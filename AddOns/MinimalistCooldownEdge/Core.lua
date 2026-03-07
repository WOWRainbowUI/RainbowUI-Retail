-- Core.lua – Addon skeleton, shared utilities, and database defaults

local addonName, addon = ...
local MCE = LibStub("AceAddon-3.0"):NewAddon(addon, "MinimalistCooldownEdge",
    "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("MinimalistCooldownEdge")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- === UPVALUE LOCALS (Performance) ===
local pcall = pcall
local InCombatLockdown = InCombatLockdown
local select = select
local tostring = tostring
local tconcat = table.concat
local CHAT_PREFIX = "|cff00ccffMiniCE|r"

-- =========================================================================
-- SHARED UTILITIES  (used across all modules)
-- =========================================================================

--- Safe forbidden-frame check (pcall guards tainted frames).
--- Must use pcall because indexing a tainted frame itself throws.
--- Pre-defined helper avoids creating a closure on every call.
local function checkForbidden(frame)
    return frame:IsForbidden()
end

function MCE:IsForbidden(frame)
    if not frame then return true end
    local ok, val = pcall(checkForbidden, frame)
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

local function BuildChatMessage(...)
    local count = select("#", ...)
    if count == 0 then
        return CHAT_PREFIX
    end

    local parts = {}
    for i = 1, count do
        parts[i] = tostring(select(i, ...))
    end

    return CHAT_PREFIX .. " " .. tconcat(parts, " ")
end

function MCE:Print(...)
    DEFAULT_CHAT_FRAME:AddMessage(BuildChatMessage(...))
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

-- Action bar gets extra textColorByDuration defaults
local actionbarDefaults = CategoryDefaults(true, 18)
actionbarDefaults.textColorByDuration = {
    enabled = true,
    thresholds = {
        { threshold = 5,    color = { r = 1.0, g = 0.0,  b = 0.0,  a = 1.0 } },
        { threshold = 60,   color = { r = 1.0, g = 0.8,  b = 0.0,  a = 1.0 } },
        { threshold = 3600, color = { r = 1.0, g = 1.0,  b = 1.0,  a = 1.0 } },
    },
    defaultColor = { r = 0.67, g = 0.67, b = 0.67, a = 1.0 },
}

local cooldownManagerDefaults = CategoryDefaults(false, 18)
cooldownManagerDefaults.essentialFontSize = cooldownManagerDefaults.fontSize
cooldownManagerDefaults.utilityFontSize = cooldownManagerDefaults.fontSize
cooldownManagerDefaults.buffIconFontSize = cooldownManagerDefaults.fontSize

MCE.defaults = {
    global = {
        versionAlertsShown = {},
    },
    profile = {
        categories = {
            actionbar       = actionbarDefaults,
            nameplate       = CategoryDefaults(false, 12),
            unitframe       = CategoryDefaults(false, 12),
            cooldownmanager = cooldownManagerDefaults,
            global          = CategoryDefaults(false, 18),
        },
    },
}

-- =========================================================================
-- ACE LIFECYCLE
-- =========================================================================

function MCE:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("MinimalistCooldownEdgeDB_v2", self.defaults, true)

    if not self.db.global.versionAlertsShown then
        self.db.global.versionAlertsShown = {}
    end

    local categories = self.db.profile.categories
    if not categories.cooldownmanager then
        categories.cooldownmanager = CopyTable(self.defaults.profile.categories.cooldownmanager)
    end

    local cooldownManager = categories.cooldownmanager
    if cooldownManager.essentialFontSize == nil then
        cooldownManager.essentialFontSize = cooldownManager.fontSize or 18
    end
    if cooldownManager.utilityFontSize == nil then
        cooldownManager.utilityFontSize = cooldownManager.fontSize or 18
    end
    if cooldownManager.buffIconFontSize == nil then
        cooldownManager.buffIconFontSize = cooldownManager.fontSize or 18
    end

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.GetOptions)

    do
        local status = AceConfigDialog:GetStatusTable(addonName)
        status.width = math.max(status.width or 0, 900)
        status.height = math.max(status.height or 0, 600)
        status.groups = status.groups or {}
        status.groups.treewidth = math.max(status.groups.treewidth or 0, 210)
        status.groups.treesizable = true
    end

    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addonName, addonName)

    self:RegisterChatCommand("mce", "SlashCommand")
    self:RegisterChatCommand("minice", "SlashCommand")
    self:RegisterChatCommand("minimalistcooldownedge", "SlashCommand")
end

function MCE:OnEnable()
end

function MCE:OnDisable()
end

function MCE:SlashCommand(input)
    if InCombatLockdown() then
        self:Print(L["Cannot open options in combat."])
        return
    end
    AceConfigDialog:Open(addonName)
end

--- Public API – delegates to Styler module.
function MCE:ForceUpdateAll(fullScan)
    self:GetModule("Styler"):ForceUpdateAll(fullScan)
end
