if GetLocale()=="zhTW" or GetLocale()=="zhCN" then return end
local IUF = InvenUnitFrames

local _G = _G
local pairs = _G.pairs
local random = _G.random
local UnitClass = _G.UnitClass

local objectName = { ["player"] = "플레이어", ["pet"] = "소환수", ["pettarget"] = "소환수의 대상", ["target"] = "대상", ["targettarget"] = "대상의 대상", ["targettargettarget"] = "대상의 대상의 대상", ["focus"] = "주시대상", ["focustarget"] = "주시대상의 대상", ["focustargettarget"] = "주시대상의 대상의 대상" }
for i = 1, MAX_PARTY_MEMBERS do
	objectName["party"..i] = "파티"..i
	objectName["partypet"..i] = "파티"..i.."의 소환수"
	objectName["party"..i.."target"] = "파티"..i.."의 대상"
	objectName["party"..i.."targettarget"] = "파티"..i.."의 대상의 대상"
end
for i = 1, MAX_BOSS_FRAMES do
	objectName["boss"..i] = "보스"..i
end

local objectClass = { "WARRIOR", "PALADIN", "DEATHKNIGHT", "ROGUE", "PRIEST", "MAGE", "WARLOCK", "HUNTER", "DRUID", "SHAMAN", "MONK" }
local classText = { ["WARRIOR"] = "전사", ["PALADIN"] = "성기사", ["DEATHKNIGHT"] = "죽음의 기사", ["ROGUE"] = "도적", ["PRIEST"] = "사제", ["MAGE"] = "마법사", ["WARLOCK"] = "흑마법사", ["HUNTER"] = "사냥꾼", ["DRUID"] = "드루이드", ["SHAMAN"] = "주술사", ["MONK"] = "수도사" }
local classPowerType = { ["WARRIOR"] = 1, ["ROGUE"] = 3, ["DEATHKNIGHT"] = 6 }

local dummy = function() end

local function previewToggle()
	if IUF.previewMode then
		for _, object in pairs(IUF.units) do
			if object.preview then
				if IUF.db.units[object.objectType].active and not object:IsVisible() then
					if object.parent then
						if IUF.units[object.parent]:IsVisible() then
							object.preview:SetParent(IUF.units[object.parent])
						elseif IUF.units[object.parent].preview then
							object.preview:SetParent(IUF.units[object.parent].preview)
						else
							object.preview:SetParent(IUF)
						end
					else
						object.preview:SetParent(IUF)
					end
					object.preview:Show()
				else
					object.preview:Hide()
				end
			end
		end
	end
end

