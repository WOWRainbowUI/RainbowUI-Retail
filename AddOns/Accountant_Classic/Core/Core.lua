-- Accountant Classic core logic. See Readme.md for project history and acknowledgements.
-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
local _, private = ...

local _G = getfenv(0)
local pairs, ipairs, next, unpack, wipe = _G.pairs, _G.ipairs, _G.next, _G.unpack, _G.wipe
local tonumber = _G.tonumber
local table = _G.table
local tinsert, tsort = table.insert, table.sort
local string = _G.string
local format, gsub, strfind, strsub = string.format, string.gsub, string.find, string.sub
local math = _G.math
local floor, fmod, min = math.floor, math.fmod, math.min
-- WoW
local C_AddOns = _G.C_AddOns
local GetAddOnInfo, GetAddOnMetadata = C_AddOns.GetAddOnInfo, C_AddOns.GetAddOnMetadata
local PanelTemplates_TabResize, PanelTemplates_SetNumTabs, PanelTemplates_SetTab, PanelTemplates_UpdateTabs = PanelTemplates_TabResize, PanelTemplates_SetNumTabs, PanelTemplates_SetTab, PanelTemplates_UpdateTabs
local GetRealmName, UnitName, UnitFactionGroup, UnitClass = _G.GetRealmName, _G.UnitName, _G.UnitFactionGroup, _G.UnitClass
local C_CurrencyInfo, BlizzardGetBackpackCurrencyInfo, GetCurrencyInfo

local Client = private.Client
local AC_USE_MAINLINE_API = Client.isRetail or Client.isForever

if AC_USE_MAINLINE_API then
	C_CurrencyInfo = _G.C_CurrencyInfo
	BlizzardGetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
	GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
else
	BlizzardGetBackpackCurrencyInfo = _G.GetBackpackCurrencyInfo
	GetCurrencyInfo = _G.GetCurrencyInfo
end

-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local FOLDER_NAME = ...
local LibStub = _G.LibStub
if not LibStub then error(FOLDER_NAME .. " requires LibStub.") end

---@class ACAddon : AceAddon-3.0, AceConsole-3.0, AceHook-3.0
---@field constants table
---@field Name string
---@field LocName string
---@field Notes string
---@field Version string
---@field UpdateDate string
---@field Author string
---@field GetFormattedValue fun(self: ACAddon, value: number): string
---@field OpenOptions fun(self: ACAddon)
---@field SetupOptions fun(self: ACAddon)
---@field PopulateCharacterList fun(self: ACAddon, server: string, faction: string)
local addon = LibStub("AceAddon-3.0"):NewAddon(private.addon_name, "AceConsole-3.0", "AceHook-3.0")

addon.constants = private.constants
addon.constants.addon_name = private.addon_name
addon.Name = FOLDER_NAME

local _, locname, notes = GetAddOnInfo(addon.Name)
addon.LocName = locname
addon.Notes = notes
addon.icon = private.constants.iconTexture
-- ToC Metadata
addon.Version 		= GetAddOnMetadata(addon.Name, "Version")
addon.UpdateDate 	= GetAddOnMetadata(addon.Name, "X-Date")
addon.Author 		= GetAddOnMetadata(addon.Name, "Author")
_G.Accountant_Classic = addon

-- UIDropDownMenu
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

local MoneyFrame

local L = LibStub("AceLocale-3.0"):GetLocale(private.addon_name);
addon.LocName = L["Accountant Classic"]
local ACbutton = LibStub("LibDBIcon-1.0")
local AceDB = LibStub("AceDB-3.0")
-- Minimap button with LibDBIcon-1.0
local LDB = LibStub("LibDataBroker-1.1"):NewDataObject(private.addon_name);
if ( TitanPanelButton_UpdateButton ) then
	TitanPanelButton_UpdateButton(private.addon_name);
end

local AccountantClassic_Version = GetAddOnMetadata(private.addon_name, "Version");
--AccountantClassic_Disabled = false;
local AC_LOGTYPE = ""
local AC_CURRMONEY = 0
local AC_LASTSESSMONEY = 0
local AC_LASTMONEY = 0
local AC_CURRTAB = private.constants.currTab
local AC_MONTHS = private.constants.months

-- Number of Accountant Classic tabs; also the tab number of "All Character"
local AC_TABS = #private.constants.logmodes + 1
local AC_CHARSCROLL_LIST = {}
local AC_CURR_LINES = 0
local AC_CHAR_LINES = private.constants.maxCharLines -- Maximum lines for characters to be displayed. We have 18 lines of space but we are using the 18th line to present the total. 
local AC_SELECTED_CHAR_NUM
local AC_SELECTED_SERVER
local AC_SELECTED_FACTION
local AC_SORT_BY = "money"
local AC_SORT_ASC = false
local AccountantClassic_Verbose = nil;
--local AccountantClassic_GotName = false;

local AC_SERVER -- server key
local AC_PLAYER -- player key
-- Classic Forever now use so-called "Main Name" and "Secondary Name", 
-- it's more like the first and last name of the player. And both look to be mandatory. 
-- While in other game client, UnitName's second return value is actually the realmName
local function getPlayerStorageKey()
    local firstName, secondName = UnitName("player")
	local storageKey = firstName

    if Client.isForever and (secondName and secondName ~= "") then
        storageKey = firstName .. "-" .. secondName
    end

    return storageKey
end

local AC_FACTION = UnitFactionGroup("player")
local _, AC_CLASS = UnitClass("player")
local AC_SHOWALLCHARS = false

local AC_DATA = private.constants.onlineData

