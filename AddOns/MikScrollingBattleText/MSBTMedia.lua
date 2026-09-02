local module = {}
local moduleName = "Media"
MikSBT[moduleName] = module

local registry = MikSBT.Configuration.MediaRegistry:New({
	sharedMedia = LibStub("LibSharedMedia-3.0"),
	defaultFonts = MikSBT.translations.FONT_FILES,
})
registry:Initialize()

local function OnVariablesInitialized()
	registry:LoadSavedMedia(MikSBT.Profiles.savedMedia)
end

module.fonts = registry.fonts
module.RegisterFont = function(name, path)
	return registry:RegisterFont(name, path)
end
module.IterateFonts = function()
	return registry:IterateFonts()
end
module.OnVariablesInitialized = OnVariablesInitialized
