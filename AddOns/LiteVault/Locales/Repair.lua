local _, lv = ...

-- Stabilization keys shared by recently added UI surfaces. Keeping this small
-- overlay together makes coverage review straightforward without rewriting the
-- large data-driven phrase dictionaries in each locale file.
local strings = {
    enUS = {
        BUTTON_GEAR="Gear", LABEL_EMPTY="Empty", TOOLTIP_GEAR_TITLE="View Gear", TOOLTIP_GEAR_DESC="View the saved equipped gear snapshot for this character",
        LABEL_INVENTORY_SLOT_NUMBER_FMT="%s %d", TEXT_GEAR_UPDATED_NEVER="Updated: Never", TEXT_GEAR_UPDATED_AGO_FMT="Updated %s ago", LABEL_STATS="Stats",
        TEXT_CALENDAR_LOGGED_IN_FMT="%s Logged In", TEXT_PROFIT_SOURCE_WEEKLY_CACHE="Weekly Cache",
        TEXT_FOLIO_COMMITTING="Committing Folio changes...", TEXT_FOLIO_UNAVAILABLE_COMBAT="Folio changes are unavailable in combat.", TEXT_FOLIO_HELP="Left-click to purchase. Right-click to refund. Selection nodes open a choice flyout.",
        TEXT_FOLIO_UNAVAILABLE_CLIENT="Omnium Folio is unavailable on this client.", TEXT_FOLIO_NO_ACTIVE_CONFIG="No active Omnium Folio config was found.", TEXT_FOLIO_NO_ACTIVE_TREE="The current character does not have an active Omnium Folio tree.", TEXT_FOLIO_NO_NODES="No Omnium Folio nodes were found.",
        TEXT_FOLIO_COMMIT_IN_PROGRESS="A Folio change is already being committed.", TEXT_FOLIO_LIVE_CHARACTER="Live current character", TEXT_FOLIO_PROGRESS_FMT="Selected Nodes: %d / %d    Spent Points: %d", TEXT_FOLIO_AVAILABLE_POINTS_NONE="Available Points: -", TEXT_FOLIO_SELECTED_NODES_NONE="Selected Nodes: -", TEXT_FOLIO_RANK_FMT="Rank %d", TEXT_FOLIO_SELECTED="Selected", TEXT_FOLIO_NO_COMMITTED_NODES="No committed Omnium Folio nodes are active.",
        LABEL_MIDNIGHT_SEASON_2="Midnight Season 2", ["The Venomous Abyss"]="The Venomous Abyss", MSG_RAID_HISTORY_PRESERVED="Raid history was preserved; destructive season reset is disabled.",
    },
    deDE = {
        BUTTON_GEAR="Ausrüstung", LABEL_EMPTY="Leer", TOOLTIP_GEAR_TITLE="Ausrüstung anzeigen", TOOLTIP_GEAR_DESC="Gespeicherte angelegte Ausrüstung dieses Charakters anzeigen", LABEL_INVENTORY_SLOT_NUMBER_FMT="%s %d", TEXT_GEAR_UPDATED_NEVER="Aktualisiert: Nie", TEXT_GEAR_UPDATED_AGO_FMT="Vor %s aktualisiert", LABEL_STATS="Werte", TEXT_CALENDAR_LOGGED_IN_FMT="%s angemeldet", TEXT_PROFIT_SOURCE_WEEKLY_CACHE="Wöchentliche Truhe", TEXT_FOLIO_COMMITTING="Foliantenänderungen werden übernommen...", TEXT_FOLIO_UNAVAILABLE_COMBAT="Foliantenänderungen sind im Kampf nicht verfügbar.", TEXT_FOLIO_HELP="Linksklick zum Kaufen. Rechtsklick zum Erstatten. Auswahlknoten öffnen eine Auswahl.", TEXT_FOLIO_UNAVAILABLE_CLIENT="Der Omniumfoliant ist auf diesem Client nicht verfügbar.", TEXT_FOLIO_NO_ACTIVE_CONFIG="Keine aktive Omniumfoliant-Konfiguration gefunden.", TEXT_FOLIO_NO_ACTIVE_TREE="Dieser Charakter hat keinen aktiven Omniumfolianten.", TEXT_FOLIO_NO_NODES="Keine Omniumfolianten-Knoten gefunden.", TEXT_FOLIO_COMMIT_IN_PROGRESS="Eine Foliantenänderung wird bereits übernommen.", TEXT_FOLIO_LIVE_CHARACTER="Aktueller Charakter", TEXT_FOLIO_PROGRESS_FMT="Ausgewählte Knoten: %d / %d    Ausgegebene Punkte: %d", TEXT_FOLIO_AVAILABLE_POINTS_NONE="Verfügbare Punkte: -", TEXT_FOLIO_SELECTED_NODES_NONE="Ausgewählte Knoten: -", TEXT_FOLIO_RANK_FMT="Rang %d", TEXT_FOLIO_SELECTED="Ausgewählt", TEXT_FOLIO_NO_COMMITTED_NODES="Keine aktiven Omniumfolianten-Knoten.", LABEL_MIDNIGHT_SEASON_2="Midnight Saison 2", ["The Venomous Abyss"]="Der Giftige Abgrund",
    },
    frFR = {
        BUTTON_GEAR="Équipement", LABEL_EMPTY="Vide", TOOLTIP_GEAR_TITLE="Voir l’équipement", TOOLTIP_GEAR_DESC="Voir l’instantané d’équipement enregistré pour ce personnage", LABEL_INVENTORY_SLOT_NUMBER_FMT="%s %d", TEXT_GEAR_UPDATED_NEVER="Mis à jour : jamais", TEXT_GEAR_UPDATED_AGO_FMT="Mis à jour il y a %s", LABEL_STATS="Caractéristiques", TEXT_CALENDAR_LOGGED_IN_FMT="Connexion de %s", TEXT_PROFIT_SOURCE_WEEKLY_CACHE="Cache hebdomadaire", TEXT_FOLIO_COMMITTING="Application des modifications du folio...", TEXT_FOLIO_UNAVAILABLE_COMBAT="Les modifications du folio sont indisponibles en combat.", TEXT_FOLIO_HELP="Clic gauche pour acheter. Clic droit pour rembourser. Les nœuds de choix ouvrent une sélection.", TEXT_FOLIO_UNAVAILABLE_CLIENT="Le folio d’Omnium est indisponible sur ce client.", TEXT_FOLIO_NO_ACTIVE_CONFIG="Aucune configuration active du folio d’Omnium trouvée.", TEXT_FOLIO_NO_ACTIVE_TREE="Ce personnage n’a pas d’arbre de folio d’Omnium actif.", TEXT_FOLIO_NO_NODES="Aucun nœud du folio d’Omnium trouvé.", TEXT_FOLIO_COMMIT_IN_PROGRESS="Une modification du folio est déjà en cours.", TEXT_FOLIO_LIVE_CHARACTER="Personnage actuel", TEXT_FOLIO_PROGRESS_FMT="Nœuds sélectionnés : %d / %d    Points dépensés : %d", TEXT_FOLIO_AVAILABLE_POINTS_NONE="Points disponibles : -", TEXT_FOLIO_SELECTED_NODES_NONE="Nœuds sélectionnés : -", TEXT_FOLIO_RANK_FMT="Rang %d", TEXT_FOLIO_SELECTED="Sélectionné", TEXT_FOLIO_NO_COMMITTED_NODES="Aucun nœud actif du folio d’Omnium.", LABEL_MIDNIGHT_SEASON_2="Midnight Saison 2", ["The Venomous Abyss"]="L’Abîme venimeux",
    },
    esES = {
        BUTTON_GEAR="Equipo", LABEL_EMPTY="Vacío", TOOLTIP_GEAR_TITLE="Ver equipo", TOOLTIP_GEAR_DESC="Ver la instantánea de equipo guardada de este personaje", LABEL_INVENTORY_SLOT_NUMBER_FMT="%s %d", TEXT_GEAR_UPDATED_NEVER="Actualizado: nunca", TEXT_GEAR_UPDATED_AGO_FMT="Actualizado hace %s", LABEL_STATS="Estadísticas", TEXT_CALENDAR_LOGGED_IN_FMT="%s inició sesión", TEXT_PROFIT_SOURCE_WEEKLY_CACHE="Alijo semanal", TEXT_FOLIO_COMMITTING="Aplicando cambios del folio...", TEXT_FOLIO_UNAVAILABLE_COMBAT="Los cambios del folio no están disponibles en combate.", TEXT_FOLIO_HELP="Clic izquierdo para comprar. Clic derecho para reembolsar. Los nodos de selección abren opciones.", TEXT_FOLIO_UNAVAILABLE_CLIENT="El folio de Omnium no está disponible en este cliente.", TEXT_FOLIO_NO_ACTIVE_CONFIG="No se encontró una configuración activa del folio de Omnium.", TEXT_FOLIO_NO_ACTIVE_TREE="Este personaje no tiene un árbol activo del folio de Omnium.", TEXT_FOLIO_NO_NODES="No se encontraron nodos del folio de Omnium.", TEXT_FOLIO_COMMIT_IN_PROGRESS="Ya se está aplicando un cambio del folio.", TEXT_FOLIO_LIVE_CHARACTER="Personaje actual", TEXT_FOLIO_PROGRESS_FMT="Nodos seleccionados: %d / %d    Puntos gastados: %d", TEXT_FOLIO_AVAILABLE_POINTS_NONE="Puntos disponibles: -", TEXT_FOLIO_SELECTED_NODES_NONE="Nodos seleccionados: -", TEXT_FOLIO_RANK_FMT="Rango %d", TEXT_FOLIO_SELECTED="Seleccionado", TEXT_FOLIO_NO_COMMITTED_NODES="No hay nodos activos del folio de Omnium.", LABEL_MIDNIGHT_SEASON_2="Temporada 2 de Midnight", ["The Venomous Abyss"]="El Abismo Venenoso",
    },
    ptBR = {
        BUTTON_GEAR="Equipamento", LABEL_EMPTY="Vazio", TOOLTIP_GEAR_TITLE="Ver equipamento", TOOLTIP_GEAR_DESC="Ver o instantâneo de equipamento salvo deste personagem", LABEL_INVENTORY_SLOT_NUMBER_FMT="%s %d", TEXT_GEAR_UPDATED_NEVER="Atualizado: nunca", TEXT_GEAR_UPDATED_AGO_FMT="Atualizado há %s", LABEL_STATS="Atributos", TEXT_CALENDAR_LOGGED_IN_FMT="%s entrou", TEXT_PROFIT_SOURCE_WEEKLY_CACHE="Cache semanal", TEXT_FOLIO_COMMITTING="Aplicando alterações do fólio...", TEXT_FOLIO_UNAVAILABLE_COMBAT="Alterações do fólio não estão disponíveis em combate.", TEXT_FOLIO_HELP="Clique esquerdo para comprar. Clique direito para reembolsar. Nós de seleção abrem opções.", TEXT_FOLIO_UNAVAILABLE_CLIENT="O Fólio de Omnium não está disponível neste cliente.", TEXT_FOLIO_NO_ACTIVE_CONFIG="Nenhuma configuração ativa do Fólio de Omnium foi encontrada.", TEXT_FOLIO_NO_ACTIVE_TREE="O personagem atual não tem uma árvore ativa do Fólio de Omnium.", TEXT_FOLIO_NO_NODES="Nenhum nó do Fólio de Omnium foi encontrado.", TEXT_FOLIO_COMMIT_IN_PROGRESS="Uma alteração do fólio já está sendo aplicada.", TEXT_FOLIO_LIVE_CHARACTER="Personagem atual", TEXT_FOLIO_PROGRESS_FMT="Nós selecionados: %d / %d    Pontos gastos: %d", TEXT_FOLIO_AVAILABLE_POINTS_NONE="Pontos disponíveis: -", TEXT_FOLIO_SELECTED_NODES_NONE="Nós selecionados: -", TEXT_FOLIO_RANK_FMT="Ranque %d", TEXT_FOLIO_SELECTED="Selecionado", TEXT_FOLIO_NO_COMMITTED_NODES="Nenhum nó ativo do Fólio de Omnium.", LABEL_MIDNIGHT_SEASON_2="Temporada 2 de Midnight", ["The Venomous Abyss"]="O Abismo Venenoso",
    },
    ruRU = {
        BUTTON_GEAR="Экипировка", LABEL_EMPTY="Пусто", TOOLTIP_GEAR_TITLE="Показать экипировку", TOOLTIP_GEAR_DESC="Показать сохранённую экипировку этого персонажа", LABEL_INVENTORY_SLOT_NUMBER_FMT="%s %d", TEXT_GEAR_UPDATED_NEVER="Обновлено: никогда", TEXT_GEAR_UPDATED_AGO_FMT="Обновлено %s назад", LABEL_STATS="Характеристики", TEXT_CALENDAR_LOGGED_IN_FMT="%s входит в игру", TEXT_PROFIT_SOURCE_WEEKLY_CACHE="Еженедельный тайник", TEXT_FOLIO_COMMITTING="Изменения фолианта применяются...", TEXT_FOLIO_UNAVAILABLE_COMBAT="Изменения фолианта недоступны в бою.", TEXT_FOLIO_HELP="ЛКМ — купить. ПКМ — вернуть. Узлы выбора открывают список.", TEXT_FOLIO_UNAVAILABLE_CLIENT="Фолиант Омниума недоступен в этом клиенте.", TEXT_FOLIO_NO_ACTIVE_CONFIG="Активная конфигурация Фолианта Омниума не найдена.", TEXT_FOLIO_NO_ACTIVE_TREE="У персонажа нет активного дерева Фолианта Омниума.", TEXT_FOLIO_NO_NODES="Узлы Фолианта Омниума не найдены.", TEXT_FOLIO_COMMIT_IN_PROGRESS="Изменение фолианта уже применяется.", TEXT_FOLIO_LIVE_CHARACTER="Текущий персонаж", TEXT_FOLIO_PROGRESS_FMT="Выбрано узлов: %d / %d    Потрачено очков: %d", TEXT_FOLIO_AVAILABLE_POINTS_NONE="Доступно очков: -", TEXT_FOLIO_SELECTED_NODES_NONE="Выбрано узлов: -", TEXT_FOLIO_RANK_FMT="Ранг %d", TEXT_FOLIO_SELECTED="Выбрано", TEXT_FOLIO_NO_COMMITTED_NODES="Нет активных узлов Фолианта Омниума.", LABEL_MIDNIGHT_SEASON_2="Midnight, сезон 2", ["The Venomous Abyss"]="Ядовитая бездна",
    },
    zhCN = {
        BUTTON_GEAR="装备", LABEL_EMPTY="空", TOOLTIP_GEAR_TITLE="查看装备", TOOLTIP_GEAR_DESC="查看该角色保存的已装备物品快照", LABEL_INVENTORY_SLOT_NUMBER_FMT="%s %d", TEXT_GEAR_UPDATED_NEVER="更新：从未", TEXT_GEAR_UPDATED_AGO_FMT="%s前更新", LABEL_STATS="属性", TEXT_CALENDAR_LOGGED_IN_FMT="%s 已登录", TEXT_PROFIT_SOURCE_WEEKLY_CACHE="每周宝箱", TEXT_FOLIO_COMMITTING="正在提交宝典更改……", TEXT_FOLIO_UNAVAILABLE_COMBAT="战斗中无法更改宝典。", TEXT_FOLIO_HELP="左键购买，右键退还。选择节点会打开选项。", TEXT_FOLIO_UNAVAILABLE_CLIENT="此客户端无法使用奥秘宝典。", TEXT_FOLIO_NO_ACTIVE_CONFIG="未找到有效的奥秘宝典配置。", TEXT_FOLIO_NO_ACTIVE_TREE="当前角色没有有效的奥秘宝典树。", TEXT_FOLIO_NO_NODES="未找到奥秘宝典节点。", TEXT_FOLIO_COMMIT_IN_PROGRESS="已有宝典更改正在提交。", TEXT_FOLIO_LIVE_CHARACTER="当前角色实时数据", TEXT_FOLIO_PROGRESS_FMT="已选节点：%d / %d    已花费点数：%d", TEXT_FOLIO_AVAILABLE_POINTS_NONE="可用点数：-", TEXT_FOLIO_SELECTED_NODES_NONE="已选节点：-", TEXT_FOLIO_RANK_FMT="等级 %d", TEXT_FOLIO_SELECTED="已选择", TEXT_FOLIO_NO_COMMITTED_NODES="没有已激活的奥秘宝典节点。", LABEL_MIDNIGHT_SEASON_2="至暗之夜第2赛季", ["The Venomous Abyss"]="剧毒深渊",
    },
    zhTW = {
        BUTTON_GEAR="裝備", LABEL_EMPTY="空", TOOLTIP_GEAR_TITLE="檢視裝備", TOOLTIP_GEAR_DESC="檢視此角色儲存的已裝備物品快照", LABEL_INVENTORY_SLOT_NUMBER_FMT="%s %d", TEXT_GEAR_UPDATED_NEVER="更新：從未", TEXT_GEAR_UPDATED_AGO_FMT="%s前更新", LABEL_STATS="屬性", TEXT_CALENDAR_LOGGED_IN_FMT="%s 已登入", TEXT_PROFIT_SOURCE_WEEKLY_CACHE="每週寶箱", TEXT_FOLIO_COMMITTING="正在提交寶典變更……", TEXT_FOLIO_UNAVAILABLE_COMBAT="戰鬥中無法變更寶典。", TEXT_FOLIO_HELP="左鍵購買，右鍵退還。選擇節點會開啟選項。", TEXT_FOLIO_UNAVAILABLE_CLIENT="此客戶端無法使用奧秘寶典。", TEXT_FOLIO_NO_ACTIVE_CONFIG="找不到有效的奧秘寶典設定。", TEXT_FOLIO_NO_ACTIVE_TREE="目前角色沒有有效的奧秘寶典樹。", TEXT_FOLIO_NO_NODES="找不到奧秘寶典節點。", TEXT_FOLIO_COMMIT_IN_PROGRESS="已有寶典變更正在提交。", TEXT_FOLIO_LIVE_CHARACTER="目前角色即時資料", TEXT_FOLIO_PROGRESS_FMT="已選節點：%d / %d    已花費點數：%d", TEXT_FOLIO_AVAILABLE_POINTS_NONE="可用點數：-", TEXT_FOLIO_SELECTED_NODES_NONE="已選節點：-", TEXT_FOLIO_RANK_FMT="等級 %d", TEXT_FOLIO_SELECTED="已選擇", TEXT_FOLIO_NO_COMMITTED_NODES="沒有已啟用的奧秘寶典節點。", LABEL_MIDNIGHT_SEASON_2="至暗之夜第2賽季", ["The Venomous Abyss"]="劇毒深淵",
    },
    koKR = {
        BUTTON_GEAR="장비", LABEL_EMPTY="비어 있음", TOOLTIP_GEAR_TITLE="장비 보기", TOOLTIP_GEAR_DESC="이 캐릭터의 저장된 착용 장비를 봅니다", LABEL_INVENTORY_SLOT_NUMBER_FMT="%s %d", TEXT_GEAR_UPDATED_NEVER="업데이트: 없음", TEXT_GEAR_UPDATED_AGO_FMT="%s 전에 업데이트", LABEL_STATS="능력치", TEXT_CALENDAR_LOGGED_IN_FMT="%s 접속", TEXT_PROFIT_SOURCE_WEEKLY_CACHE="주간 보관함", TEXT_FOLIO_COMMITTING="책자 변경 사항 적용 중...", TEXT_FOLIO_UNAVAILABLE_COMBAT="전투 중에는 책자를 변경할 수 없습니다.", TEXT_FOLIO_HELP="왼쪽 클릭으로 구매하고 오른쪽 클릭으로 환불합니다. 선택 노드는 선택지를 엽니다.", TEXT_FOLIO_UNAVAILABLE_CLIENT="이 클라이언트에서는 옴니움 책자를 사용할 수 없습니다.", TEXT_FOLIO_NO_ACTIVE_CONFIG="활성 옴니움 책자 구성을 찾지 못했습니다.", TEXT_FOLIO_NO_ACTIVE_TREE="현재 캐릭터에 활성 옴니움 책자 트리가 없습니다.", TEXT_FOLIO_NO_NODES="옴니움 책자 노드를 찾지 못했습니다.", TEXT_FOLIO_COMMIT_IN_PROGRESS="책자 변경 사항을 이미 적용 중입니다.", TEXT_FOLIO_LIVE_CHARACTER="현재 캐릭터 실시간", TEXT_FOLIO_PROGRESS_FMT="선택한 노드: %d / %d    사용한 포인트: %d", TEXT_FOLIO_AVAILABLE_POINTS_NONE="사용 가능 포인트: -", TEXT_FOLIO_SELECTED_NODES_NONE="선택한 노드: -", TEXT_FOLIO_RANK_FMT="등급 %d", TEXT_FOLIO_SELECTED="선택됨", TEXT_FOLIO_NO_COMMITTED_NODES="활성화된 옴니움 책자 노드가 없습니다.", LABEL_MIDNIGHT_SEASON_2="한밤 시즌 2", ["The Venomous Abyss"]="맹독의 심연",
    },
}

