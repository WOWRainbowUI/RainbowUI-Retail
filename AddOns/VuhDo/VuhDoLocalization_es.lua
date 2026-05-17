if (GetLocale() ~= "esES") then
	return;
end
-- á = \195\161
-- é = \195\169
-- í = \195\173
-- ó = \195\179
-- ú = \195\186
-- ñ = \195\177
-- è = \195\170
-- ï = \195\175
-- ô = \195\180
-- ù = \195\185
-- Œ = \197\146
-- œ = \197\147
-- @EXACT = true: Translation has to be the exact(!) match in the clients language,
--                beacause it carries technical semantics
-- @EXACT = false: Translation can be done freely, because text is only descriptive
-- Class Names
-- @EXACT = false
VUHDO_I18N_WARRIORS = "Guerreros";
VUHDO_I18N_ROGUES = "P\195\173caros";
VUHDO_I18N_HUNTERS = "Cazadores";
VUHDO_I18N_PALADINS = "Paladines";
VUHDO_I18N_MAGES = "Magos";
VUHDO_I18N_WARLOCKS = "Brujos";
VUHDO_I18N_SHAMANS = "Chamanes";
VUHDO_I18N_DRUIDS = "Druidas";
VUHDO_I18N_PRIESTS = "Sacerdotes";
VUHDO_I18N_DEATH_KNIGHT = "Caballeros de la Muerte";
VUHDO_I18N_MONKS = "Monjes";
-- Group Model Names
-- @EXACT = false
VUHDO_I18N_GROUP = "Grupo";
VUHDO_I18N_OWN_GROUP = "Mi Grupo";
-- Special Model Names
-- @EXACT = false
VUHDO_I18N_PETS = "Mascotas";
VUHDO_I18N_MAINTANKS = "Tanques Principales";
VUHDO_I18N_PRIVATE_TANKS = "Tanques Privados";
-- General Labels
-- @EXACT = false
VUHDO_I18N_OKAY = "Aceptar";
VUHDO_I18N_CLASS = "Clase";
VUHDO_I18N_PLAYER = "Jugador";
-- VuhDoTooltip.lua
-- @EXACT = false
VUHDO_I18N_TT_POSITION = "|cffffb233Posici\195\179n:|r";
VUHDO_I18N_TT_GHOST = "<FANTASMA>";
VUHDO_I18N_TT_DEAD = "<MUERTO>";
VUHDO_I18N_TT_AFK = "<AUSENTE>";
VUHDO_I18N_TT_DND = "<NO MOLESTAR>";
VUHDO_I18N_TT_LIFE = "|cffffb233Vida:|r ";
VUHDO_I18N_TT_MANA = "|cffffb233Man\195\161:|r ";
VUHDO_I18N_TT_LEVEL = "Nivel ";
-- VuhDoPanel.lua
-- @EXACT = false
VUHDO_I18N_CHOOSE = "Elegir";
VUHDO_I18N_DRAG = "Arrastrar";
VUHDO_I18N_REMOVE = "Eliminar";
VUHDO_I18N_ME = "¡yo!";
VUHDO_I18N_TYPE = "Tipo";
VUHDO_I18N_VALUE = "Valor";
VUHDO_I18N_SPECIAL = "Especial";
VUHDO_I18N_BUFF_ALL = "Todos";
VUHDO_I18N_SHOW_BUFF_WATCH = "Mostrar Monitor de Beneficios";
-- @EXACT = true
--
-- Chat messages
-- @EXACT = false
VUHDO_I18N_COMMAND_LIST = "\n|cffffe566 - [ Comandos de VuhDo ] -|r\n" ..
"|cffffe566opt|r[ions] - Opciones de VuhDo\n" ..
"|cffffe566res|r[et] - Restablecer la posici\\195\\179n de los paneles\n" ..
"|cffffe566lock|r - Bloquear/Desbloquear paneles\n" ..
"|cffffe566mm, map, minimap|r - Activar/Desactivar icono del minimapa\n" ..
"|cffffe566compart|r[ment] - Activar/Desactivar icono del compartimento de addons\n" ..
"|cffffe566show, hide, toggle|r - Activar/Desactivar paneles\n" ..
"|cffffe566load|r - [Perfil],[Teclas]\n" ..
"[broad]|cffffe566cast, mt|r[s] - Anunciar tanques principales\n" ..
"|cffffe566role|r - Restablecer funciones de jugador\n" ..
"|cffffe566ab|r[out] - Acerca de este addon\n" ..
"|cffffe566help,?|r - Esta lista de comandos\n";
VUHDO_I18N_BAD_COMMAND = "¡Argumento incorrecto! Escribe '/vuhdo help' o '/vd ?' para ver la lista de comandos.";
VUHDO_I18N_CHAT_SHOWN = "|cffffe566visible|r.";
VUHDO_I18N_CHAT_HIDDEN = "|cffffe566oculto|r.";
VUHDO_I18N_MM_ICON = "El icono del minimapa ahora est\195\161 ";
VUHDO_I18N_MTS_BROADCASTED = "Los tanques principales se han sincronizado con la banda";
VUHDO_I18N_PANELS_SHOWN = "Los paneles de curaci\195\179n ahora est\195\161n |cffffe566visibles|r.";
VUHDO_I18N_PANELS_HIDDEN = "Los paneles de curaci\195\179n ahora est\195\161n |cffffe566ocultos|r.";
VUHDO_I18N_LOCK_PANELS_PRE = "Las posiciones de los paneles ahora est\195\161n ";
VUHDO_I18N_LOCK_PANELS_LOCKED = "|cffffe566bloqueadas|r.";
VUHDO_I18N_LOCK_PANELS_UNLOCKED = "|cffffe566desbloqueadas|r.";
VUHDO_I18N_PANELS_RESET = "Las posiciones de los paneles se han reiniciado.";
-- Config Pop-Up
-- @EXACT = false
VUHDO_I18N_ROLE = "Rol";
VUHDO_I18N_PRIVATE_TANK = "Tanque Privado";
VUHDO_I18N_SET_BUFF = "Asignar Beneficio";
-- Minimap
-- @EXACT = false
VUHDO_I18N_VUHDO_OPTIONS = "Opciones de VuhDo";
VUHDO_I18N_PANEL_SETUP = "Opciones";
VUHDO_I18N_MM_TOOLTIP = "Izquierdo: Configurar Panel\nDerecho: Men\195\186";
VUHDO_I18N_TOGGLES = "Interruptores";
VUHDO_I18N_LOCK_PANELS = "Bloquear Paneles";
VUHDO_I18N_SHOW_PANELS = "Mostrar Paneles";
VUHDO_I18N_MM_BUTTON = "Bot\195\179n del Minimap";
VUHDO_I18N_CLOSE = "Cerrar";
VUHDO_I18N_BROADCAST_MTS = "Sincronizar Tanques Principales";
-- Buff categories
-- @EXACT = false
-- Priest
-- Shaman
VUHDO_I18N_BUFFC_FIRE_TOTEM = "T\195\179tem de Fuego";
VUHDO_I18N_BUFFC_AIR_TOTEM = "T\195\179tem de Aire";
VUHDO_I18N_BUFFC_EARTH_TOTEM = "T\195\179tem de Tierra";
VUHDO_I18N_BUFFC_WATER_TOTEM = "T\195\179tem de Agua";
VUHDO_I18N_BUFFC_WEAPON_ENCHANT = "Encantamiento de Arma";
VUHDO_I18N_BUFFC_WEAPON_ENCHANT_2 = "Encantamiento de Arma 2";
VUHDO_I18N_BUFFC_SHIELDS = "Escudos";
-- Paladin
VUHDO_I18N_BUFFC_BLESSING = "Bendici\195\179n";
VUHDO_I18N_BUFFC_SEAL = "Sello";
-- Druids
-- Warlock
VUHDO_I18N_BUFFC_SKIN = "Piel";
-- Mage
VUHDO_I18N_BUFFC_ARMOR_MAGE = "Armadura";
-- Death Knight
VUHDO_BUFFC_PRESENCE    = "Presencia";
-- Warrior
VUHDO_I18N_BUFFC_SHOUT = "Grito";
-- Hunter
VUHDO_I18N_BUFFC_ASPECT = "Aspecto";
-- Monk
VUHDO_I18N_BUFFC_STANCE = "Estilo";
-- Key Binding Headers/Names
-- @EXACT = false
BINDING_HEADER_VUHDO_TITLE = "VuhDo - Raid Frames";
BINDING_NAME_VUHDO_KEY_ASSIGN_1 = "Mouse over - Sort 1";
BINDING_NAME_VUHDO_KEY_ASSIGN_2 = "Mouse over - Sort 2";
BINDING_NAME_VUHDO_KEY_ASSIGN_3 = "Mouse over - Sort 3";
BINDING_NAME_VUHDO_KEY_ASSIGN_4 = "Mouse over - Sort 4";
BINDING_NAME_VUHDO_KEY_ASSIGN_5 = "Mouse over - Sort 5";
BINDING_NAME_VUHDO_KEY_ASSIGN_6 = "Mouse over - Sort 6";
BINDING_NAME_VUHDO_KEY_ASSIGN_7 = "Mouse over - Sort 7";
BINDING_NAME_VUHDO_KEY_ASSIGN_8 = "Mouse over - Sort 8";
BINDING_NAME_VUHDO_KEY_ASSIGN_9 = "Mouse over - Sort 9";
BINDING_NAME_VUHDO_KEY_ASSIGN_10 = "Mouse over - Sort 10";
BINDING_NAME_VUHDO_KEY_ASSIGN_11 = "Mouse over - Sort 11";
BINDING_NAME_VUHDO_KEY_ASSIGN_12 = "Mouse over - Sort 12";
BINDING_NAME_VUHDO_KEY_ASSIGN_13 = "Mouse over - Sort 13";
BINDING_NAME_VUHDO_KEY_ASSIGN_14 = "Mouse over - Sort 14";
BINDING_NAME_VUHDO_KEY_ASSIGN_15 = "Mouse over - Sort 15";
BINDING_NAME_VUHDO_KEY_ASSIGN_16 = "Mouse over - Sort 16";
BINDING_NAME_VUHDO_KEY_ASSIGN_SMART_BUFF = "Buff Intelligent";
VUHDO_I18N_MOUSE_OVER_BINDING = "Asignaciones mouseover";
VUHDO_I18N_UNASSIGNED = "(sin asignar)";
-- #+V1.89
VUHDO_I18N_NO = "No";
VUHDO_I18N_UP = "Arriba";
VUHDO_I18N_VEHICLES = "Veh\195\173culos";
-- #+v1.94
VUHDO_I18N_DEFAULT_RES_ANNOUNCE = "¡Vuelve a la vida, vuhdo!";
-- #v+1.151
VUHDO_I18N_MAIN_ASSISTS = "Asistentes Principales";
-- #+v1.184
VUHDO_I18N_BW_CD = "CD";
VUHDO_I18N_BW_GO = "¡YA!";
VUHDO_I18N_BW_LOW = "BAJO";
VUHDO_I18N_BW_N_A = "|cffff0000N/D|r";
VUHDO_I18N_BW_RNG_RED = "|cffff0000RNG|r";
VUHDO_I18N_BW_OK = "OK";
VUHDO_I18N_BW_RNG_YELLOW = "|cffffff00RNG|r";
VUHDO_I18N_PROMOTE_RAID_LEADER = "Ascender a L\195\173der de Banda";
VUHDO_I18N_PROMOTE_ASSISTANT = "Ascender a Asistente";
VUHDO_I18N_DEMOTE_ASSISTANT = "Degradar de Asistente";
VUHDO_I18N_PROMOTE_MASTER_LOOTER = "Ascender a Maestro despojador";
VUHDO_I18N_MT_NUMBER = "MT #";
VUHDO_I18N_ROLE_OVERRIDE = "Sobrescribir rol";
VUHDO_I18N_MELEE_TANK = "Tanque Cuerpo a Cuerpo";
VUHDO_I18N_MELEE_DPS = "DPS Cuerpo a Cuerpo";
VUHDO_I18N_RANGED_DPS = "DPS a Distancia";
VUHDO_I18N_RANGED_HEALERS = "Sanador a Distancia";
VUHDO_I18N_AUTO_DETECT = "<detecci\195\179n autom\195\161tica>";
VUHDO_I18N_PROMOTE_ASSIST_MSG_1 = "Ascendido |cffffe566";
VUHDO_I18N_PROMOTE_ASSIST_MSG_2 = "|r a asistente.";
VUHDO_I18N_DEMOTE_ASSIST_MSG_1 = "Degradado |cffffe566";
VUHDO_I18N_DEMOTE_ASSIST_MSG_2 = "|r de asistente.";
VUHDO_I18N_RESET_ROLES = "Reiniciar Roles";
VUHDO_I18N_LOAD_KEY_SETUP = "Cargar Distribuci\195\179n de Teclas";
VUHDO_I18N_BUFF_ASSIGN_1 = "Beneficio |cffffe566";
VUHDO_I18N_BUFF_ASSIGN_2 = "|r asignado a |cffffe566";
VUHDO_I18N_BUFF_ASSIGN_3 = "|r";
VUHDO_I18N_MACRO_KEY_ERR_1 = "ERROR: La macro de mouseover excede el l\195\173mite para el hechizo: ";
VUHDO_I18N_MACRO_KEY_ERR_2 = "/256 caracteres). ¡Intenta reducir las opciones de auto-lanzamiento!";
VUHDO_I18N_MACRO_NUM_ERR = "¡N\195\186mero m\195\161ximo de macros por personaje excedido! No se puede crear macro mouseover de: ";
VUHDO_I18N_SMARTBUFF_ERR_1 = "VuhDo: ¡No se puede aplicar beneficio inteligente en combate!";
VUHDO_I18N_SMARTBUFF_ERR_2 = "VuhDo: No hay objetivo disponible para el beneficio de ";
VUHDO_I18N_SMARTBUFF_ERR_3 = " jugadores fuera de alcance para ";
VUHDO_I18N_SMARTBUFF_ERR_4 = "VuhDo: No hay beneficio para lanzar.";
VUHDO_I18N_SMARTBUFF_OKAY_1 = "VuhDo: Aplicando beneficio |cffffffff";
VUHDO_I18N_SMARTBUFF_OKAY_2 = "|r a ";
-- #+v1.189
VUHDO_I18N_UNKNOWN = "desconocido";
VUHDO_I18N_SELF = "Uno mismo";
VUHDO_I18N_MELEES = "Cuerpo a Cuerpo";
VUHDO_I18N_RANGED = "A Distancia";
-- #+1.196
VUHDO_I18N_OPTIONS_NOT_LOADED = ">>> ¡Plugin de Opciones de VuhDo no cargado! <<<";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_1 = "Error: La distribuci\195\179n de hechizos \"";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_2 = "\" no existe.";
VUHDO_I18N_AUTO_ARRANG_1 = "N\195\186mero de miembros del grupo cambiado a ";
VUHDO_I18N_AUTO_ARRANG_2 = ". Activando arreglo autom\195\161tico: \"";
-- #+1.209
VUHDO_I18N_TRACK_BUFFS_FOR = "Rastrear beneficio para ...";
VUHDO_I18N_OWN_GROUP_LONG = "Mi grupo";
VUHDO_I18N_NO_FOCUS = "[sin foco]";
VUHDO_I18N_NOT_AVAILABLE = "[ N/D ]";
-- #+1.237
VUHDO_I18N_TT_DISTANCE = "|cffffb233Distancia:|r";
VUHDO_I18N_TT_OF = " de ";
VUHDO_I18N_YARDS = "yardas";
-- #+1.252
VUHDO_I18N_PANEL = "Panel";
VUHDO_I18N_BOUQUET_AGGRO = "Indicador: Aggro";
VUHDO_I18N_BOUQUET_OUT_OF_RANGE = "Indicador: Fuera de alcance";
VUHDO_I18N_BOUQUET_IN_RANGE = "Indicador: Dentro de alcance";
VUHDO_I18N_BOUQUET_IN_YARDS = "Indicador: Distancia < yardas";
VUHDO_I18N_BOUQUET_OTHER_HOTS = "Indicador: HoTs de otro jugador";
VUHDO_I18N_BOUQUET_DEBUFF_MAGIC = "Indicador: Perjuicio M\195\161gico";
VUHDO_I18N_BOUQUET_DEBUFF_DISEASE = "Indicador: Perjuicio Enfermedad";
VUHDO_I18N_BOUQUET_DEBUFF_POISON = "Indicador: Perjuicio Veneno";
VUHDO_I18N_BOUQUET_DEBUFF_CURSE = "Indicador: Perjuicio Maldici\195\179n";
VUHDO_I18N_BOUQUET_CHARMED = "Indicador: Embelesado";
VUHDO_I18N_BOUQUET_DEAD = "Indicador: Muerto";
VUHDO_I18N_BOUQUET_DISCONNECTED = "Indicador: Desconectado";
VUHDO_I18N_BOUQUET_AFK = "Indicador: Ausente";
VUHDO_I18N_BOUQUET_PLAYER_TARGET = "Indicador: Objetivo del jugador";
VUHDO_I18N_BOUQUET_MOUSEOVER_TARGET = "Indicador: Pasar rat\195\179n sobre objetivo";
VUHDO_I18N_BOUQUET_MOUSEOVER_GROUP = "Indicador: Pasar rat\195\179n sobre grupo";
VUHDO_I18N_BOUQUET_HEALTH_BELOW = "Indicador: Vida < %";
VUHDO_I18N_BOUQUET_MANA_BELOW = "Indicador: Man\195\161 < %";
VUHDO_I18N_BOUQUET_THREAT_ABOVE = "Indicador: Amenaza > %";
VUHDO_I18N_BOUQUET_NUM_IN_CLUSTER = "Indicador: grupo >= jugadores";
VUHDO_I18N_BOUQUET_CLASS_COLOR = "Indicador: Siempre color de clase";
VUHDO_I18N_BOUQUET_ALWAYS = "Indicador: Siempre s\195\179lido";
VUHDO_I18N_SWIFTMEND_POSSIBLE = "Indicador: Correcci\195\179n posible";
VUHDO_I18N_BOUQUET_MOUSEOVER_CLUSTER = "Indicador: Agrupaci\195\179n, pasar rat\195\179n";
VUHDO_I18N_THREAT_LEVEL_MEDIUM = "Indicador: Amenaza alta";
VUHDO_I18N_THREAT_LEVEL_HIGH = "Indicador: Amenaza extrema";
VUHDO_I18N_BOUQUET_STATUS_HEALTH = "Barra de estado: % Vida";
VUHDO_I18N_BOUQUET_STATUS_MANA = "Barra de estado: % Man\195\161";
VUHDO_I18N_BOUQUET_STATUS_OTHER_POWERS = "Barra de estado: % No-Man\195\161";
VUHDO_I18N_BOUQUET_STATUS_INCOMING = "Barra de estado: % Curaciones Entrantes";
VUHDO_I18N_BOUQUET_STATUS_THREAT = "Barra de estado: % Amenaza";
VUHDO_I18N_BOUQUET_NEW_ITEM_NAME = "-- enter (de)buff here --";
VUHDO_I18N_DEF_BOUQUET_TANK_COOLDOWNS = "Tank Cooldowns";
VUHDO_I18N_DEF_BOUQUET_PW_S_WEAKENED_SOUL = "PW:S & Weakened Soul";
VUHDO_I18N_DEF_BOUQUET_MONK_STAGGER = "Monje Aplazar";
VUHDO_I18N_DEF_BOUQUET_BORDER_MULTI_AGGRO = "Border: Multi + Aggro";
VUHDO_I18N_DEF_BOUQUET_BORDER_MULTI = "Border: Multi";
VUHDO_I18N_DEF_BOUQUET_BORDER_SIMPLE = "Border: Simple";
VUHDO_I18N_DEF_BOUQUET_SWIFTMENDABLE = "Swiftmendable";
VUHDO_I18N_DEF_BOUQUET_MOUSEOVER_SINGLE = "Mouseover: Single";
VUHDO_I18N_DEF_BOUQUET_MOUSEOVER_MULTI = "Mouseover: Multi";
VUHDO_I18N_DEF_BOUQUET_AGGRO_INDICATOR = "Aggro Indicator";
VUHDO_I18N_DEF_BOUQUET_CLUSTER_MOUSE_HOVER = "Cluster: Mouse Hover";
VUHDO_I18N_DEF_BOUQUET_THREAT_MARKS = "Threat: Marks";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_ALL = "Manabars: All Powers";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_ONLY = "Manabars: Mana only";
VUHDO_I18N_DEF_BOUQUET_BAR_THREAT = "Threat: Status Bar";
VUHDO_I18N_CUSTOM_ICON_NONE = "- Ninguno / Por defecto -";
VUHDO_I18N_CUSTOM_ICON_GLOSSY = "Brillante";
VUHDO_I18N_CUSTOM_ICON_MOSAIC = "Mosaico";
VUHDO_I18N_CUSTOM_ICON_CLUSTER = "Agrupaci\195\179n";
VUHDO_I18N_CUSTOM_ICON_FLAT = "Plano";
VUHDO_I18N_CUSTOM_ICON_SPOT = "Punto";
VUHDO_I18N_CUSTOM_ICON_CIRCLE = "C\195\173rculo";
VUHDO_I18N_CUSTOM_ICON_SKETCHED = "Boceto";
VUHDO_I18N_CUSTOM_ICON_RHOMB = "Rombo";
VUHDO_I18N_ERROR_NO_PROFILE = "Error: No existe un perfil llamado: ";
VUHDO_I18N_PROFILE_LOADED = "Perfil cargado correctamente: ";
VUHDO_I18N_PROFILE_SAVED = "Perfil guardado correctamente: ";
VUHDO_I18N_PROFILE_OVERWRITE_1 = "Perfil";
VUHDO_I18N_PROFILE_OVERWRITE_2 = "pertenece actualmente a\notro personaje";
VUHDO_I18N_PROFILE_OVERWRITE_3 = "\n- Sobrescribir: El perfil existente ser\195\161 sobrescrito.\n- Copiar: Crear y guardar una copia. Mantener perfil existente.";
VUHDO_I18N_COPY = "Copiar";
VUHDO_I18N_OVERWRITE = "Sobrescribir";
VUHDO_I18N_DISCARD = "Descartar";
-- 2.0, alpha #2
VUHDO_I18N_DEF_BAR_BACKGROUND_SOLID = "Background: Solid";
VUHDO_I18N_DEF_BAR_BACKGROUND_CLASS_COLOR = "Background: Class Color";
-- 2.0 alpha #9
VUHDO_I18N_BOUQUET_DEBUFF_BAR_COLOR = "Indicador: Perjuicio, configurado";
-- 2.0 alpha #11
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH = "Health Bar: (auto)";
VUHDO_I18N_UPDATE_RAID_TARGET = "Indicador: Color de objetivo de banda";
VUHDO_I18N_BOUQUET_OVERHEAL_HIGHLIGHT = "Color: Resaltado de Sobrecuraci\195\179n";
VUHDO_I18N_BOUQUET_EMERGENCY_COLOR = "Color: Emergencia";
VUHDO_I18N_BOUQUET_HEALTH_ABOVE = "Indicador: Vida > %";
VUHDO_I18N_BOUQUET_RESURRECTION = "Indicador: Resurrecci\195\179n";
VUHDO_I18N_BOUQUET_STACKS_COLOR = "Color: #Acumulaciones";
-- 2.1
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH_SOLID = "Health: (generic, solid)";
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH_CLASS_COLOR = "Health: (generic, class col)";
-- 2.9
VUHDO_I18N_NO_TARGET = "[sin objetivo]";
VUHDO_I18N_TT_LEFT = " Izquierdo: ";
VUHDO_I18N_TT_RIGHT = " Derecho: ";
VUHDO_I18N_TT_MIDDLE = " Medio: ";
VUHDO_I18N_TT_BTN_4 = " Bot\195\179n 4: ";
VUHDO_I18N_TT_BTN_5 = " Bot\195\179n 5: ";
VUHDO_I18N_TT_WHEEL_UP = " Rueda arriba: ";
VUHDO_I18N_TT_WHEEL_DOWN = " Rueda abajo: ";
-- 2.13
VUHDO_I18N_BOUQUET_CLASS_ICON = "Icono: Clase";
VUHDO_I18N_BOUQUET_RAID_ICON = "Icono: S\195\173mbolo de Banda";
VUHDO_I18N_BOUQUET_ROLE_ICON = "Icono: Rol";
-- 2.18
VUHDO_I18N_LOAD_PROFILE = "Cargar Perfil";
-- 2.20
VUHDO_I18N_DC_SHIELD_NO_MACROS = "No hay ranuras de macro libres para este personaje... escudo d/c deshabilitado temporalmente.";
VUHDO_I18N_BROKER_TOOLTIP_1 = "|cffffff00Clic Izquierdo|r para mostrar men\195\186 de opciones";
VUHDO_I18N_BROKER_TOOLTIP_2 = "|cffffff00Clic Derecho|r para mostrar men\195\186 emergente";
-- 2.54
VUHDO_I18N_HOURS = "horas";
VUHDO_I18N_MINS = "min";
VUHDO_I18N_SECS = "seg";
-- 2.65
VUHDO_I18N_BOUQUET_CUSTOM_DEBUFF = "Icono: Perjuicio Personalizado";
-- 2.66
VUHDO_I18N_OFF = "apagado";
VUHDO_I18N_GHOST = "fantasma";
VUHDO_I18N_RIP = "rip";
VUHDO_I18N_DC = "d/c";
VUHDO_I18N_FOC = "foc";
VUHDO_I18N_TAR = "obj";
VUHDO_I18N_VEHICLE = "O-O";
-- 2.67
VUHDO_I18N_BUFF_WATCH = "Monitor de Beneficios";
VUHDO_I18N_HOTS = "HoTs";
VUHDO_I18N_DEBUFFS = "Perjuicios";
VUHDO_I18N_BOUQUET_PLAYER_FOCUS = "Indicador: Foco del Jugador";
-- 2.69
VUHDO_I18N_SIDE_BAR_LEFT = "Barra Lateral Izquierda";
VUHDO_I18N_SIDE_BAR_RIGHT = "Barra Lateral Derecha";
VUHDO_I18N_OWN_PET = "Mascota Propia";
-- 2.72
VUHDO_I18N_SPELL = "Hechizo";
VUHDO_I18N_COMMAND = "Comando";
VUHDO_I18N_MACRO = "Macro";
VUHDO_I18N_ITEM = "Objeto";
-- 2.75
VUHDO_I18N_ERR_NO_BOUQUET = "\"%s\" intenta engancharse a la agrupaci\195\179n \"%s\" que no existe!";

