--=====================================================================================
-- RGX | Simple Quest Plates! - options_core.lua

-- Author: DonnieDice
-- Description: Options panel — built on RGXUI:CreateOptionsPanel
--=====================================================================================

local addonName, SQP = ...
local SQPSettings = SQP.db.global

-- SQP's own brand pair (green primary, purple accent). SQP.Brand is the live pair the option pages read: the own
-- pair, or the framework's main colour while its beta global theme override is on (ResolveBrand).
SQP.OwnBrand = { primary = { 0.345, 0.745, 0.506 }, accent = { 0.737, 0.435, 0.659 } }
SQP.Brand = { primary = { 0.345, 0.745, 0.506 }, accent = { 0.737, 0.435, 0.659 } }
SQP.SECTION_COLOR = SQP.Brand.primary

-- The addon's brand, registered with the framework (2.19+): SQP's own pair, or the framework's main colour while
-- its beta global theme override is on. The options panel is built with it and redraws itself on a change.
function SQP:GetBrand()
    local D = _G.RGXDesign
    if not self.BrandObj and D and type(D.RegisterBrand) == "function" then
        self.BrandObj = D:RegisterBrand("SimpleQuestPlates", self.OwnBrand, nil)
        self.BrandObj:OnChange(function() SQP:ResolveBrand() end)
    end
    return self.BrandObj
end

-- Rewrite SQP.Brand in place from the brand (option pages read it at paint time) and return it.
function SQP:ResolveBrand()
    local brand = self:GetBrand()
    local own, live = self.OwnBrand, self.Brand
    local theme = brand and brand:Resolve() or own
    local p, a = theme.primary or own.primary, theme.accent or own.accent
    live.primary[1], live.primary[2], live.primary[3] = p[1], p[2], p[3]
    live.accent[1], live.accent[2], live.accent[3] = a[1], a[2], a[3]
    return live
end

-- "|cffRRGGBB" for the live primary, for coloured text on the option pages.
function SQP:BrandHex()
    local c = self.Brand.primary
    return string.format("|cff%02x%02x%02x", math.floor(c[1] * 255 + 0.5), math.floor(c[2] * 255 + 0.5), math.floor(c[3] * 255 + 0.5))
end

function SQP:CreateOptionsPanel()
    if self.optionsPanel then
        return self.optionsPanel
    end

    local RGX = _G.RGXFramework

    -- One-time font designation for this addon (elements, buttons, and text
    -- all render through RGXFonts:GetDefault()).
    local Fonts = _G.RGXFonts
    -- The brand pair: SQP's own, or the framework's main colour while its beta theme override is on. Scoped
    -- to SQP's own UI with WithTheme below; the framework's shared theme is never changed.
    local live = SQP:ResolveBrand()
    local PRIMARY, ACCENT = live.primary, live.accent
    if Fonts and type(Fonts.SetDefault) == "function" then
        pcall(function()
            Fonts:Register("SQPStandardText", STANDARD_TEXT_FONT, {
                displayName = "遊戲預設字體",
                category = "WoW Defaults",
            })
            Fonts:SetDefault("SQPStandardText")
        end)
    end
    local UI = RGX and RGX:GetUI() or _G.RGXUI
    if not UI then
        print("|cFFFF4444[SQP] RGXUI not available — options panel cannot be created.|r")
        return
    end

    local BrandTheme = { primary = PRIMARY, accent = ACCENT }
    SQP.optionsTheme = BrandTheme
    local Design = _G.RGXDesign
    local function WithBrand(fn)
        return function(...)
            local args = { ... }
            local brand = SQP:GetBrand()
            if brand then
                SQP:ResolveBrand()
                return brand:Build(function() return fn(unpack(args)) end)
            end
            return fn(...)
        end
    end

    local function Build()
        return UI:CreateOptionsPanel({
        addonName    = addonName,
        addonBrand   = SQP:GetBrand(),
        theme        = BrandTheme,
        title        = SQP.L["SimpleQuestPlates"],
        sidebarTitle = SQP.L["SimpleQuestPlates"],
        sidebarIcon  = false,
        subtitle     = SQP.L["Quest tracking overlay for enemy nameplates"],
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
            { text = SQP.L["Global"], content = WithBrand(function(f) SQP:CreateGlobalOptions(f) end),
              onSelect = function()
                  if SQP.optionControls and SQP.optionControls.generalPager then
                      SQP.optionControls.generalPager:SetPage(1)
                  end
                  if SQP.previewFrame and SQP.previewFrame.clearTypeSelection then
                      SQP.previewFrame.clearTypeSelection()
                  end
              end },
            { text = SQP.L["Animation"], content = WithBrand(function(f) SQP:CreateAnimationOptions(f) end),
              onSelect = function()
                  if SQP.previewFrame and SQP.previewFrame.clearTypeSelection then
                      SQP.previewFrame.clearTypeSelection()
                  end
              end },
            { text = SQP.L["Profiles"], content = WithBrand(function(f)
                if type(UI.CreateProfilesPanel) == "function" then
                    UI:CreateProfilesPanel(f, {
                        db = SQP.db,
                        title = SQP.L["Profiles"],
                        icon = SQP.ICON_TEXTURE,
                        description = "",
                        createFromCurrent = true,
                        pagedPresets = true,
                        height = 176,
                        presetsPerPage = 6,
                        presets = {
                            { name = "Classic",   description = SQP.L["Floating quest icons"],        mode = "icon" },
                            { name = "Text Mode", description = SQP.L["Counts only, no backgrounds"], mode = "text" },
                            { name = "Coin",      description = SQP.L["Client-native coin chip"],        mode = "chip" },
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
                    local label = UI:CreateLabel(f, { text = SQP.L["Profiles need the RGX-Framework beta. Enable its beta channel in your addon manager."], width = 500 })
                    label:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -8)
                end
            end), onSelect = function()
                if SQP.previewFrame and SQP.previewFrame.clearTypeSelection then SQP.previewFrame.clearTypeSelection() end
            end },
        },
        })
    end

    local brand = SQP:GetBrand()
    if brand then
        self.optionsPanel = brand:Build(Build)
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
    text = SQP.L["RESET_CONFIRM"],
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        SQP:ResetSettings()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}
