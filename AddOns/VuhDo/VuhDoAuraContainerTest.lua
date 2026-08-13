local _;

local pairs = pairs;
local ipairs = ipairs;
local next = next;
local format = string.format;
local tinsert = table.insert;
local tconcat = table.concat;

local InCombatLockdown = InCombatLockdown;
local issecretvalue = issecretvalue;
local CreateFrame = CreateFrame;

local sSmokeTestContainer;



do
	--
	local tDiagColorValue;
	local function VUHDO_formatAuraDiagColorComponent(aComponent)

		if aComponent == nil then
			return "nil";
		end

		if issecretvalue(aComponent) then
			return "secret";
		end

		tDiagColorValue = format("%.3f", aComponent);

		return tDiagColorValue;

	end



	--
	local tDiagR;
	local tDiagG;
	local tDiagB;
	local tDiagA;
	local function VUHDO_dumpAuraDiagTextureVertex(aLabel, aTexture)

		if not aTexture then
			VUHDO_xMsg("  ", aLabel, "texture: nil");

			return;
		end

		tDiagR, tDiagG, tDiagB, tDiagA = aTexture:GetVertexColor();

		VUHDO_xMsg("  ", aLabel,
			"shown", aTexture:IsShown(),
			"r", VUHDO_formatAuraDiagColorComponent(tDiagR),
			"g", VUHDO_formatAuraDiagColorComponent(tDiagG),
			"b", VUHDO_formatAuraDiagColorComponent(tDiagB),
			"a", VUHDO_formatAuraDiagColorComponent(tDiagA));

		return;

	end



	--
	local tGroupKeys;
	local tGroups;
	local tGroupKey;
	local tGroupButtonSetup;
	local tDispelBright;
	local tDispelOpacity;
	local tFillColorMap;
	local tBackingColorMap;
	local tMagicFillColor;
	local tMagicBackingColor;
	local tChainBaselineFrame;
	local tChainBaselineTexture;
	local tChainBaselineMask;
	local tTargetBar;
	local tTargetTexture;
	local tTargetAlpha;
	local tDiagR;
	local tDiagG;
	local tDiagB;
	local tDiagA;
	local tContainer;
	local tContainerWidth;
	local tContainerHeight;
	local tLastSyncedGroupEnabled;
	local tLiveBarWidth;
	local tLiveBarHeight;
	local tGroupLayout;
	local tStaticColor;
	local tStoredBaselineColor;
	local tChainGroupMeta;
	local tChainGroupMetaEntry;
	local tButtonName;
	local tOverlayHostFrame;
	local tOverlayHostWidth;
	local tOverlayHostHeight;
	local tGroupFrameCount;
	local tAuraFrame;
	local tAuraFrameWidth;
	local tAuraFrameHeight;
	local tFillTexture;
	local tCanAccess;
	function VUHDO_dumpFillChainDiagnostics(aContainerData, aContainerTemplate)

		tContainer = aContainerData["container"];

		if tContainer then
			tContainerWidth, tContainerHeight = tContainer:GetSize();

			VUHDO_xMsg("  fillChainContainer",
				"shown", tContainer:IsShown(),
				"enabled", tContainer:IsEnabled(),
				"size", tContainerWidth, tContainerHeight,
				"frameLevel", tContainer:GetFrameLevel());
		end

		tOverlayHostFrame = aContainerTemplate["overlayHostFrame"];

		if tOverlayHostFrame then
			tOverlayHostWidth, tOverlayHostHeight = tOverlayHostFrame:GetSize();

			VUHDO_xMsg("  fillChainHost",
				"clipsChildren", tOverlayHostFrame:DoesClipChildren(),
				"size", tOverlayHostWidth, tOverlayHostHeight);
		end

		tGroupKeys = aContainerData["groupKeys"];
		tGroups = aContainerTemplate["groups"];
		tLastSyncedGroupEnabled = aContainerData["lastSyncedGroupEnabled"];
		tTargetBar = aContainerTemplate["overlayTargetBar"];
		tLiveBarWidth = tTargetBar and tTargetBar:GetWidth();
		tLiveBarHeight = tTargetBar and tTargetBar:GetHeight();
		tChainGroupMeta = aContainerData["chainGroupMeta"];

		if tGroupKeys and tGroups then
			for tGroupIndex = 1, #tGroupKeys do
				tGroupKey = tGroupKeys[tGroupIndex];
				tGroupButtonSetup = nil;
				tGroupLayout = nil;

				for _, tGroupTemplate in ipairs(tGroups) do
					if tGroupTemplate["key"] == tGroupKey then
						tGroupButtonSetup = tGroupTemplate["buttonSetup"];
						tGroupLayout = tGroupTemplate["layout"];

						break;
					end
				end

				tChainGroupMetaEntry = tChainGroupMeta and tChainGroupMeta[tGroupIndex];

				VUHDO_xMsg("  fillChainGroup", tGroupIndex, "key", tGroupKey,
					"groupKey", tChainGroupMetaEntry and tChainGroupMetaEntry["groupKey"],
					"lastSyncedEnabled", tLastSyncedGroupEnabled and tLastSyncedGroupEnabled[tGroupKey],
					"elementWidth", tGroupLayout and tGroupLayout["elementWidth"],
					"elementHeight", tGroupLayout and tGroupLayout["elementHeight"],
					"liveBarWidth", tLiveBarWidth,
					"liveBarHeight", tLiveBarHeight,
					"dispelFill", tGroupButtonSetup and tGroupButtonSetup["dispelFill"],
					"dispelBright", tGroupButtonSetup and tGroupButtonSetup["dispelBright"],
					"dispelOpacity", tGroupButtonSetup and tGroupButtonSetup["dispelOpacity"],
					"shadowValueMode", tGroupButtonSetup and tGroupButtonSetup["shadowValueMode"]);

				tStaticColor = tGroupButtonSetup and tGroupButtonSetup["staticColor"];

				if tStaticColor then
					VUHDO_xMsg("  fillChainGroupStaticColor",
						"r", VUHDO_formatAuraDiagColorComponent(tStaticColor["R"]),
						"g", VUHDO_formatAuraDiagColorComponent(tStaticColor["G"]),
						"b", VUHDO_formatAuraDiagColorComponent(tStaticColor["B"]),
						"a", VUHDO_formatAuraDiagColorComponent(tStaticColor["O"]));
				end

				if tGroupButtonSetup and tGroupButtonSetup["dispelFill"] then
					tDispelBright = tGroupButtonSetup["dispelBright"];
					tDispelOpacity = tGroupButtonSetup["dispelOpacity"];

					tFillColorMap = VUHDO_getDispelTypeBackgroundFillColorMap(tDispelBright, tDispelOpacity);
					tBackingColorMap = VUHDO_getDispelTypeBackgroundBackingColorMap(tDispelBright, tDispelOpacity);

					tMagicFillColor = tFillColorMap and tFillColorMap["Magic"];
					tMagicBackingColor = tBackingColorMap and tBackingColorMap["Magic"];

					if tMagicFillColor then
						tDiagR, tDiagG, tDiagB, tDiagA = tMagicFillColor:GetRGBA();

						VUHDO_xMsg("  mapMagicFill",
							"r", VUHDO_formatAuraDiagColorComponent(tDiagR),
							"g", VUHDO_formatAuraDiagColorComponent(tDiagG),
							"b", VUHDO_formatAuraDiagColorComponent(tDiagB),
							"a", VUHDO_formatAuraDiagColorComponent(tDiagA));
					end

					if tMagicBackingColor then
						tDiagR, tDiagG, tDiagB, tDiagA = tMagicBackingColor:GetRGBA();

						VUHDO_xMsg("  mapMagicBacking",
							"r", VUHDO_formatAuraDiagColorComponent(tDiagR),
							"g", VUHDO_formatAuraDiagColorComponent(tDiagG),
							"b", VUHDO_formatAuraDiagColorComponent(tDiagB),
							"a", VUHDO_formatAuraDiagColorComponent(tDiagA));
					end
				end

				if tContainer and tGroupKey then
					tGroupFrameCount = tContainer:GetAuraGroupFrameCount(tGroupKey);

					VUHDO_xMsg("  fillChainGroupFrames",
						"groupIndex", tGroupIndex,
						"key", tGroupKey,
						"frameCount", tGroupFrameCount);

					for tGroupFrameIndex = 1, tGroupFrameCount do
						tAuraFrame = tContainer:GetAuraGroupFrame(tGroupKey, tGroupFrameIndex);

						if tAuraFrame then
							tCanAccess = tAuraFrame:CanBeAccessedInContext();

							VUHDO_xMsg("  fillChainAuraFrame",
								"groupIndex", tGroupIndex,
								"frameIndex", tGroupFrameIndex,
								"canAccess", tCanAccess);

							if tCanAccess then
								tAuraFrameWidth, tAuraFrameHeight = tAuraFrame:GetSize();

								VUHDO_xMsg("  fillChainAuraFrameState",
									"groupIndex", tGroupIndex,
									"frameIndex", tGroupFrameIndex,
									"shown", tAuraFrame:IsShown(),
									"size", tAuraFrameWidth, tAuraFrameHeight,
									"numPoints", tAuraFrame:GetNumPoints());

								tFillTexture = tAuraFrame["FillTexture"];

								VUHDO_dumpAuraDiagTextureVertex("fillChainFillTexture", tFillTexture);
							end
						end
					end
				end
			end
		end

		tChainBaselineFrame = aContainerData["chainBaselineFrame"];
		tChainBaselineTexture = aContainerData["chainBaselineTexture"];
		tChainBaselineMask = tChainBaselineFrame and tChainBaselineFrame["ChainBaselineMask"];
		tTargetTexture = tTargetBar and tTargetBar:GetStatusBarTexture();
		tTargetAlpha = tTargetTexture and tTargetTexture:GetAlpha();

		tButtonName = tTargetBar and tTargetBar:GetParent() and tTargetBar:GetParent():GetName();
		tStoredBaselineColor = tButtonName and VUHDO_getOverlayChainBaselineStoredColor(tButtonName);

		VUHDO_xMsg("  fillChainBaseline",
			"frameShown", tChainBaselineFrame and tChainBaselineFrame:IsShown(),
			"texShown", tChainBaselineTexture and tChainBaselineTexture:IsShown(),
			"maskPoints", tChainBaselineMask and tChainBaselineMask:GetNumPoints(),
			"targetBarTexAlpha", VUHDO_formatAuraDiagColorComponent(tTargetAlpha));

		if tStoredBaselineColor then
			VUHDO_xMsg("  fillChainStoredBaseline",
				"r", VUHDO_formatAuraDiagColorComponent(tStoredBaselineColor["R"]),
				"g", VUHDO_formatAuraDiagColorComponent(tStoredBaselineColor["G"]),
				"b", VUHDO_formatAuraDiagColorComponent(tStoredBaselineColor["B"]),
				"a", VUHDO_formatAuraDiagColorComponent(tStoredBaselineColor["O"]));
		end

		if tChainBaselineTexture then
			VUHDO_dumpAuraDiagTextureVertex("chainBaseline", tChainBaselineTexture);
		end

		return;

	end

