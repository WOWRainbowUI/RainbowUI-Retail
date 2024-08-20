local N, T = ...
local W, M, U, D, G, L, E = unpack(T)
local OPT = {}
M.OPT = OPT

local settings = { -- 預設值
    showChat = true,
    showChannel = true,
    showTime = true,
    showbg = true,
	noFade = false,
	keepHistory =  true,
	showLines = 7
}


local options = CreateFrame("FRAME")
options.name = L['InputInput']
options:Hide()

local texture = options:CreateTexture(nil, "BACKGROUND")
texture:SetPoint("RIGHT", options, "RIGHT", -50, 0)
texture:SetTexture("Interface/ICONS/pet_type_dragon")
texture:SetSize(150, 150)

local title = options:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", options, "TOPLEFT", 20, -20)
title:SetText(L['Input Input'])
local font, fontsize, flags = title:GetFont()
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
    ---@diagnostic disable-next-line: undefined-global
    InterfaceOptions_AddCategory(options)
end

-- 添加命令来打开设置页面
SLASH_INPUTINPUT1 = "/InputInput"
SLASH_INPUTINPUT2 = "/II"

local function OpenSettingsPanel()
    if Settings and SettingsPanel then
        Settings.OpenToCategory(options.settingcategory.ID)
    else
        ---@diagnostic disable-next-line: undefined-global
        InterfaceOptionsFrame_OpenToCategory(options)
        ---@diagnostic disable-next-line: undefined-global
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
end

function OPT:loadOPT()
    settings = D:ReadDB("settings", settings)

    -- 初始化和加载设置
    -- Show Chat 显示聊天
    local showChat = CreateFrame("CheckButton", N .. "showChat", options,
        "InterfaceOptionsCheckButtonTemplate")
    showChat:SetPoint("TOPLEFT", 16, -66)
    showChat.Text:SetText(L['Show Chat'])
    showChat:SetChecked(settings.showChat)

    -- 初始化和加载设置
    -- Show channel Name 时间戳
    local showTime = CreateFrame("CheckButton", N .. "showTime", options,
        "InterfaceOptionsCheckButtonTemplate")
    showTime:SetPoint("TOPLEFT", 32, -98)
    showTime.Text:SetText(L['Show Timestamp'])
    showTime:SetChecked(settings.showTime)

    -- 初始化和加载设置
    -- Show channel Name 聊天消息背景
    local showbg = CreateFrame("CheckButton", N .. "showbg", options,
        "InterfaceOptionsCheckButtonTemplate")
    showbg:SetPoint("TOPLEFT", 32, -130)
    showbg.Text:SetText(L['Show bg'])
    showbg:SetChecked(settings.showbg)
	
	-- 不要淡出
	local noFade = CreateFrame("CheckButton", N .. "noFade", options,
        "InterfaceOptionsCheckButtonTemplate")
    noFade:SetPoint("TOPLEFT", 32, -162)
    noFade.Text:SetText(L['No Fading'])
    noFade:SetChecked(settings.noFade)
	
	-- 永久保存
	local keepHistory = CreateFrame("CheckButton", N .. "keepHistory", options,
        "InterfaceOptionsCheckButtonTemplate")
    keepHistory:SetPoint("TOPLEFT", 32, -194)
    keepHistory.Text:SetText(L['Keep Chat History'])
    keepHistory:SetChecked(settings.keepHistory)

    -- 初始化和加载设置
    -- Show channel Name 显示频道名称
    local showChannel = CreateFrame("CheckButton", N .. "showChannel", options,
        "InterfaceOptionsCheckButtonTemplate")
    showChannel:SetPoint("TOPLEFT", 16, -304)
    showChannel.Text:SetText(L['Show channel Name'])
    showChannel:SetChecked(settings.showChannel)
	
	
	-- 要顯示幾行訊息
	local showLines = CreateFrame("Slider", N .. "showLines", options, "OptionsSliderTemplate")
	showLines:SetPoint("TOPLEFT", 32 , -252)
	showLines:SetWidth(200)
	showLines:SetHeight(20)
	showLines:SetMinMaxValues(7, 30)
	showLines:SetValue(settings.showLines and settings.showLines or 7)
	showLines:SetValueStep(1)
	showLines:SetObeyStepOnDrag(true)
	showLines.Text:SetText(string.format(L["Show %d messages"], settings.showLines or 7))
	showLines.Low:SetText("7")
	showLines.High:SetText("30")
	
	showLines:SetScript("OnValueChanged", function(self, value)
	    settings.showLines = value
        D:SaveDB("settings", settings)
        changeSetting()
		
		showLines.Text:SetText(string.format(L["Show %d messages"], value))
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
        else
            showTime:Hide()
            showbg:Hide()
			noFade:Hide()
            keepHistory:Hide()
            showLines:Hide()
            showChannel:SetPoint("TOPLEFT", 16, -98)
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

    button:SetScript("OnClick", function()
        settings = {
            showChat = true,
            showChannel = true,
            showTime = true,
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
        else
            showTime:Hide()
            showbg:Hide()
			noFade:Hide()
            keepHistory:Hide()
            showLines:Hide()
            showChannel:SetPoint("TOPLEFT", 16, -98)
        end
        showTime:SetChecked(settings.showTime)
        showbg:SetChecked(settings.showbg)
        showChannel:SetChecked(settings.showChannel)
        noFade:SetChecked(settings.noFade)
        keepHistory:SetChecked(settings.keepHistory)
        showLines:SetValue(settings.showLines)
		showLines.Text:SetText(string.format(L["Show %d messages"], settings.showLines or 7))
    end)
end
