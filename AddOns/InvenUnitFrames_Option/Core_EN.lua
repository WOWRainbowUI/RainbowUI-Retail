if GetLocale()=="zhTW" or GetLocale()=="zhCN" then return end
local IUF = InvenUnitFrames
local Option = IUF.optionFrame
Option:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
Option:RegisterEvent("ADDON_LOADED")
Option:SetScript("OnShow", nil)

local _G = _G
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local select = _G.select
local max = _G.math.max
local tinsert = _G.table.insert
local tremove = _G.table.remove
local CreateFrame = _G.CreateFrame
local LBO = LibStub("LibBlueOption-1.0")
local SM = LibStub("LibSharedMedia-3.0")
local defaultFontFile = SM.DefaultMedia.font
local defaultStatusBarTexture = "Smooth v2"

local mainMenu, unitMenu, basicMenu
local unitLink = {
	["Player"] = "player",
	["Pet"] = "pet",
	["Pet Target"] = "pettarget",
	["Target"] = "target",
	["Target of Target"] = "targettarget",
	["Target of ToT"] = "targettargettarget",
	["Focus"] = "focus",
	["Focus Target"] = "focustarget",
	["Focus ToT"] = "focustargettarget",
	["Party"] = "party",
	["Party Pet"] = "partypet",
	["Party Target"] = "partytarget",
	["Boss"] = "boss",
}

local function showDetailMenu(idx)
	if Option.selected == idx then return end
	Option.selected = idx
	Option.selectedMenu, Option.unit = nil
	Option.basicMenu:Hide()
	Option.detail:Hide()
	Option.unitMenu:Hide()
	if idx == 1 then
		-- 전체 설정창 토글
		Option.basicMenu:Show()
		if not Option.basicMenu:GetValue() then
			Option.basicMenu:SetValue(1)
		end
	elseif mainMenu[idx].name and unitLink[mainMenu[idx].name] then
		-- 유닛 설정창 토글
		Option.unit = unitLink[mainMenu[idx].name]
		Option.unitMenu:Show()
		if not Option.unitMenu:GetValue() then
			Option.unitMenu:SetValue(1)
		end
	else
		-- 일반 설정창 토글
		for i, menu in pairs(Option.detail.menus) do
			if i == idx then
				Option.selectedMenu = menu
				if menu.optionName and Option["Create"..menu.optionName.."Menu"] then
					Option["Create"..menu.optionName.."Menu"](Option, menu.options, menu.content)
					menu.optionName = nil
				end
				menu:Show()
			else
				menu:Hide()
			end
		end
		Option.detail:Show()
	end
end

local function toggleMenu(menus, idx)
	Option.selectedMenu = nil
	for i, menu in pairs(menus) do
		if i == idx then
			Option.selectedMenu = menu
			if menu.optionName and Option["Create"..menu.optionName.."Menu"] then
				Option["Create"..menu.optionName.."Menu"](Option, menu.options, menu.content)
				menu.optionName = nil
			end
			menu:Show()
		else
			menu:Hide()
		end
	end

end

local function toggleBasicMenu(idx)
	toggleMenu(Option.basicMenu.menus, idx)
end

local function toggleUnitMenu(idx)
	toggleMenu(Option.unitMenu.menus, idx)
end

mainMenu = {
	{ name = "Basic", desc = "Basic settinf for unit frame.", func = showDetailMenu, needMenu = true },
	{ name = "Color", desc = "Defind colors for unit frame.", func = showDetailMenu, option = "Color" },
	{ name = "Player", desc = "Setting for player frame.", func = showDetailMenu, needMenu = true },
	{ name = "Pet", desc = "Setting for pet frame.", func = showDetailMenu, needMenu = true },
	{ name = "Pet Target", desc = "Setting for pet target frame.", func = showDetailMenu, needMenu = true },
	{ name = "Target", desc = "Setting for target frame.", func = showDetailMenu, needMenu = true },
	{ name = "Target of Target", desc = "Setting for target of target frame.", func = showDetailMenu, needMenu = true },
	{ name = "Target of ToT", desc = "Setting for target of target of target frame.", func = showDetailMenu, needMenu = true },
	{ name = "Focus", desc = "Setting for focus frame.", func = showDetailMenu, needMenu = true },
	{ name = "Focus Target", desc = "Setting for target of focus frame.", func = showDetailMenu, needMenu = true },
	{ name = "Focus ToT", desc = "Setting for target of target of focus frame.", func = showDetailMenu, needMenu = true },
	{ name = "Party", desc = "Setting for party frame.", func = showDetailMenu, needMenu = true },
	{ name = "Party Pet", desc = "Setting for party pet frame.", func = showDetailMenu, needMenu = true },
	{ name = "Party Target", desc = "Setting for party target frame.", func = showDetailMenu, needMenu = true },
	{ name = "Boss", desc = "Setting for boss frame.", func = showDetailMenu, needMenu = true },
	{ name = "Dispellable debuff", desc = "Highlight frame when dispellable debuff applied.", func = showDetailMenu, option = "Dispel" },
	{ name = "Heal prediction", desc = "Display heal prediction on healthbar.", func = showDetailMenu, option = "Heal" },
	{ name = "Class bar", desc = "Display class powerbar at bottom.", func = showDetailMenu, option = "ClassBar" },
}

basicMenu = {
	{ name = "Basic setting", func = toggleBasicMenu, option = "Basic" },
	{ name = "Profile", func = toggleBasicMenu, option = "Profile" },
	{ name = "Texture", func = toggleBasicMenu, option = "BasicStatusBar" },
	{ name = "Font", func = toggleBasicMenu, option = "BasicFont" },
	{ name = "Focus Key", func = toggleBasicMenu, option = "FocusKey" },
}

unitMenu = {
	{ name = "  Basic  ", func = toggleUnitMenu, option = "UnitBasic" },
	{ name = "  Health bar  ", func = toggleUnitMenu, option = "UnitHealth" },
	{ name = "  Health text  ", func = toggleUnitMenu, option = "UnitHealthText" },
	{ name = "  Power bar  ", func = toggleUnitMenu, option = "UnitMana" },
	{ name = "  Power text  ", func = toggleUnitMenu, option = "UnitManaText" },
	{ name = "  Cast bar  ", func = toggleUnitMenu, option = "UnitCastingBar" },
	{ name = "  Buff  ", func = toggleUnitMenu, option = "UnitBuff" },
	{ name = "  Debuff  ", func = toggleUnitMenu, option = "UnitDebuff" },
	{ name = "  Text  ", func = toggleUnitMenu, option = "UnitText" },
}

local partyUnitList = { party = {}, partypet = {}, partytarget = {}, boss = {} }
for i = 1, MAX_PARTY_MEMBERS do
	table.insert(partyUnitList.party, "party"..i)
	table.insert(partyUnitList.partypet, "partypet"..i)
	table.insert(partyUnitList.partytarget, "party"..i.."target")
end
for i = 1, MAX_BOSS_FRAMES do
	table.insert(partyUnitList.boss, "boss"..i)
end

local unitsdb = {
	player = IUF.units.player.db,
	pet = IUF.units.pet.db,
	pettarget = IUF.units.pettarget.db,
	target = IUF.units.target.db,
	targettarget = IUF.units.targettarget.db,
	targettargettarget = IUF.units.targettargettarget.db,
	focus = IUF.units.focus.db,
	focustarget = IUF.units.focustarget.db,
	focustargettarget = IUF.units.focustargettarget.db,
	party = IUF.units.party1.db,
	partypet = IUF.units.partypet1.db,
	partytarget = IUF.units.party1target.db,
	boss = IUF.units.boss1.db,
}
local barTextTypes = {
	"None", "[%]", "[Health]/[Max]", "[Health]/[Max]",
	"[Health]/[Max] [%]", "[Short Health]/[Short Max] [%]",
	"[%] [Health]/[Max]", "[%] [Short Health]/[Short Max]",
	"[Loss]", "[Short Loss]", "[Health]", "[Short Health]", "[Max]","[Short Max]",
	"[Health Number]/[Max Number]", "[Health Number]/[Max Number] [%]",
	"[%] [Health Number]/[Max Number]", "[Health Number]", "[Max Number]",
}
local barTextList = { "LEFT", "CENTER", "RIGHT", "LEFT OUT", "RIGHT OUT" }
local fontAttribute = { "NONE", "OUTLINE", "THICKOUTLINE", "MONOCHROME", "OUTLINE,MONOCHROME", "THICKOUTLINE,MONOCHROME" }
local fontAttributeSet = {
	["OUTLINE"] = "OUTLINE",
	["OUTLINE"] = "OUTLINE",
	["THICKOUTLINE"] = "THICKOUTLINE",
	["THICKOUTLINE"] = "THICKOUTLINE",
	["MONOCHROME"] = "MONOCHROME",
	["MONOCHROME"] = "MONOCHROME",
	["OUTLINE,MONOCHROME"] = "OUTLINE,MONOCHROME",
	["OUTLINE,MONOCHROME"] = "OUTLINE,MONOCHROME",
	["THICKOUTLINE,MONOCHROME"] = "THICKOUTLINE,MONOCHROME",
	["THICKOUTLINE,MONOCHROME"] = "THICKOUTLINE,MONOCHROME",
}
local auraFiltering = {
	[1] = "",	[""] = 1,
	[2] = "PLAYER",	["PLAYER"] = 2,
	[3] = "RAID",	["RAID"] = 3,
}
local buffFilteringList = { "Show all", "My cast", "Able to cast" }
local debuffFilteringList = { "Show all", "My cast", "Dispellable" }
local auraPositionList = { "TOP", "BOTTOM", "LEFT", "RIGHT" }
local auraPositions = {
	[1] = "TOP",	TOP = 1,
	[2] = "BOTTOM",	BOTTOM = 2,
	[3] = "LEFT",	LEFT = 3,
	[4] = "RIGHT",	RIGHT = 4,
}

function Option:ADDON_LOADED()
	self:UnregisterEvent("ADDON_LOADED")
	self:SetScript("OnHide", function() IUF:CollectGarbage() end)
	-- 타이틀 만들기
	self.title = self:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	self.title:SetPoint("TOPLEFT", 10, -10)
	self.title:SetText(self.name)
	self.version = self:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	self.version:SetPoint("LEFT", self.title, "RIGHT", 2, 0)
	self.version:SetText("v"..IUF.version)
	-- 세부 메뉴의 유효성 검사
	local function menuCheck(menu)
		for p, v in pairs(menu) do
			if v.option and type(Option["Create"..v.option.."Menu"]) ~= "function" then
				tremove(menu, p)
				menuCheck(menu)
				break
			end
		end
	end
	menuCheck(mainMenu)
	menuCheck(basicMenu)
	menuCheck(unitMenu)
	-- 메인 메뉴 만들기
	self.mainMenu = LBO:CreateWidget("Menu", self, mainMenu)
	self.mainMenu:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", 0, -5)
	self.mainMenu:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 10, 10)
	self.mainMenu:SetWidth(140)
	-- 세부 메뉴 생성
	self.detail = CreateFrame("Frame", nil, self, BackdropTemplateMixin and "BackdropTemplate")
	self.detail:Hide()
	self.detail:SetBackdrop(self.mainMenu:GetBackdrop())
	self.detail:SetBackdropBorderColor(0.6, 0.6, 0.6)
	self.detail:SetPoint("TOPLEFT", self.mainMenu, "TOPRIGHT", 3, 0)
	self.detail:SetPoint("BOTTOMRIGHT", -10, 10)
	self.detail.menus = {}
	for i = 1, #mainMenu do
		if not mainMenu[i].needMenu then
			self.detail.menus[i] = LBO:CreateWidget("ScrollFrame", self.detail)
			self.detail.menus[i]:Hide()
			self.detail.menus[i]:SetPoint("TOPLEFT", 5, -5)
			self.detail.menus[i]:SetPoint("BOTTOMRIGHT", -5, 5)
			self.detail.menus[i]:SetID(i)
			self.detail.menus[i].name = mainMenu[i].name
			self.detail.menus[i].optionName = mainMenu[i].option
			self.detail.menus[i].options = {}
		end
	end
	-- 전체 메뉴 만들기
	self.basicMenu, self.basicDetail = self:CreateTabMenu("basic", basicMenu)
	-- 유닛 메뉴 만들기
	self.unitMenu, self.unitDetail = self:CreateTabMenu("unit", unitMenu)
	-- 미리보기 버튼 만들기
	self.previewButton = LBO:CreateWidget("Button", self, IUF.previewMode and "Close preview" or "Open preview", "Toggle preview.", nil, nil, true,
		function(_, mode)
			IUF:SetPreviewMode(mode)
		end,
	nil, not IUF.previewMode)
	self.previewButton:SetWidth(100)
	self.previewButton:SetPoint("BOTTOMRIGHT", self.detail, "TOPRIGHT", 0, -10)
	-- 초기 메뉴 열기
	self.mainMenu:SetValue(1)
end

function Option:CreateTabMenu(name, menuTable)
	local m = LBO:CreateWidget("Tab", self, menuTable)
	m:Hide()
	m:SetPoint("TOPLEFT", self.mainMenu, "TOPRIGHT", 3, 5)
	m:SetPoint("TOPRIGHT", self, "TOPRIGHT", -10, -10)
	m.menus = {}
	local d = CreateFrame("Frame", nil, m, BackdropTemplateMixin and "BackdropTemplate")
	d:SetBackdrop(self.mainMenu:GetBackdrop())
	d:SetBackdropBorderColor(0.6, 0.6, 0.6)
	d:SetPoint("TOPLEFT", m, "BOTTOMLEFT", 0, 5)
	d:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -10, 10)
	for i = 1, #menuTable do
		m.menus[i] = LBO:CreateWidget("ScrollFrame", d)
		m.menus[i]:Hide()
		m.menus[i]:SetPoint("TOPLEFT", 5, -5)
		m.menus[i]:SetPoint("BOTTOMRIGHT", -5, 5)
		m.menus[i]:SetID(i)
		m.menus[i].name = menuTable[i].name
		m.menus[i].optionName = menuTable[i].option
		m.menus[i].options = {}
	end
	return m, d
end

function Option:Message(msg)
	if type(msg) == "string" and msg:len() > 1 then
		ChatFrame1:AddMessage("|cffffff00IUF:|r "..msg:trim(), 1, 1, 1)
	end
end

local function setCoreValueObject(object, method, ...)
	IUF[method](IUF, object, ...)
	if object.preview then
		IUF[method](IUF, object.preview, ...)
	end
end

