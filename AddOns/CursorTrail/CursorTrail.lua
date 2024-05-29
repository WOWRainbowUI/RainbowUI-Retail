--[[---------------------------------------------------------------------------
    Addon:  CursorTrail
    File:   CursorTrail.lua
    Desc:   This file contains the core implementation for this addon.
-----------------------------------------------------------------------------]]

local kAddonFolderName, private = ...

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Saved (Persistent) Variables                      ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CursorTrail_Config = CursorTrail_Config or {}
CursorTrail_PlayerConfig = CursorTrail_PlayerConfig or {}

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Aliases to Globals                                ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local Globals = _G
local _  -- Prevent tainting global _ .
local abs = _G.math.abs
local assert = _G.assert
local ColorPickerFrame = _G.ColorPickerFrame
local CopyTable = _G.CopyTable
local CreateFrame = _G.CreateFrame
local CreateVector3D = _G.CreateVector3D
local DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME
local DoesAncestryInclude = _G.DoesAncestryInclude
local floor = _G.floor
local GetAddOnMetadata = _G.GetAddOnMetadata
local GetBuildInfo = _G.GetBuildInfo
local GetCursorPosition = _G.GetCursorPosition
local GetCVar = _G.GetCVar
local GetMouseFocus = _G.GetMouseFocus
local GetTime = _G.GetTime
local geterrorhandler = _G.geterrorhandler
local ipairs = _G.ipairs
local IsMouseButtonDown = _G.IsMouseButtonDown
local IsMouselooking = _G.IsMouselooking
local math =_G.math
local max =_G.math.max
local min =_G.math.min
local next = _G.next
local pairs = _G.pairs
local print = _G.print
local random = _G.math.random
local select = _G.select
local string = _G.string
local table = _G.table
local tonumber = _G.tonumber
local UIParent = _G.UIParent
local UnitAffectingCombat = _G.UnitAffectingCombat
local xpcall = _G.xpcall

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                Aliases to things in other files.                        ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

------ - - - - - - - - - - - - - - - - - --
----local util = private.util
------ - - - - - - - - - - - - - - - - - --
----local sFind = util.sFind
----local staticClearTable = util.staticClearTable
----local staticCopyTable = util.staticCopyTable
----local strEndsWith = util.strEndsWith
----local strMatchNoCase = util.strMatchNoCase
----local tCount = util.tCount
----local tEmpty = util.tEmpty
----local tGet = util.tGet
----local tSet = util.tSet
----local vdt_dump = util.vdt_dump

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Declare Namespace                                 ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local CursorTrail = _G.CursorTrail or {}
if (not _G.CursorTrail) then _G.CursorTrail = CursorTrail end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Remap Global Environment                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setfenv(1, _G.CursorTrail)  -- Everything after this uses our namespace rather than _G.

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Constants                                         ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

kAddonTitle = GetAddOnMetadata(kAddonFolderName, "Title")
kAddonVersion = (GetAddOnMetadata(kAddonFolderName, "Version") or "0.0.0.0"):match("^([%d.]+)")
kGameTocVersion = select(4, GetBuildInfo())
----print("CursorTrail kGameTocVersion:", kGameTocVersion)

-- Colors (Hex format = alpha, R, G, B.)
kTextColorDefault = "|cff7F7FFF"
BLUE        = "|cff0099DD"
BABYBLUE    = "|cff89CFF0"
GREEN       = "|cff00FF00"
GREEN2      = "|cff80FF00"  -- Bright Green
ORANGE      = "|cffEE5500"
RED         = "|cffFF0000"
RED2        = "|cffFF2020"  -- Bright Red
WHITE       = "|cffFFFFFF"
YELLOW      = "|cffFDDA0D"

-- Misc.
kShow = 1
kHide = -1

kMediaPath = "Interface\\Addons\\" .. kAddonFolderName .. "\\Media\\"
kStr_None = "< None >"
kAddonHeading = kTextColorDefault.."["..kAddonFolderName.."] "..WHITE
kAddonErrorHeading = RED2.."[ERROR] "..kAddonHeading
kAddonAlertHeading = ORANGE.."<"..YELLOW..kAddonFolderName..ORANGE.."> "..kTextColorDefault

kFrameLevel = 32
kDefaultShadowSize = 72
kDefaultShapeSize = kDefaultShadowSize - 18

kScreenTopFourthMult = 1.015
kScreenBottomFourthMult = 1.077

-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
kNewFeatures =  -- For flagging new features in the UI.
{
    -- Added in version 10.2.7.2 ...
    {anchor="BOTTOM", relativeTo="ProfilesUI.mainFrame.title", relativeAnchor="TOP", x=0, y=0}, --(Profiles GroupBox)
    {anchor="BOTTOM", relativeTo="DefaultsBtn", relativeAnchor="TOP", x=0, y=0},  --(Defaults Button)

--~ Disabled this notification in 10.2.7.1 ...
--~     -- Added in version 10.1.7.2 ...
--~     {anchor="BOTTOMLEFT", relativeTo="SparkleCheckbox", relativeAnchor="TOPRIGHT", x=-13, y=-5.3},

--~ Disabled this notification in 10.1.5.2 ...
--~     -- Added in version 10.1.0.1 ...
--~     "ShapeLabel",
--~     "HelpBtn",

    -- FOR TESTING ...
--~     {anchor="RIGHT", relativeTo="ShapeLabel", relativeAnchor="LEFT", x=-2, y=1},
--~     {anchor="LEFT", relativeTo="SparkleCheckbox.label", relativeAnchor="RIGHT", x=2, y=1.25},
--~     {anchor="RIGHT", relativeTo="OffsetLabel", relativeAnchor="LEFT", x=-2, y=1},
--~     {anchor="RIGHT", relativeTo="MouseLookCheckbox", relativeAnchor="LEFT", x=-2, y=2},
--~     {anchor="BOTTOM", relativeTo="HelpBtn", relativeAnchor="TOP", x=0, y=-1},
}

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Switches                                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

kEditBaseValues = false -- Set to true so arrow keys change base offsets and step size while UI is up.  (Developers only!)
                        -- Arrow keys (no modifier key) change BaseOfsX and BaseOfsY.
                        -- Alt causes arrow keys to change BaseStepX and BaseStepY.
                        -- Shift decrease the amount of change each arrow key press.
                        -- Ctrl increase the amount of change each arrow key press.
                        -- When done, type "/ct model" to dump all values (BEFORE CLOSING THE UI).
kShadowStrataMatchesMain = false  -- Set to true if you want shadow at same level as the trail effect.

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Variables                                         ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

gLButtonDownCount = 0
gMotionIntensity = 0  -- Ranges 0.0 to 1.0, increases the longer the mouse is moving.  Decrease when mouse is idle.
gShowOrHide = nil  -- Can be kShow, kHide, or nil (no change).
gPreviousX = nil
gPreviousY = nil

-- Sparkling shape color arrays:
gShapeSparkleIndex = 1
gShapeSparkleMax = 60
gShapeSparkleR = {}
gShapeSparkleG = {}
gShapeSparkleB = {}
for i = 1, gShapeSparkleMax do
    gShapeSparkleR[i] = random(3,9) * 0.1
    gShapeSparkleG[i] = random(3,9) * 0.1
    gShapeSparkleB[i] = random(3,9) * 0.1
end

-- Timer variables:
gTimer1 = 0
kTimer1Interval = 0.250 -- seconds

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Helper Functions                                  ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-------------------------------------------------------------------------------
kGameFrame = UIParent
function getScreenScaledSize()
    local uiScale = kGameFrame:GetEffectiveScale()  -- i.e. getScreenScale()
    ----print("uiScale:", round(uiScale,4), "  GetCVar(uiScale):", round(GetCVar("uiScale"),4))
    local w, h = kGameFrame:GetSize()  -- i.e. getScreenSize()
    w = w * uiScale
    h = h * uiScale
    local midX = w / 2
    local midY = h / 2
    local hypotenuse = (w^2 + h^2) ^ 0.5
    return w, h, midX, midY, uiScale, hypotenuse