for locale, additions in pairs(strings) do
    local data = lv.LocaleData and lv.LocaleData[locale]
    if data then
        for key, value in pairs(additions) do data[key] = value end
    end
end

-- Verified English fallbacks for the Captain Tokka tracker. Locales can
-- replace these individually when verified translations become available.
local tokkaFallbacks = {
    BUTTON_FACTION_WEEKLIES="Faction Weeklies",
    BUTTON_CAPTAIN_TOKKA="Captain Tokka",
    LABEL_VALEERA_SANGUINAR="Valeera Sanguinar",
    LABEL_SLAYERS_DUELLUM="Slayer's Duellum",
    LABEL_MAXIMUM="Maximum",
    TITLE_TREASURES_OF_THE_DAMNED="Treasures of the Damned",
    LABEL_COMPLETED="Completed",
    LABEL_NOT_COMPLETED="Not Completed",
    LABEL_QUEST_FMT="Quest: %s",
    LABEL_QUEST_ID_FMT="Quest ID: %d",
    TOOLTIP_TOKKA_TREASURE_HINT="Fish this artifact up on the Coiled Isle and return it to Second Mate Sluggs at Tokka's Folly.",
    WARNING_TOKKA_ONE_TIME_ARTIFACTS="Warning: These artifact quests are one-time Warband turn-ins. They do not reset daily or weekly and can only reward reputation once.",
}
for _, locale in ipairs({ "enUS", "deDE", "frFR", "esES", "ptBR", "ruRU", "zhCN", "zhTW", "koKR" }) do
    local data = lv.LocaleData and lv.LocaleData[locale]
    if data then
        for key, value in pairs(tokkaFallbacks) do
            if data[key] == nil then data[key] = value end
        end
    end
