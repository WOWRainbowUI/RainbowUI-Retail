-- Copyright (c) 2026 BliZzi1337. All rights reserved.
-- Unauthorized copying, modification, distribution or use of this
-- software, in whole or in part, without prior written permission
-- from the copyright holder is strictly prohibited.
--[[
    Config.lua - BliZzi_Interrupts
    Single-page Blizzard Settings UI with collapsible sections (Blizzard expandable-section API).
    Custom templates (Config.xml):
      BITSliderEditTemplate — native slider + EditBox for direct px input
]]

BIT        = BIT or {}
BIT.Config = BIT.Config or {}

local mainCatRef = nil

-- Safe locale lookup
local function LL(key, fallback)
    return rawget(BIT.L, key) or fallback or key
end

------------------------------------------------------------
-- Mixin: Slider + EditBox (used by BITSliderEditTemplate in Config.xml)
------------------------------------------------------------
BITSliderEditMixin = {}

function BITSliderEditMixin:Init(initializer)
    SettingsSliderControlMixin.Init(self, initializer)

    local eb = self.EditBox
    if not eb then return end

    eb:SetMaxLetters(5)

    local incBtn = self.SliderWithSteppers and self.SliderWithSteppers.IncrementButton
    eb:ClearAllPoints()
    if incBtn then
        eb:SetPoint("LEFT", incBtn, "RIGHT", 6, 0)
    else
        eb:SetPoint("RIGHT", self, "RIGHT", -8, 0)
    end

    local setting = initializer:GetSetting()
    local options = initializer:GetOptions()
    local minV  = options.minValue
    local maxV  = options.maxValue
    local steps = options.steps or 0
    local step  = (steps > 0) and ((maxV - minV) / steps) or 1

    local function Sync()
        local v = setting:GetValue()
        eb:SetText(tostring(v))
        eb:SetCursorPosition(0)
    end
    Sync()

    eb:SetScript("OnEnterPressed", function(self2)
        local raw = tonumber(self2:GetText())
        if raw then
            local clamped = math.max(minV, math.min(maxV,
                math.floor(raw / step + 0.5) * step))
            setting:SetValue(clamped)
        end
        Sync()
        self2:ClearFocus()
    end)
    eb:SetScript("OnEscapePressed", function(self2)
        Sync()
        self2:ClearFocus()
    end)

    setting:SetValueChangedCallback(function() Sync() end)
end

------------------------------------------------------------
-- Helper: native slider with EditBox (returns initializer)
------------------------------------------------------------
local function MakeSliderEdit(cat, varKey, name, default,
                               minV, maxV, step, fmtFn,
                               getVal, setVal, tooltip)
    local setting = Settings.RegisterProxySetting(cat, varKey,
        Settings.VarType.Number, name, default, getVal, setVal)
    local opts = Settings.CreateSliderOptions(minV, maxV, step)
    if fmtFn then
        opts:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, fmtFn)
    end
    local initializer = Settings.CreateControlInitializer(
        "BITSliderEditTemplate", setting, opts, tooltip)
    local layout = SettingsPanel:GetLayout(cat)
    layout:AddInitializer(initializer)
    return initializer
end

------------------------------------------------------------
-- Helper: plain native checkbox (returns initializer)
------------------------------------------------------------
local function MakeCheckbox(cat, varKey, name, getVal, setVal, tooltip)
    local setting = Settings.RegisterProxySetting(cat, varKey,
        Settings.VarType.Boolean, name, false, getVal, setVal)
    local init = Settings.CreateCheckbox(cat, setting, tooltip)
    return init
end

------------------------------------------------------------
-- Helper: plain native slider (returns initializer)
------------------------------------------------------------
local function MakeSlider(cat, varKey, name, default,
                           minV, maxV, step, fmtFn,
                           getVal, setVal, tooltip)
    local setting = Settings.RegisterProxySetting(cat, varKey,
        Settings.VarType.Number, name, default, getVal, setVal)
    local opts = Settings.CreateSliderOptions(minV, maxV, step)
    if fmtFn then
        opts:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, fmtFn)
    end
    local init = Settings.CreateSlider(cat, setting, opts, tooltip)
    return init
end

------------------------------------------------------------
-- Helper: plain native dropdown (returns initializer)
------------------------------------------------------------
local function MakeDropdown(cat, varKey, name, default, getVal, setVal, optsFn, tooltip)
    local setting = Settings.RegisterProxySetting(cat, varKey,
        Settings.VarType.String, name, default, getVal, setVal)
    local init = Settings.CreateDropdown(cat, setting, optsFn, tooltip)
    return init
end

------------------------------------------------------------
-- Helper: info line (SettingsListSectionHeaderTemplate, returns initializer)
------------------------------------------------------------
local function AddInfo(layout, text)
    local init = Settings.CreateElementInitializer(
        "SettingsListSectionHeaderTemplate", { name = text })
    layout:AddInitializer(init)
    return init
end

------------------------------------------------------------
-- Helper: collapsible section (Blizzard expandable-section API)
-- Adds section header to layout; returns sectionInit.
-- Children must call InSection(sectionInit, childInit).
------------------------------------------------------------
local function CreateSection(layout, label, stateKey, defaultExpanded)
    local sectionInit
    if type(CreateSettingsExpandableSectionInitializer) == "function" then
        sectionInit = CreateSettingsExpandableSectionInitializer(label)
    else
        sectionInit = Settings.CreateElementInitializer(
            "SettingsExpandableSectionTemplate", { name = label })
    end

    -- Restore persisted expanded state; fall back to defaultExpanded
    local savedExp
    if BIT.db.sectionExpanded and BIT.db.sectionExpanded[stateKey] ~= nil then
        savedExp = BIT.db.sectionExpanded[stateKey]
    else
        savedExp = (defaultExpanded ~= false)
    end
    sectionInit.data.expanded = savedExp

    -- Methods required by the framework (not set by default)
    function sectionInit:IsExpanded()
        return self.data and self.data.expanded ~= false
    end
    function sectionInit:GetExtent()
        return 25
    end

    local origInitFrame = sectionInit.InitFrame
    function sectionInit:InitFrame(frame)
        origInitFrame(self, frame)
        frame.CalculateHeight = function(f)
            return f:GetElementData():GetExtent()
        end
        frame.OnExpandedChanged = function(f)
            if not BIT.db.sectionExpanded then BIT.db.sectionExpanded = {} end
            BIT.db.sectionExpanded[stateKey] = f:GetElementData():IsExpanded()
            if SettingsPanel and SettingsPanel.RepairDisplay then
                SettingsPanel:RepairDisplay()
            end
        end
    end

    layout:AddInitializer(sectionInit)
    return sectionInit
end

------------------------------------------------------------
-- Helper: mark an initializer as a child of a section.
-- The child is hidden whenever the section is collapsed.
------------------------------------------------------------
local function InSection(sectionInit, init)
    if init and init.AddShownPredicate then
        init:AddShownPredicate(function()
            return sectionInit:IsExpanded()
        end)
    end
end

