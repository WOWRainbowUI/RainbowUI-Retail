local addonName, ns = ...

-------------------------------------------------------------------------------
-- TalentEncode: turn a u.gg talent string into a Blizzard import string.
--
-- u.gg ships each build's talents as "nodeID#entryID#rank-..." (Blizzard trait
-- IDs). This encoder is the exact inverse of the V2 decoder in
-- Shared/ImportExport.lua: it walks C_Traits.GetTreeNodes(treeID) in the same
-- canonical order and writes the same bit layout, so the resulting string flows
-- through the existing ParseExportString / ApplyTalentExportString pipeline
-- unchanged. No offline encoder, no tree-definition files to maintain.
-------------------------------------------------------------------------------

if not ExportUtil or not C_Traits or not C_ClassTalents then
    function ns.EncodeUggTalents() return nil end
    return
end

local BIT_WIDTH_HEADER_VERSION = 8
local BIT_WIDTH_SPEC_ID = 16
local BIT_WIDTH_RANKS_PURCHASED = 6

-- "76039#96167#1-76040#96168#2" -> { [76039] = {entryID=96167, rank=1}, ... }
local function ParseUggNodes(str)
    local map = {}
    for triple in string.gmatch(str, "[^%-]+") do
        local node, entry, rank = string.match(triple, "^(%d+)#(%d+)#(%d+)$")
        if node then
            map[tonumber(node)] = { entryID = tonumber(entry), rank = tonumber(rank) }
        end
    end
    return map
end

-- Resolve tree / spec / config from the active spec when not supplied. The
-- encoder can only build a string for the tree that's currently loaded, which
-- is exactly the spec whose builds the talent pane is showing.
local function Resolve(treeID, specID, configID)
    configID = configID or C_ClassTalents.GetActiveConfigID()
    if not configID then return nil end
    if not treeID then
        local info = C_Traits.GetConfigInfo(configID)
        treeID = info and info.treeIDs and info.treeIDs[1]
    end
    if not specID then
        local idx = GetSpecialization()
        if idx then specID = (GetSpecializationInfo(idx)) end
    end
    if not treeID or not specID then return nil end
    return treeID, specID, configID
end

-- ns.EncodeUggTalents(uggStr[, treeID, specID, configID]) -> importString | nil
function ns.EncodeUggTalents(uggStr, treeID, specID, configID)
    if not uggStr or uggStr == "" then return nil end
    treeID, specID, configID = Resolve(treeID, specID, configID)
    if not treeID then return nil end

    local selected = ParseUggNodes(uggStr)

    local stream = ExportUtil.MakeExportDataStream()
    -- Header: version + specID + 128-bit tree hash. A zeroed hash is accepted
    -- on import (it only drives a soft "out of date" warning, never a reject),
    -- and our own ParseExportString never validates it.
    stream:AddValue(BIT_WIDTH_HEADER_VERSION, C_Traits.GetLoadoutSerializationVersion())
    stream:AddValue(BIT_WIDTH_SPEC_ID, specID)
    for _ = 1, 16 do stream:AddValue(8, 0) end

    -- Content: one entry per tree node, in canonical order.
    local treeNodes = C_Traits.GetTreeNodes(treeID)
    for _, nodeID in ipairs(treeNodes) do
        local sel = selected[nodeID]
        if not sel then
            stream:AddValue(1, 0) -- isNodeSelected = false
        else
            local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
            stream:AddValue(1, 1) -- isNodeSelected
            stream:AddValue(1, 1) -- isNodePurchased

            local maxRanks = (nodeInfo and nodeInfo.maxRanks) or 1
            if sel.rank < maxRanks then
                stream:AddValue(1, 1) -- isPartiallyRanked
                stream:AddValue(BIT_WIDTH_RANKS_PURCHASED, sel.rank)
            else
                stream:AddValue(1, 0)
            end

            local isChoice = nodeInfo and (
                nodeInfo.type == Enum.TraitNodeType.Selection
                or nodeInfo.type == Enum.TraitNodeType.SubTreeSelection)
            if isChoice then
                stream:AddValue(1, 1) -- isChoiceNode
                local idx = 0
                if nodeInfo.entryIDs then
                    for k, e in ipairs(nodeInfo.entryIDs) do
                        if e == sel.entryID then idx = k - 1 break end
                    end
                end
                stream:AddValue(2, idx)
            else
                stream:AddValue(1, 0)
            end
        end
    end

    return stream:GetExportString()
end

-------------------------------------------------------------------------------
-- Dev-only: dump the active spec's tree layout to ClassCodexDB.treeDefs so the
-- offline encoder (packages/scraper) can turn u.gg node lists into Blizzard
-- import strings. Run `/cc dumptree` on each spec, then /reload to flush
-- SavedVariables. Tree layout is static per patch, so this is a rare step.
-------------------------------------------------------------------------------
function ns.DumpTalentTree()
    local configID = C_ClassTalents.GetActiveConfigID()
    if not configID then
        print("|cff00ccffClass Codex:|r no active talent config — open the talents pane first.")
        return
    end
    local info = C_Traits.GetConfigInfo(configID)
    local treeID = info and info.treeIDs and info.treeIDs[1]
    local specIdx = GetSpecialization()
    local specID = specIdx and (GetSpecializationInfo(specIdx))
    if not treeID or not specID then
        print("|cff00ccffClass Codex:|r could not resolve tree/spec.")
        return
    end

    local nodes = {}
    for _, nodeID in ipairs(C_Traits.GetTreeNodes(treeID)) do
        local ni = C_Traits.GetNodeInfo(configID, nodeID)
        local entryIDs = {}
        if ni and ni.entryIDs then
            for i, e in ipairs(ni.entryIDs) do entryIDs[i] = e end
        end
        nodes[#nodes + 1] = {
            id = nodeID,
            maxRanks = ni and ni.maxRanks or 1,
            type = ni and ni.type or 0,
            entryIDs = entryIDs,
        }
    end

    ClassCodexDB = ClassCodexDB or {}
    ClassCodexDB.treeDefs = ClassCodexDB.treeDefs or {}
    ClassCodexDB.treeDefs[tostring(specID)] = {
        specID = specID,
        treeID = treeID,
        version = C_Traits.GetLoadoutSerializationVersion(),
        selectionType = Enum.TraitNodeType.Selection,
        subTreeSelectionType = Enum.TraitNodeType.SubTreeSelection,
        nodes = nodes,
    }
    print(string.format("|cff00ccffClass Codex:|r dumped tree for specID %d (%d nodes). /reload to save, then repeat on other specs.", specID, #nodes))
end
