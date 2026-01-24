local _, DR = ...

local L = {}
DR.L = L
local defaultsTable = DR.defaultsTable

local function defaultFunc(L, key)
 -- If this function was called, we have no localization for this key.
 -- We could complain loudly to allow localizers to see the error of their ways, 
 -- but, for now, just return the key as its own localization. This allows you to—avoid writing the default localization out explicitly.
 return key;
end
setmetatable(L, {__index=defaultFunc});

local LOCALE = GetLocale()

local NPC_KEYS = {
	Creature_Demonfly = 238717,
	Creature_Darkglare = 238786,
	Creature_FelSpreader = 238865,
	Creature_Felbat = 244780,
	Creature_Felbomber = 239089,
	Creature_Skyterror = 238713,
	Creature_EyeOfGreed = 244782,
};
local NPCNameCache = {};
local hiddenTip;

local function FetchNPCNameByID(npcID)
	local link = string.format("unit:Creature-0-0-0-0-%d-0000000000", npcID);

	if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
		local tooltipData = C_TooltipInfo.GetHyperlink(link);
		if tooltipData and tooltipData.lines and tooltipData.lines[1] then
			return tooltipData.lines[1].leftText;
		end
	else
		if not hiddenTip then
			hiddenTip = CreateFrame("GameTooltip", "DR_HiddenTooltip", UIParent, "GameTooltipTemplate");
			hiddenTip:SetOwner(UIParent, "ANCHOR_NONE");
		end
		hiddenTip:SetHyperlink(link);
		return DR_HiddenTooltipTextLeft1:GetText();
	end
end

local function GetNPCNameByID(npcID)
	if NPCNameCache[npcID] then
		return NPCNameCache[npcID];
	end
	local name = FetchNPCNameByID(npcID);
	if name then
		NPCNameCache[npcID] = name;
	end
	return name;
end

local function PreloadNPCNames()
	for key, npcID in pairs(NPC_KEYS) do
		local name = GetNPCNameByID(npcID);
		if name then
			L[key] = name;
		else
			L[key] = "Unknown NPC";
		end
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		PreloadNPCNames()
		self:UnregisterEvent("PLAYER_LOGIN") 
	end
end)

if LOCALE == "enUS" then
	-- The EU English game client also
	-- uses the US English locale code.
	L["Vigor"] = "Vigor"
	L["Speedometer"] = "Speedometer"
	L["ToggleModelsName"] = "Show Vigor Models"
	L["ToggleModelsTT"] = "Display the swirling model effect on the vigor bubbles."
	L["SpeedPosPointName"] = "Speedometer Position"
	L["SpeedPosPointTT"] = "Adjusts where the speedometer is anchored to relative to the vigor bar."
	L["Top"] = "Top"
	L["Bottom"] = "Bottom"
	L["Left"] = "Left"
	L["Right"] = "Right"
	L["SpeedPosXName"] = "Speedometer Horizontal Position"
	L["SpeedPosXTT"] = "Adjust the horizontal position of the speedometer."
	L["SpeedPosYName"] = "Speedometer Vertical Position"
	L["SpeedPosYTT"] = "Adjust the vertical position of the speedometer."
	L["SpeedScaleName"] = "Speedometer Scale"
	L["SpeedScaleTT"] = "Adjust the scale of the speedometer."
	L["Large"] = "Large"
	L["Small"] = "Small"
	L["Units"] = "Speedometer Units Text" -- Changed in 11.2.7
	L["UnitsTT"] = "Change the units displayed on the speedometer.\n(Mechanically 1 metre = 1 yard)"
	L["UnitsColor"] = "Speedometer Units Text Color" -- Changed in 11.2.7
	L["UnitYards"] = "yds/s"
	L["Yards"] = "Yards"
	L["UnitMiles"] = "mph"
	L["Miles"] = "Miles"
	L["UnitMeters"] = "m/s"
	L["Meters"] = "Metres"
	L["UnitKilometers"] = "km/h"
	L["Kilometers"] = "Kilometres"
	L["UnitPercent"] = "%"
	L["Percent"] = "Percentage"
	L["SpeedTextScale"] = "Speedometer Text Size"
	L["SpeedTextScaleTT"] = "Adjust the size of the text on the speedometer."
	L["Version"] = "Version %s"
	L["ResetAllSettings"] = "Reset all Dragon Rider settings"
	L["ResetAllSettingsTT"] = "Resets all settings specifically for this addon. This will include the custom color values."
	L["ResetAllSettingsConfirm"] = "Are you sure you want to reset the settings for Dragon Rider?"
	L["Low"] = "Low"
	L["High"] = "High"
	L["ProgressBar"] = "Speedometer" -- Deprecated
	L["ProgressBarColor"] = "Speedometer Color" -- Deprecated
	L["ColorPickerLowProgTT"] = "Choose a custom color for the low speed values of the speedometer. This occurs when the player is not gaining any vigor." -- Deprecated
	L["ColorPickerMidProgTT"] = "Choose a custom color for the vigor speed values of the speedometer. This occurs when the player is gaining vigor within standard speed range." -- Deprecated
	L["ColorPickerHighProgTT"] = "Choose a custom color for the high speed values of the speedometer. This occurs when the player is gaining vigor, but is above the standard speed range." -- Deprecated
	L["ColorPickerLowTextTT"] = "Choose a custom color for the low speed values of the speedometer text. This occurs when the player is not gaining any vigor." -- Deprecated
	L["ColorPickerMidTextTT"] = "Choose a custom color for the vigor speed values of the speedometer text. This occurs when the player is gaining vigor within standard speed range." -- Deprecated
	L["ColorPickerHighTextTT"] = "Choose a custom color for the high speed values of the speedometer text. This occurs when the player is gaining vigor, but is above the standard speed range." -- Deprecated
	L["DragonridingTalents"] = "Skyriding Skills and Unlocks" -- Changed in 11.2.7
	L["OpenDragonridingTalents"] = "Skyriding Skills and Unlocks" -- Changed in 11.2.7
	L["OpenDragonridingTalentsTT"] = "Open Skyriding Skills and Unlocks." -- Changed in 11.2.7
	L["SideArtName"] = "Side Art"
	L["SideArtTT"] = "Toggle the art on the sides of the main Vigor bar."
	L["BugfixesName"] = "Bugfixes" -- Deprecated
	L["BugfixesTT"] = "Experimental bug fix attempts for when default Blizzard frames aren't working as intended." -- Deprecated
	L["BugfixHideVigor"] = "Force Hide Vigor" -- Deprecated
	L["BugfixHideVigorTT"] = "Force hide the vigor bar when dismounted, and re-show when mounted on a skyriding mount." -- Deprecated
	L["FadeSpeedometer"] = "Fade Speedometer" -- Deprecated
	L["FadeSpeedometerTT"] = "Toggle fading the Speedometer when not gliding." -- Deprecated
	L["ShowVigorTooltip"] = "Show Vigor Tooltip"
	L["ShowVigorTooltipTT"] = "Toggle the tooltip that displays upon the Vigor bar."
	L["FadeVigor"] = "Fade Vigor"
	L["FadeVigorTT"] = "Toggle fading the Vigor bar when not gliding and while at full Vigor."
	L["LightningRush"] = "Show Static Charge Orbs" -- Changed in 11.2.7
	L["LightningRushTT"] = "Toggle the Static Charge orbs which are used by the Lightning Rush ability." -- Changed in 11.2.7
	L["DynamicFOV"] = "Dynamic FOV"
	L["DynamicFOVTT"] = "Enables adjustment of camera field of view based on gliding speed."
	L["Normal"] = "Normal"
	L["Advanced"] = "Advanced"
	L["Reverse"] = "Reverse"
	L["Challenge"] = "Challenge"
	L["ReverseChallenge"] = "Reverse Challenge"
	L["Storm"] = "Storm"
	L["COMMAND_help"] = "help"
	L["COMMAND_journal"] = "journal"
	L["COMMAND_listcommands"] = "A list of commands:"
	L["COMMAND_dragonrider"] = "dragonrider"
	L["DragonRider"] = "Dragon Rider"
	L["RightClick_TT_Line"] = "Right-Click: Open Settings"
	L["LeftClick_TT_Line"] = "Left-Click: Open Journal"
	L["SlashCommands_TT_Line"] = "'/dragonrider' for additional commands"
	L["Score"] = "Score"
	L["Guide"] = "Guide"
	L["Settings"] = "Settings"
	L["ComingSoon"] = "Coming Soon"
	L["UseAccountScores"] = "Use Account Scores"
	L["UseAccountScoresTT"] = "This will display your top account race scores instead of your character's scores. Account scores are indicated with an asterisk (*)."
	L["PersonalBest"] = "Personal Best: "
	L["AccountBest"] = "Account Best: "
	L["BestCharacter"] = "Best Character: "
	L["GoldTime"] = "Gold Time: "
	L["SilverTime"] = "Silver Time: "
	--L["SetMapPin_TT"] = "Click to set Map Pin"
	L["MuteVigorSound_Settings"] = "Mute Vigor Sound"
	L["MuteVigorSound_SettingsTT"] = "Toggle the sound that plays when the skyriding mount naturally gains a stack of vigor."
	L["SpeedometerTheme"] = "Speedometer Theme"
	L["SpeedometerThemeTT"] = "Customize the Speedometer theme."
	L["Algari"] = "Algari"
	L["Default"] = DEFAULT
	L["Minimalist"] = "Minimalist"
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	L["TimerunningStatistics"] = "Timerunning Statistics"
	L["SkyridingCurrencyGained"] = "Skyriding %s Gained:"

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "Show Speedometer"
	L["ToggleSpeedometerTT"] = "Toggle the Speedometer display."
	L["SpeedometerWidthName"] = "Speedometer Width" 
	L["SpeedometerWidthTT"] = "Adjust the width of the Speedometer frame."
	L["SpeedometerHeightName"] = "Speedometer Height"
	L["SpeedometerHeightTT"] = "Adjust the height of the Speedometer frame."
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "Requires closing the settings and landing for this to take effect.\n\nIncompatible with the \"Motion Sickness\" setting."
	L["DynamicFOVNewTT"] = "Enables adjustment of camera field of view based on gliding and D.R.I.V.E. speed."
	L["StaticChargeOffset"] = "Static Charge Offset"
	L["StaticChargeSpacing"] = "Static Charge Spacing"
	L["StaticChargeWidth"] = "Static Charge Width"
	L["StaticChargeHeight"] = "Static Charge Height"
	L["StaticChargeWidthTT"] = "Adjust the width of Static Charges."
	L["StaticChargeHeightTT"] = "Adjust the height of Static Charges."
	L["StaticChargeSpacingTT"] = "Adjust the spacing of Static Charges."
	L["StaticChargeOffsetTT"] = "Adjust the offset of Static Charges."
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors - replacing previous color picker text
	L["SpeedometerBar_Slow_ColorPicker"] = "Speedometer Low Speed Color"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "Pick a color for speeds displayed on the Speedometer bar when slow."
	L["SpeedometerBar_Recharge_ColorPicker"] = "Speedometer Recharge Speed Color"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "Pick a color for speeds displayed on the Speedometer bar when Skyriding Charges recover at an accelerated rate (indicated by the Thrill of the Skies buff)."
	L["SpeedometerBar_Over_ColorPicker"] = "Speedometer Over Speed Color"
	L["SpeedometerBar_Over_ColorPickerTT"] = "Pick a color for speeds displayed on the Speedometer bar when above the maximum natural gliding speed (indicated by the 2nd tick at 65%)."
	L["SpeedometerText_Slow_ColorPicker"] = "Speedometer Text Low Speed Color"
	L["SpeedometerText_Slow_ColorPickerTT"] = "Pick a color for speeds displayed by the Speedometer text when slow."
	L["SpeedometerText_Recharge_ColorPicker"] = "Speedometer Text Recharge Speed Color"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "Pick a color for speeds displayed by the Speedometer text when Skyriding Charges recover at an accelerated rate (indicated by the Thrill of the Skies buff)."
	L["SpeedometerText_Over_ColorPicker"] = "Speedometer Text Over Speed Color"
	L["SpeedometerText_Over_ColorPickerTT"] = "Pick a color for speeds displayed by the Speedometer text when above the maximum natural gliding speed (indicated by the 2nd tick at 65%)."
	L["SpeedometerCover_ColorPicker"] = "Speedometer Cover Color"
	L["SpeedometerCover_ColorPickerTT"] = "Pick a color for the Speedometer Cover."
	L["SpeedometerTick_ColorPicker"] = "Speedometer Tick Color"
	L["SpeedometerTick_ColorPickerTT"] = "Pick a color for the Speedometer Ticks. These are the two lines at 60% and 65% speed."
	L["SpeedometerTopper_ColorPicker"] = "Speedometer Top Color"
	L["SpeedometerTopper_ColorPickerTT"] = "Pick a color for the Speedometer Top texture."
	L["SpeedometerFooter_ColorPicker"] = "Speedometer Bottom Color"
	L["SpeedometerFooter_ColorPickerTT"] = "Pick a color for the Speedometer Bottom texture."
	L["SpeedometerBackground_ColorPicker"] = "Speedometer Background Color"
	L["SpeedometerBackground_ColorPickerTT"] = "Pick a color for the Speedometer Background."
	L["SpeedometerSpark_ColorPicker"] = "Speedometer Spark Color" -- NYI
	L["SpeedometerSpark_ColorPickerTT"] = "Pick a color for the Speedometer Spark. This is the texture at the very edge of the current progress bar value." -- NYI

	-- New Vigor Bar Settings
	L["VigorTheme"] = "Vigor Theme"
	L["VigorThemeTT"] = "Customize the Vigor bar theme."
	L["VigorPosXName"] = "Vigor Horizontal Position" -- NYI
	L["VigorPosXNameTT"] = "Adjust the horizontal position of the Vigor bars." -- NYI
	L["VigorPosYName"] = "Vigor Vertical Position"
	L["VigorPosYNameTT"] = "Adjust the vertical position of the Vigor bar relative to the default UI."
	L["VigorBarWidthName"] = "Vigor Charge Width"
	L["VigorBarWidthNameTT"] = "Adjust the width of each Vigor charge."
	L["VigorBarHeightName"] = "Vigor Charge Height"
	L["VigorBarHeightNameTT"] = "Adjust the height of each Vigor charge."
	L["VigorBarSpacingName"] = "Vigor Charge Spacing"
	L["VigorBarSpacingNameTT"] = "Adjust the spacing between each Vigor charge."
	L["VigorBarOrientationName"] = "Vigor Charge Orientation"
	L["VigorBarOrientationNameTT"] = "Controls the layout direction of the Vigor bar."
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "Vigor Charge Growth Direction"
	L["VigorBarDirectionNameTT"] = "Controls which way the Vigor charge grows."
	L["Direction_DownRight"] = "Top-to-Bottom / Left-to-Right"
	L["Direction_UpLeft"] = "Bottom-to-Top / Right-to-Left"
	L["VigorWrapName"] = "Vigor Charge Limit"
	L["VigorWrapNameTT"] = "Set how many charges appear before wrapping to a new row or column."
	L["VigorBarFillDirectionName"] = "Vigor Charge Fill Direction"
	L["VigorBarFillDirectionNameTT"] = "Controls the direction individual charges fill up."
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "Fill Spark Thickness" -- NYI
	L["VigorSparkThicknessNameTT"] = "Adjust the width of the recharging spark effect." -- NYI
	L["ToggleFlashFullName"] = "Flash on Full"
	L["ToggleFlashFullNameTT"] = "Toggle the flash animation when a charge becomes full."
	L["ToggleFlashProgressName"] = "Flash on Progress"
	L["ToggleFlashProgressNameTT"] = "Toggle the pulsing animation when a charge is recharging."
	L["ModelThemeName"] = "Vigor Model Theme"
	L["ModelThemeNameTT"] = "Changes the visual effect for the Vigor models."
	L["SideArtStyleName"] = "Side Art Theme"
	L["SideArtStyleNameTT"] = "Changes the theme of the side art."
	L["SideArtPosX"] = "Side Art Horizontal Position"
	L["SideArtPosXTT"] = "Adjust the horizontal position of the side art."
	L["SideArtPosY"] = "Side Art Vertical Position"
	L["SideArtPosYTT"] = "Adjust the vertical position of the side art."
	L["SideArtRot"] = "Side Art Rotation"
	L["SideArtRotTT"] = "Adjust the rotation of the Side Art textures."
	L["SideArtScale"] = "Side Art Scale"
	L["SideArtScaleTT"] = "Adjust the size of the Side Art textures."
	L["DesaturatedOptionTT"] = "Some options are desaturated, allowing them to be colored better by the color picker options. Options which are not desaturated are best viewed with the color picker set to white (#FFFFFF)."
	
	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "Vigor Full Color"
	L["VigorBar_Full_ColorPickerTT"] = "Pick a color for the Skyriding Charge when full."
	L["VigorBar_Empty_ColorPicker"] = "Vigor Empty Color"
	L["VigorBar_Empty_ColorPickerTT"] = "Pick a color for the Skyriding Charge when empty."
	L["VigorBar_Progress_ColorPicker"] = "Vigor Recharge Color"
	L["VigorBar_Progress_ColorPickerTT"] = "Pick a color for when the Skyriding Charge is recovering."
	L["VigorBarCover_ColorPicker"] = "Vigor Cover Color"
	L["VigorBarCover_ColorPickerTT"] = "Pick a color for Skyriding Charge Cover."
	L["VigorBarBackground_ColorPicker"] = "Vigor Background Color"
	L["VigorBarBackground_ColorPickerTT"] = "Pick a color for the Skyriding Charge Background."
	L["VigorBarSpark_ColorPicker"] = "Vigor Spark Color"
	L["VigorBarSpark_ColorPickerTT"] = "Pick a color for the Skyriding Charge spark. This is the texture at the very edge of the current progress bar value."
	L["VigorBarFlash_ColorPicker"] = "Vigor Flash Color"
	L["VigorBarFlash_ColorPickerTT"] = "Pick a color for Skyriding Charge flash upon reaching full or while recharging."
	L["VigorBarDecor_ColorPicker"] = "Vigor Side Art Color"
	L["VigorBarDecor_ColorPickerTT"] = "Pick a color for Side Art on the Vigor Bar."

	-- Additional Toggles
	L["ToggleTopper"] = "Show Speedometer Top"
	L["ToggleTopperTT"] = "Toggle the Speedometer Top texture."
	L["ToggleFooter"] = "Show Speedometer Bottom"
	L["ToggleFooterTT"] = "Toggle the Speedometer Bottom texture."
	L["ToggleVigor"] = "Show Vigor Bars"
	L["ToggleVigorTT"] = "Toggle the 6 Vigor bars associated with the spell charges for Surge Forward and Skyward Ascent."
	
	-- Themes
	L["ThemeAlgari_Gold"] = "Algari - Gold"
	L["ThemeAlgari_Bronze"] = "Algari - Bronze"
	L["ThemeAlgari_Dark"] = "Algari - Dark"
	L["ThemeAlgari_Silver"] = "Algari - Silver"
	L["ThemeDefault_Desaturated"] = "Default - Desaturated"
	L["ThemeAlgari_Desaturated"] = "Algari - Desaturated"
	L["ThemeGryphon_Desaturated"] = "Gryphon - Desaturated"
	L["ThemeWyvern_Desaturated"] = "Wyvern - Desaturated"
	L["ThemeDragon_Desaturated"] = "Dragon - Desaturated"
	
	-- Model Themes
	L["ModelTheme_Wind"] = "Wind"
	L["ModelTheme_Lightning"] = "Lightning"
	L["ModelTheme_FireForm"] = "Fire Form"
	L["ModelTheme_ArcaneForm"] = "Arcane Form"
	L["ModelTheme_FrostForm"] = "Frost Form"
	L["ModelTheme_HolyForm"] = "Holy Form"
	L["ModelTheme_NatureForm"] = "Nature Form"
	L["ModelTheme_ShadowForm"] = "Shadow Form"

	-- TOC translations
	L["DR_Title"] = "Dragon Rider"
	L["DR_Notes"] = "Displays a speedometer paired with the vigor bar and some other dragonriding-related options."


return end

