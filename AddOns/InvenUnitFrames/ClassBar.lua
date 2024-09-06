local IUF = InvenUnitFrames
local playerClass = select(2, UnitClass("player"))
local SM = LibStub("LibSharedMedia-3.0")

local _G = _G
local select = _G.select
local floor = _G.floor
local unpack = _G.unpack
local min = _G.math.min
local GetTime = _G.GetTime
local GetSpellInfo = _G.GetSpellInfo
local GetTotemInfo = _G.GetTotemInfo
local GetTotemTimeLeft = _G.GetTotemTimeLeft

local classBarBorderColor = { 0.45, 0.45, 0.45, 1 }

local PALADINPOWERBAR_SHOW_LEVEL = PALADINPOWERBAR_SHOW_LEVEL or 10
local function _UnitHasVehicleUI(unit)
	return false
end
local UnitHasVehicleUI = _G.UnitHasVehicleUI or _UnitHasVehicleUI

local function _GetPrimaryTalentTree()
	return 0
end
local GetSpecialization = _G.GetSpecialization or _GetSpecialization
		
local function setClassBar(frame, object, frameLevel, visible)
	frame:SetParent(object)
	frame:SetFrameLevel(frameLevel or object.classBar:GetFrameLevel())
	if visible then
		frame:HookScript("OnShow", visible)
		frame:HookScript("OnHide", visible)
	end
	frame:SetToplevel(false)
	if frame == TotemFrame then
		local totem, totemChild, totemChildWidth, totemChildHeight, totemChildTexture
		for i = 1, MAX_TOTEMS do
			totem = _G["TotemFrameTotem"..i]
			for j = 1, select("#", totem:GetChildren()) do
				totemChild = select(j, totem:GetChildren())
				if not totemChild:GetName() then
					totemChildWidth = floor(totemChild:GetWidth() + 0.1)
					totemChildHeight = floor(totemChild:GetHeight() + 0.1)
					if totemChildWidth == 38 and totemChildWidth == totemChildHeight then
						for k = 1, select("#", totemChild:GetRegions()) do
							totemChildTexture = select(k, totemChild:GetRegions())
							if totemChildTexture:GetObjectType() == "Texture" and totemChildTexture:GetDrawLayer() == "OVERLAY" then
								totemChild:SetSize(32, 32)
								totemChildTexture:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\CircleBorder")
								break
							end
						end
						break
					end
				end
			end
		end
		TotemFrameTotem2:ClearAllPoints()
		TotemFrameTotem1:ClearAllPoints()
		TotemFrameTotem1:SetPoint("RIGHT", TotemFrameTotem2, "LEFT", 4, 0)
	end
end

local function createClassBar(object)
	object:SetFrameLevel(4)
	object.classBar = CreateFrame("Frame", object:GetName().."_ClassBar", object)
	object.classBar:SetFrameLevel(3)
end

local function updateTotemDurationText()
	local totem
	if IUF.db.classBar.pos == "TOP" then
		for i = 1, MAX_TOTEMS do
			totem = _G["TotemFrameTotem"..i]
			duration = _G["TotemFrameTotem"..i.."Duration"]
			if duration then
				duration:ClearAllPoints()
				duration:SetPoint("BOTTOM", totem, "TOP", 0, -4)
			end
		end
	else
		for i = 1, MAX_TOTEMS do
			totem = _G["TotemFrameTotem"..i]
			duration = _G["TotemFrameTotem"..i.."Duration"]
			if duration then
				duration:ClearAllPoints()
				duration:SetPoint("TOP", totem, "BOTTOM", 0, 5)
			end
		end
	end
end

local function createAddOnClassBar(object)
	local f = CreateFrame("Frame", nil, object)
	f:SetFrameLevel(5)
	f:SetHeight(16)
	object.classBar.addOn = f
	f.bg = f:CreateTexture(nil, "BACKGROUND", nil, -5)
	f.bg:SetAllPoints()
	f.bg:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
	f.bg:SetVertexColor(0, 0, 0, 1)
	return f
end

