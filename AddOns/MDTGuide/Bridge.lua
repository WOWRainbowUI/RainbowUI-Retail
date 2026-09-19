---@class Addon
local Addon = select(2, ...)

-- ---------------------------------------
--            MDT access bridge
-- ---------------------------------------
-- 
-- MDT 6.2 (released 2026-08) split itself into two addons:
--
--   MythicDungeonTools      always loaded, exposes _G.MythicDungeonToolsAPI
--   MythicDungeonTools_UI   LoadOnDemand, owns the private table that holds
--                           main_frame and every method guide mode drives
--
-- and deleted the `_G.MDT` global that MDTGuide was built on (commit 2476900,
-- "remove _G.MDT"). MDT's public plugin API (API:RegisterUIInitializer) only
-- offers six methods aimed at plugins that add a settings tab or extra dungeon
-- data; it exposes nothing that lets us hooksecurefunc MDT's own methods.
--
-- The table is still reachable, because the UI table inherits from the public
-- API. MythicDungeonTools_UI/Bootstrap.lua does:
--
--   setmetatable(MDT, { __index = API })
--
-- So any method a UI module calls on itself that lives *only* on the core
-- table resolves through that metatable and arrives with the UI table as
-- `self`. We swap the public API for a forwarding proxy, intercept the first
-- such call, and keep the `self` we were handed.
--
-- MDT:IsRetail() at Modules/DungeonSelect.lua:23 runs while the UI addon's
-- files are still being loaded, which makes it a deterministic capture point.
-- The minimap methods are fallbacks in case that call site moves.

local UI_ADDON = "MythicDungeonTools_UI"

-- Core-only methods that MDT's UI modules call on themselves, earliest first.
local CAPTURE_METHODS = {
    "IsRetail",
    "HideMinimapButton",
    "ShowMinimapButton",
    "SetCompartmentButtonShown"
}

-- Methods we must be able to hook or call once the UI addon has finished loading
local REQUIRED_METHODS = {
    "UpdateBottomText", "Maximize", "Minimize", "UpdateDungeonSelectVisibility",
    "SetSelectionToPull", "ActivatePullTooltip", "DungeonEnemies_UpdateSelected",
    "ShowEnemyInfoFrame", "CreateMenu", "DrawHull", "DrawHullFontString",
    "StartScaling", "SetScale", "GetScale", "UpdateMap", "DrawAllHulls",
    "ZoomMap", "GetCurrentSubLevel", "SetCurrentSubLevel", "GetCurrentPreset",
    "CountForces", "IsCloneIncluded", "GetBlip", "GetDB",
    "RunAfterFramesInitialized", "UpdateSectionVisibility",
    "GetNavigationSidebarWidth",
}

---MDT's private UI table, once captured.
---@type table?
Addon.MDT = nil

local callbacks = {}
local loaded = false

---Run `fn` once MDT's UI addon is loaded and its table has been captured.
---Fires immediately if that already happened.
---@param fn fun(mdt: table)
function Addon.OnMDTReady(fn)
    if loaded then fn(Addon.MDT) else callbacks[fn] = fn end
end

---MDT's UI table, or nil plus a hint in chat. Use at entry points a user can
---reach before MDT has ever been opened, such as keybindings.
---@return table?
function Addon.RequireMDT()
    if Addon.MDT then return Addon.MDT end

    if not C_AddOns.IsAddOnLoaded(UI_ADDON) then
        -- Capture only completes a frame later, so this keypress is lost. Start
        -- the load now and the next one will work.
        C_AddOns.LoadAddOn(UI_ADDON)
        Addon.Echo(nil, "Loading Mythic Dungeon Tools, try again in a moment.")
    else
        Addon.Echo(nil, "Could not reach Mythic Dungeon Tools.")
    end
end

-- ---------------------------------------
--             Capture MDT
-- ---------------------------------------

local origAPI = _G.MythicDungeonToolsAPI

if origAPI then
    ---@type table|nil
    local proxyAPI = setmetatable({}, { __index = origAPI })

    local function tryCaptureMDT(candidate)
        if Addon.MDT then return end
        if type(candidate) ~= "table" or candidate == proxyAPI or candidate == origAPI then return end

        -- MythicDungeonTools_UI/Bootstrap.lua fills these in before any module
        -- loads, so they tell the UI table apart from an unrelated caller.
        if type(candidate.L) ~= "table" or candidate.AddonName == nil then return end

        Addon.MDT = candidate

        _G.MythicDungeonToolsAPI = origAPI
        proxyAPI = nil
    end


    for _, name in ipairs(CAPTURE_METHODS) do
        proxyAPI[name] = function(self, ...)
            tryCaptureMDT(self)
            return origAPI[name](origAPI, ...)
        end
    end

    _G.MythicDungeonToolsAPI = proxyAPI
end

-- ---------------------------------------
--          Handle UI addon load
-- ---------------------------------------

local function OnUIAddonLoaded()
    if loaded then return end
    loaded = true

    -- Check MDT is accessible
    local mdt = Addon.MDT
    if not mdt then
        Addon.Error("Could not reach MythicDungeonTools' internals, guide mode is disabled.")
        return
    end

    -- Check required methods exist
    for _, name in ipairs(REQUIRED_METHODS) do
        if type(mdt[name]) ~= "function" then
            Addon.Error("MythicDungeonTools is missing required method %q, guide mode is disabled.", name)
            Addon.MDT = nil
            return
        end
    end

    -- Check if dev mode is enabled
    if mdt:GetDB().devMode then
        Addon.MDT = nil
        return
    end

    -- Call all queued callbacks
    for _, fn in pairs(callbacks) do fn(mdt) end
    wipe(callbacks)
end

if not C_AddOns.IsAddOnLoaded(UI_ADDON) then
    local Frame = CreateFrame("Frame")
    Frame:RegisterEvent("ADDON_LOADED")
    Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    Frame:SetScript("OnEvent", function(self, ev, ...)
        if ev == "ADDON_LOADED" then
            if ... ~= UI_ADDON then return end
            self:UnregisterEvent("ADDON_LOADED")
            -- Give the UI addon some time to initialize
            C_Timer.After(0, OnUIAddonLoaded)
        elseif ev == "PLAYER_ENTERING_WORLD" then
            -- Load in dungeons, so enemy tracking works
            if Addon.MDT or not MDTGuideDB.active then return end
            if select(2, IsInInstance()) ~= "party" then return end
            C_AddOns.LoadAddOn(UI_ADDON)
        end
    end)
else
    -- Something force-loaded the UI addon before us
    C_Timer.After(0, OnUIAddonLoaded)
end
