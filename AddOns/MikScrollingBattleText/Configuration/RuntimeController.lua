local RuntimeController = {}
RuntimeController.__index = RuntimeController

function RuntimeController:New(options)
	local controller = setmetatable({}, self)

	controller.isAddonDisabled = options.isAddonDisabled
	controller.getProfile = options.getProfile
	controller.setAddonEnabled = options.setAddonEnabled
	controller.setBlizzardEnabled = options.setBlizzardEnabled
	controller.addonEnabled = nil

	return controller
end

function RuntimeController:ApplyAddonState()
	local shouldEnable = not not (not self.isAddonDisabled())
	if self.addonEnabled == shouldEnable then
		return
	end

	self.addonEnabled = shouldEnable
	self.setAddonEnabled(shouldEnable)
end

function RuntimeController:ApplyBlizzardState()
	local profile = self.getProfile()
	if not profile then
		return
	end

	self.setBlizzardEnabled(
		not not profile.blizzardDamageEnabled,
		not self.isAddonDisabled()
	)
end

function RuntimeController:Apply()
	self:ApplyAddonState()
	self:ApplyBlizzardState()
end

MikSBT.Configuration.RuntimeController = RuntimeController

return RuntimeController
