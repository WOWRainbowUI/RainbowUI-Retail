local addonName, ns = ...
local CCS = ns.CCS

if CCS.GetCurrentVersion() ~= CCS.RETAIL then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table

local module = {
    Name = "characterSheet",
    CompatibleVersions = { CCS.RETAIL },
}

CCS.Modules[module.Name] = module
local modbg = _G["CharacterModelFramebg"] or CreateFrame("Frame", "CharacterModelFramebg", CharacterModelScene)
modbg.retries = 0
local modtex = _G["CharacterModelFramebgtex"] or modbg:CreateTexture("CharacterModelFramebgtex", "BACKGROUND")    
local modelbtn = _G["CCS_clk_Btn"] or CreateFrame("Button", "CCS_clk_Btn", PaperDollFrame, "UIPanelButtonTemplate")
local bg_texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\bgmidnight.png"

--[[
local CharacterFrame = _G["CharacterFrame"] or CreateFrame("Frame", "CharacterFrame", CharacterFrame)
CharacterFrame:EnableMouse(false)
CharacterFrame:EnableMouseWheel(false)

local function CCS_CreateCharacterFrameProxy()
    -- Create the new layout root
    CharacterFrame:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 0, 0)
    if C_AddOns.IsAddOnLoaded("Armory") ~= true then
        CharacterFrame:SetPoint("TOPRIGHT", CharacterFrame, "TOPRIGHT", 0, 0)
    end

    -- Move all regions
    local numRegions = CharacterFrame:GetNumRegions()

    for i = 1, numRegions do
        local region = select(i, CharacterFrame:GetRegions())
        if region and region:GetObjectType() then
            region:SetParent(CharacterFrame)
        end
    end

    -- Move all children (but don’t touch CharacterFrame itself)
    local numChildren = CharacterFrame:GetNumChildren()
    for i = 1, numChildren do
        local child = select(i, CharacterFrame:GetChildren())
        if child and child ~= CharacterFrame then
            child:SetParent(CharacterFrame)
        end
    end

    -- Re-anchor anything that was anchored to CharacterFrame
    local function Reanchor(frame)
        if not frame or frame == CharacterFrame or not frame.GetNumPoints then return end

        local points = {}
        for p = 1, frame:GetNumPoints() do
            local point, relTo, relPoint, x, y = frame:GetPoint(p)
            if relTo == CharacterFrame then
                table.insert(points, {point, CharacterFrame, relPoint, x, y})
            end
        end

        if #points > 0 then
            frame:ClearAllPoints()
            for _, pt in ipairs(points) do
                frame:SetPoint(pt[1], pt[2], pt[3], pt[4], pt[5])
            end
        end
    end

    -- Reanchor all children
    numChildren = CharacterFrame:GetNumChildren()
    for i = 1, numChildren do
        local child = select(i, CharacterFrame:GetChildren())
        Reanchor(child)
    end

    -- Reanchor all regions
    numRegions = CharacterFrame:GetNumRegions()
    for i = 1, numRegions do
        local region = select(i, CharacterFrame:GetRegions())
        Reanchor(region)
    end

    return CharacterFrame
end--]]

local function hookfix() 

    if not CCS.AreSecretsDisabled() and _G["ccsm_sf"] and (option("showm_sp_onopen") == true) then
            _G["ccsm_sf"]:Show()
            _G["ccs_sf"]:Hide()             
    elseif _G["ccsm_sf"] and not CCS.AreSecretsDisabled() then
        _G["ccsm_sf"]:Hide()
    end

    if CCS.activeClickedRow then
        CCS.activeClickedRow.clicked = false
        CCS.activeClickedRow.highlight:Hide()
        CCS.activeClickedRow = nil
    end

    -- This is mostly to adjust for addons like ElvUI that make changes to the character frame.  Ensures better compatibility.
    if CharacterFrame.shadow then CharacterFrame.shadow:Hide() end
    if CharacterFrame.Center then CharacterFrame.Center:SetTexture(""); CharacterFrame.Center:Hide() end
    if CharacterFrame.LeftEdge then CharacterFrame.LeftEdge:SetTexture(""); CharacterFrame.LeftEdge:Hide() end
    if CharacterFrame.RightEdge then CharacterFrame.RightEdge:SetTexture(""); CharacterFrame.RightEdge:Hide() end
    if CharacterFrame.BottomEdge then CharacterFrame.BottomEdge:SetTexture(""); CharacterFrame.BottomEdge:Hide() end
    if CharacterFrame.TopEdge then CharacterFrame.TopEdge:SetTexture(""); CharacterFrame.TopEdge:Hide() end
    if CharacterFrame.BottomRightCorner then CharacterFrame.BottomRightCorner:SetTexture(""); CharacterFrame.BottomRightCorner:Hide() end
    if CharacterFrame.BottomLeftCorner then CharacterFrame.BottomLeftCorner:SetTexture(""); CharacterFrame.BottomLeftCorner:Hide() end
    if CharacterFrame.TopRightCorner then CharacterFrame.TopRightCorner:SetTexture(""); CharacterFrame.TopRightCorner:Hide() end
    if CharacterFrame.TopLeftCorner then CharacterFrame.TopLeftCorner:SetTexture(""); CharacterFrame.TopLeftCorner:Hide() end
    if CharacterFrameCloseButton.Texture then CharacterFrameCloseButton.Texture:SetTexture("") end
    if CharacterModelScene and CharacterModelScene.backdrop then CharacterModelScene.backdrop:Hide() end

    CharacterModelScene:SetFrameStrata("Medium")
    CharacterModelScene:SetFrameLevel(9000)
    
    if C_AddOns.IsAddOnLoaded("QuaziiUI") or C_AddOns.IsAddOnLoaded("QUI") then
        if QUI_CharacterFrameBg_Skin ~= nil then
            QUI_CharacterFrameBg_Skin:SetAlpha(0)
        end
        CharacterFrameCloseButton:SetPoint("TOPRIGHT", CharacterFrameBg, "TOPRIGHT", -5, 0)
        CharacterFrameCloseButton:SetSize(32, 32)
        CharacterFrameCloseButton:SetScale(.5)
    end

    if C_AddOns.IsAddOnLoaded("ZygorGuidesVIewer") then

	CharacterFrameInset:Hide()
	CharacterFramePortrait:Hide()
	CharacterFrameBg:Hide()
	CharacterFrameTitleText:Show()
	CharacterFrameCloseButton:Show()

	if CharacterFrame.NineSlice then
		for i,v in pairs(CharacterFrame.NineSlice) do
			if type(v)=="table" and v.Show then v:Hide() end
		end
		CharacterFrame.TitleContainer:Show()
	end
    
    end

end

local function MoveModelLeft() 
    local Height = 359+(7*option("vpad"))  -- Hard code it for now
    
    if CharacterModelScene:GetHeight() == Height then
    return end
    
    CharacterModelScene:ClearAllPoints();
    CharacterModelScene:SetHeight(Height)
    CharacterModelScene:SetWidth(Height/CCS.ModelAspect)
    CharacterModelScene:SetPoint("CENTER", CharacterFrameInset.Bg, "CENTER", 0, 0);
    CharacterModelScene:SetFrameStrata("Medium")
    CharacterModelScene:SetFrameLevel(9000)
    
    CharacterModelFrameBackgroundTopLeft:Hide();
    CharacterModelFrameBackgroundBotLeft:Hide();
    CharacterModelFrameBackgroundTopRight:Hide();
    CharacterModelFrameBackgroundBotRight:Hide();
    CharacterModelFrameBackgroundOverlay:ClearAllPoints()
    CharacterModelFrameBackgroundOverlay:SetPoint("TOPLEFT", CharacterModelFrameBackgroundTopLeft, "TOPLEFT", 0, 0)
    CharacterModelFrameBackgroundOverlay:SetPoint("BOTTOMRIGHT", CharacterModelFrameBackgroundBotRight, "BOTTOMRIGHT", 0, 70)
    CharacterModelFrameBackgroundOverlay:Hide()
    
    modbg:ClearAllPoints()
    modbg:SetPoint("TOPLEFT", CharacterHeadSlot, "TOPLEFT", 0, 0)
    modbg:SetPoint("RIGHT", CharacterHandsSlot, "RIGHT", 0, 0)    
    modbg:SetPoint("BOTTOM", CharacterMainHandSlot, "BOTTOM", 0, 0)            
    
end

local function MoveModelRight() 
    CharacterModelScene:ClearAllPoints();
    CharacterModelScene:SetHeight(CharacterFrame:GetHeight());
    CharacterModelScene:SetWidth(CharacterFrame:GetHeight()/CCS.ModelAspect);
    CharacterModelScene:SetPoint("LEFT", CharacterFrameBg, "RIGHT", 0, 0);
    CharacterModelScene:SetFrameStrata("Medium")
    CharacterModelScene:SetFrameLevel(9000)
    CharacterModelScene:Show();
    
    _G["CharacterModelFramebg"]:ClearAllPoints()
    _G["CharacterModelFramebg"]:SetAllPoints(CharacterModelScene)    
end

local function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

local function StopBGAnimation()
    if modbg.swirl then
        modbg.swirl:Hide()
        modbg.swirl.swirlAnim:Stop()
        modbg.donut:Hide()
        modbg.donutFrame.donutAnim:Stop()
    end
end

