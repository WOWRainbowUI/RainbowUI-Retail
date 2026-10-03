local addonName, ns = ...
local CCS = ns.CCS

if CCS.CurrentVersion ~= CCS.FOREVER then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table

local module = {
    Name = "CCSForeverModule",
    CompatibleVersions = { CCS.FOREVER },
}
CCS.Modules[module.Name] = module

local rowWidth, rowHeight, rowSpacing = 234, 23, 2
local fontsize = 10
local modbg = _G["CharacterModelFramebg"] or CreateFrame("Frame", "CharacterModelFramebg", CharacterModelScene)
local modtex = _G["CharacterModelFramebgtex"] or modbg:CreateTexture("CharacterModelFramebgtex", "BACKGROUND")    
local modtex2 = _G["CharacterModelFramebgtex2"] or modbg:CreateTexture("CharacterModelFramebgtex2", "ARTWORK")    
local modelbtn = _G["CCS_clk_Btn"] or CreateFrame("Button", "CCS_clk_Btn", PaperDollFrame)
local modelbtnfont1 = _G["CCS_clk_Btnfs1"] or modelbtn:CreateFontString("CCS_clk_Btnfs1")
local ccs_cshow
local function hookfix() 

    if C_AddOns.IsAddOnLoaded("ClassCodex") == true and option("showm_sp_onopen") == true then
        if ClassCodexPanel then ClassCodexPanel:Hide() end
    end

    if not CCS.AreSecretsDisabled() and _G["ccsm_sf"] and (option("showm_sp_onopen") == true) and (UnitLevel("player") == CCS.MaxLevel)then
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
   
    ccs_cshow()

end

local function MoveModelLeft() 
    local Height = 359+(7*option("vpad"))  -- Hard code it for now
    
    if CharacterModelScene:GetHeight() == Height then
    return end
    
    CharacterModelScene:ClearAllPoints();
    CharacterModelScene:SetHeight(Height)
    CharacterModelScene:SetWidth(Height/CCS.ModelAspect)
    CharacterModelScene:SetPoint("CENTER", CharacterFrameInset.Bg, "CENTER", 0, -20);
    CharacterModelScene:SetPoint("TOP", CharacterFrameInset.Bg, "TOP", 0, -5);    
    CharacterModelScene:SetPoint("BOTTOM", CharacterMainHandSlot, "BOTTOM", 0, 3);        
    CharacterModelScene:SetFrameStrata("Medium")
    CharacterModelScene:SetFrameLevel(9000)
    CharacterModelScene:Show();
    
    CharacterModelFrameBackgroundTopLeft:Hide();
    CharacterModelFrameBackgroundBotLeft:Hide();
    CharacterModelFrameBackgroundTopRight:Hide();
    CharacterModelFrameBackgroundBotRight:Hide();
    --CharacterModelFrameBackgroundOverlay:ClearAllPoints()
    --CharacterModelFrameBackgroundOverlay:SetPoint("TOPLEFT", CharacterModelFrameBackgroundTopLeft, "TOPLEFT", 0, 0)
    --CharacterModelFrameBackgroundOverlay:SetPoint("BOTTOMRIGHT", CharacterModelFrameBackgroundBotRight, "BOTTOMRIGHT", 0, 70)
    CharacterModelScene.BackgroundOverlay:Hide()
    
    modbg:ClearAllPoints()
    modbg:SetPoint("TOPLEFT", CharacterHeadSlot, "TOPLEFT", 0, 0)
    modbg:SetPoint("RIGHT", CharacterHandsSlot, "RIGHT", 0, 0)    
    modbg:SetPoint("BOTTOM", CharacterMainHandSlot, "BOTTOM", 0, 0)            

end

local function MoveModelRight() 
    CharacterModelScene:ClearAllPoints();
    CharacterModelScene:SetHeight(CharacterFrameBg:GetHeight());
    CharacterModelScene:SetWidth(CharacterFrameBg:GetHeight()/CCS.ModelAspect);
    CharacterModelScene:SetPoint("LEFT", CharacterFrameBg, "RIGHT", 0, 0);
    CharacterModelScene:SetFrameStrata("Medium")
    CharacterModelScene:SetFrameLevel(9000)
    CharacterModelScene:Show();
    
    _G["CharacterModelFramebg"]:ClearAllPoints()
    _G["CharacterModelFramebg"]:SetAllPoints(CharacterModelScene)    
end

local function CreateAndUpdateiLvlframe(parent)
	local btn = _G["CSPilvl"] or CreateFrame("Button", "CSPilvl", parent)
	local btnfont1
	local btnfontilvl = _G["CSPilvlfs1"] or btn:CreateFontString("CSPilvlfs1")
	local btntex = _G["CSPilvltex"] or btn:CreateTexture("CSPilvltex", "BACKGROUND", nil, 1)
	--local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel();
    local avgItemLevelEquipped = CCS.GetUnitItemLevel("player")
	local Color = "a336ed"
	local tt_name = ""
	local tt_desc = ""

	btn.fontString = btnfontilvl
	btn.texture = btntex
	
	btn:SetParent(parent)
	btn:ClearAllPoints()
	btn:SetSize(rowWidth, rowHeight*(option("fontsize_cilvl") or 20) /20)
	btn:SetPoint("TOP", parent, "BOTTOM", 0, -3)
	btn:SetFrameStrata("HIGH")
	btn.throttle = 0;
	btn:Show()       
	
	btntex:ClearAllPoints()
	btntex:SetAllPoints()
	btntex:SetTexture("Interface\\Masks\\SquareMask.BLP")
	btntex:SetGradient("Vertical", CreateColor(0, 0, 0, .2), CreateColor(.1, .1, .1, .4)) -- Dark Gray
	btnfontilvl:SetPoint("CENTER", btn, "CENTER", 0 ,0)
	btnfontilvl:SetFont(option("fontname_cilvl") or CCS.fontname, (option("fontsize_cilvl") or 20), CCS.textoutline)
	if option("showfontshadow") == true then
		btnfontilvl:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		btnfontilvl:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                
	
	CCS.PreloadEquippedItemInfo("player")
	CCS.WaitForItemInfoReady("player", function()
		local color = CCS:GetAverageEquippedRarityHex("player")
		Color = color

		avgItemLevelEquipped = format("%s", CCS.round(avgItemLevelEquipped))
		--avgItemLevel = format("%s", CCS.round(avgItemLevel))
		--avgItemLevelPvP = format("%s", CCS.round(avgItemLevelPvP))

	if option("show_inbag_ilvl") == true and false then
		btnfontilvl:SetText(format("|cFF%s%s / %s|r", Color, avgItemLevelEquipped, avgItemLevel))
	else
		btnfontilvl:SetText(format("|cFF%s%s|r", Color, avgItemLevelEquipped))            
	end
		--tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..avgItemLevel
		tt_name = tt_name .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, avgItemLevelEquipped)
		tt_name = tt_name .. FONT_COLOR_CODE_CLOSE

		tt_desc = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP
		--tt_desc = tt_desc.."\n\n"..STAT_AVERAGE_PVP_ITEM_LEVEL:format(avgItemLevelPvP)

		btn:SetScript("OnEnter", function(self)
			CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT")
			CCS.tooltip:AddDoubleLine(tt_name, nil, 1, 1, 1, 1, 1, 1)
			CCS.tooltip:AddLine(tt_desc, nil, nil, nil, true)
			CCS.tooltip:Show()
		end)
		btn:SetScript("OnLeave", function() CCS.tooltip:Hide() end)

	end)
	return btn
end

local function BlizStatFrame_Update()
        local stats_children = {CharacterStatsPaneScrollBox.ScrollBox.ScrollTarget:GetChildren()}
        local hcolor = CCS.StyleColor.highlight
        local ncolor = CCS.StyleColor.normal

        CharacterStatsPaneScrollBox.ClassBackground:SetVertexColor(hcolor[1],hcolor[2],hcolor[3],1)

        if false then
            CharacterStatsPaneScrollBox.ScrollBar:Hide()
            CharacterStatsPaneScrollBox.ScrollBox:Hide()
        end
        if CharacterStatsPaneScrollBox.CCS_Hooked == nil then
            CharacterStatsPaneScrollBox.CCS_Hooked = true
        end
        CreateAndUpdateiLvlframe(PaperDollSidebarTabs)
        if CharacterStatsPaneScrollBox.ScrollBar.Track.Thumb.Begin:IsDesaturated() == false then
            CharacterStatsPaneScrollBox.ScrollBar.Track.Thumb.Begin:SetDesaturated(true)
            CharacterStatsPaneScrollBox.ScrollBar.Track.Thumb.Middle:SetDesaturated(true)
            CharacterStatsPaneScrollBox.ScrollBar.Track.Thumb.End:SetDesaturated(true)

            CharacterStatsPaneScrollBox.ScrollBar.Track.Thumb.Begin:SetVertexColor(.6,.6,.6,.9)
            CharacterStatsPaneScrollBox.ScrollBar.Track.Thumb.Middle:SetVertexColor(.6,.6,.6,.9)
            CharacterStatsPaneScrollBox.ScrollBar.Track.Thumb.End:SetVertexColor(.6,.6,.6,.9)
        end

        for _,stats_child in ipairs(stats_children) do
            if stats_child.Title ~= nil then

                local entry = CCS.headertexture[3]
                local texWidth, texHeight, uMin, uMax, vMin, vMax = unpack(entry.map)

                stats_child.Background:SetTexture(entry.texture)
                stats_child.Background:SetTexCoord(uMin, uMax, vMin, vMax);
                stats_child.Background:SetPoint("TOPLEFT", stats_child, "TOPLEFT",0 , -15)
                stats_child.Background:SetPoint("BOTTOMRIGHT", stats_child, "BOTTOMRIGHT",0 , 0)
                stats_child.Background:SetVertexColor(ncolor[1], ncolor[2], ncolor[3], ncolor[4])
                stats_child.Title:SetAllPoints(stats_child.Background)
                
                if CCS.stats_child_texture == nil then
                    CCS.stats_child_texture = stats_child.Background:GetTexture()
                end

            else
                stats_child.Background:SetTexture("Interface\\Masks\\SquareMask.BLP")
                stats_child.Background:SetVertexColor(0,0,0,.7)
                stats_child.Background:Show()
                stats_child.Background:SetHeight(20)
            end
        end
