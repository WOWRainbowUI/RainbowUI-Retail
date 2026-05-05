--=====================================================================================
-- RGX | Simple Quest Plates! - options_icon.lua

-- Author: DonnieDice
-- Description: Main icon options tab (position, scale, display style)
--=====================================================================================

local addonName, SQP = ...
local format = string.format

function SQP:CreateIconOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(300)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 20, 0)

    -- ── LEFT COLUMN: Position ────────────────────────────────────────────────
    local yOffset = -15

    local posLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    posLabel:SetPoint("TOPLEFT", 20, yOffset)
    posLabel:SetText("|cff58be81" .. (self.L["OPTIONS_ICON_POSITION"] or "Icon Position") .. "|r")
    yOffset = yOffset - 22

	-- X Offset
	local xSlider = self:CreateStyledSlider(leftColumn, {
		key = "offsetX",
		label = self.L["OPTIONS_OFFSET_X"] or "Horizontal Offset",
		min = -100,
		max = 100,
		step = 1,
		default = 12,
		storage = SQPSettings,
		width = 160,
		onChange = function(value)
			SQP:RefreshAllNameplates()
		end,
	})
	xSlider:SetPoint("TOPLEFT", 20, yOffset)
	self.optionControls.offsetX = xSlider

	yOffset = yOffset - 48

	-- Y Offset
	local ySlider = self:CreateStyledSlider(leftColumn, {
		key = "offsetY",
		label = self.L["OPTIONS_OFFSET_Y"] or "Vertical Offset",
		min = -100,
		max = 100,
		step = 1,
		default = 3,
		storage = SQPSettings,
		width = 160,
		onChange = function(value)
			SQP:RefreshAllNameplates()
		end,
	})
	ySlider:SetPoint("TOPLEFT", 20, yOffset)
	self.optionControls.offsetY = ySlider

	yOffset = yOffset - 48

    -- Nameplate side
    local anchorLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    anchorLabel:SetPoint("TOPLEFT", 20, yOffset)
    anchorLabel:SetText(self.L["OPTIONS_ANCHOR"] or "Nameplate Side")
    yOffset = yOffset - 22

    local leftBtn  = self:CreateStyledButton(leftColumn, self.L["Left Side"],  90, 25)
    local rightBtn = self:CreateStyledButton(leftColumn, self.L["Right Side"], 90, 25)
    leftBtn:SetPoint("TOPLEFT", 20, yOffset)
    rightBtn:SetPoint("LEFT", leftBtn, "RIGHT", 8, 0)
    self.optionControls.anchorButtons = {left = leftBtn, right = rightBtn}

    local function UpdateAnchorButtons()
        leftBtn:SetAlpha( SQPSettings.anchor == "RIGHT" and 1 or 0.6)
        rightBtn:SetAlpha(SQPSettings.anchor == "LEFT"  and 1 or 0.6)
    end
    self.optionControls.updateAnchorButtons = UpdateAnchorButtons
    UpdateAnchorButtons()

    leftBtn:SetScript("OnClick", function()
        SQP:SetSetting('anchor', "RIGHT")
        SQP:SetSetting('relativeTo', "LEFT")
        UpdateAnchorButtons()
        SQP:RefreshAllNameplates()
    end)
    rightBtn:SetScript("OnClick", function()
        SQP:SetSetting('anchor', "LEFT")
        SQP:SetSetting('relativeTo', "RIGHT")
        UpdateAnchorButtons()
        SQP:RefreshAllNameplates()
    end)

    local anchorReset = self:CreateInlineResetButton(leftColumn, function()
        SQP:SetSetting('anchor', "RIGHT")
        SQP:SetSetting('relativeTo', "LEFT")
        UpdateAnchorButtons()
        SQP:RefreshAllNameplates()
    end)
    anchorReset:SetPoint("LEFT", rightBtn, "RIGHT", 6, 0)

    -- ── RIGHT COLUMN: Scale + Display Style ──────────────────────────────────
    local rightYOffset = -15

    local styleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    styleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    styleLabel:SetText("|cff58be81" .. (self.L["OPTIONS_ICON_STYLE"] or "Icon Style") .. "|r")
    rightYOffset = rightYOffset - 22

	-- Global Scale
	local scaleSlider = self:CreateStyledSlider(rightColumn, {
		key = "scale",
		label = self.L["OPTIONS_GLOBAL_SCALE"] or "Global Scale",
		min = 0.5,
		max = 3.0,
		step = 0.1,
		default = 1.1,
		storage = SQPSettings,
		width = 160,
		onChange = function(value)
			SQP:RefreshAllNameplates()
		end,
	})
	scaleSlider:SetPoint("TOPLEFT", 20, rightYOffset)
	self.optionControls.scale = scaleSlider

	rightYOffset = rightYOffset - 48

    -- Display Style (also available on Kill / Loot / Percent tabs)
    rightYOffset = self:CreateDisplayStyleSection(rightColumn, nil, nil, rightYOffset)
end
