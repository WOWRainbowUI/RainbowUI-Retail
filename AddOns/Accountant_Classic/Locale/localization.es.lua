-- $Id$ 
-- Thanks to IsabelGarcia
local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "esES", false)

if not L then return end

-- Header
L["Accountant Classic"] = "Accountant Classic"
L["A basic tool to track your monetary incomings and outgoings within WoW."] = "Una herramienta básica para el seguimiento monetario de ingresos y gastos dentro del WoW."
L[ [=[Left-Click to open Accountant Classic.
Right-Click for Accountant Classic options.
Left-click and drag to move this button.]=] ] = [=[Clic izquierdo para abrir Accountant Classic.
Clic derecho para opciones de Accountant Classic.]=]
L[ [=[Left-click and drag to move this button.
Right-Click to open Accountant Classic.]=] ] = [=[Click izquierdo y arrastrar para mover este botón.
Click derecho para abrir Accountant Classic.]=]
L["Total Incomings"] = "Ingresos totales"
L["Total Outgoings"] = "Gastos totales"
L["Net Profit / Loss"] = "Beneficios netos / Pérdidas"
L["Net Loss"] = "Pérdidas netas"
L["Net Profit"] = "Beneficios netos"
L["Source"] = "Fuente"
L["Incomings"] = "Ingresos"
L["Outgoings"] = "Gastos"
L["Week Start"] = "Comienzo de la semana"
L["Sum Total"] = "Suma total"
L["Character"] = "Personaje"
L["Money"] = "Dinero"
L["Updated"] = "Actualizado"

-- Section Labels
L["Quest Rewards"] = "Recompensas de misiones"
L["Merchants"] = "Mercaderes"
L["Trade Window"] = "Ventana de comercio"
L["Mail"] = "Correo"
L["Training Costs"] = "Gastos de entrenamiento"
L["Taxi Fares"] = "Precios de transporte"
L["Unknown"] = "Desconocido"
L["Repair Costs"] = "Gastos de reparación"
L["LFD, LFR and Scen."] = "LFD, LFR y ambiente"

-- Buttons
L["Reset"] = "Reiniciar"
L["Options"] = "Configuraciones"
L["Exit"] = "Salir"

-- Tabs' name
L["This Session"] = "Esta sesión"
L["Today"] = "Hoy"
L["Prv. Day"] = "Día ant."
L["This Week"] = "Esta semana"
L["Prv. Week"] = "Semana  ant."
L["This Month"] = "Este mes"
L["Prv. Month"] = "Mes ant."
L["This Year"] = "Este año"
L["Prv. Year"] = "Año ant."
L["Total"] = "Total"
L["All Chars"] = "Todos los personajes"

-- Tabs' tooltip
L["TT1"] = "Esta sesión"
L["TT2"] = "Hoy"
L["TT3"] = "Ayer"
L["TT4"] = "Esta semana"
L["TT5"] = "Semana anterior"
L["TT6"] = "Este mes"
L["TT7"] = "Mes anterior"
L["TT8"] = "Este año"
L["TT9"] = "Año anterior"
L["TT10"] = "Total"
L["TT11"] = "Todos los personajes"

