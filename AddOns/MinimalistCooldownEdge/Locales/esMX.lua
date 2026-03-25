-- esMX.lua (Spanish - Latin America)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "esMX")
if not L then return end

-- Core
L["Cannot open options in combat."] = "No se pueden abrir las opciones en combate."
L["MiniCC test command is unavailable."] = "El comando de prueba de MiniCC no está disponible."

-- Category Names
L["Action Bars"] = "Barras de acción"
L["Nameplates"] = "Placas de nombre"
L["Unit Frames"] = "Marcos de unidad"
L["CooldownManager"] = "CooldownManager"
L["MiniCC"] = "MiniCC"
L["Others"] = "Otros"

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
L["MiniCC Frame Types"] = "Tipos de marcos de MiniCC"

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
L["Toggle MiniCC's built-in test icons using /minicc test."] = "Activa o desactiva los iconos de prueba integrados de MiniCC con /minicc test."

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

-- General Dashboard
L["Enable categories styling"] = "Activar estilo de categorías"
L["LIVE_CONTROLS_DESC"] = "Los cambios se aplican al instante. Mantén activadas solo las categorías que usas para tener una configuración más limpia."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Muestra texto de cuenta atrás con estilo en los iconos de beneficios y perjuicios de Blizzard CompactPartyFrame y CompactRaidFrame. Grupo y banda pueden activarse por separado. Esto es independiente de Otros."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Copia este enlace para abrir la página del proyecto en CurseForge en tu navegador."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Copia este enlace para ver otros proyectos de Anahkas en CurseForge."

-- Help
L["Help & Support"] = "Ayuda y soporte"
L["Project"] = "Proyecto"
L["Useful Addons"] = "Addons útiles"
L["Support & Feedback"] = "Soporte y comentarios"
L["MCE_HELP_INTRO"] = "Enlaces rápidos del proyecto y un par de addons que merece la pena probar."
L["HELP_SUPPORT_DESC"] = "Las sugerencias y los comentarios siempre son bienvenidos.\n\nSi encuentras un error o tienes una idea para una función, no dudes en dejar un comentario o un mensaje privado en CurseForge."
L["HELP_COMPANION_DESC"] = "Opciones limpias que encajan bien con MiniCE."
L["HELP_MINICC_DESC"] = "Seguimiento compacto de CC. MiniCE también puede dar estilo a su texto."
L["Copy this link to open the MiniCC CurseForge page in your browser."] = "Copia este enlace para abrir la página de MiniCC en CurseForge en tu navegador."
L["HELP_PVPTAB_DESC"] = "Hace que TAB seleccione solo jugadores en JcJ. Ideal para arenas y campos de batalla."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Copia este enlace para abrir Smart PvP Tab Targeting en CurseForge."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Activa o desactiva tus categorías principales de reutilización desde un solo lugar."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Esta acción no se puede deshacer. Tu perfil se restablecerá por completo y la interfaz se recargará."
L["MAINTENANCE_DESC"] = "Devuelve esta categoría a los valores de fábrica. Las demás categorías no se verán afectadas."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Personaliza las reutilizaciones de tus barras de acción principales, incluidas Bartender4 y Dominos."
L["NAMEPLATE_DESC"] = "Da estilo a las reutilizaciones que se muestran en placas de nombre enemigas y aliadas (Plater, KuiNameplates, etc.)."
L["UNITFRAME_DESC"] = "Ajusta el estilo de reutilización en los marcos de jugador, objetivo y foco."
L["COOLDOWNMANAGER_DESC"] = "Estilo compartido de iconos para los visores de CooldownManager. El tamaño del texto de la cuenta atrás puede ajustarse por separado para los visores Essential, Utility y de iconos de beneficios."
L["MINICC_DESC"] = "Estilo dedicado para los iconos de reutilización de MiniCC. Admite los iconos de control de masas de MiniCC, placas de nombre, retratos y módulos de tipo superposición cuando MiniCC está cargado."
L["OTHERS_DESC"] = "Categoría comodín para las reutilizaciones que no pertenecen a otras categorías (bolsas, menús, otros addons)."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Colores dinámicos del texto"
L["Color by Remaining Time"] = "Colorear por tiempo restante"
L["Dynamically colors the countdown text based on how much time is left."] = "Colorea dinámicamente el texto de la cuenta atrás según el tiempo restante."
L["DYNAMIC_COLORS_DESC"] = "Cambia el color del texto según la duración restante de la reutilización. Sustituye el color estático de arriba cuando está activado."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Aplica los mismos umbrales de tiempo restante a cada categoría de MiniCE activada, incluido el texto de aura compacta de grupo/banda. El manejo de duración sigue siendo seguro incluso al cruzar medianoche cuando Blizzard expone valores ocultos."
L["Expiring Soon"] = "A punto de expirar"
L["Short Duration"] = "Duración corta"
L["Long Duration"] = "Duración larga"
L["Beyond Thresholds"] = "Más allá de los umbrales"
L["Threshold (seconds)"] = "Umbral (segundos)"
L["Default Color"] = "Color predeterminado"
L["Color used when the remaining time exceeds all thresholds."] = "Color usado cuando el tiempo restante supera todos los umbrales."

-- Abbreviation
L["Abbreviate Above"] = "Abreviar por encima de"
L["Abbreviate Above (seconds)"] = "Abreviar por encima de (segundos)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "Los números de enfriamiento por encima de este umbral se abreviarán (ej. 5m en vez de 300)."
L["ABBREV_THRESHOLD_DESC"] = "Controla cuándo los números de enfriamiento cambian a formato abreviado. Los temporizadores por encima de este umbral muestran valores abreviados como 5m o 1h."
