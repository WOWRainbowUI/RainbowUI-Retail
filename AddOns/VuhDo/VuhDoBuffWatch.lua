local _;
local _G = _G;

local VUHDO_BUFF_RAID = { };
local VUHDO_BUFF_RAID_FILTERED = { };

local VUHDO_PLAYER_GROUP = { "player" };

local VUHDO_BS_COLOR_EMPTY = 1;
local VUHDO_BS_COLOR_CD = 2;
local VUHDO_BS_COLOR_LOW = 3;
local VUHDO_BS_COLOR_MISSING = 4;
local VUHDO_BS_COLOR_OKAY = 5;


local VUHDO_NUM_LOWS = { };

local VUHDO_LAST_COLORS = { };

--
VUHDO_BUFFS = { };
VUHDO_BUFF_SETTINGS = { };

local VUHDO_CLICKED_BUFF = nil;
local VUHDO_CLICKED_TARGET_MODE = nil;
local VUHDO_CLICKED_TARGET = nil;
local VUHDO_IS_USED_SMART_BUFF;

VUHDO_BUFF_ORDER = { };
local sEmpty = { };
local sCooldownAliases = { };

-- Backdrops
BACKDROP_VUHDO_BUFF_SWATCH_PANEL_8_8_0000 = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 8,
	edgeSize = 8,
};

BACKDROP_COLOR_VUHDO_BUFF_SWATCH_PANEL = CreateColor(0, 0, 0);

BACKDROP_VUHDO_BUFF_WATCH_MAIN_FRAME_16_16_5555 = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 5, right = 5, top = 5, bottom = 5 },
};




-- BURST CACHE ---------------------------------------------------

local VUHDO_RAID;
local VUHDO_RAID_NAMES;
local VUHDO_BOSS_UNITS;
local VUHDO_GROUPS;

local VUHDO_tableUniqueAdd;
local VUHDO_isInSameZone;
local VUHDO_isInBattleground;
local VUHDO_brightenTextColor;
local VUHDO_isConfigDemoUsers;
local VUHDO_determineAura;
local VUHDO_textColor;

local GetTotemInfo = GetTotemInfo;
local table = table;
local GetTime = GetTime;
local GetSpellCooldown = GetSpellCooldown or VUHDO_getSpellCooldown;
local GetSpellInfo = GetSpellInfo or VUHDO_getSpellInfo;
local InCombatLockdown = InCombatLockdown;
local GetWeaponEnchantInfo = GetWeaponEnchantInfo;
local UnitOnTaxi = UnitOnTaxi;
local IsSpellInRange = IsSpellInRange or VUHDO_isSpellInRange;
local GetShapeshiftFormInfo = GetShapeshiftFormInfo;
local issecretvalue = issecretvalue;
local AbbreviateNumbers = AbbreviateNumbers;
local ShouldSpellAuraBeSecret = C_Secrets and C_Secrets.ShouldSpellAuraBeSecret;

local sSecretsEnabled = VUHDO_SECRETS_ENABLED;

local VUHDO_BUFF_TARGET_MODE_STANDARD;
local VUHDO_BUFF_TARGET_MODE_NAME;
local VUHDO_BUFF_TARGET_MODE_ROLE;
local VUHDO_BUFF_TARGET_MODE_TARGET;
local VUHDO_BUFF_TARGET_MODE_FOCUS;

local sTimeAbbrevData = {
	["breakpointData"] = {
		{
			["breakpoint"] = 3600,
			["abbreviation"] = "h",
			["significandDivisor"] = 60,
			["fractionDivisor"] = 60,
			["abbreviationIsGlobal"] = false,
		},
		{
			["breakpoint"] = 60,
			["abbreviation"] = "m",
			["significandDivisor"] = 60,
			["fractionDivisor"] = 1,
			["abbreviationIsGlobal"] = false,
		},
		{
			["breakpoint"] = 0,
			["abbreviation"] = "s",
			["significandDivisor"] = 1,
			["fractionDivisor"] = 1,
			["abbreviationIsGlobal"] = false,
		},
	},
};

local pairs = pairs;
local ipairs = ipairs;
local twipe = table.wipe;
local tinsert = table.insert;
local format = format;

local sConfig = { };
local sRebuffSecs;
local sRebuffPerc;
local sGermanOrEnglish = GetLocale() == "deDE" or GetLocale() == "enGB" or GetLocale() == "enUS";

-----------------------------------------------------------------------------
function VUHDO_buffWatchInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_RAID_NAMES = _G["VUHDO_RAID_NAMES"];
	VUHDO_BOSS_UNITS = _G["VUHDO_BOSS_UNITS"];
	VUHDO_GROUPS = _G["VUHDO_GROUPS"];

	VUHDO_tableUniqueAdd = _G["VUHDO_tableUniqueAdd"];
	VUHDO_isInSameZone = _G["VUHDO_isInSameZone"];
	VUHDO_isInBattleground = _G["VUHDO_isInBattleground"];
	VUHDO_brightenTextColor = _G["VUHDO_brightenTextColor"];
	VUHDO_isConfigDemoUsers = _G["VUHDO_isConfigDemoUsers"];
	VUHDO_determineAura = _G["VUHDO_determineAura"];
	VUHDO_textColor = _G["VUHDO_textColor"];

	VUHDO_BUFF_TARGET_MODE_STANDARD = _G["VUHDO_BUFF_TARGET_MODE_STANDARD"];
	VUHDO_BUFF_TARGET_MODE_NAME = _G["VUHDO_BUFF_TARGET_MODE_NAME"];
	VUHDO_BUFF_TARGET_MODE_ROLE = _G["VUHDO_BUFF_TARGET_MODE_ROLE"];
	VUHDO_BUFF_TARGET_MODE_TARGET = _G["VUHDO_BUFF_TARGET_MODE_TARGET"];
	VUHDO_BUFF_TARGET_MODE_FOCUS = _G["VUHDO_BUFF_TARGET_MODE_FOCUS"];

	sConfig = VUHDO_BUFF_SETTINGS["CONFIG"];
	sRebuffSecs = sConfig["REBUFF_MIN_MINUTES"] * 60;
	sRebuffPerc = sConfig["REBUFF_AT_PERCENT"] * 0.01;

	return;

end

----------------------------------------------------



--
local function VUHDO_isUnitInRoleGroup(aUnit, aRoleId)

	for _, tRoleUnit in pairs((VUHDO_GROUPS or sEmpty)[aRoleId] or sEmpty) do
		if tRoleUnit == aUnit then
			return true;
		end
	end

	return false;

end



--
local tBuffTex;
local tBuffGroup;
local function VUHDO_unitHasBuffVariant(aUnit, aBuffInfo)

	_, tBuffTex = VUHDO_unitBuff(aUnit, aBuffInfo[1]);

	if tBuffTex then
		return true;
	end

	for tCnt = 3, 10 do
		tBuffGroup = aBuffInfo[tCnt];

		if not tBuffGroup then
			break;
		end

		for _, tSameBuff in pairs(tBuffGroup) do
			_, tBuffTex = VUHDO_unitBuff(aUnit, tSameBuff);

			if tBuffTex then
				return true;
			end
		end
	end

	return false;

end



