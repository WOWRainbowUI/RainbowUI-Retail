-- zhTW.lua (Traditional Chinese)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "zhTW")
if not L then return end

-- Core
L["Cannot open options in combat."] = "戰鬥中無法開啟選項。"

-- Category Names
L["Action Bars"] = "動作列"
L["Nameplates"] = "名條"
L["Unit Frames"] = "單位框架"
L["CD Manager & Others"] = "冷卻管理器及其他"

-- Group Headers
L["General"] = "一般"
L["State"] = "狀態"
L["Typography (Cooldown Numbers)"] = "字體排版（冷卻數字）"
L["Swipe Animation"] = "掃動動畫"
L["Stack Counters / Charges"] = "堆疊計數 / 充能"
L["Maintenance"] = "維護"
L["Performance & Detection"] = "效能與偵測"
L["Danger Zone"] = "危險區域"
L["Style"] = "樣式"
L["Positioning"] = "定位"

-- Toggles & Settings
L["Enable %s"] = "啟用 %s"
L["Toggle styling for this category."] = "切換此分類的樣式。"
L["Font Face"] = "字體"
L["Font"] = "字體"
L["Size"] = "大小"
L["Outline"] = "描邊"
L["Color"] = "顏色"
L["Hide Numbers"] = "隱藏數字"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "完全隱藏文字（僅需掃動邊緣或堆疊時有用）。"
L["Anchor Point"] = "錨點"
L["Offset X"] = "X 偏移"
L["Offset Y"] = "Y 偏移"
L["Show Swipe Edge"] = "顯示掃動邊緣"
L["Shows the white line indicating cooldown progress."] = "顯示表示冷卻進度的白色線條。"
L["Edge Thickness"] = "邊緣厚度"
L["Scale of the swipe line (1.0 = Default)."] = "掃動線條的縮放（1.0 = 預設）。"
L["Customize Stack Text"] = "自訂堆疊文字"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "控制充能計數器（例如：2 層燃燒）。"
L["Reset %s"] = "重設 %s"
L["Revert this category to default settings."] = "將此分類回復為預設設定。"

-- Outline Values
L["None"] = "無"
L["Thick"] = "粗"
L["Mono"] = "單色"

-- Anchor Point Values
L["Bottom Right"] = "右下"
L["Bottom Left"] = "左下"
L["Top Right"] = "右上"
L["Top Left"] = "左上"
L["Center"] = "置中"

-- General Tab
L["Scan Depth"] = "掃描深度"
L["How deep the addon looks into UI frames to find cooldowns."] = "插件在介面框架中搜尋冷卻的深度。"
L["Factory Reset (All)"] = "恢復原廠設定（全部）"
L["Resets the entire profile to default values and reloads the UI."] = "將整個設定檔重設為預設值並重新載入介面。"

-- Banner
L["BANNER_DESC"] = "極簡的冷卻設定。選擇左側的分類開始設定。"

-- Scan Depth Help
L["SCAN_DEPTH_HELP"] = "\n|cff00ff00< 10|r：高效（預設介面）\n|cfffff56910 - 15|r：適中（Bartender、Dominos）\n|cffffa500> 15|r：較重（ElvUI、複雜框架）"

-- Chat Messages
L["%s settings reset."] = "%s 設定已重設。"
L["Profile reset. Reloading UI..."] = "設定檔已重設。正在重新載入介面..."
L["Global Scan Depth changed. A /reload is recommended."] = "全域掃描深度已更改。建議執行 /reload。"
