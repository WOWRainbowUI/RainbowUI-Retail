# v2.0.16 - 2026-04-29

## Bug Fixes

- **General tab layout**: Moved the shared nameplate font dropdown to the right
  column bottom card area instead of placing it at the top of the column.
- **Preview width stability**: Kept the newer preview shell from stretching to
  live nameplate width while preserving old-style SQP icon anchoring/settings.
- **Dropdown UX restored**: SQP now uses the compact RGX font dropdown again,
  not an inline visible picker.

# v2.0.15 - 2026-04-29

## Bug Fixes

- **Welcome version colors**: SQP's login version line now matches the shared
  PB2/ETL chat style: yellow `Version:` label and blue version number, with no
  hardcoded extra `v` outside the version value.

# v2.0.14 - 2026-04-29

## Bug Fixes

- **Preview shell restored**: Kept the newer framed preview banner/nameplate
  shell while preserving the old live-style SQP icon anchoring and settings
  application.
- **Font picker layout**: SQP General tab now makes room for RGX's visible paged
  font picker so choices render directly in the options panel.

# v2.0.13 - 2026-04-29

## Bug Fixes

- **Live preview restored**: Reverted the SQP options preview geometry to the
  older live-style implementation: marker parented to the fake nameplate,
  AutoQuest jellybean sizing, saved anchor/offset/scale applied, and kill/loot
  task icons honoring their saved offsets and visibility settings.

# v2.0.12 - 2026-04-29

## Bug Fixes

- **Preview jellybean restored**: SQP options preview now uses the same
  AutoQuest jellybean texture/coordinates as the live nameplate icon.
- **Preview font diagnostics**: Preview font application errors now print to chat
  instead of silently aborting the sample update.
- **Font dropdown diagnostics**: SQP General tab now prints whether the RGX font
  control was built and includes the actual error if construction fails.

# v2.0.11 - 2026-04-29

## Bug Fixes

- **Blizzard Settings restored**: SQP options are registered/opened through
  Blizzard Settings again now that RGX has safer timer and blocked-action
  diagnostics around the open path.
- **Nameplate timer pressure reduced**: The delayed nameplate recheck now prefers
  Blizzard's native `C_Timer.After()` instead of adding every plate-show recheck
  to the RGX OnUpdate timer queue.
- **Slow path diagnostics**: SQP now reports slow nameplate/font/icon update
  paths over 50ms so the in-game trace points at the real expensive callback
  instead of whichever cheap function the watchdog interrupted.

# v2.0.10 - 2026-04-29

## Bug Fixes

- **Settings-block isolation**: SQP now opens the RGX options panel directly for
  testing instead of registering/opening through Blizzard Settings, removing the
  suspected `Settings.OpenToCategory` protected-action path.
- **Preview markers forced visible**: The preview marker cluster is fixed inside
  the banner and no longer follows saved live nameplate offsets or scale that
  can push the sample icons out of view.
- **Font error diagnostics**: If the RGX font control still fails to build, SQP
  now prints the actual Lua error text under the control instead of only showing
  the generic dropdown failure.

# v2.0.9 - 2026-04-29

## Bug Fixes

- **Login blocked-action reduction**: SQP framework initialization no longer
  builds/registers the full options panel during addon startup; the panel is
  created lazily when `/sqp` or the minimap icon opens options.
- **Native RGX font selector**: The General tab now uses RGX's native shared font
  picker, avoiding the broken Blizzard dropdown path that produced “Unable to
  build RGX font dropdown.”
- **Preview marker visibility**: The options preview now mirrors scale by sizing
  the marker texture instead of scaling the full overlay frame, keeping SQP kill,
  loot, and percent icons visible in the banner.

# v2.0.8 - 2026-04-29

## Bug Fixes

- **RGX font dropdown restored**: SQP's General tab now builds against the
  restored RGX nested dropdown dispatcher and flatter shared font menu.