local function setCoreValue(objectType, method, ...)
	if partyUnitList[objectType] then
		for i = 1, #partyUnitList[objectType] do
			if IUF.units[partyUnitList[objectType][i]] then
				setCoreValueObject(IUF.units[partyUnitList[objectType][i]], method, ...)
			end
		end
	elseif IUF.units[objectType] then
		setCoreValueObject(IUF.units[objectType], method, ...)
	end
end

local function setObjectValueObject(object, method, ...)
	if type(object[method]) == "function" then
		object[method](object, ...)
	else
		object[method] = ...
	end
	if object.preview then
		if type(object.preview[method]) == "function" then
			object.preview[method](object.preview, ...)
		else
			object.preview[method] = ...
		end
	end
end

local function setObjectValue(objectType, method, ...)
	if partyUnitList[objectType] then
		for i = 1, #partyUnitList[objectType] do
			if IUF.units[partyUnitList[objectType][i]] then
				setObjectValueObject(IUF.units[partyUnitList[objectType][i]], method, ...)
			end
		end
	elseif IUF.units[objectType] then
		setObjectValueObject(IUF.units[objectType], method, ...)
	end
end

local function setObjectElementValueObject(object, element, method, ...)
	if object[element] then
		if type(object[element][method]) == "function" then
			object[element][method](object[element], ...)
		else
			object[element][method] = ...
		end
	end
	if object.preview and object.preview[element] then
		if type(object.preview[element][method]) == "function" then
			object.preview[element][method](object.preview[element], ...)
		else
			object.preview[element][method] = ...
		end
	end
end

local function setObjectElementValue(objectType, element, method, ...)
	if partyUnitList[objectType] then
		for i = 1, #partyUnitList[objectType] do
			if IUF.units[partyUnitList[objectType][i]] then
				setObjectElementValueObject(IUF.units[partyUnitList[objectType][i]], element, method, ...)
			end
		end
	elseif IUF.units[objectType] then
		setObjectElementValueObject(IUF.units[objectType], element, method, ...)
	end
end

local function setObjectHandlerUpdate(objectType, handler, ...)
	if IUF.handlers[handler] then
		if partyUnitList[objectType] then
			for i = 1, #partyUnitList[objectType] do
				if IUF.units[partyUnitList[objectType][i]] and not IUF.units[partyUnitList[objectType][i]].needAutoUpdate then
					IUF.handlers[handler](IUF.units[partyUnitList[objectType][i]], ...)
				end
			end
		elseif IUF.units[objectType] and not IUF.units[objectType].needAutoUpdate then
			IUF.handlers[handler](IUF.units[objectType], ...)
		end
	end
end

local function updateElementSkin(objectType, element)
	if partyUnitList[objectType] then
		for i = 1, #partyUnitList[objectType] do
			if IUF.units[partyUnitList[objectType][i]] then
				IUF:SetObjectElementSkin(IUF.units[partyUnitList[objectType][i]], element)
				if IUF.units[partyUnitList[objectType][i]].preview then
					IUF:SetObjectElementSkin(IUF.units[partyUnitList[objectType][i]].preview, element)
				end
			end
		end
	elseif IUF.units[objectType] then
		IUF:SetObjectElementSkin(IUF.units[objectType], element)
		if IUF.units[objectType].preview then
			IUF:SetObjectElementSkin(IUF.units[objectType].preview, element)
		end
	end
end

local function updateFontStringObject(object, element)
	if object[element] then
		IUF:SetFontString(object[element], object.db[element.."FontFile"], object.db[element.."FontSize"], object.db[element.."FontAttribute"], object.db[element.."FontShadow"])
	end
	if object.preview and object.preview[element] then
		IUF:SetFontString(object.preview[element], object.db[element.."FontFile"], object.db[element.."FontSize"], object.db[element.."FontAttribute"], object.db[element.."FontShadow"])
	end
end

local function updateFontString(objectType, element)
	if partyUnitList[objectType] then
		for i = 1, #partyUnitList[objectType] do
			if IUF.units[partyUnitList[objectType][i]] then
				updateFontStringObject(IUF.units[partyUnitList[objectType][i]], element)
			end
		end
	elseif IUF.units[objectType] then
		updateFontStringObject(IUF.units[objectType], element)
	end
end

local function notActiveParentObject()
	if Option.unit then
		Option.parentUnit = IUF.units[partyUnitList[Option.unit] and partyUnitList[Option.unit][1] or Option.unit].parent
		if Option.parentUnit then
			return not IUF.db.units[IUF.units[Option.parentUnit].objectType].active
		end
	end
	return nil
end

local function notActiveObject()
	if Option.unit then
		if IUF.db.units[Option.unit].active then
			Option.parentUnit = IUF.units[partyUnitList[Option.unit] and partyUnitList[Option.unit][1] or Option.unit].parent
			if Option.parentUnit then
				return not IUF.db.units[IUF.units[Option.parentUnit].objectType].active
			else
				return nil
			end
		else
			return true
		end
		return not IUF.db.units[Option.unit].active
	else
		return true
	end
end

local most, mvalue, mcount = {}

local function getMostOptionValue(...)
	for i = 1, select("#", ...) do
		mcount = select(i, ...)
		for unit, db in pairs(unitsdb) do
			mvalue = db[mcount] or false
			most[mvalue] = (most[mvalue] or 0) + 1
		end
	end
	mcount, mvalue = 0
	for p, v in pairs(most) do
		if v > mcount then
			mvalue, mcount = p, v
		end
		most[p] = nil
	end
	return mvalue, mcount
end

function Option:CreateBasicMenu(menu, parent)
	menu.skin = LBO:CreateWidget("DropDown", parent, "Skin", "Choose frame skins.", nil, nil, true,
		function() return IUF.db.skinName, IUF.skinDB.list end,
		function(v)
			v = IUF.skinDB.name[v]
			if v and IUF.db.skin ~= v then
				Option:SetSkin(v)
				LBO:Refresh()
			end
		end
	)
	menu.skin:SetPoint("TOPLEFT", 5, -5)
	menu.skin.button:SetScript("PreClick", function()
		IUF:LoadAllSkinAddOns()
		sort(IUF.skinDB.list, function(a, b)
			if a:find("^Default") then
				if b:find("^Default") then
					return a < b
				else
					return true
				end
			elseif b:find("^Default") then
				return false
			else
				return a < b
			end
		end)
	end)
	menu.tooltip = LBO:CreateWidget("DropDown", parent, "Tooltip", "Setting for tooltip display.", nil, nil, nil, function() return IUF.db.tooltip, { "Always", "Not in combat", "In combat", "None" } end, function(v) IUF.db.tooltip = v end)
	menu.tooltip:SetPoint("TOPRIGHT", -5, -5)
	menu.lock = LBO:CreateWidget("CheckBox", parent, "Lock frame", "Lock frame disable drag to move. Focus frame still movale by Alt+Drag.", nil, nil, nil, function() return IUF.db.lock end, function(v) IUF.db.lock = v end)
	menu.lock:SetPoint("TOP", menu.skin, "BOTTOM", 0, -10)
	menu.highlight = LBO:CreateWidget("Slider", parent, "Highlight alpha", "Set highlight opacity. Set this value to 0 to hide.", nil, nil, nil,
		function() return IUF.db.highlightAlpha * 100, 0, 100, 1, "%" end,
		function(v)
			IUF.db.highlightAlpha = v / 100
			for _, object in pairs(IUF.units) do
				if not object.needElement then
					object.highlight:SetAlpha(IUF.db.highlightAlpha)
				end
				if object.preview then
					object.preview.highlight:SetAlpha(IUF.db.highlightAlpha)
				end
			end
		end
	)
	menu.highlight:SetPoint("TOP", menu.tooltip, "BOTTOM", 0, -10)
	menu.reset = LBO:CreateWidget("Button", parent, "Reset all", "Reset all unit frame detail setting.", nil, nil, true,
		function()
			Option:ClearSetting()
			LBO:Refresh()
		end
	)
	menu.reset:SetPoint("TOP", menu.lock, "BOTTOM", 0, 0)
	menu.resetLoc = LBO:CreateWidget("Button", parent, "Reset position", "Reset all unit frame position.", nil, nil, true,
		function()
			Option:ClearLocation()
		end
	)
	menu.resetLoc:SetPoint("TOP", menu.highlight, "BOTTOM", 0, 0)
	menu.scale = LBO:CreateWidget("Slider", parent, "All size", "Size for all unit frames.", nil, nil, true,
		function() return IUF.db.scale * 100, 50, 150, 1, "%" end,
		function(v)
			IUF.db.scale = v / 100
			IUF:SetScale(IUF.db.scale)
		end
	)
	menu.scale:SetPoint("TOP", menu.reset, "BOTTOM", 0, 0)
	menu.mapButtonShown = LBO:CreateWidget("CheckBox", parent, "Show minimap button", "Toggle minimap button.", nil, nil, nil,
		function() return InvenUnitFramesDB.minimapButton.show end,
		function(v)
			InvenUnitFramesDB.minimapButton.show = v
			if v then
				InvenUnitFramesMapButton:Show()
			else
				InvenUnitFramesMapButton:Hide()
			end
			LBO:Refresh()
		end
	)
	menu.mapButtonShown:SetPoint("TOP", menu.scale, "BOTTOM", 0, 0)
	menu.mapButtonDrag = LBO:CreateWidget("CheckBox", parent, "Lock minimap button", "Lock minimap button.", nil,
		function() return not InvenUnitFramesDB.minimapButton.show end, nil,
		function() return not InvenUnitFramesDB.minimapButton.dragable end,
		function(v)
			InvenUnitFramesDB.minimapButton.dragable = not v
		end
	)
	menu.mapButtonDrag:SetPoint("TOP", menu.resetLoc, "BOTTOM", 0, -44)

	menu.hideInRaid = LBO:CreateWidget("CheckBox", parent, "Hide in raid", "Hide party from when player in raid group.", nil , nil, true,
		function() return IUF.db.hideInRaid end,
		function(v)
			IUF.db.hideInRaid = v
			setCoreValue("party", "SetActiveObject")
		end
	)
	menu.hideInRaid:SetPoint("TOP", menu.mapButtonShown, "BOTTOM", 0, 0)

	menu.hidePartyFrame = LBO:CreateWidget("CheckBox", parent, "Always hide party frame", "Always hide party frame.", nil , nil, true,
		function() return IUF.db.hidePartyFrame end,
		function(v)
			IUF.db.hidePartyFrame = v
			setCoreValue("party", "SetActiveObject")
		end
	)
	menu.hidePartyFrame:SetPoint("TOP", menu.hideInRaid, "BOTTOM", 0, 0)

	local aggroBorderList = { "Display", "Blink", "None" }

	menu.aggorBorder = LBO:CreateWidget("DropDown", parent, "Threat border", "Set red border in portrait when player get target threat.", nil, nil, nil,
		function() return IUF.db.aggroBorder, aggroBorderList end,
		function(v)
			IUF.db.aggroBorder = v
			IUF:UnregisterAllFlash()
			for _, object in pairs(IUF.units) do
				if not object.needElement then
					IUF.callbacks.Aggro(object)
				end
			end
		end
	)
	menu.aggorBorder:SetPoint("TOP", menu.hidePartyFrame, "BOTTOM", 0, 0)
end

function Option:CreateProfileMenu(menu, parent)
	local profiles = {}
	local function sortfunc(a, b)
		if a == "Default" then
			return true
		elseif b == "Default" then
			return false
		else
			return a < b
		end
	end
	local function returnProfiles()
		for p in pairs(profiles) do
			profiles[p] = nil
		end
		for key in pairs(InvenUnitFramesDB.profiles) do
			tinsert(profiles, key)
		end
		sort(profiles, sortfunc)
		return profiles
	end
	menu.select = LBO:CreateWidget("DropDown", parent, "Profile", "Select profile.", nil, nil, true,
		function() return InvenUnitFramesDB.profile[IUF.dbKey], returnProfiles() end,
		function(v)
			if InvenUnitFramesDB.profile[IUF.dbKey] ~= v then
				Option:Message(("Profile changed to %s"):format(v))
				IUF:SelectProfile(v)
				LBO:Refresh()
			end
		end
	)
	menu.select:SetPoint("TOPLEFT", 5, -5)
	menu.reset = LBO:CreateWidget("Button", parent, "Reset profile", "Reset current profile.", nil, nil, true, function() IUF:ResetProfile(InvenUnitFramesDB.profile[IUF.dbKey]) end)
	menu.reset:SetPoint("TOPRIGHT", -5, -5)
	menu.copyTargetProfile = "Default"
	menu.copyTarget = LBO:CreateWidget("DropDown", parent, nil, "Create new profile.", nil, nil, true,
		function() return menu.copyTargetProfile, returnProfiles() end,
		function(v)
			menu.copyTargetProfile = v
		end
	)
	menu.copyTarget:SetWidth(130)
	menu.copyTarget:SetPoint("TOPRIGHT", menu.reset, "BOTTOMRIGHT", 0, 0)
	menu.copy = LBO:CreateWidget("EditBox", parent, "Create new profile", "Create new profile.", nil, nil, true, nil,
		function(v)
			if v and v:len() > 0 then
				if InvenUnitFramesDB.profiles[v] then
					Option:Message(("Profile %s is already exists."):format(v))
				else
					IUF:CreateNewProfile(v, menu.copyTargetProfile)
					Option:Message(("New profile created : %s"):format(v))
					LBO:Refresh()
				end
			end
		end
	)
	menu.copy:SetWidth(0)
	menu.copy:SetPoint("TOPLEFT", menu.select, "BOTTOMLEFT", 0, -8)
	menu.copy:SetPoint("RIGHT", menu.copyTarget, "LEFT", 0, 0)
	local delprofiles = {}
	local function returnDeletableProfiles()
		for p in pairs(delprofiles) do
			delprofiles[p] = nil
		end
		for key in pairs(InvenUnitFramesDB.profiles) do
			if key ~= "Default" then
				tinsert(delprofiles, key)
			end
		end
		sort(delprofiles, sortfunc)
		return delprofiles
	end
	menu.delete = LBO:CreateWidget("DropDown", parent, "Delete profile", "Delete selected profile.", nil, function() return #(returnDeletableProfiles()) == 0 end, true,
		function() return "", returnDeletableProfiles() end,
		function(v)
			IUF:DeleteProfile(v)
			Option:Message(("Profile deleted : %s"):format(v))
			if v == copyTarget then
				copyTarget = "Default"
			end
			LBO:Refresh()
		end
	)
	menu.delete:SetPoint("TOPLEFT", menu.copy, "BOTTOMLEFT", 0, 0)
