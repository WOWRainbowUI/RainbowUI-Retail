
local addonName, addon = ...
local utils = addon.utils
local dialog = addon.dialog
local lang = addon.language
dialog.base = dialog.base or utils.class("dialog.base").new()
local UIBase = dialog.base

function UIBase:clearFocus()
end

function UIBase:genericField(parent, name)
    if not parent then
        return
    end
    
    if parent.Title then
        parent.Title:SetText(lang["dialog." .. name:lower()])
    end
    parent:SetAttribute("parentKey", name)
end

function UIBase:setup(dialog)
end

function UIBase:initialize(dialog)
end

dialog:registerHandlers(UIBase)