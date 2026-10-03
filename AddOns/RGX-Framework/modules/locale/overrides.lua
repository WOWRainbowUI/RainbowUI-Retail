--[[
RGX-Framework - Locale Overrides (non-enUS)

One guarded block per supported non-English WoW client locale. Each block
calls RGXLocale:NewLocale with the locale id; the call returns nil when the
client is running a different locale, so the `if L then ... end` guard turns
the block into a no-op on foreign clients. enUS remains the always-loaded
fallback base defined in locale.lua.

Brand names ("RGX Mods", "RGX-Framework") stay ASCII per family-wide
exemption.
]]

local _, RGX = ...
local Locale = _G.RGXLocale
if not Locale then
    error("RGX Locale overrides loaded before modules/locale/locale.lua")
    return
end

-- ── deDE ────────────────────────────────────────────────────────────────────
local L = Locale:NewLocale("RGX-Framework", "deDE")
if L then
    L["COMMAND_MODULES_HEADER"]       = "Module:"
    L["COMMAND_FONTS_HEADER"]         = "Schriftarten:"
    L["COMMAND_FONTS_AVAILABLE"]      = "verfügbar"
    L["COMMAND_FONT_DEBUG_ON"]        = "AN"
    L["COMMAND_FONT_DEBUG_OFF"]       = "AUS"
    L["COMMAND_FONT_DEBUG_PREFIX"]    = "Schriftart-Debug:"
    L["COMMAND_DB_TESTS_MISSING"]     = "DB-Tests nicht geladen."
    L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "Login-Nachrichten:"
    L["COMMAND_LOGIN_USAGE"]          = "Verwendung: /rgx login on|off|status"
    L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
    L["COMMAND_VERSION_UNKNOWN"]      = "unbekannt"
    L["COMMAND_LIST"]                 = "Befehle: modules, fonts, debug, dbtest, login, editor, version"
    L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s geladen."
    L["UI_COLORPICKER_NOT_LOADED"]    = "RGX-Farbwähler nicht geladen"
    L["UI_COLOR_DEFAULT_LABEL"]       = "Farbe"
    L["UI_SLIDER_DEFAULT_LABEL"]      = "Schieberegler"
    L["REP_RANK_1"]                   = "Hasserfüllt"
    L["REP_RANK_2"]                   = "Feindselig"
    L["REP_RANK_3"]                   = "Unfreundlich"
    L["REP_RANK_4"]                   = "Neutral"
    L["REP_RANK_5"]                   = "Freundlich"
    L["REP_RANK_6"]                   = "Wohlwollend"
    L["REP_RANK_7"]                   = "Respektvoll"
    L["REP_RANK_8"]                   = "Ehrfürchtig"
    L["REP_FACTION_FALLBACK_FORMAT"]  = "Fraktion %d"
    L["REP_UNKNOWN"]                  = "Unbekannt"
    L["REP_COVENANT"]                 = "Pakt"
end

-- ── esES ────────────────────────────────────────────────────────────────────
L = Locale:NewLocale("RGX-Framework", "esES")
if L then
    L["COMMAND_MODULES_HEADER"]       = "Módulos:"
    L["COMMAND_FONTS_HEADER"]         = "Fuentes:"
    L["COMMAND_FONTS_AVAILABLE"]      = "disponibles"
    L["COMMAND_FONT_DEBUG_ON"]        = "ACTIVADO"
    L["COMMAND_FONT_DEBUG_OFF"]       = "DESACTIVADO"
    L["COMMAND_FONT_DEBUG_PREFIX"]    = "Depuración de fuentes:"
    L["COMMAND_DB_TESTS_MISSING"]     = "Pruebas de DB no cargadas."
    L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "Mensajes de inicio de sesión:"
    L["COMMAND_LOGIN_USAGE"]          = "Uso: /rgx login on|off|status"
    L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
    L["COMMAND_VERSION_UNKNOWN"]      = "desconocida"
    L["COMMAND_LIST"]                 = "Comandos: modules, fonts, debug, dbtest, login, editor, version"
    L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s cargado."
    L["UI_COLORPICKER_NOT_LOADED"]    = "Selector de color de RGX no cargado"
    L["UI_COLOR_DEFAULT_LABEL"]       = "Color"
    L["UI_SLIDER_DEFAULT_LABEL"]      = "Deslizador"
    L["REP_RANK_1"]                   = "Odiado"
    L["REP_RANK_2"]                   = "Hostil"
    L["REP_RANK_3"]                   = "Adverso"
    L["REP_RANK_4"]                   = "Neutral"
    L["REP_RANK_5"]                   = "Amistoso"
    L["REP_RANK_6"]                   = "Honorable"
    L["REP_RANK_7"]                   = "Venerado"
    L["REP_RANK_8"]                   = "Exaltado"
    L["REP_FACTION_FALLBACK_FORMAT"]  = "Facción %d"
    L["REP_UNKNOWN"]                  = "Desconocido"
    L["REP_COVENANT"]                 = "Curia"
