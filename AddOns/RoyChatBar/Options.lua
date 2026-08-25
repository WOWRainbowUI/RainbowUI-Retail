local addonName, ns = ...
local L = ns.L

-- ========================================================================
-- 聊天设置配置项
-- ========================================================================
local FRAME_MODE_LABELS = {
    [0] = "显示",
    [1] = "隐藏",
    [2] = "渐隐",
    [3] = "渐隐-战斗显示",
}

local function MakeFrameOptions(modeList)
    return function()
        local c = Settings.CreateControlTextContainer()
        for _, mode in ipairs(modeList) do
            c:Add(mode, L[FRAME_MODE_LABELS[mode]])
        end
        return c:GetData()
    end
end

ns.ChatOptions = {
    -- 快捷聊天条
    {
        type = "header",
        key = "chatBarHeader",
        name = L["快捷聊天条"],
    },
    {
        type = "checkbox",
        key = "isChatBar",
        name = L["启用功能"],
        default = true,
        tooltip = nil,
        onChange = function(_, value)
            if ns.OnChatBarToggle then ns.OnChatBarToggle(value) end
        end,
    },
    {
        type = "checkbox",
        key = "isWorldChannel",
        name = L["世"],
        default = false,
        tooltip = L["大脚世界频道"],
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "checkbox",
        key = "isSay",
        name = L["说"],
        default = true,
        tooltip = L["说话频道"],
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "checkbox",
        key = "isYell",
        name = L["喊"],
        default = true,
        tooltip = L["大喊频道"],
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "checkbox",
        key = "isParty",
        name = L["队"],
        default = true,
        tooltip = L["队伍频道"],
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "checkbox",
        key = "isGuild",
        name = L["会"],
        default = true,
        tooltip = L["公会频道"],
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "checkbox",
        key = "isInstanceRaid",
        name = L["本"],
        default = true,
        tooltip = L["副本频道"],
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "checkbox",
        key = "isDiceButton",
        name = L["骰"],
        default = true,
        tooltip = L["投掷骰子和拾取记录"],
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "checkbox",
        key = "isMacroButton",
        name = L["宏"],
        default = true,
        tooltip = L["宏界面"],
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "CheckBoxSlider",
        key = "isReadyCheck",
        cbLabel = L["备"],
        cbDefault = true,
        cbTooltip = L["就位确认和倒数计时"],
        sliderKey = "readyCheckCountdown",
        sliderLabel = L["倒计时时长"],
        sliderDefault = 5,
        sliderMin = 3,
        sliderMax = 10,
        sliderStep = 1,
        sliderTooltip = nil,
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "checkbox",
        key = "isLeaveReset",
        name = L["退"],
        default = true,
        tooltip = L["退出队伍和重置副本"],
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "CheckBoxDropdown",
        key = "isReload",
        cbLabel = L["RL"],
        cbDefault = true,
        cbTooltip = L["重载界面和重置伤害"],
        dropdownKey = "reloadClickMode",
        dropdownLabel = L["点击模式"],
        dropdownDefault = "single",
        dropdownTooltip = nil,
        options = function()
            local c = Settings.CreateControlTextContainer()
            c:Add("single", L["单击重载"])
            c:Add("double", L["双击重载"])
            return c:GetData()
        end,
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "checkbox",
        key = "isTabSwitch",
        name = L["TAB切换频道"],
        default = false,
        tooltip = nil,
        onChange = function(_, value)
            if ns.OnTabSwitchChanged then ns.OnTabSwitchChanged(value) end
        end,
    },

    --聊天条渐隐
    {
        type = "header",
        key = "chatBarFadeHeader",
        name = L["聊天条渐隐"],
    },
    {
        type = "slider",
        key = "rcbUiFadeInDuration",
        name = L["淡入时间"],
        default = 0.2,
        min = 0,
        max = 2,
        step = 0.1,
        tooltip = L["框体渐隐淡入动画时长"],
        onChange = function(_, _)
            if ns.OnUIFadeTimerChanged then ns.OnUIFadeTimerChanged() end
        end,
    },
    {
        type = "slider",
        key = "rcbUiFadeOutDuration",
        name = L["淡出时间"],
        default = 0.2,
        min = 0,
        max = 2,
        step = 0.1,
        tooltip = L["框体渐隐淡出动画时长"],
        onChange = function(_, _)
            if ns.OnUIFadeTimerChanged then ns.OnUIFadeTimerChanged() end
        end,
    },
    {
        type = "dropdown",
        key = "chatBar",
        name = L["聊天条渐隐"],
        default = 0,
        tooltip = nil,
        options = MakeFrameOptions({ 0, 2, 3 }),
        onChange = function(_, value)
            if ns.OnUIFrameModeChanged then ns.OnUIFrameModeChanged("chatBar", value) end
        end,
    },

    -- 配置调整
    {
        type = "header",
        key = "chatLayoutHeader",
        name = L["配置调整"],
    },
    {
        type = "dropdown",
        key = "chatDisplayMode",
        name = L["显示模式"],
        default = "TEXT",
        tooltip = nil,
        options = function()
            local c = Settings.CreateControlTextContainer()
            c:Add("TEXT", L["文本"])
            c:Add("SQUARE", L["色块"])
            return c:GetData()
        end,
        onChange = function(_, _)
            Settings.NotifyUpdate("chatTextFontSize")
            Settings.NotifyUpdate("chatSquareWidth")
            Settings.NotifyUpdate("chatSquareHeight")
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "slider",
        key = "chatTextFontSize",
        name = L["文本大小"],
        default = 20,
        min = 12,
        max = 30,
        step = 1,
        tooltip = nil,
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "slider",
        key = "chatSquareWidth",
        name = L["色块长度"],
        default = 25,
        min = 5,
        max = 50,
        step = 1,
        tooltip = nil,
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "slider",
        key = "chatSquareHeight",
        name = L["色块高度"],
        default = 10,
        min = 5,
        max = 30,
        step = 1,
        tooltip = nil,
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "dropdown",
        key = "chatLayoutDirection",
        name = L["排列方向"],
        default = "HORIZONTAL",
        tooltip = nil,
        options = function()
            local c = Settings.CreateControlTextContainer()
            c:Add("HORIZONTAL", L["横向"])
            c:Add("VERTICAL", L["纵向"])
            return c:GetData()
        end,
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "slider",
        key = "chatButtonSpacing",
        name = L["调整间距"],
        default = 2,
        min = 0,
        max = 20,
        step = 1,
        tooltip = nil,
        onChange = function(_, _)
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "dropdown",
        key = "chatBarAnchorMode",
        name = L["定位模式"],
        default = "ANCHOR",
        tooltip = nil,
        options = function()
            local c = Settings.CreateControlTextContainer()
            c:Add("FREE", L["定位到屏幕"])
            c:Add("ANCHOR", L["定位到聊天框"])
            return c:GetData()
        end,
        onChange = function(_, _)
            Settings.NotifyUpdate("chatBarPositionX")
            Settings.NotifyUpdate("chatBarPositionY")
            if ns.OnChatBarChanged then ns.OnChatBarChanged() end
        end,
    },
    {
        type = "slider",
        key = "chatBarPositionX",
        name = L["水平移动"],
        default = 10,
        min = -2000,
        max = 2000,
        step = 1,
        tooltip = nil,
        getter = function()
            local mode = RoyChatBarDB.chatBarAnchorMode or "FREE"
            local pos = RoyChatBarDB.chatBarPosition
            return pos and pos[mode] and pos[mode].x or 0
        end,
        setter = function(value)
            local mode = RoyChatBarDB.chatBarAnchorMode or "FREE"
            if not RoyChatBarDB.chatBarPosition then RoyChatBarDB.chatBarPosition = {} end
            if not RoyChatBarDB.chatBarPosition[mode] then RoyChatBarDB.chatBarPosition[mode] = { x = 0, y = 0 } end
            RoyChatBarDB.chatBarPosition[mode].x = value
            if ns.OnChatBarPositionChanged then ns.OnChatBarPositionChanged() end
        end,
        onChange = function(_, _) end,
    },
    {
        type = "slider",
        key = "chatBarPositionY",
        name = L["垂直移动"],
        default = -10,
        min = -2000,
        max = 2000,
        step = 1,
        tooltip = nil,
        getter = function()
            local mode = RoyChatBarDB.chatBarAnchorMode or "FREE"
            local pos = RoyChatBarDB.chatBarPosition
            return pos and pos[mode] and pos[mode].y or 0
        end,
        setter = function(value)
            local mode = RoyChatBarDB.chatBarAnchorMode or "FREE"
            if not RoyChatBarDB.chatBarPosition then RoyChatBarDB.chatBarPosition = {} end
            if not RoyChatBarDB.chatBarPosition[mode] then RoyChatBarDB.chatBarPosition[mode] = { x = 0, y = 0 } end
            RoyChatBarDB.chatBarPosition[mode].y = value
            if ns.OnChatBarPositionChanged then ns.OnChatBarPositionChanged() end
        end,
        onChange = function(_, _) end,
    },
}

