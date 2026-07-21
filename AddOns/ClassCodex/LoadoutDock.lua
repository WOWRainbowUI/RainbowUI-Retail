local _, ns = ...

-------------------------------------------------------------------------------
-- LoadoutDock: tiny floating widget that shows the player's currently active
-- talent loadout name and, on click, pops a menu of every other build they
-- could switch to — Blizzard saved loadouts plus Class Codex recommendations.
--
-- Lives independently from the character-frame docked panel and the
-- Compendium. Hidden by default; opt-in via Settings > Class Codex >
-- "Show Loadout Dock". Position persists per-character. Drag the label to
-- move it (when unlocked); right-click for lock / hide / settings.
-------------------------------------------------------------------------------

local DOCK_DEFAULT_WIDTH = 200
local DOCK_MIN_WIDTH = 120
local DOCK_MAX_WIDTH = 400
local DOCK_HEIGHT = 22
local ICON_SIZE = 14 -- shared between spec and hero icons so they line up
local PAD = 6
local ICON_GAP = 4
local LABEL_GAP = 6

local dock = nil

-- Per-spec cache of the configID Blizzard most recently loaded. Updated
-- from C_ClassTalents.LoadConfig (hooked at module init) so the dock
-- mirrors whichever loadout the player picked in Blizzard's dropdown —
-- and, for free, whichever one CC's apply path loaded.
--
-- This sidesteps the two single-API workarounds we tried earlier:
--   - GetLastSelectedSavedConfigID stays stuck on the last saved one the
--     player explicitly clicked, ignoring programmatic LoadConfig.
--   - GetActiveConfigID returns the scratch buffer (spec-named) whenever
--     the player is on a saved loadout via Blizzard's dropdown.
-- Hooking LoadConfig is what Blizzard's own dropdown effectively reacts
-- to, so the dock now shows the same name the dropdown does.
local lastLoadedConfigBySpec = {}

local function GetCharDB()
    return ClassCodexCharDB
end

local function configName(id)
    if not id or not C_Traits or not C_Traits.GetConfigInfo then return nil end
    local info = C_Traits.GetConfigInfo(id)
    if info and info.name and info.name ~= "" then return info.name end
    return nil
end

local function GetCurrentSpecID()
    return PlayerUtil and PlayerUtil.GetCurrentSpecID and PlayerUtil.GetCurrentSpecID() or nil
end

-- Is `id` still one of the spec's live saved loadouts? C_Traits.GetConfigInfo
-- can return a stale non-nil table for a since-deleted config (the same hazard
-- ImportExport.GetStoredConfigID guards against), so a cached ID must be
-- re-validated against the live list before we trust its name. Returns true
-- when we can't validate (missing API) so we never hide a real name.
local function IsLiveSavedConfig(specID, id)
    if not id or not specID or not C_ClassTalents.GetConfigIDsBySpecID then return true end
    local ids = C_ClassTalents.GetConfigIDsBySpecID(specID)
    if not ids then return true end
    for _, cid in ipairs(ids) do
        if cid == id then return true end
    end
    return false
end

local function GetActiveLoadoutName()
    if not C_ClassTalents then return nil end
    local specID = GetCurrentSpecID()

    -- Cached: whichever configID was loaded most recently for this spec.
    -- Evict it first if the player deleted that loadout in Blizzard's UI —
    -- otherwise the stale GetConfigInfo table keeps the dock showing a
    -- loadout that no longer exists.
    if specID then
        local cached = lastLoadedConfigBySpec[specID]
        if cached and not IsLiveSavedConfig(specID, cached) then
            lastLoadedConfigBySpec[specID] = nil
            cached = nil
        end
        local name = configName(cached)
        if name then return name end
    end

    -- Cold-start fallback before any LoadConfig has fired this session.
    if specID and C_ClassTalents.GetLastSelectedSavedConfigID then
        local savedID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
        if savedID then
            lastLoadedConfigBySpec[specID] = savedID
            local name = configName(savedID)
            if name then return name end
        end
    end

    -- Last-resort fallback: the scratch buffer (typically spec-named).
    local active = C_ClassTalents.GetActiveConfigID and C_ClassTalents.GetActiveConfigID()
    return configName(active)
end

-- Find the u.gg-sourced Class Codex build whose talent bits match the
-- player's current in-game talents.
-- Talent bits for the build the player is currently running. Prefer the
-- actually-selected saved loadout's committed talents: those resolve
-- correctly right after login, whereas ns.GetActiveTalentSignature reads the
-- scratch/active config which can stay stale until the first spec change
-- (the cause of "checkmarks only appear after changing spec"). Fall back to
-- the live signature (covers unsaved in-progress edits and cold start).
local function GetCurrentLoadoutBits()
    if not (C_Traits and C_Traits.GenerateImportString and ns.ExtractTalentBits) then
        return ns.GetActiveTalentSignature and ns.GetActiveTalentSignature() or nil
    end
    local specID = GetCurrentSpecID()
    local id = specID and lastLoadedConfigBySpec[specID]
    if id and not IsLiveSavedConfig(specID, id) then id = nil end
    if not id and specID and C_ClassTalents and C_ClassTalents.GetLastSelectedSavedConfigID then
        id = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
    end
    if id then
        local ok, str = pcall(C_Traits.GenerateImportString, id)
        if ok and str then
            local bits = ns.ExtractTalentBits(str)
            if bits then return bits end
        end
    end
    return ns.GetActiveTalentSignature and ns.GetActiveTalentSignature() or nil
end

-- The set of talent signatures representing what the player is running: the
-- live scratch (ns.GetActiveTalentSignature) AND the selected saved loadout
-- (GetCurrentLoadoutBits). A build counts as "current" if it matches EITHER —
-- the scratch resolves an applied build reliably, and the saved-loadout bits
-- cover the just-after-login case; and a build applied from one source can
-- differ in encoding from the "same" build published by another, so matching
-- either is what makes the marker appear consistently.
local function CurrentTalentSignatures()
    local sigs = {}
    local scratch = ns.GetActiveTalentSignature and ns.GetActiveTalentSignature()
    if scratch then sigs[scratch] = true end
    local loadout = GetCurrentLoadoutBits()
    if loadout then sigs[loadout] = true end
    return sigs
