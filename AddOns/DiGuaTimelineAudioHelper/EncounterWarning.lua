-- EncounterWarning.lua

local addonName, addonTable = ... 

-- ------------------------------------------
-- 独立事件分发控制中心（直接平铺业务逻辑）
-- ------------------------------------------
local WarningFrame = CreateFrame("Frame")
WarningFrame:RegisterEvent("ENCOUNTER_WARNING")
WarningFrame:RegisterEvent("RAID_BOSS_EMOTE")

WarningFrame:SetScript("OnEvent", function(self, event, ...)
    if event ~= "RAID_BOSS_EMOTE" and event ~= "ENCOUNTER_WARNING" then return end

    local encounterWarningInfo = ...
    
    -- if encounterWarningInfo then
    --     print("|cffffd100[Debug] 捕获到实时事件数据:|r")
        
    --     -- 1. 文本类
    --     print("文本 (text):", encounterWarningInfo.text)
    --     print("施法者 (casterName):", encounterWarningInfo.casterName)
    --     print("目标 (targetName):", encounterWarningInfo.targetName)
        
    --     -- 2. GUID
    --     print("施法者GUID:", encounterWarningInfo.casterGUID)
    --     print("目标GUID:", encounterWarningInfo.targetGUID)
        
    --     -- 3. 数字/ID
    --     print("图标ID (iconFileID):", encounterWarningInfo.iconFileID)
    --     print("技能ID (tooltipSpellID):", encounterWarningInfo.tooltipSpellID)
    --     print("持续时间 (duration):", encounterWarningInfo.duration)
    --     print("严重程度 (severity):", encounterWarningInfo.severity)
        
    --     -- 4. 布尔值
    --     print("是否致命 (isDeadly):", tostring(encounterWarningInfo.isDeadly))
    --     print("播放声音 (shouldPlaySound):", tostring(encounterWarningInfo.shouldPlaySound))
    --     print("聊天框消息 (shouldShowChatMessage):", tostring(encounterWarningInfo.shouldShowChatMessage))
    --     print("显示警告 (shouldShowWarning):", tostring(encounterWarningInfo.shouldShowWarning))
        
    --     -- 5. 颜色
    --     if encounterWarningInfo.color then
    --         print("颜色 (RGB):", encounterWarningInfo.color.r, encounterWarningInfo.color.g, encounterWarningInfo.color.b)
    --     else
    --         print("颜色: nil")
    --     end

    -- else
    --     print("|cffff0000[Error] 事件触发但数据为空|r")
    -- end

    -- 【安全安全防护】如果是表情事件，把纯文本字符串动态包成表，完美兼容下面的所有逻辑，防止报错
    if event == "RAID_BOSS_EMOTE" then
        encounterWarningInfo = {
            text = encounterWarningInfo, -- 此时第一个参数其实是 text 字符串
            severity = 0,
            duration = 0,
            targetName = nil
        }
    end

    if not encounterWarningInfo then return end

    -- 实时从小函数里捞取主文件内部最新的隐身 local 变量
    local currentEncounterID = addonTable.GetEncounterID()
    local startTime = addonTable.GetStartTime()
    local MEDIA_PATH = addonTable.GetMediaPath() or "Interface\\AddOns\\DiGuaTimelineAudioHelper\\Media\\"
    local currentMap = C_Map.GetBestMapForUnit("player")

    -- ------------------------------------------
    -- 1. 纯地图 / 环境判定
    -- ------------------------------------------
    -- 技能：恐惧之风
    if (currentMap == 601 or currentMap == 602) and currentEncounterID == 0 then
        PlaySoundFile(MEDIA_PATH .. "XiaoXinJiTui.ogg", DiGuaTimelineAudioHelper.audioChannel)
        addonTable.StartCircleTimerBySeconds(2.7)
        return
    end
    -- 技能：仪式献祭
    if currentMap == 2501 and currentEncounterID == 0 then
        PlaySoundFile(MEDIA_PATH .. "ZhuYiJiuRen.ogg", DiGuaTimelineAudioHelper.audioChannel)
        return
    end

    if select(8, GetInstanceInfo()) == 658 and encounterWarningInfo.duration == 3.5 and currentMap == 184 then
        if IsIndoors() then
            PlaySoundFile(MEDIA_PATH .. "WuMaFenSanSanErYiZhuYiJiaoXia.ogg", DiGuaTimelineAudioHelper.audioChannel)
            addonTable.StartCircleTimerBySeconds(5.1)
            
            addonTable.SetWarningTriggered(true)
            C_Timer.After(1, function()
                addonTable.SetWarningTriggered(false)
            end)  
        end
        return
    end

    -- ------------------------------------------
    -- 2. 特定技能判定
    -- ------------------------------------------
    local severity = encounterWarningInfo.severity or 0
    local duration = encounterWarningInfo.duration or 0
    local targetName = encounterWarningInfo.targetName

    -- 技能：强风
    if currentMap == 2514 and currentEncounterID == 0 and severity == 2 and duration == 5 and not targetName 
    and (C_ScenarioInfo.GetCriteriaInfo(1) and C_ScenarioInfo.GetCriteriaInfo(1).completed or false) == true -- Boss1
    and (C_ScenarioInfo.GetCriteriaInfo(2) and C_ScenarioInfo.GetCriteriaInfo(2).completed or false) == false -- Boss2    
    then 
        PlaySoundFile(MEDIA_PATH .. "KuaiZhaoYanTi.ogg", DiGuaTimelineAudioHelper.audioChannel)
        return
    end


    -- 技能：炽焰腾流
    if currentEncounterID == 3056 and severity == 1 then
        PlaySoundFile(MEDIA_PATH .. "TieBianFangShuiSanMiaoSanErYi.ogg", DiGuaTimelineAudioHelper.audioChannel)
        addonTable.StartCircleTimerBySeconds(6)
        return
    end

    -- 技能：炫光
    if currentEncounterID == 1701 and severity == 2 then
        addonTable.SetCastStarted(true)
        C_Timer.After(0.6, function()
            addonTable.SetCastStarted(false)
        end)
        return
    end

    -- 技能：光明灌注
    if currentEncounterID == 3101 and severity == 1 then
        C_Timer.After(14, function()
            if addonTable.GetEncounterID() == 3101 then 
                addonTable.PlayAudioSequence(0, "DaoShu3.ogg", 1, "DaoShu2.ogg", 1, "DaoShu1.ogg", 1, "YiShangJieShu.ogg")
            end
        end)            
        return
    end

    -- 技能：嗜血注视
    if currentEncounterID == 3200 and severity == 2 then
        addonTable.PlayAudioSequence(11, "DaoShu3.ogg", 1, "DaoShu2.ogg", 1, "DaoShu1.ogg", 1, "AnQuan.ogg")
        return
    end

    -- 技能：专制命令
    if currentEncounterID == 3179 and severity == 0 then
        addonTable.StartCircleTimerBySeconds(12)
        return
    end

    -- 技能：残杀
    if currentEncounterID == 2065 and targetName then
        addonTable.StartCircleTimerBySeconds(5)
        return
    end

    -- 技能：震耳尖啸
    if currentEncounterID == 2564 and severity == 1 then
        addonTable.StartCircleTimerBySeconds(2.3, true)
        return
    end        

    -- 技能：静默浪潮
    if currentEncounterID == 3072 and severity == 2 then
        addonTable.StartCircleTimerBySeconds(4.8)
        return
    end

    -- 技能：黑暗诅咒和飞溅喷吐
    if currentEncounterID == 3057 and severity == 1 then
        addonTable.StartCircleTimerBySeconds(4.1)
        return
    end        

    -- 技能：星界束缚
    if currentEncounterID == 3073 and severity == 2 then
        addonTable.PlayAudioSequence(9, "DaoShu3.ogg", 1, "DaoShu2.ogg", 1, "DaoShu1.ogg", 1, "AnQuan.ogg")
        return
    end

    -- 技能：复生
    if currentEncounterID == 3182 and severity == 1 then
        C_Timer.After(35, function()
            if addonTable.GetEncounterID() == 3182 then
                addonTable.PlayAudioSequence(0, "DaoShu5.ogg", 1, "DaoShu4.ogg", 1, "DaoShu3.ogg", 1, "DaoShu2.ogg", 1, "DaoShu1.ogg")
            end
        end)
        C_Timer.After(44, function()
            if addonTable.GetEncounterID() == 3182 then
                addonTable.PlayAudioSequence(0, "KaiShiHuanSe.ogg")
            end
        end)
        return
    end

    -- 技能：粉碎灵魂
    if currentEncounterID == 3214 and severity == 1 then
        addonTable.StartCircleTimerBySeconds(4.5)
        return
    end

    -- 技能：干扰震荡
    if currentEncounterID == 3181 and severity == 1 and not targetName and duration == 3.5 then
        local preciseTime = GetTime() - startTime
        if (preciseTime >= 3 and preciseTime <= 6) or 
           (preciseTime >= 24 and preciseTime <= 26) or 
           (preciseTime >= 40 and preciseTime <= 42) then
            addonTable.StartCircleTimerBySeconds(5, true)
        end
        return
    end

    -- 技能：银峰箭/游侠印记/终末守护
    if currentEncounterID == 3181 and severity == 1 and targetName and duration == 5 then
        addonTable.StartCircleTimerBySeconds(6, true)
        return
    end

    -- 技能：亡者吐息
    if currentEncounterID == 3178 and severity == 1 and encounterWarningInfo.shouldPlaySound == true then
        local _, _, difficultyID = GetInstanceInfo()            
        if difficultyID == 16 then 
            local preciseTime = GetTime() - startTime
            if (preciseTime >= 4 and preciseTime <= 6) or
               (preciseTime >= 69 and preciseTime <= 71) or
               (preciseTime >= 131 and preciseTime <= 134) or
               (preciseTime >= 190 and preciseTime <= 193) or
               (preciseTime >= 315 and preciseTime <= 318) or
               (preciseTime >= 359 and preciseTime <= 362) or
               (preciseTime >= 411 and preciseTime <= 414) then
                addonTable.StartCircleTimerBySeconds(6)
            end
        end
        return
    end

    -- 技能：动态判断史诗难度计时条 -- 星辰裂片
    if currentEncounterID == 3183 and severity == 1 then
        local _, _, difficultyID = GetInstanceInfo()
        local timerDuration = (difficultyID == 16) and 2.9 or 3.9
        addonTable.StartCircleTimerBySeconds(timerDuration)
        return 
    end

    -- 技能：光痕
    if currentEncounterID == 3332 and not targetName and severity == 2 then
        C_Timer.After(21, function()
            if addonTable.GetEncounterID() ~= 0 then
                addonTable.PlayAudioSequence(0, "DaoShu5.ogg", 1, "DaoShu4.ogg", 1, "DaoShu3.ogg", 1, "DaoShu2.ogg", 1, "DaoShu1.ogg", 1, "YiShangJieShu.ogg")
            end
        end)
        return
    end
end)