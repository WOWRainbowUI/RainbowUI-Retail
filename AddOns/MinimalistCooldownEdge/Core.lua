-- Core.lua – Addon skeleton, shared utilities, and database defaults

local addonName, addon = ...
local MCE = LibStub("AceAddon-3.0"):NewAddon(addon, "MinimalistCooldownEdge",
    "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MinimalistCooldownEdge")

-- === UPVALUE LOCALS (Performance) ===
local pcall = pcall
local InCombatLockdown = InCombatLockdown

-- =========================================================================
-- SHARED UTILITIES  (used across all modules)
-- =========================================================================

--- Safe forbidden-frame check (pcall guards tainted frames).
--- Must use pcall because indexing a tainted frame itself throws.
function MCE:IsForbidden(frame)
    if not frame then return true end
    local ok, val = pcall(function() return frame:IsForbidden() end)
    return not ok or val
end

--- WoW API expects "" not "NONE" for font outline flags.
function MCE.NormalizeFontStyle(style)
    if not style or style == "NONE" then return "" end
    return style
end

--- Resolves "GAMEDEFAULT" to WoW's native font path.
function MCE.ResolveFontPath(fontPath)
    if fontPath == "GAMEDEFAULT" then
        return GameFontNormal:GetFont()
    end
    return fontPath
end

-- =========================================================================
-- DEBUG / LOGGING SYSTEM
-- =========================================================================

-- Initialisation de la table globale si elle n'existe pas
MinimalistCooldownEdge_DebugLog = MinimalistCooldownEdge_DebugLog or {}

-- Cache de session pour éviter de spammer le fichier d'écriture à chaque frame (performance)
local sessionLogCache = {}

function MCE:DebugPrint(message)
    if not (self.db and self.db.profile and self.db.profile.debugMode) then return end
    self:Print("|cffffaa00[Debug]|r " .. tostring(message))
end

function MCE:LogStyleApplication(frame, category, success)
    if not frame then return end
    if not (self.db and self.db.profile and self.db.profile.debugMode) then return end
    if self:GetModule("Classifier"):IsBlacklisted(frame) then return end

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
        success = success,
    }
end

-- =========================================================================
-- DATABASE DEFAULTS
-- =========================================================================

local function CategoryDefaults(enabled, fontSize)
    return {
        enabled = enabled,
        font = "GAMEDEFAULT", fontSize = fontSize or 18, fontStyle = "OUTLINE",
        textColor = { r = 1, g = 0.8, b = 0, a = 1 },
        textAnchor = "CENTER", textOffsetX = 0, textOffsetY = 0,
        hideCountdownNumbers = false,
        edgeEnabled = true, edgeScale = 1.4,
        stackEnabled = true,
        stackFont = "GAMEDEFAULT", stackSize = 16, stackStyle = "OUTLINE",
        stackColor = { r = 1, g = 1, b = 1, a = 1 },
        stackAnchor = "BOTTOMRIGHT", stackOffsetX = -3, stackOffsetY = 3,
    }
end

MCE.defaults = {
    profile = {
        debugMode = false,
        categories = {
            actionbar = CategoryDefaults(true,  18),
            nameplate = CategoryDefaults(false, 12),
            unitframe = CategoryDefaults(false, 12),
            global    = CategoryDefaults(false, 18),
        },
    },
}

-- =========================================================================
-- ACE LIFECYCLE
-- =========================================================================

function MCE:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MinimalistCooldownEdgeDB_v2", self.defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.GetOptions)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, addonName)

    self:RegisterChatCommand("mce", "SlashCommand")
    self:RegisterChatCommand("minice", "SlashCommand")
    self:RegisterChatCommand("minimalistcooldownedge", "SlashCommand")

    self:DebugPrint("Addon initialized.")
end

function MCE:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:DebugPrint("Addon enabled.")
end

function MCE:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:DebugPrint("Addon disabled.")
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
    LibStub("AceConfigDialog-3.0"):Open(addonName)
end

--- Public API – delegates to Styler module.
function MCE:ForceUpdateAll(fullScan)
    self:GetModule("Styler"):ForceUpdateAll(fullScan)
end
