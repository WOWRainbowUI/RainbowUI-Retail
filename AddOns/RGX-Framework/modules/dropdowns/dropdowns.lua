--[[
    RGX-Framework - Dropdowns Module

    Generic dropdown helpers for WoW addons. Designed to be a first-class
    dropdown library: nested menus, auto-width, inline buttons, icons,
    separators, and headers — all driven by a simple item table.

    Quick start:
        local Drops = RGX:GetDropdowns()

        -- Simple nested dropdown
        local dd = Drops:CreateNestedDropdown(parent, {
            label = "Choose Sound",
            width = 300,
            items = {
                { text = "Sounds",  children = {
                    { text = "Fanfare",  value = "fanfare"  },
                    { text = "Chime",    value = "chime"    },
                }},
                { isSeparator = true },
                { text = "None", value = "" },
            },
            onChange = function(value, item) print("selected:", value) end,
        })

        -- Inline button per item (e.g. preview/play button)
        local dd = Drops:CreateNestedDropdown(parent, {
            items = sounds,
            onButtonCreated = function(buttonFrame, item)
                local preview = Drops:AddInlineButton(buttonFrame, {
                    text = "▶",
                    width = 34, height = 16,
                    onClick = function() PlaySound(item.soundID) end,
                })
            end,
            autoWidth = { minWidth = 260, leftInset = 10 },
        })

    Utility functions (work on any UIDropDownMenu):
        Drops:ForceWidth(level, minWidth, leftInset, opts)
        Drops:GetListFrame(level)
        Drops:ShortenLabel(text, maxChars)
--]]

local _, Dropdowns = ...
local RGX = _G.RGXFramework

if not RGX then
    error("RGX Dropdowns: RGX-Framework not loaded")
    return
end

Dropdowns.name    = "dropdowns"
Dropdowns.version = "2.0.0"

local _dropdownCounter = 0

-- WoW measures buttons as listFrame:GetWidth() - (BORDER * 2)
local BORDER_THICKNESS = UIDROPDOWNMENU_BORDER_THICKNESS or 15
local BORDER_PAD       = BORDER_THICKNESS * 2

local function EnsureDropDownAPI()
    if type(UIDropDownMenu_Initialize) == "function"
        and type(UIDropDownMenu_AddButton) == "function"
        and type(UIDropDownMenu_CreateInfo) == "function" then
        return true
    end

    local loadAddon = nil
    if C_AddOns and type(C_AddOns.LoadAddOn) == "function" then
        loadAddon = C_AddOns.LoadAddOn
    elseif type(LoadAddOn) == "function" then
        loadAddon = LoadAddOn
    end

    if loadAddon then
        pcall(loadAddon, "Blizzard_UIDropDownMenu")
        pcall(loadAddon, "Blizzard_Deprecated")
    end

    return type(UIDropDownMenu_Initialize) == "function"
        and type(UIDropDownMenu_AddButton) == "function"
        and type(UIDropDownMenu_CreateInfo) == "function"
end

local function SetDropdownText(dropdown, text)
    if RGX and type(RGX.SafeUIDropDownMenu_SetText) == "function" then
        return RGX:SafeUIDropDownMenu_SetText(dropdown, text)
    end
    if type(UIDropDownMenu_SetText) == "function" then
        UIDropDownMenu_SetText(dropdown, text)
        return true
    end
    return false
end

local function InitializeDropdown(dropdown, initializer, displayMode)
    if RGX and type(RGX.SafeUIDropDownMenu_Initialize) == "function" then
        return RGX:SafeUIDropDownMenu_Initialize(dropdown, initializer, displayMode)
    end
    if type(UIDropDownMenu_Initialize) == "function" then
        UIDropDownMenu_Initialize(dropdown, initializer, displayMode)
        return true
    end
    return false
end

