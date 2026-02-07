local addonName, addonTable = ...
local L = addonTable.L

-- [[ GUARD CLAUSE: STOP IF NOT MX ]] --
if GetLocale() ~= "esMX" then return end

-- ============================================================================
-- [[ SETTINGS MENU HEADERS ]]
-- ============================================================================
L["SETTINGS_SIZE"]       = "Tamaño de lista"
L["SETTINGS_FILTER"]     = "Filtro"
L["SETTINGS_APPEARANCE"] = "Apariencia"
L["SETTINGS_BEHAVIOR"]   = "Comportamiento"
L["SETTINGS_AUTOMATION"] = "Automatización"
L["SETTINGS_RESET"]      = "|cffff0000Restablecer valores|r"

-- ============================================================================
-- [[ SETTINGS: SIZE ]]
-- ============================================================================
L["SET_SIZE_SMALL"]      = "Pequeño (Por defecto)"
L["SET_SIZE_MEDIUM"]     = "Mediano"
L["SET_SIZE_LARGE"]      = "Grande"

-- ============================================================================
-- [[ SETTINGS: FILTERS ]]
-- ============================================================================
L["SET_HIDE_OFFLINE"]    = "Ocultar desconectados"
L["SET_HIDE_AFK"]        = "Ocultar ausentes (AFK)"
L["SET_MOBILE_AFK"]      = "Marcar móvil como ausente"
L["SET_HIDE_EMPTY"]      = "Ocultar grupos vacíos"
L["SET_INGAME_ONLY"]     = "Solo amigos en el juego"
L["SET_RETAIL_ONLY"]     = "Solo amigos de Retail"

-- ============================================================================
-- [[ SETTINGS: APPEARANCE ]]
-- ============================================================================
L["SET_SHOW_FLAGS"]      = "Mostrar banderas de reino"
L["SET_SHOW_REALM"]      = "Mostrar nombre del reino"
L["SET_CLASS_COLOR"]     = "Usar colores de clase"
L["SET_FACTION_ICONS"]   = "Mostrar íconos de facción"
L["SET_GRAY_FACTION"]    = "Atenuar facción opuesta"
L["SET_SHOW_BTAG"]       = "Mostrar solo BattleTag"
L["SET_HIDE_MAX_LEVEL"]  = "Ocultar nivel máximo"

-- ============================================================================
-- [[ SETTINGS: BEHAVIOR ]]
-- ============================================================================
L["SET_FAV_GROUP"]       = "Activar grupo de favoritos"
L["SET_COLLAPSE"]        = "Auto-colapsar grupos"

-- ============================================================================
-- [[ SETTINGS: AUTOMATION ]]
-- ============================================================================
L["SET_AUTO_ACCEPT"]     = "Aceptar invitación de grupo automáticamente"
L["SET_AUTO_PARTY_SYNC"] = "Aceptar Sinc. de grupo automáticamente"
L["MSG_AUTO_INVITE"]     = "|cFF33FF99FriendGroups|r: %s te invita a un grupo. Aceptar auto. |cff00ff00ACTIVADO|r"
L["MSG_AUTO_SYNC"]       = "|cFF33FF99FriendGroups|r: %s te invita a Sinc. de grupo. Aceptar auto. |cff00ff00ACTIVADO|r"

-- Spirit Behavior Sub-Menu
L["SET_SPIRIT_HEADER"]   = "Comportamiento del espíritu"
L["SET_SPIRIT_NONE"]     = "Ninguno"
L["SET_SPIRIT_RES"]      = "Aceptar resurrección automáticamente"
L["SET_SPIRIT_RELEASE"]  = "Liberar espíritu automáticamente"

L["MSG_AUTO_RES"]        = "|cFF33FF99FriendGroups|r: %s te está resucitando. Aceptar auto. |cff00ff00ACTIVADO|r"
L["MSG_AUTO_RELEASE"]    = "|cFF33FF99FriendGroups|r: Has muerto. Liberación auto. |cff00ff00ACTIVADO|r"

-- ============================================================================
-- [[ CONTEXT MENUS ]]
-- ============================================================================
-- Group Header Right-Click
L["MENU_RENAME"]         = "Renombrar grupo"
L["MENU_REMOVE"]         = "Eliminar grupo"
L["MENU_INVITE"]         = "Invitar grupo"
L["MENU_MAX_40"]         = " (Máx 40)"

-- Friend Button Right-Click
L["DROP_TITLE"]          = "FriendGroups"
L["DROP_COPY_NAME"]      = "Copiar Nombre-Reino"
L["DROP_COPY_BTAG"]      = "Copiar BattleTag"
L["DROP_CREATE"]         = "Crear nuevo grupo"
L["DROP_ADD"]            = "Añadir al grupo"
L["DROP_REMOVE"]         = "Eliminar del grupo"
L["DROP_CANCEL"]         = "Cancelar"

-- ============================================================================
-- [[ POPUPS & SYSTEM ]]
-- ============================================================================
L["POPUP_ENTER_NAME"]    = "Ingresa el nombre del grupo"
L["POPUP_COPY"]          = "Presiona Ctrl+C para copiar:"

L["SEARCH_PLACEHOLDER"]  = "Buscar FriendGroups"
L["SEARCH_TOOLTIP"]      = "FriendGroups: ¡Busca a cualquiera! Nombre, Reino, Clase e incluso Notas"

L["MSG_WELCOME"]         = "Versión %s actualizada para el parche 12.0 por Osiris the Kiwi"
L["MSG_RESET"]           = "|cFF33FF99FriendGroups|r: Configuración restablecida."
L["MSG_BUG_WARNING"]     = "|cFF33FF99FriendGroups|r: Error de API Bnet detectado. Tu lista vacía es causada por un error del cliente WoW. Reinicia el juego. (Sin garantía)"

-- ============================================================================
-- [[ SPECIAL GROUP NAMES ]]
-- ============================================================================
L["GROUP_FAVORITES"]     = "[Favoritos]"
L["GROUP_NONE"]          = "[Sin Grupo]"
L["GROUP_EMPTY"]         = "La lista de amigos está vacía"
L["STATUS_MOBILE"]       = "Móvil"

-- ============================================================================
-- [[ HOUSING / SAFE MODE ]]
-- ============================================================================
L["RELOAD_BTN_TEXT"]      = "Recargar FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "Recargar FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "Recarga la interfaz para restaurar FriendGroups."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups Activo|r\n\nDebido a restricciones de Blizzard,\ndebes recargar para ver casas."
L["SHIELD_BTN_TEXT"]      = "Recargar para ver casas"
L["SAFE_MODE_WARNING"]    = "|cffFF0000VIVIENDA:|r FriendGroups desactivado para ver casas. Recarga para activar."