local addonName, ns = ...
local CCS = ns.CCS
if CCS.GetCurrentVersion() ~= CCS.TBC then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table

local module = {
    Name = "TBC Module",
    CompatibleVersions = { CCS.TBC },
    OnInitialize = function(self)
        print(self.Name .. " initialized for TBC")
    end,
}

CCS.Modules[module.Name] = module

-- Event handler for TBC
function CCS.TBCEventHandler(event, ...)
    local arg1, arg2, arg3 = ...

    if event == "BOSS_KILL" then
        --module:OnBossKill(arg1)
    elseif event == "LOOT_READY" then
        --module:OnLootReady()
    elseif event == "PLAYER_LEAVE_COMBAT" then
        --module:OnLeaveCombat()
    end
end

---------------------------
-- Module Definitions
---------------------------
local modbg = _G["CharacterModelFramebg"] or CreateFrame("Frame", "CharacterModelFramebg", CharacterModelFrame)
local modtex = _G["CharacterModelFramebgtex"] or modbg:CreateTexture("CharacterModelFramebgtex", "BACKGROUND")    

local inspectmodbg = _G["InspectModelFramebg"] or CreateFrame("Frame", "InspectModelFramebg")
local inspectmodtex = _G["InspectModelFramebgtex"] or inspectmodbg:CreateTexture("InspectModelFramebgtex", "BACKGROUND")    

local modelbtn = _G["CCS_clk_Btn"] or CreateFrame("Button", "CCS_clk_Btn", PaperDollFrame, "UIPanelButtonTemplate")
local bg_texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\MOTHERtalenttree.BLP"

---------------------------------
---------------------------------
---------------------------------
--- On with the show!
---------------------------------
---------------------------------
---------------------------------
function CCS.GetAverageItemLevel(unit)
    local total, count = 0, 0

    for slot = 1, 18 do
        if slot ~= 4 then  -- skip shirt
            local link = GetInventoryItemLink(unit, slot)
            if link then
                local _, _, _, ilvl, _, _, _, _, equipLoc = GetItemInfo(link)

                if ilvl and ilvl > 0 then
                    -- 2H weapon counts as two slots
                    if slot == 16 and equipLoc == "INVTYPE_2HWEAPON" then
                        total = total + (ilvl * 2)
                        count = count + 2
                    else
                        total = total + ilvl
                        count = count + 1
                    end
                end
            else
                count = count + 1
            end
        end
    end

    if count == 0 then
        return 0
    end

    return total / count
end


local function MoveModelLeft() 
    local Height = 359+(7*option("vpad"))  -- Hard code it for now
    
    if CharacterModelScene:GetHeight() == Height then
    return end
    
    CharacterModelScene:ClearAllPoints();
    CharacterModelScene:SetHeight(Height)
    CharacterModelScene:SetWidth(Height/CCS.ModelAspect)
    CharacterModelScene:SetPoint("CENTER", CharacterFrameInset.Bg, "CENTER", 0, 0);
    CharacterModelScene:SetFrameLevel(2)
    
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
    CharacterModelScene:Show();
    
    _G["CharacterModelFramebg"]:ClearAllPoints()
    _G["CharacterModelFramebg"]:SetAllPoints(CharacterModelScene)    
end

local function ChangeInspectModelBg()
 if InspectFrame == nil or InspectFrame.unit == nil then return end

    local _, _, classID = UnitClass(InspectFrame.unit)
    local _, _, raceID = UnitRace(InspectFrame.unit)
    local specID = GetPrimaryTalentTree()
    local entry = nil

    inspectmodbg:ClearAllPoints()
    if inspectmodbg:GetParent() == nil then
        inspectmodbg:SetParent(InspectModelFrame)
    end
    inspectmodbg:SetPoint("TOPLEFT", InspectHeadSlot, "TOPLEFT", 0, 0)
    inspectmodbg:SetPoint("RIGHT", InspectHandsSlot, "RIGHT", 0, 0)    
    inspectmodbg:SetPoint("BOTTOM", InspectMainHandSlot, "BOTTOM", 0, 0)    
    inspectmodbg:SetFrameStrata("BACKGROUND")
    inspectmodbg:SetFrameLevel(100)    

    if inspectmodbg:GetParent() == nil then
        inspectmodbg:SetParent(InspectModelFrame)
    end

    if option("bgtype_inspect") == "Hide" then
        inspectmodtex:Hide()
        return
    end
    inspectmodtex:Show()
    if option("bgtype_inspect") == "Class" then 
        -- Class/Specialization background
        entry = CCS.Class_Bg[classID] and CCS.Class_Bg[classID][specID]        
        inspectmodtex:SetVertexColor(0.8, 0.8, 0.8, 1)
    elseif option("bgtype_inspect") == "Race" then 
        -- Race background
        if classID == 6 then raceID = 998 -- Death Knight
        elseif classID == 12 then raceID = 999 -- Demon Hunter
        end
        entry = CCS.Race_Bg[raceID] 
        inspectmodtex:SetVertexColor(0.7, 0.7, 0.7, 1)
    end
    
    inspectmodtex:ClearAllPoints()
    inspectmodtex:SetAllPoints()
    
    if entry then
        local texWidth, texHeight, uMin, uMax, vMin, vMax = unpack(entry.map)
        local frameWidth, frameHeight = inspectmodtex:GetWidth(), inspectmodtex:GetHeight()
        
        inspectmodtex:SetTexture(entry.texture)
        
        if option("bgtype_inspect") == "Class" then
            -- Class/Specialization: right-aligned
            inspectmodtex:SetTexCoord(
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
            
            inspectmodtex:SetTexCoord(
                uMin + uOffset,
                uMax - uOffset,
                vMin,
                vMax
            )
        end
    else
        -- Default background
        inspectmodtex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\MOTHERtalenttree.BLP")
        inspectmodtex:SetTexCoord(0, 0.69, 0, 0.87)
        inspectmodtex:SetVertexColor(0.4, 0, 0.4, 0.9)
    end
    -- end of dynamic background
end

local function ChangeModelBg()
    local _, _, classID = UnitClass("player")
    local _, _, raceID = UnitRace("player")
    local specID = GetPrimaryTalentTree()
    local entry = nil
    
    if option("bgtype") == "Hide" then
        modtex:Hide()
        return
    end
    modtex:Show()
    if option("bgtype") == "Class" then 
        -- Class/Specialization background
        entry = CCS.Class_Bg[classID] and CCS.Class_Bg[classID][specID]        
        modtex:SetVertexColor(0.8, 0.8, 0.8, 1)
    elseif option("bgtype") == "Race" then 
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
        
        if option("bgtype") == "Class" then
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

local function Clicky(endstate)
    if CharacterModelScene:GetHeight() > 600 then -- This is to move model under the character equipment
        MoveModelLeft()
    else -- This is to move the model to the right of the character frame.
        MoveModelRight()
    end

    ChangeModelBg()
    PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK);
end

local function ccs_cshow()
    --MoveModelLeft()
    --ChangeModelBg()
    --CharacterModelScene.ControlFrame:Hide()
end

local function InitStats()
    if not CharacterStatsPane then return end

    CharacterStatsPane.ScrollBox:ClearAllPoints()
    CharacterStatsPane.ScrollBox:SetPoint("TOPLEFT", CharacterStatsPane, "TOPLEFT", 14, -25)
    CharacterStatsPane.ScrollBox:SetPoint("BOTTOMRIGHT", CharacterStatsPane, "BOTTOMRIGHT", -4, 0)


    for i = 1, 7 do
        local category = _G["CharacterStatsPaneCategory"..i]
        if category then
            category:SetPoint("RIGHT", CharacterStatsPane.ScrollBox, "RIGHT", -4, 0)
            for _, suffix in ipairs({"BgBottom","BgTop","BgMiddle","BgMinimized"}) do
                local bg = _G["CharacterStatsPaneCategory"..i..suffix]
                if bg then
                    bg:SetPoint("RIGHT", category, "RIGHT", 0, 0)
                end
            end
        end
    end

        -- Ilvl Frame
        
        local btn = _G["CSPilvl"] or CreateFrame("Button", "CSPilvl", CharacterStatsPane)
        local btnfont1 = _G["CSPilvlfs1"] or btn:CreateFontString("CSPilvlfs1")
        --local btnfont2 = _G["CSPilvlfs2"] or btn:CreateFontString("CSPilvlfs2")
        local btntex = _G["CSPilvltex"] or btn:CreateTexture("CSPilvltex", "BACKGROUND", nil, 1)
        local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvP = GetAverageItemLevel();
        local Color = "a336ed"
        local tt_name = ""
        local tt_desc = ""

        btn:SetParent(CharacterStatsPane)
        btn:ClearAllPoints()
        btn:SetSize(230, 23*(option("fontsize_cilvl") or 20) /20)
        btn:SetPoint("TOP", PaperDollSidebarTabs, "BOTTOM", -30, -7)
        btn:SetFrameStrata("HIGH")
        btn.throttle = 0;
        btn:Show()       
        
        btntex:ClearAllPoints()
        btntex:SetAllPoints()
        btntex:SetTexture("Interface\\Masks\\SquareMask.BLP")
        btntex:SetGradient("Vertical", CreateColor(0, 0, 0, .2), CreateColor(.1, .1, .1, .4)) -- Dark Gray
        btnfont1:SetPoint("CENTER", btn, "CENTER", 0 ,0)
        btnfont1:SetFont(option("fontname_cilvl") or CCS.fontname, (option("fontsize_cilvl") or 20))

        CCS.PreloadEquippedItemInfo("player")
        
        CCS.WaitForItemInfoReady("player", function()
            local color = CCS:GetAverageEquippedRarityHex("player")
            Color = color

            avgItemLevelEquipped = format("%.2f", avgItemLevelEquipped)
            avgItemLevel = format("%.2f", avgItemLevel)
            avgItemLevelPvP = format("%.2f", avgItemLevelPvP)

            btnfont1:SetText(format("|cFF%s%s / %s|r", Color, avgItemLevelEquipped, avgItemLevel))
        end)
    
    
end

local function hookfix() 
    CharacterLevelText:ClearAllPoints()
    CharacterLevelText:SetPoint("TOP", CharacterFrameTitleText, "BOTTOM", 0, 0)
    CharacterLevelText:SetFont(option("fontname_levelclass") or CCS.fontname, (option("fontsize_levelclass") or 12) , CCS.textoutline)
    
    if CharacterFrameExpandButton then
        CharacterFrameExpandButton:ClearAllPoints()
        CharacterFrameExpandButton:SetPoint("BOTTOMRIGHT", CharacterFrameInset, "BOTTOMRIGHT",270,4)
    end
    
    PetLevelText:ClearAllPoints()
    PetLevelText:SetPoint("TOP", CharacterFrameTitleText, "BOTTOM", 0, -4)
    PetLevelText:SetFont(option("fontname_levelclass") or CCS.fontname, (option("fontsize_levelclass") or 12) , CCS.textoutline)
    PetModelFrame:SetPoint("BOTTOMRIGHT", CharacterFrameInset, "BOTTOMRIGHT", 270, 4)
    PetPaperDollPetModelBg:ClearAllPoints()
    PetPaperDollPetModelBg:SetPoint("TOPLEFT", PetModelFrame, "TOPLEFT", 4, -4)
    PetPaperDollPetModelBg:SetPoint("BOTTOMRIGHT", PetModelFrame, "BOTTOMRIGHT", 350, -250)
    InitStats()
    
end

local function InitializeFrameUpdates()
    ReputationFrame:ClearAllPoints()
    ReputationFrame:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 0, 0)
    ReputationFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 0)
end


local function TBCupdateLocationInfo(unit, slotIndex, framename)

    local isPlayer = (unit == "player")
    local isInspect = not isPlayer

    if isInspect and not option("show_inspect") then return end

    local suffix = isPlayer and "" or "_inspect"
    local slotFrameName = CCS.getSlotFrameName(slotIndex, framename)
    if not slotFrameName then return end

    -- Determine display direction
	local displaytoleft = CCS.displaytowardleft(slotIndex)
    
	if framename == "CompCharacter" then
		displaytoleft = true
	elseif framename == "CompInspect" then
		displaytoleft = false
	end
	
    local SubElementSetPoint = "LEFT"
    local SubElementSetPoint2 = "RIGHT"
    local neg = 1
    
    if displaytoleft then 
        SubElementSetPoint = "RIGHT" 
        SubElementSetPoint2 = "LEFT" 
        neg = -1
    end
	
    -- Get item link and info
    local link = GetInventoryItemLink(unit, slotIndex)
    local itemLoc = isPlayer and ItemLocation:CreateFromEquipmentSlot(slotIndex) or nil

    if slotIndex == 0 then
        local id = GetInventoryItemID("player", slotIndex)
        local _, ammolink = GetItemInfo(id)
        link = ammolink
    end

    -- Create or reuse UI elements
    _G[slotFrameName]:SetFrameStrata("HIGH")
    local nameTxt = _G[slotFrameName.."namefs"] or _G[slotFrameName]:CreateFontString(slotFrameName.."namefs")
    local ilvlTxt = _G[slotFrameName.."ilvlfs"] or _G[slotFrameName]:CreateFontString(slotFrameName.."ilvlfs")
    local enchantTxt = _G[slotFrameName.."enchantfs"] or _G[slotFrameName]:CreateFontString(slotFrameName.."enchantfs")
    local bgfader = _G[slotFrameName.."bgfader"] or CreateFrame("Frame", slotFrameName.."bgfader", _G[slotFrameName])
    local bgfadertex = _G[bgfader:GetName().."tex"] or bgfader:CreateTexture(bgfader:GetName().."tex", "BACKGROUND", nil, 1)

    -- Optional: durability for player only
    local durabilityTxt, durbar, durbartex
    if isPlayer then
        durabilityTxt = _G[slotFrameName.."durabilityfs"] or _G[slotFrameName]:CreateFontString(slotFrameName.."durabilityfs")
        durbar = _G[slotFrameName.."durbar"] or CreateFrame("Frame", slotFrameName.."durbar", _G[slotFrameName])
        durbartex = _G[durbar:GetName().."tex"] or durbar:CreateTexture(durbar:GetName().."tex", "BACKGROUND", nil, 2)
        durbar:SetSize(4, 34)
        durbar:SetPoint("BOTTOM"..SubElementSetPoint, slotFrameName, "BOTTOM"..SubElementSetPoint2, 1 * neg, 0)
        durbar:SetFrameLevel(2)
        durbartex:SetAllPoints()
        durbartex:SetTexture("Interface\\Masks\\SquareMask.BLP")
    end

    -- Gem frames
    local gemIconframe1 = _G[slotFrameName.."gemtex1"] or CreateFrame("Button", slotFrameName.."gemtex1", _G[slotFrameName], "UIPanelButtonTemplate")
    local gemIconframe2 = _G[slotFrameName.."gemtex2"] or CreateFrame("Button", slotFrameName.."gemtex2", _G[slotFrameName], "UIPanelButtonTemplate")
    local gemIconframe3 = _G[slotFrameName.."gemtex3"] or CreateFrame("Button", slotFrameName.."gemtex3", _G[slotFrameName], "UIPanelButtonTemplate")

    -- Positioning and font setup
    nameTxt:SetPoint(SubElementSetPoint, _G[slotFrameName], SubElementSetPoint2, 10 * neg, 13)
    nameTxt:SetFont(option("fontname_iname"..suffix) or CCS.fontname, option("fontsize_iname"..suffix) or 12, "OUTLINE")

    ilvlTxt:SetPoint(SubElementSetPoint, _G[slotFrameName], SubElementSetPoint2, 10 * neg, 0)
    ilvlTxt:SetFont(option("fontname_iilvl"..suffix) or CCS.fontname, option("fontsize_iilvl"..suffix) or 10, "OUTLINE")
    ilvlTxt:SetTextColor(
        option("fontcolor_iilvl"..suffix)[1] or 1,
        option("fontcolor_iilvl"..suffix)[2] or 1,
        option("fontcolor_iilvl"..suffix)[3] or 1,
        option("fontcolor_iilvl"..suffix)[4] or 1
    )

    enchantTxt:SetPoint(SubElementSetPoint, _G[slotFrameName], SubElementSetPoint2, 10 * neg, -13)
    enchantTxt:SetFont(option("fontname_enchant"..suffix) or CCS.fontname, option("fontsize_enchant"..suffix) or 10, "OUTLINE")
    enchantTxt:SetTextColor(
        option("fontcolor_enchant"..suffix)[1] or 1,
        option("fontcolor_enchant"..suffix)[2] or 1,
        option("fontcolor_enchant"..suffix)[3] or 1,
        option("fontcolor_enchant"..suffix)[4] or 1
    )

    -- Optional: durability positioning
    if isPlayer and durabilityTxt then
        durabilityTxt:SetPoint("CENTER", _G[slotFrameName], "CENTER", 0, 0)
        durabilityTxt:SetFont(option("fontname_durability") or CCS.fontname, option("fontsize_durability") or 10, CCS.textoutline)
    end

    bgfader:SetSize(240, 39) -- fader size (scales with the character frame)
    bgfader:SetPoint(SubElementSetPoint, slotFrameName, SubElementSetPoint2, -38 * neg, 0)        
    bgfader:SetFrameLevel(1)
    bgfadertex:SetAllPoints()
    bgfadertex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Square_AlphaGradient.tga") -- last remnant from WeakAuras.
    
    gemIconframe1:SetSize(15, 15)
    gemIconframe1:SetPoint("TOP"..SubElementSetPoint2, slotFrameName, "TOP"..SubElementSetPoint, -8 * neg, 6)
    gemIconframe1:SetFrameStrata("HIGH")
    
    gemIconframe2:SetSize(15, 15)
    gemIconframe2:SetPoint(SubElementSetPoint2, slotFrameName, SubElementSetPoint, -8 * neg, 0)
    gemIconframe2:SetFrameStrata("HIGH")
    
    gemIconframe3:SetSize(15, 15)
    gemIconframe3:SetPoint("BOTTOM"..SubElementSetPoint2, slotFrameName, "BOTTOM"..SubElementSetPoint, -8 * neg, -6)
    gemIconframe3:SetFrameStrata("HIGH")


    -- Hide all elements by default
    nameTxt:Hide()
    ilvlTxt:Hide()
    enchantTxt:Hide()
    if durabilityTxt then durabilityTxt:Hide() end
    gemIconframe1:Hide()
    gemIconframe2:Hide()
    gemIconframe3:Hide()
    bgfader:Hide()
    if durbar then 
        durbar:Hide() 
    end

    -- Bail early if no item

    if link == nil then
        nameTxt:SetText("")
        ilvlTxt:SetText("")
        enchantTxt:SetText("")
        if durabilityTxt then durabilityTxt:SetText("") end
        return
	else 
        local durCur, durMax = GetInventoryItemDurability(slotIndex)
        local _, _, _, _, _, _, Gem1, Gem2, Gem3, _, _, _, _, _, _ = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
        local itemName, _, itemRarity, itemiLevel, _, itemType, _, _, _, _, _, _, _, _, expacID, setID, _ = C_Item.GetItemInfo(link)
        itemiLevel = C_Item.GetDetailedItemLevelInfo(link)
        local Color = "ffffffff"

        local itemID = tonumber(link:match("item:(%d+)"))
        if not C_Item.IsItemDataCachedByID(itemID) then
            C_Item.RequestLoadItemDataByID(itemID)
        end

        if itemRarity and itemRarity >= 1 and itemRarity <= 7 then
            Color = select(4, C_Item.GetItemQualityColor(itemRarity))
        end
        
        local ItemTip = _G["CCS_Scanningtooltip"] or CreateFrame('GameTooltip', 'CCS_Scanningtooltip', WorldFrame, 'GameTooltipTemplate')
        local EmptySocket = false
        local SocketCount = 0;
        local Enchant = ""
        local ItemUpgradeLevel = ""
        
        ItemTip:SetOwner(WorldFrame, 'ANCHOR_NONE');
        ItemTip:ClearLines()
        _G["CCS_ScanningtooltipTexture1"]:SetTexture(nil) -- Gem1
        _G["CCS_ScanningtooltipTexture2"]:SetTexture(nil) -- Gem2
        _G["CCS_ScanningtooltipTexture3"]:SetTexture(nil) -- Gem3
        ItemTip:SetHyperlink(link) 

