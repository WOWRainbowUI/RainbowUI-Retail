local addonName, addon = ...
local MCE = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local L = LibStub("AceLocale-3.0"):GetLocale("MinimalistCooldownEdge")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- === UPVALUE LOCALS ===
local format = string.format
local sort = table.sort

-- Retrieve version dynamically from TOC
local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Dev"
local CURSEFORGE_URL = "https://www.curseforge.com/wow/addons/mini-cooldown-text-edge-styler"
local DEVELOPER_URL = "https://www.curseforge.com/members/anahkas/projects"

-- LibSharedMedia integration (optional – silently absent if not installed)
local LSM = LibStub("LibSharedMedia-3.0", true)

-- === SHARED LOOKUP TABLES ===

-- Base fonts always available (WoW built-ins + addon-bundled fonts)
local FONT_OPTIONS_BASE = {
    ["GAMEDEFAULT"]               = "Game Default",
    ["Fonts\\FRIZQT__.TTF"]       = "Friz Quadrata",
    ["Fonts\\FRIZQT___CYR.TTF"]   = "Friz Quadrata (Cyrillic)",
    ["Fonts\\ARIALN.TTF"]         = "Arial Narrow",
    ["Fonts\\MORPHEUS.TTF"]       = "Morpheus",
    ["Fonts\\skurri.ttf"]         = "Skurri",
    ["Fonts\\2002.TTF"]           = "2002",
    ["Interface\\AddOns\\MinimalistCooldownEdge\\Fonts\\expressway.ttf"]        = "Expressway",
    ["Interface\\AddOns\\MinimalistCooldownEdge\\Fonts\\bazooka_regular.ttf"]   = "Bazooka",
}

--- Returns a merged font table: base fonts + any fonts registered in LibSharedMedia.
--- Declared as a function so the values are evaluated lazily each time the options
--- panel opens, picking up fonts registered by other addons after this file loads.
local function GetFontOptions()
    local opts = {}
    local usedNames = {}

    -- Base fonts take full priority (path + name reserved)
    for path, label in pairs(FONT_OPTIONS_BASE) do
        opts[path] = label
        usedNames[label:lower()] = true
    end

    if LSM then
        for name, path in pairs(LSM:HashTable("font")) do
            -- Skip if path already exists OR if display name is already in use
            if not opts[path] and not usedNames[name:lower()] then
                opts[path] = name
                usedNames[name:lower()] = true
            end
        end
    end
    
    return opts
end

local OUTLINE_OPTIONS = {
    ["NONE"]          = L["None"],
    ["OUTLINE"]       = L["Outline"],
    ["THICKOUTLINE"]  = L["Thick"],
    ["MONOCHROME"]    = L["Mono"],
}

local ANCHOR_OPTIONS = {
    ["CENTER"]      = L["Center"],
    ["TOPLEFT"]     = L["Top Left"],
    ["TOPRIGHT"]    = L["Top Right"],
    ["BOTTOMLEFT"]  = L["Bottom Left"],
    ["BOTTOMRIGHT"] = L["Bottom Right"],
}

-- =========================================================================
-- HELPERS  – DRY accessor builders to eliminate repetitive get/set closures
-- =========================================================================

--- Returns a getter function for `MCE.db.profile.categories[key][field]`.
local function CatGet(key, field, fallback)
    return function()
        local v = MCE.db.profile.categories[key][field]
        return (v ~= nil) and v or fallback
    end
end

--- Returns a setter function that writes and refreshes.
local function CatSet(key, field)
    return function(_, val)
        MCE.db.profile.categories[key][field] = val
        MCE:ForceUpdateAll()
    end
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
        MCE:ForceUpdateAll()
    end
end

local function IsCatDisabled(key)
    return not MCE.db.profile.categories[key].enabled
end

local function IsStackHidden(key)
    return not MCE.db.profile.categories[key].stackEnabled
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

-- =========================================================================
-- OPTIONS BUILDER
-- =========================================================================

