local _, ns = ...
---@class BR
local BR = ns

-- ============================================================================
-- BUFF PAGE SECTION: Free Consumables (consumable category only)
-- ============================================================================
-- Sub-section appended to the consumable Visibility block: a toggle that
-- overrides the normal visibility for buffs that do not require an item, plus
-- its own W/S/D/R picker. _Template.lua composes it as the last Visibility
-- subsection when category=="consumable".

local L = BR.L
local Components = BR.Components
local Helpers = BR.Options.Helpers

local UpdateDisplay = BR.Display.Update

local COMPONENT_GAP = BR.Options.Constants.COMPONENT_GAP
local DEPENDENT_INDENT = BR.Options.Constants.DEPENDENT_INDENT

local FREE_VISIBILITY_DEFAULT = {
    openWorld = false,
    scenario = true,
    dungeon = true,
    raid = true,
    housing = false,
    pvp = true,
}

local function Build(ctx, layout)
    local parent = ctx.content
    local db = BR.profile

    local function EnsureFreeVisibility()
        if not db.defaults then
            ---@diagnostic disable-next-line: missing-fields
            db.defaults = {}
        end
        if not db.defaults.freeConsumableVisibility then
            local copy = {}
            for k, v in pairs(FREE_VISIBILITY_DEFAULT) do
                copy[k] = v
            end
            db.defaults.freeConsumableVisibility = copy
        end
        return db.defaults.freeConsumableVisibility
    end

    Helpers.LayoutSubsectionHeader(layout, parent, L["Options.FreeConsumables"])
    Helpers.LayoutSubsectionNote(layout, parent, L["Options.FreeConsumables.Note"])

    local function IsFreeOverride()
        return BR.Config.Get("defaults.freeConsumableMode") == "override"
    end

    local freeOverrideHolder = Components.Checkbox(parent, {
        label = L["Options.FreeConsumables.Override"],
        get = IsFreeOverride,
        tooltip = {
            title = L["Options.FreeConsumables.Override"],
            desc = L["Options.FreeConsumables.Override.Desc"],
        },
        onChange = function(checked)
            BR.Config.Set("defaults.freeConsumableMode", checked and "override" or "follow")
            Components.RefreshAll()
        end,
    })
    layout:Add(freeOverrideHolder, nil, COMPONENT_GAP)

    layout:SetX(layout:GetX() + DEPENDENT_INDENT)

    -- While the override is off, one line replaces the whole toggle bar, and the
    -- sections below move up.
    local block = CreateFrame("Frame", nil, parent)
    block:SetSize(parent:GetWidth(), 1)

    local followNote = block:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    followNote:SetPoint("TOPLEFT", 0, 0)
    followNote:SetText(L["Options.FreeConsumables.Follows"])

    local freeVisToggles = Components.VisibilityToggles(block, {
        store = {
            getContent = function(key)
                local vis = db.defaults and db.defaults.freeConsumableVisibility
                return not vis or vis[key] ~= false
            end,
            setContent = function(key)
                local vis = EnsureFreeVisibility()
                vis[key] = not vis[key]
            end,
            getDiffTable = function(dbKey)
                local vis = db.defaults and db.defaults.freeConsumableVisibility
                return vis and vis[dbKey]
            end,
            ensureDiffTable = function(dbKey)
                local vis = EnsureFreeVisibility()
                if not vis[dbKey] then
                    vis[dbKey] = {} ---@diagnostic disable-line: assign-type-mismatch
                end
                return vis[dbKey]
            end,
        },
        noAutoRefresh = true,
        onChange = function()
            UpdateDisplay()
        end,
    })
    freeVisToggles:SetPoint("TOPLEFT", 0, 0)
    table.insert(BR.RefreshableComponents, freeVisToggles)

    local NOTE_HEIGHT = 14
    local function BlockHeight()
        return IsFreeOverride() and freeVisToggles:GetHeight() or NOTE_HEIGHT
    end

    local shownOverride
    function block:Refresh()
        local override = IsFreeOverride()
        freeVisToggles:SetShown(override)
        followNote:SetShown(not override)
        if shownOverride ~= nil and shownOverride ~= override then
            ctx.relayout()
        end
        shownOverride = override
    end
    block:Refresh()
    table.insert(BR.RefreshableComponents, block)
    layout:AddDynamic(block, BlockHeight, COMPONENT_GAP)

    layout:SetX(layout:GetX() - DEPENDENT_INDENT)
end

BR.Options.BuffSections.FreeConsumables = Build
