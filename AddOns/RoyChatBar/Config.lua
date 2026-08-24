local addonName, ns = ...
local L = ns.L

-- ========================================================================
-- UI 控件函数
-- ========================================================================
local function CreateHeader(layout, opt)
    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(opt.name, opt.tooltip))
end

local function CreateCheckbox(category, opt)
    local setting = Settings.RegisterProxySetting(
        category, opt.key, Settings.VarType.Boolean, opt.name, opt.default,
        function() return RoyChatBarDB[opt.key] end,
        function(value) RoyChatBarDB[opt.key] = value end
    )
    local init = Settings.CreateCheckbox(category, setting, opt.tooltip)
    if opt.onChange then setting:SetValueChangedCallback(opt.onChange) end
    return init
end

local function CreateSlider(category, opt)
    local getter = opt.getter or function() return RoyChatBarDB[opt.key] end
    local setter = opt.setter or function(value) RoyChatBarDB[opt.key] = value end
    local setting = Settings.RegisterProxySetting(
        category, opt.key, Settings.VarType.Number, opt.name, opt.default,
        getter, setter
    )
    local options = Settings.CreateSliderOptions(opt.min, opt.max, opt.step)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(v)
        if opt.step and opt.step < 1 then return string.format("%.1f", v) else return string.format("%d", v) end
    end)
    local init = Settings.CreateSlider(category, setting, options, opt.tooltip)
    if opt.onChange then setting:SetValueChangedCallback(opt.onChange) end
    return init
end

local function CreateDropdown(category, opt)
    local varType = type(opt.default) == "number"
                    and Settings.VarType.Number or Settings.VarType.String
    local getter = opt.getter or function() return RoyChatBarDB[opt.key] end
    local setter = opt.setter or function(value) RoyChatBarDB[opt.key] = value end
    local setting = Settings.RegisterProxySetting(
        category, opt.key, varType, opt.name, opt.default,
        getter, setter
    )
    local init = Settings.CreateDropdown(category, setting, opt.options, opt.tooltip)
    if opt.onChange then setting:SetValueChangedCallback(opt.onChange) end
    return init
end

local function CreateColorSwatch(category, opt)
    local setting = Settings.RegisterProxySetting(
        category, opt.key, Settings.VarType.String, opt.name, opt.default,
        function() return RoyChatBarDB[opt.key] end,
        function(value) RoyChatBarDB[opt.key] = value end
    )
    local init = Settings.CreateColorSwatch(category, setting, opt.tooltip)
    if opt.onChange then setting:SetValueChangedCallback(opt.onChange) end
    return init
end

local function CreateCheckBoxSlider(category, layout, opt)
    local cbSetting = Settings.RegisterProxySetting(
        category, opt.key, Settings.VarType.Boolean, opt.cbLabel, opt.cbDefault,
        function() return RoyChatBarDB[opt.key] end,
        function(value) RoyChatBarDB[opt.key] = value end
    )
    local sliderSetting = Settings.RegisterProxySetting(
        category, opt.sliderKey, Settings.VarType.Number, opt.sliderLabel, opt.sliderDefault,
        function() return RoyChatBarDB[opt.sliderKey] end,
        function(value) RoyChatBarDB[opt.sliderKey] = value end
    )
    local sliderOptions = Settings.CreateSliderOptions(opt.sliderMin, opt.sliderMax, opt.sliderStep)
    sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(v)
        if opt.sliderStep and opt.sliderStep < 1 then return string.format("%.1f", v) else return string.format("%d", v) end
    end)
    if opt.onChange then
        cbSetting:SetValueChangedCallback(opt.onChange)
        sliderSetting:SetValueChangedCallback(opt.onChange)
    end
    local initializer = CreateSettingsCheckboxSliderInitializer(
        cbSetting, opt.cbLabel, opt.cbTooltip,
        sliderSetting, sliderOptions, opt.sliderLabel, opt.sliderTooltip
    )
    layout:AddInitializer(initializer)
    return initializer
end

local function CreateCheckBoxDropdown(category, layout, opt)
    local cbSetting = Settings.RegisterProxySetting(
        category, opt.key, Settings.VarType.Boolean, opt.cbLabel, opt.cbDefault,
        function() return RoyChatBarDB[opt.key] end,
        function(value) RoyChatBarDB[opt.key] = value end
    )
    local varType = type(opt.dropdownDefault) == "number"
                    and Settings.VarType.Number or Settings.VarType.String
    local dropdownSetting = Settings.RegisterProxySetting(
        category, opt.dropdownKey, varType, opt.dropdownLabel, opt.dropdownDefault,
        function() return RoyChatBarDB[opt.dropdownKey] end,
        function(value) RoyChatBarDB[opt.dropdownKey] = value end
    )
    if opt.onChange then
        cbSetting:SetValueChangedCallback(opt.onChange)
        dropdownSetting:SetValueChangedCallback(opt.onChange)
    end
    local initializer = CreateSettingsCheckboxDropdownInitializer(
        cbSetting, opt.cbLabel, opt.cbTooltip,
        dropdownSetting, opt.options, opt.dropdownLabel, opt.dropdownTooltip
    )
    layout:AddInitializer(initializer)
    return initializer