local function ChangeModelBg()
    local _, _, classID = UnitClass("player")
    local _, _, raceID = UnitRace("player")
    local specID = GetSpecialization()
    local entry

    StopBGAnimation()

    if option("bgtype") == "Hide" then
        modtex:Hide()
        return
    end
    modtex:Show()

    if option("bgtype") == "Class" then
        entry = CCS.Class_Bg[classID] and CCS.Class_Bg[classID][specID]
        modtex:SetVertexColor(0.8, 0.8, 0.8, 1)
    elseif option("bgtype") == "Race" then
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

        if option("bgtype") == "Class" then
            -- Class/Specialization: right-aligned
            local visibleWidth = frameWidth / (frameHeight / texHeight)
            local left = uMin + ((texWidth - visibleWidth) / texWidth) * (uMax - uMin)
            left = clamp(left, uMin, uMax) -- ensure valid range

            modtex:SetTexCoord(left, uMax, vMin, vMax)
        else
            -- Race: horizontally centered
            local visibleWidth = frameWidth / (frameHeight / texHeight)
            local uRange = uMax - uMin
            local uOffset = (uRange - (visibleWidth / texWidth) * uRange) / 2

            local left = clamp(uMin + uOffset, uMin, uMax)
            local right = clamp(uMax - uOffset, uMin, uMax)

            modtex:SetTexCoord(left, right, vMin, vMax)
        end
    else
        if option("bgtype") ==  "Midnight"  then    
            local texWidth, texHeight, uMin, uMax, vMin, vMax = 408,374, 0, 1, .35, 1
            local frameWidth, frameHeight = modtex:GetWidth(), modtex:GetHeight()
            local visibleWidth = frameWidth / (frameHeight / texHeight)
            local uRange = uMax - uMin
            local uOffset = (uRange - (visibleWidth / texWidth) * uRange) / 2
            local origW, origH = 569, 520
            local newW, newH = modbg:GetSize()
            local scale = math.max(newH / origH, 0.1)
            if (newW == 0 or newH == 0) and modbg.retries < 5 then
                C_Timer.After(0, ChangeModelBg)
                modbg.retries = modbg.retries+1
                return
            elseif (newW == 0 or newH == 0) then
                scale = 1
            end
            modbg.retries = 0

            local offsetY = 80 * scale
            local left = clamp(uMin + uOffset, uMin, uMax)
            local right = clamp(uMax - uOffset, uMin, uMax)
            modtex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\bgmidnight.png")
            modtex:SetVertexColor(0.1, 0, 0.75, 0.95)            
            modtex:SetTexCoord(left, right, vMin, vMax)    
            if option("showbganimations") == true then
                -- VOID SWIRL LAYER (rotating)
                local swirl = modbg.swirl or modbg:CreateTexture(nil, "ARTWORK", nil, 1)
                modbg.swirl = swirl
                swirl:SetTexture("Interface\\GLUES\\Models\\UI_VoidElf\\7XP_Pandemonium_VoidFXSwirl01")
                swirl:SetVertexColor(1, 1, 1, 1)
                swirl:SetScale(scale * 0.85)
                swirl:ClearAllPoints()
                swirl:SetPoint("CENTER", modtex, "CENTER", 0, offsetY)
                swirl:Show()

                local swirlAnim = modbg.swirl.swirlAnim or swirl:CreateAnimationGroup()
                modbg.swirl.swirlAnim = swirlAnim

                local rotate = modbg.swirl.swirlAnim.rotate or swirlAnim:CreateAnimation("Rotation")
                modbg.swirl.swirlAnim.rotate = rotate
                rotate:SetDegrees(360)
                rotate:SetDuration(120)
                rotate:SetOrder(1)

                swirlAnim:SetLooping("REPEAT")
                swirlAnim:Play()

                -- PULSING VOID DONUT MASK (mmm, donuts...)
                local donutFrame = modbg.donutFrame or CreateFrame("Frame", nil, modbg)
                modbg.donutFrame = donutFrame
                donutFrame:ClearAllPoints()
                donutFrame:SetPoint("CENTER", modtex, "CENTER", 0, offsetY)
                donutFrame:SetSize(240 * scale, 350 * scale)
                donutFrame:SetScale(1) -- important: neutral base
                donutFrame:Show()

                local donut = modbg.donut or donutFrame:CreateTexture(nil, "ARTWORK", nil, 2)
                modbg.donut = donut
                donut:SetAllPoints(donutFrame)
                donut:SetTexture("Interface\\GLUES\\Models\\UI_MAINMENU_MIDNIGHT\\UI_MainMenu_Midnight_DonutMask")
                donut:SetVertexColor(.292, .457, .902, 1)
                donut:SetAlpha(1)
                donut:SetBlendMode("ADD")
                donut:Show()

                local donutAnim = modbg.donutFrame.donutAnim or donutFrame:CreateAnimationGroup()
                modbg.donutFrame.donutAnim = donutAnim
                donutAnim:Stop() -- reset if it already existed

                local alphaUp = donutAnim.alphaUp or donutAnim:CreateAnimation("Alpha")
                donutAnim.alphaUp = alphaUp
                alphaUp:SetFromAlpha(0.6)
                alphaUp:SetToAlpha(1.0)
                alphaUp:SetDuration(3)
                alphaUp:SetSmoothing("IN_OUT")
                alphaUp:SetOrder(1)

                local alphaDown = donutAnim.alphaDown or donutAnim:CreateAnimation("Alpha")
                donutAnim.alphaDown = alphaDown
                alphaDown:SetFromAlpha(1.0)
                alphaDown:SetToAlpha(0.6)
                alphaDown:SetDuration(3)
                alphaDown:SetSmoothing("IN_OUT")
                alphaDown:SetOrder(2)

                local scaleUp = donutAnim.scaleUp or donutAnim:CreateAnimation("Scale")
                donutAnim.scaleUp = scaleUp
                scaleUp:SetScale(1.05, 1.05)
                scaleUp:SetDuration(3)
                scaleUp:SetSmoothing("IN_OUT")
                scaleUp:SetOrder(1)

                local scaleDown = donutAnim.scaleDown or donutAnim:CreateAnimation("Scale")
                donutAnim.scaleDown = scaleDown
                scaleDown:SetScale(1 / 1.05, 1 / 1.05) -- back to 1.0
                scaleDown:SetDuration(3)
                scaleDown:SetSmoothing("IN_OUT")
                scaleDown:SetOrder(2)

                donutAnim:SetLooping("REPEAT")
                donutAnim:Play()                
                
            end
        else        
            -- Default background
            modtex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\MOTHERtalenttree.BLP")
            modtex:SetTexCoord(0, 0.69, 0, 0.87)
            modtex:SetVertexColor(0.6, 0, 0.6, 0.95)
        end
    end
end


local function Clicky(endstate)
    if _G["CCSf"] then _G["CCSf"]:Hide() end
    if _G["ccs_sf"] then _G["ccs_sf"]:Hide() end
    if _G["ccsm_sf"] then _G["ccsm_sf"]:Hide() end
    
    if CharacterModelScene:GetHeight() >= (CharacterFrameBg:GetHeight()-5) then -- This is to move model under the character equipment
        MoveModelLeft()
        if _G["ccsm_sf"] and (option("showm_sp_onopen") == true) and (C_MythicPlus.GetCurrentAffixes() and C_MythicPlus.GetCurrentAffixes()[1]) then
            _G["ccsm_sf"]:Show()
        elseif _G["ccsm_sf"] then 
            _G["ccsm_sf"]:Hide() 
        end
    else -- This is to move the model to the right of the character frame.
        MoveModelRight()
    end

    ChangeModelBg()
    PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK);
end

local function ccs_cshow()
    MoveModelLeft()
    if C_AddOns.IsAddOnLoaded("Narcissus") then -- Just relocate the mini talent tree so it isn't hidden behind the character frame.
    C_Timer.NewTicker(.1, function() NarciMiniTalentTree:ClearAllPoints(); 
            NarciMiniTalentTree:SetPoint("TOPLEFT", CharacterFrameBg, "TOPRIGHT", 0, 0) end, 1)
    end

    if C_AddOns.IsAddOnLoaded("Leatrix_Plus") then -- relocate the volume slider
            C_Timer.After(0, function()
                local p=CharacterModelScene 
                for i=1,p:GetNumChildren()do 
                    local c=select(i,p:GetChildren());
                    local n=c:GetName(); 
                    if c and not n and c.Thumb then 
                        c:ClearAllPoints()
                        c:SetPoint("LEFT", CCS_clk_Btn, "RIGHT", 60, 0)
                    end 
                end
            end)
    end


    ChangeModelBg()
    CharacterModelScene.ControlFrame:Hide()
end

local function LootSpecInit()
    if option("showlootspec") then 
        local specIndex = GetLootSpecialization() or 0 -- current loot spec
        local aid, aname, _, aicon = GetSpecializationInfo(GetSpecialization()); -- info for current spec
        
        for count=0, 4, 1 do -- count up to 4 (0 for loot spec based on current spec and 4 more since druids have 4 specs)
            local id, name, _, icon = GetSpecializationInfo(count); -- spec info for the loop
            local link = nil 
            local spellid = nil 
            local description = ""
            local xOffset = (90*option("hpad")/262) + 135 + (26 * (count))   
            local btn = _G["CCS_loot_Btn"..count] or CreateFrame("Button", "CCS_loot_Btn"..count, PaperDollItemsFrame, "UIPanelButtonTemplate")
            local FirstBtn = false -- use firstbtn to deal with titles/headers
            local btn_name = btn:GetName() or "ccslootspec"
            
            if count == 0 then
                name = string.format(LOOT_SPECIALIZATION_DEFAULT, aname or "*" )
                id = aid
                icon = aicon
                FirstBtn = true
            end
            
            if ( id and id ~= 0) then
                -- begin clickable button frame
                btn:SetSize(23, 23)
                btn:SetPoint("BOTTOMLEFT", PaperDollItemsFrame, "BOTTOMLEFT", xOffset, 5)
                btn:SetNormalTexture(icon)
                btn:SetFrameStrata("HIGH")
               
                local btntex = _G[btn_name.."tex"]
                if btntex == nil then btntex = btn:CreateTexture(btn_name.."tex", "OVERLAY") end
                
                btntex:SetAllPoints(btn)
                btn:Show()
                btntex:Show()
                
                if specIndex == 0 and count == 0 then btntex:SetTexture("Interface\\ContainerFrame\\UI-Icon-QuestBorder.blp")
                elseif id == specIndex and count > 0 then btntex:SetTexture("Interface\\ContainerFrame\\UI-Icon-QuestBorder.blp")
                else btntex:SetColorTexture(0,0,0,.65)
                end
                
                btn:SetScript("OnEnter", function(self) CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT")
                        if link then
                            CCS.tooltip:SetHyperlink(link)
                        else
                            CCS.tooltip:AddDoubleLine(name, spellid, 1, 1, 1, 1, 1, 1) 
                            CCS.tooltip:AddLine(description, nil, nil, nil, true)   
                        end
                        CCS.tooltip:Show()
                end)
                btn:SetScript("OnLeave", function() CCS.tooltip:Hide() end)
                
                
                btn:SetScript("OnClick", function() -- Add specific functionality when clicking the button
                        if count == 0 and specIndex ~= 0 then
                            SetLootSpecialization(0) 
                        elseif id ~= specIndex then 
                            SetLootSpecialization(id) 
                        end 
                        PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK); -- just puts a sound in when clicking on the button for more feedback
                end)
                
            end
            -- end clickable button frame
        end
        
        local btnfont1 = _G["CCS_loot_Btn0fs1"] or _G["CCS_loot_Btn0"]:CreateFontString("CCS_loot_Btn0fs1")
        local btnfont2 = _G["CCS_loot_Btn0fs2"] or _G["CCS_loot_Btn0"]:CreateFontString("CCS_loot_Btn0fs2")
        
        btnfont1:SetPoint("CENTER", 0, 0)
        btnfont1:SetFont(CCS.fontname, 16, CCS.textoutline)
        if option("showfontshadow") == true then
            btnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
            btnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
        end
        btnfont1:SetText("**")
        
        btnfont2:SetPoint("BOTTOMLEFT", _G["CCS_loot_Btn0fs1"], "TOPLEFT",0 ,7)
        btnfont2:SetFont(option("fontname_lootspec") or CCS.fontname, (option("fontsize_lootspec") or 10), CCS.textoutline)
        if option("showfontshadow") == true then
            btnfont2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
            btnfont2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
        end	                                                                
        
        btnfont2:SetTextColor(
            option("fontcolor_lootspec")[1] or 1,
            option("fontcolor_lootspec")[2] or 1,
            option("fontcolor_lootspec")[3] or 1,
            option("fontcolor_lootspec")[4] or 1
        )
        if option("showfontshadow") == true then
            btnfont2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
            btnfont2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
        end        
        btnfont2:SetText(SELECT_LOOT_SPECIALIZATION)  
        btnfont2:SetShown(option("showlootspectitle"))
       
    else
            for count=0, 4, 1 do -- count up to 4 (since druids have 4 specs)
                local btn = _G["CCS_loot_Btn"..count]
                if btn and btn:IsShown() then
                    btn:Hide()
                end
            end    
    end

    if _G["CCS_loot_Btn0fs2"] ~= nil then 
        _G["CCS_loot_Btn0fs2"]:SetShown(option("showlootspectitle"))
    end

