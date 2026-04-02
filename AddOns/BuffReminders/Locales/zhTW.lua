local _, BR = ... -- luacheck: ignore 211
if GetLocale() ~= "zhTW" then
    return
end

local L = BR.L -- luacheck: ignore 211

-- Translate below. Missing entries fall back to English automatically.
-- See Locales/enUS.lua for all available keys and their English values.
-- Example: L["Category.Raid"] = "Your Translation"

-- ============================================================================
-- CATEGORY LABELS
-- ============================================================================
L["Category.Raid"] = "團隊"
L["Category.Presence"] = "常駐"
L["Category.Targeted"] = "指向"
L["Category.Self"] = "自身"
L["Category.Pet"] = "寵物"
L["Category.Consumable"] = "消耗品"
L["Category.Custom"] = "自訂"

-- Long form (used in Options section headers)
L["Category.RaidBuffs"] = "團隊增益"
L["Category.TargetedBuffs"] = "指向增益"
L["Category.Consumables"] = "消耗品"
L["Category.PresenceBuffs"] = "常駐增益"
L["Category.SelfBuffs"] = "自身增益"
L["Category.PetReminders"] = "寵物提醒"
L["Category.CustomBuffs"] = "自訂增益"

-- Category notes
L["Category.RaidNote"] = "(為整個隊伍/團隊)"
L["Category.TargetedNote"] = "(施放在其他人身上的增益)"
L["Category.ConsumableNote"] = "(精煉、食物、符文、油)"
L["Category.PresenceNote"] = "(至少需要有1人具備)"
L["Category.SelfNote"] = "(僅限自身的增益)"
L["Category.PetNote"] = "(召喚寵物提醒)"
L["Category.CustomNote"] = "(依據法術ID追蹤任何增益/發光效果)"

-- ============================================================================
-- BUFF OVERLAY TEXT
-- ============================================================================
-- These must be kept very short (2-4 chars per line) to fit on small icons.
L["Overlay.NoDrPoison"] = "無\n減傷\n毒藥"
L["Overlay.NoAura"] = "無\n光環"
L["Overlay.NoStone"] = "無\n石"
L["Overlay.NoFaith"] = "無\n信仰"
L["Overlay.NoLight"] = "無\n聖光"
L["Overlay.NoES"] = "無\n大地盾"
L["Overlay.NoSource"] = "無\n源泉"
L["Overlay.NoScales"] = "無\n鱗片"
L["Overlay.NoLink"] = "無\n連結"
L["Overlay.NoAttune"] = "無\n同調"
L["Overlay.NoFamiliar"] = "無\n魔寵"
L["Overlay.DropWell"] = "放\n糖門"
L["Overlay.NoGrim"] = "無\n魔典"
L["Overlay.NoRite"] = "無\n儀式"
L["Overlay.ApplyPoison"] = "上\n毒"
L["Overlay.NoForm"] = "無\n形態"
L["Overlay.NoEL"] = "無\n大地"
L["Overlay.NoFT"] = "無\n火舌"
L["Overlay.NoTG"] = "無\nTG"
L["Overlay.NoWF"] = "無\n風怒"
L["Overlay.NoSelfES"] = "自身\n無大地"
L["Overlay.NoShield"] = "無\n盾"
L["Overlay.NoPet"] = "無\n寵物"
L["Overlay.PassivePet"] = "被動\n寵物"
L["Overlay.WrongPet"] = "錯誤\n寵物"
L["Overlay.NoRune"] = "無\n符文"
L["Overlay.NoFlask"] = "無\n精煉"
L["Overlay.NoFood"] = "無\n食物"
L["Overlay.NoWeaponBuff"] = "無\n武器\n增益"
L["Overlay.Buff"] = "增益!"
L["Overlay.MinutesFormat"] = "%d分"
L["Overlay.LessThanOneMinute"] = "<1分"
L["Overlay.SecondsFormat"] = "%d秒"

-- ============================================================================
-- BUFF GROUP DISPLAY NAMES
-- ============================================================================
L["Group.Beacons"] = "信標"
L["Group.ShamanImbues"] = "薩滿附魔"
L["Group.PaladinRites"] = "聖騎士儀式"
L["Group.Pets"] = "寵物"
L["Group.ShamanShields"] = "薩滿護盾"
L["Group.Flask"] = "精煉藥劑"
L["Group.Food"] = "食物"
L["Group.DelveFood"] = "探究食物"
L["Group.Healthstone"] = "治療石"
L["Group.AugmentRune"] = "強化符文"
L["Group.WeaponBuff"] = "武器增益"