VUHDO_I18N_BOUQUET_HEALTH_BELOW_ABS = "Indicador: Vida < k";
VUHDO_I18N_BOUQUET_HEALTH_ABOVE_ABS = "Indicador: Vida > k";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST = "Distribuci\195\179n de hechizos \"%s\" no existe.";

--VUHDO_I18N_ADDON_WARNING = "WARNING: Addon |cffffffff\"%s\"|r is enabled along with VuhDo, which may be problematic. Reason: %s";
--VUHDO_I18N_MAY_CAUSE_LAGS = "May cause severe lags.";

VUHDO_I18N_DISABLE_BY_MIN_VERSION = "!!! VUHDO DESACTIVADO !!! Esta versi\195\179n (%s) es solo para clientes %d o superiores !!!"
VUHDO_I18N_DISABLE_BY_MAX_VERSION = "!!! VUHDO DESACTIVADO !!! Esta versi\195\179n (%s) es solo para clientes %d o inferiores !!!"

VUHDO_I18N_BOUQUET_STATUS_ALTERNATE_POWERS = "Barra de estado: Poder Alternativo %";
VUHDO_I18N_BOUQUET_ALTERNATE_POWERS_ABOVE = "Indicador: Poder Alternativo > %";
VUHDO_I18N_DEF_ALTERNATE_POWERS = "Alternative Powers";
VUHDO_I18N_DEF_TANK_CDS_EXTENDED = "Tank Cooldowns extd";
VUHDO_I18N_BOUQUET_HOLY_POWER_EQUALS = "Indicador: Poder Sagrado propio ==";
VUHDO_I18N_DEF_PLAYER_HOLY_POWER = "Player Holy Power";
VUHDO_I18N_CUSTOM_ICON_ONE_THIRD = "Puntos: Uno";
VUHDO_I18N_CUSTOM_ICON_TWO_THIRDS = "Puntos: Dos";
VUHDO_I18N_CUSTOM_ICON_THREE_THIRDS = "Puntos: Tres";
VUHDO_I18N_DEF_ROLE_ICON = "Role Icon";
VUHDO_I18N_DEF_BOUQUET_TARGET_HEALTH = "Health (generic, target)";
VUHDO_I18N_TAPPED_COLOR = "Indicador: Marcado";
VUHDO_I18N_ENEMY_STATE_COLOR = "Color: Amigo/Enemigo";
VUHDO_I18N_FRIEND_STATUS = "Indicador: Amigo";
VUHDO_I18N_FOE_STATUS = "Indicador: Enemigo";
VUHDO_I18N_BOUQUET_STATUS_ALWAYS_FULL = "Barra de estado: Siempre llena";
VUHDO_I18N_BOUQUET_STATUS_FULL_IF_ACTIVE = "Barra de estado: Llena si activo";
VUHDO_I18N_AOE_ADVICE = "Icono: Aviso AOE";
VUHDO_I18N_DEF_AOE_ADVICE = "AOE Advice";
VUHDO_I18N_BOUQUET_DURATION_ABOVE = "Indicador: Duraci\195\179n > seg";
VUHDO_I18N_BOUQUET_DURATION_BELOW = "Indicador: Duraci\195\179n < seg";
VUHDO_I18N_DEF_WRACK = "Sinestra: Arruinar";
VUHDO_I18N_DEF_DIRECTION_ARROW = "Direction Arrow";
VUHDO_I18N_BOUQUET_DIRECTION_ARROW = "Direction Arrow";
VUHDO_I18N_DEF_RAID_LEADER = "Icono: L\195\173der de Banda";
VUHDO_I18N_DEF_RAID_ASSIST = "Icono: Asistente de Banda";
VUHDO_I18N_DEF_MASTER_LOOTER = "Icono: Maestro Despojador";
VUHDO_I18N_DEF_PVP_STATUS = "Icono: Estado PvP";

