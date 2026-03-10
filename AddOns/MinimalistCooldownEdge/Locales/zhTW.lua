-- zhTW.lua (Traditional Chinese)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "zhTW")
if not L then return end

-- Core
L["Cannot open options in combat."] = "戰鬥中無法開啟選項。"
L["MiniCC test command is unavailable."] = "無法使用 MiniCC 測試指令。"

-- Category Names
L["Action Bars"] = "快捷列"
L["Nameplates"] = "名條"
L["Unit Frames"] = "單位框架"
L["CooldownManager"] = "冷卻技能"
L["MiniCC"] = "MiniCC"
L["Others"] = "其他"

-- Group Headers
L["General"] = "一般"
L["Typography (Cooldown Numbers)"] = "字體 (冷卻數字)"
L["Swipe Animation"] = "轉圈動畫"
L["Stack Counters / Charges"] = "層數 / 充能"
L["Maintenance"] = "維護"
L["Danger Zone"] = "危險區域"
L["Style"] = "樣式"
L["Positioning"] = "位置"
L["CooldownManager Viewers"] = "冷卻技能檢視器"
L["MiniCC Frame Types"] = "MiniCC 框架類型"

-- Toggles & Settings
L["Enable %s"] = "啟用%s"
L["Toggle styling for this category."] = "切換此分類的樣式。"
L["Font Face"] = "字體"
L["Font"] = "字體"
L["Size"] = "大小"
L["Outline"] = "外框"
L["Color"] = "顏色"
L["Hide Numbers"] = "隱藏數字"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "完全隱藏文字 (僅需邊緣轉圈或有層數時有用)。"
L["Anchor Point"] = "位置"
L["Offset X"] = "水平偏移"
L["Offset Y"] = "垂直偏移"
L["Essential Viewer Size"] = "關鍵檢視器大小"
L["Utility Viewer Size"] = "輔助檢視器大小"
L["Buff Icon Viewer Size"] = "增益圖示檢視器大小"
L["CC Text Size"] = "冷卻時間文字大小"
L["Nameplates Text Size"] = "名條文字大小"
L["Portraits Text Size"] = "頭像文字大小"
L["Alerts / Overlay Text Size"] = "替代 / 覆蓋層文字大小"
L["Toggle Test Icons"] = "顯示測試圖示"
L["Show Swipe Edge"] = "顯示邊緣轉圈"
L["Shows the white line indicating cooldown progress."] = "顯示表示冷卻進度的白色線條。"
L["Edge Thickness"] = "邊緣粗細"
L["Scale of the swipe line (1.0 = Default)."] = "轉圈線條的縮放大小 (1.0 = 預設)。"
L["Customize Stack Text"] = "自訂層數文字"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "控制充能計數器(例如：2 層燃燒)。"
L["Reset %s"] = "重置 %s"
L["Revert this category to default settings."] = "將此分類回復為預設設定。"
L["Toggle MiniCC's built-in test icons using /minicc test."] = "使用 /minicc test 指令切換顯示 MiniCC 的內建測試圖示。"

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
L["Factory Reset (All)"] = "恢復原廠設定 (全部)"
L["Resets the entire profile to default values and reloads the UI."] = "將整個設定檔重設為預設值並重新載入介面。"

-- Banner
L["BANNER_DESC"] = "極簡的冷卻設定。選擇左側的分類開始設定。"

-- Chat Messages
L["%s settings reset."] = "%s 設定已重設。"
L["Profile reset. Reloading UI..."] = "設定檔已重設。正在重新載入介面..."

-- Status Indicators
L["ON"] = "開啟"
L["OFF"] = "關閉"

-- General Dashboard
L["Enable categories styling"] = "啟用分類樣式"
L["LIVE_CONTROLS_DESC"] = "變更會立即生效。只保留你實際使用的分類啟用，以保持更乾淨的設定。"

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "複製此連結以在瀏覽器中開啟 CurseForge 專案頁面。"
L["Copy this link to view other projects from Anahkas on CurseForge."] = "複製此連結以查看 Anahkas 在 CurseForge 上的其他專案。"

-- Help
L["Help & Support"] = "幫助與支援"
L["Project"] = "專案"
L["Useful Addons"] = "實用插件"
L["Support & Feedback"] = "支援與回饋"
L["MCE_HELP_INTRO"] = "快速專案連結，以及值得嘗試的幾個插件。"
L["HELP_SUPPORT_DESC"] = "建議與回饋永遠歡迎。\n\n如果你發現錯誤或有功能想法，請隨時在 CurseForge 留言或發送私人訊息。"
L["HELP_COMPANION_DESC"] = "與極簡冷卻時間搭配良好的精選插件。"
L["HELP_MINICC_DESC"] = "精簡的冷卻時間追蹤器。極簡冷卻時間也能美化它的文字。"
L["Copy this link to open the MiniCC CurseForge page in your browser."] = "複製此連結以便在瀏覽器中開啟 MiniCC 的 CurseForge 頁面。"
L["HELP_PVPTAB_DESC"] = "讓 TAB 鍵在 PvP 中只選取玩家。非常適合競技場與戰場。"
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "複製此連結以在瀏覽器中開啟 Smart PvP Tab Targeting 的 CurseForge 頁面。"

-- Quick Toggles Dashboard
L["Quick Toggles"] = "快速切換"
L["QUICK_TOGGLES_DESC"] = "從同一處切換你的主要冷卻分類。"

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "此操作無法復原。您的設定檔將被完全重置，並且介面會重新載入。"
L["MAINTENANCE_DESC"] = "將此分類恢復為出廠預設值。其他分類不受影響。"

-- Category Descriptions
L["ACTIONBAR_DESC"] = "自訂快捷列上的冷卻，包括 Bartender4、Dominos 和 ElvUI。"
L["NAMEPLATE_DESC"] = "設定敵方和友方名條上顯示的冷卻樣式（Plater、KuiNameplates 等）。"
L["UNITFRAME_DESC"] = "調整玩家、目標和專注目標單位框架上的冷卻樣式。"
L["COOLDOWNMANAGER_DESC"] = "為冷卻技能檢視器提供共用的圖示樣式。倒數文字大小可針對關鍵、輔助與增益圖示檢視器分別設定。"
L["MINICC_DESC"] = "專為極簡冷卻時間冷卻圖示設計的樣式。當極簡冷卻時間載入時，支援極簡冷卻時間的控場圖示、名條、頭像，以及覆蓋式模組。"
L["OTHERS_DESC"] = "用於不屬於其他分類的冷卻時間（背包、選單、其他插件）。"

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "動態文字顏色"
L["Color by Remaining Time"] = "依剩餘時間變色"
L["Dynamically colors the countdown text based on how much time is left."] = "依剩餘時間動態變更倒數文字顏色。"
L["DYNAMIC_COLORS_DESC"] = "根據冷卻剩餘時間改變文字顏色。啟用後會覆蓋上方的靜態顏色設定。"
L["Expiring Soon"] = "即將到期"
L["Short Duration"] = "短時間"
L["Long Duration"] = "長時間"
L["Beyond Thresholds"] = "超過閾值"
L["Threshold (seconds)"] = "閾值（秒）"
L["Default Color"] = "預設顏色"
L["Color used when the remaining time exceeds all thresholds."] = "當剩餘時間超過所有閾值時所使用的顏色。"

-- 自行加入
L["MiniCE"] = "極簡冷卻時間"
L["MinimalistCooldownEdge"] = "冷卻時間"