end

-- Active UI strings that older locale files still inherited verbatim from enUS.
local activeTranslations = {
    deDE = { LABEL_CHARACTER="Charakter", TEXT_OMNIUM_FOLIO_UNAVAILABLE="Omniumfoliant ist nicht verfügbar.", TEXT_FOLIO_AVAILABLE_POINTS_FMT="Verfügbare Punkte: %d", LABEL_VAULT_TIER_FMT="Stufe %d", OPTION_ENABLE_MINI_OMNIUM_FOLIO="Mini-Omniumfoliant aktivieren", OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC="Zeigt ein verschiebbares Omniumfoliant-Fenster außerhalb des LiteVault-Hauptfensters.", TITLE_RAID_SEASON_FMT="%s – %s" },
    frFR = { LABEL_CHARACTER="Personnage", TEXT_OMNIUM_FOLIO_UNAVAILABLE="Le folio d’Omnium est indisponible.", TEXT_FOLIO_AVAILABLE_POINTS_FMT="Points disponibles : %d", LABEL_VAULT_TIER_FMT="Palier %d", OPTION_ENABLE_MINI_OMNIUM_FOLIO="Activer le mini folio d’Omnium", OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC="Affiche un panneau mobile du folio d’Omnium hors de la fenêtre principale de LiteVault.", TITLE_RAID_SEASON_FMT="%s – %s" },
    esES = { LABEL_CHARACTER="Personaje", TEXT_OMNIUM_FOLIO_UNAVAILABLE="El folio de Omnium no está disponible.", TEXT_FOLIO_AVAILABLE_POINTS_FMT="Puntos disponibles: %d", LABEL_VAULT_TIER_FMT="Nivel %d", OPTION_ENABLE_MINI_OMNIUM_FOLIO="Activar minifolio de Omnium", OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC="Muestra un panel móvil del folio de Omnium fuera de la ventana principal de LiteVault.", TITLE_RAID_SEASON_FMT="%s - %s" },
    ptBR = { LABEL_CHARACTER="Personagem", TEXT_OMNIUM_FOLIO_UNAVAILABLE="O Fólio de Omnium não está disponível.", TEXT_FOLIO_AVAILABLE_POINTS_FMT="Pontos disponíveis: %d", LABEL_VAULT_TIER_FMT="Nível %d", OPTION_ENABLE_MINI_OMNIUM_FOLIO="Ativar Mini Fólio de Omnium", OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC="Mostra um painel móvel do Fólio de Omnium fora da janela principal do LiteVault.", TITLE_RAID_SEASON_FMT="%s - %s" },
    ruRU = { LABEL_CHARACTER="Персонаж", TEXT_OMNIUM_FOLIO_UNAVAILABLE="Фолиант Омниума недоступен.", TEXT_FOLIO_AVAILABLE_POINTS_FMT="Доступно очков: %d", LABEL_VAULT_TIER_FMT="Уровень %d", OPTION_ENABLE_MINI_OMNIUM_FOLIO="Включить мини-фолиант Омниума", OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC="Показывает перемещаемую панель Фолианта Омниума вне главного окна LiteVault.", TITLE_RAID_SEASON_FMT="%s — %s" },
    zhCN = { LABEL_CHARACTER="角色", TEXT_OMNIUM_FOLIO_UNAVAILABLE="奥秘宝典不可用。", TEXT_FOLIO_AVAILABLE_POINTS_FMT="可用点数：%d", LABEL_VAULT_TIER_FMT="层级 %d", OPTION_ENABLE_MINI_OMNIUM_FOLIO="启用迷你奥秘宝典", OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC="在 LiteVault 主窗口外显示可移动的奥秘宝典面板。", TITLE_RAID_SEASON_FMT="%s - %s" },
    zhTW = { LABEL_CHARACTER="角色", TEXT_OMNIUM_FOLIO_UNAVAILABLE="奧秘寶典無法使用。", TEXT_FOLIO_AVAILABLE_POINTS_FMT="可用點數：%d", LABEL_VAULT_TIER_FMT="層級 %d", OPTION_ENABLE_MINI_OMNIUM_FOLIO="啟用迷你奧秘寶典", OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC="在 LiteVault 主視窗外顯示可移動的奧秘寶典面板。", TITLE_RAID_SEASON_FMT="%s - %s" },
    koKR = { LABEL_CHARACTER="캐릭터", TEXT_OMNIUM_FOLIO_UNAVAILABLE="옴니움 책자를 사용할 수 없습니다.", TEXT_FOLIO_AVAILABLE_POINTS_FMT="사용 가능 포인트: %d", LABEL_VAULT_TIER_FMT="단계 %d", OPTION_ENABLE_MINI_OMNIUM_FOLIO="미니 옴니움 책자 사용", OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC="LiteVault 주 창 밖에 이동 가능한 옴니움 책자 패널을 표시합니다.", TITLE_RAID_SEASON_FMT="%s - %s" },
}
for locale, additions in pairs(activeTranslations) do
    local data = lv.LocaleData and lv.LocaleData[locale]
    if data then for key, value in pairs(additions) do data[key] = value end end
