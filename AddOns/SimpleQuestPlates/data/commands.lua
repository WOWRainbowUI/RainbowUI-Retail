--=====================================================================================
-- RGX | Simple Quest Plates! - commands.lua

-- Author: DonnieDice
-- Description: Slash commands and chat interface
--=====================================================================================

local addonName, SQP = ...
local format = string.format
local tonumber = tonumber
local type = type
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitName = UnitName

-- Constants
local CHAT_COMMAND = "sqp"

local function GetText(self, key, fallback)
    local value = self and self.L and self.L[key]
    if value == nil or value == "" then
        return fallback
    end
    return value
end

local function TrimInput(input)
    if type(input) ~= "string" then
        return ""
    end
    return (input:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Show help information
function SQP:ShowHelp()
    self:PrintMessage(GetText(self, "CMD_HELP_HEADER", "|cff58be81Simple Quest Plates Commands:|r"))
    print(GetText(self, "CMD_HELP_TEST", "  |cfffff569/sqp test|r - Test quest detection"))
    print(GetText(self, "CMD_HELP_ENABLE", "  |cfffff569/sqp on|r - Enable the addon"))
    print(GetText(self, "CMD_HELP_DISABLE", "  |cfffff569/sqp off|r - Disable the addon"))
    print(GetText(self, "CMD_HELP_STATUS", "  |cfffff569/sqp status|r - Show current settings"))
    print(GetText(self, "CMD_HELP_SCALE", "  |cfffff569/sqp scale <0.5-2.0>|r - Set icon scale"))
    print(GetText(self, "CMD_HELP_OFFSET", "  |cfffff569/sqp offset <x> <y>|r - Set icon offset"))
    print(GetText(self, "CMD_HELP_ANCHOR", "  |cfffff569/sqp anchor <LEFT|RIGHT>|r - Set icon anchor side"))
    print(GetText(self, "CMD_HELP_RESET", "  |cfffff569/sqp reset|r - Reset all settings"))
    print(GetText(self, "CMD_HELP_OPTIONS", "  |cfffff569/sqp options|r - Open the options panel"))
    print(GetText(self, "CMD_HELP_VERSION", "  |cfffff569/sqp version|r - Show addon version"))
    self:PrintMessage(GetText(self, "COMMUNITY_MESSAGE", GetText(self, "MSG_DISCORD", "Join our Discord: |cff58be81discord.gg/rgxmods|r")))
end

-- Test quest detection on current nameplates
function SQP:TestQuestDetection()
    self:PrintMessage(GetText(self, "TEST_SCANNING", GetText(self, "CMD_TEST", "Testing quest detection...")))
    
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
        self:PrintMessage(format(GetText(self, "TEST_FOUND_QUESTS", "Found %d units with quest objectives"), count))
    else
        self:PrintMessage(GetText(self, "TEST_NO_QUESTS", "No quest objectives found on visible nameplates"))
    end
end

-- Show current status
function SQP:ShowStatus()
    local statusHeader = GetText(self, "STATUS_HEADER", GetText(self, "CMD_STATUS", "|cff58be81Simple Quest Plates Status:|r"))
    local statusLine = GetText(self, "STATUS_STATUS", GetText(self, "CMD_STATUS_STATE", "  State: %s"))
    local enabledText = GetText(self, "STATUS_ENABLED", "|cff00ff00ENABLED|r")
    local disabledText = GetText(self, "STATUS_DISABLED", "|cffff0000DISABLED|r")
    local versionLine = GetText(self, "STATUS_VERSION", GetText(self, "CMD_VERSION", "Simple Quest Plates version: |cff58be81%s|r"))
    local scaleLine = GetText(self, "STATUS_SCALE", GetText(self, "CMD_STATUS_SCALE", "  Scale: |cff58be81%.1f|r"))
    local offsetLine = GetText(self, "STATUS_OFFSET", GetText(self, "CMD_STATUS_OFFSET", "  Offset: |cff58be81X=%d, Y=%d|r"))
    local anchorLine = GetText(self, "STATUS_ANCHOR", GetText(self, "CMD_STATUS_ANCHOR", "  Anchor: |cff58be81%s|r"))

    self:PrintMessage(statusHeader)
    print(format(statusLine, SQPSettings.enabled and enabledText or disabledText))
    print(format(versionLine, self.VERSION or "unknown"))
    print(format(scaleLine, SQPSettings.scale or 1))
    print(format(offsetLine, SQPSettings.offsetX or 0, SQPSettings.offsetY or 0))
    print(format(anchorLine, SQPSettings.anchor or "RIGHT"))
end

function SQP:DebugTarget()
    local unitID = "target"
    if not UnitExists(unitID) then
        self:PrintMessage("No target selected.", "DEBUG")
        return
    end

    local unitName = UnitName(unitID) or "Unknown"
    local unitGUID = UnitGUID(unitID) or "unknown"
    local progress = self:GetQuestProgress(unitID)

    self:PrintMessage(format("Target: %s (%s)", unitName, unitGUID), "DEBUG")
    if progress then
        self:PrintMessage(format("Quest progress: %s", tostring(progress)), "DEBUG")
    else
        self:PrintMessage("Quest progress: none", "DEBUG")
    end

    if self.Compat and self.Compat.IsQuestRelatedUnit then
        local ok, related = pcall(self.Compat.IsQuestRelatedUnit, unitID)
        if ok then
            self:PrintMessage(format("Quest related: %s", related and "yes" or "no"), "DEBUG")
        end
    end
end

function SQP:DebugNameplates()
    local total = 0
    local related = 0
    for i = 1, 40 do
        local unitID = "nameplate" .. i
        if UnitExists(unitID) then
            total = total + 1
            local progress = self:GetQuestProgress(unitID)
            if progress then
                related = related + 1
                self:PrintMessage(format("%s: %s", UnitName(unitID) or unitID, tostring(progress)), "DEBUG")
            end
        end
    end
    self:PrintMessage(format("Visible nameplates: %d, quest-related: %d", total, related), "DEBUG")
end

-- Set icon scale
function SQP:SetScale(scale)
    scale = tonumber(scale)
    if not scale or scale < 0.5 or scale > 2.0 then
        self:PrintMessage(GetText(self, "ERROR_INVALID_SCALE", GetText(self, "CMD_SCALE_INVALID", "|cffff0000Invalid scale value. Use a number between 0.5 and 2.0|r")))
        return
    end
    
    SQPSettings.scale = scale
    self:SaveSettings()
    self:PrintMessage(format(GetText(self, "SETTINGS_SCALE_SET", GetText(self, "CMD_SCALE_SET", "Icon scale set to: |cff58be81%.1f|r")), scale))
    self:RefreshAllNameplates()
end

-- Set icon offset
function SQP:SetOffset(x, y)
    x = tonumber(x)
    y = tonumber(y)
    if not x or not y then
        self:PrintMessage(GetText(self, "ERROR_INVALID_OFFSET", GetText(self, "CMD_OFFSET_INVALID", "|cffff0000Invalid offset values. Use numbers between -50 and 50|r")))
        return
    end
    
    SQPSettings.offsetX = x
    SQPSettings.offsetY = y
    self:SaveSettings()
    self:PrintMessage(format(GetText(self, "SETTINGS_OFFSET_SET", GetText(self, "CMD_OFFSET_SET", "Icon offset set to: |cff58be81X=%d, Y=%d|r")), x, y))
    self:RefreshAllNameplates()
end

-- Set anchor position
function SQP:SetAnchor(anchor)
    anchor = anchor:upper()
    if anchor ~= "LEFT" and anchor ~= "RIGHT" then
        self:PrintMessage(GetText(self, "ERROR_INVALID_ANCHOR", "|cffff0000Invalid anchor. Use LEFT or RIGHT|r"))
        return
    end
    
    SQPSettings.anchor = anchor
    SQPSettings.relativeTo = anchor == "LEFT" and "RIGHT" or "LEFT"
    self:SaveSettings()
    self:PrintMessage(format(GetText(self, "SETTINGS_ANCHOR_SET", "Anchor set to: |cff58be81%s|r"), anchor))
    self:RefreshAllNameplates()
end

-- Process slash command input
function SQP:ProcessSlashCommand(input)
    input = TrimInput(input):lower()
    
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
    elseif input == "version" then
        self:PrintMessage(format(GetText(self, "CMD_VERSION", "Simple Quest Plates version: |cff58be81%s|r"), self.VERSION or "unknown"))
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
        self:PrintMessage(GetText(self, "ERROR_UNKNOWN_COMMAND", "|cffff0000Unknown command. Type /sqp help|r"))
    end
end

-- Register slash commands
SLASH_SQP1 = "/" .. CHAT_COMMAND
SlashCmdList["SQP"] = function(input)
    SQP:ProcessSlashCommand(input)
end
