--=====================================================================================
-- RGX | Simple Quest Plates! - options_core.lua

-- Author: DonnieDice
-- Description: Options panel — built on RGXUI:CreateOptionsPanel
--=====================================================================================

local addonName, SQP = ...

SQP.SECTION_COLOR = {0.345, 0.745, 0.506}

function SQP:CreateOptionsPanel()
    if self.optionsPanel then
        return self.optionsPanel
    end

    local RGX = _G.RGXFramework
    local UI = RGX and RGX:GetUI() or _G.RGXUI
    if not UI then
        print("|cFFFF4444[SQP] RGXUI not available — options panel cannot be created.|r")
        return
    end

    self.optionsPanel = UI:CreateOptionsPanel({
        addonName    = "SimpleQuestPlates",
        title        = self.L["|cff58be81S|cffffffffimple |cff58be81Q|cffffffffuest |cff58be81P|cfffffffflates|cff58be81!|r"],
        subtitle     = self.L["Quest tracking overlay for enemy nameplates"],
        author       = SQP.AUTHOR or "DonnieDice",
        website      = "|cff7289daDiscord:|r |cffffd700discord.gg/rgxmods|r",
        brand        = "|cff8b4b5cRGX|r |cffffd700Mods|r",
        icon         = "Interface\\AddOns\\SimpleQuestPlates\\media\\logo.tga",
        openInSettings = true,
        registerInSettings = true,
        bannerHeight = 88,
        banner       = function(frame)
            SQP.previewFrame = SQP:CreatePreviewSection(frame)
        end,
        tabs = {
            { text = self.L["General"], content = function(f) SQP:CreateGlobalOptions(f) end },
            { text = self.L["Kill"],    content = function(f) SQP:CreateKillOptions(f) end,
              onSelect = function() if SQP.previewFrame then SQP.previewFrame.activateKillMode() end end },
            { text = self.L["Loot"],   content = function(f) SQP:CreateLootOptions(f) end,
              onSelect = function() if SQP.previewFrame then SQP.previewFrame.activateLootMode() end end },
            { text = self.L["Percent"], content = function(f) SQP:CreatePercentOptions(f) end,
              onSelect = function() if SQP.previewFrame then SQP.previewFrame.activatePercentMode() end end },
            { text = self.L["About"],  content = function(f) SQP:CreateAboutSection(f) end },
        },
    })

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