end

local function BuildBitsMatch(exportString, sigs)
    if not exportString or not ns.ExtractTalentBits then return false end
    local b = ns.ExtractTalentBits(exportString)
    return b ~= nil and sigs[b] == true
end

local function MatchCodexBuild(specData)
    if not specData or not specData.talents then return nil end
    local sigs = CurrentTalentSignatures()
    if not next(sigs) then return nil end
    for _, build in ipairs(specData.talents) do
        if BuildBitsMatch(build.exportString, sigs) then return build end
    end
    return nil
end

-- Find the u.gg-sourced build whose talent bits match the player's
-- current in-game talents. Returns (build, ctx) or nil.
local function MatchUggBuild(classToken, specKey)
    if not classToken or not specKey then return nil end
    if not ns.GetUggSpecData or not ns.ExtractTalentBits then return nil end
    local sd = ns.GetUggSpecData(classToken, specKey)
    if not sd or not sd.contexts then return nil end
    local sigs = CurrentTalentSignatures()
    if not next(sigs) then return nil end
    for _, ctx in pairs(sd.contexts) do
        if ctx.builds then
            for _, build in ipairs(ctx.builds) do
                if BuildBitsMatch(build.exportString, sigs) then return build, ctx end
            end
        end
    end
    return nil
end

-- Lay out icons + label per alignment. Uses absolute x-offsets for icons
-- so the spec/hero pair shifts with the alignment setting; the label
-- keeps a dual LEFT+RIGHT anchor (so it always has a non-zero render
-- width regardless of GetStringWidth timing) and JustifyH does the
-- final positioning of the text within that span.
local function LayoutDockContent()
    if not dock then return end
    local alignment = (ClassCodexDB and ClassCodexDB.dockLoadoutAlignment) or "LEFT"
    local frameW = dock:GetWidth() or DOCK_DEFAULT_WIDTH

    local hasSpec = dock.specIcon:IsShown()
    local hasHero = dock.heroIcon:IsShown()
    local iconCount = (hasSpec and 1 or 0) + (hasHero and 1 or 0)
    local iconsW = iconCount * ICON_SIZE + math.max(0, iconCount - 1) * ICON_GAP
    local labelW = (dock.label:GetStringWidth() or 0)
    local groupW = iconsW + (iconCount > 0 and labelW > 0 and LABEL_GAP or 0) + labelW

    -- Icons-only offset: shifts the spec/hero pair as a sub-group,
    -- while the label below stretches across the remaining width and
    -- JustifyH decides where its text sits.
    local iconOffset
    if alignment == "CENTER" then
        iconOffset = math.max(PAD, math.floor((frameW - groupW) / 2))
    elseif alignment == "RIGHT" then
        iconOffset = math.max(PAD, frameW - groupW - PAD)
    else
        iconOffset = PAD
    end

    dock.specIcon:ClearAllPoints()
    dock.heroIcon:ClearAllPoints()
    dock.label:ClearAllPoints()

    local cursor = iconOffset
    if hasSpec then
        dock.specIcon:SetPoint("LEFT", cursor, 0)
        cursor = cursor + ICON_SIZE + (hasHero and ICON_GAP or 0)
    end
    if hasHero then
        dock.heroIcon:SetPoint("LEFT", cursor, 0)
        cursor = cursor + ICON_SIZE
    end

    -- Label: dual-anchored so it always renders even when GetStringWidth
    -- hasn't propagated yet. JustifyH inside drives the visual alignment.
    local labelLeft = (iconCount > 0) and (cursor + LABEL_GAP) or PAD
    dock.label:SetPoint("LEFT", labelLeft, 0)
    dock.label:SetPoint("RIGHT", -PAD, 0)

    if alignment == "CENTER" then
        dock.label:SetJustifyH("CENTER")
    elseif alignment == "RIGHT" then
        dock.label:SetJustifyH("RIGHT")
    else
        dock.label:SetJustifyH("LEFT")
    end
end

local function RefreshLabel()
    if not dock then return end
    local db = ClassCodexDB or {}
    local L = ns.L or setmetatable({}, { __index = function(_, k) return k end })

    -- Spec icon
    local showSpec = db.dockLoadoutShowSpecIcon ~= false
    if showSpec then
        local specIndex = GetSpecialization and GetSpecialization()
        if specIndex then
            local _, _, _, iconTex = GetSpecializationInfo(specIndex)
            if iconTex then
                dock.specIcon:SetTexture(iconTex)
                dock.specIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
                dock.specIcon:Show()
            else
                dock.specIcon:Hide()
            end
        else
            dock.specIcon:Hide()
        end
    else
        dock.specIcon:Hide()
    end

    -- Hero icon
    local showHero = db.dockLoadoutShowHeroIcon ~= false
    local heroName = ns.GetActiveHeroTalentName and ns.GetActiveHeroTalentName()
    local heroAtlas = heroName and ns.HERO_TALENT_ATLAS and ns.HERO_TALENT_ATLAS[heroName]
    if showHero and heroAtlas then
        dock.heroIcon:SetAtlas(heroAtlas)
        dock.heroIcon:Show()
    else
        dock.heroIcon:Hide()
    end

    -- Resolve label text and set it BEFORE measuring or laying out.
    local labelText
    local active = GetActiveLoadoutName()
    if active and active ~= "" then
        labelText = active
    else
        local specData = ns.GetSpecData and ns.GetSpecData()
        local codexMatch = MatchCodexBuild(specData)
        if codexMatch and ns.FormatBuildLabel then
            labelText = ns.FormatBuildLabel(codexMatch)
        else
            local classToken, specSlug
            if ns.GetClassAndSpec then classToken, specSlug = ns.GetClassAndSpec() end
            local uggBuild, uggCtx = MatchUggBuild(classToken, specSlug)
            if uggBuild and uggCtx then
                labelText = (ns.GetUggEncounterLabel and ns.GetUggEncounterLabel(uggCtx)) or "u.gg"
            end
        end
    end
    -- Nothing matched (an unsaved scratch build): show the muted fallback.
    if not labelText or labelText == "" then
        labelText = "|cff808080" .. L["loadout_dock.custom_build"] .. "|r"
    end
    dock.label:SetText(labelText)

    -- Auto-width before layout so the dock is the right size when we
    -- compute alignment offset.
    if ClassCodexDB and ClassCodexDB.dockLoadoutAutoWidth then
        ns.ApplyLoadoutDockWidth()
    end

    -- Lay out immediately AND on the next frame. The deferred pass
    -- handles the case where SetText hasn't been processed yet so
    -- GetStringWidth returns 0 on the immediate call.
    LayoutDockContent()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            if dock and dock:IsShown() then
                if ClassCodexDB and ClassCodexDB.dockLoadoutAutoWidth then
                    ns.ApplyLoadoutDockWidth()
                end
                LayoutDockContent()
            end
        end)
    end
