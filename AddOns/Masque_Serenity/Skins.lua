--[[

	This file is part of 'Masque: Serenity', an add-on for World of Warcraft. For bug reports,
	documentation and license information, please visit https://github.com/SFX-WoW/Masque_Serenity.

	* File....: Skins.lua
	* Authors.: StormFX, Sairen

	Serenity Skins

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
local Authors = {"StormFX", "|cff999999Sairen|r"}
local Discord = "https://discord.gg/7MTWRgDzz8"
local Version = "11.2.8"
local Websites = {
	"https://github.com/SFX-WoW/Masque_Serenity",
	"https://www.curseforge.com/wow/addons/masque-serenity",
	"https://addons.wago.io/addons/masque-serenity",
	"https://www.wowinterface.com/downloads/info8875",
}

local PATH_BACKDROP = [[Interface\AddOns\Masque\Textures\Backdrop\]]

local PATH_ROUND = [[Interface\AddOns\Masque_Serenity\Textures\Round\]]
local BORDER_ROUND = PATH_ROUND.."Border"
local GLOW_ROUND = PATH_ROUND.."Glow"
local MASK_ROUND = PATH_ROUND.."Mask"

local PATH_SQUARE = [[Interface\AddOns\Masque_Serenity\Textures\Square\]]
local BORDER_SQUARE = PATH_SQUARE.."Border"
local GLOW_SQUARE = PATH_SQUARE.."Glow"
local MASK_SQUARE = PATH_SQUARE.."Mask"

----------------------------------------
-- Serenity
---

Masque:AddSkin("Serenity", {
	API_VERSION = API_VERSION,
	Shape = "Circle",

	-- [ Info ]
	Authors = Authors,
	Description = L["A port of the original Serenity skin by Sairen."],
	Discord = Discord,
	Version = Version,
	Websites = Websites,

	-- [ UI ]
	Group = "Serenity",
	Order = 1,

	-- [ Skin ]
	Mask = {
		Texture = MASK_ROUND,
		Width = 32,
		Height = 32,
		Anchor = "Icon",
	},
	Backdrop = {
		Texture = PATH_BACKDROP.."Action",
		Width = 32,
		Height = 32,
		UseMask = true,
		Item = {
			Texture = PATH_BACKDROP.."Item",
			Width = 32,
			Height = 32,
			UseMask = true,
		},
		Pet = {
			Texture = PATH_BACKDROP.."Pet",
			Width = 32,
			Height = 32,
			UseMask = true,
		},
	},
	Icon = {
		Texture = [[Interface\Icons\INV_Misc_Bag_08]], -- SlotIcon
		Width = 32,
		Height = 32,
		UseMask = true,
	},
	-- Shadow = Default.Shadow,
	Normal = {
		Texture = PATH_ROUND.."Normal",
		Color = {0.7, 0.7, 0.7, 1},
		Width = 44,
		Height = 44,
	},
	-- Disabled = Default.Disabled,
	Pushed = {
		Color = {0, 0, 0, 0.5},
		DrawLayer = "BORDER",
		DrawLevel = 1,
		Width = 32,
		Height = 32,
		UseColor = true,
		UseMask = true,
	},
	Flash = {
		Color = {1, 0, 0, 0.3},
		BlendMode = "ADD",
		DrawLayer = "BORDER",
		DrawLevel = 0,
		Width = 32,
		Height = 32,
		UseColor = true,
		UseMask = true,
	},
	Checked = {
		Texture = GLOW_ROUND,
		Color = {0, 0.7, 0.9, 0.7},
		Width = 34,
		Height = 34,
	},
	SlotHighlight = {
		Texture = GLOW_ROUND,
		Color = {1, 1, 1, 0.4},
		BlendMode = "ADD",
		Width = 34,
		Height = 34,
	},
	Border = {
		Texture = GLOW_ROUND,
		Width = 34,
		Height = 34,
	},
	DebuffBorder = "Border",
	EnchantBorder = "Border",
	IconBorder = "Border",
	Gloss = {
		Texture = PATH_ROUND.."Gloss",
		Color = {1, 1, 1, 0.5},
		BlendMode = "ADD",
		Width = 44,
		Height = 44,
	},
	NewAction = {
		Texture = GLOW_ROUND,
		Color = {1, 1, 0.6, 1},
		Width = 34,
		Height = 34,
	},
	SpellHighlight = "NewAction",
	IconOverlay = {
		Atlas = "AzeriteIconFrame",
		Width = 32,
		Height = 32,
	},
	IconOverlay2 = {
		Atlas = "ConduitIconFrame-Corners",
		Width = 32,
		Height = 32,
	},
	NewItem = {
		Texture = GLOW_ROUND,
		DrawLayer = "BORDER",
		DrawLevel = 0,
		Width = 34,
		Height = 34,
	},
	QuestBorder = {
		Border = PATH_ROUND.."Quest",
		Texture = BORDER_ROUND,
		Color = {1, 0.8, 0, 1},
		Width = 44,
		Height = 44,
	},
	UpgradeIcon = {
		Atlas = "bags-greenarrow",
		Width = 15,
		Height = 16,
		Point = "LEFT",
		RelPoint = "LEFT",
		OffsetX = 3,
	},
	ContextOverlay = {
		Color = {0, 0, 0, 0.7},
		Width = 36,
		Height = 36,
		UseColor = true,
	},
	SearchOverlay = "ContextOverlay",
	JunkIcon = {
		Atlas = "bags-junkcoin",
		Width = 16,
		Height = 16,
		Point = "LEFT",
		RelPoint = "LEFT",
		OffsetX = 3,
	},
	Duration = {
		OffsetY = -4,
	},
	Name = {
		OffsetY = 2,
	},
	Highlight = {
		Texture = BORDER_ROUND,
		Color = {1, 1, 1, 0.7},
		Width = 44,
		Height = 44,
	},
	-- [ TextOverlayContainer (Retail) ]
	Count = {
		OffsetX = -2,
		Item = {
			JustifyH = "CENTER",
			Anchor = "Icon",
			Point = "BOTTOM",
			RelPoint = "BOTTOM",
			OffsetX = 1,
		},
	},
	HotKey = {
		OffsetX = -3,
		Pet = {
			JustifyH = "CENTER",
			Point = "TOP",
			RelPoint = "TOP",
			OffsetY = 4,
		},
	},
	-- [ AutoCastShine (Classic) ]
	AutoCastable = {
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
		Color = {1, 1, 0, 1},
		Width = 60,
		Height = 60,
	},
	AutoCastShine = {
		Width = 28,
		Height = 28,
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
		Texture = [[Interface\AddOns\Masque\Textures\Circle\AutoCast-Mask]],
		Width = 24,
		Height = 24,
	},
	AutoCast_Corners = {
		Atlas = "UI-HUD-ActionBar-PetAutoCast-Corners",
		Width = 26,
		Height = 26,
	},
	-- [ Cooldowns ]
	Cooldown = {
		Texture = MASK_ROUND,
		EdgeTexture = [[Interface\AddOns\Masque\Textures\Square\Edge]],
		Color = {0, 0, 0, 0.7},
		Width = 30,
		Height = 30,
	},
	CooldownLoC = "Cooldown",
	ChargeCooldown = {
		EdgeTexture = [[Interface\AddOns\Masque\Textures\Square\Edge]],
		Width = 26,
		Height = 26,
	},
	-- [ SpellAlerts ]
	SpellAlert = {
		Width = 32,
		Height = 32,
		AltGlow = {
			Height = 41,
			Width = 41,
		},
		Classic = {
			Height = 28,
			Width = 28,
		},
		Modern = {
			Height = 28,
			Width = 28,
		},
		["Modern-Lite"] = {
			Height = 29,
			Width = 29,
		},
	},
	AssistedCombatHighlight = {
		Width = 41,
		Height = 41,
	},
})

----------------------------------------
-- Serenity - Redux
---

Masque:AddSkin("Serenity - Redux", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.Shape,
	Template = "Serenity",

	-- [ Info ]
	-- Authors = Template.Authors,
	Description = L["An alternate version of Serenity with modified Checked and Equipped textures."],
	-- Discord = Template.Discord,
	-- Version = Template.Version,
	-- Websites = Template.Websites,

	-- [ UI ]
	-- Group = Template.Group,
	Title = "Redux",
	Order = 2,

	-- [ Skin ]
	-- Mask = Template.Mask,
	-- Backdrop = Template.Backdrop,
	-- Icon = Template.Icon,
	-- SlotIcon = Template.SlotIcon,
	-- Shadow = Template.Shadow,
	-- Normal = Template.Normal,
	-- Disabled = Template.Disabled,
	-- Pushed = Template.Pushed,
	-- Flash = Template.Flash,
	Checked = {
		Texture = BORDER_ROUND,
		Color = {0, 0.7, 0.9, 1},
		Width = 44,
		Height = 44,
	},
	SlotHighlight = {
		Texture = BORDER_ROUND,
		Color = {1, 1, 1, 0.4},
		BlendMode = "ADD",
		Width = 44,
		Height = 44,
	},
	Border = {
		Texture = BORDER_ROUND,
		Width = 44,
		Height = 44,
	},
	DebuffBorder = "Border",
	EnchantBorder = "Border",
	IconBorder = "Border",
	-- Gloss = Template.Gloss,
	-- NewAction = Template.NewAction,
	-- SpellHighlight = Template.SpellHighlight,
	-- IconOverlay = Template.IconOverlay,
	-- IconOverlay2 = Template.IconOverlay2,
	-- NewItem = Template.NewItem,
	-- QuestBorder = Template.QuestBorder,
	-- UpgradeIcon = Template.UpgradeIcon,
	-- ContextOverlay = Template.ContextOverlay,
	-- SearchOverlay = Template.SearchOverlay,
	-- JunkIcon = Template.JunkIcon,
	-- Duration = Template.Duration,
	-- Name = Template.Name,
	-- Highlight = Template.Highlight,
	-- Count = Template.Count,
	-- HotKey = Template.HotKey,
	-- AutoCastable = Template.AutoCastable,
	-- AutoCastShine = Template.AutoCastShine,
	-- AutoCast_Frame = Template.AutoCast_Frame,
	-- AutoCast_Shine = Template.AutoCast_Shine,
	-- AutoCast_Mask = Template.AutoCast_Mask,
	-- AutoCast_Corners = Template.AutoCast_Corners,
	-- Cooldown = Template.Cooldown,
	-- ChargeCooldown = Template.ChargeCooldown,
	-- SpellAlert = Template.SpellAlert,
	-- AssistedCombatHighlight = Template.AssistedCombatHighlight,
})

----------------------------------------
-- Serenity - Square
---

Masque:AddSkin("Serenity - Square", {
	API_VERSION = API_VERSION,
	Shape = "Modern",

	-- [ Info ]
	Authors = Authors,
	Description = L["A port of the original Serenity Square skin by Sairen."],
	Discord = Discord,
	Version = Version,
	Websites = Websites,

	-- [ UI ]
	Group = "Serenity",
	Title = "Square",
	Order = 3,

	-- [ Skin ]
	Mask = {
		Texture = MASK_SQUARE,
		Width = 32,
		Height = 32,
		Anchor = "Icon",
	},
	Backdrop = {
		Texture = PATH_BACKDROP.."Action",
		Mask = MASK_SQUARE,
		Item = {
			Texture = PATH_BACKDROP.."Item",
			Mask = MASK_SQUARE,
		},
		Pet = {
			Texture = PATH_BACKDROP.."Pet",
			Mask = MASK_SQUARE,
		},
	},
	Icon = {
		Texture = [[Interface\Icons\INV_Misc_Bag_08]], -- SlotIcon
		Width = 32,
		Height = 32,
		UseMask = true,
	},
	SlotIcon = "Icon",
	-- Shadow = Default.Shadow,
	Normal = {
		Texture = PATH_SQUARE.."Normal",
		Color = {0.7, 0.7, 0.7, 1},
		Width = 40,
		Height = 40,
	},
	-- Disabled = Default.Disabled,
	Pushed = {
		Color = {0, 0, 0, 0.5},
		DrawLayer = "BORDER",
		DrawLevel = 1,
		Width = 32,
		Height = 32,
		UseColor = true,
		UseMask = true,
	},
	Flash = {
		Color = {1, 0, 0, 0.3},
		BlendMode = "ADD",
		DrawLayer = "BORDER",
		DrawLevel = 0,
		Width = 32,
		Height = 32,
		UseColor = true,
		UseMask = true,
	},
	Checked = {
		Texture = GLOW_SQUARE,
		Color = {0, 0.7, 0.9, 0.7},
		Width = 30,
		Height = 30,
	},
	SlotHighlight = {
		Texture = GLOW_SQUARE,
		Color = {1, 1, 1, 0.4},
		BlendMode = "ADD",
		Width = 30,
		Height = 30,
	},
	Border = {
		Texture = GLOW_SQUARE,
		Width = 30,
		Height = 30,
	},
	DebuffBorder = "Border",
	EnchantBorder = "Border",
	IconBorder = "Border",
	Gloss = {
		Texture = PATH_SQUARE.."Gloss",
		Color = {1, 1, 1, 0.5},
		BlendMode = "ADD",
		Width = 42,
		Height = 42,
	},
	NewAction = {
		Texture = GLOW_SQUARE,
		Color = {1, 1, 0.6, 1},
		Width = 30,
		Height = 30,
	},
	SpellHighlight = "NewAction",
	IconOverlay = {
		Atlas = "AzeriteIconFrame",
		Width = 32,
		Height = 32,
	},
	IconOverlay2 = {
		Atlas = "ConduitIconFrame-Corners",
		Width = 32,
		Height = 32,
	},
	NewItem = {
		Texture = GLOW_SQUARE,
		DrawLayer = "BORDER",
		DrawLevel = 0,
		Width = 30,
		Height = 30,
	},
	QuestBorder = {
		Border = PATH_SQUARE.."Quest",
		Texture = BORDER_SQUARE,
		Color = {1, 0.8, 0, 1},
		Width = 40,
		Height = 40,
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
		Width = 36,
		Height = 36,
		UseColor = true,
	},
	SearchOverlay = "ContextOverlay",
	JunkIcon = {
		Atlas = "bags-junkcoin",
		Width = 16,
		Height = 16,
		OffsetX = 4,
		OffsetY = -4,
	},
	Duration = {
		OffsetY = -2,
	},
	Name = {
		Anchor = "Icon",
		OffsetY = 2,
	},
	Highlight = {
		Texture = BORDER_SQUARE,
		Color = {1, 1, 1, 0.7},
		Width = 40,
		Height = 40,
	},
	Count = {
		OffsetX = -3,
		OffsetY = 3,
		Item = {
			OffsetX = -2,
			OffsetY = 2,
		},
	},
	HotKey = {
		OffsetX = -3,
		OffsetY = -3,
		Pet = {
			OffsetX = -2,
			OffsetY = -2,
		},
	},
	-- [ AutoCastShine (Classic) ]
	AutoCastable = {
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
		Width = 62,
		Height = 62,
	},
	AutoCastShine = {
		Width = 32,
		Height = 32,
		OffsetX = 1,
		OffsetY = -1,
	},
	-- [ AutoCastOverlay (Retail) ]
	-- AutoCast_Frame = Default.AutoCast_Frame,
	AutoCast_Shine = {
		Atlas = "UI-HUD-ActionBar-PetAutoCast-Ants",
		Width = 40, -- 41
		Height = 40, -- 41
	},
	AutoCast_Mask = {
		Texture = [[Interface\AddOns\Masque\Textures\Square\AutoCast-Mask]],
		Width = 26,
		Height = 26,
	},
	AutoCast_Corners = {
		Atlas = "UI-HUD-ActionBar-PetAutoCast-Corners",
		Width = 31,
		Height = 31,
	},
	-- [ Cooldowns ]
	Cooldown = {
		Texture = MASK_SQUARE,
		EdgeTexture = [[Interface\AddOns\Masque\Textures\Modern\Edge]],
		Color = {0, 0, 0, 0.7},
		Width = 31,
		Height = 31,
	},
	CooldownLoC = "Cooldown",
	ChargeCooldown = {
		EdgeTexture = [[Interface\AddOns\Masque\Textures\Modern\Edge]],
		Width = 26,
		Height = 26,
	},
	-- [ SpellAlerts ]
	SpellAlert = {
		Width = 32,
		Height = 32,
		AltGlow = {
			Height = 38,
			Width = 38,
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
			Height = 27,
			Width = 27,
		},
	},
	AssistedCombatHighlight = {
		Width = 38,
		Height = 38,
	},
})

----------------------------------------
-- Serenity - Square Redux
---

Masque:AddSkin("Serenity - Square Redux", {
	-- API_VERSION = Template.API_VERSION,
	-- Shape = Template.API_VERSION,
	Template = "Serenity - Square",

	-- [ Info ]
	-- Authors = Template.Authors,
	Description = L["An alternate version of Serenity Square with modified Checked and Equipped textures."],
	-- Discord = Template.Discord,
	-- Version = Template.Version,
	-- Websites = Template.Websites,

	-- [ UI ]
	-- Group = Template.Group,
	Title = "Square Redux",
	Order = 4,

	-- [ Skin ]
	-- Mask = Template.Mask,
	-- Backdrop = Template.Backdrop,
	-- Icon = Template.Icon,
	-- SlotIcon = Template.SlotIcon,
	-- Shadow = Template.Shadow,
	-- Normal = Template.Normal,
	-- Disabled = Template.Disabled,
	-- Pushed = Template.Pushed,
	-- Flash = Template.Flash,
	Checked = {
		Texture = BORDER_SQUARE,
		Color = {0, 0.7, 0.9, 1},
		Width = 40,
		Height = 40,
	},
	SlotHighlight = {
		Texture = BORDER_SQUARE,
		Color = {1, 1, 1, 0.4},
		BlendMode = "ADD",
		Width = 40,
		Height = 40,
	},
	Border = {
		Texture = BORDER_SQUARE,
		Width = 40,
		Height = 40,
	},
	DebuffBorder = "Border",
	EnchantBorder = "Border",
	IconBorder = "Border",
	-- Gloss = Template.Gloss,
	-- NewAction = Template.NewAction,
	-- SpellHighlight = Template.SpellHighlight,
	-- IconOverlay = Template.IconOverlay,
	-- IconOverlay2 = Template.IconOverlay2,
	-- NewItem = Template.NewItem,
	-- QuestBorder = Template.QuestBorder,
	-- UpgradeIcon = Template.UpgradeIcon,
	-- ContextOverlay = Template.ContextOverlay,
	-- SearchOverlay = Template.SearchOverlay,
	-- JunkIcon = Template.JunkIcon,
	-- Duration = Template.Duration,
	-- Name = Template.Name,
	-- Highlight = Template.Highlight,
	-- Count = Template.Count,
	-- HotKey = Template.HotKey,
	-- AutoCastable = Template.AutoCastable,
	-- AutoCastShine = Template.AutoCastShine,
	-- AutoCast_Frame = Template.AutoCast_Frame,
	-- AutoCast_Shine = Template.AutoCast_Shine,
	-- AutoCast_Mask = Template.AutoCast_Mask,
	-- AutoCast_Corners = Template.AutoCast_Corners,
	-- Cooldown = Template.Cooldown,
	-- ChargeCooldown = Template.ChargeCooldown,
	-- SpellAlert = Template.SpellAlert,
	-- AssistedCombatHighlight = Template.AssistedCombatHighlight,
})
