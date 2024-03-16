--[[---------------------------------------------------------------------------
    Addon:  CursorTrail
    File:   CursorTrailTools.lua
    Desc:   This contains non-essential functions that were useful during
            the development of this addon, and may be useful in the future
            if Blizzard changes their model API again.
-----------------------------------------------------------------------------]]

local kAddonFolderName, private = ...

--[[                       Saved (Persistent) Variables                      ]]
CursorTrail_PlayerConfig = CursorTrail_PlayerConfig or {}

--[[                       Aliases to Globals                                ]]
local Globals = _G
local _  -- Prevent tainting global _ .
local assert = _G.assert
local C_Timer = _G.C_Timer
local CreateFrame = _G.CreateFrame
local CopyTable = _G.CopyTable
local date = _G.date
local floor = _G.floor
local GetBuildInfo = _G.GetBuildInfo
local GetCurrentResolution = _G.GetCurrentResolution
local GetCursorPosition = _G.GetCursorPosition
local GetScreenResolutions = _G.GetScreenResolutions
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetTime = _G.GetTime
local geterrorhandler = _G.geterrorhandler
local max =_G.math.max
local min =_G.math.min
local next = _G.next
local pairs = _G.pairs
local PlaySound = _G.PlaySound
local print = _G.print
local select = _G.select
local SOUNDKIT = _G.SOUNDKIT
local string = _G.string
local table = _G.table
local tonumber = _G.tonumber
local type = _G.type
local UIParent = _G.UIParent
local WorldFrame = _G.WorldFrame
local xpcall = _G.xpcall

--[[                       Declare Namespace                                 ]]
local CursorTrail = _G.CursorTrail or {}
if (not _G.CursorTrail) then _G.CursorTrail = CursorTrail end

--[[                       Remap Global Environment                          ]]
setfenv(1, _G.CursorTrail)  -- Everything after this uses our namespace rather than _G.

--[[                       Helper Functions                                  ]]

-------------------------------------------------------------------------------
function printMsg(msg)
	(Globals.SELECTED_CHAT_FRAME or Globals.DEFAULT_CHAT_FRAME):AddMessage(msg)
end

-------------------------------------------------------------------------------
function vdt_dump(varValue, varDescription)  -- e.g.  vdt_dump(someVar, "Checkpoint 1")
    if Globals.ViragDevTool_AddData then
        Globals.ViragDevTool_AddData(varValue, varDescription)
    end
end

-------------------------------------------------------------------------------
function dumpObject(obj, heading, indents)
    local dataType
 
    indents = indents or ""
    heading = heading or "Object Dump"
    if (heading ~= nil and heading ~= "") then print(indents .. heading .. " ...") end
    if (obj == nil) then print(indents .. "Object is NIL."); return end
    indents = indents .. "    "
 
    local count = 0
    local varName, value
    for varName, value in pairs(obj) do
        count = count + 1
        varName = "|cff9999ff" .. varName .. "|r" -- xRGB
        dataType = type(value)
        if (dataType == nil or dataType == "nil") then
            print(indents .. varName .. " = nil")
        elseif (dataType=="string") then
            print(indents .. varName .. " = '" .. (value or "nil") .. "'")
        elseif (dataType=="number") then
            print(indents .. varName .. " = " .. (value or "nil"))
        elseif (dataType=="boolean") then
            print(indents .. varName .. " = " .. (value and "true" or "false"))
        else
            print(indents .. varName .. " = " .. dataType)
            if (dataType=="table") then dumpObject(value, "", indents) end
        end
    end
    if (count == 0) then print(indents .. "Object is empty.") end
end
--~ -------------------------------------------------------------------------------
--~ function dumpObjectSorted(obj, heading, indents)
--~     local dataType
--~  
--~     indents = indents or ""
--~     heading = heading or "Object Dump"
--~     if (heading ~= nil and heading ~= "") then print(indents .. heading .. " ...") end
--~     if (obj == nil) then print(indents .. "Object is NIL."); return end
--~     indents = indents .. "    "
--~  
--~     local count = 0
--~     local varName, value
--~     local lines = {}
--~     for varName, value in pairs(obj) do
--~         count = count + 1
--~         varName = "|cff9999ff" .. varName .. "|r" -- xRGB
--~         dataType = type(value)
--~         if (dataType == nil or dataType == "nil") then
--~             lines[count] = indents .. varName .. " = nil"
--~         elseif (dataType=="string") then
--~             lines[count] = indents .. varName .. " = '" .. (value or "nil") .. "'"
--~         elseif (dataType=="number") then
--~             lines[count] = indents .. varName .. " = " .. (value or "nil")
--~         elseif (dataType=="boolean") then
--~             lines[count] = indents .. varName .. " = " .. (value and "true" or "false")
--~         else
--~             lines[count] = indents .. varName .. " = " .. dataType .. "  (See above.)"
--~             if (dataType=="table") then dumpObject(value, varName, indents) end
--~         end
--~     end
--~     if (count == 0) then 
--~         print(indents .. "Object is empty.") 
--~     else
--~         table.sort(lines)
--~         for i = 1, #lines do print(lines[i]) end
--~     end
--~ end

