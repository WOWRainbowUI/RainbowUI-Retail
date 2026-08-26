-- Adapters/UnitFrameAdapter.lua - Blizzard + third-party unit frame cooldowns
--
-- Retail 12.1 ownership model:
--   * Blizzard's AuraContainer owns aura tracking, assignment, visibility, and
--     icon/count/duration updates.
--   * MiniCE creates each Target/Focus host once, configures its immutable aura
--     groups once, and only reapplies layout when structural inputs change.
--   * MiniCE-owned AuraButtons capture their public output regions and receive
--     one structural style pass during initializeFrame.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("UnitFrameAdapter")

local ipairs, pairs, type, pcall = ipairs, pairs, type, pcall
local format = string.format
local strfind = string.find
local unpack = unpack
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local RunNextFrame = addon.RunNextFrame

local CATEGORY = C.Categories
local UF = C.Adapter.UnitFrames
local MINIAURAS_PREFIX = C.Classifier.MiniAurasNamePrefix
local frameState = addon.frameState

local CUSTOM_GROUPS = {
    {
        key = "BuffMine", helpful = true, isMine = true,
        maxCount = 32, size = 21, friendlyIndex = 1, hostileIndex = 3,
    },
    {
        key = "BuffOther", helpful = true, isMine = false,
        maxCount = 32, size = 17, friendlyIndex = 2, hostileIndex = 4,
    },
    {
        key = "DebuffMine", helpful = false, isMine = true,
        maxCount = 16, size = 21, friendlyIndex = 3, hostileIndex = 1,
    },
    {
        key = "DebuffOther", helpful = false, isMine = false,
        maxCount = 16, size = 17, friendlyIndex = 4, hostileIndex = 2,
    },
}

-- These tables are immutable after declaration and are never mutated after
-- being passed to AuraContainer. Structural changes therefore do not allocate
-- four new layout tables on every application.
for _, group in ipairs(CUSTOM_GROUPS) do
    group.friendlyLayout = {
        elementSpacing = 3,
        lineSpacing = 3,
        groupLineSpacing = 3,
        forceNewLine = group.key == "DebuffMine",
        elementWidth = group.size,
        elementHeight = group.size,
        layoutIndex = group.friendlyIndex,
    }
    group.hostileLayout = {
        elementSpacing = 3,
        lineSpacing = 3,
        groupLineSpacing = 3,
        forceNewLine = group.key == "BuffMine",
        elementWidth = group.size,
        elementHeight = group.size,
        layoutIndex = group.hostileIndex,
    }
end

local HOST_DEFINITIONS = {
    { name = "TargetFrame", unit = "target" },
    { name = "FocusFrame", unit = "focus" },
}

local CUSTOM_AURA_MEMBER_KEYS = {
    "MCEUnitFrameCooldown", "bbfCooldown", "cooldown", "Cooldown",
}

local Registry
local hostsByName = {}
local hookedRoots = setmetatable({}, addon.weakMeta)
local trackedCooldownMeta = setmetatable({}, addon.weakMeta)
local hookedCustomAuraButtons = setmetatable({}, addon.weakMeta)
local HookCustomAuraButtonBindings
local ProcessPendingHostWork
local SeedCastBarAnchor
local hostWorkScheduled = false

for _, definition in ipairs(HOST_DEFINITIONS) do
    local host = {
        name = definition.name,
        unit = definition.unit,
        groupCounts = {},
    }
    hostsByName[host.name] = host
end

local FALLBACK_UNIT_TOKENS = {
    player = true,
    target = true,
    focus = true,
    pet = true,
}
local UNIT_TOKEN_KEYS = { "unitid", "unitID", "unitToken", "displayedUnit", "unit" }

-- MiniAuras portrait cooldowns use the addon's stable frame-name prefix.
-- Skip them here so MiniAurasAdapter retains ownership.
local function IsMiniAurasFrame(frame)
    local name = MCE:GetFrameName(frame)
    return type(name) == "string" and strfind(name, MINIAURAS_PREFIX, 1, true) == 1
end

local function SafeCall(object, methodName, ...)
    local method = MCE:SafeTableGet(object, methodName)
    if type(method) ~= "function" then
        return false
    end
    return pcall(method, object, ...)
end

local function GetAccessibleBoolean(value)
    if type(value) ~= "boolean"
       or MCE:IsSecretValue(value)
       or not addon.CanAccessAllValues(value) then
        return nil
    end
    return value == true
end

local function IsObjectTypeSafe(frame, objectType)
    local isObjectType = MCE:SafeTableGet(frame, "IsObjectType")
    if type(isObjectType) ~= "function" then
        return false
    end

    local ok, result = pcall(isObjectType, frame, objectType)
    if not ok or MCE:IsSecretValue(result) or not addon.CanAccessAllValues(result) then
        return false
    end

    return result == true
end

local function GetParentSafe(frame)
    local getParent = MCE:SafeTableGet(frame, "GetParent")
    if type(getParent) ~= "function" then
        return nil
    end

    local ok, parent = pcall(getParent, frame)
    if not ok or not MCE:CanUseFrameAsTableKey(parent) then
        return nil
    end

    return parent
end

local function GetCooldownCountdownText(cooldown)
    local getCountdownFontString = MCE:SafeTableGet(cooldown, "GetCountdownFontString")
    if type(getCountdownFontString) ~= "function" then
        return nil
    end

    local ok, countdownText = pcall(getCountdownFontString, cooldown)
    if not ok or not IsObjectTypeSafe(countdownText, "FontString") then
        return nil
    end

    return countdownText
end

local function SupportsNativeDurationText()
    return C_AuraContainerUtil ~= nil
       and type(C_AuraContainerUtil.ProcessCustomAuraButtonDurationTextOptions) == "function"
       and C_CurveUtil ~= nil
       and type(C_CurveUtil.CreateColorCurve) == "function"
       and C_StringUtil ~= nil
       and type(C_StringUtil.CreateNumericRuleFormatter) == "function"
       and Enum ~= nil
       and Enum.DurationTextBindingProperty ~= nil
       and Enum.NumericRuleFormatRounding ~= nil
end

