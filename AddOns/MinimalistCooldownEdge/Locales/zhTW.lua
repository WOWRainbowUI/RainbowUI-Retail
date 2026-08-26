-- zhTW.lua (Traditional Chinese)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "zhTW")
if not L then return end

L["MINIAURAS_COUNTDOWN_COLORS_NOTICE"] = "MiniAuras 會自行管理倒數門檻顏色。請在 MiniAuras > Misc > Countdown Colours 中設定。"
L["MINIAURAS_SWIPE_ALPHA_DESC"] = "0% = 完全透明，100% = 完全變暗。套用於所有 MiniAuras 模組群組；80% 與 MiniAuras 自身繪製的冷卻遮罩一致。"

-- Core
L["MiniAuras test command is unavailable."] = "MiniAuras 測試指令不可用。"

-- Category Names
L["Action Bars"] = "動作列"
L["Nameplates"] = "名條"
L["Unit Frames"] = "單位框架"
L["Party / Raid Frames"] = "小隊/團隊框架"
L["CooldownManager"] = "CooldownManager"
L["MiniAuras"] = "MiniAuras"

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
L["MiniAuras Frame Types"] = "MiniAuras 框架類型"

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
L["Essential Viewer Stack Size"] = "Essential 檢視器層數大小"
L["Utility Viewer Stack Size"] = "Utility 檢視器層數大小"
L["Buff Icon Viewer Stack Size"] = "增益圖示檢視器層數大小"
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
L["Toggle MiniAuras' built-in test icons using /miniauras test."] = "使用 /miniauras test 切換 MiniAuras 內建測試圖示。"

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
L["Top"] = "上"
L["Bottom"] = "下"
L["Left"] = "左"
L["Right"] = "右"

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
L["Retired"] = "已移除"

-- General Dashboard
L["Enable categories styling"] = "啟用分類樣式"
L["LIVE_CONTROLS_DESC"] = "變更會立即生效。只啟用你真正會用到的分類，讓介面更精簡。"
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "啟用小隊/團隊框架是此分類的總開關。啟用團隊光環文字會將相同樣式套用到 Blizzard 團隊框架。"
L["PARTY_RAID_FRAMES_RETIRED_DESC"] = "小隊/團隊框架支援已移除。自 Blizzard 12.0.5 更新起，MiniCE 不再 hook 或美化精簡小隊與團隊框架。"
L["PARTY_RAID_FRAMES_AURAS_TITLE"] = "開發中的新插件：Raid Frame Auras"
L["PARTY_RAID_FRAMES_AURAS_DESC"] = "Raid Frame Auras 現已上架 CurseForge。它之所以與 MiniCE 分開，是因為它使用自己的覆蓋框架，而不是去美化 Blizzard 現有的圖示，因此更適合作為獨立插件。"

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "複製此連結即可在瀏覽器中開啟 CurseForge 專案頁面。"
L["Copy this link to open Raid Frame Auras on CurseForge."] = "複製此連結即可在 CurseForge 上開啟 Raid Frame Auras。"
L["Copy this link to view other projects from Anahkas on CurseForge."] = "複製此連結即可查看 Anahkas 在 CurseForge 上的其他專案。"

-- Help
L["Help & Support"] = "幫助與支援"
L["Project"] = "專案"
L["Useful Addons"] = "實用插件"
L["Support & Feedback"] = "支援與回饋"
L["MCE_HELP_INTRO"] = "這裡有專案的快速連結，以及幾個值得一試的插件。"
L["HELP_SUPPORT_DESC"] = "歡迎隨時提供建議與回饋。\n\n如果你發現 bug 或有功能點子，歡迎在 CurseForge 留言或私訊。"
L["HELP_COMPANION_DESC"] = "幾款與 MiniCE 搭配很合適的精簡插件。"
L["HELP_MINIAURAS_DESC"] = "自訂光環、控場、冷卻與 PvP 顯示套件。MiniCE 也能美化其冷卻文字。"
L["Copy this link to open the MiniAuras CurseForge page in your browser."] = "複製此連結即可在瀏覽器中開啟 MiniAuras 的 CurseForge 頁面。"
L["HELP_PVPTAB_DESC"] = "讓 TAB 在 PvP 中只選中玩家。非常適合競技場和戰場。"
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "複製此連結即可開啟 Smart PvP Tab Targeting 的 CurseForge 頁面。"

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "在一個地方切換你的主要冷卻分類。"

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "此操作無法撤銷。你的設定檔將被完全重設，並重新載入介面。"
L["MAINTENANCE_DESC"] = "將此分類恢復為出廠預設設定。其他分類不受影響。"

