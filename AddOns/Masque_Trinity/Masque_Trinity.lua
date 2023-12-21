--Trinity Button Skins, a World of Warcraft® user interface addon plugin.
--Copyright© 2006-2014 Connor H. Chenoweth, aka Maul

--[[ Trinity Button Skins for Masque]]

if not LibStub then return end

local MSQ = LibStub("Masque", true)

if not MSQ then return end

MSQ:AddSkin("Trinity: Round",{

	-- Skin data start.

	Author = "Maul",
	Version = "40300.2",
	Masque_Version = 40200,
	Shape = "Circle",

	Normal = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButton]],
		Static = true,
		Color = {0.65, 0.65, 0.7, 1},
	},
	Pushed = {
		Width = 39,
		Height = 39,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButton]],
		Color = {0.65, 0.65, 0.7, 1},
	},
	Checked = {
		Width = 33,
		Height = 33,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButtonChecked]],
		BlendMode = "ADD",
	},
	Highlight = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButtonHiLight]],
		BlendMode = "ADD",
	},
	Border = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButtonBorder]],
	},
	Gloss = {
		Width = 30,
		Height = 30,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButtonSheen2]],
	},
	Disabled = {
		Hide = true,
	},
	Icon = {
		Width = 23,
		Height = 23,
		TexCoords = {0.07,0.93,0.07,0.93},
	},
	Cooldown = {
		Width = 23,
		Height = 23,
	},
	Backdrop = {
		Width = 23,
		Height = 23,
		Texture = [[Interface\AddOns\Masque_Trinity\images\trinity_button_bg]],
	},
	Name = {
		Width = 32,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = -1,
		OffsetY = 5,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 3,
		OffsetY = -4,
	},
	Duration = {
		Width = 36,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 32,
		Height = 32,
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	AutoCastable = {
		Width = 54,
		Height = 54,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Flash = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
	},
	-- Skin data end.

},true)

MSQ:AddSkin("Trinity: Round v2",{

	-- Skin data start.
	Author = "Maul",
	Version = "40300.2",
	Masque_Version = 40200,
	Shape = "Circle",

	Normal = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButtonNew]],
		Static = true,
		Color = {1, 1, 1, 1},
	},
	Pushed = {
		Width = 39,
		Height = 39,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButtonNew]],
		Color = {1, 1, 1, 1},
	},
	Checked = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButtonCheckedNew]],
		BlendMode = "ADD",
	},
	Highlight = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButtonHiLight]],
		BlendMode = "ADD",
	},
	Border = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButtonBorder]],
	},
	Gloss = {
		Width = 30,
		Height = 30,
		Texture = [[Interface\AddOns\Masque_Trinity\images\round\RoundButtonSheen2]],
	},
	Disabled = {
		Hide = true,
	},
	Icon = {
		Width = 23,
		Height = 23,
		TexCoords = {0.07,0.93,0.07,0.93},
	},
	Cooldown = {
		Width = 23,
		Height = 23,
	},
	Backdrop = {
		Width = 23,
		Height = 23,
		Texture = [[Interface\AddOns\Masque_Trinity\images\trinity_button_bg]],
	},
	Name = {
		Width = 32,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = -1,
		OffsetY = 5,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 3,
		OffsetY = -4,
	},
	Duration = {
		Width = 36,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 32,
		Height = 32,
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	AutoCastable = {
		Width = 54,
		Height = 54,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Flash = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
	},
	-- Skin data end.

},true)

