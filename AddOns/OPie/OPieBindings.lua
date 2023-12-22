local COMPAT, _, T = select(4,GetBuildInfo()), ...
local L, EV, PC, TS, XU, config, KR = T.L, T.Evie, T.OPieCore, T.TenSettings, T.exUI, T.config, OPie.ActionBook:compatible("Kindred", 1, 0)
local MODERN = COMPAT >= 10e4

local frame = TS:CreateOptionsPanel(L"Ring Bindings", "OPie")
	frame.desc:SetText(L"Customize OPie key bindings below. Hover over a binding button for additional information and options."
		.. (MODERN and "\n" .. L"Profiles activate automatically when you switch character specializations." or ""))
local OBC_Profile = CreateFrame("Frame", "OBC_Profile", frame, "UIDropDownMenuTemplate")
	OBC_Profile:SetPoint("TOPLEFT", 0, -80) UIDropDownMenu_SetWidth(OBC_Profile, 200)
	OBC_Profile.initialize, OBC_Profile.text = OPC_Profile.initialize, OPC_Profile.text
local bindSet = CreateFrame("Frame", "OPC_BindingSet", frame, "UIDropDownMenuTemplate")
	bindSet:SetPoint("LEFT", OBC_Profile, "RIGHT")	UIDropDownMenu_SetWidth(bindSet, 250)