------------------------------------------------------------
-- Page: Colors (own sidebar entry, collapsible sub-sections)
------------------------------------------------------------
local function BuildPageColors(cat)
    local L      = BIT.L
    local layout = SettingsPanel:GetLayout(cat)

    -- ── Title Bar Color ───────────────────────────────────────────────
    local titleColSect = CreateSection(layout, L["SEC_TITLE_COLOR"] or "Title Bar Color", "col_title", true)
    InSection(titleColSect, MakeSlider(cat, "BIT_titleR", L["COLOR_RED"]   or "Red",   0,   0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.titleColorR or 0)     * 255 + 0.5) end,
        function(v) BIT.db.titleColorR = v / 255; BIT.UI:RebuildBars() end))
    InSection(titleColSect, MakeSlider(cat, "BIT_titleG", L["COLOR_GREEN"] or "Green", 221, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.titleColorG or 0.867) * 255 + 0.5) end,
        function(v) BIT.db.titleColorG = v / 255; BIT.UI:RebuildBars() end))
    InSection(titleColSect, MakeSlider(cat, "BIT_titleB", L["COLOR_BLUE"]  or "Blue",  221, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.titleColorB or 0.867) * 255 + 0.5) end,
        function(v) BIT.db.titleColorB = v / 255; BIT.UI:RebuildBars() end))

    -- ── Bar Color ─────────────────────────────────────────────────────
    local barColSect = CreateSection(layout, L["SEC_BAR_COLOR"] or "Bar Color", "col_bar", true)
    InSection(barColSect, MakeSlider(cat, "BIT_barR", L["COLOR_RED"]   or "Red",   102, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.customColorR or 0.4) * 255 + 0.5) end,
        function(v) BIT.db.customColorR = v / 255; BIT.UI:UpdateDisplay(); if BIT.SyncCD and BIT.SyncCD.UpdateColors then BIT.SyncCD:UpdateColors() end end))
    InSection(barColSect, MakeSlider(cat, "BIT_barG", L["COLOR_GREEN"] or "Green", 204, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.customColorG or 0.8) * 255 + 0.5) end,
        function(v) BIT.db.customColorG = v / 255; BIT.UI:UpdateDisplay(); if BIT.SyncCD and BIT.SyncCD.UpdateColors then BIT.SyncCD:UpdateColors() end end))
    InSection(barColSect, MakeSlider(cat, "BIT_barB", L["COLOR_BLUE"]  or "Blue",  255, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.customColorB or 1.0) * 255 + 0.5) end,
        function(v) BIT.db.customColorB = v / 255; BIT.UI:UpdateDisplay(); if BIT.SyncCD and BIT.SyncCD.UpdateColors then BIT.SyncCD:UpdateColors() end end))

    -- ── Background Color ──────────────────────────────────────────────
    local bgColSect = CreateSection(layout, L["SEC_BG_COLOR"] or "Background Color", "col_bg", true)
    InSection(bgColSect, MakeSlider(cat, "BIT_bgR", L["COLOR_RED"]   or "Red",   26, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.customBgColorR or 0.1) * 255 + 0.5) end,
        function(v) BIT.db.customBgColorR = v / 255; BIT.UI:UpdateDisplay(); if BIT.SyncCD and BIT.SyncCD.UpdateColors then BIT.SyncCD:UpdateColors() end end))
    InSection(bgColSect, MakeSlider(cat, "BIT_bgG", L["COLOR_GREEN"] or "Green", 26, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.customBgColorG or 0.1) * 255 + 0.5) end,
        function(v) BIT.db.customBgColorG = v / 255; BIT.UI:UpdateDisplay(); if BIT.SyncCD and BIT.SyncCD.UpdateColors then BIT.SyncCD:UpdateColors() end end))
    InSection(bgColSect, MakeSlider(cat, "BIT_bgB", L["COLOR_BLUE"]  or "Blue",  26, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.customBgColorB or 0.1) * 255 + 0.5) end,
        function(v) BIT.db.customBgColorB = v / 255; BIT.UI:UpdateDisplay(); if BIT.SyncCD and BIT.SyncCD.UpdateColors then BIT.SyncCD:UpdateColors() end end))

    -- ── Border Color ──────────────────────────────────────────────────
    local borColSect = CreateSection(layout, L["SEC_BORDER_COLOR"] or "Border Color", "col_border", true)
    InSection(borColSect, MakeSlider(cat, "BIT_borR", L["COLOR_RED"]   or "Red",   0, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.borderColorR or 0) * 255 + 0.5) end,
        function(v) BIT.db.borderColorR = v / 255; BIT.UI:ApplyBorderToAll(); if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end end))
    InSection(borColSect, MakeSlider(cat, "BIT_borG", L["COLOR_GREEN"] or "Green", 0, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.borderColorG or 0) * 255 + 0.5) end,
        function(v) BIT.db.borderColorG = v / 255; BIT.UI:ApplyBorderToAll(); if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end end))
    InSection(borColSect, MakeSlider(cat, "BIT_borB", L["COLOR_BLUE"]  or "Blue",  0, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.borderColorB or 0) * 255 + 0.5) end,
        function(v) BIT.db.borderColorB = v / 255; BIT.UI:ApplyBorderToAll(); if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end end))
    InSection(borColSect, MakeSlider(cat, "BIT_borA", L["SL_BORDER_OPACITY"] or "Opacity", 255, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.borderColorA or 1) * 255 + 0.5) end,
        function(v) BIT.db.borderColorA = v / 255; BIT.UI:ApplyBorderToAll(); if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end end))

    -- ── Ready / CD Color ──────────────────────────────────────────────
    local readyColSect = CreateSection(layout, L["SEC_READY_COLOR"] or "Ready / CD Color", "col_ready", true)
    InSection(readyColSect, MakeSlider(cat, "BIT_readyR", L["COLOR_RED"]   or "Red",   51, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.readyColorR or 0.2) * 255 + 0.5) end,
        function(v) BIT.db.readyColorR = v / 255; BIT.UI:UpdateDisplay(); if BIT.SyncCD and BIT.SyncCD.UpdateColors then BIT.SyncCD:UpdateColors() end end))
    InSection(readyColSect, MakeSlider(cat, "BIT_readyG", L["COLOR_GREEN"] or "Green", 255, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.readyColorG or 1.0) * 255 + 0.5) end,
        function(v) BIT.db.readyColorG = v / 255; BIT.UI:UpdateDisplay(); if BIT.SyncCD and BIT.SyncCD.UpdateColors then BIT.SyncCD:UpdateColors() end end))
    InSection(readyColSect, MakeSlider(cat, "BIT_readyB", L["COLOR_BLUE"]  or "Blue",  51, 0, 255, 1,
        function(v) return tostring(v) end,
        function() return math.floor((BIT.db.readyColorB or 0.2) * 255 + 0.5) end,
        function(v) BIT.db.readyColorB = v / 255; BIT.UI:UpdateDisplay(); if BIT.SyncCD and BIT.SyncCD.UpdateColors then BIT.SyncCD:UpdateColors() end end))
end

