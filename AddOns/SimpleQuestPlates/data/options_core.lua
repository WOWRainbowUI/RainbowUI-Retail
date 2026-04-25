--=====================================================================================
-- RGX | Simple Quest Plates! - options_core.lua

-- Author: DonnieDice
-- Description: Options panel — built on RGXUI:CreateOptionsPanel
--=====================================================================================

local addonName, SQP = ...

SQP.SECTION_COLOR = {0.345, 0.745, 0.506}

function SQP:CreateOptionsPanel()
    local UI = _G.RGXUI
    if not UI then
        print("|cFFFF4444[SQP] RGXUI not available — options panel cannot be created.|r")
        return
    end

    self.optionsPanel = UI:CreateOptionsPanel({
        addonName    = "SimpleQuestPlates",
        title        = "|cff58be81S|rimple |cff58be81Q|ruest |cff58be81P|rlates|cff58be81!|r",
        subtitle     = "Quest tracking overlay for enemy nameplates",
        icon         = "Interface\\AddOns\\SimpleQuestPlates\\media\\icon",
        bannerHeight = 88,
        banner       = function(frame)
            SQP.previewFrame = SQP:CreatePreviewSection(frame)
        end,
        tabs = {
            { text = "General", content = function(f) SQP:CreateGlobalOptions(f) end },
            { text = "Kill",    content = function(f) SQP:CreateKillOptions(f) end,
              onSelect = function() if SQP.previewFrame then SQP.previewFrame.activateKillMode() end end },
            { text = "Loot",   content = function(f) SQP:CreateLootOptions(f) end,
              onSelect = function() if SQP.previewFrame then SQP.previewFrame.activateLootMode() end end },
            { text = "Percent", content = function(f) SQP:CreatePercentOptions(f) end,
              onSelect = function() if SQP.previewFrame then SQP.previewFrame.activatePercentMode() end end },
            { text = "About",  content = function(f) SQP:CreateAboutSection(f) end },
        },
    })
end

function SQP:OpenOptions()
    if InCombatLockdown() then
        self:PrintMessage(self.L["ERROR_COMBAT_LOCKDOWN"] or "Cannot open options during combat.")
        return
    end
    if self.optionsPanel then self.optionsPanel:Open() end
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