-- Log types present in this client, in the display order defined by constants.logtypes.
-- Iterating AC_DATA with pairs() gave a hash-dependent row order.
local AC_LOGTYPE_ORDER = {}
for _, logtype in ipairs(private.constants.logtypes) do
	if AC_DATA[logtype] then
		AC_LOGTYPE_ORDER[#AC_LOGTYPE_ORDER + 1] = logtype
	end
end

-- Reverse lookup: log mode name -> tab index (replaces repeated linear tableIndex() scans)
local AC_MODE_INDEX = {}
for index, mode in ipairs(private.constants.logmodes) do
	AC_MODE_INDEX[mode] = index
end
local AC_SESSION_TAB = AC_MODE_INDEX["Session"]

-- Previous-period modes are only written during period rollover, never by live logging.
local AC_PREVIOUS_MODES = { PrvDay = true, PrvWeek = true, PrvMonth = true, PrvYear = true }

local getClassColorPrefix = private.GetClassColorPrefix

-- Current date strings. These were previously captured once at file load, which meant
-- a session that crossed midnight / week / month / year never rolled the period data
-- over until the next /reload. refreshDates() keeps them current.
local cdate, cmonth, cyear
local function refreshDates()
	cdate = date("%d/%m/%y")
	cmonth = date("%m")
	cyear = date("%Y")
end
refreshDates()

local profile
-- Current character's saved data (Accountant_ClassicSaveData[AC_SERVER][AC_PLAYER]).
-- Kept local; it used to leak into _G.
local AccountantClassic_Profile
local AC_FIRSTLOADED = false

-- Updated by: kamusis
-- Priming flag for one-time baseline initialization
--
-- Rationale:
-- Historically, the addon used AC_FIRSTLOADED to block logging for the entire first
-- session of a character to avoid counting the current balance as a fake "income".
-- That prevented skew but also dropped all money changes during the first session.
--
-- The Priming Approach replaces that blanket suppression with a one-time baseline
-- initialization. We set AC_LASTMONEY to the current balance exactly once ("prime")
-- and then allow normal logging for the rest of the session. This avoids the initial
-- fake income without losing subsequent changes.
--
-- AC_LOG_PRIMED = false means baseline not initialized yet; the first safe path
-- (PLAYER_MONEY or CHAT_MSG_MONEY) will initialize it. After priming, logging runs
-- normally. We will also clear AC_FIRSTLOADED at that time to preserve intent.
local AC_LOG_PRIMED = false
local printMessage

--
-- One-time UI alert for baseline priming
--
-- We want to notify the player once per session when the addon performs the
-- baseline priming. Using a separate guard ensures we don't spam the UI when
-- multiple code paths (PLAYER_MONEY / CHAT_MSG_MONEY / updateLog) converge to
-- the same priming operation.
local AC_PRIMING_ALERTED = false
local function showPrimingAlert()
	if AC_PRIMING_ALERTED then return end
	AC_PRIMING_ALERTED = true
	-- One-time, noticeable chat message (yellow/orange) without using UIErrorsFrame.
	-- Rationale: keep it visible yet unobtrusive, and consistent across UIs where
	-- UIErrorsFrame may be hidden or styled away by other addons.
	local msg = format("|cffffd200[%s]: %s|r", L["Accountant Classic"], L["Initial balance captured. Tracking for subsequent money changes has started."])
	printMessage(msg)
end

local function primeBaseline()
	if AC_LOG_PRIMED then return end
	AC_LASTMONEY = GetMoney()
	if AccountantClassic_Profile and AccountantClassic_Profile["options"] then
		AccountantClassic_Profile["options"].totalcash = AC_LASTMONEY
	end
	AC_LOG_PRIMED = true
	AC_FIRSTLOADED = false
	showPrimingAlert()
end

local function newDefaultOptions()
	return {
		version = AccountantClassic_Version,
		date = cdate, -- to be used as "today"
		lastsessiondate = cdate,
		-- prvday,
		weekdate = "",
		-- prvdateweek,
		month = cmonth,
		-- prvmonth,
		weekstart = 5,
		curryear = cyear,
		-- prvyear,
		totalcash = 0,
		faction = AC_FACTION,
		class = AC_CLASS,
	}
end

local function orderednext(t, n)
	local key = t[t.__next]

	if not key then return end
	t.__next = t.__next + 1
	return key, t.__source[key]
end

local function orderedpairs(t, f)
	local keys, kn = {__source = t, __next = 1}, 1

	for k in pairs(t) do
		keys[kn], kn = k, kn + 1
	end
	tsort(keys, f)
	return orderednext, keys
end

-- function to check if user has all the options parameter, 
-- if not (due to some might be newly added), then add it with default value
local function updateOptions(player_options)
	for k, v in pairs(newDefaultOptions()) do
		if (player_options[k] == nil) then
			player_options[k] = v;
		end
	end
end

local function newZoneModeTable()
	local t = {}
	for _, logtype in ipairs(private.constants.logtypes) do
		t[logtype] = {}
	end
	return t
end

local function initZoneDB()
	if (Accountant_ClassicZoneDB == nil) then
		Accountant_ClassicZoneDB = { }
	end
	if (Accountant_ClassicZoneDB[AC_SERVER] == nil) then
		Accountant_ClassicZoneDB[AC_SERVER] = { }
	end
	if (Accountant_ClassicZoneDB[AC_SERVER][AC_PLAYER] == nil) then
		AC_FIRSTLOADED = true
		Accountant_ClassicZoneDB[AC_SERVER][AC_PLAYER] = {
			data = { }
		}
	end
	local zoneData = Accountant_ClassicZoneDB[AC_SERVER][AC_PLAYER]["data"]
	for _, v_logmode in ipairs(private.constants.logmodes) do
		if (zoneData[v_logmode] == nil) then
			zoneData[v_logmode] = newZoneModeTable()
		end
	end
end

local function initOptions()
	if (Accountant_ClassicSaveData == nil) then
		Accountant_ClassicSaveData = {};
	end
	if (Accountant_ClassicSaveData[AC_SERVER] == nil) then
		Accountant_ClassicSaveData[AC_SERVER] = {};
	end
	if (Accountant_ClassicSaveData[AC_SERVER][AC_PLAYER] == nil ) then
		Accountant_ClassicSaveData[AC_SERVER][AC_PLAYER] = {
			options = newDefaultOptions(),
			data = { },
		};
	end

	AccountantClassic_Profile = Accountant_ClassicSaveData[AC_SERVER][AC_PLAYER];

	updateOptions(AccountantClassic_Profile["options"]);
	initZoneDB();

	-- Seed the baseline immediately for a brand-new profile/session so the first
	-- real money change is not lost before the first PLAYER_MONEY event arrives.
	-- This must happen after ZoneDB initialization, because AC_FIRSTLOADED is set
	-- there for a truly fresh character/session.
	if AC_FIRSTLOADED
		or AccountantClassic_Profile["options"].totalcash == nil
		or (AccountantClassic_Profile["options"].totalcash == 0 and not next(AccountantClassic_Profile["data"])) then
		primeBaseline()
	elseif not AC_LOG_PRIMED then
		-- An existing profile already has a saved baseline from a previous session.
		-- Restore it without showing the one-time priming message again.
		AC_LASTMONEY = AccountantClassic_Profile["options"].totalcash or GetMoney()
		AC_LOG_PRIMED = true
		AC_FIRSTLOADED = false
	end
end

local function copyOptions()
	local oprofile = Accountant_ClassicSaveData[AC_SERVER][AC_PLAYER]["options"]
	local db = addon.db.profile

	if (not db or db.oprofileCopied) then return end

	db.showbutton = oprofile.showbutton
	db.showmoneyinfo = oprofile.showmoneyinfo
	db.showintrotip = oprofile.showintrotip
	db.showmoneyonbutton = oprofile.showmoneyonbutton
	db.showsessiononbutton = oprofile.showsessiononbutton
	db.cross_server = oprofile.cross_server
	db.trackzone = oprofile.trackzone
	db.tracksubzone = oprofile.tracksubzone
	db.breakupnumbers = oprofile.breakupnumbers

	db.oprofileCopied = true
end

local function arrangeAccountantClassicFrame()
	local f = _G["AccountantClassicFrame"]
	if not f then return end
	f:SetScale(profile.scale)
	f:SetAlpha(profile.alpha)
	local point, _, relativePoint, ofsx, ofsy = unpack(profile.AcFramePoint)
	f:ClearAllPoints()
	f:SetParent(UIParent)
	f:SetPoint(point or "TOPLEFT", nil, relativePoint or "TOPLEFT", ofsx or 0, ofsy or -104)
end

local setupServerDropDown, setupFactionDropDown, setupCharacterDropDown

function AccountantClassic_RegisterEvents(self)
		for _, value in pairs( private.constants.events ) do
			self:RegisterEvent( value );
		end
	--self:RegisterForDrag("LeftButton");
end

local function createACFrames()
	local parentName = "AccountantClassicFrame"
	local f = _G[parentName]
	if not f._accountantInitialized then
		f:GetScript("OnLoad")(f)
		f._accountantInitialized = true
	end
	for index = 1, 18 do
		local row = _G[parentName.."Row"..index]
		if row and not row.Title then
			AccountantClassic_InitializeRow(row)
		end
	end
	if not _G[parentName.."Tab1"] then
		AccountantClassic_CreateTabs(f)
	end

	if not f.HeaderSource then
		local function makeHeaderButton(name, x, width)
			local button = CreateFrame("Button", name, f)
			button:SetSize(width, 19)
			button:SetPoint("TOPLEFT", f, "TOPLEFT", x, -91)
			button:SetFrameStrata("HIGH")
			button:SetScript("OnEnter", function(self)
				if self.highlightTexture then
					self.highlightTexture:Show()
				else
					self.highlightTexture = self:CreateTexture(nil, "BACKGROUND")
					self.highlightTexture:SetAllPoints(self)
					self.highlightTexture:SetColorTexture(1, 1, 1, 0.2)
					self.highlightTexture:Show()
				end
			end)
			button:SetScript("OnLeave", function(self)
				if self.highlightTexture then
					self.highlightTexture:Hide()
				end
			end)
			return button
		end

		local function toggleSort(sortKey)
			if AC_SORT_BY == sortKey then
				AC_SORT_ASC = not AC_SORT_ASC
			else
				AC_SORT_BY = sortKey
				AC_SORT_ASC = true
			end
			if f and f:IsVisible() then
				AccountantClassic_OnShow()
			end
		end

		f.HeaderSource = makeHeaderButton(parentName.."HeaderSource", 21, 280)
		f.HeaderSource:SetScript("OnClick", function() toggleSort("name") end)

		f.HeaderIn = makeHeaderButton(parentName.."HeaderIn", 294, 160)
		f.HeaderIn:SetScript("OnClick", function() toggleSort("money") end)

		f.HeaderOut = makeHeaderButton(parentName.."HeaderOut", 455, 160)
		f.HeaderOut:SetScript("OnClick", function() toggleSort("date") end)
	end
	
	f.ServerDropDown = _G[parentName.."ServerDropDown"] 
	if not f.ServerDropDown then 
		f.ServerDropDown = LibDD:Create_UIDropDownMenu(parentName.."ServerDropDown", f)
		f.ServerDropDown:Hide()
		f.ServerDropDown:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -38)
		f.ServerDropDown.Label = f.ServerDropDown:CreateFontString(parentName.."ServerDropDownLabel", "BACKGROUND", "GameFontNormalSmall")
		f.ServerDropDown.Label:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 0)
		f.ServerDropDown:SetScript("OnShow", function(self)
			setupServerDropDown()
		end)
	end
	
	f.FactionDropDown = _G[parentName.."FactionDropDown"]
	if not f.FactionDropDown then 
		f.FactionDropDown = LibDD:Create_UIDropDownMenu(parentName.."FactionDropDown", f)
		f.FactionDropDown:Hide()
		f.FactionDropDown:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -62)
		f.FactionDropDown.Label = f.FactionDropDown:CreateFontString(parentName.."FactionDropDownLabel", "BACKGROUND", "GameFontNormalSmall")
		f.FactionDropDown.Label:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 0)
		f.FactionDropDown:SetScript("OnShow", function(self)
			setupFactionDropDown()
		end)
	end

	f.CharacterDropDown = _G[parentName.."CharacterDropDown"]
	if not f.CharacterDropDown then
		f.CharacterDropDown = LibDD:Create_UIDropDownMenu(parentName.."CharacterDropDown", f)
		f.CharacterDropDown:Hide()
		f.CharacterDropDown:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -62)
		f.CharacterDropDown.Label = f.CharacterDropDown:CreateFontString(parentName.."CharacterDropDownLabel", "BACKGROUND", "GameFontNormalSmall")
		f.CharacterDropDown.Label:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 0)
		f.CharacterDropDown:SetScript("OnShow", function(self)
			setupCharacterDropDown()
		end)
	end
	--[[
	-- Rows
	for i = 1, 18, 1 do
		local name = parentName.."Row"..i
		local sf = _G[name]
		if (not sf) then 
			sf = CreateFrame("Frame", name, f, AccountantClassicRowTemplate) 
		end
		if i == 1 then
			sf:SetPoint("TOPLEFT", f, "TOPLEFT", 21, -113)
		else
			local j = i-1
			sf:SetPoint("TOPLEFT", _G[name.."Row"..j], "TOPLEFT", 0, -1)
		end
		f[name] = sf
	end]]
