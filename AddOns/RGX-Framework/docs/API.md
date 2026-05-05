# RGX-Framework API Reference

Complete public API by module. See individual module docs for deeper detail:

- [docs/FONTS.md](FONTS.md) — font system
- [docs/DROPDOWNS.md](DROPDOWNS.md) — dropdown system
- [docs/ARCHITECTURE.md](ARCHITECTURE.md) — load order, module system, lifecycle

---

## Core (`RGXFramework` / `RGX`)

### Lifecycle

| Method | Description |
|---|---|
| `RGX:IsReady()` | `true` after ADDON_LOADED init completes |
| `RGX:OnReady(fn)` | Call `fn` now if ready, otherwise queue |
| `RGX:OnLogin(fn)` | Run `fn` on PLAYER_LOGIN |
| `RGX:OnLoad(addonName, fn)` | Run `fn` when a specific addon loads |

### Module Access

| Method | Description |
|---|---|
| `RGX:GetModule(name)` | Soft get; returns nil if not loaded |
| `RGX:RequireModule(name)` | Hard get; logs error if missing |
| `RGX:IsModuleLoaded(name)` | Boolean |
| `RGX:GetLoadedModules()` | Sorted list of registered module names |
| `RGX:RegisterModule(name, module, opts)` | Register a module table |

### Shortcut Getters

| Method | Module |
|---|---|
| `RGX:GetFonts()` | RGXFonts |
| `RGX:GetColors()` | RGXColors |
| `RGX:GetTextures()` | RGXTextures |
| `RGX:GetDropdowns()` | RGXDropdowns |
| `RGX:GetUI()` | RGXUI |
| `RGX:GetColorPicker()` | RGXColorPicker |
| `RGX:GetMinimap()` | RGXMinimap |
| `RGX:GetDesign()` | RGXDesign |
| `RGX:GetDataBroker()` | RGXDataBroker |
| `RGX:GetSound()` | RGXSound |
| `RGX:GetPetBattles()` | RGXPetBattles (dormant — returns nil) |
| `RGX:GetSharedMedia()` | RGXSharedMedia (dormant — returns nil) |
| `RGX:GetCombat()` | RGXCombat (dormant — returns nil) |
| `RGX:GetReputation()` | RGXReputation (dormant — returns nil) |

### Output

| Method | Description |
|---|---|
| `RGX:Print(...)` | `|cff58be81[RGX]|r` green prefix |
| `RGX:Warn(...)` | `|cffffcc00[RGX]|r` yellow prefix |
| `RGX:Error(...)` | `|cffff4444[RGX]|r` red prefix |
| `RGX:Debug(...)` | Prints only when `debugMode` is true |

### Chat Prefix

```lua
local prefix = RGX:CreateChatPrefix({
    icon = "Interface\\AddOns\\MyAddon\\media\\logo.tga",
    tag = "MYA",
    tagColor = "58be81",
    iconSize = 16,
    spacer = " - ",
})
```

### Object Composition

| Method | Description |
|---|---|
| `RGX:Mixin(target, ...)` | Copy all fields from source tables into target; returns target |
| `RGX:CopyTable(orig)` | Deep copy including metatables |
| `RGX:Clamp(val, min, max)` | Number clamp |
| `RGX:Lerp(a, b, t)` | Linear interpolation, t clamped to [0,1] |
| `RGX:TableCount(tbl)` | Count all keys |

### Convenience Wrappers

| Method | Description |
|---|---|
| `RGX:Minimap(config)` | Shortcut for `RGX:GetMinimap():Create(config)` |
| `RGX:CreateMinimapButton(config)` | Convenience minimap pattern with auto-wiring |
| `RGX:Options(config)` | Shortcut for `RGX:GetUI():CreateOptionsPanel(config)` |
| `RGX:Toggle(parent, opts)` | Shortcut for `UI:CreateToggle` |
| `RGX:Slider(parent, opts)` | Shortcut for `UI:CreateSlider` |
| `RGX:ColorPicker(parent, opts)` | Shortcut for `UI:CreateColorPicker` |
| `RGX:Section(parent, opts)` | Shortcut for `UI:CreateSection` |
| `RGX:Label(parent, opts)` | Shortcut for `UI:CreateLabel` |
| `RGX:PlaySound(id, channel)` | Lookup path via SharedMedia and play |

