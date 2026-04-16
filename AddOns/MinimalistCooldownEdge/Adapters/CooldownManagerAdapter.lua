-- Adapters/CooldownManagerAdapter.lua – CooldownManager viewer cooldowns

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("CooldownManagerAdapter")

local CATEGORY = C.Categories
local VIEWER_TYPE = C.CooldownManagerViewers
local CM = C.Adapter.CooldownManager
local VIEWER_PATTERNS = C.Classifier.CooldownManagerViewerPatterns

local hooksecurefunc = hooksecurefunc
local C_Timer_After = C_Timer.After
local GetTime = GetTime
local pairs = pairs
local setmetatable = setmetatable

local weakMeta = addon.weakMeta
local frameState = addon.frameState

local Registry, HookBridge, DurationColor, BatchProcessor

local hookedCooldowns = setmetatable({}, weakMeta)
local hookedBuffIconOwners = setmetatable({}, weakMeta)
local hookedViewers = setmetatable({}, weakMeta)
local queuedBuffIconOwners = setmetatable({}, weakMeta)
local queuedViewerRefreshes = setmetatable({}, weakMeta)
local RegisterCooldown

local VIEWER_GLOBALS = {
    [VIEWER_PATTERNS.Essential] = VIEWER_TYPE.Essential,
    [VIEWER_PATTERNS.Utility] = VIEWER_TYPE.Utility,
    [VIEWER_PATTERNS.BuffIcon] = VIEWER_TYPE.BuffIcon,
}

local function EnsureDependencies()
    if not Registry then
        Registry = MCE:GetModule("TargetRegistry")
    end
    if not HookBridge then
        HookBridge = MCE:GetModule("HookBridge")
    end
    if not DurationColor then
        DurationColor = MCE:GetModule("DurationColorController")
    end
    if not BatchProcessor then
        BatchProcessor = MCE:GetModule("BatchProcessor")
    end

    return Registry ~= nil and HookBridge ~= nil
end

function Adapter:OnEnable()
    EnsureDependencies()
    Registry:RegisterAdapter(CATEGORY.CooldownManager, self)
end