if LOCALE == "esES" or LOCALE == "esMX" then
	-- Spanish translations go here
	L["Vigor"] = "Vigor"
	L["Speedometer"] = "Velocímetro"
	L["ToggleModelsName"] = "Mostrar modelos de vigor"
	L["ToggleModelsTT"] = "Muestre el efecto del modelo de remolino en las burbujas de vigor."
	L["SpeedPosPointName"] = "Posición del velocímetro"
	L["SpeedPosPointTT"] = "Ajusta dónde está anclado el velocímetro en relación con la barra de vigor."
	L["Top"] = "Arriba"
	L["Bottom"] = "Abajo"
	L["Left"] = "Izquierda"
	L["Right"] = "Bien"
	L["SpeedPosXName"] = "Posición horizontal del velocímetro"
	L["SpeedPosXTT"] = "Ajuste la posición horizontal del velocímetro."
	L["SpeedPosYName"] = "Posición vertical del velocímetro"
	L["SpeedPosYTT"] = "Ajuste la posición vertical del velocímetro."
	L["SpeedScaleName"] = "Escala del velocímetro"
	L["SpeedScaleTT"] = "Ajuste la escala del velocímetro."
	L["Large"] = "Grande"
	L["Small"] = "Pequeño"
	L["Units"] = "Texto de unidades del velocímetro"
	L["UnitsTT"] = "Cambie las unidades que se muestran en el velocímetro.\n(Mecánicamente 1 metro = 1 yarda)"
	L["UnitsColor"] = "Color del texto de unidades del velocímetro"
	L["UnitYards"] = "yds/s"
	L["Yards"] = "Yardas"
	L["UnitMiles"] = "mph"
	L["Miles"] = "Millas"
	L["UnitMeters"] = "m/s"
	L["Meters"] = "Metros"
	L["UnitKilometers"] = "k/h"
	L["Kilometers"] = "Kilómetros"
	L["UnitPercent"] = "%"
	L["Percent"] = "Porcentaje"
	L["SpeedTextScale"] = "Tamaño del texto del velocímetro"
	L["SpeedTextScaleTT"] = "Ajusta el tamaño del texto en el velocímetro."
	L["Version"] = "Versión %s"
	L["ResetAllSettings"] = "Restablecer todas las configuraciones de Dragon Rider"
	L["ResetAllSettingsTT"] = "Restablece todas las configuraciones específicamente para este complemento. Esto incluirá los valores de color personalizados."
	L["ResetAllSettingsConfirm"] = "¿Está seguro de que desea restablecer la configuración de Dragon Rider?"
	L["Low"] = "Bajo"
	L["High"] = "Alto"
	L["ProgressBar"] = "Velocímetro" -- Deprecated
	L["ProgressBarColor"] = "Color del velocímetro" -- Deprecated
	L["ColorPickerLowProgTT"] = "Elija un color personalizado para los valores de baja velocidad del velocímetro. Esto ocurre cuando el jugador no gana vigor." -- Deprecated
	L["ColorPickerMidProgTT"] = "Elija un color personalizado para los valores de velocidad de vigor del velocímetro. Esto ocurre cuando el jugador gana vigor dentro de un rango de velocidad estándar." -- Deprecated
	L["ColorPickerHighProgTT"] = "Elija un color personalizado para los valores de alta velocidad del velocímetro. Esto ocurre cuando el jugador está ganando vigor, pero está por encima del rango de velocidad estándar." -- Deprecated
	L["ColorPickerLowTextTT"] = "Elija un color personalizado para los valores de baja velocidad del valor de velocidad. Esto ocurre cuando el jugador no gana vigor." -- Deprecated
	L["ColorPickerMidTextTT"] = "Elija un color personalizado para los valores de velocidad de vigor del valor de velocidad. Esto ocurre cuando el jugador gana vigor dentro de un rango de velocidad estándar." -- Deprecated
	L["ColorPickerHighTextTT"] = "Elija un color personalizado para los valores de alta velocidad del valor de velocidad. Esto ocurre cuando el jugador está ganando vigor, pero está por encima del rango de velocidad estándar." -- Deprecated
	L["DragonridingTalents"] = "Habilidades y desbloqueos de Surcacielos"
	L["OpenDragonridingTalents"] = "Habilidades y desbloqueos de Surcacielos"
	L["OpenDragonridingTalentsTT"] = "Abrir habilidades y desbloqueos de Surcacielos."
	L["SideArtName"] = "Arte Lateral"
	L["SideArtTT"] = "Alterna el arte en los lados de la barra principal de Vigor."
	L["BugfixesName"] = "Corrección de errores"
	L["BugfixesTT"] = "Intentos experimentales de corrección de errores cuando los marcos predeterminados de Blizzard no funcionan según lo previsto."
	L["BugfixHideVigor"] = "Fuerza Ocultar Vigor"
	L["BugfixHideVigorTT"] = "Fuerce la ocultación de la barra de vigor cuando esté desmontado y vuelva a mostrarla cuando esté montado en una montura surcacielos."
	L["FadeSpeedometer"] = "Velocímetro de desvanecimiento"
	L["FadeSpeedometerTT"] = "Alternar la atenuación del velocímetro cuando no se está planeando."
	L["ShowVigorTooltip"] = "Mostrar información sobre herramientas de vigor"
	L["ShowVigorTooltipTT"] = "Alternar la información sobre herramientas que se muestra en la barra de Vigor."
	L["FadeVigor"] = "Desvanecer vigor"
	L["FadeVigorTT"] = "Alternar el desvanecimiento de la barra de Vigor cuando no estás deslizándote y cuando tienes el Vigor máximo."
	L["LightningRush"] = "Mostrar orbes de Carga estática"  -- Changed in 11.2.7
	L["LightningRushTT"] = "Alterna los orbes de Carga estática que se utilizan con la habilidad Descarga Relámpago." -- Changed in 11.2.7
	L["DynamicFOV"] = "Campo de visión dinámico"
	L["DynamicFOVTT"] = "Permite ajustar el campo de visión de la cámara según la velocidad de deslizamiento."
	L["Normal"] = "Normal"
	L["Advanced"] = "Avanzada"
	L["Reverse"] = "Inversa"
	L["Challenge"] = "Desafío"
	L["ReverseChallenge"] = "Desafío Inverso"
	L["Storm"] = "Tormenta"
	L["COMMAND_help"] = "ayuda"
	L["COMMAND_journal"] = "diario"
	L["COMMAND_listcommands"] = "Una lista de comandos:"
	L["COMMAND_dragonrider"] = "dragonrider"
	L["DragonRider"] = "Jinete de Dragones"
	L["RightClick_TT_Line"] = "Clic derecho: Abrir Configuración"
	L["LeftClick_TT_Line"] = "Clic izquierdo: Abrir Diario"
	L["SlashCommands_TT_Line"] = "'/dragonrider' para comandos adicionales"
	L["Score"] = "Puntuación"
	L["Guide"] = "Guía"
	L["Settings"] = "Configuración"
	L["ComingSoon"] = "Próximamente"
	L["UseAccountScores"] = "Usar Puntuaciones de la Cuenta"
	L["UseAccountScoresTT"] = "Esto mostrará los puntajes de carrera principales de tu cuenta en lugar de los puntajes de tu personaje. Los puntajes de la cuenta se indican con un asterisco (*)."
	L["PersonalBest"] = "Mejor Personal: "
	L["AccountBest"] = "Mejor de la Cuenta: "
	L["BestCharacter"] = "Mejor Personaje: "
	L["GoldTime"] = "Tiempo Oro: "
	L["SilverTime"] = "Tiempo Plata: "
	L["MuteVigorSound_Settings"] = "Silenciar sonido de Vigor"
	L["MuteVigorSound_SettingsTT"] = "Alternar el sonido que se reproduce cuando la montura de Surcacielos obtiene una acumulación de vigor."
	L["SpeedometerTheme"] = "Tema del velocímetro"
	L["SpeedometerThemeTT"] = "Personaliza el tema del velocímetro."
	L["Algari"] = "Algari"
	L["Default"] = DEFAULT
	L["Minimalist"] = "Minimalista"
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	L["TimerunningStatistics"] = "Estadísticas de Cronoviaje"
	L["SkyridingCurrencyGained"] = "%s de Monta en Cielo Ganado:"

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "Mostrar velocímetro"
	L["ToggleSpeedometerTT"] = "Activa o desactiva la visualización del velocímetro."
	L["SpeedometerWidthName"] = "Anchura del velocímetro"
	L["SpeedometerWidthTT"] = "Ajusta la anchura del marco del velocímetro."
	L["SpeedometerHeightName"] = "Altura del velocímetro"
	L["SpeedometerHeightTT"] = "Ajusta la altura del marco del velocímetro."
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "Requiere cerrar la configuración y aterrizar para que surta efecto.\n\nIncompatible con el ajuste de \"Cinetosis\" / \"Mareo\"."
	L["DynamicFOVNewTT"] = "Activa el ajuste del campo de visión de la cámara según el planeo y la velocidad de M.O.T.O.R. / C.A.R.R.O."
	L["StaticChargeOffset"] = "Desplazamiento de Carga estática"
	L["StaticChargeSpacing"] = "Espaciado de Carga estática"
	L["StaticChargeSize"] = "Tamaño de Carga estática"
	L["StaticChargeWidth"] = "Ancho de Carga estática"
	L["StaticChargeHeight"] = "Alto de Carga estática"
	L["StaticChargeWidthTT"] = "Ajusta el ancho de las Cargas estáticas."
	L["StaticChargeHeightTT"] = "Ajusta el alto de las Cargas estáticas."
	L["StaticChargeSpacingTT"] = "Ajusta el espaciado de las Cargas estáticas."
	L["StaticChargeOffsetTT"] = "Ajusta el desplazamiento de las Cargas estáticas."
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors
	L["SpeedometerBar_Slow_ColorPicker"] = "Color de velocidad baja del velocímetro"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "Elige un color para las velocidades bajas en la barra del velocímetro."
	L["SpeedometerBar_Recharge_ColorPicker"] = "Color de velocidad de recarga del velocímetro"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "Elige un color para cuando las Cargas de Surcacielos se recuperan a mayor velocidad (buf Éxtasis de los Cielos)."
	L["SpeedometerBar_Over_ColorPicker"] = "Color de velocidad excedida del velocímetro"
	L["SpeedometerBar_Over_ColorPickerTT"] = "Elige un color para velocidades por encima del máximo natural (segunda marca al 65%)."
	L["SpeedometerText_Slow_ColorPicker"] = "Color del texto del velocímetro (velocidad baja)"
	L["SpeedometerText_Slow_ColorPickerTT"] = "Elige un color para las velocidades bajas del texto del velocímetro."
	L["SpeedometerText_Recharge_ColorPicker"] = "Color del texto del velocímetro (recarga)"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "Elige un color para cuando las Cargas se recuperan a mayor velocidad."
	L["SpeedometerText_Over_ColorPicker"] = "Color del texto del velocímetro (velocidad excedida)"
	L["SpeedometerText_Over_ColorPickerTT"] = "Elige un color para velocidades por encima del máximo natural."
	L["SpeedometerCover_ColorPicker"] = "Color de la cubierta del velocímetro"
	L["SpeedometerCover_ColorPickerTT"] = "Elige un color para la cubierta del velocímetro."
	L["SpeedometerTick_ColorPicker"] = "Color de las marcas del velocímetro"
	L["SpeedometerTick_ColorPickerTT"] = "Elige un color para las dos marcas del 60% y 65%."
	L["SpeedometerTopper_ColorPicker"] = "Color de la parte superior del velocímetro"
	L["SpeedometerTopper_ColorPickerTT"] = "Elige un color para la textura superior."
	L["SpeedometerFooter_ColorPicker"] = "Color de la parte inferior del velocímetro"
	L["SpeedometerFooter_ColorPickerTT"] = "Elige un color para la textura inferior."
	L["SpeedometerBackground_ColorPicker"] = "Color de fondo del velocímetro"
	L["SpeedometerBackground_ColorPickerTT"] = "Elige un color para el fondo del velocímetro."
	L["SpeedometerSpark_ColorPicker"] = "Color del destello del velocímetro"
	L["SpeedometerSpark_ColorPickerTT"] = "Elige un color para el destello del borde de progreso."

	-- Vigor Bar Settings
	L["VigorTheme"] = "Tema de Vigor"
	L["VigorThemeTT"] = "Personaliza el tema de la barra de Vigor."
	L["VigorPosXName"] = "Posición horizontal de Vigor"
	L["VigorPosXNameTT"] = "Ajusta la posición horizontal de las barras de Vigor."
	L["VigorPosYName"] = "Posición vertical de Vigor"
	L["VigorPosYNameTT"] = "Ajusta la posición vertical de la barra de Vigor."
	L["VigorBarWidthName"] = "Anchura de carga de Vigor"
	L["VigorBarWidthNameTT"] = "Ajusta la anchura de cada carga."
	L["VigorBarHeightName"] = "Altura de carga de Vigor"
	L["VigorBarHeightNameTT"] = "Ajusta la altura de cada carga."
	L["VigorBarSpacingName"] = "Espaciado de cargas de Vigor"
	L["VigorBarSpacingNameTT"] = "Ajusta el espacio entre cargas."
	L["VigorBarOrientationName"] = "Orientación de Vigor"
	L["VigorBarOrientationNameTT"] = "Controla la dirección general del diseño."
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "Dirección de crecimiento"
	L["VigorBarDirectionNameTT"] = "Controla hacia dónde crecen las cargas."
	L["Direction_DownRight"] = "De Arriba a Abajo / De Izquierda a Derecha"
	L["Direction_UpLeft"] = "De Abajo a Arriba / De Derecha a Izquierda"
	L["VigorWrapName"] = "Límite de cargas por fila/columna"
	L["VigorWrapNameTT"] = "Define cuántas cargas aparecen antes de una nueva fila/columna."
	L["VigorBarFillDirectionName"] = "Dirección de relleno"
	L["VigorBarFillDirectionNameTT"] = "Controla hacia dónde se rellena cada carga."
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "Grosor del destello"
	L["VigorSparkThicknessNameTT"] = "Ajusta el grosor del destello de recarga."
	L["ToggleFlashFullName"] = "Destello al llenarse"
	L["ToggleFlashFullNameTT"] = "Activa el destello cuando una carga se llena."
	L["ToggleFlashProgressName"] = "Destello al recargar"
	L["ToggleFlashProgressNameTT"] = "Activa el pulso durante la recarga."
	L["ModelThemeName"] = "Tema de modelo de Vigor"
	L["ModelThemeNameTT"] = "Cambia el efecto visual del modelo de Vigor."
	L["SideArtStyleName"] = "Tema del arte lateral"
	L["SideArtStyleNameTT"] = "Cambia el estilo del arte lateral."
	L["SideArtPosX"] = "Posición horizontal del arte lateral"
	L["SideArtPosXTT"] = "Ajusta la posición horizontal del arte lateral."
	L["SideArtPosY"] = "Posición vertical del arte lateral"
	L["SideArtPosYTT"] = "Ajusta la posición vertical del arte lateral."
	L["SideArtRot"] = "Rotación del arte lateral"
	L["SideArtRotTT"] = "Ajusta la rotación del arte lateral."
	L["SideArtScale"] = "Escala del arte lateral"
	L["SideArtScaleTT"] = "Ajusta el tamaño del arte lateral."
	L["DesaturatedOptionTT"] = "Algunas opciones están desaturadas, lo que permite que el selector de color las coloree mejor. Las opciones que no están desaturadas se ven mejor con el selector de color establecido en blanco (#FFFFFF)."

	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "Color de Vigor lleno"
	L["VigorBar_Full_ColorPickerTT"] = "Elige un color para una carga llena."
	L["VigorBar_Empty_ColorPicker"] = "Color de Vigor vacío"
	L["VigorBar_Empty_ColorPickerTT"] = "Elige un color para una carga vacía."
	L["VigorBar_Progress_ColorPicker"] = "Color de recarga de Vigor"
	L["VigorBar_Progress_ColorPickerTT"] = "Elige un color para la recarga."
	L["VigorBarCover_ColorPicker"] = "Color de la cubierta de Vigor"
	L["VigorBarCover_ColorPickerTT"] = "Elige un color para la cubierta."
	L["VigorBarBackground_ColorPicker"] = "Color de fondo de Vigor"
	L["VigorBarBackground_ColorPickerTT"] = "Elige un color para el fondo."
	L["VigorBarSpark_ColorPicker"] = "Color del destello de Vigor"
	L["VigorBarSpark_ColorPickerTT"] = "Color del destello del borde de progreso."
	L["VigorBarFlash_ColorPicker"] = "Color del destello de Vigor"
	L["VigorBarFlash_ColorPickerTT"] = "Color del destello al llenarse o recargar."
	L["VigorBarDecor_ColorPicker"] = "Color del arte lateral de Vigor"
	L["VigorBarDecor_ColorPickerTT"] = "Elige un color para el arte lateral."

	-- Additional Toggles
	L["ToggleTopper"] = "Mostrar parte superior"
	L["ToggleTopperTT"] = "Activa la textura superior del velocímetro."
	L["ToggleFooter"] = "Mostrar parte inferior"
	L["ToggleFooterTT"] = "Activa la textura inferior del velocímetro."
	L["ToggleVigor"] = "Mostrar barras de Vigor"
	L["ToggleVigorTT"] = "Activa las 6 barras de Vigor."

	-- Themes
	L["ThemeAlgari_Gold"] = "Algari - Dorado"
	L["ThemeAlgari_Bronze"] = "Algari - Bronce"
	L["ThemeAlgari_Dark"] = "Algari - Oscuro"
	L["ThemeAlgari_Silver"] = "Algari - Plateado"
	L["ThemeDefault_Desaturated"] = "Predeterminado - Desaturado"
	L["ThemeAlgari_Desaturated"] = "Algari - Desaturado"
	L["ThemeGryphon_Desaturated"] = "Grifo - Desaturado"
	L["ThemeWyvern_Desaturated"] = "Guiverno - Desaturado"
	L["ThemeDragon_Desaturated"] = "Dragón - Desaturado"

	-- Model Themes
	L["ModelTheme_Wind"] = "Viento"
	L["ModelTheme_Lightning"] = "Relámpago"
	L["ModelTheme_FireForm"] = "Forma de Fuego"
	L["ModelTheme_ArcaneForm"] = "Forma Arcana"
	L["ModelTheme_FrostForm"] = "Forma de Escarcha"
	L["ModelTheme_HolyForm"] = "Forma Sagrada"
	L["ModelTheme_NatureForm"] = "Forma de Naturaleza"
	L["ModelTheme_ShadowForm"] = "Forma de Sombras"

	-- TOC translations
	L["DR_Title"] = "Jinete de Dragón"
	L["DR_Notes"] = "Muestra un velocímetro emparejado con la barra de vigor y algunas otras opciones relacionadas con la conducción de dragones."


return end

