local addonName, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local L = LibStub("AceLocale-3.0"):GetLocale(C.Addon.AceName)
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

-- === UPVALUE LOCALS ===
local format = string.format
local sort = table.sort
local strtrim = strtrim

-- Retrieve version dynamically from TOC
local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "Version") or C.Addon.VersionFallback

-- LibSharedMedia integration (optional – silently absent if not installed)
local LSM = LibStub("LibSharedMedia-3.0", true)

-- === SHARED LOOKUP TABLES ===

-- Base fonts always available (WoW built-ins + addon-bundled fonts)
local FONT_OPTIONS_BASE = C.FontOptionsBase

--- Returns a merged font table: base fonts + any fonts registered in LibSharedMedia.
--- Declared as a function so the values are evaluated lazily each time the options
--- panel opens, picking up fonts registered by other addons after this file loads.
local function GetFontOptions()
    local opts = {}
    local usedNames = {}

    if LSM then
        for name, path in pairs(LSM:HashTable("font")) do
            -- LSM entries take priority
            if not opts[path] and not usedNames[name:lower()] then
                opts[path] = name
                usedNames[name:lower()] = true
            end
        end
    end

    -- Add base fonts only when not already claimed by LSM (path + display name)
    for path, label in pairs(FONT_OPTIONS_BASE) do
        if not opts[path] and not usedNames[label:lower()] then
            opts[path] = label
            usedNames[label:lower()] = true
        end
    end
    
    return opts
end

local OUTLINE_OPTIONS = {
    [C.Style.FontStyles.None] = L["None"],
    [C.Style.FontStyles.Outline] = L["Outline"],
    [C.Style.FontStyles.ThickOutline] = L["Thick"],
    [C.Style.FontStyles.Monochrome] = L["Mono"],
}

local ANCHOR_OPTIONS = {
    [C.Style.Anchors.Center] = L["Center"],
    [C.Style.Anchors.TopLeft] = L["Top Left"],
    [C.Style.Anchors.TopRight] = L["Top Right"],
    [C.Style.Anchors.BottomLeft] = L["Bottom Left"],
    [C.Style.Anchors.BottomRight] = L["Bottom Right"],
}

-- =========================================================================
-- HELPERS  – DRY accessor builders to eliminate repetitive get/set closures
-- =========================================================================

--- Returns a getter function for `MCE.db.profile.categories[key][field]`.
local function CatGet(key, field, fallback)
    return function()
        local v = MCE.db.profile.categories[key][field]
        if v ~= nil then
            return v
        end
        return fallback
    end
end

local function CategoryNeedsFullScan(key)
    return key == C.Categories.MiniCC
        or key == C.Categories.SArena
        or key == C.Categories.TellMeWhen
end

--- Returns a setter function that writes and refreshes.
local function CatSet(key, field)
    return function(_, val)
        MCE.db.profile.categories[key][field] = val
        MCE:ForceUpdateAll(CategoryNeedsFullScan(key))
        AceConfigRegistry:NotifyChange(addonName)
    end
end

--- Returns a setter function for sliders that writes immediately and refreshes once dragging stops.
local function CatRangeSet(key, field)
    return function(_, val)
        MCE.db.profile.categories[key][field] = val
        MCE:RequestDebouncedOptionRefresh(CategoryNeedsFullScan(key))
    end
end

local function DebouncedRangeSet(setter, fullScan)
    return function(...)
        setter(...)
        MCE:RequestDebouncedOptionRefresh(fullScan)
    end
end

local function SectionSpacer(order, hidden)
    return {
        type = "description",
        order = order,
        name = " ",
        fontSize = "small",
        hidden = hidden,
    }
end

local function RowBreak(order, hidden)
    return {
        type = "description",
        order = order,
        name = "",
        width = "full",
        hidden = hidden,
    }
end

local function BuildCategoryDescription(desc)
    if not desc then return nil end
    return "|cff9fb3c8" .. desc .. "|r"
end

--- Returns a colour getter (r,g,b,a).
local function CatColorGet(key, field)
    return function()
        local c = MCE.db.profile.categories[key][field]
        return c.r, c.g, c.b, c.a
    end
end

--- Returns a colour setter.
local function CatColorSet(key, field)
    return function(_, r, g, b, a)
        local c = MCE.db.profile.categories[key][field]
        c.r, c.g, c.b, c.a = r, g, b, a
        MCE:ForceUpdateAll(CategoryNeedsFullScan(key))
    end
end

local function ProfileTableGet(tableKey, field, fallback)
    return function()
        local group = MCE.db.profile[tableKey]
        local v = group and group[field]
        if v ~= nil then
            return v
        end
        return fallback
    end
end

local function ProfileTableSet(tableKey, field)
    return function(_, val)
        MCE.db.profile[tableKey][field] = val
        MCE:ForceUpdateAll(true)
        AceConfigRegistry:NotifyChange(addonName)
    end
end

local function ProfileTableRangeSet(tableKey, field)
    return function(_, val)
        MCE.db.profile[tableKey][field] = val
        MCE:RequestDebouncedOptionRefresh(true)
    end
end

local function ProfileTableColorGet(tableKey, field)
    return function()
        local c = MCE.db.profile[tableKey][field]
        return c.r, c.g, c.b, c.a
    end
end

local function ProfileTableColorSet(tableKey, field)
    return function(_, r, g, b, a)
        local c = MCE.db.profile[tableKey][field]
        c.r, c.g, c.b, c.a = r, g, b, a
        MCE:ForceUpdateAll(true)
    end
end

local function GetCompactPartyAuraOptionsConfig()
    local profile = MCE.db and MCE.db.profile
    if not profile then
        return nil
    end

    profile.compactPartyAuraText = MCE.EnsureCompactPartyAuraTextConfig(profile.compactPartyAuraText)
    return profile.compactPartyAuraText
end

local function GetDurationTextColorsConfig()
    local profile = MCE.db and MCE.db.profile
    if not profile then return nil end

    profile.durationTextColors = MCE.EnsureDurationTextColorConfig(profile.durationTextColors)
    return profile.durationTextColors
end

local function GetAllowThresholdDefault(sourceKey)
    local defaults = C.Defaults and C.Defaults.AllowThresholdColorsByCategory
    return defaults and defaults[sourceKey] == true or false
end

local function DurationColorsEnabled()
    local config = GetDurationTextColorsConfig()
    return config and config.enabled or false
end

local function DurationColorsDisabled()
    return not DurationColorsEnabled()
end

local function ShinyAurasAdapterEnabled()
    return MCE:IsShinyAurasAdapterEnabled()
end

local function SetShinyAurasAdapterEnabled(_, value)
    local profile = MCE.db and MCE.db.profile
    if not profile then return end

    profile.shinyAurasAdapterEnabled = value
    MCE:MarkReloadRequired()
    MCE:ForceUpdateAll(true)
    AceConfigRegistry:NotifyChange(addonName)
end

local function ElvUIAdapterEnabled()
    return MCE:IsElvUIAdapterEnabled()
end

local function SetElvUIAdapterEnabled(_, value)
    local profile = MCE.db and MCE.db.profile
    if not profile then return end

    profile.elvuiAdapterEnabled = value
    MCE:MarkReloadRequired()
    MCE:ForceUpdateAll(true)
    AceConfigRegistry:NotifyChange(addonName)
end

local function DurationOffsetGet()
    local config = GetDurationTextColorsConfig()
    return config.offset
end

local function DurationOffsetSet(_, val)
    local config = GetDurationTextColorsConfig()
    config.offset = val
    MCE:RequestDebouncedOptionRefresh(true)
end

local function DurationThresholdValueGet(index)
    return function()
        local config = GetDurationTextColorsConfig()
        return config.thresholds[index].threshold
    end
end

local function DurationThresholdValueSet(index)
    return DebouncedRangeSet(function(_, val)
        local config = GetDurationTextColorsConfig()
        config.thresholds[index].threshold = val
    end)
end

local function DurationThresholdColorGet(index)
    return function()
        local c = GetDurationTextColorsConfig().thresholds[index].color
        return c.r, c.g, c.b, c.a
    end
