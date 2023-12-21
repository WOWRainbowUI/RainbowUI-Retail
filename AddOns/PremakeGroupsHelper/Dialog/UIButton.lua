local addonName, addon = ...
local utils = addon.utils
local dialog = addon.dialog
local lang = addon.language
local config = addon.config
local event = addon.event
local UIBase = dialog.base
dialog.button = dialog.button or utils.class("dialog.button", UIBase).new()
local UIButton = dialog.button

local baseFields = {
    "IngoreListToggle",
    "ResetButton",
    "SearchButton",
}

function UIButton:onClick( frame, button, down)
    local key = frame:GetAttribute("parentKey")
    dialog:exec("PremakeGroupsHelperDialog" .. key .. "_OnClick", frame)
end

function UIButton:genericField(parent, name)
    UIButton.super:genericField(parent, name)

    if not parent then
        return
    end

    parent:SetText(lang["dialog." .. name:lower()] or "")
    parent:SetScript("OnClick", utils.handler(self, UIButton.onClick))
    event:exec("SETUP_SKIN", parent, "UIButton")
end

function UIButton:initialize(dialog)
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

dialog:registerHandlers(UIButton)