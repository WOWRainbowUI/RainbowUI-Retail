local AddonName, Addon = ...;
Addon.API = {};


local clientLocale = GetLocale();
local translation = {};


if (clientLocale == 'zhCN') then
	translation = {
		['Left click: Open overview'] = '左键点击：打开概览',
		['Right click: Open settings'] = '右键点击：打开设置',
		['Enable Minimap Button'] = '启用小地图按钮',
		['%s (%s Season %d)'] = '%s（%s 第 %d 赛季）',
		['Veteran'] = '老兵',
		['Champion'] = '勇士',
		['Hero'] = '英雄',
		['Great Vault'] = RATED_PVP_WEEKLY_VAULT,
		['Revival Catalyst'] = '复苏化生台'
	};
elseif (clientLocale == 'zhTW') then
	translation = {
		['Left click: Open overview'] = '點一下打開主視窗',
		['Right click: Open settings'] = '右鍵: 設定選項',
		['Enable Minimap Button'] = '啟用小地圖按鈕',
		['%s (%s Season %d)'] = '%s (%s第%d季)',
		['Veteran'] = '精兵',
		['Champion'] = '勇士',
		['Hero'] = '英雄',
		['Great Vault'] = RATED_PVP_WEEKLY_VAULT,
		['Revival Catalyst'] = '重生育籃控制台',
		
		-- 自行加入
		['Keystone Loot'] = "M+ 裝備查詢",
	};
else
	translation = {
		['Dawn of the Infinite: Galakrond\'s Fall'] = 'Galakrond\'s Fall',
		['Dawn of the Infinite: Murozond\'s Rise'] = 'Murozond\'s Rise'
	};
end


Addon.API.Translate = setmetatable(translation, {
	__index = function (t, key)
		rawset(t, key, key);
		return key;
	end
});
