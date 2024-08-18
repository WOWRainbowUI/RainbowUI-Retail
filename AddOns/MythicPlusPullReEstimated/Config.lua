local name, ns = ...

--- @class MMPE
local MMPE = ns.addon

local L = LibStub('AceLocale-3.0'):GetLocale(name)

local GetAddOnMetadata = _G.GetAddOnMetadata or _G.C_AddOns.GetAddOnMetadata
MMPE.version = GetAddOnMetadata(name, "Version") or "unknown"
MMPE.defaultSettings = {
    enabled = true,

    autoLearnScores = 'newOnly',
    inconclusiveDataThreshold = 100, -- Mobs killed within this span of time (in milliseconds) will not be processed since we might not get the criteria update fast enough to know which mob gave what progress. Well, that's the theory anyway.
    maxTimeSinceKill = 600, -- Lag tolerance between a mob dying and the progress criteria updating, in milliseconds.

    enableTooltip = true,
    includeCountInTooltip = true,
    tooltipColor = "82E0FF",

    enablePullEstimate = true,
    pullEstimateCombatOnly = true,
    pullFrameTextFormat = L["Current pull:"] .. ' $current%$ + $pull%$ = $estimated%$',

    nameplateUpdateRate = 200, -- Rate (in milliseconds) at which we update the progress we get from the current pull, as estimated by active name plates you're in combat with. Also the update rate of getting new values for nameplate text overlay if enabled.

    offsetx = 0, -- extra offset for nameplate text
    offsety = 0,

    enableNameplateText = true,
    nameplateTextColor = "FFFFFFFF",

    lockPullFrame = false,
    pullFramePoint = {
        ["anchorPoint"] = "CENTER",
        ["relativeFrame"] = "UIParent",
        ["relativePoint"] = "CENTER",
        ["offX"] = 400,
        ["offY"] = 300,
    },

    debug = false,
    debugNewNPCScores = false,

    enableMdtEmulation = true,
}

local function SetFramePoint(frame, pointInfo)
    frame:ClearAllPoints()
    frame:SetPoint(
        pointInfo.anchorPoint,
        pointInfo.relativeFrame,
        pointInfo.relativePoint,
        pointInfo.offX,
        pointInfo.offY
    );
end

function MMPE:GetSetting(setting)
    if (not setting or self.DB.settings[setting] == nil) then
        self:PrintWarning(L["MPP attempted to get missing setting:"] .. " " .. (setting or "nil"))
        return
    end
    return self.DB.settings[setting]
end

function MMPE:SetSetting(setting, value)
    if (not setting or self.DB.settings[setting] == nil) then
        self:PrintWarning(L["MPP attempted to set missing setting:"] .. " " .. (setting or "nil"))
        return
    end
    self.DB.settings[setting] = value
    return value
end

function MMPE:ToggleSetting(setting)
    return self:SetSetting(setting, not self:GetSetting(setting))
end

function MMPE:InitPopup()
    if not StaticPopupDialogs["MPPEDataExportDialog"] then
        StaticPopupDialogs["MPPEDataExportDialog"] = {
            text = L["CTRL-C to copy"],
            button1 = CLOSE,
            OnShow = function(dialog, data)
                local function HidePopup()
                    dialog:Hide();
                end
                dialog.editBox:SetScript("OnEscapePressed", HidePopup);
                dialog.editBox:SetScript("OnEnterPressed", HidePopup);
                dialog.editBox:SetScript("OnKeyUp", function(_, key)
                    if IsControlKeyDown() and key == "C" then
                        HidePopup();
                    end
                end);
                dialog.editBox:SetMaxLetters(0);
                dialog.editBox:SetText(data);
                dialog.editBox:HighlightText();
            end,
            hasEditBox = true,
            editBoxWidth = 240,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        };
    end
end