end

-------------------------------------------------------------------------------
function updateScaleVars()
    local oldW, oldH, oldScale = ScreenW, ScreenH, ScreenScale
    ScreenW, ScreenH, ScreenMidX, ScreenMidY, ScreenScale, ScreenHypotenuse = getScreenScaledSize()
    ScreenFourthH = ScreenH * 0.25  -- 1/4th screen height.
    ----print("ScreenScale:", round(ScreenScale,4), " GetCVar(uiScale):", GetCVar("uiScale"), " ScreenW:", round(ScreenW,1), " ScreenH:", round(ScreenH,1))
    if ScreenW == oldW and ScreenH == oldH and ScreenScale == oldScale then
        return false  -- Variables did not change.
    end
    return true  -- Screen size and/or scale changed.
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                    Register for Slash Commands                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-------------------------------------------------------------------------------
function printUsageMsg()
    printMsg(kAddonFolderName.." "..kAddonVersion.." Slash Commands:")
    printMsg("(Note: Either "..BLUE.."/ct|r".." or "..BLUE.."/"..kAddonFolderName.."|r can be typed for these commands.)")
    printMsg(BLUE.."  /ct"..GREEN2.." - Show/Hide the options window.")
    printMsg(BLUE.."  /ct combat"..GREEN2.." - Toggles the 'Show only in combat' setting.")
    printMsg(BLUE.."  /ct fade"..GREEN2.." - Toggles the 'Fade out when idle' setting.")
    printMsg(BLUE.."  /ct help"..GREEN2.." - Shows this message.")
    printMsg(BLUE.."  /ct mouselook"..GREEN2.." - Toggles the 'Show during Mouse Look' setting.")
    printMsg(BLUE.."  /ct off"..GREEN2.." - Temporarily disables the cursor effects to improve game performance."
        .."  (Automatically turns back on at next reload, or by typing "..BLUE.."/ct on"..GREEN2..".)")
    printMsg(BLUE.."  /ct reload"..GREEN2.." - Reloads the current cursor settings.")
    printMsg(BLUE.."  /ct reset"..GREEN2.." - Resets cursor to original settings.")
    printMsg(BLUE..'  /ct sparkle'..GREEN2..' - Toggles shape color between normal and "sparkle".')
    printMsg(GREEN2.."BACKUP COMMANDS:")
    printMsg(BLUE.."    /ct backup <backup name>")
    printMsg(BLUE.."    /ct deletebackup <backup name>")
    printMsg(BLUE.."    /ct listbackups")
    printMsg(BLUE.."    /ct restore <backup name>")
    printMsg(GREEN2.."PROFILE COMMANDS:")
    printMsg(BLUE.."    /ct delete <profile name>")
    printMsg(BLUE.."    /ct list")
    printMsg(BLUE.."    /ct load <profile name>")
    printMsg(BLUE.."    /ct save <profile name>")

    ----printMsg(BLUE.."  /ct screen"..GREEN2.." - Print screen info in chat window.")
    ----printMsg(BLUE.."  /ct camera"..GREEN2.." - Print camera info in chat window.")
    ----printMsg(BLUE.."  /ct config"..GREEN2.." - Print configuration info in chat window.")
    ----printMsg(BLUE.."  /ct model"..GREEN2.." - Print model info in chat window.")
    ----printMsg(BLUE.."  /ct cal"..GREEN2.." - Calibrate cursor effect to your mouse.")
    ----printMsg(" \n")
