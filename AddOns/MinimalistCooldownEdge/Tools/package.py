"""Build independent Retail/Forever archives. Default output is a QA draft.

Run from any location: py Tools/package.py --output .release
Release builds require a clean tagged checkout and recorded in-game validation.
This tool never commits, tags, uploads, or installs an archive.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import zipfile
import xml.etree.ElementTree as ET


def git(root, *args):
    return subprocess.check_output(["git", "-C", str(root), *args], text=True).strip()


def resolve_file(root, relative):
    relative = relative.replace("\\", "/")
    path = (root / relative).resolve()
    if not path.is_relative_to(root.resolve()):
        raise ValueError(f"File escapes addon root: {relative}")
    if not path.is_file():
        raise ValueError(f"Missing runtime file: {relative}")
    return path


def runtime_files(root, toc):
    files = set()

    def add(relative):
        path = resolve_file(root, relative)
        if path in files:
            return
        files.add(path)
        if path.suffix.lower() == ".xml":
            xml = ET.parse(path)
            for element in xml.iter():
                if element.tag.rsplit("}", 1)[-1] in ("Script", "Include"):
                    filename = element.get("file")
                    if filename:
                        add((path.parent / filename.replace("\\", "/")).relative_to(root).as_posix())

    for line in toc.splitlines():
        entry = line.strip()
        if entry and not entry.startswith("#"):
            add(entry)
    # Ship runtime assets and licensing; do not ship build tools, tests or VCS.
    assets = {".ogg", ".mp3", ".wav", ".tga", ".blp", ".png", ".jpg", ".jpeg", ".ttf", ".otf"}
    for path in root.rglob("*"):
        relative = path.relative_to(root)
        if any(part.startswith(".") or part.lower() in ("tools", "tests", "test", "node_modules", "__pycache__") for part in relative.parts):
            continue
        licensing = any(part.lower() == "licenses" for part in relative.parts) or path.name.upper().startswith(("LICENSE", "NOTICE", "ATTRIBUTION"))
        if path.is_file() and (path.suffix.lower() in assets or licensing or path.name in (
            "README.md", "CHANGELOG.md", "LICENSE", "LICENSE.md", "LICENSE.txt", "NOTICE", "NOTICE.md", "CREDITS.md", "FOREVER.md")):
            resolve_file(root, relative.as_posix())
            files.add(path)
    return sorted(files)


def edition_toc(toc, edition):
    if edition == "Forever":
        toc = re.sub(r"(?m)^## Interface:.*$", "## Interface: 16001", toc)
        toc = re.sub(r"(?m)^## AllowLoadGameType:.*$", "## AllowLoadGameType: camelot", toc)
        if "## AllowLoadGameType:" not in toc:
            toc = toc.replace("## Interface: 16001", "## Interface: 16001\n## AllowLoadGameType: camelot", 1)
    else:
        def interfaces(match):
            values = [v.strip() for v in match.group(1).split(",") if v.strip() != "16001"]
            return "## Interface: " + ", ".join(values)
        toc = re.sub(r"(?m)^## Interface:\s*(.*)$", interfaces, toc)
        def game_types(match):
            return "## AllowLoadGameType: " + ", ".join(
                v.strip() for v in match.group(1).split(",") if v.strip() != "camelot")
        toc = re.sub(r"(?m)^## AllowLoadGameType:\s*(.*)$", game_types, toc)
    return toc


def build(root, output, release=False, tag=None):
    config = json.loads((root / "Tools" / "package.json").read_text(encoding="utf-8"))
    addon = config["addon"]
    toc_path = root / f"{addon}.toc"
    toc = toc_path.read_text(encoding="utf-8-sig")
    version = re.search(r"(?m)^## Version:\s*(.+)$", toc).group(1).strip()
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", version):
        raise ValueError("TOC version must be a concrete safe filename component")
    qa = json.loads((root / "Tools" / "validation.json").read_text(encoding="utf-8"))
    if release:
        if not tag or git(root, "status", "--porcelain"):
            raise ValueError("Release requires --tag and a clean checkout")
        if tag.removeprefix("v") != version:
            raise ValueError("Release tag must match the TOC version")
        if git(root, "rev-parse", "HEAD") != git(root, "rev-parse", f"{tag}^{{commit}}"):
            raise ValueError("Tag must identify this checkout")
        for key in ("static", "forever_runtime", "retail_runtime", "dependencies"):
            if qa.get(key) != "PASS":
                raise ValueError(f"Release blocked: {key} is {qa.get(key)}")
        if not qa.get("forever_build") or not qa.get("tested_by"):
            raise ValueError("Release requires actual Forever build and tester evidence")
    files = runtime_files(root, toc)
    output.mkdir(parents=True, exist_ok=True)
    results = []
    for edition in ("Retail", "Forever"):
        archive = output / f"{addon}-{version}-{edition}.zip"
        manifest = {
            "addon": addon, "version": version, "edition": edition,
            "source_commit": git(root, "rev-parse", "HEAD"), "tag": tag,
            "source_dirty": bool(git(root, "status", "--porcelain")),
            "source_files_sha256": {p.relative_to(root).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest() for p in files},
            "draft": not release, "validation": qa,
        }
        with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as package:
            def write(name, data):
                info = zipfile.ZipInfo(f"{addon}/{name}", date_time=(2026, 1, 1, 0, 0, 0))
                info.compress_type = zipfile.ZIP_DEFLATED
                package.writestr(info, data)
            write(toc_path.name, edition_toc(toc, edition).encode("utf-8"))
            for path in files:
                write(path.relative_to(root).as_posix(), path.read_bytes())
            write("BUILD.json", json.dumps(manifest, ensure_ascii=False, indent=2).encode("utf-8"))
        with zipfile.ZipFile(archive) as package:
            if package.testzip() is not None:
                raise ValueError(f"Corrupt archive: {archive}")
        results.append({"archive": str(archive), "sha256": hashlib.sha256(archive.read_bytes()).hexdigest(),
                        "edition": edition, "runtime_files": len(files) + 1, "draft": not release})
    return results


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=Path(".release"))
    parser.add_argument("--release", action="store_true")
    parser.add_argument("--tag")
    args = parser.parse_args()
    addon_root = Path(__file__).resolve().parents[1]
    print(json.dumps(build(addon_root, args.output.resolve(), args.release, args.tag), indent=2))
