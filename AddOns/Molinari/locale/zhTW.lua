local L = select(2, ...).L('zhTW')

L['ALT key'] = _G.ALT_KEY
L['ALT + CTRL key'] = _G.ALT_KEY_TEXT .. ' + ' .. _G.CTRL_KEY
L['ALT + SHIFT key'] = _G.ALT_KEY_TEXT .. ' + ' .. _G.SHIFT_KEY
L['You can\'t do that while in combat'] = _G.ERR_NOT_IN_COMBAT

-- config
L['Modifier to activate %s'] = '分解時要按住的輔助鍵'
L['Item Blocklist'] = '忽略物品清單'
L['Block Item'] = '忽略物品'
L['Items in this list will not be processed.'] = '清單中的物品不會被處理。'
L['Block a new item by ID'] = '輸入要忽略的物品 ID'
L['Accept'] = OKAY
L['Cancel'] = CANCEL
L['Invalid Item'] = "無效的物品"

L['Molinari'] = '專業-分解'
L['Molinari '] = '一鍵分解物品'
L['Molinari: Invalid item ID'] = '一鍵分解物品: 無效的物品 ID'