end

local function SpecChangeInit()
    -- initialize button spacing.
    local specIndex = GetSpecialization();

    if option("showspec") then 
        
        for count=1, 4, 1 do -- count up to 4 (since druids have 4 specs)
            local id, name, _, icon = GetSpecializationInfo(count); -- spec info for the loop
            local link = nil 
            local spellid = nil
            local description = "" 
            local xOffset = 5 + (26 * (count-1)) 
            local btn = _G["CCS_PSpecBtn"..count]
            
            if ( id and id ~= 0) then
                -- begin clickable button frame
                
                if btn == nil then btn = CreateFrame("Button", "CCS_PSpecBtn"..count, PaperDollItemsFrame, "UIPanelButtonTemplate") end
                btn:SetSize(23, 23)
                btn:SetPoint("BOTTOMLEFT", PaperDollItemsFrame, "BOTTOMLEFT", xOffset, 5)
                btn:SetNormalTexture(icon)
                btn:SetFrameStrata("HIGH")
                local btn_name = btn:GetName() or "CCS_PSpecBtn"..count
              
                if count == 1 and option("showspectitle") then 
                    local btnfont1 = _G["CCS_PSpecBtn1fs1"] or btn:CreateFontString("CCS_PSpecBtn1fs1")
                    btnfont1:SetPoint("BOTTOMLEFT", btn, "TOPLEFT",0 ,3)
                    btnfont1:SetFont(option("fontname_specs") or CCS.fontname, (option("fontsize_specs") or 10), CCS.textoutline)
                    if option("showfontshadow") == true then
                        btnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                        btnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                    end
                    
                    btnfont1:SetTextColor(
                        option("fontcolor_specs")[1] or 1,
                        option("fontcolor_specs")[2] or 1,
                        option("fontcolor_specs")[3] or 1,
                        option("fontcolor_specs")[4] or 1
                    )
                    btnfont1:SetText(SPECIALIZATION)
                    btnfont1:Show()
                end
                
                local btntex = _G[btn_name.."tex"]
                if btntex == nil then btntex = btn:CreateTexture(btn_name.."tex", "OVERLAY") end
                
                btntex:SetAllPoints(btn)
                btn:Show()
                btntex:Show()
                
                if count == specIndex then btntex:SetTexture("Interface\\ContainerFrame\\UI-Icon-QuestBorder.blp")
                else btntex:SetColorTexture(0,0,0,.65)
                end
                
                btn:SetScript("OnEnter", function(self) CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT")
                        if link then
                            CCS.tooltip:SetHyperlink(link)
                        else
                            CCS.tooltip:AddDoubleLine(name, spellid, 1, 1, 1, 1, 1, 1) 
                            CCS.tooltip:AddLine(description, nil, nil, nil, true)   
                        end
                        CCS.tooltip:Show()
                end)
                btn:SetScript("OnLeave", function() CCS.tooltip:Hide() end)
                
                
                btn:SetScript("OnClick", function() -- Add specific functionality when clicking the button
                        if count ~= specIndex then 
                            if SetSpecialization == nil then
                                C_SpecializationInfo.SetSpecialization(count) 
                            else
                                SetSpecialization(count) 
                            end
                        end 
                        PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK); -- just puts a sound in when clicking on the button for more feedback
                end)
                -- end clickable button frame
                
            end
            
        end
    else
            for count=1, 4, 1 do -- count up to 4 (since druids have 4 specs)
                local btn = _G["CCS_PSpecBtn"..count]
                if btn and btn:IsShown() then
                    btn:Hide()
                end
            end
    end
        
    if _G["CCS_PSpecBtn1fs1"] ~= nil then 
        _G["CCS_PSpecBtn1fs1"]:SetShown(option("showspectitle"))
    end
end   

local function InitializeFrameUpdates()
    ReputationFrame:ClearAllPoints()
    ReputationFrame:SetPoint("TOPLEFT", CharacterFrameBg, "TOPLEFT", 0, 0)
    ReputationFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", -30, 0)
    _G["CCSf"]:Hide()
    _G["ccs_sf"]:Hide()
end

local function loopitems()
    for slotIndex = 1,19 do 
        CCS.updateLocationInfo("player", slotIndex, "Character")
    end 
end

local function TryLoopItems()

    local allReady = true
    for slot = 1, 19 do
        local link = GetInventoryItemLink("player", slot)
        if link and not GetItemInfo(link) then
            allReady = false
            break
        end
    end

    if allReady then
        CCS.characterUpdatePending = false
        loopitems()
    else
        -- Retry after short delay
        C_Timer.After(0.1, TryLoopItems)
    end
end


local function ReputationFrame_Update()
    local ks={ReputationFrame.ScrollBox.ScrollTarget:GetChildren()}; 
    local gender = UnitSex("player");
    local xtext, factiontext= "", ""

    if C_AddOns.IsAddOnLoaded("PrettyReps") then return end
    
    for _,k in ipairs(ks) do -- Individual Row
        local factionData = C_Reputation.GetFactionDataByIndex(k.factionIndex)
        local ks2={k:GetChildren()}; 
        if factionData ~= nil then
            for _,k2 in ipairs(ks2) do  -- Reputation Bar (in the row)
                local factionID = factionData.factionID
                local name =  factionData.name
                local standingID =  factionData.reaction
                local barMin =  factionData.currentReactionThreshold
                local barMax =  factionData.nextReactionThreshold
                local barValue =  factionData.currentStanding

                k2.Background = k2.Background or k2:CreateTexture(nil, "BACKGROUND", nil, 2)
                
                if (k2.Background) then
                    k2.Background:SetTexture("Interface\\Masks\\SquareMask.BLP")
                    if standingID == 1 then
                        k2.Background:SetColorTexture(.15, .15, .15, 0)
                    else
                        k2.Background:SetColorTexture(.15, .15, .15, 0.90)
                    end
                    k2.Background:SetPoint("TOPLEFT", k2, "TOPLEFT")
                    k2.Background:SetPoint("BOTTOMRIGHT", k2, "BOTTOMRIGHT")                
                end
                
                if (k2.ReputationBar) then
                    k2.ReputationBar.LeftTexture:SetTexture("Interface\\Masks\\SquareMask.BLP")
                    k2.ReputationBar.LeftTexture:SetGradient("Vertical", CreateColor(0, 0, 0, .2), CreateColor(.2, .2, .2, .4)) -- Dark Gray
                    k2.ReputationBar.LeftTexture:SetAlpha(0.9)
                    k2.ReputationBar.LeftTexture:SetPoint("RIGHT", k2, "RIGHT")
                    local hpad = math.min(math.max(210, (option("hpad") or 279)), 279)
                    k2.ReputationBar:SetWidth(250 * hpad / 279)  
                    k2.ReputationBar:SetHeight(k2:GetHeight()*.9)            
                    k2.ReputationBar.RightTexture:Hide()
                end
                
                if name == "Inactive" or name == "Other" then
                    -- we skip the inactive header since the friendship lookup doesn't like it.
                else
                    local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = C_GossipInfo.GetFriendshipReputation(factionID);
                    local colorIndex = standingID;
                    local barColor = FACTION_BAR_COLORS[colorIndex];
                    local factionStandingtext;
                    local isCapped = (standingID == MAX_REPUTATION_REACTION)
                    local isParagon = factionID and C_Reputation.IsFactionParagon(factionID);
                    local isMajorFaction = factionID and C_Reputation.IsMajorFaction(factionID);
                    local repInfo = factionID and C_GossipInfo.GetFriendshipReputation(factionID);
                    
                    if (repInfo and repInfo.friendshipFactionID > 0) then
                        factionStandingtext = repInfo.reaction;
                        if ( repInfo.nextThreshold ) then
                            barMin, barMax, barValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing;
                        else
                            barMin, barMax, barValue = 0, 1, 1;
                            isCapped = true;
                        end
                        local friendshipColorIndex = 5;
                        barColor = FACTION_BAR_COLORS[colorIndex];
                        k2.friendshipID = repInfo.friendshipFactionID;  
                    elseif ( isMajorFaction ) then
                        local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
                        
                        barMin, barMax = 0, majorFactionData.renownLevelThreshold;
                        isCapped = C_MajorFactions.HasMaximumRenown(factionID);
                        barValue = isCapped and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0;
                        barColor = BLUE_FONT_COLOR;
                        
                        k2.friendshipID = nil;
                        factionStandingtext = string.format(RENOWN_LEVEL_LABEL, majorFactionData.renownLevel);
                    else
                        factionStandingtext = GetText("FACTION_STANDING_LABEL"..standingID, gender);
                        k2.friendshipID = nil;
                    end
                    
                    factiontext = factionStandingtext;
                    
                    if isCapped and (not repInfo or repInfo.friendshipFactionID == 0) then
                        barMax = 21000;
                        barValue = 21000;
                        barMin = 0;
                    else
                        barMax = barMax - barMin;
                        barValue = barValue - barMin;
                        barMin = 0;
                    end
                    
                    if isParagon and C_Reputation.IsFactionParagonForCurrentPlayer(factionID) and k2.ParagonIcon then
                        local currentValue,threshold,rewardQuestID,hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
                        local r,g,b = 0,.5,.9
                        
                        factiontext = L["PARAGON"]
                        barMax = threshold
                        barValue = currentValue - (floor(currentValue/threshold)-(hasRewardPending and 1 or 0))*threshold 
                        barMin = 0
                        k2.ParagonIcon:SetShown(hasRewardPending); 
                        k2.ReputationBar:SetStatusBarColor(r,g,b)
                        k2.ReputationBar:SetMinMaxValues(0, barMax);
                        k2.ReputationBar:SetValue(barValue);
                        
                    end
                    
                    if (k2.ReputationBar) then
                        local fontName, fontHeight, fontFlags = k2.ReputationBar.BarText:GetFont()
                        xtext = format("  %-20.20s %-30.30s", factiontext, format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax)))
                        k2.ReputationBar.barProgressText = xtext
                        k2.ReputationBar.reputationStandingText = xtext
                        k2.ReputationBar.BarText:SetFont(option("fontname_repstanding") or fontName, option("fontsize_repstanding"), CCS.textoutline)
                        if option("showfontshadow") == true then
                            k2.ReputationBar.BarText:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                            k2.ReputationBar.BarText:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                        end	                                                                
                        
                        k2.ReputationBar.BarText:SetTextColor(
                            option("fontcolor_repstanding")[1] or 1,
                            option("fontcolor_repstanding")[2] or 1,
                            option("fontcolor_repstanding")[3] or 1,
                            option("fontcolor_repstanding")[4] or 1
                        )
                        k2.Name:SetFont(option("fontname_reputation") or fontName, option("fontsize_reputation"), CCS.textoutline)
                        if option("showfontshadow") == true then
                            k2.Name:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                            k2.Name:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                        end	                                                                
                        
                        k2.Name:SetTextColor(
                            option("fontcolor_reputation")[1] or 1,
                            option("fontcolor_reputation")[2] or 1,
                            option("fontcolor_reputation")[3] or 1,
                            option("fontcolor_reputation")[4] or 1
                        )
                        k2.ReputationBar.BarText:SetText(xtext)                
                        k2.ReputationBar.BarText:ClearAllPoints()
                        k2.ReputationBar.BarText:SetPoint("LEFT", k2.ReputationBar, "LEFT")
                    end
                    
                    if (k2.AccountWideIcon) then
                        k2.awi = k2.awi or k2:CreateTexture(nil, "OVERLAY", nil, 2)
                        k2.awi:SetSize(23, 23)
                        k2.awi:SetAtlas("warbands-icon", true)
                        k2.awi:SetScale(0.9)
                        k2.awi:ClearAllPoints()
                        k2.awi:SetPoint("TOPLEFT", k2.AccountWideIcon, "TOPLEFT")
                        k2.awi:SetPoint("BOTTOMRIGHT", k2.AccountWideIcon, "BOTTOMRIGHT")
                        k2.awi:SetShown(C_Reputation.IsAccountWideReputation(factionID))
                    end 
                end 
                
                
            end 
        end
    end