local function updateAddOnBorder(f)
	local w = (floor(f:GetWidth() + 0.1) - 2) / f.num
	if w ~= f.width then
		f.width = w
		local m, M, cur
		for i = 1, f.num do
			if not f.anchors[i] then
				f.anchors[i] = f:CreateTexture(nil, "BACKGROUND", nil, 0)
				f.anchors[i]:SetHeight(f.height - 4)
				if f.needStatusBar then
					f.anchors[i].bar = CreateFrame("StatusBar", nil, f)
					f.anchors[i].bar:SetFrameLevel(f:GetFrameLevel())
					f.anchors[i].bar:SetID(i)
					f.anchors[i].bar:SetStatusBarTexture(SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2"))
					f.anchors[i].bar:SetStatusBarColor(1, 0.82, 0)
					f.anchors[i].bar:SetMinMaxValues(0, 1)
					f.anchors[i].bar:SetValue(1)
					f.anchors[i].bar.text = f.anchors[i].bar:CreateFontString(nil, "OVERLAY", "FriendsFont_Small")
					f.anchors[i].bar.text:SetPoint("CENTER", 0, 0)
					if f.needStatusBarIcon then
						f.anchors[i].bar:SetPoint("TOPLEFT", f.anchors[i], "TOPLEFT", f.height - 5, 0)
						f.anchors[i].bar:SetPoint("BOTTOMRIGHT", f.anchors[i], "BOTTOMRIGHT", 0, 0)
						f.anchors[i].bar.icon = f.anchors[i].bar:CreateTexture(nil, "BORDER")
						f.anchors[i].bar.icon:SetSize(f.height - 4, f.height - 4)
						f.anchors[i].bar.icon:SetPoint("TOPLEFT", f.anchors[i], "TOPLEFT", -1, 0)
						f.anchors[i].bar.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
					else
						f.anchors[i].bar:SetAllPoints(f.anchors[i])
					end
					f.anchors[i].bar.click = CreateFrame("Button", nil, f.anchors[i].bar)
					f.anchors[i].bar.click:SetAllPoints(f.anchors[i])
					f.anchors[i].bar.click:SetFrameLevel(f:GetFrameLevel() + 1)
					f.anchors[i].bar.click:SetID(i)
				else
					--f.anchors[i]:SetTexture(1, 1, 1)
				end
				if i == 1 then
					f.anchors[i]:SetPoint("TOPLEFT", 2, -2)
				else
					f.anchors[i]:SetPoint("TOPLEFT", f.anchors[i - 1], "TOPRIGHT", 2, 0)
					f.anchors[i].s = f:CreateTexture(nil, "ARTWORK")
					f.anchors[i].s:SetSize(f.height, f.height)
					f.anchors[i].s:SetPoint("CENTER", f.anchors[i], "LEFT", 0, 0)
					f.anchors[i].s:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\SmallIconBorder3")
					f.anchors[i].s:SetVertexColor(unpack(classBarBorderColor))
				end
			end
			f.anchors[i]:Show()
			f.anchors[i]:SetWidth(w - 2)
			if f.anchors[i].s then
				f.anchors[i].s:Show()
			end
			if f.anchors[i].bar then
				f.anchors[i].bar:Show()
				m, M = f.anchors[i].bar:GetMinMaxValues()
				cur = f.anchors[i].bar:GetValue()
				f.anchors[i].bar:SetMinMaxValues(m - 1, M + 1)
				f.anchors[i].bar:SetValue(cur + 1)
				f.anchors[i].bar:SetMinMaxValues(m, M)
				f.anchors[i].bar:SetValue(cur)
			end
		end
		for i = f.num + 1, #f.anchors do
			f.anchors[i]:Hide()
			if f.anchors[i].s then
				f.anchors[i].s:Hide()
			end
			if f.anchors[i].bar then
				f.anchors[i].bar:Hide()
			end
		end
	end
end

local function setAddOnBorder(f, num, statusBar, statusBarIcon)
	if not f.anchors then
		f:EnableMouse(true)
		f.anchors, f.height = {}, floor(f:GetHeight() + 0.1)
		f.needStatusBar, f.needStatusBarIcon = statusBar, statusBar and statusBarIcon
		local bgLeft = f:CreateTexture(nil, "ARTWORK")
		bgLeft:SetSize(f.height / 2, f.height)
		bgLeft:SetPoint("TOPLEFT", 0, 0)
		bgLeft:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\SmallIconBorder")
		bgLeft:SetTexCoord(0, 0.5, 0, 1)
		bgLeft:SetVertexColor(unpack(classBarBorderColor))
		local bgRight = f:CreateTexture(nil, "ARTWORK")
		bgRight:SetSize(f.height / 2, f.height)
		bgRight:SetPoint("TOPRIGHT", 0, 0)
		bgRight:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\SmallIconBorder")
		bgRight:SetTexCoord(0.5, 1, 0, 1)
		bgRight:SetVertexColor(unpack(classBarBorderColor))
		local bgMid = f:CreateTexture(nil, "ARTWORK")
		bgMid:SetPoint("TOPLEFT", bgLeft, "TOPRIGHT", 0, 0)
		bgMid:SetPoint("BOTTOMRIGHT", bgRight, "BOTTOMLEFT", 0, 0)
		bgMid:SetTexture("Interface\\AddOns\\InvenUnitFrames\\Texture\\SmallIconBorder")
		bgMid:SetTexCoord(0.35, 0.65, 0, 1)
		bgMid:SetVertexColor(unpack(classBarBorderColor))
		f:SetScript("OnSizeChanged", updateAddOnBorder)
		f:SetScript("OnShow", updateAddOnBorder)
	end
	f.num = num or 1
	updateAddOnBorder(f)
end

function secondsToTime(seconds)
	if seconds >= 86400 then
		return ceil(seconds / 86400).."d"
	elseif seconds >= 3600 then
		return ceil(seconds / 86400).."h"
	elseif seconds >= 60 then
		return ceil(seconds / 60).."m"
	else
		return floor(seconds + 0.5)
	end
end

local function createTotem(object, num, pos, shown)
	object.totem = CreateFrame("Frame", nil, object)
	pos = pos or "TOP"
	object.totem:SetPoint(pos.."LEFT", 0, 0)
	object.totem:SetPoint(pos.."RIGHT", 0, 0)
	object.totem:SetHeight(14)
	object.totem:SetFrameLevel(object:GetFrameLevel())
	num = min(num or MAX_TOTEMS, MAX_TOTEMS)
	setAddOnBorder(object.totem, num, true, true)

	local function updateTotem(anchors, i)
		anchors[i].bar.timeLeft = GetTotemTimeLeft(anchors[i].bar:GetID())
		anchors[i].bar:SetValue(anchors[i].bar.timeLeft)
		anchors[i].bar.text:SetText(secondsToTime(anchors[i].bar.timeLeft))
	end

	object.totem:SetScript("OnEvent", function(self)
		local visible, haveTotem, name, icon
		for i = 1, self.num do
			haveTotem, name, self.anchors[i].bar.startTime, self.anchors[i].bar.duration, icon = GetTotemInfo(self.anchors[i].bar:GetID())
			if haveTotem and self.anchors[i].bar.duration > 0 then
				visible = true
				self.anchors[i].bar:Show()
				self.anchors[i].bar.icon:SetTexture(icon)
				self.anchors[i].bar:SetMinMaxValues(0, self.anchors[i].bar.duration)
				updateTotem(self.anchors, i)
			else
				self.anchors[i].bar:Hide()
				self.anchors[i].bar.startTime, self.anchors[i].bar.duration, self.anchors[i].bar.timeLeft = nil
			end
		end
		if visible then
			self:Show()
		else
			self:Hide()
		end
	end)

	local function totemOnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		GameTooltip:SetTotem(self:GetID())
	end

	for i = 1, object.totem.num do
		object.totem.anchors[i].bar.click:SetScript("OnEnter", totemOnEnter)
		object.totem.anchors[i].bar.click:SetScript("OnLeave", GameTooltip_Hide)
	end

	object.totem.onEvent = object.totem:GetScript("OnEvent")
	object.totem:RegisterEvent("PLAYER_TOTEM_UPDATE")
	object.totem:RegisterEvent("PLAYER_ENTERING_WORLD")
	object.totem:Hide()
	object.totem:SetScript("OnUpdate", function(self, timer)
		self.timer = (self.timer or 0) + timer
		if self.timer > 0.1 then
			self.timer = 0
			for i = 1, self.num do
				if self.anchors[i].bar.duration then
					updateTotem(self.anchors, i)
				end
			end
		end
	end)
	if shown then
		object.totem:SetScript("OnShow", shown)
		object.totem:SetScript("OnHide", shown)
	end
end

local function findBuffById(id, filter)
	local name, rank = GetSpellInfo(id)
	--if name then
		local buff=select(10,AuraUtil.FindAuraByName(name,"player"))
		--local buff = select(10, UnitBuff("player", name, rank, filter))

		if buff == id then
			return true
--[[
		elseif buff then
			rank = 1
			buff = select(10, UnitBuff("player", rank, filter))
			while buff do
				if buff == id then
					return true
				end
				rank = rank + 1
				buff = select(10, UnitBuff("player", rank, filter))
			end
--]]
		end
	--end
	return nil
end

if playerClass == "DRUID" then
	local function updateVisible()	-- DRUID
	
	local hideMana = false
	if (GetShapeshiftFormID() == CAT_FORM or GetShapeshiftFormID() == BEAR_FORM) then
		if IUF.db.classBar.druidManaDisible then
			hideMana = true
			if not IUF.units.player.classBar.addOn.mana:IsShown() then
				IUF.units.player.classBar.addOn.mana.max, IUF.units.player.classBar.addOn.mana.cur = UnitPowerMax("player", 0), UnitPower("player", 0)
				IUF.units.player.classBar.addOn.mana.anchors[1].bar:SetMinMaxValues(0, IUF.units.player.classBar.addOn.mana.max)
				IUF.units.player.classBar.addOn.mana.anchors[1].bar:SetValue(IUF.units.player.classBar.addOn.mana.cur)
				IUF:SetStatusBarValue(IUF.units.player.classBar.addOn.mana.text, 2, IUF.units.player.classBar.addOn.mana.cur, IUF.units.player.classBar.addOn.mana.max)
				IUF.units.player.classBar.addOn.mana:Show()
				IUF.units.player.classBar.addOn.mana:RegisterUnitEvent("UNIT_MAXPOWER", "player")
				IUF.units.player.classBar.addOn.mana:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
				IUF.units.player.classBar.addOn.mana:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
			end
		end
	else
		if GetPrimaryTalentTree() == 1 then	--         Ŀ ǥ               ٰ       .
				else
			hideMana = true
		end
	end
	
		if IUF.db.classBar.use then
			if hideMana then
				IUF.units.player.classBar.addOn.mana:SetAlpha(0)
				IUF.units.player.classBar.addOn.bg:SetAlpha(0)
			else
				IUF.units.player.classBar.addOn.mana:SetAlpha(1)
				IUF.units.player.classBar.addOn.bg:SetAlpha(1)
			end

			if IUF.db.classBar.useBlizzard and TotemFrame  then
				if TotemFrame:IsShown() then
					IUF.units.player.classBar:SetAlpha(1)

 					if EclipseBarFrame:IsShown() then
 						PlayerFrameAlternateManaBar:SetAlpha(0)
 						IUF.units.player.classBar:SetHeight(64)
 					else
  						if PlayerFrameAlternateManaBar:IsShown() then
  							PlayerFrameAlternateManaBar:SetAlpha(1)
  							IUF.units.player.classBar:SetHeight(57)
 						else
  							IUF.units.player.classBar:SetHeight(42)
						end
  					 
					end
 
 				elseif EclipseBarFrame:IsShown() then
 					IUF.units.player.classBar:SetAlpha(1)
 					PlayerFrameAlternateManaBar:SetAlpha(0)
 					IUF.units.player.classBar:SetHeight(30)
  				elseif PlayerFrameAlternateManaBar:IsShown() then
  					IUF.units.player.classBar:SetAlpha(1)
  					IUF.units.player.classBar:SetHeight(13)
  					PlayerFrameAlternateManaBar:SetAlpha(1)
  				else
					IUF.units.player.classBar:SetAlpha(0)
					IUF.units.player.classBar:SetHeight(0.001)
				end

			elseif IUF.units.player.classBar.addOn.totem:IsShown() then
				if IUF.units.player.classBar.addOn.mana:IsShown() or IUF.units.player.classBar.addOn.eclipse:IsShown() then
					IUF.units.player.classBar:SetHeight(29)
					IUF.units.player.classBar.addOn:SetHeight(28)
				else
					IUF.units.player.classBar:SetHeight(15)
					IUF.units.player.classBar.addOn:SetHeight(14)
				end
			elseif IUF.units.player.classBar.addOn.mana:IsShown() or IUF.units.player.classBar.addOn.eclipse:IsShown() or IUF.units.player.classBar.addOn.totem:IsShown() then
				IUF.units.player.classBar:SetHeight(15)
				IUF.units.player.classBar.addOn:SetHeight(14)
			else
				IUF.units.player.classBar:SetHeight(0.001)
				IUF.units.player.classBar.addOn:SetHeight(0.001)
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- DRUID
		createClassBar(object)
		object = createAddOnClassBar(object)

		local abs = _G.math.abs
		local max = _G.math.max
		local UnitPower = _G.UnitPower
		local UnitPowerMax = _G.UnitPowerMax
		local UnitPowerType = _G.UnitPowerType
		local GetShapeshiftFormID = _G.GetShapeshiftFormID
		local GetEclipseDirection = _G.GetEclipseDirection

		local ECLIPSE_MARKER_COORDS = {
			none = { 0.914, 1.0, 0.82, 1.0 },
			sun = { 0.914, 1.0, 0.641, 0.82 },
			moon = { 1.0, 0.914, 0.641, 0.82 },
		};
		local ECLIPSE_BAR_SOLAR_BUFF_ID = 48517--171744	--  ¾       
		local ECLIPSE_BAR_LUNAR_BUFF_ID = 48518--171743	--          
		local ECLIPSE_BAR_SOLAR_BUFF = GetSpellInfo(ECLIPSE_BAR_SOLAR_BUFF_ID)
		local ECLIPSE_BAR_LUNAR_BUFF = GetSpellInfo(ECLIPSE_BAR_LUNAR_BUFF_ID)

		object.mana = CreateFrame("Frame", nil, object)
		object.mana:SetPoint("TOPLEFT", 0, 0)
		object.mana:SetPoint("TOPRIGHT", 0, 0)
		object.mana:SetHeight(14)
		object.mana:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.mana, 1, true)
		object.mana.text = object.mana:CreateFontString(nil, "OVERLAY", "FriendsFont_Small")
		object.mana.text:SetPoint("CENTER", 0, 0)
		object.mana:SetScript("OnEvent", function(self, event, _, powerType)
			local druidManaDisible = false
			if IUF.db.classBar.druidManaDisible and (GetShapeshiftFormID() == CAT_FORM or GetShapeshiftFormID() == BEAR_FORM) then
				druidManaDisible = true
			end
			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_POWER_UPDATE" then
				if powerType == "MANA" and not druidManaDisible then
					self.cur = UnitPower("player", 0)
					self.anchors[1].bar:SetValue(self.cur)
					IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
				end
			elseif event == "UNIT_MAXPOWER" then
				if powerType == "MANA" and not druidManaDisible then
					self.max, self.cur = UnitPowerMax("player", 0), UnitPower("player", 0)
					self.anchors[1].bar:SetMinMaxValues(0, self.max)
					self.anchors[1].bar:SetValue(self.cur)
					IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
				end
			elseif UnitPowerType("player") == 0 or UnitHasVehicleUI("player") or druidManaDisible then
				if self:IsShown() then
					self:Hide()
					self:UnregisterEvent("UNIT_MAXPOWER")
					self:UnregisterEvent("UNIT_POWER_UPDATE")
					self:UnregisterEvent("UNIT_POWER_FREQUENT")
					updateVisible()
				end
			else
				if not self:IsShown() then
					self:Show()
					self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
					self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					updateVisible()
				end
				self:GetScript("OnEvent")(self, "UNIT_MAXPOWER", nil, "MANA")
			end
		end)
		object.mana:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.mana:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		object.mana:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
		object.mana:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.mana:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.mana:Hide()

		object.eclipse = CreateFrame("Frame", nil, object)
		object.eclipse:SetPoint("TOPLEFT", 0, 0)
		object.eclipse:SetPoint("TOPRIGHT", 0, 0)
		object.eclipse:SetHeight(14)
		object.eclipse:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.eclipse, 1)
		object.eclipse.moon = object.eclipse:CreateTexture(nil, "BACKGROUND", nil, -3)
		object.eclipse.moon:SetVertexColor(0.13, 0.2, 0.5, 0.8)
		object.eclipse.moon:SetPoint("TOPLEFT", object.eclipse.anchors[1], "TOPLEFT", 0, 0)
		object.eclipse.moon:SetPoint("BOTTOMRIGHT", object.eclipse.anchors[1], "BOTTOM", 0, 0)
		object.eclipse.sun = object.eclipse:CreateTexture(nil, "BACKGROUND", nil, -3)
		object.eclipse.sun:SetVertexColor(0.51, 0.23, 0.03, 0.8)
		object.eclipse.sun:SetPoint("TOPRIGHT", object.eclipse.anchors[1], "TOPRIGHT", 0, 0)
		object.eclipse.sun:SetPoint("BOTTOMLEFT", object.eclipse.anchors[1], "BOTTOM", 0, 0)
		object.eclipse.bar = object.eclipse:CreateTexture(nil, "BACKGROUND", nil, 0)
		object.eclipse.marker = object.eclipse:CreateTexture(nil, "ARTWORK")
		object.eclipse.marker:SetSize(20, 20)
		object.eclipse.marker:SetTexture("Interface\\PlayerFrame\\UI-DruidEclipse")
		object.eclipse.marker:SetBlendMode("ADD")
		object.eclipse.marker:SetTexCoord(unpack(ECLIPSE_MARKER_COORDS.none))
		object.eclipse.marker:SetPoint("CENTER", 0, 0)
		object.eclipse.flash = CreateFrame("Frame", nil, object.eclipse)
		object.eclipse.flash:GetFrameLevel(object.eclipse.flash:GetFrameLevel())
		object.eclipse.flash.tex = object.eclipse.flash:CreateTexture(nil, "BORDER")
		object.eclipse.flash.tex:SetBlendMode("ADD")
		object.eclipse.flash.tex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
		object.eclipse.flash.tex:SetAllPoints()
		object.eclipse.flash:Hide()
		object.eclipse.text = object.eclipse:CreateFontString(nil, "OVERLAY", "FriendsFont_Small")
		object.eclipse.text:SetPoint("CENTER", 0, 0)
		object.eclipse:Hide()

		object.eclipse:SetScript("OnEvent", function(self, event, dir, powerType)
			if event == "UNIT_AURA" then
 				if findBuffById(ECLIPSE_BAR_SOLAR_BUFF_ID, "PLAYER") then
 					if self.flash.anchor ~= self.sun then
 						self.flash.anchor = self.sun
 						self.flash:SetAllPoints(self.sun)
 						self.flash.tex:SetVertexColor(0.97, 0.84, 0.22, 0.25)
 						IUF:RegisterFlash(self.flash)
 					end

 				elseif findBuffById(ECLIPSE_BAR_LUNAR_BUFF_ID, "PLAYER") then
 					if self.flash.anchor ~= self.moon then
 						self.flash.anchor = self.moon
 						self.flash:SetAllPoints(self.moon)
 						self.flash.tex:SetVertexColor(0.35, 0.65, 0.87, 0.25)
 						IUF:RegisterFlash(self.flash)
 					end

 				else
				if self.flash.anchor or self.flash:IsShown() then
					self.flash.anchor = nil
					IUF:UnregisterFlash(self.flash)
				end
				end
 			elseif event == "ECLIPSE_DIRECTION_CHANGE" then
 				self.marker:SetTexCoord(unpack(ECLIPSE_MARKER_COORDS[dir] or ECLIPSE_MARKER_COORDS.none))
			elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then

				if powerType == "ECLIPSE" or powerType=="BALANCE"  then
--					self.cur = UnitPower("player", 8)
--					self.max = UnitPowerMax("player", 8) --eclipse
					self.cur = UnitPower("player", 26)
					self.max = UnitPowerMax("player", 26) --balance
					if self.cur == 0 or self.max == 0 then
						self.barType = 0
						self.bar:Hide()
						self.marker:SetPoint("CENTER", 0, 0)
						self.text:SetText(0)
					else

						if self.cur > 0 then
							if self.barType ~= 1 then
								self.barType = 1
								self.bar:Show()
								self.bar:ClearAllPoints()
								self.bar:SetPoint("TOPLEFT", self.sun, "TOPLEFT", 0, 0)
								self.bar:SetPoint("BOTTOMLEFT", self.sun, "BOTTOMLEFT", 0, 0)
								self.bar:SetVertexColor(0.97, 0.84, 0.22)
								self.anchor = self.sun
								self.marker:SetPoint("CENTER", self.bar, "RIGHT", 0, 0)
							end
						elseif self.barType ~= -1 then
							self.barType = -1
							self.bar:Show()
							self.bar:ClearAllPoints()
							self.bar:SetPoint("TOPRIGHT", self.moon, "TOPRIGHT", 0, 0)
							self.bar:SetPoint("BOTTOMRIGHT", self.moon, "BOTTOMRIGHT", 0, 0)
							self.bar:SetVertexColor(0.35, 0.65, 0.87)
							self.anchor = self.moon
							self.marker:SetPoint("CENTER", self.bar, "LEFT", 0, 0)
						end
						self.width = self.anchor:GetWidth()
						if self.width <= 0 then
							self.width = self.anchors[1]:GetWidth() / 2
						end
						self.cur = abs(self.cur / self.max)
						self.bar:SetWidth(max(self.cur * self.width, 0.001))
						self.text:SetFormattedText("%d", self.cur * 100)
					end
				end
 				
			elseif GetPrimaryTalentTree() == 1 and not UnitHasVehicleUI("player") and (not GetShapeshiftFormID() or GetShapeshiftFormID() == MOONKIN_FORM) then
				if not self:IsShown() then
					self:Show()
 					self:RegisterEvent("ECLIPSE_DIRECTION_CHANGE")
					self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					self:RegisterUnitEvent("UNIT_AURA", "player")
					updateVisible()
				end
				self.flash.anchor = nil
 				self:onEvent("ECLIPSE_DIRECTION_CHANGE", GetEclipseDirection() or "none")
				self:onEvent("UNIT_POWER_FREQUENT", nil, "ECLIPSE")
				self:onEvent("UNIT_POWER_FREQUENT", nil, "BALANCE")
				self:onEvent("UNIT_AURA")
			elseif self:IsShown() then
				self:Hide()
				self.flash.anchor = nil
				IUF:UnregisterFlash(self.flash)
 				self:UnregisterEvent("ECLIPSE_DIRECTION_CHANGE")
				self:UnregisterEvent("UNIT_MAXPOWER")
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_AURA")
				updateVisible()
			end
		end)
		object.eclipse.onEvent = object.eclipse:GetScript("OnEvent")
		object.eclipse:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.eclipse:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
 		object.eclipse:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		object.eclipse:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.eclipse:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.eclipse:HookScript("OnSizeChanged", function(self)
			if self:IsShown() then
				self:onEvent("UNIT_POWER_FREQUENT", nil, "ECLIPSE")
				self:onEvent("UNIT_POWER_FREQUENT", nil, "BALANCE")
			end
		end)
		object.eclipse:SetScript("OnEnter", function(self)
			GameTooltip_SetDefaultAnchor(GameTooltip, self)
			GameTooltip:SetText(BALANCE, 1, 1, 1)
			GameTooltip:AddLine(BALANCE_TOOLTIP, nil, nil, nil, true)
			GameTooltip:Show()
		end)
		object.eclipse:SetScript("OnLeave", GameTooltip_Hide)


		local maxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints);
		
		object.comboPoint = CreateFrame("Frame", nil, object)
		--object.comboPoint:SetPoint("TOPLEFT", 0, 0)
		--object.comboPoint:SetPoint("TOPRIGHT", 0, 0)
		object.comboPoint:SetPoint("TOPLEFT", object.mana, "BOTTOMLEFT", 0, 0)
		object.comboPoint:SetPoint("TOPRIGHT", object.mana, "BOTTOMRIGHT", 0, 0)
		object.comboPoint:SetHeight(14)
		object.comboPoint:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.comboPoint, maxComboPoints)

		for _, btn in ipairs(object.comboPoint.anchors) do
			btn:SetAlpha(0)
			btn:SetVertexColor(0.76, 0.76, 0.22)
			btn.flash = object.comboPoint:CreateTexture(nil, "BORDER")
			btn.flash:SetVertexColor(0.76, 0.76, 0.22)
			btn.flash:SetBlendMode("ADD")
			btn.flash:SetAllPoints(btn)
			btn.flash:Hide()
		end

		object.comboPoint:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" then
				if powerType == "COMBO_POINTS" or event == "UNIT_DISPLAYPOWER" then
				
					self.value = UnitPower("player", Enum.PowerType.ComboPoints)
					self.max = UnitPowerMax("player", Enum.PowerType.ComboPoints)

					if self.num ~= self.max then
						setAddOnBorder(self, self.max)
					end
					for i = 1, self.value do
						self.anchors[i]:SetAlpha(1)
					end
					for i = self.prev + 1, self.value do
						IUF:UIFrameFlash(self.anchors[i].flash, 0.25, 0.25, 0.5)
					end
					for i = self.value + 1, self.max do
						self.anchors[i]:SetAlpha(0)
						IUF:UIFrameFlashStop(self.anchors[i].flash)
					end
					self.prev = self.value
				end
			elseif UnitPowerType("player") == 3 and not UnitHasVehicleUI("player") then
				if not self:IsShown() then
					self:Show()
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
					updateVisible()
				end
				self.prev = UnitPower("player", Enum.PowerType.ComboPoints)
				self:GetScript("OnEvent")(self, "UNIT_DISPLAYPOWER")

			elseif self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()
			end			
		end)
		
		object.comboPoint.bar = object.comboPoint:CreateTexture(nil, "BACKGROUND", nil, 0)
		object.comboPoint.bar:SetVertexColor(0.88, 0.66, 0.44, 0.2)
		object.comboPoint.bar:SetPoint("TOPLEFT", object.mana, "TOPLEFT", 0, 3)
		object.comboPoint.bar:SetPoint("TOPRIGHT", object.mana, "TOPRIGHT", 0, 0)
		
		object.comboPoint:RegisterEvent("PLAYER_ENTERING_WORLD")
 		object.comboPoint:RegisterEvent("PLAYER_TALENT_UPDATE")
		object.comboPoint:RegisterEvent("SPELLS_CHANGED")
		object.comboPoint:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.comboPoint:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.comboPoint:Hide()
	
		
		createTotem(object, 3, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- DRUID
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				IUF.units.player.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
 					setClassBar(PlayerFrameAlternateManaBar, object, nil, updateVisible)
 					PlayerFrameAlternateManaBar:SetScript("OnMouseUp", nil)
 					PlayerFrameAlternateManaBar.SetPoint = PlayerFrameAlternateManaBar.GetPoint
					setClassBar(EclipseBarFrame, object, nil, updateVisible)
					if TotemFrame then setClassBar(TotemFrame, object, 4, updateVisible) end
				end
 				PlayerFrameAlternateManaBar:SetStatusBarTexture(SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2"))
 				PlayerFrameAlternateManaBar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
 				PlayerFrameAlternateManaBar:ClearAllPoints()
				
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.mana:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarTexture(tex)
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
				
				EclipseBarFrame:ClearAllPoints()
				if TotemFrameTotem2 then TotemFrameTotem2:ClearAllPoints() end
 				PlayerFrameAlternateManaBar.DefaultBorder:ClearAllPoints()
				object.classBar.addOn.comboPoint:ClearAllPoints()
				
				object.classBar.addOn.comboPoint.bar:SetTexture(tex)
				for _, v in pairs(object.classBar.addOn.comboPoint.anchors) do
					v:SetTexture(tex)
					v.flash:SetTexture(tex)
				end
				if IUF.db.classBar.pos == "BOTTOM" then
					EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "TOPLEFT", object.classBar, "TOPLEFT", 12, 0)
					EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "TOPRIGHT", object.classBar, "TOPRIGHT", -12, 0)
 					PlayerFrameAlternateManaBar.DefaultBorder:SetPoint("TOPLEFT", 4, 0)
 					PlayerFrameAlternateManaBar.DefaultBorder:SetPoint("TOPRIGHT", -4, 0)
 					PlayerFrameAlternateManaBar.DefaultBorder:SetTexCoord(0.125, 0.25, 1, 0)
 					PlayerFrameAlternateManaBar.DefaultBorderLeft:SetTexCoord(0, 0.125, 1, 0)
 					PlayerFrameAlternateManaBar.DefaultBorderRight:SetTexCoord(0.125, 0, 1, 0)
					EclipseBarFrame:SetPoint("TOP", object.classBar, "TOP", 0, 6)
					if TotemFrameTotem2 then TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, 9) end
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("TOPLEFT", object.classBar.addOn.mana, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("TOPRIGHT", object.classBar.addOn.mana, "BOTTOMRIGHT", 0, 0)
				else
 					PlayerFrameAlternateManaBar:ClearAllPoints()
					EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 12, 0)
					EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", -12, 0)
 					PlayerFrameAlternateManaBar.DefaultBorder:SetPoint("BOTTOMLEFT", 4, 0)
 					PlayerFrameAlternateManaBar.DefaultBorder:SetPoint("BOTTOMRIGHT", -4, 0)
 					PlayerFrameAlternateManaBar.DefaultBorder:SetTexCoord(0.125, 0.25, 0, 1)
 					PlayerFrameAlternateManaBar.DefaultBorderLeft:SetTexCoord(0, 0.125, 0, 1)
 					PlayerFrameAlternateManaBar.DefaultBorderRight:SetTexCoord(0.125, 0, 0, 1)
					EclipseBarFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, -6)
					if TotemFrameTotem2 then TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", 0, -8) end
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("BOTTOMLEFT", object.classBar.addOn.mana, "TOPLEFT", 0, 15)
					object.classBar.addOn.comboPoint:SetPoint("BOTTOMRIGHT", object.classBar.addOn.mana, "TOPRIGHT", 0, 15)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					PlayerFrameAlternateManaBar:ClearAllPoints()
					EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", UIParent, "TOP", 0, 2000)
					EclipseBarFrame:ClearAllPoints()
					EclipseBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					if TotemFrameTotem2 then 
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					end
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.mana:ClearAllPoints()
				object.classBar.addOn.eclipse:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				object.classBar.addOn.comboPoint:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarTexture(tex)
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
				

				object.classBar.addOn.eclipse.bar:SetTexture(tex)
				object.classBar.addOn.eclipse.moon:SetTexture(tex)
				object.classBar.addOn.eclipse.sun:SetTexture(tex)

				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				object.classBar.addOn.comboPoint.bar:SetTexture(tex)
				for _, v in pairs(object.classBar.addOn.comboPoint.anchors) do
					v:SetTexture(tex)
					v.flash:SetTexture(tex)
				end
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.eclipse:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.eclipse:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("TOPLEFT", object.classBar.addOn.mana, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("TOPRIGHT", object.classBar.addOn.mana, "BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.eclipse:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.eclipse:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("BOTTOMLEFT", object.classBar.addOn.mana, "TOPLEFT", 0, 15)
					object.classBar.addOn.comboPoint:SetPoint("BOTTOMRIGHT", object.classBar.addOn.mana, "TOPRIGHT", 0, 15)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard then
 				PlayerFrameAlternateManaBar:ClearAllPoints()
				EclipseBarFrame.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", UIParent, "TOP", 0, 2000)
				EclipseBarFrame:ClearAllPoints()
				EclipseBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				if TotemFrameTotem2 then 
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
			end
			object.classBar.addOn:Hide()
		end
	end

elseif playerClass == "DEATHKNIGHT" then
	if RuneFrame:GetParent() == UIParent and select(2, RuneFrame:GetPoint()) == PlayerFrame then
		RuneFrame:SetParent(PlayerFrame)
	end

	local function updateVisible()	-- DEATHKNIGHT
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame and TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(38)
				elseif RuneFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(24)
				else
					IUF.units.player.classBar:SetHeight(0.001)
				end
			else
				if IUF.units.player.classBar.addOn.totem:IsShown() and IUF.units.player.classBar.addOn.bar:IsShown() then
					IUF.units.player.classBar:SetHeight(29)
					IUF.units.player.classBar.addOn:SetHeight(28)
				elseif IUF.units.player.classBar.addOn.totem:IsShown() or IUF.units.player.classBar.addOn.bar:IsShown() then
					IUF.units.player.classBar:SetHeight(15)
					IUF.units.player.classBar.addOn:SetHeight(14)
				else
					IUF.units.player.classBar:SetHeight(0.001)
					IUF.units.player.classBar.addOn:SetHeight(0.001)
				end
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- DEATHKNIGHT
		createClassBar(object)
		object = createAddOnClassBar(object)

		local ipairs = _G.ipairs
		local GetTime = _G.GetTime
		local GetRuneType = _G.GetRuneType
		local GetRuneCooldown = _G.GetRuneCooldown

		local runes = { "BLOOD", "FROST", "UNHOLY", "DEATH" }
		local runeOrder = { 1, 2, 5, 6, 3, 4 }
		local runeColors = {
			{ 1, 0.25, 0.25 },	-- BLOOD
			{ 0, 0.7, 1 },		-- FROST
			{ 0.2, 1, 0.2 },	-- UNHOLY
			{ 0.8, 0.1, 1 },	-- DEATH
		}

		object.bar = CreateFrame("Frame", nil, object)
		object.bar:SetPoint("TOPLEFT", 0, 0)
		object.bar:SetPoint("TOPRIGHT", 0, 0)
		object.bar:SetHeight(14)
		object.bar:SetFrameLevel(object:GetFrameLevel())
		object.bar:Hide()
		setAddOnBorder(object.bar, #runeOrder, true)

		for _, btn in ipairs(object.bar.anchors) do
			btn.bar.flash = CreateFrame("Frame", nil, btn.bar)
			btn.bar.flash:SetFrameLevel(btn.bar:GetFrameLevel())
			btn.bar.flash:SetAllPoints()
			btn.bar.flash.tex = btn.bar.flash:CreateTexture(nil, "OVERLAY")
			btn.bar.flash.tex:SetBlendMode("ADD")
			btn.bar.flash.tex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
			btn.bar.flash.tex:SetAllPoints()
			btn.bar.flash:Hide()
			btn.bar.texture = btn.bar:GetStatusBarTexture()
		end

		local curTime

		local function runeOnUpdate(bar)
			curTime = GetTime()
			bar:SetValue(curTime)
			bar.text:SetText(secondsToTime(bar.endTime - curTime))
		end

		local function updateRuneCooldown(btn, id)
			local start, duration, runeReady = GetRuneCooldown(id)
			if runeReady then
				if btn.bar:GetScript("OnUpdate") then
					btn.bar:SetScript("OnUpdate", nil)
				end
				btn.bar.endTime = nil
				btn.bar.text:SetText("")
				btn.bar:SetMinMaxValues(0, 1)
				btn.bar:SetValue(1)
				btn.bar.texture:SetAlpha(1)
			else
				IUF:UIFrameFlashStop(btn.bar.flash)
				btn.bar.texture:SetAlpha(0.5)
				btn.bar.endTime = start + duration
				btn.bar:SetMinMaxValues(start, btn.bar.endTime)
				runeOnUpdate(btn.bar)
				if not btn.bar:GetScript("OnUpdate") then
					btn.bar:SetScript("OnUpdate", runeOnUpdate)
				end
			end
			return runeReady
		end

		local function updateRune(btn, id, dontShine)
			local rune = GetRuneType(id)
			btn:SetAlpha(0.35)
			if rune then
				btn:SetVertexColor(unpack(runeColors[rune]))
				btn.bar:SetStatusBarColor(unpack(runeColors[rune]))
				btn.bar.flash.tex:SetVertexColor(unpack(runeColors[rune]))
				btn.bar.flash.tex:SetAlpha(0.25)
				btn.bar:Show()
				IUF:UIFrameFlashStop(btn.bar.flash)
				btn.bar.flash:Hide()
				updateRuneCooldown(btn, id)
			else
				btn:SeVertexColor(0, 0, 0)
				btn.bar:Hide()
				if btn.bar:GetScript("OnUpdate") then
					btn.bar:SetScript("OnUpdate", nil)
				end
				--btn.rune = nil
			end
		end

		object.bar:SetScript("OnEvent", function(self, event, id, isEnergize)
			if event == "RUNE_POWER_UPDATE" then
				if runeOrder[id] then
					if updateRuneCooldown(self.anchors[runeOrder[id]], id) then
						IUF:UIFrameFlash(self.anchors[runeOrder[id]].bar.flash, 0.25, 0.25, 0.5)
					end
				end
			elseif event == "RUNE_TYPE_UPDATE" then
				if runeOrder[id] then
					updateRune(self.anchors[runeOrder[id]], id)
				end
			else
				if UnitHasVehicleUI("player") then
					if self:IsShown() then
						self:Hide()
						updateVisible()
					end
				else
					if not self:IsShown() then
						self:Show()
						updateVisible()
					end
					for rune, id in ipairs(runeOrder) do
						updateRune(self.anchors[rune], id, true)
					end
				end
			end
		end)
		object.bar:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.bar:RegisterEvent("RUNE_POWER_UPDATE")
		object.bar:RegisterEvent("RUNE_TYPE_UPDATE")
		object.bar:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.bar:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")

		createTotem(object, 1, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- DEATHKNIGHT
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(RuneFrame, object, nil, updateVisible)
					if TotemFrame and TotemFrameTotem1 and TotemFrameTotem2 then
					setClassBar(TotemFrame, object, 4, updateVisible)
					TotemFrameTotem1:ClearAllPoints()
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("LEFT", TotemFrameTotem1, "RIGHT", -4, 0)
					end
				end
				RuneFrame:ClearAllPoints()
				if TotemFrameTotem1 then 
				TotemFrameTotem1:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					RuneFrame:SetPoint("TOP", object.classBar, "TOP", 1, 0)
					TotemFrameTotem1:SetPoint("TOPRIGHT", RuneFrame, "TOPLEFT", 1, 7)
				else
					RuneFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 1, 2)
					TotemFrameTotem1:SetPoint("BOTTOMRIGHT", RuneFrame, "BOTTOMLEFT", 1, -7)
				end
				updateTotemDurationText()
				end
			else
				if object.classBar.setupBlizzard then
					if TotemFrameTotem1 then
					TotemFrameTotem1:ClearAllPoints()
					TotemFrameTotem1:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					end
					RuneFrame:ClearAllPoints()
					RuneFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.bar:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				for _, v in pairs(object.classBar.addOn.bar.anchors) do
					v:SetTexture(tex)
					v.bar:SetStatusBarTexture(tex)
					v.bar.flash.tex:SetTexture(tex)
				end
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard then
				if TotemFrameTotem1 then
				TotemFrameTotem1:ClearAllPoints()
				TotemFrameTotem1:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				RuneFrame:ClearAllPoints()
				RuneFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
			end
			object.classBar.addOn:Hide()
		end
	end

elseif playerClass == "PRIEST" then
	local function updateVisible()	-- PRIEST
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(42)
				elseif PriestBarFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(34)
				else
					IUF.units.player.classBar:SetHeight(0.001)
				end
			else
				if IUF.units.player.classBar.addOn.totem:IsShown() and IUF.units.player.classBar.addOn.bar:IsShown() then
					IUF.units.player.classBar:SetHeight(29)
					IUF.units.player.classBar.addOn:SetHeight(28)
				elseif IUF.units.player.classBar.addOn.totem:IsShown() or IUF.units.player.classBar.addOn.bar:IsShown() then
					IUF.units.player.classBar:SetHeight(15)
					IUF.units.player.classBar.addOn:SetHeight(14)
				else
					IUF.units.player.classBar:SetHeight(0.001)
					IUF.units.player.classBar.addOn:SetHeight(0.001)
				end
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- PRIEST
		createClassBar(object)
		object = createAddOnClassBar(object)

		local UnitPower = _G.UnitPower
		local UnitLevel = _G.UnitLevel

		object.bar = CreateFrame("Frame", nil, object)
		object.bar:SetPoint("TOPLEFT", 0, 0)
		object.bar:SetPoint("TOPRIGHT", 0, 0)
		object.bar:SetHeight(14)
		object.bar:SetFrameLevel(object:GetFrameLevel())
--		setAddOnBorder(object.bar, UnitPowerMax("player", SPELL_POWER_SHADOW_ORBS))
		setAddOnBorder(object.bar, 3)


		for _, btn in ipairs(object.bar.anchors) do
			btn:SetAlpha(0)
			btn:SetVertexColor(0.62, 0.22, 0.76)
			btn.flash = object.bar:CreateTexture(nil, "BORDER")
			btn.flash:SetVertexColor(0.62, 0.22, 0.76)
			btn.flash:SetBlendMode("ADD")
			btn.flash:SetAllPoints(btn)
			btn.flash:Hide()
		end

		object.bar:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_AURA" then
--				if powerType == "SHADOW_ORBS" or event == "UNIT_DISPLAYPOWER" then
--					self.numOrb = UnitPower(SPELL_POWER_SHADOW_ORBS,"player")
					self.numOrb = select(3,AuraUtil.FindAuraByName(SHADOW_ORBS,"player")) or 0
					self.numOrb = self.numOrb or 0 

--					self.numOrbMax = UnitPowerMax("player", SPELL_POWER_SHADOW_ORBS)
					self.numOrbMax = 3

					for i = 1, self.numOrb do
						self.anchors[i]:SetAlpha(1)
					end
					for i = (self.prevOrb or 0) + 1, self.numOrb do
						IUF:UIFrameFlash(self.anchors[i].flash, 0.25, 0.25, 0.5)
					end
					for i = (self.numOrb or 0) + 1, self.numOrbMax do
						self.anchors[i]:SetAlpha(0)
						IUF:UIFrameFlashStop(self.anchors[i].flash)
					end
					self.prevOrb = self.numOrb
--				end

--			elseif UnitLevel("player") >= SHADOW_ORBS_SHOW_LEVEL and GetPrimaryTalentTree() == SPEC_PRIEST_SHADOW and not UnitHasVehicleUI("player") then
			elseif GetPrimaryTalentTree() == SPEC_PRIEST_SHADOW and not UnitHasVehicleUI("player") then

				if not self:IsShown() then
					self:Show()
--					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
--					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
					self:RegisterUnitEvent("UNIT_AURA", "player")

 


					updateVisible()
				end
--				self.prevOrb = UnitPower("player", SPELL_POWER_SHADOW_ORBS)
				self.prevOrb = select(3,AuraUtil.FindAuraByName(SPELL_POWER_SHADOW_ORBS,"player")) or 0 
				self.prevOrb = self.prevOrb or 0
				self:GetScript("OnEvent")(self, "UNIT_AURA", nil, "SHADOW_ORBS")
			elseif self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_AURA")
--				self:UnregisterEvent("UNIT_POWER_FREQUENT")
--				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()
			end
		end)
		object.bar:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.bar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		object.bar:RegisterEvent("PLAYER_LEVEL_UP")
		object.bar:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.bar:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.bar:Hide()

		createTotem(object, MAX_TOTEMS, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- PRIEST
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(PriestBarFrame, object, nil, updateVisible)
					if TotemFrame then setClassBar(TotemFrame, object, 4, updateVisible) end
				
					for i = 1, select("#", PriestBarFrame:GetRegions()) do
						PriestBarFrame.background = select(i, PriestBarFrame:GetRegions())
						if PriestBarFrame.background:GetObjectType() == "Texture" and PriestBarFrame.background:GetDrawLayer() == "BACKGROUND" then
							break
						else
							PriestBarFrame.background = nil
						end
					end
				
				end
				PriestBarFrame:ClearAllPoints()
				if TotemFrameTotem2 then TotemFrameTotem2:ClearAllPoints() end
				
				if PriestBarFrame.background then
					PriestBarFrame.background:ClearAllPoints()
					if IUF.db.classBar.pos == "BOTTOM" then
						if TotemFrameTotem2 then TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9) end
						PriestBarFrame:SetPoint("TOP", object.classBar, "TOP", 0, 2)
						PriestBarFrame.background:SetAllPoints()
						PriestBarFrame.background:SetTexCoord(0.00390625, 0.62500000, 0.00781250, 0.42968750)
						for i = 1, 3 do
							_G["PriestBarFrameOrb"..i].highlight:ClearAllPoints()
							_G["PriestBarFrameOrb"..i].highlight:SetPoint("TOP", 0, -1)
							_G["PriestBarFrameOrb"..i].highlight:SetTexCoord(0.00390625, 0.29296875, 0.44531250, 0.78906250)
						end
					else
						if TotemFrameTotem2 then TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8) end
						PriestBarFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, -18)
						PriestBarFrame.background:SetPoint("TOPLEFT", 0, 16)
						PriestBarFrame.background:SetPoint("BOTTOMRIGHT", 0, 16)
						PriestBarFrame.background:SetTexCoord(0.00390625, 0.62500000, 0.42968750, 0.00781250)
						for i = 1, 3 do
							_G["PriestBarFrameOrb"..i].highlight:ClearAllPoints()
							_G["PriestBarFrameOrb"..i].highlight:SetPoint("BOTTOM", 0, 1)
							_G["PriestBarFrameOrb"..i].highlight:SetTexCoord(0.00390625, 0.29296875, 0.78906250, 0.44531250)
						end
					end
				elseif IUF.db.classBar.pos == "BOTTOM" then
					if TotemFrameTotem2 then TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9) end
					PriestBarFrame:SetPoint("TOP", object.classBar, "TOP", 0, 2)
				else
					if TotemFrameTotem2 then TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8) end
					PriestBarFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, -18)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					if TotemFrameTotem2 then 
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					end
					PriestBarFrame:ClearAllPoints()
					PriestBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.bar:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				for _, v in pairs(object.classBar.addOn.bar.anchors) do
					v:SetTexture(tex)
					v.flash:SetTexture(tex)
				end
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard then
				if TotemFrameTotem2 then
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				PriestBarFrame:ClearAllPoints()
				PriestBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
			end
			object.classBar.addOn:Hide()
		end
	end
 

