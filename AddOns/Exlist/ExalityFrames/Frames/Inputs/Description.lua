local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

--[[
Basically a dummy frame to fill space in options
]]

---@class ExalityFramesDescription
local description = EXFrames:GetFrame('description')

description.pool = {}

description.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end

local function ConfigureFrame(f)
    f:SetSize(100, 15)
    f.SetFrameWidth = function(self, width)
        f:SetWidth(width)
    end
    f.SetOptionData = function(self, option)
        self.optionData = option
        self.descriptionText:SetText(option.label)
    end

    local descriptionText = f:CreateFontString(nil, 'OVERLAY')
    descriptionText:SetFont(EXFrames.assets.font.default(), 12, 'OUTLINE')
    descriptionText:SetVertexColor(1, 1, 1, 1)
    descriptionText:SetPoint('LEFT', 5, 0)
    descriptionText:SetWidth(0)
    f.descriptionText = descriptionText

    f.configured = true
end

---Create/Get Title element
---@param self ExalityFramesDescription
---@return Frame
description.Create = function(self)
    local f = self.pool:Acquire()
    if (not f.configured) then
        ConfigureFrame(f)
    end
    f.Destroy = function(self)
        description.pool:Release(self)
    end

    f:Show()
    return f
end
