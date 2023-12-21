--[[
AdiBags - Adirelle's bag addon.
Copyright 2010-2021 Adirelle (adirelle@gmail.com)
All rights reserved.

This file is part of AdiBags.

AdiBags is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

AdiBags is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with AdiBags.  If not, see <http://www.gnu.org/licenses/>.
--]]

local addonName = ...
---@class AdiBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

--<GLOBALS
local _G = _G
local GetLocale = _G.GetLocale
local pairs = _G.pairs
local rawset = _G.rawset
local setmetatable = _G.setmetatable
local tostring = _G.tostring
--GLOBALS>

local L = setmetatable({}, {
	__index = function(self, key)
		if key ~= nil then
			--[===[@debug@
			addon:Debug('Missing locale', tostring(key))
			--@end-debug@]===]
			rawset(self, key, tostring(key))
		end
		return tostring(key)
	end,
})
addon.L = L

L["QUIVER_TAG"] = "Qu"
L["AMMO_TAG"] = "Am"
L["SOUL_BAG_TAG"] = "So"
L["LEATHERWORKING_BAG_TAG"] = "Le"
L["INSCRIPTION_BAG_TAG"] = "In"
L["HERB_BAG_TAG"] = "He"
L["ENCHANTING_BAG_TAG"] = "En"
L["ENGINEERING_BAG_TAG"] = "Eg"
L["KEYRING_TAG"] = "Ke"
L["GEM_BAG_TAG"] = "Ge"
L["MINING_BAG_TAG"] = "Mi"
L["REAGENT_BAG_TAG"] = "Re"
L["TACKLE_BOX_TAG"] = "Fi"
L["COOKING_BAR_TAG"] = "Co"

--------------------------------------------------------------------------------
-- Locales from localization system
--------------------------------------------------------------------------------

-- %Localization: adibags
-- THE END OF THE FILE IS UPDATED BY https://github.com/Adirelle/wowaceTools/#updatelocalizationphp.
-- ANY CHANGE BELOW THESES LINES WILL BE LOST.
-- UPDATE THE TRANSLATIONS AT http://www.wowace.com/addons/adibags/localization/
-- AND ASK THE AUTHOR TO UPDATE THIS FILE.