### Properties

| Property | Type | Description |
|---|---|---|
| `RGX.version` | string | From TOC metadata (e.g. `"1.6.0"`) |
| `RGX.debugMode` | boolean | Enable `Debug()` output |
| `RGX.db` | table | `RGXFrameworkDB` SavedVar reference |
| `RGX.timers` | array | Active timer table |
| `RGX.combatQueue` | array | Pending combat-locked operations |
| `RGX.timerBudget` | table | `{ maxPerFrame=256, maxSeconds=0.033, slowSeconds=0.050 }` |

---

## Events & Messages

### WoW Events

| Method | Description |
|---|---|
| `RGX:RegisterEvent(event, callback, id, owner)` | Register a C event handler; returns handler ID or false |
| `RGX:UnregisterEvent(event, id)` | Remove a specific handler |
| `RGX:UnregisterAllEvents(id)` | Remove all handlers for an ID |
| `RGX:FireEvent(event, ...)` | Manually dispatch into the event registry |

### Messages

| Method | Description |
|---|---|
| `RGX:RegisterMessage(message, callback, id, owner)` | Register an internal message handler |
| `RGX:UnregisterMessage(message, id)` | Remove handler |
| `RGX:UnregisterAllMessages(id)` | Remove all handlers for an ID |
| `RGX:SendMessage(message, ...)` | Dispatch message to all handlers |

`RegisterCallback` / `UnregisterCallback` / `UnregisterAllCallbacks` are aliases for the message API.

### CreateEmitter

```lua
local emitter = RGX:CreateEmitter(name)
emitter:RegisterCallback(signal, fn, id)
emitter:UnregisterCallback(signal, id)
emitter:UnregisterAllCallbacks(id)
emitter:Fire(signal, ...)
```

---

## Timers

| Method | Description |
|---|---|
| `RGX:After(duration, callback, label)` | One-shot delay; returns timer ref |
| `RGX:Every(duration, callback, label)` | Repeating ticker; callback receives timer ref |
| `RGX:CancelTimer(timer)` | Stop a ticker or pending one-shot |
| `RGX:CancelAllTimers()` | Cancel all active timers |
| `RGX:CreateTimer(duration, callback, repeating, label)` | Low-level; returns timer table |

`Every` callback signature: `function(timer)` — repeating timers can cancel themselves.

---

## Hooks

| Method | Description |
|---|---|
| `RGX:Hook(target, method, callback)` | Post-hook via `hooksecurefunc`; cannot be unhooked |
| `RGX:Unhook(target, method)` | Not supported (hooksecurefunc limitation) |
| `RGX:UnhookAll()` | Not supported |

Callback signature: `function(original, self, ...) return original(self, ...) end`

---

## Combat Queue

| Method | Description |
|---|---|
| `RGX:QueueForCombat(func, ...)` | Run now if not in combat, otherwise queue for PLAYER_REGEN_ENABLED |
| `RGX:ProcessCombatQueue()` | Flush all queued operations |
| `RGX:ShouldQueueOperation()` | Returns `InCombatLockdown()` |

### Safe Helpers

| Method | Description |
|---|---|
| `RGX:SafeShow(frame)` | Combat-safe Show |
| `RGX:SafeHide(frame)` | Combat-safe Hide |
| `RGX:SafeSetPoint(frame, ...)` | Combat-safe ClearAllPoints + SetPoint |
| `RGX:SafeSetSize(frame, w, h)` | Combat-safe SetSize |
| `RGX:SafeSetText(region, text)` | Combat-safe SetText |
| `RGX:SafeUIDropDownMenu_SetText(dd, text)` | Combat-safe dropdown text |
| `RGX:SafeUIDropDownMenu_Initialize(dd, init, displayMode)` | Combat-safe dropdown init |
| `RGX:SafeUIDropDownMenu_Refresh(dd)` | Combat-safe dropdown refresh |
| `RGX:SafeUIDropDownMenu_EnableDropDown(dd)` | Combat-safe dropdown enable |
| `RGX:SafeUIDropDownMenu_DisableDropDown(dd)` | Combat-safe dropdown disable |
| `RGX:SafeToggleDropDownMenu(...)` | Combat-safe ToggleDropDownMenu |
| `RGX:SafeCloseDropDownMenus(...)` | Combat-safe CloseDropDownMenus |

