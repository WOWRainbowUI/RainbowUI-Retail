local ADDON_NAME, private = ...
local L = private.L

local LOIHLootFrame = CreateFrame("Frame", "LOIHLootFrame", UIParent)
UIPanelWindows["LOIHLootFrame"] = { area = "left", pushable = 3, whileDead = 1, xoffset = -16, yoffset = 12 }
tinsert(UISpecialFrames, "LOIHLootFrame")
private.Frame = LOIHLootFrame

LOIHLootFrame:SetWidth(384)
LOIHLootFrame:SetHeight(512)
LOIHLootFrame:SetHitRectInsets(10, 34, 8, 72)
LOIHLootFrame:SetToplevel(true)
LOIHLootFrame:EnableMouse(true)
LOIHLootFrame:SetMovable(true)

LOIHLootFrame:SetScript("OnShow", function(self)
	LOIHLootFrame.TitleText:SetFormattedText("%s %s", ADDON_NAME, private.version)
	private.Frame_UpdateList()
	private.Frame_UpdateButtons()
end)

------------------------------------------------------------------------
--  BACKGROUND TEXTURES

local topLeftIcon = LOIHLootFrame:CreateTexture(nil, "BACKGROUND")
topLeftIcon:SetSize(60, 60)
topLeftIcon:SetPoint("TOPLEFT", 7, -6)
SetPortraitToTexture(topLeftIcon, "Interface\\FriendsFrame\\FriendsFrameScrollIcon")
LOIHLootFrame.TopLeftIcon = topLeftIcon

local topLeft = LOIHLootFrame:CreateTexture(nil, "BORDER")
topLeft:SetSize(256, 256)
topLeft:SetPoint("TOPLEFT")
topLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
LOIHLootFrame.TopLeft = topLeft

local topRight = LOIHLootFrame:CreateTexture(nil, "BORDER")
topRight:SetSize(128, 256)
topRight:SetPoint("TOPRIGHT")
topRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
LOIHLootFrame.BopRight = topRight

local bottomLeft = LOIHLootFrame:CreateTexture(nil, "BORDER")
bottomLeft:SetSize(256, 256)
bottomLeft:SetPoint("BOTTOMLEFT")
bottomLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
LOIHLootFrame.BottomLeft = bottomLeft

local bottomRight = LOIHLootFrame:CreateTexture(nil, "BORDER")
bottomRight:SetSize(128, 256)
bottomRight:SetPoint("BOTTOMRIGHT")
bottomRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
LOIHLootFrame.BottomRight = bottomRight

local barLeft = LOIHLootFrame:CreateTexture(nil, "ARTWORK")
barLeft:SetSize(256, 16)
barLeft:SetPoint("TOPLEFT", 15, -314)
barLeft:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-HorizontalBar")
barLeft:SetTexCoord(0, 1, 0, 0.25)
LOIHLootFrame.BarLeft = barLeft

local barRight = LOIHLootFrame:CreateTexture(nil, "ARTWORK")
barRight:SetSize(75, 16)
barRight:SetPoint("LEFT", barLeft, "RIGHT")
barRight:SetTexture("Interface\\ClassTrainerFrame\\UI-ClassTrainer-HorizontalBar")
barRight:SetTexCoord(0, 0.29296875, 0.25, 0.5)
LOIHLootFrame.BarRight = barRight

------------------------------------------------------------------------
--  TITLE TEXT

local title = LOIHLootFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
title:SetPoint("TOP", 0, -17)
LOIHLootFrame.TitleText = title

------------------------------------------------------------------------
--  DRAG REGION

local drag = CreateFrame("Frame", nil, LOIHLootFrame)
drag:SetSize(256, 28)
drag:SetPoint("TOP", 8, -10)
LOIHLootFrame.DragFrame = drag

drag:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" then
		LOIHLootFrame.isMoving = true
		LOIHLootFrame:StartMoving()
		CloseDropDownMenus()
	end
end)

local function _StopMovingFrame(self, ...)
	if LOIHLootFrame.isMoving then
		LOIHLootFrame:StopMovingOrSizing()
		LOIHLootFrame:SetUserPlaced(false)
		LOIHLootFrame.isMoving = nil
	end
end

drag:SetScript("OnMouseUp", _StopMovingFrame)
drag:SetScript("OnHide", _StopMovingFrame)

------------------------------------------------------------------------
--  CLOSE X BUTTON

local closeX = CreateFrame("Button", nil, LOIHLootFrame, "UIPanelCloseButton")
closeX:SetPoint("TOPRIGHT", -34, -12)
LOIHLootFrame.CloseButtonX = closeX

------------------------------------------------------------------------
--  SYNC BUTTON

local sync = CreateFrame("Button", "$parentSync", LOIHLootFrame, "UIPanelButtonTemplate")
sync:SetSize(60, 22)
sync:SetPoint("TOPRIGHT", -40, -49)
sync:SetNormalFontObject(GameFontNormalSmall)
sync:SetHighlightFontObject(GameFontHighlightSmall)
sync:SetDisabledFontObject(GameFontDisableSmall)
sync:SetScript("OnClick", private.Frame_SyncButtonOnClick)
sync:SetText(L.BUTTON_SYNC)
LOIHLootFrame.SyncButton = sync

------------------------------------------------------------------------
--  SYNC STATUS TEXT