-- ============================================================================
-- BUFF INFO TOOLTIPS
-- ============================================================================
L["Tooltip.MayShowExtraIcon"] = "可能會顯示額外圖示"
L["Tooltip.MayShowExtraIcon.Desc"] =
    "在你施放此法術之前，你可能會同時看到此圖示與水/閃電之盾的提醒。因為我無法判斷你是要在自己身上施放大地之盾，還是要將大地之盾施放在隊友身上，同時自己保持水/閃電之盾。"
L["Tooltip.InstanceEntryReminder"] = "進入副本提醒"
L["Tooltip.InstanceEntryReminder.Desc"] =
    "當你進入地城時會短暫顯示，提醒你施放靈魂之井。在施放後或 30 秒後消失。"
L["Tooltip.DelvesOnly"] = "僅限探究"
L["Tooltip.DelvesOnly.Desc"] =
    "當你進入探究時會短暫顯示，提醒你吃瓦麗拉的食物。在偵測到增益或 30 秒後消失。"

-- ============================================================================
-- GLOW TYPE NAMES
-- ============================================================================
L["Glow.Pixel"] = "像素"
L["Glow.AutoCast"] = "自動施放"
L["Glow.Border"] = "邊框"
L["Glow.Proc"] = "觸發"

-- ============================================================================
-- CORE
-- ============================================================================
L["Core.Any"] = "任意"

-- ============================================================================
-- PROFILES
-- ============================================================================
L["Profile.SwitchQueued"] = "已排程於戰鬥結束後切換設定檔。"
L["Profile.Switched"] = "已切換至設定檔「%s」。"

-- ============================================================================
-- MOVERS
-- ============================================================================
L["Mover.SetPosition"] = "設定位置"
L["Mover.AnchorFrame"] = "對齊框架"
L["Mover.AnchorPoint"] = "對齊點"
L["Mover.NoneScreenCenter"] = "無 (螢幕中央)"
L["Mover.Apply"] = "套用"
L["Mover.BuffAnchor"] = "增益位置"
L["Mover.DragTooltip"] = "拖曳以重新定位\n點擊以切換座標編輯器"
L["Mover.MainEmpty"] = "主要位置 (空)"
L["Mover.MainAll"] = "主要位置 (全部)"
L["Mover.Detached"] = "已分離"

-- ============================================================================
-- DISPLAY
-- ============================================================================
L["Display.FramesLocked"] = "框架已鎖定。"
L["Display.FramesUnlocked"] = "框架已解鎖。"
L["Display.MinimapHidden"] = "小地圖圖示已隱藏。"
L["Display.MinimapShown"] = "小地圖圖示已顯示。"
L["Display.Description"] = "一目了然地追蹤缺失的增益效果。"
L["Display.OpenOptions"] = "打開選項"
L["Display.SlashCommands"] = "斜線指令：/br, /br lock, /br unlock, /br test, /br minimap"
L["Display.MinimapLeftClick"] = "|cFFCFCFCF左鍵點擊|r：選項"
L["Display.MinimapRightClick"] = "|cFFCFCFCF右鍵點擊|r：測試模式"
L["Display.DismissConsumables"] = "隱藏消耗品提醒直到下次讀取畫面"

-- ============================================================================
-- OPTIONS: TAB LABELS
-- ============================================================================
L["Tab.Buffs"] = "增益"
L["Tab.DisplayBehavior"] = "顯示/行為"
L["Tab.Settings"] = "設定"
L["Tab.Profiles"] = "設定檔"

-- ============================================================================
-- OPTIONS: GLOBAL DEFAULTS
-- ============================================================================
L["Options.GlobalDefaults"] = "全域預設"
L["Options.GlobalDefaults.Note"] = "(所有類別都會繼承這些設定，除非覆蓋為自訂外觀)"
L["Options.Default"] = "預設"
L["Options.Font"] = "字體"