-------------------
-- Enchant/Upgrade line tooltip detection
-------------------
        -- Create isolated tooltip
        if not CCS_ScanTooltip then
            CCS_ScanTooltip = CreateFrame("GameTooltip", "CCS_ScanTooltip", nil, "GameTooltipTemplate")
            CCS_ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
        end

        -- Normalize helper
        local function norm(t)
            return t and t:gsub("\194\160"," ")
                         :gsub("\226\128\139"," ")
                         :gsub("\239\187\191"," ")
                         :gsub("%s+"," ")
                         :gsub("^%s+","")
                         :gsub("%s+$","") or nil
        end

        -- Escape helper for safe Lua patterns
        local function escapePattern(s)
            return s:gsub("([%(%)%.%+%-%*%?%[%]%^%$])", "%%%1")
        end

        -- Build pattern from format string
        local function buildFormatPattern(fmt)
            local pat = escapePattern(fmt)
            pat = pat:gsub("%%d", "%s*%%d+%s*")
            pat = pat:gsub("%%s", "%%S+")
            pat = pat:gsub("%s+", "%%s+")
            return pat
        end

        -- Localized patterns (always needed)
        local CREATED_BY = _G.ITEM_CREATED_BY or "<Made by %s>"
        local CREATED_BY_PATTERN = buildFormatPattern(CREATED_BY)

        local SOULBOUND = _G.ITEM_SOULBOUND or "Soulbound"

        local UPGRADE_FORMAT = _G.ITEM_UPGRADE_FRAME_CURRENT_UPGRADE_FORMAT or "Upgrade Level: %d / %d"
        local UPGRADE_PATTERN = buildFormatPattern(UPGRADE_FORMAT)
        local UPGRADE_FALLBACK_PATTERN = "^Upgrade%s+Level%s*:%s*%d+%s*/%s*%d+$"

        local DURABILITY_FORMAT = _G.DURABILITY_TEMPLATE or "Durability %d / %d"
        local DURABILITY_PATTERN = buildFormatPattern(DURABILITY_FORMAT)
        local DURABILITY_FALLBACK_PATTERN = "^Durability%s+%d+%s*/%s*%d+$"

        local REQUIRES_LEVEL_FORMAT = _G.ITEM_MIN_LEVEL or "Requires Level %d"
        local REQUIRES_LEVEL_PATTERN = buildFormatPattern(REQUIRES_LEVEL_FORMAT)

        local ITEM_LEVEL_FORMAT = _G.ITEM_LEVEL or "Item Level %d"
        local ITEM_LEVEL_PATTERN = buildFormatPattern(ITEM_LEVEL_FORMAT)
        local ITEM_LEVEL_FALLBACK_PATTERN = "^Item%s+Level%s*%d+$"

        local TRANSMOG_HEADER = _G.TRANSMOGRIFIED_HEADER or "Transmogrified to:"
        --local TRANSMOG_FORMAT = _G.TRANSMOGRIFIED or "Transmogrified to:\n%s"

        -- Build patterns
        local TRANSMOG_HEADER_PATTERN = escapePattern(TRANSMOG_HEADER)
        --local TRANSMOG_FORMAT_PATTERN = buildFormatPattern(TRANSMOG_FORMAT)

        -- Only build enchant/reforge patterns if locale is enUS/enGB
        local locale = GetLocale()
        local enchantDetectionEnabled = (locale == "enUS" or locale == "enGB")

        local REFORGE_PATTERN, REFORGED_LINE
        if enchantDetectionEnabled then
            local REFORGE_FORMAT = _G.ITEM_REFORGE_DESCRIPTION or "Reforged from %s"
            REFORGE_PATTERN = buildFormatPattern(REFORGE_FORMAT)
            local reforgedStrings = {
                enUS = "Reforged",
                enGB = "Reforged",
            }
            REFORGED_LINE = reforgedStrings[locale] or "Reforged"
        end

        -- Socket strings vary; a simple contains check is safest
        local function isSocketLine(t)
            return t and (t:find("Socket") or t:find("Prismatic Socket") or t:find("Meta Socket"))
        end

        -- Reforged-from stat tracking
        local reforgedFromStats = {}

        -- Robust stat name extractor
        local function extractStatName(t)
            return t and (
                t:match("^%+?%d[%d%,%.]*%s+([%a%s]+)$") or
                t:match("^%+?%d+%s+([%a%s]+)$")
            ) or nil
        end

        local function isReforgedSourceLine(t)
            if not enchantDetectionEnabled then return false end
            local statName = extractStatName(t)
            return statName and reforgedFromStats[statName] or false
        end

        -- Parse upgrade line into "track current/max"
        local function parseUpgradeLine(t)
            if not t then return nil end
            local track, current, max = t:match("^(.-):%s*(%d+)%s*/%s*(%d+)$")
            if track and current and max then
                return track .. " " .. current .. "/" .. max
            end
            return nil
        end

        -- Line filter: ignore all non-enchant differences
        local function isIgnorableLine(t)
            return not t
                or isSocketLine(t)
                or t:match(CREATED_BY_PATTERN)
                or t:match("^<.->$")
                or t == SOULBOUND
                or t:match(UPGRADE_PATTERN)
                or t:match(UPGRADE_FALLBACK_PATTERN)
                or t:match(DURABILITY_PATTERN)
                or t:match(DURABILITY_FALLBACK_PATTERN)
                or t:match(REQUIRES_LEVEL_PATTERN)
                or t:match(ITEM_LEVEL_PATTERN)
                or t:match(ITEM_LEVEL_FALLBACK_PATTERN)
                or t:match(TRANSMOG_HEADER_PATTERN)         -- NEW
                or (enchantDetectionEnabled and (
                    t:match(REFORGE_PATTERN) or
                    t == REFORGED_LINE or
                    isReforgedSourceLine(t)
                ))
        end

        -- Get item link
        local itemLink = GetInventoryItemLink(unit, slotIndex)
        if itemLink then
            --------------------------------------------------------------------
            -- 1. Always check for upgrade line and item level
            --------------------------------------------------------------------
            local lastLineWasTransmogHeader = false

            CCS_ScanTooltip:ClearLines()
            CCS_ScanTooltip:SetInventoryItem(unit, slotIndex)

            for i = 2, CCS_ScanTooltip:NumLines() do
                local L = _G["CCS_ScanTooltipTextLeft"..i]
                local text = norm(L and L:GetText() or nil)

                if text then
                    -- Transmog skip (header + next line)
                    if text:match(TRANSMOG_HEADER_PATTERN) then
                        lastLineWasTransmogHeader = true
                    elseif lastLineWasTransmogHeader then
                        lastLineWasTransmogHeader = false
                    else
                        -- Normal processing
                        local upgradeLine = parseUpgradeLine(text)
                        if upgradeLine then
                            ItemUpgradeLevel = upgradeLine
                        end

                       --[[ local ilvl = text:match(ITEM_LEVEL:gsub("%%d", "(%%d+)"))
                        if ilvl then
                            itemiLevel = tonumber(ilvl)
                        end --]]
                    end
                end
            end

            --------------------------------------------------------------------
            -- 2. Enchant detection
            --------------------------------------------------------------------
            if enchantDetectionEnabled then
                local enchantId = itemLink:match("item:%d+:(%d+)")
                if enchantId and enchantId ~= "0" then

                    ----------------------------------------------------------------
                    -- 2a. Build base tooltip lines (unenchanted version)
                    ----------------------------------------------------------------
                    local baseLines = {}
                    local baseStatsSeen = {}
                    local baseLink = itemLink:gsub("item:(%d+):%d+", "item:%1:0")

                    local lastLineWasTransmogHeader = false

                    CCS_ScanTooltip:ClearLines()
                    CCS_ScanTooltip:SetHyperlink(baseLink)

                    for i = 2, CCS_ScanTooltip:NumLines() do
                        local L = _G["CCS_ScanTooltipTextLeft"..i]
                        local t = norm(L and L:GetText() or nil)

                        if t then
                            -- Transmog skip
                            if t:match(TRANSMOG_HEADER_PATTERN) then
                                lastLineWasTransmogHeader = true
                            elseif lastLineWasTransmogHeader then
                                lastLineWasTransmogHeader = false
                            else
                                -- Normal processing
                                local src = t:match("Reforged from%s+([%a%s]+)")
                                if src and src ~= "" then
                                    reforgedFromStats[src] = true
                                end

                                local statName = extractStatName(t)
                                if statName then
                                    baseStatsSeen[statName] = true
                                end

                                if not isIgnorableLine(t) then
                                    baseLines[t] = true
                                end
                            end
                        end
                    end

                    ----------------------------------------------------------------
                    -- 2b. Compare equipped tooltip to base tooltip
                    ----------------------------------------------------------------
                    local equippedStatsConsumed = {}
                    local lastLineWasTransmogHeader = false

                    CCS_ScanTooltip:ClearLines()
                    CCS_ScanTooltip:SetInventoryItem(unit, slotIndex)

                    for i = 2, CCS_ScanTooltip:NumLines() do
                        local L = _G["CCS_ScanTooltipTextLeft"..i]
                        local t = norm(L and L:GetText() or nil)

                        if t then
                            -- Transmog skip
                            if t:match(TRANSMOG_HEADER_PATTERN) then
                                lastLineWasTransmogHeader = true
                            elseif lastLineWasTransmogHeader then
                                lastLineWasTransmogHeader = false
                            else
                                -- Normal processing
                                local src = t:match("Reforged from%s+([%a%s]+)")
                                if src and src ~= "" then
                                    reforgedFromStats[src] = true
                                end

                                local statName = extractStatName(t)
                                if statName and baseStatsSeen[statName] and not equippedStatsConsumed[statName] then
                                    equippedStatsConsumed[statName] = true

                                elseif not isIgnorableLine(t) and not baseLines[t] then
                                    Enchant = t
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
-------------------
-- End of the crazy tooltip detection (mostly since blizzard didn't use the enchant line in MOP)
-------------------
        local _, gem1Link = C_Item.GetItemGem(link, 1); 
        local _, gem2Link = C_Item.GetItemGem(link, 2); 
        local _, gem3Link = C_Item.GetItemGem(link, 3); 

        local Gemtex1 = _G["CCS_ScanningtooltipTexture1"]:GetTexture() or nil
        local Gemtex2 = _G["CCS_ScanningtooltipTexture2"]:GetTexture() or nil
        local Gemtex3 = _G["CCS_ScanningtooltipTexture3"]:GetTexture() or nil
        local MISSING_SOCKET = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\missing-socket.png"

        -- Show Missing sockets
        if option("showenchantgemerrors"..suffix) and false then
            if slotIndex == INVSLOT_HEAD or slotIndex == INVSLOT_WRIST or slotIndex == INVSLOT_WAIST then
                Gemtex1 = Gemtex1 or MISSING_SOCKET
            elseif slotIndex == INVSLOT_NECK or slotIndex == INVSLOT_FINGER1 or slotIndex == INVSLOT_FINGER2 then
                Gemtex1 = Gemtex1 or MISSING_SOCKET
                Gemtex2 = Gemtex2 or MISSING_SOCKET
            end
        end
 
        -- Item name info (item name in white as well) [White or Rarity Color, 12]
        if option("showitemname"..suffix) == true then
            if option("itemcolorwhite"..suffix) then Color = "ffffffff" end
            if itemName ~= nil then
                if (string.len(Color) < 8) then Color = "FF"..Color end
                if strlen(itemName) > option("itemnamelength"..suffix) then itemName = format("%." .. option("itemnamelength"..suffix) .. "s", itemName) .. "..." end                
                nameTxt:SetText("|c".. Color .. itemName .. "|r") 
            end
            nameTxt:Show()
        end
        
        -- iLvl information [White] 
        if option("showilvl"..suffix) == true then
            if option("showitemupgrade"..suffix) then 
                if string.len(ItemUpgradeLevel) > 0 then
                    local upr, upg, upb, upalpha = option("itemupgradecolor"..suffix)[1], option("itemupgradecolor"..suffix)[2], option("itemupgradecolor"..suffix)[3], option("itemupgradecolor"..suffix)[4];
                    ItemUpgradeLevel = WrapTextInColor("(" .. ItemUpgradeLevel .. ")", CreateColor(upr, upg, upb, upalpha))
                end
            else
                ItemUpgradeLevel = ""
            end
            
            if displaytoleft and itemiLevel ~= nil then
                ilvlTxt:SetText(ItemUpgradeLevel .." ".. itemiLevel) 
                --ilvlTxt:SetText(ItemUpgradeLevel .. " |cFFffffff" .. itemiLevel .. "|r") 
            elseif itemiLevel ~= nil then
                --ilvlTxt:SetText("|cFFffffff" .. itemiLevel .. " " .. ItemUpgradeLevel .. "|r")
                ilvlTxt:SetText(itemiLevel .." ".. ItemUpgradeLevel) 
            end
            ilvlTxt:Show()
        end
        
        -- Enchant Info [Mint/Red, 10]  (Mint #2afab5)
        if option("showenchants"..suffix) == true then
           
            if Enchant == "" and option("showenchantgemerrors"..suffix) == true and false then
            
                enchantTxt:SetTextColor(1,0,0,1)
            
                -- See if an enchant is missing from a slot. Extra code is to allow us to turn on/off the slots each time blizzard makes a change.
                if slotIndex == 1 then --  "Head" -
                    --Enchant = "<" .. ENSCRIBE .. ": " .. ADDON_MISSING .. ">"                            
                elseif slotIndex == 2 then --  "Neck" !
                elseif slotIndex == 3 then --  "Shoulder"
                elseif slotIndex == 5 then --  "Chest" !
                    Enchant = "<" .. ENSCRIBE .. ": " .. ADDON_MISSING .. ">"            
                elseif slotIndex == 6 then --  "Waist" -
                    --Enchant = "<" .. ENSCRIBE .. ": " .. ADDON_MISSING .. ">"            
                elseif slotIndex == 7 then --  "Legs" -
                    Enchant = "<" .. ENSCRIBE .. ": " .. ADDON_MISSING .. ">"            
                elseif slotIndex == 8 then --  "Feet" !
                    Enchant = "<" .. ENSCRIBE .. ": " .. ADDON_MISSING .. ">"            
                elseif slotIndex == 9 then --  "Wrist" !
                    Enchant = "<" .. ENSCRIBE .. ": " .. ADDON_MISSING .. ">"            
                elseif slotIndex == 10 then --  "Hands" !
                elseif slotIndex == 11 then --  "Finger0" !
                    Enchant = "<" .. ENSCRIBE .. ": " .. ADDON_MISSING .. ">"            
                elseif slotIndex == 12 then --  "Finger1" !
                    Enchant = "<" .. ENSCRIBE .. ": " .. ADDON_MISSING .. ">"            
                elseif slotIndex == 15 then --  "Back" !
                    Enchant = "<" .. ENSCRIBE .. ": " .. ADDON_MISSING .. ">"            
                elseif slotIndex == 16 then --  "MainHand" !
                    Enchant = "<" .. ENSCRIBE .. ": " .. ADDON_MISSING .. ">"            
                elseif slotIndex == 17 and itemType == "Weapon" then --  "SecondaryHand" -
                    Enchant = "<" .. ENSCRIBE .. ": " .. ADDON_MISSING .. ">"            
                end
            end
            if strlen(Enchant) > 100 then Enchant = format("%.75s", Enchant) .. "..." end
            enchantTxt:SetText(Enchant)
            enchantTxt:Show()
        end
        
        -- Display Durability text (white)
        if isPlayer and option("showdurability") == true and durMax ~= nil and durCur ~= nil and durMax > 0 and durCur ~= durMax then
            local DurPercent = string.format("%.f", durCur/durMax*100)
            durabilityTxt:SetText(DurPercent.."%")
            durabilityTxt:Show()
        end

        if isPlayer and option("showdurabilitybar") == true and durMax ~= nil and durCur ~= nil and durMax > 0 and durCur ~= durMax then
            local DurPercent = durCur/durMax
            
            if DurPercent > 0.66 then durbartex:SetColorTexture(0, 1, 0) -- green
            elseif DurPercent > 0.33 then durbartex:SetColorTexture(1, 1, 0) -- yellow
            elseif DurPercent > 0.10 then durbartex:SetColorTexture(1, 0, 0) -- red
            else durbartex:SetColorTexture(1, 0, 0, 0.10) 
            end

            durbar:SetHeight(30*DurPercent)
            durbar:Show()
        end
        
        if option("showgems"..suffix) == true then
            local tooltip, tooltip2, tooltip3 = "", "", ""
            local gemCount = 0
            
            if Gem1 ~= "" or Gemtex1 then gemCount= gemCount+1 end
            if Gem2 ~= "" or Gemtex2 then gemCount= gemCount+1 end
            if Gem3 ~= "" or Gemtex3 then gemCount= gemCount+1 end
            
            if slotIndex == 2 and expacID == LE_EXPANSION_DRAGONFLIGHT then
                gemCount = 3
            end
            
            if gemCount == 1 then
                gemIconframe1:ClearAllPoints()
                gemIconframe1:SetPoint(SubElementSetPoint2, slotFrameName, SubElementSetPoint, -8 * neg, 0)
            elseif gemCount == 2 then
                gemIconframe1:ClearAllPoints()
                gemIconframe2:ClearAllPoints()
                gemIconframe1:SetPoint("TOP"..SubElementSetPoint2, slotFrameName, "TOP"..SubElementSetPoint, -8 * neg, -2)
                gemIconframe2:SetPoint("BOTTOM"..SubElementSetPoint2, slotFrameName, "BOTTOM"..SubElementSetPoint, -8 * neg, 2)
            elseif gemCount == 3 then
                gemIconframe1:ClearAllPoints()
                gemIconframe2:ClearAllPoints()
                gemIconframe3:ClearAllPoints()
                gemIconframe2:ClearAllPoints()
                gemIconframe1:SetPoint("TOP"..SubElementSetPoint2, slotFrameName, "TOP"..SubElementSetPoint, -8 * neg, 4)
                gemIconframe2:SetPoint(SubElementSetPoint2, slotFrameName, SubElementSetPoint, -8 * neg, 0)
                gemIconframe3:SetPoint("BOTTOM"..SubElementSetPoint2, slotFrameName, "BOTTOM"..SubElementSetPoint, -8 * neg, -4)
            end
            
            local Gem1type, Gem2type, Gem3type = 0,0,0
            
            if Gem1 ~= "" then
                local icon = C_Item.GetItemIconByID(Gem1)
                gemIconframe1:SetNormalTexture(icon)
                gemIconframe1:Show()
            elseif Gemtex1 then
                gemIconframe1:SetNormalTexture(Gemtex1)
                if CCS.GemInfo[Gemtex1] then tooltip = CCS.GemInfo[Gemtex1].text else tooltip = ADDON_MISSING end
                gemIconframe1:Show()
            elseif slotIndex == 2 and expacID == LE_EXPANSION_DRAGONFLIGHT and option("showenchants"..suffix) then
                gemIconframe1:SetNormalTexture("Interface\\COMMON\\Indicator-Red.blp")
                tooltip = EMPTY_SOCKET_PRISMATIC .. ": " .. ADDON_MISSING
                gemIconframe1:Show()
            end
            
            if Gem2 ~= "" then
                local icon = C_Item.GetItemIconByID(Gem2)
                gemIconframe2:SetNormalTexture(icon)
                gemIconframe2:Show()
            elseif Gemtex2 then
                gemIconframe2:SetNormalTexture(Gemtex2)
                if CCS.GemInfo[Gemtex2] then tooltip2 = CCS.GemInfo[Gemtex2].text else tooltip2 = ADDON_MISSING end
                gemIconframe2:Show()
            elseif slotIndex == 2 and expacID == LE_EXPANSION_DRAGONFLIGHT and option("showenchants"..suffix) then
                gemIconframe2:SetNormalTexture("Interface\\COMMON\\Indicator-Red.blp")
                tooltip2 = EMPTY_SOCKET_PRISMATIC .. ": " .. ADDON_MISSING
                gemIconframe2:Show()
            end
            
            if Gem3 ~= "" then
                local icon = C_Item.GetItemIconByID(Gem3)
                gemIconframe3:SetNormalTexture(icon)
                gemIconframe3:Show()
            elseif Gemtex3 then
                gemIconframe3:SetNormalTexture(Gemtex3)
                if CCS.GemInfo[Gemtex3] then tooltip3 = CCS.GemInfo[Gemtex3].text else tooltip3 = ADDON_MISSING end
                gemIconframe3:Show()
            elseif slotIndex == 2 and expacID == LE_EXPANSION_DRAGONFLIGHT and option("showenchants"..suffix) then
                gemIconframe3:SetNormalTexture("Interface\\COMMON\\Indicator-Red.blp")
                tooltip3 = EMPTY_SOCKET_PRISMATIC .. ": " .. ADDON_MISSING
                gemIconframe3:Show()
            end
            local GemToolTip = CCS:CreateTooltip("CCSGemTooltip")
            gemIconframe1:SetScript("OnEnter", function() 
                    if gem1Link then
                         CCS.RenderSafeTooltip(GemToolTip, gem1Link, "player")
                    end
            end)
            gemIconframe1:SetScript("OnLeave", function() GemToolTip:Hide() end)
            gemIconframe2:SetScript("OnEnter", function() 
                    if gem2Link then
                         CCS.RenderSafeTooltip(GemToolTip, gem2Link, "player")
                    end
            end)
            gemIconframe2:SetScript("OnLeave", function()  GemToolTip:Hide() end)
            gemIconframe2:SetScript("OnClick", function()  end)
            
            gemIconframe3:SetScript("OnEnter", function() 
                    if gem3Link then
                         CCS.RenderSafeTooltip(GemToolTip, gem3Link, "player")
                    end

            end)
            gemIconframe3:SetScript("OnLeave", function() GemToolTip:Hide() end)
            gemIconframe3:SetScript("OnClick", function()  end) 
        end
        
        if option("showitemcolor"..suffix) then
            local setr, setg, setb, setalpha = option("setitemcolor"..suffix)[1], option("setitemcolor"..suffix)[2], option("setitemcolor"..suffix)[3], option("setitemcolor"..suffix)[4];
            
            if displaytoleft then 
                bgfadertex:SetTexCoord(1,0,0,1)
                
                if itemRarity == 1 then bgfadertex:SetGradient("Horizontal", CreateColor(.5, .5, .5, .4), CreateColor(1, 1, 1, 1))  -- white (Common)
                elseif itemRarity == 2 then bgfadertex:SetGradient("Horizontal", CreateColor(.06, .5, 0, .4), CreateColor(0.12, 1, 0, 1))  -- green (Uncommon)
                elseif itemRarity == 3 then bgfadertex:SetGradient("Horizontal", CreateColor(0, .22, .435, .4), CreateColor(0, 0.44, 0.87, 1)) -- Blue (Rare)
                elseif itemRarity == 4 then bgfadertex:SetGradient("Horizontal", CreateColor(.32, .105, .465, .4), CreateColor(0.64, 0.21, 0.93, 1)) -- Purple (Epic)
                elseif itemRarity == 5 then bgfadertex:SetGradient("Horizontal", CreateColor(.5, .25, 0, .4), CreateColor(1, 0.5, 0, 1)) -- Orange (Legendary)
                elseif itemRarity == 6 then bgfadertex:SetGradient("Horizontal", CreateColor(.45, .4, .25, .4), CreateColor(0.9, 0.8, 0.5, 1)) -- Tan (Artifact)
                elseif itemRarity == 7 then bgfadertex:SetGradient("Horizontal", CreateColor(0, .4, .5, .4), CreateColor(0, 0.8, 1, 1)) -- Light Blue (Heirloom)   
                else bgfadertex:SetGradient("Horizontal", CreateColor(.31, .31, .31, .4), CreateColor(0.62, 0.62, 0.62, 1)) -- gray / poor    
                end
                
                if option("showsetitems"..suffix) and setID then 
                    if option("showsetclasscolor"..suffix) then
                        setr, setg, setb = GetClassColor(select(2, UnitClass(unit)))
                        setalpha = .8
                    end
                    bgfadertex:SetGradient("Horizontal", CreateColor(setr/2, setg/2, setb/2, .4), CreateColor(setr, setg, setb, setalpha)) -- Set Item Color Left Display
                end
                
            else
                if itemRarity == 1 then bgfadertex:SetGradient("Horizontal", CreateColor(1, 1, 1, 1), CreateColor(.5, .5, .5, .4))  -- white (Common)
                elseif itemRarity == 2 then bgfadertex:SetGradient("Horizontal", CreateColor(0.12, 1, 0, 1), CreateColor(.06, .5, 0, .4))  -- green (Uncommon)
                elseif itemRarity == 3 then bgfadertex:SetGradient("Horizontal", CreateColor(0, 0.44, 0.87, 1), CreateColor(0, .22, .435, .4)) -- Blue (Rare)
                elseif itemRarity == 4 then bgfadertex:SetGradient("Horizontal", CreateColor(0.64, 0.21, 0.93, 1), CreateColor(.32, .105, .465, .4)) -- Purple (Epic)
                elseif itemRarity == 5 then bgfadertex:SetGradient("Horizontal", CreateColor(1, 0.5, 0, 1), CreateColor(.5, .25, 0, .4)) -- Orange (Legendary)
                elseif itemRarity == 6 then bgfadertex:SetGradient("Horizontal", CreateColor(0.9, 0.8, 0.5, 1), CreateColor(.45, .4, .25, .4)) -- Tan (Artifact)
                elseif itemRarity == 7 then bgfadertex:SetGradient("Horizontal", CreateColor(0, 0.8, 1, 1), CreateColor(0, .4, .5, .4)) -- Light Blue (Heirloom)   
                else bgfadertex:SetGradient("Horizontal", CreateColor(0.62, 0.62, 0.62, 1), CreateColor(0.62, 0.62, 0.62, .4)) -- gray / poor    
                end
                
                if option("showsetitems"..suffix) and setID then 
                    if option("showsetclasscolor"..suffix) then
                        setr, setg, setb = GetClassColor(select(2, UnitClass(unit)))
                        setalpha = .8
                    end
                    bgfadertex:SetGradient("Horizontal", CreateColor(setr, setg, setb, setalpha), CreateColor(0, 0, 0, .4)) -- Set Item Color Right Display
                end
            end
            bgfader:Show()
        end 
    end

end


local function loopitems()

    for slotIndex = 0,19 do 
        TBCupdateLocationInfo("player", slotIndex, "Character")
    end 
end

---
--- This just allows us to ensure we have all items cached before we loop.
---
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
            --loopitems()
end

local function CCS_ReputationFrame_Update()
    local ks = {ReputationFrame:GetChildren()}
    local gender = UnitSex("player")
    local xtext, factiontext = "", ""

    ReputationListScrollFrame:ClearAllPoints()
    ReputationListScrollFrame:SetPoint("BOTTOMRIGHT", ReputationFrame, "BOTTOMRIGHT", -40, 200)
    ReputationListScrollFrame:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 40, -40)
    
    local upperTex, lowerTex = ReputationListScrollFrame:GetRegions()
    if upperTex then
        upperTex:SetTexture("Interface\\Masks\\SquareMask.BLP")
        upperTex:SetColorTexture(.1, .1, .1, 0.90)
        upperTex:ClearAllPoints()
        upperTex:SetPoint("TOPLEFT", ReputationListScrollFrame, "TOPRIGHT", 4,0)
        upperTex:SetWidth(20)
        
    end
    if lowerTex then
        lowerTex:SetTexture("Interface\\Masks\\SquareMask.BLP")
        lowerTex:SetColorTexture(.1, .1, .1, 0.90)
        lowerTex:ClearAllPoints()
        lowerTex:SetPoint("BOTTOMLEFT", ReputationListScrollFrame, "BOTTOMRIGHT", 4,0)
        lowerTex:SetPoint("TOP", upperTex, "BOTTOM")
        lowerTex:SetWidth(20)
    end
    ReputationFrameFactionLabel:Show()
    ReputationFrameStandingLabel:Show()
    ReputationFrameStandingLabel:SetPoint("TOPLEFT", ReputationFrame, "TOPLEFT", 235, -59)

   
    for _, k in ipairs(ks) do -- Individual Row
        local ks2 = {k:GetChildren()}
        
        if k.index then
            -- TBC-era API
            local name, _, standingID, barMin, barMax, barValue, atWarWith, _, isHeader, _, hasRep, _, _, factionID = GetFactionInfo(k.index)
            local LeftTexture = _G[k:GetName().."ReputationBarLeft"]
            local RightTexture = _G[k:GetName().."ReputationBarRight"]
            local AtWarTexture = _G[k:GetName().."AtWarCheck"] 
            local Highlight1 = _G[k:GetName().."Highlight1"] -- width 256 normally   
            local Highlight2 = _G[k:GetName().."Highlight2"] -- width 17 normally

            k:SetWidth(225)
            
            if LeftTexture then
                LeftTexture:SetTexture("Interface\\Masks\\SquareMask.BLP")
                LeftTexture:SetColorTexture(.15, .15, .15, 0.90)
                LeftTexture:SetWidth(126)
            end
            
            if RightTexture then
                RightTexture:SetDrawLayer("BACKGROUND")
                RightTexture:SetTexture("Interface\\Masks\\SquareMask.BLP")
                RightTexture:SetGradient("Vertical", CreateColor(0, 0, 0, .4), CreateColor(.3, .3, .3, .4)) -- Dark Gray
                RightTexture:SetAlpha(0.9)
                RightTexture:SetWidth(225)                
            end     

            if Highlight1 then  -- need 351 width
                Highlight1:SetWidth(329.1327)
            end
            if Highlight2 then
                Highlight2:SetWidth(21.8673)
            end

            if AtWarTexture then
                local r1 = select(1, AtWarTexture:GetRegions())
                
                AtWarTexture:SetPoint("LEFT", RightTexture, "RIGHT", 3,0)

                if r1 and r1.GetObjectType and r1:GetObjectType() == "Texture" then
                    r1:SetGradient("Vertical", CreateColor(.8, 0, 0, .6), CreateColor(1, 0, 0, 1)) -- Dark Red
                end                    
            end

        end
    end
end

local function CCS_SkillFrame_Update()
    local ks = {SkillFrame:GetChildren()}
    local gender = UnitSex("player")
    local xtext, factiontext = "", ""

    SkillListScrollFrame:ClearAllPoints()
    SkillListScrollFrame:SetPoint("BOTTOMRIGHT", SkillFrame, "BOTTOMRIGHT", -40, 300)
    SkillListScrollFrame:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 40, -40)

    SkillDetailScrollFrame:ClearAllPoints()
    SkillDetailScrollFrame:SetPoint("BOTTOMRIGHT", SkillFrame, "BOTTOMRIGHT", -40, 20)
    SkillDetailScrollFrame:SetPoint("TOPLEFT", SkillListScrollFrame, "BOTTOMLEFT", 0, -8)	
   
    local upperTex, lowerTex = SkillListScrollFrame:GetRegions()
    if upperTex then
        upperTex:SetTexture("Interface\\Masks\\SquareMask.BLP")
        upperTex:SetColorTexture(.1, .1, .1, 0.90)
        upperTex:ClearAllPoints()
        upperTex:SetPoint("TOPLEFT", SkillListScrollFrame, "TOPRIGHT", 4,0)
        upperTex:SetWidth(20)
        
    end
    if lowerTex then
        lowerTex:SetTexture("Interface\\Masks\\SquareMask.BLP")
        lowerTex:SetColorTexture(.1, .1, .1, 0.90)
        lowerTex:ClearAllPoints()
        lowerTex:SetPoint("BOTTOMLEFT", SkillListScrollFrame, "BOTTOMRIGHT", 4,0)
        lowerTex:SetPoint("TOP", upperTex, "BOTTOM")
        lowerTex:SetWidth(20)
    end

    local upperTex2, lowerTex2 = SkillDetailScrollFrame:GetRegions()
    
    if upperTex2 then
        upperTex2:SetTexture("Interface\\Masks\\SquareMask.BLP")
        upperTex2:SetColorTexture(.1, .1, .1, 0.90)
        upperTex2:ClearAllPoints()
        upperTex2:SetPoint("TOPLEFT", SkillDetailScrollFrame, "TOPRIGHT", 4,0)
        upperTex2:SetWidth(20)
        upperTex2:Hide()
    end
    if lowerTex2 then
        lowerTex2:SetTexture("Interface\\Masks\\SquareMask.BLP")
        lowerTex2:SetColorTexture(.1, .1, .1, 0.90)
        lowerTex2:ClearAllPoints()
        lowerTex2:SetPoint("BOTTOMLEFT", SkillDetailScrollFrame, "BOTTOMRIGHT", 4,0)
        lowerTex2:SetPoint("TOP", upperTex, "BOTTOM")
        lowerTex2:SetWidth(20)
        lowerTex2:Hide()        
    end
    local fontname, fontsize, fontoptions = SkillDetailDescriptionText:GetFont()
    SkillDetailDescriptionText:SetFont(fontname, 12, fontoptions)
    SkillDetailScrollChildFrame:SetSize(320, 250)