end

function Option:CreateBasicStatusBarMenu(menu, parent)
	menu.barAll = LBO:CreateWidget("Media", parent, "All bars", "Change all unit frame bars.", nil, nil, nil,
		function()
			return getMostOptionValue("healthBarTexture", "powerBarTexture", "castingBarTexture") or "Smooth v2", "statusbar"
		end,
		function(v)
			local f = SM:Fetch("statusbar", v)
			for unit in pairs(IUF.db.units) do
				unitsdb[unit].healthBarTexture = v
				unitsdb[unit].powerBarTexture = v
				unitsdb[unit].castingBarTexture = v
				setObjectElementValue(unit, "healthBar", "SetTexture", f)
				setObjectElementValue(unit, "powerBar", "SetTexture", f)
				updateElementSkin(unit, "castingBar")
				setCoreValue(unit, "TriggerCallback", "CastingBar")
			end
			IUF.db.classBar.texture = v
			if IUF.ClassBarSetup then
				IUF:ClassBarSetup(IUF.units.player)
			end
			LBO:Refresh()
		end
	)
	menu.barAll:SetPoint("TOPLEFT", 5, -5)
	menu.barHealth = LBO:CreateWidget("Media", parent, "All health bar", "Change health bar for all unit frames.", nil, nil, nil,
		function()
			return getMostOptionValue("healthBarTexture") or "Smooth v2", "statusbar"
		end,
		function(v)
			local f = SM:Fetch("statusbar", v)
			for unit in pairs(IUF.db.units) do
				unitsdb[unit].healthBarTexture = v
				setObjectElementValue(unit, "healthBar", "SetTexture", f)
			end
			LBO:Refresh()
		end
	)
	menu.barHealth:SetPoint("TOPRIGHT", -5, -5)
	menu.barPower = LBO:CreateWidget("Media", parent, "All power bar", "Change power bar for all unit frames", nil, nil, nil,
		function()
			return getMostOptionValue("powerBarTexture") or "Smooth v2", "statusbar"
		end,
		function(v)
			local f = SM:Fetch("statusbar", v)
			for unit in pairs(IUF.db.units) do
				unitsdb[unit].powerBarTexture = v
				setObjectElementValue(unit, "powerBar", "SetTexture", f)
			end
			IUF.db.classBar.texture = v
			if IUF.ClassBarSetup then
				IUF:ClassBarSetup(IUF.units.player)
			end
			LBO:Refresh()
		end
	)
	menu.barPower:SetPoint("TOP", menu.barAll, "BOTTOM", 0, -5)
	menu.barCasting = LBO:CreateWidget("Media", parent, "all cast bar", "Change cast bar for all unit frames.", nil, nil, nil,
		function()
			return getMostOptionValue("castingBarTexture") or "Smooth v2", "statusbar"
		end,
		function(v)
			for unit in pairs(IUF.db.units) do
				unitsdb[unit].castingBarTexture = v
				updateElementSkin(unit, "castingBar")
				setCoreValue(unit, "TriggerCallback", "CastingBar")
			end
			LBO:Refresh()
		end
	)
	menu.barCasting:SetPoint("TOP", menu.barHealth, "BOTTOM", 0, -5)
	menu.classColor = LBO:CreateWidget("CheckBox", parent, "Class color", "Use class color for health bar.", nil, nil, nil,
		function()
			return getMostOptionValue("healthBarClassColor")
		end,
		function(v)
			for unit in pairs(IUF.db.units) do
				unitsdb[unit].healthBarClassColor = v
				for _, object in pairs(IUF.units) do
					if not object.needElement then
						object.healthBar.classColor = v
						IUF.callbacks.HealthColor(object)
					end
				end
			end
			LBO:Refresh()
		end
	)
	menu.classColor:SetPoint("TOP", menu.barPower, "BOTTOM", 0, 0)
	menu.classColorEnemy = LBO:CreateWidget("CheckBox", parent, "Use class color for harm players", "Use class color for harm players.", nil,
		function()
			return not getMostOptionValue("healthBarClassColor")
		end, nil,
		function()
			return IUF.db.useEnemyClassColor
		end,
		function(v)
			IUF.db.useEnemyClassColor = v
			for unit in pairs(unitsdb) do
				setCoreValue(unit, "TriggerCallback", "HealthColor")
			end
		end
	)
	menu.classColorEnemy:SetPoint("TOP", menu.classColor, "BOTTOM", 0, 15)

	menu.barAnimation = LBO:CreateWidget("CheckBox", parent, "Use bar animation", "Use smooth display for bar animation.", nil, nil, nil,
		function()
			return IUF.db.barAnimation
		end,
		function(v)
			IUF.db.barAnimation = v
		end
	)
	menu.barAnimation:SetPoint("TOP", menu.barCasting, "BOTTOM", 0, 0)
end

function Option:CreateBasicFontMenu(menu, parent)
	self.fontElements = { castingBarText = true, castingBarTime = true }
	local function addFontObject(tbl)
		for p in pairs(tbl) do
			if type(p) == "string" and p:find("(.+)FontFile$") then
				Option.fontElements[p:gsub("FontFile$", "")] = true
			end
		end
	end
	addFontObject(IUF.overrideSkin)
	for _, db in pairs(IUF.overrideUnitSkin) do
		addFontObject(db)
	end
	self.fontFiles, self.fontAttributes, self.fontShadows = {}, {}, {}
	for p in pairs(self.fontElements) do
		tinsert(self.fontFiles, p.."FontFile")
		tinsert(self.fontAttributes, p.."FontAttribute")
		tinsert(self.fontShadows, p.."FontShadow")
	end
	local textFontList = { "Name", "Level", "Status", "Cast", "Health", "Power" }
	local textFontElement = {
		["Name"] = { "nameText" },
		["Level"] = { "levelText" },
		["Status"] = { "stateText" },
		["Cast"] = { "castingBarText", "castingBarTime" },
		["Health"] = { "healthText1", "healthText2", "healthText3", "healthText4", "healthText5" },
		["Power"] = { "powerText1", "powerText2", "powerText3", "powerText4", "powerText5" },
	}
	local textFontFiles, textFontAttributes, textFontShadows, textFontHeights = {}, {}, {}, {}
	for p, t in pairs(textFontElement) do
		textFontFiles[p], textFontAttributes[p], textFontShadows[p], textFontHeights[p] = {}, {}, {}, {}
		for i, v in pairs(t) do
			tinsert(textFontFiles[p], v.."FontFile")
			tinsert(textFontAttributes[p], v.."FontAttribute")
			tinsert(textFontShadows[p], v.."FontShadow")
			tinsert(textFontHeights[p], v.."FontHeight")
		end
	end
	local function getFontValue(name)
		if name then
			return getMostOptionValue(unpack(textFontFiles[name])), nil, getMostOptionValue(unpack(textFontAttributes[name])), getMostOptionValue(unpack(textFontShadows[name])), true
		else
			return getMostOptionValue(unpack(Option.fontFiles)), nil, getMostOptionValue(unpack(Option.fontAttributes)), getMostOptionValue(unpack(Option.fontShadows)), true
		end
	end
	local function updateFontValue(element, file, attribute, shadow)
		for unit, db in pairs(unitsdb) do
			db[element.."FontFile"] = file
			db[element.."FontAttribute"] = attribute
			db[element.."FontShadow"] = shadow
			if element == "castingBarText" or element == "castingBarTime" then
				updateElementSkin(unit, "castingBar")
				setCoreValue(unit, "TriggerCallback", "CastingBar")
			else
				updateElementSkin(unit, element)
			end
		end
	end
	menu.fontAll = LBO:CreateWidget("Font", parent, "All font", "Change font for all unti frames.", nil, nil, nil, getFontValue,
		function(file, _, attribute, shadow)
			for element in pairs(Option.fontElements) do
				updateFontValue(element, file, attribute, shadow)
			end
		end
	)
	menu.fontAll:SetPoint("TOPLEFT", 5, -5)
	local function setFontValue(file, _, attribute, shadow, name)
		for _, element in pairs(textFontElement[name]) do
			for unit, db in pairs(unitsdb) do
				updateFontValue(element, file, attribute, shadow)
			end
		end
	end
	for i, name in ipairs(textFontList) do
		menu["font"..i] = LBO:CreateWidget("Font", parent, "All "..name.." font", "Change "..name.." font for all unit frames.", nil, nil, nil, getFontValue, setFontValue, name)
		if i == 1 then
			menu.font1:SetPoint("TOP", menu.fontAll, "BOTTOM", 0, -10)
		elseif i == 2 then
			menu.font2:SetPoint("TOPRIGHT", -5, -60)
		else
			menu["font"..i]:SetPoint("TOP", menu["font"..(i - 2)], "BOTTOM", 0, -10)
		end
	end
end

function Option:CreateFocusKeyMenu(menu, parent)
	menu.desc = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	menu.desc:SetPoint("TOPLEFT", 5, -5)
	menu.desc:SetPoint("TOPRIGHT", -5, -5)
	menu.desc:SetJustifyH("LEFT")
	menu.desc:SetJustifyV("TOP")
	menu.desc:SetHeight(90)
	menu.desc:SetText("Use function key to set new focus or clearing.")
	local modList = { "None", "Shift", "Ctrl", "Alt", "Shift+Ctrl", "Shift+Alt", "Alt+Ctrl" }
	menu.modkey = LBO:CreateWidget("DropDown", parent, "Function key", nil, nil, nil, true,
		function()
			menu.setting:update()
			return IUF.db.focusKey.mod + 1, modList
		end,
		function(v)
			IUF.db.focusKey.mod = v - 1
			LBO:Refresh()
			for _, object in pairs(IUF.units) do
				IUF:RegisterFocusKey(object)
			end
		end
	)
	menu.modkey:SetPoint("TOPLEFT", menu.desc, "BOTTOMLEFT", 0, 0)
	local buttonList = { "Left button", "Right button", "Center button", "Button4", "Button5", "Button6", "Button7", "Button8", "Button9", "Button10" }
	menu.button = LBO:CreateWidget("DropDown", parent, "Mouse Button", nil, nil, function() return IUF.db.focusKey.mod == 0 end, true,
		function()
			menu.setting:update()
			return IUF.db.focusKey.button, buttonList
		end,
		function(v)
			IUF.db.focusKey.button = v
			for _, object in pairs(IUF.units) do
				IUF:RegisterFocusKey(object)
			end
		end
	)
	menu.button:SetPoint("TOPRIGHT", menu.desc, "BOTTOMRIGHT", 0, 0)
	menu.setting = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	menu.setting:SetPoint("TOPLEFT", menu.modkey, "BOTTOMLEFT", 0, -12)
	menu.setting:SetPoint("TOPRIGHT", menu.button, "BOTTOMRIGHT", 0, -12)
	menu.setting:SetJustifyH("CENTER")
	menu.setting:SetHeight(40)
	menu.setting.update = function(self)
		if IUF.db.focusKey.mod == 0 then
			self:SetText("Focus target not used.")
		else
			self:SetFormattedText("|cffffff00%s + Mouse %s|r|1 set to focus target.", modList[IUF.db.focusKey.mod + 1]:gsub("%+", " + "), buttonList[IUF.db.focusKey.button])
		end
	end
end

