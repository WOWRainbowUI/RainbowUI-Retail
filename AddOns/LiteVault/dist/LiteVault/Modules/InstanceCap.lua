local addonName, lv = ...
local L = lv.L

lv.InstanceCap = lv.InstanceCap or {}

local WARNING_THRESHOLD = 8
local LOCK_THRESHOLD = 10
local WARNING_COOLDOWN = 300
local SLOT_OPEN_COOLDOWN = 10

local function EnsureDB()
    LiteVaultDB = LiteVaultDB or {}
    LiteVaultDB.instanceCap = LiteVaultDB.instanceCap or {}
    LiteVaultDB.instanceCap.hourlyRuns = LiteVaultDB.instanceCap.hourlyRuns or {}
    LiteVaultDB.instanceCap.lastWarning = LiteVaultDB.instanceCap.lastWarning or 0
end

local function TrimOld(nowTs)
    local nowTime = nowTs or time()
    EnsureDB()
    local kept = {}
    for _, ts in ipairs(LiteVaultDB.instanceCap.hourlyRuns) do
        if (nowTime - ts) < 3600 then
            kept[#kept + 1] = ts
        end
    end
    LiteVaultDB.instanceCap.hourlyRuns = kept
end

function lv.InstanceCap.RecordEntry()
    EnsureDB()
    TrimOld()
    table.insert(LiteVaultDB.instanceCap.hourlyRuns, time())
end

function lv.InstanceCap.GetCurrentCount()
    EnsureDB()
    TrimOld()
    return #LiteVaultDB.instanceCap.hourlyRuns
end

function lv.InstanceCap.GetStatus()
    local count = lv.InstanceCap.GetCurrentCount()
    if count >= LOCK_THRESHOLD then
        return "LOCKED"
    elseif count >= WARNING_THRESHOLD then
        return "WARNING"
    end
    return "SAFE"
end

function lv.InstanceCap.GetTimeUntilSlot()
    EnsureDB()
    TrimOld()
    if #LiteVaultDB.instanceCap.hourlyRuns == 0 then
        return 0
    end
    local oldest = LiteVaultDB.instanceCap.hourlyRuns[1]
    local remain = 3600 - (time() - oldest)
    return math.max(0, remain)
end

function lv.InstanceCap.CheckAndWarn()
    EnsureDB()
    local count = lv.InstanceCap.GetCurrentCount()
    if count < WARNING_THRESHOLD then
        return
    end

    local nowTs = time()
    if (nowTs - (LiteVaultDB.instanceCap.lastWarning or 0)) < WARNING_COOLDOWN then
        return
    end

    LiteVaultDB.instanceCap.lastWarning = nowTs
    local msg = (L and L["MSG_CAP_WARNING"]) or "Instance cap warning! %d/10 instances this hour."
    print("|cff9933ffLiteVault:|r " .. string.format(msg, count))
end

local function CheckForOpenedSlot()
    EnsureDB()
    local count = lv.InstanceCap.GetCurrentCount()
    local prev = LiteVaultDB.instanceCap.lastObservedCount

    if prev == nil then
        LiteVaultDB.instanceCap.lastObservedCount = count
        return
    end

    if count < prev then
        local nowTs = time()
        local lastOpenMsg = LiteVaultDB.instanceCap.lastOpenNotice or 0
        if (nowTs - lastOpenMsg) >= SLOT_OPEN_COOLDOWN then
            local msg = (L and L["MSG_CAP_SLOT_OPEN"]) or "An instance slot is now open! (%d/10 used)"
            print("|cff9933ffLiteVault:|r " .. string.format(msg, count))
            LiteVaultDB.instanceCap.lastOpenNotice = nowTs
        end
    end

    LiteVaultDB.instanceCap.lastObservedCount = count
end

local monitor = CreateFrame("Frame")
local elapsed = 0
monitor:RegisterEvent("PLAYER_LOGIN")
monitor:SetScript("OnEvent", function()
    EnsureDB()
    LiteVaultDB.instanceCap.lastObservedCount = lv.InstanceCap.GetCurrentCount()
end)
monitor:SetScript("OnUpdate", function(_, dt)
    elapsed = elapsed + dt
    if elapsed < 1 then return end
    elapsed = 0
    CheckForOpenedSlot()
end)