-- Category Descriptions
L["ACTIONBAR_DESC"] = "美化動作列上的冷卻。"
L["NAMEPLATE_DESC"] = "美化敵對與友方名條上的冷卻。"
L["UNITFRAME_DESC"] = "美化目標、焦點及其他支援單位框架上的光環冷卻。"
L["COOLDOWNMANAGER_DESC"] = "美化 CooldownManager 圖示冷卻。"
L["MINIAURAS_DESC"] = "美化 MiniAuras 冷卻圖示。"

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "動態文字顏色"
L["Color by Remaining Time"] = "依剩餘時間上色"
L["Dynamically colors the countdown text based on how much time is left."] = "依剩餘時間動態改變倒數文字顏色。"
L["DYNAMIC_COLORS_DESC"] = "依剩餘冷卻時間改變文字顏色。啟用後會覆蓋上方的靜態顏色。"
L["DYNAMIC_COLORS_GENERAL_DESC"] = "可依每個啟用中的 MiniCE 分類允許或封鎖剩餘時間門檻。即使 Blizzard 提供的是隱藏數值，跨越午夜時也能安全處理持續時間。"
L["Expiring Soon"] = "即將結束"
L["Short Duration"] = "短持續時間"
L["Long Duration"] = "長持續時間"
L["Threshold (seconds)"] = "門檻（秒）"
L["Default Color"] = "預設顏色"
L["Color used when the remaining time exceeds all thresholds."] = "當剩餘時間超過所有門檻時所使用的顏色。"

-- Abbreviation
L["Abbreviate Above"] = "縮寫門檻"
L["Abbreviate Above (seconds)"] = "縮寫門檻（秒）"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "超過此門檻的冷卻數字將被縮寫（例如顯示5m而不是300）。"
L["ABBREV_THRESHOLD_DESC"] = "控制冷卻數字何時切換為縮寫格式。超過此門檻的計時器將顯示縮寫值，如5m或1h。"

-- MyDRs / sArena
L["MYDRS_SWIPE_ALPHA_DESC"] = "0% = 完全透明，100% = 完全變暗。此分類啟用期間會取代 MyDRs 的 Cooldown Swipe Alpha 設定；100% 與 MyDRs 自身繪製的冷卻遮罩一致。"
L["MyDRs test command is unavailable."] = "MyDRs 測試指令不可用。"
L["Toggle MyDRs' built-in test icons using /mydrs test."] = "使用 /mydrs test 切換 MyDRs 內建測試圖示。"
L["sArena slash command is unavailable."] = "sArena 斜線指令不可用。"

-- Category Names
L["Player Auras"] = "玩家光環"
L["CooldownManagerCentered"] = "CooldownManagerCentered"
L["HealerCC"] = "HealerCC"
L["MyDRs"] = "MyDRs"
L["sArena"] = "sArena"
L["TellMeWhen"] = "TellMeWhen"
L["Profiles"] = "設定檔"
L["ShinyAuras"] = "ShinyAuras"
L["Dominos"] = "Dominos"
L["ElvUI"] = "ElvUI"

-- Group Headers
L["Swipe Edge"] = "掃動邊緣"
L["MiniAuras Module Groups"] = "MiniAuras 模組群組"
L["sArena Cooldown Types"] = "sArena 冷卻類型"
L["Aura Targets"] = "光環目標"
L["Buff Styling"] = "增益樣式"
L["Debuff Styling"] = "減益樣式"
L["External Defensive Buffs Styling"] = "外部防禦增益樣式"