local function previewOnUpdate(preview, timer)
	if preview:GetAlpha() == 0 then return end
	preview.healthtimer = (preview.healthtimer or random(1, 10)) - timer
	if preview.healthtimer <= 0 then
		preview.healthtimer = random(1, 10)
		preview.values.health = max(min(preview.values.health + floor(random(-25, 25) / 100 * preview.values.healthmax), preview.values.healthmax), 0)
		preview.values.dead = preview.values.health == 0 and 1 or nil
		IUF.callbacks.Health(preview)
		IUF.callbacks.State(preview)
		IUF.callbacks.StateColor(preview)
	end
	if preview.values.dead then
		preview.values.combat = nil
		IUF.callbacks.CombatIcon(preview)
		IUF.callbacks.Health(preview)
		IUF.callbacks.Power(preview)
		if preview.castingBar and preview.castingBar.bar.endTime then
			preview.castingBar.bar.endTime = nil
			preview.values.castingEndTime = nil
			IUF.callbacks.CastingBar(preview)
			IUF.callbacks.CastingBarColor(preview)
		end
		return
	elseif not preview.values.combat then
		preview.values.combat = 1
		IUF.callbacks.CombatIcon(preview)
		IUF.callbacks.Health(preview)
		IUF.callbacks.Power(preview)
	end
	if preview.powertick then
		preview.powerticktimer = (preview.powerticktimer or preview.powertick) - timer
		if preview.powerticktimer <= 0 then
			preview.powerticktimer = preview.powertick
			preview.values.power = min(preview.values.power + 20, preview.values.powermax)
			IUF.callbacks.Power(preview)
		end
		preview.powertimer = (preview.powertimer or random(1, 5)) - timer
		if preview.powertimer <= 0 then
			preview.powertimer = random(1, 5)
			preview.values.power = max(preview.values.power - random(10, 42), 0)
			IUF.callbacks.Power(preview)
		end
	else
		preview.powertimer = (preview.powertimer or random(1, 10)) - timer
		if preview.powertimer <= 0 then
			preview.powertimer = random(1, 10)
			preview.values.power = max(min(preview.values.power + floor(random(-20, 20) / 100 * preview.values.powermax), preview.values.powermax), 0)
			IUF.callbacks.Power(preview)
		end
	end
	preview.updateTime = (preview.updateTime or 0) + timer
	preview.currentTime = GetTime()
	if preview.updateTime > 1 then
		preview.updateTime = 0
		if not preview.values.castingEndTime and random(1, 3) == 1 then
			preview.values.castingIsChannel = random(1, 3) == 1
			preview.values.castingIcon = select(3, GetSpellInfo(random(10, 60000))) or "Interface\\Icons\\Temp"
			preview.values.castingStartTime = preview.currentTime * 1000
			preview.values.castingEndTime = (preview.currentTime + random(15, 50) / 10) * 1000
			preview.values.castingName = "시전바"
			IUF.callbacks.CastingBar(preview)
			IUF.callbacks.CastingBarColor(preview)
		end
	end
	if preview.castingBar and preview.castingBar.bar.endTime and preview.castingBar.bar.endTime <= preview.currentTime then
		preview.castingBar.bar.endTime = nil
		preview.values.castingEndTime = nil
		IUF.callbacks.CastingBar(preview)
		IUF.callbacks.CastingBarColor(preview)
	end
end

local function previewOnShow(preview)
	preview:SetLocation()
	IUF.callbacks.Aggro(preview)
end

local function previewOnHide(preview)
	IUF:UnregisterFlash(preview.portrait.aggro)
	IUF:UnregisterFlash(preview.aggroBorder)
end

