-- esMX.lua (Spanish - Latin America)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "esMX")
if not L then return end

L["MINIAURAS_COUNTDOWN_COLORS_NOTICE"] = "MiniAuras gestiona los colores de umbral de la cuenta regresiva. Configúralos en MiniAuras > Misc > Countdown Colours."
L["MINIAURAS_SWIPE_ALPHA_DESC"] = "0 % = transparente, 100 % = totalmente oscuro. Se aplica a todos los grupos de módulos de MiniAuras; el 80 % coincide con el barrido que dibuja MiniAuras."

-- Core
L["MiniAuras test command is unavailable."] = "El comando de prueba de MiniAuras no está disponible."

-- Category Names
L["Action Bars"] = "Barras de acción"
L["Nameplates"] = "Placas de nombre"
L["Unit Frames"] = "Marcos de unidad"
L["Party / Raid Frames"] = "Marcos de grupo/banda"
L["CooldownManager"] = "CooldownManager"
L["MiniAuras"] = "MiniAuras"

-- Group Headers
L["General"] = "General"
L["Typography (Cooldown Numbers)"] = "Tipografía (números de reutilización)"
L["Swipe Animation"] = "Animación de barrido"
L["Stack Counters / Charges"] = "Contadores de acumulación / cargas"
L["Maintenance"] = "Mantenimiento"
L["Danger Zone"] = "Zona de peligro"
L["Style"] = "Estilo"
L["Positioning"] = "Posicionamiento"
L["CooldownManager Viewers"] = "Visores de CooldownManager"
L["MiniAuras Frame Types"] = "Tipos de marcos de MiniAuras"

-- Toggles & Settings
L["Enable %s"] = "Activar %s"
L["Toggle styling for this category."] = "Alterna el estilo de esta categoría."
L["Font Face"] = "Fuente"
L["Font"] = "Fuente"
L["Size"] = "Tamaño"
L["Outline"] = "Contorno"
L["Color"] = "Color"
L["Hide Numbers"] = "Ocultar números"
L["Compact Party / Raid Aura Text"] = "Texto de aura compacta de grupo/banda"
L["Enable Party Aura Text"] = "Activar texto de aura de grupo"
L["Enable Raid Aura Text"] = "Activar texto de aura de banda"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Oculta el texto por completo (útil si solo quieres el borde de barrido o las acumulaciones)."
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = "Muestra texto de cuenta atrás con estilo en los iconos de beneficios y perjuicios de Blizzard CompactPartyFrame. Si se desactiva, se oculta el texto de las auras en los marcos de grupo."
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = "Muestra texto de cuenta atrás con estilo en los iconos de beneficios y perjuicios de Blizzard CompactRaidFrame. Si se desactiva, se oculta el texto de las auras en los marcos de banda."
L["Anchor Point"] = "Punto de anclaje"
L["Offset X"] = "Desplazamiento X"
L["Offset Y"] = "Desplazamiento Y"
L["Essential Viewer Size"] = "Tamaño del visor Essential"
L["Utility Viewer Size"] = "Tamaño del visor Utility"
L["Buff Icon Viewer Size"] = "Tamaño del visor de iconos de beneficios"
L["Essential Viewer Stack Size"] = "Tamaño de acumulaciones del visor Essential"
L["Utility Viewer Stack Size"] = "Tamaño de acumulaciones del visor Utility"
L["Buff Icon Viewer Stack Size"] = "Tamaño de acumulaciones del visor de iconos de beneficios"
L["CC Text Size"] = "Tamaño del texto de CC"
L["Nameplates Text Size"] = "Tamaño del texto de las placas de nombre"
L["Portraits Text Size"] = "Tamaño del texto de los retratos"
L["Alerts / Overlay Text Size"] = "Tamaño del texto de alertas / superposición"
L["Toggle Test Icons"] = "Alternar iconos de prueba"
L["Show Swipe Edge"] = "Mostrar borde de barrido"
L["Shows the white line indicating cooldown progress."] = "Muestra la línea blanca que indica el progreso de reutilización."
L["Edge Thickness"] = "Grosor del borde"
L["Scale of the swipe line (1.0 = Default)."] = "Escala de la línea de barrido (1.0 = por defecto)."
L["Customize Stack Text"] = "Personalizar texto de acumulación"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Toma el control del contador de cargas (por ejemplo, 2 cargas de Conflagrar)."
L["Reset %s"] = "Restablecer %s"
L["Revert this category to default settings."] = "Devuelve esta categoría a su configuración predeterminada."
L["Toggle MiniAuras' built-in test icons using /miniauras test."] = "Activa o desactiva los iconos de prueba integrados de MiniAuras con /miniauras test."

