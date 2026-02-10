
-- Create a SecureUnitButtonTemplate frame for right-click menu
local menuButton = CreateFrame("Button", "PRD_RightClickMenuButton", UIParent, "SecureUnitButtonTemplate")

-- PRD Health and Power bar containers
local prdHealth = _G.PersonalResourceDisplayFrame and _G.PersonalResourceDisplayFrame.HealthBarsContainer
local prdPower = _G.PersonalResourceDisplayFrame and _G.PersonalResourceDisplayFrame.PowerBar

local function UpdateMenuButtonVisibility()
	if prdHealth and prdPower and prdHealth:IsShown() and prdPower:IsShown() then
		menuButton:Show()
	else
		menuButton:Hide()
	end
end

if prdHealth then
	prdHealth:HookScript("OnShow", UpdateMenuButtonVisibility)
	prdHealth:HookScript("OnHide", UpdateMenuButtonVisibility)
end
if prdPower then
	prdPower:HookScript("OnShow", UpdateMenuButtonVisibility)
	prdPower:HookScript("OnHide", UpdateMenuButtonVisibility)
end

-- Call once at load to set initial state
UpdateMenuButtonVisibility()
-- SavedVariables for config
PRDRightClickMenuConfig = PRDRightClickMenuConfig or { width = 250, height = 35, x = 0, y = 0 }

local function AnchorMenuButton()
	local width = PRDRightClickMenuConfig.width or 250
	local height = PRDRightClickMenuConfig.height or 35
	local x = PRDRightClickMenuConfig.x or 0
	local y = PRDRightClickMenuConfig.y or 0
	local phf = _G.PlayerHealthTextFrame
	if phf and phf:IsShown() then
		local left = phf:GetLeft()
		local bottom = phf:GetBottom()
		if left and bottom then
			menuButton:SetSize(width, height)
			menuButton:ClearAllPoints()
			-- Place just below PlayerHealthTextFrame, with offset
			menuButton:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left + x, bottom + 4 + y)
			return
		end
	end
	menuButton:SetSize(width, height)
	menuButton:ClearAllPoints()
	menuButton:SetPoint("CENTER", UIParent, "CENTER", x, y)