local function createPreview(object)
	local preview = CreateFrame("Button", object:GetName().."_Preview", IUF)
	preview:Hide()
	preview:SetFrameStrata("BACKGROUND")
	preview:SetFrameLevel(object:GetFrameLevel())
	preview:RegisterForClicks("AnyUp")
	preview:SetClampedToScreen(true)
	preview.isPreview = true
	preview.shown = true
	preview.unit = "player"
	preview.realunit = object.realunit
	preview.objectType = object.objectType
	preview.objectIndex = object.objectIndex
	preview.needAutoUpdate = object.needAutoUpdate
	preview.parent = object.parent
	preview.SetLocation = object.SetLocation
	preview.db = object.db
	preview.buff, preview.debuff = { filters = {} }, { filters = {} }
	preview:SetScript("OnShow", previewOnShow)
	preview:SetScript("OnHide", previewOnHide)
	preview:SetScript("OnEnter", object:GetScript("OnEnter"))
	preview:SetScript("OnLeave", object:GetScript("OnLeave"))
	object:HookScript("OnShow", previewToggle)
	object:HookScript("OnHide", previewToggle)
	preview.values = { parent = preview, guid = "Preview", level = 80, name = objectName[object.realunit], connect = 1, visible = 1, raidtarget = random(1, 8) }
	if preview.objectType == "pet" or preview.objectType == "partypet" then
		preview.values.class = "PET"
		preview.values.healthmax = random(6000, 25000)
		if preview.objectType == "pet" then
			if select(2, UnitClass("player")) == "HUNTER" then
				preview.values.powertype = 2
				preview.values.powermax = 100
			else
				preview.values.powertype = 0
				preview.values.powermax = random(4000, 10000)
			end
		elseif IUF.units[preview.realunit:gsub("pet", "")].preview then
			if IUF.units[preview.realunit:gsub("pet", "")].preview.values.class == "HUNTER" then
				preview.values.powertype = 2
				preview.values.powermax = 100
			else
				preview.values.powertype = 0
				preview.values.powermax = random(4000, 10000)
			end
		end
	elseif preview.objectType == "target" or preview.objectType == "boss" or preview.objectType == "pettarget" or (preview.objectType:find("(.+)target$") and random(1, 2) == 1) and preview.objectType ~= "targettarget" then
		preview.values.class = "PET"
		preview.values.attack = 1
		preview.values.faction = "ENEMY"
		if preview.objectType == "target" or preview.objectType == "boss" then
			preview.values.level = -1
			preview.values.classification = "worldboss"
		else
			preview.values.level = 82
			preview.values.classification = "elite"
			preview.values.elite = 1
		end
		if random(1, 2) == 1 then
			preview.values.powertype = 0
			preview.values.powermax = random(5000, 1000000)
		else
			preview.values.powertype, preview.values.powermax, preview.values.power = 1, 100, 0
			preview.nopower = true
		end
		preview.values.healthmax = random(50000, 10000000)
	else
		preview.values.class = objectClass[random(1, preview.objectType == "targettarget" and 3 or 10)]
		if preview.realunit == "party4" then
			preview.values.connect, preview.values.visible = nil
			preview.values.healthmax, preview.values.powermax = 1, 1
			preview.values.powertype = classPowerType[preview.values.class] or 0
		else
			preview.values.healthmax = random(16000, 40000)
			preview.values.powertype = classPowerType[preview.values.class] or 0
			preview.values.powermax = preview.values.powertype == 0 and random(5600, 32000) or 100
		end
		if preview.objectType == "party" and IUF.units[object.vehicleunit] and IUF.units[object.vehicleunit].preview and IUF.units[object.vehicleunit].preview.values.powertype == nil then
			if preview.class == "HUNTER" then
				IUF.units[object.vehicleunit].preview.values.powertype = 2
				IUF.units[object.vehicleunit].preview.values.powermax = 100
			else
				IUF.units[object.vehicleunit].preview.values.powertype = 0
				IUF.units[object.vehicleunit].preview.values.powermax = random(4000, 10000)
			end
			IUF.units[object.vehicleunit].preview.values.power = IUF.units[object.vehicleunit].preview.values.powermax
			IUF.callbacks.Power(IUF.units[object.vehicleunit].preview)
		end
	end
	if preview.values.class ~= "PET" then
		preview.values.player = 1
		preview.values.classtext = classText[preview.values.class]
	end
	preview.values.health = preview.values.healthmax
	if not preview.nopower then
		preview.values.power = preview.values.powermax
	end
	if preview.realunit == "party1" then
		preview.values.leader = 1
		preview.values.looter = 1
		preview.values.afk = 1
	elseif preview.realunit == "party2" then
		preview.values.pvp = 1
	elseif preview.realunit == "party3" then
		preview.values.aggro = 1
	elseif preview.realunit == "targettarget" then
		preview.values.aggro = 1
	end
	if preview.values.powertype == 2 or preview.values.powertype == 3 then
		preview.powertick = 2.5
	end
	preview.values.combat = 1
	preview:SetWidth(object.db.width)
	preview:SetHeight(object.db.height)
	preview:SetScale(object.db.scale)
	IUF:CreateObjectElements(preview)
	IUF:SetObjectSkin(preview)
	IUF:RegisterMoving(preview)
	if preview.values.connect then
		preview:SetScript("OnUpdate", previewOnUpdate)
	end
	return preview
end

