local addonName, addonTable = ...
if GetLocale() ~= "esES" then return end
local L = addonTable.L

L["SETTINGS_FILTER"] = "Filtro"
L["SETTINGS_APPEARANCE"] = "Apariencia"
L["SETTINGS_BEHAVIOR"] = "Comportamiento de Grupo"
L["SETTINGS_AUTOMATION"] = "Automatización"
L["SETTINGS_RESET"] = "|cffff0000Restaurar predeterminados|r"

L["SET_HIDE_OFFLINE"] = "Ocultar desconectados"
L["SET_HIDE_AFK"] = "Ocultar ausentes (AFK)"
L["SET_HIDE_EMPTY"] = "Ocultar grupos vacíos"
L["SET_INGAME_ONLY"] = "Solo amigos en el juego"
L["SET_RETAIL_ONLY"] = "Solo amigos de Retail"
L["SET_CLASS_COLOR"] = "Usar colores de clase"
L["SET_FACTION_ICONS"] = "Mostrar iconos de facción"
L["SET_GRAY_FACTION"] = "Atenuar facción opuesta"
L["SET_SHOW_REALM"] = "Mostrar Reino"
L["SET_SHOW_BTAG"] = "Mostrar solo BattleTag"
L["SET_HIDE_MAX_LEVEL"] = "Ocultar nivel máximo"
L["SET_MOBILE_AFK"] = "Marcar móvil como ausente"
L["SET_FAV_GROUP"] = "Habilitar grupo de Favoritos"
L["SET_COLLAPSE"] = "Contraer grupos automáticamente"
L["SET_AUTO_ACCEPT"] = "Aceptar invitación automáticamente"

L["MENU_RENAME"] = "Renombrar grupo"
L["MENU_REMOVE"] = "Eliminar grupo"
L["MENU_INVITE"] = "Invitar grupo"
L["MENU_MAX_40"] = " (Máx 40)"

L["DROP_TITLE"] = "FriendGroups"
L["DROP_COPY_NAME"] = "Copiar Nombre-Reino"
L["DROP_COPY_BTAG"] = "Copiar BattleTag"
L["DROP_CREATE"] = "Crear nuevo grupo"
L["DROP_ADD"] = "Añadir al grupo"
L["DROP_REMOVE"] = "Eliminar del grupo"
L["DROP_CANCEL"] = "Cancelar"

L["POPUP_ENTER_NAME"] = "Introduce nombre del grupo"
L["POPUP_COPY"] = "Pulsa Ctrl+C para copiar:"

L["GROUP_FAVORITES"] = "[Favoritos]"
L["GROUP_NONE"] = "[Sin Grupo]"
L["GROUP_EMPTY"] = "Lista de amigos vacía"

L["STATUS_MOBILE"] = "Móvil"
L["SEARCH_PLACEHOLDER"] = "Buscar en FriendGroups"
L["MSG_RESET"] = "|cFF33FF99FriendGroups|r: Configuración restablecida."
L["MSG_BUG_WARNING"] = "|cFF33FF99FriendGroups|r: Error de API Bnet detectado. Por favor reinicia el juego."
L["MSG_WELCOME"] = "Versión %s actualizada para el parche 12.0 por Osiris the Kiwi"

L["SEARCH_TOOLTIP"] = "FriendGroups: ¡Busca a cualquiera! Nombre, Reino, Clase y Notas"

L["RELOAD_BTN_TEXT"]      = "Recargar FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "Recargar FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "Recarga la interfaz para restaurar FriendGroups."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups Activo|r\n\nDebido a restricciones de Blizzard,\ndebes recargar para ver las casas."
L["SHIELD_BTN_TEXT"]      = "Recargar para ver Casas"
L["SAFE_MODE_WARNING"]    = "|cffFF0000VER CASAS:|r FriendGroups deshabilitado. Recarga para habilitar."