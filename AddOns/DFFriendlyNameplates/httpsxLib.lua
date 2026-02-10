local _, DFFN = ...

local HttpsxLib = {}

DFFN.httpsxLib = HttpsxLib

local BORDER = "Interface\\AddOns\\DFFriendlyNameplates\\Media\\border.tga"
local FONT_DEFAULT = "Interface\\Addons\\SharedMedia_Rainbow\\fonts\\bHEI00M\\bHEI00M.ttf"
local MEDIA_TEXTURE = "Interface\\AddOns\\DFFriendlyNameplates\\Media\\Textures"

local function frameAddBg(frame, bd, color, border)
    frame:SetBackdrop(bd)
    frame:SetBackdropColor(unpack(color or { 0, 0, 0, 1 }))
    frame:SetBackdropBorderColor(unpack(border or { 1, 1, 1, 1 }))
end

function HttpsxLib:CreateButton(parent, text, width, height, point, pointFrame, point2, x, y)
    local button = CreateFrame('Button', nil, parent, 'BackdropTemplate')
    button:SetPoint(point, pointFrame, point2, x, y)
    button:SetSize(width, height)

    button:SetBackdrop({ bgFile = MEDIA_TEXTURE .. "\\WHITE8X8", edgeFile = BORDER, edgeSize = 12, tileSize = 0, insets = { left = 2.5, right = 2.5, top = 2.5, bottom = 2.5 } })
    button:SetBackdropColor(unpack({ 0.15, 0.15, 0.2, 0.9 }))
    button:SetBackdropBorderColor(unpack({ 0.4, 0.4, 0.5, 0.8 }))

    button:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(0.6, 0.6, 0.8, 1)
    end)

    button:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.2, 0.9)
        self:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.8)
    end)

    button:SetScript("OnMouseDown", function(self)
        self:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
    end)

    button:SetScript("OnMouseUp", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.2, 0.9)
    end)

    button.text = button:CreateFontString(nil, nil)
    button.text:SetPoint("CENTER")
    button.text:SetFont(FONT_DEFAULT, 10, "")
    button.text:SetTextColor(1, 1, 1, 1)
    button.text:SetText(text)
    button.text:SetJustifyH("CENTER")


    return button
end

function HttpsxLib:CreateText(parent, label, point, pointFrame, point2, x, y, sizeT, color, style)
    local fontT = {
        ["font"] = FONT_DEFAULT,
        ["size"] = sizeT or 20,
        ["style"] = style or ""
    }

    color = color or { 1, 1, 1, 1 }
    local text = parent:CreateFontString(nil, "OVERLAY")
    text:SetPoint(point, pointFrame, point2, x, y)
    text:SetFont(fontT["font"], fontT["size"], fontT["style"])
    text:SetText(label)
    text:SetJustifyH("LEFT")

    --text:SetShadowOffset(1, -1)
    if fontT["style"] == "OUTLINE" then
        text:SetShadowOffset(0, 0)
        text:SetShadowColor(0, 0, 0, 0.8)
    end

    if color then
        text:SetTextColor(unpack(color))
    end

    return text
end

function HttpsxLib:CreateEditBox(parent, width, height, point, pointFrame, x, y)
    local container = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    container:SetSize(width, height)
    container:SetPoint(point, pointFrame, x, y)
    container:SetBackdrop({ bgFile = MEDIA_TEXTURE .. "\\WHITE8X8", edgeFile = BORDER, edgeSize = 12, tileSize = 0, insets = { left = 2.5, right = 2.5, top = 2.5, bottom = 2.5 } })
    container:SetBackdropColor(0.08, 0.08, 0.12, 0.95)
    container:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)

    container.shadow = container:CreateTexture(nil, "BACKGROUND", nil, -2)
    container.shadow:SetTexture(MEDIA_TEXTURE .. "\\WHITE8x8")
    container.shadow:SetPoint("TOPLEFT", container, "TOPLEFT", 2, -2)
    container.shadow:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -2, 2)
    container.shadow:SetVertexColor(0, 0, 0, 0.4)

    local scrollFrame = CreateFrame("ScrollFrame", nil, container, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", container, 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", container, -28, 5)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetFontObject("GameFontHighlight")
    editBox:SetAutoFocus(false)
    editBox:SetWidth(width - 10)
    editBox:SetTextInsets(8, 8, 8, 8)
    editBox:SetScript("OnEscapePressed", editBox.ClearFocus)

    editBox:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    editBox:SetTextColor(0.9, 0.9, 0.9, 1)

    scrollFrame:SetScrollChild(editBox)

    return editBox