local bindLines, bindLines2, bindZone, bindZoneOrigin = {}, {}, CreateFrame("Frame", nil, frame) do
	bindZone:SetClipsChildren(true)
	bindZone:SetHitRectInsets(0, -22, 0, 0)
	bindZoneOrigin = CreateFrame("Frame", nil, bindZone)
	bindZoneOrigin:SetHeight(1)
	bindZoneOrigin:SetPoint("TOPLEFT")
	bindZoneOrigin:SetPoint("TOPRIGHT")
	bindZoneOrigin:Hide()
	bindZone.clipContainer, bindZone.bindingContainerFrame = bindZone, frame
	for i=1,19 do
		local bind = config.createBindingButton(bindZone, 170)
		bind:SetPoint("TOPLEFT", bindZoneOrigin, "TOPLEFT", 220, 22-24*i)
		local bind2 = config.createBindingButton(bindZone, 170)
		bind2:SetPoint("LEFT", bind, "RIGHT", 4, 0)
		local label = bind:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		label:SetPoint("TOPLEFT", bindZoneOrigin, 5, 18-24*i)
		bind.warn = bind:CreateTexture(nil, "ARTWORK")
		bind.warn:SetTexture("Interface/EncounterJournal/UI-EJ-WarningTextIcon")
		bind.warn:SetSize(14, 14)
		bind.warn:SetPoint("RIGHT", bind, "LEFT", -3, 0)
		bindLines[i], bind.label, bindLines2[i] = bind, label, bind2
	end
	bindZone:SetPoint("TOP", OBC_Profile, "BOTTOM", 0, -4)
	bindZone:SetPoint("LEFT", 15, 0)
	bindZone:SetPoint("RIGHT", -30, 0)
	bindZone:SetHeight((#bindLines-1)*24+3)
end
local bindZoneBar = XU:Create("ScrollBar", nil, frame)
	bindZoneBar:SetPoint("TOPLEFT", bindZone, "TOPRIGHT", 1, 14)
	bindZoneBar:SetPoint("BOTTOMLEFT", bindZone, "BOTTOMRIGHT", 1, -10)
	bindZoneBar:SetWindowRange(#bindLines-1)
	bindZoneBar:SetStepsPerPage(#bindLines-5)
local bindZoneCover = CreateFrame("Frame", nil, bindZone)
	bindZoneCover:SetAllPoints()
	bindZoneCover:EnableMouse(true)
	bindZoneCover:Hide()
	bindZoneCover:SetScript("OnShow", function(self)
		self:SetFrameLevel(bindLines[#bindLines]:GetFrameLevel()+10)
	end)

local ringBindings = {map={}, name=L"Ring Bindings", TwoBindingSlots=true}
function ringBindings:refresh()
	local pos, map = 1, self.map
	for key in PC:IterateRings(IsAltKeyDown()) do
		map[pos], pos = key, pos + 1
	end
	for i=#map,pos,-1 do
		map[i] = nil
	end
	self.count = #map
end
local function ringBindings_getInner(key, bidx)
	local bind, cBind, isOverride, isActiveInt, isActiveExt = PC:GetRingBinding(key, bidx)
	local showWarning, prefix, tipTitle, tipText = false
	local cebind = cBind or (bind and KR:EvaluateCmdOptions(bind))
	local BC_HEADER_PREFIX = "|TInterface/EncounterJournal/UI-EJ-WarningTextIcon:0:0:0:2|t "
	if not isOverride and not PC:GetOption("UseDefaultBindings", key) then
		if bind then
			showWarning, prefix, tipTitle = true, "|cffa0a0a0", BC_HEADER_PREFIX .. L"Default binding disabled"
			tipText = (L"Choose a binding for this ring, or enable the %s option in OPie options."):format(HIGHLIGHT_FONT_COLOR_CODE .. L"Use default ring bindings" .. "|r")
		end
	elseif cBind and isActiveExt ~= true then
		showWarning, tipTitle = true, BC_HEADER_PREFIX .. L"Binding conflict"
		if isActiveInt == false then
			prefix = isOverride and "|cfffa2800" or "|cffa0a0a0"
			tipText = L"This binding is not currently active because it conflicts with another."
		else
			prefix, tipText = "|cfffa2800", L"This binding is currently used by another addon."
		end
		if isActiveExt then
			local lab = _G["BINDING_NAME_" .. isActiveExt]
			if not (lab and type(lab) == "string" and lab:match("%S")) then lab = tostring(isActiveExt) end
			tipText = tipText .. "\n\n" .. (L"Conflicts with: %s"):format("|cffe0e0e0" .. lab .. "|r")
		end
	elseif cBind == nil and cebind and not isActiveInt then
		showWarning, tipTitle = true, BC_HEADER_PREFIX .. L"Binding conflict"
		prefix, tipText = "|cffa0a0a0", L"This binding is not currently active because it conflicts with another."
	elseif isOverride and bind ~= nil then
		prefix = "|cffffffff"
	end
	return bind, prefix, cBind, tipTitle, tipText, showWarning
end
function ringBindings:get(id)
	local name, key = PC:GetRingInfo(self.map[id])
	local text = name or key or "?"
	local bind, prefix, cBind, title, tip, warning = ringBindings_getInner(key, 1)
	local bind2, prefix2, _cBind2, title2, tip2, warning2 = ringBindings_getInner(key, 2)
	return bind, text, prefix, cBind, title, tip, warning, bind2, prefix2, title2, tip2, warning2
end
function ringBindings:set(id, key, bidx)
	id = self.map[id]
	config.undo:saveActiveProfile()
	PC:SetRingBinding(id, bidx, key)
end
function ringBindings:default()
	PC:ResetRingBindings()
end
function ringBindings:altClick() -- self is the binding button
	local id, bidx = self:GetID()
	id, bidx = id < 0 and -id or id, id < 0 and 2 or 1
	self:ToggleAlternateEditor(PC:GetRingBinding(ringBindings.map[id], bidx))
end
function ringBindings:shiftClick()
	local name, key, macro = PC:GetRingInfo(ringBindings.map[math.abs(self:GetID())])
	TS:ShowPromptOverlay(frame, name or key, (L"The following macro command opens this ring:"):format("|cffFFD029" .. (name or key) .. "|r"), false, false, nil, 0.90, nil, macro)
end

local subBindings = { name=L"In-Ring Bindings",
	options={"ScrollNestedRingUpButton", "ScrollNestedRingDownButton", "OpenNestedRingButton", "SelectedSliceBind"},
	optionNames={L"Scroll nested ring (up)", L"Scroll nested ring (down)", L"Open nested ring", L"Selected slice (keep ring open)"},
	count=0, t={},
}
function subBindings.allowWheel(btn)
	return btn:GetID() <= 2 and not subBindings.scope
end
function subBindings:refresh(scope)
	local ringName = scope and PC:GetRingInfo(scope)
	scope = ringName and scope or nil
	self.scope, self.nameSuffix = scope, scope and (" (|cffacd7e6" ..  ringName .. "|r)") or (" (" .. L"Defaults" .. ")")
	local t, ni = self.t, 1
	for s in PC:GetOption("SliceBindingString", scope):gmatch("%S+") do
		t[ni], ni = s, ni + 1
	end
	for i=#t,ni,-1 do t[i] = nil end
	subBindings.count = ni+(scope and 1 or 4)
end
function subBindings:get(id)
	local firstListSize = self.scope and 1 or 4
	if id <= firstListSize then
		id = (self.scope and 3 or 0) + id
		local value, setting = PC:GetOption(self.options[id], self.scope)
		return value, self.optionNames[id], setting and "|cffffffff" or nil
	else
		id = id - firstListSize
	end
	return self.t[id] == "false" and "" or self.t[id], (L"Slice #%d"):format(id)
end
function subBindings:set(id, bind)
	local firstListSize = self.scope and 1 or 4
	if id <= firstListSize then
		id = (self.scope and 3 or 0) + id
		config.undo:saveActiveProfile()
		PC:SetOption(self.options[id], bind == false and "" or bind, self.scope)
		return
	else
		id = id - firstListSize
	end
	if bind == nil then
		local i, s, s2 = 1, select(self.scope == nil and 5 or 4, PC:GetOption("SliceBindingString", self.scope))
		for f in (s or s2):gmatch("%S+") do
			if i == id then bind = f break end
			i = i + 1
		end
	end

	local t, bind = self.t, bind or "false"
	if bind ~= "false" then
		for i=1,#t do
			if t[i] == bind then
				t[i] = "false"
			end
		end
	end
	t[id] = bind
	for j=#t,1,-1 do if t[j] == "false" then t[j] = nil else break end end
	self.count = #t + firstListSize + 1
	local _, _, _, global, default = PC:GetOption("SliceBindingString", self.scope)
	local v = table.concat(t, " ")
	if self.scope == nil and v == default then v = nil
	elseif self.scope ~= nil and v == (global or default) then v = nil end
	config.undo:saveActiveProfile()
	PC:SetOption("SliceBindingString", v, self.scope)
end
local subBindings_List = {}
local function subBindings_ScopeClick(_, key)
	return bindSet.set(nil, subBindings, key or nil)
end
local function subBindings_ScopeFormat(key, list)
	return list[key], list[0] and (key or nil) == subBindings.scope
end
function subBindings:scopes(level, checked)
	local list = subBindings_List
	wipe(list) -- Reusing the table to maintain the scroll position key
	list[0], list[1], list[false] = checked, false, L"Defaults for all rings"
	local ct = T.OPC_RingScopePrefixes
	for key, name, scope in PC:IterateRings(true) do
		local color = ct and ct[scope] or "|cffacd7e6"
		list[#list+1], list[key] = key, (L"Ring: %s"):format(color .. (name or key) .. "|r")
	end
	XU:Create("ScrollableDropDownList", level, list, subBindings_ScopeFormat, subBindings_ScopeClick)
end
function subBindings:default()
	for i=0,#self.options do
		local on = i == 0 and "SliceBindingString" or self.options[i]
		PC:SetOption(on, nil)
		if self.scope then
			PC:SetOption(on, nil, self.scope)
		end
	end
end

local currentOwner, bindingTypes = ringBindings, {ringBindings, subBindings}
local function updatePanelContent()
	local m = currentOwner.count
	bindZoneBar:SetShown(m >= #bindLines)
	bindZoneBar:SetMinMaxValues(0, m > #bindLines and m - #bindLines + 1 or 1)
	local csv = bindZoneBar:GetValue()
	local csPartial = csv % 1
	local csBase = csv - csPartial
	bindZoneOrigin:SetPoint("TOPLEFT", 0, csPartial*24)
	for i=1,#bindLines do
		local j, e, e2 = csBase+i, bindLines[i], bindLines2[i]
		if j > m then
			e:Hide()
			e2:Hide()
		else
			local binding, text, prefix, _, title, tip, showWarningIcon, binding2, prefix2, title2, tip2, warning2 = currentOwner:get(j)
			e.bindingName, e.tooltipTitle, e.tooltipText = text, title, tip
			e.label:SetText(text)
			e.warn:SetShown(showWarningIcon or warning2)
			e:SetBindingText(binding, prefix)
			e:SetID(j) e:Hide() e:Show()
			e2:Hide()
			if currentOwner.TwoBindingSlots then
				e2.bindingName, e2.tooltipTitle, e2.tooltipText = text, title2, tip2
				e2:SetBindingText(binding2, prefix2)
				e2:SetID(-j)
				e2:Show()
				e:SetPoint("TOPLEFT", bindZoneOrigin, "TOPLEFT", 221, 22-24*i)
				e:SetWidth(170)
			else
				e:SetPoint("TOPLEFT", bindZoneOrigin, "TOPLEFT", 350, 22-24*i)
				e:SetWidth(215)
			end
		end
	end
	bindZone.OnBindingAltClick = currentOwner.altClick
	bindZone.OnBindingShiftClick = currentOwner.shiftClick
	UIDropDownMenu_SetText(bindSet, currentOwner.name .. (currentOwner.nameSuffix or ""))
end
function bindZone.SetBinding(buttonOrId, binding)
	local id, bidx = type(buttonOrId) == "number" and buttonOrId or buttonOrId:GetID()
	id, bidx = id < 0 and -id or id, id < 0 and 2 or 1
	currentOwner:set(id, binding, bidx)
	updatePanelContent()
end
bindZone:SetScript("OnMouseWheel", function(_, delta)
	bindZoneBar:Step(-delta*6, true)
	updatePanelContent()
end)
bindZoneBar:SetScript("OnValueChanged", function(self, _, userEvent)
	bindZoneCover:SetShown(not self:IsValueAtRest())
	if userEvent then
		updatePanelContent()
	end
end)

function bindSet:initialize(level)
	local info = {func=bindSet.set, minWidth=bindSet:GetWidth()-40}
	for i=1,#bindingTypes do
		local v = bindingTypes[i]
		if v.scopes then
			UIDropDownMenu_AddSeparator(level)
			info.text, info.isTitle, info.notCheckable, info.justifyH = v.name, true, true, "CENTER"
			UIDropDownMenu_AddButton(info, level)
			v:scopes(level, currentOwner == v)
		else
			info.notCheckable, info.isTitle, info.justifyH = nil
			info.text, info.arg1, info.checked = v.name, v, v == currentOwner
			UIDropDownMenu_AddButton(info, level)
		end
	end
end
function bindSet:set(owner, scope)
	currentOwner, bindZone.AllowWheelBinding = owner, owner and owner.allowWheel
	bindZoneBar:SetValue(0)
	if owner.refresh then owner:refresh(scope) end
	updatePanelContent()
	CloseDropDownMenus()
	frame.resetOnHide = nil
end

function frame.refresh()
	for _, v in pairs(bindingTypes) do
		if v.refresh then v:refresh(v.scope) end
	end
	OBC_Profile:text()
	updatePanelContent()
	config.checkSVState(frame)
end
function frame.default()
	config.undo:saveActiveProfile()
	for _, v in pairs(bindingTypes) do
		if v.default then v:default() end
	end
	frame.refresh()
end
local function resetView()
	currentOwner, frame.resetOnHide = ringBindings, nil
	bindZoneBar:SetValue(0)
	for _, v in pairs(bindingTypes) do
		v.scope = nil
	end
end
frame.okay, frame.cancel = resetView, resetView
frame:SetScript("OnShow", frame.refresh)
frame:SetScript("OnHide", function()
	if frame.resetOnHide then
		resetView()
	end
end)

T.AddSlashSuffix(function() frame:OpenPanel() end, "bind", "binding", "bindings")

function T.ShowSliceBindingPanel(ringKey)
	frame:OpenPanel()
	bindSet.set(nil, subBindings, ringKey)
	frame.resetOnHide = true
	config.pulseDropdown(bindSet)
end
function EV:OPIE_PROFILE_SWITCHED()
	if frame:IsVisible() then
		frame.refresh()
	end
end