local function EnsureNativeDurationText(button, cooldown, meta)
    if not SupportsNativeDurationText()
       or not MCE:CanUseFrameAsTableKey(button)
       or not MCE:CanUseFrameAsTableKey(cooldown) then
        return false
    end

    meta = meta or trackedCooldownMeta[cooldown] or {}
    local holder = meta.durationTextHolder
        or MCE:SafeTableGet(button, "MCEUnitFrameDurationTextHolder")
    local durationText = meta.durationText
        or MCE:SafeTableGet(button, "MCEUnitFrameDurationText")

    if not MCE:CanUseFrameAsTableKey(holder) then
        local createOk, createdHolder = pcall(CreateFrame, "Frame", nil, button)
        if not createOk or not MCE:CanUseFrameAsTableKey(createdHolder) then
            return false
        end
        holder = createdHolder
        holder:SetAllPoints(button)

        local getFrameLevel = MCE:SafeTableGet(cooldown, "GetFrameLevel")
        local levelOk, level = false, nil
        if type(getFrameLevel) == "function" then
            levelOk, level = pcall(getFrameLevel, cooldown)
        end
        holder:SetFrameLevel(levelOk and type(level) == "number" and (level + 5) or 5)
        button.MCEUnitFrameDurationTextHolder = holder
    end

    if not IsObjectTypeSafe(durationText, "FontString") then
        local createFontString = MCE:SafeTableGet(holder, "CreateFontString")
        if type(createFontString) ~= "function" then return false end
        local textOk, createdText = pcall(
            createFontString, holder, nil, "OVERLAY", "NumberFontNormalSmall")
        if not textOk or not IsObjectTypeSafe(createdText, "FontString") then
            return false
        end
        durationText = createdText
        durationText:SetJustifyH("CENTER")
        durationText:SetPoint("CENTER", cooldown, "CENTER", 0, 0)
        button.MCEUnitFrameDurationText = durationText
    end

    meta.button = button
    meta.durationTextHolder = holder
    meta.durationText = durationText
    meta.countdownText = durationText
    meta.nativeDurationText = true
    trackedCooldownMeta[cooldown] = meta
    return true
end

local function IsCompactGroupFrameName(name)
    name = MCE:GetNonSecretString(name)
    if not name then
        return false
    end

    return strfind(name, "CompactPartyFrame", 1, true)
        or strfind(name, "CompactRaidFrame", 1, true)
end

local function GetUnitFrameConfig()
    local profile = MCE.db and MCE.db.profile
    local categories = profile and profile.categories
    return categories and categories[CATEGORY.Unitframe] or nil
end

local function IsUnitFrameCategoryEnabled()
    return MCE:IsCategoryActive(CATEGORY.Unitframe, GetUnitFrameConfig())
end

local function RefreshNativeDurationText(cooldown)
    local config = GetUnitFrameConfig()
    if not MCE:IsCategoryActive(CATEGORY.Unitframe, config) then
        return false
    end

    local durationColor = MCE:GetModule("DurationColorController", true)
    if not durationColor or not durationColor.RefreshNativeUnitFrameDurationText then
        return false
    end
    return durationColor:RefreshNativeUnitFrameDurationText(
        cooldown, CATEGORY.Unitframe, config)
end

local function SyncTrackedCooldownState(cooldown, meta)
    local state = frameState[cooldown]
    if not state then
        state = {}
        frameState[cooldown] = state
    end

    -- AuraButtons become restricted after initializeFrame. Retain only their
    -- supported public output objects and immutable group metadata.
    state.allowBlacklisted = true
    state.unitFrameCustomAura = true
    state.unitFrameManagedAura = meta.managedByMiniCE == true
    state.unitFrameAuraInitializing = meta.initializing == true
    state.unitFrameAuraInitialized = meta.initialized == true
    state.unitFrameAuraIsMine = meta.isMine
    state.unitFrameCount = meta.count
    state.unitFrameCountdownText = meta.countdownText
    state.unitFrameAuraButton = meta.button
    state.unitFrameDurationTextHolder = meta.durationTextHolder
    state.unitFrameNativeDurationText = meta.nativeDurationText == true
    state.unitFrameNativeDurationTextReady = meta.nativeDurationTextReady == true
end

local function MarkTrackedCooldown(cooldown, meta)
    if not MCE:CanUseFrameAsTableKey(cooldown) then
        return false
    end

    local existingMeta = trackedCooldownMeta[cooldown]
    if existingMeta and meta and existingMeta ~= meta then
        for key, value in pairs(meta) do
            if value ~= nil then
                existingMeta[key] = value
            end
        end
        meta = existingMeta
    else
        meta = meta or existingMeta or {}
    end
    if meta.countdownText == nil then
        meta.countdownText = GetCooldownCountdownText(cooldown)
    end
    trackedCooldownMeta[cooldown] = meta
    SyncTrackedCooldownState(cooldown, meta)

    if Registry then
        Registry:Register(cooldown, CATEGORY.Unitframe)
    end
    return true
end

local function RegisterKnownTrackedCooldowns()
    for cooldown, meta in pairs(trackedCooldownMeta) do
        MarkTrackedCooldown(cooldown, meta)
    end
end

local function RegisterLegacyCooldown(cooldown)
    if not MCE:CanUseFrameAsTableKey(cooldown) then return end
    if Registry then
        Registry:Register(cooldown, CATEGORY.Unitframe)
    end
end

local function GetButtonCooldown(button)
    if not button then return nil end

    for i = 1, #CUSTOM_AURA_MEMBER_KEYS do
        local cooldown = MCE:SafeTableGet(button, CUSTOM_AURA_MEMBER_KEYS[i])
        if MCE:CanUseFrameAsTableKey(cooldown) then
            return cooldown
        end
    end

    for _, methodName in ipairs({ "GetDurationCooldown", "GetCooldown" }) do
        local method = MCE:SafeTableGet(button, methodName)
        if type(method) == "function" then
            local ok, cooldown = pcall(method, button)
            if ok and MCE:CanUseFrameAsTableKey(cooldown) then
                return cooldown
            end
        end
    end

    if IsObjectTypeSafe(button, "Cooldown") then
        return button
    end
    return nil
end

local function GetButtonCount(button)
    local count = MCE:SafeTableGet(button, "MCEUnitFrameCount")
        or MCE:SafeTableGet(button, "bbfCount")
        or MCE:SafeTableGet(button, "Count")
        or MCE:SafeTableGet(button, "count")
    return IsObjectTypeSafe(count, "FontString") and count or nil