VUHDO_I18N_GRID_MOUSEOVER_SINGLE = "Grid: Mouseover Single";
VUHDO_I18N_GRID_BACKGROUND_BAR = "Grid: Background Bar";
VUHDO_I18N_DEF_BIT_O_GRID = "Bit'o'Grid";
VUHDO_I18N_DEF_VUHDO_ESQUE = "Vuhdo'esque";


VUHDO_I18N_DEF_ROLE_COLOR = "Role Color";
VUHDO_I18N_BOUQUET_ROLE_TANK = "Indicador: Rol Tanque";
VUHDO_I18N_BOUQUET_ROLE_DAMAGE = "Indicador: Rol Da\195\177o";
VUHDO_I18N_BOUQUET_ROLE_HEALER = "Indicador: Rol Sanador";

VUHDO_I18N_BOUQUET_STACKS = "Indicador: Acumulaciones >";
VUHDO_I18N_DEF_PLAYER_CHI = "Player Chi";

VUHDO_I18N_BOUQUET_TARGET_RAID_ICON = "Icono: S\195\173mbolo de Banda del Objetivo";
VUHDO_I18N_BOUQUET_OWN_CHI_EQUALS = "Indicador: Chi propio ==";
VUHDO_I18N_CUSTOM_ICON_FOUR_THIRDS = "Puntos: Cuatro";
VUHDO_I18N_CUSTOM_ICON_FIVE_THIRDS = "Puntos: Cinco";
VUHDO_I18N_DEF_RAID_CDS = "Raid Cooldowns";
VUHDO_I18N_BOUQUET_STATUS_CLASS_COLOR_IF_ACTIVE = "Indicador: Color de Clase si activo";