end

local function DurationThresholdColorSet(index)
    return function(_, r, g, b, a)
        local c = GetDurationTextColorsConfig().thresholds[index].color
        c.r, c.g, c.b, c.a = r, g, b, a
        MCE:ForceUpdateAll(true)
    end
end

local function DefaultDurationColorGet()
    local c = GetDurationTextColorsConfig().defaultColor
    return c.r, c.g, c.b, c.a
end

local function DefaultDurationColorSet(_, r, g, b, a)
    local c = GetDurationTextColorsConfig().defaultColor
    c.r, c.g, c.b, c.a = r, g, b, a
    MCE:ForceUpdateAll(true)
end

local function IsCatDisabled(key)
    return not MCE.db.profile.categories[key].enabled
end

local function IsStackHidden(key)
    local config = MCE.db.profile.categories[key]
    return not config.stackEnabled or config.hideStackText
end

local function ResolveOptionValue(value)
    if type(value) == "function" then
        local ok, result = pcall(value)
        if ok then
            return result
        end
        return nil
    end

    return value
end

local function IsOptionHidden(option)
    local hidden = ResolveOptionValue(option.hidden)
    return hidden and true or false
end

local function BuildRootTreeDefinition()
    local options = MCE:GetOptions()
    local entries = {}

    for key, option in pairs(options.args or {}) do
        if option and option.type == "group" and not option.inline and not IsOptionHidden(option) then
            entries[#entries + 1] = {
                value = key,
                text = ResolveOptionValue(option.name) or key,
                disabled = false,
            }
        end
    end

    sort(entries, function(a, b)
        local optA = options.args[a.value] or {}
        local optB = options.args[b.value] or {}
        local orderA = optA.order or 100
        local orderB = optB.order or 100

        if orderA == orderB then
            return tostring(a.text):upper() < tostring(b.text):upper()
        end

        return orderA < orderB
    end)

    return entries
end

local function RefreshTreeWidgets(widget)
    if not widget then return end

    if widget.type == "TreeGroup" then
        widget:SetTree(BuildRootTreeDefinition())
    end

    if widget.children then
        for _, child in ipairs(widget.children) do
            RefreshTreeWidgets(child)
        end
    end
end

local function RefreshDynamicCategoryLabels()
    if not AceConfigDialog then return end

    local openFrame = AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames[addonName]
    if openFrame then
        RefreshTreeWidgets(openFrame)
    end

    local blizOptions = AceConfigDialog.BlizOptions and AceConfigDialog.BlizOptions[addonName]
    if blizOptions then
        for _, widget in pairs(blizOptions) do
            RefreshTreeWidgets(widget)
        end
    end
end

local function SetCategoryEnabled(key)
    return function(_, value)
        MCE.db.profile.categories[key].enabled = value
        MCE:MarkReloadRequired()
        MCE:ForceUpdateAll(CategoryNeedsFullScan(key))
        AceConfigRegistry:NotifyChange(addonName)
    end
end

local function SetDashboardCategoryEnabled(key)
    return function(_, value)
        MCE.db.profile.categories[key].enabled = value
        MCE:MarkReloadRequired()
        MCE:ForceUpdateAll(CategoryNeedsFullScan(key))
        AceConfigRegistry:NotifyChange(addonName)
        RefreshDynamicCategoryLabels()
    end
end

local function HasImportPayload()
    return type(MCE.profileImportBuffer) == "string" and strtrim(MCE.profileImportBuffer) ~= ""
end

local function BuildProfileImportExportOptions(order)
    return {
        type = "group",
        name = L["Import / Export"],
        order = order,
        args = {
            description = {
                type = "description",
                order = 0,
                width = "full",
                fontSize = "medium",
                name = "|cffbbbbbb" .. L["PROFILE_IMPORT_EXPORT_DESC"] .. "|r\n",
            },
            exportHeader = {
                type = "header",
                order = 1,
                name = L["Export current profile"],
            },
            exportButton = {
                type = "execute",
                order = 2,
                width = 0.9,
                name = L["Generate export"],
                func = function()
                    local exportString, err = MCE:ExportConfig()
                    if not exportString and err then
                        MCE:Print(err)
                    else
                        MCE:Print(L["Export string generated. Copy it with Ctrl+C."])
                    end

                    AceConfigRegistry:NotifyChange(addonName)
                end,
            },
            exportCode = {
                type = "input",
                order = 3,
                width = "full",
                multiline = 10,
                name = L["Export code"],
                desc = L["Generate an export string, then click inside this box and copy it with Ctrl+C."],
                get = function()
                    return MCE.profileExportBuffer or ""
                end,
                set = function(_, value)
                    MCE.profileExportBuffer = value or ""
                end,
            },
            importHeader = {
                type = "header",
                order = 10,
                name = L["Import profile"],
            },
            importCode = {
                type = "input",
                order = 11,
                width = "full",
                multiline = 10,
                name = L["Import code"],
                desc = L["Paste an exported string here, then click Import."],
                get = function()
                    return MCE.profileImportBuffer or ""
                end,
                set = function(_, value)
                    MCE.profileImportBuffer = value or ""
                end,
            },
            importButton = {
                type = "execute",
                order = 12,
                width = 0.9,
                name = L["Import"],
                disabled = function()
                    return not HasImportPayload()
                end,
                confirm = function()
                    return HasImportPayload()
                end,
                confirmText = L["Importing will overwrite the current profile settings. Continue?"],
                func = function()
                    local ok, err = MCE:ImportConfig(MCE.profileImportBuffer)
                    if not ok and err then
                        MCE:Print(err)
                    elseif ok then
                        MCE:MarkReloadRequired()
                    end

                    RefreshDynamicCategoryLabels()
                    AceConfigRegistry:NotifyChange(addonName)
                end,
            },
        },
    }
end

-- =========================================================================
-- OPTIONS BUILDER
-- =========================================================================