end

local function GetButtonLargeAuraState(button, style)
    local tier = type(style) == "table" and MCE:SafeTableGet(style, "tier") or nil
    if tier == "mine" or tier == "whitelistmine" or tier == "whitelistpandemic" then
        return true
    elseif tier == "others" or tier == "whitelist" then
        return false
    end

    local size = type(style) == "table" and MCE:SafeTableGet(style, "size") or nil
    if type(size) == "number"
       and not MCE:IsSecretValue(size)
       and addon.CanAccessAllValues(size) then
        return size > 20
    end

    local getWidth = MCE:SafeTableGet(button, "GetWidth")
    if type(getWidth) == "function" then
        local ok, width = pcall(getWidth, button)
        if ok and type(width) == "number"
           and not MCE:IsSecretValue(width)
           and addon.CanAccessAllValues(width)
           and width > 0 then
            return width > 20
        end
    end
    return nil
end

-- Legacy layouts and public third-party AuraContainers remain on the generic
-- discovery/styling path. The persistent-host optimization is deliberately not
-- applied to arbitrary providers.
local function ScanAuraContainer(container)
    if not MCE:CanUseFrameAsTableKey(container) then return end

    local getChildren = MCE:SafeTableGet(container, "GetChildren")
    if type(getChildren) ~= "function" then return end

    local children = { pcall(getChildren, container) }
    if not children[1] then return end

    for i = 2, #children do
        local child = children[i]
        if MCE:CanUseFrameAsTableKey(child) then
            local cooldown = GetButtonCooldown(child)
            if cooldown then
                RegisterLegacyCooldown(cooldown)
            end
        end
    end
end

local function ScanUnitFrame(frame)
    if not MCE:CanUseFrameAsTableKey(frame) then return end

    local buffFrame = MCE:SafeTableGet(frame, "BuffFrame")
        or MCE:SafeTableGet(frame, "buffFrame")
    if MCE:CanUseFrameAsTableKey(buffFrame) then ScanAuraContainer(buffFrame) end

    local debuffFrame = MCE:SafeTableGet(frame, "DebuffFrame")
        or MCE:SafeTableGet(frame, "debuffFrame")
    if MCE:CanUseFrameAsTableKey(debuffFrame) then ScanAuraContainer(debuffFrame) end

    local auraFrame = MCE:SafeTableGet(frame, "AuraFrame")
        or MCE:SafeTableGet(frame, "auraFrame")
    if MCE:CanUseFrameAsTableKey(auraFrame) then ScanAuraContainer(auraFrame) end

    local customContainer = MCE:SafeTableGet(frame, "AuraContainer")
        or MCE:SafeTableGet(frame, "auras")
    if MCE:CanUseFrameAsTableKey(customContainer) then
        ScanAuraContainer(customContainer)
    end
end