VUHDO_I18N_LETHAL_POISONS = "Venenos Letales";
VUHDO_I18N_NON_LETHAL_POISONS = "Venenos No Letales";
VUHDO_I18N_DEF_COUNTER_SHIELD_ABSORB = "Contador: Todos los Escudos de Absorci\195\179n #k";
VUHDO_I18N_BUFFC_WEAPON_ENCHANT_OFF = "Encantamiento de Arma (mano secundaria)";

VUHDO_I18N_DEF_PVP_FLAGS="PvP Flag Carriers";
VUHDO_I18N_DEF_STATUS_SHIELD = "Barra de Estado: Escudo";

VUHDO_I18N_TARGET = "Objetivo";
VUHDO_I18N_FOCUS = "Foco";
VUHDO_I18N_DEF_STATUS_OVERSHIELDED = "Barra de Estado: Sobreescudo";

-- 3.65
VUHDO_I18N_BOUQUET_OUTSIDE_ZONE = "Indicador: Zona del jugador, fuera";
VUHDO_I18N_BOUQUET_INSIDE_ZONE = "Indicador: Zona del jugador, dentro";
VUHDO_I18N_BOUQUET_WARRIOR_TANK = "Indicador: Rol Tanque, Guerrero";
VUHDO_I18N_BOUQUET_PALADIN_TANK = "Indicador: Rol Tanque, Palad\195\173n";
VUHDO_I18N_BOUQUET_DK_TANK = "Indicador: Rol Tanque, Caballero de la Muerte";
VUHDO_I18N_BOUQUET_MONK_TANK = "Indicador: Rol Tanque, Monje";
VUHDO_I18N_BOUQUET_DRUID_TANK = "Indicador: Rol Tanque, Druida";

