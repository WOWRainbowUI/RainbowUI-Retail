--[[

	This file is part of 'Masque: Entropy', an add-on for World of Warcraft. For bug reports,
	documentation and license information, please visit https://github.com/SFX-WoW/Masque_Entropy.

	* File...: Skins.lua
	* Author.: StormFX

	Entropy Skins

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
local Version = "11.2.8"
local Websites = {
	"https://github.com/SFX-WoW/Masque_Entropy",
	"https://www.curseforge.com/wow/addons/masque-entropy",
	"https://addons.wago.io/addons/masque-entropy",
	"https://www.wowinterface.com/downloads/info8873",
}
local DESCRIPTION = L["A metallic version of Apathy in the color of %s ore."]

local PATH_BACKDROP = [[Interface\AddOns\Masque\Textures\Backdrop\]]

local PATH_BASE = [[Interface\AddOns\Masque_Entropy\Textures\Base\]]
local PATH_NORMAL = PATH_BASE.."Normal"
local PATH_BORDER = PATH_BASE.."Border"
local PATH_GLOW = PATH_BASE.."Glow"

----------------------------------------
-- Silver
---

Masque:AddSkin("Entropy - Silver", {
	API_VERSION = API_VERSION,
	Shape = "Square",

	-- [ Info ]
	Author = "StormFX",
	Description = DESCRIPTION:format("Silver"),
	Discord = "https://discord.gg/7MTWRgDzz8",
	Version = Version,
	Websites = Websites,

	-- [ UI ]
	Group = "Entropy",
	Order = 11,
	Title = "Silver",

	-- [ Skin ]
	-- Mask = nil,
	Backdrop = {
		Texture = PATH_BACKDROP.."Action",
		Width = 26,
		Height = 26,
		Item = {
			Texture = PATH_BACKDROP.."Item",
			Width = 26,
			Height = 26,
		},
		Pet = {
			Texture = PATH_BACKDROP.."Pet",
			Width = 26,
			Height = 26,
		},
	},
	Icon = {
		Backpack = [[Interface\Icons\INV_Misc_Bag_08]],
		TexCoords = {0.03, 0.97, 0.03, 0.97},
		Width = 27,
		Height = 27,
	},
	Shadow = {
		Texture = PATH_BASE.."Shadow",
		Color = {0, 0, 0, 0.5},
		Width = 32,
		Height = 32,
	},
	Normal = {
		Texture = PATH_NORMAL,
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
	-- Disabled = Default.Disabled,
	Pushed = {
		Color = {0, 0, 0, 0.5},
		DrawLayer = "BORDER",
		DrawLevel = 1,
		Width = 25,
		Height = 25,
		UseColor = true,
	},
	Flash = {
		Color = {1, 0, 0, 0.4},
		BlendMode = "ADD",
		DrawLayer = "BORDER",
		DrawLevel = 0,
		Width = 25,
		Height = 25,
		UseColor = true,
	},
	Checked = {
		Texture = PATH_BORDER,
		Color = {0, 0.7, 0.9, 0.7},
		Width = 32,
		Height = 32,
	},
	SlotHighlight = "Checked",
	Border = {
		Texture = PATH_BORDER,
		Width = 32,
		Height = 32,
	},
	DebuffBorder = "Border",
	EnchantBorder = "Border",
	IconBorder = "Border",
	Gloss = {
		Texture = PATH_BASE.."Gloss",
		Color = {1, 1, 1, 0.5},
		Width = 32,
		Height = 32,
	},
	NewAction = {
		Texture = PATH_GLOW,
		BlendMode = "BLEND",
		Width = 32,
		Height = 32,
	},
	SpellHighlight = "NewAction",
	IconOverlay = {
		Atlas = "AzeriteIconFrame",
		Width = 30,
		Height = 30,
	},
	IconOverlay2 = {
		Atlas = "ConduitIconFrame-Corners",
		Width = 30,
		Height = 30,
	},
	NewItem = {
		Texture = PATH_GLOW,
		Width = 32,
		Height = 32,
	},
	QuestBorder = {
		Border = PATH_BASE.."Quest",
		Texture = PATH_BORDER,
		Color = {1, 0.8, 0, 1},
		Width = 32,
		Height = 32,
	},
	UpgradeIcon = {
		Atlas = "bags-greenarrow",
		Width = 15,
		Height = 16,
		OffsetX = 3,
		OffsetY = -4,
	},
	ContextOverlay = {
		Color = {0, 0, 0, 0.7},
		Width = 30,
		Height = 30,
		UseColor = true,
	},
	SearchOverlay = "ContextOverlay",
	JunkIcon = {
		Atlas = "bags-junkcoin",
		Width = 16,
		Height = 16,
		OffsetX = 5,
		OffsetY = -4,
	},
	Duration = {
		Width = 27,
		OffsetY = -2,
	},
	Name = {
		Width = 27,
		OffsetY = 1,
	},
	Highlight = {
		Texture = PATH_BORDER,
		Color = {1, 1, 1, 0.3},
		Width = 32,
		Height = 32,
	},
	Count = {
		OffsetY = 1,
	},
	HotKey = {
		Width = 27,
		OffsetY = -1,
	},
	-- [ AutoCastShine (Classic) ]
	AutoCastable = {
		Texture = PATH_BASE.."Indicator",
		Color = {1, 1, 0, 1},
		Width = 32,
		Height = 32,
	},
	AutoCastShine = {
		Width = 26,
		Height = 26,
		OffsetX = 1,
		OffsetY = -1,
	},
	-- [ AutoCastOverlay (Retail) ]
	-- AutoCast_Frame = Default.AutoCast_Frame,
	AutoCast_Shine = {
		Atlas = "UI-HUD-ActionBar-PetAutoCast-Ants",
		Width = 36,
		Height = 36,
	},
	AutoCast_Mask = {
		Texture = [[Interface\AddOns\Masque\Textures\Square\AutoCast-Mask]],
		Width = 24,
		Height = 24,
	},
	AutoCast_Corners = {
		Atlas = "UI-HUD-ActionBar-PetAutoCast-Corners",
		Width = 30,
		Height = 30	,
	},
	-- [ Cooldowns ]
	Cooldown = {
		Texture = [[Interface\AddOns\Masque\Textures\Square\Mask]],
		EdgeTexture = [[Interface\AddOns\Masque\Textures\Square\Edge]],
		Color = {0, 0, 0, 0.7},
		Width = 24,
		Height = 24,
	},
	CooldownLoC = "Cooldown",
	ChargeCooldown = "Cooldown",
	-- [ SpellAlerts ]
	SpellAlert = {
		Height = 32,
		Width = 32,
		AltGlow = {
			Height = 36,
			Width = 36,
		},
		Classic = {
			Height = 26,
			Width = 26,
		},
		Modern = {
			Height = 26,
			Width = 26,
		},
		["Modern-Lite"] = {
			Height = 26,
			Width = 26,
		},
	},
	AssistedCombatHighlight = {
		Width = 36,
		Height = 36,
	},
})

----------------------------------------
-- Adamantite
---

Masque:AddSkin("Entropy - Adamantite", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Entropy - Silver",

	-- [ Info ]
	Description = DESCRIPTION:format("Adamantite"),

	-- [ UI ]
	Order = 1,
	Title = "Adamantite",

	-- [ Skin ]
	Normal = {
		Texture = PATH_NORMAL,
		Color = {0.7, 0.8, 0.9, 1},
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			Color = {0.7, 0.8, 0.9, 1},
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
})

----------------------------------------
-- Bronze
---

Masque:AddSkin("Entropy - Bronze", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Entropy - Silver",

	-- [ Info ]
	Description = DESCRIPTION:format("Bronze"),

	-- [ UI ]
	Order = 2,
	Title = "Bronze",

	-- [ Skin ]
	Normal = {
		Texture = PATH_NORMAL,
		Color = {1, 0.8, 0, 1},
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			Color = {1, 0.8, 0, 1},
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
})

----------------------------------------
-- Cobalt
---

Masque:AddSkin("Entropy - Cobalt", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Entropy - Silver",

	-- [ Info ]
	Description = DESCRIPTION:format("Cobalt"),

	-- [ UI ]
	Order = 3,
	Title = "Cobalt",

	-- [ Skin ]
	Normal = {
		Texture = PATH_NORMAL,
		Color = {0.3, 0.7, 0.9, 1},
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			Color = {0.3, 0.7, 0.9, 1},
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
})

----------------------------------------
-- Copper
---

Masque:AddSkin("Entropy - Copper", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Entropy - Silver",

	-- [ Info ]
	Description = DESCRIPTION:format("Copper"),

	-- [ UI ]
	Order = 4,
	Title = "Copper",

	-- [ Skin ]
	Normal = {
		Texture = PATH_NORMAL,
		Color = {0.8, 0.5, 0, 1},
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			Color = {0.8, 0.5, 0, 1},
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
})

----------------------------------------
-- Fel Iron
---

Masque:AddSkin("Entropy - Fel Iron", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Entropy - Silver",

	-- [ Info ]
	Description = DESCRIPTION:format("Fel Iron"),

	-- [ UI ]
	Order = 5,
	Title = "Fel Iron",

	-- [ Skin ]
	Normal = {
		Texture = PATH_NORMAL,
		Color = {0.8, 1, 0.8, 1},
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			Color = {0.8, 1, 0.8, 1},
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
})

----------------------------------------
-- Gold
---

Masque:AddSkin("Entropy - Gold", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Entropy - Silver",

	-- [ Info ]
	Description = DESCRIPTION:format("Gold"),

	-- [ UI ]
	Order = 6,
	Title = "Gold",

	-- [ Skin ]
	Normal = {
		Texture = PATH_NORMAL,
		Color = {0.8, 0.8, 0, 1},
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			Color = {0.8, 0.8, 0, 1},
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
})

----------------------------------------
-- Iron
---

Masque:AddSkin("Entropy - Iron", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Entropy - Silver",

	-- [ Info ]
	Description = DESCRIPTION:format("Iron"),

	-- [ UI ]
	Order = 7,
	Title = "Iron",

	-- [ Skin ]
	Normal = {
		Texture = PATH_NORMAL,
		Color = {0.5, 0.5, 0.5, 1},
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			Color = {0.5, 0.5, 0.5, 1},
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
})

----------------------------------------
-- Khorium
---

Masque:AddSkin("Entropy - Khorium", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Entropy - Silver",

	-- [ Info ]
	Description = DESCRIPTION:format("Khorium"),

	-- [ UI ]
	Order = 8,
	Title = "Khorium",

	-- [ Skin ]
	Normal = {
		Texture = PATH_NORMAL,
		Color = {1, 0.8, 0.9, 1},
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			Color = {1, 0.8, 0.9, 1},
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
})

----------------------------------------
-- Obsidium
---

Masque:AddSkin("Entropy - Obsidium", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Entropy - Silver",

	-- [ Info ]
	Description = DESCRIPTION:format("Obsidium"),

	-- [ UI ]
	Order = 9,
	Title = "Obsidium",

	-- [ Skin ]
	Normal = {
		Texture = PATH_NORMAL,
		Color = {0.3, 0.3, 0.3, 1},
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			Color = {0.3, 0.3, 0.3, 1},
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
})

----------------------------------------
-- Saronite
---

Masque:AddSkin("Entropy - Saronite", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Entropy - Silver",

	-- [ Info ]
	Description = DESCRIPTION:format("Saronite"),

	-- [ UI ]
	Order = 10,
	Title = "Saronite",

	-- [ Skin ]
	Normal = {
		Texture = PATH_NORMAL,
		Color = {0.3, 0.9, 0.7, 1},
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			Color = {0.3, 0.9, 0.7, 1},
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
})

----------------------------------------
-- Titanium
---

Masque:AddSkin("Entropy - Titanium", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Entropy - Silver",

	-- [ Info ]
	Description = DESCRIPTION:format("Titanium"),

	-- [ UI ]
	Order = 12,
	Title = "Titanium",

	-- [ Skin ]
	Normal = {
		Texture = PATH_NORMAL,
		Color = {1, 1, 0.7, 1},
		Width = 32,
		Height = 32,
		Item = {
			Texture = PATH_NORMAL,
			Color = {1, 1, 0.7, 1},
			EmptyColor = {0.3, 0.3, 0.3, 0.5},
			Width = 32,
			Height = 32,
		},
	},
})