-------------------------------------------------------------------------------
function round(val, numDecimalPositions)
    if (val == nil) then return "NIL" end
    if (numDecimalPositions == nil) then numDecimalPositions = 0 end

    local factor = 10 ^ numDecimalPositions
    val = val * factor
    val = floor(val + 0.5)
    val = val / factor
    return val
end

-------------------------------------------------------------------------------
function isEmpty(var)  -- Returns true if the variable is nil, or is an empty table {}.
    if (var == nil or next(var) == nil) then return true else return false end
end

-------------------------------------------------------------------------------
function isDigit(val)  -- 'val' must be a string type.
   local digit = tonumber(val)
   if (digit and digit >= 0 and digit <= 9) then return true else return nil end
end

-------------------------------------------------------------------------------
function isNumber(val)  -- 'val' can be a number or string containing a number.
   if tonumber(val) then return true else return nil end
end

-------------------------------------------------------------------------------
function isInteger(val)  -- 'val' can be a number or string containing a number.
   local num = tonumber(val)
   if (num and math.floor(num) == num) then return true else return nil end
end

-------------------------------------------------------------------------------
function str_split(str, delimiter)
    assert(delimiter)
    local parts = {}
    for part in string.gmatch(str, "([^"..delimiter.."]+)") do
        table.insert(parts, part)
    end
    ----for i = 1, #parts do print("Part#"..i.." = ".. parts[i]) end  -- Dump results.
    return parts
end

-------------------------------------------------------------------------------
----kMinVer_Vanilla = 00000
----kMaxVer_Vanilla = 19999
----kMinVer_Wrath   = 20000
----kMaxVer_Wrath   = 29999
----kMinVer_Retail  = 100000
kGameTocVersion = kGameTocVersion or select(4, GetBuildInfo())
function isVanillaWoW() return (kGameTocVersion < 20000) end
function isWrathWoW()   return (kGameTocVersion >= 30000 and kGameTocVersion < 40000) end
function isRetailWoW()  return (kGameTocVersion >= 100000) end
----UNTESTED:  local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
----UNTESTED:  local isWrath = (WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC)
----UNTESTED:  local isDragonflight = floor(select(4, GetBuildInfo()) / 10000) == 10

