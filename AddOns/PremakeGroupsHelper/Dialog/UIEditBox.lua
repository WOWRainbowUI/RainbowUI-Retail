local addonName, addon = ...
local utils = addon.utils
local dialog = addon.dialog
local lang = addon.language
local config = addon.config
local event = addon.event
local UICheckBox = dialog.checkbox
dialog.editbox = dialog.editbox or utils.class("dialog.editbox", UICheckBox).new()
local UIEditBox = dialog.editbox

local editBoxFields = {
    "Ilvl",
    "CreateTime",
    'MythicScore',
    "Defeated",
    "PvpRating",
    "Members",
    "Tanks",
    "Heals",
    "Dps",
}

function UIEditBox:clearFocus()
    for _, key in pairs(editBoxFields) do
        local parent = dialog[key]
        if parent then
            for _,v in pairs({"Min", "Max"}) do
                parent[v]:ClearFocus()
            end
        end
    end
end

function UIEditBox:onTextChanged(frame, userInput)

    local parent = frame:GetParent()

    if not parent then
        return
    end

    local function NotEmpty(value)
        return value and value ~= ""
    end

    local state = NotEmpty(parent.Min:GetText()) or NotEmpty(parent.Max:GetText())
    local key = frame:GetParent():GetAttribute("parentKey"):lower()

    config:setValue({key, "min"}, tonumber(parent.Min:GetText()) or nil, utils.getCategory())
    config:setValue({key, "max"}, tonumber(parent.Max:GetText()) or nil, utils.getCategory())

    if not userInput then
        return
    end
    
    self:setChecked(parent.Act, state)
end

function UIEditBox:onTabPressed(frame)
    if(frame:GetAttribute("parentKey") == "Min") then
        frame:GetParent().Max:SetFocus()
    else
        frame:GetParent().Min:SetFocus()
    end
end

function UIEditBox:onEscapePressed(frame)
    frame:ClearFocus()
end

function UIEditBox:setup(dialog, reset)
    if not dialog then
        return
    end

    for _, key in pairs(editBoxFields) do
        local parent = dialog[key]
        if parent then
            local cfg = config:getValue({key:lower()}, utils.getCategory()) or nil
            local enable = cfg and cfg.enable or false
            
            for _,v in pairs({"Min", "Max"}) do
                local value = cfg and cfg[v:lower()] or nil
                if value or reset then
                    parent[v]:SetText(value and tostring(value) or "")
                end
            end

            parent.Act:SetChecked(enable)
        end
    end
end

function UIEditBox:initialize(dialog)
    for _, key in pairs(editBoxFields) do
        local parent = dialog[key]
        if parent then
            self:genericField(parent, key)

            for _,v in pairs({"Min", "Max"}) do
                parent[v]:SetAttribute("parentKey", v)
                parent[v]:SetScript("OnTextChanged", utils.handler(self, UIEditBox.onTextChanged))
                parent[v]:SetScript("OnTabPressed", utils.handler(self, UIEditBox.onTabPressed))
                parent[v]:SetScript("OnEscapePressed", utils.handler(self, UIEditBox.onEscapePressed))
                event:exec("SETUP_SKIN", parent[v], "UIEditBox")
            end

            parent["To"]:SetText(lang["dialog.to"])
        end
    end
end

dialog:registerHandlers(UIEditBox)