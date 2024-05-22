---@class RemixGemHelperPrivate
local Private = select(2, ...)
local const = Private.constants


local settings = {
    db = {
        show_unowned = false,
        show_primordial = false,
        show_frame = true,
        show_helpframe = true
    },
    callbacks = {}
}
Private.Settings = settings

function settings:GetSetting(settingName)
    return self.db[settingName]
end

function settings:UpdateSetting(settingName, newState)
    self.db[settingName] = newState
    if self.callbacks[settingName] then
        for _, callback in ipairs(self.callbacks[settingName]) do
            callback(settingName, newState)
        end
    end
end

function settings:CreateSettingCallback(settingName, callback)
    if not self.callbacks[settingName] then
        self.callbacks[settingName] = {}
    end
    tinsert(self.callbacks[settingName], callback)
    callback(settingName, self.db[settingName])
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function (self, event, addon)
    if event == "ADDON_LOADED" and addon == const.ADDON_NAME then
        self:UnregisterAllEvents()
        self:SetScript("OnEvent", nil)

        RemixGemHelperDB = RemixGemHelperDB or settings.db
        local defaults = settings.db
        settings.db = RemixGemHelperDB

        for settingName, defaultState in pairs(defaults) do
            if settings.db[settingName] == nil then
                settings.db[settingName] = defaultState
            end
            local state = settings.db[settingName]
            if settings.callbacks[settingName] then
                for _, callback in ipairs(self.callbacks[settingName]) do
                    callback(settingName, state)
                end
            end
        end
    end
end)