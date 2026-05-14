local Name, AddOnesTable = ...
local VCH = AddOnesTable.VCH
local D = AddOnesTable.D

VCH.MG_displayItemIDs = {
    [1315] = 268473, -- 迈萨拉洞窟
    [1299] = 268471, -- 风行者之塔
    [476] = 268470,  -- 通天峰
    [945] = 268469,  -- 执政团之座
    [278] = 268468,  -- 萨隆矿坑
    [1316] = 268467, -- 节点
    [1300] = 268466, -- 魔导师平台
    [1201] = 268465, -- 学院
}

VCH.MR_displayItemIDs = {
    [2733] = 268459, -- 元首阿福扎恩
    [2734] = 268460, -- 弗拉希乌斯
    [2736] = 268461, -- 陨落之王萨哈达尔
    [2735] = 268462, -- 威厄高尔和艾佐拉克
    [2737] = 268463, -- 光盲先锋军
    [2738] = 267488, -- 宇宙之冕

    [2795] = 268464, -- 奇美鲁斯，未梦之神

    [2739] = 268458, -- 贝洛朗，奥的子嗣
    [2740] = 262658, -- 至暗之夜降临
}

VCH.MR_upper = {
    [268459] = 0, -- 元首阿福扎恩
    [268460] = 2, -- 弗拉希乌斯
    [268461] = 2, -- 陨落之王萨哈达尔
    [268462] = 3, -- 威厄高尔和艾佐拉克
    [268463] = 3, -- 光盲先锋军
    [267488] = 4, -- 宇宙之冕

    [268464] = 2, -- 奇美鲁斯，未梦之神

    [268458] = 4, -- 贝洛朗，奥的子嗣
    [262658] = 4, -- 至暗之夜降临
}

VCH.UG_displayItemIDs = {
    268969, -- 地下堡
    269768 -- 狩猎
}

local itemLevelString = "^" .. gsub(ITEM_LEVEL, "%%d", "(%%d+)")
local upperString = "^" .. gsub(ITEM_UPGRADE_TOOLTIP_FORMAT_STRING, "%%s %%d/%%d", "(.*)%%s(%%d+)/(%%d+)")

local itemString = "^-%s(.*)"

VCH.treasureContextLevel_1 = 2
VCH.treasureContextLevel_2 = 10

local function getLootList(displayItemID, itemContext, treasureContextLevel)
    local displayName, itemLevel, upper1, upper2, upper3, item, orgItem = nil, nil, nil, nil, nil, {}, {}

    local data = C_TooltipInfo.GetItemByID(displayItemID, nil, itemContext, treasureContextLevel);
    if data ~= nil then
        local content = data.lines
        for i, tooltipDataLine in ipairs(content) do
            local text = tooltipDataLine.leftText
            if i == 1 then
                local start, _end = strfind(text, "：")
                if not _end or _end < 1 then
                    start, _end = strfind(text, ": ")
                end
                if not _end or _end < 1 then
                    return {}
                end
                displayName = strsub(text, _end + 1)
            end
            if itemLevel == nil then
                itemLevel = strmatch(text, itemLevelString)
            end
            if upper1 == nil then
                upper1, upper2, upper3 = strmatch(text, upperString)
            end
            local item_text = strmatch(text, itemString)
            table.insert(orgItem, item_text)
            if item_text ~= nil then
                local color = tooltipDataLine.leftColor
                item_text = "|c" .. color:GenerateHexColor() .. item_text .. "|r"
            end
            table.insert(item, item_text)
        end
    end
    return {
        displayName = displayName,
        itemLevel = itemLevel,
        upper = upper1 .. upper2 .. "/" .. upper3,
        item = item,
        orgItem = orgItem
    }
end


---@param displayItemIDs table|number
---@param treasureContextLevel table|number
function VCH:FreshDungeon(displayItemIDs, treasureContextLevel, cb)
    if displayItemIDs == nil then return end
    if type(displayItemIDs) == "number" then displayItemIDs = { displayItemIDs } end
    local i = 1
    for _, displayItemID in pairs(displayItemIDs) do
        C_Timer.After(i, function()
            getLootList(displayItemID, 16, treasureContextLevel)
            C_Timer.After(0.5, function()
                local lootData_item = getLootList(displayItemID, 16, treasureContextLevel)
                if lootData_item.displayName == nil then
                else
                    local lootData = D:ReadDB("lootData", {})
                    lootData[displayItemID .. "_" .. treasureContextLevel] = lootData_item
                    D:SaveDB("lootData", lootData)
                end
                if cb then cb() end
            end)
        end)
        i = i + 1
    end
end

local queue = {}
---@param displayItemIDs table|number
---@param treasureContextLevel table|number
function VCH:FreshDungeonQueue(displayItemIDs, treasureContextLevel)
    if #queue > 50 then return end
    tinsert(queue, { displayItemIDs, treasureContextLevel })
end

local eventFrame = CreateFrame("frame", nil, UIParent)
eventFrame:Hide()
-- eventFrame:RegisterEvent("SPELL_CONFIRMATION_PROMPT")
-- eventFrame:RegisterEvent("PLAYER_LOGIN")
-- eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
local lastTime = GetTime()
-- eventFrame:SetScript("OnUpdate", function ()
--     local now = GetTime()
--     if now - lastTime < 1.7 then
--         lastTime = now
--         local item = queue[1]
--         if item then
--             VCH:FreshDungeon(item[1], item[2], function ()
--                 queue[1] = nil
--             end)
--         end
--     end
-- end)
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "SPELL_CONFIRMATION_PROMPT" then
        local spellID, confirmType, text, duration, currencyID, currencyCost, difficultyID, displayItemID, itemContext, treasureContextLevel = ...;
        local saveData = {
            spellID = spellID,
            confirmType = confirmType,
            text = text,
            duration = duration,
            currencyID = currencyID,
            currencyCost = currencyCost,
            difficultyID = difficultyID,
            displayItemID = displayItemID,
            itemContext = itemContext,
            treasureContextLevel = treasureContextLevel
        }
        local scr_data = D:ReadDB("scr_data", {})
        tinsert(scr_data, saveData)
        D:SaveDB("scr_data", scr_data)
    end
    if event == "PLAYER_LOGIN" then

    end
    if event == "PLAYER_ENTERING_WORLD" then

    end
end)


eventFrame:SetScript("OnEnter", function(self)
end)

eventFrame:SetScript("OnLeave", function()
end)
