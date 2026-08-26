-- ptBR.lua (Brazilian Portuguese)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "ptBR")
if not L then return end

L["MINIAURAS_COUNTDOWN_COLORS_NOTICE"] = "O MiniAuras gerencia as cores de limite da contagem regressiva. Configure-as em MiniAuras > Misc > Countdown Colours."
L["MINIAURAS_SWIPE_ALPHA_DESC"] = "0% = transparente, 100% = totalmente escuro. Aplica-se a todos os grupos de módulos do MiniAuras; 80% corresponde à varredura que o próprio MiniAuras desenha."

-- Core
L["MiniAuras test command is unavailable."] = "O comando de teste do MiniAuras não está disponível."

-- Category Names
L["Action Bars"] = "Barras de Ação"
L["Nameplates"] = "Placas de Nome"
L["Unit Frames"] = "Quadros de Unidade"
L["Party / Raid Frames"] = "Quadros de Grupo/Raide"
L["CooldownManager"] = "CooldownManager"
L["MiniAuras"] = "MiniAuras"

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
L["MiniAuras Frame Types"] = "Tipos de Quadro do MiniAuras"

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
L["Essential Viewer Stack Size"] = "Tamanho de Acúmulos do Visualizador Essential"
L["Utility Viewer Stack Size"] = "Tamanho de Acúmulos do Visualizador Utility"
L["Buff Icon Viewer Stack Size"] = "Tamanho de Acúmulos do Visualizador de Ícones de Bônus"
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
L["Toggle MiniAuras' built-in test icons using /miniauras test."] = "Ativa ou desativa os ícones de teste internos do MiniAuras com /miniauras test."

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
L["Top"] = "Superior"
L["Bottom"] = "Inferior"
L["Left"] = "Esquerda"
L["Right"] = "Direita"

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
L["Retired"] = "Descontinuado"

-- General Dashboard
L["Enable categories styling"] = "Ativar estilo das categorias"
L["LIVE_CONTROLS_DESC"] = "As mudanças são aplicadas imediatamente. Deixe ativadas apenas as categorias que você realmente usa para uma configuração mais limpa."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Ativar Quadros de Grupo/Raide funciona como interruptor principal desta categoria. Ativar Texto de Aura da Raide estende o mesmo estilo aos quadros de raide da Blizzard."
L["PARTY_RAID_FRAMES_RETIRED_DESC"] = "O suporte a Quadros de Grupo/Raide foi descontinuado. Desde o Patch 12.0.5 da Blizzard, o MiniCE não faz mais hooks nem estiliza quadros compactos de grupo e raide."
L["PARTY_RAID_FRAMES_AURAS_TITLE"] = "Novo addon em desenvolvimento: Raid Frame Auras"
L["PARTY_RAID_FRAMES_AURAS_DESC"] = "Raid Frame Auras já está disponível no CurseForge. Ele permanece separado do MiniCE porque usa seus próprios frames de sobreposição em vez de estilizar os ícones existentes da Blizzard, o que faz dele uma opção melhor como addon independente."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "Copie este link para abrir a página do projeto no CurseForge no seu navegador."
L["Copy this link to open Raid Frame Auras on CurseForge."] = "Copie este link para abrir o Raid Frame Auras no CurseForge."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "Copie este link para ver outros projetos de Anahkas no CurseForge."

