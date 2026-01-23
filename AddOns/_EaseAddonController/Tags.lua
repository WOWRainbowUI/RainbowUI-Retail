local _, U1 = ...;

--- if addon is officially packed
function U1IsNeteaseVendor(name)
    local reg, vendor = U1IsAddonRegistered(name)
    if not UI163_USER_MODE then
        return reg and vendor and true
    else
        return reg and true
    end
end

local function loadedFilter(name)
    local info = U1GetAddonInfo(name);
    return (not U1DB or not U1DB.selectedTag or U1AddonHasTag(name, U1DB.selectedTag)) and U1IsAddonEnabled(name)
end
local function notLoadedFilter(name)
    local info = U1GetAddonInfo(name);
    return (not U1DB or not U1DB.selectedTag or U1AddonHasTag(name, U1DB.selectedTag)) and not U1IsAddonEnabled(name)
end

local hide = { hide = 1 }

--- Tags Definitions. Name is _G["TAG_<ID>"], Description is _G["TAG_DESC_<ID>"]
U1.TAGS = {

    ALL = {
        order = 1,   --- order of tag, order < 0 means last.
        hide = 1,    --- list in tags pane, some tags are used to filter
        filter = function(name) return true end, --- only ALL, SINGLE, LOADED, NLOADED tags need filter.
    },

    NETEASE = { hide = 1, filter = U1IsNeteaseVendor, },

    SINGLE = {
        order = 6,
        filter = function(name) return not U1IsNeteaseVendor(name) end,
        hide = UI163_USER_MODE,
    },

    NOTAGS = {
        order = -1,
        filter = function(name)
            local info = U1GetAddonInfo(name)
            return (not info.registered or UI163_USER_MODE) and #info.tags == 0
        end,
    },

    CLASS = {
        order = 15,
        filter = function(name) return U1AddonHasTag(name, "CLASS") and U1AddonHasTag(name, U1PlayerClass) end
    },
    HUNTER = hide, WARLOCK = hide, PRIEST = hide, PALADIN = hide, MAGE = hide, ROGUE = hide, DRUID = hide, SHAMAN = hide, WARRIOR = hide, DEATHKNIGHT = hide, MONK = hide, DEMONHUNTER = hide,

    LOADED = { filter = loadedFilter, hide = 1, },
    NLOADED = { filter = notLoadedFilter, hide = 1, },
}