function Option:CreateColorMenu(menu, parent)
	if not IUF.colordb.power[8] then
		IUF.colordb.power[8] = { 0.3, 0.52, 0.9 }
	end
	local function getColor(colortype, colorsubtype)
		return unpack(IUF.colordb[colortype][colorsubtype])
	end
	local function setColor(r, g, b, colortype, colorsubtype, updatefunc)
		IUF.colordb[colortype][colorsubtype][1] = r
		IUF.colordb[colortype][colorsubtype][2] = g
		IUF.colordb[colortype][colorsubtype][3] = b
		if type(updatefunc) == "function" then
			updatefunc()
		end
	end
	menu.class = LBO:CreateWidget("Heading", parent, "Class color")
	menu.class:SetPoint("TOPLEFT", 5, 10)
	menu.class:SetPoint("TOPRIGHT", -5, 10)
	menu.class:SetScale(1.2)
	local classOrder = { "WARRIOR", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "HUNTER", "DRUID", "SHAMAN", "PALADIN", "DEATHKNIGHT", "MONK", "PET", "FRIEND", "NEUTRAL", "ENEMY" }
	local classNames = {
		WARRIOR = "WARRIOR", ROGUE = "ROGUE", PRIEST = "PRIEST", MAGE = "MAGE", WARLOCK = "WARLOCK",
		HUNTER = "HUNTER", DRUID = "DRUID", SHAMAN = "SHAMAN", PALADIN = "PALADIN", DEATHKNIGHT = "DEATHKNIGHT", MONK = "MONK",
		PET = "PET", FRIEND = "FRIEND", NEUTRAL = "NEUTRAL", ENEMY = "ENEMY",
	}
	local function classColorUpdate()
		for _, object in pairs(IUF.units) do
			if not object.needElement then
				IUF.callbacks.NameColor(object)
				IUF.callbacks.HealthColor(object)
			end
			if object.preview then
				IUF.callbacks.NameColor(object.preview)
				IUF.callbacks.HealthColor(object.preview)
			end
		end
	end
	menu.classReset = LBO:CreateWidget("Button", parent, "Reset", "Reset all class color.", nil, nil, nil,
		function()
			IUF.colordb.class.FRIEND[1] = 0
			IUF.colordb.class.FRIEND[2] = 1
			IUF.colordb.class.FRIEND[3] = 0
			IUF.colordb.class.NEUTRAL[1] = 1
			IUF.colordb.class.NEUTRAL[2] = 1
			IUF.colordb.class.NEUTRAL[3] = 0
			IUF.colordb.class.ENEMY[1] = 1
			IUF.colordb.class.ENEMY[2] = 0.12
			IUF.colordb.class.ENEMY[3] = 0.12
			IUF.colordb.class.PET[1] = 0
			IUF.colordb.class.PET[2] = 1
			IUF.colordb.class.PET[3] = 0
			for class, color in pairs(RAID_CLASS_COLORS) do
				if IUF.colordb.class[class] then
					IUF.colordb.class[class][1] = color.r
					IUF.colordb.class[class][2] = color.g
					IUF.colordb.class[class][3] = color.b
				end
			end
			LBO:Refresh()
			classColorUpdate()
		end
	)
	menu.classReset:SetPoint("RIGHT", menu.class, "RIGHT", 0, 0)
	menu.classReset:SetScale(0.9)
	menu.classReset:SetWidth(60)
	for i, class in ipairs(classOrder) do

		menu["class"..i] = LBO:CreateWidget("ColorPicker", parent, classNames[class], "Set class color for "..classNames[class], nil, nil, nil, getColor, setColor, "class", class, classColorUpdate)

	menu["class"..i]:SetWidth(90)
		if i == 1 then
			menu["class"..i]:SetPoint("TOPLEFT", 5, -16)
		elseif i == 2 then
			menu["class"..i]:SetPoint("TOP", 0, -16)
		elseif i == 3 then
			menu["class"..i]:SetPoint("TOPRIGHT", -5, -16)
		else
			menu["class"..i]:SetPoint("TOP", menu["class"..(i - 3)], "BOTTOM", 0, 12)
		end
	end
	menu.power = LBO:CreateWidget("Heading", parent, "Power bar color")
	menu.power:SetPoint("TOPLEFT", 5, -146)
	menu.power:SetPoint("TOPRIGHT", -5, -146)
	menu.power:SetScale(1.2)
	local function powerColorUpdate()
		for _, object in pairs(IUF.units) do
			if not object.needElement then
				IUF.callbacks.PowerColor(object)
				if object.classBar and IUF.ClassBarSetup then
					IUF:ClassBarSetup(object)
				end
			end
			if object.preview then
				IUF.callbacks.PowerColor(object.preview)
			end
		end
	end
	menu.powerReset = LBO:CreateWidget("Button", parent, "Reset", "Rest all power bar color.", nil, nil, nil,
		function()
			for power, color in pairs(IUF.colordb.power) do
				if PowerBarColor[power] then
					color[1] = PowerBarColor[power].r
					color[2] = PowerBarColor[power].g
					color[3] = PowerBarColor[power].b
				end
			end
			LBO:Refresh()
			powerColorUpdate()
		end
	)
	menu.powerReset:SetPoint("RIGHT", menu.power, "RIGHT", 0, 0)
	menu.powerReset:SetScale(0.9)
	menu.powerReset:SetWidth(60)
	local powerOrder = { 0, 1, 3, 6, 2, 8 }
	local powerNames = { [0] = "Mana", [1] = "Rage", [3] = "Energy", [6] = "Runic Power", [2] = "Focus", [8] = "Astral Power" }

	for i, power in ipairs(powerOrder) do
		menu["power"..i] = LBO:CreateWidget("ColorPicker", parent, powerNames[power], "Set color of " ..powerNames[power], nil, nil, nil, getColor, setColor, "power", power, powerColorUpdate)
		menu["power"..i]:SetWidth(90)
		if i == 1 then
			menu["power"..i]:SetPoint("TOPLEFT", menu.power, "BOTTOMLEFT", 0, 26)
		elseif i == 2 then
			menu["power"..i]:SetPoint("TOP", menu.power, "BOTTOM", 0, 26)
		elseif i == 3 then
			menu["power"..i]:SetPoint("TOPRIGHT", menu.power, "BOTTOMRIGHT", 0, 26)
		else
			menu["power"..i]:SetPoint("TOP", menu["power"..(i - 3)], "BOTTOM", 0, 12)
		end
	end
	menu.casting = LBO:CreateWidget("Heading", parent, "Cast bar color")
	menu.casting:SetPoint("TOPLEFT", 5, -216)
	menu.casting:SetPoint("TOPRIGHT", -5, -216)
	menu.casting:SetScale(1.2)
	local function castingColorUpdate()
		for object in pairs(IUF.visibleObject) do
			if not object.needElement then
				IUF.callbacks.CastingBarColor(object)
			end
			if object.preview then
				IUF.callbacks.CastingBarColor(object.preview)
			end
		end
	end
	menu.castingReset = LBO:CreateWidget("Button", parent, "Reset", "Reset all cast bar color.", nil, nil, nil,
		function()
			IUF.colordb.casting.NORMAL[1] = 1
			IUF.colordb.casting.NORMAL[2] = 0.7
			IUF.colordb.casting.NORMAL[3] = 0
			IUF.colordb.casting.SHIELD[1] = 1
			IUF.colordb.casting.SHIELD[2] = 0
			IUF.colordb.casting.SHIELD[3] = 0
			IUF.colordb.casting.CHANNEL[1] = 0.4
			IUF.colordb.casting.CHANNEL[2] = 0.6
			IUF.colordb.casting.CHANNEL[3] = 0.8
			LBO:Refresh()
			castingColorUpdate()
		end
	)
	menu.castingReset:SetPoint("RIGHT", menu.casting, "RIGHT", 0, 0)
	menu.castingReset:SetScale(0.9)
	menu.castingReset:SetWidth(60)
	local castingOrder = { "NORMAL", "CHANNEL", "SHIELD" }
	local castingNames = { "Normal", "Channel", "Not interruptable" }
	for i, casting in ipairs(castingOrder) do
		menu["casting"..i] = LBO:CreateWidget("ColorPicker", parent, castingNames[i], "Set color of " ..castingNames[i] , nil, nil, nil, getColor, setColor, "casting", casting, castingColorUpdate)
		menu["casting"..i]:SetWidth(90)
		if i == 1 then
			menu["casting"..i]:SetPoint("TOPLEFT", menu.casting, "BOTTOMLEFT", 0, 26)
		elseif i == 2 then
			menu["casting"..i]:SetPoint("TOP", menu.casting, "BOTTOM", 0, 26)
		elseif i == 3 then
			menu["casting"..i]:SetPoint("TOPRIGHT", menu.casting, "BOTTOMRIGHT", 0, 26)
		else
			menu["casting"..i]:SetPoint("TOP", menu["casting"..(i - 3)], "BOTTOM", 0, 12)
		end
	end
	menu.etc = LBO:CreateWidget("Heading", parent, "Combo point color")
	menu.etc:SetPoint("TOPLEFT", 5, -260)
	menu.etc:SetPoint("TOPRIGHT", -5, -260)
	menu.etc:SetScale(1.2)
	local function comboColorUpdate()
		for _, object in pairs(IUF.units) do
			if object.comboFrame then
				for i = 1, 5 do
					object.comboFrame[i].highlight:SetVertexColor(unpack(IUF.colordb.combo))
				end
			end
			if object.preview and object.preview.comboFrame then
				for i = 1, 5 do
					object.preview.comboFrame[i].highlight:SetVertexColor(unpack(IUF.colordb.combo))
				end
			end
		end
	end
	menu.etcReset = LBO:CreateWidget("Button", parent, "Reset", "Rest combo point color.", nil, nil, nil,
		function()
			IUF.colordb.combo[1] = 1
			IUF.colordb.combo[2] = 1
			IUF.colordb.combo[3] = 0
			LBO:Refresh()
			comboColorUpdate()
		end
	)
	menu.etcReset:SetPoint("RIGHT", menu.etc, "RIGHT", 0, 0)
	menu.etcReset:SetScale(0.9)
	menu.etcReset:SetWidth(60)
	menu.combo = LBO:CreateWidget("ColorPicker", parent, "Combo point", "Set combo point color.", nil, nil, nil,
		function() return unpack(IUF.colordb.combo) end,
		function(r, g, b)
			IUF.colordb.combo[1] = r
			IUF.colordb.combo[2] = g
			IUF.colordb.combo[3] = b
			comboColorUpdate()
		end
	)
	menu.combo:SetPoint("TOPLEFT", menu.etc, "BOTTOMLEFT", 0, 26)
end

function Option:CreateBlizzardMenu(menu, parent)
	menu.hiddenBlizzard = LBO:CreateWidget("CheckBox", parent, "Hide Blizzard cast bar", "Hide Blizzard default cast bar.", nil, nil, nil,
		function()
			return unitsdb.player.hiddenBlizzardCastingBar
		end,
		function(v)
			unitsdb.player.hiddenBlizzardCastingBar = v
			if v then
				PlayerCastingBarFrame.showCastbar = nil
				PetCastingBarFrame.showCastbar = nil
			else
				PlayerCastingBarFrame.showCastbar = true
				PetCastingBarFrame.showCastbar = true
			end
			--CastingBarFrame_UpdateIsShown(PlayerCastingBarFrame)
			--CastingBarFrame_UpdateIsShown(PetCastingBarFrame)
			PlayerCastingBarFrame:UpdateIsShown()
			PetCastingBarFrame:UpdateIsShown()
		end
	)
	menu.hiddenBlizzard:SetPoint("TOPLEFT", 5, -5)
end

function Option:CreateUnitBasicMenu(menu, parent)
	menu.active = LBO:CreateWidget("CheckBox", parent, "Enable", "Enable Inven Unit Frame.", nil, notActiveParentObject, true,
		function() return IUF.db.units[Option.unit].active end,
		function(v)
			IUF.db.units[Option.unit].active = v
			setCoreValue(Option.unit, "SetActiveObject")
			if IUF.previewMode then
				IUF:SetPreviewMode(true)
			end
			LBO:Refresh()
		end
	)
	menu.active:SetPoint("TOPLEFT", 5, -5)
	menu.skinType = LBO:CreateWidget("DropDown", parent, "Skin", "Change frame skin.", nil, notActiveParentObject, true,
		function()
			return IUF.db.units[Option.unit].skin.override or "Default", Option:GetSkinTypes(Option.unit)
		end,
		function(v)
			v = v ~= "기본값" and v or nil
			if v ~= IUF.db.units[Option.unit].skin.override then
				IUF.db.units[Option.unit].skin.override = v
				setCoreValue(Option.unit, "SetObjectSkin")
				LBO:Refresh()
			end
		end
	)
	menu.skinType:SetPoint("TOPRIGHT", -5, -5)
	menu.reset = LBO:CreateWidget("Button", parent, "Reset all setting", "Reset all setting of Inven Unit Frame.", nil, notActiveObject, true,
		function()
			local update = nil
			for p in pairs(IUF.db.units[Option.unit].skin) do
				IUF.db.units[Option.unit].skin[p] = nil
				update = true
			end
			if update then
				setCoreValue(Option.unit, "SetObjectSkin")
				LBO:Refresh()
			end
		end
	)
	menu.reset:SetPoint("TOP", menu.active, "BOTTOM", 0, -5)
	menu.resetPos = LBO:CreateWidget("Button", parent, "Reset position", "Reset current frame position.", nil, notActiveObject, true,
		function()
			if IUF.db.units[Option.unit].pos[1] then
				IUF.db.units[Option.unit].pos[1], IUF.db.units[Option.unit].pos[2] = nil
				setCoreValue(Option.unit, "SetObjectPoint")
			end
			menu.pos_x:Setup()
			menu.pos_y:Setup()
		end
	)
	menu.resetPos:SetPoint("TOP", menu.skinType, "BOTTOM", 0, -5)
	menu.pos_x = LBO:CreateWidget("EditBox", parent, "Position X", "Set frame horizental positoin.", nil, notActiveObject, true,
		function()
			return tonumber(("%.2f"):format(IUF:GetObjectPoint(Option.unit)))
		end,
		function(v)
			IUF.db.units[Option.unit].pos[1], IUF.db.units[Option.unit].pos[2] = IUF:GetObjectPoint(Option.unit)
			IUF.db.units[Option.unit].pos[1] = v
			setCoreValue(Option.unit, "SetObjectPoint")
		end
	)
	menu.pos_x:SetNumeric(true)
	menu.pos_x:SetPoint("TOP", menu.reset, "BOTTOM", 0, 10)
	menu.pos_y = LBO:CreateWidget("EditBox", parent, "Position Y", "Set frame vertical positoin.", nil, notActiveObject, true,
		function()
			return -tonumber(("%.2f"):format(select(2, IUF:GetObjectPoint(Option.unit))))
		end,
		function(v)
			IUF.db.units[Option.unit].pos[1] = IUF:GetObjectPoint(Option.unit)
			IUF.db.units[Option.unit].pos[2] = -v
			setCoreValue(Option.unit, "SetObjectPoint")
		end
	)
	menu.pos_y:SetNumeric(true)
	menu.pos_y:SetPoint("TOP", menu.resetPos, "BOTTOM", 0, 10)
	self.xPos, self.yPos = menu.pos_x, menu.pos_y
	menu.width = LBO:CreateWidget("Slider", parent, "Width", "Set frame width.", nil, notActiveObject, true,
		function()
			return unitsdb[Option.unit].width, floor(unitsdb[Option.unit].height * 1.5), unitsdb[Option.unit].height * 10, 1, "픽셀"
		end,
		function(v)
			unitsdb[Option.unit].width = v
			setObjectValue(Option.unit, "SetWidth", v)
			setCoreValue(Option.unit, "UpdateSkinAura")
		end
	)
	menu.width:SetPoint("TOP", menu.pos_x, "BOTTOM", 0, 0)
	menu.scale = LBO:CreateWidget("Slider", parent, "Size", "Set frame size.", nil, notActiveObject, true,
		function()
			return floor(unitsdb[Option.unit].scale * 100), 40, 160, 1, "%"
		end,
		function(v)
			unitsdb[Option.unit].scale = v / 100
			setObjectValue(Option.unit, "SetScale", v / 100)
			setCoreValue(Option.unit, "SetObjectPoint")
		end
	)
	menu.scale:SetPoint("TOP", menu.pos_y, "BOTTOM", 0, 0)
	menu.pvp = LBO:CreateWidget("CheckBox", parent, "Show PvP Icon", "Display PvP activation icon.",
		function()
			if Option.unit then
				return not(type(unitsdb[Option.unit].pvpIcon) == "string" and unitsdb[Option.unit].pvpIcon:find("^return"))
			else
				return nil
			end
		end, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].pvpIconUse
		end,
		function(v)
			unitsdb[Option.unit].pvpIconUse = v
			setObjectElementValue(Option.unit, "pvpIcon", "use", v)
			setCoreValue(Option.unit, "TriggerCallback", "PvPIcon")
		end
	)
	menu.pvp:SetPoint("TOP", menu.width, "BOTTOM", 0, 0)
	menu.elite = LBO:CreateWidget("CheckBox", parent, "Show Elite texture", "Display Elite border.",
		function()
			if Option.unit then
				if IUF.db.skin == "Blizzard" then
					if type(unitsdb[Option.unit].overlay1) == "string" and unitsdb[Option.unit].overlay1:find("self:SetTexture") then
						return true
					else
						return nil
					end
				elseif type(unitsdb[Option.unit].eliteFrame) == "string" and unitsdb[Option.unit].eliteFrame:find("^return") then
					return nil
				else
					return true
				end
			else
				return true
			end
		end, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].eliteFrameUse
		end,
		function(v)
			unitsdb[Option.unit].eliteFrameUse = v
			setObjectElementValue(Option.unit, "eliteFrame", "use", v)
			setCoreValue(Option.unit, "TriggerCallback", "Elite")
		end
	)
	menu.elite:SetPoint("TOP", menu.scale, "BOTTOM", 0, 0)
	menu.model3d = LBO:CreateWidget("CheckBox", parent, "3D model portrait", "Use 3D portrate.",
		function()
			if Option.unit and type(unitsdb[Option.unit].portrait) == "string" and unitsdb[Option.unit].portrait:find("^return") then
				return nil
			else
				return true
			end
		end, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].portrait3DModel
		end,
		function(v)
			unitsdb[Option.unit].portrait3DModel = v
			setObjectElementValue(Option.unit, "portrait", "show3dModel", v)
			setCoreValue(Option.unit, "TriggerCallback", "Portrait")
		end
	)
	menu.model3d:SetPoint("TOP", menu.pvp, "BOTTOM", 0, 0)
	local function checkFeedback()
		if (Option.unit == "player" or Option.unit == "target") and type(unitsdb[Option.unit].portrait) == "string" and unitsdb[Option.unit].portrait:find("^return") then
			return nil
		else
			return true
		end
	end
	menu.feedback = LBO:CreateWidget("CheckBox", parent, "Show combat feedback text", "Display combat text.", checkFeedback, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].combatFeedback
		end,
		function(v)
			unitsdb[Option.unit].combatFeedback = v
			IUF:RegsiterCombatFeedback()
			LBO:Refresh()
		end
	)
	menu.feedback:SetPoint("TOP", menu.model3d, "BOTTOM", 0, 0)
	menu.feedbackFontSize = LBO:CreateWidget("Slider", parent, "Combat text font size", "Set combat text font size.", checkFeedback,
		function()
			if notActiveObject() then
				return true
			elseif unitsdb[Option.unit].combatFeedback then
				return nil
			else
				return true
			end
		end, nil,
		function()
			return unitsdb[Option.unit].combatFeedbackFontSize, 7, 34, 1, "point"
		end,
		function(v)
			unitsdb[Option.unit].combatFeedbackFontSize = v
			IUF:RegsiterCombatFeedback()
		end
	)
	menu.feedbackFontSize:SetPoint("TOP", menu.elite, "BOTTOM", 0, -44)
	menu.partyOffset = LBO:CreateWidget("Slider", parent, "Party frame space", "Set space among party frames.",
		function() return Option.unit ~= "party" end, notActiveObject, true,
		function() return unitsdb[Option.unit].partyOffset, 0, 200, 1, "pixel" end,
		function(v)
			unitsdb[Option.unit].partyOffset = v
			setCoreValue(Option.unit, "SetObjectPoint")
		end
	)
	menu.partyOffset:SetPoint("TOP", menu.elite, "BOTTOM", 0, 0)
	menu.hideInRaid = LBO:CreateWidget("CheckBox", parent, "Hide party frame in raid", "Hide party frame in raid.",
		function() return Option.unit ~= "party" end, notActiveObject, true,
		function() return IUF.db.hideInRaid end,
		function(v)
			IUF.db.hideInRaid = v
			setCoreValue(Option.unit, "SetActiveObject")
		end
	)
	menu.hideInRaid:SetPoint("TOP", menu.partyOffset, "BOTTOM", 0, 0)
	menu.bossOffset = LBO:CreateWidget("Slider", parent, "Boss frame space", "Set space among boss frames.",
		function() return Option.unit ~= "boss" end, notActiveObject, true,
		function() return unitsdb[Option.unit].bossOffset, 0, 200, 1, "pixel" end,
		function(v)
			unitsdb[Option.unit].bossOffset = v
			setCoreValue(Option.unit, "SetObjectPoint")
		end
	)
	menu.bossOffset:SetPoint("TOP", menu.elite, "BOTTOM", 0, 0)