------------------------------------------------------------
-- Page: General (own sidebar entry)
------------------------------------------------------------
local function BuildPageGeneral(cat)
    local L      = BIT.L
    local layout = SettingsPanel:GetLayout(cat)

    -- ── Language ─────────────────────────────────────────────────────
    local langSect = CreateSection(layout, L["SEC_LANGUAGE"] or "Language", "gen_language", true)
    InSection(langSect, MakeDropdown(cat, "BIT_language", L["SEC_LANGUAGE"], "auto",
        function() return BIT.db.language or "auto" end,
        function(v) BIT.db.language = v; BIT:ApplyLocale(); print(BIT.L["MSG_LANG_CHANGED"]) end,
        function()
            local c = Settings.CreateControlTextContainer()
            c:Add("auto",   L["LANG_AUTO"])
            c:Add("enUS",   "English")
            c:Add("deDE",   "Deutsch")
            c:Add("frFR",   "Français")
            c:Add("esES",   "Español")
            c:Add("ruRU",   "Русский")
            c:Add("tlhTLH","Klingon")
            return c:GetData()
        end))

    -- ── Custom Names ────────────────────────────────────────────────
    local cnSect = CreateSection(layout, LL("SEC_CUSTOM_NAMES", "Custom Names"), "gen_customNames", true)
    InSection(cnSect, AddInfo(layout,
        "|cFFAAAAAA" .. LL("CUSTOM_NAMES_DESC",
        "Set a custom nickname visible to other addon users. Only affects the addon display.") .. "|r"))
    InSection(cnSect, MakeCheckbox(cat, "BIT_showCustomNames",
        LL("CB_SHOW_CUSTOM_NAMES", "Show Custom Names"),
        function() return BIT.db.showCustomNames ~= false end,
        function(v) BIT.db.showCustomNames = v end))

    -- Custom name EditBox (canvas element to embed a text input)
    local cnInit = Settings.CreateElementInitializer("SettingsListSectionHeaderTemplate",
        { name = "" })
    local cnOrigInit = cnInit.InitFrame
    cnInit.InitFrame = function(self, frame)
        if cnOrigInit then cnOrigInit(self, frame) end
        -- prevent duplicate builds on frame recycle
        if frame._cnBuilt then
            -- show custom elements (may have been hidden by frame reuse on another page)
            if frame._cnLabel then frame._cnLabel:Show() end
            if frame._cnEB    then frame._cnEB:Show(); frame._cnEB:SetText((BIT.charDb and BIT.charDb.myCustomName) or ""); frame._cnEB:SetCursorPosition(0) end
            if frame._cnHint  then frame._cnHint:Show() end
            return
        end
        frame._cnBuilt = true

        local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("LEFT", frame, "LEFT", 10, 0)
        lbl:SetText(LL("CUSTOM_NAMES_NICK_CHAR", "Character Nickname") .. ":")

        local eb = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
        eb:SetSize(180, 22)
        eb:SetPoint("LEFT", lbl, "RIGHT", 8, 0)
        eb:SetAutoFocus(false)
        eb:SetMaxLetters(24)
        eb:SetFontObject(ChatFontNormal)
        eb:SetText((BIT.charDb and BIT.charDb.myCustomName) or "")
        eb:SetCursorPosition(0)

        local function Save(self2)
            if BIT.charDb then BIT.charDb.myCustomName = strtrim(self2:GetText()) end
            self2:ClearFocus()
            -- reset throttle so the name is sent immediately
            if BIT.Self then
                BIT.Self.lastHello     = 0
                BIT.Self.lastSyncHello = 0
            end
            if BIT.Self and BIT.Self.BroadcastHello then
                BIT.Self:BroadcastHello()
            end
            if BIT.Self and BIT.Self.BroadcastSyncHello then
                BIT.Self:BroadcastSyncHello()
            end
        end
        eb:SetScript("OnEnterPressed", Save)
        eb:SetScript("OnEditFocusLost", Save)
        eb:SetScript("OnEscapePressed", function(s)
            s:SetText((BIT.charDb and BIT.charDb.myCustomName) or "")
            s:ClearFocus()
        end)

        local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        hint:SetPoint("LEFT", eb, "RIGHT", 8, 0)
        hint:SetText("|cFF666666" .. LL("CUSTOM_NAMES_HINT", "Leave empty to use character name") .. "|r")

        frame._cnLabel = lbl
        frame._cnEB    = eb
        frame._cnHint  = hint

        -- hide custom elements when frame is released back to pool (prevents bleed into other pages)
        frame:HookScript("OnHide", function(f)
            if f._cnLabel then f._cnLabel:Hide() end
            if f._cnEB    then f._cnEB:Hide() end
            if f._cnHint  then f._cnHint:Hide() end
        end)
    end
    cnInit.GetExtent = function() return 30 end
    layout:AddInitializer(cnInit)
    InSection(cnSect, cnInit)

    -- Toggle: use global nickname instead of the per-character one
    InSection(cnSect, MakeCheckbox(cat, "BIT_useGlobalCustomName",
        LL("CUSTOM_NAMES_USE_GLOBAL", "Use Global Nickname (overrides per-character)"),
        function() return BIT.db.useGlobalCustomName == true end,
        function(v)
            BIT.db.useGlobalCustomName = v
            if BIT.Self then
                BIT.Self.lastHello     = 0
                BIT.Self.lastSyncHello = 0
                if BIT.Self.BroadcastHello     then BIT.Self:BroadcastHello()     end
                if BIT.Self.BroadcastSyncHello then BIT.Self:BroadcastSyncHello() end
            end
        end))

    -- Global nickname EditBox (mirrors the per-character one above)
    local gnInit = Settings.CreateElementInitializer("SettingsListSectionHeaderTemplate",
        { name = "" })
    local gnOrigInit = gnInit.InitFrame
    gnInit.InitFrame = function(self, frame)
        if gnOrigInit then gnOrigInit(self, frame) end
        if frame._gnBuilt then
            if frame._gnLabel then frame._gnLabel:Show() end
            if frame._gnEB    then frame._gnEB:Show(); frame._gnEB:SetText(BIT.db.globalCustomName or ""); frame._gnEB:SetCursorPosition(0) end
            if frame._gnHint  then frame._gnHint:Show() end
            return
        end
        frame._gnBuilt = true

        local lbl = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("LEFT", frame, "LEFT", 10, 0)
        lbl:SetText(LL("CUSTOM_NAMES_NICK_GLOBAL", "Global Nickname") .. ":")

        local eb = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
        eb:SetSize(180, 22)
        eb:SetPoint("LEFT", lbl, "RIGHT", 8, 0)
        eb:SetAutoFocus(false)
        eb:SetMaxLetters(24)
        eb:SetFontObject(ChatFontNormal)
        eb:SetText(BIT.db.globalCustomName or "")
        eb:SetCursorPosition(0)

        local function Save(self2)
            BIT.db.globalCustomName = strtrim(self2:GetText())
            self2:ClearFocus()
            if BIT.db.useGlobalCustomName and BIT.Self then
                BIT.Self.lastHello     = 0
                BIT.Self.lastSyncHello = 0
                if BIT.Self.BroadcastHello     then BIT.Self:BroadcastHello()     end
                if BIT.Self.BroadcastSyncHello then BIT.Self:BroadcastSyncHello() end
            end
        end
        eb:SetScript("OnEnterPressed", Save)
        eb:SetScript("OnEditFocusLost", Save)
        eb:SetScript("OnEscapePressed", function(s)
            s:SetText(BIT.db.globalCustomName or "")
            s:ClearFocus()
        end)

        local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        hint:SetPoint("LEFT", eb, "RIGHT", 8, 0)
        hint:SetText("|cFF666666" .. LL("CUSTOM_NAMES_HINT_GLOBAL", "Used on every character when enabled") .. "|r")

        frame._gnLabel = lbl
        frame._gnEB    = eb
        frame._gnHint  = hint

        frame:HookScript("OnHide", function(f)
            if f._gnLabel then f._gnLabel:Hide() end
            if f._gnEB    then f._gnEB:Hide() end
            if f._gnHint  then f._gnHint:Hide() end
        end)
    end
    gnInit.GetExtent = function() return 30 end
    layout:AddInitializer(gnInit)
    InSection(cnSect, gnInit)
end