end

local function setLabels()
	local f = _G["AccountantClassicFrame"]
	-- if current tab is All Chars tab
	if (AC_CURRTAB == AC_TABS) then
		AccountantClassicFrameResetButton:Hide()

		f.Source:SetText(L["Character"])
		f.In:SetText(L["Money"])
		f.Out:SetText(L["Updated"])
		local arrow = AC_SORT_ASC and L[" ^"] or L[" v"]
		if AC_SORT_BY == "name" then
			f.Source:SetText(L["Character"]..arrow)
		elseif AC_SORT_BY == "money" then
			f.In:SetText(L["Money"]..arrow)
		elseif AC_SORT_BY == "date" then
			f.Out:SetText(L["Updated"]..arrow)
		end
		f.TotalIn:SetText(L["Total Incomings"]..":")
		f.TotalOut:SetText(L["Total Outgoings"]..":")
		f.TotalFlow:SetText(L["Sum Total"]..":")
		f.TotalInValue:SetText("")
		f.TotalOutValue:SetText("")
		f.TotalFlowValue:SetText("")
		for i = 1, 18, 1 do
			_G["AccountantClassicFrameRow"..i.."Title".."_Text"]:SetText("")
			_G["AccountantClassicFrameRow"..i.."In".."_Text"]:SetText("")
			_G["AccountantClassicFrameRow"..i.."Out".."_Text"]:SetText("")
			_G["AccountantClassicFrameRow"..i.."Title"].logType = ""
			_G["AccountantClassicFrameRow"..i.."In"].logType = ""
			_G["AccountantClassicFrameRow"..i.."Out"].logType = ""
		end
		return
	else
		AccountantClassicFrameResetButton:Show()

		f.Source:SetText(L["Source"])
		f.In:SetText(L["Incomings"])
		f.Out:SetText(L["Outgoings"])
		f.TotalIn:SetText(L["Total Incomings"]..":")
		f.TotalOut:SetText(L["Total Outgoings"]..":")
		f.TotalFlow:SetText(L["Net Profit / Loss"]..":")

		-- Row Labels (auto generate)
		for i, key in ipairs(AC_LOGTYPE_ORDER) do
			AC_DATA[key].InPos = i
			_G["AccountantClassicFrameRow"..i.."Title".."_Text"]:SetText(AC_DATA[key].Title)
		end
	end
end

-- Portrait: the live portrait only exists for the logged-in character, so other
-- characters get their class icon and the "All Chars" selection gets the addon icon.
local CLASS_ICONS_TEXTURE = "Interface\\TargetingFrame\\UI-Classes-Circles"
local function setFramePortrait(serverkey, charkey, options)
	local portrait = _G["AccountantClassicFramePortrait"]
	if not portrait then return end

	if (serverkey == nil) then
		-- "All Chars" selection
		portrait:SetTexture(private.constants.iconTexture)
		portrait:SetTexCoord(0, 1, 0, 1)
		return
	end

	if (serverkey ~= AC_SERVER or charkey ~= AC_PLAYER) then
		local class = options and options.class
		local coords = class and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[class]
		if coords then
			portrait:SetTexture(CLASS_ICONS_TEXTURE)
			portrait:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
			return
		end
	end

	-- Logged-in character (or unknown class): live portrait
	portrait:SetTexCoord(0, 1, 0, 1)
	SetPortraitTexture(portrait, "player")
end

-- Window title, optionally followed by the character being viewed. Realm names can be
-- very long (e.g. Forever "CAMWOW TW4 Realm 1 PvE"), which pushes the character name
-- out of the character dropdown, so the selection is repeated in the title.
local function setFrameTitle(suffix)
	local header = _G["AccountantClassicFrameTitleText"]
	if not header then return end
	if suffix and suffix ~= "" then
		header:SetText(L["Accountant Classic"].." - "..suffix)
	else
		header:SetText(L["Accountant Classic"])
	end
end

local function settleTabText()
	if (Client.isAnyClassic) then
		local TabText = private.constants.tabText
		for i = 1, AC_TABS do
			local tab = _G["AccountantClassicFrameTab"..i]
			tab:SetText(TabText[i])
			PanelTemplates_TabResize(tab, 0, nil, 36, 88)
		end
	end

	if (Client.isRetail or Client.isForever) then
		AccountantClassicFrame.numTabs = AC_TABS
	else
		PanelTemplates_SetNumTabs(AccountantClassicFrame, AC_TABS)
	end

	PanelTemplates_SetTab(AccountantClassicFrame, AccountantClassicFrameTab1)
	PanelTemplates_UpdateTabs(AccountantClassicFrame)
end

-- "dd/mm/yy" -> "yymmdd" so that string comparison sorts chronologically
local function sortableSessionDate(s)
	if type(s) ~= "string" or #s < 8 then return "" end
	return strsub(s, 7, 8)..strsub(s, 4, 5)..strsub(s, 1, 2)
end

local function compareCharacters(a, b)
	local aServer, aChar = a[1], a[2]
	local bServer, bChar = b[1], b[2]
	local aOpts = Accountant_ClassicSaveData[aServer][aChar].options
	local bOpts = Accountant_ClassicSaveData[bServer][bChar].options
	local aValue, bValue
	if AC_SORT_BY == "name" then
		aValue, bValue = aServer.."-"..aChar, bServer.."-"..bChar
	elseif AC_SORT_BY == "money" then
		aValue, bValue = aOpts.totalcash or 0, bOpts.totalcash or 0
	elseif AC_SORT_BY == "date" then
		aValue, bValue = sortableSessionDate(aOpts.lastsessiondate), sortableSessionDate(bOpts.lastsessiondate)
	else
		return false
	end
	if AC_SORT_ASC then
		return aValue < bValue
	end
	return aValue > bValue
end

