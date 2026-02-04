local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class ExalityFramesButtonOptions : {text: string, onClick: function, size?: table<number>, color?: table<number>, icon?: {texture: string, width: number, height: number}}

---@class ExalityFramesButton
local button = EXFrames:GetFrame('button')

button.pool = {}

button.Init = function(self)
    self.pool = CreateFramePool('Button', UIParent)
end

local function ConfigureFrame(f)
    EXFrames.utils.addObserver(f)

    local text = f:CreateFontString(nil, 'OVERLAY')
    text:SetFont(EXFrames.assets.font.default(), 11, 'OUTLINE')
    text:SetPoint('CENTER')
    text:SetWidth(0)
    f.text = text

    local icon = f:CreateTexture(nil, 'ARTWORK')
    icon:SetPoint('CENTER')
    icon:SetSize(16, 16)
    f.icon = icon

    local bg = f:CreateTexture(nil, 'BACKGROUND')
    bg:SetTexture(EXFrames.assets.textures.input.buttonBg)
    bg:SetTextureSliceMargins(10, 10, 10, 10)
    bg:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    bg:SetVertexColor(148 / 255, 244 / 255, 1, 1)
    bg:SetAllPoints()
    f.bg = bg

    f.SetColor = function(self, r, g, b, a)
        self.bg:SetVertexColor(r, g, b, a)
    end

    local hover = CreateFrame('Frame', nil, f)
    hover:SetAllPoints()
    local hoverTexture = hover:CreateTexture(nil, 'BACKGROUND')
    hoverTexture:SetTexture(EXFrames.assets.textures.input.buttonHover)
    hoverTexture:SetTextureSliceMargins(25, 25, 25, 25)
    hoverTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    hoverTexture:SetVertexColor(1, 1, 1, 1)
    hoverTexture:SetAllPoints()
    hover:SetAlpha(0)

    local onHover = EXFrames.utils.animation.fade(hover, 0.1, 0, 1)
    local onLeave = EXFrames.utils.animation.fade(hover, 0.1, 1, 0)
    f.onHover = onHover
    f.onLeave = onLeave

    f:SetScript('OnEnter', function(self)
        onHover:Play()
    end)

    f:SetScript('OnLeave', function(self)
        onLeave:Play()
    end)

    f.SetText = function(self, text)
        self.text:SetText(text)
    end

    f:SetScript('OnClick', function(self)
        if (self.onClick) then
            self:onClick(self)
        end
    end)

    f.SetOnClick = function(self, onClick)
        self.onClick = onClick
    end

    f.SetIcon = function(self, texture, width, height)
        self.icon:SetTexture(texture)
        self.icon:SetSize(width, height)
    end

    f.SetOptionData = function(self, option)
        self.optionData = option
        self:SetText(option.label)
        if (option.onClick) then
            self.onClick = option.onClick
        end
        if (option.color) then
            self:SetColor(unpack(option.color))
        end
    end

    f.SetFrameWidth = function(self, width)
        self:SetWidth(width)
    end

    f.configured = true
end

---Create/Get Button element
---@param self ExalityFramesButton
---@param options? ExalityFramesButtonOptions
---@param parent Frame
---@return Frame
button.Create = function(self, options, parent)
    local f = self.pool:Acquire()
    if (not f.configured) then
        ConfigureFrame(f)
    end

    if (parent) then
        f:SetParent(parent)
    else
        f:SetParent(nil)
    end

    if (options and options.size) then
        f:SetSize(unpack(options.size))
    else
        f:SetSize(95, 29)
    end

    if (options and options.text) then
        f:SetText(options.text)
    end

    if (options and options.color) then
        f:SetColor(unpack(options.color))
    else
        f:SetColor(148 / 255, 244 / 255, 1, 1)
    end

    if (options and options.onClick) then
        f.onClick = options.onClick
    end

    if (options and options.icon) then
        f:SetIcon(options.icon.texture, options.icon.width, options.icon.height)
    end

    f.Destroy = function(self)
        self:ClearObservable()
        self.icon:SetTexture(nil)
        self.icon:SetSize(0, 0)
        button.pool:Release(self)
    end

    f:Show()
    return f
end
