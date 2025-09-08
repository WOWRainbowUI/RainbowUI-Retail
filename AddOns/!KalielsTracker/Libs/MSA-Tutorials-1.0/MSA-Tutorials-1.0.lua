--- MSA-Tutorials-1.0
--- Tutorials from Marouan Sabbagh based on CustomTutorials from João Cardoso.

--[[
Copyright 2010-2015 João Cardoso
CustomTutorials is distributed under the terms of the GNU General Public License (or the Lesser GPL).

CustomTutorials is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

CustomTutorials is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with CustomTutorials. If not, see <http://www.gnu.org/licenses/>.
--]]

--[[
General Arguments
-----------------
 savedvariable
 icon ........... Default is "?" icon. Image path (tga or blp).
 title .......... Default is "Tutorial".
 width .......... Default is 350. Internal frame width (without borders).
 height ......... Default is 0. Internal frame height (without borders).
                  - 0 .... auto height
                  - >0 ... fixed height with scrollbar
 font ........... Default is game font (empty string).

Frame Arguments
---------------
 title .......... Title relative to frame (replace General value).
 width .......... Width relative to frame (replace General value).
 height ......... Height relative to frame (replace General value).
Note: All other arguments can be used as a general!
 paddingX ....... Default is 25. Left and Right padding.
 paddingTop ..... Default is 20.
 paddingBottom .. Default is 20.
 image .......... [optional] Image path (tga or blp).
 imageWidth ..... Default is 256.
 imageHeight .... Default is 128.
 imagePoint ..... Default is "TOP".
 imageX ......... Default is 0.
 imageY ......... Default is 20.
 imageAbsolute .. Default is false. The image is not part of the content flow and no place is created for it.
 imageTexCoords . [optional] Sets the coordinates for cropping or transforming the texture.
 text ........... Text string.
 editbox ........ [optional] Table of edit boxes. Edit box is out of content flow.
                  One table keys:
                  - icon ....... Left icon
                  - text ....... [required]
                  - width ...... Default is 400
                  - left ....... Default is 0
                  - top ........ Default is 0
                  - bottom ..... Default is 0
                  - showHint ... Default is true
 button ......... [optional] Button text string (directing value). Button is out of content flow.
 buttonWidth .... Default is 100.
 buttonClick .... Function with button's click action.
 buttonLeft, buttonBottom
 shine .......... [optional] The frame to anchor the flashing "look at me!" glow.
 shineTop, shineBottom, shineLeft, shineRight
 point .......... Default is "CENTER".
 anchor ......... Default is "UIParent".
 relPoint ....... Default is "CENTER".
 x, y ........... Default is 0, 0.
--]]

-- Lua API
local floor = math.floor
local fmod = math.fmod
local format = string.format
local strfind = string.find
local round = function(n) return floor(n + 0.5) end

local Lib = LibStub:NewLibrary('MSA-Tutorials-1.0', 17)
if Lib then
	Lib.NewFrame, Lib.NewButton, Lib.UpdateFrame = nil
	Lib.numFrames = Lib.numFrames or 1
	Lib.frames = Lib.frames or {}
else
	return
end

local BUTTON_TEX = 'Interface\\Buttons\\UI-SpellbookIcon-%sPage-%s'
local Frames = Lib.frames
local frameBorderLeft = 7
local frameBorderRight = 9
local frameBorderTop = 26
local frameBorderBottom = 28
local freeEditboxes = {}

local default = {
	title = "Tutorial",
	width = 350,
	height = 0,
	font = "",
	paddingX = 25,
	paddingTop = 20,
	paddingBottom = 20,
	imageWidth = 256,
	imageHeight = 128,
	imagePoint = "TOP",
	imageX = 0,
	imageY = 0,
	headingFont = "Fonts\\bLEI00D.ttf",
	headingSize = 16,
	imageFloat = false,
	buttonWidth = 100,
	point = "CENTER",
	anchor = UIParent,
	relPoint = "CENTER",
	x = 0,
	y = 0,
}

--[[ Internal API ]]--

