--=====================================================================================
-- RGX | Simple Quest Plates! - esES.lua

-- Author: DonnieDice
-- Description: Spanish localization
--=====================================================================================

local addonName, SQP = ...
local locale = GetLocale()

if locale ~= "esES" and locale ~= "esMX" then return end

local L = SQP.L or {}

-- Spanish translations
L["OPTIONS_ENABLE"] = "Activar Simple Quest Plates"
L["OPTIONS_DISPLAY"] = "Configuración de visualización"
L["OPTIONS_SCALE"] = "Tamaño del icono"
L["OPTIONS_OFFSET_X"] = "Desplazamiento horizontal"
L["OPTIONS_OFFSET_Y"] = "Desplazamiento vertical"
L["OPTIONS_ANCHOR"] = "Posición del icono"
L["OPTIONS_TEST"] = "Probar detección"
L["OPTIONS_RESET"] = "Restablecer toda la configuración"

L["CMD_ENABLED"] = "ahora está |cff00ff00ACTIVADO|r"
L["CMD_DISABLED"] = "ahora está |cffff0000DESACTIVADO|r"
L["CMD_VERSION"] = "Versión de Simple Quest Plates: |cff58be81%s|r"
L["CMD_HELP_HEADER"] = "|cff58be81Comandos de RGX | Simple Quest Plates!:|r"

L["MSG_LOADED"] = "v%s cargado correctamente. Escribe |cfffff569/sqp help|r para ver los comandos."