end

-- Build the loadout-switch menu (left-click).
-- Inline status marker appended to a Saved Loadouts entry's label. Inline
-- markup (not a frame texture) because the menu runs its initializers in a
-- secure/restricted context where creating textures on the button frame is
-- unreliable. `kind`:
--   "current" — the selected loadout (gold checkmark)
--   "match"   — a DIFFERENT loadout whose talents equal the build you're
--               currently running (muted grey dot, distinct from the check)
-- Gold check = the loadout you're actively on (the selected saved loadout).
-- Green dot = any other entry whose talents match your current build (an
-- identical saved loadout, or a u.gg/Icy Veins/PvP recommendation you're
-- currently running) — a distinct shape from the checkmark. Inline markup —
-- the menu's secure initializer context rejects creating frame textures, so
-- these can't be arrow-column aligned.
local MARKER_CURRENT = "  |TInterface\\Buttons\\UI-CheckBox-Check:16:16:0:0|t"
local MARKER_MATCH   = "  |TInterface\\COMMON\\Indicator-Green:12:12:0:0|t"
local function LoadoutMarker(kind)
    if kind == "current" then return MARKER_CURRENT
    elseif kind == "match" then return MARKER_MATCH end
    return ""
end

local function BuildLoadoutMenu(_, root)
    local L = ns.L or setmetatable({}, { __index = function(_, k) return k end })
    local specID = PlayerUtil and PlayerUtil.GetCurrentSpecID and PlayerUtil.GetCurrentSpecID()
    local specData = ns.GetSpecData and ns.GetSpecData()
    -- Both signatures of what's currently running (scratch + selected loadout).
    local sigs = CurrentTalentSignatures()
    local activeID = C_ClassTalents and C_ClassTalents.GetActiveConfigID and C_ClassTalents.GetActiveConfigID() or nil
    local activeExport = activeID and C_Traits and C_Traits.GenerateImportString and C_Traits.GenerateImportString(activeID) or nil
    -- Per-spec memory of the last build applied via the dock. Survives
    -- the round-trip drift between u.gg's published exportString and
    -- the one Blizzard's stage/commit emits, which can defeat both the
    -- bit and full-string comparisons below. Validated against the bits
    -- that were active right after the apply settled — if the player
    -- has since manually changed talents, current bits diverge from the
    -- captured snapshot and the memo is invalidated (stale memo cleared
    -- so it doesn't keep falsely highlighting an entry).
    local perSpec = (ns.GetPerSpecState and ns.GetPerSpecState()) or nil
    local lastAppliedExport = perSpec and perSpec.lastAppliedBuildExport or nil
    local lastAppliedBits = perSpec and perSpec.lastAppliedBuildBits or nil
    if lastAppliedExport and lastAppliedBits and next(sigs) and not sigs[lastAppliedBits] then
        if perSpec then
            perSpec.lastAppliedBuildExport = nil
            perSpec.lastAppliedBuildBits = nil
        end
        lastAppliedExport = nil
        lastAppliedBits = nil
    end

    local function activeMatches(exportString)
        if not exportString then return false end
        if lastAppliedExport and lastAppliedBits and lastAppliedExport == exportString
           and sigs[lastAppliedBits] then
            return true
        end
        if activeExport and activeExport == exportString then return true end
        return BuildBitsMatch(exportString, sigs)
    end

    local function rememberApplied(exportString)
        local p = ns.GetPerSpecState and ns.GetPerSpecState()
        if p and exportString then p.pendingApplyBuildExport = exportString end
    end

    local db = ClassCodexDB or {}

    -- Section 1: Blizzard saved loadouts for the current spec.
    local hasBlizzard = false
    if db.dockLoadoutShowSaved ~= false and specID and C_ClassTalents and C_ClassTalents.GetConfigIDsBySpecID then
        local configs = C_ClassTalents.GetConfigIDsBySpecID(specID)
        if configs and #configs > 0 then
            -- Which saved loadout is actually selected. GetActiveConfigID
            -- returns the scratch buffer (spec-named), not the saved loadout,
            -- so resolve the selection the same way the dock label does:
            -- most-recently-loaded (validated) first, then Blizzard's pointer.
            local activeSavedID = specID and lastLoadedConfigBySpec[specID]
            if activeSavedID and not IsLiveSavedConfig(specID, activeSavedID) then
                activeSavedID = nil
            end
            if not activeSavedID and specID and C_ClassTalents.GetLastSelectedSavedConfigID then
                activeSavedID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
            end
            root:CreateTitle(L["loadout_dock.saved_loadouts"])
            for _, configID in ipairs(configs) do
                local info = C_Traits and C_Traits.GetConfigInfo and C_Traits.GetConfigInfo(configID)
                local name = info and info.name or ("Loadout " .. configID)
                -- Brand-tint the Class Codex slot blue so it reads the same
                -- here as in the native talent dropdown and stands out from
                -- the player's own (white) loadouts.
                if ns.IsCCSlotName and ns.IsCCSlotName(name) and ns.WrapCCName then
                    name = ns.WrapCCName(name)
                end
                -- Marker: gold check on the selected loadout, muted grey dot on
                -- any OTHER loadout whose talents equal the build you're
                -- currently running.
                local kind
                if activeSavedID and configID == activeSavedID then
                    kind = "current"
                elseif C_Traits and C_Traits.GenerateImportString then
                    local ok, str = pcall(C_Traits.GenerateImportString, configID)
                    if ok and str and activeMatches(str) then kind = "match" end
                end
                name = name .. LoadoutMarker(kind)
                root:CreateButton(name, function()
                    if InCombatLockdown() then
                        UIErrorsFrame:AddMessage(L["loadout_dock.cannot_switch_combat"], 1, 0.3, 0.3)
                        return
                    end
                    -- Switching to a non-CC saved loadout: mirror the proven
                    -- apply-path sequence in ImportExport.lua. A bare
                    -- LoadConfig silently no-ops when it returns Error, and
                    -- without UpdateLastSelectedSavedConfigID the spec's
                    -- "last selected" pointer (which the dock label and the
                    -- talent UI both read) doesn't follow the switch — so the
                    -- loadout doesn't truly become active.
                    local result = C_ClassTalents.LoadConfig(configID, true)
                    if result == Enum.LoadConfigResult.Error then
                        UIErrorsFrame:AddMessage(L["loadout_dock.switch_failed"], 1, 0.3, 0.3)
                        return
                    end
                    if specID and C_ClassTalents.UpdateLastSelectedSavedConfigID then
                        C_ClassTalents.UpdateLastSelectedSavedConfigID(specID, configID)
                    end
                    -- Refresh fires on TRAIT_CONFIG_UPDATED.
                end)
            end
            hasBlizzard = true
        end
    end

    -- (Removed) A former "u.gg builds grouped by hero" section read
    -- ns.GetSpecData().talents, but SourceAdapter populates that field from
    -- Icy Veins talent data (it feeds the Guide preview) — so it rendered the
    -- Icy Veins builds a second time under a wrong "u.gg" header, duplicating
    -- the real Icy Veins section below. The genuine u.gg builds are the
    -- per-encounter recommendations in the section that follows.

    -- Shared spec identity for the Icy Veins, u.gg, and PvP sections below.
    -- u.gg's data table is keyed by the spec slug (e.g. "frost"), the SECOND
    -- return of GetClassAndSpec.
    local classToken, specSlug
    if ns.GetClassAndSpec then classToken, specSlug = ns.GetClassAndSpec() end

    -- Section 2: Class Codex - Icy Veins talent builds. Ordered first to match
    -- the docked panel's source order (Icy Veins, u.gg, PvP). IV builds are
    -- context-labeled (not hero-grouped), and there are only a handful per
    -- spec, so they render as a flat list under the source title rather than
    -- nested submenus. Leveling builds are included inline.
    local hasIcyVeins = false
    if db.dockLoadoutShowIcyVeins ~= false and classToken and specSlug and ns.GetIcyVeinsTalentSpecData then
        local ivSpecData = ns:GetIcyVeinsTalentSpecData(classToken, specSlug)
        if ivSpecData and ivSpecData.talents and #ivSpecData.talents > 0 then
            if hasBlizzard then root:CreateDivider() end
            root:CreateTitle("|TInterface\\AddOns\\ClassCodex\\Textures\\icyveins:14:14:0:0|t  " .. (L["settings.value.icyveins"] or "Icy Veins"))
            for _, build in ipairs(ivSpecData.talents) do
                local capturedExport = build.exportString
                local capturedLabel = build.buildLabel or build.context or "Build"
                local label = capturedLabel
                if activeMatches(capturedExport) then
                    label = label .. MARKER_MATCH
                end
                root:CreateButton(label, function()
                    if InCombatLockdown() then
                        UIErrorsFrame:AddMessage(L["loadout_dock.cannot_switch_combat"], 1, 0.3, 0.3)
                        return
                    end
                    rememberApplied(capturedExport)
                    if ns.ApplyTalentExportString then
                        ns.ApplyTalentExportString(capturedExport, "Icy Veins " .. capturedLabel)
                    end
                end)
            end
            hasIcyVeins = true
        end
    end

    -- Section 3: Class Codex - u.gg (per-encounter recommendations).
    -- Falls back to direct _G.ClassCodexUggBuilds lookup if the namespace
    -- helper is missing.
    local uggSpecData
    if db.dockLoadoutShowUgg ~= false and classToken and specSlug then
        if ns.GetUggSpecData then
            uggSpecData = ns.GetUggSpecData(classToken, specSlug)
        end
        if not uggSpecData and _G.ClassCodexUggBuilds and _G.ClassCodexUggBuilds[classToken] then
            uggSpecData = _G.ClassCodexUggBuilds[classToken][specSlug]
        end
    end
    local hasUgg = false
    -- Diagnostic surface: when the u.gg lookup fails, render a visible
    -- breadcrumb in the menu instead of silently dropping the section so
    -- it's obvious whether the data, the helper, or the lookup itself is
    -- the issue.
    local uggReason
    if not classToken then uggReason = "no class detected"
    elseif not specSlug then uggReason = "no spec slug detected"
    elseif not _G.ClassCodexUggBuilds then uggReason = "ClassCodexUggBuilds global missing"
    elseif not _G.ClassCodexUggBuilds[classToken] then uggReason = "no ugg data for class " .. classToken
    elseif not _G.ClassCodexUggBuilds[classToken][specSlug] then uggReason = "no ugg data for " .. classToken .. "/" .. specSlug
    elseif not uggSpecData then uggReason = "spec data resolution returned nil"
    elseif not uggSpecData.contexts then uggReason = "spec data has no contexts table"
    elseif not ns.GroupUggContexts then uggReason = "GroupUggContexts helper missing"
    end
    if uggReason then
        if hasBlizzard or hasIcyVeins then
            root:CreateDivider()
        end
        root:CreateTitle("|TInterface\\AddOns\\ClassCodex\\Textures\\ugg:14:14:0:0|t  " .. L["settings.value.ugg"])
        root:CreateButton("|cff999999" .. uggReason .. "|r", function() end)
    end
    if uggSpecData and uggSpecData.contexts and ns.GroupUggContexts then
        local groups = ns.GroupUggContexts(uggSpecData)

        local function uggLabel(entry, override)
            local ctx = entry.ctx
            local base = override or (ns.GetUggEncounterLabel and ns.GetUggEncounterLabel(ctx)) or entry.contextKey
            local build = ctx.builds and ctx.builds[1]
            if build and build.heroTalent and ns.HERO_TALENT_ATLAS then
                local atlas = ns.HERO_TALENT_ATLAS[build.heroTalent]
                if atlas then
                    base = "|A:" .. atlas .. ":12:12|a " .. base
                end
            end
            if build and activeMatches(build.exportString) then
                base = base .. MARKER_MATCH
            end
            return base, build
        end

        local function uggApply(parent, entry, override)
            local label, build = uggLabel(entry, override)
            if not build then return end
            parent:CreateButton(label, function()
                if InCombatLockdown() then
                    UIErrorsFrame:AddMessage(L["loadout_dock.cannot_switch_combat"], 1, 0.3, 0.3)
                    return
                end
                local clean = label:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|A:[^|]+|a", ""):gsub("^%s+", "")
                rememberApplied(build.exportString)
                if ns.ApplyTalentExportString then
                    ns.ApplyTalentExportString(build.exportString, clean)
                end
            end)
        end

        local hasAny = groups.mplusOverview or groups.raidOverviewMythic or groups.raidOverviewHeroic
            or #groups.mplusDungeons > 0 or #groups.raidMythicBosses > 0 or #groups.raidHeroicBosses > 0
        if hasAny then
            if hasBlizzard or hasIcyVeins then root:CreateDivider() end
            root:CreateTitle("|TInterface\\AddOns\\ClassCodex\\Textures\\ugg:14:14:0:0|t  " .. L["settings.value.ugg"])

            -- M+ Dungeons submenu — overview ("All Dungeons") sits as the
            -- first entry inside the submenu rather than as a separate
            -- top-level item, so the menu surface stays compact.
            if groups.mplusOverview or #groups.mplusDungeons > 0 then
                local sub = root:CreateButton(L["context.mplus_dungeons"])
                if groups.mplusOverview then uggApply(sub, groups.mplusOverview) end
                for _, e in ipairs(groups.mplusDungeons) do uggApply(sub, e) end
            end
            -- Heroic before Mythic — most players gear up through Heroic
            -- first, so the more-likely-to-be-clicked submenu sits closer
            -- to the M+ Dungeons entry above.
            if groups.raidOverviewHeroic or #groups.raidHeroicBosses > 0 then
                local sub = root:CreateButton(L["context.raid_heroic"])
                if groups.raidOverviewHeroic then uggApply(sub, groups.raidOverviewHeroic) end
                for _, e in ipairs(groups.raidHeroicBosses) do uggApply(sub, e) end
            end
            if groups.raidOverviewMythic or #groups.raidMythicBosses > 0 then
                local sub = root:CreateButton(L["context.raid_mythic"])
                if groups.raidOverviewMythic then uggApply(sub, groups.raidOverviewMythic) end
                for _, e in ipairs(groups.raidMythicBosses) do uggApply(sub, e) end
            end
            hasUgg = true
        end
    end

    -- Section 4: Class Codex - PvP (per-bracket recommendations from
    -- Bnet talent_loadout_code + u.gg). Mirrors u.gg's submenu
    -- pattern (M+ Dungeons / Raid Heroic / Raid Mythic above): an
    -- "Arena" submenu groups Solo Shuffle / 2v2 / 3v3, and a
    -- "Battleground" submenu groups Blitz / RBG. Clicking a bracket
    -- applies the top class talent build for that bracket and, when in
    -- a PvP zone, also applies the top honor talent set.
    local hasPvp = false
    if classToken and specSlug and ns.GetPvPBracketsWithData then
        local pvpBrackets = ns.GetPvPBracketsWithData(classToken, specSlug)
        if pvpBrackets and #pvpBrackets > 0 then
            local ARENA_GROUP = { "pvp-shuffle", "pvp-2v2", "pvp-3v3" }
            local BG_GROUP    = { "pvp-blitz", "pvp-rbg" }
            local available = {}
            for _, k in ipairs(pvpBrackets) do available[k] = true end

            -- `parent` is whichever menu node we're attaching to (root
            -- for fallback flat rendering, an Arena/BG submenu otherwise).
            -- Emits one apply-able entry for a specific (bracket, hero,
            -- build) triple. Used both for the canonical single-build
            -- flow and per-hero in a multi-hero bracket submenu.
            local function emitBuildButton(parent, bracketData, build, bracketKey, label)
                local capturedBuild = build
                local capturedKey = bracketKey
                local capturedHonor = (bracketData.pvpTalentSets
                    and bracketData.pvpTalentSets[1]
                    and bracketData.pvpTalentSets[1].talents) or nil
                -- Append honor talent icon strip so the bracket entry shows
                -- *what* will be applied, not just the bracket name. The
                -- talents themselves still get applied lazily on click,
                -- gated by War Mode / instance — see ApplyPvpHonorTalents.
                if capturedHonor and ns.FormatHonorTalentIcon then
                    local icons = ""
                    for _, talentId in ipairs(capturedHonor) do
                        icons = icons .. ns.FormatHonorTalentIcon(talentId)
                    end
                    if icons ~= "" then label = label .. "  " .. icons end
                end
                if activeMatches(build.exportString) then
                    label = label .. MARKER_MATCH
                end
                local capturedHero = build.heroTalent
                local entry = parent:CreateButton(label, function()
                    if InCombatLockdown() then
                        UIErrorsFrame:AddMessage(L["loadout_dock.cannot_switch_combat"], 1, 0.3, 0.3)
                        return
                    end
                    local loadoutLabel = "PvP — " ..
                        ((ns.GetPvPBracketName and ns.GetPvPBracketName(capturedKey)) or capturedKey)
                    rememberApplied(capturedBuild.exportString)
                    if ns.ApplyTalentExportString then
                        ns.ApplyTalentExportString(capturedBuild.exportString, loadoutLabel)
                    end
                    if capturedHonor and ns.ApplyPvpHonorTalents then
                        ns.ApplyPvpHonorTalents(capturedHonor)
                    end
                end)
                -- Attach a hover tooltip listing the hero talent + the three
                -- honor talents. SetTooltip is the modern MenuUtil hook; if a
                -- client predates it, the call is no-op and the label icons
                -- still convey the picks at a glance.
                if entry and entry.SetTooltip then
                    entry:SetTooltip(function(tooltip)
                        local bracketName = (ns.GetPvPBracketName and ns.GetPvPBracketName(capturedKey)) or capturedKey
                        tooltip:AddLine("PvP — " .. bracketName, 1, 0.82, 0)
                        if capturedHero then
                            local atlas = ns.HERO_TALENT_ATLAS and ns.HERO_TALENT_ATLAS[capturedHero]
                            local prefix = atlas and ("|A:" .. atlas .. ":14:14|a ") or ""
                            tooltip:AddLine(prefix .. capturedHero, 1, 1, 1)
                        end
                        if capturedHonor and #capturedHonor > 0 then
                            tooltip:AddLine(" ")
                            tooltip:AddLine(L["pvp.honor_talents"] or "Honor Talents", 1, 0.82, 0)
                            for _, talentId in ipairs(capturedHonor) do
                                local info = ns.GetHonorTalentInfo and ns.GetHonorTalentInfo(talentId)
                                local name = (info and info.name) or ("#" .. tostring(talentId))
                                local icon = info and info.icon and ("|T" .. info.icon .. ":14:14:0:0|t ") or ""
                                tooltip:AddLine(icon .. name, 1, 1, 1)
                            end
                            tooltip:AddLine(" ")
                            tooltip:AddLine(
                                L["pvp.honor_talents_apply"]
                                    or "Honor talents apply in War Mode or PvP instances.",
                                0.7, 0.7, 0.7)
                        end
                    end)
                end
            end

            -- Render one bracket entry. Single button when the meta has
            -- a clear winner; collapsing submenu listing top-N variants
            -- when multiple builds clear the share floor (Solo Shuffle
            -- and similar — may be different heroes OR same hero with
            -- different choice-node picks). Honor talents stay at the
            -- bracket level — same set applies regardless of variant.
            local function emitBracket(parent, bracketKey)
                local bracketData = ns.GetPvPBuilds(classToken, specSlug, bracketKey)
                if not bracketData or not bracketData.builds or not bracketData.builds[1] then return end
                local bracketName = (ns.GetPvPBracketName and ns.GetPvPBracketName(bracketKey)) or bracketKey
                local variants = ns.GetPvPBuildVariants and ns.GetPvPBuildVariants(bracketData)
                    or { { hero = bracketData.builds[1].heroTalent, build = bracketData.builds[1] } }

                if #variants <= 1 then
                    -- Stable single-build flow. Hero atlas prefix mirrors
                    -- the u.gg submenu pattern.
                    local label = bracketName
                    local top = variants[1].build
                    if top.heroTalent and ns.HERO_TALENT_ATLAS then
                        local atlas = ns.HERO_TALENT_ATLAS[top.heroTalent]
                        if atlas then label = "|A:" .. atlas .. ":12:12|a " .. label end
                    end
                    emitBuildButton(parent, bracketData, top, bracketKey, label)
                    return
                end

                -- Multi-variant: bracket becomes a submenu, one entry
                -- per qualifying build. Labels are hero icon + hero name;
                -- same-hero duplicates get "(alt)" / "(alt 2)" suffixes
                -- so two visually-identical rows are distinguishable.
                local bracketNode = parent:CreateButton(bracketName)
                for _, v in ipairs(variants) do
                    local label = v.hero or "—"
                    if v.hero and ns.HERO_TALENT_ATLAS then
                        local atlas = ns.HERO_TALENT_ATLAS[v.hero]
                        if atlas then label = "|A:" .. atlas .. ":12:12|a " .. label end
                    end
                    if v.altIndex then
                        local suffix = v.altIndex == 2
                            and (L["loadout.alt"] or "alt")
                            or string.format(L["loadout.alt_n"] or "alt %d", v.altIndex - 1)
                        label = label .. " |cff9a9a9a(" .. suffix .. ")|r"
                    end
                    emitBuildButton(bracketNode, bracketData, v.build, bracketKey, label)
                end
            end

            local function groupHasAny(group)
                for _, k in ipairs(group) do if available[k] then return true end end
                return false
            end
            local arenaHas = groupHasAny(ARENA_GROUP)
            local bgHas = groupHasAny(BG_GROUP)

            if hasBlizzard or hasUgg or hasIcyVeins then root:CreateDivider() end
            root:CreateTitle("|TInterface\\AddOns\\ClassCodex\\Textures\\bnet:14:14:0:0|t  " .. (L["pvp.label"] or "PvP"))

            if not arenaHas and not bgHas then
                -- Defensive fallback: all brackets fall outside the
                -- known groups (e.g. a new bracket key the scraper
                -- adds). Render them flat at the top level instead of
                -- silently swallowing them.
                for _, bracketKey in ipairs(pvpBrackets) do emitBracket(root, bracketKey) end
            else
                if arenaHas then
                    local arenaSub = root:CreateButton(L["pvp.arena"] or "Arena")
                    for _, k in ipairs(ARENA_GROUP) do
                        if available[k] then emitBracket(arenaSub, k) end
                    end
                end
                if bgHas then
                    local bgSub = root:CreateButton(L["pvp.battleground"] or "Battleground")
                    for _, k in ipairs(BG_GROUP) do
                        if available[k] then emitBracket(bgSub, k) end
                    end
                end
            end
            hasPvp = true
        end
    end

    if not hasBlizzard and not hasUgg and not hasIcyVeins and not hasPvp and (not specData or not specData.talents or #specData.talents == 0) then
        root:CreateTitle(L["loadout_dock.no_loadouts"])
    end
end

-- Right-click menu: position lock + open settings. Lock state is
-- account-wide (ClassCodexDB.dockLoadoutLocked) so it stays consistent
-- across alts.
local function BuildOptionsMenu(_, root)
    local L = ns.L or setmetatable({}, { __index = function(_, k) return k end })
    local locked = ClassCodexDB and ClassCodexDB.dockLoadoutLocked
    root:CreateTitle(L["settings.header.loadout_dock"])
    local lockLabel = locked and L["loadout_dock.unlock_position"] or L["loadout_dock.lock_position"]
    root:CreateButton(lockLabel, function()
        if not ClassCodexDB then return end
        ClassCodexDB.dockLoadoutLocked = not ClassCodexDB.dockLoadoutLocked
    end)
    root:CreateButton(L["compendium.open_settings"], function()
        if ns.OpenSettings then ns.OpenSettings() end
    end)
end

local function CreateDock()
    local f = CreateFrame("Button", "ClassCodexLoadoutDock", UIParent, "BackdropTemplate")
    local savedWidth = (ClassCodexDB and ClassCodexDB.dockLoadoutWidth) or DOCK_DEFAULT_WIDTH
    f:SetSize(math.max(DOCK_MIN_WIDTH, math.min(DOCK_MAX_WIDTH, savedWidth)), DOCK_HEIGHT)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f:RegisterForDrag("LeftButton")

    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    f:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    f:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.7)

    local hl = f:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.06)

    -- Spec icon (active spec's iconTexture from GetSpecializationInfo).
    local specIcon = f:CreateTexture(nil, "ARTWORK")
    specIcon:SetSize(ICON_SIZE, ICON_SIZE)
    specIcon:SetPoint("LEFT", 6, 0)
    f.specIcon = specIcon

    -- Hero talent icon (atlas from ns.HERO_TALENT_ATLAS keyed by hero name).
    local heroIcon = f:CreateTexture(nil, "ARTWORK")
    heroIcon:SetSize(ICON_SIZE, ICON_SIZE)
    heroIcon:SetPoint("LEFT", specIcon, "RIGHT", 4, 0)
    f.heroIcon = heroIcon

    local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    label:SetJustifyH("LEFT")
    label:SetWordWrap(false)
    -- Anchor set in RefreshLabel based on which icons are visible.
    f.label = label

    f:SetScript("OnDragStart", function(self)
        if ClassCodexDB and ClassCodexDB.dockLoadoutLocked then return end
        self:StartMoving()
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if not ClassCodexDB then return end
        local point, _, relativePoint, x, y = self:GetPoint()
        ClassCodexDB.dockLoadoutPosition = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
    end)

    f:SetScript("OnClick", function(self, button)
        if button == "RightButton" then
            MenuUtil.CreateContextMenu(self, BuildOptionsMenu)
        else
            MenuUtil.CreateContextMenu(self, BuildLoadoutMenu)
        end
    end)

    f:SetScript("OnEnter", function(self)
        local L = ns.L or setmetatable({}, { __index = function(_, k) return k end })
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")

        -- Full loadout name as the title — the dock label itself can
        -- truncate on long names with SetWordWrap(false).
        local fullName = GetActiveLoadoutName()
        if fullName and fullName ~= "" then
            GameTooltip:AddLine(fullName, 1, 0.82, 0)
        else
            GameTooltip:AddLine(L["Class Codex"], 1, 0.82, 0)
        end

        -- On a NON-Class-Codex loadout, surface which Codex recommendation the
        -- player's talents match (if any), so they see "your custom loadout is
        -- the recommended Mythic+ build". Skipped for a Class Codex loadout —
        -- its name already states the build, and several recommendations can
        -- share the same talents, so a second line would just pick an arbitrary
        -- (often contradictory) context.
        local isCCLoadout = fullName and ns.IsCCSlotName and ns.IsCCSlotName(fullName)
        if not isCCLoadout then
        local specData = ns.GetSpecData and ns.GetSpecData()
        local codexMatch = MatchCodexBuild(specData)
        if codexMatch and ns.FormatBuildLabel then
            GameTooltip:AddLine("|TInterface\\AddOns\\ClassCodex\\Textures\\ugg:12:12:0:0|t  " ..
                ns.FormatBuildLabel(codexMatch), 0.6, 0.85, 0.6)
        else
            local classToken, specSlug
            if ns.GetClassAndSpec then classToken, specSlug = ns.GetClassAndSpec() end
            local uggBuild, uggCtx = MatchUggBuild(classToken, specSlug)
            if uggBuild and uggCtx then
                local uggLabel = (ns.GetUggEncounterLabel and ns.GetUggEncounterLabel(uggCtx)) or "u.gg"
                GameTooltip:AddLine("|TInterface\\AddOns\\ClassCodex\\Textures\\ugg:12:12:0:0|t  " ..
                    uggLabel, 0.6, 0.85, 0.6)
            end
        end
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["loadout_dock.click_to_switch"], 1, 1, 1)
        GameTooltip:AddLine(L["loadout_dock.right_click_options"], 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Initial position: account-wide saved value or sensible default
    -- (top-centre, just below the default minimap area).
    local saved = ClassCodexDB and ClassCodexDB.dockLoadoutPosition
    f:ClearAllPoints()
    if saved and saved.point and saved.x and saved.y then
        f:SetPoint(saved.point, UIParent, saved.relativePoint or saved.point, saved.x, saved.y)
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 220)
    end

    return f
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

-- Apply the user's background opacity setting (defaults to 0.95 if unset).
function ns.ApplyLoadoutDockOpacity()
    if not dock then return end
    local pct = (ClassCodexDB and ClassCodexDB.dockLoadoutOpacity) or 95
    local alpha = math.max(0, math.min(100, pct)) / 100
    dock:SetBackdropColor(0.08, 0.08, 0.08, alpha)
end

-- Toggle the dock border on/off based on settings. dockLoadoutShowBorder
-- nil/true → visible at 0.7 alpha; false → fully transparent border.
function ns.ApplyLoadoutDockBorder()
    if not dock then return end
    if ClassCodexDB and ClassCodexDB.dockLoadoutShowBorder == false then
        dock:SetBackdropBorderColor(0, 0, 0, 0)
    else
        dock:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.7)
    end
