-------------------------------------------------------------------
-- Addon: BloodlustPump
-- Author: Kongscandikk
-- Twitch: https://www.twitch.tv/kongscandikk
-- Version: 1.0.5
-------------------------------------------------------------------

local addonName, addonTable = ...
local addonPath = "Interface\\AddOns\\BloodlustPump\\"
local soundPath = addonPath .. "Sounds\\"
local imagePath = addonPath .. "Images\\"

-- 1. DATABASE AND VARIABLES
BloodlustpumpDB = BloodlustpumpDB or {}
local isLustActive, isTesting, isMoving = false, false, false
local isLoggingIn = true
local currentSessionPeak = 0
local needsReport = false
local musicHandle, delayTimer, ronnieFrames = nil, nil, {}
local currentFrame, animTimer, scanTimer = 0, 0, 0
local lustDuration, lastHaste = 40, 0
local category
local lastTriggerTime = 0
local PUMP_COOLDOWN = 60
local hasFiredThisCombat = false

local playing = false
local Volume = 100
local AmbienceVolume = 100

-- PROFILE CONFIGURATION
local pumperProfiles = {
    Ronnie = { 
        tex = "image1.blp", scream = "voice1.mp3", music = "music1.mp3",
        frames = 58, cols = 8, rows = 8, signature = "根本沒重量寶貝!", musicDelay = 0 
    },
    Arnold = { 
        tex = "image2.blp", scream = "voice2.mp3", music = "music2.mp3",
        frames = 64, cols = 8, rows = 8, signature = "保持飢餓!", musicDelay = 0
        },
    Zyzz = { 
        tex = "image3.blp", scream = "voice3.mp3", music = "music3.mp3",
        frames = 64, cols = 8, rows = 8, signature = "兄弟你在看我嗎?", musicDelay = 0 
    }
}

-- INITIALIZE DATABASE
local function InitDB(force)
    local savedPeak = BloodlustpumpDB.peakHaste or 0
    if force then 
        BloodlustpumpDB = {} 
        BloodlustpumpDB.peakHaste = savedPeak
    end
    
    BloodlustpumpDB.activeProfile = BloodlustpumpDB.activeProfile or "Ronnie"
    BloodlustpumpDB.layoutMode = BloodlustpumpDB.layoutMode or "Dual"
    BloodlustpumpDB.distFromCenter = BloodlustpumpDB.distFromCenter or 600 
    BloodlustpumpDB.yPos = BloodlustpumpDB.yPos or 278.6
    BloodlustpumpDB.size = BloodlustpumpDB.size or 320
    BloodlustpumpDB.opacity = BloodlustpumpDB.opacity or 1.0
    BloodlustpumpDB.text = BloodlustpumpDB.text or "嗜血開了寶貝!"
    BloodlustpumpDB.textScale = BloodlustpumpDB.textScale or 2.0
    BloodlustpumpDB.textY = BloodlustpumpDB.textY or 137
    BloodlustpumpDB.timerY = BloodlustpumpDB.timerY or -63
    BloodlustpumpDB.textColor = BloodlustpumpDB.textColor or {r = 1, g = 0.8, b = 0}
    BloodlustpumpDB.timerColor = BloodlustpumpDB.timerColor or {r = 1, g = 0, b = 0}
    BloodlustpumpDB.hasteThreshold = BloodlustpumpDB.hasteThreshold or 25.0
    BloodlustpumpDB.audioChannel = BloodlustpumpDB.audioChannel or "Master"
    BloodlustpumpDB.enableScream = (BloodlustpumpDB.enableScream == nil) and false or BloodlustpumpDB.enableScream -- 更改預設值
    BloodlustpumpDB.enableMusic = (BloodlustpumpDB.enableMusic == nil) and true or BloodlustpumpDB.enableMusic
    BloodlustpumpDB.enableChat = (BloodlustpumpDB.enableChat == nil) and true or BloodlustpumpDB.enableChat
    BloodlustpumpDB.peakHaste = BloodlustpumpDB.peakHaste or 0