end

local function CreateCheckBoxColor(category, layout, opt)
    local cbSetting = Settings.RegisterProxySetting(
        category, opt.key, Settings.VarType.Boolean, opt.cbLabel, opt.cbDefault,
        function() return RoyChatBarDB[opt.key] end,
        function(value) RoyChatBarDB[opt.key] = value end
    )
    if opt.onChange then cbSetting:SetValueChangedCallback(opt.onChange) end

    local function OnSwatchClick()
        local hex = RoyChatBarDB[opt.colorKey] or opt.colorDefault or "FFFFFFFF"
        local c = CreateColorFromHexString(hex)
        local info = {}
        info.r, info.g, info.b = c:GetRGB()
        info.swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local newHex = CreateColor(r, g, b):GenerateHexColor()
            RoyChatBarDB[opt.colorKey] = newHex
            if opt.onChange then opt.onChange(nil, newHex) end
        end
        info.cancelFunc = function()
            local r, g, b = ColorPickerFrame:GetPreviousValues()
            local prevHex = CreateColor(r, g, b):GenerateHexColor()
            RoyChatBarDB[opt.colorKey] = prevHex
            if opt.onChange then opt.onChange(nil, prevHex) end
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end

    local function GetSwatchColor()
        local hex = RoyChatBarDB[opt.colorKey] or opt.colorDefault or "FFFFFFFF"
        return CreateColorFromHexString(hex)
    end

    local initializer = CreateSettingsCheckboxWithColorSwatchInitializer(
        cbSetting, opt.cbTooltip,
        OnSwatchClick, nil, nil,
        GetSwatchColor, opt.colorLabel, nil
    )
    layout:AddInitializer(initializer)
    return initializer
end

local function CreateControl(category, layout, opt)
    if opt.type == "header" then
        CreateHeader(layout, opt)
        return nil
    elseif opt.type == "checkbox" then
        return CreateCheckbox(category, opt)
    elseif opt.type == "slider" then
        return CreateSlider(category, opt)
    elseif opt.type == "dropdown" then
        return CreateDropdown(category, opt)
    elseif opt.type == "color" then
        return CreateColorSwatch(category, opt)
    elseif opt.type == "CheckBoxSlider" then
        return CreateCheckBoxSlider(category, layout, opt)
    elseif opt.type == "CheckBoxDropdown" then
        return CreateCheckBoxDropdown(category, layout, opt)
    elseif opt.type == "CheckBoxColor" then
        return CreateCheckBoxColor(category, layout, opt)
    end
    return nil
end

