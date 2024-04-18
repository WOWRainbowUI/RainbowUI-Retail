local ADDON_NAME, addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhTW")
if not L then return end

L.ChkBtnHealthOn = "xanSoundAlerts: 低生命值聲音警報 [|cFF99CC33開|r]"
L.ChkBtnHealthOff = "xanSoundAlerts: 低生命值聲音警報 [|cFF99CC33關|r]"
L.ChkBtnHealthInfo = "啓用低生命值聲音警報"

L.ChkBtnManaOn = "xanSoundAlerts: 低法力值聲音警報 [|cFF99CC33開|r]"
L.ChkBtnManaOff = "xanSoundAlerts: 低法力值聲音警報 [|cFF99CC33關|r]"
L.ChkBtnManaInfo = "啓用低法力值聲音警報"

L.ChkBtnOtherInfo = "啓用 [|cff40e0d0%s|r] 聲音警報"
L.ChkBtnOtherOn = "xanSoundAlerts: 現在[|cff40e0d0%s|r] 声音警报 [|cFF99CC33開|r]"
L.ChkBtnOtherOff = "xanSoundAlerts: 現在[|cff40e0d0%s|r] 声音警报 [|cFF99CC33關|r]"
