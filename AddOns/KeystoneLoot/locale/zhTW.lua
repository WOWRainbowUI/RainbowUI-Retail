if (GetLocale() ~= 'zhTW') then
    return;
end

local AddonName, KeystoneLoot = ...;
local Translate = KeystoneLoot.Translate;


Translate['Left click: Open overview'] = '點一下查詢裝備';
Translate['Right click: Open settings'] = '右鍵: 設定選項';
Translate['Enable Minimap Button'] = '啟用小地圖按鈕';
Translate['Enable Loot Reminder'] = '啟用戰利品提醒';
Translate['Favorites Show All Specializations'] = '最愛顯示所有專精';
Translate['%s (%s Season %d)'] = '%s（%s 第 %d 賽季）';
Translate['Veteran'] = '精兵';    -- 探險者 Explorer 冒險者 Adventurer
Translate['Champion'] = '勇士';
Translate['Hero'] = '英雄';
Translate['Myth'] = '史詩';
Translate['Revival Catalyst'] = '重生育籃控制台';
Translate['Correct loot specialization set?'] = '是否有正確設定戰利品拾取專精?';
Translate['Show Item Level In Keystone Tooltip'] = '在鑰石的浮動提示中顯示物品等級';
Translate['Highlighting'] = '顯著標示';
Translate['No Stats'] = '沒有屬性';

-- 自行加入
Translate['KeystoneLoot'] = "職業適合裝備查詢"
