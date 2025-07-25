local E, L, C = select(2, ...):unpack()

local LSM = E.Libs.LSM
LSM:Register("font", "PT Sans Narrow", "Interface\\Addons\\OmniCD\\Media\\Fonts\\PTSansNarrow-Bold.ttf", bit.bor(LSM.LOCALE_BIT_western, LSM.LOCALE_BIT_ruRU))
LSM:Register("statusbar", "OmniCD Flat", "Interface\\Addons\\OmniCD\\Media\\omnicd-texture_flat.blp")

local LSM_Font = {}
local LSM_Statusbar = {}

local defaultFonts = {}

if LOCALE_koKR then
	defaultFonts.statusBar = {"기본 글꼴", 22, "NONE", 0, 0, 0, 1, -1}
	defaultFonts.icon = {"기본 글꼴", 11, "OUTLINE", 0, 0, 0, 0, 0}
	defaultFonts.anchor = {"기본 글꼴", 12, "NONE", 0, 0, 0, 1, -1}
elseif LOCALE_zhCN then
	defaultFonts.statusBar = {"默认", 22, "NONE", 0, 0, 0, 1, -1}
	defaultFonts.icon = {"默认", 15, "OUTLINE", 0, 0, 0, 0, 0}
	defaultFonts.anchor = {"默认", 15, "NONE", 0, 0, 0, 1, -1}
elseif LOCALE_zhTW then
	defaultFonts.statusBar = {"預設", 22, "NONE", 0, 0, 0, 1, -1}
	defaultFonts.icon = {"預設", 15, "OUTLINE", 0, 0, 0, 0, 0}
	defaultFonts.anchor = {"預設", 15, "NONE", 0, 0, 0, 1, -1}
elseif LOCALE_ruRU then
	defaultFonts.statusBar = {"PT Sans Narrow", 22, "NONE", 0, 0, 0, 1, -1}
	defaultFonts.icon = {"PT Sans Narrow", 10, "OUTLINE", 0, 0, 0, 0, 0}
	defaultFonts.anchor = {"PT Sans Narrow", 12, "NONE", 0, 0, 0, 1, -1}
else
	defaultFonts.statusBar = {"PT Sans Narrow", 22, "NONE", 0, 0, 0, 1, -1}
	defaultFonts.icon = {"PT Sans Narrow", 10, "OUTLINE", 0, 0, 0, 0, 0}
	defaultFonts.anchor = {"PT Sans Narrow", 12, "NONE", 0, 0, 0, 1, -1}
end

C.General = {
	fonts = {},
	textures = {
		statusBar = {
			bar = "OmniCD Flat",
			BG = "OmniCD Flat",
		},
	},
	cooldownText = {
		statusBar = {
			mmss = 120,
			mmColor = {r=1, g=1, b=1},
			mmssColor = {r=1, g=1, b=1},
		},
		useElvUICooldownTimer = true,
	}
}

for k, v in pairs(defaultFonts) do
	C.General.fonts[k] = {}
	C.General.fonts[k].font = v[1]
	C.General.fonts[k].size = v[2]
	C.General.fonts[k].flag = v[3]
	C.General.fonts[k].r = v[4]
	C.General.fonts[k].g = v[5]
	C.General.fonts[k].b = v[6]
	C.General.fonts[k].ofsX = v[7]
	C.General.fonts[k].ofsY = v[8]
end

function E:SetFontProperties(fontString, db)
	local ofsX, flag = db.ofsX, db.flag
	if db.font == "Homespun" then
		ofsX, flag = 0, "MONOCHROMEOUTLINE"
	end

	fontString:SetFont(LSM:Fetch("font", db.font), db.size, flag == "NONE" and "" or flag)
	fontString:SetShadowOffset(ofsX, -ofsX)
	fontString:SetShadowColor(db.r, db.g, db.b, ofsX == 0 and 0 or 1)
end

function E.Party:ConfigTextures()
	self:UpdateStatusBarTextures()
end

function E:ConfigTextures()
	for moduleName in pairs(self.moduleOptions) do
		local module = self[moduleName]
		local func = module.ConfigTextures
		if func then
			func(module)
		end
	end
end