---

## Slash Commands

| Method | Description |
|---|---|
| `RGX:RegisterSlashCommand(commands, callback, id)` | Register; commands: string or table; returns token |
| `RGX:Slash(command, callback)` | Shorthand for single-command registration |

---

## Utilities

### String

| Method | Description |
|---|---|
| `RGX:Trim(str)` | Strip leading/trailing whitespace |
| `RGX:Split(str, delimiter)` | Split string, returns table |
| `RGX:Format(pattern, ...)` | `string.format` wrapper |
| `RGX:StartsWith(str, prefix)` | Boolean |
| `RGX:EndsWith(str, suffix)` | Boolean |

### Table

| Method | Description |
|---|---|
| `RGX:TableKeys(tbl)` | Array of all keys |
| `RGX:TableValues(tbl)` | Array of all values |
| `RGX:TableContains(tbl, value)` | Boolean |
| `RGX:TableMap(tbl, fn)` | New table with fn(v) applied |
| `RGX:TableFilter(tbl, fn)` | New array of values where fn(v) is true |
| `RGX:TableFind(tbl, fn)` | First value where fn(v) is true |
| `RGX:MergeTable(dst, src)` | Shallow merge src into dst; returns dst |

### Math

| Method | Description |
|---|---|
| `RGX:Round(num, decimals)` | Round to N decimal places |
| `RGX:Clamp(val, min, max)` | Number clamp |
| `RGX:Lerp(a, b, t)` | Linear interpolation, t ∈ [0,1] |

### WoW Version

| Method | Description |
|---|---|
| `RGX:GetWoWVersion()` | Numeric build version |
| `RGX:IsRetail()` | Boolean |
| `RGX:IsClassicEra()` | Boolean |

---

## Fonts (`RGXFonts`)

See [docs/FONTS.md](FONTS.md) for complete documentation.

### Registry

| Method | Description |
|---|---|
| `Fonts:Register(name, path, info)` | Register a font |
| `Fonts:RegisterAddonFont(addon, name, file, info)` | Register font from external addon |
| `Fonts:RegisterFontPack(addon, definitions)` | Batch-register fonts |
| `Fonts:Exists(name)` | Boolean (includes unavailable) |
| `Fonts:IsAvailable(name)` | Boolean (excludes blocklist) |
| `Fonts:GetPath(name)` | Absolute font path or nil |
| `Fonts:Get(name, size, flags)` | Returns path, size, flags |
| `Fonts:GetFont(name, size, flags)` | Alias for Get |
| `Fonts:GetInfo(name)` | Full registry entry |
| `Fonts:List()` | All registered names |
| `Fonts:ListAvailable()` | Available names only |
| `Fonts:ListByCategory(cat)` | Names in category |
| `Fonts:GetCategories()` | Distinct categories |
| `Fonts:GetFamilies()` | Distinct families |
| `Fonts:GetGroupedFonts()` | Nested { [cat] = { [fam] = { name, ... } } } |
| `Fonts:FindByPath(path)` | Path → name reverse lookup |
| `Fonts:ResolveName(value, fallback)` | Accept name or path, return name |
| `Fonts:ResolvePath(value, fallback)` | Return safe path and name |

### Apply

| Method | Description |
|---|---|
| `Fonts:Apply(fontString, name, size, flags)` | SetFont on FontString |
| `Fonts:Quick(fontString, name, size, flags)` | Same with nil guards |
| `Fonts:ApplyChildren(frame, name, size, flags)` | Recursive apply to child FontStrings |
| `Fonts:CreateString(parent, name, size, flags, layer)` | Create + apply |
| `Fonts:FromTemplate(parent, template, text, layer)` | Create from named template |

### Defaults

| Method | Description |
|---|---|
| `Fonts:SetDefault(name)` | Set default font name |
| `Fonts:GetDefault()` | Get default font name |
| `Fonts:SetDefaultSize(size)` | Set default size |
| `Fonts:SetDefaultFlags(flags)` | Set default flags |
| `Fonts:SetAutoScale(enable)` | Enable auto-scaling |

### Styles

