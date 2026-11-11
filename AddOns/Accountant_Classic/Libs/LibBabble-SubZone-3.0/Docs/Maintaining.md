# Maintainer Guide

This guide is for people who change the library itself: updating data, reviewing pull requests, and publishing releases. Addon authors who only use the library need [Integration.md](Integration.md) and [API.md](API.md).

## Repository Layout

| Path | Purpose | Packaged |
|---|---|---|
| `Core/LibBabble-3.0.lua` | Shared LibBabble-3.0 core (public domain) | Yes |
| `Core/Core.lua` | Library registration, `MINOR_VERSION`, client API resolver | Yes |
| `Core/Cleanup.lua` | Removes the temporary loading key | Yes |
| `Data/` | Generated map indexes, one set per client | Yes |
| `Locale/` | Generated translation tables, one file per locale | Yes |
| `lib.xml` | Load order for embedded use | Yes |
| `LibBabble-SubZone-3.0.toc` | Standalone addon TOC | Yes |
| `LICENSE`, `Readme.md` | License and project overview | Yes |
| `Docs/` | Developer documentation; `Docs/Changelog.md` is also the CurseForge file changelog | Yes |
| `.util/` | Data download and generation scripts | No |
| `.github/` | CI workflows and the SVN mirror | No (GitHub only) |
| `.pkgmeta` | CurseForge packager settings | No |

"Packaged" means included in the CurseForge zip. `.util/` and `.data/` are excluded in `.pkgmeta`. Files beginning with a period are always excluded by the packager.

## Updating the Data

`Data/` and `Locale/` are generated from Wago Tools CSV exports and should not be edited by hand. [.util/Readme.md](../.util/Readme.md) covers the scripts. The usual flow is:

1. Update the build mapping in the scripts when a new client build becomes the source of truth.
2. Download the CSV files into `.data/` (not committed).
3. Regenerate the `Data/` and `Locale/` files.
4. Review the diff. Large removals usually mean a download failed or a table changed its format.
5. Update the supported build table in `Readme.md`, and the TOC `## Interface` line if the client interface version changed.

If a manual correction is needed, make it in the generator, so it is not lost the next time the data is regenerated.

## MINOR_VERSION

LibStub uses `MINOR_VERSION` in `Core/Core.lua` to choose between embedded copies: the highest number wins. Two different builds with the same number are a problem, because whichever loads first is used.

Rules:

- Increase `MINOR_VERSION` in every pull request that changes a runtime file: anything under `Core/`, `Data/`, `Locale/`, or `lib.xml`.
- Increase it by at least 1. Leaving gaps is fine.
- Never decrease it, and never reuse a number from an earlier release.

The **MINOR_VERSION check** workflow enforces the first rule: a pull request that changes runtime files fails unless `MINOR_VERSION` is higher than on the base branch. Changes to documentation, the TOC, `.util/`, or `.github/` do not need a bump.

History: until 12.1-release3, `MINOR_VERSION` was `100000 + <SVN revision>`, through the `$Rev$` keyword. The last value was `100268`. From 12.1-release4 it is a fixed number: `100301`. (`100300` was used only on SVN trunk before the release.)

## Contribution Workflow

1. Create a branch from `main`.
2. Make the change, including the `MINOR_VERSION` bump if needed and an entry under the unreleased version in [Changelog.md](Changelog.md).
3. Open a pull request. CI runs:
   - **MINOR_VERSION check**
   - **SVN mirror (dry run)**: shows exactly what would be committed to SVN, in the job summary.
4. Merge the pull request into `main`. The SVN mirror commits the change to SVN `trunk`.

