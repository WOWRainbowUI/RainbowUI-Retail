local _, ns = ...
local ProfileSettings = {}
ns.ProfileSettings = ProfileSettings

local SettingsLib = LibStub("LibEQOLSettingsMode-1.0")

ProfileSettings._pendingExportString = nil
ProfileSettings._pendingImportString = nil

StaticPopupDialogs["CMC_CREATE_NEW_PROFILE"] = {
    text = "輸入新設定檔名稱：",
    button1 = "建立",
    button2 = "取消",
    hasEditBox = true,
    maxLetters = 32,
    OnAccept = function(self)
        local editBox = self.editBox or (self.GetEditBox and self:GetEditBox())
        local text = editBox:GetText()
        if text and strtrim(text) ~= "" then
            local trimmed = strtrim(text)
            local profiles = ns.ProfileAPI:GetProfiles()
            local exists = false
            for _, name in ipairs(profiles) do
                if name:lower() == trimmed:lower() then
                    exists = true
                    break
                end
            end
            if exists then
                ns.Addon:Print("已存在相同名稱的設定檔。")
            else
                if ns.ProfileAPI:CreateProfile(trimmed) then
                    ns.Addon:Print("已建立並切換至設定檔： " .. trimmed)
                end
            end
        else
            ns.Addon:Print("請輸入有效的設定檔名稱。")
        end
    end,
    OnShow = function(self)
        local editBox = self.editBox or (self.GetEditBox and self:GetEditBox())
        editBox:SetText("")
        editBox:SetFocus()
    end,
    EditBoxOnEnterPressed = function(self)
        StaticPopup_OnClick(self:GetParent(), 1)
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["CMC_CONFIRM_DELETE_PROFILE"] = {
    text = "確定要刪除設定檔：\n\n|cffff0000%s|r\n\n此操作無法復原。",
    button1 = "刪除",
    button2 = "取消",
    OnAccept = function(self, profileName)
        if profileName and ns.ProfileAPI:DeleteProfile(profileName) then
            ns.Addon:Print("已刪除設定檔： " .. profileName)
        else
            ns.Addon:Print("刪除設定檔失敗。")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["CMC_EXPORT_PROFILE"] = {
    text = "複製此匯出字串（Ctrl+C）：\n\n設定檔：|cff00ff00%s|r",
    button1 = "關閉",
    hasEditBox = true,
    editBoxWidth = 350,
    OnShow = function(self, data)
        local exportString = ns.ProfileSettings._pendingExportString or ""
        local editBox = self.editBox or (self.GetEditBox and self:GetEditBox())
        editBox:SetText(exportString)
        editBox:SetFocus()
        editBox:HighlightText()
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["CMC_IMPORT_PROFILE_STRING"] = {
    text = "請在下方貼上設定檔匯出字串：",
    button1 = "下一步",
    button2 = "取消",
    hasEditBox = true,
    editBoxWidth = 350,
    OnAccept = function(self)
        local editBox = self.editBox or (self.GetEditBox and self:GetEditBox())
        local text = editBox:GetText()
        if text and strtrim(text) ~= "" then
            local data, errorMsg = ns.ProfileAPI:DecodeExportString(text)
            if data then
                ns.ProfileSettings._pendingImportString = text
                StaticPopup_Show("CMC_IMPORT_PROFILE_NAME")
            else
                ns.Addon:Print("|cffff0000匯入錯誤：|r " .. (errorMsg or "無效的匯入字串。"))
            end
        else
            ns.Addon:Print("請貼上有效的匯出字串。")
        end
    end,
    OnShow = function(self)
        local editBox = self.editBox or (self.GetEditBox and self:GetEditBox())
        editBox:SetText("")
        editBox:SetFocus()
    end,
    EditBoxOnEnterPressed = function(self)
        StaticPopup_OnClick(self:GetParent(), 1)
    end,
    EditBoxOnEscapePressed = function(self)
        ns.ProfileSettings._pendingImportString = nil
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["CMC_IMPORT_PROFILE_NAME"] = {
    text = "輸入匯入設定檔的名稱：",
    button1 = "匯入",
    button2 = "取消",
    hasEditBox = true,
    maxLetters = 32,
    OnAccept = function(self)
        local editBox = self.editBox or (self.GetEditBox and self:GetEditBox())
        local profileName = editBox:GetText()
        local importString = ns.ProfileSettings._pendingImportString
        if not importString then
            ns.Addon:Print("|cffff0000匯入錯誤：|r 找不到匯入資料。")
            return
        end
        if profileName and strtrim(profileName) ~= "" then
            local trimmed = strtrim(profileName)
            local success, errorMsg = ns.ProfileAPI:ImportFromString(importString, trimmed)
            if success then
                ns.Addon:Print("|cff00ff00成功匯入設定檔：|r " .. trimmed)
            else
                ns.Addon:Print("|cffff0000匯入錯誤：|r " .. (errorMsg or "匯入設定檔失敗。"))
            end
        else
            ns.Addon:Print("請輸入有效的設定檔名稱。")
        end
        ns.ProfileSettings._pendingImportString = nil
    end,
    OnShow = function(self)
        local editBox = self.editBox or (self.GetEditBox and self:GetEditBox())
        editBox:SetFocus()
    end,
    OnCancel = function()
        ns.ProfileSettings._pendingImportString = nil
    end,
    EditBoxOnEnterPressed = function(self)
        StaticPopup_OnClick(self:GetParent(), 1)
    end,
    EditBoxOnEscapePressed = function(self)
        ns.ProfileSettings._pendingImportString = nil
        self:GetParent():Hide()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function ProfileSettings:BuildSettings(parentCategory)
    local profileCategory = SettingsLib:CreateCategory(parentCategory, "設定檔", false)
    ns.WilduSettings.SettingsLayout.profileCategory = profileCategory

    SettingsLib:CreateText(profileCategory, {
        name = "管理你的插件設定檔。",
    })

    SettingsLib:CreateDropdown(profileCategory, {
        prefix = "CMC_",
        key = "profile_current",
        name = "啟用的設定檔",
        default = "",
        optionfunc = function()
            local profiles = ns.ProfileAPI:GetProfiles()
            local values = {}
            for _, name in ipairs(profiles) do
                values[name] = name
            end
            return values
        end,
        get = function()
            return ns.ProfileAPI:GetCurrentProfile()
        end,
        set = function(value)
            if value and value ~= ns.ProfileAPI:GetCurrentProfile() then
                ns.ProfileAPI:SetProfile(value)
            end
        end,
    })

    SettingsLib:CreateButton(profileCategory, {
        text = "建立新檔",
        func = function()
            StaticPopup_Show("CMC_CREATE_NEW_PROFILE")
        end,
        desc = "以自訂名稱建立新設定檔。",
    })

    SettingsLib:CreateHeader(profileCategory, {
        name = "匯入 / 匯出",
    })

    SettingsLib:CreateButton(profileCategory, {
        text = "匯出",
        func = function()
            local exportString = ns.ProfileAPI:GetExportString()
            if exportString and exportString ~= "" then
                ns.ProfileSettings._pendingExportString = exportString
                local currentProfile = ns.ProfileAPI:GetCurrentProfile()
                StaticPopup_Show("CMC_EXPORT_PROFILE", currentProfile)
            else
                ns.Addon:Print("產生匯出字串失敗。")
            end
        end,
        desc = "將目前設定檔匯出為可分享的字串。",
    })

    SettingsLib:CreateButton(profileCategory, {
        text = "匯入",
        func = function()
            StaticPopup_Show("CMC_IMPORT_PROFILE_STRING")
        end,
        desc = "從匯出字串匯入設定檔。",
    })

    SettingsLib:CreateHeader(profileCategory, {
        name = "|cffff0000刪除設定檔|r",
    })

    SettingsLib:CreateDropdown(profileCategory, {
        prefix = "CMC_",
        key = "profile_delete",
        name = "選擇要刪除的設定檔",
        default = "",
        optionfunc = function()
            local profiles = ns.ProfileAPI:GetProfiles()
            local values = { [""] = "選擇一個設定檔..." }
            local current = ns.ProfileAPI:GetCurrentProfile()
            for _, name in ipairs(profiles) do
                if name ~= current then
                    values[name] = name
                end
            end
            return values
        end,
        get = function()
            return ""
        end,
        set = function(value)
            if value and value ~= "" then
                StaticPopup_Show("CMC_CONFIRM_DELETE_PROFILE", value, nil, value)
            end
        end,
        desc = "選擇要刪除的設定檔（無法刪除目前啟用的設定檔）。",
    })
end
