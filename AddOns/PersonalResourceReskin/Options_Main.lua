-- Options_Main.lua

local AceConfig = LibStub and LibStub("AceConfig-3.0", true)
local AceConfigDialog = LibStub and LibStub("AceConfigDialog-3.0", true)

local mainOptions = {
    name = "Personal Resource Reskin Plus",
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
            AceConfigDialog:AddToBlizOptions("PersonalResourceReskinPlus", "Personal Resource Reskin Plus")
        end
    end,
}

-- Register on load
PersonalResourceReskinPlus_Options.Register()
