local MSQ = LibStub("Masque", true)
if not MSQ then return end

-- Diablo III - Square
MSQ:AddSkin("Diablo III - Square", {
	Author = "Suicidal Katt",
	Version = "1.0",
	Shape = "Square",
	Masque_Version = 40200,
	Backdrop = {
		Width = 36,
		Height = 36,
		Color = {0.8, 0.8, 0.8, 1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\Backdrop]],
	},
	Icon = {
		Width = 36,
		Height = 36,
		TexCoords = {0.08,0.92,0.08,0.92},
	},
	Flash = {
		Width = 40,
		Height = 40,
		Color = {1, 0, 0, 1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\Highlight]],
	},
	Cooldown = {
		Width = 36,
		Height = 36,
	},
	Pushed = {
		Width = 40,
		Height = 40,
		Color = {1,1,1,1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\Border]],
	},
	Normal = {
		Width = 40,
		Height = 40,
		Color = {0.7,0.7,0.7,1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\Normal]],
	},
	Disabled = {
		Hide = true,
	},
	Checked = {
		Width = 40,
		Height = 40,
		BlendMode = "BLEND",
		Color = {1,1,1,1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\Overlay]],
	},
	Border = {
		Width = 40,
		Height = 40,
		BlendMode = "BLEND",
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\Highlight]],
	},
	Gloss = {
		Width = 40,
		Height = 40,
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\Gloss]],
	},
	AutoCastable = {
		Width = 64,
		Height = 64,
		OffsetX = 0.5,
		OffsetY = -0.5,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Highlight = {
		Width = 40,
		Height = 40,
		BlendMode = "ADD",
		Color = {1, 1, 1, 1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\Highlight]],
	},
	Name = {
		Width = 36,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = 2,
		OffsetY = 2,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 6,
	},
	Duration = {
		Width = 32,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 24,
		Height = 24,
		OffsetX = 1,
		OffsetY = -1,
	},
}, true)

-- Diablo III - Circle
MSQ:AddSkin("Diablo III - Circle", {
	Author = "Suicidal Katt",
	Version = "1.0",
	Shape = "Circle",
	Masque_Version = 40200,
	Backdrop = {
		Width = 36,
		Height = 36,
		Color = {0.8, 0.8, 0.8, 1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SBackdrop]],
	},
	Icon = {
		Width = 26,
		Height = 26,
		OffsetY = -1,
		TexCoords = {0.08,0.92,0.08,0.92},
	},
	Flash = {
		Width = 40,
		Height = 40,
		Color = {1, 0, 0, 1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SHighlight]],
	},
	Cooldown = {
		Width = 27,
		Height = 27,
	},
	Pushed = {
		Width = 40,
		Height = 40,
		Color = {1,1,1,1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SBorder]],
	},
	Normal = {
		Width = 40,
		Height = 40,
		Color = {0.7,0.7,0.7,1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SNormal]],
	},
	Disabled = {
		Hide = true,
	},
	Checked = {
		Width = 40,
		Height = 40,
		BlendMode = "BLEND",
		Color = {1,1,1,1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SOverlay]],
	},
	Border = {
		Width = 40,
		Height = 40,
		BlendMode = "BLEND",
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SHighlight]],
	},
	Gloss = {
		Width = 40,
		Height = 40,
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SGloss]],
	},
	AutoCastable = {
		Width = 64,
		Height = 64,
		OffsetX = 0.5,
		OffsetY = -0.5,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Highlight = {
		Width = 40,
		Height = 40,
		BlendMode = "ADD",
		Color = {1, 1, 1, 1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SHighlight]],
	},
	Name = {
		Width = 36,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = 2,
		OffsetY = 2,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 6,
	},
	Duration = {
		Width = 32,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 24,
		Height = 24,
		OffsetX = 1,
		OffsetY = -1,
	},
}, true)

-- Diablo III - Spiked
MSQ:AddSkin("Diablo III - Spiked", {
	Author = "Suicidal Katt",
	Version = "1.0",
	Shape = "Circle",
	Masque_Version = 40200,
	Backdrop = {
		Width = 36,
		Height = 36,
		Color = {0.8, 0.8, 0.8, 1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SBackdrop]],
	},
	Icon = {
		Width = 32,
		Height = 32,
		TexCoords = {0.08,0.92,0.08,0.92},
	},
	Flash = {
		Width = 40,
		Height = 40,
		Color = {1, 0, 0, 1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SpHighlight]],
	},
	Cooldown = {
		Width = 36,
		Height = 36,
	},
	Pushed = {
		Width = 40,
		Height = 40,
		Color = {1,1,1,1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SpBorder]],
	},
	Normal = {
		Width = 40,
		Height = 40,
		Color = {0.7,0.7,0.7,1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SpNormal]],
	},
	Disabled = {
		Hide = true,
	},
	Checked = {
		Width = 40,
		Height = 40,
		BlendMode = "BLEND",
		Color = {1,1,1,1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SpOverlay]],
	},
	Border = {
		Width = 40,
		Height = 40,
		BlendMode = "BLEND",
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SpHighlight]],
	},
	Gloss = {
		Width = 40,
		Height = 40,
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SGloss]],
	},
	AutoCastable = {
		Width = 64,
		Height = 64,
		OffsetX = 0.5,
		OffsetY = -0.5,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]],
	},
	Highlight = {
		Width = 40,
		Height = 40,
		BlendMode = "ADD",
		Color = {1, 1, 1, 1},
		Texture = [[Interface\AddOns\Masque_Diablo_III\Textures\SpHighlight]],
	},
	Name = {
		Width = 36,
		Height = 10,
		OffsetY = 4,
	},
	Count = {
		Width = 32,
		Height = 10,
		OffsetX = 2,
		OffsetY = 2,
	},
	HotKey = {
		Width = 32,
		Height = 10,
		OffsetX = 6,
	},
	Duration = {
		Width = 32,
		Height = 10,
		OffsetY = -2,
	},
	AutoCast = {
		Width = 24,
		Height = 24,
		OffsetX = 1,
		OffsetY = -1,
	},
}, true)