end

-- 2. VISUAL UPDATES
local function UpdateVisuals()
    local showFrames = isLustActive or isTesting or isMoving
    local profile = pumperProfiles[BloodlustpumpDB.activeProfile]
    local isSingle = (BloodlustpumpDB.layoutMode == "Single")

    for i, f in ipairs(ronnieFrames) do
        if f then
            local currentAlpha = showFrames and (BloodlustpumpDB.opacity or 1) or 0
            if i == 2 and isSingle then
                f:SetAlpha(0)
            else
                f:SetAlpha(currentAlpha)
            end

            local xOff = BloodlustpumpDB.distFromCenter 
            if not isSingle then
                xOff = (i == 1) and -BloodlustpumpDB.distFromCenter or BloodlustpumpDB.distFromCenter
            end

            f:SetSize(BloodlustpumpDB.size or 400, BloodlustpumpDB.size or 400)
            f.text:SetText(BloodlustpumpDB.text or "")
            f.text:SetScale(BloodlustpumpDB.textScale or 1.8)
            local tc, mc = BloodlustpumpDB.textColor, BloodlustpumpDB.timerColor
            f.text:SetTextColor(tc.r or 1, tc.g or 0.8, tc.b or 0)
            f.timerText:SetTextColor(mc.r or 1, mc.g or 0, mc.b or 0)
            
            f:ClearAllPoints(); f:SetPoint("CENTER", UIParent, "CENTER", xOff, BloodlustpumpDB.yPos or 150)
            f.textFrame:SetPoint("CENTER", f, "CENTER", 0, BloodlustpumpDB.textY or 130)
            f.timerText:SetPoint("CENTER", f, "CENTER", 0, BloodlustpumpDB.timerY or -110)
            f.tex:SetTexture(imagePath .. profile.tex)
        end
    end
end

-- 3. HYPE UTILITIES
local function GetFormattedRecord(val)
    return "|cffdf8d20[" .. string.format("%.1f", val) .. "% 加速 1RM]|r"
end

local function Brag1RM()
    local peak = BloodlustpumpDB.peakHaste or 0
    local profile = pumperProfiles[BloodlustpumpDB.activeProfile]
    local msg = "[BloodlustPump]: 我目前的 1RM 是 " .. string.format("%.1f", peak) .. "% 加速! " .. profile.signature
    
    -- Send to RAID if in raid, PARTY if in group, otherwise just to your own chat
    local channel = (IsInRaid() and "RAID") or (IsInGroup() and "PARTY") or "SAY"
    SendChatMessage(msg, channel)
end

-- 4. TWITCH POPUP
StaticPopupDialogs["BLOODLUSTPUMP_COPY_LINK"] = {
    text = "Kongscandikk 的 Twitch 頻道:",
    button1 = "完成",
    hasEditBox = 1, editBoxWidth = 260,
    OnShow = function(self)
        local eb = _G[self:GetName().."EditBox"]
        if eb then eb:SetText("www.twitch.tv/kongscandikk"); eb:HighlightText(); eb:SetFocus() end
    end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}