-- 3.66
VUHDO_I18N_BOUQUET_PALADIN_BEACON = "Paladin Beacon";
VUHDO_I18N_BOUQUET_STATUS_EXCESS_ABSORB = "Barra de estado: Absorci\195\179n excedente %";
VUHDO_I18N_BOUQUET_STATUS_TOTAL_ABSORB = "Barra de estado: Absorci\195\179n total %";

-- 3.67
VUHDO_I18N_NO_BOSS = "[sin PNJ]";
VUHDO_I18N_BOSSES = "PNJs";

-- 3.71
VUHDO_I18N_BOUQUET_CUSTOM_FLAG = "Indicador Personalizado";
VUHDO_I18N_ERROR_CUSTOM_FLAG_LOAD = "{VuhDo} Error: Tu validador de indicador personalizado no se ha cargado:";
VUHDO_I18N_ERROR_CUSTOM_FLAG_EXECUTE = "{VuhDo} Error: Tu validador de indicador personalizado no se ha ejecutado:";
VUHDO_I18N_ERROR_CUSTOM_FLAG_BLOCKED = "{VuhDo} Error: Un indicador personalizado de esta agrupaci\195\179n intent\195\179 llamar a una funci\195\179n prohibida y ha sido bloqueado. Recuerda importar \195\186nicamente cadenas de fuentes de confianza.";
VUHDO_I18N_ERROR_INVALID_VALIDATOR = "{VuhDo} Error: Validador no v\195\161lido:";

