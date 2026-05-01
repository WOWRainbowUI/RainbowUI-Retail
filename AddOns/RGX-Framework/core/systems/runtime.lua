--[[
    RGX-Framework - Runtime Helpers

    BLU already proved that a WoW addon can provide its own lightweight
    framework runtime without leaning on LibStub-era dependency chains.

    RGX keeps the same philosophy here:
    - native timer helpers
    - native hook helpers
    - native slash command registration
--]]

local addonName, RGX = ...

RGX.timers = RGX.timers or {}
RGX._hookRegistry = RGX._hookRegistry or {}
RGX.slashCommands = RGX.slashCommands or {}
RGX._slashCommandCounter = RGX._slashCommandCounter or 0
RGX.combatQueue = RGX.combatQueue or {}
RGX._timerCounter = RGX._timerCounter or 0
RGX.timerBudget = RGX.timerBudget or {
    maxPerFrame = 120,
    maxSeconds = 0.016,
    slowSeconds = 0.050,
}

local unpackFunc = unpack or table.unpack

local function isInCombatLockdown()
    return InCombatLockdown and InCombatLockdown() == true
end

local function secureInvoke(fn, ...)
    if type(fn) ~= "function" then
        return false, "missing function"
    end

    local ok, result = pcall(fn, ...)
    if not ok then
        return false, result
    end
    if result == false then
        return false, result
    end
    return true, result
end

local function reportRuntimeError(scope, err)
    local message = string.format("[RGX:%s] %s", tostring(scope), tostring(err))

    if type(_G.geterrorhandler) == "function" then
        _G.geterrorhandler()(message)
        return
    end

    print("|cFFFF4444" .. message .. "|r")
end

local function nowSeconds()
    if type(GetTimePreciseSec) == "function" then
        return GetTimePreciseSec()
    end
    if type(debugprofilestop) == "function" then
        return debugprofilestop() / 1000
    end
    if type(GetTime) == "function" then
        return GetTime()
    end
    if type(os) == "table" and type(os.clock) == "function" then
        return os.clock()
    end
    return 0
end

local function reportTimerBudget(message)
    local now = nowSeconds()
    if (RGX._lastTimerBudgetReport or 0) + 2 > now then
        return
    end

    RGX._lastTimerBudgetReport = now
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffaaaaaa[RGX:timer-budget]|r " .. tostring(message))
    end
end

function RGX:EnsureTimerDriver()
    if self.timerFrame then
        self.timerFrame:SetScript("OnUpdate", function(_, elapsed)
            self:UpdateTimers(elapsed)
        end)
        return
    end

    self.timerFrame = CreateFrame("Frame")
    self.timerFrame:SetScript("OnUpdate", function(_, elapsed)
        self:UpdateTimers(elapsed)
    end)
end

