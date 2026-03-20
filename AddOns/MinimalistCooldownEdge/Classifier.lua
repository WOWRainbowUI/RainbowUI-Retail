-- Classifier.lua – frame classification, cooldown discovery, and context resolution

local MCE = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local Classifier = MCE:NewModule("Classifier")

local Helpers = MCE.Helpers
local Constants = MCE.Constants

local pairs, ipairs, type, pcall = pairs, ipairs, type, pcall
local strfind, strlower = string.find, string.lower
local setmetatable, wipe = setmetatable, wipe
local UIParent = UIParent
local _G = _G

local SCAN_DEPTH = Constants.CLASSIFIER_SCAN_DEPTH
local MAX_COOLDOWN_OWNER_SCAN_DEPTH = Constants.MAX_COOLDOWN_OWNER_SCAN_DEPTH
local ROOT_SCAN_DEPTH = Constants.ROOT_SCAN_DEPTH
local SUPPORTED_CATEGORIES = Constants.SUPPORTED_CATEGORIES
local BLACKLIST_NAME_CONTAINS = Constants.BLACKLIST_NAME_CONTAINS
local BLACKLIST_EXACT_PAIRS = Constants.BLACKLIST_EXACT_PAIRS
local COOLDOWN_MEMBER_KEYS = Constants.COOLDOWN_MEMBER_KEYS
local ACTION_BAR_BUTTON_SPECS = Constants.ACTION_BAR_BUTTON_SPECS

local weakKeysMeta = { __mode = "k" }

local categoryCache = setmetatable({}, weakKeysMeta)
local viewerTypeCache = setmetatable({}, weakKeysMeta)
local miniCCTypeCache = setmetatable({}, weakKeysMeta)
local contextCache = setmetatable({}, weakKeysMeta)
local miniCCRootRegistry = setmetatable({}, weakKeysMeta)

local classifyChain = {}

local function IsSupportedCategory(category)
    return category and SUPPORTED_CATEGORIES[category] or false
end

local function IsNameplateContext(name, objectType, unit)
    local unitToken = Helpers.ExtractUnitToken(unit)
    local lowerName = name and type(name) == "string" and strlower(name) or ""

    return objectType == "NamePlate"
        or strfind(lowerName, "nameplate", 1, true)
        or strfind(lowerName, "plater", 1, true)
        or strfind(lowerName, "kui", 1, true)
        or strfind(lowerName, "elvnp", 1, true)
        or strfind(lowerName, "threatplate", 1, true)
        or (unitToken and type(unitToken) == "string" and strfind(strlower(unitToken), "nameplate", 1, true))
end

local function IsMiniCCNamedFrame(frame)
    if not frame or not frame.GetName then
        return false
    end

    local name = frame:GetName()
    return type(name) == "string" and strfind(name, "MiniCC_", 1, true) == 1
end

local function IsMiniCCFrame(frame)
    if not frame then
        return false
    end

    local current = frame
    for _ = 1, 6 do
        if not current then
            break
        end
        if IsMiniCCNamedFrame(current) then
            return true
        end
        current = current.GetParent and current:GetParent() or nil
    end

    return false
end

local function IsUnitFrameContext(frame)
    if not frame then
        return false
    end

    local unit = Helpers.GetFrameUnit(frame)
    if unit and not strfind(unit, "nameplate", 1, true) then
        return true
    end

    local name = frame.GetName and frame:GetName() or ""
    return strfind(name, "PlayerFrame", 1, true)
        or strfind(name, "TargetFrame", 1, true)
        or strfind(name, "FocusFrame", 1, true)
        or strfind(name, "PetFrame", 1, true)
        or strfind(name, "ElvUF", 1, true)
        or strfind(name, "SUF", 1, true)
        or strfind(name, "CompactPartyFrame", 1, true)
        or strfind(name, "CompactRaidFrame", 1, true)
        or strfind(name, "Grid", 1, true)
        or strfind(name, "Plexus", 1, true)
        or strfind(name, "Cell", 1, true)
        or strfind(name, "TPerl", 1, true)
end

local function IsPartyRaidUnitToken(unitToken)
    if type(unitToken) ~= "string" then
        return false
    end

    return strfind(unitToken, "party", 1, true) == 1
        or strfind(unitToken, "raid", 1, true) == 1
