local addonName, addonTable = ...
if GetLocale() ~= "ptBR" then return end
local L = addonTable.L

L["SETTINGS_FILTER"] = "Filtro"
L["SETTINGS_APPEARANCE"] = "Aparência"
L["SETTINGS_BEHAVIOR"] = "Comportamento do Grupo"
L["SETTINGS_AUTOMATION"] = "Automação"
L["SETTINGS_RESET"] = "|cffff0000Restaurar Padrão|r"

L["SET_HIDE_OFFLINE"] = "Ocultar Offline"
L["SET_HIDE_AFK"] = "Ocultar Ausentes (AFK)"
L["SET_HIDE_EMPTY"] = "Ocultar Grupos Vazios"
L["SET_INGAME_ONLY"] = "Apenas Amigos no Jogo"
L["SET_RETAIL_ONLY"] = "Apenas Amigos Retail"
L["SET_CLASS_COLOR"] = "Usar Cores de Classe"
L["SET_FACTION_ICONS"] = "Ícones de Facção"
L["SET_GRAY_FACTION"] = "Escurecer Facção Oposta"
L["SET_SHOW_REALM"] = "Mostrar Reino"
L["SET_SHOW_BTAG"] = "Mostrar Apenas BattleTag"
L["SET_HIDE_MAX_LEVEL"] = "Ocultar Nível Máximo"
L["SET_MOBILE_AFK"] = "Marcar Mobile como AFK"
L["SET_FAV_GROUP"] = "Habilitar Grupo Favoritos"
L["SET_COLLAPSE"] = "Recolher Grupos Automaticamente"
L["SET_AUTO_ACCEPT"] = "Aceitar Convites Automaticamente"

L["MENU_RENAME"] = "Renomear Grupo"
L["MENU_REMOVE"] = "Remover Grupo"
L["MENU_INVITE"] = "Convidar Grupo"
L["MENU_MAX_40"] = " (Máx 40)"

L["DROP_TITLE"] = "FriendGroups"
L["DROP_COPY_NAME"] = "Copiar Nome-Reino"
L["DROP_COPY_BTAG"] = "Copiar BattleTag"
L["DROP_CREATE"] = "Criar Novo Grupo"
L["DROP_ADD"] = "Adicionar ao Grupo"
L["DROP_REMOVE"] = "Remover do Grupo"
L["DROP_CANCEL"] = "Cancelar"

L["POPUP_ENTER_NAME"] = "Digite o nome do grupo"
L["POPUP_COPY"] = "Pressione Ctrl+C para copiar:"

L["GROUP_FAVORITES"] = "[Favoritos]"
L["GROUP_NONE"] = "[Sem Grupo]"
L["GROUP_EMPTY"] = "Lista de amigos vazia"

L["STATUS_MOBILE"] = "Mobile"
L["SEARCH_PLACEHOLDER"] = "Busca FriendGroups"
L["MSG_RESET"] = "|cFF33FF99FriendGroups|r: Configurações resetadas."
L["MSG_BUG_WARNING"] = "|cFF33FF99FriendGroups|r: Bug na API Bnet detectado. Por favor, reinicie seu jogo."
L["MSG_WELCOME"] = "Versão %s atualizada para o patch 12.0 por Osiris the Kiwi"

L["SEARCH_TOOLTIP"] = "FriendGroups: Busque por qualquer um! Nome, Reino, Classe e Notas"

L["RELOAD_BTN_TEXT"]      = "Recarregar FriendGroups"
L["RELOAD_TOOLTIP_TITLE"] = "Recarregar FriendGroups"
L["RELOAD_TOOLTIP_DESC"]  = "Recarrega a interface para restaurar FriendGroups."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups Ativo|r\n\nDevido a restrições da Blizzard,\nvocê deve recarregar para ver as Casas."
L["SHIELD_BTN_TEXT"]      = "Recarregar para ver Casas"
L["SAFE_MODE_WARNING"]    = "|cffFF0000VER CASAS:|r FriendGroups desabilitado. Recarregue para ativar."