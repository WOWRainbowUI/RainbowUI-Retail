local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class KeybindOptions = {onChange: function, onClear: function, name: string, keybind: ?string}

---@class ExalityFramesKeybind
local keybind = EXFrames:GetFrame('keybind-frame')

local RESERVED_KEYS = {
    ESCAPE = true,
    BACKSPACE = true,
    SPACE = true,
    ENTER = true,
    TAB = true,
};

keybind.Init = function(self)
    self.pool = CreateFramePool('Button', UIParent)
end

local SetupKeyListening = function(f)
    local function onKeyUp(self, key)
        self:StopListening();
    end

    local function onKeyDown(self, key)
        if (key == 'ESCAPE') then
            if (self.onClear) then
                self:SetInactive()
                self.newKey = nil
                self.onClear()
            end
            self:StopListening();
            return
        end

        if (RESERVED_KEYS[key]) then
            print('Reserved key ' .. key .. ' pressed')
            return
        end

        self.newKey = strupper(CreateKeyChordStringUsingMetaKeyState(key))
    end

    local function onMouseEvent(self, event, button)
        if (event == 'GLOBAL_MOUSE_DOWN') then
            self.newKey = strupper(CreateKeyChordStringUsingMetaKeyState(button))
            self.hasMouseDown = true
        elseif (event == 'GLOBAL_MOUSE_UP' and self.hasMouseDown) then
            self:StopListening()
        end
    end

    f.StartListening = function(self)
        self.newKey = nil;
        f:SetIsListening()
        self:RegisterEvent("GLOBAL_MOUSE_DOWN");
        self:RegisterEvent("GLOBAL_MOUSE_UP");
        self:SetScript("OnEvent", onMouseEvent)
        self:SetScript("OnKeyDown", onKeyDown)
        self:SetScript("OnKeyUp", onKeyUp)
        self:SetPropagateKeyboardInput(false)
    end

    f.StopListening = function(self)
        self:Reset()
        self:UnregisterEvent("GLOBAL_MOUSE_DOWN");
        self:UnregisterEvent("GLOBAL_MOUSE_UP");
        self:SetScript("OnKeyDown", nil)
        self:SetScript("OnKeyUp", nil)
        self.hasMouseDown = false

        if (f.onChange and self.newKey) then
            local result = f.onChange(self.newKey, f)
            if not result then
                return
            end
        end
        if (self.newKey) then
            f:SetIsActive()
            f:SetKeybind(self.newKey)
        end
    end

    f:SetScript('OnClick', function(self)
        self:StartListening()
    end)
end

local SetupFrame = function(f)
    EXFrames.utils.addObserver(f)
    f:SetSize(150, 35)


    local bg = f:CreateTexture(nil, 'BACKGROUND')
    bg:SetTexture(EXFrames.assets.textures.input.buttonBg)
    bg:SetTextureSliceMargins(10, 10, 10, 10)
    bg:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    bg:SetVertexColor(0, 0, 0, 1)
    bg:SetAllPoints()
    f.bg = bg

    local keybind = f:CreateFontString(nil, 'OVERLAY')
    keybind:SetFont(EXFrames.assets.font.default(), 13, 'OUTLINE')
    keybind:SetPoint('CENTER')
    keybind:SetWidth(0)
    f.keybind = keybind
    keybind:SetText('Unbound')

    f.SetKeybind = function(self, keybind)
        self.keybind:SetText(keybind)
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
    f.hoverTexture = hoverTexture

    local onHover = EXFrames.utils.animation.fade(hover, 0.1, 0, 1)
    local onLeave = EXFrames.utils.animation.fade(hover, 0.1, 1, 0)
    f.onHover = onHover
    f.onLeave = onLeave

    f:SetScript('OnEnter', function(self)
        if (not self.isListening) then
            onHover:Play()
        end
    end)

    f:SetScript('OnLeave', function(self)
        if (not self.isListening) then
            onLeave:Play()
        end
    end)

    f.SetIsListening = function(self)
        self.hoverTexture:SetVertexColor(199 / 255, 166 / 255, 0, 1)
        f.isListening = true
    end

    f.SetInactive = function(self)
        self:SetKeybind('Not Bound')
        self.bg:SetVertexColor(66 / 255, 0, 10 / 255, 1)
    end

    f.SetIsActive = function(self)
        self.bg:SetVertexColor(0, 66 / 255, 31 / 255, 1)
    end

    f.UnsetKeybind = function(self)
        self:SetKeybind('Unbound')
    end

    f.Reset = function(self)
        self.hoverTexture:SetVertexColor(1, 1, 1, 1)
        self.isListening = false
        if (not self:IsMouseOver()) then
            onLeave:Play()
        end
    end

    local nameFrame = CreateFrame('Frame', nil, f)
    nameFrame:SetAllPoints()
    nameFrame:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', 10, 0)
    nameFrame:SetSize(1, 1)
    nameFrame:SetFrameLevel(f:GetFrameLevel() + 2)
    local name = nameFrame:CreateFontString(nil, 'OVERLAY')
    name:SetFont(EXFrames.assets.font.default(), 12, 'OUTLINE')
    name:SetPoint('LEFT')
    name:SetWidth(0)
    f.name = name

    f.SetKeybindName = function(self, name)
        self.name:SetText(name)
    end

    SetupKeyListening(f)

    f.configured = true
end

---Create Keybind Setup
---@param self ExalityFramesKeybind
---@param options KeybindOptions
keybind.Create = function(self, options, parent)
    local f = self.pool:Acquire()
    if (not f.configured) then
        SetupFrame(f)
    end

    f:SetKeybindName(options.name)

    if (parent) then
        f:SetParent(parent)
    end

    if (options.onChange) then
        f.onChange = options.onChange
    end

    if (options.keybind) then
        f:SetKeybind(options.keybind)
        f:SetIsActive()
    else
        f:SetInactive()
    end

    if (options.onClear) then
        f.onClear = options.onClear
    end

    f:Show()
    return f
end