end

local function IsPartyRaidFrameName(name)
    if type(name) ~= "string" or name == "" then
        return false
    end

    return strfind(name, "PartyFrame", 1, true)
        or strfind(name, "CompactPartyFrame", 1, true)
        or strfind(name, "CompactRaidFrame", 1, true)
        or strfind(name, "SUFHeaderparty", 1, true)
        or strfind(name, "SUFHeaderraid", 1, true)
        or strfind(name, "SUFUnitparty", 1, true)
        or strfind(name, "SUFUnitraid", 1, true)
        or strfind(name, "ElvUF_Raid", 1, true)
        or strfind(name, "Plexus", 1, true)
        or strfind(name, "CellPartyFrame", 1, true)
        or strfind(name, "CellRaidFrame", 1, true)
        or strfind(name, "CellSoloFrame", 1, true)
        or strfind(name, "TPerl_Party", 1, true)
        or strfind(name, "TPerl_Raid", 1, true)
end

local function GetUnitFrameCategory(frame, knownName)
    if not frame then
        return nil
    end

    local name = knownName or (frame.GetName and frame:GetName()) or ""
    local unitToken = Helpers.GetFrameUnit(frame)

    if IsPartyRaidUnitToken(unitToken) or IsPartyRaidFrameName(name) then
        return "partyraidframes"
    end

    if IsUnitFrameContext(frame) then
        return "unitframe"
    end

    return nil
end

local function FindMiniCCRootFrame(frame)
    local current = frame
    local root = nil

    for _ = 1, SCAN_DEPTH + 10 do
        if not current or not IsMiniCCFrame(current) then
            break
        end
        root = current
        current = current.GetParent and current:GetParent() or nil
    end

    return root, current
end

local function RegisterMiniCCRoot(frame)
    local root = nil

    if frame and IsMiniCCNamedFrame(frame) then
        root = frame
    elseif frame then
        root = FindMiniCCRootFrame(frame)
    end

    if root and not MCE:IsForbidden(root) then
        miniCCRootRegistry[root] = true
    end

    return root
end

local function GetMiniCCPointRelativeFrame(frame)
    if not frame or not frame.GetPoint then
        return nil
    end

    local ok, _, relativeTo = pcall(frame.GetPoint, frame, 1)
    if ok then
        return relativeTo
    end

    return nil
end

local function ResolveMiniCCFrameType(frame)
    if not MCE:IsMiniCCAvailable() or not IsMiniCCFrame(frame) then
        return nil
    end

    local root, parent = FindMiniCCRootFrame(frame)
    if not root then
        return nil
    end

    RegisterMiniCCRoot(root)

    if parent then
        local parentName = parent.GetName and parent:GetName() or ""
        if IsNameplateContext(parentName, parent:GetObjectType(), Helpers.GetFrameUnit(parent)) then
            return "nameplate"
        end
        if IsUnitFrameContext(parent) then
            return "portrait"
        end
    end

    local relativeTo = GetMiniCCPointRelativeFrame(root)
    if relativeTo then
        local relativeName = relativeTo.GetName and relativeTo:GetName() or ""
        if IsNameplateContext(relativeName, relativeTo:GetObjectType(), Helpers.GetFrameUnit(relativeTo)) then
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
        if strfind(name, "BuffBarCooldownViewer", 1, true) then
            return "default"
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
            return "default"
        end
    end

    return nil
end

local function GetContextState(frame)
    local state = contextCache[frame]
    if not state then
        state = {}
        contextCache[frame] = state
    end
    return state
end

local function GetCompactGroupFrameTypeFromUnit(unitToken)
    if type(unitToken) ~= "string" then
        return nil
    end

    if strfind(unitToken, "raid", 1, true) == 1 then
        return "raid"
    end

    if strfind(unitToken, "party", 1, true) == 1 then
        return "party"
    end

    return nil
end

local function GetCompactGroupFrameType(frame)
    if not frame then
        return nil
    end

    local name = frame.GetName and frame:GetName() or ""
    if strfind(name, "CompactPartyFrame", 1, true) then
        return "party"
    end
    if strfind(name, "CompactRaidFrame", 1, true) then
        return "raid"
    end

    return GetCompactGroupFrameTypeFromUnit(Helpers.GetFrameUnitToken(frame))
