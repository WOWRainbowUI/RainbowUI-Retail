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
local GetSpecialization = _G.GetSpecialization
local GetShapeshiftFormID = _G.GetShapeshiftFormID
local InCombatLockdown = _G.InCombatLockdown

local classBarBorderColor = { 0.45, 0.45, 0.45, 1 }
IUF.unit = "player"
if not PlayerFrameAlternateManaBar then PlayerFrameAlternateManaBar = AlternatePowerBar end
PlayerFrameAlternateManaBar.unit = "player"
if not ComboPointDruidPlayerFrame then ComboPointDruidPlayerFrame = DruidComboPointBarFrame end
ComboPointDruidPlayerFrame.unit = "player"


local function setClassBar(frame, object, frameLevel, visible)
	frame:SetParent(object)
	frame:SetFrameLevel(frameLevel or object.classBar:GetFrameLevel())
	frame.layoutOnBottom = nil
	if visible then
		frame:HookScript("OnShow", visible)
		frame:HookScript("OnHide", visible)
	end
	frame:SetToplevel(0)
end

local function createClassBar(object)
	object:SetFrameLevel(4)
	object.classBar = CreateFrame("Frame", object:GetName().."_ClassBar", object)
	object.classBar:SetFrameLevel(3)
end

local function updateTotemDurationText()
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
		for i = 1, f.num + 1 do
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
	local name = C_Spell.GetSpellName(id)
	local rank = nil
	--if name then
		-- local buff = select(10, UnitBuff("player", name, rank, filter))
		local aura = C_UnitAuras.GetBuffDataByIndex("player", name, rank, filter)
		local buff = aura and aura.spellId or nil
		if buff == id then
			return true
		elseif buff then
			rank = 1
			aura = C_UnitAuras.GetBuffDataByIndex("player", rank, filter)
			buff = aura and aura.spellId or nil
			while buff do
				if buff == id then
					return true
				end
				rank = rank + 1
				aura = C_UnitAuras.GetBuffDataByIndex("player", rank, filter)
				buff = aura and aura.spellId or nil
			end
		end
	--end
	return nil