local function EnableDropdown(dropdown)
    if RGX and type(RGX.SafeUIDropDownMenu_EnableDropDown) == "function" then
        return RGX:SafeUIDropDownMenu_EnableDropDown(dropdown)
    end
    if type(UIDropDownMenu_EnableDropDown) == "function" then
        UIDropDownMenu_EnableDropDown(dropdown)
        return true
    end
    return false
end

local function DisableDropdown(dropdown)
    if RGX and type(RGX.SafeUIDropDownMenu_DisableDropDown) == "function" then
        return RGX:SafeUIDropDownMenu_DisableDropDown(dropdown)
    end
    if type(UIDropDownMenu_DisableDropDown) == "function" then
        UIDropDownMenu_DisableDropDown(dropdown)
        return true
    end
    return false
end

local function CloseMenus()
    if RGX and type(RGX.SafeCloseDropDownMenus) == "function" then
        return RGX:SafeCloseDropDownMenus()
    end
    if type(CloseDropDownMenus) == "function" then
        CloseDropDownMenus()
        return true
    end
    return false
end

--[[============================================================================
    ITEM NORMALIZATION
============================================================================]]

local function CopyItem(item)
    if type(item) ~= "table" then return nil end

    local copy = {}
    for k, v in pairs(item) do
        if k == "children" and type(v) == "table" then
            local children = {}
            for i, child in ipairs(v) do
                children[i] = CopyItem(child)
            end
            copy.children = children
        else
            copy[k] = v
        end
    end

    -- UIDropDownMenu compatibility layer
    -- Normalize old schema fields to RGXDropdowns schema
    local originalText = copy.text
    local originalValue = copy.value

    copy.text = copy.text or copy.label or copy.name or ""

    -- Handle legacy value fields
    if copy.value == nil then
        if copy.arg1 ~= nil then
            copy.value = copy.arg1
            RGX:Debug("Dropdowns:Normalize", "Converted arg1->value", tostring(copy.arg1))
        elseif copy.font ~= nil then
            copy.value = copy.font
            RGX:Debug("Dropdowns:Normalize", "Converted font->value", tostring(copy.font))
        elseif copy.name ~= nil and copy.path ~= nil then
            copy.value = copy.name
            RGX:Debug("Dropdowns:Normalize", "Converted name->value", tostring(copy.name))
        end
    end

    -- Log normalization if values changed
    if (originalText ~= copy.text or originalValue ~= copy.value) then
        RGX:Debug("Dropdowns:Normalize", "Item text:", tostring(originalText), "->", tostring(copy.text), "value:", tostring(originalValue), "->", tostring(copy.value))
    end

    -- Convert menuList to children
    if copy.menuList then
        copy.children = copy.children or copy.menuList
        copy.menuList = nil
    end

    -- Recursively normalize children
    if type(copy.children) == "table" then
        copy.children = Dropdowns:NormalizeItems(copy.children)
    end

    -- Preserve legacy callback as onClick wrapper
    if copy.func and not copy.onClick then
        local func = copy.func
        copy.onClick = function() func(copy, copy.arg1, copy.arg2, nil) end
    end

    return copy
end

