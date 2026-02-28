--=====================================================================================
-- RGX | Simple Quest Plates! - options_widgets.lua

-- Author: DonnieDice
-- Description: Custom widget creation functions
--=====================================================================================

local addonName, SQP = ...
local CreateFrame = CreateFrame

-- Create custom styled button
function SQP:CreateStyledButton(parent, text, width, height)
    local button = CreateFrame("Button", nil, parent)
    button:SetSize(width or 120, height or 30)

    -- Normal texture
    button:SetNormalTexture("Interface\\Buttons\\UI-DialogBox-Button-Up")
    button:GetNormalTexture():SetTexCoord(0, 1, 0, 0.71875)

    -- Highlight texture
    button:SetHighlightTexture("Interface\\Buttons\\UI-DialogBox-Button-Highlight")
    button:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.71875)
    button:GetHighlightTexture():SetBlendMode("ADD")

    -- Pushed texture
    button:SetPushedTexture("Interface\\Buttons\\UI-DialogBox-Button-Down")
    button:GetPushedTexture():SetTexCoord(0, 1, 0, 0.71875)

    -- Text
    button:SetText(text)
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    button:SetDisabledFontObject("GameFontDisable")

    return button
end

-- Create small inline reset button (↺ symbol)
function SQP:CreateInlineResetButton(parent, onClickFn)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(40, 16)
    btn:SetNormalTexture("Interface\\Buttons\\UI-DialogBox-Button-Up")
    btn:GetNormalTexture():SetTexCoord(0, 1, 0, 0.71875)
    btn:SetHighlightTexture("Interface\\Buttons\\UI-DialogBox-Button-Highlight")
    btn:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.71875)
    btn:GetHighlightTexture():SetBlendMode("ADD")
    btn:SetPushedTexture("Interface\\Buttons\\UI-DialogBox-Button-Down")
    btn:GetPushedTexture():SetTexCoord(0, 1, 0, 0.71875)

    local lbl = btn:CreateFontString(nil, "OVERLAY")
    lbl:SetFont(STANDARD_TEXT_FONT, 11)
    lbl:SetAllPoints()
    lbl:SetJustifyH("CENTER")
    lbl:SetText("重置") -- ↺ (U+21BA)

    btn:SetAlpha(0.7)
    btn:SetScript("OnClick", onClickFn)
    btn:SetScript("OnEnter", function(self) self:SetAlpha(1.0) end)
    btn:SetScript("OnLeave", function(self) self:SetAlpha(0.7) end)
    return btn
end

-- Create custom slider
function SQP:CreateStyledSlider(parent, min, max, step, width)
    local slider = CreateFrame("Slider", nil, parent, "BackdropTemplate")
    slider:SetSize(width or 200, 16)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    -- Background
    slider:SetBackdrop({
        bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
        edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
        tile = true,
        tileSize = 8,
        edgeSize = 8,
        insets = {left = 3, right = 3, top = 6, bottom = 6}
    })

    -- Thumb
    slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")

    return slider
end

-- Create custom checkbox
function SQP:CreateStyledCheckbox(parent, text)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(300, 24)

    local checkbox = CreateFrame("CheckButton", nil, frame)
    checkbox:SetSize(24, 24)
    checkbox:SetPoint("LEFT", 0, 0)

    checkbox:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    checkbox:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    checkbox:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
    checkbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

    local label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    label:SetText(text)

    frame.checkbox = checkbox
    frame.label = label

    return frame
end
