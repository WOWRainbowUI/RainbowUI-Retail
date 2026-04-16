-- 创建模块表
local _, addonTable = ...
local Countdown = {}
addonTable.Countdown = Countdown

local ticker = nil

-- 内部停止函数
function Countdown:Stop()
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
end

-- 内部开始函数
function Countdown:Start(timeRemaining)
    -- === 1. 检测 DBM 或 BigWigs (优先级最高，存在则不工作) ===
    if C_AddOns.IsAddOnLoaded("DBM-Core") or C_AddOns.IsAddOnLoaded("BigWigs") then
        return 
    end

    -- === 2. 动态获取语音包路径 ===
    local currentMediaPath = ""
    -- 检测“忘忧景久”语音包是否存在
    if C_AddOns.IsAddOnLoaded("DiGua-WYJJ") then
        currentMediaPath = "Interface\\AddOns\\DiGua-WYJJ\\Media\\"
    else
        -- 默认路径（主插件路径）
        currentMediaPath = "Interface\\AddOns\\DiGuaTimelineAudioHelper\\Media\\"
    end

    self:Stop() 

    local count = math.floor(timeRemaining)
    if count <= 0 then return end

    -- === 3. 内部播放逻辑 ===
    local function PlayVoice(num)
        -- 注意：确保 DiGua-WYJJ 文件夹下也有 Media\DaoShu1.ogg 等文件
        local path = currentMediaPath .. "DaoShu" .. num .. ".ogg"
        PlaySoundFile(path, "Master")
    end

    -- 立即播报起始数字
    PlayVoice(count)
    count = count - 1

    -- 如果剩余数字大于等于 0，启动计时器
    if count >= 0 then
        -- 这里的 count + 1 是循环次数
        ticker = C_Timer.NewTicker(1, function()
            if count > 0 then
                PlayVoice(count)
                count = count - 1
            elseif count == 0 then
                -- 播完 0 (如果有 DaoShu0.ogg 的话) 或者直接停止
                -- PlayVoice(0) -- 如果你有 0 的语音可以取消注释
                self:Stop()
            else
                self:Stop()
            end
        end, count + 1)
    end
end

-- 模块初始化（注册事件）
local frame = CreateFrame("Frame")
frame:RegisterEvent("START_PLAYER_COUNTDOWN")
frame:RegisterEvent("CANCEL_PLAYER_COUNTDOWN")

frame:SetScript("OnEvent", function(_, event, ...)
    if event == "START_PLAYER_COUNTDOWN" then
        local _, timeRemaining = ...
        Countdown:Start(timeRemaining)
    elseif event == "CANCEL_PLAYER_COUNTDOWN" then
        Countdown:Stop()
    end
end)