function Dropdowns:NormalizeItems(items)
    if type(items) ~= "table" then return {} end
    local out = {}
    for _, item in ipairs(items) do
        local c = CopyItem(item)
        if c then out[#out + 1] = c end
    end
    return out
end

--[[============================================================================
    LAYOUT UTILITIES (usable on any UIDropDownMenu)
============================================================================]]

--- Get the WoW dropdown list frame for a given menu level.
function Dropdowns:GetListFrame(level)
    return _G["DropDownList" .. (level or 1)]
        or _G["LibDropDownMenu_List" .. (level or 1)]
end

--- Truncate text to maxChars, appending "..." if needed.
function Dropdowns:ShortenLabel(text, maxChars)
    if type(text) ~= "string" then return "", false end
    if #text <= maxChars then return text, false end
    return string.sub(text, 1, maxChars - 3) .. "...", true
end

--[[
    ForceWidth(level, minWidth, leftInset, opts)

    Auto-size a UIDropDownMenu list frame + buttons after WoW renders them.
    Runs deferred via RGX:After(0) so it fires after UIDropDownMenu_AddButton.

    opts:
        inlineKeys  (table of strings) — button field names for inline widgets
                    e.g. { "rgxPreviewBtn", "rgxDeleteBtn" }
        compactRight (bool) — anchor inline buttons just after label text
                    instead of right-aligning them (default false)
        countKey    (string) — field name for a count label widget
]]
function Dropdowns:ForceWidth(level, minWidth, leftInset, opts)
    leftInset = leftInset or 10
    opts = opts or {}
    local inlineKeys     = opts.inlineKeys or {}
    local compactRight   = opts.compactRight == true
    local countKey       = opts.countKey
    local self_ref       = self

    RGX:After(0, function()
        local listFrame = self_ref:GetListFrame(level)
        if not listFrame or not listFrame:IsShown() then return end

        local maxButtons = UIDROPDOWNMENU_MAXBUTTONS or 32

        -- Pass 1: measure widest content needed
        local neededContent = (minWidth or 200) - BORDER_PAD
        local visible = 0
        for i = 1, maxButtons do
            local btn = _G[listFrame:GetName() .. "Button" .. i]
            if btn and btn:IsShown() then
                visible = visible + 1
                local nt          = _G[btn:GetName() .. "NormalText"]
                local expandArrow = _G[btn:GetName() .. "ExpandArrow"]
                local tw          = nt and math.ceil(nt:GetStringWidth() or 0) or 0
                local countLabel  = countKey and btn[countKey]
                local cw          = (countLabel and countLabel:IsShown())
                                    and math.ceil(countLabel:GetStringWidth() or 0) or 0
                local hasArrow    = expandArrow and expandArrow:IsShown()

                -- measure rightmost inline widget
                local inlineW = 0
                for _, key in ipairs(inlineKeys) do
                    if btn[key] and btn[key]:IsShown() then
                        inlineW = math.max(inlineW, btn[key]:GetWidth() or 0)
                    end
                end

                local rightRes = inlineW > 0 and (inlineW + 8)
                    or (hasArrow and 14 or 6) + (cw > 0 and (cw + 6) or 0)
                neededContent = math.max(neededContent, leftInset + tw + rightRes)
            end
        end

        if visible == 0 then return end

        -- Pass 2: apply widths and re-anchor
        local btnWidth   = neededContent
        local frameWidth = neededContent + BORDER_PAD
        listFrame:SetWidth(frameWidth)

        for i = 1, maxButtons do
            local btn = _G[listFrame:GetName() .. "Button" .. i]
            if btn and btn:IsShown() then
                btn:SetWidth(btnWidth)
                local nt          = _G[btn:GetName() .. "NormalText"]
                local expandArrow = _G[btn:GetName() .. "ExpandArrow"]
                local countLabel  = countKey and btn[countKey]
                local hasArrow    = expandArrow and expandArrow:IsShown()
                local hasCount    = countLabel and countLabel:IsShown()

                -- Find rightmost visible inline widget
                local inlineBtn = nil
                for _, key in ipairs(inlineKeys) do
                    if btn[key] and btn[key]:IsShown() then
                        inlineBtn = btn[key]
                        break
                    end
                end

                if inlineBtn then
                    if compactRight and nt then
                        local tw = math.ceil(nt:GetStringWidth() or 0)
                        inlineBtn:ClearAllPoints()
                        inlineBtn:SetPoint("LEFT", btn, "LEFT", leftInset + tw + 4, 0)
                    else
                        inlineBtn:ClearAllPoints()
                        inlineBtn:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
                    end
                end

                if nt then
                    nt:ClearAllPoints()
                    nt:SetPoint("LEFT", btn, "LEFT", leftInset, 0)
                    nt:SetJustifyH("LEFT")
                    if hasCount and countLabel then
                        if hasArrow and expandArrow then
                            expandArrow:ClearAllPoints()
                            expandArrow:SetPoint("RIGHT", btn, "RIGHT", -3, 0)
                            countLabel:ClearAllPoints()
                            countLabel:SetPoint("RIGHT", expandArrow, "LEFT", -4, 0)
                        else
                            countLabel:ClearAllPoints()
                            countLabel:SetPoint("RIGHT", btn, "RIGHT", -6, 0)
                        end
                        nt:SetPoint("RIGHT", countLabel, "LEFT", -6, 0)
                    elseif not inlineBtn and not compactRight then
                        nt:SetPoint("RIGHT", btn, "RIGHT", hasArrow and -16 or -6, 0)
                    end
                end

                if expandArrow and not hasCount and not inlineBtn then
                    expandArrow:ClearAllPoints()
                    expandArrow:SetPoint("RIGHT", btn, "RIGHT", -3, 0)
                end
            end
        end
    end)
end

--[[============================================================================
    INLINE BUTTON HELPER
============================================================================]]

--[[
    AddInlineButton(buttonFrame, opts) -> Button

    Attaches a small inline button to an existing UIDropDownMenu button frame.
    The button persists across re-renders of the same menu slot — call Show()
    after each UIDropDownMenu_AddButton call that should show it, and Hide() on
    slots that should not.

    opts:
        key      (string)   — field name on buttonFrame (default "rgxInlineBtn")
        text     (string)   — button label
        width    (number)   — default 34
        height   (number)   — default 16
        onClick  (function) — called with (buttonFrame) on click
        tooltip  (string)   — GameTooltip text
]]
function Dropdowns:AddInlineButton(buttonFrame, opts)
    opts = opts or {}
    local key     = opts.key or "rgxInlineBtn"
    local existing = buttonFrame[key]

    if not existing then
        existing = CreateFrame("Button", nil, buttonFrame, "BackdropTemplate")
        existing:SetSize(opts.width or 34, opts.height or 16)
        existing:SetBackdrop({
            bgFile   = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            tile = false, edgeSize = 1,
            insets = {left=0, right=0, top=0, bottom=0}
        })
        existing:SetBackdropColor(0.08, 0.10, 0.13, 0.95)
        existing:SetBackdropBorderColor(0.14, 0.20, 0.28, 1)

        local lbl = existing:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetAllPoints()
        lbl:SetJustifyH("CENTER")
        existing.label = lbl

        existing:SetScript("OnLeave", function() GameTooltip:Hide() end)
        buttonFrame[key] = existing
    end

    -- Update per-call properties
    existing.label:SetText(opts.text or "")
    if opts.width  then existing:SetSize(opts.width,  existing:GetHeight()) end
    if opts.height then existing:SetSize(existing:GetWidth(), opts.height)  end

    existing:SetScript("OnClick", function()
        if type(opts.onClick) == "function" then opts.onClick(buttonFrame) end
    end)

    if opts.tooltip then
        existing:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(opts.tooltip)
            GameTooltip:Show()
        end)
    else
        existing:SetScript("OnEnter", nil)
    end

    existing:Show()
    return existing
