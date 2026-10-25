local addonName, lv = ...

lv.MountDrops = lv.MountDrops or {}

-- InstanceID -> list of journalMountIDs that can drop in that instance.
local INSTANCE_MOUNTS = {
    [249] = {349},
    [329] = {69},
    [532] = {168},
    [550] = {183},
    [556] = {185},
    [575] = {264},
    [585] = {213},
    [603] = {304},
    [616] = {246, 247},
    [624] = {286},
    [631] = {363},
    [657] = {395},
    [720] = {425, 415},
    [725] = {397},
    [754] = {396},
    [859] = {410, 411},
    [967] = {442, 444, 445},
    [1008] = {478},
    [1098] = {531, 543},
    [1136] = {559},
    [1205] = {613},
    [1448] = {751},
    [1530] = {791, 633},
    [1651] = {875},
    [1676] = {899},
    [1712] = {954, 971},
    [1754] = {995},
    [1762] = {1040},
    [1841] = {1053},
    [2070] = {1217, 1219},
    [2097] = {1252},
    [2217] = {1293},
    [2286] = {1406},
    [2441] = {1481},
    [2450] = {1471, 1500},
    [2481] = {1587},
    [2549] = {1818},
    [2651] = {2204},
    [2657] = {2219, 2223},
    [2769] = {2507, 2487},
    [2810] = {2606, 2569},
}

function lv.MountDrops.GetInstanceMountStatus(instanceID)
    if not instanceID then return nil end
    local mounts = INSTANCE_MOUNTS[instanceID]
    if not mounts or #mounts == 0 then
        return nil
    end
    if not C_MountJournal or not C_MountJournal.GetMountInfoByID then
        return nil
    end

    local total = 0
    local owned = 0
    local entries = {}
    for _, journalID in ipairs(mounts) do
        local name, _, icon, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(journalID)
        total = total + 1
        if isCollected then
            owned = owned + 1
        end
        entries[#entries + 1] = {
            journalID = journalID,
            name = name or ("Mount " .. tostring(journalID)),
            icon = icon,
            collected = isCollected and true or false,
        }
    end
    if total == 0 then
        return nil
    end
    return {
        total = total,
        owned = owned,
        allCollected = (owned == total),
        entries = entries,
    }
end