end

function Option:CreateUnitHealthMenu(menu, parent)
	menu.texture = LBO:CreateWidget("Media", parent, "Bar texture", "Set health bar texture.", nil, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].healthBarTexture or defaultStatusBarTexture, "StatusBar"
		end,
		function(v)
			unitsdb[Option.unit].healthBarTexture = v
			setObjectElementValue(Option.unit, "healthBar", "SetTexture", SM:Fetch("statusbar", v))
		end
	)
	menu.texture:SetPoint("TOPLEFT", 5, -5)

	menu.barAnimation = LBO:CreateWidget("CheckBox", parent, "Use bar animation", "Animated effect for health bar", nil, notActiveObject, nil,
		function()
			return IUF.db.barAnimation
		end,
		function(v)
			IUF.db.barAnimation = v
		end
	)
	menu.barAnimation:SetPoint("TOPRIGHT", -5, -12)
	menu.classColor = LBO:CreateWidget("CheckBox", parent, "Use class color", "Use class color for health bar.", nil, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].healthBarClassColor
		end,
		function(v)
			unitsdb[Option.unit].healthBarClassColor = v
			setObjectElementValue(Option.unit, "healthBar", "classColor", v)
			setCoreValue(Option.unit, "TriggerCallback", "HealthColor")
			LBO:Refresh()
		end
	)
	menu.classColor:SetPoint("TOP", menu.texture, "BOTTOM", 0, -10)
	menu.classColorEnemy = LBO:CreateWidget("CheckBox", parent, "Use class color for enemy players", "Use class color for enemy players.", nil,
		function()
			if not notActiveObject() then
				return Option.unit and (not unitsdb[Option.unit].healthBarClassColor)
			else
				return true
			end
		end, nil,
		function()
			return IUF.db.useEnemyClassColor
		end,
		function(v)
			IUF.db.useEnemyClassColor = v
			for unit in pairs(unitsdb) do
				setCoreValue(unit, "TriggerCallback", "HealthColor")
			end
		end
	)
	menu.classColorEnemy:SetPoint("TOP", menu.classColor, "BOTTOM", 0, 15)
end

function Option:CreateUnitHealthTextMenu(menu, parent)
	menu.clearAll = LBO:CreateWidget("Button", parent, "Hide all", "Hide all health display setting.", nil, notActiveObject, nil,
		function()
			for i = 1, 5 do
				unitsdb[Option.unit]["healthText"..i] = false
				unitsdb[Option.unit]["healthText"..i.."InCombat"] = false
				setObjectElementValue(Option.unit, "healthText"..i, "combat", nil)
				updateElementSkin(Option.unit, "healthText"..i)
			end
			setCoreValue(Option.unit, "TriggerCallback", "Health")
			LBO:Refresh()
		end
	)
	menu.clearAll:SetPoint("TOPLEFT", 5, 0)
	menu.resetAll = LBO:CreateWidget("Button", parent, "Reset", "Reset all health display setting.", nil, notActiveObject, nil,
		function()
			for i = 1, 5 do
				IUF.db.units[Option.unit].skin["healthText"..i] = nil
				IUF.db.units[Option.unit].skin["healthText"..i.."InCombat"] = nil
				IUF.db.units[Option.unit].skin["healthText"..i.."FontFile"] = nil
				IUF.db.units[Option.unit].skin["healthText"..i.."FontSize"] = nil
				IUF.db.units[Option.unit].skin["healthText"..i.."FontAttribute"] = nil
				IUF.db.units[Option.unit].skin["healthText"..i.."FontShadow"] = nil
				updateFontString(Option.unit, "healthText"..i)
				setObjectElementValue(Option.unit, "healthText"..i, "combat", unitsdb[Option.unit]["healthText"..i.."InCombat"])
				updateElementSkin(Option.unit, "healthText"..i)
			end
			setCoreValue(Option.unit, "TriggerCallback", "Health")
			LBO:Refresh()
		end
	)
	menu.resetAll:SetPoint("TOPRIGHT", -5, 0)
	local function getTextType(id)
		if unitsdb[Option.unit]["healthText"..id] and barTextTypes[unitsdb[Option.unit]["healthText"..id] + 1] then
			return unitsdb[Option.unit]["healthText"..id] + 1, barTextTypes
		else
			return 1, barTextTypes
		end
	end
	local function setTextType(v, id, menu)
		v = v - 1
		if IUF:HasStatusBarDisplay(v) then
			unitsdb[Option.unit]["healthText"..id] = v
		else
			unitsdb[Option.unit]["healthText"..id] = false
		end
		updateElementSkin(Option.unit, "healthText"..id)
		setCoreValue(Option.unit, "TriggerCallback", "Health")
		LBO:Refresh()
	end
	local function getTextCombat(id)
		return unitsdb[Option.unit]["healthText"..id.."InCombat"]
	end
	local function setTextCombat(v, id)
		unitsdb[Option.unit]["healthText"..id.."InCombat"] = v
		setObjectElementValue(Option.unit, "healthText"..id, "combat", v)
		setCoreValue(Option.unit, "TriggerCallback", "Health")
	end
	local function getTextFont(id)
		return unitsdb[Option.unit]["healthText"..id.."FontFile"], unitsdb[Option.unit]["healthText"..id.."FontSize"], unitsdb[Option.unit]["healthText"..id.."FontAttribute"], unitsdb[Option.unit]["healthText"..id.."FontShadow"]
	end
	local function setTextFont(file, size, attribute, shadow, id)
		unitsdb[Option.unit]["healthText"..id.."FontFile"] = file
		unitsdb[Option.unit]["healthText"..id.."FontSize"] = size
		unitsdb[Option.unit]["healthText"..id.."FontAttribute"] = attribute
		unitsdb[Option.unit]["healthText"..id.."FontShadow"] = shadow
		updateFontString(Option.unit, "healthText"..id)
	end
	local function disableTextFont(id)
		if notActiveObject() then
			return true
		elseif Option.unit and IUF:HasStatusBarDisplay(unitsdb[Option.unit]["healthText"..id]) then
			return false
		else
			return true
		end
	end
	for i, name in ipairs(barTextList) do
		menu["text"..i] = LBO:CreateWidget("Heading", parent, "Health bar "..name, nil, nil, notActiveObject)
		menu["text"..i]:SetScale(1.1)
		menu["text"..i]:SetPoint("TOPLEFT", menu["text"..(i - 1)], "BOTTOMLEFT", 0, -80)
		menu["text"..i]:SetPoint("TOPRIGHT", menu["text"..(i - 1)], "BOTTOMRIGHT", 0, -80)
		menu["textType"..i] = LBO:CreateWidget("DropDown", parent, "Display", "Set text display of Health bar "..name..".", nil, notActiveObject, nil, getTextType, setTextType, i)
		menu["textType"..i]:SetPoint("TOPLEFT", menu["text"..i], "BOTTOMLEFT", 0, 18)
		menu["textInCombat"..i] = LBO:CreateWidget("CheckBox", parent, "Only in combat", "Health bar "..name.." text displayed in combat only.", nil, disableTextFont, nil, getTextCombat, setTextCombat, i)
		menu["textInCombat"..i]:SetPoint("TOPRIGHT", menu["text"..i], "BOTTOMRIGHT", 0, 18)
		menu["textFont"..i] = LBO:CreateWidget("Font", parent, "Font", "Set font of Health bar "..name..".", nil, disableTextFont, nil, getTextFont, setTextFont, i)
		menu["textFont"..i]:SetPoint("TOP", menu["textType"..i], "BOTTOM", 0, -5)
	end
	menu.text1:ClearAllPoints()
	menu.text1:SetPoint("TOPLEFT", 5, -30)
	menu.text1:SetPoint("TOPRIGHT", -5, -30)
end

function Option:CreateUnitManaMenu(menu, parent)
	menu.texture = LBO:CreateWidget("Media", parent, "Bar texture", "Set power bar texture.", nil, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].powerBarTexture or defaultStatusBarTexture, "StatusBar"
		end,
		function(v)
			unitsdb[Option.unit].powerBarTexture = v
			setObjectElementValue(Option.unit, "powerBar", "SetTexture", SM:Fetch("statusbar", v))
			if Option.unit == "player" and IUF.ClassBarSetup then
				IUF:ClassBarSetup(IUF.units.player)
			end
		end
	)
	menu.texture:SetPoint("TOPLEFT", 5, -5)
	menu.barAnimation = LBO:CreateWidget("CheckBox", parent, "Use bar animation", "Animation effor for power bar.", nil, notActiveObject, nil,
		function() return IUF.db.barAnimation end,
		function(v) IUF.db.barAnimation = v end
	)
	menu.barAnimation:SetPoint("TOPRIGHT", -5, -12)
	menu.barHeight = LBO:CreateWidget("Slider", parent, "Power bar scale", "Set power bar scale.",
		function()
			if Option.unit then
				return type(unitsdb[Option.unit].powerBarHeight) ~= "number"
			end
		end, notActiveObject, nil,
		function() return (unitsdb[Option.unit].powerBarHeight or 0.5) * 100, 0, 100, 1, "%" end,
		function(v)
			unitsdb[Option.unit].powerBarHeight = v / 100
			updateElementSkin(Option.unit, "healthBar")
			updateElementSkin(Option.unit, "powerBar")
		end
	)
	menu.barHeight:SetPoint("TOP", menu.texture, "BOTTOM", 0, -10)
end

