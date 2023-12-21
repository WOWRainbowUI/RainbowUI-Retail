local quickKeybindModeShortcutFrame = nil
local origGameMenuFrame_OnShow = nil

local function overrideScript(frame, script, newHandler)
	local origScript = frame:GetScript(script)
	frame:SetScript(script, newHandler)
	return origScript
end

local function quickKeybindModeShortcutFrame_OnClick()
	QuickKeybindFrame:Show()
end

local function gameMenuFrame_OnShow(self, ...)
	origGameMenuFrame_OnShow(self, ...)

	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + quickKeybindModeShortcutFrame:GetHeight())
end

function BUII_QuickKeybindModeShortcutEnable()
	if not quickKeybindModeShortcutFrame then
		quickKeybindModeShortcutFrame = CreateFrame("Button", "BUIIQuickKeybindModeShortcutMenuButton", GameMenuFrame,
			"GameMenuButtonTemplate")
		quickKeybindModeShortcutFrame:SetText("快速按鍵設定模式")
		quickKeybindModeShortcutFrame:SetScript("OnClick", quickKeybindModeShortcutFrame_OnClick)
	end

	if not quickKeybindModeShortcutFrame:IsVisible() then
		quickKeybindModeShortcutFrame:Show()
	end

	quickKeybindModeShortcutFrame:SetPoint("TOP", GameMenuButtonEditMode, "BOTTOM", 0, -1)
	GameMenuButtonMacros:SetPoint("TOP", quickKeybindModeShortcutFrame, "BOTTOM", 0, -1)

	-- GameMenuFrame adjusts height OnShow so we'll need to override it to take
	-- the new button into account
	if not origGameMenuFrame_OnShow then
		origGameMenuFrame_OnShow = overrideScript(GameMenuFrame, "OnShow", gameMenuFrame_OnShow)
	end
end

function BUII_QuickKeybindModeShortcutDisable()
	quickKeybindModeShortcutFrame:Hide()

	GameMenuButtonMacros:SetPoint("TOP", GameMenuButtonEditMode, "BOTTOM", 0, -1)
	GameMenuFrame:SetScript("OnShow", origGameMenuFrame_OnShow)

	if origGameMenuFrame_OnShow then
		GameMenuFrame:SetScript("OnShow", origGameMenuFrame_OnShow)
		origGameMenuFrame_OnShow = nil
	end
end
