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

-- WoW measures buttons as listFrame:GetWidth() - (BORDER * 2)
local BORDER_THICKNESS = UIDROPDOWNMENU_BORDER_THICKNESS or 15
local BORDER_PAD       = BORDER_THICKNESS * 2

--[[============================================================================
    ITEM NORMALIZATION
============================================================================]]

local function CopyItem(item)
    if type(item) ~= "table" then return nil end
    local copy = {}
    for k, v in pairs(item) do
        if k == "children" and type(v) == "table" then
            local children = {}
            for i, child in ipairs(v) do children[i] = CopyItem(child) end
            copy.children = children
        else
            copy[k] = v
        end
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
]]
function Dropdowns:CreateNestedDropdown(parent, opts)
    opts = opts or {}
    parent = parent or UIParent

    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(opts.width or 260, opts.height or 56)

    holder.label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    holder.label:SetPoint("TOPLEFT", 0, 0)
    holder.label:SetText(opts.label or "Select")

    holder.value = opts.value

    holder.dropdown = CreateFrame("Frame", nil, holder, "UIDropDownMenuTemplate")
    holder.dropdown:SetPoint("TOPLEFT", holder.label, "BOTTOMLEFT", -18, -2)
    UIDropDownMenu_SetWidth(holder.dropdown, opts.buttonWidth or 210)

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
        UIDropDownMenu_SetText(self.dropdown, self:GetValueText(self.value))
        if type(opts.onChange) == "function" then
            opts.onChange(item.value, item, self)
        end
        if not item.keepOpen then
            CloseDropDownMenus()
        end
    end

    local autoW = opts.autoWidth

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
                info.menuList      = item.children
                info.disabled      = item.disabled
                info.tooltipTitle  = item.tooltipTitle
                info.tooltipText   = item.tooltipText
                if item.icon       then info.icon = item.icon end
                if item.colorCode  then info.colorCode = item.colorCode end
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

    UIDropDownMenu_Initialize(holder.dropdown, function(_, level, menuList)
        level = level or 1
        if level == 1 then
            addItems(holder:GetItems(), level)
        elseif type(menuList) == "table" then
            addItems(menuList, level)
        end
    end)

    function holder:Refresh(value)
        if value ~= nil then self.value = value end
        UIDropDownMenu_SetText(self.dropdown, self:GetValueText(self.value))
    end

    function holder:SetEnabled(enabled)
        local on = enabled ~= false
        self.label:SetAlpha(on and 1 or 0.6)
        UIDropDownMenu_DisableDropDown(self.dropdown)
        if on then UIDropDownMenu_EnableDropDown(self.dropdown) end
        self.dropdown:SetAlpha(on and 1 or 0.45)
    end

    holder:Refresh(holder.value)
    return holder
end

--[[============================================================================
    INITIALIZATION
============================================================================]]

function Dropdowns:Init()
    RGX:RegisterModule("dropdowns", self)
    _G.RGXDropdowns = self
end

Dropdowns:Init()
