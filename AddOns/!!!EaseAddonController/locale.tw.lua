if GetLocale() ~= "zhTW" then return end

local L = select(2, ...).L

TAG_CLASS = ((U1PlayerClass=="DEATHKNIGHT" and "死亡騎士") or (U1PlayerClass=="DEMONHUNTER" and "惡魔獵人") or UnitClass("player")) .. "專用"
TAG_NOTAGS = "五花八門"
TAG_ALL = "全部插件"

TAG_SOCIAL = "聊天社交"
TAG_AUCTION = "商人拍賣"
TAG_PVP = "PvP"
TAG_COMBAT = "戰鬥相關"
TAG_ENHANCEMENT = "介面增強"
TAG_ITEM = "物品裝備"
TAG_MAP = "地圖資訊"
TAG_QUEST = "任務升級"
TAG_BOSSRAID = "副本團隊"
TAG_PROFESSION = "專業技能"
TAG_UNITFRAME = "頭像框架"
TAG_ACTIONBAR = "快捷列"
TAG_CLASSALL = "職業專屬"
TAG_COLLECTION = "成就收藏"
TAG_MISC = "進階使用"

U1REASON_INCOMPATIBLE = "不相容"
U1REASON_DISABLED = "未啟用"
U1REASON_INTERFACE_VERSION = "版本過期"
U1REASON_DEP_DISABLED = "相關插件未啟用"
U1REASON_DEP_CORRUPT = "相關插件無法載入"
U1REASON_SHORT_DEP_CORRUPT = "相關失敗"
U1REASON_SHORT_DEP_DISABLED = "相關未啟用"
U1REASON_DEP_INTERFACE_VERSION = "相關插件版本過期"
U1REASON_SHORT_DEP_INTERFACE_VERSION = "相關過期"
U1REASON_DEP_MISSING = "相關插件未安裝"
U1REASON_SHORT_DEP_MISSING = "相關未安裝"
U1REASON_DEP_NOT_DEMAND_LOADED = "相關插件無法在需要時載入"
U1REASON_SHORT_DEP_NOT_DEMAND_LOADED = "相關無法在需要時載入"

--- ===========================================================
-- 163UI.lua
--- ===========================================================
L["|cff1acd1c[EAC]|r- "] = "|cff1acd1c【插件控制台】|r- "
L["%|cff880303%[EAC%]%|r "] = "%|cff880303%[插件控制台%]%|r "
L["Load Now"] = "強制載入"
L["desc.Load Now"] = "說明`本插件會在滿足條件時自動載入，如果現在就要載入請點擊此按鈕` `|cffff0000注意：有可能會出錯|r"
L["Options"] = "設定選項"

L["Reload to completely disable %s."] = "停用%s需要重新載入介面。"
L["AddOn |cffffd100%s|r"] = "插件-|cffffd100%s|r-"
L["%s loaded"] = "%s載入成功"
L["%s load failed, reason: "] = "%s載入失敗，原因："
L["unknown"] = "未知"
L["%s is current paused, the memory will not release until reload ui."] = "%s已暫停，重新載入介面後才會釋放記憶體。"
L["%s is no longer disabled."] = "%s不再停用。"
L["%s is enabled, and will load on demand."] = "%s已啟用, 需要時會自動載入。"
L["%%s load failed, error loading dependency [%s]"] = "%%s載入失敗，相關插件[%s]無法載入。"

--- ===========================================================
-- 163UIUI_V3.lua
--- ===========================================================
--- Quick Menu
L["AddOn: "] = "插件："
L["Quick Enable/Disable AddOn"] = "快速啟用/停用插件"
L["Scale"] = "縮放"

--- AddOn Status on Tooltip
L["Loaded, reload to disable"] = "已載入，重新載入後停用。"
L["|cff00D100Loaded|r"] = "|cff00D100已載入|r"
L["|cff00D100Missing|r"] = "|cffff0000未安裝|r"
L["|cff00D100Disabled|r"] = "|cffA0A0A0未啟用|r"
L["Enabled"] = "已啟用"
L["Enabled, reloadui to load"] = "已啟用，需要重新載入介面。"
L["|cffA0A0A0Deps Disabled|r"] = "|cffA0A0A0相關插件未啟用|r"
L["|cffff7f7fLoad Failed|r"] = "|cffff7f7f啟用失敗|r"
L["Module"] = "模組"
L["Version"] = "版本"