elseif playerClass == "PALADIN" then
	local function updateVisible()	-- PALADIN
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame and TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(40)
				elseif PaladinPowerBarFrame:IsShown() then	-- if GetPrimaryTalentTree() == SPEC_PALADIN_RETRIBUTION then
					IUF.units.player.classBar:SetHeight(38)
				else
					IUF.units.player.classBar:SetHeight(0.001)
				end
			else
				if IUF.units.player.classBar.addOn.totem:IsShown() and IUF.units.player.classBar.addOn.bar:IsShown() then
					IUF.units.player.classBar:SetHeight(29)
					IUF.units.player.classBar.addOn:SetHeight(28)
				elseif IUF.units.player.classBar.addOn.totem:IsShown() or IUF.units.player.classBar.addOn.bar:IsShown() then
					IUF.units.player.classBar:SetHeight(15)
					IUF.units.player.classBar.addOn:SetHeight(14)
				else
					IUF.units.player.classBar:SetHeight(0.001)
					IUF.units.player.classBar.addOn:SetHeight(0.001)
				end
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- PALADIN
		createClassBar(object)
		object = createAddOnClassBar(object)

		local UnitPower = _G.UnitPower
		local UnitLevel = _G.UnitLevel

		object.bar = CreateFrame("Frame", nil, object)
		object.bar:SetPoint("TOPLEFT", 0, 0)
		object.bar:SetPoint("TOPRIGHT", 0, 0)
		object.bar:SetHeight(14)
		object.bar:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.bar, Enum.PowerType.HolyPower)

		for _, btn in ipairs(object.bar.anchors) do
			btn:SetAlpha(0)
			btn:SetVertexColor(0.95, 0.9, 0.2)
			btn.flash = object.bar:CreateTexture(nil, "BORDER")
			btn.flash:SetVertexColor(0.95, 0.9, 0.2)
			btn.flash:SetBlendMode("ADD")
			btn.flash:SetAllPoints(btn)
			btn.flash:Hide()
		end

		object.bar:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" then
				if powerType == "HOLY_POWER" or event == "UNIT_DISPLAYPOWER" then
					self.holy = UnitPower("player", Enum.PowerType.HolyPower)
					self.holyMax = UnitPowerMax("player", Enum.PowerType.HolyPower)

					if self.num ~= self.holyMax then
						setAddOnBorder(self, self.holyMax)
					end
					for i = 1, self.holy do
						self.anchors[i]:SetAlpha(1)
					end
					for i = self.prevHoly + 1, self.holy do
						IUF:UIFrameFlash(self.anchors[i].flash, 0.25, 0.25, 0.5)
					end
					for i = self.holy + 1, self.holyMax do
						self.anchors[i]:SetAlpha(0)
						IUF:UIFrameFlashStop(self.anchors[i].flash)
					end
					self.prevHoly = self.holy
				
				end