end

local function IsKnownCooldownMember(frame, cooldown)
    if not frame or not cooldown then
        return false
    end

    for i = 1, #COOLDOWN_MEMBER_KEYS do
        if frame[COOLDOWN_MEMBER_KEYS[i]] == cooldown then
            return true
        end
    end

    return false
end

local function GetCompactPartyAuraTypeFromMember(parent, child)
    if not parent or not child then
        return nil
    end

    local auraFrame = parent.CenterDefensiveBuff
    if not auraFrame or MCE:IsForbidden(auraFrame) then
        return nil
    end

    if auraFrame == child or IsKnownCooldownMember(auraFrame, child) then
        return GetCompactGroupFrameType(parent)
    end

    return nil
end

local function GetActionIDFromButton(parent)
    if not parent then
        return nil
    end

    local actionID = parent.action
    if type(actionID) == "number" then
        return actionID
    end

    if parent.GetAttribute then
        local ok, attribute = pcall(parent.GetAttribute, parent, "action")
        if ok and type(attribute) == "number" then
            return attribute
        end
    end

    return nil
end

local function GetCooldownSpellID(owner)
    if not owner then
        return nil
    end

    if type(owner.GetSpellID) == "function" then
        local ok, spellID = pcall(owner.GetSpellID, owner)
        if ok and spellID then
            return spellID
        end
    end

    return owner.spellID
end

local QueueDiscoveredFrame
local ScanFrameTree
local ScanFrameMemberByKey

local function RunDiscoverySource(refreshFn, visited, callback)
    if type(refreshFn) == "function" then
        refreshFn(visited, callback)
    end
end

local function QueueKnownCooldownMembers(frame, callback, forcedCategory)
    local seen1, seen2

    for i = 1, 4 do
        local cooldown = frame[COOLDOWN_MEMBER_KEYS[i]]
        if type(cooldown) == "table"
           and cooldown ~= seen1 and cooldown ~= seen2
           and not MCE:IsForbidden(cooldown) then
            if forcedCategory and IsSupportedCategory(forcedCategory) then
                Classifier:SetCategory(cooldown, forcedCategory)
            end
            if not seen1 then
                seen1 = cooldown
            else
                seen2 = cooldown
            end
            if callback then
                callback(cooldown, forcedCategory)
            end
        end
    end
end

QueueDiscoveredFrame = function(frame, forcedCategory, callback)
    if not frame or MCE:IsForbidden(frame) then
        return
    end

    if frame.IsObjectType and frame:IsObjectType("Cooldown") then
        if forcedCategory and IsSupportedCategory(forcedCategory) then
            Classifier:SetCategory(frame, forcedCategory)
        end
        if callback then
            callback(frame, forcedCategory)
        end
        return
    end

    QueueKnownCooldownMembers(frame, callback, forcedCategory)
end

local function ScanFrameChildren(forcedCategory, maxDepth, visited, callback, firstChild, ...)
    if not firstChild then
        return
    end

    ScanFrameTree(firstChild, forcedCategory, maxDepth, visited, callback)
    ScanFrameChildren(forcedCategory, maxDepth, visited, callback, ...)
end

ScanFrameTree = function(root, forcedCategory, maxDepth, visited, callback)
    if not root or visited[root] or MCE:IsForbidden(root) then
        return
    end

    visited[root] = true
    QueueDiscoveredFrame(root, forcedCategory, callback)

    if maxDepth <= 0 or type(root.GetChildren) ~= "function" then
        return
    end

    local numChildren = root.GetNumChildren and root:GetNumChildren() or 0
    if numChildren == 0 then
        return
    end

    ScanFrameChildren(forcedCategory, maxDepth - 1, visited, callback, root:GetChildren())
end

ScanFrameMemberByKey = function(frame, memberKey, forcedCategory, maxDepth, visited, callback)
    if not frame or type(memberKey) ~= "string" then
        return
    end

    local member = frame[memberKey]
    if type(member) == "table" and not MCE:IsForbidden(member) then
        ScanFrameTree(member, forcedCategory, maxDepth, visited, callback)
    end
end

local function ScanGlobalFrameByName(globalName, forcedCategory, maxDepth, visited, callback)
    local frame = _G[globalName]
    if frame then
        ScanFrameTree(frame, forcedCategory, maxDepth, visited, callback)
    end
