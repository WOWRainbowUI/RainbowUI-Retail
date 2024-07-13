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
	-- bagbutton.lua
	L.data["Empty Bag Slot"] = "空的背包格子"
	
	-- bagslots.lua
	L.data["Equipped Bags"] = "已裝備的背包"
	
	-- frames\contextmenu.lua
	L.data["View"] = "檢視"
	L.data["One Bag"] = "合併背包"
	L.data["This view will display all items in a single bag, regardless of category."] = "將所有物品放在單一背包中，不分類。"
	L.data["Section Grid"] = "分類區塊"
	L.data["This view will display items in sections, which are categorized by type, expansion, trade skill, and more."] = "將物品顯示成分類的區塊，依據類型、資料片、交易技能或更多。"
	L.data["List"] = "清單"
	L.data["This view will display items in a list, which is categorized by type, expansion, trade skill, and more."] = "將物品顯示成分類的清單列表，依據類型、資料片、交易技能或更多。"
	L.data["Deposit All Reagents"] = "存放所有材料"
	L.data["Click to deposit all reagents into your reagent bank."] = "點一下將所有材料存放到材料銀行。"
	L.data["Show Bags"] = "顯示背包欄位"
	L.data["Click to toggle the display of the bag slots."] = "點一下切換顯示裝備背包的欄位，方便更換背包。"
	L.data["Cannot toggle bag slots in combat."] = "戰鬥中無法顯示裝備背包的欄位。"
	L.data["Show Currencies"] = "顯示兌換通貨"
	L.data["Click to toggle the display of the currencies side panel."] = "點一下切換顯示兌換通貨的面板。"
	L.data["Themes"] = "背包外觀主題"
	L.data["Click to toggle the display of the theme configuration side panel."] = "點一下切換顯示背包外觀主題的設定面板。"
	L.data["Configure Categories"] = "設定分類"
	L.data["Click to toggle the display of the category configuration side panel."] = "點一下切換顯示分類的設定面板。"
	L.data["Show Bag Button"] = "顯示背包按鈕"
	L.data["Click to toggle the display of the Blizzard bag button."] = "點一下切換顯示遊戲內建的背包按鈕。"
	L.data["Open Options Screen"] = "打開選項"
	L.data["Click to open the options screen."] = "點一下打開設定選項視窗。"
	L.data["Close Menu"] = "關閉選單"	
	
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
	L.data["Free Slots"] = "空格"

	-- section.lua
	L.data["Item Count: "] = "物品數: " 
	L.data["Drop "] = "將 " 
	L.data[" here to add it to "] = " 拖放到這裡以加入" 
	L.data["."] = "。" 
	L.data["Hold shift to add "] = "按住 Shift 將 " 
	L.data[" to "] = " 加入" 
	
	-- masque.lua
	L.data["BetterBags"] = "掰特包"
	
	-- config\bags.lua
	L.data["Custom Categories"] = "自訂分類"
	L.data["No custom categories have been created yet."] = "尚未建立自訂分類。"
	L.data["Select which custom categories to show in this bag. If an option is checked, items that belong to the checked category will be put into a section for that category."] = "選擇要在背包中顯示的自訂分類。勾選後，屬於該分類的物品將會放入該分類的區塊中。"
	L.data["Categories"] = "分類"
	L.data["Subtype"] = "物品子類型"
	L.data["Expansion"] = "資料片"
	L.data["Trade Skill"] = "交易技能"
	L.data["Gear Set"] = "裝備管理員套裝"
	L.data["Equipment Location"] = "裝備部位"
	L.data["Select which categories to show in this bag. If an option is checked, items that belong to the checked category will be put into a section for that category."] = "選擇要在背包中顯示的分類。勾選後，屬於該分類的物品將會放入該分類的區塊中。"
	L.data["Recent Items"] = "新物品"
	L.data["Type"] = "物品類型"
	L.data["Item Compaction"] = "精簡版面"
	L.data["If Simple is selected, item sections will be sorted from left to right, however if a section can fit in the same row as the section above it, the section will move up."] = "選擇 \"簡單\" 時，物品區塊會從左到右排序，如果某個區塊可以與上方的區塊放在同一列，該區塊會移至上方。"
	L.data["None"] = "無"
	L.data["Simple"] = "簡單"
	L.data["Section Sorting"] = "區塊排序"
	L.data["Select how sections should be sorted."] = "選擇區塊該如何排列順序。"
	L.data["Alphabetically"] = "名稱"
	L.data["Size Descending"] = "大小遞減"
	L.data["Size Ascending"] = "大小遞增"
	L.data["Item Sorting"] = "物品排序"
	L.data["Select how items should be sorted."] = "選擇物品該如何排列順序。"
	L.data["Quality, then Alphabetically"] = "先品質、再名稱"
	L.data["Alphabetically, then Quality"] = "先名稱、再品質"
	L.data["New Items"] = "新物品"
	L.data["Incoming items are recent"] = "剛進背包都是新的"
	L.data["If enabled, all new items added to the bag will be marked as recent, i.e. bank -> backpack."] = "啟用時，所有新加入到背包中的物品都會標記為新的，例如從銀行 -> 背包。"
	L.data["Flash new items in stacks"] = "閃爍新物品的堆疊"
	L.data["If enabled, stacks that receive new items will flash to indicate the addition of a new item."] = "啟用時，接收新物品的堆疊會閃爍，表示加入了新的物品。"
	L.data["Stacking"] = "物品堆疊"
	L.data["Merge Stacks"] = "合併堆疊"
	L.data["Merge stacks of the same item into a single stack."] = "將相同物品的堆疊合併成單一個堆疊。"
	L.data["Merge stacks of the same item into a single stack, i.e. 20x [Linen Cloth] + 20x [Linen Cloth] = 40x [Linen Cloth] in one stack."] = "將相同物品的堆疊合併成單一個堆疊。例如 20x [亞麻布] + 20x [亞麻布] = 一疊 40x [亞麻布]。"
	L.data["Merge Unstackable"] = "物品無法堆疊"
	L.data["Merge unstackable items of the same kind into a single stack, such as armors, bags, etc."] = "將無法堆疊的同類物品的合併成單一個堆疊，例如護甲、背包...等。"
	L.data["Unmerge at Shop"] = "商店時取消堆疊"
	L.data["Unmerge all items when visiting a vendor."] = "拜訪商人時不要堆疊所有物品。"
	L.data["Don't Merge Partial"] = "不合併未滿的"
	L.data["Don't merge stacks of items that aren't full stacks."] = "不要合併那些堆疊數量未滿的物品堆疊。"
	L.data["Don't Merge Transmog"] = "不合併外觀"
	L.data["Don't merge stacks of items that have different transmogs on them."] = "不要合併塑形外觀不同的物品堆疊。"
	L.data["Item Level"] = "物品等級"
	L.data["Enabled"] = "啟用"
	L.data["Show the item level of items in this bag."] = "顯示背包中物品的等級。"
	L.data["Color"] = "顏色"
	L.data["Color the item level text based on the item's quality."] = "依據物品品質來顯示物品等級文字的顏色。"
	L.data["Select which view to use for this bag."] = "選擇檢視背包的方式。"
	L.data["Display"] = "顯示"
	L.data["Show Full Section Names"] = "顯示完整的分類名稱"
	L.data["Show the full section in the bag window without truncating it with '...'"] = "在背包視窗中顯示完整的分類名稱，不要截斷加上 '...'。"
	L.data["Items Per Row"] = "每列物品數"
	L.data["Set the number of items per row in this bag."] = "設定每個橫列要顯示幾件物品。"
	L.data["Columns"] = "欄數"
	L.data["Set the number of columns sections will fit into."] = "設定各區塊適合的欄數。"
	L.data["Opacity"] = "不透明度"
	L.data["Set the opacity of this bag."] = "設定背包的不透明度。"
	L.data["Scale"] = "縮放大小"
	L.data["Set the scale of this bag."] = "設定背包的縮放大小。"
	
	-- config\config.lua
	L.data["General"] = "一般"
	L.data["Enable In-Bag Search"] = "啟用搜尋列"
	L.data["If enabled, a search bar will appear at the top of your bags."] = "啟用時，背包上方會顯示搜尋列。"
	L.data["Show Blizzard Bag Button"] = "顯示背包按鈕"
	L.data["Show or hide the default Blizzard bag button."] = "顯示畫面右下角，遊戲內建的背包按鈕。"
	L.data["New Item Duration"] = "新物品持續時間"
	L.data["The time, in minutes, to consider an item a new item."] = "新的物品要保留多久時間後自動歸類，以分鐘為單位。"
	L.data["Plugins"] = "外掛套件"
	L.data["Plugin configuration options can be accessed on the left by expanding the 'Plugins' menu option."] = "將左側的 '外掛套件' 選單展開，可以看到外掛套件的設定選項。"
	
	-- config\customcat.lua 
	L.data["Items"] = "物品"
	L.data["Delete Category"] = "刪除分類"
	L.data["Are you sure you want to delete this category?"] = "是否確定要刪除此分類?"
	L.data["Create Category"] = "建立分類"
	L.data["Custom categories allow you to create your own categories for items. Type the name of the category you want to create in the box below and press enter to create an empty category."] = "自訂分類允許你為物品建立自己的分類。在下方的框中輸入要建立的分類名稱，然後按 Enter 鍵建立一個空的分類。"
	L.data["Categories you create can be enabled and disabled just like the default categories in the configuration menu option for the bag (Backpack or Bank) on the left. Once you have created a category, you can configure it by selecting it on the menu on the left."] = "\n你所建立的分類像預設分類一樣可以啟用或停用。建立了分類之後，就可以從左側的選單來進行設定。"
	L.data["New Category Name"] = "新分類名稱"
	
	-- config\help.lua
	L.data["Help"] = "說明"
	L.data["Welcome to Better Bags! Please select a help item from the left menu for FAQ's and other information."] = "歡迎使用掰特包 Better Bags! 請將左側選單展開選擇說明項目，查看常見問題和其他資訊。"
	L.data["Why are some of my items not showing up in my custom categories?"] = "為什麼一些物品沒有顯示在我的自訂分類中?"
	L.data["Items can only be in one category at a time. If you have a category that is missing items, it is likely that the items in that category are already in another category."] = "物品一次只能屬於一個類別。如果某個分類缺少物品，很可能是該物品已經屬於其他分類了。"
	L.data["Why does a custom category reappear after I delete it?"] = "為什麼刪除自訂分類後它又重新出現?"
	L.data["If you delete a custom category that was created by another addon/plugin, it will reappear the next time you log in/reload. To permanently delete a custom category created by a plugin/another addon, you must disable the addon creating the category and then delete the category in the UI."] = "如果刪除的是由其他插件建立的自訂分類，下次登入/重新載入介面時它會重新出現。要永久刪除由其他插件建立的自訂分類，必須停用建立該分類的插件，然後在設定選項中刪除該分類。"
	L.data["How do I delete an item from a custom category?"] = "如何從自訂分類中刪除物品?"
	L.data["When viewing a custom category configuration, you can right click on an item to open it's menu and select 'delete' to delete it from the category."] = "在設定選項中查看自訂分類時，在要刪除的物品名稱上面點右鍵選擇 '移除'。"
	L.data["Search"] = "搜尋"
	L.data["How do I search for items?"] = "我該如何搜尋物品?"
	L.data[ [[
    You can bind a key to open the search bar in the World of Warcraft keybindings menu. You can also open the search bar by shift clicking on the bag button at the top of the bag frame.
    Once the search bar is open, you can type in the name of an item to search for it. You can also use the following search operators:
    - `type:` to search for items of a specific type (e.g. `type:weapon`)
    - `subtype:` to search for items of a specific subtype (e.g. `subtype:axe`)
    - `name:` to search for items with a specific name (e.g. `name:axe`)
    - `gear:` to search for items that are part of an equipment set (e.g. `gear:tank`)
    - `exp:` to search for items from a specific expansion (e.g. `exp:shadowlands`)
    
    For expansions, you can use the following expansions shortcuts (e.g. `exp:classic`):
    - `classic`
    - `tbc`
    - `wotlk`
    - `cata`
    - `mop`
    - `wod`
    - `legion`
    - `bfa`
    - `shadowlands`
    - `dragonflight`
  ]] ] = [[
    可以在遊戲選項的按鍵綁定中設定一個快速鍵來打開搜尋欄，也可以用 Shift+左鍵點擊背包視窗左上角的背包圖示來打開搜尋欄。
    搜索欄打開後，可以輸入物品名稱來進行搜尋。還可以使用下面的搜尋運算符：
    - `type:` 用來搜尋指定類型的物品 (例如 `type:武器`)
    - `subtype:` 用來搜尋指定子類型的物品 (例如 `subtype:斧`)
    - `name:` 用來搜尋指定名稱的物品 (例如 `name:斧`)
    - `gear:` 用來搜尋套裝設定中的物品 (例如 `gear:坦克`)
    - `exp:` 用來搜尋指定資料片的物品 (例如 `exp:暗影之境`)
    
    資料片可以使用下面的英文縮寫 (例如 `exp:classic`):
    - `classic`
    - `tbc`
    - `wotlk`
    - `cata`
    - `mop`
    - `wod`
    - `legion`
    - `bfa`
    - `shadowlands`
    - `dragonflight`
  ]]
	
	-- config\itemlist.lua
	L.data["Drag an item here from your inventory, bank, or another source to add it to this category."] = "將物品從背包、銀行或其他地方拖曳到這裡，便可加入此分類。"
	L.data["Drag an item here to add it to this category."] = "將物品拖曳到這裡以加入此分類。"
	L.data["Remove"] = "移除"
	
	-- core/constants.lua
	L.data["Bags"] = "背包"
	L.data["Quiver"] = "箭袋"
	L.data["Ammo Pouch"] = "彈藥袋"
	L.data["Soul Bag"] = "靈魂袋"
	L.data["Leatherworking Bag"] = "剝皮包"
	L.data["Inscription Bag"] = "銘文包"
	L.data["Herb Bag"] = "草藥包"
	L.data["Enchanting Bag"] = "附魔包"
	L.data["Engineering Bag"] = "工程包"
	L.data["Keyring"] = "鑰匙圈"
	L.data["Gem Bag"] = "寶石包"
	L.data["Mining Bag"] = "採礦包"

	-- frames\bags.lua
	L.data["Search Reagent Bank"] = "搜尋材料銀行"
	L.data["Reagent Bank"] = "材料銀行"
	L.data["Search Bank"] = "搜尋銀行"
	L.data["Bank"] = "銀行"
	L.data["Backpack"] = "背包"
	L.data["Create Category"] = "建立新分類"
	L.data["What would you like to name the new category for %s?"] = "請輸入 %s 的新分類名稱:"
	L.data["Left Click"] = "左鍵"
	L.data["Open Menu"] = "打開選單"
	L.data["Shift Left Click"] = "Shift+左鍵"
	L.data["Search Bags"] = "搜尋背包"
	L.data["Right Click"] = "右鍵"
	L.data["Sort Bags"] = "整理背包"
	L.data["Refresh Bags"] = "重新整理背包"
	L.data["Swap Between Bank/Reagent Bank"] = "切換銀行/材料銀行"
	L.data["Drop %s here to create a new category for it."] = "將 %s 拖放到這裡來建立新分類。"
	
	-- frames\bagbutton.lua
	L.data["Cannot change bags in combat."] = "戰鬥中無法更換背包。"
	
	-- frames\currency.lua
	L.data["Click to add or remove this currency to and from your backpack."] = "點一下將此貨幣加入背包或從背包中移除。"
	L.data["Currencies"] = "兌換通貨"
	
	-- frames\search.lua
	L.data["Start typing to search your bags..."] = "輸入文字來搜尋背包中的物品..."
	L.data["Search Backpack"] = "搜尋背包"
	
	-- frames\sectionconfig.lua
	L.data["Pinned"] = "置頂"
	L.data["Automatically Sorted"] = "自動排序"
	L.data["Open the sidebar for configuring items in this category."] = "打開面板以便設定此分類中的物品。"
	L.data[ [[
        Left click to enable or disable items from being added to this category.
        Drag this category to Pinned to keep it at the top of your bags, or to Automatically Sorted to have it sorted with the rest of your items.]] ] = [[
        左鍵點擊啟用或停用將物品加入此分類。
        將分類拖曳到置頂，保持在背包的最前面，
        或拖曳到自動排序與其他分類一起排序。]]
	L.data["Left Click"] = "左鍵"
	L.data["Enable or Disable Category"] = "啟用或停用分類"
	L.data["Shift Left Click"] = "Shift+左鍵"
	L.data["Move %s to the top of your bags"] = "將 %s 移動到背包的最前面"
	L.data["Right Click"] = "右鍵"
	L.data["Shift Right Click"] = "Shift+右鍵"
	L.data["Hide or Show Category"] = "隱藏或顯示分類"
	L.data["Show or hide this category in the bags."] = "在背包中顯示或隱藏此分類"
	L.data["Hide Category"] = "隱藏分類"
	L.data["(hidden)"] = "(已隱藏)"
	-- L.data["Open Menu"] = "打開選單" -- 前面已有
	L.data[ [[
          Dynamic categories can't be enabled or disabled (yet).
          Drag this category to Pinned to keep it at the top of your bags, or to Automatically Sorted to have it sorted with the rest of your items.]] ] = [[
          (還不能) 啟用或停用動態分類。
        將分類拖曳到置頂，保持在背包的最前面，
        或拖曳到自動排序與其他分類一起排序。]]
	L.data["Are you sure you want to delete the category %s?"] = "是否確定要刪除分類 %s?"
	
	-- frames\themeconfig.lua
	L.data["Theme Configuration"] = "選擇背包外觀主題"
	
	-- themes\default.lua
	L.data["Default"] = "預設"

	-- themes\simpledark.lua
	L.data["Simple Dark"] = "就是黑"
	
	-- util\sort.lua
	L.data["Free Space"] = "空格"
	
	-- BetterBags-Teleports
	L.data["Teleporters"] = "傳送"
	
	-- BetterBags-Appearances
	L.data["Appearances"] = "外觀"
	L.data["Item Splitting Options"] = "物品子分類選項"
	L.data["Split by Item Type"] = "依物品類型拆開"
	L.data["This will split tradable items into categories based on their type."] = "依據物品類型，將可交易的物品分別放置到不同的子分類中。"
	L.data["Split by Item Location"] = "依物品部位拆開"
	L.data["This will split tradable items into categories based on their equip slot."] = "依據物品裝備的部位，將可交易的物品分別放置到不同的子分類中。"
	L.data["Mog - Learnable"] = "外觀 (可學習)"
	L.data["Mog - Tradable"] = "外觀 (可交易)"
	L.data["Mog - Tradable - "] = "外觀 (可交易): "
	L.data["Mog - Sellable"] = "外觀 (可賣出)"
	
		--Old
		L.data["Known - BoE"] = "裝備綁定 (已收集外觀) "
		L.data["Known - BoP"] = "靈魂綁定 (已收集外觀) "
		L.data[" Usable"] = "無法使用"
		L.data["Unknown - "] = "外觀 (未收集): "
		L.data["Unknown - Other Classes"] = "外觀 (未收集) "
		L.data["Other Classes"] = "其他職業"
	
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
	L.data["|cffa335eeAwakened|r"] = "|cff67CF9E覺醒|r"
	L.data["|cfff49813Bronze|r"] = "|cff67CF9E青銅|r"	
	
	-- BetterBags_GearFirst
	L.data["Gear > Alphabetically"] = "裝備 > 名稱"
	L.data["Hearthstone > Gear > Alphabetically"] = "爐石 > 裝備 > 名稱"
	
	-- Betterbags-openable
	L.data["Openable"] = "打開"
	
	-- BetterBags_BetterSort
	L.data["Sort by Item Level"] = "依物品等級排序"
	L.data["Sort Items by Item Level."] = "依照物品等級來排列物品。"
	L.data["Ignore New Item Tag"] = "忽略新物品標籤"
	L.data["If enbaled, Blizzard \"New Item Tag\" will be ignored. This makes new items strictly rely on \"New Item Duration\" setting."] = "啟用時，會忽略遊戲內建的 \"新物品標籤\"，這會讓新物品完全遵照 \"新物品持續時間\" 的設定。"	
	
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