end

-- Compute the natural width the content needs (icons + gaps + label
-- rendered text + padding). Used by auto-fit width and by the alignment
-- offset calculation.
local function computeContentWidth()
    if not dock then return 0 end
    local hasSpec = dock.specIcon:IsShown()
    local hasHero = dock.heroIcon:IsShown()
    local iconCount = (hasSpec and 1 or 0) + (hasHero and 1 or 0)
    local iconsW = iconCount * ICON_SIZE + math.max(0, iconCount - 1) * ICON_GAP
    local labelW = dock.label:GetStringWidth() or 0
    return iconsW + (iconCount > 0 and labelW > 0 and LABEL_GAP or 0) + labelW
end

function ns.ApplyLoadoutDockWidth()
    if not dock then return end
    if ClassCodexDB and ClassCodexDB.dockLoadoutAutoWidth then
        local content = computeContentWidth()
        local w = math.max(DOCK_MIN_WIDTH, math.min(DOCK_MAX_WIDTH, math.ceil(content + PAD * 2)))
        dock:SetWidth(w)
    else
        local w = (ClassCodexDB and ClassCodexDB.dockLoadoutWidth) or DOCK_DEFAULT_WIDTH
        dock:SetWidth(math.max(DOCK_MIN_WIDTH, math.min(DOCK_MAX_WIDTH, w)))
    end