end

-- ── esMX ────────────────────────────────────────────────────────────────────
-- Shares the esES vocabulary (Latin-American Spanish client strings use the
-- same Blizzard terms for these ranks and common nouns). Documented shared
-- choice: keys are repeated explicitly so a future esMX-specific edit never
-- has to mutate the esES block.
L = Locale:NewLocale("RGX-Framework", "esMX")
if L then
    L["COMMAND_MODULES_HEADER"]       = "Módulos:"
    L["COMMAND_FONTS_HEADER"]         = "Fuentes:"
    L["COMMAND_FONTS_AVAILABLE"]      = "disponibles"
    L["COMMAND_FONT_DEBUG_ON"]        = "ACTIVADO"
    L["COMMAND_FONT_DEBUG_OFF"]       = "DESACTIVADO"
    L["COMMAND_FONT_DEBUG_PREFIX"]    = "Depuración de fuentes:"
    L["COMMAND_DB_TESTS_MISSING"]     = "Pruebas de DB no cargadas."
    L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "Mensajes de inicio de sesión:"
    L["COMMAND_LOGIN_USAGE"]          = "Uso: /rgx login on|off|status"
    L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
    L["COMMAND_VERSION_UNKNOWN"]      = "desconocida"
    L["COMMAND_LIST"]                 = "Comandos: modules, fonts, debug, dbtest, login, editor, version"
    L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s cargado."
    L["UI_COLORPICKER_NOT_LOADED"]    = "Selector de color de RGX no cargado"
    L["UI_COLOR_DEFAULT_LABEL"]       = "Color"
    L["UI_SLIDER_DEFAULT_LABEL"]      = "Deslizador"
    L["REP_RANK_1"]                   = "Odiado"
    L["REP_RANK_2"]                   = "Hostil"
    L["REP_RANK_3"]                   = "Adverso"
    L["REP_RANK_4"]                   = "Neutral"
    L["REP_RANK_5"]                   = "Amistoso"
    L["REP_RANK_6"]                   = "Honorable"
    L["REP_RANK_7"]                   = "Venerado"
    L["REP_RANK_8"]                   = "Exaltado"
    L["REP_FACTION_FALLBACK_FORMAT"]  = "Facción %d"
    L["REP_UNKNOWN"]                  = "Desconocido"
    L["REP_COVENANT"]                 = "Curia"
end