--- AddOn Tooltip
L["Loading addons while in combat is not recommended.\n"] = "不建議在戰鬥中載入插件。\n"
L["Author"] = "作者"
L["Credits"] = "翻譯"
L["Folder"] = "資料夾"
L["Total"] = "全部"
L["Memory"] = "記憶體"
L["Status"] = "狀態"
L["|cff00D100LoD|r"] = "|cff00D100需要時會自動載入|r"
L["Reason"] = "原因"
L["Depends"] = "相關"
L["Individual AddOn"] = "單體插件"
L["Package AddOn"] = "整合包"

--- Tags panel and Tags tooltip
L["No Loaded Addons"] = "沒有已載入的插件"
L["  All AddOns  "] = "　彩虹ui　"

--- Top Panel
L["EAC Options"] = " 控制台選項 "
L["OP"] = "設定"
L["ReloadUI"] = " 重新載入 "
L["RL"] = "重載"
L["MemoryGC"] = " 清理記憶體 "
L["GC"] = "記憶體"
L["Profiles"] = " 方案管理 "
L["PF"] = "方案"
L["Memory Garbage Collect"] = "清理記憶體"
L["desc.GC"] = "強制回收空閒的記憶體，除了確定插件記憶體的穩定值外，並沒有太大用處。"
L["Save addons status and control panel settings, and share the profile among characters."] = "將已啟用的插件清單保存為方案，例如任務模式、副本模式...等，方便快速切換整組插件，也可以在多個角色之間共用。"
L["Show Ease Addon Controller's option page. Click again to return to the previous selected addon."] = "顯示插件控制台的介紹和設定選項，再次點擊返回之前所選取的插件。"
L["Quick Menu"] = "快速設定控制台"
L["Show frequently used toggle options, in a dropdown menu."] = "一些常用的選項，以下拉式功能表方式列出，可迅速進行設定。"
L["Please DOUBLE click to confirm"] = "請點兩下按鈕（防止誤按）"
L["Operations require reloading: "] = "以下操作需要重新載入介面："
L["|cffff0000Disable|r - "] = "|cffff0000停用|r - "
L["Modified - "] = "設定已更改 - "

--- Central Panel
L["Load All"] = "全部載入"
L["short.LoadAll"] = "全開"
L["Load all addons in the above list"] = "載入目前顯示的所有插件"
L["The game may freeze for a little while."] = "注意：載入時可能會稍微卡頓，請安心等待。"
L["Disable All"] = "全部停用"
L["short.DisableAll"] = "全關"
L["Disable all addons in the above list"] = "停用目前顯示的所有插件"
L["UI reloading is required to really disable addons."] = "停用後請手動重新載入介面"
L["Hint"] = "說明"
L["Show or hide the loaded addons in the above list"] = "顯示目前分類下已啟用的插件"
L["Disabled"] = "未啟用"
L["Show or hide the disabled addons in the above list"] = "顯示目前分類下未啟用的插件"
L["|cff00ff00 %d|r Enabled"] = "已啟用|cff00ff00 %d|r"
L["|cffAAAAAA %d|r Disabled"] = "未啟用|cffAAAAAA %d|r"
L["All of selected addons are loaded."] = "全部插件載入完畢。"

--- Right panel
L["AddOn Options"] = "插件選項"
L["AddOn Notes"] = "插件介紹"
L["AddOn Introduction"] = "插件說明"
L["Category: "] = "分類："
L["AddOns Installed: "] = "已安裝插件數："

--- Events Scripts Creating Frames
L["Search AddOns"] = "搜尋插件及選項"
L["desc.SEARCH1"] = "輸入中文或英文進行搜尋，只有一個結果時可按 Enter 鍵來選取。"
L["desc.SEARCH2"] = "可以搜尋插件名稱、資料夾名稱、選項中的文字，所有含有搜尋關鍵字的插件都會被顯示出來，符合的內容會被顯著標示。"
L["desc.SEARCH3"] = false
L["help.SEARCH"] = "這裡可以輸入中文或英文進行搜尋，例如 '|cffffd200小地圖|r' 或 '|cffffd200Map|r'。不只能查詢插件名稱，還能查詢插件的選項！"

