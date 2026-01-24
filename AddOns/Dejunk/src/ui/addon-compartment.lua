if not AddonCompartmentFrame then return end

local ADDON_NAME = ... ---@type string
local Addon = select(2, ...) ---@type Addon
local Commands = Addon:GetModule("Commands")

AddonCompartmentFrame:RegisterAddon({
  text = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title"),
  icon = Addon:GetAsset("dejunk-icon"),
  notCheckable = true,
  func = Commands.options
})
