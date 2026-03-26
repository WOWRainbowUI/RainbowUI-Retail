local addonName, ns = ...
local CCS = ns.CCS
if CCS.GetCurrentVersion() ~= CCS.MOP then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table

local module = {
    Name = "Mop Module",
    CompatibleVersions = { CCS.MOP },
    OnInitialize = function(self)
        print(self.Name .. " initialized for MoP")
    end,
}

CCS.Modules[module.Name] = module

local modbg = _G["CharacterModelFramebg"] or CreateFrame("Frame", "CharacterModelFramebg", CharacterModelScene)
local modtex = _G["CharacterModelFramebgtex"] or modbg:CreateTexture("CharacterModelFramebgtex", "BACKGROUND")    

local inspectmodbg = _G["InspectModelFramebg"] or CreateFrame("Frame", "InspectModelFramebg")
local inspectmodtex = _G["InspectModelFramebgtex"] or inspectmodbg:CreateTexture("InspectModelFramebgtex", "BACKGROUND")    

local modelbtn = _G["CCS_clk_Btn"] or CreateFrame("Button", "CCS_clk_Btn", PaperDollFrame, "UIPanelButtonTemplate")
local bg_texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\MOTHERtalenttree.BLP"

function module:OnInitialize()
 --print (module.Name, " Test")
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
    MoveModelLeft()
    ChangeModelBg()
    CharacterModelScene.ControlFrame:Hide()
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
    
    CharacterFrameExpandButton:ClearAllPoints()
    CharacterFrameExpandButton:SetPoint("BOTTOMRIGHT", CharacterFrameInset, "BOTTOMRIGHT",270,4)
    
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
    ReputationFrame:SetPoint("TOPLEFT", CharacterFrameBg, "TOPLEFT", 0, 0)
    ReputationFrame:SetPoint("BOTTOMRIGHT", CharacterFrameBg, "BOTTOMRIGHT", 0, 0)
end


local function MOPupdateLocationInfo(unit, slotIndex, framename)
    if slotIndex == 18 then return end -- skip ranged slot

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
    if durbar then durbar:Hide() end

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
        local Color = "ffffffff"
        itemiLevel = C_Item.GetDetailedItemLevelInfo(link)
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
                end--]]
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


--[[
if itemLink then
    -- Always check for upgrade line and item level
    CCS_ScanTooltip:ClearLines()
    CCS_ScanTooltip:SetInventoryItem(unit, slotIndex)
    for i = 2, CCS_ScanTooltip:NumLines() do
        local L = _G["CCS_ScanTooltipTextLeft"..i]
        local text = norm(L and L:GetText() or nil)
        
        if text then
            local upgradeLine = parseUpgradeLine(text)
            if upgradeLine then
                ItemUpgradeLevel = upgradeLine
            end
            local ilvl = text:match(ITEM_LEVEL:gsub("%%d", "(%%d+)"))
            if ilvl then
                itemiLevel = tonumber(ilvl)
            end
        end
    end

    -- Only run enchant detection if enabled and enchantId is non‑zero
    if enchantDetectionEnabled then
        local enchantId = itemLink:match("item:%d+:(%d+)")
        if enchantId and enchantId ~= "0" then
            local baseLines = {}
            local baseStatsSeen = {}
            local baseLink = itemLink:gsub("item:(%d+):%d+", "item:%1:0")

            CCS_ScanTooltip:ClearLines()
            CCS_ScanTooltip:SetHyperlink(baseLink)
            for i = 2, CCS_ScanTooltip:NumLines() do
                local L = _G["CCS_ScanTooltipTextLeft"..i]
                local t = norm(L and L:GetText() or nil)
                if t then
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

            local equippedStatsConsumed = {}
            CCS_ScanTooltip:ClearLines()
            CCS_ScanTooltip:SetInventoryItem(unit, slotIndex)
            for i = 2, CCS_ScanTooltip:NumLines() do
                local L = _G["CCS_ScanTooltipTextLeft"..i]
                local t = norm(L and L:GetText() or nil)
                if t then
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
--]]
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

    for slotIndex = 1,19 do 
        MOPupdateLocationInfo("player", slotIndex, "Character")
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