- **Options open performance**: The preview no longer probes live nameplate
  frames while Blizzard Settings is opening, reducing the minimap-click spike.
- **Preview icon visibility**: The preview marker layer is now parented to the
  preview container instead of the fake nameplate, so off-plate SQP icons are not
  clipped out of view.

# v2.0.7 - 2026-04-29

## Bug Fixes

- **Minimap options click**: SQP now defers minimap left-click options opening
  with native `C_Timer.After(0)` before falling back to RGX timers, reducing
  protected-action attribution when opening Blizzard Settings.
- **General tab organization**: Kept the shared RGX font selector on the right
  column with the position and scale controls, leaving addon state and minimap
  controls grouped on the left.
- **Preview marker visibility**: The preview nameplate now clamps extreme saved
  offsets and always renders the sample SQP kill, loot, and percent markers so
  the preview demonstrates the actual purpose of the addon.

# v2.0.6 - 2026-04-28

## Bug Fixes

- **Minimap options open**: SQP now defers the minimap left-click options open
  by one frame and relies on RGX's safer Retail Settings path, avoiding the
  protected Blizzard UI fallback that could block the click.
- **General font dropdown**: Moved the nameplate text font selector higher on
  the General tab and guarded its RGX font-control creation so failures show a
  visible message instead of silently stopping the tab build.
- **Preview icons**: The options preview now force-renders the SQP quest marker
  and uses stable texture paths for the kill and loot sample icons.

# v2.0.5 - 2026-04-28

## Bug Fixes

- **Minimap options behavior**: SQP explicitly opens through RGX's Blizzard
  Settings path, so clicking the minimap icon selects the SQP options category
  instead of showing a standalone fallback panel.
- **Nameplate creation safety**: `NAME_PLATE_CREATED` now only records the plate.
  SQP builds the heavier quest overlay lazily when the plate receives a unit,
  preventing large nameplate batches from timing out inside framework helpers.

# v2.0.4 - 2026-04-28

## Bug Fixes

- **Options menu restored**: SQP now registers its RGX Settings category during
  framework initialization again, so it appears in Blizzard's AddOns menu on load.
- **Options load safety**: Heavy SQP preview and tab content now rely on RGX's
  show-time lazy build path instead of being constructed during login.
- **Saved-variable timing**: SQP framework UI initialization now waits for
  `SQPSettings` to load before creating minimap/options storage-backed widgets.
- **Version sync**: Runtime version metadata now matches the TOC version.

# v2.0.3 - 2026-04-28

## Bug Fixes

- **Login stability**: SQP no longer builds the full RGX options panel during
  `PLAYER_LOGIN`; options are created lazily when opened, while the minimap icon
  still initializes during framework readiness.

# v2.0.2 - 2026-04-28

## Enhancements

- **Framework chat prefix**: SQP now uses `RGX:CreateChatPrefix()` for chat
  output so the icon/tag format stays consistent with other RGX addons.

## Bug Fixes

- **Icon path cleanup**: Updated SQP branding to use `media/logo.tga` instead of
  the removed `media/icon.tga` path in the TOC, options panel, about tab, and
  panel header.
- **Chat icon sizing**: Aligned the SQP chat icon size with the shared 16x16
  prefix style used by other RGX addons.
- **Font selection safety**: SQP nameplate rendering now resolves saved font
  paths through `RGXFonts:ResolvePath()` before applying them, so invalid or
  stale saved font paths fall back through the framework instead of breaking
  `SetFont()`.

# v2.0.1 - 2026-04-25

## Bug Fixes

- **Options panel restored**: All tab content (General, Kill, Loot, Percent, About) now
  renders correctly after the RGX-Framework v1.5.3 CreateAddHelper fix.
- **Preview bar**: Fixed sizing — preview container now uses anchors instead of
  `parent:GetWidth()` (which returned 0 during frame construction). Added backdrop
  styling to make the preview section visually distinct.
