local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class ExalityFramesTitle
local title = EXFrames:GetFrame('title')

title.pool = {}

title.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end

local function ConfigureFrame(f)
    f:SetSize(100, 30)
    f.SetFrameWidth = function(self, width)
        f:SetWidth(width)
    end
    f.SetOptionData = function(self, option)
        self.optionData = option
        self.titleText:SetText(option.label)
        if (option.size) then
            self.titleText:SetFont(EXFrames.assets.font.default(), option.size, 'OUTLINE')
            self:SetHeight(option.size + 12)
        else
            self:SetHeight(30)
            self.titleText:SetFont(EXFrames.assets.font.default(), 18, 'OUTLINE')
        end
    end

    local titleText = f:CreateFontString(nil, 'OVERLAY')
    titleText:SetFont(EXFrames.assets.font.default(), 18, 'OUTLINE')
    titleText:SetVertexColor(1, 1, 1, 1)
    titleText:SetShadowOffset(2, -2)
    titleText:SetShadowColor(249 / 255, 95 / 255, 9 / 255, 1)
    titleText:SetPoint('LEFT', 5, 0)
    titleText:SetWidth(0)
    f.titleText = titleText

    local bg = f:CreateTexture(nil, 'BACKGROUND')
    bg:SetTexture(EXFrames.assets.textures.titleBg)
    bg:SetVertexColor(1, 1, 1, 0.2)
    bg:SetTextureSliceMargins(20, 20, 20, 20)
    bg:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    bg:SetPoint('TOPLEFT')
    bg:SetPoint('BOTTOMLEFT', 100, 0)
    f.bg = bg

    f.configured = true
end

---Create/Get Title element
---@param self ExalityFramesTitle
---@return Frame
title.Create = function(self)
    local f = self.pool:Acquire()
    if (not f.configured) then
        ConfigureFrame(f)
    end
    f.Destroy = function(self)
        title.pool:Release(self)
    end

    f:Show()
    return f
end
