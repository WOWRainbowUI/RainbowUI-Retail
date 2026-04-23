local addonName, ns = ...
local CCS = ns.CCS

if CCS.GetCurrentVersion() ~= CCS.RETAIL then
    return
end

local option = function(key) return CCS:GetOptionValue(key) end
local L = ns.L  -- grab the localization table
local visibleGroups = {}
local raidCount =  0
local module = {
    Name = "raidStats",
    CompatibleVersions = { CCS.RETAIL },
}

CCS.Modules[module.Name] = module

do
	for _, group in ipairs(CCS.RaidLayout) do
		local minTOC, maxTOC = unpack(group.tocinfo)
		if CCS.tocversion >= minTOC and CCS.tocversion <= maxTOC then
			table.insert(visibleGroups, group) -- store for later rendering
			raidCount = raidCount + 1
		end
	end
end

local function killcount(statID)
    local bc = GetStatistic(statID)
    if (bc == nil or bc == "--") then bc = 0 else bc = tonumber(bc) end
    return bc
end

local function getprogression(raidID)
    local normal, heroic, mythic = 0, 0, 0

    for _, group in ipairs(visibleGroups) do
        if not raidID or group.raid == raidID then
            for _, bossID in ipairs(group.bosses) do
                local data = CCS.SRI[bossID]
                if data then
                    if killcount(data.normal) > 0 then normal = normal + 1 end
                    if killcount(data.heroic) > 0 then heroic = heroic + 1 end
                    if killcount(data.mythic) > 0 then mythic = mythic + 1 end
                end
            end
        end
    end

    return normal, heroic, mythic
end

local function getraidstring(raidID, onlyHighest)
    if option("showraidprogress") ~= true then return "" end
    local totalBosses = 0
    local normal, heroic, mythic = getprogression(raidID)

    local name_string = ""
    for _, group in ipairs(CCS.RaidLayout) do
        if group.raid == raidID then
            name_string = group.shortname or RAID
            totalBosses = group.num_bosses
            break
        end
    end

    local M_color = CCS.RAID_DIFFICULTY_COLORS[3][4]
    local H_color = CCS.RAID_DIFFICULTY_COLORS[2][4]
    local N_color = CCS.RAID_DIFFICULTY_COLORS[1][4]

    local M_name = CCS.RAID_DIFFICULTY_NAMES[3]
    local H_name = CCS.RAID_DIFFICULTY_NAMES[2]
    local N_name = CCS.RAID_DIFFICULTY_NAMES[1]

    local returnvalue = ""

    if onlyHighest then
        if mythic > 0 then
            returnvalue = format("%s |c%s %s |r %s/%s\n", name_string, M_color, M_name, mythic, totalBosses)
        elseif heroic > 0 then
            returnvalue = format("%s |c%s %s |r %s/%s\n", name_string, H_color, H_name, heroic, totalBosses)
        elseif normal >= 0 then
            returnvalue = format("%s |c%s %s |r %s/%s\n", name_string, N_color, N_name, normal, totalBosses)
        end
    else
        if mythic > 0 then
            returnvalue = returnvalue .. format("%s |c%s %s |r %s/%s\n", name_string, M_color, M_name, mythic, totalBosses)
        end
        if heroic >= 0 then
            returnvalue = returnvalue .. format("%s |c%s %s |r %s/%s\n", name_string, H_color, H_name, heroic, totalBosses)
        end
        if normal >= 0 and mythic == 0 then
            returnvalue = returnvalue .. format("%s |c%s %s |r %s/%s\n", name_string, N_color, N_name, normal, totalBosses)
        end
    end

    return returnvalue
end

