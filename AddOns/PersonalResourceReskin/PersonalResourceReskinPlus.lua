
local ADDON_NAME = "PersonalResourceReskinPlus"

-- Guarded library lookups
local LibStub = _G.LibStub
local AceAddon = LibStub and LibStub("AceAddon-3.0", true)
local AceDB = LibStub and LibStub("AceDB-3.0", true)
local AceConfig = LibStub and LibStub("AceConfig-3.0", true)
local AceConfigDialog = LibStub and LibStub("AceConfigDialog-3.0", true)
local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)

if not AceAddon or not AceDB or not AceConfig or not AceConfigDialog or not LSM then
    print("|cffff0000[" .. ADDON_NAME .. "]|r 缺少 Ace3 或 LibSharedMedia 函式庫，請重新安裝。")
    return
end

local PRR = AceAddon:NewAddon(ADDON_NAME, "AceConsole-3.0")
_G[ADDON_NAME] = PRR

-- Defaults
local defaults = {
    profile = {
        texture = "White8x8",
        font = "Friz Quadrata TT",
        fontFlags = "OUTLINE",
        fontColor = {1, 1, 1, 1},
        powerBgColor = {0, 0, 0, 0.5},
        healthBgColor = {0, 0, 0, 0.5},
        healthBarColor = {0.2, 0.8, 0.2, 1},
        useClassColor = false,
        width = 220,
        frameWidth = 220,
        healthTextSize = 14,
        resourceYOffset = 14,
        resourceXOffset = 0,
        altPowerBarX = 0,
        altPowerBarY = 0,
        trackedSpells = {1225789, 1217607, 1227702},
        trackedEnabled = true,
        trackedSpacing = 40,
        showCooldown = true,
    }
}

local function GetProfile()
    return PRR.db and PRR.db.profile or defaults.profile
end

-- API readiness check
local function ApiReady()
    if type(UnitAura) == "function" and (type(GetSpellInfo) == "function" or (C_Spell and type(C_Spell.GetSpellInfo) == "function")) then
        return true
    end
    return false
end

-- Robust GetSpellInfo wrapper
local function GetSpellInfoSafe(idOrName)
    if not idOrName then return nil, nil, nil end
    if type(GetSpellInfo) == "function" then
        local a, b, c = GetSpellInfo(idOrName)
        if type(a) == "table" then
            local t = a
            local name = t.name or t.spellName or tostring(idOrName)
            local icon = t.icon or t.iconFileID or c
            return name, b, icon
        end
        return a, b, c
    end
    if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
        local ok, a, b, c = pcall(C_Spell.GetSpellInfo, idOrName)
        if not ok then return nil, nil, nil end
        if type(a) == "table" then
            local t = a
            local name = t.name or t.spellName or tostring(idOrName)
            local icon = t.icon or t.iconFileID or c
            return name, b, icon
        end
        return a, b, c
    end
    return nil, nil, nil
end

local function GetSpellChargesSafe(id)
    if type(GetSpellCharges) == "function" then
        local charges, maxCharges = GetSpellCharges(id)
        if charges ~= nil then return charges, maxCharges end
    end
    return nil
end

local function GetSpellCooldownSafe(id)
    if type(GetSpellCooldown) == "function" then
        local start, duration, enabled = GetSpellCooldown(id)
        return start, duration, enabled
    end
    return nil
end

-- Aura stack reader by spellID
local function GetPlayerAuraCountBySpellID(spellID)
    if not spellID then return nil end
    if type(UnitAura) ~= "function" then return nil end

    -- Try direct lookup
    local name, icon, count = UnitAura("player", spellID)
    if name then return count or 1 end

    -- Fallback scan
    for i = 1, 40 do
        local n, ic, c, debuffType, duration, expirationTime, unitCaster, isStealable, nameplateShowPersonal, spellId =
            UnitAura("player", i)
        if not n then break end
        if spellId == spellID then
            return c or 1
        end
    end

    return nil