-- Options
L["Accountant Classic Options"] = "Opciones de contabilidad"
L["Show minimap button"] = "Mostrar el botón del minimapa"
L["Show money"] = "Mostrar dinero"
L["Show money on minimap button's tooltip"] = "Mostrar dinero en el mensaje emergente del botón del minimapa"
L["Show session info"] = "Mostrar información de sesión"
L["Show session info on minimap button's tooltip"] = "Mostrar información de sesión en la ventana emergente del botón del minimapa"
L["Show money on screen"] = "Mostrar info de dinero en pantalla"
L["Reset position"] = "Reiniciar posición"
L["Reset money frame's position"] = "Reinicia la posición del marco del dinero"
L["Minimap Button Settings"] = "Configuración del botón del minimapa"
L["Minimap Button Position"] = "Posición del botón del minimapa"
L["Start of Week"] = "Comienzo de la semana"
L["Done"] = "Listo"
L["Display Instruction Tips"] = "Consejos de instrucciones de visualización"
L["Toggle whether to display minimap button or floating money frame's operation tips."] = "Alternar entre mostrar el botón del minimapa o los consejos de operación del marco de dinero flotante."
L["Select the character to be removed:"] = "Selecciona el personaje a ser eliminado:"
L["The selected character's Accountant Classic data will be removed."] = "Se eliminarán los datos de Accountant Classic del personaje seleccionado."
L["|cffffffff\"%s - %s|cffffffff\" character's Accountant Classic data has been removed."] = "Los datos de Accountant Classic del personaje |cffffffff\"%s - %s|cffffffff\" han sido eliminados."
L["Select the date format:"] = "Selecciona el formato de la fecha:"
L["Date format showing in \"All Chars\" and \"Week\" tabs"] = "Formato de fecha que se muestra en las pestañas de \"Personajes\" y \"Semana\""
L["Show net income / expanse on LDB"] = "Mostrar ingresos netos / expansión en LDB"
L["Show current session's net income / expanse instead of total money on LDB"] = "Muestra los ingresos / expansión netos de la sesión actual en lugar del dinero total en LDB"
L["Show all realms' characters info"] = "Mostrar información de personajes de todos los reinos."
L["Enable to show all characters' money info from all realms. Disable to only show current realm's character info."] = "Activar para mostrar la información monetaria de todos los personajes de todos los reinos. Desactivar para mostrar solo la información del personaje del reino actual."
L["Track location of incoming / outgoing money"] = "Seguimiento de la ubicación del dinero entrante / saliente"
L["Enable to track the location of each incoming / outgoing money and also show the breakdown info while mouse hover each of the expenditure."] = "Activar el seguimiento de la ubicación de cada dinero entrante / saliente y también muestre la información de desglose mientras pasa el ratón sobre cada uno de los gastos."
L["Also track subzone info"] = "Rastrea también información de subzonas"
L["Enable to also track on the subzone info. For example: Suramar - Sanctum of Order"] = "Activar para rastrear también la información de la subzona. Por ejemplo: Suramar - Santuario del orden"
L["Converts a number into a localized string, grouping digits as required."] = "Convierte un número en una cadena localizada, agrupando dígitos según sea necesario."
L["Accountant Classic Frame's Scale"] = "Escala del marco de Accountant Classic"
L["Accountant Classic Frame's Transparency"] = "Transparencia del marco de Accountant Classic"
L["Accountant Classic Floating Info's Scale"] = "Escala de la información flotante de Accountant Classic"
L["Accountant Classic Floating Info's Transparency"] = "Transparencia de la información flotante de Accountant Classic"
L["LDB Display Settings"] = "Configuración de pantalla LDB"
L["LDB Display Type"] = "Tipo de pantalla LDB"
L["Data type to be displayed on LDB"] = "Tipo de datos que se mostrarán en LDB"
L["General and Data Display Format Settings"] = "Configuración general y de formato de visualización de datos"
L["Main Frame's Scale and Alpha Settings"] = "Configuración de escala y alfa del marco principal"
L["Onscreen Actionbar's Scale and Alpha Settings"] = "Configuración de escala y alfa de la barra de acciones en pantalla"
L["Character Data's Removal"] = "Eliminación de datos de personajes"
L["Profile Options"] = "Configuraciones de perfil"
L["Scale and Transparency"] = "Escala y transparencia"
L["Remember character selected"] = "Recordar personaje seleccionado"
L["Remember the latest character selection in dropdown menu."] = "Recuerde la última selección de personajes en el menú desplegable."
L["Show all factions' characters info"] = "Mostrar información de personajes de todas las facciones."
L["Enable to show all characters' money info from all factions. Disable to only show all characters' info from current faction."] = "Activar para mostrar la información monetaria de todos los personajes de todas las facciones. Desactivar para mostrar solo la información de todos los personajes de la facción actual."
L["Enhanced Tracking Options"] = "Opciones de seguimiento mejoradas"
L["All Factions"] = "Todas las facciones"
L["All Servers"] = "Todos los servidores"

-- Misc
L["Are you sure you want to reset the \"%s\" data?"] = "¿Estás seguro de que quieres restablecer los datos \"%s\"?"
L["New Accountant Classic profile created for %s"] = "Nuevo perfil de Contador Clásico creado para %s"
L["Loaded Accountant Classic Profile for %s"] = "Perfil de Accountant Classic cargado para %s"
L["Accountant Classic loaded."] = "Accountant Classic cargado."
L["g "] = "o"
L["s "] = "s"
L["c"] = "c"
L["About"] = "Acerca de"
L["Show All Characters"] = "Mostrar todos los personajes"
L["Show all characters' incoming and outgoing data."] = "Muestra todos los datos de ingresos y gastos de todos los personajes."

-- Amount string for CHAT_MESSAGE_MONEY search
L["(%d+) Gold"] = "(%d+) oro"
L["(%d+) Silver"] = "(%d+) plata"
L["(%d+) Copper"] = "(%d+) cobre"

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT_CLASSIC_TITLE"] = "Atajos de Accountant Classic"
L["BINDING_NAME_ACCOUNTANT_CLASSIC_TOGGLE"] = "Alternar el mostrar Accountant Classic"
