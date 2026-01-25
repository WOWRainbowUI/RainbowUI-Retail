local addonName, addonTable = ...
local L = addonTable.L

-- [[ GUARD CLAUSE: STOP IF NOT PT ]] --
if GetLocale() ~= "ptBR" then return end

-- ============================================================================
-- [[ SETTINGS MENU HEADERS ]]
-- ============================================================================
L["SETTINGS_SIZE"]       = "Tamanho da Lista"
L["SETTINGS_FILTER"]     = "Filtro"
L["SETTINGS_APPEARANCE"] = "Aparência"
L["SETTINGS_BEHAVIOR"]   = "Comportamento"
L["SETTINGS_AUTOMATION"] = "Automação"
L["SETTINGS_RESET"]      = "|cffff0000Restaurar Padrões|r"

-- ============================================================================
-- [[ SETTINGS: SIZE ]]
-- ============================================================================
L["SET_SIZE_SMALL"]      = "Pequeno (Padrão)"
L["SET_SIZE_MEDIUM"]     = "Médio"
L["SET_SIZE_LARGE"]      = "Grande"

-- ============================================================================
-- [[ SETTINGS: FILTERS ]]
-- ============================================================================
L["SET_HIDE_OFFLINE"]    = "Ocultar Offline"
L["SET_HIDE_AFK"]        = "Ocultar Ausentes (AFK)"
L["SET_MOBILE_AFK"]      = "Marcar Mobile como AFK"
L["SET_HIDE_EMPTY"]      = "Ocultar Grupos Vazios"
L["SET_INGAME_ONLY"]     = "Apenas Amigos no Jogo"
L["SET_RETAIL_ONLY"]     = "Apenas Amigos de Retail"

-- ============================================================================
-- [[ SETTINGS: APPEARANCE ]]
-- ============================================================================
L["SET_SHOW_FLAGS"]      = "Mostrar Bandeiras de Reino"
L["SET_SHOW_REALM"]      = "Mostrar Nome do Reino"
L["SET_CLASS_COLOR"]     = "Usar Cores de Classe"
L["SET_FACTION_ICONS"]   = "Mostrar Ícones de Facção"
L["SET_GRAY_FACTION"]    = "Escurecer Facção Oposta"
L["SET_SHOW_BTAG"]       = "Mostrar Apenas BattleTag"
L["SET_HIDE_MAX_LEVEL"]  = "Ocultar Nível Máximo"

-- ============================================================================
-- [[ SETTINGS: BEHAVIOR ]]
-- ============================================================================
L["SET_FAV_GROUP"]       = "Habilitar Grupo de Favoritos"
L["SET_COLLAPSE"]        = "Colapsar Grupos Automaticamente"

-- ============================================================================
-- [[ SETTINGS: AUTOMATION ]]
-- ============================================================================
L["SET_AUTO_ACCEPT"]     = "Aceitar Convite Automaticamente"
L["SET_AUTO_PARTY_SYNC"] = "Aceitar Sincronia de Grupo Auto"

-- ============================================================================
-- [[ CONTEXT MENUS ]]
-- ============================================================================
-- Group Header Right-Click
L["MENU_RENAME"]         = "Renomear Grupo"
L["MENU_REMOVE"]         = "Remover Grupo"
L["MENU_INVITE"]         = "Convidar Grupo"
L["MENU_MAX_40"]         = " (Máx 40)"

-- Friend Button Right-Click
L["DROP_TITLE"]          = "FriendGroups"
L["DROP_COPY_NAME"]      = "Copiar Nome-Reino"
L["DROP_COPY_BTAG"]      = "Copiar BattleTag"
L["DROP_CREATE"]         = "Criar Novo Grupo"
L["DROP_ADD"]            = "Adicionar ao Grupo"
L["DROP_REMOVE"]         = "Remover do Grupo"
L["DROP_CANCEL"]         = "Cancelar"

-- ============================================================================
-- [[ POPUPS & SYSTEM ]]
-- ============================================================================
L["POPUP_ENTER_NAME"]    = "Digite o nome do novo grupo"
L["POPUP_COPY"]          = "Pressione Ctrl+C para copiar:"

L["SEARCH_PLACEHOLDER"]  = "Busca FriendGroups"
L["SEARCH_TOOLTIP"]      = "FriendGroups: Busque por qualquer um! Nome, Reino, Classe e até Notas"

L["MSG_WELCOME"]         = "Versão %s atualizada para o patch 12.0 por Osiris the Kiwi"
L["MSG_RESET"]           = "|cFF33FF99FriendGroups|r: Configurações redefinidas."
L["MSG_BUG_WARNING"]     = "|cFF33FF99FriendGroups|r: Bug na API Bnet detectado. Sua lista vazia é causada por um erro no cliente do WoW. Por favor, reinicie o jogo. (Sem garantia de correção)"

-- ============================================================================
-- [[ SPECIAL GROUP NAMES ]]
-- ============================================================================
L["GROUP_FAVORITES"]     = "[Favoritos]"
L["GROUP_NONE"]          = "[Sem Grupo]"
L["GROUP_EMPTY"]         = "A lista de amigos está vazia"
L["STATUS_MOBILE"]       = "Móvel"

-- ============================================================================
-- [[ HOUSING / SAFE MODE ]]
-- ============================================================================
L["RELOAD_BTN_TEXT"]      = "Recarregar FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "Recarregar FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "Recarrega a interface para restaurar o FriendGroups."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups está Ativo|r\n\nDevido a restrições de segurança da Blizzard,\nvocê deve recarregar para ver as Casas."
L["SHIELD_BTN_TEXT"]      = "Recarregar para Ver Casas"
L["SAFE_MODE_WARNING"]    = "|cffFF0000CASAS:|r FriendGroups desativado para ver Casas. Recarregue para ativar."