end

-- Reskin helpers
local function ReskinBar(bar, barType)
    if not bar then return end
    local profile = GetProfile()
    local tex = LSM:Fetch("statusbar", profile.texture) or "Interface\\TARGETINGFRAME\\UI-StatusBar"
    if bar.SetStatusBarTexture then pcall(bar.SetStatusBarTexture, bar, tex) end

    local bgColor = (barType == "power") and profile.powerBgColor or profile.healthBgColor
    if not bar.__PRR_BG then
        local bg = bar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(bar)
        bg:SetColorTexture(unpack(bgColor))
        bar.__PRR_BG = bg
    else
        bar.__PRR_BG:SetColorTexture(unpack(bgColor))
    end

    if barType == "health" and profile.useClassColor and RAID_CLASS_COLORS then
        local _, class = UnitClass("player")
        local classColor = RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1, a = 1 }
        local r, g, b, a = classColor.r, classColor.g, classColor.b, classColor.a or 1
        if bar.SetStatusBarColor then
            pcall(bar.SetStatusBarColor, bar, r, g, b, a)
        end
    end

    if not bar.__PRR_Text and bar.CreateFontString then
        local text = bar:CreateFontString(nil, "OVERLAY")
        text:SetPoint("CENTER", bar, "CENTER", 0, 0)
        bar.__PRR_Text = text
    end
    if bar.__PRR_Text then
        local fontPath = LSM:Fetch("font", profile.font) or "Fonts\\FRIZQT__.TTF"
        pcall(bar.__PRR_Text.SetFont, bar.__PRR_Text, fontPath, profile.healthTextSize or 14, profile.fontFlags ~= "NONE" and profile.fontFlags or nil)
        bar.__PRR_Text:SetTextColor(unpack(profile.fontColor or {1, 1, 1, 1}))
    end
end

local function ReskinAlternatePowerBar(bar)
    if not bar then return end
    local profile = GetProfile()
    local tex = LSM:Fetch("statusbar", profile.altTexture or profile.texture) or "Interface\\TARGETINGFRAME\\UI-StatusBar"
    if bar.SetStatusBarTexture then pcall(bar.SetStatusBarTexture, bar, tex) end
    if bar.Texture and bar.Texture.SetTexture then pcall(bar.Texture.SetTexture, bar.Texture, tex) end
    if bar.texture and bar.texture.SetTexture then pcall(bar.texture.SetTexture, bar.texture, tex) end

    if bar.background and bar.background.SetColorTexture then
        pcall(bar.background.SetColorTexture, bar.background, unpack(profile.powerBgColor or {0, 0, 0, 0.5}))
    end
    if bar.Border and bar.Border.SetTexture then
        pcall(bar.Border.SetTexture, bar.Border, nil)
    end

    if not bar.__PRR_BG then
        local bg = bar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(bar)
        bg:SetColorTexture(unpack(profile.powerBgColor or {0, 0, 0, 0.5}))
        bar.__PRR_BG = bg
    else
        bar.__PRR_BG:SetColorTexture(unpack(profile.powerBgColor or {0, 0, 0, 0.5}))
    end
end

local function MoveAlternatePowerBar()
    local profile = GetProfile()
    local prd = _G["PersonalResourceDisplayFrame"]
    local bar = prd and prd.AlternatePowerBar
    if bar and bar.ClearAllPoints and bar.SetPoint then
        bar:ClearAllPoints()
        bar:SetPoint("CENTER", UIParent, "CENTER", profile.altPowerBarX or 0, profile.altPowerBarY or 0)
    end
    if bar and bar.Border and bar.Border.ClearAllPoints and bar.Border.SetPoint then
        bar.Border:ClearAllPoints()
        bar.Border:SetPoint("CENTER", bar, "CENTER", 0, 0)
    end
end

