local Addon = select(2, ...) ---@type Addon

--- @class Locale
local L = Addon:GetModule("Locale")

setmetatable(L, {
  __index = function(t, k)
    return rawget(t, k) or k
  end
})

-- ============================================================================
-- English
-- ============================================================================

L["ADD_ALL_TO_LIST"] = "Add All to %s"
L["ADD_TO_LIST"] = "Add to %s"
L["ALL_ITEMS_REMOVED_FROM_LIST"] = "Removed all items from %s."
L["ALT_KEY"] = "Alt"
L["AUTO_JUNK_FRAME_TEXT"] = "Auto Junk Frame"
L["AUTO_JUNK_FRAME_TOOLTIP"] = "Automatically toggle the Junk frame upon interacting with a merchant."
L["AUTO_REPAIR_TEXT"] = "Auto Repair"
L["AUTO_REPAIR_TOOLTIP"] = "Automatically repair upon interacting with a merchant."
L["AUTO_SELL_TEXT"] = "Auto Sell"
L["AUTO_SELL_TOOLTIP"] = "Automatically sell items upon interacting with a merchant."
L["BAG_ITEM_ICONS_TEXT"] = "Bag Item Icons"
L["BAG_ITEM_ICONS_TOOLTIP"] = "Overlay an icon on junk items in your bags."
L["BAG_ITEM_TOOLTIPS_TEXT"] = "Bag Item Tooltips"
L["BAG_ITEM_TOOLTIPS_TOOLTIP"] = "Add Dejunk information to the tooltips of items in your bags."
L["CANNOT_OPEN_LOOTABLE_ITEMS"] = "Cannot open lootable items right now."
L["CANNOT_SELL_OR_DESTROY_ITEM"] = "Cannot sell or destroy %s."
L["CANNOT_SELL_WITHOUT_MERCHANT"] = "Cannot sell items without a merchant."
L["CHANGE_VALUE"] = "Change Value"
L["CHARACTER_SPECIFIC_SETTINGS_TEXT"] = "Character Specific Settings"
L["CHARACTER_SPECIFIC_SETTINGS_TOOLTIP"] = "Enable settings specific to this character."
L["CHARACTER"] = "Character"
L["CHAT_MESSAGES_TEXT"] = "Chat Messages"
L["CHAT_MESSAGES_TOOLTIP"] = "Enable chat messages."
L["CLEAR_SEARCH"] = "Clear Search"
L["CLEAR"] = "Clear"
L["COMMAND_DESCRIPTION_DESTROY"] = "Destroy the next junk item."
L["COMMAND_DESCRIPTION_HELP"] = "Display a list of commands."
L["COMMAND_DESCRIPTION_JUNK"] = "Toggle the junk frame."
L["COMMAND_DESCRIPTION_KEYBINDS"] = "Open the key binding frame."
L["COMMAND_DESCRIPTION_LOOT"] = "Open lootable items."
L["COMMAND_DESCRIPTION_OPTIONS"] = "Toggle the options frame."
L["COMMAND_DESCRIPTION_SELL"] = "Start selling junk items."
L["COMMAND_DESCRIPTION_TRANSPORT"] = "Toggle the transport frame."
L["COMMANDS"] = "Commands"
L["COMMON"] = "Common"
L["CONTROL_KEY"] = "Ctrl"
L["DESTROY_NEXT_ITEM"] = "Destroy Next Item"
L["DESTROY"] = "Destroy"
L["DESTROYED_ITEM"] = "Destroyed: %s."
L["DOES_NOT_APPLY_TO_SPECIAL_EQUIPMENT"] = "Does not apply to generic, cosmetic, or fishing pole items."
L["EPIC"] = "Epic"
L["EXCLUDE_EQUIPMENT_SETS_TEXT"] = "Exclude Equipment Sets"
L["EXCLUDE_EQUIPMENT_SETS_TOOLTIP"] = "Exclude equipment that is saved to an equipment set."
L["EXCLUDE_UNBOUND_EQUIPMENT_TEXT"] = "Exclude Unbound Equipment"
L["EXCLUDE_UNBOUND_EQUIPMENT_TOOLTIP"] = "Exclude equipment that is not bound."
L["EXCLUDE_WARBAND_EQUIPMENT_TEXT"] = "Exclude Warband Equipment"
L["EXCLUDE_WARBAND_EQUIPMENT_TOOLTIP"] = "Exclude equipment that can be placed in the warband bank."
L["EXCLUDE"] = "Exclude"
L["EXCLUSIONS_DESCRIPTION_GLOBAL"] = "Items on this list will not be considered junk unless included by %s."
L["EXCLUSIONS_DESCRIPTION_PERCHAR"] = "Items on this list will never be considered junk."
L["EXCLUSIONS_TEXT"] = "Exclusions"
L["EXPORT"] = "Export"
L["FAILED_TO_DESTROY_ITEM"] = "Failed to destroy %s."
L["FAILED_TO_SELL_ITEM"] = "Failed to sell %s."
L["GENERAL"] = "General"
L["GLOBAL"] = "Global"
L["IMPORT"] = "Import"
L["INCLUDE_ARTIFACT_RELICS_TEXT"] = "Include Artifact Relics"
L["INCLUDE_ARTIFACT_RELICS_TOOLTIP"] = "Include artifact relic gems."
L["INCLUDE_BELOW_ITEM_LEVEL_POPUP_HELP"] = "Enter an item level:"
L["INCLUDE_BELOW_ITEM_LEVEL_TEXT"] = "Include Below Item Level"
L["INCLUDE_BELOW_ITEM_LEVEL_TOOLTIP"] = "Include equipment with an item level below a set value (%s)."
L["INCLUDE_BY_QUALITY_TEXT"] = "Include By Quality"
L["INCLUDE_BY_QUALITY_TOOLTIP"] = "Mass include items based on quality."
L["INCLUDE_UNSUITABLE_EQUIPMENT_TEXT"] = "Include Unsuitable Equipment"
L["INCLUDE_UNSUITABLE_EQUIPMENT_TOOLTIP"] = "Include equipment with an armor or weapon type that is unsuitable for your class."
L["INCLUDE"] = "Include"
L["INCLUSIONS_DESCRIPTION_GLOBAL"] = "Items on this list will be considered junk unless excluded by %s."
L["INCLUSIONS_DESCRIPTION_PERCHAR"] = "Items on this list will always be considered junk."
L["INCLUSIONS_TEXT"] = "Inclusions"
L["IS_BUSY_CONFIRMING_ITEMS"] = "Confirming items..."
L["IS_BUSY_SELLING_ITEMS"] = "Selling items..."
L["ITEM_ADDED_TO_LIST"] = "%s added to %s."
L["ITEM_ALREADY_ON_LIST"] = "%s is already on %s."
L["ITEM_ID_DOES_NOT_EXIST"] = "Item with ID %s does not exist."
L["ITEM_ID_FAILED_TO_PARSE"] = "Item with ID %s failed to parse and may not exist."
L["ITEM_IDS"] = "Item IDs"
L["ITEM_IS_JUNK"] = "This item is junk."
L["ITEM_IS_LOCKED"] = "Item is locked."
L["ITEM_IS_NOT_JUNK"] = "This item is not junk."
L["ITEM_IS_REFUNDABLE"] = "Item is refundable."
L["ITEM_NOT_ON_LIST"] = "%s is not on %s."
L["ITEM_QUALITY_CHECK_BOX_TOOLTIP"] = "Apply to items of this quality."
L["ITEM_REMOVED_FROM_LIST"] = "%s removed from %s."
L["JUNK_FRAME_TOOLTIP"] = "Junk items you currently possess will be listed in this frame.|n|nTo add an item to %s, drop it into the frame below.|n|nTo add an item to %s, hold %s and drop it into the frame below."
L["JUNK_ITEMS"] = "Junk Items"
L["KEYBINDS"] = "Keybinds"
L["LEFT_CLICK"] = "Left-Click"
L["LIST_FRAME_TOOLTIP"] = "To add an item, drop it into the frame below."
L["LIST_FRAME_TRANSPORT_BUTTON_TOOLTIP"] = "Toggle the Transport frame for this list."
L["LISTS"] = "Lists"
L["LOADING"] = "Loading"
L["MAY_NOT_HAVE_DESTROYED_ITEM"] = "May not have destroyed %s."
L["MAY_NOT_HAVE_SOLD_ITEM"] = "May not have sold %s."
L["MERCHANT_BUTTON_TEXT"] = "Merchant Button"
L["MERCHANT_BUTTON_TOOLTIP"] = "Enable a button on the merchant frame."
L["MINIMAP_ICON_TEXT"] = "Minimap Icon"
L["MINIMAP_ICON_TOOLTIP"] = "Enable an icon on the minimap."
L["NO_FILTERS_MATCHED"] = "No filters matched."
L["NO_ITEMS"] = "No items."
L["NO_JUNK_ITEMS_TO_DESTROY"] = "No junk items to destroy."
L["NO_JUNK_ITEMS_TO_SELL"] = "No junk items to sell."
L["NO_LOOTABLE_ITEMS_TO_OPEN"] = "No lootable items to open."
L["OPEN_LOOTABLE_ITEMS"] = "Open Lootable Items"
L["OPTION_WARNING_BE_CAREFUL"] = "Please be careful with this option."
L["OPTIONS_TEXT"] = "Options"
L["POOR"] = "Poor"
L["PROFIT"] = "Profit: %s"
L["RARE"] = "Rare"
L["REMOVE_ALL_ITEMS"] = "Remove All Items"
L["REMOVE_FROM_LIST"] = "Remove from %s"
L["REMOVE"] = "Remove"
L["REPAIRED_ALL_ITEMS"] = "Repaired all items for %s."
L["RESET_POSITION"] = "Reset Position"
L["RIGHT_CLICK"] = "Right-Click"
L["SAFE_MODE_TEXT"] = "Safe Mode"
L["SAFE_MODE_TOOLTIP"] = "Only sell up to 12 items at a time."
L["SEARCH_LISTS"] = "Search Lists"
L["SELECT_ALL"] = "Select All"
L["SELL"] = "Sell"
L["SHIFT_KEY"] = "Shift"
L["SOLD_ITEM"] = "Sold: %s."
L["START_SELLING"] = "Start Selling"
L["TOGGLE_JUNK_FRAME"] = "Toggle Junk Frame"
L["TOGGLE_OPTIONS_FRAME"] = "Toggle Options Frame"
L["TRANSPORT_FRAME_TOOLTIP"] = "Use this frame to transport item IDs into or out of the target list.|n|nWhen importing, item IDs must be separated by a non-numeric character (e.g. 4983,58907,67410)."
L["TRANSPORT"] = "Transport"
L["UNCOMMON"] = "Uncommon"

