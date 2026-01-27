--[[

	This file is part of 'Masque: Squat', an add-on for World of Warcraft.

	* File...: Skins.lua
	* Author.: StormFX & dlecina

]]

local Masque = LibStub and LibStub("Masque", true)
if not Masque then return end

local _, Core = ...

----------------------------------------
-- Internal
---

local L = Core.Locale

----------------------------------------
-- Locals
---

local API_VERSION = 110208

-- Skin Info
local Version = "1.0.0"
local Websites = {
	"https://github.com/dlecina/Masque_Squat",
}

local PATH_TEXTURES = [[Interface\AddOns\Masque_Squat\Textures\]]

----------------------------------------
-- Squat
---

Masque:AddSkin("Squat", {
	API_VERSION = API_VERSION,
	Shape = "Square",

	-- Info
	Author = "dlecina",
	Description = L["A nice and short skin for Masque."],
	Version = Version,
	Websites = Websites,

	-- Skin
	Backdrop = {
		Texture = PATH_TEXTURES.."Backdrop-Action",
		TexCoords = {0.07,0.93,0.2,0.8},
		Width = 37,
		Height = 28,
		Item = {
			Texture = PATH_TEXTURES.."Backdrop-Item",
			TexCoords = {0.07,0.93,0.2,0.8},
			Width = 42,
			Height = 32,
		},
		Pet = {
			Texture = PATH_TEXTURES.."Backdrop-Pet",
			TexCoords = {0.07,0.93,0.2,0.8},
			Width = 42,
			Height = 32,
		},
	},
	Icon = {
		TexCoords = {0.07,0.93,0.2,0.8},
		Width = 37,
		Height = 28,
	},
	Shadow = {
		Texture = PATH_TEXTURES.."Shadow",
		Color = {0, 0, 0, 0.5},
		Width = 42,
		Height = 32,
	},
	Normal = {
		Texture = PATH_TEXTURES.."Normal",
		Color = {0, 0, 0, 1},
		Width = 42,
		Height = 32,
	},
	Pushed = {
		Color = {0, 0, 0, 0.5},
		UseColor = true,
	},
	Flash = {
		Color = {1, 0, 0, 0.4},
		UseColor = true,
	},
	Checked = {
		Texture = PATH_TEXTURES.."Border",
		Color = {0, 0.7, 0.9, 0.7},
		Width = 42,
		Height = 32,
	},
	SlotHighlight = "Checked",
	Border = {
		Texture = PATH_TEXTURES.."Border",
		Width = 42,
		Height = 32,
	},
	DebuffBorder = "Border",
	EnchantBorder = "Border",
	IconBorder = "Border",
	Gloss = {
		Texture = PATH_TEXTURES.."Gloss",
		Width = 42,
		Height = 32,
	},
	NewAction = {
		Texture = PATH_TEXTURES.."Glow",
		Color = {1, 1, 0.8, 1},
		Width = 42,
		Height = 32,
	},
	SpellHighlight = "NewAction",
	IconOverlay = {
		Atlas = "AzeriteIconFrame",
	},
	IconOverlay2 = {
		Atlas = "ConduitIconFrame-Corners",
	},
	NewItem = {
		Texture = PATH_TEXTURES.."Glow",
		DrawLayer = "OVERLAY",
		DrawLevel = 2,
		Width = 42,
		Height = 32,
	},
	QuestBorder = {
		Border = PATH_TEXTURES.."Border",
		Texture = PATH_TEXTURES.."Quest",
		Color = {1, 0.8, 0, 1},
		Width = 42,
		Height = 32,
	},
	UpgradeIcon = {
		Atlas = "bags-greenarrow",
		Width = 15,
		Height = 16,
		OffsetY = -1,
	},
	ContextOverlay = {
		Color = {0, 0, 0, 0.7},
		Width = 37,
		Height = 28,
		UseColor = true,
	},
	SearchOverlay = "ContextOverlay",
	JunkIcon = {
		Atlas = "bags-junkcoin",
		Width = 16,
		Height = 16,
		OffsetX = 2,
		OffsetY = -1,
	},
	Duration = {
        Point = "TOP",
		OffsetY = 6,
	},
	Name = {
        Point = "BOTTOM",
		OffsetY = -6,
	},
	Highlight = {
		Texture = PATH_TEXTURES.."Border",
		Color = {1, 1, 1, 0.3},
		BlendMode = "ADD",
		Width = 42,
		Height = 32,
	},
	Count = {
		OffsetX = -2,
		OffsetY = 2,
	},
	HotKey = {
		OffsetX = -2,
		OffsetY = -2,
	},
	AutoCastable = {
		Texture = PATH_TEXTURES.."Indicator",
		Color = {1, 1, 0, 1},
		Width = 42,
		Height = 32,
	},
	AutoCastShine = {
		Width = 35,
		Height = 25,
		OffsetX = 1,
		OffsetY = -1,
	},
	Cooldown = {
		Color = {0, 0, 0, 0.7},
		Width = 36,
		Height = 27,
	},
	ChargeCooldown = "Cooldown",
}, true)