local function ConvertPixelsToUI(pixels, frameScale)
	local physicalScreenHeight = select(2, GetPhysicalScreenSize());
	return (pixels * 768.0)/(physicalScreenHeight * frameScale);
end

local function EditboxSetWidth(editbox, maxWidth)
	local width = editbox._textLength + editbox.inset + 2
	if width > 0 and width < maxWidth then
		editbox:SetWidth(width)
	else
		editbox:SetWidth(maxWidth)
	end
end

local function NewEditbox(frame)
	local numFreeEditboxes = #freeEditboxes
	local editbox
	if numFreeEditboxes > 0 then
		editbox = tremove(freeEditboxes, numFreeEditboxes)
		editbox:SetParent(frame)
	else
		editbox = CreateFrame('EditBox', nil, frame)
		editbox:SetFontObject(GameFontHighlight)
		editbox:SetTextColor(0, 0.5, 1)
		editbox:SetAutoFocus(false)
		editbox:SetAltArrowKeyMode(true)
		editbox.measurer = editbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		local icon = editbox:CreateTexture(nil, "ARTWORK")
		icon:SetSize(16, 16)
		icon:SetVertexColor(0.93, 0.76, 0)
		icon:SetPoint("LEFT")
		editbox.icon = icon
		local hint = editbox:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		hint:SetPoint("LEFT", editbox, "RIGHT", 4, -1)
		hint:SetText("CTRL+C to copy")
		hint:SetTextColor(0.93, 0.76, 0)
		hint:Hide()
		editbox.hint = hint
		editbox.hintWidth = hint:GetWidth()
		editbox:SetScript("OnEditFocusGained", function(self)
			self:SetTextColor(1, 1, 1)
			self:HighlightText()
			if self.showHint then
				if self._textLength + self.hintWidth + 4 > self.maxWidth then
					self:SetWidth(self.maxWidth - self.hintWidth - 4)
				end
				self.hint:Show()
			end
		end)
		editbox:SetScript("OnEditFocusLost", function(self)
			self:SetTextColor(0, 0.5, 1)
			self:HighlightText(0, 0)
			if self.showHint then
				EditboxSetWidth(self, self.maxWidth)
				self.hint:Hide()
			end
		end)
		editbox:SetScript("OnMouseDown", function(self)
			if self:HasFocus() then
				C_Timer.After(0, function()
					self:HighlightText()
				end)
			end
		end)
		editbox:SetScript("OnMouseUp", function(self)
			if self:HasFocus() then
				self:SetCursorPosition(0)
				self:HighlightText()
			end
		end)
		editbox:SetScript("OnTextChanged", function(self, user)
			if user then
				self:SetText(self._text)
				self:SetCursorPosition(0)
				self:HighlightText()
			end
		end)
		editbox:SetScript("OnEnterPressed", function(self)
			self:ClearFocus()
			ChatFrame_OpenChat("")
		end)
		editbox:SetScript("OnEscapePressed", function(self)
			self:ClearFocus()
		end)
		editbox:SetScript("OnEnter", function(self)
			if not self:HasFocus() then
				self:SetTextColor(0.48, 0.73, 1)
			end
		end)
		editbox:SetScript("OnLeave", function(self)
			if not self:HasFocus() then
				self:SetTextColor(0, 0.5, 1)
			end
		end)
	end
	editbox.icon:SetTexture()
	editbox:SetTextInsets(0, 0, 0, 0)
	editbox.inset = 0
	editbox.showHint = true
	return editbox
end

local function RemoveEditboxes(frame)
	for i = 1, #frame.editboxes do
		tinsert(freeEditboxes, frame.editboxes[i])
		frame.editboxes[i]:Hide()
		frame.editboxes[i] = nil
	end
end