--			elseif UnitLevel("player") >= PALADINPOWERBAR_SHOW_LEVEL and GetPrimaryTalentTree() == SPEC_PALADIN_RETRIBUTION and not UnitHasVehicleUI("player") then
			elseif    not UnitHasVehicleUI("player") then

				if not self:IsShown() then
					self:Show()
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")

					updateVisible()
				end
				self.prevHoly = UnitPower("player", Enum.PowerType.HolyPower)
				self:GetScript("OnEvent")(self, "UNIT_DISPLAYPOWER", nil, "HOLY_POWER")

			elseif self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
--				self:UnregisterEvent("UNIT_AURA")

				updateVisible()
			end
		end)
		object.bar:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.bar:RegisterEvent("PLAYER_LEVEL_UP")
--		object.bar:RegisterEvent("PLAYER_TALENT_UPDATE")	--PLAYER_SPECIALIZATION_CHANGED
		object.bar:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.bar:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.bar:Hide()

		createTotem(object, 1, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- PALADIN
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(PaladinPowerBarFrame, object, nil, updateVisible)
					
					if TotemFrame then setClassBar(TotemFrame, object, 4, updateVisible) end
					if TotemFrameTotem1 then TotemFrameTotem1:ClearAllPoints() end
					if TotemFrameTotem2 then 
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("LEFT", TotemFrameTotem1, "RIGHT", -4, 0)
					end
				end
				if TotemFrameTotem1 then TotemFrameTotem1:ClearAllPoints() end
				
				PaladinPowerBarFrame:ClearAllPoints()
				PaladinPowerBarFrameBG:ClearAllPoints()
				PaladinPowerBarFrameBankBG:ClearAllPoints()
				PaladinPowerBarFrameGlowBGTexture:ClearAllPoints()
				PaladinPowerBarFrameRune1:ClearAllPoints()
				PaladinPowerBarFrameRune4:ClearAllPoints()
				PaladinPowerBarFrameRune5:ClearAllPoints()
			
				if IUF.db.classBar.pos == "BOTTOM" then
					if TotemFrameTotem1 then TotemFrameTotem1:SetPoint("RIGHT", PaladinPowerBarFrame, "LEFT", 20, 0) end
					
					PaladinPowerBarFrame:ClearAllPoints()
					PaladinPowerBarFrame:SetPoint("TOP", object.classBar, "TOP", 0, 7)
					PaladinPowerBarFrameBG:SetPoint("TOP", 0, 0)
					PaladinPowerBarFrameBG:SetTexCoord(0.00390625, 0.53515625, 0.00781250, 0.31250000)
					PaladinPowerBarFrameBankBG:SetPoint("TOP", 0, -29)
					PaladinPowerBarFrameBankBG:SetTexCoord(0.00390625, 0.27343750, 0.64843750, 0.77343750)
					PaladinPowerBarFrameGlowBGTexture:SetPoint("TOP", 0, 0)
					PaladinPowerBarFrameGlowBGTexture:SetTexCoord(0.00390625, 0.53515625, 0.32812500, 0.63281250)
					PaladinPowerBarFrameRune1:SetPoint("TOPLEFT", 21, -11)
					PaladinPowerBarFrameRune4:SetPoint("TOPLEFT", 67, -28)
					PaladinPowerBarFrameRune5:SetPoint("TOPLEFT", 43, -28)
					PaladinPowerBarFrameRune1Texture:SetTexCoord(0.00390625, 0.14453125, 0.78906250, 0.96093750)
					PaladinPowerBarFrameRune2Texture:SetTexCoord(0.15234375, 0.27343750, 0.78906250, 0.92187500)
					PaladinPowerBarFrameRune3Texture:SetTexCoord(0.28125000, 0.38671875, 0.64843750, 0.81250000)
					PaladinPowerBarFrameRune4Texture:SetTexCoord(0.28125000, 0.38671875, 0.82812500, 0.92187500)
					PaladinPowerBarFrameRune5Texture:SetTexCoord(0.39453125, 0.49609375, 0.64843750, 0.74218750)
					
				else
					if TotemFrameTotem1 then TotemFrameTotem1:SetPoint("RIGHT", PaladinPowerBarFrame, "LEFT", 20, 0) end
					PaladinPowerBarFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, -7)
					PaladinPowerBarFrameBG:SetPoint("BOTTOM", 0, 0)
					PaladinPowerBarFrameBG:SetTexCoord(0.00390625, 0.53515625, 0.31250000, 0.00781250)
					PaladinPowerBarFrameBankBG:SetPoint("BOTTOM", 0, 29)
					PaladinPowerBarFrameBankBG:SetTexCoord(0.00390625, 0.27343750, 0.77343750, 0.64843750)
					PaladinPowerBarFrameGlowBGTexture:SetPoint("BOTTOM", 0, 0)
					PaladinPowerBarFrameGlowBGTexture:SetTexCoord(0.00390625, 0.53515625, 0.63281250, 0.32812500)
					PaladinPowerBarFrameRune1:SetPoint("BOTTOMLEFT", 21, 11)
					PaladinPowerBarFrameRune4:SetPoint("BOTTOMLEFT", 67, 28)
					PaladinPowerBarFrameRune5:SetPoint("BOTTOMLEFT", 43, 28)
					PaladinPowerBarFrameRune1Texture:SetTexCoord(0.00390625, 0.14453125, 0.96093750, 0.78906250)
					PaladinPowerBarFrameRune2Texture:SetTexCoord(0.15234375, 0.27343750, 0.92187500, 0.78906250)
					PaladinPowerBarFrameRune3Texture:SetTexCoord(0.28125000, 0.38671875, 0.81250000, 0.64843750)
					PaladinPowerBarFrameRune4Texture:SetTexCoord(0.28125000, 0.38671875, 0.92187500, 0.82812500)
					PaladinPowerBarFrameRune5Texture:SetTexCoord(0.39453125, 0.49609375, 0.74218750, 0.64843750)
				
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					if TotemFrameTotem2 then 
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					end
					PaladinPowerBarFrame:ClearAllPoints()
					PaladinPowerBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				
				object.classBar.addOn:Show()				
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.bar:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				for _, v in pairs(object.classBar.addOn.bar.anchors) do
					v:SetTexture(tex)
					v.flash:SetTexture(tex)
				end
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard then
				if TotemFrameTotem2 then
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				PaladinPowerBarFrame:ClearAllPoints()
				PaladinPowerBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
			end
			object.classBar.addOn:Hide()
		end
	end

