--[[---------------------------------------------------------------------------
    Addon:  CursorTrail
    File:   CursorTrailHelp.lua
    Desc:   Functions and variables for showing this addon's help text.
-----------------------------------------------------------------------------]]

local kAddonFolderName, private = ...

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Saved (Persistent) Variables                      ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

CursorTrail_PlayerConfig = CursorTrail_PlayerConfig or {}

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Aliases to Globals                                ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

local Globals = _G
local _  -- Prevent tainting global _ .
local print = _G.print

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

kHelpText_Options = [[
選項視窗可從 Esc>選項>插件>滑鼠，開啟，或是輸入 /ct 或 /cursortrail。設定是每個角色分開儲存的，因此 (例如) 你的戰坦可以擁有與其他角色不同的滑鼠游標效果。

* 圖形: 可供選擇的圖形清單。
圖形的顏色可透過點擊圖形選項右側的色票按鈕來變更。
啟用「閃閃發光」時，所選的圖形顏色將被忽略，而圖形將改為「閃爍」。(閃閃發光不會影響軌跡顏色。)

* 軌跡: 可供選擇的游標特效清單。可以利用下方的「調整位置」來移動位置。

* 陰影%: 控制黑色背景圓圈的強度。99% 最暗，而 0% 是隱形 (關閉)。

* 縮放大小%: 控制效果的大小。可以是 1 到 998。

* 不透明度%: 控制圖形和軌跡的透明度。100% 完全可見，而 0% 則是隱形 (關閉)。

* 框架層級: 控制圖形和軌跡繪製在其他使用者介面的後面或前面，不會影響陰影選項。(背景會繪製在最底層，而浮動提示則是最高層。)

* 調整位置: 移動軌跡特效的中心位置。第一個數字框是水平移動 (負數向左移動，正數向右移動)。第二個數字框是垂直移動 (負數向下移動，正數向上移動)。

* 滑鼠不動時隱藏: 啟用時，當滑鼠停止移動時，游標效果會淡出。

* 只在戰鬥中顯示: 啟用時，游標效果只會在戰鬥中出現。

* 用滑鼠控制視角時要顯示: 啟用時，游標效果在使用滑鼠環顧四周時仍會保持可見。

* 預設: 每個預設按鈕都有不同的預設選項。可以將它們作為自己效果的起點。(若要儲存自己的設定，請參閱下方的 /ct save 和 /ct load 指令。)
]]

kHelpText_ProfileCommands = [[
使用指令，可以在所有角色之間儲存和載入個人設定檔 (你的設定):

        /ct save  <設定檔名稱>
        /ct load  <設定檔名稱>
        /ct delete  <設定檔名稱>
        /ct list
]]

kHelpText_SlashCommands = [[
輸入 /ct help 查看所有可以使用的指令。
]]

kHelpText_Troubleshooting = [[
- 如果縮放設定得太低，部分軌跡會消失。如果選擇軌跡後卻沒有顯示，請嘗試較大的縮放百分比。(所有軌跡皆能在 100% 縮放下運作。)

- 如果游標效果突然消失，可以輸入 /ct reload 來快速回復。

- 如果圖形和陰影無法正常跟隨滑鼠游標，同時您有使用插件將遊戲介面縮放到低於正常最小值 (64%)，請輸入 /ct reload (或正常重新載入介面)，讓游標軌跡使用新的縮放值。

- 如果您也有使用 CTMod 插件，它使用相同的指令 (/ct)，只會開啟其中一個插件。
如果輸入 /ct 時 CTMod 一直開啟，請使用 /cursortrail 開啟鼠之軌跡。
如果輸入 /ct 時鼠之軌跡一直開啟，可以手動將鼠之軌跡的指令變更為其他指令，例如 /ctr。
  重要提醒 - 您需要在每次下載鼠之軌跡後重複做變更。
  1.使用任何文字編輯器，開啟位於 Warcraft 插件資料夾內鼠之軌跡資料夾中的 CursorTrail.lua。
    (例如 C:\Program Files\World of Warcraft\_retail_\Interface\AddOns\CursorTrail\CursorTrail.lua)
  2. 在該檔案中搜尋 SLASH_。
  3. 需要變更這行的最後面。將結尾從
       Globals["SLASH_"..kAddonName.."2"] = "/ct"
    變更為新的指令
      Globals["SLASH_"..kAddonName.."2"] = "/ctr"
  4. 儲存，然後重新載入魔獸 (/reload)。
]]

