-- Classifier.lua – Frame classification & blacklist (AceModule)
--
-- Determines which category (actionbar / nameplate / unitframe / cooldownmanager / global)
-- a Cooldown frame belongs to, so the Styler can apply the right config.

local MCE = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local Classifier = MCE:NewModule("Classifier")

local strfind, ipairs, type, pcall = string.find, ipairs, type, pcall
local setmetatable, wipe = setmetatable, wipe
local UIParent = UIParent

local SCAN_DEPTH = 10  -- Ancestry levels scanned for frame classification (covers all known addon UIs)

-- Weak-keyed cache: auto-collected when frames are garbage-collected
local categoryCache = setmetatable({}, { __mode = "k" })
local viewerTypeCache = setmetatable({}, { __mode = "k" })
local miniCCTypeCache = setmetatable({}, { __mode = "k" })

-- Module-level scratch table reused by ClassifyFrame to avoid per-call allocation
local classifyChain = {}

-- =========================================================================
-- BLACKLIST DATA
-- =========================================================================

-- Add your ignore cases here.
local BLACKLIST_NAME_CONTAINS = {
    "Glider", "Party", "Compact",
    "Raid", "VuhDo", "Grid",
    "PVEFrame", "PVPQueueFrame",
    "LossOfControlFrame",
    "ContainerFrameCombinedBagsCooldown",
}

-- Nested lookup: BLACKLIST_EXACT_PAIRS[parentName][frameName]
-- Avoids per-call string concatenation ("ParentName -> FrameName").
local BLACKLIST_EXACT_PAIRS = {
    -- Character Slots
    ["CharacterBackSlot"]           = { ["CharacterBackSlotCooldown"] = true },
    ["CharacterShirtSlot"]          = { ["CharacterShirtSlotCooldown"] = true },
    ["CharacterMainHandSlot"]       = { ["CharacterMainHandSlotCooldown"] = true },
    ["CharacterLegsSlot"]           = { ["CharacterLegsSlotCooldown"] = true },
    ["CharacterFinger0Slot"]        = { ["CharacterFinger0SlotCooldown"] = true },
    ["CharacterHeadSlot"]           = { ["CharacterHeadSlotCooldown"] = true },
    ["CharacterFeetSlot"]           = { ["CharacterFeetSlotCooldown"] = true },
    ["CharacterShoulderSlot"]       = { ["CharacterShoulderSlotCooldown"] = true },
    ["CharacterWristSlot"]          = { ["CharacterWristSlotCooldown"] = true },
    ["CharacterHandsSlot"]          = { ["CharacterHandsSlotCooldown"] = true },
    ["CharacterTabardSlot"]         = { ["CharacterTabardSlotCooldown"] = true },
    ["CharacterSecondaryHandSlot"]  = { ["CharacterSecondaryHandSlotCooldown"] = true },
    ["CharacterFinger1Slot"]        = { ["CharacterFinger1SlotCooldown"] = true },
    ["CharacterWaistSlot"]          = { ["CharacterWaistSlotCooldown"] = true },
    ["CharacterChestSlot"]          = { ["CharacterChestSlotCooldown"] = true },
    ["CharacterNeckSlot"]           = { ["CharacterNeckSlotCooldown"] = true },
    ["CharacterTrinket1Slot"]       = { ["CharacterTrinket1SlotCooldown"] = true },
    ["CharacterTrinket0Slot"]       = { ["CharacterTrinket0SlotCooldown"] = true },
}

-- =========================================================================
-- PATTERN HELPERS
-- =========================================================================

local function ExtractUnitToken(unit)
    if type(unit) == "string" then
        return unit ~= "" and unit or nil
    end

    if type(unit) ~= "table" then
        return nil
    end

    local token = unit.unitid
        or unit.unitID
        or unit.unitToken
        or unit.displayedUnit
        or unit.unit

    if type(token) == "string" and token ~= "" then
        return token
    end

    return nil