-- Help
L["Help & Support"] = "Ajuda e Suporte"
L["Project"] = "Projeto"
L["Useful Addons"] = "Addons Úteis"
L["Support & Feedback"] = "Suporte e Feedback"
L["MCE_HELP_INTRO"] = "Links rápidos do projeto e alguns addons que valem a pena testar."
L["HELP_SUPPORT_DESC"] = "Sugestões e feedback são sempre bem-vindos.\n\nSe você encontrar um bug ou tiver uma ideia de recurso, fique à vontade para deixar um comentário ou mensagem privada no CurseForge."
L["HELP_COMPANION_DESC"] = "Boas combinações que funcionam bem com o MiniCE."
L["HELP_MINIAURAS_DESC"] = "Conjunto de exibições de auras personalizadas, controle coletivo, recargas e JxJ. O MiniCE também pode estilizar os textos de recarga."
L["Copy this link to open the MiniAuras CurseForge page in your browser."] = "Copie este link para abrir a página do MiniAuras no CurseForge no seu navegador."
L["HELP_PVPTAB_DESC"] = "Faz com que TAB selecione apenas jogadores no PvP. Ótimo para arenas e campos de batalha."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "Copie este link para abrir Smart PvP Tab Targeting no CurseForge."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "Ative ou desative suas categorias principais de recarga em um só lugar."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "Esta ação não pode ser desfeita. Seu perfil será totalmente redefinido e a interface será recarregada."
L["MAINTENANCE_DESC"] = "Reverte esta categoria para os padrões de fábrica. As outras categorias não são afetadas."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Estilize as recargas nas suas barras de ação."
L["NAMEPLATE_DESC"] = "Estilize as recargas nas placas de nome inimigas e aliadas."
L["UNITFRAME_DESC"] = "Estilize as recargas de auras nos quadros de alvo, foco e outros quadros de unidade compatíveis."
L["COOLDOWNMANAGER_DESC"] = "Estilize as recargas de ícones do CooldownManager."
L["MINIAURAS_DESC"] = "Estilize os ícones de recarga do MiniAuras."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "Cores Dinâmicas do Texto"
L["Color by Remaining Time"] = "Colorir pelo Tempo Restante"
L["Dynamically colors the countdown text based on how much time is left."] = "Muda dinamicamente a cor do texto da contagem regressiva com base no tempo restante."
L["DYNAMIC_COLORS_DESC"] = "Altera a cor do texto com base na duração restante da recarga. Quando ativado, substitui a cor estática acima."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "Os limites de tempo restante podem ser permitidos ou bloqueados por categoria ativa do MiniCE. O tratamento da duração continua seguro mesmo na virada da meia-noite quando a Blizzard expõe valores ocultos."
L["Expiring Soon"] = "Expirando em breve"
L["Short Duration"] = "Duração curta"
L["Long Duration"] = "Duração longa"
L["Threshold (seconds)"] = "Limite (segundos)"
L["Default Color"] = "Cor padrão"
L["Color used when the remaining time exceeds all thresholds."] = "Cor usada quando o tempo restante ultrapassa todos os limites."

-- Abbreviation
L["Abbreviate Above"] = "Abreviar acima de"
L["Abbreviate Above (seconds)"] = "Abreviar acima de (segundos)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "Números de recarga acima deste limite serão abreviados (ex. 5m em vez de 300)."
L["ABBREV_THRESHOLD_DESC"] = "Controla quando os números de recarga mudam para formato abreviado. Temporizadores acima deste limite mostram valores abreviados como 5m ou 1h."

-- MyDRs / sArena
L["MYDRS_SWIPE_ALPHA_DESC"] = "0% = transparente, 100% = totalmente escuro. Substitui a configuração Cooldown Swipe Alpha do MyDRs enquanto esta categoria estiver ativada; 100% corresponde à varredura que o próprio MyDRs desenha."
L["MyDRs test command is unavailable."] = "O comando de teste do MyDRs não está disponível."
L["Toggle MyDRs' built-in test icons using /mydrs test."] = "Ativa ou desativa os ícones de teste internos do MyDRs com /mydrs test."
L["sArena slash command is unavailable."] = "O comando slash do sArena não está disponível."

-- Category Names
L["Player Auras"] = "Auras do Jogador"
L["CooldownManagerCentered"] = "CooldownManagerCentered"
L["HealerCC"] = "HealerCC"
L["MyDRs"] = "MyDRs"
L["sArena"] = "sArena"
L["TellMeWhen"] = "TellMeWhen"
L["Profiles"] = "Perfis"
L["ShinyAuras"] = "ShinyAuras"
L["Dominos"] = "Dominos"
L["ElvUI"] = "ElvUI"

-- Group Headers
L["Swipe Edge"] = "Borda de Varredura"
L["MiniAuras Module Groups"] = "Grupos de Módulos do MiniAuras"
L["sArena Cooldown Types"] = "Tipos de Recarga do sArena"
L["Aura Targets"] = "Alvos de Auras"
L["Buff Styling"] = "Estilo de Bônus"
L["Debuff Styling"] = "Estilo de Penalidades"
L["External Defensive Buffs Styling"] = "Estilo de Bônus Defensivos Externos"