MSQ:AddSkin("Trinity: Diamond",{

	-- Skin data start.
	Author = "Maul",
	Version = "40300.2",
	Masque_Version = 40200,
	Shape = "Square",

	Normal = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\diamond\diamond]],
		Static = true,
		Color = {0.40, 0.15, 0.0, 1},
	},
	Pushed = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\AddOns\Masque_Trinity\images\diamond\diamond]],
		Color = {0.40, 0.15, 0.0, 1},
	},
	Checked = {
		Width = 34,
		Height = 34,
		Texture = [[Interface\AddOns\Masque_Trinity\images\diamond\diamondChecked]],
		BlendMode = "ADD",
	},
	Highlight = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\diamond\diamondHighlight]],
		BlendMode = "ADD",
	},
	Border = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\diamond\diamondBorder]],
	},
	Gloss = {
		Width = 30,
		Height = 30,
		Texture = [[Interface\AddOns\Masque_Trinity\images\diamond\diamondSheen]],
	},
	Disabled = {
		Hide = true,
	},
	Icon = {
		Width = 19,
		Height = 19,
		TexCoords = {0.07,0.93,0.07,0.93},
	},
	Cooldown = {
		Width = 19,
		Height = 19,
	},
	Backdrop = {
		Width = 19,
		Height = 19,
		Texture = [[Interface\AddOns\Masque_Trinity\images\trinity_button_bg]],
	},
	Name = {
		Width = 32,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = -1,
		OffsetY = 5,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 3,
		OffsetY = -4,
	},
	Duration = {
		Width = 36,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 32,
		Height = 32,
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	AutoCastable = {
		Width = 54,
		Height = 54,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Flash = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
	},
	-- Skin data end.

},true)

MSQ:AddSkin("Trinity: Hex 3D",{

	-- Skin data start.
	Author = "Maul",
	Version = "40300.2",
	Masque_Version = 40200,
	Shape = "Square",

	Normal = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\hex\hex]],
		Static = true,
		Color = {0.3, 0.3, 0.3, 1},
	},
	Pushed = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\AddOns\Masque_Trinity\images\hex\hex]],
		Color = {0.3, 0.3, 0.3, 1},
	},
	Checked = {
		Width = 34,
		Height = 34,
		Texture = [[Interface\AddOns\Masque_Trinity\images\hex\hexChecked]],
		BlendMode = "ADD",
	},
	Highlight = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\hex\hexHighlight]],
		BlendMode = "ADD",
	},
	Border = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\hex\hexBorder]],
		BlendMode = "ADD",
	},
	Gloss = {
		Width = 33,
		Height = 33,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\Hex_Sheen]],
	},
	Disabled = {
		Hide = true,
	},
	Icon = {
		Width = 21,
		Height = 21,
		TexCoords = {0.07,0.93,0.07,0.93},
	},
	Cooldown = {
		Width = 21,
		Height = 21,
	},
	Backdrop = {
		Width = 21,
		Height = 21,
		Texture = [[Interface\AddOns\Masque_Trinity\images\trinity_button_bg]],
	},
	Name = {
		Width = 32,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = -1,
		OffsetY = 5,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 3,
		OffsetY = -4,
	},
	Duration = {
		Width = 36,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 32,
		Height = 32,
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	AutoCastable = {
		Width = 54,
		Height = 54,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Flash = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
	},
	-- Skin data end.

},true)

--Adornment skins by Tonedef of WoWInterface

MSQ:AddSkin("Adorn: Light Round",{

	-- Skin data start.
	Author = "Maul",
	Version = "40300.2",
	Masque_Version = 40200,
	Shape = "Circle",

	Normal = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundButton]],
		Static = true,
	},
	Pushed = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundButton]],
	},
	Checked = {
		Width = 34,
		Height = 34,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundButtonChecked]],
		BlendMode = "ADD",
	},
	Highlight = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundButtonHiLight]],
		BlendMode = "ADD",
	},
	Border = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundButtonChecked]],
		BlendMode = "ADD",
	},
	Gloss = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundButtonSheen]],
	},
	Disabled = {
		Hide = true,
	},
	Icon = {
		Width = 23,
		Height = 23,
		TexCoords = {0.07,0.93,0.07,0.93},
	},
	Cooldown = {
		Width = 23,
		Height = 23,
	},
	Backdrop = {
		Width = 23,
		Height = 23,
		Texture = [[Interface\AddOns\Masque_Trinity\images\trinity_button_bg]],
	},
	Name = {
		Width = 32,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = -1,
		OffsetY = 5,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 3,
		OffsetY = -4,
	},
	Duration = {
		Width = 36,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 32,
		Height = 32,
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	AutoCastable = {
		Width = 54,
		Height = 54,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Flash = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
	},
	-- Skin data end.

},true)