end

local function IsNameplateContext(name, objType, unit)
    local unitToken = ExtractUnitToken(unit)
    local lowerName = name and type(name) == "string" and string.lower(name) or ""

    return objType == "NamePlate"
        or strfind(lowerName, "nameplate", 1, true)
        or strfind(lowerName, "plater",    1, true)
        or strfind(lowerName, "kui",       1, true)
        or strfind(lowerName, "elvnp",     1, true)
        or strfind(lowerName, "threatplate", 1, true)
        or (unitToken and type(unitToken) == "string" and strfind(string.lower(unitToken), "nameplate", 1, true))
end

local function IsMiniCCNamedFrame(frame)
    if not frame or not frame.GetName then return false end
    local name = frame:GetName()
    return type(name) == "string" and strfind(name, "MiniCC_", 1, true) == 1
end

local function IsMiniCCFrame(frame)
    if not frame then return false end

    local current = frame
    for _ = 1, 6 do
        if not current then break end
        if IsMiniCCNamedFrame(current) then
            return true
        end
        current = current.GetParent and current:GetParent() or nil
    end

    return false
end

local function GetFrameUnit(frame)
    if not frame then return nil end

    local unit = ExtractUnitToken(frame.unit)
    if unit then
        return unit
    end

    unit = ExtractUnitToken(frame.unitid)
        or ExtractUnitToken(frame.unitID)
        or ExtractUnitToken(frame.unitToken)
        or ExtractUnitToken(frame.displayedUnit)
    if unit then
        return unit
    end

    if frame.GetAttribute then
        local ok, attr = pcall(frame.GetAttribute, frame, "unit")
        unit = ok and ExtractUnitToken(attr) or nil
        if unit then
            return unit
        end
    end

    return nil
end

local function IsUnitFrameContext(frame)
    if not frame then return false end

    local unit = GetFrameUnit(frame)
    if unit and not strfind(unit, "nameplate", 1, true) then
        return true
    end

    local name = frame.GetName and frame:GetName() or ""
    return strfind(name, "PlayerFrame", 1, true)
        or strfind(name, "TargetFrame", 1, true)
        or strfind(name, "FocusFrame",  1, true)
        or strfind(name, "PetFrame",    1, true)
        or strfind(name, "ElvUF",       1, true)
        or strfind(name, "SUF",         1, true)
        or strfind(name, "CompactPartyFrame", 1, true)
        or strfind(name, "CompactRaidFrame", 1, true)
        or strfind(name, "Grid",        1, true)
        or strfind(name, "Plexus",      1, true)
        or strfind(name, "Cell",        1, true)
        or strfind(name, "TPerl",       1, true)
end

local function FindMiniCCRootFrame(frame)
    local current = frame
    local root = nil

    for _ = 1, SCAN_DEPTH + 10 do
        if not current or not IsMiniCCFrame(current) then break end
        root = current
        current = current.GetParent and current:GetParent() or nil
    end

    return root, current
end

local function GetMiniCCPointRelativeFrame(frame)
    if not frame or not frame.GetPoint then return nil end

    local ok, _, relativeTo = pcall(frame.GetPoint, frame, 1)
    if ok then
        return relativeTo
    end

    return nil
end

local function GetMiniCCFrameType(frame)
    if not MCE:IsMiniCCAvailable() or not IsMiniCCFrame(frame) then
        return nil
    end

    local root, parent = FindMiniCCRootFrame(frame)
    if not root then return nil end

    if parent then
        local parentName = parent.GetName and parent:GetName() or ""
        if IsNameplateContext(parentName, parent:GetObjectType(), GetFrameUnit(parent)) then
            return "nameplate"
        end
        if IsUnitFrameContext(parent) then
            return "portrait"
        end
    end

    local relativeTo = GetMiniCCPointRelativeFrame(root)
    if relativeTo then
        local relativeName = relativeTo.GetName and relativeTo:GetName() or ""
        if IsNameplateContext(relativeName, relativeTo:GetObjectType(), GetFrameUnit(relativeTo)) then
            return "nameplate"
        end
        if IsUnitFrameContext(relativeTo) then
            return "cc"
        end
    end

    return "overlay"