--[[	
elseif playerClass == "MONK" then
	local function updateVisible()	-- MONK
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame and TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(MonkHarmonyBar:IsShown() and 63 or 42)
				else
					IUF.units.player.classBar:SetHeight(MonkHarmonyBar:IsShown() and 30 or 0.001)
				end
			else
				local h = 0
				if IUF.units.player.classBar.addOn.mana:IsShown() then
					h = h + 14
				end
				if IUF.units.player.classBar.addOn.bar:IsShown() then
					h = h + 14
				end
				if IUF.units.player.classBar.addOn.totem:IsShown() then
					h = h + 14
				end
				if h > 0 then
					IUF.units.player.classBar:SetHeight(h + 1)
					IUF.units.player.classBar.addOn:SetHeight(h)
				else
					IUF.units.player.classBar:SetHeight(0.001)
					IUF.units.player.classBar.addOn:SetHeight(0.001)
				end
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- MONK
		createClassBar(object)
		object = createAddOnClassBar(object)

		local UnitPower = _G.UnitPower
		local UnitPowerMax = _G.UnitPowerMax
		local UnitPowerType = _G.UnitPowerType

		object.mana = CreateFrame("Frame", nil, object)
		object.mana:SetPoint("TOPLEFT", 0, 0)
		object.mana:SetPoint("TOPRIGHT", 0, 0)
		object.mana:SetHeight(14)
		object.mana:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.mana, 1, true)
		object.mana.text = object.mana:CreateFontString(nil, "OVERLAY", "FriendsFont_Small")
		object.mana.text:SetPoint("CENTER", 0, 0)
		object.mana:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_POWER_UPDATE" then
				if powerType == "MANA" then
					self.cur = UnitPower("player", 0)
					self.anchors[1].bar:SetValue(self.cur)
					IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
				end
			elseif event == "UNIT_MAXPOWER" then
				if powerType == "MANA" then
					self.max, self.cur = UnitPowerMax("player", 0), UnitPower("player", 0)
					self.anchors[1].bar:SetMinMaxValues(0, self.max)
					self.anchors[1].bar:SetValue(self.cur)
					IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
				end
			elseif GetPrimaryTalentTree() == SPEC_MONK_MISTWEAVER and UnitPowerType("player") ~= 0 and not UnitHasVehicleUI("player") then
				if not self:IsShown() then
					self:Show()
					self:SetHeight(14)
					self:SetAlpha(1)
					self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
					self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					updateVisible()
				end
				self:GetScript("OnEvent")(self, "UNIT_MAXPOWER", nil, "MANA")
			elseif self:IsShown() then
				self:Hide()
				self:SetHeight(0.001)
				self:SetAlpha(0)
				self:UnregisterEvent("UNIT_MAXPOWER")
				self:UnregisterEvent("UNIT_POWER_UPDATE")
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				updateVisible()
			end
		end)
		object.mana:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.mana:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
		object.mana:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		object.mana:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
		object.mana:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.mana:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.mana:SetAlpha(0)
		object.mana:SetHeight(0.001)
		object.mana:Hide()

		object.bar = CreateFrame("Frame", nil, object)
		object.bar:SetPoint("TOPLEFT", 0, 0)
		object.bar:SetPoint("TOPRIGHT", 0, 0)
		object.bar:SetHeight(14)
		object.bar:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.bar, 6)

		for _, btn in ipairs(object.bar.anchors) do
			btn:SetAlpha(0)
			btn:SetVertexColor(0.71, 1, 0.92)
			btn.flash = object.bar:CreateTexture(nil, "BORDER")
			btn.flash:SetVertexColor(0.71, 1, 0.92)
			btn.flash:SetBlendMode("ADD")
			btn.flash:SetAllPoints(btn)
			btn.flash:Hide()
		end

		local SPELL_POWER_CHI = SPELL_POWER_CHI or SPELL_POWER_LIGHT_FORCE

		local function updateChi(self)
			self.chi = UnitPower("player", SPELL_POWER_CHI)
			self.chiMax = UnitPowerMax("player", SPELL_POWER_CHI)
			if self.num ~= self.chiMax then
				setAddOnBorder(self, self.chiMax)
			end
			for i = 1, self.chi do
				self.anchors[i]:SetAlpha(1)
			end
			for i = self.prevChi + 1, self.chi do
				IUF:UIFrameFlash(self.anchors[i].flash, 0.25, 0.25, 0.5)
			end
			for i = self.chi + 1, self.chiMax do
				self.anchors[i]:SetAlpha(0)
				IUF:UIFrameFlashStop(self.anchors[i].flash)
			end
			self.prevChi = self.chi
		end

		object.bar:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" then
				if powerType == "CHI" or powerType == "LIGHT_FORCE" or powerType == "DARK_FORCE" then
					updateChi(self)
				end
			elseif event == "UNIT_DISPLAYPOWER" or event == "PLAYER_TALENT_UPDATE" then
				self.prevChi = UnitPower("player", chi)
				updateChi(self)
			elseif not UnitHasVehicleUI("player") then
				if not self:IsShown() then
					self:Show()
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
					updateVisible()
				end
				self.prevChi = UnitPower("player", chi)
				updateChi(self)
			elseif self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()
			end
		end)
		object.bar:RegisterEvent("PLAYER_ENTERING_WORLD")
--		object.bar:RegisterEvent("PLAYER_TALENT_UPDATE")
		object.bar:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.bar:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.bar:Hide()

		createTotem(object, 1, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- MONK
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(MonkHarmonyBar, object, nil, updateVisible)
--~ 					setClassBar(PlayerFrameAlternateManaBar, object, 4, updateVisible)
--~ 					PlayerFrameAlternateManaBar:SetScript("OnMouseUp", nil)
--~ 					PlayerFrameAlternateManaBar.SetPoint = PlayerFrameAlternateManaBar.GetPoint
					if TotemFrame then setClassBar(TotemFrame, object, 5, updateVisible) end
					for i = 1, select("#", MonkHarmonyBar:GetRegions()) do
						MonkHarmonyBar.hasBackground = select(i, MonkHarmonyBar:GetRegions())
						if MonkHarmonyBar.hasBackground:GetObjectType() == "Texture" and MonkHarmonyBar.hasBackground:GetName() == "MonkHarmonyBarGlow" then
							if MonkHarmonyBar.hasBackground:GetDrawLayer() == "BACKGROUND" then
								MonkHarmonyBar.backgroundShadow = MonkHarmonyBar.hasBackground
							elseif MonkHarmonyBar.hasBackground:GetDrawLayer() == "BORDER" then
								MonkHarmonyBar.background = MonkHarmonyBar.hasBackground
							end
						end
					end
					MonkHarmonyBar.hasBackground = (MonkHarmonyBar.background and MonkHarmonyBar.backgroundShadow) and true or nil
				end
				MonkHarmonyBar:ClearAllPoints()
--~ 				PlayerFrameAlternateManaBar:ClearAllPoints()
--~ 				PlayerFrameAlternateManaBar:SetStatusBarTexture(SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2"))
--~ 				PlayerFrameAlternateManaBar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
				if TotemFrameTotem2 then TotemFrameTotem2:ClearAllPoints() end
				if IUF.db.classBar.pos == "BOTTOM" then
					if TotemFrameTotem2 then TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9) end
					MonkHarmonyBar:SetPoint("TOP", object.classBar, "TOP", 0, 20)
--~ 					PlayerFrameAlternateManaBar:ClearAllPoints()
--~ 					MonkHarmonyBar.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", MonkHarmonyBar, "BOTTOM", 0, 10)
					if MonkHarmonyBar.hasBackground then
						MonkHarmonyBar.background:SetTexCoord(0.00390625, 0.53515625, 0.35937500, 0.69531250)
						MonkHarmonyBar.backgroundShadow:SetTexCoord(0.00390625, 0.53515625, 0.00781250, 0.34375000)
					end
				else
					if TotemFrameTotem2 then TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8) end
					MonkHarmonyBar:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, -20)
