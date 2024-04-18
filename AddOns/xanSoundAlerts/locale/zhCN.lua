local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhCN")
if not L then return end

L.ChkBtnHealthOn = "xanSoundAlerts: 低生命值声音警报 [|cFF99CC33开|r]"
L.ChkBtnHealthOff = "xanSoundAlerts: 低生命值声音警报 [|cFF99CC33关|r]"
L.ChkBtnHealthInfo = "启用低生命值声音警报"

L.ChkBtnManaOn = "xanSoundAlerts: 低法力值声音警报 [|cFF99CC33开|r]"
L.ChkBtnManaOff = "xanSoundAlerts: 低法力值声音警报 [|cFF99CC33关|r]"
L.ChkBtnManaInfo = "启用低法力值声音警报"

L.ChkBtnOtherInfo = "启用 [|cff40e0d0%s|r] 声音警报"
L.ChkBtnOtherOn = "xanSoundAlerts: 现在[|cff40e0d0%s|r] 声音警报 [|cFF99CC33开|r]"
L.ChkBtnOtherOff = "xanSoundAlerts: 现在[|cff40e0d0%s|r] 声音警报 [|cFF99CC33关|r]"