end
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
Globals["SLASH_"..kAddonFolderName.."1"] = "/"..kAddonFolderName
Globals["SLASH_"..kAddonFolderName.."2"] = "/ct"
Globals.SlashCmdList[kAddonFolderName] = function (params)
    if (params == nil or params == "") then
        -- Toggle options window.
        if OptionsFrame:IsShown() then
            OptionsFrame:Hide()
        else
            OptionsFrame:Show()
            if isCursorTrailOff() then CursorTrail_ON(true) end
        end
        ----printUsageMsg()
        return
    end

    local cmd = string.split(" ", params)
    cmd = cmd:lower()
    local cmdParam = params:sub( cmd:len()+2 ):trim(' "')  -- Use this var for "names" that contain spaces.
    ----local paramAsNum = tonumber(params)

    local indents = "    "
    local bOptionsModified = false

    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    if cmd == "help" or cmd == "?" then
        printUsageMsg()
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "reset" then
        ----if Calibrating then Calibrating_DoNextStep("abort") end
        if OptionsFrame:IsShown() then OptionsFrame:Hide() end
        PlayerConfig_SetDefaults()
        CursorTrail_Load()
        CursorTrail_ON()
        OptionsFrame.ProfilesUI.clearProfileName()  -- Avoids overwriting current profile name with default values.
        printMsg(kAddonFolderName.." reset to original settings.")
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "reload" then
        if OptionsFrame:IsShown() then OptionsFrame:Hide() end
        updateScaleVars()
        CursorTrail_Load()
        CursorTrail_ON()
        ----if OptionsFrame:IsShown() then OptionsFrame_UpdateUI(PlayerConfig) end
        printMsg(kAddonFolderName.." settings reloaded.")
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "resetnewfeatures" then  -- For development use.
        if OptionsFrame:IsShown() then OptionsFrame:Hide() end
        Globals.CursorTrail_Config.NewFeaturesSeen = {}
        printMsg(kAddonFolderName.." reset new feature notifications.")
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "combat" then
        PlayerConfig.UserShowOnlyInCombat = not PlayerConfig.UserShowOnlyInCombat
        bOptionsModified = true
        printMsg(kAddonFolderName..GREEN2.." 'Show only in combat' |r= "
            ..ORANGE..(PlayerConfig.UserShowOnlyInCombat==true and "ON" or "OFF"))
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "mouselook" then
        PlayerConfig.UserShowMouseLook = not PlayerConfig.UserShowMouseLook
        bOptionsModified = true
        printMsg(kAddonFolderName..GREEN2.." 'Show during Mouse Look' |r= "
            ..ORANGE..(PlayerConfig.UserShowMouseLook==true and "ON" or "OFF"))
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "fade" then
        PlayerConfig.FadeOut = not PlayerConfig.FadeOut
        bOptionsModified = true
        if (PlayerConfig.FadeOut == true) then gMotionIntensity = 0.5 end
        printMsg(kAddonFolderName..GREEN2.." 'Fade out when idle' |r= "
            ..ORANGE..(PlayerConfig.FadeOut==true and "ON" or "OFF"))
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "sparkle" then
        PlayerConfig.ShapeSparkle = not PlayerConfig.ShapeSparkle
        bOptionsModified = true
        printMsg(kAddonFolderName..GREEN2.." 'Shape Sparkle' |r= "
            ..ORANGE..(PlayerConfig.ShapeSparkle==true and "ON" or "OFF"))
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "list" and cmdParam == "" then
        print(kAddonTitle.." Profiles:")
        local numProfiles = OptionsFrame.ProfilesUI:printProfileNames( ORANGE..indents )
        if numProfiles == 0 then print(indents.."(None.)")
        else print(indents.."|cff707070("..numProfiles.." profiles)") end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "load" or cmd == "save" or cmd == "delete" then
        local profileName = cmdParam
        if profileName == nil or profileName == "" then
            print(kAddonHeading.."ERROR - No profile name specified.")
            return  -- FAIL
        end
        ----OptionsFrame:Hide()  -- Close UI to avoid user undoing changes by clicking Cancel button.
        local profilesUI = OptionsFrame.ProfilesUI
        --:::::::::::::::::::::::::::::::::::::::::::::
        if cmd == "load" then
            local bResult, nameLoaded = profilesUI:loadProfile(profileName, "s")
            if bResult then
                print(kAddonHeading..'Loaded "'..ORANGE..nameLoaded..'|r".')
            else
                print(kAddonHeading..'ERROR - Profile "'..ORANGE..profileName..'|r" does not exist.')
            end
        --:::::::::::::::::::::::::::::::::::::::::::::
        elseif cmd == "save" then
            -- Save profile name, and then load that profile (in case its different than the currently loaded profile).
            local bResult, errMsg = profilesUI:saveProfile(profileName, "s", profileName)
            if bResult then
                print(kAddonHeading..'Saved "'..ORANGE..profileName..'|r".')
            else
                print(kAddonHeading..'ERROR - Failed to save profile "'..ORANGE..profileName..'|r".')
                if errMsg then print("    ("..errMsg..")") end
            end
        --:::::::::::::::::::::::::::::::::::::::::::::
        elseif cmd == "delete" then
            local bResult, nameDeleted = profilesUI:deleteProfile(profileName, "s")
            if bResult then
                print(kAddonHeading..'Deleted "'..ORANGE..nameDeleted..'|r".')
            else
                print(kAddonHeading..'ERROR - Profile "'..ORANGE..profileName..'|r" does not exist.')
            end
        end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "listbackups" or cmd == "lb" then
        print(kAddonTitle.." Backups:")
        local numBackups = OptionsFrame.ProfilesUI:printBackupNames(ORANGE..indents)
        if numBackups == 0 then print(indents.."(None.)") end
   -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "backup" or cmd == "bu" then
        local profilesUI = OptionsFrame.ProfilesUI
        local backupName = cmdParam
        if backupName == "" then
            profilesUI:backupProfiles()  -- Displays the "restore backups" window.
        else
            local bResult, backupNameUsed, errMsg = profilesUI:backupProfiles(backupName, "s")

            if bResult then
                assert(backupNameUsed ~= nil and backupNameUsed ~= "")
                backupNameUsed = '"'..ORANGE..backupNameUsed..'|r"'
                print(kAddonHeading.."Backed up all profiles to "..backupNameUsed..".")
            else
                print(kAddonHeading.."ERROR - Failed to backup profiles.")
                if errMsg then print("    ("..errMsg..")") end
            end
        end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "restore" or cmd == "re" then
        OptionsFrame:Hide()  -- Close UI to avoid user undoing changes by clicking Cancel button.
        local profilesUI = OptionsFrame.ProfilesUI
        local backupName = cmdParam
        if backupName == "" then
            profilesUI:restoreProfiles()  -- Displays the "restore backups" window.
        else
            local bResult, backupNameUsed, numProfiles = profilesUI:restoreProfiles(backupName, "s")

            if bResult then
                assert(backupNameUsed ~= nil and backupNameUsed ~= "")
                backupNameUsed = '"'..ORANGE..backupNameUsed..'|r"'
                print(kAddonHeading.."Restored backup "..backupNameUsed.." ("..numProfiles.." profiles).")
            else
                cmdParam = '"'..ORANGE..cmdParam..'|r"'
                print(kAddonHeading.."ERROR - Failed to restore "..cmdParam..".")
            end
        end
     -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "deletebackup" or cmd == "db" then
        OptionsFrame:Hide()  -- Close UI to avoid user undoing changes by clicking Cancel button.
        local backupName = cmdParam
        if backupName == nil or backupName == "" then
            print(kAddonHeading.."ERROR - No backup name specified.")
        elseif OptionsFrame.ProfilesUI:deleteBackup(backupName, "s") then
            backupName = '"'..ORANGE..backupName..'|r"'
            print(kAddonHeading.."Deleted backup "..backupName..".")
        else
            print(kAddonHeading..'ERROR - Backup "'..ORANGE..backupName..'|r" does not exist.')
            ----    .. "\nMake sure you typed the exact upper/lower case letters in the name.")
        end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "on" then
        -- Show model if in combat or ShowOnlyInCombat is false.
        if (PlayerConfig.UserShowOnlyInCombat ~= true or UnitAffectingCombat("player") == true) then
            CursorTrail_Show()
        end
        CursorTrail_ON(true)
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "off" then
        CursorTrail_OFF()
        CursorTrail_Hide()
        printMsg(kAddonFolderName..": "..ORANGE.."OFF|r  (Automatically turns back on at next reload, or by opening the options window.)")
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    --____________________________________________________
    --               DEBUGGING COMMANDS
    --____________________________________________________
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif cmd == "memory" then  -- For debugging.
        Globals.collectgarbage("collect")  -- Frees any "garbage memory" immediately.
        ----printMsg(kAddonFolderName.." Memory:"..round(Globals.collectgarbage("count"),1).."k")
        Globals.UpdateAddOnMemoryUsage(kAddonFolderName)
        printMsg(kAddonFolderName.." Memory: "..round(Globals.GetAddOnMemoryUsage(kAddonFolderName),1).."k")
--~     -- - - - - - - - - - - - - - - - - - - - - - - - - - -
--~     elseif cmd == "deleteallprofiles!" then
--~         OptionsFrame:Hide()  -- Close UI to avoid user undoing changes by clicking Cancel button.
--~         print(kAddonHeading.."Deleting profiles ...")
--~         ----Globals.CursorTrail_Config.Profiles = {}
--~         local DB = OptionsFrame.ProfilesUI.DB
--~         local profiles = DB:getProfiles()
--~         for k, v in pairs(profiles) do profiles[k]=nil end
--~         PlayerConfig_SetDefaults()
--~         OptionsFrame.ProfilesUI:refreshUI()
--~         DB:clearCache(true) -- Wipe cached profiles and backups so they aren't restored in PLAYER_LOGOUT.
--~         print(kAddonHeading.."All profiles deleted!")
--~     -- - - - - - - - - - - - - - - - - - - - - - - - - - -
--~     elseif cmd == "deleteallbackups!" then
--~         OptionsFrame:Hide()  -- Close UI to avoid user undoing changes by clicking Cancel button.
--~         print(kAddonHeading.."Deleting backups ...")
--~         local DB = OptionsFrame.ProfilesUI.DB
--~         local backups = DB:getBackups()
--~         for k, v in pairs(backups) do backups[k]=nil end
--~         DB:clearCache(true) -- Wipe cached profiles and backups so they aren't restored in PLAYER_LOGOUT.
--~         print(kAddonHeading.."All backups deleted!")
--~     -- - - - - - - - - - - - - - - - - - - - - - - - - - -
--~     elseif cmd == "deletealldata!" then
--~         OptionsFrame:Hide()  -- Close UI to avoid user undoing changes by clicking Cancel button.
--~         Globals.CursorTrail_Config = nil
--~         Globals.CursorTrail_PlayerConfig = nil
--~         Globals.C_UI.Reload()
--~     -- - - - - - - - - - - - - - - - - - - - - - - - - - -
--~     elseif cmd == "test" then
--~         print(kAddonHeading.."Test...")
--~
--~ local currentFrame = GetMouseFocus()
--~ while currentFrame do
--~     vdt_dump(currentFrame, "ancestory test")
--~     if currentFrame == OptionsFrame then
--~         print("Test DONE (found it).")
--~         return true
--~     end
--~     currentFrame = currentFrame:GetParent()
--~ end
--~
--~         ----local data = OptionsFrame.ProfilesUI.DB:get("Test")
--~ --TODO: Add Credits to TOC files for AceSerializer if you end up using it.
--~         local data = OptionsFrame.ProfilesUI.DB:getProfiles()
--~         local exportStr = private.AceSerializer:Serialize(data)
--~         print(exportStr)
--~         local bResult, importedData = private.AceSerializer:Deserialize(exportStr)
--~         ----Globals.DevTools_Dump(importedData)
--~         ----Globals.ViragDevTool_AddData(importedData, "importedData")
--~         vdt_dump(importedData, "importedData")

        print(kAddonHeading.."Test DONE.")
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -
    elseif not HandleToolSwitches(params) then
        printMsg(kAddonErrorHeading..": Invalid slash command ("..params..").")
        ----DebugText(kAddonFolderName..": Invalid slash command ("..params..").")
    end
    -- - - - - - - - - - - - - - - - - - - - - - - - - - -

    if bOptionsModified then
        PlayerConfig_Save()
        CursorTrail_Load(PlayerConfig)  -- Update displayed cursor FX.
        UI_SetValues(PlayerConfig)  -- Update UI.
        OptionsFrame.ProfilesUI:OnValueChanged()
        OptionsFrame.ProfilesUI:OnOkay()  -- Saves current profile if "save on okay" option is set.
    end
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Event Handlers                                    ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