-------------------------------------------------------------------------------
function compareVersions(verA, verB)
-- Returns 0 if equal, 1 if verA is newer, or 2 if verB is newer.
    assert(verA or verB)  -- One must exist!
    local a = str_split(verA, ".")
    local b = str_split(verB, ".")
    local maxParts = max(#a, #b)
    assert(maxParts and maxParts > 0) -- Empty strings?  Missing dots?

    for i = 1, maxParts do
        if     (a[i] ~= nil and b[i] == nil) then return 1
        elseif (a[i] == nil and b[i] ~= nil) then return 2
        else -- Both parts exist.
            if     (a[i] > b[i]) then return 1
            elseif (a[i] < b[i]) then return 2
            end
        end
    end

    return 0  -- verA = verB
end
--~     function compareVersions_UnitTest()
--~         print("compareVersions_UnitTest() ... STARTING")
--~         print( "Test 01:", compareVersions("12.3.456.7", "12.3.456.7") )  --> 0
--~         print( "Test 02:", compareVersions("12.3.456.7", "12.3.456"  ) )  --> 1
--~         print( "Test 03:", compareVersions("12.3.456",   "12.3.456.7") )  --> 2
--~         print( "Test 04:", compareVersions("12.3.456.7", ""          ) )  --> 1
--~         print( "Test 05:", compareVersions("", "12.3.456.7"          ) )  --> 2
--~                ----------
--~         print( "Test 06:", compareVersions("3.4.5.6", "0.4.5.6"      ) )  --> 1
--~         print( "Test 07:", compareVersions("3.4.5.6", "9.4.5.6"      ) )  --> 2

--~         print( "Test 08:", compareVersions("3.4.5.6", "3.0.5.6"      ) )  --> 1
--~         print( "Test 09:", compareVersions("3.4.5.6", "3.9.5.6"      ) )  --> 2

--~         print( "Test 10:", compareVersions("3.4.5.6", "3.4.0.6"      ) )  --> 1
--~         print( "Test 11:", compareVersions("3.4.5.6", "3.4.9.6"      ) )  --> 2

--~         print( "Test 12:", compareVersions("3.4.5.6", "3.4.5.0"      ) )  --> 1
--~         print( "Test 13:", compareVersions("3.4.5.6", "3.4.5.9"      ) )  --> 2
--~                ----------
--~         print( "Test 14:", compareVersions("9.4.5.6", "3.4.5.6"      ) )  --> 1
--~         print( "Test 15:", compareVersions("0.4.5.6", "3.4.5.6"      ) )  --> 2

--~         print( "Test 16:", compareVersions("3.9.5.6", "3.4.5.6"      ) )  --> 1
--~         print( "Test 17:", compareVersions("3.0.5.6", "3.4.5.6"      ) )  --> 2

--~         print( "Test 18:", compareVersions("3.4.9.6", "3.4.5.6"      ) )  --> 1
--~         print( "Test 19:", compareVersions("3.4.0.6", "3.4.5.6"      ) )  --> 2

--~         print( "Test 20:", compareVersions("3.4.5.9", "3.4.5.6"      ) )  --> 1
--~         print( "Test 21:", compareVersions("3.4.5.0", "3.4.5.6"      ) )  --> 2
--~                ----------
--~         print( "Test 22:", compareVersions("123.4567", "123.4567"    ) )  --> 0
--~         print("compareVersions_UnitTest() ... DONE.")
--~     end

-------------------------------------------------------------------------------
function dbg(msg)
    ----local timestamp = GetTime()
    ----local timestamp = date("%Y-%m-%d %H:%M:%S")
    local timestamp = date("%I:%M:%S")
    print("|c00ff3030["..timestamp.."] "..(kAddonName or "")..": "..(msg or "nil").."|r")  -- Color format = xRGB.
end

-------------------------------------------------------------------------------
function errHandler(msg)  -- Used by xpcall().  See also the Blizzard function, geterrorhandler().
    dbg(msg)
    print("Call Stack ...\n" .. debugstack(2, 3, 2))
end

--[[                       Text Frame Functions                              ]]

--~ -------------------------------------------------------------------------------
--~ function TextFrame_SetText(txt)
--~     if (txt == nil or txt == "") then  -- Empty text string.  Hide the text frame.
--~         if TextFrame then -- Close the text frame.
--~             TextFrame:Hide()
--~             TextFrameText = nil
--~             TextFrame = nil
--~         end
--~     else  -- 'txt' parameter is not empty.
--~         if not TextFrame then TextFrame_Create() end
--~         if TextFrameText then
--~             TextFrameText:SetText(txt)
--~             TextFrame:Show()
--~         else
--~             print(txt)
--~         end
--~     end
--~ end

--~ -------------------------------------------------------------------------------
--~ function TextFrame_Create()
--~     if TextFrame then TextFrame_Close() end
--~     TextFrame = CreateFrame("frame", "CursorTrailTextFrame", UIParent)

--~     -- Text Window
--~     TextFrame:SetScale(2.0)
--~     TextFrame:SetPoint("CENTER", "UIParent", "CENTER", 0, -ScreenH * 0.1)
--~     TextFrame:SetFrameStrata("DIALOG")
--~     TextFrame:SetToplevel(true)
--~     TextFrame:SetSize(ScreenW, 50)

--~     -- Text Window's Text
--~     TextFrameText = TextFrame:CreateFontString(nil,"OVERLAY", "GameFontNormal")
--~     TextFrameText:SetPoint("CENTER", TextFrame, "CENTER", 0, 0)
--~     TextFrameText:SetJustifyH("CENTER")
--~     TextFrameText:SetJustifyV("CENTER")
--~ end

-------------------------------------------------------------------------------
function DebugText(txt, width, height)
    if not DbgFrame then
        -- Create the frame.
        DbgFrame = CreateFrame("frame", kAddonName.."DebugFrame", nil, "BackdropTemplate")
        DbgFrame:Hide()
        DbgFrame:SetPoint("CENTER", UIParent, "CENTER")
        DbgFrame:SetFrameStrata("TOOLTIP")
        DbgFrame:SetToplevel(true)

        DbgFrame:SetBackdrop({
            bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile="",
            tile = false, tileSize = 32, edgeSize = 24,
            insets = {left = 0, right = 0, top = 0, bottom = 0}
        })
        DbgFrame:SetBackdropColor(0,0,0, 1)

        DbgFrame.text = DbgFrame:CreateFontString(nil,"OVERLAY","GameFontNormal") ----"GameFontNormalSmall")
        DbgFrame.text:SetJustifyH("LEFT")
        DbgFrame.text:SetJustifyV("TOP")
        DbgFrame.text:SetPoint("TOPLEFT", DbgFrame, "TOPLEFT", 4, -4)

        -- Allow moving the frame.
        DbgFrame:EnableMouse(true)
        DbgFrame:SetMovable(true)
        DbgFrame:SetClampedToScreen(true)
        DbgFrame:SetClampRectInsets(250, -250, -350, 350)
        DbgFrame:RegisterForDrag("LeftButton")
        DbgFrame:SetScript("OnDragStart", function() DbgFrame:StartMoving() end)
        DbgFrame:SetScript("OnDragStop", function() DbgFrame:StopMovingOrSizing() end)
    end

    -- Hide frame if specified text is empty.
    if (txt == nil or txt == "") then return DbgFrame:Hide() end

    -- Otherwise, show the specified text.
    DbgFrame.text:SetText(txt)
    width = width or DbgFrame.text:GetStringWidth()+8
    if (width == nil or width == 0)   then width = 150 end
    if (height == nil or height == 0) then height = 20 end
    DbgFrame:SetWidth(width)
    DbgFrame:SetHeight(height)
    DbgFrame:Show()
