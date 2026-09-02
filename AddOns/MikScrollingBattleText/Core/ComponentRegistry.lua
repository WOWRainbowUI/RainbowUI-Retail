local registry = {
	components = {},
	componentsByName = {},
	initialized = {},
	enabled = {},
}

function registry:Register(component)
	assert(component and component.name, "component must have a name")
	assert(not self.componentsByName[component.name],
		"component already registered: " .. component.name)

	self.components[#self.components + 1] = component
	self.componentsByName[component.name] = component
end

function registry:SetDiagnostics(diagnostics)
	self.diagnostics = diagnostics
end

local function RunLifecycle(self, component, operation, ...)
	local handler = component[operation]
	if not handler then
		return true
	end

	local success, message = pcall(handler, component, ...)
	if not success and self.diagnostics then
		self.diagnostics:ReportError(component.name, operation, message)
	end

	return success
end

function registry:InitializeAll(context)
	for _, component in ipairs(self.components) do
		if not self.initialized[component]
			and RunLifecycle(self, component, "Initialize", context) then
			self.initialized[component] = true
		end
	end
end

function registry:EnableAll()
	for _, component in ipairs(self.components) do
		if not self.enabled[component]
			and RunLifecycle(self, component, "Enable") then
			self.enabled[component] = true
		end
	end
end

function registry:DisableAll()
	for index = #self.components, 1, -1 do
		local component = self.components[index]
		if self.enabled[component]
			and RunLifecycle(self, component, "Disable") then
			self.enabled[component] = nil
		end
	end
end

MikSBT.Core = MikSBT.Core or {}
MikSBT.Core.ComponentRegistry = registry

return registry