if LOCALE == "deDE" then
	-- German translations go here
	L["Vigor"] = "Elan"
	L["Speedometer"] = "Tacho"
	L["ToggleModelsName"] = "Elan-Effekt anzeigen"
	L["ToggleModelsTT"] = "Zeigt den wirbelnden Modelleffekt auf den Elanblasen an."
	L["SpeedPosPointName"] = "Tacho-Position"
	L["SpeedPosPointTT"] = "Passt an, wo der Tacho relativ zur Elananzeige verankert sein soll."
	L["Top"] = "Oben"
	L["Bottom"] = "Unten"
	L["Left"] = "Links"
	L["Right"] = "Rechts"
	L["SpeedPosXName"] = "Horizontale Position des Tachos"
	L["SpeedPosXTT"] = "Passt die horizontale Position des Tachos an."
	L["SpeedPosYName"] = "Vertikale Position des Tachos"
	L["SpeedPosYTT"] = "Passt Sie die vertikale Position des Tachos an."
	L["SpeedScaleName"] = "Tacho-Skalierung"
	L["SpeedScaleTT"] = "Passt die Skalierung des Tachos an."
	L["Large"] = "Groß"
	L["Small"] = "Klein"
	L["Units"] = "Text der Geschwindigkeitsanzeige-Einheiten" -- Changed in 11.2.7
	L["UnitsTT"] = "Ändert die auf dem Tacho angezeigte Einheit.\n(Mechanisch 1 Meter = 1 Yard)"
	L["UnitsColor"] = "Farbe des Einheiten-Textes der Geschwindigkeitsanzeige" -- Changed in 11.2.7
	L["UnitYards"] = "yds/s"
	L["Yards"] = "Yards"
	L["UnitMiles"] = "mph"
	L["Miles"] = "Meilen"
	L["UnitMeters"] = "m/s"
	L["Meters"] = "Meter"
	L["UnitKilometers"] = "km/h"
	L["Kilometers"] = "Kilometer"
	L["UnitPercent"] = "%"
	L["Percent"] = "Prozentsatz"
	L["SpeedTextScale"] = "Textgröße des Tachos"
	L["SpeedTextScaleTT"] = "Passt die Größe des Textes auf dem Tacho an."
	L["Version"] = "Version %s"
	L["ResetAllSettings"] = "Setzt alle Dragon Rider-Einstellungen zurück"
	L["ResetAllSettingsTT"] = "Setzt alle Einstellungen speziell für dieses Add-on zurück. Dies schließt die benutzerdefinierten Farbwerte ein."
	L["ResetAllSettingsConfirm"] = "Sind Sie sicher, dass Sie die Einstellungen für Dragon Rider zurücksetzen möchten?"
	L["Low"] = "Niedrig"
	L["High"] = "Hoch"
	L["ProgressBar"] = "Tacho" -- Deprecated
	L["ProgressBarColor"] = "Tacho-Farbe" -- Deprecated
	L["ColorPickerLowProgTT"] = "Wählen Sie eine benutzerdefinierte Farbe für die niedrigen Geschwindigkeitsbereich des Tachos. Diese wird dargestellt, wenn der Spieler keinen Elan generiert." -- Deprecated
	L["ColorPickerMidProgTT"] = "Wählen Sie eine benutzerdefinierte Farbe für den normalen Geschwindigkeitsbereich des Tachos. Diese wird dargestellt, wenn der Spieler Elan generiert." -- Deprecated
	L["ColorPickerHighProgTT"] = "Wählen Sie eine individuelle Farbe für den hohen Geschwindigkeitsbereich des Tachos. Diese wird dargestellt, wenn der Spieler Elan generiert, als auch sich mit einer Geschwindigkeit über dem normalen Geschwindigkeitsbereich fortbewegt." -- Deprecated
	L["ColorPickerLowTextTT"] = "Wählen Sie eine benutzerdefinierte Text-Farbe für die niedrigen Geschwindigkeitsbereich des Tacho. Diese wird dargestellt, wenn der Spieler keinen Elan generiert." -- Deprecated
	L["ColorPickerMidTextTT"] = "Wählen Sie eine benutzerdefinierte Text-Farbe für den normalen Geschwindigkeitsbereich des Tachos. Diese wird dargestellt, wenn der Spieler Elan generiert." -- Deprecated
	L["ColorPickerHighTextTT"] = "Wählen Sie eine benutzerdefinierte Text-Farbe für die hohen Geschwindigkeitsbereich des Tachos. Diese wird dargestellt, wenn der Spieler Elan generiert, als auch sich mit einer Geschwindigkeit über dem normalen Geschwindigkeitsbereich fortbewegt." -- Deprecated
	L["DragonridingTalents"] = "Himmelsreiten - Fertigkeiten und Freischaltungen" -- Changed in 11.2.7
	L["OpenDragonridingTalents"] = "Himmelsreiten - Fertigkeiten und Freischaltungen" -- Changed in 11.2.7
	L["OpenDragonridingTalentsTT"] = "Öffnet die Fertigkeiten und Freischaltungen für das Himmelsreiten." -- Changed in 11.2.7
	L["SideArtName"] = "Seitenkunst"
	L["SideArtTT"] = "Zeigt die Seitenkunst der Elan-Leiste an."
	L["BugfixesName"] = "Fehlerbehebung"
	L["BugfixesTT"] = "Experimentelle Fehlerbehebungsversuche für den Fall, dass Standard-Blizzard-Frames nicht wie vorgesehen funktionieren."
	L["BugfixHideVigor"] = "Force Hide Vigor"
	L["BugfixHideVigorTT"] = "Erzwingen Sie das Ausblenden der Energieleiste beim Absteigen und das erneute Einblenden, wenn Sie auf einem dynamischen Flugreittier montiert sind."
	L["FadeSpeedometer"] = "Tacho ausblenden"
	L["FadeSpeedometerTT"] = "Blendet den Tacho aus, wenn Ihr euch auf dem Boden befindet."
	L["ShowVigorTooltip"] = "Elan-Tooltip anzeigen"
	L["ShowVigorTooltipTT"] = "Zeigt den Tooltip der Elan-Leiste an."
	L["FadeVigor"] = "Elan ausblenden"
	L["FadeVigorTT"] = "Blendet die Elan-Leiste aus, wenn Ihr euch auf dem Boden befindet und bei vollem Elan seid."
	L["LightningRush"] = "Statische-Ladung-Kugeln anzeigen" -- Changed in 11.2.7
	L["LightningRushTT"] = "Schaltet die statischen Ladungskugeln um, die für die Fähigkeit Blitzansturm verwendet werden." -- Changed in 11.2.7
	L["DynamicFOV"] = "Dynamisches Sichtfeld"
	L["DynamicFOVTT"] = "Ermöglicht die Anpassung des Kamerasichtfelds basierend auf der Gleitgeschwindigkeit."
	L["Normal"] = "Normal"
	L["Advanced"] = "Fortgeschritten"
	L["Reverse"] = "Umgekehrt"
	L["Challenge"] = "Herausforderung"
	L["ReverseChallenge"] = "Umgekehrte Herausforderung"
	L["Storm"] = "Sturm"
	L["COMMAND_help"] = "hilfe"
	L["COMMAND_journal"] = "tagebuch"
	L["COMMAND_listcommands"] = "Eine Liste der Befehle:"
	L["COMMAND_dragonrider"] = "drachenreiter"
	L["DragonRider"] = "Drachenreiter"
	L["RightClick_TT_Line"] = "Rechtsklick: Einstellungen öffnen"
	L["LeftClick_TT_Line"] = "Linksklick: Tagebuch öffnen"
	L["SlashCommands_TT_Line"] = "'/drachenreiter' für weitere Befehle"
	L["Score"] = "Punktzahl"
	L["Guide"] = "Anleitung"
	L["Settings"] = "Einstellungen"
	L["ComingSoon"] = "Demnächst"
	L["UseAccountScores"] = "Benutze Account-Wertungen"
	L["UseAccountScoresTT"] = "Dies zeigt deine besten Rennpunkte für das Konto an, anstelle der Punkte deines Charakters. Punkte des Kontos werden mit einem Stern (*) markiert."
	L["PersonalBest"] = "Persönlicher Rekord: "
	L["AccountBest"] = "Account-Bester: "
	L["BestCharacter"] = "Bester Charakter: "
	L["GoldTime"] = "Goldzeit: "
	L["SilverTime"] = "Silberzeit: "
	L["MuteVigorSound_Settings"] = "Elan-Ton stummschalten"
	L["MuteVigorSound_SettingsTT"] = "Schaltet den Ton stumm, der abgespielt wird, wenn das Himmelsreittier einen Stapel an Elan erhält."
	L["SpeedometerTheme"] = "Tacho-Design"
	L["SpeedometerThemeTT"] = "Passt das Design des Tachos an."
	L["Algari"] = "Algari"
	L["Default"] = DEFAULT
	L["Minimalist"] = "Minimalistisch"
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	-- Above officially translated by Cirez
	L["TimerunningStatistics"] = "Zeitwanderungsstatistik"
	L["SkyridingCurrencyGained"] = "Himmelsreiten %s Erhalten:"

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "Geschwindigkeitsanzeige anzeigen"
	L["ToggleSpeedometerTT"] = "Aktiviert oder deaktiviert die Geschwindigkeitsanzeige."
	L["SpeedometerWidthName"] = "Breite der Geschwindigkeitsanzeige"
	L["SpeedometerWidthTT"] = "Passt die Breite des Rahmens der Geschwindigkeitsanzeige an."
	L["SpeedometerHeightName"] = "Höhe der Geschwindigkeitsanzeige"
	L["SpeedometerHeightTT"] = "Passt die Höhe des Rahmens der Geschwindigkeitsanzeige an."
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "Erfordert das Schließen der Einstellungen und eine Landung, damit dies wirksam wird.\n\nNicht kompatibel mit der Einstellung „Bewegungskrankheit“."
	L["DynamicFOVNewTT"] = "Aktiviert die Anpassung des Kamerasichtfelds basierend auf Gleiten und F.A.H.R.E.N.-Geschwindigkeit."
	L["StaticChargeOffset"] = "Versatz der Statischen Aufladung"
	L["StaticChargeSpacing"] = "Abstand der Statischen Aufladung"
	L["StaticChargeSize"] = "Größe der Statischen Aufladung"
	L["StaticChargeWidth"] = "Breite der Statischen Aufladung"
	L["StaticChargeHeight"] = "Höhe der Statischen Aufladung"
	L["StaticChargeWidthTT"] = "Passt die Breite der Statischen Aufladungen an."
	L["StaticChargeHeightTT"] = "Passt die Höhe der Statischen Aufladungen an."
	L["StaticChargeSpacingTT"] = "Passt den Abstand der Statischen Aufladungen an."
	L["StaticChargeOffsetTT"] = "Passt den Versatz der Statischen Aufladungen an."
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors
	L["SpeedometerBar_Slow_ColorPicker"] = "Farbe für niedrige Geschwindigkeit"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "Wähle eine Farbe für niedrige Geschwindigkeiten auf der Anzeige."
	L["SpeedometerBar_Recharge_ColorPicker"] = "Farbe für Aufladegeschwindigkeit"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "Wähle eine Farbe für Geschwindigkeiten, bei denen Himmelsreiter-Ladungen schneller regenerieren (Buff: Höhenrausch)."
	L["SpeedometerBar_Over_ColorPicker"] = "Farbe für überschrittene Geschwindigkeit"
	L["SpeedometerBar_Over_ColorPickerTT"] = "Wähle eine Farbe für Geschwindigkeiten über dem natürlichen Maximum (zweiter Strich bei 65%)."
	L["SpeedometerText_Slow_ColorPicker"] = "Textfarbe für niedrige Geschwindigkeit"
	L["SpeedometerText_Slow_ColorPickerTT"] = "Wähle eine Textfarbe für niedrige Geschwindigkeiten."
	L["SpeedometerText_Recharge_ColorPicker"] = "Textfarbe für Aufladegeschwindigkeit"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "Wähle eine Textfarbe für erhöhte Regeneration."
	L["SpeedometerText_Over_ColorPicker"] = "Textfarbe für überschrittene Geschwindigkeit"
	L["SpeedometerText_Over_ColorPickerTT"] = "Wähle eine Textfarbe für Geschwindigkeiten oberhalb des Maximums."
	L["SpeedometerCover_ColorPicker"] = "Abdeckfarbe der Geschwindigkeitsanzeige"
	L["SpeedometerCover_ColorPickerTT"] = "Wähle eine Farbe für die Abdeckung."
	L["SpeedometerTick_ColorPicker"] = "Markierungsfarbe"
	L["SpeedometerTick_ColorPickerTT"] = "Wähle eine Farbe für die beiden Markierungen bei 60 % und 65 %."
	L["SpeedometerTopper_ColorPicker"] = "Farbe der oberen Verzierung"
	L["SpeedometerTopper_ColorPickerTT"] = "Wähle eine Farbe für die obere Verzierung."
	L["SpeedometerFooter_ColorPicker"] = "Farbe der unteren Verzierung"
	L["SpeedometerFooter_ColorPickerTT"] = "Wähle eine Farbe für die untere Verzierung."
	L["SpeedometerBackground_ColorPicker"] = "Hintergrundfarbe"
	L["SpeedometerBackground_ColorPickerTT"] = "Wähle eine Farbe für den Hintergrund."
	L["SpeedometerSpark_ColorPicker"] = "Farbe des Funkens"
	L["SpeedometerSpark_ColorPickerTT"] = "Wähle eine Farbe für den Funken am Rand des Fortschrittsbalkens."

	-- Vigor Bar Settings
	L["VigorTheme"] = "Vigor-Thema"
	L["VigorThemeTT"] = "Passe das Thema der Vigor-Leiste an."
	L["VigorPosXName"] = "Horizontale Position der Vigor-Leiste"
	L["VigorPosXNameTT"] = "Passt die horizontale Position der Vigor-Leisten an."
	L["VigorPosYName"] = "Vertikale Position der Vigor-Leiste"
	L["VigorPosYNameTT"] = "Passt die vertikale Position der Vigor-Leiste an."
	L["VigorBarWidthName"] = "Breite der Vigor-Ladung"
	L["VigorBarWidthNameTT"] = "Passt die Breite jeder Vigor-Ladung an."
	L["VigorBarHeightName"] = "Höhe der Vigor-Ladung"
	L["VigorBarHeightNameTT"] = "Passt die Höhe jeder Vigor-Ladung an."
	L["VigorBarSpacingName"] = "Abstand zwischen Vigor-Ladungen"
	L["VigorBarSpacingNameTT"] = "Passt den Abstand zwischen einzelnen Ladungen an."
	L["VigorBarOrientationName"] = "Ausrichtung der Vigor-Leiste"
	L["VigorBarOrientationNameTT"] = "Legt die allgemeine Ausrichtung der Leiste fest."
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "Wachstumsrichtung"
	L["VigorBarDirectionNameTT"] = "Bestimmt die Wachstumsrichtung der Ladungen."
	L["Direction_DownRight"] = "Oben nach Unten / Links nach Rechts"
	L["Direction_UpLeft"] = "Unten nach Oben / Rechts nach Links"
	L["VigorWrapName"] = "Ladungsbegrenzung"
	L["VigorWrapNameTT"] = "Legt fest, wie viele Ladungen pro Reihe/Spalte angezeigt werden."
	L["VigorBarFillDirectionName"] = "Füllrichtung"
	L["VigorBarFillDirectionNameTT"] = "Bestimmt, in welche Richtung jede Ladung gefüllt wird."
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "Funkenbreite"
	L["VigorSparkThicknessNameTT"] = "Passt die Breite des Funken-Effekts an."
	L["ToggleFlashFullName"] = "Aufblitzen bei voller Ladung"
	L["ToggleFlashFullNameTT"] = "Aktiviert das Aufblitzen, wenn eine Ladung voll ist."
	L["ToggleFlashProgressName"] = "Pulsieren beim Aufladen"
	L["ToggleFlashProgressNameTT"] = "Aktiviert das Pulsieren während des Aufladens."
	L["ModelThemeName"] = "Vigor-Modellthema"
	L["ModelThemeNameTT"] = "Ändert den visuellen Effekt des Vigor-Modells."
	L["SideArtStyleName"] = "Seitenornament-Thema"
	L["SideArtStyleNameTT"] = "Ändert das Thema der Seitenverzierungen."
	L["SideArtPosX"] = "Horizontale Position der Seitenverzierung"
	L["SideArtPosXTT"] = "Passt die horizontale Position an."
	L["SideArtPosY"] = "Vertikale Position der Seitenverzierung"
	L["SideArtPosYTT"] = "Passt die vertikale Position an."
	L["SideArtRot"] = "Rotation der Seitenverzierung"
	L["SideArtRotTT"] = "Passt die Rotation an."
	L["SideArtScale"] = "Skalierung der Seitenverzierung"
	L["SideArtScaleTT"] = "Passt die Größe an."
	L["DesaturatedOptionTT"] = "Einige Optionen sind entsättigt, sodass sie vom Farbwähler besser eingefärbt werden können. Optionen, die nicht entsättigt sind, sehen am besten mit dem Farbwähler auf Weiß (#FFFFFF) aus."

	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "Farbe: volle Vigor-Ladung"
	L["VigorBar_Full_ColorPickerTT"] = "Wähle eine Farbe für eine volle Ladung."
	L["VigorBar_Empty_ColorPicker"] = "Farbe: leere Vigor-Ladung"
	L["VigorBar_Empty_ColorPickerTT"] = "Wähle eine Farbe für eine leere Ladung."
	L["VigorBar_Progress_ColorPicker"] = "Farbe: aufladende Vigor-Ladung"
	L["VigorBar_Progress_ColorPickerTT"] = "Wähle eine Farbe für den Aufladezustand."
	L["VigorBarCover_ColorPicker"] = "Farbe der Abdeckung"
	L["VigorBarCover_ColorPickerTT"] = "Wähle eine Farbe für die Abdeckung."
	L["VigorBarBackground_ColorPicker"] = "Hintergrundfarbe"
	L["VigorBarBackground_ColorPickerTT"] = "Wähle eine Farbe für den Hintergrund."
	L["VigorBarSpark_ColorPicker"] = "Funkenfarbe"
	L["VigorBarSpark_ColorPickerTT"] = "Farbe des Funken-Effekts am Rand."
	L["VigorBarFlash_ColorPicker"] = "Blitzfarbe"
	L["VigorBarFlash_ColorPickerTT"] = "Farbe des Blitzes beim Füllen/Aufladen."
	L["VigorBarDecor_ColorPicker"] = "Farbe der Seitenornamente"
	L["VigorBarDecor_ColorPickerTT"] = "Wähle eine Farbe für die Verzierungen."

	-- Additional Toggles
	L["ToggleTopper"] = "Obere Verzierung anzeigen"
	L["ToggleTopperTT"] = "Zeigt die obere Verzierung der Geschwindigkeitsanzeige."
	L["ToggleFooter"] = "Untere Verzierung anzeigen"
	L["ToggleFooterTT"] = "Zeigt die untere Verzierung der Geschwindigkeitsanzeige."
	L["ToggleVigor"] = "Vigor-Leisten anzeigen"
	L["ToggleVigorTT"] = "Zeigt die 6 Vigor-Ladungen an."

	-- Themes
	L["ThemeAlgari_Gold"] = "Algari - Gold"
	L["ThemeAlgari_Bronze"] = "Algari - Bronze"
	L["ThemeAlgari_Dark"] = "Algari - Dunkel"
	L["ThemeAlgari_Silver"] = "Algari - Silber"
	L["ThemeDefault_Desaturated"] = "Standard - Entsättigt"
	L["ThemeAlgari_Desaturated"] = "Algari - Entsättigt"
	L["ThemeGryphon_Desaturated"] = "Greif - Entsättigt"
	L["ThemeWyvern_Desaturated"] = "Wyvern - Entsättigt"
	L["ThemeDragon_Desaturated"] = "Drache - Entsättigt"

	-- Model Themes
	L["ModelTheme_Wind"] = "Wind"
	L["ModelTheme_Lightning"] = "Blitz"
	L["ModelTheme_FireForm"] = "Feuergestalt"
	L["ModelTheme_ArcaneForm"] = "Arkanform"
	L["ModelTheme_FrostForm"] = "Frostgestalt"
	L["ModelTheme_HolyForm"] = "Heiliggestalt"
	L["ModelTheme_NatureForm"] = "Naturgestalt"
	L["ModelTheme_ShadowForm"] = "Schattengestalt"

	-- TOC translations
	L["DR_Title"] = "Drachenreiter"
	L["DR_Notes"] = "Zeigt einen Tachometer gepaart mit der Energieleiste und einigen anderen Drachenreiten-bezogenen Optionen an."


return end

if LOCALE == "frFR" then
	-- French translations go here
	L["Vigor"] = "Vigueur"
	L["Speedometer"] = "Compteur de vitesse"
	L["ToggleModelsName"] = "Afficher les modèles de vigueur"
	L["ToggleModelsTT"] = "Affichez l'effet de modèle tourbillonnant sur les bulles de vigueur."
	L["SpeedPosPointName"] = "Position du compteur de vitesse"
	L["SpeedPosPointTT"] = "Ajuste l'endroit où le compteur de vitesse est ancré par rapport à la barre de vigueur."
	L["Top"] = "Haut"
	L["Bottom"] = "Bas"
	L["Left"] = "Gauche"
	L["Right"] = "Droite"
	L["SpeedPosXName"] = "Position horizontale du compteur de vitesse"
	L["SpeedPosXTT"] = "Réglez la position horizontale du compteur de vitesse."
	L["SpeedPosYName"] = "Position verticale du compteur de vitesse"
	L["SpeedPosYTT"] = "Réglez la position verticale du compteur de vitesse."
	L["SpeedScaleName"] = "Échelle du compteur de vitesse"
	L["SpeedScaleTT"] = "Réglez l'échelle du compteur de vitesse."
	L["Large"] = "Grand"
	L["Small"] = "Petit"
	L["Units"] = "Texte des unités du vélocimètre" -- Changed in 11.2.7
	L["UnitsTT"] = "Modifiez les unités affichées sur le compteur de vitesse.\n(Mécaniquement 1 mètre = 1 yard)"
	L["UnitsColor"] = "Couleur du texte des unités du vélocimètre" -- Changed in 11.2.7
	L["UnitYards"] = "verges/s"
	L["Yards"] = "Verges"
	L["UnitMiles"] = "mi/h"
	L["Miles"] = "Milles"
	L["UnitMeters"] = "m/s"
	L["Meters"] = "Mètres"
	L["UnitKilometers"] = "km/h"
	L["Kilometers"] = "Kilomètres"
	L["UnitPercent"] = "%"
	L["Percent"] = "Pourcentage"
	L["SpeedTextScale"] = "Taille du texte du compteur de vitesse"
	L["SpeedTextScaleTT"] = "Ajustez la taille du texte sur le compteur de vitesse."
	L["Version"] = "Version %s"
	L["ResetAllSettings"] = "Réinitialiser tous les paramètres de Dragon Rider"
	L["ResetAllSettingsTT"] = "Réinitialise tous les paramètres spécifiquement pour cet addon. Cela inclura les valeurs de couleur personnalisées."
	L["ResetAllSettingsConfirm"] = "Voulez-vous vraiment réinitialiser les paramètres de Dragon Rider?"
	L["Low"] = "Faible"
	L["High"] = "Haut"
	L["ProgressBar"] = "Compteur de vitesse" -- Deprecated
	L["ProgressBarColor"] = "Couleur du compteur de vitesse" -- Deprecated
	L["ColorPickerLowProgTT"] = "Choisissez une couleur personnalisée pour les valeurs de basse vitesse du compteur de vitesse. Cela se produit lorsque le joueur ne gagne aucune vigueur." -- Deprecated
	L["ColorPickerMidProgTT"] = "Choisissez une couleur personnalisée pour les valeurs de vitesse de vigueur du compteur de vitesse. Cela se produit lorsque le joueur gagne en vigueur dans une plage de vitesse standard." -- Deprecated
	L["ColorPickerHighProgTT"] = "Choisissez une couleur personnalisée pour les valeurs de vitesse élevée du compteur de vitesse. Cela se produit lorsque le joueur gagne en vigueur, mais est au-dessus de la plage de vitesse standard." -- Deprecated
	L["ColorPickerLowTextTT"] = "Choisissez une couleur personnalisée pour les valeurs de faible vitesse de la valeur de vitesse. Cela se produit lorsque le joueur ne gagne aucune vigueur." -- Deprecated
	L["ColorPickerMidTextTT"] = "Choisissez une couleur personnalisée pour les valeurs de vitesse de vigueur de la valeur de vitesse. Cela se produit lorsque le joueur gagne en vigueur dans une plage de vitesse standard." -- Deprecated
	L["ColorPickerHighTextTT"] = "Choisissez une couleur personnalisée pour les valeurs de vitesse élevée de la valeur de vitesse. Cela se produit lorsque le joueur gagne en vigueur, mais est au-dessus de la plage de vitesse standard." -- Deprecated
	L["DragonridingTalents"] = "Compétences et déblocages du Vol à voile" -- Changed in 11.2.7
	L["OpenDragonridingTalents"] = "Compétences et déblocages du Vol à voile" -- Changed in 11.2.7
	L["OpenDragonridingTalentsTT"] = "Ouvre les compétences et déblocages du Vol à voile." -- Changed in 11.2.7
	L["SideArtName"] = "Art Parallèle"
	L["SideArtTT"] = "Basculez l’art sur les côtés de la barre Vigor principale."
	L["BugfixesName"] = "Corrections de bugs"
	L["BugfixesTT"] = "Tentatives expérimentales de correction de bogues lorsque les images Blizzard par défaut ne fonctionnent pas comme prévu."
	L["BugfixHideVigor"] = "Forcer à masquer la vigueur"
	L["BugfixHideVigorTT"] = "Forcer à masquer la barre de vigueur lors de la descente et à la réafficher lorsqu'il est monté sur une monture de vol dynamique."
	L["FadeSpeedometer"] = "Fade Speedometer"
	L["FadeSpeedometerTT"] = "Activer le fondu du compteur de vitesse lorsque vous ne planez pas."
	L["ShowVigorTooltip"] = "Afficher l'info-bulle Vigor"
	L["ShowVigorTooltipTT"] = "Basculez l'info-bulle qui s'affiche sur la barre Vigor."
	L["FadeVigor"] = "Fade Vigor"
	L["FadeVigorTT"] = "Activer l'effacement de la barre Vigor lorsque vous ne glissez pas et lorsque vous êtes au maximum de Vigor."
	L["LightningRush"] = "Afficher les orbes de Charge statique" -- Changed in 11.2.7
	L["LightningRushTT"] = "Active ou désactive les orbes de Charge statique utilisés par la technique Ruée Foudroyante." -- Changed in 11.2.7
	L["DynamicFOV"] = "Champ de vision dynamique"
	L["DynamicFOVTT"] = "Permet d'ajuster le champ de vision de la caméra en fonction de la vitesse de glisse."
	L["Normal"] = "Normale"
	L["Advanced"] = "Avancée"
	L["Reverse"] = "Inversée"
	L["Challenge"] = "Défi"
	L["ReverseChallenge"] = "Défi Inversé"
	L["Storm"] = "Tempête"
	L["COMMAND_help"] = "aide"
	L["COMMAND_journal"] = "journal"
	L["COMMAND_listcommands"] = "Liste des commandes :"
	L["COMMAND_dragonrider"] = "dragonrider"
	L["DragonRider"] = "Chevaucheur de dragon"
	L["RightClick_TT_Line"] = "Clic droit : Ouvrir les paramètres"
	L["LeftClick_TT_Line"] = "Clic gauche : Ouvrir le journal"
	L["SlashCommands_TT_Line"] = "'/dragonrider' pour des commandes supplémentaires"
	L["Score"] = "Score"
	L["Guide"] = "Guide"
	L["Settings"] = "Paramètres"
	L["ComingSoon"] = "Prochainement"
	L["UseAccountScores"] = "Utiliser les Scores du Compte"
	L["UseAccountScoresTT"] = "Cela affichera vos meilleures scores de courses du compte plutôt que ceux de votre personnage. Les scores du compte sont indiqués par un astérisque (*)."
	L["PersonalBest"] = "Meilleur personnel : "
	L["AccountBest"] = "Meilleur du compte : "
	L["BestCharacter"] = "Meilleur personnage : "
	L["GoldTime"] = "Temps Or : "
	L["SilverTime"] = "Temps Argent : "
	L["MuteVigorSound_Settings"] = "Muter le son de Vigueur"
	L["MuteVigorSound_SettingsTT"] = "Activer/désactiver le son qui se joue lorsque la monture de vol dynamique obtient naturellement une pile de vigueur."
	L["SpeedometerTheme"] = "Thème du tachymètre"
	L["SpeedometerThemeTT"] = "Personnalisez le thème du tachymètre."
	L["Algari"] = "Algari"
	L["Default"] = DEFAULT
	L["Minimalist"] = "Minimaliste"
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	L["TimerunningStatistics"] = "Statistiques de Chronofracture"
	L["SkyridingCurrencyGained"] = "%s de Vol Céleste Obtenu :"

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "Afficher le vélocimètre"
	L["ToggleSpeedometerTT"] = "Active ou désactive l’affichage du vélocimètre."
	L["SpeedometerWidthName"] = "Largeur du vélocimètre"
	L["SpeedometerWidthTT"] = "Ajuste la largeur du cadre du vélocimètre."
	L["SpeedometerHeightName"] = "Hauteur du vélocimètre"
	L["SpeedometerHeightTT"] = "Ajuste la hauteur du cadre du vélocimètre."
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "Nécessite de fermer les options et d’atterrir pour prendre effet.\n\nIncompatible avec le réglage « Cinétose »."
	L["DynamicFOVNewTT"] = "Active l’ajustement du champ de vision de la caméra selon le vol plané et la vitesse V.R.O.U.M."
	L["StaticChargeOffset"] = "Décalage de la charge statique"
	L["StaticChargeSpacing"] = "Espacement de la charge statique"
	L["StaticChargeSize"] = "Taille de la charge statique"
	L["StaticChargeWidth"] = "Largeur de la charge statique"
	L["StaticChargeHeight"] = "Hauteur de la charge statique"
	L["StaticChargeWidthTT"] = "Ajuste la largeur des charges statiques."
	L["StaticChargeHeightTT"] = "Ajuste la hauteur des charges statiques."
	L["StaticChargeSpacingTT"] = "Ajuste l'espacement des charges statiques."
	L["StaticChargeOffsetTT"] = "Ajuste le décalage des charges statiques."
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors
	L["SpeedometerBar_Slow_ColorPicker"] = "Couleur de vitesse basse"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "Choisissez une couleur pour les vitesses basses."
	L["SpeedometerBar_Recharge_ColorPicker"] = "Couleur de vitesse de recharge"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "Choisissez une couleur lorsque les Charges d’essor se rechargent plus vite (buff : Allégresse des cieux)."
	L["SpeedometerBar_Over_ColorPicker"] = "Couleur de vitesse excédée"
	L["SpeedometerBar_Over_ColorPickerTT"] = "Choisissez une couleur pour les vitesses au-dessus du maximum naturel (deuxième repère à 65 %)."
	L["SpeedometerText_Slow_ColorPicker"] = "Couleur du texte (vitesse basse)"
	L["SpeedometerText_Slow_ColorPickerTT"] = "Choisissez une couleur pour le texte lorsque la vitesse est basse."
	L["SpeedometerText_Recharge_ColorPicker"] = "Couleur du texte (recharge)"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "Choisissez une couleur pour le texte lorsque les Charges se rechargent plus vite."
	L["SpeedometerText_Over_ColorPicker"] = "Couleur du texte (vitesse excédée)"
	L["SpeedometerText_Over_ColorPickerTT"] = "Choisissez une couleur pour les vitesses excédant le maximum naturel."
	L["SpeedometerCover_ColorPicker"] = "Couleur du cache du vélocimètre"
	L["SpeedometerCover_ColorPickerTT"] = "Choisissez une couleur pour le cache."
	L["SpeedometerTick_ColorPicker"] = "Couleur des repères"
	L["SpeedometerTick_ColorPickerTT"] = "Choisissez une couleur pour les repères de 60 % et 65 %."
	L["SpeedometerTopper_ColorPicker"] = "Couleur du haut du vélocimètre"
	L["SpeedometerTopper_ColorPickerTT"] = "Choisissez une couleur pour la texture supérieure."
	L["SpeedometerFooter_ColorPicker"] = "Couleur du bas du vélocimètre"
	L["SpeedometerFooter_ColorPickerTT"] = "Choisissez une couleur pour la texture inférieure."
	L["SpeedometerBackground_ColorPicker"] = "Couleur de fond du vélocimètre"
	L["SpeedometerBackground_ColorPickerTT"] = "Choisissez une couleur pour le fond."
	L["SpeedometerSpark_ColorPicker"] = "Couleur de l’étincelle"
	L["SpeedometerSpark_ColorPickerTT"] = "Choisissez une couleur pour l’étincelle en bordure de progression."

	-- Vigor Bar Settings
	L["VigorTheme"] = "Thème de Vigueur"
	L["VigorThemeTT"] = "Personnalise le thème de la barre de Vigueur."
	L["VigorPosXName"] = "Position horizontale de Vigueur"
	L["VigorPosXNameTT"] = "Ajuste la position horizontale des barres de Vigueur."
	L["VigorPosYName"] = "Position verticale de Vigueur"
	L["VigorPosYNameTT"] = "Ajuste la position verticale de la barre de Vigueur."
	L["VigorBarWidthName"] = "Largeur d’une charge de Vigueur"
	L["VigorBarWidthNameTT"] = "Ajuste la largeur de chaque charge."
	L["VigorBarHeightName"] = "Hauteur d’une charge de Vigueur"
	L["VigorBarHeightNameTT"] = "Ajuste la hauteur de chaque charge."
	L["VigorBarSpacingName"] = "Espacement des charges"
	L["VigorBarSpacingNameTT"] = "Ajuste l’espace entre chaque charge."
	L["VigorBarOrientationName"] = "Orientation de la barre de Vigueur"
	L["VigorBarOrientationNameTT"] = "Détermine la disposition générale de la barre."
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "Direction de croissance"
	L["VigorBarDirectionNameTT"] = "Définit la direction dans laquelle les charges se développent."
	L["Direction_DownRight"] = "Haut vers Bas / Gauche vers Droite"
	L["Direction_UpLeft"] = "Bas vers Haut / Droite vers Gauche"
	L["VigorWrapName"] = "Limite d’affichage"
	L["VigorWrapNameTT"] = "Définit combien de charges apparaissent avant un retour à la ligne/colonne."
	L["VigorBarFillDirectionName"] = "Direction de remplissage"
	L["VigorBarFillDirectionNameTT"] = "Définit la direction dans laquelle les charges se remplissent."
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "Épaisseur de l’étincelle"
	L["VigorSparkThicknessNameTT"] = "Ajuste l’épaisseur de l’étincelle de recharge."
	L["ToggleFlashFullName"] = "Flash à charge complète"
	L["ToggleFlashFullNameTT"] = "Active un flash lorsqu’une charge est complète."
	L["ToggleFlashProgressName"] = "Flash en recharge"
	L["ToggleFlashProgressNameTT"] = "Active une pulsation pendant la recharge."
	L["ModelThemeName"] = "Thème du modèle de Vigueur"
	L["ModelThemeNameTT"] = "Change l’effet visuel du modèle de Vigueur."
	L["SideArtStyleName"] = "Thème de l’art latéral"
	L["SideArtStyleNameTT"] = "Change le thème de l’art latéral."
	L["SideArtPosX"] = "Position horizontale de l’art latéral"
	L["SideArtPosXTT"] = "Ajuste la position horizontale."
	L["SideArtPosY"] = "Position verticale de l’art latéral"
	L["SideArtPosYTT"] = "Ajuste la position verticale."
	L["SideArtRot"] = "Rotation de l’art latéral"
	L["SideArtRotTT"] = "Ajuste la rotation."
	L["SideArtScale"] = "Échelle de l’art latéral"
	L["SideArtScaleTT"] = "Ajuste la taille."
	L["DesaturatedOptionTT"] = "Certaines options sont désaturées, ce qui permet au sélecteur de couleur de mieux les appliquer. Les options non désaturées sont plus lisibles lorsque le sélecteur de couleur est réglé sur blanc (#FFFFFF)."

	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "Couleur : charge pleine"
	L["VigorBar_Full_ColorPickerTT"] = "Choisissez une couleur pour une charge pleine."
	L["VigorBar_Empty_ColorPicker"] = "Couleur : charge vide"
	L["VigorBar_Empty_ColorPickerTT"] = "Choisissez une couleur pour une charge vide."
	L["VigorBar_Progress_ColorPicker"] = "Couleur : charge en recharge"
	L["VigorBar_Progress_ColorPickerTT"] = "Choisissez une couleur pour l’état de recharge."
	L["VigorBarCover_ColorPicker"] = "Couleur du cache"
	L["VigorBarCover_ColorPickerTT"] = "Choisissez une couleur pour le cache."
	L["VigorBarBackground_ColorPicker"] = "Couleur de fond"
	L["VigorBarBackground_ColorPickerTT"] = "Choisissez une couleur de fond."
	L["VigorBarSpark_ColorPicker"] = "Couleur de l’étincelle"
	L["VigorBarSpark_ColorPickerTT"] = "Couleur de l’étincelle en bordure de progression."
	L["VigorBarFlash_ColorPicker"] = "Couleur du flash"
	L["VigorBarFlash_ColorPickerTT"] = "Couleur du flash lors du remplissage ou de la recharge."
	L["VigorBarDecor_ColorPicker"] = "Couleur de l’art latéral"
	L["VigorBarDecor_ColorPickerTT"] = "Choisissez une couleur pour l’art latéral."

	-- Additional Toggles
	L["ToggleTopper"] = "Afficher le haut"
	L["ToggleTopperTT"] = "Active ou désactive la texture supérieure du vélocimètre."
	L["ToggleFooter"] = "Afficher le bas"
	L["ToggleFooterTT"] = "Active ou désactive la texture inférieure du vélocimètre."
	L["ToggleVigor"] = "Afficher les barres de Vigueur"
	L["ToggleVigorTT"] = "Active l’affichage des 6 charges de Vigueur."

	-- Themes
	L["ThemeAlgari_Gold"] = "Algari - Or"
	L["ThemeAlgari_Bronze"] = "Algari - Bronze"
	L["ThemeAlgari_Dark"] = "Algari - Sombre"
	L["ThemeAlgari_Silver"] = "Algari - Argent"
	L["ThemeDefault_Desaturated"] = "Par défaut - Désaturé"
	L["ThemeAlgari_Desaturated"] = "Algari - Désaturé"
	L["ThemeGryphon_Desaturated"] = "Griffon - Désaturé"
	L["ThemeWyvern_Desaturated"] = "Wyrm - Désaturé"
	L["ThemeDragon_Desaturated"] = "Dragon - Désaturé"

	-- Model Themes
	L["ModelTheme_Wind"] = "Vent"
	L["ModelTheme_Lightning"] = "Foudre"
	L["ModelTheme_FireForm"] = "Forme de Feu"
	L["ModelTheme_ArcaneForm"] = "Forme des Arcanes"
	L["ModelTheme_FrostForm"] = "Forme de Givre"
	L["ModelTheme_HolyForm"] = "Forme Sacrée"
	L["ModelTheme_NatureForm"] = "Forme de Nature"
	L["ModelTheme_ShadowForm"] = "Forme d’Ombre"

	-- TOC translations
	L["DR_Title"] = "Dragonnier"
	L["DR_Notes"] = "Affiche un indicateur de vitesse associé à la barre de vigueur et à d'autres options liées à la conduite de dragons."