end

local function BlizPetStatFrame_Update()
        if  CharacterStatsPanePetScrollBox == nil or 
            CharacterStatsPanePetScrollBox.ScrollBox == nil or 
            CharacterStatsPanePetScrollBox.ScrollBox.ScrollTarget == nil then
            return
        end
            
        local stats_children = {CharacterStatsPanePetScrollBox.ScrollBox.ScrollTarget:GetChildren()}
        local hcolor = CCS.StyleColor.highlight
        local ncolor = CCS.StyleColor.normal

        PetPaperDollPetHappinessInfo:SetParent(PetPaperDollFrameExpBar)
        PetPaperDollPetHappinessInfo:ClearAllPoints()
        PetPaperDollPetHappinessInfo:SetPoint("RIGHT", PetPaperDollFrameExpBar, "LEFT", -10, 0)

        if CharacterStatsPanePetScrollBox.ScrollBar.Track.Thumb.Begin:IsDesaturated() == false then
            CharacterStatsPanePetScrollBox.ScrollBar.Track.Thumb.Begin:SetDesaturated(true)
            CharacterStatsPanePetScrollBox.ScrollBar.Track.Thumb.Middle:SetDesaturated(true)
            CharacterStatsPanePetScrollBox.ScrollBar.Track.Thumb.End:SetDesaturated(true)

            CharacterStatsPanePetScrollBox.ScrollBar.Track.Thumb.Begin:SetVertexColor(.6,.6,.6,.9)
            CharacterStatsPanePetScrollBox.ScrollBar.Track.Thumb.Middle:SetVertexColor(.6,.6,.6,.9)
            CharacterStatsPanePetScrollBox.ScrollBar.Track.Thumb.End:SetVertexColor(.6,.6,.6,.9)
        end

        for _,stats_child in ipairs(stats_children) do
            if stats_child.Title ~= nil then

                local entry = CCS.headertexture[3]
                local texWidth, texHeight, uMin, uMax, vMin, vMax = unpack(entry.map)

                stats_child.Background:SetTexture(entry.texture)
                stats_child.Background:SetTexCoord(uMin, uMax, vMin, vMax);
                stats_child.Background:SetPoint("TOPLEFT", stats_child, "TOPLEFT",0 , -15)
                stats_child.Background:SetPoint("BOTTOMRIGHT", stats_child, "BOTTOMRIGHT",0 , 0)
                stats_child.Background:SetVertexColor(ncolor[1], ncolor[2], ncolor[3], ncolor[4])
                stats_child.Title:SetAllPoints(stats_child.Background)
                
                if CCS.stats_child_texture == nil then
                    CCS.stats_child_texture = stats_child.Background:GetTexture()
                end

            else
                stats_child.Background:SetTexture("Interface\\Masks\\SquareMask.BLP")
                stats_child.Background:SetVertexColor(0,0,0,.7)
                stats_child.Background:Show()
                stats_child.Background:SetHeight(20)
            end
        end
end

function CCS.Clicky(endstate)

    if _G["CCSf"] then _G["CCSf"]:Hide() end
    if _G["ccs_sf"] then _G["ccs_sf"]:Hide() end
    if _G["ccsm_sf"] then _G["ccsm_sf"]:Hide() end
    if _G["ccsr_sf"] then _G["ccsr_sf"]:Hide() end    
    if _G["ccsgf_sf"] then _G["ccsgf_sf"]:Hide() end    
    
    if endstate == "LEFT" or CharacterModelScene:GetHeight() >= (CharacterFrameBg:GetHeight()-5) then -- This is to move model under the character equipment
        MoveModelLeft()
        if _G["ccsm_sf"] and (option("showm_sp_onopen") == true) and UnitLevel("player") >= CCS.MaxLevel and (C_MythicPlus.GetCurrentAffixes() and C_MythicPlus.GetCurrentAffixes()[1]) then
            _G["ccsm_sf"]:Show()
        elseif _G["ccsm_sf"] then 
            _G["ccsm_sf"]:Hide() 
        end
    else -- This is to move the model to the right of the character frame.
        MoveModelRight()
    end

    CCS.ChangeModelBg(false)
    PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK);
end

ccs_cshow = function()
    MoveModelLeft()
    if C_AddOns.IsAddOnLoaded("Narcissus") and NarciMiniTalentTree and NarciMiniTalentTree:IsVisible() then -- Just relocate the mini talent tree so it isn't hidden behind the character frame.
    C_Timer.NewTicker(.1, function() 
            NarciMiniTalentTree:ClearAllPoints(); 
            NarciMiniTalentTree:SetPoint("TOPLEFT", CharacterFrameBg, "TOPRIGHT", 0, 0) end, 1)
    end
    --if option("hideshowchbtn") == true then modelbtn:Hide() else modelbtn:Show() end

    if C_AddOns.IsAddOnLoaded("Leatrix_Plus") then -- relocate the volume slider
            C_Timer.After(0, function()
                local p=CharacterModelScene 
                for i=1,p:GetNumChildren()do 
                    local c=select(i,p:GetChildren());
                    local n=c:GetName(); 
                    if c and not n and c.Thumb then 
                        c:ClearAllPoints()
                        c:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight, "BOTTOMLEFT", -40, 3)
                    end 
                end
            end)
    end

    CCS.ChangeModelBg(false)
    CharacterModelScene.ControlFrame:Hide()
    CharacterModelScene.GearEnchantAnimation:Hide()
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
    if CCS.initall == true then return end
    local allReady = true
    for slot = 1, 19 do
        local link = GetInventoryItemLink("player", slot)
        if link and not C_Item.GetItemInfo(link) then
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

local function SkillsFrame_Update()
    local ks={SkillsFrame.ScrollBox.ScrollTarget:GetChildren()}; 
    local dcolor = CCS.StyleColor.border

    CCS.SkillRows =  {}
    
    for _,k in ipairs(ks) do -- Individual Row
        local ks2={k:GetChildren()}; 
        local ktex = select(1, k:GetRegions())
        local kheight = k:GetHeight()

        CCS.SkillRows = CCS.SkillRows or {}
        table.insert(CCS.SkillRows, k)

        if k.Name then 
            k.Name:SetPoint("LEFT", k, "LEFT", 20,0)
            if ktex ~= nil and dcolor ~= nil then
                ktex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\marblebar.png")
                ktex:SetVertexColor(dcolor[1], dcolor[2], dcolor[3], dcolor[4])
                ktex:SetPoint("TOPLEFT", k, "TOPLEFT",0,-kheight*.15)
                ktex:SetPoint("BOTTOMRIGHT", k, "BOTTOMRIGHT",0,kheight*.15)
            end
        else
            if not k.CCS_ClickHooked then
                k:HookScript("OnMouseDown", function(self)
                    -- Mark this row selected
                    self.CCS_Selected = true

                    -- Unselect all other rows
                    for _, row in ipairs(CCS.SkillRows) do
                        if row ~= self then
                            row.CCS_Selected = false

                            -- Restore normal background color
                            if row.Background then
                                if row.standingID == 1 then
                                    row.Background:SetColorTexture(.07, .07, .07, 0)
                                else
                                    row.Background:SetColorTexture(.07, .07, .07, 1)
                                end
                            end
                        end
                    end

                    -- Apply selected highlight to this row
                    if self.Background then
                        --local bcolor = CCS.NormalizeColor(CCS.StyleColor.border)
                       -- self.Background:SetColorTexture(bcolor[1], bcolor[2], bcolor[3], 0.35)
                    end
                end)

                k.CCS_ClickHooked = true
            end

        
        end
        
        for _,k2 in ipairs(ks2) do  
            k.Background = k.Background or k:CreateTexture(nil, "BACKGROUND", nil, 2)

            if (k.Background) then
                k.Background:SetTexture("Interface\\Masks\\SquareMask.BLP")
                k.Background:SetColorTexture(.07, .07, .07, 1)
                
                k.Background:SetPoint("TOPLEFT", k2, "TOPLEFT",0,0)
                k.Background:SetPoint("BOTTOMRIGHT", k2, "BOTTOMRIGHT",0,0)
                k2.BackgroundHighlight:ClearAllPoints()
                k2.BackgroundHighlight:SetAllPoints(k.Background)

                if k:IsSelected() then
                    k.Background:SetColorTexture(.2, .2, .2, 1)
                end

                if k.Background and not k.CCS_BackgroundHighlightHooked then

                    k:SetScript("OnEnter", function(self)
                        k2.BackgroundHighlight:SetAlpha(0)

                        self.Background:SetColorTexture(.2, .2, .2, 1)
                    end)

                    k:SetScript("OnLeave", function(self)
                        -- restore original background color
                        if not k:IsSelected() then
                            if standingID == 1 then
                                self.Background:SetColorTexture(.07, .07, .07, 0)
                            else
                                self.Background:SetColorTexture(.07, .07, .07, 1)
                            end
                        end
                    end)

                    k2.CCS_BackgroundHighlightHooked = true
                end

            end

            if k2.BackgroundHighlight and false then
               -- k2.BackgroundHighlight:Hide()
                k2.BackgroundHighlight:SetAlpha(0)
            end
        end 
    end