-- 3.72
VUHDO_I18N_BOUQUET_DEMON_HUNTER_TANK = "Indicador: Rol Tanque, Cazador de Demonios";
VUHDO_I18N_DEMON_HUNTERS = "Cazadores de Demonios";

-- 3.77
VUHDO_I18N_DEF_COUNTER_OVERFLOW_ABSORB = "Contador: Absorci\195\179n Desbordamiento M\195\173tica+ #k";

-- 3.79
VUHDO_I18N_DEFAULT_RES_ANNOUNCE_MASS = "¡Lanzando resurrecci\195\179n en masa!";

-- 3.81
VUHDO_I18N_BOUQUET_OVERFLOW_COUNTER = "Overflow Mythic+ Affix";

-- 3.82
VUHDO_I18N_SPELL_TRACE = "Icono: Rastrear Hechizo";
VUHDO_I18N_DEF_SPELL_TRACE = "Spell Trace";
VUHDO_I18N_TRAIL_OF_LIGHT = "Icono: Estela de Luz";
VUHDO_I18N_DEF_TRAIL_OF_LIGHT = "Trail of Light";

-- 3.83
VUHDO_I18N_BOUQUET_STATUS_MANA_HEALER_ONLY = "Barra de estado: Man\195\161 % (Solo Sanador)";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_HEALER_ONLY = "Manabars: Mana (Healer Only)";

-- 3.98
VUHDO_I18N_BOUQUET_HAS_SUMMON_ICON = "Icono: Tiene Invocaci\195\179n";
VUHDO_I18N_DEF_BOUQUET_HAS_SUMMON = "Summon Status Icon";
VUHDO_I18N_DEF_BOUQUET_ROLE_AND_SUMMON = "Role & Summon Status Icon";

-- 3.99
VUHDO_I18N_BOUQUET_IS_PHASED = "Icono: En otra fase";
VUHDO_I18N_BOUQUET_IS_WAR_MODE_PHASED = "Icono: En otra fase (Modo Guerra)";
VUHDO_I18N_DEF_BOUQUET_IS_PHASED = "Is Phased Icon";

-- 3.101
VUHDO_I18N_DEF_PLAYER_COMBO_POINTS = "Player Combo Points";
VUHDO_I18N_BOUQUET_OWN_COMBO_POINTS_EQUALS = "Indicador: Puntos de Combo propios ==";
VUHDO_I18N_DEF_PLAYER_SOUL_SHARDS = "Player Soul Shards";
VUHDO_I18N_BOUQUET_OWN_SOUL_SHARDS_EQUALS = "Indicador: Fragmentos de Alma propios ==";
VUHDO_I18N_DEF_PLAYER_RUNES = "Player Runes";
VUHDO_I18N_BOUQUET_OWN_RUNES_EQUALS = "Indicador: Runas propias ==";
VUHDO_I18N_DEF_PLAYER_ARCANE_CHARGES = "Player Arcane Charges";
VUHDO_I18N_BOUQUET_OWN_ARCANE_CHARGES_EQUALS = "Indicador: Cargas Arcanas propias ==";
VUHDO_I18N_DEBUFF_BLACKLIST_ADDED = "A\195\177adido \"[%s] %s\" a la lista negra de perjuicios.";

