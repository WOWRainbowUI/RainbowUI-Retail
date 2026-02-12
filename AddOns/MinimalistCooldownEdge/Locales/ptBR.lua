-- ptBR.lua (Brazilian Portuguese)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "ptBR")
if not L then return end

-- Core
L["Cannot open options in combat."] = "Não é possível abrir opções em combate."

-- Category Names
L["Action Bars"] = "Barras de Ação"
L["Nameplates"] = "Placas de Nome"
L["Unit Frames"] = "Quadros de Unidade"
L["CD Manager & Others"] = "Gerenciador de CD e Outros"

-- Group Headers
L["General"] = "Geral"
L["State"] = "Estado"
L["Typography (Cooldown Numbers)"] = "Tipografia (Números de Recarga)"
L["Swipe Animation"] = "Animação de Varredura"
L["Stack Counters / Charges"] = "Contadores de Acúmulo / Cargas"
L["Maintenance"] = "Manutenção"
L["Performance & Detection"] = "Desempenho e Detecção"
L["Danger Zone"] = "Zona de Perigo"
L["Style"] = "Estilo"
L["Positioning"] = "Posicionamento"

-- Toggles & Settings
L["Enable %s"] = "Ativar %s"
L["Toggle styling for this category."] = "Alternar estilo para esta categoria."
L["Font Face"] = "Fonte"
L["Font"] = "Fonte"
L["Size"] = "Tamanho"
L["Outline"] = "Contorno"
L["Color"] = "Cor"
L["Hide Numbers"] = "Ocultar Números"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Ocultar o texto completamente (útil se você quiser apenas a borda de varredura ou acúmulos)."
L["Anchor Point"] = "Ponto de Ancoragem"
L["Offset X"] = "Deslocamento X"
L["Offset Y"] = "Deslocamento Y"
L["Show Swipe Edge"] = "Mostrar Borda de Varredura"
L["Shows the white line indicating cooldown progress."] = "Mostra a linha branca indicando o progresso da recarga."
L["Edge Thickness"] = "Espessura da Borda"
L["Scale of the swipe line (1.0 = Default)."] = "Escala da linha de varredura (1.0 = Padrão)."
L["Customize Stack Text"] = "Personalizar Texto de Acúmulo"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Assuma o controle do contador de cargas (ex: 2 acúmulos de Conflagrar)."
L["Reset %s"] = "Redefinir %s"
L["Revert this category to default settings."] = "Reverter esta categoria para as configurações padrão."

-- Outline Values
L["None"] = "Nenhum"
L["Thick"] = "Grosso"
L["Mono"] = "Mono"

-- Anchor Point Values
L["Bottom Right"] = "Inferior Direito"
L["Bottom Left"] = "Inferior Esquerdo"
L["Top Right"] = "Superior Direito"
L["Top Left"] = "Superior Esquerdo"
L["Center"] = "Centro"

-- General Tab
L["Scan Depth"] = "Profundidade de Varredura"
L["How deep the addon looks into UI frames to find cooldowns."] = "Quão profundo o addon procura nos quadros da interface para encontrar recargas."
L["Factory Reset (All)"] = "Restaurar Padrão de Fábrica (Tudo)"
L["Resets the entire profile to default values and reloads the UI."] = "Redefine o perfil inteiro para os valores padrão e recarrega a interface."

-- Banner
L["BANNER_DESC"] = "Configuração minimalista para suas recargas. Selecione uma categoria à esquerda para começar."

-- Scan Depth Help
L["SCAN_DEPTH_HELP"] = "\n|cff00ff00< 10|r : Eficiente (UI padrão)\n|cfffff56910 - 15|r : Moderado (Bartender, Dominos)\n|cffffa500> 15|r : Pesado (ElvUI, Quadros complexos)"

-- Chat Messages
L["%s settings reset."] = "Configurações de %s redefinidas."
L["Profile reset. Reloading UI..."] = "Perfil redefinido. Recarregando interface..."
L["Global Scan Depth changed. A /reload is recommended."] = "Profundidade de varredura global alterada. Um /reload é recomendado."
