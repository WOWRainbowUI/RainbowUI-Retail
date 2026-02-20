local _, DFFN = ...

local HttpsxLib = DFFN.httpsxLib

local httpsxFriendlyNamePlates = CreateFrame("Frame")
httpsxFriendlyNamePlates.hideCastBar = CreateFrame("Frame")
httpsxFriendlyNamePlates.config = {}

local DFFNamePlates = {}
DFFNamePlates.tabs = {}
DFFNamePlates.settings = {}
DFFNamePlates.gameFonts = { SystemFont_NamePlate_Outlined, SystemFont_NamePlate }
DFFNamePlates.instanceType = "none"

DFFN.DFFNamePlates = DFFNamePlates

local defaultFont, defaultFontSize, defaultFontFlags = SystemFont_NamePlate_Outlined:GetFont() --unitNameInside
local defaultFont2, defaultFontSize2, defaultFontFlags2 = SystemFont_NamePlate:GetFont()

DFFNamePlates.defaultFont = {
    name = defaultFont,
    size = defaultFontSize,
    flags = defaultFontFlags,
}
DFFNamePlates.defaultFont2 = {
    name = defaultFont2,
    size = defaultFontSize2,
    flags = defaultFontFlags2,
}

local ADDON_VERSION = "2.3"
local CONFIG_VERSION = "3.1"
DFFNamePlates.DEFAULT_WORLD_TEXT_SIZE = 0
DFFNamePlates.DEFAULT_WORLD_TEXT_ALPHA = 0.5

function DFFNamePlates:reloadNP()
    SetCVar("UnitNameFriendlyPlayerName", GetCVar("UnitNameFriendlyPlayerName"))
end

function DFFNamePlates:UpdateFontFrame(frame)
    if not DFFriendlyNamePlates.NamePlatesSettings["customFont"] then return end
    frame:SetFont(DFFriendlyNamePlates.NamePlatesSettings["fontName"],
        DFFriendlyNamePlates.NamePlatesSettings["fontSize"],
        DFFriendlyNamePlates.NamePlatesSettings["fontStyle"])
end

function DFFNamePlates:setFontForAll()
    for _, frame in pairs(C_NamePlate.GetNamePlates()) do --Skip forbiddenNP
        if frame and frame.UnitFrame and frame.UnitFrame.name then
            DFFNamePlates:UpdateFontFrame(frame.UnitFrame.name)
        end
    end
end

function DFFNamePlates:UpdateFont()
    if not DFFriendlyNamePlates.NamePlatesSettings["customFont"] then return end
    for _, v in pairs(DFFNamePlates.gameFonts) do
        v:SetFont(DFFriendlyNamePlates.NamePlatesSettings["fontName"],
            DFFriendlyNamePlates.NamePlatesSettings["fontSize"],
            DFFriendlyNamePlates.NamePlatesSettings["fontStyle"])
    end
end

function DFFNamePlates:forceUpdateFont(needDelay)
    if not DFFriendlyNamePlates.NamePlatesSettings["customFont"] then return end
    for _, v in pairs(DFFNamePlates.gameFonts) do
        v:SetFont(DFFriendlyNamePlates.NamePlatesSettings["fontName"],
            DFFriendlyNamePlates.NamePlatesSettings["fontSize"] - 1,
            DFFriendlyNamePlates.NamePlatesSettings["fontStyle"])
    end
    if not needDelay then
        DFFNamePlates:UpdateFont()
        return
    else
        C_Timer.After(0.1, function() DFFNamePlates:UpdateFont() end)
    end
end

function DFFNamePlates:SwitchTab(name)
    for k, mod in pairs(self.tabs) do
        if mod.Hide then mod:Hide() end
    end
    if self.tabs[name] and self.tabs[name].Show then
        self.tabs[name]:Show()
    end
end

function DFFNamePlates:SetActiveTab(btn)
    if self.activeTab then
        self.activeTab:SetBackdropColor(0.12, 0.12, 0.18, 0.8)
        self.activeTab:SetBackdropBorderColor(0.3, 0.3, 0.4, 0.6)
        self.activeTab.text:SetTextColor(0.9, 0.8, 0.6)
        self.activeTab.activeIndicator:Hide()
    end

    self.activeTab = btn

    btn:SetBackdropColor(0.25, 0.25, 0.35, 1)
    btn:SetBackdropBorderColor(0.6, 0.6, 0.8, 1)
    btn.text:SetTextColor(1, 0.95, 0.8)
    btn.activeIndicator:Show()
    btn.activeIndicator:SetVertexColor(0.8, 0.6, 0.2, 1)

    local animGroup = btn.activeIndicator:CreateAnimationGroup()
    local fadeIn = animGroup:CreateAnimation("Alpha")
    fadeIn:SetDuration(0.2)
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetSmoothing("IN")

    animGroup:Play()
