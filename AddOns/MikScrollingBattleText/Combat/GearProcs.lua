local ns = MikSBT.CombatEngine
local GearProcs = {
    bySpell = {
        [21919] = { item = 17705, name = "Thrash Blade" },
        [15494] = { item = 11684, name = "Ironfoe" },
        [15601] = { item = 11815, name = "Hand of Justice" },
    },
}

function GearProcs.IsEquipped(rule)
    local client = MikSBT.Compatibility and MikSBT.Compatibility.Client
    if not (client and client.isForever and C_Item and C_Item.IsEquippedItem) then return false end
    local equipped = C_Item.IsEquippedItem(rule.item)
    return ns.Bool(equipped) and equipped
end

function GearProcs.Name(rule)
    local name = C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(rule.item)
    return ns.Text(name) and name or rule.name
end

ns.GearProcs = GearProcs
