-- zhTW.lua (Traditional Chinese)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "zhTW")
if not L then return end

-- Core
L["Cannot open options in combat."] = "戰鬥中無法開啟選項。"

-- Category Names
L["Action Bars"] = "快捷列"
L["Nameplates"] = "名條"
L["Unit Frames"] = "單位框架"
L["CooldownManager"] = "冷卻技能"
L["Others"] = "其他"

-- Group Headers
L["General"] = "一般"
L["State"] = "狀態"
L["Typography (Cooldown Numbers)"] = "字體 (冷卻數字)"
L["Swipe Animation"] = "轉圈動畫"
L["Stack Counters / Charges"] = "層數 / 充能"
L["Maintenance"] = "維護"
L["Performance & Detection"] = "效能 & 偵測"
L["Danger Zone"] = "危險區域"
L["Style"] = "樣式"
L["Positioning"] = "位置"
L["CooldownManager Viewers"] = "冷卻技能檢視器"

-- Toggles & Settings
L["Enable %s"] = "啟用%s"
L["Toggle styling for this category."] = "切換此分類的樣式。"
L["Font Face"] = "字體"
L["Game Default"] = "預設"
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
L["Show Swipe Edge"] = "顯示邊緣轉圈"
L["Shows the white line indicating cooldown progress."] = "顯示表示冷卻進度的白色線條。"
L["Edge Thickness"] = "邊緣粗細"
L["Scale of the swipe line (1.0 = Default)."] = "轉圈線條的縮放大小 (1.0 = 預設)。"
L["Customize Stack Text"] = "自訂層數文字"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "控制充能計數器(例如：2 層燃燒)。"
L["Reset %s"] = "重置 %s"
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
L["Factory Reset (All)"] = "恢復原廠設定 (全部)"
L["Resets the entire profile to default values and reloads the UI."] = "將整個設定檔重設為預設值並重新載入介面。"

-- Banner
L["BANNER_DESC"] = "極簡的冷卻設定。選擇左側的分類開始設定。"

-- Scan Depth Help
L["SCAN_DEPTH_HELP"] = "\n|cff00ff00< 10|r：高效（預設介面）\n|cfffff56910 - 15|r：適中（Bartender、Dominos）\n|cffffa500> 15|r：較重（ElvUI、複雜框架）"

-- Chat Messages
L["%s settings reset."] = "%s 設定已重設。"
L["Profile reset. Reloading UI..."] = "設定檔已重設。正在重新載入介面..."
L["Global Scan Depth changed. A /reload is recommended."] = "全域掃描深度已更改。建議執行 /reload。"

-- Status Indicators
L["ON"] = "開啟"
L["OFF"] = "關閉"
L["Category Status"] = "分類狀態"

-- Tools
L["Tools"] = "工具"
L["Force Refresh"] = "強制重新整理"
L["Force a full rescan of all cooldown frames."] = "強制對所有冷卻框架執行完整掃描。"
L["Full refresh completed."] = "完整重新整理完成。"

-- Links
L["Links"] = "連結"
L["LINKS_DESC"] = "提供更新、變更紀錄和下載的專案連結。"
L["CurseForge URL"] = "CurseForge 網址"
L["Copy this link to open the CurseForge project page in your browser."] = "複製此連結以在瀏覽器中開啟 CurseForge 專案頁面。"
L["Developer Page"] = "開發者頁面"
L["Copy this link to view other projects from Anahkas on CurseForge."] = "複製此連結以查看 Anahkas 在 CurseForge 上的其他專案。"

-- Help
L["Help"] = "說明"
L["Project Information"] = "專案資訊"
L["Development Status"] = "開發狀態"
L["HELP_ABOUT_DESC"] = "MinimalistCooldownEdge 是一款輕量化的冷卻時間樣式插件，專注於清晰度、效能與簡潔介面。"
L["HELP_DEVELOPMENT_DESC"] = "此插件仍在持續開發與改進中。"
L["HELP_FEEDBACK_DESC"] = "非常歡迎建議、回饋與評論，這些能幫助塑造未來的改進方向。"

-- Quick Toggles Dashboard
L["Quick Toggles"] = "快速切換"
L["QUICK_TOGGLES_DESC"] = "可快速啟用或停用分類，變更會立即生效。"

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "此操作無法復原。您的設定檔將被完全重置，並且介面會重新載入。"
L["MAINTENANCE_DESC"] = "將此分類恢復為出廠預設值。其他分類不受影響。"

-- Category Descriptions
L["ACTIONBAR_DESC"] = "自訂快捷列上的冷卻，包括 Bartender4、Dominos 和 ElvUI。"
L["NAMEPLATE_DESC"] = "設定敵方和友方名條上顯示的冷卻樣式（Plater、KuiNameplates 等）。"
L["UNITFRAME_DESC"] = "調整玩家、目標和專注目標單位框架上的冷卻樣式。"
L["COOLDOWNMANAGER_DESC"] = "為冷卻技能檢視器提供共用的圖示樣式。倒數文字大小可針對關鍵、輔助與增益圖示檢視器分別設定。"
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