end

function DFFNamePlates:AddTabFrame(name, module)
    local tab = {}
    tab.frame = CreateFrame("Frame", nil, DFFNamePlates.mainContent)
    tab.frame:SetAllPoints()
    tab.module = module

    local title = HttpsxLib:CreateText(tab.frame, name, "TOP", tab.frame, "TOP", 0, -10, 12,
        { 0.9, 0.8, 0.5, 1 }, "OUTLINE")

    function tab:Show()
        self.frame:Show()
    end

    function tab:Hide()
        self.frame:Hide()
    end

    tab:Hide()

    DFFNamePlates.tabs[name] = tab

    return tab
end

function DFFNamePlates:AddTabButton(name, index, module)
    local btn = CreateFrame("Button", nil, self.frame.tabList, BackdropTemplateMixin and "BackdropTemplate")
    btn:SetSize(94, 25)
    btn:SetPoint("TOPLEFT", 5 + (index - 1) * 97, -5)

    btn:SetBackdrop({
        bgFile = "Interface\\AddOns\\DFFriendlyNameplates\\Media\\Textures\\WHITE8X8",
        edgeFile =
        "Interface\\AddOns\\DFFriendlyNameplates\\Media\\border.tga",
        edgeSize = 12,
        tileSize = 0,
        insets = { left = 2.5, right = 2.5, top = 2.5, bottom = 2.5 }
    })
    btn:SetBackdropColor(0.12, 0.12, 0.18, 0.8)
    btn:SetBackdropBorderColor(0.3, 0.3, 0.4, 0.6)

    btn.name = name

    local textMap = {
        ["Nameplates"] = "Nameplates",
        ["WorldText"] = "World Text",
        ["Extended"] = "Extended",
    }

    btn.text = HttpsxLib:CreateText(btn, textMap[name] or name, "CENTER", btn, "CENTER", 0, 0, 11.5, { 0.9, 0.8, 0.6 },
        "")

    btn.activeIndicator = btn:CreateTexture(nil, "OVERLAY")
    btn.activeIndicator:SetSize(89, 3)
    btn.activeIndicator:SetPoint("BOTTOM", btn, "BOTTOM", 0, 0)
    btn.activeIndicator:SetTexture("Interface\\AddOns\\DFFriendlyNameplates\\Media\\Textures\\WHITE8x8")
    btn.activeIndicator:SetVertexColor(0.8, 0.6, 0.2, 0)
    btn.activeIndicator:Hide()

    btn:SetScript("OnEnter", function()
        if self.activeTab ~= btn then
            btn:SetBackdropColor(0.18, 0.18, 0.25, 0.9)
            btn:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.8)
            btn.text:SetTextColor(1, 0.9, 0.7)
        end
    end)

    btn:SetScript("OnLeave", function()
        if self.activeTab ~= btn then
            btn:SetBackdropColor(0.12, 0.12, 0.18, 0.8)
            btn:SetBackdropBorderColor(0.3, 0.3, 0.4, 0.6)
            btn.text:SetTextColor(0.9, 0.8, 0.6)
        end
    end)

    btn:SetScript("OnClick", function()
        self:SwitchTab(name)
        self:SetActiveTab(btn)
    end)

    --table.insert(self.tabButtons, btn)
    self.tabButtons[index] = btn

    return DFFNamePlates:AddTabFrame(name, module)
end

function DFFNamePlates:IterateMediaData(mediaType)
    local mediaTable = {}
    local keys = {}
    if LibStub then
        local loaded, media = pcall(LibStub, "LibSharedMedia-3.0")
        if loaded and media then
            mediaTable = media:HashTable(mediaType)
        end
    end
    for name in pairs(mediaTable) do
        table.insert(keys, name)
    end
    table.sort(keys)
    local i = 0
    return function()
        i = i + 1
        local key = keys[i]
        if key then
            return key, mediaTable[key]
        end
    end
