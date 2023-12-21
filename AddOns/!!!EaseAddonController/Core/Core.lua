local _, core = ...
local L = core.L
local floor,ceil,format,tostring=floor,ceil,format,tostring
local pairs,ipairs,next,wipe,assert,type,tinsert,select,tremove,GetTime = pairs,ipairs,next,wipe,assert,type,tinsert,select,tremove,GetTime
local n2s_small,n2s_big,n2s_float,n2s_format,n2s_pad_cache={},{},{},{"%.1f","%.2f","%.3f","%.4f","%.5f",[0]="%d"},{"0","00","000","0000","00000"}
for i=0, 100 do n2s_small[i] = tostring(i) end
for i=0, 9 do for j=0, 9 do n2s_float[i+j/10] = format("%.1f", i+j/10) end end

function noop() end
function pdebug() print(debugstack(2)) end

_empty_table = {};
_temp_table = {};

function copy(fromTable, toTable)
    toTable = toTable or {}
    if not fromTable then return end
    for k,v in pairs(fromTable) do
        toTable[k] = v;
    end
    return toTable;
end

function deepmix(targetTable, dataTable)
    for k, v in pairs(dataTable) do
        if type(v) == "table" and type(targetTable[k]) == "table" then
            deepmix(targetTable[k], v)
        else
            targetTable[k] = v
        end
    end
end

function tremovedata(t, data)
    for i=#t,1,-1 do
        if t[i]==data then
            tremove(t, i)
        end
    end
end

--- return false if data is already in array, otherwise append data and return true
function tinsertdata(array, data)
    for i=1,#array do
        if(array[i]==data) then return end
    end
    tinsert(array, data);
    return true;
end

--- table1 has all table2 keys and values are same
function tcovers(table1, table2)
    for k,v in pairs(table2) do
        if v ~= table1[k] then
            return false
        end
    end
    return true
end

local function escape(str)
    return str:gsub("%%", "%%%%"):gsub("%-","%%-"):gsub("%+","%%+"):gsub("%.","%%."):gsub("%[", "%%["):gsub("%]", "%%]"):gsub("%(", "%%("):gsub("%)", "%%)");
end

--- format a pattern to case-insensetive one. "Abc" -> "[Aa][Bb][Cc]"
function nocase(s)
    return string.gsub(escape(s), "%a", function (c)
        return string.format("[%s%s]", string.lower(c),
            string.upper(c))
    end)
end

function uncolor(s)
    return s and s:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1") or nil
end

function time33(s)
    if #s < 15 then s = s .. strrep(s, 15 / #s) .. string.reverse(s) end
    local hash = 0
    for i=1,#s do
        hash = (hash * 31) % 1000000 + s:byte(i)
    end
    return hash
end

--[[
	 xpcall safecall implementation
]]
local xpcall = xpcall

local function errorhandler(err)
    return geterrorhandler()(err)
end

local function CreateDispatcher(argCount)
    local code = [[
		local xpcall, eh = ...
		local method, ARGS
		local function call() return method(ARGS) end

		local function dispatch(func, ...)
			method = func
			if not method then return end
			ARGS = ...
			return xpcall(call, eh)
		end

		return dispatch
	]]

    local ARGS = {}
    for i = 1, argCount do ARGS[i] = "arg"..i end
    code = code:gsub("ARGS", table.concat(ARGS, ", "))
    return assert(loadstring(code, "safecall Dispatcher["..argCount.."]"))(xpcall, errorhandler)
end

local Dispatchers = setmetatable({}, {__index=function(self, argCount)
    local dispatcher = CreateDispatcher(argCount)
    rawset(self, argCount, dispatcher)
    return dispatcher
end})
Dispatchers[0] = function(func)
    return xpcall(func, errorhandler)
end

function safecall(func, ...)
    return Dispatchers[select("#", ...)](func, ...)
end

--- format integers to string, fixed length, padding with '0'
function n2s_pad(str, length)
    length = length - #str
    if length > 0 then return n2s_pad_cache[length]..str else return str end
end
local n2s_02d = {} for i=0, 100 do n2s_02d[i]=format("%02d", i) end

--- number to string
function n2s(n, pad, useceil)
    if n >= 0 then
        if n <= 100 then
            if pad then
                if pad==2 then return n2s_02d[n] end
                local str = n2s_small[n] or n2s_small[(useceil and ceil or floor)(n)]
                pad = pad - #str if pad > 0 then return n2s_pad_cache[pad]..str else return str end
            else
                return n2s_small[n] or n2s_small[(useceil and ceil or floor)(n)]
            end
        elseif n <=10000 then
            local n2s_res = n2s_big[n]
            if not n2s_res then
                n = (useceil and ceil or floor)(n)
                n2s_res = n2s_big[n]
                if not n2s_res then
                    n2s_res = format("%d", n)
                    n2s_big[(useceil and ceil or floor)(n)] = n2s_res
                end
            end
            if pad then
                pad = pad - #n2s_res if pad > 0 then return n2s_pad_cache[pad]..n2s_res else return n2s_res end
            else
                return n2s_res
            end
        else
            return format("%d", n)
        end
    else
        return ""..n --overflow
    end
