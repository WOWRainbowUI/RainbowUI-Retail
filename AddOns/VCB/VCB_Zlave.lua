-- create some global variables --
local function CreateGlobalVariables()
-- Colors --
	vcbMainColor = CreateColorFromRGBAHexString("F0E68CFF")
	vcbHighColor = CreateColorFromRGBAHexString("9ACD32FF")
	vcbNoMainColor = CreateColorFromRGBAHexString("F0E68C00")
	vcbNoHighColor = CreateColorFromRGBAHexString("9ACD3200")
-- Spell School Color --
	vcbPhysicalColor = CreateColorFromRGBAHexString("FFFF00FF") -- 1
	vcbHolyColor = CreateColorFromRGBAHexString("FFE680FF") -- 2
	vcbFireColor = CreateColorFromRGBAHexString("FF8000FF") -- 4
	vcbNatureColor = CreateColorFromRGBAHexString("4DFF4DFF") -- 8
	vcbFrostColor = CreateColorFromRGBAHexString("80FFFFFF") -- 16
	vcbShadowColor = CreateColorFromRGBAHexString("8080FFFF") -- 32
	vcbArcaneColor = CreateColorFromRGBAHexString("FF80FFFF") -- 64
	vcbHolystrikeColor = CreateColorFromRGBAHexString("FFF04DFF") -- 3
	vcbFlamestrikeColor = CreateColorFromRGBAHexString("FFB300FF") -- 5
	vcbRadiantColor = CreateColorFromRGBAHexString("FFA933FF") -- 6
	vcbStormstrikeColor = CreateColorFromRGBAHexString("A6FF27FF") -- 9
	vcbHolystormColor = CreateColorFromRGBAHexString("A6F367FF") -- 10
	vcbVolcanicColor = CreateColorFromRGBAHexString("A6C027FF") -- 12
	vcbFroststrikeColor = CreateColorFromRGBAHexString("C0FF80FF") -- 17
	vcbHolyfrostColor = CreateColorFromRGBAHexString("B3F5CCFF") -- 18
	vcbFrostfireColor = CreateColorFromRGBAHexString("C0C080FF") -- 20
	vcbFroststormColor = CreateColorFromRGBAHexString("67FFA6FF") -- 24
	vcbShadowstrikeColor = CreateColorFromRGBAHexString("B3B399FF") -- 33
	vcbTwilightColor = CreateColorFromRGBAHexString("C0B3C0FF") -- 34
	vcbShadowflameColor = CreateColorFromRGBAHexString("B38099FF") -- 36
	vcbPlagueColor = CreateColorFromRGBAHexString("67C0A6FF") -- 40
	vcbShadowfrostColor = CreateColorFromRGBAHexString("80B3FFFF") -- 48
	vcbSpellstrikeColor = CreateColorFromRGBAHexString("FFB399FF") -- 65
	vcbDivineColor = CreateColorFromRGBAHexString("FFB3C0FF") -- 66
	vcbSpellfireColor = CreateColorFromRGBAHexString("FF8080FF") -- 68
	vcbAstralColor = CreateColorFromRGBAHexString("A6C0A6FF") -- 72
	vcbSpellfrostColor = CreateColorFromRGBAHexString("C0C0FFFF") -- 80
	vcbSpellshadowColor = CreateColorFromRGBAHexString("C080FFFF") -- 96
	vcbElementalColor = CreateColorFromRGBAHexString("99D56FFF") -- 28
	vcbChromaticColor = CreateColorFromRGBAHexString("A9C78FFF") -- 62
	vcbCosmicColor = CreateColorFromRGBAHexString("C0B9DFFF") -- 106
	vcbMagicColor = CreateColorFromRGBAHexString("B7BBA2FF") -- 126
	vcbChaosColor = CreateColorFromRGBAHexString("C1C58BFF") -- 127 - 124
-- class color --
	vcbClassColorPlayer = C_ClassColor.GetClassColor(select(2, C_PlayerInfo.GetClass(PlayerLocation:CreateFromUnit("player"))))
-- faction and faction color --
	vcbFaction = C_CreatureInfo.GetFactionInfo(C_PlayerInfo.GetRace(PlayerLocation:CreateFromUnit("player")))
	local vcbFactionName = (vcbFaction.name == "部落") and "HORDE" or "ALLIANCE" -- 暫時修正
	vcbFactionColor = CreateColor(_G["PLAYER_FACTION_COLOR_"..vcbFactionName]:GetRGB())
-- function for showing the menu --
	local function vcbShowMenu()
		if not InCombatLockdown() then
			local _, loaded = C_AddOns.IsAddOnLoaded("VCB_Options")
			local loadable, reason = C_AddOns.IsAddOnLoadable("VCB_Options" , nil , true)
			if loadable and not loaded then
				C_AddOns.LoadAddOn("VCB_Options")
				if not vcbOptions00:IsShown() then
					vcbOptions00:Show()
				else
					vcbOptions00:Hide()
				end
			elseif loadable and loaded then
				if not vcbOptions00:IsShown() then
					vcbOptions00:Show()
				else
					vcbOptions00:Hide()
				end
			else
				local vcbTime = GameTime_GetTime(false)
				DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] The addon with the name "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB_Options", "Title")).." is "..reason.."!")
			end
		else
			local vcbTime = GameTime_GetTime(false)
			DEFAULT_CHAT_FRAME:AddMessage(vcbTime.." |A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a ["..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."] While you are in combat, you can't do this!")
		end
	end