local function BuildFilterString(group)
    local filters = AuraUtil and AuraUtil.AuraFilters
    if not filters or type(AuraUtil.CreateFilterString) ~= "function"
       or not filters.Helpful or not filters.Harmful or not filters.Player then
        return nil
    end

    local parts = { group.helpful and filters.Helpful or filters.Harmful }
    if not group.helpful and filters.IncludeNameplateOnly then
        parts[#parts + 1] = filters.IncludeNameplateOnly
    end
    parts[#parts + 1] = group.isMine and filters.Player or ("!" .. filters.Player)
    return AuraUtil.CreateFilterString(unpack(parts))
end

local function AddUniformAsset(map, asset)
    for _, dispelType in ipairs({ "None", "Magic", "Curse", "Disease", "Poison", "Bleed" }) do
        map[dispelType] = { asset = asset }
    end
end

-- Dispel borders are parented to the AuraButton, below the raised duration
-- text holder, preserving the existing visual layering.
local function InitializeAuraBorder(button, icon, harmful, auraSize)
    local textureStyles = Enum and Enum.CustomAuraButtonDispelTypeTextureStyle
    if not textureStyles or type(button.AddDispelTypeTexture) ~= "function" then
        return
    end

    if harmful then
        local border = button:CreateTexture(nil, "OVERLAY")
        border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
        border:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
        border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
        button:AddDispelTypeTexture(border, {
            style = textureStyles.PreserveAsset,
            showWhenHarmful = true,
            showWhenHelpful = false,
            showWithoutDispelType = true,
        })
        button.MCEUnitFrameBorder = border
        return
    end

    local stealableFilter = Enum.CustomAuraButtonDispelTypeStealableFilter
    if not stealableFilter then return end

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize((auraSize or 21) * (24 / 21), (auraSize or 21) * (24 / 21))
    border:SetPoint("CENTER", icon, "CENTER")
    border:SetBlendMode("ADD")

    local assetMap = {}
    AddUniformAsset(assetMap, "Interface\\TargetingFrame\\UI-TargetingFrame-Stealable")
    button:AddDispelTypeTexture(border, {
        style = textureStyles.CustomAsset,
        showWhenHarmful = false,
        showWhenHelpful = true,
        showWithoutDispelType = true,
        stealableFilter = stealableFilter.Stealable,
        customDispelAssetMap = assetMap,
    })
    button.MCEUnitFrameStealableBorder = border
end

local function InitializeCustomAuraButton(_, button, group)
    if not button then return end

    HookCustomAuraButtonBindings(button)
    button:SetSize(group.size, group.size)

    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(button)
    button.MCEUnitFrameIcon = icon
    button:SetIcon(icon)

    local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetAllPoints(icon)
    cooldown:SetReverse(true)
    cooldown:SetDrawEdge(true)
    cooldown:SetDrawBling(false)
    cooldown:SetUsingParentLevel(true)
    button.MCEUnitFrameCooldown = cooldown

    local overlay = CreateFrame("Frame", nil, button)
    overlay:SetAllPoints(button)
    overlay:SetFrameLevel(cooldown:GetFrameLevel() + 1)
    button.MCEUnitFrameOverlay = overlay

    local count = overlay:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    count:SetJustifyH("RIGHT")
    count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, 0)
    button.MCEUnitFrameCount = count

    InitializeAuraBorder(button, icon, not group.helpful, group.size)

    local meta = {
        managedByMiniCE = true,
        initializing = true,
        initialized = false,
        isMine = group.isMine,
        count = count,
        button = button,
    }
    EnsureNativeDurationText(button, cooldown, meta)

    -- Register before Blizzard binds its outputs. SetDurationCooldown immediately
    -- calls the cooldown API, so HookBridge must see the initializing fast-path
    -- state before that call begins.
    MarkTrackedCooldown(cooldown, meta)

    button:SetApplicationCount(count)
    button:SetDurationCooldown(cooldown)
    meta.nativeDurationTextReady = meta.nativeDurationText == true
    SyncTrackedCooldownState(cooldown, meta)

    -- This is the single structural style pass for this AuraButton lifetime.
    local styleEngine = MCE:GetModule("StyleEngine", true)
    if styleEngine then
        styleEngine:ApplyStyle(cooldown, CATEGORY.Unitframe)
    else
        RefreshNativeDurationText(cooldown)
    end

    meta.initializing = false
    meta.initialized = true
    SyncTrackedCooldownState(cooldown, meta)

    button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", 0, 0)
end

local function CreateAuraButtonInitializer(host, group)
    return function(button)
        InitializeCustomAuraButton(host, button, group)
    end
end

local function GetNativeAuraContainer(root)
    local method = MCE:SafeTableGet(root, "GetAuraContainer")
    if type(method) ~= "function" then return nil end
    local ok, container = pcall(method, root)
    return ok and MCE:CanUseFrameAsTableKey(container) and container or nil
end

local function GetCustomContainerParent(root)
    local content = MCE:SafeTableGet(root, "TargetFrameContent")
    local contextual = MCE:SafeTableGet(content, "TargetFrameContentContextual")
    return MCE:CanUseFrameAsTableKey(contextual) and contextual or root
end

local function GetCustomContainerAnchor(root)
    local targetContainer = MCE:SafeTableGet(root, "TargetFrameContainer")
    local texture = MCE:SafeTableGet(targetContainer, "FrameTexture")
    return MCE:CanUseFrameAsTableKey(texture) and texture or root
end

local function GetConfiguredMaxCount(root, field, fallback)
    local value = MCE:SafeTableGet(root, field)
    if type(value) == "number"
       and not MCE:IsSecretValue(value)
       and addon.CanAccessAllValues(value)
       and value >= 0 then
        return value
    end
    return fallback
end

local function GetHostFriendlyState(host)
    if type(UnitIsFriend) ~= "function" then return false end
    local ok, result = pcall(UnitIsFriend, "player", host.unit)
    return ok and GetAccessibleBoolean(result) == true or false
end

local function BuildHostConfigurationSignature(host, config, friendly, maxBuffs, maxDebuffs, buffsOnTop)
    return format("%s|%s|%s|%d|%d|%s|%s|%s",
        host.name,
        host.unit,
        friendly and "1" or "0",
        maxBuffs,
        maxDebuffs,
        config.onlyMineBuffs == true and "1" or "0",
        config.onlyMineDebuffs == true and "1" or "0",
        buffsOnTop and "1" or "0")
end

local function ApplyHostConfigurationIfDirty(host, force)
    if not host.created or not host.container then return false end

    local config = GetUnitFrameConfig()
    if not config then return false end

    local root = host.root
    local friendly = GetHostFriendlyState(host)
    local maxBuffs = GetConfiguredMaxCount(root, "maxBuffs", 32)
    local maxDebuffs = GetConfiguredMaxCount(root, "maxDebuffs", 16)
    local buffsOnTop = GetAccessibleBoolean(MCE:SafeTableGet(root, "buffsOnTop")) == true
    local anchor = GetCustomContainerAnchor(root)
    local signature = BuildHostConfigurationSignature(
        host, config, friendly, maxBuffs, maxDebuffs, buffsOnTop)

    if not force
       and host.configurationSignature == signature
       and host.configurationAnchor == anchor then
        host.configurationDirty = nil
        return false
    end

    if force or host.appliedFriendly ~= friendly then
        for _, group in ipairs(CUSTOM_GROUPS) do
            host.container:SetAuraGroupLayout(
                group.key, friendly and group.friendlyLayout or group.hostileLayout)
        end
        host.appliedFriendly = friendly
    end

    for _, group in ipairs(CUSTOM_GROUPS) do
        local maxCount = group.helpful and maxBuffs or maxDebuffs
        local onlyMine = group.helpful
            and config.onlyMineBuffs == true
            or (not group.helpful and config.onlyMineDebuffs == true)
        if not group.isMine and onlyMine then
            maxCount = 0
        end

        if force or host.groupCounts[group.key] ~= maxCount then
            host.container:SetAuraGroupMaxFrameCount(group.key, maxCount)
            host.groupCounts[group.key] = maxCount
        end
    end

    if force
       or host.appliedBuffsOnTop ~= buffsOnTop
       or host.configurationAnchor ~= anchor then
        local point = buffsOnTop and "BOTTOMLEFT" or "TOPLEFT"
        local relativePoint = buffsOnTop and "TOPLEFT" or "BOTTOMLEFT"
        local verticalDirection = buffsOnTop
            and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down
        local offsetY = buffsOnTop and -6 or 9

        host.container:SetFlowLayoutAnchorPoint(point)
        host.container:SetFlowLayoutGrowthDirection(
            AnchorUtil.FlowDirection.Right, verticalDirection)
        host.container:ClearAllPoints()
        host.container:SetPoint(point, anchor, relativePoint, 5, offsetY)
        host.appliedBuffsOnTop = buffsOnTop
    end

    host.configurationSignature = signature
    host.configurationAnchor = anchor
    host.configurationDirty = nil
    return true
end

local function SuppressNativeContainer(host, force)
    if not host.native then return false end
    if host.nativeSuppressed and not host.nativeSuppressionDirty and not force then
        return false
    end

    SafeCall(host.native, "SetMaxBuffs", 0)
    SafeCall(host.native, "SetMaxDebuffs", 0)
    SafeCall(host.native, "SetEnabled", false)
    SafeCall(host.native, "SetUnit", "none")
    host.nativeSuppressed = true
    host.nativeSuppressionDirty = nil
    return true
end

local function RestoreNativeContainer(host)
    if not host.native or not host.nativeSuppressed then return false end

    host.restoringNative = true
    SafeCall(host.native, "SetUnit", host.unit)
    SafeCall(host.native, "SetMaxBuffs",
        GetConfiguredMaxCount(host.root, "maxBuffs", host.nativeMaxBuffs or 32))
    SafeCall(host.native, "SetMaxDebuffs",
        GetConfiguredMaxCount(host.root, "maxDebuffs", host.nativeMaxDebuffs or 16))
    SafeCall(host.native, "SetEnabled", host.nativeWasEnabled ~= false)
    SafeCall(host.native, "Show")

    -- Restoring native ownership is an exceptional lifecycle transition. Ask
    -- Blizzard to reconfigure and parse the current unit once.
    host.nativeSuppressed = nil
    host.nativeSuppressionDirty = nil
    SafeCall(host.root, "ConfigureAuraContainer")
    SafeCall(host.native, "UpdateAllAuras")
    host.restoringNative = nil
    return true
end

local function RefreshHostData(host)
    if not host.created or not host.active or not host.container then return false end
    host.container:UpdateAllAuras()
    return true
end

local function ActivateHost(host)
    if not host.created then return false end
    if host.active then
        if host.nativeSuppressionDirty then
            SuppressNativeContainer(host, true)
        end
        return false
    end

    ApplyHostConfigurationIfDirty(host)
    SuppressNativeContainer(host)
    host.container:SetEnabled(true)
    host.container:Show()
    host.active = true

    -- A disabled container can miss changes. Reactivation performs one explicit
    -- parse; steady-state aura churn is entirely Blizzard-driven afterward.
    RefreshHostData(host)
    return true
end

local function DeactivateHost(host, restoreNative)
    if host.created and host.active then
        SafeCall(host.container, "SetEnabled", false)
        SafeCall(host.container, "Hide")
        host.active = nil
    end
    if restoreNative then
        RestoreNativeContainer(host)
    end
end

local function HostAPIsAvailable()
    local filters = AuraUtil and AuraUtil.AuraFilters
    return type(CreateFrame) == "function"
       and AnchorUtil ~= nil
       and AnchorUtil.FlowLayoutAxis ~= nil
       and AnchorUtil.FlowDirection ~= nil
       and filters ~= nil
       and type(AuraUtil.CreateFilterString) == "function"
       and SupportsNativeDurationText()
end

local function UpdateRegenEventRegistration()
    local eventFrame = Adapter.eventFrame
    if not eventFrame then return end

    local pending = false
    for _, definition in ipairs(HOST_DEFINITIONS) do
        local host = hostsByName[definition.name]
        if host.pendingCreate then
            pending = true
            break
        end
    end

    if pending then
        eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    else
        eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end

local function EnsureHost(host)
    if host.created then return true end
    if not IsUnitFrameCategoryEnabled()
       or MCE:IsBetterBlizzFramesAvailable()
       or not HostAPIsAvailable() then
        host.pendingCreate = nil
        UpdateRegenEventRegistration()
        return false
    end

    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        host.pendingCreate = true
        UpdateRegenEventRegistration()
        return false
    end

    local root = _G[host.name]
    if not MCE:CanUseFrameAsTableKey(root) then return false end

    local native = GetNativeAuraContainer(root)
    if not native then return false end

    local nativeEnabled = true
    local enabledOk, enabled = SafeCall(native, "IsEnabled")
    if enabledOk then
        local accessibleEnabled = GetAccessibleBoolean(enabled)
        if accessibleEnabled ~= nil then
            nativeEnabled = accessibleEnabled
        end
    end
    if not nativeEnabled then
        -- A provider other than MiniCE already owns this presentation.
        return false
    end

    local parent = GetCustomContainerParent(root)
    local groupFilters = {}
    for _, group in ipairs(CUSTOM_GROUPS) do
        local filterString = BuildFilterString(group)
        if not filterString then
            return false
        end
        groupFilters[group.key] = filterString
    end

    local container = CreateFrame(
        "AuraContainer", nil, parent, "CustomAuraContainerTemplate")

    host.root = root
    host.native = native
    host.nativeWasEnabled = nativeEnabled
    host.nativeMaxBuffs = GetConfiguredMaxCount(root, "maxBuffs", 32)
    host.nativeMaxDebuffs = GetConfiguredMaxCount(root, "maxDebuffs", 16)
    host.container = container

    container:SetSize(1, 1)
    container:SetUnit(host.unit)
    container:SetEnabled(false)
    container:Hide()
    container:SetFlowLayoutAxis(AnchorUtil.FlowLayoutAxis.Horizontal)
    container:SetFlowLayoutPadding(0, 0, 0, 0)
    container:SetFlowLayoutMaximumLineSize(122)

    -- AddAuraGroup stamps UntrustedLayoutScriptExecution onto AuraContainer.
    -- Seed the spell-bar dependency first so the aspect can propagate through
    -- the existing anchor relationship instead of rejecting a later SetPoint.
    SeedCastBarAnchor(host)

    for _, group in ipairs(CUSTOM_GROUPS) do
        -- Declare full topology once while safely out of combat. Runtime
        -- visibility is controlled by SetAuraGroupMaxFrameCount.
        container:AddAuraGroup(group.key, groupFilters[group.key], {
            maxFrameCount = group.maxCount,
            layout = group.friendlyLayout,
            initializeFrame = CreateAuraButtonInitializer(host, group),
        })
    end

    host.created = true
    host.pendingCreate = nil
    host.configurationSignature = nil
    ApplyHostConfigurationIfDirty(host, true)
    UpdateRegenEventRegistration()
    return true
end

-- ── Cast bar repositioning ────────────────────────────────────────────────
--
-- Blizzard anchors the Target/Focus spell bar below its own AuraContainer.
-- MiniCE suppresses that container and renders auras from its own, so the
-- spell bar collapses back against the frame and overlaps the aura rows.
-- When enabled, re-anchor it to the bottom of the MiniCE container so it
-- always sits under the last buff/debuff row and follows it as rows change.
local CASTBAR_ANCHOR_X = 18
local CASTBAR_ANCHOR_Y = -5

local castBarHooked = setmetatable({}, addon.weakMeta)
local castBarAnchoring = {}
local castBarOwned = {}
local AnchorCastBar

local function GetSpellBar(host)
    local spellBar = _G[host.name .. "SpellBar"]
    return MCE:CanUseFrameAsTableKey(spellBar) and spellBar or nil
end

local function IsCastBarRepositionEnabled()
    local config = GetUnitFrameConfig()
    return config ~= nil
       and MCE:IsCategoryActive(CATEGORY.Unitframe, config)
       and config.castBarReposition ~= false
end

local function ApplyCastBarPoint(spellBar, point, relativeTo, relativePoint, x, y)
    -- 12.1 spell bars carry an additive offset on top of their anchor.
    if type(spellBar.ClearPointsOffset) == "function" then
        spellBar:ClearPointsOffset()
    end
    spellBar:ClearAllPoints()
    spellBar:SetPoint(point, relativeTo, relativePoint, x, y)
end

local function TryCastBarPoint(host, spellBar, point, relativeTo, relativePoint, x, y)
    castBarAnchoring[host.name] = true
    local ok = pcall(ApplyCastBarPoint, spellBar, point, relativeTo, relativePoint, x, y)
    castBarAnchoring[host.name] = nil
    return ok
end

-- Blizzard's resting placement, reapplied when MiniCE gives ownership back.
local function GetBlizzardCastBarBase(root)
    local smallSize = GetAccessibleBoolean(MCE:SafeTableGet(root, "smallSize")) == true
    local haveToT = GetAccessibleBoolean(MCE:SafeTableGet(root, "haveToT")) == true
    local x = smallSize and 38 or 43
    local y = smallSize and 3 or 5
    if haveToT then
        y = smallSize and -48 or -46
    end
    return x, y
end

SeedCastBarAnchor = function(host)
    local spellBar = GetSpellBar(host)
    if not spellBar or not host.container then return false end

    castBarOwned[host.name] = true
    if TryCastBarPoint(host, spellBar, "TOPLEFT", host.container, "BOTTOMLEFT",
        CASTBAR_ANCHOR_X, CASTBAR_ANCHOR_Y) then
        return true
    end

    castBarOwned[host.name] = nil
    local root = host.root or _G[host.name]
    if MCE:CanUseFrameAsTableKey(root) then
        local x, y = GetBlizzardCastBarBase(root)
        TryCastBarPoint(host, spellBar, "TOPLEFT", root, "BOTTOMLEFT", x, y)
    end
    return false
end

local function ReleaseCastBar(host)
    if not castBarOwned[host.name] then return end
    castBarOwned[host.name] = nil

    local spellBar = GetSpellBar(host)
    local root = host.root or _G[host.name]
    if not spellBar or not MCE:CanUseFrameAsTableKey(root) then return end

    local x, y = GetBlizzardCastBarBase(root)
    TryCastBarPoint(host, spellBar, "TOPLEFT", root, "BOTTOMLEFT", x, y)
end

-- Anchoring a clean frame onto one that carries restricted layout execution
-- taints the layout pass. Only anchor while both sides share the aspect.
local function CanAnchorCastBarTo(spellBar, container)
    local aspect = Enum and Enum.ForbiddenAspect
        and Enum.ForbiddenAspect.UntrustedLayoutScriptExecution
    if not aspect or type(container.HasAnyForbiddenAspects) ~= "function" then
        return true
    end

    local ok, containerRestricted = pcall(container.HasAnyForbiddenAspects, container, aspect)
    if not ok or not containerRestricted then
        return ok
    end

    if type(spellBar.HasAnyForbiddenAspects) ~= "function" then
        return false
    end
    local barOk, barRestricted = pcall(spellBar.HasAnyForbiddenAspects, spellBar, aspect)
    return barOk and barRestricted == true
end

AnchorCastBar = function(host)
    if castBarAnchoring[host.name] then return end

    -- With buffs on top the container grows away from the spell bar, so
    -- Blizzard's own placement below the frame is already correct.
    if not IsCastBarRepositionEnabled()
       or not host.created or not host.active or not host.container
       or host.appliedBuffsOnTop then
        ReleaseCastBar(host)
        return
    end

    local spellBar = GetSpellBar(host)
    if not spellBar or not CanAnchorCastBarTo(spellBar, host.container) then
        ReleaseCastBar(host)
        return
    end

    castBarOwned[host.name] = true
    TryCastBarPoint(host, spellBar, "TOPLEFT", host.container, "BOTTOMLEFT",
        CASTBAR_ANCHOR_X, CASTBAR_ANCHOR_Y)
end

-- Blizzard re-points the spell bar every time a cast starts. Reassert the
-- MiniCE anchor from the same hook instead of polling.
local function HookCastBar(host)
    local spellBar = GetSpellBar(host)
    if not spellBar or castBarHooked[spellBar] then return end
    castBarHooked[spellBar] = true

    hooksecurefunc(spellBar, "SetPoint", function()
        if castBarAnchoring[host.name] then return end
        AnchorCastBar(host)
    end)
end

local function ScheduleHostWork(host, configuration, dataRefresh)
    if configuration then
        host.configurationDirty = true
    end
    if dataRefresh then
        host.dataRefreshPending = true
    end
    host.workPending = true

    if hostWorkScheduled then return end
    hostWorkScheduled = true
    RunNextFrame(ProcessPendingHostWork)
end

ProcessPendingHostWork = function()
    hostWorkScheduled = false

    for _, definition in ipairs(HOST_DEFINITIONS) do
        local host = hostsByName[definition.name]
        if host.workPending or host.pendingCreate then
            host.workPending = nil
            HookCastBar(host)

            if not IsUnitFrameCategoryEnabled() or MCE:IsBetterBlizzFramesAvailable() then
                host.pendingCreate = nil
                host.configurationDirty = nil
                host.dataRefreshPending = nil
                DeactivateHost(host, true)
            elseif EnsureHost(host) then
                if host.configurationDirty then
                    ApplyHostConfigurationIfDirty(host)
                end

                local activated = ActivateHost(host)
                if host.dataRefreshPending and not activated then
                    RefreshHostData(host)
                end
                host.dataRefreshPending = nil
            end

            AnchorCastBar(host)
        end
    end

    UpdateRegenEventRegistration()
end

local function HookBlizzardRoot(host)
    local root = _G[host.name]
    if not MCE:CanUseFrameAsTableKey(root) or hookedRoots[root] then
        return
    end
    hookedRoots[root] = true

    local configure = MCE:SafeTableGet(root, "ConfigureAuraContainer")
    if type(configure) == "function" then
        hooksecurefunc(root, "ConfigureAuraContainer", function()
            if not Adapter:IsEnabled() or host.restoringNative then return end
            if not IsUnitFrameCategoryEnabled() then return end

            -- Blizzard may have reapplied native settings. Reassert suppression
            -- once for this structural callback, and only reapply MiniCE layout
            -- if its signature changed.
            if host.active and host.nativeSuppressed then
                host.nativeSuppressionDirty = true
            end
            ScheduleHostWork(host, true, false)
        end)
    end
end

local function HandleHostEvent(_, event, unit)
    if event == "PLAYER_REGEN_ENABLED" then
        for _, definition in ipairs(HOST_DEFINITIONS) do
            local host = hostsByName[definition.name]
            if host.pendingCreate then
                ScheduleHostWork(host, true, true)
            end
        end
        return
    end

    if not IsUnitFrameCategoryEnabled() then return end

    if event == "PLAYER_TARGET_CHANGED" then
        ScheduleHostWork(hostsByName.TargetFrame, true, true)
    elseif event == "PLAYER_FOCUS_CHANGED" then
        ScheduleHostWork(hostsByName.FocusFrame, true, true)
    elseif event == "UNIT_FACTION" then
        local host = unit == "focus" and hostsByName.FocusFrame or hostsByName.TargetFrame
        ScheduleHostWork(host, true, false)
    else
        for _, definition in ipairs(HOST_DEFINITIONS) do
            ScheduleHostWork(hostsByName[definition.name], true, true)
        end
    end
end

function Adapter:OnEnable()
    if MCE:IsBetterBlizzFramesAvailable() then return end

    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.Unitframe, self)

    local eventFrame = CreateFrame("Frame")
    self.eventFrame = eventFrame
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    eventFrame:RegisterUnitEvent("UNIT_FACTION", "target", "focus")
    eventFrame:SetScript("OnEvent", HandleHostEvent)

    for _, definition in ipairs(HOST_DEFINITIONS) do
        local host = hostsByName[definition.name]
        HookBlizzardRoot(host)
        HookCastBar(host)
        if IsUnitFrameCategoryEnabled() then
            ScheduleHostWork(host, true, true)
        end
    end