EventFrame = CreateFrame("Frame")

-------------------------------------------------------------------------------
EventFrame:SetScript("OnEvent", function(self, event, ...)
	-- This calls a method named after the event, passing in all the relevant args.
    -- Example:  MyAddon.frame:RegisterEvent("XYZ") calls function MyAddon.frame:XYZ()
    --           with any arguments passed in the "..." part.
	self[event](self, ...)
end)

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("ADDON_LOADED")
function       EventFrame:ADDON_LOADED(addonName)
    if (addonName == kAddonFolderName) then
        ----dbg("ADDON_LOADED")
        ----print("|c7f7f7fff".. kAddonFolderName .." "..kAddonVersion.." loaded.  For options, type \n"..
        ----    Globals["SLASH_"..kAddonFolderName.."2"] .." or ".. Globals["SLASH_"..kAddonFolderName.."1"] ..".|r") -- Color format = xRGB.
        self:UnregisterEvent("ADDON_LOADED")
    end
end

-------------------------------------------------------------------------------
--~ EventFrame:RegisterEvent("CVAR_UPDATE")
--~ function       EventFrame:CVAR_UPDATE(varName, varValue)
--~     ----dbg("CVAR_UPDATE("..(varName or "nil")..", "..(varValue or "nil")..")")
--~     if (varName and varName == "uiScale") then
--~         ----dbg("*** Calling updateScaleVars() ***")
--~         updateScaleVars()
--~     end
--~ end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD") --VARIABLES_LOADED
function       EventFrame:PLAYER_ENTERING_WORLD()
    ----dbg("PLAYER_ENTERING_WORLD")
    ----dbg("CursorModel: "..(CursorModel and "EXISTS" or "NIL"))
    Addon_Initialize()
    if not StandardPanel then StandardPanel_Create("/"..kAddonFolderName) end
    if not OptionsFrame then OptionsFrame_Create() end
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("UI_SCALE_CHANGED")
function       EventFrame:UI_SCALE_CHANGED()
    ----dbg("UI_SCALE_CHANGED")
    updateScaleVars()
    if CursorModel then
        CursorTrail_Load()  -- Reload the cursor model to apply the new UI scale.
    end
end

--~ -------------------------------------------------------------------------------
--~ function reportError20240522()  -- TODO:Remove in next release.
--~     if CursorTrail_Error20240522 then return end  -- Prevent spamming this error.
--~     CursorTrail_Error20240522 = true
--~     print(kAddonErrorHeading, "Unexpected call to DISPLAY_SIZE_CHANGED.  Please report this on"
--~         .. "|cff44BBFF www.curseforge.com/wow/addons/cursortrail|r and mention your game's display resolution.")
--~ end
--~ -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
--~ EventFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
--~ function       EventFrame:DISPLAY_SIZE_CHANGED()
--~     ----dbg("DISPLAY_SIZE_CHANGED")
--~     if updateScaleVars() and CursorModel then
--~         reportError20240522() -- TODO:Remove. (Added to see if users see it. If so, it means DISPLAY_SIZE_CHANGED can fire without UI_SCALE_CHANGED firing first.  Uncomment next lines if it does.)
--~ ---->>> TODO: Uncomment?  Potential fix for ultrawide monitors.
--~ ----        CursorTrail_Load()  -- Reload the cursor model to apply the new display size.
--~     end
--~ end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
function       EventFrame:LOADING_SCREEN_DISABLED()
    updateScaleVars()
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("PLAYER_LOGOUT")
function       EventFrame:PLAYER_LOGOUT()
    PlayerConfig_Save()
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("CINEMATIC_START")
function       EventFrame:CINEMATIC_START()
    ----gShowOrHide = kHide
    gShowOrHide = nil
    CursorTrail_Hide()
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("CINEMATIC_STOP")
function       EventFrame:CINEMATIC_STOP()
    ----gShowOrHide = kShow
    gShowOrHide = nil
    if (PlayerConfig.UserShowOnlyInCombat == true) then
        CursorTrail_Hide()
    else
        CursorTrail_Show()
    end
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
function       EventFrame:PLAYER_REGEN_DISABLED()  -- Combat started.
    ----dbg("PLAYER_REGEN_DISABLED")
    if (PlayerConfig.UserShowOnlyInCombat == true) then gShowOrHide = kShow end
end

-------------------------------------------------------------------------------
EventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
function       EventFrame:PLAYER_REGEN_ENABLED()  -- Combat ended.
    ----dbg("PLAYER_REGEN_ENABLED")
    if (PlayerConfig.UserShowOnlyInCombat == true) then gShowOrHide = kHide end
end

-------------------------------------------------------------------------------
----EventFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")  <-- Registered in OptionsFrame_OnShow().
function EventFrame:GLOBAL_MOUSE_DOWN(button)
    ----dbg("GLOBAL_MOUSE_DOWN")
    private.UDControls.handleGlobalMouseClick(button)
end

--~ -------------------------------------------------------------------------------
--~ EventFrame:RegisterEvent("UNIT_PET")
--~ function       EventFrame:UNIT_PET()
--~     ----dbg("UNIT_PET")
--~     -- Eat this event so it doesn't mysteriously cause an
--~     -- "addon tried to call protected function" error
--~     -- in Blizzard's CompactuUnitFrame.lua file.
--~ end

--~ -------------------------------------------------------------------------------
--~ EventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
--~ function       EventFrame:GROUP_ROSTER_UPDATE()
--~     ----dbg("GROUP_ROSTER_UPDATE")
--~     -- Eat this event so it doesn't mysteriously cause an
--~     -- "addon tried to call protected function" error
--~     -- in Blizzard's CompactRaidFrameContainer.lua file.
--~ end