function RGX:CreateTimer(duration, callback, repeating, label)
    duration = tonumber(duration) or 0
    if duration < 0 then
        duration = 0
    end

    if type(callback) ~= "function" then
        return nil
    end

    self._timerCounter = (self._timerCounter or 0) + 1

    local timer = {
        id = self._timerCounter,
        label = label or ("timer#" .. tostring(self._timerCounter)),
        duration = duration,
        callback = callback,
        repeating = repeating == true,
        elapsed = 0,
        active = true,
    }

    if type(debugstack) == "function" then
        timer.createdAt = debugstack(2, 4, 0)
    end

    self.timers[#self.timers + 1] = timer
    self:EnsureTimerDriver()
    return timer
end

function RGX:After(duration, callback, label)
    return self:CreateTimer(duration, callback, false, label)
end

function RGX:Every(duration, callback, label)
    return self:CreateTimer(duration, callback, true, label)
end

function RGX:CancelTimer(timer)
    if type(timer) ~= "table" then
        return false
    end

    timer.active = false
    return true
end

function RGX:CancelAllTimers()
    local cancelled = 0

    for index = 1, #self.timers do
        local timer = self.timers[index]
        if timer and timer.active then
            timer.active = false
            cancelled = cancelled + 1
        end
    end

    return cancelled
end

function RGX:EnsureCombatQueueEvent()
    if self._combatQueueRegistered then
        return true
    end

    if type(self.RegisterEvent) ~= "function" then
        return false
    end

    local ok, result = pcall(self.RegisterEvent, self, "PLAYER_REGEN_ENABLED", function()
        self:ProcessCombatQueue()
    end, "RGX_CombatQueue_PLAYER_REGEN_ENABLED")

    self._combatQueueRegistered = ok and result ~= false
    return self._combatQueueRegistered
end

function RGX:QueueForCombat(func, ...)
    if type(func) ~= "function" then
        return false
    end

    if not isInCombatLockdown() then
        return func(...)
    end

    local args = { n = select("#", ...), ... }
    self.combatQueue[#self.combatQueue + 1] = {
        func = func,
        args = args,
    }
    self:EnsureCombatQueueEvent()
    return false
end

function RGX:ProcessCombatQueue()
    if isInCombatLockdown() then
        return false
    end

    local queue = self.combatQueue
    if type(queue) ~= "table" or #queue == 0 then
        return true
    end

    self.combatQueue = {}
    for index = 1, #queue do
        local operation = queue[index]
        if operation and type(operation.func) == "function" then
            local args = operation.args or {}
            local ok, err = pcall(operation.func, unpackFunc(args, 1, args.n or #args))
            if not ok then
                reportRuntimeError("combat-queue", err)
            end
        end
    end

    return true
end

function RGX:ShouldQueueOperation()
    return isInCombatLockdown()
end

local function queueSecureCall(self, label, fn, ...)
    local args = { n = select("#", ...), ... }
    return self:QueueForCombat(function()
        local ok, err = secureInvoke(fn, unpackFunc(args, 1, args.n))
        if not ok then
            self:Debug("[RGX:safe] " .. tostring(label) .. " failed:", err)
        end
        return ok
    end)
end

function RGX:SafeShow(frame)
    if not frame or type(frame.Show) ~= "function" then return false end
    return queueSecureCall(self, "Show", frame.Show, frame)
end

function RGX:SafeHide(frame)
    if not frame or type(frame.Hide) ~= "function" then return false end
    return queueSecureCall(self, "Hide", frame.Hide, frame)
end

function RGX:SafeSetPoint(frame, ...)
    if not frame or type(frame.SetPoint) ~= "function" then return false end
    local args = { n = select("#", ...), ... }
    return self:QueueForCombat(function()
        local ok, err = pcall(function()
            if type(frame.ClearAllPoints) == "function" then
                frame:ClearAllPoints()
            end
            frame:SetPoint(unpackFunc(args, 1, args.n))
        end)
        if not ok then
            self:Debug("[RGX:safe] SetPoint failed:", err)
        end
        return ok
    end)
end

function RGX:SafeSetSize(frame, width, height)
    if not frame or type(frame.SetSize) ~= "function" then return false end
    return queueSecureCall(self, "SetSize", frame.SetSize, frame, width, height)
end

function RGX:SafeSetText(region, text)
    if not region or type(region.SetText) ~= "function" then return false end
    return queueSecureCall(self, "SetText", region.SetText, region, text)
end

function RGX:SafeUIDropDownMenu_SetText(dropdown, text)
    if not dropdown or type(UIDropDownMenu_SetText) ~= "function" then return false end
    return queueSecureCall(self, "UIDropDownMenu_SetText", UIDropDownMenu_SetText, dropdown, text)
end

function RGX:SafeUIDropDownMenu_Initialize(dropdown, initializer, displayMode)
    if not dropdown or type(initializer) ~= "function" or type(UIDropDownMenu_Initialize) ~= "function" then
        return false
    end
    return queueSecureCall(self, "UIDropDownMenu_Initialize", UIDropDownMenu_Initialize, dropdown, initializer, displayMode)
end

function RGX:SafeUIDropDownMenu_Refresh(dropdown)
    if not dropdown or type(UIDropDownMenu_Refresh) ~= "function" then return false end
    return queueSecureCall(self, "UIDropDownMenu_Refresh", UIDropDownMenu_Refresh, dropdown)
end

function RGX:SafeUIDropDownMenu_EnableDropDown(dropdown)
    if not dropdown or type(UIDropDownMenu_EnableDropDown) ~= "function" then return false end
    return queueSecureCall(self, "UIDropDownMenu_EnableDropDown", UIDropDownMenu_EnableDropDown, dropdown)
end

function RGX:SafeUIDropDownMenu_DisableDropDown(dropdown)
    if not dropdown or type(UIDropDownMenu_DisableDropDown) ~= "function" then return false end
    return queueSecureCall(self, "UIDropDownMenu_DisableDropDown", UIDropDownMenu_DisableDropDown, dropdown)
end

function RGX:SafeToggleDropDownMenu(...)
    if type(ToggleDropDownMenu) ~= "function" then return false end
    return queueSecureCall(self, "ToggleDropDownMenu", ToggleDropDownMenu, ...)
end

function RGX:SafeCloseDropDownMenus(...)
    if type(CloseDropDownMenus) ~= "function" then return false end
    return queueSecureCall(self, "CloseDropDownMenus", CloseDropDownMenus, ...)
end

function RGX:UpdateTimers(elapsed)
    local budget = self.timerBudget or {}
    local maxPerFrame = tonumber(budget.maxPerFrame) or 120
    local maxSeconds = tonumber(budget.maxSeconds) or 0.008
    local slowSeconds = tonumber(budget.slowSeconds) or 0.050
    local started = nowSeconds()
    local processed = 0
    local index = #self.timers

    while index >= 1 do
        if processed >= maxPerFrame or (nowSeconds() - started) >= maxSeconds then
            if #self.timers > 25 or processed >= maxPerFrame then
                reportTimerBudget(string.format(
                    "deferred timers after %d callbacks in %.1fms; %d timer(s) still queued",
                    processed,
                    (nowSeconds() - started) * 1000,
                    #self.timers
                ))
            end
            break
        end

        local timer = self.timers[index]

        if not timer or not timer.active then
            table.remove(self.timers, index)
        else
            timer.elapsed = timer.elapsed + elapsed

            if timer.elapsed >= timer.duration then
                processed = processed + 1
                local callbackStarted = nowSeconds()
                local ok, err = pcall(timer.callback, timer)
                local callbackElapsed = nowSeconds() - callbackStarted

                if not ok then
                    reportRuntimeError("timer", err)
                elseif callbackElapsed >= slowSeconds then
                    reportRuntimeError("timer-slow", string.format(
                        "%s took %.1fms",
                        tostring(timer.label or timer.id or timer.callback),
                        callbackElapsed * 1000
                    ))
                end

                if timer.repeating and timer.active then
                    timer.elapsed = timer.elapsed - timer.duration
                    if timer.elapsed < 0 then
                        timer.elapsed = 0
                    end
                else
                    table.remove(self.timers, index)
                end
            end
        end

        index = index - 1
    end

    if #self.timers == 0 and self.timerFrame then
        self.timerFrame:SetScript("OnUpdate", nil)
    end
end

-- Post-hook target[method] via hooksecurefunc. callback receives the same args
-- as the original. Safe for Blizzard UI functions; cannot be unhooked.
function RGX:Hook(target, method, callback)
    if type(target) ~= "table" or type(method) ~= "string" or method == "" then
        return false
    end
    if type(callback) ~= "function" then
        return false
    end
    if type(target[method]) ~= "function" then
        return false
    end

    self._hookRegistry[target] = self._hookRegistry[target] or {}
    if self._hookRegistry[target][method] then
        return false
    end
    self._hookRegistry[target][method] = true

    hooksecurefunc(target, method, callback)
    return true
end

function RGX:RegisterSlashCommand(commands, callback, id)
    if type(callback) ~= "function" then
        return false
    end

    local commandList = type(commands) == "table" and commands or { commands }
    local normalized = {}

    for index = 1, #commandList do
        local command = tostring(commandList[index] or "")
        command = command:gsub("^%s*/?", ""):gsub("%s+$", "")
        if command ~= "" then
            normalized[#normalized + 1] = command
        end
    end

    if #normalized == 0 then
        return false
    end

    self._slashCommandCounter = self._slashCommandCounter + 1
    local token = tostring(id or (addonName .. "_CMD_" .. self._slashCommandCounter))
    token = token:gsub("[^%w_]", "_"):upper()

    for index = 1, #normalized do
        _G["SLASH_" .. token .. index] = "/" .. normalized[index]
    end

    SlashCmdList[token] = callback
    self.slashCommands[token] = {
        commands = normalized,
        callback = callback,
    }

    return token
end

-- Shorthand: RGX:Slash("mycommand", fn)  →  RGX:RegisterSlashCommand({"mycommand"}, fn)
function RGX:Slash(command, callback)
    return self:RegisterSlashCommand({ command }, callback)
end