end

local function CurrencyFrame_Update()
            local tf={TokenFrame.ScrollBox.ScrollTarget:GetChildren()}; 
            
            for _,t in ipairs(tf) do 
                if t and t.Name then t.Name:SetFont(t.Name:GetFont(), option("fontsize_currency") or 11, CCS.textoutline)
                        if option("showfontshadow") == true then
                            t.Name:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                            t.Name:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                        end	                                                                
                end 
                if t and t.Count then t.Count:SetFont(t.Count:GetFont(), option("fontsize_currency") or 11, CCS.textoutline)
                        if option("showfontshadow") == true then
                            t.Count:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                            t.Count:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                        end	                                                
                end 

                    if t.Text then
                        t.Text:SetFont(option("fontname_currency") or fontName, option("fontsize_currency"), CCS.textoutline)
                        if option("showfontshadow") == true then
                            t.Text:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                            t.Text:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                        end	                                                
                        
                        t.Text:SetTextColor(
                            option("fontcolor_currency")[1] or 1,
                            option("fontcolor_currency")[2] or 1,
                            option("fontcolor_currency")[3] or 1,
                            option("fontcolor_currency")[4] or 1
                        )                    
                    end

                local ks2={t:GetChildren()}; 
                for _,k2 in ipairs(ks2) do  -- Individual Row
                    k2.Background = k2.Background or k2:CreateTexture(nil, "BACKGROUND", nil, 2)
                    
                    if (k2.Background) then
                        k2.Background:SetTexture("Interface\\Masks\\SquareMask.BLP")
                        k2.Background:SetColorTexture(.15, .15, .15, 0.90)
                        k2.Background:ClearAllPoints()
                        k2.Background:SetPoint("TOPLEFT", k2, "TOPLEFT")
                        k2.Background:SetPoint("BOTTOMRIGHT", k2, "BOTTOMRIGHT")
                        k2.Background:Show()
                    end

                    if k2.Name then
                        k2.Name:SetFont(option("fontname_currency") or fontName, option("fontsize_currency"), CCS.textoutline)
                        if option("showfontshadow") == true then
                            k2.Name:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                            k2.Name:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                        end	                                                
                        
                        k2.Name:SetTextColor(
                            option("fontcolor_currency")[1] or 1,
                            option("fontcolor_currency")[2] or 1,
                            option("fontcolor_currency")[3] or 1,
                            option("fontcolor_currency")[4] or 1
                        )
                    end
                    
                    if k2.Count then
                        k2.Count:SetFont(option("fontname_currency") or fontName, option("fontsize_currency"), CCS.textoutline)
                        if option("showfontshadow") == true then
                            k2.Count:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                            k2.Count:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                        end	                                                
                        
                        k2.Count:SetTextColor(
                            option("fontcolor_currency")[1] or 1,
                            option("fontcolor_currency")[2] or 1,
                            option("fontcolor_currency")[3] or 1,
                            option("fontcolor_currency")[4] or 1
                        )

                    end

                    
                    if k2.AccountWideIcon then
                        k2.awi = k2.awi or k2:CreateTexture(nil, "OVERLAY", nil, 2)
                        k2.awi:SetSize(23, 23)
                        k2.awi:SetAtlas("warbands-icon", true)
                        k2.awi:SetScale(0.9)
                        k2.awi:ClearAllPoints()
                        k2.awi:SetPoint("TOPLEFT", k2.AccountWideIcon, "TOPLEFT")
                        k2.awi:SetPoint("BOTTOMRIGHT", k2.AccountWideIcon, "BOTTOMRIGHT")
                        if t.elementData.isAccountTransferable then
                            k2.awi:Show()
                        else
                            k2.awi:Hide()
                        end
                    end 
                end
                
            end
    
end

local function CreateTransmogButton()
    -- Create the button
    local btn = CreateFrame("CheckButton", "MyTransmogButton", PaperDollSidebarTabs)
    btn:SetSize(33, 35)

    local last = _G["PaperDollSidebarTab"..1]
    btn:SetPoint("RIGHT", last, "LEFT", -4, 0)

    btn.TabBg = btn:CreateTexture(nil, "BACKGROUND")
    btn.TabBg:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
    btn.TabBg:SetSize(50, 43)
    btn.TabBg:SetPoint("BOTTOMLEFT", -9, -2)
    btn.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.61328125, 0.78125000)

    btn.Icon = btn:CreateTexture(nil, "ARTWORK")
    --btn.Icon:SetAtlas("transmog-icon-ui")
    btn.Icon:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\transmog.png")
    btn.Icon:SetSize(30, 30)
    btn.Icon:SetPoint("CENTER")

    btn.Highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.Highlight:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
    btn.Highlight:SetSize(31, 31)
    btn.Highlight:SetPoint("TOPLEFT", 2, -3)
    btn.Highlight:SetTexCoord(0.01562500, 0.50000000, 0.19531250, 0.31640625)

    btn:SetScript("OnClick", function(self, button)
        if not InCombatLockdown() then
                ToggleFrame(TransmogFrame)
        else
				PlaySound(8959)
				RaidNotice_AddMessage(RaidBossEmoteFrame, format("%s", ERR_AFFECTING_COMBAT), ChatTypeInfo["SYSTEM"])        
        end
    end)

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Transmogrification")
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return btn
end

