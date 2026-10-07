--=====================================================================================
-- RGX | Simple Quest Plates! - options_icon.lua

-- Author: DonnieDice
-- Description: Main icon options tab (position, scale, display style)
--=====================================================================================

local addonName, SQP = ...
local SQPSettings = SQP.db.global
local format = string.format

function SQP:CreateIconOptions(content)
    if not self.optionControls then self.optionControls = {} end

    local leftColumn, rightColumn = SQP:CreateOptionColumns(content)

    -- == LEFT COLUMN: Position ================================================
    local yOffset = -12

    local posLabel = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    SQP:ApplyDefaultFont(posLabel)
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
		default = 0,
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
		default = 0,
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
    SQP:ApplyDefaultFont(anchorLabel)
    anchorLabel:SetPoint("TOPLEFT", 20, yOffset)
    anchorLabel:SetText(self.L["OPTIONS_ANCHOR"] or "Nameplate Side")
    yOffset = yOffset - 22

    local leftBtn  = self:CreateStyledButton(leftColumn, "Left Side",  90, 25)
    local rightBtn = self:CreateStyledButton(leftColumn, "Right Side", 90, 25)
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

    -- == RIGHT COLUMN: Scale + Display Style ==================================
    local rightYOffset = -12

    local styleLabel = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    SQP:ApplyDefaultFont(styleLabel)
    styleLabel:SetPoint("TOPLEFT", 20, rightYOffset)
    styleLabel:SetText("|cff58be81" .. (self.L["OPTIONS_ICON_STYLE"] or "Icon Style") .. "|r")
    rightYOffset = rightYOffset - 22

	-- Global Scale
	-- Range 0.5–1.5 centers the slider on 1; 1.1 is the baseline default.
	local scaleSlider = self:CreateStyledSlider(rightColumn, {
		key = "scale",
		label = self.L["OPTIONS_GLOBAL_SCALE"] or "Global Scale",
		min = 0.5,
		max = 1.5,
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

    -- Toast Animation (the "?" pop when the quest frame shows)
    local markerHeader = rightColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    markerHeader:SetPoint("TOPLEFT", 20, rightYOffset)
    markerHeader:SetText("|cff58be81Toast Animation|r")
    SQP:ApplyDefaultFont(markerHeader)
    rightYOffset = rightYOffset - 20

    local markerFrame = self:CreateStyledCheckbox(rightColumn, "Show toast animation")
    markerFrame:SetPoint("TOPLEFT", 20, rightYOffset)
    markerFrame.checkbox:SetChecked(SQPSettings.showQuestMarker ~= false)
    self.optionControls.showQuestMarker = markerFrame.checkbox
    markerFrame.checkbox:SetScript("OnClick", function(self)
        SQP:SetSetting('showQuestMarker', self:GetChecked())
    end)
    rightYOffset = rightYOffset - 44

	local markerSizeSlider = self:CreateStyledSlider(rightColumn, {
		key = "questMarkerSize",
		label = "Toast Size",
		min = 10,
		max = 48,
		step = 1,
		default = 28,
		storage = SQPSettings,
		width = 160,
		onChange = function(value)
			SQP:RefreshAllNameplates()
		end,
	})
	markerSizeSlider:SetPoint("TOPLEFT", 20, rightYOffset)
	self.optionControls.questMarkerSize = markerSizeSlider

	rightYOffset = rightYOffset - 48

    -- Display Style (also available on Kill / Loot / Percent tabs)
    rightYOffset = self:CreateDisplayStyleSection(rightColumn, nil, nil, rightYOffset)
end
