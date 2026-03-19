
local module = {}
local moduleName = "Media"
MikSBT[moduleName] = module

local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations

local string_sub = string.sub
local string_len = string.len

local DEFAULT_SOUND_FILES = {
	["MSBT Low Health"]		= "Interface\\Addons\\MikScrollingBattleText\\Sounds\\LowHealth.ogg",
	["MSBT Low Mana"]		= "Interface\\Addons\\MikScrollingBattleText\\Sounds\\LowMana.ogg",
	["MSBT Cooldown"]		= "Interface\\Addons\\MikScrollingBattleText\\Sounds\\Cooldown.ogg",
}

local DEFAULT_FONT_FILES = L.FONT_FILES

local SML = LibStub("LibSharedMedia-3.0")
local SML_LANG_MASK_ALL = 255

local fonts = {}
local sounds = {}

local function RegisterFont(fontName, fontPath)

	if type(fontName) ~= "string" or type(fontPath) ~= "string" then
		return
	end
	if fontName == "" or fontPath == "" then
		return
	end

	fonts[fontName] = fontPath
	SML:Register("font", fontName, fontPath, SML_LANG_MASK_ALL)
end

local function IterateFonts()
	return pairs(fonts)
end

local function RegisterSound(soundName, soundPath)

	if type(soundName) ~= "string" then
		return
	end

	local soundPathLower = string.lower(soundPath)
	if not soundPath or soundName == "" or soundPath == "" or (type(soundPath) == "string" and ((string.find(soundPathLower, "interface") or 0) ~= 1 or (not string.find(soundPathLower, ".mp3") and not string.find(soundPathLower, ".ogg")))) then
		return
	end

	sounds[soundName] = soundPath

	SML:Register("sound", soundName, soundPath)
end

local function IterateSounds()
	return pairs(sounds)
end

local function SMLRegistered(event, mediaType, name)
	if mediaType == "font" then
		fonts[name] = SML:Fetch(mediaType, name)
	elseif mediaType == "sound" then
		sounds[name] = SML:Fetch(mediaType, name)
	end
end

local function OnVariablesInitialized()

	for fontName, fontPath in pairs(MSBTProfiles.savedMedia.fonts) do
		RegisterFont(fontName, fontPath)
	end
	for soundName, soundPath in pairs(MSBTProfiles.savedMedia.sounds) do
		RegisterSound(soundName, soundPath)
	end
end

for fontName, fontPath in pairs(DEFAULT_FONT_FILES) do
	RegisterFont(fontName, fontPath)
end
for soundName, soundPath in pairs(DEFAULT_SOUND_FILES) do
	RegisterSound(soundName, soundPath)
end

for index, fontName in pairs(SML:List("font")) do
	fonts[fontName] = SML:Fetch("font", fontName)
end
for index, soundName in pairs(SML:List("sound")) do
	sounds[soundName] = SML:Fetch("sound", soundName)
end

SML.RegisterCallback("MSBTSharedMedia", "LibSharedMedia_Registered", SMLRegistered)

module.fonts = fonts
module.sounds = sounds

module.RegisterFont				= RegisterFont
module.RegisterSound			= RegisterSound
module.IterateFonts				= IterateFonts
module.IterateSounds			= IterateSounds
module.OnVariablesInitialized	= OnVariablesInitialized