local function UpdateFrame(frame, i)
	local data = frame.data[i]
	if not data then
		return
	end

	for k, v in pairs(default) do
		if not data[k] then
			if not frame.data[k] then
				data[k] = v
			else
				data[k] = frame.data[k]
			end
		end
	end
	
	-- Callbacks
	if frame.data.onShow then
		frame.data.onShow(frame.data, i)
	end

	-- Cache inline texture
	local j, idx = 1, 1
	local lastTex
	while idx do
		local s, e, tex = strfind(data.text, "|T(Interface\\AddOns\\[^:]+)[^|]+|t", idx)
		if tex then
			if tex ~= lastTex then
				if not frame["cache"..j] then
					frame["cache"..j] = frame:CreateTexture()
				end
				frame["cache"..j]:SetTexture(tex)
				lastTex = tex
				j = j + 1
			end
			idx = e
		else
			break
		end
	end

	-- Frame
	frame:ClearAllPoints()
	frame:SetPoint(data.point, data.anchor, data.relPoint, data.x, data.y)
	frame:SetWidth(data.width + frameBorderLeft + frameBorderRight)
	local titleText = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and frame.TitleContainer.TitleText or frame.TitleText
	titleText:SetPoint('TOP', 0, -5)
	titleText:SetText(data.title)

	frame.scroll:SetPoint('TOPLEFT', frameBorderLeft + data.paddingX, (frameBorderTop + data.paddingTop) * -1)
	frame.scroll:SetPoint('BOTTOMRIGHT', (frameBorderRight + 23) * -1, frameBorderBottom + data.paddingBottom)
	frame.scroll:SetVerticalScroll(0)
	frame.scroll.ScrollBar:SetPoint("TOPLEFT", frame.scroll, "TOPRIGHT", 5, -1 * (default.paddingTop - data.paddingTop - 2))
	frame.scroll.ScrollBar:SetPoint("BOTTOMLEFT", frame.scroll, "BOTTOMRIGHT", 5, default.paddingBottom - data.paddingBottom - 3)
	frame.content:SetWidth(data.width - data.paddingX - max(data.paddingX, 25))

	local height = 0
	local textPaddingTop = 0

	-- Image
	for _, image in pairs(frame.images) do
		image:Hide()
	end
	if data.image then
		local img = frame.images[i]
		if not img then
			img = CreateFrame("Frame")
			img:SetFrameLevel(1)
			img.texture = img:CreateTexture()
			img.texture:SetAllPoints()
		end
		img:SetParent(data.imageAbsolute and frame or frame.content)
		img.texture:SetTexture(data.image)
		if data.imageTexCoords then
			img.texture:SetTexCoord(unpack(data.imageTexCoords))
		end
		img:SetSize(data.imageWidth, data.imageHeight)
		img:SetPoint(data.imagePoint, data.imageX, data.imageY)
		img:Show()
		frame.images[i] = img
		if not data.imageAbsolute then
			textPaddingTop = data.imageY + data.imageHeight + 20
			height = height + textPaddingTop
		end
	end

	-- Heading
	if data.heading then
		frame.heading:SetPoint('TOPLEFT', 0, textPaddingTop * -1)
		if data.headingFont then
			frame.heading:SetFont(data.headingFont, data.headingSize)
		end
		frame.heading:SetText(data.heading)
		height = height + frame.heading:GetHeight()
		frame.heading:Show()
	else
		frame.heading:Hide()
	end

	-- Text
	if data.heading then
		frame.text:SetPoint('TOPLEFT', frame.heading, 'BOTTOMLEFT', 0, -16)
		height = height + 16
	else
		frame.text:SetPoint('TOPLEFT', 0, textPaddingTop * -1)
	end
	frame.text:SetText(data.text)

	local textHeight = round(frame.text:GetHeight() + 3)
	textHeight = textHeight + fmod(textHeight, 2)
	height = height + textHeight
	frame.content:SetHeight(height)

	height = height + data.paddingTop + data.paddingBottom
	if data.height > 0 and height > data.height then
		height = data.height
	end
	height = height + frameBorderTop + frameBorderBottom
	frame:SetHeight(height)

	frame.i = i
	frame:Show()

	-- EditBox
	RemoveEditboxes(frame)
	if data.editbox then
		for k = 1, #data.editbox do
			local editbox = NewEditbox(frame.content)
			editbox:ClearFocus()
			editbox:ClearAllPoints()
			if data.editbox[k].top then
				editbox:SetPoint('TOPLEFT', (data.editbox[k].left or 0), (data.editbox[k].top or 0) * -1)
			elseif data.editbox[k].bottom then
				editbox:SetPoint('BOTTOMLEFT', (data.editbox[k].left or 0), data.editbox[k].bottom or 0)
			end
			editbox._text = data.editbox[k].text
			editbox:SetText(editbox._text)
			editbox:SetCursorPosition(0)
			editbox.measurer:SetText(editbox._text)
			editbox._textLength = editbox.measurer:GetStringWidth()
			if data.editbox[k].icon then
				editbox.icon:SetTexture(data.editbox[k].icon)
				editbox.inset = 17
			end
			if data.editbox[k].showHint ~= nil then
				editbox.showHint = data.editbox[k].showHint
			end
			editbox.maxWidth = data.editbox[k].width or 400
			EditboxSetWidth(editbox, editbox.maxWidth)
			editbox:SetHeight(20)
			editbox:Show()
			editbox:SetTextInsets(editbox.inset, 0, 0, 0)
			frame.editboxes[k] = editbox
		end
	end

	-- Button
	if data.button then
		frame.button:SetWidth(data.buttonWidth)
		frame.button:SetPoint('BOTTOMLEFT', 8 + data.paddingX + (data.buttonLeft or 0), 28 + 18 + (data.buttonBottom or 0))
		frame.button:SetText(data.button)
		frame.button:SetScript('OnClick', data.buttonClick)
		frame.button:Show()
	else
		frame.button:Hide()
	end
	
	-- Shine
	if data.shine then
		frame.shine:SetParent(data.shine)
		frame.shine:SetPoint('BOTTOMRIGHT', data.shineRight or 0, data.shineBottom or 0)
		frame.shine:SetPoint('TOPLEFT', data.shineLeft or 0, data.shineTop or 0)
		frame.shine:Show()
		frame.flash:Play()
	else
		frame.flash:Stop()
		frame.shine:Hide()
	end
	
	-- Buttons
	if i == 1 then
		frame.prev:Disable()
	else
		frame.prev:Enable()
	end
	frame.pageNum:SetText(("%d/%d"):format(i, frame.unlocked))
	if i < (frame.unlocked or 0) then
		frame.next:Enable()
	else
		frame.next:Disable()
	end
	
	-- Save
	local sv = frame.data.key or frame.data.savedvariable
	if sv then
		local table = frame.data.key and frame.data.savedvariable or _G
		table[sv] = max(i, table[sv] or 0)
	end
