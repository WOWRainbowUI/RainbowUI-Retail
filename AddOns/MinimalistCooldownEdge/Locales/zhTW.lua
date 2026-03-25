-- zhTW.lua (Traditional Chinese)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "zhTW")
if not L then return end

-- Core
L["Cannot open options in combat."] = "戰鬥中無法開啟選項。"
L["MiniCC test command is unavailable."] = "MiniCC 測試指令不可用。"

-- Category Names
L["Action Bars"] = "動作列"
L["Nameplates"] = "名條"
L["Unit Frames"] = "單位框架"
L["CooldownManager"] = "CooldownManager"
L["MiniCC"] = "MiniCC"
L["Others"] = "其他"

-- Group Headers
L["General"] = "一般"
L["Typography (Cooldown Numbers)"] = "字體排版（冷卻數字）"
L["Swipe Animation"] = "掃動動畫"
L["Stack Counters / Charges"] = "層數計數 / 充能"
L["Maintenance"] = "維護"
L["Danger Zone"] = "危險區域"
L["Style"] = "樣式"
L["Positioning"] = "定位"
L["CooldownManager Viewers"] = "CooldownManager 檢視器"
L["MiniCC Frame Types"] = "MiniCC 框架類型"

-- Toggles & Settings
L["Enable %s"] = "啟用 %s"
L["Toggle styling for this category."] = "切換此分類的樣式。"
L["Font Face"] = "字體"
L["Font"] = "字體"
L["Size"] = "大小"
L["Outline"] = "描邊"
L["Color"] = "顏色"
L["Hide Numbers"] = "隱藏數字"
L["Compact Party / Raid Aura Text"] = "精簡小隊/團隊光環文字"
L["Enable Party Aura Text"] = "啟用小隊光環文字"
L["Enable Raid Aura Text"] = "啟用團隊光環文字"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "完全隱藏文字（如果你只想保留掃動邊緣或層數，這會很有用）。"
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = "在 Blizzard CompactPartyFrame 的增益與減益圖示上顯示帶樣式的倒數文字。停用後會隱藏小隊框架上的光環倒數文字。"
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = "在 Blizzard CompactRaidFrame 的增益與減益圖示上顯示帶樣式的倒數文字。停用後會隱藏團隊框架上的光環倒數文字。"
L["Anchor Point"] = "錨點"
L["Offset X"] = "X 偏移"
L["Offset Y"] = "Y 偏移"
L["Essential Viewer Size"] = "Essential 檢視器大小"
L["Utility Viewer Size"] = "Utility 檢視器大小"
L["Buff Icon Viewer Size"] = "增益圖示檢視器大小"
L["CC Text Size"] = "CC 文字大小"
L["Nameplates Text Size"] = "名條文字大小"
L["Portraits Text Size"] = "頭像文字大小"
L["Alerts / Overlay Text Size"] = "警示 / 覆蓋文字大小"
L["Toggle Test Icons"] = "切換測試圖示"
L["Show Swipe Edge"] = "顯示掃動邊緣"
L["Shows the white line indicating cooldown progress."] = "顯示表示冷卻進度的白色線條。"
L["Edge Thickness"] = "邊緣厚度"
L["Scale of the swipe line (1.0 = Default)."] = "掃動線條的縮放（1.0 = 預設）。"
L["Customize Stack Text"] = "自訂層數文字"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "接管充能計數器（例如：2 層燃燒）。"
L["Reset %s"] = "重設 %s"
L["Revert this category to default settings."] = "將此分類恢復為預設設定。"
L["Toggle MiniCC's built-in test icons using /minicc test."] = "使用 /minicc test 切換 MiniCC 內建測試圖示。"

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
L["Factory Reset (All)"] = "恢復原廠設定（全部）"
L["Resets the entire profile to default values and reloads the UI."] = "將整個設定檔重設為預設值並重新載入介面。"
L["Import / Export"] = "匯入 / 匯出"
L["PROFILE_IMPORT_EXPORT_DESC"] = "將目前的 AceDB 設定檔匯出為可分享的字串，或匯入字串以取代目前設定檔的設定。"
L["Export current profile"] = "匯出目前設定檔"
L["Generate export"] = "產生匯出"
L["Export code"] = "匯出代碼"
L["Generate an export string, then click inside this box and copy it with Ctrl+C."] = "產生匯出字串後，點擊此框並使用 Ctrl+C 複製。"
L["Import profile"] = "匯入設定檔"
L["Import code"] = "匯入代碼"
L["Paste an exported string here, then click Import."] = "在此貼上匯出的字串，然後點擊匯入。"
L["Import"] = "匯入"
L["Importing will overwrite the current profile settings. Continue?"] = "匯入將覆寫目前設定檔的設定。要繼續嗎？"
L["Export string generated. Copy it with Ctrl+C."] = "匯出字串已產生。請使用 Ctrl+C 複製。"
L["Profile import completed."] = "設定檔匯入完成。"
L["No active profile available."] = "目前沒有可用的作用中設定檔。"
L["Failed to encode export string."] = "匯出字串編碼失敗。"
L["Paste an import string first."] = "請先貼上匯入字串。"
L["Invalid import string format."] = "匯入字串格式無效。"
L["Failed to decode import string."] = "匯入字串解碼失敗。"
L["Failed to decompress import string."] = "匯入字串解壓失敗。"
L["Failed to deserialize import string."] = "匯入字串反序列化失敗。"

