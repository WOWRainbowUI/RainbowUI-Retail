local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhTW")
if not L then return end

L.ChkBtnHealthOn = "xanSoundAlerts: 血量提醒音效現在 [|cFF99CC33開啟|r]"
L.ChkBtnHealthOff = "xanSoundAlerts: 血量提醒音效現在 [|cFF99CC33關閉|r]"
L.ChkBtnHealthInfo = "啟用血量提醒音效。"

L.ChkBtnManaOn = "xanSoundAlerts: 法力提醒音效現在 [|cFF99CC33開啟|r]"
L.ChkBtnManaOff = "xanSoundAlerts: 法力提醒音效現在 [|cFF99CC33關閉|r]"
L.ChkBtnManaInfo = "啟用法力提醒音效。"

L.ChkBtnOtherInfo = "也要啟用 [|cff40e0d0%s|r] 的提醒音效。"
L.ChkBtnOtherOn = "xanSoundAlerts: [|cff40e0d0%s|r] 的提醒音效現在 [|cFF99CC33開啟|r]"
L.ChkBtnOtherOff = "xanSoundAlerts: [|cff40e0d0%s|r] 的提醒音效現在 [|cFF99CC33關閉|r]"

L.OPTION_NAME = "音效-血量/法力"
L.ADDON_NAME = "血量/法力過低音效"
