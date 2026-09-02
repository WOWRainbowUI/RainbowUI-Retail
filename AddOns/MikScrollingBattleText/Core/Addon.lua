local Diagnostics = MikSBT.Core.Diagnostics
local EventBus = MikSBT.Core.EventBus
local components = MikSBT.Core.ComponentRegistry

MikSBT.API = MikSBT.API or {}
MikSBT.Services = MikSBT.Services or {}
MikSBT.Display = MikSBT.Display or {}
MikSBT.Configuration = MikSBT.Configuration or {}

local diagnostics = Diagnostics:New()
local addon = {
	context = {
		api = MikSBT.API,
		services = MikSBT.Services,
		display = MikSBT.Display,
		configuration = MikSBT.Configuration,
		diagnostics = diagnostics,
		events = EventBus:New(diagnostics),
		components = components,
	},
}

components:SetDiagnostics(diagnostics)

function addon:RegisterComponent(component)
	self.context.components:Register(component)
end

MikSBT.Core.Addon = addon
MikSBT.RegisterComponent = function(component)
	addon:RegisterComponent(component)
end

return addon
