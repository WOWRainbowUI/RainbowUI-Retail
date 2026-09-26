--[[
    RGX-Framework - API Compatibility Layer

    Provides guarded access to WoW API functions that may not exist on all
    client flavors (especially the WoW Forever beta). Consumers call
    RGX.API.functionName(...) instead of the raw global, and the framework
    handles the fallback chain.

    Usage:
        local GetItemInfoSafe = RGX.API.GetItemInfo
        local name, link = GetItemInfoSafe(itemID)

    Or access the whole table:
        local API = RGX.API
        API.GetCoinText(totalPrice)
--]]

local _, RGX = ...

RGX.API = {}

local function FirstAvailable(...)
    for i = 1, select("#", ...) do
        local fn = select(i, ...)
        if type(fn) == "function" then
            return fn
        end
    end
    return nil
end

local function Identity(...)
    return ...
end

local function Nil() return nil end

--------------------------------------------------------------------------------
-- Item system
--------------------------------------------------------------------------------

RGX.API.GetItemInfo = FirstAvailable(
    _G.C_Item and _G.C_Item.GetItemInfo,
    _G.GetItemInfo
) or Nil

RGX.API.GetItemIcon = FirstAvailable(
    _G.C_Item and _G.C_Item.GetItemIconByID,
    _G.GetItemIcon
) or function() return "Interface\\Icons\\INV_Misc_QuestionMark" end

RGX.API.GetItemInfoFromHyperlink = _G.GetItemInfoFromHyperlink
    or function(link)
        if type(link) == "string" then
            return tonumber(link:match("item:(%d+)"))
        end
        return nil
    end

RGX.API.GetItemQualityColor = _G.GetItemQualityColor
    or function(quality)
        local colors = {
            [0] = {0.62, 0.62, 0.62, "9d9d9d"},
            [1] = {1.00, 1.00, 1.00, "ffffff"},
            [2] = {0.12, 1.00, 0.12, "1eff00"},
            [3] = {0.00, 0.44, 0.87, "0070dd"},
            [4] = {0.64, 0.00, 0.93, "a335ee"},
            [5] = {1.00, 0.50, 0.00, "ff8000"},
        }
        local c = colors[quality]
        if c then
            return c[1], c[2], c[3], c[4], quality
        end
        return 1, 1, 1, "ffffff", quality
    end

--------------------------------------------------------------------------------
-- Container system
--------------------------------------------------------------------------------

local ContainerUtil = _G.C_Container or {}

RGX.API.UseContainerItem = FirstAvailable(
    ContainerUtil.UseContainerItem,
    _G.UseContainerItem
) or Nil

RGX.API.PickupContainerItem = FirstAvailable(
    ContainerUtil.PickupContainerItem,
    _G.PickupContainerItem
) or Nil

RGX.API.GetContainerItemInfo = FirstAvailable(
    ContainerUtil.GetContainerItemInfo,
    _G.GetContainerItemInfo
) or Nil

RGX.API.GetContainerNumSlots = FirstAvailable(
    ContainerUtil.GetContainerNumSlots,
    _G.GetContainerNumSlots
) or function() return 0 end

RGX.API.GetContainerNumFreeSlots = FirstAvailable(
    ContainerUtil.GetContainerNumFreeSlots,
    _G.GetContainerNumFreeSlots
) or function() return 0 end

RGX.API.SplitContainerItem = FirstAvailable(
    ContainerUtil.SplitContainerItem,
    _G.SplitContainerItem
) or Nil

--------------------------------------------------------------------------------
-- Money/text
--------------------------------------------------------------------------------

RGX.API.GetCoinText = FirstAvailable(
    _G.GetCoinText,
    _G.GetMoneyString,
    _G.C_CurrencyInfo and _G.C_CurrencyInfo.GetCoinText
) or function(amount)
    local gold = math.floor(amount / 10000)
    local silver = math.floor((amount % 10000) / 100)
    local copper = amount % 100
    if gold > 0 then
        return string.format("%dg %ds %dc", gold, silver, copper)
    elseif silver > 0 then
        return string.format("%ds %dc", silver, copper)
    end
    return string.format("%dc", copper)
end

--------------------------------------------------------------------------------
-- Party/raid
--------------------------------------------------------------------------------

RGX.API.UnitInRaid = _G.UnitInRaid or function() return false end
RGX.API.UnitInParty = _G.UnitInParty or function() return false end
RGX.API.UnitIsGroupLeader = _G.UnitIsGroupLeader or function() return false end

RGX.API.UninviteUnit = FirstAvailable(
    _G.C_PartyInfo and _G.C_PartyInfo.RemoveFromParty,
    _G.UninviteUnit
) or Nil

RGX.API.LeaveParty = FirstAvailable(
    _G.C_PartyInfo and _G.C_PartyInfo.LeaveParty,
    _G.LeaveParty
) or Nil

--------------------------------------------------------------------------------
-- Raid targeting
--------------------------------------------------------------------------------

RGX.API.SetRaidTarget = _G.SetRaidTarget or Nil
RGX.API.GetRaidTargetIndex = _G.GetRaidTargetIndex or Nil

--------------------------------------------------------------------------------
-- Resurrection
--------------------------------------------------------------------------------

RGX.API.AcceptResurrect = _G.AcceptResurrect or Nil
RGX.API.DeclineResurrect = _G.DeclineResurrect or Nil

--------------------------------------------------------------------------------
-- Taxi/transport
--------------------------------------------------------------------------------

RGX.API.TakeTaxiNode = _G.TakeTaxiNode or Nil

--------------------------------------------------------------------------------
-- Map/position
--------------------------------------------------------------------------------

RGX.API.GetBestMapForUnit = FirstAvailable(
    _G.C_Map and _G.C_Map.GetBestMapForUnit,
    _G.GetCurrentMapAreaID
) or Nil

--------------------------------------------------------------------------------
-- Debug: report which APIs are missing on this client
--------------------------------------------------------------------------------

function RGX.API.GetMissingAPIs()
    local missing = {}
    local checks = {
        "GetItemInfo", "GetItemIcon", "GetCoinText",
        "UseContainerItem", "PickupContainerItem",
        "GetContainerItemInfo", "GetContainerNumSlots",
        "UnitInRaid", "UnitInParty", "UnitIsGroupLeader",
        "SetRaidTarget", "AcceptResurrect", "TakeTaxiNode",
    }
    for _, name in ipairs(checks) do
        local fn = RGX.API[name]
        if fn == Nil or fn == nil then
            table.insert(missing, name)
        end
    end
    return missing
end
