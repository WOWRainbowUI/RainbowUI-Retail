local addonName, ns = ...
local CCS = ns.CCS
local loopitems
if CCS.CurrentVersion ~= CCS.FOREVER then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table
local module = {
    Name = "inspectSheet",
    CompatibleVersions = { CCS.FOREVER },
}

CCS.Modules[module.Name] = module

local modbg = _G["InspectModelFramebg"] or CreateFrame("Frame", "InspectModelFramebg")
local modtex = _G["InspectModelFramebgtex"] or modbg:CreateTexture("InspectModelFramebgtex", "BACKGROUND")    
local modtex2 = _G["InspectModelFramebgtex2"] or modbg:CreateTexture("InspectModelFramebgtex2", "ARTWORK")    

---------------------------
-- Module methods
---------------------------
function module:Initialize(onlyStyle)
    -- Optional setup for the inspect sheet
    -- print("[CCS] inspectSheet initialized")
    -- Nothing to set up yet in this.  This will be future creation code.
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
	CCS.ChangeModelBg(true)
    PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK); -- just puts a sound in when clicking on the button for more feedback
end

local function initclickframe()
    -- initialize button spacing.
    local btn = _G["CCS_iclk_Btn"] or CreateFrame("Button", "CCS_iclk_Btn", InspectPaperDollItemsFrame, "UIPanelButtonTemplate")
    local name = ""
    local description = ""
    local link = nil
    
    -- Create the main button
    if not option("showmodel_inspect") then btn:Hide() else btn:Show() end

    -- Create the inspect model button
    btn:SetSize(23, 23)
    btn:SetNormalTexture("Interface\\Calendar\\MeetingIcon.blp")
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp", "ADD")
    btn:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress.blp")
    btn:SetHitRectInsets(0, 0, 0, 0)
    btn:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMRIGHT", -4, 4)    
    btn:SetFrameStrata("HIGH")

    local btnfont1 = _G[btn:GetName().."fs1"]
    if btnfont1 == nil then 
        btnfont1 = btn:CreateFontString(btn:GetName().."fs1")
    end    

    btnfont1:SetFont(CCS.fontname, 10, CCS.textoutline)
    btnfont1:SetPoint("RIGHT", btn, "LEFT", -3 , 2)
    btnfont1:SetText(MOUNT_JOURNAL_PLAYER)
    btnfont1:SetWordWrap(true)
   
    --btnfont1:SetPoint("BOTTOM", btn, "TOP", -3 ,0)
	if option("showfontshadow") == true then
		btnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		btnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	
    
    btn:SetScript("OnEnter", function(self) CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT")
            CCS.tooltip:AddDoubleLine("", nil, 1, 1, 1, 1, 1, 1) 
            CCS.tooltip:Show()
    end)
    btn:SetScript("OnLeave", function() CCS.tooltip:Hide() end)
    btn:SetScript("OnClick", function() InspectClicky(1); end)
end