-- Outline Values
L["None"] = "Ninguno"
L["Thick"] = "Grueso"
L["Mono"] = "Mono"

-- Anchor Point Values
L["Bottom Right"] = "Inferior derecha"
L["Bottom Left"] = "Inferior izquierda"
L["Top Right"] = "Superior derecha"
L["Top Left"] = "Superior izquierda"
L["Center"] = "Centro"
L["Top"] = "Superior"
L["Bottom"] = "Inferior"
L["Left"] = "Izquierda"
L["Right"] = "Derecha"

-- General Tab
L["Factory Reset (All)"] = "Restablecimiento de fábrica (todo)"
L["Resets the entire profile to default values and reloads the UI."] = "Restablece todo el perfil a los valores predeterminados y recarga la interfaz."
L["Import / Export"] = "Importar / Exportar"
L["PROFILE_IMPORT_EXPORT_DESC"] = "Exporta el perfil activo de AceDB a una cadena compartible o importa una cadena para reemplazar la configuración actual del perfil."
L["Export current profile"] = "Exportar perfil actual"
L["Generate export"] = "Generar exportación"
L["Export code"] = "Código de exportación"
L["Generate an export string, then click inside this box and copy it with Ctrl+C."] = "Genera una cadena de exportación y luego haz clic dentro de este cuadro para copiarla con Ctrl+C."
L["Import profile"] = "Importar perfil"
L["Import code"] = "Código de importación"
L["Paste an exported string here, then click Import."] = "Pega aquí una cadena exportada y luego haz clic en Importar."
L["Import"] = "Importar"
L["Importing will overwrite the current profile settings. Continue?"] = "La importación sobrescribirá la configuración actual del perfil. ¿Continuar?"
L["Export string generated. Copy it with Ctrl+C."] = "Cadena de exportación generada. Cópiala con Ctrl+C."
L["Profile import completed."] = "Importación de perfil completada."
L["No active profile available."] = "No hay ningún perfil activo disponible."
L["Failed to encode export string."] = "No se pudo codificar la cadena de exportación."
L["Paste an import string first."] = "Pega primero una cadena de importación."
L["Invalid import string format."] = "Formato de cadena de importación no válido."
L["Failed to decode import string."] = "No se pudo decodificar la cadena de importación."
L["Failed to decompress import string."] = "No se pudo descomprimir la cadena de importación."
L["Failed to deserialize import string."] = "No se pudo deserializar la cadena de importación."

-- Banner
L["BANNER_DESC"] = "Configuración minimalista para tus reutilizaciones. Selecciona una categoría a la izquierda para comenzar."

-- Chat Messages
L["%s settings reset."] = "Ajustes de %s restablecidos."
L["Profile reset. Reloading UI..."] = "Perfil restablecido. Recargando la interfaz..."

-- Status Indicators
L["ON"] = "ON"
L["OFF"] = "OFF"
L["Retired"] = "Retirado"

