local addonName, ns = ...
local L = ns.L

-- ========================================================================
-- 【TAB切换频道】
-- ========================================================================
do
    local tabSwitchHooked = false
    local originalTabPressed = nil

    local cycles = {
        { chatType = "SAY", use = function() return true end },
        { chatType = "YELL", use = function() return true end },
        { chatType = "PARTY", use = function() return IsInGroup() end },
        { chatType = "RAID", use = function() return IsInRaid() end },
        { chatType = "INSTANCE_CHAT", use = function()
            local inInstance, instanceType = IsInInstance()
            return inInstance and instanceType == "pvp"
        end },
        { chatType = "GUILD", use = function() return IsInGuild() end },
        { chatType = "CHANNEL", use = function(editbox, currChatType)
            local currNum = currChatType == "CHANNEL" and editbox:GetAttribute("channelTarget") or 0
            for i = currNum + 1, 10 do
                local channelNum, channelName = GetChannelName(i)
                if channelNum > 0 and channelName and not channelName:find("local %-") then
                    editbox:SetAttribute("channelTarget", i)
                    return true
                end
            end
        end },
    }

    local function TabSwitchFunction(self)
        if not RoyChatBarDB or not RoyChatBarDB.isTabSwitch then return end
        if strsub(tostring(self:GetText()), 1, 1) == "/" then return end

        local currChatType = self:GetAttribute("chatType")

        if currChatType == "WHISPER" or currChatType == "BN_WHISPER" then
            self:SetAttribute("chatType", "SAY")
            securecall(ChatEdit_UpdateHeader, self)
            return
        end

        if currChatType == "CHANNEL" and not self:GetAttribute("channelTarget") then
            self:SetAttribute("chatType", "SAY")
            securecall(ChatEdit_UpdateHeader, self)
            return
        end

        for i, curr in ipairs(cycles) do
            if curr.chatType == currChatType then
                local startIdx = (currChatType == "CHANNEL") and i or i + 1
                for j = startIdx, #cycles do
                    if cycles[j].use(self, currChatType) then
                        self:SetAttribute("chatType", cycles[j].chatType)
                        ChatEdit_UpdateHeader(self)
                        return
                    end
                end
                self:SetAttribute("chatType", "SAY")
                ChatEdit_UpdateHeader(self)
                return
            end
        end
    end

    function ns.OnTabSwitchChanged(value)
        if value and not tabSwitchHooked then
            originalTabPressed = ChatEdit_CustomTabPressed
            ChatEdit_CustomTabPressed = TabSwitchFunction
            tabSwitchHooked = true
        elseif not value and tabSwitchHooked then
            ChatEdit_CustomTabPressed = originalTabPressed
            tabSwitchHooked = false
        end
    end
end

