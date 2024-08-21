local W, M, U, D, G, L, E, API, LOG = unpack((select(2, ...)))
local OPT = {}
M.OPT = OPT

local C_AddOns_IsAddOnLoaded = API.C_AddOns_IsAddOnLoaded
local GetAddOnMemoryUsage = API.GetAddOnMemoryUsage
local C_AddOns_GetAddOnEnableState = API.C_AddOns_GetAddOnEnableState

local settings = { -- 預設值
    showChat = true,
    showChannel = true,
    showTime = true,
    showbg = false,
    enableIL_zh = true,
    noFade = false,
	keepHistory =  true,
	showLines = 7
}


local options = CreateFrame("FRAME")
options.name = L['InputInput']
options:Hide()

local texture = options:CreateTexture(nil, "BACKGROUND")
texture:SetPoint("RIGHT", options, "RIGHT", -50, 0)
texture:SetTexture("Interface/AddOns/InputInput/Media/pet_type_dragon")
texture:SetSize(150, 150)

local title = options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", options, "TOPLEFT", 20, -20)
title:SetText(L['Input Input'].." "..W.colorName)
local font, fontsize, flags = title:GetFont()
---@diagnostic disable-next-line: param-type-mismatch
title:SetFont(font, 28, flags)

local button = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
button:SetSize(120, 25)
button:SetPoint("TOPRIGHT", options, "TOPRIGHT", -20, -20)
button:SetText(L['Default Setting'])

if Settings and Settings.RegisterCanvasLayoutCategory then
    local category, layout = Settings.RegisterCanvasLayoutCategory(options, options.name);
    Settings.RegisterAddOnCategory(category);
    options.settingcategory = category
else
    InterfaceOptions_AddCategory(options)
end

-- 添加命令来打开设置页面
SLASH_INPUTINPUT1 = "/InputInput"
SLASH_INPUTINPUT2 = "/II"

local function OpenSettingsPanel()
    if Settings and SettingsPanel then
        Settings.OpenToCategory(options.settingcategory.ID)
    else
        InterfaceOptionsFrame_OpenToCategory(options)

        InterfaceOptionsFrame_OpenToCategory(options)
    end
end

SlashCmdList["INPUTINPUT"] = OpenSettingsPanel

local function changeSetting()
    M.MAIN:HideChat(settings.showChat)
    M.MAIN:HideChannel(settings.showChannel)
    M.MAIN:HideTime(settings.showTime)
    M.MAIN:Hidebg(settings.showbg)
    M.MAIN:NoFade(settings.noFade)
    M.MAIN:KeepHistory(settings.keepHistory)
    M.MAIN:ShowLines(settings.showLines)
    M.MAIN:EnableIL_zh(settings.enableIL_zh)
end

---@param addonName string
---@return string
local function GetAddonMemory(addonName)
    -- 获取插件的内存占用（以 KB 为单位）
    local memoryUsage = GetAddOnMemoryUsage(addonName)
    -- 转换为 MB（可选）
    local memoryUsageMB = memoryUsage / 1024
    if memoryUsageMB == 0 then
        return ''
    else
        return '(' .. math.floor(memoryUsageMB) .. 'MB)'
    end
end