-- General Dashboard
L["Enable categories styling"] = "Activar estilo de categorías"
L["LIVE_CONTROLS_DESC"] = "Los cambios se aplican al instante. Mantén activadas solo las categorías que usas para tener una configuración más limpia."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Activar Marcos de grupo/banda actúa como interruptor principal de esta categoría. Activar texto de aura de banda extiende el mismo estilo a los marcos de banda de Blizzard."
L["PARTY_RAID_FRAMES_RETIRED_DESC"] = "El soporte de Marcos de grupo/banda se ha retirado. Desde el parche 12.0.5 de Blizzard, MiniCE ya no enlaza ni aplica estilo a los marcos compactos de grupo y banda."
L["PARTY_RAID_FRAMES_AURAS_TITLE"] = "Nuevo addon en desarrollo: Raid Frame Auras"
L["PARTY_RAID_FRAMES_AURAS_DESC"] = "Raid Frame Auras ya está disponible en CurseForge. Se mantiene separado de MiniCE porque usa sus propios marcos superpuestos en lugar de aplicar estilo a los iconos existentes de Blizzard, por lo que encaja mejor como addon independiente."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Copia este enlace para abrir la página del proyecto en CurseForge en tu navegador."
L["Copy this link to open Raid Frame Auras on CurseForge."] = "Copia este enlace para abrir Raid Frame Auras en CurseForge."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Copia este enlace para ver otros proyectos de Anahkas en CurseForge."

-- Help
L["Help & Support"] = "Ayuda y soporte"
L["Project"] = "Proyecto"
L["Useful Addons"] = "Addons útiles"
L["Support & Feedback"] = "Soporte y comentarios"
L["MCE_HELP_INTRO"] = "Enlaces rápidos del proyecto y un par de addons que merece la pena probar."
L["HELP_SUPPORT_DESC"] = "Las sugerencias y los comentarios siempre son bienvenidos.\n\nSi encuentras un error o tienes una idea para una función, no dudes en dejar un comentario o un mensaje privado en CurseForge."
L["HELP_COMPANION_DESC"] = "Opciones limpias que encajan bien con MiniCE."
L["HELP_MINIAURAS_DESC"] = "Conjunto de auras personalizadas, control de masas, reutilizaciones y herramientas JcJ. MiniCE también puede personalizar los textos de reutilización."
L["Copy this link to open the MiniAuras CurseForge page in your browser."] = "Copia este enlace para abrir la página de MiniAuras en CurseForge en tu navegador."
L["HELP_PVPTAB_DESC"] = "Hace que TAB seleccione solo jugadores en JcJ. Ideal para arenas y campos de batalla."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Copia este enlace para abrir Smart PvP Tab Targeting en CurseForge."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Activa o desactiva tus categorías principales de reutilización desde un solo lugar."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Esta acción no se puede deshacer. Tu perfil se restablecerá por completo y la interfaz se recargará."
L["MAINTENANCE_DESC"] = "Devuelve esta categoría a los valores de fábrica. Las demás categorías no se verán afectadas."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Da estilo a las reutilizaciones de tus barras de acción."
L["NAMEPLATE_DESC"] = "Da estilo a las reutilizaciones de las placas de nombre enemigas y aliadas."
L["UNITFRAME_DESC"] = "Da estilo a las reutilizaciones de auras en los marcos de objetivo, foco y otros marcos de unidad compatibles."
L["COOLDOWNMANAGER_DESC"] = "Da estilo a las reutilizaciones de iconos de CooldownManager."
L["MINIAURAS_DESC"] = "Da estilo a los iconos de reutilización de MiniAuras."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Colores dinámicos del texto"
L["Color by Remaining Time"] = "Colorear por tiempo restante"
L["Dynamically colors the countdown text based on how much time is left."] = "Colorea dinámicamente el texto de la cuenta atrás según el tiempo restante."
L["DYNAMIC_COLORS_DESC"] = "Cambia el color del texto según la duración restante de la reutilización. Sustituye el color estático de arriba cuando está activado."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Los umbrales de tiempo restante pueden permitirse o bloquearse por cada categoría activa de MiniCE. El manejo de duración sigue siendo seguro incluso al cruzar medianoche cuando Blizzard expone valores ocultos."
L["Expiring Soon"] = "A punto de expirar"
L["Short Duration"] = "Duración corta"
L["Long Duration"] = "Duración larga"
L["Threshold (seconds)"] = "Umbral (segundos)"
L["Default Color"] = "Color predeterminado"
L["Color used when the remaining time exceeds all thresholds."] = "Color usado cuando el tiempo restante supera todos los umbrales."

