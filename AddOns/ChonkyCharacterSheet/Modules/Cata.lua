local addonName, ns = ...
local CCS = ns.CCS

local module = {
    Name = "Cata Module",
    CompatibleVersions = { CCS.CATA },
    OnInitialize = function(self)
        --print(self.Name .. " initialized for Cata")
    end,
}

CCS.Modules[module.Name] = module