end

local function StatisticsFrame_Update() 
    local ks={StatisticsFrame.ScrollBox.ScrollTarget:GetChildren()}; 
    local bcolor = CCS.StyleColor.border
    local dcolor = CCS.DarkenColor(bcolor, .3)
    
    for _,k in ipairs(ks) do -- Individual Row
        local ks2={k:GetChildren()}; 
        local ktex = select(1, k:GetRegions())
        local kheight = k:GetHeight()
        k.Background = k.Background or k:CreateTexture(nil, "BACKGROUND", nil, 2)

        if k.Name ~= nil then 
            k.Name:SetPoint("LEFT", k, "LEFT", 20,0)
            if ktex ~= nil and bcolor ~= nil then
                ktex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\marblebar.png")
                ktex:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])
                ktex:SetPoint("TOPLEFT", k, "TOPLEFT",0,-kheight*.15)
                ktex:SetPoint("BOTTOMRIGHT", k, "BOTTOMRIGHT",0,kheight*.15)
            end
        else
            if k.Content ~= nil and k.Content.BackgroundHighlight ~= nil then
                k.Content.BackgroundHighlight:ClearAllPoints()
                k.Content.BackgroundHighlight:SetAllPoints(k.Background)
                k.Content.BackgroundHighlight:SetFrameLevel(4)
            end

            if k.Background ~= nil then
                k.Background:SetTexture("Interface\\Masks\\SquareMask.BLP")
                k.Background:SetColorTexture(.07, .07, .07, 1)
                k.Background:SetAllPoints(k)
            end
            
            if k.ToggleCollapseButton ~= nil then
                k.Background:SetColorTexture(dcolor[1], dcolor[2], dcolor[3], dcolor[4])
            end
            
        end
    end
end

local function DumpHeaderRow(k)
    print("== Dump for header row ==", k:GetName() or "<unnamed>")

    local regions = { k:GetRegions() }
    for i, r in ipairs(regions) do
        local rType = r:GetObjectType()
        print(string.format("Region %d: %s", i, rType))

        if rType == "Texture" then
            local tex = r:GetTexture()
            local uMin, uMax, vMin, vMax = r:GetTexCoord()
            local hTile = r.GetHorizTile and r:GetHorizTile()
            local vTile = r.GetVertTile and r:GetVertTile()
            local w, h = r:GetSize()
            local layer, sublevel = r:GetDrawLayer()

            print(string.format("  Texture: %s", tex or "nil"))
            print(string.format("  Layer: %s (%d)", layer or "nil", sublevel or 0))
            print(string.format("  Size: %.1f x %.1f", w or 0, h or 0))
            print(string.format("  TexCoord: u(%.3f, %.3f) v(%.3f, %.3f)", uMin or 0, uMax or 0, vMin or 0, vMax or 0))
            print(string.format("  Tiling: horiz=%s vert=%s", tostring(hTile), tostring(vTile)))
        elseif rType == "FontString" then
            print(string.format("  Text: %s", r:GetText() or ""))
        end
    end
end


