local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class ExalityFramesModuleItemOptions : {onClick: function}

---@class ExalityFramesModuleItem
local moduleItem = EXFrames:GetFrame('module-item')

moduleItem.pool = {}

moduleItem.Init = function(self)
    self.pool = CreateFramePool('Button', UIParent)
end

local function ConfigureFrame(f)
    EXFrames.utils.addObserver(f)
    f:SetHeight(30)
    f.isSelected = false

    local text = f:CreateFontString(nil, 'OVERLAY')
    text:SetFont(EXFrames.assets.font.default(), 11, 'OUTLINE')
    text:SetPoint('CENTER')
    text:SetWidth(0)
    f.text = text

    local bg = f:CreateTexture(nil, 'BACKGROUND')
    bg:SetTexture(EXFrames.assets.textures.input.buttonBg)
    bg:SetTextureSliceMargins(10, 10, 10, 10)
    bg:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    bg:SetVertexColor(0.05, 0.05, 0.05, 1)
    bg:SetAllPoints()
    f.bg = bg

    local hover = CreateFrame('Frame', nil, f)
    hover:SetAllPoints()
    local hoverTexture = hover:CreateTexture(nil, 'BACKGROUND')
    hoverTexture:SetTexture(EXFrames.assets.textures.input.buttonHover)
    hoverTexture:SetTextureSliceMargins(25, 25, 25, 25)
    hoverTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    hoverTexture:SetVertexColor(249 / 255, 95 / 255, 9 / 255, 1)
    hoverTexture:SetAllPoints()
    hover:SetAlpha(0.1)

    local onHover = EXFrames.utils.animation.fade(hover, 0.1, 0.1, 1)
    local onLeave = EXFrames.utils.animation.fade(hover, 0.1, 1, 0.1)
    f.onHover = onHover
    f.onLeave = onLeave

    f:SetScript('OnEnter', function(self)
        if (not self.isSelected) then
            onHover:Play()
        end
    end)

    f:SetScript('OnLeave', function(self)
        if (not self.isSelected) then
            onLeave:Play()
        end
    end)

    f.SetModule = function(self, data)
        self.data = data
        self.text:SetText(data:GetName())
    end

    f.SetSelected = function(self, selected)
        local wasSelected = self.isSelected
        self.isSelected = selected
        if (selected) then
            hover:SetAlpha(1)
        elseif (wasSelected) then
            self.onLeave:Play()
        end
    end

    f.SetOnClick = function(self, onClick)
        f:SetScript('OnClick', onClick)
    end
    f.configured = true
end

---@param self ExalityFramesModuleItem
---@param options ExalityFramesModuleItemOptions
---@param parent Frame
---@return Frame
moduleItem.Create = function(self, options, parent)
    local f = self.pool:Acquire()
    if (not f.configured) then
        ConfigureFrame(f)
    end
    f:SetOnClick(options.onClick)

    f.Destroy = function(self)
        self.data = nil
        moduleItem.pool:Release(self)
    end

    if (parent) then
        f:SetParent(parent)
    else
        f:SetParent(nil)
    end

    return f
end
