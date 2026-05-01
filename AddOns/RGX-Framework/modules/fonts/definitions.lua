local _, addon = ...
local Fonts = {}
addon._fontsModule = Fonts
_G.RGXFonts = Fonts

Fonts.fontPath = "Interface/AddOns/RGX-Framework/media/fonts/"

Fonts.unavailableFonts = {
	["Audiowide-Regular"] = true,
	["Cinzel-Regular"] = true,
	["Merriweather-Regular"] = true,
	["Merriweather-Bold"] = true,
	["Montserrat-Regular"] = true,
	["Montserrat-Bold"] = true,
	["Orbitron-Regular"] = true,
	["Oswald-Regular"] = true,
	["PlayfairDisplay-Regular"] = true,
	["PlayfairDisplay-Bold"] = true,
}

Fonts.definitions = {
	["Inter-Regular"] = {
		file = "Inter-Regular.otf",
		family = "Inter",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["Inter-Bold"] = {
		file = "Inter-Bold.otf",
		family = "Inter",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["CrimsonText-Regular"] = {
		file = "CrimsonText-Regular.ttf",
		family = "Crimson Text",
		category = "Serif",
		license = "OFL 1.1",
	},
	["PressStart2P-Regular"] = {
		file = "PressStart2P-Regular.ttf",
		family = "Press Start 2P",
		category = "Pixel",
		license = "OFL 1.1",
	},
	["VT323-Regular"] = {
		file = "VT323-Regular.ttf",
		family = "VT323",
		category = "Pixel",
		license = "OFL 1.1",
	},
	["DejaVuSans"] = {
		file = "DejaVuSans.ttf",
		family = "DejaVu Sans",
		category = "Sans-serif",
		license = "Public Domain",
	},
	["DejaVuSans-Bold"] = {
		file = "DejaVuSans-Bold.ttf",
		family = "DejaVu Sans",
		category = "Sans-serif",
		license = "Public Domain",
	},
	["DejaVuSansCondensed"] = {
		file = "DejaVuSansCondensed.ttf",
		family = "DejaVu Sans Condensed",
		category = "Sans-serif",
		license = "Public Domain",
	},
	["DejaVuSansCondensed-Bold"] = {
		file = "DejaVuSansCondensed-Bold.ttf",
		family = "DejaVu Sans Condensed",
		category = "Sans-serif",
		license = "Public Domain",
	},
	["LiberationSans-Regular"] = {
		file = "LiberationSans-Regular.ttf",
		family = "Liberation Sans",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["LiberationSans-Bold"] = {
		file = "LiberationSans-Bold.ttf",
		family = "Liberation Sans",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["LiberationSans-Italic"] = {
		file = "LiberationSans-Italic.ttf",
		family = "Liberation Sans",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["LiberationSans-BoldItalic"] = {
		file = "LiberationSans-BoldItalic.ttf",
		family = "Liberation Sans",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["Ubuntu-Regular"] = {
		file = "Ubuntu-Regular.ttf",
		family = "Ubuntu",
		category = "Sans-serif",
		license = "Ubuntu Font License",
	},
	["Ubuntu-Bold"] = {
		file = "Ubuntu-Bold.ttf",
		family = "Ubuntu",
		category = "Sans-serif",
		license = "Ubuntu Font License",
	},
	["Lato-Regular"] = {
		file = "Lato-Regular.ttf",
		family = "Lato",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["Lato-Bold"] = {
		file = "Lato-Bold.ttf",
		family = "Lato",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["Poppins-Regular"] = {
		file = "Poppins-Regular.ttf",
		family = "Poppins",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["Poppins-Bold"] = {
		file = "Poppins-Bold.ttf",
		family = "Poppins",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["Montserrat-Regular"] = {
		file = "Montserrat-Regular.ttf",
		family = "Montserrat",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["Montserrat-Bold"] = {
		file = "Montserrat-Bold.ttf",
		family = "Montserrat",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["Oswald-Regular"] = {
		file = "Oswald-Regular.ttf",
		family = "Oswald",
		category = "Display",
		license = "OFL 1.1",
	},
	["Rajdhani-Regular"] = {
		file = "Rajdhani-Regular.ttf",
		family = "Rajdhani",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["Rajdhani-Bold"] = {
		file = "Rajdhani-Bold.ttf",
		family = "Rajdhani",
		category = "Sans-serif",
		license = "OFL 1.1",
	},
	["IBMPlexMono-Regular"] = {
		file = "IBMPlexMono-Regular.ttf",
		family = "IBM Plex Mono",
		category = "Monospace",
		license = "OFL 1.1",
	},
	["JetBrainsMono-Regular"] = {
		file = "JetBrainsMono-Regular.ttf",
		family = "JetBrains Mono",
		category = "Monospace",
		license = "OFL 1.1",
	},
	["JetBrainsMono-Bold"] = {
		file = "JetBrainsMono-Bold.ttf",
		family = "JetBrains Mono",
		category = "Monospace",
		license = "OFL 1.1",
	},
	["Merriweather-Regular"] = {
		file = "Merriweather-Regular.ttf",
		family = "Merriweather",
		category = "Serif",
		license = "OFL 1.1",
	},
	["Merriweather-Bold"] = {
		file = "Merriweather-Bold.ttf",
		family = "Merriweather",
		category = "Serif",
		license = "OFL 1.1",
	},
	["PlayfairDisplay-Regular"] = {
		file = "PlayfairDisplay-Regular.ttf",
		family = "Playfair Display",
		category = "Serif",
		license = "OFL 1.1",
	},
	["PlayfairDisplay-Bold"] = {
		file = "PlayfairDisplay-Bold.ttf",
		family = "Playfair Display",
		category = "Serif",
		license = "OFL 1.1",
	},
	["BebasNeue-Regular"] = {
		file = "BebasNeue-Regular.ttf",
		family = "Bebas Neue",
		category = "Display",
		license = "OFL 1.1",
	},
	["Bangers-Regular"] = {
		file = "Bangers-Regular.ttf",
		family = "Bangers",
		category = "Display",
		license = "OFL 1.1",
	},
	["Creepster-Regular"] = {
		file = "Creepster-Regular.ttf",
		family = "Creepster",
		category = "Display",
		license = "OFL 1.1",
	},
	["Orbitron-Regular"] = {
		file = "Orbitron-Regular.ttf",
		family = "Orbitron",
		category = "Display",
		license = "OFL 1.1",
	},
	["Audiowide-Regular"] = {
		file = "Audiowide-Regular.ttf",
		family = "Audiowide",
		category = "Display",
		license = "OFL 1.1",
	},
	["Anton-Regular"] = {
		file = "Anton-Regular.ttf",
		family = "Anton",
		category = "Display",
		license = "OFL 1.1",
	},
	["Silkscreen-Regular"] = {
		file = "Silkscreen-Regular.ttf",
		family = "Silkscreen",
		category = "Pixel",
		license = "OFL 1.1",
	},
	["UncialAntiqua-Regular"] = {
		file = "UncialAntiqua-Regular.ttf",
		family = "Uncial Antiqua",
		category = "Fantasy",
		license = "OFL 1.1",
	},
	["Cinzel-Regular"] = {
		file = "Cinzel-Regular.ttf",
		family = "Cinzel",
		category = "Fantasy",
		license = "OFL 1.1",
	},
}

function Fonts:ScanForNewFonts()
	if _G.RGXFramework then _G.RGXFramework:Debug("Fonts: Scanning for available fonts...") end
end
