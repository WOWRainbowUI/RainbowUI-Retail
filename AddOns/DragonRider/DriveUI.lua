local _, DR = ...

local L = DR.L
local defaultsTable = DR.defaultsTable

local DriveUI = CreateFrame("Frame")
DriveUI:RegisterEvent("UNIT_POWER_UPDATE")
DriveUI:RegisterEvent("PLAYER_ENTERING_WORLD")
DriveUI:RegisterEvent("SPELLS_CHANGED")
DriveUI:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA")
DriveUI:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA")
DriveUI:RegisterEvent("UPDATE_UI_WIDGET")
DriveUI:RegisterEvent("SPELL_UPDATE_COOLDOWN")

DragonRider_API.DriveUtils.DriveUI = DriveUI

local TurboSpells = {
	[33] = 470932,
	[20] = 470934,
	[50] = 470935,
};

local TurboVehicleSpells = {
	[470934] = 471755, -- 33
	[470932] = 1215073, -- 20
	[470935] = 1215074, -- 50
};

function DriveUI.CheckTraitEngine()
	local TurboVal_Default = 20
	local TurboVal = TurboVal_Default
	local TurboSpell
	for k, v in pairs(TurboSpells) do
		if IsPlayerSpell(v) then
			TurboVal, TurboSpell = k, v
		end
	end

	return TurboVal, TurboSpell
end

local bars = {}
local segmentRange = 20
local maxPower = 100
local segmentCount = math.floor(maxPower / segmentRange)
local barWidth = 30
local spacing = 10

function DriveUI.CreateBar(index)
	local bar = CreateFrame("StatusBar", "DriveStatusBar"..index, UIParent)
	bar:SetSize(30, 30)
	--bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
	--bar:SetStatusBarTexture("Interface\\AddOns\\DragonRider\\Textures\\vigorcircle")
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)

	bar.bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	bar.bg:SetAllPoints(true)
	--bar.bg:SetAtlas("dragonriding_vigor_background")
	--bar.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)

	bar.border = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	--bar.border:SetPoint("TOPLEFT", bar, "TOPLEFT", -12, 12)
	--bar.border:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 12, -12)



	--bar.border:SetAtlas("dragonriding_vigor_frame")

	-- goblin theme?
	bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
	bar.bg:SetTexture("Interface\\VEHICLES\\UI-Vehicles-FuelTank")
	bar.border:SetTexture("Interface\\VEHICLES\\UI-Vehicles-FuelTank")
	bar.bg:SetTexCoord(.5,1,0,1)
	bar.border:SetTexCoord(0,.5,0,1)
	bar.border:SetPoint("TOPLEFT", bar, "TOPLEFT", -5, 0)
	bar.border:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 5, 0)

	--bar:SetStatusBarColor(0.2, 0.6, 1)
	--bar:SetStatusBarColor(1, 1, 1)
	bar:SetStatusBarColor(.3, 1, .3)

	if index == 1 then
		bar:SetPoint("CENTER", UIParent, "CENTER", -80, 0)
	else
		bar:SetPoint("LEFT", bars[index - 1], "RIGHT", 10, 0)
	end

	return bar
end

function DriveUI.HideBars()
	for i = 1, #bars do
		bars[i]:Hide()
	end
end

local scheduledCDTimer = nil

function DriveUI.TurboSpellsOnCD()
	local TurboVal, TurboSpell = DriveUI.CheckTraitEngine()
	for k, v in pairs(TurboVehicleSpells) do
		if k == TurboSpell then
			local isEnabled, startTime, modRate, duration
			if C_Spell.GetSpellCooldown then
				local cd = C_Spell.GetSpellCooldown(v)
				isEnabled, startTime, modRate, duration = cd.isEnabled, cd.startTime, cd.modRate, cd.duration
			else
				isEnabled, startTime, modRate, duration = GetSpellCooldown(v)
			end

			if startTime > 0 and duration > 0 then
				local cdLeft = startTime + duration - GetTime()

				if not scheduledCDTimer then
					scheduledCDTimer = C_Timer.NewTimer(cdLeft, function()
						DriveUI.UpdateBars()
						scheduledCDTimer = nil
					end)
				end

				return true
			else
				return false
			end
		end
	end