-- ============================================================================
-- OPTIONS: GLOW SETTINGS
-- ============================================================================
L["Options.GlowReminderIcons"] = "提醒圖示發光"
L["Options.GlowReminderIcons.Title"] = "提醒圖示發光"
L["Options.GlowReminderIcons.Desc"] =   "為提醒圖示加上光暈效果。可分別自訂「即將到期」與「缺少」的光暈樣式。"
L["Options.GlowKind.Expiring"] =        "即將到期"
L["Options.GlowKind.Missing"] =         "缺少"
L["Options.GlowSettings.Expiring"] =    "光暈設定 — 即將到期"
L["Options.GlowSettings.Missing"] =     "光暈設定 — 缺少"
L["Options.Glow.Enabled"] =             "啟用"
L["Options.Threshold"] = "閾值"
L["Options.GlowMissingPets"] = "缺失寵物發光"
L["Options.CustomGlowStyle"] = "自訂發光樣式"
L["Options.Expiration"] = "過期"
L["Options.Glow"] = "發光"
L["Options.UseCustomColor"] = "使用自訂顏色"
L["Options.UseCustomColor.Desc"] =
    "啟用時，觸發發光效果會降低飽和度並重新著色。\n這看起來會比預設的觸發發光效果不那麼鮮豔。"
L["Options.ExpirationReminder"] = "過期提醒"

-- Glow params
L["Options.Glow.Type"] = "類型："
L["Options.Glow.Size"] = "大小："
L["Options.Glow.Duration"] = "持續時間"
L["Options.Glow.Frequency"] = "頻率"
L["Options.Glow.Length"] = "長度"
L["Options.Glow.Lines"] = "線條"
L["Options.Glow.Particles"] = "粒子"
L["Options.Glow.Scale"] = "縮放"
L["Options.Glow.Speed"] = "速度"
L["Options.Glow.StartAnimation"] = "起始動畫"
L["Options.Glow.XOffset"] = "X 偏移"
L["Options.Glow.YOffset"] = "Y 偏移"

-- ============================================================================
-- OPTIONS: CONTENT VISIBILITY
-- ============================================================================
L["Options.HidePvPMatchStart"] = "PvP對戰開始時隱藏"
L["Options.HidePvPMatchStart.Title"] = "PvP對戰開始時隱藏"
L["Options.HidePvPMatchStart.Desc"] = "一旦 PvP 對戰開始 (準備階段結束後)，隱藏此類別。"
L["Options.ReadyCheckOnly"] = "僅在確認準備時顯示"
L["Options.ReadyCheckOnly.Desc"] = "僅在確認準備開始後的 15 秒內顯示此類別的增益"
L["Options.Visibility"] = "可見度"
L["Options.PerCategoryCustomization"] = "各類別自訂"
L["Options.DetachIcon"] =      "獨立顯示"
L["Options.DetachIcon.Desc"] = "將此圖示移至可獨立定位的框架"

-- ============================================================================
-- OPTIONS: HEALTHSTONE
-- ============================================================================
L["Options.Healthstone"] = "治療石"
L["Options.Healthstone.ReadyCheckOnly"] = "僅確認準備"
L["Options.Healthstone.ReadyCheckWarlock"] = "確認準備 + 術士永遠顯示"
L["Options.Healthstone.AlwaysShow"] = "永遠顯示"
L["Options.Healthstone.Visibility"] = "治療石可見度"
L["Options.Healthstone.Visibility.Desc"] =
    "控制何時顯示治療石提醒。\n\n|cffffcc00僅確認準備：|r 僅在確認準備期間 (15秒內)。\n|cffffcc00確認準備 + 術士永遠顯示：|r 術士永遠可見；其他職業僅在確認準備時顯示。\n|cffffcc00永遠顯示：|r 只要符合內容類型就會顯示。"
L["Options.Healthstone.WarlockAlwaysDesc"] = "術士永遠可見提醒；其他職業僅在確認準備時顯示"
L["Options.Healthstone.ReadyCheckDesc"] = "在確認準備開始後的 15 秒內顯示"
L["Options.Healthstone.AlwaysDesc"] = "只要符合內容類型就會顯示"

-- ============================================================================
-- OPTIONS: FREE CONSUMABLES
-- ============================================================================
L["Options.FreeConsumables"] = "免費消耗品"
L["Options.FreeConsumables.Note"] = "(治療石、永久強化符文)"
L["Options.FreeConsumables.Override"] = "覆蓋內容過濾器"
L["Options.FreeConsumables.Override.Desc"] =
    "勾選時，免費消耗品將使用下方自己的內容類型可見度設定。\n\n取消勾選時，它們將跟隨其他消耗品相同的內容過濾器。"