function Option:CreateUnitManaTextMenu(menu, parent)
	menu.clearAll = LBO:CreateWidget("Button", parent, "Hide all", "Hide all power bar setting.", nil, notActiveObject, nil,
		function()
			for i = 1, 5 do
				unitsdb[Option.unit]["powerText"..i] = false
				unitsdb[Option.unit]["powerText"..i.."InCombat"] = false
				setObjectElementValue(Option.unit, "powerText"..i, "combat", nil)
				updateElementSkin(Option.unit, "powerText"..i)
			end
			setCoreValue(Option.unit, "TriggerCallback", "Power")
			LBO:Refresh()
		end
	)
	menu.clearAll:SetPoint("TOPLEFT", 5, 0)
	menu.resetAll = LBO:CreateWidget("Button", parent, "Reset", "Reset all power bar setting.", nil, notActiveObject, nil,
		function()
			for i = 1, 5 do
				IUF.db.units[Option.unit].skin["powerText"..i] = nil
				IUF.db.units[Option.unit].skin["powerText"..i.."InCombat"] = nil
				IUF.db.units[Option.unit].skin["powerText"..i.."FontFile"] = nil
				IUF.db.units[Option.unit].skin["powerText"..i.."FontSize"] = nil
				IUF.db.units[Option.unit].skin["powerText"..i.."FontAttribute"] = nil
				IUF.db.units[Option.unit].skin["powerText"..i.."FontShadow"] = nil
				updateFontString(Option.unit, "powerText"..i)
				setObjectElementValue(Option.unit, "powerText"..i, "combat", unitsdb[Option.unit]["powerText"..i.."InCombat"])
				updateElementSkin(Option.unit, "powerText"..i)
			end
			setCoreValue(Option.unit, "TriggerCallback", "Power")
			LBO:Refresh()
		end
	)
	menu.resetAll:SetPoint("TOPRIGHT", -5, 0)
	local function getTextType(id)
		if unitsdb[Option.unit]["powerText"..id] and barTextTypes[unitsdb[Option.unit]["powerText"..id] + 1] then
			return unitsdb[Option.unit]["powerText"..id] + 1, barTextTypes
		else
			return 1, barTextTypes
		end
	end
	local function setTextType(v, id, menu)
		v = v - 1
		if IUF:HasStatusBarDisplay(v) then
			unitsdb[Option.unit]["powerText"..id] = v
		else
			unitsdb[Option.unit]["powerText"..id] = false
		end
		updateElementSkin(Option.unit, "powerText"..id)
		setCoreValue(Option.unit, "TriggerCallback", "Power")
		LBO:Refresh()
	end
	local function getTextCombat(id)
		return unitsdb[Option.unit]["powerText"..id.."InCombat"]
	end
	local function setTextCombat(v, id)
		unitsdb[Option.unit]["powerText"..id.."InCombat"] = v
		setObjectElementValue(Option.unit, "powerText"..id, "combat", v)
		setCoreValue(Option.unit, "TriggerCallback", "Power")
	end
	local function getTextFont(id)
		return unitsdb[Option.unit]["powerText"..id.."FontFile"], unitsdb[Option.unit]["powerText"..id.."FontSize"], unitsdb[Option.unit]["powerText"..id.."FontAttribute"], unitsdb[Option.unit]["powerText"..id.."FontShadow"]
	end
	local function setTextFont(file, size, attribute, shadow, id)
		unitsdb[Option.unit]["powerText"..id.."FontFile"] = file
		unitsdb[Option.unit]["powerText"..id.."FontSize"] = size
		unitsdb[Option.unit]["powerText"..id.."FontAttribute"] = attribute
		unitsdb[Option.unit]["powerText"..id.."FontShadow"] = shadow
		updateFontString(Option.unit, "powerText"..id)
	end
	local function disableTextFont(id)
		if notActiveObject() then
			return true
		elseif Option.unit and IUF:HasStatusBarDisplay(unitsdb[Option.unit]["powerText"..id]) then
			return false
		else
			return true
		end
	end
	for i, name in ipairs(barTextList) do
		menu["text"..i] = LBO:CreateWidget("Heading", parent, "Power bar "..name, nil, nil, notActiveObject)
		menu["text"..i]:SetScale(1.1)
		menu["text"..i]:SetPoint("TOPLEFT", menu["text"..(i - 1)], "BOTTOMLEFT", 0, -80)
		menu["text"..i]:SetPoint("TOPRIGHT", menu["text"..(i - 1)], "BOTTOMRIGHT", 0, -80)
		menu["textType"..i] = LBO:CreateWidget("DropDown", parent, "display type", "Set text type of power bar "..name..".", nil, notActiveObject, nil, getTextType, setTextType, i)
		menu["textType"..i]:SetPoint("TOPLEFT", menu["text"..i], "BOTTOMLEFT", 0, 18)
		menu["textInCombat"..i] = LBO:CreateWidget("CheckBox", parent, "Only in combat", "Power "..name.." text displayed only in combat.", nil, disableTextFont, nil, getTextCombat, setTextCombat, i)
		menu["textInCombat"..i]:SetPoint("TOPRIGHT", menu["text"..i], "BOTTOMRIGHT", 0, 18)
		menu["textFont"..i] = LBO:CreateWidget("Font", parent, "Font", "Set font of power bar "..name..".", nil, disableTextFont, nil, getTextFont, setTextFont, i)
		menu["textFont"..i]:SetPoint("TOP", menu["textType"..i], "BOTTOM", 0, -5)
	end
	menu.text1:ClearAllPoints()
	menu.text1:SetPoint("TOPLEFT", 5, -30)
	menu.text1:SetPoint("TOPRIGHT", -5, -30)
end

function Option:CreateUnitCastingBarMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "Show cast bar", "Show or hide cast bar in frame.", nil, notActiveObject, nil,
		function()
			return unitsdb[Option.unit].castingBarUse
		end,
		function(v)
			unitsdb[Option.unit].castingBarUse = v
			setObjectElementValue(Option.unit, "castingBar", "use", v)
			if v then
				setObjectHandlerUpdate(Option.unit, "UNIT_SPELLCAST_START")
			end
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
			LBO:Refresh()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	menu.hiddenBlizzard = LBO:CreateWidget("CheckBox", parent, "Hide Blizzard cast bar", "Show or hide blizzard default cast bar.",
		function()
			return Option.unit ~= "player"
		end, nil, nil,
		function()
			return unitsdb[Option.unit].hiddenBlizzardCastingBar
		end,
		function(v)
			unitsdb[Option.unit].hiddenBlizzardCastingBar = v
			if v then
				PlayerCastingBarFrame.showCastbar = nil
				PetCastingBarFrame.showCastbar = nil
			else
				PlayerCastingBarFrame.showCastbar = true
				PetCastingBarFrame.showCastbar = true
			end
			--CastingBarFrame_UpdateIsShown(PlayerCastingBarFrame)
			--CastingBarFrame_UpdateIsShown(PetCastingBarFrame)				
			PlayerCastingBarFrame:UpdateIsShown()
			PetCastingBarFrame:UpdateIsShown()
		end
	)
	menu.hiddenBlizzard:SetPoint("TOPRIGHT", -5, -5)
	local function isnotCastingBarUse()
		if notActiveObject() then
			return true
		else
			return not unitsdb[Option.unit].castingBarUse
		end
	end
	menu.texture = LBO:CreateWidget("Media", parent, "Bar Texture", "Set castbar texture.", nil, isnotCastingBarUse, nil,
		function()
			return unitsdb[Option.unit].castingBarTexture or defaultStatusBarTexture, "statusbar"
		end,
		function(v)
			unitsdb[Option.unit].castingBarTexture = v
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
		end
	)
	menu.texture:SetPoint("TOP", menu.use, "BOTTOM", 0, 5)
	local castingBarPosLink = { "TOPAURA", "TOP", "BOTTOM", "BOTTOMAURA" }
	local castingBarPos = { "Most Top", "Frame Top", "Frame Bottom", "Most Bottom" }
	local castingBarPosID = {}
	for p, v in pairs(castingBarPosLink) do
		castingBarPosID[v] = p
	end
	menu.pos = LBO:CreateWidget("DropDown", parent, "Position", "Set cast bar position.", nil, isnotCastingBarUse, nil,
		function()
			return castingBarPosID[unitsdb[Option.unit].castingBarPos or "BOTTOM"] or 2, castingBarPos
		end,
		function(v)
			unitsdb[Option.unit].castingBarPos = castingBarPosLink[v]
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
		end
	)
	menu.pos:SetPoint("TOP", menu.hiddenBlizzard, "BOTTOM", 0, 5)
	menu.height = LBO:CreateWidget("Slider", parent, "Height", "Set castbar height.", nil, isnotCastingBarUse, nil,
		function()
			return unitsdb[Option.unit].castingBarHeight, 1, 30, 1, "pixel"
		end,
		function(v)
			unitsdb[Option.unit].castingBarHeight = v
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
		end
	)
	menu.height:SetPoint("TOP", menu.texture, "BOTTOM", 0, -5)
	menu.textUse = LBO:CreateWidget("CheckBox", parent, "Show spell name", "Show spell name in casting.", nil, isnotCastingBarUse, nil,
		function()
			return unitsdb[Option.unit].castingBarTextUse
		end,
		function(v)
			unitsdb[Option.unit].castingBarTextUse = v
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
			LBO:Refresh()
		end
	)
	menu.textUse:SetPoint("TOP", menu.height, "BOTTOM", 0, 0)
	menu.textFont = LBO:CreateWidget("Font", parent, "Spell name font", "Set font for spell name in casting.", nil,
		function()
			if not isnotCastingBarUse() then
				return not unitsdb[Option.unit].castingBarTextUse
			else
				return true
			end
		end, nil,
		function()
			return unitsdb[Option.unit].castingBarTextFontFile, unitsdb[Option.unit].castingBarTextFontSize, unitsdb[Option.unit].castingBarTextFontAttribute, unitsdb[Option.unit].castingBarTextFontShadow
		end,
		function(file, size, attribute, shadow)
			unitsdb[Option.unit].castingBarTextFontFile = file
			unitsdb[Option.unit].castingBarTextFontSize = size
			unitsdb[Option.unit].castingBarTextFontAttribute = attribute
			unitsdb[Option.unit].castingBarTextFontShadow = shadow
			updateFontString(Option.unit, "castingBarText")
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
		end
	)
	menu.textFont:SetPoint("TOP", menu.textUse, "BOTTOM", 0, 5)
	menu.timerUse = LBO:CreateWidget("CheckBox", parent, "Show remain time", "Shows remain time in casting.", nil, isnotCastingBarUse, nil,
		function()
			return unitsdb[Option.unit].castingBarTimeUse
		end,
		function(v)
			unitsdb[Option.unit].castingBarTimeUse = v
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
			LBO:Refresh()
		end
	)
	menu.timerUse:SetPoint("TOPLEFT", menu.pos, "BOTTOMLEFT", 0, -49)
	menu.timerFont = LBO:CreateWidget("Font", parent, "Remain time font", "Set font for remain time in casting.", nil,
		function()
			if not isnotCastingBarUse() then
				return not unitsdb[Option.unit].castingBarTimeUse
			else
				return true
			end
		end, nil,
		function()
			return unitsdb[Option.unit].castingBarTimeFontFile, unitsdb[Option.unit].castingBarTimeFontSize, unitsdb[Option.unit].castingBarTimeFontAttribute, unitsdb[Option.unit].castingBarTimeFontShadow
		end,
		function(file, size, attribute, shadow)
			unitsdb[Option.unit].castingBarTimeFontFile = file
			unitsdb[Option.unit].castingBarTimeFontSize = size
			unitsdb[Option.unit].castingBarTimeFontAttribute = attribute
			unitsdb[Option.unit].castingBarTimeFontShadow = shadow
			updateFontString(Option.unit, "castingBarTime")
			updateElementSkin(Option.unit, "castingBar")
			setCoreValue(Option.unit, "TriggerCallback", "CastingBar")
		end
	)
	menu.timerFont:SetPoint("TOP", menu.timerUse, "BOTTOM", 0, 5)
end

