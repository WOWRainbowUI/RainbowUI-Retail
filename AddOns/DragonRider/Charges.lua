	local _, DR = ...

local L = DR.L
local defaultsTable = DR.defaultsTable


---@type LibAdvFlight
local LibAdvFlight = LibStub:GetLibrary("LibAdvFlight-1.1")

---------------------------------------------------------------------------------------------------------------
-- Static Charges
---------------------------------------------------------------------------------------------------------------

DR.charge = CreateFrame("Frame", nil, DR.vigorBar)
DR.charge:SetAllPoints(DR.vigorBar)
DR.charge:RegisterEvent("UNIT_AURA")
DR.charge:RegisterEvent("SPELL_UPDATE_COOLDOWN")

local MAX_CHARGE_FRAMES = 10
local MAX_VIGOR_BARS = 6
local CHARGE_WIDTH_DEFAULT = 36
local CHARGE_HEIGHT_DEFAULT = 36
local PADDING_DEFAULT = -10
local CHARGE_SPACING_DEFAULT = 5.5

-- vigor bar defaults
local DEFAULT_ORIENTATION = 2
local DEFAULT_VIGOR_WRAP = 6
local STATIC_CHARGE_AURA = 418590

local TexturePath = "Interface\\AddOns\\DragonRider\\Textures\\"
local PixelTexture = "Interface\\buttons\\white8x8"

local ChargeOptions = {
	[1] = { -- default - gold
		Base = TexturePath.."Points_Gold_Empty",
		Cover = TexturePath.."Points_Gold_Cover",
		Fill = TexturePath.."Points_Fill",
		Desat = false,
		IsMinimalist = false,
	},
	[2] = { -- algari bronze
		Base = TexturePath.."Points_Bronze_Empty",
		Cover = TexturePath.."Points_Bronze_Cover",
		Fill = TexturePath.."Points_Fill",
		Desat = false,
		IsMinimalist = false,
	},
	[3] = { -- algari dark
		Base = TexturePath.."Points_Dark_Empty",
		Cover = TexturePath.."Points_Dark_Cover",
		Fill = TexturePath.."Points_Fill",
		Desat = false,
		IsMinimalist = false,
	},
	[4] = { -- algari gold
		Base = TexturePath.."Points_Gold_Empty",
		Cover = TexturePath.."Points_Gold_Cover",
		Fill = TexturePath.."Points_Fill",
		Desat = false,
		IsMinimalist = false,
	},
	[5] = { -- algari silver
		Base = TexturePath.."Points_Silver_Empty",
		Cover = TexturePath.."Points_Silver_Cover",
		Fill = TexturePath.."Points_Fill",
		Desat = false,
		IsMinimalist = false,
	},
	[6] = { -- default - desat
		Base = TexturePath.."Points_Silver_Empty",
		Cover = TexturePath.."Points_Silver_Cover",
		Fill = TexturePath.."Points_Fill",
		Desat = true,
		IsMinimalist = false,
	},
	[7] = { -- algari - desat
		Base = TexturePath.."Points_Silver_Empty",
		Cover = TexturePath.."Points_Silver_Cover",
		Fill = TexturePath.."Points_Fill",
		Desat = true,
		IsMinimalist = false,
	},
	[8] = { -- Minimalist
		Base = PixelTexture,
		Cover = nil,
		Fill = PixelTexture,
		Desat = false,
		IsMinimalist = true,
	},
};

