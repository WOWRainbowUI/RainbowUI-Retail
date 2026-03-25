-- ptBR.lua (Brazilian Portuguese)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "ptBR")
if not L then return end

-- Core
L["Cannot open options in combat."] = "Não é possível abrir as opções em combate."
L["MiniCC test command is unavailable."] = "O comando de teste do MiniCC não está disponível."

-- Category Names
L["Action Bars"] = "Barras de Ação"
L["Nameplates"] = "Placas de Nome"
L["Unit Frames"] = "Quadros de Unidade"
L["CooldownManager"] = "CooldownManager"
L["MiniCC"] = "MiniCC"
L["Others"] = "Outros"

-- Group Headers
L["General"] = "Geral"
L["Typography (Cooldown Numbers)"] = "Tipografia (Números de Recarga)"
L["Swipe Animation"] = "Animação de Varredura"
L["Stack Counters / Charges"] = "Contadores de Acúmulo / Cargas"
L["Maintenance"] = "Manutenção"
L["Danger Zone"] = "Zona de Perigo"
L["Style"] = "Estilo"
L["Positioning"] = "Posicionamento"
L["CooldownManager Viewers"] = "Visualizadores do CooldownManager"
L["MiniCC Frame Types"] = "Tipos de Quadro do MiniCC"

-- Toggles & Settings
L["Enable %s"] = "Ativar %s"
L["Toggle styling for this category."] = "Alterna o estilo desta categoria."
L["Font Face"] = "Fonte"
L["Font"] = "Fonte"
L["Size"] = "Tamanho"
L["Outline"] = "Contorno"
L["Color"] = "Cor"
L["Hide Numbers"] = "Ocultar Números"
L["Compact Party / Raid Aura Text"] = "Texto de Aura Compacta de Grupo/Raide"
L["Enable Party Aura Text"] = "Ativar Texto de Aura do Grupo"
L["Enable Raid Aura Text"] = "Ativar Texto de Aura da Raide"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "Oculta o texto por completo (útil se você quiser apenas a borda de varredura ou os acúmulos)."
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = "Mostra texto de contagem regressiva estilizado nos ícones de bônus e penalidades do Blizzard CompactPartyFrame. Desativar isso oculta o texto de aura nos quadros de grupo."
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = "Mostra texto de contagem regressiva estilizado nos ícones de bônus e penalidades do Blizzard CompactRaidFrame. Desativar isso oculta o texto de aura nos quadros de raide."
L["Anchor Point"] = "Ponto de Ancoragem"
L["Offset X"] = "Deslocamento X"
L["Offset Y"] = "Deslocamento Y"
L["Essential Viewer Size"] = "Tamanho do Visualizador Essential"
L["Utility Viewer Size"] = "Tamanho do Visualizador Utility"
L["Buff Icon Viewer Size"] = "Tamanho do Visualizador de Ícones de Bônus"
L["CC Text Size"] = "Tamanho do Texto de CC"
L["Nameplates Text Size"] = "Tamanho do Texto das Placas de Nome"
L["Portraits Text Size"] = "Tamanho do Texto dos Retratos"
L["Alerts / Overlay Text Size"] = "Tamanho do Texto de Alertas / Sobreposição"
L["Toggle Test Icons"] = "Alternar Ícones de Teste"
L["Show Swipe Edge"] = "Mostrar Borda de Varredura"
L["Shows the white line indicating cooldown progress."] = "Mostra a linha branca indicando o progresso da recarga."
L["Edge Thickness"] = "Espessura da Borda"
L["Scale of the swipe line (1.0 = Default)."] = "Escala da linha de varredura (1.0 = padrão)."
L["Customize Stack Text"] = "Personalizar Texto de Acúmulo"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "Assuma o controle do contador de cargas (por exemplo, 2 cargas de Conflagrar)."
L["Reset %s"] = "Redefinir %s"
L["Revert this category to default settings."] = "Reverte esta categoria para as configurações padrão."
L["Toggle MiniCC's built-in test icons using /minicc test."] = "Ativa ou desativa os ícones de teste internos do MiniCC com /minicc test."

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
L["Factory Reset (All)"] = "Restauração de Fábrica (Tudo)"
L["Resets the entire profile to default values and reloads the UI."] = "Redefine todo o perfil para os valores padrão e recarrega a interface."
L["Import / Export"] = "Importar / Exportar"
L["PROFILE_IMPORT_EXPORT_DESC"] = "Exporta o perfil ativo do AceDB para uma sequência compartilhável ou importa uma sequência para substituir as configurações atuais do perfil."
L["Export current profile"] = "Exportar perfil atual"
L["Generate export"] = "Gerar exportação"
L["Export code"] = "Código de exportação"
L["Generate an export string, then click inside this box and copy it with Ctrl+C."] = "Gere uma sequência de exportação e depois clique nesta caixa para copiá-la com Ctrl+C."
L["Import profile"] = "Importar perfil"
L["Import code"] = "Código de importação"
L["Paste an exported string here, then click Import."] = "Cole aqui uma sequência exportada e depois clique em Importar."
L["Import"] = "Importar"
L["Importing will overwrite the current profile settings. Continue?"] = "A importação sobrescreverá as configurações atuais do perfil. Continuar?"
L["Export string generated. Copy it with Ctrl+C."] = "Sequência de exportação gerada. Copie-a com Ctrl+C."
L["Profile import completed."] = "Importação do perfil concluída."
L["No active profile available."] = "Nenhum perfil ativo disponível."
L["Failed to encode export string."] = "Falha ao codificar a sequência de exportação."
L["Paste an import string first."] = "Cole primeiro uma sequência de importação."
L["Invalid import string format."] = "Formato de sequência de importação inválido."
L["Failed to decode import string."] = "Falha ao decodificar a sequência de importação."
L["Failed to decompress import string."] = "Falha ao descompactar a sequência de importação."
L["Failed to deserialize import string."] = "Falha ao desserializar a sequência de importação."

