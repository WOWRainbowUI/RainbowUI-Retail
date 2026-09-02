local MediaRegistry = {}
MediaRegistry.__index = MediaRegistry

local ALL_LANGUAGES = 255

function MediaRegistry:New(options)
	local registry = setmetatable({}, self)

	registry.sharedMedia = options.sharedMedia
	registry.defaultFonts = options.defaultFonts or {}
	registry.fonts = {}

	return registry
end

function MediaRegistry:RegisterFont(name, path)
	if type(name) ~= "string" or name == "" then
		return false
	end
	if type(path) ~= "string" or path == "" then
		return false
	end

	self.fonts[name] = path
	self.sharedMedia:Register("font", name, path, ALL_LANGUAGES)

	return true
end

function MediaRegistry:ImportSharedMedia(mediaType, name)
	if mediaType == "font" then
		self.fonts[name] = self.sharedMedia:Fetch(mediaType, name)
	end
end

function MediaRegistry:LoadSavedMedia(savedMedia)
	for name, path in pairs(savedMedia and savedMedia.fonts or {}) do
		self:RegisterFont(name, path)
	end
end

function MediaRegistry:Initialize()
	for name, path in pairs(self.defaultFonts) do
		self:RegisterFont(name, path)
	end
	for _, name in pairs(self.sharedMedia:List("font")) do
		self:ImportSharedMedia("font", name)
	end

	self.sharedMedia.RegisterCallback(
		self,
		"LibSharedMedia_Registered",
		function(event, mediaType, name)
			self:ImportSharedMedia(mediaType, name)
		end
	)
end

function MediaRegistry:IterateFonts()
	return pairs(self.fonts)
end

MikSBT.Configuration.MediaRegistry = MediaRegistry

return MediaRegistry