local function ReputationFrame_Update()
    local ks={ReputationFrame.ScrollBox.ScrollTarget:GetChildren()}; 
    local gender = UnitSex("player");
    local xtext, factiontext= "", ""
    local dcolor = CCS.StyleColor.border

    CCS.RepRows =  {}
    if C_AddOns.IsAddOnLoaded("PrettyReps") then return end
    
    for _,k in ipairs(ks) do -- Individual Row
        local factionData = C_Reputation.GetFactionDataByIndex(k.factionIndex)
        local ks2={k:GetChildren()}; 
        local ktex = select(1, k:GetRegions())
        local kheight = k:GetHeight()

        CCS.RepRows = CCS.RepRows or {}
        table.insert(CCS.RepRows, k)

        if k.Name then 
            k.Name:SetPoint("LEFT", k, "LEFT", 20,0)
            if ktex ~= nil and dcolor ~= nil then
                ktex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\marblebar.png")
                ktex:SetVertexColor(dcolor[1], dcolor[2], dcolor[3], dcolor[4])
                ktex:SetPoint("TOPLEFT", k, "TOPLEFT",0,-kheight*.15)
                ktex:SetPoint("BOTTOMRIGHT", k, "BOTTOMRIGHT",0,kheight*.15)
            end
        else
            if not k.CCS_ClickHooked then
                k:HookScript("OnMouseDown", function(self)
                    -- Mark this row selected
                    self.CCS_Selected = true

                    -- Unselect all other rows
                    for _, row in ipairs(CCS.RepRows) do
                        if row ~= self then
                            row.CCS_Selected = false

                            -- Restore normal background color
                            if row.Background then
                                if row.standingID == 1 then
                                    row.Background:SetColorTexture(.07, .07, .07, 0)
                                else
                                    row.Background:SetColorTexture(.07, .07, .07, 1)
                                end
                            end
                        end
                    end

                    -- Apply selected highlight to this row
                    if self.Background then
                        --local bcolor = CCS.NormalizeColor(CCS.StyleColor.border)
                       -- self.Background:SetColorTexture(bcolor[1], bcolor[2], bcolor[3], 0.35)
                    end
                end)

                k.CCS_ClickHooked = true
            end

        
        end
        
        if factionData ~= nil then
            for _,k2 in ipairs(ks2) do  -- Reputation Bar (in the row)
                local factionID = factionData.factionID
                local name =  factionData.name
                local standingID =  factionData.reaction
                local barMin =  factionData.currentReactionThreshold
                local barMax =  factionData.nextReactionThreshold
                local barValue =  factionData.currentStanding
                k.Background = k.Background or k:CreateTexture(nil, "BACKGROUND", nil, 2)

                if (k.Background) then
                    k.Background:SetTexture("Interface\\Masks\\SquareMask.BLP")
                    if standingID == 1 then
                        k.Background:SetColorTexture(.07, .07, .07, 0)
                    else
                        k.Background:SetColorTexture(.07, .07, .07, 1)
                    end
                    k.Background:SetPoint("TOPLEFT", k2, "TOPLEFT",0,0)
                    k.Background:SetPoint("BOTTOMRIGHT", k2, "BOTTOMRIGHT",0,0)
                    k2.BackgroundHighlight:ClearAllPoints()
                    k2.BackgroundHighlight:SetAllPoints(k.Background)

                    if k:IsSelected() then
                        k.Background:SetColorTexture(.2, .2, .2, 1)
                    end

                    if k.Background and not k.CCS_BackgroundHighlightHooked then

                        k:SetScript("OnEnter", function(self)
                            k2.BackgroundHighlight:SetAlpha(0)

                            self.Background:SetColorTexture(.2, .2, .2, 1)
                        end)

                        k:SetScript("OnLeave", function(self)
                            -- restore original background color
                            if not k:IsSelected() then
                                if standingID == 1 then
                                    self.Background:SetColorTexture(.07, .07, .07, 0)
                                else
                                    self.Background:SetColorTexture(.07, .07, .07, 1)
                                end
                            end
                        end)

                        k2.CCS_BackgroundHighlightHooked = true
                    end

                end

                if k2.BackgroundHighlight and false then
                   -- k2.BackgroundHighlight:Hide()
                    k2.BackgroundHighlight:SetAlpha(0)
                end
                
                if (k2.ReputationBar) then
                    local hpad = math.min(math.max(210, (option("hpad") or 279)), 279)
                    local reph = k2:GetHeight()
                    k2.ReputationBar:SetWidth(140 * hpad / 279 * 2)  
                    k2.ReputationBar:SetHeight(reph*.9)
                    select(1, k2.ReputationBar:GetRegions()):SetHeight(reph)
                    k2.ReputationBar.Fill:SetHeight(reph)
                    k2.ReputationBar.Mask:SetHeight(reph)
                    local percent = barMax > 0 and (barValue / barMax) or 0
                    k2.ReputationBar:SetFillPercent(math.min(percent, 1))
                end
                
                if name == "Inactive" or name == "Other" then
                    -- we skip the inactive header since the friendship lookup doesn't like it.
                else
                    --local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = C_GossipInfo.GetFriendshipReputation(factionID);
                    local colorIndex = standingID;
                    local barColor = FACTION_BAR_COLORS[colorIndex];
                    local factionStandingtext;
                    local isCapped = (standingID == MAX_REPUTATION_REACTION)
                    local isParagon = factionID and C_Reputation.IsFactionParagon(factionID);
                    local isMajorFaction = factionID and C_Reputation.IsMajorFaction(factionID);
                    local repInfo = factionID and C_GossipInfo.GetFriendshipReputation(factionID);
                    
                	local friendshipData = C_GossipInfo.GetFriendshipReputation(factionID);
                    local isFriendshipReputation = friendshipData and friendshipData.friendshipFactionID > 0;
                    local rankInfo = friendshipData and C_GossipInfo.GetFriendshipReputationRanks(friendshipData.friendshipFactionID);

                    if friendshipData ~= nil and friendshipData.name ~= nil then                        
                        if repInfo.nextThreshold then
                            barMin, barMax, barValue = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing;
                        else
                            barMin, barMax, barValue = repInfo.reactionThreshold, repInfo.reactionThreshold, repInfo.reactionThreshold;
                            isCapped = true;
                        end
                        factionStandingtext = repInfo.reaction 
                        
                        if k2.Name ~= nil then
                            k2.Name:SetText(name .. " ("..RANK..": "..(rankInfo.currentLevel or 0).." / "..(rankInfo.maxLevel or 0)..")")
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
                    elseif isCapped and friendshipData ~= nil and friendshipData.name ~= nil then                        
                        --
                        if factionID == 2640 or factionID == 2744 then -- Bran Bronzebeard or Valeera
                            barMax = barMax - barMin;
                            barValue = barValue - barMin;
                            barMin = 0;
                        end
                    else
                        barMax = barMax - barMin;
                        barValue = barValue - barMin;
                        barMin = 0;
                    end
                    
                    if isParagon and C_Reputation.IsFactionParagonForCurrentPlayer(factionID) and k2.ParagonIcon then
                        local currentValue,threshold,rewardQuestID,hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
                        local r,g,b = 0,.5,.9
                        local actualval = currentValue - (floor(currentValue/threshold)-(hasRewardPending and 1 or 0))*threshold
                        factiontext = L["PARAGON"]
                        barMax = threshold
                        barValue = currentValue - (floor(currentValue/threshold)-(hasRewardPending and 1 or 0))*threshold
                        
                        barMin = 0
                        k2.ParagonIcon:SetShown(hasRewardPending); 
                        k2.ReputationBar:SetStatusBarColor(r,g,b)
                        if option("showparagonmax") then
                            -- Force a visually full bar
                            k2.ReputationBar:SetMinMaxValues(0, 1)
                            k2.ReputationBar:SetValue(1)
                        else
                            k2.ReputationBar:SetMinMaxValues(0, barMax);                        
                            k2.ReputationBar:SetValue(barValue);
                        end
                        
                    end
                    
                    if (k2.ReputationBar) then
                        local fontName, fontHeight, fontFlags = k2.ReputationBar.Text:GetFont()
                        --xtext = format("  %-60.60s %-60.60s", factiontext or "", format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue) or "", BreakUpLargeNumbers(barMax)) or "")
                        xtext = format("  %-60.60s", factiontext or "")

                        if k2.ReputationBar.Text2 == nil then
                            k2.ReputationBar.Text2 = k2.ReputationBar:CreateFontString()
                            k2.ReputationBar.Text2:SetFont(option("fontname_repstanding") or fontName, option("fontsize_repstanding"), CCS.textoutline)                            
                            k2.ReputationBar.Text2:SetPoint("RIGHT", k2.ReputationBar, "RIGHT", -2, 0)
                        end
                            
    
                        k2.ReputationBar.barProgressText = xtext
                        k2.ReputationBar.reputationStandingText = xtext
                        k2.ReputationBar.Text:SetFont(option("fontname_repstanding") or fontName, option("fontsize_repstanding"), CCS.textoutline)
                        k2.ReputationBar.Text2:SetFont(option("fontname_repstanding") or fontName, option("fontsize_repstanding"), CCS.textoutline)

                        if option("showfontshadow") == true then
                            k2.ReputationBar.Text:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                            k2.ReputationBar.Text:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                            k2.ReputationBar.Text2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                            k2.ReputationBar.Text2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                            
                        end	                                                                

                        k2.ReputationBar.Text:SetTextColor(
                            option("fontcolor_repstanding")[1] or 1,
                            option("fontcolor_repstanding")[2] or 1,
                            option("fontcolor_repstanding")[3] or 1,
                            option("fontcolor_repstanding")[4] or 1
                        )

                        k2.ReputationBar.Text2:SetTextColor(
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
                        k2.ReputationBar.Text:SetText(xtext)  
                        k2.ReputationBar.Text2:SetText(format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue) or "", BreakUpLargeNumbers(barMax)) or "")
                        k2.ReputationBar.Text:ClearAllPoints()
                        k2.ReputationBar.Text:SetPoint("LEFT", k2.ReputationBar, "LEFT")
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

if true then return end
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
            if not TransmogFrame then

            else
                ToggleFrame(TransmogFrame)
            end
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

local function CCS_FilterTitles(search)
    local filtered = {}
    search = search and search:lower() or ""

    -- "No Title" sentinel row FIRST
    local noTitleName = _G.PLAYER_TITLE_NONE or "No Title"
    if search == "" or noTitleName:lower():find(search, 1, true) then
        table.insert(filtered, {
            id = -1,          -- Blizzard's sentinel for "No Title"
            name = noTitleName,
            earned = true,    -- Must be true so Blizzard enables the button
        })
    end

    -- Add earned titles
    for titleID = 1, GetNumTitles() do
        if IsTitleKnown(titleID) then
            local name = GetTitleName(titleID)
            if name and name ~= "" then
                if search == "" or name:lower():find(search, 1, true) then
                    table.insert(filtered, {
                        id = titleID,
                        name = name,
                        earned = true,
                    })
                end
            end
        end
    end

    -- Sort alphabetically, but keep sentinel row at top
    table.sort(filtered, function(a, b)
        if a.id == -1 then return true end
        if b.id == -1 then return false end
        return a.name:lower() < b.name:lower()
    end)

    return filtered
end

local function CCS_UpdateTitleList()
    local parent = PaperDollFrame.TitleManagerPane
    if not parent or not parent.ScrollBox then return end

    local search = parent.SearchBox and parent.SearchBox:GetText() or ""
    search = search:lower()

    local filtered = CCS_FilterTitles(search)
    local provider = CreateDataProvider()

    -- Blizzard expects this table to exist
    parent.titles = filtered

    for index, entry in ipairs(filtered) do
        provider:Insert({
            index       = index,
            playerTitle = entry,   -- { id, name, earned }
        })
    end

    parent.ScrollBox:SetDataProvider(provider, ScrollBoxConstants.RetainScrollPosition)
end

local function CreateTitleSearchBox()
    local parent = PaperDollFrame.TitleManagerPane
    if not parent or parent.SearchBox then return end

    local box = CreateFrame("EditBox", "CCS_TitleSearchBox", parent, "SearchBoxTemplate")
    parent.SearchBox = box
    box:SetShown(option("showtitlesearch"))
    box:SetSize(200, 20)
    box:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    box:SetAutoFocus(false)

    box:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)
        CCS_UpdateTitleList()
    end)
end