-- 3.104
VUHDO_I18N_PLAY_SOUND_FILE_ERR = "No se pudo reproducir el sonido \"%s\": %s";
VUHDO_I18N_PLAY_SOUND_FILE_DEBUFF_ERR = "No se pudo reproducir el sonido \"%s\" para el perjuicio est\195\161ndar. Ajusta la configuraci\195\179n en 'Opciones de VuhDo > Perjuicios > Est\195\161ndar > Sonido de Perjuicio'.";
VUHDO_I18N_PLAY_SOUND_FILE_CUSTOM_DEBUFF_ERR = "No se pudo reproducir el sonido \"%s\" para el perjuicio personalizado \"%s\". Ajusta la configuraci\195\179n en 'Opciones de VuhDo > Perjuicios > Personalizado'.";

-- 3.122
VUHDO_I18N_BOUQUET_STATUS_POWER_TANK_ONLY = "Barra de estado: Poder % (Solo Tanque)";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_TANK_ONLY = "Manabars: Power (Tank Only)";

-- 3.131
VUHDO_I18N_DEF_COUNTER_HEAL_ABSORB = "Counter: All Heal Absorb #k";
VUHDO_I18N_DEF_STATUS_HEAL_ABSORB = "Barra de estado: Absorci\195\179n de Sanaci\195\179n";

-- 3.135
VUHDO_I18N_TRINKET_1 = "Abalorio 1";
VUHDO_I18N_TRINKET_2 = "Abalorio 2";

-- 3.139
VUHDO_I18N_EVOKERS = "Evocadores";

-- 3.143
VUHDO_I18N_BUFFC_EARTH_SHIELD = "Escudo de Tierra (Propio)";

-- 3.150
VUHDO_I18N_ADDON_COMPARTMENT_ICON = "El icono del compartimento de AddOn ahora es ";

-- 3.152
VUHDO_I18N_SPELL_TRACE_SINGLE = "Icono: Rastreador de Hechizo (Individual)";

-- 3.154
VUHDO_I18N_SPELL_TRACE_INCOMING = "Icono: Rastreador de Hechizo (Entrante)";
VUHDO_I18N_SPELL_TRACE_HEAL = "Icono: Rastreador de Hechizo (Sanaci\195\179n)";

-- 3.157
VUHDO_I18N_TEXT_PROVIDER_OVERHEAL = "Sobrecuraci\195\179n: <#nk>";
VUHDO_I18N_TEXT_PROVIDER_OVERHEAL_PLUS = "Sobrecuraci\195\179n: +<#n>k";
VUHDO_I18N_TEXT_PROVIDER_INCOMING_HEAL = "Sanaci\195\179n entrante: <#nk>";
VUHDO_I18N_TEXT_PROVIDER_SHIELD_ABSORB = "Absorci\195\179n de escudos total: <#nk>";
VUHDO_I18N_TEXT_PROVIDER_HEAL_ABSORB = "Absorci\195\179n de sanaci\195\179n total: <#nk>";
VUHDO_I18N_TEXT_PROVIDER_THREAT = "Amenaza: <#n>%";
VUHDO_I18N_TEXT_PROVIDER_CHI = "Chi: <#n>";
VUHDO_I18N_TEXT_PROVIDER_HOLY_POWER = "Poder Sagrado: <#n>";
VUHDO_I18N_TEXT_PROVIDER_COMBO_POINTS = "Puntos de Combo: <#n>";
VUHDO_I18N_TEXT_PROVIDER_SOUL_SHARDS = "Fragmentos de Alma: <#n>";
VUHDO_I18N_TEXT_PROVIDER_RUNES = "Runas: <#n>";
VUHDO_I18N_TEXT_PROVIDER_ARCANE_CHARGES = "Cargas Arcanas: <#n>";
VUHDO_I18N_TEXT_PROVIDER_MANA_PERCENT = "Man\195\161: <#n>%";
VUHDO_I18N_TEXT_PROVIDER_MANA_PERCENT_TENTH = "Man\195\161: <#n/10%>";
VUHDO_I18N_TEXT_PROVIDER_MANA_UNIT_OF = "Man\195\161: <#n>/<#n>";
VUHDO_I18N_TEXT_PROVIDER_MANA_KILO_OF = "Man\195\161: <#nk>/<#nk>";
VUHDO_I18N_TEXT_PROVIDER_MANA = "Man\195\161: <#n>";
VUHDO_I18N_TEXT_PROVIDER_MANA_KILO = "Man\195\161: <#nk>";
VUHDO_I18N_BOUQUET_STATUS_HEALTH_IF_ACTIVE = "Barra de estado: Vida % si activo";

VUHDO_I18N_DEF_COUNTER_ACTIVE_AURAS = "Counter: Active Bouquet Auras #k";

VUHDO_I18N_BOUQUET_EVOKER_REVERSION = "Evoker Reversion (non-echo)";
VUHDO_I18N_BOUQUET_EVOKER_REVERSION_ECHO = "Evoker Reversion (echo)";
VUHDO_I18N_BOUQUET_EVOKER_DREAM_BREATH = "Evoker Dream Breath (non-echo)";
VUHDO_I18N_BOUQUET_EVOKER_DREAM_BREATH_ECHO = "Evoker Dream Breath (echo)";
VUHDO_I18N_BOUQUET_EVOKER_ALL_ECHO = "Evoker All HoT Echoes";

VUHDO_I18N_TRAIL_OF_LIGHT_NEXT = "Indicador: Estela de Luz (Siguiente)";
VUHDO_I18N_DEF_TRAIL_OF_LIGHT_NEXT = "Trail of Light (Next)";
VUHDO_I18N_BOUQUET_DEBUFF_BLEED = "Indicador: Perjuicio Hemorragia";

VUHDO_I18N_DEF_SPELL_TRACE_INCOMING = "Spell Trace (Incoming)";

VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_MINE = "Icon: Chi Harmony (Mine)";
VUHDO_I18N_DEF_BOUQUET_CHI_HARMONY_ICON_MINE = "Chi Harmony (Mine)";
VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_OTHERS = "Icon: Chi Harmony (Others)";
VUHDO_I18N_DEF_BOUQUET_CHI_HARMONY_ICON_OTHERS = "Chi Harmony (Others)";
VUHDO_I18N_BOUQUET_CHI_HARMONY_ICON_BOTH = "Icon: Chi Harmony (Both)";
VUHDO_I18N_DEF_BOUQUET_CHI_HARMONY_ICON_BOTH = "Chi Harmony (Both)";

