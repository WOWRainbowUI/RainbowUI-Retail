local _, ns = ...

local DB = ns.TrackerDB
local ItemsData = ns.TrackerItemsData

local ItemVisuals = ns.TrackerItemVisuals or {}
ns.TrackerItemVisuals = ItemVisuals

local FALLBACK_ICON = 134400

local desaturationCurve = C_CurveUtil.CreateCurve()
desaturationCurve:AddPoint(0, 0)
desaturationCurve:AddPoint(0.001, 1)

-- local function GetGlobalCooldownDuration()
--     local info = C_Spell.GetSpellCooldown(61304)
--     return info and info.duration or nil
-- end

function ItemVisuals:GetEntryIcon(kind, id)
    if kind == "wildcardSlots" and ItemsData and ItemsData.GetWildcardSlotItemID then
        local itemID = ItemsData:GetWildcardSlotItemID(id)
        if itemID then
            return C_Item.GetItemIconByID(itemID) or FALLBACK_ICON
        end
        return FALLBACK_ICON
    end
    if kind == "spell" then
        return C_Spell.GetSpellTexture(id) or FALLBACK_ICON
    end

    return C_Item.GetItemIconByID(id) or FALLBACK_ICON
end

function ItemVisuals:ApplyItemIcon(frame, itemID)
    if not frame or not frame.Icon then
        return
    end
    frame.Icon:SetTexture(C_Item.GetItemIconByID(itemID) or FALLBACK_ICON)
end

function ItemVisuals:ApplyEntryIcon(frame, kind, id)
    if not frame or not frame.Icon then
        return
    end
    frame.Icon:SetTexture(self:GetEntryIcon(kind, id))
end

function ItemVisuals:SetEmptySlot(frame)
    if not frame then
        return
    end
    if frame.Icon then
        frame.Icon:SetTexture(nil)
        frame.Icon:SetAtlas("cdm-empty", true)
        frame.Icon:SetDesaturated(false)
    end
    if frame.Cooldown then
        CooldownFrame_Clear(frame.Cooldown)
    end
end

function ItemVisuals:ClearCooldown(frame, desaturation)
    if not frame then
        return
    end
    if frame.Cooldown then
        CooldownFrame_Clear(frame.Cooldown)
        frame.Cooldown:SetDrawSwipe(false)
    end
    if desaturation ~= nil and frame.Icon then
        frame.Icon:SetDesaturation(desaturation)
    end
end

function ItemVisuals:UpdateSpellCooldown(frame, spellID)
    if not frame or not frame.Cooldown then
        return false
    end
    -- Clear item count display when updating spell cooldown (spells don't use count display)
    frame.count:SetText("")

    local cooldownDuration = C_Spell.GetSpellCooldownDuration(spellID)
    frame.Cooldown:SetCooldownFromDurationObject(cooldownDuration)
    if C_Spell.GetSpellCharges(spellID) then
        local chargeDuration = C_Spell.GetSpellChargeDuration and C_Spell.GetSpellChargeDuration(spellID) or nil
        if chargeDuration then
            frame.Cooldown:SetCooldownFromDurationObject(chargeDuration)
        end
    else
        frame.Cooldown:SetDrawSwipe(true)
    end

    local desaturation = 0

    if not C_Spell.GetSpellCooldown(spellID).isOnGCD then
        desaturation = cooldownDuration:EvaluateRemainingPercent(desaturationCurve)
    end

    frame.Icon:SetDesaturation(desaturation)

    return true
end

function ItemVisuals:UpdateItemCooldown(frame, itemID)
    if not frame or not frame.Cooldown then
        return false
    end
    local count = 0
    local classID, subclassID = select(6, GetItemInfoInstant(itemID))
    if classID == Enum.ItemClass.Consumable then
        count = C_Item.GetItemCount(itemID, false, true)
    end

    if count > 1 then
        frame.count:SetText(count)
    else
        frame.count:SetText("")
    end

    local startTime, duration, enabled = C_Item.GetItemCooldown(itemID)

    local name, spellID = C_Item.GetItemSpell(itemID)
    frame.Cooldown:SetCooldown(startTime, duration)
    frame.Cooldown:SetDrawSwipe(true)

    local desaturation = 0

    if not spellID or not C_Spell.GetSpellCooldown(spellID).isOnGCD then
        if startTime > 0 then
            desaturation = 1
        end
    end

    frame.Icon:SetDesaturation(desaturation)

    return true
end

function ItemVisuals:UpdateEntryCooldown(frame, kind, id)
    if kind == "wildcardSlots" and ItemsData and ItemsData.GetWildcardSlotItemID then
        local itemID = ItemsData:GetWildcardSlotItemID(id)
        if not itemID then
            if frame.count then
                frame.count:SetText("")
            end
            if frame.Cooldown then
                CooldownFrame_Clear(frame.Cooldown)
                frame.Cooldown:SetDrawSwipe(false)
            end
            if frame.Icon then
                frame.Icon:SetDesaturation(0)
            end
            return true
        end
        return self:UpdateItemCooldown(frame, itemID)
    end
    if kind == "spell" then
        return self:UpdateSpellCooldown(frame, id)
    end
    return self:UpdateItemCooldown(frame, id)
end
