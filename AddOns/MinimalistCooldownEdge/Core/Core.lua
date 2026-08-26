-- Core.lua – Addon skeleton, shared utilities, and database defaults

local addonName, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):NewAddon(addon, C.Addon.AceName,
    "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(C.Addon.AceName)
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

-- === UPVALUE LOCALS (Performance) ===
local pcall = pcall
local select = select
local tostring = tostring
local type = type
local tconcat = table.concat
local C_Timer_NewTimer = C_Timer.NewTimer
local CHAT_PREFIX = C.Chat.Prefix
local OPTION_SLIDER_DEBOUNCE_DELAY = C.Options.SliderDebounceDelay
local StaticPopup_Show = StaticPopup_Show
local StaticPopupDialogs = StaticPopupDialogs
local hooksecurefunc = hooksecurefunc
local issecretvalue = issecretvalue
local canaccessallvalues = canaccessallvalues
local CLIENT_INTERFACE_VERSION = select(4, GetBuildInfo())

local RELOAD_PROMPT_POPUP_ID = "MCE_ReloadPrompt"

MCE.Constants = C

-- Shared weak-keyed state tables accessible to all modules
local weakMeta = { __mode = "k" }
addon.weakMeta = weakMeta
addon.frameState = setmetatable({}, weakMeta)
addon.fontState = setmetatable({}, weakMeta)

-- =========================================================================
-- WORK DRIVER (addon profiler attribution)
-- =========================================================================
-- C_AddOnProfiler blames the addon that owns the frame or timer which STARTS
-- a code path, and code paths starting inside a secure Blizzard addon are not
-- profiled at all. Almost everything MiniCE does begins with Blizzard calling
-- Cooldown:SetCooldown() through our secure hooks, and the deferred passes were
-- scheduled with C_Timer from inside that Blizzard-owned path -- so the timers
-- inherited Blizzard's context and MiniCE reported a flat 0 ms in AddonProfiler.
--
-- This frame is created while MinimalistCooldownEdge's own files are loading,
-- so the client associates it with MiniCE. Every deferred pass and repeating
-- task now runs from its OnUpdate, which puts that CPU back under MiniCE in
-- C_AddOnProfiler.GetAddOnMetric("MinimalistCooldownEdge", ...).
--
-- The frame stays hidden (OnUpdate does not run) whenever nothing is queued,
-- so an idle MiniCE still costs nothing.
local driver = CreateFrame("Frame", "MinimalistCooldownEdgeDriver")
driver:Hide()
addon.driver = driver

do
    local xpcall, geterrorhandler = xpcall, geterrorhandler
    local tremove = table.remove
    local GetTime = GetTime

    -- One-shot queue is double-buffered so work queued *during* a pass waits for
    -- the next frame, matching C_Timer.After(0) semantics.
    local pendingTasks, pendingCount = {}, 0
    local spareTasks = {}
    local delayedTasks = {}
    local tickers = {}

    local handleMeta = {
        __index = {
            Cancel = function(self) self.cancelled = true end,
            IsCancelled = function(self) return self.cancelled == true end,
        },
    }

    -- Errors are routed to the standard handler instead of propagating, so one
    -- failing task cannot swallow the rest of the queue for that frame.
    local function Run(fn)
        xpcall(fn, geterrorhandler())
    end

    driver:SetScript("OnUpdate", function(_, elapsed)
        if pendingCount > 0 then
            local batch, batchCount = pendingTasks, pendingCount
            pendingTasks, pendingCount = spareTasks, 0
            spareTasks = batch

            for i = 1, batchCount do
                local fn = batch[i]
                batch[i] = nil
                Run(fn)
            end
        end

        for i = #delayedTasks, 1, -1 do
            local task = delayedTasks[i]
            if task.cancelled then
                tremove(delayedTasks, i)
            elseif GetTime() >= task.at then
                tremove(delayedTasks, i)
                Run(task.fn)
            end
        end

        local tickerCount = #tickers
        if tickerCount > 0 then
            for i = 1, tickerCount do
                local ticker = tickers[i]
                if not ticker.cancelled then
                    ticker.elapsed = ticker.elapsed + elapsed
                    if ticker.elapsed >= ticker.interval then
                        ticker.elapsed = 0
                        Run(ticker.fn)
                    end
                end
            end

            -- Compact after the pass: a ticker may cancel itself from its own
            -- callback, and tickers started during the pass wait for next frame.
            for i = tickerCount, 1, -1 do
                if tickers[i].cancelled then tremove(tickers, i) end
            end
        end

        if pendingCount == 0 and #delayedTasks == 0 and #tickers == 0 then
            driver:Hide()
        end
    end)

    -- Drop-in replacement for C_Timer.After(0, fn).
    function addon.RunNextFrame(fn)
        pendingCount = pendingCount + 1
        pendingTasks[pendingCount] = fn
        driver:Show()
    end

    -- Drop-in replacement for C_Timer.After(delay, fn) / C_Timer.NewTimer.
    -- Returns a handle exposing :Cancel().
    function addon.RunAfter(delay, fn)
        if not delay or delay <= 0 then
            addon.RunNextFrame(fn)
            return nil
        end

        local task = setmetatable({ at = GetTime() + delay, fn = fn }, handleMeta)
        delayedTasks[#delayedTasks + 1] = task
        driver:Show()
        return task
    end

    -- Drop-in replacement for C_Timer.NewTicker(interval, fn).
    function addon.NewTicker(interval, fn)
        local ticker = setmetatable({ interval = interval, elapsed = 0, fn = fn }, handleMeta)
        tickers[#tickers + 1] = ticker
        driver:Show()
        return ticker
    end
end

-- Shared safe-value helpers (used by StyleEngine, HookBridge, Classifier, etc.)
-- Exposed on addon namespace so each module can upvalue them without duplication.
-- pcall is still required: both builtins throw when handed a tainted value.
function addon.IsSecretValue(value)
    local ok, result = pcall(issecretvalue, value)
    return ok and result or false
end

function addon.CanAccessAllValues(...)
    local ok, result = pcall(canaccessallvalues, ...)
    return ok and result or false
end

do
    local math_abs = math.abs
    local EPSILON = C.Styler.NumericComparisonEpsilon

    function addon.IsNearlyEqual(a, b)
        if issecretvalue(a) or issecretvalue(b) then return false end
        if a == b then return true end
        if type(a) ~= "number" or type(b) ~= "number" then return false end
        return math_abs(a - b) < EPSILON
    end

    function addon.IsSameSwipeColor(state, r, g, b, a)
        return state
            and addon.IsNearlyEqual(state.r, r)
            and addon.IsNearlyEqual(state.g, g)
            and addon.IsNearlyEqual(state.b, b)
            and addon.IsNearlyEqual(state.a, a)
    end
end

function addon.IsMUIStyledCooldown(cooldown)
    if not MCE:IsMUIAvailable() then return false end
    local parent = addon.GetParentSafe(cooldown)
    return parent and parent.mUIBorder ~= nil
end

local addonLoadState = {}
local ownershipProviderAddons = {
    [C.Addon.HealerCCName] = true,
    [C.Addon.MiniAurasName] = true,
    [C.Addon.DominosName] = true,
    [C.Addon.DominosCastName] = true,
    [C.Addon.DominosConfigName] = true,
    [C.Addon.Bartender4Name] = true,
    [C.Addon.SArenaName] = true,
    [C.Addon.TellMeWhenName] = true,
    [C.Addon.MyDRsName] = true,
    [C.Addon.ShackledName] = true,
    [C.Addon.ShinyAurasName] = true,
    [C.Addon.BetterBlizzFramesName] = true,
    [C.Addon.BetterBlizzPlatesName] = true,
    ElvUI = true,
}

local function IsOwnershipProviderAddon(addonName)
    return ownershipProviderAddons[addonName] == true
        or (type(addonName) == "string"
            and addonName:find("ElvUI", 1, true) == 1)
end

local function QueryAddonLoaded(addonName)
    if type(addonName) ~= "string" or addonName == "" then
        return false
    end

    return C_AddOns.IsAddOnLoaded(addonName) == true
end

-- =========================================================================
-- SHARED UTILITIES  (used across all modules)
-- =========================================================================

--- Safe forbidden-frame check (pcall guards tainted frames).
--- Must use pcall because indexing a tainted frame itself throws.
--- Pre-defined helper avoids creating a closure on every call.
local function checkForbidden(frame)
    return frame:IsForbidden()
end

local function checkSecretValue(value)
    return issecretvalue(value)
end

local function getParentKey(frame)
    return frame:GetParentKey()
end

local function getTableValue(tbl, key)
    return tbl[key]
end

local function setTableValue(tbl, key, value)
    tbl[key] = value
end

local function getParent(frame)
    return frame:GetParent()
end

local function areSameValue(left, right)
    return left == right
end

function MCE:IsForbidden(frame)
    if not frame then return true end
    local ok, val = pcall(checkForbidden, frame)
    return not ok or val
end

--- Safe parent lookup shared by every parent walk.
--- GetParent throws "forbidden object" whenever the parent itself is
--- forbidden, even though the child passes IsForbidden (MiniAuras
--- AuraContainer buttons become forbidden right after initialization).
--- Returns nil in that case so the walk simply stops instead of erroring.
function addon.GetParentSafe(frame)
    if not frame then return nil end

    local getParentMethod = MCE:SafeTableGet(frame, "GetParent")
    if type(getParentMethod) ~= "function" then return nil end

    local ok, parent = pcall(getParent, frame)
    if not ok then return nil end

    return parent
end

function MCE:SafeTableGet(tbl, key)
    if tbl == nil or key == nil then
        return nil
    end

    local ok, value = pcall(getTableValue, tbl, key)
    if not ok then
        return nil
    end

    return value
end

function MCE:IsSecretValue(value)
    local ok, result = pcall(checkSecretValue, value)
    return ok and result or false
end

function MCE:GetNonSecretString(value)
    if type(value) ~= "string" then
        return nil
    end

    if self:IsSecretValue(value) or not addon.CanAccessAllValues(value) then
        return nil
    end

    if value == "" then
        return nil
    end

    return value
end

function MCE:CanUseFrameAsTableKey(frame)
    if not frame then return false end

    local frameType = type(frame)
    if frameType ~= "table" and frameType ~= "userdata" then
        return false
    end

    local ok, isSecret = pcall(checkSecretValue, frame)
    if not ok or isSecret then
        return false
    end

    local accessOk, canAccess = pcall(canaccessallvalues, frame)
    if not accessOk or not canAccess then
        return false
    end

    return not self:IsForbidden(frame)
end

function MCE:GetNonSecretParentKey(frame)
    if not frame or not frame.GetParentKey then
        return nil
    end

    local ok, parentKey = pcall(getParentKey, frame)
    if not ok then
        return nil
    end

    parentKey = self:GetNonSecretString(parentKey)
    if not parentKey then
        return nil
    end

    return parentKey
end

function MCE:GetFrameName(frame)
    if not frame or self:IsForbiddenCached(frame) then
        return nil
    end

    local getName = self:SafeTableGet(frame, "GetName")
    if type(getName) ~= "function" then
        return nil
    end

    local ok, name = pcall(getName, frame)
    if not ok then
        return nil
    end

    return self:GetNonSecretString(name)
end

function MCE:IsLossOfControlCooldown(cooldown)
    if not self:CanUseFrameAsTableKey(cooldown) then
        return false
    end

    if self:GetNonSecretParentKey(cooldown) == "lossOfControlCooldown" then
        return true
    end

    local parent = addon.GetParentSafe(cooldown)
    if not self:CanUseFrameAsTableKey(parent) then
        return false
    end

    local overlay = self:SafeTableGet(parent, "lossOfControlCooldown")
    if not self:CanUseFrameAsTableKey(overlay) then
        return false
    end

    return overlay == cooldown
end

--- Cached wrappers for hot paths.
-- Results are stored per-frame in frameState and invalidated by
-- InvalidateResolvedFrameState in HookBridge on each new hook cycle.
local frameState = addon.frameState

function MCE:IsForbiddenCached(frame)
    if not frame then return true end
    local ok, fs = pcall(getTableValue, frameState, frame)
    if not ok then fs = nil end
    if fs then
        local cached = fs.isForbidden
        if cached ~= nil then return cached end
    end
    local result = self:IsForbidden(frame)
    if fs then
        fs.isForbidden = result
    end
    return result
end

--- Cooldowns MiniCE does not track have no frameState entry to memoize into, yet
--- this check runs first in every Cooldown hook -- so it was recomputed (a dozen
--- pcalls) for every SetCooldown and Clear in the whole UI. The loss-of-control
--- relation is structural: the parent key and the owner's lossOfControlCooldown
--- field are set when the frame is built, so a verdict resolved on an
--- inspectable frame stays valid for that frame's lifetime.
local lossOfControlCache = setmetatable({}, weakMeta)

function MCE:IsLossOfControlCooldownCached(cooldown)
    if not cooldown then return false end
    local ok, fs = pcall(getTableValue, frameState, cooldown)
    if not ok then fs = nil end
    if fs then
        local cached = fs.isLoC
        if cached ~= nil then return cached end

        local result = self:IsLossOfControlCooldown(cooldown)
        fs.isLoC = result
        return result
    end

    local cachedOk, cached = pcall(getTableValue, lossOfControlCache, cooldown)
    if cachedOk and cached ~= nil then return cached end

    -- IsLossOfControlCooldown answers false for any frame it cannot inspect.
    -- That answer is not a verdict, so it must never be memoized.
    if not self:CanUseFrameAsTableKey(cooldown) then return false end

    local result = self:IsLossOfControlCooldown(cooldown)
    pcall(setTableValue, lossOfControlCache, cooldown, result)
    return result
end

--- WoW API expects "" not "NONE" for font outline flags.
function MCE.NormalizeFontStyle(style)
    if not style or style == C.Style.FontStyles.None then return "" end
    return style
end

--- Resolves "GAMEDEFAULT" to WoW's native font path.
function MCE.ResolveFontPath(fontPath)
    if fontPath == C.Style.Fonts.GameDefault then
        return GameFontNormal:GetFont()
    end
    return fontPath
end

function MCE:SetAddonLoadState(addonName, isLoaded)
    if type(addonName) ~= "string" or addonName == "" then
        return false
    end

    addonLoadState[addonName] = isLoaded == true
    return addonLoadState[addonName]
end

function MCE:IsAddonLoadedCached(addonName)
    if type(addonName) ~= "string" or addonName == "" then
        return false
    end

    local cached = addonLoadState[addonName]
    if cached ~= nil then
        return cached
    end

    return self:SetAddonLoadState(addonName, QueryAddonLoaded(addonName))
end

function MCE:IsMiniAurasAvailable()
    return self:IsAddonLoadedCached(C.Addon.MiniAurasName)
end

function MCE:IsHealerCCAvailable()
    if _G.HealerCCAnchor or _G.HealerCCEnemyAnchor then
        self:SetAddonLoadState(C.Addon.HealerCCName, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.HealerCCName)
end

function MCE:IsDominosAvailable()
    if _G.DominosFrame1 or _G.DominosActionButton1 then
        self:SetAddonLoadState(C.Addon.DominosName, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.DominosName)
        or self:IsAddonLoadedCached(C.Addon.DominosCastName)
        or self:IsAddonLoadedCached(C.Addon.DominosConfigName)
end

function MCE:IsBartender4Available()
    if _G.BT4Button1 then
        self:SetAddonLoadState(C.Addon.Bartender4Name, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.Bartender4Name)
end

function MCE:IsSArenaAvailable()
    return self:IsAddonLoadedCached(C.Addon.SArenaName)
end

function MCE:IsTellMeWhenAvailable()
    return self:IsAddonLoadedCached(C.Addon.TellMeWhenName)
end

function MCE:IsMyDRsAvailable()
    if _G.MyDRsContainer or type(_G.MyDRs) == "table" then
        self:SetAddonLoadState(C.Addon.MyDRsName, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.MyDRsName)
end

function MCE:IsShackledAvailable()
    if _G[C.Adapter.Shackled.BarFrameName] then
        self:SetAddonLoadState(C.Addon.ShackledName, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.ShackledName)
end

function MCE:IsElvUIAvailable()
    if type(_G.ElvUI) == "table" then
        self:SetAddonLoadState("ElvUI", true)
        return true
    end

    return self:IsAddonLoadedCached("ElvUI")
end

function MCE:IsCooldownManagerCenteredAvailable()
    local addonName = C.Addon.CooldownManagerCenteredName
    if type(_G[addonName]) == "table" then
        self:SetAddonLoadState(addonName, true)
        return true
    end

    return self:IsAddonLoadedCached(addonName)
end

function MCE:IsMUIAvailable()
    if type(_G.mUI) == "table" then
        self:SetAddonLoadState(C.Addon.MUIName, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.MUIName)
end

function MCE:IsShinyAurasAvailable()
    if _G.ShinyAurasFrame or type(_G.ShinyAurasDB) == "table" then
        self:SetAddonLoadState(C.Addon.ShinyAurasName, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.ShinyAurasName)
end

function MCE:IsBetterBlizzFramesAvailable()
    if type(_G.BBF) == "table" then
        self:SetAddonLoadState(C.Addon.BetterBlizzFramesName, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.BetterBlizzFramesName)
end

function MCE:IsBetterBlizzPlatesAvailable()
    if type(_G.BBP) == "table" then
        self:SetAddonLoadState(C.Addon.BetterBlizzPlatesName, true)
        return true
    end

    return self:IsAddonLoadedCached(C.Addon.BetterBlizzPlatesName)
end

function MCE:IsCategoryBlockedByAddonConflict(category)
    if category == C.Categories.Unitframe then
        return self:IsBetterBlizzFramesAvailable()
    end
    if category == C.Categories.Nameplate then
        return self:IsBetterBlizzPlatesAvailable()
    end
    return false
end

function MCE:InvalidateOwnership()
    local registry = self:GetModule("TargetRegistry", true)
    if registry then
        registry:InvalidateOwnership()
    end
end

function MCE:IsCategoryActive(category, config)
    if config == nil then
        local profile = self.db and self.db.profile
        local categories = profile and profile.categories
        config = categories and categories[category]
    end
    return config and config.enabled == true
        and not self:IsCategoryBlockedByAddonConflict(category)
        or false
end

function MCE:IsShinyAurasAdapterEnabled()
    local profile = self.db and self.db.profile
    if not profile then
        return true
    end

    return profile.shinyAurasAdapterEnabled ~= false
end

function MCE:IsDominosAdapterEnabled()
    local profile = self.db and self.db.profile
    if not profile then
        return true
    end

    return profile.dominosAdapterEnabled ~= false
end

function MCE:IsBartender4AdapterEnabled()
    local profile = self.db and self.db.profile
    if not profile then
        return true
    end

    return profile.bartender4AdapterEnabled ~= false
end

function MCE:IsElvUIAdapterEnabled()
    local profile = self.db and self.db.profile
    if not profile then
        return true
    end

    return profile.elvuiAdapterEnabled ~= false
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

function MCE:WarnBetterBlizzFramesUnitFrameConflict()
    if self.betterBlizzFramesUnitFrameConflictWarned then return end

    self.betterBlizzFramesUnitFrameConflictWarned = true
    self:Print("|cffff7a1a" .. L["BETTERBLIZZFRAMES_UNITFRAME_CONFLICT_WARNING"] .. "|r")
end

function MCE:WarnBetterBlizzPlatesNameplateConflict()
    if self.betterBlizzPlatesNameplateConflictWarned then return end

    self.betterBlizzPlatesNameplateConflictWarned = true
    self:Print("|cffff7a1a" .. L["BETTERBLIZZPLATES_NAMEPLATE_CONFLICT_WARNING"] .. "|r")
end

local pendingCategoryConflicts = {}
local categoryConflictRefreshPending = false

local function QueueCategoryConflictRefresh(self, category, adapterName)
    pendingCategoryConflicts[category] = adapterName
    if categoryConflictRefreshPending then return end

    categoryConflictRefreshPending = true
    addon.RunNextFrame(function()
        categoryConflictRefreshPending = false
        local registry = self:GetModule("TargetRegistry", true)
        local styleEngine = self:GetModule("StyleEngine", true)
        if registry and styleEngine then
            for pendingCategory in pairs(pendingCategoryConflicts) do
                for cooldown in registry:IterateCategory(pendingCategory) do
                    if cooldown and not self:IsForbiddenCached(cooldown) then
                        styleEngine:ApplyStyle(cooldown, pendingCategory)
                    end
                end
            end
        end

        for _, pendingAdapterName in pairs(pendingCategoryConflicts) do
            local adapter = self:GetModule(pendingAdapterName, true)
            if adapter and adapter:IsEnabled() then
                adapter:Disable()
            end
        end
        wipe(pendingCategoryConflicts)

        self:ForceUpdateAll(true)
        AceConfigRegistry:NotifyChange(addonName)
    end)
end

function MCE:HandleBetterBlizzFramesUnitFrameConflict()
    self:WarnBetterBlizzFramesUnitFrameConflict()
    QueueCategoryConflictRefresh(
        self, C.Categories.Unitframe, "UnitFrameAdapter")
end

function MCE:HandleBetterBlizzPlatesNameplateConflict()
    self:WarnBetterBlizzPlatesNameplateConflict()
    QueueCategoryConflictRefresh(
        self, C.Categories.Nameplate, "NameplateAdapter")
end

function MCE:MarkReloadRequired()
    self.reloadRequired = true
    self.reloadChangeVersion = (self.reloadChangeVersion or 0) + 1
end

function MCE:ClearReloadRequired()
    self.reloadRequired = false
    self.reloadPromptedVersion = self.reloadChangeVersion or 0
end

function MCE:ShouldPromptForReload()
    return self.reloadRequired == true
        and (self.reloadPromptedVersion or 0) < (self.reloadChangeVersion or 0)
end

function MCE:EnsureReloadPromptDialog()
    if self.reloadPromptDialogRegistered or type(StaticPopupDialogs) ~= "table" then
        return
    end

    StaticPopupDialogs[RELOAD_PROMPT_POPUP_ID] = StaticPopupDialogs[RELOAD_PROMPT_POPUP_ID] or {
        text = L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"],
        button1 = RELOADUI,
        button2 = NOT_NOW or CANCEL,
        OnAccept = function()
            self:ClearReloadRequired()
            ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = STATICPOPUP_NUMDIALOGS,
    }

    self.reloadPromptDialogRegistered = true
end

function MCE:QueueReloadPrompt()
    if not self:ShouldPromptForReload() or self.reloadPromptQueued then
        return
    end

    self.reloadPromptQueued = true
    addon.RunNextFrame(function()
        self.reloadPromptQueued = nil

        if self:ShouldPromptForReload() and type(StaticPopup_Show) == "function" then
            self.reloadPromptedVersion = self.reloadChangeVersion or 0
            StaticPopup_Show(RELOAD_PROMPT_POPUP_ID)
        end
    end)
end

function MCE:HandleTrackedBlizzardOptionsClosed()
    if not self.visitedBlizzardOptions then
        return
    end

    self.visitedBlizzardOptions = false
    self:QueueReloadPrompt()
end

function MCE:EnsureSettingsPanelCloseHooks()
    local function HookSettingsFrame(frame)
        if not frame or not frame.HookScript or frame._mceReloadPromptHooked then
            return false
        end

        frame:HookScript("OnHide", function()
            self:HandleTrackedBlizzardOptionsClosed()
        end)
        frame._mceReloadPromptHooked = true
        return true
    end

    local hooked = false
    hooked = HookSettingsFrame(_G.SettingsPanel) or hooked
    hooked = HookSettingsFrame(_G.InterfaceOptionsFrame) or hooked

    self.settingsPanelCloseHooksInstalled = hooked or self.settingsPanelCloseHooksInstalled
end

function MCE:RegisterBlizzardOptionsPanel(panel)
    local frame = panel and (panel.frame or panel)
    if not frame or not frame.HookScript or frame._mceReloadPromptTracked then
        return panel
    end

    frame:HookScript("OnShow", function()
        self.visitedBlizzardOptions = true
        self:EnsureSettingsPanelCloseHooks()
    end)
    frame._mceReloadPromptTracked = true

    return panel
end

function MCE:EnsureOptionsCloseHooks()
    if self.optionsCloseHooksInstalled or type(hooksecurefunc) ~= "function" then
        return
    end

    hooksecurefunc(AceConfigDialog, "Open", function(_, appName)
        local widget = AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames[appName]
        local frame = widget and widget.frame
        if not frame or not frame.HookScript then
            return
        end

        frame._mceReloadPromptAppName = appName
        if not frame._mceReloadPromptHooked then
            frame:HookScript("OnHide", function(closingFrame)
                if closingFrame and closingFrame._mceReloadPromptAppName == addonName then
                    self:QueueReloadPrompt()
                end
            end)
            frame._mceReloadPromptHooked = true
        end
    end)

    self.optionsCloseHooksInstalled = true
end

-- =========================================================================
-- DATABASE DEFAULTS
-- =========================================================================

local function CategoryDefaults(categoryKey, enabled, fontSize)
    local defaults = C.Defaults.Category
    local allowThresholdColors = C.Defaults.AllowThresholdColorsByCategory[categoryKey] == true
    return {
        enabled = enabled,
        font = defaults.Font,
        fontSize = fontSize or defaults.FontSize,
        fontStyle = defaults.FontStyle,
        textColor = CopyTable(defaults.TextColor),
        textAnchor = defaults.TextAnchor,
        textOffsetX = defaults.TextOffsetX,
        textOffsetY = defaults.TextOffsetY,
        allowThresholdColors = allowThresholdColors,
        hideCountdownNumbers = defaults.HideCountdownNumbers,
        auraCdTextOnlyMine = defaults.AuraCdTextOnlyMine,
        drawSwipe = defaults.DrawSwipe,
        edgeEnabled = defaults.EdgeEnabled,
        edgeScale = defaults.EdgeScale,
        stackEnabled = defaults.StackEnabled,
        hideStackText = defaults.HideStackText,
        stackFont = defaults.StackFont,
        stackSize = defaults.StackSize,
        stackStyle = defaults.StackStyle,
        stackColor = CopyTable(defaults.StackColor),
        stackAnchor = defaults.StackAnchor,
        stackOffsetX = defaults.StackOffsetX,
        stackOffsetY = defaults.StackOffsetY,
    }
end

local PLAYER_AURA_STYLE_FIELDS = {
    "font",
    "fontSize",
    "fontStyle",
    "textColor",
    "timerInsideIcon",
    "textOffsetX",
    "textOffsetY",
    "hideCountdownNumbers",
    "drawSwipe",
    "edgeEnabled",
    "edgeScale",
    "reverseSwipe",
    "swipeAlpha",
    "stackEnabled",
    "hideStackText",
    "stackFont",
    "stackSize",
    "stackStyle",
    "stackColor",
    "stackAnchor",
    "stackOffsetX",
    "stackOffsetY",
}

local PLAYER_AURA_TYPE_KEYS = {
    C.PlayerAuraTypes.Buff,
    C.PlayerAuraTypes.Debuff,
    C.PlayerAuraTypes.ExternalDefensiveBuffs,
}

local LEGACY_PLAYER_AURA_DEFENSIVE_BUFF_KEY = "defensiveBuff"
local LEGACY_PLAYER_AURA_EXTERNAL_DEFENSIVE_BUFF_KEY = "externalDefensiveBuff"

local PLAYER_AURA_TYPE_KEY_LOOKUP = {}
for i = 1, #PLAYER_AURA_TYPE_KEYS do
    PLAYER_AURA_TYPE_KEY_LOOKUP[PLAYER_AURA_TYPE_KEYS[i]] = true
end

local function CopyConfigValue(value)
    return type(value) == "table" and CopyTable(value) or value
end

local function PlayerAuraTypeDefaults(sourceConfig)
    local defaults = {
        enabled = true,
    }

    for i = 1, #PLAYER_AURA_STYLE_FIELDS do
        local field = PLAYER_AURA_STYLE_FIELDS[i]
        defaults[field] = CopyConfigValue(sourceConfig[field])
    end

    return defaults
end

local function DurationTextColorDefaults()
    local defaults = C.Defaults.DurationTextColors
    local thresholds = {}

    for i = 1, #defaults.Thresholds do
        thresholds[i] = {
            threshold = defaults.Thresholds[i].threshold,
            color = CopyTable(defaults.Thresholds[i].color),
        }
    end

    return {
        enabled = defaults.Enabled,
        offset = defaults.Offset,
        thresholds = thresholds,
        defaultColor = CopyTable(defaults.DefaultColor),
    }
end

local actionbarDefaults = CategoryDefaults(C.Categories.Actionbar, true, 18)
actionbarDefaults.hideChargeTimers = C.Defaults.Actionbar.HideChargeTimers
actionbarDefaults.reverseSwipe = C.Defaults.Actionbar.ReverseSwipe
actionbarDefaults.swipeAlpha = C.Defaults.Actionbar.SwipeAlpha

local nameplateDefaults = CategoryDefaults(C.Categories.Nameplate, false, C.Defaults.Nameplate.FontSize)
nameplateDefaults.allowThresholdColors = nil
nameplateDefaults.stackSize = C.Defaults.Nameplate.StackSize
nameplateDefaults.stackAnchor = C.Defaults.Nameplate.StackAnchor
nameplateDefaults.stackOffsetX = C.Defaults.Nameplate.StackOffsetX
nameplateDefaults.stackOffsetY = C.Defaults.Nameplate.StackOffsetY

local unitframeDefaults = CategoryDefaults(C.Categories.Unitframe, false, 12)
unitframeDefaults.stackSize = C.Defaults.Unitframe.StackSize
unitframeDefaults.stackAnchor = C.Defaults.Unitframe.StackAnchor
unitframeDefaults.stackOffsetX = C.Defaults.Unitframe.StackOffsetX
unitframeDefaults.stackOffsetY = C.Defaults.Unitframe.StackOffsetY
unitframeDefaults.auraCdTextOnlyMine = true
unitframeDefaults.onlyMineDebuffs = C.Defaults.Unitframe.OnlyMineDebuffs
unitframeDefaults.onlyMineBuffs = C.Defaults.Unitframe.OnlyMineBuffs
unitframeDefaults.castBarReposition = C.Defaults.Unitframe.CastBarReposition

local playerAuraStyleDefaults = CategoryDefaults(C.Categories.PlayerAura, true, 12)
playerAuraStyleDefaults.reverseSwipe = C.Defaults.PlayerAura.ReverseSwipe
playerAuraStyleDefaults.swipeAlpha = C.Defaults.PlayerAura.SwipeAlpha
playerAuraStyleDefaults.timerInsideIcon = C.Defaults.PlayerAura.TimerInsideIcon

local playerAuraExternalDefensiveBuffsDefaults = PlayerAuraTypeDefaults(playerAuraStyleDefaults)
playerAuraExternalDefensiveBuffsDefaults.enabled = false

local playerAuraDefaults = {
    enabled = false,
    disableFading = C.Defaults.PlayerAura.DisableFading,
    [C.PlayerAuraTypes.Buff] = PlayerAuraTypeDefaults(playerAuraStyleDefaults),
    [C.PlayerAuraTypes.Debuff] = PlayerAuraTypeDefaults(playerAuraStyleDefaults),
    [C.PlayerAuraTypes.ExternalDefensiveBuffs] = playerAuraExternalDefensiveBuffsDefaults,
}

local defaultDurationTextColors = DurationTextColorDefaults()

local function EnsureDurationTextColorConfig(config)
    if type(config) ~= "table" then
        return CopyTable(defaultDurationTextColors)
    end

    if config.enabled == nil then
        config.enabled = defaultDurationTextColors.enabled
    end

    if type(config.offset) ~= "number" then
        config.offset = defaultDurationTextColors.offset
    end

    if type(config.thresholds) ~= "table" then
        config.thresholds = {}
    end

    for i = 1, #defaultDurationTextColors.thresholds do
        local defaultThreshold = defaultDurationTextColors.thresholds[i]
        local threshold = config.thresholds[i]

        if type(threshold) ~= "table" then
            config.thresholds[i] = CopyTable(defaultThreshold)
        else
            if threshold.threshold == nil then
                threshold.threshold = defaultThreshold.threshold
            end
            if type(threshold.color) ~= "table" then
                threshold.color = CopyTable(defaultThreshold.color)
            else
                threshold.color.r = threshold.color.r or defaultThreshold.color.r
                threshold.color.g = threshold.color.g or defaultThreshold.color.g
                threshold.color.b = threshold.color.b or defaultThreshold.color.b
                threshold.color.a = threshold.color.a or defaultThreshold.color.a
            end
        end
    end

    if type(config.defaultColor) ~= "table" then
        config.defaultColor = CopyTable(defaultDurationTextColors.defaultColor)
    else
        config.defaultColor.r = config.defaultColor.r or defaultDurationTextColors.defaultColor.r
        config.defaultColor.g = config.defaultColor.g or defaultDurationTextColors.defaultColor.g
        config.defaultColor.b = config.defaultColor.b or defaultDurationTextColors.defaultColor.b
        config.defaultColor.a = config.defaultColor.a or defaultDurationTextColors.defaultColor.a
    end

    return config
end

local function EnsurePlayerAuraConfig(config)
    if type(config) ~= "table" then
        return CopyTable(playerAuraDefaults)
    end

    for field, defaultValue in pairs(playerAuraDefaults) do
        if not PLAYER_AURA_TYPE_KEY_LOOKUP[field] and config[field] == nil then
            config[field] = type(defaultValue) == "table" and CopyTable(defaultValue) or defaultValue
        end
    end

    local externalDefensiveBuffsKey = C.PlayerAuraTypes.ExternalDefensiveBuffs
    if type(config[externalDefensiveBuffsKey]) ~= "table" then
        if type(config[LEGACY_PLAYER_AURA_EXTERNAL_DEFENSIVE_BUFF_KEY]) == "table" then
            config[externalDefensiveBuffsKey] = config[LEGACY_PLAYER_AURA_EXTERNAL_DEFENSIVE_BUFF_KEY]
        elseif type(config[LEGACY_PLAYER_AURA_DEFENSIVE_BUFF_KEY]) == "table" then
            config[externalDefensiveBuffsKey] = config[LEGACY_PLAYER_AURA_DEFENSIVE_BUFF_KEY]
        end
    end
    config[LEGACY_PLAYER_AURA_EXTERNAL_DEFENSIVE_BUFF_KEY] = nil
    config[LEGACY_PLAYER_AURA_DEFENSIVE_BUFF_KEY] = nil

    for i = 1, #PLAYER_AURA_TYPE_KEYS do
        local typeKey = PLAYER_AURA_TYPE_KEYS[i]
        local defaultTypeConfig = playerAuraDefaults[typeKey]
        local typeConfig = config[typeKey]
        if type(typeConfig) ~= "table" then
            typeConfig = CopyTable(defaultTypeConfig)
            config[typeKey] = typeConfig
        else
            for field, defaultValue in pairs(defaultTypeConfig) do
                if typeConfig[field] == nil then
                    typeConfig[field] = CopyConfigValue(defaultValue)
                end
            end
        end
    end

    return config
end

local function EnsureActionbarConfig(config)
    if type(config) ~= "table" then
        return CopyTable(actionbarDefaults)
    end

    if config.hideChargeTimers == nil then
        config.hideChargeTimers = C.Defaults.Actionbar.HideChargeTimers
    end
    if config.reverseSwipe == nil then
        config.reverseSwipe = C.Defaults.Actionbar.ReverseSwipe
    end
    if type(config.swipeAlpha) ~= "number" then
        config.swipeAlpha = C.Defaults.Actionbar.SwipeAlpha
    end

    return config
end

local function CleanupObsoleteProfileFields(profile)
    profile.cooldownManagerCenteredOverrideEnabled = nil
    profile.compactPartyAuraText = nil

    local categories = type(profile.categories) == "table" and profile.categories or nil
    if not categories then
        return
    end

    categories.partyraidframes = nil
    categories.compactPartyAura = nil
    categories[C.Categories.PartyRaidRetired] = nil

    local actionbarCategory = categories[C.Categories.Actionbar]
    if type(actionbarCategory) == "table" then
        actionbarCategory.textColorByDuration = nil
    end

    local nameplateCategory = categories[C.Categories.Nameplate]
    if type(nameplateCategory) == "table" then
        nameplateCategory.allowThresholdColors = nil
    end

    local playerAuraCategory = categories[C.Categories.PlayerAura]
    if type(playerAuraCategory) == "table" then
        playerAuraCategory.compactDurationText = nil
        for i = 1, #PLAYER_AURA_STYLE_FIELDS do
            playerAuraCategory[PLAYER_AURA_STYLE_FIELDS[i]] = nil
        end
        playerAuraCategory.textAnchor = nil
        playerAuraCategory.allowThresholdColors = nil
        playerAuraCategory.auraCdTextOnlyMine = nil
    end

end

local function CleanupObsoleteDatabaseFields(db, profile)
    if type(db) == "table" and type(db.global) == "table" then
        db.global.versionAlertsShown = nil
    end

    if profile then
        CleanupObsoleteProfileFields(profile)
    end
end

MCE.DurationTextColorDefaults = DurationTextColorDefaults
MCE.EnsureDurationTextColorConfig = EnsureDurationTextColorConfig

local cooldownManagerDefaults = CategoryDefaults(C.Categories.CooldownManager, false, 18)
cooldownManagerDefaults.essentialFontSize = C.Defaults.CooldownManager.EssentialFontSize
cooldownManagerDefaults.utilityFontSize = C.Defaults.CooldownManager.UtilityFontSize
cooldownManagerDefaults.buffIconFontSize = C.Defaults.CooldownManager.BuffIconFontSize
cooldownManagerDefaults.essentialStackSize = C.Defaults.CooldownManager.EssentialStackSize
cooldownManagerDefaults.utilityStackSize = C.Defaults.CooldownManager.UtilityStackSize
cooldownManagerDefaults.buffIconStackSize = C.Defaults.CooldownManager.BuffIconStackSize
cooldownManagerDefaults.auraColorEnabled = C.Defaults.CooldownManager.AuraColorEnabled
cooldownManagerDefaults.auraColor = CopyTable(C.Defaults.CooldownManager.AuraColor)

local healerCCDefaults = CategoryDefaults(C.Categories.HealerCC, false, 18)
healerCCDefaults.allowThresholdColors = nil

local function EnsureCooldownManagerConfig(config)
    if type(config) ~= "table" then
        return CopyTable(cooldownManagerDefaults)
    end

    if type(config.essentialFontSize) ~= "number" then
        config.essentialFontSize = C.Defaults.CooldownManager.EssentialFontSize
    end
    if type(config.utilityFontSize) ~= "number" then
        config.utilityFontSize = C.Defaults.CooldownManager.UtilityFontSize
    end
    if type(config.buffIconFontSize) ~= "number" then
        config.buffIconFontSize = C.Defaults.CooldownManager.BuffIconFontSize
    end
    local legacyStackSize = type(config.stackSize) == "number" and config.stackSize or nil
    if type(config.essentialStackSize) ~= "number" then
        config.essentialStackSize = legacyStackSize or C.Defaults.CooldownManager.EssentialStackSize
    end
    if type(config.utilityStackSize) ~= "number" then
        config.utilityStackSize = legacyStackSize or C.Defaults.CooldownManager.UtilityStackSize
    end
    if type(config.buffIconStackSize) ~= "number" then
        config.buffIconStackSize = legacyStackSize or C.Defaults.CooldownManager.BuffIconStackSize
    end
    if config.auraColorEnabled == nil then
        config.auraColorEnabled = C.Defaults.CooldownManager.AuraColorEnabled
    end
    if type(config.auraColor) ~= "table" then
        config.auraColor = CopyTable(C.Defaults.CooldownManager.AuraColor)
    else
        local defaultColor = C.Defaults.CooldownManager.AuraColor
        if config.auraColor.r == nil then config.auraColor.r = defaultColor.r end
        if config.auraColor.g == nil then config.auraColor.g = defaultColor.g end
        if config.auraColor.b == nil then config.auraColor.b = defaultColor.b end
        if config.auraColor.a == nil then config.auraColor.a = defaultColor.a end
    end

    return config
end

local miniAurasDefaults = CategoryDefaults(C.Categories.MiniAuras, false, 18)
miniAurasDefaults.allowThresholdColors = nil
miniAurasDefaults.ccFontSize = C.Defaults.MiniAuras.CCFontSize
miniAurasDefaults.ccHideCountdownNumbers = C.Defaults.MiniAuras.CCHideCountdownNumbers
miniAurasDefaults.ccHideSwipe = C.Defaults.MiniAuras.CCHideSwipe
miniAurasDefaults.raidFrameAuraFontSize = C.Defaults.MiniAuras.RaidFrameAuraFontSize
miniAurasDefaults.raidFrameAuraHideCountdownNumbers = C.Defaults.MiniAuras.RaidFrameAuraHideCountdownNumbers
miniAurasDefaults.raidFrameAuraHideSwipe = C.Defaults.MiniAuras.RaidFrameAuraHideSwipe
miniAurasDefaults.portraitFontSize = C.Defaults.MiniAuras.PortraitFontSize
miniAurasDefaults.portraitHideCountdownNumbers = C.Defaults.MiniAuras.PortraitHideCountdownNumbers
miniAurasDefaults.portraitHideSwipe = C.Defaults.MiniAuras.PortraitHideSwipe
miniAurasDefaults.overlayFontSize = C.Defaults.MiniAuras.OverlayFontSize
miniAurasDefaults.overlayHideCountdownNumbers = C.Defaults.MiniAuras.OverlayHideCountdownNumbers
miniAurasDefaults.overlayHideSwipe = C.Defaults.MiniAuras.OverlayHideSwipe
miniAurasDefaults.swipeAlpha = C.Defaults.MiniAuras.SwipeAlpha

local function EnsureMiniAurasConfig(config)
    if type(config) ~= "table" then
        return CopyTable(miniAurasDefaults)
    end

    -- MiniAuras owns countdown threshold colors through its Misc settings.
    -- Remove the former MiniCE override from existing profiles.
    config.allowThresholdColors = nil

    if type(config.raidFrameAuraFontSize) ~= "number" then
        config.raidFrameAuraFontSize = type(config.friendlyCdFontSize) == "number"
            and config.friendlyCdFontSize or C.Defaults.MiniAuras.RaidFrameAuraFontSize
    end
    if config.raidFrameAuraHideCountdownNumbers == nil then
        if config.friendlyCdHideCountdownNumbers ~= nil then
            config.raidFrameAuraHideCountdownNumbers = config.friendlyCdHideCountdownNumbers
        else
            config.raidFrameAuraHideCountdownNumbers = C.Defaults.MiniAuras.RaidFrameAuraHideCountdownNumbers
        end
    end
    if config.raidFrameAuraHideSwipe == nil then
        if config.friendlyCdHideSwipe ~= nil then
            config.raidFrameAuraHideSwipe = config.friendlyCdHideSwipe
        else
            config.raidFrameAuraHideSwipe = C.Defaults.MiniAuras.RaidFrameAuraHideSwipe
        end
    end

    if type(config.swipeAlpha) ~= "number" then
        config.swipeAlpha = C.Defaults.MiniAuras.SwipeAlpha
    end

    -- MiniAuras 12.1 renders this label inside restricted AuraButtons, so the
    -- former MiniCC warning-text override is no longer a safe integration.
    config.healerWarningTextColor = nil

    return config
end

local sArenaDefaults = CategoryDefaults(C.Categories.SArena, false, 18)
sArenaDefaults.classIconFontSize = C.Defaults.SArena.ClassIconFontSize
sArenaDefaults.drFontSize = C.Defaults.SArena.DRFontSize
sArenaDefaults.trinketRacialFontSize = C.Defaults.SArena.TrinketRacialFontSize

local tellMeWhenDefaults = CategoryDefaults(C.Categories.TellMeWhen, false, C.Defaults.TellMeWhen.FontSize)

-- MyDRs draws its own DR state label on the cooldown, so this category never
-- gains a stack section; only the countdown text and swipe edge are MiniCE's.
local myDRsDefaults = CategoryDefaults(C.Categories.MyDRs, false, C.Defaults.MyDRs.FontSize)
myDRsDefaults.swipeAlpha = C.Defaults.MyDRs.SwipeAlpha
myDRsDefaults.reverseSwipe = C.Defaults.MyDRs.ReverseSwipe

-- Shackled draws its own remaining-time FontString beside the cooldown widget
-- (Blizzard's own countdown numbers are explicitly disabled), so like MyDRs
-- this category never gains a stack section -- Shackled icons carry no charge
-- or application count.
local shackledDefaults = CategoryDefaults(C.Categories.Shackled, false, C.Defaults.Shackled.FontSize)
shackledDefaults.swipeAlpha = C.Defaults.Shackled.SwipeAlpha
shackledDefaults.reverseSwipe = C.Defaults.Shackled.ReverseSwipe

MCE.defaults = {
    profile = {
        abbrevThreshold = C.Options.DefaultAbbrevThreshold,
        countdownMillisecondsThreshold = C.Options.DefaultMillisecondsThreshold,
        shinyAurasAdapterEnabled = true,
        dominosAdapterEnabled = true,
        bartender4AdapterEnabled = true,
        elvuiAdapterEnabled = true,
        durationTextColors = defaultDurationTextColors,
        categories = {
            [C.Categories.Actionbar] = actionbarDefaults,
            [C.Categories.Nameplate] = nameplateDefaults,
            [C.Categories.Unitframe] = unitframeDefaults,
            [C.Categories.PlayerAura] = playerAuraDefaults,
            [C.Categories.CooldownManager] = cooldownManagerDefaults,
            [C.Categories.HealerCC] = healerCCDefaults,
            [C.Categories.MiniAuras] = miniAurasDefaults,
            [C.Categories.MyDRs] = myDRsDefaults,
            [C.Categories.SArena] = sArenaDefaults,
            [C.Categories.TellMeWhen] = tellMeWhenDefaults,
            [C.Categories.Shackled] = shackledDefaults,
        },
    },
}

function MCE:UpgradeProfile()
    local profile = self.db and self.db.profile
    if not profile then return end

    CleanupObsoleteDatabaseFields(self.db, profile)

    if profile.shinyAurasAdapterEnabled == nil then
        profile.shinyAurasAdapterEnabled = true
    end

    if profile.dominosAdapterEnabled == nil then
        profile.dominosAdapterEnabled = true
    end

    if profile.bartender4AdapterEnabled == nil then
        profile.bartender4AdapterEnabled = true
    end

    if profile.elvuiAdapterEnabled == nil then
        profile.elvuiAdapterEnabled = true
    end

    if type(profile.countdownMillisecondsThreshold) ~= "number" then
        profile.countdownMillisecondsThreshold = C.Options.DefaultMillisecondsThreshold
    end

    if not profile.durationTextColors then
        profile.durationTextColors = CopyTable(defaultDurationTextColors)
    end

    if type(profile.categories) ~= "table" then
        profile.categories = CopyTable(self.defaults.profile.categories)
    end

    -- Preserve existing MiniCC integration settings after the addon/category
    -- rename. rawget avoids mistaking AceDB's default-backed MiniAuras table for
    -- an explicitly saved profile value.
    local legacyMiniCCConfig = rawget(profile.categories, "minicc")
    if type(legacyMiniCCConfig) == "table"
        and rawget(profile.categories, C.Categories.MiniAuras) == nil then
        profile.categories[C.Categories.MiniAuras] = CopyTable(legacyMiniCCConfig)
    end
    profile.categories.minicc = nil

    if type(profile.categories[C.Categories.HealerCC]) ~= "table" then
        profile.categories[C.Categories.HealerCC] = CopyTable(healerCCDefaults)
    end

    profile.categories[C.Categories.Actionbar] =
        EnsureActionbarConfig(profile.categories[C.Categories.Actionbar])
    profile.categories[C.Categories.HealerCC].allowThresholdColors = nil

    if profile.categories[C.Categories.HealerCC].healerCCThresholdColorsInitialized == true then
        profile.categories[C.Categories.HealerCC].healerCCThresholdColorsInitialized = nil
    end

    profile.categories[C.Categories.CooldownManager] =
        EnsureCooldownManagerConfig(profile.categories[C.Categories.CooldownManager])
    profile.categories[C.Categories.MiniAuras] =
        EnsureMiniAurasConfig(profile.categories[C.Categories.MiniAuras])
    profile.categories[C.Categories.PlayerAura] =
        EnsurePlayerAuraConfig(profile.categories[C.Categories.PlayerAura])

    EnsureDurationTextColorConfig(profile.durationTextColors)
end

function MCE:HandleProfileUpdated()
    if self.suppressProfileCallbacks then return end

    self:UpgradeProfile()
    self:ForceUpdateAll(true)
    AceConfigRegistry:NotifyChange(addonName)
end

function MCE:ADDON_LOADED(_, loadedAddonName)
    self:SetAddonLoadState(loadedAddonName, true)
    if IsOwnershipProviderAddon(loadedAddonName) then
        self:InvalidateOwnership()
    end
    if loadedAddonName == C.Addon.BetterBlizzFramesName then
        self:HandleBetterBlizzFramesUnitFrameConflict()
    elseif loadedAddonName == C.Addon.BetterBlizzPlatesName then
        self:HandleBetterBlizzPlatesNameplateConflict()
    end
end

-- =========================================================================
-- ACE LIFECYCLE
-- =========================================================================

function MCE:OnInitialize()
    self:RegisterEvent("ADDON_LOADED")
    self.db = LibStub("AceDB-3.0"):New(C.Addon.SavedVariables, self.defaults, true)
    self.db.RegisterCallback(self, "OnProfileChanged", "HandleProfileUpdated")
    self.db.RegisterCallback(self, "OnProfileCopied", "HandleProfileUpdated")
    self.db.RegisterCallback(self, "OnProfileReset", "HandleProfileUpdated")
    self:UpgradeProfile()
    self.pendingOptionRefresh = nil
    self.pendingOptionRefreshFullScan = false
    self.reloadRequired = false
    self.reloadChangeVersion = 0
    self.reloadPromptedVersion = 0
    self.reloadPromptQueued = false
    self.visitedBlizzardOptions = false
    self:EnsureReloadPromptDialog()
    self:EnsureOptionsCloseHooks()

    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self.GetOptions)

    do
        local status = AceConfigDialog:GetStatusTable(addonName)
        status.width = math.max(status.width or 0, C.Options.FrameWidth)
        status.height = math.max(status.height or 0, C.Options.FrameHeight)
        status.groups = status.groups or {}
        status.groups.treewidth = math.max(status.groups.treewidth or 0, C.Options.TreeWidth)
        status.groups.treesizable = true
    end

    self.optionsFrame = self:RegisterBlizzardOptionsPanel(
        AceConfigDialog:AddToBlizOptions(addonName, C.Addon.ShortName, nil, "general")
    )
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Action Bars"], C.Addon.ShortName, C.Categories.Actionbar))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Nameplates"], C.Addon.ShortName, C.Categories.Nameplate))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Unit Frames"], C.Addon.ShortName, C.Categories.Unitframe))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Player Auras"], C.Addon.ShortName, C.Categories.PlayerAura))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Party / Raid Frames"], C.Addon.ShortName, C.Categories.PartyRaidRetired))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["CooldownManager"], C.Addon.ShortName, C.Categories.CooldownManager))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["HealerCC"], C.Addon.ShortName, C.Categories.HealerCC))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["MiniAuras"], C.Addon.ShortName, C.Categories.MiniAuras))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["MyDRs"], C.Addon.ShortName, C.Categories.MyDRs))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["sArena"], C.Addon.ShortName, C.Categories.SArena))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["TellMeWhen"], C.Addon.ShortName, C.Categories.TellMeWhen))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Shackled"], C.Addon.ShortName, C.Categories.Shackled))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Profiles"], C.Addon.ShortName, "profiles"))
    self:RegisterBlizzardOptionsPanel(AceConfigDialog:AddToBlizOptions(addonName, L["Help & Support"], C.Addon.ShortName, "help"))

    for i = 1, #C.Addon.SlashCommands do
        self:RegisterChatCommand(C.Addon.SlashCommands[i], "SlashCommand")
    end

    if self:IsBetterBlizzFramesAvailable() then
        self:WarnBetterBlizzFramesUnitFrameConflict()
    end
    if self:IsBetterBlizzPlatesAvailable() then
        self:WarnBetterBlizzPlatesNameplateConflict()
    end
