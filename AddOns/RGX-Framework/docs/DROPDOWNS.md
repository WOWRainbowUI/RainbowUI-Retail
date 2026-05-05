# RGX Dropdowns System

Complete documentation for `RGXDropdowns` — nested UIDropDownMenu wrappers, auto-width, inline buttons, and dual-schema item normalization.

---

## Overview

RGXDropdowns wraps WoW's native `UIDropDownMenu` system with:

- **Nested submenus** — arbitrary depth via `children` arrays
- **Auto-width** — measures rendered button labels and sizes the list frame to fit
- **Inline buttons** — per-item action widgets (e.g. preview buttons) pinned to dropdown buttons
- **Item normalization** — `CopyItem` / `NormalizeItems` transforms various item schemas into the canonical UIDropDownMenu format
- **MenuUtil compatibility** — dual `func`/`onClick` fields for both legacy and modern WoW dropdown paths

No custom scroll frames, no custom menu rendering — all built on WoW's native `UIDropDownMenu_*` API.

---

## CreateNestedDropdown

```lua
local dd = Drops:CreateNestedDropdown(parent, {
    label   = "Choose Font",       -- label text above the dropdown
    width   = 200,                 -- dropdown width in pixels
    value   = "Inter-Regular",     -- initial selected value

    items = {
        { text = "Sans", isHeader = true },        -- section header
        { text = "Inter", value = "Inter-Regular", -- leaf item
          children = {                             -- OR submenu
              { text = "Regular", value = "Inter-Regular" },
              { text = "Bold",    value = "Inter-Bold" },
          }},
        { isSeparator = true },                    -- horizontal divider
        { text = "None", value = "" },             -- leaf with empty value
        { text = "Icon Item", value = "x", icon = "Interface\\Icons\\INV_Misc_QuestionMark" },
        { text = "Colored", value = "y", colorCode = "|cffFF8000" },
        { text = "Sticky",  value = "z", keepOpen = true },
    },

    onChange = function(value, item) end,          -- fires on leaf selection

    autoWidth = { minWidth = 200, leftInset = 10 }, -- auto-size the list frame

    onButtonCreated = function(buttonFrame, item) end, -- after each button is rendered
})
```

### Item schema

| Field | Type | Description |
|---|---|---|
| `text` | string | Display label |
| `value` | any | Selection value (passed to `onChange`) |
| `children` | array | Submenu items (creates `hasArrow = true`) |
| `menuList` | array | Alias for `children` (PB2 compat) |
| `isHeader` | boolean | Non-selectable section header |
| `isSeparator` | boolean | Horizontal divider |
| `icon` | string | Texture path, shown left of label |
| `colorCode` | string | `|cff` color code for label |
| `keepOpen` | boolean | Don't close menu on select |
| `func` | function | Legacy callback (PB2 / UIDropDownMenu path) |
| `onClick` | function | RGX MenuUtil callback |
| `checked` | boolean | Radio/checkbox check state |
| `isNotRadio` | boolean | Checkbox style (not radio dot) |
| `keepShownOnClick` | boolean | Menu stays open after click |
| `notCheckable` | boolean | No check indicator at all |
| `hasArrow` | boolean | Submenu arrow (auto-set if `children` present) |

---

## Item Normalization

### CopyItem

```lua
local normalized = Drops:CopyItem(item)
```

Transforms various input schemas into canonical UIDropDownMenu format:

| Input field | Output field | Rule |
|---|---|---|
| `menuList` | `children` | `menuList → children` (PB2 compat) |
| `arg1` | `value` | `arg1 → value` |
| `font` | `value` | `font → value` |
| `name` | `value` | `name → value` if `path` is also present |
| `func` | `onClick` | `func → onClick` if `onClick` is absent |

Both `children` and `menuList` reference the **same table** after normalization — consumers using either field get the same data.

### NormalizeItems

```lua
Drops:NormalizeItems(items) -- in-place normalization of an item array
```

Calls `CopyItem` on each entry. Used internally by `CreateNestedDropdown` before rendering.

---

## Auto-Width

Dropdown list frames in WoW are sized before their button content is rendered. RGX solves this with a deferred two-pass measurement:

```lua
Drops:ForceWidth(level, minWidth, leftInset, opts)
```

- `level` — 1 = root menu, 2 = first submenu, etc.
- `minWidth` — minimum list frame width
- `leftInset` — left padding offset
- `opts.inlineKeys` — inline button keys to account for
- `opts.compactRight` — reduce right margin
- `opts.countKey` — item count key for sizing

**Implementation:** `ForceWidth` is deferred via `RGX:After(0)`. On the first pass, it measures all button `FontString:GetWidth()` values. On the second pass, it applies the resolved width to the list frame and all buttons.

---

## Inline Buttons

Inline buttons are small action widgets attached to individual dropdown button frames. They persist across re-renders by key.

### AddInlineButton

```lua
Drops:AddInlineButton(buttonFrame, {
    key     = "preview",     -- reuse key (default "inline")
    text    = "▶",           -- button label
    width   = 20,            -- button width
    height  = 16,            -- button height
    tooltip = "Preview",     -- tooltip text on hover
    onClick = function(inlineBtn, buttonFrame) end,
})
```

The inline button is positioned to the right of the dropdown button's text, inset from the right edge.

### HideInlineButtons

```lua
Drops:HideInlineButtons(level, key) -- hide all inline buttons with key at level
```

Call before re-populating a menu level to clear stale inline buttons.

---

## Helpers

```lua
Drops:GetListFrame(level)           -- returns _G["DropDownList"..level]
Drops:ShortenLabel(text, maxChars)  -- truncate with "..." ellipsis
Drops:NormalizeItems(items)         -- normalize item list in place
```

---

## Font Dropdown Integration

`CreateFontDropdown` (in the Fonts module) delegates to `Drops:CreateNestedDropdown` with font-specific item data from `BuildGroupedFontItems`:

```lua
-- modules/fonts/dropdowns.lua
function Fonts:CreateFontDropdown(parent, opts)
    local function buildItems()
        return Fonts:BuildGroupedFontItems({ keepShownOnClick = true })
    end

    return Drops:CreateNestedDropdown(parent, {
        label   = opts.label,
        width   = opts.width or 200,
        value   = opts.value,
        items   = buildItems(),
        onChange = function(value, item)
            -- resolve font name from value, call opts.onChange
        end,
    })
end
```

Selection is handled by the `onChange` callback on the `CreateNestedDropdown` holder — not by passing `onSelect` through `buildItems`. This keeps the font dropdown's callback path consistent with all other RGX dropdowns.

---

## Dual-Schema Design

RGX dropdown items carry both legacy and modern callback fields:

- **`func`** — called by WoW's `UIDropDownMenu` dispatch when a button is clicked (legacy path, used by PB2)
- **`onClick`** — called by WoW's `MenuUtil` modular system (modern path, used by RGX)

Both are set to the same closure so either dispatch path produces the same behavior.

Similarly, submenu data is carried in both:

- **`children`** — read by RGX's `NormalizeItems` and `CreateNestedDropdown`
- **`menuList`** — read by PB2's `CreateMenuInfo` system

After `CopyItem` / `NormalizeItems`, both fields reference the same table.

---

## File Layout

```
modules/dropdowns/
└── dropdowns.lua   — CreateNestedDropdown, CopyItem, NormalizeItems, ForceWidth, AddInlineButton, HideInlineButtons, GetListFrame, ShortenLabel
```
