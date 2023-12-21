local _, T = ...
local XU, ScrollBar, iSB, type = T.exUI, {}, {}, type
local assert, getWidgetData, newWidgetData, setWidgetData, AddObjectMethods, CallObjectScript = XU:GetImpl()

local HOLD_ACTION_DELAY, PAGE_DELAY, STEPPER_REPEAT_DELAY = 0.15, 0.25, 0.4
local MIN_ANIMATION_FRAMERATE, ANIMATION_TARGET_DURATION = 45, 0.2
local ScrollBarData, scrollBarProps = {}, {
	api=ScrollBar,
	scripts={"OnMinMaxChanged", "OnValueChanged"},

	val=0,
	min=0,
	max=100,
	win=10,
	step=1,
	stepsPerPage=1,
	enabled=true,
}
AddObjectMethods({"ScrollBar"}, scrollBarProps)

-- Public ScrollBar Widget API
function ScrollBar:GetValue()
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	return d.val
end
function ScrollBar:SetValue(value)
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	assert(type(value) == "number", 'Syntax: ScrollBar:SetValue(value)')
	if d.val ~= value then
		iSB.SetValue(d, value, false, true)
	end
end
function ScrollBar:GetMinMaxValues()
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	return d.min, d.max
end
function ScrollBar:SetMinMaxValues(minValue, maxValue)
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	assert(type(minValue) == 'number' and type(maxValue) == 'number', 'Syntax: ScrollBar:SetMinMaxValues(minValue, maxValue)')
	if minValue == d.min and maxValue == d.max then return end
	d.min, d.max, d.ThumbSize = minValue, maxValue < minValue and minValue or maxValue
	iSB.SetValue(d, d.val, false)
	iSB.SetInteractionState(d, "NONE")
	iSB.UpdateThumbSizeAndPosition(d)
	CallObjectScript(d.self, "OnMinMaxChanged", minValue, maxValue)
end
function ScrollBar:GetWindowRange()
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	return d.win
end
function ScrollBar:SetWindowRange(range)
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	if d.win == range then return end
	assert(type(range) == 'number' and range >= 0, 'Syntax: ScrollBar:SetWindowRange(range)')
	d.win = range
	iSB.UpdateThumbPosition(d)
	iSB.SetInteractionState(d, "NONE")
end
function ScrollBar:GetValueStep()
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	return d.step
end
function ScrollBar:SetValueStep(step)
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	assert(type(step) == "number" and step >= 0, 'Syntax: ScrollBar:SetValueStep(step)')
	d.step = step
end
function ScrollBar:GetStepsPerPage()
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	return d.stepsPerPage
end
function ScrollBar:SetStepsPerPage(steps)
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	assert(type(steps) == "number" and steps >= 1, 'Syntax: ScrollBar:SetStepsPerPage(stepsPerPage)')
	d.stepsPerPage = steps
end
function ScrollBar:GetStepperButtonsShown()
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	return d.StepUp:IsShown()
end
function ScrollBar:SetStepperButtonsShown(shown)
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	d.StepUp:SetShown(shown)
	d.StepDown:SetShown(shown)
	d.Track:SetPoint("TOP", 0, shown and -20 or -1)
	d.Track:SetPoint("BOTTOM", 0, shown and 20 or 1)
	iSB.SetInteractionState(d, "NONE")
	iSB.UpdateTrackTextures(d)
	iSB.UpdateThumbSizeAndPosition(d)
end
function ScrollBar:Step(delta, allowAnimation)
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	assert(type(delta) == "number" and (allowAnimation == nil or type(allowAnimation) == "boolean"), 'Syntax: ScrollBar:Step(delta[, allowAnimation])')
	iSB.Step(d, delta, false, allowAnimation)
end
function ScrollBar:IsValueAtRest()
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	return d.animTarget == nil and d.interactionState ~= "THUMB_DRAG"
end
function ScrollBar:IsEnabled()
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	return d.enabled
end
function ScrollBar:SetEnabled(enabled)
	local d = assert(getWidgetData(self, ScrollBarData), "Invalid object type")
	enabled = not not enabled
	if d.enabled ~= enabled then
		d.enabled = enabled
		iSB.SetInteractionState(d, "NONE")
	end
end
function ScrollBar:Enable()
	return ScrollBar.SetEnabled(self, true)
end
function ScrollBar:Disable()
	return ScrollBar.SetEnabled(self, false)
end