for i = 1, MAX_CHARGE_FRAMES do
	DR.charge[i] = CreateFrame("Frame", "DragonRider_StaticCharge_"..i, DR.charge)
	DR.charge[i]:SetSize(CHARGE_WIDTH_DEFAULT, CHARGE_HEIGHT_DEFAULT)
	DR.charge[i]:SetFrameLevel(5)
	
	-- Create Borders (Hidden by default, used for Minimalist)
	local borderThickness = 1
	
	DR.charge[i].borderTop = DR.charge[i]:CreateTexture(nil, "OVERLAY", nil, 5)
	DR.charge[i].borderTop:SetTexture(PixelTexture)
	DR.charge[i].borderTop:SetPoint("TOPLEFT", DR.charge[i], "TOPLEFT", 0, 0)
	DR.charge[i].borderTop:SetPoint("TOPRIGHT", DR.charge[i], "TOPRIGHT", 0, 0)
	DR.charge[i].borderTop:SetHeight(borderThickness)
	DR.charge[i].borderTop:Hide()

	DR.charge[i].borderBottom = DR.charge[i]:CreateTexture(nil, "OVERLAY", nil, 5)
	DR.charge[i].borderBottom:SetTexture(PixelTexture)
	DR.charge[i].borderBottom:SetPoint("BOTTOMLEFT", DR.charge[i], "BOTTOMLEFT", 0, 0)
	DR.charge[i].borderBottom:SetPoint("BOTTOMRIGHT", DR.charge[i], "BOTTOMRIGHT", 0, 0)
	DR.charge[i].borderBottom:SetHeight(borderThickness)
	DR.charge[i].borderBottom:Hide()

	DR.charge[i].borderLeft = DR.charge[i]:CreateTexture(nil, "OVERLAY", nil, 5)
	DR.charge[i].borderLeft:SetTexture(PixelTexture)
	DR.charge[i].borderLeft:SetPoint("TOPLEFT", DR.charge[i], "TOPLEFT", 0, -borderThickness) 
	DR.charge[i].borderLeft:SetPoint("BOTTOMLEFT", DR.charge[i], "BOTTOMLEFT", 0, borderThickness)
	DR.charge[i].borderLeft:SetWidth(borderThickness)
	DR.charge[i].borderLeft:Hide()

	DR.charge[i].borderRight = DR.charge[i]:CreateTexture(nil, "OVERLAY", nil, 5)
	DR.charge[i].borderRight:SetTexture(PixelTexture)
	DR.charge[i].borderRight:SetPoint("TOPRIGHT", DR.charge[i], "TOPRIGHT", 0, -borderThickness)
	DR.charge[i].borderRight:SetPoint("BOTTOMRIGHT", DR.charge[i], "BOTTOMRIGHT", 0, borderThickness)
	DR.charge[i].borderRight:SetWidth(borderThickness)
	DR.charge[i].borderRight:Hide()
	
	-- Standard Textures
	DR.charge[i].texBase = DR.charge[i]:CreateTexture(nil, "BACKGROUND", nil, 0)
	DR.charge[i].texBase:SetAllPoints()
	DR.charge[i].texFill = DR.charge[i]:CreateTexture(nil, "OVERLAY", nil, 1)
	DR.charge[i].texFill:SetAllPoints()
	DR.charge[i].texFill:Hide()
	DR.charge[i].texCover = DR.charge[i]:CreateTexture(nil, "OVERLAY", nil, 2)
	DR.charge[i].texCover:SetAllPoints()
	DR.charge[i]:Hide()
end

function DR:chargeSetup(number)
	local charge = DR.charge[number]
	if not charge then return end

	local themeVigor = (DragonRider_DB and DragonRider_DB.themeVigor) or 1
	local options = ChargeOptions[themeVigor] or ChargeOptions[1]

	charge.texBase:SetTexture(options.Base)
	charge.texFill:SetTexture(options.Fill)
	
	if options.Cover then
		charge.texCover:SetTexture(options.Cover)
		charge.texCover:Show()
	else
		charge.texCover:Hide()
	end

	local desat = options.Desat or false
	charge.texBase:SetDesaturated(desat)
	charge.texCover:SetDesaturated(desat)
	charge.texFill:SetDesaturated(desat)

	if options.IsMinimalist then
		charge.borderTop:Show()
		charge.borderBottom:Show()
		charge.borderLeft:Show()
		charge.borderRight:Show()
		
		charge.texFill:ClearAllPoints()
		charge.texFill:SetPoint("TOPLEFT", 1, -1)
		charge.texFill:SetPoint("BOTTOMRIGHT", -1, 1)
		
		charge.texBase:ClearAllPoints()
		charge.texBase:SetPoint("TOPLEFT", 1, -1)
		charge.texBase:SetPoint("BOTTOMRIGHT", -1, 1)
	else
		charge.borderTop:Hide()
		charge.borderBottom:Hide()
		charge.borderLeft:Hide()
		charge.borderRight:Hide()
		
		charge.texFill:ClearAllPoints()
		charge.texFill:SetAllPoints()
		charge.texBase:ClearAllPoints()
		charge.texBase:SetAllPoints()
	end

	local rF, gF, bF, aF = 1, 1, 1, 1
	if DragonRider_DB and DragonRider_DB.vigorBarColor and DragonRider_DB.vigorBarColor.full then
		rF = DragonRider_DB.vigorBarColor.full.r
		gF = DragonRider_DB.vigorBarColor.full.g
		bF = DragonRider_DB.vigorBarColor.full.b
		aF = DragonRider_DB.vigorBarColor.full.a
	end
	
	local rBG, gBG, bBG, aBG = 1, 1, 1, 1
	if DragonRider_DB and DragonRider_DB.vigorBarColor and  DragonRider_DB.vigorBarColor.background then
		rBG = DragonRider_DB.vigorBarColor.background.r
		gBG = DragonRider_DB.vigorBarColor.background.g
		bBG = DragonRider_DB.vigorBarColor.background.b
		aBG = DragonRider_DB.vigorBarColor.background.a
	end

	local rC, gC, bC, aC = 1, 1, 1, 1
	if DragonRider_DB and DragonRider_DB.vigorBarColor and DragonRider_DB.vigorBarColor.cover then
		rC = DragonRider_DB.vigorBarColor.cover.r
		gC = DragonRider_DB.vigorBarColor.cover.g
		bC = DragonRider_DB.vigorBarColor.cover.b
		aC = DragonRider_DB.vigorBarColor.cover.a
	end
	
	charge.texFill:SetVertexColor(rF, gF, bF, aF)
	charge.texBase:SetVertexColor(rBG, gBG, bBG, aBG)
	charge.texCover:SetVertexColor(rC, gC, bC, aC)
	
	charge.borderTop:SetVertexColor(rC, gC, bC, aC)
	charge.borderBottom:SetVertexColor(rC, gC, bC, aC)
	charge.borderLeft:SetVertexColor(rC, gC, bC, aC)
	charge.borderRight:SetVertexColor(rC, gC, bC, aC)
