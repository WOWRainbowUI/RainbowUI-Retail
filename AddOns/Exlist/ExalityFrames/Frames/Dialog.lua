local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class ExalityFramesButton
local button = EXFrames:GetFrame('button')

---@class ExalityFramesDialogFrame
local dialog = EXFrames:GetFrame('dialog-frame')

dialog.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end

local function ConfigureFrame(f)
    f:SetSize(400, 80)
    f:SetPoint('TOP', 0, -200)
    f:SetFrameStrata('DIALOG')
    f:SetFrameLevel(10)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag('LeftButton')
    f:SetScript('OnDragStart', function(self)
        self:StartMoving()
    end)
    f:SetScript('OnDragStop', function(self)
        self:StopMovingOrSizing()
    end)

    f.fadeIn = EXFrames.utils.animation.fade(f, 0.2, 0, 1)
    f.fadeOut = EXFrames.utils.animation.fade(f, 0.2, 1, 0)
    f.fadeOut:SetScript('OnFinished', function() f:Hide() end)
    EXFrames.utils.animation.diveIn(f, 0.2, 0, 20, 'IN', f.fadeIn)
    EXFrames.utils.animation.diveIn(f, 0.2, 0, -20, 'OUT', f.fadeOut)

    local background = f:CreateTexture(nil, 'BACKGROUND')
    background:SetTexture(EXFrames.assets.textures.window.bg)
    background:SetVertexColor(0.1, 0.1, 0.1, 0.8)
    background:SetTexCoord(7 / 512, 505 / 512, 7 / 512, 505 / 512)
    background:SetTextureSliceMargins(15, 15, 15, 15)
    background:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
    background:SetAllPoints()

    local text = f:CreateFontString(nil, 'OVERLAY')
    text:SetFont(EXFrames.assets.font.default(), 11, 'OUTLINE')
    text:SetPoint('TOPLEFT', 5, -5)
    text:SetPoint('BOTTOMRIGHT', -5, 40)
    text:SetWidth(0)
    text:SetText('Placeholder')
    f.text = text

    f.ShowDialog = function(self)
        self:Show()
        self.fadeIn:Play()
    end

    f.HideDialog = function(self)
        self.fadeOut:Play()
    end

    f.SetText = function(self, text)
        self.text:SetText(text)
    end

    f.SetButtons = function(self, buttons)
        self.buttonConfigs = buttons
        self:OrganizeButtons()
    end

    f.buttons = { button:Create(nil, f), button:Create(nil, f), button:Create(nil, f) }

    f.OrganizeButtons = function(self)
        local prev = nil
        for _, button in ipairs(self.buttons) do
            button:ClearAllPoints()
        end

        for indx, btnConfig in ipairs(self.buttonConfigs) do
            local btn = self.buttons[indx]
            btn:SetText(btnConfig.text)
            if (btnConfig.color) then
                btn:SetColor(unpack(btnConfig.color))
            end
            if (btnConfig.onClick) then
                btn.onClick = btnConfig.onClick
            end
            if (prev) then
                btn:SetPoint('BOTTOMLEFT', prev, 'BOTTOMRIGHT', 5, 0)
            else
                btn:SetPoint('LEFT', 5, 0)
                btn:SetPoint('BOTTOMRIGHT', self, 'BOTTOM', 0, 5)
            end
            prev = btn
        end
        prev:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', -5, 5)
    end
end

---Create Dialog Frame
---@param self ExalityFramesDialogFrame
---@return Frame
dialog.Create = function(self)
    local f = self.pool:Acquire()
    if not f.configured then
        ConfigureFrame(f)
    end

    f:Hide()

    return f
end
