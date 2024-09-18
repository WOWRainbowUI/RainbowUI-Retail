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
		PlayerCastingBarFrame.Icon:SetScale(2.5) -- 圖示大小
		PlayerCastingBarFrame.Icon:AdjustPointsOffset(3, -3)
		vcbCreateTicks()
		if VCBrTarget["otherAdddon"] == "Shadowed Unit Frame" then
			TargetFrame:HookScript("OnUpdate", function(self)
				self:SetAlpha(0)
			end)
		end
		if VCBrFocus["otherAdddon"] == "Shadowed Unit Frame" then
			FocusFrame:HookScript("OnUpdate", function(self)
				self:SetAlpha(0)
			end)
		end
	elseif event == "PLAYER_FOCUS_CHANGED" and FocusFrame:IsShown() then
		local classFilename = UnitClassBase("focus")
		if classFilename ~= nil then vcbClassColorFocus = C_ClassColor.GetClassColor(classFilename) end
	elseif event == "PLAYER_TARGET_CHANGED" and TargetFrame:IsShown() then
		local classFilename = UnitClassBase("target")
		if classFilename ~= nil then vcbClassColorTarget = C_ClassColor.GetClassColor(classFilename) end
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