-- Banner
L["BANNER_DESC"] = "為你的冷卻提供精簡設定。選擇左側的分類即可開始。"

-- Chat Messages
L["%s settings reset."] = "%s 設定已重設。"
L["Profile reset. Reloading UI..."] = "設定檔已重設。正在重新載入介面..."

-- Status Indicators
L["ON"] = "開"
L["OFF"] = "關"

-- General Dashboard
L["Enable categories styling"] = "啟用分類樣式"
L["LIVE_CONTROLS_DESC"] = "變更會立即生效。只啟用你真正會用到的分類，讓介面更精簡。"
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "在 Blizzard CompactPartyFrame 和 CompactRaidFrame 的增益與減益圖示上顯示帶樣式的倒數文字。小隊和團隊可分別切換。此功能獨立於「其他」分類。"

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "複製此連結即可在瀏覽器中開啟 CurseForge 專案頁面。"
L["Copy this link to view other projects from Anahkas on CurseForge."] = "複製此連結即可查看 Anahkas 在 CurseForge 上的其他專案。"

-- Help
L["Help & Support"] = "幫助與支援"
L["Project"] = "專案"
L["Useful Addons"] = "實用插件"
L["Support & Feedback"] = "支援與回饋"
L["MCE_HELP_INTRO"] = "這裡有專案的快速連結，以及幾個值得一試的插件。"
L["HELP_SUPPORT_DESC"] = "歡迎隨時提供建議與回饋。\n\n如果你發現 bug 或有功能點子，歡迎在 CurseForge 留言或私訊。"
L["HELP_COMPANION_DESC"] = "幾款與 MiniCE 搭配很合適的精簡插件。"
L["HELP_MINICC_DESC"] = "精簡的控場追蹤器。MiniCE 也能美化它的文字。"
L["Copy this link to open the MiniCC CurseForge page in your browser."] = "複製此連結即可在瀏覽器中開啟 MiniCC 的 CurseForge 頁面。"
L["HELP_PVPTAB_DESC"] = "讓 TAB 在 PvP 中只選中玩家。非常適合競技場和戰場。"
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "複製此連結即可開啟 Smart PvP Tab Targeting 的 CurseForge 頁面。"

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "在一個地方切換你的主要冷卻分類。"

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "此操作無法撤銷。你的設定檔將被完全重設，並重新載入介面。"
L["MAINTENANCE_DESC"] = "將此分類恢復為出廠預設設定。其他分類不受影響。"

-- Category Descriptions
L["ACTIONBAR_DESC"] = "自訂主動作列上的冷卻，包括 Bartender4 和 Dominos。"
L["NAMEPLATE_DESC"] = "設定敵對與友方名條上顯示的冷卻樣式（Plater、KuiNameplates 等）。"
L["UNITFRAME_DESC"] = "調整玩家、目標與焦點單位框架上的冷卻樣式。"
L["COOLDOWNMANAGER_DESC"] = "為 CooldownManager 檢視器提供統一的圖示樣式。倒數文字大小可分別為 Essential、Utility 和增益圖示檢視器單獨設定。"
L["MINICC_DESC"] = "MiniCC 冷卻圖示的專用樣式。載入 MiniCC 時，可支援其控場圖示、名條、頭像與覆蓋式模組。"
L["OTHERS_DESC"] = "用於不屬於其他分類的冷卻的整合分類（背包、選單、雜項插件）。"

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "動態文字顏色"
L["Color by Remaining Time"] = "依剩餘時間上色"
L["Dynamically colors the countdown text based on how much time is left."] = "依剩餘時間動態改變倒數文字顏色。"
L["DYNAMIC_COLORS_DESC"] = "依剩餘冷卻時間改變文字顏色。啟用後會覆蓋上方的靜態顏色。"
L["DYNAMIC_COLORS_GENERAL_DESC"] = "將相同的剩餘時間門檻套用到所有已啟用的 MiniCE 分類，包括精簡小隊/團隊光環文字。即使 Blizzard 提供的是隱藏數值，跨越午夜時也能安全處理持續時間。"
L["Expiring Soon"] = "即將結束"
L["Short Duration"] = "短持續時間"
L["Long Duration"] = "長持續時間"
L["Beyond Thresholds"] = "超過門檻"
L["Threshold (seconds)"] = "門檻（秒）"
L["Default Color"] = "預設顏色"
L["Color used when the remaining time exceeds all thresholds."] = "當剩餘時間超過所有門檻時所使用的顏色。"

-- Abbreviation
L["Abbreviate Above"] = "縮寫門檻"
L["Abbreviate Above (seconds)"] = "縮寫門檻（秒）"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "超過此門檻的冷卻數字將被縮寫（例如顯示5m而不是300）。"
L["ABBREV_THRESHOLD_DESC"] = "控制冷卻數字何時切換為縮寫格式。超過此門檻的計時器將顯示縮寫值，如5m或1h。"