--
function VUHDO_buffWatchOnMouseDown(aPanel)

	if VUHDO_mayMoveHealPanels() then
		aPanel["isMoving"] = true;

		aPanel:StartMoving();
	end

	return;

end



--
local tCoords;
function VUHDO_buffWatchOnMouseUp(aPanel)

	if aPanel["isMoving"] then
		aPanel["isMoving"] = false;

		VUHDO_PixelUtil.StopMovingOrSizing(aPanel);

		tCoords = VUHDO_BUFF_SETTINGS["CONFIG"]["POSITION"];
		tCoords["point"], _, tCoords["relativePoint"], tCoords["x"], tCoords["y"] = aPanel:GetPoint();
	end

	return;

end



--
local tCopy = { };
local function VUHDO_copyColor(aColor)
	tCopy["R"], tCopy["G"], tCopy["B"], tCopy["O"] = aColor["R"], aColor["G"], aColor["B"], aColor["O"];
	tCopy["TR"], tCopy["TG"], tCopy["TB"], tCopy["TO"] = aColor["TR"], aColor["TG"], aColor["TB"], aColor["TO"];
	tCopy["useBackground"], tCopy["useText"], tCopy["useOpacity"] = aColor["useBackground"], aColor["useText"], aColor["useOpacity"];
	return tCopy;
end



--
function VUHDO_isUseSingleBuff(aSwatch)
	if VUHDO_BUFF_TARGET_SINGLE ~= aSwatch:GetAttribute("buff")[2] then	return false;
	elseif aSwatch:GetAttribute("lowtarget") == nil or InCombatLockdown() then return 2;
	else return true; end
end



local function VUHDO_getWeaponEnchantMacroText(anEnchantName, aTargetType)
	return format("/use [@none] %s\n/use %d\n/click StaticPopup1Button1 LeftButton",
		anEnchantName, VUHDO_BUFF_TARGET_ENCHANT == aTargetType and 16 or 17);
end



--
local function VUHDO_setupBuffButtonAttributes(aModifierKey, aButtonId, anActionName, aButton, aTargetType)
	if not VUHDO_strempty(anActionName) then
		if VUHDO_BUFF_TARGET_ENCHANT == aTargetType or VUHDO_BUFF_TARGET_ENCHANT_OFF == aTargetType then
			VUHDO_safeSetAttribute(aButton, aModifierKey .. "type" .. aButtonId, "macro");
			VUHDO_safeSetAttribute(aButton, aModifierKey .. "macrotext" .. aButtonId, VUHDO_getWeaponEnchantMacroText(anActionName, aTargetType));
		else
			VUHDO_safeSetAttribute(aButton, aModifierKey .. "type" .. aButtonId, "spell");
			VUHDO_safeSetAttribute(aButton, aModifierKey .. "spell" .. aButtonId, anActionName);
		end
	else
		VUHDO_safeSetAttribute(aButton, aModifierKey .. "type" .. aButtonId, "");
	end
end



--
function VUHDO_setupAllBuffButtonUnits(aButton, aUnit)
	VUHDO_safeSetAttribute(aButton, "unit", aUnit or "_foo");
end



--
--local tModiKey, tButtonId;
function VUHDO_setupAllBuffButtonsTo(aButton, aBuffName, aUnit, aTargetType)
	if InCombatLockdown() then return; end

	VUHDO_setupAllBuffButtonUnits(aButton, aUnit);
	for _, tWithMinus in pairs(VUHDO_MODIFIER_KEYS) do
		for tCnt = 1, VUHDO_NUM_MOUSE_BUTTONS do
			VUHDO_setupBuffButtonAttributes(tWithMinus, tCnt, tCnt ~= 2 and aBuffName or nil, aButton, aTargetType);
		end
	end
end



--
function VUHDO_buffSelectDropdownOnLoad()
	UIDropDownMenu_SetInitializeFunction(VuhDoBuffSelectDropdown, VUHDO_buffSelectDropdown_Initialize);
	UIDropDownMenu_SetDisplayMode(VuhDoBuffSelectDropdown, "MENU");
end