-- 自行加入
L["DEJUNK"] = "Dejunk"

-- ============================================================================
-- Others
-- ============================================================================

if GetLocale() == "deDE" then
  
end

if GetLocale() == "esES" then
  
end

if GetLocale() == "esMX" then
  
end

if GetLocale() == "frFR" then
  
end

if GetLocale() == "itIT" then
  
end

if GetLocale() == "koKR" then
  
end

if GetLocale() == "ptBR" then
  
end

if GetLocale() == "ruRU" then

end

if GetLocale() == "zhCN" then
  L["ADD_ALL_TO_LIST"] = "全部添加至%s"
L["ADD_TO_LIST"] = "添加到%s"
L["ALL_ITEMS_REMOVED_FROM_LIST"] = "已从%s中移除所有物品。"
L["ALT_KEY"] = "Alt键"
L["AUTO_JUNK_FRAME_TEXT"] = "自动显示垃圾物品框架"
L["AUTO_JUNK_FRAME_TOOLTIP"] = "与商贩交互时自动切换垃圾框架"
L["AUTO_REPAIR_TEXT"] = "自动修理"
L["AUTO_REPAIR_TOOLTIP"] = "和商贩交互时自动修理物品。"
L["AUTO_SELL_TEXT"] = "自动出售"
L["AUTO_SELL_TOOLTIP"] = "与商人交互时自动售卖物品。"
L["BAG_ITEM_ICONS_TEXT"] = "背包内物品图标"
L["BAG_ITEM_ICONS_TOOLTIP"] = "在你背包内垃圾物品上叠加一个图标"
L["BAG_ITEM_TOOLTIPS_TEXT"] = "背包物品鼠标提示"
L["BAG_ITEM_TOOLTIPS_TOOLTIP"] = "给你背包里物品的鼠标提示中添加Dejunk信息。"
L["CANNOT_OPEN_LOOTABLE_ITEMS"] = "现在无法打开可开启的物品。"
L["CANNOT_SELL_OR_DESTROY_ITEM"] = "无法出售或摧毁%s。"
L["CANNOT_SELL_WITHOUT_MERCHANT"] = "没有商人，无法出售物品。"
L["CHANGE_VALUE"] = "更改数值"
L["CHARACTER"] = "角色"
L["CHARACTER_SPECIFIC_SETTINGS_TEXT"] = "角色专属设置"
L["CHARACTER_SPECIFIC_SETTINGS_TOOLTIP"] = "给此角色开启专属设置。"
L["CHAT_MESSAGES_TEXT"] = "聊天信息"
L["CHAT_MESSAGES_TOOLTIP"] = "开启聊天信息。"
L["CLEAR"] = "清除"
L["CLEAR_SEARCH"] = "清空搜索"
L["COMMAND_DESCRIPTION_DESTROY"] = "摧毁下一件物品。"
L["COMMAND_DESCRIPTION_HELP"] = "显示指令列表。"
L["COMMAND_DESCRIPTION_JUNK"] = "切换垃圾物品框架。"
L["COMMAND_DESCRIPTION_KEYBINDS"] = "打开按键绑定框架。"
L["COMMAND_DESCRIPTION_LOOT"] = "打开可开启的物品。"
L["COMMAND_DESCRIPTION_OPTIONS"] = "切换选项框架。"
L["COMMAND_DESCRIPTION_SELL"] = "开始出售垃圾物品。"
L["COMMAND_DESCRIPTION_TRANSPORT"] = "切换传输框架。"
L["COMMANDS"] = "指令"
L["COMMON"] = "普通"
L["CONTROL_KEY"] = "Ctrl键"
L["DESTROY"] = "摧毁"
L["DESTROY_NEXT_ITEM"] = "摧毁下一个物品"
L["DESTROYED_ITEM"] = "已摧毁：%s。"
L["DOES_NOT_APPLY_TO_SPECIAL_EQUIPMENT"] = "不应用于通用物品，装饰品或者钓鱼竿"
L["EPIC"] = "史诗"
L["EXCLUDE"] = "排除"
L["EXCLUDE_EQUIPMENT_SETS_TEXT"] = "排除装备方案"
L["EXCLUDE_EQUIPMENT_SETS_TOOLTIP"] = "排除已经保存到某个方案的装备。"
L["EXCLUDE_UNBOUND_EQUIPMENT_TEXT"] = "排除未绑定装备"
L["EXCLUDE_UNBOUND_EQUIPMENT_TOOLTIP"] = "排除未绑定装备"
L["EXCLUDE_WARBAND_EQUIPMENT_TEXT"] = "排除战团绑定装备"
L["EXCLUDE_WARBAND_EQUIPMENT_TOOLTIP"] = "排除可以放进战团银行的装备"
L["EXCLUSIONS_DESCRIPTION_GLOBAL"] = "本列表上的物品不会被当做垃圾，除非被%s包含。"
L["EXCLUSIONS_DESCRIPTION_PERCHAR"] = "此列表上的物品绝不会被当做垃圾。"
L["EXCLUSIONS_TEXT"] = "排除"
L["EXPORT"] = "导出"
L["FAILED_TO_DESTROY_ITEM"] = "摧毁%s失败。"
L["FAILED_TO_SELL_ITEM"] = "出售%s失败。"
L["GENERAL"] = "通用"
L["GLOBAL"] = "全局"
L["IMPORT"] = "导入"
L["INCLUDE"] = "包含"
L["INCLUDE_ARTIFACT_RELICS_TEXT"] = "包含神器圣物"
L["INCLUDE_ARTIFACT_RELICS_TOOLTIP"] = "包含神器圣物。"
L["INCLUDE_BELOW_ITEM_LEVEL_POPUP_HELP"] = "输入物品等级："
L["INCLUDE_BELOW_ITEM_LEVEL_TEXT"] = "包含低于物品等级"
L["INCLUDE_BELOW_ITEM_LEVEL_TOOLTIP"] = "包含物品等级低于设定值（%s）的装备"
L["INCLUDE_BY_QUALITY_TEXT"] = "按照品质包含"
L["INCLUDE_BY_QUALITY_TOOLTIP"] = "基于物品的品质进行大量包含"
L["INCLUDE_UNSUITABLE_EQUIPMENT_TEXT"] = "包含不可用装备"
L["INCLUDE_UNSUITABLE_EQUIPMENT_TOOLTIP"] = "包含护甲或者武器类型不适用于你的职业的装备"
L["INCLUSIONS_DESCRIPTION_GLOBAL"] = "此列表上的物品会被当做垃圾，除非被%s排除。"
L["INCLUSIONS_DESCRIPTION_PERCHAR"] = "此列表上的物品总是会被当做垃圾。"
L["INCLUSIONS_TEXT"] = "包含"
L["IS_BUSY_CONFIRMING_ITEMS"] = "确认物品中..."
L["IS_BUSY_SELLING_ITEMS"] = "出售物品中..."
L["ITEM_ADDED_TO_LIST"] = "已添加%s至%s。"
L["ITEM_ALREADY_ON_LIST"] = "\"%s已经存在于%s。"
L["ITEM_ID_DOES_NOT_EXIST"] = "ID为%s的物品不存在。"
L["ITEM_ID_FAILED_TO_PARSE"] = "ID为%s的物品无法解析，可能不存在。"
L["ITEM_IDS"] = "物品ID"
L["ITEM_IS_JUNK"] = "此物品是垃圾。"
L["ITEM_IS_LOCKED"] = "此物品被锁定。"
L["ITEM_IS_NOT_JUNK"] = "此物品不是垃圾。"
L["ITEM_IS_REFUNDABLE"] = "此物品可退款。"
L["ITEM_NOT_ON_LIST"] = "%s不存在于%s。"
L["ITEM_QUALITY_CHECK_BOX_TOOLTIP"] = "应用于这个品质的物品"
L["ITEM_REMOVED_FROM_LIST"] = "%s已从%s上移除。"
L["JUNK_FRAME_TOOLTIP"] = "你当前拥有的垃圾物品会被列在这个框架中。|n|n 若想要添加一个物品到%s中，拖动它到下方框架中。|n|n 若想要添加一个物品到%s中，按住%s并且拖动物品到下方框架中。"
L["JUNK_ITEMS"] = "垃圾物品"
L["KEYBINDS"] = "按键绑定"
L["LEFT_CLICK"] = "点击左键"
L["LIST_FRAME_TOOLTIP"] = "若要添加物品，拖放其到下方框架。"
L["LIST_FRAME_TRANSPORT_BUTTON_TOOLTIP"] = "切换此列表的传输框架。"
L["LISTS"] = "列表"
L["LOADING"] = "加载中"
L["MAY_NOT_HAVE_DESTROYED_ITEM"] = "可能没有摧毁%s。"
L["MAY_NOT_HAVE_SOLD_ITEM"] = "可能没有出售%s。"
L["MERCHANT_BUTTON_TEXT"] = "商人按钮"
L["MERCHANT_BUTTON_TOOLTIP"] = "在商人框架上启用按钮。"
L["MINIMAP_ICON_TEXT"] = "小地图图标"
L["MINIMAP_ICON_TOOLTIP"] = "开启小地图图标。"
L["NO_FILTERS_MATCHED"] = "无过滤器可匹配。"
L["NO_ITEMS"] = "没有物品。"
L["NO_JUNK_ITEMS_TO_DESTROY"] = "没有垃圾物品可摧毁。"
L["NO_JUNK_ITEMS_TO_SELL"] = "没有垃圾物品可出售。"
L["NO_LOOTABLE_ITEMS_TO_OPEN"] = "没有可开启的物品。"
L["OPEN_LOOTABLE_ITEMS"] = "打开可开启物品"
L["OPTION_WARNING_BE_CAREFUL"] = "请谨慎对待这个选项"
L["OPTIONS_TEXT"] = "选项"
L["POOR"] = "粗糙"
L["PROFIT"] = "获利：%s"
L["RARE"] = "精良"
L["REMOVE"] = "移除"
L["REMOVE_ALL_ITEMS"] = "移除所有物品"
L["REMOVE_FROM_LIST"] = "从%s移除"
L["REPAIRED_ALL_ITEMS"] = "已修理所有物品，共计%s。"
L["RESET_POSITION"] = "重置位置"
L["RIGHT_CLICK"] = "点击右键"
L["SAFE_MODE_TEXT"] = "安全模式"
L["SAFE_MODE_TOOLTIP"] = "一次最多出售12个物品。"
L["SEARCH_LISTS"] = "搜索列表"
L["SELECT_ALL"] = "选择所有"
L["SELL"] = "出售"
L["SHIFT_KEY"] = "Shift键"
L["SOLD_ITEM"] = "已出售：%s。"
L["START_SELLING"] = "开始出售"
L["TOGGLE_JUNK_FRAME"] = "切换垃圾物品框架"
L["TOGGLE_OPTIONS_FRAME"] = "切换选项框架"
L["TRANSPORT"] = "传输"
L["TRANSPORT_FRAME_TOOLTIP"] = "使用本框体将物品id导入或移出目标列表。|n|n当导入时, 物品id需要用非数字的字符隔开(例如： 4983,58907,67410)。"
L["UNCOMMON"] = "优秀"