-- ============================================================================
-- OPTIONS: ICONS
-- ============================================================================
L["Options.Icons"] = "圖示"
L["Options.ShowText"] = "在圖示上顯示文字"
L["Options.ShowText.Desc"] = "在此類別的增益圖示上顯示數量或缺失的文字疊加"
L["Options.ShowMissingCountOnly"] = "僅顯示缺失數量"
L["Options.ShowMissingCountOnly.Desc"] =
    '僅顯示缺失的增益數量 (例如「1」)，而不是完整數量 (例如「19/20」)'
L["Options.ShowBuffReminderText"] = '顯示「增益!」提醒文字'
L["Options.BuffTextOffsetX"] = '增益! X'
L["Options.BuffTextOffsetY"] = '增益! Y'
L["Options.Size"] = "大小"

-- ============================================================================
-- OPTIONS: CLICK TO CAST
-- ============================================================================
L["Options.ClickToCast"] = "點擊施放"
L["Options.ClickToCast.DescFull"] =
    "讓增益圖示可以被點擊以施放對應法術 (僅限非戰鬥狀態)。僅適用於你的角色可以施放的法術。"
L["Options.HoverHighlight"] = "滑鼠指向時顯著標示"
L["Options.HoverHighlight.Desc"] = "滑鼠指向可點擊的增益圖示上時顯示微弱的顯著標示效果。"

-- ============================================================================
-- OPTIONS: PET
-- ============================================================================
L["Options.PetSpecIcon"] = "懸停時顯示獵人寵物專精圖示"
L["Options.PetSpecIcon.Title"] = "懸停時顯示寵物專精圖示"
L["Options.PetSpecIcon.Desc"] =
    "懸停時將寵物圖示切換為其專精技能 (狡詐、凶暴、堅毅)。"
L["Options.ShowItemTooltips"] = "顯示物品提示"
L["Options.ShowItemTooltips.Desc"] = "懸停在消耗品圖示上時，顯示其物品提示。"
L["Options.Behavior"] = "行為"
L["Options.PetPassiveCombat"] = "僅在戰鬥中顯示寵物被動"
L["Options.PetPassiveCombat.Desc"] =
    "僅在戰鬥中顯示被動寵物提醒。停用時，提醒會永遠顯示。"
L["Options.FelDomination"] = "召喚前使用惡魔支配"
L["Options.FelDomination.Title"] = "惡魔支配"
L["Options.FelDomination.Desc"] =
    "透過點擊施放召喚惡魔之前，自動施放惡魔支配。如果惡魔支配在冷卻中，則正常進行召喚。需要惡魔支配天賦。"

-- ============================================================================
-- OPTIONS: PET DISPLAY
-- ============================================================================
L["Options.PetDisplay"] = "寵物顯示"
L["Options.PetDisplay.Generic"] = "通用圖示"
L["Options.PetDisplay.GenericDesc"] = "單一的通用「無寵物」圖示"
L["Options.PetDisplay.Summon"] = "召喚法術"
L["Options.PetDisplay.SummonDesc"] = "將每個寵物召喚法術作為獨立圖示"
L["Options.PetDisplay.Mode"] = "寵物顯示模式"
L["Options.PetDisplay.Mode.Desc"] = "缺失寵物提醒的顯示方式。"
L["Options.PetLabels"] = "寵物標籤"
L["Options.PetLabels.Desc"] = "在每個圖示下方顯示寵物名稱與專精。"
L["Options.PetLabels.SizePct"] = "大小 %"

-- ============================================================================
-- OPTIONS: CONSUMABLE DISPLAY
-- ============================================================================
L["Options.ConsumableTextScale"] = "文字縮放"
L["Options.ConsumableTextScale.Title"] = "消耗品文字縮放"
L["Options.ConsumableTextScale.Desc"] =
    "物品數量與品質 (R1/R2/R3) 標籤的字體大小，以圖示大小的百分比表示。"