-- ========================================================================
-- 【快捷聊天条】
-- ========================================================================
do
    local function SwitchToChannel(cmd)
        local cf = SELECTED_DOCK_FRAME
        local active = ChatEdit_GetActiveWindow()
        if active then
            ChatFrame_OpenChat("/" .. cmd .. " " .. cf.editBox:GetText(), cf)
        else
            ChatFrame_OpenChat("/" .. cmd, cf)
        end
    end

    local countdownEndTime = 0

    local buttonDefs = {
        {
            id = "WorldChannel",
            var = "isWorldChannel",
            shortName = L["世"],
            color = { 1, 0.75, 0.75 },
            tooltip = L["左键：世界频道\n右键：进出频道"],
            onClick = function(_, button)
                local channelName = "大脚世界频道"
                if button == "RightButton" then
                    local _, name = GetChannelName(channelName)
                    local editBox = ChatEdit_ChooseBoxForSend()
                    if not editBox then return end
                    if name == nil then
                        editBox:SetText("/join " .. channelName)
                        ChatEdit_SendText(editBox, 1)
                        print("|cFF33FF99BF|r丨|cFF4499FF" .. L["已加入世界频道"] .. "|r")
                    else
                        local id = GetChannelName(channelName)
                        if id then
                            editBox:SetText("/leave " .. id)
                            ChatEdit_SendText(editBox, 1)
                            print("|cFF33FF99BF|r丨|cFFEE8800" .. L["已离开世界频道"] .. "|r")
                        end
                    end
                else
                    local id, name = GetChannelName(channelName)
                    if name == nil then
                        print("|cFF33FF99BF|r丨|cFFEE8800" .. L["你不在世界频道，右键点击以加入"] .. "|r")
                    else
                        SwitchToChannel(id)
                    end
                end
            end,
        },
        {
            id = "Say",
            var = "isSay",
            shortName = L["说"],
            color = { 1, 1, 1 },
            tooltip = L["说"],
            onClick = function() SwitchToChannel("s") end,
        },
        {
            id = "Yell",
            var = "isYell",
            shortName = L["喊"],
            color = { 1, 0.25, 0.25 },
            tooltip = L["大喊"],
            onClick = function() SwitchToChannel("y") end,
        },
        {
            id = "Party",
            var = "isParty",
            shortName = L["队"],
            color = { 0.67, 0.67, 1 },
            tooltip = L["队伍"],
            onClick = function() SwitchToChannel("p") end,
        },
        {
            id = "Guild",
            var = "isGuild",
            shortName = L["会"],
            color = { 0.25, 1, 0.25 },
            tooltip = L["公会"],
            onClick = function() SwitchToChannel("g") end,
        },
        {
            id = "InstanceRaid",
            var = "isInstanceRaid",
            shortName = L["本"],
            color = { 1, 0.5, 0 },
            tooltip = L["左键：副本团队\n右键：团队通知"],
            onClick = function(_, button)
                if button == "RightButton" then
                    SwitchToChannel("rw")
                else
                    if IsInRaid() then
                        SwitchToChannel("raid")
                    else
                        SwitchToChannel("instance_chat")
                    end
                end
            end,
        },
        {
            id = "Dice",
            var = "isDiceButton",
            shortName = L["骰"],
            color = { 1, 0.9, 0.4 },
            tooltip = L["左键：投掷点数\n右键：掷骰记录"],
            onClick = function(_, button)
                if button == "LeftButton" then
                    RandomRoll(1, 100)
                elseif button == "RightButton" then
                    if GroupLootHistoryFrame:IsShown() then
                        HideUIPanel(GroupLootHistoryFrame)
                    else
                        ShowUIPanel(GroupLootHistoryFrame)
                    end
                end
            end,
        },
        {
            id = "Macro",
            var = "isMacroButton",
            shortName = L["宏"],
            color = { 0.2, 0.4, 1 },
            tooltip = L["宏界面"],
            onClick = function(_, button)
                if button == "LeftButton" then
                    if MacroFrame and MacroFrame:IsShown() then
                        HideUIPanel(MacroFrame)
                    else
                        ShowMacroFrame()
                    end
                end
            end,
        },
        {
            id = "ReadyCheck",
            var = "isReadyCheck",
            shortName = L["备"],
            color = { 0.4, 1, 0.6 },
            tooltip = L["左键：就位确认\n右键：倒数计时"],
            onClick = function(_, button)
                if button == "LeftButton" then
                    DoReadyCheck()
                elseif button == "RightButton" then
                    local secs = RoyChatBarDB.readyCheckCountdown or 5
                    local now = GetTime()
                    if now < countdownEndTime then
                        if C_PartyInfo.CancelCountdown then
                            C_PartyInfo.CancelCountdown()
                        else
                            C_PartyInfo.DoCountdown(0)
                        end
                        countdownEndTime = 0
                    else
                        C_PartyInfo.DoCountdown(secs)
                        countdownEndTime = now + secs
                    end
                end
            end,
        },
        {
            id = "LeaveReset",
            var = "isLeaveReset",
            shortName = L["退"],
            color = { 1, 1, 0 },
            tooltip = L["左键：退出队伍\n右键：重置副本"],
            onClick = function(_, button)
                if button == "LeftButton" then
                    C_PartyInfo.LeaveParty()
                    C_Timer.After(0.3, function()
                        local _, instanceType = IsInInstance()
                        if instanceType == "scenario" then
                            C_PartyInfo.DelveTeleportOut()
                        end
                    end)
                elseif button == "RightButton" then
                    ResetInstances()
                end
            end,
        },
        {
            id = "Reload",
            var = "isReload",
            shortName = L["RL"],
            color = { 0, 0.8, 1 },
            tooltip = L["左键：重载界面\n右键：重置伤害"],
            onClick = function(self, button)
                if button == "LeftButton" then
                    local mode = RoyChatBarDB.reloadClickMode or "single"
                    if mode == "single" then
                        ReloadUI()
                    else
                        local now = GetTime()
                        if self._lastClickTime and (now - self._lastClickTime) < 0.4 then
                            self._lastClickTime = nil
                            ReloadUI()
                        else
                            self._lastClickTime = now
                        end
                    end
                elseif button == "RightButton" then
                    C_DamageMeter.ResetAllCombatSessions()
                end
            end,
        },
    }

    local chatBarFrame = nil
    local activeButtons = {}

    local function GetButtonSize(displayMode, fontSize, sqW, sqH)
        if displayMode == "TEXT" then
            return fontSize * 1.2, fontSize + 4
        end
        return sqW, sqH
    end

    local function GetTotalSize(count, bw, bh, direction, spacing)
        if direction == "HORIZONTAL" then
            return count * bw + (count - 1) * spacing, bh
        end
        return bw, count * bh + (count - 1) * spacing
    end

    local function UpdateVisual(button, def, displayMode, fontSize)
        if displayMode == "TEXT" then
            if not button.bllText then
                button.bllText = button:CreateFontString(nil, "OVERLAY")
                button.bllText:SetPoint("CENTER")
                button.bllText:SetJustifyH("CENTER")
            end
            button.bllText:SetFont(STANDARD_TEXT_FONT, fontSize, "OUTLINE")
            button.bllText:SetText(def.shortName)
            button.bllText:SetTextColor(def.color[1], def.color[2], def.color[3])
            button.bllText:Show()
            if button.bllBG then button.bllBG:Hide() end
        else
            if not button.bllBG then
                button.bllBG = button:CreateTexture(nil, "BACKGROUND")
                button.bllBG:SetAllPoints(button)
                button.bllBG:SetTexture("Interface\\AddOns\\RoyChatBar\\Media\\Chatbar.png")
                button.bllBG:SetBlendMode("BLEND")
            end
            button.bllBG:SetVertexColor(def.color[1], def.color[2], def.color[3])
            button.bllBG:Show()
            if button.bllText then button.bllText:Hide() end
        end
        button.bllColor = def.color
        button.bllDisplayMode = displayMode
    end

    local function SetupMouseEvents(button, def)
        button:SetScript("OnClick", def.onClick)

        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:ClearLines()
            GameTooltip:SetText(def.tooltip, 1, 1, 1)
            GameTooltip:Show()
            self:SetAlpha(0.75)
        end)

        button:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            self:SetAlpha(1)
        end)

        button:SetScript("OnMouseDown", function(self)
            local c = self.bllColor
            if not c then return end
            local r, g, b = c[1] * 0.6, c[2] * 0.6, c[3] * 0.6
            if self.bllDisplayMode == "TEXT" and self.bllText then
                self.bllText:SetTextColor(r, g, b)
            elseif self.bllDisplayMode == "SQUARE" and self.bllBG then
                self.bllBG:SetVertexColor(r, g, b)
            end
        end)

        button:SetScript("OnMouseUp", function(self)
            local c = self.bllColor
            if not c then return end
            if self.bllDisplayMode == "TEXT" and self.bllText then
                self.bllText:SetTextColor(c[1], c[2], c[3])
            elseif self.bllDisplayMode == "SQUARE" and self.bllBG then
                self.bllBG:SetVertexColor(c[1], c[2], c[3])
            end
        end)
    end

    local function UpdatePosition()
        if not chatBarFrame then return end
        local db = RoyChatBarDB
        local mode = db.chatBarAnchorMode or "FREE"
        local pos = db.chatBarPosition and db.chatBarPosition[mode]
        local x = pos and pos.x or 0
        local y = pos and pos.y or 0
        chatBarFrame:ClearAllPoints()
        if mode == "ANCHOR" then
            local anchorTarget = GeneralDockManager
            if not anchorTarget or not anchorTarget:IsShown() then
                anchorTarget = DEFAULT_CHAT_FRAME or ChatFrame1
            end
            chatBarFrame:SetPoint("TOPLEFT", anchorTarget, "TOPLEFT", x, y)
        else
            chatBarFrame:SetPoint("CENTER", UIParent, "CENTER", x, y)
        end
    end

    local function RebuildButtons()
        if not chatBarFrame then return end
        local db = RoyChatBarDB
        if not db or not db.isChatBar then
            chatBarFrame:Hide()
            return
        end

        local enabled = {}
        for _, def in ipairs(buttonDefs) do
            if db[def.var] then
                enabled[#enabled + 1] = def
            end
        end

        if #enabled == 0 then
            chatBarFrame:Hide()
            return
        end

        local displayMode = db.chatDisplayMode or "TEXT"
        local direction = db.chatLayoutDirection or "HORIZONTAL"
        local spacing = db.chatButtonSpacing or 0
        local fontSize = db.chatTextFontSize or 16
        local sqW = db.chatSquareWidth or 25
        local sqH = db.chatSquareHeight or 10

        local bw, bh = GetButtonSize(displayMode, fontSize, sqW, sqH)
        local totalW, totalH = GetTotalSize(#enabled, bw, bh, direction, spacing)

        for _, btn in pairs(activeButtons) do
            btn:Hide()
            btn:ClearAllPoints()
        end

        for i, def in ipairs(enabled) do
            local btnName = "RoyChatBarChatButton_" .. def.id
            local btn = activeButtons[def.id] or _G[btnName]
            if not btn then
                btn = CreateFrame("Button", btnName, chatBarFrame)
                btn:RegisterForClicks("AnyUp")
            end

            local xOff, yOff
            if direction == "HORIZONTAL" then
                xOff, yOff = (i - 1) * (bw + spacing), 0
            else
                xOff, yOff = 0, -(i - 1) * (bh + spacing)
            end
            btn:SetPoint("TOPLEFT", chatBarFrame, "TOPLEFT", xOff, yOff)
            btn:SetSize(bw, bh)

            UpdateVisual(btn, def, displayMode, fontSize)
            SetupMouseEvents(btn, def)
            btn:SetAlpha(1)
            btn:Show()

            activeButtons[def.id] = btn
        end

        chatBarFrame:SetSize(totalW, totalH)
        chatBarFrame:Show()

        UpdatePosition()
    end

    local function InitChatBar()
        local db = RoyChatBarDB
        if not db or not db.isChatBar then return end

        if not chatBarFrame then
            chatBarFrame = CreateFrame("Frame", "RoyChatBarChatBarFrame", UIParent)
            chatBarFrame:SetFrameStrata("MEDIUM")
            chatBarFrame:SetFrameLevel(200)
            chatBarFrame:SetSize(1, 1)
        end
        RebuildButtons()
    end

    function ns.OnChatBarToggle(value)
        if value then
            InitChatBar()
        else
            if chatBarFrame then chatBarFrame:Hide() end
        end
    end

    function ns.OnChatBarChanged()
        if not RoyChatBarDB or not RoyChatBarDB.isChatBar then return end
        if not chatBarFrame then
            InitChatBar()
        else
            RebuildButtons()
        end
    end

    function ns.OnChatBarPositionChanged()
        UpdatePosition()
    end

    local chatEventFrame = CreateFrame("Frame")
    chatEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    chatEventFrame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_ENTERING_WORLD" then
            local db = RoyChatBarDB
            if not db then return end
            if db.isChatBar then
                C_Timer.After(1, InitChatBar)
            end
            if db.isTabSwitch then
                C_Timer.After(0.5, function()
                    ns.OnTabSwitchChanged(true)
                end)
            end
        end
    end)
end

-- ========================================================================
-- 【框体渐隐系统】
-- ========================================================================
do
    local MODE_SHOW = 0
    local MODE_FADE = 2
    local MODE_FADE_COMBAT = 3

    -- -------------------------------------------------------------------
    -- 核心：FadeEngine + 工具函数 + 通用渐隐钩子
    -- -------------------------------------------------------------------
    local animQueue = {}
    local animFrame = CreateFrame("Frame")
    local animRunning = false

    local function StopAnim(key)
        animQueue[key] = nil
        if not next(animQueue) then
            animFrame:SetScript("OnUpdate", nil)
            animRunning = false
        end
    end

    local function PlayFade(key, frame, targetAlpha, duration)
        if not frame then return end
        local current = frame:GetAlpha()
        if math.abs(current - targetAlpha) < 0.001 then return end
        if duration <= 0 then
            StopAnim(key)
            frame:SetAlpha(targetAlpha)
            return
        end
        animQueue[key] = {
            frame = frame,
            startAlpha = current,
            targetAlpha = targetAlpha,
            startTime = GetTime(),
            duration = duration,
        }
        if not animRunning then
            animRunning = true
            animFrame:SetScript("OnUpdate", function()
                local now = GetTime()
                for k, a in pairs(animQueue) do
                    local t = math.min((now - a.startTime) / a.duration, 1)
                    a.frame:SetAlpha(a.startAlpha + (a.targetAlpha - a.startAlpha) * t)
                    if t >= 1 then animQueue[k] = nil end
                end
                if not next(animQueue) then
                    animFrame:SetScript("OnUpdate", nil)
                    animRunning = false
                end
            end)
        end
    end

    local function GetFadeIn() return RoyChatBarDB.rcbUiFadeInDuration or 0.2 end
    local function GetFadeOut() return RoyChatBarDB.rcbUiFadeOutDuration or 0.2 end
    local function InCombat() return UnitAffectingCombat("player") end

    local globalFadeEnabled = true
    local hooked = {}

    local function HookFade(key, frame, buttons, dynamicButtons)
        if hooked[key] and not dynamicButtons then return end
        hooked[key] = true

        local function OnEnter()
            if not RoyChatBarDB then return end
            local mode = RoyChatBarDB[key]
            if mode ~= MODE_FADE and mode ~= MODE_FADE_COMBAT then return end
            if not globalFadeEnabled then return end
            PlayFade(key, frame, 1, GetFadeIn())
        end

        local function OnLeave()
            if not RoyChatBarDB then return end
            local mode = RoyChatBarDB[key]
            if mode ~= MODE_FADE and mode ~= MODE_FADE_COMBAT then return end
            if not globalFadeEnabled then return end
            C_Timer.After(0.05, function()
                if frame:IsMouseOver() then return end
                for _, btn in ipairs(buttons) do
                    if btn and btn:IsMouseOver() then return end
                end
                if RoyChatBarDB[key] == MODE_FADE_COMBAT and InCombat() then return end
                PlayFade(key, frame, 0, GetFadeOut())
            end)
        end

        frame:HookScript("OnEnter", OnEnter)
        frame:HookScript("OnLeave", OnLeave)
        for _, btn in ipairs(buttons) do
            if btn then
                btn:HookScript("OnEnter", OnEnter)
                btn:HookScript("OnLeave", OnLeave)
            end
        end
    end

    local function ApplyFadeState(key, frame, buttons, mode, dynamicButtons)
        HookFade(key, frame, buttons, dynamicButtons)
        if mode == MODE_FADE_COMBAT and InCombat() then
            StopAnim(key); frame:SetAlpha(1); return
        end
        if not globalFadeEnabled then
            PlayFade(key, frame, 1, GetFadeIn()); return
        end
        local hovered = frame:IsMouseOver()
        if not hovered then
            for _, btn in ipairs(buttons) do
                if btn and btn:IsMouseOver() then hovered = true; break end
            end
        end
        PlayFade(key, frame, hovered and 1 or 0, hovered and GetFadeIn() or GetFadeOut())
    end

    -- -------------------------------------------------------------------
    -- REGISTRY：框体数据表
    -- -------------------------------------------------------------------
    local REGISTRY = {}

    local chatBarButtonIds = {
        "WorldChannel", "Say", "Yell", "Party", "Guild", "InstanceRaid",
        "Dice", "Macro", "ReadyCheck", "LeaveReset", "Reload",
    }

    REGISTRY[#REGISTRY + 1] = {
        key = "chatBar",
        noHide = true,
        retry = true,
        dynamicButtons = true,
        getFrame = function() return _G["RoyChatBarChatBarFrame"] end,
        getButtons = function()
            local btns = {}
            for _, id in ipairs(chatBarButtonIds) do
                local btn = _G["RoyChatBarChatButton_" .. id]
                if btn then btns[#btns + 1] = btn end
            end
            return btns
        end,
    }

    -- -------------------------------------------------------------------
    -- ApplyState：调度函数
    -- -------------------------------------------------------------------
    local function ApplyState(reg)
        if not RoyChatBarDB then return end
        local mode = RoyChatBarDB[reg.key] or MODE_SHOW
        local key = reg.key
        local frame = reg.getFrame()
        if not frame then return end
        local buttons = reg.getButtons()

        if mode == MODE_SHOW then
            StopAnim(key); frame:SetAlpha(1); return
        end

        if mode == MODE_HIDE then
            StopAnim(key); frame:SetAlpha(0); return
        end

        ApplyFadeState(key, frame, buttons, mode, reg.dynamicButtons)
    end

    -- -------------------------------------------------------------------
    -- 事件处理 + 初始化
    -- -------------------------------------------------------------------
    local function ApplyAllStates()
        for _, reg in ipairs(REGISTRY) do
            ApplyState(reg)
        end
    end

    local combatFrame = CreateFrame("Frame")
    combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    combatFrame:SetScript("OnEvent", ApplyAllStates)

    function ns.OnUIFrameModeChanged(key, value)
        if not RoyChatBarDB then return end
        for _, reg in ipairs(REGISTRY) do
            if reg.key == key then ApplyState(reg); break end
        end
    end

    function ns.OnUIFadeTimerChanged() end

    local function Initialize()
        if RoyChatBarDB and RoyChatBarDB.globalFadeEnabled ~= nil then
            globalFadeEnabled = RoyChatBarDB.globalFadeEnabled
        end
        C_Timer.After(1, function()
            ApplyAllStates()
            for _, reg in ipairs(REGISTRY) do
                if reg.retry then
                    local retryCount = 0
                    C_Timer.NewTicker(0.5, function(t)
                        retryCount = retryCount + 1
                        ApplyState(reg)
                        if reg.getFrame() or retryCount >= 20 then t:Cancel() end
                    end)
                end
            end
        end)
    end

    EventUtil.ContinueOnAddOnLoaded(addonName, Initialize)

    local worldFrame = CreateFrame("Frame")
    worldFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    worldFrame:SetScript("OnEvent", function(_, _, isInitialLogin, isReloadingUI)
        if not isInitialLogin and not isReloadingUI then
            C_Timer.After(0.5, ApplyAllStates)
        end
    end)
end