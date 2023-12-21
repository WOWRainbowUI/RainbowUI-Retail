
local addonName, addon = ...
local utils = addon.utils
local dialog = addon.dialog
local lang = addon.language
local UIBase = dialog.base
dialog.text = dialog.text or utils.class("dialog.text", UIBase).new()
local UIText = dialog.text

function UIText:initialize(dialog)
    dialog.Title:SetText("Premake Groups Helper")
    dialog.SimpleExplanation:SetText(lang["expl.simple"])
    dialog.StateExplanation:SetText(lang["expl.state"])
    dialog.MinExplanation:SetText(lang["expl.min"])
    dialog.MaxExplanation:SetText(lang["expl.max"])
    dialog.AdvancedExplanation:SetText(lang["expl.advanced"])
end

dialog:registerHandlers(UIText)