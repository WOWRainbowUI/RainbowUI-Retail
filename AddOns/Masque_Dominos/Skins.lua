--[[

	This file is part of 'Masque: Dominos', an add-on for World of Warcraft. For bug reports,
	documentation and license information, please visit https://github.com/SFX-WoW/Masque_Dominos.

	* File...: Skins.lua
	* Author.: StormFX, Tuller

	Dominos Skin

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

local API_VERSION = 120000

-- Skin Info
local Authors = {"StormFX", "Tuller"}
local Version = "c1b4983"
local Websites = {
	"https://github.com/SFX-WoW/Masque_Dominos",
	"https://www.curseforge.com/wow/addons/masque-dominos",
	"https://addons.wago.io/addons/masque-dominos",
	"https://www.wowinterface.com/downloads/info26455",
}

----------------------------------------
-- Dominos
---

Masque:AddSkin("Dominos", {
	API_VERSION = API_VERSION,
	Shape = "Modern",
	Template = "Blizzard Classic",

	-- [ Info ]
	Authors = Authors,
	Description = L["A port of the original Dominos skin for Masque."],
	Discord = "https://discord.gg/7MTWRgDzz8",
	Version = Version,
	Websites = Websites,

	-- [ Skin ]
	Icon = {
		Backpack = [[Interface\Icons\INV_Misc_Bag_08]],
		TexCoords = {0.06, 0.94, 0.06, 0.94},
	},
	Normal = {
		Texture = [[Interface\Buttons\UI-Quickslot2]],
		Color = { 1, 1, 1, 0.5 },
		Width = 66,
		Height = 66,
		UseStates = true,
	},
	-- [ AutoCast (Classic) ]
	AutoCastShine = {
		Width = 32,
		Height = 32,
		OffsetX = 1,
		OffsetY = -1,
	},
	-- [ AutoCastOverlay (Retail) ]
	AutoCast_Mask = {
		Texture = [[Interface\AddOns\Masque\Textures\Modern\AutoCast-Mask]],
		Width = 32,
		Height = 32,
		OffsetX = -0.5,
		OffsetY = 0.5,
	},
	AutoCast_Corners = {
		Atlas = "UI-HUD-ActionBar-PetAutoCast-Corners",
		Width = 38,
		Height = 38,
		OffsetX = -0.5,
		OffsetY = 0.5,
	},
	-- [ Cooldowns ]
	Cooldown = {
		Texture = [[Interface\AddOns\Masque\Textures\Square\Mask]],
		EdgeTexture = [[Interface\AddOns\Masque\Textures\Modern\Edge]],
		Color = {0, 0, 0, 0.7},
		Width = 36,
		Height = 36,
	},
	CooldownLoC = "Cooldown",
	ChargeCooldown = {
		EdgeTexture = [[Interface\AddOns\Masque\Textures\Modern\Edge]],
		Width = 34,
		Height = 34,
	},
	-- [ SpellAlerts ]
	SpellAlert = {
		Width = 44,
		Height = 44,
		AltGlow = {
			Width = 51,
			Height = 51,
		},
		Classic = {
			Height = 34,
			Width = 34,
		},
		Modern = {
			Height = 36,
			Width = 36,
		},
		["Modern-Lite"] = {
			Height = 36.5,
			Width = 36.5,
		},
	},
	AssistedCombatHighlight = {
		Width = 51,
		Height = 51,
	},
})