end

local function GetCooldownManagerViewerTypeFromChain(chain, chainLen)
    for i = 1, chainLen do
        local frame = chain[i]
        local name = frame.GetName and frame:GetName() or ""

        if strfind(name, "EssentialCooldownViewer", 1, true) then
            return "essential"
        end
        if strfind(name, "UtilityCooldownViewer", 1, true) then
            return "utility"
        end
        if strfind(name, "BuffIconCooldownViewer", 1, true) then
            return "bufficon"
        end
    end

    local owner = chain[1]
    if owner then
        local applications = owner.Applications
        if applications and applications.Applications then
            return "bufficon"
        end

        local chargeCount = owner.ChargeCount
        if chargeCount and chargeCount.Current then
            return "utility_or_essential"
        end
    end

    return nil
end

-- =========================================================================
-- PUBLIC API
-- =========================================================================

function Classifier:IsBlacklisted(frame, knownFrameName)
    if not frame then return false end

    local frameName = knownFrameName or (frame.GetName and frame:GetName()) or "AnonymousFrame"
    local parent    = frame.GetParent and frame:GetParent() or nil
    local parentName = parent and parent.GetName and parent:GetName() or "NoParent"

    local parentBlacklist = BLACKLIST_EXACT_PAIRS[parentName]
    if parentBlacklist and parentBlacklist[frameName] then return true end

    for _, key in ipairs(BLACKLIST_NAME_CONTAINS) do
        if strfind(frameName, key, 1, true) or strfind(parentName, key, 1, true) then
            return true
        end
    end
    return false
end

--- Single-pass frame classifier. Builds the ancestry chain once, then
--- classifies by priority: blacklist > nameplate > unitframe > actionbar > cooldownmanager > global.
function Classifier:ClassifyFrame(cooldownFrame)
    local miniCCType = GetMiniCCFrameType(cooldownFrame)
    if miniCCType then
        miniCCTypeCache[cooldownFrame] = miniCCType
        return "minicc"
    end

    local current = cooldownFrame:GetParent()
    if not current then return "global" end

    local maxDepth = SCAN_DEPTH
    
    -- Phase 1: Build ancestry chain once (reuses module-level scratch table)
    local chain = classifyChain
    local chainLen = 0
    local node = current
    while node and node ~= UIParent and chainLen < SCAN_DEPTH do
        chainLen = chainLen + 1
        chain[chainLen] = node
        node = node:GetParent()
    end
    -- Clear stale entries from previous calls to avoid holding dead references
    for i = chainLen + 1, #chain do chain[i] = nil end
    local reachedUIParent = (node == UIParent)

    -- Phase 2: Fast early-out for aura buttons (buff/debuff on player frame vs nameplate)
    local parentName = current:GetName() or ""
    if strfind(parentName, "BuffButton",  1, true)
    or strfind(parentName, "DebuffButton", 1, true)
    or strfind(parentName, "TempEnchant",  1, true) then
        -- Walk the pre-built chain looking for nameplate ancestors
        for i = 1, chainLen do
            local n = chain[i]
            local name = n:GetName() or ""
            if IsNameplateContext(name, n:GetObjectType(), n.unit) then
                return "nameplate"
            end
        end
        -- Reached UIParent → definitively a player buff/debuff
        if reachedUIParent then return "global" end
        -- Chain still building (hierarchy incomplete) → defer
        return "aura_pending"
    end

    local cooldownManagerViewerType = GetCooldownManagerViewerTypeFromChain(chain, chainLen)

    -- Phase 3: General classification within configured scan depth
    local limit = chainLen < maxDepth and chainLen or maxDepth
    for i = 1, limit do
        local frame = chain[i]
        local name  = frame:GetName() or ""
        local objType = frame:GetObjectType()

        -- Blacklist check (exact pair + name-contains patterns)
        if self:IsBlacklisted(frame, name) then return "blacklist" end

        -- Nameplate detection
        if IsNameplateContext(name, objType, frame.unit) then return "nameplate" end

        -- Unit frame detection
        if strfind(name, "PlayerFrame", 1, true)
        or strfind(name, "TargetFrame", 1, true)
        or strfind(name, "FocusFrame",  1, true)
        or strfind(name, "ElvUF",       1, true)
        or strfind(name, "SUF",         1, true) then
            return "unitframe"
        end

        -- Action bar detection (skip "Aura" false positives)
        if (frame.action and type(frame.action) == "number")
        or (frame.GetAttribute and frame:GetAttribute("type"))
        or strfind(name, "Action",   1, true)
        or strfind(name, "MultiBar", 1, true)
        or strfind(name, "BT4",      1, true)
        or strfind(name, "Dominos",  1, true) then
            if not strfind(name, "Aura", 1, true) then
                return "actionbar"
            end
        end
    end

    if cooldownManagerViewerType then
        viewerTypeCache[cooldownFrame] = cooldownManagerViewerType
        return "cooldownmanager"
    end

    -- Phase 4: Extended nameplate check beyond configured depth
    -- Nameplates can be deeply nested in addon UIs (Plater, KuiNameplates, etc.)
    for i = limit + 1, chainLen do
        local frame = chain[i]
        if IsNameplateContext(frame:GetName() or "", frame:GetObjectType(), frame.unit) then
            return "nameplate"
        end
    end

    -- Intercept detached aura frames (e.g. freshly created nameplate buffs not parented yet)
    if not reachedUIParent and node == nil and chain[chainLen] ~= WorldFrame then
        return "aura_pending"
    end

    return "global"
