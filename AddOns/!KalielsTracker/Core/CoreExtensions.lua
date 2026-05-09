--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

-- Module

function KT_ObjectiveTrackerModuleMixin:SetHeaderSuffix(suffix)
    local text = self.headerText
    if suffix then
        text = format("%s (%s)", text, suffix)
    end
    self.Header.Text:SetText(text)
end

function KT_ObjectiveTrackerModuleMixin:OnLineClick(line, mouseButton)
    -- override in your mixin
end

function KT_ObjectiveTrackerModuleMixin:OnLineEnter(line)
    -- override in your mixin
end

function KT_ObjectiveTrackerModuleMixin:OnLineLeave(line)
    -- override in your mixin
end

function KT_ObjectiveTrackerModuleMixin:OnLineFree(line)
    -- override in your mixin
end

-- Block

function KT_ObjectiveTrackerBlockMixin:OnEnter()
    self:OnHeaderEnter()
end

function KT_ObjectiveTrackerBlockMixin:OnLeave()
    self:OnHeaderLeave()
end

function KT_ObjectiveTrackerBlockMixin:OnMouseUp(mouseButton)
    self:OnHeaderClick(mouseButton)
end

-- Line

KT_ObjectiveTrackerClickLineMixin = CreateFromMixins(KT_ObjectiveTrackerAnimLineMixin)

function KT_ObjectiveTrackerClickLineMixin:UpdateHighlight()
    local dashColor
    if self.isHighlighted then
        dashColor = KT_OBJECTIVE_TRACKER_COLOR["NormalHighlight"]
    else
        dashColor = KT_OBJECTIVE_TRACKER_COLOR["Normal"]
    end

    local colorStyle = self.Text.colorStyle.reverse
    if colorStyle then
        self.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
        self.Text.colorStyle = colorStyle
        if self.Dash then
            self.Dash:SetTextColor(dashColor.r, dashColor.g, dashColor.b)
        end
    end
end

function KT_ObjectiveTrackerClickLineMixin:OnMouseUp(mouseButton)
    local block = self:GetParent()
    block.parentModule:OnLineClick(self, mouseButton)
end

function KT_ObjectiveTrackerClickLineMixin:OnEnter()
    self.isHighlighted = true
    self:UpdateHighlight()
    self.parentBlock.parentModule:OnLineEnter(self)
end

function KT_ObjectiveTrackerClickLineMixin:OnLeave()
    self.isHighlighted = false
    self:UpdateHighlight()
    self.parentBlock.parentModule:OnLineLeave(self)
end

function KT_ObjectiveTrackerClickLineMixin:OnFree(block)
    KT_ObjectiveTrackerAnimLineMixin.OnFree(self, block)
    block.parentModule:OnLineFree(self)
end

function KT_ObjectiveTrackerClickLineMixin:SetIcon(texture)
    self.Icon2:SetTexture(texture)
end