-- Classifier.lua – Frame classification & blacklist (AceModule)
--
-- Determines which category (actionbar / nameplate / unitframe / global)
-- a Cooldown frame belongs to, so the Styler can apply the right config.

local MCE = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local Classifier = MCE:NewModule("Classifier")

local strfind, ipairs, type = string.find, ipairs, type
local setmetatable, wipe = setmetatable, wipe
local UIParent = UIParent

local SCAN_DEPTH = 10  -- Ancestry levels scanned for frame classification (covers all known addon UIs)

-- Weak-keyed cache: auto-collected when frames are garbage-collected
local categoryCache = setmetatable({}, { __mode = "k" })

-- =========================================================================
-- BLACKLIST DATA
-- =========================================================================

-- Add your ignore cases here.
local BLACKLIST_NAME_CONTAINS = {
    "Glider", "Party", "Compact",
    "Raid", "VuhDo", "Grid",
    "LossOfControlFrame",
    "ContainerFrameCombinedBagsCooldown",
}

-- Exact relation keys: "ParentName -> FrameName"
local BLACKLIST_EXACT_PAIRS = {
    -- Character Slots
    ["CharacterBackSlot -> CharacterBackSlotCooldown"] = true,
    ["CharacterShirtSlot -> CharacterShirtSlotCooldown"] = true,
    ["CharacterMainHandSlot -> CharacterMainHandSlotCooldown"] = true,
    ["CharacterLegsSlot -> CharacterLegsSlotCooldown"] = true,
    ["CharacterFinger0Slot -> CharacterFinger0SlotCooldown"] = true,
    ["CharacterHeadSlot -> CharacterHeadSlotCooldown"] = true,
    ["CharacterFeetSlot -> CharacterFeetSlotCooldown"] = true,
    ["CharacterShoulderSlot -> CharacterShoulderSlotCooldown"] = true,
    ["CharacterWristSlot -> CharacterWristSlotCooldown"] = true,
    ["CharacterHandsSlot -> CharacterHandsSlotCooldown"] = true,
    ["CharacterTabardSlot -> CharacterTabardSlotCooldown"] = true,
    ["CharacterSecondaryHandSlot -> CharacterSecondaryHandSlotCooldown"] = true,
    ["CharacterFinger1Slot -> CharacterFinger1SlotCooldown"] = true,
    ["CharacterWaistSlot -> CharacterWaistSlotCooldown"] = true,
    ["CharacterChestSlot -> CharacterChestSlotCooldown"] = true,
    ["CharacterNeckSlot -> CharacterNeckSlotCooldown"] = true,
    ["CharacterTrinket1Slot -> CharacterTrinket1SlotCooldown"] = true,
    ["CharacterTrinket0Slot -> CharacterTrinket0SlotCooldown"] = true,
}

-- =========================================================================
-- PATTERN HELPERS
-- =========================================================================

local function IsNameplateContext(name, objType, unit)
    return objType == "NamePlate"
        or strfind(name, "NamePlate", 1, true)
        or strfind(name, "Plater",    1, true)
        or strfind(name, "Kui",       1, true)
        or (unit and strfind(unit, "nameplate", 1, true))
end

-- NOUVELLE FONCTION : Détection ultra-rapide des frames générées par MiniCC
-- MiniCC injects DesiredIconSize/FontScale on anonymous nameplate cooldowns.
local function IsMiniCCFrame(frame)
    if not frame then return false end

    -- 1. Duck-typing : MiniCC injecte ces variables spécifiques sur le Cooldown
    if frame.DesiredIconSize and frame.FontScale then
        -- 2. Vérification de la hiérarchie (Cooldown -> Slot -> Container -> Nameplate)
        -- Les frames intermédiaires de MiniCC sont anonymes, GetName() doit retourner nil
        local slotFrame = frame:GetParent()
        if slotFrame and not slotFrame:GetName() then
            
            local containerFrame = slotFrame:GetParent()
            if containerFrame and not containerFrame:GetName() then
                
                local nameplate = containerFrame:GetParent()
                -- 3. Le parent final doit être une Nameplate reconnue
                if nameplate then
                    local npName = nameplate:GetName() or ""
                    if IsNameplateContext(npName, nameplate:GetObjectType(), nameplate.unit) then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

-- =========================================================================
-- PUBLIC API
-- =========================================================================

function Classifier:IsBlacklisted(frame, knownFrameName)
    if not frame then return false end

    -- On ignore immédiatement les frames de MiniCC
    if IsMiniCCFrame(frame) then return true end

    local frameName = knownFrameName or (frame.GetName and frame:GetName()) or "AnonymousFrame"
    local parent    = frame.GetParent and frame:GetParent() or nil
    local parentName = parent and parent.GetName and parent:GetName() or "NoParent"

    if BLACKLIST_EXACT_PAIRS[parentName .. " -> " .. frameName] then return true end

    for _, key in ipairs(BLACKLIST_NAME_CONTAINS) do
        if strfind(frameName, key, 1, true) or strfind(parentName, key, 1, true) then
            return true
        end
    end
    return false
end

--- Single-pass frame classifier. Builds the ancestry chain once, then
--- classifies by priority: blacklist > nameplate > unitframe > actionbar > global.
function Classifier:ClassifyFrame(cooldownFrame)
    local current = cooldownFrame:GetParent()
    if not current then return "global" end

    local maxDepth     = SCAN_DEPTH
    local extendedLimit = SCAN_DEPTH + 30

    -- Phase 1: Build ancestry chain once (single allocation, reused for all checks)
    local chain = {}
    local chainLen = 0
    local node = current
    while node and node ~= UIParent and chainLen < extendedLimit do
        chainLen = chainLen + 1
        chain[chainLen] = node
        node = node:GetParent()
    end
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

    -- Phase 4: Extended nameplate check beyond configured depth
    -- Nameplates can be deeply nested in addon UIs (Plater, KuiNameplates, etc.)
    for i = limit + 1, chainLen do
        local frame = chain[i]
        if IsNameplateContext(frame:GetName() or "", frame:GetObjectType(), frame.unit) then
            return "nameplate"
        end
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

function Classifier:IsCached(frame)
    return categoryCache[frame] ~= nil
end

function Classifier:SetCategory(frame, cat)
    categoryCache[frame] = cat
end

function Classifier:WipeCache()
    wipe(categoryCache)
end