local function CreateHeaderRow(raidData, anchor, parent, rowHeight)
	local raidID = raidData.raid
	local normal, heroic, mythic = getprogression(raidID)

	local ccsrf_rx = _G["ccsrf_r"..raidID] or CreateFrame("Frame", "ccsrf_r"..raidID, parent)
	ccsrf_rx:SetSize(620, rowHeight)
	ccsrf_rx:Show()
	
	local ccsrf_rx_tex1 = _G["ccsrf_r"..raidID.."_tex1"] or ccsrf_rx:CreateTexture("ccsrf_r"..raidID.."_tex1", "BACKGROUND", nil, 3)
	ccsrf_rx_tex1:ClearAllPoints()
	ccsrf_rx_tex1:SetAllPoints()
	ccsrf_rx_tex1:SetTexture("Interface\\Masks\\SquareMask.BLP")
	ccsrf_rx_tex1:SetColorTexture(0, 0, 0, .9)
	ccsrf_rx_tex1:Show()
	
	-- Raid Name
	local ccsrf_rx_fs1 = _G["ccsrf_r"..raidID.."_fs1"] or  ccsrf_rx:CreateFontString("ccsrf_r"..raidID.."_fs1")
	ccsrf_rx_fs1:SetPoint("LEFT", ccsrf_rx, "LEFT", 10 ,0);
	ccsrf_rx_fs1:SetFont(option("fontname_raidtitle") or CCS.fontname, (option("fontsize_raidtitle") or 20), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsrf_rx_fs1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsrf_rx_fs1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                
	
	ccsrf_rx_fs1:SetSize(4*rowHeight, rowHeight)
	ccsrf_rx_fs1:SetJustifyH("LEFT")
	ccsrf_rx_fs1:SetText(string.format("%s",raidData.title))
	ccsrf_rx_fs1:Show()

	-- Kill Count Normal
	local ccsrf_rx_fs2 = _G["ccsrf_r"..raidID.."_fs2"] or  ccsrf_rx:CreateFontString("ccsrf_r"..raidID.."_fs2")
	ccsrf_rx_fs2:SetPoint("LEFT", ccsrf_rx, "LEFT", (2*rowHeight)+105 ,0);
	ccsrf_rx_fs2:SetFont(option("fontname_raiddiff") or CCS.fontname, (option("fontsize_raiddiff") or 18), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsrf_rx_fs2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsrf_rx_fs2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                
	
    ccsrf_rx_fs2:SetSize(200, rowHeight)
	ccsrf_rx_fs2:SetJustifyH("CENTER")
	ccsrf_rx_fs2:SetText(string.format("|cff1eff00%s %s|r\n(%s/%s)",PLAYER_DIFFICULTY1, KILLS, normal, raidData.num_bosses))
	ccsrf_rx_fs2:Show()

	-- Kill Count Heroic
	local ccsrf_rx_fs3 = _G["ccsrf_r"..raidID.."_fs3"] or  ccsrf_rx:CreateFontString("ccsrf_r"..raidID.."_fs3")
	ccsrf_rx_fs3:SetPoint("LEFT", ccsrf_rx, "LEFT", (2*rowHeight)+240 ,0);
	ccsrf_rx_fs3:SetFont(option("fontname_raiddiff") or CCS.fontname, (option("fontsize_raiddiff") or 18), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsrf_rx_fs3:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsrf_rx_fs3:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                
	
    ccsrf_rx_fs3:SetSize(200, rowHeight)
	ccsrf_rx_fs3:SetJustifyH("CENTER")
	ccsrf_rx_fs3:SetText(string.format("|cff0070dd%s %s|r\n(%s/%s)",PLAYER_DIFFICULTY2, KILLS, heroic, raidData.num_bosses))
	ccsrf_rx_fs3:Show()
	
	-- Kill Count Mythic
	local ccsrf_rx_fs4 = _G["ccsrf_r"..raidID.."_fs4"] or  ccsrf_rx:CreateFontString("ccsrf_r"..raidID.."_fs4")
	ccsrf_rx_fs4:SetPoint("LEFT", ccsrf_rx, "LEFT", (2*rowHeight)+370 ,0);
	ccsrf_rx_fs4:SetFont(option("fontname_raiddiff") or CCS.fontname, (option("fontsize_raiddiff") or 18), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsrf_rx_fs4:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsrf_rx_fs4:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                
	
    ccsrf_rx_fs4:SetSize(200, rowHeight)
	ccsrf_rx_fs4:SetJustifyH("CENTER")
	ccsrf_rx_fs4:SetText(string.format("|cffa335ee%s %s|r\n(%s/%s)",PLAYER_DIFFICULTY6, KILLS, mythic, raidData.num_bosses))
	ccsrf_rx_fs4:Show()
	
	ccsrf_rx.raidID = raidID
	ccsrf_rx.isHeaderRow = true
	
	return ccsrf_rx

end

local function CreateBossRow(bossData, anchor, parent, rowHeight, rowCount)
	local bossID = bossData.boss
	local ccsrf_bx = _G["ccsrf_b"..bossID] or CreateFrame("Frame", "ccsrf_b"..bossID, parent)
	ccsrf_bx:SetSize(620, rowHeight)
	ccsrf_bx:Show()
	
	local ccsrf_bx_tex1 = _G["ccsrf_b"..bossID.."_tex1"] or ccsrf_bx:CreateTexture("ccsrf_b"..bossID.."_tex1", "BACKGROUND", nil, 3)
	ccsrf_bx_tex1:ClearAllPoints()
	ccsrf_bx_tex1:SetAllPoints()
	ccsrf_bx_tex1:SetTexture("Interface\\Masks\\SquareMask.BLP")
	
	if rowCount%2 == 1 then 
		ccsrf_bx_tex1:SetColorTexture(.247, .247, .247, .6)
	else
		ccsrf_bx_tex1:SetColorTexture(.17, .17, .17, .4)
	end

	ccsrf_bx_tex1:Show()
	
	-- Boss Icon
	local ccsrf_bx_tex2 = _G["ccsrf_b"..bossID.."_tex2"] or ccsrf_bx:CreateTexture("ccsrf_b"..bossID.."_tex2", "ARTWORK", nil)
	ccsrf_bx_tex2:SetPoint("TOPLEFT", ccsrf_bx, "TOPLEFT", 5, 0)
	ccsrf_bx_tex2:SetSize(2*rowHeight, rowHeight)
	ccsrf_bx_tex2:SetTexture(bossData.icon)
	ccsrf_bx_tex2:Show()
	-- Boss Name
	local ccsrf_bx_fs1 = _G["ccsrf_b"..bossID.."_fs1"] or  ccsrf_bx:CreateFontString("ccsrf_b"..bossID.."_fs1")
	ccsrf_bx_fs1:SetPoint("LEFT", ccsrf_bx_tex2, "RIGHT", 10 ,0);
	ccsrf_bx_fs1:SetFont(option("fontname_raidboss") or CCS.fontname, (option("fontsize_raidboss") or 14), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsrf_bx_fs1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsrf_bx_fs1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                
	
	ccsrf_bx_fs1:SetSize(3.5*rowHeight, rowHeight)
	ccsrf_bx_fs1:SetJustifyH("LEFT")
	ccsrf_bx_fs1:SetText(string.format("%s",bossData.name))
	ccsrf_bx_fs1:Show()

	-- Kill Count Normal
	local ccsrf_bx_fs2 = _G["ccsrf_b"..bossID.."_fs2"] or  ccsrf_bx:CreateFontString("ccsrf_b"..bossID.."_fs2")
	--ccsrf_bx_fs2:SetPoint("LEFT", ccsrf_bx_tex2, "RIGHT", 275 ,0);
	ccsrf_bx_fs2:SetPoint("LEFT", ccsrf_bx_tex2, "RIGHT", 175 ,0);
	ccsrf_bx_fs2:SetFont(option("fontname_raidboss") or CCS.fontname, (option("fontsize_raidboss") or 14), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsrf_bx_fs2:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsrf_bx_fs2:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                
	
    ccsrf_bx_fs2:SetSize(50, rowHeight)
	ccsrf_bx_fs2:SetJustifyH("CENTER")

    local normalKills = killcount(bossData.normal)
    local normalColor = (normalKills > 0) and "|cff1eff00" or "|cffa0a0a0"
    ccsrf_bx_fs2:SetText(string.format("%s%-2.2s|r\n", normalColor, normalKills))
	ccsrf_bx_fs2:Show()

	-- Kill Count Heroic
	local ccsrf_bx_fs3 = _G["ccsrf_b"..bossID.."_fs3"] or  ccsrf_bx:CreateFontString("ccsrf_b"..bossID.."_fs3")
	ccsrf_bx_fs3:SetPoint("LEFT", ccsrf_bx_tex2, "RIGHT", 310 ,0);	
	ccsrf_bx_fs3:SetFont(option("fontname_raidboss") or CCS.fontname, (option("fontsize_raidboss") or 14), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsrf_bx_fs3:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsrf_bx_fs3:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                
	
    ccsrf_bx_fs3:SetSize(50, rowHeight)
	ccsrf_bx_fs3:SetJustifyH("CENTER")
    
    local heroicKills = killcount(bossData.heroic)
    local heroicColor = (heroicKills > 0) and "|cff0070dd" or "|cffa0a0a0"
    ccsrf_bx_fs3:SetText(string.format("%s%-2.2s|r\n", heroicColor, heroicKills))
	ccsrf_bx_fs3:Show()
	
	-- Kill Count Mythic
	local ccsrf_bx_fs4 = _G["ccsrf_b"..bossID.."_fs4"] or  ccsrf_bx:CreateFontString("ccsrf_b"..bossID.."_fs4")
	ccsrf_bx_fs4:SetPoint("LEFT", ccsrf_bx_tex2, "RIGHT", 440 ,0);
	ccsrf_bx_fs4:SetFont(option("fontname_raidboss") or CCS.fontname, (option("fontsize_raidboss") or 14), CCS.textoutline);
	if option("showfontshadow") == true then
		ccsrf_bx_fs4:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		ccsrf_bx_fs4:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                
	
    ccsrf_bx_fs4:SetSize(50, rowHeight)
	ccsrf_bx_fs4:SetJustifyH("CENTER")
    
    local mythicKills = killcount(bossData.mythic)
    local mythicColor = (mythicKills > 0) and "|cffa335ee" or "|cffa0a0a0"
    ccsrf_bx_fs4:SetText(string.format("%s%-2.2s|r\n", mythicColor, mythicKills))
	ccsrf_bx_fs4:Show()
	
	ccsrf_bx.bossID = bossID
	ccsrf_bx.isBossRow = true
	
	return ccsrf_bx

end


local function updateRaidStatusFrame()
	local textstring = ""
    if option("showraidprogress") ~= true or _G["ccsrf_sf"] == nil then return end

	for _, raidData in ipairs(visibleGroups) do
		local raidID = raidData.raid
		
		local headerFrame = _G["ccsrf_r"..raidID]
		if headerFrame and headerFrame.isHeaderRow then
			local normal, heroic, mythic = getprogression(raidID)		
			_G["ccsrf_r"..raidID.."_fs2"]:SetText(string.format("|cff1eff00%s %s|r\n(%s/%s)",PLAYER_DIFFICULTY1, KILLS, normal, raidData.num_bosses))
			_G["ccsrf_r"..raidID.."_fs3"]:SetText(string.format("|cff0070dd%s %s|r\n(%s/%s)",PLAYER_DIFFICULTY2, KILLS, heroic, raidData.num_bosses))
			_G["ccsrf_r"..raidID.."_fs4"]:SetText(string.format("|cffa335ee%s %s|r\n(%s/%s)",PLAYER_DIFFICULTY6, KILLS, mythic, raidData.num_bosses))
		end
		
		textstring = textstring .. (getraidstring( raidID ,(raidCount > 1)) or false)
	
		for _, bossID in ipairs(raidData.bosses) do
			local data = CCS.SRI[bossID]

			if data and data.boss and _G["ccsrf_b"..data.boss] then
				local n = killcount(data.normal)
				local h = killcount(data.heroic)
				local m = killcount(data.mythic)

				_G["ccsrf_b"..data.boss.."_fs2"]:SetText(format("%-2.2s", n))
				_G["ccsrf_b"..data.boss.."_fs3"]:SetText(format("%-2.2s", h))
				_G["ccsrf_b"..data.boss.."_fs4"]:SetText(format("%-2.2s", m))
			end

		end
	end

	if _G["ccsr_btnfs1"] then _G["ccsr_btnfs1"]:SetText(textstring) end

end
	
function module:Initialize()
    if option("showraidprogress") ~= true then return end
	if InCombatLockdown() then CCS.incombat = true return end
    local ccsr_btn = _G["ccsr_btn1"] or CreateFrame("Frame", "ccsr_btn1", CharacterHandsSlot)
    local btnfont1 = _G["ccsr_btnfs1"] or ccsr_btn:CreateFontString("ccsr_btnfs1")
    local textstring = ""
	local ccsrf_af = _G["ccsrf_af"] or CreateFrame("Frame", "ccsrf_af", CharacterFrame, "SecureHandlerBaseTemplate");
    local ccsrf_sf = _G["ccsrf_sf"] or CreateFrame("Frame", "ccsrf_sf", CharacterFrame, "SecureHandlerBaseTemplate");
    local rf_bg = _G["ccsrf_rf_bg"] or ccsrf_sf:CreateTexture("ccsrf_rf_bg", "BACKGROUND", nil, 1)        
    local rf_topbar = _G["ccsrf_rf_tb"] or ccsrf_sf:CreateTexture("ccsrf_rf_tb", "BACKGROUND", nil, 2)
    local rf_topstreaks = _G["ccsrf_rf_ts"] or ccsrf_sf:CreateTexture("ccsrf_rf_ts", "BACKGROUND", nil, 2)
    local rf_bottombar = _G["ccsrf_rf_bb"] or ccsrf_sf:CreateTexture("ccsrf_rf_bb", "BACKGROUND", nil, 2)

	if not ccsrf_sf.hooked then
		hooksecurefunc(ccsrf_sf, "Show", function() CCS.RaidProgressEventHandler() end)
		ccsrf_sf.hooked = true
	end
	
	_G["ccsrf_sf"]:SetScale(option("raid_sp_scale"))
-- Button 1	
	ccsr_btn:SetSize(150, 30)
    ccsr_btn:SetPoint("BOTTOMRIGHT", CharacterHandsSlot, "TOPRIGHT", 8, 20)
    ccsr_btn:SetFrameStrata("HIGH")
    ccsr_btn:Show()
    
    btnfont1:SetPoint("RIGHT", ccsr_btn, "RIGHT", -3 ,0)
    btnfont1:SetFont(option("fontname_raid") or CCS.fontname, (option("fontsize_raid") or 11), CCS.textoutline)
	if option("showfontshadow") == true then
		btnfont1:SetShadowColor(unpack(option("fontshadowcolor") or {0,0,0,1}))
		btnfont1:SetShadowOffset(option("fontshadowx") or 0, option("fontshadowy") or 0)
	end	                                                
	
    btnfont1:SetText(textstring)
    btnfont1:SetJustifyH("RIGHT")

---- Create the second button
    local ccsr_btn2 = _G["ccsr_btn2"] or CreateFrame("Button", "ccsr_btn2", PaperDollFrame)
	ccsr_btn2:SetSize(28, 28)
	ccsr_btn2:SetPoint("RIGHT", PaperDollSidebarTabs, "RIGHT", -0.5, -15)
	ccsr_btn2:SetPoint("TOPRIGHT", CharacterFrameCloseButton, "BOTTOMRIGHT", 0, -30)
	ccsr_btn2:SetFrameStrata("HIGH")

	ccsr_btn2._ccs_OnEnter = function(self)
		CCS.tooltip:SetOwner(self, "ANCHOR_RIGHT", -7, -11)
		GameTooltip_SetTitle(CCS.tooltip, format(GUILD_NEWS_FILTER3, ""))
		GameTooltip_AddNormalLine(CCS.tooltip, CLICK_HERE_FOR_MORE_INFO)
		CCS.tooltip:Show()
	end

	ccsr_btn2._ccs_OnLeave = function(self)
		CCS.tooltip:Hide()
	end
	if option("showr_altbtn") then
		local ccsr_btn2_tex = ccsr_btn2.tex or ccsr_btn2:CreateTexture(nil, "ARTWORK")
		ccsr_btn2.tex = ccsr_btn2_tex
		CCS:ApplyIconStyle(ccsr_btn2, "ightarrow", 20)
		ccsr_btn2_tex:SetAllPoints()
		ccsr_btn2_tex:Show()
		ccsr_btn2_tex:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\raid.png")
	else
		CCS:ApplyIconStyle(ccsr_btn2, "rightarrow", 20)
		if ccsr_btn2 and ccsr_btn2.tex ~= nil then
			ccsr_btn2.tex:Hide()
		end
	end

	-- Click behavior
	ccsr_btn2:SetScript("OnClick", function(self, button)
		PlaySound(SOUNDKIT.GS_LOGIN_CHANGE_REALM_OK)
		if not InCombatLockdown() then
			if _G["ccsm_sf"] and _G["ccsm_sf"]:IsShown() then _G["ccsm_sf"]:Hide() end
			
			if _G["ccsrf_sf"]:IsShown() then
				_G["ccsrf_sf"]:Hide()
			else
				_G["ccsrf_sf"]:Show()
			end
		else
			PlaySound(8959)
			RaidNotice_AddMessage(RaidBossEmoteFrame, format("%s", ERR_AFFECTING_COMBAT), ChatTypeInfo["SYSTEM"])
		end
	end)

		ccsr_btn2:Show()

    ccsrf_sf:ClearAllPoints()
	
	local hpad = option("hpad") or 279
	local offsetX = (60 + hpad)

    if C_AddOns.IsAddOnLoaded("DejaCharacterStats") then
		ccsrf_af:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", offsetX-63, 0)
		ccsrf_af:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMRIGHT", offsetX-63, 0)
	else
		ccsrf_af:SetPoint("TOPLEFT", CharacterFrame, "TOPRIGHT", offsetX, 0)
		ccsrf_af:SetPoint("BOTTOMLEFT", CharacterFrame, "BOTTOMRIGHT", offsetX, 0)
	end

	ccsrf_sf:SetPoint("TOPLEFT", ccsrf_af, "TOPRIGHT", 0, 0); 
	ccsrf_sf:SetSize(660, 640)  
    --ccsrf_sf:SetSize(900, 640)

	ccsrf_sf:SetScale(option("raid_sp_scale"))
    ccsrf_sf:SetFrameStrata("TOOLTIP")
    ccsrf_sf:SetShown(ccsrf_sf:IsVisible())
    -- Create the Raid Bosses Mouseover frame.    
    ccsr_btn:SetScript("OnEnter", function() 
            if option("showraidprogress") ~= true then return end
            if not InCombatLockdown() then
                ccsrf_sf:Show() 
            else
                PlaySound(8959)
                RaidNotice_AddMessage(RaidBossEmoteFrame, format("%s", ERR_AFFECTING_COMBAT), ChatTypeInfo["SYSTEM"])
            end
    end)

    ccsr_btn:SetScript("OnLeave", function() 
            if not InCombatLockdown() then 
                ccsrf_sf:Hide()
            end 
    end)
	
	if UnitLevel("player") < CCS.MaxLevel then
        ccsr_btn:Hide()
        ccsr_btn2:Hide()		
    end
	local bgr, bgg, bgb, bgalpha = option("bgcolor_raid")[1], option("bgcolor_raid")[2], option("bgcolor_raid")[3], option("bgcolor_raid")[4];
	
    rf_bg:ClearAllPoints()
    rf_bg:SetAllPoints()
    rf_bg:SetTexture("Interface\\Masks\\SquareMask.BLP")
	rf_bg:SetColorTexture(bgr,bgg,bgb,bgalpha)

    rf_topbar:ClearAllPoints()
    rf_topbar:SetPoint("TOPLEFT", ccsrf_sf, "TOPLEFT")
    rf_topbar:SetPoint("TOPRIGHT", ccsrf_sf, "TOPRIGHT")
    rf_topbar:SetHeight(16)
    rf_topbar:SetTexture("1723833")
    rf_topbar:SetTexCoord(0, 1, 0.586, .734)

    rf_topstreaks:ClearAllPoints()
    rf_topstreaks:SetPoint("TOPLEFT", rf_topbar, "BOTTOMLEFT")
    rf_topstreaks:SetPoint("TOPRIGHT", rf_topbar, "BOTTOMRIGHT")
    rf_topstreaks:SetHeight(43)
    rf_topstreaks:SetTexture("1723833")
    rf_topstreaks:SetTexCoord(0, 1, 0, .328)

    rf_bottombar:ClearAllPoints()
    rf_bottombar:SetPoint("BOTTOMLEFT", ccsrf_sf, "BOTTOMLEFT")
    rf_bottombar:SetPoint("BOTTOMRIGHT", ccsrf_sf, "BOTTOMRIGHT")
    rf_bottombar:SetHeight(16)

    rf_bottombar:SetTexture("4556093")
    rf_bottombar:SetTexCoord(0, .75, 0, .082) 
	
	local totalRows = 0
	local maxHeight = 600
	local rowSpacing = 2

	for _, group in ipairs(visibleGroups) do
			totalRows = totalRows + 1 -- header row
			totalRows = totalRows + #group.bosses -- boss rows
	end

	local totalSpacing = (totalRows - 1) * rowSpacing
	local availableHeight = maxHeight - totalSpacing
	local rowHeight = math.min(math.floor(availableHeight / totalRows), 50)
	local anchor = ccsrf_sf
	local layoutChain = {}  -- Ordered list of frames to anchor

    -- Phase 1: Create all frames
    for _, raidData in ipairs(visibleGroups) do
            -- Create header row for this raid
            local rowCount = 1      -- For zebra striping
            local header = CreateHeaderRow(raidData, anchor, ccsrf_sf, rowHeight)
            table.insert(layoutChain, {frame = header, isHeader = true})
            
            -- Loop through each boss in this raid group
            for _, bossID in ipairs(raidData.bosses) do
                local bossData = CCS.SRI[bossID]

                if bossData then
				    local row = CreateBossRow(bossData, anchor, ccsrf_sf, rowHeight, rowCount)
                    table.insert(layoutChain, {frame = row, isHeader = false})
					rowCount = rowCount + 1
				end
            end
    end

    -- Phase 2: Anchor all frames
    for i, entry in ipairs(layoutChain) do
        local frame = entry.frame
        if i == 1 and entry.isHeader then
            -- First header anchors to parent with custom offset
            frame:SetPoint("TOPLEFT", ccsrf_sf, "TOPLEFT", 18, -20)
        else
            local prev = layoutChain[i - 1].frame
            frame:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -2)
        end
    end

	updateRaidStatusFrame()

end

function CCS.RaidProgressEventHandler(event, ...)
    local arg1, arg2, arg3 = ...
	if option("showraidprogress") == false then return end

	if CCS.GetCurrentVersion() ~= CCS.RETAIL then return end
    if event == "PLAYER_LEVEL_UP" then
       C_Timer.After(.2, function() if UnitLevel("player") == CCS.MaxLevel then  _G["ccsr_btn"]:Show() end end)
    end

    if event == "CCS_EVENT_OPTIONS" and option("showraidprogress") == false then
        if _G["ccsr_btn1"] ~= nil then _G["ccsr_btn1"]:Hide() end
        if _G["ccsr_btn2"] ~= nil then _G["ccsr_btn2"]:Hide() end		
    end

	updateRaidStatusFrame();
    
end