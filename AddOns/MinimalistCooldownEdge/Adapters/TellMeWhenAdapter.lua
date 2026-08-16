-- Adapters/TellMeWhenAdapter.lua - TellMeWhen cooldown discovery
--
-- TellMeWhen 12.1 has two cooldown implementations:
--   Legacy icon types: IconModule_CooldownSweep cooldowns parented to the icon.
--   Combat-ready auras: an anonymous button.tmwCooldown parented to a Blizzard
--                       AuraButton owned by IconModule_AuraContainer.
-- AuraButtons become inaccessible to addon code after their initialization
-- callback when aura data is secret, so native cooldowns must also be claimed
-- and styled from SetDurationCooldown while that callback is still running.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("TellMeWhenAdapter")

local pairs, pcall, type = pairs, pcall, type
local strfind, strmatch = string.find, string.match
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local CATEGORY = C.Categories
local CLASSIFIER_CONSTANTS = C.Classifier
local TMW = C.Adapter.TellMeWhen

local Registry
local frameState = addon.frameState
local timerOptions = setmetatable({}, addon.weakMeta)
local initializationStyling = setmetatable({}, addon.weakMeta)
local cooldownOptionHooksInstalled = {}
local durationCooldownHookInstalled = false
local cooldownProbe
local customAuraButtonAPI
local InstallNativeAuraButtonHook

local function EnsureRegistry()
    if not Registry then
        Registry = MCE:GetModule("TargetRegistry", true)
    end
    return Registry
end

local function IsTellMeWhenIconFrame(frame)
    local name = MCE:GetFrameName(frame)
    return type(name) == "string"
        and (strmatch(name, "^TellMeWhen_Group%d+_Icon%d+$") ~= nil
            or strmatch(name, "^TellMeWhen_GlobalGroup%d+_Icon%d+$") ~= nil)
end

local function IsTellMeWhenCooldownName(name)
    name = MCE:GetNonSecretString(name)
    return name ~= nil
        and strfind(name, CLASSIFIER_CONSTANTS.TellMeWhenNamePrefix, 1, true) == 1
        and strfind(name, TMW.CooldownNameFragment, 1, true) ~= nil
end

local function GetParentSafe(frame)
    local getParent = MCE:SafeTableGet(frame, "GetParent")
    if type(getParent) ~= "function" then return nil end

    local ok, parent = pcall(getParent, frame)
    if not ok or not MCE:CanUseFrameAsTableKey(parent) then return nil end

    return parent
end

local function GetTellMeWhenAuraButton(cooldown)
    if not MCE:CanUseFrameAsTableKey(cooldown) then return nil end

    local owner = GetParentSafe(cooldown)
    if not owner then return nil end

    return MCE:SafeTableGet(owner, "tmwCooldown") == cooldown and owner or nil
end

local function IsTellMeWhenCooldown(cooldown)
    if not MCE:IsTellMeWhenAvailable() or not cooldown or MCE:IsForbidden(cooldown) then
        return false
    end

    if cooldown.tmwMainCd or cooldown.tmwChargeCd then
        return true
    end

    if IsTellMeWhenCooldownName(MCE:GetFrameName(cooldown)) then
        return true
    end

    local owner = GetParentSafe(cooldown)
    if not owner then return false end

    return IsTellMeWhenIconFrame(owner)
        or MCE:SafeTableGet(owner, "tmwCooldown") == cooldown
end

local function ReadAccessibleBoolean(object, methodName)
    local method = object and MCE:SafeTableGet(object, methodName) or nil
    if type(method) ~= "function" then return nil end

    local ok, value = pcall(method, object)
    if not ok
       or type(value) ~= "boolean"
       or MCE:IsSecretValue(value)
       or not addon.CanAccessAllValues(value) then
        return nil
    end
    return value
end

local function GetOrCreateTimerOptions(cooldown)
    local options = timerOptions[cooldown]
    if not options then
        options = {}
        timerOptions[cooldown] = options
    end
    return options
end

local function CaptureCurrentTimerOptions(cooldown)
    if not MCE:CanUseFrameAsTableKey(cooldown) then return nil end

    local options = GetOrCreateTimerOptions(cooldown)
    local drawSwipe = ReadAccessibleBoolean(cooldown, "GetDrawSwipe")
    local hideNumbers = ReadAccessibleBoolean(cooldown, "GetHideCountdownNumbers")

    if drawSwipe ~= nil then options.drawSwipe = drawSwipe end
    if hideNumbers ~= nil then options.hideCountdownNumbers = hideNumbers end
    return options
end

local function RegisterCooldown(cooldown)
    if IsTellMeWhenCooldown(cooldown) then
        local auraButton = GetTellMeWhenAuraButton(cooldown)
        if auraButton then
            InstallNativeAuraButtonHook(auraButton)
        end
        CaptureCurrentTimerOptions(cooldown)
        local registry = EnsureRegistry()
        if registry then
            registry:Register(cooldown, CATEGORY.TellMeWhen)
            return true
        end
    end
    return false
end

local function RegisterIconCooldowns(icon)
    if not icon or MCE:IsForbidden(icon) then return end

    local modules = icon.Modules
    local cooldownModule = modules and modules.IconModule_CooldownSweep or nil
    if cooldownModule then
        RegisterCooldown(cooldownModule.cooldown)
        RegisterCooldown(cooldownModule.cooldown2)
    else
        RegisterCooldown(icon.cooldown or icon.Cooldown)
        RegisterCooldown(icon.chargeCooldown or icon.ChargeCooldown)
    end

    local auraContainerModule = modules and modules.IconModule_AuraContainer or nil
    local auraButtons = auraContainerModule and auraContainerModule.buttons or nil
    if type(auraButtons) == "table" then
        for button in pairs(auraButtons) do
            if MCE:CanUseFrameAsTableKey(button) then
                RegisterCooldown(MCE:SafeTableGet(button, "tmwCooldown"))
            end
        end
    end