local function CreateExtraReputationRows(numExtra)
    -- Find the last existing row
    local lastRow = _G["ReputationBar"..NUM_FACTIONS_DISPLAYED]
    if not lastRow then return end

    for i = NUM_FACTIONS_DISPLAYED+1, NUM_FACTIONS_DISPLAYED+numExtra do
        -- Only create if it doesn't already exist
        if not _G["ReputationBar"..i] then
            local row = CreateFrame("Button", "ReputationBar"..i, ReputationFrame, "ReputationBarTemplate")

            -- Anchor it directly below the previous row (no extra offset)
            local prevRow = _G["ReputationBar"..(i-1)]
            if prevRow then
                row:SetPoint("TOPLEFT", prevRow, "BOTTOMLEFT", 0, -3)
                row:SetPoint("RIGHT", prevRow, "RIGHT", 0, 0)                
            else
                -- Fallback: anchor to lastRow if prevRow is missing
                row:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT", 0, -3)
                row:SetPoint("RIGHT", lastRow, "RIGHT", 0, 0)                                
            end

            -- Set ID/index so GetFactionInfo works
            row:SetID(i)
        end
    end

    -- Update the constant so FauxScrollFrame_Update knows about the new rows
    NUM_FACTIONS_DISPLAYED = NUM_FACTIONS_DISPLAYED + numExtra
end


local function ReputationFrame_Update()
    local ks = {ReputationFrame:GetChildren()}
    local gender = UnitSex("player")
    local xtext, factiontext = "", ""
    
    ReputationListScrollFrame:ClearAllPoints()
    ReputationListScrollFrame:SetPoint("TOPLEFT", CharacterFrameInset, "TOPLEFT", 0, -4)
    ReputationListScrollFrame:SetPoint("BOTTOMRIGHT", ReputationFrame, "BOTTOMRIGHT", -40, 4)
    
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

    ReputationFrameStandingLabel:SetPoint("TOPLEFT", ReputationFrame, "TOPLEFT", 545, -42)
   
    for _, k in ipairs(ks) do -- Individual Row
        local ks2 = {k:GetChildren()}
        
        if k.index then
            -- MoP-era API
            local name, _, standingID, barMin, barMax, barValue, _, _, _, _, _, _, _, factionID = GetFactionInfo(k.index)
            local mainbarbg = _G[k:GetName().."Background"]
               
                if (mainbarbg) then
                    mainbarbg:SetTexture("Interface\\Masks\\SquareMask.BLP")
                    mainbarbg:SetColorTexture(.15, .15, .15, 0.90)
                end
                
                if _G[k:GetName().."LeftLine"] then
                _G[k:GetName().."LeftLine"]:SetTexture("")
                end
                
                if _G[k:GetName().."BottomLine"] then
                _G[k:GetName().."BottomLine"]:SetTexture("")
                end

            for _, k2 in ipairs(ks2) do -- Reputation sub-Bar (right side of the row)
                local RepBar = _G[k2:GetName()]
                k2.Background = k2.Background or k2:CreateTexture(nil, "BACKGROUND", nil, 2)

                if (k2.Background) then

                    k2.Background:SetTexture("Interface\\Masks\\SquareMask.BLP")
                    k2.Background:SetColorTexture(.08, .08, .08, 0.90)
                    k2.Background:SetPoint("TOPLEFT", k2, "TOPLEFT")
                    k2.Background:SetPoint("BOTTOMRIGHT", k2, "BOTTOMRIGHT")
                end

                local LeftTexture = _G[k2:GetName().."LeftTexture"]
                
                if (RepBar and LeftTexture) then
                    LeftTexture:SetTexture("Interface\\Masks\\SquareMask.BLP")
                    LeftTexture:SetGradient("Vertical", CreateColor(0, 0, 0, .4), CreateColor(.2, .2, .2, .4)) -- Dark Gray
                    LeftTexture:SetAlpha(0.9)
                    LeftTexture:SetWidth(250)
                    LeftTexture:SetPoint("TOP", k, "TOP")                    
                    LeftTexture:SetPoint("BOTTOM", k, "BOTTOM")                                        
                    RepBar:SetWidth(250)
                    RepBar:SetHeight(k:GetHeight())
                    _G[k2:GetName().."RightTexture"]:Hide()
                end

                if name == "Inactive" or name == "Other" then
                    -- skip inactive header
                else
                    local colorIndex = standingID
                    local barColor = FACTION_BAR_COLORS[colorIndex]
                    local factionStandingtext = GetText("FACTION_STANDING_LABEL" .. standingID, gender)
                    local isCapped = (standingID == MAX_REPUTATION_REACTION)

                    factiontext = factionStandingtext
                    
                    if isCapped then
                        barMax = 21000
                        barValue = 21000
                        barMin = 0
                    else
                        barMax = barMax - barMin
                        barValue = barValue - barMin
                        barMin = 0
                    end

                    if (RepBar) then
                        xtext = format("  %-20.20s %-30.30s", factiontext, format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(barMax)))
                        if _G[k2:GetName().."FactionStanding"] then
                            _G[k2:GetName().."FactionStanding"]:SetText(xtext)
                        end
                        if LeftTexture then
                            LeftTexture:SetGradient("Vertical", CreateColor(0, 0, 0, .4), CreateColor(barColor.r, barColor.g, barColor.b, .4)) -- Dark Gray
                            if barMax ~= 0 then
                                LeftTexture:SetWidth(math.max(1,250*barValue/barMax))
                            end
                        end

                        if k2.StandingText then
                            k2.StandingText:SetText(xtext)
                            k2.tooltip:SetText(xtext)
                        end

                    end
                end
            end
        end
    end
