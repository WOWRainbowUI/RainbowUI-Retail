import argparse
import json
from pathlib import Path


DEFAULT_CHANGELOG = "Automated release"
DEFAULT_GAME_VERSION_NAMES = ["Retail", "12.1.0"]


def read_latest_changelog(changelog_path: Path) -> str:
    if not changelog_path.exists():
        return DEFAULT_CHANGELOG

    lines = changelog_path.read_text(encoding="utf-8").splitlines()
    capture = False
    collected = []

    for line in lines:
        if line.startswith("## "):
            if capture:
                break
            capture = True
            continue

        if capture:
            collected.append(line)

    text = "\n".join(collected).strip()
    return text or DEFAULT_CHANGELOG


def build_metadata(version: str, changelog: str, game_version_names: list[str]) -> dict:
    return {
        "displayName": f"MikScrollingBattleText {version}",
        "changelog": changelog,
        "changelogType": "markdown",
        "releaseType": "release",
        "gameVersionNames": game_version_names,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", required=True)
    parser.add_argument("--changelog", default="CHANGELOG.md")
    parser.add_argument("--output", required=True)
    parser.add_argument(
        "--game-version",
        action="append",
        dest="game_versions",
        default=[],
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()

    changelog = read_latest_changelog(Path(args.changelog))
    game_versions = args.game_versions or list(DEFAULT_GAME_VERSION_NAMES)
    metadata = build_metadata(
        version=args.version,
        changelog=changelog,
        game_version_names=game_versions,
    )

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(metadata), encoding="utf-8")


if __name__ == "__main__":
    main()