-- ── frFR ────────────────────────────────────────────────────────────────────
L = Locale:NewLocale("RGX-Framework", "frFR")
if L then
    L["COMMAND_MODULES_HEADER"]       = "Modules :"
    L["COMMAND_FONTS_HEADER"]         = "Polices :"
    L["COMMAND_FONTS_AVAILABLE"]      = "disponibles"
    L["COMMAND_FONT_DEBUG_ON"]        = "ACTIVÉ"
    L["COMMAND_FONT_DEBUG_OFF"]       = "DÉSACTIVÉ"
    L["COMMAND_FONT_DEBUG_PREFIX"]    = "Débogage des polices :"
    L["COMMAND_DB_TESTS_MISSING"]     = "Tests de base de données non chargés."
    L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "Messages de connexion :"
    L["COMMAND_LOGIN_USAGE"]          = "Utilisation : /rgx login on|off|status"
    L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
    L["COMMAND_VERSION_UNKNOWN"]      = "inconnue"
    L["COMMAND_LIST"]                 = "Commandes : modules, fonts, debug, dbtest, login, editor, version"
    L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s chargé."
    L["UI_COLORPICKER_NOT_LOADED"]    = "Sélecteur de couleur RGX non chargé"
    L["UI_COLOR_DEFAULT_LABEL"]       = "Couleur"
    L["UI_SLIDER_DEFAULT_LABEL"]      = "Curseur"
    L["REP_RANK_1"]                   = "Détesté"
    L["REP_RANK_2"]                   = "Hostile"
    L["REP_RANK_3"]                   = "Inamical"
    L["REP_RANK_4"]                   = "Neutre"
    L["REP_RANK_5"]                   = "Amical"
    L["REP_RANK_6"]                   = "Honoré"
    L["REP_RANK_7"]                   = "Révéré"
    L["REP_RANK_8"]                   = "Exalté"
    L["REP_FACTION_FALLBACK_FORMAT"]  = "Faction %d"
    L["REP_UNKNOWN"]                  = "Inconnu"
    L["REP_COVENANT"]                 = "Congrégation"
end

-- ── itIT ────────────────────────────────────────────────────────────────────
L = Locale:NewLocale("RGX-Framework", "itIT")
if L then
    L["COMMAND_MODULES_HEADER"]       = "Moduli:"
    L["COMMAND_FONTS_HEADER"]         = "Font:"
    L["COMMAND_FONTS_AVAILABLE"]      = "disponibili"
    L["COMMAND_FONT_DEBUG_ON"]        = "ATTIVO"
    L["COMMAND_FONT_DEBUG_OFF"]       = "DISATTIVO"
    L["COMMAND_FONT_DEBUG_PREFIX"]    = "Debug dei font:"
    L["COMMAND_DB_TESTS_MISSING"]     = "Test del database non caricati."
    L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "Messaggi di accesso:"
    L["COMMAND_LOGIN_USAGE"]          = "Uso: /rgx login on|off|status"
    L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
    L["COMMAND_VERSION_UNKNOWN"]      = "sconosciuta"
    L["COMMAND_LIST"]                 = "Comandi: modules, fonts, debug, dbtest, login, editor, version"
    L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s caricato."
    L["UI_COLORPICKER_NOT_LOADED"]    = "Selettore colore RGX non caricato"
    L["UI_COLOR_DEFAULT_LABEL"]       = "Colore"
    L["UI_SLIDER_DEFAULT_LABEL"]      = "Cursore"
    L["REP_RANK_1"]                   = "Odiato"
    L["REP_RANK_2"]                   = "Ostile"
    L["REP_RANK_3"]                   = "Scortese"
    L["REP_RANK_4"]                   = "Neutrale"
    L["REP_RANK_5"]                   = "Amichevole"
    L["REP_RANK_6"]                   = "Onorato"
    L["REP_RANK_7"]                   = "Venerato"
    L["REP_RANK_8"]                   = "Esaltato"
    L["REP_FACTION_FALLBACK_FORMAT"]  = "Fazione %d"
    L["REP_UNKNOWN"]                  = "Sconosciuto"
    L["REP_COVENANT"]                 = "Congrega"
end

