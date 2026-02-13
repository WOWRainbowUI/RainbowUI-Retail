--[[-------------------------------------------------------------------
--  Clique - Copyright 2006-2026 - James N. Whitehead II
-------------------------------------------------------------------]]--

--- @class CliqueAddon: AddonCore
local addon = select(2, ...)

function addon:RegisterUnitFrame(frame)
    -- We need a frame
    --
    if not frame then return end
    -- Make sure its not already registered
    if self.ccframes[frame] then return end
    -- Make sure the frame is button-ish
    if not frame.RegisterForClicks then return end

    if InCombatLockdown() or not self:IsInitialized() then
        table.insert(self.regqueue, frame)
        return
    end

    self.ccframes[frame] = true
    self:UpdateRegisteredClicks(frame)

    -- Wrap the OnEnter/OnLeave scripts in order to handle keybindings
    self.header:WrapScript(frame, "OnEnter", self.header:GetAttribute("setup_onenter"))
    self.header:WrapScript(frame, "OnLeave", self.header:GetAttribute("setup_onleave"))

    -- Set the attributes on the frame
    self.header:SetFrameRef("cliquesetup_button", frame)
    self.header:Execute(self.header:GetAttribute("setup_clicks"), frame)
end

function addon:UnregisterUnitFrame(frame)
    if InCombatLockdown() then
        table.insert(self.unregqueue, frame)
        return
    end

    -- Clear any click/bind attributes
    self.header:SetFrameRef("cliquesetup_button", frame)
    self.header:Execute([[
        local button = self:GetFrameRef("cliquesetup_button")
        self:RunFor(button, self:GetAttribute("setup_onleave"))
        self:RunAttribute("remove_clicks")
    ]])

    self.ccframes[frame] = nil

    -- Unwrap the OnEnter/OnLeave scripts, if they were set
    self.header:UnwrapScript(frame, "OnEnter")
    self.header:UnwrapScript(frame, "OnLeave")
end

-- This function returns whether or not a frame is blacklisted in the current
-- users settings
function addon:IsFrameBlacklisted(frame)
    local name = frame
    if type(frame) == "table" then
        name = frame.GetName and frame:GetName()
    end

    return self.settings.blacklist[name]
end

function addon:UpdateGlobalButtonClicks()
    -- We own this button so we can force certain behaviour,
    -- such as always activating on the 'Down' part of clicks.
    self.globutton:SetAttribute("useOnKeyDown", true)
    self.globutton:RegisterForClicks("AnyDown")
end

function addon:GetButtonDirections()
    if self.settings.usecvardirection then
        local keyDown = C_CVar.GetCVarBool("ActionButtonUseKeyDown")

        if keyDown then
            return "AnyDown"
        else
            return "AnyUp"
        end
    end

    -- Old behaviour
    if self:ProjectIsBCC() then
        return "AnyDown"
    else
        return "AnyUp", "AnyDown"
    end
end

-- Update both registered clicks, and ensure that mousewheel events are enabled
-- on the frame.
function addon:UpdateRegisteredClicks(button)
    if InCombatLockdown() then
        table.insert(self.regclickqueue, button)
        return
    end

    -- Short version that only updates clicks for one frame
    if button and not self:IsFrameBlacklisted(button) then
        button:RegisterForClicks(self:GetButtonDirections())
        button:EnableMouseWheel(true)
        return
    end

    for button in pairs(self.ccframes) do
        if not self:IsFrameBlacklisted(button) then
            button:RegisterForClicks(self:GetButtonDirections())
            button:EnableMouseWheel(true)
        end
    end

    for name, button in pairs(self.hccframes) do
        if not self:IsFrameBlacklisted(button) then
            button:RegisterForClicks(self:GetButtonDirections())
            button:EnableMouseWheel(true)
        end
    end

    -- Update the global button in case settings have changed
    self:UpdateGlobalButtonClicks()
end

function addon:BLACKLIST_CHANGED()
    if InCombatLockdown() then
        self:Defer("BLACKLIST_CHANGED")
        return
    end

    -- Clear attributes on all frames
    self:ClearAttributes()

    -- Actually update the blacklist accordingly
    local bits = {
        "blacklist = table.wipe(blacklist)",
    }

    for frame, value in pairs(self.settings.blacklist) do
        if not not value then
            bits[#bits + 1] = string.format("blacklist[%q] = true", frame)
        end
    end

    self.header:Execute(table.concat(bits, ";\n"))

    -- Update the registered clicks, to catch any unblacklisted frames
    self:UpdateRegisteredClicks()

    -- Update the options panel
    if self.UpdateOptionsPanel then
        self:UpdateOptionsPanel()
    end

    -- Update the actual attributes on all frames
    self:ApplyAttributes()
end
