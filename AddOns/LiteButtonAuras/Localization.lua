--[[----------------------------------------------------------------------------

    LiteButtonAuras
    Copyright 2024 Mike "Xodiv" Battersby

    您好，請幫忙翻譯一下
    https://legacy.curseforge.com/wow/addons/litebuttonauras/localization
    https://github.com/xod-wow/LiteButtonAuras/issues

----------------------------------------------------------------------------]]--

local _, LBA = ...

LBA.L = setmetatable({}, { __index = function (_,k) return k end })

local L = LBA.L

local locale = GetLocale()

-- :r! sh fetchlocale.sh -------------------------------------------------------

-- zhCN ------------------------------------------------------------------------

if locale == "zhCN" then
    L = L or {}
    L["Add ability"] = "添加技能"
    L["Aura list"] = "光环清单"
    L["Automatically match auras to abilities by name."] = "自动将名称相同的光环与技能配对"
    L["Bottom"] = "下"
    L["Bottom left"] = "左下"
    L["Bottom right"] = "右下"
    L["Center"] = "中间"
    L["Color aura duration timers based on remaining time."] = "依据剩余时间变化文字颜色"
    L["Display aura duration timers."] = "显示光环持续时间"
    L["Display buffs cast by you on your pet."] = "显示你施放在你的宠物身上的增益"
    L["Error: unknown ability spell: %s"] = "错误: 未知的技能法术: %s"
    L["Error: unknown aura spell: %s"] = "错误: 未知的光环法术: %s"
    L["Error: unknown spell: %s"] = "错误: 未知的法术: %s"
    L["Extra aura displays"] = "额外显示光环"
    L["Font name"] = "字体"
    L["Font size"] = "文字大小"
    L["For spells that aren't in your spell book use the spell ID number."] = "不在你的法术书里面的法术请使用法术 ID 数字"
    L["Highlight buttons for interrupt and soothe."] = "断法和安抚按钮发光"
    L["If you disable this option, only auras explicitly configured under \"Extra aura displays\" will be shown."] = "停用此选项时，只会显示在 \"额外显示光环 \" 中有明确设定的光环。"
    L["Ignored abilities"] = "忽略技能"
    L["Left"] = "左"
    L["on"] = "于"
    L["On ability"] = "于技能"
    L["Right"] = "右"
    L["Show aura"] = "显示光环"
    L["Show aura stacks."] = "显示光环层数"
    L["Show fractions of a second on timers."] = "时间显示小数点"
    L["Stack text offset"] = "层数位置偏移"
    L["Stack text position"] = "层数位置"
    L["Text positions"] = "位置"
    L["Timer text offset"] = "时间位置偏移"
    L["Timer text position"] = "时间位置"
    L["Top"] = "上"
    L["Top left"] = "左上"
    L["Top right"] = "右上"
    L["Wiping aura list."] = "正在清空光环清单。"
end

-- zhTW ------------------------------------------------------------------------

if locale == "zhTW" then
    L = L or {}
    L["Add ability"] = "添加技能"
    L["Aura list"] = "光環清單"
    L["Automatically match auras to abilities by name."] = "自動將名稱相同的光環與技能配對"
    L["Bottom"] = "下"
    L["Bottom left"] = "左下"
    L["Bottom right"] = "右下"
    L["Center"] = "中間"
    L["Color aura duration timers based on remaining time."] = "依據剩餘時間變化文字顏色"
    L["Display aura duration timers."] = "顯示光環持續時間"
    L["Display buffs cast by you on your pet."] = "顯示你施放在你的寵物身上的增益"
    L["Error: unknown ability spell: %s"] = "錯誤: 未知的技能法術: %s"
    L["Error: unknown aura spell: %s"] = "錯誤: 未知的光環法術: %s"
    L["Error: unknown spell: %s"] = "錯誤: 未知的法術: %s"
    L["Extra aura displays"] = "額外顯示光環"
    L["Font name"] = "字體"
    L["Font size"] = "文字大小"
    L["For spells that aren't in your spell book use the spell ID number."] = "不在你的法術書裡面的法術請使用法術 ID 數字"
    L["Highlight buttons for interrupt and soothe."] = "斷法和安撫按鈕發光"
    L["If you disable this option, only auras explicitly configured under \"Extra aura displays\" will be shown."] = "停用此選項時，只會顯示在 \"額外顯示光環\" 中有明確設定的光環。"
    L["Ignored abilities"] = "忽略技能"
    L["Left"] = "左"
    L["on"] = "於"
    L["On ability"] = "於技能"
    L["Right"] = "右"
    L["Show aura"] = "顯示光環"
    L["Show aura stacks."] = "顯示光環層數"
    L["Show fractions of a second on timers."] = "時間顯示小數點"
    L["Stack text offset"] = "層數位置偏移"
    L["Stack text position"] = "層數位置"
    L["Text positions"] = "位置"
    L["Timer text offset"] = "時間位置偏移"
    L["Timer text position"] = "時間位置"
    L["Top"] = "上"
    L["Top left"] = "左上"
    L["Top right"] = "右上"
    L["Wiping aura list."] = "正在清空光環清單。"
	
	-- 自行加入
	L["LiteButtonAuras"] = "光環時間"
	L["Lite Button Auras"] = "光環時間 (快捷列)"
	L["Font"] = "文字"
end