----------------------------------------
-- Squatter
---

Masque:AddSkin("Squatter", {
	API_VERSION = API_VERSION,
	Shape = "Square",

	-- Info
	Author = "dlecina",
	Description = L["A nice and short skin for Masque."],
	Version = Version,
	Websites = Websites,

	-- Skin
	Backdrop = {
		Texture = PATH_TEXTURES.."Backdrop-Action",
		TexCoords = {0.07,0.93,0.2,0.7},
		Width = 37,
		Height = 20,
		Item = {
			Texture = PATH_TEXTURES.."Backdrop-Item",
			TexCoords = {0.07,0.93,0.2,0.7},
			Width = 42,
			Height = 22,
		},
		Pet = {
			Texture = PATH_TEXTURES.."Backdrop-Pet",
			TexCoords = {0.07,0.93,0.2,0.7},
			Width = 42,
			Height = 22,
		},
	},
	Icon = {
		TexCoords = {0.07,0.93,0.2,0.7},
		Width = 37,
		Height = 20,
	},
	Shadow = {
		Texture = PATH_TEXTURES.."Shadow",
		Color = {0, 0, 0, 0.5},
		Width = 42,
		Height = 22,
	},
	Normal = {
		Texture = PATH_TEXTURES.."Normal",
		Color = {0, 0, 0, 1},
		Width = 42,
		Height = 22,
	},
	Pushed = {
		Color = {0, 0, 0, 0.5},
		UseColor = true,
	},
	Flash = {
		Color = {1, 0, 0, 0.4},
		UseColor = true,
	},
	Checked = {
		Texture = PATH_TEXTURES.."Border",
		Color = {0, 0.7, 0.9, 0.7},
		Width = 42,
		Height = 22,
	},
	SlotHighlight = "Checked",
	Border = {
		Texture = PATH_TEXTURES.."Border",
		Width = 42,
		Height = 22,
	},
	DebuffBorder = "Border",
	EnchantBorder = "Border",
	IconBorder = "Border",
	Gloss = {
		Texture = PATH_TEXTURES.."Gloss",
		Width = 42,
		Height = 22,
	},
	NewAction = {
		Texture = PATH_TEXTURES.."Glow",
		Color = {1, 1, 0.8, 1},
		Width = 42,
		Height = 22,
	},
	SpellHighlight = "NewAction",
	IconOverlay = {
		Atlas = "AzeriteIconFrame",
	},
	IconOverlay2 = {
		Atlas = "ConduitIconFrame-Corners",
	},
	NewItem = {
		Texture = PATH_TEXTURES.."Glow",
		DrawLayer = "OVERLAY",
		DrawLevel = 2,
		Width = 42,
		Height = 22,
	},
	QuestBorder = {
		Border = PATH_TEXTURES.."Border",
		Texture = PATH_TEXTURES.."Quest",
		Color = {1, 0.8, 0, 1},
		Width = 42,
		Height = 22,
	},
	UpgradeIcon = {
		Atlas = "bags-greenarrow",
		Width = 15,
		Height = 16,
		OffsetY = -1,
	},
	ContextOverlay = {
		Color = {0, 0, 0, 0.7},
		Width = 37,
		Height = 20,
		UseColor = true,
	},
	SearchOverlay = "ContextOverlay",
	JunkIcon = {
		Atlas = "bags-junkcoin",
		Width = 16,
		Height = 16,
		OffsetX = 2,
		OffsetY = -1,
	},
	Duration = {
        Point = "TOP",
		OffsetY = 4,
	},
	Name = {
        Point = "BOTTOM",
		OffsetY = -4,
	},
	Highlight = {
		Texture = PATH_TEXTURES.."Border",
		Color = {1, 1, 1, 0.3},
		BlendMode = "ADD",
		Width = 42,
		Height = 22,
	},
	Count = {
		OffsetX = -2,
		OffsetY = 2,
	},
	HotKey = {
		OffsetX = -2,
		OffsetY = -2,
	},
	AutoCastable = {
		Texture = PATH_TEXTURES.."Indicator",
		Color = {1, 1, 0, 1},
		Width = 42,
		Height = 22,
	},
	AutoCastShine = {
		Width = 34,
		Height = 18,
		OffsetX = 1,
		OffsetY = -1,
	},
	Cooldown = {
		Color = {0, 0, 0, 0.7},
		Width = 36,
		Height = 19,
	},
	ChargeCooldown = "Cooldown",
}, true)