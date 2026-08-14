-- Adapters/UnitFrameAdapter.lua – Blizzard + third-party unit frame cooldowns

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("UnitFrameAdapter")

local ipairs, pairs, type, pcall = ipairs, pairs, type, pcall
local strfind = string.find
local unpack = unpack
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local C_Timer_After = C_Timer.After

local CATEGORY = C.Categories
local UF = C.Adapter.UnitFrames
local MINIAURAS_PREFIX = C.Classifier.MiniAurasNamePrefix
local frameState = addon.frameState

local CUSTOM_GROUPS = {
    { key = "BuffMine", helpful = true, isMine = true, maxCount = 32, size = 21 },
    { key = "BuffOther", helpful = true, isMine = false, maxCount = 32, size = 17 },
    { key = "DebuffMine", helpful = false, isMine = true, maxCount = 16, size = 21 },
    { key = "DebuffOther", helpful = false, isMine = false, maxCount = 16, size = 17 },
}

local CUSTOM_ROOTS = {
    { name = "TargetFrame", unit = "target", spellBar = "TargetFrameSpellBar" },
    { name = "FocusFrame", unit = "focus", spellBar = "FocusFrameSpellBar" },
}

local CUSTOM_ROOT_BY_NAME = {}
for _, rootInfo in ipairs(CUSTOM_ROOTS) do
    CUSTOM_ROOT_BY_NAME[rootInfo.name] = rootInfo
end

local BETTERBLIZZ_HOST_KEYS = { "target", "focus" }
local BETTERBLIZZ_CONTAINER_KEYS = { "spacer", "blockTop", "blockBottom", "filtered" }
local CUSTOM_AURA_MEMBER_KEYS = {
    "MCEUnitFrameCooldown", "bbfCooldown", "cooldown", "Cooldown",
}

local Registry
local customHosts = {}
local hookedRoots = setmetatable({}, addon.weakMeta)
local trackedCooldownMeta = setmetatable({}, addon.weakMeta)
local hookedCustomAuraButtons = setmetatable({}, addon.weakMeta)
local pendingRootSync = {}
local betterBlizzHooked = false
local betterBlizzRefreshPending = false
local betterBlizzAuraStyleWrapped = false
local HookCustomAuraButtonBindings

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
    local config = GetUnitFrameConfig()
    return config and config.enabled == true or false
end

local function RefreshNativeDurationText(cooldown)
    local config = GetUnitFrameConfig()
    if not (config and config.enabled == true) then return false end

    local durationColor = MCE:GetModule("DurationColorController", true)
    if not durationColor or not durationColor.RefreshNativeUnitFrameDurationText then
        return false
    end
    return durationColor:RefreshNativeUnitFrameDurationText(
        cooldown, CATEGORY.Unitframe, config)
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

    local state = frameState[cooldown]
    if not state then
        state = {}
        frameState[cooldown] = state
    end

    -- Custom AuraButtons deny tainted access while auras are secret. The
    -- cooldown and its display regions are still the public, supported output
    -- objects, so remember their safe metadata before that restriction applies.
    state.allowBlacklisted = true
    state.unitFrameCustomAura = true
    state.unitFrameAuraIsMine = meta.isMine
    state.unitFrameCount = meta.count
    state.unitFrameCountdownText = meta.countdownText
    state.unitFrameAuraButton = meta.button
    state.unitFrameDurationTextHolder = meta.durationTextHolder
    state.unitFrameNativeDurationText = meta.nativeDurationText == true
    state.unitFrameNativeDurationTextReady = meta.nativeDurationTextReady == true
    state.unitFrameThresholdColorsDisabled = meta.thresholdColorsDisabled == true

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

local function RegisterLegacyCooldown(cooldown, thresholdColorsDisabled)
    if not MCE:CanUseFrameAsTableKey(cooldown) then return end
    if thresholdColorsDisabled then
        MarkTrackedCooldown(cooldown, { thresholdColorsDisabled = true })
    elseif Registry then
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
           and addon.CanAccessAllValues(width) then
            if width > 0 then
                return width > 20
            end
        end
    end
    return nil
end

local function RegisterAuraButton(button, style, thresholdColorsDisabled)
    if not MCE:CanUseFrameAsTableKey(button) then return end
    local cooldown = GetButtonCooldown(button)
    if not cooldown then return end

    MarkTrackedCooldown(cooldown, {
        isMine = GetButtonLargeAuraState(button, style),
        count = GetButtonCount(button),
        button = button,
        thresholdColorsDisabled = thresholdColorsDisabled == true and true or nil,
    })