end

function MCE:OnDisable()
    self:CancelDebouncedOptionRefresh()
end

function MCE:SlashCommand(input)
    if AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames[addonName] then
        AceConfigDialog:Close(addonName)
        return
    end

    AceConfigDialog:Open(addonName)
end

--- Public API – delegates to Styler module.
function MCE:CancelDebouncedOptionRefresh()
    local pending = self.pendingOptionRefresh
    if pending then
        pending:Cancel()
        self.pendingOptionRefresh = nil
    end

    self.pendingOptionRefreshFullScan = false
end

function MCE:RequestDebouncedOptionRefresh(fullScan, delay)
    self.pendingOptionRefreshFullScan = self.pendingOptionRefreshFullScan or fullScan or false

    local pending = self.pendingOptionRefresh
    if pending then
        pending:Cancel()
    end

    self.pendingOptionRefresh = C_Timer_NewTimer(delay or OPTION_SLIDER_DEBOUNCE_DELAY, function()
        local needsFullScan = self.pendingOptionRefreshFullScan
        self.pendingOptionRefresh = nil
        self.pendingOptionRefreshFullScan = false
        self:ForceUpdateAll(needsFullScan)
    end)
end

function MCE:ForceUpdateAll(fullScan)
    self:CancelDebouncedOptionRefresh()
    self:GetModule("Styler"):ForceUpdateAll(fullScan)

    local playerAuraStyler = self:GetModule("PlayerAuraStyler", true)
    if playerAuraStyler and playerAuraStyler.ForceUpdateAll then
        playerAuraStyler:ForceUpdateAll()
    end
end