-- ========================================================================
-- 父子联动依赖关系
-- ========================================================================
ns.OptionDependencies = {
    -- -------------------------------------------------------------------
    -- 聊天设置
    -- -------------------------------------------------------------------
    isChatBar = {
        {
            children = {
                "isWorldChannel", "isSay", "isYell", "isParty", "isGuild", "isInstanceRaid", "isDiceButton",
                "isMacroButton", "isReadyCheck", "isLeaveReset", "isReload", "reloadClickMode",
            },
            enabled = function() return RoyChatBarDB.isChatBar == true end,
        },
    },
    chatDisplayMode = {
        {
            children = { "chatTextFontSize" },
            enabled = function() return RoyChatBarDB.chatDisplayMode == "TEXT" end,
        },
        {
            children = { "chatSquareWidth", "chatSquareHeight" },
            enabled = function() return RoyChatBarDB.chatDisplayMode == "SQUARE" end,
        },
    },
    chatBarAnchorMode = {
        {
            children = { "chatBarPositionX", "chatBarPositionY" },
            enabled = function() return RoyChatBarDB.chatBarAnchorMode ~= nil end,
        },
    },
}

-- ========================================================================
-- 默认值提取
-- ========================================================================
ns.defaults = {}

local function CollectDefaults(optList)
    for _, opt in ipairs(optList) do
        if opt.type == "CheckBoxColor" then
            if opt.key and opt.cbDefault ~= nil then
                ns.defaults[opt.key] = opt.cbDefault
            end
            if opt.colorKey and opt.colorDefault ~= nil then
                ns.defaults[opt.colorKey] = opt.colorDefault
            end
        elseif opt.type == "CheckBoxSlider" then
            if opt.key and opt.cbDefault ~= nil then
                ns.defaults[opt.key] = opt.cbDefault
            end
            if opt.sliderKey and opt.sliderDefault ~= nil then
                ns.defaults[opt.sliderKey] = opt.sliderDefault
            end
        elseif opt.type == "CheckBoxDropdown" then
            if opt.key and opt.cbDefault ~= nil then
                ns.defaults[opt.key] = opt.cbDefault
            end
            if opt.dropdownKey and opt.dropdownDefault ~= nil then
                ns.defaults[opt.dropdownKey] = opt.dropdownDefault
            end
        elseif opt.type ~= "header" then
            if opt.key and opt.default ~= nil then
                ns.defaults[opt.key] = opt.default
            end
        end
    end
end

CollectDefaults(ns.ChatOptions)

-- 聊天条位置嵌套表默认值（两种定位模式各自独立存储）
ns.defaults.chatBarPosition = {
    FREE = { x = 0, y = 0 },
    ANCHOR = { x = 0, y = 0 },
}