end

function Classifier:GetCategory(cooldownFrame)
    local cached = categoryCache[cooldownFrame]
    if cached then return cached end

    local category = self:ClassifyFrame(cooldownFrame)

    -- Cache definitive results; "aura_pending" is retried in ApplyStyle
    if category ~= "aura_pending" then
        categoryCache[cooldownFrame] = category
    end
    return category
end

function Classifier:GetCooldownManagerViewerType(cooldownFrame)
    local cached = viewerTypeCache[cooldownFrame]
    if cached then return cached end

    local current = cooldownFrame and cooldownFrame.GetParent and cooldownFrame:GetParent()
    if not current then return nil end

    local chain = classifyChain
    local chainLen = 0
    local node = current
    while node and node ~= UIParent and chainLen < SCAN_DEPTH do
        chainLen = chainLen + 1
        chain[chainLen] = node
        node = node:GetParent()
    end
    for i = chainLen + 1, #chain do chain[i] = nil end

    local viewerType = GetCooldownManagerViewerTypeFromChain(chain, chainLen)
    if viewerType then
        viewerTypeCache[cooldownFrame] = viewerType
    end
    return viewerType
end

function Classifier:GetMiniCCFrameType(cooldownFrame)
    local cached = miniCCTypeCache[cooldownFrame]
    if cached then return cached end

    local miniCCType = GetMiniCCFrameType(cooldownFrame)
    if miniCCType then
        miniCCTypeCache[cooldownFrame] = miniCCType
    end

    return miniCCType
end

function Classifier:IsCached(frame)
    return categoryCache[frame] ~= nil
end

function Classifier:SetCategory(frame, cat)
    categoryCache[frame] = cat
    if cat ~= "cooldownmanager" then
        viewerTypeCache[frame] = nil
    end
    if cat ~= "minicc" then
        miniCCTypeCache[frame] = nil
    end
end

function Classifier:WipeCache()
    wipe(categoryCache)
    wipe(viewerTypeCache)
    wipe(miniCCTypeCache)
end