end

function Adapter:OnDisable()
    hostWorkScheduled = false
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end

    for _, definition in ipairs(HOST_DEFINITIONS) do
        local host = hostsByName[definition.name]
        host.workPending = nil
        host.pendingCreate = nil
        host.configurationDirty = nil
        host.dataRefreshPending = nil
        DeactivateHost(host, true)
        ReleaseCastBar(host)
    end
end

function Adapter:Rebuild()
    if MCE:IsBetterBlizzFramesAvailable() then
        for _, definition in ipairs(HOST_DEFINITIONS) do
            local host = hostsByName[definition.name]
            host.pendingCreate = nil
            DeactivateHost(host, true)
            ReleaseCastBar(host)
        end
        UpdateRegenEventRegistration()
        return
    end

    if not IsUnitFrameCategoryEnabled() then
        for _, definition in ipairs(HOST_DEFINITIONS) do
            local host = hostsByName[definition.name]
            host.workPending = nil
            host.pendingCreate = nil
            host.configurationDirty = nil
            host.dataRefreshPending = nil
            DeactivateHost(host, true)
            ReleaseCastBar(host)
        end
        UpdateRegenEventRegistration()
        return
    end

    -- Registry rebuilds wipe ownership, not persistent AuraButtons. Restore
    -- known registrations without walking every host on ordinary aura events.
    RegisterKnownTrackedCooldowns()

    for _, definition in ipairs(HOST_DEFINITIONS) do
        local host = hostsByName[definition.name]
        HookBlizzardRoot(host)
        HookCastBar(host)
        ScheduleHostWork(host, true, false)
    end

    for _, rootName in ipairs(UF.BlizzardRoots) do
        local root = _G[rootName]
        if root then ScanUnitFrame(root) end
    end

    for _, pattern in ipairs(UF.ThirdPartyPatterns) do
        local root = _G[pattern]
        if root and not MCE:IsForbidden(root) then
            ScanUnitFrame(root)
        end
    end
