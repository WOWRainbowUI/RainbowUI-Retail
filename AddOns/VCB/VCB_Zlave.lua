-- First Time Saved Variables --
local function FirstTimeSavedVariables()
	if VCBrCounterLoading == nil or VCBrCounterLoading ~= nil then VCBrCounterLoading = 0 end
	if VCBrCounterDeleting == nil or VCBrCounterDeleting ~= nil then VCBrCounterDeleting = 0 end
	if VCBrProfile == nil then VCBrProfile = {} end
	if VCBrNumber == nil then VCBrNumber = 0 end
	if VCBrPlayer == nil then
		VCBrPlayer = { NameText = "左下",
			CurrentTimeText = {Position = "隱藏", Direction = "兩者", Sec = "隱藏"},
			TotalTimeText = {Position = "隱藏", Sec = "隱藏"},
			BothTimeText = {Position = "右下", Direction = "兩者", Sec = "隱藏"},
			LagBar = "顯示",
			Icon = "左",
			Color = "預設顏色",
			Art = "預設",
			Ticks = "顯示",
		}
	end
	if VCBrTarget == nil then
		VCBrTarget = { Unlock = false,
			Position = {X = 0, Y = 0},
			Scale = 100,
			NameText = "左上",
			CurrentTimeText = {Position = "隱藏", Direction = "兩者", Sec = "隱藏"},
			TotalTimeText = {Position = "隱藏", Sec = "隱藏"},
			BothTimeText = {Position = "右下", Direction = "兩者", Sec = "隱藏"},
			Color = "預設顏色",
			Art = "預設",
			otherAdddon = "無",
		}
	end
	if VCBrFocus == nil then
		VCBrFocus = { Unlock = false,
			Position = {X = 0, Y = 0},
			Scale = 100,
			NameText = "左上",
			CurrentTimeText = {Position = "隱藏", Direction = "兩者", Sec = "隱藏"},
			TotalTimeText = {Position = "隱藏", Sec = "隱藏"},
			BothTimeText = {Position = "右下", Direction = "兩者", Sec = "隱藏"},
			Color = "預設顏色",
			Art = "預設",
			otherAdddon = "無",
		}
	end
	vcbClassColorPlayer = C_ClassColor.GetClassColor(select(2, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))))
	if VCBrPlayer["CurrentTimeText"]["Decimals"] == nil then VCBrPlayer["CurrentTimeText"]["Decimals"] = 1 end
	if VCBrPlayer["TotalTimeText"]["Decimals"] == nil then VCBrPlayer["TotalTimeText"]["Decimals"] = 1 end
	if VCBrPlayer["BothTimeText"]["Decimals"] == nil then VCBrPlayer["BothTimeText"]["Decimals"] = 1 end
	if VCBrTarget["CurrentTimeText"]["Decimals"] == nil then VCBrTarget["CurrentTimeText"]["Decimals"] = 1 end
	if VCBrTarget["TotalTimeText"]["Decimals"] == nil then VCBrTarget["TotalTimeText"]["Decimals"] = 1 end
	if VCBrTarget["BothTimeText"]["Decimals"] == nil then VCBrTarget["BothTimeText"]["Decimals"] = 1 end
	if VCBrFocus["CurrentTimeText"]["Decimals"] == nil then VCBrFocus["CurrentTimeText"]["Decimals"] = 1 end
	if VCBrFocus["TotalTimeText"]["Decimals"] == nil then VCBrFocus["TotalTimeText"]["Decimals"] = 1 end
	if VCBrFocus["BothTimeText"]["Decimals"] == nil then VCBrFocus["BothTimeText"]["Decimals"] = 1 end
end
-- loading saved variables --
local function LoadSavedVariables()
	if VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" and VCBrTarget["Unlock"] then
		SUFUnittarget:HookScript("OnShow", function(self)
			local classFilename = UnitClassBase("target")
			if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
		end)
		vcbSufCoOp_Traget(vcbClassColorTarget)
	elseif VCBrTarget["otherAdddon"] == "無" and VCBrTarget["Unlock"] then
		TargetFrameSpellBar:HookScript("OnUpdate", function(self)
			self:SetScale(VCBrTarget["Scale"]/100)
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrTarget["Position"]["X"], VCBrTarget["Position"]["Y"])
		end)
	end
	if VCBrFocus["otherAdddon"] == "Shadowed Unit Frame" and VCBrFocus["Unlock"] then
		SUFUnitfocus:HookScript("OnShow", function(self)
			local classFilename = UnitClassBase("focus")
			if classFilename ~= nil then vcbClassColorFocus = C_ClassColor.GetClassColor(classFilename) end
		end)
		vcbSufCoOp_Focus()
	elseif VCBrFocus["otherAdddon"] == "無" and VCBrFocus["Unlock"] then
		FocusFrameSpellBar:HookScript("OnUpdate", function(self)
			self:SetScale(VCBrFocus["Scale"]/100)
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", VCBrFocus["Position"]["X"], VCBrFocus["Position"]["Y"])
		end)
	end