L["Options.ItemDisplay"] = "物品顯示"
L["Options.ItemDisplay.IconOnly"] = "僅圖示"
L["Options.ItemDisplay.IconOnlyDesc"] = "顯示數量最多的物品"
L["Options.ItemDisplay.SubIcons"] = "子圖示"
L["Options.ItemDisplay.SubIconsDesc"] = "每個圖示下方顯示可點擊的小型物品變體"
L["Options.ItemDisplay.Expanded"] = "展開"
L["Options.ItemDisplay.ExpandedDesc"] = "將每個物品變體作為完整大小的圖示"
L["Options.ItemDisplay.Mode"] = "消耗品物品顯示"
L["Options.ItemDisplay.Mode.Desc"] =
    "具有多種變體 (例如不同精煉類型) 的消耗品物品的顯示方式。"
L["Options.SubIconSide"] = "側面"
L["Options.SubIconSide.Bottom"] = "下"
L["Options.SubIconSide.Top"] = "上"
L["Options.SubIconSide.Left"] = "左"
L["Options.SubIconSide.Right"] = "右"
L["Options.ShowWithoutItems"] = "即使沒有物品也顯示"
L["Options.ShowWithoutItems.Title"] = "顯示沒有物品的消耗品"
L["Options.ShowWithoutItems.Desc"] =
    "啟用時，即使你的背包中沒有該物品，也會顯示消耗品提醒。停用時，只顯示你實際攜帶的消耗品。"
L["Options.DelveFoodOnly"] = "在探究中僅顯示探究食物"
L["Options.DelveFoodOnly.Desc"] = "進入探究時，隱藏探究食物以外的所有消耗品提醒。"

-- ============================================================================
-- OPTIONS: LAYOUT
-- ============================================================================
L["Options.Layout"] = "版面配置"
L["Options.Priority"] = "優先級"
L["Options.Priority.Desc"] =
    "控制此類別在合併框架中的順序。較低的值會優先顯示。"
L["Options.SplitFrame"] = "分離為獨立框架"
L["Options.SplitFrame.Desc"] = "將此類別的增益顯示在一個獨立的、可獨立移動的框架中"
L["Options.DisplayPriority"] = "顯示優先級"

-- ============================================================================
-- OPTIONS: APPEARANCE
-- ============================================================================
L["Options.CustomAppearance"] = "使用自訂外觀"
L["Options.CustomAppearance.Desc"] =
    "停用時，此類別繼承全域預設的外觀設定。增長方向需要分離為獨立框架才能設定。"
L["Options.Customize"] = "自訂"
L["Options.ResetPosition"] = "重置位置"
L["Options.MasqueNote"] = "縮放和邊框設定由 Masque 管理"

-- ============================================================================
-- OPTIONS: SETTINGS TAB
-- ============================================================================
L["Options.ShowLoginMessages"] = "顯示登入訊息"
L["Options.ShowMinimapButton"] = "顯示小地圖按鈕"
L["Options.ShowOnlyInGroup"] = "僅在隊伍/團隊中顯示"

-- Hide when section
L["Options.HideWhen"] = "隱藏時機："
L["Options.HideWhen.Resting"] = "休息狀態"
L["Options.HideWhen.Resting.Title"] = "休息時隱藏"
L["Options.HideWhen.Resting.Desc"] = "在旅館或主城中隱藏增益提醒"
L["Options.HideWhen.Combat"] = "戰鬥中"
L["Options.HideWhen.Expiring"] = "戰鬥中即將過期"
L["Options.HideWhen.Expiring.Title"] = "戰鬥中隱藏即將過期的增益"
L["Options.HideWhen.Expiring.Desc"] =
    "在戰鬥中，隱藏即將過期的增益，僅顯示完全缺失的增益"
L["Options.HideWhen.Vehicle"] = "在載具中"
L["Options.HideWhen.Vehicle.Title"] = "在載具中隱藏"
L["Options.HideWhen.Vehicle.Desc"] =
    "在任務載具中隱藏所有增益提醒。停用時，團隊和常駐增益仍會顯示"
L["Options.HideWhen.Mounted"] = "乘騎時"
L["Options.HideWhen.Mounted.Title"] = "乘騎時隱藏"
L["Options.HideWhen.Mounted.Desc"] =
    "乘騎時隱藏所有增益提醒。此選項會覆蓋各類別的寵物乘騎隱藏設定"
