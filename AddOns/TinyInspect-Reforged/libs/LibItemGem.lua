-- 臨時修正：使用新版 C_Item API，作者修正後優先採作者實作。
local GetItemInfo = (C_Item and C_Item.GetItemInfo) or _G.GetItemInfo
local GetItemGem = (C_Item and C_Item.GetItemGem) or _G.GetItemGem

local MAJOR, MINOR = "LibItemGem.7000", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then return end

function lib:GetItemGemInfo(ItemLink)
    local total, info = 0, {}
    local stats = C_Item.GetItemStats(ItemLink)
    for key, num in pairs(stats) do
        if (string.find(key, "EMPTY_SOCKET_")) then
            for i = 1, num do
                total = total + 1
                table.insert(info, { name = _G[key] or EMPTY, link = nil })
            end
        end
    end
    local quality = select(3, GetItemInfo(ItemLink))
    if (quality == 6 and total > 0) then
        total = 3
        for i = 1, total-#info do
            table.insert(info, { name = RELICSLOT or EMPTY, link = nil })
        end
    end
    local name, link
    for i = 1, 4 do
        name, link = GetItemGem(ItemLink, i)
        if (link) then
            if (info[i]) then
                info[i].name = name
                info[i].link = link
            else
                table.insert(info, { name = name, link = link })
            end
        end
    end
    return total, info, quality
end