-- Toggles & Settings
L["Style Buffs"] = "Estilizar Bônus"
L["Style Debuffs"] = "Estilizar Penalidades"
L["Style External Defensive Buffs"] = "Estilizar Bônus Defensivos Externos"
L["Style Blizzard's default player buff buttons."] = "Estiliza os ícones de bônus padrão do jogador da Blizzard."
L["Style Blizzard's default player debuff buttons."] = "Estiliza os ícones de penalidades padrão do jogador da Blizzard."
L["Style Blizzard's external defensive buff buttons."] = "Estiliza os ícones de bônus defensivos externos da Blizzard."
L["Timer Inside Icon"] = "Temporizador Dentro do Ícone"
L["Place the aura timer in the center of the icon instead of Blizzard's default outside position."] = "Posiciona o temporizador da aura no centro do ícone em vez da posição externa padrão da Blizzard."
L["Hide Swipe"] = "Ocultar Varredura"
L["Only Mine (Timer Text)"] = "Somente as Minhas (Texto do Temporizador)"
L["Aura Visibility"] = "Visibilidade de Auras"
L["Only My Debuffs"] = "Somente Minhas Penalidades"
L["Only My Buffs"] = "Somente Meus Bônus"
L["Disable fading/blinking"] = "Desativar esmaecimento/piscar"
L["Enables styled countdown text on Party / Raid Frames. When disabled, both party and raid aura text styling are turned off."] = "Ativa o texto de contagem regressiva estilizado em Quadros de Grupo/Raide. Se desativado, o estilo de texto de aura de grupo e de raide é completamente desligado."
L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."] = "Também aplica texto de contagem regressiva estilizado aos ícones de bônus e penalidades do Blizzard CompactRaidFrame. Requer que Quadros de Grupo/Raide esteja ativado."
L["Hide the swipe animation for this frame group (countdown text still shows)."] = "Oculta a animação de varredura deste grupo de quadros (o texto de contagem regressiva continua visível)."
L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."] = "Mostra o texto do temporizador de recarga somente nas suas próprias auras. Usa a heurística de auras grandes da Blizzard em vez de uma verificação direta de sourceUnit."
L["UNITFRAME_ONLY_MINE_DESC"] = "Mostra o texto do temporizador somente em auras lançadas por você. Os contêineres de alvo/foco do MiniCE para WoW 12.1 usam o filtro de Jogador da Blizzard; quadros de addons compatíveis e legados usam seus metadados de grupo ou o recurso de aura grande."
L["UNITFRAME_ONLY_MINE_DEBUFFS_DESC"] = "Oculta penalidades lançadas por outros jogadores nos quadros de alvo e foco. O MiniCE gerencia esses contêineres de auras no WoW 12.1, portanto o filtro de penalidades da própria Blizzard não os alcança mais."
L["UNITFRAME_ONLY_MINE_BUFFS_DESC"] = "Oculta bônus lançados por outros jogadores nos quadros de alvo e foco. O MiniCE gerencia esses contêineres de auras no WoW 12.1, portanto o filtro de bônus da própria Blizzard não os alcança mais."
L["Cast Bar"] = "Barra de Conjuração"
L["Reposition Cast Bar"] = "Reposicionar a Barra de Conjuração"
L["UNITFRAME_CASTBAR_REPOSITION_DESC"] = "Ancora as barras de conjuração de alvo e foco abaixo da última linha de benefícios/penalidades. O MiniCE gerencia esses contêineres de auras no WoW 12.1; caso contrário, a barra da Blizzard fica presa ao quadro e as sobrepõe."
L["Keeps player aura buttons fully opaque when they are close to expiring."] = "Mantém os ícones de auras do jogador totalmente opacos quando estão prestes a expirar."
L["When a CooldownManager slot is temporarily showing aura time, use a dedicated buff color instead of remaining-time threshold colors."] = "Usa uma cor de bônus dedicada em vez das cores de limite de tempo restante quando um slot do CooldownManager está mostrando temporariamente o tempo de uma aura."
L["Applied while the slot is showing aura duration. When the aura ends and the slot switches back to cooldown time, threshold colors resume."] = "Aplicada enquanto o slot mostra a duração da aura. Quando a aura termina e o slot volta para o tempo de recarga, as cores de limite são retomadas."
L["Buff / Debuff Size"] = "Tamanho de Bônus/Penalidade"
L["Defensive Buff Size"] = "Tamanho do Bônus Defensivo"
L["Use Buff Color"] = "Usar Cor de Bônus"
L["Buff Color"] = "Cor do Bônus"
L["Essential Viewer"] = "Visualizador Essential"
L["Utility Viewer"] = "Visualizador Utility"
L["Buff Icon Viewer"] = "Visualizador de Ícones de Bônus"
L["CC Frames Text Size"] = "Tamanho do Texto dos Quadros de CC"
L["CC / Friendly Frames Text Size"] = "Tamanho do Texto CC / Quadros Aliados"
L["Raid Frame Auras Text Size"] = "Tamanho do Texto de Auras dos Quadros de Raide"
L["Class Icon Text Size"] = "Tamanho do Texto do Ícone de Classe"
L["DR Cooldown Text Size"] = "Tamanho do Texto de Recarga de DR"
L["Alerts / Trackers / Custom Auras Text Size"] = "Tamanho do Texto de Alertas / Rastreadores / Auras Personalizadas"
L["Trinket / Racial Text Size"] = "Tamanho do Texto de Bugiganga / Racial"
L["Show Test Frames"] = "Mostrar Quadros de Teste"
L["Hide Test Frames"] = "Ocultar Quadros de Teste"
L["Show Swipe Animation"] = "Mostrar Animação de Varredura"
L["Shows the dark overlay that sweeps during a cooldown."] = "Mostra a sobreposição escura que varre durante uma recarga."
L["Swipe Shade Alpha"] = "Opacidade da Sombra de Varredura"
L["0% = transparent, 100% = full dark."] = "0% = transparente, 100% = totalmente escuro."
L["Reverse Swipe"] = "Inverter Varredura"
L["Reverse the swipe direction so the shade fills in the opposite direction."] = "Inverte a direção da varredura para que a sombra se preencha na direção oposta."
L["Hide Charge Timers"] = "Ocultar Temporizadores de Cargas"
L["Hide timers while charges are restoring (only show timer when all charges are spent)."] = "Oculta os temporizadores enquanto as cargas estão se restaurando (mostra o temporizador somente quando todas as cargas forem gastas)."
L["Hide Stack Text"] = "Ocultar Texto de Acúmulo"
L["Hide stacks and charges entirely."] = "Oculta completamente os acúmulos e as cargas."
L["MiniAuras text settings are grouped by module family so similar widgets share the same countdown size."] = "As configurações de texto do MiniAuras são agrupadas por família de módulos, para que widgets semelhantes compartilhem o mesmo tamanho de contagem regressiva."
L["Applies to MiniAuras CC module (enemy crowd controls)."] = "Aplica-se ao módulo CC do MiniAuras (controle de grupo inimigo)."
L["Applies to MiniAuras CC, Friendly CDs, and Friendly Indicators modules."] = "Aplica-se aos módulos CC, Friendly CDs e Friendly Indicators do MiniAuras."
L["Applies to the MiniAuras Raid Frame Auras module."] = "Aplica-se ao módulo Raid Frame Auras do MiniAuras."
L["Applies to MiniAuras portrait icons."] = "Aplica-se aos ícones de retrato do MiniAuras."
L["Applies to MiniAuras Alerts, Healer CC, Kick Timer, Precognition, Trinkets, and Custom Auras modules."] = "Aplica-se aos módulos Alerts, Healer CC, Kick Timer, Precognition, Trinkets e Custom Auras do MiniAuras."
L["Show sArena test frames using /sarena test."] = "Mostra os quadros de teste do sArena com /sarena test."
L["Hide sArena test frames using /sarena hide."] = "Oculta os quadros de teste do sArena com /sarena hide."

