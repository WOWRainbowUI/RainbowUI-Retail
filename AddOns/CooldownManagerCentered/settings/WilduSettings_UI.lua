local _, ns = ...

--- WilduSettings - Settings Management System
local WilduSettings = {}
ns.WilduSettings = WilduSettings

ns.WilduSettings.settingPreview = {}
ns.WilduSettings.SettingsLayout = {}

local SettingsLib = LibStub("LibEQOLSettingsMode-1.0")
local LSM = LibStub("LibSharedMedia-3.0", true)

local function WilduSettings_BuildCooldown(category, layout)
    -- -- Custom Glow Alerts Settings
    -- SettingsLib:CreateHeader(category, {
    --     parentSection = customEffectsSection,
    --     name = "Custom Glow Alerts",
    -- })

    -- SettingsLib:CreateText(category, {
    --     name = "Replace Blizzard's default alert glow with custom LibCustomGlow effects.\nRequires at least one Square Icons Styling option enabled.",
    --     parentSection = customEffectsSection,
    -- })

    -- SettingsLib:CreateDropdown(category, {
    --     parentSection = customEffectsSection,
    --     prefix = "CMC_",
    --     key = "cooldownManager_glowStyle",
    --     name = "Glow Alert Style",
    --     default = "BLIZZARD",
    --     values = {
    --         ["BLIZZARD"] = "Blizzard Default (don't replace)",
    --         ["PIXEL"] = "Pixel Glow",
    --         ["AUTOCAST"] = "AutoCast Shine",
    --         ["BUTTONGLOW"] = "Button Glow",
    --     },
    --     order = { "BLIZZARD", "PIXEL", "AUTOCAST", "BUTTONGLOW" },
    --     get = function()
    --         return ns.db.profile.cooldownManager_glowStyle or "BLIZZARD"
    --     end,
    --     set = function(value)
    --         ns.db.profile.cooldownManager_glowStyle = value
    --         if ns.GlowEffects then
    --             ns.GlowEffects:OnSettingChanged()
    --         end
    --     end,
    --     desc = "Select the glow effect style for cooldown alerts on Square Icons.\n\n|cff8ccd00Blizzard Default|r - Keep default behavior\n|cff8ccd00Pixel Glow|r - Animated pixel border effect\n|cff8ccd00AutoCast Shine|r - Spinning shine particles\n|cff8ccd00Button Glow|r - Classic action button glow",
    -- })

    SettingsLib:CreateHeader(category, {
        name = "Set how it grows and from where",
    })
    SettingsLib:CreateText(category, {
        name = "Dynamic alignment of Icons and Bars is happening within the Viewer container.\nSnap to Grid in |cff87bbcaEdit Mode|r for best results.",
    })
    SettingsLib:CreateDropdown(category, {
        prefix = "CMC_",
        key = "cooldownManager_alignBuffIcons_growFromDirection",
        name = "Tracked Buff Icons|cffff0000*|r",
        searchtags = { "Grow", "Direction", "Alignment", "Position", "Layout", "Anchor", "Left", "Right", "Center" },
        default = "CENTER",

        optionfunc = function()
            return {
                ["START"] = BuffIconCooldownViewer.isHorizontal and "Grow from the |cff8ccd00Start|r"
                    or "Grow from the |cff8ccd00Start|r",
                ["CENTER"] = "Grow from |cff8ccd00Center|r",
                ["END"] = BuffIconCooldownViewer.isHorizontal and "Grow from the |cff8ccd00End|r"
                    or "Grow from the |cff8ccd00End|r",
                ["Disable"] = "|cff7c7c7cDisable dynamic layout|r",
            }
        end,
        order = { "START", "CENTER", "END", "Disable" },
        get = function()
            return ns.db.profile.cooldownManager_alignBuffIcons_growFromDirection or "CENTER"
        end,
        set = function(value)
            ns.db.profile.cooldownManager_alignBuffIcons_growFromDirection = value
            ns.API:RefreshCooldownManager()
        end,
    })

    SettingsLib:CreateDropdown(category, {
        prefix = "CMC_",
        key = "cooldownManager_alignBuffBars_growFromDirection",
        name = "Tracked Bars",
        searchtags = {
            "Grow",
            "Direction",
            "Alignment",
            "Position",
            "Layout",
            "Anchor",
            "Top",
            "Bottom",
            "Buff",
            "Bar",
        },
        default = "BOTTOM",
        values = {
            BOTTOM = "Bars grow from |cff8ccd00Bottom|r",
            TOP = "Bars grow from |cff8ccd00Top|r",
            ["Disable"] = "|cff7c7c7cDisable dynamic layout|r",
        },
        order = { "TOP", "BOTTOM", "Disable" },
        get = function()
            return ns.db.profile.cooldownManager_alignBuffBars_growFromDirection or "BOTTOM"
        end,
        set = function(value)
            ns.db.profile.cooldownManager_alignBuffBars_growFromDirection = value
            ns.API:RefreshCooldownManager()
        end,
    })

    SettingsLib:CreateDropdown(category, {
        prefix = "CMC_",
        key = "cooldownManager_centerEssential_growFromDirection",
        name = "Essential Icons|cffff0000*|r",
        searchtags = { "Grow", "Direction", "Alignment", "Position", "Layout", "Anchor", "Row", "Column", "Essential" },
        default = "TOP",
        optionfunc = function()
            return {
                BOTTOM = EssentialCooldownViewer.isHorizontal and "New Rows on |cff8ccd00Top|r"
                    or "New Columns to the |cff8ccd00Left|r",
                TOP = EssentialCooldownViewer.isHorizontal and "New Rows |cff8ccd00Below|r"
                    or "New Columns to the |cff8ccd00Right|r",
                ["Disable"] = "|cff7c7c7cDisable dynamic layout|r",
            }
        end,
        order = { "TOP", "BOTTOM", "Disable" },
        get = function()
            return ns.db.profile.cooldownManager_centerEssential_growFromDirection or "TOP"
        end,
        set = function(value)
            ns.db.profile.cooldownManager_centerEssential_growFromDirection = value
            ns.API:RefreshCooldownManager()
        end,
    })

    SettingsLib:CreateDropdown(category, {
        prefix = "CMC_",
        key = "cooldownManager_centerUtility_growFromDirection",
        name = "Utility Icons|cffff0000*|r",
        searchtags = { "Grow", "Direction", "Alignment", "Position", "Layout", "Anchor", "Row", "Column", "Utility" },
        default = "TOP",
        optionfunc = function()
            return {
                BOTTOM = UtilityCooldownViewer.isHorizontal and "New Rows on |cff8ccd00Top|r"
                    or "New Columns to the |cff8ccd00Left|r",
                TOP = UtilityCooldownViewer.isHorizontal and "New Rows |cff8ccd00Below|r"
                    or "New Columns to the |cff8ccd00Right|r",
                ["Disable"] = "|cff7c7c7cDisable dynamic layout|r",
            }
        end,
        order = { "TOP", "BOTTOM", "Disable" },
        get = function()
            return ns.db.profile.cooldownManager_centerUtility_growFromDirection or "TOP"
        end,
        set = function(value)
            ns.db.profile.cooldownManager_centerUtility_growFromDirection = value
            ns.API:RefreshCooldownManager()
        end,
    })

    SettingsLib:CreateCheckboxSlider(category, {
        prefix = "CMC_",
        key = "cooldownManager_utility_dimWhenNotOnCD",
        name = "Dim Utility when not on CD",
        searchtags = { "Dim", "Opacity", "Faded", "Transparent", "Utility", "Cooldown", "Hide", "Icons" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_utility_dimWhenNotOnCD
        end,
        set = function(value)
            ns.db.profile.cooldownManager_utility_dimWhenNotOnCD = value
            ns.CooldownManager.ForceRefresh({ utility = true })
        end,
        desc = "Dim Utility Cooldown icons when they are not on cooldown.",

        sliderKey = "cooldownManager_utility_dimOpacity",
        sliderName = "Dim Opacity",
        sliderMin = 0,
        sliderMax = 0.9,
        sliderStep = 0.05,
        sliderDefault = 0.3,
        sliderGet = function()
            return ns.db.profile.cooldownManager_utility_dimOpacity
        end,
        sliderSet = function(value)
            ns.db.profile.cooldownManager_utility_dimOpacity = value
            ns.CooldownManager.ForceRefresh({ utility = true })
        end,
        sliderFormatter = function(value)
            return string.format("%.0f%%", value * 100)
        end,
    })

    SettingsLib:CreateText(category, {
        name = "|cffff0000*|rTo change |cfffff100Padding|r or to change between |cfffff100columns / rows|r\n Go to |cff87bbcaEdit Mode|r and change |cfffff100Icon Padding & Orientation|r.",
    })

    SettingsLib:CreateButton(category, {
        text = "Open Edit Mode",
        func = function()
            ns.API:ToggleEditMode()
        end,
        parentSection = cooldownSection,
    })
    SettingsLib:CreateButton(category, {
        text = "Open Cooldown Settings",
        func = function()
            if not InCombatLockdown() then
                HideUIPanel(SettingsPanel)
                C_Timer.After(0.1, function()
                    CooldownViewerSettings:ShowUIPanel(false)
                end)
            end
        end,
        parentSection = cooldownSection,
    })
    SettingsLib:CreateText(category, {
        name = "You can write |cfffff100/cds|r or |cfffff100/cdm|r Go to |cfffff100Cooldown Settings|r",
    })

    local squareIconsSection = SettingsLib:CreateExpandableSection(category, {
        name = "|cff5fb64aIco|r|cff8ccd00ns|r Styling",
        expanded = false,
        colorizeTitle = true,
    })
    SettingsLib:CreateText(category, {
        name = "|cfffff100Padding|r can no longer be set within addon, please use |cff87bbcaEdit Mode|r",
        parentSection = squareIconsSection,
    })

    SettingsLib:CreateCheckbox(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIcons_BuffIcons",
        name = "Square Buff Icons",
        searchtags = { "Square", "Shape", "Style", "Rectangular", "Flat", "Modern", "Buff", "Icon", "Texture" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_squareIcons_BuffIcons
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIcons_BuffIcons = value
            ns.StyledIcons:OnSettingChanged()
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "Apply square icon styling to Buff Icons viewer.",
    })
    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsBorder_BuffIcons",
        name = "Border Thickness",
        searchtags = { "Border", "Thickness", "Width", "Edge", "Frame", "Outline", "Buff", "Size" },
        default = 4,
        min = 0,
        max = 6,
        step = 1,
        formatter = function(value)
            return string.format("%.0fpx", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_squareIconsBorder_BuffIcons or 4
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIconsBorder_BuffIcons = value
            if ns.StyledIcons then
                ns.StyledIcons:OnSettingChanged()
            end
        end,
        desc = "Border thickness for square Buff Icons (space between icon edge and texture).",
        -- isEnabled = function()
        --     return not ns.API:IsSomeAddOnRestrictionActive()
        -- end,
    })

    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsZoom_BuffIcons",
        name = "Zoom",
        searchtags = { "Zoom", "Scale", "Crop", "Magnify", "Enlarge", "Texture", "Buff", "Icon" },
        default = 0,
        min = 0,
        max = 0.5,
        step = 0.01,
        formatter = function(value)
            return string.format("%.2f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_squareIconsZoom_BuffIcons or 0
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIconsZoom_BuffIcons = value
            ns.StyledIcons:OnSettingChanged()
        end,
        desc = "Zoom level for square Buff Icons (0 = no zoom, 0.5 = maximum zoom).",
    })
    SettingsLib:CreateText(category, {
        name = "",
        parentSection = squareIconsSection,
    })

    SettingsLib:CreateCheckbox(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIcons_Essential",
        name = "Square Essential Cooldowns",
        searchtags = { "Square", "Shape", "Style", "Rectangular", "Flat", "Modern", "Essential", "Icon", "Texture" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_squareIcons_Essential
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIcons_Essential = value
            ns.StyledIcons:OnSettingChanged()
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "Apply square icon styling to Essential Cooldowns viewer.",
    })

    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsBorder_Essential",
        name = "Border Thickness",
        searchtags = { "Border", "Thickness", "Width", "Edge", "Frame", "Outline", "Essential", "Size" },
        default = 4,
        min = 0,
        max = 6,
        step = 1,
        formatter = function(value)
            return string.format("%.0fpx", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_squareIconsBorder_Essential or 4
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIconsBorder_Essential = value

            ns.StyledIcons:OnSettingChanged()
        end,
        desc = "Border thickness for square Essential Icons (space between icon edge and texture).",
        -- isEnabled = function()
        --     return not ns.API:IsSomeAddOnRestrictionActive()
        -- end,
    })

    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsZoom_Essential",
        name = "Icon Zoom",
        searchtags = { "Zoom", "Scale", "Crop", "Magnify", "Enlarge", "Texture", "Essential", "Icon" },
        default = 0,
        min = 0,
        max = 0.5,
        step = 0.01,
        formatter = function(value)
            return string.format("%.2f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_squareIconsZoom_Essential or 0
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIconsZoom_Essential = value
            if ns.StyledIcons then
                ns.StyledIcons:OnSettingChanged()
            end
        end,
        desc = "Zoom level for square Essential Icons (0 = no zoom, 0.5 = maximum zoom).",
    })
    SettingsLib:CreateText(category, {
        name = "",
        parentSection = squareIconsSection,
    })

    SettingsLib:CreateCheckbox(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIcons_Utility",
        name = "Square Utility Cooldowns",
        searchtags = { "Square", "Shape", "Style", "Rectangular", "Flat", "Modern", "Utility", "Icon", "Texture" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_squareIcons_Utility
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIcons_Utility = value
            ns.StyledIcons:OnSettingChanged()
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "Apply square icon styling to Utility Cooldowns viewer.",
    })

    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsBorder_Utility",
        name = "Border Thickness",
        searchtags = { "Border", "Thickness", "Width", "Edge", "Frame", "Outline", "Utility", "Size" },
        default = 4,
        min = 0,
        max = 6,
        step = 1,
        formatter = function(value)
            return string.format("%.0fpx", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_squareIconsBorder_Utility or 4
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIconsBorder_Utility = value
            if ns.StyledIcons then
                ns.StyledIcons:OnSettingChanged()
            end
        end,
        desc = "Border thickness for square Utility Icons (space between icon edge and texture).",
        -- isEnabled = function()
        --     return not ns.API:IsSomeAddOnRestrictionActive()
        -- end,
    })

    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsZoom_Utility",
        name = "Icon Zoom",
        searchtags = { "Zoom", "Scale", "Crop", "Magnify", "Enlarge", "Texture", "Utility", "Icon" },
        default = 0,
        min = 0,
        max = 0.5,
        step = 0.01,
        formatter = function(value)
            return string.format("%.2f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_squareIconsZoom_Utility or 0
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIconsZoom_Utility = value
            if ns.StyledIcons then
                ns.StyledIcons:OnSettingChanged()
            end
        end,
        desc = "Zoom level for square Utility Icons (0 = no zoom, 0.5 = maximum zoom).",
    })
    SettingsLib:CreateCheckbox(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_normalizeUtilitySize",
        name = "Normalize Utility Icons Scaling",
        searchtags = { "Fix", "Normalize", "Size", "Uniform", "Match", "Equal", "Same", "Utility", "Icon" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_normalizeUtilitySize
        end,
        set = function(value)
            ns.db.profile.cooldownManager_normalizeUtilitySize = value
            ns.StyledIcons:OnSettingChanged()
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "Set base Utility Cooldown Icons |cffff0000base|r size as Essential Cooldowns Icons\nIt helps to have a more uniform look when both viewers are used together.",
    })

    local cooldownSection = SettingsLib:CreateExpandableSection(category, {
        name = "|cffeeeeeeCooldown|r Settings",
        expanded = false,
        colorizeTitle = true,
    })
    local customSwipeColorCheckbox = SettingsLib:CreateCheckbox(category, {
        prefix = "CMC_",
        key = "cooldownManager_customSwipeColor_enabled",
        name = "Enable Custom Overlay Colors",
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_customSwipeColor_enabled or false
        end,
        set = function(value)
            ns.db.profile.cooldownManager_customSwipeColor_enabled = value
        end,
        desc = "Enable custom coloring for the cooldown swipe overlay.",
        parentSection = cooldownSection,
    })

    SettingsLib:CreateColorOverrides(category, {
        key = "cooldownManager_customActiveColor",
        entries = {
            { key = "active", label = "Active Aura Color" },
        },
        hasOpacity = true,
        getColor = function(key)
            if key == "active" then
                return ns.db.profile.cooldownManager_customActiveColor_r or 1,
                    ns.db.profile.cooldownManager_customActiveColor_g or 0.95,
                    ns.db.profile.cooldownManager_customActiveColor_b or 0.57,
                    ns.db.profile.cooldownManager_customActiveColor_a or 0.69
            end
        end,
        setColor = function(key, r, g, b, a)
            if key == "active" then
                ns.db.profile.cooldownManager_customActiveColor_r = r
                ns.db.profile.cooldownManager_customActiveColor_g = g
                ns.db.profile.cooldownManager_customActiveColor_b = b
                if a == 0.7 then
                    a = 0.69
                end
                ns.db.profile.cooldownManager_customActiveColor_a = a
            end
        end,
        getDefaultColor = function(key)
            if key == "active" then
                return 1, 0.95, 0.57, 0.69 -- Default black swipe
            end
        end,
        parentSection = cooldownSection,
    })

    SettingsLib:CreateColorOverrides(category, {
        key = "cooldownManager_customCDSwipeColor",
        entries = {
            { key = "active", label = "Cooldown Swipe Color" },
        },
        hasOpacity = true,
        getColor = function(key)
            if key == "active" then
                return ns.db.profile.cooldownManager_customCDSwipeColor_r or 0,
                    ns.db.profile.cooldownManager_customCDSwipeColor_g or 0,
                    ns.db.profile.cooldownManager_customCDSwipeColor_b or 0,
                    ns.db.profile.cooldownManager_customCDSwipeColor_a or 0.69
            end
        end,
        setColor = function(key, r, g, b, a)
            if key == "active" then
                ns.db.profile.cooldownManager_customCDSwipeColor_r = r
                ns.db.profile.cooldownManager_customCDSwipeColor_g = g
                ns.db.profile.cooldownManager_customCDSwipeColor_b = b
                if a == 0.7 then
                    a = 0.69
                end
                ns.db.profile.cooldownManager_customCDSwipeColor_a = a
            end
        end,
        getDefaultColor = function(key)
            if key == "active" then
                return 0, 0, 0, 0.69 -- Default black swipe
            end
        end,
        parentSection = cooldownSection,
    })

    SettingsLib:CreateButton(category, {
        text = "Set default colors",
        func = function()
            ns.db.profile.cooldownManager_customActiveColor_r = 1
            ns.db.profile.cooldownManager_customActiveColor_g = 0.95
            ns.db.profile.cooldownManager_customActiveColor_b = 0.57
            ns.db.profile.cooldownManager_customActiveColor_a = 0.69
            ns.db.profile.cooldownManager_customCDSwipeColor_r = 0
            ns.db.profile.cooldownManager_customCDSwipeColor_g = 0
            ns.db.profile.cooldownManager_customCDSwipeColor_b = 0
            ns.db.profile.cooldownManager_customCDSwipeColor_a = 0.69
            ReloadUI()
        end,
        parentSection = cooldownSection,
    })

    SettingsLib:CreateHeader(category, {
        name = "Cooldown Number Settings",
        parentSection = cooldownSection,
    })

    SettingsLib:CreateScrollDropdown(category, {
        parentSection = cooldownSection,
        prefix = "CMC_",
        key = "cooldownManager_cooldownFontName",
        name = "Cooldown Font",
        searchtags = { "Font", "Text", "Cooldown", "Count", "Number", "Typeface", "Typography", "SharedMedia" },
        default = "Friz Quadrata TT",
        height = 220,
        get = function()
            return ns.db.profile.cooldownManager_cooldownFontName or "Friz Quadrata TT"
        end,
        set = function(value)
            ns.db.profile.cooldownManager_cooldownFontName = value
            ns.CooldownFont:RefreshAll()
        end,
        desc = "Select the font for ability cooldown numbers. Uses SharedMedia fonts if available.",
        generator = function(dropdown, rootDescription)
            dropdown.fontPool = {}
            if not dropdown._CMC_FontFace_Dropdown_OnMenuClosed_hooked then
                hooksecurefunc(dropdown, "OnMenuClosed", function()
                    for _, fontDisplay in pairs(dropdown.fontPool) do
                        fontDisplay:Hide()
                    end
                end)
                dropdown._CMC_FontFace_Dropdown_OnMenuClosed_hooked = true
            end
            local fonts = LSM:HashTable(LSM.MediaType.FONT)
            local sortedFonts = {}
            for fontName in pairs(fonts) do
                if fontName ~= "" then
                    table.insert(sortedFonts, fontName)
                end
            end
            table.sort(sortedFonts)

            for index, fontName in ipairs(sortedFonts) do
                local fontPath = fonts[fontName]

                local button = rootDescription:CreateRadio(fontName, function()
                    return ns.db.profile.cooldownManager_cooldownFontName == fontName
                end, function()
                    ns.db.profile.cooldownManager_cooldownFontName = fontName
                    ns.CooldownFont:RefreshAll()
                    dropdown:SetText(fontName)
                end)

                button:AddInitializer(function(self)
                    local fontDisplay = dropdown.fontPool[index]
                    if not fontDisplay then
                        fontDisplay = dropdown:CreateFontString(nil, "BACKGROUND")
                        dropdown.fontPool[index] = fontDisplay
                    end

                    self.fontString:Hide()

                    fontDisplay:SetParent(self)
                    fontDisplay:SetPoint("LEFT", self.fontString, "LEFT", 0, 0)
                    fontDisplay:SetFont(fontPath, 12)
                    fontDisplay:SetText(fontName)
                    fontDisplay:Show()
                end)
            end
        end,
    })

    SettingsLib:CreateMultiDropdown(category, {
        parentSection = cooldownSection,
        prefix = "CMC_",
        key = "cooldownManager_cooldownFontFlags",
        name = "Font Flags",
        customText = "No Flags",
        searchtags = { "Font", "Flags", "Outline", "Shadow", "Thick", "Monochrome", "Text", "Style" },
        defaultSelection = {},
        values = {
            ["OUTLINE"] = "Outline",
            ["THICKOUTLINE"] = "Thick Outline",
            ["MONOCHROME"] = "Monochrome",
        },
        getSelection = function()
            return ns.db.profile.cooldownManager_cooldownFontFlags or {}
        end,
        setSelection = function(value)
            ns.db.profile.cooldownManager_cooldownFontFlags = value
            ns.CooldownFont:RefreshAll()
        end,
        desc = "Select font flags for ability cooldown numbers.",
    })

    local cooldownFontSizeValues = {
        ["NIL"] = "Default",
        ["0"] = "Hide",
        ["10"] = "10",
        ["12"] = "12",
        ["14"] = "14",
        ["16"] = "16",
        ["18"] = "18",
        ["20"] = "20",
        ["22"] = "22",
        ["24"] = "24",
        ["26"] = "26",
        ["28"] = "28",
        ["30"] = "30",
        ["32"] = "32",
        ["34"] = "34",
        ["36"] = "36",
        ["38"] = "38",
    }
    local cooldownFontSizeOrder = {
        "NIL",
        "0",
        "10",
        "12",
        "14",
        "16",
        "18",
        "20",
        "22",
        "24",
        "26",
        "28",
        "30",
        "32",
        "34",
        "36",
        "38",
    }

    local function CreateCooldownFontSizeDropdown(
        parentSection,
        key,
        name,
        getFn,
        setFn,
        checkboxKey,
        checkboxGet,
        checkboxSet
    )
        SettingsLib:CreateCheckboxDropdown(category, {
            parentSection = parentSection,
            prefix = "CMC_",
            dropdownKey = key,
            key = checkboxKey,
            name = name,
            dropdownDefault = "NIL",
            dropdownValues = cooldownFontSizeValues,
            dropdownOrder = cooldownFontSizeOrder,
            dropdownGet = getFn,
            dropdownSet = setFn,
            get = checkboxGet,
            set = checkboxSet,
            default = false,
        })
    end

    CreateCooldownFontSizeDropdown(
        cooldownSection,
        "cooldownManager_cooldownFontSizeEssential",
        "Change on Essential",
        function()
            return ns.db.profile.cooldownManager_cooldownFontSizeEssential ~= nil
                    and tostring(ns.db.profile.cooldownManager_cooldownFontSizeEssential)
                or "NIL"
        end,
        function(value)
            if value == "NIL" then
                ns.db.profile.cooldownManager_cooldownFontSizeEssential = "NIL"
            else
                local n = tonumber(value)
                ns.db.profile.cooldownManager_cooldownFontSizeEssential = n
            end
            ns.CooldownFont:RefreshAll()
        end,
        "cooldownManager_cooldownFontSizeEssential_enabled",
        function()
            return ns.db.profile.cooldownManager_cooldownFontSizeEssential_enabled
        end,
        function(value)
            ns.db.profile.cooldownManager_cooldownFontSizeEssential_enabled = value
            if not value then
                ns.API:ShowReloadUIConfirmation()
            end
            ns.CooldownFont:RefreshAll()
        end
    )
    CreateCooldownFontSizeDropdown(
        cooldownSection,
        "cooldownManager_cooldownFontSizeUtility",
        "Change on Utility",
        function()
            return ns.db.profile.cooldownManager_cooldownFontSizeUtility ~= nil
                    and tostring(ns.db.profile.cooldownManager_cooldownFontSizeUtility)
                or "NIL"
        end,
        function(value)
            if value == "NIL" then
                ns.db.profile.cooldownManager_cooldownFontSizeUtility = "NIL"
            else
                local n = tonumber(value)
                ns.db.profile.cooldownManager_cooldownFontSizeUtility = n
            end
            ns.CooldownFont:RefreshAll()
        end,
        "cooldownManager_cooldownFontSizeUtility_enabled",
        function()
            return ns.db.profile.cooldownManager_cooldownFontSizeUtility_enabled
        end,
        function(value)
            ns.db.profile.cooldownManager_cooldownFontSizeUtility_enabled = value
            if not value then
                ns.API:ShowReloadUIConfirmation()
            end
            ns.CooldownFont:RefreshAll()
        end
    )
    CreateCooldownFontSizeDropdown(
        cooldownSection,
        "cooldownManager_cooldownFontSizeBuffIcons",
        "Change on Tracked Buffs",
        function()
            return ns.db.profile.cooldownManager_cooldownFontSizeBuffIcons ~= nil
                    and tostring(ns.db.profile.cooldownManager_cooldownFontSizeBuffIcons)
                or "NIL"
        end,
        function(value)
            if value == "NIL" then
                ns.db.profile.cooldownManager_cooldownFontSizeBuffIcons = "NIL"
            else
                local n = tonumber(value)
                ns.db.profile.cooldownManager_cooldownFontSizeBuffIcons = n
            end
            ns.CooldownFont:RefreshAll()
        end,
        "cooldownManager_cooldownFontSizeBuffIcons_enabled",
        function()
            return ns.db.profile.cooldownManager_cooldownFontSizeBuffIcons_enabled
        end,
        function(value)
            ns.db.profile.cooldownManager_cooldownFontSizeBuffIcons_enabled = value
            if not value then
                ns.API:ShowReloadUIConfirmation()
            end
            ns.CooldownFont:RefreshAll()
        end
    )

    local stackNumberSection = SettingsLib:CreateExpandableSection(category, {
        name = "Ability |cffeeeeeeStacks|r Number Settings",
        expanded = false,
        colorizeTitle = true,
    })

    SettingsLib:CreateText(category, {
        name = "|cffff0000*|rSome changes require |cff00ff00Reload|r to return to default positions and fonts.",
        parentSection = stackNumberSection,
    })

    SettingsLib:CreateScrollDropdown(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackFontName",
        name = "Font",
        searchtags = { "Font", "Text", "Stack", "Count", "Number", "Typeface", "Typography", "SharedMedia" },
        default = "Friz Quadrata TT",
        height = 220,
        get = function()
            return ns.db.profile.cooldownManager_stackFontName or "Friz Quadrata TT"
        end,
        set = function(value)
            ns.db.profile.cooldownManager_stackFontName = value
            ns.Stacks:OnSettingChanged()
        end,
        desc = "Select the font for ability stack numbers. Uses SharedMedia fonts if available.",
        generator = function(dropdown, rootDescription)
            dropdown.fontPool = {}
            if not dropdown._CMC_FontFace_Dropdown_OnMenuClosed_hooked then
                hooksecurefunc(dropdown, "OnMenuClosed", function()
                    for _, fontDisplay in pairs(dropdown.fontPool) do
                        fontDisplay:Hide()
                    end
                end)
                dropdown._CMC_FontFace_Dropdown_OnMenuClosed_hooked = true
            end
            local fonts = LSM:HashTable(LSM.MediaType.FONT)
            local sortedFonts = {}
            for fontName in pairs(fonts) do
                if fontName ~= "" then
                    table.insert(sortedFonts, fontName)
                end
            end
            table.sort(sortedFonts)

            for index, fontName in ipairs(sortedFonts) do
                local fontPath = fonts[fontName]

                local button = rootDescription:CreateRadio(fontName, function()
                    return ns.db.profile.cooldownManager_stackFontName == fontName
                end, function()
                    ns.db.profile.cooldownManager_stackFontName = fontName
                    ns.Stacks:OnSettingChanged()
                    dropdown:SetText(fontName)
                end)

                button:AddInitializer(function(self)
                    local fontDisplay = dropdown.fontPool[index]
                    if not fontDisplay then
                        fontDisplay = dropdown:CreateFontString(nil, "BACKGROUND")
                        dropdown.fontPool[index] = fontDisplay
                    end

                    self.fontString:Hide()

                    fontDisplay:SetParent(self)
                    fontDisplay:SetPoint("LEFT", self.fontString, "LEFT", 0, 0)
                    fontDisplay:SetFont(fontPath, 12)
                    fontDisplay:SetText(fontName)
                    fontDisplay:Show()
                end)
            end
        end,
    })

    SettingsLib:CreateMultiDropdown(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackFontFlags",
        name = "Font Flags",
        customText = "No Flags",
        searchtags = { "Font", "Flags", "Outline", "Shadow", "Thick", "Monochrome", "Text", "Style" },
        defaultSelection = {},
        values = {
            ["OUTLINE"] = "Outline",
            ["THICKOUTLINE"] = "Thick Outline",
            ["MONOCHROME"] = "Monochrome",
        },
        getSelection = function()
            return ns.db.profile.cooldownManager_stackFontFlags or {}
        end,
        setSelection = function(value)
            ns.db.profile.cooldownManager_stackFontFlags = value
            ns.Stacks:OnSettingChanged()
        end,
        desc = "Select font flags for ability stack numbers.",
    })

    local fontSizeValues = {
        ["NIL"] = "Don't change",
        ["10"] = "10",
        ["12"] = "12",
        ["14"] = "14",
        ["16"] = "16",
        ["18"] = "18",
        ["20"] = "20",
        ["22"] = "22",
        ["24"] = "24",
        ["26"] = "26",
        ["28"] = "28",
        ["30"] = "30",
        ["32"] = "32",
        ["34"] = "34",
        ["36"] = "36",
        ["38"] = "38",
    }
    local fontSizeOrder = {
        "NIL",
        "10",
        "12",
        "14",
        "16",
        "18",
        "20",
        "22",
        "24",
        "26",
        "28",
        "30",
        "32",
        "34",
        "36",
        "38",
    }

    local function CreateStackFontSizeDropdown(parentSection, key, name, getFn, setFn)
        SettingsLib:CreateDropdown(category, {
            parentSection = parentSection,
            prefix = "CMC_",
            key = key,
            name = name,
            default = "NIL",
            values = fontSizeValues,
            order = fontSizeOrder,
            get = getFn,
            set = setFn,
        })
    end

    local anchorPointValues = {
        TOPLEFT = "Top Left",
        TOP = "Top",
        TOPRIGHT = "Top Right",
        LEFT = "Left",
        RIGHT = "Right",
        BOTTOMLEFT = "Bottom Left",
        BOTTOM = "Bottom",
        BOTTOMRIGHT = "Bottom Right",
    }
    local anchorPointOrder = {
        "TOPLEFT",
        "TOP",
        "TOPRIGHT",
        "LEFT",
        "RIGHT",
        "BOTTOMLEFT",
        "BOTTOM",
        "BOTTOMRIGHT",
    }

    SettingsLib:CreateHeader(category, {
        parentSection = stackNumberSection,
        name = "Stacks Number on Tracked Buff Icons",
    })
    SettingsLib:CreateCheckboxDropdown(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorBuffIcons_enabled",
        dropdownKey = "cooldownManager_stackAnchorBuffIcons_point",
        name = "Enable & Anchor|cffff0000*|r",
        searchtags = { "Stack", "Count", "Number", "Anchor", "Position", "Buff", "Enable", "Corner" },
        default = false,
        dropdownDefault = "BOTTOMRIGHT",
        get = function()
            return ns.db.profile.cooldownManager_stackAnchorBuffIcons_enabled
        end,
        set = function(value)
            ns.db.profile.cooldownManager_stackAnchorBuffIcons_enabled = value
            if not value then
                ns.API:ShowReloadUIConfirmation()
            end
            ns.Stacks:ApplyStackFonts("BuffIconCooldownViewer")
        end,
        dropdownGet = function()
            return ns.db.profile.cooldownManager_stackAnchorBuffIcons_point or "BOTTOMRIGHT"
        end,
        dropdownSet = function(value)
            ns.db.profile.cooldownManager_stackAnchorBuffIcons_point = value
            ns.Stacks:ApplyStackFonts("BuffIconCooldownViewer")
        end,
        dropdownValues = anchorPointValues,
        dropdownOrder = anchorPointOrder,
        desc = "Enable and select anchor point for Buff Icons stack count position.",
    })

    CreateStackFontSizeDropdown(stackNumberSection, "cooldownManager_stackFontSizeBuffIcons", "Font Size", function()
        return ns.db.profile.cooldownManager_stackFontSizeBuffIcons ~= nil
                and tostring(ns.db.profile.cooldownManager_stackFontSizeBuffIcons)
            or "NIL"
    end, function(value)
        if value == "NIL" then
            ns.db.profile.cooldownManager_stackFontSizeBuffIcons = nil
            ns.API:ShowReloadUIConfirmation()
        else
            local n = tonumber(value)
            ns.db.profile.cooldownManager_stackFontSizeBuffIcons = n and math.floor(n + 0.5) or nil
        end
        ns.Stacks:ApplyStackFonts("BuffIconCooldownViewer")
    end)
    SettingsLib:CreateSlider(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorBuffIcons_offsetX",
        name = "X Offset",
        default = 0,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_stackAnchorBuffIcons_offsetX or 0
        end,
        set = function(value)
            local v = math.floor((value or 0) + 0.5)
            ns.db.profile.cooldownManager_stackAnchorBuffIcons_offsetX = v
            ns.Stacks:ApplyStackFonts("BuffIconCooldownViewer")
        end,
    })
    SettingsLib:CreateSlider(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorBuffIcons_offsetY",
        name = "Y Offset",
        default = 0,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_stackAnchorBuffIcons_offsetY or 0
        end,
        set = function(value)
            local v = math.floor((value or 0) + 0.5)
            ns.db.profile.cooldownManager_stackAnchorBuffIcons_offsetY = v
            ns.Stacks:ApplyStackFonts("BuffIconCooldownViewer")
        end,
    })

    SettingsLib:CreateHeader(category, {
        parentSection = stackNumberSection,
        name = "Stacks Number on Essential Cooldowns Icons",
    })
    SettingsLib:CreateCheckboxDropdown(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorEssential_enabled",
        dropdownKey = "cooldownManager_stackAnchorEssential_point",
        name = "Enable & Anchor|cffff0000*|r",
        searchtags = { "Stack", "Count", "Number", "Anchor", "Position", "Essential", "Enable", "Corner" },
        default = false,
        dropdownDefault = "BOTTOMRIGHT",
        get = function()
            return ns.db.profile.cooldownManager_stackAnchorEssential_enabled
        end,
        set = function(value)
            ns.db.profile.cooldownManager_stackAnchorEssential_enabled = value
            if not value then
                ns.API:ShowReloadUIConfirmation()
            end
            ns.Stacks:ApplyStackFonts("EssentialCooldownViewer")
        end,
        dropdownGet = function()
            return ns.db.profile.cooldownManager_stackAnchorEssential_point or "BOTTOMRIGHT"
        end,
        dropdownSet = function(value)
            ns.db.profile.cooldownManager_stackAnchorEssential_point = value
            ns.Stacks:ApplyStackFonts("EssentialCooldownViewer")
        end,
        dropdownValues = anchorPointValues,
        dropdownOrder = anchorPointOrder,
        desc = "Enable and select anchor point for Essential Cooldown stack count position.",
    })

    CreateStackFontSizeDropdown(stackNumberSection, "cooldownManager_stackFontSizeEssential", "Font Size", function()
        return ns.db.profile.cooldownManager_stackFontSizeEssential ~= nil
                and tostring(ns.db.profile.cooldownManager_stackFontSizeEssential)
            or "NIL"
    end, function(value)
        if value == "NIL" then
            ns.db.profile.cooldownManager_stackFontSizeEssential = nil
            ns.API:ShowReloadUIConfirmation()
        else
            local n = tonumber(value)
            ns.db.profile.cooldownManager_stackFontSizeEssential = n and math.floor(n + 0.5) or nil
        end
        ns.Stacks:ApplyStackFonts("EssentialCooldownViewer")
    end)
    SettingsLib:CreateSlider(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorEssential_offsetX",
        name = "X Offset",
        default = 0,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_stackAnchorEssential_offsetX or 0
        end,
        set = function(value)
            local v = math.floor((value or 0) + 0.5)
            ns.db.profile.cooldownManager_stackAnchorEssential_offsetX = v
            ns.Stacks:ApplyStackFonts("EssentialCooldownViewer")
        end,
    })
    SettingsLib:CreateSlider(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorEssential_offsetY",
        name = "Y Offset",
        default = 0,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_stackAnchorEssential_offsetY or 0
        end,
        set = function(value)
            local v = math.floor((value or 0) + 0.5)
            ns.db.profile.cooldownManager_stackAnchorEssential_offsetY = v
            ns.Stacks:ApplyStackFonts("EssentialCooldownViewer")
        end,
    })

    SettingsLib:CreateHeader(category, {
        parentSection = stackNumberSection,
        name = "Stacks Number on Utility Cooldowns Icons",
    })
    SettingsLib:CreateCheckboxDropdown(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorUtility_enabled",
        dropdownKey = "cooldownManager_stackAnchorUtility_point",
        name = "Enable & Anchor|cffff0000*|r",
        searchtags = { "Stack", "Count", "Number", "Anchor", "Position", "Utility", "Enable", "Corner" },
        default = false,
        dropdownDefault = "BOTTOMRIGHT",
        get = function()
            return ns.db.profile.cooldownManager_stackAnchorUtility_enabled
        end,
        set = function(value)
            ns.db.profile.cooldownManager_stackAnchorUtility_enabled = value
            if not value then
                ns.API:ShowReloadUIConfirmation()
            end
            ns.Stacks:ApplyStackFonts("UtilityCooldownViewer")
        end,
        dropdownGet = function()
            return ns.db.profile.cooldownManager_stackAnchorUtility_point or "BOTTOMRIGHT"
        end,
        dropdownSet = function(value)
            ns.db.profile.cooldownManager_stackAnchorUtility_point = value
            ns.Stacks:ApplyStackFonts("UtilityCooldownViewer")
        end,
        dropdownValues = anchorPointValues,
        dropdownOrder = anchorPointOrder,
        desc = "Enable and select anchor point for Utility cooldown stack count position.",
    })

    CreateStackFontSizeDropdown(stackNumberSection, "cooldownManager_stackFontSizeUtility", "Font Size", function()
        return ns.db.profile.cooldownManager_stackFontSizeUtility ~= nil
                and tostring(ns.db.profile.cooldownManager_stackFontSizeUtility)
            or "NIL"
    end, function(value)
        if value == "NIL" then
            ns.db.profile.cooldownManager_stackFontSizeUtility = nil
            ns.API:ShowReloadUIConfirmation()
        else
            local n = tonumber(value)
            ns.db.profile.cooldownManager_stackFontSizeUtility = n and math.floor(n + 0.5) or nil
        end
        ns.Stacks:ApplyStackFonts("UtilityCooldownViewer")
    end)
    SettingsLib:CreateSlider(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorUtility_offsetX",
        name = "X Offset",
        default = 0,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_stackAnchorUtility_offsetX or 0
        end,
        set = function(value)
            local v = math.floor((value or 0) + 0.5)
            ns.db.profile.cooldownManager_stackAnchorUtility_offsetX = v
            ns.Stacks:ApplyStackFonts("UtilityCooldownViewer")
        end,
    })
    SettingsLib:CreateSlider(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorUtility_offsetY",
        name = "Y Offset",
        default = 0,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_stackAnchorUtility_offsetY or 0
        end,
        set = function(value)
            local v = math.floor((value or 0) + 0.5)
            ns.db.profile.cooldownManager_stackAnchorUtility_offsetY = v
            ns.Stacks:ApplyStackFonts("UtilityCooldownViewer")
        end,
    })

    local keybindsSection = SettingsLib:CreateExpandableSection(category, {
        name = "|cffeeeeeeKeybind|r Text Display",
        expanded = false,
        colorizeTitle = true,
    })

    SettingsLib:CreateText(category, {
        name = "Display keybind text on cooldown icons.",
        parentSection = keybindsSection,
    })

    SettingsLib:CreateScrollDropdown(category, {
        parentSection = keybindsSection,
        prefix = "CMC_",
        key = "cooldownManager_keybindFontName",
        name = "Font",
        searchtags = { "Font", "Text", "Keybind", "Hotkey", "Binding", "Typeface", "Typography", "SharedMedia" },
        default = "Friz Quadrata TT",
        height = 220,
        get = function()
            return ns.db.profile.cooldownManager_keybindFontName or "Friz Quadrata TT"
        end,
        set = function(value)
            ns.db.profile.cooldownManager_keybindFontName = value
            ns.Keybinds:OnSettingChanged()
        end,
        desc = "Select the font for ability keybind text. Uses SharedMedia fonts if available.",
        generator = function(dropdown, rootDescription)
            dropdown.fontPool = {}
            if not dropdown._CMC_FontFace_Dropdown_OnMenuClosed_hooked then
                hooksecurefunc(dropdown, "OnMenuClosed", function()
                    for _, fontDisplay in pairs(dropdown.fontPool) do
                        fontDisplay:Hide()
                    end
                end)
                dropdown._CMC_FontFace_Dropdown_OnMenuClosed_hooked = true
            end
            local fonts = LSM:HashTable(LSM.MediaType.FONT)
            local sortedFonts = {}
            for fontName in pairs(fonts) do
                if fontName ~= "" then
                    table.insert(sortedFonts, fontName)
                end
            end
            table.sort(sortedFonts)

            for index, fontName in ipairs(sortedFonts) do
                local fontPath = fonts[fontName]

                local button = rootDescription:CreateRadio(fontName, function()
                    return ns.db.profile.cooldownManager_keybindFontName == fontName
                end, function()
                    ns.db.profile.cooldownManager_keybindFontName = fontName
                    ns.Keybinds:OnSettingChanged()
                    dropdown:SetText(fontName)
                end)

                button:AddInitializer(function(self)
                    local fontDisplay = dropdown.fontPool[index]
                    if not fontDisplay then
                        fontDisplay = dropdown:CreateFontString(nil, "BACKGROUND")
                        dropdown.fontPool[index] = fontDisplay
                    end

                    self.fontString:Hide()

                    fontDisplay:SetParent(self)
                    fontDisplay:SetPoint("LEFT", self.fontString, "LEFT", 0, 0)
                    fontDisplay:SetFont(fontPath, 12)
                    fontDisplay:SetText(fontName)
                    fontDisplay:Show()
                end)
            end
        end,
    })

    SettingsLib:CreateMultiDropdown(category, {
        parentSection = keybindsSection,
        prefix = "CMC_",
        key = "cooldownManager_keybindFontFlags",
        name = "Font Flags",
        customText = "No Flags",
        searchtags = { "Font", "Flags", "Outline", "Shadow", "Thick", "Monochrome", "Keybind", "Style" },
        defaultSelection = {},
        values = {
            ["OUTLINE"] = "Outline",
            ["THICKOUTLINE"] = "Thick Outline",
            ["MONOCHROME"] = "Monochrome",
        },
        getSelection = function()
            return ns.db.profile.cooldownManager_keybindFontFlags or {}
        end,
        setSelection = function(value)
            ns.db.profile.cooldownManager_keybindFontFlags = value
            ns.Keybinds:OnSettingChanged()
        end,
        desc = "Select font flags for ability keybind text.",
    })
    SettingsLib:CreateText(category, {
        name = "",
        parentSection = keybindsSection,
    })
    -- Keybind font size options (no "Don't change" option)
    local keybindFontSizeValues = {
        ["6"] = "6",
        ["8"] = "8",
        ["10"] = "10",
        ["12"] = "12",
        ["14"] = "14",
        ["16"] = "16",
        ["18"] = "18",
        ["20"] = "20",
        ["22"] = "22",
        ["24"] = "24",
        ["26"] = "26",
        ["28"] = "28",
        ["30"] = "30",
        ["32"] = "32",
    }
    local keybindFontSizeOrder = {
        "6",
        "8",
        "10",
        "12",
        "14",
        "16",
        "18",
        "20",
        "22",
        "24",
        "26",
        "28",
        "30",
        "32",
    }

    local function CreateKeybindFontSizeDropdown(parentSection, key, name, getFn, setFn)
        SettingsLib:CreateDropdown(category, {
            parentSection = parentSection,
            prefix = "CMC_",
            key = key,
            name = name,
            default = "14",
            values = keybindFontSizeValues,
            order = keybindFontSizeOrder,
            get = getFn,
            set = setFn,
        })
    end

    -- Keybind Anchor
    SettingsLib:CreateCheckboxDropdown(category, {
        parentSection = keybindsSection,
        prefix = "CMC_",
        key = "cooldownManager_showKeybinds_Essential",
        dropdownKey = "cooldownManager_keybindAnchor_Essential",
        name = "Essential Enable & Anchor",
        searchtags = { "Keybind", "Hotkey", "Binding", "Key", "Shortcut", "Essential", "Show", "Display", "Anchor" },
        default = false,
        dropdownDefault = "TOPRIGHT",
        get = function()
            return ns.db.profile.cooldownManager_showKeybinds_Essential
        end,
        set = function(value)
            ns.db.profile.cooldownManager_showKeybinds_Essential = value
            if ns.Keybinds then
                ns.Keybinds:OnSettingChanged("Essential")
            end
        end,
        dropdownGet = function()
            return ns.db.profile.cooldownManager_keybindAnchor_Essential or "TOPRIGHT"
        end,
        dropdownSet = function(value)
            ns.db.profile.cooldownManager_keybindAnchor_Essential = value
            if ns.Keybinds then
                ns.Keybinds:ApplyKeybindSettings("EssentialCooldownViewer")
            end
        end,
        dropdownValues = {
            TOPLEFT = "Top Left",
            TOP = "Top",
            TOPRIGHT = "Top Right",
            LEFT = "Left",
            CENTER = "Center",
            RIGHT = "Right",
            BOTTOMLEFT = "Bottom Left",
            BOTTOM = "Bottom",
            BOTTOMRIGHT = "Bottom Right",
        },
        dropdownOrder = {
            "TOPLEFT",
            "TOP",
            "TOPRIGHT",
            "LEFT",
            "CENTER",
            "RIGHT",
            "BOTTOMLEFT",
            "BOTTOM",
            "BOTTOMRIGHT",
        },
        desc = "Enable keybind text on Essential Cooldowns and select anchor position.",
    })

    CreateKeybindFontSizeDropdown(keybindsSection, "cooldownManager_keybindFontSize_Essential", "Font Size", function()
        return tostring(ns.db.profile.cooldownManager_keybindFontSize_Essential or 14)
    end, function(value)
        local n = tonumber(value)
        ns.db.profile.cooldownManager_keybindFontSize_Essential = n and math.floor(n + 0.5) or 14
        if ns.Keybinds then
            ns.Keybinds:ApplyKeybindSettings("EssentialCooldownViewer")
        end
    end)

    -- Keybind X Offset
    SettingsLib:CreateSlider(category, {
        parentSection = keybindsSection,
        prefix = "CMC_",
        key = "cooldownManager_keybindOffsetX_Essential",
        name = "X Offset",
        default = -3,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_keybindOffsetX_Essential or -3
        end,
        set = function(value)
            local v = math.floor((value or 0) + 0.5)
            ns.db.profile.cooldownManager_keybindOffsetX_Essential = v
            if ns.Keybinds then
                ns.Keybinds:ApplyKeybindSettings("EssentialCooldownViewer")
            end
        end,
    })

    -- Keybind Y Offset
    SettingsLib:CreateSlider(category, {
        parentSection = keybindsSection,
        prefix = "CMC_",
        key = "cooldownManager_keybindOffsetY_Essential",
        name = "Y Offset",
        default = -3,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_keybindOffsetY_Essential or -3
        end,
        set = function(value)
            local v = math.floor((value or 0) + 0.5)
            ns.db.profile.cooldownManager_keybindOffsetY_Essential = v
            if ns.Keybinds then
                ns.Keybinds:ApplyKeybindSettings("EssentialCooldownViewer")
            end
        end,
    })
    SettingsLib:CreateText(category, {
        name = "",
        parentSection = keybindsSection,
    })

    SettingsLib:CreateCheckboxDropdown(category, {
        parentSection = keybindsSection,
        prefix = "CMC_",
        key = "cooldownManager_showKeybinds_Utility",
        dropdownKey = "cooldownManager_keybindAnchor_Utility",
        name = "Utility: Enable & Anchor",
        searchtags = { "Keybind", "Hotkey", "Binding", "Key", "Shortcut", "Utility", "Show", "Display", "Anchor" },
        default = false,
        dropdownDefault = "TOPRIGHT",
        get = function()
            return ns.db.profile.cooldownManager_showKeybinds_Utility
        end,
        set = function(value)
            ns.db.profile.cooldownManager_showKeybinds_Utility = value
            if ns.Keybinds then
                ns.Keybinds:OnSettingChanged("UtilityCooldownViewer")
            end
        end,
        dropdownGet = function()
            return ns.db.profile.cooldownManager_keybindAnchor_Utility or "TOPRIGHT"
        end,
        dropdownSet = function(value)
            ns.db.profile.cooldownManager_keybindAnchor_Utility = value
            if ns.Keybinds then
                ns.Keybinds:ApplyKeybindSettings("UtilityCooldownViewer")
            end
        end,
        dropdownValues = {
            TOPLEFT = "Top Left",
            TOP = "Top",
            TOPRIGHT = "Top Right",
            LEFT = "Left",
            CENTER = "Center",
            RIGHT = "Right",
            BOTTOMLEFT = "Bottom Left",
            BOTTOM = "Bottom",
            BOTTOMRIGHT = "Bottom Right",
        },
        dropdownOrder = {
            "TOPLEFT",
            "TOP",
            "TOPRIGHT",
            "LEFT",
            "CENTER",
            "RIGHT",
            "BOTTOMLEFT",
            "BOTTOM",
            "BOTTOMRIGHT",
        },
        desc = "Enable keybind text on Utility Cooldowns and select anchor position.",
    })

    CreateKeybindFontSizeDropdown(keybindsSection, "cooldownManager_keybindFontSize_Utility", "Font Size", function()
        return tostring(ns.db.profile.cooldownManager_keybindFontSize_Utility or 10)
    end, function(value)
        local n = tonumber(value)
        ns.db.profile.cooldownManager_keybindFontSize_Utility = n and math.floor(n + 0.5) or 14
        if ns.Keybinds then
            ns.Keybinds:ApplyKeybindSettings("UtilityCooldownViewer")
        end
    end)
    SettingsLib:CreateSlider(category, {
        parentSection = keybindsSection,
        prefix = "CMC_",
        key = "cooldownManager_keybindOffsetX_Utility",
        name = "X Offset",
        default = -3,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_keybindOffsetX_Utility or -3
        end,
        set = function(value)
            local v = math.floor((value or 0) + 0.5)
            ns.db.profile.cooldownManager_keybindOffsetX_Utility = v
            if ns.Keybinds then
                ns.Keybinds:ApplyKeybindSettings("UtilityCooldownViewer")
            end
        end,
    })
    SettingsLib:CreateSlider(category, {
        parentSection = keybindsSection,
        prefix = "CMC_",
        key = "cooldownManager_keybindOffsetY_Utility",
        name = "Y Offset",
        default = -3,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.cooldownManager_keybindOffsetY_Utility or -3
        end,
        set = function(value)
            local v = math.floor((value or 0) + 0.5)
            ns.db.profile.cooldownManager_keybindOffsetY_Utility = v
            if ns.Keybinds then
                ns.Keybinds:ApplyKeybindSettings("UtilityCooldownViewer")
            end
        end,
    })

    local tweaksHeader = SettingsLib:CreateHeader(category, {
        name = "|cff008945Wildu|r|cff8ccd00Tweaks|r for Cooldown Manager",
        searchtags = {
            "Wildu",
            "Tweaks",
            "Cooldown",
            "Manager",
            "CMC",
            "CDM",
            "Assistant",
            "Assisted",
            "Highlight",
            "Rotation",
            "Suggested",
            "Border",
            "Glow",
            "Sync Utility width to Essential",
            "Fix",
            "Normalize",
            "Size",
            "Uniform",
            "Match",
            "Equal",
            "Same",
            "Utility",
            "Icon",
        },
    })

    SettingsLib:CreateCheckbox(category, {
        prefix = "CMC_",
        key = "cooldownManager_showHighlight_Essential",
        name = "Rotation Highlight on CDM",
        searchtags = { "Assistant", "Assisted", "Highlight", "Rotation", "Suggested", "Border", "Glow" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_showHighlight_Essential
                and ns.db.profile.cooldownManager_showHighlight_Utility
        end,
        set = function(value)
            ns.db.profile.cooldownManager_showHighlight_Essential = value
            ns.db.profile.cooldownManager_showHighlight_Utility = value
            if value then
                C_CVar.SetCVar("assistedCombatHighlight", "1")
            end
            if ns.Assistant then
                ns.Assistant:OnSettingChanged("Essential")
                ns.Assistant:OnSettingChanged("Utility")
            end
        end,
        desc = "Show blue border on Cooldown Manager when ability is suggested by the rotation helper.",
    })
    SettingsLib:CreateCheckboxDropdown(category, {
        prefix = "CMC_",
        key = "cooldownManager_buttonPress",
        name = "Button Press overlay",
        searchtags = { "Button", "Press", "Overlay", "Experimental", "Cooldowns", "Icons" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_buttonPress
        end,
        set = function(value)
            ns.db.profile.cooldownManager_buttonPress = value
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "Show an overlay on cooldown icons when the corresponding action button is pressed.",

        dropdownKey = "cooldownManager_buttonPress_texture",
        dropdownName = "Button Press Texture",
        dropdownValues = {
            Blizzard = "Blizzard Default",
            Flat = "Simple Flat Overlay",
        },
        dropdownDefault = "Blizzard",
        dropdownGet = function()
            return ns.db.profile.cooldownManager_buttonPress_texture or "Blizzard"
        end,
        dropdownSet = function(value)
            ns.db.profile.cooldownManager_buttonPress_texture = value
            ns.API:ShowReloadUIConfirmation()
        end,
        dropdownDesc = "Select the texture for the button press overlay.",
        dropdownOrder = {
            "Blizzard",
            "Flat",
        },
    })

    SettingsLib:CreateCheckbox(category, {
        prefix = "CMC_",
        key = "cooldownManager_limitUtilitySizeToEssential",
        name = "Sync Utility width to Essential",
        searchtags = { "Sync", "Width", "Size", "Match", "Limit", "Utility", "Essential", "Constrain" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_limitUtilitySizeToEssential
        end,
        set = function(value)
            ns.db.profile.cooldownManager_limitUtilitySizeToEssential = value
            ns.CooldownManager.ForceRefreshAll()
        end,
        desc = "Set |cffff0000maximum|r Utility width to the width of Essential\n|cffff0000It will not get narrower than 6 icons or limit you set in |r|cff87bbcaEdit Mode|r",
    })
    local version = C_AddOns.GetAddOnMetadata("CooldownManagerCentered", "version")
    SettingsLib:CreateText(category, {
        name = "|cffccccccAddon version: " .. version .. "|r",
    })

    local experimentalCategory = SettingsLib:CreateCategory(category, "Experimental", false)

    SettingsLib:CreateHeader(experimentalCategory, {
        name = "|cffff0000Experimental Features|r",
        searchtags = { "Experimental", "Beta", "Testing", "Feature", "Features" },
    })

    SettingsLib:CreateCheckbox(experimentalCategory, {
        prefix = "CMC_",
        key = "cooldownManager_experimental_enableRectangularIcons",
        name = "Rectangular Icons",
        searchtags = { "Rectangular", "Icons", "Experimental", "Rectangle", "Wide", "Aspect Ratio" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_experimental_enableRectangularIcons
        end,
        set = function(value)
            ns.db.profile.cooldownManager_experimental_enableRectangularIcons = value
            ns.StyledIcons:OnSettingChanged()
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "Enable rectangular icons for Cooldown Manager viewers. |cffff0000Experimental feature, may cause issues!|r",
    })
    SettingsLib:CreateText(experimentalCategory, {
        name = 'Rectangular icons - require "Square styling" to be enabled - not configurable yet',
    })

    SettingsLib:CreateCheckbox(experimentalCategory, {
        prefix = "CMC_",
        key = "cooldownManager_experimental_hideAuras",
        name = "Hide Auras",
        searchtags = { "Hide", "Auras", "Experimental", "Cooldowns", "Buffs", "Debuffs" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_experimental_hideAuras
        end,
        set = function(value)
            ns.db.profile.cooldownManager_experimental_hideAuras = value
        end,
        desc = "Hide auras on icons, always show only cooldowns of the abilities. |cffff0000Experimental feature, may cause issues!|r",
    })
    SettingsLib:CreateText(experimentalCategory, {
        name = "Hide auras, always show only cooldowns of the abilites",
    })

    SettingsLib:CreateCheckbox(experimentalCategory, {
        prefix = "CMC_",
        key = "cooldownManager_experimental_trinketRacialTracker",
        name = "Trinket, Potion & Racial Tracker",
        searchtags = { "Trinket", "Racial", "Tracker", "Experimental", "Cooldowns", "Icons", "Potion", "Healthstone" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_experimental_trinketRacialTracker
        end,
        set = function(value)
            ns.db.profile.cooldownManager_experimental_trinketRacialTracker = value
            if ns.TrinketRacialTracker then
                ns.TrinketRacialTracker:OnSettingChanged()
            end
        end,
        desc = "Show a separate tracking bar for trinkets, potions, healthstones, and racial abilities. |cffff0000Experimental feature, may cause issues!|r",
    })
    SettingsLib:CreateText(experimentalCategory, {
        name = "Track cooldowns for trinkets, potions, healthstones, and racial abilities in a movable bar",
    })

    local trackerStyleSection = SettingsLib:CreateExpandableSection(experimentalCategory, {
        name = "|cffeeeeeeTrinket Tracker|r Styling",
        expanded = false,
        colorizeTitle = true,
    })

    local function BuildRacialsOptions()
        local options = {}
        local spellNameToIds = {}

        for _, spellId in ipairs(ns.TrinketRacialTracker.RACIALS) do
            local spellInfo = C_Spell.GetSpellInfo(spellId)
            if spellInfo and spellInfo.name then
                if not spellNameToIds[spellInfo.name] then
                    spellNameToIds[spellInfo.name] = {
                        ids = {},
                        icon = spellInfo.iconID,
                    }
                end
                table.insert(spellNameToIds[spellInfo.name].ids, spellId)
            end
        end

        local sortedNames = {}
        for name in pairs(spellNameToIds) do
            table.insert(sortedNames, name)
        end
        table.sort(sortedNames)

        for _, name in ipairs(sortedNames) do
            local data = spellNameToIds[name]
            local iconText = "|T" .. (data.icon or "Interface\\Icons\\INV_Misc_QuestionMark") .. ":16:16:0:0|t "
            table.insert(options, {
                value = name,
                text = iconText .. name,
                label = iconText .. name,
            })
        end

        return options
    end

    SettingsLib:CreateMultiDropdown(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_ignoredRacials",
        name = "Ignored Racials",
        customText = "All Racials shown",
        searchtags = { "Trinket", "Racial", "Tracker", "Ignore", "Hide", "Filter" },
        defaultSelection = {},
        optionfunc = BuildRacialsOptions,
        getSelection = function()
            return ns.db.profile.trinketRacialTracker_ignoredRacials or {}
        end,
        setSelection = function(value)
            ns.db.profile.trinketRacialTracker_ignoredRacials = value
            if ns.TrinketRacialTracker then
                ns.TrinketRacialTracker:RefreshAll()
            end
        end,
        summary = function(selectionMap, selectedLabels)
            if #selectedLabels == 0 then
                return ""
            end
            return "Ignoring " .. #selectedLabels .. " Racial" .. (#selectedLabels > 1 and "s" or "")
        end,
        desc = "Select racial abilities to hide from the tracker. Multiple spell IDs with the same name will all be hidden.",
    })

    local function BuildItemsOptions()
        local options = {}
        local itemNameToIds = {}

        for _, itemId in ipairs(ns.TrinketRacialTracker.ITEMS) do
            local itemName = C_Item.GetItemNameByID(itemId)
            local itemIcon = C_Item.GetItemIconByID(itemId)
            local itemQuality = C_Item.GetItemQualityByID(itemId)

            if itemName then
                if not itemNameToIds[itemName] then
                    itemNameToIds[itemName] = {
                        ids = {},
                        icon = itemIcon,
                        quality = itemQuality,
                    }
                end
                table.insert(itemNameToIds[itemName].ids, itemId)
            end
        end

        local sortedNames = {}
        for name in pairs(itemNameToIds) do
            table.insert(sortedNames, name)
        end
        table.sort(sortedNames)

        for _, name in ipairs(sortedNames) do
            local data = itemNameToIds[name]
            local iconText = "|T" .. (data.icon or "Interface\\Icons\\INV_Misc_QuestionMark") .. ":16:16:0:0|t "
            table.insert(options, {
                value = name,
                text = iconText .. name,
                label = iconText .. name,
            })
        end

        return options
    end

    SettingsLib:CreateMultiDropdown(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_ignoredItems",
        name = "Ignored Items",
        searchtags = { "Trinket", "Item", "Potion", "Tracker", "Ignore", "Hide", "Filter", "Healthstone" },
        defaultSelection = {},
        optionfunc = BuildItemsOptions,
        getSelection = function()
            return ns.db.profile.trinketRacialTracker_ignoredItems or {}
        end,
        setSelection = function(value)
            ns.db.profile.trinketRacialTracker_ignoredItems = value
            if ns.TrinketRacialTracker then
                ns.TrinketRacialTracker:RefreshAll()
            end
        end,
        customText = "All Items shown",
        summary = function(selectionMap, selectedLabels)
            if #selectedLabels == 0 then
                return ""
            end
            return "Ignoring " .. #selectedLabels .. " Item" .. (#selectedLabels > 1 and "s" or "")
        end,
        desc = "Select items (potions, healthstones) to hide from the tracker.",
    })

    SettingsLib:CreateCheckbox(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_squareIcons",
        name = "Square Icons",
        searchtags = { "Trinket", "Racial", "Tracker", "Square", "Icons", "Style" },
        default = false,
        get = function()
            return ns.db.profile.trinketRacialTracker_squareIcons
        end,
        set = function(value)
            ns.db.profile.trinketRacialTracker_squareIcons = value
            if ns.TrinketRacialTracker then
                ns.TrinketRacialTracker:RefreshStyling()
            end
        end,
        desc = "Apply square icon styling to the Trinket, Potion & Racial Tracker. When disabled, the default cooldown manager mask (texture 6707800) is used.",
    })

    SettingsLib:CreateSlider(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_borderThickness",
        name = "Border Thickness",
        searchtags = { "Trinket", "Racial", "Tracker", "Border", "Thickness", "Width" },
        default = 1,
        min = 0,
        max = 6,
        step = 1,
        formatter = function(value)
            return string.format("%.0fpx", value)
        end,
        get = function()
            return ns.db.profile.trinketRacialTracker_borderThickness or 1
        end,
        set = function(value)
            ns.db.profile.trinketRacialTracker_borderThickness = value
            if ns.TrinketRacialTracker then
                ns.TrinketRacialTracker:RefreshStyling()
            end
        end,
        desc = "Border thickness for tracker icons (space between icon edge and texture).",
    })

    SettingsLib:CreateSlider(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_iconZoom",
        name = "Icon Zoom",
        searchtags = { "Trinket", "Racial", "Tracker", "Zoom", "Scale", "Crop" },
        default = 0.3,
        min = 0,
        max = 0.5,
        step = 0.01,
        formatter = function(value)
            return string.format("%.2f", value)
        end,
        get = function()
            return ns.db.profile.trinketRacialTracker_iconZoom or 0.3
        end,
        set = function(value)
            ns.db.profile.trinketRacialTracker_iconZoom = value
            if ns.TrinketRacialTracker then
                ns.TrinketRacialTracker:RefreshStyling()
            end
        end,
        desc = "Zoom level for tracker icons (0 = no zoom, 0.5 = maximum zoom).",
    })

    SettingsLib:CreateHeader(experimentalCategory, {
        parentSection = trackerStyleSection,
        name = "Stack/Count Number",
    })

    local anchorPointValues = {
        TOPLEFT = "Top Left",
        TOP = "Top",
        TOPRIGHT = "Top Right",
        LEFT = "Left",
        CENTER = "Center",
        RIGHT = "Right",
        BOTTOMLEFT = "Bottom Left",
        BOTTOM = "Bottom",
        BOTTOMRIGHT = "Bottom Right",
    }
    local anchorPointOrder = {
        "TOPLEFT",
        "TOP",
        "TOPRIGHT",
        "LEFT",
        "CENTER",
        "RIGHT",
        "BOTTOMLEFT",
        "BOTTOM",
        "BOTTOMRIGHT",
    }

    SettingsLib:CreateDropdown(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_stackAnchor",
        name = "Stack Anchor",
        searchtags = { "Trinket", "Racial", "Tracker", "Stack", "Anchor", "Position", "Count" },
        default = "BOTTOMRIGHT",
        values = anchorPointValues,
        order = anchorPointOrder,
        get = function()
            return ns.db.profile.trinketRacialTracker_stackAnchor or "BOTTOMRIGHT"
        end,
        set = function(value)
            ns.db.profile.trinketRacialTracker_stackAnchor = value
            if ns.TrinketRacialTracker then
                ns.TrinketRacialTracker:RefreshStyling()
            end
        end,
        desc = "Anchor point for stack/count number position on tracker icons.",
    })

    SettingsLib:CreateSlider(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_stackFontSize",
        name = "Stack Font Size",
        searchtags = { "Trinket", "Racial", "Tracker", "Stack", "Font", "Size", "Count" },
        default = 14,
        min = 8,
        max = 32,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.trinketRacialTracker_stackFontSize or 14
        end,
        set = function(value)
            ns.db.profile.trinketRacialTracker_stackFontSize = value
            if ns.TrinketRacialTracker then
                ns.TrinketRacialTracker:RefreshStyling()
            end
        end,
        desc = "Font size for stack/count numbers on tracker icons.",
    })

    SettingsLib:CreateSlider(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_stackOffsetX",
        name = "X Offset",
        searchtags = { "Trinket", "Racial", "Tracker", "Stack", "Offset", "X", "Horizontal" },
        default = -1,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.trinketRacialTracker_stackOffsetX or -1
        end,
        set = function(value)
            ns.db.profile.trinketRacialTracker_stackOffsetX = value
            if ns.TrinketRacialTracker then
                ns.TrinketRacialTracker:RefreshStyling()
            end
        end,
        desc = "Horizontal offset for stack/count number position.",
    })

    SettingsLib:CreateSlider(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_stackOffsetY",
        name = "Y Offset",
        searchtags = { "Trinket", "Racial", "Tracker", "Stack", "Offset", "Y", "Vertical" },
        default = 1,
        min = -40,
        max = 40,
        step = 1,
        formatter = function(value)
            return string.format("%.0f", value)
        end,
        get = function()
            return ns.db.profile.trinketRacialTracker_stackOffsetY or 1
        end,
        set = function(value)
            ns.db.profile.trinketRacialTracker_stackOffsetY = value
            if ns.TrinketRacialTracker then
                ns.TrinketRacialTracker:RefreshStyling()
            end
        end,
        desc = "Vertical offset for stack/count number position.",
    })

    SettingsLib:CreateText(experimentalCategory, {
        parentSection = trackerStyleSection,
        name = "Note: Stack font name and flags are taken from the global Stack Font settings.",
    })
end

-- Initialize the settings UI (called from main addon after DB is ready)
function WilduSettings:RegisterSettings()
    local category, layout = Settings.RegisterVerticalLayoutCategory(
        "Co|cffbcc71fo|r|cff52a855ld|r|cff3faa4fownM|r|cff5fb64aan|r|cff7ac243ag|r|cff8ccd00erCentered|r"
    )
    Settings.RegisterAddOnCategory(category)
    ns.WilduSettings.SettingsLayout.rootCategory = category
    ns.WilduSettings.SettingsLayout.rootLayout = layout
end

local isInitialized = false
function WilduSettings:InitializeSettings()
    if isInitialized then
        return
    end
    isInitialized = true

    WilduSettings_BuildCooldown(
        ns.WilduSettings.SettingsLayout.rootCategory,
        ns.WilduSettings.SettingsLayout.rootLayout
    )

    ns.ProfileSettings:BuildSettings(ns.WilduSettings.SettingsLayout.rootCategory)
end
