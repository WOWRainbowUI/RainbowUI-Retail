-- Mexican Spanish localization for Accountant Classic
-- Thanks to IsabelGarcia
local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "esMX", false)

if not L then return end

-- Header
L["Accountant Classic"] = "Accountant Classic"
L[ [=[Left-Click to open Accountant Classic.
Right-Click for Accountant Classic options.
Left-click and drag to move this button.]=] ] = [=[Clic izquierdo para abrir Accountant Classic.
Clic derecho para opciones de Accountant Classic.]=]
L[ [=[Left-click and drag to move this button.
Right-Click to open Accountant Classic.]=] ] = "Clic derecho para abrir Accountant Classic."
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
L["Options"] = "Opciones"
L["Exit"] = "Salir"

-- Tabs' name
L["This Session"] = "Sesión"
L["Today"] = "Día"
L["This Week"] = "Semana"
L["This Month"] = "Mes"
L["Total"] = "Total"
L["All Chars"] = "Todos los personajes"

-- Options
L["Accountant Classic Options"] = "Opciones de contabilidad"
L["Show minimap button"] = "Mostrar botón minimapa"
L["Show money on screen"] = "Mostrar info de dinero en pantalla"
L["Minimap Button Position"] = "Posición botón minimapa"
L["Start of Week"] = "Comienzo de la semana"
L["Done"] = "Listo"

-- Misc
L["Are you sure you want to reset the \"%s\" data?"] = "¿Estás seguro de que quieres reiniciar?"
L["New Accountant Classic profile created for %s"] = "Nuevo perfil de contabilidad creado para"
L["Loaded Accountant Classic Profile for %s"] = "Perfil cargado para"
L["Accountant Classic loaded."] = "Cargado"
L["g "] = "g"
L["s "] = "s"
L["c"] = "c"
L["About"] = "Acerca de"

-- Amount string for CHAT_MESSAGE_MONEY search
L["(%d+) Gold"] = "(%d+) oro"
L["(%d+) Silver"] = "(%d+) plata"
L["(%d+) Copper"] = "(%d+) cobre"

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT_CLASSIC_TITLE"] = "Accountant Classic"
L["BINDING_NAME_ACCOUNTANT_CLASSIC_TOGGLE"] = "Mostrar / Ocultar Accountant Classic"

-- History ledger
L["Remove, keep history"] = "Eliminar y conservar el historial"
L["Remove with history"] = "Eliminar junto con el historial"
L["Delete the entire Accountant Classic history ledger of all characters?\nThe classic period data is not affected."] = "¿Eliminar todo el historial de Accountant Classic de todos los personajes?\nLos datos por período de las estadísticas tradicionales no se verán afectados."
L["The history ledger has been deleted."] = "Se eliminó el historial."
L["The history ledger was saved by a newer version of Accountant Classic and is read-only."] = "El historial se guardó con una versión más reciente de Accountant Classic y es de solo lectura."
L["History matches today's classic data (%d categories)."] = "El historial coincide con los datos de hoy de las estadísticas tradicionales (%d categorías)."
L["%d categories differ from today's classic data."] = "%d categorías difieren de los datos de hoy de las estadísticas tradicionales."
L["History tracking started today, so money logged earlier today exists only in the classic data."] = "El seguimiento del historial comenzó hoy, por lo que los movimientos de dinero registrados antes de su inicio solo figuran en las estadísticas tradicionales."
L["Resetting the Day tab also causes differences; the history ledger is never reset with it."] = "Restablecer la pestaña del día también genera diferencias; el historial nunca se restablece con ella."
