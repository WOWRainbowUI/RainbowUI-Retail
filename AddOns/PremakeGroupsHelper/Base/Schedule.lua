local addonName, addon = ...
local utils = addon.utils
addon.schedule = addon.schedule or utils.class("addon.schedule").new()
local schedule = addon.schedule

function schedule:handler(name)
    return function(...)
        return self:exec(name, ...)
    end
end

function schedule:registerHandlers(handler)
    if not handler then
        return
    end

    if not self.handlers then
        self.handlers = {}
    end

    table.insert(self.handlers, handler)
end

function schedule:unregisterHandlers(handler)
    if not self.handlers then
        return
    end

    utils.tremovebyvalue(self.handlers, handler)
end

function schedule:exec(event, ...)
    local handlers = self.handlers
    if not handlers then
        return
    end

    --utils.dump(event, "event")

    for k, v in pairs(handlers) do
        local func = v[event]
        if func then
            func(v, ...)
            --pcall(func, v, ...)
        end
    end
end
