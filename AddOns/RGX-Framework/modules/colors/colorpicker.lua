--[[
    RGX-Framework - Modern Color Picker
    
    Rectangular color selector inspired by Figma/Photoshop.
    Horizontal hue bar, saturation/value box, and RGB/HEX inputs.
    
    Usage:
        local CP = RGX:GetModule("colorpicker")
        CP:Show({r=1, g=0, b=0}, function(r, g, b, a)
            -- color selected
        end)
--]]

local _, ColorPicker = ...
local RGX = _G.RGXFramework

if not RGX then
    error("RGX ColorPicker: RGX-Framework not loaded")
    return
end

ColorPicker.name = "colorpicker"
ColorPicker.version = "2.0.0"

-- Storage
ColorPicker.callback = nil
ColorPicker.current = {r=1, g=0, b=0, a=1}
ColorPicker.history = {}
ColorPicker.palettes = {}

-- Default color palettes
ColorPicker.presets = {
    {name="Recent", colors={}},
    {name="Class", colors={
        {r=0.77, g=0.12, b=0.23}, -- Warrior
        {r=0.96, g=0.55, b=0.73}, -- Paladin
        {r=0.67, g=0.83, b=0.45}, -- Hunter
        {r=1.00, g=0.96, b=0.41}, -- Rogue
        {r=1.00, g=1.00, b=1.00}, -- Priest
        {r=0.00, g=0.44, b=0.87}, -- Shaman
        {r=0.53, g=0.53, b=0.93}, -- Mage
        {r=0.58, g=0.51, b=0.79}, -- Warlock
        {r=1.00, g=0.49, b=0.04}, -- Monk
        {r=0.20, g=0.58, b=0.50}, -- Druid
    }},
    {name="Quality", colors={
        {r=0.61, g=0.61, b=0.61},
        {r=1.00, g=1.00, b=1.00},
        {r=0.12, g=1.00, b=0.00},
        {r=0.00, g=0.44, b=0.87},
        {r=0.64, g=0.21, b=0.93},
        {r=1.00, g=0.50, b=0.00},
    }},
    {name="Basic", colors={
        {r=1, g=0, b=0}, {r=0, g=1, b=0}, {r=0, g=0, b=1},
        {r=1, g=1, b=0}, {r=1, g=0, b=1}, {r=0, g=1, b=1},
        {r=0, g=0, b=0}, {r=1, g=1, b=1},
    }}
}

--[[============================================================================
    COLOR CONVERSIONS
============================================================================]]

function ColorPicker:RGBToHSV(r, g, b)
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, v
    
    v = max
    local d = max - min
    s = max == 0 and 0 or d / max
    
    if max == min then
        h = 0
    else
        if max == r then h = (g - b) / d + (g < b and 6 or 0)
        elseif max == g then h = (b - r) / d + 2
        else h = (r - g) / d + 4 end
        h = h / 6
    end
    
    return h, s, v
end

function ColorPicker:HSVToRGB(h, s, v)
    local r, g, b
    
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    
    i = i % 6
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    else r, g, b = v, p, q
    end
    
    return r, g, b
end

function ColorPicker:RGBToHex(r, g, b)
    return string.format("%02x%02x%02x",
        math.floor(r * 255 + 0.5),
        math.floor(g * 255 + 0.5),
        math.floor(b * 255 + 0.5))
end

function ColorPicker:HexToRGB(hex)
    hex = hex:gsub("#", "")
    if #hex == 3 then
        hex = hex:sub(1,1):rep(2) .. hex:sub(2,2):rep(2) .. hex:sub(3,3):rep(2)
    end
    return tonumber(hex:sub(1,2), 16) / 255,
           tonumber(hex:sub(3,4), 16) / 255,
           tonumber(hex:sub(5,6), 16) / 255
end

--[[============================================================================
    UI CREATION - Modern Rectangular Design
============================================================================]]

