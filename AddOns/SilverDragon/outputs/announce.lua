local myname, ns = ...

local core = LibStub("AceAddon-3.0"):GetAddon("SilverDragon")
local module = core:NewModule("Announce", "AceTimer-3.0", "LibSink-2.0")
local Debug = core.Debug

local L = {}
L["chat"] = "聊天"
L["fake"] = "假的"
L["mouseover"] = "滑鼠指向"
L["target"] = "目標"
L["grouptarget"] = "隊友目標"
L["vignette"] = "地圖星號"
L["macro"] = "巨集"
L["nameplate"] = "血條"
L["point-of-interest"] = "探索點"
L["GUILD"] = "公會"
L["PARTY"] = "隊伍"
L["RAID"] = "團隊"
L["groupsync"] = "隊伍同步"
L["guildsync"] = "公會同步"

local LSM = LibStub("LibSharedMedia-3.0")
local HBD = LibStub("HereBeDragons-2.0")

-- testing snippet:
-- /script C_Timer.After(2, function() SilverDragon:GetModule("Announce"):Seen("_", 32491, 120, 0.490, 0.362, false, "fake") end)

-- Register some media
LSM:Register("sound", "Rubber Ducky", 566121)
LSM:Register("sound", "Cartoon FX", 566543)
LSM:Register("sound", "Explosion", 566982)
LSM:Register("sound", "Shing!", 566240)
LSM:Register("sound", "Wham!", 566946)
LSM:Register("sound", "Simon Chime", 566076)
LSM:Register("sound", "War Drums", 567275)--NPC Scan default
LSM:Register("sound", "Scourge Horn", 567386)--NPC Scan default
LSM:Register("sound", "Dwarf Horn", 566064)
LSM:Register("sound", "Pygmy Drums", 566508)
LSM:Register("sound", "Cheer", 567283)
LSM:Register("sound", "Humm", 569518)
LSM:Register("sound", "Short Circuit", 568975)
LSM:Register("sound", "Fel Portal", 569215)
LSM:Register("sound", "Fel Nova", 568582)
LSM:Register("sound", "PVP Flag", 569200)
LSM:Register("sound", "PvP Flag Horde", 568165) -- PVPFlagTakenHorde
LSM:Register("sound", "Thunder crack", 566202) -- doodad/fx_thundercrack04.ogg
LSM:Register("sound", "Algalon: Beware!", 543587)
LSM:Register("sound", "Yogg Saron: Laugh", 564859)
LSM:Register("sound", "Illidan: Not Prepared", 552503)
LSM:Register("sound", "Magtheridon: I am Unleashed", 554554)
LSM:Register("sound", "Loatheb: I see you", 554236)
LSM:Register("sound", "Ikiss: Trinkets", 561403)
LSM:Register("sound", "Kobold: Not junk", 5726692)
LSM:Register("sound", "NPCScan", 567275)--Sound file is actually bogus, this just forces the option NPCScan into menu. We hack it later.
LSM:Register("sound", "PvP Alliance", 568320) -- PVPWarningAllianceLong
LSM:Register("sound", "PvP Horde", 569112) -- PVPWarningHordeLong
LSM:Register("sound", "Grimrail Train Horn", 1023633)
LSM:Register("sound", "Squire Horn", 598079)
LSM:Register("sound", "Gruntling Horn", 598196)