return end

if LOCALE == "itIT" then
	-- Italian translations go here
	L["Vigor"] = "Vigore"
	L["Speedometer"] = "Tachimetro"
	L["ToggleModelsName"] = "Mostra modelli di vigore"
	L["ToggleModelsTT"] = "Mostra l'effetto del modello vorticoso sulle bolle di vigore."
	L["SpeedPosPointName"] = "Posizione del tachimetro"
	L["SpeedPosPointTT"] = "Regola dove è ancorato il tachimetro rispetto alla barra del vigore."
	L["Top"] = "Superiore"
	L["Bottom"] = "Metter il fondo a"
	L["Left"] = "Sinistra"
	L["Right"] = "Giusto"
	L["SpeedPosXName"] = "Posizione orizzontale del tachimetro"
	L["SpeedPosXTT"] = "Regola la posizione orizzontale del tachimetro."
	L["SpeedPosYName"] = "Posizione verticale del tachimetro"
	L["SpeedPosYTT"] = "Regola la posizione verticale del tachimetro."
	L["SpeedScaleName"] = "Scala del tachimetro"
	L["SpeedScaleTT"] = "Regola la scala del tachimetro."
	L["Large"] = "Grande"
	L["Small"] = "Piccolo"
	L["Units"] = "Testo delle unità del tachimetro" -- Changed in 11.2.7
	L["UnitsTT"] = "Cambia le unità visualizzate sul tachimetro.\n(Meccanicamente 1 metro = 1 iarda)"
	L["UnitsColor"] = "Colore del testo delle unità del tachimetro" -- Changed in 11.2.7
	L["UnitYards"] = "yd/s"
	L["Yards"] = "Iarde"
	L["UnitMiles"] = "mph"
	L["Miles"] = "Miglia"
	L["UnitMeters"] = "m/s"
	L["Meters"] = "Metri"
	L["UnitKilometers"] = "km/h"
	L["Kilometers"] = "Chilometri"
	L["UnitPercent"] = "%"
	L["Percent"] = "Percentuale"
	L["SpeedTextScale"] = "Dimensione del testo del tachimetro"
	L["SpeedTextScaleTT"] = "Regola la dimensione del testo sul tachimetro."
	L["Version"] = "Versione %s"
	L["ResetAllSettings"] = "Ripristina tutte le impostazioni di Dragon Rider"
	L["ResetAllSettingsTT"] = "Ripristina tutte le impostazioni specifiche per questo componente aggiuntivo. Ciò includerà i valori di colore personalizzati."
	L["ResetAllSettingsConfirm"] = "Sei sicuro di voler ripristinare le impostazioni di Dragon Rider?"
	L["Low"] = "Basso"
	L["High"] = "Alto"
	L["ProgressBar"] = "Tachimetro" -- Deprecated
	L["ProgressBarColor"] = "Colore del tachimetro" -- Deprecated
	L["ColorPickerLowProgTT"] = "Scegli un colore personalizzato per i valori di bassa velocità del tachimetro. Ciò si verifica quando il giocatore non sta guadagnando vigore." -- Deprecated
	L["ColorPickerMidProgTT"] = "Scegli un colore personalizzato per i valori di velocità del vigore del tachimetro. Ciò si verifica quando il giocatore sta guadagnando vigore entro un intervallo di velocità standard." -- Deprecated
	L["ColorPickerHighProgTT"] = "Scegli un colore personalizzato per i valori di alta velocità del tachimetro. Ciò si verifica quando il giocatore sta guadagnando vigore, ma è al di sopra della gamma di velocità standard." -- Deprecated
	L["ColorPickerLowTextTT"] = "Scegli un colore personalizzato per i valori di bassa velocità del valore di velocità. Ciò si verifica quando il giocatore non sta guadagnando vigore." -- Deprecated
	L["ColorPickerMidTextTT"] = "Scegli un colore personalizzato per i valori di velocità del vigore del valore di velocità. Ciò si verifica quando il giocatore sta guadagnando vigore entro un intervallo di velocità standard." -- Deprecated
	L["ColorPickerHighTextTT"] = "Scegli un colore personalizzato per i valori ad alta velocità del valore della velocità. Ciò si verifica quando il giocatore sta guadagnando vigore, ma è al di sopra della gamma di velocità standard." -- Deprecated
	L["DragonridingTalents"] = "Abilità e Sblocchi del Volo Draconico" -- Changed in 11.2.7
	L["OpenDragonridingTalents"] = "Abilità e Sblocchi del Volo Draconico" -- Changed in 11.2.7
	L["OpenDragonridingTalentsTT"] = "Apre la finestra delle abilità e degli sblocchi del Volo Draconico." -- Changed in 11.2.7
	L["SideArtName"] = "Arte Laterale"
	L["SideArtTT"] = "Attiva/disattiva la grafica sui lati della barra principale del Vigore."
	L["BugfixesName"] = "Correzioni di bug"
	L["BugfixesTT"] = "Tentativi sperimentali di correzione di bug per quando i frame Blizzard predefiniti non funzionano come previsto."
	L["BugfixHideVigor"] = "Forza Nascondi Vigore"
	L["BugfixHideVigorTT"] = "Nascondi forzatamente la barra del vigore quando scendi e la mostri quando sei montata su una cavalcatura volante di Volo Dinamico."
	L["FadeSpeedometer"] = "Tachimetro della dissolvenza"
	L["FadeSpeedometerTT"] = "Attiva/disattiva la dissolvenza del tachimetro quando non stai planando."
	L["ShowVigorTooltip"] = "Mostra descrizione comando Vigor"
	L["ShowVigorTooltipTT"] = "Attiva/disattiva la descrizione comando visualizzata sulla barra del vigore."
	L["FadeVigor"] = "Vigore della dissolvenza"
	L["FadeVigorTT"] = "Attiva/disattiva la dissolvenza della barra del vigore quando non si plana e mentre si è al massimo del vigore."
	L["LightningRush"] = "Mostra le Sfere di Carica Statica" -- Changed in 11.2.7
	L["LightningRushTT"] = "Attiva o disattiva le Sfere di Carica Statica utilizzate dall’abilità Impeto Fulmineo." -- Changed in 11.2.7
	L["DynamicFOV"] = "FOV dinamico"
	L["DynamicFOVTT"] = "Consente la regolazione del campo visivo della telecamera in base alla velocità di planata."
	L["Normal"] = "Normale"
	L["Advanced"] = "Avanzate"
	L["Reverse"] = "Inverso"
	L["Challenge"] = "Sfida"
	L["ReverseChallenge"] = "Sfida Inversa"
	L["Storm"] = "Tempesta"
	L["COMMAND_help"] = "aiuto"
	L["COMMAND_journal"] = "diario"
	L["COMMAND_listcommands"] = "Lista dei comandi:"
	L["COMMAND_dragonrider"] = "dragonrider"
	L["DragonRider"] = "Cavaliere del Drago"
	L["RightClick_TT_Line"] = "Clic destro: Apri impostazioni"
	L["LeftClick_TT_Line"] = "Clic sinistro: Apri diario"
	L["SlashCommands_TT_Line"] = "'/dragonrider' per comandi aggiuntivi"
	L["Score"] = "Punteggio"
	L["Guide"] = "Guida"
	L["Settings"] = "Impostazioni"
	L["ComingSoon"] = "Prossimamente"
	L["UseAccountScores"] = "Usa Punteggi dell'Account"
	L["UseAccountScoresTT"] = "Questo mostrerà i tuoi migliori punteggi di gara dell'account invece di quelli del tuo personaggio. I punteggi dell'account sono indicati con un asterisco (*)."
	L["PersonalBest"] = "Personale migliore: "
	L["AccountBest"] = "Miglior dell'account: "
	L["BestCharacter"] = "Miglior personaggio: "
	L["GoldTime"] = "Tempo Oro: "
	L["SilverTime"] = "Tempo Argento: "
	L["MuteVigorSound_Settings"] = "Silenzia suono Vigore"
	L["MuteVigorSound_SettingsTT"] = "Attiva/disattiva il suono che si riproduce quando la cavalcatura di Volo Dinamico guadagna naturalmente uno stack di vigore."
	L["SpeedometerTheme"] = "Tema del tachimetro"
	L["SpeedometerThemeTT"] = "Personalizza il tema del tachimetro."
	L["Algari"] = "Algari"
	L["Default"] = DEFAULT
	L["Minimalist"] = "Minimalista"
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	L["TimerunningStatistics"] = "Statistiche di Corsa Temporale"
	L["SkyridingCurrencyGained"] = "%s di Cavalcata Celeste Ottenuto:"

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "Mostra il tachimetro"
	L["ToggleSpeedometerTT"] = "Attiva o disattiva la visualizzazione del tachimetro."
	L["SpeedometerWidthName"] = "Larghezza del tachimetro"
	L["SpeedometerWidthTT"] = "Regola la larghezza del telaio del tachimetro."
	L["SpeedometerHeightName"] = "Altezza del tachimetro"
	L["SpeedometerHeightTT"] = "Regola l’altezza del telaio del tachimetro."
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "Richiede di chiudere le impostazioni e atterrare affinché abbia effetto.\n\nIncompatibile con l’impostazione \"Chinetosi\"."
	L["DynamicFOVNewTT"] = "Abilita la regolazione del campo visivo della telecamera in base al volo planato e alla velocità G.U.I.D.A."
	L["StaticChargeOffset"] = "Offset della Carica Statica"
	L["StaticChargeSpacing"] = "Spaziatura della Carica Statica"
	L["StaticChargeSize"] = "Dimensione della Carica Statica"
	L["StaticChargeWidth"] = "Larghezza della Carica Statica"
	L["StaticChargeHeight"] = "Altezza della Carica Statica"
	L["StaticChargeWidthTT"] = "Regola la larghezza delle Cariche Statiche."
	L["StaticChargeHeightTT"] = "Regola l'altezza delle Cariche Statiche."
	L["StaticChargeSpacingTT"] = "Regola la spaziatura delle Cariche Statiche."
	L["StaticChargeOffsetTT"] = "Regola l'offset delle Cariche Statiche."
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors
	L["SpeedometerBar_Slow_ColorPicker"] = "Colore: velocità bassa"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "Scegli un colore per le velocità basse."
	L["SpeedometerBar_Recharge_ColorPicker"] = "Colore: velocità di ricarica"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "Scegli un colore per le velocità che accelerano la ricarica del Vigore (bonus: Furia dei Cieli/Euphoria)."
	L["SpeedometerBar_Over_ColorPicker"] = "Colore: velocità oltre il limite"
	L["SpeedometerBar_Over_ColorPickerTT"] = "Scegli un colore per velocità superiori al massimo naturale (secondo indicatore al 65%)."
	L["SpeedometerText_Slow_ColorPicker"] = "Colore testo (velocità bassa)"
	L["SpeedometerText_Slow_ColorPickerTT"] = "Scegli un colore per il testo in caso di velocità bassa."
	L["SpeedometerText_Recharge_ColorPicker"] = "Colore testo (ricarica)"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "Scegli un colore per il testo in caso di ricarica accelerata."
	L["SpeedometerText_Over_ColorPicker"] = "Colore testo (oltre il limite)"
	L["SpeedometerText_Over_ColorPickerTT"] = "Scegli un colore per il testo quando la velocità supera il limite naturale."
	L["SpeedometerCover_ColorPicker"] = "Colore della copertura del tachimetro"
	L["SpeedometerCover_ColorPickerTT"] = "Scegli un colore per la copertura."
	L["SpeedometerTick_ColorPicker"] = "Colore degli indicatori"
	L["SpeedometerTick_ColorPickerTT"] = "Scegli un colore per gli indicatori al 60% e 65%."
	L["SpeedometerTopper_ColorPicker"] = "Colore della decorazione superiore"
	L["SpeedometerTopper_ColorPickerTT"] = "Scegli un colore per la decorazione superiore."
	L["SpeedometerFooter_ColorPicker"] = "Colore della decorazione inferiore"
	L["SpeedometerFooter_ColorPickerTT"] = "Scegli un colore per la decorazione inferiore."
	L["SpeedometerBackground_ColorPicker"] = "Colore dello sfondo"
	L["SpeedometerBackground_ColorPickerTT"] = "Scegli un colore per lo sfondo."
	L["SpeedometerSpark_ColorPicker"] = "Colore della scintilla"
	L["SpeedometerSpark_ColorPickerTT"] = "Scegli un colore per la scintilla ai bordi della barra di avanzamento."

	-- Vigor Bar Settings
	L["VigorTheme"] = "Tema del Vigore"
	L["VigorThemeTT"] = "Personalizza il tema della barra del Vigore."
	L["VigorPosXName"] = "Posizione orizzontale del Vigore"
	L["VigorPosXNameTT"] = "Regola la posizione orizzontale delle barre del Vigore."
	L["VigorPosYName"] = "Posizione verticale del Vigore"
	L["VigorPosYNameTT"] = "Regola la posizione verticale della barra del Vigore."
	L["VigorBarWidthName"] = "Larghezza della carica di Vigore"
	L["VigorBarWidthNameTT"] = "Regola la larghezza di ogni carica."
	L["VigorBarHeightName"] = "Altezza della carica di Vigore"
	L["VigorBarHeightNameTT"] = "Regola l’altezza di ogni carica."
	L["VigorBarSpacingName"] = "Spaziatura tra le cariche"
	L["VigorBarSpacingNameTT"] = "Regola la distanza tra ogni carica."
	L["VigorBarOrientationName"] = "Orientamento della barra del Vigore"
	L["VigorBarOrientationNameTT"] = "Determina l’orientamento generale della barra."
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "Direzione di crescita"
	L["VigorBarDirectionNameTT"] = "Determina la direzione in cui le cariche si espandono."
	L["Direction_DownRight"] = "Dall’Alto verso il Basso / Da Sinistra a Destra"
	L["Direction_UpLeft"] = "Dal Basso verso l’Alto / Da Destra a Sinistra"
	L["VigorWrapName"] = "Limite di riga"
	L["VigorWrapNameTT"] = "Determina quante cariche vengono mostrate prima che si vada a capo."
	L["VigorBarFillDirectionName"] = "Direzione di riempimento"
	L["VigorBarFillDirectionNameTT"] = "Determina la direzione in cui le cariche si riempiono."
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "Spessore della scintilla"
	L["VigorSparkThicknessNameTT"] = "Regola lo spessore della scintilla di ricarica."
	L["ToggleFlashFullName"] = "Lampeggio a carica completa"
	L["ToggleFlashFullNameTT"] = "Abilita un lampeggio quando una carica è completamente riempita."
	L["ToggleFlashProgressName"] = "Lampeggio durante la ricarica"
	L["ToggleFlashProgressNameTT"] = "Abilita un effetto pulsante durante la ricarica."
	L["ModelThemeName"] = "Tema del modello del Vigore"
	L["ModelThemeNameTT"] = "Cambia l’effetto visivo del modello del Vigore."
	L["SideArtStyleName"] = "Tema delle decorazioni laterali"
	L["SideArtStyleNameTT"] = "Modifica il tema delle decorazioni laterali."
	L["SideArtPosX"] = "Posizione orizzontale della decorazione laterale"
	L["SideArtPosXTT"] = "Regola la posizione orizzontale."
	L["SideArtPosY"] = "Posizione verticale della decorazione laterale"
	L["SideArtPosYTT"] = "Regola la posizione verticale."
	L["SideArtRot"] = "Rotazione della decorazione laterale"
	L["SideArtRotTT"] = "Regola la rotazione."
	L["SideArtScale"] = "Scala della decorazione laterale"
	L["SideArtScaleTT"] = "Regola la dimensione."
	L["DesaturatedOptionTT"] = "Alcune opzioni sono desaturate, permettendo al selettore colore di applicare meglio i colori. Le opzioni non desaturate si vedono meglio con il selettore colore impostato su bianco (#FFFFFF)."

	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "Colore: carica piena"
	L["VigorBar_Full_ColorPickerTT"] = "Scegli un colore per una carica piena."
	L["VigorBar_Empty_ColorPicker"] = "Colore: carica vuota"
	L["VigorBar_Empty_ColorPickerTT"] = "Scegli un colore per una carica vuota."
	L["VigorBar_Progress_ColorPicker"] = "Colore: carica in ricarica"
	L["VigorBar_Progress_ColorPickerTT"] = "Scegli un colore per lo stato di ricarica."
	L["VigorBarCover_ColorPicker"] = "Colore della copertura"
	L["VigorBarCover_ColorPickerTT"] = "Scegli un colore per la copertura."
	L["VigorBarBackground_ColorPicker"] = "Colore dello sfondo"
	L["VigorBarBackground_ColorPickerTT"] = "Scegli un colore per lo sfondo."
	L["VigorBarSpark_ColorPicker"] = "Colore della scintilla"
	L["VigorBarSpark_ColorPickerTT"] = "Colore della scintilla lungo il bordo della carica."
	L["VigorBarFlash_ColorPicker"] = "Colore del lampeggio"
	L["VigorBarFlash_ColorPickerTT"] = "Colore del lampeggio durante la ricarica."
	L["VigorBarDecor_ColorPicker"] = "Colore delle decorazioni"
	L["VigorBarDecor_ColorPickerTT"] = "Scegli un colore per le decorazioni laterali."

	-- Additional Toggles
	L["ToggleTopper"] = "Mostra decorazione superiore"
	L["ToggleTopperTT"] = "Mostra la decorazione superiore del tachimetro."
	L["ToggleFooter"] = "Mostra decorazione inferiore"
	L["ToggleFooterTT"] = "Mostra la decorazione inferiore del tachimetro."
	L["ToggleVigor"] = "Mostra le barre di Vigore"
	L["ToggleVigorTT"] = "Mostra le 6 cariche di Vigore."
	
	-- Themes
	L["ThemeAlgari_Gold"] = "Algari - Oro"
	L["ThemeAlgari_Bronze"] = "Algari - Bronzo"
	L["ThemeAlgari_Dark"] = "Algari - Scuro"
	L["ThemeAlgari_Silver"] = "Algari - Argento"
	L["ThemeDefault_Desaturated"] = "Predefinito - Desaturato"
	L["ThemeAlgari_Desaturated"] = "Algari - Desaturato"
	L["ThemeGryphon_Desaturated"] = "Grifone - Desaturato"
	L["ThemeWyvern_Desaturated"] = "Viverna - Desaturato"
	L["ThemeDragon_Desaturated"] = "Drago - Desaturato"

	-- Model Themes
	L["ModelTheme_Wind"] = "Vento"
	L["ModelTheme_Lightning"] = "Fulmine"
	L["ModelTheme_FireForm"] = "Forma di Fuoco"
	L["ModelTheme_ArcaneForm"] = "Forma Arcana"
	L["ModelTheme_FrostForm"] = "Forma di Gelo"
	L["ModelTheme_HolyForm"] = "Forma Sacra"
	L["ModelTheme_NatureForm"] = "Forma Naturale"
	L["ModelTheme_ShadowForm"] = "Forma d’Ombra"

	-- TOC translations
	L["DR_Title"] = "Cavaliere del Drago"
	L["DR_Notes"] = "Mostra un tachimetro abbinato alla barra del vigore e alcune altre opzioni relative alla cavalcata dei draghi."


