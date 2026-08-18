local core = LibStub("AceAddon-3.0"):GetAddon("SilverDragon")
local module = core:NewModule("Config", "AceConsole-3.0")

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
				about = desc("稀有怪獸與牠們的產地 - SilverDragon 會隨時為你注意稀有生物。\n\n"..
						"要更改監控的方式請到 \"掃描\" 設定。"..
						"可以啟用或停用幾種不同的用法，"..
						"以及調整一些選項。\n\n"..
						"要調整彈出的目標面板請到 \"目標框架\" "..
						"設定。\n\n"..
						"要更改發現稀有怪時的通知，請到 \"輸出\" "..
						"設定。\n\n"..
						"要新增自訂稀有怪來掃描，請看看 \"稀有怪\" 裡面的 \"自訂\" "..
						"設定。\n\n"..
						"如果你希望稀有怪和牠們的產地不要 不要 千萬不要再通知某些稀有怪，"..
						"請看看 \"稀有怪\" 裡面的 \"忽略\" 標籤頁面。"),
			},
			order = 0,
		},
		general = {
			type = "group",
			name = "一般",
			order = 10,
			args = {
				about = desc("稀有怪獸與牠們的產地會通知你一些訊息，查看這裡和子類別來調整通知的方式。", 0),
				loot = {
					type = "group",
					name = "戰利品",
					inline = true,
					-- last: both of these are fine-tuning, and everything the
					-- modules add to this section matters more than they do
					order = 110,
					args = {
						about = desc("Some options for how SilverDragon will treat loot drops from mobs", 0),
						charloot = toggle("Current character only", "Only show loot that should drop for your current character, and only count that loot towards a rare being worth announcing. Holding shift when showing loot will make non-character loot appear.", 10),
						sharedloot = toggle("Count shared loot", "Some rares draw on a loot table shared with others nearby. Count what's in it towards them being worth announcing, the same as their own loot.", 15),
						sharedloot_alerts = toggle("...for alerts?", "A shared mount you haven't got will earn the mount sound, flash and map icon as well, rather than just being notable.", 16, nil, function() return not core.db.profile.sharedloot end),
						boeloot = toggle("Count sellable duplicates", "A mount, pet or toy you already have still counts as notable if it's bind-on-equip, since you can sell it.", 20),
						transmog_specific = toggle("Transmog exact items", "For transmog appearances, only count them as known if you know them from that exact item, rather than from another sharing the same appearance", 25),
					}
				},
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
				dead = toggle("Dead rares", "Count a rare that's already dead when we spot it, and tell you about it. Not every way of spotting them can tell whether one is dead.", 45),
				instances = toggle("Scan in instances", "Look for rares while you're in an instance, and tell you about the ones we find. There aren't that many actual rares in instances, and scanning might slow things down at a time when you'd like the most performance possible.", 50),
				taxi = toggle("Scan on taxis", "Keep scanning for rares while flying on a taxi or in a dragon race. Just hope that it'll still be there after you land and make your way back...", 55),
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