end

--- Hide all inline buttons with the given key on every visible slot.
function Dropdowns:HideInlineButtons(level, key)
    key = key or "rgxInlineBtn"
    local listFrame = self:GetListFrame(level)
    if not listFrame then return end
    local maxButtons = UIDROPDOWNMENU_MAXBUTTONS or 32
    for i = 1, maxButtons do
        local btn = _G[listFrame:GetName() .. "Button" .. i]
        if btn and btn[key] then btn[key]:Hide() end
    end
end

--[[============================================================================
    NESTED DROPDOWN WIDGET
============================================================================]]

--[[
    CreateNestedDropdown(parent, opts) -> holder

    opts:
        label           (string)
        width           (number)           — holder frame width
        buttonWidth     (number)           — UIDropDownMenu inner button width
        value           (any)              — initially selected value
        placeholder     (string)           — text when nothing selected
        items           (table|function)   — flat or nested item list, or fn(holder)
        onChange        (fn(value, item, holder))
        getItemText     (fn(item, value, holder)) -> string
        getValueText    (fn(value, holder)) -> string
        isItemChecked   (fn(item, value, holder)) -> bool
        onButtonCreated (fn(buttonFrame, item)) — called after each AddButton for
                        leaf items; use Drops:AddInlineButton here
        autoWidth       (table)            — { minWidth, leftInset, opts }
                        triggers ForceWidth on each open

    Item fields:
        text        (string)
        value       (any)
        label       (string)   — alias for text
        children    (table)    — sub-items (triggers nested sub-menu)
        icon        (string)   — texture path shown as left icon
        colorCode   (string)   — WoW color escape, e.g. "|cFF00FF00"
        isSeparator (bool)     — horizontal divider (no value, not selectable)
        isHeader    (bool)     — styled category label (bold, not checkable)
        disabled    (bool)
        notCheckable(bool)
        tooltipTitle(string)
        tooltipText (string)
        keepOpen    (bool)     — don't CloseDropDownMenus on select
        keepShownOnClick(bool) — UIDropDownMenu-compatible alias for keepOpen
]]
-- ─────────────────────────────────────────────────────────────────────────────
-- MenuUtil path (TWW / Midnight 12.x).
--
-- Blizzard removed Blizzard_UIDropDownMenu in 11.0; what remains is a deprecation
-- shim that taints any insecure code path that touches it, producing
-- "ADDON FORBIDDEN" errors when our dropdowns are opened next to secure UI.
-- Modern clients use MenuUtil + WowStyle1ArrowDropdownTemplate, which has no
-- such taint surface. We dispatch to this path when MenuUtil is available and
-- fall back to the legacy implementation for Classic Era / Cata Classic /
-- MoP Classic where MenuUtil does not exist.
-- ─────────────────────────────────────────────────────────────────────────────