-------------------------------------------------------------------------------
function CursorTrail_OnUpdate(self, elapsedSeconds)
    ----DebugText("CPU: "..round(elapsedSeconds,3), 76)
    ----DebugText("Shadow% "..round(Globals.CursorTrail_PlayerConfig.UserShadowAlpha,2), 100)
    ----DebugText("Fade: "..(Globals.CursorTrail_Config.Profiles.Test.FadeOut and "true" or "false"), 80)
    ----local t0 = GetTime()
    local bOptionsShown = (OptionsFrame and OptionsFrame:IsShown())
    local bIsMouseLooking = IsMouselooking()
    if (PlayerConfig.UserShowMouseLook == true) then
        gTimer1 = 0  -- Prevents hiding during "mouse look".
        if (bIsMouseLooking == true and PlayerConfig.FadeOut == true) then
            gMotionIntensity = 1.0  -- Force show during mouse look.
        end
    else
        -- - - - - - - - - - - - - - - - - - - - - - - - --
        -- Hide cursor effect during "mouse look".
        -- - - - - - - - - - - - - - - - - - - - - - - - --
        gTimer1 = gTimer1 + elapsedSeconds
        if (gTimer1 >= kTimer1Interval) then
            gTimer1 = 0
            ----if (OptionsFrame and OptionsFrame:IsShown() ~= true) then
            if not bOptionsShown then
                if bIsMouseLooking then
                    gLButtonDownCount = 1
                    if ( CursorModel.IsHidden ~= true
                        or (ShadowTexture and ShadowTexture:GetAlpha() > 0)
                        or (ShapeTexture and ShapeTexture:GetAlpha() > 0) )
                      then
                        gShowOrHide = kHide
                    end
                elseif IsMouseButtonDown("LeftButton") then
                    gLButtonDownCount = gLButtonDownCount + 1
                    if (gLButtonDownCount > 1) then
                        if ( CursorModel.IsHidden ~= true
                            or (ShadowTexture and ShadowTexture:GetAlpha() > 0)
                            or (ShapeTexture and ShapeTexture:GetAlpha() > 0) )
                          then
                            gShowOrHide = kHide
                        end
                    end
                elseif (gLButtonDownCount > 0) then
                    gLButtonDownCount = 0
                    gShowOrHide = kShow
                    if (PlayerConfig.UserShowOnlyInCombat == true
                        and not UnitAffectingCombat("player"))
                      then
                        -- Player not in combat, so don't show the cursor.
                        gShowOrHide = kHide
                    end
                end
            end
        end
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - --
    -- Show/hide cursor model (or leave it as-is).
    -- - - - - - - - - - - - - - - - - - - - - - - - --
    if (gShowOrHide == kShow) then
        CursorTrail_Show()  -- Note: Resets gShowOrHide to nil.
        ----xpcall(CursorTrail_Show, errHandler)
    elseif (gShowOrHide == kHide) then
        CursorTrail_Hide()  -- Note: Resets gShowOrHide to nil.
        ----xpcall(CursorTrail_Hide, errHandler)
        return  -- No need to continue when its hidden.
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - --
    -- Update shape color if sparkle mode is on.
    -- - - - - - - - - - - - - - - - - - - - - - - - --
    if (ShapeTexture and PlayerConfig.ShapeSparkle) then
        ShapeTexture:SetVertexColor(gShapeSparkleR[gShapeSparkleIndex]
                                  , gShapeSparkleG[gShapeSparkleIndex]
                                  , gShapeSparkleB[gShapeSparkleIndex])
        gShapeSparkleIndex = gShapeSparkleIndex + 1
        if gShapeSparkleIndex > gShapeSparkleMax then gShapeSparkleIndex = 1 end
    end

    -- - - - - - - - - - - - - - - - - - - - - - - - --
    -- Follow mouse cursor.
    -- - - - - - - - - - - - - - - - - - - - - - - - --
    local cursorX, cursorY = GetCursorPosition()
    ----DebugText("x: "..cursorX..",  y: "..cursorY)
    if (cursorX ~= gPreviousX or cursorY ~= gPreviousY) then
        -- Cursor position changed.  Keep model position in sync with it.
        local bPreview = (gPreviousX == nil)

        ----local dx, dy = cursorX-(gPreviousX or 0), cursorY-(gPreviousY or 0)
        gPreviousX, gPreviousY = cursorX, cursorY

        -- Keep FX along top side of options window while mouse is over it (so user can see changes better).
        if bOptionsShown then
            -- Mouse over options window?
            bPreview = bPreview or DoesAncestryInclude(OptionsFrame, GetMouseFocus())
            -- Mouse over color picker?
            bPreview = bPreview or (ColorPickerFrame:IsShown() and DoesAncestryInclude(ColorPickerFrame, GetMouseFocus()))
            if bPreview then
                local ofs = ShapeTexture:GetWidth() * 0.5
                cursorY = (OptionsFrame.HeaderTexture:GetTop() + ofs - 2) * ScreenScale
                --------ofs = ofs - (math.sin(cursorY*0.04) - 1) * 50  -- Wobble left/right as mouse moves up/down.
                ----cursorX = (OptionsFrame:GetLeft() - ofs - 8) * ScreenScale
            end
        end

        local tX, tY   -- (x, y) position of texture objects.
        if (ShadowTexture or ShapeTexture) then
            tX = ((cursorX - ScreenMidX) / ScreenScale)
            tY = ((cursorY - ScreenMidY) / ScreenScale)
        end

        -- Update position of shadow.
        if ShadowTexture then
            ShadowTexture:SetPoint("CENTER", kGameFrame, "CENTER", tX+3, tY-2)
            ----ShadowTexture:SetPoint("CENTER", kGameFrame, "CENTER", tX+(3*PlayerConfig.UserScale), tY-(2*PlayerConfig.UserScale))
        end

--~         if TestCursorModel then
--~             local modelX = cursorX / ScreenHypotenuse
--~             local modelY = cursorY / ScreenHypotenuse
--~             ----TestCursorModel:SetPosition(0, modelX, modelY)  --<<< NOT WORKING.
--~             TestCursorModel:SetTransform( CreateVector3D(modelX, modelY, 0),  -- (Position x,y,z)
--~                                           CreateVector3D(0,0,0), ----rad(0), rad(0), rad(0)),  -- (Rotation x,y,z)
--~                                           TestCursorModel.baseScale )  ----TestCursorModel:GetWorldScale() )
--~         end

        -- Update position of model.
        if CursorModel then
            if (CursorModel.Constants.IsSkewed == true) then
                cursorX, cursorY = unskew(cursorX, cursorY,
                                        CursorModel.Constants.HorizontalSlope,
                                        CursorModel.Constants.SkewTopMult,
                                        CursorModel.Constants.SkewBottomMult)
            end

            local modelX = ((cursorX - ScreenMidX) / CursorModel.StepX) + CursorModel.OfsX
            local modelY = ((cursorY - ScreenMidY) / CursorModel.StepY) + CursorModel.OfsY
            CursorModel:SetPosition(0, modelX, modelY)
        end

        -- Update position of shape.
        if ShapeTexture then
            ShapeTexture:SetPoint("CENTER", kGameFrame, "CENTER", tX+0.5, tY-0.5)
        end

        -- - - - - - - - - - - - - - - - - - - - - - - - --
        -- Fade in, if necessary.
        -- - - - - - - - - - - - - - - - - - - - - - - - --
        if (PlayerConfig.FadeOut == true) then
            -- Calculate motion intensity.
            if (gMotionIntensity <= 0) then
                gMotionIntensity = 0.04  -- Starting intensity for fading in.
            elseif (gMotionIntensity < 1) then
                gMotionIntensity = min(1.0, gMotionIntensity*1.23)  -- Increase intensity while cursor moves (up to 1.0).
            end
            ----print("gMotionIntensity fi:", round(gMotionIntensity,2))

            -- Apply motion intensity to user's chosen alpha levels.
            if (CursorModel and CursorModel.IsHidden ~= true) then
                CursorModel:SetAlpha( PlayerConfig.UserAlpha * gMotionIntensity )
            end
            if (ShadowTexture and PlayerConfig.UserShadowAlpha > 0) then  -- Has user set shadow opacity?
                ShadowTexture:SetAlpha( PlayerConfig.UserShadowAlpha * gMotionIntensity )
            end
            if (ShapeTexture and PlayerConfig.UserAlpha > 0) then  -- TODO: Add a userShapeAlpha parameter set by user?
                ShapeTexture:SetAlpha( PlayerConfig.UserAlpha * gMotionIntensity )
            end
        end
    elseif (gMotionIntensity > 0) then
        -- - - - - - - - - - - - - - - - - - - - - - - - --
        -- Fade out when mouse is not moving.
        -- - - - - - - - - - - - - - - - - - - - - - - - --
        local kFadeoutSecs = 0.5  -- (Reduce from max to min intensity over this many seconds.)
        local delta, alpha

        -- Decrease intensity.
        ----if (gMotionIntensity >= 1.0) then print("-------------") end
        delta = elapsedSeconds / kFadeoutSecs
        gMotionIntensity = gMotionIntensity - delta
        if (gMotionIntensity < 0) then gMotionIntensity = 0 end
        ----print("elapsed: "..round(elapsedSeconds,2)..", delta: "..round(delta,2))
        ----dbg("gMotionIntensity fo: "..round(gMotionIntensity,2))

        -- Fade out model.
        if CursorModel then
            if (CursorModel:GetAlpha() > 0) then
                alpha = PlayerConfig.UserAlpha * gMotionIntensity
                CursorModel:SetAlpha(alpha)
                ----print("model alpha:", round(alpha,2))
            end
        end

        -- Fade out shadow.
        if ShadowTexture then
            if (ShadowTexture:GetAlpha() > 0) then
                alpha = PlayerConfig.UserShadowAlpha * gMotionIntensity
                ShadowTexture:SetAlpha(alpha)
                ----print("shadow alpha:", round(alpha,2))
            end
        end

        -- Fade out shape.
        if ShapeTexture then
            if (ShapeTexture:GetAlpha() > 0) then
                alpha = PlayerConfig.UserAlpha * gMotionIntensity
                ShapeTexture:SetAlpha(alpha)
                ----print("shape alpha:", round(alpha,2))
            end
        end
    end

    ----DebugText("dt: "..GetTime()-t0, 200)
