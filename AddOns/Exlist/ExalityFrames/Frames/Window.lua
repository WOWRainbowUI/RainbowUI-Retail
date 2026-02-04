local addonName, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class WindowOptions : {size?: table<number>, title?: string, hideVersion?: boolean}

--- @class ExalityFramesWindowFrame
local window = EXFrames:GetFrame('window-frame')

---@class ExalityFramesWindowManager
local windowManager = EXFrames:GetFrame('window-manager')

local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "version")
--[==[@debug@
if addonVersion == '1.0.0' then
    addonVersion = '1.0.0-dev'
end
--@end-debug@]==]

window.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end

local configure = function(frame)
    frame:SetSize(500, 500)
    frame.windowId = EXFrames.utils.generateRandomString(10)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:EnableMouse(true)
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetResizable(true)

    frame.fadeIn = EXFrames.utils.animation.fade(frame, 0.2, 0, 1)
    frame.fadeOut = EXFrames.utils.animation.fade(frame, 0.2, 1, 0)
    frame.fadeOut:SetScript('OnFinished', function() frame:Hide() end)
    EXFrames.utils.animation.diveIn(frame, 0.2, 0, 20, 'IN', frame.fadeIn)
    EXFrames.utils.animation.diveIn(frame, 0.2, 0, -20, 'OUT', frame.fadeOut)

    frame.ShowWindow = function(self, hideAfter)
        self:Show()
        if (self.StaticAnchor) then
            self:ClearAllPoints()
            self:SetPoint(unpack(self.StaticAnchor))
        else
            windowManager:SetValidCenterPosition(self)
        end
        self.fadeIn:Play()
        if (hideAfter) then
            self.timerContainer:Show();
            self.timer:SetMinMaxValues(0, hideAfter)
            self.timer:SetValue(hideAfter)
            self:SetScript('OnUpdate', function(self, elapsed)
                self.timer:SetValue(self.timer:GetValue() - elapsed)
                if (self.timer:GetValue() <= 0) then
                    self:HideWindow()
                end
            end)
        end
    end

    frame.HideWindow = function(self)
        self.fadeOut:Play()
        if (self.onClose) then
            self.onClose()
        end
        self:SetScript('OnUpdate', nil)
        EXFrames:Callback('windowClose', self.windowId)
    end

    if (not frame.Texture) then
        local bg = frame:CreateTexture()
        frame.Texture = bg
        bg:SetTexture(EXFrames.assets.textures.window.bg)
        bg:SetVertexColor(0, 0, 0, 0.8)
        bg:SetTexCoord(7 / 512, 505 / 512, 7 / 512, 505 / 512)
        bg:SetTextureSliceMargins(15, 15, 15, 15)
        bg:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
        bg:SetAllPoints()
    end

    if (not frame.logo) then
        local logo = CreateFrame('Frame', nil, frame)
        logo:SetSize(25, 25)
        logo:SetPoint('LEFT', frame, 'TOPLEFT', 10, 0)

        local texture = logo:CreateTexture(nil, 'OVERLAY')
        texture:SetTexture(EXFrames.config.logoPath)
        texture:SetVertexColor(1, 1, 1, 1)
        texture:SetTexCoord(0, 1, 0, 1)
        texture:SetAllPoints()

        local version = logo:CreateFontString(nil, 'OVERLAY')
        version:SetPoint('LEFT', logo, 'RIGHT', 3, 0)
        version:SetVertexColor(.8, .8, .8, 1)
        version:SetFont(EXFrames.assets.font.default(), 10, 'OUTLINE')
        version:SetText(addonVersion)

        frame.logo = logo

        frame.HideVersion = function(self, hide)
            if (hide) then
                version:Hide()
            else
                version:Show()
            end
        end
    end

    if (not frame.resizeBtn) then
        local resizeBtn = CreateFrame("Button", nil, frame, "PanelResizeButtonTemplate");
        frame.resizeBtn = resizeBtn
        resizeBtn:SetPoint("BOTTOM", 0, -15)
        resizeBtn:SetSize(40, 10)
        resizeBtn:SetNormalTexture(EXFrames.assets.textures.window.resizeBtn)
        resizeBtn:SetHighlightTexture(EXFrames.assets.textures.window.resizeBtnHighlight)
        resizeBtn:Init(frame, 500, 500, 500, 1200);
    end

    if (not frame.close) then
        local closeContainer = CreateFrame("Button", nil, frame)
        closeContainer:SetSize(38, 28)
        closeContainer:SetPoint("TOPRIGHT", -8, -5)

        local texture = closeContainer:CreateTexture(nil, "BACKGROUND")
        texture:SetTexture(EXFrames.assets.textures.input.buttonBg)
        texture:SetTextureSliceMargins(20, 20, 20, 20)
        texture:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
        texture:SetVertexColor(110 / 255, 4 / 255, 0, 1)
        texture:SetAllPoints()

        local closeIcon = closeContainer:CreateTexture(nil, "OVERLAY")
        closeIcon:SetTexture(EXFrames.assets.textures.icon.close)
        closeIcon:SetVertexColor(1, 1, 1, 1)
        closeIcon:SetPoint("CENTER")
        closeIcon:SetSize(10, 10)

        closeContainer:EnableMouse(true)
        closeContainer:SetMouseClickEnabled()
        closeContainer:SetScript("OnClick", function()
            if (frame:IsShown()) then
                frame:HideWindow()
            end
        end)
        closeContainer:SetScript("OnEnter", function(_)
            texture:SetVertexColor(186 / 255, 6 / 255, 0, 1)
        end)
        closeContainer:SetScript("OnLeave", function(_)
            texture:SetVertexColor(110 / 255, 4 / 255, 0, 1)
        end)

        frame.close = closeContainer
    end

    if (not frame.timer) then
        frame.timerContainer = CreateFrame("Frame", nil, frame)
        frame.timerContainer:SetHeight(12)
        frame.timerContainer:SetPoint('BOTTOMLEFT', frame, 'BOTTOMLEFT', 20, 15)
        frame.timerContainer:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -20, 15)
        local timerBg = frame.timerContainer:CreateTexture(nil, "BACKGROUND")
        timerBg:SetTexture(EXFrames.assets.textures.statusBar)
        timerBg:SetVertexColor(0, 0, 0, 1)
        timerBg:SetAllPoints()

        frame.timer = CreateFrame("StatusBar", nil, frame.timerContainer)
        frame.timer:SetAllPoints()
        frame.timer:SetStatusBarTexture(EXFrames.assets.textures.statusBar)
        frame.timer:SetStatusBarColor(194 / 255, 2 / 255, 37 / 255, 1)
        frame.timer:SetMinMaxValues(0, 1)
        frame.timer:SetValue(0)
        frame.timerContainer:Hide();
    end

    local title = frame:CreateFontString(nil, "OVERLAY")
    frame.title = title
    title:SetFont(EXFrames.assets.font.default(), 10, 'OUTLINE')
    title:SetTextColor(1, 1, 1)
    title:SetPoint('CENTER', frame, 'TOP')
    title:SetText(addonName)

    frame.SetTitle = function(self, title)
        self.title:SetText(title)
    end

    if not frame.container then
        local container = CreateFrame("Frame", nil, frame)
        frame.container = container
        container:SetPoint("TOPLEFT", 15, -50)
        container:SetPoint("BOTTOMRIGHT", -15, 15)
    end

    frame.DisableResize = function(self)
        -- It's still resizeable but button to do it is not there so basically disabled
        self.resizeBtn:Hide()
    end

    frame.SetTitleSize = function(self, size)
        self.title:SetFont(EXFrames.assets.font.default(), size, 'OUTLINE')
    end

    frame.DisableLogoAndVersion = function(self)
        self.logo:Hide()
        self.HideVersion(true)
    end

    ---@param options {staticAnchor?: table, disableResize?: boolean, disableLogoAndVersion?: boolean, titleSize?: number}
    frame.Configure = function(self, options)
        if (options) then
            if (options.disableResize) then
                self:DisableResize()
            end
            if (options.staticAnchor) then
                self.StaticAnchor = options.staticAnchor
            end
            if (options.disableLogoAndVersion) then
                self:DisableLogoAndVersion()
            end
            if (options.titleSize) then
                self:SetTitleSize(options.titleSize)
            end
        end
    end

    windowManager:RegisterWindow(frame)
    frame.configured = true
end

---@param self ExalityFramesWindowFrame
---@param options WindowOptions
---@return Frame
window.Create = function(self, options)
    local f = self.pool:Acquire()
    if not f.configured then
        configure(f)
    end

    if (options and options.size) then
        f:SetSize(options.size[1], options.size[2])
        f.resizeBtn:Init(f, options.size[1], options.size[2], options.size[1], options.size[2] + 1000)
    end

    if (options and options.title) then
        f:SetTitle(options.title)
    end

    if (options and options.hideVersion) then
        f:HideVersion(options.hideVersion)
    end

    if (options and options.onClose) then
        f.onClose = options.onClose
    end

    return f
end