function ColorPicker:GetFrame()
    if self.frame then return self.frame end
    
    local f = CreateFrame("Frame", "RGXColorPicker", UIParent, "BackdropTemplate")
    f:SetSize(340, 450)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        edgeSize = 1,
        insets = {left=0, right=0, top=0, bottom=0}
    })
    f:SetBackdropColor(0.12, 0.12, 0.14, 1)
    f:SetBackdropBorderColor(0.2, 0.2, 0.22, 1)
    f:Hide()
    
    -- Title
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOP", f, "TOP", 0, -12)
    f.title:SetText("Color")
    
    -- Close button (X)
    f.close = CreateFrame("Button", nil, f)
    f.close:SetSize(20, 20)
    f.close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)
    f.close:SetText("X")
    f.close:SetNormalFontObject("GameFontRed")
    f.close:SetScript("OnClick", function() self:Cancel() end)
    
    -- === SATURATION/VALUE BOX (Main gradient square) ===
    self:CreateSVBox(f)
    
    -- === HUE BAR (Horizontal rainbow bar) ===
    self:CreateHueBar(f)
    
    -- === PREVIEW & HEX ===
    self:CreatePreview(f)
    
    -- === RGB INPUTS ===
    self:CreateRGBInputs(f)
    
    -- === PRESETS ===
    self:CreatePresets(f)
    
    -- === BUTTONS ===
    self:CreateButtons(f)
    
    -- Make draggable
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    self.frame = f
    return f
end

function ColorPicker:CreateSVBox(f)
    -- Saturation/Value box - the main gradient square
    local box = CreateFrame("Frame", nil, f)
    box:SetSize(200, 160)
    box:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -45)
    box:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1
    })
    box:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)
    
    -- Create gradient texture
    box.bg = box:CreateTexture(nil, "BACKGROUND")
    box.bg:SetAllPoints()
    -- White to transparent gradient (saturation)
    box.bg:SetColorTexture(1, 1, 1, 1)
    
    -- Overlay gradient for value (black gradient)
    box.overlay = box:CreateTexture(nil, "ARTWORK")
    box.overlay:SetAllPoints()
    box.overlay:SetColorTexture(0, 0, 0, 1)
    box.overlay:SetGradient("VERTICAL", CreateColor(0,0,0,0), CreateColor(0,0,0,1))
    
    -- Cursor (picker position)
    box.cursor = box:CreateTexture(nil, "OVERLAY")
    box.cursor:SetSize(12, 12)
    box.cursor:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    box.cursor:SetPoint("CENTER", box, "CENTER")
    
    -- Mouse interaction
    box:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.dragging = true
            ColorPicker:UpdateSVFromMouse(self)
        end
    end)
    box:SetScript("OnMouseUp", function(self) self.dragging = false end)
    box:SetScript("OnUpdate", function(self)
        if self.dragging then
            ColorPicker:UpdateSVFromMouse(self)
        end
    end)
    
    f.svBox = box
end

function ColorPicker:CreateHueBar(f)
    -- Horizontal hue rainbow bar
    local bar = CreateFrame("Frame", nil, f)
    bar:SetSize(200, 20)
    bar:SetPoint("TOP", f.svBox, "BOTTOM", 0, -15)
    bar:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1
    })
    bar:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)
    
    -- Create rainbow gradient texture
    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetAllPoints()
    -- We'll update this with the hue gradient
    bar.bg:SetColorTexture(1, 0, 0, 1)
    
    -- Hue cursor
    bar.cursor = bar:CreateTexture(nil, "OVERLAY")
    bar.cursor:SetSize(4, 24)
    bar.cursor:SetColorTexture(1, 1, 1, 1)
    bar.cursor:SetPoint("CENTER", bar, "LEFT")
    
    -- Mouse interaction
    bar:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.dragging = true
            ColorPicker:UpdateHueFromMouse(self)
        end
    end)
    bar:SetScript("OnMouseUp", function(self) self.dragging = false end)
    bar:SetScript("OnUpdate", function(self)
        if self.dragging then
            ColorPicker:UpdateHueFromMouse(self)
        end
    end)
    
    f.hueBar = bar
end