end

function HttpsxLib:CreatePanel(parent, width, height, point, pointFrame, x, y, title)
    local panel = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    panel:SetSize(width, height)
    panel:SetPoint(point, pointFrame, x, y)

    panel:SetBackdrop({ bgFile = MEDIA_TEXTURE .. "\\WHITE8X8", edgeFile = BORDER, edgeSize = 12, tileSize = 0, insets = { left = 2.5, right = 2.5, top = 2.5, bottom = 2.5 } })
    panel:SetBackdropColor(0.06, 0.06, 0.1, 0.98)
    panel:SetBackdropBorderColor(0.35, 0.35, 0.45, 1)

    panel.shadow = panel:CreateTexture(nil, "BACKGROUND", nil, -4)
    panel.shadow:SetTexture(MEDIA_TEXTURE .. "\\WHITE8x8")
    panel.shadow:SetPoint("TOPLEFT", panel, "TOPLEFT", -4, 4)
    panel.shadow:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 4, -4)
    panel.shadow:SetVertexColor(0, 0, 0, 0.5)

    if title then
        panel.title = panel:CreateFontString(nil, "OVERLAY")
        panel.title:SetPoint("TOP", 0, -10)
        panel.title:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        panel.title:SetText(title)
        panel.title:SetTextColor(0.9, 0.8, 0.5)
    end

    return panel
end

function HttpsxLib:CreateCheckBox(parent, text, point, pointFrame, x, y)
    local checkBox = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    checkBox:SetPoint(point, pointFrame, x, y)
    checkBox:SetSize(25, 25)

    checkBox.text = checkBox:CreateFontString(nil, "OVERLAY")
    checkBox.text:SetPoint("LEFT", checkBox, "RIGHT", 5, 0)
    checkBox.text:SetFont(FONT_DEFAULT, 11.5)
    checkBox.text:SetText(text)
    checkBox.text:SetTextColor(0.9, 0.9, 0.9, 1)

    return checkBox
end