end

local function CurrencyFrame_Update()
            
            local tf={TokenFrame.ScrollBox.ScrollTarget:GetChildren()}; 
            
            for _,t in ipairs(tf) do 
                if t and t.Name then t.Name:SetFont(t.Name:GetFont(), option("fontsize_currency") or 11, "")end 
                if t and t.Count then t.Count:SetFont(t.Count:GetFont(), option("fontsize_currency") or 11, "")end 

                    if t.Text then
                        t.Text:SetFont(option("fontname_currency") or fontName, option("fontsize_currency"), CCS.textoutline)
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
                        k2.Name:SetTextColor(
                            option("fontcolor_currency")[1] or 1,
                            option("fontcolor_currency")[2] or 1,
                            option("fontcolor_currency")[3] or 1,
                            option("fontcolor_currency")[4] or 1
                        )
                    end
                    
                    if k2.Count then
                        k2.Count:SetFont(option("fontname_currency") or fontName, option("fontsize_currency"), CCS.textoutline)
                        k2.Count:SetTextColor(
                            option("fontcolor_currency")[1] or 1,
                            option("fontcolor_currency")[2] or 1,
                            option("fontcolor_currency")[3] or 1,
                            option("fontcolor_currency")[4] or 1
                        )

                    end

                end
                
            end

end

