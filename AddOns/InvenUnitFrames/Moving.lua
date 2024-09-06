local IUF = InvenUnitFrames
local moving = CreateFrame("Frame", nil, UIParent)
IUF.movingFrame = moving
moving:SetFrameStrata("HIGH")
moving:Hide()

local moving2 = CreateFrame("Frame", nil, UIParent)
IUF.movingFrame2 = moving2
moving2:SetFrameStrata("HIGH")

local _G = _G
local floor = _G.floor
local IsAltKeyDown = _G.IsAltKeyDown
local InCombatLockdown = _G.InCombatLockdown

local x1, x2, y1, y2, parent, scale

local function getTypePos(type)
	if IUF.db.units[type].pos[1] then
		return IUF.db.units[type].pos[1], IUF.db.units[type].pos[2]
	elseif IUF.skinPos[IUF.db.skin] and IUF.skinPos[IUF.db.skin][type] and IUF.skinPos[IUF.db.skin][type][1] then
		return IUF.skinPos[IUF.db.skin][type][1], IUF.skinPos[IUF.db.skin][type][2]
	elseif IUF.overrideUnitPos[type] and IUF.overrideUnitPos[type][1] then
		return IUF.overrideUnitPos[type][1], IUF.overrideUnitPos[type][2]
	elseif IUF.units[type] and IUF.units[type].parent then
		return 0, -(1 + IUF.units[type]:GetParent().db.height)
	else
		return 230, -230
	end
end

local function getObjectPos(object)
	parent = object:GetParent()
	scale = object:GetEffectiveScale() / parent:GetEffectiveScale()
	return object:GetLeft() * scale - parent:GetLeft(), object:GetTop() * scale - parent:GetTop()
end

local function loadPos(object)
	object:ClearAllPoints()
	if object.objectType == "party" and object.objectIndex ~= 1 then
		scale = IUF.units["party"..(object.objectIndex - 1)]
		object:SetPoint("TOPLEFT", object.isPreview and scale.preview or scale, "BOTTOMLEFT", 0, -object.db.partyOffset)
	elseif object.objectType == "boss" and object.objectIndex ~= 1 then
		scale = IUF.units["boss"..(object.objectIndex - 1)]
		object:SetPoint("TOPLEFT", object.isPreview and scale.preview or scale, "BOTTOMLEFT", 0, -object.db.bossOffset)
	else
		x1, y1 = getTypePos(object.objectType)
		scale = object:GetParent():GetEffectiveScale() / object:GetEffectiveScale()
		object:SetPoint("TOPLEFT", x1 * scale, y1 * scale)
	end
end

local function savePos(object)
	IUF.db.units[object.objectType].pos[1], IUF.db.units[object.objectType].pos[2] = getObjectPos(object)
	return IUF.db.units[object.objectType].pos[1], IUF.db.units[object.objectType].pos[2]
end

local function updateOptionValue(object, isUpdate)
	if IUF.optionFrame:IsVisible() and IUF.optionFrame.unit == object.objectType and IUF.optionFrame.xPos and IUF.optionFrame.xPos:IsVisible() then
		IUF.optionFrame.xPos:Setup()
		IUF.optionFrame.yPos:Setup()
	end
end

local function objectStartMoving(object)
	if not IUF.db.lock or ((object.objectType == "focus" or object.objectType == "boss") and IsAltKeyDown()) then
		moving:Hide()
		if object.objectType == "party" and object.objectIndex ~= 1 then
			if IUF.units.party1:IsVisible() then
				moving.parent = IUF.units.party1
			elseif IUF.units.party1.preview and IUF.units.party1.preview:IsVisible() then
				moving.parent = IUF.units.party1.preview
			else
				return
			end
		elseif object.objectType == "boss" and object.objectIndex ~= 1 then
			if IUF.units.boss1:IsVisible() then
				moving.parent = IUF.units.boss1
			elseif IUF.units.boss1.preview and IUF.units.boss1.preview:IsVisible() then
				moving.parent = IUF.units.boss1.preview
			else
				return
			end
		elseif object.parent and InCombatLockdown() then
			return
		else
			moving.parent = object
		end
		moving:ClearAllPoints()
		moving:SetAllPoints(moving.parent)
		moving:Show()
		moving.parent:StartMoving()
	end
end

local function objectStopMoving(object)
	if moving:IsVisible() then
		moving:Hide()
	elseif moving.parent then
		moving.parent:StopMovingOrSizing()
		updateOptionValue(moving.parent)
		if not InCombatLockdown() then
			loadPos(IUF.units[moving.parent.realunit])
		end
		if IUF.units[moving.parent.realunit].preview then
			loadPos(IUF.units[moving.parent.realunit].preview)
		end
		moving.parent = nil
	end
end

function IUF:RegisterMoving(object)
	if object.registerMoving then return end
	object.registerMoving = true
	object:SetMovable(true)
	object:RegisterForDrag("LeftButton")
	object:SetUserPlaced(false)
	object:SetScript("OnDragStart", objectStartMoving)
	object:SetScript("OnDragStop", objectStopMoving)
	object:HookScript("OnHide", objectStopMoving)
	self:SetObjectPoint(object)
end

function IUF:SetObjectPoint(object)
	loadPos(object)
end

function IUF:GetObjectPoint(objectType)
	return getTypePos(objectType)
end

moving:RegisterEvent("PLAYER_REGEN_DISABLED")
moving:SetScript("OnEvent", moving.Hide)
moving:SetScript("OnUpdate", function(self)
	if self.parent and self.parent:IsVisible() then
		self.px, self.py = savePos(self.parent)
		updateOptionValue(self.parent)
		if IUF.previewMode and self.xvalue then
			self:SetAlpha(1)
			self.xvalue:SetFormattedText("%.2f", self.px)
			self.yvalue:SetFormattedText("%.2f", -self.py)
		else
			self:SetAlpha(0)
		end
		if self.parent.objectType == "partypet" then
			self.unitformat = "partypet%d"
		elseif self.parent.objectType == "partytarget" then
			self.unitformat = "party%dtarget"
		else
			self.unitformat = nil
		end
		if self.unitformat then
			if InCombatLockdown() then
				self.px, self.py = nil
				self:Hide()
			else
				if self.px ~= self.pxp or self.py ~= self.pyp then
					self.pxp, self.pyp = self.px, self.py
					for i = 1, 4 do
						self.unit = self.unitformat:format(i)
						if self.parent.realunit ~= self.unit then
							loadPos(IUF.units[self.unit])
							if IUF.units[self.unit].preview then
								loadPos(IUF.units[self.unit].preview)
							end
						end
					end
				end
			end
		elseif self.parent.isPreview and not InCombatLockdown() then
			loadPos(IUF.units[self.parent.realunit])
		elseif self.parent.preview then
			loadPos(self.parent.preview)
		end
	else
		self.px, self.py = nil
		self:Hide()
	end
end)
moving:SetScript("OnHide", function(self)
	if self.parent then
		objectStopMoving(self.parent)
	end
end)