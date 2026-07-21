local addonName, ns = ...

-------------------------------------------------------------------------------
-- ImportExport: Parse and apply Blizzard talent export strings
--
-- V2 parser + C_Traits staging + CommitConfig to a dedicated loadout slot.
-- Directly based on TalentLoadoutManager's proven approach.
-------------------------------------------------------------------------------

if not ExportUtil or not C_Traits or not C_ClassTalents then
    function ns.ApplyTalentExportString()
        return nil, "Required talent APIs not available"
    end
    return
end

-------------------------------------------------------------------------------
-- Constants (match Blizzard's V2 serialization format)
-------------------------------------------------------------------------------

local BIT_WIDTH_HEADER_VERSION = 8
local BIT_WIDTH_SPEC_ID = 16
local BIT_WIDTH_RANKS_PURCHASED = 6

-------------------------------------------------------------------------------
-- Utilities
-------------------------------------------------------------------------------

local function Msg(text)
    print("|cff00ccffClass Codex:|r " .. text)
end

local function GetSpecID()
    local specIndex = GetSpecialization()
    if not specIndex then return nil end
    return (GetSpecializationInfo(specIndex))
end

local function GetTreeID()
    local configInfo = C_Traits.GetConfigInfo(C_ClassTalents.GetActiveConfigID())
    return configInfo and configInfo.treeIDs and configInfo.treeIDs[1]
end

-------------------------------------------------------------------------------
-- V2 Parser (copied from TalentLoadoutManager/ImportExportV2.lua)
-------------------------------------------------------------------------------

local function ReadLoadoutHeader(importStream)
    local headerBitWidth = BIT_WIDTH_HEADER_VERSION + BIT_WIDTH_SPEC_ID + 128
    if importStream:GetNumberOfBits() < headerBitWidth then
        return false, 0, 0
    end
    local serializationVersion = importStream:ExtractValue(BIT_WIDTH_HEADER_VERSION)
    local specID = importStream:ExtractValue(BIT_WIDTH_SPEC_ID)
    -- treeHash: 128 bits, 16 x 8-bit values
    local treeHash = {}
    for i = 1, 16 do
        treeHash[i] = importStream:ExtractValue(8)
    end
    return true, serializationVersion, specID, treeHash
end

local function ReadLoadoutContent(importStream, treeID)
    local results = {}
    local treeNodes = C_Traits.GetTreeNodes(treeID)
    for i, nodeID in ipairs(treeNodes) do
        local isNodeSelected = importStream:ExtractValue(1) == 1
        local isNodePurchased = false
        local isPartiallyRanked = false
        local partialRanksPurchased = 0
        local isChoiceNode = false
        local choiceNodeSelection = 0

        if isNodeSelected then
            isNodePurchased = importStream:ExtractValue(1) == 1
            if isNodePurchased then
                isPartiallyRanked = importStream:ExtractValue(1) == 1
                if isPartiallyRanked then
                    partialRanksPurchased = importStream:ExtractValue(BIT_WIDTH_RANKS_PURCHASED)
                end
                isChoiceNode = importStream:ExtractValue(1) == 1
                if isChoiceNode then
                    choiceNodeSelection = importStream:ExtractValue(2)
                end
            end
        end

        results[i] = {
            nodeID = nodeID,
            isNodeSelected = isNodeSelected,
            isNodeGranted = isNodeSelected and not isNodePurchased,
            isNodePurchased = isNodePurchased,
            isPartiallyRanked = isPartiallyRanked,
            partialRanksPurchased = partialRanksPurchased,
            isChoiceNode = isChoiceNode,
            choiceNodeSelection = choiceNodeSelection + 1, -- zero-indexed → lua
        }
    end
    return results
end

local function ConvertToEntryInfo(configID, treeID, loadoutContent)
    local results = {}
    local treeNodes = C_Traits.GetTreeNodes(treeID)
    for i, treeNodeID in ipairs(treeNodes) do
        local indexInfo = loadoutContent[i]
        if indexInfo and indexInfo.isNodePurchased then
            local nodeInfo = C_Traits.GetNodeInfo(configID, treeNodeID)
            if nodeInfo and nodeInfo.ID ~= 0 then
                local isChoice = nodeInfo.type == Enum.TraitNodeType.Selection
                              or nodeInfo.type == Enum.TraitNodeType.SubTreeSelection
                local choiceIdx = indexInfo.isChoiceNode and indexInfo.choiceNodeSelection or nil
                if isChoice ~= indexInfo.isChoiceNode then
                    choiceIdx = 1 -- corrupt string fallback
                end
                local selectionEntryID
                if isChoice and choiceIdx and nodeInfo.entryIDs then
                    selectionEntryID = nodeInfo.entryIDs[choiceIdx]
                elseif nodeInfo.activeEntry then
                    selectionEntryID = nodeInfo.activeEntry.entryID
                end

                local ranks = nodeInfo.maxRanks or 1
                if indexInfo.isPartiallyRanked then
                    ranks = indexInfo.partialRanksPurchased
                end

                results[treeNodeID] = {
                    nodeID = treeNodeID,
                    ranksPurchased = ranks,
                    selectionEntryID = selectionEntryID,
                    isChoiceNode = isChoice,
                }
            end
        end
    end
    return results
end

-- ParseExportString
--
-- `expectedSpecID` and `configID` are optional overrides — when present
-- they replace the player's current spec / configID resolution, which
-- is what the inspect-mode hover-diff path needs. Without them this
-- behaves exactly as before (apply path).
local function ParseExportString(exportString, treeID, expectedSpecID, configID)
    local ok, importStream = pcall(ExportUtil.MakeImportDataStream, exportString)
    if not ok or not importStream then
        return nil, "Failed to decode export string"
    end

    local headerValid, version, specID = ReadLoadoutHeader(importStream)
    if not headerValid then
        return nil, "Invalid export string"
    end
    if version ~= C_Traits.GetLoadoutSerializationVersion() then
        return nil, "Serialization version mismatch"
    end

    local checkAgainst = expectedSpecID or GetSpecID()
    if specID ~= checkAgainst then
        return nil, format("Export is for specID %d, active is %d", specID, checkAgainst)
    end

    local loadoutContent = ReadLoadoutContent(importStream, treeID)
    local effectiveConfigID = configID or C_ClassTalents.GetActiveConfigID()
    local entryInfo = ConvertToEntryInfo(effectiveConfigID, treeID, loadoutContent)

    return entryInfo
end

-------------------------------------------------------------------------------
-- ns.ParseLoadoutNodes(exportString) -> { [nodeID] = { ranksPurchased,
--   selectionEntryID, isChoiceNode } } or nil, err
--
-- Parse-only path (no staging, no commit). Used by the talent-pane frame's
-- hover-diff to decode a build's export string against the player's active
-- tree without applying anything.
-------------------------------------------------------------------------------
function ns.ParseLoadoutNodes(exportString)
    if not exportString or exportString == "" then
        return nil, "Empty export string"
    end
    local treeID, configID, expectedSpecID
    -- Inspect mode: resolve tree, configID and expected spec from the
    -- talent frame's current state, not the local player. The export
    -- string's specID won't match the local player's when classes
    -- differ, and the tree/configID need to be the inspected target's
    -- for ConvertToEntryInfo to look up node info correctly.
    if ns._talentPaneInspect then
        local tf = PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame
        if tf and tf.GetConfigID then
            local ok, id = pcall(tf.GetConfigID, tf)
            if ok then configID = id end
        end
        if not configID then
            configID = (Constants and Constants.TraitConsts and Constants.TraitConsts.INSPECT_TRAIT_CONFIG_ID) or -1
        end
        local info = C_Traits.GetConfigInfo(configID)
        treeID = info and info.treeIDs and info.treeIDs[1]
        expectedSpecID = ns._talentPaneInspect.specID
    else
        treeID = GetTreeID()
    end
    if not treeID then return nil, "Cannot determine talent tree" end
    return ParseExportString(exportString, treeID, expectedSpecID, configID)
end

-------------------------------------------------------------------------------
-- Purchase entries (multi-pass, deferred across frames — based on TLM
-- PurchaseOrderedEntries but batched so the UI doesn't freeze for ~1s
-- on a full reset+purchase. Processes BATCH_SIZE nodes per frame; multi-
-- pass semantics preserved (re-runs until no progress is made). Calls
-- onComplete when finished.
--
-- An applyToken guards against overlapping calls: each invocation gets
-- a unique token and aborts early if a newer call has been started.
-------------------------------------------------------------------------------

local BATCH_SIZE = 100 -- effectively process the whole tree in one batch; the suppression flag keeps the freeze short, async only kicks in for trees larger than this
local applyToken = 0

local function ResetAndPurchaseDeferred(configID, treeID, entryInfo, onComplete)
    applyToken = applyToken + 1
    local myToken = applyToken

    C_Traits.ResetTree(configID, treeID)

    local orderedNodes = C_Traits.GetTreeNodes(treeID)
    table.sort(orderedNodes, function(a, b)
        local aI = C_Traits.GetNodeInfo(configID, a)
        local bI = C_Traits.GetNodeInfo(configID, b)
        if aI.posY ~= bI.posY then return aI.posY < bI.posY end
        return aI.posX < bI.posX
    end)

    local i = 1
    local passProgress = 0
    -- Consecutive no-progress passes. Talent gate/currency updates from a
    -- pass's purchases can lag a frame or two, so a pass can momentarily make
    -- no progress while nodes are still about to unlock. Retry a bounded
    -- number of no-progress passes (each a frame apart) before giving up, so
    -- valid max-level builds don't drop nodes that were about to become
    -- purchasable — this is why staging into a fresh loadout used to land only
    -- 64/72. Genuinely unaffordable (levelling) nodes still terminate quickly.
    local zeroPasses = 0
    local MAX_ZERO_PASSES = 8

    local function step()
        if myToken ~= applyToken then return end -- superseded by a newer apply
        local processed = 0
        while i <= #orderedNodes and processed < BATCH_SIZE do
            local nodeID = orderedNodes[i]
            local entry = entryInfo[nodeID]
            if entry then
                -- madeProgress: this node bought/selected at least one thing
                -- this pass (keeps the multi-pass loop alive). complete: the
                -- node has now reached its target and can be retired.
                --
                -- These are deliberately SEPARATE. A gated multi-rank node
                -- (e.g. a hero-tree apex/capstone) often can't buy all its
                -- ranks in one pass — its gate isn't satisfied until a later
                -- node or the hero SubTreeSelection is purchased on a
                -- subsequent pass. Tying progress to only the LAST
                -- PurchaseRank result (as before) hid that partial progress,
                -- so a pass whose only work was a partial multi-rank buy
                -- reported zero progress and the loop terminated early —
                -- leaving the apex cluster unpurchased and firing a bogus
                -- "can't fit the rest" warning even at max level. Retire the
                -- node only once it's fully ranked so the remainder is
                -- retried next pass.
                local madeProgress = false
                local complete = false
                if entry.isChoiceNode then
                    if C_Traits.SetSelection(configID, entry.nodeID, entry.selectionEntryID) then
                        madeProgress = true
                        complete = true
                    end
                elseif entry.ranksPurchased then
                    local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
                    local have = nodeInfo and nodeInfo.ranksPurchased or 0
                    for _ = have + 1, entry.ranksPurchased do
                        if C_Traits.PurchaseRank(configID, entry.nodeID) then
                            madeProgress = true
                        else
                            break -- out of currency / gate not met; retry next pass
                        end
                    end
                    local afterInfo = C_Traits.GetNodeInfo(configID, nodeID)
                    complete = (afterInfo and afterInfo.ranksPurchased or have) >= entry.ranksPurchased
                end
                if madeProgress then passProgress = passProgress + 1 end
                if complete then entryInfo[nodeID] = nil end
            end
            i = i + 1
            processed = processed + 1
        end

        if i <= #orderedNodes then
            -- More nodes in this pass; continue next frame.
            C_Timer.After(0, step)
        elseif passProgress > 0 then
            -- Pass made progress; start another pass.
            i = 1
            passProgress = 0
            zeroPasses = 0
            C_Timer.After(0, step)
        elseif next(entryInfo) ~= nil and zeroPasses < MAX_ZERO_PASSES then
            -- No progress but nodes remain: give lagging gate/currency updates
            -- a few more frames to settle before concluding they can't fit.
            zeroPasses = zeroPasses + 1
            i = 1
            passProgress = 0
            C_Timer.After(0, step)
        else
            -- Done (all staged, or the remainder genuinely can't be afforded).
            if onComplete then onComplete() end
        end
    end

    step()
end

-------------------------------------------------------------------------------
-- Dedicated "Class Codex" loadout slot (configID stored in CharDB per spec)
-------------------------------------------------------------------------------

local CC_NAME = "Class Codex"
local pendingApply = nil
local pendingApplySeq = 0

-- pendingApply stays set across the ENTIRE async lifecycle so the spam-
-- click guard at the top of ApplyTalentExportString blocks any user
-- re-entry between phases. Intermediate event handlers don't nil it —
-- only the terminal success/failure points do, via ClearPendingApply.
--
-- Legitimate continuations (handlers calling ApplyTalentExportString
-- via RunNextFrame) bypass the guard with _isContinuation=true.
--
-- The watchdog is a defence against Blizzard silently dropping an
-- expected TRAIT_CONFIG_* event: if the flag stays set past the
-- window, the watchdog auto-clears it so the player can apply again
-- without /reload. Sequence counter invalidates stale timers when
-- pendingApply is replaced or cleared mid-flight.
local PENDING_APPLY_WATCHDOG_SECS = 10
local function SetPendingApply(pa)
    pendingApplySeq = pendingApplySeq + 1
    local mySeq = pendingApplySeq
    pendingApply = pa
    C_Timer.After(PENDING_APPLY_WATCHDOG_SECS, function()
        if pendingApplySeq ~= mySeq then return end
        -- An expected TRAIT_CONFIG_* event never arrived. Tear the apply
        -- down cleanly: drop the guard and clear the in-progress flag so the
        -- talent UI unfreezes and the player can try again without /reload.
        -- (A stale TRAIT_CONFIG_CREATED registration is harmless — its
        -- handler bails on the now-nil pendingApply.)
        pendingApply = nil
        ns._talentApplyInProgress = false
        if ns._refreshTalentDiff then ns._refreshTalentDiff() end
    end)
end

local function ClearPendingApply()
    pendingApplySeq = pendingApplySeq + 1 -- invalidate any in-flight watchdog
    pendingApply = nil
end

local function ClearStoredConfigID(specID)
    if not ClassCodexCharDB or not ClassCodexCharDB.ccLoadout then return end
    if specID then ClassCodexCharDB.ccLoadout[specID] = nil end
end

-- A slot belongs to CC if its name is either the bare CC_NAME (freshly
-- created, never applied) or starts with "CC_NAME: " (renamed by us
-- after a successful apply at lines 387/497/581). Anything else means
-- the user renamed our slot — we must NOT keep treating it as ours, or
-- the next Apply would overwrite their loadout.
local function IsCCSlotName(name)
    if type(name) ~= "string" then return false end
    if name == CC_NAME then return true end
    return name:sub(1, #CC_NAME + 2) == CC_NAME .. ": "
end
-- Exposed for the native loadout-dropdown tint (TalentPaneDropdown.lua):
-- it scans the live config names to find our slot without re-deriving the
-- naming convention.
ns.IsCCSlotName = IsCCSlotName

-- Brand colour for the Class Codex loadout wherever it shows in a loadout
-- list (native talent dropdown + the loadout dock). Class Codex brand blue
-- (the same cyan as the "Class Codex:" chat prefix), so our slot stands out
-- from the player's white loadouts at a glance.
ns.CC_LOADOUT_COLOR = CreateColor(0, 0.8, 1)
function ns.WrapCCName(name)
    return ns.CC_LOADOUT_COLOR:WrapTextInColorCode(name)
end

local function GetStoredConfigID()
    local specID = GetSpecID()
    if not specID or not ClassCodexCharDB then return nil end
    local stored = ClassCodexCharDB.ccLoadout and ClassCodexCharDB.ccLoadout[specID]
    if not stored then return nil end

    -- Validate against the live loadout list — GetConfigInfo can still return
    -- a stale table for a deleted configID, which would later make
    -- LoadConfig fail with Enum.LoadConfigResult.Error.
    local liveIDs
    if C_ClassTalents.GetConfigIDsBySpecID then
        liveIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)
    end
    if liveIDs then
        local found = false
        for _, id in ipairs(liveIDs) do
            if id == stored then found = true; break end
        end
        if not found then
            ClearStoredConfigID(specID)
            return nil
        end
    end

    -- Slot name guard: if the user renamed our slot, treat it as no
    -- longer ours so the next Apply creates a fresh CC slot instead of
    -- writing into the player's renamed loadout.
    local ok, info = pcall(C_Traits.GetConfigInfo, stored)
    if not ok or not info then
        ClearStoredConfigID(specID)
        return nil
    end
    if not IsCCSlotName(info.name) then
        ClearStoredConfigID(specID)
        return nil
    end
    return stored
end

local function StoreConfigID(configID)
    local specID = GetSpecID()
    if not specID or not ClassCodexCharDB then return end
    if not ClassCodexCharDB.ccLoadout then ClassCodexCharDB.ccLoadout = {} end
    ClassCodexCharDB.ccLoadout[specID] = configID
end

-- Look for an existing CC-named slot on the current spec without
-- relying on ClassCodexCharDB. Lets us adopt an orphan slot left over
-- from a previous character DB wipe or a manual SavedVariables edit
-- instead of creating a second "Class Codex" slot alongside it. Returns
-- the first matching configID we find, or nil.
local function FindExistingCCSlot()
    local specID = GetSpecID()
    if not specID or not C_ClassTalents.GetConfigIDsBySpecID then return nil end
    local liveIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)
    if not liveIDs then return nil end
    for _, id in ipairs(liveIDs) do
        local ok, info = pcall(C_Traits.GetConfigInfo, id)
        if ok and info and IsCCSlotName(info.name) then
            return id
        end
    end
    return nil
end

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "TRAIT_CONFIG_CREATED" then
        if type(arg1) ~= "table" then return end
        if not pendingApply then return end
        if arg1.type ~= Enum.TraitConfigType.Combat then return end
        -- Only adopt the Class Codex slot we asked for by name.
        if arg1.name ~= CC_NAME then return end
        self:UnregisterEvent("TRAIT_CONFIG_CREATED")
        StoreConfigID(arg1.ID)
        -- pendingApply intentionally kept set — the spam-click guard needs it
        -- across the window between this handler and the next-frame re-entry.
        local pa = pendingApply
        RunNextFrame(function()
            ns.ApplyTalentExportString(pa.exportString, pa.buildLabel, true)
        end)
    elseif event == "TRAIT_CONFIG_UPDATED" then
        if arg1 ~= C_ClassTalents.GetActiveConfigID() then return end
        if not pendingApply then return end
        self:UnregisterEvent("TRAIT_CONFIG_UPDATED")
        local pa = pendingApply
        if pa.renameOnly then
            -- Terminal success: commit cast finished, rename to reflect the
            -- picked recommendation, notify.
            if pa.target and pa.finalName and C_ClassTalents.RenameConfig then
                C_ClassTalents.RenameConfig(pa.target, pa.finalName)
            end
            if ns.RefreshLoadoutDock then ns.RefreshLoadoutDock() end
            Msg("Talents applied: " .. (pa.buildLabel or "build"))
            ClearPendingApply()
            -- Defer the flag clear by one frame so any TRAIT_*_UPDATED events
            -- still pending in this dispatch cycle remain suppressed, then
            -- refresh the talent dropdown/glow against the new active state.
            RunNextFrame(function()
                ns._talentApplyInProgress = false
                if ns._refreshTalentDiff then ns._refreshTalentDiff() end
            end)
        else
            -- LoadConfig cast finished — re-enter to stage + commit.
            RunNextFrame(function()
                ns.ApplyTalentExportString(pa.exportString, pa.buildLabel, true)
            end)
        end
    end
end)

-------------------------------------------------------------------------------
-- Shared staging+commit helper used by both the CC-slot apply path and
-- the user-named save-as-new path. Caller has already ensured
-- `targetConfigID` is loaded as the active scratch (LoadConfig done) —
-- this function only stages purchases, commits, and arms the
-- post-commit rename if `finalName` is set.
--
-- `finalName` controls the rename after CommitConfig's cast finishes:
--   - Apply path passes "Class Codex: <buildLabel>" so the loadout
--     label reflects the picked recommendation.
--   - Save-as-new passes nil so the user's chosen name stays intact.
-------------------------------------------------------------------------------

local function StageAndCommit(targetConfigID, activeConfigID, entryInfo, treeID, buildLabel, finalName)
    -- Snapshot for the partial-apply path (B): ResetAndPurchaseDeferred
    -- nils out entries from entryInfo as it successfully purchases
    -- them, so the leftover count after staging tells us how many
    -- nodes we couldn't afford at the player's current level.
    local originalNodeCount = 0
    for _ in pairs(entryInfo) do originalNodeCount = originalNodeCount + 1 end

    -- Reset + purchase: deferred across frames so the UI doesn't
    -- freeze on a ~50-node tree. Commit happens in the onComplete
    -- callback once all nodes are staged.
    --
    -- Set a global flag covering the WHOLE apply: deferred purchase
    -- loop AND the commit cast that follows. Observers (e.g. our own
    -- talent dropdown's TRAIT_TREE_CURRENCY_INFO_UPDATED handler) skip
    -- their per-event re-renders while the flag is set, so the diff
    -- glow doesn't flicker as the staged state shifts node-by-node
    -- and during the commit cast the player is watching.
    --
    -- Cleared on failure inside the onComplete callback; on success
    -- the flag stays true until the commit cast completes
    -- (TRAIT_CONFIG_UPDATED in renameOnly branch).
    ns._talentApplyInProgress = true
    ResetAndPurchaseDeferred(activeConfigID, treeID, entryInfo, function()
        if not C_Traits.ConfigHasStagedChanges(activeConfigID) then
            ns._talentApplyInProgress = false
            -- No staged changes means the loadout already has these
            -- exact talents. If we own the slot (CC apply path), rename
            -- to reflect what the user picked; otherwise just say so.
            if finalName and C_ClassTalents.RenameConfig and targetConfigID then
                C_ClassTalents.RenameConfig(targetConfigID, finalName)
                if ns.RefreshLoadoutDock then ns.RefreshLoadoutDock() end
                Msg("Renamed loadout to " .. (buildLabel or "Build"))
            else
                Msg("Already using this build.")
            end
            ClearPendingApply()
            return
        end

        -- (B) Partial-apply warning. The staging loop is already
        -- robust to "ran out of currency" — failed PurchaseRank calls
        -- leave the node in entryInfo and a pass that makes zero
        -- progress terminates the loop. So if any nodes remain in
        -- entryInfo, it's because the player's current level couldn't
        -- afford or unlock them (typical levelling-vs-max-level-build
        -- case). Surface that as a single info line before committing
        -- so the user knows why their loadout looks shorter than the
        -- build description.
        local remainingNodes = 0
        for _ in pairs(entryInfo) do remainingNodes = remainingNodes + 1 end
        if remainingNodes > 0 then
            local applied = originalNodeCount - remainingNodes
            Msg(string.format(
                "Applying %d of %d nodes — your current level can't fit the rest. Level up and re-apply to fill in the remaining %d.",
                applied, originalNodeCount, remainingNodes))
        end

        if not C_ClassTalents.CommitConfig(targetConfigID) then
            ns._talentApplyInProgress = false
            Msg("|cffff0000Commit failed.|r Open talent frame and click Apply Changes.")
            ClearPendingApply()
            return
        end

        -- CommitConfig triggers a cast bar — defer rename to after cast.
        -- The apply-in-progress flag stays true until that fires.
        SetPendingApply({
            buildLabel = buildLabel,
            renameOnly = true,
            target = targetConfigID,
            finalName = finalName,
        })
        eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")

        if C_ClassTalents.UpdateLastSelectedSavedConfigID then
            local specID = GetSpecID()
            if specID then
                C_ClassTalents.UpdateLastSelectedSavedConfigID(specID, targetConfigID)
            end
        end
    end)

    return true
end

-------------------------------------------------------------------------------
-- ns.ApplyTalentExportString(exportString, buildLabel)
-------------------------------------------------------------------------------

-- Terminal-failure helper: every bail-out path runs through here so a
-- continuation that hits a precondition error never leaves
-- pendingApply set (which would otherwise lock the next user click
-- behind the spam-click guard until the watchdog expires).
local function Fail(msg)
    ClearPendingApply()
    return nil, msg
end

-- _isContinuation is true only when the function is re-entered from a
-- TRAIT_CONFIG_* handler's RunNextFrame to continue an in-flight apply.
-- User-initiated calls always omit it (or pass nil/false), which makes
-- the guard fire if a previous apply is still mid-flight.
function ns.ApplyTalentExportString(exportString, buildLabel, _isContinuation)
    if not exportString or exportString == "" then
        return Fail("Empty export string")
    end

    -- Spam-click guard: block any new user-initiated apply while a
    -- previous one is still mid-flight. pendingApply stays set across
    -- the entire async lifecycle (RequestNewConfig → LoadConfig cast
    -- → stage/commit cast → rename) so the guard catches clicks at
    -- every intermediate step, not just within a single phase.
    if pendingApply and not _isContinuation then
        return nil, "Apply already in progress — wait for it to finish."
    end

    local activeConfigID = C_ClassTalents.GetActiveConfigID()
    if not activeConfigID then return Fail("No active talent configuration") end

    -- Combat is the only failure cause we can't recover from — staging
    -- and CommitConfig are both protected from combat lockdown. Check
    -- explicitly so the user gets a clear message instead of a mid-
    -- stage failure that looks like a bug.
    if InCombatLockdown and InCombatLockdown() then
        return Fail("Cannot change talents in combat.")
    end

    -- Unsaved talent changes (player clicked talents in the tree but
    -- didn't apply) cause LoadConfig to error in the create-fresh-slot
    -- path, which leaves the user puzzled when their build doesn't
    -- come through. Surface it before we do anything destructive so
    -- they know to apply or discard their manual edits first. Skip on
    -- continuation calls — staging legitimately stages changes on the
    -- scratch, and re-checking mid-flight would always trip.
    if not _isContinuation and C_Traits.ConfigHasStagedChanges
        and C_Traits.ConfigHasStagedChanges(activeConfigID)
    then
        return Fail("You have unsaved talent changes. Open the talents pane and click Apply Changes (or right-click the loadout name to discard) before applying a Class Codex build.")
    end

    -- We deliberately don't pre-flight C_ClassTalents.CanChangeTalents()
    -- here: it returns false whenever the tree has unspent currency,
    -- which would lock levelling players out of the apply path entirely.
    -- ResetAndPurchaseDeferred starts with ResetTree (refunds the whole
    -- tree) and then stages purchases until the player's currency is
    -- consumed — so unspent vs spent at entry doesn't matter, and the
    -- post-stage partial-apply warning surfaces if the build exceeds
    -- the player's budget. Other CanChangeTalents=false reasons (talent
    -- UI not loaded, PvP-zone restrictions, etc.) fall through to the
    -- existing CommitConfig branch which prints "Commit failed. Open
    -- talent frame and click Apply Changes."

    -- Fast path: if the CC loadout already has these exact talents AND
    -- it's the spec's currently-selected saved loadout, just rename it.
    -- Skips the full stage/commit cycle when two recommendations share
    -- the same build (e.g. "All Dungeons" and "Maisara Caverns") but the
    -- user wants the dock/loadout to read the more specific encounter
    -- name. The persistent ccConfigID is what we want to rename, NOT
    -- the in-memory scratch returned by GetActiveConfigID.
    if ns.ExtractTalentBits and ns.GetActiveTalentSignature
        and C_ClassTalents.RenameConfig and C_ClassTalents.GetLastSelectedSavedConfigID
    then
        local ccConfigID = GetStoredConfigID()
        local specID = GetSpecID()
        local lastSelected = specID and C_ClassTalents.GetLastSelectedSavedConfigID(specID)
        if ccConfigID and lastSelected == ccConfigID then
            local activeBits = ns.GetActiveTalentSignature()
            local newBits = ns.ExtractTalentBits(exportString)
            if activeBits and newBits and activeBits == newBits then
                C_ClassTalents.RenameConfig(ccConfigID, CC_NAME .. ": " .. (buildLabel or "Build"))
                if ns.RefreshLoadoutDock then ns.RefreshLoadoutDock() end
                Msg("Renamed loadout to " .. (buildLabel or "Build"))
                ClearPendingApply()
                return true
            end
        end
    end

    local treeID = GetTreeID()
    if not treeID then return Fail("Cannot determine talent tree") end

    -- Parse
    local entryInfo, parseErr = ParseExportString(exportString, treeID)
    if not entryInfo then return Fail(parseErr) end

    -- Ensure we have a dedicated loadout slot. Adopt an existing
    -- CC-named slot before creating a new one so the user always ends
    -- up with a SINGLE Class Codex loadout per spec, even after a
    -- character-DB wipe or manual SavedVariables edit cleared the
    -- stored mapping.
    local ccConfigID = GetStoredConfigID()
    if not ccConfigID then
        ccConfigID = FindExistingCCSlot()
        if ccConfigID then StoreConfigID(ccConfigID) end
    end
    if not ccConfigID then
        if C_ClassTalents.CanCreateNewConfig and not C_ClassTalents.CanCreateNewConfig() then
            return Fail("No free loadout slots — delete one to use Class Codex builds")
        end
        C_ClassTalents.RequestNewConfig(CC_NAME)
        SetPendingApply({ exportString = exportString, buildLabel = buildLabel })
        eventFrame:RegisterEvent("TRAIT_CONFIG_CREATED")
        Msg("Creating loadout slot...")
        return true
    end

    -- Switch to the CC loadout if not on it (TLM does this before staging) so
    -- the scratch reflects it and gating computes correctly.
    local specID = GetSpecID()
    local currentLoadoutID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
    if currentLoadoutID ~= ccConfigID then
        local result = C_ClassTalents.LoadConfig(ccConfigID, true)
        if result == Enum.LoadConfigResult.LoadInProgress then
            SetPendingApply({ exportString = exportString, buildLabel = buildLabel })
            eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
            return true
        elseif result == Enum.LoadConfigResult.Error then
            -- LoadConfig failed even though GetStoredConfigID validated the ID.
            -- Clear the stored ID so a subsequent click runs the fresh path,
            -- then surface the error. Do NOT recurse.
            ClearStoredConfigID(specID)
            return Fail("Could not load Class Codex loadout. Open the talents pane and click Apply Changes, then try again.")
        end
    end

    -- Re-fetch activeConfigID after LoadConfig may have changed it
    activeConfigID = C_ClassTalents.GetActiveConfigID()

    return StageAndCommit(ccConfigID, activeConfigID, entryInfo, treeID, buildLabel,
        CC_NAME .. ": " .. (buildLabel or "Build"))
end

-------------------------------------------------------------------------------
-- ns.SaveTalentBuildAsNewLoadout(exportString, buildLabel, userName)
--
-- Creates a brand-new loadout named `userName` containing the build, using
-- Blizzard's native C_ClassTalents.ImportLoadout — the exact call the game's
-- own "Import Loadout" dialog uses. It builds the full loadout (hero talents,
-- gated/tiered nodes, granted ranks) in one server call, with none of the
-- manual staging that dropped nodes when writing into a fresh slot. Does not
-- touch ClassCodexCharDB, and the name is kept verbatim.
--
-- Parsing below mirrors Blizzard_ClassTalentImportExport: read the header,
-- read the per-node content bitstream, and convert to the ImportLoadoutEntryInfo
-- array (nodeID, ranksGranted, ranksPurchased, selectionEntryID) the API wants.
-------------------------------------------------------------------------------

local BIT_WIDTH_HEADER_VERSION = 8
local BIT_WIDTH_SPEC_ID = 16
local BIT_WIDTH_RANKS_PURCHASED = 6

local function ReadImportHeader(stream)
    local headerBits = BIT_WIDTH_HEADER_VERSION + BIT_WIDTH_SPEC_ID + 128
    if stream:GetNumberOfBits() < headerBits then return false end
    local version = stream:ExtractValue(BIT_WIDTH_HEADER_VERSION)
    local specID = stream:ExtractValue(BIT_WIDTH_SPEC_ID)
    for _ = 1, 16 do stream:ExtractValue(8) end -- skip the 128-bit tree hash
    return true, version, specID
end

local function ReadImportContent(stream, treeID)
    local results = {}
    local treeNodes = C_Traits.GetTreeNodes(treeID)
    for i = 1, #treeNodes do
        local r = { isNodeSelected = false, isNodeGranted = false,
                    isPartiallyRanked = false, partialRanksPurchased = 0,
                    isChoiceNode = false, choiceNodeSelection = 1 }
        if stream:ExtractValue(1) == 1 then
            r.isNodeSelected = true
            local isPurchased = stream:ExtractValue(1) == 1
            r.isNodeGranted = not isPurchased
            if isPurchased then
                r.isPartiallyRanked = stream:ExtractValue(1) == 1
                if r.isPartiallyRanked then
                    r.partialRanksPurchased = stream:ExtractValue(BIT_WIDTH_RANKS_PURCHASED)
                end
                r.isChoiceNode = stream:ExtractValue(1) == 1
                if r.isChoiceNode then
                    r.choiceNodeSelection = stream:ExtractValue(2) + 1
                end
            end
        end
        results[i] = r
    end
    return results
end

local function ImportEntryFromSingleNode(results, nodeInfo, idx)
    if not nodeInfo or not idx or not idx.isNodeSelected then return end
    local r = { nodeID = nodeInfo.ID, ranksGranted = idx.isNodeGranted and 1 or 0 }
    if idx.isNodeSelected and not idx.isNodeGranted then
        r.ranksPurchased = idx.isPartiallyRanked and idx.partialRanksPurchased or nodeInfo.maxRanks
    else
        r.ranksPurchased = 0
    end
    if idx.isChoiceNode and idx.choiceNodeSelection and nodeInfo.entryIDs then
        r.selectionEntryID = nodeInfo.entryIDs[idx.choiceNodeSelection]
    elseif nodeInfo.activeEntry then
        r.selectionEntryID = nodeInfo.activeEntry.entryID
    end
    if not r.selectionEntryID and nodeInfo.entryIDs then
        r.selectionEntryID = nodeInfo.entryIDs[1]
    end
    if r.selectionEntryID ~= nil then results[#results + 1] = r end
end

local function ImportEntryFromTieredNode(results, configID, nodeInfo, idx)
    if not nodeInfo or not idx or not idx.isNodeSelected then return end
    local total = 0
    if not idx.isNodeGranted then
        total = idx.isPartiallyRanked and idx.partialRanksPurchased or nodeInfo.maxRanks
    end
    local remaining = total
    for index, entryID in ipairs(nodeInfo.entryIDs or {}) do
        local ei = C_Traits.GetEntryInfo(configID, entryID)
        if ei then
            local ranks = math.min(remaining, ei.maxRanks or 0)
            local isGranted = idx.isNodeGranted and index == 1
            if ranks > 0 or isGranted then
                results[#results + 1] = {
                    nodeID = nodeInfo.ID,
                    ranksGranted = isGranted and 1 or 0,
                    ranksPurchased = ranks,
                    selectionEntryID = entryID,
                }
            end
            remaining = remaining - ranks
        end
    end
end

local function ParseImportEntries(exportString, configID, treeID)
    if not ExportUtil or not ExportUtil.MakeImportDataStream then
        return nil, "Import not supported by this client."
    end
    local ok, stream = pcall(ExportUtil.MakeImportDataStream, exportString)
    if not ok or not stream then return nil, "Failed to decode export string" end
    local hok, version = ReadImportHeader(stream)
    if not hok then return nil, "Bad export string" end
    if C_Traits.GetLoadoutSerializationVersion
        and version ~= C_Traits.GetLoadoutSerializationVersion() then
        return nil, "Build string is from a different game version — re-copy it."
    end
    local content = ReadImportContent(stream, treeID)
    local results = {}
    local treeNodes = C_Traits.GetTreeNodes(treeID)
    for index = 1, #treeNodes do
        local nodeInfo = C_Traits.GetNodeInfo(configID, treeNodes[index])
        if nodeInfo then
            if nodeInfo.type == Enum.TraitNodeType.Tiered then
                ImportEntryFromTieredNode(results, configID, nodeInfo, content[index])
            else
                ImportEntryFromSingleNode(results, nodeInfo, content[index])
            end
        end
    end
    return results
end

function ns.SaveTalentBuildAsNewLoadout(exportString, buildLabel, userName)
    if not exportString or exportString == "" then return nil, "Empty export string" end
    if not userName or userName == "" then return nil, "Loadout name is required" end
    -- Reject CC-looking names so the slot can't later be adopted/overwritten
    -- by the apply path's FindExistingCCSlot.
    if IsCCSlotName(userName) then
        return nil, '"' .. CC_NAME .. '" is reserved for Class Codex — pick a different name.'
    end
    if InCombatLockdown and InCombatLockdown() then return nil, "Cannot change talents in combat." end
    if not C_ClassTalents.ImportLoadout then
        return nil, "This game version doesn't support saving loadouts."
    end
    if C_ClassTalents.CanCreateNewConfig and not C_ClassTalents.CanCreateNewConfig() then
        return nil, "No free loadout slots — delete one to save a new build."
    end
    local configID = C_ClassTalents.GetActiveConfigID()
    if not configID then return nil, "No active talent configuration" end

    -- When the talent tree is open, import through the frame's own ImportLoadout
    -- rather than the bare C_ClassTalents API. The frame arms its
    -- "wait until the new config is populated" check and repopulates the tree;
    -- the bare API doesn't, so the frame auto-switches to the not-yet-populated
    -- new config and the tree shows blank ("resets to nothing"). Only takes the
    -- frame path when the tree is actually shown — otherwise there's no open
    -- tree to blank and the direct API is simpler.
    local tf = PlayerSpellsFrame and PlayerSpellsFrame.TalentsFrame
    if tf and tf.ImportLoadout and tf.IsShown and tf:IsShown() then
        local ok, res = pcall(tf.ImportLoadout, tf, exportString, userName)
        if ok and res ~= false then
            if ns.RefreshLoadoutDock then ns.RefreshLoadoutDock() end
            return true
        end
        if ok and res == false then
            -- The frame validated and rejected the string (it shows its own
            -- error); surface a short inline message too.
            return nil, "Couldn't save the loadout — check the build string."
        end
        -- pcall errored (frame not ready) → fall through to the direct API.
    end

    -- Direct fallback (talent tree not open): parse + native import.
    local treeID = GetTreeID()
    if not treeID then return nil, "Cannot determine talent tree" end
    local entries, parseErr = ParseImportEntries(exportString, configID, treeID)
    if not entries then return nil, parseErr end
    local ok, importErr = C_ClassTalents.ImportLoadout(configID, entries, userName, exportString)
    if not ok then return nil, importErr or "Import failed" end
    Msg("Saved loadout '" .. userName .. "'.")
    if ns.RefreshLoadoutDock then ns.RefreshLoadoutDock() end
    return true
end