-- Banner
L["BANNER_DESC"] = "Configuração minimalista para suas recargas. Selecione uma categoria à esquerda para começar."

-- Chat Messages
L["%s settings reset."] = "Configurações de %s redefinidas."
L["Profile reset. Reloading UI..."] = "Perfil redefinido. Recarregando a interface..."

-- Status Indicators
L["ON"] = "ON"
L["OFF"] = "OFF"

-- General Dashboard
L["Enable categories styling"] = "Ativar estilo das categorias"
L["LIVE_CONTROLS_DESC"] = "As mudanças são aplicadas imediatamente. Deixe ativadas apenas as categorias que você realmente usa para uma configuração mais limpa."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Mostra texto de contagem regressiva estilizado nos ícones de bônus e penalidades do Blizzard CompactPartyFrame e CompactRaidFrame. Grupo e raide podem ser ativados separadamente. Isso é independente de Outros."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Copie este link para abrir a página do projeto no CurseForge no seu navegador."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Copie este link para ver outros projetos de Anahkas no CurseForge."

-- Help
L["Help & Support"] = "Ajuda e Suporte"
L["Project"] = "Projeto"
L["Useful Addons"] = "Addons Úteis"
L["Support & Feedback"] = "Suporte e Feedback"
L["MCE_HELP_INTRO"] = "Links rápidos do projeto e alguns addons que valem a pena testar."
L["HELP_SUPPORT_DESC"] = "Sugestões e feedback são sempre bem-vindos.\n\nSe você encontrar um bug ou tiver uma ideia de recurso, fique à vontade para deixar um comentário ou mensagem privada no CurseForge."
L["HELP_COMPANION_DESC"] = "Boas combinações que funcionam bem com o MiniCE."
L["HELP_MINICC_DESC"] = "Rastreador compacto de CC. O MiniCE também pode estilizar o texto dele."
L["Copy this link to open the MiniCC CurseForge page in your browser."] = "Copie este link para abrir a página do MiniCC no CurseForge no seu navegador."
L["HELP_PVPTAB_DESC"] = "Faz com que TAB selecione apenas jogadores no PvP. Ótimo para arenas e campos de batalha."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Copie este link para abrir Smart PvP Tab Targeting no CurseForge."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Ative ou desative suas categorias principais de recarga em um só lugar."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Esta ação não pode ser desfeita. Seu perfil será totalmente redefinido e a interface será recarregada."
L["MAINTENANCE_DESC"] = "Reverte esta categoria para os padrões de fábrica. As outras categorias não são afetadas."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Personalize as recargas nas suas barras de ação principais, incluindo Bartender4 e Dominos."
L["NAMEPLATE_DESC"] = "Estilize as recargas exibidas em placas de nome inimigas e aliadas (Plater, KuiNameplates etc.)."
L["UNITFRAME_DESC"] = "Ajuste o estilo de recarga nos quadros de jogador, alvo e foco."
L["COOLDOWNMANAGER_DESC"] = "Estilo de ícone compartilhado para os visualizadores do CooldownManager. O tamanho do texto de contagem regressiva pode ser ajustado separadamente para os visualizadores Essential, Utility e de ícones de bônus."
L["MINICC_DESC"] = "Estilo dedicado para os ícones de recarga do MiniCC. Suporta os ícones de controle do MiniCC, placas de nome, retratos e módulos em estilo de sobreposição quando o MiniCC estiver carregado."
L["OTHERS_DESC"] = "Categoria coringa para recargas que não pertencem a outras categorias (bolsas, menus, outros addons)."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Cores Dinâmicas do Texto"
L["Color by Remaining Time"] = "Colorir pelo Tempo Restante"
L["Dynamically colors the countdown text based on how much time is left."] = "Muda dinamicamente a cor do texto da contagem regressiva com base no tempo restante."
L["DYNAMIC_COLORS_DESC"] = "Altera a cor do texto com base na duração restante da recarga. Quando ativado, substitui a cor estática acima."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Aplica os mesmos limites de tempo restante a todas as categorias do MiniCE ativadas, incluindo o texto de aura compacta de grupo/raide. O tratamento da duração continua seguro mesmo na virada da meia-noite quando a Blizzard expõe valores ocultos."
L["Expiring Soon"] = "Expirando em breve"
L["Short Duration"] = "Duração curta"
L["Long Duration"] = "Duração longa"
L["Beyond Thresholds"] = "Além dos limites"
L["Threshold (seconds)"] = "Limite (segundos)"
L["Default Color"] = "Cor padrão"
L["Color used when the remaining time exceeds all thresholds."] = "Cor usada quando o tempo restante ultrapassa todos os limites."

-- Abbreviation
L["Abbreviate Above"] = "Abreviar acima de"
L["Abbreviate Above (seconds)"] = "Abreviar acima de (segundos)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "Números de recarga acima deste limite serão abreviados (ex. 5m em vez de 300)."
L["ABBREV_THRESHOLD_DESC"] = "Controla quando os números de recarga mudam para formato abreviado. Temporizadores acima deste limite mostram valores abreviados como 5m ou 1h."