function iSB.NotifyValueChanged(d, isInternalChange, onlyOnRestStart)
	local isAtRest = d.animTarget == nil and d.interactionState ~= "THUMB_DRAG"
	local wasNotAtRest = onlyOnRestStart and d.lastValueChangeNotAtRest
	d.lastValueChangeNotAtRest = not isAtRest
	if not onlyOnRestStart or (wasNotAtRest and isAtRest) then
		CallObjectScript(d.self, "OnValueChanged", d.val, isInternalChange)
	end
end
function iSB.SetInteractionState(d, state)
	local val, enabled = d.val, d.enabled
	d.interactionState = state
	d.ThumbTexN:SetShown(state ~= "THUMB_DRAG")
	d.ThumbTexP:SetShown(state == "THUMB_DRAG")
	d.Thumb:EnableMouseMotion(enabled and state ~= "THUMB_DRAG")
	if d.mouseDown and state ~= "THUMB_DRAG" and state ~= "TRACK_HELD" then
		d.mouseDown, d.mouseDownX, d.mouseDownY, d.mouseDownS, d.mouseDownV, d.mouseDownOnThumb = nil
		d.Track:SetScript("OnUpdate", nil)
	end
	if d.stepperHeld == d.StepUp and state ~= "STEP_UP_HELD" or
	   d.stepperHeld == d.StepDown and state ~= "STEP_DOWN_HELD" then
		d.stepperHeldTime, d.stepperHeld = nil
	end
	d.StepUpH:SetShown(state ~= "STEP_UP_HELD")
	d.StepDownH:SetShown(state ~= "STEP_DOWN_HELD")
	d.StepUp:SetEnabled(enabled and val > d.min)
	d.StepDown:SetEnabled(enabled and val < d.max)
	if state ~= "ANIMATING_VALUE" and state ~= "STEP_UP_HELD" and state ~= "STEP_DOWN_HELD" then
		d.animStart, d.animTarget, d.animEnd, d.animDur = nil
	end
	iSB.NotifyValueChanged(d, true, true)
end
function iSB.SetValue(d, candValue, isInternalChange, visualUpdate, allowInteraction)
	local vlo, vhi, enabled = d.min, d.max, d.enabled
	local ov, nv = d.val, candValue < vlo and vlo or candValue > vhi and vhi or candValue
	d.StepUp:SetEnabled(enabled and nv > vlo)
	d.StepDown:SetEnabled(enabled and nv < vhi)
	d.val = nv
	if visualUpdate then
		iSB.UpdateThumbPosition(d)
	end
	if nv ~= ov then
		if visualUpdate and not allowInteraction then
			iSB.SetInteractionState(d, "NONE")
		end
		iSB.NotifyValueChanged(d, isInternalChange)
		return true
	end
end
function iSB.UpdateThumbPosition(d)
	local om = d.ThumbOffsetMul
	if not om then
		return iSB.UpdateThumbSizeAndPosition(d)
	end
	d.Thumb:SetPoint("TOP", 0, (d.val - d.min)*om)
end
function iSB.UpdateThumbSizeAndPosition(d)
	local vrange, urange = d.max - d.min, d.Track:GetHeight()
	d.Thumb:SetShown(vrange > 0)
	if vrange <= 0 then return end
	local tsz = math.max(18, d.win / (vrange + d.win) * urange)
	local om = (tsz-urange)/vrange
	if d.ThumbSize == tsz and d.ThumbOffsetMul == om then return end
	d.ThumbSize, d.ThumbOffsetMul = tsz, om
	d.Thumb:SetHeight(tsz)
	iSB.UpdateThumbTextures(d, tsz)
	iSB.UpdateThumbPosition(d)
end
function iSB.PerformTrackPageStep(d, isFirstStep)
	local thumb, _mouseX, mouseY = d.Thumb, GetCursorPosition()
	local dsign, delta, nv = mouseY/thumb:GetEffectiveScale() >= thumb:GetTop() and -1 or 1
	if isFirstStep or dsign == d.mouseDownS then
		d.mouseDownS, delta = dsign, (d.step > 0 and d.step or 1)*(d.stepsPerPage > 0 and d.stepsPerPage or 1)
		nv = iSB.AdjustValueToStep(d, d.val + dsign * delta, dsign)
		return iSB.SetValue(d, nv, true, true, true)
	end