end



do
	--
	local function VUHDO_escapeAuraDiagFilterString(aFilterString)

		if not aFilterString then
			return aFilterString;
		end

		return gsub(aFilterString, "|", "||");

	end



	--
	local tPanelAnchors;
	local tEnabledAnchorCount;
	local tFilterString;
	local tLayoutCapacity;
	local tButtons;
	local tButtonName;
	local tButtonAnchors;
	local tContainer;
	local tContainerTemplate;
	local tGroups;
	local tWidth;
	local tHeight;
	local tIsShown;
	local tIsEnabled;
	local tContainerUnit;
	local tSlots;
	local tSlot;
	local tCandidateFilters;
	local tOverlayContainers;
	local tHasStaticColor;
	function VUHDO_dumpAuraDiagnostics(aUnit)

		aUnit = aUnit or "player";

		VUHDO_xMsg("--- Aura Container Diagnostics ---");
		VUHDO_xMsg("unit:", aUnit);
		VUHDO_xMsg("restricted:", VUHDO_isAuraDataRestricted());
		VUHDO_xMsg("auraMode:", VUHDO_isAuraModeContainers() and "on" or "off");
		VUHDO_xMsg("forceAuraMode:", VUHDO_FORCE_AURA_MODE == nil and "auto" or VUHDO_FORCE_AURA_MODE);
		VUHDO_xMsg("forceRestricted:", VUHDO_FORCE_AURA_DATA_RESTRICTED);
		VUHDO_xMsg("secretsEnabled:", VUHDO_SECRETS_ENABLED);
		VUHDO_xMsg("combatLockdown:", InCombatLockdown());
		VUHDO_xMsg("containerBuilds:", VUHDO_AURA_CONTAINER_METRICS["builds"]["container"] or 0);
		VUHDO_xMsg("containerReleases:", VUHDO_AURA_CONTAINER_METRICS["releases"]["container"] or 0);
		VUHDO_xMsg("containerPoolHits:", VUHDO_AURA_CONTAINER_METRICS["poolHits"]["container"] or 0);

		VUHDO_xMsg("pendingContainerBuilds:", VUHDO_getPendingContainerBuildCount());

		VUHDO_xMsg("pendingOverlayBuilds:", VUHDO_getPendingOverlayBuildCount());

		for tPanelNum = 1, VUHDO_MAX_PANELS do
			if VUHDO_isPanelVisible(tPanelNum) then
				tPanelAnchors = VUHDO_PANEL_SETUP[tPanelNum] and VUHDO_PANEL_SETUP[tPanelNum]["AURA_ANCHORS"];

				if tPanelAnchors then
					tEnabledAnchorCount = 0;

					for tAnchorIndex, tAnchorConfig in pairs(tPanelAnchors) do
						if tAnchorConfig and tAnchorConfig["enabled"] ~= false then
							tEnabledAnchorCount = tEnabledAnchorCount + 1;

							tFilterString = VUHDO_escapeAuraDiagFilterString(VUHDO_resolveAuraContainerFilter(tAnchorConfig));
							tLayoutCapacity = (tAnchorConfig["maxColumns"] or 5) * (tAnchorConfig["maxRows"] or 1);

							VUHDO_xMsg("panel", tPanelNum, "anchor", tAnchorIndex,
								"groupId", tAnchorConfig["groupId"],
								"filter", tFilterString,
								"maxDisplay", tAnchorConfig["maxDisplay"] or 5,
								"layoutCap", tLayoutCapacity);
						end
					end

					VUHDO_xMsg("panel", tPanelNum, "enabledAnchors:", tEnabledAnchorCount);
				else
					VUHDO_xMsg("panel", tPanelNum, "AURA_ANCHORS: nil");
				end
			end
		end

		tButtons = VUHDO_getUnitButtonsSafe(aUnit);

		if not tButtons or not next(tButtons) then
			VUHDO_xMsg("no buttons for unit:", aUnit);
			VUHDO_xMsg("--- End Diagnostics ---");

			return;
		end

		for _, tButton in pairs(tButtons) do
			tButtonName = tButton:GetName();

			if tButtonName then
				tButtonAnchors = VUHDO_AURA_CONTAINERS[tButtonName];

				if not tButtonAnchors then
					VUHDO_xMsg("button", tButtonName, "containers: none");
				else
					for tAnchorIndex, tContainerData in pairs(tButtonAnchors) do
						tContainer = tContainerData and tContainerData["container"];

						if tContainer then
							tWidth, tHeight = tContainer:GetSize();
							tIsShown = tContainer:IsShown();
							tIsEnabled = tContainer:IsEnabled();
							tContainerUnit = tContainer:GetUnit();
							tContainerTemplate = tContainerData["containerTemplate"];
							tGroups = tContainerTemplate and tContainerTemplate["groups"];
							tSlots = tContainerTemplate and tContainerTemplate["slots"];

							VUHDO_xMsg("button", tButtonName, "anchor", tAnchorIndex,
								"shown", tIsShown, "enabled", tIsEnabled,
								"unit", tContainerUnit, "size", tWidth, tHeight,
								"lastSyncedUnit", tContainerData["lastSyncedUnit"],
								"lastSyncedRestricted", tContainerData["lastSyncedRestricted"]);

							if tGroups then
								for tGroupIndex, tGroup in ipairs(tGroups) do
									VUHDO_xMsg("  group", tGroupIndex,
										"filter", VUHDO_escapeAuraDiagFilterString(tGroup["filterString"]),
										"maxFrames", tGroup["maxFrameCount"]);
								end
							end

							if tSlots then
								for tSlotIndex, tSlot in ipairs(tSlots) do
									tCandidateFilters = tSlot["candidateFilters"];

									VUHDO_xMsg("  slot", tSlotIndex,
										"filter", VUHDO_escapeAuraDiagFilterString(tSlot["filterString"]),
										"hasSpellIds", tCandidateFilters and tCandidateFilters["includeSpellIDs"] ~= nil);
								end
							end
						else
							VUHDO_xMsg("button", tButtonName, "anchor", tAnchorIndex, "container: nil");
						end
					end
				end

				tOverlayContainers = VUHDO_OVERLAY_CONTAINERS[tButtonName];

				if not tOverlayContainers then
					VUHDO_xMsg("button", tButtonName, "overlays: none");
				else
					for tIndicatorKey, _ in pairs(tOverlayContainers) do
						for tEntryKey, tContainerData in pairs(tOverlayContainers[tIndicatorKey]) do
							tContainer = tContainerData and tContainerData["container"];

							if tContainer then
								tIsShown = tContainer:IsShown();
								tIsEnabled = tContainer:IsEnabled();
								tContainerUnit = tContainer:GetUnit();

								tContainerTemplate = tContainerData["containerTemplate"];
								tGroups = tContainerTemplate and tContainerTemplate["groups"];

								tFilterString = tGroups and tGroups[1] and tGroups[1]["filterString"];
								tFilterString = tContainerData["overlayFilterString"] or tFilterString;
								tCandidateFilters = tContainerData["overlayCandidateFilters"];
								tHasStaticColor = tContainerData["overlayStaticColor"] ~= nil;

								tSlots = tContainerTemplate and tContainerTemplate["slots"];
								tSlot = tSlots and tSlots[1] and tSlots[1]["buttonSetup"];

								VUHDO_xMsg("overlay", tButtonName, "indicator", tIndicatorKey, "entry", tEntryKey,
									"shown", tIsShown, "enabled", tIsEnabled,
									"unit", tContainerUnit,
									"friendlyOnly", tContainerData["friendlyOnly"],
									"hostileOnly", tContainerData["hostileOnly"],
									"lastSyncedEnabled", tContainerData["lastSyncedEnabled"],
									"filter", VUHDO_escapeAuraDiagFilterString(tFilterString),
									"hasStaticColor", tHasStaticColor,
									"hasSpellIds", tCandidateFilters and tCandidateFilters["includeSpellIDs"] ~= nil,
									"hasDispelTypes", tCandidateFilters and tCandidateFilters["includeDispelTypes"] ~= nil,
									"shadowValueMode", tSlot and tSlot["shadowValueMode"],
									"sublevelLayer", tSlot and tSlot["sublevelSlots"] and tSlot["sublevelSlots"][1] and tSlot["sublevelSlots"][1]["layer"],
									"sublevel", tSlot and tSlot["sublevelSlots"] and tSlot["sublevelSlots"][1] and tSlot["sublevelSlots"][1]["sublevel"],
									"fromPool", tContainerData["fromPool"],
									"frameLevel", tContainer:GetFrameLevel());

								if tContainerTemplate and tContainerTemplate["isFillChain"] then
									VUHDO_dumpFillChainDiagnostics(tContainerData, tContainerTemplate);
								end
							else
								VUHDO_xMsg("overlay", tButtonName, "indicator", tIndicatorKey, "entry", tEntryKey, "container: nil");
							end
						end
					end
				end
			end
		end

		VUHDO_xMsg("--- End Diagnostics ---");

		return;

	end