--~ 					PlayerFrameAlternateManaBar:ClearAllPoints()
--~ 					MonkHarmonyBar.SetPoint(PlayerFrameAlternateManaBar, "TOP", MonkHarmonyBar, "TOP", 0, -10)
					if MonkHarmonyBar.hasBackground then
						MonkHarmonyBar.background:SetTexCoord(0.00390625, 0.53515625, 0.69531250, 0.35937500)
						MonkHarmonyBar.backgroundShadow:SetTexCoord(0.00390625, 0.53515625, 0.34375000, 0.00781250)
					end
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					if TotemFrameTotem2 then 
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					end
					MonkHarmonyBar:ClearAllPoints()
					MonkHarmonyBar:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--~ 					PlayerFrameAlternateManaBar:ClearAllPoints()
--~ 					MonkHarmonyBar.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", UIParent, "TOP", 0, 2000)
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.mana:ClearAllPoints()
				object.classBar.addOn.bar:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarTexture(tex)
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				for _, v in pairs(object.classBar.addOn.bar.anchors) do
					v:SetTexture(tex)
					v.flash:SetTexture(tex)
				end
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPLEFT", object.classBar.addOn.mana, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPRIGHT", object.classBar.addOn.mana, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMLEFT", object.classBar.addOn.mana, "TOPLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMRIGHT", object.classBar.addOn.mana, "TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard then
				if TotemFrameTotem2 then
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				MonkHarmonyBar:ClearAllPoints()
				MonkHarmonyBar:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--~ 				PlayerFrameAlternateManaBar:ClearAllPoints()
--~ 				MonkHarmonyBar.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", UIParent, "TOP", 0, 2000)
			end
			object.classBar.addOn:Hide()
		end
	end
--]]	
 
 elseif playerClass == "WARLOCK" then
 	local function updateVisible()	-- WARLOCK
 		if IUF.db.classBar.use then
 			if IUF.db.classBar.useBlizzard then
 				if TotemFrame:IsShown() then
 					if WarlockPowerFrame:IsShown() then
 						IUF.units.player.classBar:SetHeight(64)
 					else
 						IUF.units.player.classBar:SetHeight(40)
 					end
 				elseif WarlockPowerFrame:IsShown() then
 					IUF.units.player.classBar:SetHeight(28)
 				else
 					IUF.units.player.classBar:SetHeight(0.001)
 				end
 			elseif IUF.units.player.classBar.addOn.soulShard:IsShown() then--or IUF.units.player.classBar.addOn.demonicFury:IsShown() or IUF.units.player.classBar.addOn.burningEmber:IsShown() then
 				if IUF.units.player.classBar.addOn.totem:IsShown() then
 					IUF.units.player.classBar:SetHeight(29)
 					IUF.units.player.classBar.addOn:SetHeight(28)
 				else
 					IUF.units.player.classBar:SetHeight(15)
 					IUF.units.player.classBar.addOn:SetHeight(14)
 				end
 			elseif IUF.units.player.classBar.addOn.totem:IsShown() then
 					IUF.units.player.classBar:SetHeight(15)
 					IUF.units.player.classBar.addOn:SetHeight(14)
 			else
 				IUF.units.player.classBar:SetHeight(0.001)
 				IUF.units.player.classBar.addOn:SetHeight(0.001)
 			end
 		else
 			IUF.units.player.classBar:SetHeight(0.001)
 			IUF.units.player.classBar.addOn:SetHeight(0.001)
 		end
 	end

 	function IUF:CreateClassBar(object)	-- WARLOCK
 		createClassBar(object)
 		object = createAddOnClassBar(object)

 		local UnitPower = _G.UnitPower
 		local UnitPowerMax = _G.UnitPowerMax
 		local UnitBuff = _G.UnitBuff
 		local IsPlayerSpell = _G.IsPlayerSpell

 		object.soulShard = CreateFrame("Frame", nil, object)
 		object.soulShard:SetPoint("TOPLEFT", 0, 0)
 		object.soulShard:SetPoint("TOPRIGHT", 0, 0)
 		object.soulShard:SetHeight(14)
 		object.soulShard:SetFrameLevel(object:GetFrameLevel())
 		setAddOnBorder(object.soulShard, UnitPowerMax("player", Enum.PowerType.SoulShards))

 		for _, btn in ipairs(object.soulShard.anchors) do
 			btn:SetAlpha(0)
 			btn:SetVertexColor(0.62, 0.22, 0.76)
 			btn.flash = object.soulShard:CreateTexture(nil, "BORDER")
 			btn.flash:SetVertexColor(0.62, 0.22, 0.76)
 			btn.flash:SetBlendMode("ADD")
 			btn.flash:SetAllPoints(btn)
 			btn.flash:Hide()
 		end

 		object.soulShard:SetScript("OnEvent", function(self, event, _, powerType)
 			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" then
 				if powerType == "SOUL_SHARDS" or event == "UNIT_DISPLAYPOWER" then
 					self.value = UnitPower("player", Enum.PowerType.SoulShards)
 					self.max = UnitPowerMax("player", Enum.PowerType.SoulShards)

 					if self.num ~= self.max then
 						setAddOnBorder(self, self.max)
 					end
 					for i = 1, self.value do
 						self.anchors[i]:SetAlpha(1)
 					end
 					for i = self.prev + 1, self.value do
 						IUF:UIFrameFlash(self.anchors[i].flash, 0.25, 0.25, 0.5)
 					end
 					for i = self.value + 1, self.max do
 						self.anchors[i]:SetAlpha(0)
 						IUF:UIFrameFlashStop(self.anchors[i].flash)
 					end
 					self.prev = self.value
 				end
 --			elseif GetPrimaryTalentTree() == SPEC_WARLOCK_AFFLICTION and IsPlayerSpell(WARLOCK_SOULBURN) and not UnitHasVehicleUI("player") then
 			elseif UnitLevel("player") >= SHARDBAR_SHOW_LEVEL and not UnitHasVehicleUI("player") then
 				if not self:IsShown() then
 					self:Show()
 					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
 					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
 					updateVisible()
 				end
 				self.prev = UnitPower("player", Enum.PowerType.SoulShards)
 				self:GetScript("OnEvent")(self, "UNIT_DISPLAYPOWER")

 			elseif self:IsShown() then
 				self:Hide()
 				self:UnregisterEvent("UNIT_POWER_FREQUENT")
 				self:UnregisterEvent("UNIT_DISPLAYPOWER")
 				updateVisible()

 			end			
 		end)
 		object.soulShard:RegisterEvent("PLAYER_ENTERING_WORLD")
 --		object.soulShard:RegisterEvent("PLAYER_TALENT_UPDATE")
 		object.soulShard:RegisterEvent("SPELLS_CHANGED")
 		object.soulShard:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
 		object.soulShard:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
 		object.soulShard:Hide()
 --[[
 		object.demonicFury = CreateFrame("Frame", nil, object)
 		object.demonicFury:SetPoint("TOPLEFT", 0, 0)
 		object.demonicFury:SetPoint("TOPRIGHT", 0, 0)
 		object.demonicFury:SetHeight(14)
 		object.demonicFury:SetFrameLevel(object:GetFrameLevel())
 		setAddOnBorder(object.demonicFury, 1, true)
 		object.demonicFury.anchors[1].bar:SetStatusBarColor(0.62, 0.22, 0.76)
 		object.demonicFury.anchors[1].bar.add = object.demonicFury.anchors[1].bar:CreateTexture(nil, "ARTWORK")
 		object.demonicFury.anchors[1].bar.add:SetAllPoints(object.demonicFury.anchors[1].bar:GetStatusBarTexture())
 		object.demonicFury.anchors[1].bar.add:SetVertexColor(0.62, 0.22, 0.76, 0.5)
 		object.demonicFury.anchors[1].bar.add:SetBlendMode("ADD")
 		object.demonicFury.anchors[1].bar.add:Hide()

 		object.demonicFury:SetScript("OnEvent", function(self, event, _, powerType)
 			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" then
 				if powerType == "DEMONIC_FURY" or event == "UNIT_DISPLAYPOWER" then
 					self.value = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
 					self.max = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)
 					self.anchors[1].bar:SetMinMaxValues(0, self.max)
 					self.anchors[1].bar:SetValue(self.value)
 					IUF:SetStatusBarValue(self.anchors[1].bar.text, 2, self.value, self.max)
 				end
 			elseif event == "UNIT_AURA" then
 				if findBuffById(WARLOCK_METAMORPHOSIS, "PLAYER") then
 					if not self.isMetamorphosis then
 						self.isMetamorphosis = true
 						self.anchors[1].bar.add:Show()
 					end
 				elseif self.isMetamorphosis then
 					self.isMetamorphosis = nil
 					self.anchors[1].bar.add:Hide()
 				end
 			elseif GetPrimaryTalentTree() == SPEC_WARLOCK_DEMONOLOGY and not UnitHasVehicleUI("player") then
 				if not self:IsShown() then
 					self:Show()
 					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
 					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
 					self:RegisterUnitEvent("UNIT_AURA", "player")
 					updateVisible()
 				end
 				self:GetScript("OnEvent")(self, "UNIT_DISPLAYPOWER")
 				self:GetScript("OnEvent")(self, "UNIT_AURA")
 			elseif self:IsShown() then
 				self:Hide()
 				self:UnregisterEvent("UNIT_POWER_FREQUENT")
 				self:UnregisterEvent("UNIT_DISPLAYPOWER")
 				self:UnregisterEvent("UNIT_AURA")
 				updateVisible()
 			end
 		end)
 		object.demonicFury:RegisterEvent("PLAYER_ENTERING_WORLD")
 		object.demonicFury:RegisterEvent("PLAYER_TALENT_UPDATE")
 		object.demonicFury:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
 		object.demonicFury:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
 		object.demonicFury:Hide()

 		object.burningEmber = CreateFrame("Frame", nil, object)
 		object.burningEmber:SetPoint("TOPLEFT", 0, 0)
 		object.burningEmber:SetPoint("TOPRIGHT", 0, 0)
 		object.burningEmber:SetHeight(14)
 		object.burningEmber:SetFrameLevel(object:GetFrameLevel())
 		setAddOnBorder(object.burningEmber, 4, true)

 		for i, btn in ipairs(object.burningEmber.anchors) do
 			btn.bar:SetStatusBarColor(1, 0.37, 0)
 			btn.bar.max = i * 10
 			btn.bar:SetMinMaxValues((i - 1) * 10, btn.bar.max)
 			btn.bar.flash = btn.bar:CreateTexture(nil, "OVERLAY")
 			btn.bar.flash:SetVertexColor(1, 0.9, 0)
 			btn.bar.flash:SetAllPoints()
 			btn.bar.flash:Hide()
 		end

 		object.burningEmber:SetScript("OnEvent", function(self, event, _, powerType)
 			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" then
 				if powerType == "BURNING_EMBERS" or event == "UNIT_DISPLAYPOWER" then
 					self.value = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)
 					self.max = UnitPowerMax("player", SPELL_POWER_BURNING_EMBERS, true)
 					self.numEmbers = floor(self.max / MAX_POWER_PER_EMBER)
 					if self.num ~= self.numEmbers then
 						setAddOnBorder(self, self.numEmbers)
 					end
 					for _, btn in ipairs(object.burningEmber.anchors) do
 						btn.bar:SetValue(self.value)
 						if btn.bar.max > self.value then
 							if btn.bar.full then
 								btn.bar.full = nil
 								IUF:UIFrameFlashStop(btn.bar.flash)
 								btn.bar.flash:Hide()
 							end
 						elseif not btn.bar.full then
 							btn.bar.full = true
 							if self.ignoreFull then
 								btn.bar.flash:Show()
 							else
 								IUF:UIFrameFlash(btn.bar.flash, 0.25, 0, 0.25, 1)
 							end
 						end
 					end
 					self.ignoreFull = nil
 				end
 			elseif WARLOCK_BURNING_EMBERS and GetPrimaryTalentTree() == SPEC_WARLOCK_DESTRUCTION and IsPlayerSpell(WARLOCK_BURNING_EMBERS) and not UnitHasVehicleUI("player") then
 				if not self:IsShown() then
 					self:Show()
 					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
 					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
 					updateVisible()
 				end
 				self.ignoreFull = true
 				self:GetScript("OnEvent")(self, "UNIT_DISPLAYPOWER")
 			elseif self:IsShown() then
 				self:Hide()
 				self:UnregisterEvent("UNIT_POWER_FREQUENT")
 				self:UnregisterEvent("UNIT_DISPLAYPOWER")
 				updateVisible()
 			end
 		end)
 		object.burningEmber:RegisterEvent("PLAYER_ENTERING_WORLD")
 		object.burningEmber:RegisterEvent("PLAYER_TALENT_UPDATE")
 		object.burningEmber:RegisterEvent("SPELLS_CHANGED")
 		object.burningEmber:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
 		object.burningEmber:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
 		object.burningEmber:Hide()
 --]]

 		createTotem(object, MAX_TOTEMS, "BOTTOM", updateVisible)
 	end
 	
 	function IUF:ClassBarSetup(object)	-- WARLOCK
 		if IUF.db.classBar.use then
 			if IUF.db.classBar.useBlizzard then
 				object.classBar.addOn:Hide()
 				if not object.classBar.setupBlizzard then
 					object.classBar.setupBlizzard = true
 					setClassBar(WarlockPowerFrame, object, nil, updateVisible)
 					setClassBar(TotemFrame, object, 4, updateVisible)
 					local shard, shardBorder
 --[[
 					for i = 1, 4 do
 						shard = _G["ShardBarFrameShard"..i]
 						for j = 1, select("#", shard:GetRegions()) do
 							shardBorder = select(j, shard:GetRegions())
 							if shardBorder:GetObjectType() == "Texture" and shardBorder:GetDrawLayer() == "BORDER" then
 								shard.shardBorder = shardBorder
 								break
 							end
 						end

 						shard = _G["BurningEmbersBarFrameEmber"..i]
 						for j = 1, select("#", shard:GetRegions()) do
 							shardBorder = select(j, shard:GetRegions())
 							if shardBorder:GetObjectType() == "Texture" and shardBorder:GetDrawLayer() == "BORDER" then
 								shard.emberBorder = shardBorder
 								break
 							end
 						end
 						
 					end		
 					for i = 1, select("#", BurningEmbersBarFrame:GetRegions()) do
 						 shard = select(i, BurningEmbersBarFrame:GetRegions())
 						 if shard:GetDrawLayer() == "BACKGROUND" then
 							BurningEmbersBarFrame.background = shard
 							break
 						end
 					end
 ]]
 				end	
 				
 				TotemFrameTotem2:ClearAllPoints()
 				WarlockPowerFrame:ClearAllPoints()
 				if IUF.db.classBar.pos == "BOTTOM" then
 					TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
 					WarlockPowerFrame:SetPoint("TOP", object.classBar, "TOP", 0, -1)
 --[[					
 					local shard
 					for i = 1, 4 do
 						shard = _G["ShardBarFrameShard"..i]
 						shard.shardGlow:ClearAllPoints()
 						shard.shardGlow:SetPoint("TOPLEFT", -2, 1)
 						shard.shardSmokeA:ClearAllPoints()
 						shard.shardSmokeA:SetPoint("TOPLEFT", -8, 5)
 						shard.shardFill:ClearAllPoints()
 						shard.shardFill:SetPoint("TOPLEFT" , 3, -2)
 						shard.shardBorder:ClearAllPoints()
 						shard.shardBorder:SetPoint("TOPLEFT", -5, 3)
 						shard.shardGlow:SetTexCoord(0.01562500, 0.42187500, 0.14843750, 0.32812500)
 						shard.shardSmokeA:SetTexCoord(0.01562500, 0.51562500, 0.34375000, 0.59375000)
 						shard.shardSmokeB:SetTexCoord(0.51562500, 0.01562500, 0.34375000, 0.59375000)
 						shard.shardFill:SetTexCoord(0.01562500, 0.28125000, 0.00781250, 0.13281250)
 						shard.shardBorder:SetTexCoord(0.01562500, 0.82812500, 0.60937500, 0.83593750)
 						shard = _G["BurningEmbersBarFrameEmber"..i]
 						shard.emberBorder:SetTexCoord(0.15234375, 0.29296875, 0.32812500, 0.93750000)
 						shard.emberBorder:ClearAllPoints()
 						shard.emberBorder:SetAllPoints()
 					end
 					BurningEmbersBarFrame.background:ClearAllPoints()
 					BurningEmbersBarFrame.background:SetAllPoints()
 					BurningEmbersBarFrame.background:SetTexCoord(0.00390625, 0.58203125, 0.01562500, 0.29687500)
 ]]
 				else
 					TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8)
 					WarlockPowerFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, 1)
 --[[					
 					local shard
 					for i = 1, 4 do
 						shard = _G["ShardBarFrameShard"..i]
 						shard.shardGlow:ClearAllPoints()
 						shard.shardGlow:SetPoint("TOPLEFT", -2, -3)
 						shard.shardSmokeA:ClearAllPoints()
 						shard.shardSmokeA:SetPoint("TOPLEFT", -8, 1)
 						shard.shardFill:ClearAllPoints()
 						shard.shardFill:SetPoint("TOPLEFT" , 3, -6)
 						shard.shardBorder:ClearAllPoints()
 						shard.shardBorder:SetPoint("TOPLEFT", -5, 2)
 						shard.shardGlow:SetTexCoord(0.01562500, 0.42187500, 0.32812500, 0.14843750)
 						shard.shardSmokeA:SetTexCoord(0.01562500, 0.51562500, 0.59375000, 0.34375000)
 						shard.shardSmokeB:SetTexCoord(0.51562500, 0.01562500, 0.59375000, 0.34375000)
 						shard.shardFill:SetTexCoord(0.01562500, 0.28125000, 0.13281250, 0.00781250)
 						shard.shardBorder:SetTexCoord(0.01562500, 0.82812500, 0.83593750, 0.60937500)
 						shard = _G["BurningEmbersBarFrameEmber"..i]
 						shard.emberBorder:SetTexCoord(0.15234375, 0.29296875, 0.93750000, 0.32812500)
 						shard.emberBorder:ClearAllPoints()
 						shard.emberBorder:SetPoint("TOPLEFT", 0, -2)
 						shard.emberBorder:SetPoint("BOTTOMRIGHT", 0, -2)
 					end
 					BurningEmbersBarFrame.background:ClearAllPoints()
 					BurningEmbersBarFrame.background:SetPoint("TOPLEFT", 0, -9)
 					BurningEmbersBarFrame.background:SetPoint("BOTTOMRIGHT", 0, -9)
 					BurningEmbersBarFrame.background:SetTexCoord(0.00390625, 0.58203125, 0.29687500, 0.01562500)
 --]]					
 				end
 				updateTotemDurationText()
 			else
 				if object.classBar.setupBlizzard then
 					TotemFrameTotem2:ClearAllPoints()
 					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
 					WarlockPowerFrame:ClearAllPoints()
 					WarlockPowerFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
 				end
 				object.classBar.addOn:Show()
 				object.classBar.addOn:ClearAllPoints()
 --				object.classBar.addOn.soulShard:Show()
 				object.classBar.addOn.soulShard:ClearAllPoints()
 --				object.classBar.addOn.demonicFury:ClearAllPoints()
 --				object.classBar.addOn.burningEmber:ClearAllPoints()
 				object.classBar.addOn.totem:ClearAllPoints()
 				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
 				for _, v in pairs(object.classBar.addOn.totem.anchors) do
 					v.bar:SetStatusBarTexture(tex)
 				end
 				for _, v in pairs(object.classBar.addOn.soulShard.anchors) do
 					v:SetTexture(tex)
 					v.flash:SetTexture(tex)
 				end
 --[[
 				object.classBar.addOn.demonicFury.anchors[1].bar:GetStatusBarTexture(tex)
 				object.classBar.addOn.demonicFury.anchors[1].bar.add:SetTexture(tex)
 				for _, v in pairs(object.classBar.addOn.burningEmber.anchors) do
 					v.bar:SetStatusBarTexture(tex)
 					v.bar.flash:SetTexture(tex)
 				end
 --]]
 				if IUF.db.classBar.pos == "BOTTOM" then
 					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
 					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
 					object.classBar.addOn.soulShard:SetPoint("TOPLEFT", 0, 0)
 					object.classBar.addOn.soulShard:SetPoint("TOPRIGHT", 0, 0)
 --					object.classBar.addOn.demonicFury:SetPoint("TOPLEFT", 0, 0)
 --					object.classBar.addOn.demonicFury:SetPoint("TOPRIGHT", 0, 0)
 --					object.classBar.addOn.burningEmber:SetPoint("TOPLEFT", 0, 0)
 --					object.classBar.addOn.burningEmber:SetPoint("TOPRIGHT", 0, 0)
 					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
 					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
 				else
 					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
 					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
 					object.classBar.addOn.soulShard:SetPoint("BOTTOMLEFT", 0, 0)
 					object.classBar.addOn.soulShard:SetPoint("BOTTOMRIGHT", 0, 0)
 --					object.classBar.addOn.demonicFury:SetPoint("BOTTOMLEFT", 0, 0)
 --					object.classBar.addOn.demonicFury:SetPoint("BOTTOMRIGHT", 0, 0)
 --					object.classBar.addOn.burningEmber:SetPoint("BOTTOMLEFT", 0, 0)
 --					object.classBar.addOn.burningEmber:SetPoint("BOTTOMRIGHT", 0, 0)
 					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
 					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
 				end
 			end
 			updateVisible()
 		else
 			if object.classBar.setupBlizzard then
 				TotemFrameTotem2:ClearAllPoints()
 				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
 				WarlockPowerFrame:ClearAllPoints()
 				WarlockPowerFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
 			end
 			object.classBar.addOn:Hide()
 		end
 	end