---------------------------------------------------------
-- ScrollBox initializer
---------------------------------------------------------
local function CCS_TitleButtonInitializer(button, elementData)
    local info = elementData.playerTitle
    local index = elementData.index

    local txt = button.text or button.Text
    if txt then
        txt:SetText(info.name)
    end

    button.titleId = info.id

    if button.Check then
        if info.id == GetCurrentTitle() then
            button.Check:Show()
        else
            button.Check:Hide()
        end
    end

    -------------------------------------------------
    -- SELECTED BAR (Blizzard visual)
    -------------------------------------------------
    if button.SelectedBar then
        if info.id == GetCurrentTitle() then
            button.SelectedBar:Show()
        else
            button.SelectedBar:Hide()
        end
    end

    -------------------------------------------------
    -- ENABLE / DISABLE + TEXT COLOR
    -------------------------------------------------
    if info.earned then
        button:Enable()
        if txt then txt:SetTextColor(1, 0.82, 0) end
    else
        button:Disable()
        if txt then txt:SetTextColor(0.6, 0.6, 0.6) end
    end

    -------------------------------------------------
    -- BACKGROUND TEXTURES (Top / Middle / Bottom)
    -------------------------------------------------
    if button.BgTop then
        if index == 1 then
            button.BgTop:Show()
        else
            button.BgTop:Hide()
        end
    end

    if button.BgBottom then
        if index == #PaperDollFrame.TitleManagerPane.titles then
            button.BgBottom:Show()
        else
            button.BgBottom:Hide()
        end
    end

    if button.BgMiddle then
        button.BgMiddle:Show()
    end

    -------------------------------------------------
    -- STRIPE (alternating row background)
    -------------------------------------------------
    if button.Stripe then
        if index % 2 == 0 then
            button.Stripe:SetColorTexture(0.9, 0.9, 1)
            button.Stripe:SetAlpha(0.1)
            button.Stripe:Show()
        else
            button.Stripe:Hide()
        end
    end
end


---------------------------------------------------------
-- Attach initializer
---------------------------------------------------------
local function CCS_ApplyTitleInitializer()
    local pane = PaperDollFrame and PaperDollFrame.TitleManagerPane
    if not pane or not pane.ScrollBox then return end

    local view = pane.ScrollBox:GetView()
    view:SetElementInitializer("PlayerTitleButtonTemplate", CCS_TitleButtonInitializer)
end

function CCS.HookSetup()
    if CCS.Hooked then return end

        --== Frame Hooks
    --CreateTransmogButton()

    hooksecurefunc(SkillsFrame, "Show", function() 
        if SkillsFrame.ScrollBar ~= nil then
            SkillsFrame.ScrollBar.Track.Thumb.Begin:SetDesaturated(true)
            SkillsFrame.ScrollBar.Track.Thumb.Middle:SetDesaturated(true)
            SkillsFrame.ScrollBar.Track.Thumb.End:SetDesaturated(true)

            SkillsFrame.ScrollBar.Track.Thumb.Begin:SetVertexColor(.6,.6,.6,.9)
            SkillsFrame.ScrollBar.Track.Thumb.Middle:SetVertexColor(.6,.6,.6,.9)
            SkillsFrame.ScrollBar.Track.Thumb.End:SetVertexColor(.6,.6,.6,.9)
        end
        SkillsFrame_Update()
    end)
    hooksecurefunc(SkillsFrame.ScrollBox, "Update", function() SkillsFrame_Update() end)

    hooksecurefunc(StatisticsFrame, "Show", function()  
        if StatisticsFrame.ScrollBar ~= nil then
            StatisticsFrame.ScrollBar.Track.Thumb.Begin:SetDesaturated(true)
            StatisticsFrame.ScrollBar.Track.Thumb.Middle:SetDesaturated(true)
            StatisticsFrame.ScrollBar.Track.Thumb.End:SetDesaturated(true)

            StatisticsFrame.ScrollBar.Track.Thumb.Begin:SetVertexColor(.6,.6,.6,.9)
            StatisticsFrame.ScrollBar.Track.Thumb.Middle:SetVertexColor(.6,.6,.6,.9)
            StatisticsFrame.ScrollBar.Track.Thumb.End:SetVertexColor(.6,.6,.6,.9)
        end
        StatisticsFrame_Update() 
    end)
    hooksecurefunc(StatisticsFrame.ScrollBox, "Update", function() StatisticsFrame_Update() end)
    
    hooksecurefunc(TokenFrame, "Show", function() C_Timer.After(0, hookfix) 
        if TokenFrame.ScrollBar ~= nil then
            TokenFrame.ScrollBar.Track.Thumb.Begin:SetDesaturated(true)
            TokenFrame.ScrollBar.Track.Thumb.Middle:SetDesaturated(true)
            TokenFrame.ScrollBar.Track.Thumb.End:SetDesaturated(true)

            TokenFrame.ScrollBar.Track.Thumb.Begin:SetVertexColor(.6,.6,.6,.9)
            TokenFrame.ScrollBar.Track.Thumb.Middle:SetVertexColor(.6,.6,.6,.9)
            TokenFrame.ScrollBar.Track.Thumb.End:SetVertexColor(.6,.6,.6,.9)
        end
    
    end)
    hooksecurefunc(TokenFrame.ScrollBox, "Update", function() CurrencyFrame_Update() end)
  
    hooksecurefunc(CharacterStatsPaneScrollBox.ScrollBox, "Update", function() BlizStatFrame_Update() end)   
    hooksecurefunc(CharacterStatsPanePetScrollBox.ScrollBox, "Update", function() BlizPetStatFrame_Update() end)   
   
    hooksecurefunc(PaperDollFrame, "Show", function() hookfix(); 
        C_Timer.After(0, function() CharacterFrameTitleText:SetTextColor(
        option("fontcolor_nametitle")[1] or 1,
        option("fontcolor_nametitle")[2] or 1,
        option("fontcolor_nametitle")[3] or 1,
        option("fontcolor_nametitle")[4] or 1
        ) end)
        C_Timer.After(0, hookfix)
    end)

    if C_AddOns.IsAddOnLoaded("PrettyReps") == false then
        --hooksecurefunc(ReputationFrame, "Hide", function() ReputationFrame.ReputationDetailFrame:Hide(); end )
        hooksecurefunc(ReputationFrame.ScrollBox, "Update", ReputationFrame_Update)
        --hooksecurefunc(ReputationFrame.ReputationDetailFrame, "Show", ReputationFrame_Update)
        --hooksecurefunc(ReputationFrame.ReputationDetailFrame, "Hide", ReputationFrame_Update)
        hooksecurefunc(ReputationFrame, "Show", function() 
                C_Timer.After(0, hookfix)
                InitializeFrameUpdates();
                ReputationFrame_Update()
        end)
    end


    hooksecurefunc("PaperDollTitlesPane_Update", function()
        CCS_UpdateTitleList()
    end)

    hooksecurefunc("PaperDollTitlesPane_Update", function()
        CreateTitleSearchBox()
    end)

    hooksecurefunc("PaperDollTitlesPane_Update", function()
        CCS_ApplyTitleInitializer()
    end)

    hooksecurefunc(CharacterFrame, "Show", function() 
        if _G["ccsm_sf"] and _G["ccsm_sf"].currentSortBy and _G["ccsm_sf"].currentDir and (_G["ccsm_sf"].currentSortBy ~= option("mplus_sortby") or _G["ccsm_sf"].currentDir ~= option("mplus_direction"))then
            _G["ccsm_sf"].currentSortBy = option("mplus_sortby") or "Name"
            _G["ccsm_sf"].currentDir = option("mplus_direction") or "Ascending"
            CCS.updatemplussideframe()
        end
        ccs_cshow()
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
            
        if not CCS.tempEnchantTicker and option("showtempenchants") then
            CCS.tempEnchantTicker = C_Timer.NewTicker(1, function()
                CCS:UpdateTempEnchantDisplay()
            end)
        end
            
    end )

    hooksecurefunc(CharacterFrame, "Hide", function() 
        GameTooltip:Hide(); 
        CCS.tooltip:Hide(); 
        CCS.StopBGAnimation(modbg);
        if _G["ccsgf_sf"] ~= nil and not InCombatLockdown() then
            _G["ccsgf_sf"]:Hide()
        end
        if CCS.tempEnchantTicker then
            CCS.tempEnchantTicker:Cancel()
            CCS.tempEnchantTicker = nil
        end
        
        end )

    CCS.Hooked = true
end