-- ── koKR ────────────────────────────────────────────────────────────────────
L = Locale:NewLocale("RGX-Framework", "koKR")
if L then
    L["COMMAND_MODULES_HEADER"]       = "모듈:"
    L["COMMAND_FONTS_HEADER"]         = "글꼴:"
    L["COMMAND_FONTS_AVAILABLE"]      = "사용 가능"
    L["COMMAND_FONT_DEBUG_ON"]        = "켜짐"
    L["COMMAND_FONT_DEBUG_OFF"]       = "꺼짐"
    L["COMMAND_FONT_DEBUG_PREFIX"]    = "글꼴 디버그:"
    L["COMMAND_DB_TESTS_MISSING"]     = "DB 테스트가 로드되지 않았습니다."
    L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "로그인 메시지:"
    L["COMMAND_LOGIN_USAGE"]          = "사용법: /rgx login on|off|status"
    L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
    L["COMMAND_VERSION_UNKNOWN"]      = "알 수 없음"
    L["COMMAND_LIST"]                 = "명령: modules, fonts, debug, dbtest, login, editor, version"
    L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s 로드됨."
    L["UI_COLORPICKER_NOT_LOADED"]    = "RGX 색상 선택기가 로드되지 않았습니다"
    L["UI_COLOR_DEFAULT_LABEL"]       = "색상"
    L["UI_SLIDER_DEFAULT_LABEL"]      = "슬라이더"
    L["REP_RANK_1"]                   = "매우 적대적"
    L["REP_RANK_2"]                   = "적대적"
    L["REP_RANK_3"]                   = "약간 적대적"
    L["REP_RANK_4"]                   = "중립적"
    L["REP_RANK_5"]                   = "약간 우호적"
    L["REP_RANK_6"]                   = "우호적"
    L["REP_RANK_7"]                   = "매우 우호적"
    L["REP_RANK_8"]                   = "확고한 동맹"
    L["REP_FACTION_FALLBACK_FORMAT"]  = "진영 %d"
    L["REP_UNKNOWN"]                  = "알 수 없음"
    L["REP_COVENANT"]                 = "성약의 단"
end

-- ── ptBR ────────────────────────────────────────────────────────────────────
L = Locale:NewLocale("RGX-Framework", "ptBR")
if L then
    L["COMMAND_MODULES_HEADER"]       = "Módulos:"
    L["COMMAND_FONTS_HEADER"]         = "Fontes:"
    L["COMMAND_FONTS_AVAILABLE"]      = "disponíveis"
    L["COMMAND_FONT_DEBUG_ON"]        = "ATIVADO"
    L["COMMAND_FONT_DEBUG_OFF"]       = "DESATIVADO"
    L["COMMAND_FONT_DEBUG_PREFIX"]    = "Depuração de fontes:"
    L["COMMAND_DB_TESTS_MISSING"]     = "Testes de banco de dados não carregados."
    L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "Mensagens de login:"
    L["COMMAND_LOGIN_USAGE"]          = "Uso: /rgx login on|off|status"
    L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
    L["COMMAND_VERSION_UNKNOWN"]      = "desconhecida"
    L["COMMAND_LIST"]                 = "Comandos: modules, fonts, debug, dbtest, login, editor, version"
    L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s carregado."
    L["UI_COLORPICKER_NOT_LOADED"]    = "Seletor de cores RGX não carregado"
    L["UI_COLOR_DEFAULT_LABEL"]       = "Cor"
    L["UI_SLIDER_DEFAULT_LABEL"]      = "Controle deslizante"
    L["REP_RANK_1"]                   = "Odiado"
    L["REP_RANK_2"]                   = "Hostil"
    L["REP_RANK_3"]                   = "Inamistoso"
    L["REP_RANK_4"]                   = "Neutro"
    L["REP_RANK_5"]                   = "Amigável"
    L["REP_RANK_6"]                   = "Honrado"
    L["REP_RANK_7"]                   = "Reverenciado"
    L["REP_RANK_8"]                   = "Exaltado"
    L["REP_FACTION_FALLBACK_FORMAT"]  = "Facção %d"
    L["REP_UNKNOWN"]                  = "Desconhecido"
    L["REP_COVENANT"]                 = "Pacto"
end