return end

if LOCALE == "ptBR" then
	-- Brazilian Portuguese translations go here
	L["Vigor"] = "Vigor"
	L["Speedometer"] = "Velocímetro"
	L["ToggleModelsName"] = "Mostrar modelos de vigor"
	L["ToggleModelsTT"] = "Exiba o efeito do modelo giratório nas bolhas de vigor."
	L["SpeedPosPointName"] = "Posição do velocímetro"
	L["SpeedPosPointTT"] = "Ajusta onde o velocímetro está ancorado em relação à barra de vigor."
	L["Top"] = "Principal"
	L["Bottom"] = "Fundo"
	L["Left"] = "Esquerda"
	L["Right"] = "Certo"
	L["SpeedPosXName"] = "Posição horizontal do velocímetro"
	L["SpeedPosXTT"] = "Ajuste a posição horizontal do velocímetro."
	L["SpeedPosYName"] = "Posição vertical do velocímetro"
	L["SpeedPosYTT"] = "Ajuste a posição vertical do velocímetro."
	L["SpeedScaleName"] = "Escala do velocímetro"
	L["SpeedScaleTT"] = "Ajuste a escala do velocímetro."
	L["Large"] = "Grande"
	L["Small"] = "Pequeno"
	L["Units"] = "Texto das unidades do velocímetro" -- Changed in 11.2.7
	L["UnitsTT"] = "Altere as unidades exibidas no velocímetro.\n(mecanicamente 1 metro = 1 jarda)"
	L["UnitsColor"] = "Cor do texto das unidades do velocímetro" -- Changed in 11.2.7
	L["UnitYards"] = "jardas/s"
	L["Yards"] = "Jardas"
	L["UnitMiles"] = "mph"
	L["Miles"] = "Milhas"
	L["UnitMeters"] = "m/s"
	L["Meters"] = "Metros"
	L["UnitKilometers"] = "km/h"
	L["Kilometers"] = "Quilômetros"
	L["UnitPercent"] = "%"
	L["Percent"] = "Percentagem"
	L["SpeedTextScale"] = "Tamanho do texto do velocímetro"
	L["SpeedTextScaleTT"] = "Ajuste o tamanho do texto no velocímetro."
	L["Version"] = "Versão %s"
	L["ResetAllSettings"] = "Redefinir todas as configurações do Dragon Rider"
	L["ResetAllSettingsTT"] = "Redefine todas as configurações especificamente para este complemento. Isso incluirá os valores de cores personalizados."
	L["ResetAllSettingsConfirm"] = "Tem certeza de que deseja redefinir as configurações do Dragon Rider?"
	L["Low"] = "Baixo"
	L["High"] = "Alto"
	L["ProgressBar"] = "Velocímetro" -- Deprecated
	L["ProgressBarColor"] = "Cor do velocímetro" -- Deprecated
	L["ColorPickerLowProgTT"] = "Escolha uma cor personalizada para os valores de baixa velocidade do velocímetro. Isso ocorre quando o jogador não está ganhando vigor." -- Deprecated
	L["ColorPickerMidProgTT"] = "Escolha uma cor personalizada para os valores de velocidade de vigor do velocímetro. Isso ocorre quando o jogador está ganhando vigor dentro de uma faixa de velocidade padrão." -- Deprecated
	L["ColorPickerHighProgTT"] = "Escolha uma cor personalizada para os valores de alta velocidade do velocímetro. Isso ocorre quando o jogador está ganhando vigor, mas está acima da faixa de velocidade padrão." -- Deprecated
	L["ColorPickerLowTextTT"] = "Escolha uma cor personalizada para os valores de velocidade baixa do valor de velocidade. Isso ocorre quando o jogador não está ganhando vigor." -- Deprecated
	L["ColorPickerMidTextTT"] = "Escolha uma cor personalizada para os valores de velocidade de vigor do valor de velocidade. Isso ocorre quando o jogador está ganhando vigor dentro de uma faixa de velocidade padrão." -- Deprecated
	L["ColorPickerHighTextTT"] = "Escolha uma cor personalizada para os valores de alta velocidade do valor de velocidade. Isso ocorre quando o jogador está ganhando vigor, mas está acima da faixa de velocidade padrão." -- Deprecated
	L["DragonridingTalents"] = "Habilidades e Desbloqueios de Voo Dracônico" -- Changed in 11.2.7
	L["OpenDragonridingTalents"] = "Habilidades e Desbloqueios de Voo Dracônico" -- Changed in 11.2.7
	L["OpenDragonridingTalentsTT"] = "Abre a janela de habilidades e desbloqueios do Voo Dracônico." -- Changed in 11.2.7
	L["SideArtName"] = "Arte Lateral"
	L["SideArtTT"] = "Alterne a arte nas laterais da barra principal do Vigor."
	L["BugfixesName"] = "Correções de bugs"
	L["BugfixesTT"] = "Tentativas experimentais de correção de bugs quando os frames padrão da Blizzard não estão funcionando conforme o esperado."
	L["BugfixHideVigor"] = "Forçar Ocultar Vigor"
	L["BugfixHideVigorTT"] = "Force a ocultação da barra de vigor quando desmontada e mostre-a novamente quando montada em uma montaria voadora de Pilotagem Aérea."
	L["FadeSpeedometer"] = "Fade Velocímetro"
	L["FadeSpeedometerTT"] = "Alternar o desbotamento do velocímetro quando não estiver planando."
	L["ShowVigorTooltip"] = "Mostrar dica de vigor"
	L["ShowVigorTooltipTT"] = "Alternar a dica de ferramenta exibida na barra de Vigor."
	L["FadeVigor"] = "Fade Vigor"
	L["FadeVigorTT"] = "Alternar o desvanecimento da barra de Vigor quando não estiver planando e enquanto estiver com Vigor total."
	L["LightningRush"] = "Mostrar Orbes de Carga Estática" -- Changed in 11.2.7
	L["LightningRushTT"] = "Alterna os Orbes de Carga Estática usados pela habilidade Corrida Relâmpago." -- Changed in 11.2.7
	L["DynamicFOV"] = "Campo de visão dinâmico"
	L["DynamicFOVTT"] = "Permite o ajuste do campo de visão da câmera com base na velocidade de planeio."
	L["Normal"] = "Normal"
	L["Advanced"] = "Avançada"
	L["Reverse"] = "Invertida"
	L["Challenge"] = "Desafio"
	L["ReverseChallenge"] = "Desafio Invertida"
	L["Storm"] = "Tempestade"
	L["COMMAND_help"] = "ajuda"
	L["COMMAND_journal"] = "diário"
	L["COMMAND_listcommands"] = "Lista de comandos:"
	L["COMMAND_dragonrider"] = "dragonrider"
	L["DragonRider"] = "Cavaleiro do Dragão"
	L["RightClick_TT_Line"] = "Clique Direito: Abrir Configurações"
	L["LeftClick_TT_Line"] = "Clique Esquerdo: Abrir Diário"
	L["SlashCommands_TT_Line"] = "'/dragonrider' para comandos adicionais"
	L["Score"] = "Pontuação"
	L["Guide"] = "Guia"
	L["Settings"] = "Configurações"
	L["ComingSoon"] = "Em Breve"
	L["UseAccountScores"] = "Usar Pontuações da Conta"
	L["UseAccountScoresTT"] = "Isso mostrará suas melhores pontuações de corrida da conta em vez das pontuações do seu personagem. As pontuações da conta são indicadas com um asterisco (*)."
	L["PersonalBest"] = "Melhor Pessoal: "
	L["AccountBest"] = "Melhor da Conta: "
	L["BestCharacter"] = "Melhor Personagem: "
	L["GoldTime"] = "Tempo Ouro: "
	L["SilverTime"] = "Tempo Prata: "
	L["MuteVigorSound_Settings"] = "Silenciar Som de Vigor"
	L["MuteVigorSound_SettingsTT"] = "Alternar o som que é reproduzido quando a montaria de Pilotagem Aérea naturalmente ganha uma pilha de vigor."
	L["SpeedometerTheme"] = "Tema do velocímetro"
	L["SpeedometerThemeTT"] = "Personalize o tema do velocímetro."
	L["Algari"] = "Algari"
	L["Default"] = DEFAULT
	L["Minimalist"] = "Minimalista"
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	L["TimerunningStatistics"] = "Estatísticas de Corrida Temporal"
	L["SkyridingCurrencyGained"] = "%s de Montaria Celeste Obtido:"

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "Mostrar velocímetro"
	L["ToggleSpeedometerTT"] = "Ativa ou desativa a exibição do velocímetro."
	L["SpeedometerWidthName"] = "Largura do velocímetro"
	L["SpeedometerWidthTT"] = "Ajusta a largura da moldura do velocímetro."
	L["SpeedometerHeightName"] = "Altura do velocímetro"
	L["SpeedometerHeightTT"] = "Ajusta a altura da moldura do velocímetro."
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "É necessário fechar as configurações e pousar para que tenha efeito.\n\nIncompatível com a opção \"Vertigem de movimento\"."
	L["DynamicFOVNewTT"] = "Ativa o ajuste do campo de visão da câmera baseado no planar e na velocidade V.R.U.M.M."
	L["StaticChargeOffset"] = "Deslocamento da Carga Estática"
	L["StaticChargeSpacing"] = "Espaçamento da Carga Estática"
	L["StaticChargeSize"] = "Tamanho da Carga Estática"
	L["StaticChargeWidth"] = "Largura da Carga Estática"
	L["StaticChargeHeight"] = "Altura da Carga Estática"
	L["StaticChargeWidthTT"] = "Ajusta a largura das Cargas Estáticas."
	L["StaticChargeHeightTT"] = "Ajusta a altura das Cargas Estáticas."
	L["StaticChargeSpacingTT"] = "Ajusta o espaçamento das Cargas Estáticas."
	L["StaticChargeOffsetTT"] = "Ajusta o deslocamento das Cargas Estáticas."
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors
	L["SpeedometerBar_Slow_ColorPicker"] = "Cor: velocidade baixa"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "Escolha a cor para velocidades baixas."
	L["SpeedometerBar_Recharge_ColorPicker"] = "Cor: velocidade de recarga"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "Escolha a cor para velocidades que aceleram a recuperação do Vigor (buff 'Arrebatamento dos Céus')."
	L["SpeedometerBar_Over_ColorPicker"] = "Cor: velocidade acima do limite"
	L["SpeedometerBar_Over_ColorPickerTT"] = "Escolha a cor para velocidades acima do limite natural (marcador de 65%)."
	L["SpeedometerText_Slow_ColorPicker"] = "Cor do texto: velocidade baixa"
	L["SpeedometerText_Slow_ColorPickerTT"] = "Escolha a cor do texto ao exibir velocidades baixas."
	L["SpeedometerText_Recharge_ColorPicker"] = "Cor do texto: recarga acelerada"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "Escolha a cor do texto ao exibir velocidade com recarga acelerada."
	L["SpeedometerText_Over_ColorPicker"] = "Cor do texto: acima do limite"
	L["SpeedometerText_Over_ColorPickerTT"] = "Escolha a cor do texto ao exibir velocidade além do limite natural."
	L["SpeedometerCover_ColorPicker"] = "Cor da cobertura do velocímetro"
	L["SpeedometerCover_ColorPickerTT"] = "Escolha a cor da cobertura."
	L["SpeedometerTick_ColorPicker"] = "Cor dos marcadores"
	L["SpeedometerTick_ColorPickerTT"] = "Escolha a cor das linhas de 60% e 65%."
	L["SpeedometerTopper_ColorPicker"] = "Cor do topo"
	L["SpeedometerTopper_ColorPickerTT"] = "Escolha a cor da textura superior."
	L["SpeedometerFooter_ColorPicker"] = "Cor da base"
	L["SpeedometerFooter_ColorPickerTT"] = "Escolha a cor da textura inferior."
	L["SpeedometerBackground_ColorPicker"] = "Cor do fundo"
	L["SpeedometerBackground_ColorPickerTT"] = "Escolha a cor do fundo do velocímetro."
	L["SpeedometerSpark_ColorPicker"] = "Cor do brilho"
	L["SpeedometerSpark_ColorPickerTT"] = "Escolha a cor do brilho na borda da barra de progresso."

	-- Vigor Bar Settings
	L["VigorTheme"] = "Tema do Vigor"
	L["VigorThemeTT"] = "Personalize o tema da barra de Vigor."
	L["VigorPosXName"] = "Posição horizontal do Vigor"
	L["VigorPosXNameTT"] = "Ajusta a posição horizontal das barras de Vigor."
	L["VigorPosYName"] = "Posição vertical do Vigor"
	L["VigorPosYNameTT"] = "Ajusta a posição vertical da barra de Vigor."
	L["VigorBarWidthName"] = "Largura das cargas de Vigor"
	L["VigorBarWidthNameTT"] = "Ajusta a largura de cada carga."
	L["VigorBarHeightName"] = "Altura das cargas de Vigor"
	L["VigorBarHeightNameTT"] = "Ajusta a altura de cada carga."
	L["VigorBarSpacingName"] = "Espaçamento entre cargas"
	L["VigorBarSpacingNameTT"] = "Ajusta o espaço entre cada carga."
	L["VigorBarOrientationName"] = "Orientação da barra de Vigor"
	L["VigorBarOrientationNameTT"] = "Controla a orientação geral da barra."
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "Direção de crescimento"
	L["VigorBarDirectionNameTT"] = "Controla para onde as cargas crescem."
	L["Direction_DownRight"] = "De Cima para Baixo / Da Esquerda para a Direita"
	L["Direction_UpLeft"] = "De Baixo para Cima / Da Direita para a Esquerda"
	L["VigorWrapName"] = "Limite por linha"
	L["VigorWrapNameTT"] = "Define quantas cargas aparecem antes de quebrar linha/coluna."
	L["VigorBarFillDirectionName"] = "Direção de preenchimento"
	L["VigorBarFillDirectionNameTT"] = "Controla a direção em que cada carga é preenchida."
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "Espessura do brilho"
	L["VigorSparkThicknessNameTT"] = "Ajusta a espessura do brilho de recarga."
	L["ToggleFlashFullName"] = "Brilhar ao encher"
	L["ToggleFlashFullNameTT"] = "Ativa o efeito de brilho quando uma carga se completa."
	L["ToggleFlashProgressName"] = "Brilhar durante a recarga"
	L["ToggleFlashProgressNameTT"] = "Ativa o pulso de brilho durante a recarga."
	L["ModelThemeName"] = "Tema do modelo do Vigor"
	L["ModelThemeNameTT"] = "Altera o efeito visual do modelo de Vigor."
	L["SideArtStyleName"] = "Tema da arte lateral"
	L["SideArtStyleNameTT"] = "Altera o tema da arte lateral."
	L["SideArtPosX"] = "Posição horizontal da arte lateral"
	L["SideArtPosXTT"] = "Ajusta a posição horizontal da arte lateral."
	L["SideArtPosY"] = "Posição vertical da arte lateral"
	L["SideArtPosYTT"] = "Ajusta a posição vertical."
	L["SideArtRot"] = "Rotação da arte lateral"
	L["SideArtRotTT"] = "Ajusta a rotação."
	L["SideArtScale"] = "Escala da arte lateral"
	L["SideArtScaleTT"] = "Ajusta a escala das texturas laterais."
	L["DesaturatedOptionTT"] = "Algumas opções estão dessaturadas, permitindo que o seletor de cores as colore melhor. Opções não dessaturadas são melhor visualizadas com a cor branca (#FFFFFF)."

	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "Cor: carga cheia"
	L["VigorBar_Full_ColorPickerTT"] = "Escolha a cor para cargas completas."
	L["VigorBar_Empty_ColorPicker"] = "Cor: carga vazia"
	L["VigorBar_Empty_ColorPickerTT"] = "Escolha a cor para cargas vazias."
	L["VigorBar_Progress_ColorPicker"] = "Cor: recarregando"
	L["VigorBar_Progress_ColorPickerTT"] = "Escolha a cor para cargas sendo recarregadas."
	L["VigorBarCover_ColorPicker"] = "Cor da cobertura"
	L["VigorBarCover_ColorPickerTT"] = "Escolha a cor da cobertura."
	L["VigorBarBackground_ColorPicker"] = "Cor do fundo"
	L["VigorBarBackground_ColorPickerTT"] = "Escolha a cor do fundo."
	L["VigorBarSpark_ColorPicker"] = "Cor do brilho"
	L["VigorBarSpark_ColorPickerTT"] = "Escolha a cor do brilho na borda da carga."
	L["VigorBarFlash_ColorPicker"] = "Cor do efeito de brilho"
	L["VigorBarFlash_ColorPickerTT"] = "Escolha a cor do brilho ao completar ou recarregar."
	L["VigorBarDecor_ColorPicker"] = "Cor da decoração"
	L["VigorBarDecor_ColorPickerTT"] = "Escolha a cor da arte decorativa."

	-- Additional Toggles
	L["ToggleTopper"] = "Mostrar topo do velocímetro"
	L["ToggleTopperTT"] = "Mostra a textura superior."
	L["ToggleFooter"] = "Mostrar base do velocímetro"
	L["ToggleFooterTT"] = "Mostra a textura inferior."
	L["ToggleVigor"] = "Mostrar barras de Vigor"
	L["ToggleVigorTT"] = "Mostra as 6 barras de Vigor associadas às habilidades de impulso."
	
	-- Themes
	L["ThemeAlgari_Gold"] = "Algari - Dourado"
	L["ThemeAlgari_Bronze"] = "Algari - Bronze"
	L["ThemeAlgari_Dark"] = "Algari - Escuro"
	L["ThemeAlgari_Silver"] = "Algari - Prateado"
	L["ThemeDefault_Desaturated"] = "Padrão - Dessaturado"
	L["ThemeAlgari_Desaturated"] = "Algari - Dessaturado"
	L["ThemeGryphon_Desaturated"] = "Grifo - Dessaturado"
	L["ThemeWyvern_Desaturated"] = "Dracônico - Dessaturado"
	L["ThemeDragon_Desaturated"] = "Dragão - Dessaturado"

	-- Model Themes
	L["ModelTheme_Wind"] = "Vento"
	L["ModelTheme_Lightning"] = "Relâmpago"
	L["ModelTheme_FireForm"] = "Forma de Fogo"
	L["ModelTheme_ArcaneForm"] = "Forma Arcana"
	L["ModelTheme_FrostForm"] = "Forma de Gelo"
	L["ModelTheme_HolyForm"] = "Forma Sagrada"
	L["ModelTheme_NatureForm"] = "Forma da Natureza"
	L["ModelTheme_ShadowForm"] = "Forma Sombria"

	-- TOC translations
	L["DR_Title"] = "Cavaleiro do Dragão"
	L["DR_Notes"] = "Exibe um velocímetro emparelhado com a barra de vigor e algumas outras opções relacionadas à cavalgada de dragões."


-- Note that the EU Portuguese WoW client also
-- uses the Brazilian Portuguese locale code.
return end