-- @noloc[[

------------------------ enUS ------------------------


-- config/Config-ItemList.lua
L["Click or drag this item to remove it."] = true
L["Drop an item there to add it to the list."] = true

-- config/Options.lua
L["... including incomplete stacks"] = true
L["Adjust the maximum height of the bags, relative to screen size."] = true
L["Adjust the width of the bag columns."] = true
L["Anchored"] = true
L["At mechants', bank, auction house, ..."] = true
L["Automatically open the bags at merchant's, bank, ..."] = true
L["Backpack color"] = true
L["Backpack"] = true
L["Bag background"] = true
L["Bag title"] = true
L["Bag type"] = true
L["Bags"] = true
L["Bank color"] = true
L["Bank"] = true
L["Border width"] = true
L["Border"] = true
L["By category, subcategory, quality and item level (default)"] = true
L["By name"] = true
L["By quality and item level"] = true
L["Change stacking at merchants', auction house, bank, mailboxes or when trading."] = true
L["Check this to display a bag type tag in the top left corner of items."] = true
L["Check this to display a colored border around items, based on item quality."] = true
L["Check this to display an indicator on quest items."] = true
L["Check this to have poor quality items dimmed."] = true
L["Check to enable this module."] = true
L["Click there to reset the bag positions and sizes."] = true
L["Click to toggle the bag anchor."] = true
L["Column width"] = true
L["Configure"] = true
L["Dim junk"] = true
L["Do not show anchor point"] = true
L["Enabled bags"] = true
L["Enabled"] = true
L["Filters are used to dispatch items in bag sections. One item can only appear in one section. If the same item is selected by several filters, the one with the highest priority wins."] = true
L["Filters"] = true
L["Hide the colored corner shown when you move the bag."] = true
L["Insets"] = true
L["Items"] = true
L["Keep all stacks together."] = true
L["Lock anchor"] = true
L["Manual"] = true
L["Maximum bag height"] = true
L["Merge free space"] = true
L["Merge incomplete stacks with complete ones."] = true
L["Merge stackable items"] = true
L["Merge unstackable items"] = true
L["Opacity"] = true
L["Open automatically"] = true
L["Plugins"] = true
L["Position mode"] = true
L["Priority"] = true
L["Quality highlight"] = true
L["Quest indicator"] = true
L["Reset position"] = true
L["Right-click to open options"] = true
L["Scale"] = true
L["Section header"] = true
L["Select how items should be sorted within each section."] = true
L["Select how the bags are positionned."] = true
L["Select which bags AdiBags should display."] = true
L["Separate incomplete stacks."] = true
L["Separate unstackable items."] = true
L["Show every distinct item stacks."] = true
L["Show only one free slot for each kind of bags."] = true
L["Show only one slot of items that can be stacked."] = true
L["Show only one slot of items that cannot be stacked."] = true
L["Skin"] = true
L["Sorting order"] = true
L["Texture"] = true
L["Toggle and configure item filters."] = true
L["Toggle and configure plugins."] = true
L["Uncheck this to disable AdiBags."] = true
L["Unlock anchor"] = true
L["Use this to adjust the bag scale."] = true
L["Use this to adjust the quality-based border opacity. 100% means fully opaque."] = true
L["Virtual stacks display in one place items that actually spread over several bag slots."] = true
L["Virtual stacks"] = true
L["When checked, right-clicking on an empty space of a bag opens the configuration panel."] = true

-- core/Constants.lua
L["Engineering"] = true
L["Tailoring"] = true
L["Leatherworking"] = true
L["Mining"] = true
L["Herbalism"] = true

-- core/Core.lua
L["Warning: You are using an alpha or beta version of AdiBags without displaying Lua errors. If anything goes wrong, AdiBags (or any other addon causing some error) will simply stop working for apparently no reason. Please either enable the display of Lua errors or install an error handler addon like BugSack or Swatter."] = true

-- core/DefaultFilters.lua
L["Ammunition"] = true
L["Check sets that should be merged into a unique \"Sets\" section. This is obviously a per-character setting."] = true
L["Check this so armors are dispatched in four sections by type."] = true
L["Check this to display one individual section per set. If this is disabled, there will be one big \"Sets\" section."] = true
L["Consider gems as a subcategory of trade goods"] = true
L["Consider glyphs as a subcategory of trade goods"] = true
L["Equipment"] = true
L["Four general sections."] = true
L["Gear manager item sets"] = true
L["Gems are trade goods"] = true
L["Glyphs are trade goods"] = true
L["Item category"] = true
L["Jewelry"] = true
L["Merged sets"] = true
L["One section per item slot."] = true
L["One section per set"] = true
L["Only one section."] = true
L["Please note this filter matchs every item. Any filter with lower priority than this one will have no effect."] = true
L["Put any item that can be equipped (including bags) into the \"Equipment\" section."] = true
L["Put items belonging to one or more sets of the built-in gear manager in specific sections."] = true
L["Put items in sections depending on their first-level category at the Auction House."] = true
L["Put quest-related items in their own section."] = true
L["Quest Items"] = true
L["Section setup"] = true
L["Select the sections in which the items should be dispatched."] = true
L["Select which first-level categories should be split by sub-categories."] = true
L["Set: %s"] = true
L["Sets"] = true
L["Split armors by types"] = true
L["Split by subcategories"] = true

-- core/Fonts.lua
L["Color"] = true
L["Font"] = true
L["Reset"] = true
L["Size"] = true
L["Text"] = true

-- core/Layout.lua
L["AdiBags Anchor"] = true

-- modules/BankSwitcher.lua
L["Bank Switcher"] = true
L["Move items from and to the bank by right-clicking on section headers."] = true
L["Right-click to move these items."] = true

-- modules/BindTypeFilter.lua
L["Bind type"] = true
L["Sort items by bind type."] = true

-- modules/ChangeHighlight.lua
L["Highlight changes"] = true
L["Highlight what changes in bags with a little sparkle."] = true

-- modules/CurrencyFrame.lua
L["Currencies to show"] = true
L["Currency"] = true
L["Display character currency at bottom left of the backpack."] = true
L["Hide zeroes"] = true
L["Ignore currencies with null amounts."] = true
L["Right-click to configure."] = true

-- modules/DataSource.lua
L["Bag usage format"] = true
L["Check this to display an icon after usage of each type of bags."] = true
L["Check this to display an textual tag before usage of each type of bags."] = true
L["Check this to display only one value counting all equipped bags, ignoring their type."] = true
L["Check this to show space at your bank in the plugin."] = true
L["Free space / total space"] = true
L["Free space"] = true
L["LDB Plugin"] = true
L["Merge bag types"] = true
L["Provides a LDB data source to be displayed by LDB display addons."] = true
L["Select how bag usage should be formatted in the plugin."] = true
L["Show bag type icons"] = true
L["Show bag type tags"] = true
L["Show bank usage"] = true
L["Space in use / total space"] = true
L["Space in use"] = true

-- modules/FilterOverride.lua
L["Add association"] = true
L["Allow you manually redefine the section in which an item should be put. Simply drag an item on the section title."] = true
L["Alt-right-click to configure manual filtering."] = true
L["Are you sure you want to remove this section ?"] = true
L["Assign %s to ..."] = true
L["Category"] = true
L["Click on a item to remove it from the list. You can drop an item on the empty slot to add it to the list."] = true
L["Click on this button to create the new association."] = true
L["Drop your item there to add it to this section."] = true
L["Enter the name of the section to associate with the item."] = true
L["Enter the name, link or itemid of the item to associate with the section. You can also drop an item into this box."] = true
L["Item"] = true
L["Manual filtering"] = true
L["New Override"] = true
L["New section"] = true
L["Press Alt while doing so to open a dropdown menu."] = true
L["Remove"] = true
L["Section category"] = true
L["Section"] = true
L["Select the category of the section to associate. This is used to group sections together."] = true
L["Use this section to define any item-section association."] = true

-- modules/ItemLevel.lua
L["Color scheme"] = true
L["Display the level of equippable item in the top left corner of the button."] = true
L["Do not show level of heirloom items."] = true
L["Do not show level of items that cannot be equipped."] = true
L["Do not show level of poor quality items."] = true
L["Do not show levels under this threshold."] = true
L["Ignore heirloom items"] = true
L["Ignore low quality items"] = true
L["Item level"] = true
L["Let SyLevel handle the the display."] = true
L["Mininum level"] = true
L["None"] = true
L["Only equippable items"] = true
L["Related to player level"] = true
L["Same as InventoryItemLevels"] = true
L["Use SyLevel"] = true
L["Which color scheme should be used to display the item level ?"] = true

-- modules/Junk.lua
L["Alt-right-click to configure the Junk module."] = true
L["Exclude list"] = true
L["Include list"] = true
L["Included categories"] = true
L["Items in this list are always considered as junk. Click an item to remove it from the list."] = true
L["Items in this list are never considered as junk. Click an item to remove it from the list."] = true
L["Junk category"] = true
L["Low quality items"] = true
L["Nothing to sell."] = true
L["Put items of poor quality or labeled as junk in the \"Junk\" section."] = true
L["Right-click to sell these items."] = true

-- modules/MoneyFrame.lua
L["Display a smaller money frame. This setting will take effect on next reload."] = true
L["Display character money at bottom right of the backpack."] = true
L["Money"] = true
L["Small"] = true

-- modules/NewItemTracking.lua
L["6.0"] = true
L["Click to reset item status."] = true
L["Highlight color"] = true
L["Highlight scale"] = true
L["Highlight style"] = true
L["Legacy"] = true
L["New"] = true
L["Recent Items"] = true
L["Reset new items"] = true
L["Track new items in each bag, displaying a glowing aura over them and putting them in a special section. \"New\" status can be reset by clicking on the small \"N\" button at top left of bags."] = true
L["Track new items"] = true

-- modules/SectionVisibilityDropdown.lua
L["Add a dropdown menu to bags that allow to hide the sections."] = true
L["Check this to show this section. Uncheck to hide it."] = true
L["Click to select which sections should be shown or hidden. Section visibility is common to all bags."] = true
L["Section visibility button"] = true
L["Section visibility"] = true
L["Show %s"] = true

-- modules/TooltipInfo.lua
L["AH category"] = true
L["AH subcategory"] = true
L["Add more information in tooltips related to items in your bags."] = true
L["Always"] = true
L["Bag number"] = true
L["Container information"] = true
L["Filter"] = true
L["Filtering information"] = true
L["Item information"] = true
L["Maximum stack size"] = true
L["Never"] = true
L["Show container information..."] = true
L["Show filtering information..."] = true
L["Show item information..."] = true
L["Slot number"] = true
L["Tooltip information"] = true
L["Virtual stack slots"] = true
L["When alt is held down"] = true
L["When any modifier key is held down"] = true
L["When ctrl is held down"] = true
L["When shift is held down"] = true

-- widgets/AnchorWidget.lua
L["Alt-right-click to switch to anchored placement."] = true
L["Alt-right-click to switch to manual placement."] = true
L["Drag to move this bag."] = true
L["Right-click to (un)lock the bag anchor."] = true

-- widgets/BagSlots.lua
L["Click to purchase"] = true
L["Equipped bags"] = true
L["Right-click to try to empty this bag."] = true

-- widgets/ContainerFrame.lua
L["%s is: %s."] = true
L["Auto-sort can cause freeze when the bag is closed."] = true
L["Bag #%d"] = true
L["Bank bag #%d"] = true
L["Click to swap between %s and %s."] = true
L["Click to toggle the equipped bag panel, so you can change them."] = true
L["Close"] = true
L["Right-click to toggle %s."] = true
L["You can block auto-deposit ponctually by pressing a modified key while talking to the banker."] = true
L["auto-deposit"] = true
L["auto-sort"] = true
L["disabled"] = true
L["enabled"] = true

-- 自行加入
L['Experiments'] = true
L['View your experiment groups and toggle participation.'] = true
L["Bag Lag Fix"] = true
L["This experiment will fix the lag when opening bags via per-item change draws instead of full redraws."] = true

------------------------ zhTW ------------------------
local locale = GetLocale()
if locale == 'zhTW' then
L["%s is: %s."] = "%s已%s。"
L["... including incomplete stacks"] = "... 包括不完整的堆疊"
L["6.0"] = "6.0"
L["Add a dropdown menu to bags that allow to hide the sections."] = "增加下拉式選單來隱藏類別"
L["Add association"] = "新增關聯"
L["Add more information in tooltips related to items in your bags."] = "顯示物品的額外資訊提示"
L["AdiBags Anchor"] = "AdiBags 對齊點"
L["Adjust the maximum height of the bags, relative to screen size."] = "調整背包最大高度，相對於螢幕尺寸"
L["Adjust the width of the bag columns."] = "調整背包的欄寬。"
L["AH category"] = "拍賣場類別"
L["AH subcategory"] = "拍賣場子類別"
L["Allow you manually redefine the section in which an item should be put. Simply drag an item on the section title."] = "允許以手動方式，將物品拖曳到區塊標題來分類物品。"
L["Alt-right-click to configure manual filtering."] = "Alt+右鍵來設定手動分類。"
L["Alt-right-click to configure the Junk module."] = "Alt+右鍵來設定垃圾模組。"
L["Alt-right-click to switch to anchored placement."] = "Alt+右鍵切換到對齊點位置。"
L["Alt-right-click to switch to manual placement."] = "Alt+右鍵切換到手動調整位置。"
L["Always"] = "總是"
L["AMMO_TAG"] = "Am"
L["Ammunition"] = "彈藥"
L["Anchored"] = "對齊點"
L["Are you sure you want to remove this section ?"] = "你確定要刪除本分類嗎？"
L["Assign %s to ..."] = "指定 %s 為 ..."
L["At merchants', bank, auction house, ..."] = "在商店、銀行、拍賣場等"
L["auto-deposit"] = "自動存放"
L["Automatically open the bags at merchant's, bank, ..."] = "與商人或銀行員等對話時，自動開啟背包。"
L["auto-sort"] = "自動排序"
L["Auto-sort can cause freeze when the bag is closed."] = "若當背包運行自動排序時突然被關閉，可能會導致所有背包介面凍結。"
L["Backpack"] = "背包"
L["Backpack color"] = "背包顏色"
L["Bag #%d"] = "背包 #%d"
L["Bag background"] = "背包背景"
L["Bag number"] = "背包數量"
L["Bag title"] = "背包標題"
L["Bag type"] = "背包類型"
L["Bag usage format"] = "背包運用格式"
L["Bags"] = "背包"
L["Bank"] = "銀行"
L["Bank bag #%d"] = "銀行背包 #%d"
L["Bank color"] = "銀行顏色"
L["Bank Switcher"] = "銀行切換"
L["Bind type"] = "綁定類型"
L["Border"] = "邊框"
L["Border width"] = "邊框寬度"
L["By category, subcategory, quality and item level (default)"] = "按類別, 子類別, 品質和物品等級(預設)"
L["By name"] = "按物品名稱"
L["By quality and item level"] = "按品質和物品等級"
L["Category"] = "種類"
L["Change stacking at merchants', auction house, bank, mailboxes or when trading."] = "商人，拍賣行，銀行，郵箱或交易時更改堆疊。"
L["Check sets that should be merged into a unique \"Sets\" section. This is obviously a per-character setting."] = "勾選裝備設定將其合併成一個「套裝」類別。此項設定顯然為角色獨用。"
L["Check this so armors are dispatched in four sections by type."] = "護甲將按四大類型分組（布甲/皮甲/鎖甲/鎧甲）。"
L["Check this to display a bag type tag in the top left corner of items."] = "在物品左上角顯示背包標籤"
L["Check this to display a colored border around items, based on item quality."] = "依物品品質著色邊框"
L["Check this to display an icon after usage of each type of bags."] = "在每個背包運用類型後顯示圖示。"
L["Check this to display an indicator on quest items."] = "在任務物品上顯示指示。"
L["Check this to display an textual tag before usage of each type of bags."] = "在每個背包運用類型前顯示文字標記。"
L["Check this to display one individual section per set. If this is disabled, there will be one big \"Sets\" section."] = "依各個套裝獨立分組。若停用此選項，將會合併成一個大「套裝」分組。"
L["Check this to display only one value counting all equipped bags, ignoring their type."] = "讓所有裝備背包顯示一個值，忽略其類型。"
L["Check this to have poor quality items dimmed."] = "黯淡品質為粗糙的物品"
L["Check this to show space at your bank in the plugin."] = "在銀行中顯示背包空間。"
L["Check this to show this section. Uncheck to hide it."] = "設定要顯示的類別"
L["Check to disable error reporting."] = "勾選以停用錯誤報告。"
L["Check to enable this module."] = "檢查以啟用模組。"
L["Click on a item to remove it from the list. You can drop an item on the empty slot to add it to the list."] = "點擊一個項目從列表中刪除它。也可拖放物品至空格以添加至列表。"
L["Click on this button to create the new association."] = "建立新的關聯"
L["Click or drag this item to remove it."] = "點擊或拖曳物品以移除。"
L["Click there to reset the bag positions and sizes."] = "點擊重置背包位置和尺寸。"
L["Click to purchase"] = "點擊購買"
L["Click to reset item status."] = "點一下重置物品狀態。"
L["Click to select which sections should be shown or hidden. Section visibility is common to all bags."] = "設定要顯示或隱藏的類別"
L["Click to swap between %s and %s."] = "點一下切換成 %s 或 %s。"
L["Click to toggle the bag anchor."] = "點一下開啟或關閉背包對齊。"
L["Click to toggle the equipped bag panel, so you can change them."] = "點一下開啟或關閉已裝備的背包面板, 可以更換背包。"
L["Close"] = "關閉"
L["Color"] = "顏色"
L["Color scheme"] = "顏色設定"
L["Column width"] = "欄寬"
L["Configure"] = "設定選項"
L["Consider gems as a subcategory of trade goods"] = "將寶石設定為商品的子類別"
L["Consider glyphs as a subcategory of trade goods"] = "將雕紋設定為商品的子類別"
L["Container information"] = "容器資訊"
L["COOKING_BAR_TAG"] = "食材"
L["Currencies to show"] = "通貨至顯示"
L["Currency"] = "貨幣"
L["Dim junk"] = "暗淡的垃圾"
L["disabled"] = "停用"
L["Display a smaller money frame. This setting will take effect on next reload."] = "顯示一個較小的金錢框架。此設置將在下次重載後生效。"
L["Display character currency at bottom left of the backpack."] = "在背包左下方顯示角色的兌換通貨"
L["Display character money at bottom right of the backpack."] = "在背包右下方顯示角色的金錢"
L["Display the level of equippable item in the top left corner of the button."] = "在可裝備物品的左上角顯示物品等級。"
L["Do not show anchor point"] = "不要顯示對齊點"
L["Do not show level of heirloom items."] = "不要顯示傳家寶的物品等級。"
L["Do not show level of items that cannot be equipped."] = "不要顯示無法裝備物品的等級。"
L["Do not show level of poor quality items."] = "不要顯示劣質物品的等級。"
L["Do not show levels under this threshold."] = "不要顯示此等級以下的物品。"
L["Drag to move this bag."] = "拖曳以移動這個袋子。"
L["Drop an item there to add it to the list."] = "拖放物品至此可添加至列表。"
L["Drop your item there to add it to this section."] = "拖放物品加入到類別。"
L["Enabled"] = "啟用"
L["enabled"] = "啟用"
L["Enabled bags"] = "啟用介面"
L["ENCHANTING_BAG_TAG"] = "附魔"
L["ENGINEERING_BAG_TAG"] = "工程"
L["Enter the name of the section to associate with the item."] = "輸入類別名稱來與物品建立關連"
L["Enter the name, link or itemid of the item to associate with the section. You can also drop an item into this box."] = "輸入物品名稱、連結或物品ID，來與類別建立關連；也可以直接將物品拖曳至此處。"
L["Equipment"] = "裝備"
L["Equipped bags"] = "裝備背包"
L["Error in %s: %s -- details: %s"] = "%s錯誤：%s -- 細節：%s"
L["Exclude list"] = "排除列表"
L["Filter"] = "過濾方式"
L["Filtering information"] = "過濾資訊"
L["Filters"] = "過濾方式"
L["Filters are used to dispatch items in bag sections. One item can only appear in one section. If the same item is selected by several filters, the one with the highest priority wins."] = "過濾方式是用來分類背包中的物品。一件物品只能被分類到一個類別。如果一項物品符合多個過濾條件，會以優先順序最高者為準。"
L["Font"] = "字體"
L["Four general sections."] = "裝備分為四大類(武器/護甲/飾品/其他)"
L["Free space"] = "可用空間"
L["Free space / total space"] = "空間/總空間"
L["Gear manager item sets"] = "裝備管理員套裝"
L["GEM_BAG_TAG"] = "寶石"
L["Gems are trade goods"] = "寶石是貿易商品"
L["Glyphs are trade goods"] = "雕紋是貿易商品"
L["HERB_BAG_TAG"] = "草藥"
L["Hide the colored corner shown when you move the bag."] = "移動背包時隱藏在角落顯示的色塊。"
L["Hide zeroes"] = "隱藏零值"
L["Highlight changes"] = "顯著標示變動"
L["Highlight color"] = "顯著標示顏色"
L["Highlight scale"] = "顯著標示縮放大小"
L["Highlight style"] = "顯著標示樣式"
L["Highlight what changes in bags with a little sparkle."] = "以閃光來突顯背包內的變動。"
L["If the addon seems not to work properly, please re-enable error reporting and check again before filing a bug ticket."] = "如果該插件似乎不能正常運作，在提交問題回報(bug ticket)前，請重新啟用錯誤報告(error reporting)來檢查。"
L["Ignore currencies with null amounts."] = "忽略數量為零的貨幣。"
L["Ignore heirloom items"] = "忽略傳家寶"
L["Ignore low quality items"] = "忽略低品質的物品"
L["Include list"] = "包含列表"
L["Included categories"] = "包含分類"
L["INSCRIPTION_BAG_TAG"] = "銘文"
L["Insets"] = "間距"
L["Item"] = "物品"
L["Item category"] = "物品類別"
L["Item information"] = "物品資訊"
L["Item level"] = "物品等級"
L["Items"] = "物品"
L["Items in this list are always considered as junk. Click an item to remove it from the list."] = "在此列表中的物品總是視為垃圾。可從列表中點擊要剔除的物品。"
L["Items in this list are never considered as junk. Click an item to remove it from the list."] = "在此列表中的物品不會視為垃圾。可從列表中點擊要剔除的物品。"
L["Jewelry"] = "飾品"
L["Junk category"] = "垃圾類別"
L["Keep all stacks together."] = "保持全部堆疊合起來。"
L["KEYRING_TAG"] = "Ke"
L["LDB Plugin"] = "LDB 外掛套件"
L["LEATHERWORKING_BAG_TAG"] = "製皮"
L["Legacy"] = "傳統"
L["Let SyLevel handle the the display."] = "讓 SyLevel 處理顯示。"
L["Lock anchor"] = "鎖定對齊點"
L["Low quality items"] = "劣質物品"
L["Manual"] = "手動"
L["Manual filtering"] = "手動分類"
L["Maximum bag height"] = "最大高度的背包"
L["Maximum stack size"] = "最大的堆疊多少"
L["Merge bag types"] = "合併背包類型"
L["Merge free space"] = "合併空間"
L["Merge incomplete stacks with complete ones."] = "合併顯示完整與不完整推疊"
L["Merge stackable items"] = "合併可堆疊的物品"
L["Merge unstackable items"] = "合併未可堆疊的物品"
L["Merged sets"] = "合併設定"
L["MINING_BAG_TAG"] = "礦石"
L["Mininum level"] = "最低物品等級"
L["Money"] = "金錢"
L["Move items from and to the bank by right-clicking on section headers."] = "右鍵點擊類別標題，可將該類別物品存放到銀行，或由銀行中提取。"
L["Never"] = "永不"
L["New"] = "新物品"
L["New Override"] = "新覆蓋"
L["New section"] = "新分類"
L["No error reports"] = "沒有錯誤報告"
L["None"] = "無"
L["Nothing to sell."] = "不賣。"
L["One section per item slot."] = "依物品部位各自分類"
L["One section per set"] = "以一組裝備設定為一個分類"
L["Only equippable items"] = "只有可裝備的物品"
L["Only one section."] = "只分為一個類別"
L["Opacity"] = "透明度"
L["Open automatically"] = "自動開啟"
L["Please note this filter matchs every item. Any filter with lower priority than this one will have no effect."] = "請注意，此過濾功能將適用於全部的物品，其他優先性較低的過濾設定將會被覆蓋而無法生效。"
L["Plugins"] = "外掛套件"
L["Position mode"] = "位置模式"
L["Press Alt while doing so to open a dropdown menu."] = "按 Alt 鍵可以打開下拉選單。"
L["Priority"] = "優先順序"
L["Provides a LDB data source to be displayed by LDB display addons."] = "提供LDB顯示插件的資料來源"
L["Put any item that can be equipped (including bags) into the \"Equipment\" section."] = "將任何可裝備的物品 (包含背包) 放在「裝備」類別。"
L["Put items belonging to one or more sets of the built-in gear manager in specific sections."] = "將屬於遊戲內建裝備管理員套裝的物品放在各自的區塊裡。"
L["Put items in sections depending on their first-level category at the Auction House."] = "依拍賣場的「主類型」來分類物品。"
L["Put items of poor quality or labeled as junk in the \"Junk\" section."] = "將劣質或垃圾物品分類為垃圾類別。"
L["Put quest-related items in their own section."] = "將任務相關物品分類為任務類別。"
L["Quality highlight"] = "品質顏色外框"
L["Quest indicator"] = "任務指示物"
L["Quest Items"] = "任務物品"
L["QUIVER_TAG"] = "Qu"
L["Recent Items"] = "新物品"
L["Related to player level"] = "相對於玩家等級"
L["Remove"] = "移除"
L["Reset"] = "重設"
L["Reset new items"] = "重設新物品"
L["Reset position"] = "重設位置"
L["Right-click to (un)lock the bag anchor."] = "點右鍵來鎖定/解鎖背包對齊。"
L["Right-click to configure."] = "點右鍵來設定。"
L["Right-click to move these items."] = "點右鍵來移動這些物品。"
L["Right-click to open options"] = "點右鍵開啟選項"
L["Right-click to sell these items."] = "點右鍵來賣掉這些物品。"
L["Right-click to toggle %s."] = "點右鍵開啟或關閉%s。"
L["Right-click to try to empty this bag."] = "點右鍵嘗試清空這個背包。"
L["Same as InventoryItemLevels"] = "與 InventoryItemLevels 插件一樣"
L["Scale"] = "縮放"
L["Section"] = "類別"
L["Section category"] = "類別"
L["Section header"] = "類別標題"
L["Section setup"] = "類別設定"
L["Section visibility"] = "顯示類別"
L["Section visibility button"] = "顯示類別按鈕"
L["Select how bag usage should be formatted in the plugin."] = "選擇背包使用狀況格式"
L["Select how items should be sorted within each section."] = "設定各類別中物品的排序方式。"
L["Select how the bags are positionned."] = "選擇背包該如何決定位置"
L["Select the category of the section to associate. This is used to group sections together."] = "選擇分類相關聯的分組。這是用來組合類別的分組。"
L["Select the sections in which the items should be dispatched."] = "選擇物品分組的類別"
L["Select which bags AdiBags should display."] = "選擇哪種背包要使用 AdiBags 介面"
L["Select which first-level categories should be split by sub-categories."] = "勾選將此類型再細分為子類型"
L["Separate incomplete stacks."] = "分開不完整的堆疊。"
L["Separate unstackable items."] = "分開未可堆疊的物品。"
L["Set: %s"] = "套裝: %s"
L["Sets"] = "套裝"
L["Show %s"] = "顯示 %s"
L["Show bag type icons"] = "顯示背包類型圖示"
L["Show bag type tags"] = "顯示背包類型標籤"
L["Show bank usage"] = "顯示銀行使用"
L["Show container information..."] = "顯示容器資訊"
L["Show every distinct item stacks."] = "顯示每個不同的物品堆疊。"
L["Show filtering information..."] = "顯示過濾資訊..."
L["Show item information..."] = "顯示物品資訊"
L["Show only one free slot for each kind of bags."] = "將各個背袋的可用格數合併為一格顯示。"
L["Show only one slot of items that can be stacked."] = "可堆疊物品合併顯示於一格"
L["Show only one slot of items that cannot be stacked."] = "將不可堆疊物品也集中顯示"
L["Size"] = "大小"
L["Skin"] = "外觀"
L["Slot number"] = "槽數"
L["Small"] = "小型"
L["Sort items by bind type."] = "依綁定類型排序。"
L["Sorting order"] = "排序"
L["SOUL_BAG_TAG"] = "靈魂"
L["Space in use"] = "空間使用"
L["Space in use / total space"] = "空間使用/總空間"
L["Split armors by types"] = "根據武器種類進行分類"
L["Split by subcategories"] = "子類別的分離"
L["TACKLE_BOX_TAG"] = "釣魚"
L["Text"] = "文字"
L["Texture"] = "材質"
L["Toggle and configure item filters."] = "切換和設定物品過濾方式。"
L["Toggle and configure plugins."] = "切換和設定外掛套件。"
L["Tooltip information"] = "提示資訊"
L["Track new items"] = "追蹤新物品"
L["Track new items in each bag, displaying a glowing aura over them and putting them in a special section. \"New\" status can be reset by clicking on the small \"N\" button at top left of bags."] = "追蹤新進物品，在新物品上顯示光環並分類至一個特殊的「新物品」分類。點擊右上角的「N」按鈕可還原新進物品至一般分類。"
L["Uncheck this to disable AdiBags."] = "不選此停用AdiBags。"
L["Unlock anchor"] = "解鎖對齊點"
L["Use SyLevel"] = "使用SyLevel"
L["Use this section to define any item-section association."] = "使用此類別定義任意物品分組過濾"
L["Use this to adjust the bag scale."] = "調整包包大小"
L["Use this to adjust the quality-based border opacity. 100% means fully opaque."] = "調整品質邊框透明度 100%=完全不透明"
L["Virtual stack slots"] = "虛擬堆疊插槽"
L["Virtual stacks"] = "虛擬堆疊"
L["Virtual stacks display in one place items that actually spread over several bag slots."] = "將散落於各背包內的同一物品以虛擬堆疊顯示"
L["When alt is held down"] = "按住 Alt 鍵時"
L["When any modifier key is held down"] = "按住任意輔助鍵時"
L["When checked, right-clicking on an empty space of a bag opens the configuration panel."] = "勾選時，可在背包的空白處點擊右鍵，以打開設定選單。"
L["When ctrl is held down"] = "按住 Ctrl 鍵時"
L["When shift is held down"] = "按住 Shift 鍵時"
L["Which color scheme should be used to display the item level ?"] = "應該使用哪種顏色設定顯示物品等級?"
L["You can block auto-deposit ponctually by pressing a modified key while talking to the banker."] = "在與銀行職員對話的同時按住『輔助按鍵』，可避免自動存放功能。"

-- 自行加入
L["AdiBags"] = "背包"
L["Adi Bags"] = "Adi 背包"
L["(Blizzard's) Sort items"] = "(遊戲內建的) 整理物品"
L["Automatically..."] = "自動..."
L["Open"] = "打開背包"
L["Deposit reagents"] = "存放材料"
L["Automtically deposit all reagents into the reagent bank when you talk to the banker."] = "和銀行行員對話時，自動將所有材料存放到材料銀行。"
L["Position & size"] = "位置和大小"
L["Section layout"] = "區塊版面配置"
L["Compact layout"] = "精簡版面"
L["When enabled, AdiBags reorder the section to achieve a more compact layout."] = "重新排列區塊以達到更精簡的版面。"
L["Reagent bank color"] = "材料銀行顏色"
L["At mechants', bank, auction house, ..."] = "在商人、銀行、拍賣場等..."
L['Highlight items that have changed'] = "顯著標示有變動的物品"
L['Show battle pet levels'] = "顯示戰寵等級"
L['Shows the levels of caged battle pets.'] = "顯示裝在籠子裡的戰寵等級。"
L["Recent items"] = "新物品"
L["This special section receives items that have been recently moved, changed or added to the bags."] = "這個特別的區域會顯示最近被移動、變更或新增到背包中的物品。"
L['Layout'] = "版面配置"
L['Currencies per row'] = "每個橫列顯示幾種貨幣"
L["Reagent"] = "材料"
L["Reagent Bag"] = "材料包"

L["QUIVER_TAG"] = "任"
L["AMMO_TAG"] = "彈"
L["SOUL_BAG_TAG"] = "靈"
L["LEATHERWORKING_BAG_TAG"] = "皮"
L["INSCRIPTION_BAG_TAG"] = "銘"
L["HERB_BAG_TAG"] = "草"
L["ENCHANTING_BAG_TAG"] = "附"
L["ENGINEERING_BAG_TAG"] = "工"
L["KEYRING_TAG"] = "鑰"
L["GEM_BAG_TAG"] = "寶"
L["MINING_BAG_TAG"] = "礦"
L["REAGENT_BAG_TAG"] = "材"
L["TACKLE_BOX_TAG"] = "魚"
L["COOKING_BAR_TAG"] = "烹"

L['Theme'] = "外觀主題"
L['Theme Selection'] = "選擇外觀主題"
L['Select the theme to use for displaying the bags.'] = "選擇要用來顯示這個背包的外觀主題。"
L['Theme Controls'] = "外觀主題控制"
L['All controls are disabled if the selected theme is the default theme. Make a new theme below to edit your theme.'] = "選擇的外觀主題是預設主題時，所有控制功能都會被停用。在下方建立新的主題來編輯你自己的外觀主題。"
L['Save Theme'] = "儲存外觀主題"
L['Save the current theme settings to the selected theme name.'] = "將目前的主題設定儲存到到選擇的外觀主題名稱。"
L["Are you sure you want to save and overwrite the theme '"] = "是否確定要儲存並取代外觀主題 '"
L['Delete Theme'] = "刪除外觀主題"
L['Delete the selected theme from the database.'] = "從資料庫中刪除選擇的外觀主題。"
L["Are you sure you want to delete the theme '"] = "是否確定要刪除外觀主題 '"
L['Type in a new theme in the input below and hit enter to create a new theme.'] = "在下面的文字欄位中輸入新的名稱，然後按下 Enter 鍵來建立新的外觀主題。"
L['New Theme Name'] = "新外觀主題名稱"
L['Type in the name of the new theme to create.'] = "輸入新主題的名稱來建立外觀主題。"
L["A theme by that name already exists."] = "已經有相同名稱的外觀主題。"
L["Reagent Bank"] = "材料銀行"
L['Border Width'] = "邊框寬度"
L['Background'] = "背景"

L['Masque'] = "按鈕外觀"
L['Support for skinning item buttons with Masque.'] = "支援使用 Masque 插件來更改物品按鈕的外觀。"

-- core/Constants.lua
L["Engineering"] = "工程學"
L["Tailoring"] = "裁縫"
L["Leatherworking"] = "製皮"
L["Mining"] = "採礦"
L["Herbalism"] = "草藥學"

L['Experiments'] = "實驗性功能"
L['View your experiment groups and toggle participation.'] = "檢視實驗性功能和切換是否要使用。"
L["Bag Lag Fix"] = "修正背包延遲"
L["This experiment will fix the lag when opening bags via per-item change draws instead of full redraws."] = "這個實驗性功能會修正打開背包時的延遲，藉由只繪製變更過的物品，而不是全部重新繪製。"

------------------------ zhCN ------------------------
elseif locale == 'zhCN' then
L["Engineering"] = "工程学"
L["Tailoring"] = "裁缝"
L["Leatherworking"] = "制皮"
L["Mining"] = "采矿"
L["Herbalism"] = "草药学"
L["Add a dropdown menu to bags that allow to hide the sections."] = "给背包添加下拉菜单, 允许隐藏分组."
L["Add association"] = "添加过滤"
L["Add more information in tooltips related to items in your bags."] = "显示物品的额外提示信息"
L["AdiBags Anchor"] = "AdiBags 锚点"
L["Adjust the maximum height of the bags, relative to screen size."] = "调整背包最大高度 (相对于屏幕)"
L["AH category"] = "拍卖类"
L["AH subcategory"] = "拍卖子类"
L["Allow you manually redefine the section in which an item should be put. Simply drag an item on the section title."] = "允许以将物品拖曳至区块标题的方式来分类物品" -- Needs review
L["Alt-right-click to configure manual filtering."] = "按住Alt键单击鼠标右键 配置手动筛选。"
L["Alt-right-click to configure the Junk module."] = "按住Alt键单击鼠标右键配置垃圾模块。"
L["Alt-right-click to switch to anchored placement."] = "按住Alt键单击鼠标右键切换到锚定位置。"
L["Alt-right-click to switch to manual placement."] = "按住Alt键单击鼠标右键切换到手动放置。"
L["Always"] = "总是"
L["AMMO_TAG"] = "弹"
L["Ammunition"] = "弹药"
L["Anchored"] = "锚点"
L["Are you sure you want to remove this section ?"] = "确定移除此过滤 ?"
L["Assign %s to ..."] = "指定 %s 到 ..." -- Needs review
L["At mechants', bank, auction house, ..."] = "在商人,银行,拍卖场等..."
L["Automatically open the bags at merchant's, bank, ..."] = "在商人、银行等处自动打开背包" -- Needs review
L["Backpack"] = "背包"
L["Backpack color"] = "背包颜色"
L["Bag background"] = "背包背景"
L["Bag #%d"] = "背包 #%d"
L["Bag number"] = "背包号"
L["Bags"] = "背包"
L["Bag title"] = "背包标题"
L["Bag type"] = "背包类型"
L["Bag usage format"] = "背包使用格式"
L["Bank"] = "银行"
L["Bank bag #%d"] = "银行包 #%d"
L["Bank color"] = "银行颜色"
L["Bank Switcher"] = "银行切换"
L["Border"] = "边框"
L["Border width"] = "边框宽度"
L["By category, subcategory, quality and item level (default)"] = "按类别, 子类别, 品质和物品等级(默认)"
L["By name"] = "按名称"
L["By quality and item level"] = "按品质和物品等级"
L["Category"] = "分类"
L["Change stacking at merchants', auction house, bank, mailboxes or when trading."] = "在交易, 拍卖, 银行, 邮局以及实施商业技能时更改堆叠效果."
L["Check sets that should be merged into a unique \"Sets\" section. This is obviously a per-character setting."] = "根据套装分组物品, 此项根据每个角色设置有所不同."
L["Check this so armors are dispatched in four sections by type."] = "护甲将按四大类型分组 (布甲/皮甲/锁甲/板甲)."
L["Check this to display a bag type tag in the top left corner of items."] = "在物品左上角显示标签, 标示其放置的特殊背包类型."
L["Check this to display a colored border around items, based on item quality."] = "按物品品质着色边框."
L["Check this to display an icon after usage of each type of bags."] = "在每个类型背包使用后显示一个图标."
L["Check this to display an indicator on quest items."] = "标示任务物品."
L["Check this to display an textual tag before usage of each type of bags."] = "在每个类型背包前显示文本标记."
L["Check this to display one individual section per set. If this is disabled, there will be one big \"Sets\" section."] = "每个套装独立分组, 禁用此选项, 将会合并成一个大[套装]分组"
L["Check this to display only one value counting all equipped bags, ignoring their type."] = "选中来让所有装备包显示一个值，忽略类型。"
L["Check this to have poor quality items dimmed."] = "将低品质物品变暗"
L["Check this to show space at your bank in the plugin."] = "在银行中显示背包空间"
L["Check this to show this section. Uncheck to hide it."] = "勾选则显示此分组, 不勾选则隐藏."
L["Check to enable this module."] = "启用此模块"
L["Click on a item to remove it from the list. You can drop an item on the empty slot to add it to the list."] = "点击物品可从列表中移除. 也可拖放物品至空栏以添加至列表."
L["Click on this button to create the new association."] = "创建一个新过滤"
L["Click or drag this item to remove it."] = "点击或拖出物品可移除."
L["Click there to reset the bag positions and sizes."] = "重置背包位置和尺寸"
L["Click to purchase"] = "购买"
L["Click to reset item status."] = "重置物品状态."
L["Click to select which sections should be shown or hidden. Section visibility is common to all bags."] = "设置显示/隐藏物品分组, 默认全部显示."
L["Click to toggle the bag anchor."] = "切换背包锚点"
L["Click to toggle the equipped bag panel, so you can change them."] = "点击切换背包面板, 用于更换背包."
L["Close"] = "关闭"
L["Color"] = "颜色"
L["Color scheme"] = "颜色设定" -- Needs review
L["Configure"] = "配置"
L["Consider gems as a subcategory of trade goods"] = "将珠宝设定为商品子类"
L["Consider glyphs as a subcategory of trade goods"] = "将雕文设定为商品子类"
L["Container information"] = "容器信息"
L["COOKING_BAR_TAG"] = "食材" -- Needs review
L["Currencies to show"] = "货币显示"
L["Currency"] = "货币"
L["Dim junk"] = "灰色垃圾"
L["Display a smaller money frame. This setting will take effect on next reload."] = "显示一个较小的货币框体。此项设定重载界面后生效。" -- Needs review
L["Display character currency at bottom left of the backpack."] = "在背包底部左侧显示角色拥有的货币."
L["Display character money at bottom right of the backpack."] = "在背包底部右侧显示金钱"
L["Display the level of equippable item in the top left corner of the button."] = "显示按钮的左上角含装备等级的物品。" -- Needs review
L["Do not show anchor point"] = "不要显示锚点" -- Needs review
L["Do not show level of heirloom items."] = "不要显示水平的传家宝。" -- Needs review
L["Do not show level of items that cannot be equipped."] = "不要显示无法装备的物品等级。" -- Needs review
L["Do not show level of poor quality items."] = "不要显示质量差的物品等级" -- Needs review
L["Do not show levels under this threshold."] = "不要显示此阈值等级下的物品。" -- Needs review
L["Drag to move this bag."] = "拖动以移动这个袋子。"
L["Drop an item there to add it to the list."] = "拖放物品至此可添加至列表."
L["Drop your item there to add it to this section."] = "拖曳物品到此分组."
L["Enabled"] = "启用"
L["Enabled bags"] = "(启用/关闭)袋UI界面"
L["ENCHANTING_BAG_TAG"] = "容器" -- Needs review
L["ENGINEERING_BAG_TAG"] = "工"
L["Enter the name, link or itemid of the item to associate with the section. You can also drop an item into this box."] = "输入物品名称, 链接或物品 ID 到此分组, 也可以拖曳物品至此."
L["Enter the name of the section to associate with the item."] = "输入分组名称以建立过滤"
L["Equipment"] = "装备"
L["Equipped bags"] = "已装备背包"
L["Exclude list"] = "排除列表"
L["Filter"] = "过滤"
L["Filtering information"] = "过滤信息"
L["Filters"] = "过滤器"
L["Filters are used to dispatch items in bag sections. One item can only appear in one section. If the same item is selected by several filters, the one with the highest priority wins."] = "过滤器将用于背包分类中调度物品, 一件物品仅可在一个分类中显示. 如果在多个过滤器中选中相同的物品, 将使用最高优先级."
L["Font"] = "字型"
L["Four general sections."] = "按护甲类型分组"
L["Free space"] = "空闲空间"
L["Free space / total space"] = "空闲 / 总空间"
L["Gear manager item sets"] = "套装管理"
L["GEM_BAG_TAG"] = "宝"
L["Gems are trade goods"] = "宝石是商品"
L["Glyphs are trade goods"] = "铭文是商品"
L["HERB_BAG_TAG"] = "草"
L["Hide the colored corner shown when you move the bag."] = "当移动背包时隐藏边框着色。" -- Needs review
L["Hide zeroes"] = "隐藏零"
L["Highlight color"] = "高亮颜色"
L["Highlight scale"] = "高亮缩放"
L["Ignore currencies with null amounts."] = "忽略货币的无效量。"
L["Ignore heirloom items"] = "忽略传家宝" -- Needs review
L["Ignore low quality items"] = "忽略劣质物品" -- Needs review
L["Included categories"] = "包含过滤"
L["Include list"] = "包含列表"
L["... including incomplete stacks"] = "包含不完整堆叠"
L["INSCRIPTION_BAG_TAG"] = "铭"
L["Insets"] = "插图"
L["Item"] = "物品"
L["Item category"] = "物品类别"
L["Item information"] = "物品信息"
L["Item level"] = "物品等级" -- Needs review
L["Items"] = "物品"
L["Items in this list are always considered as junk. Click an item to remove it from the list."] = "此列表物品将不被归类为垃圾. 点击可移除."
L["Items in this list are never considered as junk. Click an item to remove it from the list."] = "此列表物品将不被归类为垃圾. 点击可移除."
L["Jewelry"] = "饰品"
L["Junk category"] = "垃圾"
L["Keep all stacks together."] = "将所有堆叠合并"
L["KEYRING_TAG"] = "钥"
L["LDB Plugin"] = "LDB 组件"
L["LEATHERWORKING_BAG_TAG"] = "皮"
L["Lock anchor"] = "锁定锚点"
L["Low quality items"] = "劣质物品"
L["Manual"] = "手动"
L["Manual filtering"] = "手动过滤"
L["Maximum bag height"] = "最大背包高度"
L["Maximum stack size"] = "最大堆叠"
L["Merge bag types"] = "合并背包类型"
L["Merged sets"] = "合并套装"
L["Merge free space"] = "合并空间"
L["Merge incomplete stacks with complete ones."] = "合并不完整堆叠"
L["Merge stackable items"] = "合并可堆叠物品"
L["Merge unstackable items"] = "合并不可堆叠的物品"
L["MINING_BAG_TAG"] = "矿"
L["Mininum level"] = "最低限度的等级" -- Needs review
L["Money"] = "金钱"
L["Move items from and to the bank by right-clicking on section headers."] = "通過類別標題右鍵單擊進行，移動該類別物品到銀行。" -- Needs review
L["Never"] = "从不"
L["New"] = "新物品"
L["New Override"] = "新建覆盖"
L["New section"] = "新分类" -- Needs review
L["None"] = "无" -- Needs review
L["Nothing to sell."] = "不卖。"
L["One section per item slot."] = "按物品位置分组"
L["One section per set"] = "按套装分组"
L["Only equippable items"] = "只有装备的物品" -- Needs review
L["Only one section."] = "仅一个分组"
L["Opacity"] = "透明度"
L["Open automatically"] = "自动打开"
L["Please note this filter matchs every item. Any filter with lower priority than this one will have no effect."] = "注意, 此筛选功能应用于全部物品, 其他优先级较低的筛选设置将被覆盖而无法生效."
L["Plugins"] = "组件"
L["Position mode"] = "定位模式"
L["Press Alt while doing so to open a dropdown menu."] = "按下Alt键将打开一个下拉菜单。" -- Needs review
L["Priority"] = "优先级"
L["Provides a LDB data source to be displayed by LDB display addons."] = "给 LDB 提供数据资料, 以便符合 LDB 规范的插件使用."
L["Put any item that can be equipped (including bags) into the \"Equipment\" section."] = "放置可装备物品至[装备]分组"
L["Put items belonging to one or more sets of the built-in gear manager in specific sections."] = "按装备管理设置的套装分组放置物品"
L["Put items in sections depending on their first-level category at the Auction House."] = "按拍卖行主类型规则分组放置物品."
L["Put items of poor quality or labeled as junk in the \"Junk\" section."] = "将低品质或者垃圾物品放入[垃圾]分组"
L["Put quest-related items in their own section."] = "将任务物品放入相关分组"
L["Quality highlight"] = "品质高亮"
L["Quest indicator"] = "任务指示器"
L["Quest Items"] = "任务物品"
L["QUIVER_TAG"] = "箭"
L["Related to player level"] = "与玩家等级相关" -- Needs review
L["Remove"] = "移除"
L["Reset"] = "重设"
L["Reset new items"] = "整理新物品"
L["Reset position"] = "重置位置"
L["Right-click to configure."] = "右键单击配置"
L["Right-click to move these items."] = "右键单击以移动这些物品。"
L["Right-click to open options"] = "右键点击开启选项"
L["Right-click to sell these items."] = "右键单击出售这些物品。"
L["Right-click to try to empty this bag."] = "右键点击尝试清空此背包."
L["Right-click to (un)lock the bag anchor."] = "右键单击(不锁定/锁定)袋锚点。"
L["Same as InventoryItemLevels"] = "一样等级的物品" -- Needs review
L["Scale"] = "缩放"
L["Section"] = "分组"
L["Section category"] = "分组类型"
L["Section header"] = "分类标题" -- Needs review
L["Section setup"] = "分组设定"
L["Section visibility"] = "分组可见"
L["Section visibility button"] = "分组可见按钮"
L["Select how bag usage should be formatted in the plugin."] = "选择背包使用状况格式"
L["Select how items should be sorted within each section."] = "物品在每个分组内排序方式"
L["Select how the bags are positionned."] = "选择背包应如何放置" -- Needs review
L["Select the category of the section to associate. This is used to group sections together."] = "选择分组过滤类型. 用于聚合分组."
L["Select the sections in which the items should be dispatched."] = "选择物品分配的分组"
L["Select which bags AdiBags should display."] = "选择Adibags应该显示哪些背包" -- Needs review
L["Select which first-level categories should be split by sub-categories."] = "选择使用子类型拆分的物品主类型"
L["Separate incomplete stacks."] = "分开不完整的堆叠"
L["Separate unstackable items."] = "分开不可堆叠的物品"
L["Sets"] = "套装"
L["Set: %s"] = "套装: %s"
L["Show bag type icons"] = "显示背包类型图标"
L["Show bag type tags"] = "显示背包类型标签"
L["Show bank usage"] = "显示银行占用"
L["Show container information..."] = "显示容器信息"
L["Show every distinct item stacks."] = "显示每个不同的物品堆叠"
L["Show filtering information..."] = "显示过滤信息"
L["Show item information..."] = "显示物品信息"
L["Show only one free slot for each kind of bags."] = "每种类型背包空余空间分别合并显示为一格"
L["Show only one slot of items that can be stacked."] = "将可堆叠物品合并显示为一格"
L["Show only one slot of items that cannot be stacked."] = "将不可堆叠物品合并显示为一格"
L["Show %s"] = "显示 %s"
L["Size"] = "大小"
L["Skin"] = "皮肤"
L["Slot number"] = "槽号"
L["Sorting order"] = "分类顺序"
L["SOUL_BAG_TAG"] = "魂"
L["Space in use"] = "已使用空间"
L["Space in use / total space"] = "已使用空间 / 总空间"
L["Split armors by types"] = "按类型拆分护甲"
L["Split by subcategories"] = "按子类拆分"
L["TACKLE_BOX_TAG"] = "鱼具箱" -- Needs review
L["Text"] = "文本"
L["Texture"] = "材质"
L["Toggle and configure item filters."] = "配置物品过滤"
L["Toggle and configure plugins."] = "配置组件"
L["Tooltip information"] = "提示信息"
L["Track new items"] = "追踪新物品"
L["Track new items in each bag, displaying a glowing aura over them and putting them in a special section. \"New\" status can be reset by clicking on the small \"N\" button at top left of bags."] = "追踪背包中的新物品, 新物品在[新物品]区将高亮显示, 可以点击右上[N]按钮将其重置."
L["Uncheck this to disable AdiBags."] = "反选禁用 AdiBags"
L["Unlock anchor"] = "解锁锚点"
L["Use this section to define any item-section association."] = "使用此分组定义任意物品分组过滤"
L["Use this to adjust the bag scale."] = "背包缩放"
L["Use this to adjust the quality-based border opacity. 100% means fully opaque."] = "调整品质背景透明度, 100% 为不透明"
L["Virtual stacks"] = "虚拟堆叠"
L["Virtual stacks display in one place items that actually spread over several bag slots."] = "虚拟堆叠将同一物品用一个单位显示, 实际在背包中仍占用多个位置."
L["Virtual stack slots"] = "虚拟堆叠"
L["When alt is held down"] = "当ALT键被按下" -- Needs review
L["When any modifier key is held down"] = "当任意键被按下" -- Needs review
L["When checked, right-clicking on an empty space of a bag opens the configuration panel."] = "选择后可以在背包空白处点击右键打开配置面板。" -- Needs review
L["When ctrl is held down"] = "当CTRL键被按下" -- Needs review
L["When shift is held down"] = "当SHIFT键被按下" -- Needs review
L["Which color scheme should be used to display the item level ?"] = "应该使用哪种颜色设定显示物品的等级?" -- Needs review
end

-- @noloc]]

-- Replace remaining true values by their key
for k,v in pairs(L) do if v == true then L[k] = k end end