end

-- Scan an aura container for cooldown children. This covers legacy unit-frame
-- layouts and public 12.1 CustomAuraContainers created by other addons.
local function ScanAuraContainer(container, thresholdColorsDisabled)
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
                RegisterLegacyCooldown(cooldown, thresholdColorsDisabled)
            end
        end
    end
end

local function ScanCustomAuraContainer(container, thresholdColorsDisabled)
    if not MCE:CanUseFrameAsTableKey(container) then return end

    local styles = MCE:SafeTableGet(container, "bbfStyles")
    local getCount = MCE:SafeTableGet(container, "GetAuraGroupFrameCount")
    local getFrame = MCE:SafeTableGet(container, "GetAuraGroupFrame")
    if type(styles) == "table" and type(getCount) == "function" and type(getFrame) == "function" then
        for groupKey, style in pairs(styles) do
            local ok, count = pcall(getCount, container, groupKey)
            if ok and type(count) == "number"
               and not MCE:IsSecretValue(count)
               and addon.CanAccessAllValues(count) then
                for index = 1, count do
                    local frameOk, button = pcall(getFrame, container, groupKey, index)
                    if frameOk then
                        RegisterAuraButton(button, style, thresholdColorsDisabled)
                    end
                end
            end
        end
    end

    ScanAuraContainer(container, thresholdColorsDisabled)
end

local function ScanUnitFrame(frame)
    if not MCE:CanUseFrameAsTableKey(frame) then return end

    local buffFrame = MCE:SafeTableGet(frame, "BuffFrame")
    if not MCE:CanUseFrameAsTableKey(buffFrame) then
        buffFrame = MCE:SafeTableGet(frame, "buffFrame")
    end
    if MCE:CanUseFrameAsTableKey(buffFrame) then ScanAuraContainer(buffFrame) end

    local debuffFrame = MCE:SafeTableGet(frame, "DebuffFrame")
    if not MCE:CanUseFrameAsTableKey(debuffFrame) then
        debuffFrame = MCE:SafeTableGet(frame, "debuffFrame")
    end
    if MCE:CanUseFrameAsTableKey(debuffFrame) then ScanAuraContainer(debuffFrame) end

    local auraFrame = MCE:SafeTableGet(frame, "AuraFrame")
    if not MCE:CanUseFrameAsTableKey(auraFrame) then
        auraFrame = MCE:SafeTableGet(frame, "auraFrame")
    end
    if MCE:CanUseFrameAsTableKey(auraFrame) then ScanAuraContainer(auraFrame) end

    -- Public custom unit-frame implementations commonly expose their 12.1
    -- AuraContainer directly even though Blizzard's native container is
    -- restricted and cannot be enumerated by addon code.
    local customContainer = MCE:SafeTableGet(frame, "AuraContainer")
        or MCE:SafeTableGet(frame, "auras")
    if MCE:CanUseFrameAsTableKey(customContainer) then
        ScanCustomAuraContainer(customContainer)
    end
end

local function ScanBetterBlizzFrames()
    local bbf = _G.BBF
    local hosts = type(bbf) == "table" and MCE:SafeTableGet(bbf, "auraHosts") or nil
    if type(hosts) ~= "table" then
        return false
    end

    local found = false
    for _, hostKey in ipairs(BETTERBLIZZ_HOST_KEYS) do
        local host = MCE:SafeTableGet(hosts, hostKey)
        if type(host) == "table" then
            found = true
            for _, containerKey in ipairs(BETTERBLIZZ_CONTAINER_KEYS) do
                local container = MCE:SafeTableGet(host, containerKey)
                if MCE:CanUseFrameAsTableKey(container) then
                    ScanCustomAuraContainer(container, true)
                end
            end
        end
    end
    return found
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

-- Dispel borders are parented to the button rather than the higher-level
-- overlay frame so the cooldown countdown text, which StyleEngine raises
-- to a high OVERLAY sublevel, still draws above them.
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