function ColorPicker:CreatePreview(f)
    -- Current color preview
    f.preview = f:CreateTexture(nil, "ARTWORK")
    f.preview:SetSize(70, 70)
    f.preview:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -45)
    f.preview:SetColorTexture(1, 0, 0, 1)
    
    -- Preview border
    f.previewBorder = CreateFrame("Frame", nil, f)
    f.previewBorder:SetPoint("TOPLEFT", f.preview, "TOPLEFT", -2, 2)
    f.previewBorder:SetPoint("BOTTOMRIGHT", f.preview, "BOTTOMRIGHT", 2, -2)
    f.previewBorder:SetBackdrop({
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2
    })
    f.previewBorder:SetBackdropBorderColor(0.4, 0.4, 0.45, 1)
    
    -- Eyedropper button
    f.eyedropper = CreateFrame("Button", nil, f)
    f.eyedropper:SetSize(24, 24)
    f.eyedropper:SetPoint("BOTTOM", f.preview, "TOP", 0, 5)
    f.eyedropper:SetNormalTexture("Interface\\Cursor\\CrossHair")
    
    f.eyedropper:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Eyedropper Tool")
        GameTooltip:AddLine("Click and drag to pick a color from screen", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    f.eyedropper:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f.eyedropper:SetScript("OnClick", function()
        ColorPicker:StartEyedropper()
    end)
    
    -- HEX input
    local hexLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hexLabel:SetPoint("TOP", f.preview, "BOTTOM", 0, -10)
    hexLabel:SetText("HEX")
    hexLabel:SetTextColor(0.7, 0.7, 0.7)
    
    f.hexInput = CreateFrame("EditBox", nil, f)
    f.hexInput:SetSize(70, 22)
    f.hexInput:SetPoint("TOP", hexLabel, "BOTTOM", 0, -5)
    f.hexInput:SetFontObject("GameFontNormal")
    f.hexInput:SetTextColor(1, 1, 1)
    f.hexInput:SetAutoFocus(false)
    f.hexInput:SetMaxLetters(6)
    f.hexInput:SetText("FF0000")
    
    f.hexInput:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = {left=4, right=4, top=0, bottom=0}
    })
    f.hexInput:SetBackdropColor(0.15, 0.15, 0.17, 1)
    f.hexInput:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)
    
    f.hexInput:SetScript("OnTextChanged", function(self)
        local hex = self:GetText()
        if #hex == 6 then
            local r, g, b = ColorPicker:HexToRGB(hex)
            ColorPicker:SetRGB(r, g, b)
        end
    end)
end

function ColorPicker:CreateRGBInputs(f)
    local labels = {"R", "G", "B"}
    local y = -240
    
    for i, label in ipairs(labels) do
        local lbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetPoint("TOPLEFT", f, "TOPLEFT", 20 + (i-1) * 60, y)
        lbl:SetText(label)
        lbl:SetTextColor(0.7, 0.7, 0.7)
        
        local input = CreateFrame("EditBox", nil, f)
        input:SetSize(50, 22)
        input:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -5)
        input:SetFontObject("GameFontNormal")
        input:SetTextColor(1, 1, 1)
        input:SetAutoFocus(false)
        input:SetMaxLetters(3)
        input:SetNumeric(true)
        
        input:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = {left=4, right=4, top=0, bottom=0}
        })
        input:SetBackdropColor(0.15, 0.15, 0.17, 1)
        input:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)
        
        input:SetText("255")
        
        local idx = i
        input:SetScript("OnTextChanged", function(self)
            local val = tonumber(self:GetText()) or 0
            val = math.min(255, math.max(0, val)) / 255
            
            local c = ColorPicker.current
            if idx == 1 then c.r = val
            elseif idx == 2 then c.g = val
            else c.b = val end
            
            ColorPicker:UpdateUI()
        end)
        
        if i == 1 then f.inputR = input
        elseif i == 2 then f.inputG = input
        else f.inputB = input end
    end
end