local getTextColor = function(info)
	local db = E.profile.General.cooldownText[ info[3] ][ info[#info] ]
	return db.r, db.g, db.b
end

local setTextColor = function(info, r, g, b)
	local db = E.profile.General.cooldownText[ info[3] ][ info[#info] ]
	db.r, db.g, db.b = r, g, b
	E:Refresh()
end

local isHomespun = function(info)
	return E.profile.General.fonts[ info[3] ].font == "Homespun"
end

local fontInfo = {
	font = {
		name = L["Font"],
		order = 1,
		type = "select",


		values = LSM_Font,
	},
	size = {
		name = FONT_SIZE,
		order = 2,
		type = "range",
		min = 8, max = 32, step = 1,
	},
	flag = {
		disabled = isHomespun,
		name = L["Font Outline"],
		order = 3,
		type = "select",
		values = {
			["NONE"] = "NONE",
			["OUTLINE"] = "OUTLINE",
			["MONOCHROMEOUTLINE"] = "MONOCHROMEOUTLINE",
			["THICKOUTLINE"] = "THICKOUTLINE"
		},
	},
	ofsX = {
		disabled = isHomespun,
		name = L["Font Shadow"],
		order = 4,
		type = "select",
		values = {
			[0] = NONE,
			[1] = "1, -1",
		}
	},
}

local General = {
	name = GENERAL,
	order = 10,
	type = "group",
	childGroups = "tab",
	args = {
		fonts = {
			name = L["Fonts"],
			order = 10,
			type = "group",
			get = function(info) return E.profile.General.fonts[ info[3] ][ info[#info] ] end,
			set = function(info, value) E.profile.General.fonts[ info[3] ][ info[#info] ] = value E:UpdateFontObjects() end,
			args ={
				anchor = {
					name = L["Anchor"],
					order = 1,
					type = "group",
					inline = true,
					args = fontInfo
				},
				icon = {
					name = L["Icon"],
					order = 2,
					type = "group",
					inline = true,
					args = fontInfo
				},
				statusBar = {
					name = L["Status Bar"],
					order = 3,
					type = "group",
					inline = true,
					args = fontInfo
				},
			}
		},
		textures = {
			name = TEXTURES_SUBHEADER,
			order = 20,
			type = "group",
			get = function(info) return E.profile.General.textures[ info[3] ][ info[#info] ] end,
			set = function(info, value) E.profile.General.textures[ info[3] ][ info[#info] ] = value E:ConfigTextures() end,
			args = {
				statusBar = {
					name = L["Status Bar"],
					order = 1,
					type = "group",
					inline = true,
					args = {
						bar = {
							name = L["Bar"],
							order = 1,
							type = "select",


							values = LSM_Statusbar,
						},
						BG = {
							name = L["BG"],
							order = 2,
							type = "select",


							values = LSM_Statusbar,
						},
					}
				},
			}
		},
		cooldownText = {
			name = L["Timers"],
			order = 30,
			type = "group",
			get = function(info) return E.profile.General.cooldownText[ info[3] ][ info[#info] ] end,
			set = function(info, value) E.profile.General.cooldownText[ info[3] ][ info[#info] ] = value E:Refresh() end,
			args = {
				coooldownTimer = {
					name = L["Cooldown Timer"],
					order = 100,
					type = "group",
					inline = true,
					args = {
						useElvUICooldownTimer = {
							disabled = function() return not _G.ElvUI end,
							name = L["Use ElvUI Timer"],
							desc = L["[Show Numbers for Cooldowns] must be disabled in Blizzard's \'Options/Action Bars\' menu."],
							type = "toggle",
							get = function() return E.profile.General.cooldownText.useElvUICooldownTimer end,
							set = function(_, value)
								E.profile.General.cooldownText.useElvUICooldownTimer = value
								E.Libs.OmniCDC.StaticPopup_Show("OMNICD_RELOADUI", E.STR.RELOAD_UI)
							end,
						},
					}
				},
				statusBar = {
					name = L["Status Bar"],
					order = 200,
					type = "group",
					inline = true,
					args = {
						minute = {
							name = L["> 1 minute"],
							order = 10,
							type = "group",
							inline = true,
							args = {
								mmss = {
									name = L["MM:SS Threshold"],
									desc = L["Threshold at which the timer transitions from MM to MM:SS format."],
									order = 1,
									type = "range",
									min = 60, max = 300, step = 5,
								},
								mmColor = {
									disabled = true,
									name = L["MM:SS Color"],
									order = 2,
									type = "color",
									dialogControl = "ColorPicker-OmniCDC",
									get = getTextColor,
									set = setTextColor,
								},
								mmssColor = {
									disabled = true,
									name = L["MM Color"],
									order = 3,
									type = "color",
									dialogControl = "ColorPicker-OmniCDC",
									get = getTextColor,
									set = setTextColor,
								},
							}
						},
					}
				},
			}
		}
	}
}

function E:AddGeneral()

	self.dummyFontString = self.dummyFontString or self:CreateFontString()
	for fontName, fontPath in pairs(LSM:HashTable("font")) do
		self.dummyFontString:SetFont(fontPath, 22)
		LSM_Font[fontName] = fontName
	end

	for _, fontName in ipairs(LSM:List("statusbar")) do
		LSM_Statusbar[fontName] = fontName
	end

	self.options.args["General"] = General
end
