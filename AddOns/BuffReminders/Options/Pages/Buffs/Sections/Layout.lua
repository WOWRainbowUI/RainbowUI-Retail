local _, ns = ...
---@class BR
local BR = ns

-- ============================================================================
-- BUFF PAGE SECTION: Layout
-- ============================================================================
-- One row: the split-frame toggle, then the growth direction and the
-- reset-position button. Both apply to a split frame only, so they hide, not dim,
-- while the category is not split. Cross-category display ordering lives on the
-- Defaults page (single ordered list across all non-split categories) since
-- priority is inherently a global decision.
--
-- The direction is its own inherited key: nil follows the Defaults page,
-- independent of the Appearance override.

local L = BR.L
local Components = BR.Components
local CreateButton = BR.CreateButton
local Helpers = BR.Options.Helpers

local IsCategorySplit = BR.Helpers.IsCategorySplit

local UpdateVisuals = BR.Display.UpdateVisuals
local ResetCategoryFramePosition = BR.Display.ResetCategoryFramePosition

local LayoutSectionHeader = Helpers.LayoutSectionHeader
local SetCategorySetting = Helpers.SetCategorySetting

local COMPONENT_GAP = BR.Options.Constants.COMPONENT_GAP

local DIRECTION_DEFAULT = "DEFAULT"

local function Build(ctx, layout)
    local category = ctx.category
    local parent = ctx.content
    local defaults = BR.defaults

    LayoutSectionHeader(layout, parent, L["Options.Layout"])

    local splitHolder = Components.Checkbox(parent, {
        label = L["Options.SplitFrame"],
        get = function()
            return IsCategorySplit(category)
        end,
        tooltip = {
            title = L["Options.SplitFrame"],
            desc = L["Options.SplitFrame.Desc"],
        },
        onChange = function(checked)
            -- split is registered as FramesReparent in CategorySettingKeys, so the
            -- Set call fires that event. Only the visuals need a redraw.
            SetCategorySetting(category, "split", checked)
            UpdateVisuals()
            -- The direction, the reset button and the Stacking Order list on the
            -- Layout page all read the split state.
            Components.RefreshAll()
        end,
    })
    layout:Add(splitHolder, nil, COMPONENT_GAP)

    local directionHolder = Components.Dropdown(parent, {
        label = L["Direction.Label"],
        width = 110,
        options = {
            { label = L["Options.Direction.Default"], value = DIRECTION_DEFAULT },
            { label = L["Direction.Left"], value = "LEFT" },
            { label = L["Direction.Center"], value = "CENTER" },
            { label = L["Direction.Right"], value = "RIGHT" },
            { label = L["Direction.Up"], value = "UP" },
            { label = L["Direction.Down"], value = "DOWN" },
        },
        tooltip = { title = L["Direction.Label"], desc = L["Options.Direction.Desc"] },
        get = function()
            local catSettings = BR.profile.categorySettings and BR.profile.categorySettings[category]
            return catSettings and catSettings.layoutDirection or DIRECTION_DEFAULT
        end,
        onChange = function(dir)
            SetCategorySetting(category, "layoutDirection", dir ~= DIRECTION_DEFAULT and dir or nil)
        end,
    })
    directionHolder:SetPoint("LEFT", splitHolder.infoIcon or splitHolder.label, "RIGHT", 20, 0)

    local resetBtn = CreateButton(parent, L["Options.ResetPosition"], function()
        local catDefaults = defaults.categorySettings[category]
        if catDefaults and catDefaults.position then
            ResetCategoryFramePosition(category, catDefaults.position.x, catDefaults.position.y)
        end
    end)
    resetBtn:SetPoint("LEFT", directionHolder, "RIGHT", 4, 0)

    local splitDependents = CreateFrame("Frame", nil, parent)
    function splitDependents:Refresh()
        local split = IsCategorySplit(category)
        directionHolder:SetShown(split)
        resetBtn:SetShown(split)
    end
    splitDependents:Refresh()
    table.insert(BR.RefreshableComponents, splitDependents)
end

BR.Options.BuffSections.Layout = Build