--- GameMenu Button and Minimap Button
L["Ease AddOn"] = "彩虹ui"
L["Ease Addon Controller"] = "插件控制台"
L["Open Ease Addon Controller's main panel"] = "顯示插件控制台"
L["An advanced in-game addon control center, which combines Categoring, Searching, Loading and Setting of wow addons all together."] = ""
L["Right click to open quick menu."] = "左鍵 插件控制台|n右鍵 快速設定控制台"

--- Controls
L["Requires an UI reload"] = "需要重新載入介面"
L["Please input a number between |cffffd200%s|r and |cffffd200%s|r"] = "請輸入 |cffffd200%s|r ~ |cffffd200%s|r 之間的數字"

--- CfgEAC.lua
L["CFG.desc"] = "插件控制台是網易有愛整合插件的核心元件，您目前使用的是控制台的單體版，它可以和Curse的插件更新器強強聯手，為您提供插件分類/檢索/即時載入等功能。如果你難以忍受更新Curse的網路難題，可以嘗試一下網易有愛整合插件，其理念就是單體插件+大師調優，滿足多種用戶的需求。網址 http://wowui.w.163.com/163ui"
L["CFG.author"] = "|cffcd1a1c[網易原創]|r"
L["Ease Addon Controller Options"] = "插件控制台選項"
L["Show Minimap Button"] = "顯示小地圖按鈕"
L["Main Panel Scale"] = "控制台縮放比例"
L["Main Panel Opacity"] = "控制台透明度"
L["Show AddOns Folder Name"] = "顯示插件英文名稱"
L["Hint`Show addon folder name instead of the Title in the toc file."] = "說明`啟用時會顯示插件資料夾的名字，適合進階玩家快速選擇所需插件。"
L["Sort AddOns by Memory Usage"] = "依據插件使用的記憶體排序"
L["Hint`Sort the addons by their memory usages instead of name order."] = "說明`啟用時會依據插件 (包括子模組) 所使用的記憶體大小進行排序，停用時會依據插件名稱排序。"
L["Panel Tile Settings"] = "插件清單按鈕設定"
L["Are you sure to reset these settings, and start an UI reload?"] = "是否確定要重置這些選項並重新載入介面?"
L["AddOn Tile Width"] = "插件清單按鈕寬度"
L["AddOn Tile Height"] = "插件清單按鈕高度"
L["AddOn Tile Margin"] = "插件清單按鈕間距"

--- ===========================================================
-- Profiles.lua ProfilesUI.lua
--- ===========================================================
L["Before Load Profile"] = "載入前"
L["Before Logout"] = "登出前"
L["Before Restore"] = "重置前"
L["After Login"] = "登入後"

L["Current addon enable states will be lost, are you SURE?"] = "是否確定要捨棄目前的插件控制台設定?"
L["Are you sure to delete this profile?"] = "是否確定要刪除此方案?"
L["Ease Addon Controller Profiles"] = "插件配置方案"
L["Saved"] = "方案列表"
L["Auto"] = "自動保存"
L["EAC will automatically save profiles before logout, after login, or loading another profile."] = "角色登出、載入方案之前，會自動保存目前設定。"
L["Create Profile"] = "新增方案"
L["Restore Default"] = "恢復預設"
L["Profile: "] = "方案："
L["AddOns: "] = "插件數："
L["Today"] = "今天"
L["AddOn States"] = "插件狀態"
L["AddOn Options"] = "用法、設定和相關模組"
L["In addition of saving addon enable/disable states, also save the options shown in the EAC panel."] = "啟用時會保存/載入插件控制台裡的所有設定選項。"
L["Rename"] = "更改"
L["Unnamed"] = "未命名"
L["Load"] = "載入"
L["Delete"] = "刪除"
L["Save"] = "儲存"
L["New profile name: "] = "新方案名稱："
L["Change profile name: "] = "更改方案名稱："

-- 自行加入的
L["Name: "] = "名稱："
L["How To Use"] = "使用方法"
L["Notice"] = "特別注意"
L["Reset to Default"] = "重置為預設值"
L["Changing this option requires an UI reload"] = "更改這個選項需要重新載入介面"
L["hint.Load Now"] = "這個插件在需要使用時會自動載入，按下 '強制載入' 來立即載入它。"