end

function DFFNamePlates:CreateMainUI()
    local f = CreateFrame("Frame", "DFFNamePlatesMainFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    f:SetSize(330, 480)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    table.insert(UISpecialFrames, f:GetName())

    f:SetBackdrop({
        bgFile = "Interface\\Addons\\DFFriendlyNameplates\\Media\\Textures\\WHITE8x8",
        edgeFile = "Interface\\Addons\\DFFriendlyNameplates\\Media\\Textures\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    f:SetBackdropColor(0.05, 0.05, 0.08, 0.98)
    f:SetBackdropBorderColor(0.4, 0.4, 0.5, 1)

    f:SetFrameStrata("HIGH")

    f.title = HttpsxLib:CreateText(f, "DF Friendly Nameplates - Midnight", "TOPLEFT", f, "TOPLEFT", 20, -15, 13,
        { 1, 0.9, 0.6 }, "OUTLINE")

    f.subtitle = HttpsxLib:CreateText(f, "Version: " .. ADDON_VERSION, "TOPLEFT", f.title, "BOTTOMLEFT", 0, -5, 11,
        { 0.7, 0.7, 0.8, 0.8 }, "")

    f.closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", -5, -5)
    f.closeButton:SetSize(24, 24)

    f.tabList = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate")
    f.tabList:SetSize(300, 35)
    f.tabList:SetPoint("TOPLEFT", 15, -60)
    f.tabList:SetBackdrop({
        bgFile = "Interface\\AddOns\\DFFriendlyNameplates\\Media\\Textures\\WHITE8X8",
        edgeFile =
        "Interface\\AddOns\\DFFriendlyNameplates\\Media\\border.tga",
        edgeSize = 12,
        tileSize = 0,
        insets = { left = 2.5, right = 2.5, top = 2.5, bottom = 2.5 }
    })
    f.tabList:SetBackdropColor(0.08, 0.08, 0.12, 0.95)
    f.tabList:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)

    f.mainContent = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate")
    f.mainContent:SetSize(300, 375)
    f.mainContent:SetPoint("TOPLEFT", 15, -95)
    f.mainContent:SetBackdrop({
        bgFile = "Interface\\AddOns\\DFFriendlyNameplates\\Media\\Textures\\WHITE8X8",
        edgeFile =
        "Interface\\AddOns\\DFFriendlyNameplates\\Media\\border.tga",
        edgeSize = 12,
        tileSize = 0,
        insets = { left = 2.5, right = 2.5, top = 2.5, bottom = 2.5 }
    })
    f.mainContent:SetBackdropColor(0.1, 0.1, 0.13, 0.97)
    f.mainContent:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)

    self.frame = f
    self.mainContent = f.mainContent
    self.tabButtons = {}

    for i, v in pairs({ "httpsxnp", "cfrn", "friendlynameplates", "dffn" }) do
        _G["SLASH_CFRN" .. i] = "/" .. v
    end

    SlashCmdList["CFRN"] = function()
        if f:IsShown() then
            f:Hide()
        else
            f:Show()
            f:SetAlpha(0)
            f:Show()
            UIFrameFadeIn(f, 0.3, 0, 1)
        end
    end
end

DFFNamePlates:CreateMainUI()

local function ApplyDefaults(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = ApplyDefaults(dst[k] or {}, v)
        else
            if dst[k] == nil then
                dst[k] = v
            end
        end
    end
    return dst
end

function DFFNamePlates:IsShowOnlyNameNPC()
    local mode = DFFriendlyNamePlates.NamePlatesSettings.showOnlyNameNpcType
    local it = DFFNamePlates.instanceType

    if mode == "dungeon" and it ~= "party" then
        return false
    end
    if mode == "raids" and it ~= "raid" then
        return false
    end
    if mode == "dungeon_raids" and it ~= "party" and it ~= "raid" then
        return false
    end

    return true
end

httpsxFriendlyNamePlates:RegisterEvent("PLAYER_LOGIN")
httpsxFriendlyNamePlates:RegisterEvent("PLAYER_ENTERING_WORLD")
httpsxFriendlyNamePlates:SetScript("OnEvent", function(s, event)
    --UIParentLoadAddOn("Blizzard_DebugTools")

    if event == "PLAYER_LOGIN" then
        for name, tab in pairs(DFFNamePlates.tabs) do
            if type(tab.module.OnLoad) == "function" then
                tab.module:OnLoad()
            end
        end

        DFFNamePlates:SwitchTab("Nameplates")
        DFFNamePlates:SetActiveTab(DFFNamePlates.tabButtons[1])

        local default_np_colors = false
        if C_AddOns.IsAddOnLoaded("Plater") or C_AddOns.IsAddOnLoaded("Platynator") or
            C_AddOns.IsAddOnLoaded("ElvUI") then
            default_np_colors = true
        end

        httpsxFriendlyNamePlates.config.default = {
            ["NamePlatesSettings"] = {
                ["enabled"] = true,
                ["showOnlyName"] = true,
                ["showOnlyNameNpc"] = true,
                ["showOnlyNameNpcType"] = "dungeon",
                ["showClassColor"] = true,
                ["customFont"] = false,
                ["fontName"] = defaultFont,
                ["fontSize"] = defaultFontSize,
                ["fontStyle"] = defaultFontFlags,
                ["hideCastBar2"] = true,
                ["showColorBySelection"] = default_np_colors,
            },
            ["WorldTextSettings"] = {
                ["enabled"] = false,
                ["alwaysShow"] = false,
                ["hidePlayerGuild"] = GetCVar("UnitNamePlayerGuild") and GetCVar("UnitNamePlayerGuild") == "0" or false,
                ["hidePlayerTitle"] = GetCVar("UnitNamePlayerPVPTitle") and GetCVar("UnitNamePlayerPVPTitle") == "0" or
                    false,
                ["worldTextSize"] = GetCVar("WorldTextMinSize") or DFFNamePlates.DEFAULT_WORLD_TEXT_SIZE,
                ["worldTextAlpha"] = GetCVar("WorldTextMinAlpha_v2") or DFFNamePlates.DEFAULT_WORLD_TEXT_ALPHA,
            },
            ["ExtendedSettings"] = {
                ["hideInOpenWorld"] = false,
            },
            ["Settings"] = {
                ["version"] = CONFIG_VERSION,
            },
        }

        if not DFFriendlyNamePlates
            or not DFFriendlyNamePlates.NamePlatesSettings
            or not DFFriendlyNamePlates.WorldTextSettings
            or not DFFriendlyNamePlates.Settings
            or DFFriendlyNamePlates.Settings.version ~= CONFIG_VERSION
        then
            local config = CopyTable(httpsxFriendlyNamePlates.config.default)
            if not DFFriendlyNamePlates then
                DFFriendlyNamePlates = {}
            end
            DFFriendlyNamePlates = ApplyDefaults(DFFriendlyNamePlates, config)
            DFFriendlyNamePlates.Settings.version = CONFIG_VERSION
        end


        DFFNamePlates.settings.NamePlatesSettings["showOnlyName"]:SetChecked(DFFriendlyNamePlates.NamePlatesSettings
            ["showOnlyName"])
        DFFNamePlates.settings.NamePlatesSettings["showClassColor"]:SetChecked(DFFriendlyNamePlates.NamePlatesSettings
            ["showClassColor"])
        DFFNamePlates.settings.NamePlatesSettings["customFont"]:SetChecked(DFFriendlyNamePlates.NamePlatesSettings
            ["customFont"])
        DFFNamePlates.settings.NamePlatesSettings["fontName"]:SetValue(DFFriendlyNamePlates.NamePlatesSettings
            ["fontName"])
        DFFNamePlates.settings.NamePlatesSettings["fontSize"]:SetValue(DFFriendlyNamePlates.NamePlatesSettings
            ["fontSize"])
        DFFNamePlates.settings.NamePlatesSettings["fontStyle"]:SetValue(DFFriendlyNamePlates.NamePlatesSettings
            ["fontStyle"])
        DFFNamePlates.settings.NamePlatesSettings["enabled"]:SetChecked(DFFriendlyNamePlates.NamePlatesSettings
            ["enabled"])
        DFFNamePlates.settings.NamePlatesSettings["hideCastBar2"]:SetChecked(DFFriendlyNamePlates.NamePlatesSettings
            ["hideCastBar2"])

        DFFNamePlates.settings.WorldTextSettings["enabled"]:SetChecked(DFFriendlyNamePlates.WorldTextSettings["enabled"])
        DFFNamePlates.settings.WorldTextSettings["alwaysShow"]:SetChecked(DFFriendlyNamePlates.WorldTextSettings
            ["alwaysShow"])
        DFFNamePlates.settings.WorldTextSettings["worldTextSize"]:SetValue(DFFriendlyNamePlates.WorldTextSettings
            ["worldTextSize"])
        DFFNamePlates.settings.WorldTextSettings["worldTextAlpha"]:SetValue(DFFriendlyNamePlates.WorldTextSettings
            ["worldTextAlpha"])
        DFFNamePlates.settings.WorldTextSettings["hidePlayerGuild"]:SetChecked(DFFriendlyNamePlates.WorldTextSettings
            ["hidePlayerGuild"])
        DFFNamePlates.settings.WorldTextSettings["hidePlayerTitle"]:SetChecked(DFFriendlyNamePlates.WorldTextSettings
            ["hidePlayerTitle"])
        DFFNamePlates.settings.NamePlatesSettings["showOnlyNameNpc"]:SetChecked(DFFriendlyNamePlates.NamePlatesSettings
            ["showOnlyNameNpc"])
        DFFNamePlates.settings.NamePlatesSettings["showOnlyNameNpcType"]:SetValue(DFFriendlyNamePlates
            .NamePlatesSettings
            ["showOnlyNameNpcType"])
        DFFNamePlates.settings.NamePlatesSettings["showColorBySelection"]:SetChecked(DFFriendlyNamePlates
            .NamePlatesSettings
            ["showColorBySelection"])

        DFFNamePlates.settings.ExtendedSettings["hideInOpenWorld"]:SetChecked(DFFriendlyNamePlates.ExtendedSettings
            ["hideInOpenWorld"])



        --nameplates
        if DFFriendlyNamePlates.NamePlatesSettings["enabled"] then
            SetCVar("nameplateshowfriendlyPlayers", "1");
            DFFNamePlates:SetNPSettingsEnabled(true)
        else
            SetCVar("nameplateshowfriendlyPlayers", "0");
            DFFNamePlates:SetNPSettingsEnabled(false)
        end

        if DFFriendlyNamePlates.NamePlatesSettings["showOnlyName"] then
            SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", true)
        end
        if DFFriendlyNamePlates.NamePlatesSettings["showClassColor"] then
            SetCVar("nameplateUseClassColorForFriendlyPlayerUnitNames", true)
        end
        if DFFriendlyNamePlates.NamePlatesSettings["customFont"] then
            DFFNamePlates:SetFontSettingsEnabled(true)
            DFFNamePlates:UpdateFont()
        else
            DFFNamePlates:SetFontSettingsEnabled(false)
        end

        hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateSize", function(self)
            if not DFFriendlyNamePlates.NamePlatesSettings["customFont"] then return end
            DFFNamePlates:forceUpdateFont(true)
        end)

        hooksecurefunc(NamePlateUnitFrameMixin, "OnUnitSet", function(self)
            if not self:IsPlayer() and DFFriendlyNamePlates.NamePlatesSettings["showOnlyNameNpc"] then
                if DFFNamePlates:IsShowOnlyNameNPC() then
                    TableUtil.TrySet(self, "showOnlyName")
                end
            end
            --for allign name, mark in center for any forbidden nameplate (Only npc?)
        end)


        hooksecurefunc(NamePlateUnitFrameMixin, "UpdateNameClassColor", function(self)
            local np = C_NamePlate.GetNamePlateForUnit(self.unit)
            if not np then
                if DFFriendlyNamePlates.NamePlatesSettings["showColorBySelection"] then
                    TableUtil.TrySet(self.optionTable, "colorNameBySelection")
                end

                if DFFriendlyNamePlates.NamePlatesSettings["hideCastBar2"] then
                    if ((self:IsPlayer() and not DFFriendlyNamePlates.NamePlatesSettings["showOnlyName"]) or
                            (not self:IsPlayer() and DFFriendlyNamePlates.NamePlatesSettings["showOnlyNameNpc"] and
                                DFFNamePlates:IsShowOnlyNameNPC())) then
                        TableUtil.TrySet(self.castBar, "showOnlyName")
                        TableUtil.TrySet(self.castBar, "widgetsOnly")
                    end
                end

                if DFFriendlyNamePlates.NamePlatesSettings["showOnlyNameNpc"] then
                    if not self:IsPlayer() and DFFNamePlates:IsShowOnlyNameNPC() then
                        TableUtil.TrySet(self.HealthBarsContainer.healthBar, "showOnlyName")
                    end
                end
            end
        end)

        hooksecurefunc(NamePlateDriverFrame, "OnNamePlateAdded", function(self, namePlateUnitToken)
            if not DFFriendlyNamePlates.NamePlatesSettings["customFont"] then return end
            if not namePlateUnitToken:match("^nameplate") then return end
            local np = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken)
            if not np then
                DFFNamePlates:forceUpdateFont(false)
                -- print("player/forbiddenNP -> forceupdatefont")
            else
                DFFNamePlates:UpdateFontFrame(np.UnitFrame.name)
            end
        end)
        --world text

        if DFFriendlyNamePlates.WorldTextSettings["enabled"]
            or DFFriendlyNamePlates.WorldTextSettings["alwaysShow"] then
            SetCVar("WorldTextMinSize", DFFriendlyNamePlates.WorldTextSettings["worldTextSize"]);
            SetCVar("WorldTextMinAlpha_v2", DFFriendlyNamePlates.WorldTextSettings["worldTextAlpha"]);
        else
            SetCVar("WorldTextMinSize", DFFNamePlates.DEFAULT_WORLD_TEXT_SIZE);
            SetCVar("WorldTextMinAlpha_v2", DFFNamePlates.DEFAULT_WORLD_TEXT_ALPHA);
        end

        if DFFriendlyNamePlates.WorldTextSettings["hidePlayerGuild"] then
            SetCVar("UnitNamePlayerGuild", "0");
        else
            SetCVar("UnitNamePlayerGuild", "1");
        end

        if DFFriendlyNamePlates.WorldTextSettings["hidePlayerTitle"] then
            SetCVar("UnitNamePlayerPVPTitle", "0");
        else
            SetCVar("UnitNamePlayerPVPTitle", "1");
        end

        --extended
        DFFNamePlates.settings.ExtendedSettings["blizzardSize"]:SetValue(tonumber(GetCVar("nameplateSize")))
        DFFNamePlates.settings.ExtendedSettings["blizzardStyle"]:SetValue(tostring(GetCVar("nameplateStyle")))

        local needHideCastBar = DFFriendlyNamePlates.NamePlatesSettings["hideCastBar2"];
        if needHideCastBar then
            --httpsxFriendlyNamePlates.hideCastBar:RegisterEvent("NAME_PLATE_UNIT_ADDED")
            --httpsxFriendlyNamePlates.hideCastBar:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED")
            --httpsxFriendlyNamePlates.hideCastBar:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
            --httpsxFriendlyNamePlates.hideCastBar:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_REMOVED")
        end

        httpsxFriendlyNamePlates:UnregisterEvent("PLAYER_LOGIN");
    elseif event == "PLAYER_ENTERING_WORLD" then
        DFFNamePlates.instanceType = select(2, IsInInstance())
        if DFFriendlyNamePlates.ExtendedSettings["hideInOpenWorld"] then
            if DFFriendlyNamePlates.NamePlatesSettings["enabled"] then
                if DFFNamePlates.instanceType == "none" then
                    SetCVar("nameplateshowfriendlyPlayers", "0")
                else
                    SetCVar("nameplateshowfriendlyPlayers", "1")
                end
            end
        else
            if GetCVar("nameplateshowfriendlyPlayers") == "0" and DFFriendlyNamePlates.NamePlatesSettings["enabled"] then
                SetCVar("nameplateshowfriendlyPlayers", "1")
            end
        end
    end
end)

httpsxFriendlyNamePlates.hideCastBar:SetScript("OnEvent", function()
    if not DFFriendlyNamePlates.NamePlatesSettings["hideCastBar2"] then return end
    if not DFFriendlyNamePlates.NamePlatesSettings["enabled"] then return end

    for _, frame in pairs(C_NamePlate.GetNamePlates(true)) do
        if frame.unitFrameTemplate == "ForbiddenNamePlateUnitFrameTemplate" then
            TableUtil.TrySet(frame.UnitFrame.castBar, "showOnlyName")
        else
            frame.UnitFrame.castBar:SetShowOnlyName(false)
        end
    end
end)