local function HasMenuUtil()
    return _G.MenuUtil ~= nil and type(_G.MenuUtil.CreateContextMenu) == "function"
end

local _hasModernDropdownTemplate = nil
local function HasModernDropdownTemplate()
    -- WowStyle1ArrowDropdownTemplate is the new selection dropdown widget.
    -- We can probe its existence by trying to create one; the template is
    -- registered globally as soon as UIParent loads on a TWW+ client.
    if _hasModernDropdownTemplate ~= nil then
        return _hasModernDropdownTemplate
    end
    if not HasMenuUtil() then return false end
    local probe = pcall(CreateFrame, "DropdownButton", nil, UIParent, "WowStyle1ArrowDropdownTemplate")
    _hasModernDropdownTemplate = probe == true
    return _hasModernDropdownTemplate
end

function Dropdowns:CreateNestedDropdown_MenuUtil(parent, opts)
    opts = opts or {}
    parent = parent or UIParent

    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(opts.width or 260, opts.height or 56)

    holder.label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    holder.label:SetPoint("TOPLEFT", 0, 0)
    holder.label:SetText(opts.label or "Select")

    holder.value = opts.value

    _dropdownCounter = _dropdownCounter + 1
    holder.dropdown = CreateFrame("DropdownButton", "RGXDropdown_" .. _dropdownCounter, holder, "WowStyle1ArrowDropdownTemplate")
    holder.dropdown:SetPoint("TOPLEFT", holder.label, "BOTTOMLEFT", 0, -2)
    holder.dropdown:SetWidth(opts.buttonWidth or 210)
    if type(holder.dropdown.SetDefaultText) == "function" then
        holder.dropdown:SetDefaultText(opts.placeholder or "Select")
    end

    -- Item helpers (same names/shapes as the legacy path so the holder is
    -- API-compatible with Fonts:CreateFontDropdown and similar callers).
    function holder:GetItems()
        if type(opts.items) == "function" then
            return Dropdowns:NormalizeItems(opts.items(self))
        end
        return Dropdowns:NormalizeItems(opts.items)
    end

    function holder:GetItemText(item)
        if type(opts.getItemText) == "function" then
            return opts.getItemText(item, self.value, self) or ""
        end
        return item and (item.text or item.label or tostring(item.value or "")) or ""
    end

    function holder:GetValueText(value)
        if type(opts.getValueText) == "function" then
            return opts.getValueText(value, self) or ""
        end
        local function findText(items)
            for _, item in ipairs(items) do
                if item.value == value then return self:GetItemText(item) end
                if type(item.children) == "table" then
                    local n = findText(item.children)
                    if n then return n end
                end
            end
        end
        return findText(self:GetItems()) or opts.placeholder or "Select"
    end

    -- Locate an item by value across the (possibly nested) tree, so onChange
    -- can receive the same `(value, item, holder)` arguments as the legacy
    -- dropdown — callers like Fonts and PB2 rely on the item being passed.
    local function FindItemByValue(items, target)
        for _, item in ipairs(items or {}) do
            if item.value == target then return item end
            if type(item.children) == "table" then
                local found = FindItemByValue(item.children, target)
                if found then return found end
            end
        end
        return nil
    end

    -- Generator runs every time the menu opens, so radio "checked" state
    -- always reflects the current holder.value.
	local _genCalledOnce = false
	local function generator(_, rootDescription)
		if not _genCalledOnce then
			_genCalledOnce = true
			local items = holder:GetItems()
			local leafCount, groupCount = 0, 0
			for _, it in ipairs(items or {}) do
				if type(it.children) == "table" and #it.children > 0 then groupCount = groupCount + 1 else leafCount = leafCount + 1 end
			end
			RGX:Debug("RGXDropdown:generator first call, items=" .. #items .. " groups=" .. groupCount .. " leafs=" .. leafCount)
		end
		local function isSelected(value) return holder.value == value end
        local function setSelected(value)
            holder.value = value
            local item = FindItemByValue(holder:GetItems(), value)
            if type(opts.onChange) == "function" then
                opts.onChange(value, item, holder)
            end
        end

        local function addItems(items, parentDesc)
            for _, item in ipairs(items or {}) do
                if item.isSeparator then
                    parentDesc:CreateDivider()
                elseif item.isHeader then
                    parentDesc:CreateTitle(holder:GetItemText(item))
                elseif type(item.children) == "table" and #item.children > 0 then
                    -- Submenu: a button whose own description we add children to.
                    local sub = parentDesc:CreateButton(holder:GetItemText(item))
                    addItems(item.children, sub)
                else
                    -- Leaf. Selectable items (with a value, not flagged
                    -- notCheckable) become radios; everything else becomes a
                    -- plain button that fires onChange like the legacy path.
                    if item.value ~= nil and item.notCheckable ~= true then
                        parentDesc:CreateRadio(holder:GetItemText(item), isSelected, setSelected, item.value)
                    else
                        local label = holder:GetItemText(item)
                        parentDesc:CreateButton(label, function()
                            if type(opts.onChange) == "function" then
                                opts.onChange(item.value, item, holder)
                            end
                        end)
                    end
                end
            end
        end

        addItems(holder:GetItems(), rootDescription)
    end

    holder.dropdown:SetupMenu(generator)

    function holder:Refresh(value)
        if value ~= nil then self.value = value end
        local text = self:GetValueText(self.value)
        -- OverrideText pins the displayed label regardless of which radio is
        -- currently selected; useful for getValueText callers (e.g. fonts)
        -- that format the displayed label differently from the menu items.
        if type(self.dropdown.OverrideText) == "function" and type(opts.getValueText) == "function" then
            self.dropdown:OverrideText(text)
        end
    end

    function holder:SetEnabled(enabled)
        local on = enabled ~= false
        self.label:SetAlpha(on and 1 or 0.6)
        if type(self.dropdown.SetEnabled) == "function" then
            self.dropdown:SetEnabled(on)
        end
        self.dropdown:SetAlpha(on and 1 or 0.45)
    end

    holder:Refresh(holder.value)
    return holder
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Legacy UIDropDownMenu path (Classic Era / Cata Classic / MoP Classic).
-- Used as a fallback when MenuUtil is unavailable.
-- ─────────────────────────────────────────────────────────────────────────────

function Dropdowns:CreateNestedDropdown_Legacy(parent, opts)
    opts = opts or {}
    parent = parent or UIParent

    if not EnsureDropDownAPI() then
        RGX:Debug("RGXDropdowns: UIDropDownMenu API unavailable")
        return nil
    end

    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(opts.width or 260, opts.height or 56)

    holder.label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    holder.label:SetPoint("TOPLEFT", 0, 0)
    holder.label:SetText(opts.label or "Select")

    holder.value = opts.value

    _dropdownCounter = _dropdownCounter + 1
    holder.dropdown = CreateFrame("Frame", "RGXDropdown_" .. _dropdownCounter, holder, "UIDropDownMenuTemplate")
    holder.dropdown:SetPoint("TOPLEFT", holder.label, "BOTTOMLEFT", -18, -2)
    if type(UIDropDownMenu_SetWidth) == "function" then
        UIDropDownMenu_SetWidth(holder.dropdown, opts.buttonWidth or 210)
    elseif holder.dropdown.SetWidth then
        holder.dropdown:SetWidth((opts.buttonWidth or 210) + 40)
    end

    -- Item helpers
    function holder:GetItems()
        if type(opts.items) == "function" then
            return Dropdowns:NormalizeItems(opts.items(self))
        end
        return Dropdowns:NormalizeItems(opts.items)
    end

    function holder:GetItemText(item)
        if type(opts.getItemText) == "function" then
            return opts.getItemText(item, self.value, self) or ""
        end
        return item and (item.text or item.label or tostring(item.value or "")) or ""
    end

    function holder:GetValueText(value)
        if type(opts.getValueText) == "function" then
            return opts.getValueText(value, self) or ""
        end
        local function findText(items)
            for _, item in ipairs(items) do
                if item.value == value then return self:GetItemText(item) end
                if type(item.children) == "table" then
                    local n = findText(item.children)
                    if n then return n end
                end
            end
        end
        return findText(self:GetItems()) or opts.placeholder or "Select"
    end

    function holder:IsItemChecked(item)
        if type(opts.isItemChecked) == "function" then
            return opts.isItemChecked(item, self.value, self) == true
        end
        return item and item.value == self.value
    end

    function holder:Select(item)
        if not item then return end
        self.value = item.value
        SetDropdownText(self.dropdown, self:GetValueText(self.value))
        if type(opts.onChange) == "function" then
            opts.onChange(item.value, item, self)
        end
        if not item.keepOpen and not item.keepShownOnClick then
            CloseMenus()
        end
    end

    local autoW = opts.autoWidth

    -- String-key registry for sub-menu children (TWW UIDropDownMenu compat:
    -- table references in menuList may not survive the callback round-trip).
    holder._menuData = {}
    local menuKeyCounter = 0

    local function addItems(items, level)
        for _, item in ipairs(items or {}) do
            local info = UIDropDownMenu_CreateInfo()

            -- Separator
            if item.isSeparator then
                info.isSeparator   = true
                info.notCheckable  = true
                info.disabled      = true
                UIDropDownMenu_AddButton(info, level)
                -- no onButtonCreated for separators

            -- Header
            elseif item.isHeader then
                info.isTitle       = true
                info.text          = holder:GetItemText(item)
                info.notCheckable  = true
                info.disabled      = true
                UIDropDownMenu_AddButton(info, level)

            -- Sub-menu group
            elseif type(item.children) == "table" and #item.children > 0 then
                info.text          = holder:GetItemText(item)
                info.notCheckable  = item.notCheckable ~= false
                info.hasArrow      = true
                info.disabled      = item.disabled
                info.tooltipTitle  = item.tooltipTitle
                info.tooltipText   = item.tooltipText
                if item.icon       then info.icon = item.icon end
                if item.colorCode  then info.colorCode = item.colorCode end
                menuKeyCounter = menuKeyCounter + 1
                local key = "m" .. menuKeyCounter
                holder._menuData[key] = item.children
                info.menuList = key
                UIDropDownMenu_AddButton(info, level)

            -- Leaf item
            else
                info.text          = holder:GetItemText(item)
                info.notCheckable  = item.notCheckable
                if info.notCheckable == nil then
                    info.notCheckable = item.value == nil
                end
                if not info.notCheckable then
                    info.checked = holder:IsItemChecked(item)
                end
                info.disabled      = item.disabled
                info.tooltipTitle  = item.tooltipTitle
                info.tooltipText   = item.tooltipText
                if item.icon       then info.icon = item.icon end
                if item.colorCode  then info.colorCode = item.colorCode end
                info.func = function()
                    holder:Select(item)
                end
                info.keepShownOnClick = item.keepShownOnClick or item.keepOpen
                UIDropDownMenu_AddButton(info, level)

                -- Let the caller attach inline buttons
                if type(opts.onButtonCreated) == "function" then
                    local listFrame = Dropdowns:GetListFrame(level)
                    if listFrame then
                        local maxButtons = UIDROPDOWNMENU_MAXBUTTONS or 32
                        for i = maxButtons, 1, -1 do
                            local btn = _G[listFrame:GetName() .. "Button" .. i]
                            if btn and btn:IsShown() then
                                opts.onButtonCreated(btn, item)
                                break
                            end
                        end
                    end
                end
            end
        end

        -- Auto-width after all items added at this level
        if autoW then
            Dropdowns:ForceWidth(level,
                autoW.minWidth  or 200,
                autoW.leftInset or 10,
                autoW.opts)
        end
    end

    InitializeDropdown(holder.dropdown, function(_, level, menuList)
        level = level or 1
        if level == 1 then
            -- Rebuild data registry fresh on every open (BLU pattern).
            -- Prevents stale key accumulation and ensures TWW compat.
            holder._menuData = {}
            menuKeyCounter = 0
            addItems(holder:GetItems(), level)
        else
            local children = type(menuList) == "table" and menuList
                or (holder._menuData and holder._menuData[menuList])
            if type(children) == "table" then
                addItems(children, level)
            end
        end
    end)

    function holder:Refresh(value)
        if value ~= nil then self.value = value end
        SetDropdownText(self.dropdown, self:GetValueText(self.value))
    end

    function holder:SetEnabled(enabled)
        local on = enabled ~= false
        self.label:SetAlpha(on and 1 or 0.6)
        DisableDropdown(self.dropdown)
        if on then EnableDropdown(self.dropdown) end
        self.dropdown:SetAlpha(on and 1 or 0.45)
    end

    holder:Refresh(holder.value)
    return holder
end

function Dropdowns:CreateNestedDropdown(parent, opts)
	if HasModernDropdownTemplate() then
		RGX:Debug("RGXDropdown: dispatching to MenuUtil path")
		return self:CreateNestedDropdown_MenuUtil(parent, opts)
	end
	RGX:Debug("RGXDropdown: dispatching to Legacy path")
	return self:CreateNestedDropdown_Legacy(parent, opts)
end

--[[============================================================================
    INITIALIZATION
============================================================================]]

function Dropdowns:Init()
    RGX:RegisterModule("dropdowns", self)
    _G.RGXDropdowns = self
end

Dropdowns:Init()