local function CreateCategoryOptions(order, name, key, desc)
    local disabledFn    = function() return IsCatDisabled(key) end
    local stackHiddenFn = function() return IsStackHidden(key) end
    local isCooldownManager = (key == "cooldownmanager")

    return {
        type = "group",
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
            -- ── 0. Category description ──────────────────────────────────
            catDesc = desc and {
                type = "description", order = 0, fontSize = "medium",
                name = "\n|cff88bbdd" .. desc .. "|r\n",
            } or nil,

            -- ── 1. Main Toggle ──────────────────────────────────────────
            enableGroup = {
                type = "group", name = "", inline = true, order = 1,
                args = {
                    enabled = {
                        type = "toggle", order = 1, width = "full",
                        name = "|cff33ff99" .. format(L["Enable %s"], name) .. "|r",
                        desc = L["Toggle styling for this category."],
                        get = CatGet(key, "enabled"),
                        set = function(_, val)
                            MCE.db.profile.categories[key].enabled = val
                            MCE:ForceUpdateAll()
                            LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
                        end,
                    },
                },
            },

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
                        get = CatGet(key, "fontSize"), set = CatSet(key, "fontSize"),
                        hidden = function() return isCooldownManager end,
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
                    hideCountdownNumbers = {
                        type = "toggle", order = 5, width = "full",
                        name = L["Hide Numbers"],
                        desc = L["Hide the text entirely (useful if you only want the swipe edge or stacks)."],
                        get = CatGet(key, "hideCountdownNumbers"),
                        set = CatSet(key, "hideCountdownNumbers"),
                    },
                    cooldownManagerHeader = isCooldownManager and {
                        type = "header", name = L["CooldownManager Viewers"], order = 5.1,
                    } or nil,
                    essentialFontSize = isCooldownManager and {
                        type = "range", order = 5.2, width = "full",
                        name = L["Essential Viewer Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "essentialFontSize", 18),
                        set = CatSet(key, "essentialFontSize"),
                    } or nil,
                    utilityFontSize = isCooldownManager and {
                        type = "range", order = 5.3, width = "full",
                        name = L["Utility Viewer Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "utilityFontSize", 18),
                        set = CatSet(key, "utilityFontSize"),
                    } or nil,
                    buffIconFontSize = isCooldownManager and {
                        type = "range", order = 5.4, width = "full",
                        name = L["Buff Icon Viewer Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "buffIconFontSize", 18),
                        set = CatSet(key, "buffIconFontSize"),
                    } or nil,
                    -- Positioning sub-section
                    posHeader = { type = "header", name = L["Positioning"], order = 6 },
                    textAnchor = {
                        type = "select", order = 7,
                        name = L["Anchor Point"], values = ANCHOR_OPTIONS,
                        get = CatGet(key, "textAnchor", "CENTER"),
                        set = CatSet(key, "textAnchor"),
                    },
                    textOffsetX = {
                        type = "range", order = 8, width = "half",
                        name = L["Offset X"], min = -30, max = 30, step = 1,
                        get = CatGet(key, "textOffsetX", 0),
                        set = CatSet(key, "textOffsetX"),
                    },
                    textOffsetY = {
                        type = "range", order = 9, width = "half",
                        name = L["Offset Y"], min = -30, max = 30, step = 1,
                        get = CatGet(key, "textOffsetY", 0),
                        set = CatSet(key, "textOffsetY"),
                    },
                },
            },

            -- ── 2.5 Dynamic Text Colors (Action Bar only) ───────────────
            dynamicColors = (key == "actionbar") and {
                type = "group", name = "|cffffd100" .. L["Dynamic Text Colors"] .. "|r",
                inline = true, order = 15, disabled = disabledFn,
                args = {
                    dynamicDesc = {
                        type = "description", order = 0, fontSize = "small",
                        name = "|cff88bbdd" .. L["DYNAMIC_COLORS_DESC"] .. "|r\n",
                    },
                    dynamicEnabled = {
                        type = "toggle", order = 1, width = "full",
                        name = L["Color by Remaining Time"],
                        desc = L["Dynamically colors the countdown text based on how much time is left."],
                        get = function()
                            return MCE.db.profile.categories[key].textColorByDuration.enabled
                        end,
                        set = function(_, val)
                            MCE.db.profile.categories[key].textColorByDuration.enabled = val
                            MCE:ForceUpdateAll()
                        end,
                    },
                    -- Threshold 1: Expiring Soon
                    t1Header = {
                        type = "header", name = L["Expiring Soon"], order = 10,
                        hidden = function() return not MCE.db.profile.categories[key].textColorByDuration.enabled end,
                    },
                    t1Value = {
                        type = "range", order = 11, width = 1.0,
                        name = L["Threshold (seconds)"], min = 1, max = 60, step = 1,
                        get = function() return MCE.db.profile.categories[key].textColorByDuration.thresholds[1].threshold end,
                        set = function(_, val) MCE.db.profile.categories[key].textColorByDuration.thresholds[1].threshold = val; MCE:ForceUpdateAll() end,
                        hidden = function() return not MCE.db.profile.categories[key].textColorByDuration.enabled end,
                    },
                    t1Color = {
                        type = "color", order = 12, width = 0.5,
                        name = L["Color"], hasAlpha = true,
                        get = function() local c = MCE.db.profile.categories[key].textColorByDuration.thresholds[1].color; return c.r, c.g, c.b, c.a end,
                        set = function(_, r, g, b, a) local c = MCE.db.profile.categories[key].textColorByDuration.thresholds[1].color; c.r, c.g, c.b, c.a = r, g, b, a; MCE:ForceUpdateAll() end,
                        hidden = function() return not MCE.db.profile.categories[key].textColorByDuration.enabled end,
                    },
                    -- Threshold 2: Short Duration
                    t2Header = {
                        type = "header", name = L["Short Duration"], order = 20,
                        hidden = function() return not MCE.db.profile.categories[key].textColorByDuration.enabled end,
                    },
                    t2Value = {
                        type = "range", order = 21, width = 1.0,
                        name = L["Threshold (seconds)"], min = 5, max = 300, step = 1,
                        get = function() return MCE.db.profile.categories[key].textColorByDuration.thresholds[2].threshold end,
                        set = function(_, val) MCE.db.profile.categories[key].textColorByDuration.thresholds[2].threshold = val; MCE:ForceUpdateAll() end,
                        hidden = function() return not MCE.db.profile.categories[key].textColorByDuration.enabled end,
                    },
                    t2Color = {
                        type = "color", order = 22, width = 0.5,
                        name = L["Color"], hasAlpha = true,
                        get = function() local c = MCE.db.profile.categories[key].textColorByDuration.thresholds[2].color; return c.r, c.g, c.b, c.a end,
                        set = function(_, r, g, b, a) local c = MCE.db.profile.categories[key].textColorByDuration.thresholds[2].color; c.r, c.g, c.b, c.a = r, g, b, a; MCE:ForceUpdateAll() end,
                        hidden = function() return not MCE.db.profile.categories[key].textColorByDuration.enabled end,
                    },
                    -- Threshold 3: Long Duration
                    t3Header = {
                        type = "header", name = L["Long Duration"], order = 30,
                        hidden = function() return not MCE.db.profile.categories[key].textColorByDuration.enabled end,
                    },
                    t3Value = {
                        type = "range", order = 31, width = 1.0,
                        name = L["Threshold (seconds)"], min = 60, max = 7200, step = 60,
                        get = function() return MCE.db.profile.categories[key].textColorByDuration.thresholds[3].threshold end,
                        set = function(_, val) MCE.db.profile.categories[key].textColorByDuration.thresholds[3].threshold = val; MCE:ForceUpdateAll() end,
                        hidden = function() return not MCE.db.profile.categories[key].textColorByDuration.enabled end,
                    },
                    t3Color = {
                        type = "color", order = 32, width = 0.5,
                        name = L["Color"], hasAlpha = true,
                        get = function() local c = MCE.db.profile.categories[key].textColorByDuration.thresholds[3].color; return c.r, c.g, c.b, c.a end,
                        set = function(_, r, g, b, a) local c = MCE.db.profile.categories[key].textColorByDuration.thresholds[3].color; c.r, c.g, c.b, c.a = r, g, b, a; MCE:ForceUpdateAll() end,
                        hidden = function() return not MCE.db.profile.categories[key].textColorByDuration.enabled end,
                    },
                    -- Default color (beyond all thresholds)
                    defaultHeader = {
                        type = "header", name = L["Beyond Thresholds"], order = 40,
                        hidden = function() return not MCE.db.profile.categories[key].textColorByDuration.enabled end,
                    },
                    defaultDurationColor = {
                        type = "color", order = 41, width = 0.8,
                        name = L["Default Color"],
                        desc = L["Color used when the remaining time exceeds all thresholds."],
                        hasAlpha = true,
                        get = function() local c = MCE.db.profile.categories[key].textColorByDuration.defaultColor; return c.r, c.g, c.b, c.a end,
                        set = function(_, r, g, b, a) local c = MCE.db.profile.categories[key].textColorByDuration.defaultColor; c.r, c.g, c.b, c.a = r, g, b, a; MCE:ForceUpdateAll() end,
                        hidden = function() return not MCE.db.profile.categories[key].textColorByDuration.enabled end,
                    },
                },
            } or nil,

            -- ── 3. Swipe Edge ───────────────────────────────────────────
            swipeEdge = {
                type = "group", name = "|cffffd100" .. L["Swipe Animation"] .. "|r",
                inline = true, order = 20, disabled = disabledFn,
                args = {
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
                        set = CatSet(key, "edgeScale"),
                    },
                },
            },

            -- ── 4. Stack Counters / Charges ────────────────────────────
            stackGroup = (key == "actionbar" or key == "cooldownmanager") and {
                type = "group", name = "|cffffd100" .. L["Stack Counters / Charges"] .. "|r",
                inline = true, order = 30, disabled = disabledFn,
                args = {
                    stackEnabled = {
                        type = "toggle", order = 1, width = "full",
                        name = L["Customize Stack Text"],
                        desc = L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."],
                        get = CatGet(key, "stackEnabled"),
                        set = CatSet(key, "stackEnabled"),
                    },
                    -- Style sub-section
                    headerStyle = { type = "header", name = L["Style"], order = 10, hidden = stackHiddenFn },
                    stackFont = {
                        type = "select", order = 11, width = 1.5,
                        name = L["Font"], values = GetFontOptions,
                        get = CatGet(key, "stackFont"), set = CatSet(key, "stackFont"),
                        hidden = stackHiddenFn,
                    },
                    stackSize = {
                        type = "range", order = 12, width = 0.7,
                        name = L["Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "stackSize"), set = CatSet(key, "stackSize"),
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
                    headerPos = { type = "header", name = L["Positioning"], order = 20, hidden = stackHiddenFn },
                    stackAnchor = {
                        type = "select", order = 21,
                        name = L["Anchor Point"], values = ANCHOR_OPTIONS,
                        get = CatGet(key, "stackAnchor"), set = CatSet(key, "stackAnchor"),
                        hidden = stackHiddenFn,
                    },
                    stackOffsetX = {
                        type = "range", order = 22, width = "half",
                        name = L["Offset X"], min = -20, max = 20, step = 1,
                        get = CatGet(key, "stackOffsetX"), set = CatSet(key, "stackOffsetX"),
                        hidden = stackHiddenFn,
                    },
                    stackOffsetY = {
                        type = "range", order = 23, width = "half",
                        name = L["Offset Y"], min = -20, max = 20, step = 1,
                        get = CatGet(key, "stackOffsetY"), set = CatSet(key, "stackOffsetY"),
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

-- =========================================================================
-- ROOT OPTIONS TABLE
-- =========================================================================

function MCE:GetOptions()
    local profileOpts = LibStub("AceDBOptions-3.0"):GetOptionsTable(MCE.db)
    profileOpts.order = 10 -- ensure profiles tab is last

    return {
        type = "group",
        name = "|cff00ccffMiniCE|r",
        args = {
            -- ── General ─────────────────────────────────────────────────
            general = {
                type = "group", name = L["General"], order = 1,
                args = {
                    banner = {
                        type = "description", order = 0.1, fontSize = "large",
                        name = "|cff00ccffMinimalistCooldownEdge|r",
                        image = "Interface\\AddOns\\MinimalistCooldownEdge\\MinimalistCooldownEdge",
                        imageWidth = 48, imageHeight = 48,
                    },
                    bannerMeta = {
                        type = "description", order = 0.2, fontSize = "small",
                        name = "|cff888888v" .. addonVersion .. "  |cff666666by Anahkas|r\n",
                    },
                    bannerSep = { type = "header", name = "", order = 0.3 },
                    bannerDesc = {
                        type = "description", order = 0.4, fontSize = "medium",
                        name = "|cffbbbbbb" .. L["BANNER_DESC"] .. "|r\n",
                    },
                    -- ── Quick Toggles Dashboard ─────────────────────────
                    quickToggles = {
                        type = "group", name = "|cffffd100" .. L["Quick Toggles"] .. "|r",
                        inline = true, order = 1.5,
                        args = {
                            quickDesc = {
                                type = "description", order = 0, fontSize = "small",
                                name = "|cff888888" .. L["QUICK_TOGGLES_DESC"] .. "|r\n",
                            },
                            toggleActionbar = {
                                type = "toggle", order = 1, width = 0.85,
                                name = "|cffffd100" .. L["Action Bars"] .. "|r",
                                get = function() return MCE.db.profile.categories.actionbar.enabled end,
                                set = function(_, v) MCE.db.profile.categories.actionbar.enabled = v; MCE:ForceUpdateAll(); RefreshDynamicCategoryLabels() end,
                            },
                            toggleNameplate = {
                                type = "toggle", order = 2, width = 0.85,
                                name = "|cffffd100" .. L["Nameplates"] .. "|r",
                                get = function() return MCE.db.profile.categories.nameplate.enabled end,
                                set = function(_, v) MCE.db.profile.categories.nameplate.enabled = v; MCE:ForceUpdateAll(); RefreshDynamicCategoryLabels() end,
                            },
                            toggleUnitframe = {
                                type = "toggle", order = 3, width = 0.85,
                                name = "|cffffd100" .. L["Unit Frames"] .. "|r",
                                get = function() return MCE.db.profile.categories.unitframe.enabled end,
                                set = function(_, v) MCE.db.profile.categories.unitframe.enabled = v; MCE:ForceUpdateAll(); RefreshDynamicCategoryLabels() end,
                            },
                            toggleCooldownMgr = {
                                type = "toggle", order = 4, width = 0.85,
                                name = "|cffffd100" .. L["CooldownManager"] .. "|r",
                                get = function() return MCE.db.profile.categories.cooldownmanager.enabled end,
                                set = function(_, v) MCE.db.profile.categories.cooldownmanager.enabled = v; MCE:ForceUpdateAll(); RefreshDynamicCategoryLabels() end,
                            },
                            toggleGlobal = {
                                type = "toggle", order = 5, width = 0.85,
                                name = "|cffffd100" .. L["Others"] .. "|r",
                                get = function() return MCE.db.profile.categories.global.enabled end,
                                set = function(_, v) MCE.db.profile.categories.global.enabled = v; MCE:ForceUpdateAll(); RefreshDynamicCategoryLabels() end,
                            },
                        },
                    },
                    -- ── Tools ────────────────────────────────────────────
                    toolsGroup = {
                        type = "group", name = "|cffffd100" .. L["Tools"] .. "|r",
                        inline = true, order = 2.5,
                        args = {
                            forceRefresh = {
                                type = "execute", order = 1, width = 1.5,
                                name = L["Force Refresh"],
                                desc = L["Force a full rescan of all cooldown frames."],
                                func = function()
                                    MCE:ForceUpdateAll(true)
                                    MCE:Print(L["Full refresh completed."])
                                end,
                            },
                        },
                    },
                    resetGroup = {
                        type = "group", name = "|cffff4444" .. L["Danger Zone"] .. "|r",
                        inline = true, order = 3,
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
            actionbar = CreateCategoryOptions(2, L["Action Bars"],          "actionbar",
                L["ACTIONBAR_DESC"]),
            nameplate = CreateCategoryOptions(3, L["Nameplates"],           "nameplate",
                L["NAMEPLATE_DESC"]),
            unitframe = CreateCategoryOptions(4, L["Unit Frames"],          "unitframe",
                L["UNITFRAME_DESC"]),
            cooldownmanager = CreateCategoryOptions(5, L["CooldownManager"], "cooldownmanager",
                L["COOLDOWNMANAGER_DESC"]),
            global          = CreateCategoryOptions(6, L["Others"],          "global",
                L["OTHERS_DESC"]),

            help = {
                type = "group", name = L["Help"], order = 9,
                args = {
                    aboutHeader = {
                        type = "description", order = 0.1, fontSize = "large",
                        name = "|cff00ccffMiniCE|r\n",
                    },
                    aboutMeta = {
                        type = "description", order = 0.15, fontSize = "small",
                        name = "|cff888888v" .. addonVersion .. "|r\n",
                    },
                    aboutDesc = {
                        type = "description", order = 0.2, fontSize = "medium",
                        name = "|cffbbbbbb" .. L["HELP_ABOUT_DESC"] .. "|r\n",
                    },
                    projectGroup = {
                        type = "group", name = "|cffffd100" .. L["Project Information"] .. "|r",
                        inline = true, order = 1,
                        args = {
                            projectUrl = {
                                type = "input", order = 1, width = "full",
                                name = L["CurseForge URL"],
                                desc = L["Copy this link to open the CurseForge project page in your browser."],
                                get = function() return CURSEFORGE_URL end,
                                set = function() end,
                            },
                            developerUrl = {
                                type = "input", order = 2, width = "full",
                                name = L["Developer Page"],
                                desc = L["Copy this link to view other projects from Anahkas on CurseForge."],
                                get = function() return DEVELOPER_URL end,
                                set = function() end,
                            },
                        },
                    },
                    developmentGroup = {
                        type = "group", name = "|cffffd100" .. L["Development Status"] .. "|r",
                        inline = true, order = 2,
                        args = {
                            developmentDesc = {
                                type = "description", order = 1, fontSize = "medium",
                                name = "|cff88bbdd" .. L["HELP_DEVELOPMENT_DESC"] .. "|r\n\n|cffbbbbbb" .. L["HELP_FEEDBACK_DESC"] .. "|r",
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