end
--[[
--ComboPointDruidPlayerFrame
local origsetpoint = getmetatable(ComboPointDruidPlayerFrame).__index.SetPoint
local function move1(self)
   self:ClearAllPoints()
	   origsetpoint(self, "TOPLEFT", IUF.units.player, "BOTTOMLEFT", 64, -16)
	   origsetpoint(self, "TOPRIGHT", IUF.units.player, "BOTTOMRIGHT", 64, -16)
	   ComboPointDruidPlayerFrame:SetScale(1.4)
	   ComboPointDruidPlayerFrame:Show()
print("ComboPointDruidPlayerFrame " .. ComboPointDruidPlayerFrame:GetParent():GetName())
if IUF.units.player then
print("IUF.units.player " .. IUF.units.player:GetName())
end
if IUF.units.player and IUF.units.player.classBar then
print("IUF.units.player.classBar " .. IUF.units.player.classBar:GetName())
end
end
hooksecurefunc(ComboPointDruidPlayerFrame, "SetPoint", move1)
move1(ComboPointDruidPlayerFrame)

local origsetParent = getmetatable(ComboPointDruidPlayerFrame).__index.SetParent
local function move2(self)
   origsetParent(self, IUF.units.player)
end
hooksecurefunc(ComboPointDruidPlayerFrame, "SetParent", move2)
move2(ComboPointDruidPlayerFrame)

--TotemFrame
local origsetpoint = getmetatable(TotemFrame).__index.SetPoint
local function move3(self, arg1, arg2, arg3, arg4, arg5)
   self:ClearAllPoints()   
   origsetpoint(self, "TOPLEFT", IUF.units.player, "BOTTOMLEFT", 64, -16)
   origsetpoint(self, "TOPRIGHT", IUF.units.player, "BOTTOMRIGHT", 64, -16)
   TotemFrame:SetScale(1.4)
   TotemFrame:Show()
end
hooksecurefunc(TotemFrame, "SetPoint", move3)
move3(TotemFrame)

local origsetParent = getmetatable(TotemFrame).__index.SetParent
local function move4(self)
   origsetParent(self, IUF.units.player)
end
hooksecurefunc(TotemFrame, "SetParent", move4)
move4(TotemFrame)
--]]
if playerClass == "DRUID" then
	local function updateVisible()	-- DRUID DRUID DRUID DRUID DRUID 
		local GetShapeshiftFormID = _G.GetShapeshiftFormID
		if not InCombatLockdown() then PlayerFrameAlternateManaBar:Hide() end

		local hideMana = false
		if (GetShapeshiftFormID() == DRUID_CAT_FORM or GetShapeshiftFormID() == DRUID_BEAR_FORM) then
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
			if GetSpecialization() == 1 then
			else
				hideMana = true
			end
		end
		
		if IUF.db.classBar.use then
			local height = 0
			-- bliz
			if IUF.db.classBar.useBlizzard then
				--if TotemFrame:IsShown() then
				--	height = height + 15
				--end

			--	if ComboPointDruidPlayerFrame:IsShown() then
			--		height = height + 15
			--	end
			else
			-- iuf
				local classbarShow = false
				if IUF.units.player.classBar.addOn.totem:IsShown() then
					height = height + 15
					classbarShow = true
				end			
				if IUF.units.player.classBar.addOn.comboPoint:IsShown() then
					height = height + 15
					classbarShow = true
				end
			end
			if hideMana then
				IUF.units.player.classBar.addOn.mana:SetAlpha(0)
			else
				height = height + 13
				classbarShow = true
				IUF.units.player.classBar.addOn.mana:SetAlpha(1)
			end
			
			IUF.units.player.classBar:SetAlpha(1)

			if height > 0 then
				IUF.units.player.classBar:SetHeight(height + 1)
				IUF.units.player.classBar.addOn:SetHeight(height)
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
		local UnitHasVehicleUI = _G.UnitHasVehicleUI
		local GetShapeshiftFormID = _G.GetShapeshiftFormID

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
			if IUF.db.classBar.druidManaDisible and (GetShapeshiftFormID() == DRUID_CAT_FORM or GetShapeshiftFormID() == DRUID_BEAR_FORM) then
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
			btn:SetVertexColor(IUF.colordb.combo[1], IUF.colordb.combo[2], IUF.colordb.combo[3])
			btn.flash = object.comboPoint:CreateTexture(nil, "BORDER")
			btn.flash:SetVertexColor(IUF.colordb.combo[1] + 0.2, IUF.colordb.combo[2] + 0.2, IUF.colordb.combo[3] + 0.2)
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
				if event == "UPDATE_SHAPESHIFT_FORM" then
					if IUF.db.classBar.use then
						if IUF.db.classBar.useBlizzard then
							IUF:ClassBarSetup(self:GetParent():GetParent())
						else
							self:Show()
							self:SetAlpha(1)
						end
					end
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
		object.comboPoint:RegisterEvent("UPDATE_SHAPESHIFT_FORM") -- not use
		object.comboPoint:RegisterEvent("SPELLS_CHANGED")
		object.comboPoint:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.comboPoint:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		if UnitPowerType("player") == 3 then
			object.comboPoint:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
			object.comboPoint:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
		end
		object.comboPoint:Hide()
		object.comboPoint:ClearAllPoints()


		createTotem(object, 3, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- DRUID
		local GetShapeshiftFormID = _G.GetShapeshiftFormID
		
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if not object.classBar.setupBlizzard then
					setClassBar(PlayerFrameAlternateManaBar, object, nil, updateVisible)
					PlayerFrameAlternateManaBar:SetScript("OnMouseUp", nil)
					PlayerFrameAlternateManaBar.SetPoint = PlayerFrameAlternateManaBar.GetPoint
					ComboPointDruidPlayerFrame:ClearAllPoints()
					setClassBar(ComboPointDruidPlayerFrame, object, UnitPowerMax("player", Enum.PowerType.ComboPoints), updateVisible)
					setClassBar(TotemFrame, object, 3, updateVisible)
					
					--object.classBar.addOn.comboPoint:ClearAllPoints()
					object.classBar.setupBlizzard = true
				end
				PlayerFrameAlternateManaBar:SetStatusBarTexture(SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2"))
				PlayerFrameAlternateManaBar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
				PlayerFrameAlternateManaBar:ClearAllPoints()

				object.classBar.addOn:Show()
				if GetShapeshiftFormID() == DRUID_CAT_FORM then
					ComboPointDruidPlayerFrame:Show()
					ComboPointDruidPlayerFrame:SetAlpha(1)
				end
				object.classBar.addOn.bg:SetAlpha(0)
				object.classBar.addOn.comboPoint:SetAlpha(0)
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.mana:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				object.classBar.addOn.totem:SetAlpha(0)

				if TotemFrame then
					TotemFrame:ClearAllPoints()
					TotemFrame:SetAlpha(1)
				end
--				PlayerFrameAlternateManaBar.DefaultBorder:ClearAllPoints()

				object.classBar.addOn.comboPoint.bar:SetTexture(tex)
				for _, v in pairs(object.classBar.addOn.comboPoint.anchors) do
					v:SetTexture(tex)
					v.flash:SetTexture(tex)
				end
				PlayerFrameAlternateManaBar:ClearAllPoints()
				ComboPointDruidPlayerFrame:ClearAllPoints()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.mana:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					if TotemFrame then
						if ComboPointDruidPlayerFrame then
							TotemFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, -55)
						else
							TotemFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, -5)
						end
					end
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPRIGHT", 0, 0)
					ComboPointDruidPlayerFrame:SetPoint("TOPLEFT", object.classBar, "BOTTOMLEFT", 17, 3)
					ComboPointDruidPlayerFrame:SetPoint("TOPRIGHT", object.classBar, "BOTTOMRIGHT", 17, 3)
				else
					if TotemFrame then
						if ComboPointDruidPlayerFrame then
							TotemFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 25)
						else
							TotemFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 0)
						end
					end
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMRIGHT", 0, 0)
					ComboPointDruidPlayerFrame:SetPoint("BOTTOMLEFT", object.classBar, "TOPLEFT", 17, 0)
					ComboPointDruidPlayerFrame:SetPoint("BOTTOMRIGHT", object.classBar, "TOPRIGHT", 17, 0)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					PlayerFrameAlternateManaBar:ClearAllPoints()
					if TotemFrame then
						TotemFrame:ClearAllPoints()
						TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					end
					--ComboPointDruidPlayerFrame:ClearAllPoints()
					--setClassBar(ComboPointDruidPlayerFrame, object, UnitPowerMax("player", Enum.PowerType.ComboPoints), updateVisible)
				end
				object.classBar.addOn:Show()
				if not InCombatLockdown() then ComboPointDruidPlayerFrame:Hide() end
				ComboPointDruidPlayerFrame:SetAlpha(0)
				object.classBar.addOn.bg:SetAlpha(0)
				TotemFrame:SetAlpha(0)
				if GetShapeshiftFormID() == DRUID_CAT_FORM then
					object.classBar.addOn.comboPoint:Show()
					object.classBar.addOn.comboPoint:SetAlpha(1)
				end
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.mana:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				object.classBar.addOn.totem:SetAlpha(1)
				--object.classBar.addOn.comboPoint:ClearAllPoints()
				object.classBar.addOn.comboPoint.bar:SetTexture(tex)
				
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarTexture(tex)
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
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
					object.classBar.addOn.mana:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("TOPLEFT", object.classBar.addOn, "BOTTOMLEFT", 0, 15)
					object.classBar.addOn.comboPoint:SetPoint("TOPRIGHT", object.classBar.addOn, "BOTTOMRIGHT", 0, 15)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("BOTTOMLEFT", object.classBar.addOn, "TOPLEFT", 0, 0)
					object.classBar.addOn.comboPoint:SetPoint("BOTTOMRIGHT", object.classBar.addOn, "TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
--			if object.classBar.setupBlizzard then
				PlayerFrameAlternateManaBar:ClearAllPoints()
				if TotemFrame then
					TotemFrame:ClearAllPoints()
					TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
--			end
			object.classBar.addOn:Hide()
			if not InCombatLockdown() then 	ComboPointDruidPlayerFrame:Hide() end
			ComboPointDruidPlayerFrame:SetAlpha(0)
			object.classBar.addOn.comboPoint:Hide()
			object.classBar.addOn.comboPoint:SetAlpha(0)
		end
	end
elseif playerClass == "DEATHKNIGHT" then
	if RuneFrame:GetParent() == UIParent and select(2, RuneFrame:GetPoint()) == PlayerFrame then
		RuneFrame:SetParent(PlayerFrame)
	end

	local function updateVisible()	-- DEATHKNIGHT
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
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

		local runes = { "BLOOD", "UNHOLY", "FROST", "DEATH" }
		local runeOrder = { 1, 2, 3, 4, 5, 6 }
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
			local rune = GetSpecialization()--GetRuneType(id)
			btn:SetAlpha(0.35)
			--if rune then
				btn:SetVertexColor(unpack(runeColors[rune]))
				btn.bar:SetStatusBarColor(unpack(runeColors[rune]))
				btn.bar.flash.tex:SetVertexColor(unpack(runeColors[rune]))
				btn.bar.flash.tex:SetAlpha(0.25)
				btn.bar:Show()
				IUF:UIFrameFlashStop(btn.bar.flash)
				btn.bar.flash:Hide()
				updateRuneCooldown(btn, id)
			--else
			--	btn:SeVertexColor(0, 0, 0)
			--	btn.bar:Hide()
			--	if btn.bar:GetScript("OnUpdate") then
			--		btn.bar:SetScript("OnUpdate", nil)
			--	end
				--btn.rune = nil
			--end
		end

		object.bar:SetScript("OnEvent", function(self, event, id, isEnergize)
			if event == "UNIT_POWER_FREQUENT" then
				if runeOrder[id] then
					if updateRuneCooldown(self.anchors[runeOrder[id]], id) then
						IUF:UIFrameFlash(self.anchors[runeOrder[id]].bar.flash, 0.25, 0.25, 0.5)
					end
				end
			--elseif event == "RUNE_TYPE_UPDATE" then
			--	if runeOrder[id] then
			--		updateRune(self.anchors[runeOrder[id]], id)
			--	end
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
		object.bar:RegisterEvent("PLAYER_TALENT_UPDATE")
		object.bar:RegisterEvent("UNIT_POWER_FREQUENT") --RUNE_TYPE_UPDATE
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
					setClassBar(TotemFrame, object, 4, updateVisible)
				end
				RuneFrame:SetParent(PlayerFrameBottomManagedFramesContainer)
				RuneFrame:ClearAllPoints()
				TotemFrame:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					RuneFrame:SetPoint("TOP", object.classBar, "TOP", 1, 0)
					TotemFrame:SetPoint("TOPRIGHT", RuneFrame, "TOPLEFT", 1, 7)
				else
					RuneFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 1, 2)
					TotemFrame:SetPoint("BOTTOMRIGHT", RuneFrame, "BOTTOMLEFT", 1, -7)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrame:ClearAllPoints()
					TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					RuneFrame:ClearAllPoints()
					RuneFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				RuneFrame:SetParent(IUF.dummyParent)
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
--			if object.classBar.setupBlizzard then
				TotemFrame:ClearAllPoints()
				TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				RuneFrame:ClearAllPoints()
				RuneFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--			end
			object.classBar.addOn:Hide()
		end
	end

elseif playerClass == "PRIEST" then
	local function updateVisible()	-- PRIEST
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(42)
					IUF.units.player.classBar.addOn:SetHeight(42)
				elseif IUF.units.player.classBar.addOn.mana:IsShown() then
					IUF.units.player.classBar:SetHeight(15)
					IUF.units.player.classBar.addOn:SetHeight(14)
				else
					IUF.units.player.classBar:SetHeight(0.001)
					IUF.units.player.classBar.addOn:SetHeight(0.001)
				end
			else
				if IUF.units.player.classBar.addOn.totem:IsShown() and IUF.units.player.classBar.addOn.mana:IsShown() then
					IUF.units.player.classBar:SetHeight(29)
					IUF.units.player.classBar.addOn:SetHeight(28)
				elseif IUF.units.player.classBar.addOn.totem:IsShown() or IUF.units.player.classBar.addOn.mana:IsShown() then
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
		local UnitHasVehicleUI = _G.UnitHasVehicleUI


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
			elseif UnitPowerType("player") == 0 or UnitHasVehicleUI("player") then
				if self:IsShown() then
					self:Hide()
					self:UnregisterEvent("UNIT_MAXPOWER")
					self:UnregisterEvent("UNIT_POWER_UPDATE")
					self:UnregisterEvent("UNIT_POWER_FREQUENT")
					updateVisible()
				end
			else
				if not self:IsShown() and not IUF.db.classBar.useBlizzard then
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
		

		createTotem(object, MAX_TOTEMS, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- PRIEST
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Show()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(TotemFrame, object, 4, updateVisible)
					
				end
				PlayerFrameAlternateManaBar:SetAlpha(1.0)
				PlayerFrameAlternateManaBar:SetScale(1.0)
				object.classBar.addOn:ClearAllPoints()
				TotemFrame:ClearAllPoints()
--~ 				object.classBar.addOn.mana:ClearAllPoints()
--~ 				object.classBar.addOn.mana:Hide()
				object.classBar.addOn.mana:SetAlpha(0.0)
				object.classBar.addOn.mana:SetScale(0.1)
				object.classBar.addOn.bg:SetAlpha(0.0)
				
				if IUF.db.classBar.pos == "BOTTOM" then
					object.classBar.addOn:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					object.classBar.addOn:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					TotemFrame:SetPoint("BOTTOMLEFT", 0, 0)
					TotemFrame:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					TotemFrame:SetPoint("TOPLEFT", 0, 0)
					TotemFrame:SetPoint("TOPRIGHT", 0, 0)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrame:ClearAllPoints()
					TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--~ 					PlayerFrameAlternateManaBar:ClearAllPoints()
--~ 					PlayerFrameAlternateManaBar:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				PlayerFrameAlternateManaBar:SetAlpha(0.0)
				PlayerFrameAlternateManaBar:SetScale(0.1)
				object.classBar.addOn.mana:SetAlpha(1.0)
				object.classBar.addOn.mana:SetScale(1.0)
				object.classBar.addOn.bg:SetAlpha(1.0)
				object.classBar.addOn:Show()
				object.classBar.addOn.mana:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				object.classBar.addOn.mana:ClearAllPoints()
				object.classBar.addOn.mana:SetPoint("TOPLEFT", 0, 0)
				object.classBar.addOn.mana:SetPoint("TOPRIGHT", 0, 0)
				
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				for _, v in pairs(object.classBar.addOn.totem.anchors) do
					v.bar:SetStatusBarTexture(tex)
				end
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarTexture(tex)
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
				
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
			end
			updateVisible()
		else
--			if object.classBar.setupBlizzard then
				TotemFrame:ClearAllPoints()
				TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				PlayerFrameAlternateManaBar:SetAlpha(0.0)
				PlayerFrameAlternateManaBar:SetScale(0.1)
--~ 				PlayerFrameAlternateManaBar:ClearAllPoints()
--~ 				PlayerFrameAlternateManaBar:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--			end
			object.classBar.addOn:Hide()
		end
	end
elseif playerClass == "PALADIN" then
	local function updateVisible()	-- PALADIN
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(40)
				elseif PaladinPowerBarFrame:IsShown() then	-- if GetSpecialization() == SPEC_PALADIN_RETRIBUTION then
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
		local UnitHasVehicleUI = _G.UnitHasVehicleUI

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
			elseif not UnitHasVehicleUI("player") then -- UnitLevel("player") >= PALADINPOWERBAR_SHOW_LEVEL and -- and GetSpecialization() == SPEC_PALADIN_RETRIBUTION
				if not self:IsShown() then
					self:Show()
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
					updateVisible()
				end
				self.prevHoly = UnitPower("player", Enum.PowerType.HolyPower)
				self:GetScript("OnEvent")(self, "UNIT_POWER_FREQUENT", nil, "HOLY_POWER")
			elseif self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()
			end
		end)
		object.bar:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.bar:RegisterEvent("PLAYER_LEVEL_UP")
		object.bar:RegisterEvent("PLAYER_TALENT_UPDATE")	--PLAYER_SPECIALIZATION_CHANGED
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
					setClassBar(TotemFrame, object, 4, updateVisible)
				end
				TotemFrame:ClearAllPoints()

				PaladinPowerBarFrame:SetAlpha(1.0)
				PaladinPowerBarFrame:SetScale(1.0)
 				PaladinPowerBarFrame:SetParent(PlayerFrameBottomManagedFramesContainer)
				PaladinPowerBarFrame:ClearAllPoints()


				if IUF.db.classBar.pos == "BOTTOM" then
					TotemFrame:SetPoint("RIGHT", PaladinPowerBarFrame, "LEFT", 20, 0)
					PaladinPowerBarFrame:SetPoint("TOP", object.classBar, "TOP", 0, 7)
				else
					TotemFrame:SetPoint("RIGHT", PaladinPowerBarFrame, "LEFT", 20, 0)
					PaladinPowerBarFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, -7)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrame:ClearAllPoints()
					TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					PaladinPowerBarFrame:ClearAllPoints()
					PaladinPowerBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end

				PaladinPowerBarFrame:SetAlpha(0.0)
				PaladinPowerBarFrame:SetScale(0.1)