end

local function ScanNumberedGlobalFrames(prefix, count, forcedCategory, maxDepth, visited, callback, startIndex)
    for i = startIndex or 1, count do
        local frame = _G[prefix .. i]
        if frame then
            ScanFrameTree(frame, forcedCategory, maxDepth, visited, callback)
        end
    end
end

local function BootstrapActionBarCooldowns(visited, callback)
    local roots = {
        MainMenuBar,
        MainMenuBarArtFrame,
        MultiBarBottomLeft,
        MultiBarBottomRight,
        MultiBarLeft,
        MultiBarRight,
        MultiBar5,
        MultiBar6,
        MultiBar7,
        PetActionBarFrame,
        StanceBarFrame,
        PossessBarFrame,
        OverrideActionBar,
        OverrideActionBarFrame,
        ExtraActionBarFrame,
        ZoneAbilityFrame,
    }

    for i = 1, #roots do
        local root = roots[i]
        if root then
            ScanFrameTree(root, "actionbar", ROOT_SCAN_DEPTH.actionbar, visited, callback)
        end
    end

    for i = 1, #ACTION_BAR_BUTTON_SPECS do
        local spec = ACTION_BAR_BUTTON_SPECS[i]
        ScanNumberedGlobalFrames(spec.prefix, spec.count, "actionbar", 0, visited, callback)
    end

    local extraActionButton = ExtraActionButton1
    if extraActionButton then
        ScanFrameTree(extraActionButton, "actionbar", ROOT_SCAN_DEPTH.actionbar, visited, callback)
    end

    local zoneButton = ZoneAbilityFrame and ZoneAbilityFrame.SpellButton
    if zoneButton then
        ScanFrameTree(zoneButton, "actionbar", ROOT_SCAN_DEPTH.actionbar, visited, callback)
    end
end

local function BootstrapNameplateCooldowns(visited, callback)
    if not C_NamePlate or type(C_NamePlate.GetNamePlates) ~= "function" then
        return
    end

    local ok, nameplates = pcall(C_NamePlate.GetNamePlates)
    if not ok or type(nameplates) ~= "table" then
        return
    end

    for _, nameplate in pairs(nameplates) do
        ScanFrameTree(nameplate, "nameplate", ROOT_SCAN_DEPTH.nameplate, visited, callback)
    end
end

local function BootstrapUnitFrameCooldowns(visited, callback)
    local roots = {
        PlayerFrame,
        TargetFrame,
        FocusFrame,
        PetFrame,
        BossTargetFrameContainer,
        ArenaEnemyFrames,
        ElvUF_Player,
        ElvUF_Target,
        ElvUF_Focus,
        ElvUF_Pet,
        SUFUnitplayer,
        SUFUnittarget,
        SUFUnitfocus,
        SUFUnitpet,
    }

    for i = 1, #roots do
        local root = roots[i]
        if root then
            ScanFrameTree(root, "unitframe", ROOT_SCAN_DEPTH.unitframe, visited, callback)
        end
    end

    ScanNumberedGlobalFrames("ArenaEnemyFrame", 5, "unitframe", ROOT_SCAN_DEPTH.unitframe, visited, callback)
end

