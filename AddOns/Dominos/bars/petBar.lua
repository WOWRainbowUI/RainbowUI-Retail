if not PetActionBar then return end

--------------------------------------------------------------------------------
-- Pet Bar
-- A movable action bar for pets
--------------------------------------------------------------------------------

local AddonName, Addon = ...
local L = LibStub('AceLocale-3.0'):GetLocale(AddonName)

--------------------------------------------------------------------------------
-- Pet Buttons
--
-- In retail, we can't use the existing pet action slots, and there isn't really
-- a sufficient amount of secure environment actions to perfectly reimplement
-- the pet bar.
--
-- To work around this, we implement our own pet bar, but keep the other one
-- still active (but invisible). This lets us use the old bar to track when our
-- bar should be shown
--------------------------------------------------------------------------------

local PetActionButtonMixin = {}

function PetActionButtonMixin:CancelSpellDataLoadedCallback()
    local cancelFunc = self.spellDataLoadedCancelFunc

    if cancelFunc then
		cancelFunc()
		self.spellDataLoadedCancelFunc = nil
	end
end

-- this is mostly a straight port of PetActionBarMixin:Update()
function PetActionButtonMixin:Update()
    local petActionID = self:GetID()
    local petActionIcon = self.icon
    local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(petActionID)

    if not isToken then
        self.tooltipName = name
    else
        self.tooltipName = _G[name]
    end

    self.isToken = isToken

    if spellID and spellID ~= self.spellID then
        self.spellID = spellID

        local spell = Spell:CreateFromSpellID(spellID)

        self.spellDataLoadedCancelFunc = spell:ContinueWithCancelOnSpellLoad(function()
            self.tooltipSubtext = spell:GetSpellSubtext()
        end)
    end

    if isActive then
        if IsPetAttackAction(petActionID) then
            self:StartFlash()
            self:GetCheckedTexture():SetAlpha(0.5)
        else
            self:StopFlash()
            self:GetCheckedTexture():SetAlpha(1)
        end
    else
        self:StopFlash()
    end

    self:SetChecked(isActive and true)


    local autoCastOverlay = self.AutoCastOverlay
    if autoCastOverlay then
        autoCastOverlay:SetShown(autoCastAllowed)
		autoCastOverlay:ShowAutoCastEnabled(autoCastEnabled)
    else
        self.AutoCastable:SetShown(autoCastAllowed and true)

        if autoCastEnabled then
            AutoCastShine_AutoCastStart(self.AutoCastShine)
        else
            AutoCastShine_AutoCastStop(self.AutoCastShine)
        end
    end

    if texture then
        if GetPetActionSlotUsable(petActionID) then
            petActionIcon:SetVertexColor(1, 1, 1)
        else
            petActionIcon:SetVertexColor(0.4, 0.4, 0.4)
        end

        petActionIcon:SetTexture(isToken and _G[texture] or texture)
        petActionIcon:Show()
    else
        petActionIcon:Hide()
    end

    SharedActionButton_RefreshSpellHighlight(self, PET_ACTION_HIGHLIGHT_MARKS[petActionID])
end

function PetActionButtonMixin:UpdateCooldown()
    local cooldown = self.cooldown
    local start, duration, enable = GetPetActionCooldown(self:GetID())

    if enable and enable ~= 0 and start > 0 and duration > 0 then
        cooldown:SetCooldown(start, duration)
    else
        cooldown:Clear()
    end

    if GameTooltip and GameTooltip:IsOwned(self) then
        self:OnEnter()
    end
end

function PetActionButtonMixin:UpdateShownInsecure()
    if InCombatLockdown() then
        return
    end

    self:SetShown(self.watcher:IsVisible() and not self:GetAttribute("statehidden"))
end

local function createPetActionButton(name, id)
    local button = CreateFrame('CheckButton', name, nil, 'PetActionButtonTemplate')

    Mixin(button, PetActionButtonMixin)

    -- get the stock button
    local target = _G['PetActionButton' .. id]

    -- copy its ID
    button:SetID(target:GetID())

    -- copy its visibility state
    local watcher = CreateFrame('Frame', nil, target, "SecureHandlerShowHideTemplate")
    watcher:SetFrameRef("owner", button)
    watcher:SetAttribute("_onshow", [[ self:GetFrameRef("owner"):Show(true) ]])
    watcher:SetAttribute("_onhide", [[ self:GetFrameRef("owner"):Hide(true) ]])
    button.watcher = watcher

    -- copy its pushed state
    hooksecurefunc(target, "SetButtonState", function(_, ...)
        button:SetButtonState(...)
    end)

    -- setup bindings
    button:SetAttribute("commandName", "BONUSACTIONBUTTON" .. id)
    Addon.BindableButton:AddQuickBindingSupport(button)

    -- add support for mousewheel bindings
    button:EnableMouseWheel(true)

    -- unregister spell data loaded callback
    button:HookScript("OnHide", PetActionButtonMixin.CancelSpellDataLoadedCallback)

    return button
