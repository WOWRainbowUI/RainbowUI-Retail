-- Some local variables --
local lagStart = 0
local lagEnd = 0
local lagTotal = 0
local statusMin = 0
local statusMax = 0
local lagWidth = 0
-- function for the texts --
local function VCBtexts(var1)
	var1:SetFontObject("GameFontHighlightSmall")
	var1:SetHeight(PlayerCastingBarFrame.Text:GetHeight())
	var1:Hide()
end
-- Name Text --
VCBnameText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBnameText)
-- Current Time Text --
VCBcurrentTimeText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBcurrentTimeText)
-- Total Time Text --
VCBtotalTimeText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBtotalTimeText)
-- Both Time Text --
VCBbothTimeText = PlayerCastingBarFrame:CreateFontString(nil, "OVERLAY", nil)
VCBtexts(VCBbothTimeText)
-- Copy Texture of Spell's Icon --
VCBiconSpell = PlayerCastingBarFrame:CreateTexture(nil, "ARTWORK", nil, 0)
VCBiconSpell:SetPoint("LEFT", PlayerCastingBarFrame, "RIGHT", 2, -4)
VCBiconSpell:SetWidth(PlayerCastingBarFrame.Icon:GetWidth())
VCBiconSpell:SetHeight(PlayerCastingBarFrame.Icon:GetHeight())
VCBiconSpell:SetScale(1.3)
VCBiconSpell:Hide()
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
	if playerSpell and VCBrPlayer["LagBar"] == "Show" then
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
	if playerSpell and VCBrPlayer["LagBar"] == "Show" then
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
-- First Time Saved Variables --
local function FirstTimeSavedVariables()
	if VCBrCounterLoading == nil or VCBrCounterLoading ~= nil then VCBrCounterLoading = 0 end
	if VCBrCounterDeleting == nil or VCBrCounterDeleting ~= nil then VCBrCounterDeleting = 0 end
	if VCBrProfile == nil then VCBrProfile = {} end
	if VCBrNumber == nil then VCBrNumber = 0 end
	if VCBrPlayer == nil then
		VCBrPlayer = { NameText = "Top",
			CurrentTimeText = {Position = "Bottom Left", Direction = "Both", Sec = "Show"},
			TotalTimeText = {Position = "Bottom Right", Sec = "Show"},
			BothTimeText = {Position = "Hide", Direction = "Both", Sec = "Hide"},
			LagBar = "Show",
			Icon = "Left",
			Color = "Default Color",
			Art = "Default",
			Ticks = "Show",
		}
	end
	if VCBrTarget == nil then
		VCBrTarget = { Unlock = false,
			Position = {X = 0, Y = 0},
			Scale = 100,
			NameText = "Top",
			CurrentTimeText = {Position = "Bottom Left", Direction = "Both", Sec = "Show"},
			TotalTimeText = {Position = "Bottom Right", Sec = "Show"},
			BothTimeText = {Position = "Hide", Direction = "Both", Sec = "Hide"},
			Color = "Default Color",
			Art = "Default",
			otherAdddon = "None",
		}
	end
	if VCBrFocus == nil then
		VCBrFocus = { Unlock = false,
			Position = {X = 0, Y = 0},
			Scale = 100,
			NameText = "Top",
			CurrentTimeText = {Position = "Bottom Left", Direction = "Both", Sec = "Show"},
			TotalTimeText = {Position = "Bottom Right", Sec = "Show"},
			BothTimeText = {Position = "Hide", Direction = "Both", Sec = "Hide"},
			Color = "Default Color",
			Art = "Default",
			otherAdddon = "None",
		}
	end
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3)
	if event == "PLAYER_LOGIN" then
		FirstTimeSavedVariables()
		vcbClassColor = C_ClassColor.GetClassColor(select(2, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))))
		PlayerCastingBarFrame.Icon:SetScale(1.3)
		PlayerCastingBarFrame.Icon:AdjustPointsOffset(2, -4)
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
	elseif event == "CURRENT_SPELL_CAST_CHANGED" and arg1 == false then
		lagStart = GetTime()
	elseif event == "UNIT_SPELLCAST_START" and arg1 == "player" then
		VCBarg3 = arg3
		vcbHideTicks()
		VCBlagBar1:Hide()
		VCBlagBar2:Hide()
		PlayerCastLagBar(arg3)
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" and arg1 == "player" then
		VCBarg3 = arg3
		vcbHideTicks()
		VCBlagBar1:Hide()
		VCBlagBar2:Hide()
		PlayerChannelLagBar(arg3)
	elseif event == "UNIT_SPELLCAST_EMPOWER_START" and arg1 == "player" then
		VCBlagBar1:Hide()
		VCBlagBar2:Hide()
		vcbHideTicks()
	end
end
vcbZlave:SetScript("OnEvent", EventsTime)
