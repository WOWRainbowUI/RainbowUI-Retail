--[[---------------------------------------------------------------------------
    Addon:  CursorTrail
    File:   Switches.lua
    Desc:   Feature switches for this addon.
-----------------------------------------------------------------------------]]

local kAddonFolderName, private = ...

local C_Timer = C_Timer
local print = print

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
--[[                       Switches                                          ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

kDebug = false  -- TODO: Set to *false* before releases!
kEditBaseValues = false  -- Set to true so arrow keys change base offsets and step size while UI is up.  (Developers only!)
                        -- Arrow keys (no modifier key) change BaseOfsX and BaseOfsY.
                        -- Alt causes arrow keys to change BaseStepX and BaseStepY.
                        -- Shift decrease the amount of change each arrow key press.
                        -- Ctrl increase the amount of change each arrow key press.
                        -- When done, type "/ct model" to dump all values (BEFORE CLOSING THE UI).
kShadowStrataMatchesMain = false  -- Set to true if you want shadow at same level as the trail effect.
kShowColorPickerOpacity = false  -- Set to true to show the opacity slider in the color picker window.

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                        Debug Warning                                    ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

if kDebug or kEditBaseValues then
    local heading = "[".. kAddonFolderName .."]|cffFF0000* * * WARNING * * *|r "
    local msg = "switch is set to true!"
    C_Timer.After(2.9, function()
        if kDebug then
            print(heading, "kDebug", msg)
        end
        if kEditBaseValues then
            print(heading, "kEditBaseValues", msg)
        end
    end)
end

--- End of File ---