--
local tDdCategName;
local tDdCateg;
local tDdSettings;
local tDdTargetType;
local tDdDropInfo;
local tDdText;
local tDdRoleIdR;
local tDdUnbuffedList;
local tDdAllRoleList;
local tDdPickList;
local tDdNextName;
local tDdFoundCur;
local tDdUnitId;
local tDdSelName;
local tDdNextSel;
function VUHDO_buffSelectDropdown_Initialize(_, _)

	if VUHDO_CLICKED_BUFF == nil or VUHDO_CLICKED_TARGET_MODE == nil or InCombatLockdown() then
		return;
	end

	tDdCategName = VUHDO_getBuffCategoryName(VUHDO_CLICKED_BUFF[1], VUHDO_CLICKED_BUFF[2]);
	tDdCateg = VUHDO_getPlayerClassBuffs()[tDdCategName];
	tDdSettings = VUHDO_BUFF_SETTINGS[tDdCategName];
	tDdTargetType = tDdCateg[1][2];

	if #tDdCateg > 1 then
		for _, tCategBuff in ipairs(tDdCateg) do
			if VUHDO_BUFFS[tCategBuff[1]] then
				tDdDropInfo = UIDropDownMenu_CreateInfo();
				tDdDropInfo["text"] = tCategBuff[1];
				tDdDropInfo["keepShownOnClick"] = false;
				tDdDropInfo["icon"] = VUHDO_BUFFS[tCategBuff[1]]["icon"];
				tDdDropInfo["arg1"] = tDdCategName;
				tDdDropInfo["func"] = VUHDO_buffSelectDropdownBuffSelected;
				tDdDropInfo["arg2"] = tCategBuff[1];

				tDdDropInfo["checked"] = tDdSettings["buff"] == tCategBuff[1];
				UIDropDownMenu_AddButton(tDdDropInfo);
			end
		end

	elseif VUHDO_BUFF_TARGET_RAID == tDdTargetType or VUHDO_BUFF_TARGET_SINGLE == tDdTargetType then
		tDdDropInfo = UIDropDownMenu_CreateInfo();
		tDdDropInfo["text"] = VUHDO_I18N_TRACK_BUFFS_FOR;
		tDdDropInfo["isTitle"] = true;
		tDdDropInfo["notCheckable"] = true;
		UIDropDownMenu_AddButton(tDdDropInfo);

		for _, tFilter in pairs(VUHDO_BUFF_FILTER_COMBO_TABLE) do
			tDdDropInfo = UIDropDownMenu_CreateInfo();
			tDdText = tFilter[2];
			tDdDropInfo["text"] = tDdText;
			tDdDropInfo["checked"] = VUHDO_BUFF_SETTINGS[tDdCategName]["filter"][tFilter[1]];
			tDdDropInfo["arg1"] = tDdCategName;
			tDdDropInfo["arg2"] = tFilter[1];
			tDdDropInfo["func"] = VUHDO_buffSelectDropdownFilterSelected;
			tDdDropInfo["isTitle"] = false;
			tDdDropInfo["disabled"] = false;

			UIDropDownMenu_AddButton(tDdDropInfo);
		end

	else
		VuhDoBuffSelectDropdown:Hide();

		if VUHDO_BUFF_TARGET_MODE_TARGET == VUHDO_CLICKED_TARGET_MODE
			or VUHDO_BUFF_TARGET_MODE_FOCUS == VUHDO_CLICKED_TARGET_MODE then
		elseif VUHDO_BUFF_TARGET_MODE_NAME == VUHDO_CLICKED_TARGET_MODE then
			tDdSelName = nil;
			tDdNextSel = false;

			if VUHDO_RAID_NAMES[tDdSettings["name"]] then
				for tName, _ in pairs(VUHDO_RAID_NAMES) do
					if tName ~= "player" then
						if tDdSelName == nil or tDdNextSel then
							tDdSelName = tName;

							if tDdNextSel then
								break;
							end
						end

						if tName == tDdSettings["name"] then
							tDdNextSel = true;
						end
					end
				end

				tDdSettings["name"] = tDdSelName;
				VUHDO_reloadBuffPanel();
			else
				tDdSettings["name"] = VUHDO_PLAYER_NAME;
			end

		elseif VUHDO_BUFF_TARGET_MODE_ROLE == VUHDO_CLICKED_TARGET_MODE then
			tDdRoleIdR = VUHDO_CLICKED_TARGET;
			tDdUnbuffedList = { };
			tDdAllRoleList = { };

			for _, tUnitId in pairs((VUHDO_GROUPS or sEmpty)[tDdRoleIdR] or sEmpty) do
				if VUHDO_RAID[tUnitId] and not VUHDO_RAID[tUnitId]["isPet"] then
					tinsert(tDdAllRoleList, tUnitId);

					if not VUHDO_unitHasBuffVariant(tUnitId, VUHDO_CLICKED_BUFF) then
						tinsert(tDdUnbuffedList, tUnitId);
					end
				end
			end

			tDdPickList = (#tDdUnbuffedList > 0) and tDdUnbuffedList or tDdAllRoleList;
			tDdNextName = nil;
			tDdFoundCur = false;

			for tIdx = 1, #tDdPickList do
				tDdUnitId = tDdPickList[tIdx];

				if tDdFoundCur then
					tDdNextName = (VUHDO_RAID[tDdUnitId] or sEmpty)["name"];
					break;
				end

				if (VUHDO_RAID[tDdUnitId] or sEmpty)["name"] == tDdSettings["name"] then
					tDdFoundCur = true;
				end
			end

			if not tDdNextName and #tDdPickList > 0 then
				tDdUnitId = tDdPickList[1];
				tDdNextName = (VUHDO_RAID[tDdUnitId] or sEmpty)["name"];
			end

			if tDdNextName then
				tDdSettings["name"] = tDdNextName;
				VUHDO_reloadBuffPanel();
			end
		end
	end

	return;

end



--
function VUHDO_buffSelectDropdownBuffSelected(_, aCategoryName, aBuffName)
	if aCategoryName then
		VUHDO_BUFF_SETTINGS[aCategoryName]["buff"] = aBuffName;
		VUHDO_reloadBuffPanel();
	end
end



--
function VUHDO_buffSelectDropdownFilterSelected(_, aCategName, aFilterValue)
	if aCategName then
		local tAllFilters = VUHDO_BUFF_SETTINGS[aCategName]["filter"];
		if VUHDO_ID_ALL == aFilterValue then
			twipe(tAllFilters);
			tAllFilters[VUHDO_ID_ALL] = true;
		else
			if tAllFilters[aFilterValue] then tAllFilters[aFilterValue] = nil;
			else tAllFilters[aFilterValue] = true; end

			tAllFilters[VUHDO_ID_ALL] = nil;
		end

		VUHDO_updateBuffFilters();
	end
end



--
function VuhDoBuffPreClick(aButton, aMouseButton)
	local tSwatch = aButton:GetParent();
	local tVariant = tSwatch:GetAttribute("buff");

	if "RightButton" == aMouseButton then
		VUHDO_CLICKED_BUFF = tVariant;
		VUHDO_CLICKED_TARGET_MODE = tSwatch:GetAttribute("targetmode");
		VUHDO_CLICKED_TARGET = tSwatch:GetAttribute("target");
		ToggleDropDownMenu(1, nil, VuhDoBuffSelectDropdown, aButton:GetName(), 0, -5);
	end

	VUHDO_IS_USED_SMART_BUFF = VUHDO_isUseSingleBuff(tSwatch);
	local tBuff = tVariant[1];

	if 2 == VUHDO_IS_USED_SMART_BUFF and aMouseButton == "LeftButton" then
		UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_ERR_2 .. tBuff, 1, 0.1, 0.1, 1);
		VUHDO_setupAllBuffButtonsTo(aButton, "", "", nil);
		return;
	end

	local tTarget = VUHDO_IS_USED_SMART_BUFF
		and tSwatch:GetAttribute("lowtarget") or tSwatch:GetAttribute("goodtarget");

	VUHDO_setupAllBuffButtonsTo(aButton, tBuff, tTarget, tVariant[2]);

	if not tTarget and aMouseButton ~= "RightButton" then
		UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_ERR_2 .. tBuff, 1, 0.1, 0.1, 1);
	end
end



--
function VuhDoBuffPostClick(aButton, aMouseButton)
	if VUHDO_IS_USED_SMART_BUFF then
		local tVariant = aButton:GetParent():GetAttribute("buff");
		VUHDO_setupAllBuffButtonsTo(aButton, tVariant[1], aButton:GetParent():GetAttribute("goodtarget"), tVariant[2]);
	end
end