end


function DriveUI.UpdateBarConfig()
	segmentRange = DriveUI.CheckTraitEngine()
	segmentCount = math.floor(maxPower / segmentRange)

	local totalWidth = barWidth * segmentCount + spacing * (segmentCount - 1)
	local Xplacement = -totalWidth / 2 + barWidth / 2

	DriveUI.HideBars()

	if not DragonRider_API.DriveUtils.IsDriving() then
		return
	end

	for i = 1, segmentCount do
		if not bars[i] then
			bars[i] = DriveUI.CreateBar(i)
		end
		bars[i]:SetMinMaxValues(0, 1)
		bars[i]:SetValue(0)
		bars[i]:SetOrientation("VERTICAL")
		bars[i]:Show()
	end

	bars[1]:ClearAllPoints()

	-- Move first bar
	if PlayerPowerBarAlt and PlayerPowerBarAlt.barInfo and PlayerPowerBarAlt.barInfo.ID and PlayerPowerBarAlt.barInfo.ID == 720 then
		bars[1]:SetPoint("CENTER", PlayerPowerBarAlt, "CENTER", Xplacement, 0)
	else
		bars[1]:SetPoint("CENTER", UIParent, "CENTER", Xplacement, 0)
	end
end

function DriveUI.UpdateBars()
	local power = UnitPower("player", Enum.PowerType.Alternate)
	local activeBarIndex = 0

	for i = 1, segmentCount do
		local lower = (i - 1) * segmentRange
		local fill = 0

		if power > lower then
			fill = math.min((power - lower) / segmentRange, 1)
		end

		if bars[i] then
			bars[i]:SetValue(fill)

			-- Determine active bar (partially filled)
			if fill > 0 and fill < 1 then
				activeBarIndex = i
			end
		end
	end

	-- Apply bar colors
	for i = 1, segmentCount do
		if bars[i] then
			if DriveUI.TurboSpellsOnCD() then
				if i == activeBarIndex then
					bars[i]:SetStatusBarColor(.5, .5, .5)
				else
					bars[i]:SetStatusBarColor(.3, .5, .3)
				end
			else
				if i == activeBarIndex then
					bars[i]:SetStatusBarColor(1, 1, 1)
				else
					bars[i]:SetStatusBarColor(.3, 1, .3)
				end
			end
		end
	end
end

DriveUI:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_GAINS_VEHICLE_DATA" or event == "PLAYER_LOSES_VEHICLE_DATA" or event == "UPDATE_UI_WIDGET" then
		DriveUI.UpdateBarConfig()
		DriveUI.UpdateBars()
	end

	if not DragonRider_API.DriveUtils.IsDriving() then
		DriveUI.HideBars()
		return
	end

	if event == "UNIT_POWER_UPDATE" then
		local unit, powerType = ...
		if unit == "player" and powerType == "ALTERNATE" then
			DriveUI.UpdateBars()
		end
	elseif event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" then
		DriveUI.UpdateBarConfig()
		DriveUI.UpdateBars()
	end

	-- hide widget test
	if event == "UPDATE_UI_WIDGET" then
		if PlayerPowerBarAlt and PlayerPowerBarAlt.barInfo and PlayerPowerBarAlt.barInfo.ID and PlayerPowerBarAlt.barInfo.ID == 720 then
			if (PlayerPowerBarAlt:IsShown()) then
				PlayerPowerBarAlt:Hide()
			end
		end
	end

	if event == "SPELL_UPDATE_COOLDOWN" then
		DriveUI.TurboSpellsOnCD()
		DriveUI.UpdateBars()
	end

end)