function module:OnInitialize()
	self.db = core.db:RegisterNamespace("Announce", {
		profile = {
			sink = true,
			drums = true,
			sound = true,
			soundgroup = true,
			soundguild = false,
			sound_mount = true,
			sound_boss = true,
			sound_loot = true,
			sound_loot_junk = true,
			soundfile = "Loatheb: I see you",
			soundfile_mount = "Illidan: Not Prepared",
			soundfile_boss = "Magtheridon: I am Unleashed",
			soundfile_loot = "Ikiss: Trinkets",
			soundfile_loot_junk = "Kobold: Not junk",
			sound_loop = 1,
			sound_mount_loop = 1,
			sound_boss_loop = 1,
			sound_loot_loop = 1,
			sound_loot_junk_loop = 1,
			flash = true,
			flash_texture = "Blizzard Low Health",
			flash_color = {r=1,g=0,b=1,a=1,},
			flash_mount = true,
			flash_texture_mount = "Blizzard Low Health",
			flash_color_mount = {r=0,g=1,b=0,a=1,},
			flash_boss = false,
			flash_texture_boss = "Blizzard Low Health",
			flash_color_boss = {r=1,g=0,b=1,a=1,},
			vibrate = true,
			vibrate_type = "High",
			vibrate_intensity = 1,
			vibrate_mount = true,
			vibrate_type_mount = "Low",
			vibrate_intensity_mount = 1,
			vibrate_boss = true,
			vibrate_type_boss = "High",
			vibrate_intensity_boss = 1,
			vibrate_loot = true,
			vibrate_type_loot = "High",
			vibrate_intensity_loot = 0.8,
			filter = "notable", -- none | notable | everything
			filter_loot = "everything", -- none | notable | everything
			-- the already* keys this replaced are deliberately absent: they only
			-- exist now as migration input, and giving them defaults would make
			-- an un-migrated profile indistinguishable from a fresh one
			sink_opts = {sink20OutputSink="UIErrorsFrame"},
			channel = "Music", -- 更改預設值
			unmute = false,
			background = false,
		},
	})
	self.db.RegisterCallback(self, "OnProfileChanged", "MigrateFilterOptions")
	self.db.RegisterCallback(self, "OnProfileCopied", "MigrateFilterOptions")
	self.db.RegisterCallback(self, "OnProfileReset", "MigrateFilterOptions")

	self:SetSinkStorage(self.db.profile.sink_opts)

	local removeSinks = {Channel=true}
	if self.db.profile.sink_opts.sink20OutputSink == "Channel" then
		-- 8.2.5 / Classic removed the ability to output to channels, outside of hardware-driven events
		self.db.profile.sink_opts.sink20OutputSink = "UIErrorsFrame"
	end
	if LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_MIDNIGHT then
		removeSinks.Blizzard = true
		removeSinks.Default = true
		-- 12.0.0 has given Blizzard SCT extreme breakage
		if
			-- Default uses Blizzard scrolling combat if it's available
			not self.db.profile.sink_opts.sink20OutputSink or
			self.db.profile.sink_opts.sink20OutputSink == "Default" or
			-- ...and this is just directly saying to send it to Blizzard's scrolling combat
			self.db.profile.sink_opts.sink20OutputSink == "Blizzard"
		then
			self.db.profile.sink_opts.sink20OutputSink = "UIErrorsFrame"
		end
	end

	self:MigrateFilterOptions()

	core.RegisterCallback(self, "Seen")
	core.RegisterCallback(self, "SeenLoot")

	local config = core:GetModule("Config", true)
	if config then
		local toggle = config.toggle
		local get = function(info) return self.db.profile[info[#info]] end
		local set = function(info, v) self.db.profile[info[#info]] = v end

		-- Singling a mount out asks the same question the filter does, so say so
		-- wherever that happens -- it's not obvious from here that a checkbox in
		-- another section can switch these off.
		local mountNote = "\n\nWhich mounts count comes from the Mount option under \"What's notable?\": one you already know only counts if it's BoE, and with that unticked this stops happening at all."

		local sink_config = self:GetSinkAce3OptionsDataTable()
		local sink_args = {}
		for k,v in pairs(sink_config.args) do
			if not removeSinks[k] then
				sink_args[k] = v
			end
		end
		sink_config.args = sink_args
		sink_config.inline = true
		sink_config.order = 15

		local faker = function(id, name, zone, x, y)
			return {
				type = "execute", name = name,
				desc = "假裝看到 " .. name,
				func = function()
					-- id, zone, x, y, is_dead, source, unit
					core.events:Fire("Seen", id, zone, x, y, false, "fake", false)
				end,
			}
		end
		local soundfile = function(enabled_key, order)
			return {
				type = "select", dialogControl = "LSM30_Sound",
				name = "播放音效", desc = "選擇要播放的音效",
				values = LSM:HashTable("sound"),
				disabled = function() return not self.db.profile[enabled_key] end,
				order = order,
			}
		end
		local soundrange = function(order)
			return {
				type = "range",
				name = "重複...",
				desc = "音效重複播放的次數",
				min = 1, max = 10, step = 1,
				order = order,
			}
		end
		local colorget = function(info)
			local color = self.db.profile[info[#info]]
			return color.r, color.g, color.b, color.a
		end
		local colorset = function(info, r, g, b, a)
			local color = self.db.profile[info[#info]]
			color.r, color.g, color.b, color.a = r, g, b, a
		end

		local fake_args = {
			-- this is a vanilla mob
			deathmaw = faker(10077, "死亡之喉 (可馴服!)", 29, 0.5, 0.5),
		}
		if LE_EXPANSION_LEVEL_CURRENT >= (LE_EXPANSION_WRATH_OF_THE_LICH_KING or 999) then
			fake_args.time = faker(32491, "時光流逝元龍 (坐騎!)", 120, 0.490, 0.362)
			fake_args.vyragosa = faker(32630, "維拉苟莎 (無趣)", 120, 0.5, 0.5)
		end
		if not ns.CLASSIC then
			-- id, name, zone, x, y, is_dead, is_new_location, source, unit
			-- ishak = faker(157134, "Ishak of the Four Winds (Mount!)", 1527, 0.73, 0.83)
			fake_args.anger = faker(60491, "憤怒之煞 (首領!)", 809, 0.5, 0.5)
			-- haakun = faker(83008, "『盡噬者』赫昆", 946, 0.5, 0.5)
			fake_args.yiphrim = faker(157473, "『意志劫毀者』伊弗林 (玩具!)", 1527, 0.5, 0.786)
			fake_args.amalgamation = faker(157593, "血肉融合體 (寵物!)", 1527, 0.598, 0.724)
			-- alash = faker(148787, "Alash'anir", 62, 0.598, 0.724)
			-- burninator = faker(149141, "Burninator Mk V (Pet!)", 62, 0.414, 0.764)
			fake_args.worldedge = faker(160821, "世界邊緣吞食者 (坐騎)", 1525, 0.5, 0.5)
			fake_args.tarahna = faker(126900, "講師塔拉娜 (多個玩具)", 882, 0.5, 0.5)
			fake_args.nerissa = faker(162690, "奈里莎·無心 (坐騎)", 1536, 0.5, 0.5)
			-- faeflayer = faker(171688, "Faeflayer", 1536, 0.5, 0.5)
			fake_args.scrapking = faker(151625, "廢料王 (物品)", 1462, 0.5, 0.5)
			fake_args.kash = faker(159105, "收藏者卡許 (很多物品)", 1536, 0.5, 0.5)
			-- worldcracker = faker(180032, "Wild Worldcracker", 1961, 0.5, 0.5)
			-- blanchy = faker(173468, "Dead Blanchy", 1525, 0.5, 0.5)
			fake_args.chest = {
				type = "execute", name = "浸水的箱子",
				desc = "假裝看到浸水的箱子",
				func = function()
					-- id, zone, x, y, instanceid
					core.events:Fire("SeenLoot", "浸水的箱子", 3341, 37, 0.318, 0.628)
				end
			}
			fake_args.mount_chest = {
				type = "execute", name = "Mawsworn Supply Chest (mount)",
				desc = "Fake seeing a Mawsworn Supply Chest, which contains a mount",
				func = function()
					-- id, zone, x, y, instanceid
					core.events:Fire("SeenLoot", "Mawsworn Supply Chest", 4969, 1970, 0.318, 0.628)
				end
			}
		end

		local filter_values = {
			none = "None",
			notable = "Notable ones",
			everything = "All of them",
		}
		-- least noisy first, so the list reads as a scale
		local filter_sorting = {"none", "notable", "everything"}

		local options = {
			general = {
				type = "group", name = "通報", inline = true,
				order = 10,
				get = get, set = set,
				args = {
					filter = {
						type = "select", name = "Which rares?",
						desc = "\"Notable ones\" leaves out a rare once it has nothing left for you. What counts as worth having is up to you, below.\n\nWhether loot that can't drop for you counts is up to \"Current character only\", over in General's Loot options. Rares we know nothing about are always announced.",
						values = filter_values, sorting = filter_sorting,
						order = 0, width = "double",
					},
					filter_loot = {
						type = "select", name = "Which treasures?",
						desc = "\"Notable ones\" leaves out a treasure once it has nothing left for you. What counts as worth having is up to you, below.\n\nWhether loot that can't drop for you counts is up to \"Current character only\", over in General's Loot options. Treasures we know nothing about are always announced.",
						values = filter_values, sorting = filter_sorting,
						order = 1, width = "double",
					},
				},
			},
			notable = {
				type = "group", name = "What's notable?", inline = true,
				desc = "Define exactly what counts as being \"notable\"",
				order = 12,
				-- these live on the core profile, because the shared rewards
				-- system reads them and other parts of SilverDragon can use them
				get = function(info) return core.db.profile[info[#info]] end,
				set = function(info, v)
					core.db.profile[info[#info]] = v
					core.events:Fire("OptionsChanged", info[#info], v)
				end,
				-- Deliberately not disabled when neither filter is "notable": Mount
				-- still decides which sightings earn the mount sound and flash, and
				-- greying out something that's still doing work is worse than
				-- leaving it alone.
				args = {
					-- these globals don't all exist in the classic clients, hence
					-- the fallbacks
					achievement_notable = toggle(_G.TRANSMOG_SOURCE_5 or ACHIEVEMENTS or "Achievement", "Count unearned achievement-progress as notable", 10),
					mount_notable = toggle(PERKS_VENDOR_CATEGORY_MOUNT or MOUNTS or "Mount", "Count unlearned mounts as notable loot. This also picks which sightings get the mount sound and flash, whatever the filters above say", 20),
					toy_notable = toggle(TOY or "Toy", "Count unlearned toys as notable loot", 30),
					pet_notable = toggle(TOOLTIP_BATTLE_PET or "Battle Pet", "Count uncaught pets as notable loot", 40),
					transmog_notable = toggle("Transmog", "Count unlearned transmogrification appearances as notable loot.\n\nWhether an appearance you know from some other item counts as known here is up to \"Transmog exact items\", over in General's Loot options", 50),
					decor_notable = toggle(_G.BINDING_TAG_DECOR or "Decor", "Count unfound decor as notable loot", 60, nil, not _G.BINDING_TAG_DECOR),
					quest_notable = toggle("Quest-attached", "Count items with attached uncompleted quests as notable loot (this includes a lot of \"learnable\" items, weekly reputation drops, etc)", 70),
					alts_achievements_count = toggle("An alt counts", "Treat an achievement one of your other characters has completed as done, rather than as something still to earn", 80),
				},
			},
			message = {
				type = "group", name = "訊息",
				order = 20,
				get = get, set = set,
				args = {
					sink = toggle("啟用", "傳送訊息到你正在使用的任何一種捲動文字插件。", 10),
					output = sink_config,
				},
			},
			test = {
				type = "group", name = "測試!",
				inline =  true,
				args = fake_args,
			},
			sound = {
				type = "group", name = "音效",
				get = get, set = set,
				order = 10,
				args = {
					about = config.desc("發現稀有怪時要播放音效通知? 特別的稀有怪還可以有特別音效。*絕對* 不會讓你錯過... 像是... 時光流逝元龍，絕對不會...", 0),
					channel = {
						type = "select",
						name = _G.SOUND_CHANNELS or _G.AUDIO_CHANNELS, -- dragonflight
						descStyle = "inline",
						values = {
							Ambience = _G.AMBIENCE_VOLUME,
							Master = "主音量",
							Music = _G.MUSIC_VOLUME,
							SFX = _G.SOUND_VOLUME or _G.FX_VOLUME,
							Dialog = _G.DIALOG_VOLUME,
						},
						order = 11,
					},
					test = {
						type = "execute",
						name = "測試!",
						image = "interface/common/voicechat-speaker",
						func = function()
							module:PlaySound{
								soundfile = module.db.profile.soundfile,
								loops = module.db.profile.sound_loop
							}
						end,
						order = 11,
					},
					unmute = toggle("忽略靜音", "就算遊戲靜音時也要播放音效", 12),
					background = toggle(_G.ENABLE_BGSOUND, _G.OPTION_TOOLTIP_ENABLE_BGSOUND, 13),
					drums = toggle("鼓聲", "搭配鼓聲更有氣氛", 14),
					soundgroup = toggle("隊伍同步音效", "從隊伍/團隊成員同步稀有怪時播放音效", 15),
					soundguild = toggle("公會同步音效", "從不在隊伍中的公會成員同步稀有怪時播放音效", 16),
					regular = {type="header", name="", order=20,},
					sound = toggle("音效", "一般稀有怪播放音效", 21),
					soundfile = soundfile("sound", 22),
					sound_loop = soundrange(23),
					mount = {type="header", name="", order=25,},
					sound_mount = toggle("Mount sounds", "Play a sound for mobs that drop a mount" .. mountNote, 26),
					soundfile_mount = soundfile("sound_mount", 27),
					sound_mount_loop = soundrange(28),
					boss = {type="header", name="", order=30,},
					sound_boss = toggle("首領音效", "需要組隊擊殺的稀有怪播放音效", 31),
					soundfile_boss = soundfile("sound_boss", 35),
					sound_boss_loop = soundrange(37),
					loot = {type="header", name="", order=40,},
					sound_loot = toggle("Loot sounds", "Play a sound for notable treasures", 41),
					soundfile_loot = soundfile("sound_loot", 45),
					sound_loot_loop = soundrange(47),
					sound_loot_junk = toggle("Junk loot sounds", "Play a sound for treasures that aren't notable. Only reachable when the treasures filter, over in Announcements, is set to \"All of them\"", 48),
					soundfile_loot_junk = soundfile("sound_loot_junk", 49),
					sound_loot_junk_loop = soundrange(50),
				},
			},
			flash = {
				type = "group", name = "閃爍畫面",
				get = get, set = set,
				order = 15,
				args = {
					about = config.desc("發現稀有怪時閃爍遊戲畫面", 0),
					flash = toggle("啟用", "閃爍畫面?", 1),
					flash_color = {
						name = COLOR,
						type = "color",
						hasAlpha = true,
						descStyle = "inline",
						get = colorget,
						set = colorset,
						order = 2,
					},
					flash_texture = {
						name = TEXTURES_SUBHEADER,
						type = "select",
						descStyle = "inline",
						dialogControl = "LSM30_Background",
						values = AceGUIWidgetLSMlists.background,
						order = 3,
					},
					preview = {
						name = PREVIEW,
						type = "execute",
						func = function()
							module:Flash(50065) -- Armagedillo
						end,
						order = 4,
					},
					mount = {type="header", name="", order=10,},
					flash_mount = toggle("Mount flash", "Flash the screen differently when we see a mob with a mount?" .. mountNote, 11),
					flash_color_mount = {
						name = COLOR,
						type = "color",
						hasAlpha = true,
						descStyle = "inline",
						get = colorget,
						set = colorset,
						order = 12,
					},
					flash_texture_mount = {
						name = TEXTURES_SUBHEADER,
						type = "select",
						descStyle = "inline",
						dialogControl = "LSM30_Background",
						values = AceGUIWidgetLSMlists.background,
						order = 13,
					},
					preview_mount = {
						name = PREVIEW,
						type = "execute",
						func = function()
							module:Flash(32491) -- time lost
						end,
						order = 14,
					},
					boss = {type="header", name="", order=20,},
					flash_boss = toggle("首領閃爍", "發現首領級的稀有怪時，用不同的方式閃爍?", 21),
					flash_color_boss = {
						name = COLOR,
						type = "color",
						hasAlpha = true,
						descStyle = "inline",
						get = colorget,
						set = colorset,
						order = 22,
					},
					flash_texture_boss = {
						name = TEXTURES_SUBHEADER,
						type = "select",
						descStyle = "inline",
						dialogControl = "LSM30_Background",
						values = AceGUIWidgetLSMlists.background,
						order = 23,
					},
					preview_boss = {
						name = PREVIEW,
						type = "execute",
						func = function()
							module:Flash(70096) -- War-God Dokah
						end,
						order = 24,
					},
				},
			},
			controller = {
				type = "group", name = "搖桿",
				get = get, set = set,
				disabled = function(info) return info[#info] ~= "controller" and not C_GamePad.IsEnabled() end,
				order = 15,
				args = {
					about = config.desc("發現稀有怪時震動已連接的搖桿，只有已經啟用搖桿支援性時才有效果。在聊天視窗輸入 `/console GamePadEnable 1` 可以啟用搖桿。", 0),
				},
			},
		}

		local function vibrate_section(t, key, order, heading, description)
			key = key and ("_"..key) or ""
			if heading then
				t["vibrate_heading" .. key] = {type="header", name="", order=order,}
			end
			t["vibrate" .. key] = toggle(heading or "Vibrate", description or "Vibrate the controller?", order + 1)
			t["vibrate_type" .. key] = {
				type = "select", name = "類型",
				desc = "使用哪種震動類型",
				values = {
					Low = "低",
					High = "高",
					LTrigger = "左板機 (PS5 限定)",
					RTrigger = "右板機 (PS5 限定)",
				},
				order = order + 2,
			}
			t["vibrate_intensity" .. key] = {
				type = "range", name = "強度",
				desc = "震動強度要多少",
				min = 0, max = 1, step = 0.1,
				order = order + 3,
			}
			t["preview" .. key] = {
				type = "execute", name = PREVIEW,
				func = function(info)
					C_GamePad.SetVibration(self.db.profile["vibrate_type" .. key], self.db.profile["vibrate_intensity" .. key])
				end,
				order = order + 4,
			}
			return order + 5
		end
		local order = 1
		order = vibrate_section(options.controller.args, nil, 1)
		order = vibrate_section(options.controller.args, "mount", order, "Vibrate for mounts", "Vibrate the controller?" .. mountNote)
		order = vibrate_section(options.controller.args, "boss", order, "Vibrate for bosses")
		order = vibrate_section(options.controller.args, "loot", order, "Vibrate for loot")

		config.options.args.general.plugins.announce = options
	end
end

-- Move a profile's old announcement options onto the two filters.
--
-- Each group keys off whether its old options are stored at all, because AceDB
-- doesn't store a value matching its default: someone who only changed
-- already_transmog has no stored `already`, and someone who left the Treasures
-- toggle alone has no stored `loot`. Hence `== false` for the ones that used to
-- default to true. Clearing the old keys is what stops this running twice, as
-- none of them have defaults any more.
--
-- This runs on profile change as well as at load: profiles are switched long
-- after OnInitialize, and an old one would otherwise keep its old keys and
-- silently fall back to the default filters.
function module:MigrateFilterOptions()
	local p = self.db.profile
	if p.already ~= nil or p.already_drop ~= nil or p.already_transmog ~= nil or p.already_alt ~= nil then
		-- `already` meant "don't filter on completion at all", so it's the only one
		-- that maps to anything other than the default. already_drop asked for loot
		-- you own to silence a rare, which is what the notable filter does anyway,
		-- so it needs nothing beyond being cleared away here.
		p.filter = p.already and "everything" or "notable"
		-- already_transmog deliberately doesn't carry over. It read as "count
		-- appearances when working out whether you already have everything", so
		-- off meant a transmog-only rare could never be called finished and kept
		-- announcing. transmog_notable off does the reverse: appearances stop
		-- being a reason, but hasKnowableLoot still sees them, so the rare reads
		-- as knowably-not-wanted and goes quiet. Mapping one to the other turns
		-- the old default upside down, so leave everyone on the new one.

		-- already_alt was "tell me anyway", the inverse of counting an alt's as done
		core.db.profile.alts_achievements_count = p.already_alt == false

		p.already, p.already_drop, p.already_transmog, p.already_alt = nil, nil, nil, nil
	end

	-- The "Treasures" toggle is the "None" end of the treasure filter now. It
	-- defaulted to on, so a stored value only ever means it was turned off.
	if p.loot ~= nil then
		if not p.loot then
			p.filter_loot = "none"
		end
		p.loot = nil
	end

	-- known_mounts is gone; the Mount notability option covers it. Turning it off
	-- used to mean "a mount I already know still counts", which has no equivalent
	-- and nothing to migrate to, so it just goes.
	p.known_mounts = nil

	-- There were two switches for instances, this one and core's "Scan in
	-- instances", both off to start with and in different panels -- so turning
	-- that one on by itself changed nothing you could hear. Core's covers both
	-- now. It defaulted off, so a stored value here only ever means it was on.
	if p.instances ~= nil then
		if p.instances then
			core.db.profile.instances = true
		end
		p.instances = nil
	end

	-- Same story for dead rares: this and the Targets scanner each had a switch
	-- called "Dead rares". Core's covers both. It defaulted on, so a stored value
	-- here only ever means it was turned off.
	if p.dead ~= nil then
		if not p.dead then
			core.db.profile.dead = false
		end
		p.dead = nil
	end
end

function module:Seen(callback, id, zone, x, y, is_dead, source, ...)
	Debug("Announce:Seen", id, zone, x, y, is_dead, source, ...)

	if not core.db.profile.instances and IsInInstance() then
		return
	end

	if not self:ShouldAnnounce(id, zone, x, y, is_dead, source, ...) then
		return
	end

	core.events:Fire("Announce", id, zone, x, y, is_dead, source, ...)
end

function module:SeenLoot(callback, name, id, zone, x, y, ...)
	Debug("Announce:SeenLoot", name, id, zone, x, y, ...)

	if not core.db.profile.instances and IsInInstance() then
		return
	end

	local filter = self.db.profile.filter_loot
	if filter == "none" then
		Debug("Announce:SeenLoot", false, "treasures off")
		return
	end
	-- as in ShouldAnnounce, only a definite "nothing here is wanted" silences it
	if filter == "notable" and ns.MobIsNotable(id, true) == false then
		Debug("Announce:SeenLoot", false, "not notable")
		return
	end

	core.events:Fire("AnnounceLoot", name, id, zone, x, y, ...)
end

function module:ShouldAnnounce(id, zone, x, y, is_dead, source, ...)
	-- an off switch, so it comes before the always-announce cases
	if self.db.profile.filter == "none" then
		Debug("ShouldAnnounce", false, "rares off")
		return false
	end
	if is_dead and not core.db.profile.dead then
		Debug("ShouldAnnounce", false, "dead")
		return false
	end
	if core:IsCustom(id, zone) then
		-- If you've manually added a mob, bypass any other checks
		Debug("ShouldAnnounce", true, "always")
		return true
	end
	if ns.mobdb[id] and (
		(ns.mobdb[id].requires and not ns.conditions.check(ns.mobdb[id].requires)) or
		(ns.mobdb[id].active and not ns.conditions.check(ns.mobdb[id].active))
	) then
		-- not a completion question, so it applies whatever the filter is
		Debug("ShouldAnnounce", false, "requirements not met")
		return false
	end

	if self.db.profile.filter ~= "notable" then
		Debug("ShouldAnnounce", true, "not filtering")
		return true
	end
	-- Being on a vignette says the mob still has something to give, whatever our
	-- own quest data thinks -- but it says nothing about whether you want it, so
	-- it's an argument to the check rather than a way around it.
	local fromVignette = source == "vignette" or source == "point-of-interest"
	-- nil means we can't tell, which is no reason to keep quiet
	if ns.MobIsNotable(id, false, fromVignette) == false then
		Debug("ShouldAnnounce", false, "not notable")
		return false
	end
	Debug("ShouldAnnounce", true, "notable")
	return true
end

core.RegisterCallback("SD Announce Sink", "Announce", function(callback, id, zone, x, y, dead, source)
	if not module.db.profile.sink then
		return
	end

	Debug("Pouring")
	if source:match("^sync") then
		local channel, player = source:match("sync:(.+):(.+)")
		if channel and player then
			local localized_zone = core.zone_names[zone] or UNKNOWN
			source = "由" .. (L[channel] or channel) .. "的 " .. player .. " 發現；在" .. localized_zone
		end
	end
	local pin = ""
	if x and y then
		-- 偵測方式翻譯為中文
		if L[source] then source = L[source] end

		if x == 0 and y == 0 then
			source = source .. " @ 未知位置"
		else
			source = source .. (" @ %.1f, %.1f"):format(x * 100, y * 100)
			if zone ~= HBD:GetPlayerZone() then
				source = source .. " 在 " .. (core.zone_names[zone] or UNKNOWN)
			end
			if module.db.profile.sink_opts.sink20OutputSink == "ChatFrame" and MAP_PIN_HYPERLINK then
				pin = (" |cffffff00|Hworldmap:%d:%d:%d|h[%s]|h|r"):format(
					zone, x * 10000, y * 10000, MAP_PIN_HYPERLINK
				)
			end
		end
	end
	module:Pour(("發現稀有怪: %s%s (%s)%s"):format(core:GetMobLabel(id), dead and "... 但是已經死了" or '', source or '', pin))
end)
core.RegisterCallback("SD AnnounceLoot Sink", "AnnounceLoot", function(callback, name, id, zone, x, y, instanceid)
	if not module.db.profile.sink then
		return
	end

	Debug("Pouring")
	local pin = ""
	local location = UNKNOWN
	if x and y and x > 0 and y > 0 then
		location = ("%.1f, %.1f"):format(x * 100, y * 100)
		if module.db.profile.sink_opts.sink20OutputSink == "ChatFrame" and MAP_PIN_HYPERLINK then
			pin = (" |cffffff00|Hworldmap:%d:%d:%d|h[%s]|h|r"):format(
				zone, x * 10000, y * 10000, MAP_PIN_HYPERLINK
			)
		end
	end
	module:Pour(("發現寶藏: %s (%s)%s"):format(name, location, pin))
end)

local cvar_overrides
local channel_cvars = {
	Ambience = "Sound_EnableAmbience",
	Master = "Sound_EnableAllSound",
	Music = "Sound_EnableMusic",
	SFX = "Sound_EnableSFX",
	Dialog = "Sound_EnableDialog",
}
local delays = {
	["Ikiss: Trinkets"] = 5.7,
}
local nowplaying
function module:PlaySound(s)
	-- Arg is a table, to make scheduling the loops easier. I am lazy.
	Debug("Playing sound", s.soundfile, s.loops)
	-- boring check:
	if s and s.handle then
		StopSound(s.handle)
		if s.drumshandle then
			StopSound(s.drumshandle)
		end
		s.handle = nil
		s.drumshandle = nil
	end
	if not s.loops or s.loops == 0 then
		if cvar_overrides and s.cvars then
			for cvar, value in pairs(s.cvars) do
				SetCVar(cvar, value)
			end
			cvar_overrides = false
		end
		nowplaying = false
		return
	end
	if not cvar_overrides then
		if self.db.profile.background and GetCVar("Sound_EnableSoundWhenGameIsInBG") == "0" then
			cvar_overrides = true
			s.cvars = s.cvars or {}
			s.cvars["Sound_EnableSoundWhenGameIsInBG"] = GetCVar("Sound_EnableSoundWhenGameIsInBG")
			SetCVar("Sound_EnableSoundWhenGameIsInBG", "1")
		end
		if self.db.profile.unmute and GetCVar(channel_cvars[self.db.profile.channel]) == "0" then
			cvar_overrides = true
			s.cvars = s.cvars or {}
			s.cvars[channel_cvars[self.db.profile.channel]] = GetCVar(channel_cvars[self.db.profile.channel])
			SetCVar(channel_cvars[self.db.profile.channel], "1")
		end
	end
	-- now, noise!
	local drums = self.db.profile.drums
	if s.soundfile == "NPCScan" then
		--Override default behavior and force npcscan behavior of two sounds at once
		drums = true
		local _, handle = PlaySoundFile(LSM:Fetch("sound", "Scourge Horn"), self.db.profile.channel)
		s.handle = handle
	else
		--Play whatever sound is set
		local _, handle = PlaySoundFile(LSM:Fetch("sound", s.soundfile), self.db.profile.channel)
		s.handle = handle
	end
	if drums then
		local _, handle = PlaySoundFile(LSM:Fetch("sound", "War Drums"), self.db.profile.channel)
		s.drumshandle = handle
	end
	s.loops = s.loops - 1
	-- we guarantee one callback, in case we need to do cleanup
	self:ScheduleTimer("PlaySound", delays[s.soundfile] or 4.5, s)
	nowplaying = true
end
core.RegisterCallback("SD Announce Sound", "Announce", function(callback, id, zone, x, y, dead, source)
	if not LSM then return end
	if nowplaying then return end
	if source:match("^sync") then
		local channel, player = source:match("sync:(.+):(.+)")
		if channel == "GUILD" and not module.db.profile.soundguild or (channel == "PARTY" or channel == "RAID") and not module.db.profile.soundgroup then return end
	end
	local soundfile, loops
	if ns.HasNotableMounts(id) then
		if not module.db.profile.sound_mount then return end
		soundfile = module.db.profile.soundfile_mount
		loops = module.db.profile.sound_mount_loop
	elseif ns.mobdb[id] and ns.mobdb[id].boss then
		if not module.db.profile.sound_boss then return end
		soundfile = module.db.profile.soundfile_boss
		loops = module.db.profile.sound_boss_loop
	else
		if not module.db.profile.sound then return end
		soundfile = module.db.profile.soundfile
		loops = module.db.profile.sound_loop
	end
	module:PlaySound{soundfile = soundfile, loops = loops}
end)
core.RegisterCallback("SD AnnounceLoot Sound", "AnnounceLoot", function(callback, name, id, zone, x, y, instanceid)
	if not LSM then return end
	if nowplaying then return end
	local soundfile, loops
	if ns.HasNotableMounts(id, true) then
		if not module.db.profile.sound_mount then return end
		soundfile = module.db.profile.soundfile_mount
		loops = module.db.profile.sound_mount_loop
	elseif ns.MobIsNotable(id, true) == false then
		-- only reachable at all when the treasures filter is "everything", since
		-- "notable" stops AnnounceLoot firing for these before it gets here
		if not module.db.profile.sound_loot_junk then return end
		soundfile = module.db.profile.soundfile_loot_junk
		loops = module.db.profile.sound_loot_junk_loop
	else
		if not module.db.profile.sound_loot then return end
		soundfile = module.db.profile.soundfile_loot
		loops = module.db.profile.sound_loot_loop
	end
	module:PlaySound{soundfile = soundfile, loops = loops}
end)

do
	local flashframe
	function module:Flash(id, isloot)
		if not module.db.profile.flash then
			return
		end
		if not flashframe then
			flashframe = CreateFrame("Frame", nil, WorldFrame)
			flashframe:SetClampedToScreen(true)
			flashframe:SetFrameStrata("FULLSCREEN_DIALOG")
			flashframe:SetToplevel(true)
			flashframe:SetAllPoints(UIParent)
			flashframe:Hide()

			-- Use the OutOfControl (blue) and LowHealth (red) textures to get a purple flash
			local texture = flashframe:CreateTexture(nil, "BACKGROUND")
			texture:SetBlendMode("ADD")
			texture:SetDesaturated(true)
			texture:SetAllPoints()

			local group = flashframe:CreateAnimationGroup()
			group:SetLooping("BOUNCE")
			local pulse = group:CreateAnimation("Alpha")
			pulse:SetFromAlpha(0.3)
			pulse:SetToAlpha(0.75)
			pulse:SetDuration(0.5236)

			local loops = 0
			group:SetScript("OnLoop", function(frame, state)
				loops = loops + 1
				if loops == 9 then
					group:Finish()
				end
			end)
			group:SetScript("OnFinished", function(self)
				loops = 0
				flashframe:Hide()
			end)

			flashframe:SetScript("OnShow", function(self)
				local background = module.db.profile.flash_texture
				local color = module.db.profile.flash_color
				local data = self.id and (self.isloot and ns.vignetteTreasureLookup or ns.mobdb)[self.id]
				if data then
					if module.db.profile.flash_mount and ns.HasNotableMounts(self.id, self.isloot) then
						background = module.db.profile.flash_texture_mount
						color = module.db.profile.flash_color_mount
					elseif data.boss and module.db.profile.flash_boss then
						background = module.db.profile.flash_texture_boss
						color = module.db.profile.flash_color_boss
					end
				end
				texture:SetTexture(LSM:Fetch("background", background))
				texture:SetVertexColor(color.r, color.g, color.b, color.a)

				group:Play()
			end)
		end

		Debug("Flashing")
		flashframe.id = id
		flashframe.isloot = isloot
		flashframe:Hide()
		flashframe:Show()
	end

	core.RegisterCallback("SD Announce Flash", "Announce", function(callback, id)
		module:Flash(id)
	end)
	core.RegisterCallback("SD AnnounceLoot Flash", "AnnounceLoot", function(callback, name, id)
		module:Flash(id, true)
	end)
end

core.RegisterCallback("SD Announce Controller", "Announce", function(callback, id, zone, x, y, dead, source)
	local vibrate_type, vibrate_intensity
	if ns.HasNotableMounts(id) then
		if not module.db.profile.vibrate_mount then return end
		vibrate_type = module.db.profile.vibrate_type_mount
		vibrate_intensity = module.db.profile.vibrate_intensity_mount
	elseif ns.mobdb[id] and ns.mobdb[id].boss then
		if not module.db.profile.vibrate_boss then return end
		vibrate_type = module.db.profile.vibrate_type_boss
		vibrate_intensity = module.db.profile.vibrate_intensity_boss
	else
		if not module.db.profile.vibrate then return end
		vibrate_type = module.db.profile.vibrate_type
		vibrate_intensity = module.db.profile.vibrate_intensity
	end
	if C_GamePad.IsEnabled() then
		C_GamePad.SetVibration(vibrate_type, vibrate_intensity)
	end
end)
core.RegisterCallback("SD AnnounceLoot Controller", "AnnounceLoot", function(callback, name, id, zone, x, y, instanceid)
	if not module.db.profile.vibrate_loot then
		return
	end
	if C_GamePad.IsEnabled() then
		C_GamePad.SetVibration(module.db.profile.vibrate_type_loot, module.db.profile.vibrate_intensity_loot)
	end
end)