function ApplyReskinToPRD()
    local prd = _G["PersonalResourceDisplayFrame"]
    if not prd then return end
    local profile = GetProfile()
    if prd.SetWidth and profile.frameWidth then pcall(prd.SetWidth, prd, profile.frameWidth) end

    if prd.PowerBar then
        if profile.width then pcall(prd.PowerBar.SetWidth, prd.PowerBar, profile.width) end
        ReskinBar(prd.PowerBar, "power")
    end

    local healthBar = nil
    if prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
        if prd.HealthBarsContainer.healthBar.healthBar then
            healthBar = prd.HealthBarsContainer.healthBar.healthBar
        else
            healthBar = prd.HealthBarsContainer.healthBar
        end
    end
    if healthBar then ReskinBar(healthBar, "health") end

    if prd.AlternatePowerBar then
        ReskinAlternatePowerBar(prd.AlternatePowerBar)
        -- EBONMIGHT text logic removed by user request
    end

    MoveAlternatePowerBar()
end

-- Tracked display
local Tracked = {
    spellIDs = {},
    frames = {},
}

local function EnsureParentBar()
    local prd = _G["PersonalResourceDisplayFrame"]
    if not prd then return nil end
    return prd.AlternatePowerBar
end

local function EnsureTextAppearance(f)
    if not f or not f.text then return end
    local profile = GetProfile()
    local fontPath = LSM:Fetch("font", profile.font) or "Fonts\\FRIZQT__.TTF"
    pcall(f.text.SetFont, f.text, fontPath, profile.healthTextSize or 12, profile.fontFlags ~= "NONE" and profile.fontFlags or nil)
    f.text:ClearAllPoints()
    f.text:SetPoint("CENTER", f, "CENTER", 0, 0)
    f.text:SetJustifyH("CENTER")
    f.text:SetDrawLayer("OVERLAY", 2)
    local r, g, b, a = unpack(profile.fontColor or {1, 1, 1, 1})
    f.text:SetTextColor(r, g, b, a or 1)
    f.text:SetAlpha(a or 1)
    if f.cdText then
        pcall(f.cdText.SetFont, f.cdText, fontPath, 10, profile.fontFlags ~= "NONE" and profile.fontFlags or nil)
        f.cdText:SetDrawLayer("OVERLAY", 3)
        f.cdText:SetJustifyH("CENTER")
        f.cdText:SetAlpha(1)
    end
end

local function FormatCooldown(start, duration)
    if not start or start == 0 or not duration or duration == 0 then return nil end
    local remaining = start + duration - GetTime()
    if remaining <= 0 then return nil end
    if remaining >= 60 then
        return string.format("%dm", math.floor(remaining / 60 + 0.5))
    else
        return string.format("%ds", math.floor(remaining + 0.5))
    end
end

function Tracked:CreateOrUpdateFrames()
    local bar = EnsureParentBar()
    if not bar then return end
    local profile = GetProfile()
    self.spellIDs = profile.trackedSpells or self.spellIDs

    for idx, id in ipairs(self.spellIDs) do
        if not id then break end
        local f = self.frames[id]
        if not f then
            f = CreateFrame("Frame", nil, bar)
            f:SetSize(28, 28)
            f.icon = f:CreateTexture(nil, "ARTWORK")
            f.icon:SetAllPoints(f)
            f.text = f:CreateFontString(nil, "OVERLAY")
            f.text:SetPoint("CENTER", f, "CENTER", 0, 0)
            f.cdText = f:CreateFontString(nil, "OVERLAY")
            f.cdText:SetPoint("TOP", f, "TOP", 0, 2)
            f.cdText:SetTextColor(1, 0.8, 0, 1)
            f:Hide()
            self.frames[id] = f
        end

        EnsureTextAppearance(f)

        local name, _, tex = GetSpellInfoSafe(id)
        if tex and f.icon.SetTexture then
            pcall(f.icon.SetTexture, f.icon, tex)
        else
            f.icon:SetTexture(nil)
        end

        local xOffset = (idx - 1) * (profile.trackedSpacing or 40) + (profile.resourceXOffset or 0)
        local yOffset = (profile.resourceYOffset or 14) + 6
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", xOffset, yOffset)
    end
