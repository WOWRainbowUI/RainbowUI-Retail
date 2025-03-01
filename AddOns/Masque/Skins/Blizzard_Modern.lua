--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For bug reports,
	suggestions and license information, please visit https://github.com/SFX-WoW/Masque.

	* File...: Skins\Blizzard_Modern.lua
	* Author.: Blizzard Entertainment

	"Blizzard Modern" Skin

	Notes:
	* Emulates the default Dragonflight button style.
	* Some attributes are modified for internal consistency.

]]

local _, Core = ...

if not Core.WOW_RETAIL then return end

----------------------------------------
-- Internal
---

-- @ Locales\enUS
local L = Core.Locale

-- @ Skins\Skins
local Hidden = Core.__Hidden

----------------------------------------
-- Blizzard Modern
---

local SkinID = "Blizzard Modern"

local Skin = {
	API_VERSION = Core.API_VERSION,
	Shape = "Blizzard",
	SkinID = SkinID,

	-- Info
	Description = L["The default Dragonflight button style."],
	Version = Core.Version,
	Author = "|cff0099ffBlizzard Entertainment|r",

	-- Skin
	Mask = {
		-- Key = "IconMask",
		Atlas = "UI-HUD-ActionBar-IconFrame-Mask",
		UseAtlasSize = false,
		WrapH = "CLAMPTOBLACKADDITIVE",
		WrapV = "CLAMPTOBLACKADDITIVE",
		Width = 51,
		Height = 51,
		Anchor = "Icon",
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		BagSlot = {
			-- Key = "CircleMask",
			Texture = [[Interface\CharacterFrame\TempPortraitAlphaMask]],
			WrapH = "CLAMPTOBLACKADDITIVE",
			WrapV = "CLAMPTOBLACKADDITIVE",
			Width = 28,
			Height = 28,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = -1,
			OffsetY = 1,
		},
	},
	Backdrop = {
		Atlas = "UI-HUD-ActionBar-IconFrame-Slot",
		UseAtlasSize = false,
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "BACKGROUND",
		DrawLevel = -1,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = true,
		-- UseColor = nil,
		Backpack = Hidden,
		BagSlot = {
			-- Atlas = "bags-item-slot64",
			-- UseAtlasSize = false,
			Texture = [[Interface\Addons\Masque\Textures\Backdrop\Slot-Modern]],
			--Color = {1, 1, 1, 0.8},
			BlendMode = "BLEND",
			DrawLayer = "BACKGROUND",
			DrawLevel = -1,
			Width = 36, -- 64
			Height = 36, -- 64
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			UseMask = true,
			SetAllPoints = true,
			-- UseColor = nil,
		},
		Item = {
			Atlas = "bags-item-slot64",
			UseAtlasSize = false,
			-- Color = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "BACKGROUND",
			DrawLevel = -1,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = true,
			-- UseColor = nil,
		},
	},
	Icon = {
		-- TexCoords = {0, 1, 0, 1},
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
		UseMask = true,
		Aura = {
			-- TexCoords = {0, 1, 0, 1},
			Width = 36,
			Height = 36,
			Point = "TOP",
			RelPoint = "TOP",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
			-- UseMask = true,
		},
		BagSlot = {
			-- TexCoords = {0, 1, 0, 1},
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
			UseMask = true,
		},
		Item = {
			-- TexCoords = {0, 1, 0, 1},
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
		},
	},
	SlotIcon = Hidden,
	Shadow = Hidden,
	Normal = {
		Atlas = "UI-HUD-ActionBar-IconFrame",
		-- EmptyAtlas = "UI-HUD-ActionBar-IconFrame",
		UseAtlasSize = false,
		-- Color = {1, 1, 1, 1},
		-- EmptyColor = {1, 1, 1, 0.5},
		BlendMode = "BLEND",
		DrawLayer = "ARTWORK",
		DrawLevel = 0,
		Width = 37,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 1,
		OffsetY = -0.5,
		-- SetAllPoints = nil,
		-- UseStates = true,
		Aura = Hidden,
		Backpack = {
			Atlas = "bag-main",
			-- EmptyAtlas = "bag-main",
			UseAtlasSize = false,
			-- Color = {1, 1, 1, 1},
			-- EmptyColor = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
			UseStates = true,
		},
		BagSlot = {
			Atlas = "bag-border",
			-- EmptyAtlas = "bag-border-empty",
			UseAtlasSize = false,
			-- Color = {1, 1, 1, 1},
			-- EmptyColor = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			SetAllPoints = true,
			UseStates = true,
		},
		Item = {
			Texture = [[Interface\Buttons\UI-Quickslot2]],
			-- EmptyTexture = "Interface\\Buttons\\UI-Quickslot2",
			-- TexCoords = {0, 1, 0, 1},
			-- EmptyCoords = {0, 1, 0, 1},
			-- Color = {1, 1, 1, 1},
			-- EmptyColor = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 62,
			Height = 62,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0.5,
			OffsetY = -0.5,
			-- SetAllPoints = nil,
			UseStates = true,
		},
		ReagentBag = {
			Atlas = "bag-reagent-border",
			-- EmptyAtlas = "bag-reagent-border-empty",
			UseAtlasSize = false,
			-- Color = {1, 1, 1, 1},
			-- EmptyColor = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			SetAllPoints = true,
			UseStates = true,
		},
	},
	Disabled = Hidden,
	Pushed = {
		Atlas = "UI-HUD-ActionBar-IconFrame-Down",
		UseAtlasSize = false,
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "ARTWORK",
		DrawLevel = 0,
		Width = 37,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 1,
		OffsetY = -0.5,
		-- SetAllPoints = nil,
		-- UseColor = nil,
		Backpack = {
			Atlas = "bag-main",
			UseAtlasSize = false,
			-- Color = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			--SetAllPoints = true,
			-- UseColor = nil,
		},
		BagSlot = {
			Atlas = "bag-border",
			UseAtlasSize = false,
			-- Color = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			SetAllPoints = true,
			-- UseColor = nil,
		},
		Item = {
			Texture = [[Interface\Buttons\UI-Quickslot-Depress]],
			-- TexCoords = {0, 1, 0, 1},
			-- Color = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
		},
		ReagentBag = {
			Atlas = "bag-reagent-border",
			UseAtlasSize = false,
			-- Color = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			SetAllPoints = true,
		},
	},
	Flash = {
		Atlas = "UI-HUD-ActionBar-IconFrame-Flash",
		UseAtlasSize = false, --true
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "ARTWORK",
		DrawLevel = 1,
		Width = 37,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = 0,
		-- SetAllPoints = nil,
		-- UseColor = nil,
		Item = { -- Unused
			Atlas = "bags-glow-flash",
			UseAtlasSize = true,
			-- Color = {1, 1, 1, 1},
			BlendMode = "ADD",
			DrawLayer = "OVERLAY",
			DrawLevel = 2,
			Width = 90,
			Height = 90,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
			-- UseColor = nil,
		},
	},
	HotKey = {
		JustifyH = "RIGHT",
		JustifyV = "MIDDLE",
		DrawLayer = "OVERLAY",
		Width = 32,
		Height = 0,
		Anchor = "Icon",
		Point = "TOPRIGHT",
		RelPoint = "TOPRIGHT",
		OffsetX = -4,
		OffsetY = -4,
		Pet = {
			JustifyH = "RIGHT",
			JustifyV = "MIDDLE",
			DrawLayer = "ARTWORK",
			Width = 36,
			Height = 0,
			Anchor = "Icon",
			Point = "TOPRIGHT",
			RelPoint = "TOPRIGHT",
			OffsetX = -3,
			OffsetY = -3,
		},
	},
	Count = {
		JustifyH = "RIGHT",
		JustifyV = "MIDDLE",
		DrawLayer = "OVERLAY",
		Width = 0,
		Height = 0,
		Anchor = "Icon",
		Point = "BOTTOMRIGHT",
		RelPoint = "BOTTOMRIGHT",
		OffsetX = -5,
		OffsetY = 5,
		Aura = {
			JustifyH = "RIGHT",
			JustifyV = "MIDDLE",
			DrawLayer = "ARTWORK",
			Width = 36,
			Height = 0,
			Anchor = "Icon",
			Point = "BOTTOMRIGHT",
			RelPoint = "BOTTOMRIGHT",
			OffsetX = -2,
			OffsetY = 2,
		},
		Item = {
			JustifyH = "RIGHT",
			JustifyV = "MIDDLE",
			DrawLayer = "ARTWORK",
			Width = 0,
			Height = 0,
			Anchor = "Icon",
			Point = "BOTTOMRIGHT",
			RelPoint = "BOTTOMRIGHT",
			OffsetX = -5,
			OffsetY = 2,
		},
	},
	Duration = {
		JustifyH = "CENTER",
		JustifyV = "MIDDLE",
		DrawLayer = "OVERLAY",
		Width = 36,
		Height = 0,
		Anchor = "Icon",
		Point = "TOP",
		RelPoint = "BOTTOM",
		OffsetX = 0,
		OffsetY = 0,
	},
	Checked = {
		Atlas = "UI-HUD-ActionBar-IconFrame-Mouseover",
		UseAtlasSize = false,
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 37,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	SlotHighlight = {
		Atlas = "bag-border-highlight",
		UseAtlasSize = false,
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "ARTWORK",
		DrawLevel = 0,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		SetAllPoints = true,
		Backpack = {
			Atlas = "bag-main-highlight",
			UseAtlasSize = false,
			-- Color = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "ARTWORK",
			DrawLevel = 0,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
		},
	},
	Name = {
		JustifyH = "CENTER",
		JustifyV = "MIDDLE",
		DrawLayer = "OVERLAY",
		Width = 36,
		Height = 0,
		Anchor = "Icon",
		Point = "BOTTOM",
		RelPoint = "BOTTOM",
		OffsetX = 0,
		OffsetY = 2,
	},
	Border = {
		Atlas = "UI-HUD-ActionBar-IconFrame-Border",
		UseAtlasSize = false, -- true
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 37,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = 0,
		-- SetAllPoints = nil,
		Debuff = {
			Texture = [[Interface\Buttons\UI-Debuff-Overlays]],
			TexCoords = {0.296875, 0.5703125, 0, 0.515625},
			-- Color = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "OVERLAY",
			DrawLevel = 0,
			Width = 40,
			Height = 38,
			Anchor = "Icon",
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
		},
		Enchant = {
			Texture = [[Interface\Buttons\UI-TempEnchant-Border]],
			-- TexCoords = {0, 1, 0, 1},
			-- Color = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "OVERLAY",
			DrawLevel = 0,
			Width = 38,
			Height = 38,
			Anchor = "Icon",
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
		},
		Item = {
			Texture = [[Interface\Common\WhiteIconFrame]],
			-- TexCoords = {0, 1, 0, 1},
			-- Color = {1, 1, 1, 1},
			BlendMode = "BLEND",
			DrawLayer = "OVERLAY",
			DrawLevel = 0,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
		},
	},
	DebuffBorder = {
		Texture = [[Interface\Buttons\UI-Debuff-Overlays]],
		TexCoords = {0.296875, 0.5703125, 0, 0.515625},
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 40,
		Height = 38,
		Anchor = "Icon",
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	EnchantBorder = {
		Texture = [[Interface\Buttons\UI-TempEnchant-Border]],
		-- TexCoords = {0, 1, 0, 1},
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 38,
		Height = 38,
		Anchor = "Icon",
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	IconBorder = {
		Texture = [[Interface\Common\WhiteIconFrame]],
		RelicTexture = [[Interface\Artifacts\RelicIconFrame]],
		-- TexCoords = {0, 1, 0, 1},
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	Gloss = Hidden,
	NewAction = {
		Atlas = "UI-HUD-ActionBar-IconFrame-Mouseover",
		UseAtlasSize = false, -- true
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 37,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	SpellHighlight = {
		Atlas = "UI-HUD-ActionBar-IconFrame-Mouseover",
		UseAtlasSize = false, -- true
		Color = {1, 1, 1, 0.4},
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 37,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	AutoCastable = {
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
		-- TexCoords = {0, 1, 0, 1},
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 64,
		Height = 64,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = -0.5,
		-- SetAllPoints = nil,
	},
	IconOverlay = {
		Atlas = "AzeriteIconFrame",
		UseAtlasSize = false,
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 37,
		Height = 37,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	UpgradeIcon = {
		Atlas = "bags-greenarrow",
		UseAtlasSize = true,
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 20,
		Height = 22,
		Point = "TOPLEFT",
		RelPoint = "TOPLEFT",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	IconOverlay2 = {
		Atlas = "ConduitIconFrame-Corners",
		UseAtlasSize = false,
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 2,
		Width = 37,
		Height = 37,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	QuestBorder = {
		Border = [[Interface\ContainerFrame\UI-Icon-QuestBang]],
		Texture = [[Interface\ContainerFrame\UI-Icon-QuestBorder]],
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 2,
		Width = 36,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	NewItem = {
		Atlas = "bags-glow-white",
		UseAtlasSize = true,
		-- Color = {1, 1, 1, 1},
		BlendMode = "ADD",
		DrawLayer = "OVERLAY",
		DrawLevel = 2,
		Width = 37,
		Height = 37,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	SearchOverlay = {
		-- Texture = nil,
		-- TexCoords = {0, 1, 0, 1},
		Color = {0, 0, 0, 0.8},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 4,
		Width = 37,
		Height = 37,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = true,
		UseColor = true,
		UseMask = true,
	},
	ContextOverlay = {
		-- Texture = nil,
		-- TexCoords = {0, 1, 0, 1},
		Color = {0, 0, 0, 0.8},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 4,
		Width = 37,
		Height = 37,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = true,
		UseColor = true,
		UseMask = true,
	},
	JunkIcon = {
		Atlas = "bags-junkcoin",
		UseAtlasSize = true,
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 5,
		Width = 20,
		Height = 18,
		Point = "TOPLEFT",
		RelPoint = "TOPLEFT",
		OffsetX = 1,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	Highlight = {
		Atlas = "UI-HUD-ActionBar-IconFrame-Mouseover",
		UseAtlasSize = false,
		-- Color = {1, 1, 1, 1},
		BlendMode = "ADD",
		DrawLayer = "HIGHLIGHT",
		DrawLevel = 0,
		Width = 37,
		Height = 36,
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0.5,
		OffsetY = 0,
		-- SetAllPoints = nil,
		-- UseColor = nil,
		Backpack = {
			Atlas = "bag-main-highlight",
			UseAtlasSize = false,
			Color = {1, 1, 1, 0.4},
			BlendMode = "ADD",
			DrawLayer = "HIGHLIGHT",
			DrawLevel = 0,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
			-- UseColor = nil,
		},
		BagSlot = {
			Atlas = "bag-border-highlight",
			UseAtlasSize = false,
			Color = {1, 1, 1, 0.4},
			BlendMode = "ADD",
			DrawLayer = "HIGHLIGHT",
			DrawLevel = 0,
			Width = 36,
			Height = 36,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
			-- UseColor = nil,
		},
		Item = {
			Texture = [[Interface\Buttons\ButtonHilight-Square]],
			-- TexCoords = {0, 1, 0, 1},
			-- Color = {1, 1, 1, 1},
			BlendMode = "ADD",
			DrawLayer = "HIGHLIGHT",
			DrawLevel = 0,
			Width = 37,
			Height = 37,
			Point = "CENTER",
			RelPoint = "CENTER",
			OffsetX = 0,
			OffsetY = 0,
			-- SetAllPoints = nil,
			-- UseColor = nil,
		},
	},
	-- [ AutoCastOverlay (Retail) ]
	-- AB (45) / SAB (30) = 1.5
	-- Lua @ SAB: 31 * 1.5 = 46.5
	-- Masque: 46.5 / 1.25 = 37.2
	-- Multiplier = 1.2 (1.5 / 1.25)
	AutoCast_Frame = {
		Width = 37, -- 31
		Height = 37, -- 31
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	AutoCast_Shine = {
		Atlas = "UI-HUD-ActionBar-PetAutoCast-Ants",
		UseAtlasSize = false,
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 0,
		Width = 49, -- 41
		Height = 49, -- 41
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	AutoCast_Mask = {
		Atlas = "UI-HUD-ActionBar-PetAutoCast-Mask",
		UseAtlasSize = false,
		Width = 28, -- 23
		Height = 28, -- 23
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	AutoCast_Corners = {
		Atlas = "UI-HUD-ActionBar-PetAutoCast-Corners",
		UseAtlasSize = false,
		-- Color = {1, 1, 1, 1},
		BlendMode = "BLEND",
		DrawLayer = "OVERLAY",
		DrawLevel = 1,
		Width = 37, -- 31
		Height = 37, -- 31
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		SetAllPoints = true,
	},
	-- [ AutoCastShine (Classic) ]
	AutoCastShine = {
		Width = 33, -- 40/28
		Height = 33, -- 40/28
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 1,
		OffsetY = -0.5,
		-- SetAllPoints = nil,
	},
	-- [ Cooldowns ]
	Cooldown = {
		Texture = [[Interface\AddOns\Masque\Textures\Modern\Mask]],
		EdgeTexture = [[Interface\Cooldown\UI-HUD-ActionBar-SecondaryCooldown]],
		PulseTexture = [[Interface\Cooldown\star4]],
		Color = {0, 0, 0, 0.8},
		Width = 31,
		Height = 31,
		Anchor = "Icon",
		Point = "CENTER",
		RelPoint = "CENTER",
		OffsetX = 0,
		OffsetY = 0,
		-- SetAllPoints = nil,
	},
	ChargeCooldown = "Cooldown",
	-- [ SpellAlert ]
	-- SpellAlert = Default.SpellAlert,
}

----------------------------------------
-- Core
---

Core.AddSkin(SkinID, Skin, true)

Core.DEFAULT_SKIN = Skin
Core.DEFAULT_SKIN_ID = SkinID