local function initializeinspectframe(optupdate)
    if not InspectFrame or not option("show_inspect") or 
	  (InspectFrame.loaded == true and optupdate ~= true) or 
	   InCombatLockdown() == true then 
		return 
	   end
   
    InspectFrame:SetScale(option("sheetscale_inspect") or 1)
    InspectFrame:SetHeight(479+(7*option("vpad_inspect"))) -- Do not allow the frame to get any smaller than the default bliz frame
    InspectFrame:SetWidth(617)

	if not InspectFrame.ccshooked then
		-- This may be used if I need to in the future
		--hooksecurefunc(InspectFrame, "Show", function() print("OPEN") end)
		--hooksecurefunc(InspectFrame, "Hide", function() print("CLOSE") end)
		InspectFrame.ccshooked = true
	end
	
    local bcolor = CCS.NormalizeColor(CCS.StyleColor.border)	
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
    
    local charbg = _G["InspectFrameBgbg"] or CreateFrame("Frame", "InspectFrameBgbg", InspectFrame, BackdropTemplateMixin and "BackdropTemplate")
    local charbgtex = _G["InspectFrameBgbgtex"] or charbg:CreateTexture("InspectFrameBgbgtex", "BACKGROUND", nil, 1)    
    local ccsbg = option("bgcolor_inspect")
    charbg:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- optional background texture
        edgeFile = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\UI-Tooltip-SquareBorder.blp",        -- thin edge texture
        edgeSize = 16,                                              -- thickness of the border
        insets = { left = 3, right = 3, top = 3, bottom = 3 },      -- inset so content doesn't overlap border
    })
    charbg:ClearAllPoints()
    charbg:SetAllPoints(InspectFrameBg)
    charbg:SetFrameStrata("BACKGROUND")
    charbgtex:ClearAllPoints()
    charbgtex:SetAllPoints()
    charbgtex:SetTexture("Interface\\Masks\\SquareMask.BLP")
    charbgtex:SetVertexColor(ccsbg[1], ccsbg[2], ccsbg[3], ccsbg[4]);
	charbg:SetBackdropBorderColor(unpack(bcolor))
    
    InspectFrameTitleText:ClearAllPoints();
    InspectFrameTitleText:SetPoint("TOP", InspectFrame, "TOP", 0, -7)
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
    
    InspectBackSlot.BorderFrame:Hide()
    InspectChestSlot.BorderFrame:Hide()
    InspectFeetSlot.BorderFrame:Hide()
    InspectFinger0Slot.BorderFrame:Hide()
    InspectFinger1Slot.BorderFrame:Hide()
    InspectHandsSlot.BorderFrame:Hide()
    InspectHeadSlot.BorderFrame:Hide()
    InspectLegsSlot.BorderFrame:Hide()
    InspectMainHandSlot.BorderFrame:Hide()
    InspectNeckSlot.BorderFrame:Hide()
    InspectSecondaryHandSlot.BorderFrame:Hide()
    InspectShirtSlot.BorderFrame:Hide()
    InspectShoulderSlot.BorderFrame:Hide()
    InspectTabardSlot.BorderFrame:Hide()
    InspectTrinket0Slot.BorderFrame:Hide()
    InspectTrinket1Slot.BorderFrame:Hide()
    InspectWaistSlot.BorderFrame:Hide()
    InspectWristSlot.BorderFrame:Hide()
	InspectRangedSlot.BorderFrame:Hide()    
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
	InspectRangedSlot:ClearAllPoints()
	InspectRangedSlot:SetPoint("TOPLEFT", InspectMainHandSlot, "BOTTOMLEFT", 0, -5)        
    
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

    C_Timer.After(.1, function() CCS.ChangeModelBg(true) end)

    InspectUITabs:ClearAllPoints()
    InspectUITabs:SetPoint("TOPLEFT", InspectFrameBg,"TOPRIGHT", 0, -2)
    InspectUITabs:SetScale(.75)
    InspectUITabs:SetFrameLevel(9001)

    if bcolor ~= nil then
        InspectFrameModeTab1.Background:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])
        InspectFrameModeTab2.Background:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])
	end

    if InspectPaperDollFrame.ViewButton ~= nil then
        InspectPaperDollFrame.ViewButton.Left:Hide()
        InspectPaperDollFrame.ViewButton.Middle:Hide()
        InspectPaperDollFrame.ViewButton.Right:Hide()
        InspectPaperDollFrame.ViewButton:GetHighlightTexture():SetVertexColor(0.78, 0.14, 0.69, 0) -- Neon purple with transparency
        
        Mixin(InspectPaperDollFrame.ViewButton, BackdropTemplateMixin)
        CCS.SkinButton(InspectPaperDollFrame.ViewButton)
    end

    if InspectPaperDollFrame.InspectTalents ~= nil then

        InspectPaperDollFrame.InspectTalents.Left:Hide()
        InspectPaperDollFrame.InspectTalents.Middle:Hide()
        InspectPaperDollFrame.InspectTalents.Right:Hide()
        InspectPaperDollFrame.InspectTalents:GetHighlightTexture():SetVertexColor(0.78, 0.14, 0.69, 0) -- Neon purple with transparency
    
        Mixin(InspectPaperDollFrame.InspectTalents, BackdropTemplateMixin)
        CCS.SkinButton(InspectPaperDollFrame.InspectTalents)
		InspectPaperDollFrame.InspectTalents:ClearAllPoints()
		InspectPaperDollFrame.InspectTalents:SetPoint("TOPRIGHT", InspectFrame, "TOPRIGHT", -20, -5)
    end
    
	if InspectGuildFrame ~= nil and InspectGuildFrameBG ~= nil then
		local width = InspectGuildFrame:GetWidth() or 617
		
		InspectGuildFrameBG:SetPoint("BOTTOMRIGHT", InspectGuildFrame, "BOTTOMRIGHT", -4, 4)

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
 
    for slotIndex = 1,19 do
        if slotIndex ~= 4 then
			CCS.updateLocationInfo(unit, slotIndex, "Inspect")
        end
    end 

    -- Create Ilvl Frame and populate
    local iLvl = CCS.GetUnitItemLevel(unit) 
    local ilvlTxt = _G["InspectFrameilvlfs"] or _G["InspectPaperDollFrame"]:CreateFontString("InspectFrameilvlfs")
    local color = "ffffff"
	
    color = CCS:GetAverageEquippedRarityHex(unit) or "ffffff"
    
    ilvlTxt:SetPoint("TOP", _G["InspectLevelText"], "BOTTOM", 0, -5) 
    ilvlTxt:SetFont(option("fontname_inspect_ilvl") or CCS.fontname, option("fontsize_inspect_ilvl") or 20, CCS.textoutline)
	if option("showfontshadow") == true then
		ilvlTxt:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ilvlTxt:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end
		
    if C_AddOns.IsAddOnLoaded("LoxxInterruptTracker") then
		ilvlTxt:SetFont(option("fontname_inspect_ilvl") or CCS.fontname, 12, CCS.textoutline)
		ilvlTxt:SetText("|cFFFFFF00Loxx Interrupt Tracker is Interfering with this addon.|r")
		ilvlTxt:Show()
	else
		ilvlTxt:SetText("|cFF".. color .. format("%.2f", iLvl or "") .. "|r")
		ilvlTxt:SetShown(option("showilvlinspect"))
    end
	if not InspectFrame.ccsinitload then
		initclickframe()
		InspectFrame.ccsinitload = true
	end
end 

-- Event handler for inspect sheet
function CCS.ForeverInspectSheetEventHandler(event, ...)

    -- Retail-only inspect frame updates
    if CCS.CurrentVersion ~= CCS.FOREVER then return end
    if not InspectFrame or not option("show_inspect") then return end

	if not InspectFrame.loaded then
		initializeinspectframe()
	end
	
    if event == "CCS_EVENT_OPTIONS" then
        if not option("show_inspect") then
            local msg = REQUIRES_RELOAD .. ". (" .. SLASH_RELOAD1 .. ")"
            print(msg)
            PlaySound(8959)
            RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["SYSTEM"])
            ReloadUI()
        end
		initializeinspectframe(true)
		
		if InspectFrame:IsVisible() == true and InspectFrame.unit ~= nil and InspectFrame.unit ~= "mouseover" then
			loopitems()			
        end

		InspectFrame.loaded = false
        return true
	end
	
	if not InspectFrame.unit or InspectFrame.unit == "mouseover" then return end
	
	if event == "INSPECT_READY" then 
		CCS.ChangeModelBg(true)
		loopitems()
	end
end