--[[     
    SkillFrameFactionLabel:Show()
    SkillFrameStandingLabel:Show()
    SkillFrameStandingLabel:SetPoint("TOPLEFT", SkillFrame, "TOPLEFT", 235, -59)

   
    for _, k in ipairs(ks) do -- Individual Row
        local ks2 = {k:GetChildren()}
        
        if k.index then
            -- TBC-era API
            local name, _, standingID, barMin, barMax, barValue, atWarWith, _, isHeader, _, hasRep, _, _, factionID = GetFactionInfo(k.index)
            local LeftTexture = _G[k:GetName().."SkillBarLeft"]
            local RightTexture = _G[k:GetName().."SkillBarRight"]
            local AtWarTexture = _G[k:GetName().."AtWarCheck"] 
            local Highlight1 = _G[k:GetName().."Highlight1"] -- width 256 normally   
            local Highlight2 = _G[k:GetName().."Highlight2"] -- width 17 normally

            k:SetWidth(225)
            
            if LeftTexture then
                LeftTexture:SetTexture("Interface\\Masks\\SquareMask.BLP")
                LeftTexture:SetColorTexture(.15, .15, .15, 0.90)
                LeftTexture:SetWidth(126)
            end
            
            if RightTexture then
                RightTexture:SetDrawLayer("BACKGROUND")
                RightTexture:SetTexture("Interface\\Masks\\SquareMask.BLP")
                RightTexture:SetGradient("Vertical", CreateColor(0, 0, 0, .4), CreateColor(.3, .3, .3, .4)) -- Dark Gray
                RightTexture:SetAlpha(0.9)
                RightTexture:SetWidth(225)                
            end     

            if Highlight1 then  -- need 351 width
                Highlight1:SetWidth(329.1327)
            end
            if Highlight2 then
                Highlight2:SetWidth(21.8673)
            end

            if AtWarTexture then
                local r1 = select(1, AtWarTexture:GetRegions())
                
                AtWarTexture:SetPoint("LEFT", RightTexture, "RIGHT", 3,0)

                if r1 and r1.GetObjectType and r1:GetObjectType() == "Texture" then
                    r1:SetGradient("Vertical", CreateColor(.8, 0, 0, .6), CreateColor(1, 0, 0, 1)) -- Dark Red
                end                    
            end

        end
    end --]]
end

