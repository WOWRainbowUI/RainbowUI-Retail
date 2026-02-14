local _, ns = ...

local NoAuras = {}
ns.NoAuras = NoAuras

local viewers = {
    EssentialCooldownViewer = _G["EssentialCooldownViewer"],
    UtilityCooldownViewer = _G["UtilityCooldownViewer"],
}

function NoAuras.CollectViewerChildren(viewer)
    local all = {}

    local children = { viewer:GetChildren() }
    for _, child in ipairs(children) do
        if child and child:IsShown() and child.Cooldown then
            all[#all + 1] = child
        end
    end
    return all
end

function NoAuras:DisableAura(child)
    local cooldownInfo = child:GetCooldownInfo()
    if not cooldownInfo then
        return
    end
    local spellID = cooldownInfo.overrideSpellID or cooldownInfo.spellID
    if not spellID then
        return
    end

    local c = CooldownViewerConstants.ITEM_COOLDOWN_COLOR
    child.Cooldown:SetSwipeColor(c.r, c.g, c.b, c.a)

    -- child.Cooldown:SetDrawEdge(true)

    local cooldownDuration = C_Spell.GetSpellCooldownDuration(spellID)
    child.Cooldown:SetCooldownFromDurationObject(cooldownDuration)
    local spellChargesInfo = C_Spell.GetSpellCharges(spellID)
    local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID)

    local iconTexture = child:GetIconTexture()
    if spellChargesInfo then
        child.Cooldown:SetCooldownFromDurationObject(C_Spell.GetSpellChargeDuration(spellID))
    end

    child.Cooldown:SetReverse(false)
    if not spellCooldownInfo.isOnGCD then
        if not spellChargesInfo then
            C_Timer.After(0, function()
                iconTexture:SetDesaturated(true)
            end)
        else
            -- bugged, can't desaturate...
        end
    end
end

function NoAuras:HookCooldown()
    for viewerName, viewer in pairs(viewers) do
        if not viewer then
            return
        end

        local children = NoAuras.CollectViewerChildren(viewer)
        for _, child in ipairs(children) do
            if not child._cmcNoAuraHooked and child.Cooldown then
                child._cmcNoAuraHooked = true
                hooksecurefunc(child.Cooldown, "SetCooldown", function(self)
                    if not ns.db.profile.cooldownManager_experimental_hideAuras then
                        return
                    end
                    NoAuras:DisableAura(self:GetParent())
                end)
            end
        end
    end
end
local areHooksInitialized = false
function NoAuras:Initialize()
    if areHooksInitialized then
        return
    end
    for viewerName, viewer in pairs(viewers) do
        if viewer then
            hooksecurefunc(viewer, "RefreshLayout", function()
                C_Timer.After(0.01, function()
                    NoAuras:HookCooldown()
                end)
            end)
        end
    end
end