local function InitializeCustomAuraButton(host, button, group)
    if not button then return end

    -- CustomAuraContainer reserves the configured cell size but does not
    -- resize the AuraButton itself (unlike Blizzard's native target layout).
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

    local meta = { isMine = group.isMine, count = count, button = button }
    EnsureNativeDurationText(button, cooldown, meta)
    trackedCooldownMeta[cooldown] = meta
    host.cooldowns[#host.cooldowns + 1] = cooldown
    -- Register before binding the Duration. SetDurationCooldown immediately
    -- calls the cooldown API, and HookBridge must already know that this public
    -- output cooldown is intentionally allowed beneath a restricted AuraButton.
    MarkTrackedCooldown(cooldown, meta)

    InitializeAuraBorder(button, icon, not group.helpful, group.size)

    button:SetApplicationCount(count)
    button:SetDurationCooldown(cooldown)
    meta.nativeDurationTextReady = meta.nativeDurationText == true
    MarkTrackedCooldown(cooldown, meta)

    -- The provider applies its access restriction after this callback. Bind
    -- the secure duration text and apply all static styling while its public
    -- output regions are still configurable.
    local styleEngine = MCE:GetModule("StyleEngine", true)
    if styleEngine then
        styleEngine:ApplyStyle(cooldown, CATEGORY.Unitframe)
    else
        RefreshNativeDurationText(cooldown)
    end

    button:SetTooltipAnchorPoint("ANCHOR_BOTTOMLEFT", 0, 0)
end

local function GetNativeAuraContainer(root)
    local method = MCE:SafeTableGet(root, "GetAuraContainer")
    if type(method) ~= "function" then return nil end
    local ok, container = pcall(method, root)
    return ok and container or nil
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

local function ConfigureGroupLayouts(host)
    local root = host.root
    local isFriendly = false
    if type(UnitIsFriend) == "function" then
        local ok, result = pcall(UnitIsFriend, "player", host.unit)
        if ok then
            isFriendly = GetAccessibleBoolean(result) == true
        end
    end

    local orderedKeys
    if isFriendly then
        orderedKeys = { "BuffMine", "BuffOther", "DebuffMine", "DebuffOther" }
    else
        orderedKeys = { "DebuffMine", "DebuffOther", "BuffMine", "BuffOther" }
    end

    local firstOfSecondType = orderedKeys[3]
    for index, groupKey in ipairs(orderedKeys) do
        local size = (groupKey == "BuffMine" or groupKey == "DebuffMine") and 21 or 17
        SafeCall(host.container, "SetAuraGroupLayout", groupKey, {
            elementSpacing = 3,
            lineSpacing = 3,
            groupLineSpacing = 3,
            forceNewLine = groupKey == firstOfSecondType,
            elementWidth = size,
            elementHeight = size,
            layoutIndex = index,
        })
    end

    local buffsOnTop = GetAccessibleBoolean(MCE:SafeTableGet(root, "buffsOnTop")) == true
    local point = buffsOnTop and "BOTTOMLEFT" or "TOPLEFT"
    local relativePoint = buffsOnTop and "TOPLEFT" or "BOTTOMLEFT"
    local verticalDirection = buffsOnTop and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down
    local offsetY = buffsOnTop and -6 or 9

    SafeCall(host.container, "SetFlowLayoutAnchorPoint", point)
    SafeCall(host.container, "SetFlowLayoutGrowthDirection", AnchorUtil.FlowDirection.Right, verticalDirection)
    SafeCall(host.container, "ClearAllPoints")
    SafeCall(host.container, "SetPoint", point, host.anchor, relativePoint, 5, offsetY)
    host.buffsOnTop = buffsOnTop
end

local function ConfigureSpellBar(host)
    local spellBar = host.spellBar
    if not MCE:CanUseFrameAsTableKey(spellBar) then return end

    if host.buffsOnTop then
        if host.spellBarAnchored then
            SafeCall(spellBar, "AdjustPosition")
            host.spellBarAnchored = nil
        end
        return
    end

    SafeCall(spellBar, "ClearAllPoints")
    local ok = SafeCall(spellBar, "SetPoint", "TOPLEFT", host.container, "BOTTOMLEFT", 18, -10)
    if ok then
        host.spellBarAnchored = true
    end
end

local function RestoreSpellBar(host)
    if not host.spellBarAnchored then return end
    SafeCall(host.spellBar, "AdjustPosition")
    host.spellBarAnchored = nil
end

local function SuppressNativeContainer(host)
    local native = host.native
    if not native then return end

    SafeCall(native, "SetMaxBuffs", 0)
    SafeCall(native, "SetMaxDebuffs", 0)
    SafeCall(native, "SetEnabled", false)
    SafeCall(native, "SetUnit", "none")
    host.nativeSuppressed = true
end

local function RestoreNativeContainer(host)
    if not host.native or not host.nativeSuppressed then return end

    SafeCall(host.native, "SetUnit", host.unit)
    SafeCall(host.native, "SetMaxBuffs", host.nativeMaxBuffs)
    SafeCall(host.native, "SetMaxDebuffs", host.nativeMaxDebuffs)
    SafeCall(host.native, "SetEnabled", host.nativeWasEnabled ~= false)
    SafeCall(host.native, "Show")

    host.syncing = true
    SafeCall(host.root, "ConfigureAuraContainer")
    SafeCall(host.native, "UpdateAllAuras")
    host.syncing = nil
    host.nativeSuppressed = nil
end

local function ActivateCustomHost(host)
    ConfigureGroupLayouts(host)
    SuppressNativeContainer(host)

    SafeCall(host.container, "SetUnit", host.unit)
    SafeCall(host.container, "SetEnabled", true)
    SafeCall(host.container, "Show")
    SafeCall(host.container, "UpdateAllAuras")
    ConfigureSpellBar(host)
    host.active = true

    for _, cooldown in ipairs(host.cooldowns) do
        local meta = trackedCooldownMeta[cooldown]
        if meta then MarkTrackedCooldown(cooldown, meta) end
    end
end

local function DeactivateCustomHost(host, restoreNative)
    SafeCall(host.container, "SetEnabled", false)
    SafeCall(host.container, "Hide")
    RestoreSpellBar(host)
    if restoreNative then
        RestoreNativeContainer(host)
    end
    host.active = nil
end

local function CreateCustomHost(rootInfo)
    if not AnchorUtil or not AnchorUtil.FlowLayoutAxis or not AnchorUtil.FlowDirection then
        return nil
    end

    local root = _G[rootInfo.name]
    if not MCE:CanUseFrameAsTableKey(root) then return nil end

    local native = GetNativeAuraContainer(root)
    if not native then return nil end

    local nativeEnabled = true
    local enabledOk, enabled = SafeCall(native, "IsEnabled")
    if enabledOk then
        local accessibleEnabled = GetAccessibleBoolean(enabled)
        if accessibleEnabled ~= nil then
            nativeEnabled = accessibleEnabled
        end
    end
    if not nativeEnabled then
        -- Another addon already owns target/focus aura presentation.
        return nil
    end

    local parent = GetCustomContainerParent(root)
    local ok, container = pcall(CreateFrame, "AuraContainer", nil, parent, "CustomAuraContainerTemplate")
    if not ok or not MCE:CanUseFrameAsTableKey(container) then
        return nil
    end

    local host = {
        name = rootInfo.name,
        root = root,
        unit = rootInfo.unit,
        native = native,
        nativeWasEnabled = nativeEnabled,
        nativeMaxBuffs = GetConfiguredMaxCount(root, "maxBuffs", 32),
        nativeMaxDebuffs = GetConfiguredMaxCount(root, "maxDebuffs", 16),
        container = container,
        anchor = GetCustomContainerAnchor(root),
        spellBar = MCE:SafeTableGet(root, "spellbar") or _G[rootInfo.spellBar],
        cooldowns = {},
    }

    SafeCall(container, "SetSize", 1, 1)
    SafeCall(container, "SetFlowLayoutAxis", AnchorUtil.FlowLayoutAxis.Horizontal)
    SafeCall(container, "SetFlowLayoutPadding", 0, 0, 0, 0)
    SafeCall(container, "SetFlowLayoutMaximumLineSize", 122)

    for _, group in ipairs(CUSTOM_GROUPS) do
        local filterString = BuildFilterString(group)
        if not filterString then
            SafeCall(container, "Hide")
            return nil
        end

        local maxCount = group.helpful
            and GetConfiguredMaxCount(root, "maxBuffs", group.maxCount)
            or GetConfiguredMaxCount(root, "maxDebuffs", group.maxCount)
        local added = SafeCall(container, "AddAuraGroup", group.key, filterString, {
            maxFrameCount = maxCount,
            layout = {
                elementSpacing = 3,
                lineSpacing = 3,
                elementWidth = group.size,
                elementHeight = group.size,
            },
            initializeFrame = function(button)
                InitializeCustomAuraButton(host, button, group)
            end,
        })
        if not added then
            SafeCall(container, "SetEnabled", false)
            SafeCall(container, "Hide")
            return nil
        end
    end

    ConfigureGroupLayouts(host)
    customHosts[rootInfo.name] = host
    return host
end

local function BetterBlizzOwnsHost(rootInfo)
    local bbf = _G.BBF
    local hosts = type(bbf) == "table" and MCE:SafeTableGet(bbf, "auraHosts") or nil
    local host = type(hosts) == "table" and MCE:SafeTableGet(hosts, rootInfo.unit) or nil
    if type(host) ~= "table" then
        return false
    end

    for _, containerKey in ipairs(BETTERBLIZZ_CONTAINER_KEYS) do
        if MCE:CanUseFrameAsTableKey(MCE:SafeTableGet(host, containerKey)) then
            return true
        end
    end
    return false
end

local function IsBetterBlizzTargetOrFocusContainer(container)
    local bbf = _G.BBF
    local hosts = type(bbf) == "table" and MCE:SafeTableGet(bbf, "auraHosts") or nil
    if type(hosts) ~= "table" or not MCE:CanUseFrameAsTableKey(container) then
        return false
    end

    for _, hostKey in ipairs(BETTERBLIZZ_HOST_KEYS) do
        local host = MCE:SafeTableGet(hosts, hostKey)
        if type(host) == "table" then
            for _, containerKey in ipairs(BETTERBLIZZ_CONTAINER_KEYS) do
                if container == MCE:SafeTableGet(host, containerKey) then
                    return true
                end
            end
        end
    end
    return false
end

local function IsBetterBlizzTargetOrFocusButton(button)
    if not MCE:CanUseFrameAsTableKey(button) then
        return false
    end

    local current = button
    for _ = 1, UF.MaxAncestorDepth do
        if IsBetterBlizzTargetOrFocusContainer(current) then
            return true
        end
        current = GetParentSafe(current)
        if not current then break end
    end
    return false
end

local function FinalizeBetterBlizzAuraButtonStyle(button)
    if not IsBetterBlizzTargetOrFocusButton(button) then return end

    local cooldown = GetButtonCooldown(button)
    if not MCE:CanUseFrameAsTableKey(cooldown) then return end

    local meta = trackedCooldownMeta[cooldown] or {
        button = button,
        count = GetButtonCount(button),
        isMine = GetButtonLargeAuraState(button),
    }
    meta.button = button
    if meta.count == nil then
        meta.count = GetButtonCount(button)
    end
    if meta.isMine == nil then
        meta.isMine = GetButtonLargeAuraState(button)
    end

    -- If an earlier generic hook provisionally created MiniCE duration text,
    -- hide it now. BBF's own cooldown timer is the sole visible color owner.
    if meta.nativeDurationText == true and meta.durationTextHolder then
        local setAlpha = MCE:SafeTableGet(meta.durationTextHolder, "SetAlpha")
        if type(setAlpha) == "function" then
            pcall(setAlpha, meta.durationTextHolder, 0)
        end
    end

    -- BBF creates its timer at the end of InitAuraButton. Retain the public
    -- FontString for MiniCE's font/placement styling, but leave all duration
    -- color decisions to BBF's own threshold system.
    local countdownText = MCE:SafeTableGet(button, "bbfTimer")
    if not IsObjectTypeSafe(countdownText, "FontString") then
        countdownText = GetCooldownCountdownText(cooldown)
    end
    meta.countdownText = countdownText
    meta.durationText = nil
    meta.durationTextHolder = nil
    meta.nativeDurationText = false
    meta.nativeDurationTextReady = false
    meta.thresholdColorsDisabled = true
    MarkTrackedCooldown(cooldown, meta)

    local state = frameState[cooldown]
    if state then
        state.textRegions = nil
        state.unitFrameBoundDurationCurve = nil
        state.unitFrameBoundDurationFormatter = nil
        state.unitFrameBoundDurationText = nil
    end

    local styleEngine = MCE:GetModule("StyleEngine", true)
    if styleEngine then
        styleEngine:ApplyStyle(cooldown, CATEGORY.Unitframe)
    end
end

local function InstallBetterBlizzAuraStyleWrapper()
    if betterBlizzAuraStyleWrapped then return true end

    local mixin = _G.CustomAuraContainerSharedMixin
    local originalAddAuraGroup = type(mixin) == "table"
        and MCE:SafeTableGet(mixin, "AddAuraGroup") or nil
    if type(originalAddAuraGroup) ~= "function" then
        return false
    end

    local wrappedAddAuraGroup
    wrappedAddAuraGroup = function(container, groupKey, filter, options)
        local initializeFrame = type(options) == "table"
            and MCE:SafeTableGet(options, "initializeFrame") or nil
        if not IsBetterBlizzTargetOrFocusContainer(container)
           or type(initializeFrame) ~= "function" then
            return originalAddAuraGroup(container, groupKey, filter, options)
        end

        -- Capture BBF's public text and stack regions after its initializer has
        -- created them, but before the provider applies access restrictions.
        local wrappedOptions = {}
        for key, value in pairs(options) do
            wrappedOptions[key] = value
        end
        wrappedOptions.initializeFrame = function(button, ...)
            initializeFrame(button, ...)
            FinalizeBetterBlizzAuraButtonStyle(button)
        end
        return originalAddAuraGroup(container, groupKey, filter, wrappedOptions)
    end

    local ok = pcall(function()
        mixin.AddAuraGroup = wrappedAddAuraGroup
    end)
    betterBlizzAuraStyleWrapped = ok and mixin.AddAuraGroup == wrappedAddAuraGroup
    return betterBlizzAuraStyleWrapped
end

local function SyncCustomHost(rootInfo)
    local host = customHosts[rootInfo.name]

    -- BetterBlizzFrames also uses the supported CustomAuraContainer API. When
    -- its target/focus host exists, style those public cooldowns and keep the
    -- MiniCE-owned fallback hidden so only one aura presentation is visible.
    if BetterBlizzOwnsHost(rootInfo) then
        if host and host.active then
            DeactivateCustomHost(host, false)
        end
        ScanBetterBlizzFrames()
        return
    end

    if not IsUnitFrameCategoryEnabled() then
        if host and host.active then
            DeactivateCustomHost(host, true)
        end
        return
    end

    host = host or CreateCustomHost(rootInfo)
    if not host then return end

    host.syncing = true
    ActivateCustomHost(host)
    host.syncing = nil
end

local function ScheduleHostSync(rootName)
    if pendingRootSync[rootName] then return end
    pendingRootSync[rootName] = true

    C_Timer_After(0, function()
        pendingRootSync[rootName] = nil
        local rootInfo = CUSTOM_ROOT_BY_NAME[rootName]
        if rootInfo then
            SyncCustomHost(rootInfo)
        end
    end)
end

local function HookBlizzardRoot(rootInfo)
    local root = _G[rootInfo.name]
    if not MCE:CanUseFrameAsTableKey(root) or hookedRoots[root] then
        return
    end
    hookedRoots[root] = true

    local configure = MCE:SafeTableGet(root, "ConfigureAuraContainer")
    if type(configure) == "function" then
        hooksecurefunc(root, "ConfigureAuraContainer", function()
            local host = customHosts[rootInfo.name]
            if not (host and host.syncing) then
                ScheduleHostSync(rootInfo.name)
            end
        end)
    end

    local updateAuras = MCE:SafeTableGet(root, "UpdateAuras")
    if type(updateAuras) == "function" then
        hooksecurefunc(root, "UpdateAuras", function()
            ScheduleHostSync(rootInfo.name)
        end)
    end
end

local function ScheduleBetterBlizzRefresh()
    if betterBlizzRefreshPending then return end
    betterBlizzRefreshPending = true
    C_Timer_After(0, function()
        betterBlizzRefreshPending = false
        MCE:ForceUpdateAll(true)
    end)
end

local function HookBetterBlizzFrames()
    InstallBetterBlizzAuraStyleWrapper()
    if betterBlizzHooked then return end

    local bbf = _G.BBF
    if type(bbf) ~= "table"
       or type(MCE:SafeTableGet(bbf, "HookPlayerAndTargetAuras")) ~= "function" then
        return
    end

    betterBlizzHooked = true

    if type(MCE:SafeTableGet(bbf, "UpdateUserAuraSettings")) == "function" then
        hooksecurefunc(bbf, "UpdateUserAuraSettings", function()
            -- BBF refreshes these settings immediately before it creates the
            -- Target/Focus AuraContainers. Retry the Blizzard AuraButton hook
            -- here so every pooled button is captured while it is still public.
            HookCustomAuraButtonBindings()
        end)
    end

    hooksecurefunc(bbf, "HookPlayerAndTargetAuras", function()
        -- BBF may have just taken ownership of the native aura slots and
        -- created a new pool of public cooldowns. Rebuild once after its setup
        -- finishes so MiniCE hides its fallback and styles BBF's pool.
        ScheduleBetterBlizzRefresh()
    end)

    if type(MCE:SafeTableGet(bbf, "RestyleAuraButtons")) == "function" then
        hooksecurefunc(bbf, "RestyleAuraButtons", ScheduleBetterBlizzRefresh)
    end
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.Unitframe, self)

    HookCustomAuraButtonBindings()
    HookBetterBlizzFrames()
    for _, rootInfo in ipairs(CUSTOM_ROOTS) do
        HookBlizzardRoot(rootInfo)
    end

    local eventFrame = CreateFrame("Frame")
    self.eventFrame = eventFrame
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
    eventFrame:RegisterUnitEvent("UNIT_FACTION", "target", "focus")
    eventFrame:SetScript("OnEvent", function(_, event, arg1)
        if event == "ADDON_LOADED" then
            if arg1 == "BetterBlizzFrames" then
                HookCustomAuraButtonBindings()
                HookBetterBlizzFrames()
                ScheduleBetterBlizzRefresh()
            elseif arg1 == "Blizzard_AuraContainer" then
                HookCustomAuraButtonBindings()
            end
            return
        end

        if event == "PLAYER_TARGET_CHANGED" then
            ScheduleHostSync("TargetFrame")
        elseif event == "PLAYER_FOCUS_CHANGED" then
            ScheduleHostSync("FocusFrame")
        elseif event == "UNIT_FACTION" then
            ScheduleHostSync(arg1 == "focus" and "FocusFrame" or "TargetFrame")
        else
            for _, rootInfo in ipairs(CUSTOM_ROOTS) do
                ScheduleHostSync(rootInfo.name)
            end
        end
    end)
end

function Adapter:OnDisable()
    if self.eventFrame then
        self.eventFrame:UnregisterAllEvents()
        self.eventFrame:SetScript("OnEvent", nil)
        self.eventFrame = nil
    end

    for _, rootInfo in ipairs(CUSTOM_ROOTS) do
        pendingRootSync[rootInfo.name] = nil
        local host = customHosts[rootInfo.name]
        if host and host.active then
            DeactivateCustomHost(host, not BetterBlizzOwnsHost(rootInfo))
        end
    end
end

function Adapter:Rebuild()
    RegisterKnownTrackedCooldowns()
    HookBetterBlizzFrames()
    ScanBetterBlizzFrames()

    for _, rootInfo in ipairs(CUSTOM_ROOTS) do
        HookBlizzardRoot(rootInfo)
        SyncCustomHost(rootInfo)
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

function Adapter:TryClaim(cooldown)
    if not MCE:CanUseFrameAsTableKey(cooldown) then return nil end
    if trackedCooldownMeta[cooldown] then return CATEGORY.Unitframe end

    -- MiniAuras cooldowns carry the MiniAuras_ prefix; skip them entirely.
    if IsMiniAurasFrame(cooldown) then return nil end

    local current = GetParentSafe(cooldown)
    local customAuraButton
    if current
       and type(MCE:SafeTableGet(current, "GetDurationCooldown")) == "function"
       and type(MCE:SafeTableGet(current, "SetDurationCooldown")) == "function" then
        customAuraButton = current
    end
    local foundCustomTargetContainer = false
    local function ClaimUnitFrame()
        if foundCustomTargetContainer then
            local isBetterBlizzButton = IsBetterBlizzTargetOrFocusButton(customAuraButton)
            MarkTrackedCooldown(cooldown, {
                isMine = GetButtonLargeAuraState(customAuraButton),
                count = GetButtonCount(customAuraButton),
                button = customAuraButton,
                thresholdColorsDisabled = isBetterBlizzButton,
            })
        end
        return CATEGORY.Unitframe
    end

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
            -- During an in-instance reload, a custom provider's initialize
            -- callback is the last moment its AuraButton ancestry is public.
            -- Remember the cooldown now; after the callback the button becomes
            -- forbidden, while the cooldown remains a supported output widget.
            foundCustomTargetContainer = true
        end

        for _, rootName in ipairs(UF.BlizzardRoots) do
            if name == rootName then return ClaimUnitFrame() end
        end

        for _, pattern in ipairs(UF.ThirdPartyPatterns) do
            if strfind(name, pattern, 1, true) then return ClaimUnitFrame() end
        end

        if unitToken and FALLBACK_UNIT_TOKENS[unitToken] then
            if name ~= "" and (strfind(name, "Frame", 1, true)
                or strfind(name, "UF", 1, true)) then
                return ClaimUnitFrame()
            end
        end

        current = GetParentSafe(current)
    end

    if foundCustomTargetContainer then
        return ClaimUnitFrame()
    end
    return nil
end

do
    local durationHooked = false
    local countHooked = false
    local customAuraButtonAPI
    local customAuraButtonProbe
    local customAuraContainerLoadAttempted = false

    local function CreateCustomAuraButtonProbe()
        local createOk, probe = pcall(
            CreateFrame, "AuraButton", nil, UIParent, "CustomAuraButtonTemplate")
        if not createOk or not probe then
            return nil
        end

        pcall(probe.Hide, probe)
        local meta = getmetatable(probe)
        local api = meta and meta.__index or nil
        if type(api) ~= "table" then
            return nil
        end

        customAuraButtonProbe = probe
        return api
    end

    local function GetCustomAuraButtonAPI()
        if customAuraButtonAPI then
            return customAuraButtonAPI
        end

        local api = CreateCustomAuraButtonProbe()
        if not api and not customAuraContainerLoadAttempted then
            customAuraContainerLoadAttempted = true
            if C_AddOns and type(C_AddOns.LoadAddOn) == "function" then
                pcall(C_AddOns.LoadAddOn, "Blizzard_AuraContainer")
                api = CreateCustomAuraButtonProbe()
            end
        end

        if not api then return nil end
        customAuraButtonAPI = api
        return customAuraButtonAPI
    end

    HookCustomAuraButtonBindings = function()
        local api = GetCustomAuraButtonAPI()
        if not api then return end

        if not durationHooked
           and type(MCE:SafeTableGet(api, "SetDurationCooldown")) == "function" then
            local hookOk = pcall(hooksecurefunc, api, "SetDurationCooldown", function(button, cooldown)
                local category
                local isBetterBlizzButton = false
                if MCE:CanUseFrameAsTableKey(cooldown) then
                    isBetterBlizzButton = IsBetterBlizzTargetOrFocusButton(button)
                    category = isBetterBlizzButton and CATEGORY.Unitframe
                        or Adapter:TryClaim(cooldown)
                end

                local meta = cooldown and trackedCooldownMeta[cooldown] or nil
                if not meta and category == CATEGORY.Unitframe
                   and MCE:CanUseFrameAsTableKey(button) then
                    meta = {
                        button = button,
                        count = GetButtonCount(button),
                        isMine = GetButtonLargeAuraState(button),
                        thresholdColorsDisabled = isBetterBlizzButton,
                    }
                    MarkTrackedCooldown(cooldown, meta)
                end
                if not meta or not MCE:CanUseFrameAsTableKey(button) then return end

                if isBetterBlizzButton then
                    -- BBF has not created bbfTimer yet. Its wrapped initializer
                    -- captures the FontString for styling without binding a
                    -- MiniCE duration-color curve to it.
                    meta.thresholdColorsDisabled = true
                    meta.nativeDurationText = false
                    meta.nativeDurationTextReady = false
                else
                    EnsureNativeDurationText(button, cooldown, meta)
                    meta.nativeDurationTextReady = meta.nativeDurationText == true
                end

                if meta.isMine == nil then
                    meta.isMine = GetButtonLargeAuraState(button)
                end
                MarkTrackedCooldown(cooldown, meta)

                -- BBF applies its tier size later in the same initialize
                -- callback. Capture that public layout choice before the
                -- provider restricts the button; it preserves MiniCE's legacy
                -- large-aura fallback for Only Mine in an instance reload.
                if not hookedCustomAuraButtons[button]
                   and type(MCE:SafeTableGet(button, "SetSize")) == "function" then
                    local hookOk = pcall(hooksecurefunc, button, "SetSize", function(_, width)
                        if type(width) == "number"
                           and not MCE:IsSecretValue(width)
                           and addon.CanAccessAllValues(width)
                           and width > 0 then
                            local currentMeta = trackedCooldownMeta[cooldown]
                            if currentMeta then
                                currentMeta.isMine = width > 20
                                MarkTrackedCooldown(cooldown, currentMeta)
                            end
                        end
                    end)
                    if hookOk then
                        hookedCustomAuraButtons[button] = true
                    end
                end

                if not isBetterBlizzButton
                   and (category == CATEGORY.Unitframe or (Registry
                   and Registry:GetCategory(cooldown) == CATEGORY.Unitframe)) then
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
                local cooldown = GetButtonCooldown(button)
                local meta = cooldown and trackedCooldownMeta[cooldown] or nil
                if not meta and Registry and cooldown
                   and Registry:GetCategory(cooldown) == CATEGORY.Unitframe then
                    meta = {}
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

-- Install during file loading when Blizzard_AuraContainer is already present;
-- OnEnable retries for load-order variants. This captures public output
-- widgets inside third-party initialize callbacks before 12.1 restricts them.
HookCustomAuraButtonBindings()
InstallBetterBlizzAuraStyleWrapper()
HookBetterBlizzFrames()