end
-- Config window for /prdright
local configFrame
SLASH_PRDRIGHT1 = "/prdright"
SlashCmdList["PRDRIGHT"] = function()
	if not configFrame then
		configFrame = CreateFrame("Frame", "PRDRightClickMenuConfigFrame", UIParent, "BasicFrameTemplateWithInset")
		configFrame:SetSize(260, 240)
		configFrame:SetPoint("CENTER")
		configFrame:SetMovable(true)
		configFrame:EnableMouse(true)
		configFrame:RegisterForDrag("LeftButton")
		configFrame:SetScript("OnDragStart", configFrame.StartMoving)
		configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
		configFrame.title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		configFrame.title:SetPoint("TOP", 0, -10)
		configFrame.title:SetText("Right Click Menu Config")

		-- Width slider
		local widthSlider = CreateFrame("Slider", nil, configFrame, "OptionsSliderTemplate")
		widthSlider:SetPoint("TOP", 0, -40)
		widthSlider:SetMinMaxValues(50, 600)
		widthSlider:SetValueStep(1)
		widthSlider:SetObeyStepOnDrag(true)
		widthSlider:SetWidth(200)
		widthSlider:SetValue(PRDRightClickMenuConfig.width)
		widthSlider.text = widthSlider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		widthSlider.text:SetPoint("TOP", widthSlider, "BOTTOM", 0, -2)
		widthSlider.text:SetText("Width: " .. PRDRightClickMenuConfig.width)
		widthSlider:SetScript("OnValueChanged", function(self, value)
			value = math.floor(value)
			PRDRightClickMenuConfig.width = value
			widthSlider.text:SetText("Width: " .. value)
			AnchorMenuButton()
		end)

		-- Height slider
		local heightSlider = CreateFrame("Slider", nil, configFrame, "OptionsSliderTemplate")
		heightSlider:SetPoint("TOP", widthSlider, "BOTTOM", 0, -40)
		heightSlider:SetMinMaxValues(10, 200)
		heightSlider:SetValueStep(1)
		heightSlider:SetObeyStepOnDrag(true)
		heightSlider:SetWidth(200)
		heightSlider:SetValue(PRDRightClickMenuConfig.height)
		heightSlider.text = heightSlider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		heightSlider.text:SetPoint("TOP", heightSlider, "BOTTOM", 0, -2)
		heightSlider.text:SetText("Height: " .. PRDRightClickMenuConfig.height)
		heightSlider:SetScript("OnValueChanged", function(self, value)
			value = math.floor(value)
			PRDRightClickMenuConfig.height = value
			heightSlider.text:SetText("Height: " .. value)
			AnchorMenuButton()
		end)
		-- X Offset slider
		local xSlider = CreateFrame("Slider", nil, configFrame, "OptionsSliderTemplate")
		xSlider:SetPoint("TOP", heightSlider, "BOTTOM", 0, -40)
		xSlider:SetMinMaxValues(-400, 400)
		xSlider:SetValueStep(1)
		xSlider:SetObeyStepOnDrag(true)
		xSlider:SetWidth(200)
		xSlider:SetValue(PRDRightClickMenuConfig.x or 0)
		xSlider.text = xSlider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		xSlider.text:SetPoint("TOP", xSlider, "BOTTOM", 0, -2)
		xSlider.text:SetText("X Offset: " .. (PRDRightClickMenuConfig.x or 0))
		xSlider:SetScript("OnValueChanged", function(self, value)
			value = math.floor(value)
			PRDRightClickMenuConfig.x = value
			xSlider.text:SetText("X Offset: " .. value)
			AnchorMenuButton()
		end)

		-- Y Offset slider
		local ySlider = CreateFrame("Slider", nil, configFrame, "OptionsSliderTemplate")
		ySlider:SetPoint("TOP", xSlider, "BOTTOM", 0, -40)
		ySlider:SetMinMaxValues(-400, 400)
		ySlider:SetValueStep(1)
		ySlider:SetObeyStepOnDrag(true)
		ySlider:SetWidth(200)
		ySlider:SetValue(PRDRightClickMenuConfig.y or 0)
		ySlider.text = ySlider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		ySlider.text:SetPoint("TOP", ySlider, "BOTTOM", 0, -2)
		ySlider.text:SetText("Y Offset: " .. (PRDRightClickMenuConfig.y or 0))
		ySlider:SetScript("OnValueChanged", function(self, value)
			value = math.floor(value)
			PRDRightClickMenuConfig.y = value
			ySlider.text:SetText("Y Offset: " .. value)
			AnchorMenuButton()
		end)


		-- Hide menuButton when config closes
		configFrame:SetScript("OnHide", function()
			menuButton:SetAlpha(0)
		end)
	end
	configFrame:Show()
	menuButton:SetAlpha(1)
end
AnchorMenuButton()
menuButton:SetAlpha(0)
-- Re-anchor when PlayerHealthTextFrame moves or shows
local phf = _G.PlayerHealthTextFrame
if phf then
	phf:HookScript("OnShow", AnchorMenuButton)
	phf:HookScript("OnSizeChanged", AnchorMenuButton)
	phf:HookScript("OnHide", AnchorMenuButton)
	if phf.SetPoint then
		hooksecurefunc(phf, "SetPoint", AnchorMenuButton)
	end
end
menuButton:SetFrameStrata("DIALOG")
menuButton:SetFrameLevel(100)

-- Visual background
local tex = menuButton:CreateTexture(nil, "BACKGROUND")
tex:SetAllPoints()
tex:SetColorTexture(0.2, 0.2, 0.2, 0.8) -- Dark grey background
menuButton.texture = tex

-- Set the unit this button should represent
menuButton:SetAttribute("unit", "player")

-- Register for left and right clicks
menuButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

-- Assign actions to click types
menuButton:SetAttribute("*type1", "target")     -- Left-click targets the unit
menuButton:SetAttribute("*type2", "togglemenu") -- Right-click opens the unit menu

-- Only show if the unit exists (player always exists, but this is best practice)
RegisterUnitWatch(menuButton)

-- Optional: Tooltip for clarity
menuButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("Right-click for menu", 1, 1, 1)
	GameTooltip:Show()
end)
menuButton:SetScript("OnLeave", function(self)
	GameTooltip:Hide()
end)
