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
        name = "設定延伸方式與起始位置",
    })
    SettingsLib:CreateText(category, {
        name = "圖示與計量條的動態對齊發生在檢視器容器內。\n在|cff87bbca編輯模式|r中使用對齊網格可獲得最佳效果。",
    })
    SettingsLib:CreateDropdown(category, {
        prefix = "CMC_",
        key = "cooldownManager_alignBuffIcons_growFromDirection",
        name = "追蹤的增益圖示|cffff0000*|r",
        searchtags = { "延伸", "方向", "對齊", "位置", "版面配置", "對齊點", "左", "右", "中", "Grow", "Direction", "Alignment", "Position", "Layout", "Anchor", "Left", "Right", "Center" },
        default = "CENTER",

        optionfunc = function()
            return {
                ["START"] = BuffIconCooldownViewer.isHorizontal and "從|cff8ccd00起始處|r延伸"
                    or "從|cff8ccd00起始處|r延伸",
                ["CENTER"] = "從|cff8ccd00中間|r延伸",
                ["END"] = BuffIconCooldownViewer.isHorizontal and "從|cff8ccd00結尾處|r延伸"
                    or "從|cff8ccd00結尾處|r延伸",
                ["Disable"] = "|cff7c7c7c停用動態版面配置|r",
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
        name = "追蹤的計量條",
        searchtags = {
            "延伸",
            "方向",
            "對齊",
            "位置",
            "版面配置",
            "對齊點",
            "上",
            "下",
            "增益",
            "條",
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
            BOTTOM = "計量條從|cff8ccd00下方|r延伸",
            TOP = "計量條從|cff8ccd00上方|r延伸",
            ["Disable"] = "|cff7c7c7c停用動態版面配置|r",
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
        name = "關鍵圖示|cffff0000*|r",
        searchtags = { "延伸", "方向", "對齊", "位置", "版面配置", "對齊點", "行", "列", "關鍵", "Grow", "Direction", "Alignment", "Position", "Layout", "Anchor", "Row", "Column", "Essential" },
        default = "TOP",
        optionfunc = function()
            return {
                BOTTOM = EssentialCooldownViewer.isHorizontal and "新行位於|cff8ccd00上方|r"
                    or "新列向|cff8ccd00左|r延伸",
                TOP = EssentialCooldownViewer.isHorizontal and "新行位於|cff8ccd00下方|r"
                    or "新列向|cff8ccd00右|r延伸",
                ["Disable"] = "|cff7c7c7c停用動態版面配置|r",
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
        name = "輔助圖示|cffff0000*|r",
        searchtags = { "延伸", "方向", "對齊", "位置", "版面配置", "對齊點", "行", "列", "輔助", "Grow", "Direction", "Alignment", "Position", "Layout", "Anchor", "Row", "Column", "Utility" },
        default = "TOP",
        optionfunc = function()
            return {
                BOTTOM = UtilityCooldownViewer.isHorizontal and "新行位於|cff8ccd00上方|r"
                    or "新列向|cff8ccd00左|r延伸",
                TOP = UtilityCooldownViewer.isHorizontal and "新行位於|cff8ccd00下方|r"
                    or "新列向|cff8ccd00右|r延伸",
                ["Disable"] = "|cff7c7c7c停用動態版面配置|r",
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
        name = "不在冷卻中時調暗輔助技能",
        searchtags = { "調暗", "不透明度", "淡出", "透明", "輔助", "冷卻", "隱藏", "圖示", "Dim", "Opacity", "Faded", "Transparent", "Utility", "Cooldown", "Hide", "Icons" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_utility_dimWhenNotOnCD
        end,
        set = function(value)
            ns.db.profile.cooldownManager_utility_dimWhenNotOnCD = value
            ns.CooldownManager.ForceRefresh({ utility = true })
        end,
        desc = "當輔助技能不在冷卻中時，調暗其圖示。",

        sliderKey = "cooldownManager_utility_dimOpacity",
        sliderName = "調暗不透明度",
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
        name = "|cffff0000*|r若要變更|cfffff100間距|r或在|cfffff100列 / 行|r之間切換\n請前往|cff87bbca編輯模式|r並變更|cfffff100圖示間距與方向|r。",
    })

    SettingsLib:CreateButton(category, {
        text = "開啟編輯模式",
        func = function()
            ns.API:ToggleEditMode()
        end,
        parentSection = cooldownSection,
    })
    SettingsLib:CreateButton(category, {
        text = "開啟冷卻設定",
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
        name = "您可以輸入 |cfffff100/cds|r 或 |cfffff100/cdm|r 前往 |cfffff100冷卻設定|r",
    })

    local squareIconsSection = SettingsLib:CreateExpandableSection(category, {
        name = "|cff5fb64a圖|r|cff8ccd00示|r樣式",
        expanded = false,
        colorizeTitle = true,
    })
    SettingsLib:CreateText(category, {
        name = "|cfffff100間距|r無法再於插件內設定，請使用|cff87bbca編輯模式|r",
        parentSection = squareIconsSection,
    })

    SettingsLib:CreateCheckbox(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIcons_BuffIcons",
        name = "方形增益圖示",
        searchtags = { "方形", "形狀", "樣式", "矩形", "扁平", "現代", "增益", "圖示", "材質", "Square", "Shape", "Style", "Rectangular", "Flat", "Modern", "Buff", "Icon", "Texture" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_squareIcons_BuffIcons
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIcons_BuffIcons = value
            ns.StyledIcons:OnSettingChanged()
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "將方形圖示樣式套用到增益圖示檢視器。",
    })
    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsBorder_BuffIcons",
        name = "邊框粗細",
        searchtags = { "邊框", "粗細", "寬度", "邊緣", "框架", "輪廓", "增益", "大小", "Border", "Thickness", "Width", "Edge", "Frame", "Outline", "Buff", "Size" },
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
        desc = "方形增益圖示的邊框粗細（圖示邊緣與材質之間的空間）。",
        -- isEnabled = function()
        --     return not ns.API:IsSomeAddOnRestrictionActive()
        -- end,
    })

    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsZoom_BuffIcons",
        name = "縮放",
        searchtags = { "縮放", "比例", "裁切", "放大", "材質", "增益", "圖示", "Zoom", "Scale", "Crop", "Magnify", "Enlarge", "Texture", "Buff", "Icon" },
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
        desc = "方形增益圖示的縮放等級（0 = 無縮放，0.5 = 最大縮放）。",
    })
    SettingsLib:CreateText(category, {
        name = "",
        parentSection = squareIconsSection,
    })

    SettingsLib:CreateCheckbox(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIcons_Essential",
        name = "方形關鍵冷卻",
        searchtags = { "方形", "形狀", "樣式", "矩形", "扁平", "現代", "關鍵", "圖示", "材質", "Square", "Shape", "Style", "Rectangular", "Flat", "Modern", "Essential", "Icon", "Texture" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_squareIcons_Essential
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIcons_Essential = value
            ns.StyledIcons:OnSettingChanged()
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "將方形圖示樣式套用到關鍵冷卻檢視器。",
    })

    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsBorder_Essential",
        name = "邊框粗細",
        searchtags = { "邊框", "粗細", "寬度", "邊緣", "框架", "輪廓", "關鍵", "大小", "Border", "Thickness", "Width", "Edge", "Frame", "Outline", "Essential", "Size" },
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
        desc = "方形關鍵圖示的邊框粗細（圖示邊緣與材質之間的空間）。",
        -- isEnabled = function()
        --     return not ns.API:IsSomeAddOnRestrictionActive()
        -- end,
    })

    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsZoom_Essential",
        name = "圖示縮放",
        searchtags = { "縮放", "比例", "裁切", "放大", "材質", "關鍵", "圖示", "Zoom", "Scale", "Crop", "Magnify", "Enlarge", "Texture", "Essential", "Icon" },
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
        desc = "方形關鍵圖示的縮放等級（0 = 無縮放，0.5 = 最大縮放）。",
    })
    SettingsLib:CreateText(category, {
        name = "",
        parentSection = squareIconsSection,
    })

    SettingsLib:CreateCheckbox(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIcons_Utility",
        name = "方形輔助冷卻",
        searchtags = { "方形", "形狀", "樣式", "矩形", "扁平", "現代", "輔助", "圖示", "材質", "Square", "Shape", "Style", "Rectangular", "Flat", "Modern", "Utility", "Icon", "Texture" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_squareIcons_Utility
        end,
        set = function(value)
            ns.db.profile.cooldownManager_squareIcons_Utility = value
            ns.StyledIcons:OnSettingChanged()
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "將方形圖示樣式套用到輔助冷卻檢視器。",
    })

    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsBorder_Utility",
        name = "邊框粗細",
        searchtags = { "邊框", "粗細", "寬度", "邊緣", "框架", "輪廓", "輔助", "大小", "Border", "Thickness", "Width", "Edge", "Frame", "Outline", "Utility", "Size" },
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
        desc = "方形輔助圖示的邊框粗細（圖示邊緣與材質之間的空間）。",
        -- isEnabled = function()
        --     return not ns.API:IsSomeAddOnRestrictionActive()
        -- end,
    })

    SettingsLib:CreateSlider(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_squareIconsZoom_Utility",
        name = "圖示縮放",
        searchtags = { "縮放", "比例", "裁切", "放大", "材質", "輔助", "圖示", "Zoom", "Scale", "Crop", "Magnify", "Enlarge", "Texture", "Utility", "Icon" },
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
        desc = "方形輔助圖示的縮放等級（0 = 無縮放，0.5 = 最大縮放）。",
    })
    SettingsLib:CreateCheckbox(category, {
        parentSection = squareIconsSection,
        prefix = "CMC_",
        key = "cooldownManager_normalizeUtilitySize",
        name = "統一輔助圖示縮放",
        searchtags = { "修復", "統一", "大小", "一致", "匹配", "相等", "相同", "輔助", "圖示", "Fix", "Normalize", "Size", "Uniform", "Match", "Equal", "Same", "Utility", "Icon" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_normalizeUtilitySize
        end,
        set = function(value)
            ns.db.profile.cooldownManager_normalizeUtilitySize = value
            ns.StyledIcons:OnSettingChanged()
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "將輔助冷卻圖示的|cffff0000基礎|r大小設定為與關鍵冷卻圖示相同\n這有助於在同時使用兩個檢視器時保持外觀更統一。",
    })

    local cooldownSection = SettingsLib:CreateExpandableSection(category, {
        name = "|cffeeeeee冷卻|r設定",
        expanded = false,
        colorizeTitle = true,
    })
    local customSwipeColorCheckbox = SettingsLib:CreateCheckbox(category, {
        prefix = "CMC_",
        key = "cooldownManager_customSwipeColor_enabled",
        name = "啟用自訂覆蓋顏色",
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_customSwipeColor_enabled or false
        end,
        set = function(value)
            ns.db.profile.cooldownManager_customSwipeColor_enabled = value
        end,
        desc = "啟用冷卻轉圈覆蓋圖層的自訂顏色。",
        parentSection = cooldownSection,
    })

    SettingsLib:CreateColorOverrides(category, {
        key = "cooldownManager_customActiveColor",
        entries = {
            { key = "active", label = "作用中光環顏色" },
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
            { key = "active", label = "冷卻轉圈顏色" },
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
        text = "設定預設顏色",
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
        name = "冷卻數字設定",
        parentSection = cooldownSection,
    })

    SettingsLib:CreateScrollDropdown(category, {
        parentSection = cooldownSection,
        prefix = "CMC_",
        key = "cooldownManager_cooldownFontName",
        name = "冷卻字型",
        searchtags = { "字型", "文字", "冷卻", "計數", "數字", "字體", "排版", "SharedMedia", "Font", "Text", "Cooldown", "Count", "Number", "Typeface", "Typography" },
        default = "Friz Quadrata TT",
        height = 220,
        get = function()
            return ns.db.profile.cooldownManager_cooldownFontName or "Friz Quadrata TT"
        end,
        set = function(value)
            ns.db.profile.cooldownManager_cooldownFontName = value
            ns.CooldownFont:RefreshAll()
        end,
        desc = "選擇技能冷卻數字的字型。若可用將使用 SharedMedia 字型。",
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
        name = "文字樣式",
        customText = "無標籤",
        searchtags = { "字型", "標籤", "外框", "陰影", "粗", "單色", "文字", "樣式", "Font", "Flags", "Outline", "Shadow", "Thick", "Monochrome", "Text", "Style" },
        defaultSelection = {},
        values = {
            ["OUTLINE"] = "外框",
            ["THICKOUTLINE"] = "粗外框",
            ["MONOCHROME"] = "單色",
        },
        getSelection = function()
            return ns.db.profile.cooldownManager_cooldownFontFlags or {}
        end,
        setSelection = function(value)
            ns.db.profile.cooldownManager_cooldownFontFlags = value
            ns.CooldownFont:RefreshAll()
        end,
        desc = "選擇技能冷卻數字的文字樣式。",
    })

    local cooldownFontSizeValues = {
        ["NIL"] = "預設",
        ["0"] = "隱藏",
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
        "變更關鍵區塊",
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
        "變更輔助區塊",
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
        "變更追蹤的增益",
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
        name = "技能|cffeeeeee堆疊|r層數設定",
        expanded = false,
        colorizeTitle = true,
    })

    SettingsLib:CreateText(category, {
        name = "|cffff0000*|r部分變更需要|cff00ff00重新載入|r才能恢復預設位置和字型。",
        parentSection = stackNumberSection,
    })

    SettingsLib:CreateScrollDropdown(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackFontName",
        name = "字型",
        searchtags = { "字型", "文字", "堆疊", "計數", "數字", "字體", "排版", "SharedMedia", "Font", "Text", "Stack", "Count", "Number", "Typeface", "Typography" },
        default = "Friz Quadrata TT",
        height = 220,
        get = function()
            return ns.db.profile.cooldownManager_stackFontName or "Friz Quadrata TT"
        end,
        set = function(value)
            ns.db.profile.cooldownManager_stackFontName = value
            ns.Stacks:OnSettingChanged()
        end,
        desc = "選擇技能堆疊層數的字型。若可用將使用 SharedMedia 字型。",
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
        name = "文字樣式",
        customText = "無標籤",
        searchtags = { "字型", "標籤", "外框", "陰影", "粗", "單色", "文字", "樣式", "Font", "Flags", "Outline", "Shadow", "Thick", "Monochrome", "Text", "Style" },
        defaultSelection = {},
        values = {
            ["OUTLINE"] = "外框",
            ["THICKOUTLINE"] = "粗外框",
            ["MONOCHROME"] = "單色",
        },
        getSelection = function()
            return ns.db.profile.cooldownManager_stackFontFlags or {}
        end,
        setSelection = function(value)
            ns.db.profile.cooldownManager_stackFontFlags = value
            ns.Stacks:OnSettingChanged()
        end,
        desc = "選擇技能堆疊層數的文字樣式。",
    })

    local fontSizeValues = {
        ["NIL"] = "不變更",
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
        TOPLEFT = "左上",
        TOP = "上方",
        TOPRIGHT = "右上",
        LEFT = "左側",
        RIGHT = "右側",
        BOTTOMLEFT = "左下",
        BOTTOM = "下方",
        BOTTOMRIGHT = "右下",
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
        name = "追蹤的增益圖示上的堆疊層數",
    })
    SettingsLib:CreateCheckboxDropdown(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorBuffIcons_enabled",
        dropdownKey = "cooldownManager_stackAnchorBuffIcons_point",
        name = "啟用與對齊點|cffff0000*|r",
        searchtags = { "堆疊", "計數", "數字", "對齊點", "位置", "增益", "啟用", "角落", "Stack", "Count", "Number", "Anchor", "Position", "Buff", "Enable", "Corner" },
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
        desc = "啟用並選擇增益圖示堆疊計數位置的對齊點。",
    })

    CreateStackFontSizeDropdown(stackNumberSection, "cooldownManager_stackFontSizeBuffIcons", "文字大小", function()
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
        name = "X 偏移",
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
        name = "Y 偏移",
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
        name = "關鍵冷卻圖示上的堆疊層數",
    })
    SettingsLib:CreateCheckboxDropdown(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorEssential_enabled",
        dropdownKey = "cooldownManager_stackAnchorEssential_point",
        name = "啟用與對齊點|cffff0000*|r",
        searchtags = { "堆疊", "計數", "數字", "對齊點", "位置", "關鍵", "啟用", "角落", "Stack", "Count", "Number", "Anchor", "Position", "Essential", "Enable", "Corner" },
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
        desc = "啟用並選擇關鍵冷卻堆疊計數位置的對齊點。",
    })

    CreateStackFontSizeDropdown(stackNumberSection, "cooldownManager_stackFontSizeEssential", "文字大小", function()
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
        name = "X 偏移",
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
        name = "Y 偏移",
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
        name = "輔助冷卻圖示上的堆疊層數",
    })
    SettingsLib:CreateCheckboxDropdown(category, {
        parentSection = stackNumberSection,
        prefix = "CMC_",
        key = "cooldownManager_stackAnchorUtility_enabled",
        dropdownKey = "cooldownManager_stackAnchorUtility_point",
        name = "啟用與對齊點|cffff0000*|r",
        searchtags = { "堆疊", "計數", "數字", "對齊點", "位置", "輔助", "啟用", "角落", "Stack", "Count", "Number", "Anchor", "Position", "Utility", "Enable", "Corner" },
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
        desc = "啟用並選擇輔助冷卻堆疊計數位置的對齊點。",
    })

    CreateStackFontSizeDropdown(stackNumberSection, "cooldownManager_stackFontSizeUtility", "文字大小", function()
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
        name = "X 偏移",
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
        name = "Y 偏移",
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
        name = "|cffeeeeee快捷鍵|r文字顯示",
        expanded = false,
        colorizeTitle = true,
    })

    SettingsLib:CreateText(category, {
        name = "在冷卻圖示上顯示快捷鍵文字。",
        parentSection = keybindsSection,
    })

    SettingsLib:CreateScrollDropdown(category, {
        parentSection = keybindsSection,
        prefix = "CMC_",
        key = "cooldownManager_keybindFontName",
        name = "字型",
        searchtags = { "字型", "文字", "快捷鍵", "熱鍵", "綁定", "字體", "排版", "SharedMedia", "Font", "Text", "Keybind", "Hotkey", "Binding", "Typeface", "Typography" },
        default = "Friz Quadrata TT",
        height = 220,
        get = function()
            return ns.db.profile.cooldownManager_keybindFontName or "Friz Quadrata TT"
        end,
        set = function(value)
            ns.db.profile.cooldownManager_keybindFontName = value
            ns.Keybinds:OnSettingChanged()
        end,
        desc = "選擇技能快捷鍵文字的字型。若可用將使用 SharedMedia 字型。",
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
        name = "文字樣式",
        customText = "無標籤",
        searchtags = { "字型", "標籤", "外框", "陰影", "粗", "單色", "快捷鍵", "樣式", "Font", "Flags", "Outline", "Shadow", "Thick", "Monochrome", "Keybind", "Style" },
        defaultSelection = {},
        values = {
            ["OUTLINE"] = "外框",
            ["THICKOUTLINE"] = "粗外框",
            ["MONOCHROME"] = "單色",
        },
        getSelection = function()
            return ns.db.profile.cooldownManager_keybindFontFlags or {}
        end,
        setSelection = function(value)
            ns.db.profile.cooldownManager_keybindFontFlags = value
            ns.Keybinds:OnSettingChanged()
        end,
        desc = "選擇技能快捷鍵文字的文字樣式。",
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
        name = "關鍵：啟用與對齊點",
        searchtags = { "快捷鍵", "熱鍵", "綁定", "按鍵", "捷徑", "關鍵", "顯示", "展示", "對齊點", "Keybind", "Hotkey", "Binding", "Key", "Shortcut", "Essential", "Show", "Display", "Anchor" },
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
            TOPLEFT = "左上",
            TOP = "上方",
            TOPRIGHT = "右上",
            LEFT = "左側",
            CENTER = "中間",
            RIGHT = "右側",
            BOTTOMLEFT = "左下",
            BOTTOM = "下方",
            BOTTOMRIGHT = "右下",
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
        desc = "啟用關鍵冷卻上的快捷鍵文字並選擇對齊點位置。",
    })

    CreateKeybindFontSizeDropdown(keybindsSection, "cooldownManager_keybindFontSize_Essential", "文字大小", function()
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
        name = "X 偏移",
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
        name = "Y 偏移",
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
        name = "輔助：啟用與對齊點",
        searchtags = { "快捷鍵", "熱鍵", "綁定", "按鍵", "捷徑", "輔助", "顯示", "展示", "對齊點", "Keybind", "Hotkey", "Binding", "Key", "Shortcut", "Utility", "Show", "Display", "Anchor" },
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
            TOPLEFT = "左上",
            TOP = "上方",
            TOPRIGHT = "右上",
            LEFT = "左側",
            CENTER = "中間",
            RIGHT = "右側",
            BOTTOMLEFT = "左下",
            BOTTOM = "下方",
            BOTTOMRIGHT = "右下",
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
        desc = "啟用輔助冷卻上的快捷鍵文字並選擇對齊點位置。",
    })

    CreateKeybindFontSizeDropdown(keybindsSection, "cooldownManager_keybindFontSize_Utility", "文字大小", function()
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
        name = "X 偏移",
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
        name = "Y 偏移",
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
        name = "|cff008945Wildu|r|cff8ccd00微調|r (冷卻監控)",
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
            "微調",
            "冷卻",
            "管理員",
            "助手",
            "協助",
            "顯著標示",
            "迴圈",
            "建議",
            "邊框",
            "發光",
            "同步",
            "寬度",
            "大小",
            "一致",
            "圖示",
        },
    })

    SettingsLib:CreateCheckbox(category, {
        prefix = "CMC_",
        key = "cooldownManager_showHighlight_Essential",
        name = "顯著標示迴圈",
        searchtags = { "助手", "協助", "顯著標示", "迴圈", "建議", "邊框", "發光", "Assistant", "Assisted", "Highlight", "Rotation", "Suggested", "Border", "Glow" },
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
        desc = "當單鍵技能輔助建議技能時，在冷卻監控上顯示藍色邊框。",
    })
    SettingsLib:CreateCheckboxDropdown(category, {
        prefix = "CMC_",
        key = "cooldownManager_buttonPress",
        name = "按鍵按下覆蓋圖層",
        searchtags = { "按鈕", "按下", "覆蓋", "實驗性", "冷卻", "圖示", "Button", "Press", "Overlay", "Experimental", "Cooldowns", "Icons" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_buttonPress
        end,
        set = function(value)
            ns.db.profile.cooldownManager_buttonPress = value
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "當按下對應的動作按鈕時，在冷卻圖示上顯示覆蓋圖層。",

        dropdownKey = "cooldownManager_buttonPress_texture",
        dropdownName = "按鍵按下材質",
        dropdownValues = {
            Blizzard = "暴雪預設",
            Flat = "簡易扁平覆蓋",
        },
        dropdownDefault = "Blizzard",
        dropdownGet = function()
            return ns.db.profile.cooldownManager_buttonPress_texture or "Blizzard"
        end,
        dropdownSet = function(value)
            ns.db.profile.cooldownManager_buttonPress_texture = value
            ns.API:ShowReloadUIConfirmation()
        end,
        dropdownDesc = "選擇按鍵按下覆蓋圖層的材質。",
        dropdownOrder = {
            "Blizzard",
            "Flat",
        },
    })

    SettingsLib:CreateCheckbox(category, {
        prefix = "CMC_",
        key = "cooldownManager_limitUtilitySizeToEssential",
        name = "同步輔助區塊寬度至關鍵區塊",
        searchtags = { "同步", "寬度", "大小", "匹配", "限制", "輔助", "關鍵", "約束", "Sync", "Width", "Size", "Match", "Limit", "Utility", "Essential", "Constrain" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_limitUtilitySizeToEssential
        end,
        set = function(value)
            ns.db.profile.cooldownManager_limitUtilitySizeToEssential = value
            ns.CooldownManager.ForceRefreshAll()
        end,
        desc = "將輔助區塊的|cffff0000最大|r寬度設定為關鍵區塊的寬度\n|cffff0000寬度不會小於 6 個圖示，或您在|r|cff87bbca編輯模式|r中設定的限制",
    })
    local version = C_AddOns.GetAddOnMetadata("CooldownManagerCentered", "version")
    SettingsLib:CreateText(category, {
        name = "|cffcccccc插件版本: " .. version .. "|r",
    })

    local experimentalCategory = SettingsLib:CreateCategory(category, "實驗性", false)

    SettingsLib:CreateHeader(experimentalCategory, {
        name = "|cffff0000實驗性功能|r",
        searchtags = { "實驗性", "測試", "功能", "Experimental", "Beta", "Testing", "Feature", "Features" },
    })

    SettingsLib:CreateCheckbox(experimentalCategory, {
        prefix = "CMC_",
        key = "cooldownManager_experimental_enableRectangularIcons",
        name = "長方形圖示",
        searchtags = { "長方形", "圖示", "實驗性", "矩形", "寬", "長寬比", "Rectangular", "Icons", "Experimental", "Rectangle", "Wide", "Aspect Ratio" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_experimental_enableRectangularIcons
        end,
        set = function(value)
            ns.db.profile.cooldownManager_experimental_enableRectangularIcons = value
            ns.StyledIcons:OnSettingChanged()
            ns.API:ShowReloadUIConfirmation()
        end,
        desc = "為冷卻管理員檢視器啟用長方形圖示。|cffff0000實驗性功能，可能會導致問題！|r",
    })
    SettingsLib:CreateText(experimentalCategory, {
        name = '長方形圖示 - 需要啟用「方形樣式」- 尚未完全可配置',
    })

    SettingsLib:CreateCheckbox(experimentalCategory, {
        prefix = "CMC_",
        key = "cooldownManager_experimental_hideAuras",
        name = "隱藏光環",
        searchtags = { "隱藏", "光環", "實驗性", "冷卻", "增益", "減益", "Hide", "Auras", "Experimental", "Cooldowns", "Buffs", "Debuffs" },
        default = false,
        get = function()
            return ns.db.profile.cooldownManager_experimental_hideAuras
        end,
        set = function(value)
            ns.db.profile.cooldownManager_experimental_hideAuras = value
        end,
        desc = "在圖示上隱藏光環，始終只顯示技能的冷卻時間。|cffff0000實驗性功能，可能會導致問題！|r",
    })
    SettingsLib:CreateText(experimentalCategory, {
        name = "隱藏光環，始終只顯示技能的冷卻時間",
    })

    SettingsLib:CreateCheckbox(experimentalCategory, {
        prefix = "CMC_",
        key = "cooldownManager_experimental_trinketRacialTracker",
        name = "飾品、藥水與種族特長追蹤器",
        searchtags = { "飾品", "種族", "追蹤器", "實驗性", "冷卻", "圖示", "藥水", "治療石", "Trinket", "Racial", "Tracker", "Experimental", "Cooldowns", "Icons", "Potion", "Healthstone" },
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
        desc = "顯示一個獨立的追蹤條，用於監控飾品、藥水、治療石和種族特長的冷卻時間。|cffff0000實驗性功能，可能會導致問題！|r",
    })
    SettingsLib:CreateText(experimentalCategory, {
        name = "在可移動的條上追蹤飾品、藥水、治療石和種族特長的冷卻時間",
    })

    local trackerStyleSection = SettingsLib:CreateExpandableSection(experimentalCategory, {
        name = "|cffeeeeee飾品追蹤器|r樣式",
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
        name = "忽略的種族特長",
        customText = "顯示所有種族特長",
        searchtags = { "飾品", "種族", "追蹤器", "忽略", "隱藏", "過濾", "Trinket", "Racial", "Tracker", "Ignore", "Hide", "Filter" },
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
            return "忽略 " .. #selectedLabels .. " 個種族特長"
        end,
        desc = "選擇要從追蹤器中隱藏的種族特長。相同名稱的多個法術 ID 將全部隱藏。",
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
        name = "忽略的物品",
        searchtags = { "飾品", "物品", "藥水", "追蹤器", "忽略", "隱藏", "過濾", "治療石", "Trinket", "Item", "Potion", "Tracker", "Ignore", "Hide", "Filter", "Healthstone" },
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
        customText = "顯示所有物品",
        summary = function(selectionMap, selectedLabels)
            if #selectedLabels == 0 then
                return ""
            end
            return "忽略 " .. #selectedLabels .. " 個物品"
        end,
        desc = "選擇要從追蹤器中隱藏的物品（藥水、治療石）。",
    })

    SettingsLib:CreateCheckbox(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_squareIcons",
        name = "方形圖示",
        searchtags = { "飾品", "種族", "追蹤器", "方形", "圖示", "樣式", "Trinket", "Racial", "Tracker", "Square", "Icons", "Style" },
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
        desc = "將方形圖示樣式套用到飾品、藥水與種族特長追蹤器。停用時將使用預設冷卻管理員遮罩（材質 6707800）。",
    })

    SettingsLib:CreateSlider(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_borderThickness",
        name = "邊框粗細",
        searchtags = { "飾品", "種族", "追蹤器", "邊框", "粗細", "寬度", "Trinket", "Racial", "Tracker", "Border", "Thickness", "Width" },
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
        desc = "追蹤器圖示的邊框粗細（圖示邊緣與材質之間的空間）。",
    })

    SettingsLib:CreateSlider(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_iconZoom",
        name = "圖示縮放",
        searchtags = { "飾品", "種族", "追蹤器", "縮放", "比例", "裁切", "Trinket", "Racial", "Tracker", "Zoom", "Scale", "Crop" },
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
        desc = "追蹤器圖示的縮放等級（0 = 無縮放，0.5 = 最大縮放）。",
    })

    SettingsLib:CreateHeader(experimentalCategory, {
        parentSection = trackerStyleSection,
        name = "堆疊/計數數字",
    })

    local anchorPointValues = {
        TOPLEFT = "左上",
        TOP = "上方",
        TOPRIGHT = "右上",
        LEFT = "左側",
        CENTER = "中間",
        RIGHT = "右側",
        BOTTOMLEFT = "左下",
        BOTTOM = "下方",
        BOTTOMRIGHT = "右下",
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
        name = "堆疊對齊點",
        searchtags = { "飾品", "種族", "追蹤器", "堆疊", "對齊點", "位置", "計數", "Trinket", "Racial", "Tracker", "Stack", "Anchor", "Position", "Count" },
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
        desc = "追蹤器圖示上堆疊/計數數字的對齊點位置。",
    })

    SettingsLib:CreateSlider(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_stackFontSize",
        name = "堆疊文字大小",
        searchtags = { "飾品", "種族", "追蹤器", "堆疊", "字型", "大小", "計數", "Trinket", "Racial", "Tracker", "Stack", "Font", "Size", "Count" },
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
        desc = "追蹤器圖示上堆疊/計數數字的文字大小。",
    })

    SettingsLib:CreateSlider(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_stackOffsetX",
        name = "X 偏移",
        searchtags = { "飾品", "種族", "追蹤器", "堆疊", "偏移", "X", "水平", "Trinket", "Racial", "Tracker", "Stack", "Offset", "X", "Horizontal" },
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
        desc = "堆疊/計數數字位置的水平偏移。",
    })

    SettingsLib:CreateSlider(experimentalCategory, {
        parentSection = trackerStyleSection,
        prefix = "CMC_",
        key = "trinketRacialTracker_stackOffsetY",
        name = "Y 偏移",
        searchtags = { "飾品", "種族", "追蹤器", "堆疊", "偏移", "Y", "垂直", "Trinket", "Racial", "Tracker", "Stack", "Offset", "Y", "Vertical" },
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
        desc = "堆疊/計數數字位置的垂直偏移。",
    })

    SettingsLib:CreateText(experimentalCategory, {
        parentSection = trackerStyleSection,
        name = "注意：堆疊字型名稱與標籤採用全域堆疊字型設定。",
    })
end

-- Initialize the settings UI (called from main addon after DB is ready)
function WilduSettings:RegisterSettings()
    local category, layout = Settings.RegisterVerticalLayoutCategory(
        "技能監控"
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