local function createMovingAnchor()
	IUF.movingFrame.yline = IUF.movingFrame:CreateTexture(nil, "OVERLAY")
	IUF.movingFrame.yline:SetPoint("CENTER", IUF.movingFrame, "TOPLEFT", 0, 0)
	IUF.movingFrame.yline:SetWidth(1)
	IUF.movingFrame.yline:SetHeight(50)
	IUF.movingFrame.yline:SetTexture(1, 1, 1)
	IUF.movingFrame.yvalue = IUF.movingFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	IUF.movingFrame.yvalue:SetPoint("BOTTOM", IUF.movingFrame.yline, "TOP", 0, 2)
	
	IUF.movingFrame.xline = IUF.movingFrame:CreateTexture(nil, "OVERLAY")
	IUF.movingFrame.xline:SetPoint("CENTER", IUF.movingFrame, "TOPLEFT", 0, 0)
	IUF.movingFrame.xline:SetWidth(50)
	IUF.movingFrame.xline:SetHeight(1)
	IUF.movingFrame.xline:SetTexture(1, 1, 1)
	IUF.movingFrame.xvalue = IUF.movingFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	IUF.movingFrame.xvalue:SetPoint("RIGHT", IUF.movingFrame.xline, "LEFT", -2, 0)
	
	IUF.movingFrame2.xcenter = IUF.movingFrame2:CreateTexture(nil, "ARTWORK")
	IUF.movingFrame2.xcenter:SetTexture(1, 0, 0)
	IUF.movingFrame2.xcenter:SetHeight(1)
	IUF.movingFrame2.xcenter:SetPoint("LEFT", UIParent, "LEFT", 0, 0)
	IUF.movingFrame2.xcenter:SetPoint("RIGHT", UIParent, "RIGHT", 0, 0)
	IUF.movingFrame2.xcenter:SetVertexColor(0,1,0,0.5)
	
	IUF.movingFrame2.ycenter = IUF.movingFrame2:CreateTexture(nil, "ARTWORK")
	IUF.movingFrame2.ycenter:SetTexture(1, 0, 0)
	IUF.movingFrame2.ycenter:SetWidth(1)
	IUF.movingFrame2.ycenter:SetPoint("TOP", UIParent, "TOP", 0, 0)
	IUF.movingFrame2.ycenter:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
	IUF.movingFrame2.ycenter:SetVertexColor(0,1,0,0.5)
	local pixel, tex = 25
	for i = 1, 50 do
		tex = IUF.movingFrame2:CreateTexture(nil, "BORDER")
		tex:SetTexture(1, 1, 1)
		tex:SetPoint("LEFT", UIParent, "LEFT", 0, pixel * i)
		tex:SetPoint("RIGHT", UIParent, "RIGHT", 0, pixel * i)
		tex:SetHeight(1)
		tex:SetVertexColor(0,0,0,0.5)
		tex = IUF.movingFrame2:CreateTexture(nil, "BORDER")
		tex:SetTexture(1, 1, 1)
		tex:SetPoint("LEFT", UIParent, "LEFT", 0, -pixel * i)
		tex:SetPoint("RIGHT", UIParent, "RIGHT", 0, -pixel * i)
		tex:SetHeight(1)
		tex:SetVertexColor(0,0,0,0.5)
		tex = IUF.movingFrame2:CreateTexture(nil, "BORDER")
		tex:SetTexture(1, 0, 0)
		tex:SetPoint("TOP", UIParent, "TOP", pixel * i, 0)
		tex:SetPoint("BOTTOM", UIParent, "BOTTOM", pixel * i, 0)
		tex:SetWidth(1)
		tex:SetVertexColor(0,0,0,0.5)
		tex = IUF.movingFrame2:CreateTexture(nil, "BORDER")
		tex:SetTexture(1, 0, 0)
		tex:SetPoint("TOP", UIParent, "TOP", -pixel * i, 0)
		tex:SetPoint("BOTTOM", UIParent, "BOTTOM", -pixel * i, 0)
		tex:SetWidth(1)
		tex:SetVertexColor(0,0,0,0.5)
	end
end