end

function Tracked:UpdateAll()
    if not GetProfile().trackedEnabled then
        for _, f in pairs(self.frames) do if f then f:Hide() end end
        return
    end

    if not ApiReady() then
        C_Timer.After(0.5, function()
            if ApiReady() then
                Tracked:CreateOrUpdateFrames()
                Tracked:UpdateAll()
            end
        end)
        return
    end

    for _, id in ipairs(self.spellIDs) do
        local f = self.frames[id]
        if not f then
            self:CreateOrUpdateFrames()
            f = self.frames[id]
            if not f then return end
        end

        EnsureTextAppearance(f)
        local shown = false

        local charges, maxCharges = GetSpellChargesSafe(id)
        if charges ~= nil then
            if charges > 0 then
                f.text:SetText(charges .. (maxCharges and ("/" .. maxCharges) or ""))
                f.text:Show()
                shown = true
            else
                f.text:SetText("")
                f.text:Hide()
            end
        else
            local count = GetPlayerAuraCountBySpellID(id)
            if count and count > 0 then
                f.text:SetText(tostring(count))
                f.text:Show()
                shown = true
            else
                f.text:SetText("")
                f.text:Hide()
            end
        end

        if GetProfile().showCooldown then
            local start, duration, enabled = GetSpellCooldownSafe(id)
            local cdText = FormatCooldown(start, duration)
            if cdText then
                f.cdText:SetText(cdText)
                f.cdText:Show()
                shown = true
            else
                f.cdText:SetText("")
                f.cdText:Hide()
            end
        else
            f.cdText:SetText("")
            f.cdText:Hide()
        end

        if shown then
            f:Show()
        else
            f:Hide()
        end
    end
end

-- Events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")

eventFrame:SetScript("OnEvent", function(_, event, arg1, ...)
    if event == "UNIT_AURA" and arg1 ~= "player" then return end
    C_Timer.After(0.05, function()
        ApplyReskinToPRD()
        Tracked:CreateOrUpdateFrames()
        Tracked:UpdateAll()
    end)
end)