function CCS.HookSetup()

    if CCS.Hooked then return end

        --== Frame Hooks

    if C_AddOns.IsAddOnLoaded("PrettyReps") == false then
        hooksecurefunc(ReputationFrame, "Hide", function() ReputationDetailFrame:Hide(); end )

        local lastUpdate = 0
        local throttle = 0.05   -- seconds between allowed calls

        hooksecurefunc("ReputationFrame_Update", function()
            local now = GetTime()
            if now - lastUpdate < throttle then
                return
            end
            lastUpdate = now
            CCS_ReputationFrame_Update()
        end)
        hooksecurefunc(ReputationFrame, "Show", function() 
                InitializeFrameUpdates();
                CCS_ReputationFrame_Update()
                CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", 65, 0); 
                CharacterNameText:SetPoint("TOP", ReputationFrame, "TOP", 0, -22)
        end)

    end
    --[[
    hooksecurefunc(SkillFrame_Update. "Update", function()
        local now = GetTime()
        if now - lastUpdate < throttle then
            return
        end
        lastUpdate = now
        CCS_SkillFrame_Update()
    end)--]]
    hooksecurefunc(SkillFrame, "Show", function() 
            InitializeFrameUpdates();
            CCS_SkillFrame_Update()
            CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", 65, 0); 
            CharacterNameText:SetPoint("TOP", SkillFrame, "TOP", 0, -22)
            CharacterNameText:SetPoint("TOP", ReputationFrame, "TOP", 0, -22)

    end)  

    hooksecurefunc(PaperDollFrame, "Show", function()  CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", option("hpad")+221, 0); 
                local classDisplayName, class = UnitClass("player");
                local classColorString = RAID_CLASS_COLORS[class].colorStr;
                local level = UnitLevel("player");
                local race = UnitRace("player")
                local text = format("%s %s %s |c%s%s|r", LEVEL, level, race, classColorString, classDisplayName)
                CharacterLevelText:SetText(text);      
                CharacterNameText:SetPoint("TOP", CharacterModelFrame, "TOP", 0, 60)
    
    end)
    hooksecurefunc(PetPaperDollFrame, "Show", function() CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", 65, 0); end)
    hooksecurefunc(PVPFrame, "Show", function() 
            CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", 65, 0); 
            CharacterNameText:SetPoint("TOP", PVPFrame, "TOP", 0, -22)
            end)
            
    hooksecurefunc(CharacterFrame, "Show", function() 
            InitializeFrameUpdates()
            CCS:FireEvent("CCS_EVENT_CSHOW")
            GameTooltip:Hide()
                local classDisplayName, class = UnitClass("player");
                local classColorString = RAID_CLASS_COLORS[class].colorStr;
                local level = UnitLevel("player");
                local race = UnitRace("player")
                local text = format("%s %s %s |c%s%s|r", LEVEL, level, race, classColorString, classDisplayName)
                CharacterLevelText:SetText(text);      
            --hookfix()
    end )
    
    hooksecurefunc(CharacterFrame, "Hide", function() GameTooltip:Hide(); end )
    CCS.Hooked = true
end

-- Module Inspect Init
function TBCinitializeinspectframe()
    if not InspectFrame or not option("show_inspect") then return end
   
    InspectFrame:SetScale(option("sheetscale_inspect") or 1)
    InspectFrame:SetHeight(479+(7*option("vpad_inspect"))) -- Do not allow the frame to get any smaller than the default bliz frame
    InspectFrame:SetWidth(617)
    
    local Bgoffset = 209 + (610 - 540)
    
    InspectFrameInset:ClearAllPoints();
    InspectFrameInset:SetPoint("TOPLEFT", InspectFrame, "TOPLEFT", 4, -60)
    InspectFrameInset:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 610, 0)
    InspectFrameInset:Hide();
    
    InspectFrameBg:SetVertexColor(0,0,0,0);
    InspectFrameBg:ClearAllPoints()
    InspectFrameBg:SetPoint("TOPLEFT", InspectFrame, "TOPLEFT", 0, 0);
    InspectFrameBg:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMRIGHT", 0, 0); --275  .449

    local inspectbg = _G["InspectFrameBgbg"] or CreateFrame("Frame", "InspectFrameBgbg", InspectFrame, BackdropTemplateMixin and "BackdropTemplate")
    local inspectbgtex = _G["CharacterFrameBgbgtex"] or inspectbg:CreateTexture("InspectFrameBgbgtex", "BACKGROUND", nil, 1)    
    local bgr, bgg, bgb, bgalpha = option("bgcolor_inspect")[1], option("bgcolor_inspect")[2], option("bgcolor_inspect")[3], option("bgcolor_inspect")[4];

    inspectbg:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- optional background texture
        edgeFile = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\UI-Tooltip-SquareBorder.blp",        -- thin edge texture
        edgeSize = 16,                                              -- thickness of the border
        insets = { left = 3, right = 3, top = 3, bottom = 3 },      -- inset so content doesn't overlap border
    })

    local borderColor = CCS.StyleColor.border
    inspectbg:SetBackdropBorderColor(unpack(borderColor))   -- purple border    
    
    inspectbg:ClearAllPoints()
    inspectbg:SetAllPoints(InspectFrameBg)
    inspectbg:SetFrameStrata("BACKGROUND")
    inspectbgtex:ClearAllPoints()
    inspectbgtex:SetAllPoints()
    inspectbgtex:SetTexture("Interface\\Masks\\SquareMask.BLP")
    inspectbgtex:SetVertexColor(bgr,bgg,bgb,bgalpha);

    InspectFrameTopTileStreaks:Hide()
    InspectFrameTopRightCorner:Hide()
    InspectFrameBotRightCorner:Hide()
    InspectFrameTopLeftCorner:Hide()
    InspectFrameBotLeftCorner:Hide()
    InspectFrameRightBorder:Hide()    
    InspectFrameLeftBorder:Hide()        
    InspectFrameTopBorder:Hide()        
    InspectFrameBottomBorder:Hide()        
    
    InspectFrameBtnCornerLeft:Hide()        
    InspectFrameBtnCornerRight:Hide()            
    InspectFrameButtonBottomBorder:Hide()            

    InspectFramePortraitFrame:Hide()            
    InspectFrame.PortraitContainer:Hide()            
	
	--InspectFrameCloseButton:SetNormalTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\close.png")
    --InspectFrameCloseButton:SetHighlightTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\close-h.png")
    CCS:SkinBlizzardButton(InspectFrameCloseButton, "x", 26)
    InspectFrameCloseButton:ClearAllPoints();
    InspectFrameCloseButton:SetPoint("TOPRIGHT", InspectFrameBg, "TOPRIGHT", -10, -10)
    InspectFrameCloseButton:SetSize(32, 32)
    InspectFrameCloseButton:SetScale(.5)
--[[    
    if InspectInspectPVPFrame then
        InspectInspectPVPFrame.BG:SetPoint("BOTTOMRIGHT", InspectFrameBg, "BOTTOMRIGHT", -5, 30)
        --InspectInspectPVPFrame.HonorLevel:SetPoint("TOP", InspectInspectPVPFrame, "TOP", 0, -70)
        --InspectInspectPVPFrame.HKs:SetPoint("TOP", InspectInspectPVPFrame, "TOP", 0, -100)
    end
    --]]
	
-------------------------
-- InspectPVPFrame Changes
-------------------------
    regions = { InspectPVPFrame:GetRegions() }
    for i = 1, #regions do
        local r = regions[i]
        if r and r.Hide then
            r:Hide()
        end
    end 
    InspectPVPFrameBackground:SetPoint("BOTTOMRIGHT", InspectFrameBg, "BOTTOMRIGHT", 0, 0)
    InspectPVPFrame:SetPoint("BOTTOMRIGHT", InspectFrameBg, "BOTTOMRIGHT", 0, 0)
    InspectPVPHonor:ClearAllPoints()
    InspectPVPHonor:SetPoint("TOP", InspectPVPFrame, "TOP", 0, -100)
    InspectPVPFrameArena:ClearAllPoints()
    InspectPVPFrameArena:SetPoint("TOP", InspectPVPFrame, "TOP", 0, -160)
    InspectPVPFrameArenaLabel:ClearAllPoints()
    InspectPVPFrameArenaLabel:SetPoint("CENTER",InspectPVPFrameArena,"CENTER",-15,0)

    InspectPVPFrameHonor:ClearAllPoints()
    InspectPVPFrameHonor:SetPoint("BOTTOM", InspectPVPHonor, "TOP", 0, 10)
    InspectPVPFrameHonorLabel:ClearAllPoints()
    InspectPVPFrameHonorLabel:SetPoint("CENTER",InspectPVPFrameHonor,"CENTER",-15,0)
    
    InspectPVPTeam1Standard:SetPoint("LEFT", InspectPVPHonor, "BOTTOMLEFT", -25, -75)
    InspectPVPTeam2Standard:SetPoint("TOPLEFT", InspectPVPTeam1Standard, "BOTTOMLEFT", 0, -20)
    InspectPVPTeam3Standard:SetPoint("TOPLEFT", InspectPVPTeam2Standard, "BOTTOMLEFT", 0, -20)
-- End of InspectPVPFrame	

-------------------------
-- InspectTalentFrame Changes
-------------------------
    InspectTalentFrameTab1:SetPoint("TOPLEFT", InspectTalentFrame, "TOPLEFT", 170, -25)
    InspectTalentFrameScrollFrame:ClearAllPoints()
    InspectTalentFrameScrollFrame:SetPoint("TOPLEFT", InspectTalentFrame, "TOPLEFT", 170, -52)
    InspectTalentFrameScrollFrame:SetPoint("TOPRIGHT", InspectTalentFrame, "TOPRIGHT", -65, -52)
    InspectTalentFrameScrollFrame:SetPoint("BOTTOM", InspectTalentFramePointsBar, "TOP", 0, -10)
    InspectTalentFrameScrollChildFrame:ClearAllPoints()
    InspectTalentFrameScrollChildFrame:SetPoint("TOPLEFT", InspectTalentFrameScrollFrame, "TOPLEFT", 0, 0)
    InspectTalentFrameBackgroundTopLeft:ClearAllPoints()
    InspectTalentFrameBackgroundTopLeft:SetPoint("TOPLEFT", InspectTalentFrame, "TOPLEFT", 50, -52)
    InspectTalentFrameBackgroundTopLeft:SetWidth(256*1.7265625)
    InspectTalentFrameBackgroundTopLeft:SetHeight(256*1.7265625)
    InspectTalentFrameBackgroundTopRight:SetWidth(64*1.7265625)
    InspectTalentFrameBackgroundTopRight:SetHeight(256*1.7265625)
    InspectTalentFrameBackgroundBottomLeft:SetWidth(256*1.7265625)
    InspectTalentFrameBackgroundBottomLeft:SetHeight(128*1.7265625)
    InspectTalentFrameBackgroundBottomRight:SetWidth(64*1.7265625)
    InspectTalentFrameBackgroundBottomRight:SetHeight(128*1.7265625)
    InspectTalentFrameScrollFrameScrollBar:SetPoint("BOTTOMLEFT", InspectTalentFrameScrollFrame, "BOTTOMRIGHT", 6, 26)
    local upperTex, lowerTex = InspectTalentFrameScrollFrame:GetRegions()
    if upperTex then
        upperTex:SetTexture("Interface\\Masks\\SquareMask.BLP")
        upperTex:SetColorTexture(.1, .1, .1, 0.90)
        upperTex:ClearAllPoints()
        upperTex:SetPoint("TOPLEFT", InspectTalentFrameScrollFrame, "TOPRIGHT", 4, 0)
        upperTex:SetWidth(18)
        
    end
    if lowerTex then
        lowerTex:SetTexture("Interface\\Masks\\SquareMask.BLP")
        lowerTex:SetColorTexture(.1, .1, .1, 0.90)
        lowerTex:ClearAllPoints()
        lowerTex:SetPoint("BOTTOMLEFT", InspectTalentFrameScrollFrame, "BOTTOMRIGHT", 4,16)
        lowerTex:SetPoint("TOP", upperTex, "BOTTOM")
        lowerTex:SetWidth(18)
    end
-- End of InspectTalentFrame	
    
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
    
    InspectNameFrame:ClearAllPoints()
    InspectNameFrame:SetPoint("TOP", InspectFrame, "TOP", 0, -4)
    
    InspectFrameTitleBg:Hide()
    InspectFrameTitleText:ClearAllPoints();
    InspectFrameTitleText:SetPoint("TOP", InspectFrame, "TOP", 0, 0)
    InspectFrameTitleText:SetPoint("LEFT", InspectFrame, "LEFT", 50, 0)
    InspectFrameTitleText:SetPoint("RIGHT", InspectFrameInset, "RIGHT", -40, 0)
    
    InspectFrameTitleText:SetFont(option("fontname_nametitle_inspect") or CCS.fontname, option("fontsize_nametitle_inspect") or 12, "OUTLINE")
    InspectFrameTitleText:SetTextColor(
        option("fontcolor_nametitle_inspect")[1] or 1,
        option("fontcolor_nametitle_inspect")[2] or 1,
        option("fontcolor_nametitle_inspect")[3] or 1,
        option("fontcolor_nametitle_inspect")[4] or 1
    )
    
    InspectLevelText:ClearAllPoints()
    InspectLevelText:SetPoint("TOP", InspectNameFrame, "BOTTOM", 0, -5)
    
    InspectLevelText:SetFont(option("fontname_levelclass_inspect") or CCS.fontname, option("fontsize_levelclass_inspect") or 11, "OUTLINE")
    
    InspectFrame.NineSlice:ClearAllPoints()
    InspectFrame.NineSlice:SetPoint("TOPLEFT", InspectFrame, "TOPLEFT", 0, 0)
    InspectFrame.NineSlice:SetPoint("BOTTOMRIGHT", InspectFrame, "BOTTOMLEFT", 579, 0)
    InspectFrame.NineSlice:Hide()
    InspectFramePortrait:Hide()
        
    InspectModelFrameBorderBottom:Hide()
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
	InspectRangedSlot:ClearAllPoints()
    InspectRangedSlot:SetPoint("TOPLEFT", InspectMainHandSlot, "BOTTOMLEFT", 0, -5)
	
	
    local mh_region = select(13, InspectMainHandSlot:GetRegions())
    if mh_region and mh_region.GetObjectType and mh_region:GetObjectType() == "Texture" then
        mh_region:Hide()
    end    
    local oh_region = select(13, InspectSecondaryHandSlot:GetRegions())
    if oh_region and oh_region.GetObjectType and oh_region:GetObjectType() == "Texture" then
        oh_region:Hide()
    end    

    local Height = 359+(7*option("vpad_inspect"))  -- Hard code it for now
    local Left = 120  -- Hard code it for now
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


    InspectModelFrame:SetPoint("LEFT", InspectFrameBg, "LEFT", Left+(Bgoffset-277)/2, -20);
    InspectModelFrame:SetFrameLevel(2)
    InspectModelFrame:Show();
    InspectModelFrameRotateRightButton:ClearAllPoints()
    InspectModelFrameRotateRightButton:SetPoint("TOP", InspectModelFrame, "TOP", 0, 0)
    InspectModelFrameRotateRightButton:Hide()
    InspectModelFrameRotateLeftButton:Hide()    

    inspectmodbg:ClearAllPoints()
    if inspectmodbg:GetParent() == nil then
        inspectmodbg:SetParent(InspectModelFrame)
    end
    inspectmodbg:SetPoint("TOPLEFT", InspectHeadSlot, "TOPLEFT", 0, 0)
    inspectmodbg:SetPoint("RIGHT", InspectHandsSlot, "RIGHT", 0, 0)    
    inspectmodbg:SetPoint("BOTTOM", InspectMainHandSlot, "BOTTOM", 0, 0)        
    inspectmodbg:SetFrameStrata("BACKGROUND")
    inspectmodbg:SetFrameLevel(100)
    ChangeInspectModelBg()

end

-- Module Initialization
function module:Initialize()
    -- Set up the character sheet for the current player
    local scaling = option("sheetscale") or 1
    local Bgoffset = option("hpad")

    CharacterFrame:SetHeight(479+(7*option("vpad"))) -- Do not allow the frame to get any smaller than the default bliz frame
    --CharacterFrame:SetWidth(598+Bgoffset)
    CharacterFrame:SetScale(scaling); 

    local CharacterFrameBg = _G["CharacterFrameBg"] or CreateFrame("Frame", "CharacterFrameBg", CharacterFrame, BackdropTemplateMixin and "BackdropTemplate")   

    CharacterFrameBg:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- optional background texture
    })
    CharacterFrameBg:SetBackdropColor(0.1, 0.1, 0.1, 0.1)  -- match your dark grey background
    
    CharacterFrameBg:ClearAllPoints()
    CharacterFrameBg:SetAllPoints()
    CharacterFrameBg:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 7, 0);
    --CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", 0, 0); --279  .449
    CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", Bgoffset+221, 0); --279   (344)
    CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", 65, 0); --279  .449
 
    CharacterFrameTab1:ClearAllPoints()
    CharacterFrameTab1:SetPoint("TOPLEFT", CharacterFrame, "BOTTOMLEFT", 11, 2)
    CharacterNameFrame:SetPoint("TOP", CharacterModelFrame, "TOP", 0, 60)
    
    if not option("showcharacterstats") then
        CharacterAttributesFrame:ClearAllPoints()
        CharacterAttributesFrame:SetPoint("RIGHT",CharacterFrameBg, "RIGHT", -25, 0)    

        PlayerStatRightTop:ClearAllPoints()
        PlayerStatRightTop:SetPoint("TOPRIGHT", PlayerStatLeftBottom, "BOTTOMRIGHT", 0, -30)

        CharacterResistanceFrame:ClearAllPoints()
        CharacterResistanceFrame:SetPoint("BOTTOMLEFT",CharacterAttributesFrame, "TOPLEFT", 0, 10)        
    end
    
--    local charbg = _G["CharacterFrameBgbg"] or CreateFrame("Frame", "CharacterFrameBgbg", CharacterFrame)
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
    
    charbg:ClearAllPoints()
    charbg:SetAllPoints(CharacterFrameBg)
    charbg:SetFrameStrata("BACKGROUND")
    charbgtex:ClearAllPoints()
    charbgtex:SetAllPoints()
    charbgtex:SetTexture("Interface\\Masks\\SquareMask.BLP")
    charbgtex:SetVertexColor(bgr,bgg,bgb,bgalpha);

    CCS:SkinBlizzardButton(CharacterFrameCloseButton, "x", 26)
    CharacterFrameCloseButton:ClearAllPoints();
    CharacterFrameCloseButton:SetPoint("TOPRIGHT", CharacterFrameBg, "TOPRIGHT", -10, -10)
    CharacterFrameCloseButton:SetSize(32, 32)
    CharacterFrameCloseButton:SetScale(.5)
    
    local CCSsetbtn = _G["CCSsetbtn"] or CreateFrame("Button", "CCSsetbtn", CharacterFrame)
    CCSsetbtn:SetSize(32, 32)
    CCSsetbtn:SetPoint("TOPRIGHT", CharacterFrameCloseButton, "TOPLEFT", -5, 0)
    CCSsetbtn:SetScale(.5)
    CCS:ApplyIconStyle(CCSsetbtn, "gear", 32)    
    --CCSsetbtn:SetNormalTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\settings.png")
    --CCSsetbtn:SetHighlightTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\settings-h.png")
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
--[[    
    CharacterFrameTitleText:ClearAllPoints();
    CharacterFrameTitleText:SetPoint("TOP", CharacterFrame, "TOP", 0, -5)
    CharacterFrameTitleText:SetPoint("LEFT", CharacterFrame, "LEFT", 50, 0)
    CharacterFrameTitleText:SetPoint("RIGHT", CharacterFrameInset.Bg, "RIGHT", -40, 0)
    CharacterFrameTitleText:SetFont( option("fontname_nametitle") or CCS.fontname, (option("fontsize_nametitle") or 12) , CCS.textoutline)
    CharacterFrameTitleText:SetTextColor(
        option("fontcolor_nametitle")[1] or 1,
        option("fontcolor_nametitle")[2] or 1,
        option("fontcolor_nametitle")[3] or 1,
        option("fontcolor_nametitle")[4] or 1
    )
--]]