end

local function getOrCreatePetActionButton(id)
    local name = ('%sPetActionButton%d'):format(AddonName, id)
    local button = _G[name]

    if not button then
        button = createPetActionButton(name, id)
    end

    return button
end

--------------------------------------------------------------------------------
-- The Pet Bar
--------------------------------------------------------------------------------

local PetBar = Addon:CreateClass('Frame', Addon.ButtonBar)

function PetBar:New()
    return PetBar.proto.New(self, 'pet')
end

function PetBar:GetDisplayName()
    return L.PetBarDisplayName
end

function PetBar:IsOverrideBar()
    return Addon.db.profile.possessBar == self.id
end

function PetBar:UpdateOverrideBar()
end

function PetBar:GetDefaults()
    return {
        point = 'BOTTOM',
		x = -484,
		y = 140,
		scale = 0.8,
		columns = 5,
		spacing = 2
    }
end

function PetBar:NumButtons()
    return NUM_PET_ACTION_SLOTS
end

function PetBar:AcquireButton(index)
    return getOrCreatePetActionButton(index)
end

function PetBar:OnAttachButton(button)
    button.HotKey:SetAlpha(self:ShowingBindingText() and 1 or 0)
    button:UpdateShownInsecure()

    Addon:GetModule('ButtonThemer'):Register(button, L.PetBarDisplayName)
    Addon:GetModule('Tooltips'):Register(button)
end

function PetBar:OnDetachButton(button)
    Addon:GetModule('ButtonThemer'):Unregister(button, L.PetBarDisplayName)
    Addon:GetModule('Tooltips'):Unregister(button)
end

-- keybound events
function PetBar:KEYBOUND_ENABLED()
    self:ForButtons("UpdateShownInsecure")
end

function PetBar:KEYBOUND_DISABLED()
    self:ForButtons("UpdateShownInsecure")
end

-- binding text
function PetBar:SetShowBindingText(show)
    show = show and true

    if show == Addon.db.profile.showBindingText then
        self.sets.showBindingText = nil
    else
        self.sets.showBindingText = show
    end

    for _, button in pairs(self.buttons) do
        button.HotKey:SetAlpha(show and 1 or 0)
    end
end

function PetBar:ShowingBindingText()
    local result = self.sets.showBindingText

    if result == nil then
        result = Addon.db.profile.showBindingText
    end

    return result
end

function PetBar:OnCreateMenu(menu)
    local L = LibStub('AceLocale-3.0'):GetLocale('Dominos-Config')

    local layoutPanel = menu:NewPanel(L.Layout)

    layoutPanel:NewCheckButton {
        name = L.ShowBindingText,
        get = function()
            return layoutPanel.owner:ShowingBindingText()
        end,
        set = function(_, enable)
            layoutPanel.owner:SetShowBindingText(enable)
        end
    }

    layoutPanel:AddLayoutOptions()

    menu:AddFadingPanel()
    menu:AddAdvancedPanel()
end

--------------------------------------------------------------------------------
-- the module
--------------------------------------------------------------------------------

local PetBarModule = Addon:NewModule('PetBar', 'AceEvent-3.0')

function PetBarModule:Load()
    self.bar = PetBar:New()
    self:UpdateActions()
    self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
end

function PetBarModule:Unload()
    self:UnregisterAllEvents()

    if self.bar then
        self.bar:Free()
        self.bar = nil
    end
end

function PetBarModule:OnFirstLoad()
    -- "hide" the pet bar (make invisible and non-interactive)
    PetActionBar:SetAlpha(0)
    PetActionBar:EnableMouse(false)
    PetActionBar:SetScript("OnUpdate", nil)

    -- and its buttons, too
    for _, button in pairs(PetActionBar.actionButtons) do
        button:EnableMouse(false)
        button:SetScript("OnUpdate", nil)
        button:UnregisterAllEvents()
    end

    -- unregister events that do not impact pet action bar visibility
    PetActionBar:UnregisterEvent("PET_BAR_UPDATE_COOLDOWN")

    -- an extremly lazy method of updating the Dominos pet bar when the
    -- normal pet bar would be updated
    hooksecurefunc(PetActionBar, "Update", Addon:Debounce(function() self:UpdateActions() end, 0.01))
end

function PetBarModule:PET_BAR_UPDATE_COOLDOWN()
    self:UpdateCooldowns()
end

function PetBarModule:UpdateActions()
    if not (self.bar and PetHasActionBar() and UnitIsVisible("pet")) then return end

    self.bar:ForButtons("Update")
end

function PetBarModule:UpdateCooldowns()
    if not (self.bar and PetHasActionBar() and UnitIsVisible("pet")) then return end

    self.bar:ForButtons("UpdateCooldown")
end