-- ========================================================================
-- 主界面
-- ========================================================================
local function CreateMainFrame()
    local frame = CreateFrame("Frame")

    -- 标题
    local title = frame:CreateFontString(nil, "ARTWORK")
    title:SetFont(STANDARD_TEXT_FONT, 30, "OUTLINE")
    title:SetPoint("TOP", 0, -20)
    title:SetText("RoyChatBar")
    title:SetTextColor(1, 0.8, 0)

    -- 副标题
    local subtitle = frame:CreateFontString(nil, "ARTWORK")
    subtitle:SetFont(STANDARD_TEXT_FONT, 20, "OUTLINE")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -10)
    subtitle:SetText(L["快捷聊天条"])
    subtitle:SetTextColor(0.6, 0.8, 1)

    -- 装饰线
    local line = frame:CreateLine()
    line:SetColorTexture(0.8, 0.6, 0, 0.6)
    line:SetThickness(1.5)
    line:SetStartPoint("TOPLEFT", 20, -90)
    line:SetEndPoint("TOPRIGHT", -20, -90)

    -- 更新记录标题
    local changelogTitle = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    changelogTitle:SetPoint("TOP", line, "BOTTOM", 0, -15)
    changelogTitle:SetWidth(600)
    changelogTitle:SetJustifyH("LEFT")
    changelogTitle:SetText(L["更新记录"])
    changelogTitle:SetTextColor(1, 0.8, 0)

    -- 滚动框架
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOP", changelogTitle, "BOTTOM", 0, -10)
    scrollFrame:SetPoint("LEFT", frame, "LEFT", 30, 0)
    scrollFrame:SetPoint("RIGHT", frame, "RIGHT", -50, 0)
    scrollFrame:SetHeight(400)

    -- 滚动框架背景
    local bg = CreateFrame("Frame", nil, scrollFrame, "BackdropTemplate")
    bg:SetAllPoints(scrollFrame)
    bg:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    bg:SetBackdropColor(0, 0, 0, 0.8)
    bg:SetFrameLevel(scrollFrame:GetFrameLevel() - 1)

    -- 滚动内容子框架
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(570)

    -- 更新记录文本
    local changelog = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    changelog:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 10, -10)
    changelog:SetWidth(570)
    changelog:SetJustifyH("LEFT")
    changelog:SetSpacing(10)
    changelog:SetTextColor(0.5, 0.5, 0.5)

    if not rawget(ns.L, "changelog") then
        ns.L["changelog"] = [[
【2026.8.14】v1.9.5
・修复tab切换频道时的某些错误
・修复定位模式的某些错误

【2026.8.12】v1.9.4
・添加12.1支持

【2026.6.17】v1.9.3
・添加12.0.7支持

【2026.6.8】v1.9.2
・恢复频道名简写功能
・添加聊天条渐隐功能

【2026.5.31】v1.9.1
・调整toc文件顺序
・添加繁体中文翻译

【2026.5.31】v1.9
・完全重构插件结构
・添加倒计时停止功能，右键点击开始倒计时，再次点击停止倒计时
・添加重载按钮点击模式，现在可以选择双击后再重载界面，防止误触
・移除频道名称简写功能
・添加本地化支持

【2026.4.22】v1.8.1
・添加12.0.5支持   

【2026.3.19】v1.8
・修复在原生聊天框下退出世界频道后重新加入会无效的问题
・更改插件配置界面

【2026.2.22】v1.7
・修复绑定到原生聊天框后，切换标签时聊天条会消失的问题
・在插件设置主界面添加了更新记录

【2026.2.14】v1.6
・拆分“骰”按钮和“宏”按钮
・“骰”按钮更新为左键掷骰子，右键打开战利品投掷界面
・“RL”按钮右键添加重置伤害统计功能

【2026.1.31】v1.5
・修正聊天条材质路径

【2026.1.29】v1.4
・添加倒计时时长滑动条（3-10秒）
・更新“骰”按钮，左键打开宏命令界面，右键掷骰子
・添加绑定聊天框功能，启用后在编辑模式下移动聊天框，聊天条可跟随聊天框一起移动，绑定状态下的XY值为相对位置（只支持原生聊天框）

【2026.1.26】v1.3
・修复频道缩写引起的战斗报错

【2026.1.23】v1.2
・添加频道缩写
・添加TAB切换频道
・修改聊天条移动范围

【2026.1.22】v1.1
・重置插件名称，适配12.0版本

【2026.1.15】v1.0
・发布插件版
        ]]
    end
    changelog:SetText(L["changelog"])

    scrollChild:SetHeight(changelog:GetStringHeight() + 30)

    return frame
end

-- ========================================================================
-- 面板初始化
-- ========================================================================
local function InitializeSettings()
    -- 主界面使用 Canvas 布局，支持自定义 Frame
    local mainFrame = CreateMainFrame()
    local mainCategory = Settings.RegisterCanvasLayoutCategory(mainFrame, L["RoyChatBar"])

    -- 子分类使用垂直布局，标准控件列表
    local chatCategory, chatLayout = Settings.RegisterVerticalLayoutSubcategory(mainCategory, L["聊天设置"])

    -- 注册主分类
    Settings.RegisterAddOnCategory(mainCategory)
    ns.categoryID = mainCategory:GetID()
	ns.chatCategoryID = chatCategory:GetID()   -- 新增

    local initializers = {}
    local function BuildControls(optList, category, layout)
        for _, opt in ipairs(optList) do
            local init = CreateControl(category, layout, opt)
            if init and opt.key then
                initializers[opt.key] = init
            end
        end
    end

    BuildControls(ns.ChatOptions, chatCategory, chatLayout)

    -- 绑定父子联动关系
    for parentKey, groups in pairs(ns.OptionDependencies) do
        local parentInit = initializers[parentKey]
        if parentInit then
            for _, group in ipairs(groups) do
                for _, childKey in ipairs(group.children) do
                    local childInit = initializers[childKey]
                    if childInit then
                        childInit:SetParentInitializer(parentInit, group.enabled)
                        childInit:AddShownPredicate(group.enabled)
                    end
                end
            end
        end
    end
end

EventUtil.ContinueOnPlayerLogin(InitializeSettings)