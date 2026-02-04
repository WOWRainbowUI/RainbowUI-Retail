local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

--[[
Basically a dummy frame to fill space in options
]]

---@class ExalityFramesSpacer
local spacer = EXFrames:GetFrame('spacer')

spacer.pool = {}

spacer.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end

local function ConfigureFrame(f)
    f:SetSize(1, 1)
    f.SetFrameWidth = function() end
    f.SetOptionData = function(self, option)
        self.optionData = option
    end

    f.configured = true
end

---Create/Get Spacer element
---@param self ExalityFramesSpacer
---@return Frame
spacer.Create = function(self)
    local f = self.pool:Acquire()
    if (not f.configured) then
        ConfigureFrame(f)
    end
    f.Destroy = function(self)
        spacer.pool:Release(self)
    end

    f:Show()
    return f
end