if LOCALE == "ruRU" then
	-- Russian translations go here
	L["Vigor"] = "Энергия"
	L["Speedometer"] = "Спидометр"
	L["ToggleModelsName"] = "Показать модели энергии"
	L["ToggleModelsTT"] = "Отобразите эффект вращающейся модели на пузырьках энергии."
	L["SpeedPosPointName"] = "Положение спидометра"
	L["SpeedPosPointTT"] = "Регулирует место крепления спидометра относительно шкалы мощности."
	L["Top"] = "Вершина"
	L["Bottom"] = "Нижний"
	L["Left"] = "Левый"
	L["Right"] = "Верно"
	L["SpeedPosXName"] = "Горизонтальное положение спидометра"
	L["SpeedPosXTT"] = "Отрегулируйте горизонтальное положение спидометра."
	L["SpeedPosYName"] = "Вертикальное положение спидометра"
	L["SpeedPosYTT"] = "Отрегулируйте вертикальное положение спидометра."
	L["SpeedScaleName"] = "Шкала спидометра"
	L["SpeedScaleTT"] = "Отрегулируйте шкалу спидометра."
	L["Large"] = "Большой"
	L["Small"] = "Маленький"
	L["Units"] = "Текст единиц скорости" -- Changed in 11.2.7
	L["UnitsTT"] = "Измените единицы измерения, отображаемые на спидометре.\n(Механически 1 метр = 1 ярд)"
	L["UnitsColor"] = "Цвет текста единиц скорости" -- Changed in 11.2.7
	L["UnitYards"] = "ярдов/с"
	L["Yards"] = "Дворы"
	L["UnitMiles"] = "миль в час"
	L["Miles"] = "Мили"
	L["UnitMeters"] = "м/с"
	L["Meters"] = "Метры"
	L["UnitKilometers"] = "км/ч"
	L["Kilometers"] = "км"
	L["UnitPercent"] = "%"
	L["Percent"] = "Процент"
	L["SpeedTextScale"] = "Размер текста спидометра"
	L["SpeedTextScaleTT"] = "Отрегулируйте размер текста на спидометре."
	L["Version"] = "Версия %s"
	L["ResetAllSettings"] = "Сбросить все настройки Драконий Всадник"
	L["ResetAllSettingsTT"] = "Сбрасывает все настройки специально для этого аддона. Это будет включать пользовательские значения цвета."
	L["ResetAllSettingsConfirm"] = "Вы уверены, что хотите сбросить настройки DДраконий Всадник?"
	L["Low"] = "Низкий"
	L["High"] = "Высокий"
	L["ProgressBar"] = "Спидометр" -- Deprecated
	L["ProgressBarColor"] = "Цвет спидометра" -- Deprecated
	L["ColorPickerLowProgTT"] = "Выберите собственный цвет для значений низкой скорости спидометра. Это происходит, когда игрок не набирает сил." -- Deprecated
	L["ColorPickerMidProgTT"] = "Выберите собственный цвет для значений скорости энергии спидометра. Это происходит, когда игрок набирает силу в пределах стандартного диапазона скоростей." -- Deprecated
	L["ColorPickerHighProgTT"] = "Выберите собственный цвет для значений высокой скорости спидометра. Это происходит, когда игрок набирает силу, но его скорость выше стандартного диапазона." -- Deprecated
	L["ColorPickerLowTextTT"] = "Выберите пользовательский цвет для значений низкой скорости значения скорости. Это происходит, когда игрок не набирает сил." -- Deprecated
	L["ColorPickerMidTextTT"] = "Выберите пользовательский цвет для значений скорости силы значения скорости. Это происходит, когда игрок набирает силу в пределах стандартного диапазона скоростей." -- Deprecated
	L["ColorPickerHighTextTT"] = "Выберите пользовательский цвет для высокоскоростных значений значения скорости. Это происходит, когда игрок набирает силу, но его скорость выше стандартного диапазона." -- Deprecated
	L["DragonridingTalents"] = "Умения и улучшения Небесной езды" -- Changed in 11.2.7
	L["OpenDragonridingTalents"] = "Умения и улучшения Небесной езды" -- Changed in 11.2.7
	L["OpenDragonridingTalentsTT"] = "Открывает окно умений и улучшений Небесной езды." -- Changed in 11.2.7
	L["SideArtName"] = "Боковой арт"
	L["SideArtTT"] = "Переключите изображение по бокам главной панели Vigor."
	L["BugfixesName"] = "Исправление ошибок"
	L["BugfixesTT"] = "Экспериментальные попытки исправить ошибку, когда стандартные фреймы Blizzard не работают должным образом."
	L["BugfixHideVigor"] = "Сила Скрыть Энергию"
	L["BugfixHideVigorTT"] = "Принудительно скройте шкалу энергии при спешивании и снова отобразите ее при установке на высший пилотаж средства передвижения."
	L["FadeSpeedometer"] = "Затухание спидометра"
	L["FadeSpeedometerTT"] = "Включить затухание спидометра, когда он не скользит."
	L["ShowVigorTooltip"] = "Показать подсказку по Vigor"
	L["ShowVigorTooltipTT"] = "Переключить всплывающую подсказку, отображаемую на шкале энергии."
	L["FadeVigor"] = "Угасание энергии"
	L["FadeVigorTT"] = "Переключить затухание шкалы Энергии, когда она не скользит и при полной Энергии."
	L["LightningRush"] = "Показать сферы статического заряда" -- Changed in 11.2.7
	L["LightningRushTT"] = "Переключает сферы статического заряда, используемые способностью «Удар молнии»." -- Changed in 11.2.7
	L["DynamicFOV"] = "Динамический угол обзора"
	L["DynamicFOVTT"] = "Позволяет регулировать поле зрения камеры в зависимости от скорости планирования."
	L["Normal"] = "Нормальный"
	L["Advanced"] = "высокая сложность"
	L["Reverse"] = "обратный маршрут"
	L["Challenge"] = "испытание"
	L["ReverseChallenge"] = "обратный маршрут"
	L["Storm"] = "Буря"
	L["COMMAND_help"] = "помощь"
	L["COMMAND_journal"] = "журнал"
	L["COMMAND_listcommands"] = "Список команд:"
	L["COMMAND_dragonrider"] = "всадникдракона"
	L["DragonRider"] = "Драконий Всадник"
	L["RightClick_TT_Line"] = "Правый клик: Открыть настройки"
	L["LeftClick_TT_Line"] = "Левый клик: Открыть журнал"
	L["SlashCommands_TT_Line"] = "'/всадникдракона' для дополнительных команд"
	L["Score"] = "Счёт"
	L["Guide"] = "Руководство"
	L["Settings"] = "Настройки"
	L["ComingSoon"] = "Скоро"
	L["UseAccountScores"] = "Использовать Счета аккаунта"
	L["UseAccountScoresTT"] = "Это отобразит ваши лучшие результаты гонок аккаунта вместо результатов вашего персонажа. Результаты аккаунта обозначаются звездочкой (*)."
	L["PersonalBest"] = "Личный лучший: "
	L["AccountBest"] = "Лучший аккаунта: "
	L["BestCharacter"] = "Лучший персонаж: "
	L["GoldTime"] = "Золотое время: "
	L["SilverTime"] = "Серебряное время: "
	L["MuteVigorSound_Settings"] = "Выключить звук силы"
	L["MuteVigorSound_SettingsTT"] = "Переключить звук, который проигрывается, когда высший пилотаж естественным образом получает стопку силы."
	L["SpeedometerTheme"] = "Тема спидометра"
	L["SpeedometerThemeTT"] = "Настройте тему спидометра."
	L["Algari"] = "Алгари"
	L["Default"] = DEFAULT
	L["Minimalist"] = "Минималистичный"
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	L["TimerunningStatistics"] = "Статистика Хронобега"
	L["SkyridingCurrencyGained"] = "Получено %s за Небесную Езду:"

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "Показать спидометр"
	L["ToggleSpeedometerTT"] = "Включить или отключить отображение спидометра."
	L["SpeedometerWidthName"] = "Ширина спидометра"
	L["SpeedometerWidthTT"] = "Настроить ширину рамки спидометра."
	L["SpeedometerHeightName"] = "Высота спидометра"
	L["SpeedometerHeightTT"] = "Настроить высоту рамки спидометра."
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "Требуется закрыть настройки и приземлиться, чтобы изменения вступили в силу.\n\nНесовместимо с параметром «Укачивание»."
	L["DynamicFOVNewTT"] = "Включает настройку поля зрения камеры в зависимости от планирования и скорости РАЗГОН"
	L["StaticChargeOffset"] = "Смещение Статического разряда"
	L["StaticChargeSpacing"] = "Интервал Статического разряда"
	L["StaticChargeSize"] = "Размер Статического разряда"
	L["StaticChargeWidth"] = "Ширина Статического разряда"
	L["StaticChargeHeight"] = "Высота Статического разряда"
	L["StaticChargeWidthTT"] = "Настройка ширины Статических разрядов."
	L["StaticChargeHeightTT"] = "Настройка высоты Статических разрядов."
	L["StaticChargeSpacingTT"] = "Настройка интервала между Статическими разрядами."
	L["StaticChargeOffsetTT"] = "Настройка смещения Статических разрядов."
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors - replacing previous color picker text
	L["SpeedometerBar_Slow_ColorPicker"] = "Цвет: низкая скорость"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "Выберите цвет для низких значений скорости."
	L["SpeedometerBar_Recharge_ColorPicker"] = "Цвет: скорость восстановления"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "Выберите цвет для скорости, при которой бодрость восполняется быстрее (эффект «Азарт неба»)."
	L["SpeedometerBar_Over_ColorPicker"] = "Цвет: сверхскорость"
	L["SpeedometerBar_Over_ColorPickerTT"] = "Выберите цвет для скорости выше естественного максимума (отметка 65%)."
	L["SpeedometerText_Slow_ColorPicker"] = "Цвет текста: низкая скорость"
	L["SpeedometerText_Slow_ColorPickerTT"] = "Выберите цвет текста для низкой скорости."
	L["SpeedometerText_Recharge_ColorPicker"] = "Цвет текста: ускоренное восстановление"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "Выберите цвет текста для ускоренного восстановления бодрости."
	L["SpeedometerText_Over_ColorPicker"] = "Цвет текста: сверхскорость"
	L["SpeedometerText_Over_ColorPickerTT"] = "Выберите цвет текста для скорости выше естественного максимума."
	L["SpeedometerCover_ColorPicker"] = "Цвет покрытия спидометра"
	L["SpeedometerCover_ColorPickerTT"] = "Выберите цвет для покрытия."
	L["SpeedometerTick_ColorPicker"] = "Цвет отметок"
	L["SpeedometerTick_ColorPickerTT"] = "Выберите цвет для отметок 60% и 65%."
	L["SpeedometerTopper_ColorPicker"] = "Цвет верхнего элемента"
	L["SpeedometerTopper_ColorPickerTT"] = "Выберите цвет верхней декоративной части."
	L["SpeedometerFooter_ColorPicker"] = "Цвет нижнего элемента"
	L["SpeedometerFooter_ColorPickerTT"] = "Выберите цвет нижней декоративной части."
	L["SpeedometerBackground_ColorPicker"] = "Цвет фона"
	L["SpeedometerBackground_ColorPickerTT"] = "Выберите цвет фона спидометра."
	L["SpeedometerSpark_ColorPicker"] = "Цвет искры"
	L["SpeedometerSpark_ColorPickerTT"] = "Выберите цвет искры на краю текущего значения скорости."

	-- New Vigor Bar Settings
	L["VigorTheme"] = "Тема бодрости"
	L["VigorThemeTT"] = "Настроить тему панели бодрости."
	L["VigorPosXName"] = "Горизонтальная позиция панели бодрости"
	L["VigorPosXNameTT"] = "Настроить горизонтальное положение панелей бодрости."
	L["VigorPosYName"] = "Вертикальная позиция панели бодрости"
	L["VigorPosYNameTT"] = "Настроить вертикальное положение панели бодрости."
	L["VigorBarWidthName"] = "Ширина ячейки бодрости"
	L["VigorBarWidthNameTT"] = "Настроить ширину каждой ячейки бодрости."
	L["VigorBarHeightName"] = "Высота ячейки бодрости"
	L["VigorBarHeightNameTT"] = "Настроить высоту каждой ячейки."
	L["VigorBarSpacingName"] = "Расстояние между ячейками"
	L["VigorBarSpacingNameTT"] = "Настроить расстояние между ячейками бодрости."
	L["VigorBarOrientationName"] = "Ориентация панели бодрости"
	L["VigorBarOrientationNameTT"] = "Определяет ориентацию панели."
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "Направление роста панели"
	L["VigorBarDirectionNameTT"] = "Определяет направление расположения ячеек."
	L["Direction_DownRight"] = "Сверху вниз / Слева направо"
	L["Direction_UpLeft"] = "Снизу вверх / Справа налево"
	L["VigorWrapName"] = "Лимит элементов в строке"
	L["VigorWrapNameTT"] = "Определяет количество ячеек до переноса в новую строку/столбец."
	L["VigorBarFillDirectionName"] = "Направление заполнения"
	L["VigorBarFillDirectionNameTT"] = "Определяет направление заполнения каждой ячейки."
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "Толщина искры"
	L["VigorSparkThicknessNameTT"] = "Настроить толщину эффекта искры."
	L["ToggleFlashFullName"] = "Вспышка при полном заполнении"
	L["ToggleFlashFullNameTT"] = "Включить вспышку при полном заполнении ячейки."
	L["ToggleFlashProgressName"] = "Пульсация при восстановлении"
	L["ToggleFlashProgressNameTT"] = "Включить пульсацию во время восстановления бодрости."
	L["ModelThemeName"] = "Тема моделей бодрости"
	L["ModelThemeNameTT"] = "Изменяет визуальный эффект моделей бодрости."
	L["SideArtStyleName"] = "Тема бокового оформления"
	L["SideArtStyleNameTT"] = "Изменяет тему боковых декоративных элементов."
	L["SideArtPosX"] = "Горизонтальное положение боковой декорации"
	L["SideArtPosXTT"] = "Настроить горизонтальное положение."
	L["SideArtPosY"] = "Вертикальное положение боковой декорации"
	L["SideArtPosYTT"] = "Настроить вертикальное положение."
	L["SideArtRot"] = "Поворот боковой декорации"
	L["SideArtRotTT"] = "Настроить поворот декоративных текстур."
	L["SideArtScale"] = "Масштаб боковой декорации"
	L["SideArtScaleTT"] = "Настроить размер декоративных элементов."
	L["DesaturatedOptionTT"] = "Некоторые параметры обесцвечены, что позволяет палитре лучше применять цвет. Параметры без обесцвечивания лучше всего видеть при установке белого цвета (#FFFFFF)."

	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "Цвет полной ячейки"
	L["VigorBar_Full_ColorPickerTT"] = "Выберите цвет для полностью заполненной ячейки."
	L["VigorBar_Empty_ColorPicker"] = "Цвет пустой ячейки"
	L["VigorBar_Empty_ColorPickerTT"] = "Выберите цвет для пустой ячейки."
	L["VigorBar_Progress_ColorPicker"] = "Цвет восстанавливающейся ячейки"
	L["VigorBar_Progress_ColorPickerTT"] = "Выберите цвет для восстановительной фазы."
	L["VigorBarCover_ColorPicker"] = "Цвет покрытия ячейки"
	L["VigorBarCover_ColorPickerTT"] = "Выберите цвет покрытия."
	L["VigorBarBackground_ColorPicker"] = "Цвет фона"
	L["VigorBarBackground_ColorPickerTT"] = "Выберите цвет фона ячеек бодрости."
	L["VigorBarSpark_ColorPicker"] = "Цвет искры"
	L["VigorBarSpark_ColorPickerTT"] = "Выберите цвет искры на границе ячейки."
	L["VigorBarFlash_ColorPicker"] = "Цвет вспышки"
	L["VigorBarFlash_ColorPickerTT"] = "Определяет цвет вспышки при восстановлении или полном заполнении."
	L["VigorBarDecor_ColorPicker"] = "Цвет декоративных элементов"
	L["VigorBarDecor_ColorPickerTT"] = "Выберите цвет боковых декоративных элементов."

	-- Additional Toggles
	L["ToggleTopper"] = "Показать верхний элемент"
	L["ToggleTopperTT"] = "Показать верхнюю декоративную часть спидометра."
	L["ToggleFooter"] = "Показать нижний элемент"
	L["ToggleFooterTT"] = "Показать нижнюю декоративную часть спидометра."
	L["ToggleVigor"] = "Показать панель бодрости"
	L["ToggleVigorTT"] = "Показать 6 ячеек бодрости."
	
	-- Themes
	L["ThemeAlgari_Gold"] = "Алгари - Золотой"
	L["ThemeAlgari_Bronze"] = "Алгари - Бронзовый"
	L["ThemeAlgari_Dark"] = "Алгари - Тёмный"
	L["ThemeAlgari_Silver"] = "Алгари - Серебряный"
	L["ThemeDefault_Desaturated"] = "По умолчанию - Обесцвеченный"
	L["ThemeAlgari_Desaturated"] = "Алгари - Обесцвеченный"
	L["ThemeGryphon_Desaturated"] = "Грифон - Обесцвеченный"
	L["ThemeWyvern_Desaturated"] = "Виверна - Обесцвеченная"
	L["ThemeDragon_Desaturated"] = "Дракон - Обесцвеченный"

	-- Model Themes
	L["ModelTheme_Wind"] = "Ветер"
	L["ModelTheme_Lightning"] = "Молния"
	L["ModelTheme_FireForm"] = "Облик Огня"
	L["ModelTheme_ArcaneForm"] = "Чародейский Облик"
	L["ModelTheme_FrostForm"] = "Облик Льда"
	L["ModelTheme_HolyForm"] = "Священный Облик"
	L["ModelTheme_NatureForm"] = "Природный Облик"
	L["ModelTheme_ShadowForm"] = "Облик Тени"

	-- TOC translations
	L["DR_Title"] = "Драконий Всадник"
	L["DR_Notes"] = "Отображает спидометр в паре с полосой энергии и некоторыми другими параметрами, связанными с верховой ездой на драконах."


return end