MSQ:AddSkin("Adorn: Dark Round",{

	-- Skin data start.
	Author = "Maul",
	Version = "40300.2",
	Masque_Version = 40200,
	Shape = "Circle",

	Normal = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundDark_Frame]],
		Static = true,
	},
	Pushed = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundDark_Frame]],
	},
	Checked = {
		Width = 34,
		Height = 34,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundButtonChecked]],
		BlendMode = "ADD",
	},
	Highlight = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundButtonHiLight]],
		BlendMode = "ADD",
	},
	Border = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundButtonChecked]],
		BlendMode = "ADD",
	},
	Gloss = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\round\GlowRoundButtonSheen]],
	},
	Disabled = {
		Hide = true,
	},
	Icon = {
		Width = 23,
		Height = 23,
		TexCoords = {0.07,0.93,0.07,0.93},
	},
	Cooldown = {
		Width = 23,
		Height = 23,
	},
	Backdrop = {
		Width = 23,
		Height = 23,
		Texture = [[Interface\AddOns\Masque_Trinity\images\trinity_button_bg]],
	},
	Name = {
		Width = 32,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = -1,
		OffsetY = 5,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 3,
		OffsetY = -4,
	},
	Duration = {
		Width = 36,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 32,
		Height = 32,
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	AutoCastable = {
		Width = 54,
		Height = 54,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Flash = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
	},
	-- Skin data end.

},true)

MSQ:AddSkin("Adorn: Light Square",{

	-- Skin data start.
	Author = "Maul",
	Version = "40300.2",
	Masque_Version = 40200,
	Shape = "Square",

	Normal = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquare_Frame]],
		Static = true,
	},
	Pushed = {
		Width = 34,
		Height = 34,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquare_Frame]],
	},
	Checked = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquare_Checked]],
		BlendMode = "ADD",
	},
	Highlight = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquare_highlight]],
		BlendMode = "ADD",
	},
	Border = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquare_Checked]],
		BlendMode = "ADD",
	},
	Gloss = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquare_Sheen]],
	},
	Disabled = {
		Hide = true,
	},
	Icon = {
		Width = 30,
		Height = 30,
		TexCoords = {0.07,0.93,0.07,0.93},
	},
	Cooldown = {
		Width = 30,
		Height = 30,
	},
	Backdrop = {
		Width = 30,
		Height = 30,
		Texture = [[Interface\AddOns\Masque_Trinity\images\trinity_button_bg]],
	},
	Name = {
		Width = 32,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = -1,
		OffsetY = 5,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 3,
		OffsetY = -4,
	},
	Duration = {
		Width = 36,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 32,
		Height = 32,
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	AutoCastable = {
		Width = 54,
		Height = 54,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Flash = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
	},
	-- Skin data end.

},true)