-- Import / Export
L["Import string is too large."] = "A sequência de importação é muito grande."
L["Import profile contains invalid data."] = "O perfil importado contém dados inválidos."
L["Failed to apply imported profile."] = "Falha ao aplicar o perfil importado."

-- Chat Messages
L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"] = "Algumas alterações exigem recarregar a interface para serem aplicadas completamente.\n\nRecarregar a interface agora?"

-- Addon Integrations
L["Addon Integrations"] = "Integrações de Addons"
L["ADDON_INTEGRATIONS_DESC"] = "Ativa ou desativa pontes de addons opcionais que roteiam recargas externas para as categorias do MiniCE."
L["Routes ShinyAuras cooldowns through the Unit Frames category. Disable this if you want ShinyAuras to keep its native countdowns untouched."] = "Roteia as recargas do ShinyAuras pela categoria Quadros de Unidade. Desative isso se quiser que o ShinyAuras mantenha suas contagens regressivas nativas inalteradas."
L["Routes supported Dominos action bar cooldowns through the Action Bars category. Disable this if you want Dominos to keep its native cooldown styling untouched."] = "Roteia as recargas compatíveis das barras de ação do Dominos pela categoria Barras de Ação. Desative isso se quiser que o Dominos mantenha seu estilo de recarga nativo inalterado."
L["Routes supported Bartender4 action bar cooldowns through the Action Bars category. Disable this if you want Bartender4 to keep its native cooldown styling untouched."] = "Roteia as recargas compatíveis das barras de ação do Bartender4 pela categoria Barras de Ação. Desative isso se quiser que o Bartender4 mantenha seu estilo de recarga nativo inalterado."
L["Routes supported ElvUI action bar, unit frame, and nameplate cooldowns through MiniCE categories. Disable this if you want ElvUI to keep its native cooldown styling untouched."] = "Roteia as recargas compatíveis de barras de ação, quadros de unidade e placas de nome do ElvUI pelas categorias do MiniCE. Desative isso se quiser que o ElvUI mantenha seu estilo de recarga nativo inalterado."
L["CooldownManagerCentered also styles %s. This may add a small performance cost. Disable CMC timer fonts if you want MiniCE to remain the only owner of those viewer timers."] = "O CooldownManagerCentered também estiliza %s. Isso pode adicionar um pequeno custo de desempenho. Desative as fontes de temporizador do CMC se quiser que o MiniCE permaneça o único responsável por esses temporizadores de visualizador."

