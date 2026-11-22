-- Brazilian Portuguese localization for Accountant Classic
local L = LibStub("AceLocale-3.0"):NewLocale("Accountant_Classic", "ptBR", false)

if not L then return end

-- Header
L["Accountant Classic"] = "Accountant Classic"
L["A basic tool to track your monetary incomings and outgoings within WoW."] = "Uma ferramenta básica para monitorar entradas e saídas no WoW."
L[ [=[Left-Click to open Accountant Classic.
Right-Click for Accountant Classic options.
Left-click and drag to move this button.]=] ] = [=[Clique esquerdo abre o Accountant Classic.
Clique direito abre as opções do Accountant Classic.
Clique esquerdo + Arrastar move o botão.]=]
L[ [=[Left-click and drag to move this button.
Right-Click to open Accountant Classic.]=] ] = [=[Cloque com o botão esquerdo e segure para mover este botão.
Clique com o botão direito para abrir o Accountant Classic.]=]
L["Total Incomings"] = "Total de Entradas"
L["Total Outgoings"] = "Total de Saídas"
L["Net Profit / Loss"] = "Lucro / Prejuízo Líquido"
L["Net Loss"] = "Prejuízo Líquido"
L["Net Profit"] = "Lucro Líquido"
L["Source"] = "Fonte"
L["Incomings"] = "Entradas"
L["Outgoings"] = "Saídas"
L["Week Start"] = "Começo da Semana"
L["Sum Total"] = "Soma Total"
L["Character"] = "Personagem"
L["Money"] = "Dinheiro"
L["Updated"] = "Atualizado"

-- Section Labels
L["Quest Rewards"] = "Ganho de Missões"
L["Merchants"] = "Comerciantes"
L["Trade Window"] = "Janela de Negociação"
L["Mail"] = "Correio"
L["Training Costs"] = "Custos de Treinamento"
L["Taxi Fares"] = "Tarifas de Voo"
L["Unknown"] = "Desconhecido"
L["Repair Costs"] = "Custo de Reparo"
L["LFD, LFR and Scen."] = "Fila de Masmorras, Raids, Cenários"

-- Buttons
L["Reset"] = "Reset"
L["Options"] = "Opções"
L["Exit"] = "Sair"

-- Tabs' name
L["This Session"] = "Esta Sessão"
L["Today"] = "Hoje"
L["Prv. Day"] = "Dia Anterior"
L["This Week"] = "Esta Semana"
L["Prv. Week"] = "Semana Passada"
L["This Month"] = "Este Mês"
L["Prv. Month"] = "Mês Passado (or \"Mês Ant.\" if you need a smaller version)"
L["This Year"] = "Este ano"
L["Prv. Year"] = "Ano Passado"
L["Total"] = "Total"
L["All Chars"] = "Todos Personagens"

-- Options
L["Accountant Classic Options"] = "Opções do Accountant Classic"
L["Show minimap button"] = "Mostrar botão no Minimapa"
L["Show money"] = "Mostrar dinheiro"
L["Show money on minimap button's tooltip"] = "Mostrar dinheiro no tooltip do botão, no minimapa."
L["Show session info on minimap button's tooltip"] = "Mostrar informações da sessão no tooltip do botão, no minimapa."
L["Show money on screen"] = "Mostrar dinheiro na tela"
L["Reset position"] = "Resetar posição"
L["Reset money frame's position"] = "Resetar a posição do quadro de dinheiro na tela."
L["Minimap Button Position"] = "Posição do Botão do Minimapa"
L["Start of Week"] = "Começo da Semana"
L["Done"] = "Feito"
L["Display Instruction Tips"] = "Mostrar Dicas Informativas"
L["Select the character to be removed:"] = "Selecione o personagem a ser removido:"
L["The selected character's Accountant Classic data will be removed."] = "Os personagens selecionados terão seus dados deletados do Accountant Classic."
L["|cffffffff\"%s - %s|cffffffff\" character's Accountant Classic data has been removed."] = "|cffffffff\"%s - %s|cffffffff\" Dados do personagem foram removidos do Accountant Classic."
L["Select the date format:"] = "Selecione o formato da data:"

-- Misc
L["Are you sure you want to reset the \"%s\" data?"] = "Você tem certeza que deseja resetar os dados de \"%s\"?"
L["New Accountant Classic profile created for %s"] = "Novo perfil de %s criado no Accountant Classic"
L["Loaded Accountant Classic Profile for %s"] = "Perfil de %s carregado pelo Accountant Classic"
L["Accountant Classic loaded."] = "Accountant Classic carregado."
L["About"] = "Sobre"
L["Show All Characters"] = "Mostrar Todos Personagens"

-- Amount string for CHAT_MESSAGE_MONEY search
L["(%d+) Gold"] = "(%d+) de Ouro"
L["(%d+) Silver"] = "(%d+) de Prata"
L["(%d+) Copper"] = "(%d+) de Cobre"

-- Key Bindings headers
L["BINDING_HEADER_ACCOUNTANT_CLASSIC_TITLE"] = "Accountant Classic"
L["BINDING_NAME_ACCOUNTANT_CLASSIC_TOGGLE"] = "Alternar Accountant Classic"

-- History ledger
L["Remove, keep history"] = "Remover e manter o histórico"
L["Remove with history"] = "Remover junto com o histórico"
L["Delete the entire Accountant Classic history ledger of all characters?\nThe classic period data is not affected."] = "Excluir todo o histórico do Accountant Classic de todos os personagens?\nOs dados por período das estatísticas tradicionais não serão afetados."
L["The history ledger has been deleted."] = "O histórico foi excluído."
L["The history ledger was saved by a newer version of Accountant Classic and is read-only."] = "O histórico foi salvo por uma versão mais recente do Accountant Classic e está disponível somente para leitura."
L["History matches today's classic data (%d categories)."] = "O histórico corresponde aos dados de hoje das estatísticas tradicionais (%d categorias)."
L["%d categories differ from today's classic data."] = "%d categorias diferem dos dados de hoje das estatísticas tradicionais."
L["History tracking started today, so money logged earlier today exists only in the classic data."] = "O acompanhamento do histórico começou hoje, portanto as movimentações de dinheiro registradas hoje antes de sua ativação constam apenas nas estatísticas tradicionais."
L["Resetting the Day tab also causes differences; the history ledger is never reset with it."] = "Redefinir a aba do dia também causa diferenças; o histórico nunca é redefinido junto com ela."