MSQ:AddSkin("Adorn: Dark Square",{

	-- Skin data start.
	Author = "Maul",
	Version = "40300.2",
	Masque_Version = 40200,
	Shape = "Square",

	Normal = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquareDark_Frame]],
		Static = true,
	},
	Pushed = {
		Width = 34,
		Height = 34,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquareDark_Frame]],
	},
	Checked = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquare_Checked]],
		BlendMode = "ADD",
	},
	Highlight = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquare_highlight]],
		BlendMode = "ADD",
	},
	Border = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquare_Checked]],
		BlendMode = "ADD",
	},
	Gloss = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\square\GlowSquare_Sheen2]],
	},
	Disabled = {
		Hide = true,
	},
	Icon = {
		Width = 30,
		Height = 30,
		TexCoords = {0.07,0.93,0.07,0.93},
	},
	Cooldown = {
		Width = 30,
		Height = 30,
	},
	Backdrop = {
		Width = 30,
		Height = 30,
		Texture = [[Interface\AddOns\Masque_Trinity\images\trinity_button_bg]],
	},
	Name = {
		Width = 32,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = -1,
		OffsetY = 5,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 3,
		OffsetY = -4,
	},
	Duration = {
		Width = 36,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 32,
		Height = 32,
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	AutoCastable = {
		Width = 54,
		Height = 54,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Flash = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
	},
	-- Skin data end.

},true)

MSQ:AddSkin("Adorn: Light Hex",{

	-- Skin data start.
	Author = "Maul",
	Version = "40300.2",
	Masque_Version = 40200,
	Shape = "Square",

	Normal = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\Hex_Frame]],
		Static = true,
	},
	Pushed = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\Hex_Frame]],
	},
	Checked = {
		Width = 34,
		Height = 34,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\Hex_Checked]],
		BlendMode = "ADD",
	},
	Highlight = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\Hex_highlight]],
		BlendMode = "ADD",
	},
	Border = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\Hex_Checked]],
		BlendMode = "ADD",
	},
	Gloss = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\Hex_Sheen]],
	},
	Disabled = {
		Hide = true,
	},
	Icon = {
		Width = 21,
		Height = 21,
		TexCoords = {0.07,0.93,0.07,0.93},
	},
	Cooldown = {
		Width = 21,
		Height = 21,
	},
	Backdrop = {
		Width = 21,
		Height = 21,
		Texture = [[Interface\AddOns\Masque_Trinity\images\trinity_button_bg]],
	},
	Name = {
		Width = 32,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = -1,
		OffsetY = 5,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 3,
		OffsetY = -4,
	},
	Duration = {
		Width = 36,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 32,
		Height = 32,
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	AutoCastable = {
		Width = 54,
		Height = 54,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Flash = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
	},
	-- Skin data end.

},true)

MSQ:AddSkin("Adorn: Dark Hex",{

	-- Skin data start.
	Author = "Maul",
	Version = "40300.2",
	Masque_Version = 40200,
	Shape = "Square",

	Normal = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\HexDark_Frame]],
		Static = true,
	},
	Pushed = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\HexDark_Frame]],
	},
	Checked = {
		Width = 34,
		Height = 34,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\Hex_Checked]],
		BlendMode = "ADD",
	},
	Highlight = {
		Width = 36,
		Height = 36,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\Hex_highlight]],
		BlendMode = "ADD",
	},
	Border = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\Hex_Checked]],
		BlendMode = "ADD",
	},
	Gloss = {
		Width = 35,
		Height = 35,
		Texture = [[Interface\AddOns\Masque_Trinity\images\adornment\hex\Hex_Sheen]],
	},
	Disabled = {
		Hide = true,
	},
	Icon = {
		Width = 21,
		Height = 21,
		TexCoords = {0.07,0.93,0.07,0.93},
	},
	Cooldown = {
		Width = 21,
		Height = 21,
	},
	Backdrop = {
		Width = 21,
		Height = 21,
		Texture = [[Interface\AddOns\Masque_Trinity\images\trinity_button_bg]],
	},
	Name = {
		Width = 32,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = -1,
		OffsetY = 5,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 3,
		OffsetY = -4,
	},
	Duration = {
		Width = 36,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 32,
		Height = 32,
		OffsetX = 0.5,
		OffsetY = -0.5
	},
	AutoCastable = {
		Width = 54,
		Height = 54,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Flash = {
		Width = 32,
		Height = 32,
		Texture = [[Interface\Buttons\UI-QuickslotRed]],
	},
	-- Skin data end.

},true)
