local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

--- @class ExalityFramesPanelFrame
local panel = EXFrames:GetFrame('panel-frame')

panel.Init = function(self)
    panel.pool = CreateFramePool('Frame', UIParent)
end

local configure = function(frame)
    local bg = frame:CreateTexture()
    frame.Texture = bg
    bg:SetTexture(EXFrames.assets.textures.window.bg)
    bg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
    bg:SetTexCoord(7 / 512, 505 / 512, 7 / 512, 505 / 512)
    bg:SetTextureSliceMargins(15, 15, 15, 15)
    bg:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    bg:SetAllPoints()

    frame.Destroy = function(self)
        panel.pool:Release(self)
    end

    frame.SetBackgroundColor = function(self, r, g, b, a)
        self.Texture:SetVertexColor(r, g, b, a)
    end

    frame.configured = true
end

---@param self ExalityFramesPanelFrame
---@return Frame
panel.Create = function(self)
    local f = self.pool:Acquire()
    if not f.configured then
        configure(f)
    end

    f:Show()
    return f
end