-- ── ptPT ────────────────────────────────────────────────────────────────────
L = Locale:NewLocale("RGX-Framework", "ptPT")
if L then
    L["COMMAND_MODULES_HEADER"]       = "Módulos:"
    L["COMMAND_FONTS_HEADER"]         = "Tipos de letra:"
    L["COMMAND_FONTS_AVAILABLE"]      = "disponíveis"
    L["COMMAND_FONT_DEBUG_ON"]        = "ATIVADO"
    L["COMMAND_FONT_DEBUG_OFF"]       = "DESATIVADO"
    L["COMMAND_FONT_DEBUG_PREFIX"]    = "Depuração de tipos de letra:"
    L["COMMAND_DB_TESTS_MISSING"]     = "Testes da base de dados não carregados."
    L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "Mensagens de início de sessão:"
    L["COMMAND_LOGIN_USAGE"]          = "Utilização: /rgx login on|off|status"
    L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
    L["COMMAND_VERSION_UNKNOWN"]      = "desconhecida"
    L["COMMAND_LIST"]                 = "Comandos: modules, fonts, debug, dbtest, login, editor, version"
    L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s carregado."
    L["UI_COLORPICKER_NOT_LOADED"]    = "Seletor de cores RGX não carregado"
    L["UI_COLOR_DEFAULT_LABEL"]       = "Cor"
    L["UI_SLIDER_DEFAULT_LABEL"]      = "Barra deslizante"
    L["REP_RANK_1"]                   = "Odiado"
    L["REP_RANK_2"]                   = "Hostil"
    L["REP_RANK_3"]                   = "Inamistoso"
    L["REP_RANK_4"]                   = "Neutro"
    L["REP_RANK_5"]                   = "Amigável"
    L["REP_RANK_6"]                   = "Honrado"
    L["REP_RANK_7"]                   = "Reverenciado"
    L["REP_RANK_8"]                   = "Exaltado"
    L["REP_FACTION_FALLBACK_FORMAT"]  = "Facção %d"
    L["REP_UNKNOWN"]                  = "Desconhecido"
    L["REP_COVENANT"]                 = "Congregação"
end

-- ── ruRU ────────────────────────────────────────────────────────────────────
L = Locale:NewLocale("RGX-Framework", "ruRU")
if L then
    L["COMMAND_MODULES_HEADER"]       = "Модули:"
    L["COMMAND_FONTS_HEADER"]         = "Шрифты:"
    L["COMMAND_FONTS_AVAILABLE"]      = "доступно"
    L["COMMAND_FONT_DEBUG_ON"]        = "ВКЛ"
    L["COMMAND_FONT_DEBUG_OFF"]       = "ВЫКЛ"
    L["COMMAND_FONT_DEBUG_PREFIX"]    = "Отладка шрифтов:"
    L["COMMAND_DB_TESTS_MISSING"]     = "Тесты базы данных не загружены."
    L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "Сообщения при входе:"
    L["COMMAND_LOGIN_USAGE"]          = "Использование: /rgx login on|off|status"
    L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
    L["COMMAND_VERSION_UNKNOWN"]      = "неизвестно"
    L["COMMAND_LIST"]                 = "Команды: modules, fonts, debug, dbtest, login, editor, version"
    L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s загружен."
    L["UI_COLORPICKER_NOT_LOADED"]    = "Средство выбора цвета RGX не загружено"
    L["UI_COLOR_DEFAULT_LABEL"]       = "Цвет"
    L["UI_SLIDER_DEFAULT_LABEL"]      = "Ползунок"
    L["REP_RANK_1"]                   = "Ненависть"
    L["REP_RANK_2"]                   = "Враждебность"
    L["REP_RANK_3"]                   = "Неприязнь"
    L["REP_RANK_4"]                   = "Равнодушие"
    L["REP_RANK_5"]                   = "Дружелюбие"
    L["REP_RANK_6"]                   = "Уважение"
    L["REP_RANK_7"]                   = "Почтение"
    L["REP_RANK_8"]                   = "Превознесение"
    L["REP_FACTION_FALLBACK_FORMAT"]  = "Фракция %d"
    L["REP_UNKNOWN"]                  = "Неизвестно"
    L["REP_COVENANT"]                 = "Ковенант"
end