end

local function NewButton(frame, name, direction)
	local button = CreateFrame('Button', nil, frame)
	button:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight')
	button:SetDisabledTexture(BUTTON_TEX:format(name, 'Disabled'))
	button:SetPushedTexture(BUTTON_TEX:format(name, 'Down'))
	button:SetNormalTexture(BUTTON_TEX:format(name, 'Up'))
	button:SetPoint('BOTTOM'..((direction == -1) and 'LEFT' or 'RIGHT'), -(30 * direction), 1)
	button:SetSize(26, 26)
	button:SetScript('OnClick', function()
		UpdateFrame(frame, frame.i + direction)
	end)

	local text = button:CreateFontString(nil, nil, 'GameFontHighlightSmall')
	text:SetText(_G[strupper(name)])
	text:SetPoint('LEFT', -(13 + text:GetStringWidth()/2) * direction, 0)

	return button
end

local function NewFrame(data)
	local frame = CreateFrame('Frame', 'Tutorials'..Lib.numFrames, UIParent, 'ButtonFrameTemplate')
	local portrait = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and frame:GetPortrait() or frame.portrait
	portrait:SetPoint('TOPLEFT', -3, 5)
	portrait:SetTexture(data.icon or 'Interface\\TutorialFrame\\UI-HELP-PORTRAIT')
	frame.Inset:SetPoint('TOPLEFT', 4, -23)
	frame.Inset.Bg:SetColorTexture(0, 0, 0)

	local template = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and "ScrollFrameTemplate" or "UIPanelScrollFrameTemplate"
	frame.scroll = CreateFrame("ScrollFrame", nil, frame, template)
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		frame.scroll.ScrollBar:SetHideIfUnscrollable(true)
	end

	frame.content = CreateFrame("Frame", nil, frame.scroll)
	frame.content:SetHeight(1)  -- for correct init height
	frame.scroll:SetScrollChild(frame.content)

	frame.images = {}
	frame.heading = frame.content:CreateFontString(nil, nil, 'GameFontNormal')
	frame.heading:SetPoint('RIGHT')
	frame.heading:SetJustifyH('LEFT')
	frame.heading:Hide()
	frame.text = frame.content:CreateFontString(nil, nil, 'GameFontHighlight')
	frame.text:SetPoint('RIGHT')
	if data.font then
		frame.text:SetFont(data.font, 12)
	end
	frame.text:SetJustifyH('LEFT')
	frame.editboxes = {}
	
	frame.prev = NewButton(frame, 'Prev', -1)
	frame.next = NewButton(frame, 'Next', 1)
	
	frame.pageNum = frame:CreateFontString(nil, nil, 'GameFontHighlightSmall')
	frame.pageNum:SetPoint('BOTTOM', 0, 9)
	
	frame:SetFrameStrata('DIALOG')
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:SetToplevel(true)
	frame:SetScript('OnHide', function()
		frame.flash:Stop()
		frame.shine:Hide()
		if frame.data.onHide then
			frame.data.onHide()
		end
	end)

	frame.button = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
	frame.button:SetSize(100, 22)
	frame.button:SetPoint("CENTER")
	frame.button:Hide()

	frame.shine = CreateFrame('Frame', nil, frame, BackdropTemplateMixin and 'BackdropTemplate')
	frame.shine:SetBackdrop({edgeFile = 'Interface\\TutorialFrame\\UI-TutorialFrame-CalloutGlow', edgeSize = 16})
	for i = 1, frame.shine:GetNumRegions() do
		select(i, frame.shine:GetRegions()):SetBlendMode('ADD')
	end

	local flash = frame.shine:CreateAnimationGroup()
	flash:SetLooping('BOUNCE')
	frame.flash = flash
	
	local anim = flash:CreateAnimation('Alpha')
	anim:SetDuration(.75)
	anim:SetFromAlpha(.7)
	anim:SetToAlpha(0)

	frame.data = data
	Lib.numFrames = Lib.numFrames + 1

	-- for update height
	hooksecurefunc(UIParent, "SetScale", function(self)
		UpdateFrame(frame, frame.i)
	end)

	return frame