end

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                            Hooks                                        ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-------------------------------------------------------------------------------
-- Hide during movies.
Globals.MovieFrame:HookScript("OnShow", function() gShowOrHide = kHide end)
Globals.MovieFrame:HookScript("OnHide", function() gShowOrHide = kShow end)

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                            Functions                                    ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-------------------------------------------------------------------------------
function Addon_Initialize()
    -------------------
    -- Global Settings
    -------------------
    Globals.CursorTrail_Config.Profiles = Globals.CursorTrail_Config.Profiles or {}

    ------ Changelog stuff.
    ---->>> NOT IMPLEMENTED YET.
    ----Globals.CursorTrail_Config.LastChangelogVersion = Globals.CursorTrail_Config.LastChangelogVersion or ""
    ----
    ------ Show change log?
    ----if (compareVersions(Globals.CursorTrail_Config.LastChangelogVersion, kAddonVersion) == 2) then  -- Is addon version newer?
    ----    CursorTrail_ShowChangelog()
    ----    Globals.CursorTrail_Config.LastChangelogVersion = kAddonVersion
    ----end

    -- New features notification.
    Globals.CursorTrail_Config.NewFeaturesSeen = Globals.CursorTrail_Config.NewFeaturesSeen or {}
    local newFeaturesCount = 0
    for _, pt in pairs(kNewFeatures) do
        local newFeatureName = pt.relativeTo
        ----print("Addon_Initialize(), newFeatureName:", newFeatureName)
        if not Globals.CursorTrail_Config.NewFeaturesSeen[newFeatureName] then
            newFeaturesCount = newFeaturesCount + 1
        end
    end
    if (newFeaturesCount > 0) then printNewFeaturesMsg(true) end

    -------------------
    -- Player Settings
    -------------------
    if (not PlayerConfig) then
        PlayerConfig_Load()
    end

    -- Initialize addon.
    CursorTrail_Load()
    CursorTrail_ON()
end

-------------------------------------------------------------------------------
function isCursorTrailOff()
    if (EventFrame:GetScript("OnUpdate") == nil) then return true end
    return false
end

-------------------------------------------------------------------------------
function CursorTrail_ON(bPrintMsg)
    if isCursorTrailOff() then  -- Prevents chaining multiple calls to our handler.
        ----print(kAddonFolderName..": Setting EventFrame's OnUpdate script.")
        EventFrame:SetScript("OnUpdate", CursorTrail_OnUpdate)
    end
    if bPrintMsg then printMsg(kAddonFolderName..": "..ORANGE.."ON") end
end

-------------------------------------------------------------------------------
function CursorTrail_OFF()
    if OptionsFrame:IsShown() then OptionsFrame:Hide() end
    EventFrame:SetScript("OnUpdate", nil)
end

-------------------------------------------------------------------------------
function printNewFeaturesMsg(bIncludeInstructions)
    local msg = kAddonAlertHeading..GREEN.."NEW FEATURES available!"..kTextColorDefault
    if bIncludeInstructions then
        msg = msg.."  (Type either "..WHITE.."/ct|r or "..WHITE.."/"..kAddonFolderName.."|r to see them.)"
    end
    printMsg(msg)
end

-------------------------------------------------------------------------------
function PlayerConfig_SetDefaults()
    local defaultData = kDefaultConfig[kDefaultConfigKey]
    ----staticClearTable( Globals.CursorTrail_PlayerConfig )  -- Clear existing fields first.
    staticCopyTable( defaultData, Globals.CursorTrail_PlayerConfig ) -- Updates CursorTrail_PlayerConfig.
    PlayerConfig = Globals.CursorTrail_PlayerConfig
end

-------------------------------------------------------------------------------
function PlayerConfig_Save() --TODO:Remove?
    assert(PlayerConfig == Globals.CursorTrail_PlayerConfig) -- Verify addresses didn't change from using CopyTable() instead of staticCopyTable().
    ----assert(PlayerConfig)
    ----Globals.CursorTrail_PlayerConfig = PlayerConfig
end

-------------------------------------------------------------------------------
function PlayerConfig_Load()
    PlayerConfig = Globals.CursorTrail_PlayerConfig
    if isEmpty(PlayerConfig) then PlayerConfig_SetDefaults() end
    PlayerConfig_Validate()
end

-------------------------------------------------------------------------------
function validateSettings(config)
    ---------------------
    -- Validate fields.
    ---------------------
    ----config.ShapeFileName  <-- This can be nil.  Nothing do to.
    if not config.ModelID  -- Doesn't exist?
      or not tonumber(config.ModelID) -- Obsolete model path (string value)?
      then
        config.ModelID = kDefaultModelID
    end
    config.ShapeColorR = config.ShapeColorR or 1.0
    config.ShapeColorG = config.ShapeColorG or 1.0
    config.ShapeColorB = config.ShapeColorB or 1.0
    ----config.ShapeSparkle = config.ShapeSparkle or false

    config.UserShadowAlpha = config.UserShadowAlpha or 0.0
    config.UserScale = config.UserScale or 1.0
    config.UserAlpha = config.UserAlpha or 1.0
    config.Strata = config.Strata or kDefaultStrata
    config.UserOfsX = config.UserOfsX or 0.0
    config.UserOfsY = config.UserOfsY or 0.0

    ----config.FadeOut = config.FadeOut or false
    ----config.UserShowOnlyInCombat = config.UserShowOnlyInCombat or false
    ----config.UserShowMouseLook = config.UserShowMouseLook or false

    ---------------------------
    -- Clear obsolete fields.
    ---------------------------
    -- (Removed some time before version 10.)
    if (config.BaseScale ~= nil) then
        config.BaseScale = nil
        config.BaseOfsX = nil
        config.BaseOfsY = nil
        config.BaseStepX = nil
        config.BaseStepY = nil
    end
    config.Version = nil
end

-------------------------------------------------------------------------------
function PlayerConfig_Validate() validateSettings(PlayerConfig) end