end



do
	--
	local tClassName;
	local tPanelIndicatorConfig;
	local tBouquetClass;
	local tBouquet;
	local tItem;
	local tSpecial;
	local tHasExpressibleAuraItem;
	local tHasUnsupportedAuraItem;
	local tHasBlindSpotItem;
	local tGroupId;
	local tGroup;
	local tIsExpressible;
	local tAuditAssigned;
	function VUHDO_auditAuraConfiguration()

		VUHDO_Msg("|cffFFD100--- Aura Configuration Audit ---|r");

		VUHDO_Msg(format("Aura mode: %s (capability: %s, override: %s)",
			VUHDO_isAuraModeContainers() and "on" or "off",
			VUHDO_AURA_MODE_CAPABILITY and "yes" or "no",
			VUHDO_FORCE_AURA_MODE == nil and "auto" or tostring(VUHDO_FORCE_AURA_MODE)));

		tAuditAssigned = { };

		for tPanelNum = 1, VUHDO_MAX_PANELS do
			if VUHDO_isPanelVisible(tPanelNum) then
				tPanelIndicatorConfig = VUHDO_INDICATOR_CONFIG and VUHDO_INDICATOR_CONFIG[tPanelNum];

				if tPanelIndicatorConfig and tPanelIndicatorConfig["BOUQUETS"] then
					for tIndicatorKey, tBouquetName in pairs(tPanelIndicatorConfig["BOUQUETS"]) do
						if tBouquetName and tBouquetName ~= "" then
							tAuditAssigned[tBouquetName] = tAuditAssigned[tBouquetName] or { };

							tinsert(tAuditAssigned[tBouquetName], format("panel %d/%s", tPanelNum, tIndicatorKey));
						end
					end
				end
			end
		end

		if VUHDO_BOUQUETS and VUHDO_BOUQUETS["STORED"] then
			for tBouquetName, _ in pairs(VUHDO_BOUQUETS["STORED"]) do
				tBouquetClass = VUHDO_classifyBouquetRestrictedMode(tBouquetName);

				if tBouquetClass == VUHDO_BOUQUET_RESTRICTED_NON_AURA then
					tClassName = "NON_AURA";
				elseif tBouquetClass == VUHDO_BOUQUET_RESTRICTED_AURA_CONTAINER then
					tClassName = "CONTAINER";
				elseif tBouquetClass == VUHDO_BOUQUET_RESTRICTED_MIXED then
					tClassName = "MIXED";
				else
					tClassName = "UNSUPPORTED";
				end

				tHasExpressibleAuraItem = false;
				tHasUnsupportedAuraItem = false;
				tHasBlindSpotItem = false;

				tBouquet = VUHDO_BOUQUETS["STORED"][tBouquetName];
				tBouquet = VUHDO_decompressIfCompressed(tBouquet);

				if type(tBouquet) == "table" then
					for tCnt = 1, #tBouquet do
						tItem = tBouquet[tCnt];
						tSpecial = VUHDO_BOUQUET_BUFFS_SPECIAL[tItem["name"]];

						if tSpecial then
							if tSpecial["custom_type"] == VUHDO_BOUQUET_CUSTOM_TYPE_AURA_GROUP then
								tGroupId = tItem["custom"] and tItem["custom"]["auraGroupId"];
								tGroup = VUHDO_getAuraGroup(tGroupId);

								if tGroup and VUHDO_isAuraGroupContainerExpressible(tGroup) then
									tHasExpressibleAuraItem = true;
								else
									tHasUnsupportedAuraItem = true;
								end
							elseif tItem["name"] == "STACKS" or tItem["name"] == "STACKS_COLOR" or tItem["name"] == "ACTIVE_AURAS_COUNTER" then
								tHasBlindSpotItem = true;
							elseif tBouquetClass == VUHDO_BOUQUET_RESTRICTED_UNSUPPORTED then
								tHasUnsupportedAuraItem = true;
							elseif tBouquetClass == VUHDO_BOUQUET_RESTRICTED_AURA_CONTAINER then
								tHasExpressibleAuraItem = true;
							end
						elseif not VUHDO_strempty(tItem["name"]) and tBouquetClass == VUHDO_BOUQUET_RESTRICTED_MIXED then
							if not VUHDO_resolveAuraContainerSpellId(tItem["name"]) then
								tHasUnsupportedAuraItem = true;
							end
						end
					end
				end

				if tBouquetClass == VUHDO_BOUQUET_RESTRICTED_UNSUPPORTED or tHasBlindSpotItem
					or (tHasExpressibleAuraItem and tHasUnsupportedAuraItem and tBouquetClass ~= VUHDO_BOUQUET_RESTRICTED_MIXED)
					or (tBouquetClass == VUHDO_BOUQUET_RESTRICTED_MIXED and tHasUnsupportedAuraItem) then
					VUHDO_MsgC(format("  bouquet %s: %s", tBouquetName, tClassName), 1, 0.6, 0.2);

					if tAuditAssigned[tBouquetName] then
						VUHDO_Msg("    assigned: " .. tconcat(tAuditAssigned[tBouquetName], ", "));
					end

					if tHasBlindSpotItem then
						VUHDO_Msg("    blind-spot: STACKS / STACKS_COLOR / ACTIVE_AURAS_COUNTER");
					end

					if tHasExpressibleAuraItem and tHasUnsupportedAuraItem and tBouquetClass ~= VUHDO_BOUQUET_RESTRICTED_MIXED then
						VUHDO_Msg("    mixed bouquet: some items silently drop in container mode");
					end

					if tBouquetClass == VUHDO_BOUQUET_RESTRICTED_MIXED and tHasUnsupportedAuraItem then
						VUHDO_Msg("    mixed bouquet: unresolvable aura spell items drop in container mode");
					end
				end
			end
		end

		if VUHDO_CONFIG and VUHDO_CONFIG["AURA_GROUPS"] then
			for tGroupId, tGroup in pairs(VUHDO_CONFIG["AURA_GROUPS"]) do
				tIsExpressible = VUHDO_isAuraGroupContainerExpressible(tGroup);

				if not tIsExpressible then
					VUHDO_MsgC(format("  aura group %s: inexpressible", tGroupId), 1, 0.6, 0.2);
				end
			end
		end

		VUHDO_Msg("|cffFFD100--- End Aura Audit ---|r");

		return;

	end

