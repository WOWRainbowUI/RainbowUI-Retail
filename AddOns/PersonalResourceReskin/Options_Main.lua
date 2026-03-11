-- Options_Main.lua

local AceConfig = LibStub and LibStub("AceConfig-3.0", true)
local AceConfigDialog = LibStub and LibStub("AceConfigDialog-3.0", true)

local mainOptions = {
    name = "個人資源條外觀增強",
    type = "group",
    childGroups = "tab",
    args = {

    },
}

PersonalResourceReskinPlus_Options = {
    mainOptions = mainOptions,
    RegisterSubOptions = function(key, opts)
        mainOptions.args[key] = opts
    end,
    Register = function()
        if AceConfig and AceConfigDialog then
            AceConfig:RegisterOptionsTable("PersonalResourceReskinPlus", mainOptions)
            local frame, categoryID = AceConfigDialog:AddToBlizOptions("PersonalResourceReskinPlus", "個人資源條")
			_G.PersonalResourceReskinCategoryID = categoryID
        end
    end,
}

-- Defer registration to PLAYER_LOGIN so all sub-option files have loaded
local optRegFrame = CreateFrame("Frame")
optRegFrame:RegisterEvent("PLAYER_LOGIN")
optRegFrame:SetScript("OnEvent", function(self)
    self:UnregisterAllEvents()
    PersonalResourceReskinPlus_Options.Register()
end)