-- Toggles & Settings
L["Style Buffs"] = "美化增益"
L["Style Debuffs"] = "美化減益"
L["Style External Defensive Buffs"] = "美化外部防禦增益"
L["Style Blizzard's default player buff buttons."] = "美化 Blizzard 預設的玩家增益圖示。"
L["Style Blizzard's default player debuff buttons."] = "美化 Blizzard 預設的玩家減益圖示。"
L["Style Blizzard's external defensive buff buttons."] = "美化 Blizzard 的外部防禦增益圖示。"
L["Timer Inside Icon"] = "圖示內計時"
L["Place the aura timer in the center of the icon instead of Blizzard's default outside position."] = "將光環計時器置於圖示中央，而非 Blizzard 預設的外部位置。"
L["Hide Swipe"] = "隱藏掃動"
L["Only Mine (Timer Text)"] = "僅顯示我的（計時文字）"
L["Aura Visibility"] = "光環顯示設定"
L["Only My Debuffs"] = "僅顯示我的減益"
L["Only My Buffs"] = "僅顯示我的增益"
L["Disable fading/blinking"] = "停用淡出/閃爍"
L["Enables styled countdown text on Party / Raid Frames. When disabled, both party and raid aura text styling are turned off."] = "在小隊/團隊框架上啟用帶樣式的倒數文字。停用後，小隊和團隊光環文字樣式都會關閉。"
L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."] = "同時將帶樣式的倒數文字套用到 Blizzard CompactRaidFrame 的增益與減益圖示。需要啟用小隊/團隊框架。"
L["Hide the swipe animation for this frame group (countdown text still shows)."] = "隱藏此框架群組的掃動動畫（倒數文字仍會顯示）。"
L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."] = "僅在你自己的光環上顯示冷卻計時文字。使用 Blizzard 的大型光環判斷法，而非直接檢查 sourceUnit。"
L["UNITFRAME_ONLY_MINE_DESC"] = "僅在你自己施放的光環上顯示計時文字。MiniCE 在 WoW 12.1 中的目標/焦點容器使用 Blizzard 的玩家篩選器；相容插件與舊版框架則使用其群組中繼資料或大型光環備援機制。"
L["UNITFRAME_ONLY_MINE_DEBUFFS_DESC"] = "隱藏其他玩家在目標與焦點框架上施放的減益。MiniCE 在 WoW 12.1 中管理這些光環容器，因此 Blizzard 自身的減益篩選器不再對其生效。"
L["UNITFRAME_ONLY_MINE_BUFFS_DESC"] = "隱藏其他玩家在目標與焦點框架上施放的增益。MiniCE 在 WoW 12.1 中管理這些光環容器，因此 Blizzard 自身的增益篩選器不再對其生效。"
L["Cast Bar"] = "施法條"
L["Reposition Cast Bar"] = "重新定位施法條"
L["UNITFRAME_CASTBAR_REPOSITION_DESC"] = "將目標與焦點的施法條錨定在最後一行增益/減益之下。MiniCE 在 WoW 12.1 中管理這些光環容器，否則暴雪的施法條會緊貼框架並與光環重疊。"
L["Keeps player aura buttons fully opaque when they are close to expiring."] = "當玩家光環圖示即將到期時，保持其完全不透明。"
L["When a CooldownManager slot is temporarily showing aura time, use a dedicated buff color instead of remaining-time threshold colors."] = "當 CooldownManager 插槽暫時顯示光環時間時，使用專用增益顏色，而非剩餘時間門檻顏色。"
L["Applied while the slot is showing aura duration. When the aura ends and the slot switches back to cooldown time, threshold colors resume."] = "在插槽顯示光環持續時間期間套用。光環結束、插槽切回冷卻時間後，將恢復門檻顏色。"
L["Buff / Debuff Size"] = "增益/減益大小"
L["Defensive Buff Size"] = "防禦增益大小"
L["Use Buff Color"] = "使用增益顏色"
L["Buff Color"] = "增益顏色"
L["Essential Viewer"] = "Essential 檢視器"
L["Utility Viewer"] = "Utility 檢視器"
L["Buff Icon Viewer"] = "增益圖示檢視器"
L["CC Frames Text Size"] = "CC 框架文字大小"
L["CC / Friendly Frames Text Size"] = "CC / 友方框架文字大小"
L["Raid Frame Auras Text Size"] = "團隊框架光環文字大小"
L["Class Icon Text Size"] = "職業圖示文字大小"
L["DR Cooldown Text Size"] = "DR 冷卻文字大小"
L["Alerts / Trackers / Custom Auras Text Size"] = "警示/追蹤器/自訂光環文字大小"
L["Trinket / Racial Text Size"] = "飾品/種族文字大小"
L["Show Test Frames"] = "顯示測試框架"
L["Hide Test Frames"] = "隱藏測試框架"
L["Show Swipe Animation"] = "顯示掃動動畫"
L["Shows the dark overlay that sweeps during a cooldown."] = "顯示冷卻期間掃過的深色遮罩。"
L["Swipe Shade Alpha"] = "掃動遮罩不透明度"
L["0% = transparent, 100% = full dark."] = "0% = 完全透明，100% = 完全變暗。"
L["Reverse Swipe"] = "反轉掃動"
L["Reverse the swipe direction so the shade fills in the opposite direction."] = "反轉掃動方向，使遮罩往相反方向填滿。"
L["Hide Charge Timers"] = "隱藏充能計時器"
L["Hide timers while charges are restoring (only show timer when all charges are spent)."] = "充能恢復期間隱藏計時器（僅在所有充能用盡時顯示計時器）。"
L["Hide Stack Text"] = "隱藏層數文字"
L["Hide stacks and charges entirely."] = "完全隱藏層數與充能。"
L["MiniAuras text settings are grouped by module family so similar widgets share the same countdown size."] = "MiniAuras 文字設定依模組系列分組，相似的元件共用相同的倒數大小。"
L["Applies to MiniAuras CC module (enemy crowd controls)."] = "適用於 MiniAuras CC 模組（敵方控場效果）。"
L["Applies to MiniAuras CC, Friendly CDs, and Friendly Indicators modules."] = "適用於 MiniAuras 的 CC、Friendly CDs 與 Friendly Indicators 模組。"
L["Applies to the MiniAuras Raid Frame Auras module."] = "適用於 MiniAuras 的 Raid Frame Auras 模組。"
L["Applies to MiniAuras portrait icons."] = "適用於 MiniAuras 頭像圖示。"
L["Applies to MiniAuras Alerts, Healer CC, Kick Timer, Precognition, Trinkets, and Custom Auras modules."] = "適用於 MiniAuras 的 Alerts、Healer CC、Kick Timer、Precognition、Trinkets 與 Custom Auras 模組。"
L["Show sArena test frames using /sarena test."] = "使用 /sarena test 顯示 sArena 測試框架。"
L["Hide sArena test frames using /sarena hide."] = "使用 /sarena hide 隱藏 sArena 測試框架。"

