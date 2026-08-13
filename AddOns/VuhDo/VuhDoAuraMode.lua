local _;

local ShouldAurasBeSecret = C_Secrets.ShouldAurasBeSecret;
local issecretvalue = issecretvalue;
local pairs = pairs;

local VUHDO_RAID;
local VUHDO_CONFIG;
local VUHDO_AURA_GROUP_TYPE_FILTER;
local VUHDO_AURA_GROUP_TYPE_LIST;

local VUHDO_hideAllAuras;
local VUHDO_syncOverlaysForUnit;
local VUHDO_releaseOverlaysForButton;
local VUHDO_getUnitButtonsSafe;
local VUHDO_clearAllAuraCaches;
local VUHDO_syncAuraContainersForUnit;
local VUHDO_degradeAuraCacheForUnit;
local VUHDO_fullAuraRefresh;
local VUHDO_updateAllRaidBars;
local VUHDO_initUnitAuraSlots;
local VUHDO_refreshListBouquetsForUnit;
local VUHDO_initNativeAuraSounds;
local VUHDO_rebuildSoundEnabledAuraGroups;
local VUHDO_clearNativeAuraSounds;

local sSecretsEnabled = false;
local sIsAuraDataRestricted = false;
local sIsAuraModeContainers = false;
local sNeedsUnitAuraEvent = true;
local sEmpty = { };



--
function VUHDO_auraModeInitLocalOverrides()

	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_AURA_GROUP_TYPE_FILTER = _G["VUHDO_AURA_GROUP_TYPE_FILTER"];
	VUHDO_AURA_GROUP_TYPE_LIST = _G["VUHDO_AURA_GROUP_TYPE_LIST"];

	VUHDO_hideAllAuras = _G["VUHDO_hideAllAuras"];
	VUHDO_syncOverlaysForUnit = _G["VUHDO_syncOverlaysForUnit"];
	VUHDO_releaseOverlaysForButton = _G["VUHDO_releaseOverlaysForButton"];
	VUHDO_getUnitButtonsSafe = _G["VUHDO_getUnitButtonsSafe"];
	VUHDO_clearAllAuraCaches = _G["VUHDO_clearAllAuraCaches"];
	VUHDO_syncAuraContainersForUnit = _G["VUHDO_syncAuraContainersForUnit"];
	VUHDO_degradeAuraCacheForUnit = _G["VUHDO_degradeAuraCacheForUnit"];
	VUHDO_fullAuraRefresh = _G["VUHDO_fullAuraRefresh"];
	VUHDO_updateAllRaidBars = _G["VUHDO_updateAllRaidBars"];
	VUHDO_initUnitAuraSlots = _G["VUHDO_initUnitAuraSlots"];
	VUHDO_refreshListBouquetsForUnit = _G["VUHDO_refreshListBouquetsForUnit"];
	VUHDO_initNativeAuraSounds = _G["VUHDO_initNativeAuraSounds"];
	VUHDO_rebuildSoundEnabledAuraGroups = _G["VUHDO_rebuildSoundEnabledAuraGroups"];
	VUHDO_clearNativeAuraSounds = _G["VUHDO_clearNativeAuraSounds"];

	VUHDO_syncOverlaysForUnit = _G["VUHDO_deferSyncOverlaysForUnit"];
	VUHDO_syncAuraContainersForUnit = _G["VUHDO_deferSyncAuraContainersForUnit"];
	VUHDO_degradeAuraCacheForUnit = _G["VUHDO_deferDegradeAuraCacheForUnit"];
	VUHDO_fullAuraRefresh = _G["VUHDO_deferRefreshUnitAuras"];
	VUHDO_updateAllRaidBars = _G["VUHDO_deferUpdateAllRaidBars"];

	sSecretsEnabled = _G["VUHDO_SECRETS_ENABLED"] == true;

	sIsAuraDataRestricted = VUHDO_AURA_DATA_RESTRICTED == true or (sSecretsEnabled and ShouldAurasBeSecret());

	return;

end



--
function VUHDO_isAuraModeContainers()

	return sIsAuraModeContainers;

end



--
function VUHDO_rebuildAuraModeEventFlags()

	if not sIsAuraModeContainers then
		sNeedsUnitAuraEvent = true;

		return;
	end

	if VUHDO_CONFIG and VUHDO_CONFIG["SMARTCAST_CLEANSE"] then
		sNeedsUnitAuraEvent = true;

		return;
	end

	if VUHDO_CONFIG and (VUHDO_CONFIG["SOUND_DEBUFF"] or "") ~= "" then
		sNeedsUnitAuraEvent = true;

		return;
	end

	if VUHDO_hasConfiguredAuraGroupSounds() then
		sNeedsUnitAuraEvent = true;

		return;
	end

	sNeedsUnitAuraEvent = false;

	return;

end



--
function VUHDO_initAuraModeSelection()

	if VUHDO_FORCE_AURA_MODE == 0 then
		VUHDO_AURA_MODE_CONTAINERS = false;
	else
		VUHDO_AURA_MODE_CONTAINERS = VUHDO_AURA_MODE_CAPABILITY == true;
	end

	sIsAuraModeContainers = VUHDO_AURA_MODE_CONTAINERS == true;

	VUHDO_rebuildAuraModeEventFlags();

	return;

end



--
local tSound;
local tGroupType;
function VUHDO_hasConfiguredAuraGroupSounds()

	if not VUHDO_CONFIG or not VUHDO_CONFIG["AURA_GROUPS"] then
		return false;
	end

	for _, tGroup in pairs(VUHDO_CONFIG["AURA_GROUPS"]) do
		tSound = tGroup["sound"];

		if (tSound or "") ~= "" then
			tGroupType = tGroup["type"] or VUHDO_AURA_GROUP_TYPE_FILTER;

			if tGroupType == VUHDO_AURA_GROUP_TYPE_FILTER or tGroupType == VUHDO_AURA_GROUP_TYPE_LIST then
				return true;
			end
		end
	end

	return false;