end


--[[ User API ]]--

function Lib:RegisterTutorial(data)
	assert(type(data) == 'table', 'RegisterTutorials: 2nd arg must be a table', 2)
	assert(self, 'RegisterTutorials: 1st arg was not provided', 2)

	if not Lib.frames[self] then
		Lib.frames[self] = NewFrame(data)
	end
end

function Lib:TriggerTutorial(index, maxAdvance)
	assert(type(index) == 'number', 'TriggerTutorial: 2nd arg must be a number', 2)
	assert(self, 'RegisterTutorials: 1st arg was not provided', 2)

	local frame = Lib.frames[self]
	if frame then
		local sv = frame.data.key or frame.data.savedvariable
		local table = frame.data.key and frame.data.savedvariable or _G
		local last = sv and table[sv] or 0
		
		if index > last then
			frame.unlocked = index
			UpdateFrame(frame, (maxAdvance == true or not sv) and index or last + (maxAdvance or 1))
		end
	end
end

function Lib:ResetTutorial()
	assert(self, 'RegisterTutorials: 1st arg was not provided', 2)

	local frame = Lib.frames[self]
	if frame then
		local sv = frame.data.key or frame.data.savedvariable
		if sv then
			local table = frame.data.key and frame.data.savedvariable or _G
			table[sv] = false
		end
	end
end

function Lib:GetTutorial()
	return self and Lib.frames[self] and Lib.frames[self].data
end