L["Options.HideWhen.Legacy"] = "在傳統副本中"
L["Options.HideWhen.Legacy.Title"] = "在傳統副本中隱藏"
L["Options.HideWhen.Legacy.Desc"] =
    "在非常舊的副本中隱藏所有增益提醒 (當傳統拾取啟用時)"

-- ============================================================================
-- OPTIONS: BUFF TRACKING MODE
-- ============================================================================
L["Options.BuffTracking"] = "增益追蹤"
L["Options.BuffTracking.All"] = "所有增益，所有玩家"
L["Options.BuffTracking.All.Desc"] =
    "顯示每個職業的所有團隊和常駐增益，追蹤完整的團隊覆蓋率。"
L["Options.BuffTracking.MyBuffs"] = "僅限我的增益，所有玩家"
L["Options.BuffTracking.MyBuffs.Desc"] =
    "僅顯示你的職業可提供的增益。仍會追蹤完整的團隊覆蓋率。"
L["Options.BuffTracking.OnlyMine"] = "僅限我需要的增益"
L["Options.BuffTracking.OnlyMine.Desc"] =
    "顯示所有增益類型，但僅檢查你個人是否具備。不顯示團隊數量。"
L["Options.BuffTracking.Smart"] = "智慧"
L["Options.BuffTracking.Smart.Desc"] =
    "你的職業所提供的增益會追蹤完整的團隊覆蓋率。其他職業的增益僅檢查你個人。"
L["Options.BuffTracking.Mode"] = "增益追蹤模式"
L["Options.BuffTracking.Mode.Desc"] =
    "控制顯示哪些團隊和常駐增益，以及它們是追蹤完整團隊還是僅限你個人。"

-- ============================================================================
-- OPTIONS: PROFILES TAB
-- ============================================================================
L["Options.ActiveProfile"] = "作用中設定檔"
L["Options.ActiveProfile.Desc"] =
    "在已儲存的設定之間切換。每個角色可以使用不同的設定檔。"
L["Options.SelectProfile"] = "選擇一個設定檔"
L["Options.Profile"] = "設定檔"
L["Options.CopyFrom"] = "複製自"
L["Options.Delete"] = "刪除"
L["Options.PerSpecProfiles"] = "按專精設定檔"
L["Options.PerSpecProfiles.Desc"] = "當你更改專精時，自動切換設定檔。"
L["Options.PerSpecProfiles.Enable"] = "啟用按專精設定檔"

-- ============================================================================
-- OPTIONS: IMPORT/EXPORT
-- ============================================================================
L["Options.ExportSettings"] = "匯出設定"
L["Options.ExportSettings.Desc"] = "複製下方字串以與其他人分享你的設定。"
L["Options.ImportSettings"] = "匯入設定"
L["Options.ImportSettings.DescPlain"] = "在下方貼上設定字串。"
L["Options.ImportSettings.Overwrite"] = "這將覆蓋作用中的設定檔。"
L["Options.Export"] = "匯出"
L["Options.Import"] = "匯入"
L["Options.ImportSuccess"] = "設定匯入成功！"
L["Options.FailedExport"] = "匯出失敗"
L["Options.UnknownError"] = "未知的錯誤"

-- ============================================================================
-- OPTIONS: DIALOGS
-- ============================================================================
L["Dialog.Cancel"] = "取消"
L["Dialog.DeleteCustomBuff"] = '要刪除自訂增益「%s」嗎？'
L["Dialog.ResetProfile"] =
    "要將目前的設定檔重置為預設值嗎？\n\n這將清除目前設定檔中的所有自訂內容\n並重新載入介面。"
L["Dialog.Reset"] = "重置"
L["Dialog.ReloadPrompt"] = "設定匯入成功！\n重新載入介面以套用變更？"
L["Dialog.Reload"] = "重新載入"
L["Dialog.NewProfilePrompt"] = "輸入新設定檔的名稱："
L["Dialog.Create"] = "建立"
L["Dialog.DiscordPrompt"] = "加入 BuffReminders Discord！\n複製下方網址 (Ctrl+C)："
L["Dialog.Close"] = "關閉"