end



do
	--
	local tButtons;
	local tButtonName;
	local tButtonContainers;
	local tContainer;
	local tContainerTemplate;
	local tSlots;
	local tSlotKey;
	local tSlotFrame;
	local tStaticSlots;
	local tStaticSlotIndex;
	local tStaticFrame;
	local tFrameLevel;
	local tAlpha;
	local tIsShown;
	local tMixedPriorityCutoffs;
	local tLastSlotSuppress;
	local tShouldSuppress;
	local tPriorityCutoff;
	local tEntryIndex;
	local tItemIndex;
	function VUHDO_dumpAuraContainerLevels(aUnit)

		aUnit = aUnit or "player";

		VUHDO_xMsg("--- Aura Container Level Dump ---");
		VUHDO_xMsg("unit:", aUnit);

		tButtons = VUHDO_getUnitButtonsSafe(aUnit);

		if not tButtons or not next(tButtons) then
			VUHDO_xMsg("no buttons for unit:", aUnit);
			VUHDO_xMsg("--- End Level Dump ---");

			return;
		end

		for _, tButton in pairs(tButtons) do
			tButtonName = tButton:GetName();

			if tButtonName then
				VUHDO_xMsg("button", tButtonName,
					"level", tButton:GetFrameLevel(),
					"strata", tButton:GetFrameStrata());

				tButtonContainers = VUHDO_AURA_CONTAINERS[tButtonName];

				if not tButtonContainers then
					VUHDO_xMsg("  containers: none");
				else
					for tAnchorIndex, tContainerData in pairs(tButtonContainers) do
						tContainer = tContainerData and tContainerData["container"];

						if tContainer then
							VUHDO_xMsg("  anchor", tAnchorIndex,
								"containerLevel", tContainer:GetFrameLevel(),
								"strata", tContainer:GetFrameStrata(),
								"shown", tContainer:IsShown(),
								"enabled", tContainer:IsEnabled());

							tMixedPriorityCutoffs = tContainerData["mixedPriorityCutoffs"];

							if tMixedPriorityCutoffs and next(tMixedPriorityCutoffs) then
								for tCutoffEntryIndex, tCutoffItemIndex in pairs(tMixedPriorityCutoffs) do
									VUHDO_xMsg("    mixedPriorityCutoff", "entry", tCutoffEntryIndex, "item", tCutoffItemIndex);
								end
							else
								VUHDO_xMsg("    mixedPriorityCutoffs: none");
							end

							tLastSlotSuppress = tContainerData["lastSlotSuppress"];

							tContainerTemplate = tContainerData["containerTemplate"];
							tSlots = tContainerTemplate and tContainerTemplate["slots"];

							if tSlots then
								for tSlotIndex, tSlot in ipairs(tSlots) do
									tShouldSuppress = nil;
									tSlotKey = tSlot["key"];

									if tSlotKey and tLastSlotSuppress then
										tShouldSuppress = tLastSlotSuppress[tSlotKey];
									end

									VUHDO_xMsg("    templateSlot", tSlotIndex,
										"key", tSlotKey,
										"isStatic", tSlot["isStaticBouquetSlot"] or false,
										"mixedEntry", tSlot["mixedEntryIndex"],
										"mixedItem", tSlot["mixedItemIndex"],
										"frameLevelOffset", tSlot["frameLevelOffset"] or (tSlot["buttonSetup"] and tSlot["buttonSetup"]["frameLevelOffset"]),
										"suppressed", tShouldSuppress);

									if not tSlot["isStaticBouquetSlot"] then
										tSlotKey = tSlot["key"];
										tSlotFrame = tContainerData["slotFrames"] and tContainerData["slotFrames"][tSlotKey];

										if tSlotFrame then
											if tContainerData["lastSyncedRestricted"] then
												VUHDO_xMsg("      engineFrame restricted");
											else
												tFrameLevel = tSlotFrame:GetFrameLevel();
												tIsShown = tSlotFrame:IsShown();
												tAlpha = tSlotFrame:GetAlpha();

												VUHDO_xMsg("      engineFrame",
													"level", tFrameLevel,
													"shown", tIsShown,
													"alpha", tAlpha);
											end
										else
											VUHDO_xMsg("      engineFrame: nil");
										end
									end
								end
							end

							tStaticSlots = tContainerData["staticSlots"];

							if tStaticSlots and next(tStaticSlots) then
								for tStaticSlotKey, tStaticSlot in pairs(tStaticSlots) do
									tStaticSlotIndex = tStaticSlot["slotIndex"];

									tStaticFrame = VUHDO_AURA_FRAMES[tButtonName]
										and VUHDO_AURA_FRAMES[tButtonName][tAnchorIndex]
										and VUHDO_AURA_FRAMES[tButtonName][tAnchorIndex][tStaticSlotIndex];

									if tStaticFrame then
										tFrameLevel = tStaticFrame:GetFrameLevel();
										tIsShown = tStaticFrame:IsShown();
										tAlpha = tStaticFrame:GetAlpha();

										tEntryIndex = tStaticSlot["entryIndex"];
										tItemIndex = tStaticSlot["itemIndex"];
										tPriorityCutoff = tEntryIndex and tMixedPriorityCutoffs and tMixedPriorityCutoffs[tEntryIndex];

										VUHDO_xMsg("    staticSlot", tStaticSlotKey,
											"slotIndex", tStaticSlotIndex,
											"entryIndex", tEntryIndex,
											"itemIndex", tItemIndex,
											"priorityCutoff", tPriorityCutoff,
											"frameLevelOffset", tStaticSlot["frameLevelOffset"],
											"level", tFrameLevel,
											"shown", tIsShown,
											"alpha", tAlpha,
											"geometryKey", tStaticFrame["staticSlotGeometryKey"]);
									else
										VUHDO_xMsg("    staticSlot", tStaticSlotKey, "frame: nil");
									end
								end
							end
						else
							VUHDO_xMsg("  anchor", tAnchorIndex, "container: nil");
						end
					end
				end
			end
		end

		VUHDO_xMsg("--- End Level Dump ---");

		return;

	end
