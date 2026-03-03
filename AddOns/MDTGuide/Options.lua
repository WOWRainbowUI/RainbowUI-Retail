---@type string
local Name = ...
---@class Addon
local Addon = select(2, ...)

---@class Options
local Self = {}
Addon.Options = Self

function Self:RegisterCategories()
    self.category, self.layout = Settings.RegisterVerticalLayoutCategory(Name)
    Settings.RegisterAddOnCategory(self.category)
end

function Self:RegisterGeneralSettings()
    -- 縮放 (最小)
    self:CreateSlider(
        "zoomMin",
        "縮放 (最小值)",
        1, 0.1, 2, 0.1,
        FormatPercentageRounded,
        "設定最小縮放比例。"
    )

    -- 縮放 (最大)
    self:CreateSlider(
        "zoomMax",
        "縮放 (最大值)",
        1, 0.1, 2, 0.1,
        FormatPercentageRounded,
        "設定最大縮放比例。"
    )

    -- 淡出/不透明度
    self:CreateCheckboxSlider(
        "fade",
        "自動淡出",
        false,
        0.3, 0.1, 1, 0.1,
        FormatPercentageRounded,
        "當滑鼠不在視窗上時，自動淡出導覽視窗（調整不透明度）。",
        function () Addon.SetFade() end
    )

    -- 戰鬥中隱藏
    self:CreateCheckbox(
        "hide",
        "戰鬥中隱藏",
        false,
        "進入戰鬥時自動隱藏導覽視窗。",
        function () Addon.SetHide() end
    )

    -- 地圖切換動畫
    self:CreateCheckbox(
        "animate",
        "地圖切換動畫",
        true,
        "啟用拉怪波次切換時的平滑過渡動畫。若在切換拉怪波次時感到延遲，請關閉此選項。"
    )
end

function Self:Migrate()
    -- Legacy globals
    if MDTGuideOptions and MDTGuideOptions.version == 1 then
        MDTGuideDB.active = MDTGuideActive
        MDTGuideDB.options = MDTGuideOptions
        MDTGuideActive = nil
        MDTGuideOptions = nil
    end

    -- Migrate options
    local op = MDTGuideDB.options

    if not op.version then
        op.zoom = nil
        op.zoomMin = 1
        op.zoomMax = 1
        op.route = false
        op.version = 1
    end
    if op.version <= 1 then
        op.animate = true
        op.version = 2
    end
end

-- UTIL

---@param name string
---@param label string
---@param defaultValue number
---@param minValue number
---@param maxValue number
---@param rate number
---@param formatter fun(value: number): number
---@param tooltip? string
---@param callback? fun(setting: Setting, value: number)
---@param category? SettingsCategory
---@param variableTbl? table
function Self:CreateSlider(name, label, defaultValue, minValue, maxValue, rate, formatter, tooltip, callback, category, variableTbl)
    if not category then category = self.category end
    if not variableTbl then variableTbl = MDTGuideDB.options end

    local setting = Settings.RegisterAddOnSetting(category, name, name, variableTbl, Settings.VarType.Number, label, defaultValue)
    if callback then setting:SetValueChangedCallback(callback) end

    local options = Settings.CreateSliderOptions(minValue, maxValue, rate)
    if formatter then
        options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, formatter)
    end

    return Settings.CreateSlider(category, setting, options, tooltip)
end

---@param name string
---@param label string
---@param defaultValue number | false
---@param minValue number
---@param maxValue number
---@param rate number
---@param formatter fun(value: number): number
---@param tooltip? string
---@param callback? fun(setting: Setting, value: number | false)
---@param category? SettingsCategory
---@param variableTbl? table
function Self:CreateCheckboxSlider(name, label, defaultEnabled, defaultValue, minValue, maxValue, rate, formatter, tooltip, callback, category, variableTbl)
    if not category then category = self.category end
    if not variableTbl then variableTbl = MDTGuideDB.options end

    local sliderSetting
    sliderSetting = Settings.RegisterProxySetting(
        category,
        name,
        Settings.VarType.Number,
        label,
        defaultValue,
        function () return variableTbl[name] or defaultValue end,
        function (value)
            variableTbl[name] = value
            if callback then callback(sliderSetting, variableTbl[name] --[[@as number | false]]) end
        end
    )

    local sliderOptions = Settings.CreateSliderOptions(minValue, maxValue, rate)
    if formatter then
        sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, formatter)
    end

    local checkboxSetting = Settings.RegisterProxySetting(
        category,
        name .. "Enabled",
        Settings.VarType.Boolean,
        label,
        defaultEnabled,
        function () return variableTbl[name] ~= false end,
        function (value)
            variableTbl[name] = value and defaultValue
            if callback then callback(sliderSetting, variableTbl[name] --[[@as number | false]]) end
        end
    )

    self.layout:AddInitializer(CreateSettingsCheckboxSliderInitializer(
        checkboxSetting, "Enable " .. label, tooltip,
        sliderSetting, sliderOptions, "Set " .. label, tooltip
    ))
end

---@param name string
---@param label string
---@param defaultValue boolean
---@param tooltip? string
---@param callback? fun(setting: Setting, value: boolean)
---@param category? SettingsCategory
---@param variableTbl? table
function Self:CreateCheckbox(name, label, defaultValue, tooltip, callback, category, variableTbl)
    if not category then category = self.category end
    if not variableTbl then variableTbl = MDTGuideDB.options end

    local setting = Settings.RegisterAddOnSetting(category, name, name, variableTbl, Settings.VarType.Boolean, label, defaultValue)
    if callback then setting:SetValueChangedCallback(callback) end

    return Settings.CreateCheckbox(category, setting, tooltip)
end

-- EVENTS

function Self:OnLoaded()
    self:Migrate()
    self:RegisterCategories()
    self:RegisterGeneralSettings()
end