end


function DR.UpdateChargePositions()
	for i = 1, MAX_CHARGE_FRAMES do
		if DR.charge[i] then DR.charge[i]:Hide() end
	end

	if not DR.vigorBar or not DR.vigorBar:IsShown() or not DragonRider_DB or not LibAdvFlight or not LibAdvFlight.HasLightningRush() or not DragonRider_DB.lightningRush then
		return
	end

	for i = 1, MAX_CHARGE_FRAMES do
		DR:chargeSetup(i)
	end

	local orientation = (DragonRider_DB.vigorBarOrientation) or DEFAULT_ORIENTATION
	local vigorWrap = (DragonRider_DB.vigorWrap and DragonRider_DB.vigorWrap > 0 and DragonRider_DB.vigorWrap) or DEFAULT_VIGOR_WRAP

	local showTopBottom = false

	if orientation == 1 then
		if vigorWrap >= 3 then
			showTopBottom = false
		else
			showTopBottom = true
		end
	else
		if vigorWrap >= 3 then
			showTopBottom = true
		else
			showTopBottom = false
		end
	end

	local chargeWidth = (DragonRider_DB.staticChargeWidth) or CHARGE_WIDTH_DEFAULT
	local chargeHeight = (DragonRider_DB.staticChargeHeight) or CHARGE_HEIGHT_DEFAULT
	local chargeSpacing = (DragonRider_DB.staticChargeSpacing) or CHARGE_SPACING_DEFAULT
	local chargeOffset = (DragonRider_DB.staticChargeOffset) or PADDING_DEFAULT
	
	for i = 1, 5 do
		local charge1 = DR.charge[i]
		local charge2 = DR.charge[i + 5]
		
		if charge1 and charge2 then
			charge1:SetSize(chargeWidth, chargeHeight)
			charge2:SetSize(chargeWidth, chargeHeight)
			
			charge1:ClearAllPoints()
			charge2:ClearAllPoints()

			local centerOffset = (i - 3) * (chargeWidth + chargeSpacing)

			if showTopBottom then
				charge1:SetPoint("BOTTOM", DR.vigorBar, "TOP", centerOffset, chargeOffset)
				charge2:SetPoint("TOP", DR.vigorBar, "BOTTOM", centerOffset, -chargeOffset)
			else
				local vertOffset = -centerOffset

				charge1:SetPoint("RIGHT", DR.vigorBar, "LEFT", -chargeOffset, vertOffset)
				charge2:SetPoint("LEFT", DR.vigorBar, "RIGHT", chargeOffset, vertOffset)
			end
			
			charge1:Show()
			charge2:Show()
		end
	end
end


function DR.charge:OnEvent(event, ...)
	if event == "UNIT_AURA" then
		local unit = select(1, ...)
		if unit == "player" then
			DR.UpdateChargePositions()
			if C_Secrets and C_Secrets.ShouldSpellCooldownBeSecret(STATIC_CHARGE_AURA) then return end
			local chargeCount = 0
			local spellAura = C_UnitAuras.GetPlayerAuraBySpellID(STATIC_CHARGE_AURA)
			if issecretvalue and issecretvalue(spellAura) then
				return
			end
			if spellAura then
				chargeCount = spellAura.applications
			end
			
			for i = 1, 5 do 
				local top_charge = DR.charge[i]
				local bottom_charge = DR.charge[i + 5]

				if top_charge and top_charge.texFill then
					if i <= chargeCount then 
						top_charge.texFill:Show()
					else
						top_charge.texFill:Hide()
					end
				end

				if bottom_charge and bottom_charge.texFill then
					if (i + 5) <= chargeCount then 
						bottom_charge.texFill:Show()
					else
						bottom_charge.texFill:Hide()
					end
				end
			end
		end
	end
	
	if event == "SPELL_UPDATE_COOLDOWN" then
		local isEnabled, startTime, modRate, duration
		if C_Spell.GetSpellCooldown then
			local cooldownInfo = C_Spell.GetSpellCooldown(418592)
			if issecretvalue and issecretvalue(cooldownInfo) then
				return
			end
			isEnabled, startTime, modRate, duration = cooldownInfo.isEnabled, cooldownInfo.startTime, cooldownInfo.modRate, cooldownInfo.duration
		else
			isEnabled, startTime, modRate, duration = GetSpellCooldown(418592)
		end
	end
end

DR.charge:SetScript("OnEvent", DR.charge.OnEvent)