-- ============================================================================
-- OPTIONS: TEST / LOCK
-- ============================================================================
L["Options.LockUnlock"] = "鎖定 / 解鎖"
L["Options.LockUnlock.Desc"] = "解鎖以顯示位置控制點，以便重新定位增益框架。"
L["Options.TestAppearance"] = "測試外觀"
L["Options.TestAppearance.Desc"] =
    "顯示你選擇的增益並帶有假數值，以便預覽其外觀。"
L["Options.Test"] = "測試"
L["Options.StopTest"] = "停止測試"
L["Options.AnchorHint"] = "點擊主要位置以更新其對齊點位置或座標"
L["Options.Lock"] = "鎖定"
L["Options.Unlock"] = "解鎖"

-- ============================================================================
-- OPTIONS: CUSTOM BUFF MODAL
-- ============================================================================
L["CustomBuff.Edit"] = "編輯自訂增益"
L["CustomBuff.Add"] = "新增自訂增益"
L["CustomBuff.AddButton"] = "+ 新增自訂增益"
L["CustomBuff.SpellIDs"] = "法術ID："
L["CustomBuff.Lookup"] = "查詢"
L["CustomBuff.AddSpellID"] = "+ 新增法術 ID"
L["CustomBuff.Name"] = "名稱："
L["CustomBuff.Text"] = "文字："
L["CustomBuff.LineBreakHint"] = "(使用 \\n 換行)"
L["CustomBuff.Appearance"] = "外觀"
L["CustomBuff.Conditions"] = "條件"
L["CustomBuff.ShowIn"] = "顯示於"
L["CustomBuff.ClickAction"] = "點擊動作"
L["CustomBuff.SettingsMovedNote"] = "可見度和確認準備設定已移至各增益的編輯選單中。"

-- Custom buff mode toggles
L["CustomBuff.WhenActive"] = "作用時"
L["CustomBuff.WhenMissing"] = "缺失時"
L["CustomBuff.OnlyIfSpellKnown"] = "僅當學會法術時"

-- Custom buff class dropdown
L["Class.Any"] = "任意"
L["Class.DeathKnight"] = "死亡騎士"
L["Class.DemonHunter"] = "惡魔獵人"
L["Class.Druid"] = "德魯伊"
L["Class.Evoker"] = "喚能師"
L["Class.Hunter"] = "獵人"
L["Class.Mage"] = "法師"
L["Class.Monk"] = "武僧"
L["Class.Paladin"] = "聖騎士"
L["Class.Priest"] = "牧師"
L["Class.Rogue"] = "盜賊"
L["Class.Shaman"] = "薩滿"
L["Class.Warlock"] = "術士"
L["Class.Warrior"] = "戰士"

-- Custom buff fields
L["CustomBuff.Spec"] = "專精："
L["CustomBuff.Class"] = "職業："
L["CustomBuff.RequireItem"] = "需要物品："
L["CustomBuff.RequireItem.EquippedBags"] = "已裝備/背包"
L["CustomBuff.RequireItem.Equipped"] = "已裝備"
L["CustomBuff.RequireItem.InBags"] = "在背包中"
L["CustomBuff.RequireItem.Hint"] = "物品 ID — 如果未找到則隱藏"

-- Bar glow options
L["CustomBuff.BarGlow.WhenGlowing"] = "發光時偵測"
L["CustomBuff.BarGlow.WhenNotGlowing"] = "不發光時偵測"
L["CustomBuff.BarGlow.Disabled"] = "已停用"
L["CustomBuff.BarGlow"] = "快捷列發光："
L["CustomBuff.BarGlow.Title"] = "快捷列發光備用方案"
L["CustomBuff.BarGlow.Desc"] =
    "在 M+/PvP/戰鬥中，當增益 API 受到限制時，使用快捷列法術發光進行備用偵測。如果你只想追蹤增益是否存在，請停用此功能。"

-- Ready check / level
L["CustomBuff.ReadyCheckOnly"] = "僅在確認準備時"
L["CustomBuff.Level"] = "等級："
L["CustomBuff.Level.Any"] = "任意等級"
L["CustomBuff.Level.Max"] = "僅限最高等級"
L["CustomBuff.Level.BelowMax"] = "低於最高等級"

