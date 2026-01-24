--[[
    Copyright (c) 2023 Krowi
    Licensed under the terms of the LICENSE file in this repository.
]]

---@diagnostic disable: undefined-global

local lib = KROWI_LIBMAN:GetCurrentLibrary(true)
if not lib then	return end

local L = lib.Localization.NewLocale('zhTW')
if not L then return end

-- [[ Everything after this line is automatically generated from CurseForge and is not meant for manual edit - SOURCETOKEN - AUTOGENTOKEN ]] --

-- [[ Exported at 2026-01-12 19-39-11 ]] --
L['Author'] = '作者'
L['Build'] = '版本'
L['Checked'] = '已勾選'
L['Credits'] = '致謝'
L['CurseForge'] = true
L['CurseForge Desc'] = '開啟包含 {addonName} {curseForge} 頁面連結的視窗。'
L['Default value'] = '預設值'
L['Deselect All'] = '取消全選'
L['Discord'] = true
L['Discord Desc'] = '開啟包含 {serverName} Discord 伺服器連結的視窗。您可以在該伺服器提交評論、回報問題、建議、想法或其他任何內容。'
L['Donations'] = '贊助'
L['Hide'] = '隱藏'
L['Left click'] = '左鍵點擊'
L['Left-Click'] = '左鍵點擊'
L['Loaded'] = '已載入'
L['Loaded Desc'] = "顯示與此插件關聯的 UI 是否已載入。"
L['Localizations'] = '本地化'
L['Plugins'] = '外掛套件'
L['Profiles'] = '設定檔'
L['Requires a reload'] = '需要重新載入介面 (/reload)'
L['Right click'] = '右鍵點擊'
L['Right-Click'] = '右鍵點擊'
L['Select All'] = '全選'
L['Show minimap icon'] = "顯示小地圖圖示"
L['Show minimap icon Desc'] = "顯示或隱藏小地圖上的圖示。"
L['Special thanks'] = '特別感謝'
L['Unchecked'] = '未勾選'
L['Wago'] = true
L['Wago Desc'] = '開啟包含 {addonName} {wago} 頁面連結的視窗。'