-- Help
L["HELP_ARENADR_DESC"] = "Acompanha as reduções progressivas inimigas diretamente nas placas de nome na Arena."
L["Copy this link to open ArenaDR Nameplates on CurseForge."] = "Copie este link para abrir o ArenaDR Nameplates no CurseForge."

-- Category Descriptions
L["BETTERBLIZZFRAMES_UNITFRAME_CONFLICT_WARNING"] = "O BetterBlizzFrames está ativo, portanto o estilo de Quadros de Unidade do MiniCE foi desativado para evitar possíveis conflitos. Um adaptador dedicado para BetterBlizzFrames será lançado em breve."
L["BETTERBLIZZPLATES_NAMEPLATE_CONFLICT_WARNING"] = "O BetterBlizzPlates está ativo, portanto o estilo de Placas de Nome do MiniCE foi desativado para evitar possíveis conflitos."
L["PLAYERAURA_DESC"] = "Estilize as recargas de bônus e penalidades do jogador da Blizzard."
L["HEALERCC_DESC"] = "Estilize as recargas de alertas do HealerCC aliadas e inimigas."
L["MYDRS_DESC"] = "Estilize os ícones de recarga das reduções progressivas do MyDRs. O MyDRs mantém seu próprio rótulo de estado de DR (50% / IMM)."
L["SARENA_DESC"] = "Estilize os temporizadores de recarga do sArena_Reloaded."
L["TELLMEWHEN_DESC"] = "Estilize o texto de recarga e as bordas de varredura do TellMeWhen."
L["TELLMEWHEN_TIMER_OPTIONS_NOTICE"] = "A visibilidade do temporizador, o texto do temporizador, a direção do sombreamento e a exibição do GCD continuam controlados pelo TellMeWhen. A visibilidade e a espessura da borda de varredura são controladas aqui."
L["TELLMEWHEN_EDGE_SCALE_DESC"] = "Redimensiona a borda de varredura do TellMeWhen quando o MiniCE a ativa."

-- Dynamic Text Colors
L["Allow Threshold Colors"] = "Permitir Cores de Limite"
L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."] = "Permite que os limites globais de \"Colorir pelo Tempo Restante\" substituam a cor de texto estática desta categoria."
L["Behavior"] = "Comportamento"
L["Advanced Threshold Settings"] = "Configurações Avançadas de Limite"
L["Threshold Colors"] = "Cores de Limite"
L["THRESHOLD_COLORS_DESC"] = "Cada faixa define o corte e a cor usados para aquele intervalo de tempo restante."
L["Threshold Transition Offset"] = "Deslocamento de Transição de Limite"
L["Moves the start of each next color band. Negative values switch slightly earlier."] = "Move o início de cada próxima faixa de cor. Valores negativos fazem a mudança ocorrer um pouco antes."
L["Beyond Thresholds Color"] = "Cor Além dos Limites"

-- Abbreviation
L["Show Tenths Below (seconds)"] = "Mostrar Décimos Abaixo de (segundos)"
L["Cooldown numbers below this threshold will show one decimal place (e.g. 8.7). Set 0 to disable."] = "Números de recarga abaixo deste limite mostrarão uma casa decimal (ex. 8.7). Defina 0 para desativar."

-- Performance Warning
L["PERF_WARNING_DESC"] = "Este recurso pode afetar o desempenho e causar quedas de FPS. Use apenas em configurações potentes."

-- Font Options
L["Game Default"] = "Padrão do Jogo"