--~ elseif playerClass == "MAGE" then
--~ 	local function updateVisible()	-- MAGE
--~ 		if IUF.db.classBar.use then
--~ 			if IUF.db.classBar.useBlizzard then
--~ 				if TotemFrame:IsShown() then
--~ 					IUF.units.player.classBar:SetHeight(40)
--~ 				else
--~ 					IUF.units.player.classBar:SetHeight(28)
--~ 				end
--~ 			elseif IUF.units.player.classBar.addOn.totem:IsShown() then
--~ 				IUF.units.player.classBar:SetHeight(29)
--~ 				IUF.units.player.classBar.addOn:SetHeight(28)
--~ 			else
--~ 				IUF.units.player.classBar:SetHeight(15)
--~ 				IUF.units.player.classBar.addOn:SetHeight(14)
--~ 			end
--~ 		else
--~ 			IUF.units.player.classBar:SetHeight(0.001)
--~ 			IUF.units.player.classBar.addOn:SetHeight(0.001)
--~ 		end
--~ 	end

--~ 	function IUF:CreateClassBar(object)	-- MAGE
--~ 		createClassBar(object)
--~ 		object = createAddOnClassBar(object)

--~ 		local UnitPower = _G.UnitPower
--~ 		local UnitPowerMax = _G.UnitPowerMax
--~ 		local UnitBuff = _G.UnitBuff
--~ 		local IsPlayerSpell = _G.IsPlayerSpell
--~ 		local maxComboPoints = UnitPowerMax("player", Enum.PowerType.ArcaneCharges);
--~ 		
--~ 		object.comboPoint = CreateFrame("Frame", nil, object)
--~ 		object.comboPoint:SetPoint("TOPLEFT", 0, 0)
--~ 		object.comboPoint:SetPoint("TOPRIGHT", 0, 0)
--~ 		object.comboPoint:SetHeight(14)
--~ 		object.comboPoint:SetFrameLevel(object:GetFrameLevel())
--~ 		setAddOnBorder(object.comboPoint, maxComboPoints)

--~ 		for _, btn in ipairs(object.comboPoint.anchors) do
--~ 			btn:SetAlpha(0)
--~ 			btn:SetVertexColor(0.33, 0.77, 0.90)
--~ 			btn.flash = object.comboPoint:CreateTexture(nil, "BORDER")
--~ 			btn.flash:SetVertexColor(0.33, 0.77, 0.90)
--~ 			btn.flash:SetBlendMode("ADD")
--~ 			btn.flash:SetAllPoints(btn)
--~ 			btn.flash:Hide()
--~ 		end

--~ 		object.comboPoint:SetScript("OnEvent", function(self, event, _, powerType)
--~ 			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" then
--~ 				if powerType == "ARCANE_CHARGES" or event == "UNIT_DISPLAYPOWER" then
--~ 					self.value = UnitPower("player", Enum.PowerType.ArcaneCharges)
--~ 					self.max = UnitPowerMax("player", Enum.PowerType.ArcaneCharges)

--~ 					if self.num ~= self.max then
--~ 						setAddOnBorder(self, self.max)
--~ 					end
--~ 					for i = 1, self.value do
--~ 						self.anchors[i]:SetAlpha(1)
--~ 					end
--~ 					for i = self.prev + 1, self.value do
--~ 						IUF:UIFrameFlash(self.anchors[i].flash, 0.25, 0.25, 0.5)
--~ 					end
--~ 					for i = self.value + 1, self.max do
--~ 						self.anchors[i]:SetAlpha(0)
--~ 						IUF:UIFrameFlashStop(self.anchors[i].flash)
--~ 					end
--~ 					self.prev = self.value
--~ 				end
--~ 			elseif not UnitHasVehicleUI("player") then
--~ 				if not self:IsShown() then
--~ 					self:Show()
--~ 					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
--~ 					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
--~ 					updateVisible()
--~ 				end
--~ 				self.prev = UnitPower("player", Enum.PowerType.ArcaneCharges)
--~ 				self:GetScript("OnEvent")(self, "UNIT_DISPLAYPOWER")

--~ 			elseif self:IsShown() then
--~ 				self:Hide()
--~ 				self:UnregisterEvent("UNIT_POWER_FREQUENT")
--~ 				self:UnregisterEvent("UNIT_DISPLAYPOWER")
--~ 				updateVisible()

--~ 			end			
--~ 		end)
--~ 		object.comboPoint:RegisterEvent("PLAYER_ENTERING_WORLD")
--~ --		object.comboPoint:RegisterEvent("PLAYER_TALENT_UPDATE")
--~ 		object.comboPoint:RegisterEvent("SPELLS_CHANGED")
--~ 		object.comboPoint:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
--~ 		object.comboPoint:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
--~ 		object.comboPoint:Hide()

