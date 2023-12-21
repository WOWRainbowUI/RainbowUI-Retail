local addonName, addon = ...
local utils = addon.utils
local dialog = addon.dialog
local lang = addon.language
local config = addon.config
local event = addon.event
local UIBase = dialog.base
dialog.checkbox = dialog.checkbox or utils.class("dialog.checkbox", UIBase).new()
local UICheckBox = dialog.checkbox

function UICheckBox:setChecked( frame, state)
    frame:SetChecked(state)
    local key = frame:GetParent():GetAttribute("parentKey"):lower()
    config:setValue({key, "enable"}, state, utils.getCategory())

    if LFGListFrame.SearchPanel:IsShown() then
        LFGListFrame.SearchPanel.RefreshButton:Click()
    end
end

function UICheckBox:onClick( frame, button, down)
    local key = frame:GetParent():GetAttribute("parentKey")
    dialog:exec("PremakeGroupsHelperDialog" .. key .. "_OnClick", frame)
    self:setChecked(frame, frame:GetChecked())
end

function UICheckBox:onEnter(frame)
    local key = frame:GetParent():GetAttribute("parentKey"):lower()
    local tooltipText = lang["dialog.tooltip." .. key] or nil
    if tooltipText then
        GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
        GameTooltip_SetTitle(GameTooltip, tooltipText)
        GameTooltip:Show()
    end
end

function UICheckBox:onLeave(frame)
    local key = frame:GetParent():GetAttribute("parentKey"):lower()
    local tooltipText = lang["dialog.tooltip." .. key] or nil

    if tooltipText then
        GameTooltip:Hide()
    end
end

function UICheckBox:genericField(parent, name)
    UICheckBox.super:genericField(parent, name)

    if not parent then
        return
    end

    --local key = parent:GetAttribute("parentKey")
    dialog:exec("PremakeGroupsHelperDialog" .. name .. "_OnInit", parent.Act)
    parent.Act:SetScript("OnClick", utils.handler(self, UICheckBox.onClick))
    parent.Act:SetScript("OnEnter", utils.handler(self, UICheckBox.onEnter))
    parent.Act:SetScript("OnLeave", utils.handler(self, UICheckBox.onLeave))

    event:exec("SETUP_SKIN", parent.Act, "UICheckBox")
end


dialog:registerHandlers(UICheckBox)