--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
--[[                       Functions                                         ]]
--:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-------------------------------------------------------------------------------
function CursorTrail_ShowHelp(parent, scrollToTopic)
    local topMargin = 3
    local scrollDelaySecs = nil
    
    if not HelpFrame then
        HelpFrame = private.Controls.CreateTextScrollFrame(parent, "*** "..kAddonName.." Help ***", 750)
        HelpFrame.topicOffsets = {}
        local bigFont = "GameFontNormalHuge" --"OptionsFontLarge" --"GameFontNormalLarge"
        local smallFont = "GameTooltipText"
        local lineSpacing = 6
        scrollDelaySecs = 0.1  -- Required so this newly created window has its scrollbar update correctly.

        -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --

        -- OPTIONS:
        ----HelpFrame.topicOffsets["OPTIONS"] = HelpFrame:GetNextVerticalPosition()
        HelpFrame:AddText(ORANGE.."選項", 0, topMargin, bigFont)
        HelpFrame:AddText(kHelpText_Options, 0, lineSpacing, smallFont)
        ----HelpFrame:AddText(BLUE.."\nTIP:|r You can use the mouse wheel or Up/Down keys to change values.", 0, lineSpacing, smallFont)
        HelpFrame:AddText(" ", 0, lineSpacing, smallFont)
        
        -- PROFILE COMMANDS:
        HelpFrame.topicOffsets["PROFILE_COMMANDS"] = HelpFrame:GetNextVerticalPosition() -12
        HelpFrame:AddText(ORANGE.."設定檔指令", 0, 0, bigFont)
        HelpFrame:AddText(kHelpText_ProfileCommands, 0, lineSpacing, smallFont)
        HelpFrame:AddText(" ", 0, lineSpacing, smallFont)
        
        -- SLASH COMMANDS:
        ----HelpFrame.topicOffsets["SLASH_COMMANDS"] = HelpFrame:GetNextVerticalPosition()
        HelpFrame:AddText(ORANGE.."指令", 0, 0, bigFont)
        HelpFrame:AddText(kHelpText_SlashCommands, 0, lineSpacing, smallFont)
        HelpFrame:AddText(" ", 0, lineSpacing, smallFont)
        
        -- TROUBLESHOOTING:
        ----HelpFrame.topicOffsets["TROUBLESHOOTING"] = HelpFrame:GetNextVerticalPosition()
        HelpFrame:AddText(ORANGE.."問題排除", 0, 0, bigFont)
        HelpFrame:AddText(kHelpText_Troubleshooting, 0, lineSpacing, smallFont)
        HelpFrame:AddText(" ", 0, lineSpacing, smallFont)
        
        -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - --
        -- Add space at bottom so we can scroll any topic to the top.
        HelpFrame:AddText(" ", 0, HelpFrame.scrollFrame:GetHeight() - 56, smallFont)
        
        -- Allow moving the window.
        local w, h = HelpFrame:GetSize()
        local clampW, clampH = w*0.7, h*0.8
        HelpFrame:EnableMouse(true)
        HelpFrame:SetMovable(true)
        HelpFrame:SetClampedToScreen(true)
        HelpFrame:SetClampRectInsets(clampW, -clampW, -clampH, clampH)
        HelpFrame:RegisterForDrag("LeftButton")
        HelpFrame:SetScript("OnDragStart", function() HelpFrame:StartMoving() end)
        HelpFrame:SetScript("OnDragStop", function() HelpFrame:StopMovingOrSizing() end)
    end 
    
    -- Scroll to top, or to specified topic.
    local scrollOffset = 0
    if scrollToTopic then
        scrollOffset = HelpFrame.topicOffsets[ scrollToTopic ]
        if scrollOffset then
        scrollOffset = scrollOffset - topMargin
        else
            print(kAddonErrorHeading.."Invalid help topic!  ("..scrollToTopic..")")
            scrollOffset = 0
        end
    end
    HelpFrame:SetVerticalScroll( scrollOffset, scrollDelaySecs )
    HelpFrame:Show()
end

-------------------------------------------------------------------------------
function CursorTrail_HideHelp()
    if HelpFrame then HelpFrame:Hide() end
end

--- End of File ---