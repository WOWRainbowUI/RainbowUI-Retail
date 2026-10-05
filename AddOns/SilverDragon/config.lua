local core = LibStub("AceAddon-3.0"):GetAddon("SilverDragon")
local module = core:NewModule("Config", "AceConsole-3.0")

local lookNames = {
	Traditional = "傳統", Minimal = "極簡", Classic = "經典",
	Legendary = "傳說", SilverDragon = "銀龍", Store = "商城",
	StoreSilver = "商城（銀色）", Transmog = "塑形",
	Loot_MoreAwesome = "戰利品：華麗", Loot_LessAwesome = "戰利品：簡約",
	Loot_QuestReward = "戰利品：任務獎勵", Loot_Alliance = "戰利品：聯盟",
	Loot_Horde = "戰利品：部落", Loot_Azerite = "戰利品：艾澤萊晶",
	Loot_NZoth = "戰利品：恩若司", Loot_Oribos = "戰利品：奧睿博司",
}

function module.LookName(look)
	return lookNames[look] or look:gsub("_", ": ")
end

local function toggle(name, desc, order, inline, disabled)
	return {
		type = "toggle",
		name = name,
		desc = desc,
		order = order,
		descStyle = (inline or (inline == nil)) and "inline" or nil,
		width = (inline or (inline == nil)) and "full" or nil,
		disabled = disabled,
	}
end
module.toggle = toggle
local function desc(text, order)
	return {
		type = "description",
		name = text,
		order = order,
		fontSize = "medium",
	}
end
module.desc = desc

