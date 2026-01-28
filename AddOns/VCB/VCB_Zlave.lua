-- some variables --
VDW.VCB = VDW.VCB or {}
local G = VDW.Local.Override
local C = VDW.GetAddonColors("VCB")
local prefixTip = VDW.Prefix("VCB")
local prefixChat = VDW.PrefixChat("VCB")
local function CreateGlobalVariables()
-- function for opening the options --
	local function ShowMenu()
		if not InCombatLockdown() then
			local _, loaded = C_AddOns.IsAddOnLoaded("VCB_Options")
			local loadable, reason = C_AddOns.IsAddOnLoadable("VCB_Options" , nil , true)
			if reason == "MISSING" then
				C_Sound.PlayVocalErrorSound(48)
				DEFAULT_CHAT_FRAME:AddMessage(C.Main:WrapTextInColorCode(prefixChat.." "..string.format(G.WRN_ADDON_IS_STATE, C.High:WrapTextInColorCode("Voodoo Casting Bar Options"), reason)))
				UIErrorsFrame:AddExternalWarningMessage(string.format(G.WRN_ADDON_IS_STATE, C.High:WrapTextInColorCode("Voodoo Casting Bar Options"), reason))
			elseif loadable and not loaded then
				C_AddOns.LoadAddOn("VCB_Options")
				if not vcbOptions0:IsShown() then
					vcbOptions0:Show()
				else
					vcbOptions0:Hide()
				end
			elseif loadable and loaded then
				if not vcbOptions0:IsShown() then
					vcbOptions0:Show()
				else
					vcbOptions0:Hide()
				end
			else
				C_Sound.PlayVocalErrorSound(48)
				DEFAULT_CHAT_FRAME:AddMessage(C.Main:WrapTextInColorCode(prefixChat.." "..string.format(G.WRN_ADDON_IS_STATE, C_AddOns.GetAddOnMetadata("VCB_Options", "Title"), reason)))
				UIErrorsFrame:AddExternalWarningMessage(string.format(G.WRN_ADDON_IS_STATE, C_AddOns.GetAddOnMetadata("VCB_Options", "Title"), reason))
			end
		else
			C_Sound.PlayVocalErrorSound(48)
			DEFAULT_CHAT_FRAME:AddMessage(C.Main:WrapTextInColorCode(prefixChat.." "..G.WRN_COMBAT_LOCKDOWN))
			UIErrorsFrame:AddExternalWarningMessage(G.WRN_COMBAT_LOCKDOWN)
		end
	end
-- slash command --
	RegisterNewSlashCommand(ShowMenu, "vcb", "voodoocastingbar")
-- mini map button functions --
	AddonCompartmentFrame:RegisterAddon({
		text = C.Main:WrapTextInColorCode(C_AddOns.GetAddOnMetadata("VCB", "Title")),
		icon = C_AddOns.GetAddOnMetadata("VCB", "IconAtlas"),
		notCheckable = true,
		func = function(button, menuInputData, menu)
			local buttonName = menuInputData.buttonName
			if buttonName == "LeftButton" then
				ShowMenu()
			end
		end,
		funcOnEnter = function(button)
			MenuUtil.ShowTooltip(button, function(tooltip)
			tooltip:SetOwner(AddonCompartmentFrame, "ANCHOR_TOP", 0, 0)
			tooltip:SetText(C.Main:WrapTextInColorCode(prefixTip).."|n"..G.BUTTON_L_CLICK..": "..G.TIP_OPEN_SETTINGS_MAIN)
			end)
		end,
		funcOnLeave = function(button)
			MenuUtil.HideTooltip(AddonCompartmentFrame)
		end,
	})
end
-- loading first time the variables --
local function FirstTimeSavedVariables()
	if VCBprofiles == nil then VCBprofiles = {} end
	if VCBsettings == nil then VCBsettings = {} end
-- player settings --
	if VCBsettings["Player"] == nil then
		VCBsettings["Player"] = {
			NameText = {Position = G.OPTIONS_P_TOP,},
			CurrentTimeText = {Position = G.OPTIONS_P_BOTTOMLEFT, Direction = G.OPTIONS_P_BOTH, Sec = G.OPTIONS_V_SHOW, Decimals = "2",},
			TotalTimeText = {Position = G.OPTIONS_P_BOTTOMRIGHT, Sec = G.OPTIONS_V_SHOW, Decimals = "3",},
			BothTimeText = {Position = G.OPTIONS_V_HIDE, Direction = G.OPTIONS_P_BOTH, Sec = G.OPTIONS_V_HIDE, Decimals = "0",},
			LagBar = {Visibility = G.OPTIONS_V_SHOW,},
			QueueBar = {Visibility = G.OPTIONS_V_SHOW,},
			GCD = {Style = G.OPTIONS_S_CLASS_ICON, Position = G.OPTIONS_P_TOP,},
			Icon = {Position = G.OPTIONS_P_LEFT, Shield = G.OPTIONS_V_SHOW},
			StatusBar = {Color = G.OPTIONS_C_SPELL, Style = G.OPTIONS_C_DEFAULT},
			Border = {Color = G.OPTIONS_C_DEFAULT, Style = G.OPTIONS_C_DEFAULT},
		}
	end