function IUF:SetPreviewMode(mode)
	mode = (not InCombatLockdown()) and mode or nil
	self.previewMode = mode
	if mode then
		if not self.movingFrame.yvalue then
			createMovingAnchor()
			for _, unit in ipairs(IUF.objectOrder) do
				if unit ~= "player" then
					self.units[unit].preview = createPreview(self.units[unit])
				end
			end
		end
		previewToggle()
		objectName, objectClass, classPowerType = nil
		IUF.movingFrame2:Show()
		if IUF.optionFrame.previewButton then
			IUF.optionFrame.previewButton.title:SetText("Hide preview")
			IUF.optionFrame.previewButton.arg1 = nil
		end
	else
		for _, object in pairs(self.units) do
			if object.preview then
				object.preview:Hide()
			end
		end
		IUF.movingFrame2:Hide()
		if IUF.optionFrame.previewButton then
			IUF.optionFrame.previewButton.title:SetText("Show preview")
			IUF.optionFrame.previewButton.arg1 = true
		end
	end
	self:CollectGarbage()
end

local btn, ba, da

local function auraonenter(aura)
	GameTooltip:SetOwner(aura, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:AddLine(aura.tooltipText)
	GameTooltip:Show()
end

local function createAura(preview, idx, isbuff)
	btn = IUF.CreateAuraButton(preview, isbuff)
	btn:SetScript("OnEnter", auraonenter)
	btn:SetScript("OnLeave", GameTooltip_Hide)
	btn.tooltipText = (isbuff and "Buff " or "Debuff ")..idx
	btn.icon:SetTexture("Interface\\Icons\\Spell_Charge"..(isbuff and "Positive" or "Negative"))
	btn.count:SetText(idx)
	btn.icon.SetTexture = dummy
	btn.count.SetText = dummy
	btn.cooldown.timer.SetText = dummy
	return btn
end

function IUF:SetPreviewAura(preview)
	if preview.isPreview then
		for i = 1, preview.buff.num do
			preview.buff[i] = preview.buff[i] or createAura(preview, i, true)
			preview.buff[i]:ClearAllPoints()
			preview.buff[i]:SetWidth(preview.buff.small)
			preview.buff[i]:SetHeight(preview.buff.small)
			preview.buff[i]:Show()
		end
		for i = preview.buff.num + 1, #preview.buff do
			preview.buff[i]:Hide()
		end
		ba = IUF.SetAuraPos(preview.buff, preview.buff.num)
		for i = 1, preview.debuff.num do
			preview.debuff[i] = preview.debuff[i] or createAura(preview, i)
			preview.debuff[i]:ClearAllPoints()
			preview.debuff[i]:SetWidth(preview.debuff.small)
			preview.debuff[i]:SetHeight(preview.debuff.small)
			preview.debuff[i]:Show()
		end
		for i = preview.debuff.num + 1, #preview.debuff do
			preview.debuff[i]:Hide()
		end
		da = IUF.SetAuraPos(preview.debuff, preview.debuff.num)
		if preview.values.class == "PET" and (preview.objectType:find("target") or preview.objectType == "focus") then
			if preview.debuff.num > 0 then
				preview.auraTopAnchor, preview.auraBottomAnchor = IUF.SetAuraAnchorPos(preview.debuff, da, preview.buff, ba)
			elseif preview.buff.num > 0 then
				preview.auraTopAnchor, preview.auraBottomAnchor = IUF.SetAuraAnchorPos(preview.buff, ba)
			else
				preview.auraTopAnchor, preview.auraBottomAnchor = nil, nil
			end
		elseif preview.buff.num > 0 then
			if preview.debuff.num > 0 then
				preview.auraTopAnchor, preview.auraBottomAnchor = IUF.SetAuraAnchorPos(preview.buff, ba, preview.debuff, da)
			else
				preview.auraTopAnchor, preview.auraBottomAnchor = IUF.SetAuraAnchorPos(preview.buff, ba)
			end
		elseif preview.debuff.num > 0 then
			preview.auraTopAnchor, preview.auraBottomAnchor = IUF.SetAuraAnchorPos(preview.debuff, da)
		else
			preview.auraTopAnchor, preview.auraBottomAnchor = nil, nil
		end
		IUF:SetCastingBarPosition(preview)
	end
end