------------------------------------------------------------
-- Page: Interrupt Tracker (own sidebar entry)
------------------------------------------------------------
local function BuildPageInterruptTracker(cat)
    local L      = BIT.L
    local layout = SettingsPanel:GetLayout(cat)

    -- ── General (expanded) ────────────────────────────────────────────
    local genSect = CreateSection(layout, "General", "it_general", true)
    local function G(init) InSection(genSect, init) end

    G(MakeCheckbox(cat, "BIT_locked", L["CB_LOCK_POSITION"],
        function() return BIT.db.locked end,
        function(v)
            BIT.db.locked = v
            BIT.UI:RebuildBars()
            if v and BIT.UI.HidePosEditor then BIT.UI.HidePosEditor() end
        end))

    G(MakeCheckbox(cat, "BIT_rotEnabled", L["ROT_ENABLE"] or "Enable Kick Rotation",
        function() return BIT.db.rotationEnabled end,
        function(v) BIT.db.rotationEnabled = v; BIT.UI:UpdateDisplay() end))

    G(MakeCheckbox(cat, "BIT_growUpward", L["CB_GROW_UPWARD"] or "Grow Upward",
        function() return BIT.db.growUpward end,
        function(v)
            BIT.db.growUpward = v
            BIT.UI:RebuildBars()
            if BIT.UI.ApplyFramePosition then BIT.UI.ApplyFramePosition() end
        end))

    G(MakeCheckbox(cat, "BIT_hideOOC", L["CB_HIDE_OUT_OF_COMBAT"],
        function() return BIT.db.hideOutOfCombat end,
        function(v) BIT.db.hideOutOfCombat = v; BIT.UI:CheckZoneVisibility() end))

    G(MakeCheckbox(cat, "BIT_showWelcome", L["CB_SHOW_WELCOME"] or "Show welcome message on login",
        function() return BIT.db.showWelcome ~= false end,
        function(v) BIT.db.showWelcome = v end))

    G(MakeDropdown(cat, "BIT_iconSide", L["SEC_ICON_POSITION"], "LEFT",
        function() return BIT.db.iconSide or "LEFT" end,
        function(v) BIT.db.iconSide = v; BIT.UI:RebuildBars() end,
        function()
            local c = Settings.CreateControlTextContainer()
            c:Add("LEFT",  L["ICON_LEFT"])
            c:Add("RIGHT", L["ICON_RIGHT"])
            return c:GetData()
        end))

    G(MakeDropdown(cat, "BIT_fillMode", L["SEC_BAR_FILL"], "DRAIN",
        function() return BIT.db.barFillMode or "DRAIN" end,
        function(v) BIT.db.barFillMode = v; BIT.UI:RebuildBars() end,
        function()
            local c = Settings.CreateControlTextContainer()
            c:Add("DRAIN", L["FILL_DRAIN"])
            c:Add("FILL",  L["FILL_FILL"])
            return c:GetData()
        end))

    G(MakeDropdown(cat, "BIT_sortMode", L["SEC_SORT_ORDER"], "NONE",
        function() return BIT.db.sortMode or "NONE" end,
        function(v) BIT.db.sortMode = v; BIT.UI:RebuildBars() end,
        function()
            local c = Settings.CreateControlTextContainer()
            c:Add("NONE",    L["SORT_NONE"])
            c:Add("CD_ASC",  L["SORT_ASC"])
            c:Add("CD_DESC", L["SORT_DESC"])
            return c:GetData()
        end))

    G(MakeDropdown(cat, "BIT_colorMode", L["SEC_BAR_COLOR"], "class",
        function() return BIT.db.useClassColors and "class" or "custom" end,
        function(v)
            BIT.db.useClassColors = (v == "class")
            BIT.UI:UpdateDisplay()
            if BIT.SyncCD and BIT.SyncCD.UpdateColors then BIT.SyncCD:UpdateColors() end
        end,
        function()
            local c = Settings.CreateControlTextContainer()
            c:Add("class",  L["COLOR_CLASS"])
            c:Add("custom", L["COLOR_CUSTOM"])
            return c:GetData()
        end))

    G(MakeSlider(cat, "BIT_alpha", L["SL_OPACITY"], 100, 10, 100, 5,
        function(v) return v .. "%" end,
        function() return math.floor((BIT.db.alpha or 1.0) * 100 + 0.5) end,
        function(v)
            BIT.db.alpha = v / 100
            if BIT.UI.mainFrame then BIT.UI.mainFrame:SetAlpha(v / 100) end
        end))

    do
        local testSetting = Settings.RegisterProxySetting(cat, "BIT_testMode",
            Settings.VarType.Boolean, L["SEC_TEST_MODE"], false,
            function() return BIT.testMode or false end,
            function(_) BIT:StartTestMode() end)
        G(Settings.CreateCheckbox(cat, testSetting, nil))
    end

    -- ── Failed Kick Detection (collapsed) ─────────────────────────────
    local failSect = CreateSection(layout, L["SEC_FAILED_KICK"] or "Failed Kick Detection", "failedKick", false)
    InSection(failSect, MakeCheckbox(cat, "BIT_failedKick",
        L["CB_FAILED_KICK"] or "CD text green on success, red on failed interrupt",
        function() return BIT.db.showFailedKick end,
        function(v) BIT.db.showFailedKick = v end))
    InSection(failSect, AddInfo(layout,
        "|cFFAAAAAA" .. (L["INFO_FAILED_KICK"] or "Only works when both players have the addon") .. "|r"))

    -- ── Visibility (collapsed) ────────────────────────────────────────
    local visSect = CreateSection(layout, "Visibility", "it_visibility", false)
    InSection(visSect, MakeCheckbox(cat, "BIT_dungeon", L["CB_SHOW_DUNGEON"],
        function() return BIT.db.showInDungeon end,
        function(v) BIT.db.showInDungeon = v; BIT.UI:CheckZoneVisibility() end))
    InSection(visSect, MakeCheckbox(cat, "BIT_raid", L["CB_SHOW_RAID"],
        function() return BIT.db.showInRaid end,
        function(v) BIT.db.showInRaid = v; BIT.UI:CheckZoneVisibility() end))
    InSection(visSect, MakeCheckbox(cat, "BIT_world", L["CB_SHOW_WORLD"],
        function() return BIT.db.showInOpenWorld end,
        function(v) BIT.db.showInOpenWorld = v; BIT.UI:CheckZoneVisibility() end))
    InSection(visSect, MakeCheckbox(cat, "BIT_arena", L["CB_SHOW_ARENA"],
        function() return BIT.db.showInArena end,
        function(v) BIT.db.showInArena = v; BIT.UI:CheckZoneVisibility() end))
    InSection(visSect, MakeCheckbox(cat, "BIT_bg", L["CB_SHOW_BG"],
        function() return BIT.db.showInBG end,
        function(v) BIT.db.showInBG = v; BIT.UI:CheckZoneVisibility() end))

    -- ── Sounds (collapsed) ────────────────────────────────────────────
    local sndSect = CreateSection(layout, L["PANEL_SOUNDS"] or "Sounds", "sounds", false)
    InSection(sndSect, MakeCheckbox(cat, "BIT_soundEnabled", L["CB_SOUND_ENABLED"],
        function() return BIT.db.soundEnabled end,
        function(v) BIT.db.soundEnabled = v end))
    InSection(sndSect, MakeCheckbox(cat, "BIT_soundOwnKickOnly", L["CB_SOUND_OWN_ONLY"],
        function() return BIT.db.soundOwnKickOnly end,
        function(v) BIT.db.soundOwnKickOnly = v end))
    InSection(sndSect, MakeDropdown(cat, "BIT_soundSuccess", L["DD_SOUND_SUCCESS"], "None",
        function() return BIT.db.soundKickSuccess or "None" end,
        function(v) BIT.db.soundKickSuccess = v end,
        function()
            local c = Settings.CreateControlTextContainer()
            for _, s in ipairs(BIT.Media:GetAvailableSounds()) do c:Add(s.name, s.name) end
            return c:GetData()
        end))
    InSection(sndSect, MakeDropdown(cat, "BIT_soundFailed", L["DD_SOUND_FAILED"], "None",
        function() return BIT.db.soundKickFailed or "None" end,
        function(v) BIT.db.soundKickFailed = v end,
        function()
            local c = Settings.CreateControlTextContainer()
            for _, s in ipairs(BIT.Media:GetAvailableSounds()) do c:Add(s.name, s.name) end
            return c:GetData()
        end))