--~ 		createTotem(object, MAX_TOTEMS, "BOTTOM", updateVisible)
--~ 	end
--~ 	
--~ 	function IUF:ClassBarSetup(object)	-- MAGE
--~ 		if IUF.db.classBar.use then
--~ 			if IUF.db.classBar.useBlizzard then
--~ 				object.classBar.addOn:Hide()
--~ 				if not object.classBar.setupBlizzard then
--~ 					object.classBar.setupBlizzard = true
--~ 					MageArcaneChargesFrame:ClearAllPoints()
--~ 					setClassBar(MageArcaneChargesFrame, object, UnitPowerMax("player", Enum.PowerType.ArcaneCharges), updateVisible)
--~ 					setClassBar(TotemFrame, object, 4, updateVisible)
--~ 				end	
--~ 				
--~ 				MageArcaneChargesFrame:Show()
--~ 				TotemFrameTotem2:ClearAllPoints()
--~ 				if IUF.db.classBar.pos == "BOTTOM" then
--~ 					MageArcaneChargesFrame:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
--~ 					MageArcaneChargesFrame:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
--~ 					TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
--~ 				else
--~ 					MageArcaneChargesFrame:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
--~ 					MageArcaneChargesFrame:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
--~ 					TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8)				
--~ 				end
--~ 				updateTotemDurationText()
--~ 			else
--~ 				if object.classBar.setupBlizzard then
--~ 					TotemFrameTotem2:ClearAllPoints()
--~ 					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--~ 				end
--~ 				MageArcaneChargesFrame:Hide()
--~ 				
--~ 				object.classBar.addOn:Show()
--~ 				object.classBar.addOn:ClearAllPoints()
--~ 				object.classBar.addOn.comboPoint:ClearAllPoints()
--~ 				object.classBar.addOn.totem:ClearAllPoints()
--~ 				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
--~ 				for _, v in pairs(object.classBar.addOn.totem.anchors) do
--~ 					v.bar:SetStatusBarTexture(tex)
--~ 				end
--~ 				for _, v in pairs(object.classBar.addOn.comboPoint.anchors) do
--~ 					v:SetTexture(tex)
--~ 					v.flash:SetTexture(tex)
--~ 				end

--~ 				if IUF.db.classBar.pos == "BOTTOM" then
--~ 					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
--~ 					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
--~ 					object.classBar.addOn.comboPoint:SetPoint("TOPLEFT", 0, 0)
--~ 					object.classBar.addOn.comboPoint:SetPoint("TOPRIGHT", 0, 0)
--~ 					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
--~ 					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
--~ 				else
--~ 					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
--~ 					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
--~ 					object.classBar.addOn.comboPoint:SetPoint("BOTTOMLEFT", 0, 0)
--~ 					object.classBar.addOn.comboPoint:SetPoint("BOTTOMRIGHT", 0, 0)
--~ 					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
--~ 					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
--~ 				end
--~ 			end
--~ 			updateVisible()
--~ 		else
--~ 			if object.classBar.setupBlizzard then
--~ 				TotemFrameTotem2:ClearAllPoints()
--~ 				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--~ 			end
--~ 			object.classBar.addOn:Hide()
--~ 		end
--~ 	end	
	
elseif playerClass == "ROGUE" then
	local function updateVisible()	-- ROGUE
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if  TotemFrame and TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(40)
				else
					IUF.units.player.classBar:SetHeight(28)
				end
			elseif IUF.units.player.classBar.addOn.totem:IsShown() then
				IUF.units.player.classBar:SetHeight(29)
				IUF.units.player.classBar.addOn:SetHeight(28)
			else
				IUF.units.player.classBar:SetHeight(15)
				IUF.units.player.classBar.addOn:SetHeight(14)
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- ROGUE
		createClassBar(object)
		object = createAddOnClassBar(object)

		local UnitPower = _G.UnitPower
		local UnitPowerMax = _G.UnitPowerMax
		local UnitBuff = _G.UnitBuff
		local IsPlayerSpell = _G.IsPlayerSpell
		local maxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints);
		
		object.comboPoint = CreateFrame("Frame", nil, object)
		object.comboPoint:SetPoint("TOPLEFT", 0, 0)
		object.comboPoint:SetPoint("TOPRIGHT", 0, 0)
		object.comboPoint:SetHeight(14)
		object.comboPoint:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.comboPoint, maxComboPoints)

		for _, btn in ipairs(object.comboPoint.anchors) do
			btn:SetAlpha(0)
			btn:SetVertexColor(unpack(self.colordb.combo))
			btn.flash = object.comboPoint:CreateTexture(nil, "BORDER")
			btn.flash:SetVertexColor(0.76, 0.22, 0.22)
			btn.flash:SetBlendMode("ADD")
			btn.flash:SetAllPoints(btn)
			btn.flash:Hide()
		end

		object.comboPoint:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" then
				if powerType == "COMBO_POINTS" or event == "UNIT_DISPLAYPOWER" then
					self.value = UnitPower("player", Enum.PowerType.ComboPoints)
					self.max = UnitPowerMax("player", Enum.PowerType.ComboPoints)

					if self.num ~= self.max then
						setAddOnBorder(self, self.max)
					end
					for i = 1, self.value do
						self.anchors[i]:SetAlpha(1)
					end
					for i = self.prev + 1, self.value do
						IUF:UIFrameFlash(self.anchors[i].flash, 0.25, 0.25, 0.5)
					end
					for i = self.value + 1, self.max do
						self.anchors[i]:SetAlpha(0)
						IUF:UIFrameFlashStop(self.anchors[i].flash)
					end
					self.prev = self.value
				end
				
			elseif event == "PLAYER_TARGET_CHANGED" then
				self.value = GetComboPoints("player", "target")
				self.max = UnitPowerMax("player", Enum.PowerType.ComboPoints)

				if self.num ~= self.max then
					setAddOnBorder(self, self.max)
				end
				for i = 1, self.value do
					self.anchors[i]:SetAlpha(1)
				end
				for i = self.prev + 1, self.value do
					IUF:UIFrameFlash(self.anchors[i].flash, 0.25, 0.25, 0.5)
				end
				for i = self.value + 1, self.max do
					self.anchors[i]:SetAlpha(0)
					IUF:UIFrameFlashStop(self.anchors[i].flash)
				end
				self.prev = self.value
				
			elseif not UnitHasVehicleUI("player") then
				if not self:IsShown() then
					self:Show()
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
					updateVisible()
				end
				self.prev = UnitPower("player", Enum.PowerType.ComboPoints)
				self:GetScript("OnEvent")(self, "UNIT_DISPLAYPOWER")

			elseif self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()

			end			
		end)
		object.comboPoint:RegisterEvent("PLAYER_ENTERING_WORLD")
--		object.comboPoint:RegisterEvent("PLAYER_TALENT_UPDATE")
		object.comboPoint:RegisterEvent("PLAYER_TARGET_CHANGED")
		object.comboPoint:RegisterEvent("SPELLS_CHANGED")
		object.comboPoint:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.comboPoint:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.comboPoint:Hide()

		createTotem(object, MAX_TOTEMS, "BOTTOM", updateVisible)
	end
	
	function IUF:ClassBarSetup(object)	-- ROGUE
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					if ComboPointPlayerFrame then
						ComboPointPlayerFrame:ClearAllPoints()
						setClassBar(ComboPointPlayerFrame, object, UnitPowerMax("player", Enum.PowerType.ComboPoints), updateVisible)
					end
					if TotemFrame then
					setClassBar(TotemFrame, object, 4, updateVisible)
					end
				end	
				
				if ComboPointPlayerFrame then
					ComboPointPlayerFrame:Show()
				end
				if TotemFrameTotem2 then TotemFrameTotem2:ClearAllPoints() end
				if IUF.db.classBar.pos == "BOTTOM" then				
					if ComboPointPlayerFrame then
						ComboPointPlayerFrame:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
						ComboPointPlayerFrame:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					end
					if TotemFrameTotem2 then TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9) end
				else
					if ComboPointPlayerFrame then
						ComboPointPlayerFrame:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
						ComboPointPlayerFrame:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					end
					if TotemFrameTotem2 then TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8)			end	
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard and TotemFrameTotem2 then
					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				if ComboPointPlayerFrame then
					ComboPointPlayerFrame:Hide()
				end
				
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.comboPoint:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				for _, v in pairs(object.classBar.addOn.comboPoint.anchors) do
					v:SetTexture(tex)
					v.flash:SetTexture(tex)
				end

				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
			if object.classBar.setupBlizzard and TotemFrameTotem2 then
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
			end
			object.classBar.addOn:Hide()
		end
	end	
else
	local function updateVisible()	-- OTHER
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame and TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(42)
				else
					IUF.units.player.classBar:SetHeight(0.001)
				end
			elseif IUF.units.player.classBar.addOn.totem:IsShown() then
				IUF.units.player.classBar:SetHeight(15)
				IUF.units.player.classBar.addOn:SetHeight(14)
			else
				IUF.units.player.classBar:SetHeight(0.001)
				IUF.units.player.classBar.addOn:SetHeight(0.001)
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- OTHER
		createClassBar(object)
		object = createAddOnClassBar(object)
		createTotem(object, MAX_TOTEMS, "TOP", updateVisible)
		if playerClass == "SHAMAN" then
			object.totem.anchors[1].bar:SetStatusBarColor(1, 0, 0)
			object.totem.anchors[2].bar:SetStatusBarColor(0, 1, 0)
			object.totem.anchors[3].bar:SetStatusBarColor(0, 1, 1)
			object.totem.anchors[4].bar:SetStatusBarColor(0, 0, 1)
		end
		self.max, self.cur = UnitPowerMax("player", 0), UnitPower("player", 0)
		if self.max > 0 then

			object.mana = CreateFrame("Frame", nil, object)
			object.mana:SetPoint("TOPLEFT", 0, 0)
			object.mana:SetPoint("TOPRIGHT", 0, 0)
			object.mana:SetHeight(14)
			object.mana:SetFrameLevel(object:GetFrameLevel())
			setAddOnBorder(object.mana, 1, true)
			object.mana.text = object.mana:CreateFontString(nil, "OVERLAY", "FriendsFont_Small")
			object.mana.text:SetPoint("CENTER", 0, 0)
			local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
			object.mana.anchors[1].bar:SetStatusBarTexture(tex)
			object.mana.anchors[1].bar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
			object.mana:SetScript("OnEvent", function(self, event, _, powerType)
				if event == "UNIT_POWER_FREQUENT" or event == "UNIT_POWER_UPDATE" then
					if powerType == "MANA" then
						self.cur = UnitPower("player", 0)
						self.anchors[1].bar:SetValue(self.cur)
						IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
					end
				elseif event == "UNIT_MAXPOWER" then
					if powerType == "MANA" then
						self.max, self.cur = UnitPowerMax("player", 0), UnitPower("player", 0)
						self.anchors[1].bar:SetMinMaxValues(0, self.max)
						self.anchors[1].bar:SetValue(self.cur)
						IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
					end
				elseif UnitPowerType("player") == 0 or UnitHasVehicleUI("player") then
					if self:IsShown() then
						self:Hide()
						self:UnregisterEvent("UNIT_MAXPOWER")
						self:UnregisterEvent("UNIT_POWER_UPDATE")
						self:UnregisterEvent("UNIT_POWER_FREQUENT")
						updateVisible()
					end
				else
					if not self:IsShown() then
						self:Show()
						self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
						self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
						self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
						updateVisible()
					end
					self:GetScript("OnEvent")(self, "UNIT_MAXPOWER", nil, "MANA")
				end
			end)
			object.mana:RegisterEvent("PLAYER_ENTERING_WORLD")
			object.mana:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
			object.mana:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
			object.mana:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
			object.mana:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
			object.mana:Hide()
		
		end
	end

	function IUF:ClassBarSetup(object)	-- OTHER
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					if TotemFrame then setClassBar(TotemFrame, object, 4, updateVisible) end
				end
				if TotemFrameTotem2 then
				TotemFrameTotem2:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					TotemFrameTotem2:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
				else
					TotemFrameTotem2:SetPoint("TOP", object.classBar, "TOP", -19, -8)
				end
				updateTotemDurationText()
				end
			else
				if object.classBar.setupBlizzard and TotemFrameTotem2 then

					TotemFrameTotem2:ClearAllPoints()
					TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
			end
			updateVisible()
		else
			object.classBar.addOn:Hide()
			if object.classBar.setupBlizzard and TotemFrameTotem2 then
				TotemFrameTotem2:ClearAllPoints()
				TotemFrameTotem2:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
			end
		end
	end
end