end

--- float to string
function f2s(n, radius)
    radius = radius or 0
    if n>=0 and n<=100 and radius<=1 then
        if radius == 0 then
            return n2s_small[floor(n+0.5)]
        else
            local n2s_res = n2s_float[floor(n*10+.5)/10]
            if not n2s_res then
                n2s_res = format("%.1f", n)
                n2s_float[n] = n2s_res
            end
            return n2s_res
        end
    else
        return format(n2s_format[radius] or n2s_format[0], n)
    end
end

local n2s,safecall,copy,tinsertdata,tremovedata,f2s = n2s,safecall,copy,tinsertdata,tremovedata,f2s
LibStub("AceTimer-3.0"):Embed(core)
function CoreScheduleTimer(repeating, delay, callback, arg)
    if(repeating)then
        return core:ScheduleRepeatingTimer(callback, delay, arg)
    else
        return core:ScheduleTimer(callback, delay, arg)
    end
end
function CoreCancelTimer(handle, silent)
    return core:CancelTimer(handle, silent);
end
local allTimers = {}
function CoreScheduleBucket(timerName, delay, callback, arg)
    if allTimers[timerName] then
        CoreCancelTimer(allTimers[timerName])
    end
    local timer = CoreScheduleTimer(false, delay, function(...) allTimers[timerName] = nil callback(...) end, arg)
    allTimers[timerName] = timer
    return timer
end

function CoreCancelBucket(timerName)
    if allTimers[timerName] then
        CoreCancelTimer(allTimers[timerName])
    end
end

core.frame = CreateFrame("Frame")
local runOnNextCount = 0
local runOnNextFrame = {}
local runOnNextKeyCount = 0
local runOnNextKey = setmetatable({}, {__newindex = function(t, k, v) rawset(t, k, v) runOnNextKeyCount=runOnNextKeyCount+1 end})
core.frame:SetScript("OnUpdate", function(self)
    if runOnNextKeyCount > 0 then
        for k,v in next, runOnNextKey do
            safecall(v, k);
            runOnNextKey[k] = nil
        end
        runOnNextKeyCount = 0;
    end
    if runOnNextCount > 0 then
        local oldCount = runOnNextCount
        for i=1, oldCount do
            local v = runOnNextFrame[i];
            if v[1] then
                safecall(v[1], select(2, unpack(v)));
            end
            wipe(v);
        end
        runOnNextCount = runOnNextCount - oldCount;

        for i=1, runOnNextCount do
            copy(runOnNextFrame[i+runOnNextCount], runOnNextFrame[i]);
            wipe(runOnNextFrame[i+runOnNextCount]);
        end
    end
end)

--- call func on next update frame
function RunOnNextFrame(func, ...)
    --assert(type(func)=="function", "Parameter must be function.")
    runOnNextCount = runOnNextCount+1;
    local data=runOnNextFrame[runOnNextCount];
    if(not data)then
        data={};
        runOnNextFrame[runOnNextCount]=data;
    end
    data[1]=func;
    for i=1,select("#", ...) do
        data[i+1]=select(i, ...);
    end
end

function RunOnNextFrameKey(key, func)
    runOnNextKey[key] = func;
end

function RunOnNextFrameKeyCancel(key)
    runOnNextKey[key] = nil;
end

--- simple events dispatcher
-- @param addon table or frame with functions like addon:EVENT_A.
local CoreDispatchEventFunc;
function CoreDispatchEvent(frame, addon)
    frame.addon = addon or frame;
    CoreDispatchEventFunc = CoreDispatchEventFunc or function(self, event, ...)
        local func = self.addon[event];
        if(type(func)=="function")then
            func(self.addon, event, ...);
        else
            func = self.addon.DEFAULT_EVENT;
            if(type(func)~="function") then
                print("No function for ["..event.."]");
                return
            end
            func(self.addon, event, ...);
        end
    end
    frame:SetScript("OnEvent", CoreDispatchEventFunc);
end

local eventRegistration = {}
function CoreAddEvent(event)
    eventRegistration[event] = {};
end
function CoreRegisterEvent(event, obj)
    local reg = eventRegistration[event];
    assert(reg, "No event '"..event.."' is defined.");
    tinsert(reg, (WW and WW.un) and WW:un(obj) or obj._F or obj);
end
function CoreUnregisterEvent(event, obj)
    local reg = eventRegistration[event];
    assert(reg, "No event '"..event.."' is defined.");
    tremovedata(reg, WW and WW:un(obj) or obj._F or obj);
end
function CoreUnregisterAllEvents(obj)
    for k, v in pairs(eventRegistration) do
        CoreUnregisterEvent(k, obj);
    end
end
function CoreFireEvent(event, ...)
    --debug("event fired", event);
    local reg = eventRegistration[event];
    if(reg)then
        for i=1, #reg do
            local obj = reg[i]
            safecall(obj[event], obj, ...);
        end
    end