end
function iSB:OnTrackUpdate()
	local d, now = getWidgetData(self, ScrollBarData), GetTime()
	if not (d.mouseDown and d.ThumbOffsetMul) then return end
	local downElapsed = now - d.mouseDown
	local doNothing = downElapsed < HOLD_ACTION_DELAY
	if doNothing and d.mouseDownOnThumb then
		local _mx, my = GetCursorPosition()
		doNothing = (my-d.mouseDownY)^2 < 5
	end
	if doNothing then
	elseif d.mouseDownOnThumb then
		local ts, _mx, my = self:GetEffectiveScale(), GetCursorPosition()
		local dm = (d.mouseDownY-my)/ts
		local nv = dm^2 > 0.5 and d.mouseDownV-dm/d.ThumbOffsetMul or d.mouseDownV
		iSB.SetValue(d, nv, true, true, true)
	elseif not iSB.IsCursorOverThumb(d) and iSB.PerformTrackPageStep(d, false) then
		d.mouseDown = GetTime() + PAGE_DELAY - HOLD_ACTION_DELAY
	end
end
function iSB:OnTrackMouseDown(button)
	local d = button == "LeftButton" and getWidgetData(self, ScrollBarData)
	if not (d.enabled and d.min < d.max) then return end
	d.mouseDown, d.mouseDownOnThumb = GetTime(), iSB.IsCursorOverThumb(d)
	d.mouseDownV, d.mouseDownX, d.mouseDownY = d.val, GetCursorPosition()
	iSB.SetInteractionState(d, d.mouseDownOnThumb and "THUMB_DRAG" or "TRACK_HELD")
	if not d.mouseDownOnThumb then
		iSB.PerformTrackPageStep(d, true)
	end
	d.Track:SetScript("OnUpdate", iSB.OnTrackUpdate)
end
function iSB:OnTrackMouseUp(button)
	local d = button == "LeftButton" and getWidgetData(self, ScrollBarData)
	if d.mouseDown then
		iSB.SetInteractionState(d, "NONE")
	end
end
function iSB:OnShow()
	local d = getWidgetData(self, ScrollBarData)
	iSB.SetInteractionState(d, "NONE")
	d.ThumbSize = nil
	iSB.UpdateThumbSizeAndPosition(d)
end
function iSB.Step(d, delta, isInternalChange, allowAnimation)
	local dsign, dstep = delta < 0 and -1 or delta > 0 and 1 or 0, d.step
	local delta, at = delta * (dstep > 0 and dstep or 1), allowAnimation and d.animTarget
	local sval = at and (delta == 0 or ((at - d.val) < 0) == (delta < 0)) and at or d.val
	local nv = iSB.AdjustValueToStep(d, sval + delta, dsign)
	if allowAnimation then
		iSB.SetValueAnimated(d, nv, isInternalChange, ANIMATION_TARGET_DURATION)
	else
		iSB.SetValue(d, nv, isInternalChange, true, true)
	end
end
function iSB.AdjustValueToStep(d, candValue, dsign)
	local dstep, lo, hi = d.step, d.min, d.max
	local fv = dstep > 0 and candValue % dstep or 0
	dsign = dsign == 0 and (fv > 0.5 and 1 or -1) or dsign
	if fv > 0 then
		candValue = candValue - fv + (fv+fv > dstep and dstep or 0)
	end
	return candValue < lo and lo or candValue > hi and hi or candValue
end
function iSB.AnimateValue(d)
	local sv, tv, et, ad, now = d.animStart, d.animTarget, d.animEnd, d.animDur, GetTime()
	if not (d and sv and tv and et and ad) then
	elseif et <= now then
		d.animStart, d.animTarget, d.animEnd, d.animDur = nil
		iSB.SetValue(d, tv, true, true, true)
	else
		local p = 1-(et-now)/ad
		p = p*p*(3-2*p)
		iSB.SetValue(d, sv + (tv-sv)*p, true, true, true)
		return true
	end
end
function iSB:OnValueAnimationUpdate()
	local d = getWidgetData(self, ScrollBarData)
	if d and not iSB.AnimateValue(d) then
		d.animStart, d.animTarget, d.animEnd, d.animDur = nil
		self:SetScript("OnUpdate", nil)
		if d.interactionState == "ANIMATING_VALUE" then
			iSB.SetInteractionState(d, "NONE")
		else
			iSB.NotifyValueChanged(d, true, true)
		end
	end
