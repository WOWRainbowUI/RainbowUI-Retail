-- esMX.lua (Latin American Spanish - shares esES translations)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "esMX")
if not L then return end

-- Core
L["Cannot open options in combat."] = "No se pueden abrir las opciones en combate."

-- Category Names
L["Action Bars"] = "Barras de acción"
L["Nameplates"] = "Placas de nombre"
L["Unit Frames"] = "Marcos de unidad"
L["CD Manager & Others"] = "Gestor de CD y Otros"

-- Group Headers
L["General"] = "General"
L["State"] = "Estado"
L["Typography (Cooldown Numbers)"] = "Tipografía (Números de reutilización)"
L["Swipe Animation"] = "Animación de barrido"
L["Stack Counters / Charges"] = "Contadores de acumulación / Cargas"
L["Maintenance"] = "Mantenimiento"
L["Performance & Detection"] = "Rendimiento y Detección"
L["Danger Zone"] = "Zona de peligro"
L["Style"] = "Estilo"
L["Positioning"] = "Posicionamiento"

-- Toggles & Settings
L["Enable %s"] = "Activar %s"
L["Toggle styling for this category."] = "Alternar el estilo para esta categoría."
L["Font Face"] = "Fuente"
L["Game Default"] = "Fuente del juego"
L["Font"] = "Fuente"
L["Size"] = "Tamaño"
L["Outline"] = "Contorno"
L["Color"] = "Color"
L["Hide Numbers"] = "Ocultar números"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Ocultar el texto completamente (útil si solo quieres el borde de barrido o las acumulaciones)."
L["Anchor Point"] = "Punto de anclaje"
L["Offset X"] = "Desplazamiento X"
L["Offset Y"] = "Desplazamiento Y"
L["Show Swipe Edge"] = "Mostrar borde de barrido"
L["Shows the white line indicating cooldown progress."] = "Muestra la línea blanca que indica el progreso de reutilización."
L["Edge Thickness"] = "Grosor del borde"
L["Scale of the swipe line (1.0 = Default)."] = "Escala de la línea de barrido (1.0 = Por defecto)."
L["Customize Stack Text"] = "Personalizar texto de acumulación"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Toma el control del contador de cargas (ej: 2 acumulaciones de Conflagrar)."
L["Reset %s"] = "Restablecer %s"
L["Revert this category to default settings."] = "Revertir esta categoría a los ajustes predeterminados."

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
L["Scan Depth"] = "Profundidad de escaneo"
L["How deep the addon looks into UI frames to find cooldowns."] = "Cuán profundo busca el addon en los marcos de la interfaz para encontrar tiempos de reutilización."
L["Factory Reset (All)"] = "Restablecimiento de fábrica (Todo)"
L["Resets the entire profile to default values and reloads the UI."] = "Restablece el perfil completo a los valores por defecto y recarga la interfaz."

-- Banner
L["BANNER_DESC"] = "Configuración minimalista para tus tiempos de reutilización. Selecciona una categoría a la izquierda para comenzar."

-- Scan Depth Help
L["SCAN_DEPTH_HELP"] = "\n|cff00ff00< 10|r : Eficiente (UI por defecto)\n|cfffff56910 - 15|r : Moderado (Bartender, Dominos)\n|cffffa500> 15|r : Pesado (ElvUI, marcos complejos)"

-- Chat Messages
L["%s settings reset."] = "Ajustes de %s restablecidos."
L["Profile reset. Reloading UI..."] = "Perfil restablecido. Recargando interfaz..."
L["Global Scan Depth changed. A /reload is recommended."] = "Profundidad de escaneo global cambiada. Se recomienda un /reload."