-- target settings --
	if VCBsettings["Target"] == nil then
		VCBsettings["Target"] = {
			Lock = G.OPTIONS_LS_LOCKED,
			Position = {X = 860, Y = 540},
			Scale = 100,
			NameText = {Position = G.OPTIONS_P_TOP,},
			CurrentTimeText = {Position = G.OPTIONS_P_BOTTOMLEFT, Direction = G.OPTIONS_P_BOTH, Sec = G.OPTIONS_V_SHOW, Decimals = "2",},
			TotalTimeText = {Position = G.OPTIONS_P_BOTTOMRIGHT, Sec = G.OPTIONS_V_SHOW, Decimals = "3",},
			BothTimeText = {Position = G.OPTIONS_V_HIDE, Direction = G.OPTIONS_P_BOTH, Sec = G.OPTIONS_V_HIDE, Decimals = "0",},
			Icon = {Position = G.OPTIONS_P_LEFT, Shield = G.OPTIONS_V_SHOW},
			StatusBar = {Color = G.OPTIONS_C_CLASS, Style = G.OPTIONS_C_DEFAULT},
			Border = {Color = G.OPTIONS_C_DEFAULT, Style = G.OPTIONS_C_DEFAULT},
		}
	end
-- focus settings --
	if VCBsettings["Focus"] == nil then
		VCBsettings["Focus"] = {
			Lock = G.OPTIONS_LS_LOCKED,
			Position = {X = 860, Y = 540},
			Scale = 100,
			NameText = {Position = G.OPTIONS_P_TOP,},
			CurrentTimeText = {Position = G.OPTIONS_P_BOTTOMLEFT, Direction = G.OPTIONS_P_BOTH, Sec = G.OPTIONS_V_SHOW, Decimals = "2",},
			TotalTimeText = {Position = G.OPTIONS_P_BOTTOMRIGHT, Sec = G.OPTIONS_V_SHOW, Decimals = "3",},
			BothTimeText = {Position = G.OPTIONS_V_HIDE, Direction = G.OPTIONS_P_BOTH, Sec = G.OPTIONS_V_HIDE, Decimals = "0",},
			Icon = {Position = G.OPTIONS_P_LEFT, Shield = G.OPTIONS_V_SHOW},
			StatusBar = {Color = G.OPTIONS_C_CLASS, Style = G.OPTIONS_C_DEFAULT},
			Border = {Color = G.OPTIONS_C_DEFAULT, Style = G.OPTIONS_C_DEFAULT},
		}
	end
-- boss settings --
	if VCBsettings["Boss"] == nil then
		VCBsettings["Boss"] = {
			Lock = G.OPTIONS_LS_LOCKED,
			Position = {X = 860, Y = 540},
			Scale = 100,
			NameText = {Position = G.OPTIONS_P_TOP,},
			CurrentTimeText = {Position = G.OPTIONS_P_BOTTOMLEFT, Direction = G.OPTIONS_P_BOTH, Sec = G.OPTIONS_V_SHOW, Decimals = "2",},
			TotalTimeText = {Position = G.OPTIONS_P_BOTTOMRIGHT, Sec = G.OPTIONS_V_SHOW, Decimals = "3",},
			BothTimeText = {Position = G.OPTIONS_V_HIDE, Direction = G.OPTIONS_P_BOTH, Sec = G.OPTIONS_V_HIDE, Decimals = "0",},
			Icon = {Position = G.OPTIONS_P_LEFT, Shield = G.OPTIONS_V_SHOW},
			StatusBar = {Color = G.OPTIONS_C_CLASS, Style = G.OPTIONS_C_DEFAULT},
			Border = {Color = G.OPTIONS_C_DEFAULT, Style = G.OPTIONS_C_DEFAULT},
		}
	end
-- arena settings --
	if VCBsettings["Arena"] == nil then
		VCBsettings["Arena"] = {
			Lock = G.OPTIONS_LS_LOCKED,
			Position = {X = 860, Y = 540},
			Scale = 100,
			NameText = {Position = G.OPTIONS_P_TOP,},
			CurrentTimeText = {Position = G.OPTIONS_P_BOTTOMLEFT, Direction = G.OPTIONS_P_BOTH, Sec = G.OPTIONS_V_SHOW, Decimals = "2",},
			TotalTimeText = {Position = G.OPTIONS_P_BOTTOMRIGHT, Sec = G.OPTIONS_V_SHOW, Decimals = "3",},
			BothTimeText = {Position = G.OPTIONS_V_HIDE, Direction = G.OPTIONS_P_BOTH, Sec = G.OPTIONS_V_HIDE, Decimals = "0",},
			Icon = {Position = G.OPTIONS_P_LEFT, Shield = G.OPTIONS_V_SHOW},
			StatusBar = {Color = G.OPTIONS_C_CLASS, Style = G.OPTIONS_C_DEFAULT},
			Border = {Color = G.OPTIONS_C_DEFAULT, Style = G.OPTIONS_C_DEFAULT},
		}
	end
-- special settings --
	if VCBspecialSettings == nil then VCBspecialSettings = {} end
	if VCBspecialSettings["Player"] == nil then
		VCBspecialSettings["Player"] = {
			Ticks = {Style = G.OPTIONS_V_HIDE,},
		}
	end
	if VCBspecialSettings["LastLocation"] == nil then
		VCBspecialSettings["LastLocation"] = GetLocale()
	end
end
-- events time --
local function EventsTime(self, event, arg1, arg2, arg3, arg4)
	if event == "PLAYER_LOGIN" then
		CreateGlobalVariables()
		FirstTimeSavedVariables()
	end
end
vcbZlave:SetScript("OnEvent", EventsTime)
