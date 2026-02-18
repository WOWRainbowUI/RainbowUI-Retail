--- MSA-AceConfigPatcher-1.0
---
--- Marouan Sabbagh <mar.sabbagh@gmail.com>

local name, version = "MSA-AceConfigPatcher-1.0", 0

local lib = LibStub:NewLibrary(name, version)
if not lib then return end

local aceConfigNamespaces = { "", "-ElvUI" }

lib.optionsPatches = lib.optionsPatches or {}

function lib:ApplyOptionsPatches(appName, namespace)
    local patchList = lib.optionsPatches[appName]
    if not patchList then return end

    local ACR = LibStub("AceConfigRegistry-3.0"..namespace)
    local options = ACR:GetOptionsTable(appName, "dialog", name)
    if type(options) == "function" then
        options = options()
    end
    if not options then return end

    if options._MSA_Patched then return end
    options._MSA_Patched = true

    for _, patchFunc in ipairs(patchList) do
        patchFunc(options)
    end
end

function lib:RegisterOptionsPatch(appName, patchFunc)
    lib.optionsPatches[appName] = lib.optionsPatches[appName] or {}
    table.insert(lib.optionsPatches[appName], patchFunc)
end

function lib:Init()
    for _, namespace in ipairs(aceConfigNamespaces) do
        local ACD = LibStub("AceConfigDialog-3.0"..namespace, true)
        if ACD then
            local bck_ACD_Open = ACD.Open
            function ACD:Open(appName, container, ...)
                lib:ApplyOptionsPatches(appName, namespace)
                bck_ACD_Open(self, appName, container, ...)
            end
        end
    end
end

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:SetScript("OnEvent", function(self, event)
    lib:Init()
    self:UnregisterEvent(event)
end)
lib.eventFrame:RegisterEvent("PLAYER_LOGIN")

-- Embed handling ------------------------------------------------------------------------------------------------------

local mixins = {
    "RegisterOptionsPatch"
}

lib.embeds = lib.embeds or {}

function lib:Embed(target)
    for _, v in ipairs(mixins) do
        target[v] = self[v]
    end
    self.embeds[target] = true
    return target
end

for target in pairs(lib.embeds) do
    lib:Embed(target)
end