--~ 				PaladinPowerBarFrame:SetParent(IUF.dummyParent)
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
--			if object.classBar.setupBlizzard then
				TotemFrame:ClearAllPoints()
				TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				PaladinPowerBarFrame:ClearAllPoints()
				PaladinPowerBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--			end
			object.classBar.addOn:Hide()
		end
	end
elseif playerClass == "MONK" then
	local function updateVisible()	-- MONK
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				local h = 0
				if TotemFrame:IsShown() then
					h = h + 30
				end
				if MonkHarmonyBarFrame:IsShown() then
					h = h + 30
				end
				if MonkStaggerBar:IsShown() then
					h = h + 14
				end
				if h > 0 then
					IUF.units.player.classBar:SetHeight(h + 1)
					IUF.units.player.classBar.addOn:SetHeight(h)
				else
					IUF.units.player.classBar:SetHeight(0.001)
					IUF.units.player.classBar.addOn:SetHeight(0.001)
				end
--~ 				if TotemFrame:IsShown() then
--~ 					IUF.units.player.classBar:SetHeight(MonkHarmonyBarFrame:IsShown() and 63 or 42)
--~ 				else
--~ 					IUF.units.player.classBar:SetHeight(MonkHarmonyBarFrame:IsShown() and 30 or 0.001)
--~ 				end
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
				if IUF.units.player.classBar.addOn.stagger:IsShown() then
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
		local UnitHasVehicleUI = _G.UnitHasVehicleUI

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
			elseif GetSpecialization() == SPEC_MONK_MISTWEAVER and UnitPowerType("player") ~= 0 and not UnitHasVehicleUI("player") then
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

		local function updateChi(self)	-- SPEC_MONK_BREWMASTER , , SPEC_MONK_WINDWALKER
			self.chi = UnitPower("player", Enum.PowerType.Chi );--UnitPower("player", SPELL_POWER_CHI)
			self.chiMax = UnitPowerMax("player", Enum.PowerType.Chi );--UnitPowerMax("player", SPELL_POWER_CHI)
			if GetSpecialization() ~= SPEC_MONK_WINDWALKER then
				self.chiMax = 0
			end
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
			if self.chiMax > 0 and not self:IsShown() then
				self:Show()
				self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
				self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
				updateVisible()
			elseif self.chiMax == 0 and self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()
			end
		end

		object.bar:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" then
				if powerType == "CHI" or powerType == "LIGHT_FORCE" or powerType == "DARK_FORCE" then
					updateChi(self)
				end
			elseif event == "UNIT_DISPLAYPOWER" then
				self.prevChi = UnitPower("player", chi)
				updateChi(self)
			elseif GetSpecialization() == SPEC_MONK_WINDWALKER and not UnitHasVehicleUI("player") then
				if not self:IsShown() then
					IUF:ClassBarSetup(self:GetParent():GetParent())
					self.prevChi = UnitPower("player", chi)
					updateChi(self)
					self:Show()
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
					updateVisible()
				end
				self.prevChi = UnitPower("player", chi)
				updateChi(self)
				if IUF.db.classBar.use and IUF.db.classBar.useBlizzard and self:GetParent():GetParent() and MonkStaggerBar:GetParent() ~= self:GetParent():GetParent().classBar then
					IUF:ClassBarSetup(self:GetParent():GetParent())
				end
			elseif self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()
			end
		end)
		object.bar:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.bar:RegisterEvent("PLAYER_TALENT_UPDATE")	--PLAYER_SPECIALIZATION_CHANGED
		object.bar:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.bar:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.bar:Hide()



		object.stagger = CreateFrame("Frame", nil, object)
		object.stagger:SetPoint("TOPLEFT", 0, 0)
		object.stagger:SetPoint("TOPRIGHT", 0, 0)
		object.stagger:SetHeight(14)
		object.stagger:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.stagger, 1, true)
		object.stagger.text = object.stagger:CreateFontString(nil, "OVERLAY", "FriendsFont_Small")
		object.stagger.text:SetPoint("CENTER", 0, 0)
		object.stagger:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_DISPLAYPOWER" then
				self.cur = UnitStagger("player")
				self.anchors[1].bar:SetValue(self.cur)
				if self.max then
					IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
				end
			elseif GetSpecialization() == SPEC_MONK_BREWMASTER and not UnitHasVehicleUI("player") then
				if not self:IsShown() then
					self:Show()
					self:SetHeight(14)
					self:SetAlpha(1)
					self:RegisterUnitEvent("UNIT_MAXPOWER", "player")
					self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					self.max, self.cur = UnitHealthMax("player"), UnitStagger("player")
					self.anchors[1].bar:SetMinMaxValues(self.cur, self.max)
					self.anchors[1].bar:SetValue(self.cur)
					IUF:SetStatusBarValue(self.text, 2, self.cur, self.max)
					updateVisible()
				end
				if IUF.db.classBar.use and IUF.db.classBar.useBlizzard and self:GetParent():GetParent() and MonkHarmonyBarFrame:GetParent() ~= self:GetParent():GetParent().classBar then
					IUF:ClassBarSetup(self:GetParent():GetParent())
				end
				self:GetScript("OnEvent")(self, "UNIT_DISPLAYPOWER", nil, "stagger")
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
		object.stagger:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.stagger:RegisterEvent("PLAYER_TALENT_UPDATE")
		object.stagger:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		object.stagger:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED")
		object.stagger:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
		object.stagger:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
		object.stagger:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.stagger:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.stagger:SetAlpha(0)
		object.stagger:SetHeight(0.001)
		object.stagger:Hide()


		createTotem(object, 1, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- MONK
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					setClassBar(MonkHarmonyBarFrame, object, nil, updateVisible)
					setClassBar(MonkStaggerBar, object, nil, updateVisible)
					setAddOnBorder(MonkStaggerBar, 1, true)
--~ 					setClassBar(PlayerFrameAlternateManaBar, object, 4, updateVisible)
--~ 					PlayerFrameAlternateManaBar:SetScript("OnMouseUp", nil)
--~ 					PlayerFrameAlternateManaBar.SetPoint = PlayerFrameAlternateManaBar.GetPoint
					setClassBar(TotemFrame, object, 5, updateVisible)
					for i = 1, select("#", MonkHarmonyBarFrame:GetRegions()) do
						MonkHarmonyBarFrame.hasBackground = select(i, MonkHarmonyBarFrame:GetRegions())
						if MonkHarmonyBarFrame.hasBackground:GetObjectType() == "Texture" and MonkHarmonyBarFrame.hasBackground:GetName() == "MonkHarmonyBarFrameGlow" then
							if MonkHarmonyBarFrame.hasBackground:GetDrawLayer() == "BACKGROUND" then
								MonkHarmonyBarFrame.backgroundShadow = MonkHarmonyBarFrame.hasBackground
							elseif MonkHarmonyBarFrame.hasBackground:GetDrawLayer() == "BORDER" then
								MonkHarmonyBarFrame.background = MonkHarmonyBarFrame.hasBackground
							end
						end
					end
					MonkHarmonyBarFrame.hasBackground = (MonkHarmonyBarFrame.background and MonkHarmonyBarFrame.backgroundShadow) and true or nil
				end
				MonkHarmonyBarFrame:ClearAllPoints()
				MonkStaggerBar:ClearAllPoints()
				MonkHarmonyBarFrame:SetAlpha(1)
				MonkStaggerBar:SetAlpha(1)
				MonkHarmonyBarFrame:SetScale(1)
				MonkStaggerBar:SetScale(1.2)
				TotemFrame:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					TotemFrame.topPadding = 24
					TotemFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, -5)
					MonkHarmonyBarFrame:SetPoint("TOP", object.classBar, "TOP", 0, 0)
					MonkStaggerBar:SetPoint("TOP", object.classBar, "TOP", 0, 0)
				else
					TotemFrame.topPadding = 24
					TotemFrame:SetPoint("TOP", object.classBar, "TOP", -19, -2)
					MonkHarmonyBarFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, 0)
					MonkStaggerBar:SetPoint("BOTTOM", object.classBar, "BOTTOM", 0, 0)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrame:ClearAllPoints()
					TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					MonkHarmonyBarFrame:ClearAllPoints()
					MonkHarmonyBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					MonkStaggerBar:ClearAllPoints()
					MonkStaggerBar:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					MonkHarmonyBarFrame.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", UIParent, "TOP", 0, 2000)
				end
				MonkHarmonyBarFrame:SetAlpha(0)
				MonkStaggerBar:SetAlpha(0)
				MonkHarmonyBarFrame:SetScale(0.1)
				MonkStaggerBar:SetScale(0.1)
				object.classBar.addOn:Show()
				object.classBar.addOn:ClearAllPoints()
				object.classBar.addOn.mana:ClearAllPoints()
				object.classBar.addOn.stagger:ClearAllPoints()
				object.classBar.addOn.bar:ClearAllPoints()
				object.classBar.addOn.totem:ClearAllPoints()
				local tex = SM:Fetch("statusbar", IUF.db.classBar.texture or "Smooth v2")
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarTexture(tex)
				object.classBar.addOn.mana.anchors[1].bar:SetStatusBarColor(self.colordb.power[0][1], self.colordb.power[0][2], self.colordb.power[0][3])
				object.classBar.addOn.stagger.anchors[1].bar:SetStatusBarTexture(tex)
				object.classBar.addOn.stagger.anchors[1].bar:SetStatusBarColor(self.colordb.power[1][1], self.colordb.power[1][2], self.colordb.power[1][3])
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
					object.classBar.addOn.stagger:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.stagger:SetPoint("TOPRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPLEFT", object.classBar.addOn.mana, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("TOPRIGHT", object.classBar.addOn.mana, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
				else
					object.classBar.addOn:SetPoint("BOTTOMLEFT", object.classBar, "BOTTOMLEFT", 0, 0)
					object.classBar.addOn:SetPoint("BOTTOMRIGHT", object.classBar, "BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.mana:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.stagger:SetPoint("BOTTOMLEFT", 0, 0)
					object.classBar.addOn.stagger:SetPoint("BOTTOMRIGHT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMLEFT", object.classBar.addOn.mana, "TOPLEFT", 0, 0)
					object.classBar.addOn.bar:SetPoint("BOTTOMRIGHT", object.classBar.addOn.mana, "TOPRIGHT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
					object.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
				end
			end
			updateVisible()
		else
--			if object.classBar.setupBlizzard then
				TotemFrame:ClearAllPoints()
				TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				MonkHarmonyBarFrame:ClearAllPoints()
				MonkHarmonyBarFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				MonkStaggerBar:ClearAllPoints()
				MonkStaggerBar:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				PlayerFrameAlternateManaBar:ClearAllPoints()
				MonkHarmonyBarFrame.SetPoint(PlayerFrameAlternateManaBar, "BOTTOM", UIParent, "TOP", 0, 2000)
--			end
			object.classBar.addOn:Hide()
		end
	end
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
		-- local UnitBuff = _G.UnitBuff
		local IsPlayerSpell = _G.IsPlayerSpell
		local UnitHasVehicleUI = _G.UnitHasVehicleUI

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
--			elseif GetSpecialization() == SPEC_WARLOCK_AFFLICTION and IsPlayerSpell(WARLOCK_SOULBURN) and not UnitHasVehicleUI("player") then
--			elseif UnitLevel("player") >= SHARDBAR_SHOW_LEVEL and not UnitHasVehicleUI("player") 
			elseif not UnitHasVehicleUI("player") then
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
		object.soulShard:RegisterEvent("PLAYER_TALENT_UPDATE")
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
			elseif GetSpecialization() == SPEC_WARLOCK_DEMONOLOGY and not UnitHasVehicleUI("player") then
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
			elseif WARLOCK_BURNING_EMBERS and GetSpecialization() == SPEC_WARLOCK_DESTRUCTION and IsPlayerSpell(WARLOCK_BURNING_EMBERS) and not UnitHasVehicleUI("player") then
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

				WarlockPowerFrame:SetParent(PlayerFrameBottomManagedFramesContainer)
				TotemFrame:ClearAllPoints()
				WarlockPowerFrame:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					TotemFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
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
					TotemFrame:SetPoint("TOP", object.classBar, "TOP", -19, -8)
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
					TotemFrame:ClearAllPoints()
					TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
					WarlockPowerFrame:ClearAllPoints()
					WarlockPowerFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				
				WarlockPowerFrame:SetParent(IUF.dummyParent)
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
--			if object.classBar.setupBlizzard then
				TotemFrame:ClearAllPoints()
				TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				WarlockPowerFrame:ClearAllPoints()
				WarlockPowerFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--			end
			object.classBar.addOn:Hide()
		end
	end

elseif playerClass == "MAGE" then
	local function updateVisible()	-- MAGE
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				local classBarHeight = 0.001
				if TotemFrame:IsShown() then
					classBarHeight = classBarHeight + 12
				end
				if GetSpecialization() == SPEC_MAGE_ARCANE then
					classBarHeight = classBarHeight + 20
					MageArcaneChargesFrame:Show()
				else
					if not InCombatLockdown() then MageArcaneChargesFrame:Hide() end
				end
				IUF.units.player.classBar:SetHeight(classBarHeight)
			else
				local classBarHeight = 0.001
				local addOnHeight = 0.001
				if IUF.units.player.classBar.addOn.totem:IsShown() then
					classBarHeight = classBarHeight + 15
					addOnHeight = addOnHeight + 14
				end
				if GetSpecialization() == SPEC_MAGE_ARCANE then
					classBarHeight = classBarHeight + 15
					addOnHeight = addOnHeight + 14
				end
				IUF.units.player.classBar:SetHeight(classBarHeight)
				IUF.units.player.classBar.addOn:SetHeight(addOnHeight)
			end
		else
			IUF.units.player.classBar:SetHeight(0.001)
			IUF.units.player.classBar.addOn:SetHeight(0.001)
		end
	end

	function IUF:CreateClassBar(object)	-- MAGE
		createClassBar(object)
		object = createAddOnClassBar(object)

		local UnitPower = _G.UnitPower
		local UnitPowerMax = _G.UnitPowerMax
		-- local UnitBuff = _G.UnitBuff
		local IsPlayerSpell = _G.IsPlayerSpell
		local UnitHasVehicleUI = _G.UnitHasVehicleUI
		local maxComboPoints = UnitPowerMax("player", Enum.PowerType.ArcaneCharges);

		object.comboPoint = CreateFrame("Frame", nil, object)
		object.comboPoint:SetPoint("TOPLEFT", 0, 0)
		object.comboPoint:SetPoint("TOPRIGHT", 0, 0)
		object.comboPoint:SetHeight(14)
		object.comboPoint:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.comboPoint, maxComboPoints)

		for _, btn in ipairs(object.comboPoint.anchors) do
			btn:SetAlpha(0)
			btn:SetVertexColor(0.33, 0.77, 0.90)
			btn.flash = object.comboPoint:CreateTexture(nil, "BORDER")
			btn.flash:SetVertexColor(0.33, 0.77, 0.90)
			btn.flash:SetBlendMode("ADD")
			btn.flash:SetAllPoints(btn)
			btn.flash:Hide()
		end

		object.comboPoint:SetScript("OnEvent", function(self, event, _, powerType)
			if event == "UNIT_POWER_FREQUENT" or event == "UNIT_DISPLAYPOWER" then
				if powerType == "ARCANE_CHARGES" or event == "UNIT_DISPLAYPOWER" then
					self.value = UnitPower("player", Enum.PowerType.ArcaneCharges)
					self.max = UnitPowerMax("player", Enum.PowerType.ArcaneCharges)

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
			elseif not UnitHasVehicleUI("player") and GetSpecialization() == SPEC_MAGE_ARCANE then	--    ⿡      PLAYER_TALENT_UPDATE
				if not self:IsShown() then
					IUF:ClassBarSetup(self:GetParent():GetParent())
					self:Show()
					self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
					self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
					updateVisible()
				end
				self.prev = UnitPower("player", Enum.PowerType.ArcaneCharges)
				self:GetScript("OnEvent")(self, "UNIT_DISPLAYPOWER")

			elseif self:IsShown() then
				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()
			end
		end)
		object.comboPoint:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.comboPoint:RegisterEvent("PLAYER_TALENT_UPDATE")
		object.comboPoint:RegisterEvent("SPELLS_CHANGED")
		object.comboPoint:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
		object.comboPoint:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
		object.comboPoint:Hide()

		createTotem(object, MAX_TOTEMS, "BOTTOM", updateVisible)
	end

	function IUF:ClassBarSetup(object)	-- MAGE
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				object.classBar.addOn:Hide()
				if not object.classBar.setupBlizzard then
					object.classBar.setupBlizzard = true
					MageArcaneChargesFrame:ClearAllPoints()
					setClassBar(MageArcaneChargesFrame, object, UnitPowerMax("player", Enum.PowerType.ArcaneCharges), updateVisible)
					setClassBar(TotemFrame, object, 4, updateVisible)
				end

				MageArcaneChargesFrame:Show()
				TotemFrame:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					MageArcaneChargesFrame:SetPoint("TOP", object.classBar, "TOP", 0, 0)
					TotemFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
				else
					MageArcaneChargesFrame:SetPoint("TOP", object.classBar, "TOP", 0, 0)
					TotemFrame:SetPoint("TOP", object.classBar, "TOP", -19, -8)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrame:ClearAllPoints()
					TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				if not InCombatLockdown() then MageArcaneChargesFrame:Hide() end

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
--			if object.classBar.setupBlizzard then
				TotemFrame:ClearAllPoints()
				TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--			end
			object.classBar.addOn:Hide()
		end
	end

elseif playerClass == "ROGUE" then
	local function updateVisible()	-- ROGUE
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
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
		-- local UnitBuff = _G.UnitBuff
		local IsPlayerSpell = _G.IsPlayerSpell
		local UnitHasVehicleUI = _G.UnitHasVehicleUI
		local maxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints);

		object.comboPoint = CreateFrame("Frame", nil, object)
		object.comboPoint:SetPoint("TOPLEFT", 0, 0)
		object.comboPoint:SetPoint("TOPRIGHT", 0, 0)
		object.comboPoint:SetHeight(14)
		object.comboPoint:SetFrameLevel(object:GetFrameLevel())
		setAddOnBorder(object.comboPoint, maxComboPoints)

		for _, btn in ipairs(object.comboPoint.anchors) do
			btn:SetAlpha(0)
			btn:SetVertexColor(IUF.colordb.combo[1], IUF.colordb.combo[2], IUF.colordb.combo[3])
			btn.flash = object.comboPoint:CreateTexture(nil, "BORDER")
			btn.flash:SetVertexColor(IUF.colordb.combo[1], IUF.colordb.combo[2], IUF.colordb.combo[3])
			btn.flash:SetBlendMode("ADD")
			btn.flash:SetAllPoints(btn)
			btn.flash:Hide()
		end

		object.comboPoint:SetScript("OnEvent", function(self, event, arg1, powerType)
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
						if self.anchors[i].flash then
							IUF:UIFrameFlashStop(self.anchors[i].flash)
						end
					end
					self.prev = self.value
				end
				
			elseif not UnitHasVehicleUI("player") then
				if not self:IsShown() and not InCombatLockdown() then
					self:Show()
				end
				self:GetParent():SetAlpha(1)
				self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
				self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
				updateVisible()
				self.prev = UnitPower("player", Enum.PowerType.ComboPoints)
				self:GetScript("OnEvent")(self, "UNIT_DISPLAYPOWER")

			elseif self:IsShown() then
				self:GetParent():SetAlpha(0)
--~ 				self:Hide()
				self:UnregisterEvent("UNIT_POWER_FREQUENT")
				self:UnregisterEvent("UNIT_DISPLAYPOWER")
				updateVisible()

			end
		end)
		object.comboPoint:RegisterEvent("PLAYER_ENTERING_WORLD")
		object.comboPoint:RegisterEvent("PLAYER_TALENT_UPDATE")
		object.comboPoint:RegisterEvent("UNIT_MAXPOWER")
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
					RogueComboPointBarFrame:ClearAllPoints()
					setClassBar(RogueComboPointBarFrame, object, UnitPowerMax("player", Enum.PowerType.ComboPoints), updateVisible)
					RogueComboPointBarFrame:SetScale(1.0)
					setClassBar(TotemFrame, object, 4, updateVisible)
				end

				RogueComboPointBarFrame:SetParent(PlayerFrameBottomManagedFramesContainer)
				RogueComboPointBarFrame:Show()
				TotemFrame:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					RogueComboPointBarFrame:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					RogueComboPointBarFrame:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					TotemFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
				else
					RogueComboPointBarFrame:SetPoint("TOPLEFT", object.classBar, "TOPLEFT", 0, 0)
					RogueComboPointBarFrame:SetPoint("TOPRIGHT", object.classBar, "TOPRIGHT", 0, 0)
					TotemFrame:SetPoint("TOP", object.classBar, "TOP", -19, -8)
				end
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrame:ClearAllPoints()
					TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end
				RogueComboPointBarFrame:SetParent(IUF.dummyParent)
				if not InCombatLockdown() then RogueComboPointBarFrame:Hide() end

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
--			if object.classBar.setupBlizzard then
				TotemFrame:ClearAllPoints()
				TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--			end
			object.classBar.addOn:Hide()
			if not InCombatLockdown() then RogueComboPointBarFrame:Hide() end
		end
	end
else
	local function updateVisible()	-- OTHER
		if IUF.db.classBar.use then
			if IUF.db.classBar.useBlizzard then
				if TotemFrame:IsShown() then
					IUF.units.player.classBar:SetHeight(42)
				else
					IUF.units.player.classBar:SetHeight(0.001)
				end
			elseif IUF.units.player.classBar.addOn.totem:IsShown() then
				IUF.units.player.classBar:SetHeight(15)
				IUF.units.player.classBar.addOn:SetHeight(14)
				if IUF.units.player.classBar.addOn.mana and IUF.units.player.classBar.addOn.mana:IsShown() then
					IUF.units.player.classBar.addOn.totem:ClearAllPoints()
					if IUF.db.classBar.pos == "BOTTOM" then
						IUF.units.player.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, -15)
						IUF.units.player.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, -15)
					else
						IUF.units.player.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
						IUF.units.player.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
					end
				else
					IUF.units.player.classBar.addOn.totem:ClearAllPoints()
					if IUF.db.classBar.pos == "BOTTOM" then
						IUF.units.player.classBar.addOn.totem:SetPoint("BOTTOMLEFT", 0, 0)
						IUF.units.player.classBar.addOn.totem:SetPoint("BOTTOMRIGHT", 0, 0)
					else
						IUF.units.player.classBar.addOn.totem:SetPoint("TOPLEFT", 0, 0)
						IUF.units.player.classBar.addOn.totem:SetPoint("TOPRIGHT", 0, 0)
					end
				end
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
--~ 		if playerClass == "EVOKER" then
--~ 		
--~ 		end
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
					setClassBar(TotemFrame, object, 4, updateVisible)
				end
				TotemFrame:ClearAllPoints()
				if IUF.db.classBar.pos == "BOTTOM" then
					TotemFrame:SetPoint("BOTTOM", object.classBar, "BOTTOM", -19, 9)
				else
					TotemFrame:SetPoint("TOP", object.classBar, "TOP", -19, -8)
				end
				
				PlayerFrameAlternateManaBar:SetAlpha(1.0)
				PlayerFrameAlternateManaBar:SetScale(1.0)
				EssencePlayerFrame:SetAlpha(1.0)
				EssencePlayerFrame:SetScale(1.0)
				if object.classBar.addOn.mana then
					object.classBar.addOn.mana:SetAlpha(0.0)
					object.classBar.addOn.mana:SetScale(0.1)
					object.classBar.addOn.bg:SetAlpha(0.0)
				end
				
				updateTotemDurationText()
			else
				if object.classBar.setupBlizzard then
					TotemFrame:ClearAllPoints()
					TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
				end

				PlayerFrameAlternateManaBar:SetAlpha(0.0)
				PlayerFrameAlternateManaBar:SetScale(0.1)
				EssencePlayerFrame:SetAlpha(0.0)
				EssencePlayerFrame:SetScale(0.1)
				if object.classBar.addOn.mana then
					object.classBar.addOn.mana:SetAlpha(1.0)
					object.classBar.addOn.mana:SetScale(1.0)
					object.classBar.addOn.bg:SetAlpha(1.0)
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
--			if object.classBar.setupBlizzard then
				PlayerFrameAlternateManaBar:SetAlpha(0.0)
				PlayerFrameAlternateManaBar:SetScale(0.1)
				EssencePlayerFrame:SetAlpha(0.0)
				EssencePlayerFrame:SetScale(0.1)
				TotemFrame:ClearAllPoints()
				TotemFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 2000)
--			end
		end
	end
end