--- MSA-AceConfigPatcher-1.0
--- Copyright (c) 2025-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.

local name, version = "MSA-AceConfigPatcher-1.0", 3

local lib = LibStub:NewLibrary(name, version)
if not lib then return end

-- AceConfig -----------------------------------------------------------------------------------------------------------

local aceConfigNamespaces = { "", "-ElvUI" }

lib.aceOptionsPatches = lib.aceOptionsPatches or {}

function lib:Ace_ApplyOptionsPatches(appName, namespace)
    local patchList = lib.aceOptionsPatches[appName]
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

function lib:Ace_RegisterOptionsPatch(appName, patchFunc)
    lib.aceOptionsPatches[appName] = lib.aceOptionsPatches[appName] or {}
    table.insert(lib.aceOptionsPatches[appName], patchFunc)
end

function lib:Ace_InitOptions()
    for _, namespace in ipairs(aceConfigNamespaces) do
        local ACD = LibStub("AceConfigDialog-3.0"..namespace, true)
        if ACD then
            local bck_ACD_Open = ACD.Open
            function ACD:Open(appName, container, ...)
                lib:Ace_ApplyOptionsPatches(appName, namespace)
                bck_ACD_Open(self, appName, container, ...)
            end
        end
    end
end

-- Blizzard ------------------------------------------------------------------------------------------------------------

lib.blizOptionsPatches = lib.blizOptionsPatches or {}

local measureText = UIParent:CreateFontString(nil, "ARTWORK")
measureText:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", -100, -100)
measureText:SetWordWrap(true)

local function GetOptionsLayout(category)
    local layout = SettingsPanel:GetLayout(category)
    if not layout then return end

    if layout:IsVerticalLayout() then
        return layout, SettingsPanel:GetSettingsList().ScrollBox
    end

    local page = layout:GetFrame()
    if page.layout and page.layout.GetInitializers and page.List and page.List.ScrollBox then
        return page.layout, page.List.ScrollBox
    end
end

function lib:Bliz_AddOptionsText(category, parentInitializer, options)
    local layout, scrollBox = GetOptionsLayout(category)
    if not layout then return end

    local text = options.text
    local font = options.font or GameFontHighlightSmall
    local left = 37 + (options.indent or 15)
    local right = options.paddingRight or 0
    local top = options.paddingTop or 0

    local initializer = Settings.CreateElementInitializer("SettingsListElementTemplate", {})

    function initializer:GetExtent()
        measureText:SetFontObject(font)
        measureText:SetWidth(math.max(1, scrollBox:GetWidth() - 25 - left - right))
        measureText:SetText(text)
        return math.ceil(26 + math.max(0, measureText:GetStringHeight() - measureText:GetLineHeight()) + top)
    end

    function initializer:InitFrame(frame)
        frame.Tooltip:Hide()
        frame.NewFeature:Hide()

        local label = frame.Text
        label:ClearAllPoints()
        label:SetPoint("LEFT", frame, "LEFT", left, -top / 2)
        label:SetPoint("RIGHT", frame, "RIGHT", -right, -top / 2)
        label:SetFontObject(font)
        label:SetJustifyH("LEFT")
        label:SetJustifyV("TOP")
        label:SetWordWrap(true)
        label:SetText(text)
        label:Show()
    end

    function initializer:Resetter(frame)
        frame.Text:SetText(nil)
    end

    local rows = layout:GetInitializers()
    for i, row in ipairs(rows) do
        if row == parentInitializer then
            table.insert(rows, i + 1, initializer)
            break
        end
    end
end

function lib:Bliz_ApplyOptionsPatches(category, initializer, nextInitializer)
    local setting = initializer.GetSetting and initializer:GetSetting()
    local variable = setting and setting:GetVariable()
    local patchList = lib.blizOptionsPatches[variable]
    if not patchList then return end

    if initializer._MSA_Patched then return end
    initializer._MSA_Patched = true

    local options = initializer:GetData()
    local nextOptions = nextInitializer and nextInitializer:GetData()

    for _, patchFunc in ipairs(patchList) do
        patchFunc(options, nextOptions, initializer, category)
    end

    if nextOptions and nextOptions.hidden then
        nextInitializer:AddShownPredicate(function()
            return false
        end)
    end

    local description = options.description
    if description then
        if type(description) == "string" then
            description = { text = description }
        end
        lib:Bliz_AddOptionsText(category, initializer, description)
    end
end

function lib:Bliz_RegisterOptionsPatch(variable, patchFunc)
    lib.blizOptionsPatches[variable] = lib.blizOptionsPatches[variable] or {}
    table.insert(lib.blizOptionsPatches[variable], patchFunc)
end

function lib:Bliz_InitOptions()
    hooksecurefunc(SettingsPanel, "SetCurrentCategory", function(self, category)
        local layout = GetOptionsLayout(category)
        if not layout then return end

        local initializers = layout:GetInitializers()
        for i = #initializers, 1, -1 do
            lib:Bliz_ApplyOptionsPatches(category, initializers[i], initializers[i + 1])
        end
    end)
end

-- Init ----------------------------------------------------------------------------------------------------------------

lib.eventFrame = lib.eventFrame or CreateFrame("Frame")
lib.eventFrame:SetScript("OnEvent", function(self, event)
    lib:Ace_InitOptions()
    lib:Bliz_InitOptions()
    self:UnregisterEvent(event)
end)
lib.eventFrame:RegisterEvent("PLAYER_LOGIN")

-- Embed handling ------------------------------------------------------------------------------------------------------

local mixins = {
    "Ace_RegisterOptionsPatch",
    "Bliz_RegisterOptionsPatch",
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