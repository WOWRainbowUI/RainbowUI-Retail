-- StufLocale.lua
-- Localization for the Stuf core addon
-- Original zhTW: 彩虹ui (2016/9/6)
-- Original zhCN: 敌羞吾去脱她衣 (2023/7/23)
-- deDE, frFR, koKR, ruRU, esES, esMX, itIT, ptBR: generated 2026/3/17

-- English is the default/fallback — no block needed for enUS.

-- ============================================================
-- Traditional Chinese (zhTW) — original by 彩虹ui
-- ============================================================
if ( GetLocale() == "zhTW" ) then
StufLocalization = {
	["|cff00ff00Stuf|r: "] = "|cff00ff00Stuf頭像|r：",
	["Cannot load Stuf while in combat."] = "戰鬥中無法載入。",
	["Settings copied to this character."] = "已複製設定到這個角色。",
	["Stuf_Options is required to initialize variables."] = "需要載入 Stuf頭像-設定選項 模組。",
	["Stuf_Options not found."] = "無法找到 Stuf頭像-設定選項 模組。",
	["%s is using version %s."] = "%s 目前正在使用的版本是 %s。",
	["Humanoid"] = "人形生物",
	["Stuf"] = "Stuf 頭像",
	["Inspect"] = "快速互動",
	[" <Left-click> to inspect.\n"] = " <左鍵> 觀察\n",
	[" <Middle-click> to note target.\n"] = " <中鍵> 密語\n",
	[" <Right-click> to dressup."] = " <右鍵> 交易\n <按鍵4> 跟隨",
	["|cfffed100Stuf|cffffffff Unit Frames"] = "|cfffed100Stuf|cffffffff 頭像框架",
	["|cffffffffLeft-click|r       Toggle config/drag mode"] = "|cffffffff左鍵|r       切換配置/拖曳模式",
	["|cffffffffRight-click|r      Open Stuf options"] = "|cffffffff右鍵|r       開啟設定選項",
	["|cffffffffAlt+Right-click|r Open StufRaid config"] = "|cffffffffAlt+右鍵|r   開啟 StufRaid 設定",
}

-- ============================================================
-- Simplified Chinese (zhCN) — original by 敌羞吾去脱她衣
-- ============================================================
elseif ( GetLocale() == "zhCN" ) then
StufLocalization = {
	["|cff00ff00Stuf|r: "] = "|cff00ff00Stuf头像|r：",
	["Cannot load Stuf while in combat."] = "战斗中无法载入。",
	["Settings copied to this character."] = "已复制设置到这个角色。",
	["Stuf_Options is required to initialize variables."] = "需要载入 Stuf头像-设置选项 模组。",
	["Stuf_Options not found."] = "无法找到 Stuf头像-设置选项 模组。",
	["%s is using version %s."] = "%s 目前正在使用的版本是 %s。",
	["Humanoid"] = "人形生物",
	["Stuf"] = "Stuf 头像",
	["Inspect"] = "快速互动",
	[" <Left-click> to inspect.\n"] = " <左键> 观察\n",
	[" <Middle-click> to note target.\n"] = " <中键> 密语\n",
	[" <Right-click> to dressup."] = " <右键> 交易\n <按键4> 跟随",
	["|cfffed100Stuf|cffffffff Unit Frames"] = "|cfffed100Stuf|cffffffff 头像框架",
	["|cffffffffLeft-click|r       Toggle config/drag mode"] = "|cffffffff左键|r       切换配置/拖拽模式",
	["|cffffffffRight-click|r      Open Stuf options"] = "|cffffffff右键|r       打开设置选项",
	["|cffffffffAlt+Right-click|r Open StufRaid config"] = "|cffffffffAlt+右键|r   打开 StufRaid 设置",
}
end