| Method | Description |
|---|---|
| `Fonts:CreateStyle(tbl)` | Create normalized style object |
| `Fonts:ApplyStyle(fs, style)` | Apply all style fields to FontString |
| `Fonts:ApplyTextStyle(fs, style)` | Alias for ApplyStyle |
| `Fonts:NormalizeStyle(style)` | Fill missing fields with defaults |
| `Fonts:NormalizeColorValue(color)` | Normalize color to {r,g,b,a} |
| `Fonts:GetStyle(font, size, flags)` | Build minimal style table |

### Flags

| Method | Description |
|---|---|
| `Fonts:SplitFlags(flags)` | String → array |
| `Fonts:NormalizeFlags(flags)` | String or table → canonical string |
| `Fonts:DescribeFlags(flags)` | Human-readable description |
| `Fonts:GetFlagPresets()` | Preset flag combinations |

### Controls

| Method | Description |
|---|---|
| `Fonts:CreateFontDropdown(parent, opts)` | Full grouped font dropdown |
| `Fonts:CreateFontSettingControl(parent, opts)` | Font dropdown + reset + flag + size |
| `Fonts:CreateStyleSelector(parent, opts)` | Full style editor with preview |
| `Fonts:CreateSimpleFontSelector(parent, opts)` | Minimal font selector |
| `Fonts:CreateSimpleStyleSelector(parent, opts)` | Minimal style selector |
| `Fonts:AttachFontSelector(parent, db, key, opts)` | One-line DB-bound font UI |
| `Fonts:AttachStyleSelector(parent, db, key, opts)` | One-line DB-bound style UI |

### Menu Items

| Method | Description |
|---|---|
| `Fonts:CreateFontMenuItems(opts)` | UIDropDownMenu-compatible font items |
| `Fonts:CreateFlagMenuItems(opts)` | Flag selection items |
| `Fonts:CreateSizeMenuItems(opts)` | Size selection items |
| `Fonts:CreateStyleMenuItems(opts)` | Composite style items |

### Internal

| Method | Description |
|---|---|
| `Fonts:BuildGroupedFontItems(opts)` | Build grouped menu items (single source of truth) |
| `Fonts:Init()` | Module initialization (called by TryInit) |

---

## Colors (`RGXColors`)

### Lookup

| Method | Description |
|---|---|
| `Colors:Get(name)` | Returns `{r, g, b, a}` |
| `Colors:GetRGB(name)` | Returns r, g, b (multi-return) |
| `Colors:GetHex(name)` | Returns `"#RRGGBB"` |
| `Colors:GetClass(className)` | Class color table |
| `Colors:GetQuality(quality)` | Quality color table (0–5) |
| `Colors:GetPower(powerType)` | Power type color table |

### Text Wrapping

| Method | Description |
|---|---|
| `Colors:Wrap(text, colorName)` | `|cffRRGGBBtext|r` |
| `Colors:WrapClass(text, className)` | Wrap in class color |
| `Colors:WrapQuality(text, quality)` | Wrap in quality color |

### Color Math

| Method | Description |
|---|---|
| `Colors:Create(r, g, b, a)` | New color table |
| `Colors:Clone(color)` | Deep copy |
| `Colors:Darken(colorName, amount)` | Darkened color |
| `Colors:Lighten(colorName, amount)` | Lightened color |
| `Colors:SetAlpha(colorName, alpha)` | New color with alpha set |
| `Colors:Lerp(c1, c2, t)` | Interpolate between two colors |
| `Colors:Gradient(pct, low, mid, high)` | 3-stop gradient; mid optional |
| `Colors:Health(percent)` | Health gradient (green → yellow → red) |
| `Colors:RGBToHex(r, g, b)` | Returns `"RRGGBB"` |
| `Colors:HexToRGB(hex)` | Returns r, g, b |

### Apply

| Method | Description |
|---|---|
| `Colors:ApplyText(fontString, colorName)` | Set text color |
| `Colors:ApplyTexture(texture, colorName)` | Set texture color |
| `Colors:ApplyStatusBar(statusBar, colorName)` | Set bar color |

### Picker (Blizzard API)

```lua
Colors:OpenPicker({
    color = "brand",
    hasOpacity = false,
    onChanged = function(color, r, g, b, a, cancelled) end,
})
```