local options = {
	type = "group",
	name = "稀有怪獸與牠們的產地",
	get = function(info) return core.db.profile[info[#info]] end,
	set = function(info, v)
		core.db.profile[info[#info]] = v
		-- anything drawing from these has to be told; the map in particular keeps
		-- its pins up until something asks it to think again
		core.events:Fire("OptionsChanged", info[#info], v)
	end,
	args = {
		about = {
			type = "group",
			name = "關於",
			args = {
				about = desc("稀有怪通知會協助你尋找稀有怪。\n\n"..
						"要調整偵測方式，請前往「掃描」設定。"..
						"可以啟用或停用各種掃描方式，"..
						"並調整其運作方式。\n\n"..
						"要調整目標通知框的外觀，請前往「目標框架」"..
						"設定。\n\n"..
						"要調整發現稀有怪時的通知方式，請前往"..
						"「通知」設定。\n\n"..
						"要新增自訂掃描怪物，請前往「稀有怪 > 自訂」"..
						"設定。\n\n"..
						"要停止通知特定"..
						"怪物，請前往「稀有怪 > 忽略」。\n\n"..
						"要忽略特定寶藏，請前往「掃描 > 地圖星號」。"),
			},
			order = 0,
		},
		general = {
			type = "group",
			name = "一般",
			order = 10,
			args = {
				loot = {
					type = "group",
					name = "戰利品",
					inline = true,
					order = 10,
					args = {
						about = desc("設定如何判斷怪物掉落的戰利品。", 0),
						charloot = toggle("僅計算目前角色", "判斷稀有怪是否值得通知時，只計算目前角色可獲得的戰利品。戰利品視窗仍顯示全部物品，無法掉落給你的物品會另列在獨立區段。", 10),
						sharedloot = toggle("計算共用戰利品", "某些稀有怪與附近的其他稀有怪共用戰利品表。判斷是否值得通知時，將共用戰利品與專屬戰利品一併計算。", 15),
						sharedloot_alerts = toggle("共用戰利品也觸發提醒", "共用戰利品中有尚未取得的坐騎時，也會觸發坐騎音效、畫面閃爍與地圖圖示。", 16, nil, function() return not core.db.profile.sharedloot end),
						boeloot = toggle("計算可出售的重複收藏", "已擁有的坐騎、寵物或玩具若為裝備綁定，仍視為值得關注，因為可以出售。", 20),
						transmog_specific = toggle("塑形須取得相同物品", "只有從該件物品取得的塑形外觀才視為已收藏；從其他同外觀物品取得的不算。", 25),
					}
				},
			},
			plugins = {},
		},
		notable = {
			type = "group",
			name = "關注條件",
			order = 13,
			args = {
				about = desc("設定哪些內容值得關注。通知篩選、地圖標示與點擊選取目標巨集都會使用這些條件。", 0),
				achievement_notable = toggle(_G.TRANSMOG_SOURCE_5 or ACHIEVEMENTS or "成就", "將尚未完成的成就進度視為值得關注", 10),
				mount_notable = toggle(PERKS_VENDOR_CATEGORY_MOUNT or MOUNTS or "坐騎", "將尚未學會的坐騎視為值得關注的戰利品。此選項也決定哪些發現會觸發坐騎音效與畫面閃爍，不受篩選條件影響。", 20),
				toy_notable = toggle(TOY or "玩具", "將尚未收藏的玩具視為值得關注的戰利品", 30),
				pet_notable = toggle(TOOLTIP_BATTLE_PET or "戰寵", "將尚未收藏的寵物視為值得關注的戰利品", 40),
				transmog_notable = toggle("塑形外觀", "將尚未收藏的塑形外觀視為值得關注的戰利品。\n\n從其他物品取得的相同外觀是否算已收藏，由「一般 > 戰利品 > 塑形須取得相同物品」決定。", 50),
				decor_notable = toggle(_G.BINDING_TAG_DECOR or "裝飾", "將尚未取得的裝飾視為值得關注的戰利品", 60, nil, not _G.BINDING_TAG_DECOR),
				quest_notable = toggle("附帶任務", "將附帶未完成任務的物品視為值得關注的戰利品，包括許多可學習物品、每週聲望物品等。", 70),
				alts_achievements_count = toggle("計入其他角色成就", "其他角色已完成的成就視為已完成，不再當作尚待取得的成就。", 80),
			},
			plugins = {},
		},
		announcements = {
			type = "group",
			name = "通知",
			order = 17,
			args = {
				about = desc("設定發現稀有怪時的通知方式。", 0),
			},
			plugins = {},
		},
		scanning = {
			type = "group",
			name = "掃描",
			order = 20,
			args = {
				about = desc("稀有怪獸與牠們的產地就是用來掃描稀有怪獸的，這裡看到的選項都會套用到所有正在使用的掃描方法。每個方法也還有一些專用的選項，從左側點各自的方法來查看。", 0),
				scan = {
					type = "range",
					name = "掃描頻率",
					desc = "間隔多久時間要掃描一次附近的稀有怪，以秒為單位 (0 為停用掃描)",
					min = 0, max = 10, step = 0.1,
					order = 10,
				},
				delay = {
					type = "range",
					name = "保鮮期限",
					desc = "等待多久之後才會再次記錄相同的稀有怪",
					min = 30, max = (60 * 60), step = 10,
					order = 20,
				},
				dead = toggle("已死亡的稀有怪", "發現已死亡的稀有怪時仍記錄並通知。並非所有偵測方式都能判斷怪物是否已死亡。", 45),
				instances = toggle("在副本內掃描", "在副本內掃描並通知稀有怪。副本中的稀有怪不多，掃描可能會影響遊戲效能。", 50),
				taxi = toggle("搭乘飛行交通時掃描", "搭乘飛行交通或參加飛龍競速時持續掃描稀有怪。降落後返回時，牠可能已經不在了。", 55),
			},
			plugins = {},
		},
	},
	plugins = {
	},
}
module.options = options

function module:OnInitialize()
	options.plugins["profiles"] = {
		profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(core.db)
	}
	options.plugins.profiles.profiles.order = -1 -- last!

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SilverDragon", function()
		core.events:Fire("OptionsRequested", options)
		return options
	end)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SilverDragon", "稀有怪")
end

function module:ShowConfig(...)
	LibStub("AceConfigDialog-3.0"):Open("SilverDragon", ...)
end
