
_G["i_loop"] = 1;
_G["RaidIcons"] = {8,7,5,3,6,1,2,4};

local frame = CreateFrame("FRAME", "QTFrame");
frame:RegisterEvent("PLAYER_REGEN_ENABLED");
local function eventHandler(self, event, ...)
    QTReset();
end
frame:SetScript("OnEvent", eventHandler);

function RoundRobin()
    if UnitExists("mouseover") then
        if (_G["i_loop"] <= 0 or _G["i_loop"] >= 9) then
            _G["i_loop"] = 1;
        end
        SetRaidTarget("mouseover", _G["RaidIcons"][_G["i_loop"]]);
        if ((_G["i_loop"] + 1) > 8) then
            _G["i_loop"] = 1;
        else
            _G["i_loop"] = i_loop + 1;
        end
    end
end

function QTReset()
    _G["i_loop"] = 1;
end

function QTClear()
    if UnitExists("mouseover") then
        SetRaidTarget("mouseover", 0);
    end
end