### Inline Controls

| Method | Description |
|---|---|
| `Colors:CreateColorPicker(parent, opts)` | Inline color swatch + picker |
| `Colors:CreateColorSettingControl(parent, opts)` | DB-bound color control |

---

## ColorPicker (`RGXColorPicker`)

Custom rectangular HSV color picker widget. Features:

- Figma-style rectangular selector (saturation/value box)
- Hue bar
- RGB and HEX input fields
- Color history
- Class, quality, and basic palettes

Called via `Colors:OpenPicker()` or `Colors:CreateColorPicker()`. Not typically used directly.

---

## Textures (`RGXTextures`)

### Registry

| Method | Description |
|---|---|
| `Textures:RegisterBar(name, path, opts)` | Register a statusbar texture |
| `Textures:RegisterBars(source, bars, opts)` | Batch-register |
| `Textures:Exists(name)` | Boolean |
| `Textures:GetInfo(name)` | `{ name, path, group, source }` |
| `Textures:GetBar(name)` | Returns path string |
| `Textures:GetDefault()` | Default texture name |
| `Textures:GetDefaultPath()` | Default texture path |
| `Textures:SetDefault(name)` | Set default |
| `Textures:ListBars()` | Sorted array of all names |
| `Textures:ListAvailable()` | Alias for ListBars |
| `Textures:GetGroups()` | Distinct group strings |
| `Textures:ListByGroup(group)` | Names in a group |
| `Textures:GetDropdownItems()` | Grouped item list for CreateNestedDropdown |
| `Textures:ImportLibSharedMedia(force)` | Pull LSM bars into registry |

### Apply

| Method | Description |
|---|---|
| `Textures:ApplyToStatusBar(bar, name)` | Set statusbar texture |
| `Textures:ApplyToTexture(region, name)` | Set texture |

### Controls

| Method | Description |
|---|---|
| `Textures:CreateBarDropdown(parent, opts)` | Texture dropdown |
| `Textures:CreateBarSettingControl(parent, opts)` | DB-bound texture control |
| `Textures:AttachBarSelector(parent, db, key, opts)` | One-line DB-bound texture UI |

---

## Dropdowns (`RGXDropdowns`)

See [docs/DROPDOWNS.md](DROPDOWNS.md) for complete documentation.

| Method | Description |
|---|---|
| `Drops:CreateNestedDropdown(parent, opts)` | Full nested dropdown widget |
| `Drops:ForceWidth(level, min, inset, opts)` | Auto-size list frame |
| `Drops:AddInlineButton(btnFrame, opts)` | Add per-item action widget |
| `Drops:HideInlineButtons(level, key)` | Hide inline buttons before re-populate |
| `Drops:GetListFrame(level)` | Returns `DropDownListN` frame |
| `Drops:ShortenLabel(text, maxChars)` | Truncate with "..." |
| `Drops:CopyItem(item)` | Normalize single item |
| `Drops:NormalizeItems(items)` | Normalize item array in place |

---

## Design (`RGXDesign`)

### Static Color Palette

| Key | Hex | Usage |
|---|---|---|
| `primary` | `#58be81` | Brand green |
| `accent` | `#bc6fa8` | Brand purple |
| `surface` | — | Panel backgrounds |
| `background` | — | Main backgrounds |
| `text` | — | Primary text |
| `subtext` | — | Secondary text |
| `success` | — | Positive indicators |
| `warning` | — | Caution indicators |
| `error` | — | Error/negative indicators |
| `border` | — | Default borders |
| `borderActive` | — | Focused borders |
| `hover` | — | Hover highlights |

Access via `Design.Colors.primary`, `Design.Colors.accent`, etc.

---

## UI Controls (`RGXUI`)

### Control Factory

