local AppName = ...
local AL = LibStub("AceLocale-3.0")
local L = AL:NewLocale(AppName, "enUS", true)

L["focus"] = "Focus"
L["mouseover"] = "Mouseover"
L["pet"] = "Pet"
L["playertarget"] = "Target"
L["arena%d"]="Arena%d"
L["|cffeda55fControl + Left Click|r to lock frames"] = "|cffeda55fControl + Left Click|r to lock frames"
L["|cffeda55fDrag|r to move the frame"] = "|cffeda55fDrag|r to move the frame"
L["|cffeda55fLeft Click|r to lock/unlock frames"] = "|cffeda55fLeft Click|r to lock/unlock frames"
L["|cffeda55fShift + Left Click|r to toggle sound"] = "|cffeda55fShift + Left Click|r to toggle sound"
L["|cffeda55fRight Click|r to open the configuration window"] = "|cffeda55fRight Click|r to open the configuration window"

-- 自行加入
L["RangeDisplay: "] = "RangeDisplay: "

-----------------------------------------------------------------------------

L = AL:NewLocale(AppName, "zhCN")
if L then
L["|cffeda55fControl + Left Click|r to lock frames"] = "|cffeda55fCtrl+点击|r锁定所有框架"
L["|cffeda55fDrag|r to move the frame"] = "|cffeda55f拖拽|r 移动位置"
L["|cffeda55fLeft Click|r to lock/unlock frames"] = "|cffeda55f点击|r锁定/解锁框架"
L["|cffeda55fRight Click|r to open the configuration window"] = "|cffeda55f右击|r打开设置窗口"
L["|cffeda55fShift + Left Click|r to toggle sound"] = "|cffeda55fShift + 左键点击|r 来开启/关闭音效"
L["focus"] = "焦点"
L["mouseover"] = "鼠标悬停"
L["pet"] = "宠物"
L["playertarget"] = "目标"

end

L = AL:NewLocale(AppName, "zhTW")
if L then
L["focus"] = "專注目標"
L["mouseover"] = "滑鼠目標"
L["pet"] = "寵物"
L["playertarget"] = "當前目標"
L["arena%d"]="競技場%d"
L["|cffeda55fControl + Left Click|r to lock frames"] = "|cffeda55fCtrl+左鍵|r 鎖定所有框架"
L["|cffeda55fDrag|r to move the frame"] = "|cffeda55f拖曳|r 移動位置"
L["|cffeda55fLeft Click|r to lock/unlock frames"] = "|cffeda55f左鍵|r 鎖定/解鎖框架"
L["|cffeda55fRight Click|r to open the configuration window"] = "|cffeda55f右鍵|r 開啟設定視窗"
L["|cffeda55fShift + Left Click|r to toggle sound"] = "|cffeda55fShift + 左鍵|r 切換音效"

-- 自行加入
L["RangeDisplay: "] = "顯示距離: "
end