if LOCALE == "koKR" then
	-- Korean translations go here
	L["Vigor"] = "활기"
	L["Speedometer"] = "속도계"
	L["ToggleModelsName"] = "활기 모델 표시"
	L["ToggleModelsTT"] = "활력 거품에 소용돌이 모델 효과를 표시합니다."
	L["SpeedPosPointName"] = "속도계 위치"
	L["SpeedPosPointTT"] = "활력 막대를 기준으로 속도계가 고정되는 위치를 조정합니다."
	L["Top"] = "맨 위"
	L["Bottom"] = "맨 아래"
	L["Left"] = "왼쪽"
	L["Right"] = "오른쪽"
	L["SpeedPosXName"] = "속도계 수평 위치"
	L["SpeedPosXTT"] = "속도계의 수평 위치를 조정합니다."
	L["SpeedPosYName"] = "속도계 수직 위치"
	L["SpeedPosYTT"] = "속도계의 수직 위치를 조정하십시오."
	L["SpeedScaleName"] = "속도계 눈금"
	L["SpeedScaleTT"] = "속도계의 눈금을 조정하십시오."
	L["Large"] = "크기가 큰"
	L["Small"] = "작은"
	L["Units"] = "속도 단위 텍스트" -- Changed in 11.2.7
	L["UnitsTT"] = "속도계에 표시되는 단위를 변경합니다.\n(기계적으로 1미터 = 1야드)"
	L["UnitsColor"] = "속도 단위 텍스트 색상" -- Changed in 11.2.7
	L["UnitYards"] = "야드/초"
	L["Yards"] = "야드"
	L["UnitMiles"] = "시간 당 마일"
	L["Miles"] = "마일"
	L["UnitMeters"] = "m/s"
	L["Meters"] = "미터"
	L["UnitKilometers"] = "km/h"
	L["Kilometers"] = "킬로미터"
	L["UnitPercent"] = "%"
	L["Percent"] = "백분율"
	L["SpeedTextScale"] = "속도계 텍스트 크기"
	L["SpeedTextScaleTT"] = "속도계의 텍스트 크기를 조정합니다."
	L["Version"] = "버전 %s"
	L["ResetAllSettings"] = "모든 드래곤 라이더 설정 재설정"
	L["ResetAllSettingsTT"] = "이 애드온에 대한 모든 설정을 재설정합니다. 여기에는 사용자 정의 색상 값이 포함됩니다."
	L["ResetAllSettingsConfirm"] = "Dragon Rider의 설정을 재설정하시겠습니까?"
	L["Low"] = "낮은"
	L["High"] = "높은"
	L["ProgressBar"] = "속도계" -- Deprecated
	L["ProgressBarColor"] = "속도계 색상" -- Deprecated
	L["ColorPickerLowProgTT"] = "속도계의 저속 값에 대한 사용자 정의 색상을 선택하십시오. 이것은 플레이어가 활력을 얻지 못할 때 발생합니다." -- Deprecated
	L["ColorPickerMidProgTT"] = "속도계의 활력 속도 값에 대한 사용자 정의 색상을 선택하십시오. 이것은 플레이어가 표준 a 속도 범위 내에서 활력을 얻고 있을 때 발생합니다." -- Deprecated
	L["ColorPickerHighProgTT"] = "속도계의 고속 값에 대한 사용자 정의 색상을 선택하십시오. 이것은 플레이어가 활력을 얻고 있지만 표준 속도 범위를 초과할 때 발생합니다." -- Deprecated
	L["ColorPickerLowTextTT"] = "속도 값의 저속 값에 대한 사용자 지정 색상을 선택합니다. 이것은 플레이어가 활력을 얻지 못할 때 발생합니다." -- Deprecated
	L["ColorPickerMidTextTT"] = "속도 값의 활력 속도 값에 대한 사용자 정의 색상을 선택하십시오. 이것은 플레이어가 표준 a 속도 범위 내에서 활력을 얻고 있을 때 발생합니다." -- Deprecated
	L["ColorPickerHighTextTT"] = "속도 값의 고속 값에 대한 사용자 지정 색상을 선택합니다. 이것은 플레이어가 활력을 얻고 있지만 표준 속도 범위를 초과할 때 발생합니다." -- Deprecated
	L["DragonridingTalents"] = "드래곤라이딩 특성" -- Changed in 11.2.7
	L["OpenDragonridingTalents"] = "드래곤라이딩 특성 창 열기" -- Changed in 11.2.7
	L["OpenDragonridingTalentsTT"] = "드래곤라이딩 특성 창을 엽니다." -- Changed in 11.2.7
	L["SideArtName"] = "사이드 아트"
	L["SideArtTT"] = "메인 Vigor 바의 측면에 있는 아트를 전환합니다."
	L["BugfixesName"] = "버그 수정"
	L["BugfixesTT"] = "기본 블리자드 프레임이 의도한 대로 작동하지 않는 경우를 위한 실험적인 버그 수정 시도입니다."
	L["BugfixHideVigor"] = "포스 하이드 활력"
	L["BugfixHideVigorTT"] = "분리되면 활력 바를 강제로 숨기고 하늘비행 장착하면 다시 표시됩니다."
	L["FadeSpeedometer"] = "속도계 페이드"
	L["FadeSpeedometerTT"] = "글라이딩하지 않을 때 속도계 페이딩을 전환합니다."
	L["ShowVigorTooltip"] = "활력 도구 설명 표시"
	L["ShowVigorTooltipTT"] = "활력 막대에 표시되는 도구 설명을 전환합니다."
	L["FadeVigor"] = "활력이 희미해짐"
	L["FadeVigorTT"] = "활공하지 않을 때와 활력이 최대일 때 활력 바 페이드를 전환합니다."
	L["LightningRush"] = "정전기 구체 표시" -- Changed in 11.2.7
	L["LightningRushTT"] = "번개 돌진 기술에서 사용되는 정전기 구슬을 전환합니다." -- Changed in 11.2.7
	L["DynamicFOV"] = "동적 시야"
	L["DynamicFOVTT"] = "글라이딩 속도에 따라 카메라 시야를 조정할 수 있습니다."
	L["Normal"] = "정상"
	L["Advanced"] = "고급의"
	L["Reverse"] = "뒤집다"
	L["Challenge"] = "도전"
	L["ReverseChallenge"] = "역방향 도전"
	L["Storm"] = "폭풍"
	L["COMMAND_help"] = "도움말"
	L["COMMAND_journal"] = "일지"
	L["COMMAND_listcommands"] = "명령어 목록:"
	L["COMMAND_dragonrider"] = "드래곤라이더"
	L["DragonRider"] = "드래곤 라이더"
	L["RightClick_TT_Line"] = "우클릭: 설정 열기"
	L["LeftClick_TT_Line"] = "좌클릭: 일지 열기"
	L["SlashCommands_TT_Line"] = "'/드래곤라이더' 추가 명령어"
	L["Score"] = "점수"
	L["Guide"] = "가이드"
	L["Settings"] = "설정"
	L["ComingSoon"] = "곧 출시 예정"
	L["UseAccountScores"] = "계정 점수 사용"
	L["UseAccountScoresTT"] = "이는 캐릭터의 점수 대신 상위 계정 레이스 점수를 표시합니다. 계정 점수는 별표 (*)로 표시됩니다."
	L["PersonalBest"] = "개인 최고: "
	L["AccountBest"] = "계정 최고: "
	L["BestCharacter"] = "최고 캐릭터: "
	L["GoldTime"] = "금 시간: "
	L["SilverTime"] = "은 시간: "
	L["MuteVigorSound_Settings"] = "체력 사운드 음소거"
	L["MuteVigorSound_SettingsTT"] = "하늘비행 체력 스택을 자연적으로 얻을 때 재생되는 소리를 토글합니다."
	L["SpeedometerTheme"] = "속도계 테마"
	L["SpeedometerThemeTT"] = "속도계 테마를 사용자 정의합니다."
	L["Algari"] = "알가리"
	L["Default"] = DEFAULT
	L["Minimalist"] = "미니멀리스트"
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	L["TimerunningStatistics"] = "시간 달리기 통계"
	L["SkyridingCurrencyGained"] = "스카이라이딩 %s 획득:"

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "속도계 표시"
	L["ToggleSpeedometerTT"] = "속도계 표시를 켜거나 끕니다."
	L["SpeedometerWidthName"] = "속도계 너비"
	L["SpeedometerWidthTT"] = "속도계 프레임 너비를 설정합니다."
	L["SpeedometerHeightName"] = "속도계 높이"
	L["SpeedometerHeightTT"] = "속도계 프레임 높이를 설정합니다."
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "효과를 적용하려면 설정을 닫고 착지해야 합니다.\n\n\"멀미 방지\" 설정과 호환되지 않습니다."
	L["DynamicFOVNewTT"] = "활공 및 고.속.주.행 속도에 따라 카메라 시야각을 조정합니다."
	L["StaticChargeOffset"] = "전하 충전 위치"
	L["StaticChargeSpacing"] = "전하 충전 간격"
	L["StaticChargeSize"] = "전하 충전 크기"
	L["StaticChargeWidth"] = "전하 충전 너비"
	L["StaticChargeHeight"] = "전하 충전 높이"
	L["StaticChargeWidthTT"] = "전하 충전의 너비를 조정합니다."
	L["StaticChargeHeightTT"] = "전하 충전의 높이를 조정합니다."
	L["StaticChargeSpacingTT"] = "전하 충전 간격을 조정합니다."
	L["StaticChargeOffsetTT"] = "전하 충전 위치를 조정합니다."
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors - replacing previous color picker text
	L["SpeedometerBar_Slow_ColorPicker"] = "느린 속도 색상"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "느린 속도 값의 색상을 선택합니다."
	L["SpeedometerBar_Recharge_ColorPicker"] = "재충전 속도 색상"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "재충전 속도가 증가할 때 색상을 선택합니다 ('하늘의 격정' 효과)."
	L["SpeedometerBar_Over_ColorPicker"] = "초과 속도 색상"
	L["SpeedometerBar_Over_ColorPickerTT"] = "자연 최대치를 초과한 속도 색상을 선택합니다 (65% 표시)."
	L["SpeedometerText_Slow_ColorPicker"] = "느린 속도 텍스트 색상"
	L["SpeedometerText_Slow_ColorPickerTT"] = "느린 속도 텍스트 색상을 선택합니다."
	L["SpeedometerText_Recharge_ColorPicker"] = "재충전 속도 텍스트 색상"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "재충전 속도 텍스트 색상을 선택합니다."
	L["SpeedometerText_Over_ColorPicker"] = "초과 속도 텍스트 색상"
	L["SpeedometerText_Over_ColorPickerTT"] = "초과 속도 텍스트 색상을 선택합니다."
	L["SpeedometerCover_ColorPicker"] = "속도계 커버 색상"
	L["SpeedometerCover_ColorPickerTT"] = "커버 색상을 선택합니다."
	L["SpeedometerTick_ColorPicker"] = "표시선 색상"
	L["SpeedometerTick_ColorPickerTT"] = "60% 및 65% 표시선 색상을 선택합니다."
	L["SpeedometerTopper_ColorPicker"] = "상단 장식 색상"
	L["SpeedometerTopper_ColorPickerTT"] = "상단 장식 색상을 선택합니다."
	L["SpeedometerFooter_ColorPicker"] = "하단 장식 색상"
	L["SpeedometerFooter_ColorPickerTT"] = "하단 장식 색상을 선택합니다."
	L["SpeedometerBackground_ColorPicker"] = "배경 색상"
	L["SpeedometerBackground_ColorPickerTT"] = "속도계 배경 색상을 선택합니다."
	L["SpeedometerSpark_ColorPicker"] = "불꽃 색상"
	L["SpeedometerSpark_ColorPickerTT"] = "속도계 끝 불꽃 색상을 선택합니다."

	-- New Vigor Bar Settings
	L["VigorTheme"] = "활력 테마"
	L["VigorThemeTT"] = "활력 패널 테마를 설정합니다."
	L["VigorPosXName"] = "활력 패널 X 위치"
	L["VigorPosXNameTT"] = "활력 패널의 가로 위치를 설정합니다."
	L["VigorPosYName"] = "활력 패널 Y 위치"
	L["VigorPosYNameTT"] = "활력 패널의 세로 위치를 설정합니다."
	L["VigorBarWidthName"] = "활력 칸 너비"
	L["VigorBarWidthNameTT"] = "활력 칸 너비를 설정합니다."
	L["VigorBarHeightName"] = "활력 칸 높이"
	L["VigorBarHeightNameTT"] = "활력 칸 높이를 설정합니다."
	L["VigorBarSpacingName"] = "칸 간 간격"
	L["VigorBarSpacingNameTT"] = "활력 칸 사이 간격을 설정합니다."
	L["VigorBarOrientationName"] = "활력 패널 방향"
	L["VigorBarOrientationNameTT"] = "패널의 전체 방향을 설정합니다."
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "칸 배치 방향"
	L["VigorBarDirectionNameTT"] = "칸 배치 방향을 설정합니다."
	L["Direction_DownRight"] = "위에서 아래로 / 왼쪽에서 오른쪽으로"
	L["Direction_UpLeft"] = "아래에서 위로 / 오른쪽에서 왼쪽으로"
	L["VigorWrapName"] = "줄/열당 칸 수"
	L["VigorWrapNameTT"] = "한 줄(또는 열)에 표시할 칸 수를 설정합니다."
	L["VigorBarFillDirectionName"] = "칸 채우기 방향"
	L["VigorBarFillDirectionNameTT"] = "칸 내부 채우기 방향을 설정합니다."
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "불꽃 두께"
	L["VigorSparkThicknessNameTT"] = "활력 칸 불꽃 두께를 설정합니다."
	L["ToggleFlashFullName"] = "완전 충전 시 깜박임"
	L["ToggleFlashFullNameTT"] = "칸이 완전히 찼을 때 깜박임을 활성화합니다."
	L["ToggleFlashProgressName"] = "회복 시 펄스 효과"
	L["ToggleFlashProgressNameTT"] = "회복 중인 칸에 펄스 효과를 활성화합니다."
	L["ModelThemeName"] = "모델 테마"
	L["ModelThemeNameTT"] = "활력 모델 테마를 변경합니다."
	L["SideArtStyleName"] = "측면 장식 테마"
	L["SideArtStyleNameTT"] = "측면 장식 스타일을 변경합니다."
	L["SideArtPosX"] = "측면 장식 X 위치"
	L["SideArtPosXTT"] = "측면 장식의 가로 위치를 설정합니다."
	L["SideArtPosY"] = "측면 장식 Y 위치"
	L["SideArtPosYTT"] = "측면 장식의 세로 위치를 설정합니다."
	L["SideArtRot"] = "측면 장식 회전"
	L["SideArtRotTT"] = "측면 장식 회전을 설정합니다."
	L["SideArtScale"] = "측면 장식 크기"
	L["SideArtScaleTT"] = "측면 장식 크기를 설정합니다."
	L["DesaturatedOptionTT"] = "일부 옵션은 채도가 낮춰져 있어 색상 선택기로 더 잘 색상을 적용할 수 있습니다. 채도가 낮춰지지 않은 옵션은 색상 선택기를 흰색(#FFFFFF)으로 설정했을 때 가장 잘 보입니다."

	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "완전 칸 색상"
	L["VigorBar_Full_ColorPickerTT"] = "완전히 찬 칸 색상을 선택합니다."
	L["VigorBar_Empty_ColorPicker"] = "빈 칸 색상"
	L["VigorBar_Empty_ColorPickerTT"] = "빈 칸 색상을 선택합니다."
	L["VigorBar_Progress_ColorPicker"] = "회복 칸 색상"
	L["VigorBar_Progress_ColorPickerTT"] = "회복 중인 칸 색상을 선택합니다."
	L["VigorBarCover_ColorPicker"] = "칸 커버 색상"
	L["VigorBarCover_ColorPickerTT"] = "칸 커버 색상을 선택합니다."
	L["VigorBarBackground_ColorPicker"] = "배경 색상"
	L["VigorBarBackground_ColorPickerTT"] = "활력 칸 배경 색상을 선택합니다."
	L["VigorBarSpark_ColorPicker"] = "불꽃 색상"
	L["VigorBarSpark_ColorPickerTT"] = "활력 칸 불꽃 색상을 선택합니다."
	L["VigorBarFlash_ColorPicker"] = "깜박임 색상"
	L["VigorBarFlash_ColorPickerTT"] = "회복 또는 완전 충전 시 깜박임 색상을 선택합니다."
	L["VigorBarDecor_ColorPicker"] = "장식 색상"
	L["VigorBarDecor_ColorPickerTT"] = "측면 장식 색상을 선택합니다."

	-- Additional Toggles
	L["ToggleTopper"] = "상단 장식 표시"
	L["ToggleTopperTT"] = "속도계 상단 장식을 표시합니다."
	L["ToggleFooter"] = "하단 장식 표시"
	L["ToggleFooterTT"] = "속도계 하단 장식을 표시합니다."
	L["ToggleVigor"] = "활력 패널 표시"
	L["ToggleVigorTT"] = "6칸 활력 패널을 표시합니다."
	
	-- Themes
	L["ThemeAlgari_Gold"] = "알가리 - 골드"
	L["ThemeAlgari_Bronze"] = "알가리 - 브론즈"
	L["ThemeAlgari_Dark"] = "알가리 - 다크"
	L["ThemeAlgari_Silver"] = "알가리 - 실버"
	L["ThemeDefault_Desaturated"] = "기본값 - 탈채색"
	L["ThemeAlgari_Desaturated"] = "알가리 - 탈채색"
	L["ThemeGryphon_Desaturated"] = "그리폰 - 탈채색"
	L["ThemeWyvern_Desaturated"] = "와이번 - 탈채색"
	L["ThemeDragon_Desaturated"] = "드래곤 - 탈채색"

	-- Model Themes
	L["ModelTheme_Wind"] = "바람"
	L["ModelTheme_Lightning"] = "번개"
	L["ModelTheme_FireForm"] = "불의 형상"
	L["ModelTheme_ArcaneForm"] = "비전 형상"
	L["ModelTheme_FrostForm"] = "서리 형상"
	L["ModelTheme_HolyForm"] = "신성 형상"
	L["ModelTheme_NatureForm"] = "자연 형상"
	L["ModelTheme_ShadowForm"] = "암흑 형상"

	-- TOC translations
	L["DR_Title"] = "드래곤 라이더"
	L["DR_Notes"] = "활력 막대 및 기타 드래곤 라이딩 관련 옵션과 페어링된 속도계를 표시합니다."


return end