end
function iSB.SetValueAnimated(d, nv, isInternalChange, targetDuration)
	local at = d.animTarget
	if at == nv then
		return
	elseif nv == d.val then
		d.animStart, d.animDur, d.animTarget, d.animEnd = nil
		return
	elseif GetFramerate() < MIN_ANIMATION_FRAMERATE and not at then
		return iSB.SetValue(d, nv, isInternalChange, true, true)
	end
	local et, ad, sv, now = d.animEnd, d.animDur, d.val, GetTime()
	local r0, r1 = et and (at-d.animStart), nv - sv
	if et == nil or et <= now or (r0 < 0) ~= (r1 < 0) or r1 == 0 then
		d.animStart, d.animDur = at or sv, targetDuration
	else
		r0, r1 = r0 < 0 and -r0 or r0, r1 < 0 and -r1 or r1
		local p = 1-(et-now)/ad
		local s = r1*(36/144*r1-p*(1-p)*r0)
		local x1 = s > 0 and 0.5 - s^0.5/r1 or 0.25
		local p1 = x1*x1*(3-x1-x1)
		local d1 = p1*(nv-sv)/(1-p1)
		d.animStart, d.animDur = sv-d1, targetDuration/(1-x1)
	end
	d.animTarget, d.animEnd = nv, now+targetDuration
	d.Track:SetScript("OnUpdate", iSB.OnValueAnimationUpdate)
end
function iSB:OnStepButtonDown(button)
	local d = button == "LeftButton" and getWidgetData(self, ScrollBarData)
	local isUpStep = d and self == d.StepUp
	if not d or (d.val == (isUpStep and d.min or d.max)) then return end
	iSB.Step(d, isUpStep and -1 or 1, true, true)
	d.stepperHeldTime, d.stepperHeld = GetTime() + STEPPER_REPEAT_DELAY, self
	iSB.SetInteractionState(d, isUpStep and "STEP_UP_HELD" or "STEP_DOWN_HELD")
	self:SetScript("OnUpdate", iSB.OnStepButtonHeld)
	PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
end
function iSB:OnStepButtonHeld()
	local d = getWidgetData(self:GetParent(), ScrollBarData)
	if not d then
	elseif d.stepperHeld ~= self then
		self:SetScript("OnUpdate", nil)
	elseif d.stepperHeldTime < GetTime() then
		iSB.OnStepButtonDown(self, "LeftButton")
	end
end
function iSB:OnStepButtonUp(button)
	local d = button == "LeftButton" and getWidgetData(self, ScrollBarData)
	if not d then return end
	self:SetScript("OnUpdate", nil)
	if d.stepperHeld == self then
		d.stepperHeldTime, d.stepperHeld = nil
	end
	if d.interactionState == (self == d.StepUp and "STEP_UP_HELD" or "STEP_DOWN_HELD") then
		iSB.SetInteractionState(d, d.animTarget and "ANIMATING_VALUE" or "NONE")
	end
end
function iSB.IsCursorOverThumb(d)
	local l, r, t, b = d.Thumb:GetHitRectInsets()
	return d.Thumb:IsMouseOver(-t, b, l, -r)
end
function iSB.UpdateTrackTextures(d)
	local bg = d.TrackBG
	bg[1]:SetAtlas("minimal-scrollbar-track-top", true)
	bg[2]:SetAtlas("!minimal-scrollbar-track-middle", true)
	bg[3]:SetAtlas("minimal-scrollbar-track-bottom", true)
end
function iSB.UpdateThumbTextures(d, tsz)
	local n, h, p, m = d.ThumbTexN, d.ThumbTexH, d.ThumbTexP, d.ThumbTexM
	tsz = tsz or d.Thumb:GetHeight()
	local b = tsz < 32 and "minimal-scrollbar-small-thumb-bottom" or "minimal-scrollbar-thumb-bottom"
	n[1]:SetAtlas("minimal-scrollbar-thumb-top", true)
	n[2]:SetAtlas("minimal-scrollbar-thumb-middle", true)
	n[3]:SetAtlas(b, true)
	h[1]:SetAtlas("minimal-scrollbar-thumb-top-over", true)
	h[2]:SetAtlas("minimal-scrollbar-thumb-middle-over", true)
	h[3]:SetAtlas(b.."-over", true)
	p[1]:SetAtlas("minimal-scrollbar-thumb-top-down", true)
	p[2]:SetAtlas("minimal-scrollbar-thumb-middle-down", true)
	p[3]:SetAtlas(b.."-down", true)
	m:SetTexCoord(0,1, 0, tsz < 715 and tsz/715 or 1)
end
function iSB:UpdateStepButtonTextures(variant)
	local normal, hover, pushed
	if variant == "TOP" then
		normal, hover, pushed = "minimal-scrollbar-arrow-top", "minimal-scrollbar-arrow-top-over", "minimal-scrollbar-arrow-top-down"
	elseif variant == "BOTTOM" then
		normal, hover, pushed = "minimal-scrollbar-arrow-bottom", "minimal-scrollbar-arrow-bottom-over", "minimal-scrollbar-arrow-bottom-down"
	else
		error('invalid variant')
	end
	self:GetNormalTexture():SetAtlas(normal, true)
	self:GetHighlightTexture():SetAtlas(hover, true)
	self:GetPushedTexture():SetAtlas(pushed, true)
	local dt = self:GetDisabledTexture()
	dt:SetAtlas(normal, true)
	dt:SetDesaturated(true)
	dt:SetVertexColor(0.5, 0.5, 0.5)
