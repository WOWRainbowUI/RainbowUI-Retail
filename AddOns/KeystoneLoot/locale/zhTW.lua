if (GetLocale() ~= 'zhTW') then
    return;
end

local AddonName, Addon = ...;
local Translate = Addon.Translate;


Translate['Left click: Open overview'] = '點一下查詢裝備';
Translate['Right click: Open settings'] = '右鍵: 設定選項';
Translate['Enable Minimap Button'] = '啟用小地圖按鈕';
Translate['Enable Loot Reminder'] = '啟用戰利品提醒';
Translate['%s (%s Season %d)'] = '%s（%s 第 %d 賽季）';
Translate['Veteran'] = '老兵';
Translate['Champion'] = '勇士';
Translate['Hero'] = '英雄';
Translate['Great Vault'] = RATED_PVP_WEEKLY_VAULT;
Translate['Revival Catalyst'] = '重生育籃控制台';
Translate['Correct loot specialization set?'] = '是否有正確設定戰利品拾取專精?';

-- 自行加入
Translate['KeystoneLoot'] = "M+ 裝備查詢"