-- Import / Export
L["Import string is too large."] = "匯入字串過大。"
L["Import profile contains invalid data."] = "匯入的設定檔包含無效資料。"
L["Failed to apply imported profile."] = "無法套用匯入的設定檔。"

-- Chat Messages
L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"] = "部分變更需要重新載入介面才能完全生效。\n\n是否立即重新載入介面？"

-- Addon Integrations
L["Addon Integrations"] = "插件整合"
L["ADDON_INTEGRATIONS_DESC"] = "啟用或停用將外部冷卻路由至 MiniCE 分類的選用插件橋接。"
L["Routes ShinyAuras cooldowns through the Unit Frames category. Disable this if you want ShinyAuras to keep its native countdowns untouched."] = "透過單位框架分類路由 ShinyAuras 的冷卻。若希望 ShinyAuras 保留其原生倒數不變，請停用此項。"
L["Routes supported Dominos action bar cooldowns through the Action Bars category. Disable this if you want Dominos to keep its native cooldown styling untouched."] = "透過動作列分類路由受支援的 Dominos 動作列冷卻。若希望 Dominos 保留其原生冷卻樣式不變，請停用此項。"
L["Routes supported Bartender4 action bar cooldowns through the Action Bars category. Disable this if you want Bartender4 to keep its native cooldown styling untouched."] = "透過動作列分類路由受支援的 Bartender4 動作列冷卻。若希望 Bartender4 保留其原生冷卻樣式不變，請停用此項。"
L["Routes supported ElvUI action bar, unit frame, and nameplate cooldowns through MiniCE categories. Disable this if you want ElvUI to keep its native cooldown styling untouched."] = "透過 MiniCE 分類路由受支援的 ElvUI 動作列、單位框架與名條冷卻。若希望 ElvUI 保留其原生冷卻樣式不變，請停用此項。"
L["CooldownManagerCentered also styles %s. This may add a small performance cost. Disable CMC timer fonts if you want MiniCE to remain the only owner of those viewer timers."] = "CooldownManagerCentered 也會美化 %s，這可能帶來些微效能負擔。若希望 MiniCE 是這些檢視器計時器的唯一管理者，請停用 CMC 計時字型。"