end

if GetLocale() == "zhTW" then
L["ADD_ALL_TO_LIST"] = "全部加入 %s"
L["ADD_TO_LIST"] = "加入 %s"
L["ALL_ITEMS_REMOVED_FROM_LIST"] = "已從 %s 移除所有物品。"
L["ALT_KEY"] = "Alt"
L["AUTO_JUNK_FRAME_TEXT"] = "大量賣垃圾視窗"
L["AUTO_JUNK_FRAME_TOOLTIP"] = "與商人互動時自動顯示垃圾物品視窗。"
L["AUTO_REPAIR_TEXT"] = "自動修理"
L["AUTO_REPAIR_TOOLTIP"] = "與商人互動時自動修理。"
L["AUTO_SELL_TEXT"] = "自動賣出"
L["AUTO_SELL_TOOLTIP"] = "與商人互動時自動賣出物品。"
L["BAG_ITEM_ICONS_TEXT"] = "背包物品圖示"
L["BAG_ITEM_ICONS_TOOLTIP"] = "在背包中的垃圾物品上疊加圖示。"
L["BAG_ITEM_TOOLTIPS_TEXT"] = "背包物品提示"
L["BAG_ITEM_TOOLTIPS_TOOLTIP"] = "在背包物品的浮動提示資訊中加入大量賣垃圾資訊。"
L["CANNOT_OPEN_LOOTABLE_ITEMS"] = "目前無法開啟可拾取物品。"
L["CANNOT_SELL_OR_DESTROY_ITEM"] = "無法賣出或摧毀 %s。"
L["CANNOT_SELL_WITHOUT_MERCHANT"] = "沒有商人無法賣出物品。"
L["CHANGE_VALUE"] = "更改數值"
L["CHARACTER_SPECIFIC_SETTINGS_TEXT"] = "角色專用設定"
L["CHARACTER_SPECIFIC_SETTINGS_TOOLTIP"] = "啟用此角色專用設定。"
L["CHARACTER"] = "角色"
L["CHAT_MESSAGES_TEXT"] = "聊天訊息"
L["CHAT_MESSAGES_TOOLTIP"] = "啟用聊天訊息。"
L["CLEAR_SEARCH"] = "清除搜尋"
L["CLEAR"] = "清除"
L["COMMAND_DESCRIPTION_DESTROY"] = "摧毀下一個垃圾物品。"
L["COMMAND_DESCRIPTION_HELP"] = "顯示指令列表。"
L["COMMAND_DESCRIPTION_JUNK"] = "顯示垃圾物品視窗。"
L["COMMAND_DESCRIPTION_KEYBINDS"] = "開啟按鍵綁定視窗。"
L["COMMAND_DESCRIPTION_LOOT"] = "開啟可拾取物品。"
L["COMMAND_DESCRIPTION_OPTIONS"] = "顯示選項視窗。"
L["COMMAND_DESCRIPTION_SELL"] = "開始賣出垃圾物品。"
L["COMMAND_DESCRIPTION_TRANSPORT"] = "顯示傳輸視窗。"
L["COMMANDS"] = "指令"
L["COMMON"] = "普通"
L["CONTROL_KEY"] = "Ctrl"
L["DESTROY_NEXT_ITEM"] = "摧毀下一個物品"
L["DESTROY"] = "摧毀"
L["DESTROYED_ITEM"] = "已摧毀：%s。"
L["DOES_NOT_APPLY_TO_SPECIAL_EQUIPMENT"] = "不適用於通用、造型或釣魚竿物品。"
L["EPIC"] = "史詩"
L["EXCLUDE_EQUIPMENT_SETS_TEXT"] = "排除裝備管理員設定"
L["EXCLUDE_EQUIPMENT_SETS_TOOLTIP"] = "排除已儲存至裝備管理員的裝備。"
L["EXCLUDE_UNBOUND_EQUIPMENT_TEXT"] = "排除未綁定裝備"
L["EXCLUDE_UNBOUND_EQUIPMENT_TOOLTIP"] = "排除未綁定的裝備。"
L["EXCLUDE_WARBAND_EQUIPMENT_TEXT"] = "排除戰隊裝備"
L["EXCLUDE_WARBAND_EQUIPMENT_TOOLTIP"] = "排除可放入戰隊銀行中的裝備。"
L["EXCLUDE"] = "排除"
L["EXCLUSIONS_DESCRIPTION_GLOBAL"] = "此清單中的物品除非被 %s 包含，否則將不會被視為垃圾。"
L["EXCLUSIONS_DESCRIPTION_PERCHAR"] = "此清單中的物品永遠不會被視為垃圾。"
L["EXCLUSIONS_TEXT"] = "排除清單"
L["EXPORT"] = "匯出"
L["FAILED_TO_DESTROY_ITEM"] = "摧毀 %s 失敗。"
L["FAILED_TO_SELL_ITEM"] = "賣出 %s 失敗。"
L["GENERAL"] = "一般"
L["GLOBAL"] = "帳號"
L["IMPORT"] = "匯入"
L["INCLUDE_ARTIFACT_RELICS_TEXT"] = "包含神器聖物"
L["INCLUDE_ARTIFACT_RELICS_TOOLTIP"] = "包含神器聖物寶石。"
L["INCLUDE_BELOW_ITEM_LEVEL_POPUP_HELP"] = "輸入物品等級："
L["INCLUDE_BELOW_ITEM_LEVEL_TEXT"] = "包含低於此物品等級"
L["INCLUDE_BELOW_ITEM_LEVEL_TOOLTIP"] = "包含物品等級低於設定值 (%s) 的裝備。"
L["INCLUDE_BY_QUALITY_TEXT"] = "依品質包含"
L["INCLUDE_BY_QUALITY_TOOLTIP"] = "根據品質大量包含物品。"
L["INCLUDE_UNSUITABLE_EQUIPMENT_TEXT"] = "包含不適用裝備"
L["INCLUDE_UNSUITABLE_EQUIPMENT_TOOLTIP"] = "包含護甲或武器類型不適合您的職業的裝備。"
L["INCLUDE"] = "包含"
L["INCLUSIONS_DESCRIPTION_GLOBAL"] = "此清單中的物品除非被 %s 排除，否則將被視為垃圾。"
L["INCLUSIONS_DESCRIPTION_PERCHAR"] = "此清單中的物品永遠會被視為垃圾。"
L["INCLUSIONS_TEXT"] = "包含清單"
L["IS_BUSY_CONFIRMING_ITEMS"] = "正在確認物品…"
L["IS_BUSY_SELLING_ITEMS"] = "正在賣出物品…"
L["ITEM_ADDED_TO_LIST"] = "已將 %s 加入 %s。"
L["ITEM_ALREADY_ON_LIST"] = "%s 已在 %s 中。"
L["ITEM_ID_DOES_NOT_EXIST"] = "物品 ID %s 不存在。"
L["ITEM_ID_FAILED_TO_PARSE"] = "物品 ID %s 解析失敗，可能不存在。"
L["ITEM_IDS"] = "物品 ID"
L["ITEM_IS_JUNK"] = "此物品為垃圾。"
L["ITEM_IS_LOCKED"] = "物品已鎖定。"
L["ITEM_IS_NOT_JUNK"] = "此物品非垃圾。"
L["ITEM_IS_REFUNDABLE"] = "物品可退款。"
L["ITEM_NOT_ON_LIST"] = "%s 不在 %s 中。"
L["ITEM_QUALITY_CHECK_BOX_TOOLTIP"] = "適用於此品質的物品。"
L["ITEM_REMOVED_FROM_LIST"] = "已從 %s 移除 %s。"
L["JUNK_FRAME_TOOLTIP"] = "您目前擁有的垃圾物品將在此視窗中列出。|n|n若要將物品新增至 %s，請將其拖曳至下方視窗中。|n|n若要將物品新增至 %s，請按住 %s 並將其拖曳至下方視窗中。"
L["JUNK_ITEMS"] = "垃圾物品"
L["KEYBINDS"] = "按鍵綁定"
L["LEFT_CLICK"] = "左鍵"
L["LIST_FRAME_TOOLTIP"] = "若要新增物品，請將其拖曳至下方視窗中。"
L["LIST_FRAME_TRANSPORT_BUTTON_TOOLTIP"] = "顯示此清單的傳輸視窗。"
L["LISTS"] = "清單"
L["LOADING"] = "載入中"
L["MAY_NOT_HAVE_DESTROYED_ITEM"] = "可能未摧毀 %s。"
L["MAY_NOT_HAVE_SOLD_ITEM"] = "可能未賣出 %s。"
L["MERCHANT_BUTTON_TEXT"] = "商人按鈕"
L["MERCHANT_BUTTON_TOOLTIP"] = "在商人視窗上啟用一個按鈕。"
L["MINIMAP_ICON_TEXT"] = "小地圖按鈕"
L["MINIMAP_ICON_TOOLTIP"] = "在小地圖上啟用一個按鈕。"
L["NO_FILTERS_MATCHED"] = "無符合的過濾方式。"
L["NO_ITEMS"] = "沒有物品。"
L["NO_JUNK_ITEMS_TO_DESTROY"] = "沒有垃圾物品可摧毀。"
L["NO_JUNK_ITEMS_TO_SELL"] = "沒有垃圾物品可賣出。"
L["NO_LOOTABLE_ITEMS_TO_OPEN"] = "沒有可開啟的可拾取物品。"
L["OPEN_LOOTABLE_ITEMS"] = "開啟可拾取物品"
L["OPTION_WARNING_BE_CAREFUL"] = "請小心使用此選項。"
L["OPTIONS_TEXT"] = "選項"
L["POOR"] = "粗劣"
L["PROFIT"] = "利潤：%s"
L["RARE"] = "精良"
L["REMOVE_ALL_ITEMS"] = "移除所有物品"
L["REMOVE_FROM_LIST"] = "從 %s 移除"
L["REMOVE"] = "移除"
L["REPAIRED_ALL_ITEMS"] = "已修理所有物品，花費 %s。"
L["RESET_POSITION"] = "重設位置"
L["RIGHT_CLICK"] = "右鍵"
L["SAFE_MODE_TEXT"] = "安全模式"
L["SAFE_MODE_TOOLTIP"] = "每次最多賣出 12 個物品。"
L["SEARCH_LISTS"] = "搜尋清單"
L["SELECT_ALL"] = "全選"
L["SELL"] = "賣出"
L["SHIFT_KEY"] = "Shift"
L["SOLD_ITEM"] = "已賣出：%s。"
L["START_SELLING"] = "開始賣出"
L["TOGGLE_JUNK_FRAME"] = "顯示垃圾物品視窗"
L["TOGGLE_OPTIONS_FRAME"] = "顯示選項視窗"
L["TRANSPORT_FRAME_TOOLTIP"] = "使用此視窗將物品 ID 傳輸進出目標清單。|n|n匯入時，物品 ID 必須以非數字字元分隔 (例如 4983,58907,67410)。"
L["TRANSPORT"] = "傳輸"
L["UNCOMMON"] = "優良"

-- 自行加入
L["DEJUNK"] = "大量賣垃圾"

end