end
-- Some local variables --
local lagStart = 0
local lagEnd = 0
local lagTotal = 0
local statusMin = 0
local statusMax = 0
local lagWidth = 0
-- function for the lag bars --
local function VCBlagBars(var1)
	var1:SetTexture("Interface\\RAIDFRAME\\Raid-Bar-Hp-Fill")
	var1:SetHeight(PlayerCastingBarFrame:GetHeight())
	var1:SetVertexColor(1, 0, 0)
	var1:SetAlpha(0.75)
	var1:SetBlendMode("ADD")
	var1:Hide()
end
-- Lag Bar 1 --
local VCBlagBar1 = PlayerCastingBarFrame:CreateTexture(nil, "OVERLAY", nil, 7)
VCBlagBars(VCBlagBar1)
-- Lag Bar 2 --
local VCBlagBar2 = PlayerCastingBarFrame:CreateTexture(nil, "OVERLAY", nil, 7)
VCBlagBars(VCBlagBar2)
-- Player Casting Latency Bar --
local function PlayerCastLagBar(arg3)
	local playerSpell = IsPlayerSpell(arg3)
	if playerSpell and VCBrPlayer["LagBar"] == "顯示" then
		lagEnd = GetTime()
		lagTotal = (lagEnd - lagStart)
		statusMin, statusMax = PlayerCastingBarFrame:GetMinMaxValues()
		lagWidth = lagTotal / (statusMax - statusMin)
		VCBlagBar1:ClearAllPoints()
		VCBlagBar1:SetWidth(PlayerCastingBarFrame:GetWidth() * lagWidth)
		VCBlagBar1:SetPoint("RIGHT", PlayerCastingBarFrame, "RIGHT", 0, 0)
		VCBlagBar1:Show()
	end
end
-- Player Channeling Latency Bar --
local function PlayerChannelLagBar(arg3)
	local playerSpell = IsPlayerSpell(arg3)
	if playerSpell and VCBrPlayer["LagBar"] == "顯示" then
		lagEnd = GetTime()
		lagTotal = (lagEnd - lagStart)
		statusMin, statusMax = PlayerCastingBarFrame:GetMinMaxValues()
		lagWidth = lagTotal / (statusMax - statusMin)
		VCBlagBar2:ClearAllPoints()
		VCBlagBar2:SetWidth(PlayerCastingBarFrame:GetWidth() * lagWidth)
		VCBlagBar2:SetPoint("LEFT", PlayerCastingBarFrame, "LEFT", 0, 0)
		VCBlagBar2:Show()
	end
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3)
	if event == "PLAYER_LOGIN" then
		FirstTimeSavedVariables()
		LoadSavedVariables()
		PlayerCastingBarFrame.Icon:SetScale(2.5) -- 圖示大小
		PlayerCastingBarFrame.Icon:AdjustPointsOffset(3, -3)
		vcbCreateTicks()
	elseif event == "PLAYER_FOCUS_CHANGED" then
		if FocusFrame:IsShown() then
			local classFilename = UnitClassBase("focus")
			if classFilename ~= nil then vcbClassColorFocus = C_ClassColor.GetClassColor(classFilename) end
		elseif SUFUnitfocus ~= nil and SUFUnitfocus:IsShown() then
			SUFUnitfocus.vcbCastbar:SetUnit(nil, true, true)
			SUFUnitfocus.vcbCastbar:PlayFinishAnim()
			SUFUnitfocus.vcbCastbar:SetUnit("focus", true, true)
			local classFilename = UnitClassBase("focus")
			if classFilename ~= nil then vcbClassColorFocus = C_ClassColor.GetClassColor(classFilename) end
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		if TargetFrame:IsShown() then
			local classFilename = UnitClassBase("target")
			if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
		elseif SUFUnittarget ~= nil and SUFUnittarget:IsShown() then
			SUFUnittarget.vcbCastbar:SetUnit(nil, true, true)
			SUFUnittarget.vcbCastbar:PlayFinishAnim()
			SUFUnittarget.vcbCastbar:SetUnit("target", true, true)
			local classFilename = UnitClassBase("target")
			if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
		end
	elseif event == "CURRENT_SPELL_CAST_CHANGED" and arg1 == false then
		lagStart = GetTime()
	elseif event == "UNIT_SPELLCAST_START" and arg1 == "player" then
		VCBarg3 = arg3
		vcbHideTicks()
		VCBlagBar1:Hide()
		VCBlagBar2:Hide()
		PlayerCastLagBar(arg3)
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" and arg1 == "player" then
		vcbChannelSpellID = arg3
		VCBarg3 = arg3
		vcbHideTicks()
		VCBlagBar1:Hide()
		VCBlagBar2:Hide()
		PlayerChannelLagBar(arg3)
	elseif event == "UNIT_SPELLCAST_EMPOWER_START" and arg1 == "player" then
		VCBlagBar1:Hide()
		VCBlagBar2:Hide()
		vcbHideTicks()
	elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
		local spellId, spellName, spellSchool = select(12, CombatLogGetCurrentEventInfo())
		if subevent == "SPELL_CAST_START" and sourceName == UnitFullName("player") then
			vcbSpellSchool = spellSchool
		elseif subevent == "SPELL_CAST_SUCCESS" and spellId == vcbChannelSpellID and sourceName == UnitFullName("player") then
			vcbSpellSchool = spellSchool
		end
	elseif (event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_SENT") and arg1 == "player" then
		vcbSpellSchool = 0
	end
end
vcbZlave:SetScript("OnEvent", EventsTime)