-- 5. HASTE TRACKER
local function CheckHasteSpike()
    if isLustActive or isTesting or isMoving or isLoggingIn or hasFiredThisCombat then 
        local currentHaste = GetHaste()
        if isLustActive or isTesting then
            if currentHaste > currentSessionPeak then currentSessionPeak = currentHaste end
            if currentHaste > BloodlustpumpDB.peakHaste then
                BloodlustpumpDB.peakHaste = currentHaste
                if BloodlustpumpDB.enableChat and not isTesting then
                     print("|cffFFD700[BloodlustPump]:|r |cff00ff00新的 1RM 紀錄!|r 高峰值: |cffffffff" .. string.format("%.1f", currentHaste) .. "%|r")
                end
            end
        end
        return 
    end

    local currentHaste = GetHaste()
    local currentTime = GetTime()
    local spike = currentHaste - lastHaste
    
    if spike >= (BloodlustpumpDB.hasteThreshold or 25.0) and (currentTime - lastTriggerTime > 60) then
        lastTriggerTime = currentTime 
        isLustActive = true
        
        if UnitAffectingCombat("player") then hasFiredThisCombat = true end
        
        currentFrame = 0; lustDuration = 40; currentSessionPeak = currentHaste; UpdateVisuals()

        local profile = pumperProfiles[BloodlustpumpDB.activeProfile]
        if BloodlustpumpDB.enableChat then print("|cffFFD700[BloodlustPump]:|r 健身開始...") end
        
        if BloodlustpumpDB.enableScream then 
            PlaySoundFile(soundPath..profile.scream, BloodlustpumpDB.audioChannel); 
            delayTimer = profile.musicDelay
        elseif BloodlustpumpDB.enableMusic then 
            -- 檢查是否已經播放音樂
			if playing then return end
			Volume = tonumber(GetCVar("Sound_MusicVolume"))
			AmbienceVolume = tonumber(GetCVar("Sound_AmbienceVolume"))
			if BloodlustpumpDB.audioChannel ~= "Music" then
					SetCVar("Sound_MusicVolume", 0)
			end
			if BloodlustpumpDB.audioChannel ~= "Ambience" then
				SetCVar("Sound_AmbienceVolume", 0)
			end
			playing, musicHandle = PlaySoundFile(soundPath..profile.music, BloodlustpumpDB.audioChannel); 
            delayTimer = nil 
			
			C_Timer.After(40, function()
				SetCVar("Sound_MusicVolume", Volume)
				SetCVar("Sound_AmbienceVolume", AmbienceVolume)
				playing = false
			end)
        end
    end
    
    lastHaste = currentHaste
end