if LOCALE == "zhCN" then
	-- Simplified Chinese translations go here
	-- Provided by 枫聖御雷 (https://legacy.curseforge.com/wow/addons/dragon-rider#c33)
	L["Vigor"] = "精力"
	L["Speedometer"] = "速度计"
	L["ToggleModelsName"] = "显示精力模型"
	L["ToggleModelsTT"] = "显示精力泡泡上的旋转模型效果。"
	L["SpeedPosPointName"] = "速度计位置"
	L["SpeedPosPointTT"] = "调整速度计相对于精力条的固定位置。"
	L["Top"] = "顶部"
	L["Bottom"] = "底部"
	L["Left"] = "左边"
	L["Right"] = "右边"
	L["SpeedPosXName"] = "速度计水平位置"
	L["SpeedPosXTT"] = "调整速度计的水平位置。"
	L["SpeedPosYName"] = "速度计垂直位置"
	L["SpeedPosYTT"] = "调整速度计的垂直位置。"
	L["SpeedScaleName"] = "速度计刻度"
	L["SpeedScaleTT"] = "调整速度计的刻度。"
	L["Large"] = "大的"
	L["Small"] = "小的"
	L["Units"] = "速度单位文字" -- Changed in 11.2.7
	L["UnitsTT"] = "更改速度计上显示的单位。\n（机械上 1 米 = 1 码）"
	L["UnitsColor"] = "速度单位文字颜色" -- Changed in 11.2.7
	L["UnitYards"] = "码/秒"
	L["Yards"] = "码数"
	L["UnitMiles"] = "英里/小时"
	L["Miles"] = "英里"
	L["UnitMeters"] = "米/秒"
	L["Meters"] = "米"
	L["UnitKilometers"] = "公里/小时"
	L["Kilometers"] = "公里"
	L["UnitPercent"] = "%"
	L["Percent"] = "百分比"
	L["SpeedTextScale"] = "速度计文字大小"
	L["SpeedTextScaleTT"] = "调整速度计上文字的大小。"
	L["Version"] = "版本 %s"
	L["ResetAllSettings"] = "重置所有龙骑士设置"
	L["ResetAllSettingsTT"] = "专门为此插件重置所有设置。 这将包括自定义颜色值。"
	L["ResetAllSettingsConfirm"] = "您确定要重置《龙骑士》的设置吗？"
	L["Low"] = "低"
	L["High"] = "高"
	L["ProgressBar"] = "速度计" -- Deprecated
	L["ProgressBarColor"] = "速度计颜色" -- Deprecated
	L["ColorPickerLowProgTT"] = "为速度计的低速值选择自定义颜色。 当玩家没有获得任何精力时就会发生这种情况。" -- Deprecated
	L["ColorPickerMidProgTT"] = "为速度计的精力速度值标准时选择自定义颜色。 当玩家在标准速度范围内获得精力时，就会发生这种情况。" -- Deprecated
	L["ColorPickerHighProgTT"] = "为速度计的高速值选择自定义颜色。 当玩家精力充沛但速度高于标准速度范围时，就会发生这种情况。" -- Deprecated
	L["ColorPickerLowTextTT"] = "为速度计的低速度值选择自定义颜色。 当玩家没有获得任何精力时就会发生这种情况。" -- Deprecated
	L["ColorPickerMidTextTT"] = "为速度计的精力速度值选择自定义颜色。 当玩家在标准速度范围内获得精力时，就会发生这种情况。" -- Deprecated
	L["ColorPickerHighTextTT"] = "为速度计的高速值选择自定义颜色。 当玩家精力充沛但速度高于标准速度范围时，就会发生这种情况。" -- Deprecated
	L["DragonridingTalents"] = "龙骑天赋" -- translated 11.0 -- Changed in 11.2.7
	L["OpenDragonridingTalents"] = "打开龙骑天赋窗口" -- translated 11.0 -- Changed in 11.2.7
	L["OpenDragonridingTalentsTT"] = "打开龙骑天赋窗口。" -- translated 11.0 -- Changed in 11.2.7
	L["SideArtName"] = "侧面美化"
	L["SideArtTT"] = "切换主精力条两侧的美化。"
	L["BugfixesName"] = "Bug修复"
	L["BugfixesTT"] = "当默认暴雪框架未按预期工作时尝试进行实验性错误修复。"
	L["BugfixHideVigor"] = "强制隐藏精力条"
	L["BugfixHideVigorTT"] = "下坐骑时强制隐藏精力条，骑上驭空术飞行坐骑时重新显示。" -- translated 11.0
	L["FadeSpeedometer"] = "淡出速度计"
	L["FadeSpeedometerTT"] = "在不滑行时切换速度计的淡出。"
	L["ShowVigorTooltip"] = "显示精力条上鼠标提示"
	L["ShowVigorTooltipTT"] = "切换精力条上鼠标提示的显示。"
	L["FadeVigor"] = "淡出精力条"
	L["FadeVigorTT"] = "在不滑翔和充满精力时切换精力条的淡出。"
	L["LightningRush"] = "闪电冲击" -- Changed in 11.2.7
	L["LightningRushTT"] = "显示技能“闪电冲击”的静电充能球体。" -- Changed in 11.2.7
	L["DynamicFOV"] = "动态视野"
	L["DynamicFOVTT"] = "能够根据飞行速度调整镜头视野。"
	L["Normal"] = "普通" -- translated (https://legacy.curseforge.com/wow/addons/dragon-rider#c43)
	L["Advanced"] = "进阶" -- translated
	L["Reverse"] = "反向" -- translated
	L["Challenge"] = "挑战" -- translated
	L["ReverseChallenge"] = "反向挑战" -- translated
	L["Storm"] = "风暴之速" -- translated
	L["COMMAND_help"] = "帮助"
	L["COMMAND_journal"] = "日志"
	L["COMMAND_listcommands"] = "命令列表:"
	L["COMMAND_dragonrider"] = "龙骑士"
	L["DragonRider"] = "龙骑手"
	L["RightClick_TT_Line"] = "右键点击：打开设置"
	L["LeftClick_TT_Line"] = "左键点击：打开日志"
	L["SlashCommands_TT_Line"] = "'/龙骑士' 以获取更多命令"
	L["Score"] = "得分"
	L["Guide"] = "指南"
	L["Settings"] = "设置"
	L["ComingSoon"] = "即将推出"
	L["UseAccountScores"] = "使用账号分数" -- translated
	L["UseAccountScoresTT"] = "这将显示您账号中最高的得分，而不是您当前角色的得分。账号得分用星号 (*) 表示。" -- translated
	L["PersonalBest"] = "个人最佳: "
	L["AccountBest"] = "账号最佳: " -- translated
	L["BestCharacter"] = "最佳角色: "
	L["GoldTime"] = "金牌时间: "
	L["SilverTime"] = "银牌时间: "
	L["MuteVigorSound_Settings"] = "静音精力音效" -- translated
	L["MuteVigorSound_SettingsTT"] = "切换驭空术坐骑获得精力时播放的声音。"  -- translated 11.0
	L["SpeedometerTheme"] = "速度计主题"
	L["SpeedometerThemeTT"] = "自定义速度计主题。"
	L["Algari"] = "阿加驭雷者"
	L["Default"] = DEFAULT
	L["Minimalist"] = "简单" -- (last updated https://github.com/nanjuekaien1/DragonRider-zhCN/blob/main/zhCN.lua)
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	--non-official translations
	L["TimerunningStatistics"] = "时光奔跑统计"
	L["SkyridingCurrencyGained"] = "获得天空骑行 %s："

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "显示速度表"
	L["ToggleSpeedometerTT"] = "切换显示速度表。"
	L["SpeedometerWidthName"] = "速度表宽度"
	L["SpeedometerWidthTT"] = "设置速度表框架宽度。"
	L["SpeedometerHeightName"] = "速度表高度"
	L["SpeedometerHeightTT"] = "设置速度表框架高度。"
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "需要关闭设置并着陆后才能生效。\n\n与“动态眩晕”选项不兼容."
	L["DynamicFOVNewTT"] = "根据滑翔和 D.R.I.V.E. 速度调整相机视野。"
	L["StaticChargeOffset"] = "静电充能偏移"
	L["StaticChargeSpacing"] = "静电充能间距"
	L["StaticChargeSize"] = "静电充能大小"
	L["StaticChargeWidth"] = "静电充能宽度"
	L["StaticChargeHeight"] = "静电充能高度"
	L["StaticChargeWidthTT"] = "调整静电充能的宽度。"
	L["StaticChargeHeightTT"] = "调整静电充能的高度。"
	L["StaticChargeSpacingTT"] = "调整静电充能的间距。"
	L["StaticChargeOffsetTT"] = "调整静电充能的偏移。"
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors - replacing previous color picker text
	L["SpeedometerBar_Slow_ColorPicker"] = "慢速颜色"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "选择慢速值的颜色。"
	L["SpeedometerBar_Recharge_ColorPicker"] = "充能颜色"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "选择充能速度增加时的颜色（“天雷之力”效果）。"
	L["SpeedometerBar_Over_ColorPicker"] = "极速颜色"
	L["SpeedometerBar_Over_ColorPickerTT"] = "选择超过自然最大值的颜色（65%显示）。"
	L["SpeedometerText_Slow_ColorPicker"] = "慢速文字颜色"
	L["SpeedometerText_Slow_ColorPickerTT"] = "选择慢速文字的颜色。"
	L["SpeedometerText_Recharge_ColorPicker"] = "充能文字颜色"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "选择充能文字的颜色。"
	L["SpeedometerText_Over_ColorPicker"] = "极速文字颜色"
	L["SpeedometerText_Over_ColorPickerTT"] = "选择极速文字的颜色。"
	L["SpeedometerCover_ColorPicker"] = "速度表覆盖颜色"
	L["SpeedometerCover_ColorPickerTT"] = "选择覆盖颜色。"
	L["SpeedometerTick_ColorPicker"] = "刻度线颜色"
	L["SpeedometerTick_ColorPickerTT"] = "选择60%和65%刻度线颜色。"
	L["SpeedometerTopper_ColorPicker"] = "顶部装饰颜色"
	L["SpeedometerTopper_ColorPickerTT"] = "选择顶部装饰颜色。"
	L["SpeedometerFooter_ColorPicker"] = "底部装饰颜色"
	L["SpeedometerFooter_ColorPickerTT"] = "选择底部装饰颜色。"
	L["SpeedometerBackground_ColorPicker"] = "背景颜色"
	L["SpeedometerBackground_ColorPickerTT"] = "选择速度表背景颜色。"
	L["SpeedometerSpark_ColorPicker"] = "火花颜色"
	L["SpeedometerSpark_ColorPickerTT"] = "选择速度表末端火花颜色。"

	-- New Vigor Bar Settings
	L["VigorTheme"] = "活力主题"
	L["VigorThemeTT"] = "设置活力面板主题。"
	L["VigorPosXName"] = "活力面板X轴位置"
	L["VigorPosXNameTT"] = "设置活力面板水平位置。"
	L["VigorPosYName"] = "活力面板Y轴位置"
	L["VigorPosYNameTT"] = "设置活力面板垂直位置。"
	L["VigorBarWidthName"] = "活力格宽度"
	L["VigorBarWidthNameTT"] = "设置每个活力格的宽度。"
	L["VigorBarHeightName"] = "活力格高度"
	L["VigorBarHeightNameTT"] = "设置每个活力格的高度。"
	L["VigorBarSpacingName"] = "格间距"
	L["VigorBarSpacingNameTT"] = "设置活力格之间的间距。"
	L["VigorBarOrientationName"] = "活力面板方向"
	L["VigorBarOrientationNameTT"] = "设置面板整体方向。"
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "格子排列方向"
	L["VigorBarDirectionNameTT"] = "设置活力格排列方向。"
	L["Direction_DownRight"] = "从上到下 / 从左到右"
	L["Direction_UpLeft"] = "从下到上 / 从右到左"
	L["VigorWrapName"] = "每行/列格数"
	L["VigorWrapNameTT"] = "设置每行或每列显示的格数。"
	L["VigorBarFillDirectionName"] = "格填充方向"
	L["VigorBarFillDirectionNameTT"] = "设置格内部填充方向。"
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "火花厚度"
	L["VigorSparkThicknessNameTT"] = "设置活力格火花厚度。"
	L["ToggleFlashFullName"] = "满格闪烁"
	L["ToggleFlashFullNameTT"] = "格满时启用闪烁。"
	L["ToggleFlashProgressName"] = "恢复格脉动"
	L["ToggleFlashProgressNameTT"] = "格恢复中时启用脉动效果。"
	L["ModelThemeName"] = "模型主题"
	L["ModelThemeNameTT"] = "更改活力模型主题。"
	L["SideArtStyleName"] = "侧边装饰主题"
	L["SideArtStyleNameTT"] = "更改侧边装饰风格。"
	L["SideArtPosX"] = "侧边装饰X轴位置"
	L["SideArtPosXTT"] = "设置侧边装饰水平位置。"
	L["SideArtPosY"] = "侧边装饰Y轴位置"
	L["SideArtPosYTT"] = "设置侧边装饰垂直位置。"
	L["SideArtRot"] = "侧边装饰旋转"
	L["SideArtRotTT"] = "设置侧边装饰旋转角度。"
	L["SideArtScale"] = "侧边装饰缩放"
	L["SideArtScaleTT"] = "设置侧边装饰大小。"
	L["DesaturatedOptionTT"] = "部分选项被去饱和，这可使颜色选择器更好地应用颜色。未去饱和的选项在颜色选择器设为白色 (#FFFFFF) 时视觉效果最佳。"

	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "满格颜色"
	L["VigorBar_Full_ColorPickerTT"] = "选择满格颜色。"
	L["VigorBar_Empty_ColorPicker"] = "空格颜色"
	L["VigorBar_Empty_ColorPickerTT"] = "选择空格颜色。"
	L["VigorBar_Progress_ColorPicker"] = "恢复格颜色"
	L["VigorBar_Progress_ColorPickerTT"] = "选择恢复格颜色。"
	L["VigorBarCover_ColorPicker"] = "格覆盖颜色"
	L["VigorBarCover_ColorPickerTT"] = "选择格覆盖颜色。"
	L["VigorBarBackground_ColorPicker"] = "背景颜色"
	L["VigorBarBackground_ColorPickerTT"] = "选择活力格背景颜色。"
	L["VigorBarSpark_ColorPicker"] = "火花颜色"
	L["VigorBarSpark_ColorPickerTT"] = "选择活力格火花颜色。"
	L["VigorBarFlash_ColorPicker"] = "闪烁颜色"
	L["VigorBarFlash_ColorPickerTT"] = "选择恢复或满格时闪烁颜色。"
	L["VigorBarDecor_ColorPicker"] = "装饰颜色"
	L["VigorBarDecor_ColorPickerTT"] = "选择侧边装饰颜色。"

	-- Additional Toggles
	L["ToggleTopper"] = "显示顶部装饰"
	L["ToggleTopperTT"] = "显示速度表顶部装饰。"
	L["ToggleFooter"] = "显示底部装饰"
	L["ToggleFooterTT"] = "显示速度表底部装饰。"
	L["ToggleVigor"] = "显示活力面板"
	L["ToggleVigorTT"] = "显示6格活力面板。"
	
	-- Themes
	L["ThemeAlgari_Gold"] = "阿加里 - 金色"
	L["ThemeAlgari_Bronze"] = "阿加里 - 青铜"
	L["ThemeAlgari_Dark"] = "阿加里 - 深色"
	L["ThemeAlgari_Silver"] = "阿加里 - 银色"
	L["ThemeDefault_Desaturated"] = "默认 - 去饱和"
	L["ThemeAlgari_Desaturated"] = "阿加里 - 去饱和"
	L["ThemeGryphon_Desaturated"] = "狮鹫 - 去饱和"
	L["ThemeWyvern_Desaturated"] = "双足飞龙 - 去饱和"
	L["ThemeDragon_Desaturated"] = "巨龙 - 去饱和"

	-- Model Themes
	L["ModelTheme_Wind"] = "风"
	L["ModelTheme_Lightning"] = "闪电"
	L["ModelTheme_FireForm"] = "火焰形态"
	L["ModelTheme_ArcaneForm"] = "奥术形态"
	L["ModelTheme_FrostForm"] = "冰霜形态"
	L["ModelTheme_HolyForm"] = "神圣形态"
	L["ModelTheme_NatureForm"] = "自然形态"
	L["ModelTheme_ShadowForm"] = "暗影形态"

	-- TOC translations
	L["DR_Title"] = "Dragon Rider: 龙骑士"
	L["DR_Notes"] = "显示与活力条和其他一些与龙骑术相关的选项配对的速度计。"


return end

if LOCALE == "zhTW" then
	-- Traditional Chinese translations go here
	L["Vigor"] = "活力"
	L["Speedometer"] = "車速表"
	L["ToggleModelsName"] = "展現活力模特"
	L["ToggleModelsTT"] = "顯示活力氣泡上的旋轉模型效果。"
	L["SpeedPosPointName"] = "車速表位置"
	L["SpeedPosPointTT"] = "調整速度計相對於活力條的固定位置。"
	L["Top"] = "頂部"
	L["Bottom"] = "底部"
	L["Left"] = "左邊"
	L["Right"] = "正確的"
	L["SpeedPosXName"] = "車速表水平位置"
	L["SpeedPosXTT"] = "調整車速表的水平位置。"
	L["SpeedPosYName"] = "車速表垂直位置"
	L["SpeedPosYTT"] = "調整車速表的垂直位置。"
	L["SpeedScaleName"] = "車速表刻度"
	L["SpeedScaleTT"] = "調整車速表的刻度。"
	L["Large"] = "大的"
	L["Small"] = "小的"
	L["Units"] = "速度單位文字" -- Changed in 11.2.7
	L["UnitsTT"] = "更改車速表上顯示的單位。\n（機械上 1 米 = 1 碼）"
	L["UnitsColor"] = "速度單位文字顏色" -- Changed in 11.2.7
	L["UnitYards"] = "碼/秒"
	L["Yards"] = "碼數"
	L["UnitMiles"] = "英里/小時"
	L["Miles"] = "英里"
	L["UnitMeters"] = "米/秒"
	L["Meters"] = "米"
	L["UnitKilometers"] = "公里/小時"
	L["Kilometers"] = "公里"
	L["UnitPercent"] = "%"
	L["Percent"] = "百分比"
	L["SpeedTextScale"] = "車速表文字大小"
	L["SpeedTextScaleTT"] = "調整車速表上文字的大小。"
	L["Version"] = "版本 %s"
	L["ResetAllSettings"] = "重置所有龍騎士設置"
	L["ResetAllSettingsTT"] = "專門為此插件重置所有設置。 這將包括自定義顏色值。"
	L["ResetAllSettingsConfirm"] = "您確定要重置《龍騎士》的設置嗎？"
	L["Low"] = "低的"
	L["High"] = "高的"
	L["ProgressBar"] = "車速表" -- Deprecated
	L["ProgressBarColor"] = "車速表顏色" -- Deprecated
	L["ColorPickerLowProgTT"] = "為速度計的低速值選擇自定義顏色。 當玩家沒有獲得任何活力時就會發生這種情況。" -- Deprecated
	L["ColorPickerMidProgTT"] = "為速度計的活力速度值選擇自定義顏色。 當玩家在標準速度範圍內獲得活力時，就會發生這種情況。" -- Deprecated
	L["ColorPickerHighProgTT"] = "為車速表的高速值選擇自定義顏色。 當玩家精力充沛但速度高於標準速度範圍時，就會發生這種情況。" -- Deprecated
	L["ColorPickerLowTextTT"] = "為速度值的低速度值選擇自定義顏色。 當玩家沒有獲得任何活力時就會發生這種情況。" -- Deprecated
	L["ColorPickerMidTextTT"] = "為速度值的活力速度值選擇自定義顏色。 當玩家在標準速度範圍內獲得活力時，就會發生這種情況。" -- Deprecated
	L["ColorPickerHighTextTT"] = "為速度值的高速值選擇自定義顏色。 當玩家精力充沛但速度高於標準速度範圍時，就會發生這種情況。" -- Deprecated
	L["DragonridingTalents"] = "龍騎天賦" -- Changed in 11.2.7
	L["OpenDragonridingTalents"] = "打開龍騎天賦視窗" -- Changed in 11.2.7
	L["OpenDragonridingTalentsTT"] = "打開龍騎天賦視窗。" -- Changed in 11.2.7
	L["SideArtName"] = "側面藝術"
	L["SideArtTT"] = "切換主活力條兩側的藝術。"
	L["BugfixesName"] = "Bug修復"
	L["BugfixesTT"] = "當預設暴雪框架未如預期工作時嘗試進行實驗性錯誤修復。"
	L["BugfixHideVigor"] = "強制隱藏活力"
	L["BugfixHideVigorTT"] = "下坐騎時強制隱藏精力條，騎上驭空术飞行坐騎時重新顯示。"
	L["FadeSpeedometer"] = "褪色車速表"
	L["FadeSpeedometerTT"] = "不滑行時切換速度計的淡出。"
	L["ShowVigorTooltip"] = "顯示活力工具提示"
	L["ShowVigorTooltipTT"] = "切換活力條上顯示的工具提示。"
	L["FadeVigor"] = "褪色活力"
	L["FadeVigorTT"] = "在不滑翔和充滿活力時切換活力條的淡出。"
	L["LightningRush"] = "閃電衝刺顯示" -- Changed in 11.2.7
	L["LightningRushTT"] = "切換用於「閃電突襲」技能的靜電充能球。" -- Changed in 11.2.7
	L["DynamicFOV"] = "動態視野"
	L["DynamicFOVTT"] = "能夠根據滑翔速度調整相機視野。"
	L["Normal"] = "普通的"
	L["Advanced"] = "先進的"
	L["Reverse"] = "反向"
	L["Challenge"] = "挑戰"
	L["ReverseChallenge"] = "反向挑戰"
	L["Storm"] = "風暴"
	L["COMMAND_help"] = "幫助"
	L["COMMAND_journal"] = "日誌"
	L["COMMAND_listcommands"] = "指令列表:"
	L["COMMAND_dragonrider"] = "龍騎士"
	L["DragonRider"] = "龍騎士"
	L["RightClick_TT_Line"] = "右鍵點擊：打開設置"
	L["LeftClick_TT_Line"] = "左鍵點擊：打開日誌"
	L["SlashCommands_TT_Line"] = "'/龍騎士' 以獲取其他指令"
	L["Score"] = "得分"
	L["Guide"] = "指南"
	L["Settings"] = "設置"
	L["ComingSoon"] = "即將推出"
	L["UseAccountScores"] = "使用帳戶分數"
	L["UseAccountScoresTT"] = "這將顯示您帳戶中的最高種族分數，而不是您角色的分數。帳戶分數以星號 (*) 表示。"
	L["PersonalBest"] = "個人最佳: "
	L["AccountBest"] = "帳戶最佳: "
	L["BestCharacter"] = "最佳角色: "
	L["GoldTime"] = "金牌時間: "
	L["SilverTime"] = "銀牌時間: "
	L["MuteVigorSound_Settings"] = "静音活力音效"
	L["MuteVigorSound_SettingsTT"] = "切换驭空术坐骑获得精力时播放的声音。"
	L["SpeedometerTheme"] = "速度計主題"
	L["SpeedometerThemeTT"] = "自訂速度計主題。"
	L["Algari"] = "阿爾加里"
	L["Default"] = DEFAULT
	L["Minimalist"] = "極簡主義"
	L["Alliance"] = FACTION_ALLIANCE
	L["Horde"] = FACTION_HORDE
	L["TimerunningStatistics"] = "時光奔跑統計"
	L["SkyridingCurrencyGained"] = "獲得天空騎乘 %s："

	-- New in 11.2.7
	L["ToggleSpeedometer"] = "顯示速度表"
	L["ToggleSpeedometerTT"] = "切換顯示速度表。"
	L["SpeedometerWidthName"] = "速度表寬度"
	L["SpeedometerWidthTT"] = "設定速度表框架寬度。"
	L["SpeedometerHeightName"] = "速度表高度"
	L["SpeedometerHeightTT"] = "設定速度表框架高度。"
	L["LockFrame"] = LOCK_FRAME
	L["UnlockFrame"] = UNLOCK_FRAME
	L["DynamicFOV_CaveatTT"] = "需要關閉設定並著陸後才會生效。\n\n與「畫面暈眩」設定不相容。"
	L["DynamicFOVNewTT"] = "依據滑翔與 D.R.I.V.E. 速度調整相機視野。"
	L["StaticChargeOffset"] = "静电充能偏移"
	L["StaticChargeSpacing"] = "静电充能间距"
	L["StaticChargeSize"] = "静电充能大小"
	L["StaticChargeWidth"] = "靜電能量寬度"
	L["StaticChargeHeight"] = "靜電能量高度"
	L["StaticChargeWidthTT"] = "調整靜電能量的寬度。"
	L["StaticChargeHeightTT"] = "調整靜電能量的高度。"
	L["StaticChargeSpacingTT"] = "調整靜電能量的間距。"
	L["StaticChargeOffsetTT"] = "調整靜電能量的偏移。"
	L["MoveFrame"] = MOVE_FRAME

	-- Speedometer Colors - replacing previous color picker text
	L["SpeedometerBar_Slow_ColorPicker"] = "慢速顏色"
	L["SpeedometerBar_Slow_ColorPickerTT"] = "選擇慢速值的顏色。"
	L["SpeedometerBar_Recharge_ColorPicker"] = "充能顏色"
	L["SpeedometerBar_Recharge_ColorPickerTT"] = "選擇充能速度增加時的顏色（「天雷之力」效果）。"
	L["SpeedometerBar_Over_ColorPicker"] = "超速顏色"
	L["SpeedometerBar_Over_ColorPickerTT"] = "選擇超過自然最大值的顏色（65%顯示）。"
	L["SpeedometerText_Slow_ColorPicker"] = "慢速文字顏色"
	L["SpeedometerText_Slow_ColorPickerTT"] = "選擇慢速文字的顏色。"
	L["SpeedometerText_Recharge_ColorPicker"] = "充能文字顏色"
	L["SpeedometerText_Recharge_ColorPickerTT"] = "選擇充能文字的顏色。"
	L["SpeedometerText_Over_ColorPicker"] = "超速文字顏色"
	L["SpeedometerText_Over_ColorPickerTT"] = "選擇超速文字的顏色。"
	L["SpeedometerCover_ColorPicker"] = "速度表覆蓋顏色"
	L["SpeedometerCover_ColorPickerTT"] = "選擇覆蓋顏色。"
	L["SpeedometerTick_ColorPicker"] = "刻度線顏色"
	L["SpeedometerTick_ColorPickerTT"] = "選擇60%和65%刻度線顏色。"
	L["SpeedometerTopper_ColorPicker"] = "頂部裝飾顏色"
	L["SpeedometerTopper_ColorPickerTT"] = "選擇頂部裝飾顏色。"
	L["SpeedometerFooter_ColorPicker"] = "底部裝飾顏色"
	L["SpeedometerFooter_ColorPickerTT"] = "選擇底部裝飾顏色。"
	L["SpeedometerBackground_ColorPicker"] = "背景顏色"
	L["SpeedometerBackground_ColorPickerTT"] = "選擇速度表背景顏色。"
	L["SpeedometerSpark_ColorPicker"] = "火花顏色"
	L["SpeedometerSpark_ColorPickerTT"] = "選擇速度表末端火花顏色。"

	-- New Vigor Bar Settings
	L["VigorTheme"] = "活力主題"
	L["VigorThemeTT"] = "設定活力面板主題。"
	L["VigorPosXName"] = "活力面板X位置"
	L["VigorPosXNameTT"] = "設定活力面板水平位置。"
	L["VigorPosYName"] = "活力面板Y位置"
	L["VigorPosYNameTT"] = "設定活力面板垂直位置。"
	L["VigorBarWidthName"] = "活力格寬度"
	L["VigorBarWidthNameTT"] = "設定每個活力格的寬度。"
	L["VigorBarHeightName"] = "活力格高度"
	L["VigorBarHeightNameTT"] = "設定每個活力格的高度。"
	L["VigorBarSpacingName"] = "格間距"
	L["VigorBarSpacingNameTT"] = "設定活力格之間的間距。"
	L["VigorBarOrientationName"] = "活力面板方向"
	L["VigorBarOrientationNameTT"] = "設定面板整體方向。"
	L["Orientation_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Orientation_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorBarDirectionName"] = "格子排列方向"
	L["VigorBarDirectionNameTT"] = "設定活力格排列方向。"
	L["Direction_DownRight"] = "由上往下 / 由左往右"
	L["Direction_UpLeft"] = "由下往上 / 由右往左"
	L["VigorWrapName"] = "每行/列格數"
	L["VigorWrapNameTT"] = "設定每行或每列顯示的格數。"
	L["VigorBarFillDirectionName"] = "格填充方向"
	L["VigorBarFillDirectionNameTT"] = "設定格內部填充方向。"
	L["Direction_Vertical"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL
	L["Direction_Horizontal"] = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL
	L["VigorSparkThicknessName"] = "火花厚度"
	L["VigorSparkThicknessNameTT"] = "設定活力格火花厚度。"
	L["ToggleFlashFullName"] = "滿格閃爍"
	L["ToggleFlashFullNameTT"] = "格滿時啟用閃爍。"
	L["ToggleFlashProgressName"] = "恢復格脈動"
	L["ToggleFlashProgressNameTT"] = "格恢復中時啟用脈動效果。"
	L["ModelThemeName"] = "模型主題"
	L["ModelThemeNameTT"] = "更改活力模型主題。"
	L["SideArtStyleName"] = "側邊裝飾主題"
	L["SideArtStyleNameTT"] = "更改側邊裝飾風格。"
	L["SideArtPosX"] = "側邊裝飾X位置"
	L["SideArtPosXTT"] = "設定側邊裝飾水平位置。"
	L["SideArtPosY"] = "側邊裝飾Y位置"
	L["SideArtPosYTT"] = "設定側邊裝飾垂直位置。"
	L["SideArtRot"] = "側邊裝飾旋轉"
	L["SideArtRotTT"] = "設定側邊裝飾旋轉角度。"
	L["SideArtScale"] = "側邊裝飾縮放"
	L["SideArtScaleTT"] = "設定側邊裝飾大小。"
	L["DesaturatedOptionTT"] = "部分選項已降低飽和度，使其更容易被色彩選擇器著色。未降低飽和度的選項在將色彩選擇器設為白色 (#FFFFFF) 時效果最佳。"

	-- Vigor Colors
	L["VigorBar_Full_ColorPicker"] = "滿格顏色"
	L["VigorBar_Full_ColorPickerTT"] = "選擇滿格顏色。"
	L["VigorBar_Empty_ColorPicker"] = "空格顏色"
	L["VigorBar_Empty_ColorPickerTT"] = "選擇空格顏色。"
	L["VigorBar_Progress_ColorPicker"] = "恢復格顏色"
	L["VigorBar_Progress_ColorPickerTT"] = "選擇恢復格顏色。"
	L["VigorBarCover_ColorPicker"] = "格覆蓋顏色"
	L["VigorBarCover_ColorPickerTT"] = "選擇格覆蓋顏色。"
	L["VigorBarBackground_ColorPicker"] = "背景顏色"
	L["VigorBarBackground_ColorPickerTT"] = "選擇活力格背景顏色。"
	L["VigorBarSpark_ColorPicker"] = "火花顏色"
	L["VigorBarSpark_ColorPickerTT"] = "選擇活力格火花顏色。"
	L["VigorBarFlash_ColorPicker"] = "閃爍顏色"
	L["VigorBarFlash_ColorPickerTT"] = "選擇恢復或滿格時閃爍顏色。"
	L["VigorBarDecor_ColorPicker"] = "裝飾顏色"
	L["VigorBarDecor_ColorPickerTT"] = "選擇側邊裝飾顏色。"

	-- Additional Toggles
	L["ToggleTopper"] = "顯示頂部裝飾"
	L["ToggleTopperTT"] = "顯示速度表頂部裝飾。"
	L["ToggleFooter"] = "顯示底部裝飾"
	L["ToggleFooterTT"] = "顯示速度表底部裝飾。"
	L["ToggleVigor"] = "顯示活力面板"
	L["ToggleVigorTT"] = "顯示6格活力面板。"
	
	-- Themes
	L["ThemeAlgari_Gold"] = "阿加里 - 金色"
	L["ThemeAlgari_Bronze"] = "阿加里 - 青銅"
	L["ThemeAlgari_Dark"] = "阿加里 - 深色"
	L["ThemeAlgari_Silver"] = "阿加里 - 銀色"
	L["ThemeDefault_Desaturated"] = "預設 - 降低飽和度"
	L["ThemeAlgari_Desaturated"] = "阿加里 - 降低飽和度"
	L["ThemeGryphon_Desaturated"] = "獅鷲 - 降低飽和度"
	L["ThemeWyvern_Desaturated"] = "雙足飛龍 - 降低飽和度"
	L["ThemeDragon_Desaturated"] = "巨龍 - 降低飽和度"

	-- Model Themes
	L["ModelTheme_Wind"] = "風"
	L["ModelTheme_Lightning"] = "閃電"
	L["ModelTheme_FireForm"] = "火焰形態"
	L["ModelTheme_ArcaneForm"] = "祕法形態"
	L["ModelTheme_FrostForm"] = "冰霜形態"
	L["ModelTheme_HolyForm"] = "神聖形態"
	L["ModelTheme_NatureForm"] = "自然形態"
	L["ModelTheme_ShadowForm"] = "暗影形態"


	-- TOC translations
	L["DR_Title"] = "Dragon Rider: 龍騎士"
	L["DR_Notes"] = "顯示與活力條和其他一些與龍騎術相關的選項配對的速度計。"


return end