-- Options
local options = {
    name = ADDON_NAME,
    type = "group",
    args = {
        general = {
            name = "一般",
            type = "group",
            inline = true,
            args = {
                texture = {
                    name = "資源條材質",
                    type = "select",
                    values = function() return LSM:HashTable("statusbar") end,
                    get = function() return GetProfile().texture end,
                    set = function(_, val) GetProfile().texture = val; ApplyReskinToPRD() end,
                    dialogControl = "Dropdown",
                },
                font = {
                    name = "字型",
                    type = "select",
                    values = function() return LSM:HashTable("font") end,
                    get = function() return GetProfile().font end,
                    set = function(_, val) GetProfile().font = val; Tracked:CreateOrUpdateFrames(); Tracked:UpdateAll() end,
                    dialogControl = "Dropdown",
                },
                fontColor = {
                    name = "字型顏色",
                    type = "color",
                    hasAlpha = true,
                    get = function() return unpack(GetProfile().fontColor) end,
                    set = function(_, r, g, b, a) GetProfile().fontColor = {r, g, b, a}; Tracked:CreateOrUpdateFrames(); Tracked:UpdateAll() end,
                },
            },
        },
        move = {
            name = "替代能量條",
            type = "group",
            inline = true,
            args = {
                altTexture = {
                    name = "替代能量條材質",
                    type = "select",
                    values = function() return LSM:HashTable("statusbar") end,
                    get = function() return GetProfile().altTexture or GetProfile().texture end,
                    set = function(_, val) GetProfile().altTexture = val; ApplyReskinToPRD() end,
                    dialogControl = "Dropdown",
                },
                altX = {
                    name = "水平偏移",
                    type = "range",
                    min = -1000,
                    max = 1000,
                    step = 1,
                    get = function() return GetProfile().altPowerBarX or 0 end,
                    set = function(_, val) GetProfile().altPowerBarX = val; MoveAlternatePowerBar() end,
                },
                altY = {
                    name = "垂直偏移",
                    type = "range",
                    min = -1000,
                    max = 1000,
                    step = 1,
                    get = function() return GetProfile().altPowerBarY or 0 end,
                    set = function(_, val) GetProfile().altPowerBarY = val; MoveAlternatePowerBar() end,
                },
            },
        },
        tracked = {
            name = "追蹤法術",
            type = "group",
            inline = true,
            args = {
                enabled = {
                    name = "啟用追蹤",
                    type = "toggle",
                    get = function() return GetProfile().trackedEnabled end,
                    set = function(_, val) GetProfile().trackedEnabled = val; Tracked:UpdateAll() end,
                },
                spacing = {
                    name = "間距",
                    type = "range",
                    min = 10,
                    max = 120,
                    step = 1,
                    get = function() return GetProfile().trackedSpacing or 40 end,
                    set = function(_, val) GetProfile().trackedSpacing = val; Tracked:CreateOrUpdateFrames() end,
                },
                showCooldown = {
                    name = "顯示冷卻文字",
                    type = "toggle",
                    get = function() return GetProfile().showCooldown end,
                    set = function(_, val) GetProfile().showCooldown = val; Tracked:UpdateAll() end,
                },
                list = {
                    name = "法術 ID 列表",
                    desc = "以逗號分隔要追蹤的法術 ID（例如 1225789,1217607）",
                    type = "input",
                    get = function() local t = GetProfile().trackedSpells or {} return table.concat(t, ",") end,
                    set = function(_, val) local t = {} for id in string.gmatch(val, "%d+") do table.insert(t, tonumber(id)) end GetProfile().trackedSpells = t Tracked:CreateOrUpdateFrames() Tracked:UpdateAll() end,
                    width = "full",
                },
            },
        },
    },
}

function PRR:OnInitialize()
    self.db = AceDB:New(ADDON_NAME .. "DB", defaults, true)
    AceConfig:RegisterOptionsTable(ADDON_NAME, options)
    AceConfigDialog:AddToBlizOptions(ADDON_NAME, ADDON_NAME)
end

function PRR:OnEnable()
    C_Timer.After(0.1, function()
        ApplyReskinToPRD()
        Tracked:CreateOrUpdateFrames()
        Tracked:UpdateAll()
    end)

    local prd = _G["PersonalResourceDisplayFrame"]
    if prd and prd.AlternatePowerBar and not prd.AlternatePowerBar.__PRR_Hooked then
        prd.AlternatePowerBar:HookScript("OnShow", function()
            ApplyReskinToPRD()
            Tracked:CreateOrUpdateFrames()
            Tracked:UpdateAll()
        end)
        prd.AlternatePowerBar.__PRR_Hooked = true
    end
end

-- Safe slash handler
SLASH_PRR1 = "/prr"
SlashCmdList["PRR"] = function(msg)
    msg = (msg or ""):lower()
    if msg == "test" then
        ApplyReskinToPRD()
        Tracked:CreateOrUpdateFrames()
        Tracked:UpdateAll()
        -- print("[" .. ADDON_NAME .. "] Applied reskin and updated tracked auras.")
        return
    end

    if type(InterfaceOptionsFrame_OpenToCategory) == "function" then
        pcall(InterfaceOptionsFrame_OpenToCategory, ADDON_NAME)
        return
    end

    if AceConfigDialog and type(AceConfigDialog.Open) == "function" then
        pcall(AceConfigDialog.Open, AceConfigDialog, ADDON_NAME)
        return
    end

    print("[" .. ADDON_NAME .. "] 介面選項目前無法使用。請嘗試輸入 /reload，或手動開啟 介面選項。")
end

-- Debug slash
-- Debug slash command removed to prevent chat spam