-- 6. SETTINGS MENU
local function CreateSettingsMenu()
    local panel = CreateFrame("Frame", "BloodlustpumpSettingsPanel", UIParent)
    panel.name = "嗜血"; local refreshFunctions = {}
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("TOPLEFT", 20, -25); title:SetText("嗜血引擎"); title:SetScale(1.5)

    local subTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightMedium")
    subTitle:SetPoint("LEFT", title, "RIGHT", 12, -2); subTitle:SetFont(STANDARD_TEXT_FONT, 12, "ITALIC")
    subTitle:SetText("- 專為狂熱猛男的最佳化設計"); subTitle:SetTextColor(0.7, 0.7, 0.7)

    local line = panel:CreateTexture(nil, "ARTWORK")
    line:SetSize(580, 1); line:SetPoint("TOPLEFT", 20, -75); line:SetColorTexture(1, 1, 1, 0.1)

    local btnY = -105
    local moveBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    moveBtn:SetSize(130, 26); moveBtn:SetPoint("TOPLEFT", 20, btnY); moveBtn:SetText("打開版面配置")
    moveBtn.tooltipText = "持續顯示嗜血框架以調整其在螢幕上的位置。"
    moveBtn:SetScript("OnClick", function(self) isMoving = not isMoving; self:SetText(isMoving and "鎖定版面配置" or "打開版面配置"); UpdateVisuals() end)

    local testBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    testBtn:SetSize(130, 26); testBtn:SetPoint("LEFT", moveBtn, "RIGHT", 10, 0); testBtn:SetText("測試嗜血效果")
    testBtn.tooltipText = "模擬加速高峰值以查看動畫並聆聽音樂。"
    testBtn:SetScript("OnClick", function(self) 
        isTesting = not isTesting
        if isTesting then isMoving, currentFrame, lustDuration = false, 0, 40
            local profile = pumperProfiles[BloodlustpumpDB.activeProfile]
            if BloodlustpumpDB.enableScream then PlaySoundFile(soundPath..profile.scream, BloodlustpumpDB.audioChannel); delayTimer = profile.musicDelay
            elseif BloodlustpumpDB.enableMusic then
				-- 檢查是否已經播放音樂
				if playing then return end
				Volume = tonumber(GetCVar("Sound_MusicVolume"))
				AmbienceVolume = tonumber(GetCVar("Sound_AmbienceVolume"))
				if BloodlustpumpDB.audioChannel ~= "Music" then
					SetCVar("Sound_MusicVolume", 0)
				end
				if BloodlustpumpDB.audioChannel ~= "Ambience" then
					SetCVar("Sound_AmbienceVolume", 0)
				end
				playing, musicHandle = PlaySoundFile(soundPath..profile.music, BloodlustpumpDB.audioChannel); 
				delayTimer = nil 

				C_Timer.After(40, function()
					SetCVar("Sound_MusicVolume", Volume)
					SetCVar("Sound_AmbienceVolume", AmbienceVolume)
					playing = false
				end)
			end
            self:SetText("停止")
        else 
			self:SetText("測試嗜血效果");
			if musicHandle then StopSound(musicHandle);
			musicHandle = nil end; 
			delayTimer = nil
			if playing then
				SetCVar("Sound_MusicVolume", Volume)
				SetCVar("Sound_AmbienceVolume", AmbienceVolume)
				playing = false
			end
		end
        UpdateVisuals()
    end)

    -- 1RM Display (Top Right)
    local pbDisplay = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    pbDisplay:SetPoint("TOPRIGHT", -25, btnY - 5)
    pbDisplay:SetTextColor(0.87, 0.55, 0.12) -- Legendary Orange

    local flexBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    flexBtn:SetSize(80, 22)
    flexBtn:SetPoint("TOPRIGHT", -25, btnY - 5)
    flexBtn:SetText("秀肌肉")
    flexBtn.tooltipText = "向你的隊伍或團隊炫耀你的歷史最高加速高峰值。"
    flexBtn:SetScript("OnClick", function() Brag1RM() end)

    local pbDisplay = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    pbDisplay:SetPoint("RIGHT", flexBtn, "LEFT", -12, 0)
    pbDisplay:SetTextColor(0.87, 0.55, 0.12) -- Legendary Orange

    table.insert(refreshFunctions, function() 
        pbDisplay:SetText("加速 1RM: " .. string.format("%.1f", BloodlustpumpDB.peakHaste) .. "%") 
    end)

        local cbScream = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    cbScream.Text:SetText("啟用語音")
    cbScream.tooltipText = "播放傳奇音效。"
    cbScream:SetScript("OnClick", function(self) BloodlustpumpDB.enableScream = self:GetChecked() end)
    table.insert(refreshFunctions, function() cbScream:SetChecked(BloodlustpumpDB.enableScream) end)

    local cbMusic = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    cbMusic.Text:SetText("啟用音樂")
    cbMusic.tooltipText = "在爆發期間播放健身音樂。"
    cbMusic:SetScript("OnClick", function(self) BloodlustpumpDB.enableMusic = self:GetChecked() end)
    table.insert(refreshFunctions, function() cbMusic:SetChecked(BloodlustpumpDB.enableMusic) end)

    local cbChat = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    cbChat.Text:SetText("聊天記錄")
    cbChat.tooltipText = "切換聊天視窗中的診斷訊息。"
    cbChat:SetScript("OnClick", function(self) BloodlustpumpDB.enableChat = self:GetChecked() end)
    table.insert(refreshFunctions, function() cbChat:SetChecked(BloodlustpumpDB.enableChat) end)

    local rowY = btnY - 70

    -- 1. LEGEND DROPDOWN
    local sectionProfiles = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    sectionProfiles:SetPoint("TOPLEFT", 20, rowY); sectionProfiles:SetText("選擇你的傳奇")

    local profileDD = CreateFrame("Frame", "BLP_ProfileDD", panel, "UIDropDownMenuTemplate")
    profileDD:SetPoint("TOPLEFT", sectionProfiles, "BOTTOMLEFT", -15, -2)
    UIDropDownMenu_SetWidth(profileDD, 90)
    UIDropDownMenu_Initialize(profileDD, function(self)
        for _, name in ipairs({"Ronnie", "Arnold", "Zyzz"}) do
            local info = UIDropDownMenu_CreateInfo()
            info.text, info.value, info.func = name, name, function(s) BloodlustpumpDB.activeProfile = s.value; UIDropDownMenu_SetText(profileDD, s.value); UpdateVisuals() end
            info.checked = (name == BloodlustpumpDB.activeProfile); UIDropDownMenu_AddButton(info)
        end
    end)
    table.insert(refreshFunctions, function() UIDropDownMenu_SetText(profileDD, BloodlustpumpDB.activeProfile) end)

    -- 2. AUDIO CHANNEL DROPDOWN
    local sectionAudio = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    sectionAudio:SetPoint("LEFT", sectionProfiles, "LEFT", 135, 0); sectionAudio:SetText("音效頻道")

    local dropdown = CreateFrame("Frame", "BLP_ChanDD", panel, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", sectionAudio, "BOTTOMLEFT", -15, -2)
    UIDropDownMenu_SetWidth(dropdown, 85)
    UIDropDownMenu_Initialize(dropdown, function(self)
        -- Manual mapping for translation while keeping internal values
        local channelMap = {Master="主聲道", SFX="音效", Music="音樂", Ambience="環境音", Dialog="對話"}
        for _, c in ipairs({"Master", "SFX", "Music", "Ambience", "Dialog"}) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channelMap[c] or c
            info.value = c
            info.func = function(s) BloodlustpumpDB.audioChannel = s.value; UIDropDownMenu_SetText(dropdown, channelMap[s.value] or s.value) end
            info.checked = (c == BloodlustpumpDB.audioChannel); UIDropDownMenu_AddButton(info)
        end
    end)
    table.insert(refreshFunctions, function() 
        local c = BloodlustpumpDB.audioChannel
        local channelMap = {Master="主聲道", SFX="音效", Music="音樂", Ambience="環境音", Dialog="對話"}
        UIDropDownMenu_SetText(dropdown, channelMap[c] or c) 
    end)

    -- 3. LAYOUT MODE DROPDOWN
    local sectionLayout = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    sectionLayout:SetPoint("LEFT", sectionAudio, "LEFT", 125, 0); sectionLayout:SetText("版面配置")

    local layoutDD = CreateFrame("Frame", "BLP_LayoutDD", panel, "UIDropDownMenuTemplate")
    layoutDD:SetPoint("TOPLEFT", sectionLayout, "BOTTOMLEFT", -15, -2)
    UIDropDownMenu_SetWidth(layoutDD, 75)
    UIDropDownMenu_Initialize(layoutDD, function(self)
        local layoutMap = {Single="單一", Dual="雙重"}
        for _, mode in ipairs({"Single", "Dual"}) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = layoutMap[mode] or mode
            info.value = mode
            info.func = function(s) BloodlustpumpDB.layoutMode = s.value; UIDropDownMenu_SetText(layoutDD, layoutMap[s.value] or s.value); for _, f in ipairs(refreshFunctions) do f() end; UpdateVisuals() end
            info.checked = (mode == BloodlustpumpDB.layoutMode); UIDropDownMenu_AddButton(info)
        end
    end)
    table.insert(refreshFunctions, function() 
        local m = BloodlustpumpDB.layoutMode or "Dual"
        local layoutMap = {Single="單一", Dual="雙重"}
        UIDropDownMenu_SetText(layoutDD, layoutMap[m] or m) 
    end)

    cbScream:SetPoint("TOPLEFT", profileDD, "BOTTOMLEFT", 20, -10)
    cbMusic:SetPoint("TOPLEFT", cbScream, "TOPLEFT", 140, 0)
    cbChat:SetPoint("TOPLEFT", cbMusic, "TOPLEFT", 140, 0)

    -- 4. COLOR PICKER BUTTONS
    local function OpenPicker(dbKey)
        local color = BloodlustpumpDB[dbKey]
        ColorPickerFrame:SetupColorPickerAndShow({
            swatchFunc = function() 
                local r, g, b = ColorPickerFrame:GetColorRGB(); 
                BloodlustpumpDB[dbKey] = {r = r, g = g, b = b}; 
                UpdateVisuals() 
            end,
            r = color.r, g = color.g, b = color.b, hasOpacity = false
        })
    end
    
    local txtColBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    txtColBtn:SetSize(85, 22); txtColBtn:SetPoint("LEFT", layoutDD, "RIGHT", 5, 2); txtColBtn:SetText("文字顏色")
    txtColBtn.tooltipText = "更改 '嗜血開了' 標題文字的顏色。"
    txtColBtn:SetScript("OnClick", function() OpenPicker("textColor") end)

    local timColBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    timColBtn:SetSize(100, 22); timColBtn:SetPoint("LEFT", txtColBtn, "RIGHT", 5, 0); timColBtn:SetText("計時器顏色")
    timColBtn.tooltipText = "更改倒數計時器文字的顏色。"
    timColBtn:SetScript("OnClick", function() OpenPicker("timerColor") end)

    local section2 = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    section2:SetPoint("TOPLEFT", 20, btnY - 195); section2:SetText("視覺校準")

    local function NewSlider(n, l, min, max, k, x, y, tip)
        local s = CreateFrame("Slider", n, panel, "OptionsSliderTemplate")
        s:SetPoint("TOPLEFT", 20 + x, btnY - 235 + y); s:SetMinMaxValues(min, max); s:SetObeyStepOnDrag(true); s:SetSize(180, 18); s.tooltipText = tip
        
        local isPrecision = (k == "opacity" or k == "textScale")
        s:SetValueStep(isPrecision and 0.1 or 1)
        
        local eb = CreateFrame("EditBox", nil, panel, "InputBoxTemplate"); eb:SetSize(40, 18); eb:SetPoint("LEFT", s, "RIGHT", 10, 0); eb:SetAutoFocus(false)
        eb:SetScript("OnEnterPressed", function(self) local v = tonumber(self:GetText()); if v then BloodlustpumpDB[k] = math.min(max, math.max(min, v)); s:SetValue(v); UpdateVisuals() end; self:ClearFocus() end)
        
        s:SetScript("OnValueChanged", function(_, v) 
            if s:IsMouseOver() then 
                local val = isPrecision and tonumber(string.format("%.1f", v)) or tonumber(string.format("%.0f", v))
                BloodlustpumpDB[k] = val; eb:SetText(val); UpdateVisuals() 
            end 
        end)
        
        table.insert(refreshFunctions, function() 
            s:SetValue(BloodlustpumpDB[k]); eb:SetText(BloodlustpumpDB[k]); 
            local label = l
            if k == "distFromCenter" then
                label = (BloodlustpumpDB.layoutMode == "Single") and "水平位置" or "框架間距"
            end
            _G[s:GetName()..'Text']:SetText(label) 
        end)
    end
    
    NewSlider("BLP_T", "觸發加速 %", 5, 50, "hasteThreshold", 0, 0, "啟動所需的高峰值。")
    NewSlider("BLP_S", "圖片大小", 0, 800, "size", 260, 0, "Ronnie/Arnold 有多大。")
    NewSlider("BLP_D", "框架間距", -1200, 1200, "distFromCenter", 0, -45, "水平移動。")
    NewSlider("BLP_Y", "垂直高度", -500, 500, "yPos", 260, -45, "上下移動框架。")
    NewSlider("BLP_TY", "文字垂直位置", -500, 500, "textY", 0, -90, "標題位置。")
    NewSlider("BLP_RY", "計時器垂直位置", -500, 500, "timerY", 260, -90, "計時器位置。")
    NewSlider("BLP_SC", "文字縮放大小", 0.1, 5, "textScale", 0, -135, "調整文字大小。")
    NewSlider("BLP_OP", "不透明度", 0, 1, "opacity", 260, -135, "設定透明度。")

    local resetAllBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetAllBtn:SetSize(105, 24); resetAllBtn:SetPoint("BOTTOMLEFT", 20, 28); resetAllBtn:SetText("重置預設值")
    resetAllBtn.tooltipText = "重置所有設定為預設值。間距將恢復為 600。"
    resetAllBtn:SetScript("OnClick", function() InitDB(true); for _, f in ipairs(refreshFunctions) do f() end; UpdateVisuals() end)

    local resetPBBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetPBBtn:SetSize(105, 24); resetPBBtn:SetPoint("LEFT", resetAllBtn, "RIGHT", 5, 0); resetPBBtn:SetText("重置 1RM")
    resetPBBtn.tooltipText = "清除你的歷史最高加速高峰值記錄 (1RM)。"
    resetPBBtn:SetScript("OnClick", function() BloodlustpumpDB.peakHaste = 0; for _, f in ipairs(refreshFunctions) do f() end; print("|cffFFD700[BloodlustPump]:|r 記錄已清除。") end)

    local shareAddonBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    shareAddonBtn:SetSize(105, 24); shareAddonBtn:SetPoint("LEFT", resetPBBtn, "RIGHT", 5, 0); shareAddonBtn:SetText("分享插件")
    shareAddonBtn.tooltipText = "與你目前的隊伍或團隊分享插件下載連結。"
    shareAddonBtn:SetScript("OnClick", function() 
        local link = "https://www.curseforge.com/wow/addons/bloodlustpump"
        SendChatMessage("[BloodlustPump]: 追蹤你的 1RM 加速高峰值！下載： " .. link, (IsInRaid() and "RAID") or (IsInGroup() and "PARTY") or "SAY")
    end)

    local creditBtn = CreateFrame("Button", nil, panel)
    creditBtn:SetSize(320, 40); creditBtn:SetPoint("BOTTOMRIGHT", -20, 20)
    creditBtn.prefix = creditBtn:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    creditBtn.prefix:SetText("由 Kongscandikk 100% 激情編碼"); creditBtn.prefix:SetTextColor(1, 0.82, 0, 0.7) 
    creditBtn.name = creditBtn:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    creditBtn.name:SetText(""); creditBtn.name:SetTextColor(0.776, 0.608, 0.427); creditBtn.name:SetAlpha(0.7); creditBtn.name:SetPoint("RIGHT", creditBtn, "RIGHT")
    creditBtn.prefix:SetPoint("RIGHT", creditBtn.name, "LEFT", -5, 0)
    creditBtn:SetScript("OnEnter", function(self) self.prefix:SetAlpha(1.0); self.prefix:SetTextColor(1, 1, 1) end)
    creditBtn:SetScript("OnLeave", function(self) self.prefix:SetAlpha(0.7); self.prefix:SetTextColor(1, 0.82, 0, 0.7) end)
    creditBtn:SetScript("OnClick", function() StaticPopup_Show("BLOODLUSTPUMP_COPY_LINK") end)

    panel:SetScript("OnShow", function() for _, f in ipairs(refreshFunctions) do f() end end)
    category = Settings.RegisterCanvasLayoutCategory(panel, "嗜血")
    Settings.RegisterAddOnCategory(category)
end

-- 7. CORE ENGINE
local core = CreateFrame("Frame")
core:RegisterEvent("PLAYER_LOGIN")
core:RegisterEvent("PLAYER_REGEN_ENABLED")
core:RegisterEvent("PLAYER_ENTERING_WORLD")

core:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then 
        InitDB(); lastHaste = GetHaste(); isLoggingIn = true; CreateSettingsMenu()
        C_Timer.After(5, function() isLoggingIn = false end)
        for i=1,2 do 
            local f = CreateFrame("Frame", "BLP_F"..i, UIParent); f:SetSize(400, 400); f:SetAlpha(0)
            f.textFrame = CreateFrame("Frame", nil, f); f.textFrame:SetSize(400, 50)
            f.text = f.textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge"); f.text:SetPoint("CENTER")
            f.timerText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge"); f.timerText:SetPoint("CENTER", 0, -110); f.timerText:SetScale(2.2)
            f.tex = f:CreateTexture(nil, "OVERLAY"); f.tex:SetAllPoints()
            ronnieFrames[i] = f
        end
        UpdateVisuals()
    elseif event == "PLAYER_ENTERING_WORLD" then
        lastHaste = GetHaste() 
    elseif event == "PLAYER_REGEN_ENABLED" then
        hasFiredThisCombat = false 
        
        if needsReport then
            C_Timer.After(0.1, function()
                local prof = pumperProfiles[BloodlustpumpDB.activeProfile]
                print("|cffFFD700[BloodlustPump]:|r 健身總結:")
                print(">> 高峰值 1RM: " .. GetFormattedRecord(currentSessionPeak))
                if currentSessionPeak >= BloodlustpumpDB.peakHaste then 
                    print("|cff00ff00創下新紀錄!|r " .. prof.signature) 
                end
                needsReport = false; currentSessionPeak = 0
            end)
        end
    end
end)