| Method | Description |
|---|---|
| `UI:CreateFontDropdown(parent, opts)` | Font selector dropdown |
| `UI:CreateStatusBarDropdown(parent, opts)` | Texture selector dropdown |
| `UI:CreateTextureDropdown(parent, opts)` | Texture selector dropdown |
| `UI:OpenFontMenu(anchor, opts)` | Pop-up font menu |
| `UI:CreateColorPicker(parent, opts)` | Inline color swatch + picker |
| `UI:CreateSlider(parent, opts)` | Numeric slider |
| `UI:CreateToggle(parent, opts)` | Checkbox toggle |
| `UI:CreateLabel(parent, opts)` | Text label |
| `UI:CreateCheckBox(parent, opts)` | Checkbox with label |
| `UI:CreateDropdown(parent, opts)` | Generic dropdown |
| `UI:CreateResetButton(parent, callback)` | Reset button |
| `UI:CreateSection(parent, opts)` | Section divider with optional title |
| `UI:CreatePreviewFrame(parent, opts)` | Styled backdrop panel |

### Options Panel

```lua
local panel = UI:CreateOptionsPanel({
    title = "My Addon",
    tabs = {
        { text = "General", content = function(parent) ... end },
        { text = "Appearance", content = function(parent) ... end },
    },
})
panel:Open()
panel:SelectTab(1)
panel:SelectTabByName("Appearance")
```

---

## Minimap (`RGXMinimap`)

### Create

```lua
local btn = MM:Create({
    name = "MyAddonMinimapButton",
    icon = "Interface\\...",
    defaultAngle = 220,
    buttonSize = 32,
    iconSize = 19,
    storage = db,
    angleKey = "minimapAngle",
    enabledKey = "minimapEnabled",
    tooltip = { title = "...", lines = {...} },
    onLeftClick = function(btn) end,
    onRightClick = function(btn) end,
    onCtrlRight = function(btn) btn:SetVisible(false) end,
    onVisibilityChanged = function(visible, btn) end,
})
```

### Button API

| Method | Description |
|---|---|
| `btn:SetVisible(bool)` | Show/hide + write storage + fire callback |
| `btn:Toggle()` | Flip visibility |
| `btn:Show()` | Place at angle, show frame |
| `btn:Hide()` | Hide frame |
| `btn:IsShown()` | Boolean |
| `btn:GetEnabled()` | Reads storage enabledKey |
| `btn:PlaceAtAngle()` | Reposition from stored angle |
| `btn:GetAngle()` | Current angle in degrees |
| `btn:SetAngle(deg)` | Store angle |
| `btn.frame` | Raw WoW Button frame |

### Registry

| Method | Description |
|---|---|
| `MM:Get(name)` | Retrieve button wrapper by frame name |

---

## Sound (`RGXSound`)

```lua
Sound:Register(name, opts)
-- opts: { path, channel, variants, defaultSound, muteable }
```

Level-up sound system with variant playback, default-sound muting, and SavedVar integration. Currently loaded by XML but primarily used by PetBuddy2.

---

## DataBroker (`RGXDataBroker`)

```lua
local dataObj = DB:NewDataObject(name, attrs)
```

LibDataBroker-compatible proxy data source with optional LDB bridge. Currently loaded by XML but minimal external usage.

---

## Dormant Modules

The following modules are in-tree but not loaded by the current XML:

### PetBattles (`RGXPetBattles`)

| Method | Description |
|---|---|
| `PB:OnLevelUp(fn)` | Register level-up callback |
| `PB:OnCapture(fn)` | Register capture callback |
| `PB:OnBattleStart(fn)` | Register battle start callback |
| `PB:OnBattleEnd(fn)` | Register battle end callback |
| `PB:OnPetChanged(fn)` | Register pet changed callback |
| `PB:IsAvailable()` | Pet battle system accessible |
| `PB:IsInBattle()` | In active battle |
| `PB:GetNumPets()` | Owned pet count |
| `PB:GetPetInfoByIndex(i)` | C_PetJournal result table |
| `PB:GetPetInfoByID(id)` | C_PetJournal result table |
| `PB:GetPetLevel(id)` | Cached level |
| `PB:ScanPetLevels()` | Populate level cache |
| `PB:CheckPetLevels()` | Diff scan, fire OnLevelUp |
| `PB:SchedulePetLevelScan(delay)` | Delayed scan |

### SharedMedia (`RGXSharedMedia`)

Sound/font/texture registry with pack scanner. Drop-in for LibSharedMedia scanning logic.

### Combat (`RGXCombat`)

Combat event library: enter/leave/kill/damage/heal/crit callbacks.

### Reputation (`RGXReputation`)

Reputation and renown tracking, cross-expansion normalized.