-- Abbreviation
L["Abbreviate Above"] = "Abreviar por encima de"
L["Abbreviate Above (seconds)"] = "Abreviar por encima de (segundos)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "Los números de enfriamiento por encima de este umbral se abreviarán (ej. 5m en vez de 300)."
L["ABBREV_THRESHOLD_DESC"] = "Controla cuándo los números de enfriamiento cambian a formato abreviado. Los temporizadores por encima de este umbral muestran valores abreviados como 5m o 1h."

-- MyDRs / sArena
L["MYDRS_SWIPE_ALPHA_DESC"] = "0 % = transparente, 100 % = totalmente oscuro. Sustituye el ajuste Cooldown Swipe Alpha de MyDRs mientras esta categoría esté activada; el 100 % coincide con el barrido que dibuja MyDRs."
L["MyDRs test command is unavailable."] = "El comando de prueba de MyDRs no está disponible."
L["Toggle MyDRs' built-in test icons using /mydrs test."] = "Activa o desactiva los iconos de prueba integrados de MyDRs con /mydrs test."
L["sArena slash command is unavailable."] = "El comando slash de sArena no está disponible."

-- Category Names
L["Player Auras"] = "Auras del jugador"
L["CooldownManagerCentered"] = "CooldownManagerCentered"
L["HealerCC"] = "HealerCC"
L["MyDRs"] = "MyDRs"
L["sArena"] = "sArena"
L["TellMeWhen"] = "TellMeWhen"
L["Profiles"] = "Perfiles"
L["ShinyAuras"] = "ShinyAuras"
L["Dominos"] = "Dominos"
L["ElvUI"] = "ElvUI"

-- Group Headers
L["Swipe Edge"] = "Borde de barrido"
L["MiniAuras Module Groups"] = "Grupos de módulos de MiniAuras"
L["sArena Cooldown Types"] = "Tipos de reutilización de sArena"
L["Aura Targets"] = "Objetivos de auras"
L["Buff Styling"] = "Estilo de beneficios"
L["Debuff Styling"] = "Estilo de perjuicios"
L["External Defensive Buffs Styling"] = "Estilo de beneficios defensivos externos"

