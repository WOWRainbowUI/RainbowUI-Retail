local AddonName, MKPT_env, _ = ...
local L = MKPT_env.L

function MKPT_env.InitializeOptionsMenu()
    local db = MKPT_env.db
    local charDb = MKPT_env.charDb
    -- Create and register the main category for your addon in the Interface Options
    local category, layout, _ = Settings.RegisterVerticalLayoutCategory(L["Myu's kp Tracker"])
    MKPT_env.categoryId = category:GetID()
    local generalSubcategory, generalLayout = Settings.RegisterVerticalLayoutSubcategory(category, L["General"])
    local appearanceSubategory, appearanceLayout = Settings.RegisterVerticalLayoutSubcategory(category, L["Appearance"])

    do
        layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["Subcategories"]))
    end

    do
        local name = L["General"]
        local buttonText = L["Go to general options"]
        local tooltip = L["Lock window, autohide, minimap icon and more"]
        local onClick = function() Settings.OpenToCategory(generalSubcategory:GetID()) end
        local searchable = false
        local generalCategoryButtonInitializer = CreateSettingsButtonInitializer(
            name,
            buttonText,
            onClick,
            tooltip,
            searchable
        )
        layout:AddInitializer(generalCategoryButtonInitializer)
    end

    do
        local name = L["Appearance"]
        local buttonText = L["Go to appearance options"]
        local tooltip = L["Change text color, background opacity and window size"]
        local onClick = function() Settings.OpenToCategory(appearanceSubategory:GetID()) end
        local searchable = false
        local generalCategoryButtonInitializer = CreateSettingsButtonInitializer(
            name,
            buttonText,
            onClick,
            tooltip,
            searchable
        )
        layout:AddInitializer(generalCategoryButtonInitializer)
    end

    do
        generalLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["Behavior"]))
    end

    do
        local GetValue = function()
            return db.ui.lockWindow
        end
        local SetValue = function(value)
            MKPT_env.SetLockUi(value)
        end
        local name = L["Lock Window"]
        local defaultValue = false
        local setting = Settings.RegisterProxySetting(
            generalSubcategory,
            "MKPT_LockWindow",
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        local tooltip = L["Locks window position"]
        Settings.CreateCheckbox(generalSubcategory, setting, tooltip)
    end

    do
        local GetValue = function()
            return db.ui.autohide
        end
        local SetValue = function(value)
            MKPT_env.ToggleAutoHide()
        end
        local name = L["Autohide"]
        local defaultValue = false
        local setting = Settings.RegisterProxySetting(
            generalSubcategory,
            "MKPT_Autohide",
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        local tooltip = L["Hides the window when the cursor is not over it"]
        Settings.CreateCheckbox(generalSubcategory, setting, tooltip)
    end

    do
        local GetValue = function()
            return db.ui.hideInCombat
        end
        local SetValue = function(value)
            db.ui.hideInCombat = value

            if not InCombatLockdown() then
                return
            end
            if value then
                MKPT_env.ui:Hide()
            elseif MKPT_env.charDb.state.show then
                MKPT_env.ui:Show()
            end
        end
        local name = L["Hide in combat"]
        local defaultValue = false
        local setting = Settings.RegisterProxySetting(
            generalSubcategory,
            "MKPT_HideInCombat",
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        local tooltip = L["Hides the window when in combat"]
        Settings.CreateCheckbox(generalSubcategory, setting, tooltip)
    end

    do
        local GetValue = function()
            return db.config.professionsStartExpanded
        end
        local SetValue = function(value)
            db.config.professionsStartExpanded = value
        end
        local name = L["Start expanded (All characters)"]
        local defaultValue = false
        local setting = Settings.RegisterProxySetting(
            generalSubcategory,
            "MKPT_ProfessionsStartExpanded",
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        local tooltip = L["Professions are expanded on login for all characters, unchecking this will cause them to be collapsed (default)"]
        Settings.CreateCheckbox(generalSubcategory, setting, tooltip)
    end

    do
        local GetValue = function()
            return charDb.config.professionsStartExpanded
        end
        local SetValue = function(value)
            charDb.config.professionsStartExpanded = value
        end
        local name = L["Start expanded (Only this character)"]
        local defaultValue = false
        local setting = Settings.RegisterProxySetting(
            generalSubcategory,
            "MKPT_ProfessionsStartExpandedCharacter",
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        local tooltip = L["Professions are expanded on login for this character, unchecking this will cause them to be collapsed (default)"]
        Settings.CreateCheckbox(generalSubcategory, setting, tooltip)
    end

    do
        generalLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["Icons"]))
    end

    do
        local GetValue = function()
            return not db.minimap.hide
        end
        local SetValue = function(value)
            MKPT_env.ToggleMinimapIcon()
        end
        local name = L["Minimap icon"]
        local defaultValue = true
        local setting = Settings.RegisterProxySetting(
            generalSubcategory,
            "MKPT_Minimap",
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        local tooltip = L["Show/hide minimap icon"]
        Settings.CreateCheckbox(generalSubcategory, setting, tooltip)
    end

    do
        local GetValue = function()
            return not db.compartment.hide
        end
        local SetValue = function(value)
            MKPT_env.ToggleCompartmentIcon()
        end
        local name = L["Show in addon compartment"]
        local defaultValue = true
        local setting = Settings.RegisterProxySetting(
            generalSubcategory,
            "MKPT_Compartment",
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        local tooltip = L["Show/hide addon compartment entry"]
        Settings.CreateCheckbox(generalSubcategory, setting, tooltip)
    end

    do
        appearanceLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["Window"]))
    end

    do
        local variableName = "MKPT_UiScale"
        local name = L["UI scale"]
        local tooltip = L["Resizes the addon window"]
        local defaultValue = 1.0
        local minValue = 0.5
        local maxValue = 1.5
        local step = 0.05

        local GetValue = function()
            return db.ui.scale
        end
        local SetValue = function(value)
            MKPT_env.SetUiScale(value)
        end

        local setting = Settings.RegisterProxySetting(
            appearanceSubategory,
            variableName,
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        local options = Settings.CreateSliderOptions(minValue, maxValue, step)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
            return string.format("%.2f", value)
        end)
        Settings.CreateSlider(appearanceSubategory, setting, options, tooltip)
    end

    do
        local variableName = "MKPT_BackgroundOpacity"
        local name = L["Background Opacity"]
        local tooltip = L["Changes background opacity"]
        local defaultValue = 0.6
        local minValue = 0.0
        local maxValue = 1.0
        local step = 0.01

        local GetValue = function()
            return db.ui.backgroundColor.a
        end
        local SetValue = function(value)
            local backgroundColor = db.ui.backgroundColor
            backgroundColor.a = value

            MKPT_env.ui:SetBackdropColor(backgroundColor.r, backgroundColor.g, backgroundColor.b, backgroundColor.a)
        end

        local setting = Settings.RegisterProxySetting(
            appearanceSubategory,
            variableName,
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        local options = Settings.CreateSliderOptions(minValue, maxValue, step)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
            return string.format("%.2f", value)
        end)
        Settings.CreateSlider(appearanceSubategory, setting, options, tooltip)
    end

    do
        local variableName = "MKPT_RowBackgroundOpacity"
        local name = L["Row Background Opacity"]
        local tooltip = L["Changes row background opacity"]
        local defaultValue = 0.5
        local minValue = 0.0
        local maxValue = 1.0
        local step = 0.01

        local GetValue = function()
            return db.ui.rowBackgroundColor.a
        end
        local SetValue = function(value)
            db.ui.rowBackgroundColor.a = value
            MKPT_env.ui:RenderTree()
        end

        local setting = Settings.RegisterProxySetting(
            appearanceSubategory,
            variableName,
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        local options = Settings.CreateSliderOptions(minValue, maxValue, step)
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
            return string.format("%.2f", value)
        end)
        Settings.CreateSlider(appearanceSubategory, setting, options, tooltip)
    end

    do
        appearanceLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["Text Colors"]))
    end

    do
        local variableName = "MKPT_WeeklyColor"
        local name = L["Weekly Color"]
        local tooltip = L["Changes the color of weekly obtainable points"]
        local defaultValue = "FF006FDD"

        local GetValue = function()
            return db.ui.colors.weekly
        end
        local SetValue = function(value)
            db.ui.colors.weekly = value
            MKPT_env.ui:RenderTree()
        end

        local setting = Settings.RegisterProxySetting(
            appearanceSubategory,
            variableName,
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        Settings.CreateColorSwatch(appearanceSubategory, setting, tooltip)
    end

    do
        local variableName = "MKPT_CatchUpColor"
        local name = L["Catch-Up Color"]
        local tooltip = L["Changes the color of catch-up mechanic points"]
        local defaultValue = "FF1EFF00"

        local GetValue = function()
            return db.ui.colors.catchUp
        end
        local SetValue = function(value)
            db.ui.colors.catchUp = value
            MKPT_env.ui:RenderTree()
        end

        local setting = Settings.RegisterProxySetting(
            appearanceSubategory,
            variableName,
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        Settings.CreateColorSwatch(appearanceSubategory, setting, tooltip)
    end

    do
        local variableName = "MKPT_UniqueColor"
        local name = L["Unique Color"]
        local tooltip = L["Changes the color of Unique knowledge points"]
        local defaultValue = "FFA435EE"

        local GetValue = function()
            return db.ui.colors.unique
        end
        local SetValue = function(value)
            db.ui.colors.unique = value
            MKPT_env.ui:RenderTree()
        end

        local setting = Settings.RegisterProxySetting(
            appearanceSubategory,
            variableName,
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        Settings.CreateColorSwatch(appearanceSubategory, setting, tooltip)
    end

    do
        local variableName = "MKPT_Missing"
        local name = L["Missing Color"]
        local tooltip = L["Changes the color of Missing knowledge points"]
        local defaultValue = "FFFF8000"

        local GetValue = function()
            return db.ui.colors.missing
        end
        local SetValue = function(value)
            db.ui.colors.missing = value
            MKPT_env.ui:RenderTree()
        end

        local setting = Settings.RegisterProxySetting(
            appearanceSubategory,
            variableName,
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        Settings.CreateColorSwatch(appearanceSubategory, setting, tooltip)
    end

    do
        local variableName = "MKPT_Unspent"
        local name = L["Unspent Color"]
        local tooltip = L["Changes the color of Unspent knowledge points"]
        local defaultValue = "FFFF6DCE"

        local GetValue = function()
            return db.ui.colors.unspent
        end
        local SetValue = function(value)
            db.ui.colors.unspent = value
            MKPT_env.ui:RenderTree()
        end

        local setting = Settings.RegisterProxySetting(
            appearanceSubategory,
            variableName,
            type(defaultValue),
            name,
            defaultValue,
            GetValue,
            SetValue
        )
        Settings.CreateColorSwatch(appearanceSubategory, setting, tooltip)
    end


    Settings.RegisterAddOnCategory(category)
end