end

local function ApplyStyleImmediately(cooldown)
    if initializationStyling[cooldown] then return end
    local styleEngine = MCE:GetModule("StyleEngine", true)
    if not (styleEngine and styleEngine:IsEnabled()) then return end

    initializationStyling[cooldown] = true
    pcall(styleEngine.ApplyStyle, styleEngine, cooldown, CATEGORY.TellMeWhen)
    initializationStyling[cooldown] = nil
end

local function StyleNativeAuraCooldown(cooldown)
    if not MCE:IsTellMeWhenAvailable()
       or not GetTellMeWhenAuraButton(cooldown)
       or not RegisterCooldown(cooldown) then
        return
    end

    ApplyStyleImmediately(cooldown)
end

local function GetCooldownAPI()
    if cooldownProbe then
        local meta = getmetatable(cooldownProbe)
        return meta and meta.__index or nil
    end
    if type(CreateFrame) ~= "function" then return nil end

    local createOk, probe = pcall(CreateFrame, "Cooldown")
    if not createOk or not probe then return nil end

    cooldownProbe = probe
    local meta = getmetatable(probe)
    return meta and meta.__index or nil
end

local function CaptureTimerOption(cooldown, optionKey, value, suppressStateKey)
    local state = MCE:SafeTableGet(frameState, cooldown)
    if state and state[suppressStateKey] then return end
    if type(value) ~= "boolean"
       or MCE:IsSecretValue(value)
       or not addon.CanAccessAllValues(value)
       or not IsTellMeWhenCooldown(cooldown) then
        return
    end

    local options = CaptureCurrentTimerOptions(cooldown)
        or GetOrCreateTimerOptions(cooldown)
    options[optionKey] = value

    if RegisterCooldown(cooldown) then
        ApplyStyleImmediately(cooldown)
    end
end

local function InstallTimerOptionHooks()
    local api = GetCooldownAPI()
    if type(api) ~= "table" then return end

    local hooks = {
        SetDrawSwipe = { option = "drawSwipe", suppress = "suppressSwipeDraw" },
        SetHideCountdownNumbers = {
            option = "hideCountdownNumbers",
            suppress = "suppressHideNums",
        },
    }

    for methodName, info in pairs(hooks) do
        if not cooldownOptionHooksInstalled[methodName]
           and type(MCE:SafeTableGet(api, methodName)) == "function" then
            local optionKey = info.option
            local suppressStateKey = info.suppress
            local hookOk = pcall(hooksecurefunc, api, methodName, function(cooldown, value)
                CaptureTimerOption(cooldown, optionKey, value, suppressStateKey)
            end)
            cooldownOptionHooksInstalled[methodName] = hookOk
        end
    end
end

local function GetCustomAuraButtonAPI(button)
    if customAuraButtonAPI then return customAuraButtonAPI end
    if not MCE:CanUseFrameAsTableKey(button) then return nil end

    local metaOk, meta = pcall(getmetatable, button)
    if not metaOk or type(meta) ~= "table" then return nil end
    local api = MCE:SafeTableGet(meta, "__index")
    if type(api) ~= "table"
       or type(MCE:SafeTableGet(api, "SetDurationCooldown")) ~= "function" then
        return nil
    end

    customAuraButtonAPI = api
    return customAuraButtonAPI
end

InstallNativeAuraButtonHook = function(button)
    if durationCooldownHookInstalled then return end

    local api = GetCustomAuraButtonAPI(button)
    local setDurationCooldown = api and MCE:SafeTableGet(api, "SetDurationCooldown") or nil
    if type(setDurationCooldown) ~= "function" then return end

    local hookOk = pcall(hooksecurefunc, api, "SetDurationCooldown", function(button, cooldown)
        if MCE:SafeTableGet(button, "tmwCooldown") == cooldown then
            StyleNativeAuraCooldown(cooldown)
        end
    end)
    durationCooldownHookInstalled = hookOk
end

local function ScanDomainGroups(groups)
    if type(groups) ~= "table" then return end

    for _, group in pairs(groups) do
        if group and not MCE:IsForbidden(group) then
            local numIcons = group.numIcons or #group
            for iconIndex = 1, numIcons do
                RegisterIconCooldowns(group[iconIndex])
            end
        end
    end
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.TellMeWhen, self)
    InstallTimerOptionHooks()
end

function Adapter:Rebuild()
    if not MCE:IsTellMeWhenAvailable() then return end

    local tellMeWhen = _G.TMW or _G.TellMeWhen
    if type(tellMeWhen) ~= "table" then return end

    for i = 1, #TMW.DomainKeys do
        ScanDomainGroups(tellMeWhen[TMW.DomainKeys[i]])
    end
end

function Adapter:TryClaim(cooldown)
    if IsTellMeWhenCooldown(cooldown) then
        CaptureCurrentTimerOptions(cooldown)
        return CATEGORY.TellMeWhen
    end
    return nil
end

function Adapter:GetTimerOption(cooldown, optionKey)
    local options = MCE:SafeTableGet(timerOptions, cooldown)
    local value
    if type(options) == "table" then
        value = options[optionKey]
    end
    if type(value) == "boolean" then
        return value
    end
    return nil
end

-- The ordinary Cooldown option hooks and Rebuild discover TMW's public output
-- cooldowns. Their genuine owner buttons then bootstrap the shared AuraButton
-- hook without creating a restricted Blizzard template.
InstallTimerOptionHooks()