end

local function ExtractUnitToken(unit)
    local directToken = MCE:GetNonSecretString(unit)
    if directToken then
        return directToken
    end
    if type(unit) ~= "table"
       or MCE:IsSecretValue(unit)
       or not addon.CanAccessAllValues(unit) then
        return nil
    end

    for i = 1, #UNIT_TOKEN_KEYS do
        local token = MCE:GetNonSecretString(MCE:SafeTableGet(unit, UNIT_TOKEN_KEYS[i]))
        if token then
            return token
        end
    end
    return nil
end

local function ClaimUnitFrameCooldown(cooldown, customAuraButton, foundCustomTargetContainer)
    if foundCustomTargetContainer then
        MarkTrackedCooldown(cooldown, {
            managedByMiniCE = false,
            isMine = GetButtonLargeAuraState(customAuraButton),
            count = GetButtonCount(customAuraButton),
            button = customAuraButton,
        })
    end
    return CATEGORY.Unitframe
end

function Adapter:TryClaim(cooldown)
    if MCE:IsBetterBlizzFramesAvailable() then return nil end
    if not MCE:CanUseFrameAsTableKey(cooldown) then return nil end
    if trackedCooldownMeta[cooldown] then return CATEGORY.Unitframe end

    if IsMiniAurasFrame(cooldown) then return nil end

    local current = GetParentSafe(cooldown)
    local customAuraButton
    if current
       and type(MCE:SafeTableGet(current, "GetDurationCooldown")) == "function"
       and type(MCE:SafeTableGet(current, "SetDurationCooldown")) == "function" then
        customAuraButton = current
    end
    local foundCustomTargetContainer = false

    for _ = 1, UF.MaxAncestorDepth do
        if not current then break end
        local name = MCE:GetFrameName(current) or ""
        local unitToken = ExtractUnitToken(MCE:SafeTableGet(current, "unit"))
            or ExtractUnitToken(MCE:SafeTableGet(current, "unitToken"))
            or ExtractUnitToken(MCE:SafeTableGet(current, "displayedUnit"))

        if not unitToken then
            local getUnit = MCE:SafeTableGet(current, "GetUnit")
            if type(getUnit) == "function" then
                local unitOk, methodUnit = pcall(getUnit, current)
                if unitOk then
                    unitToken = ExtractUnitToken(methodUnit)
                end
            end
        end

        if IsCompactGroupFrameName(name) then
            return nil
        end
        if name ~= "" and strfind(name, MINIAURAS_PREFIX, 1, true) then
            return nil
        end

        if (unitToken == "target" or unitToken == "focus")
           and type(MCE:SafeTableGet(current, "GetAuraGroupFrame")) == "function"
           and type(MCE:SafeTableGet(current, "GetAuraGroupFrameCount")) == "function" then
            foundCustomTargetContainer = true
        end

        for _, rootName in ipairs(UF.BlizzardRoots) do
            if name == rootName then
                return ClaimUnitFrameCooldown(
                    cooldown, customAuraButton, foundCustomTargetContainer)
            end
        end

        for _, pattern in ipairs(UF.ThirdPartyPatterns) do
            if strfind(name, pattern, 1, true) then
                return ClaimUnitFrameCooldown(
                    cooldown, customAuraButton, foundCustomTargetContainer)
            end
        end

        if unitToken and FALLBACK_UNIT_TOKENS[unitToken] then
            if name ~= "" and (strfind(name, "Frame", 1, true)
                or strfind(name, "UF", 1, true)) then
                return ClaimUnitFrameCooldown(
                    cooldown, customAuraButton, foundCustomTargetContainer)
            end
        end

        current = GetParentSafe(current)
    end

    if foundCustomTargetContainer then
        return ClaimUnitFrameCooldown(
            cooldown, customAuraButton, foundCustomTargetContainer)
    end
    return nil