local function CreateCategoryOptions(order, name, key, desc)
    local disabledFn    = function() return IsCatDisabled(key) end
    local stackHiddenFn = function() return IsStackHidden(key) end
    local isCooldownManager = (key == C.Categories.CooldownManager)
    local isMiniCC = (key == C.Categories.MiniCC)
    local isSArena = (key == C.Categories.SArena)
    local isTellMeWhen = (key == C.Categories.TellMeWhen)
    local isUnitframe = (key == C.Categories.Unitframe)
    local isStackCategory = (key == C.Categories.Actionbar or key == C.Categories.Nameplate or key == C.Categories.CooldownManager or key == C.Categories.Unitframe)

    return {
        type = "group",
        hidden = function()
            return (isMiniCC and not MCE:IsMiniCCAvailable())
                or (isSArena and not MCE:IsSArenaAvailable())
                or (isTellMeWhen and not MCE:IsTellMeWhenAvailable())
        end,
        -- Dynamic name with status indicator (colored accent when active, dimmed when inactive)
        name = function()
            if not MCE.db or not MCE.db.profile then return name end
            local enabled = MCE.db.profile.categories[key].enabled
            if enabled then
                return "|cff33ff99" .. L["ON"] .. "|r  " .. name
            else
                return "|cff555555" .. L["OFF"] .. "|r  |cff888888" .. name .. "|r"
            end
        end,
        order = order,
        args = {
            -- ── 1. Main Toggle ──────────────────────────────────────────
            enableGroup = {
                type = "group", name = "", inline = true, order = 1,
                args = {
                    enabled = {
                        type = "toggle", order = 1, width = "full",
                        name = "|cff33ff99" .. format(L["Enable %s"], name) .. "|r",
                        desc = L["Toggle styling for this category."],
                        get = CatGet(key, "enabled"),
                        set = SetCategoryEnabled(key),
                    },
                    miniCCTestToggle = isMiniCC and {
                        type = "execute", order = 2, width = "1",
                        name = L["Toggle Test Icons"],
                        desc = L["Toggle MiniCC's built-in test icons using /minicc test."],
                        hidden = function() return not MCE:IsMiniCCAvailable() end,
                        func = function()
                            local handler = SlashCmdList and SlashCmdList.MINICC
                            if handler then
                                pcall(handler, "test")
                            else
                                MCE:Print(L["MiniCC test command is unavailable."])
                            end
                            MCE:ForceUpdateAll(true)
                        end,
                    } or nil,
                    sArenaTestToggle = isSArena and {
                        type = "execute", order = 2, width = "1",
                        name = L["Show Test Frames"],
                        desc = L["Show sArena test frames using /sarena test."],
                        hidden = function() return not MCE:IsSArenaAvailable() end,
                        func = function()
                            local handler = SlashCmdList and SlashCmdList.ACECONSOLE_SARENA
                            if handler then
                                pcall(handler, "test")
                                C_Timer.After(0, function()
                                    MCE:ForceUpdateAll(true)
                                end)
                            else
                                MCE:Print(L["sArena slash command is unavailable."])
                            end
                        end,
                    } or nil,
                    sArenaHideToggle = isSArena and {
                        type = "execute", order = 3, width = "1",
                        name = L["Hide Test Frames"],
                        desc = L["Hide sArena test frames using /sarena hide."],
                        hidden = function() return not MCE:IsSArenaAvailable() end,
                        func = function()
                            local handler = SlashCmdList and SlashCmdList.ACECONSOLE_SARENA
                            if handler then
                                pcall(handler, "hide")
                                C_Timer.After(0, function()
                                    MCE:ForceUpdateAll(true)
                                end)
                            else
                                MCE:Print(L["sArena slash command is unavailable."])
                            end
                        end,
                    } or nil,
                },
            },

            categoryOverview = desc and {
                type = "group", name = "", inline = true, order = 2,
                args = {
                    catDesc = {
                        type = "description", order = 0.1, fontSize = "medium", width = "full",
                        name = BuildCategoryDescription(desc),
                    },
                    bottomSpacing = SectionSpacer(0.12),
                },
            } or nil,

            -- ── 2. Typography ───────────────────────────────────────────
            typography = {
                type = "group", name = "|cffffd100" .. L["Typography (Cooldown Numbers)"] .. "|r",
                inline = true, order = 10, disabled = disabledFn,
                args = {
                    font = {
                        type = "select", order = 1, width = 1.5,
                        name = L["Font Face"], values = GetFontOptions,
                        get = CatGet(key, "font"), set = CatSet(key, "font"),
                    },
                    fontSize = {
                        type = "range", order = 2, width = 0.7,
                        name = L["Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "fontSize"), set = CatRangeSet(key, "fontSize"),
                        hidden = function() return isCooldownManager or isMiniCC or isSArena end,
                    },
                    fontStyle = {
                        type = "select", order = 3, width = 0.8,
                        name = L["Outline"], values = OUTLINE_OPTIONS,
                        get = CatGet(key, "fontStyle"), set = CatSet(key, "fontStyle"),
                    },
                    textColor = {
                        type = "color", order = 4, width = "half",
                        name = L["Color"], hasAlpha = true,
                        get = CatColorGet(key, "textColor"),
                        set = CatColorSet(key, "textColor"),
                    },
                    allowThresholdColors = {
                        type = "toggle", order = 4.5, width = "full",
                        name = L["Allow Threshold Colors"],
                        desc = L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."],
                        get = CatGet(key, "allowThresholdColors", GetAllowThresholdDefault(key)),
                        set = CatSet(key, "allowThresholdColors"),
                        hidden = function() return isSArena end,
                    },
                    hideCountdownNumbers = {
                        type = "toggle", order = 5, width = "1",
                        name = L["Hide Numbers"],
                        desc = L["Hide the text entirely (useful if you only want the swipe edge or stacks)."],
                        get = CatGet(key, "hideCountdownNumbers"),
                        set = CatSet(key, "hideCountdownNumbers"),
                        hidden = function() return isMiniCC or isSArena end,
                    },
                    auraCdTextOnlyMine = isUnitframe and {
                        type = "toggle", order = 5.005, width = "1",
                        name = L["Only Mine"],
                        desc = L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."],
                        get = CatGet(key, "auraCdTextOnlyMine", false),
                        set = CatSet(key, "auraCdTextOnlyMine"),
                        disabled = function()
                            return MCE.db.profile.categories[key].hideCountdownNumbers == true
                        end,
                    } or nil,
                    hideStackText = isStackCategory and {
                        type = "toggle", order = 5.01, width = "1",
                        name = L["Hide Stack Text"],
                        desc = L["Hide stacks and charges entirely."],
                        get = CatGet(key, "hideStackText", false),
                        set = CatSet(key, "hideStackText"),
                    } or nil,
                    hideChargeTimers = (key == C.Categories.Actionbar) and {
                        type = "toggle", order = 5.02, width = "full",
                        name = L["Hide Charge Timers"],
                        desc = L["Hide timers while charges are restoring (only show timer when all charges are spent)."],
                        get = function()
                            return MCE.db.profile.categories[C.Categories.Actionbar].hideChargeTimers and true or false
                        end,
                        set = function(_, val)
                            MCE.db.profile.categories[C.Categories.Actionbar].hideChargeTimers = val and true or false
                            MCE:ForceUpdateAll(false)
                            AceConfigRegistry:NotifyChange(addonName)
                        end,
                    } or nil,
                    cooldownManagerHeaderTopSpacing = isCooldownManager and SectionSpacer(5.05) or nil,
                    cooldownManagerHeader = isCooldownManager and {
                        type = "header", name = L["CooldownManager Viewers"], order = 5.1,
                    } or nil,
                    cooldownManagerHeaderBottomSpacing = isCooldownManager and SectionSpacer(5.15) or nil,
                    essentialFontSize = isCooldownManager and {
                        type = "range", order = 5.2, width = "full",
                        name = L["Essential Viewer Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "essentialFontSize", 18),
                        set = CatRangeSet(key, "essentialFontSize"),
                    } or nil,
                    utilityFontSize = isCooldownManager and {
                        type = "range", order = 5.3, width = "full",
                        name = L["Utility Viewer Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "utilityFontSize", 18),
                        set = CatRangeSet(key, "utilityFontSize"),
                    } or nil,
                    buffIconFontSize = isCooldownManager and {
                        type = "range", order = 5.4, width = "full",
                        name = L["Buff Icon Viewer Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "buffIconFontSize", 18),
                        set = CatRangeSet(key, "buffIconFontSize"),
                    } or nil,
                    miniCCHeaderTopSpacing = isMiniCC and SectionSpacer(5.05) or nil,
                    miniCCHeader = isMiniCC and {
                        type = "header", name = L["MiniCC Frame Types"], order = 5.1,
                    } or nil,
                    miniCCHeaderBottomSpacing = isMiniCC and SectionSpacer(5.15) or nil,
                    ccFontSize = isMiniCC and {
                        type = "range", order = 5.2, width = 1.2,
                        name = L["CC Text Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "ccFontSize", 18),
                        set = CatRangeSet(key, "ccFontSize"),
                    } or nil,
                    ccHideCountdownNumbers = isMiniCC and {
                        type = "toggle", order = 5.25, width = 0.8,
                        name = L["Hide Numbers"],
                        desc = L["Hide the text entirely (useful if you only want the swipe edge or stacks)."],
                        get = CatGet(key, "ccHideCountdownNumbers", false),
                        set = CatSet(key, "ccHideCountdownNumbers"),
                    } or nil,
                    ccRowBreak = isMiniCC and RowBreak(5.29) or nil,
                    nameplateFontSize = isMiniCC and {
                        type = "range", order = 5.3, width = 1.2,
                        name = L["Nameplates Text Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "nameplateFontSize", 12),
                        set = CatRangeSet(key, "nameplateFontSize"),
                    } or nil,
                    nameplateHideCountdownNumbers = isMiniCC and {
                        type = "toggle", order = 5.35, width = 0.8,
                        name = L["Hide Numbers"],
                        desc = L["Hide the text entirely (useful if you only want the swipe edge or stacks)."],
                        get = CatGet(key, "nameplateHideCountdownNumbers", false),
                        set = CatSet(key, "nameplateHideCountdownNumbers"),
                    } or nil,
                    nameplateRowBreak = isMiniCC and RowBreak(5.39) or nil,
                    portraitFontSize = isMiniCC and {
                        type = "range", order = 5.4, width = 1.2,
                        name = L["Portraits Text Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "portraitFontSize", 18),
                        set = CatRangeSet(key, "portraitFontSize"),
                    } or nil,
                    portraitHideCountdownNumbers = isMiniCC and {
                        type = "toggle", order = 5.45, width = 0.8,
                        name = L["Hide Numbers"],
                        desc = L["Hide the text entirely (useful if you only want the swipe edge or stacks)."],
                        get = CatGet(key, "portraitHideCountdownNumbers", false),
                        set = CatSet(key, "portraitHideCountdownNumbers"),
                    } or nil,
                    portraitRowBreak = isMiniCC and RowBreak(5.49) or nil,
                    overlayFontSize = isMiniCC and {
                        type = "range", order = 5.5, width = 1.2,
                        name = L["Alerts / Overlay Text Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "overlayFontSize", 18),
                        set = CatRangeSet(key, "overlayFontSize"),
                    } or nil,
                    overlayHideCountdownNumbers = isMiniCC and {
                        type = "toggle", order = 5.55, width = 0.8,
                        name = L["Hide Numbers"],
                        desc = L["Hide the text entirely (useful if you only want the swipe edge or stacks)."],
                        get = CatGet(key, "overlayHideCountdownNumbers", false),
                        set = CatSet(key, "overlayHideCountdownNumbers"),
                    } or nil,
                    sArenaHeaderTopSpacing = isSArena and SectionSpacer(5.05) or nil,
                    sArenaHeader = isSArena and {
                        type = "header", name = L["sArena Cooldown Types"], order = 5.1,
                    } or nil,
                    sArenaHeaderBottomSpacing = isSArena and SectionSpacer(5.15) or nil,
                    classIconFontSize = isSArena and {
                        type = "range", order = 5.2, width = "full",
                        name = L["Class Icon Text Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "classIconFontSize", 18),
                        set = CatRangeSet(key, "classIconFontSize"),
                    } or nil,
                    drFontSize = isSArena and {
                        type = "range", order = 5.3, width = "full",
                        name = L["DR Cooldown Text Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "drFontSize", 18),
                        set = CatRangeSet(key, "drFontSize"),
                    } or nil,
                    trinketRacialFontSize = isSArena and {
                        type = "range", order = 5.4, width = "full",
                        name = L["Trinket / Racial Text Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "trinketRacialFontSize", 18),
                        set = CatRangeSet(key, "trinketRacialFontSize"),
                    } or nil,
                    -- Positioning sub-section
                    posHeaderTopSpacing = SectionSpacer(5.95),
                    posHeader = { type = "header", name = L["Positioning"], order = 6 },
                    posHeaderBottomSpacing = SectionSpacer(6.05),
                    textAnchor = {
                        type = "select", order = 7,
                        name = L["Anchor Point"], values = ANCHOR_OPTIONS,
                        get = CatGet(key, "textAnchor", C.Style.Anchors.Center),
                        set = CatSet(key, "textAnchor"),
                    },
                    textOffsetX = {
                        type = "range", order = 8, width = "half",
                        name = L["Offset X"], min = -30, max = 30, step = 1,
                        get = CatGet(key, "textOffsetX", 0),
                        set = CatRangeSet(key, "textOffsetX"),
                    },
                    textOffsetY = {
                        type = "range", order = 9, width = "half",
                        name = L["Offset Y"], min = -30, max = 30, step = 1,
                        get = CatGet(key, "textOffsetY", 0),
                        set = CatRangeSet(key, "textOffsetY"),
                    },
                },
            },
            -- ── 3. Swipe Edge ───────────────────────────────────────────
            swipeEdge = {
                type = "group", name = "|cffffd100" .. L["Swipe Animation"] .. "|r",
                inline = true, order = 20, disabled = disabledFn,
                args = {
                    drawSwipe = {
                        type = "toggle", order = 0, width = "normal",
                        name = L["Show Swipe Animation"],
                        desc = L["Shows the dark overlay that sweeps during a cooldown."],
                        get = CatGet(key, "drawSwipe", true),
                        set = CatSet(key, "drawSwipe"),
                    },
                    edgeEnabled = {
                        type = "toggle", order = 1, width = "normal",
                        name = L["Show Swipe Edge"],
                        desc = L["Shows the white line indicating cooldown progress."],
                        get = CatGet(key, "edgeEnabled"),
                        set = CatSet(key, "edgeEnabled"),
                    },
                    edgeScale = {
                        type = "range", order = 2,
                        name = L["Edge Thickness"],
                        desc = L["Scale of the swipe line (1.0 = Default)."],
                        min = 0.5, max = 2.0, step = 0.1,
                        get = CatGet(key, "edgeScale"),
                        set = CatRangeSet(key, "edgeScale"),
                    },
                    swipeAlpha = (key == C.Categories.Actionbar) and {
                        type = "range", order = 3,
                        name = L["Swipe Shade Alpha"],
                        desc = L["0% = transparent, 100% = full dark."],
                        min = 0, max = 100, step = 1,
                        get = CatGet(key, "swipeAlpha", 80),
                        set = CatRangeSet(key, "swipeAlpha"),
                    } or nil,
                },
            },

            -- ── 4. Stack Counters / Charges ────────────────────────────
            stackGroup = isStackCategory and {
                type = "group", name = "|cffffd100" .. L["Stack Counters / Charges"] .. "|r",
                inline = true, order = 30, disabled = disabledFn,
                hidden = function()
                    return MCE.db.profile.categories[key].hideStackText
                end,
                args = {
                    stackEnabled = {
                        type = "toggle", order = 2, width = "full",
                        name = L["Customize Stack Text"],
                        desc = L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."],
                        get = CatGet(key, "stackEnabled"),
                        set = CatSet(key, "stackEnabled"),
                    },
                    -- Style sub-section
                    headerStyleTopSpacing = SectionSpacer(9.95, stackHiddenFn),
                    headerStyle = { type = "header", name = L["Style"], order = 10, hidden = stackHiddenFn },
                    headerStyleBottomSpacing = SectionSpacer(10.05, stackHiddenFn),
                    stackFont = {
                        type = "select", order = 11, width = 1.5,
                        name = L["Font"], values = GetFontOptions,
                        get = CatGet(key, "stackFont"), set = CatSet(key, "stackFont"),
                        hidden = stackHiddenFn,
                    },
                    stackSize = {
                        type = "range", order = 12, width = 0.7,
                        name = L["Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "stackSize"), set = CatRangeSet(key, "stackSize"),
                        hidden = stackHiddenFn,
                    },
                    stackStyle = {
                        type = "select", order = 13, width = 0.8,
                        name = L["Outline"], values = OUTLINE_OPTIONS,
                        get = CatGet(key, "stackStyle"), set = CatSet(key, "stackStyle"),
                        hidden = stackHiddenFn,
                    },
                    stackColor = {
                        type = "color", order = 14, width = 0.8,
                        name = L["Color"], hasAlpha = true,
                        get = CatColorGet(key, "stackColor"),
                        set = CatColorSet(key, "stackColor"),
                        hidden = stackHiddenFn,
                    },
                    -- Position sub-section
                    headerPosTopSpacing = SectionSpacer(19.95, stackHiddenFn),
                    headerPos = { type = "header", name = L["Positioning"], order = 20, hidden = stackHiddenFn },
                    headerPosBottomSpacing = SectionSpacer(20.05, stackHiddenFn),
                    stackAnchor = {
                        type = "select", order = 21,
                        name = L["Anchor Point"], values = ANCHOR_OPTIONS,
                        get = CatGet(key, "stackAnchor"), set = CatSet(key, "stackAnchor"),
                        hidden = stackHiddenFn,
                    },
                    stackOffsetX = {
                        type = "range", order = 22, width = "half",
                        name = L["Offset X"], min = -20, max = 20, step = 1,
                        get = CatGet(key, "stackOffsetX"), set = CatRangeSet(key, "stackOffsetX"),
                        hidden = stackHiddenFn,
                    },
                    stackOffsetY = {
                        type = "range", order = 23, width = "half",
                        name = L["Offset Y"], min = -20, max = 20, step = 1,
                        get = CatGet(key, "stackOffsetY"), set = CatRangeSet(key, "stackOffsetY"),
                        hidden = stackHiddenFn,
                    },
                },
            } or nil,

            -- ── 5. Maintenance ──────────────────────────────────────────
            maintenance = {
                type = "group", name = "|cff999999" .. L["Maintenance"] .. "|r",
                inline = true, order = 100,
                args = {
                    maintenanceDesc = {
                        type = "description", order = 0, fontSize = "small",
                        name = "|cff666666" .. L["MAINTENANCE_DESC"] .. "|r\n",
                    },
                    resetCategory = {
                        type = "execute", order = 1, width = "full",
                        name = "|cffff8888" .. format(L["Reset %s"], name) .. "|r",
                        desc = L["Revert this category to default settings."],
                        confirm = true,
                        func = function()
                            MCE.db.profile.categories[key] = CopyTable(MCE.defaults.profile.categories[key])
                            MCE:ForceUpdateAll()
                            LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
                            MCE:Print(format(L["%s settings reset."], name))
                        end,
                    },
                },
            },
        },
    }
end

local function CreateCompactPartyAuraOptions(order, name, desc)
    local function IsCompactPartyAuraEnabled()
        local config = GetCompactPartyAuraOptionsConfig()
        return config and config.enabled or false
    end

    local function SetCompactPartyAuraToggle(field)
        return function(_, val)
            local config = GetCompactPartyAuraOptionsConfig()
            if not config then return end
            config[field] = val
            MCE:MarkReloadRequired()
            MCE:ForceUpdateAll(true)
            AceConfigRegistry:NotifyChange(addonName)
            RefreshDynamicCategoryLabels()
        end
    end

    local compactDisabledFn = function()
        return not IsCompactPartyAuraEnabled()
    end

    local compactStackHiddenFn = function()
        local config = GetCompactPartyAuraOptionsConfig()
        return not config or not config.stackEnabled or config.hideStackText
    end

    return {
        type = "group",
        name = function()
            if not MCE.db or not MCE.db.profile then return name end
            if IsCompactPartyAuraEnabled() then
                return "|cff33ff99" .. L["ON"] .. "|r  " .. name
            end

            return "|cff555555" .. L["OFF"] .. "|r  |cff888888" .. name .. "|r"
        end,
        order = order,
        args = {
            enableGroup = {
                type = "group", name = "", inline = true, order = 1,
                args = {
                    enabled = {
                        type = "toggle", order = 1, width = "full",
                        name = "|cff33ff99" .. format(L["Enable %s"], name) .. "|r",
                        desc = L["Toggle styling for this category."],
                        get = ProfileTableGet("compactPartyAuraText", "enabled", true),
                        set = SetCompactPartyAuraToggle("enabled"),
                    },
                },
            },
            categoryOverview = desc and {
                type = "group", name = "", inline = true, order = 2,
                args = {
                    catDesc = {
                        type = "description", order = 0.1, fontSize = "medium", width = "full",
                        name = BuildCategoryDescription(desc),
                    },
                    bottomSpacing = SectionSpacer(0.12),
                },
            } or nil,
            typography = {
                type = "group", name = "|cffffd100" .. L["Typography (Cooldown Numbers)"] .. "|r",
                inline = true, order = 10,
                disabled = compactDisabledFn,
                args = {
                    compactRaidEnabled = {
                        type = "toggle", order = 1, width = "full",
                        name = L["Enable Raid Aura Text"],
                        desc = L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."],
                        get = ProfileTableGet("compactPartyAuraText", "raidEnabled", false),
                        set = SetCompactPartyAuraToggle("raidEnabled"),
                    },
                    compactPartyFont = {
                        type = "select", order = 2, width = 1.5,
                        name = L["Font Face"], values = GetFontOptions,
                        get = ProfileTableGet("compactPartyAuraText", "font"),
                        set = ProfileTableSet("compactPartyAuraText", "font"),
                    },
                    compactPartyFontStyle = {
                        type = "select", order = 3, width = 0.8,
                        name = L["Outline"], values = OUTLINE_OPTIONS,
                        get = ProfileTableGet("compactPartyAuraText", "fontStyle"),
                        set = ProfileTableSet("compactPartyAuraText", "fontStyle"),
                    },
                    compactPartyTextColor = {
                        type = "color", order = 4, width = "half",
                        name = L["Color"], hasAlpha = true,
                        get = ProfileTableColorGet("compactPartyAuraText", "textColor"),
                        set = ProfileTableColorSet("compactPartyAuraText", "textColor"),
                    },
                    compactPartyAllowThresholdColors = {
                        type = "toggle", order = 4.5, width = "full",
                        name = L["Allow Threshold Colors"],
                        desc = L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."],
                        get = ProfileTableGet("compactPartyAuraText", "allowThresholdColors", GetAllowThresholdDefault(C.Categories.CompactPartyAura)),
                        set = ProfileTableSet("compactPartyAuraText", "allowThresholdColors"),
                    },
                    compactPartyFontSize = {
                        type = "range", order = 5, width = 1.0,
                        name = L["Buff / Debuff Size"], min = 8, max = 36, step = 1,
                        get = ProfileTableGet("compactPartyAuraText", "fontSize", 12),
                        set = ProfileTableRangeSet("compactPartyAuraText", "fontSize"),
                    },
                    compactPartyDefensiveBuffFontSize = {
                        type = "range", order = 6, width = 1.2,
                        name = L["Defensive Buff Size"], min = 8, max = 36, step = 1,
                        get = ProfileTableGet("compactPartyAuraText", "defensiveBuffFontSize", 12),
                        set = ProfileTableRangeSet("compactPartyAuraText", "defensiveBuffFontSize"),
                    },
                    compactPartyPosSpacing = SectionSpacer(6.9),
                    compactPartyPosHeader = { type = "header", name = L["Positioning"], order = 7 },
                    compactPartyPosSpacingAfter = SectionSpacer(7.05),
                    compactPartyTextAnchor = {
                        type = "select", order = 8,
                        name = L["Anchor Point"], values = ANCHOR_OPTIONS,
                        get = ProfileTableGet("compactPartyAuraText", "textAnchor", C.Style.Anchors.Center),
                        set = ProfileTableSet("compactPartyAuraText", "textAnchor"),
                    },
                    compactPartyTextOffsetX = {
                        type = "range", order = 9, width = "half",
                        name = L["Offset X"], min = -30, max = 30, step = 1,
                        get = ProfileTableGet("compactPartyAuraText", "textOffsetX", 0),
                        set = ProfileTableRangeSet("compactPartyAuraText", "textOffsetX"),
                    },
                    compactPartyTextOffsetY = {
                        type = "range", order = 10, width = "half",
                        name = L["Offset Y"], min = -30, max = 30, step = 1,
                        get = ProfileTableGet("compactPartyAuraText", "textOffsetY", 0),
                        set = ProfileTableRangeSet("compactPartyAuraText", "textOffsetY"),
                    },
                    compactPartyHideStackText = {
                        type = "toggle", order = 11, width = "1",
                        name = L["Hide Stack Text"],
                        desc = L["Hide stacks and charges entirely."],
                        get = ProfileTableGet("compactPartyAuraText", "hideStackText", false),
                        set = function(_, val)
                            local config = GetCompactPartyAuraOptionsConfig()
                            if not config then return end
                            config.hideStackText = val
                            MCE:ForceUpdateAll(true)
                            AceConfigRegistry:NotifyChange(addonName)
                        end,
                    },
                },
            },
            swipeAnimation = {
                type = "group", name = "|cffffd100" .. L["Swipe Animation"] .. "|r",
                inline = true, order = 20,
                disabled = compactDisabledFn,
                args = {
                    drawSwipe = {
                        type = "toggle", order = 1, width = "normal",
                        name = L["Show Swipe Animation"],
                        desc = L["Shows the dark overlay that sweeps during a cooldown."],
                        get = ProfileTableGet("compactPartyAuraText", "drawSwipe", true),
                        set = ProfileTableSet("compactPartyAuraText", "drawSwipe"),
                    },
                    edgeEnabled = {
                        type = "toggle", order = 2, width = "normal",
                        name = L["Show Swipe Edge"],
                        desc = L["Shows the white line indicating cooldown progress."],
                        get = ProfileTableGet("compactPartyAuraText", "edgeEnabled", true),
                        set = ProfileTableSet("compactPartyAuraText", "edgeEnabled"),
                    },
                    edgeScale = {
                        type = "range", order = 3,
                        name = L["Edge Thickness"],
                        desc = L["Scale of the swipe line (1.0 = Default)."],
                        min = 0.5, max = 2.0, step = 0.1,
                        get = ProfileTableGet("compactPartyAuraText", "edgeScale", 1.4),
                        set = ProfileTableRangeSet("compactPartyAuraText", "edgeScale"),
                    },
                },
            },
            stackGroup = {
                type = "group", name = "|cffffd100" .. L["Stack Counters / Charges"] .. "|r",
                inline = true, order = 30, disabled = compactDisabledFn,
                hidden = function()
                    local config = GetCompactPartyAuraOptionsConfig()
                    return config and config.hideStackText or false
                end,
                args = {
                    stackEnabled = {
                        type = "toggle", order = 2, width = "full",
                        name = L["Customize Stack Text"],
                        desc = L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."],
                        get = ProfileTableGet("compactPartyAuraText", "stackEnabled", true),
                        set = function(_, val)
                            local config = GetCompactPartyAuraOptionsConfig()
                            if not config then return end
                            config.stackEnabled = val
                            MCE:ForceUpdateAll(true)
                            AceConfigRegistry:NotifyChange(addonName)
                        end,
                    },
                    headerStyleTopSpacing = SectionSpacer(9.95, compactStackHiddenFn),
                    headerStyle = { type = "header", name = L["Style"], order = 10, hidden = compactStackHiddenFn },
                    headerStyleBottomSpacing = SectionSpacer(10.05, compactStackHiddenFn),
                    stackFont = {
                        type = "select", order = 11, width = 1.5,
                        name = L["Font"], values = GetFontOptions,
                        get = ProfileTableGet("compactPartyAuraText", "stackFont"),
                        set = ProfileTableSet("compactPartyAuraText", "stackFont"),
                        hidden = compactStackHiddenFn,
                    },
                    stackSize = {
                        type = "range", order = 12, width = 0.7,
                        name = L["Size"], min = 8, max = 36, step = 1,
                        get = ProfileTableGet("compactPartyAuraText", "stackSize", 8),
                        set = ProfileTableRangeSet("compactPartyAuraText", "stackSize"),
                        hidden = compactStackHiddenFn,
                    },
                    stackStyle = {
                        type = "select", order = 13, width = 0.8,
                        name = L["Outline"], values = OUTLINE_OPTIONS,
                        get = ProfileTableGet("compactPartyAuraText", "stackStyle"),
                        set = ProfileTableSet("compactPartyAuraText", "stackStyle"),
                        hidden = compactStackHiddenFn,
                    },
                    stackColor = {
                        type = "color", order = 14, width = 0.8,
                        name = L["Color"], hasAlpha = true,
                        get = ProfileTableColorGet("compactPartyAuraText", "stackColor"),
                        set = ProfileTableColorSet("compactPartyAuraText", "stackColor"),
                        hidden = compactStackHiddenFn,
                    },
                    headerPosTopSpacing = SectionSpacer(19.95, compactStackHiddenFn),
                    headerPos = { type = "header", name = L["Positioning"], order = 20, hidden = compactStackHiddenFn },
                    headerPosBottomSpacing = SectionSpacer(20.05, compactStackHiddenFn),
                    stackAnchor = {
                        type = "select", order = 21,
                        name = L["Anchor Point"], values = ANCHOR_OPTIONS,
                        get = ProfileTableGet("compactPartyAuraText", "stackAnchor"),
                        set = ProfileTableSet("compactPartyAuraText", "stackAnchor"),
                        hidden = compactStackHiddenFn,
                    },
                    stackOffsetX = {
                        type = "range", order = 22, width = "half",
                        name = L["Offset X"], min = -20, max = 20, step = 1,
                        get = ProfileTableGet("compactPartyAuraText", "stackOffsetX", 0),
                        set = ProfileTableRangeSet("compactPartyAuraText", "stackOffsetX"),
                        hidden = compactStackHiddenFn,
                    },
                    stackOffsetY = {
                        type = "range", order = 23, width = "half",
                        name = L["Offset Y"], min = -20, max = 20, step = 1,
                        get = ProfileTableGet("compactPartyAuraText", "stackOffsetY", 0),
                        set = ProfileTableRangeSet("compactPartyAuraText", "stackOffsetY"),
                        hidden = compactStackHiddenFn,
                    },
                },
            },
            maintenance = {
                type = "group", name = "|cff999999" .. L["Maintenance"] .. "|r",
                inline = true, order = 100,
                args = {
                    maintenanceDesc = {
                        type = "description", order = 0, fontSize = "small",
                        name = "|cff666666" .. L["MAINTENANCE_DESC"] .. "|r\n",
                    },
                    resetCategory = {
                        type = "execute", order = 1, width = "full",
                        name = "|cffff8888" .. format(L["Reset %s"], name) .. "|r",
                        desc = L["Revert this category to default settings."],
                        confirm = true,
                        func = function()
                            MCE.db.profile.compactPartyAuraText = CopyTable(MCE.defaults.profile.compactPartyAuraText)
                            MCE:ForceUpdateAll(true)
                            AceConfigRegistry:NotifyChange(addonName)
                            RefreshDynamicCategoryLabels()
                            MCE:Print(format(L["%s settings reset."], name))
                        end,
                    },
                },
            },
        },
    }
end

-- =========================================================================
-- ROOT OPTIONS TABLE
-- =========================================================================

function MCE:GetOptions()
    local profileOpts = LibStub("AceDBOptions-3.0"):GetOptionsTable(MCE.db)
    profileOpts.order = 10 -- ensure profiles tab is last
    profileOpts.args = profileOpts.args or {}
    profileOpts.args.importExport = BuildProfileImportExportOptions(50)

    return {
        type = "group",
        name = C.Chat.Prefix,
        args = {
            -- ── General ─────────────────────────────────────────────────
            general = {
                type = "group", name = L["General"], order = 1,
                args = {
                    banner = {
                        type = "description", order = 0.1, fontSize = "large",
                        name = "|cff00ccffMinimalist Cooldown Edge|r |cff888888v" .. addonVersion .. "|r\n|cff666666by Anahkas|r",
                        image = C.Assets.Icon,
                        imageWidth = 48, imageHeight = 48,
                    },
                    bannerSpacing1 = SectionSpacer(0.2),
                    bannerDesc = {
                        type = "description", order = 0.3, fontSize = "medium",
                        name = "|cffbbbbbb" .. L["BANNER_DESC"] .. "|r\n",
                    },
                    bannerSpacing2 = SectionSpacer(0.4),
                    -- ── Quick Toggles Dashboard ─────────────────────────
                    quickToggles = {
                        type = "group", name = "|cffffd100" .. L["Enable categories styling"] .. "|r",
                        inline = true, order = 1,
                        args = {
                            quickDesc = {
                                type = "description", order = 0, fontSize = "small", width = "full",
                                name = "|cff888888" .. L["QUICK_TOGGLES_DESC"] .. "|r\n",
                            },
                            toggleActionbar = {
                                type = "toggle", order = 1, width = 1.0,
                                name = "|cffffd100" .. L["Action Bars"] .. "|r",
                                get = function() return MCE.db.profile.categories[C.Categories.Actionbar].enabled end,
                                set = SetDashboardCategoryEnabled(C.Categories.Actionbar),
                            },
                            toggleNameplate = {
                                type = "toggle", order = 2, width = 1.0,
                                name = "|cffffd100" .. L["Nameplates"] .. "|r",
                                get = function() return MCE.db.profile.categories[C.Categories.Nameplate].enabled end,
                                set = SetDashboardCategoryEnabled(C.Categories.Nameplate),
                            },
                            quickRowBreak1 = RowBreak(2.1),
                            toggleUnitframe = {
                                type = "toggle", order = 3, width = 1.0,
                                name = "|cffffd100" .. L["Unit Frames"] .. "|r",
                                get = function() return MCE.db.profile.categories[C.Categories.Unitframe].enabled end,
                                set = SetDashboardCategoryEnabled(C.Categories.Unitframe),
                            },
                            togglePartyRaidFrames = {
                                type = "toggle", order = 4, width = 1.0,
                                name = "|cffffd100" .. L["Party / Raid Frames"] .. "|r",
                                get = function()
                                    local config = GetCompactPartyAuraOptionsConfig()
                                    return config and config.enabled or false
                                end,
                                set = function(_, v)
                                    local config = GetCompactPartyAuraOptionsConfig()
                                    if not config then return end
                                    config.enabled = v
                                    MCE:MarkReloadRequired()
                                    MCE:ForceUpdateAll(true)
                                    AceConfigRegistry:NotifyChange(addonName)
                                    RefreshDynamicCategoryLabels()
                                end,
                            },
                            quickRowBreak2 = RowBreak(4.1),
                            toggleCooldownMgr = {
                                type = "toggle", order = 5, width = "full",
                                name = "|cffffd100" .. L["CooldownManager"] .. "|r",
                                get = function() return MCE.db.profile.categories[C.Categories.CooldownManager].enabled end,
                                set = SetDashboardCategoryEnabled(C.Categories.CooldownManager),
                            },
                            toggleMiniCC = {
                                type = "toggle", order = 6, width = 0.6,
                                name = "|cffffd100" .. L["MiniCC"] .. "|r",
                                hidden = function() return not MCE:IsMiniCCAvailable() end,
                                get = function() return MCE.db.profile.categories[C.Categories.MiniCC].enabled end,
                                set = SetDashboardCategoryEnabled(C.Categories.MiniCC),
                            },
                            toggleSArena = {
                                type = "toggle", order = 7, width = 0.6,
                                name = "|cffffd100" .. L["sArena"] .. "|r",
                                hidden = function() return not MCE:IsSArenaAvailable() end,
                                get = function() return MCE.db.profile.categories[C.Categories.SArena].enabled end,
                                set = SetDashboardCategoryEnabled(C.Categories.SArena),
                            },
                            toggleTellMeWhen = {
                                type = "toggle", order = 8, width = 0.9,
                                name = "|cffffd100" .. L["TellMeWhen"] .. "|r",
                                hidden = function() return not MCE:IsTellMeWhenAvailable() end,
                                get = function() return MCE.db.profile.categories[C.Categories.TellMeWhen].enabled end,
                                set = SetDashboardCategoryEnabled(C.Categories.TellMeWhen),
                            },
                            quickFooter = {
                                type = "description", order = 9, fontSize = "small", width = "full",
                                name = "\n|cff999999" .. L["LIVE_CONTROLS_DESC"] .. "|r",
                            },
                        },
                    },
                    addonIntegrations = {
                        type = "group", name = "|cffffd100" .. L["Addon Integrations"] .. "|r",
                        inline = true, order = 1.5,
                        hidden = function()
                            return not MCE:IsShinyAurasAvailable()
                                and not MCE:IsElvUIAvailable()
                        end,
                        args = {
                            integrationsDesc = {
                                type = "description", order = 0, fontSize = "small", width = "full",
                                name = "|cff888888" .. L["ADDON_INTEGRATIONS_DESC"] .. "|r\n",
                            },
                            toggleShinyAuras = {
                                type = "toggle", order = 1, width = "full",
                                name = "|cffffd100" .. L["ShinyAuras"] .. "|r",
                                hidden = function() return not MCE:IsShinyAurasAvailable() end,
                                desc = L["Routes ShinyAuras cooldowns through the Unit Frames category. Disable this if you want ShinyAuras to keep its native countdowns untouched."],
                                get = ShinyAurasAdapterEnabled,
                                set = SetShinyAurasAdapterEnabled,
                            },
                            toggleElvUI = {
                                type = "toggle", order = 2, width = "full",
                                name = "|cffffd100" .. L["ElvUI"] .. "|r",
                                hidden = function() return not MCE:IsElvUIAvailable() end,
                                desc = L["Routes supported ElvUI action bar, unit frame, and nameplate cooldowns through MiniCE categories. Disable this if you want ElvUI to keep its native cooldown styling untouched."],
                                get = ElvUIAdapterEnabled,
                                set = SetElvUIAdapterEnabled,
                            },
                        },
                    },
                    durationTextColors = {
                        type = "group", name = "|cffffd100" .. L["Dynamic Text Colors"] .. "|r",
                        inline = true, order = 2,
                        args = {
                            dynamicDesc = {
                                type = "description", order = 0, fontSize = "small", width = "full",
                                name = "|cff88bbdd" .. L["DYNAMIC_COLORS_GENERAL_DESC"] .. "|r\n",
                            },
                            dynamicEnabled = {
                                type = "toggle", order = 2, width = "full",
                                name = L["Color by Remaining Time"],
                                desc = L["Dynamically colors the countdown text based on how much time is left."],
                                get = DurationColorsEnabled,
                                set = function(_, val)
                                    local config = GetDurationTextColorsConfig()
                                    config.enabled = val
                                    MCE:ForceUpdateAll(true)
                                    AceConfigRegistry:NotifyChange(addonName)
                                end,
                            },
                            thresholdsRowBreak = RowBreak(3.1),
                            thresholdsHeader = {
                                type = "header", name = L["Threshold Colors"], order = 10,
                                hidden = DurationColorsDisabled,
                            },
                            thresholdsHeaderSpacing = SectionSpacer(10.05, DurationColorsDisabled),
                            t1Value = {
                                type = "range", order = 11, width = 1.2,
                                name = L["Expiring Soon"],
                                desc = L["Threshold (seconds)"], min = 1, max = 60, step = 1,
                                get = DurationThresholdValueGet(1),
                                set = DurationThresholdValueSet(1),
                                hidden = DurationColorsDisabled,
                            },
                            t1Color = {
                                type = "color", order = 12, width = 0.5,
                                name = L["Color"], hasAlpha = true,
                                get = DurationThresholdColorGet(1),
                                set = DurationThresholdColorSet(1),
                                hidden = DurationColorsDisabled,
                            },
                            t1RowBreak = RowBreak(12.1, DurationColorsDisabled),
                            t2Value = {
                                type = "range", order = 20, width = 1.2,
                                name = L["Short Duration"],
                                desc = L["Threshold (seconds)"], min = 5, max = 300, step = 1,
                                get = DurationThresholdValueGet(2),
                                set = DurationThresholdValueSet(2),
                                hidden = DurationColorsDisabled,
                            },
                            t2Color = {
                                type = "color", order = 21, width = 0.5,
                                name = L["Color"], hasAlpha = true,
                                get = DurationThresholdColorGet(2),
                                set = DurationThresholdColorSet(2),
                                hidden = DurationColorsDisabled,
                            },
                            t2RowBreak = RowBreak(21.1, DurationColorsDisabled),
                            t3Value = {
                                type = "range", order = 30, width = 1.2,
                                name = L["Long Duration"],
                                desc = L["Threshold (seconds)"], min = 60, max = 3600, step = 60,
                                get = DurationThresholdValueGet(3),
                                set = DurationThresholdValueSet(3),
                                hidden = DurationColorsDisabled,
                            },
                            t3Color = {
                                type = "color", order = 31, width = 0.5,
                                name = L["Color"], hasAlpha = true,
                                get = DurationThresholdColorGet(3),
                                set = DurationThresholdColorSet(3),
                                hidden = DurationColorsDisabled,
                            },
                            footerRowBreak = RowBreak(31.1, DurationColorsDisabled),
                            defaultHeader = {
                                type = "header", name = L["Advanced Threshold Settings"], order = 40,
                                hidden = DurationColorsDisabled,
                            },
                            defaultHeaderSpacing = SectionSpacer(40.05, DurationColorsDisabled),                            
                            defaultDurationColor = {
                                type = "color", order = 41, width = 1.3,
                                name = L["Beyond Thresholds Color"],
                                desc = L["Color used when the remaining time exceeds all thresholds."],
                                hasAlpha = true,
                                get = DefaultDurationColorGet,
                                set = DefaultDurationColorSet,
                                hidden = DurationColorsDisabled,
                            },
                            dynamicOffset = {
                                type = "range", order = 42, width = 1.4,
                                name = L["Threshold Transition Offset"],
                                desc = L["Moves the start of each next color band. Negative values switch slightly earlier."],
                                min = -2, max = 2, step = 0.05,
                                hidden = DurationColorsDisabled,
                                get = DurationOffsetGet,
                                set = DurationOffsetSet,
                            },
                            perfWarning = {
                                type = "description", order = 99, fontSize = "small", width = "full",
                                name = "\n|cffffaa55(!) This feature may impact performance and cause FPS drops. Use only on strong setups. |r",
                            },
                        },
                    },
                    abbrevThreshold = {
                        type = "group", name = "|cffffd100" .. L["Abbreviate Above"] .. "|r",
                        inline = true, order = 2.2,
                        args = {
                            abbrevDesc = {
                                type = "description", order = 0, fontSize = "small", width = "full",
                                name = "|cff88bbdd" .. L["ABBREV_THRESHOLD_DESC"] .. "|r\n",
                            },
                            abbrevValue = {
                                type = "range", order = 1, width = "full",
                                name = L["Abbreviate Above (seconds)"],
                                desc = L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."],
                                min = 0, max = 300, step = 1,
                                get = function()
                                    return MCE.db.profile.abbrevThreshold or C.Options.DefaultAbbrevThreshold
                                end,
                                set = function(_, val)
                                    MCE.db.profile.abbrevThreshold = val
                                    MCE:ForceUpdateAll(true)
                                end,
                            },
                        },
                    },
                    resetGroup = {
                        type = "group", name = "|cffff4444" .. L["Danger Zone"] .. "|r",
                        inline = true, order = 3.5,
                        args = {
                            dangerDesc = {
                                type = "description", order = 0, fontSize = "small",
                                name = "|cff666666" .. L["DANGER_ZONE_DESC"] .. "|r\n",
                            },
                            resetAll = {
                                type = "execute", order = 1, width = "full",
                                name = "|cffff6666" .. L["Factory Reset (All)"] .. "|r",
                                desc = L["Resets the entire profile to default values and reloads the UI."],
                                confirm = true,
                                func = function()
                                    MCE.db:ResetProfile()
                                    MCE:Print(L["Profile reset. Reloading UI..."])
                                    ReloadUI()
                                end,
                            },
                        },
                    },
                },
            },

            -- ── Category tabs (with per-category descriptions) ────────
            [C.Categories.Actionbar] = CreateCategoryOptions(2, L["Action Bars"], C.Categories.Actionbar,
                L["ACTIONBAR_DESC"]),
            [C.Categories.Nameplate] = CreateCategoryOptions(3, L["Nameplates"], C.Categories.Nameplate,
                L["NAMEPLATE_DESC"]),
            [C.Categories.Unitframe] = CreateCategoryOptions(4, L["Unit Frames"], C.Categories.Unitframe,
                L["UNITFRAME_DESC"]),
            [C.Categories.CompactPartyAura] = CreateCompactPartyAuraOptions(5, L["Party / Raid Frames"],
                L["COMPACT_PARTY_AURA_TEXT_DESC"]),
            [C.Categories.CooldownManager] = CreateCategoryOptions(6, L["CooldownManager"], C.Categories.CooldownManager,
                L["COOLDOWNMANAGER_DESC"]),
            [C.Categories.MiniCC] = CreateCategoryOptions(7, L["MiniCC"], C.Categories.MiniCC,
                L["MINICC_DESC"]),
            [C.Categories.SArena] = CreateCategoryOptions(8, L["sArena"], C.Categories.SArena,
                L["SARENA_DESC"]),
            [C.Categories.TellMeWhen] = CreateCategoryOptions(9, L["TellMeWhen"], C.Categories.TellMeWhen,
                L["TELLMEWHEN_DESC"]),

            help = {
                type = "group", name = L["Help & Support"], order = 10,
                args = {
                    aboutHeader = {
                        type = "description", order = 0.1, fontSize = "large",
                        name = C.Chat.Prefix .. "  |cff888888v" .. addonVersion .. "|r\n",
                    },
                    aboutDesc = {
                        type = "description", order = 0.2, fontSize = "medium",
                        name = "|cffbbbbbb" .. L["MCE_HELP_INTRO"] .. "|r\n",
                    },
                    aboutSpacing = SectionSpacer(0.21),
                    supportGroup = {
                        type = "group", name = "|cffffd100" .. L["Support & Feedback"] .. "|r",
                        inline = true, order = 0.5,
                        args = {
                            supportDesc = {
                                type = "description", order = 1, fontSize = "medium", width = "full",
                                name = "|cffbbbbbb" .. L["HELP_SUPPORT_DESC"] .. "|r",
                            },
                        },
                    },
                    projectGroup = {
                        type = "group", name = "|cffffd100" .. L["Project"] .. "|r",
                        inline = true, order = 1,
                        args = {
                            projectUrl = {
                                type = "input", order = 1, width = "full",
                                name = "",
                                desc = L["Copy this link to open the CurseForge project page in your browser."],
                                get = function() return C.Urls.CurseForge end,
                                set = function() end,
                            },
                            developerUrl = {
                                type = "input", order = 2, width = "full",
                                name = "",
                                desc = L["Copy this link to view other projects from Anahkas on CurseForge."],
                                get = function() return C.Urls.Developer end,
                                set = function() end,
                            },
                        },
                    },
                    addonsGroup = {
                        type = "group", name = "|cffffd100" .. L["Useful Addons"] .. "|r",
                        inline = true, order = 2,
                        args = {
                            addonsDesc = {
                                type = "description", order = 0, fontSize = "small", width = "full",
                                name = "|cff88bbdd" .. L["HELP_COMPANION_DESC"] .. "|r\n",
                            },
                            miniCCDesc = {
                                type = "description", order = 1, fontSize = "small", width = "full",
                                name = "|cff33ff99MiniCC|r\n|cffbbbbbb" .. L["HELP_MINICC_DESC"] .. "|r",
                            },
                            miniCCUrl = {
                                type = "input", order = 2, width = "full",
                                name = "",
                                desc = L["Copy this link to open the MiniCC CurseForge page in your browser."],
                                get = function() return C.Urls.MiniCC end,
                                set = function() end,
                            },
                            miniCCSpacer = SectionSpacer(2.1),
                            pvpTabDesc = {
                                type = "description", order = 3, fontSize = "small", width = "full",
                                name = "|cff33ff99Smart PvP Tab Targeting|r\n|cffbbbbbb" .. L["HELP_PVPTAB_DESC"] .. "|r",
                            },
                            pvpTabUrl = {
                                type = "input", order = 4, width = "full",
                                name = "",
                                desc = L["Copy this link to open Smart PvP Tab Targeting on CurseForge."],
                                get = function() return C.Urls.SmartPvPTabTargeting end,
                                set = function() end,
                            },
                            pvpTabSpacer = SectionSpacer(4.1),
                            arenaDRDesc = {
                                type = "description", order = 5, fontSize = "small", width = "full",
                                name = "|cff33ff99ArenaDR Nameplates|r\n|cffbbbbbb" .. L["HELP_ARENADR_DESC"] .. "|r",
                            },
                            arenaDRUrl = {
                                type = "input", order = 6, width = "full",
                                name = "",
                                desc = L["Copy this link to open ArenaDR Nameplates on CurseForge."],
                                get = function() return C.Urls.ArenaDRNameplates end,
                                set = function() end,
                            },
                        },
                    },
                },
            },

            -- ── Profiles (always last) ──────────────────────────────────
            profiles = profileOpts,
        },
    }
end