-------------------------
-- PaperDollFrame Changes
-------------------------
    local regions = { PaperDollFrame:GetRegions() }
    for i = 1, #regions do
        local r = regions[i]
        if r and r.Hide then
            r:Hide()
        end
    end 
-------------------------
-- PetPaperDollFrame Changes
-------------------------
    regions = { PetPaperDollFrame:GetRegions() }
    for i = 1, #regions do
        local r = regions[i]
        if r and r.Hide then
            r:Hide()
        end
    end 
    PetPaperDollCloseButton:Hide()
    PetPaperDollFrame:ClearAllPoints()
    PetPaperDollFrame:SetPoint("TOPLEFT", CharacterFrameBg, "TOPLEFT", 0, 0)
    PetPaperDollFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 0)
    PetModelFrame:ClearAllPoints()
    PetModelFrame:SetPoint("TOPLEFT", PetPaperDollFrame, "TOPLEFT", 40, -100)
    PetModelFrame:SetPoint("BOTTOMRIGHT", PetPaperDollFrame, "RIGHT", -40, -100)    
    PetNameText:ClearAllPoints()
    PetNameText:SetPoint("TOP", PetPaperDollFrame, "TOP",0,-20)
    PetLoyaltyText:Show()
    PetLevelText:Show()
    PetAttributesFrame:ClearAllPoints()    
    PetAttributesFrame:SetPoint("BOTTOM", PetPaperDollFrame, "BOTTOM", 0, 100)
    PetResistanceFrame:ClearAllPoints()
    PetResistanceFrame:SetPoint("BOTTOMLEFT",PetAttributesFrame,"TOPLEFT",0,0)
    PetMagicResFrame1:ClearAllPoints()
    PetMagicResFrame2:ClearAllPoints()    
    PetMagicResFrame3:ClearAllPoints()    
    PetMagicResFrame4:ClearAllPoints()    
    PetMagicResFrame5:ClearAllPoints()    
    PetMagicResFrame1:SetPoint("BOTTOMLEFT",PetResistanceFrame,"BOTTOMLEFT",30,3)
    PetMagicResFrame2:SetPoint("LEFT",PetMagicResFrame1,"RIGHT",3,0)
    PetMagicResFrame3:SetPoint("LEFT",PetMagicResFrame2,"RIGHT",3,0)
    PetMagicResFrame4:SetPoint("LEFT",PetMagicResFrame3,"RIGHT",3,0)
    PetMagicResFrame5:SetPoint("LEFT",PetMagicResFrame4,"RIGHT",3,0)
    PetPaperDollFrameExpBar:ClearAllPoints()
    PetPaperDollFrameExpBar:SetPoint("BOTTOM", PetPaperDollFrame,"BOTTOM", 0, 50)
    PetTrainingPointText:ClearAllPoints()
    PetTrainingPointText:SetPoint("BOTTOM", PetPaperDollFrameExpBar, "TOP", 40, 10)

    local petmodbgtex = _G["PetModFrameBgTex"] or PetModelFrame:CreateTexture("PetModFrameBgTex", "BACKGROUND", nil, 1)    
    petmodbgtex:SetAllPoints()
    petmodbgtex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\MOTHERtalenttree.BLP")
    petmodbgtex:SetTexCoord(0, 0.69, 0, 0.87)
    petmodbgtex:SetVertexColor(0.4, 0, 0.4, 0.9)
    PetModelFrameRotateRightButton:ClearAllPoints()
    PetModelFrameRotateRightButton:SetPoint("BOTTOMRIGHT", PetModelFrame, "TOP", -3, -10)
    PetPaperDollPetInfo:ClearAllPoints()
    PetPaperDollPetInfo:SetPoint("RIGHT", PetAttributesFrame, "LEFT", -5, 0)
-------------------------
-- ReputationFrame Changes
-------------------------
    regions = { ReputationFrame:GetRegions() }
    for i = 1, #regions do
        local r = regions[i]
        if r and r.Hide then
            r:Hide()
        end
    end 
    ReputationDetailFrame:SetFrameStrata("HIGH")
    ReputationDetailFrame:ClearAllPoints()
    ReputationDetailFrame:SetPoint("BOTTOMLEFT", ReputationFrame, "BOTTOMLEFT", 20, 3)
    
-------------------------
-- SkillFrame Changes
-------------------------
    regions = { SkillFrame:GetRegions() }
    for i = 1, #regions do
        local r = regions[i]
        if r and r.Hide then
            r:Hide()
        end
    end 

    SkillFrameCancelButton:Hide()
    SkillFrame:ClearAllPoints()
    SkillFrame:SetPoint("TOPLEFT", CharacterFrameBg, "TOPLEFT", 0, 0)
    SkillFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 0)

    Mixin(SkillListScrollFrame, BackdropTemplateMixin)
    SkillListScrollFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- optional background texture
        edgeFile = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\UI-Tooltip-SquareBorder.blp",        -- thin edge texture
        edgeSize = 8,                                              -- thickness of the border
        insets = { left = 3, right = -3, top = 3, bottom = -3 },
    })
    local borderColor = CCS.StyleColor.border    
    SkillListScrollFrame:SetBackdropBorderColor(unpack(borderColor))   -- purple border
    SkillListScrollFrame.TopLeftCorner:SetPoint("TOPLEFT", SkillListScrollFrame, "TOPLEFT", -15, 0)
    SkillListScrollFrame.BottomLeftCorner:SetPoint("BOTTOMLEFT", SkillListScrollFrame, "BOTTOMLEFT", -15, 0)    
    SkillListScrollFrame:SetBackdropColor(0.4, 0, 0.4, 0.9)

    Mixin(SkillDetailScrollFrame, BackdropTemplateMixin)
    SkillDetailScrollFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- optional background texture
        edgeFile = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\UI-Tooltip-SquareBorder.blp",        -- thin edge texture
        edgeSize = 8,                                              -- thickness of the border
        insets = { left = 3, right = -3, top = 3, bottom = -3 },
    })
    SkillDetailScrollFrame:SetBackdropBorderColor(unpack(borderColor))   -- purple border
    SkillDetailScrollFrame.TopLeftCorner:SetPoint("TOPLEFT", SkillDetailScrollFrame, "TOPLEFT", -15, 0)
    SkillDetailScrollFrame.BottomLeftCorner:SetPoint("BOTTOMLEFT", SkillDetailScrollFrame, "BOTTOMLEFT", -15, 0)    
    SkillDetailScrollFrame:SetBackdropColor(0.4, 0, 0.4, 0.9)


-------------------------
-- PVPFrame Changes
-------------------------
    regions = { PVPFrame:GetRegions() }
    for i = 1, #regions do
        local r = regions[i]
        if r and r.Hide then
            r:Hide()
        end
    end 
    PVPFrameBackground:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 0)
    PVPFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 0)
    PVPHonor:ClearAllPoints()
    PVPHonor:SetPoint("TOP", PVPFrame, "TOP", 0, -100)
    PVPFrameArena:ClearAllPoints()
    PVPFrameArena:SetPoint("TOP", PVPFrame, "TOP", 0, -160)
    PVPFrameArenaLabel:ClearAllPoints()
    PVPFrameArenaLabel:SetPoint("CENTER",PVPFrameArena,"CENTER",-15,0)

    PVPFrameHonor:ClearAllPoints()
    PVPFrameHonor:SetPoint("BOTTOM", PVPHonor, "TOP", 0, 10)
    PVPFrameHonorLabel:ClearAllPoints()
    PVPFrameHonorLabel:SetPoint("CENTER",PVPFrameHonor,"CENTER",-15,0)
    
    PVPTeam1Standard:SetPoint("LEFT", PVPFrameBackground, "LEFT", 50, 35)
    PVPTeam2Standard:SetPoint("LEFT", PVPFrameBackground, "LEFT", 50, -50)
    PVPTeam3Standard:SetPoint("LEFT", PVPFrameBackground, "LEFT", 50, -135)
    
    
    CharacterLevelText:Show()
    CharacterFramePortrait:Hide()

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
    CharacterRangedSlot:ClearAllPoints()
    CharacterRangedSlot:SetPoint("TOPLEFT", CharacterMainHandSlot, "BOTTOMLEFT", 0, -5)
    
    if CharacterSecondaryHandSlot.BottomRightSlotTexture then
        CharacterSecondaryHandSlot.BottomRightSlotTexture:Hide()
    end
    local mh_region = select(14, CharacterMainHandSlot:GetRegions())
    if mh_region and mh_region.GetObjectType and mh_region:GetObjectType() == "Texture" then
        mh_region:Hide()
    end
    
    local ammo_region = select(1, CharacterAmmoSlot:GetRegions())
    if ammo_region and ammo_region.GetObjectType and ammo_region:GetObjectType() == "Texture" then
        ammo_region:Hide()
    end

    
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
        CharacterRangedSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        --CharacterAmmoSlot.IconBorder:SetTexCoord(.8,.8,.8,.8,.8,.8,.8,.8)
        
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
        --CharacterAmmoSlot.IconBorder:SetTexCoord(1,1,1,1,1,1,1,1)
        local ammo_region = select(14, CharacterAmmoSlot:GetRegions())
        if ammo_region and ammo_region.GetObjectType and ammo_region:GetObjectType() == "Texture" then
            ammo_region:SetTexCoord(1,1,1,1,1,1,1,1)
        end

        
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

--[[
    -- Create the character model button
    modelbtn:SetSize(23, 23)
    modelbtn:SetPoint("BOTTOMLEFT", PaperDollItemsFrame, "BOTTOMLEFT", 60, 7)
    modelbtn:SetFrameStrata("HIGH")
    
    if option("hideshowchbtn") == true then
        modelbtn:Hide()
    else
        modelbtn:Show()
    end
    modelbtn:Hide()
    
    local modelbtnfont1 = _G["CCS_clk_Btnfs1"] or modelbtn:CreateFontString("CCS_clk_Btnfs1")
    
    modelbtnfont1:SetPoint("BOTTOM", modelbtn, "TOP", -3 , 2)
    modelbtnfont1:SetFont(option("fontname_showchar") or CCS.fontname, (option("fontsize_showchar") or 10), "OUTLINE")
    modelbtnfont1:SetTextColor(
        option("fontcolor_showchar")[1] or 1,
        option("fontcolor_showchar")[2] or 1,
        option("fontcolor_showchar")[3] or 1,
        option("fontcolor_showchar")[4] or 1
    )
    
    modelbtnfont1:SetText(MOUNT_JOURNAL_PLAYER)
    modelbtnfont1:SetWordWrap(true)
    modelbtn:SetNormalTexture("Interface\\Calendar\\MeetingIcon.blp")
    modelbtn:SetScript("OnEnter", function(self) 
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
            GameTooltip:AddDoubleLine("", nil, 1, 1, 1, 1, 1, 1) 
            GameTooltip:Show()
    end)
    modelbtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    modelbtn:SetScript("OnClick", function()
            if not InCombatLockdown() then 
                Clicky() 
            else
                PlaySound(8959)
                RaidNotice_AddMessage(RaidBossEmoteFrame, format("%s", ERR_AFFECTING_COMBAT), ChatTypeInfo["SYSTEM"])
            end 
    end)
    --]]
    modbg:ClearAllPoints()
    modbg:SetPoint("TOPLEFT", CharacterHeadSlot, "TOPLEFT", 0, 0)
    modbg:SetPoint("RIGHT", CharacterHandsSlot, "RIGHT", 0, 0)    
    modbg:SetPoint("BOTTOM", CharacterRangedSlot, "BOTTOM", 0, 0)        
    modbg:SetFrameStrata("LOW")
    modbg:SetFrameLevel(50)
    ChangeModelBg()
    
    if option("hidemodelbg") then
        modbg:Hide()
    else
        modbg:Show()
    end
    
    local Height = 520  -- Hard code it for now
    local Left = 120  -- Hard code it for now
    CharacterModelFrame:ClearAllPoints();
    CharacterModelFrame:SetHeight(Height)
    CharacterModelFrame:SetWidth(Height/CCS.ModelAspect)
    CharacterModelFrame:SetPoint("LEFT", CharacterFrameBg, "LEFT", Left+(Bgoffset-277)/2, -20);
    CharacterModelFrame:SetFrameLevel(2)
    CharacterModelFrame:Show();
    CharacterModelFrameRotateRightButton:ClearAllPoints()
    CharacterModelFrameRotateRightButton:SetPoint("TOP", CharacterModelFrame, "TOP", 0, 0)
    CharacterModelFrameRotateRightButton:Hide()
    CharacterModelFrameRotateLeftButton:Hide()    

	--CharacterModelFrame:ClearAllPoints()
	--CharacterModelFrame:SetPoint("TOPLEFT", CharacterHeadSlot, "BOTTOMLEFT",0,-18.5)
	--CharacterModelFrame:SetPoint("RIGHT", CharacterLegsSlot, "RIGHT",0,0)	
	--CharacterModelFrame:SetPoint("BOTTOM", CharacterMainHandSlot, "TOP",0,0)		

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


-- Loop through the Paperdoll Items and create/display information
local function TBCloopinspectitems()

    if not option("show_inspect") or InspectFrame.unit == nil then return end
      
    local unit = InspectFrame.unit
 
    for slotIndex = 0,18 do 
        if slotIndex ~= 4 then
            local itemLink = GetInventoryItemLink(unit, slotIndex)
            local itemID = itemLink and tonumber(itemLink:match("item:(%d+)"))

            if itemID then
                local texture = select(10, C_Item.GetItemInfo(itemID))
                if texture then
                    TBCupdateLocationInfo(unit, slotIndex, "Inspect")
                else
                    local slotFrameName = CCS.getSlotFrameName(slotIndex, "Inspect")
                    _G[slotFrameName]:RegisterEvent("GET_ITEM_INFO_RECEIVED")
                    _G[slotFrameName]:SetScript("OnEvent", function(self, event, arg)
                        if event == "GET_ITEM_INFO_RECEIVED" and arg == itemID then
                            TBCupdateLocationInfo(unit, slotIndex, "Inspect")
                            self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
                        end
                    end)
                end
            end
        end
    end 

    --Create Ilvl Frame and populate
    local iLvl = CCS.GetAverageItemLevel(unit)
    --local iLvl = CCS.GetInspectItemLevel(unit) 
    local ilvlTxt = _G["InspectFrameilvlfs"] or _G["InspectPaperDollFrame"]:CreateFontString("InspectFrameilvlfs")
    local color = "ffffff"
    
    if iLvl == nil then return true end
    
    color = CCS:GetAverageEquippedRarityHex(unit) or "ffffff"
    
    ilvlTxt:SetPoint("TOP", _G["InspectLevelText"], "BOTTOM", 0, -10) 
    ilvlTxt:SetFont(option("fontname_inspect_ilvl") or CCS.fontname, option("fontsize_inspect_ilvl") or 20, "OUTLINE")
    
    ilvlTxt:SetText("|cFF".. color .. format("%.2f", iLvl or "") .. "|r")
    ilvlTxt:SetShown(option("showilvl_inspect"))
end 

-- Define the event handler function for this module
function CCS.TBCCharacterSheetEventHandler(event, ...)
    local arg1 = ...

    if CCS.GetCurrentVersion() ~= CCS.TBC then return end 

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
        TryLoopItems()
        if not CCS.characterUpdatePending then
            CCS.characterUpdatePending = true
            C_Timer.After(0.2, function()
                CCS.characterUpdatePending = false
                TryLoopItems()
            end)
        end
        return true
    end
    if (not CharacterFrame or not CharacterFrame:IsVisible()) and event ~= "INSPECT_READY" then return end

    if event == "PLAYER_EQUIPMENT_CHANGED" then
        TryLoopItems()
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
        CCS_ReputationFrame_Update()
        if PaperDollFrame and PaperDollFrame:IsVisible() then 
            CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", option("hpad")+221, 0);
        end
        return true
    elseif event == "CCS_EVENT_CSHOW" then

        if not CCS.characterUpdatePending then
            CCS.characterUpdatePending = true
            C_Timer.After(0, function()
                CCS.characterUpdatePending = false
                TryLoopItems()
                ccs_cshow()
            end)
        end
        return true
    elseif event == "QUEST_ACCEPTED" and arg1 and CCS.Paragon_Factions[arg1] and C_Reputation.GetFactionDataByID(CCS.Paragon_Factions[arg1].factionID) then
        local name = C_Reputation.GetFactionDataByID(CCS.Paragon_Factions[arg1].factionID).name
        local text = GetQuestLogCompletionText(C_QuestLog.GetLogIndexForQuestID(arg1))
        ShowToast(name, text)

    elseif event == "INSPECT_READY" and InspectFrame ~= nil and InspectFrame.unit ~= nil then
        if not CCS.inspectUpdatePending then
            CCS.inspectUpdatePending = true
            InspectFrame:SetAlpha(0)
            InspectModelFrame:SetAlpha(0)
            C_Timer.After(0.1, function()
                CCS.inspectUpdatePending = false
                TBCinitializeinspectframe()
                TBCloopinspectitems()
                InspectFrame:SetAlpha(1)
                InspectModelFrame:SetAlpha(1)
            end)
        end
        return true
    else 
        if not CCS.characterUpdatePending then
            CCS.characterUpdatePending = true
            loopitems()
            C_Timer.After(0.2, function()
                CCS.characterUpdatePending = false
                loopitems()
            end)
        end
        return true
    end
end