end

-- Native frame scale: grows or shrinks the widget proportionally so
-- font, icons, height, and padding all stay in their designed ratio.
-- The setting stores a percentage (50-200), divide by 100 for SetScale.
function ns.ApplyLoadoutDockScale()
    if not dock then return end
    local pct = (ClassCodexDB and ClassCodexDB.dockLoadoutScale) or 100
    local scale = math.max(0.5, math.min(2.0, pct / 100))
    dock:SetScale(scale)
    -- The label's measured width can shift after a SetScale because
    -- the font's render reflows; without a re-measure, the previously
    -- computed auto-fit width may now be too narrow and the label
    -- truncates to "...". Mirror RefreshLabel's immediate+deferred
    -- pattern so the deferred pass picks up the post-scale width.
    if dock:IsShown() then
        ns.ApplyLoadoutDockWidth()
        LayoutDockContent()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if dock and dock:IsShown() then
                    ns.ApplyLoadoutDockWidth()
                    LayoutDockContent()
                end
            end)
        end
    end
end

function ns.ShowLoadoutDock()
    if not dock then dock = CreateDock() end
    dock:Show()
    ns.ApplyLoadoutDockOpacity()
    ns.ApplyLoadoutDockBorder()
    ns.ApplyLoadoutDockWidth()
    ns.ApplyLoadoutDockScale()
    RefreshLabel()
    -- The talent API is occasionally not populated immediately after
    -- PLAYER_LOGIN — an extra refresh half a second later catches the
    -- common "loadout name shows blank on first display" case.
    if C_Timer and C_Timer.After then
        C_Timer.After(0.5, function()
            if dock and dock:IsShown() then RefreshLabel() end
        end)
    end