local function BootstrapPartyRaidFrameCooldowns(visited, callback)
    local roots = {
        PartyFrame,
        CompactPartyFrame,
        CompactRaidFrameContainer,
        CellPartyFrameHeader,
        CellSoloFrame,
        TPerl_Party_SecureHeader,
    }

    for i = 1, #roots do
        local root = roots[i]
        if root then
            ScanFrameTree(root, "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
        end
    end

    ScanNumberedGlobalFrames("CompactPartyFrameMember", 5, "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
    for i = 1, 5 do
        ScanFrameMemberByKey(_G["CompactPartyFrameMember" .. i], "CenterDefensiveBuff", "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
    end
    ScanNumberedGlobalFrames("CompactPartyFramePet", 4, "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
    ScanNumberedGlobalFrames("CompactRaidFrame", 40, "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
    for i = 1, 40 do
        ScanFrameMemberByKey(_G["CompactRaidFrame" .. i], "CenterDefensiveBuff", "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
    end
    ScanNumberedGlobalFrames("PlexusLayoutHeader", 12, "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
    ScanNumberedGlobalFrames("CellRaidFrameHeader", 8, "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback, 0)
    ScanNumberedGlobalFrames("SUFHeaderpartyUnitButton", 5, "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
    ScanNumberedGlobalFrames("SUFHeaderraidUnitButton", 40, "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
    ScanNumberedGlobalFrames("SUFUnitparty", 5, "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
    ScanNumberedGlobalFrames("SUFUnitraid", 40, "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
    ScanNumberedGlobalFrames("ElvUF_Raid", 8, "partyraidframes", ROOT_SCAN_DEPTH.partyraidframes, visited, callback)
end

local function BootstrapCooldownManagerCooldowns(visited, callback)
    ScanGlobalFrameByName("EssentialCooldownViewer", "cooldownmanager", ROOT_SCAN_DEPTH.cooldownmanager, visited, callback)
    ScanGlobalFrameByName("UtilityCooldownViewer", "cooldownmanager", ROOT_SCAN_DEPTH.cooldownmanager, visited, callback)
    ScanGlobalFrameByName("BuffIconCooldownViewer", "cooldownmanager", ROOT_SCAN_DEPTH.cooldownmanager, visited, callback)
    ScanGlobalFrameByName("BuffBarCooldownViewer", "cooldownmanager", ROOT_SCAN_DEPTH.cooldownmanager, visited, callback)
end

local function BootstrapMiniCCCooldowns(visited, callback)
    if not MCE:IsMiniCCAvailable() then
        return
    end

    local discoveredAny = false
    for root in pairs(miniCCRootRegistry) do
        if root and not MCE:IsForbidden(root) then
            discoveredAny = true
            ScanFrameTree(root, "minicc", ROOT_SCAN_DEPTH.minicc, visited, callback)
        end
    end

    if discoveredAny then
        return
    end

    for globalName, frame in pairs(_G) do
        if type(globalName) == "string"
           and type(frame) == "table"
           and strfind(globalName, "MiniCC_", 1, true) == 1 then
            RegisterMiniCCRoot(frame)
            ScanFrameTree(frame, "minicc", ROOT_SCAN_DEPTH.minicc, visited, callback)
        end
    end
end

local DISCOVERY_SOURCE_ORDER = {
    "actionbar",
    "nameplate",
    "unitframe",
    "partyraidframes",
    "cooldownmanager",
    "minicc",
}

local DISCOVERY_SOURCES = {
    actionbar = BootstrapActionBarCooldowns,
    nameplate = BootstrapNameplateCooldowns,
    unitframe = BootstrapUnitFrameCooldowns,
    partyraidframes = BootstrapPartyRaidFrameCooldowns,
    cooldownmanager = BootstrapCooldownManagerCooldowns,
    minicc = BootstrapMiniCCCooldowns,
}

local function NormalizeDiscoverySelection(selection)
    if selection == nil or selection == true or selection == "all" then
        return DISCOVERY_SOURCE_ORDER
    end

    if type(selection) == "string" then
        return IsSupportedCategory(selection) and { selection } or {}
    end

    if type(selection) ~= "table" then
        return {}
    end

    local normalized = {}
    for i = 1, #DISCOVERY_SOURCE_ORDER do
        local sourceKey = DISCOVERY_SOURCE_ORDER[i]
        if selection[sourceKey] then
            normalized[#normalized + 1] = sourceKey
        end
    end

    return normalized
end

function Classifier:IsBlacklisted(frame, knownFrameName)
    if not frame then
        return false
    end

    local frameName = knownFrameName or (frame.GetName and frame:GetName()) or "AnonymousFrame"
    local parent = frame.GetParent and frame:GetParent() or nil
    local parentName = parent and parent.GetName and parent:GetName() or "NoParent"

    if GetUnitFrameCategory(frame, frameName) == "partyraidframes" then
        return false
    end
    if parent and GetUnitFrameCategory(parent, parentName) == "partyraidframes" then
        return false
    end

    local parentBlacklist = BLACKLIST_EXACT_PAIRS[parentName]
    if parentBlacklist and parentBlacklist[frameName] then
        return true
    end

    for _, key in ipairs(BLACKLIST_NAME_CONTAINS) do
        if strfind(frameName, key, 1, true) or strfind(parentName, key, 1, true) then
            return true
        end
    end

    return false
end

function Classifier:ClassifyFrame(cooldownFrame)
    local miniCCType = ResolveMiniCCFrameType(cooldownFrame)
    if miniCCType then
        miniCCTypeCache[cooldownFrame] = miniCCType
        RegisterMiniCCRoot(cooldownFrame)
        return "minicc"
    end

    local current = cooldownFrame and cooldownFrame.GetParent and cooldownFrame:GetParent() or nil
    if not current then
        return nil
    end

    local chain = classifyChain
    local chainLen = 0
    local node = current
    while node and node ~= UIParent and chainLen < SCAN_DEPTH do
        chainLen = chainLen + 1
        chain[chainLen] = node
        node = node:GetParent()
    end
    for i = chainLen + 1, #chain do
        chain[i] = nil
    end

    local reachedUIParent = (node == UIParent)
    local parentName = current.GetName and current:GetName() or ""

    if strfind(parentName, "BuffButton", 1, true)
       or strfind(parentName, "DebuffButton", 1, true)
       or strfind(parentName, "TempEnchant", 1, true) then
        for i = 1, chainLen do
            local ancestor = chain[i]
            local name = ancestor.GetName and ancestor:GetName() or ""
            if IsNameplateContext(name, ancestor:GetObjectType(), ancestor.unit) then
                return "nameplate"
            end
        end

        if reachedUIParent then
            return nil
        end

        return "aura_pending"
    end

    local cooldownManagerViewerType = GetCooldownManagerViewerTypeFromChain(chain, chainLen)
    local limit = chainLen < SCAN_DEPTH and chainLen or SCAN_DEPTH

    for i = 1, limit do
        local frame = chain[i]
        local name = frame.GetName and frame:GetName() or ""
        local objectType = frame:GetObjectType()
        local unitFrameCategory = GetUnitFrameCategory(frame, name)

        if unitFrameCategory then
            return unitFrameCategory
        end

        if self:IsBlacklisted(frame, name) then
            return "blacklist"
        end

        if IsNameplateContext(name, objectType, frame.unit) then
            return "nameplate"
        end
        if (frame.action and type(frame.action) == "number")
           or (frame.GetAttribute and frame:GetAttribute("type"))
           or strfind(name, "Action", 1, true)
           or strfind(name, "MultiBar", 1, true)
           or strfind(name, "BT4", 1, true)
           or strfind(name, "Dominos", 1, true) then
            if not strfind(name, "Aura", 1, true) then
                return "actionbar"
            end
        end
    end

    if cooldownManagerViewerType then
        viewerTypeCache[cooldownFrame] = cooldownManagerViewerType
        return "cooldownmanager"
    end

    for i = limit + 1, chainLen do
        local frame = chain[i]
        if IsNameplateContext(frame:GetName() or "", frame:GetObjectType(), frame.unit) then
            return "nameplate"
        end
    end

    if not reachedUIParent and node == nil and chain[chainLen] ~= WorldFrame then
        return "aura_pending"
    end

    return nil
end

function Classifier:GetCategory(cooldownFrame)
    local cached = categoryCache[cooldownFrame]
    if cached then
        return cached
    end

    local category = self:ClassifyFrame(cooldownFrame)
    if category and category ~= "aura_pending" then
        categoryCache[cooldownFrame] = category
    end

    return category
end

function Classifier:GetCooldownManagerViewerType(cooldownFrame)
    local cached = viewerTypeCache[cooldownFrame]
    if cached then
        return cached
    end

    local current = cooldownFrame and cooldownFrame.GetParent and cooldownFrame:GetParent() or nil
    if not current then
        return nil
    end

    local chain = classifyChain
    local chainLen = 0
    local node = current
    while node and node ~= UIParent and chainLen < SCAN_DEPTH do
        chainLen = chainLen + 1
        chain[chainLen] = node
        node = node:GetParent()
    end
    for i = chainLen + 1, #chain do
        chain[i] = nil
    end

    local viewerType = GetCooldownManagerViewerTypeFromChain(chain, chainLen)
    if viewerType then
        viewerTypeCache[cooldownFrame] = viewerType
    end

    return viewerType
end

function Classifier:GetMiniCCFrameType(cooldownFrame)
    local cached = miniCCTypeCache[cooldownFrame]
    if cached then
        return cached
    end

    local miniCCType = ResolveMiniCCFrameType(cooldownFrame)
    if miniCCType then
        miniCCTypeCache[cooldownFrame] = miniCCType
    end

    return miniCCType
end

function Classifier:IsCached(frame)
    return categoryCache[frame] ~= nil
end

function Classifier:SetCategory(frame, category)
    categoryCache[frame] = category
    if category ~= "cooldownmanager" then
        viewerTypeCache[frame] = nil
    end
    if category ~= "minicc" then
        miniCCTypeCache[frame] = nil
    end
end

function Classifier:ClearContext(frame)
    if frame then
        contextCache[frame] = nil
    end
end

function Classifier:ResolveCooldownContext(cdFrame, forceRefresh)
    if not cdFrame then
        return nil
    end

    local state = GetContextState(cdFrame)
    if state.resolved and not forceRefresh then
        return state
    end

    wipe(state)

    local child = cdFrame
    local current = cdFrame.GetParent and cdFrame:GetParent() or nil
    local actionButton, actionID
    local spellOwner
    local auraInstanceOwner
    local auraUnitOwner
    local compactPartyAuraType = false
    local sawAuraContext = false
    local hasAuraNamedAncestor = false

    for _ = 1, MAX_COOLDOWN_OWNER_SCAN_DEPTH do
        if not current then
            break
        end

        if not actionButton then
            local resolvedActionID = GetActionIDFromButton(current)
            if resolvedActionID then
                actionButton = current
                actionID = resolvedActionID
            end
        end

        if not spellOwner and GetCooldownSpellID(current) ~= nil then
            spellOwner = current
        end

        if not auraInstanceOwner and Helpers.GetFrameAuraInstanceID(current) ~= nil then
            auraInstanceOwner = current
        end

        if not auraUnitOwner and Helpers.GetFrameUnitToken(current) ~= nil then
            auraUnitOwner = current
        end

        local name = current.GetName and current:GetName() or ""
        if strfind(name, "Buff", 1, true)
           or strfind(name, "Debuff", 1, true)
           or strfind(name, "Aura", 1, true) then
            hasAuraNamedAncestor = true
            sawAuraContext = true
            if compactPartyAuraType == false then
                if strfind(name, "CompactPartyFrame", 1, true) then
                    compactPartyAuraType = "party"
                elseif strfind(name, "CompactRaidFrame", 1, true) then
                    compactPartyAuraType = "raid"
                end
            end
        end

        if compactPartyAuraType == false and sawAuraContext and strfind(name, "Compact", 1, true) then
            local unitType = GetCompactGroupFrameTypeFromUnit(Helpers.GetFrameUnitToken(current))
            if unitType then
                compactPartyAuraType = unitType
            end
        end

        if compactPartyAuraType == false then
            local unitType = GetCompactPartyAuraTypeFromMember(current, child)
            if unitType then
                compactPartyAuraType = unitType
                hasAuraNamedAncestor = true
                sawAuraContext = true
            end
        end

        child = current
        current = current.GetParent and current:GetParent() or nil
    end

    state.resolved = true
    state.actionButton = actionButton or false
    state.actionID = actionID or false
    state.spellOwner = spellOwner or false
    state.auraInstanceOwner = auraInstanceOwner or false
    state.auraUnitOwner = auraUnitOwner or false
    state.compactPartyAuraType = compactPartyAuraType or false
    state.hasAuraNamedAncestor = hasAuraNamedAncestor or false

    return state
end

function Classifier:GetCompactPartyAuraFrameType(cdFrame)
    local state = self:ResolveCooldownContext(cdFrame)
    local frameType = state and state.compactPartyAuraType
    return frameType and frameType ~= false and frameType or nil
end

function Classifier:GetAuraDurationContext(cdFrame)
    local state = self:ResolveCooldownContext(cdFrame)
    if not state then
        return nil, nil, nil
    end

    local auraOwner = state.auraInstanceOwner ~= false and state.auraInstanceOwner or nil
    local unitOwner = state.auraUnitOwner ~= false and state.auraUnitOwner or nil
    local auraInstanceID = Helpers.GetFrameAuraInstanceID(auraOwner)
    local unitToken = Helpers.GetFrameUnitToken(unitOwner)

    if (not auraInstanceID or not unitToken) and state.hasAuraNamedAncestor then
        state = self:ResolveCooldownContext(cdFrame, true)
        auraOwner = state and state.auraInstanceOwner ~= false and state.auraInstanceOwner or nil
        unitOwner = state and state.auraUnitOwner ~= false and state.auraUnitOwner or nil
        auraInstanceID = Helpers.GetFrameAuraInstanceID(auraOwner)
        unitToken = Helpers.GetFrameUnitToken(unitOwner)
    end

    if auraInstanceID and unitToken then
        return auraInstanceID, unitToken, auraOwner or unitOwner
    end

    return nil, nil, nil
end

function Classifier:GetSpellCooldownOwner(cdFrame)
    local state = self:ResolveCooldownContext(cdFrame)
    return state and state.spellOwner ~= false and state.spellOwner or nil
end

function Classifier:GetActionIDFromButton(frame)
    return GetActionIDFromButton(frame)
end

function Classifier:GetCooldownSpellID(frame)
    return GetCooldownSpellID(frame)
end

function Classifier:ShouldUseAuraDurationFallback(cdFrame, category)
    category = category or self:GetCategory(cdFrame)
    if not category then
        return false
    end

    if category == "actionbar" or category == "minicc" then
        return false
    end

    if category == "cooldownmanager" then
        local viewerType = self:GetCooldownManagerViewerType(cdFrame)
        return viewerType == "bufficon"
    end

    if category == "nameplate" or category == "unitframe" or category == "partyraidframes" then
        return true
    end

    if category ~= "aura_pending" then
        return false
    end

    local state = self:ResolveCooldownContext(cdFrame)
    return state and state.hasAuraNamedAncestor == true or false
end

function Classifier:IsAuraDrivenCooldown(cdFrame, category)
    if not self:ShouldUseAuraDurationFallback(cdFrame, category) then
        return false
    end

    local auraInstanceID, unitToken = self:GetAuraDurationContext(cdFrame)
    if auraInstanceID and unitToken then
        return true
    end

    local state = self:ResolveCooldownContext(cdFrame)
    return state and state.hasAuraNamedAncestor == true or false
end

function Classifier:IsAssistedCombatActionCooldown(cdFrame)
    if not cdFrame or not C_ActionBar or type(C_ActionBar.IsAssistedCombatAction) ~= "function" then
        return false
    end

    local parent = cdFrame.GetParent and cdFrame:GetParent() or nil
    if not parent or MCE:IsForbidden(parent) then
        return false
    end

    local actionID = GetActionIDFromButton(parent)
    if not actionID then
        local state = self:ResolveCooldownContext(cdFrame)
        actionID = state and state.actionID ~= false and state.actionID or nil
    end

    if type(actionID) ~= "number" then
        return false
    end

    local ok, isAssisted = pcall(C_ActionBar.IsAssistedCombatAction, actionID)
    return ok and isAssisted == true
end

function Classifier:BootstrapSupportedCooldownSources(callback)
    self:RefreshSupportedCooldownSources("all", callback)
end

function Classifier:RefreshSupportedCooldownSources(selection, callback)
    local visited = {}
    local sources = NormalizeDiscoverySelection(selection)

    for i = 1, #sources do
        local sourceKey = sources[i]
        RunDiscoverySource(DISCOVERY_SOURCES[sourceKey], visited, callback)
    end
end

function Classifier:RefreshCategorySources(category, callback)
    self:RefreshSupportedCooldownSources(category, callback)
end

function Classifier:RegisterDiscoveredCooldown(frame, category)
    if category == "minicc" then
        RegisterMiniCCRoot(frame)
    end
end

function Classifier:ClearFrameClassification(frame)
    if not frame then
        return
    end

    categoryCache[frame] = nil
    viewerTypeCache[frame] = nil
    miniCCTypeCache[frame] = nil
    contextCache[frame] = nil
end

function Classifier:WipeCache()
    wipe(categoryCache)
    wipe(viewerTypeCache)
    wipe(miniCCTypeCache)
    wipe(contextCache)
    wipe(miniCCRootRegistry)
end