function HttpsxLib:CreateDropDown(parent, width, items, point, pointFrame, x, y, defaultText, onSelect)
    local maxVisible = 8
    local itemHeight = 22
    local drop = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    drop:SetSize(width, 24)
    drop:SetPoint(point, pointFrame, x, y)
    drop:SetBackdrop({ bgFile = MEDIA_TEXTURE .. "\\WHITE8X8", edgeFile = BORDER, edgeSize = 12, tileSize = 0, insets = { left = 2.5, right = 2.5, top = 2.5, bottom = 2.5 } })
    drop:SetBackdropColor(0.08, 0.08, 0.12, 0.95)
    drop:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)

    drop.enabled = true

    drop.text = drop:CreateFontString(nil, "OVERLAY")
    drop.text:SetPoint("LEFT", 8, 0)
    drop.text:SetFont(FONT_DEFAULT, 10)
    drop.text:SetTextColor(0.9, 0.9, 0.9, 1)
    drop.text:SetText(defaultText or (items[1] and items[1].text or ""))

    drop.button = CreateFrame("Button", nil, drop)
    drop.button:SetSize(18, 18)
    drop.button:SetPoint("RIGHT", -4, 0)
    drop.button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
    drop.button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
    drop.button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

    drop.listFrame = CreateFrame("Frame", nil, drop, "BackdropTemplate")
    drop.listFrame:SetBackdrop({ bgFile = MEDIA_TEXTURE .. "\\WHITE8X8", edgeFile = BORDER, edgeSize = 12, tileSize = 0, insets = { left = 2.5, right = 2.5, top = 2.5, bottom = 2.5 } })
    drop.listFrame:SetBackdropColor(0.12, 0.12, 0.18, 0.98)
    drop.listFrame:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)
    local visibleCount = math.min(#items, maxVisible)
    drop.listFrame:SetSize(width + 60, (visibleCount + 1) * itemHeight)
    drop.listFrame:SetPoint("TOPLEFT", drop, "BOTTOMLEFT", 0, -2)
    drop.listFrame:Hide()
    drop.listFrame:SetFrameStrata("TOOLTIP")

    local scrollFrame = CreateFrame("ScrollFrame", nil, drop.listFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 8)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(width, #items * itemHeight)
    scrollFrame:SetScrollChild(content)

    drop.listButtons = {}

    for i, item in ipairs(items) do
        local btn = CreateFrame("Button", nil, content, "BackdropTemplate")
        btn:SetSize(width + 48, itemHeight)
        btn:SetPoint("TOPLEFT", 5, -((i - 1) * itemHeight))

        btn.text = btn:CreateFontString(nil, "OVERLAY")
        btn.text:SetPoint("CENTER", 0, 0)
        if item.value:lower():find("%f[%w]fonts%f[%W]") then
            btn.text:SetFont(item.value, 10)
        else
            btn.text:SetFont(FONT_DEFAULT, 10)
        end
        btn.text:SetTextColor(0.9, 0.9, 0.9, 1)
        btn.text:SetText(item.text)

        btn:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.2, 0.2, 0.3, 1)
        end)
        btn:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0, 0, 0, 0)
        end)
        btn:SetScript("OnClick", function()
            drop.text:SetText(item.text)
            drop.selectedValue = item.value
            drop.listFrame:Hide()
            if onSelect then onSelect(drop, item.value, item.text) end
        end)

        btn:SetBackdrop({ bgFile = MEDIA_TEXTURE .. "\\WHITE8x8" })
        btn:SetBackdropColor(0, 0, 0, 0)

        drop.listButtons[i] = btn
    end

    if #items > maxVisible then
        scrollFrame.ScrollBar:Show()
    else
        scrollFrame.ScrollBar:Hide()
    end

    local function ToggleList()
        if not drop.enabled then return end
        if drop.listFrame:IsShown() then
            drop.listFrame:Hide()
        else
            drop.listFrame:Show()
            drop.listFrame:SetFrameLevel(drop:GetFrameLevel() + 10)
        end
    end

    drop.button:SetScript("OnClick", ToggleList)
    drop:SetScript("OnMouseDown", ToggleList)

    -- Закрытие по клику вне
    local function GlobalClick(_, button)
        if not drop.listFrame:IsShown() then return end
        if drop:IsMouseOver() or drop.button:IsMouseOver() then return end
        local x, y = GetCursorPosition()
        local scale = drop.listFrame:GetEffectiveScale()
        x, y = x / scale, y / scale
        local left, bottom, widthF, heightF = drop.listFrame:GetLeft(), drop.listFrame:GetBottom(),
            drop.listFrame:GetWidth(), drop.listFrame:GetHeight()
        if not (x > left and x < left + widthF and y > bottom and y < bottom + heightF) then
            drop.listFrame:Hide()
        end
    end
    drop.listFrame:SetScript("OnShow", function()
        drop.listFrame:RegisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    drop.listFrame:SetScript("OnHide", function()
        drop.listFrame:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    end)
    drop.listFrame:SetScript("OnEvent", GlobalClick)

    -- API
    function drop:SetValue(val)
        for i, item in ipairs(items) do
            if item.value == val then
                drop.text:SetText(item.text)
                drop.selectedValue = val
                break
            end
        end
    end

    function drop:GetValue()
        return drop.selectedValue
    end

    return drop
end

function HttpsxLib:CreateSlider(parent, width, minVal, maxVal, step, point, pointFrame, x, y, defaultVal, onChange)
    local slider = CreateFrame("Slider", nil, parent, "BackdropTemplate")
    slider:SetOrientation("HORIZONTAL")
    slider:SetSize(width, 18)
    slider:SetPoint(point, pointFrame, x, y)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step or 1)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(defaultVal or minVal)

    slider:SetBackdrop({ bgFile = MEDIA_TEXTURE .. "\\WHITE8X8", edgeFile = BORDER, edgeSize = 12, tileSize = 0, insets = { left = 2.5, right = 2.5, top = 2.5, bottom = 2.5 } })
    slider:SetBackdropColor(0.10, 0.10, 0.15, 0.95)
    slider:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)

    slider.valueText = HttpsxLib:CreateNumberEditBox(slider, 50, 20, "BOTTOM", slider, 0, -25, defaultVal or minVal,
        function(self, value)
            slider:SetValue(value)
        end
    )

    --slider.valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    --slider.valueText:SetPoint("TOP", slider, "BOTTOM", 0, -2)
    --slider.valueText:SetFont(FONT_DEFAULT, 14)
    --slider.valueText:SetTextColor(0.9, 0.9, 0.9, 1)
    --slider.valueText:SetText(tostring(defaultVal or minVal))

    slider.minText = slider:CreateFontString(nil, "OVERLAY")
    slider.minText:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -2)
    slider.minText:SetFont(FONT_DEFAULT, 10)
    slider.minText:SetText(tostring(minVal))
    slider.minText:SetTextColor(0.9, 0.9, 0.9, 1)
    slider.maxText = slider:CreateFontString(nil, "OVERLAY")
    slider.maxText:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -2)
    slider.maxText:SetFont(FONT_DEFAULT, 10)
    slider.maxText:SetText(tostring(maxVal))
    slider.maxText:SetTextColor(0.9, 0.9, 0.9, 1)

    slider.thumb = slider:CreateTexture(nil, "ARTWORK")
    slider.thumb:SetColorTexture(0.44, 0.45, 0.50, 0.8)
    slider.thumb:SetSize(10, 16)
    slider:SetThumbTexture(slider.thumb)

    slider._lastValue = defaultVal or minVal

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / (step or 1) + 0.5) * (step or 1)
        if tostring(value) ~= self.valueText:GetText() then
            self.valueText:SetText(tostring(value))
        end
        if onChange and value ~= self._lastValue then
            self._lastValue = value
            onChange(self, value)
        end
    end)

    -- API
    function slider:SetValueText(text)
        self.valueText:SetText(text)
        self:SetValue(tonumber(text))
    end

    function slider:GetValueText()
        return self.valueText:GetText()
    end

    return slider
