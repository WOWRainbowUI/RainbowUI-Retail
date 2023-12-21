local addonName, addon = ...
local utils = addon.utils
local dialog = addon.dialog
local lang = addon.language
local config = addon.config
local event = addon.event
local UIBase = dialog.base
dialog.moveable = dialog.moveable or utils.class("dialog.moveable", UIBase).new()
local UIMoveableToggle = dialog.moveable

local baseFields = {
    "MoveableToggle",
}

function UIMoveableToggle:clearFocus()
    
end

function UIMoveableToggle:setChecked( frame, state)
    frame:SetChecked(state)
    local key = frame:GetAttribute("parentKey"):lower()
    config:setValue({key, "enable"}, state)
end

function UIMoveableToggle:onClick( frame, button, down)
    local checked = frame:GetChecked()
    self:setChecked(frame, checked)
    print(frame:GetAttribute("parentKey") .. "_OnClick")
    dialog:exec("PremakeGroupsHelperDialog" .. frame:GetAttribute("parentKey") .. "_OnClick", frame)
end

function UIMoveableToggle:genericField(parent, name)
    parent:SetAttribute("parentKey", name)
    parent:SetScript("OnClick", utils.handler(self, UIMoveableToggle.onClick))
    event:exec("SETUP_SKIN", parent, "UIMoveableToggle")
end

function UIMoveableToggle:setup(dialog)
    if not dialog then
        return
    end

    for k, v in pairs(baseFields) do
        local parent = dialog[v]
        if parent then
            local enable = config:getValue({v:lower(), "enable"}) or false
            parent:SetChecked(enable)
        end
    end
end

function UIMoveableToggle:initialize(dialog)
    if not dialog then
        return
    end

    for k, v in pairs(baseFields) do
        local parent = dialog[v]
        if parent then
            self:genericField(parent, v)
        end
    end
end

function UIMoveableToggle:PremakeGroupsHelperDialogMoveableToggle_OnClick(frame)
    local checked = frame:GetChecked()
    if not checked then
        dialog:resetPosition()
    end
end

dialog:registerHandlers(UIMoveableToggle)