function module:SetupBlizzardFrameOverrides()
    local Bgoffset = option("hpad")
	--------------------------------
	-- Only process these events once
	--------------------------------

    local CharacterFrameBg = _G["CharacterFrameBg"] or CreateFrame("Frame", "CharacterFrameBg", CharacterFrame, BackdropTemplateMixin and "BackdropTemplate")
    local CharacterFrameInset = _G["CharacterFrameInset"] or CreateFrame("Frame", "CharacterFrameInset", CharacterFrame)
    local CharacterFrameInsetRight = _G["CharacterFrameInsetRight"] or CreateFrame("Frame", "CharacterFrameInsetRight", CharacterFrame)
    _G["CharacterFrameInset"] = _G["CharacterFrameLeftPaneHost"]
    CharacterFrameInset = _G["CharacterFrameInset"]
	if CharacterFrameInset.Bg == nil then 
	    CharacterFrameInset.Bg = CreateFrame("Frame", nil, CharacterFrameInset, BackdropTemplateMixin and "BackdropTemplate")
	end
    --CharacterFrameBg:SetVertexColor(0,0,0,0);
    CharacterFrameBg:ClearAllPoints()
    CharacterFrameBg:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 0, 0);
    --CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", 344, 0);    
    CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "TOPRIGHT", Bgoffset, -(479+(7*option("vpad"))))

    CharacterFrameInset:ClearAllPoints()
    CharacterFrameInset:SetPoint("TOPLEFT", CharacterFrameBg, "TOPLEFT", 4, -60);
    CharacterFrameInset:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", -275, 4);    

    CharacterFrameInset.Bg:ClearAllPoints()
    CharacterFrameInset.Bg:SetPoint("TOPLEFT", CharacterFrameInset, "TOPLEFT", 0, 0);
    CharacterFrameInset.Bg:SetPoint("BOTTOMRIGHT", CharacterFrameInset, "BOTTOMRIGHT", 0, 0);    

    CharacterFrameInsetRight:ClearAllPoints()
    CharacterFrameInsetRight:SetPoint("TOPLEFT", CharacterFrameInset, "TOPRIGHT", 1, 0);
    CharacterFrameInsetRight:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", -4, 4);    
    CharacterFrameModeTabs:ClearAllPoints()
    --CharacterFrameModeTabs:SetPoint("TOPLEFT", CharacterFrameInsetRight,"TOPRIGHT", 5, 0)
    CharacterFrameModeTabs:SetPoint("TOPLEFT", CharacterFrameBg,"TOPRIGHT", 0, -2)
    CharacterFrameModeTabs:SetScale(.75)
    CharacterFrameModeTabs:SetFrameLevel(9001)
    
    CharacterFrameLeftPaneHost:Hide()
    CharacterFrameRightPaneHost:ClearAllPoints()
    CharacterFrameRightPaneHost:SetPoint("LEFT", CharacterFrameLeftPaneHost, "RIGHT",0,0)
    CharacterFrameRightPaneHost:SetPoint("TOP", CharacterFrameBg, "TOP", 0, -10);    
    CharacterFrameRightPaneHost:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", -4, 4);    
    CharacterFrameRightPaneHostStoneBg:SetPoint("RIGHT", CharacterFrameBg, "RIGHT", -5, 0)
    CharacterFrameRightPaneToggleButton:Hide()
    local rphl = select(1, CharacterFrameRightPaneHost:GetChildren())
    if rphl ~= CharacterFrameRightPaneHostStoneBg then
        select(1, rphl:GetRegions()):SetPoint("TOPLEFT", rphl, "TOPLEFT", -6, 6)
        select(1, rphl:GetRegions()):SetPoint("BOTTOMLEFT", rphl, "BOTTOMLEFT", -6, 0)

    end
        
    CharacterStatsPaneScrollBox.ClassBackground:SetPoint("BOTTOMRIGHT", CharacterStatsPaneScrollBox, "BOTTOMRIGHT", -2, 10)
    CharacterStatsPaneScrollBox.Border:SetPoint("BOTTOMRIGHT", CharacterStatsPaneScrollBox, "BOTTOMRIGHT", 0, 2)    
    CharacterStatsPaneScrollBox:SetFrameLevel(4)
    PaperDollLevelInfo:SetPoint("TOP", CharacterFrame.TitleContainer, "BOTTOM", 0, -10)
    PaperDollSidebarTabs:SetPoint("TOP", CharacterFrameRightPaneHost, "TOP", 0, -5)
    PaperDollSidebarTabs:SetHeight(50)
    if ReputationFrame.ScrollBar ~= nil then
        ReputationFrame.ScrollBar.Track.Thumb.Begin:SetDesaturated(true)
        ReputationFrame.ScrollBar.Track.Thumb.Middle:SetDesaturated(true)
        ReputationFrame.ScrollBar.Track.Thumb.End:SetDesaturated(true)

        ReputationFrame.ScrollBar.Track.Thumb.Begin:SetVertexColor(.6,.6,.6,.9)
        ReputationFrame.ScrollBar.Track.Thumb.Middle:SetVertexColor(.6,.6,.6,.9)
        ReputationFrame.ScrollBar.Track.Thumb.End:SetVertexColor(.6,.6,.6,.9)
    end

    local charbg = _G["CharacterFrameBgbg"] or CreateFrame("Frame", "CharacterFrameBgbg", CharacterFrame, BackdropTemplateMixin and "BackdropTemplate")
    local charbgtex = _G["CharacterFrameBgbgtex"] or charbg:CreateTexture("CharacterFrameBgbgtex", "BACKGROUND", nil, 1)    

    charbg:SetBackdrop({
        --bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- optional background texture
        edgeFile = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\UI-Tooltip-SquareBorder.blp",        -- thin edge texture
        edgeSize = 16,                                              -- thickness of the border
        insets = { left = 3, right = 3, top = 3, bottom = 3 },      -- inset so content doesn't overlap border
    })
    
    GearManagerPopupFrame:SetFrameStrata("DIALOG")
    GearManagerPopupFrame.IconSelector:SetFrameStrata("FULLSCREEN")
    
    charbg:ClearAllPoints()
    charbg:SetAllPoints(CharacterFrameBg)
    charbg:SetFrameStrata("BACKGROUND")
    charbg:SetFrameLevel(0)    
    charbgtex:ClearAllPoints()
    charbgtex:SetAllPoints()
    charbgtex:SetTexture("Interface\\Masks\\SquareMask.BLP")

    local CCSsetbtn = _G["CCSsetbtn"] or CreateFrame("Button", "CCSsetbtn", CharacterFrame)
    CCSsetbtn:SetSize(32, 32)
    CCSsetbtn:SetPoint("TOPRIGHT", CharacterFrameCloseButton, "TOPLEFT", -5, 0)
    CCSsetbtn:SetScale(.5)
    CCSsetbtn:SetFrameLevel(510)
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

--==========These are test elements for bliz theme ================
    CharacterFrame.NineSlice:Hide()
    --CharacterFrame.NineSlice:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 0)
    --CharacterFrame.NineSlice.TopLeftCorner:SetAtlas(CharacterFrame.NineSlice.TopRightCorner:GetAtlas())
    --CharacterFrame.NineSlice.TopLeftCorner:SetTexCoord(1, 0, 0, 1)
    --CharacterFrame.NineSlice.TopLeftCorner:SetPoint("TOPLEFT", CharacterFrame.NineSlice, "TOPLEFT", -4, 16)
    --CharacterFrame.NineSlice.LeftEdge:SetPoint("TOPLEFT", CharacterFrame.NineSlice.TopLeftCorner, "BOTTOMLEFT", -9, 0)    
--==========
--==========
--==========
--==========
    
    CharacterFramePortrait:Hide()
   --[[ 
    CharacterFrameInsetRight.Bg:Hide();
    CharacterFrameInsetRight:ClearAllPoints();
    CharacterFrameInsetRight:SetPoint("TOPLEFT", CharacterFrameInset.Bg, "TOPRIGHT", 4, 0)
    CharacterFrameInsetRight:SetPoint("BOTTOMRIGHT", CharacterFrameInset.Bg, "BOTTOMRIGHT", 250, 0)
	CharacterFrameInsetRight:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", -4, 0)    
    CharacterStatsPane.ClassBackground:Hide()
    --]]
	--PaperDollSidebarTabs:SetPoint("LEFT", CharacterFrameInsetRight,"LEFT",0,0)
	--PaperDollSidebarTabs:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight,"TOPRIGHT",0,4)

	--local sbtxoffset = (267 - ((#PAPERDOLL_SIDEBARS+1) * 33)) / 2
	--PaperDollSidebarTab3:SetPoint("BOTTOMRIGHT", PaperDollSidebarTabs,"BOTTOMRIGHT",-sbtxoffset,0)    
    
    PaperDollFrame:UnregisterAllEvents()
--[[
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
--]]    

    CharacterBackSlot.BorderFrame:Hide()
    CharacterChestSlot.BorderFrame:Hide()
    CharacterFeetSlot.BorderFrame:Hide()
    CharacterFinger0Slot.BorderFrame:Hide()
    CharacterFinger1Slot.BorderFrame:Hide()
    CharacterHandsSlot.BorderFrame:Hide()
    CharacterHeadSlot.BorderFrame:Hide()
    CharacterLegsSlot.BorderFrame:Hide()
    CharacterMainHandSlot.BorderFrame:Hide()
    CharacterNeckSlot.BorderFrame:Hide()
    CharacterSecondaryHandSlot.BorderFrame:Hide()
    CharacterShirtSlot.BorderFrame:Hide()
    CharacterShoulderSlot.BorderFrame:Hide()
    CharacterTabardSlot.BorderFrame:Hide()
    CharacterTrinket0Slot.BorderFrame:Hide()
    CharacterTrinket1Slot.BorderFrame:Hide()
    CharacterWaistSlot.BorderFrame:Hide()
    CharacterWristSlot.BorderFrame:Hide()
    --CharacterAmmoSlot.BorderFrame:Hide()
    --select(1, CharacterAmmoSlot:GetRegions()):Hide()
    for i=1,20 do
        local ammo_region = select(i, CharacterAmmoSlot:GetRegions())
        if ammo_region and ammo_region.GetObjectType and ammo_region:GetObjectType() == "Texture" then
            ammo_region:Hide()
        end
    end
    
    CharacterRangedSlot.BorderFrame:Hide()    
--[[
    select(16, CharacterMainHandSlot:GetRegions()):SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
    select(17, CharacterMainHandSlot:GetRegions()):SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)    
    select(16, CharacterSecondaryHandSlot:GetRegions()):SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
    select(17, CharacterSecondaryHandSlot:GetRegions()):SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
--]]
--[[
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
 --]]
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

    ReputationFrame.ScrollBox:SetPoint("TOPLEFT", CharacterFrameLeftPaneHost, "TOPLEFT", 10, -4)
    ReputationFrame.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterFrameLeftPaneHost, "BOTTOMRIGHT", -25, 15)

    SkillsFrame.ScrollBox:SetPoint("TOPLEFT", CharacterFrameLeftPaneHost, "TOPLEFT", 10, -4)
    SkillsFrame.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterFrameLeftPaneHost, "BOTTOMRIGHT", -25, 15)

    StatisticsFrame.ScrollBox:SetPoint("TOPLEFT", CharacterFrameLeftPaneHost, "TOPLEFT", 10, -4)
    StatisticsFrame.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterFrameLeftPaneHost, "BOTTOMRIGHT", -25, 15)