function CCS.HookSetup()

    if CCS.Hooked then return end
        --== Frame Hooks

    if C_AddOns.IsAddOnLoaded("PrettyReps") == false then
        hooksecurefunc(ReputationFrame, "Hide", function() ReputationDetailFrame:Hide(); end )
        hooksecurefunc("ReputationFrame_Update", ReputationFrame_Update)
        hooksecurefunc(ReputationFrame, "Show", function() 
                hookfix();
                InitializeFrameUpdates();
        end)

        local ks = {ReputationFrame:GetChildren()}
        for _, k in ipairs(ks) do -- Individual Row
            k:SetScript("OnEnter", function() end)
            k:SetScript("OnLeave", function() end)
        end

    end

    CharacterFrameExpandButton:HookScript("OnClick", function(self, button, down)
        hookfix()
    end)

    CharacterStatsPaneCategory1ToolbarSortDownArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory1ToolbarSortUpArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory2ToolbarSortDownArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory2ToolbarSortUpArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory3ToolbarSortDownArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory3ToolbarSortUpArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory4ToolbarSortDownArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory4ToolbarSortUpArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory5ToolbarSortDownArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory5ToolbarSortUpArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory6ToolbarSortDownArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory6ToolbarSortUpArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory7ToolbarSortDownArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    CharacterStatsPaneCategory7ToolbarSortUpArrow:HookScript("OnClick", function(self, button, down) hookfix() end)
    
   
    hooksecurefunc(PaperDollFrame, "Show", function() hookfix(); end)
    hooksecurefunc(CharacterFrame, "Show", function() 
            InitializeFrameUpdates()
            CCS:FireEvent("CCS_EVENT_CSHOW")
            GameTooltip:Hide()
            hookfix()
            CharacterModelScene.ControlFrame:Hide()            
            if C_AddOns.IsAddOnLoaded("NDui") then
                CharacterFrameCloseButton:Hide()
            end
    end )

    
    hooksecurefunc(CharacterFrame, "Hide", function() GameTooltip:Hide(); end )
    CCS.Hooked = true
end