end

--- Call func if addon is loaded, or when addon is loaded
function CoreDependCall(addon, func, ...)
    local func = type(func) == "function" and func or _G[func];
    local func = type(func) == "function" and func or _G[func];
    if(IsAddOnLoaded(addon) and type(func)=="function") then
        func(...)
    else
        local params = {...}
        CoreOnEvent("ADDON_LOADED", function(event, name)
            if(name:lower() == addon:lower())then
                func(unpack(params));
                return true;
            end
        end)
    end
end

--- Core function if not in combat or when player leaves combat.
local leaveCombatCalls = {}
function CoreLeaveCombatCall(key, message, func)
    local func = type(func) == "function" and func or _G[func];
    assert(type(func)=="function", "param #2 should be function or function name.")
    if not InCombatLockdown() then
        safecall(func, key)
    else
        if message then U1Message(message) end
        leaveCombatCalls[key] = func;
    end
end

local eventFuncs = {}
local eventBucket, checkBucket = {}, false --eventBucket[event] = { {[1]=func, [2]=interval, [3]=timeLeft, [4]=needEndCall,}, ...}
core.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
core.frame:SetScript("OnEvent", function(self, event, ...)
    if event=="PLAYER_REGEN_ENABLED" then
        for key, func in next, leaveCombatCalls do safecall(func, key) end
        wipe(leaveCombatCalls);
    end
    local eventTable = eventFuncs[event];
    if eventTable then
        local i = 1;
        while i<=#eventTable do
            local status, result = safecall(eventTable[i], event, ...);
            if status and result then
                tremove(eventTable, i);
            else
                i = i + 1;
            end
        end
    end
    local eventTable = eventBucket[event]
    if eventTable then
        for i=1,#eventTable do
            local v=eventTable[i]
            local timer = v[3]
            if timer == nil then
                safecall(v[1], event)
                v[3] = v[2] -- reset timer to interval
            else
                v[4] = 1
            end
        end
    end
end)
CoreScheduleTimer(true, 0.2, function()
    if not checkBucket then return end
    for event, eventTable in pairs(eventBucket) do
        for i = 1, #eventTable do
            local v = eventTable[i]
            local timer = v[3];
            if timer then
                timer = timer - 0.1
                if timer<=0 then
                    if v[4] then
                        safecall(v[1], event);
                        v[4] = nil;
                        timer = v[2];
                    else
                        timer = nil
                    end
                end
                v[3] = timer
            end
        end
    end
end)

--- CoreOnEvent("VARIABLE_LOADED", func(event, ...) return "REMOVE!" end);
--- callback return true to remove.
function CoreOnEvent(event, func, frame)
    if frame then
        if type(frame)=="table" then
            frame:RegisterEvent(event);
            frame[event] = func;
        else
            local f = CreateFrame("Frame");
            CoreDispatchEvent(f)
            f:RegisterEvent(event);
            f[event] = func;
            return f;
        end
    end

    if(not core.frame:IsEventRegistered(event)) then
        core.frame:RegisterEvent(event);
    end
    local eventTable = eventFuncs[event];
    if(eventTable==nil)then eventTable={} eventFuncs[event]=eventTable end
    tinsert(eventTable, func);
end

--- Register an event which will not call more than once in 'interval' seconds
-- the callback func receive one and only one param - <the event string>
function CoreOnEventBucket(event, interval, func)
    if(not core.frame:IsEventRegistered(event)) then
        core.frame:RegisterEvent(event);
    end
    local eventTable = eventBucket[event];
    if(eventTable==nil) then eventTable={} eventBucket[event]=eventTable end
    tinsert(eventTable, {func, interval, 0})
    checkBucket = next(eventBucket) and true
end

--- call blizzard /dump
function dump(...)
    if not IsAddOnLoaded("Blizzard_DebugTools") then LoadAddOn("Blizzard_DebugTools") end
    DevTools_Dump(...);
end

function CoreCall(funcName, ...)
    local func = _G[funcName]
    return func and func(...);
end

--- use SetScript if the script is not set, otherwize use HookScript.
-- param keep will guarantee that func will never be replaced (by future SetScript calls).
function CoreHookScript(frame, scriptName, func, keep)
    if( frame:GetScript(scriptName) ) then
        frame:HookScript(scriptName, func);
    else
        frame:SetScript(scriptName, func);
    end
    if keep then
        hooksecurefunc(frame, "SetScript", function(self, name)
            if name==scriptName then
                self:HookScript(scriptName, func)
            end
        end)
    end
end

function CoreEncodeHTML(s, keepColor)
    if not keepColor then
        s = s:gsub("|c%x%x%x%x%x%x%x%x%[(.-)%]|r", "%1"):gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
    end
    s = s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
    return s;
end

hooksecurefunc("AddonTooltip_Update", function(owner)
	local name, title, notes, _, _, security = GetAddOnInfo(owner:GetID());
	if title then AddonTooltip:AddLine(L["Folder"].. ": " .. name) end
end)
