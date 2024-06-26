local _, Addon = ...
if Addon:IsBuild("retail") then return end

local ActionButton = {}

local function GetActionButtonCommand(id)
    -- 0
    if id <= 0 then
        return
    -- 1
    elseif id <= 12 then
        return "ACTIONBUTTON" .. id
    -- 2
    elseif id <= 24 then
        return
    -- 3
    elseif id <= 36 then
        return "MULTIACTIONBAR3BUTTON" .. (id - 24)
    -- 4
    elseif id <= 48 then
        return "MULTIACTIONBAR4BUTTON" .. (id - 36)
    -- 5
    elseif id <= 60 then
        return "MULTIACTIONBAR2BUTTON" .. (id - 48)
    -- 6
    elseif id <= 72 then
        return "MULTIACTIONBAR1BUTTON" .. (id - 60)
    end
end

function ActionButton:OnCreate(id)
    -- initialize secure state
    self:SetAttributeNoHandler("action", 0)
    self:SetAttributeNoHandler("commandName", GetActionButtonCommand(id) or ("CLICK %s:HOTKEY"):format(self:GetName()))
    self:SetAttributeNoHandler("showgrid", 0)
    self:SetAttributeNoHandler("useparent-checkfocuscast", true)
    self:SetAttributeNoHandler("useparent-checkmouseovercast", true)
    self:SetAttributeNoHandler("useparent-checkselfcast", true)

    -- secure handlers
    self:SetAttributeNoHandler('_childupdate-offset', [[
        local offset = message or 0
        local id = self:GetAttribute('index') + offset

        if self:GetAttribute('action') ~= id then
            self:SetAttribute('action', id)
        end
    ]])

    -- register for clicks on all buttons, and enable mousewheel bindings
    self:EnableMouseWheel()
    self:RegisterForClicks("AnyUp", "AnyDown")

    -- bindings setup
    Addon.BindableButton:AddQuickBindingSupport(self)
end

function ActionButton:UpdateShown()
    if InCombatLockdown() then return end

    self:SetShown(
        (self:GetAttribute("showgrid") > 0 or HasAction(self:GetAttribute("action")))
        and not self:GetAttribute("statehidden")
    )
end

--------------------------------------------------------------------------------
-- configuration
--------------------------------------------------------------------------------

function ActionButton:SetFlyoutDirectionInsecure(direction)
    if InCombatLockdown() then return end

    self:SetAttribute("flyoutDirection", direction)
    self:UpdateFlyout()
end

-- the stock UI shows and hides hotkeys based on if there's a binding or not
-- so we simply make our hotkeys transparent when we don't want them shown
function ActionButton:SetShowBindingText(show)
    local parent = (show and self) or Addon.ShadowUIParent

    if self.HotKey:GetParent() ~= parent then
        self.HotKey:SetParent(parent)
    end
end

-- we hide cooldowns when action buttons are transparent
-- so that the sparks don't appear
function ActionButton:SetShowCooldowns(show)
    if show then
        if self.cooldown:GetParent() ~= self then
            self.cooldown:SetParent(self)
            ActionButton_UpdateCooldown(self)
        end
    else
        self.cooldown:SetParent(Addon.ShadowUIParent)
    end
end

function ActionButton:SetShowCounts(show)
    self.Count:SetShown(show)
end

function ActionButton:SetShowEquippedItemBorders(show)
    local parent = (show and self) or Addon.ShadowUIParent

    if self.Border:GetParent() ~= parent then
        self.Border:SetParent(parent)
    end
end

function ActionButton:SetShowEmptyButtons(show, force)
    self:SetShowGridInsecure(show, Addon.ActionButtons.ShowGridReasons.SHOW_EMPTY_BUTTONS_PER_BAR, force)
end

function ActionButton:SetShowGridInsecure(show, reason, force)
    if InCombatLockdown() then return end

    if type(reason) ~= "number" then
        error("Usage: ActionButton:SetShowGridInsecure(show, reason, force?)", 2)
    end

    local value = self:GetAttribute("showgrid") or 0
    local prevValue = value

    if show then
        value = bit.bor(value, reason)
    else
        value = bit.band(value, bit.bnot(reason))
    end

    if (value ~= prevValue) or force then
        self:SetAttribute("showgrid", value)
        self:UpdateShown()
    end
end

function ActionButton:SetShowMacroText(show)
    self.Name:SetShown(show and true)
end

if ActionButton_UpdateHotkeys then
    hooksecurefunc("ActionButton_UpdateHotkeys", Addon.BindableButton.UpdateHotkeys)
end

if ActionButton_UpdateFlyout then
    ActionButton.UpdateFlyout = ActionButton_UpdateFlyout
else
    ActionButton.UpdateFlyout = function() end
end

-- exports
Addon.ActionButton = ActionButton