function ColorPicker:CreatePresets(f)
    local y = -310
    
    -- Preset label
    local lbl = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("TOPLEFT", f, "TOPLEFT", 20, y)
    lbl:SetText("Presets")
    lbl:SetTextColor(0.7, 0.7, 0.7)
    
    -- Create color swatch buttons
    f.swatches = {}
    local startY = y - 25
    
    for paletteIdx, palette in ipairs(self.presets) do
        local row = 0
        for colorIdx, color in ipairs(palette.colors) do
            local btn = CreateFrame("Button", nil, f)
            btn:SetSize(22, 22)
            
            local col = (colorIdx - 1) % 8
            local rowOffset = math.floor((colorIdx - 1) / 8)
            
            btn:SetPoint("TOPLEFT", f, "TOPLEFT", 20 + col * 26, startY - (paletteIdx-1) * 60 - rowOffset * 26)
            
            btn.bg = btn:CreateTexture(nil, "BACKGROUND")
            btn.bg:SetAllPoints()
            btn.bg:SetColorTexture(color.r, color.g, color.b, 1)
            
            btn:SetBackdrop({
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1
            })
            btn:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)
            
            btn:SetScript("OnClick", function()
                ColorPicker:SetRGB(color.r, color.g, color.b)
            end)
            
            table.insert(f.swatches, btn)
        end
    end
end

function ColorPicker:CreateButtons(f)
    -- OK button
    f.okBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.okBtn:SetSize(80, 28)
    f.okBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -15, 15)
    f.okBtn:SetText("OK")
    f.okBtn:SetScript("OnClick", function() self:OK() end)
    
    -- Cancel button
    f.cancelBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.cancelBtn:SetSize(80, 28)
    f.cancelBtn:SetPoint("RIGHT", f.okBtn, "LEFT", -10, 0)
    f.cancelBtn:SetText("Cancel")
    f.cancelBtn:SetScript("OnClick", function() self:Cancel() end)
end

--[[============================================================================
    UPDATE FUNCTIONS
============================================================================]]

function ColorPicker:UpdateSVFromMouse(box)
    local x, y = GetCursorPosition()
    local scale = box:GetEffectiveScale()
    local left, bottom = box:GetLeft(), box:GetBottom()
    
    local relativeX = (x / scale - left) / box:GetWidth()
    local relativeY = (y / scale - bottom) / box:GetHeight()
    
    relativeX = math.max(0, math.min(1, relativeX))
    relativeY = math.max(0, math.min(1, relativeY))
    
    local h = self.current.h or 0
    local s = relativeX
    local v = relativeY
    
    local r, g, b = self:HSVToRGB(h, s, v)
    self:SetRGB(r, g, b, false)
end

function ColorPicker:UpdateHueFromMouse(bar)
    local x = GetCursorPosition()
    local scale = bar:GetEffectiveScale()
    local left = bar:GetLeft()
    
    local relativeX = ((x / scale - left) / bar:GetWidth())
    relativeX = math.max(0, math.min(1, relativeX))
    
    local s = self.current.s or 1
    local v = self.current.v or 1
    
    local r, g, b = self:HSVToRGB(relativeX, s, v)
    self:SetRGB(r, g, b)
end

function ColorPicker:SetRGB(r, g, b, updateUI)
    self.current.r = r
    self.current.g = g
    self.current.b = b
    
    local h, s, v = self:RGBToHSV(r, g, b)
    self.current.h = h
    self.current.s = s
    self.current.v = v
    
    if updateUI ~= false then
        self:UpdateUI()
    end
end