end

-------------------------------------------------------------------------------
function msgBox(msg,
                btnText1, btnFunc1,
                btnText2, btnFunc2,
                customData, bShowAlertIcon, soundID, timeoutSecs)
-- REQUIRES:    'kAddonName' to have been set to the addon's name.  i.e. First line
--              of your lua file should look like this -->  local kAddonName = ...
-- Examples:
--      msgBox("Job done.")
--      msgBox("Bad data found!  Click OK to use it anyway, or CANCEL to restore defaults.",
--              "OK", saveMyData,
--              "Cancel", restoreMyDefaultData,
--              myDataBuffer, true, SOUNDKIT.ALARM_CLOCK_WARNING_2)
--      msgBox("Uh oh! Show help?\n\n(This message goes away after 15 seconds.)",
--              "Yes", showMyHelp,
--              "No", nil,
--              nil, false, SOUNDKIT.ALARM_CLOCK_WARNING_3, 15)
--
-- For more info, see...
--      https://wowwiki-archive.fandom.com/wiki/Creating_simple_pop-up_dialog_boxes
    local dialogID = "MSGBOX_FOR_" .. kAddonName

    if (btnText1 == "" or btnText1 == nil) then btnText1 = "OK" end
    if (btnText2 == "") then btnText2 = nil end
    if (bShowAlertIcon ~= true) then bShowAlertIcon = nil end  -- Forces it to be 'true' or 'nil'.

    Globals.StaticPopupDialogs[dialogID] =
    {
        text = (msg or ""),
        showAlert = bShowAlertIcon,
        sound = soundID,
        timeout = timeoutSecs,

        enterClicksFirstButton = true,
        hideOnEscape = true,
        whileDead = true,
        ----exclusive = true,  -- Makes the popup go away if any other popup is displayed.
        ----preferredIndex = 3,

        button1 = btnText1,
        OnAccept = btnFunc1,

        button2 = btnText2,
        OnCancel = btnFunc2,

        OnHide = function(self) self.data = nil; self.selectedIcon = nil; end,
    }

    local dlgBox = Globals.StaticPopup_Show(dialogID)
    if dlgBox then
        dlgBox.data = customData
        ----dlgBox.data2 = customData2
    end
end

-------------------------------------------------------------------------------
function showErrMsg(msg)
-- REQUIRES:    'kAddonName' to have been set to the addon's name.  i.e. First line
--              of your lua file should look like this -->  local kAddonName = ...
    local bar = ":::::::::::::"
    msgBox( bar.." [ "..kAddonName.." ] "..bar.."\n\n"..msg,
            nil, nil,
            nil, nil,
            nil, true, SOUNDKIT.ALARM_CLOCK_WARNING_3 )
end

--[[                          Tool Functions                                 ]]

