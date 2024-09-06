-- Please use the Localization App on WoWAce to Update this
-- https://wow.curseforge.com/projects/wowgatheringnodes/localization

if GetLocale() ~= "zhTW" then return; end
local WoWGatheringNodes = LibStub("AceAddon-3.0"):GetAddon("WoWGatheringNodes")
local L = LibStub("AceLocale-3.0"):NewLocale("WoWGatheringNodes", "zhTW")
if not L then return end

L["Auto Import Data to Gathermate"] = "自動匯入資料到採集助手"
L["Auto Import New Data"] = "自動匯入新資料"
L["Auto Import to Data Gathermate"] = "自動匯入資料到採集助手"
L["Auto Import to Herb Data to Carbonite"] = "自動匯入採草資料到 Carbonite"
L["Auto Import to Mine Data to Carbonite"] = "自動匯入採礦資料到 Carbonite"
L["Automaticaly imports data when updated data is found"] = "有更新的資料時自動匯入"
L["Clear Data"] = "清空資料"
L["Clears data from memory if version has already been imported."] = "如果是已經匯入的版本，清空記憶體中的資料。"
L["Custom Objects"] = "自訂物件"
L["Enable Custom Objects"] = "啟用自訂物件"
L["Failed to load WoWGatheringNodes due to "] = "WoWGatheringNodes  載入失敗，原因是 "
L["Import WoWGatheringNodes"] = "匯入 WoWGatheringNodes"
L["Inject %s into gathering addons"] = "將 %s 加入到採集插件"
L["Injects new objects into Gatherer/Gathermate2 that are not currently in their data files"] = "加入不在 Gatherer/Gathermate2 資料檔案中的新物件"
L["Load WoWGatheringNodes and import the data to your database."] = "載入 WoWGatheringNodes 並匯入資料到你的資料庫。"
L["Merge will add WoWGatheringNodes to your database. Overwrite will replace your database with the data in WoWGatheringNodes"] = "合併會將 WoWGatheringNodes 加入到你的資料庫。否則會使用 WoWGatheringNodes 中的資料取代你的資料庫。"
L["WoWGatheringNodes has been imported."] = "WoWGatheringNodes  已匯入。"