-- Toggles & Settings
L["Style Buffs"] = "Estilizar beneficios"
L["Style Debuffs"] = "Estilizar perjuicios"
L["Style External Defensive Buffs"] = "Estilizar beneficios defensivos externos"
L["Style Blizzard's default player buff buttons."] = "Estiliza los iconos de beneficios predeterminados del jugador de Blizzard."
L["Style Blizzard's default player debuff buttons."] = "Estiliza los iconos de perjuicios predeterminados del jugador de Blizzard."
L["Style Blizzard's external defensive buff buttons."] = "Estiliza los iconos de beneficios defensivos externos de Blizzard."
L["Timer Inside Icon"] = "Temporizador dentro del icono"
L["Place the aura timer in the center of the icon instead of Blizzard's default outside position."] = "Coloca el temporizador del aura en el centro del icono en lugar de la posición externa predeterminada de Blizzard."
L["Hide Swipe"] = "Ocultar barrido"
L["Only Mine (Timer Text)"] = "Solo las mías (texto del temporizador)"
L["Aura Visibility"] = "Visibilidad de auras"
L["Only My Debuffs"] = "Solo mis perjuicios"
L["Only My Buffs"] = "Solo mis beneficios"
L["Disable fading/blinking"] = "Desactivar desvanecido/parpadeo"
L["Enables styled countdown text on Party / Raid Frames. When disabled, both party and raid aura text styling are turned off."] = "Activa el texto de cuenta atrás con estilo en Marcos de grupo/banda. Si se desactiva, se apaga por completo el estilo del texto de aura de grupo y de banda."
L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."] = "Aplica también texto de cuenta atrás con estilo a los iconos de beneficios y perjuicios de Blizzard CompactRaidFrame. Requiere que Marcos de grupo/banda esté activado."
L["Hide the swipe animation for this frame group (countdown text still shows)."] = "Oculta la animación de barrido para este grupo de marcos (el texto de cuenta atrás se sigue mostrando)."
L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."] = "Muestra el texto del temporizador de reutilización solo en tus propias auras. Usa la heurística de auras grandes de Blizzard en lugar de una comprobación directa de sourceUnit."
L["UNITFRAME_ONLY_MINE_DESC"] = "Muestra el texto del temporizador solo en las auras lanzadas por ti. Los contenedores de objetivo/foco de MiniCE para WoW 12.1 usan el filtro de jugador de Blizzard; los marcos de addons compatibles y antiguos usan sus metadatos de grupo o el recurso de auras grandes."
L["UNITFRAME_ONLY_MINE_DEBUFFS_DESC"] = "Oculta los perjuicios lanzados por otros jugadores en los marcos de objetivo y foco. MiniCE gestiona estos contenedores de auras en WoW 12.1, por lo que el filtro de perjuicios propio de Blizzard ya no llega a ellos."
L["UNITFRAME_ONLY_MINE_BUFFS_DESC"] = "Oculta los beneficios lanzados por otros jugadores en los marcos de objetivo y foco. MiniCE gestiona estos contenedores de auras en WoW 12.1, por lo que el filtro de beneficios propio de Blizzard ya no llega a ellos."
L["Cast Bar"] = "Barra de lanzamiento"
L["Reposition Cast Bar"] = "Reposicionar la barra de lanzamiento"
L["UNITFRAME_CASTBAR_REPOSITION_DESC"] = "Ancla las barras de lanzamiento de objetivo y foco bajo la última fila de beneficios/perjuicios. MiniCE gestiona estos contenedores de auras en WoW 12.1; de lo contrario, la barra de Blizzard queda pegada al marco y las solapa."
L["Keeps player aura buttons fully opaque when they are close to expiring."] = "Mantiene los iconos de auras del jugador completamente opacos cuando están a punto de expirar."
L["When a CooldownManager slot is temporarily showing aura time, use a dedicated buff color instead of remaining-time threshold colors."] = "Usa un color de beneficio específico en lugar de los colores de umbral de tiempo restante cuando un espacio de CooldownManager muestra temporalmente la duración de un aura."
L["Applied while the slot is showing aura duration. When the aura ends and the slot switches back to cooldown time, threshold colors resume."] = "Se aplica mientras el espacio muestra la duración del aura. Cuando el aura termina y el espacio vuelve al tiempo de reutilización, se reanudan los colores de umbral."
L["Buff / Debuff Size"] = "Tamaño de beneficio/perjuicio"
L["Defensive Buff Size"] = "Tamaño de beneficio defensivo"
L["Use Buff Color"] = "Usar color de beneficio"
L["Buff Color"] = "Color de beneficio"
L["Essential Viewer"] = "Visor Essential"
L["Utility Viewer"] = "Visor Utility"
L["Buff Icon Viewer"] = "Visor de iconos de beneficios"
L["CC Frames Text Size"] = "Tamaño del texto de marcos de CC"
L["CC / Friendly Frames Text Size"] = "Tamaño del texto de CC / marcos aliados"
L["Raid Frame Auras Text Size"] = "Tamaño del texto de auras en marcos de banda"
L["Class Icon Text Size"] = "Tamaño del texto del icono de clase"
L["DR Cooldown Text Size"] = "Tamaño del texto de reutilización de DR"
L["Alerts / Trackers / Custom Auras Text Size"] = "Tamaño del texto de alertas/seguimientos/auras personalizadas"
L["Trinket / Racial Text Size"] = "Tamaño del texto de abalorio/racial"
L["Show Test Frames"] = "Mostrar marcos de prueba"
L["Hide Test Frames"] = "Ocultar marcos de prueba"
L["Show Swipe Animation"] = "Mostrar animación de barrido"
L["Shows the dark overlay that sweeps during a cooldown."] = "Muestra la superposición oscura que barre durante una reutilización."
L["Swipe Shade Alpha"] = "Opacidad de la sombra de barrido"
L["0% = transparent, 100% = full dark."] = "0 % = transparente, 100 % = totalmente oscuro."
L["Reverse Swipe"] = "Invertir barrido"
L["Reverse the swipe direction so the shade fills in the opposite direction."] = "Invierte la dirección del barrido para que la sombra se rellene en la dirección opuesta."
L["Hide Charge Timers"] = "Ocultar temporizadores de cargas"
L["Hide timers while charges are restoring (only show timer when all charges are spent)."] = "Oculta los temporizadores mientras se restauran las cargas (solo muestra el temporizador cuando se han gastado todas las cargas)."
L["Hide Stack Text"] = "Ocultar texto de acumulación"
L["Hide stacks and charges entirely."] = "Oculta por completo las acumulaciones y las cargas."
L["MiniAuras text settings are grouped by module family so similar widgets share the same countdown size."] = "Los ajustes de texto de MiniAuras se agrupan por familia de módulos para que los widgets similares compartan el mismo tamaño de cuenta atrás."
L["Applies to MiniAuras CC module (enemy crowd controls)."] = "Se aplica al módulo CC de MiniAuras (controles de masas enemigos)."
L["Applies to MiniAuras CC, Friendly CDs, and Friendly Indicators modules."] = "Se aplica a los módulos CC, Friendly CDs y Friendly Indicators de MiniAuras."
L["Applies to the MiniAuras Raid Frame Auras module."] = "Se aplica al módulo Raid Frame Auras de MiniAuras."
L["Applies to MiniAuras portrait icons."] = "Se aplica a los iconos de retrato de MiniAuras."
L["Applies to MiniAuras Alerts, Healer CC, Kick Timer, Precognition, Trinkets, and Custom Auras modules."] = "Se aplica a los módulos Alerts, Healer CC, Kick Timer, Precognition, Trinkets y Custom Auras de MiniAuras."
L["Show sArena test frames using /sarena test."] = "Muestra los marcos de prueba de sArena con /sarena test."
L["Hide sArena test frames using /sarena hide."] = "Oculta los marcos de prueba de sArena con /sarena hide."