end

do
    local durationHooked = false
    local countHooked = false
    local customAuraButtonAPI

    local function GetCustomAuraButtonAPI(button)
        if customAuraButtonAPI then
            return customAuraButtonAPI
        end
        if not MCE:CanUseFrameAsTableKey(button) then return nil end

        local metaOk, meta = pcall(getmetatable, button)
        if not metaOk or type(meta) ~= "table" then return nil end
        local api = MCE:SafeTableGet(meta, "__index")
        if type(api) ~= "table"
           or type(MCE:SafeTableGet(api, "SetDurationCooldown")) ~= "function"
           or type(MCE:SafeTableGet(api, "SetApplicationCount")) ~= "function" then
            return nil
        end
        customAuraButtonAPI = api
        return customAuraButtonAPI
    end

    HookCustomAuraButtonBindings = function(button)
        local api = GetCustomAuraButtonAPI(button)
        if not api then return end

        if not durationHooked
           and type(MCE:SafeTableGet(api, "SetDurationCooldown")) == "function" then
            local hookOk = pcall(hooksecurefunc, api, "SetDurationCooldown", function(button, cooldown)
                if not IsUnitFrameCategoryEnabled() then return end
                if not MCE:CanUseFrameAsTableKey(cooldown) then return end

                local meta = trackedCooldownMeta[cooldown]
                if meta and meta.managedByMiniCE then
                    -- Blizzard is rebinding dynamic aura data to an already
                    -- styled public output. The native binding and HookBridge
                    -- fast path require no structural work here.
                    return
                end

                local category = Adapter:TryClaim(cooldown)
                meta = trackedCooldownMeta[cooldown]
                if not meta and category == CATEGORY.Unitframe
                   and MCE:CanUseFrameAsTableKey(button) then
                    meta = {
                        managedByMiniCE = false,
                        button = button,
                        count = GetButtonCount(button),
                        isMine = GetButtonLargeAuraState(button),
                    }
                end
                if not meta or not MCE:CanUseFrameAsTableKey(button) then return end

                EnsureNativeDurationText(button, cooldown, meta)
                meta.nativeDurationTextReady = meta.nativeDurationText == true
                if meta.isMine == nil then
                    meta.isMine = GetButtonLargeAuraState(button)
                end
                MarkTrackedCooldown(cooldown, meta)

                -- Third-party custom UnitFrames remain on the generic styling
                -- path; only MiniCE-owned outputs use the no-restyle fast path.
                if not hookedCustomAuraButtons[button]
                   and type(MCE:SafeTableGet(button, "SetSize")) == "function" then
                    local sizeHooked = pcall(hooksecurefunc, button, "SetSize", function(_, width)
                        if type(width) == "number"
                           and not MCE:IsSecretValue(width)
                           and addon.CanAccessAllValues(width)
                           and width > 0 then
                            local currentMeta = trackedCooldownMeta[cooldown]
                            if currentMeta then
                                currentMeta.isMine = width > 20
                                SyncTrackedCooldownState(cooldown, currentMeta)
                            end
                        end
                    end)
                    if sizeHooked then
                        hookedCustomAuraButtons[button] = true
                    end
                end

                if category == CATEGORY.Unitframe or (Registry
                   and Registry:GetCategory(cooldown) == CATEGORY.Unitframe) then
                    local styleEngine = MCE:GetModule("StyleEngine", true)
                    if styleEngine then
                        styleEngine:ApplyStyle(cooldown, CATEGORY.Unitframe)
                    else
                        RefreshNativeDurationText(cooldown)
                    end
                end
            end)
            durationHooked = hookOk
        end

        if not countHooked
           and type(MCE:SafeTableGet(api, "SetApplicationCount")) == "function" then
            local hookOk = pcall(hooksecurefunc, api, "SetApplicationCount", function(button, count)
                if not IsUnitFrameCategoryEnabled() then return end

                local cooldown = GetButtonCooldown(button)
                local meta = cooldown and trackedCooldownMeta[cooldown] or nil
                if meta and meta.managedByMiniCE then
                    return
                end
                if not meta and Registry and cooldown
                   and Registry:GetCategory(cooldown) == CATEGORY.Unitframe then
                    meta = { managedByMiniCE = false }
                end
                if meta and IsObjectTypeSafe(count, "FontString") then
                    meta.count = count
                    MarkTrackedCooldown(cooldown, meta)
                end
            end)
            countHooked = hookOk
        end
    end
end