function addon:PopulateCharacterList(server, faction)
	wipe(AC_CHARSCROLL_LIST)

	local allFactions = (not faction or faction == "All")
	local function addServer(serverkey, serverData)
		for charkey, charvalue in orderedpairs(serverData) do
			if allFactions or (charvalue.options and charvalue.options.faction == faction) then
				AC_CHARSCROLL_LIST[#AC_CHARSCROLL_LIST + 1] = { serverkey, charkey }
			end
		end
	end

	if (not server or server == "All") then
		for serverkey, serverData in orderedpairs(Accountant_ClassicSaveData) do
			addServer(serverkey, serverData)
		end
	elseif Accountant_ClassicSaveData[server] then
		addServer(server, Accountant_ClassicSaveData[server])
	end

	if AC_CURRTAB == AC_TABS and AC_SORT_BY then
		tsort(AC_CHARSCROLL_LIST, compareCharacters)
	end

	AC_CURR_LINES = #AC_CHARSCROLL_LIST

	-- Create and align the entry buttons we need. The faux scroll frame only ever
	-- displays AC_CHAR_LINES rows, so there is no need for one frame per character.
	for j = 1, min(AC_CURR_LINES, AC_CHAR_LINES) do
		if (not _G["AccountantClassicCharacterEntry"..j]) then
			local f = AccountantClassic_CreateRow(AccountantClassicFrame, "AccountantClassicCharacterEntry"..j)
			-- Keep the rows above the faux scroll frame (same parent) so they receive mouse-over
			f:SetFrameLevel(AccountantClassicScrollBar:GetFrameLevel() + 2)
			if j == 1 then
				f:SetPoint("TOPLEFT", "AccountantClassicScrollBar", "TOPLEFT", 0, 0)
			else
				f:SetPoint("TOPLEFT", "AccountantClassicCharacterEntry"..(j - 1), "BOTTOMLEFT", 0, -1)
			end
		end
	end
end

local function serverDropDownOnClick(self)
	LibDD:UIDropDownMenu_SetSelectedValue(AccountantClassicFrameServerDropDown, self.value)
	AC_SELECTED_SERVER = self.value
	addon:PopulateCharacterList(AC_SELECTED_SERVER, AC_SELECTED_FACTION)
	AccountantClassic_OnShow()
end

local function serverDropDownInit()
	local info
	for k in orderedpairs(Accountant_ClassicSaveData) do
		info = LibDD:UIDropDownMenu_CreateInfo()
		info.text = k
		info.value = k
		info.func = serverDropDownOnClick
		LibDD:UIDropDownMenu_AddButton(info)
	end
	
	-- Added All Chars to dropdown
	info = LibDD:UIDropDownMenu_CreateInfo()
	info.text = L["All Servers"]
	info.value = "All"
	info.tooltipTitle = L["Show all realms' characters info"]
	info.tooltipOnButton = true
	info.func = serverDropDownOnClick
	LibDD:UIDropDownMenu_AddButton(info)
end

setupServerDropDown = function()
	LibDD:UIDropDownMenu_Initialize(AccountantClassicFrameServerDropDown, serverDropDownInit)
	
	if (profile.cross_server and not AC_SELECTED_SERVER) then
		AC_SELECTED_SERVER = "All"
		LibDD:UIDropDownMenu_SetSelectedValue(AccountantClassicFrameServerDropDown, "All")
	else
		LibDD:UIDropDownMenu_SetSelectedValue(AccountantClassicFrameServerDropDown, AC_SELECTED_SERVER or AC_SERVER)
	end
	LibDD:UIDropDownMenu_SetWidth(AccountantClassicFrameServerDropDown, 200)
end


local function factionDropDownOnClick(self)
	LibDD:UIDropDownMenu_SetSelectedValue(AccountantClassicFrameFactionDropDown, self.value)
	AC_SELECTED_FACTION = self.value
	addon:PopulateCharacterList(AC_SELECTED_SERVER, AC_SELECTED_FACTION)
	AccountantClassic_OnShow()
end

local function factionDropDownInit()
	local info
	info = LibDD:UIDropDownMenu_CreateInfo()
	info.icon = "Interface\\PVPFrame\\PVP-Currency-Alliance"
	info.text = FACTION_ALLIANCE
	info.colorCode = "|cff7babe0"
	info.value = "Alliance"
	info.arg1 = "Alliance"
	info.func = factionDropDownOnClick
	LibDD:UIDropDownMenu_AddButton(info)

	info = LibDD:UIDropDownMenu_CreateInfo()
	info.icon = "Interface\\PVPFrame\\PVP-Currency-Horde"
	info.text = FACTION_HORDE
	info.colorCode = "|cffda6955"
	info.value = "Horde"
	info.arg1 = "Horde"
	info.func = factionDropDownOnClick
	LibDD:UIDropDownMenu_AddButton(info)
	
	-- Added All Factions to dropdown
	info = LibDD:UIDropDownMenu_CreateInfo()
	info.text = L["All Factions"]
	info.value = "All"
	info.func = factionDropDownOnClick
	LibDD:UIDropDownMenu_AddButton(info)
end

setupFactionDropDown = function()
	LibDD:UIDropDownMenu_Initialize(AccountantClassicFrameFactionDropDown, factionDropDownInit)
	if (profile.show_allFactions and not AC_SELECTED_FACTION) then
		AC_SELECTED_FACTION = "All"
		LibDD:UIDropDownMenu_SetSelectedValue(AccountantClassicFrameFactionDropDown, "All")
	else
		LibDD:UIDropDownMenu_SetSelectedValue(AccountantClassicFrameFactionDropDown, AC_SELECTED_FACTION or AC_FACTION)
	end
	LibDD:UIDropDownMenu_SetWidth(AccountantClassicFrameFactionDropDown, 200)
end


-- Character selection for the period tabs.
-- The selection used to be remembered as a list index, which pointed at a different
-- character as soon as a character was added or removed, and on first open the
-- dropdown showed the remembered entry while the data shown was the current character.
-- We now remember a stable key ("server<TAB>character", or ALL_CHARS_KEY) and resolve
-- it to an index in AC_CHARSCROLL_LIST whenever needed.
local ALL_CHARS_KEY = "*"
local AC_SELECTED_CHAR_KEY

local function characterKey(serverkey, charkey)
	return serverkey.."\t"..charkey
end

local function findCharacterIndex(key)
	if key == ALL_CHARS_KEY then
		return #AC_CHARSCROLL_LIST + 1
	end
	for i = 1, #AC_CHARSCROLL_LIST do
		local entry = AC_CHARSCROLL_LIST[i]
		if characterKey(entry[1], entry[2]) == key then
			return i
		end
	end
end

local function resolveSelectedCharacter()
	if not AC_SELECTED_CHAR_KEY then
		if profile.rememberSelectedCharacter and profile.selectedCharacterKey then
			AC_SELECTED_CHAR_KEY = profile.selectedCharacterKey
		else
			AC_SELECTED_CHAR_KEY = characterKey(AC_SERVER, AC_PLAYER)
		end
	end
	AC_SELECTED_CHAR_NUM = findCharacterIndex(AC_SELECTED_CHAR_KEY)
		or findCharacterIndex(characterKey(AC_SERVER, AC_PLAYER))
		or 1
	return AC_SELECTED_CHAR_NUM
end

local function characterDropDownOnClick(self)
	LibDD:UIDropDownMenu_SetSelectedValue(AccountantClassicFrameCharacterDropDown, self.value)
	AC_SELECTED_CHAR_NUM = self.value
	AC_SELECTED_CHAR_KEY = (self.arg1 and self.arg2) and characterKey(self.arg1, self.arg2) or ALL_CHARS_KEY
	profile.selectedCharacterKey = AC_SELECTED_CHAR_KEY
	profile.selectedCharacter = nil -- legacy index-based value
	AccountantClassic_OnShow()
end

local function characterDropDownInit()
	local info
	for i = 1, #AC_CHARSCROLL_LIST do
		local serverkey = AC_CHARSCROLL_LIST[i][1]
		local charkey = AC_CHARSCROLL_LIST[i][2]
		local options = Accountant_ClassicSaveData[serverkey][charkey]["options"]
		info = LibDD:UIDropDownMenu_CreateInfo()
		local factionstr = options.faction
		info.icon = factionstr and "Interface\\PVPFrame\\PVP-Currency-"..factionstr or nil

		local colorPrefix = getClassColorPrefix(options.class)
		info.colorCode = colorPrefix ~= "" and colorPrefix or nil

		info.text = serverkey.." - "..charkey
		info.value = i
		info.arg1 = serverkey
		info.arg2 = charkey
		info.func = characterDropDownOnClick
		LibDD:UIDropDownMenu_AddButton(info)
	end

	-- Added All Chars to dropdown
	info = LibDD:UIDropDownMenu_CreateInfo()
	info.text = L["All Chars"]
	info.value = #AC_CHARSCROLL_LIST + 1
	info.tooltipTitle = L["Show all characters' incoming and outgoing data."]
	info.tooltipOnButton = true
	info.func = characterDropDownOnClick
	LibDD:UIDropDownMenu_AddButton(info)
end

setupCharacterDropDown = function()
	LibDD:UIDropDownMenu_Initialize(AccountantClassicFrameCharacterDropDown, characterDropDownInit)
	if not profile.rememberSelectedCharacter then
		-- Without "remember", every time the dropdown appears it starts at the current character.
		AC_SELECTED_CHAR_KEY = nil
	end
	LibDD:UIDropDownMenu_SetSelectedValue(AccountantClassicFrameCharacterDropDown, resolveSelectedCharacter())
	LibDD:UIDropDownMenu_SetWidth(AccountantClassicFrameCharacterDropDown, 200)
end

-- Period rollover definitions: options key holding the current period, options key that
-- receives the previous period, data mode, previous data mode.
local AC_PERIODS = {
	{ "date",     "prvday",      "Day",   "PrvDay"   },
	{ "dateweek", "prvdateweek", "Week",  "PrvWeek"  },
	{ "month",    "prvmonth",    "Month", "PrvMonth" },
	{ "curryear", "prvyear",     "Year",  "PrvYear"  },
}

local function rollAmounts(logData, mode, prvMode)
	local cur = logData[mode]
	if not cur then
		cur = { In = 0, Out = 0 }
		logData[mode] = cur
	end
	local prv = logData[prvMode]
	if not prv then
		prv = { In = 0, Out = 0 }
		logData[prvMode] = prv
	end
	prv.In, prv.Out = cur.In or 0, cur.Out or 0
	cur.In, cur.Out = 0, 0
end

local function rollPeriod(serverkey, charkey, charData, period, current)
	local optKey, prvOptKey, mode, prvMode = period[1], period[2], period[3], period[4]
	local options = charData.options
	if options[optKey] == current then return end

	options[prvOptKey] = options[optKey]
	for _, logData in pairs(charData.data) do
		rollAmounts(logData, mode, prvMode)
	end

	-- The live in-memory copy for the current character
	if (serverkey == AC_SERVER and charkey == AC_PLAYER) then
		for _, logData in pairs(AC_DATA) do
			if logData[mode] then
				rollAmounts(logData, mode, prvMode)
			end
		end
	end

	-- ZoneDB: the current period becomes the previous one, then start a fresh period
	local zoneServer = Accountant_ClassicZoneDB and Accountant_ClassicZoneDB[serverkey]
	local zoneChar = zoneServer and zoneServer[charkey]
	local zoneData = zoneChar and zoneChar.data
	if (zoneData and zoneData[mode]) then
		zoneData[prvMode] = zoneData[mode]
		zoneData[mode] = newZoneModeTable()
	end

	options[optKey] = current
end

-- Since 2016/12/17 we support showing a specific character's or all characters' data in
-- each log mode, so period shifting has to be applied to every character, not just the
-- current one. This is checked on load, on every money update and whenever the main
-- frame is shown. A full pass over all characters is only needed when the period key
-- actually changed, so the result is cached.
local AC_LAST_SHIFT_KEY
local updateLDBText
local function shiftLogs()
	refreshDates()
	local week = addon:WeekStart()
	local shiftKey = cdate.."|"..week.."|"..cmonth.."|"..cyear
	if shiftKey == AC_LAST_SHIFT_KEY then return end
	AC_LAST_SHIFT_KEY = shiftKey

	local currentValues = { cdate, week, cmonth, cyear }
	for serverkey, serverData in pairs(Accountant_ClassicSaveData) do
		for charkey, charData in pairs(serverData) do
			if charData.options and charData.data then
				-- lastsessiondate backfill for characters saved by very old versions
				if (charData.options.lastsessiondate == nil) then
					charData.options.lastsessiondate = charData.options["date"]
				end
				for index, period in ipairs(AC_PERIODS) do
					rollPeriod(serverkey, charkey, charData, period, currentValues[index])
				end
			end
		end
	end

	if updateLDBText then updateLDBText() end
end

local function loadData()
	refreshDates()
	local profileData = AccountantClassic_Profile["data"]
	for order, key in ipairs(AC_LOGTYPE_ORDER) do
		if (profileData[key] == nil) then
			profileData[key] = { }
		end
		for _, mode in ipairs(private.constants.logmodes) do
			if (profileData[key][mode] == nil or mode == "Session") then
				profileData[key][mode] = {In=0, Out=0};
			end
			AC_DATA[key][mode] = {
				In = profileData[key][mode].In or 0,
				Out = profileData[key][mode].Out or 0,
			}
		end
		AC_DATA[key].order = order
	end

	-- ZoneDB handling
	-- Reset session DB
	Accountant_ClassicZoneDB[AC_SERVER][AC_PLAYER]["data"]["Session"] = newZoneModeTable()

	AccountantClassic_Profile["options"].version = AccountantClassic_Version;
	-- Here we retrieve the last session money before we set the option-value to the current one
	AC_LASTSESSMONEY = AccountantClassic_Profile["options"].totalcash;
	AccountantClassic_Profile["options"].totalcash = GetMoney();

	shiftLogs();

	AccountantClassic_Profile["options"].lastsessiondate = cdate;
end

local niceCash

local function getZoneText()
	local zoneText = GetZoneText()
	-- For the case when player is in dungeon or raid, track on subzone make less sense
	if (profile.tracksubzone == true and not IsInInstance()) then
		local subZoneText = GetSubZoneText()
		if (subZoneText and subZoneText ~= "") then
			zoneText = format("%s - %s", zoneText, subZoneText)
		end
	end
	return zoneText
end

local function updateLog()
	-- Updated by: kamusis
	-- One-time baseline priming for first-load sessions
	--
	-- Explanation:
	-- Instead of suppressing the entire first session (which would miss all money
	-- changes), we perform a single baseline initialization. When AC_FIRSTLOADED is
	-- true and we have not primed yet (AC_LOG_PRIMED is false), we set
	-- AC_LASTMONEY to the current balance and store it in options.totalcash. Then we
	-- mark AC_LOG_PRIMED = true and clear AC_FIRSTLOADED so subsequent calls proceed
	-- with normal diff-based logging. We return immediately here to avoid treating
	-- the initial balance as an income/outgoing delta.
	if AC_FIRSTLOADED and not AC_LOG_PRIMED then
		primeBaseline()
		return
	end

	shiftLogs();

	-- calculating diff money
	AC_CURRMONEY = GetMoney()
	AccountantClassic_Profile["options"].totalcash = AC_CURRMONEY
	local diff = AC_CURRMONEY - (AC_LASTMONEY or AC_CURRMONEY)
	AC_LASTMONEY = AC_CURRMONEY
	if (diff == 0) then
		return
	end

	local logtype = AC_LOGTYPE;
	if (logtype == "" or not AC_DATA[logtype]) then logtype = "OTHER"; end

	local flow = (diff > 0) and "In" or "Out"
	local amount = (diff > 0) and diff or -diff
	local profileData = AccountantClassic_Profile["data"][logtype]

	-- ZoneDB
	local zoneModes, zoneText
	if (profile.trackzone == true) then
		zoneModes = Accountant_ClassicZoneDB[AC_SERVER][AC_PLAYER]["data"]
		zoneText = getZoneText()
	end

	for _, logmode in ipairs(private.constants.logmodes) do
		-- data in previous time period should not be touched
		if not AC_PREVIOUS_MODES[logmode] then
			local live = AC_DATA[logtype][logmode]
			live[flow] = live[flow] + amount
			profileData[logmode][flow] = live[flow]

			if zoneModes then
				local byMode = zoneModes[logmode]
				if not byMode then
					byMode = newZoneModeTable()
					zoneModes[logmode] = byMode
				end
				local byType = byMode[logtype]
				if not byType then
					byType = {}
					byMode[logtype] = byType
				end
				local entry = byType[zoneText]
				if not entry then
					entry = { In = 0, Out = 0 }
					byType[zoneText] = entry
				end
				entry[flow] = (entry[flow] or 0) + amount
			end
		end
	end
	if AccountantClassic_Verbose then
		printMessage(((diff > 0) and "Gained " or "Lost ")..niceCash(amount).." from "..logtype)
	end

	-- special case mode resets
	if AC_LOGTYPE == "REPAIRS" then
		AC_LOGTYPE = "MERCH";
	end

	updateLDBText()
	if AccountantClassicFrame:IsVisible() then
		AccountantClassic_OnShow();
	end
end

local function accountantSlash(msg)
	if msg == nil or msg == "" then
		msg = "log"
	end
	local args = {n=0}
	local function helper(word) tinsert(args, word) end
	-- Updated by: kamusis
	-- Silence linter about discarding return values; we only need the callback side-effect.
	local _ = gsub(msg, "[_%w]+", helper)
	if args[1] == 'log'  then
		ShowUIPanel(AccountantClassicFrame)
	elseif args[1] == 'verbose' then
		if AccountantClassic_Verbose == nil then
			AccountantClassic_Verbose = 1
			printMessage("Verbose Mode On")
		else
			AccountantClassic_Verbose = nil;
			printMessage("Verbose Mode Off")
		end
	elseif args[1] == 'week' then
		printMessage(addon:WeekStart())
	else
		printMessage("/accountant log\n")
	end
end

-- codes by Tntdruid
local function detectAhMail()
	local _, totalItems = GetInboxNumItems();
	for x = 1, totalItems do	
		-- invoiceType, itemName, playerName, bid, buyout, deposit, consignment = GetInboxInvoiceInfo(index);
		--	invoiceType : String - type of invoice ("buyer", "seller", or "seller_temp_invoice").
		local invoiceType = GetInboxInvoiceInfo(x);
		if (invoiceType == "seller") then
			return true;
		end
	end
end

local function onShareMoney(arg1)
	local oldType = AC_LOGTYPE;
	if (oldType == "LOOT") then
		return;
	end

	local money;

	-- Parse the message for money gained.
	local _, _, gold = strfind(arg1, L["(%d+) Gold"])
	local _, _, silver = strfind(arg1, L["(%d+) Silver"])
	local _, _, copper = strfind(arg1, L["(%d+) Copper"])
	if (gold) then
		gold = tonumber(gold);
	else
		gold = 0;
	end
	if (silver) then
		silver = tonumber(silver);
	else
		silver = 0;
	end
	if (copper) then
		copper = tonumber(copper);
	else
		copper = 0;
	end

	money = copper + silver * 100 + gold * 10000
	-- Updated by: kamusis
	-- Baseline priming guard for first-load sessions
	--
	-- If the very first event we observe is CHAT_MSG_MONEY (shared loot message), we
	-- must ensure we have a proper baseline before attempting to force-update logs.
	-- Otherwise, we would manipulate AC_LASTMONEY and then have updateLog() perform
	-- the one-time priming, which could lead to inconsistent AC_LASTMONEY values.
	--
	-- Therefore, when AC_FIRSTLOADED and not AC_LOG_PRIMED, we prime baseline here
	-- and return without recording this message. Subsequent money changes will be
	-- tracked normally. This mirrors the priming path used for PLAYER_MONEY.
	if AC_FIRSTLOADED and not AC_LOG_PRIMED then
		primeBaseline()
		return
	end

	if (not AC_LASTMONEY) then
		AC_LASTMONEY = 0;
	end

	-- This will force a money update with calculated amount.
	AC_LASTMONEY = AC_LASTMONEY - money;
	AC_LOGTYPE = "LOOT";
	updateLog();
	AC_LOGTYPE = oldType;

	-- This will suppress the incoming PLAYER_MONEY event.
	AC_LASTMONEY = AC_LASTMONEY + money;

end

niceCash = function(amount)
	local agold = 10000;
	local asilver = 100;
	local outstr = "";
	local gold = 0;
	local silver = 0;
	local cent = 0;

	if amount >= agold then
		gold = floor(amount / agold);
		outstr = "|cFFFFFF00" .. gold .. L["g "];
	end
	amount = amount - (gold * agold);
	if amount >= asilver then
		silver = floor(amount / asilver);
		local silverDisplay = silver < 10 and " " .. silver or tostring(silver);
		outstr = outstr .. "|cFFDDDDDD" .. silverDisplay .. L["s "];
	end
	amount = amount - (silver * asilver);
	if amount > 0 then
		cent = amount;
		local centDisplay = cent < 10 and " " .. cent or tostring(cent);
		outstr = outstr .. "|cFFFF6600" .. centDisplay .. L["c"];
	end
	outstr = outstr.."|r";
	return outstr;
end

-- code adopted from SellTrash and MoneyFrame.lua
local COPPER_PER_GOLD = COPPER_PER_SILVER * SILVER_PER_GOLD
local TMP_GOLD_AMOUNT_TEXTURE = "%s|TInterface\\MoneyFrame\\UI-GoldIcon:%d:%d:2:0|t"
local TMP_SILVER_AMOUNT_TEXTURE = "%02d|TInterface\\MoneyFrame\\UI-SilverIcon:%d:%d:2:0|t"
local TMP_COPPER_AMOUNT_TEXTURE = "%02d|TInterface\\MoneyFrame\\UI-CopperIcon:%d:%d:2:0|t"
local FORMAT_GOLD = TMP_GOLD_AMOUNT_TEXTURE.." "..TMP_SILVER_AMOUNT_TEXTURE.." "..TMP_COPPER_AMOUNT_TEXTURE
local FORMAT_SILVER = SILVER_AMOUNT_TEXTURE.." "..TMP_COPPER_AMOUNT_TEXTURE

function addon:GetFormattedValue(amount)
	local gold = floor(amount / COPPER_PER_GOLD);
	local goldDisplay = profile.breakupnumbers and BreakUpLargeNumbers(gold) or gold;
	local silver = floor((amount - (gold * COPPER_PER_GOLD)) / COPPER_PER_SILVER);
	local copper = fmod(amount, COPPER_PER_SILVER);

	if (gold >0) then
		return format(FORMAT_GOLD, goldDisplay, 0, 0, silver, 0, 0, copper, 0, 0);
	elseif (silver >0) then
		return format(FORMAT_SILVER, silver, 0, 0, copper, 0, 0);
	elseif (copper >0) then
		return format(COPPER_AMOUNT_TEXTURE, copper, 0, 0);
	else
		return "";
	end
end

local function getFormattedCurrency(currencyID)
	local name, amount, icon
	if (AC_USE_MAINLINE_API) then
		local info = GetCurrencyInfo(currencyID)
		name = info.name
		amount = info.quantity
		icon = info.iconFileID
	else
		name, amount, icon = GetCurrencyInfo(currencyID)
	end

	if amount and amount > 0 then
		local amountText = profile.breakupnumbers and BreakUpLargeNumbers(amount) or tostring(amount)
		if tonumber(amount) < 10 then
			amountText = " " .. amountText
		end
		return format("%s|T%s:%d:%d:2:0|t ", amountText, icon, 0, 0)
	end

	return ""
end

function addon:WeekStart()
	local oneday = 86400
	local ct = time()
	local weekstart = tonumber(addon.db.profile.weekstart) or 5
	-- wday: 1 = Sunday ... 7 = Saturday, same as the weekstart option
	local daysBack = (date("*t", ct).wday - weekstart) % 7
	return tostring(date("%m/%d/%y", ct - daysBack * oneday))
end

local function parseDateStrings(s, typ)
	local mm, dd, yy;
	if not s then
		return ""
	end
	local sdate = s;
	
	if (typ == 1) then -- mm/dd/yy, currently used in dateweek (WeekStart)
		mm = strsub(sdate, 1, 2);
		dd = strsub(sdate, 4, 5);
	else
		dd = strsub(sdate, 1, 2);
		mm = strsub(sdate, 4, 5);
	end
	yy = strsub(sdate, 7, 8);

--[[ /////////////////////////
	[1] = "mm/dd/yy";
	[2] = "dd/mm/yy";
	[3] = "yy/mm/dd";
]]
	if (profile.dateformat == 1) then
		sdate = mm.."/"..dd.."/"..yy;
	elseif (profile.dateformat == 2) then
		sdate = dd.."/"..mm.."/"..yy;
	else
		sdate = yy.."/"..mm.."/"..dd;
	end
	
	return sdate;
end

function AccountantClassicScrollBar_Update()
	FauxScrollFrame_Update(AccountantClassicScrollBar, AC_CURR_LINES, AC_CHAR_LINES, 19)
	local offset = FauxScrollFrame_GetOffset(AccountantClassicScrollBar)
	for i = 1, AC_CHAR_LINES do
		local f = _G["AccountantClassicCharacterEntry"..i]
		local lineplusoffset = i + offset
		if (f and lineplusoffset <= AC_CURR_LINES) then
			local serverkey = AC_CHARSCROLL_LIST[lineplusoffset][1]
			local charkey = AC_CHARSCROLL_LIST[lineplusoffset][2]
			local options = Accountant_ClassicSaveData[serverkey][charkey]["options"]

			local factionstr = options.faction
			local faction_icon = factionstr and "|TInterface\\PVPFrame\\PVP-Currency-"..factionstr..":0:0|t" or ""
			local class_color = getClassColorPrefix(options.class)
			local color_end = (class_color ~= "") and "|r" or ""

			-- When a single realm is selected the realm name is redundant (and Forever realm
			-- names such as "CAMWOW TW4 Realm 1 PvE" are long), so only show the character.
			local name
			if (AC_SELECTED_SERVER == "All") then
				name = serverkey.." - "..charkey
			else
				name = charkey
			end
			f.Title.Text:SetText(class_color..faction_icon..name..color_end)
			-- Full "realm - character" text for the tooltip shown when the label is truncated
			f.Title.fullText = class_color..serverkey.." - "..charkey..color_end

			if options["totalcash"] ~= nil then
				f.In.Text:SetText("|cFFFFFFFF"..addon:GetFormattedValue(options["totalcash"]))
				f.Out.Text:SetText(parseDateStrings(options["lastsessiondate"], 2))
			else
				f.In.Text:SetText("Unknown")
				f.Out.Text:SetText("")
			end
			f:Show()
		elseif (f) then
			f:Hide()
		end
	end
end

function AccountantClassic_OnEvent(self, event, ...)
	local arg1 = ...;
	local oldType = AC_LOGTYPE;
	local logType = private.constants.eventLogTypes[event]

	if logType ~= nil then
		AC_LOGTYPE = logType
	elseif event == "MERCHANT_UPDATE" then
		if InRepairMode() then
			AC_LOGTYPE = "REPAIRS"
		end
	elseif event == "MAIL_INBOX_UPDATE" then
		AC_LOGTYPE = detectAhMail() and "AH" or "MAIL"
	-- This event is supposed to be fired before PLAYER_MONEY.
	elseif event == "CHAT_MSG_MONEY" then
		onShareMoney(arg1)
	elseif event == "PLAYER_MONEY" then
		if not AC_LOG_PRIMED then
			primeBaseline()
		else
			if AccountantClassic_Verbose then
				printMessage("Player money changed, starting to update money log ...")
			end
			updateLog()
		end
	end

	if AccountantClassic_Verbose and AC_LOGTYPE ~= oldType then printMessage("Accountant mode changed to '"..AC_LOGTYPE.."'"); end
end

local function getCharacterModeData(server, character, logType, logMode)
	local serverData = Accountant_ClassicSaveData[server]
	local characterData = serverData and serverData[character]
	local logData = characterData and characterData.data and characterData.data[logType]
	return logData and logData[logMode]
end

local function setTotals(totalIn, totalOut)
	local f = AccountantClassicFrame
	f.TotalInValue:SetText("|cFFFFFFFF"..addon:GetFormattedValue(totalIn))
	f.TotalOutValue:SetText("|cFFFFFFFF"..addon:GetFormattedValue(totalOut))
	if (totalOut > totalIn) then
		f.TotalFlow:SetText("|cFFFF3333"..L["Net Loss"]..":")
		f.TotalFlowValue:SetText("|cFFFF3333"..addon:GetFormattedValue(totalOut - totalIn))
	elseif (totalOut ~= totalIn) then
		f.TotalFlow:SetText("|cFF00FF00"..L["Net Profit"]..":")
		f.TotalFlowValue:SetText("|cFF00FF00"..addon:GetFormattedValue(totalIn - totalOut))
	else
		f.TotalFlow:SetText(L["Net Profit / Loss"]..":")
		f.TotalFlowValue:SetText("")
	end
end

-- Sum one log type / mode across all characters of the given server ("All" = every server)
local function sumAllCharacters(server, logType, mode)
	local mIn, mOut = 0, 0
	local function addServer(serverkey, serverData)
		for charkey in pairs(serverData) do
			local modeData = getCharacterModeData(serverkey, charkey, logType, mode)
			if modeData then
				mIn = mIn + (modeData.In or 0)
				mOut = mOut + (modeData.Out or 0)
			end
		end
	end
	if server == "All" then
		for serverkey, serverData in pairs(Accountant_ClassicSaveData) do
			addServer(serverkey, serverData)
		end
	elseif Accountant_ClassicSaveData[server] then
		addServer(server, Accountant_ClassicSaveData[server])
	end
	return mIn, mOut
end

-- Extra info shown at the top right for each period tab
local function updateExtraInfo(mode, selectedOptions)
	local fs = AccountantClassicFrame.Extra
	local fsv = AccountantClassicFrame.ExtraValue
	local options = AccountantClassic_Profile["options"]
	local label, value = "", ""

	if (mode == "Week") then
		label = L["Week Start"]..":"
		value = parseDateStrings(options["dateweek"] or addon:WeekStart(), 1)
	elseif (mode == "PrvWeek") then
		if (selectedOptions and selectedOptions.prvdateweek) then
			label = L["Week Start"]..":"
			value = parseDateStrings(selectedOptions.prvdateweek, 1)
		end
	elseif (mode == "Month") then
		value = AC_MONTHS[tonumber(options["month"])] or ""
	elseif (mode == "PrvMonth") then
		if (selectedOptions and selectedOptions.prvmonth) then
			value = AC_MONTHS[tonumber(selectedOptions.prvmonth)] or ""
		end
	elseif (mode == "Day") then
		value = parseDateStrings(cdate, 2)
	elseif (mode == "PrvDay") then
		if (selectedOptions and selectedOptions.prvday) then
			value = parseDateStrings(selectedOptions.prvday, 2)
		end
	elseif (mode == "Year") then
		value = options["curryear"] or ""
	elseif (mode == "PrvYear") then
		value = options["prvyear"] or ""
	end

	fs:SetText(label)
	fsv:SetText(value)
end

function AccountantClassic_OnShow(self)
	createACFrames()

	shiftLogs()
	setLabels()
	if ( AC_CURRTAB ~= AC_TABS ) then
		-- for all the tabs except for character tab
		addon:PopulateCharacterList()
		AccountantClassicFrameServerDropDown:Hide()
		AccountantClassicFrameFactionDropDown:Hide()
		AccountantClassicScrollBar:Hide()
		for i = 1, AC_CHAR_LINES do
			local entry = _G["AccountantClassicCharacterEntry"..i]
			if (entry) then
				entry:Hide()
			end
		end

		local isSession = (AC_CURRTAB == AC_SESSION_TAB)
		if (isSession) then
			AccountantClassicFrameCharacterDropDown:Hide()
		else
			AccountantClassicFrameCharacterDropDown:Show()
		end

		local mode = private.constants.logmodes[AC_CURRTAB]
		local selectedIndex = (not isSession) and resolveSelectedCharacter() or nil
		local selectedServer, selectedChar, selectedOptions
		if selectedIndex and selectedIndex <= #AC_CHARSCROLL_LIST then
			selectedServer, selectedChar = AC_CHARSCROLL_LIST[selectedIndex][1], AC_CHARSCROLL_LIST[selectedIndex][2]
			selectedOptions = Accountant_ClassicSaveData[selectedServer][selectedChar]["options"]
		end
		local allCharsServer = profile.cross_server and "All" or AC_SERVER

		local TotalIn = 0
		local TotalOut = 0
		for _, key in ipairs(AC_LOGTYPE_ORDER) do
			local colIn = _G["AccountantClassicFrameRow"..AC_DATA[key].InPos.."In"]
			local colOut = _G["AccountantClassicFrameRow"..AC_DATA[key].InPos.."Out"]

			colIn.logType = key
			colOut.logType = key
			colIn.cashflow = "In"
			colOut.cashflow = "Out"

			local mIn, mOut = 0, 0
			if (isSession) then
				mIn = AC_DATA[key][mode].In
				mOut = AC_DATA[key][mode].Out
			elseif (selectedServer) then
				local modeData = getCharacterModeData(selectedServer, selectedChar, key, mode)
				mIn = modeData and modeData.In or 0
				mOut = modeData and modeData.Out or 0
			else
				-- "All Chars" entry of the character dropdown
				mIn, mOut = sumAllCharacters(allCharsServer, key, mode)
			end

			TotalIn = TotalIn + mIn
			TotalOut = TotalOut + mOut

			colIn.Text:SetText(addon:GetFormattedValue(mIn))
			colOut.Text:SetText(addon:GetFormattedValue(mOut))
		end
		setTotals(TotalIn, TotalOut)

		-- Set row 18 to be empty so that the total row from all characters will be clean out
		_G["AccountantClassicFrameRow18Title"].Text:SetText("")
		_G["AccountantClassicFrameRow18In"].Text:SetText("")

		updateExtraInfo(mode, selectedOptions)

		if (isSession) then
			setFrameTitle()
			setFramePortrait(AC_SERVER, AC_PLAYER)
		elseif (selectedChar) then
			setFrameTitle(selectedChar)
			setFramePortrait(selectedServer, selectedChar, selectedOptions)
		else
			setFrameTitle(L["All Chars"])
			setFramePortrait(nil)
		end
	else
		setFrameTitle()
		setFramePortrait(AC_SERVER, AC_PLAYER)
		-- all characters' tab
		addon:PopulateCharacterList(AC_SELECTED_SERVER, AC_SELECTED_FACTION)
		AccountantClassicFrameCharacterDropDown:Hide();
		AccountantClassicFrameServerDropDown:Show()
		AccountantClassicFrameFactionDropDown:Show()

		-- AC_CHARSCROLL_LIST now holds exactly the characters matching the selected
		-- server / faction filters, so the totals can be summed straight from it.
		local alltotal, allin, allout = 0, 0, 0
		for _, entry in ipairs(AC_CHARSCROLL_LIST) do
			local serverkey, charkey = entry[1], entry[2]
			alltotal = alltotal + (Accountant_ClassicSaveData[serverkey][charkey]["options"]["totalcash"] or 0)
			for _, key in ipairs(AC_LOGTYPE_ORDER) do
				local totalData = getCharacterModeData(serverkey, charkey, key, "Total")
				if totalData then
					allin = allin + (totalData.In or 0)
					allout = allout + (totalData.Out or 0)
				end
			end
		end
		AccountantClassicScrollBar_Update()

		setTotals(allin, allout)
		_G["AccountantClassicFrameRow18Title"].Text:SetText(L["Sum Total"])
		_G["AccountantClassicFrameRow18In"].Text:SetText("|cFFFFFFFF"..addon:GetFormattedValue(alltotal))

		AccountantClassicFrame.Extra:SetText("")
		AccountantClassicFrame.ExtraValue:SetText("")
	end
	PanelTemplates_SetTab(AccountantClassicFrame, AC_CURRTAB)
end

function AccountantClassic_OnMouseDown(self, button)
	-- Handle left button clicks
	if (button == "LeftButton") then
		self:StartMoving()
	end
end

function AccountantClassic_OnMouseUp(self, button)
	self:StopMovingOrSizing();
	local a, b, c, d, e = self:GetPoint()
	profile.AcFramePoint = { a, b, c, d, e }
end

printMessage = function(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg);
end

local function resetConfirmed()
	local mode = private.constants.logmodes[AC_CURRTAB];
	if not mode then return end
	for key in pairs(AC_DATA) do
		if AC_DATA[key][mode] then
			AC_DATA[key][mode].In = 0;
			AC_DATA[key][mode].Out = 0;
		end
		local profileData = AccountantClassic_Profile["data"][key]
		if profileData and profileData[mode] then
			profileData[mode].In = 0;
			profileData[mode].Out = 0;
		end
	end
	-- Also clear the per-zone breakdown so the row tooltips match the reset values
	local zoneData = Accountant_ClassicZoneDB[AC_SERVER][AC_PLAYER]["data"]
	if zoneData[mode] then
		zoneData[mode] = newZoneModeTable()
	end
	updateLDBText()
	if AccountantClassicFrame:IsVisible() then
		AccountantClassic_OnShow();
	end
end

-- Using native StaticPopupDialogs to show the confirm box. %s is filled in by StaticPopup_Show.
StaticPopupDialogs["ACCOUNTANT_CLASSIC_RESET"] = {
	text = L["Are you sure you want to reset the \"%s\" data?"],
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		resetConfirmed();
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

function AccountantClassic_ResetData()
	-- constants.tabText shares its index with constants.logmodes
	-- (the old if/elseif chain missed "Prv. Year")
	local logmode = private.constants.tabText[AC_CURRTAB] or private.constants.logmodes[AC_CURRTAB]
	if not logmode then return end
	StaticPopup_Show("ACCOUNTANT_CLASSIC_RESET", logmode)
end

function addon:CharacterRemovalProceed(server, character)
	local serverData = Accountant_ClassicSaveData[server]
	local charData = serverData and serverData[character]
	if not charData then return end

	local options = charData["options"] or {}
	local faction_icon = options.faction and "|TInterface\\PVPFrame\\PVP-Currency-"..options.faction..":0:0|t" or ""
	local class_color = getClassColorPrefix(options.class)

	serverData[character] = nil
	if not next(serverData) then
		-- don't leave an empty realm behind in the server dropdown
		Accountant_ClassicSaveData[server] = nil
		if AC_SELECTED_SERVER == server then
			AC_SELECTED_SERVER = profile.cross_server and "All" or AC_SERVER
		end
	end

	-- Remove the matching zone breakdown as well, otherwise it stays in SavedVariables forever
	local zoneServer = Accountant_ClassicZoneDB and Accountant_ClassicZoneDB[server]
	if zoneServer then
		zoneServer[character] = nil
		if not next(zoneServer) then
			Accountant_ClassicZoneDB[server] = nil
		end
	end

	printMessage(format(L["|cffffffff\"%s - %s|cffffffff\" character's Accountant Classic data has been removed."], faction_icon..class_color..server, character))
	addon:PopulateCharacterList()
	if AccountantClassicFrame:IsVisible() then
		AccountantClassic_OnShow()
	end
end

--[[
function AccountantClassicTab_OnClick(self)
	LibDD:CloseDropDownMenus()
	PanelTemplates_SetTab(AccountantClassicFrame, self:GetID());
	AC_CURRTAB = self:GetID();
	PlaySound(841);
	AccountantClassic_OnShow();
end
]]
function addon:RepairAllItems(guildBankRepair)
	if (not guildBankRepair) then
		AC_LOGTYPE = "REPAIRS";
	end
end

function addon:CursorHasItem()
	if InRepairMode() then
		AC_LOGTYPE = "REPAIRS";
	end
end

local function getBackpackCurrencyInfo(index)
	if (AC_USE_MAINLINE_API) then
		local info = BlizzardGetBackpackCurrencyInfo(index)
		return info and info.currencyTypesID or nil
	else
		local _, _, _, currencyID  = BlizzardGetBackpackCurrencyInfo(index)
		return currencyID or nil
	end
end

function addon:BackpackTokenFrame_Update()
	local tokenstr = ""
	for i = 1, 50 do
		local currencyTypesID = getBackpackCurrencyInfo(i)
		if not currencyTypesID then
			break
		end
		tokenstr = tokenstr .. getFormattedCurrency(currencyTypesID) .. " "
	end
	return tokenstr
end

function addon:ShowNetMoney(logmode)
	if (not logmode) then return end

	local amoney_str = "";

	local TotalIn = 0;
	local TotalOut = 0;
	local diff = 0;
	if (logmode ~= "Total" and AC_DATA["REPAIRS"][logmode]) then
		for key in pairs(AC_DATA) do
			TotalIn = TotalIn + AC_DATA[key][logmode].In;
			TotalOut = TotalOut + AC_DATA[key][logmode].Out;
		end
		if (TotalOut > TotalIn) then
			diff = TotalOut-TotalIn;
			amoney_str = amoney_str.."|cFFFF3333"..L["Net Loss"]..": ";
			amoney_str = amoney_str..addon:GetFormattedValue(diff);
		else
			diff = TotalIn-TotalOut;
			if (diff == 0) then
				amoney_str = addon:GetFormattedValue(GetMoney());
			else
				amoney_str = amoney_str.."|cFF00FF00"..L["Net Profit"]..": ";
				amoney_str = amoney_str..addon:GetFormattedValue(diff);
			end
		end
	else
		amoney_str = addon:GetFormattedValue(GetMoney());
	end
	
	if (amoney_str) then
		return amoney_str;
	end
end

updateLDBText = function()
	if not (profile and Accountant_ClassicSaveData and AC_DATA["REPAIRS"]["Session"]) then return end
	LDB.text = addon:ShowNetMoney(private.constants.ldbDisplayTypes[profile.ldbDisplayType]) or ""
end

function addon:ShowSessionToolTip()
	local amoney_str = "";

	local TotalIn = 0;
	local TotalOut = 0;
	local diff = 0;
	for key in pairs(AC_DATA) do
		TotalIn = TotalIn + AC_DATA[key]["Session"].In;
		TotalOut = TotalOut + AC_DATA[key]["Session"].Out;
	end
	amoney_str = "|cFFFFFFFF"..L["Total Incomings"]..": "..addon:GetFormattedValue(TotalIn).."\n";
	amoney_str = amoney_str.."|cFFFFFFFF"..L["Total Outgoings"]..": "..addon:GetFormattedValue(TotalOut).."\n";
	if TotalOut > TotalIn then
		diff = TotalOut-TotalIn;
		amoney_str = amoney_str.."|cFFFF3333"..L["Net Loss"]..": ";
		amoney_str = amoney_str..addon:GetFormattedValue(diff);
	else
		if TotalOut ~= TotalIn then
			diff = TotalIn-TotalOut;
			amoney_str = amoney_str.."|cFF00FF00"..L["Net Profit"]..": ";
			amoney_str = amoney_str..addon:GetFormattedValue(diff);
		else
			-- do nothing
		end
	end
	
	if (amoney_str) then
		return amoney_str;
	end
end

local AC_MAXTOOLTIPLINES = private.constants.maxTooltipLines
function AccountantClassic_LogTypeOnShow(self)
	local logmode = private.constants.logmodes[AC_CURRTAB]
	if (not logmode) then
		return;
	end
	if (profile.trackzone ~= true or not self.logType or not self.cashflow) then
		return
	end

	local serverkey, charkey
	if (logmode == "Session") then
		serverkey, charkey = AC_SERVER, AC_PLAYER
	else
		local index = AC_SELECTED_CHAR_NUM or resolveSelectedCharacter()
		local entry = AC_CHARSCROLL_LIST[index]
		if not entry then
			-- "All Chars" selection: per-zone breakdown across characters is not supported
			return
		end
		serverkey, charkey = entry[1], entry[2]
	end

	local serverData = Accountant_ClassicZoneDB and Accountant_ClassicZoneDB[serverkey]
	local characterData = serverData and serverData[charkey]
	local periodData = characterData and characterData.data and characterData.data[logmode]
	local zoneData = periodData and periodData[self.logType]
	if not zoneData then return end

	local cashflow = self.cashflow
	local lines = {}
	for k_zone, zoneAmounts in orderedpairs(zoneData) do
		local amount = zoneAmounts[cashflow] or 0
		if (amount > 0) then
			if (#lines + 1 >= AC_MAXTOOLTIPLINES) then
				lines[#lines + 1] = "..."
				break
			end
			lines[#lines + 1] = k_zone..": "..niceCash(amount)
		end
	end

	if #lines == 0 then return end
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:AddLine(table.concat(lines, "\n"), nil, nil, nil, false);
	GameTooltip:Show();
end


function addon:OnInitialize()
	self.db = AceDB:New("Accountant_ClassicDB", private.constants.defaults, true);
	profile = self.db.profile
	if not self.db then
		self:Print("Error: Database not loaded correctly.  Please exit out of WoW and delete the Accountant Classic database file Accountant_Classic.lua) found in: \\World of Warcraft\\WTF\\Account\\<Account Name>>\\SavedVariables\\")
		return
	end
	self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
	self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
	self.db.RegisterCallback(self, "OnProfileReset", "Refresh")

	LDB.type = "data source";
	LDB.text = L["Accountant Classic"];
	LDB.label = L["Accountant Classic"];
	LDB.icon = addon.icon
	LDB.OnClick = (function(_, button)
		if button == "LeftButton" then
			AccountantClassic_ButtonOnClick();
		elseif button == "RightButton" then
			addon:OpenOptions();
		end
	end);
	LDB.OnTooltipShow = (function(tooltip)
		if not tooltip or not tooltip.AddLine then return end
		local title = "|cffffffff"..L["Accountant Classic"];
		if (profile and profile.showmoneyonbutton) then
			title = title.." - "..addon:GetFormattedValue(GetMoney());
		end
		tooltip:AddLine(title);
		if (profile and profile.showsessiononbutton == true) then
			tooltip:AddLine(addon:ShowSessionToolTip());
		end
		if (profile and profile.showintrotip == true) then
			tooltip:AddLine(L["Left-Click to open Accountant Classic.\nRight-Click for Accountant Classic options.\nLeft-click and drag to move this button."]);
		end
	end);

	ACbutton:Register(private.addon_name, LDB, profile and profile.minimap);
	self:RegisterChatCommand("accountantbutton", function() addon:Toggle() end);
	self:RegisterChatCommand("accountant", accountantSlash);
	self:RegisterChatCommand("acc", accountantSlash);
	addon:SetupOptions()
	
	MoneyFrame = addon:GetModule("MoneyFrame", true)
	createACFrames()
end

function addon:OnEnable()
	AC_SERVER = GetRealmName()
	AC_PLAYER = getPlayerStorageKey()
	initOptions()
	copyOptions()

	self:SecureHook("RepairAllItems")
	self:SecureHook("CursorHasItem")
	
	loadData()
	setLabels()

	if (profile.cross_server and not AC_SELECTED_SERVER) then 
		AC_SELECTED_SERVER = "All" 
	elseif (not profile.cross_server and not AC_SELECTED_SERVER) then 
		AC_SELECTED_SERVER = AC_SERVER
	end
	if (profile.show_allFactions and not AC_SELECTED_FACTION) then 
		AC_SELECTED_FACTION = "All" 
	elseif (not profile.show_allFactions and not AC_SELECTED_FACTION) then 
		AC_SELECTED_FACTION = AC_FACTION
	end
	
	-- Cash
	AC_CURRMONEY = GetMoney()
	-- Check if there is any un-recorded money in or out
	if (AC_LASTSESSMONEY and AC_LASTSESSMONEY ~= AC_CURRMONEY) then
		AC_LOGTYPE = "OTHER"
		AC_LASTMONEY = AC_LASTSESSMONEY
		updateLog()
	end
	AC_LASTMONEY = AC_CURRMONEY
	
	settleTabText()

	addon:PopulateCharacterList()
	
	self:Refresh()
end

function addon:Toggle()
	self.db.profile.minimap.hide = not self.db.profile.minimap.hide
	if self.db.profile.minimap.hide then
		ACbutton:Hide(private.addon_name)
	else
		ACbutton:Show(private.addon_name)
	end
end

function addon:Refresh()
	profile = self.db.profile

	if (profile and profile.showmoneyinfo) then
		AccountantClassicMoneyInfoFrame:Show()
		MoneyFrame:ArrangeMoneyInfoFrame()
	else
		AccountantClassicMoneyInfoFrame:Hide()
	end
	AccountantClassic_OnShow()
	arrangeAccountantClassicFrame()

	updateLDBText()
end

function AccountantClassic_ButtonOnClick()
	if AccountantClassicFrame:IsVisible() then
		AccountantClassicFrame:Hide();
	else
		AccountantClassicFrame:Show();
	end
end

AccountantClassicTabButtonMixin = {};

function AccountantClassicTabButtonMixin:OnLoad()
	local TabText = private.constants.tabText
	local i = self:GetID()
	
	self:SetFrameLevel(self:GetFrameLevel() + 4);
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self.Text:SetText(TabText[i]);
end

local function updateTabResize(self)
	if (Client.isAnyClassic) then
		PanelTemplates_TabResize(self, 0, nil, 36, 88);
	else
		PanelTemplates_TabResize(self, self:GetParent().tabPadding, nil, self:GetParent().minTabWidth, self:GetParent().maxTabWidth);
	end
end

function AccountantClassicTabButtonMixin:OnEvent(event, ...)
	if self:IsVisible() then
		updateTabResize(self)
	end
end

function AccountantClassicTabButtonMixin:OnShow()
	updateTabResize(self)
end

function AccountantClassicTabButtonMixin:OnEnter()
	local TabTooltipText = private.constants.tabTooltipText
	local i = self:GetID()
	
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(TabTooltipText[i], 1.0, 0.82, 0);
end

function AccountantClassicTabButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function AccountantClassicTabButtonMixin:OnClick()
	local id = self:GetID()
	LibDD:CloseDropDownMenus()
	PanelTemplates_SetTab(AccountantClassicFrame, id)
	AC_CURRTAB = id
	PlaySound(841)
	AccountantClassic_OnShow()
end