Changes should reach `main` through pull requests, so that the checks run before the SVN commit. Never commit to the WoWAce SVN repository directly; see [SVN Mirror](#svn-mirror).

## Releasing

1. **Prepare.** Make sure every change for the release is merged into `main`, and that the latest SVN mirror run on `main` succeeded.
2. **Changelog.** In [Changelog.md](Changelog.md), replace `Unreleased` with the release date, and update the compare link at the bottom so it ends at the new tag. Merge this through a pull request.
3. **Tag.** Tag the merge commit on `main` and push the tag:

   ```text
   git checkout main
   git pull
   git tag 12.1-release4
   git push origin 12.1-release4
   ```

4. **Check.** The SVN mirror workflow creates the SVN tag `tags/<tag>`. The CurseForge packager then builds the file. Check the run summary in GitHub Actions, then the new file on CurseForge.
5. **Next version.** Add a new `Unreleased` section at the top of the changelog.

Tag names:

- Use `<WoW version>-release<N>`, for example `12.1-release4`. The counter restarts for each new WoW version.
- A tag containing `beta` or `alpha` is packaged as a beta or alpha file instead of a release. See the CurseForge guide for [WoW addons](https://support.curseforge.com/support/solutions/articles/9000197281-wow-addons).
- Never move or reuse a tag after it has been pushed. The mirror refuses to overwrite an existing SVN tag, and CurseForge has already packaged it.

## SVN Mirror

GitHub is the source of truth. The WoWAce SVN repository at `https://repos.wowace.com/wow/libbabble-subzone-3-0` is a one-way mirror, kept for CurseForge packaging and for addons whose `.pkgmeta` points to SVN.

| GitHub event | SVN result |
|---|---|
| Push to `main` | One commit to `trunk` with the new content |
| Tag push | `tags/<tag>` copied from the trunk revision holding the tagged commit |
| Pull request | Dry run only |

### Configuration

| Setting | Where | Value |
|---|---|---|
| `SVN_MIRROR_ENABLED` | Settings → Secrets and variables → Actions → Variables (repository) | `true` to commit; anything else means dry run |
| `SVN_USERNAME` | Environment `svn-mirror` secret | CurseForge username |
| `SVN_PASSWORD` | Environment `svn-mirror` secret | CurseForge API token |
| Environment `svn-mirror` | Settings → Environments | Deployment limited to `main` and tags |

The CurseForge packager is set to package tags only, so commits to `trunk` do not create alpha files.

To rotate the token: create a new CurseForge API token, update `SVN_PASSWORD`, then run the **SVN credential check** workflow from the Actions tab. It opens a test transaction on the server and deletes it without creating a revision.

### Safety checks

Each run checks the following before writing anything:

- **Baseline:** the last SVN trunk revision must match the Git commit named in its `Git commit: <sha>` line. Any change made to SVN outside the mirror stops the run.
- **Main only:** only commits on `main` are mirrored, so a tag on another branch cannot change trunk.
- **History:** trunk never moves back to an older commit, and the run fails if the Git history was rewritten.
- **Tags:** an existing SVN tag is never overwritten.

SVN commits are atomic. A failed run leaves SVN unchanged, and a successful re-run continues from the same baseline.

### Troubleshooting

| Symptom | Cause | Action |
|---|---|---|
| `Unexpected server error 500` during the commit | Temporary WoWAce server error | Re-run the failed job |
| `401` or `403` from SVN | Missing or rejected credentials | Check the secrets, then run **SVN credential check** |
| `does not match Git commit` | SVN was changed outside the mirror | Do not force it. Compare the SVN change with GitHub and bring it into Git through a pull request. Then ask for help: the baseline has to be restored before the mirror can continue. |
| `No SVN trunk revision holds Git commit` | The tag points to a commit that was never mirrored | Tag a commit that is on `main` and already mirrored |
| `SVN tag ... already exists` | The tag name was used before | Use the next release number |
| Tag run was cancelled | A newer mirror run replaced it while it waited in the queue | Re-run the tag's workflow run |

The mirror keeps SVN content byte-for-byte equal to Git, except that `.git` and `.github` are not copied. The `svn:keywords` properties were removed in the first mirror commit (r270), because the source no longer uses keywords.