local function PrepTransmogTab()
    table.insert(PAPERDOLL_SIDEBARS, {
        name = SPLASH_LEGION_NEW_7_2_FEATURE2_TITLE,
        icon = "Interface\\Icons\\inv_helm_cloth_raidpriest_k_01",
        texCoords = {0.01562500, 0.53125000, 0.32421875, 0.46093775},
        disabledTooltip = nil,
        IsActive = function() return true end,
    })

    local index = #PAPERDOLL_SIDEBARS

    local pane = CreateFrame("Frame", "PaperDollTransmogPane", PaperDollFrame)
    pane:SetPoint("TOPLEFT", CharacterFrameInsetRight, "TOPLEFT", 12, -3)
    pane:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight, "BOTTOMRIGHT", -3, 2)
    pane:Hide()
    PaperDollFrame.TransmogPane = pane

    local orig_Get = GetPaperDollSideBarFrame
    function GetPaperDollSideBarFrame(i)
        if i == index then
            return PaperDollFrame.TransmogPane
        end
        return orig_Get(i)
    end

    local tab = CreateFrame("CheckButton", "PaperDollSidebarTab"..index, PaperDollSidebarTabs)
    tab:SetID(index)
    tab:SetSize(33, 35)

    -- Background
    tab.TabBg = tab:CreateTexture(nil, "BACKGROUND")
    tab.TabBg:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
    tab.TabBg:SetSize(50, 43)
    tab.TabBg:SetPoint("BOTTOMLEFT", -9, -2)
    tab.TabBg:SetTexCoord(0.01562500, 0.79687500, 0.61328125, 0.78125000)

    -- Icon
    tab.Icon = tab:CreateTexture(nil, "ARTWORK")
    tab.Icon:SetSize(30.17143, 32)
    tab.Icon:SetPoint("BOTTOM", 1, -2)

    -- Hider
    tab.Hider = tab:CreateTexture(nil, "OVERLAY")
    tab.Hider:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
    tab.Hider:SetSize(34, 19)
    tab.Hider:SetPoint("BOTTOM")
    tab.Hider:SetTexCoord(0.01562500, 0.54687500, 0.11328125, 0.18750000)

    -- Highlight
    tab.Highlight = tab:CreateTexture(nil, "HIGHLIGHT")
    tab.Highlight:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
    tab.Highlight:SetSize(31, 31)
    tab.Highlight:SetPoint("TOPLEFT", 2, -3)
    tab.Highlight:SetTexCoord(0.01562500, 0.50000000, 0.19531250, 0.31640625)

    local data = PAPERDOLL_SIDEBARS[index]
	tab.Icon:SetAtlas("transmog-icon-ui", false)
    tab.disabledTooltip = data.disabledTooltip

    local last = _G["PaperDollSidebarTab"..1]
    tab:SetPoint("RIGHT", last, "LEFT", -4, 0)

	--PaperDollSidebarTabs:SetPoint("LEFT", CharacterFrameInsetRight,"LEFT",0,0)
	--PaperDollSidebarTabs:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight,"TOPRIGHT",0,4)

	--local sbtxoffset = (267 - (index * 33)) / 2
	--PaperDollSidebarTab3:SetPoint("BOTTOMRIGHT", PaperDollSidebarTabs,"BOTTOMRIGHT",-sbtxoffset,0)

    tab:SetScript("OnClick", function(self, button)
		ToggleFrame(TransmogFrame)
    end)

    tab:SetScript("OnEnter", PaperDollFrame_SidebarTab_OnEnter)
    tab:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function CCS.HookSetup()
    if CCS.Hooked then return end

        --== Frame Hooks
    CreateTransmogButton()

    -- This is an insane hack to get around the taint issue for Armory
    if C_AddOns.IsAddOnLoaded("Armory") == true then
        local EXPANDED_WIDTH  = 540  
        local COLLAPSED_WIDTH = 384 
        local CURRENT_STATE   = "collapsed"
        CharacterFrame:SetWidth(EXPANDED_WIDTH)
        if PaperDollSidebarTabs then
        PaperDollSidebarTabs:SetParent(PaperDollFrame)
        PaperDollSidebarTabs:ClearAllPoints()
        PaperDollSidebarTabs:SetPoint("LEFT", CharacterHandsSlot, "RIGHT", 15, -35)
        PaperDollSidebarTabs:SetPoint("BOTTOMRIGHT", CharacterHandsSlot, "TOPRIGHT", 280, 4)
        end
        
        CharacterFrame.Expand = function()
            if CURRENT_STATE == "expanded" then return end
            CURRENT_STATE = "expanded"

            -- show the stats/sidebar pane:
            if CharacterStatsPane then CharacterStatsPane:Show() end
            if PaperDollSidebarTabs then PaperDollSidebarTabs:Show() end

        end

        CharacterFrame.Collapse = function()
            if CURRENT_STATE == "collapsed" then return end
            CURRENT_STATE = "collapsed"

            -- Hide the stats/sidebar pane:
            if CharacterStatsPane then CharacterStatsPane:Hide() end
            if PaperDollSidebarTabs then PaperDollSidebarTabs:Hide() end
        end
    end
    
    if C_AddOns.IsAddOnLoaded("PrettyReps") == false then
        hooksecurefunc(ReputationFrame, "Hide", function() ReputationFrame.ReputationDetailFrame:Hide(); end )
        hooksecurefunc(ReputationFrame.ScrollBox, "Update", ReputationFrame_Update)
        hooksecurefunc(ReputationFrame.ReputationDetailFrame, "Show", ReputationFrame_Update)
        hooksecurefunc(ReputationFrame.ReputationDetailFrame, "Hide", ReputationFrame_Update)
        hooksecurefunc(ReputationFrame, "Show", function() 
                C_Timer.After(0, hookfix)
                InitializeFrameUpdates();
                ReputationFrame_Update()
        end)
    end
    hooksecurefunc(TokenFrame, "Show", function() C_Timer.After(0, hookfix) end)
    hooksecurefunc(TokenFrame.ScrollBox, "Update", function() CurrencyFrame_Update() end)
   
    hooksecurefunc(PaperDollFrame, "Show", function() hookfix(); 

        if C_AddOns.IsAddOnLoaded("Armory") == true then
            CharacterFrame.Expand() 
        end
    end)
    hooksecurefunc(CharacterFrame, "Show", function() 
            InitializeFrameUpdates()
            CCS:FireEvent("CCS_EVENT_CSHOW")
            GameTooltip:Hide()
            CCS.tooltip:Hide()
            C_Timer.After(0, hookfix)
            if _G["CCS_stat_sf"] then _G["CCS_stat_sf"]:SetVerticalScroll(0) end
            CharacterModelScene.ControlFrame:Hide()            
            if C_AddOns.IsAddOnLoaded("NDui") then
                CharacterFrameCloseButton:Hide()
            end
          
        CharacterFrameTab1.Text:SetTextColor(1,1,1,1)
        CharacterFrameTab2.Text:SetTextColor(1,1,1,1)
        CharacterFrameTab3.Text:SetTextColor(1,1,1,1)

        CharacterFrameTab1.Left:ClearAllPoints()
        CharacterFrameTab1.LeftActive:ClearAllPoints()
        CharacterFrameTab1.LeftHighlight:ClearAllPoints()
        CharacterFrameTab1.Right:ClearAllPoints()
        CharacterFrameTab1.RightActive:ClearAllPoints()
        CharacterFrameTab1.RightHighlight:ClearAllPoints()
        CharacterFrameTab1.Middle:SetPoint("TOPLEFT", CharacterFrameTab1, "TOPLEFT", 0, 0)
        CharacterFrameTab1.Middle:SetPoint("TOPRIGHT", CharacterFrameTab1, "TOPRIGHT", 0, 0)
        CharacterFrameTab1.Middle:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab1.MiddleActive:SetPoint("TOPLEFT", CharacterFrameTab1, 0, 0)
        CharacterFrameTab1.MiddleActive:SetPoint("TOPRIGHT", CharacterFrameTab1, 0, 0)
        CharacterFrameTab1.MiddleActive:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab1.MiddleHighlight:SetPoint("TOPLEFT", CharacterFrameTab1, 0, 0)
        CharacterFrameTab1.MiddleHighlight:SetPoint("TOPRIGHT", CharacterFrameTab1, 0, 0)
        CharacterFrameTab1.MiddleHighlight:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab1.MiddleActive:SetGradient("Vertical", CreateColor(.25, .25, .25, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab1.Middle:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab2.Left:ClearAllPoints()
        CharacterFrameTab2.LeftActive:ClearAllPoints()
        CharacterFrameTab2.LeftHighlight:ClearAllPoints()
        CharacterFrameTab2.Right:ClearAllPoints()
        CharacterFrameTab2.RightActive:ClearAllPoints()
        CharacterFrameTab2.RightHighlight:ClearAllPoints()
        CharacterFrameTab2.Middle:SetPoint("TOPLEFT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.Middle:SetPoint("TOPRIGHT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.Middle:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab2.MiddleActive:SetPoint("TOPLEFT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.MiddleActive:SetPoint("TOPRIGHT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.MiddleActive:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab2.MiddleHighlight:SetPoint("TOPLEFT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.MiddleHighlight:SetPoint("TOPRIGHT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.MiddleHighlight:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray        
        CharacterFrameTab2.MiddleActive:SetGradient("Vertical", CreateColor(.25, .25, .25, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab2.Middle:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab3.Left:ClearAllPoints()
        CharacterFrameTab3.LeftActive:ClearAllPoints()
        CharacterFrameTab3.LeftHighlight:ClearAllPoints()
        CharacterFrameTab3.Right:ClearAllPoints()
        CharacterFrameTab3.RightActive:ClearAllPoints()
        CharacterFrameTab3.RightHighlight:ClearAllPoints()
        CharacterFrameTab3.Middle:SetPoint("TOPLEFT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.Middle:SetPoint("TOPRIGHT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.Middle:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab3.MiddleActive:SetPoint("TOPLEFT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.MiddleActive:SetPoint("TOPRIGHT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.MiddleActive:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab3.MiddleHighlight:SetPoint("TOPLEFT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.MiddleHighlight:SetPoint("TOPRIGHT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.MiddleHighlight:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab3.MiddleActive:SetGradient("Vertical", CreateColor(.25, .25, .25, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab3.Middle:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
            
            
            
    end )

    if not PaperDollSidebarTab1._ccsHooked then

        PaperDollSidebarTab1:HookScript("OnClick", function(self, button)
            if C_AddOns.IsAddOnLoaded("Narcissus") then -- Just relocate the mini talent tree so it isn't hidden behind the character frame.
                NarciMiniTalentTree:ClearAllPoints(); 
                NarciMiniTalentTree:SetPoint("TOPLEFT", CharacterFrameBg, "TOPRIGHT", 0, 0)
            end                        
        end)
        PaperDollSidebarTab1._ccsHooked = true
    end

    if not PaperDollSidebarTab2._ccsHooked then
        local TitleManager = PaperDollFrame.TitleManagerPane.ScrollBox.ScrollTarget; 
        
        TitleManager:HookScript("OnUpdate", function() 
                        for i = 1, TitleManager:GetNumChildren() do 
                            local child = select(i, TitleManager:GetChildren()) 
                            if child.BgTop then child.BgTop:Hide() end 
                            if child.BgMiddle then child.BgMiddle:Hide() end 
                            if child.BgBottom then child.BgBottom:Hide() end 
                            if child.text and child.text.GetObjectType and child.text:GetObjectType() == "FontString" then
                                child.text:SetWordWrap(false)
                                child.text:SetFont(option("fontname_titles") or CCS.fontname, option("fontsize_titles") or 10, CCS.textoutline or "")
                            end                             
                        end
                        
                    end)

        PaperDollSidebarTab2:HookScript("OnClick", function(self, button)
            PaperDollFrame.TitleManagerPane:ClearAllPoints()
            PaperDollFrame.TitleManagerPane:SetPoint("TOPLEFT", CharacterFrameInsetRight, "TOPLEFT", 9, -4)
            PaperDollFrame.TitleManagerPane:SetPoint("BOTTOM", CharacterFrameInsetRight, "BOTTOM", 0, 10)
            PaperDollFrame.TitleManagerPane:SetPoint("RIGHT", CharacterFrameBg, "RIGHT", -50, 0)
            PaperDollFrame.TitleManagerPane.ScrollBox:ClearAllPoints()
            PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint("TOPLEFT", CharacterFrameInsetRight, "TOPLEFT", 9, -24)
            PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint("BOTTOM", CharacterFrameInsetRight, "BOTTOM", 0, 10)
            PaperDollFrame.TitleManagerPane.ScrollBox:SetPoint("RIGHT", CharacterFrameBg, "RIGHT", -30, 0)
                        
            TitleManager:SetPoint("RIGHT", CharacterFrameBg, "RIGHT", -24, 0)
            
            for i = 1, TitleManager:GetNumChildren() do 
                local child = select(i, TitleManager:GetChildren()) 
                if child.BgTop then child.BgTop:SetPoint("RIGHT", TitleManager, "RIGHT") child.BgTop:Hide() end 
                if child.BgMiddle then child.BgMiddle:SetPoint("RIGHT", TitleManager, "RIGHT") child.BgMiddle:Hide() end 
                if child.BgBottom then child.BgBottom:SetPoint("RIGHT", TitleManager, "RIGHT") child.BgBottom:Hide() end 
                
                if child and not child._ccsHooked and child:GetObjectType() == "Button" then
                    child:HookScript("OnClick", function()
                        local lastTitleID = GetCurrentTitle()
                        C_Timer.NewTicker(0.1, function(ticker)
                            local currentTitleID = GetCurrentTitle()
                            if currentTitleID ~= lastTitleID then
                                PaperDollTitlesPane_Update()
                                ticker:Cancel()
                            end
                        end)
                    end)
                    child._ccsHooked = true
                end
            end
            
            if C_AddOns.IsAddOnLoaded("Narcissus") then -- Just relocate the mini talent tree so it isn't hidden behind the character frame.
                NarciMiniTalentTree:ClearAllPoints(); 
                NarciMiniTalentTree:SetPoint("TOPLEFT", CharacterFrameBg, "TOPRIGHT", 0, 0)
            end                        
        end)
        PaperDollSidebarTab2._ccsHooked = true
    end

    if not PaperDollSidebarTab3._ccsHooked then
        local EquipmentManager = PaperDollFrame.EquipmentManagerPane.ScrollBox.ScrollTarget; 

        PaperDollSidebarTab3:HookScript("OnClick", function(self, button)
            PaperDollFrame.EquipmentManagerPane:ClearAllPoints()
            PaperDollFrame.EquipmentManagerPane:SetPoint("TOPLEFT", CharacterFrameInsetRight, "TOPLEFT", 9, -40)
            PaperDollFrame.EquipmentManagerPane:SetPoint("BOTTOM", CharacterFrameInsetRight, "BOTTOM", 0, 10)
            PaperDollFrame.EquipmentManagerPane:SetPoint("RIGHT", CharacterFrameBg, "RIGHT")
            PaperDollFrame.EquipmentManagerPane.ScrollBox:ClearAllPoints()
            PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint("TOPLEFT", PaperDollFrameEquipSet, "BOTTOMLEFT", -5, -4)
            PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint("BOTTOM", CharacterFrameInsetRight, "BOTTOM", 0, 10)
            PaperDollFrame.EquipmentManagerPane.ScrollBox:SetPoint("RIGHT", CharacterFrameBg, "RIGHT", -30, 0)
            EquipmentManager:SetPoint("RIGHT", CharacterFrameBg, "RIGHT", -24, 0)
        
            PaperDollFrameEquipSet:SetPoint("TOPLEFT", PaperDollFrame.EquipmentManagerPane, "TOPLEFT", 20, 0)
        
            for i = 1, EquipmentManager:GetNumChildren() do 
                local child = select(i, EquipmentManager:GetChildren()) 
                if child.BgTop then child.BgTop:SetPoint("RIGHT", EquipmentManager, "RIGHT") end -- child.BgTop:Hide() end 
                if child.BgMiddle then child.BgMiddle:SetPoint("RIGHT", EquipmentManager, "RIGHT") end --child.BgMiddle:Hide() end 
                if child.BgBottom then child.BgBottom:SetPoint("RIGHT", EquipmentManager, "RIGHT") end --child.BgBottom:Hide() end 
            end

            if C_AddOns.IsAddOnLoaded("Narcissus") then -- Just relocate the mini talent tree so it isn't hidden behind the character frame.
                NarciMiniTalentTree:ClearAllPoints(); 
                NarciMiniTalentTree:SetPoint("TOPLEFT", CharacterFrameBg, "TOPRIGHT", 0, 0)
            end            

            
            
        end)
        PaperDollSidebarTab3._ccsHooked = true
    end
    
    hooksecurefunc(CharacterFrame, "Hide", function() 
        GameTooltip:Hide(); 
        CCS.tooltip:Hide(); 
        StopBGAnimation();
        end )
    CCS.Hooked = true
end

-- Module Initialization
function module:Initialize()
    -- Set up the character sheet for the current player

    if InCombatLockdown() then 
        CCS.initall = true
        return 
    end

    local scaling = option("sheetscale") or 1
    local Bgoffset = option("hpad")

    --CCS_CreateCharacterFrameProxy() -- Create our new proxy frame
    LootSpecInit()
    SpecChangeInit()
    
    CharacterFrame:SetHeight(479+(7*option("vpad"))) -- Do not allow the frame to get any smaller than the default bliz frame
    
    CharacterFrameInset.Bg:ClearAllPoints();
    CharacterFrameInset.Bg:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 4, -60)
    CharacterFrameInset.Bg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 330+option("hpad"), 30)
    CharacterFrameInset:Hide();
    
    CharacterFrameBg:SetVertexColor(0,0,0,0);
    
    CharacterFrameBg:ClearAllPoints()
    CharacterFrameBg:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 0, 0);

    if C_AddOns.IsAddOnLoaded("DejaCharacterStats") then
        CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT",Bgoffset, 0); 
        DCS_configButton:SetPoint("BOTTOMRIGHT", CharacterFrameCloseButton, "BOTTOMLEFT", -20, -10)
        CharacterStatsPane:SetPoint("TOPLEFT", CharacterFrameInsetRight, "TOPLEFT", 13, -3)
        PaperDollSidebarTabs:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight, "TOPRIGHT", -70, -1)
    else
        CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", Bgoffset+65, 0); --279  .449
    end    
    
    CharacterFrame.Background:ClearAllPoints()
    CharacterFrame.Background:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 0, 0);
    CharacterFrame.Background:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", Bgoffset+50, 0); --275  .449
    CharacterFrame.Background:Hide()
    
    CharacterFrame.TopTileStreaks:Hide()
    ReputationFrame.ReputationDetailFrame:SetFrameStrata("HIGH")
    ReputationFrame.ReputationDetailFrame:SetFrameLevel(1000)
    ReputationFrame.ReputationDetailFrame.Border.Bg:SetColorTexture(0,0,0,1)
    
    local charbg = _G["CharacterFrameBgbg"] or CreateFrame("Frame", "CharacterFrameBgbg", CharacterFrame, BackdropTemplateMixin and "BackdropTemplate")
    local charbgtex = _G["CharacterFrameBgbgtex"] or charbg:CreateTexture("CharacterFrameBgbgtex", "BACKGROUND", nil, 1)    
    local bgr, bgg, bgb, bgalpha = option("bgcolor")[1], option("bgcolor")[2], option("bgcolor")[3], option("bgcolor")[4];
    
    charbg:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- optional background texture
        edgeFile = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\UI-Tooltip-SquareBorder.blp",        -- thin edge texture
        edgeSize = 16,                                              -- thickness of the border
        insets = { left = 3, right = 3, top = 3, bottom = 3 },      -- inset so content doesn't overlap border
    })
    local borderColor = CCS.StyleColor.border
    charbg:SetBackdropBorderColor(unpack(borderColor))   -- purple border    
    charbg:SetBackdropColor(bgr,bgg,bgb,bgalpha)   -- purple border    
    
    GearManagerPopupFrame:SetFrameStrata("DIALOG")
    GearManagerPopupFrame.IconSelector:SetFrameStrata("FULLSCREEN")
    
    charbg:ClearAllPoints()
    charbg:SetAllPoints(CharacterFrameBg)
    charbg:SetFrameStrata("BACKGROUND")
    charbg:SetFrameLevel(0)    
    charbgtex:ClearAllPoints()
    charbgtex:SetAllPoints()
    charbgtex:SetTexture("Interface\\Masks\\SquareMask.BLP")
    charbgtex:SetVertexColor(bgr,bgg,bgb,bgalpha);

    CharacterFrameCloseButton:ClearAllPoints();
    CharacterFrameCloseButton:SetPoint("TOPRIGHT", CharacterFrameBg, "TOPRIGHT", -10, -10)
    CharacterFrameCloseButton:SetSize(32, 32)
    CharacterFrameCloseButton:SetSize(32, 32)
    CCS:SkinBlizzardButton(CharacterFrameCloseButton, "x", 26)
    CharacterFrameCloseButton:SetScale(.5)
    
    local CCSsetbtn = _G["CCSsetbtn"] or CreateFrame("Button", "CCSsetbtn", CharacterFrame)
    CCSsetbtn:SetSize(32, 32)
    CCSsetbtn:SetPoint("TOPRIGHT", CharacterFrameCloseButton, "TOPLEFT", -5, 0)
    CCSsetbtn:SetScale(.5)
    CCSsetbtn:Show()
    local optionsFrame = _G["CCS_Options"]
    CCSsetbtn:SetScript("OnClick", function()
        if InCombatLockdown() then
            PlaySound(8959)
            RaidNotice_AddMessage(RaidBossEmoteFrame, format("CCS %s", ERR_AFFECTING_COMBAT), ChatTypeInfo["SYSTEM"])
            return
        end
        if optionsFrame then
            if optionsFrame:IsShown() then
                optionsFrame:Hide()
            else
                optionsFrame:Show()
                optionsFrame:SetPropagateKeyboardInput(true)
            end
        end
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    end)
   CCS:ApplyIconStyle(CCSsetbtn, "gear", 32)
   
    CharacterModelScene.GearEnchantAnimation:ClearAllPoints()
    CharacterFrameTitleText:ClearAllPoints();
    CharacterFrameTitleText:SetPoint("TOP", CharacterFrame, "TOP", 0, -5)
    CharacterFrameTitleText:SetPoint("LEFT", CharacterFrame, "LEFT", 50, 0)
    CharacterFrameTitleText:SetPoint("RIGHT", CharacterFrameInset.Bg, "RIGHT", -40, 0)
    CharacterFrameTitleText:SetFont( option("fontname_nametitle") or CCS.fontname, (option("fontsize_nametitle") or 12) , CCS.textoutline)
    if option("showfontshadow") == true then
        CharacterFrameTitleText:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
        CharacterFrameTitleText:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
    end	                                                
    
    CharacterFrameTitleText:SetTextColor(
        option("fontcolor_nametitle")[1] or 1,
        option("fontcolor_nametitle")[2] or 1,
        option("fontcolor_nametitle")[3] or 1,
        option("fontcolor_nametitle")[4] or 1
    )

    CharacterLevelText:ClearAllPoints()
    CharacterLevelText:SetPoint("TOP", CharacterFrameTitleText, "BOTTOM", 0, 0)
    CharacterLevelText:SetFont(option("fontname_levelclass") or CCS.fontname, (option("fontsize_levelclass") or 12) , CCS.textoutline)
    if option("showfontshadow") == true then
        CharacterLevelText:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
        CharacterLevelText:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
    end	                                                
    
    CharacterFrame.NineSlice:Hide()
    CharacterFramePortrait:Hide()
    
    CharacterFrameInsetRight.Bg:Hide();
    CharacterFrameInsetRight:ClearAllPoints();
    CharacterFrameInsetRight:SetPoint("TOPLEFT", CharacterFrameInset.Bg, "TOPRIGHT", 4, 0)
    CharacterFrameInsetRight:SetPoint("BOTTOMRIGHT", CharacterFrameInset.Bg, "BOTTOMRIGHT", 250, 0)
	CharacterFrameInsetRight:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", -4, 0)    
    CharacterStatsPane.ClassBackground:Hide()
    
	PaperDollSidebarTabs:SetPoint("LEFT", CharacterFrameInsetRight,"LEFT",0,0)
	PaperDollSidebarTabs:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight,"TOPRIGHT",0,4)

	local sbtxoffset = (267 - ((#PAPERDOLL_SIDEBARS+1) * 33)) / 2
	PaperDollSidebarTab3:SetPoint("BOTTOMRIGHT", PaperDollSidebarTabs,"BOTTOMRIGHT",-sbtxoffset,0)    
    
    PaperDollFrame:UnregisterAllEvents()
    PaperDollInnerBorderBottom:Hide()
    PaperDollInnerBorderBottom2:Hide()
    PaperDollInnerBorderBottomLeft:Hide()
    PaperDollInnerBorderBottomRight:Hide()
    PaperDollInnerBorderLeft:Hide()
    PaperDollInnerBorderRight:Hide()
    PaperDollInnerBorderTop:Hide()
    PaperDollInnerBorderTopLeft:Hide()
    PaperDollInnerBorderTopRight:Hide()
    CharacterFrameInsetRight.NineSlice:Hide()
    
    CharacterBackSlotFrame:Hide()
    CharacterChestSlotFrame:Hide()
    CharacterFeetSlotFrame:Hide()
    CharacterFinger0SlotFrame:Hide()
    CharacterFinger1SlotFrame:Hide()
    CharacterHandsSlotFrame:Hide()
    CharacterHeadSlotFrame:Hide()
    CharacterLegsSlotFrame:Hide()
    CharacterMainHandSlotFrame:Hide()
    CharacterNeckSlotFrame:Hide()
    CharacterSecondaryHandSlotFrame:Hide()
    CharacterShirtSlotFrame:Hide()
    CharacterShoulderSlotFrame:Hide()
    CharacterTabardSlotFrame:Hide()
    CharacterTrinket0SlotFrame:Hide()
    CharacterTrinket1SlotFrame:Hide()
    CharacterWaistSlotFrame:Hide()
    CharacterWristSlotFrame:Hide()
    -- All slots on the left (under head) are tied back to this slot
    CharacterHeadSlot:ClearAllPoints()
    CharacterHeadSlot:SetPoint("TOPLEFT", CharacterFrameBg, "TOPLEFT", 30, -60)
    CharacterNeckSlot:ClearAllPoints()
    CharacterNeckSlot:SetPoint("TOPLEFT", CharacterHeadSlot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterShoulderSlot:ClearAllPoints()
    CharacterShoulderSlot:SetPoint("TOPLEFT", CharacterNeckSlot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterBackSlot:ClearAllPoints()
    CharacterBackSlot:SetPoint("TOPLEFT", CharacterShoulderSlot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterChestSlot:ClearAllPoints()
    CharacterChestSlot:SetPoint("TOPLEFT", CharacterBackSlot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterShirtSlot:ClearAllPoints()
    CharacterShirtSlot:SetPoint("TOPLEFT", CharacterChestSlot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterTabardSlot:ClearAllPoints()
    CharacterTabardSlot:SetPoint("TOPLEFT", CharacterShirtSlot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterWristSlot:ClearAllPoints()
    CharacterWristSlot:SetPoint("TOPLEFT", CharacterTabardSlot, "BOTTOMLEFT", 0, -option("vpad"))
    -- All slots on the right (under hands) are tied back to this slot
    CharacterHandsSlot:ClearAllPoints()
    CharacterHandsSlot:SetPoint("TOPLEFT", CharacterFrameBg, "TOPLEFT", 283 + option("hpad"), -60)
    CharacterWaistSlot:ClearAllPoints()
    CharacterWaistSlot:SetPoint("TOPLEFT", CharacterHandsSlot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterLegsSlot:ClearAllPoints()
    CharacterLegsSlot:SetPoint("TOPLEFT", CharacterWaistSlot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterFeetSlot:ClearAllPoints()
    CharacterFeetSlot:SetPoint("TOPLEFT", CharacterLegsSlot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterFinger0Slot:ClearAllPoints()
    CharacterFinger0Slot:SetPoint("TOPLEFT", CharacterFeetSlot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterFinger1Slot:ClearAllPoints()
    CharacterFinger1Slot:SetPoint("TOPLEFT", CharacterFinger0Slot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterTrinket0Slot:ClearAllPoints()
    CharacterTrinket0Slot:SetPoint("TOPLEFT", CharacterFinger1Slot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterTrinket1Slot:ClearAllPoints()
    CharacterTrinket1Slot:SetPoint("TOPLEFT", CharacterTrinket0Slot, "BOTTOMLEFT", 0, -option("vpad"))
    CharacterMainHandSlot:ClearAllPoints()
    CharacterMainHandSlot:SetPoint("BOTTOMLEFT", CharacterFrameBg, "BOTTOMLEFT", 146 + 89*option("hpad")/262, 60)
    CharacterSecondaryHandSlot:ClearAllPoints()
    CharacterSecondaryHandSlot:SetPoint("TOPLEFT", CharacterMainHandSlot, "TOPRIGHT", 60*option("hpad")/262, 0)
    select(16, CharacterMainHandSlot:GetRegions()):SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
    select(17, CharacterMainHandSlot:GetRegions()):SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)    
    select(16, CharacterSecondaryHandSlot:GetRegions()):SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
    select(17, CharacterSecondaryHandSlot:GetRegions()):SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)    
    if (option("hideiconborders")) then
        CharacterBackSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterBackSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterChestSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterFeetSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterFinger0Slot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterFinger1Slot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterHandsSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterHeadSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterLegsSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterMainHandSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterNeckSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterSecondaryHandSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterShirtSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterShoulderSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterTabardSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterTrinket0Slot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterTrinket1Slot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterWaistSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        CharacterWristSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        
        CharacterBackSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterChestSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterFeetSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterFinger0SlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterFinger1SlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterHandsSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterHeadSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterLegsSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterMainHandSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterNeckSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterSecondaryHandSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterShirtSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterShoulderSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterTabardSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterTrinket0SlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterTrinket1SlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterWaistSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        CharacterWristSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
        
        CharacterBackSlotNormalTexture:Hide()
        CharacterChestSlotNormalTexture:Hide()
        CharacterFeetSlotNormalTexture:Hide()
        CharacterFinger0SlotNormalTexture:Hide()
        CharacterFinger1SlotNormalTexture:Hide()
        CharacterHandsSlotNormalTexture:Hide()
        CharacterHeadSlotNormalTexture:Hide()
        CharacterLegsSlotNormalTexture:Hide()
        CharacterMainHandSlotNormalTexture:Hide()
        CharacterNeckSlotNormalTexture:Hide()
        CharacterSecondaryHandSlotNormalTexture:Hide()
        CharacterShirtSlotNormalTexture:Hide()
        CharacterShoulderSlotNormalTexture:Hide()
        CharacterTabardSlotNormalTexture:Hide()
        CharacterTrinket0SlotNormalTexture:Hide()
        CharacterTrinket1SlotNormalTexture:Hide()
        CharacterWaistSlotNormalTexture:Hide()
        CharacterWristSlotNormalTexture:Hide()
        
    else
        CharacterBackSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterBackSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterChestSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterFeetSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterFinger0Slot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterFinger1Slot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterHandsSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterHeadSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterLegsSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterMainHandSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterNeckSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterSecondaryHandSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterShirtSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterShoulderSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterTabardSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterTrinket0Slot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterTrinket1Slot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterWaistSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        CharacterWristSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        
        CharacterBackSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterChestSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterFeetSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterFinger0SlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterFinger1SlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterHandsSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterHeadSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterLegsSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterMainHandSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterNeckSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterSecondaryHandSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterShirtSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterShoulderSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterTabardSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterTrinket0SlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterTrinket1SlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterWaistSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        CharacterWristSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
        
        CharacterBackSlotNormalTexture:Show()
        CharacterChestSlotNormalTexture:Show()
        CharacterFeetSlotNormalTexture:Show()
        CharacterFinger0SlotNormalTexture:Show()
        CharacterFinger1SlotNormalTexture:Show()
        CharacterHandsSlotNormalTexture:Show()
        CharacterHeadSlotNormalTexture:Show()
        CharacterLegsSlotNormalTexture:Show()
        CharacterMainHandSlotNormalTexture:Show()
        CharacterNeckSlotNormalTexture:Show()
        CharacterSecondaryHandSlotNormalTexture:Show()
        CharacterShirtSlotNormalTexture:Show()
        CharacterShoulderSlotNormalTexture:Show()
        CharacterTabardSlotNormalTexture:Show()
        CharacterTrinket0SlotNormalTexture:Show()
        CharacterTrinket1SlotNormalTexture:Show()
        CharacterWaistSlotNormalTexture:Show()
        CharacterWristSlotNormalTexture:Show()
          
    end
        CharacterFrameTab1.Text:SetTextColor(1,1,1,1)
        CharacterFrameTab2.Text:SetTextColor(1,1,1,1)
        CharacterFrameTab3.Text:SetTextColor(1,1,1,1)

        CharacterFrameTab1:SetPoint("TOPLEFT", CharacterFrame, "BOTTOMLEFT", 11, 2)
        CharacterFrameTab1.Left:ClearAllPoints()
        CharacterFrameTab1.LeftActive:ClearAllPoints()
        CharacterFrameTab1.LeftHighlight:ClearAllPoints()
        CharacterFrameTab1.Right:ClearAllPoints()
        CharacterFrameTab1.RightActive:ClearAllPoints()
        CharacterFrameTab1.RightHighlight:ClearAllPoints()
        CharacterFrameTab1.Middle:SetPoint("TOPLEFT", CharacterFrameTab1, "TOPLEFT", 0, 0)
        CharacterFrameTab1.Middle:SetPoint("TOPRIGHT", CharacterFrameTab1, "TOPRIGHT", 0, 0)
        CharacterFrameTab1.Middle:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab1.MiddleActive:SetPoint("TOPLEFT", CharacterFrameTab1, 0, 0)
        CharacterFrameTab1.MiddleActive:SetPoint("TOPRIGHT", CharacterFrameTab1, 0, 0)
        CharacterFrameTab1.MiddleActive:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab1.MiddleHighlight:SetPoint("TOPLEFT", CharacterFrameTab1, 0, 0)
        CharacterFrameTab1.MiddleHighlight:SetPoint("TOPRIGHT", CharacterFrameTab1, 0, 0)
        CharacterFrameTab1.MiddleHighlight:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab1.MiddleActive:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab1.Middle:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray

        CharacterFrameTab2:SetPoint("TOPLEFT", CharacterFrameTab1, "TOPRIGHT", 3, 0)
        CharacterFrameTab2.Left:ClearAllPoints()
        CharacterFrameTab2.LeftActive:ClearAllPoints()
        CharacterFrameTab2.LeftHighlight:ClearAllPoints()
        CharacterFrameTab2.Right:ClearAllPoints()
        CharacterFrameTab2.RightActive:ClearAllPoints()
        CharacterFrameTab2.RightHighlight:ClearAllPoints()
        CharacterFrameTab2.Middle:SetPoint("TOPLEFT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.Middle:SetPoint("TOPRIGHT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.Middle:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab2.MiddleActive:SetPoint("TOPLEFT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.MiddleActive:SetPoint("TOPRIGHT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.MiddleActive:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab2.MiddleHighlight:SetPoint("TOPLEFT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.MiddleHighlight:SetPoint("TOPRIGHT", CharacterFrameTab2, 0, 0)
        CharacterFrameTab2.MiddleHighlight:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray        
        CharacterFrameTab2.MiddleActive:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab2.Middle:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray

        CharacterFrameTab3:SetPoint("TOPLEFT", CharacterFrameTab2, "TOPRIGHT", 3, 0)
        CharacterFrameTab3.Left:ClearAllPoints()
        CharacterFrameTab3.LeftActive:ClearAllPoints()
        CharacterFrameTab3.LeftHighlight:ClearAllPoints()
        CharacterFrameTab3.Right:ClearAllPoints()
        CharacterFrameTab3.RightActive:ClearAllPoints()
        CharacterFrameTab3.RightHighlight:ClearAllPoints()
        CharacterFrameTab3.Middle:SetPoint("TOPLEFT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.Middle:SetPoint("TOPRIGHT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.Middle:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab3.MiddleActive:SetPoint("TOPLEFT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.MiddleActive:SetPoint("TOPRIGHT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.MiddleActive:SetTexture("Interface\\Masks\\SquareMask.BLP")
        CharacterFrameTab3.MiddleHighlight:SetPoint("TOPLEFT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.MiddleHighlight:SetPoint("TOPRIGHT", CharacterFrameTab3, 0, 0)
        CharacterFrameTab3.MiddleHighlight:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab3.MiddleActive:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
        CharacterFrameTab3.Middle:SetGradient("Vertical", CreateColor(0, 0, 0, 1), CreateColor(0, 0, 0, 1)) -- Dark Gray
     
    PaperDollFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 0)
    
    -- [Toast] Create Base Frame
    local toast = _G["CCS_TOAST"] or CreateFrame("FRAME","CCS_TOAST",UIParent)
    toast:SetPoint("TOP",UIParent,"TOP",0,-160)
    toast:SetWidth(302)
    toast:SetHeight(70)
    toast:SetMovable(true)
    toast:SetUserPlaced(false)
    toast:SetClampedToScreen(true)
    toast:RegisterForDrag("LeftButton")
    toast:SetScript("OnDragStart",toast.StartMoving)
    toast:SetScript("OnDragStop",toast.StopMovingOrSizing)
    toast:Hide()
    toast.texture = toast:CreateTexture(nil,"BACKGROUND")
    toast.texture:SetPoint("TOPLEFT",toast,"TOPLEFT",-6,4)
    toast.texture:SetPoint("BOTTOMRIGHT",toast,"BOTTOMRIGHT",4,-4)
    toast.texture:SetTexture("Interface\\Garrison\\GarrisonToast")
    toast.texture:SetTexCoord(0,.61,.33,.48)
    toast.title = _G["CCS_TOASTfs1"] or toast:CreateFontString("CCS_TOASTfs1")
    toast.title:SetPoint("TOPLEFT",toast,"TOPLEFT",23,-10)
    toast.title:SetWidth(260)
    toast.title:SetHeight(16)
    toast.title:SetJustifyV("TOP")
    toast.title:SetJustifyH("LEFT")
    toast.title:SetFont(CCS.fontname, 12, CCS.textoutline)
    toast.title:Show()
    toast.description = _G["CCS_TOASTfs2"] or toast:CreateFontString("CCS_TOASTfs2")
    toast.description:SetPoint("TOPLEFT",toast.title,"TOPLEFT",1,-23)
    toast.description:SetWidth(258)
    toast.description:SetHeight(32)
    toast.description:SetJustifyV("TOP")
    toast.description:SetJustifyH("LEFT")
    toast.description:SetFont(CCS.fontname, 12, CCS.textoutline)
    toast.description:Show()
    
    if scaling ~= 1 or (scaling == 1 and CharacterFrame:GetScale() ~= 1) then
        CharacterFrame:SetScale(scaling); 
    end
    
    ReputationFrame:SetScale(scaling);
    ReputationFrame:ClearAllPoints()
    ReputationFrame:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 0, 0)
    ReputationFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 7)
    ReputationFrame.ScrollBox:ClearAllPoints()
    ReputationFrame.ScrollBox:SetPoint("TOPLEFT", CharacterFrameInset, "TOPLEFT", 4, -4)
    ReputationFrame.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", -30, 7)
    ReputationFrame.filterDropdown:ClearAllPoints()
    ReputationFrame.filterDropdown:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", -38, -30)    
    
    if ccs_sf then ccs_sf:SetScale(.69); end
    
    -- Create the character model button
    modelbtn:SetSize(23, 23)
    modelbtn:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", -100, 7)
    modelbtn:SetFrameStrata("HIGH")
    
    if option("hideshowchbtn") == true then
        modelbtn:Hide()
    else
        modelbtn:Show()
    end
    
    local modelbtnfont1 = _G["CCS_clk_Btnfs1"] or modelbtn:CreateFontString("CCS_clk_Btnfs1")
    
    modelbtnfont1:SetPoint("BOTTOM", modelbtn, "TOP", -3 , 2)
    modelbtnfont1:SetFont(option("fontname_showchar") or CCS.fontname, (option("fontsize_showchar") or 10), CCS.textoutline)
    if option("showfontshadow") == true then
        modelbtnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
        modelbtnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
    end	                                                
    
    modelbtnfont1:SetTextColor(
        option("fontcolor_showchar")[1] or 1,
        option("fontcolor_showchar")[2] or 1,
        option("fontcolor_showchar")[3] or 1,
        option("fontcolor_showchar")[4] or 1
    )
    
    modelbtnfont1:SetText(MOUNT_JOURNAL_PLAYER)
    modelbtnfont1:SetWordWrap(true)
    modelbtn:SetNormalTexture("Interface\\Calendar\\MeetingIcon.blp")
    modelbtn:SetScript("OnEnter", function(self) CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT")
            CCS.tooltip:AddDoubleLine("", nil, 1, 1, 1, 1, 1, 1) 
            CCS.tooltip:Show()
    end)
    modelbtn:SetScript("OnLeave", function() CCS.tooltip:Hide() end)
    modelbtn:SetScript("OnClick", function()
            if not InCombatLockdown() then 
                Clicky() 
            else
                PlaySound(8959)
                RaidNotice_AddMessage(RaidBossEmoteFrame, format("%s", ERR_AFFECTING_COMBAT), ChatTypeInfo["SYSTEM"])
            end 
    end)

    modbg:ClearAllPoints()
    modbg:SetPoint("TOPLEFT", CharacterHeadSlot, "TOPLEFT", 0, 0)
    modbg:SetPoint("RIGHT", CharacterHandsSlot, "RIGHT", 0, 0)    
    modbg:SetPoint("BOTTOM", CharacterMainHandSlot, "BOTTOM", 0, 0)        
    modbg:SetFrameStrata("LOW")
    modbg:SetFrameLevel(5000)
    
    if option("hidemodelbg") then
        modbg:Hide()
    else
        modbg:Show()
    end
    
    local Height = 520  -- Hard code it for now
    local Left = 120  -- Hard code it for now
    
    CharacterModelScene:ClearAllPoints();
    CharacterModelScene:SetHeight(Height)
    CharacterModelScene:SetWidth(Height/CCS.ModelAspect)
    CharacterModelScene:SetPoint("LEFT", CharacterFrameBg, "LEFT", Left, -20);
    CharacterModelScene:SetFrameStrata("Medium")
    CharacterModelScene:SetFrameLevel(9000)
    CharacterModelScene:Show();
    CharacterModelFrameBackgroundTopLeft:Hide();
    CharacterModelFrameBackgroundBotLeft:Hide();
    CharacterModelFrameBackgroundTopRight:Hide();
    CharacterModelFrameBackgroundBotRight:Hide();
    CharacterModelFrameBackgroundOverlay:ClearAllPoints()
    CharacterModelFrameBackgroundOverlay:SetPoint("TOPLEFT", CharacterModelFrameBackgroundTopLeft, "TOPLEFT", 0, 0)
    CharacterModelFrameBackgroundOverlay:SetPoint("BOTTOMRIGHT", CharacterModelFrameBackgroundBotRight, "BOTTOMRIGHT", 0, 70)
    CharacterModelFrameBackgroundOverlay:Hide()
    
    TokenFramePopup:SetFrameStrata("HIGH")
    TokenFramePopup.Border.Bg:SetColorTexture(0, 0, 0, 1)
    CurrencyTransferLog:SetFrameStrata("HIGH")
    --TokenFrame:SetScale(scaling); 
    if not TokenFrame.CCS_Init and not TokenFrame:IsProtected() then
        TokenFrame:ClearAllPoints()
        TokenFrame:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 0, 0)
        TokenFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 0)
        TokenFrame.ScrollBox:ClearAllPoints()
        TokenFrame.ScrollBox:SetPoint("TOPLEFT", CharacterFrameInset, "TOPLEFT", 4, -4)
        TokenFrame.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", -30, 26)    -- 325, 26
        TokenFrame.CCS_Init = true
    end
    
    if C_AddOns.IsAddOnLoaded("Pawn") then
        PawnUI_InventoryPawnButton:ClearAllPoints()
        PawnUI_InventoryPawnButton:SetPoint("BOTTOMRIGHT", CharacterFrameInset.Bg, "BOTTOMRIGHT", 0, -55)
    end
 
    if not _G["ccs_sf"] then 
        
        if not _G["CCSf"] then CreateFrame("Frame", "CCSf", CharacterFrame) end
        local ccsf_af = _G["ccsf_af"] or CreateFrame("Frame", "ccsf_af", CharacterFrame, "SecureHandlerBaseTemplate");
        
        ccsf_af:ClearAllPoints()
        ccsf_af:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT",  option("hpad")+63, 0);
        CCSf:ClearAllPoints(); 
        CCSf:SetPoint("TOPLEFT", ccsf_af, "TOPRIGHT", 0, 0); 
        CCSf:SetSize(900, 640)
        CCSf:Hide()
        
        --CharacterFrameCloseButton:SetScale(.7)
        
        local sf = _G["ccs_sf"] or CreateFrame("Frame", "ccs_sf", CharacterFrame);
        local sf_bg = _G["ccs_sf_bg"] or sf:CreateTexture("ccs_sf_bg", "BACKGROUND", nil, 1)        
        local sf_topbar = _G["ccs_sf_tb"] or sf:CreateTexture("ccs_sf_tb", "BACKGROUND", nil, 2)
        local sf_topstreaks = _G["ccs_sf_ts"] or sf:CreateTexture("ccs_sf_ts", "BACKGROUND", nil, 2)
        local sf_bottombar = _G["ccs_sf_bb"] or sf:CreateTexture("ccs_sf_bb", "BACKGROUND", nil, 2)
        
        sf:SetScale(.69)
        sf_bg:Show()
    end
    CCS.HookSetup()
    
end

-- Show the Paragon Toast if a Paragon Reward Quest is accepted.
local function ShowToast(name, text)
    local toast = _G["CCS_TOAST"]

    PlaySound(44295, "master", true)

    -- Reset frame state
    toast:Hide()
    toast:SetAlpha(0)
    toast.title:SetAlpha(0)
    toast.description:SetAlpha(0)

    toast:EnableMouse(false)
    toast.title:SetText(name)
    toast.description:SetText(text)

    -- Animate toast and text
    C_Timer.After(1, function() UIFrameFadeIn(toast, .5, 0, 1) end)
    C_Timer.After(2, function() UIFrameFadeIn(toast.title, .5, 0, 1) end)
    C_Timer.After(2, function() UIFrameFadeIn(toast.description, .5, 0, 1) end)
    C_Timer.After(5, function() UIFrameFadeOut(toast, 1, 1, 0) end)
end


-- Define the event handler function for this module
function CCS.CharacterSheetEventHandler(event, ...)
    local arg1 = ...

    if CCS.GetCurrentVersion() ~= CCS.RETAIL then return end
   
    if event == "PLAYER_ENTERING_WORLD" then
            for slot = 1, 19 do
                local link = GetInventoryItemLink("player", slot)
                if link then
                    GetItemInfo(link) -- queues item for caching
                    local itemID = GetInventoryItemID("player", slot)
                    if itemID then
                        C_Item.RequestLoadItemDataByID(itemID) -- nudges client to fetch item data
                    end
                end
            end
            if not CCS.characterUpdatePending then
                CCS.characterUpdatePending = true
                C_Timer.After(0.2, function()
                    CCS.characterUpdatePending = false
                    TryLoopItems()
                end)
            end
        return true
    end    
    if CharacterFrame and not CharacterFrame:IsVisible() 
        and event ~= "PLAYER_LOOT_SPEC_UPDATED" and event ~= "PLAYER_SPECIALIZATION_CHANGED" and event ~= "QUEST_ACCEPTED" and event ~= "CCS_EVENT_CSHOW"
    then return end
    
    PaperDollFrame_SetLevel()
    
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        if arg1 == nil then return false end
        if not CCS.characterUpdatePending then
            CCS.characterUpdatePending = true
            C_Timer.After(0.2, function()
                CCS.characterUpdatePending = false
                TryLoopItems()
            end)
        end
        return true
    elseif event == "CCS_EVENT_OPTIONS" then
        TryLoopItems()
        ChangeModelBg()
        ReputationFrame_Update()
        CurrencyFrame_Update()
        --print(date("%H:%M:%S") .. format(".%03d", (GetTime() * 1000) % 1000), "message")
        return true
    elseif event == "CCS_EVENT_CSHOW" then

        if not CCS.characterUpdatePending then
            CCS.characterUpdatePending = true
            C_Timer.After(0, function()
                CCS.characterUpdatePending = false
                TryLoopItems()
                ccs_cshow()
                ReputationFrame_Update()                
            end)
        end
        return true

    elseif event == "PLAYER_LOOT_SPEC_UPDATED" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        LootSpecInit()
        SpecChangeInit()
        ChangeModelBg()
    elseif event == "QUEST_ACCEPTED" and arg1 and CCS.Paragon_Factions[arg1] and C_Reputation.GetFactionDataByID(CCS.Paragon_Factions[arg1].factionID) then
        local name = C_Reputation.GetFactionDataByID(CCS.Paragon_Factions[arg1].factionID).name
        local text = GetQuestLogCompletionText(C_QuestLog.GetLogIndexForQuestID(arg1))
        ShowToast(name, text)
    else 
        if not CCS.characterUpdatePending then
            CCS.characterUpdatePending = true
            C_Timer.After(0.2, function()
                CCS.characterUpdatePending = false
                TryLoopItems()
                --loopitems()
            end)
        end
        return true
    end
end