function Option:CreateUnitBuffMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "Show buff", "Show or hide buff.", nil, notActiveObject, nil,
		function() return unitsdb[Option.unit].buffUse end,
		function(v)
			unitsdb[Option.unit].buffUse = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
			LBO:Refresh()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	local function isnotBuffUse()
		if notActiveObject() then
			return true
		else
			return not unitsdb[Option.unit].buffUse
		end
	end
	menu.num = LBO:CreateWidget("Slider", parent, "Number of buff to display", "Number of buff to display.", nil, isnotBuffUse, nil,
		function() return unitsdb[Option.unit].buffNum, 0, 40, 1, "개" end,
		function(v)
			unitsdb[Option.unit].buffNum = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.num:SetPoint("TOPRIGHT", -5, -5)
	menu.pos = LBO:CreateWidget("DropDown", parent, "Buff position", "Set buff position.", nil, isnotBuffUse, nil,
		function()
			return auraPositions[unitsdb[Option.unit].buffPos or "TOP"] or 1, auraPositionList
		end,
		function(v)
			unitsdb[Option.unit].buffPos = auraPositions[v] or "TOP"
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, 10)
	menu.small = LBO:CreateWidget("Slider", parent, "Buff size", "Set buff icon size of other players.", nil, isnotBuffUse, nil,
		function()
			return unitsdb[Option.unit].buffSmallSize, 10, 40, 1, "픽셀"
		end,
		function(v)
			unitsdb[Option.unit].buffSmallSize = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.small:SetPoint("TOP", menu.pos, "BOTTOM", 0, -10)
	menu.countSize = LBO:CreateWidget("Slider", parent, "Font size for stack", "Set stack font size.", nil, isnotBuffUse, nil,
		function()
			return unitsdb[Option.unit].buffCountTextFontSize, 7, 37, 1, "point"
		end,
		function(v)
			unitsdb[Option.unit].buffCountTextFontSize = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.countSize:SetPoint("TOP", menu.small, "TOP", 0, 0)
	menu.countSize:SetPoint("RIGHT", menu.num, "RIGHT", 0, 0)

	menu.smallTexture = LBO:CreateWidget("CheckBox", parent, "Show cooldown texture", "Show or hide cooldown texture of other players.", nil, isnotBuffUse, nil,
		function() return not unitsdb[Option.unit].buffHiddenSmallCooldownTexture end,
		function(v)
			unitsdb[Option.unit].buffHiddenSmallCooldownTexture = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.smallTexture:SetPoint("TOP", menu.small, "BOTTOM", 0, 5)
	menu.line = LBO:CreateWidget("CheckBox", parent, "Auto line feed", "Auto line feed by frame size.", nil, isnotBuffUse, nil,
		function() return not unitsdb[Option.unit].buffSkipLine end,
		function(v)
			unitsdb[Option.unit].buffSkipLine = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.line:SetPoint("TOP", menu.countSize, "BOTTOM", 0, 5)
	local function isnotMyBuff()
		return Option.unit ~= "player" and Option.unit ~= "target" and Option.unit ~= "focus" and Option.unit ~= "party" and Option.unit ~= "boss"
	end

	menu.filterLine = LBO:CreateWidget("Heading", parent, "Buff filtering", nil, nil, isnotBuffUse)
	menu.filterLine:SetScale(1.2)
	menu.filterLine:SetPoint("TOPLEFT", menu.small, "BOTTOMLEFT", 0, -18)
	menu.filterLine:SetPoint("TOPRIGHT", menu.countSize, "BOTTOMRIGHT", 0, -18)

	menu.filterHelpMine = LBO:CreateWidget("CheckBox", parent, "Help: My cast", "Show my buff for helpful target.", nil, isnotBuffUse, nil,
		function() return unitsdb[Option.unit].buffFilterHelpMine end,
		function(v)
			unitsdb[Option.unit].buffFilterHelpMine = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
			LBO:Refresh()
		end
	)
	menu.filterHelpMine:SetPoint("TOPLEFT", menu.filterLine, "BOTTOMLEFT", 0, 20)
	menu.filterHelpMineBig = LBO:CreateWidget("CheckBox", parent, "Emphasize", "Emphsize my buff for helpful target.", isnotMyBuff,
		function()
			return isnotBuffUse() or not unitsdb[Option.unit].buffFilterHelpMine
		end, nil,
		function() return unitsdb[Option.unit].buffFilterHelpMineBig end,
		function(v)
			unitsdb[Option.unit].buffFilterHelpMineBig = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.filterHelpMineBig:SetPoint("TOPLEFT", menu.filterHelpMine, "BOTTOMLEFT", 24, 24)
	menu.filterHelpMineBig:SetScale(0.9)
	menu.filterHelpCast = LBO:CreateWidget("CheckBox", parent, "Help: Able to cast", "Show my available buff for helpful target.", nil, isnotBuffUse, nil,
		function() return unitsdb[Option.unit].buffFilterHelpCast end,
		function(v)
			unitsdb[Option.unit].buffFilterHelpCast = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
			LBO:Refresh()
		end
	)
	menu.filterHelpCast:SetPoint("TOPLEFT", menu.filterHelpMine, "BOTTOMLEFT", 0, 0)
	menu.filterHelpCastBig = LBO:CreateWidget("CheckBox", parent, "Emphasize", "Emphszie my avilable buff for helpful target.", isnotMyBuff,
		function()
			return isnotBuffUse() or not unitsdb[Option.unit].buffFilterHelpCast
		end, nil,
		function() return unitsdb[Option.unit].buffFilterHelpCastBig end,
		function(v)
			unitsdb[Option.unit].buffFilterHelpCastBig = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.filterHelpCastBig:SetPoint("TOPLEFT", menu.filterHelpCast, "BOTTOMLEFT", 24, 24)
	menu.filterHelpOhter = LBO:CreateWidget("CheckBox", parent, "Help : Others", "Show other buff for helpful target.", nil, isnotBuffUse, nil,
		function() return unitsdb[Option.unit].buffFilterHelpOhter end,
		function(v)
			unitsdb[Option.unit].buffFilterHelpOhter = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
			LBO:Refresh()
		end
	)
	menu.filterHelpOhter:SetPoint("TOPLEFT", menu.filterHelpCast, "BOTTOMLEFT", 0, 0)
	menu.filterHelpOhterBig = LBO:CreateWidget("CheckBox", parent, "Emphasize", "Emphasize other buff for helpful target.", isnotMyBuff,
		function()
			return isnotBuffUse() or not unitsdb[Option.unit].buffFilterHelpOhter
		end, nil,
		function() return unitsdb[Option.unit].buffFilterHelpOhterBig end,
		function(v)
			unitsdb[Option.unit].buffFilterHelpOhterBig = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.filterHelpOhterBig:SetPoint("TOPLEFT", menu.filterHelpOhter, "BOTTOMLEFT", 24, 24)

	menu.filterHarmDispel = LBO:CreateWidget("CheckBox", parent, "Hostile: Dispellable", "Show dispellable buff for harmful target.", nil, isnotBuffUse, nil,
		function() return unitsdb[Option.unit].buffFilterHarmDispel end,
		function(v)
			unitsdb[Option.unit].buffFilterHarmDispel = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
			LBO:Refresh()
		end
	)
	menu.filterHarmDispel:SetPoint("TOPRIGHT", menu.filterLine, "BOTTOMRIGHT", 0, 20)
	menu.filterHarmDispelBig = LBO:CreateWidget("CheckBox", parent, "Emphasize", "Emphasize dispellable buff for harmful target.", isnotMyBuff,
		function()
			return isnotBuffUse() or not unitsdb[Option.unit].buffFilterHarmDispel
		end, nil,
		function() return unitsdb[Option.unit].buffFilterHarmDispelBig end,
		function(v)
			unitsdb[Option.unit].buffFilterHarmDispelBig = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.filterHarmDispelBig:SetPoint("TOPLEFT", menu.filterHarmDispel, "BOTTOMLEFT", 24, 24)
	menu.filterHarmOhter = LBO:CreateWidget("CheckBox", parent, "Hostile: Others", "Show other buff for harmful target.", nil, isnotBuffUse, nil,
		function() return unitsdb[Option.unit].buffFilterHarmOhter end,
		function(v)
			unitsdb[Option.unit].buffFilterHarmOhter = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
			LBO:Refresh()
		end
	)
	menu.filterHarmOhter:SetPoint("TOPLEFT", menu.filterHarmDispel, "BOTTOMLEFT", 0, 0)
	menu.filterHarmOhterBig = LBO:CreateWidget("CheckBox", parent, "Emphasize", "Emphasize other buff for harmful target.", isnotMyBuff,
		function()
			return isnotBuffUse() or not unitsdb[Option.unit].buffFilterHarmOhter
		end, nil,
		function() return unitsdb[Option.unit].buffFilterHarmOhterBig end,
		function(v)
			unitsdb[Option.unit].buffFilterHarmOhterBig = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.filterHarmOhterBig:SetPoint("TOPLEFT", menu.filterHarmOhter, "BOTTOMLEFT", 24, 24)

	menu.mybuff = LBO:CreateWidget("Heading", parent, "Emphasized buff", nil, isnotMyBuff, isnotBuffUse)
	menu.mybuff:SetScale(1.2)
	menu.mybuff:SetPoint("TOPLEFT", menu.filterHelpOhter, "BOTTOMLEFT", 0, 0)
	menu.mybuff:SetPoint("RIGHT", menu.filterHarmOhter, "RIGHT", 0, 0)
	menu.big = LBO:CreateWidget("Slider", parent, "Enlarge emphasized buff", "Enlarge emphasized buff.", isnotMyBuff, isnotBuffUse, nil,
		function()
			return unitsdb[Option.unit].buffBigScale * 100, 100, 200, 1, "%"
		end,
		function(v)
			unitsdb[Option.unit].buffBigScale = v / 100
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.big:SetPoint("TOPLEFT", menu.mybuff, "BOTTOMLEFT", 0, 10)
	menu.bigTexture = LBO:CreateWidget("CheckBox", parent, "Show cooldown texture", "Show or hide cooldown texture for emphasized buff.", isnotMyBuff, isnotBuffUse, nil,
		function() return not unitsdb[Option.unit].buffHiddenBigCooldownTexture end,
		function(v)
			unitsdb[Option.unit].buffHiddenBigCooldownTexture = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.bigTexture:SetPoint("TOPRIGHT", menu.mybuff, "BOTTOMRIGHT", 0, 10)
	menu.cdUse = LBO:CreateWidget("CheckBox", parent, "Show remain time", "Display remain time of emphasized buff(only remain time less than 10 min).", isnotMyBuff, isnotBuffUse, nil,
		function() return unitsdb[Option.unit].buffCooldownTextUse end,
		function(v)
			unitsdb[Option.unit].buffCooldownTextUse = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
			LBO:Refresh()
		end
	)
	menu.cdUse:SetPoint("TOP", menu.big, "BOTTOM", 0, -5)
-- 추가	
	menu.cdFullTime = LBO:CreateWidget("CheckBox", parent, "Ignore 10 min limit", "Ignor 10 min limit.", isnotMyBuff, isnotBuffUse, nil,
		function() return unitsdb[Option.unit].buffCooldownFullTime end,
		function(v)
			unitsdb[Option.unit].buffCooldownFullTime = v
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
			LBO:Refresh()
		end
	)
	menu.cdFullTime:SetPoint("TOP", menu.big, "BOTTOM", 100, -5)
-- 끝
	menu.cd = LBO:CreateWidget("Font", parent, "Remain time font", "Set font for remain time.", isnotMyBuff,
		function()
			if not isnotMyBuff() and not isnotBuffUse() then
				return not unitsdb[Option.unit].buffCooldownTextUse
			else
				return true
			end
		end, nil,
		function()
			return unitsdb[Option.unit].buffCooldownTextFontFile, unitsdb[Option.unit].buffCooldownTextFontSize, unitsdb[Option.unit].buffCooldownTextFontAttribute, unitsdb[Option.unit].buffCooldownTextFontShadow
		end,
		function(file, size, attribute, shadow)
			unitsdb[Option.unit].buffCooldownTextFontFile = file
			unitsdb[Option.unit].buffCooldownTextFontSize = size
			unitsdb[Option.unit].buffCooldownTextFontAttribute = attribute
			unitsdb[Option.unit].buffCooldownTextFontShadow = shadow
			setCoreValue(Option.unit, "UpdateSkinAura", "buff")
		end
	)
	menu.cd:SetPoint("TOPRIGHT", menu.bigTexture, "BOTTOMRIGHT", 0, 2)
end

function Option:CreateUnitDebuffMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "Show debuff", "Show or hide debuff.", nil, notActiveObject, nil,
		function() return unitsdb[Option.unit].debuffUse end,
		function(v)
			unitsdb[Option.unit].debuffUse = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
			LBO:Refresh()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, -5)
	local function isnotDebuffUse()
		if notActiveObject() then
			return true
		else
			return not unitsdb[Option.unit].debuffUse
		end
	end
	menu.num = LBO:CreateWidget("Slider", parent, "Debuff number to display", "Number of debuff to display.", nil, isnotDebuffUse, nil,
		function() return unitsdb[Option.unit].debuffNum, 0, 40, 1, "개" end,
		function(v)
			unitsdb[Option.unit].debuffNum = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.num:SetPoint("TOPRIGHT", -5, -5)
	menu.pos = LBO:CreateWidget("DropDown", parent, "Debuff position", "Set debuff position.", nil, isnotDebuffUse, nil,
		function()
			return auraPositions[unitsdb[Option.unit].debuffPos or "TOP"] or 1, auraPositionList
		end,
		function(v)
			unitsdb[Option.unit].debuffPos = auraPositions[v] or "TOP"
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, 10)
	menu.small = LBO:CreateWidget("Slider", parent, "Debuff size", "Set debuff size of other players.", nil, isnotDebuffUse, nil,
		function()
			return unitsdb[Option.unit].debuffSmallSize, 10, 40, 1, "pixel"
		end,
		function(v)
			unitsdb[Option.unit].debuffSmallSize = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.small:SetPoint("TOP", menu.pos, "BOTTOM", 0, -10)
	menu.countSize = LBO:CreateWidget("Slider", parent, "Font size for stack", "Set stack font size.", nil, isnotDebuffUse, nil,
		function()
			return unitsdb[Option.unit].debuffCountTextFontSize, 7, 37, 1, "point"
		end,
		function(v)
			unitsdb[Option.unit].debuffCountTextFontSize = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.countSize:SetPoint("TOP", menu.small, "TOP", 0, 0)
	menu.countSize:SetPoint("RIGHT", menu.num, "RIGHT", 0, 0)
	menu.smallTexture = LBO:CreateWidget("CheckBox", parent, "Show cooldown texture", "Show or hide cooldown texture of other player's debuff.", nil, isnotDebuffUse, nil,
		function() return not unitsdb[Option.unit].debuffHiddenSmallCooldownTexture end,
		function(v)
			unitsdb[Option.unit].debuffHiddenSmallCooldownTexture = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.smallTexture:SetPoint("TOP", menu.small, "BOTTOM", 0, 5)
	menu.line = LBO:CreateWidget("CheckBox", parent, "Auto linefeed", "Auto linefeed by frame size.", nil, isnotDebuffUse, nil,
		function() return not unitsdb[Option.unit].debuffSkipLine end,
		function(v)
			unitsdb[Option.unit].debuffSkipLine = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.line:SetPoint("TOP", menu.countSize, "BOTTOM", 0, 5)
	local function isnotMyDebuff()
		if notActiveObject() then
			return true
		else
			return Option.unit ~= "player" and Option.unit ~= "target" and Option.unit ~= "focus" and Option.unit ~= "party" and Option.unit ~= "boss"
		end
	end

	menu.filterLine = LBO:CreateWidget("Heading", parent, "Debuff Filtering", nil, nil, isnotDebuffUse)
	menu.filterLine:SetScale(1.2)
	menu.filterLine:SetPoint("TOPLEFT", menu.small, "BOTTOMLEFT", 0, -18)
	menu.filterLine:SetPoint("TOPRIGHT", menu.countSize, "BOTTOMRIGHT", 0, -18)

	menu.filterHarmMine = LBO:CreateWidget("CheckBox", parent, "Hostile: My cast", "Show my debuff for harmful target.", nil, isnotDebuffUse, nil,
		function() return unitsdb[Option.unit].debuffFilterHarmMine end,
		function(v)
			unitsdb[Option.unit].debuffFilterHarmMine = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
			LBO:Refresh()
		end
	)
	menu.filterHarmMine:SetPoint("TOPLEFT", menu.filterLine, "BOTTOMLEFT", 0, 20)
	menu.filterHarmMineBig = LBO:CreateWidget("CheckBox", parent, "Emphasize", "Emphasize my debuff for harmful target.", isnotMyDebuff,
		function()
			return isnotDebuffUse() or not unitsdb[Option.unit].debuffFilterHarmMine
		end, nil,
		function() return unitsdb[Option.unit].debuffFilterHarmMineBig end,
		function(v)
			unitsdb[Option.unit].debuffFilterHarmMineBig = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.filterHarmMineBig:SetPoint("TOPLEFT", menu.filterHarmMine, "BOTTOMLEFT", 24, 24)
	menu.filterHarmMineBig:SetScale(0.9)
	menu.filterHarmCast = LBO:CreateWidget("CheckBox", parent, "Hostile: Able to cast", "Show my available debuff for harmful target.", nil, isnotDebuffUse, nil,
		function() return unitsdb[Option.unit].debuffFilterHarmCast end,
		function(v)
			unitsdb[Option.unit].debuffFilterHarmCast = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
			LBO:Refresh()
		end
	)
	menu.filterHarmCast:SetPoint("TOPLEFT", menu.filterHarmMine, "BOTTOMLEFT", 0, 0)
	menu.filterHarmCastBig = LBO:CreateWidget("CheckBox", parent, "Emphasize", "Emphasize my available debuff for harmful target.", isnotMyDebuff,
		function()
			return isnotDebuffUse() or not unitsdb[Option.unit].debuffFilterHarmCast
		end, nil,
		function() return unitsdb[Option.unit].debuffFilterHarmCastBig end,
		function(v)
			unitsdb[Option.unit].debuffFilterHarmCastBig = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.filterHarmCastBig:SetPoint("TOPLEFT", menu.filterHarmCast, "BOTTOMLEFT", 24, 24)
	menu.filterHarmOhter = LBO:CreateWidget("CheckBox", parent, "Hostile: Other", "Show other debuff for harmful target.", nil, isnotDebuffUse, nil,
		function() return unitsdb[Option.unit].debuffFilterHarmOhter end,
		function(v)
			unitsdb[Option.unit].debuffFilterHarmOhter = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
			LBO:Refresh()
		end
	)
	menu.filterHarmOhter:SetPoint("TOPLEFT", menu.filterHarmCast, "BOTTOMLEFT", 0, 0)
	menu.filterHarmOhterBig = LBO:CreateWidget("CheckBox", parent, "Emphasize", "Emphasize other debuff for harmful target.", isnotMyDebuff,
		function()
			return isnotDebuffUse() or not unitsdb[Option.unit].debuffFilterHarmOhter
		end, nil,
		function() return unitsdb[Option.unit].debuffFilterHarmOhterBig end,
		function(v)
			unitsdb[Option.unit].debuffFilterHarmOhterBig = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.filterHarmOhterBig:SetPoint("TOPLEFT", menu.filterHarmOhter, "BOTTOMLEFT", 24, 24)

	menu.filterHelpDispel = LBO:CreateWidget("CheckBox", parent, "Help : Dispellable", "Show debuffs for helpful targets.", nil, isnotDebuffUse, nil,
		function() return unitsdb[Option.unit].debuffFilterHelpDispel end,
		function(v)
			unitsdb[Option.unit].debuffFilterHelpDispel = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
			LBO:Refresh()
		end
	)
	menu.filterHelpDispel:SetPoint("TOPRIGHT", menu.filterLine, "BOTTOMRIGHT", 0, 20)
	menu.filterHelpDispelBig = LBO:CreateWidget("CheckBox", parent, "Emphasize", "Emphasize debuffs for helpful targets.", isnotMyDebuff,
		function()
			return isnotDebuffUse() or not unitsdb[Option.unit].debuffFilterHelpDispel
		end, nil,
		function() return unitsdb[Option.unit].debuffFilterHelpDispelBig end,
		function(v)
			unitsdb[Option.unit].debuffFilterHelpDispelBig = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.filterHelpDispelBig:SetPoint("TOPLEFT", menu.filterHelpDispel, "BOTTOMLEFT", 24, 24)
	menu.filterHelpOhter = LBO:CreateWidget("CheckBox", parent, "Help : Others", "Display other debuffs for helpful targets.", nil, isnotDebuffUse, nil,
		function() return unitsdb[Option.unit].debuffFilterHelpOhter end,
		function(v)
			unitsdb[Option.unit].debuffFilterHelpOhter = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
			LBO:Refresh()
		end
	)
	menu.filterHelpOhter:SetPoint("TOPLEFT", menu.filterHelpDispel, "BOTTOMLEFT", 0, 0)
	menu.filterHelpOhterBig = LBO:CreateWidget("CheckBox", parent, "Emphasize", "Emphasize other debuffs for helpful targets.", isnotMyDebuff,
		function()
			return isnotDebuffUse() or not unitsdb[Option.unit].debuffFilterHelpOhter
		end, nil,
		function() return unitsdb[Option.unit].debuffFilterHelpOhterBig end,
		function(v)
			unitsdb[Option.unit].debuffFilterHelpOhterBig = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.filterHelpOhterBig:SetPoint("TOPLEFT", menu.filterHelpOhter, "BOTTOMLEFT", 24, 24)

	menu.mydebuff = LBO:CreateWidget("Heading", parent, "Emphasized debuff", nil, isnotMyDebuff, isnotDebuffUse)
	menu.mydebuff:SetScale(1.2)
	menu.mydebuff:SetPoint("TOPLEFT", menu.filterHarmOhter, "BOTTOMLEFT", 0, 0)
	menu.mydebuff:SetPoint("RIGHT", menu.filterHelpOhter, "RIGHT", 0, 0)
	menu.big = LBO:CreateWidget("Slider", parent, "Enlarge emphasized debuff", "Enlarge emphasized debuff.", isnotMyDebuff, isnotDebuffUse, nil,
		function()
			return unitsdb[Option.unit].debuffBigScale * 100, 100, 200, 1, "%"
		end,
		function(v)
			unitsdb[Option.unit].debuffBigScale = v / 100
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.big:SetPoint("TOPLEFT", menu.mydebuff, "BOTTOMLEFT", 0, 10)
	menu.bigTexture = LBO:CreateWidget("CheckBox", parent, "Show cooldown texture", "Show or hide cooldown texture of emphasized debuff.", isnotMyDebuff, isnotDebuffUse, nil,
		function() return not unitsdb[Option.unit].debuffHiddenBigCooldownTexture end,
		function(v)
			unitsdb[Option.unit].debuffHiddenBigCooldownTexture = not v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.bigTexture:SetPoint("TOPRIGHT", menu.mydebuff, "BOTTOMRIGHT", 0, 10)
	menu.cdUse = LBO:CreateWidget("CheckBox", parent, "Show remain time", "Show remain time of emphasized debuff.Only shows remain time less than 10 min.", isnotMyDebuff, isnotDebuffUse, nil,
		function() return unitsdb[Option.unit].debuffCooldownTextUse end,
		function(v)
			unitsdb[Option.unit].debuffCooldownTextUse = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
			LBO:Refresh()
		end
	)
	menu.cdUse:SetPoint("TOP", menu.big, "BOTTOM", 0, -5)
-- 추가	
	menu.cdFullTime = LBO:CreateWidget("CheckBox", parent, "Ignore 10 min limit", "Ignore 10 min left display.", isnotMyDebuff, isnotDebuffUse, nil,
		function() return unitsdb[Option.unit].debuffCooldownFullTime end,
		function(v)
			unitsdb[Option.unit].debuffCooldownFullTime = v
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
			LBO:Refresh()
		end
	)
	menu.cdFullTime:SetPoint("TOP", menu.big, "BOTTOM", 100, -5)
-- 끝
	menu.cd = LBO:CreateWidget("Font", parent, "Remain time font", "Set remain time font for highlighed debuff.", isnotMyDebuff,
		function()
			if not isnotMyDebuff() and not isnotDebuffUse() then
				return not unitsdb[Option.unit].debuffCooldownTextUse
			else
				return true
			end
		end, nil,
		function()
			return unitsdb[Option.unit].debuffCooldownTextFontFile, unitsdb[Option.unit].debuffCooldownTextFontSize, unitsdb[Option.unit].debuffCooldownTextFontAttribute, unitsdb[Option.unit].debuffCooldownTextFontShadow
		end,
		function(file, size, attribute, shadow)
			unitsdb[Option.unit].debuffCooldownTextFontFile = file
			unitsdb[Option.unit].debuffCooldownTextFontSize = size
			unitsdb[Option.unit].debuffCooldownTextFontAttribute = attribute
			unitsdb[Option.unit].debuffCooldownTextFontShadow = shadow
			setCoreValue(Option.unit, "UpdateSkinAura", "debuff")
		end
	)
	menu.cd:SetPoint("TOPRIGHT", menu.bigTexture, "BOTTOMRIGHT", 0, 2)
end

function Option:CreateUnitTextMenu(menu, parent)
	local function hideTextOption(key)
		if Option.unit and type(unitsdb[Option.unit][key]) == "string" and unitsdb[Option.unit][key]:find("^return ") then
			return nil
		else
			return true
		end
	end
	local function getFont(key)
		return unitsdb[Option.unit][key.."FontFile"], unitsdb[Option.unit][key.."FontSize"], unitsdb[Option.unit][key.."FontAttribute"], unitsdb[Option.unit][key.."FontShadow"]
	end
	local function setFont(file, size, attribute, shadow, key)
		unitsdb[Option.unit][key.."FontFile"] = file
		unitsdb[Option.unit][key.."FontSize"] = size
		unitsdb[Option.unit][key.."FontAttribute"] = attribute
		unitsdb[Option.unit][key.."FontShadow"] = shadow
		updateFontString(Option.unit, key)
	end
	menu.name = LBO:CreateWidget("Font", parent, "Name font", "Set name text font.", hideTextOption, notActiveObject, nil, getFont, setFont, "nameText")
	menu.name:SetPoint("TOPLEFT", 5, -5)
	menu.classColor = LBO:CreateWidget("CheckBox", parent, "Class color for text", "Set cUse class color for name.", hideTextOption, notActiveObject, nil,
		function() return unitsdb[Option.unit].nameTextClassColor end,
		function(v)
			unitsdb[Option.unit].nameTextClassColor = v
			setObjectElementValue(Option.unit, "nameText", "classColor", v)
			setCoreValue(Option.unit, "TriggerCallback", "NameColor")
		end,
	"nameText")
	menu.classColor:SetPoint("TOPRIGHT", -5, -5)
	menu.level = LBO:CreateWidget("Font", parent, "Level font", "Set level text font.", hideTextOption, notActiveObject, nil, getFont, setFont, "levelText")
	menu.level:SetPoint("TOP", menu.name, "BOTTOM", 0, -10)
	menu.state = LBO:CreateWidget("Font", parent, "Status font", "Set status like AFK or offline.", hideTextOption, notActiveObject, nil, getFont, setFont, "stateText")
	menu.state:SetPoint("TOP", menu.classColor, "BOTTOM", 0, -10)
	menu.class = LBO:CreateWidget("Font", parent, "Class font", "Set font for class.", hideTextOption, notActiveObject, nil, getFont, setFont, "classText")
	menu.class:SetPoint("TOP", menu.level, "BOTTOM", 0, -10)
end

function Option:CreateDispelMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "Highlight dispellable debuff", "Highlight frame at dispellable debuff.", nil, nil, nil,
		function() return IUF.db.dispel.active end,
		function(v)
			IUF.db.dispel.active = v
			for unit in pairs(IUF.db.units) do
				setCoreValue(unit, "TriggerCallback", "Dispel")
			end
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
	menu.alpha = LBO:CreateWidget("Slider", parent, "Opacity", "Set debuff highligh opacity.", nil, nil, nil,
		function() return IUF.db.dispel.alpha * 100, 0, 100, 1, "%" end,
		function(v)
			IUF.db.dispel.alpha = v / 100
			for unit in pairs(IUF.db.units) do
				setObjectElementValue(unit, "dispelFrame", "SetAlpha", IUF.db.dispel.alpha)
			end
		end
	)
	menu.alpha:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)

end

local function notActivePlayerUnit()
	return not IUF.db.units.player.active
end

function Option:CreateHealMenu(menu, parent)
	menu.use = LBO:CreateWidget("CheckBox", parent, "Show heal prediction", "Show heal prediction.", nil, nil, nil,
		function() return IUF.db.heal.active end,
		function(v)
			IUF.db.heal.active = v
			for _, object in pairs(IUF.units) do
				IUF.callbacks.Heal(object)
			end
			LBO:Refresh(parent)
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)
	local function notActive()
		return not IUF.db.heal.active
	end
	menu.player = LBO:CreateWidget("CheckBox", parent, "Show my heal", "Show player's heal amount at prediction.", nil, notActive, nil,
		function() return IUF.db.heal.player end,
		function(v)
			IUF.db.heal.player = v
			for _, object in pairs(IUF.units) do
				if UnitExists(object.unit or "") then
					IUF.handlers.UNIT_HEAL_PREDICTION(object)
				end
			end
		end
	)
	menu.player:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)
	menu.alpha = LBO:CreateWidget("Slider", parent, "Opacity", "Set heal prediction opacity.", nil, notActive, nil,
		function() return IUF.db.heal.alpha * 100, 0, 80, 1, "%" end,
		function(v)
			IUF.db.heal.alpha = v / 100
			for _, object in pairs(IUF.units) do
				IUF.callbacks.Heal(object)
			end
		end
	)
	menu.alpha:SetPoint("TOPRIGHT", -5, -39)
end

function Option:CreateClassBarMenu(menu, parent)
	local function updateClassBar()
		if IUF.units.player.classBar then
			IUF:SetObjectElementSkin(IUF.units.player, "classBar")
		end
	end

	local function notActive()
		return not IUF.db.classBar.use
	end

	menu.use = LBO:CreateWidget("CheckBox", parent, "Use class bar", "Show class specific bar.", nil, nil, nil,
		function() return IUF.db.classBar.use end,
		function(v)
			IUF.db.classBar.use = v
			LBO:Refresh(parent)
			updateClassBar()
		end
	)
	menu.use:SetPoint("TOPLEFT", 5, 5)

	local tvb = { "위쪽", "아래쪽" }
	menu.pos = LBO:CreateWidget("DropDown", parent, "Class bar position", "Set class bar position.", nil, notActive, nil,
		function() return IUF.db.classBar.pos == "TOP" and 1 or 2, tvb end,
		function(v)
			IUF.db.classBar.pos = v == 1 and "TOP" or "BOTTOM"
			updateClassBar()
		end
	)
	menu.pos:SetPoint("TOP", menu.use, "BOTTOM", 0, 0)

	menu.texture = LBO:CreateWidget("Media", parent, "Bar texture", "Set texture of all class bar.", nil, notActive, nil,
		function()
			return IUF.db.classBar.texture or "Smooth v2", "statusbar"
		end,
		function(v)
			IUF.db.classBar.texture = v
			updateClassBar()
		end
	)
	menu.texture:SetPoint("TOPRIGHT", -5, -39)

	menu.blizzard = LBO:CreateWidget("CheckBox", parent, "Display WoW default class bar", "Use Wow defualt classbar instead of Inven Unit Frame.", nil, notActive, nil,
		function()
			return IUF.db.classBar.useBlizzard
		end,
		function(v)
			IUF.db.classBar.useBlizzard = v
			updateClassBar()
		end
	)
	menu.blizzard:SetPoint("TOP", menu.pos, "BOTTOM", 0, -10)
-- 추가된 내용	
	menu.druidMana = LBO:CreateWidget("CheckBox", parent, "Hide mana while feral form", "Hide mana while non-mana form.", nil, nil, nil,
		function() return IUF.db.classBar.druidManaDisible end,
		function(v)
			IUF.db.classBar.druidManaDisible = v
			LBO:Refresh(parent)
			updateClassBar()
		end
	)
	menu.druidMana:SetPoint("TOP", menu.blizzard, "BOTTOM", 0, -10)
end