-- Import / Export
L["Import string is too large."] = "La cadena de importación es demasiado grande."
L["Import profile contains invalid data."] = "El perfil importado contiene datos no válidos."
L["Failed to apply imported profile."] = "No se pudo aplicar el perfil importado."

-- Chat Messages
L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"] = "Algunos cambios requieren recargar la interfaz para aplicarse por completo.\n\n¿Recargar la interfaz ahora?"

-- Addon Integrations
L["Addon Integrations"] = "Integraciones de addons"
L["ADDON_INTEGRATIONS_DESC"] = "Activa o desactiva los puentes de addons opcionales que enrutan reutilizaciones externas a las categorías de MiniCE."
L["Routes ShinyAuras cooldowns through the Unit Frames category. Disable this if you want ShinyAuras to keep its native countdowns untouched."] = "Enruta las reutilizaciones de ShinyAuras a través de la categoría Marcos de unidad. Desactívalo si quieres que ShinyAuras conserve sus cuentas atrás nativas sin modificar."
L["Routes supported Dominos action bar cooldowns through the Action Bars category. Disable this if you want Dominos to keep its native cooldown styling untouched."] = "Enruta las reutilizaciones compatibles de las barras de acción de Dominos a través de la categoría Barras de acción. Desactívalo si quieres que Dominos conserve su estilo de reutilización nativo sin modificar."
L["Routes supported Bartender4 action bar cooldowns through the Action Bars category. Disable this if you want Bartender4 to keep its native cooldown styling untouched."] = "Enruta las reutilizaciones compatibles de las barras de acción de Bartender4 a través de la categoría Barras de acción. Desactívalo si quieres que Bartender4 conserve su estilo de reutilización nativo sin modificar."
L["Routes supported ElvUI action bar, unit frame, and nameplate cooldowns through MiniCE categories. Disable this if you want ElvUI to keep its native cooldown styling untouched."] = "Enruta las reutilizaciones compatibles de barras de acción, marcos de unidad y placas de nombre de ElvUI a través de las categorías de MiniCE. Desactívalo si quieres que ElvUI conserve su estilo de reutilización nativo sin modificar."
L["CooldownManagerCentered also styles %s. This may add a small performance cost. Disable CMC timer fonts if you want MiniCE to remain the only owner of those viewer timers."] = "CooldownManagerCentered también da estilo a %s. Esto puede añadir un pequeño coste de rendimiento. Desactiva las fuentes de temporizador de CMC si quieres que MiniCE sea el único responsable de esos temporizadores de visor."

