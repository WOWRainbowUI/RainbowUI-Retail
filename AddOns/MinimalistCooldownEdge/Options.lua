local addonName, addon = ...
local MCE = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local L = LibStub("AceLocale-3.0"):GetLocale("MinimalistCooldownEdge")

-- === UPVALUE LOCALS ===
local format = string.format

-- Retrieve version dynamically from TOC
local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Dev"

-- === SHARED LOOKUP TABLES ===
local FONT_OPTIONS = {
    ["Fonts\\FRIZQT__.TTF"]        = "Friz Quadrata",
    ["Fonts\\FRIZQT___CYR.TTF"]   = "Friz Quadrata (Cyrillic)",
    ["Fonts\\ARIALN.TTF"]         = "Arial Narrow",
    ["Fonts\\MORPHEUS.TTF"]       = "Morpheus",
    ["Fonts\\skurri.ttf"]         = "Skurri",
    ["Fonts\\2002.TTF"]           = "2002",
    ["Interface\\AddOns\\MinimalistCooldownEdge\\expressway.ttf"] = "Expressway",
}

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

-- === DEFAULTS ===
local DEFAULT_FONT = "Interface\\AddOns\\MinimalistCooldownEdge\\expressway.ttf"

local function GetCategoryDefaults(enabled, fontSize)
    return {
        enabled = enabled,
        -- Typography
        font                 = DEFAULT_FONT,
        fontSize             = fontSize or 18,
        fontStyle            = "OUTLINE",
        textColor            = { r = 1, g = 0.8, b = 0, a = 1 },
        textAnchor           = "CENTER",
        textOffsetX          = 0,
        textOffsetY          = 0,
        hideCountdownNumbers = false,
        -- Edge
        edgeEnabled = true,
        edgeScale   = 1.4,
        -- Stack (actionbar-specific, but stored for safety)
        stackEnabled  = true,
        stackFont     = DEFAULT_FONT,
        stackSize     = 16,
        stackStyle    = "OUTLINE",
        stackColor    = { r = 1, g = 1, b = 1, a = 1 },
        stackAnchor   = "BOTTOMRIGHT",
        stackOffsetX  = -3,
        stackOffsetY  = 3,
    }
end

MCE.defaults = {
    profile = {
        debugMode = false,
        scanDepth = 10,
        categories = {
            actionbar = GetCategoryDefaults(true,  18),
            nameplate = GetCategoryDefaults(false, 12),
            unitframe = GetCategoryDefaults(false, 12),
            global    = GetCategoryDefaults(false, 18),
        },
    },
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

-- =========================================================================
-- OPTIONS BUILDER
-- =========================================================================

local function CreateCategoryOptions(order, name, key)
    local disabledFn    = function() return IsCatDisabled(key) end
    local stackHiddenFn = function() return IsStackHidden(key) end

    return {
        type = "group",
        name = name,
        order = order,
        args = {
            -- ── 1. Main Toggle ──────────────────────────────────────────
            enableGroup = {
                type = "group", name = L["State"], inline = true, order = 1,
                args = {
                    enabled = {
                        type = "toggle", order = 1, width = "full",
                        name = format(L["Enable %s"], name),
                        desc = L["Toggle styling for this category."],
                        get = CatGet(key, "enabled"),
                        set = CatSet(key, "enabled"),
                    },
                },
            },

            -- ── 2. Typography ───────────────────────────────────────────
            typography = {
                type = "group", name = L["Typography (Cooldown Numbers)"],
                inline = true, order = 10, disabled = disabledFn,
                args = {
                    font = {
                        type = "select", order = 1, width = 1.5,
                        name = L["Font Face"], values = FONT_OPTIONS,
                        get = CatGet(key, "font"), set = CatSet(key, "font"),
                    },
                    fontSize = {
                        type = "range", order = 2, width = 0.7,
                        name = L["Size"], min = 8, max = 36, step = 1,
                        get = CatGet(key, "fontSize"), set = CatSet(key, "fontSize"),
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

            -- ── 3. Swipe Edge ───────────────────────────────────────────
            swipeEdge = {
                type = "group", name = L["Swipe Animation"],
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

            -- ── 4. Stack Counters (action bar only) ─────────────────────
            stackGroup = (key == "actionbar") and {
                type = "group", name = L["Stack Counters / Charges"],
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
                        name = L["Font"], values = FONT_OPTIONS,
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
                type = "group", name = L["Maintenance"],
                inline = true, order = 100,
                args = {
                    resetCategory = {
                        type = "execute", order = 1, width = "full",
                        name = format(L["Reset %s"], name),
                        desc = L["Revert this category to default settings."],
                        confirm = true,
                        func = function()
                            MCE.db.profile.categories[key] = CopyTable(MCE.defaults.profile.categories[key])
                            MCE:ForceUpdateAll()
                            LibStub("AceConfigRegistry-3.0"):NotifyChange("MinimalistCooldownEdge")
                            print("|cff00ccffMCE:|r " .. format(L["%s settings reset."], name))
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
        name = "MiniCE",
        args = {
            -- ── General ─────────────────────────────────────────────────
            general = {
                type = "group", name = L["General"], order = 1,
                args = {
                    banner = {
                        type = "description", order = 1, fontSize = "medium",
                        name = "|cff00ccff" .. addonName .. "|r |cffffd100v" .. addonVersion .. "|r\n" ..
                               L["BANNER_DESC"],
                        image = "Interface\\AddOns\\MinimalistCooldownEdge\\MinimalistCooldownEdge",
                        imageWidth = 32, imageHeight = 32,
                    },
                    perfGroup = {
                        type = "group", name = L["Performance & Detection"],
                        inline = true, order = 2,
                        args = {
                            scanDepth = {
                                type = "range", order = 1, width = "double",
                                name = L["Scan Depth"],
                                desc = L["How deep the addon looks into UI frames to find cooldowns."],
                                min = 1, max = 20, step = 1,
                                get = function() return MCE.db.profile.scanDepth end,
                                set = function(_, val)
                                    MCE.db.profile.scanDepth = val
                                    print("|cff00ff00MCE:|r " .. L["Global Scan Depth changed. A /reload is recommended."])
                                end,
                            },
                            helpText = {
                                type = "description", order = 2, width = "full",
                                name = L["SCAN_DEPTH_HELP"],
                            },
                        },
                    },
                    resetGroup = {
                        type = "group", name = L["Danger Zone"],
                        inline = true, order = 3,
                        args = {
                            resetAll = {
                                type = "execute", order = 1, width = "full",
                                name = L["Factory Reset (All)"],
                                desc = L["Resets the entire profile to default values and reloads the UI."],
                                confirm = true,
                                func = function()
                                    MCE.db:ResetProfile()
                                    print("|cff00ccffMCE:|r " .. L["Profile reset. Reloading UI..."])
                                    ReloadUI()
                                end,
                            },
                        },
                    },
                },
            },

            -- ── Category tabs ───────────────────────────────────────────
            actionbar = CreateCategoryOptions(2, L["Action Bars"],          "actionbar"),
            nameplate = CreateCategoryOptions(3, L["Nameplates"],           "nameplate"),
            unitframe = CreateCategoryOptions(4, L["Unit Frames"],          "unitframe"),
            global    = CreateCategoryOptions(5, L["CD Manager & Others"],  "global"),

            -- ── Profiles (always last) ──────────────────────────────────
            profiles = profileOpts,
        },
    }
end