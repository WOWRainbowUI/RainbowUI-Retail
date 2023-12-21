local _G = _G

---------config-------------
--- 可以改这个数值，即可调整延迟多少秒时间加载。有的人立刻加载不行
local DELAY_TIME = 3
--- 文字输出相关
local PrintEnable = true --- 是否打印输出文字


local EnableYourCVars = true -- 开启你的输入
---------config end-----------

local GetTime = GetTime
local addon = {}

addon.eventframe = CreateFrame('Frame')

    --自定义体API，启用描边禁用阴影，可读性较佳 
local function SetFont(obj, optSize) 
  local fontName, _,fontFlags = obj:GetFont() 
  obj:SetFont(fontName, optSize, "THICKOUTLINE") 
  obj:SetShadowOffset(0, 0) 
end 

local function default() 
    --启用名字模式，注意这个CVAR是全局的，所以使用时必需搭配姓名板插件，否则敌方姓名板也没有血条 
    --如果你哪天不用这段代码了，光删代码删插件没用，要在游戏里输入 /run SetCVar("nameplateShowOnlyNames", 0) 才能恢复设置 
    SetCVar("nameplateShowOnlyNames", 1) 
     
    --将自定义字体API套用到姓名板的文字上 
    SetFont(SystemFont_LargeNamePlate, 16) 
    SetFont(SystemFont_NamePlate, 12) 
    SetFont(SystemFont_LargeNamePlateFixed, 16) 
    SetFont(SystemFont_NamePlateFixed, 12) 
    SetFont(SystemFont_NamePlateCastBar, 12) 
     
    --将友方姓名板的框架尺寸设为1，由于暴雪的CVAR只是单纯的隐藏血条，必需做这个设置，才能在堆叠模式下不挤占敌方姓名板空间 
    C_NamePlate.SetNamePlateFriendlySize(25,-28) 
    --将全局缩放设为1，否则引起掉帧(7.0最严重能掉一半，9.0掉个1/3吧) 
    SetCVar("namePlateMinScale", 1) 

    SetCVar("namePlateMaxScale", 1) 
     
    --下面随喜好 
     
    --边缘贴齐 
    -- SetCVar("nameplateOtherTopInset", .08) 
    -- SetCVar("nameplateOtherBottomInset", .1) 
    -- SetCVar("nameplateLargeTopInset", .08) 
    -- SetCVar("nameplateLargeBottomInset", .1) 
    --禁用点击，使用之后，对于友方玩家，点名字无法选中目标，要选模型 
    C_NamePlate.SetNamePlateFriendlyClickThrough(true) 
    --友方显示条件，把非玩家都隐去 
    SetCVar("nameplateShowFriendlyGuardians", 0) --守护者 
    SetCVar("nameplateShowFriendlyMinions", 0) --仆从 
    SetCVar("nameplateShowFriendlyNPCs", 0) --npc 
    SetCVar("nameplateShowFriendlyPets", 0) --宠物 
    SetCVar("nameplateShowFriendlyTotems", 0) --图腾 
  
end 

local lastEnterTime
local getFriendInfo = C_BattleNet.GetFriendGameAccountInfo
C_BattleNet.GetFriendGameAccountInfo = function(...)
    local gameInfo = getFriendInfo(...)
    gameInfo.isInCurrentRegion = true
    return gameInfo
end

local function realDoIt()
	if EnableYourCVars then
		default()
	end
end

local function OnTimerUpdate()
    if (GetTime() - lastEnterTime) >= DELAY_TIME then
        realDoIt()
		addon.eventframe:SetScript("OnUpdate", nil)
    end
end


function addon.OnEvent (frame, event, ...)
	if event == 'LOADING_SCREEN_DISABLED' then
		lastEnterTime = GetTime()
		addon.eventframe:SetScript("OnUpdate", OnTimerUpdate)
		addon.eventframe:UnregisterEvent("LOADING_SCREEN_DISABLED")
	end
end

addon.eventframe:SetScript('OnEvent', addon.OnEvent)
addon.eventframe:RegisterEvent("LOADING_SCREEN_DISABLED")