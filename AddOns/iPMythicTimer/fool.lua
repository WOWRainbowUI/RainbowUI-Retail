local unix = time()
local day, month = strsplit('-', date('%d-%m', unix))

if not (tonumber(day) == 1 and tonumber(month) == 4) then return end

local AddonName, Addon = ...

Addon.fool = true
Addon.foolAffix = 9999
Addon.affixesCount = 5

function Addon:ShowFool()
    if Addon.fMain.fool == nil then
        Addon.fMain.fool = {}
        local point = 'RIGHT'
        local rPoint = 'LEFT'
        local x = -10
        if Addon.fMain:GetLeft() < 100 then
            point = 'LEFT'
            rPoint = 'RIGHT'
            x = 10
        end
        for value = 1,3 do
            Addon.fMain.fool[value] = CreateFrame("Button", nil, Addon.fMain, "IPButton")
            Addon.fMain.fool[value]:SetPoint(point, Addon.fMain, rPoint, x, -(value - 2)*24)
            Addon.fMain.fool[value]:SetSize(60, 20)
            Addon.fMain.fool[value]:SetText('+' .. (value*5) .. ' min')
            Addon.fMain.fool[value]:SetScript("OnClick", function(self)
                if IPMTDungeon.fool == nil then
                    IPMTDungeon.fool = 0
                end
                IPMTDungeon.fool = IPMTDungeon.fool + 300*value -- 5 min / 10min / 15min
            end)
        end
    end
    for value = 1,3 do
        Addon.fMain.fool[value]:Show()
    end
end

function Addon:HideFool()
    if Addon.fMain.fool == nil then
        return
    end
    for value = 1,3 do
        if Addon.fMain.fool[value] ~= nil then
            Addon.fMain.fool[value]:Hide()
        end
    end
end

function Addon:FoolUpdatePortrait()
    SetPortraitTexture(Addon.fMain.affix[1].Portrait, "player")
    if Addon.fMain.affix[1].Portrait:GetTexture() ~= nil then
        return
    end
    C_Timer.After(1, Addon.FoolUpdatePortrait)
end