function ColorPicker:UpdateUI()
    local c = self.current
    local f = self.frame
    
    -- Update preview
    f.preview:SetColorTexture(c.r, c.g, c.b, 1)
    
    -- Update hex
    f.hexInput:SetText(self:RGBToHex(c.r, c.g, c.b):upper())
    
    -- Update RGB inputs
    f.inputR:SetText(tostring(math.floor(c.r * 255 + 0.5)))
    f.inputG:SetText(tostring(math.floor(c.g * 255 + 0.5)))
    f.inputB:SetText(tostring(math.floor(c.b * 255 + 0.5)))
    
    -- Update SV box cursor position
    local cursorX = (c.s or 0) * f.svBox:GetWidth()
    local cursorY = (c.v or 0) * f.svBox:GetHeight()
    f.svBox.cursor:SetPoint("CENTER", f.svBox, "BOTTOMLEFT", cursorX, cursorY)
    
    -- Update hue bar cursor
    local hueX = (c.h or 0) * f.hueBar:GetWidth()
    f.hueBar.cursor:SetPoint("CENTER", f.hueBar, "LEFT", hueX, 0)
    
    -- Update SV box background (pure hue color)
    local hr, hg, hb = self:HSVToRGB(c.h or 0, 1, 1)
    f.svBox.bg:SetColorTexture(hr, hg, hb, 1)
    
    -- Update hue bar gradient
    -- (In WoW we'd need a texture, simplified here)
end

--[[============================================================================
    PUBLIC API
============================================================================]]

function ColorPicker:Show(color, callback)
    self.callback = callback
    self.current = {
        r = color.r or 1,
        g = color.g or 0,
        b = color.b or 0,
        h = 0, s = 1, v = 1
    }
    
    -- Convert to HSV
    local h, s, v = self:RGBToHSV(self.current.r, self.current.g, self.current.b)
    self.current.h, self.current.s, self.current.v = h, s, v
    
    local f = self:GetFrame()
    self:UpdateUI()
    f:Show()
end

function ColorPicker:OK()
    if self.callback then
        self.callback(self.current.r, self.current.g, self.current.b, 1)
    end
    self.frame:Hide()
end

function ColorPicker:Cancel()
    self.frame:Hide()
end

function ColorPicker:AddToHistory(r, g, b)
    table.insert(self.history, 1, {r=r, g=g, b=b})
    if #self.history > 16 then table.remove(self.history) end
end

--[[============================================================================
    EYEDROPPER TOOL
============================================================================]]

function ColorPicker:StartEyedropper()
    -- Hide picker temporarily
    self.frame:Hide()
    
    -- Create eyedropper overlay
    if not self.dropperFrame then
        self.dropperFrame = CreateFrame("Frame", nil, UIParent)
        self.dropperFrame:SetFrameStrata("TOOLTIP")
        self.dropperFrame:SetAllPoints()
        self.dropperFrame:EnableMouse(true)
        self.dropperFrame:EnableKeyboard(true)
        
        -- Crosshair cursor
        self.dropperFrame.cursor = self.dropperFrame:CreateTexture(nil, "OVERLAY")
        self.dropperFrame.cursor:SetSize(32, 32)
        self.dropperFrame.cursor:SetTexture("Interface\\Cursor\\CrossHair")
        self.dropperFrame.cursor:SetPoint("CENTER", self.dropperFrame, "CENTER")
        
        -- Color preview box
        self.dropperFrame.preview = self.dropperFrame:CreateTexture(nil, "OVERLAY")
        self.dropperFrame.preview:SetSize(60, 60)
        self.dropperFrame.preview:SetPoint("CENTER", self.dropperFrame.cursor, "CENTER", 50, 50)
        self.dropperFrame.preview:SetColorTexture(1, 1, 1, 1)
        
        -- Preview border
        self.dropperFrame.previewBorder = self.dropperFrame:CreateTexture(nil, "OVERLAY")
        self.dropperFrame.previewBorder:SetSize(64, 64)
        self.dropperFrame.previewBorder:SetPoint("CENTER", self.dropperFrame.preview, "CENTER")
        self.dropperFrame.previewBorder:SetColorTexture(0, 0, 0, 1)
        
        -- HEX text
        self.dropperFrame.hexText = self.dropperFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.dropperFrame.hexText:SetPoint("TOP", self.dropperFrame.preview, "BOTTOM", 0, -5)
        self.dropperFrame.hexText:SetText("#FFFFFF")
        
        -- Instructions
        self.dropperFrame.instructions = self.dropperFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.dropperFrame.instructions:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 100)
        self.dropperFrame.instructions:SetText("|cffff7d00[Left Click]|r Pick Color  |  |cffff7d00[ESC]|r Cancel")
    end
    
    self.dropperFrame:Show()
    self.isDropping = true
    
    -- Set cursor
    self.oldCursor = GetCVar("cursorTexture")
    SetCVar("cursorTexture", "Interface\\Cursor\\CrossHair")
    
    -- OnUpdate for live preview
    self.dropperFrame:SetScript("OnUpdate", function()
        self:UpdateEyedropperPreview()
    end)
    
    -- Click to pick
    self.dropperFrame:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            self:PickColorFromScreen()
        end
    end)
    
    -- ESC to cancel
    self.dropperFrame:SetScript("OnKeyDown", function(_, key)
        if key == "ESCAPE" then
            self:StopEyedropper()
        end
    end)
end