core:SetScript("OnUpdate", function(self, elapsed)
    scanTimer = scanTimer + elapsed
    if scanTimer > 0.2 then CheckHasteSpike(); scanTimer = 0 end
    
    if isLustActive or isTesting or isMoving then

        animTimer = animTimer + elapsed
        local profile = pumperProfiles[BloodlustpumpDB.activeProfile]
        local frameRate = (1 / 30) 

        if BloodlustpumpDB.activeProfile == "Arnold" then 
            frameRate = (5 / 64) 
        elseif BloodlustpumpDB.activeProfile == "Zyzz" then 
            frameRate = (0.775 / 64) 
        end
        
        if animTimer > frameRate then
            local r = math.floor(currentFrame / profile.cols)
            local c = currentFrame % profile.cols
            local x1, x2 = c * (1 / profile.cols), (c + 1) * (1 / profile.cols)
            local y1, y2 = r * (1 / profile.rows), (r + 1) * (1 / profile.rows)
            for _, f in ipairs(ronnieFrames) do if f then f.tex:SetTexCoord(x1, x2, y1, y2) end end
            currentFrame = (currentFrame + 1) % profile.frames
            animTimer = 0; UpdateVisuals()
        end

        if not isMoving then
            lustDuration = math.max(0, lustDuration - elapsed)
            for _, f in ipairs(ronnieFrames) do if f then f.timerText:SetText(string.format("%.1f", lustDuration)) end end
            if lustDuration <= 0 and not isTesting then 
                isLustActive = false; 
                needsReport = true; 
                if musicHandle then StopSound(musicHandle); musicHandle = nil end; 
                UpdateVisuals() 
            end
        else 
            for _, f in ipairs(ronnieFrames) do if f then f.timerText:SetText("40.0") end end 
        end
    end

    if delayTimer then
        delayTimer = delayTimer - elapsed
        if delayTimer <= 0 then 
            if (isLustActive or isTesting) and BloodlustpumpDB.enableMusic then 
                local profile = pumperProfiles[BloodlustpumpDB.activeProfile]
                _, musicHandle = PlaySoundFile(soundPath..profile.music, BloodlustpumpDB.audioChannel) 
            end
            delayTimer = nil 
        end
    end
end)

SLASH_BLOODLUSTPUMP1 = "/blp"
SlashCmdList["BLOODLUSTPUMP"] = function() if category and category:GetID() then Settings.OpenToCategory(category:GetID()) end end