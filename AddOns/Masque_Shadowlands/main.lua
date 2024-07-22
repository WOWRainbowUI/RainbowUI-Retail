local ADDON = ...

local MSQ = LibStub and LibStub("Masque", true)
if (not MSQ) then 
	return 
end

local VERSION = C_AddOns.GetAddOnMetadata(ADDON, "Version")
local MASQUE_VERSION = 90002

local path = [[Interface\AddOns\]] .. ADDON .. [[\media\]]
local BLANK = [[Interface\ChatFrame\ChatFrameBackground]]

local pet_scale, button_scale, masque_scale = 30, 36, 36
local function scale(regionSize, buttonSize)
	return regionSize / ((buttonSize or button_scale)/masque_scale)
end

-- Shadowlands inspired Masque skin
MSQ:AddSkin("Shadowlands", {
	Author = "Hodaeg",
	Version = VERSION,
	Shape = "Circle",
	Masque_Version = MASQUE_VERSION,
	Backdrop = {
		Width = scale(44, button_scale),
		Height = scale(44, button_scale),
		TexCoords = { 10/64, 54/64, 10/64, 54/64 },
		Color = { 1, 1, 1, 1 },
		Texture = path .. "backdrop.tga"
	},
	Icon = {
		Width = scale(34, button_scale),
		Height = scale(34, button_scale),
		TexCoords = { 5/64, 59/64, 5/64, 59/64 }
	},
	Flash = {
		Width = scale(34, button_scale),
		Height = scale(34, button_scale),
		Color = { .7, 0, 0, .30 },
		Texture = BLANK
	},
	Cooldown = {
		Width = scale(54, button_scale),
		Height = scale(54, button_scale),
		TexCoords = { 5/64, 59/64, 5/64, 59/64 },
		Color = { 1, 1, 1, .75 },
		Texture = path .. "cooldown.tga"
	},
	Pushed = {
		Width = scale(54, button_scale),
		Height = scale(54, button_scale),
		TexCoords = { 5/64, 59/64, 5/64, 59/64 },
		Color = { 1, 1, 1, 1 },
		Texture = path .. "pushed.tga"
	},
	Normal = {
		Width = scale(54, button_scale),
		Height = scale(54, button_scale),
		TexCoords = { 5/64, 59/64, 5/64, 59/64 },
		Color = { 1, 1, 1, 1 },
		Texture = path .. "normal.tga",
		EmptyTexture = path .. "empty.tga",
		EmptyColor = { 1, 1, 1, 1 }
	},
	Disabled = {
		Hide = true,
	},
	Checked = {
		Width = scale(54, button_scale),
		Height = scale(54, button_scale),
		TexCoords = { 5/64, 59/64, 5/64, 59/64 },
		BlendMode = "BLEND",
		Color = { 1, 1, 1, 1 },
		Texture = path .. "checked.tga"
	},
	Border = {
		Width = scale(54, button_scale),
		Height = scale(54, button_scale),
		TexCoords = { 5/64, 59/64, 5/64, 59/64 },
		BlendMode = "BLEND",
		Texture = path .. "highlight.tga"
	},
	Gloss = {
		Hide = true,
	},
	AutoCastable = {
		Width = scale(86, button_scale),
		Height = scale(86, button_scale),
		OffsetX = 0,
		OffsetY = 0,
		Texture = [[Interface\Buttons\UI-AutoCastableOverlay]]
	},
	Highlight = {
		Width = scale(54, button_scale),
		Height = scale(54, button_scale),
		TexCoords = { 5/64, 59/64, 5/64, 59/64 },
		BlendMode = "BLEND",
		Color = { 1, 1, 1, 1 },
		Texture = path .. "highlight.tga"
	},
	Name = {
		Width = 34,
		Height = 10,
		OffsetY = 4
	},
	Count = {
		Width = 34,
		Height = 10,
		OffsetX = 0,
		OffsetY = 0
	},
	HotKey = {
		Width = 34,
		Height = 10,
		OffsetX = 0
	},
	Duration = {
		Width = 34,
		Height = 10,
		OffsetY = 0
	},
	AutoCast = {
		Width = 24,
		Height = 24,
		OffsetX = 1,
		OffsetY = -1
	}
}, true)