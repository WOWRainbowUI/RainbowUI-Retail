local addonName, ns = ...
local CCS = ns.CCS
local loopitems
if CCS.GetCurrentVersion() ~= CCS.RETAIL then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table
local module = {
    Name = "inspectSheet",
    CompatibleVersions = { CCS.RETAIL },
}

CCS.Modules[module.Name] = module

local modbg = _G["InspectModelFramebg"] or CreateFrame("Frame", "InspectModelFramebg")
local modtex = _G["InspectModelFramebgtex"] or modbg:CreateTexture("InspectModelFramebgtex", "BACKGROUND")    

---------------------------
-- Module methods
---------------------------
function module:Initialize()
    -- Optional setup for the inspect sheet
    -- print("[CCS] inspectSheet initialized")
    -- Nothing to set up yet in this.  This will be future creation code.
end


function CCS:inspect()
  if not InspectFrame or not InspectFrame.unit then return end
  
  local unitinspect = InspectFrame.unit
  --------------------------
 -- Create Primary Frame 
 --------------------------
    local CCS_ic = _G["CCS_InspectCompare"] or CreateFrame("Frame", "CCS_InspectCompare", UIParent, "BackdropTemplate")
    local CCS_EC = _G["CCS_EquipCompareframe"] or CreateFrame("Frame", "CCS_EquipCompareframe", CCS_ic)
    local cmodelFrame = _G["CompCharacterModel"] or CreateFrame("PlayerModel", "CompCharacterModel", CCS_EC)
    local imodelFrame = _G["CompInspectModel"] or CreateFrame("PlayerModel", "CompInspectModel", CCS_EC)

    CCS_ic:SetSize(900, 700)
    CCS_ic:SetScale(1.10)
    CCS_ic:SetPoint("TOPLEFT", InspectFrame, "TOPLEFT", 0, 50)
    CCS_ic:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })

    local borderColor = CCS.StyleColor.border
    CCS_ic:SetBackdropBorderColor(unpack(borderColor)) -- purple border

    CCS_ic:EnableKeyboard(true)
    CCS_ic:SetFrameLevel(0)
    CCS_ic.name = addonName
    CCS_ic:SetPropagateKeyboardInput(true)
    CCS_ic:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            CCS_ic:Hide()
            CCS_ic:SetPropagateKeyboardInput(false)
        else
            self:SetPropagateKeyboardInput(true)
        end

    end)

    CCS_ic:SetFrameStrata("HIGH")
    CCS_ic:SetFrameLevel(0)

    CCS_ic:SetScript("OnShow", function() 
        InspectFrame:SetAlpha(0); 
        InspectModelFrame:Hide() 
        imodelFrame:Hide()
        cmodelFrame:Hide()
        C_Timer.After(3, function() 
            cmodelFrame:Show()
            imodelFrame:Show() 
            end)
        end)
    CCS_ic:SetScript("OnHide", function() 
        InspectFrame:SetAlpha(1) 
        InspectModelFrame:Show() 
        end)    

    local CCS_ic_tex1 = _G["CCS_ic_tex1"] or CCS_ic:CreateTexture("CCS_ic_tex1", "BACKGROUND", nil)
    CCS_ic_tex1:SetPoint("TOPLEFT", CCS_ic, "TOPLEFT")
    CCS_ic_tex1:SetPoint("BOTTOMLEFT", CCS_ic, "BOTTOMLEFT")    
    CCS_ic_tex1:SetPoint("TOPRIGHT", CCS_ic, "TOP", 0 , -1)
    CCS_ic_tex1:SetPoint("BOTTOMRIGHT", CCS_ic, "BOTTOM", 0 , 1)    
    CCS_ic_tex1:SetTexture("Interface\\Masks\\SquareMask.BLP")
    CCS_ic_tex1:SetTexCoord(1,0,0,1)
    CCS_ic_tex1:SetGradient("Horizontal", CreateColor(0.094, 0.031, 0.137, 0.95), CreateColor(0, 0, 0, 1))
    CCS_ic_tex1:Show()
    
    local CCS_ic_tex2 = _G["CCS_ic_tex2"] or CCS_ic:CreateTexture("CCS_ic_tex2", "BACKGROUND", nil)
    CCS_ic_tex2:SetPoint("TOPRIGHT", CCS_ic, "TOPRIGHT")
    CCS_ic_tex2:SetPoint("BOTTOMRIGHT", CCS_ic, "BOTTOMRIGHT")
    CCS_ic_tex2:SetPoint("TOPLEFT", CCS_ic, "TOP", 0 , -1)
    CCS_ic_tex2:SetPoint("BOTTOMLEFT", CCS_ic, "BOTTOM", 0 , 1)    
    CCS_ic_tex2:SetTexture("Interface\\Masks\\SquareMask.BLP")
    CCS_ic_tex2:SetGradient("Horizontal", CreateColor(0, 0, 0, 1), CreateColor(0.094, 0.031, 0.137, 0.95))
    CCS_ic_tex2:Show()

    -- Close button
    local closeBtn = CreateFrame("Button", nil, CCS_ic, "UIPanelCloseButton")
	CCS:SkinBlizzardButton(closeBtn, "x", 26)
    closeBtn:SetSize(32, 32)
    closeBtn:SetScale(.5)
    closeBtn:SetPoint("TOPRIGHT", CCS_ic, "TOPRIGHT", -10, -10)
    closeBtn:Show()
    CCS_ic:Hide()
    CCS_ic:Show()
	
	--------------------------
	-- Create Header Elements
	--------------------------
	local color = "ffffff"
	
	local cmplus = _G["CompCharacterMplusRating"] or CCS_ic:CreateFontString("CompCharacterMplusRating")
    cmplus:SetPoint("TOPLEFT", CCS_ic, "TOPLEFT", 9, -30) 
	cmplus:SetSize(150,60)
    cmplus:SetFont(option("fontname_mplus") or CCS.fontname, option("fontsize_mplus") or 11, CCS.textoutline)
	if option("showfontshadow") == true then
		cmplus:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		cmplus:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end		
    cmplus:SetText(CCS.getraiderioscoreplayer(true) or "")

	local implus = _G["CompInspectMplusRating"] or CCS_ic:CreateFontString("CompInspectMplusRating")
    implus:SetPoint("TOPRIGHT", CCS_ic, "TOPRIGHT", -9, -30) 
	implus:SetSize(150,60)
    implus:SetFont(option("fontname_mplus_inspect") or CCS.fontname, option("fontsize_mplus_inspect") or 11, CCS.textoutline)
	if option("showfontshadow") == true then
		implus:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		implus:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	
    implus:SetText(CCS.getraiderioscoreinspect() or "")

	local ctitname = _G["CompCharacterTitleName"] or CCS_ic:CreateFontString("CompCharacterTitleName")
    ctitname:SetPoint("TOP", CCS_ic, "TOP", -200, -15) 
    ctitname:SetFont( option("fontname_nametitle") or CCS.fontname, (option("fontsize_nametitle") or 12) , CCS.textoutline)
	if option("showfontshadow") == true then
		ctitname:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ctitname:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	
	ctitname:SetSize(520, 12)
	ctitname:SetJustifyH("CENTER")
    ctitname:SetTextColor(
        option("fontcolor_nametitle")[1] or 1,
        option("fontcolor_nametitle")[2] or 1,
        option("fontcolor_nametitle")[3] or 1,
        option("fontcolor_nametitle")[4] or 1
    )
    CharacterFrame:UpdateTitle()
    PaperDollFrame_SetLevel();
    ctitname:SetText(CharacterFrameTitleText:GetText() or "")

	local ititname = _G["CompInspectTitleName"] or CCS_ic:CreateFontString("CompInspectTitleName")
    ititname:SetPoint("TOP", CCS_ic, "TOP", 200, -15) 
    ititname:SetFont(option("fontname_nametitle_inspect") or CCS.fontname, option("fontsize_nametitle_inspect") or 12, CCS.textoutline)
	if option("showfontshadow") == true then
		ititname:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ititname:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
	
	ititname:SetSize(520, 12)
	ititname:SetJustifyH("CENTER")
    ititname:SetTextColor(
        option("fontcolor_nametitle_inspect")[1] or 1,
        option("fontcolor_nametitle_inspect")[2] or 1,
        option("fontcolor_nametitle_inspect")[3] or 1,
        option("fontcolor_nametitle_inspect")[4] or 1
    )
    ititname:SetText(InspectFrameTitleText:GetText() or "")

	local clvltxt = _G["CompCharacterLevelText"] or CCS_ic:CreateFontString("CompCharacterLevelText")
    clvltxt:SetPoint("TOP", ctitname, "BOTTOM", 0, 0) 
    clvltxt:SetFont(option("fontname_levelclass") or CCS.fontname, (option("fontsize_levelclass") or 12) , CCS.textoutline)
	if option("showfontshadow") == true then
		clvltxt:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		clvltxt:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
	
	clvltxt:SetSize(220, 24)
	clvltxt:SetJustifyH("CENTER")
    clvltxt:SetText(CharacterLevelText:GetText() or "")

	local ilvltxt = _G["CompInspectLevelText"] or CCS_ic:CreateFontString("CompInspectLevelText")
    ilvltxt:SetPoint("TOP", ititname, "BOTTOM", 0, 0) 
    ilvltxt:SetFont(option("fontname_levelclass_inspect") or CCS.fontname, (option("fontsize_levelclass_inspect") or 12) , CCS.textoutline)
	if option("showfontshadow") == true then
		ilvltxt:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ilvltxt:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
	
	ilvltxt:SetSize(220, 24)
	ilvltxt:SetJustifyH("CENTER")
    ilvltxt:SetText(InspectLevelText:GetText() or "")

	local cilvltxt = _G["CompCharacterIlvl"] or CCS_ic:CreateFontString("CompCharacterIlvl")
	local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel();
	local Color = "a336ed"
    cilvltxt:SetPoint("TOP", clvltxt, "BOTTOM", 0 ,0) 
    cilvltxt:SetFont(option("fontname_cilvl") or CCS.fontname, (option("fontsize_cilvl") or 20) , CCS.textoutline)
	if option("showfontshadow") == true then
		cilvltxt:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		cilvltxt:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
	
	cilvltxt:SetSize(230, 22*(option("fontsize_cilvl") or 20)/20)
	cilvltxt:SetJustifyH("CENTER")
    CCS:GetAverageEquippedRarityHex("player")
	cilvltxt:SetText(avgItemLevelEquipped or "")

	CCS.PreloadEquippedItemInfo("player")
	CCS.WaitForItemInfoReady("player", function()
		local color = CCS:GetAverageEquippedRarityHex("player")
		Color = color

		avgItemLevelEquipped = format("%.2f", avgItemLevelEquipped)
		cilvltxt:SetText(format("|cFF%s%s|r", Color, avgItemLevelEquipped))
	end)

	local iilvltxt = _G["CompInspectIlvl"] or CCS_ic:CreateFontString("CompInspectIlvl")
    avgItemLevelEquipped = CCS.GetInspectItemLevel(unitinspect)
    Color = "a336ed"
    iilvltxt:SetPoint("TOP", ilvltxt, "BOTTOM", 0 ,0) 
    iilvltxt:SetFont(option("fontname_inspect_ilvl") or CCS.fontname, option("fontsize_inspect_ilvl") or 20, CCS.textoutline)
	if option("showfontshadow") == true then
		iilvltxt:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		iilvltxt:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
	
	iilvltxt:SetSize(230, 22*(option("fontsize_inspect_ilvl") or 20)/20)
	iilvltxt:SetJustifyH("CENTER")
    CCS:GetAverageEquippedRarityHex(unitinspect)
	iilvltxt:SetText(avgItemLevelEquipped or "")

	CCS.PreloadEquippedItemInfo(unitinspect)
	CCS.WaitForItemInfoReady(unitinspect, function()
		local color = CCS:GetAverageEquippedRarityHex(unitinspect)
		Color = color

		avgItemLevelEquipped = format("%.2f", avgItemLevelEquipped)
		iilvltxt:SetText(format("|cFF%s%s|r", Color, avgItemLevelEquipped))
	end)

	--------------------------
	-- Create EquipCompareframe Elements
	--------------------------
    CCS_EC:SetPoint("TOPLEFT", CCS_ic, "TOPLEFT", 0, -75)
    CCS_EC:SetPoint("RIGHT", CCS_ic, "RIGHT", 0, 0)	
    CCS_EC:SetPoint("BOTTOM", CCS_ic, "BOTTOM", 0, 34)		
	CCS_EC:Show()
    
    --------------------------
    -- Set up the character side of the frame.
    --------------------------
	
	local CompareToolTip = CCS:CreateTooltip("CCSCompareTooltip")
	
    for slotIndex = 1,17 do 
        if slotIndex ~= 4 then
            local slotName = CCS.getSlotFrameName(slotIndex, "CompCharacter")
            local itemframe = _G[slotName] or CreateFrame("Button", slotName, CCS_EC)
            local itemframetex = _G[slotName.."tex"] or itemframe:CreateTexture(slotName.."tex", "ARTWORK", nil)
            local link = GetInventoryItemLink("player", slotIndex)
            local itemTexture 
            itemframe:SetFrameStrata("HIGH")
            itemframe:SetFrameLevel(5)
            if link then
                itemTexture = select(10, C_Item.GetItemInfo(link))
            end
            itemframe:SetSize(37,37)
            itemframetex:SetAllPoints(itemframe)
            itemframetex:SetTexture(itemTexture or CCS.emptySlotTextures[slotIndex])
            itemframetex:Show()
            CCS.updateLocationInfo("player", slotIndex, "CompCharacter")
            itemframe:SetScale(.8648)
            itemframe:SetScript("OnEnter", function(self) 
                    if link then
					    CompareToolTip:SetOwner(itemframe, "ANCHOR_RIGHT")
						CCS.RenderSafeTooltip(CompareToolTip, link, "player")
                    end
            end)
            itemframe:SetScript("OnLeave", function() CompareToolTip:Hide() end)
        end
    end 

    _G["CompCharacterHeadSlot"]:SetPoint("TOPRIGHT", CCS_EC, "TOP", -29, 0)
    _G["CompCharacterNeckSlot"]:SetPoint("TOPRIGHT", _G["CompCharacterHeadSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterShoulderSlot"]:SetPoint("TOPRIGHT", _G["CompCharacterNeckSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterBackSlot"]:SetPoint("TOPRIGHT", _G["CompCharacterShoulderSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterChestSlot"]:SetPoint("TOPRIGHT", _G["CompCharacterBackSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterWristSlot"]:SetPoint("TOPRIGHT", _G["CompCharacterChestSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterMainHandSlot"]:SetPoint("TOPRIGHT", _G["CompCharacterWristSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterSecondaryHandSlot"]:SetPoint("TOPRIGHT", _G["CompCharacterMainHandSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterHandsSlot"]:SetPoint("TOPRIGHT", _G["CompCharacterSecondaryHandSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterWaistSlot"]:SetPoint("TOPRIGHT", _G["CompCharacterHandsSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterLegsSlot"]:SetPoint("TOPRIGHT", _G["CompCharacterWaistSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterFeetSlot"]:SetPoint("TOPRIGHT", _G["CompCharacterLegsSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterFinger0Slot"]:SetPoint("TOPRIGHT", _G["CompCharacterFeetSlot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterFinger1Slot"]:SetPoint("TOPRIGHT", _G["CompCharacterFinger0Slot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterTrinket0Slot"]:SetPoint("TOPRIGHT", _G["CompCharacterFinger1Slot"], "BOTTOMRIGHT", 0, -1)
    _G["CompCharacterTrinket1Slot"]:SetPoint("TOPRIGHT", _G["CompCharacterTrinket0Slot"], "BOTTOMRIGHT", 0, -1)

    -- Create or reuse the model frame
    cmodelFrame:SetPoint("TOPLEFT", CCS_EC, "TOPLEFT", 3, 0)
    cmodelFrame:SetPoint("BOTTOMRIGHT", _G["CompCharacterTrinket1Slot"], "BOTTOMLEFT", 0, 0)
    cmodelFrame:SetFrameStrata("HIGH")
    cmodelFrame:SetFrameLevel(1)
    
    -- Optional background texture
    local cmodelFrametex = _G["CompCharacterModeltex"] or cmodelFrame:CreateTexture("CompCharacterModeltex", "BACKGROUND", nil)
    cmodelFrametex:SetAllPoints()
    cmodelFrametex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\MOTHERtalenttree.BLP")
    cmodelFrametex:SetTexCoord(0, 0.69, 0, 0.87)
    cmodelFrametex:SetVertexColor(0.4, 0, 0.4, 0.9)

    local raceZoomLevels = {
        Human         = { [2] = .95,  [3] = .95 },
        NightElf      = { [2] = .95,  [3] = .95 },
        Orc           = { [2] = .95,  [3] = .95 },
        Troll         = { [2] = .95,  [3] = .95 },
        Undead        = { [2] = .95,  [3] = .95 },
        BloodElf      = { [2] = .95,  [3] = .95 },
        Nightborne    = { [2] = .95,  [3] = .95 },
        MagharOrc     = { [2] = .95,  [3] = .95 },
        VoidElf       = { [2] = .95,  [3] = .95 },
        Pandaren      = { [2] = .95,  [3] = .95 },
        LightforgedDraenei = { [2] = .95, [3] = .95 },
        Worgen        = { [2] = .95,  [3] = .9 },
        Gnome         = { [2] = 1.05,  [3] = 1.05 },
        Mechagnome    = { [2] = 1.05,  [3] = 1.05 },
        Goblin        = { [2] = 1.05,  [3] = 1.05 },
        Vulpera       = { [2] = 1.05,  [3] = 1.05 },
        Dwarf         = { [2] = 1.05,  [3] = 1.05 },
        DarkIronDwarf = { [2] = 1.05,  [3] = 1.05 },
        Draenei       = { [2] = .93,  [3] = .93 },
        ZandalariTroll = { [2] = .93, [3] = .93 },
        KulTiran      = { [2] = .93, [3] = .93 },
        Tauren        = { [2] = .93, [3] = .93 },
        HighmountainTauren = { [2] = .93, [3] = .93 },
        Dracthyr      = { [2] = .95, [3] = .95 },
    }

    local raceFile = select(2, UnitRace("player"))
    local genderID = UnitSex("player") -- 2 = male, 3 = female
    -- Adjust zoom based on character size
    local zoomLevel = raceZoomLevels[raceFile] and raceZoomLevels[raceFile][genderID] or 1.0

    -- Initialize model
    cmodelFrame:ClearModel()
    cmodelFrame:SetUnit("player")
    cmodelFrame:SetPortraitZoom(zoomLevel)
    cmodelFrame:SetCamDistanceScale(6)
    cmodelFrame.zoomLevel = 6
    cmodelFrame:SetPosition(0, 0, .4)
    cmodelFrame:SetRotation(0)
    cmodelFrame:RefreshCamera()
    cmodelFrame:Show()

    -- Rotation via left-click drag
    cmodelFrame:EnableMouse(true)
    cmodelFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.isRotating = true
            self.startX = GetCursorPosition()
            self.startRotation = self:GetFacing()
        end
    end)

    cmodelFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self.isRotating = false
        end
    end)

    cmodelFrame:SetScript("OnUpdate", function(self)
        if self.isRotating then
            local x = GetCursorPosition()
            local scale = UIParent:GetEffectiveScale()
            local delta = (x - self.startX) / scale
            self:SetFacing(self.startRotation + delta * 0.01)
        end
    end)

    -- Time to make the donuts!
    local frameNames = {
    "StaminaFrame",
    "PrimeStatFrame",
    "CritFrame",
    "HasteFrame",
    "MasteryFrame",
    "VersFrame",
    }

    local function getStatInfo(x, stats, unit)
        local iconpath = "Interface\\Icons\\INV_Misc_QuestionMark"
        local iconname = ""
        local statvalue = 0
        
        if      x == 1 then 
                iconpath = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\stamina.png"
                iconname = ITEM_MOD_STAMINA_SHORT
                statvalue = stats.STAMINA
        elseif  x == 2 then 
				if unit == "player" then
					local spec = GetSpecialization()
					local _, _, _, _, _, primaryStat = GetSpecializationInfo(spec)
					if      primaryStat == 1 then 
						iconpath = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\strength.png"
						iconname = ITEM_MOD_STRENGTH_SHORT
						statvalue = stats.STRENGTH
					elseif  primaryStat == 2 then 
						iconpath = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\agility.png"
						iconname = ITEM_MOD_AGILITY_SHORT
						statvalue = stats.AGILITY
					elseif  primaryStat == 4 then 
						iconpath = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\intellect.png"
						iconname = ITEM_MOD_INTELLECT_SHORT
						statvalue = stats.INTELLECT
					end
				elseif unit == InspectFrame.unit then
					local specID = GetInspectSpecialization(unitinspect)
					if specID and specID ~= 0 then
						--local _, specName, _, _, role, classFile = GetSpecializationInfoByID(specID)

							local specPrimaryStat = {
								-- DRUID
								[102] = 4, -- Balance
								[103] = 2,   -- Feral
								[104] = 2,   -- Guardian
								[105] = 4, -- Restoration

								-- SHAMAN
								[262] = 4, -- Elemental
								[263] = 2,   -- Enhancement
								[264] = 4, -- Restoration

								-- MONK
								[268] = 2,   -- Brewmaster
								[269] = 2,   -- Windwalker
								[270] = 4, -- Mistweaver

								-- PALADIN
								[65]  = 4, -- Holy
								[66]  = 1,  -- Protection
								[70]  = 1,  -- Retribution

								-- HUNTER
								[253] = 2, -- Beast Mastery
								[254] = 2, -- Marksmanship
								[255] = 2, -- Survival

								-- ROGUE
								[259] = 2, -- Assassination
								[260] = 2, -- Outlaw
								[261] = 2, -- Subtlety

								-- WARRIOR
								[71]  = 1, -- Arms
								[72]  = 1, -- Fury
								[73]  = 1, -- Protection

								-- DEATH KNIGHT
								[250] = 1, -- Blood
								[251] = 1, -- Frost
								[252] = 1, -- Unholy

								-- MAGE
								[62]  = 4, -- Arcane
								[63]  = 4, -- Fire
								[64]  = 4, -- Frost

								-- PRIEST
								[256] = 4, -- Discipline
								[257] = 4, -- Holy
								[258] = 4, -- Shadow

								-- WARLOCK
								[265] = 4, -- Affliction
								[266] = 4, -- Demonology
								[267] = 4, -- Destruction

								-- EVOKER
								[1467] = 4, -- Devastation
								[1468] = 4, -- Preservation
								[1473] = 4, -- Augmentation
							}

						local primaryStat = specPrimaryStat[specID] or 2
						
						if      primaryStat == 1 then 
							iconpath = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\strength.png"
							iconname = ITEM_MOD_STRENGTH_SHORT
							statvalue = stats.STRENGTH
						elseif  primaryStat == 2 then 
							iconpath = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\agility.png"
							iconname = ITEM_MOD_AGILITY_SHORT
							statvalue = stats.AGILITY
						elseif  primaryStat == 4 then 
							iconpath = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\intellect.png"
							iconname = ITEM_MOD_INTELLECT_SHORT
							statvalue = stats.INTELLECT
						end
					end
				end			
        elseif  x == 3 then 
                iconpath = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\crit.png"
                iconname = ITEM_MOD_CRIT_RATING_SHORT
                statvalue = stats.CRIT_RATING
        elseif  x == 4 then 
                iconpath = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\haste.png"
                iconname = ITEM_MOD_HASTE_RATING_SHORT
                statvalue = stats.HASTE_RATING
        elseif  x == 5 then 
                iconpath = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\mastery.png"
                iconname = ITEM_MOD_MASTERY_RATING_SHORT
                statvalue = stats.MASTERY_RATING
        elseif  x == 6 then 
                iconpath = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\versatility.png"
                iconname = STAT_VERSATILITY
                statvalue = stats.VERSATILITY
        end
        
        return iconpath, iconname, statvalue
    end

    local cstats = CCS:GetUnitEquipmentStats("player")

    for i, name in ipairs(frameNames) do
        local frame = _G["CompCharacter"..name] or CreateFrame("Button", "CompCharacter"..name, CCS_EC)
        frame:SetSize(64.5, 64.5)
        frame:SetPoint("BOTTOMLEFT", CCS_EC, "BOTTOMLEFT", ((i - 1) * 71)+5, 0) -- horizontal layout

        -- Background texture
        frame.bg = frame.bg or frame:CreateTexture(nil, "BACKGROUND")
        frame.bg:SetAllPoints()
        frame.bg:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\steelsquare.png")

        -- Icon texture (top-aligned)
        frame.icon = frame.icon or frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetSize(32, 32)
        frame.icon:SetPoint("TOP", frame, "TOP", 0, -7)
        local iconpath, iconname, statvalue = getStatInfo(i, cstats, "player")
        frame.icon:SetTexture(iconpath)

        -- Font string (bottom-aligned)
        frame.label = frame.label or frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.label:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
        frame.label:SetText(BreakUpLargeNumbers(statvalue))
        frame:Show()

        frame:SetScript("OnEnter", function(self) 
                CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT")
                CCS.tooltip:AddLine(iconname, 1, 1, 1)

                CCS.tooltip:Show()
        end)
        frame:SetScript("OnLeave", function() CCS.tooltip:Hide() end)
        
    end
        
    ----------------
    -- Set up the inspect side of the frame.
    ----------------
    for slotIndex = 1,17 do 
        if slotIndex ~= 4 then
            local slotName = CCS.getSlotFrameName(slotIndex, "CompInspect")
            local itemframe = _G[slotName] or CreateFrame("Button", slotName, CCS_EC)
            local itemframetex = _G[slotName.."tex"] or itemframe:CreateTexture(slotName.."tex", "ARTWORK", nil)
            local link = GetInventoryItemLink(unitinspect, slotIndex)
            local itemTexture 
            if link then
                itemTexture = select(10, C_Item.GetItemInfo(link))
            end
            itemframe:SetFrameStrata("HIGH")
            itemframe:SetFrameLevel(5)
            itemframe:SetSize(37,37)
            itemframetex:SetAllPoints(itemframe)
            itemframetex:SetTexture(itemTexture or CCS.emptySlotTextures[slotIndex])
            itemframetex:Show()
            CCS.updateLocationInfo(unitinspect, slotIndex, "CompInspect")
            itemframe:SetScale(.8648)

            itemframe:SetScript("OnEnter", function(self) 
                    if link then
					    CompareToolTip:SetOwner(itemframe, "ANCHOR_RIGHT")
						CCS.RenderSafeTooltip(CompareToolTip, link, unitinspect)
                    end
            end)
            itemframe:SetScript("OnLeave", function() CompareToolTip:Hide() end)
        end
    end 

    _G["CompInspectHeadSlot"]:SetPoint("TOPLEFT", CCS_EC, "TOP", 29, 0)
    _G["CompInspectNeckSlot"]:SetPoint("TOPLEFT", _G["CompInspectHeadSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectShoulderSlot"]:SetPoint("TOPLEFT", _G["CompInspectNeckSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectBackSlot"]:SetPoint("TOPLEFT", _G["CompInspectShoulderSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectChestSlot"]:SetPoint("TOPLEFT", _G["CompInspectBackSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectWristSlot"]:SetPoint("TOPLEFT", _G["CompInspectChestSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectMainHandSlot"]:SetPoint("TOPLEFT", _G["CompInspectWristSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectSecondaryHandSlot"]:SetPoint("TOPLEFT", _G["CompInspectMainHandSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectHandsSlot"]:SetPoint("TOPLEFT", _G["CompInspectSecondaryHandSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectWaistSlot"]:SetPoint("TOPLEFT", _G["CompInspectHandsSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectLegsSlot"]:SetPoint("TOPLEFT", _G["CompInspectWaistSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectFeetSlot"]:SetPoint("TOPLEFT", _G["CompInspectLegsSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectFinger0Slot"]:SetPoint("TOPLEFT", _G["CompInspectFeetSlot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectFinger1Slot"]:SetPoint("TOPLEFT", _G["CompInspectFinger0Slot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectTrinket0Slot"]:SetPoint("TOPLEFT", _G["CompInspectFinger1Slot"], "BOTTOMLEFT", 0, -1)
    _G["CompInspectTrinket1Slot"]:SetPoint("TOPLEFT", _G["CompInspectTrinket0Slot"], "BOTTOMLEFT", 0, -1)	


    -- Create or reuse the model frame
    imodelFrame:SetPoint("TOPRIGHT", CCS_EC, "TOPRIGHT", -3, 0)
    imodelFrame:SetPoint("BOTTOMLEFT", _G["CompInspectTrinket1Slot"], "BOTTOMRIGHT", 0, 0)
    imodelFrame:SetFrameStrata("HIGH")
    imodelFrame:SetFrameLevel(1)
    -- Optional background texture
    local imodelFrametex = _G["CompInspectModeltex"] or imodelFrame:CreateTexture("CompInspectModeltex", "BACKGROUND", nil)
    imodelFrametex:SetAllPoints()
    imodelFrametex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\MOTHERtalenttree.BLP")
    imodelFrametex:SetTexCoord(0, 0.69, 0, 0.87)
    imodelFrametex:SetVertexColor(0.4, 0, 0.4, 0.9)
    
    raceFile = select(2, UnitRace(unitinspect))
    genderID = UnitSex(unitinspect) -- 2 = male, 3 = female
    zoomLevel = raceZoomLevels[raceFile] and raceZoomLevels[raceFile][genderID] or 1.0
    
    -- Initialize model
    imodelFrame:ClearModel()
    imodelFrame:SetUnit(unitinspect)
    imodelFrame:SetPortraitZoom(zoomLevel)
    imodelFrame.zoomLevel = 6
    imodelFrame:SetCamDistanceScale(6)
    imodelFrame:SetPosition(0, 0, .4)
    imodelFrame:SetRotation(0)
    imodelFrame:RefreshCamera()
    imodelFrame:Show()

    -- Rotation via left-click drag
    imodelFrame:EnableMouse(true)
    imodelFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self.isRotating = true
            self.startX = GetCursorPosition()
            self.startRotation = self:GetFacing()
        end
    end)

    imodelFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            self.isRotating = false
        end
    end)

    imodelFrame:SetScript("OnUpdate", function(self)
        if self.isRotating then
            local x = GetCursorPosition()
            local scale = UIParent:GetEffectiveScale()
            local delta = (x - self.startX) / scale
            self:SetFacing(self.startRotation + delta * 0.01)
        end
    end)

    -- Set up the bottom/stat area
    -- Something broken this way comes!

    local istats = CCS:GetUnitEquipmentStats(unitinspect)

    for i, name in ipairs(frameNames) do
        local frame = _G["CompInspect"..name] or CreateFrame("Button", "CompInspect"..name, CCS_EC)
        frame:SetSize(64.5, 64.5)
        frame:SetPoint("TOPLEFT", _G["CompInspectTrinket1Slot"], "BOTTOMLEFT", ((i - 1) * 71)+1, -2) -- horizontal layout

        -- Background texture
        frame.bg = frame.bg or frame:CreateTexture(nil, "BACKGROUND")
        frame.bg:SetAllPoints()
        frame.bg:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\steelsquare.png")

        -- Icon texture (top-aligned)
        frame.icon = frame.icon or frame:CreateTexture(nil, "ARTWORK")
        frame.icon:SetSize(32, 32)
        frame.icon:SetPoint("TOP", frame, "TOP", 0, -7)
        local iconpath, iconname, statvalue = getStatInfo(i, istats, unitinspect)
        frame.icon:SetTexture(iconpath)

        -- Font string (bottom-aligned)
        frame.label = frame.label or frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.label:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
        frame.label:SetText(BreakUpLargeNumbers(statvalue))
        frame:Show()

        frame:SetScript("OnEnter", function(self) 
                CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT")
                CCS.tooltip:AddLine(iconname, 1, 1, 1)

                CCS.tooltip:Show()
        end)
        frame:SetScript("OnLeave", function() CCS.tooltip:Hide() end)
        
    end

	--------------------------
	-- Create TalentCompareframe Elements
	--------------------------
    CCS_TC = _G["CCS_TalentCompareframe"] or CreateFrame("Frame", "CCS_TalentCompareframe", CCS_ic)
    CCS_TC:SetPoint("TOPLEFT", CCS_ic, "TOPLEFT", 0, -67)
    CCS_TC:SetPoint("RIGHT", CCS_ic, "RIGHT", 0, 0)	
    CCS_TC:SetPoint("BOTTOM", CCS_ic, "BOTTOM", 0, 34)		
	CCS_TC:Hide()

	--------------------------
	-- Create PVPCompareframe Elements
	--------------------------
    CCS_PVP = _G["CCS_PVPCompareframe"] or CreateFrame("Frame", "CCS_PVPCompareframe", CCS_ic)
    CCS_PVP:SetPoint("TOPLEFT", CCS_ic, "TOPLEFT", 0, -67)
    CCS_PVP:SetPoint("RIGHT", CCS_ic, "RIGHT", 0, 0)	
    CCS_PVP:SetPoint("BOTTOM", CCS_ic, "BOTTOM", 0, 34)		
	CCS_PVP:Hide()

	--------------------------
	-- Create Footer Elements
	--------------------------
end

local function display_time(timex, spelltimer)
	local timestring = ""
	
	if timex < 0 then timex = timex*-1 end
	
	local hours = floor(mod(timex, 86400)/3600)
	local minutes = floor(mod(timex, 3600)/60)
	local seconds = floor(mod(timex,60))
	if spelltimer == false then
		timestring = format("%02d:%02d:%02d", hours, minutes, seconds)
	else
		if hours > 0 then timestring = timestring .. hours .. "h " end
		if minutes > 0 then timestring = timestring .. format("%02dm ",minutes) end
		if seconds > 0 and hours <= 0 then timestring = timestring .. format("%02ds ", seconds)  end
	end
	return timestring
end

local function stars(runtime, dungeontime)
	local text = "|cFFFFFC33".."|r"
	
	if runtime == 0 then text = "|cFFFFFC33".."|r"
	elseif runtime < (dungeontime * 0.6) then text = "|cFFFFFC33".."***".."|r"
	elseif runtime < (dungeontime * 0.8) then text = "|cFFFFFC33".."**".."|r"
	elseif runtime < dungeontime then text = "|cFFFFFC33".."*".."|r"
	end
	return text
end

function CCS.getraiderioscoreinspect()
    local name
    
    if InspectFrame and InspectFrame.unit then
        name = UnitName(InspectFrame.unit)
    else
        name = ""
    end
    
    local score=0
    local returnvalue=""
    local scorecolor=""
    
    if option("showmythicplusscore_inspect") ~= true or name == "" or name == nil or C_PlayerInfo.GetPlayerMythicPlusRatingSummary(InspectFrame.unit) == nil or C_PlayerInfo.GetPlayerMythicPlusRatingSummary(InspectFrame.unit).currentSeasonScore == nil then return "" end
    
    score = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(InspectFrame.unit).currentSeasonScore
    local color = C_ChallengeMode.GetDungeonScoreRarityColor(score)
    local red = color.r
    local green = color.g
    local blue = color.b
    
    scorecolor = format("|cff%.2x%.2x%.2x", red*255,green*255,blue*255)
    
    returnvalue = format(CHALLENGE_COMPLETE_DUNGEON_SCORE, format("%s\n", scorecolor) .. score .. format("|r\n") )
    
    
    return returnvalue
end

local function updatemplussideframe()
	if not InspectFrame or not InspectFrame.unit then return end
	local unit = InspectFrame.unit
	local ccsmi_fs2 = _G["ccsmi_fs2"]
	ccsmi_fs2:SetText(CCS.getraiderioscoreinspect())
	if not C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit) or not C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit).runs then return end
	for x=1,8 do 
		
		local ccsmi_bx = _G["ccsmi_b"..x] or CreateFrame("Frame", "ccsmi_b"..x, _G["ccsmi_sf"]);
		local mapID = C_ChallengeMode.GetMapTable()[x] or 0
		local mapspellID = 0
		local mapName, _, MaptimeLimit, MapTexture = C_ChallengeMode.GetMapUIInfo(mapID)
		local MapTable= C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit).runs[x]
		local MapScore= MapTable and MapTable.mapScore or 0
		local ccsmi_bx_btn1 = _G["ccsmi_b"..x.."_btn1"]
		local ccsmi_bx_btn2 = _G["ccsmi_b"..x.."_btn2"]
		local ccsmi_bx_tex1 = _G["ccsmi_b"..x.."_tex1"]
		local ccsmi_bx_tex2 = _G["ccsmi_b"..x.."_tex2"]
		local ccsmi_bx_fs1 = _G["ccsmi_b"..x.."_fs1"]
		local ccsmi_bx_fs2 = _G["ccsmi_b"..x.."_fs2"]
		local ccsmi_bx_fs3 = _G["ccsmi_b"..x.."_fs3"]
		local ccsmi_bx_fs4 = _G["ccsmi_b"..x.."_fs4"]
		local ccsmi_bx_fs7 = _G["ccsmi_b"..x.."_fs7"]
		local ccsmi_bx_btn1_bg = _G["ccsmi_b"..x.."_btn1_bg"] or ccsmi_bx_btn1:CreateTexture("ccsmi_b"..x.."_btn1_bg", "BACKGROUND", nil)
		local ccsmi_bx_btn2_bg = _G["ccsmi_b"..x.."_btn2_bg"]
		
		ccsmi_bx_tex2:SetTexture(MapTexture or 5221804)
		ccsmi_bx_fs2:SetText(mapName or " ");
        ccsmi_bx_tex2:Show()
		ccsmi_bx_btn2_bg:SetTexture(MapTexture or "Interface\\CovenantRenown\\DragonflightMajorFactionsNiffen.BLP")
		ccsmi_bx_btn2_bg:SetTexCoord(0, 1, 0, 1)
		ccsmi_bx_btn2_bg:SetAlpha(1)
		
		ccsmi_bx_btn1:Show()

		ccsmi_bx_btn1_bg:SetTexture(MapTexture or "Interface\\CovenantRenown\\DragonflightMajorFactionsNiffen.BLP")
		ccsmi_bx_btn1_bg:SetTexCoord(0, 1, 0, 1)
		ccsmi_bx_btn1_bg:SetAlpha(1)
		ccsmi_bx_btn1_bg:SetAllPoints(ccsmi_bx_btn2_bg)
		ccsmi_bx_btn1_bg:Show()

		if MapTable ~= nil and MapScore ~= nil then
			local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(MapScore) or HIGHLIGHT_FONT_COLOR
			local red = color.r
			local green = color.g
			local blue = color.b
			local scorecolor = format("|cff%.2x%.2x%.2x", red*255,green*255,blue*255)
            local bestRunDuration = MapTable and MapTable.bestRunDurationMS/1000 or 0
			
			ccsmi_bx_fs1:SetText(format("%s", scorecolor) .. MapScore or " " .. format("|r\n"))
			
			--== Fortified Score and Color
			
			ccsmi_bx_fs3:SetText(stars(bestRunDuration, MaptimeLimit).. (MapTable and MapTable.bestRunLevel or "0"));
			
			color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(MapScore) or HIGHLIGHT_FONT_COLOR
			red = color.r
			green = color.g
			blue = color.b
			scorecolor = format("|cff%.2x%.2x%.2x", red*255,green*255,blue*255)
			
			ccsmi_bx_fs4:SetText(format("%s", scorecolor) .. format("%.f", MapScore).. format("|r\n"))
			
			if option("showm_overundertime") then
				if (bestRunDuration) == 0 then
					ccsmi_bx_fs7:SetText("     -")
				elseif (bestRunDuration) - MaptimeLimit <= 0 then
					ccsmi_bx_fs7:SetText(display_time(bestRunDuration, false).."  ".."(|cFF00AA00-"..display_time((bestRunDuration) - MaptimeLimit, false).."|r)\n");            
				else
					ccsmi_bx_fs7:SetText(display_time(bestRunDuration, false).."  ".."(|cFFAA0000+"..display_time((bestRunDuration) - MaptimeLimit, false).."|r)\n");            
				end
			else
				ccsmi_bx_fs7:SetText(display_time(bestRunDuration, false).."\n");            
			end
		else
			ccsmi_bx_fs1:SetText("-")
			ccsmi_bx_fs3:SetText("-")
			ccsmi_bx_fs4:SetText("-")
			ccsmi_bx_fs7:SetText("     -")
		end 
	end
end

local function initializemplusplanelframe()
	if not InspectFrame or not InspectFrame.unit or InCombatLockdown() == true then return end
	
	local unit = InspectFrame.unit
	local bgr, bgg, bgb, bgalpha = option("ccsmbgcolor")[1], option("ccsmbgcolor")[2], option("ccsmbgcolor")[3], option("ccsmbgcolor")[4];
	
	-- Create the basic side frame
	local ccsmi_af = _G["ccsmi_af"] or CreateFrame("Frame", "ccsmi_af", InspectFrame, "SecureHandlerBaseTemplate");
	local ccsmi_sf = _G["ccsmi_sf"] or CreateFrame("Frame", "ccsmi_sf", InspectFrame, "SecureHandlerBaseTemplate");
	local sf_bg = _G["ccsmi_sf_bg"] or ccsmi_sf:CreateTexture("ccsmi_sf_bg", "BACKGROUND", nil, 1)        
	local sf_topbar = _G["ccsmi_sf_tb"] or ccsmi_sf:CreateTexture("ccsmi_sf_tb", "BACKGROUND", nil, 2)
	local sf_topstreaks = _G["ccsmi_sf_ts"] or ccsmi_sf:CreateTexture("ccsmi_sf_ts", "BACKGROUND", nil, 2)
	local sf_bottombar = _G["ccsmi_sf_bb"] or ccsmi_sf:CreateTexture("ccsmi_sf_bb", "BACKGROUND", nil, 2)
	
	ccsmi_af:SetPoint("TOPLEFT", InspectFrame, "TOPRIGHT", -5, 0);
	ccsmi_af:SetPoint("BOTTOMLEFT", InspectFrame, "BOTTOMRIGHT", -5, 0);
	ccsmi_sf:SetSize(1, 1)
	
	ccsmi_sf:SetPoint("TOPLEFT", ccsmi_af, "TOPRIGHT", 0, 0); 
	ccsmi_sf:SetPoint("BOTTOMLEFT", ccsmi_af, "BOTTOMRIGHT", 0, 0); 
	ccsmi_sf:SetSize(660, 640)
	ccsmi_sf.throttle = 0;
	ccsmi_sf:Hide()
--[[
	if option("showm_sp") == true and (UnitLevel(unit) == CCS.MaxLevel) and (C_MythicPlus.GetCurrentAffixes() and C_MythicPlus.GetCurrentAffixes()[1]) then
		ccsmi_sf:Show()
	else
		ccsmi_sf:Hide()
	end
--]]	
	--sf_bg:ClearAllPoints()
	sf_bg:SetAllPoints()
	sf_bg:SetTexture("Interface\\Masks\\SquareMask.BLP")
	sf_bg:SetColorTexture(bgr,bgg,bgb,bgalpha)
	
	--sf_topbar:ClearAllPoints()
	sf_topbar:SetPoint("TOPLEFT", ccsmi_sf, "TOPLEFT")
	sf_topbar:SetPoint("TOPRIGHT", ccsmi_sf, "TOPRIGHT")
	sf_topbar:SetHeight(16)
	sf_topbar:SetTexture("1723833")
	sf_topbar:SetTexCoord(0, 1, 0.586, .734)
	
	sf_topstreaks:SetPoint("TOPLEFT", sf_topbar, "BOTTOMLEFT")
	sf_topstreaks:SetPoint("TOPRIGHT", sf_topbar, "BOTTOMRIGHT")
	sf_topstreaks:SetHeight(43)
	sf_topstreaks:SetTexture("1723833")
	sf_topstreaks:SetTexCoord(0, 1, 0, .328)
	
	sf_bottombar:SetPoint("BOTTOMLEFT", ccsmi_sf, "BOTTOMLEFT")
	sf_bottombar:SetPoint("BOTTOMRIGHT", ccsmi_sf, "BOTTOMRIGHT")
	
	local bottomheight = 60
	sf_bottombar:SetHeight(bottomheight)
	sf_bottombar:SetTexture("4556093")
	sf_bottombar:SetTexCoord(0, .75, 0, .082) 

	local ccsmi_fs2 = _G["ccsmi_fs2"] or  ccsmi_sf:CreateFontString("ccsmi_fs2")
	ccsmi_fs2:SetPoint("TOP", sf_topbar, "BOTTOM", 0, -35);
	ccsmi_fs2:SetFont(option("fontname_mplus_title") or CCS.fontname, (option("fontsize_mplus_title") or 16), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsmi_fs2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsmi_fs2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
	
	ccsmi_fs2:SetJustifyH("CENTER")
	ccsmi_fs2:SetText(CCS.getraiderioscoreinspect())
	ccsmi_fs2:Show()        
	
	local ccsmi_fs3 = _G["ccsmi_fs3"] or  ccsmi_sf:CreateFontString("ccsmi_fs3")
	ccsmi_fs3:SetPoint("TOPRIGHT", sf_topbar, "BOTTOMRIGHT", -10, -4);
	ccsmi_fs3:SetFont(option("fontname_mplus_title") or CCS.fontname, (option("fontsize_mplus_title") or 12), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsmi_fs3:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsmi_fs3:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
	
	ccsmi_fs3:SetJustifyH("RIGHT")
	ccsmi_fs3:SetText("")
	ccsmi_fs3:Hide()       
	
	-- This is where the bars are made
	for x=1,8 do
		local ccsmi_bx = _G["ccsmi_b"..x] or CreateFrame("Frame", "ccsmi_b"..x, _G["ccsmi_sf"]) --, "SecureHandlerBaseTemplate");
		local height = 1-((math.max(0,1)-1)*0.208333);
		
		ccsmi_bx:SetSize(650, 51*height)
		ccsmi_bx:Show()
		
		local ccsmi_bx_tex1 = _G["ccsmi_b"..x.."_tex1"] or ccsmi_bx:CreateTexture("ccsmi_b"..x.."_tex1", "BACKGROUND", nil)
		--ccsmi_bx_tex1:ClearAllPoints()
		ccsmi_bx_tex1:SetAllPoints()
		ccsmi_bx_tex1:SetTexture("Interface\\Masks\\SquareMask.BLP")
		
		if x%2 == 1 then 
			ccsmi_bx_tex1:SetColorTexture(0, 0, 0, .4)
		else
			ccsmi_bx_tex1:SetColorTexture(.15, .15, .15, .6)
		end
		
		ccsmi_bx_tex1:Show()
		
		local ccsmi_bx_tex2 = _G["ccsmi_b"..x.."_tex2"] or ccsmi_bx:CreateTexture("ccsmi_b"..x.."_tex2", "ARTWORK", nil)
		ccsmi_bx_tex2:SetPoint("TOPLEFT", ccsmi_bx, "TOPLEFT", 5, -3)
		ccsmi_bx_tex2:SetSize(45*height, 45*height)
		ccsmi_bx_tex2:Hide()
		
		local ccsmi_bx_btn1 = _G["ccsmi_b"..x.."_btn1"] or CreateFrame("Frame","ccsmi_b"..x.."_btn1", ccsmi_bx)
		ccsmi_bx_btn1:SetPoint("TOPLEFT", ccsmi_bx, "TOPLEFT",5 ,-3);

		ccsmi_bx_btn1:SetSize(math.min(45*height,38),math.min(45*height,38))
		ccsmi_bx_btn1:SetFrameStrata("HIGH")
		ccsmi_bx_btn1:SetFrameLevel(10)
		ccsmi_bx_btn1:Show()
		
		local ccsmi_bx_btn1_bg = _G["ccsmi_b"..x.."_btn1_bg"] or ccsmi_bx_btn1:CreateTexture("ccsmi_b"..x.."_btn1_bg", "BACKGROUND", nil)
		ccsmi_bx_btn1_bg:SetAllPoints()
		ccsmi_bx_btn1_bg:SetTexture("Interface\\Masks\\SquareMask.BLP")
		ccsmi_bx_btn1_bg:SetColorTexture(0, 0, 0, .3)
		ccsmi_bx_btn1_bg:Show()
		
		local ccsmi_bx_btn2 = _G["ccsmi_b"..x.."_btn2"] or CreateFrame("Button", "ccsmi_b"..x.."_btn2", _G["ccsmi_sf"], "SecureActionButtonTemplate")--, "SecureHandlerBaseTemplate")
		ccsmi_bx_btn2:SetParent(_G["ccsmi_sf"])
		ccsmi_bx_btn2:SetFrameStrata("HIGH")
		ccsmi_bx_btn2:SetFrameLevel(100)
		ccsmi_bx_btn2:SetSize(math.min(45*height,38),math.min(45*height,38))
		ccsmi_bx_btn2:Show()
		
		local ccsmi_bx_btn2_fs = _G["ccsmi_b"..x.."_btn2_fs"] or ccsmi_bx_btn2:CreateFontString("ccsmi_b"..x.."_btn2_fs")
		ccsmi_bx_btn2_fs:SetPoint("CENTER", ccsmi_bx_btn2, "CENTER",0 ,0);
		ccsmi_bx_btn2_fs:SetFont(CCS.fontname, (option("fontsize") or 10), CCS.textoutline);
		if option("showfontshadow") == true then
			ccsmi_bx_btn2_fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsmi_bx_btn2_fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end
		
		ccsmi_bx_btn2_fs:SetJustifyH("CENTER")
		ccsmi_bx_btn2_fs:Show()
		
		local ccsmi_bx_btn2_bg = _G["ccsmi_b"..x.."_btn2_bg"] or ccsmi_bx_btn2:CreateTexture("ccsmi_b"..x.."_btn2_bg", "BACKGROUND", nil)
		ccsmi_bx_btn2_bg:SetAllPoints()
		ccsmi_bx_btn2_bg:SetTexture("Interface\\Masks\\SquareMask.BLP")
		ccsmi_bx_btn2_bg:SetColorTexture(0, 0, 0, .3)
		ccsmi_bx_btn2_bg:Show()
		
		local ccsmi_bx_fs1 = _G["ccsmi_b"..x.."_fs1"] or  ccsmi_bx:CreateFontString("ccsmi_b"..x.."_fs1") -- Over icon
		ccsmi_bx_fs1:SetPoint("CENTER", ccsmi_bx_tex2, "CENTER", 0 ,0)
		ccsmi_bx_fs1:SetFont(option("fontname_mplus_row") or CCS.fontname, (option("fontsize_mplus_row") or 18), CCS.textoutline)
		if option("showfontshadow") == true then
			ccsmi_bx_fs1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsmi_bx_fs1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end
		
		ccsmi_bx_fs1:Hide()
		
		local ccsmi_bx_fs2 = _G["ccsmi_b"..x.."_fs2"] or  ccsmi_bx:CreateFontString("ccsmi_b"..x.."_fs2") -- Dungeon Name
		ccsmi_bx_fs2:SetPoint("LEFT", ccsmi_bx_tex2, "RIGHT", 10 ,0);
		ccsmi_bx_fs2:SetFont(option("fontname_mplus_row") or CCS.fontname, (option("fontsize_mplus_row") or 14), CCS.textoutline);
		if option("showfontshadow") == true then
			ccsmi_bx_fs2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsmi_bx_fs2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end
		
		ccsmi_bx_fs2:SetSize(250, 45*height)
		ccsmi_bx_fs2:SetJustifyH("LEFT")
		ccsmi_bx_fs2:Show()
		
		local ccsmi_bx_fs3 = _G["ccsmi_b"..x.."_fs3"] or  ccsmi_bx:CreateFontString("ccsmi_b"..x.."_fs3") -- Level
		ccsmi_bx_fs3:SetPoint("RIGHT", ccsmi_bx_tex2, "RIGHT", 325 ,0);
		ccsmi_bx_fs3:SetFont(option("fontname_mplus_row") or CCS.fontname, (option("fontsize_mplus_row") or 14), CCS.textoutline);
		if option("showfontshadow") == true then
			ccsmi_bx_fs3:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsmi_bx_fs3:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end
		
		ccsmi_bx_fs3:SetJustifyH("RIGHT")
		ccsmi_bx_fs3:Show()
		
		local ccsmi_bx_fs4 = _G["ccsmi_b"..x.."_fs4"] or  ccsmi_bx:CreateFontString("ccsmi_b"..x.."_fs4") -- Rating
		ccsmi_bx_fs4:SetPoint("RIGHT", ccsmi_bx_tex2, "RIGHT", 400 ,0);
		ccsmi_bx_fs4:SetFont(option("fontname_mplus_row") or CCS.fontname, (option("fontsize_mplus_row") or 14), CCS.textoutline);
		if option("showfontshadow") == true then
			ccsmi_bx_fs4:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsmi_bx_fs4:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end
		
		ccsmi_bx_fs4:SetJustifyH("RIGHT")
		ccsmi_bx_fs4:Show()
		
		local ccsmi_bx_fs7 = _G["ccsmi_b"..x.."_fs7"] or  ccsmi_bx:CreateFontString("ccsmi_b"..x.."_fs7") -- Best
		ccsmi_bx_fs7:SetPoint("LEFT", ccsmi_bx_tex2, "RIGHT", 435 ,0);
		ccsmi_bx_fs7:SetFont(option("fontname_mplus_row") or CCS.fontname, (option("fontsize_mplus_row") or 14), CCS.textoutline);
		if option("showfontshadow") == true then
			ccsmi_bx_fs7:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
			ccsmi_bx_fs7:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
		end
		
		ccsmi_bx_fs7:SetJustifyH("RIGHT")
		ccsmi_bx_fs7:Show()
	end
	_G["ccsmi_b8"]:SetPoint("BOTTOMLEFT", ccsmi_sf, "BOTTOMLEFT", 5, sf_bottombar:GetHeight()+3)
	_G["ccsmi_b7"]:SetPoint("BOTTOMLEFT", _G["ccsmi_b8"], "TOPLEFT", 0, 2)
	_G["ccsmi_b6"]:SetPoint("BOTTOMLEFT", _G["ccsmi_b7"], "TOPLEFT", 0, 2)
	_G["ccsmi_b5"]:SetPoint("BOTTOMLEFT", _G["ccsmi_b6"], "TOPLEFT", 0, 2)
	_G["ccsmi_b4"]:SetPoint("BOTTOMLEFT", _G["ccsmi_b5"], "TOPLEFT", 0, 2)
	_G["ccsmi_b3"]:SetPoint("BOTTOMLEFT", _G["ccsmi_b4"], "TOPLEFT", 0, 2)
	_G["ccsmi_b2"]:SetPoint("BOTTOMLEFT", _G["ccsmi_b3"], "TOPLEFT", 0, 2)
	_G["ccsmi_b1"]:SetPoint("BOTTOMLEFT", _G["ccsmi_b2"], "TOPLEFT", 0, 2)
	
	-- This is where the column header items are made
	local ccsmi_headerlvl_fs = _G["ccsmi_headerlvl_fs"] or  ccsmi_sf:CreateFontString("ccsmi_headerlvl_fs")
	ccsmi_headerlvl_fs:SetPoint("BOTTOMRIGHT", ccsmi_b1_fs3, "TOPRIGHT", 0 ,15)
	ccsmi_headerlvl_fs:SetFont(option("fontname_mplus_header") or CCS.fontname, (option("fontsize_mplus_header") or 14), CCS.textoutline)
	if option("showfontshadow") == true then
		ccsmi_headerlvl_fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsmi_headerlvl_fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
	
	ccsmi_headerlvl_fs:SetText(LEVEL)
    ccsmi_headerlvl_fs:SetTextColor(
        option("fontcolor_mplus_header")[1] or 1,
        option("fontcolor_mplus_header")[2] or 1,
        option("fontcolor_mplus_header")[3] or 1,
        option("fontcolor_mplus_header")[4] or 1
    )	
	ccsmi_headerlvl_fs:Show()        
	
	local ccsmi_header_fs = _G["ccsmi_header_fs"] or  ccsmi_sf:CreateFontString("ccsmi_header_fs")
	ccsmi_header_fs:SetPoint("BOTTOMRIGHT", ccsmi_b1_fs4, "TOPRIGHT", 0 ,15)
	ccsmi_header_fs:SetFont(option("fontname_mplus_header") or CCS.fontname, (option("fontsize_mplus_header") or 14), CCS.textoutline)
	if option("showfontshadow") == true then
		ccsmi_header_fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsmi_header_fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
	
	ccsmi_header_fs:SetText(PVP_RATING_HEADER)
    ccsmi_header_fs:SetTextColor(
        option("fontcolor_mplus_header")[1] or 1,
        option("fontcolor_mplus_header")[2] or 1,
        option("fontcolor_mplus_header")[3] or 1,
        option("fontcolor_mplus_header")[4] or 1
    )	
	ccsmi_header_fs:Show()
	
	local ccsmi_fbt_fs = _G["ccsmi_fbt_fs"] or  ccsmi_sf:CreateFontString("ccsmi_fbt_fs")
	ccsmi_fbt_fs:SetPoint("BOTTOMLEFT", ccsmi_b1_fs7, "TOPLEFT", 0 ,15)
	ccsmi_fbt_fs:SetFont(option("fontname_mplus_header") or CCS.fontname, (option("fontsize_mplus_header") or 14), CCS.textoutline)
	if option("showfontshadow") == true then
		ccsmi_fbt_fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsmi_fbt_fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end

	ccsmi_fbt_fs:SetText(BEST)
    ccsmi_fbt_fs:SetTextColor(
        option("fontcolor_mplus_header")[1] or 1,
        option("fontcolor_mplus_header")[2] or 1,
        option("fontcolor_mplus_header")[3] or 1,
        option("fontcolor_mplus_header")[4] or 1
    )	
	ccsmi_fbt_fs:Show()
	
	local ccsmi_tp_fs = _G["ccsmi_tp_fs"] or  ccsmi_sf:CreateFontString("ccsmi_tp_fs")
	ccsmi_tp_fs:SetPoint("BOTTOMLEFT", ccsmi_b1_btn1, "TOPLEFT", 0 , 10)
	ccsmi_tp_fs:SetFont(option("fontname_mplus_header") or CCS.fontname, (option("fontsize_mplus_header") or 14), CCS.textoutline)
	if option("showfontshadow") == true then
		ccsmi_tp_fs:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsmi_tp_fs:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
	
	ccsmi_tp_fs:SetText("")
    ccsmi_tp_fs:SetTextColor(
        option("fontcolor_mplus_header")[1] or 1,
        option("fontcolor_mplus_header")[2] or 1,
        option("fontcolor_mplus_header")[3] or 1,
        option("fontcolor_mplus_header")[4] or 1
    )	
	ccsmi_tp_fs:Show()

	_G["ccsmi_sf_bg"]:SetColorTexture(bgr,bgg,bgb,bgalpha)

	C_Timer.After(.2, function() updatemplussideframe(); end)

end

local function initmplusframe()
    if not option("show_inspect") then return end
    local textstring = CCS.getraiderioscoreinspect() or ""
    
    -- Create the title text
    local btnfont1 = _G["InspectMPlusfs1"] or InspectPaperDollFrame:CreateFontString("InspectMPlusfs1")
    
    btnfont1:SetPoint("TOPLEFT", InspectPaperDollFrame, "TOPLEFT", 5, -5)
	btnfont1:SetSize(150, 60)
    btnfont1:SetFont(option("fontname_inspect_mplus") or CCS.fontname, option("fontsize_inspect_mplus") or 11, CCS.textoutline)
	if option("showfontshadow") == true then
		btnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		btnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
    btnfont1:SetText(textstring)
    
----
---- Create the second button
----
	-- Create the new button
	local btn2 = _G["InspectMPlusScoreIconBtn"] or CreateFrame("Button", "InspectMPlusScoreIconBtn", InspectPaperDollItemsFrame)
	btn2:SetSize(32, 32)
	btn2:SetPoint("TOPRIGHT", InspectPaperDollItemsFrame, "TOPRIGHT", -7, -24)
	btn2:SetFrameStrata("HIGH")

	btn2._ccs_OnEnter = function(self)
		CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11)
		GameTooltip_SetTitle(CCS.tooltip, format(CHALLENGE_COMPLETE_DUNGEON_SCORE, ""))
		GameTooltip_AddNormalLine(CCS.tooltip, CLICK_HERE_FOR_MORE_INFO)
		GameTooltip_AddNormalLine(CCS.tooltip, "\n"..L["CONTROL_CLICK"])
		CCS.tooltip:Show()
	end

	btn2._ccs_OnLeave = function(self)
		CCS.tooltip:Hide()
	end

	CCS:ApplyIconStyle(btn2, "rightarrow", 24)

	-- Click behavior
	btn2:SetScript("OnClick", function(self, button)
		PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)

		if IsControlKeyDown() and button == "LeftButton" then
			local def = CCS:GetOptionDefByKey("showm_sp")
			if def then
				CCS:UpdateOption(def, _G["ccsmi_sf"]:IsShown())
				C_Timer.After(.1, function() CCS:LoadOptions() end)
				
			end
			return
		end

		if not InCombatLockdown() then
			if _G["ccsmi_sf"]:IsShown() then
				_G["ccsmi_sf"]:Hide()
			else
				_G["ccsmi_sf"]:Show()
				if _G["CCSf"] then _G["CCSf"]:Hide() end
				if _G["ccs_sf"] then _G["ccs_sf"]:Hide() end
				if WeeklyRewardsFrame:IsVisible() then WeeklyRewardsFrame:Hide() end
			end
		else
			PlaySound(8959)
			RaidNotice_AddMessage(RaidBossEmoteFrame, format("%s", ERR_AFFECTING_COMBAT), ChatTypeInfo["SYSTEM"])
		end
	end)

	btn2:Show()
    
end

local function MoveInspectModelRight() 
    if not option("show_inspect") then return end
    InspectModelFrame:ClearAllPoints();
    InspectModelFrame:SetHeight(InspectFrame:GetHeight());
    InspectModelFrame:SetWidth(InspectFrame:GetHeight()/CCS.ModelAspect);
    InspectModelFrame:SetPoint("LEFT", InspectFrameBg, "RIGHT", 0, 0);
    InspectModelFrame:Show();
    _G["InspectModelFramebg"]:ClearAllPoints()
    _G["InspectModelFramebg"]:SetAllPoints(InspectModelFrame)    
    
    InspectModelFrameBackgroundTopLeft:Hide();
    InspectModelFrameBackgroundBotLeft:Hide();
    InspectModelFrameBackgroundTopRight:Hide();
    InspectModelFrameBackgroundBotRight:Hide();
    
    InspectModelFrameBackgroundOverlay:ClearAllPoints()
    InspectModelFrameBackgroundOverlay:SetPoint("TOPLEFT", InspectModelFrameBackgroundTopLeft, "TOPLEFT", 0, 0)
    InspectModelFrameBackgroundOverlay:SetPoint("BOTTOMRIGHT", InspectModelFrameBackgroundBotRight, "BOTTOMRIGHT", 0, 70)
    InspectModelFrameBackgroundOverlay:Hide()
end

local function MoveInspectModelLeft() 
    if not option("show_inspect") then return end
    local Width = 550 -- Hard code it for now
    local Height = 359+(7*option("vpad_inspect"))  -- Hard code it for now
    InspectModelFrame:ClearAllPoints();
    InspectModelFrame:SetHeight(Height)
    InspectModelFrame:SetWidth(Height/CCS.ModelAspect)
    InspectModelFrame:SetPoint("CENTER", InspectFrameBg, "CENTER", 0, 0);
    InspectModelFrame:SetFrameLevel(2)
    InspectModelFrame:Show();
    InspectModelFrameBackgroundTopLeft:Hide();
    InspectModelFrameBackgroundBotLeft:Hide();
    InspectModelFrameBackgroundTopRight:Hide();
    InspectModelFrameBackgroundBotRight:Hide();
    
    InspectModelFrameBackgroundOverlay:ClearAllPoints()
    InspectModelFrameBackgroundOverlay:SetPoint("TOPLEFT", InspectModelFrameBackgroundTopLeft, "TOPLEFT", 0, 0)
    InspectModelFrameBackgroundOverlay:SetPoint("BOTTOMRIGHT", InspectModelFrameBackgroundBotRight, "BOTTOMRIGHT", 0, 70)
    InspectModelFrameBackgroundOverlay:Hide()
    
    modbg:ClearAllPoints()
    if modbg:GetParent() == nil then
        modbg:SetParent(InspectModelFrame)
    end
    modbg:SetPoint("TOPLEFT", InspectHeadSlot, "TOPLEFT", 0, 0)
    modbg:SetPoint("RIGHT", InspectHandsSlot, "RIGHT", 0, 0)    
    modbg:SetPoint("BOTTOM", InspectMainHandSlot, "BOTTOM", 0, 0)            

    
end


local function ChangeModelBg()
 if InspectFrame == nil or InspectFrame.unit == nil then return end

    local _, _, classID = UnitClass(InspectFrame.unit)
    local _, _, raceID = UnitRace(InspectFrame.unit)
    local specID = GetSpecialization()
    local entry = nil

    if modbg:GetParent() == nil then
        modbg:SetParent(InspectModelFrame)
    end
    
    if option("bgtype_inspect") == "Hide" then
        modtex:Hide()
        return
    end
    modtex:Show()
    if option("bgtype_inspect") == "Class" then 
        -- Class/Specialization background
        entry = CCS.Class_Bg[classID] and CCS.Class_Bg[classID][specID]        
        modtex:SetVertexColor(0.8, 0.8, 0.8, 1)
    elseif option("bgtype_inspect") == "Race" then 
        -- Race background
        if classID == 6 then raceID = 998 -- Death Knight
        elseif classID == 12 then raceID = 999 -- Demon Hunter
        end
        entry = CCS.Race_Bg[raceID] 
        modtex:SetVertexColor(0.7, 0.7, 0.7, 1)
    end
    
    modtex:ClearAllPoints()
    modtex:SetAllPoints()
    
    if entry then
        local texWidth, texHeight, uMin, uMax, vMin, vMax = unpack(entry.map)
        local frameWidth, frameHeight = modtex:GetWidth(), modtex:GetHeight()
        
        modtex:SetTexture(entry.texture)
        
        if option("bgtype_inspect") == "Class" then
            -- Class/Specialization: right-aligned
            modtex:SetTexCoord(
                uMin + ((texWidth - (frameWidth / (frameHeight / texHeight))) / texWidth) * (uMax - uMin),
                uMax,
                vMin,
                vMax
            )
        else
            -- Race: horizontally centered
            local visibleWidth = frameWidth / (frameHeight / texHeight) -- width in texture space
            local uRange = uMax - uMin
            local uOffset = (uRange - (visibleWidth / texWidth) * uRange) / 2
            
            modtex:SetTexCoord(
                uMin + uOffset,
                uMax - uOffset,
                vMin,
                vMax
            )
        end
    else
        -- Default background
        modtex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\MOTHERtalenttree.BLP")
        modtex:SetTexCoord(0, 0.69, 0, 0.87)
        modtex:SetVertexColor(0.4, 0, 0.4, 0.9)
    end
    -- end of dynamic background
end

local function InspectClicky(endstate)
    if endstate == 1 then -- Model code
        if _G["ccs_i"] then ccs_i:Hide() end
        local loc = InspectModelFrame:GetPoint()
        if loc == "LEFT" then -- This is to move model behind the inspect equipment
            MoveInspectModelLeft()
        else -- This is to move the model to the right of the inspect frame.
            MoveInspectModelRight()
        end
    end
    ChangeModelBg()
    PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK); -- just puts a sound in when clicking on the button for more feedback
end

local function initclickframe()
    -- initialize button spacing.
    local btn = _G["CCS_iclk_Btn"] or CreateFrame("Button", "CCS_iclk_Btn", InspectPaperDollItemsFrame, "UIPanelButtonTemplate")
    local textstring = MOUNT_JOURNAL_PLAYER
    local texture = "Interface\\Calendar\\MeetingIcon.blp"
    local name = ""
    local description = ""
    local link = nil
    
    -- Create the main button
    btn:SetSize(24, 24)
    btn:SetPoint("BOTTOM", InspectPaperDollItemsFrame, "BOTTOM", 0, 6)
    btn:SetFrameStrata("HIGH")
    if not option("showmodel_inspect") then btn:Hide() else btn:Show() end
    
    -- Create the title text
    local btnfont1 = _G[btn:GetName().."fs1"]
    if btnfont1 == nil then 
        btnfont1 = btn:CreateFontString(btn:GetName().."fs1")
    end    
    
    btnfont1:SetPoint("BOTTOM", btn, "TOP", -3 ,0)
    btnfont1:SetFont(CCS.fontname, 10, CCS.textoutline)
	if option("showfontshadow") == true then
		btnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		btnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	
	
    btnfont1:SetText(textstring)
    btn:SetNormalTexture(texture)
    
    btn:SetScript("OnEnter", function(self) CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT")
            CCS.tooltip:AddDoubleLine("", nil, 1, 1, 1, 1, 1, 1) 
            CCS.tooltip:Show()
    end)
    btn:SetScript("OnLeave", function() CCS.tooltip:Hide() end)
    btn:SetScript("OnClick", function() InspectClicky(1); end)
-- Button 2 (Compare Button)
    -- initialize button spacing.
    btn2 = _G["CCS_iclk_Btn2"] or CreateFrame("Button", "CCS_iclk_Btn2", InspectPaperDollItemsFrame, "BackdropTemplate")
    btn2:SetSize(102, 20)
    btn2:SetPoint("RIGHT", InspectPaperDollItemsFrame.InspectTalents, "LEFT", -5, 0)
    btn2:SetText(L["Compare"])
    CCS.SkinButton(btn2)

    btn2:SetScript("OnClick", function()
		if InCombatLockdown() then
			PlaySound(8959)
			RaidNotice_AddMessage(RaidBossEmoteFrame, format("%s", ERR_AFFECTING_COMBAT), ChatTypeInfo["SYSTEM"])
		else
			CCS:inspect()
		end
    end)
end

local function initializeinspectframe()
    if not InspectFrame or not option("show_inspect") or InspectFrame.loaded == true or InCombatLockdown() == true then return end
   
    InspectFrame:SetScale(option("sheetscale_inspect") or 1)
    InspectFrame:SetHeight(479+(7*option("vpad_inspect"))) -- Do not allow the frame to get any smaller than the default bliz frame
    InspectFrame:SetWidth(617)
    
    local Bgoffset = 209 + (610 - 540)
    
    InspectFrameInset:ClearAllPoints();
    InspectFrameInset:SetPoint("TOPLEFT", InspectFrame, "TOPLEFT", 4, -60)
    InspectFrameInset:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 610, 0)
    InspectFrameInset:Hide();
    InspectPaperDollFrame.ViewButton:ClearAllPoints()
    InspectPaperDollFrame.ViewButton:SetPoint("BOTTOMLEFT", InspectFrameBg, "BOTTOMLEFT", 5, 5)
    
    InspectFrameBg:SetVertexColor(0,0,0,0);
    InspectFrameBg:ClearAllPoints()
    InspectFrameBg:SetPoint("TOPLEFT", InspectFrame, "TOPLEFT", 0, 0);
    InspectFrameBg:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMRIGHT", 0, 0); --275  .449
    InspectFrame.TopTileStreaks:Hide()
    
    InspectFrame.NineSlice.TopRightCorner:ClearAllPoints()
    InspectFrame.NineSlice.BottomRightCorner:ClearAllPoints()
    InspectFrame.NineSlice.TopRightCorner:SetPoint("TOPRIGHT", InspectFrameBg, "TOPRIGHT", 4, 37)
    InspectFrame.NineSlice.BottomRightCorner:SetPoint("BOTTOMRIGHT", InspectFrameBg, "BOTTOMRIGHT", 4, -3)
	CCS:SkinBlizzardButton(InspectFrameCloseButton, "x", 26)
    InspectFrameCloseButton:ClearAllPoints();
    InspectFrameCloseButton:SetPoint("TOPRIGHT", InspectFrameBg, "TOPRIGHT", -10, -10)
    InspectFrameCloseButton:SetSize(32, 32)
    InspectFrameCloseButton:SetScale(.5)
    
    if InspectPVPFrame then
        InspectPVPFrame.BG:SetPoint("BOTTOMRIGHT", InspectFrameBg, "BOTTOMRIGHT", -5, 30)
        InspectPVPFrame.HonorLevel:SetPoint("TOP", InspectPVPFrame, "TOP", 0, -70)
        InspectPVPFrame.HKs:SetPoint("TOP", InspectPVPFrame, "TOP", 0, -100)
    end
    
    local charbg = _G["InspectFrameBgbg"] or CreateFrame("Frame", "InspectFrameBgbg", InspectFrame)
    local charbgtex = _G["InspectFrameBgbgtex"] or charbg:CreateTexture("InspectFrameBgbgtex", "BACKGROUND", nil, 1)    
    local ccsbg = option("bgcolor_inspect")
        
    charbg:ClearAllPoints()
    charbg:SetAllPoints(InspectFrameBg)
    charbg:SetFrameStrata("BACKGROUND")
    charbgtex:ClearAllPoints()
    charbgtex:SetAllPoints()
    charbgtex:SetTexture("Interface\\Masks\\SquareMask.BLP")
    charbgtex:SetVertexColor(ccsbg[1], ccsbg[2], ccsbg[3], ccsbg[4]);
    
    InspectFrameTitleText:ClearAllPoints();
    InspectFrameTitleText:SetPoint("TOP", InspectFrame, "TOP", 0, 0)
    InspectFrameTitleText:SetPoint("LEFT", InspectFrame, "LEFT", 50, 0)
    InspectFrameTitleText:SetPoint("RIGHT", InspectFrameInset, "RIGHT", -40, 0)
    
    InspectFrameTitleText:SetFont(option("fontname_nametitle_inspect") or CCS.fontname, option("fontsize_nametitle_inspect") or 12, CCS.textoutline)
	if option("showfontshadow") == true then
		InspectFrameTitleText:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		InspectFrameTitleText:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	
	
    InspectFrameTitleText:SetTextColor(
        option("fontcolor_nametitle_inspect")[1] or 1,
        option("fontcolor_nametitle_inspect")[2] or 1,
        option("fontcolor_nametitle_inspect")[3] or 1,
        option("fontcolor_nametitle_inspect")[4] or 1
    )

    InspectLevelText:ClearAllPoints()
    InspectLevelText:SetPoint("TOP", InspectFrameTitleText, "BOTTOM", 0, -5)
    
    InspectLevelText:SetFont(option("fontname_levelclass_inspect") or CCS.fontname, option("fontsize_levelclass_inspect") or 11, CCS.textoutline)
	if option("showfontshadow") == true then
		InspectLevelText:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		InspectLevelText:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	
    
    InspectFrame.NineSlice:ClearAllPoints()
    InspectFrame.NineSlice:SetPoint("TOPLEFT", InspectFrame, "TOPLEFT", 0, 0)
    InspectFrame.NineSlice:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 579, 0)
    InspectFrame.NineSlice:Hide()
    InspectFramePortrait:Hide()
    
    InspectModelFrameBorderBottom:Hide()
    InspectModelFrameBorderBottom2:Hide()
    InspectModelFrameBorderBottomLeft:Hide()
    InspectModelFrameBorderBottomRight:Hide()
    InspectModelFrameBorderLeft:Hide()
    InspectModelFrameBorderRight:Hide()
    InspectModelFrameBorderTop:Hide()
    InspectModelFrameBorderTopLeft:Hide()
    InspectModelFrameBorderTopRight:Hide()
    
    InspectBackSlotFrame:Hide()
    InspectChestSlotFrame:Hide()
    InspectFeetSlotFrame:Hide()
    InspectFinger0SlotFrame:Hide()
    InspectFinger1SlotFrame:Hide()
    InspectHandsSlotFrame:Hide()
    InspectHeadSlotFrame:Hide()
    InspectLegsSlotFrame:Hide()
    InspectMainHandSlotFrame:Hide()
    InspectNeckSlotFrame:Hide()
    InspectSecondaryHandSlotFrame:Hide()
    InspectShirtSlotFrame:Hide()
    InspectShoulderSlotFrame:Hide()
    InspectTabardSlotFrame:Hide()
    InspectTrinket0SlotFrame:Hide()
    InspectTrinket1SlotFrame:Hide()
    InspectWaistSlotFrame:Hide()
    InspectWristSlotFrame:Hide()
    -- All slots on the left (under head) are tied back to this slot
    InspectHeadSlot:ClearAllPoints()
    InspectHeadSlot:SetPoint("TOPLEFT", InspectFrameBg, "TOPLEFT", 30, -60)
    -- Now we change the spacing of the slots on the left
    InspectNeckSlot:ClearAllPoints()
    InspectNeckSlot:SetPoint("TOPLEFT", InspectHeadSlot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectShoulderSlot:ClearAllPoints()
    InspectShoulderSlot:SetPoint("TOPLEFT", InspectNeckSlot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectBackSlot:ClearAllPoints()
    InspectBackSlot:SetPoint("TOPLEFT", InspectShoulderSlot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectChestSlot:ClearAllPoints()
    InspectChestSlot:SetPoint("TOPLEFT", InspectBackSlot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectShirtSlot:ClearAllPoints()
    InspectShirtSlot:SetPoint("TOPLEFT", InspectChestSlot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectTabardSlot:ClearAllPoints()
    InspectTabardSlot:SetPoint("TOPLEFT", InspectShirtSlot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectWristSlot:ClearAllPoints()
    InspectWristSlot:SetPoint("TOPLEFT", InspectTabardSlot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    
    -- All slots on the right (under hands) are tied back to this slot
    InspectHandsSlot:ClearAllPoints()
    InspectHandsSlot:SetPoint("TOPLEFT", InspectFrameBg, "TOPLEFT", 545, -60)
    -- Now we change the spacing of the slots on the right
    InspectWaistSlot:ClearAllPoints()
    InspectWaistSlot:SetPoint("TOPLEFT", InspectHandsSlot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectLegsSlot:ClearAllPoints()
    InspectLegsSlot:SetPoint("TOPLEFT", InspectWaistSlot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectFeetSlot:ClearAllPoints()
    InspectFeetSlot:SetPoint("TOPLEFT", InspectLegsSlot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectFinger0Slot:ClearAllPoints()
    InspectFinger0Slot:SetPoint("TOPLEFT", InspectFeetSlot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectFinger1Slot:ClearAllPoints()
    InspectFinger1Slot:SetPoint("TOPLEFT", InspectFinger0Slot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectTrinket0Slot:ClearAllPoints()
    InspectTrinket0Slot:SetPoint("TOPLEFT", InspectFinger1Slot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    InspectTrinket1Slot:ClearAllPoints()
    InspectTrinket1Slot:SetPoint("TOPLEFT", InspectTrinket0Slot, "BOTTOMLEFT", 0, -option("vpad_inspect"))
    
    InspectMainHandSlot:ClearAllPoints()
    InspectMainHandSlot:SetPoint("BOTTOMLEFT", InspectFrameBg, "BOTTOMLEFT", 235, 60)
    InspectSecondaryHandSlot:ClearAllPoints()
    InspectSecondaryHandSlot:SetPoint("TOPLEFT", InspectMainHandSlot, "TOPRIGHT", 60, 0)
    
    local Height = 359+(7*option("vpad_inspect"))  -- Hard code it for now
    InspectModelFrame:ClearAllPoints();
    InspectModelFrame:SetHeight(Height)
    InspectModelFrame:SetWidth(Height/CCS.ModelAspect)
    InspectModelFrame:SetPoint("CENTER", InspectFrameBg, "CENTER", 0, 0);
    InspectModelFrame:SetFrameLevel(2)
    InspectModelFrame:Show();
    InspectModelFrameBackgroundTopLeft:Hide();
    InspectModelFrameBackgroundBotLeft:Hide();
    InspectModelFrameBackgroundTopRight:Hide();
    InspectModelFrameBackgroundBotRight:Hide();
    
    InspectModelFrameBackgroundOverlay:ClearAllPoints()
    InspectModelFrameBackgroundOverlay:SetPoint("TOPLEFT", InspectModelFrameBackgroundTopLeft, "TOPLEFT", 0, 0)
    InspectModelFrameBackgroundOverlay:SetPoint("BOTTOMRIGHT", InspectModelFrameBackgroundBotRight, "BOTTOMRIGHT", 0, 70)
    InspectModelFrameBackgroundOverlay:Hide()

    modbg:ClearAllPoints()
    if modbg:GetParent() == nil then
        modbg:SetParent(InspectModelFrame)
    end
    modbg:SetPoint("TOPLEFT", InspectHeadSlot, "TOPLEFT", 0, 0)
    modbg:SetPoint("RIGHT", InspectHandsSlot, "RIGHT", 0, 0)    
    modbg:SetPoint("BOTTOM", InspectMainHandSlot, "BOTTOM", 0, 0)        
    modbg:SetFrameStrata("BACKGROUND")
    modbg:SetFrameLevel(100)

    ChangeModelBg()

    if InspectPaperDollFrame.ViewButton ~= nil then
        InspectPaperDollFrame.ViewButton.Left:Hide()
        InspectPaperDollFrame.ViewButton.Middle:Hide()
        InspectPaperDollFrame.ViewButton.Right:Hide()
        InspectPaperDollFrame.ViewButton:GetHighlightTexture():SetVertexColor(0.78, 0.14, 0.69, 0) -- Neon purple with transparency
        
        Mixin(InspectPaperDollFrame.ViewButton, BackdropTemplateMixin)
        CCS.SkinButton(InspectPaperDollFrame.ViewButton)
    end

    if InspectPaperDollItemsFrame.InspectTalents ~= nil then
        InspectPaperDollItemsFrame.InspectTalents.Left:Hide()
        InspectPaperDollItemsFrame.InspectTalents.Middle:Hide()
        InspectPaperDollItemsFrame.InspectTalents.Right:Hide()
        InspectPaperDollItemsFrame.InspectTalents:GetHighlightTexture():SetVertexColor(0.78, 0.14, 0.69, 0) -- Neon purple with transparency
    
        Mixin(InspectPaperDollItemsFrame.InspectTalents, BackdropTemplateMixin)
        CCS.SkinButton(InspectPaperDollItemsFrame.InspectTalents)
		InspectPaperDollItemsFrame.InspectTalents:ClearAllPoints()
		InspectPaperDollItemsFrame.InspectTalents:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMRIGHT", -4, 4)
    end
    
	if InspectGuildFrame ~= nil and InspectGuildFrameBG ~= nil then
		local width = InspectGuildFrame:GetWidth() or 617
		
		InspectGuildFrameBG:SetPoint("BOTTOMRIGHT", InspectGuildFrame, "BOTTOMRIGHT", -4, 4)
		InspectGuildFrameBanner:ClearAllPoints()
		InspectGuildFrameBanner:SetPoint("TOP", InspectGuildFrameBG, "TOP")
	end

    -- This is mostly to adjust for addons like ElvUI that make changes to the character frame.  Ensures better compatibility.
    if InspectFrame.shadow then InspectFrame.shadow:Hide() end
    if InspectFrame.Center then InspectFrame.Center:SetTexture(""); InspectFrame.Center:Hide() end
    if InspectFrame.LeftEdge then InspectFrame.LeftEdge:SetTexture(""); InspectFrame.LeftEdge:Hide() end
    if InspectFrame.RightEdge then InspectFrame.RightEdge:SetTexture(""); InspectFrame.RightEdge:Hide() end
    if InspectFrame.BottomEdge then InspectFrame.BottomEdge:SetTexture(""); InspectFrame.BottomEdge:Hide() end
    if InspectFrame.TopEdge then InspectFrame.TopEdge:SetTexture(""); InspectFrame.TopEdge:Hide() end
    if InspectFrame.BottomRightCorner then InspectFrame.BottomRightCorner:SetTexture(""); InspectFrame.BottomRightCorner:Hide() end
    if InspectFrame.BottomLeftCorner then InspectFrame.BottomLeftCorner:SetTexture(""); InspectFrame.BottomLeftCorner:Hide() end
    if InspectFrame.TopRightCorner then InspectFrame.TopRightCorner:SetTexture(""); InspectFrame.TopRightCorner:Hide() end
    if InspectFrame.TopLeftCorner then InspectFrame.TopLeftCorner:SetTexture(""); InspectFrame.TopLeftCorner:Hide() end
    if InspectFrameCloseButton.Texture then InspectFrameCloseButton.Texture:SetTexture("") end
    if InspectModelFrame and InspectModelFrame.backdrop then InspectModelFrame.backdrop:Hide() end

    local regions = { InspectPaperDollItemsFrame:GetRegions() }
	C_Timer.After(0, function()
    for i = 1, #regions do
        local r = regions[i]
        if r and r.Hide then
            r:Hide()
        end
    end end)
	InspectFrame.loaded = true
end

-- Loop through the Paperdoll Items and create/display information
loopitems = function()

    if not option("show_inspect") or InspectFrame.unit == nil then return end
    local unit = InspectFrame.unit
 
    for slotIndex = 1,17 do 
        if slotIndex ~= 4 then
			CCS.updateLocationInfo(unit, slotIndex, "Inspect")
--[[
            local itemLink = GetInventoryItemLink(unit, slotIndex)
            local itemID = itemLink and tonumber(itemLink:match("item:(%d+)"))

            if itemID then
                local texture = select(10, C_Item.GetItemInfo(itemID))
                if texture then
                    CCS.updateLocationInfo(unit, slotIndex, "Inspect")
                else
                    local slotFrameName = CCS.getSlotFrameName(slotIndex, "Inspect")
                    _G[slotFrameName]:RegisterEvent("GET_ITEM_INFO_RECEIVED")
                    _G[slotFrameName]:SetScript("OnEvent", function(self, event, arg)
                        if event == "GET_ITEM_INFO_RECEIVED" and arg == itemID then
                            CCS.updateLocationInfo(unit, slotIndex, "Inspect")
                            self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
                        end
                    end)
                end
            end--]]
        end
    end 

    -- Create Ilvl Frame and populate
    local iLvl = CCS.GetInspectItemLevel(unit) 
    local ilvlTxt = _G["InspectFrameilvlfs"] or _G["InspectPaperDollFrame"]:CreateFontString("InspectFrameilvlfs")
    local color = "ffffff"

    if iLvl == nil then return true end
    
    color = CCS:GetAverageEquippedRarityHex(unit) or "ffffff"
    
    ilvlTxt:SetPoint("TOP", _G["InspectLevelText"], "BOTTOM", 0, -10) 
    ilvlTxt:SetFont(option("fontname_inspect_ilvl") or CCS.fontname, option("fontsize_inspect_ilvl") or 20, CCS.textoutline)
	if option("showfontshadow") == true then
		ilvlTxt:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ilvlTxt:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
    
    ilvlTxt:SetText("|cFF".. color .. format("%.2f", iLvl or "") .. "|r")
    ilvlTxt:SetShown(option("showilvl_inspect"))
    
    initmplusframe()
    initclickframe()
end 

local function IsInspectDataReady(unit)
	if unit == nil or not UnitExists(unit) then return false end

    for slot = 1, 17 do
        if slot ~= 4 then
            local item = GetInventoryItemLink(unit, slot)
            if item then
                if not C_Item.GetItemInfo(item) then
                    return false
                end
            end
        end
    end

    return true
end

local function FinalizeInspect()
    initializeinspectframe()
    initializemplusplanelframe()
    loopitems()
	C_Timer.After(.2, function()
	InspectFrame:SetAlpha(1)
	InspectModelFrame:SetAlpha(1)	
	end)
end

local function WaitForInspectData(unit)
    C_Timer.After(0.05, function()
		if unit == nil or not UnitExists(unit) then return false end
        if IsInspectDataReady(unit) then
            FinalizeInspect()
        else
            WaitForInspectData(unit)
        end
    end)
end

-- Event handler for inspect sheet
function CCS.InspectSheetEventHandler(event, ...)
	
    -- Retail-only inspect frame updates
    if CCS.GetCurrentVersion() ~= CCS.RETAIL then return end
    if not InspectFrame or not InspectFrame.unit then return end

	local unit = InspectFrame.unit
	
    if not UnitExists(unit) then return end
    if not CanInspect(unit) then return end

    if event == "CCS_EVENT_OPTIONS" then
        if not option("show_inspect") then
            local msg = REQUIRES_RELOAD .. ". (" .. SLASH_RELOAD1 .. ")"
            print(msg)
            PlaySound(8959)
            RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["SYSTEM"])
            ReloadUI()
        end
		InspectFrame.loaded = false
		FinalizeInspect()
        return true
	elseif event == "INSPECT_READY" then
		if not CCS.inspectUpdatePending then
			CCS.inspectUpdatePending = true
			InspectFrame:SetAlpha(0)
            InspectModelFrame:SetAlpha(0)
			FinalizeInspect()
			C_Timer.After(0.1, function() 
				WaitForInspectData(InspectFrame.unit); 
				CCS.inspectUpdatePending = false 
				end)
		end
	end
end