local function UpdateMoveSpeed()

    local btnfont2 = _G["CSPbtn7fs2"]
    if not btnfont2 or not option("showcharacterstats") then return end
    
    local currentSpeed, runSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player");
    runSpeed = runSpeed/BASE_MOVEMENT_SPEED*100;
    flightSpeed = flightSpeed/BASE_MOVEMENT_SPEED*100;
    swimSpeed = swimSpeed/BASE_MOVEMENT_SPEED*100;
    currentSpeed = currentSpeed/BASE_MOVEMENT_SPEED*100;
    local speed = runSpeed;
    
    if (UnitInVehicle("player")) then
        local vehicleSpeed = GetUnitSpeed("Vehicle")/BASE_MOVEMENT_SPEED*100;
        speed = vehicleSpeed
    elseif IsSwimming("player") then speed = swimSpeed;
    elseif UnitOnTaxi("player") then speed = currentSpeed;
    elseif IsFlying("player") then speed = flightSpeed;
    end
    btnfont2:SetText(format("%.0f%%", speed))
    
end

local function showrow(row)
    if row == nil then return false end
    
    if row == 1 then return option("show_headers") and option("show_basestats")
    elseif row == 2 then return option("show_basestats") -- Strength
    elseif row == 3 then return option("show_basestats") -- Agility
    elseif row == 4 then return option("show_basestats") -- Stamina
    elseif row == 5 then return option("show_basestats") -- Intellect
    elseif row == 6 then return option("show_basestats") -- Spirit
    elseif row == 7 then return option("show_basestats") -- Movement Speed
    elseif row == 8 then return option("show_headers") and option("show_melee_stats") 
    elseif row == 9 then return option("show_melee_stats")
    elseif row == 10 then return option("show_melee_stats")
    elseif row == 11 then return option("show_melee_stats")
    elseif row == 12 then return option("show_melee_stats")
    elseif row == 13 then return option("show_melee_stats")
    elseif row == 14 then return option("show_melee_stats")
    elseif row == 15 then return option("show_headers") and option("show_ranged_stats")
    elseif row == 16 then return option("show_ranged_stats")
    elseif row == 17 then return option("show_ranged_stats")
    elseif row == 18 then return option("show_ranged_stats")
    elseif row == 19 then return option("show_ranged_stats")
    elseif row == 20 then return option("show_ranged_stats")
    elseif row == 21 then return option("show_headers") and option("show_spell_stats")
    elseif row == 22 then return option("show_spell_stats")
    elseif row == 23 then return option("show_spell_stats")
    elseif row == 24 then return option("show_spell_stats")
    elseif row == 25 then return option("show_spell_stats")
    elseif row == 26 then return option("show_spell_stats")
    elseif row == 27 then return option("show_spell_stats")
    elseif row == 28 then return option("show_headers") and option("show_defenses_stats")
    elseif row == 29 then return option("show_defenses_stats")
    elseif row == 30 then return option("show_defenses_stats")
    elseif row == 31 then return option("show_defenses_stats")
    elseif row == 32 then return option("show_defenses_stats")
    elseif row == 33 then return option("show_defenses_stats")
    elseif row == 34 then return option("show_defenses_stats") -- Movement Speed
    end
    
    return false
end