--
function VUHDO_getAllUniqueSpells()
	local tUniqueBuffs = { };
	local tUniqueCategs = { };

	for tCategName, tCategBuffs in pairs(VUHDO_getPlayerClassBuffs()) do
		local tSpellName = tCategBuffs[1][1];
		if VUHDO_BUFFS[tSpellName] and VUHDO_BUFF_TARGET_UNIQUE == tCategBuffs[1][2] then
			tUniqueBuffs[#tUniqueBuffs + 1] = tSpellName;
			tUniqueCategs[tSpellName] = tCategName;
		end
	end

	return tUniqueBuffs, tUniqueCategs;
end



--
function VUHDO_initBuffsFromSpellBook()

	local tParentSpellName, tChildSpellName, tSpellId, tIcon;

	-- Patch 6.0.2 broke the spell book for a certain class of spells which 'transform' into other spells 
	-- eg. Lightning Shield becomes Water Shield, Seal of Command becomes Seal of Truth
	-- the workaround is to always check for existance in the spell book using the 'source' or 'parent' 
	-- spell name then map the 'source' spell name to the correct 'derived' or 'child' spell info
	-- eg. GetSpellBookItemInfo("Lightning Shield") will return a spell ID only for Lightning Shield, 
	-- however when a Resto Shaman calls GetSpellInfo("Lightning Shield") it returns the correct 
	-- information for the derived spell Water Shield
	VUHDO_BUFFS = { };
	for _, tCateg in pairs(VUHDO_getPlayerClassBuffs()) do
		for _, tCategSpells in pairs(tCateg) do
			tParentSpellName = tCategSpells[1];

			if VUHDO_isSpellKnown(tParentSpellName) then
				tChildSpellName, _, tIcon, _, _, _, tSpellId = GetSpellInfo(tParentSpellName);

				if tChildSpellName then
					VUHDO_BUFFS[tChildSpellName] = {
						["icon"] = tIcon,
						["id"] = tSpellId
					};

					if tChildSpellName ~= tParentSpellName then
						VUHDO_BUFFS[tParentSpellName] = {
							["icon"] = tIcon,
							["id"] = tSpellId
						};
					end

					VUHDO_CLASS_BUFFS_BY_TARGET_TYPE[tCategSpells[2]][tParentSpellName] = true;
				end
			end
		end
	end

	for tClassName, _ in pairs(VUHDO_CLASS_BUFFS) do
		if VUHDO_PLAYER_CLASS ~= tClassName then
			VUHDO_CLASS_BUFFS[tClassName] = nil;
		end
	end

end



--
function VUHDO_isBuffOfTargetType(aBuffName, aTargetType)

	return VUHDO_CLASS_BUFFS_BY_TARGET_TYPE[aTargetType][aBuffName] and true or false;

end



--
function VUHDO_getBuffCategoryName(aBuffName, aTargetType)
	for tCategName, tCategBuffs in pairs(VUHDO_getPlayerClassBuffs()) do
		for _, tBuffVariant in pairs(tCategBuffs) do
			if aBuffName == tBuffVariant[1] and aTargetType == tBuffVariant[2] then
				return tCategName;
			end
		end
	end

	return nil;
end



--
local tInfo;
local function VUHDO_setUnitMissBuff(aUnit, aCategSpec, someVariants, aCategName)

	if not (VUHDO_BUFF_SETTINGS[aCategName]["missingColor"] or sEmpty)["show"] then
		return;
	end

	tInfo = VUHDO_RAID[aUnit];

	if tInfo then
		-- Don't show missing buffs on vehicles
		if tInfo["isPet"] and VUHDO_RAID[tInfo["ownerUnit"]] and VUHDO_RAID[tInfo["ownerUnit"]]["isVehicle"] then
			return;
		end

		if not tInfo["missbuff"] or tInfo["missbuff"] > VUHDO_BUFF_ORDER[aCategSpec] then
			tInfo["missbuff"] = VUHDO_BUFF_ORDER[aCategSpec];
			tInfo["mibucateg"] = aCategName;
			tInfo["mibuvariants"] = someVariants;
		end
	end

	return;

end



--
local tTexture, tStart, tRest;
local tMissGroup = { };
local tLowGroup = { };
local tOkayGroup = { };
local tOorGroup = { };
local tGoodTarget;
local tLowestRest;
local tLowestUnit;
local tNow;
local tInRange;
local tCount;
local tMaxCount;
local tSecretCount;
local tIsWatchUnit;
local tInfo;
local tCategName;
local tIsAvailable;
local tIsNotInBattleground;
local tBuffGroup;
local tSpellInRange;
local function VUHDO_getMissingBuffs(aBuffInfo, someUnits, aCategSpec, anSuppressMissBuff, aTargetMode)

	tCategName = aCategSpec;

	twipe(tMissGroup);
	twipe(tLowGroup);
	twipe(tOkayGroup);
	twipe(tOorGroup);

	tGoodTarget = nil;
	tLowestRest = nil;
	tLowestUnit = nil;

	tNow = GetTime();

	tMaxCount = 0;
	tSecretCount = nil;

	if UnitOnTaxi("player") and VUHDO_BUFF_TARGET_SELF ~= aBuffInfo[2] then
		return tMissGroup, tLowGroup, tGoodTarget, tLowestRest, tLowestUnit, tOkayGroup, tOorGroup, tMaxCount;
	end

	tIsNotInBattleground = not VUHDO_isInBattleground();

	for _, tUnit in pairs(someUnits) do
		tInfo = VUHDO_RAID[tUnit];

		if (("focus" == tUnit or "target" == tUnit) and VUHDO_BUFF_TARGET_MODE_TARGET ~= aTargetMode and VUHDO_BUFF_TARGET_MODE_FOCUS ~= aTargetMode)
			or tInfo == nil or tInfo["isPet"] then
			tIsWatchUnit = false;
		elseif "player" == tUnit then
			tIsWatchUnit = true;
		elseif VUHDO_isInSameZone(tUnit) and (tInfo["visible"] or tIsNotInBattleground) then
			tIsWatchUnit = true;
		else
			tIsWatchUnit = false;
		end

		if tIsWatchUnit then
			tSpellInRange = IsSpellInRange(aBuffInfo[1], tUnit);

			tInRange = (tSpellInRange == 1 or tSpellInRange == true) or tInfo["hasSecretRange"]
				or (VUHDO_SECRETS_ENABLED and issecretvalue(tInfo["baseRange"])) or tInfo["baseRange"];

			tIsAvailable = tInfo["connected"] and not tInfo["dead"];

			_, tTexture, tCount, _, tStart, tRest, _, _ = VUHDO_unitBuff(tUnit, aBuffInfo[1]);

			if not tTexture then
				for tCnt = 3, 10 do
					tBuffGroup = aBuffInfo[tCnt];

					if not tBuffGroup then
						break;
					end

					for _, tSameGroupBuff in pairs(tBuffGroup) do
						_, tTexture, tCount, _, tStart, tRest, _, _ = VUHDO_unitBuff(tUnit, tSameGroupBuff);

						if tTexture then
							break;
						end
					end

					 -- Kein Buff in einer der Gruppen? => Raus, nachbuffen
					if not tTexture then
						break;
					end
				end
			end

			if tTexture then
				tCount = tCount or 0;

				if sSecretsEnabled and issecretvalue(tCount) then
					tSecretCount = tCount;
				elseif not issecretvalue(tCount) and tCount > tMaxCount then
					tMaxCount = tCount;
				end

				if sSecretsEnabled and (issecretvalue(tRest) or issecretvalue(tStart)) then
					tOkayGroup[#tOkayGroup + 1] = tUnit;
				else
					tStart = tStart or 0;
					tRest = tRest and tRest - tNow or 0;

					if (tRest < sRebuffSecs or tRest / tStart < sRebuffPerc) and tRest > 0 then
						tLowGroup[#tLowGroup + 1] = tUnit;

						if not tInRange and tIsAvailable then
							tOorGroup[#tOorGroup + 1] = tUnit;
						end
					else
						tOkayGroup[#tOkayGroup + 1] = tUnit;
					end

					if tLowestRest == nil or tRest < tLowestRest then
						tLowestRest = tRest;

						if tInRange then
							tLowestUnit = tUnit;
						end
					end
				end
			end

			if tIsAvailable then
				if not tTexture then
					tMissGroup[#tMissGroup + 1] = tUnit;

					if not tInRange and tIsAvailable then
						tOorGroup[#tOorGroup + 1] = tUnit;
					end

					if not anSuppressMissBuff then
						VUHDO_setUnitMissBuff(tUnit, aCategSpec, aBuffInfo, tCategName);
					end

					if tInRange then
						tLowestUnit = tUnit;
						tLowestRest = 0;
					end
				end

				if 10 == aBuffInfo[2] then
					tGoodTarget = "player"; -- VUHDO_BUFF_TARGET_RAID
				elseif 9 == aBuffInfo[2] then
					tGoodTarget = "target"; -- VUHDO_BUFF_TARGET_HOSTILE
				elseif 3 == aBuffInfo[2] or tInRange then
					tGoodTarget = tUnit; -- VUHDO_BUFF_TARGET_UNIQUE
				end
			end
		end
	end

	return tMissGroup, tLowGroup, tGoodTarget, tLowestRest, tLowestUnit, tOkayGroup, tOorGroup, tSecretCount or tMaxCount;

end



--
local tFilters;
local tIsPetArray = { ["isPet"] = true };
local function VUHDO_updateFilter(aCategName)
	tFilters = VUHDO_BUFF_SETTINGS[aCategName]["filter"];

	if tFilters[VUHDO_ID_ALL] then
		VUHDO_BUFF_RAID_FILTERED[aCategName] = VUHDO_BUFF_RAID;
	else
		VUHDO_BUFF_RAID_FILTERED[aCategName] = { };

		for tModelId, _ in pairs(tFilters) do
			for _, tUnit in pairs(VUHDO_GROUPS[tModelId]) do
				if not (VUHDO_RAID[tUnit] or tIsPetArray)["isPet"] then
					VUHDO_tableUniqueAdd(VUHDO_BUFF_RAID_FILTERED[aCategName], tUnit);
				end
			end
		end
	end
end



--
function VUHDO_updateBuffFilters()
	for tCategSpec, _ in pairs(VUHDO_getPlayerClassBuffs()) do
		VUHDO_updateFilter(tCategSpec);
	end
end



--
function VUHDO_updateBuffRaidGroup()

	twipe(VUHDO_BUFF_RAID);

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if "focus" ~= tUnit and "target" ~= tUnit and not tInfo["isPet"] and not VUHDO_BOSS_UNITS[tUnit] then
			VUHDO_BUFF_RAID[#VUHDO_BUFF_RAID + 1] = tUnit;
		end
	end

	VUHDO_updateBuffFilters();

	return;

end



--
local tDestGroup;
local tTargetType;
local tEnchantDuration;
local tHasEnchant;
local tCategName;
local tNameGroup = { };
local tIsActive;
local tStart, tDuration, tRest, tName, tTexture;
local function VUHDO_getMissingBuffsForCode(aTargetMode, aTarget, aBuffInfo, aCategSpec, anSuppressMissBuff)

	if VUHDO_BUFF_TARGET_MODE_NAME == aTargetMode then
		tNameGroup[1] = VUHDO_RAID_NAMES[aTarget];
		tDestGroup = tNameGroup;
	elseif VUHDO_BUFF_TARGET_MODE_ROLE == aTargetMode then
		tDestGroup = (VUHDO_GROUPS or sEmpty)[aTarget] or sEmpty;
	elseif VUHDO_BUFF_TARGET_MODE_TARGET == aTargetMode then
		tNameGroup[1] = VUHDO_RAID["target"] and "target" or nil;
		tDestGroup = tNameGroup;
	elseif VUHDO_BUFF_TARGET_MODE_FOCUS == aTargetMode then
		tNameGroup[1] = VUHDO_RAID["focus"] and "focus" or nil;
		tDestGroup = tNameGroup;
	else
		tTargetType = aBuffInfo[2];

		if VUHDO_BUFF_TARGET_RAID == tTargetType or VUHDO_BUFF_TARGET_SINGLE == tTargetType then
			tCategName = aCategSpec;
			if VUHDO_BUFF_RAID_FILTERED[tCategName] then
				tDestGroup = VUHDO_BUFF_RAID_FILTERED[tCategName];
			else
				tDestGroup = VUHDO_BUFF_RAID;
			end

		elseif VUHDO_BUFF_TARGET_OWN_GROUP == tTargetType then
			tDestGroup = VUHDO_GROUPS[(VUHDO_RAID["player"] or {})["group"] or 1];

		elseif VUHDO_BUFF_TARGET_STANCE == tTargetType then
			for tCnt = 1, NUM_STANCE_SLOTS do
				_, tName, tIsActive = GetShapeshiftFormInfo(tCnt);
				if tIsActive and tName == aBuffInfo[1] then
					return sEmpty, sEmpty, "player", 0, "player", VUHDO_PLAYER_GROUP, sEmpty, 0;
				end
			end

			VUHDO_setUnitMissBuff("player", aCategSpec, aBuffInfo, aCategSpec);
			return VUHDO_PLAYER_GROUP, sEmpty, "player", 0, "player", sEmpty, sEmpty, 0;

		elseif VUHDO_BUFF_TARGET_ENCHANT == tTargetType then
			tHasEnchant, tEnchantDuration = GetWeaponEnchantInfo();
			if tHasEnchant and (not sGermanOrEnglish or strfind(aBuffInfo[1], VUHDO_getWeaponEnchantName(16), 1, true)) then
				return sEmpty, sEmpty, "player", tEnchantDuration * 0.001, "player", VUHDO_PLAYER_GROUP, sEmpty, 0;
			end

			VUHDO_setUnitMissBuff("player", aCategSpec, aBuffInfo, aCategSpec);
			return VUHDO_PLAYER_GROUP, sEmpty, "player", 0, "player", sEmpty, sEmpty, 0;

		elseif VUHDO_BUFF_TARGET_ENCHANT_OFF == tTargetType then
			_, _, _, _, tHasEnchant, tEnchantDuration = GetWeaponEnchantInfo();

			if tHasEnchant and (not sGermanOrEnglish or strfind(aBuffInfo[1], VUHDO_getWeaponEnchantName(17), 1, true)) then
				return sEmpty, sEmpty, "player", tEnchantDuration * 0.001, "player", VUHDO_PLAYER_GROUP, sEmpty, 0;
			end

			VUHDO_setUnitMissBuff("player", aCategSpec, aBuffInfo, aCategSpec);
			return VUHDO_PLAYER_GROUP, sEmpty, "player", 0, "player", sEmpty, sEmpty, 0;

		elseif VUHDO_BUFF_TARGET_TOTEM == tTargetType then
			for tTotemNum = 1, 4 do
				_, tName, tStart, tDuration, tTexture = GetTotemInfo(tTotemNum);
				if tTexture == VUHDO_BUFFS[aBuffInfo[1]]["icon"] then
					if tName ~= aBuffInfo[1] then
						sCooldownAliases[aBuffInfo[1]] = tName;
					end
					tRest = tDuration - (GetTime() - tStart);
					if tRest < 0 then tRest = 0; end

					return sEmpty, sEmpty, "player", tRest, "player", VUHDO_PLAYER_GROUP, sEmpty, 0;
				end
			end

			VUHDO_setUnitMissBuff("player", aCategSpec, aBuffInfo, aCategSpec);
			return VUHDO_PLAYER_GROUP, sEmpty, "player", 0, "player", sEmpty, sEmpty, 0;
		else
			-- If self we only care if buff isn't on player
			tDestGroup = VUHDO_PLAYER_GROUP;
		end
	end

	return VUHDO_getMissingBuffs(aBuffInfo, tDestGroup or sEmpty, aCategSpec, anSuppressMissBuff, aTargetMode);
end



--
local function VUHDO_setBuffSwatchColor(aSwatch, aColorInfo, aColorType)
	if VUHDO_LAST_COLORS[aSwatch:GetName()] == aColorType then return; end

	local tColor = VUHDO_getDiffColor(VUHDO_copyColor(sConfig["SWATCH_BG_COLOR"]), aColorInfo);
	aSwatch:SetBackdropColor(VUHDO_backColor(tColor));
	local tName = aSwatch:GetName();

	if tColor["useText"] then
		_G[tName .. "MessageLabelLabel"]:SetTextColor(VUHDO_textColor(tColor));
		_G[tName .. "TimerLabelLabel"]:SetTextColor(VUHDO_textColor(tColor));
		_G[tName .. "CounterLabelLabel"]:SetTextColor(VUHDO_textColor(tColor));
		tColor = VUHDO_brightenTextColor(VUHDO_copyColor(aColorInfo), 0.2);
		_G[tName .. "GroupLabelLabel"]:SetTextColor(VUHDO_textColor(tColor));
	end

	VUHDO_LAST_COLORS[tName] = aColorType;
end



--
local function VUHDO_setBuffSwatchInfo(aSwatchName, anInfoText)
	_G[aSwatchName .. "MessageLabelLabel"]:SetText(anInfoText);
end



--
local function VUHDO_setBuffSwatchCount(aSwatchName, aText)
	_G[aSwatchName .. "CounterLabelLabel"]:SetText(aText);
end



--
local tCountStr;
local tRemainingSeconds;
local tDurationText;
local function VUHDO_setBuffSwatchTimer(aSwatchName, aSecsNum, aCount, aDuration)

	if aDuration then
		tRemainingSeconds = aDuration:GetRemainingDuration();
		tDurationText = AbbreviateNumbers(tRemainingSeconds, sTimeAbbrevData);

		_G[aSwatchName .. "TimerLabelLabel"]:SetText(tDurationText or "");
	elseif (aSecsNum or -1) >= 0 then
		tCountStr = ((issecretvalue(aCount) and sSecretsEnabled) or (not issecretvalue(aCount) and (aCount or 0) > 0 and not VUHDO_BUFF_SETTINGS["CONFIG"]["HIDE_CHARGES"]))
			and format("|cffffffff%dx |r", aCount) or "";
		_G[aSwatchName .. "TimerLabelLabel"]:SetText(format("%s%d:%02d", tCountStr, aSecsNum / 60, aSecsNum % 60));
	else
		_G[aSwatchName .. "TimerLabelLabel"]:SetText("");
	end

	return;

end



--
local tStart;
local tDurationRemaining;
local tSpellId;
local tIsOnGCD;
local tDuration;
local function VUHDO_getSpellCooldown(aSpellName)

	tSpellId = sCooldownAliases[aSpellName] or (VUHDO_BUFFS[aSpellName] and VUHDO_BUFFS[aSpellName]["id"]);

	if not tSpellId then
		return 0, 0, nil;
	end

	if sSecretsEnabled then
		tStart, tDurationRemaining, _, _, tIsOnGCD, tDuration = GetSpellCooldown(tSpellId);

		if tIsOnGCD == true or not tDuration or (not tDuration:HasSecretValues() and tDuration:IsZero()) then
			return 0, 0, nil;
		end

		return -1, -1, tDuration;
	end

	if sCooldownAliases[aSpellName] then
		tStart, tDurationRemaining = GetSpellCooldown(sCooldownAliases[aSpellName], BOOKTYPE_SPELL);
	else
		tStart, tDurationRemaining = GetSpellCooldown(tSpellId);
	end

	if (tDurationRemaining or 0) == 0 then
		return 0, 0, nil;
	else
		return (tStart or 0) + tDurationRemaining - GetTime(), tDurationRemaining, nil;
	end

end



--
local tMissGroup;
local tLowGroup;
local tGoodTarget;
local tLowestRest;
local tLowestUnit;
local tOkayGroup;
local tOorGroup;
local tCooldown, tTotalCd;
local tSpellCdDuration;
local tRefSpell;
local tSwatchName;
local tMaxCount;
local tCategSpec;
local tVariant;
local tTargetMode;
local tTarget;
local tSuppressMiss;
local tUniqueRoleOkay;
local tIsUniqueRole;
local tUniqueRoleLow;
local tRoleId;
local tPinnedUnit;
local tBuffSettings;
local tStaleName;
local tGroupLabel;
local tRoleTotal;
local tIsSpellAuraSecret;
local tInfo;
function VUHDO_updateBuffSwatch(aSwatch)

	tSwatchName = aSwatch:GetName();
	tVariant = aSwatch:GetAttribute("buff");
	tTargetMode = aSwatch:GetAttribute("targetmode");
	tTarget = aSwatch:GetAttribute("target");
	tCategSpec = aSwatch:GetAttribute("buffName");

	if not tTargetMode or not tVariant then
		return;
	end

	tLowestUnit, tGoodTarget = nil, nil;

	tRefSpell = tVariant[1];

	if not VUHDO_BUFFS[tRefSpell] or not VUHDO_BUFFS[tRefSpell]["id"] then
		return;
	end

	tCooldown, tTotalCd, tSpellCdDuration = VUHDO_getSpellCooldown(tRefSpell);

	if tCooldown == -1 then
		VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_COOLDOWN"], VUHDO_BS_COLOR_CD);
		VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_CD);
		VUHDO_setBuffSwatchCount(tSwatchName, "");
		VUHDO_setBuffSwatchTimer(tSwatchName, nil, nil, tSpellCdDuration);
	elseif tCooldown > 1.5 then
		VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_COOLDOWN"], VUHDO_BS_COLOR_CD);
		VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_CD);
		VUHDO_setBuffSwatchCount(tSwatchName, "");
		VUHDO_setBuffSwatchTimer(tSwatchName, tCooldown, nil);

		if tTotalCd > 59 then
			VUHDO_BUFFS[tRefSpell]["wasOnCd"] = true;
		end
	else
		if VUHDO_BUFFS[tRefSpell]["wasOnCd"] and VUHDO_BUFF_SETTINGS["CONFIG"]["HIGHLIGHT_COOLDOWN"] then
			VUHDO_UIFrameFlash(aSwatch, 0.3, 0.3, 5, true, 0, 0.3);

			VUHDO_BUFFS[tRefSpell]["wasOnCd"] = false;
		end

		if VUHDO_BUFF_TARGET_MODE_NAME == tTargetMode then
			tStaleName = tTarget;

			if not VUHDO_RAID_NAMES[tStaleName] then
				VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_OUT"], VUHDO_BS_COLOR_MISSING);
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_MISS);
				VUHDO_setBuffSwatchCount(tSwatchName, "");
				VUHDO_setBuffSwatchTimer(tSwatchName, nil);
				tGroupLabel = _G[tSwatchName .. "GroupLabelLabel"];
				tGroupLabel:SetTextColor(1, 0.2, 0.2);
				VUHDO_safeSetAttribute(aSwatch, "lowtarget", nil);
				VUHDO_safeSetAttribute(aSwatch, "goodtarget", nil);

				VUHDO_NUM_LOWS[tSwatchName] = 0;

				return;
			end
		elseif VUHDO_BUFF_TARGET_MODE_TARGET == tTargetMode or VUHDO_BUFF_TARGET_MODE_FOCUS == tTargetMode then
			tGroupLabel = _G[tSwatchName .. "GroupLabelLabel"];

			if not VUHDO_RAID[VUHDO_BUFF_TARGET_MODE_TARGET == tTargetMode and "target" or "focus"] then
				VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_OKAY"], VUHDO_BS_COLOR_OKAY);
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_N_A);
				VUHDO_setBuffSwatchCount(tSwatchName, "");
				VUHDO_setBuffSwatchTimer(tSwatchName, nil);
				tGroupLabel:SetText(VUHDO_BUFF_TARGET_MODE_TARGET == tTargetMode and VUHDO_I18N_BW_TARGET or VUHDO_I18N_BW_FOCUS);
				VUHDO_safeSetAttribute(aSwatch, "lowtarget", nil);
				VUHDO_safeSetAttribute(aSwatch, "goodtarget", nil);

				VUHDO_NUM_LOWS[tSwatchName] = 0;

				return;
			end

			tGroupLabel:SetText((VUHDO_RAID[VUHDO_BUFF_TARGET_MODE_TARGET == tTargetMode and "target" or "focus"] or sEmpty)["name"]
				or (VUHDO_BUFF_TARGET_MODE_TARGET == tTargetMode and VUHDO_I18N_BW_TARGET or VUHDO_I18N_BW_FOCUS));
		end

		tIsSpellAuraSecret = ShouldSpellAuraBeSecret and ShouldSpellAuraBeSecret(VUHDO_BUFFS[tRefSpell]["id"]);
		tSuppressMiss = VUHDO_BUFF_TARGET_UNIQUE == tVariant[2] and tIsSpellAuraSecret;

		tMissGroup, tLowGroup, tGoodTarget, tLowestRest, tLowestUnit, tOkayGroup, tOorGroup, tMaxCount
			= VUHDO_getMissingBuffsForCode(tTargetMode, tTarget, tVariant, tCategSpec, tSuppressMiss);

		if VUHDO_BUFF_TARGET_MODE_ROLE == tTargetMode and VUHDO_BUFF_TARGET_UNIQUE == tVariant[2] then
			tRoleId = tTarget;
			tBuffSettings = VUHDO_BUFF_SETTINGS[tCategSpec];
			tPinnedUnit = VUHDO_RAID_NAMES[(tBuffSettings or sEmpty)["name"]];

			if tPinnedUnit and VUHDO_isUnitInRoleGroup(tPinnedUnit, tRoleId) then
				for _, tRoleUnit in pairs(tMissGroup) do
					if tRoleUnit == tPinnedUnit then
						tGoodTarget = tPinnedUnit;

						break;
					end
				end

				for _, tRoleUnit in pairs(tLowGroup) do
					if tRoleUnit == tPinnedUnit then
						tLowestUnit = tPinnedUnit;

						break;
					end
				end

				if not tGoodTarget and not tLowestUnit then
					tGoodTarget = tPinnedUnit;
				end
			end

			tGroupLabel = _G[tSwatchName .. "GroupLabelLabel"];

			if tPinnedUnit and VUHDO_RAID[tPinnedUnit] then
				tGroupLabel:SetText(VUHDO_RAID[tPinnedUnit]["name"]);
			elseif tLowestUnit and VUHDO_RAID[tLowestUnit] then
				tGroupLabel:SetText(VUHDO_RAID[tLowestUnit]["name"] or VUHDO_HEADER_TEXTS[tRoleId]);
			elseif tGoodTarget and VUHDO_RAID[tGoodTarget] then
				tGroupLabel:SetText(VUHDO_RAID[tGoodTarget]["name"] or VUHDO_HEADER_TEXTS[tRoleId]);
			else
				tGroupLabel:SetText(VUHDO_HEADER_TEXTS[tRoleId]);
			end
		end

		tIsUniqueRole = (VUHDO_BUFF_TARGET_MODE_ROLE == tTargetMode and VUHDO_BUFF_TARGET_UNIQUE == tVariant[2]);

		if tIsUniqueRole and (#tOkayGroup > 0 or #tLowGroup > 0) then
			for _, tRoleUnit in pairs(tMissGroup) do
				tInfo = VUHDO_RAID[tRoleUnit];

				if tInfo and tInfo["mibucateg"] == tCategSpec then
					tInfo["missbuff"] = nil;
					tInfo["mibucateg"] = nil;
					tInfo["mibuvariants"] = nil;
				end
			end
		end

		if VUHDO_BUFF_TARGET_UNIQUE == tVariant[2] and tIsSpellAuraSecret and #tMissGroup > 0 then
			VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_OKAY"], VUHDO_BS_COLOR_OKAY);
			VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_LOCK);
			VUHDO_setBuffSwatchCount(tSwatchName, "");
			VUHDO_setBuffSwatchTimer(tSwatchName, nil);
			VUHDO_safeSetAttribute(aSwatch, "lowtarget", tLowestUnit);
			VUHDO_safeSetAttribute(aSwatch, "goodtarget", tGoodTarget);

			VUHDO_NUM_LOWS[tSwatchName] = #(tMissGroup or sEmpty);

			return;
		end

		tUniqueRoleOkay = (tIsUniqueRole and #tOkayGroup > 0 and #tLowGroup == 0);
		tUniqueRoleLow = (tIsUniqueRole and #tLowGroup > 0);

		if tUniqueRoleOkay then
			VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_OKAY"], VUHDO_BS_COLOR_OKAY);

			if not tGoodTarget then
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_RNG_RED);
			else
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_OK);
			end

			tRoleTotal = #tOkayGroup + #tMissGroup;
			VUHDO_setBuffSwatchCount(tSwatchName, format("%d/%d", #tOkayGroup, tRoleTotal > 0 and tRoleTotal or #tOkayGroup));

			if tLowestRest == 0 then
				VUHDO_setBuffSwatchTimer(tSwatchName, nil);
			else
				VUHDO_setBuffSwatchTimer(tSwatchName, tLowestRest, tMaxCount);
			end
		elseif tUniqueRoleLow then
			VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_LOW"], VUHDO_BS_COLOR_LOW);
			VUHDO_setBuffSwatchInfo(tSwatchName, tGoodTarget and VUHDO_I18N_BW_LOW or VUHDO_I18N_BW_RNG_RED);

			tRoleTotal = #tOkayGroup + #tLowGroup + #tMissGroup;

			VUHDO_setBuffSwatchCount(tSwatchName,
				format("%d/%d", #tOkayGroup + #tLowGroup,
					tRoleTotal > 0 and tRoleTotal or (#tOkayGroup + #tLowGroup)));
			VUHDO_setBuffSwatchTimer(tSwatchName, tLowestRest, tMaxCount);
		elseif #tMissGroup > 0 then
			VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_OUT"], VUHDO_BS_COLOR_MISSING);

			if not tGoodTarget or #tMissGroup + #tLowGroup - #tOorGroup == 0 then
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_RNG_YELLOW);
				VUHDO_setBuffSwatchCount(tSwatchName, "" .. #tOorGroup);
				VUHDO_setBuffSwatchTimer(tSwatchName, 0, tMaxCount, nil);
			else
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_GO);

				if #tOorGroup > 0 then
					VUHDO_setBuffSwatchCount(tSwatchName, format("%d/%d", #tMissGroup + #tLowGroup - #tOorGroup, #tMissGroup + #tLowGroup));
				else
					VUHDO_setBuffSwatchCount(tSwatchName, format("%d", #tMissGroup + #tLowGroup));
				end

				VUHDO_setBuffSwatchTimer(tSwatchName, 0, nil);
			end
		elseif #tLowGroup > 0 then
			VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_LOW"], VUHDO_BS_COLOR_LOW);
			VUHDO_setBuffSwatchInfo(tSwatchName, tGoodTarget and VUHDO_I18N_BW_LOW or VUHDO_I18N_BW_RNG_RED);

			if #tOorGroup > 0 then
				VUHDO_setBuffSwatchCount(tSwatchName, format("%d/%d", #tLowGroup - #tOorGroup, #tLowGroup));
			else
				VUHDO_setBuffSwatchCount(tSwatchName, format("%d", #tLowGroup));
			end

			VUHDO_setBuffSwatchTimer(tSwatchName, tLowestRest, tMaxCount);
		else
			VUHDO_setBuffSwatchColor(aSwatch, sConfig["SWATCH_COLOR_BUFF_OKAY"], VUHDO_BS_COLOR_OKAY);

			if #tOkayGroup == 0 then
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_N_A);
			elseif not tGoodTarget then
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_RNG_RED);
			else
				VUHDO_setBuffSwatchInfo(tSwatchName, VUHDO_I18N_BW_OK);
			end

			VUHDO_setBuffSwatchCount(tSwatchName, #tOkayGroup);

			if tLowestRest == 0 then
				VUHDO_setBuffSwatchTimer(tSwatchName, nil);
			else
				VUHDO_setBuffSwatchTimer(tSwatchName, tLowestRest, tMaxCount);
			end
		end
	end

	VUHDO_safeSetAttribute(aSwatch, "lowtarget", tLowestUnit);
	VUHDO_safeSetAttribute(aSwatch, "goodtarget", tVariant[2] == VUHDO_BUFF_TARGET_SELF and "player" or tGoodTarget);

	VUHDO_NUM_LOWS[tSwatchName] = #(tLowGroup or sEmpty) + #(tMissGroup or sEmpty);

	return;

end



--
local tAllSwatches;
local tOldMissBuffs = { };
function VUHDO_updateBuffPanel()
	if VUHDO_isConfigDemoUsers() then return; end

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		tOldMissBuffs[tUnit] = tInfo["missbuff"];
		tInfo["missbuff"] = nil;
	end

	tAllSwatches = VUHDO_getAllBuffSwatches();
	for _, tUpdSwatch in pairs(tAllSwatches) do
		if tUpdSwatch:IsShown() then VUHDO_updateBuffSwatch(tUpdSwatch); end
	end

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if tOldMissBuffs[tUnit] ~= tInfo["missbuff"] then
			tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineAura(tUnit);

			VUHDO_updateHealthBarsFor(tUnit, VUHDO_UPDATE_DEBUFF);
		end
	end

	twipe(tOldMissBuffs);
end



--
function VUHDO_execSmartBuffPre(self)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_ERR_1, 1, 0.1, 0.1, 1);
		return false;
	end

	local tAllSwatches = VUHDO_getAllBuffSwatchesOrdered();
	local tVariants = nil;
	local tTargetMode = nil;
	local tTarget = nil;
	local tRefSpell = nil;
	local tMaxLow = 0;
	local tMaxLowSpell = nil;
	local tMaxLowTarget = nil;
	local tCategSpec;
	local tMissGroup, tLowGroup, tGoodTarget, tLowestUnit, tOorGroup;
	local tNumLow;
	local tCooldown;

	for _, tCheckSwatch in ipairs(tAllSwatches) do
		if tCheckSwatch:IsShown() then
			tVariants = tCheckSwatch:GetAttribute("buff");
			tTargetMode = tCheckSwatch:GetAttribute("targetmode");
			tTarget = tCheckSwatch:GetAttribute("target");
			tCategSpec = tCheckSwatch:GetAttribute("buffname");
			tRefSpell = tVariants[1];

			tMissGroup, tLowGroup, tGoodTarget,	_, tLowestUnit, _,	tOorGroup, _
					= VUHDO_getMissingBuffsForCode(tTargetMode, tTarget, tVariants, tCategSpec);

			tNumLow = #tMissGroup + #tLowGroup;
			if not VUHDO_BUFFS[tRefSpell] or not VUHDO_BUFFS[tRefSpell]["id"] then
				tCooldown = 0;
			else
				tCooldown = VUHDO_getSpellCooldown(tRefSpell);
			end

			if tNumLow > tMaxLow and tCooldown <= 1.5 and VUHDO_BUFF_TARGET_HOSTILE ~= tVariants[2] then
				if (tGoodTarget == nil) then
					UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_ERR_2 .. tRefSpell, 1, 0.1, 0.1, 1);
				elseif #tOorGroup > 0 then
					UIErrorsFrame:AddMessage("VuhDo: " .. #tOorGroup .. VUHDO_I18N_SMARTBUFF_ERR_3 .. tRefSpell, 1, 0.1, 0.1, 1);
				else
					tMaxLow = tNumLow;
					tMaxLowTarget = VUHDO_isUseSingleBuff(tCheckSwatch)	and tLowestUnit or tGoodTarget;
					tMaxLowSpell = tVariants[1];
				end
			end
		end
	end

	if not tMaxLowSpell then
		UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_ERR_4, 1, 1, 0.1, 1);
		return;
	end

	if not VUHDO_BUFFS[tMaxLowSpell] or not VUHDO_BUFFS[tMaxLowSpell]["id"] then
		tCooldown = 0;
	else
		tCooldown = VUHDO_getSpellCooldown(tMaxLowSpell);
	end

	if tCooldown > 0 then return; end

	local tName = VUHDO_RAID_NAMES[tMaxLowTarget] or VUHDO_RAID[tMaxLowTarget]["name"];

	UIErrorsFrame:AddMessage(VUHDO_I18N_SMARTBUFF_OKAY_1 .. tMaxLowSpell .. VUHDO_I18N_SMARTBUFF_OKAY_2 .. tName, 0.1, 1, 0.1, 1);
	VUHDO_safeSetAttribute(VuhDoSmartCastGlassButton, "unit", tMaxLowTarget);
	VUHDO_safeSetAttribute(VuhDoSmartCastGlassButton, "type1", "spell");
	VUHDO_safeSetAttribute(VuhDoSmartCastGlassButton, "spell1", tMaxLowSpell);
end



--
function VUHDO_execSmartBuffPost()
	VUHDO_safeSetAttribute(VuhDoSmartCastGlassButton, "unit", nil);
	VUHDO_safeSetAttribute(VuhDoSmartCastGlassButton, "type1", nil);
end



--
function VUHDO_resetBuffSwatchInfos()
	twipe(VUHDO_LAST_COLORS);
end