-- Help
L["HELP_ARENADR_DESC"] = "直接在競技場名條上追蹤敵方遞減效果。"
L["Copy this link to open ArenaDR Nameplates on CurseForge."] = "複製此連結即可在 CurseForge 上開啟 ArenaDR Nameplates。"

-- Category Descriptions
L["BETTERBLIZZFRAMES_UNITFRAME_CONFLICT_WARNING"] = "BetterBlizzFrames 已啟用，因此 MiniCE 的單位框架美化已停用，以避免可能的衝突。專用的 BetterBlizzFrames 轉接器即將推出。"
L["BETTERBLIZZPLATES_NAMEPLATE_CONFLICT_WARNING"] = "BetterBlizzPlates 已啟用，因此 MiniCE 的名條美化已停用，以避免可能的衝突。"
L["PLAYERAURA_DESC"] = "美化 Blizzard 玩家增益與減益冷卻。"
L["HEALERCC_DESC"] = "美化友方與敵方的 HealerCC 警示冷卻。"
L["MYDRS_DESC"] = "美化 MyDRs 的遞減效果圖示冷卻。MyDRs 保留其自身的 DR 狀態標籤（50% / IMM）。"
L["SARENA_DESC"] = "美化 sArena_Reloaded 的冷卻計時器。"
L["TELLMEWHEN_DESC"] = "美化 TellMeWhen 的冷卻文字與掃動邊緣。"
L["TELLMEWHEN_TIMER_OPTIONS_NOTICE"] = "計時器可見性、計時器文字、陰影方向與 GCD 顯示仍由 TellMeWhen 控制。掃動邊緣的可見性與厚度在此控制。"
L["TELLMEWHEN_EDGE_SCALE_DESC"] = "在 MiniCE 啟用後縮放 TellMeWhen 的掃動邊緣。"

-- Dynamic Text Colors
L["Allow Threshold Colors"] = "允許門檻顏色"
L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."] = "允許全域的「依剩餘時間上色」門檻覆蓋此分類的靜態文字顏色。"
L["Behavior"] = "行為"
L["Advanced Threshold Settings"] = "進階門檻設定"
L["Threshold Colors"] = "門檻顏色"
L["THRESHOLD_COLORS_DESC"] = "每個區段定義該剩餘時間範圍所使用的臨界值與顏色。"
L["Threshold Transition Offset"] = "門檻轉換偏移"
L["Moves the start of each next color band. Negative values switch slightly earlier."] = "移動下一個顏色區段的起始點。負值會讓切換提前一些。"
L["Beyond Thresholds Color"] = "超過門檻顏色"

-- Abbreviation
L["Show Tenths Below (seconds)"] = "低於此值顯示小數（秒）"
L["Cooldown numbers below this threshold will show one decimal place (e.g. 8.7). Set 0 to disable."] = "低於此門檻的冷卻數字將顯示一位小數（例如 8.7）。設為 0 可停用。"

-- Performance Warning
L["PERF_WARNING_DESC"] = "此功能可能影響效能並導致 FPS 下降，請僅在效能較強的設備上使用。"

-- Font Options
L["Game Default"] = "遊戲預設"