function CCS:RestoreCharacterStatsPane()
    if true then return end
    CharacterStatsPane.ItemLevelCategory:SetPoint("TOP", CharacterStatsPane, "TOP", -3, 2)
    CharacterStatsPane.ClassBackground:SetAlpha(1)

    -- Re-register default events
    CharacterStatsPane:RegisterUnitEvent("UNIT_STATS", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_RESISTANCES", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_ATTACK_POWER", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_RANGED_ATTACK_POWER", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_DAMAGE", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_AURA", "player")
    CharacterStatsPane:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")

    CharacterStatsPane:RegisterEvent("PLAYER_LEVEL_UP")
    CharacterStatsPane:RegisterEvent("PLAYER_ENTERING_WORLD")
    CharacterStatsPane:RegisterEvent("COMBAT_RATING_UPDATE")
    CharacterStatsPane:RegisterEvent("MASTERY_UPDATE")
    CharacterStatsPane:RegisterEvent("SPEED_UPDATE")
    CharacterStatsPane:RegisterEvent("LIFESTEAL_UPDATE")
    CharacterStatsPane:RegisterEvent("AVOIDANCE_UPDATE")
    CharacterStatsPane:RegisterEvent("PLAYER_TALENT_UPDATE")
    CharacterStatsPane:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    CharacterStatsPane:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
    CharacterStatsPane:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    CharacterStatsPane:RegisterEvent("UNIT_MODEL_CHANGED")
    if _G["CCS_stat_sf"] then _G["CCS_stat_sf"]:Hide() end
end

local function GetStatColorText(tmp_stat_value, effectiveStat, posBuff, negBuff, tt_name)
	local btnfont2 = ""
    effectiveStat = BreakUpLargeNumbers(effectiveStat)
	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		btnfont2 = effectiveStat;
        tt_name = effectiveStat
	else 
		tt_name = tt_name..effectiveStat;
		if ( posBuff > 0 or negBuff < 0 ) then
			tt_name = tt_name.." ("..(tmp_stat_value - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tt_name = tt_name..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tt_name = tt_name..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tt_name = tt_name..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end

		if ( negBuff < 0 ) then
			btnfont2 = RED_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE;
		else
			btnfont2 = GREEN_FONT_COLOR_CODE..effectiveStat..FONT_COLOR_CODE_CLOSE;
		end
	end   
	return btnfont2, tt_name		
end


function InitializeStats()
    if C_AddOns.IsAddOnLoaded("DejaClassicStats") == true then return end

    local Width = 210 -- 230  
    local Height = 22
    local yOffset = 2.3
    local r, g, b, alpha =1,1,1,1                 
   -- print(date("%H:%M:%S") .. format(".%03d", (GetTime() * 1000) % 1000), "your message")
   
    if option("showcharacterstats") then
        C_CVar.SetCVar("breakUpLargeNumbers", "1")
        local _, _, classID = UnitClass("player")
       
        -- Just a little code to create a scrolling frame to house the stats.  That way we can scroll if we resize the character frame.
        local scrollFrame = _G["CCS_stat_sf"] or CreateFrame("ScrollFrame", "CCS_stat_sf", PaperDollFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:ClearAllPoints()
        scrollFrame:SetPoint("TOP", PaperDollFrame, "TOP", 0, -18)
        scrollFrame:SetPoint("LEFT", CharacterHandsSlot, "RIGHT", 30, 0)
        scrollFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", -25, 5)
        scrollFrame:Show()
        
        local scrollChild = _G["CCS_stat_sc"] or CreateFrame("Frame", "CCS_stat_sc", scrollFrame )
        scrollFrame:SetScrollChild(scrollChild)
        scrollChild:SetWidth(Width)
        scrollChild:SetHeight(1)
        if scrollFrame:GetVerticalScrollRange() > 0 then  CCS_stat_sfScrollBar:Show() else CCS_stat_sfScrollBar:Hide() end
        
        -- Ilvl Frame
        do
            local btn = _G["CSPilvl"] or CreateFrame("Button", "CSPilvl", scrollChild)
            local btnfont1
            local btnfontilvl = _G["CSPilvlfs1"] or btn:CreateFontString("CSPilvlfs1")
            local btntex = _G["CSPilvltex"] or btn:CreateTexture("CSPilvltex", "BACKGROUND", nil, 1)
            local avgItemLevelEquipped = CCS.GetAverageItemLevel("player")
            local Color = "a336ed"
            local tt_name = ""
            local tt_desc = ""

            btn:SetParent(scrollChild)
            btn:ClearAllPoints()
            btn:SetSize(Width, Height*(option("fontsize_cilvl") or 20) /20)
            btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
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

                avgItemLevelEquipped = format("%.2f", avgItemLevelEquipped)

                btnfontilvl:SetText(format("|cFF%s%s|r", Color, avgItemLevelEquipped))

                tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL).." "..avgItemLevelEquipped
                tt_name = tt_name .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, avgItemLevelEquipped)
                tt_name = tt_name .. FONT_COLOR_CODE_CLOSE

                tt_desc = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP

                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    GameTooltip:AddDoubleLine(tt_name, nil, 1, 1, 1, 1, 1, 1)
                    GameTooltip:AddLine(tt_desc, nil, nil, nil, true)
                    GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            end)
        end
        do
            -- Health Frame
            local btn = _G["CSPhp"] or CreateFrame("Button", "CSPhp", scrollChild)
            local btnfont1 = _G["CSPhpfs1"] or btn:CreateFontString("CSPhpfs1")
            local btnfont2 = _G["CSPhpfs2"] or btn:CreateFontString("CSPhpfs2")
            local btntex = _G["CSPhptex"] or btn:CreateTexture("CSPhptex", "BACKGROUND", nil, 1)
            local tt_name = ""
            local tt_desc = ""

            local health = UnitHealthMax("player");
            local healthText = BreakUpLargeNumbers(health);
            
            btn:SetParent(scrollChild)
            btn:ClearAllPoints()

            btn:SetSize(Width, Height*(option("fontsize_hppower") or 17)/17)
            btn:SetPoint("TOPLEFT", CSPilvl, "BOTTOMLEFT", 0, -yOffset)            
            btn:SetFrameStrata("HIGH")
            btn:Show()            
            
            btntex:ClearAllPoints()
            btntex:SetAllPoints()
            btntex:SetTexture("Interface\\Masks\\SquareMask.BLP")
            btntex:SetGradient("Horizontal", CreateColor(1, 0, 0, 0.4), CreateColor(1, 0, 0, 0)) -- Red (for HP)
            
            btnfont1:SetPoint("LEFT", CSPhp, "LEFT", 0 ,0)
            btnfont1:SetFont(option("fontname_hppower") or CCS.fontname, (option("fontsize_hppower") or 12), CCS.textoutline)
            if option("showfontshadow") == true then
                btnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                btnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
            end	                                                
            
            btnfont1:SetTextColor(
                option("fontcolor_hppower")[1] or 1,
                option("fontcolor_hppower")[2] or 1,
                option("fontcolor_hppower")[3] or 1,
                option("fontcolor_hppower")[4] or 1
            )
            btnfont1:SetText(HEALTH)
            
            btnfont2:SetPoint("RIGHT", CSPhp, "RIGHT", 0 ,0)
            btnfont2:SetFont(option("fontname_hppower") or CCS.fontname, (option("fontsize_hppower") or 12), CCS.textoutline)
            if option("showfontshadow") == true then
                btnfont2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                btnfont2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
            end	                                                
            
            btnfont2:SetTextColor(
                option("fontcolor_hppower")[1] or 1,
                option("fontcolor_hppower")[2] or 1,
                option("fontcolor_hppower")[3] or 1,
                option("fontcolor_hppower")[4] or 1
            )
            
            btnfont2:SetText(healthText)
            
            tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, HEALTH).." "..healthText..FONT_COLOR_CODE_CLOSE;
            tt_desc = STAT_HEALTH_TOOLTIP;
            
            btn:SetScript("OnEnter", function(self) 
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    GameTooltip:AddDoubleLine(tt_name, nil, 1, 1, 1, 1, 1, 1) 
                    GameTooltip:AddLine(tt_desc, nil, nil, nil, true)   
                    GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        -- Character Power Frame
        do
            local btn = _G["CSPpower"] or CreateFrame("Button", "CSPpower", scrollChild)
            local btnfont1 = _G["CSPpowerfs1"] or btn:CreateFontString("CSPpowerfs1")
            local btnfont2 = _G["CSPpowerfs2"] or btn:CreateFontString("CSPpowerfs2")
            local btntex = _G["CSPpowertex"] or btn:CreateTexture("CSPpowertex", "BACKGROUND", nil, 1)
            local powerType, powerToken, altR, altG, altB = UnitPowerType("player")
            local power = UnitPowerMax("player") or 0;
            local powerText = BreakUpLargeNumbers(power);
            local info = PowerBarColor[powerToken];
            local tt_name = ""
            local tt_desc = ""
            local altR, altG, altB = 0.1, 0.1, 0.1
            if info then altR, altG, altB = info.r, info.g, info.b end
            
            btn:SetParent(scrollChild)
            btn:ClearAllPoints()
            btn:SetFrameStrata("HIGH")
            btn:Show()            
            
            btn:SetSize(Width, Height*(option("fontsize_hppower") or 17)/17)
            btn:SetPoint("TOPLEFT", CSPhp, "BOTTOMLEFT", 0, -yOffset)            
            btn:SetFrameStrata("HIGH")
            btn:Show()            
            
            btntex:ClearAllPoints()
            btntex:SetAllPoints()
            btntex:SetTexture("Interface\\Masks\\SquareMask.BLP")
            btntex:SetGradient("Horizontal", CreateColor(altR, altG, altB, 0.4), CreateColor(altR, altG, altB, 0)) -- Color based on power type
            
            btnfont1:SetPoint("LEFT", btn, "LEFT", 0 ,0)
            btnfont1:SetFont(option("fontname_hppower") or CCS.fontname, (option("fontsize_hppower") or 12), CCS.textoutline)
            if option("showfontshadow") == true then
                btnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                btnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
            end	                                                
            
            btnfont1:SetTextColor(
                option("fontcolor_hppower")[1] or 1,
                option("fontcolor_hppower")[2] or 1,
                option("fontcolor_hppower")[3] or 1,
                option("fontcolor_hppower")[4] or 1
            )
            btnfont1:SetText(CCS.POWER_TYPES_TABLE[powerType])
            
            btnfont2:SetPoint("RIGHT", btn, "RIGHT", 0 ,0)
            btnfont2:SetFont(option("fontname_hppower") or CCS.fontname, (option("fontsize_hppower") or 12), CCS.textoutline)
            if option("showfontshadow") == true then
                btnfont2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                btnfont2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
            end	                                                
            
            btnfont2:SetTextColor(
                option("fontcolor_hppower")[1] or 1,
                option("fontcolor_hppower")[2] or 1,
                option("fontcolor_hppower")[3] or 1,
                option("fontcolor_hppower")[4] or 1
            )
            btnfont2:SetText(powerText)
            
            tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, (powerToken or "")).." "..(powerText or "") .. FONT_COLOR_CODE_CLOSE;
            tt_desc = _G["STAT_"..(powerToken or "") .."_TOOLTIP"];
            
            btn:SetScript("OnEnter", function(self) 
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    GameTooltip:AddDoubleLine(tt_name, nil, 1, 1, 1, 1, 1, 1) 
                    GameTooltip:AddLine(tt_desc, nil, nil, nil, true)   
                    GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end    

        CharacterAttributesFrame:ClearAllPoints()
        CharacterAttributesFrame:SetPoint("LEFT",CharacterFrameBg, "RIGHT", 5, 0)   
        CharacterAttributesFrame:Hide()

        PlayerStatRightTop:ClearAllPoints()
        PlayerStatRightTop:SetPoint("TOPRIGHT", PlayerStatLeftBottom, "BOTTOMRIGHT", 0, -30)

        CharacterResistanceFrame:ClearAllPoints()
        CharacterResistanceFrame:SetPoint("TOPLEFT",_G["CSPpower"], "BOTTOMLEFT", 17, -5)        
        CharacterResistanceFrame:SetParent(_G["CSPpower"])
        MagicResFrame2:ClearAllPoints()
        MagicResFrame2:SetPoint("LEFT",MagicResFrame1, "RIGHT", 1, 0)        

        MagicResFrame3:ClearAllPoints()
        MagicResFrame3:SetPoint("LEFT",MagicResFrame2, "RIGHT", 1, 0)        

        MagicResFrame4:ClearAllPoints()
        MagicResFrame4:SetPoint("LEFT",MagicResFrame3, "RIGHT", 1, 0)        

        MagicResFrame5:ClearAllPoints()
        MagicResFrame5:SetPoint("LEFT",MagicResFrame4, "RIGHT", 1, 0)        
        
        ---------------------------
        --  Start Frame Creation --
        ---------------------------
        local prev_row = scrollChild
        
        for row = 1, 34 do -- just mass creating the frames, textures, and strings, will set them later
            local btn = _G["CSPbtn"..row] or CreateFrame("Button", "CSPbtn"..row, scrollChild)
            local btnfont1 = _G[btn:GetName().."fs1"] or btn:CreateFontString(btn:GetName().."fs1")
            local btnfont2 = _G[btn:GetName().."fs2"] or btn:CreateFontString(btn:GetName().."fs2")
            local btntex = _G[btn:GetName().."tex"] or btn:CreateTexture(btn:GetName().."tex", "BACKGROUND", nil, 1)
            local tooltip = false
            local tt_name = ""
            local tt_desc = ""
            
            if row >= 1 and row <= 7 then
                --r =0.64; g =0.47; b = 0.1 -- Gold
                r       = option("ccs_basestats_color")[1] or 0.64
                g       = option("ccs_basestats_color")[2] or 0.47
                b       = option("ccs_basestats_color")[3] or 0.1
                alpha   = option("ccs_basestats_color")[4] or 0.4
            elseif row >= 8 and row <= 14 then
                --r =0.16; g =0.34; b = 0.08 -- Dark Green
                r       = option("ccs_melee_stats_color")[1] or 0.16
                g       = option("ccs_melee_stats_color")[2] or 0.34
                b       = option("ccs_melee_stats_color")[3] or 0.08
                alpha   = option("ccs_melee_stats_color")[4] or 0.4                
            elseif row >= 15 and row <= 20 then
                --r =0.41; g =0; b = 0 -- Dark Red            
                r       = option("ccs_ranged_stats_color")[1] or 0.41
                g       = option("ccs_ranged_stats_color")[2] or 0
                b       = option("ccs_ranged_stats_color")[3] or 0
                alpha   = option("ccs_ranged_stats_color")[4] or 0.4                                
            elseif row >= 21 and row <= 27 then
                --r =0; g =0.13; b = 0.38 -- Dark Blue            
                r       = option("ccs_spell_stats_color")[1] or 0
                g       = option("ccs_spell_stats_color")[2] or 0.13
                b       = option("ccs_spell_stats_color")[3] or 0.38
                alpha   = option("ccs_spell_stats_color")[4] or 0.4                                
            else
                --r =0.45; g =0.45; b = 0.45-- Gray        
                r       = option("ccs_defenses_color")[1] or 0.45
                g       = option("ccs_defenses_color")[2] or 0.45
                b       = option("ccs_defenses_color")[3] or 0.45
                alpha   = option("ccs_defenses_color")[4] or 0.4                                
                
            end
            
            btn:SetParent(scrollChild)
            btn:ClearAllPoints()
            btntex:SetTexture("Interface\\Masks\\SquareMask.BLP")
            
            -- Header Rows     
            if row == 1 or row == 8 or row == 15 or row == 21 or row == 28 then
                
                btn:SetSize(Width, Height*(option("fontsize_statheaders") or 14)/14)
                if (prev_row == scrollChild) then 
                    btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -3.5*30)
                else
                    btn:SetPoint("TOPLEFT", prev_row, "BOTTOMLEFT", 0, -yOffset)--*3)
                end
                btn:SetFrameStrata("HIGH")
                btntex:SetAllPoints()

                if option("ccs_stats_solidbg") then
                    btntex:SetVertexColor(r, g, b, alpha)
                else
                    btntex:SetGradient("Horizontal", CreateColor(0, 0, 0, alpha/2), CreateColor(r, g, b, alpha))
                end
                
                btnfont1:SetPoint("CENTER", btn, "CENTER", 0 ,0)
                btnfont1:SetFont(option("fontname_statheaders") or CCS.fontname, (option("fontsize_statheaders") or 14), CCS.textoutline)
                if option("showfontshadow") == true then
                    btnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                    btnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                end	                                                
                
                btnfont1:SetText(STAT_CATEGORY_ATTRIBUTES)
                btnfont1:SetTextColor(
                    option("fontcolor_statheaders")[1] or 1,
                    option("fontcolor_statheaders")[2] or 1,
                    option("fontcolor_statheaders")[3] or 1,
                    option("fontcolor_statheaders")[4] or 1
                )
                
                
            else -- all other rows
                btn:SetSize(Width, Height/2*(math.max(option("fontsize_stats"), option("fontsize_statname")) or 10)/10)
                
                if (prev_row == scrollChild) then 
                    btn:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -yOffset*30)
                else
                    btn:SetPoint("TOPLEFT", prev_row, "BOTTOMLEFT", 0, -yOffset)
                end
                
                btn:SetFrameStrata("HIGH")
                
                btntex:SetAllPoints()

                if option("ccs_stats_solidbg") then
                   btntex:SetVertexColor(r, g, b, alpha)
                else
                   btntex:SetGradient("Horizontal",CreateColor(r, g, b, alpha), CreateColor(0, 0, 0, alpha/2))
                end
                
                btnfont1:SetPoint("LEFT", btn, "LEFT", 0 ,0)
                btnfont1:SetFont(option("fontname_statname") or CCS.fontname, (option("fontsize_statname") or 10), CCS.textoutline)
                if option("showfontshadow") == true then
                    btnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                    btnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                end	                                                
                
                btnfont1:SetText("Name")
                btnfont1:SetTextColor(
                    option("fontcolor_statname")[1] or 1,
                    option("fontcolor_statname")[2] or 1,
                    option("fontcolor_statname")[3] or 1,
                    option("fontcolor_statname")[4] or 1
                )
               
                btnfont2:SetPoint("RIGHT", btn, "RIGHT", 0 ,0)
                btnfont2:SetFont(option("fontname_stats") or CCS.fontname, (option("fontsize_stats") or 10), CCS.textoutline)
                if option("showfontshadow") == true then
                    btnfont2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
                    btnfont2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
                end	                                                
                
                btnfont2:SetText("Value")
                btnfont2:SetTextColor(
                    option("fontcolor_stats")[1] or 1,
                    option("fontcolor_stats")[2] or 1,
                    option("fontcolor_stats")[3] or 1,
                    option("fontcolor_stats")[4] or 1
                )
                
                tooltip = true
            end
            
            if showrow(row) then
                btn:Show()            
                prev_row = btn
            else
                btn:Hide()            
            end
            
            ---------------------------
            -- Attributes Category
            ---------------------------
            if         row == 1 then btnfont1:SetText(PLAYERSTAT_BASE_STATS)
            elseif    row == 2 then -- Strength
                local statIndex = 1 
                local tmp_stat_value, effectiveStat, posBuff, negBuff = UnitStat("player", statIndex);
                local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
                local _, unitClass = UnitClass("player");
                unitClass = strupper(unitClass);
                                
                btnfont1:SetText(format("%s", ITEM_MOD_STRENGTH_SHORT)..":")                                
                
                local statName = _G["SPELL_STAT"..statIndex.."_NAME"];

                tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." "..tt_name;

            --tooltip name and value text
                local tmp_a
                tmp_a, tt_name = GetStatColorText(tmp_stat_value, effectiveStat, posBuff, negBuff, tt_name)
                btnfont2:SetText(tmp_a)

            -- Tooltip description
                local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);

                tt_desc = tt_desc .. format(_G["DEFAULT_STAT"..statIndex.."_TOOLTIP"], BreakUpLargeNumbers(attackPower));               

                if ( unitClass == "WARRIOR" or unitClass == "SHAMAN" or unitClass == "PALADIN" ) then
                    local increasedParryChance = GetParryChanceFromAttribute();
                    if ( increasedParryChance > 0 ) then
                        tt_desc = tt_desc.."|n|n"..format(CR_PARRY_BASE_STAT_TOOLTIP, increasedParryChance);
                    end
                end
            elseif    row == 3 then -- Agility
                local statIndex = 2 
                local tmp_stat_value, effectiveStat, posBuff, negBuff = UnitStat("player", statIndex);
                local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
                local _, unitClass = UnitClass("player");
                unitClass = strupper(unitClass);
                                
                btnfont1:SetText(format("%s", ITEM_MOD_AGILITY_SHORT)..":")                                
                
                local statName = _G["SPELL_STAT"..statIndex.."_NAME"];

                tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." "..tt_name;

            --tooltip name and value text
                local tmp_a
                tmp_a, tt_name = GetStatColorText(tmp_stat_value, effectiveStat, posBuff, negBuff, tt_name)
                btnfont2:SetText(tmp_a)

            -- Tooltip description
                local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
                
                if ( attackPower > 0 ) then
                    tt_desc = format(STAT_ATTACK_POWER, attackPower) .. format(_G["DEFAULT_STAT"..statIndex.."_TOOLTIP"], GetCritChanceFromAgility("player"), effectiveStat*ARMOR_PER_AGILITY);
                else
                    tt_desc = format(_G["DEFAULT_STAT"..statIndex.."_TOOLTIP"], GetCritChanceFromAgility("player"), effectiveStat*ARMOR_PER_AGILITY);
                end                
            
            elseif    row == 4 then -- Stamina
                local statIndex = 3 
                local tmp_stat_value, effectiveStat, posBuff, negBuff = UnitStat("player", statIndex);
                local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
                local _, unitClass = UnitClass("player");
                unitClass = strupper(unitClass);
                                
                btnfont1:SetText(format("%s", ITEM_MOD_STAMINA_SHORT)..":")                                
                
                local statName = _G["SPELL_STAT"..statIndex.."_NAME"];

                tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." "..tt_name;

            --tooltip name and value text
                local tmp_a
                tmp_a, tt_name = GetStatColorText(tmp_stat_value, effectiveStat, posBuff, negBuff, tt_name)
                btnfont2:SetText(tmp_a)

            -- Tooltip description
                local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
                local hpperstam = UnitHPPerStamina("player")
                local maxhealthmod = GetUnitMaxHealthModifier("player") 
                
                tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." "..tt_name;
                tt_desc = tt_desc .. format(_G["DEFAULT_STAT"..statIndex.."_TOOLTIP"], BreakUpLargeNumbers(((effectiveStat*hpperstam))*maxhealthmod));                
                
            elseif    row == 5 then -- Intellect
                local statIndex = 4 
                local tmp_stat_value, effectiveStat, posBuff, negBuff = UnitStat("player", statIndex);
                local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
                local _, unitClass = UnitClass("player");
                unitClass = strupper(unitClass);
                btnfont1:SetText(format("%s", ITEM_MOD_INTELLECT_SHORT)..":")                                
                
                local statName = _G["SPELL_STAT"..statIndex.."_NAME"];

                tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." "..tt_name;

            --tooltip name and value text
                local tmp_a
                tmp_a, tt_name = GetStatColorText(tmp_stat_value, effectiveStat, posBuff, negBuff, tt_name)
                btnfont2:SetText(tmp_a)

            -- Tooltip description
                local baseInt = min(20, effectiveStat);
                local moreInt = effectiveStat - baseInt

                if ( UnitHasMana("player") ) then
                    tt_desc = format(_G["DEFAULT_STAT"..statIndex.."_TOOLTIP"], baseInt + moreInt*MANA_PER_INTELLECT, GetSpellCritChanceFromIntellect("player"));
                else
                    tt_desc = nil;
                end
            
            elseif    row == 6 then -- Spirit
                local statIndex = 5 
                local tmp_stat_value, effectiveStat, posBuff, negBuff = UnitStat("player", statIndex);
                local statName = _G["SPELL_STAT"..statIndex.."_NAME"];
                local _, unitClass = UnitClass("player");
                unitClass = strupper(unitClass);
                                
                btnfont1:SetText(format("%s", ITEM_MOD_SPIRIT_SHORT)..":")                                
                
                local statName = _G["SPELL_STAT"..statIndex.."_NAME"];

                tt_name = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." "..tt_name;

            --tooltip name and value text
                local tmp_a
                tmp_a, tt_name = GetStatColorText(tmp_stat_value, effectiveStat, posBuff, negBuff, tt_name)
                btnfont2:SetText(tmp_a)

            -- Tooltip description
                tt_desc = format(_G["DEFAULT_STAT"..statIndex.."_TOOLTIP"], GetUnitHealthRegenRateFromSpirit("player"));
                
                if ( UnitHasMana("player") ) then
                    local regen = GetUnitManaRegenRateFromSpirit("player");
                    regen = floor( regen * 5.0 );
                    tt_desc = tt_desc.."\n"..format(MANA_REGEN_FROM_SPIRIT, regen);
                end

            elseif    row == 7 then -- Movement Speed
                -- Movement Speed
                UpdateMoveSpeed()
                btnfont1:SetText(format("%s", STAT_MOVEMENT_SPEED)..":")
                
                ---------------------------                
                -- Melee Category
                ---------------------------
            elseif    row == 8 then btnfont1:SetText(PLAYERSTAT_MELEE_COMBAT)
            elseif    row == 9 then -- Damage
                tooltip = false -- We will create a double tooltip for this information
                btnfont1:SetText(DAMAGE_COLON)
                btnfont2:SetText("Value")
                tt_name = INVTYPE_WEAPONMAINHAND
                
                local speed, offhandSpeed = UnitAttackSpeed("player");
                local minDamage;
                local maxDamage; 
                local minOffHandDamage;
                local maxOffHandDamage; 
                local physicalBonusPos;
                local physicalBonusNeg;
                local percent;

                minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player");
                local displayMin = max(floor(minDamage),1);
                local displayMax = max(ceil(maxDamage),1);
                
                if (percent == 0) then
                    minDamage = 0;
                    maxDamage = 0;
                else
                    minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
                    maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;
                end

                local baseDamage = (minDamage + maxDamage) * 0.5;
                local fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
                local totalBonus = (fullDamage - baseDamage);
                local damagePerSecond;
                if speed == 0 then
                    damagePerSecond = 0;
                else
                    damagePerSecond = (max(fullDamage,1) / speed);
                end
                local damageTooltip = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
                local colorPos = "|cff20ff20";
                local colorNeg = "|cffff2020";

                -- epsilon check
                if ( totalBonus < 0.1 and totalBonus > -0.1 ) then
                    totalBonus = 0.0;
                end

                if ( totalBonus == 0 ) then
                    if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
                        btnfont2:SetText(displayMin.." - "..displayMax);	
                    else
                        btnfont2:SetText(displayMin.."-"..displayMax);
                    end
                else
                    
                    local color;
                    if ( totalBonus > 0 ) then
                        color = colorPos;
                    else
                        color = colorNeg;
                    end
                    
                    if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
                        btnfont2:SetText(color..displayMin.." - "..displayMax.."|r");	
                    else
                        btnfont2:SetText(color..displayMin.."-"..displayMax.."|r");
                    end
                    
                    if ( physicalBonusPos > 0 ) then
                        damageTooltip = damageTooltip..colorPos.." +"..physicalBonusPos.."|r";
                    end
                    if ( physicalBonusNeg < 0 ) then
                        damageTooltip = damageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
                    end
                    if ( percent > 1 ) then
                        damageTooltip = damageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";

                    elseif ( percent < 1 ) then
                        damageTooltip = damageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
                    end
                    
                end
                local offhandDamagett, offhandDPS
                -- If there's an offhand speed then add the offhand info to the tooltip
                if ( offhandSpeed ) then
                    minOffHandDamage = (minOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;
                    maxOffHandDamage = (maxOffHandDamage / percent) - physicalBonusPos - physicalBonusNeg;

                    local offhandBaseDamage = (minOffHandDamage + maxOffHandDamage) * 0.5;
                    local offhandFullDamage = (offhandBaseDamage + physicalBonusPos + physicalBonusNeg) * percent;

                    local offhandDamagePerSecond;
                    if offhandSpeed == 0 then
                        offhandDamagePerSecond = 0;
                    else
                        offhandDamagePerSecond = (max(offhandFullDamage,1) / offhandSpeed);
                    end
                    local offhandDamageTooltip = max(floor(minOffHandDamage),1).." - "..max(ceil(maxOffHandDamage),1);
                    if ( physicalBonusPos > 0 ) then
                        offhandDamageTooltip = offhandDamageTooltip..colorPos.." +"..physicalBonusPos.."|r";
                    end
                    if ( physicalBonusNeg < 0 ) then
                        offhandDamageTooltip = offhandDamageTooltip..colorNeg.." "..physicalBonusNeg.."|r";
                    end
                    if ( percent > 1 ) then
                        offhandDamageTooltip = offhandDamageTooltip..colorPos.." x"..floor(percent*100+0.5).."%|r";
                    elseif ( percent < 1 ) then
                        offhandDamageTooltip = offhandDamageTooltip..colorNeg.." x"..floor(percent*100+0.5).."%|r";
                    end

                    offhandDamagett = offhandDamageTooltip
                    offhandDPS = offhandDamagePerSecond
                end

                -- Start constructing the tooltip values
                btn:SetScript("OnEnter", function(self) 
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                        GameTooltip:SetText(INVTYPE_WEAPONMAINHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
                        GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2F", speed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                        GameTooltip:AddDoubleLine(DAMAGE_COLON, damageTooltip, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                        GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1F", damagePerSecond), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);

                        if ( offhandSpeed ~= nil ) then
                            GameTooltip:AddLine(" "); -- Blank line.
                            GameTooltip:AddLine(INVTYPE_WEAPONOFFHAND, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
                            GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2F", offhandSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                            GameTooltip:AddDoubleLine(DAMAGE_COLON, offhandDamagett, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                            GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1F", offhandDPS), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                        end          

                        GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            elseif    row == 10 then -- Speed
                btnfont1:SetText(format("%s", SPEED)..":")

                local speed, offhandSpeed = UnitAttackSpeed("player");
                speed = CCS.round(speed) --format("%.2f", speed);
                if ( offhandSpeed ) then
                    offhandSpeed = CCS.round(offhandSpeed)
                end

                local text;	
                if ( offhandSpeed ) then
                    text = speed.." / "..offhandSpeed;
                else
                    text = speed;
                end

                btnfont2:SetText(text)

                tt_name = HIGHLIGHT_FONT_COLOR_CODE..ATTACK_SPEED.." "..text..FONT_COLOR_CODE_CLOSE;
                tt_desc = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_MELEE), GetCombatRatingBonus(CR_HASTE_MELEE));                
                
            elseif    row == 11 then -- Power
                btnfont1:SetText(ATTACK_POWER_COLON)

                local base, posBuff, negBuff = UnitAttackPower("player");
                local text = max(0,base + posBuff + negBuff);
                
            --tooltip name and value text
                local tmp_a
                tmp_a, tt_name = GetStatColorText(text, text, posBuff, negBuff, tt_name)
                btnfont2:SetText(tmp_a)
                tt_name = MELEE_ATTACK_POWER .. format(" %s", tt_name or "")
                tt_desc = format(MELEE_ATTACK_POWER_TOOLTIP, text/ATTACK_POWER_MAGIC_NUMBER);
                
                
            elseif    row == 12 then -- Hit Rating
                local rating = GetCombatRating(CR_HIT_MELEE);
                local ratingBonus = GetCombatRatingBonus(CR_HIT_MELEE);
                btnfont1:SetText(format("%s", COMBAT_RATING_NAME6)..":")
                btnfont2:SetText(rating)
                tt_name = HIGHLIGHT_FONT_COLOR_CODE..COMBAT_RATING_NAME6.." "..rating..FONT_COLOR_CODE_CLOSE;
                tt_desc = format(CR_HIT_MELEE_TOOLTIP, UnitLevel("player"), ratingBonus, GetArmorPenetration());                
                            
            elseif    row == 13 then -- Crit Chance
                local critChance = GetCritChance();
                critChance = format("%.2f%%", critChance);
                btnfont1:SetText(format("%s", MELEE_CRIT_CHANCE)..":")
                btnfont2:SetText(critChance);
                tt_name = HIGHLIGHT_FONT_COLOR_CODE..MELEE_CRIT_CHANCE.." "..critChance..FONT_COLOR_CODE_CLOSE;
                tt_desc = format(CR_CRIT_MELEE_TOOLTIP, GetCombatRating(CR_CRIT_MELEE), GetCombatRatingBonus(CR_CRIT_MELEE));  
                
            elseif    row == 14 then -- Expertise
                btnfont1:SetText(format("%s", STAT_EXPERTISE)..":")
                local expertise, offhandExpertise = GetExpertise();
                local speed, offhandSpeed = UnitAttackSpeed("player");
                local text;
                if( offhandSpeed ) then
                    text = expertise.." / "..offhandExpertise;
                else
                    text = expertise;
                end
                btnfont2:SetText(text)                
                tt_name = HIGHLIGHT_FONT_COLOR_CODE..getglobal("COMBAT_RATING_NAME"..CR_EXPERTISE).." "..text..FONT_COLOR_CODE_CLOSE;
                
                local expertisePercent, offhandExpertisePercent = GetExpertisePercent();
                expertisePercent = format("%.2f", expertisePercent);
                if( offhandSpeed ) then
                    offhandExpertisePercent = format("%.2f", offhandExpertisePercent);
                    text = expertisePercent.."% / "..offhandExpertisePercent.."%";
                else
                    text = expertisePercent.."%";
                end

                tt_desc = format(CR_EXPERTISE_TOOLTIP, text, GetCombatRating(CR_EXPERTISE), GetCombatRatingBonus(CR_EXPERTISE));

                ---------------------------                
                -- Ranged Category
                ---------------------------
            elseif    row == 15 then btnfont1:SetText(PLAYERSTAT_RANGED_COMBAT)
            elseif    row == 16 then -- Damage
                tooltip = false -- We will create a double tooltip for this information
                btnfont1:SetText(DAMAGE_COLON);

                -- If no ranged attack then set to n/a
                local hasRelic = UnitHasRelicSlot("player");	
                local rangedTexture = GetInventoryItemTexture("player", 18);
                if ( rangedTexture and not hasRelic ) then
                    PaperDollFrame.noRanged = nil;
                    
                    local rangedAttackSpeed, minDamage, maxDamage, physicalBonusPos, physicalBonusNeg, percent = UnitRangedDamage("player");
                    local displayMin = max(floor(minDamage),1);
                    local displayMax = max(ceil(maxDamage),1);

                    local baseDamage;
                    local fullDamage;
                    local totalBonus;
                    local damagePerSecond;
                    local doublett;

                    if ( HasWandEquipped() ) then
                        baseDamage = (minDamage + maxDamage) * 0.5;
                        fullDamage = baseDamage * percent;
                        totalBonus = 0;
                        damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
                        doublett = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
                    else
                        minDamage = (minDamage / percent) - physicalBonusPos - physicalBonusNeg;
                        maxDamage = (maxDamage / percent) - physicalBonusPos - physicalBonusNeg;

                        baseDamage = (minDamage + maxDamage) * 0.5;
                        fullDamage = (baseDamage + physicalBonusPos + physicalBonusNeg) * percent;
                        totalBonus = (fullDamage - baseDamage);
                        if (rangedAttackSpeed == 0) then
                        -- Egan's Blaster!!!
                            damagePerSecond = math.huge;
                        else
                            damagePerSecond = (max(fullDamage,1) / rangedAttackSpeed);
                        end
                        doublett = max(floor(minDamage),1).." - "..max(ceil(maxDamage),1);
                    end

                    if ( totalBonus == 0 ) then
                        if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
                            btnfont2:SetText(displayMin.." - "..displayMax);	
                        else
                            btnfont2:SetText(displayMin.."-"..displayMax);
                        end
                    else
                        local colorPos = "|cff20ff20";
                        local colorNeg = "|cffff2020";
                        local color;
                        if ( totalBonus > 0 ) then
                            color = colorPos;
                        else
                            color = colorNeg;
                        end
                        if ( ( displayMin < 100 ) and ( displayMax < 100 ) ) then 
                            btnfont2:SetText(color..displayMin.." - "..displayMax.."|r");	
                        else
                            btnfont2:SetText(color..displayMin.."-"..displayMax.."|r");
                        end
                        if ( physicalBonusPos > 0 ) then
                            doublett = doublett..colorPos.." +"..physicalBonusPos.."|r";
                        end
                        if ( physicalBonusNeg < 0 ) then
                            doublett = doublett..colorNeg.." "..physicalBonusNeg.."|r";
                        end
                        if ( percent > 1 ) then
                            doublett = doublett..colorPos.." x"..floor(percent*100+0.5).."%|r";
                        elseif ( percent < 1 ) then
                            doublett = doublett..colorNeg.." x"..floor(percent*100+0.5).."%|r";
                        end

                    end

                    btn:SetScript("OnEnter", function(self) 
                            GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                            GameTooltip:SetText(INVTYPE_RANGED, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
                            GameTooltip:AddDoubleLine(ATTACK_SPEED_COLON, format("%.2F", rangedAttackSpeed), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                            GameTooltip:AddDoubleLine(DAMAGE_COLON, doublett, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                            GameTooltip:AddDoubleLine(DAMAGE_PER_SECOND, format("%.1F", damagePerSecond), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                            GameTooltip:Show()
                    end)
                    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
                    
                else
                    tooltip = true
                    btnfont2:SetText(NOT_APPLICABLE);
                    PaperDollFrame.noRanged = 1;
                    tt_name = nil
                    tt_desc = nil
                end
  
            elseif    row == 17 then -- Speed
                btnfont1:SetText(format("%s", SPEED)..":")
                local text;
                -- If no ranged attack then set to n/a
                if ( PaperDollFrame.noRanged ) then
                    text = NOT_APPLICABLE;
                    tt_name = nil;
                    tt_desc = nil
                else
                    text = UnitRangedDamage("player");
                    text = format("%.2f", text);
                    tt_name = HIGHLIGHT_FONT_COLOR_CODE..ATTACK_SPEED.." "..text..FONT_COLOR_CODE_CLOSE;
                    tt_desc = format(CR_HASTE_RATING_TOOLTIP, GetCombatRating(CR_HASTE_RANGED), GetCombatRatingBonus(CR_HASTE_RANGED));
                end
                btnfont2:SetText(text)

            elseif    row == 18 then -- Power
                btnfont1:SetText(ATTACK_POWER_COLON);
                local base, posBuff, negBuff = UnitRangedAttackPower("player");
                local text = max(0,base + posBuff + negBuff);
                
                local tmp_a
                tmp_a, tt_name = GetStatColorText(text, text, posBuff, negBuff, tt_name)
                btnfont2:SetText(tmp_a)
                tt_name = RANGED_ATTACK_POWER .. format(" %s", tt_name or "")
                
                
                local totalAP = base+posBuff+negBuff;
                tt_desc = format(RANGED_ATTACK_POWER_TOOLTIP, max((totalAP), 0)/ATTACK_POWER_MAGIC_NUMBER);
                
                local petAPBonus = ComputePetBonus( "PET_BONUS_RAP_TO_AP", totalAP );
                if( petAPBonus > 0 ) then
                    tt_desc = tt_desc .. "\n" .. format(PET_BONUS_TOOLTIP_RANGED_ATTACK_POWER, math.floor(petAPBonus));
                end
                
                local petSpellDmgBonus = ComputePetBonus( "PET_BONUS_RAP_TO_SPELLDMG", totalAP );
                if( petSpellDmgBonus > 0 ) then
                    tt_desc = tt_desc .. "\n" .. format(PET_BONUS_TOOLTIP_SPELLDAMAGE, math.floor(petSpellDmgBonus));
                end
            
            elseif    row == 19 then -- Hit Rating
                local rating = GetCombatRating(CR_HIT_RANGED);
                local ratingBonus = GetCombatRatingBonus(CR_HIT_RANGED);
                btnfont1:SetText(format("%s", COMBAT_RATING_NAME6)..":")
                btnfont2:SetText(rating)
                tt_name = HIGHLIGHT_FONT_COLOR_CODE..COMBAT_RATING_NAME6.." "..rating..FONT_COLOR_CODE_CLOSE;
                tt_desc = format(CR_HIT_RANGED_TOOLTIP, UnitLevel("player"), ratingBonus, GetArmorPenetration());                

            
            elseif    row == 20 then -- Crit Chance
                local critChance = GetRangedCritChance();
                critChance = format("%.2f%%", critChance);
                btnfont1:SetText(format("%s", RANGED_CRIT_CHANCE)..":")
                btnfont2:SetText(critChance);
                tt_name = HIGHLIGHT_FONT_COLOR_CODE..RANGED_CRIT_CHANCE.." "..critChance..FONT_COLOR_CODE_CLOSE;
                tt_desc = format(CR_CRIT_RANGED_TOOLTIP, GetCombatRating(CR_CRIT_RANGED), GetCombatRatingBonus(CR_CRIT_RANGED));  
                
                ---------------------------                
                -- Spell Category
                ---------------------------
            elseif    row == 21 then btnfont1:SetText(PLAYERSTAT_SPELL_COMBAT)
            elseif    row == 22 then -- Bonus Damage
                tooltip = false
                local holySchool = 2;
                -- Start at 2 to skip physical damage
                local minModifier = GetSpellBonusDamage(holySchool);
                local statFramebonusDamage = {};
                statFramebonusDamage[holySchool] = minModifier;
                local bonusDamage;
                for i=(holySchool+1), MAX_SPELL_SCHOOLS do
                    bonusDamage = GetSpellBonusDamage(i);
                    minModifier = min(minModifier, bonusDamage);
                    statFramebonusDamage[i] = bonusDamage;
                end

                btnfont1:SetText(format("%s", ITEM_MOD_SPELL_DAMAGE_DONE_SHORT)..":")
                btnfont2:SetText(minModifier);

                -- Create tooltip
                btn:SetScript("OnEnter", function(self) 
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                        GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..BONUS_DAMAGE.." "..minModifier..FONT_COLOR_CODE_CLOSE);
                        for i=2, MAX_SPELL_SCHOOLS do
                            GameTooltip:AddDoubleLine(getglobal("DAMAGE_SCHOOL"..i), statFramebonusDamage[i], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                            GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..i);
                        end
                        
                        local petStr, damage;
                        if( statFramebonusDamage[6] > statFramebonusDamage[3] ) then
                            petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG_SHADOW;
                            damage = statFramebonusDamage[6];
                        else
                            petStr = PET_BONUS_TOOLTIP_WARLOCK_SPELLDMG_FIRE;
                            damage = statFramebonusDamage[3];
                        end
                        
                        local petBonusAP = ComputePetBonus("PET_BONUS_SPELLDMG_TO_AP", damage );
                        local petBonusDmg = ComputePetBonus("PET_BONUS_SPELLDMG_TO_SPELLDMG", damage );
                        if( petBonusAP > 0 or petBonusDmg > 0 ) then
                            GameTooltip:AddLine("\n" .. format(petStr, petBonusAP, petBonusDmg), nil, nil, nil, 1 );
                        end
                        GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            
            elseif    row == 23 then -- Bonus Healing
                local bonusHealing = GetSpellBonusHealing();
                btnfont1:SetText(format("%s", BONUS_HEALING)..":")
                btnfont2:SetText(bonusHealing);
                tt_name = HIGHLIGHT_FONT_COLOR_CODE .. BONUS_HEALING .. FONT_COLOR_CODE_CLOSE;
                tt_desc =format(BONUS_HEALING_TOOLTIP, bonusHealing);                

            elseif    row == 24 then -- Hit Rating
                local statName = getglobal("COMBAT_RATING_NAME"..CR_HIT_SPELL);
                local rating = GetCombatRating(CR_HIT_SPELL);
                local ratingBonus = GetCombatRatingBonus(CR_HIT_SPELL);

                btnfont1:SetText(statName..":");
                btnfont2:SetText(rating);
                
                -- Set the tooltip text
                tt_name = HIGHLIGHT_FONT_COLOR_CODE..statName.." "..rating..FONT_COLOR_CODE_CLOSE;     
                tt_desc = format(CR_HIT_SPELL_TOOLTIP, UnitLevel("player"), ratingBonus, GetSpellPenetration(), GetSpellPenetration());                
            
            elseif    row == 25 then -- Crit Chance
                tooltip = false
                btnfont1:SetText(SPELL_CRIT_CHANCE..":");
                local holySchool = 2;
                -- Start at 2 to skip physical damage
                local minCrit = GetSpellCritChance(holySchool);
                local statFramespellCrit = {};
                statFramespellCrit[holySchool] = minCrit;
                local spellCrit;
                for i=(holySchool+1), MAX_SPELL_SCHOOLS do
                    spellCrit = GetSpellCritChance(i);
                    minCrit = min(minCrit, spellCrit);
                    statFramespellCrit[i] = spellCrit;
                end

                minCrit = format("%.2f%%", minCrit);
                btnfont2:SetText(minCrit);

                -- Create tooltip
                    btn:SetScript("OnEnter", function(self) 
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    GameTooltip:SetText(HIGHLIGHT_FONT_COLOR_CODE..COMBAT_RATING_NAME11.." "..GetCombatRating(11)..FONT_COLOR_CODE_CLOSE);
                    local spellCrit;
                    for i=2, MAX_SPELL_SCHOOLS do
                        spellCrit = format("%.2f", statFramespellCrit[i]);
                        spellCrit = spellCrit.."%";
                        GameTooltip:AddDoubleLine(getglobal("DAMAGE_SCHOOL"..i), spellCrit, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                        GameTooltip:AddTexture("Interface\\PaperDollInfoFrame\\SpellSchoolIcon"..i);
                    end
                    GameTooltip:Show();
                end)
                btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
           
            elseif    row == 26 then -- Haste Rating
                btnfont1:SetText(format("%s", SPELL_HASTE)..":")
                btnfont2:SetText(GetCombatRating(CR_HASTE_SPELL))

                tt_name = HIGHLIGHT_FONT_COLOR_CODE .. SPELL_HASTE .. FONT_COLOR_CODE_CLOSE;
                tt_desc = format(SPELL_HASTE_TOOLTIP, GetCombatRatingBonus(CR_HASTE_SPELL));                
            
            elseif    row == 27 then -- Mana Regen
                btnfont1:SetText(format("%s", MANA_REGEN)..":")

                if ( not UnitHasMana("player") ) then
                    btnfont2:SetText(NOT_APPLICABLE);
                    tooltip = false
                else
                    local base, casting = GetManaRegen();
                    -- All mana regen stats are displayed as mana/5 sec.
                    base = floor( base * 5.0 );
                    casting = floor( casting * 5.0 );
                    btnfont2:SetText(base);
                    tt_name = HIGHLIGHT_FONT_COLOR_CODE .. MANA_REGEN .. FONT_COLOR_CODE_CLOSE;
                    tt_desc = format(MANA_REGEN_TOOLTIP, base, casting);
                
                end

                ---------------------------                
                -- Defenses Category
                ---------------------------
            elseif    row == 28 then btnfont1:SetText(PLAYERSTAT_DEFENSES)
            elseif    row == 29 then -- Armor
            	local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
                local text = max(0,base + posBuff + negBuff);
                local tmp_a
                tmp_a, tt_name = GetStatColorText(text, effectiveArmor, posBuff, negBuff, tt_name)

                btnfont1:SetText(format("%s", ARMOR)..":")
                btnfont2:SetText(tmp_a)                
                tt_name = ARMOR .. format(" %s", tt_name or "")

                local armorReduction = PaperDollFrame_GetArmorReduction(effectiveArmor, UnitLevel("player"));
                local armorReductionText = format("%.2f", armorReduction);
                tt_desc = format(DEFAULT_STATARMOR_TOOLTIP, armorReductionText);

                local petBonus = ComputePetBonus("PET_BONUS_ARMOR", effectiveArmor );
                if( petBonus > 0 ) then
                    tt_desc = tt_desc .. "\n" .. format(PET_BONUS_TOOLTIP_ARMOR, petBonus);
                end
                
            elseif    row == 30 then -- Defense
                local base, modifier = UnitDefense("player");
                local posBuff = 0;
                local negBuff = 0;
                if ( modifier > 0 ) then
                    posBuff = modifier;
                elseif ( modifier < 0 ) then
                    negBuff = modifier;
                end

                btnfont1:SetText(format("%s", DEFENSE)..":")
               
                local text = max(0,base + posBuff + negBuff);
                local tmp_a
                tmp_a, tt_name = GetStatColorText(text, text, posBuff, negBuff, tt_name)

                btnfont2:SetText(tmp_a)                
                tt_name = DEFENSE .. format(" %s", tt_name or "")
                
                local defensePercent = GetDodgeBlockParryChanceFromDefense();
                tt_desc = format(DEFAULT_STATDEFENSE_TOOLTIP, GetCombatRating(CR_DEFENSE_SKILL), GetCombatRatingBonus(CR_DEFENSE_SKILL), defensePercent, defensePercent);
                
            elseif    row == 31 then -- Dodge
            	local chance = GetDodgeChance();
                
                btnfont1:SetText(format("%s", DODGE)..":")
                btnfont2:SetText(CCS.round(chance).."%")

                tt_name = HIGHLIGHT_FONT_COLOR_CODE..DODGE_CHANCE.." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
                tt_desc = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));

            elseif    row == 32 then -- Parry
            	local chance = GetParryChance();
                
                btnfont1:SetText(format("%s", PARRY)..":")
                btnfont2:SetText(CCS.round(chance).."%")
                
                tt_name = HIGHLIGHT_FONT_COLOR_CODE..getglobal("PARRY_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
                tt_desc = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));

            elseif    row == 33 then -- Block
                local chance = GetBlockChance();

                btnfont1:SetText(format("%s", BLOCK)..":")
                btnfont2:SetText(CCS.round(chance).."%")
                
                tt_name = HIGHLIGHT_FONT_COLOR_CODE..getglobal("BLOCK_CHANCE").." "..string.format("%.02f", chance).."%"..FONT_COLOR_CODE_CLOSE;
                tt_desc = format(CR_BLOCK_TOOLTIP, GetCombatRating(CR_BLOCK), GetCombatRatingBonus(CR_BLOCK), GetShieldBlock());

            elseif    row == 34 then -- Resilience
            	local resilience = GetCombatRating(CR_RESILIENCE_CRIT_TAKEN);
                local bonus = GetCombatRatingBonus(CR_RESILIENCE_CRIT_TAKEN);
                
                btnfont1:SetText(format("%s", RESILIENCE)..":")
                btnfont2:SetText(resilience)
                tt_name = HIGHLIGHT_FONT_COLOR_CODE..STAT_RESILIENCE.." "..resilience..FONT_COLOR_CODE_CLOSE;
                tt_desc = format(RESILIENCE_TOOLTIP, bonus, min(bonus * 2, 25.00), bonus);

            end
       
            if tooltip then 
                local name, desc = tt_name, tt_desc
                btn:SetScript("OnEnter", function(self) 
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                        GameTooltip:AddDoubleLine(name, nil, 1, 1, 1, 1, 1, 1) 
                        GameTooltip:AddLine(desc, nil, nil, nil, true)   
                        GameTooltip:Show()
                end)
                btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            end
            
        end
        
    end
end   


-- Event handler for character stats
function CCS.TBCCharacterStatsEventHandler(event, ...)
    local arg1 = ...

    if CCS.GetCurrentVersion() ~= CCS.TBC then return end
    if CharacterFrame and not CharacterFrame:IsVisible() then return end

    if C_AddOns.IsAddOnLoaded("DejaClassicStats") == true then 
        DCS_StatScrollFrame:SetParent(PaperDollFrame)
        DCS_StatScrollFrame:ClearAllPoints()
        DCS_StatScrollFrame:SetPoint("TOP", PaperDollFrame, "TOP", 0, -38)
        DCS_StatScrollFrame:SetPoint("LEFT", CharacterHandsSlot, "RIGHT", 40, 0)
        DCS_StatScrollFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", -35, 25)

        regions = { DCS_StatScrollFrame:GetRegions() }
        for i = 1, #regions do
            local r = regions[i]
            if r and r.Hide then
                r:Hide()
            end
        end 
    return end
    
    if (event == "UNIT_DAMAGE" or event == "UNIT_ATTACK_SPEED" or event == "UNIT_MAXHEALTH") and arg1 ~= "player" then return end

    if event == "PLAYER_STARTED_LOOKING" or event == "PLAYER_STARTED_MOVING" or event == "PLAYER_STARTED_TURNING" or 
       event == "PLAYER_STOPPED_LOOKING" or event == "PLAYER_STOPPED_MOVING" or event == "PLAYER_STOPPED_TURNING" then
        if not InCombatLockdown() and CharacterFrame:IsVisible() then
            UpdateMoveSpeed()
        end
        return
    end

    if event == "CCS_EVENT_OPTIONS" then
        InitializeStats()
        return true
    end

    if not CCS.statsUpdatePending then
        CCS.statsUpdatePending = true
        C_Timer.After(0, function()
            CCS.statsUpdatePending = false
            InitializeStats()
        end)
    end
end
