---@class RemixGemHelperPrivate
local Private = select(2, ...)
local addon = Private.Addon
local const = Private.constants
local function getCloakLevel()
    local level = 0
    for achievementID = const.CLOAK_BUFF.ACHIEVEMENT_ID_START, const.CLOAK_BUFF.ACHIEVEMENT_ID_END do
        local completed = select(4, GetAchievementInfo(achievementID))
        if completed then
            level = level + 1
        end
    end
    return string.format(" [%s %d/12]", addon.Loc["Rank"], level)
end

local function getCloakStats()
    local cloakAura = C_UnitAuras.GetPlayerAuraBySpellID(const.CLOAK_BUFF.AURA_ID)
    if not cloakAura then return end
    local cloakTooltip = C_TooltipInfo.GetUnitBuffByAuraInstanceID("player", cloakAura.auraInstanceID)
    if not cloakTooltip.lines or not cloakTooltip.lines[2] then return "" end
    return cloakTooltip.lines[2].leftText
end

local function updateItemTooltip(tooltip, tooltipData)
    if tooltipData.id ~= const.CLOAK_BUFF.ITEM_ID or not tooltipData.guid then return end
    local guid = tooltipData.guid
    if not guid or not C_Item.IsItemGUIDInInventory(guid) then return end

    tooltip.TextLeft1:SetText((tooltip.TextLeft1:GetText() or "") .. getCloakLevel())
    local stats = getCloakStats()
    if stats then
        tooltip.TextLeft2:SetText((tooltip.TextLeft2:GetText() or "").. "\n|cFFFFFFFF" .. stats)
    end
end


TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, updateItemTooltip)