end



do
	--
	local tButton;
	local tContainer;
	local tButtons;
	function VUHDO_createAuraContainerSmokeTest(aUnit)

		aUnit = aUnit or "player";

		if InCombatLockdown() then
			VUHDO_xMsg("Aura smoke test blocked: combat lockdown.");

			return;
		end

		tButtons = VUHDO_getUnitButtonsSafe(aUnit);

		if not tButtons or not next(tButtons) then
			VUHDO_xMsg("Aura smoke test: no button for unit", aUnit);

			return;
		end

		for _, tCandidateButton in pairs(tButtons) do
			tButton = tCandidateButton;

			break;
		end

		if sSmokeTestContainer then
			sSmokeTestContainer:SetEnabled(false);
			sSmokeTestContainer:SetShown(false);

			sSmokeTestContainer:Hide();

			sSmokeTestContainer = nil;
		end

		tContainer = CreateFrame("AuraContainer", "VuhDoAuraSmokeTest", tButton, "VuhDoAuraContainerTemplate");

		tContainer:ClearAllPoints();

		VUHDO_PixelUtil.SetPoint(tContainer, "TOPRIGHT", tButton, "TOPRIGHT", -2, -2);
		tContainer:SetFrameLevel(tButton:GetFrameLevel() + 20);

		tContainer:SetFlowLayoutAnchorPoint("TOPRIGHT");
		tContainer:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Left, AnchorUtil.FlowDirection.Down);
		tContainer:SetFlowLayoutPadding(0, 0, 0, 0);

		tContainer:AddAuraGroup("test", "HELPFUL", {
			["maxFrameCount"] = 5,
			["sortMethod"] = AuraContainerSortMethod.Default,
			["sortDirection"] = AuraContainerSortDirection.Normal,
			["templateNames"] = { VUHDO_AURA_BUTTON_ICON_TEMPLATE },
			["layout"] = {
				["elementWidth"] = 20,
				["elementHeight"] = 20,
				["elementSpacing"] = 2,
				["lineSpacing"] = 2,
			},
		});

		tContainer:SetUnit(aUnit);
		tContainer:SetEnabled(true);
		tContainer:SetShown(true);
		tContainer:Show();

		sSmokeTestContainer = tContainer;

		VUHDO_xMsg("Aura smoke test created on", tButton:GetName(), "for", aUnit);

		return;

	end

end