-------------------------------------------------------------------------------
function HandleToolSwitches(params)
    local paramAsNum = tonumber(params)

    if (params == "screen") then
        Screen_Dump()
    elseif (params == "camera") then
        Camera_Dump()
    elseif (params == "config") then
        dumpObject(PlayerConfig, "CONFIG INFO")
    elseif (params == "model") then
        CursorModel_Dump()
    ----elseif (params == "cal") then
    ----    Calibrating_DoNextStep()
    ----elseif (params == "track") then
    ----    TrackPosition()
    -----------------------------------------------------
    -- NOTE: You can also enable the switch "kEditBaseValues" in the main file and then use
    --       the arrow keys to alter the values below (while the UI is displayed).
    --       Arrow keys (no modifier key) change BaseOfsX and BaseOfsY.
    --       Alt causes arrow keys to change BaseStepX and BaseStepY.
    --       Shift decrease the amount of change each arrow key press.
    --       Ctrl increase the amount of change each arrow key press.
    --       When done, type "/ct model" to dump all values (BEFORE CLOSING THE UI).
    elseif (params:sub(1,5) == "box++") then CmdLineValue("BaseOfsX",  params:sub(6), "+")
    elseif (params:sub(1,5) == "boy++") then CmdLineValue("BaseOfsY",  params:sub(6), "+")
    elseif (params:sub(1,5) == "bsx++") then CmdLineValue("BaseStepX", params:sub(6), "+")
    elseif (params:sub(1,5) == "bsy++") then CmdLineValue("BaseStepY", params:sub(6), "+")
    elseif (params:sub(1,5) == "box--") then CmdLineValue("BaseOfsX",  params:sub(6), "-")
    elseif (params:sub(1,5) == "boy--") then CmdLineValue("BaseOfsY",  params:sub(6), "-")
    elseif (params:sub(1,5) == "bsx--") then CmdLineValue("BaseStepX", params:sub(6), "-")
    elseif (params:sub(1,5) == "bsy--") then CmdLineValue("BaseStepY", params:sub(6), "-")
    elseif (params:sub(1,3) == "box")   then CmdLineValue("BaseOfsX",  params:sub(4))
    elseif (params:sub(1,3) == "boy")   then CmdLineValue("BaseOfsY",  params:sub(4))
    elseif (params:sub(1,3) == "bsx")   then CmdLineValue("BaseStepX", params:sub(4))
    elseif (params:sub(1,3) == "bsy")   then CmdLineValue("BaseStepY", params:sub(4))
    elseif (params:sub(1,4) == "bs++")  then CmdLineValue("BaseScale", params:sub(5), "+")
    elseif (params:sub(1,4) == "bs--")  then CmdLineValue("BaseScale", params:sub(5), "-")
    elseif (params:sub(1,2) == "bs")    then CmdLineValue("BaseScale", params:sub(3))
    elseif (params:sub(1,4) == "bf++")  then CmdLineValue("BaseFacing",params:sub(5), "+")
    elseif (params:sub(1,4) == "bf--")  then CmdLineValue("BaseFacing",params:sub(5), "-")
    elseif (params:sub(1,2) == "bf")    then CmdLineValue("BaseFacing",params:sub(3))
    elseif (params:sub(1,4) == "hs++")  then CmdLineValue("HorizontalSlope", params:sub(5), "+")
    elseif (params:sub(1,4) == "hs--")  then CmdLineValue("HorizontalSlope", params:sub(5), "-")
    elseif (params:sub(1,2) == "hs")    then CmdLineValue("HorizontalSlope", params:sub(3))
    ----elseif (params == "mdl++")          then OptionsFrame_IncrDecrModel(1)
    ----elseif (params == "mdl--")          then OptionsFrame_IncrDecrModel(-1)
    -----------------------------------------------------
    elseif (params:sub(1,3) == "mdl") then
        local modelID = tonumber(params:sub(4))
        local msg = kAddonName
        if (modelID == nil) then
            modelID = CursorModel:GetModelFileID()
            msg = msg .. " model ID is " .. (modelID or "NIL") .. "."
        else
            local origBaseScale = CursorModel.Constants.BaseScale
            local tmpConfig = CopyTable(kDefaultConfig)
            tmpConfig.ModelID = modelID
            CursorTrail_Load(tmpConfig)
            CursorTrail_Show()
            CursorModel.Constants.BaseScale = origBaseScale
            CursorModel.Constants.BaseStepX = 3330
            CursorModel.Constants.BaseStepY = 3330
            CursorTrail_ApplyModelSettings()
            msg = msg .. " changed model ID to " .. (modelID or "NIL") .. "."
        end
        print(msg)
    elseif (params:sub(1,3) == "pos") then  -- Set position (0,0), (1,1), (2,2), etc.
        local delta = tonumber(params:sub(4))
        CursorModel:SetPosition(0, delta, delta)
    elseif (params:sub(1,9) == "testmodel") then
        local modelID = tonumber(params:sub(10))
        if not TestCursorModel then
            TestCursorModel = CreateFrame("PlayerModel", nil, kGameFrame)
        end
        TestCursorModel:SetAllPoints()
        TestCursorModel:SetFrameStrata("TOOLTIP")
        TestCursorModel:ClearModel()
        TestCursorModel:SetScale(1)  -- Very important!
        TestCursorModel:SetPosition(0, 0, 0)  -- Very Important!
        TestCursorModel:SetAlpha(1)
        TestCursorModel:SetFacing(0)
        if modelID then TestCursorModel:SetModel(modelID) end
        TestCursorModel:SetCustomCamera(1) -- Very important! (Note: CursorModel:SetCamera(1) doesn't work here.)
    ----elseif (paramAsNum ~= nil) then
    ----    print(kAddonName .. " processed number", paramAsNum, ".")
    elseif (params == "fonts") then
        private.Controls.DisplayAllFonts()
    elseif (params == "bug") then  -- Cause a bug to test error handling.
        xpcall(bogus_function, geterrorhandler())
        ----xpcall(bogus_function, errHandler)
    else
        return false  -- 'params' was NOT handled by this function.
    end

    return true  -- 'params' WAS handled by this function.
end

-------------------------------------------------------------------------------
function CmdLineValue(name, val, plusOrMinus)
    val = tonumber(val)
    if (val == nil) then
        print(kAddonName .. " "..name.." is", CursorModel.Constants[name], ".")
    else
        if (plusOrMinus == "+") then
            val = CursorModel.Constants[name] + val
        elseif (plusOrMinus == "-") then
            val = CursorModel.Constants[name] - val
        end
        val = round(val, 3)

        if (name == "BaseScale") then
            PlayerConfig.UserScale = 1.0  -- Reset user offsets when changing base scale.
            CursorModel.Constants.BaseScale = 1.0  -- VERY IMPORTANT to do this first.
            CursorTrail_ApplyModelSettings()
        elseif (name:sub(1,7) == "BaseOfs") then
            -- Reset user offsets when changing base offsets.
            PlayerConfig.UserOfsX = 0
            PlayerConfig.UserOfsY = 0
        end

        CursorModel.Constants[name] = val  -- Change the specified value.
        CursorTrail_ApplyModelSettings()   -- Apply the change.
        print(kAddonName .. " changed "..name.." to", val, ".")
        ----if (name == "BaseScale") then CursorModel_Dump() end
    end
end

-------------------------------------------------------------------------------
function Screen_Dump(heading)
    -- Print the current resolution to chat.
    local origGameFrame = kGameFrame
    local width, height
    local indents = "    "
    
    print((heading or "SCREEN INFO") .. " ...")
    
    if GetCurrentResolution then  -- Use old API?
        ----NOT WORKING CORRECTLY ANYMORE ...
        ----local currentResolutionIndex = GetCurrentResolution()
        ----local resolution = select(currentResolutionIndex, GetScreenResolutions())
        ----print(indents.."Screen Resolution = "..(resolution or "Unknown"))
    else -- Use new API introduced in 10.0.
        ----width, height = Globals.GetPhysicalScreenSize()  SEEMS TO RETURN RESOLUTION, NOT PHYSICAL SIZE.
        ----print("  Screen Physical Size =", floor(width), "x", floor(height))
        local gameWindowSize = Globals.C_VideoOptions.GetCurrentGameWindowSize()
        width, height = gameWindowSize:GetXY()
        print(indents.."Screen Resolution =", floor(width), "x", floor(height))
    end

    for i = 1, 2 do
        if (i == 1) then
            print(indents.."-----[ WORLD FRAME ]-----")
            kGameFrame = WorldFrame
        else
            print(indents.."-----[ UI PARENT FRAME ]-----")
            kGameFrame = UIParent
        end

        local unscaledW, unscaledH = kGameFrame:GetSize()  -- i.e. getScreenSize()
        local scaledW, scaledH, scaledMidX, scaledMidY, uiscale, hypotenuse = getScreenScaledSize()  -- Uses kGameFrame.

        print(indents.."Window Size = "..round(unscaledW,2).." x "..round(unscaledH,2))
        print(indents.."Aspect Ratio = "..round(scaledW/scaledH,2))
        print(indents.."UI Scale = "..round(uiscale,3))
        print(indents.."Scaled Size = "..round(scaledW,2).." x "..round(scaledH,2))
        print(indents.."Scaled Center = ("..round(scaledMidX,2)..", "..round(scaledMidY,2)..")")
        print(indents.."Scaled Hypotenuse = "..round(hypotenuse,2))
    end

    local z, x, y = CursorModel:GetPosition()
    print("  Model Position (x,y,z): ("..round(x,1)..", "..round(y,1)..", "..round(z,1)..")")

    kGameFrame = origGameFrame
end

-------------------------------------------------------------------------------
function Camera_Dump(heading)
    assert(CursorModel)
    local z, x, y = CursorModel:GetCameraPosition()
    local tz, tx, ty = CursorModel:GetCameraTarget()

    heading = heading or "CAMERA INFO (Distance/Yaw/Pitch)"
    print( heading.." ..."
            .."\n  Camera Position = "
                ..round(z,3) -- Camera's distance from the view port?
                .."  /  "..round(x,3)   -- Rotation around the z-axis.
                .."  /  "..round(y,3)   -- Rotation around the y-axis.
            .."\n  Camera Target    = "
                ..round(tz,3)  -- Camera target's distance from the view port?
                .."  /  "..round(tx,3)    -- Rotation around the z-axis.
                .."  /  "..round(ty,3)    -- Rotation around the y-axis.
            .."\n  Model Yaw (Left/Right) =", round(CursorModel:GetFacing(),3)
            .."\n  Model Pitch (Up/Down) =", round(CursorModel:GetPitch(),3) )
end

-------------------------------------------------------------------------------
function CursorModel_Dump(heading)
    assert(CursorModel)
    dumpObject(CursorModel, heading or "MODEL INFO")
    local w, h = CursorModel:GetSize()
    print("|cff9999ff    Width =|r", round(w))
    print("|cff9999ff    Height =|r", round(h))
end

--~ -------------------------------------------------------------------------------
--~ function Calibrating_DoNextStep(abort)
--~     assert(ScreenHypotenuse)
--~     assert(PlayerConfig)
--~     assert(CursorModel)

--~     local function printStep(stepNum)
--~         TextFrame_SetText( "CALIBRATION STEP #" .. stepNum .. " of 3\n\n"
--~                         .. "(Click the center of the cursor effect.)" )
--~     end

--~     if abort then
--~         if Calibrating then
--~             CursorModel:EnableMouse(false)
--~             CursorModel:SetScale( Calibrating.OriginalModelScale )
--~             Calibrating = nil
--~             TextFrame_SetText()
--~             print(kAddonName.." calibration aborted.")
--~         end
--~         return
--~     end
--~
--~     if not Calibrating then
--~         --===[ STEP 1 ]===--
--~         Calibrating = {}
--~         Calibrating.Step = 1
--~         Calibrating.OriginalModelScale = CursorModel:GetScale()
--~         Calibrating.Scale = 1.0  ----Calibrating.OriginalModelScale
--~         Calibrating.Distance = 3  ----10
--~         Calibrating.Distance = Calibrating.Distance / Calibrating.Scale / ScreenScale
--~         Calibrating.MinMovementDistance = ScreenMidY * 0.70
--~
--~         Calibrating.BaseScale = CursorModel.Constants.BaseScale * Calibrating.Scale
--~         CursorModel:SetScale( Calibrating.BaseScale )
--~         CursorTrail_SetFadeOut(false)
--~         CursorModel:SetPosition(0, 0, 0)
--~         printStep(Calibrating.Step)
--~         PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
--~
--~         CursorModel:EnableMouse(true)
--~         CursorModel:SetScript("OnMouseUp", function(self, button)
--~             if (button == "LeftButton") then
--~                 Calibrating_DoNextStep()
--~             ----elseif (button == "RightButton") then
--~             ----    if (Calibrating.Scale > 0.1) then
--~             ----        Calibrating.Scale = Calibrating.Scale - 0.1
--~             ----        Calibrating.Distance = Calibrating.Distance / Calibrating.Scale / ScreenScale
--~             ----        Calibrating.BaseScale = CursorModel.Constants.BaseScale * Calibrating.Scale
--~             ----        CursorModel:SetScale( Calibrating.BaseScale )
--~             ----        CursorModel:SetPosition(0, 0, 0)
--~             ----        print("Calibration scale reduced to:", Calibrating.Scale)
--~             ----    end
--~             end
--~         end)
--~     else
--~         Calibrating.Step = Calibrating.Step + 1

--~         if (Calibrating.Step == 2) then
--~             --===[ STEP 2 ]===--
--~             Calibrating.x1, Calibrating.y1 = GetCursorPosition()
--~             ----print("Cal Raw Deltas 1: (".. round(ScreenMidX-Calibrating.x1) ..", "
--~             ----                           .. round(ScreenMidY-Calibrating.y1) ..")")
--~             CursorModel:SetPosition(0, Calibrating.Distance, Calibrating.Distance)
--~             printStep(Calibrating.Step)
--~             PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
--~         else
--~             local x1, y1 = Calibrating.x1, Calibrating.y1
--~             local x2, y2 = GetCursorPosition()
--~             ----print("Cal Raw Deltas ".. Calibrating.Step-1 ..": (".. round(ScreenMidX-(x2-Calibrating.Distance)) ..", "
--~             ----                                                    .. round(ScreenMidY-(y2-Calibrating.Distance)) ..")")
--~
--~             -- Compute the distance the model moves in screen coords when
--~             -- it is moved by one unit (1, 1) in the model's coordinate space.
--~             local dx, dy = (x2 - x1), (y2 - y1)
--~             local baseStepX = (dx / Calibrating.Distance)
--~             local baseStepY = (dy / Calibrating.Distance)

--~             if (Calibrating.Step == 3) then
--~                 --===[ STEP 3 ]===--
--~                 -- If the mouse wasn't moved far enough, increase the test distance and
--~                 -- try again.  (Helps get a more accurate result for unit step size.)
--~                 if (dy < Calibrating.MinMovementDistance) then
--~                     Calibrating.Distance = Calibrating.Distance * Calibrating.MinMovementDistance / dy
--~                     CursorModel:SetPosition(0, Calibrating.Distance, Calibrating.Distance)
--~                     printStep(Calibrating.Step)
--~                     PlaySound(SOUNDKIT.IG_MAINMENU_OPEN)
--~                 else
--~                     -- Skip to the final step.
--~                     ----print("Calibration Step #"..Calibrating.Step..": Skipped")
--~                     Calibrating.Step = Calibrating.Step + 1
--~                 end
--~             end

--~             if (Calibrating.Step == 4) then
--~                 --===[ FINAL STEP ]===--
--~                 if (baseStepX == 0 and baseStepY == 0) then
--~                     return Calibrating_DoNextStep("abort")  -- All clicks occurred at same spot.  Abort.
--~                 end

--~                 -- Compute offset from center of model to center of screen.
--~                 local baseOfsX, baseOfsY = (ScreenMidX - x1), (ScreenMidY - y1)
--~
--~                 ----print("dx = "..round(dx,2)..", dy = "..round(dy,2))
--~                 ----print("Raw Offset = ("..round(baseOfsX,2)..", "..round(baseOfsY,2)..")")
--~                 ----print("Raw Step Size = ("..round(baseStepX,2)..", "..round(baseStepY,2)..")")

--~                 -- Adjust the offset by the raw step size computed above.
--~                 baseOfsX = baseOfsX / baseStepX * Calibrating.Scale
--~                 baseOfsY = baseOfsY / baseStepY * Calibrating.Scale

--~                 ------ Tweak offsets so the tip of mouse cursor's finger appears over the model's center.
--~                 ----baseOfsX = baseOfsX + 0.2
--~                 ----baseOfsY = baseOfsY - 0.2
--~
--~                  -- Normalize the step sizes to 100% model scale so they can be used for any scale
--~                  -- later on simply by multiplying the model's current scale to them.
--~                 baseStepX = baseStepX / Calibrating.BaseScale
--~                 baseStepY = baseStepY / Calibrating.BaseScale
--~
--~                 -- Normalize the base values to a screen aspect ratio of 1:1 so they can be used
--~                 -- for any aspect ratio later on simply by multiplying the screen hypotenuse to them.
--~                 baseOfsX  = baseOfsX  / kBaseMult / ScreenHypotenuse
--~                 baseOfsY  = baseOfsY  / kBaseMult / ScreenHypotenuse
--~                 baseStepX = baseStepX / kBaseMult / ScreenHypotenuse
--~                 baseStepY = baseStepY / kBaseMult / ScreenHypotenuse

--~                 -- Round off.
--~                 local precision = 1
--~                 baseOfsX  = round(baseOfsX, precision)
--~                 baseOfsY  = round(baseOfsY, precision)
--~                 baseStepX = round(baseStepX, precision)
--~                 baseStepY = round(baseStepY, precision)

--~                 -- Clean up.
--~                 CursorModel:EnableMouse(false)
--~                 CursorModel:SetScale( Calibrating.OriginalModelScale )
--~                 CursorTrail_SetFadeOut( PlayerConfig.FadeOut )
--~
--~                 -- Display the results in the chat window.
--~                 PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE)
--~                 TextFrame_SetText()  -- Hides text frame.
--~                 local modelID = PlayerConfig.ModelID
--~                 print('|c00FFFF00Calibration RESULTS for model '..modelID..' ...|r' -- Color format = xRGB.
--~                         .."\n  Base Offset (X, Y) = ("..baseOfsX..", "..baseOfsY..")"
--~                         .."\n  Step Size (X, Y) = ("..baseStepX..", "..baseStepY..")"
--~                         .."|c00808080   Average = "..round((baseStepX+baseStepY)/2, precision).."|r" )

--~                 -- Refresh the cursor model base constants. (Note: Must hardcode the new values to make them permanent.)
--~                 kModelConstants[modelID].BaseOfsX = baseOfsX
--~                 kModelConstants[modelID].BaseOfsY = baseOfsY
--~                 kModelConstants[modelID].BaseStepX = baseStepX
--~                 kModelConstants[modelID].BaseStepY = baseStepY
--~                 CursorTrail_Load()
--~
--~                 Calibrating = nil  -- Done.
--~             end
--~         end
--~     end
--~ end

--- End of File ---