-- ── zhCN ────────────────────────────────────────────────────────────────────
L = Locale:NewLocale("RGX-Framework", "zhCN")
if L then
    L["COMMAND_MODULES_HEADER"]       = "模块："
    L["COMMAND_FONTS_HEADER"]         = "字体："
    L["COMMAND_FONTS_AVAILABLE"]      = "可用"
    L["COMMAND_FONT_DEBUG_ON"]        = "开"
    L["COMMAND_FONT_DEBUG_OFF"]       = "关"
    L["COMMAND_FONT_DEBUG_PREFIX"]    = "字体调试："
    L["COMMAND_DB_TESTS_MISSING"]     = "数据库测试未加载。"
    L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "登录消息："
    L["COMMAND_LOGIN_USAGE"]          = "用法：/rgx login on|off|status"
    L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
    L["COMMAND_VERSION_UNKNOWN"]      = "未知"
    L["COMMAND_LIST"]                 = "命令：modules, fonts, debug, dbtest, login, editor, version"
    L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s 已加载。"
    L["UI_COLORPICKER_NOT_LOADED"]    = "RGX 颜色选择器未加载"
    L["UI_COLOR_DEFAULT_LABEL"]       = "颜色"
    L["UI_SLIDER_DEFAULT_LABEL"]      = "滑块"
    L["REP_RANK_1"]                   = "仇恨"
    L["REP_RANK_2"]                   = "敌对"
    L["REP_RANK_3"]                   = "冷淡"
    L["REP_RANK_4"]                   = "中立"
    L["REP_RANK_5"]                   = "友善"
    L["REP_RANK_6"]                   = "尊敬"
    L["REP_RANK_7"]                   = "崇敬"
    L["REP_RANK_8"]                   = "崇拜"
    L["REP_FACTION_FALLBACK_FORMAT"]  = "阵营 %d"
    L["REP_UNKNOWN"]                  = "未知"
    L["REP_COVENANT"]                 = "盟约"
end

-- ── zhTW ────────────────────────────────────────────────────────────────────
L = Locale:NewLocale("RGX-Framework", "zhTW")
if L then
    L["COMMAND_MODULES_HEADER"]       = "模組："
    L["COMMAND_FONTS_HEADER"]         = "字體："
    L["COMMAND_FONTS_AVAILABLE"]      = "可用"
    L["COMMAND_FONT_DEBUG_ON"]        = "開"
    L["COMMAND_FONT_DEBUG_OFF"]       = "關"
    L["COMMAND_FONT_DEBUG_PREFIX"]    = "字體除錯："
    L["COMMAND_DB_TESTS_MISSING"]     = "資料庫測試未載入。"
    L["COMMAND_LOGIN_MESSAGES_PREFIX"]= "登入訊息："
    L["COMMAND_LOGIN_USAGE"]          = "用法：/rgx login on|off|status"
    L["COMMAND_VERSION_PREFIX"]       = "RGX-Framework v"
    L["COMMAND_VERSION_UNKNOWN"]      = "未知"
    L["COMMAND_LIST"]                 = "指令：modules, fonts, debug, dbtest, login, editor, version"
    L["LOGIN_LOADED_FORMAT"]          = "RGX-Framework v%s 已載入。"
    L["UI_COLORPICKER_NOT_LOADED"]    = "RGX 顏色選擇器未載入"
    L["UI_COLOR_DEFAULT_LABEL"]       = "顏色"
    L["UI_SLIDER_DEFAULT_LABEL"]      = "滑桿"
    L["REP_RANK_1"]                   = "仇恨"
    L["REP_RANK_2"]                   = "敵對"
    L["REP_RANK_3"]                   = "不友好"
    L["REP_RANK_4"]                   = "中立"
    L["REP_RANK_5"]                   = "友好"
    L["REP_RANK_6"]                   = "尊敬"
    L["REP_RANK_7"]                   = "崇敬"
    L["REP_RANK_8"]                   = "崇拜"
    L["REP_FACTION_FALLBACK_FORMAT"]  = "陣營 %d"
    L["REP_UNKNOWN"]                  = "未知"
    L["REP_COVENANT"]                 = "誓盟"
end