-- Help
L["HELP_ARENADR_DESC"] = "Rastrea las reducciones progresivas enemigas directamente en las placas de nombre en Arena."
L["Copy this link to open ArenaDR Nameplates on CurseForge."] = "Copia este enlace para abrir ArenaDR Nameplates en CurseForge."

-- Category Descriptions
L["BETTERBLIZZFRAMES_UNITFRAME_CONFLICT_WARNING"] = "BetterBlizzFrames está activo, por lo que se ha desactivado el estilo de marcos de unidad de MiniCE para evitar posibles conflictos. Próximamente habrá un adaptador específico para BetterBlizzFrames."
L["BETTERBLIZZPLATES_NAMEPLATE_CONFLICT_WARNING"] = "BetterBlizzPlates está activo, por lo que se ha desactivado el estilo de placas de nombre de MiniCE para evitar posibles conflictos."
L["PLAYERAURA_DESC"] = "Da estilo a las reutilizaciones de beneficios y perjuicios del jugador de Blizzard."
L["HEALERCC_DESC"] = "Da estilo a las reutilizaciones de alertas de HealerCC aliadas y enemigas."
L["MYDRS_DESC"] = "Da estilo a los iconos de reutilización de reducciones progresivas de MyDRs. MyDRs conserva su propia etiqueta de estado de DR (50 % / IMM)."
L["SARENA_DESC"] = "Da estilo a los temporizadores de reutilización de sArena_Reloaded."
L["TELLMEWHEN_DESC"] = "Da estilo al texto de reutilización y a los bordes de barrido de TellMeWhen."
L["TELLMEWHEN_TIMER_OPTIONS_NOTICE"] = "La visibilidad del temporizador, el texto del temporizador, la dirección del sombreado y la visualización del GCD siguen controlados por TellMeWhen. La visibilidad y el grosor del borde de barrido se controlan aquí."
L["TELLMEWHEN_EDGE_SCALE_DESC"] = "Escala el borde de barrido de TellMeWhen cuando MiniCE lo ha activado."

-- Dynamic Text Colors
L["Allow Threshold Colors"] = "Permitir colores de umbral"
L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."] = "Permite que los umbrales globales de \"Colorear por tiempo restante\" sustituyan el color de texto estático de esta categoría."
L["Behavior"] = "Comportamiento"
L["Advanced Threshold Settings"] = "Ajustes avanzados de umbrales"
L["Threshold Colors"] = "Colores de umbral"
L["THRESHOLD_COLORS_DESC"] = "Cada banda define el límite y el color usados para ese rango de tiempo restante."
L["Threshold Transition Offset"] = "Desfase de transición de umbral"
L["Moves the start of each next color band. Negative values switch slightly earlier."] = "Desplaza el inicio de cada siguiente banda de color. Los valores negativos hacen que el cambio ocurra un poco antes."
L["Beyond Thresholds Color"] = "Color más allá de los umbrales"

-- Abbreviation
L["Show Tenths Below (seconds)"] = "Mostrar décimas por debajo de (segundos)"
L["Cooldown numbers below this threshold will show one decimal place (e.g. 8.7). Set 0 to disable."] = "Los números de enfriamiento por debajo de este umbral mostrarán un decimal (ej. 8,7). Pon 0 para desactivarlo."

-- Performance Warning
L["PERF_WARNING_DESC"] = "Esta función puede afectar al rendimiento y provocar caídas de FPS. Úsala solo en equipos potentes."

-- Font Options
L["Game Default"] = "Predeterminada del juego"