end

local raidRedesignTranslations = {
    deDE = { TAB_RAID_CURRENT="Aktuell", TAB_RAID_LEGACY="Vergangen", LABEL_WARBAND_PROGRESSION="Kriegsmeutenfortschritt", STATUS_KILLED="Besiegt", STATUS_NOT_KILLED="Nicht besiegt", LABEL_KILLED_BY="Besiegt von:", TEXT_NO_WARBAND_RAID_KILL="Kein verfolgter Charakter hat diesen Sieg.", TEXT_MORE_CHARACTERS_FMT="+ %d weitere", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", LABEL_RAID_AOTC="Kriegsmeute: Der Zeit voraus", LABEL_RAID_CUTTING_EDGE="Kriegsmeute: Spitzenreiter", MSG_RAID_DEBUG_NO_ENCOUNTER="In dieser Sitzung wurde noch kein ENCOUNTER_END-Ereignis beobachtet." },
    frFR = { TAB_RAID_CURRENT="Actuel", TAB_RAID_LEGACY="Héritage", LABEL_WARBAND_PROGRESSION="Progression du bataillon", STATUS_KILLED="Vaincu", STATUS_NOT_KILLED="Non vaincu", LABEL_KILLED_BY="Vaincu par :", TEXT_NO_WARBAND_RAID_KILL="Aucun personnage suivi ne possède cette victoire.", TEXT_MORE_CHARACTERS_FMT="+ %d autres", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", LABEL_RAID_AOTC="Bataillon : Une longueur d’avance", LABEL_RAID_CUTTING_EDGE="Bataillon : À la pointe", MSG_RAID_DEBUG_NO_ENCOUNTER="Aucun événement ENCOUNTER_END observé pendant cette session." },
    esES = { TAB_RAID_CURRENT="Actual", TAB_RAID_LEGACY="Legado", LABEL_WARBAND_PROGRESSION="Progreso de la banda guerrera", STATUS_KILLED="Derrotado", STATUS_NOT_KILLED="No derrotado", LABEL_KILLED_BY="Derrotado por:", TEXT_NO_WARBAND_RAID_KILL="Ningún personaje registrado tiene esta derrota.", TEXT_MORE_CHARACTERS_FMT="+ %d más", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", LABEL_RAID_AOTC="Banda guerrera: Aventajado", LABEL_RAID_CUTTING_EDGE="Banda guerrera: Al límite", MSG_RAID_DEBUG_NO_ENCOUNTER="No se observó ningún evento ENCOUNTER_END durante esta sesión." },
    ptBR = { TAB_RAID_CURRENT="Atual", TAB_RAID_LEGACY="Legado", LABEL_WARBAND_PROGRESSION="Progressão do Bando de Guerra", STATUS_KILLED="Derrotado", STATUS_NOT_KILLED="Não derrotado", LABEL_KILLED_BY="Derrotado por:", TEXT_NO_WARBAND_RAID_KILL="Nenhum personagem rastreado tem esta vitória.", TEXT_MORE_CHARACTERS_FMT="+ %d outros", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", LABEL_RAID_AOTC="Bando de Guerra: À Frente", LABEL_RAID_CUTTING_EDGE="Bando de Guerra: Vanguarda", MSG_RAID_DEBUG_NO_ENCOUNTER="Nenhum evento ENCOUNTER_END foi observado nesta sessão." },
    ruRU = { TAB_RAID_CURRENT="Текущий", TAB_RAID_LEGACY="Прошлые", LABEL_WARBAND_PROGRESSION="Прогресс отряда", STATUS_KILLED="Побеждён", STATUS_NOT_KILLED="Не побеждён", LABEL_KILLED_BY="Победили:", TEXT_NO_WARBAND_RAID_KILL="Ни у одного отслеживаемого персонажа нет этой победы.", TEXT_MORE_CHARACTERS_FMT="+ ещё %d", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", LABEL_RAID_AOTC="Отряд: Герой своего времени", LABEL_RAID_CUTTING_EDGE="Отряд: На кромке лезвия", MSG_RAID_DEBUG_NO_ENCOUNTER="В этом сеансе событие ENCOUNTER_END не наблюдалось." },
    zhCN = { TAB_RAID_CURRENT="当前", TAB_RAID_LEGACY="旧赛季", LABEL_WARBAND_PROGRESSION="战团进度", STATUS_KILLED="已击杀", STATUS_NOT_KILLED="未击杀", LABEL_KILLED_BY="击杀角色：", TEXT_NO_WARBAND_RAID_KILL="没有已追踪角色完成此击杀。", TEXT_MORE_CHARACTERS_FMT="另有 %d 个", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", LABEL_RAID_AOTC="战团：引领潮流", LABEL_RAID_CUTTING_EDGE="战团：千钧一发", MSG_RAID_DEBUG_NO_ENCOUNTER="本次会话尚未观察到 ENCOUNTER_END 事件。" },
    zhTW = { TAB_RAID_CURRENT="目前", TAB_RAID_LEGACY="舊賽季", LABEL_WARBAND_PROGRESSION="戰隊進度", STATUS_KILLED="已擊殺", STATUS_NOT_KILLED="未擊殺", LABEL_KILLED_BY="擊殺角色：", TEXT_NO_WARBAND_RAID_KILL="沒有已追蹤角色完成此擊殺。", TEXT_MORE_CHARACTERS_FMT="另有 %d 個", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", LABEL_RAID_AOTC="戰隊：領先群雄", LABEL_RAID_CUTTING_EDGE="戰隊：名人堂", MSG_RAID_DEBUG_NO_ENCOUNTER="本次連線尚未觀察到 ENCOUNTER_END 事件。" },
    koKR = { TAB_RAID_CURRENT="현재", TAB_RAID_LEGACY="이전 시즌", LABEL_WARBAND_PROGRESSION="전투부대 진행도", STATUS_KILLED="처치", STATUS_NOT_KILLED="미처치", LABEL_KILLED_BY="처치한 캐릭터:", TEXT_NO_WARBAND_RAID_KILL="이 우두머리를 처치한 추적 캐릭터가 없습니다.", TEXT_MORE_CHARACTERS_FMT="외 %d명", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", LABEL_RAID_AOTC="전투부대: 정예", LABEL_RAID_CUTTING_EDGE="전투부대: 최정예", MSG_RAID_DEBUG_NO_ENCOUNTER="이번 접속에서 ENCOUNTER_END 이벤트가 관찰되지 않았습니다." },
}
for locale, additions in pairs(raidRedesignTranslations) do
    local data = lv.LocaleData and lv.LocaleData[locale]
    if data then for key, value in pairs(additions) do data[key] = value end end
end

local tideboundTranslations = {
    deDE = { DIFFICULTY_WORLD="Welt", ["The Tidebound Grotto"]="The Tidebound Grotto", ["Nymrissa Wavecaller"]="Nymrissa Wavecaller" },
    frFR = { DIFFICULTY_WORLD="Monde", ["The Tidebound Grotto"]="The Tidebound Grotto", ["Nymrissa Wavecaller"]="Nymrissa Wavecaller" },
    esES = { DIFFICULTY_WORLD="Mundo", ["The Tidebound Grotto"]="The Tidebound Grotto", ["Nymrissa Wavecaller"]="Nymrissa Wavecaller" },
    ptBR = { DIFFICULTY_WORLD="Mundo", ["The Tidebound Grotto"]="The Tidebound Grotto", ["Nymrissa Wavecaller"]="Nymrissa Wavecaller" },
    ruRU = { DIFFICULTY_WORLD="Мир", ["The Tidebound Grotto"]="The Tidebound Grotto", ["Nymrissa Wavecaller"]="Nymrissa Wavecaller" },
    zhCN = { DIFFICULTY_WORLD="世界", ["The Tidebound Grotto"]="The Tidebound Grotto", ["Nymrissa Wavecaller"]="Nymrissa Wavecaller" },
    zhTW = { DIFFICULTY_WORLD="世界", ["The Tidebound Grotto"]="The Tidebound Grotto", ["Nymrissa Wavecaller"]="Nymrissa Wavecaller" },
    koKR = { DIFFICULTY_WORLD="야외", ["The Tidebound Grotto"]="The Tidebound Grotto", ["Nymrissa Wavecaller"]="Nymrissa Wavecaller" },
}
for locale, additions in pairs(tideboundTranslations) do
    local data = lv.LocaleData and lv.LocaleData[locale]
    if data then for key, value in pairs(additions) do data[key] = value end end
end

local unifiedRaidTranslations = {
    deDE = { TITLE_RAIDS="Schlachtzüge", TITLE_RAIDS_CHARACTER_FMT="{character} – {raids} – {season}", LABEL_THIS_WEEK="Diese Woche", LABEL_WARBAND="Kriegsmeute", LABEL_CHARACTER_PROGRESSION="Charakterfortschritt", STATUS_SAVED_KILLED="Gespeichert / besiegt", STATUS_NOT_SAVED_KILLED="Diese Woche nicht als besiegt erfasst" },
    frFR = { TITLE_RAIDS="Raids", TITLE_RAIDS_CHARACTER_FMT="{character} – {raids} – {season}", LABEL_THIS_WEEK="Cette semaine", LABEL_WARBAND="Bataillon", LABEL_CHARACTER_PROGRESSION="Progression du personnage", STATUS_SAVED_KILLED="Sauvegardé / vaincu", STATUS_NOT_SAVED_KILLED="Non enregistré comme vaincu cette semaine" },
    esES = { TITLE_RAIDS="Bandas", TITLE_RAIDS_CHARACTER_FMT="{character} - {raids} - {season}", LABEL_THIS_WEEK="Esta semana", LABEL_WARBAND="Banda guerrera", LABEL_CHARACTER_PROGRESSION="Progreso del personaje", STATUS_SAVED_KILLED="Guardado / derrotado", STATUS_NOT_SAVED_KILLED="No figura como derrotado esta semana" },
    ptBR = { TITLE_RAIDS="Raides", TITLE_RAIDS_CHARACTER_FMT="{character} - {raids} - {season}", LABEL_THIS_WEEK="Esta semana", LABEL_WARBAND="Bando de Guerra", LABEL_CHARACTER_PROGRESSION="Progressão do personagem", STATUS_SAVED_KILLED="Salvo / derrotado", STATUS_NOT_SAVED_KILLED="Não registrado como derrotado nesta semana" },
    ruRU = { TITLE_RAIDS="Рейды", TITLE_RAIDS_CHARACTER_FMT="{character} — {raids} — {season}", LABEL_THIS_WEEK="На этой неделе", LABEL_WARBAND="Отряд", LABEL_CHARACTER_PROGRESSION="Прогресс персонажа", STATUS_SAVED_KILLED="Сохранён / побеждён", STATUS_NOT_SAVED_KILLED="На этой неделе не отмечен как побеждённый" },
    zhCN = { TITLE_RAIDS="团队副本", TITLE_RAIDS_CHARACTER_FMT="{character} - {raids} - {season}", LABEL_THIS_WEEK="本周", LABEL_WARBAND="战团", LABEL_CHARACTER_PROGRESSION="角色进度", STATUS_SAVED_KILLED="已保存 / 已击杀", STATUS_NOT_SAVED_KILLED="本周未记录为已击杀" },
    zhTW = { TITLE_RAIDS="團隊副本", TITLE_RAIDS_CHARACTER_FMT="{character} - {raids} - {season}", LABEL_THIS_WEEK="本週", LABEL_WARBAND="戰隊", LABEL_CHARACTER_PROGRESSION="角色進度", STATUS_SAVED_KILLED="已儲存 / 已擊殺", STATUS_NOT_SAVED_KILLED="本週未記錄為已擊殺" },
    koKR = { TITLE_RAIDS="공격대", TITLE_RAIDS_CHARACTER_FMT="{character} - {raids} - {season}", LABEL_THIS_WEEK="이번 주", LABEL_WARBAND="전투부대", LABEL_CHARACTER_PROGRESSION="캐릭터 진행도", STATUS_SAVED_KILLED="귀속 / 처치", STATUS_NOT_SAVED_KILLED="이번 주 처치로 기록되지 않음" },
}
for locale, additions in pairs(unifiedRaidTranslations) do
    local data = lv.LocaleData and lv.LocaleData[locale]
    if data then for key, value in pairs(additions) do data[key] = value end end
end

local yesterday = {
    enUS="Yesterday", deDE="Gestern", frFR="Hier", esES="Ayer", ptBR="Ontem",
    ruRU="Вчера", zhCN="昨天", zhTW="昨天", koKR="어제",
}
for locale, value in pairs(yesterday) do
    if lv.LocaleData and lv.LocaleData[locale] then lv.LocaleData[locale].TIME_YESTERDAY = value end
end

-- Complete the small set of canonical phrase/source keys missing from older
-- locale files. Achievement titles are proper nouns pending API localization.
for locale, data in pairs(lv.LocaleData or {}) do
    data["TEXT_PROFIT_FALLBACK_WOW_TOKEN_PURCHASE"] = data["TEXT_PROFIT_FALLBACK_WOW_TOKEN_PURCHASE"] or "WoW Token Purchase"
    data["TEXT_PROFIT_SOURCE_WOW_TOKEN"] = data["TEXT_PROFIT_SOURCE_WOW_TOKEN"] or "WoW Token"
    data.MSG_RAID_HISTORY_PRESERVED = data.MSG_RAID_HISTORY_PRESERVED or strings.enUS.MSG_RAID_HISTORY_PRESERVED
end

-- Phase 1 architecture keys intentionally inherit canonical English until the
-- translation pass. Keeping the list explicit makes that debt validator-visible.
local phaseOneFallbackKeys = {
    "MSG_NO_FACTION_WEEKLY_COMPLETIONS", "TOOLTIP_QUEST_ID_FMT", "CALENDAR_MONTH_YEAR_FMT",
    "LABEL_RENOWN_LEVEL_MAXIMUM_FMT", "LABEL_RENOWN_LEVEL_PROGRESS_FMT", "LABEL_RENOWN_LEVEL_FMT",
    "LABEL_RENOWN_VALUE_FMT", "TEXT_CRESTS_WITH_VALUES_FMT", "TOOLTIP_REWARDS_FMT",
    "TOOLTIP_MOUNT_COLLECTED_FMT", "TOOLTIP_MOUNT_UNCOLLECTED_FMT", "LABEL_REWARD", "LABEL_NOTE", "STATUS_ACTIVE",
    "TOOLTIP_ENTRANCE_COORDINATES_FMT", "TOOLTIP_INSCRIPTION_COORDINATES_FMT",
    "TOOLTIP_ENTRANCE_INSCRIPTION_CLICK_INSTRUCTIONS", "LABEL_100_RENOWN_FMT",
    "TOOLTIP_ACHIEVEMENT_CREDIT_FROM_FMT", "NOTE_HARANDAR_TREASURE_REQUIREMENTS",
    "NOTE_FORGOTTEN_MASK_LOCATION", "NOTE_HEAD_MASONS_TABLET_LOCATION", "NOTE_PROFANED_PLAQUE_LOCATION",
}
local phaseOneEnglish = lv.LocaleData and lv.LocaleData.enUS
if phaseOneEnglish then
    for locale, data in pairs(lv.LocaleData or {}) do
        if locale ~= "enUS" then
            for _, key in ipairs(phaseOneFallbackKeys) do data[key] = data[key] or phaseOneEnglish[key] end
        end
    end
end

lv.ReloadLocales()