local syncText = sync:CreateFontString(nil, "OVERLAY", "GameFontNormal")
syncText:SetSize(100, 0)
syncText:SetPoint("RIGHT", sync, "LEFT", -10, 0)
syncText:SetJustifyH("RIGHT")
syncText:SetIndentedWordWrap(false)
LOIHLootFrame.SyncText = syncText

------------------------------------------------------------------------
--  TAB BUTTONS

local subtitleTab = CreateFrame("Button", "$parentSubTitleTab", LOIHLootFrame, "TabSystemTemplate")
subtitleTab:SetPoint("TOPLEFT", 70, -42)
do 
	local tabId = subtitleTab:AddTab(L.TAB_WISHLIST)
	subtitleTab:SetTabEnabled(tabId, false)
	local tabButton = subtitleTab:GetTabButton(tabId)
	tabButton.isTabOnTop = true
	tabButton:HandleRotation()
end
LOIHLootFrame.SubTitleTab = subtitleTab

------------------------------------------------------------------------
--  LIST FRAME

local listFrame = CreateFrame("Frame", "$parentListFrame", LOIHLootFrame)
listFrame:SetSize(320, 242)
listFrame:SetPoint("TOPLEFT", 20, -74)
LOIHLootFrame.ListFrame = listFrame

------------------------------------------------------------------------
--  LIST SCROLLBAR

local scrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", listFrame, "HybridScrollFrameTemplate")
scrollFrame:SetSize(296, 242)
scrollFrame:SetPoint("TOPLEFT")
scrollFrame.stepSize = private.LIST_BUTTON_HEIGHT*4
scrollFrame.update = private.Frame_UpdateList
LOIHLootFrame.ScrollFrame = scrollFrame

local scrollBar = CreateFrame("Slider", "$parentScrollBar", scrollFrame, "HybridScrollBarTemplate")
scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 4, -13)
scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 4, 13)
scrollBar.doNotHide = true
LOIHLootFrame.ScrollBar = scrollBar

------------------------------------------------------------------------
--  LIST BUTTONS

HybridScrollFrame_CreateButtons(scrollFrame, "LOIHLootWishlistTemplate", 2, 0, "TOPLEFT", "TOPLEFT", 0, 2, "TOP", "BOTTOM")

------------------------------------------------------------------------
--  DESCRIPTION FRAME

local description = CreateFrame("Frame", nil, LOIHLootFrame)
description:SetSize(320, 102)
description:SetPoint("TOPLEFT", 20, -326)
LOIHLootFrame.DescriptionFrame = description

------------------------------------------------------------------------
--  TEXT SCROLL FRAME (for non-editable text)

local textScroll = CreateFrame("ScrollFrame", "LOIHLootTextScrollFrame", description)
textScroll:SetSize(296, 102)
textScroll:SetPoint("TOPLEFT")
textScroll:Hide()
textScroll.scrollBarHideable = true
LOIHLootFrame.TextScrollFrame = textScroll

textScroll:SetScript("OnMouseWheel", ScrollFrameTemplate_OnMouseWheel)
textScroll:SetScript("OnVerticalScroll", private.Frame_OnVerticalScroll)
textScroll:SetScript("OnScrollRangeChanged", function(self, xOffset, yOffset)
	-- Scroll range will only change when we put new text into the
	-- textbox, so when this happens we also set the scrollbar
	-- position to zero to show the top of the text always.
	ScrollFrame_OnScrollRangeChanged(self, yOffset)
	LOIHLootTextScrollFrameScrollBar:SetValue(0)
end)

--[[
-- 10.1 Removes some old ScrollBar templates and leaving this in causes double scrollbars
local textBar = CreateFrame("Slider", "$parentScrollBar", textScroll, "UIPanelScrollBarTemplate")
textBar:SetPoint("TOPLEFT", textScroll, "TOPRIGHT", 8, -16)
textBar:SetPoint("BOTTOMLEFT", textScroll, "BOTTOMRIGHT", 8, 14)
LOIHLootFrame.TextScrollFrame.ScrollBar = textBar
]]

ScrollFrame_OnLoad(textScroll)
--ScrollFrame_OnScrollRangeChanged(textScroll, 0)
textScroll:SetVerticalScroll(0) -- 10.1 Removes some old ScrollBar templates

local textChild = CreateFrame("Frame", "$parentScrollChild", textScroll)
textChild:SetSize(296, 102)
textChild:SetPoint("TOPLEFT")
textChild:EnableMouse(true)
textScroll:SetScrollChild(textChild)
LOIHLootFrame.TextScrollChild = textChild

local textBox = textChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
textBox:SetSize(286, 0)
textBox:SetPoint("TOPLEFT", 10, -2)
textBox:SetJustifyH("LEFT")
textBox:SetIndentedWordWrap(false)
LOIHLootFrame.TextBox = textBox

------------------------------------------------------------------------
--  BONUSROLLFRAME

local bonusText = BonusRollFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
--bonusText:SetPoint("RIGHT", BonusRollFrame.PromptFrame.RollButton, "LEFT", -10, 0)
bonusText:SetPoint("RIGHT", BonusRollFrame.PromptFrame.InfoFrame)
bonusText:SetJustifyH("RIGHT")
bonusText:Hide()
LOIHLootFrame.BonusText = bonusText

------------------------------------------------------------------------
--	Addon

LOIHLootFrame:SetScript("OnEvent", private.OnEvent)

private.OnLoad(LOIHLootFrame)

-- EOF