local function MatchesViewerPrefix(name, viewerName)
    return type(name) == "string"
        and viewerName ~= nil
        and name:sub(1, #viewerName) == viewerName
end

-- Mirror tullaCTC's MatchName("^ViewerName") behavior for viewer detection.
local function DetermineViewerType(name)
    if MatchesViewerPrefix(name, VIEWER_PATTERNS.Essential) then return VIEWER_TYPE.Essential end
    if MatchesViewerPrefix(name, VIEWER_PATTERNS.Utility) then return VIEWER_TYPE.Utility end
    if MatchesViewerPrefix(name, VIEWER_PATTERNS.BuffIcon) then return VIEWER_TYPE.BuffIcon end
    return nil
end

-- Walk from the cooldown itself and stop at the first named ancestor, just
-- like tullaCTC.MatchName does for its built-in viewer rules.
local function ResolveViewerType(cooldown)
    local current = cooldown
    for _ = 1, CM.MaxAncestorDepth do
        if not current then break end

        local name = MCE:GetFrameName(current)
        if name then
            return DetermineViewerType(name)
        end

        current = current.GetParent and current:GetParent() or nil
    end

    -- Structural fallback for unnamed BuffIcon children.
    local parent = cooldown.GetParent and cooldown:GetParent() or nil
    if parent and parent.Applications and parent.Applications.Applications then
        return VIEWER_TYPE.BuffIcon
    end

    return nil
end

local function IsLiveHookViewerType(viewerType)
    return viewerType == VIEWER_TYPE.Essential or viewerType == VIEWER_TYPE.Utility
end

local function InvalidateCooldownState(cooldown)
    local fs = cooldown and frameState[cooldown] or nil
    if not fs then
        return
    end

    fs.durationObject = nil
    fs.forceTextRegionRefresh = true
    fs.appliedTextColor = nil
    fs.contextResolved = nil
    fs.liveNameplateAuraContextResolved = nil
    fs.liveNameplateAuraContext = nil
    fs.compactPartyAuraTypeResolved = nil
    fs.compactPartyAuraType = nil
end

local function ForwardCooldownUpdate(cooldown, durationObject)
    if not EnsureDependencies() then
        return
    end

    HookBridge:HandleCooldownUpdate(cooldown, durationObject)
end

local function ResyncCooldown(cooldown)
    if not cooldown or MCE:IsForbidden(cooldown) then
        return
    end
    if not EnsureDependencies() then
        return
    end

    InvalidateCooldownState(cooldown)
    HookBridge:HandleCooldownUpdate(cooldown, nil)
end

local function QueueBuffIconOwnerResync(owner)
    if not owner or MCE:IsForbidden(owner) then
        return
    end
    if queuedBuffIconOwners[owner] then
        return
    end

    queuedBuffIconOwners[owner] = true

    C_Timer_After(0, function()
        queuedBuffIconOwners[owner] = nil

        if not owner or MCE:IsForbidden(owner) then
            return
        end

        local cooldown = owner.cooldown or owner.Cooldown
        if not cooldown or MCE:IsForbidden(cooldown) then
            return
        end

        RegisterCooldown(cooldown, VIEWER_TYPE.BuffIcon)
        ResyncCooldown(cooldown)
    end)
end

local function ShouldHookBuffIconOwnerStateChanges()
    -- These owner aura/state callbacks are only needed for CMC BuffIcon recycling.
    return MCE:IsCooldownManagerCenteredAvailable()
end

local function HookBuffIconOwner(owner)
    if not ShouldHookBuffIconOwnerStateChanges() then
        return
    end
    if not owner or MCE:IsForbidden(owner) then
        return
    end
    if hookedBuffIconOwners[owner] then
        return
    end

    hookedBuffIconOwners[owner] = true

    if type(owner.OnActiveStateChanged) == "function" then
        hooksecurefunc(owner, "OnActiveStateChanged", function(self)
            QueueBuffIconOwnerResync(self)
        end)
    end

    if type(owner.OnUnitAuraAddedEvent) == "function" then
        hooksecurefunc(owner, "OnUnitAuraAddedEvent", function(self)
            QueueBuffIconOwnerResync(self)
        end)
    end

    if type(owner.OnUnitAuraRemovedEvent) == "function" then
        hooksecurefunc(owner, "OnUnitAuraRemovedEvent", function(self)
            QueueBuffIconOwnerResync(self)
        end)
    end
end

local function HookCooldownInstance(cooldown, viewerType)
    if not IsLiveHookViewerType(viewerType) then
        return
    end
    if not cooldown or MCE:IsForbidden(cooldown) then
        return
    end
    if hookedCooldowns[cooldown] then
        return
    end

    hookedCooldowns[cooldown] = true

    if type(cooldown.SetCooldown) == "function" then
        hooksecurefunc(cooldown, "SetCooldown", function(self, startTime, duration, modRate)
            local durationObject = DurationColor
                and DurationColor:CreateDurationObjectFromCooldownArgs(startTime, duration, modRate)
                or nil
            ForwardCooldownUpdate(self, durationObject)
        end)
    end

    if type(cooldown.SetCooldownDuration) == "function" then
        hooksecurefunc(cooldown, "SetCooldownDuration", function(self, duration, modRate)
            local durationObject
            if DurationColor
               and type(duration) == "number"
               and duration > 0 then
                durationObject = DurationColor:CreateDurationFromEndTime(GetTime() + duration, duration, modRate or 1)
            end
            ForwardCooldownUpdate(self, durationObject)
        end)
    end

    if type(cooldown.SetCooldownFromDurationObject) == "function" then
        hooksecurefunc(cooldown, "SetCooldownFromDurationObject", function(self, durationObject)
            ForwardCooldownUpdate(self, durationObject)
        end)
    end

    if type(cooldown.SetCooldownFromExpirationTime) == "function" then
        hooksecurefunc(cooldown, "SetCooldownFromExpirationTime", function(self, expirationTime, duration, modRate)
            local durationObject = DurationColor
                and DurationColor:CreateDurationObjectFromExpirationArgs(expirationTime, duration, modRate)
                or nil
            ForwardCooldownUpdate(self, durationObject)
        end)
    end

    if type(cooldown.Clear) == "function" then
        hooksecurefunc(cooldown, "Clear", function(self)
            if EnsureDependencies() then
                HookBridge:HandleCooldownClear(self)
            end
        end)
    end
end

RegisterCooldown = function(cooldown, viewerType)
    if not cooldown or MCE:IsForbidden(cooldown) then
        return
    end
    if not EnsureDependencies() then
        return
    end

    Registry:Register(cooldown, CATEGORY.CooldownManager, viewerType)
    HookCooldownInstance(cooldown, viewerType)
end

local function ForEachViewerCooldown(viewerFrame, viewerType, callback)
    if not viewerFrame or MCE:IsForbidden(viewerFrame) then return end
    if not viewerFrame.GetChildren then return end

    local children = { viewerFrame:GetChildren() }
    for i = 1, #children do
        local child = children[i]
        if child and not MCE:IsForbidden(child) then
            if viewerType == VIEWER_TYPE.BuffIcon then
                HookBuffIconOwner(child)
            end

            local cd = child.cooldown or child.Cooldown
            if cd then
                callback(cd, viewerType)
            end

            if child.GetChildren then
                local grandchildren = { child:GetChildren() }
                for j = 1, #grandchildren do
                    local gc = grandchildren[j]
                    if gc and gc.IsObjectType and gc:IsObjectType("Cooldown") then
                        callback(gc, viewerType)
                    end
                end
            end
        end
    end
end

local function ScanViewer(viewerFrame, viewerType)
    ForEachViewerCooldown(viewerFrame, viewerType, RegisterCooldown)
end

local function HookViewerRefresh(viewerFrame, viewerType)
    if not viewerFrame or MCE:IsForbidden(viewerFrame) then
        return
    end
    if hookedViewers[viewerFrame] then
        return
    end

    hookedViewers[viewerFrame] = true

    if type(viewerFrame.RefreshLayout) == "function" then
        hooksecurefunc(viewerFrame, "RefreshLayout", function(self)
            if queuedViewerRefreshes[self] then
                return
            end

            queuedViewerRefreshes[self] = true

            C_Timer_After(0, function()
                queuedViewerRefreshes[self] = nil

                if not self or MCE:IsForbidden(self) then
                    return
                end

                ScanViewer(self, viewerType)

                ForEachViewerCooldown(self, viewerType, function(cooldown)
                    ResyncCooldown(cooldown)
                end)
            end)
        end)
    end
end

local function HookKnownViewers()
    for viewerName, viewerType in pairs(VIEWER_GLOBALS) do
        local frame = _G[viewerName]
        if frame then
            HookViewerRefresh(frame, viewerType)
        end
    end
end

function Adapter:Rebuild()
    HookKnownViewers()

    for viewerName, viewerType in pairs(VIEWER_GLOBALS) do
        local frame = _G[viewerName]
        if frame then
            ScanViewer(frame, viewerType)
        end
    end
end

function Adapter:TryClaim(cooldown)
    if not cooldown then return nil end
    local viewerType = ResolveViewerType(cooldown)
    if viewerType then
        HookCooldownInstance(cooldown, viewerType)
        return CATEGORY.CooldownManager, viewerType
    end
    return nil
end