-- Slash Command --
	RegisterNewSlashCommand(vcbShowMenu, "vcb", "voodoocastingbar")
-- Mini Map Button Functions --
	AddonCompartmentFrame:RegisterAddon({
		text = vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")),
		icon = C_AddOns.GetAddOnMetadata("VCB", "IconAtlas"),
		notCheckable = true,
		func = function(button, menuInputData, menu)
			local buttonName = menuInputData.buttonName
			if buttonName == "LeftButton" then
				vcbShowMenu()
			end
		end,
		funcOnEnter = function(button)
			MenuUtil.ShowTooltip(button, function(tooltip)
			tooltip:SetText("|A:"..C_AddOns.GetAddOnMetadata("VCB", "IconAtlas")..":16:16|a "..vcbMainColor:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")).."|nLeft Click: "..vcbMainColor:WrapTextInColorCode("Open the main panel of settings!"))
			end)
		end,
		funcOnLeave = function(button)
			MenuUtil.HideTooltip(button)
		end,
	})
end
-- First Time Saved Variables --
local function FirstTimeSavedVariables()
	if VCBrCounterLoading == nil or VCBrCounterLoading ~= nil then VCBrCounterLoading = 0 end
	if VCBrCounterDeleting == nil or VCBrCounterDeleting ~= nil then VCBrCounterDeleting = 0 end
	if VCBrProfile == nil then VCBrProfile = {} end
	if VCBrNumber == nil then VCBrNumber = 0 end
	if VCBrPlayer == nil then
		VCBrPlayer = { NameText = "左下",
			CurrentTimeText = {Position = "隱藏", Direction = "兩者", Sec = "隱藏"},
			TotalTimeText = {Position = "隱藏", Sec = "隱藏"},
			BothTimeText = {Position = "右下", Direction = "兩者", Sec = "隱藏"},
			LagBar = "顯示",
			Icon = "左",
			Color = "預設顏色",
			Art = "預設",
			Ticks = "顯示",
		}
	end
	if VCBrTarget == nil then
		VCBrTarget = { Unlock = false,
			Position = {X = 0, Y = 0},
			Scale = 100,
			NameText = "左上",
			CurrentTimeText = {Position = "隱藏", Direction = "兩者", Sec = "隱藏"},
			TotalTimeText = {Position = "隱藏", Sec = "隱藏"},
			BothTimeText = {Position = "右下", Direction = "兩者", Sec = "隱藏"},
			Color = "預設顏色",
			Art = "預設",
			otherAdddon = "無",
		}
	end
	if VCBrFocus == nil then
		VCBrFocus = { Unlock = false,
			Position = {X = 0, Y = 0},
			Scale = 100,
			NameText = "左上",
			CurrentTimeText = {Position = "隱藏", Direction = "兩者", Sec = "隱藏"},
			TotalTimeText = {Position = "隱藏", Sec = "隱藏"},
			BothTimeText = {Position = "右下", Direction = "兩者", Sec = "隱藏"},
			Color = "預設顏色",
			Art = "預設",
			otherAdddon = "無",
		}
	end
	if VCBrPlayer["CurrentTimeText"]["Decimals"] == nil then VCBrPlayer["CurrentTimeText"]["Decimals"] = 1 end
	if VCBrPlayer["TotalTimeText"]["Decimals"] == nil then VCBrPlayer["TotalTimeText"]["Decimals"] = 1 end
	if VCBrPlayer["BothTimeText"]["Decimals"] == nil then VCBrPlayer["BothTimeText"]["Decimals"] = 1 end
	if VCBrTarget["CurrentTimeText"]["Decimals"] == nil then VCBrTarget["CurrentTimeText"]["Decimals"] = 1 end
	if VCBrTarget["TotalTimeText"]["Decimals"] == nil then VCBrTarget["TotalTimeText"]["Decimals"] = 1 end
	if VCBrTarget["BothTimeText"]["Decimals"] == nil then VCBrTarget["BothTimeText"]["Decimals"] = 1 end
	if VCBrFocus["CurrentTimeText"]["Decimals"] == nil then VCBrFocus["CurrentTimeText"]["Decimals"] = 1 end
	if VCBrFocus["TotalTimeText"]["Decimals"] == nil then VCBrFocus["TotalTimeText"]["Decimals"] = 1 end
	if VCBrFocus["BothTimeText"]["Decimals"] == nil then VCBrFocus["BothTimeText"]["Decimals"] = 1 end
	if VCBrPlayer["GCD"] == nil then VCBrPlayer["GCD"] = {ClassicTexture = "隱藏",} end
	if VCBrPlayer["QueueBar"] == nil then VCBrPlayer["QueueBar"] = "顯示" end
end
-- Events Time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		CreateGlobalVariables()
		FirstTimeSavedVariables()
	end
end
vcbZlave:SetScript("OnEvent", EventsTime)