-- Module Inspect Init
function MOPinitializeinspectframe()
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

    InspectFrameTopTileStreaks:Hide()
    InspectFrameTopRightCorner:Hide()
    InspectFrameBotRightCorner:Hide()
    InspectFrameTopLeftCorner:Hide()
    InspectFrameBotLeftCorner:Hide()
    InspectFrameRightBorder:Hide()    
    InspectFrameLeftBorder:Hide()        
    InspectFrameTopBorder:Hide()        
    InspectFrameBottomBorder:Hide()        

    InspectFramePortraitFrame:Hide()            
    InspectFrame.PortraitContainer:Hide()            
	
	--InspectFrameCloseButton:SetNormalTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\close.png")
    --InspectFrameCloseButton:SetHighlightTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\close-h.png")
    CCS:SkinBlizzardButton(InspectFrameCloseButton, "x", 26)
    InspectFrameCloseButton:ClearAllPoints();
    InspectFrameCloseButton:SetPoint("TOPRIGHT", InspectFrameBg, "TOPRIGHT", -10, -10)
    InspectFrameCloseButton:SetSize(32, 32)
    InspectFrameCloseButton:SetScale(.5)
    
    if InspectPVPFrame then
        InspectPVPFrame.BG:SetPoint("BOTTOMRIGHT", InspectFrameBg, "BOTTOMRIGHT", -5, 30)
        --InspectPVPFrame.HonorLevel:SetPoint("TOP", InspectPVPFrame, "TOP", 0, -70)
        --InspectPVPFrame.HKs:SetPoint("TOP", InspectPVPFrame, "TOP", 0, -100)
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
    local mh_region = select(13, InspectMainHandSlot:GetRegions())
    if mh_region and mh_region.GetObjectType and mh_region:GetObjectType() == "Texture" then
        mh_region:Hide()
    end    
    local oh_region = select(13, InspectSecondaryHandSlot:GetRegions())
    if oh_region and oh_region.GetObjectType and oh_region:GetObjectType() == "Texture" then
        oh_region:Hide()
    end    
    
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

    CharacterFrame:SetHeight(479+(7*option("vpad"))) -- Do not allow the frame to get any smaller than the default bliz frame
    local Bgoffset = option("hpad")
    
    CharacterFrameInset.Bg:ClearAllPoints();
    CharacterFrameInset.Bg:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 4, -60)
    CharacterFrameInset.Bg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMLEFT", 330+option("hpad"), 30)
    CharacterFrameInset:Hide();
    
    CharacterFrameBg:SetVertexColor(0,0,0,0);
    
    CharacterFrameBg:ClearAllPoints()
    CharacterFrameBg:SetPoint("TOPLEFT", CharacterFrame, "TOPLEFT", 0, 0);
    CharacterFrameBg:SetPoint("BOTTOMRIGHT", CharacterFrame, "BOTTOMRIGHT", Bgoffset+65, 0); --279  .449
   
    CharacterFrame.TopTileStreaks:Hide()
    --ReputationFrame.ReputationDetailFrame:SetFrameStrata("HIGH")
    
    local charbg = _G["CharacterFrameBgbg"] or CreateFrame("Frame", "CharacterFrameBgbg", CharacterFrame)
    local charbgtex = _G["CharacterFrameBgbgtex"] or charbg:CreateTexture("CharacterFrameBgbgtex", "BACKGROUND", nil, 1)    
    local bgr, bgg, bgb, bgalpha = option("bgcolor")[1], option("bgcolor")[2], option("bgcolor")[3], option("bgcolor")[4];
    
    GearManagerPopupFrame:SetFrameStrata("DIALOG")
    GearManagerPopupFrame.IconSelector:SetFrameStrata("FULLSCREEN")
    
    charbg:ClearAllPoints()
    charbg:SetAllPoints(CharacterFrameBg)
    charbg:SetFrameStrata("BACKGROUND")
    charbgtex:ClearAllPoints()
    charbgtex:SetAllPoints()
    charbgtex:SetTexture("Interface\\Masks\\SquareMask.BLP")
    charbgtex:SetVertexColor(bgr,bgg,bgb,bgalpha);

    --CharacterFrameCloseButton:SetNormalTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\close.png")
    --CharacterFrameCloseButton:SetHighlightTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\close-h.png")
    CCS:SkinBlizzardButton(CharacterFrameCloseButton, "x", 26)
    CharacterFrameCloseButton:ClearAllPoints();
    CharacterFrameCloseButton:SetPoint("TOPRIGHT", CharacterFrameBg, "TOPRIGHT", -10, -10)
    CharacterFrameCloseButton:SetSize(32, 32)
    CharacterFrameCloseButton:SetScale(.5)
    
    local CCSsetbtn = _G["CCSsetbtn"] or CreateFrame("Button", "CCSsetbtn", CharacterFrame)
    CCSsetbtn:SetSize(32, 32)
    CCSsetbtn:SetPoint("TOPRIGHT", CharacterFrameCloseButton, "TOPLEFT", -5, 0)
    CCSsetbtn:SetScale(.5)
    --CCSsetbtn:SetNormalTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\settings.png")
    --CCSsetbtn:SetHighlightTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\settings-h.png")
    CCS:ApplyIconStyle(CCSsetbtn, "gear", 32)    
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
   
    --CharacterModelScene.GearEnchantAnimation:ClearAllPoints()
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

    CharacterLevelText:ClearAllPoints()
    CharacterLevelText:SetPoint("TOP", CharacterFrameTitleText, "BOTTOM", 0, 0)
    CharacterLevelText:SetFont(option("fontname_levelclass") or CCS.fontname, (option("fontsize_levelclass") or 12) , CCS.textoutline)
    
    CharacterFrame.NineSlice:Hide()
    CharacterFramePortrait:Hide()
    
    CharacterFrameExpandButton:Hide()
    CharacterFrameBotLeftCorner:Hide()
    CharacterFrameBotRightCorner:Hide()
    CharacterFrameBottomBorder:Hide()
    CharacterFrameLeftBorder:Hide()
    CharacterFrameRightBorder:Hide()    
    CharacterFrameTopBorder:Hide()        
    CharacterFrameTopLeftCorner:Hide()        
    CharacterFrameTopRightCorner:Hide()            
    CharacterFrameTopTileStreaks:Hide()                
    CharacterFramePortraitFrame:Hide()        
    CharacterFrameTitleBg:Hide()
    
    CharacterFrameInsetRight.Bg:Hide();
    CharacterFrameInsetRight:ClearAllPoints();
    CharacterFrameInsetRight:SetPoint("TOPLEFT", CharacterFrameInset.Bg, "TOPRIGHT", 4, 0)
    CharacterFrameInsetRight:SetPoint("BOTTOMRIGHT", CharacterFrameInset.Bg, "BOTTOMRIGHT", 250, 0)
    CharacterStatsPane.ClassBackground:Hide()
    
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
    if CharacterSecondaryHandSlot.BottomRightSlotTexture then
        CharacterSecondaryHandSlot.BottomRightSlotTexture:Hide()
    end
    local mh_region = select(14, CharacterMainHandSlot:GetRegions())
    if mh_region and mh_region.GetObjectType and mh_region:GetObjectType() == "Texture" then
        mh_region:Hide()
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

    -- Create the character model button
    modelbtn:SetSize(23, 23)
    modelbtn:SetPoint("BOTTOMLEFT", PaperDollItemsFrame, "BOTTOMLEFT", 60, 7)
    modelbtn:SetFrameStrata("HIGH")
    
    if option("hideshowchbtn") == true then
        modelbtn:Hide()
    else
        modelbtn:Show()
    end
    
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
    modelbtn:SetScript("OnEnter", function() GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
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
    
    modbg:ClearAllPoints()
    modbg:SetPoint("TOPLEFT", CharacterHeadSlot, "TOPLEFT", 0, 0)
    modbg:SetPoint("RIGHT", CharacterHandsSlot, "RIGHT", 0, 0)    
    modbg:SetPoint("BOTTOM", CharacterMainHandSlot, "BOTTOM", 0, 0)        
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
    CharacterModelScene:ClearAllPoints();
    CharacterModelScene:SetHeight(Height)
    CharacterModelScene:SetWidth(Height/CCS.ModelAspect)
    CharacterModelScene:SetPoint("LEFT", CharacterFrameBg, "LEFT", Left, -20);
    CharacterModelScene:SetFrameLevel(2)
    CharacterModelScene:Show();
    CharacterModelFrameBackgroundTopLeft:Hide();
    CharacterModelFrameBackgroundBotLeft:Hide();
    CharacterModelFrameBackgroundTopRight:Hide();
    CharacterModelFrameBackgroundBotRight:Hide();
    CharacterModelFrameBackgroundOverlay:ClearAllPoints()
    CharacterModelFrameBackgroundOverlay:SetPoint("TOPLEFT", CharacterModelFrameBackgroundTopLeft, "TOPLEFT", 0, 0)
    CharacterModelFrameBackgroundOverlay:SetPoint("BOTTOMRIGHT", CharacterModelFrameBackgroundBotRight, "BOTTOMRIGHT", 0, 70)
    CharacterModelFrameBackgroundOverlay:Hide()

    CreateExtraReputationRows(10)
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
local function MOPloopinspectitems()

    if not option("show_inspect") or InspectFrame.unit == nil then return end
      
    local unit = InspectFrame.unit
 
    for slotIndex = 1,17 do 
        if slotIndex ~= 4 then
            local itemLink = GetInventoryItemLink(unit, slotIndex)
            local itemID = itemLink and tonumber(itemLink:match("item:(%d+)"))

            if itemID then
                local texture = select(10, C_Item.GetItemInfo(itemID))
                if texture then
                    MOPupdateLocationInfo(unit, slotIndex, "Inspect")
                else
                    local slotFrameName = CCS.getSlotFrameName(slotIndex, "Inspect")
                    _G[slotFrameName]:RegisterEvent("GET_ITEM_INFO_RECEIVED")
                    _G[slotFrameName]:SetScript("OnEvent", function(self, event, arg)
                        if event == "GET_ITEM_INFO_RECEIVED" and arg == itemID then
                            MOPupdateLocationInfo(unit, slotIndex, "Inspect")
                            self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
                        end
                    end)
                end
            end
        end
    end 

    --Create Ilvl Frame and populate
    local iLvl = CCS.GetInspectItemLevel(unit) 
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
function CCS.MOPCharacterSheetEventHandler(event, ...)
    local arg1 = ...

    if CCS.GetCurrentVersion() ~= CCS.MOP then return end
    
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
        ReputationFrame_Update()
        --CurrencyFrame_Update()
        return true
    elseif event == "CCS_EVENT_CSHOW" then

        if not CCS.characterUpdatePending then
            CCS.characterUpdatePending = true
            C_Timer.After(0.2, function()
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
                MOPinitializeinspectframe()
                MOPloopinspectitems()
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
