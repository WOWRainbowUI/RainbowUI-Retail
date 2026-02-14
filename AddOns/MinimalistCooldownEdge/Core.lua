-- Core.lua - Main functionality using Ace3

local _, addon = ...
local MCE = LibStub("AceAddon-3.0"):NewAddon(addon, "MinimalistCooldownEdge", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MinimalistCooldownEdge")

-- === UPVALUE LOCALS (Performance) ===
local pairs, ipairs, type = pairs, ipairs, type
local pcall, setmetatable = pcall, setmetatable
local strfind = string.find
local C_Timer_After = C_Timer.After
local InCombatLockdown = InCombatLockdown
local EnumerateFrames = EnumerateFrames
local hooksecurefunc = hooksecurefunc
local UIParent = UIParent

-- === DEBUG / LOGGING SYSTEM ===
-- Initialisation de la table globale si elle n'existe pas
MinimalistCooldownEdge_DebugLog = MinimalistCooldownEdge_DebugLog or {}

-- Cache de session pour éviter de spammer le fichier d'écriture à chaque frame (performance)
local sessionLogCache = {}
local IsBlacklistedFrame

function MCE:DebugPrint(message)
    if not (self.db and self.db.profile and self.db.profile.debugMode) then return end
    self:Print("|cffffaa00[Debug]|r " .. tostring(message))
end

function MCE:LogStyleApplication(frame, category, success)
    if not frame then return end
    if not (self.db and self.db.profile and self.db.profile.debugMode) then return end
    if IsBlacklistedFrame(frame) then return end

    -- On crée un identifiant unique pour la frame
    local frameName = frame:GetName() or "AnonymousFrame"
    local parent = frame:GetParent()
    local parentName = parent and parent:GetName() or "NoParent"
    
    -- Clé unique : Parent -> Frame
    local key = parentName .. " -> " .. frameName
    
    -- Si on a déjà logué cette frame dans cette session, on ignore (pour ne pas tuer les FPS)
    if sessionLogCache[key] then return end
    sessionLogCache[key] = true

    -- Enregistrement dans la variable sauvegardée
    MinimalistCooldownEdge_DebugLog[key] = {
        frameName = frameName,
        parentName = parentName,
        category = category,
        objType = frame:GetObjectType(),
        timestamp = date("%Y-%m-%d %H:%M:%S"),
        success = success, -- Est-ce que le style a été appliqué ou bloqué ?
        scanDepth = MCE.db and MCE.db.profile and MCE.db.profile.scanDepth or nil -- Pour voir si la profondeur influe
    }
end

-- === BLACKLIST (Centralized frame matcher) ===
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

-- === CACHES (Weak-keyed to auto-collect garbage) ===
local categoryCache   = setmetatable({}, { __mode = "k" })
local trackedCooldowns = setmetatable({}, { __mode = "k" })
local pendingAuraRetries = setmetatable({}, { __mode = "k" })
local pendingGlobalDefer = setmetatable({}, { __mode = "k" })
local globalDeferDone = setmetatable({}, { __mode = "k" })

local hooksInstalled = false

-- === SAFE FORBIDDEN CHECK ===
-- Must use a closure inside pcall because indexing a "secret table"
-- (tainted frame) itself throws; we can't pre-resolve frame.IsForbidden.
local function IsForbiddenFrame(frame)
    if not frame then return true end
    local ok, forbidden = pcall(function() return frame:IsForbidden() end)
    return not ok or forbidden
end

IsBlacklistedFrame = function(frame, knownFrameName)
    if not frame then return false end

    local frameName = knownFrameName or (frame.GetName and frame:GetName()) or "AnonymousFrame"
    local parent = frame.GetParent and frame:GetParent() or nil
    local parentName = parent and parent.GetName and parent:GetName() or "NoParent"

    if BLACKLIST_EXACT_PAIRS[parentName .. " -> " .. frameName] then
        return true
    end

    for _, key in ipairs(BLACKLIST_NAME_CONTAINS) do
        if strfind(frameName, key, 1, true) or strfind(parentName, key, 1, true) then
            return true
        end
    end

    return false
end

local function IsNameplateContext(name, objType, unit)
    return objType == "NamePlate"
        or strfind(name, "NamePlate", 1, true)
        or strfind(name, "Plater", 1, true)
        or strfind(name, "Kui", 1, true)
        or (unit and strfind(unit, "nameplate", 1, true))
end

-- === FONT STYLE NORMALIZER ===
-- WoW API expects "" not "NONE"; centralise the conversion.
local function NormalizeFontStyle(style)
    if not style or style == "NONE" then return "" end
    return style
end

-- === ACE ADDON LIFECYCLE ===
function MCE:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MinimalistCooldownEdgeDB_v2", self.defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("MinimalistCooldownEdge", self.GetOptions)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("MinimalistCooldownEdge", "MinimalistCooldownEdge")

    self:RegisterChatCommand("mce", "SlashCommand")
    self:RegisterChatCommand("minice", "SlashCommand")
    self:RegisterChatCommand("minimalistcooldownedge", "SlashCommand")

    self:DebugPrint("Addon initialized.")
end

function MCE:OnEnable()
    self:SetupHooks()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:DebugPrint("Addon enabled.")

    if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_REGEN_ENABLED")

        if InCombatLockdown() then
            self:PLAYER_REGEN_DISABLED()
        end
    end

    C_Timer_After(2, function()
        self:DebugPrint("Initial full scan scheduled on enable.")
        self:ForceUpdateAll(true)
    end)
end

function MCE:OnDisable()
    if self.nameplateTicker then
        self.nameplateTicker:Cancel()
        self.nameplateTicker = nil
    end

    self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:DebugPrint("Addon disabled.")
end

function MCE:SlashCommand(input)
    local cmd = input and input:match("^%s*(%S+)")
    if cmd and cmd:lower() == "debug" then
        if not (self.db and self.db.profile) then return end

        self.db.profile.debugMode = not self.db.profile.debugMode

        if self.db.profile.debugMode then
            self:Print("Debug mode enabled.")
            self:DebugPrint("Debug logging active.")
        else
            self:Print("Debug mode disabled.")
        end
        return
    end

    if InCombatLockdown() then
        self:Print(L["Cannot open options in combat."])
        return
    end
    LibStub("AceConfigDialog-3.0"):Open("MinimalistCooldownEdge")
end

function MCE:PLAYER_ENTERING_WORLD(_, isInitialLogin, isReloadingUi)
    if isInitialLogin then
        self:DebugPrint("PLAYER_ENTERING_WORLD (initial login).")
    elseif isReloadingUi then
        self:DebugPrint("PLAYER_ENTERING_WORLD (UI reload).")
    else
        self:DebugPrint("PLAYER_ENTERING_WORLD (zone/world transition).")
    end
end

-- === DETECTION LOGIC ===
local function IsNameplateChain(frame, maxDepth)
    local current = frame
    local depth = 0
    maxDepth = maxDepth or 40

    while current and current ~= UIParent and depth < maxDepth do
        local name = current:GetName() or ""
        local objType = current:GetObjectType()

        if IsNameplateContext(name, objType, current.unit) then
            return true
        end

        current = current:GetParent()
        depth = depth + 1
    end

    return false
end

function MCE:GetCooldownCategory(cooldownFrame)
    local cached = categoryCache[cooldownFrame]
    if cached then return cached end

    local current = cooldownFrame:GetParent()
    if not current then
        return "global"
    end

    local maxDepth = (self.db and self.db.profile and self.db.profile.scanDepth) or 10

    if IsNameplateChain(current, maxDepth + 30) then
        categoryCache[cooldownFrame] = "nameplate"
        return "nameplate"
    end

    -- Fast early-out for aura buttons
    local parentName = current:GetName() or ""
    if strfind(parentName, "BuffButton", 1, true)
    or strfind(parentName, "DebuffButton", 1, true)
    or strfind(parentName, "TempEnchant", 1, true) then
        local probe = current
        local probeDepth = 0
        while probe and probe ~= UIParent and probeDepth < maxDepth do
            local probeName = probe:GetName() or ""
            local probeType = probe:GetObjectType()
            if IsNameplateContext(probeName, probeType, probe.unit) then
                categoryCache[cooldownFrame] = "nameplate"
                return "nameplate"
            end
            probe = probe:GetParent()
            probeDepth = probeDepth + 1
        end

        -- Defer classification briefly; some aura frames finish parenting a moment later.
        return "aura_pending"
    end

    local result = "global"
    local depth  = 0

    while current and current ~= UIParent and depth < maxDepth do
        local name    = current:GetName() or ""
        local objType = current:GetObjectType()

        -- Blacklist check (exact pair + contains patterns)
        if IsBlacklistedFrame(current, name) then
            categoryCache[cooldownFrame] = "blacklist"
            return "blacklist"
        end

        -- Nameplate detection
        if IsNameplateContext(name, objType, current.unit) then
            result = "nameplate"
            break
        end

        -- Unit frame detection
        if strfind(name, "PlayerFrame", 1, true)
        or strfind(name, "TargetFrame", 1, true)
        or strfind(name, "FocusFrame", 1, true)
        or strfind(name, "ElvUF", 1, true)
        or strfind(name, "SUF", 1, true) then
            result = "unitframe"
            break
        end

        -- Action bar detection
        if (current.action and type(current.action) == "number")
        or (current.GetAttribute and current:GetAttribute("type"))
        or strfind(name, "Action", 1, true)
        or strfind(name, "MultiBar", 1, true)
        or strfind(name, "BT4", 1, true)
        or strfind(name, "Dominos", 1, true) then
            if not strfind(name, "Aura", 1, true) then
                result = "actionbar"
                break
            end
        end

        current = current:GetParent()
        depth = depth + 1
    end

    if result ~= "global" then
        categoryCache[cooldownFrame] = result
    end
    return result
end

-- === STACK COUNT STYLING ===
function MCE:StyleStackCount(cooldownFrame, config, category)
    if category ~= "actionbar" or not config.stackEnabled then return end

    local parent = cooldownFrame:GetParent()
    if not parent then return end

    local parentName  = parent.GetName and parent:GetName()
    local countRegion = parent.Count or (parentName and _G[parentName .. "Count"])

    if not countRegion or not countRegion.GetObjectType then return end
    if countRegion:GetObjectType() ~= "FontString" then return end
    if IsForbiddenFrame(countRegion) then return end

    countRegion:SetFont(config.stackFont, config.stackSize, NormalizeFontStyle(config.stackStyle))
    local sc = config.stackColor
    countRegion:SetTextColor(sc.r, sc.g, sc.b, sc.a)
    countRegion:ClearAllPoints()
    countRegion:SetPoint(config.stackAnchor, parent, config.stackAnchor, config.stackOffsetX, config.stackOffsetY)
    if countRegion.GetDrawLayer then
        countRegion:SetDrawLayer("OVERLAY", 7)
    end
end

-- === STYLE APPLICATION ===
function MCE:ApplyCustomStyle(cdFrame, forcedCategory, skipGlobalDefer)
    if IsForbiddenFrame(cdFrame) then return end
    if IsBlacklistedFrame(cdFrame) then return end

    trackedCooldowns[cdFrame] = true

    if forcedCategory and forcedCategory ~= "global" then
        categoryCache[cdFrame] = forcedCategory
        pendingGlobalDefer[cdFrame] = nil
    end

    -- Guard: DB must be ready
    if not self.db or not self.db.profile or not self.db.profile.categories then return end

    local category = forcedCategory or self:GetCooldownCategory(cdFrame)

    -- Loguer la frame avant le traitement des cas spéciaux
    -- On loguera plus bas si le style est réellement appliqué, mais ici on capture la catégorie détectée

    if category == "aura_pending" then
        local retries = pendingAuraRetries[cdFrame] or 0
        if retries < 4 then
            pendingAuraRetries[cdFrame] = retries + 1
            C_Timer_After(0.05, function()
                if cdFrame and not IsForbiddenFrame(cdFrame) then
                    MCE:ApplyCustomStyle(cdFrame)
                end
            end)
            return
        end
        pendingAuraRetries[cdFrame] = nil
        category = "global"
    else
        pendingAuraRetries[cdFrame] = nil
    end

    -- Defer "global" styling one frame to avoid flicker on nameplates
    -- whose hierarchy has not finished attaching when the hook fires.
    if category == "global" and not forcedCategory and not skipGlobalDefer and not globalDeferDone[cdFrame] then
        if not pendingGlobalDefer[cdFrame] then
            pendingGlobalDefer[cdFrame] = true
            C_Timer_After(0, function()
                pendingGlobalDefer[cdFrame] = nil
                globalDeferDone[cdFrame] = true
                if cdFrame and not IsForbiddenFrame(cdFrame) and not categoryCache[cdFrame] then
                    MCE:ApplyCustomStyle(cdFrame, nil, true)
                end
            end)
            return
        end
        pendingGlobalDefer[cdFrame] = nil
    end

    if category == "blacklist" then 
        -- Optionnel : loguer les frames blacklistées
        self:LogStyleApplication(cdFrame, "blacklist", false)
        return 
    end

    local config = self.db.profile.categories[category]
    if not config or not config.enabled then
        if cdFrame.SetDrawEdge then
            pcall(cdFrame.SetDrawEdge, cdFrame, false)
        end
        -- Loguer que c'est désactivé
        self:LogStyleApplication(cdFrame, category .. " (Disabled)", false)
        return
    end

    -- C'est ici que l'application réelle commence
    self:LogStyleApplication(cdFrame, category, true)

    -- Stack counts (action bar only)
    self:StyleStackCount(cdFrame, config, category)

    -- Edge glow
    if cdFrame.SetDrawEdge then
        pcall(cdFrame.SetDrawEdge, cdFrame, config.edgeEnabled)
        if config.edgeEnabled and cdFrame.SetEdgeScale then
            pcall(cdFrame.SetEdgeScale, cdFrame, config.edgeScale)
        end
    end

    -- Hide/show countdown numbers
    if cdFrame.SetHideCountdownNumbers then
        pcall(cdFrame.SetHideCountdownNumbers, cdFrame, config.hideCountdownNumbers)
    end

    -- Font string styling & positioning
    if not cdFrame.GetRegions then return end

    local numRegions = cdFrame.GetNumRegions and cdFrame:GetNumRegions() or 0
    if numRegions == 0 then return end

    local fontStyle = NormalizeFontStyle(config.fontStyle)
    local regions   = { cdFrame:GetRegions() }
    for i = 1, numRegions do
        local region = regions[i]
        if region:GetObjectType() == "FontString" and not IsForbiddenFrame(region) then
            region:SetFont(config.font, config.fontSize, fontStyle)
            if config.textColor then
                local tc = config.textColor
                region:SetTextColor(tc.r, tc.g, tc.b, tc.a)
            end
            if config.textAnchor then
                region:ClearAllPoints()
                region:SetPoint(config.textAnchor, cdFrame, config.textAnchor, config.textOffsetX, config.textOffsetY)
            end
        end
    end
end

-- === FORCE UPDATE ===
function MCE:ForceUpdateAll(fullScan)
    self:DebugPrint("ForceUpdateAll called (fullScan=" .. tostring(fullScan) .. ").")

    if fullScan or not self.fullScanDone then
        self.fullScanDone = true
        local frame = EnumerateFrames()
        while frame do
            if not IsForbiddenFrame(frame) then
                if frame:IsObjectType("Cooldown") then
                    self:ApplyCustomStyle(frame)
                elseif frame.cooldown and type(frame.cooldown) == "table" then
                    if not IsForbiddenFrame(frame.cooldown) then
                        self:ApplyCustomStyle(frame.cooldown)
                    end
                end
            end
            frame = EnumerateFrames(frame)
        end
        return
    end

    -- Incremental: only update previously tracked cooldowns
    for cd in pairs(trackedCooldowns) do
        if cd and cd.IsObjectType and cd:IsObjectType("Cooldown") then
            self:ApplyCustomStyle(cd)
        end
    end
end

-- === NAMEPLATE EVENTS ===
function MCE:NAME_PLATE_UNIT_ADDED(_, unit)
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit(unit)
    if plate then
        C_Timer_After(0, function() self:StyleCooldownsInFrame(plate, "nameplate", 10) end)
        C_Timer_After(0.12, function() self:StyleCooldownsInFrame(plate, "nameplate", 10) end)
    end
end

function MCE:NAME_PLATE_UNIT_REMOVED()
    -- Weak tables handle cleanup automatically.
end

function MCE:RefreshVisibleNameplates()
    if not (C_NamePlate and C_NamePlate.GetNamePlates) then return end

    for _, plate in ipairs(C_NamePlate.GetNamePlates() or {}) do
        if plate and not IsForbiddenFrame(plate) then
            self:StyleCooldownsInFrame(plate, "nameplate", 10)
        end
    end
end

function MCE:PLAYER_REGEN_DISABLED()
    if self.nameplateTicker then return end
    
    self.nameplateTicker = C_Timer.NewTicker(0.35, function()
        self:RefreshVisibleNameplates()
    end)
end

function MCE:PLAYER_REGEN_ENABLED()
    if self.nameplateTicker then
        self.nameplateTicker:Cancel()
        self.nameplateTicker = nil
    end
end

-- === HOOKS ===
function MCE:SetupHooks()
    if hooksInstalled then return end
    hooksInstalled = true

    hooksecurefunc("CooldownFrame_Set", function(f)
        MCE:ApplyCustomStyle(f)
    end)

    if CooldownFrame_SetTimer then
        hooksecurefunc("CooldownFrame_SetTimer", function(f)
            MCE:ApplyCustomStyle(f)
        end)
    end

    if ActionButton_UpdateCooldown then
        hooksecurefunc("ActionButton_UpdateCooldown", function(button)
            local cd = button and (button.cooldown or button.Cooldown)
            if cd then
                MCE:ApplyCustomStyle(cd, "actionbar")
            end
        end)
    end

    -- LibActionButton support (Bartender4, etc.)
    local LAB = LibStub("LibActionButton-1.0", true)
    if LAB then
        LAB:RegisterCallback("OnButtonUpdate", function(_, button)
            if button and button.cooldown then
                MCE:ApplyCustomStyle(button.cooldown, "actionbar")
            end
        end)
    end
end

-- === SCOPED SCANNING ===
function MCE:StyleCooldownsInFrame(rootFrame, forcedCategory, maxDepth)
    if not rootFrame then return end
    maxDepth = maxDepth or 5

    local function scan(frame, depth)
        if not frame or depth > maxDepth then return end
        if IsForbiddenFrame(frame) then return end

        if frame.IsObjectType and frame:IsObjectType("Cooldown") then
            self:ApplyCustomStyle(frame, forcedCategory)
        elseif frame.cooldown and type(frame.cooldown) == "table" then
            if not IsForbiddenFrame(frame.cooldown) then
                self:ApplyCustomStyle(frame.cooldown, forcedCategory)
            end
        end

        local childCount = frame.GetNumChildren and frame:GetNumChildren() or 0
        if childCount > 0 and frame.GetChildren then
            local children = { frame:GetChildren() }
            for i = 1, childCount do
                scan(children[i], depth + 1)
            end
        end
    end

    scan(rootFrame, 0)
end