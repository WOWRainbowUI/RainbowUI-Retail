local addonName = ... ---@type string

---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

---@class Localization: AceModule
---@field data table<string, string>
local L = addon:NewModule('Localization')

-- Data is set outside of the initialization function so that
-- it loads when the file is read.
L.data = {}

if GetLocale() == "zhTW" then
	-- bag.lua
	L.data["Reagent Bank"] = "材料銀行"
	L.data["Bank"] = "銀行"
	L.data["Backpack"] = "背包"
	L.data["Left Click to open the menu."] = "點一下顯示選單"
	L.data["Left Click to open the menu, right click to swap to reagent bank and back."] = "左鍵: 顯示選單，右鍵: 切換材料銀行。"
	L.data["Recent Items"] = "新物品"
	L.data["Free Slots"] = "空格"
	
	-- bagbutton.lua
	L.data["Empty Bag Slot"] = "空的背包格子"
	
	-- bagslots.lua
	L.data["Equipped Bags"] = "已裝備的背包"
	
	-- context.lua
	L.data["Alphabetical"] = "名稱"
	L.data["Alphabetical, then Quality"] = "先名稱、再品質"
	L.data["BetterBags Menu"] = "BetterBags"
	L.data["Click to deposit all reagents into your reagent bank."] = "點一下將所有材料存放到材料銀行。"
	L.data["Click to toggle the display of the bag slots."] = "點一下切換顯示裝備背包的欄位，方便更換背包。"
	L.data["Click to toggle the display of the Blizzard bag button."] = "點一下切換顯示遊戲內建的背包按鈕。"
	L.data["Close Menu"] = "關閉選單"
	L.data["Columns"] = "直欄數"
	L.data["Compaction"] = "精簡版面"
	L.data["Custom Categories"] = "自訂分類"
	L.data["Deposit All Reagents"] = "存放所有材料"
	L.data["Edit Custom Categories..."] = "編輯自訂分類"
	L.data["Expansion"] = "資料片"
	L.data["If enabled, the item level of each item will be displayed in the corner of the item icon."] = "啟用時，會在物品圖示的角落顯示物品等級。"
	L.data["If enabled, the item level text will be colored based on the item level."] = "啟用時，會依據物品等級來顯示物品等級文字的顏色。"
	L.data["If enabled, recent items are put into their own special section at the top of your bag."] = "啟用時，最近獲得的新物品會放在背包最上方的專屬區塊中。"
	L.data["If enabled, will categorize items by "] = "啟用時，會依照"
	L.data["."] = "來分類物品。"
	L.data["If enabled, will categorize items by expansion."] = "啟用時，會依照資料片來分類物品。"
	L.data["If enabled, will categorize items by their auction house type."] = "啟用時，會依照拍賣場的類別來分類物品。"
	L.data["If enabled, will categorize items by trade skill."] = "啟用時，會依照交易技能來分類物品。"
	L.data["Items"] = "物品"
	L.data["Item Level"] = "物品等級"
	L.data["Item Level Colors"] = "物品等級顏色"
	L.data["Item level related settings for this bag."] = "和物品等級有關的設定。"
	L.data["Items per Row"] = "每列顯示幾件物品"
	L.data["Item sections will be sorted from left to right without any consideration for empty space in the bag window."] = "物品區塊會從左到右排序，不考慮背包視窗中的空白空間。"
	L.data["Item sections will be sorted from left to right, however if a section can fit in the same row as the section above it, the section will move up."] = "物品區塊會從左到右排序，如果某個區塊可以與上方的區塊放在同一列，該區塊會移至上方。"
	L.data["Items will be sorted alphabetically, then by quality."] = "先依照物品的名稱排序，再依照品質排序。"
	L.data["Items will be sorted by quality, then alphabetically."] = "先依照物品的品質排序，再依照名稱排序。"
	L.data["List"] = "清單"
	L.data["None"] = "無"
	L.data["One Bag"] = "合併背包"
	L.data["Opacity"] = "不透明度"
	L.data["Quality, then Alphabetical"] = "先品質、再名稱"
	L.data["Scale"] = "縮放大小"
	L.data["Sections"] = "區塊"
	L.data["Section Categories"] = "分類方式"
	L.data["Section Grid"] = "分類區塊"
	L.data["Sections will be sorted alphabetically from left to right."] = "依照區塊名稱的第一個字，從左到右排序。"
	L.data["Sections will be sorted by size from large to small."] = "依照區塊的大小，從大到小排序。"
	L.data["Sections will be sorted by size from small to large."] = "依照區塊的大小，從小到大排序。"
	L.data["Show"] = "顯示"
	L.data["Show Bag Button"] = "顯示背包按鈕"
	L.data["Show Bags"] = "顯示背包欄位"
	L.data["Simple"] = "簡單"
	L.data["Size"] = "大小"
	L.data["Size Ascending"] = "大小遞增"
	L.data["Size Ascending (small to large)"] = "大小遞增 (小到大)"
	L.data["Size Descending"] = "大小遞減"
	L.data["Size Descending (large to small)"] = "大小遞減 (大到小)"
	L.data["Sorting"] = "排序"
	L.data["This view will display all items in a single bag, regardless of category."] = "將所有物品放在單一背包中，不分類。"
	L.data["This view will display items in sections, which are categorized by type, expansion, trade skill, and more."] = "將物品顯示成分類的區塊，依據類型、資料片、交易技能或更多。"
	L.data["This view will display items in a list, which is categorized by type, expansion, trade skill, and more."] = "將物品顯示成分類的清單列表，依據類型、資料片、交易技能或更多。"
	L.data["Trade Skill"] = "交易技能"
	L.data["Trade Skill (Reagents Only)"] = "交易技能 (僅限材料)"
	L.data["Type"] = "物品類型"
	L.data["View"] = "檢視"
	
	-- constants.lua
	L.data["Engineering"] = "工程學"
	L.data["Tailoring"] = "裁縫"
	L.data["Leatherworking"] = "製皮"
	L.data["Mining"] = "採礦"
	L.data["Herbalism"] = "草藥學"
	
	-- item.lua
	L.data["Gear: "] = "裝備: "
	L.data["Everything"] = "全部"
	L.data["Junk"] = "垃圾"
	L.data["Unknown"] = "未知"

	-- section.lua
	L.data["Item Count: "] = "物品數: " 
	
	-- masque.lua
	L.data["BetterBags"] = "掰特包"
	
	-- BetterBags-Teleports
	L.data["Teleporters"] = "傳送"
	
	-- BetterBags-Appearances
	L.data["Known - BoE"] = "裝備綁定 (已收集外觀) "
	L.data["Known - BoP"] = "靈魂綁定 (已收集外觀) "
	L.data["Unknown - "] = "外觀 (未收集) "
	L.data["Unknown - Other Classes"] = "外觀 (未收集) "
	
	-- BetterBags-Bound
	L.data["BoA"] = "帳號綁定"
	L.data["BoE"] = "裝備綁定"
	
	-- BetterBags-Keystones
	L.data["|cff7997dbKeystone|r"] = "|cff7997db鑰石|r"
	
	-- BetterBags_Dragonflight
	L.data["|cff16B7FFPrimal Storms|r"] = "|cff16B7FF原初風暴|r"
	L.data["|cffB5D3E7Storm's Fury|r"] = "|cffB5D3E7風暴之怒|r"
	L.data["|cff88AAFFZskera Vault|r"] = "|cff88AAFF澤斯克拉密庫|r"
	L.data["|cffFFAB00Primordial Stones|r"] = "|cffFFAB00原初之石|r"
	L.data["|cff88AAFFArtisan Curios|r"] = "|cff88AAFF工匠珍品|r"
	L.data["Diamanthia Journal"] = "艾達曼希亞日誌"
	L.data["|cff0070ddProfession Knowledge|r"] = "|cff0070dd專業知識|r"
	L.data["|cff56BBFFDrakewatcher Manuscript|r"] = "|cff56BBFF飛龍觀察者手稿|r"
	L.data["|cffa335eeLizi's Reins|r"] = "|cffa335ee莉茲的韁繩|r"
	L.data["|cffa335eeTemperamental Skyclaw|r"] = "|cffa335ee暴躁的天爪|r"
	L.data["|cffa335eeMagmashell|r"] = "|cffa335ee熔殼蝸牛|r"
	L.data["|cffa335eeLoyal Magmammoth|r"] = "|cffa335ee忠誠的熔岩猛瑪象|r"
	L.data["|cffa335eeMossy Mammoth|r"] = "|cffa335ee青苔猛瑪象|r"
	L.data["|cffa335eeGooey Snailemental|r"] = "|cffa335ee黏稠元素蝸牛|r"
	L.data["|cff0070ddChip|r"] = "|cff0070dd小鑿|r"
	L.data["|cff0070ddPhoenix Wishwing|r"] = "|cff0070dd鳳凰希翼|r"
	L.data["|cffff8040Reputation|r"] = "|cffff8040聲望|r"
	L.data["|cffAFB42BContracts|r"] = "|cffAFB42B合約|r"
	L.data["Treasure Sacks"] = "寶藏袋"
	L.data["Darkmoon Cards"] = "暗月卡"
	L.data["Fortune Cards"] = "命運卡片"
	L.data["|cffff8040Loamm|r"] = "|cffff8040洛姆|r"
	L.data["|cffff8040Crests|r"] = "|cffff8040紋章|r"
	L.data["|cff910951Fyrakk Assault|r"] = "|cff910951菲拉卡襲擊|r"
	L.data["|cffEDE4D3Time Rift|r"] = "|cffEDE4D3時間裂隙|r"
	L.data["|cff67CF9EDreamsurge|r"] = "|cff67CF9E夢境湧現|r"
	L.data["|cff67CF9ESuperbloom|r"] = "|cff67CF9E繁盛綻放|r"
	
	
end

-- G returns the localized string for the given key.
-- If no localized string is found, the key is returned.
---@param key string
---@return string
function L:G(key)
  return self.data[key] or key
end

-- S sets the localized string for the given key.
---@param key string
---@param value string
---@return nil
function L:S(key, value)
  self.data[key] = value
end

L:Enable()