--[[
    ReputationFrame:ClearAllPoints()
    ReputationFrame:SetPoint("TOPLEFT", CharacterFrameBg, "TOPLEFT", 0, 0)
    ReputationFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 7)
    ReputationFrame.ScrollBox:ClearAllPoints()
    ReputationFrame.filterDropdown:ClearAllPoints()
    ReputationFrame.filterDropdown:SetPoint("TOPRIGHT", ReputationFrame, "TOPRIGHT", -38, -30)    
--]]    
    local Height = 520  -- Hard code it for now
    local Left = 120  -- Hard code it for now
   
    CharacterModelScene:ClearAllPoints();
    CharacterModelScene:SetHeight(Height)
    CharacterModelScene:SetWidth(Height/CCS.ModelAspect)
    CharacterModelScene:SetPoint("CENTER", CharacterFrameInset.Bg, "CENTER", 0, -20);
    CharacterModelScene:SetPoint("TOP", CharacterFrameInset.Bg, "TOP", 0, -5);    
    CharacterModelScene:SetFrameStrata("Medium")
    CharacterModelScene:SetFrameLevel(9000)
    CharacterModelScene:Show();
    CharacterModelScene.GearEnchantAnimation:Hide()
    --CharacterModelScene.GearEnchantAnimation:SetAllPoints(CharacterModelFramebg)
    
    CharacterModelFrameBackgroundTopLeft:Hide();
    CharacterModelFrameBackgroundBotLeft:Hide();
    CharacterModelFrameBackgroundTopRight:Hide();
    CharacterModelFrameBackgroundBotRight:Hide();
--[[
    CharacterModelFrameBackgroundOverlay:ClearAllPoints()
    CharacterModelFrameBackgroundOverlay:SetPoint("TOPLEFT", CharacterModelFrameBackgroundTopLeft, "TOPLEFT", 0, 0)
    CharacterModelFrameBackgroundOverlay:SetPoint("BOTTOMRIGHT", CharacterModelFrameBackgroundBotRight, "BOTTOMRIGHT", 0, 70)
    CharacterModelFrameBackgroundOverlay:Hide()
    --]]
--    TokenFramePopup:SetFrameStrata("HIGH")
--    TokenFramePopup.Border.Bg:SetColorTexture(0, 0, 0, 1)
    CurrencyTransferLog:SetFrameStrata("HIGH")
    CharacterModelScene.BackgroundOverlay:Hide()

    if not TokenFrame.CCS_Init and not TokenFrame:IsProtected() then
        TokenFrame:ClearAllPoints()
        TokenFrame:SetPoint("TOPLEFT", CharacterFrameBg, "TOPLEFT", 0, 0)
        TokenFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 0)
        TokenFrame.ScrollBox:ClearAllPoints()
        TokenFrame.ScrollBox:SetPoint("TOPLEFT", CharacterFrameLeftPaneHost, "TOPLEFT", 10, -4)
        TokenFrame.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterFrameLeftPaneHost, "BOTTOMRIGHT", -25, 15)
        TokenFrame.CCS_Init = true
    end
    
    if not _G["ccs_sf"] then 
        
        if not _G["CCSf"] then CreateFrame("Frame", "CCSf", CharacterFrame) end
        local ccsf_af = _G["ccsf_af"] or CreateFrame("Frame", "ccsf_af", CharacterFrame, "SecureHandlerBaseTemplate");
        
        ccsf_af:ClearAllPoints()
        ccsf_af:SetPoint("TOPLEFT", CharacterFrameBg, "TOPRIGHT",  option("hpad")+63, 0);
        CCSf:ClearAllPoints(); 
        CCSf:SetPoint("TOPLEFT", ccsf_af, "TOPRIGHT", 0, 0); 
        CCSf:SetSize(900, 640)
        CCSf:Hide()
        
        local sf = _G["ccs_sf"] or CreateFrame("Frame", "ccs_sf", CharacterFrame);
        local sf_bg = _G["ccs_sf_bg"] or sf:CreateTexture("ccs_sf_bg", "BACKGROUND", nil, 1)        
        local sf_topbar = _G["ccs_sf_tb"] or sf:CreateTexture("ccs_sf_tb", "BACKGROUND", nil, 2)
        local sf_topstreaks = _G["ccs_sf_ts"] or sf:CreateTexture("ccs_sf_ts", "BACKGROUND", nil, 2)
        local sf_bottombar = _G["ccs_sf_bb"] or sf:CreateTexture("ccs_sf_bb", "BACKGROUND", nil, 2)
        
        sf:SetScale(.69)
        sf_bg:Show()
    end

    -- Create the character model button
    modelbtn:SetSize(23, 23)
    modelbtn:SetNormalTexture("Interface\\Calendar\\MeetingIcon.blp")
    modelbtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square.blp", "ADD")
    modelbtn:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress.blp")
    modelbtn:SetHitRectInsets(0, 0, 0, 0)
    modelbtn:SetPoint("BOTTOMRIGHT", CharacterFrameRightPaneHost, "BOTTOMLEFT", -7, 10)    
    modelbtn:SetFrameStrata("HIGH")
    modelbtnfont1:SetFont(option("fontname_showchar") or CCS.fontname, (option("fontsize_showchar") or 10), CCS.textoutline)
    modelbtnfont1:SetPoint("RIGHT", modelbtn, "LEFT", -3 , 2)
    modelbtnfont1:SetText(MOUNT_JOURNAL_PLAYER)
    modelbtnfont1:SetWordWrap(true)
    modelbtn:SetScript("OnEnter", function(self) CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT")
            CCS.tooltip:AddDoubleLine("", nil, 1, 1, 1, 1, 1, 1) 
            CCS.tooltip:Show()
    end)
    modelbtn:SetScript("OnLeave", function() CCS.tooltip:Hide() end)
    modelbtn:SetScript("OnClick", function()
            if not InCombatLockdown() then 
                CCS.Clicky() 
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
end

function module:UpdateStyle()
    local charbg = _G["CharacterFrameBgbg"] or CreateFrame("Frame", "CharacterFrameBgbg", CharacterFrameBg, BackdropTemplateMixin and "BackdropTemplate")
    local charbgtex = _G["CharacterFrameBgbgtex"] or charbg:CreateTexture("CharacterFrameBgbgtex", "BACKGROUND", nil, 1)    
    local bgr, bgg, bgb, bgalpha = option("bgcolor")[1], option("bgcolor")[2], option("bgcolor")[3], option("bgcolor")[4];

    local borderColor = CCS.StyleColor.border
    charbg:SetBackdropBorderColor(unpack(borderColor))   -- purple border    
    charbg:SetBackdropColor(bgr,bgg,bgb,bgalpha)   -- purple border    
    charbgtex:SetVertexColor(bgr,bgg,bgb,bgalpha);

    CCS:SkinBlizzardButton(CharacterFrameCloseButton, "x", 26)

    local CCSsetbtn = _G["CCSsetbtn"] or CreateFrame("Button", "CCSsetbtn", CharacterFrame)
    CCS:ApplyIconStyle(CCSsetbtn, "gear", 32)

    local ttfontsize = option("fontsize_nametitle") or 12
    CharacterFrameTitleText:SetPoint("TOP", CharacterFrameBg, "TOP", 0, -5*ttfontsize/12)
    CharacterFrameTitleText:SetFont( option("fontname_nametitle") or CCS.fontname, ttfontsize , CCS.textoutline)
    if option("showfontshadow") == true then
        CharacterFrameTitleText:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
        CharacterFrameTitleText:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
    end	                                                
    
    CharacterFrameTitleText:SetTextColor(unpack(option("fontcolor_nametitle") or {1,1,1,1}))

    CharacterLevelText:SetFont(option("fontname_levelclass") or CCS.fontname, (option("fontsize_levelclass") or 12) , CCS.textoutline)
    if option("showfontshadow") == true then
        CharacterLevelText:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
        CharacterLevelText:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
    end	    

    modelbtnfont1:SetFont(option("fontname_showchar") or CCS.fontname, (option("fontsize_showchar") or 10), CCS.textoutline)
    if option("showfontshadow") == true then
        modelbtnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
        modelbtnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
    end	                                                
    
    modelbtnfont1:SetTextColor(unpack(option("fontcolor_showchar") or {1,1,1,1}))
    if option("hidemodelbg") then modbg:Hide() else modbg:Show() end

    -------------------------------
    -- Now we recolor all of the new in-game assets that Blizzard has
    -------------------------------
    local bcolor = CCS.NormalizeColor(CCS.StyleColor.border)
    
    if bcolor ~= nil then
        CharacterFrameModeTab1.Background:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])
        CharacterFrameModeTab2.Background:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])
        CharacterFrameModeTab3.Background:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])
        CharacterFrameModeTab4.Background:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])
        CharacterFrameModeTab5.Background:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])
        CharacterFrameModeTab6.Background:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])
        
        local rphl = select(1, CharacterFrameRightPaneHost:GetChildren())
        if rphl ~= CharacterFrameRightPaneHostStoneBg then
            local rphl_bar = select(1, rphl:GetRegions())
            rphl_bar:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])
        end
        CharacterFrameRightPaneHostStoneBg:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])

        local rph = select(1, CharacterFrameRightPaneHost:GetRegions())
        if rph ~= CharacterFrameRightPaneHostStoneBg then
            rph:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock.blp")
            rph:SetVertexColor(bcolor[1], bcolor[2], bcolor[3], bcolor[4])
        end

        
    end
    