end
------------------------------------------------------------
-- Page: Party CDs (own sidebar entry)
------------------------------------------------------------
local function BuildPagePartyCDs(cat)
    local L      = BIT.L
    local layout = SettingsPanel:GetLayout(cat)

    -- ── WIP Notice ────────────────────────────────────────────────────
    local wipSect = CreateSection(layout, "|cFFFF4444" .. (L["PARTY_CD_WIP_TITLE"] or "Work in Progress") .. "|r", "partyCd_wip", true)
    InSection(wipSect, AddInfo(layout,
        "|cFFFFD700" .. (L["PARTY_CD_WIP_LINE1"] or "This module is actively being developed.") .. "|r"))
    InSection(wipSect, AddInfo(layout,
        "|cFFAAAAAA" .. (L["PARTY_CD_WIP_LINE2"] or "Features may change, break, or be incomplete.") .. "|r"))

    -- ── General ───────────────────────────────────────────────────────
    local genSect = CreateSection(layout, L["SEC_GENERAL"] or "General", "partyCd_gen", true)
    local function G(init) InSection(genSect, init) end

    -- ── Shared predicates ─────────────────────────────────────────────
    local function isAttachActive()
        return (BIT.db.syncCdModeGroup or "ATTACH") == "ATTACH"
            or (BIT.db.syncCdModeRaid  or "BARS")  == "ATTACH"
    end
    local function isWindowMode()
        return (BIT.db.syncCdModeGroup or "ATTACH") == "WINDOW"
            or (BIT.db.syncCdModeRaid  or "BARS")  == "WINDOW"
    end
    local function isNotBarsMode()
        return (BIT.db.syncCdModeGroup or "ATTACH") ~= "BARS"
            or (BIT.db.syncCdModeRaid  or "BARS")  ~= "BARS"
    end
    local function bumpCatVer()
        BIT.db.syncCdCatVer = (BIT.db.syncCdCatVer or 0) + 1
        if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
    end

    -- ── Toggles ───────────────────────────────────────────────────────
    G(MakeCheckbox(cat, "BIT_showSyncCDs",
        L["CB_SHOW_SYNC_CDS"] or "Show Party CD tracker (addon users only)",
        function() return BIT.db.showSyncCDs end,
        function(v)
            BIT.db.showSyncCDs = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end))

    G(MakeCheckbox(cat, "BIT_syncOnlyInGroup",
        L["CB_SYNC_ONLY_GROUP"] or "Show only in group",
        function() return BIT.db.syncOnlyInGroup or false end,
        function(v)
            BIT.db.syncOnlyInGroup = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end))

    G(MakeCheckbox(cat, "BIT_showOwnSyncCD",
        L["CB_SHOW_OWN_SYNC"] or "Show own cooldowns",
        function() return BIT.db.showOwnSyncCD ~= false end,
        function(v)
            BIT.db.showOwnSyncCD = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end))

    G(MakeCheckbox(cat, "BIT_syncCdShowDMG",
        L["CB_SHOW_DMG"] or "Show Offensives",
        function() return BIT.db.syncCdShowDMG ~= false end,
        function(v) BIT.db.syncCdShowDMG = v; bumpCatVer() end))

    G(MakeCheckbox(cat, "BIT_syncCdShowDEF",
        L["CB_SHOW_DEF"] or "Show Defensives",
        function() return BIT.db.syncCdShowDEF ~= false end,
        function(v) BIT.db.syncCdShowDEF = v; bumpCatVer() end))

    local tooltipInit = MakeCheckbox(cat, "BIT_syncCdTooltip",
        L["CB_SYNC_TOOLTIP"] or "Show spell tooltips on hover",
        function() return BIT.db.syncCdTooltip ~= false end,
        function(v) BIT.db.syncCdTooltip = v end)
    if tooltipInit and tooltipInit.AddShownPredicate then
        tooltipInit:AddShownPredicate(isNotBarsMode)
    end
    G(tooltipInit)

    local windowCompactInit = MakeCheckbox(cat, "BIT_syncCdWindowCompact",
        L["CB_WINDOW_COMPACT"] or "Compact mode (no background, no title)",
        function() return BIT.db.syncCdWindowCompact or false end,
        function(v)
            BIT.db.syncCdWindowCompact = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    if windowCompactInit and windowCompactInit.AddShownPredicate then
        windowCompactInit:AddShownPredicate(isWindowMode)
    end
    G(windowCompactInit)

    local barsLockInit = MakeCheckbox(cat, "BIT_syncCdBarsLocked",
        L["CB_BARS_LOCKED"] or "Lock Position",
        function() return BIT.db.syncCdBarsLocked == true end,
        function(v)
            BIT.db.syncCdBarsLocked = v
            if BIT.SyncCD and BIT.SyncCD.ApplyStyle then BIT.SyncCD.ApplyStyle() end
        end)
    if barsLockInit and barsLockInit.AddShownPredicate then
        barsLockInit:AddShownPredicate(function()
            local g = BIT.db.syncCdModeGroup or "ATTACH"
            local r = BIT.db.syncCdModeRaid  or "BARS"
            return g == "BARS" or g == "WINDOW" or r == "BARS" or r == "WINDOW"
        end)
    end
    G(barsLockInit)

    -- CC Window section removed (CC tracking removed)

    -- ── Display & Layout ────────────────────────────────────────────
    local displaySect = CreateSection(layout, LL("SEC_SYNC_DISPLAY", "Display & Layout"), "partyCd_display", true)
    local function D(init) InSection(displaySect, init) end

    local groupModeSetting = Settings.RegisterProxySetting(cat, "BIT_syncCdModeGroup",
        Settings.VarType.String,
        L["SYNC_DISPLAY_MODE_GROUP"] or "Display Mode (Group)",
        "ATTACH",
        function() return BIT.db.syncCdModeGroup or "ATTACH" end,
        function(v)
            BIT.db.syncCdModeGroup = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    local groupModeInit = Settings.CreateDropdown(cat, groupModeSetting, function()
        local c = Settings.CreateControlTextContainer()
        c:Add("WINDOW", L["SYNC_MODE_WINDOW"]   or "Standalone Window")
        c:Add("ATTACH", L["SYNC_MODE_ATTACH"]   or "Attach to Party Frames")
        c:Add("BARS",   L["SYNC_MODE_BARS"]     or "Group Bars")
        c:Add("OFF",    L["SYNC_MODE_DISABLED"] or "Disabled")
        return c:GetData()
    end)
    D(groupModeInit)

    local raidModeSetting = Settings.RegisterProxySetting(cat, "BIT_syncCdModeRaid",
        Settings.VarType.String,
        L["SYNC_DISPLAY_MODE_RAID"] or "Display Mode (Raid)",
        "BARS",
        function() return BIT.db.syncCdModeRaid or "BARS" end,
        function(v)
            BIT.db.syncCdModeRaid = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    local raidModeInit = Settings.CreateDropdown(cat, raidModeSetting, function()
        local c = Settings.CreateControlTextContainer()
        c:Add("WINDOW", L["SYNC_MODE_WINDOW"]   or "Standalone Window")
        c:Add("ATTACH", L["SYNC_MODE_ATTACH"]   or "Attach to Party Frames")
        c:Add("BARS",   L["SYNC_MODE_BARS"]     or "Group Bars")
        c:Add("OFF",    L["SYNC_MODE_DISABLED"] or "Disabled")
        return c:GetData()
    end)
    D(raidModeInit)

    -- ── Frame Provider ───────────────────────────────────────────────
    local providerSetting = Settings.RegisterProxySetting(cat, "BIT_syncCdFrameProvider",
        Settings.VarType.String,
        "Attach to Frames",
        "AUTO",
        function() return BIT.db.syncCdFrameProvider or "AUTO" end,
        function(v)
            BIT.db.syncCdFrameProvider = v
            BIT.db._frameProviderAsked = true
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    local providerInit = Settings.CreateDropdown(cat, providerSetting, function()
        local c = Settings.CreateControlTextContainer()
        c:Add("AUTO",       "Auto Detect")
        c:Add("ELVUI",      "ElvUI")
        c:Add("NDUI",       "NDui")
        c:Add("DANDERS",    "D4 / Danders")
        c:Add("CELL",       "Cell")
        c:Add("GRID2",      "Grid2")
        c:Add("ENHANCEQOL", "EnhanceQoL")
        c:Add("SUF",        "ShadowedUF")
        c:Add("BLIZZARD",   "Blizzard")
        return c:GetData()
    end)
    if providerInit and providerInit.AddShownPredicate then
        providerInit:AddShownPredicate(isAttachActive)
    end
    D(providerInit)

    -- ── Attach ────────────────────────────────────────────────────────
    local posSetting = Settings.RegisterProxySetting(cat, "BIT_syncCdAttachPos",
        Settings.VarType.String,
        L["SYNC_ATTACH_POS"] or "Attach Position",
        "LEFT",
        function() return BIT.db.syncCdAttachPos or "LEFT" end,
        function(v)
            BIT.db.syncCdAttachPos = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    local posInit = Settings.CreateDropdown(cat, posSetting, function()
        local c = Settings.CreateControlTextContainer()
        c:Add("RIGHT",  L["SYNC_POS_RIGHT"]  or "Right")
        c:Add("LEFT",   L["SYNC_POS_LEFT"]   or "Left")
        c:Add("TOP",    L["SYNC_POS_TOP"]    or "Top")
        c:Add("BOTTOM", L["SYNC_POS_BOTTOM"] or "Bottom")
        return c:GetData()
    end)
    if posInit and posInit.AddShownPredicate then
        posInit:AddShownPredicate(isAttachActive)
    end
    D(posInit)

    -- ── Layout ────────────────────────────────────────────────────────
    -- Unified Top / Bottom layout (3.5.0+). Was previously two separate
    -- dropdowns; collapsed into one because users always picked the
    -- same value for both directions in practice.
    local tbLayoutSetting = Settings.RegisterProxySetting(cat, "BIT_syncCdTBLayout",
        Settings.VarType.String,
        L["SYNC_TB_LAYOUT"] or "Top / Bottom - Layout",
        "ROWS",
        function()
            return BIT.db.syncCdTBLayout
                or BIT.db.syncCdTopLayout
                or BIT.db.syncCdBottomLayout
                or "ROWS"
        end,
        function(v)
            BIT.db.syncCdTBLayout     = v
            BIT.db.syncCdTopLayout    = v   -- mirror to legacy keys for downgrade-safety
            BIT.db.syncCdBottomLayout = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    local tbLayoutInit = Settings.CreateDropdown(cat, tbLayoutSetting, function()
        local c = Settings.CreateControlTextContainer()
        c:Add("ROWS",    L["SYNC_LAYOUT_ROWS"]    or "Rows")
        c:Add("COLUMNS", L["SYNC_LAYOUT_COLUMNS"] or "Columns")
        return c:GetData()
    end)
    if tbLayoutInit and tbLayoutInit.AddShownPredicate then
        tbLayoutInit:AddShownPredicate(function()
            local p = BIT.db.syncCdAttachPos or "LEFT"
            return isAttachActive() and (p == "TOP" or p == "BOTTOM")
        end)
    end
    D(tbLayoutInit)

    local function rowOpts()
        local c = Settings.CreateControlTextContainer()
        c:Add("1", L["ROW_1"] or "Row 1")
        c:Add("2", L["ROW_2"] or "Row 2")
        c:Add("3", L["ROW_3"] or "Row 3")
        return c:GetData()
    end

    D(MakeDropdown(cat, "BIT_syncCdCatRowDMG", L["DD_CAT_ROW_DMG"] or "Offensives — Row", "1",
        function() return tostring(BIT.db.syncCdCatRowDMG or "1") end,
        function(v) BIT.db.syncCdCatRowDMG = v; bumpCatVer() end,
        rowOpts))

    D(MakeDropdown(cat, "BIT_syncCdCatRowDEF", L["DD_CAT_ROW_DEF"] or "Defensives — Row", "2",
        function() return tostring(BIT.db.syncCdCatRowDEF or "2") end,
        function(v) BIT.db.syncCdCatRowDEF = v; bumpCatVer() end,
        rowOpts))

    -- ── Icons & Text ────────────────────────────────────────────────
    local iconsSect = CreateSection(layout, LL("SEC_SYNC_ICONS", "Icons & Text"), "partyCd_icons", true)
    local function I(init) InSection(iconsSect, init) end

    local iconSizeInit = MakeSlider(cat, "BIT_syncCdIconSize",
        L["SL_SYNC_ICON_SIZE"] or "Icon Size",
        28, 12, 60, 1,
        function(v) return tostring(v) end,
        function() return BIT.db.syncCdIconSize or 28 end,
        function(v)
            BIT.db.syncCdIconSize = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    if iconSizeInit and iconSizeInit.AddShownPredicate then iconSizeInit:AddShownPredicate(isNotBarsMode) end
    I(iconSizeInit)

    local iconSpacingInit = MakeSlider(cat, "BIT_syncCdIconSpacing",
        L["SL_SYNC_ICON_SPACING"] or "Icon Spacing",
        2, 0, 20, 1,
        function(v) return tostring(v) end,
        function() return BIT.db.syncCdIconSpacing or 4 end,
        function(v)
            BIT.db.syncCdIconSpacing = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    if iconSpacingInit and iconSpacingInit.AddShownPredicate then iconSpacingInit:AddShownPredicate(isNotBarsMode) end
    I(iconSpacingInit)

    local rowGapInit = MakeSlider(cat, "BIT_syncCdAttachRowGap",
        L["SL_ATTACH_ROW_GAP"] or "Row Spacing",
        2, 0, 20, 1,
        function(v) return tostring(v) end,
        function() return BIT.db.syncCdAttachRowGap or 4 end,
        function(v)
            BIT.db.syncCdAttachRowGap = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    if rowGapInit and rowGapInit.AddShownPredicate then rowGapInit:AddShownPredicate(isAttachActive) end
    I(rowGapInit)

    local attachOffXInit = MakeSlider(cat, "BIT_syncCdAttachOffsetX",
        L["SL_ATTACH_OFFSET_X"] or "Offset X",
        0, -100, 100, 1,
        function(v) return tostring(v) end,
        function() return BIT.db.syncCdAttachOffsetX or 0 end,
        function(v)
            BIT.db.syncCdAttachOffsetX = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    if attachOffXInit and attachOffXInit.AddShownPredicate then attachOffXInit:AddShownPredicate(isAttachActive) end
    I(attachOffXInit)

    local attachOffYInit = MakeSlider(cat, "BIT_syncCdAttachOffsetY",
        L["SL_ATTACH_OFFSET_Y"] or "Offset Y",
        0, -100, 100, 1,
        function(v) return tostring(v) end,
        function() return BIT.db.syncCdAttachOffsetY or 0 end,
        function(v)
            BIT.db.syncCdAttachOffsetY = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    if attachOffYInit and attachOffYInit.AddShownPredicate then attachOffYInit:AddShownPredicate(isAttachActive) end
    I(attachOffYInit)

    local counterSizeInit = MakeSlider(cat, "BIT_syncCdCounterSize",
        L["SL_SYNC_COUNTER_SIZE"] or "Counter Text Size",
        10, 6, 24, 1,
        function(v) return tostring(v) end,
        function() return BIT.db.syncCdCounterSize or 14 end,
        function(v)
            BIT.db.syncCdCounterSize = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end)
    if counterSizeInit and counterSizeInit.AddShownPredicate then counterSizeInit:AddShownPredicate(isNotBarsMode) end
    I(counterSizeInit)

    local timeFmtInit = MakeDropdown(cat, "BIT_syncCdTimeFormat",
        L["DD_SYNC_TIME_FORMAT"] or "Countdown Format",
        "SECONDS",
        function() return BIT.db.syncCdTimeFormat or "MMSS" end,
        function(v)
            BIT.db.syncCdTimeFormat = v
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end,
        function()
            local c = Settings.CreateControlTextContainer()
            c:Add("SECONDS", L["TIMEFMT_SECONDS"] or "Seconds (90)")
            c:Add("MMSS",    L["TIMEFMT_MMSS"]    or "MM:SS (1:30)")
            return c:GetData()
        end)
    if timeFmtInit and timeFmtInit.AddShownPredicate then timeFmtInit:AddShownPredicate(isNotBarsMode) end
    I(timeFmtInit)

    -- ── Spell Filters ─────────────────────────────────────────────────
    local SPEC_TO_CLASS = {
        [250]="DEATHKNIGHT",[251]="DEATHKNIGHT",[252]="DEATHKNIGHT",
        [577]="DEMONHUNTER",[581]="DEMONHUNTER",[1480]="DEMONHUNTER",
        [102]="DRUID",[103]="DRUID",[104]="DRUID",[105]="DRUID",
        [1467]="EVOKER",[1468]="EVOKER",[1473]="EVOKER",
        [253]="HUNTER",[254]="HUNTER",[255]="HUNTER",
        [62]="MAGE",[63]="MAGE",[64]="MAGE",
        [268]="MONK",[269]="MONK",[270]="MONK",
        [65]="PALADIN",[66]="PALADIN",[70]="PALADIN",
        [256]="PRIEST",[257]="PRIEST",[258]="PRIEST",
        [259]="ROGUE",[260]="ROGUE",[261]="ROGUE",
        [262]="SHAMAN",[263]="SHAMAN",[264]="SHAMAN",
        [265]="WARLOCK",[266]="WARLOCK",[267]="WARLOCK",
        [71]="WARRIOR",[72]="WARRIOR",[73]="WARRIOR",
    }
    local CLASS_ORDER = {
        "DEATHKNIGHT","DEMONHUNTER","DRUID","EVOKER","HUNTER",
        "MAGE","MONK","PALADIN","PRIEST","ROGUE",
        "SHAMAN","WARLOCK","WARRIOR",
    }
    local CLASS_DISPLAY = {
        DEATHKNIGHT="Death Knight", DEMONHUNTER="Demon Hunter",
        DRUID="Druid", EVOKER="Evoker", HUNTER="Hunter",
        MAGE="Mage", MONK="Monk", PALADIN="Paladin",
        PRIEST="Priest", ROGUE="Rogue", SHAMAN="Shaman",
        WARLOCK="Warlock", WARRIOR="Warrior",
    }

    local catData   = {}
    local seenSpell = {}
    if BIT.SYNC_SPELLS then
        for specID, spells in pairs(BIT.SYNC_SPELLS) do
            local cls = SPEC_TO_CLASS[specID]
            if cls then
                for _, s in ipairs(spells) do
                    if not seenSpell[s.id] then
                        seenSpell[s.id] = true
                        local ck = s.cat or "DEF"
                        if not catData[ck] then catData[ck] = {} end
                        if not catData[ck][cls] then catData[ck][cls] = {} end
                        local t = catData[ck][cls]
                        t[#t+1] = { id = s.id, name = s.name }
                    end
                end
            end
        end
        for _, clsMap in pairs(catData) do
            for _, spells in pairs(clsMap) do
                table.sort(spells, function(a, b) return a.name < b.name end)
            end
        end
    end

    local SYNC_CATEGORIES = {
        { key = "DMG", label = LL("SF_CAT_DMG", "Damage CDs")   },
        { key = "DEF", label = LL("SF_CAT_DEF", "Defensive CDs") },
    }

    local filterSect = CreateSection(layout, LL("SEC_SPELL_FILTER", "Spell Filters — Party CDs"), "syncSpellFilter", false)

    for _, catEntry in ipairs(SYNC_CATEGORIES) do
        local clsMap = catData[catEntry.key]
        if clsMap then
            -- Nested collapsible section per category
            local innerSect = CreateSection(layout, "|cFFFFD700" .. catEntry.label .. "|r", "syncCat_" .. catEntry.key, false)
            InSection(filterSect, innerSect)

            for _, cls in ipairs(CLASS_ORDER) do
                local spells = clsMap[cls]
                if spells and #spells > 0 then
                    local cc  = BIT.CLASS_COLORS and BIT.CLASS_COLORS[cls]
                    local r   = cc and cc[1] or 1
                    local g   = cc and cc[2] or 1
                    local b   = cc and cc[3] or 1
                    local hex = string.format("%02x%02x%02x",
                        math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
                    local clsInit = AddInfo(layout,
                        "|cff" .. hex .. CLASS_DISPLAY[cls] .. "|r")
                    InSection(innerSect, clsInit)

                    for _, s in ipairs(spells) do
                        local sid    = s.id
                        local iconID = C_Spell.GetSpellTexture(sid)
                        local label  = (iconID and ("|T"..iconID..":16:16:0:0|t ") or "") .. s.name
                        local spellSetting = Settings.RegisterProxySetting(cat,
                            "BIT_sync_" .. sid,
                            Settings.VarType.Boolean,
                            label, true,
                            function()
                                return not (BIT.db.syncCdDisabled and BIT.db.syncCdDisabled[sid])
                            end,
                            function(v)
                                if not BIT.db.syncCdDisabled then BIT.db.syncCdDisabled = {} end
                                BIT.db.syncCdDisabled[sid] = not v or nil
                                BIT.db.syncCdDisabledVer = (BIT.db.syncCdDisabledVer or 0) + 1
                                if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
                            end)
                        local spellInit = Settings.CreateCheckbox(cat, spellSetting)
                        InSection(innerSect, spellInit)
                    end
                end
            end
        end
    end
end

------------------------------------------------------------
-- Page: Size & Font (own sidebar entry, collapsible sub-sections)
------------------------------------------------------------
local function BuildPageSizeFont(cat)
    local L      = BIT.L
    local layout = SettingsPanel:GetLayout(cat)

    -- ── Title ─────────────────────────────────────────────────────────
    local titleSect = CreateSection(layout, L["SF_TITLE"] or "Title Bar", "sf_title", true)
    do
        InSection(titleSect, MakeCheckbox(cat, "BIT_showTitle", L["CB_SHOW_TITLE"],
            function() return BIT.db.showTitle end,
            function(v) BIT.db.showTitle = v; BIT.UI:RebuildBars() end))

        local tfi = MakeSlider(cat, "BIT_titleFont",
            L["SL_FONT_TITLE"] or "Title Font Size", 0, 0, 36, 1,
            function(v) return v == 0 and "Auto" or tostring(v) end,
            function() return BIT.db.titleFontSize or 0 end,
            function(v) BIT.db.titleFontSize = v; BIT.UI:RebuildBars() end)
        InSection(titleSect, tfi)

        local tai = MakeDropdown(cat, "BIT_titleAlign",
            L["SEC_TITLE_ALIGN"] or "Alignment", "CENTER",
            function() return BIT.db.titleAlign or "CENTER" end,
            function(v) BIT.db.titleAlign = v; BIT.UI:RebuildBars() end,
            function()
                local c = Settings.CreateControlTextContainer()
                c:Add("LEFT",   L["ALIGN_LEFT"]   or "Left")
                c:Add("CENTER", L["ALIGN_CENTER"] or "Center")
                c:Add("RIGHT",  L["ALIGN_RIGHT"]  or "Right")
                return c:GetData()
            end)
        InSection(titleSect, tai)
        -- Hide alignment when title bar is disabled
        if tai and tai.AddShownPredicate then
            tai:AddShownPredicate(function() return BIT.db.showTitle ~= false end)
        end

        local toyi = MakeSliderEdit(cat, "BIT_titleOffY", L["SL_OFFSET_Y"] or "Offset Y", 0, -30, 30, 1,
            function(v) return (v >= 0 and "+" or "") .. v .. " px" end,
            function() return BIT.db.titleOffsetY or 0 end,
            function(v)
                BIT.db.titleOffsetY = v
                BIT.UI:RebuildBars()
            end)
        InSection(titleSect, toyi)
        if toyi and toyi.AddShownPredicate then
            toyi:AddShownPredicate(function() return BIT.db.showTitle ~= false end)
        end
    end

    -- ── Name ──────────────────────────────────────────────────────────
    local nameSect = CreateSection(layout, L["SF_NAME"] or "Name", "sf_name", true)
    InSection(nameSect, MakeCheckbox(cat, "BIT_showName", L["CB_SHOW_NAME"],
        function() return BIT.db.showName end,
        function(v) BIT.db.showName = v; BIT.UI:UpdateDisplay() end))
    InSection(nameSect, MakeDropdown(cat, "BIT_font", "Font", "Default",
        function() return BIT.db.fontName or BIT.Media.fontName or "Default" end,
        function(v)
            for _, e in ipairs(BIT.Media:GetAvailableFonts()) do
                if e.name == v then
                    BIT.db.fontPath = e.path; BIT.db.fontName = e.name
                    BIT.Media.font  = e.path; BIT.Media.fontName = e.name
                    break
                end
            end
            BIT.UI:RebuildBars()
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end,
        function()
            local c = Settings.CreateControlTextContainer()
            for _, e in ipairs(BIT.Media:GetAvailableFonts()) do c:Add(e.name, e.name) end
            return c:GetData()
        end))
    InSection(nameSect, MakeSlider(cat, "BIT_nameFont", L["SL_FONT_NAME"], 0, 0, 24, 1,
        function(v) return v == 0 and "Auto" or tostring(v) end,
        function() return BIT.db.nameFontSize or 0 end,
        function(v) BIT.db.nameFontSize = v; BIT.UI:RebuildBars() end))
    InSection(nameSect, MakeSliderEdit(cat, "BIT_offX", L["SL_OFFSET_X"], 0, -100, 100, 1,
        function(v) return (v >= 0 and "+" or "") .. v .. " px" end,
        function() return BIT.db.nameOffsetX or 0 end,
        function(v) BIT.db.nameOffsetX = v; BIT.UI:RebuildBars() end))
    InSection(nameSect, MakeSliderEdit(cat, "BIT_offY", L["SL_OFFSET_Y"], 0, -20, 20, 1,
        function(v) return (v >= 0 and "+" or "") .. v .. " px" end,
        function() return BIT.db.nameOffsetY or 0 end,
        function(v) BIT.db.nameOffsetY = v; BIT.UI:RebuildBars() end))

    -- ── CD / Ready Text ───────────────────────────────────────────────
    local cdSect = CreateSection(layout, L["SF_CDTEXT"] or "CD / Ready", "sf_cdtext", true)
    InSection(cdSect, MakeCheckbox(cat, "BIT_showReady", L["CB_SHOW_READY"],
        function() return BIT.db.showReady end,
        function(v) BIT.db.showReady = v; BIT.UI:RebuildBars() end))
    InSection(cdSect, MakeSlider(cat, "BIT_cdFont", L["SL_FONT_CD"], 0, 0, 24, 1,
        function(v) return v == 0 and "Auto" or tostring(v) end,
        function() return BIT.db.readyFontSize or 0 end,
        function(v) BIT.db.readyFontSize = v; BIT.UI:RebuildBars() end))
    InSection(cdSect, MakeSlider(cat, "BIT_cdOffX", L["SL_CD_OFFSET_X"] or "CD Text Offset X", 0, -50, 50, 1,
        function(v) return (v >= 0 and "+" or "") .. v .. " px" end,
        function() return BIT.db.cdOffsetX or 0 end,
        function(v) BIT.db.cdOffsetX = v; BIT.UI:RebuildBars() end))
    InSection(cdSect, MakeSlider(cat, "BIT_cdOffY", L["SL_CD_OFFSET_Y"] or "CD Text Offset Y", 0, -50, 50, 1,
        function(v) return (v >= 0 and "+" or "") .. v .. " px" end,
        function() return BIT.db.cdOffsetY or 0 end,
        function(v) BIT.db.cdOffsetY = v; BIT.UI:RebuildBars() end))

    -- ── Frame ─────────────────────────────────────────────────────────
    local frameSect = CreateSection(layout, L["SEC_FRAME"] or "Frame", "sf_frame", true)
    InSection(frameSect, MakeSliderEdit(cat, "BIT_barW", L["SL_WIDTH"], 180, 10, 500, 1,
        function(v) return v .. " px" end,
        function() return BIT.db.frameWidth or 180 end,
        function(v) BIT.db.frameWidth = v; BIT.UI:RebuildBars() end))
    InSection(frameSect, MakeSliderEdit(cat, "BIT_barH", L["SL_BAR_HEIGHT"], 30, 14, 60, 1,
        function(v) return v .. " px" end,
        function() return BIT.db.barHeight or 30 end,
        function(v) BIT.db.barHeight = v; BIT.UI:RebuildBars() end))
    InSection(frameSect, MakeSliderEdit(cat, "BIT_barGap", LL("SL_BAR_GAP", "Bar Gap"), 0, -1, 40, 1,
        function(v) return v .. " px" end,
        function() return BIT.db.barGap or 0 end,
        function(v) BIT.db.barGap = v; BIT.UI:RebuildBars() end))
    InSection(frameSect, MakeSlider(cat, "BIT_frameScale", LL("SL_FRAME_SCALE", "Frame Scale"), 100, 10, 200, 1,
        function(v) return v .. "%" end,
        function() return BIT.db.frameScale or 100 end,
        function(v)
            local f = BIT.UI.mainFrame
            if not f then BIT.db.frameScale = v; return end
            local oldScale = f:GetScale()
            local cx, cy   = f:GetCenter()
            local screenCX = cx * oldScale
            local screenCY = cy * oldScale
            local newScale = v / 100
            BIT.db.frameScale = v
            f:SetScale(newScale)
            f:ClearAllPoints()
            f:SetPoint("CENTER", UIParent, "BOTTOMLEFT",
                screenCX / newScale, screenCY / newScale)
            -- Save position in the same format as the drag handler so
            -- ApplyFramePosition() doesn't drift on the next RebuildBars call.
            -- 3.5.0+: positions are per-profile in BIT.db (was charDb).
            if BIT.db then
                local titleH = BIT.db.showTitle and 20 or 0
                if BIT.db.growUpward then
                    BIT.db.posXUp = f:GetLeft()
                    BIT.db.posYUp = f:GetBottom()
                else
                    BIT.db.posX = f:GetLeft()
                    BIT.db.posY = (f:GetTop() or 0) - titleH
                end
            end
            -- Apply same scale to Party CD Bars (center-preserving)
            if BIT.SyncCD and BIT.SyncCD.ScaleFrame then
                BIT.SyncCD:ScaleFrame(v)
            end
        end,
        LL("TT_FRAME_SCALE", "Scales the entire tracker window. 100% = original size.")))

    -- ── Bar Texture ───────────────────────────────────────────────────
    local barSect = CreateSection(layout, L["SEC_BAR"] or "Bar Texture", "sf_bartex", true)
    InSection(barSect, MakeDropdown(cat, "BIT_barTex", "Bar Texture", "Flat",
        function() return BIT.db.barTextureName or BIT.Media.barTextureName or "Flat" end,
        function(v)
            for _, e in ipairs(BIT.Media:GetAvailableTextures()) do
                if e.name == v then
                    BIT.db.barTexturePath = e.path; BIT.db.barTextureName = e.name
                    BIT.Media.barTexture  = e.path; BIT.Media.barTextureName = e.name
                    break
                end
            end
            BIT.UI:RebuildBars()
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end,
        function()
            local c = Settings.CreateControlTextContainer()
            for _, e in ipairs(BIT.Media:GetAvailableTextures()) do c:Add(e.name, e.name) end
            return c:GetData()
        end))

    -- ── Border ────────────────────────────────────────────────────────
    local borderSect = CreateSection(layout, L["SEC_BORDER"] or "Border", "sf_border", true)
    InSection(borderSect, MakeDropdown(cat, "BIT_border", L["SEC_BAR_BORDER"], "None",
        function() return BIT.db.borderTextureName or "None" end,
        function(v)
            for _, e in ipairs(BIT.Media:GetAvailableBorders()) do
                if e.name == v then
                    BIT.db.borderTexturePath = e.path
                    BIT.db.borderTextureName = e.name
                    BIT.UI:ApplyBorderToAll()
                    if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
                    break
                end
            end
        end,
        function()
            local c = Settings.CreateControlTextContainer()
            for _, e in ipairs(BIT.Media:GetAvailableBorders()) do c:Add(e.name, e.name) end
            return c:GetData()
        end))
    InSection(borderSect, MakeSliderEdit(cat, "BIT_borderSize", L["SL_BORDER_SIZE"], 12, 1, 24, 1,
        function(v) return v .. " px" end,
        function() return BIT.db.borderSize or 12 end,
        function(v) BIT.db.borderSize = v; BIT.UI:ApplyBorderToAll(); if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end end))

    -- ── Outline & Shadow ─────────────────────────────────────────────
    local outlineSect = CreateSection(layout, LL("SF_OUTLINE", "Outline & Shadow"), "sf_outline", true)
    InSection(outlineSect, MakeDropdown(cat, "BIT_fontOutline",
        LL("DD_FONT_OUTLINE", "Font Outline"), "OUTLINE",
        function() return BIT.db.fontOutline or "OUTLINE" end,
        function(v)
            BIT.db.fontOutline = v
            BIT.Media:Load()
            BIT.UI:RebuildBars()
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end,
        function()
            local c = Settings.CreateControlTextContainer()
            c:Add("NONE",          LL("OUTLINE_NONE", "None"))
            c:Add("OUTLINE",       LL("OUTLINE_THIN", "Outline"))
            c:Add("THICKOUTLINE",  LL("OUTLINE_THICK", "Thick Outline"))
            return c:GetData()
        end))
    InSection(outlineSect, MakeSliderEdit(cat, "BIT_shadowX",
        LL("SL_SHADOW_X", "Shadow Offset X"), 0, -5, 5, 1,
        function(v) return (v >= 0 and "+" or "") .. v .. " px" end,
        function() return BIT.db.shadowOffsetX or 0 end,
        function(v)
            BIT.db.shadowOffsetX = v
            BIT.UI:RebuildBars()
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end))
    InSection(outlineSect, MakeSliderEdit(cat, "BIT_shadowY",
        LL("SL_SHADOW_Y", "Shadow Offset Y"), 0, -5, 5, 1,
        function(v) return (v >= 0 and "+" or "") .. v .. " px" end,
        function() return BIT.db.shadowOffsetY or 0 end,
        function(v)
            BIT.db.shadowOffsetY = v
            BIT.UI:RebuildBars()
            if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
        end))
end

-- Blizzard Settings registration removed — addon uses custom SettingsUI.lua
