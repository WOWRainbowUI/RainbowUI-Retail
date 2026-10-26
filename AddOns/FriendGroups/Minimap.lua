local addonName, addonTable = ...
local L = addonTable.L
local Compat = addonTable.Compat

-- The minimap button through LibDBIcon, and the same entry in the addon compartment.
-- Left-click toggles the contact list; right-click opens the settings menu.
local Broker = LibStub("LibDataBroker-1.1", true)
local Icon = LibStub("LibDBIcon-1.0", true)

local function AddTips(tooltip, draggable)
    tooltip:AddLine(FriendGroups_AccentText(addonName))
    tooltip:AddLine(L["MINIMAP_TIP_LEFT"], 1, 1, 1)
    tooltip:AddLine(L["MINIMAP_TIP_RIGHT"], 1, 1, 1)
    if draggable then tooltip:AddLine(L["MINIMAP_TIP_DRAG"], 1, 1, 1) end
end

local launcher = Broker and Broker:NewDataObject(addonName, {
    type = "launcher",
    text = addonName,
    icon = "Interface\\AddOns\\FriendGroups\\Textures\\fg_icon",
    OnClick = function(clicked, button)
        if button == "RightButton" then
            if not FriendGroups_BuildSettingsMenu then return end
            -- A compartment row is torn down as its menu closes, so it cannot own ours.
            local minimapButton = Icon and Icon:GetMinimapButton(addonName)
            local owner = (minimapButton and clicked == minimapButton) and minimapButton
                or AddonCompartmentFrame or UIParent
            Compat.OpenContextMenu(owner, FriendGroups_BuildSettingsMenu)
        elseif InCombatLockdown() then
            -- Opening from addon code runs FriendsFrame's OnShow tainted: CurseForge #55.
            UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT, 1, 0.1, 0.1)
        else
            ToggleFriendsFrame(FRIEND_TAB_FRIENDS)
        end
    end,
    OnTooltipShow = function(tooltip)
        local button = Icon and Icon:GetMinimapButton(addonName)
        AddTips(tooltip, button ~= nil and tooltip:GetOwner() == button)
    end,
})

-- LibDBIcon keeps its own hide, position and compartment flags in sv.minimap.
function FriendGroups_UpdateMinimapButton()
    local sv = FriendGroups_SavedVars
    if not (Icon and launcher and sv) then return end
    if type(sv.minimap) ~= "table" then sv.minimap = {} end
    local db = sv.minimap
    db.hide = not sv.show_minimap_button
    if not Icon:IsRegistered(addonName) then
        db.showInCompartment = (sv.show_compartment and Compat.HAS_COMPARTMENT) or nil
        Icon:Register(addonName, launcher, db)
    end
    if db.hide then Icon:Hide(addonName) else Icon:Show(addonName) end
    if Compat.HAS_COMPARTMENT then
        if sv.show_compartment then
            Icon:AddButtonToCompartment(addonName)
        else
            Icon:RemoveButtonFromCompartment(addonName)
        end
    end
end

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("PLAYER_LOGIN")
EventFrame:SetScript("OnEvent", function(self)
    FriendGroups_UpdateMinimapButton()
    self:UnregisterEvent("PLAYER_LOGIN")
end)
