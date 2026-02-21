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

    -- Wrap the OnEnter and OnLeave scripts once, calling the snippets stored
    -- in the control header. That script gets updated with new attributes
    -- so no need to update the dispatch.
    self.header:WrapScript(frame, "OnEnter", [[control:RunFor(self, control:GetAttribute('setup_onenter'))]])
    self.header:WrapScript(frame, "OnLeave", [[control:RunFor(self, control:GetAttribute('setup_onleave'))]])

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

function addon:PopulateDenylistFromSettings()
    local bits = {
        "blacklist = table.wipe(blacklist)",
    }

    for frame, value in pairs(self.settings.blacklist) do
        if value then
            bits[#bits + 1] = string.format("blacklist[%q] = true", frame)
        end
    end

    self.header:Execute(table.concat(bits, ";\n"))
end

function addon:UpdateGlobalButtonClicks()
    -- We own this button so we can force certain behaviour,
    -- such as always activating on the 'Down' part of clicks.
    self.globutton:SetAttribute("useOnKeyDown", true)
    self.globutton:RegisterForClicks("AnyDown")
    if self:IsGamePadEnabled() then
        self.globutton:EnableGamePadButton(true)
    end
end

function addon:GetButtonDirections()
    if self:IsDownClickEnabled() then
        return "AnyDown"
    else
        return "AnyUp"
    end
end

-- Update both registered clicks, and ensure that mousewheel events are enabled
-- on the frame.
function addon:UpdateRegisteredClicks(button)
    if InCombatLockdown() then
        table.insert(self.regclickqueue, button)
        return
    end

    local enableGamePad = self:IsGamePadEnabled()

    -- Note: We intentionally only enable GamePadButton, never disable it.
    -- WoW frames come with EnableGamePadButton on by default, so we don't
    -- want to forcibly disable it when the Clique option is off.

    -- Short version that only updates clicks for one frame
    if button and not self:IsFrameBlacklisted(button) then
        button:RegisterForClicks(self:GetButtonDirections())
        button:EnableMouseWheel(true)
        if enableGamePad then
            button:EnableGamePadButton(true)
        end
        return
    end

    for button in pairs(self.ccframes) do
        if not self:IsFrameBlacklisted(button) then
            button:RegisterForClicks(self:GetButtonDirections())
            button:EnableMouseWheel(true)
            if enableGamePad then
                button:EnableGamePadButton(true)
            end
        end
    end

    for name, button in pairs(self.hccframes) do
        if not self:IsFrameBlacklisted(button) then
            button:RegisterForClicks(self:GetButtonDirections())
            button:EnableMouseWheel(true)
            if enableGamePad then
                button:EnableGamePadButton(true)
            end
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

    -- Sync the secure blacklist with Lua-side settings
    self:PopulateDenylistFromSettings()

    -- Update the registered clicks, to catch any unblacklisted frames
    self:UpdateRegisteredClicks()

    -- Update the options panel
    if self.UpdateOptionsPanel then
        self:UpdateOptionsPanel()
    end

    -- Update the actual attributes on all frames
    self:ApplyAttributes()
end