function ColorPicker:UpdateEyedropperPreview()
    -- Get mouse position
    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    
    -- Move preview to follow cursor
    self.dropperFrame.preview:ClearAllPoints()
    self.dropperFrame.preview:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", (x / scale) + 20, (y / scale) + 20)
    
    -- Try to get color at cursor position
    -- Note: WoW doesn't have native screen pixel reading, so we approximate
    -- by checking what's under the cursor frame-wise
    local r, g, b = self:GetScreenColorAt(x, y)
    
    if r then
        self.dropperFrame.preview:SetColorTexture(r, g, b, 1)
        self.dropperFrame.hexText:SetText("#" .. self:RGBToHex(r, g, b):upper())
    end
end

function ColorPicker:GetScreenColorAt(x, y)
    -- NOTE: WoW doesn't provide direct screen pixel reading for security.
    -- This implementation samples colors from visible UI frames at the cursor position.
    -- For true screen-wide eyedropper, an external companion addon would be needed.
    
    local scale = UIParent:GetEffectiveScale()
    local uiX = x / scale
    local uiY = y / scale
    
    -- Check all visible frames
    local bestFrame = nil
    local bestLevel = 0
    
    local function checkFrame(frame)
        if not frame:IsVisible() then return end
        
        local left, bottom, width, height = frame:GetLeft(), frame:GetBottom(), frame:GetWidth(), frame:GetHeight()
        if not left then return end
        
        if uiX >= left and uiX <= left + width and uiY >= bottom and uiY <= bottom + height then
            local level = frame:GetFrameLevel()
            if level > bestLevel then
                -- Try to get color from frame's textures
                local regions = {frame:GetRegions()}
                for _, region in ipairs(regions) do
                    if region.GetVertexColor then
                        local r, g, b = region:GetVertexColor()
                        if r and r ~= 0 and g ~= 0 and b ~= 0 then
                            bestFrame = {r=r, g=g, b=b}
                            bestLevel = level
                        end
                    end
                end
            end
        end
        
        -- Check children
        for _, child in ipairs({frame:GetChildren()}) do
            checkFrame(child)
        end
    end
    
    checkFrame(UIParent)
    
    if bestFrame then
        return bestFrame.r, bestFrame.g, bestFrame.b
    end
    
    -- If no UI frame found, use the color under cursor from last known
    -- or sample from minimap/world frame if available
    return nil, nil, nil
end

-- Alternative: Built-in color sampler using existing textures
function ColorPicker:CreateTextureSampler()
    -- Creates a texture that can be sampled
    -- This allows picking from textures loaded in the UI
    local sampler = CreateFrame("Frame")
    sampler:SetSize(1, 1)
    sampler.tex = sampler:CreateTexture()
    sampler.tex:SetAllPoints()
    
    function sampler:SetTexture(path)
        self.tex:SetTexture(path)
    end
    
    function sampler:GetPixelColor(u, v)
        -- Returns approximate color at UV coordinates
        -- Note: Actual pixel reading requires render target access
        -- which WoW restricts for security
        return self.tex:GetVertexColor()
    end
    
    return sampler
end

-- Future: External companion addon for true screen sampling
-- An external .exe could:
-- 1. Read screen pixels via Windows API
-- 2. Send color to WoW via addon message
-- 3. This would be a separate optional download

function ColorPicker:PickColorFromScreen()
    local x, y = GetCursorPosition()
    local r, g, b = self:GetScreenColorAt(x, y)
    
    if r then
        self:SetRGB(r, g, b)
        self:AddToHistory(r, g, b)
    end
    
    self:StopEyedropper()
    self.frame:Show()
end

function ColorPicker:StopEyedropper()
    self.isDropping = false
    
    if self.dropperFrame then
        self.dropperFrame:Hide()
        self.dropperFrame:SetScript("OnUpdate", nil)
    end
    
    -- Restore cursor
    if self.oldCursor then
        SetCVar("cursorTexture", self.oldCursor)
    end
    
    -- Show picker again
    self.frame:Show()
end

--[[============================================================================
    INITIALIZATION
============================================================================]]

function ColorPicker:Init()
    RGX:RegisterModule("colorpicker", self)
end

ColorPicker:Init()