end

function ns.HideLoadoutDock()
    if dock then dock:Hide() end
end

function ns.RefreshLoadoutDock()
    if dock and dock:IsShown() then RefreshLabel() end
end

-- Apply visibility based on settings + combat state. Called from settings
-- callbacks and combat events.
function ns.UpdateLoadoutDockVisibility()
    local db = ClassCodexDB
    if not db then return end
    if not db.dockLoadoutEnabled then
        ns.HideLoadoutDock()
        return
    end
    if db.dockLoadoutHideInCombat and InCombatLockdown() then
        ns.HideLoadoutDock()
        return
    end
    ns.ShowLoadoutDock()
end

-------------------------------------------------------------------------------
-- LoadConfig hook
--
-- Every loadout switch — Blizzard's dropdown click, CC's apply, any
-- third-party addon — flows through C_ClassTalents.LoadConfig. Hooking
-- it captures the configID the moment the load is requested, which is
-- the same signal Blizzard's own dropdown updates from. We re-resolve
-- the name on TRAIT_CONFIG_UPDATED (post-CommitConfig and post-rename)
-- so the dock always reflects the latest displayed name.
-------------------------------------------------------------------------------

if C_ClassTalents and C_ClassTalents.LoadConfig then
    hooksecurefunc(C_ClassTalents, "LoadConfig", function(configID, _autoApply)
        if not configID then return end
        local specID = GetCurrentSpecID()
        if specID then
            lastLoadedConfigBySpec[specID] = configID
        end
        if ns.RefreshLoadoutDock then ns.RefreshLoadoutDock() end
    end)
end

-------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        ns.UpdateLoadoutDockVisibility()
        if dock and dock:IsShown() then RefreshLabel() end
    elseif event == "TRAIT_CONFIG_UPDATED" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        -- Promote a pending apply (set when the user clicked a build
        -- in the dock menu) to a confirmed one, capturing the player's
        -- bits as they actually settled — that snapshot is what the
        -- next menu render uses to validate the memo.
        local perSpec = ns.GetPerSpecState and ns.GetPerSpecState()
        if perSpec and perSpec.pendingApplyBuildExport then
            local bits = ns.GetActiveTalentSignature and ns.GetActiveTalentSignature()
            if bits then
                perSpec.lastAppliedBuildExport = perSpec.pendingApplyBuildExport
                perSpec.lastAppliedBuildBits = bits
                perSpec.pendingApplyBuildExport = nil
            end
        end
        ns.RefreshLoadoutDock()
    elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
        ns.UpdateLoadoutDockVisibility()
    end
end)
