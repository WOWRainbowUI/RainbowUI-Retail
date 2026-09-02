local EventBus = {}
EventBus.__index = EventBus

function EventBus:New(diagnostics)
	return setmetatable({
		diagnostics = diagnostics,
		subscriptions = {},
	}, self)
end

function EventBus:Subscribe(owner, eventName, handler)
	assert(owner, "event subscription must have an owner")
	assert(eventName, "event subscription must have an event name")
	assert(type(handler) == "function", "event subscription must have a handler")

	local handlers = self.subscriptions[eventName]
	if not handlers then
		handlers = {}
		self.subscriptions[eventName] = handlers
	end

	handlers[#handlers + 1] = {
		owner = owner,
		handler = handler,
	}
end

function EventBus:UnsubscribeOwner(owner)
	for eventName, handlers in pairs(self.subscriptions) do
		for index = #handlers, 1, -1 do
			if handlers[index].owner == owner then
				table.remove(handlers, index)
			end
		end

		if #handlers == 0 then
			self.subscriptions[eventName] = nil
		end
	end
end

function EventBus:Emit(eventName, ...)
	local handlers = self.subscriptions[eventName]
	if not handlers then
		return
	end

	for _, subscription in ipairs(handlers) do
		local success, message = pcall(subscription.handler, ...)
		if not success and self.diagnostics then
			self.diagnostics:ReportError(
				subscription.owner,
				eventName,
				message
			)
		end
	end
end

MikSBT.Core = MikSBT.Core or {}
MikSBT.Core.EventBus = EventBus

return EventBus
