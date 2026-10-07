--=====================================================================================
-- RGX | Simple Quest Plates! - options_core.lua

-- Author: DonnieDice
-- Description: Options panel — built on RGXUI:CreateOptionsPanel
--=====================================================================================

local addonName, SQP = ...
local SQPSettings = SQP.db.global

SQP.SECTION_COLOR = {0.345, 0.745, 0.506}

function SQP:CreateOptionsPanel()
    if self.optionsPanel then
        return self.optionsPanel
    end

    local RGX = _G.RGXFramework

    -- One-time font designation for this addon (elements, buttons, and text
    -- all render through RGXFonts:GetDefault()).
    local Fonts = _G.RGXFonts
    if RGX and type(RGX.SetHighlightColor) == "function" then
        pcall(function() RGX:SetHighlightColor({ 0.345, 0.745, 0.506 }, { 0.737, 0.435, 0.659 }) end)
    end
    if Fonts and type(Fonts.SetDefault) == "function" then
        pcall(function()
            Fonts:SetDefault("FrizQuadrata")
        end)
    end
    local UI = RGX and RGX:GetUI() or _G.RGXUI
    if not UI then
        print("|cFFFF4444[SQP] RGXUI not available — options panel cannot be created.|r")
        return
    end

    -- SQP brand green (#58be81) on this addon's UI only. Hardcoded: core.lua
    -- also writes SQP.SECTION_COLOR ("RGX Blue") and load order decides who
    -- survives, so do not read it at runtime.
    local BrandTheme = { primary = { 0.345, 0.745, 0.506 }, accent = { 0.737, 0.435, 0.659 } }
    SQP.optionsTheme = BrandTheme
    local Design = _G.RGXDesign
    local function WithBrand(fn)
        return function(...)
            local args = { ... }
            if Design and Design.WithTheme then
                local result
                Design:WithTheme(BrandTheme, function() result = fn(unpack(args)) end)
                return result
            end
            return fn(...)
        end
    end

    local function Build()
        return UI:CreateOptionsPanel({
        addonName    = addonName,
        theme        = BrandTheme,
        title        = SQP.NAME,
        sidebarTitle = (SQP.NAME:gsub("%s*%b()", "")),
        subtitle     = "Quest tracking overlay for enemy nameplates",
        author       = SQP.AUTHOR or "DonnieDice",
        website      = "|cff7289daDiscord:|r |cffffd700discord.gg/N7kdKAHVVF|r",
        brand        = "|cff8b4b5cRGX|r |cffffd700Mods|r",
        icon         = SQP.ICON_TEXTURE,
        openInSettings = true,
        registerInSettings = true,
        closeButton = false,
        height = 680,
        bannerHeight = 84,
        banner       = WithBrand(function(frame)
            SQP.previewFrame = SQP:CreatePreviewSection(frame)
        end),
        tabs = {
            { text = "Global", content = WithBrand(function(f) SQP:CreateGlobalOptions(f) end),
              onSelect = function()
                  if SQP.optionControls and SQP.optionControls.generalPager then
                      SQP.optionControls.generalPager:SetPage(1)
                  end
                  if SQP.previewFrame and SQP.previewFrame.clearTypeSelection then
                      SQP.previewFrame.clearTypeSelection()
                  end
              end },
            { text = "Animation", content = WithBrand(function(f) SQP:CreateAnimationOptions(f) end),
              onSelect = function()
                  if SQP.previewFrame and SQP.previewFrame.clearTypeSelection then
                      SQP.previewFrame.clearTypeSelection()
                  end
              end },
            { text = "Profiles", content = WithBrand(function(f)
                if type(UI.CreateProfilesPanel) == "function" then
                    UI:CreateProfilesPanel(f, {
                        db = SQP.db,
                        title = "Profiles",
                        icon = SQP.ICON_TEXTURE,
                        description = "",
                        createFromCurrent = true,
                        pagedPresets = true,
                        height = 176,
                        presetsPerPage = 6,
                        presets = {
                            { name = "Classic",   description = "Floating quest icons",        mode = "icon" },
                            { name = "Text Mode", description = "Counts only, no backgrounds", mode = "text" },
                            { name = "Coin",      description = "Client-native coin chip",        mode = "chip" },
                            { name = "Future Preset 1", disabled = true },
                            { name = "Future Preset 2", disabled = true },
                            { name = "Future Preset 3", disabled = true },
                            { name = "Future Preset 4", disabled = true },
                            { name = "Future Preset 5", disabled = true },
                            { name = "Future Preset 6", disabled = true },
                            { name = "Future Preset 7", disabled = true },
                            { name = "Future Preset 8", disabled = true },
                            { name = "Future Preset 9", disabled = true },
                        },
                        onPreset = function(preset)
                            if preset and preset.mode then
                                SQP:ApplyGlobalDisplayStyle(preset.mode)
                            end
                        end,
                    })
                else
                    local label = UI:CreateLabel(f, { text = "Profiles need the RGX-Framework beta. Enable its beta channel in your addon manager.", width = 500 })
                    label:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -8)
                end
            end), onSelect = function()
                if SQP.previewFrame and SQP.previewFrame.clearTypeSelection then SQP.previewFrame.clearTypeSelection() end
            end },
        },
        })
    end

    if Design and Design.WithTheme then
        Design:WithTheme(BrandTheme, function() self.optionsPanel = Build() end)
    else
        self.optionsPanel = Build()
    end

    return self.optionsPanel
end

function SQP:OpenOptions()
    if InCombatLockdown() then
        self:PrintMessage(self.L["ERROR_COMBAT_LOCKDOWN"] or "Cannot open options during combat.")
        return
    end
    if not self.optionsPanel then
        self:CreateOptionsPanel()
    end
    if self.optionsPanel then self.optionsPanel:Open() end
end

function SQP:ToggleOptions()
    if InCombatLockdown() then
        self:PrintMessage(self.L["ERROR_COMBAT_LOCKDOWN"] or "Cannot open options during combat.")
        return
    end
    if not self.optionsPanel then self:CreateOptionsPanel() end
    if self.optionsPanel then self.optionsPanel:Toggle() end
end

StaticPopupDialogs["SQP_RESET_CONFIRM"] = {
    text = "|cff58be81Simple Quest Plates!|r\n\nAre you sure you want to reset all settings to defaults?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        SQP:ResetSettings()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