-- Click action
L["CustomBuff.Action.None"] = "無"
L["CustomBuff.Action.Spell"] = "法術"
L["CustomBuff.Action.Item"] = "物品"
L["CustomBuff.Action.Macro"] = "巨集"
L["CustomBuff.Action.OnClick"] = "點擊時："
L["CustomBuff.Action.Title"] = "點擊動作"
L["CustomBuff.Action.Desc"] =
    "點擊此增益圖示時發生的動作。「法術」會施放法術，「物品」會使用物品，「巨集」會執行巨集指令。"
L["CustomBuff.Action.MacroHint"] = "例如 /use item:12345\\n/use 13"

-- Save/Cancel/Delete
L["CustomBuff.Save"] = "儲存"
L["CustomBuff.ValidateError"] = "請至少驗證一個法術 ID"

-- Custom buff tooltip
L["CustomBuff.Tooltip.Title"] = "自訂增益"
L["CustomBuff.Tooltip.Desc"] = "右鍵點擊以編輯或刪除"

-- Custom buff status
L["CustomBuff.InvalidID"] = "無效 ID"
L["CustomBuff.NotFound"] = "未找到"
L["CustomBuff.NotFoundRetry"] = "未找到 (重試)"
L["CustomBuff.Error"] = "錯誤："

-- ============================================================================
-- OPTIONS: DISCORD
-- ============================================================================
L["Options.JoinDiscord"] = "加入 Discord"
L["Options.JoinDiscord.Title"] = "點擊獲取邀請連結"
L["Options.JoinDiscord.Desc"] = "有回饋意見、功能請求或錯誤回報？\n加入我們的 Discord！"

-- ============================================================================
-- OPTIONS: CUSTOM ANCHOR FRAMES
-- ============================================================================
L["Options.CustomAnchorFrames"] = "自訂對齊框架"
L["Options.CustomAnchorFrames.Desc"] =
    "將全域框架名稱加入對齊下拉選單 (例如 MyAddon_PlayerFrame)。\n遊戲中不存在的框架將會被自動略過。"
L["Options.Add"] = "新增"
L["Options.New"] = "新增"
L["Options.ResetToDefaults"] = "重置為預設"

-- ============================================================================
-- OPTIONS: MISC
-- ============================================================================
L["Options.Off"] = "關閉"
L["Options.Always"] = "總是"
L["Options.ReadyCheck"] = "確認準備"
L["Options.Min"] = "分鐘"

-- ============================================================================
-- COMPONENTS (UI/Components.lua)
-- ============================================================================
-- Slider tooltip
L["Component.AdjustValue"] = "調整數值"
L["Component.AdjustValue.Desc"] = "點擊輸入或使用滑鼠滾輪"

-- Direction labels
L["Direction.Left"] = "左"
L["Direction.Center"] = "中"
L["Direction.Right"] = "右"
L["Direction.Up"] = "上"
L["Direction.Down"] = "下"
L["Direction.Label"] = "方向"

-- Content visibility
L["Content.ShowIn"] = "顯示於："

-- Content toggle definitions
L["Content.OpenWorld"] = "開放世界"
L["Content.Housing"] = "玩家房屋"
L["Content.Scenarios"] = "事件 (探究、托迦司等)"
L["Content.Dungeons"] = "地城 (包含 M+)"
L["Content.Raids"] = "團隊副本"
L["Content.PvP"] = "PvP (競技場與戰場)"

-- Scenario difficulty
L["Content.Delves"] = "探究"
L["Content.OtherScenarios"] = "其他事件 (托迦司等)"

-- Dungeon difficulty
L["Content.NormalDungeons"] = "普通地城"
L["Content.HeroicDungeons"] = "英雄地城"
L["Content.MythicDungeons"] = "傳奇地城"
L["Content.MythicPlus"] = "傳奇鑰石 (M+)"
L["Content.TimewalkingDungeons"] = "時光漫遊地城"
L["Content.FollowerDungeons"] = "追隨者地城"

-- Raid difficulty
L["Content.LFR"] = "隨機團隊"
L["Content.NormalRaids"] = "普通團隊"
L["Content.HeroicRaids"] = "英雄團隊"
L["Content.MythicRaids"] = "傳奇團隊"

-- PvP types
L["Content.Arena"] = "競技場"
L["Content.Battlegrounds"] = "戰場"

-- 自行加入
L["BuffReminders"] = "增益提醒"
L["|cffffffffBuff|r|cffffcc00Reminders|r"] = "|cffffffff增益|r|cffffcc00提醒|r"