function OPT:loadOPT()
    settings = D:ReadDB("settings", settings)
    settings.enableIL_zh = C_AddOns_GetAddOnEnableState("InputInput_Libraries_zh") == 2
    -- Show Chat 显示聊天
    local showChat = CreateFrame("CheckButton", W.N .. "showChat", options,
        "InterfaceOptionsCheckButtonTemplate")
    showChat:SetPoint("TOPLEFT", 16, -66)
    showChat.Text:SetText(L['Show Chat'])
    showChat:SetChecked(settings.showChat)

    -- 时间戳
    local showTime = CreateFrame("CheckButton", W.N .. "showTime", options,
        "InterfaceOptionsCheckButtonTemplate")
    showTime:SetPoint("TOPLEFT", 32, -98)
    showTime.Text:SetText(L['Show Timestamp'])
    showTime:SetChecked(settings.showTime)

    -- 聊天消息背景
    local showbg = CreateFrame("CheckButton", W.N .. "showbg", options,
        "InterfaceOptionsCheckButtonTemplate")
    showbg:SetPoint("TOPLEFT", 32, -130)
    showbg.Text:SetText(L['Show bg'])
    showbg:SetChecked(settings.showbg)
	
	-- 不要淡出
	local noFade = CreateFrame("CheckButton", W.N .. "noFade", options,
        "InterfaceOptionsCheckButtonTemplate")
    noFade:SetPoint("TOPLEFT", 32, -162)
    noFade.Text:SetText(L['No Fading'])
    noFade:SetChecked(settings.noFade)
	
	-- 永久保存
	local keepHistory = CreateFrame("CheckButton", W.N .. "keepHistory", options,
        "InterfaceOptionsCheckButtonTemplate")
    keepHistory:SetPoint("TOPLEFT", 32, -194)
    keepHistory.Text:SetText(L['Keep Chat History'])
    keepHistory:SetChecked(settings.keepHistory)	
	
	-- 要顯示幾行訊息
	local showLines = CreateFrame("Slider", W.N .. "showLines", options, "OptionsSliderTemplate")
	showLines:SetPoint("TOPLEFT", 32 , -252)
	showLines:SetWidth(200)
	showLines:SetHeight(20)
	showLines:SetMinMaxValues(7, 30)
	showLines:SetValue(settings.showLines and settings.showLines or 7)
	showLines:SetValueStep(1)
	showLines:SetObeyStepOnDrag(true)
	showLines.Text:SetText(format(L["Show %d messages"], settings.showLines or 7))
	showLines.Low:SetText("7")
	showLines.High:SetText("30")
	
	-- 显示频道名称
    local showChannel = CreateFrame("CheckButton", W.N .. "showChannel", options,
        "InterfaceOptionsCheckButtonTemplate")
    showChannel:SetPoint("TOPLEFT", 16, -304)
    showChannel.Text:SetText(L['Show channel Name'])
    showChannel:SetChecked(settings.showChannel)

    -- 启用|cff409EFF|cffF56C6Ci|rnput|cffF56C6Ci|rnput|r_Libraries_|cffF56C6Czh|r
    local enableIL_zh = CreateFrame("CheckButton", W.N .. "enableIL_zh", options,
        "InterfaceOptionsCheckButtonTemplate")
    enableIL_zh:SetPoint("TOPLEFT", 16, -336)
    -- enableIL_zh.Text:SetText(format(L['Enable InputInput_Libraries_zh'],
    --     'InputInput_Libraries_zh'))
    -- enableIL_zh:Hide()

    -- 添加鼠标提示的显示和隐藏事件
    enableIL_zh:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")                                                       -- 设置提示框的位置
        GameTooltip:SetText(L['Chinese word processing module can make input prompts more intelligent']) -- 设置提示框的内容
        GameTooltip:Show()                                                                               -- 显示提示框
    end)

    enableIL_zh:SetScript("OnLeave", function(self)
        GameTooltip:Hide() -- 隐藏提示框
    end)

    options:SetScript("OnShow", function(self)
        UpdateAddOnMemoryUsage()
        enableIL_zh.Text:SetText(format(L['Enable InputInput_Libraries_zh'],
            C_AddOns.IsAddOnLoaded('InputInput_Libraries_zh') and ('|cff409EFF|cffF56C6Ci|rnput|cffF56C6Ci|rnput|r_Libraries_|cffF56C6Czh|r' .. ' |cFF909399' .. GetAddonMemory('InputInput_Libraries_zh')) or ' |cFF909399') ..
			' (' .. L['Need To Reload'] .. ')|r')
        settings.enableIL_zh = C_AddOns_GetAddOnEnableState("InputInput_Libraries_zh") == 2
        enableIL_zh:SetChecked(settings.enableIL_zh)
    end)

    changeSetting()

    showChat:SetScript("OnClick", function(self)
        settings.showChat = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
        if settings.showChat then
            showTime:Show()
            showbg:Show()
			noFade:Show()
            keepHistory:Show()
            showLines:Show()
            showChannel:SetPoint("TOPLEFT", 16, -304)
            enableIL_zh:SetPoint("TOPLEFT", 16, -336)
        else
            showTime:Hide()
            showbg:Hide()
			noFade:Hide()
            keepHistory:Hide()
            showLines:Hide()
            showChannel:SetPoint("TOPLEFT", 16, -98)
            enableIL_zh:SetPoint("TOPLEFT", 16, -136)
        end
    end)
    showChannel:SetScript("OnClick", function(self)
        settings.showChannel = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
    end)
    showTime:SetScript("OnClick", function(self)
        settings.showTime = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
    end)
	showbg:SetScript("OnClick", function(self)
        settings.showbg = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
    end)
    enableIL_zh:SetScript("OnClick", function(self)
        settings.enableIL_zh = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
    end)
    noFade:SetScript("OnClick", function(self)
        settings.noFade = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
    end)
	keepHistory:SetScript("OnClick", function(self)
        settings.keepHistory = self:GetChecked()
        D:SaveDB("settings", settings)
        changeSetting()
    end)
	showLines:SetScript("OnValueChanged", function(self, value)
	    settings.showLines = value
        D:SaveDB("settings", settings)
        changeSetting()
		
		showLines.Text:SetText(format(L["Show %d messages"], value))
	end)

    button:SetScript("OnClick", function()
        settings = {
            showChat = true,
            showChannel = true,
            showTime = true,
            showbg = false,
            enableIL_zh = true,
            showbg = true,
            noFade = false,
            keepHistory = true,
            showLines = 7,
        }
        D:SaveDB("settings", settings)
        changeSetting()
        showChat:SetChecked(settings.showChat)
        if settings.showChat then
            showTime:Show()
            showbg:Show()
            noFade:Show()
            keepHistory:Show()
            showLines:Show()
            showChannel:SetPoint("TOPLEFT", 16, -304)
            enableIL_zh:SetPoint("TOPLEFT", 16, -336)
        else
            showTime:Hide()
            showbg:Hide()
			noFade:Hide()
            keepHistory:Hide()
            showLines:Hide()
            showChannel:SetPoint("TOPLEFT", 16, -98)
            enableIL_zh:SetPoint("TOPLEFT", 16, -136)
        end
        showTime:SetChecked(settings.showTime)
        showbg:SetChecked(settings.showbg)
        showChannel:SetChecked(settings.showChannel)
        enableIL_zh:SetChecked(settings.enableIL_zh)
        noFade:SetChecked(settings.noFade)
        keepHistory:SetChecked(settings.keepHistory)
        showLines:SetValue(settings.showLines)
		showLines.Text:SetText(format(L["Show %d messages"], settings.showLines or 7))
    end)
end