VUHDO_I18N_BOUQUET_DEBUFF_ENRAGE = "Indicador: Perjuicio Enfurecer";

VUHDO_I18N_AURA_GROUP_MY_HOTS = "Mis HoTs (Auras de combate)";
VUHDO_I18N_AURA_GROUP_OTHERS_HOTS = "HoTs de otros (Auras de combate)";
VUHDO_I18N_AURA_GROUP_ALL_HOTS = "Todos los HoTs (Auras de combate)";
VUHDO_I18N_AURA_GROUP_DISPELLABLE = "Perjuicios disipables";
VUHDO_I18N_AURA_GROUP_CC = "Efectos de control de masas";
VUHDO_I18N_AURA_GROUP_BIG_DEF = "Defensivos mayores";
VUHDO_I18N_AURA_GROUP_EXTERNAL_DEF = "Defensivos externos";
VUHDO_I18N_AURA_GROUP_ALL_DEBUFFS = "Todos los perjuicios";
VUHDO_I18N_AURA_GROUP_ALL_BUFFS = "Todos los beneficios";
VUHDO_I18N_AURA_GROUP_MY_BUFFS = "Mis beneficios de banda";
VUHDO_I18N_AURA_GROUP_OTHERS_BUFFS = "Beneficios de banda de otros";
VUHDO_I18N_AURA_GROUP_ALL_RAID_BUFFS = "Todos los beneficios de banda";
VUHDO_I18N_AURA_GROUP_RAID_DEBUFFS = "Perjuicios de banda";
VUHDO_I18N_AURA_GROUP_IMPORTANT_BUFFS = "Beneficios importantes";
VUHDO_I18N_AURA_GROUP_IMPORTANT_DEBUFFS = "Perjuicios importantes";
VUHDO_I18N_AURA_GROUP_CANCELABLE = "Beneficios cancelables";
VUHDO_I18N_AURA_GROUP_NOT_CANCELABLE = "Beneficios no cancelables";
VUHDO_I18N_AURA_GROUP_TORGHAST_ANIMA = "Poderes de \195\161nima de Torghast";
VUHDO_I18N_AURA_GROUP_INFERRED_RIPTIDE = "Mareas Vivas (Inferido)";
VUHDO_I18N_AURA_GROUP_INFERRED_ECHO = "Eco (Inferido)";
VUHDO_I18N_AURA_GROUP_INFERRED_ATONEMENT = "Expiaci\195\179n (Inferido)";
VUHDO_I18N_AURA_GROUP_MY_NAMEPLATE = "Mis perjuicios de placas de nombre";
VUHDO_I18N_AURA_GROUP_OTHERS_NAMEPLATE = "Perjuicios de placas de nombre de otros";
VUHDO_I18N_AURA_GROUP_ALL_NAMEPLATE = "Todos los perjuicios de placas de nombre";
VUHDO_I18N_AURA_GROUP_MY_DEBUFFS = "Mis perjuicios";
VUHDO_I18N_AURA_GROUP_MY_EXTERNAL_DEF = "Defensivos externos";
VUHDO_I18N_AURA_GROUP_MY_RAID_DEBUFFS = "Perjuicios de banda";
VUHDO_I18N_AURA_GROUP_PRESERVATION_EVOKER_HOTS = "HoTs de Evocador Preservaci\195\179n";
VUHDO_I18N_AURA_GROUP_AUGMENTATION_EVOKER_BUFFS = "Beneficios de Evocador Aumento";
VUHDO_I18N_AURA_GROUP_RESTORATION_DRUID_HOTS = "HoTs de Druida Restauraci\195\179n";
VUHDO_I18N_AURA_GROUP_DISCIPLINE_PRIEST_HOTS = "HoTs de Sacerdote Disciplina";
VUHDO_I18N_AURA_GROUP_HOLY_PRIEST_HOTS = "HoTs de Sacerdote Sagrado";
VUHDO_I18N_AURA_GROUP_MISTWEAVER_MONK_HOTS = "HoTs de Monje Tejedor de Niebla";
VUHDO_I18N_AURA_GROUP_RESTORATION_SHAMAN_HOTS = "HoTs de Cham\195\161n Restauraci\195\179n";
VUHDO_I18N_AURA_GROUP_HOLY_PALADIN_HOTS = "HoTs de Palad\195\173n Sagrado";
VUHDO_I18N_AURA_GROUP_RAID_BUFFS = "Beneficios de banda";
VUHDO_I18N_AURA_GROUP_BLESSING_OF_BRONZE = "Bendici\195\179n de Bronce";
VUHDO_I18N_AURA_GROUP_ROGUE_POISONS = "Venenos de P\195\173caro";
VUHDO_I18N_AURA_GROUP_SHAMAN_WEAPON_IMBUEMENTS = "Imbuciones de arma de Cham\195\161n";
VUHDO_I18N_AURA_GROUP_PALADIN_WEAPON_IMBUEMENTS = "Imbuciones de arma de Palad\195\173n";
VUHDO_I18N_AURA_GROUP_ENHANCEMENT_SHAMAN_BUFFS = "Beneficios de Cham\195\161n Mejora";
VUHDO_I18N_AURA_GROUP_BREWMASTER_MONK_BUFFS = "Beneficios de Monje Maestro Cervecero";
VUHDO_I18N_AURA_GROUP_WARLOCK_METAMORPHOSIS = "Metamorfosis de Brujo";
VUHDO_I18N_AURA_GROUP_MIGRATED_HOTS = "HoTs migrados";
VUHDO_I18N_AURA_GROUP_MIGRATED_HOT_ICONS = "Iconos de HoT migrados";
VUHDO_I18N_AURA_GROUP_MIGRATED_HOT_BARS = "Barras de HoT migradas";

VUHDO_I18N_BOUQUET_AURA_GROUP_ACTIVE = "Indicador: Grupo de auras activo";
VUHDO_I18N_AURA_GROUP_FERAL_DRUID_BUFFS = "Beneficios de Druida Feral";
VUHDO_I18N_BW_MISS = "|cffff0000FALLO|r";
VUHDO_I18N_BW_LOCK = "|cff4488ffBLOQUEO|r";
VUHDO_I18N_BW_TARGET_MODE = "Objetivo de";
VUHDO_I18N_BW_TARGET_BY_NAME = "Nombre del jugador";
VUHDO_I18N_BW_TARGET = "Objetivo";
VUHDO_I18N_BW_FOCUS = "Foco";

VUHDO_I18N_AURA_GROUP_ALL_DISPELLABLE = "All Dispellable Debuffs";