end

function module:ApplyDynamicLayout()
    local scaling = option("sheetscale") or 1
    local Bgoffset = option("hpad")
	--------------------------------
	-- Only process hpad/vpad
	--------------------------------
	if CCS.lastChangedOption == nil or CCS.lastChangedOption == "vpad" or CCS.lastChangedOption == "hpad" then
		CharacterFrameBg:SetHeight(479+(7*option("vpad"))) -- Do not allow the frame to get any smaller than the default bliz frame
		CharacterFrameInset.Bg:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMLEFT", 330+option("hpad"), 30)
        if C_AddOns.IsAddOnLoaded("DejaCharacterStats") then
			CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "TOPRIGHT",Bgoffset, -(479+(7*option("vpad")))); 
		else
			CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "TOPRIGHT", Bgoffset, -(479+(7*option("vpad")))); --279  .449
		end   
        
		CharacterFrameCloseButton:ClearAllPoints();
		CharacterFrameCloseButton:SetPoint("TOPRIGHT", CharacterFrameBg, "TOPRIGHT", -10, -10)
		CharacterFrameCloseButton:SetSize(32, 32)
		CharacterFrameCloseButton:SetScale(.5)
		---------------
		-- All slots on the left (under head) are tied back to this slot
		---------------
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
		CharacterRangedSlot:ClearAllPoints()
		CharacterRangedSlot:SetPoint("TOPLEFT", CharacterMainHandSlot, "BOTTOMLEFT", 0, -5)        
        CharacterAmmoSlot:SetPoint("LEFT", CharacterRangedSlot, "RIGHT", 25,0)
	end
	--------------------------------
	-- Only process character sheet scale
	--------------------------------
    if CCS.lastChangedOption == nil or CCS.lastChangedOption == "sheetscale" then
		if scaling ~= 1 or (scaling == 1 and CharacterFrame:GetScale() ~= 1) then -- If scaling is 1, then we can let other addons adjust the sheet scale.
			CharacterFrame:SetScale(scaling); 
		end
		if ccs_sf then ccs_sf:SetScale(.69); end
	end
    
    if option("hideshowchbtn") == true then modelbtn:Hide() else modelbtn:Show() end
    
	--------------------------------
	-- Only process hide icon borders
	--------------------------------
    if CCS.lastChangedOption == nil or CCS.lastChangedOption == "hideiconborders" then
        if (option("hideiconborders")) then
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
			CharacterRangedSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
            
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
			CharacterRangedSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
			CharacterAmmoSlotIconTexture:SetTexCoord(.07,.07,.07,.93,.93,.07,.93,.93)
            
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
			CharacterRangedSlotNormalTexture:Hide()
			CharacterAmmoSlotNormalTexture:Hide()
            
        else
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
			CharacterRangedSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
			--[[CharacterAmmoSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
			local ammo_region = select(14, CharacterAmmoSlot:GetRegions())
			if ammo_region and ammo_region.GetObjectType and ammo_region:GetObjectType() == "Texture" then
				ammo_region:SetTexCoord(1,1,1,1,1,1,1,1)
			end--]]
            
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
			CharacterRangedSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
			CharacterAmmoSlotIconTexture:SetTexCoord(0,0,0,1,1,0,1,1)
            
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
            CharacterRangedSlotNormalTexture:Show()
			CharacterAmmoSlotNormalTexture:Show()
              
        end
    end
end
-- Module Initialization
function module:Initialize(onlyStyle)
    -- Set up the character sheet for the current player

    if CCS.AreSecretsDisabled() then 
        CCS.initall = true
        return 
    end

    ----------------------------------
    -- This is for options menu changes. Only process Layout & Styles updates
    ----------------------------------

    if onlyStyle and self.BlizzardCleanup then
        self:ApplyDynamicLayout()
        self:UpdateStyle()
        return
    end

    ----------------------------------
    -- Bliz cleanup, Layout setup, & Styles
    ----------------------------------
    if not self.BlizzardCleanup then
        self:SetupBlizzardFrameOverrides()
        CCS.HookSetup()
        self.BlizzardCleanup = true
    end

    if not self.LayoutSetup then
        self:ApplyDynamicLayout()
        self.LayoutSetup = true
    end

    if not self.StyleSetup then
        self:UpdateStyle()
        self.StyleSetup = true
    end

    --LootSpecInit()
    --SpecChangeInit()
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

function CCS.RefreshTitleRows()
    C_Timer.After(0, function()
        local pane = PaperDollFrame and PaperDollFrame.TitleManagerPane
        if not pane or not pane.ScrollBox then return end

        pane.ScrollBox:ForEachFrame(function(button, elementData)
            CCS_TitleButtonInitializer(button, elementData)
        end)
    end)
end


-- Define the event handler function for this module
function CCS.ForeverCharacterSheetEventHandler(event, ...)
    local arg1 = ...

    if CCS.CurrentVersion ~= CCS.FOREVER then return end

    if CCS.initall == true then return end
   
    if event == "PLAYER_ENTERING_WORLD" then
            for slot = 1, 19 do
                local link = GetInventoryItemLink("player", slot)
                if link then
                    C_Item.GetItemInfo(link) -- queues item for caching
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
    if event == "UNIT_NAME_UPDATE" and arg1 == "player" then
        CCS.RefreshTitleRows()
        return
    end
    
    if event == "PLAYER_EQUIPMENT_CHANGED" then
        if arg1 == nil then return false end

        if not CCS.characterUpdatePending then
            CCS.characterUpdatePending = true
            C_Timer.After(0.2, function()
                CCS.characterUpdatePending = false
                BlizStatFrame_Update()
                BlizPetStatFrame_Update()
                TryLoopItems()
            end)
        end
        return true
    elseif event == "CCS_EVENT_OPTIONS" then
        TryLoopItems()
        CCS.ChangeModelBg(false)
        ReputationFrame_Update()
        SkillsFrame_Update()
        StatisticsFrame_Update()        
        CurrencyFrame_Update()
        BlizStatFrame_Update()
        BlizPetStatFrame_Update()
        --LootSpecInit()
        --SpecChangeInit()        
        --print(date("%H:%M:%S") .. format(".%03d", (GetTime() * 1000) % 1000), "message")
        if CCS_TitleSearchBox then
            CCS_TitleSearchBox:SetShown(option("showtitlesearch"))
        end

        return true
    elseif event == "CCS_EVENT_CSHOW" then

        if not CCS.characterUpdatePending then
            CCS.characterUpdatePending = true
            C_Timer.After(0, function()
                CCS.characterUpdatePending = false
                TryLoopItems()
                ccs_cshow()
                ReputationFrame_Update()
                SkillsFrame_Update()
                StatisticsFrame_Update()
                BlizStatFrame_Update()
                BlizPetStatFrame_Update()
            end)
        end
        return true

    elseif event == "PLAYER_LOOT_SPEC_UPDATED" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        --LootSpecInit()
        --SpecChangeInit()
        CCS.ChangeModelBg(false)
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
                BlizStatFrame_Update()
                BlizPetStatFrame_Update()
                --loopitems()
            end)
        end
        return true
    end
end
