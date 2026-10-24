--[[

	This file is part of 'Masque', an add-on for World of Warcraft. For bug reports,
	documentation and license information, please visit https://github.com/SFX-WoW/Masque.

	* File...: Locales\esES.lua

	esMX/esES Locale

	[ Notes ]

	To help with translations, use the localization system on CurseForge (https://www.curseforge.com/wow/addons/masque/localization).

]]

local Locale = GetLocale()
if Locale ~= "esMX" and Locale ~= "esES" then return end

local _, Core = ...
local L = Core.Locale

-- Info
L["About Masque"] = "Acerca de Masque"
L["API"] = "API"
L["Author"] = "Autor"
L["Authors"] = "Autores"
L["Compatible"] = "Compatible"
L["Description"] = "Descripción"
--[[Translation missing --]]
--[[ L["Discord"] = "Discord"--]] 
L["For more information, please visit one of the sites listed below."] = "Para más información, visita uno de los sitios listados a continuación."
L["Installed Skins"] = "Apariencias instaladas"
L["Masque is a skinning engine for button-based add-ons."] = "Masque es un sistema de cambio de apariencia para los addons de botones."
L["No description available."] = "Descripción no disponible."
L["Select to view."] = "Selecciona para ver."
--[[Translation missing --]]
--[[ L["Status"] = "Status"--]] 
--[[Translation missing --]]
--[[ L["Supporters"] = "Supporters"--]] 
--[[Translation missing --]]
--[[ L["The status of this skin is unknown."] = "The status of this skin is unknown."--]] 
--[[Translation missing --]]
--[[ L["This section provides information on any skins you have installed."] = "This section provides information on any skins you have installed."--]] 
--[[Translation missing --]]
--[[ L["This skin is compatible with Masque."] = "This skin is compatible with Masque."--]] 
--[[Translation missing --]]
--[[ L["This skin is outdated but is still compatible with Masque."] = "This skin is outdated but is still compatible with Masque."--]] 
--[[Translation missing --]]
--[[ L["Unknown"] = "Unknown"--]] 
L["Version"] = "Versión"
L["Website"] = "Sitio web"
L["Websites"] = "Sitios web"
--[[Translation missing --]]
--[[ L["You must have an add-on that supports Masque installed to use it."] = "You must have an add-on that supports Masque installed to use it."--]] 

-- Settings
L["About"] = "Acerca de"
--[[Translation missing --]]
--[[ L["Add-On Compartment"] = "Add-On Compartment"--]] 
--[[Translation missing --]]
--[[ L["Adjust the scale of this group's skin."] = "Adjust the scale of this group's skin."--]] 
--[[Translation missing --]]
--[[ L["Advanced"] = "Advanced"--]] 
--[[Translation missing --]]
--[[ L["Advanced Settings"] = "Advanced Settings"--]] 
L["Alternate Sorting"] = "Ordenación alternativa"
L["Backdrop"] = "Opciones de Fondo"
--[[Translation missing --]]
--[[ L["Cast Animations"] = "Cast Animations"--]] 
L["Causes Masque to throw Lua errors whenever it encounters a problem with an add-on or skin."] = "Mostrar errores Lua al encontrar una problema con un add-on o una tema."
L["Causes the skins included with Masque to be listed above third-party skins."] = "Hace que las skins incluidas con Masque aparezcan por encima de las skins de terceros."
L["Checked"] = "Activado"
L["Clean Database"] = "Limpiar base de datos"
L["Click to open Masque's settings."] = "Haz clic para abrir los ajustes de Masque."
L["Click to purge the settings of all unused add-ons and groups."] = "Haz clic para purgar la configuración de todos los add-ons y grupos no utilizados."
L["Click to reload the interface."] = "Haz clic para recargar la interfaz."
L["Color"] = "Color"
L["Colors"] = "Colores"
L["Cooldown"] = "Enfriamiento"
--[[Translation missing --]]
--[[ L["Cooldown Animations"] = "Cooldown Animations"--]] 
L["Debug Mode"] = "Depuración"
L["Developer"] = "Desarrollador"
L["Developer Settings"] = "Ajustes de desarrollador"
L["Disable"] = "Desactivado"
L["Disable the skinning of this group."] = "Deshabilitar las texturas para este grupo."
L["Enable"] = "Activado"
--[[Translation missing --]]
--[[ L["Enable animations when action button cooldowns finish."] = "Enable animations when action button cooldowns finish."--]] 
--[[Translation missing --]]
--[[ L["Enable cast animations on action buttons."] = "Enable cast animations on action buttons."--]] 
--[[Translation missing --]]
--[[ L["Enable interrupt animations on action buttons."] = "Enable interrupt animations on action buttons."--]] 
--[[Translation missing --]]
--[[ L["Enable skin scaling."] = "Enable skin scaling."--]] 
--[[Translation missing --]]
--[[ L["Enable targeting reticles on action buttons."] = "Enable targeting reticles on action buttons."--]] 
L["Enable the Backdrop texture."] = "Habilitar la textura de fondo."
L["Enable the Gloss texture."] = "Activar textura brillante."
L["Enable the Shadow texture."] = "Activar textura de sombra."
L["Flash"] = "Destello"
--[[Translation missing --]]
--[[ L["Flash and Loop"] = "Flash and Loop"--]] 
L["General Settings"] = "Ajustes generales"
L["Global"] = "Global"
L["Global Settings"] = "Ajustes globales"
L["Gloss"] = "Opciones de Brillo"
L["Highlight"] = "Resaltado"
--[[Translation missing --]]
--[[ L["Increases the font size of the text on Ace3 profile panels."] = "Increases the font size of the text on Ace3 profile panels."--]] 
L["Interface"] = "Interfaz"
L["Interface Settings"] = "Ajustes de interfaz"
--[[Translation missing --]]
--[[ L["Interrupt Animations"] = "Interrupt Animations"--]] 
L["Load the skin information panel."] = "Cargar panel de información de apariencias."
--[[Translation missing --]]
--[[ L["Loop Only"] = "Loop Only"--]] 
L["Masque debug mode disabled."] = "La depuración de Masque se ha desactivada."
L["Masque debug mode enabled."] = "La depuración de Masque se ha activada."
--[[Translation missing --]]
--[[ L["Menu Icon"] = "Menu Icon"--]] 
--[[Translation missing --]]
--[[ L["Minimap"] = "Minimap"--]] 
--[[Translation missing --]]
--[[ L["None"] = "None"--]] 
L["Normal"] = "Normal"
--[[Translation missing --]]
--[[ L["Profile Panel Font Fix"] = "Profile Panel Font Fix"--]] 
L["Profile Settings"] = "Ajustes de perfil"
--[[Translation missing --]]
--[[ L["Pulse"] = "Pulse"--]] 
L["Pushed"] = "Pulsado"
L["Reload Interface"] = "Recargar interfaz"
L["Requires an interface reload."] = "Recarga de interfaz requerida."
L["Reset all skin options to the defaults."] = "Reestablece todos los colores a los predefinidos."
L["Reset Skin"] = "Restablecer Colores"
--[[Translation missing --]]
--[[ L["Scale"] = "Scale"--]] 
--[[Translation missing --]]
--[[ L["Select the spell alert style."] = "Select the spell alert style."--]] 
--[[Translation missing --]]
--[[ L["Select where Masque's menu icon is displayed."] = "Select where Masque's menu icon is displayed."--]] 
--[[Translation missing --]]
--[[ L["Select which spell alert animations are enabled."] = "Select which spell alert animations are enabled."--]] 
L["Set the color of the Backdrop texture."] = "Establece el color de la textura del fondo."
L["Set the color of the Checked texture."] = "Establece el color de la textura activada."
L["Set the color of the Cooldown animation."] = "Establece el color de la animación de enfriamiento."
L["Set the color of the Flash texture."] = "Establece el color del textura destelleando."
L["Set the color of the Gloss texture."] = "Establece el color de la textura brillando."
L["Set the color of the Highlight texture."] = "Establece el color de la textura resaltada."
L["Set the color of the Normal texture."] = "Establece el color de la textura normal."
L["Set the color of the Pushed texture."] = "Establece el color de la textura pulsada."
L["Set the color of the Shadow texture."] = "Establece el color de la textura de las sombras."
L["Set the skin for this group."] = "Seleccionar la tema para este grupo."
L["Shadow"] = "Sombras"
--[[Translation missing --]]
--[[ L["Show the pulse effect when a cooldown finishes."] = "Show the pulse effect when a cooldown finishes."--]] 
L["Skin"] = "Textura"
L["Skin Information"] = "Información de apariencia"
--[[Translation missing --]]
--[[ L["Skin Settings"] = "Skin Settings"--]] 
--[[Translation missing --]]
--[[ L["Spell Alert Animations"] = "Spell Alert Animations"--]] 
--[[Translation missing --]]
--[[ L["Spell Alert Style"] = "Spell Alert Style"--]] 
--[[Translation missing --]]
--[[ L["Stand-Alone GUI"] = "Stand-Alone GUI"--]] 
--[[Translation missing --]]
--[[ L["Targeting Reticles"] = "Targeting Reticles"--]] 
--[[Translation missing --]]
--[[ L["This action cannot be undone. Continue?"] = "This action cannot be undone. Continue?"--]] 
--[[Translation missing --]]
--[[ L["This section will allow you to adjust button settings for the default interface."] = "This section will allow you to adjust button settings for the default interface."--]] 
--[[Translation missing --]]
--[[ L["This section will allow you to adjust Masque's interface and performance settings."] = "This section will allow you to adjust Masque's interface and performance settings."--]] 
--[[Translation missing --]]
--[[ L["This section will allow you to adjust settings that affect Masque's interface."] = "This section will allow you to adjust settings that affect Masque's interface."--]] 
--[[Translation missing --]]
--[[ L["This section will allow you to adjust settings that affect working with Masque's API."] = "This section will allow you to adjust settings that affect working with Masque's API."--]] 
--[[Translation missing --]]
--[[ L["This section will allow you to adjust the skin settings of all buttons registered to %s."] = "This section will allow you to adjust the skin settings of all buttons registered to %s."--]] 
--[[Translation missing --]]
--[[ L["This section will allow you to adjust the skin settings of all buttons registered to %s. This will overwrite any per-group settings."] = "This section will allow you to adjust the skin settings of all buttons registered to %s. This will overwrite any per-group settings."--]] 
--[[Translation missing --]]
--[[ L["This section will allow you to adjust the skin settings of all registered buttons. This will overwrite any per-add-on settings."] = "This section will allow you to adjust the skin settings of all registered buttons. This will overwrite any per-add-on settings."--]] 
L["This section will allow you to skin the buttons of the add-ons and add-on groups registered with Masque."] = "Estas opciones te permiten cambiar la aparencia de los botones de los add-ons que se han registrados en Masque."
--[[Translation missing --]]
--[[ L["This section will allow you to view information about Masque and any skins you have installed."] = "This section will allow you to view information about Masque and any skins you have installed."--]] 
--[[Translation missing --]]
--[[ L["Unavailable in combat."] = "Unavailable in combat."--]] 
--[[Translation missing --]]
--[[ L["Use a resizable, stand-alone options window."] = "Use a resizable, stand-alone options window."--]] 

-- Skins
L["A square skin with trimmed icons and a semi-transparent background."] = "Una apariencia cuadrada con iconos recortados y un fondo semitransparente."
L["A square skin with zoomed icons and a semi-transparent background."] = "Una apariencia cuadrada con iconos ampliados y un fondo semitransparente."
L["An enhanced version of the classic button style."] = "Una versión mejorada del diseño de los botones por defecto del juego."
L["An enhanced version of the modern button style."] = "Una versión mejorada del estilo de los botones de Dragonflight."
--[[Translation missing --]]
--[[ L["The default classic button style."] = "The default classic button style."--]] 
--[[Translation missing --]]
--[[ L["The default modern button style."] = "The default modern button style."--]] 