end

function HttpsxLib:CreateNumberEditBox(parent, width, height, point, pointFrame, x, y, defaultValue, onChange)
    local editBox = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    editBox:SetSize(width, height)
    editBox:SetPoint(point, pointFrame, x, y)
    editBox:SetFont(FONT_DEFAULT, 11, "")
    editBox:SetAutoFocus(false)
    editBox:SetTextInsets(10, 10, 0, 0)
    editBox:SetJustifyH("CENTER")
    editBox:SetBackdrop({
        bgFile = MEDIA_TEXTURE .. "\\WHITE8X8",
        edgeFile = BORDER,
        edgeSize = 8,
        insets = { left = 2.5, right = 2.5, top = 2.5, bottom = 2.5 }
    })
    editBox:SetBackdropColor(0.08, 0.08, 0.12, 0.95)
    editBox:SetBackdropBorderColor(0.3, 0.3, 0.4, 1)
    if editBox.Left then editBox.Left:Hide() end
    if editBox.Middle then editBox.Middle:Hide() end
    if editBox.Right then editBox.Right:Hide() end

    --editBox:SetNumeric(true)

    if defaultValue then
        editBox:SetText(tostring(defaultValue))
    end

    local function FinalizeNumber(self)
        local s = (self:GetText() or ""):match("^%s*(.-)%s*$")
        if s == "" or s == "-" then
            s = self.__lastValid or "0"
            self:SetText(s)
            self:SetCursorPosition(#s)
        end
        if s:match("^%-?%d+$") then
            self.__lastValid = s
            if onChange then onChange(self, tonumber(s)) end
        else
            local back = self.__lastValid or "0"
            self:SetText(back)
            self:SetCursorPosition(#back)
            if onChange then onChange(self, tonumber(back)) end
        end
    end

    editBox.__lastValid = editBox:GetText() ~= "" and editBox:GetText() or "0"

    editBox:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(1.0, 0.74, 0, 0.5) end)
    editBox:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(0.3, 0.3, 0.4, 1) end)

    editBox:SetScript("OnEnterPressed", function(self)
        FinalizeNumber(self)
        self:ClearFocus()
    end)

    editBox:SetScript("OnEditFocusLost", function(self)
        FinalizeNumber(self)
    end)

    editBox:SetScript("OnEscapePressed", function(self)
        local back = self.__lastValid or "0"
        self:SetText(back)
        self:ClearFocus()
    end)

    return editBox
end