-------------------------------------------------------------------------------
function CursorTrail_Load(config)
    -- Handle nil parameter.
    ----vdt_dump(config, "config (1) in CursorTrail_Load()")
    if (not config) then
        if (not PlayerConfig) then PlayerConfig_Load() end
        config = PlayerConfig
    end
    config.UserScale = config.UserScale or 1
    ----vdt_dump(config, "config (2) in CursorTrail_Load()")

    -----------------
    -- LOAD SHADOW --
    -----------------
    if not ShadowTexture then
        Shadow_Create()
    end
    if (kShadowStrataMatchesMain == true) then
        ShadowFrame:SetFrameStrata(config.Strata)
    end
    ShadowTexture:SetAlpha(config.UserShadowAlpha)

    ----------------
    -- LOAD SHAPE --
    ----------------
    if not ShapeTexture then
        Shape_Create()
    end
    ShapeFrame:SetFrameStrata(config.Strata)
    Shape_SetTexture(config.ShapeFileName)
    ----Shape_SetColor()  -- Set texture's original color(s).
    Shape_SetColor(config.ShapeColorR, config.ShapeColorG, config.ShapeColorB)

    ----------------
    -- LOAD MODEL --
    ----------------
    if not CursorModel then
        ----assert(UnitAffectingCombat("player") ~= true)
        CursorModel = CreateFrame("PlayerModel", nil, kGameFrame)
        CursorModel:SetAllPoints()

        -- After the parent frame (UIParent) is unhidden, we must reload the cursor model to see it again.
        CursorModel:SetScript("OnHide", function(self)
                if (kGameFrame:IsShown() ~= true)  then
                    CursorModel.bReloadOnShow = true
                end
            end)
        CursorModel:SetScript("OnShow", function(self)
                if (CursorModel.bReloadOnShow == true) then
                    CursorTrail_Load()
                    CursorModel.bReloadOnShow = nil
                end
            end)
    end

    CursorModel_Init()
    CursorModel_SetModel(config.ModelID)
    CursorModel:SetCustomCamera(1) -- Very important! (Note: CursorModel:SetCamera(1) doesn't work here.)
    CursorTrail_ApplyModelSettings(config.UserScale,
                                   config.UserOfsX,
                                   config.UserOfsY,
                                   config.UserAlpha)
    CursorTrail_SetFadeOut(config.FadeOut)
    CursorModel:SetFrameStrata(config.Strata)
    CursorModel:SetFrameLevel(kFrameLevel+1)  -- +1 so model is drawn in front of the shadow texture.

    if (CursorModel.Constants.BaseFacing ~= nil) then
        CursorModel:SetFacing(CursorModel.Constants.BaseFacing)
    end

    ------------
    -- FINISH --
    ------------
    gShowOrHide = kShow
    if config.FadeOut then gMotionIntensity = 1.0 end  -- So user can briefly see the cursor if fade is on.
    if OptionsFrame and OptionsFrame:IsShown() then return end  -- (Never hide effects while UI is open.)
    if config.UserShowOnlyInCombat and not UnitAffectingCombat("player") then
        -- Player not in combat, so don't show the cursor.
        gShowOrHide = kHide
    end
end

-------------------------------------------------------------------------------
function CursorTrail_ApplyModelSettings(userScale, userOfsX, userOfsY, userAlpha)
-- This function is for changing values that do not require recreating the model object.
-- It also forces the displayed model to refresh immediately.
-- It does not update PlayerConfig.
-- (Note: This single function was written instead of multiple separate functions for fastest performance.)

    ----print("userScale="..(userScale or "NIL")..", userOfs=("..(userOfsX or "NIL")..", "..(userOfsY or "NIL")..")")
    assert(CursorModel.Constants)

    -- Validate parameters.
    if (userScale == nil or userScale <= 0) then
        userScale = PlayerConfig.UserScale
    end
    userOfsX = userOfsX or PlayerConfig.UserOfsX
    userOfsY = userOfsY or PlayerConfig.UserOfsY
    if (userAlpha == nil or userAlpha <= 0) then
        userAlpha = PlayerConfig.UserAlpha or 1.0
    end

    -- Compute scale factor.
    local mult = kBaseMult * ScreenHypotenuse
    local baseScale = CursorModel.Constants.BaseScale
    local finalScale = userScale * baseScale
    ---->>> DIDN'T HELP.  CHANGING UI SCALE ALSO CHANGES THE ScaleMin VALUE.  WAS UNABLE TO DETERMINE CORRECT VALUE.
    ----if (CursorModel.Constants.ScaleMin and finalScale < CursorModel.Constants.ScaleMin) then
    ----    finalScale = CursorModel.Constants.ScaleMin
    ----end

    -- UPDATE MODEL --
    CursorModel:SetScale(finalScale)
    CursorModel:SetAlpha(userAlpha)
    ----print("CursorModel:GetEffectiveScale():", CursorModel:GetEffectiveScale()) -- i.e. finalScale * kGameFrame:GetEffectiveScale()
    ----if (CursorModel:GetEffectiveScale() < 0.0113) then printMsg(kAddonFolderName.." WARNING - Model scaled too small.  ") end

    -- Compute model step size and offset.
    CursorModel.StepX = CursorModel.Constants.BaseStepX * mult * finalScale
    CursorModel.StepY = CursorModel.Constants.BaseStepY * mult * finalScale
    CursorModel.OfsX = ((CursorModel.Constants.BaseOfsX * mult / baseScale) + userOfsX) / userScale
    CursorModel.OfsY = ((CursorModel.Constants.BaseOfsY * mult / baseScale) + userOfsY) / userScale

    -- UPDATE SHADOW --
    if ShadowTexture then
        -- Update shadow size based on current user scale.
        local shadowSize = kDefaultShadowSize * userScale
        ShadowTexture:SetSize(shadowSize, shadowSize)

        ----ShadowTexture.OfsX = (CursorModel.StepX * userOfsX)
        ----ShadowTexture.OfsY = (CursorModel.StepY * userOfsY)
    end

    -- UPDATE SHAPE --
    if ShapeTexture then
        ShapeTexture:SetAlpha(userAlpha)

        -- Update shape size based on current user scale.
        local shapeSize = kDefaultShapeSize * userScale
        ShapeTexture:SetSize(shapeSize, shapeSize)
    end

    gPreviousX = nil  -- Forces cursor FX to refresh during the next OnUpdate().
end

-------------------------------------------------------------------------------
function CursorTrail_Show()
    CursorModel_Show()
    if ShadowTexture then
        ShadowTexture:Show()
    end
    if ShapeTexture then
        ShapeTexture:Show()
    end

    gShowOrHide = nil  -- Reset.
end

-------------------------------------------------------------------------------
function CursorTrail_Hide()
    CursorModel_Hide()
    if ShadowTexture then
        ShadowTexture:Hide()
    end
    if ShapeTexture then
        ShapeTexture:Hide()
    end
    gShowOrHide = nil  -- Reset.
end

-------------------------------------------------------------------------------
function CursorTrail_SetFadeOut(bFadeOut)
    gMotionIntensity = 0
    PlayerConfig.FadeOut = bFadeOut or false
    if (PlayerConfig.FadeOut == true) then
        CursorModel:SetAlpha(0)
        if ShadowTexture then
            ShadowTexture:SetAlpha(0)
        end
        if ShapeTexture then
            ShapeTexture:SetAlpha(0)
        end
    else
        CursorModel:SetAlpha(PlayerConfig.UserAlpha)
        if ShadowTexture then
            ShadowTexture:SetAlpha(PlayerConfig.UserShadowAlpha)
        end
        if ShapeTexture then
            ShapeTexture:SetAlpha(PlayerConfig.UserAlpha)
        end
    end
    ----gPreviousX = nil  -- Forces cursor FX to refresh during the next OnUpdate().
end

-------------------------------------------------------------------------------
function CursorTrail_SetShapeSparkle(bSparkle)
    PlayerConfig.ShapeSparkle = bSparkle or false
    if not PlayerConfig.ShapeSparkle then
        local r, g, b = OptionsFrame.ShapeColor:GetColor()
        if not r or not g or not b then
            r, g, b = PlayerConfig.ShapeColorR, PlayerConfig.ShapeColorG, PlayerConfig.ShapeColorB
        end
        Shape_SetColor(r, g, b)
    end
end

-------------------------------------------------------------------------------
function CursorModel_Init()
    if CursorModel then
        CursorModel:ClearModel()
        CursorModel:SetScale(1)  -- Very important!
        CursorModel:SetModelScale(1)
        CursorModel:SetPosition(0, 0, 0)  -- Very Important!
        CursorModel:SetAlpha(1.0)
        CursorModel:SetFacing(0)

        CursorModel.Constants = nil
        CursorModel.OfsX = nil
        CursorModel.OfsY = nil
        CursorModel.StepX = nil
        CursorModel.StepY = nil
        CursorModel.IsHidden = nil
    end
end

-------------------------------------------------------------------------------
function CursorModel_SetModel(modelID)
    modelID = modelID or kDefaultModelID
    CursorModel.Constants = CopyTable( kModelConstants[modelID] or kModelConstants[kDefaultModelID] )
    CursorModel.Constants.sortedID = modelID
    if (modelID > 0) then
        CursorModel:SetModel(modelID)
    end
    ----dbg("CursorModel:GetModelFileID() --> "..(CursorModel:GetModelFileID() or "nil"))
end

-------------------------------------------------------------------------------
function CursorModel_Show()
    -- Note: The normal Show() and Hide() don't work right (reason unknown).
    if not CursorModel then return end
    if (CursorModel.Constants.sortedID == 0) then -- Is model set to "None"?
        CursorModel_Hide()
    elseif (CursorModel.IsHidden ~= false) then -- Is model hidden?
        -- Unhide it.
        local alpha = PlayerConfig.UserAlpha or 1.0
        if (PlayerConfig.FadeOut == true) then alpha = alpha * gMotionIntensity end
        CursorModel:SetAlpha(alpha)
        CursorModel.IsHidden = false
    end
end

-------------------------------------------------------------------------------
function CursorModel_Hide()
    -- Note: The normal Show() and Hide() don't work right (reason unknown).
    if (CursorModel and CursorModel.IsHidden ~= true) then  -- Is model shown?
        -- Hide it.
        CursorModel:SetAlpha(0)
        CursorModel.IsHidden = true
        ----gMotionIntensity = 0
    end
end

-------------------------------------------------------------------------------
function Shadow_Create()
    if not ShadowFrame then
        ShadowFrame = CreateFrame("Frame", nil, kGameFrame)
        ShadowFrame:SetFrameStrata("BACKGROUND")
        ShadowFrame:SetFrameLevel(kFrameLevel)
        ShadowTexture = ShadowFrame:CreateTexture()
        ShadowTexture:SetBlendMode("ALPHAKEY")
        ShadowTexture:SetTexture([[Interface\GLUES\Models\UI_Alliance\gradient5Circle]])
        ----ShadowTexture:SetTexture([[Interface\GLUES\Models\UI_Draenei\GenericGlow64]])
        ----ShadowTexture:SetColorTexture(1,1,1,1)  DIDN'T WORK!
        ----ShadowTexture:SetVertexColor(1,1,1,1)  DIDN'T WORK!  (Only works for non-black textures.)
    end
end

-------------------------------------------------------------------------------
function Shape_Create()
    if not ShapeFrame then
        ShapeFrame = CreateFrame("Frame", nil, kGameFrame)
        ShapeFrame:SetFrameStrata("HIGH")
        ShapeFrame:SetFrameLevel(kFrameLevel+2)  -- +2 so shape is drawn in front of the model and shadow.
        ShapeTexture = ShapeFrame:CreateTexture()
        ----ShapeTexture:SetBlendMode("ALPHAKEY")
    end
end

-------------------------------------------------------------------------------
function Shape_SetTexture(shapeFileName)
    if ShapeTexture then
        if (shapeFileName == kStr_None) then
            ShapeTexture:SetTexture(nil)  -- Clear current texture.
        else
            ShapeTexture:SetTexture(shapeFileName)
        end
    end
end

-------------------------------------------------------------------------------
function Shape_SetColor(r, g, b, a)  -- Pass in nothing to use the texture's original color(s).
    if (not r and not g and not b and not a) then a = 1 end
    ShapeTexture:SetVertexColor(r or 1, g or 1, b or 1, a)  -- RGBa
end

-------------------------------------------------------------------------------
function unskew(inX, inY, inHorizontalSlope, topMult, bottomMult) -- Compensates for perimeter skewing built into some models.
    local x, y = inX, inY
    local dx = inX - ScreenMidX  -- Horizontal delta from center of screen.
    local dy = inY - ScreenMidY  -- Vertical delta from center of screen.

    -- Initialize skew factors for sides of screen depending on if cursor is above or below middle of screen.
    topMult = topMult or 0.985
    bottomMult = bottomMult or 1.105

    -- Multiply X coord by a variable factor based on the Y coord.
    local vertRange = topMult - bottomMult
    local multX = bottomMult + (vertRange*inY/ScreenH)
    x = ScreenMidX + (dx * multX)

    -- Multiply Y coord by a variable factor based on whether the Y coord is in the top or bottom half of the screen.
    if (dy < 0) then
        -- Bottom half of screen.
        y = ScreenMidY + (dy * 1.11)
        ----if (dy > -ScreenFourthH) then DebugText("Bottom 1") else DebugText("Bottom 2") end
        if (dy > -ScreenFourthH) then
            y = ScreenMidY + (dy * kScreenBottomFourthMult)
        else
            ----y = ScreenMidY + ((-ScreenFourthH * kScreenBottomFourthMult) + ((dy+ScreenFourthH) * 1.138))
            ----y = ScreenMidY + ((-ScreenFourthH * kScreenBottomFourthMult) + ((dy+ScreenFourthH) * kScreenBottomFourthMult * 1.0566))
            ----y = ScreenMidY + ((-ScreenFourthH + ((dy+ScreenFourthH) * 1.0566)) * kScreenBottomFourthMult)
            y = ScreenMidY + ((((dy+ScreenFourthH) * 1.0566) - ScreenFourthH) * kScreenBottomFourthMult)
        end
    else
        -- Top half of screen.
        y = ScreenMidY + (dy * 0.99)
        ----if (dy < ScreenFourthH) then DebugText("Top 1") else DebugText("Top 2") end
        if (dy < ScreenFourthH) then
            y = ScreenMidY + (dy * kScreenTopFourthMult)
        else
            ----y = ScreenMidY + ((ScreenFourthH * kScreenTopFourthMult) + ((dy-ScreenFourthH) * 0.966))
            ----y = ScreenMidY + ((ScreenFourthH * kScreenTopFourthMult) + ((dy-ScreenFourthH) * kScreenTopFourthMult * 0.9517))
            ----y = ScreenMidY + ((ScreenFourthH + ((dy-ScreenFourthH) * 0.9517)) * kScreenTopFourthMult)
            y = ScreenMidY + ((((dy-ScreenFourthH) * 0.9517) + ScreenFourthH) * kScreenTopFourthMult)
        end
    end

    -- Adjust the Y coord by a dynamic offset based on the X coord.
    y = y - (inHorizontalSlope * dx / ScreenMidX)
    ----x = x - (inVerticalSlope * dy / ScreenMidY)

    return x, y
end

--- End of File ---
