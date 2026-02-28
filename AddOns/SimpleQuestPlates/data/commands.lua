--=====================================================================================
-- RGX | Simple Quest Plates! - commands.lua

-- Author: DonnieDice
-- Description: Slash commands and chat interface
--=====================================================================================

local addonName, SQP = ...
local format = string.format
local tonumber = tonumber

-- Constants
local CHAT_COMMAND = "sqp"

-- Show help information
function SQP:ShowHelp()
    self:PrintMessage(self.L["CMD_HELP_HEADER"])
    print(self.L["CMD_HELP_TEST"])
    print(self.L["CMD_HELP_ENABLE"])
    print(self.L["CMD_HELP_DISABLE"])
    print(self.L["CMD_HELP_STATUS"])
    print(self.L["CMD_HELP_SCALE"])
    print(self.L["CMD_HELP_OFFSET"])
    print(self.L["CMD_HELP_ANCHOR"] or "  /sqp anchor <LEFT|RIGHT> - Set icon position")
    print(self.L["CMD_HELP_RESET"])
    print(self.L["CMD_HELP_OPTIONS"] or "  /sqp options - Open the options panel")
    self:PrintMessage(self.L["COMMUNITY_MESSAGE"])
end

-- Test quest detection on current nameplates
function SQP:TestQuestDetection()
    self:PrintMessage(self.L["TEST_SCANNING"])
    
    local count = 0
    for i = 1, 40 do
        local unitID = "nameplate" .. i
        if UnitExists(unitID) then
            local progressGlob = self:GetQuestProgress(unitID)
            if progressGlob then
                count = count + 1
                self:PrintMessage(format("%s: %s", UnitName(unitID), progressGlob))
            end
        end
    end
    
    if count > 0 then
        self:PrintMessage(format(self.L["TEST_FOUND_QUESTS"], count))
    else
        self:PrintMessage(self.L["TEST_NO_QUESTS"])
    end
end

-- Show current status
function SQP:ShowStatus()
    self:PrintMessage(self.L["STATUS_HEADER"])
    print(format("%s %s", self.L["STATUS_STATUS"], 
        SQPSettings.enabled and self.L["STATUS_ENABLED"] or self.L["STATUS_DISABLED"]))
    print(format(self.L["STATUS_VERSION"], self.VERSION))
    print(format(self.L["STATUS_SCALE"], SQPSettings.scale))
    print(format(self.L["STATUS_OFFSET"], SQPSettings.offsetX, SQPSettings.offsetY))
    print(format(self.L["STATUS_ANCHOR"], SQPSettings.anchor))
end

-- Set icon scale
function SQP:SetScale(scale)
    scale = tonumber(scale)
    if not scale or scale < 0.5 or scale > 2.0 then
        self:PrintMessage(self.L["ERROR_INVALID_SCALE"])
        return
    end
    
    SQPSettings.scale = scale
    self:SaveSettings()
    self:PrintMessage(format(self.L["SETTINGS_SCALE_SET"], scale))
    self:RefreshAllNameplates()
end

-- Set icon offset
function SQP:SetOffset(x, y)
    x = tonumber(x)
    y = tonumber(y)
    if not x or not y then
        self:PrintMessage(self.L["ERROR_INVALID_OFFSET"])
        return
    end
    
    SQPSettings.offsetX = x
    SQPSettings.offsetY = y
    self:SaveSettings()
    self:PrintMessage(format(self.L["SETTINGS_OFFSET_SET"], x, y))
    self:RefreshAllNameplates()
end

-- Set anchor position
function SQP:SetAnchor(anchor)
    anchor = anchor:upper()
    if anchor ~= "LEFT" and anchor ~= "RIGHT" then
        self:PrintMessage(self.L["ERROR_INVALID_ANCHOR"])
        return
    end
    
    SQPSettings.anchor = anchor
    SQPSettings.relativeTo = anchor == "LEFT" and "RIGHT" or "LEFT"
    self:SaveSettings()
    self:PrintMessage(format(self.L["SETTINGS_ANCHOR_SET"], anchor))
    self:RefreshAllNameplates()
end

-- Process slash command input
function SQP:ProcessSlashCommand(input)
    input = input:trim():lower()
    
    -- No input = open options panel
    if input == "" then
        self:OpenOptions()
    elseif input == "help" then
        self:ShowHelp()
    elseif input == "on" or input == "enable" then
        self:EnableAddon()
    elseif input == "off" or input == "disable" then
        self:DisableAddon()
    elseif input == "test" then
        self:TestQuestDetection()
    elseif input == "status" then
        self:ShowStatus()
    elseif input == "reset" then
        self:ResetSettings()
    elseif input:match("^scale%s+(.+)") then
        local scale = input:match("^scale%s+(.+)")
        self:SetScale(scale)
    elseif input:match("^offset%s+(-?%d+)%s+(-?%d+)") then
        local x, y = input:match("^offset%s+(-?%d+)%s+(-?%d+)")
        self:SetOffset(x, y)
    elseif input:match("^anchor%s+(.+)") then
        local anchor = input:match("^anchor%s+(.+)")
        self:SetAnchor(anchor)
    elseif input == "options" or input == "config" then
        self:OpenOptions()
    elseif input == "debug" then
        SQPSettings.debug = not SQPSettings.debug
        self:PrintMessage(format("Debug mode: %s", SQPSettings.debug and "ON" or "OFF"))
    elseif input == "debug target" then
        self:DebugTarget()
    elseif input == "debug nameplates" then
        self:DebugNameplates()
    else
        self:PrintMessage(self.L["ERROR_UNKNOWN_COMMAND"])
    end
end

-- Register slash commands
SLASH_SQP1 = "/" .. CHAT_COMMAND
SlashCmdList["SQP"] = function(input)
    SQP:ProcessSlashCommand(input)
end