end



--
function VUHDO_hasFilterBasedAuraGroupSounds()

	return VUHDO_hasConfiguredAuraGroupSounds();

end



--
function VUHDO_needsUnitAuraEvent()

	return sNeedsUnitAuraEvent;

end



--
function VUHDO_isAuraDataRestricted()

	if VUHDO_FORCE_AURA_DATA_RESTRICTED then
		return true;
	end

	if sIsAuraDataRestricted then
		return true;
	end

	if sSecretsEnabled and ShouldAurasBeSecret() then
		VUHDO_checkAuraDataRestrictedState(true);

		return true;
	end

	return false;

end



--
function VUHDO_shouldDropRestrictedAuraEvent(aUpdateInfo)

	if VUHDO_isAuraDataRestricted() then
		return true;
	end

	if aUpdateInfo and issecretvalue(aUpdateInfo["isFullUpdate"]) then
		VUHDO_checkAuraDataRestrictedState(true);

		return true;
	end

	return false;

end



--
local function VUHDO_determineAuraDataRestricted()

	if VUHDO_FORCE_AURA_DATA_RESTRICTED then
		return true;
	end

	if not sSecretsEnabled then
		return false;
	end

	return ShouldAurasBeSecret();

end



--
function VUHDO_syncAllOverlayUnits(anIsForceRebuild)

	if not VUHDO_RAID then
		return;
	end

	if anIsForceRebuild then
		for tUnit, _ in pairs(VUHDO_RAID) do
			for _, tButton in pairs(VUHDO_getUnitButtonsSafe(tUnit)) do
				VUHDO_releaseOverlaysForButton(tButton);
			end
		end
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_syncOverlaysForUnit(tUnit);
	end

	return;

end



--
function VUHDO_resyncAuraDisplayMode(anIsForceRebuild)

	if not VUHDO_isVariablesLoaded() then
		return;
	end

	if VUHDO_isAuraModeContainers() then
		VUHDO_syncAllOverlayUnits(anIsForceRebuild);

		return;
	end

	if VUHDO_AURA_DATA_RESTRICTED then
		VUHDO_hideAllAuras();
		VUHDO_clearAllAuraCaches();

		for tUnit, _ in pairs(VUHDO_RAID or sEmpty) do
			VUHDO_initUnitAuraSlots(tUnit);
			VUHDO_degradeAuraCacheForUnit(tUnit);
		end

		VUHDO_updateAllRaidBars();

		for tUnit, _ in pairs(VUHDO_RAID or sEmpty) do
			VUHDO_syncAuraContainersForUnit(tUnit);
			VUHDO_refreshListBouquetsForUnit(tUnit);
		end
	else
		for tUnit, _ in pairs(VUHDO_RAID or sEmpty) do
			VUHDO_fullAuraRefresh(tUnit);
		end
	end

	VUHDO_syncAllOverlayUnits(anIsForceRebuild);

	return;

end



--
local function VUHDO_setAuraDataRestrictedState(anIsRestricted, anIsForceResync)

	sIsAuraDataRestricted = anIsRestricted;

	if anIsRestricted == VUHDO_AURA_DATA_RESTRICTED and not anIsForceResync then
		return;
	end

	VUHDO_AURA_DATA_RESTRICTED = anIsRestricted;

	if VUHDO_isAuraModeContainers() and not anIsForceResync then
		if not anIsRestricted then
			VUHDO_flushPendingOverlayAcquires();
		end

		return;
	end

	VUHDO_resyncAuraDisplayMode(anIsForceResync);

	if not anIsRestricted then
		VUHDO_flushPendingOverlayAcquires();
	end

	return;

end



--
function VUHDO_updateAuraDataRestrictedState(anIsForceResync)

	VUHDO_setAuraDataRestrictedState(VUHDO_determineAuraDataRestricted(), anIsForceResync);

	return;

end



--
function VUHDO_checkAuraDataRestrictedState(anIsSecret)

	if anIsSecret and not VUHDO_AURA_DATA_RESTRICTED then
		VUHDO_setAuraDataRestrictedState(true, false);

		return;
	end

	if sSecretsEnabled and VUHDO_AURA_DATA_RESTRICTED ~= VUHDO_determineAuraDataRestricted() then
		VUHDO_updateAuraDataRestrictedState(false);
	end

	return;

end



--
function VUHDO_setForceAuraMode(aMode)

	if aMode == 1 then
		VUHDO_FORCE_AURA_MODE = 1;

		VUHDO_FORCE_AURA_DATA_RESTRICTED = true;
	elseif aMode == 0 then
		VUHDO_FORCE_AURA_MODE = 0;

		VUHDO_FORCE_AURA_DATA_RESTRICTED = false;
	else
		VUHDO_FORCE_AURA_MODE = nil;

		VUHDO_FORCE_AURA_DATA_RESTRICTED = false;
	end

	VUHDO_updateAuraDataRestrictedState(true);

	return;

end



--
function VUHDO_initAuraMode()

	VUHDO_rebuildSoundEnabledAuraGroups();

	if VUHDO_isAuraModeContainers() then
		VUHDO_clearNativeAuraSounds();
		VUHDO_initNativeAuraSounds();
	else
		VUHDO_clearNativeAuraSounds();
	end

	VUHDO_updateAuraDataRestrictedState(true);

	return;

end