function MMPE:InitConfig()
    local mdtLoaded = C_AddOns.IsAddOnLoaded("MythicDungeonTools");

    local count = 0
    local function increment() count = count + 1; return count end
    local options = {
        type = "group",
        childGroups = "tab",
        name = L["Mythic Plus Progress"],
        desc = L["Mythic Plus Progress tracker"],
        get = function(info) return self:GetSetting(info[#info]) end,
        set = function(info, value) self:SetSetting(info[#info], value) end,
        args = {
            version = {
                order = increment(),
                type = "description",
                name = L["Version:"] .. " " .. self.version,
            },
            enabled = {
                order = increment(),
                type = "toggle",
                name = L["Enabled"],
                desc = L["Enable/Disable the addon"],
            },
            wipesettings = {
                order = increment(),
                type = "execute",
                name = L["Reset Settings to default"],
                desc = L["Reset Settings to default"],
                func = function()
                    self:VerifySettings(true)
                end,
                width = "double",
            },
------------- disabled for now, might get re-enabled in the future, right now it's incorrectly detecting spiteful kills, and DH demon kills.
--[[            scores = {
--                order = increment(),
--                type = "group",
--                name = "Auto Learn Scores",
--                args = {
--                    autoLearnScores = {
--                        order = increment(),
--                        name = "Auto Learn Scores",
--                        desc = "New Only >> Only learn scores that for new NPCs. Useful for new dungeons, and the addon isn't updated yet.\nAlways >> Always learn updated scores. This might make the percentage inaccurate.\nOff >> Don't learn scores.",
--                        type = "select",
--                        values = {
--                            newOnly = "New Only (Recommended)",
--                            always = "Always (Risky)",
--                            off = "Off",
--                        },
--                    },
--                    inconclusiveDataThreshold = {
--                        order = increment(),
--                        name = "Inconclusive Data Threshold",
--                        desc = "Mobs killed within this span of time (in milliseconds) will not be processed since we might not get the criteria update fast enough to know which mob gave what progress.",
--                        type = "range",
--                        min = 50,
--                        max = 400,
--                        step = 10,
--                        hidden = true,
--                    },
--                    maxTimeSinceKill = {
--                        order = increment(),
--                        name = "Max Time Since Kill",
--                        desc = "Lag tolerance between a mob dying and the progress criteria updating, in milliseconds.",
--                        type = "range",
--                        min = 0,
--                        max = 1000,
--                        step = 10,
--                        hidden = true,
--                    },
--                },
--            },--]]
            mainOptions = {
                order = increment(),
                type = "group",
                name = L["Main Options"],
                args = {
                    tooltip = {
                        order = increment(),
                        type = "group",
                        name = L["Tooltip"],
                        inline = true,
                        args = {
                            enableTooltip = {
                                order = increment(),
                                type = "toggle",
                                name = L["Enable Tooltip"],
                                desc = L["Adds percentage info to the unit tooltip"],
                            },
                            includeCountInTooltip = {
                                order = increment(),
                                type = "toggle",
                                name = L["Include Count"],
                                desc = L["Include the raw count value in the tooltip, as well as the percentage"],
                            },
                        },
                    },
                    pullEstimateFrame = {
                        order = increment(),
                        type = "group",
                        name = L["Pull Estimate frame"],
                        inline = true,
                        args = {
                            enablePullEstimate = {
                                order = increment(),
                                type = "toggle",
                                name = L["Enable Current Pull frame"],
                                desc = L["Display a frame with current pull information"],
                            },
                            pullEstimateCombatOnly = {
                                order = increment(),
                                type = "toggle",
                                name = L["Only in combat"],
                                desc = L["Only show the frame when you are in combat"],
                            },
                            lockPullFrame = {
                                order = increment(),
                                type = "toggle",
                                name = L["Lock frame"],
                                desc = L["Lock the frame in place"],
                                set = function(info, value)
                                    self:SetSetting(info[#info], value)
                                    self.currentPullFrame:EnableMouse(not value)
                                end,
                            },
                            reset = {
                                order = increment(),
                                type = "execute",
                                name = L["Reset position"],
                                desc = L["Reset position of Current Pull frame to the default"],
                                func = function()
                                    self.DB.settings.pullFramePoint = self.defaultSettings.pullFramePoint
                                    SetFramePoint(self.currentPullFrame, self.DB.settings.pullFramePoint)
                                end,
                            },
                            pullFrameTextFormat = {
                                order = increment(),
                                type = "input",
                                name = L["Text Format"],
                                desc = L["The text format of the pull frame. Use placeholders to display information."],
                                descStyle = "inline",
                                width = "full",
                            },
                            pullFrameTextFormatDescription = {
                                order = increment(),
                                type = "description",
                                name = L['The following placeholders are available:'] .. '\n' ..
                                    '    - $current$ ' .. L['The current count of mobs killed.'] .. '\n' ..
                                    '    - $pull$ ' .. L['The count of mobs pulled.'] .. '\n' ..
                                    '    - $estimated$ ' .. L['The estimated count after all pulled mobs are killed.'] .. '\n' ..
                                    '    - $required$ ' .. L['The required count of mobs to reach 100%%.'] .. '\n' ..
                                    '    - $current%%$ ' .. L['The current percentage of mobs killed.'] .. '\n' ..
                                    '    - $pull%%$ ' .. L['The percentage of mobs pulled.'] .. '\n' ..
                                    '    - $estimated%%$ ' .. L['The estimated percentage after all pulled mobs are killed.'] .. '\n' ..
                                    '    - $required%%$ ' .. L['A long way of writing 100%%.'],
                            },
                            resetPullFrameTextFormatormat = {
                                order = increment(),
                                type = "execute",
                                name = "Reset Text Format",
                                desc = "Reset the text format to the default.",
                                descStyle = "inline",
                                width = "full",
                                func = function() self:SetSetting("pullFrameTextFormat", self.defaultSettings.pullFrameTextFormat); end,
                            },
                        },
                    },
                    nameplate = {
                        order = increment(),
                        type = "group",
                        name = L["Nameplate"],
                        inline = true,
                        args = {
                            enableNameplateText = {
                                order = increment(),
                                type = "toggle",
                                name = L["Enable Nameplate Text"],
                                desc = L["Adds the % info to the enemy nameplates"],
                            },
                            nameplateTextColor = {
                                order = increment(),
                                type = "color",
                                name = L["Nameplate Text Color"],
                                desc = L["Color of the text on the enemy nameplates"],
                                hasAlpha = true,
                                get = function(info)
                                    local hex = self:GetSetting(info[#info])
                                    return tonumber(hex:sub(3,4), 16) / 255, tonumber(hex:sub(5,6), 16) / 255, tonumber(hex:sub(7,8), 16) / 255, tonumber(hex:sub(1,2), 16) / 255
                                end,
                                set = function(info, r, g, b, a)
                                    self:SetSetting(info[#info], string.format("%02x%02x%02x%02x", a * 255, r * 255, g * 255, b * 255))
                                end,
                            },
                            offsetx = {
                                order = increment(),
                                type = "range",
                                name = L["Horizontal offset ( <-> )"],
                                desc = L["Horizontal offset of the nameplate text"],
                                width = "double",
                                softMin = -100,
                                softMax = 100,
                                bigStep = 1,
                            },
                            offsety = {
                                order = increment(),
                                type = "range",
                                name = L["Vertical Offset ( | )"],
                                desc = L["Vertical offset of the nameplate text"],
                                width = "double",
                                softMin = -100,
                                softMax = 100,
                                bigStep = 1,
                            },
                        },
                    },
                    experimental = {
                        order = increment(),
                        type = "group",
                        name = L["Experimental"],
                        inline = true,
                        args = {
                            description = {
                                order = increment(),
                                type = "description",
                                name = L["These options are experimental and may not work as intended."],
                            },
                            mdtEmulation = {
                                order = increment(),
                                type = "group",
                                inline = true,
                                name = L["MDT Emulation"],
                                args = {
                                    mdtEmulationDescription = {
                                        order = increment(),
                                        type = "description",
                                        name = mdtLoaded and L["Disabled when MythicDungeonTools is loaded"] or L["Allows addons and WAs that use MythicDungeonTools for % info to work with this addon instead."],
                                        width = "full",
                                    },
                                    enableMdtEmulation = {
                                        order = increment(),
                                        type = "toggle",
                                        name = L["Enable MDT Emulation"],
                                        desc = "",
                                        set = function(info, value)
                                            self:SetSetting(info[#info], value)
                                            self:CheckMdtEmulation()
                                        end,
                                        disabled = mdtLoaded,
                                    },
                                },
                            },
                        },
                    },
                },
            },
            devOptions = {
                order = increment(),
                type = "group",
                name = L["Developer Options"],
                args = {
                    debug = {
                        order = increment(),
                        type = "toggle",
                        name = L["Debug"],
                        desc = L["Enable/Disable debug prints"],
                    },
                    debugNewNPCScores = {
                        order = increment(),
                        type = "toggle",
                        name = L["Debug New NPC Scores"],
                        desc = L["Enable/Disable debug prints for new NPC scores"],
                    },
                    exportData = {
                        order = increment(),
                        type = "execute",
                        name = L["Export NPC data"],
                        desc = L["Opens a popup which allows copying the data"],
                        func = function() self:ExportData() end,
                    },
                    exportUpdatedData = {
                        order = increment(),
                        type = "execute",
                        name = L["Export updated NPC data"],
                        desc = L["Export only data that is different from the default values"],
                        func = function() self:ExportData(true) end,
                    },
                    npcDataPatchVersion = {
                        order = increment(),
                        type = "description",
                        name = function() return
                        string.format(
                                L["NPC data patch version: %s, build %d (ts %d)"],
                                self.DB.npcDataPatchVersionInfo.version,
                                self.DB.npcDataPatchVersionInfo.build,
                                self.DB.npcDataPatchVersionInfo.timestamp
                        )
                        end,
                    },
                    resetNpcData = {
                        order = increment(),
                        type = "execute",
                        name = L["Reset NPC data"],
                        desc = L["Reset the NPC data to the default values"],
                        func = function() self:VerifyDB(false, true) end,
                        confirm = true,
                        confirmText = L["Are you sure you want to reset the NPC data to the defaults?"],
                    },
                    simulationActive = {
                        order = increment(),
                        type = "toggle",
                        name = L["Simulation Mode"],
                        desc = L["Enable/Disable Simulation Mode"],
                        width = "double",
                        get = function(info) return self.simulationActive end,
                        set = function(info, value) self.simulationActive = value end,
                    },
                    simulationMax = {
                        order = increment(),
                        type = "range",
                        name = L["Simulation Required Points"],
                        desc = L["Simulated number of 'points' required to complete the run"],
                        softMin = 1,
                        softMax = 100,
                        bigStep = 1,
                        get = function(info) return self.simulationMax end,
                        set = function(info, value) self.simulationMax = value end,
                    },
                    simulationCurrent = {
                        order = increment(),
                        type = "range",
                        name = L["Simulation Current Points"],
                        desc = L["Simulated number of 'points' currently earned"],
                        softMin = 1,
                        softMax = 100,
                        bigStep = 1,
                        get = function(info) return self.simulationCurrent end,
                        set = function(info, value) self.simulationCurrent = value end,
                    },
                    wipeAll = {
                        order = increment(),
                        type = "execute",
                        name = L["Wipe All Data"],
                        desc = L["Wipe all data"],
                        func = function() self:VerifyDB(true) end,
                        confirm = true,
                        confirmText = L["Are you sure you want to wipe all data?"],
                    },
                },
            },
        },
    }

    self.configCategory = "MythicPlusProgress"
    LibStub("AceConfig-3.0"):RegisterOptionsTable(self.configCategory, options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(self.configCategory)
end

function MMPE:OpenConfig()
    Settings.OpenToCategory(self.configCategory);
end