end

local function createTexTrio(parent, layer, startGap, endGap, xShift, yShift)
	local oy, ox, a,b,c = yShift or 0, xShift or 0
	for i=1,3 do
		c, b, a = parent:CreateTexture(nil, layer, nil, i == 2 and -1 or 0), c, b
	end
	a:SetPoint("TOP", ox, oy)
	c:SetPoint("BOTTOM", ox, oy)
	if startGap then
		b:SetPoint("TOP", ox, oy - startGap)
		b:SetPoint("BOTTOM", ox, oy + (endGap or startGap))
	else
		b:SetPoint("TOPLEFT", a, "BOTTOMLEFT")
		b:SetPoint("BOTTOMRIGHT", c, "TOPRIGHT", 0, endGap and -endGap or 0)
	end
	return XU:Create("ObjectGroup", a,b,c)
end
local function createStepButton(parent, d, ...)
	local t = CreateFrame("Button", nil, parent)
	t:SetSize(16, 16)
	t:SetScript("OnMouseDown", iSB.OnStepButtonDown)
	t:SetScript("OnMouseUp", iSB.OnStepButtonUp)
	setWidgetData(t, ScrollBarData, d)
	t:SetPoint(...)
	t:SetNormalTexture('')
	t:SetHighlightTexture('')
	t:SetPushedTexture('')
	t:SetDisabledTexture('')
	local a,b,c,d = t:GetNormalTexture(), t:GetHighlightTexture(), t:GetPushedTexture(), t:GetDisabledTexture()
	b:SetBlendMode('BLEND')
	for i=1,4 do
		a:ClearAllPoints()
		a:SetPoint("CENTER")
		a:SetShown(i < 3)
		a,b,c,d=b,c,d,a
	end
	return t, b
end
local function CreateScrollBar(name, parent, outerTemplate, id)
	local f, d, t = CreateFrame("Frame", name, parent, outerTemplate, id)
	d = newWidgetData(f, ScrollBarData, scrollBarProps)
	f:SetWidth(20)
	t = CreateFrame("Frame", nil, f)
	t:SetWidth(10)
	t:SetPoint("TOP", 0, -20)
	t:SetPoint("BOTTOM", 0, 20)
	t:SetScript("OnMouseDown", iSB.OnTrackMouseDown)
	t:SetScript("OnMouseUp", iSB.OnTrackMouseUp)
	t:SetScript("OnShow", iSB.OnShow)
	t:SetScript("OnSizeChanged", iSB.OnShow)
	setWidgetData(t, ScrollBarData, d)
	t, d.Track = CreateFrame("Frame", nil, t), t
	t:SetPoint("TOP", 0, -50)
	t:SetSize(8, 20)
	t:EnableMouseMotion(true)
	d.Thumb = t
	local sp, sx = 8, 0
	d.ThumbTexN = createTexTrio(t, "BACKGROUND", sp, sp, sx)
	d.ThumbTexH = createTexTrio(t, "HIGHLIGHT", sp, sp, sx)
	d.ThumbTexP = createTexTrio(t, "BACKGROUND", sp, sp, sx)
	d.ThumbTexM = XU:Create("ObjectGroup", d.ThumbTexN[2], d.ThumbTexH[2], d.ThumbTexP[2])
	d.ThumbTexP:SetShown(false)
	local etw = (d.Track:GetWidth()-t:GetWidth())/2
	d.Thumb:SetHitRectInsets(-etw, -etw, 0, 0)
	d.StepUp, d.StepUpH = createStepButton(f, d, "TOP", 0, -2)
	d.StepDown, d.StepDownH = createStepButton(f, d, "BOTTOM", 0, 2)
	iSB.UpdateStepButtonTextures(d.StepUp, "TOP")
	iSB.UpdateStepButtonTextures(d.StepDown, "BOTTOM")
	d.TrackBG = createTexTrio(d.Track, "BACKGROUND", nil, nil, nil, 1)
	d.StepUp:GetPushedTexture():SetPoint("CENTER", 0, 2)
	d.StepDown:GetPushedTexture():SetPoint("CENTER", 0, -2)
	iSB.UpdateTrackTextures(d)
	iSB.UpdateThumbTextures(d)
	return f
end

XU:RegisterFactory("ScrollBar", CreateScrollBar)