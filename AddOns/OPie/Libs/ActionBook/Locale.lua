local L, _, T = 0, ...
if T.SkipLocalActionBook then return end
L, T.ActionBook.LW = T.ActionBook.LW, nil

local C, z, V, K = GetLocale(), nil
V =
    C == "deDE" and { -- 38/43 (88%)
      "Fähigkeiten", "Auch Gegenstände mit gleichem Namen nutzen", z, z, "Kampfhaustier", "Kampfhaustiere", "Kalender", "Eigenes Makro", "Reitdrache", "Ausrüstungsset",
      "Ausrüstungsslot", "Ausrüstungssets", "Ausgerüstet", "Zusätzlicher Aktionsbutton", "Flugreittier", "Spielmenü", "Bodenreittier", "Interface Fenster", "Gegenstand", "Gegenstände",
      "Makro", "Makros", "Verschiedenes", "Reittier", "Reittiere", "Neues Makro", "Zeige nur wenn angelegt", "Outfit", z, "Begleiterfähigkeit",
      "Begleiterfähigkeiten", "Zielmarkierungssymbol", "Weltmarkierung", "Markierungssymbole", "Zeige einen Platzhalter wenn nicht verfügbar", "Zauber", "Spielzeug", "Spielzeuge", "UI Fenster", z,
      z, "Benutze den höchsten bekannten Rang", "Zonenfähigkeiten",
    }
    or C == "esES" and { -- 38/43 (88%)
      "Habilidades", "Usar otros artículos con el mismo nombre", z, z, "Mascota de duelo", "Mascotas de duelo", "Calendario", "Macro personalizado", "Montura de Dracoequitación", "Conjunto de equipamiento",
      "Hueco de Equipo", "Conjuntos de equipamiento", "Equipado", "Botón de acción extra", "Montura voladora", "Menú de juego", "Montura terrestre", "Panel de interfaz", "Artículo", "Artículos",
      "Macro", "Macros", "Misceláneo", "Montura", "Monturas", "Nueva macro", "Mostrar sólo al equipar", "Atuendo", z, "Habilidad de mascota",
      "Habilidades de mascota", "Marcador de objetivo", "Marcador del mundo", "Marcadores del mundo", "Mostrar un marcador cuando no esté disponible", "Hechizo", "Juguete", "Juguetes", "Paneles de IU", z,
      z, "Usar el rango mas alto", "Habilidades de zona",
    }
    or C == "esMX" and { -- 38/43 (88%)
      "Habilidades", "Usar otros artículos con el mismo nombre", z, z, "Mascota de duelo", "Mascotas de duelo", "Calendario", "Macro personalizado", "Montura de vuelo de dragón", "Conjunto de equipamientos",
      "Ranura de equipo", "Conjuntos de equipamiento", "Equipado", "Botón de acción extra", "Montura voladora", "Menú de juego", "Montura terrestre", "Panel de interfaz", "Artículo", "Artículos",
      "Macro", "Macros", "Misceláneo", "Montura", "Monturas", "Nueva Macro", "Mostrar sólo al equipar", "Indumentaria", z, "Hablidad de mascota",
      "Habilidades de mascota", "Marcador del mundo", "Marcador del mundo", "Marcadores del mundo", "Mostrar un sustituto cuando no esté disponible", "Hechizo", "Juegete", "Juguetes", "Paneles de interfaz de usuario", z,
      z, "Usar el rango más alto conocido", "Habilidades de area",
    }
    or C == "frFR" and { -- 38/43 (88%)
      "Compétences", "Également utiliser l'élément avec le même nom", z, z, "Mascotte de combat", "Mascottes de combat", "Calendrier", "Macro personnalisée", "Monture draconique", "Set d'équipement",
      "Emplacement d'équipement", "Équipement de sets", "Équipés", "Bouton d'action supplémentaire", "Montures volantes", "Menu de jeu", "Monture terrestre", "Fenêtre", "Objet", "Objets",
      "Macro", "Macros", "Divers", "Monture", "Montures", "Nouvelle Macro", "Afficher seulement quand équipé", "Tenue", z, "Compétence du Familier",
      "Compétences du familier", "Marqueur de Raid", "Marqueur de Terrain", "Marqueurs de Raid", "Afficher un remplacement quand indisponible", "Sort", "Jouet", "Jouets", "Fenêtres de l'interface", z,
      z, "Utiliser le rang le plus élevé connu", "Compétences de zone",
    }
    or C == "itIT" and { -- 37/43 (86%)
      "Abilità", "Usa anche gli oggetti con lo stesso nome", z, z, "Mascotte", "Mascotte", "Calendario", "Macro Personalizzate", z, "Set equipaggiamento",
      "Slot equipaggiamento", "Collezione di set", "Equipaggiato", "Pulsante azioni extra", "Cavalcatura volante", "Menu di gioco", "Cavalcatura terrestre", "Pannello UI", "Oggetto", "Oggetti",
      "Macro", "Le macro", "Varie", "Cavalcatura", "Cavalcature", "Nuova Macro", "Mostra solo se equipaggiato", "Completo", z, "Abilità del famiglio",
      "Collezione abilità del famiglio", "Segnalini Raid", "Segnalini raid mondiali", "Segnalini raid", "Mostra un segnaposto quando non disponibile", "Incantesimo", "Giocattolo", "Giocattoli", "Pannelli UI", z,
      z, "Usare il grado più alto conosciuto.", "Abilità di Zona.",
    }
    or C == "koKR" and { -- 43/43 (100%)
      "능력", "같은 이름의 아이템 사용", "외형 잠금", "외형 잠금 해제", "애완동물 대전", "전투 애완동물", "달력", "사용자 정의 매크로", "용조련술 탈것", "장비 구성",
      "장비 칸", "장비 구성", "착용", "추가 행동 버튼", "비행 탈것", "게임 메뉴", "지상 탈것", "인터페이스 메뉴", "아이템", "아이템",
      "매크로", "매크로", "기타", "탈것", "탈것", "새 매크로", "착용 시에만 표시", "의상", "의상", "소환수 능력",
      "소환수 능력", "공격대 징표", "공격대 바닥 징표", "공격대 징표", "사용 불가능할 때 점선으로 표시", "주문", "장난감", "장난감", "UI 메뉴", "이 모양을 상황으로 대체하려면 다시 사용하세요.",
      "이 표시가 상황으로 대체되는 것을 방지하려면 다시 사용하세요.", "가장 높은 등급 기술 사용", "지역 기술",
    }
    or C == "ruRU" and { -- 38/43 (88%)
      "Способности", "Использовать предметы с таким же именем", z, z, "Боевой питомец", "Боевые питомцы", "Календарь", "Пользовательские макросы", "Средство передвижения для полётов на драконе", "Комплект экипировки",
      "Ячейка экипировки", "Комплекты экипировки", "Надето", "Дополнительная кнопка действия", "Воздушные средства передвижения", "Главное меню", "Наземные средства передвижения", "Панель интерфейса", "Предмет", "Предметы",
      "Макрос", "Макросы", "Разное", "Средство передвижения", "Средства передвижения", "Новый Макрос", "Показывать только если надет", "Снаряжение", z, "Способности питомца",
      "Способности питомцев", "Рейдовая метка", "Метка рейда", "Рейдовые метки", "Всегда показывать этот фрагмент", "Заклинание", "Игрушки", "Игрушки", "Панели пользовательского интерфейса", z,
      z, "Использовать наивысший изученный ранг", "Способности местности",
    }
    or C == "zhCN" and { -- 38/43 (88%)
      "技能", "同样使用具有相同名字的物品", z, z, "战斗宠物", "战斗宠物", "日历", "自定义宏", "驭龙术坐骑", "套装方案",
      "装备栏位", "套装方案", "装备", "额外动作按钮", "飞行坐骑", "主菜单", "地面坐骑", "界面面板", "物品", "物品",
      "宏", "宏", "杂项", "坐骑", "坐骑", "新建宏", "仅在已装备时显示", "外观方案", z, "宠物技能",
      "宠物技能", "团队标记", "团队世界标记", "团队标记", "不可用时显示占位符", "法术", "玩具", "玩具", "UI面板", z,
      z, "使用已知的最高等级技能", "区域技能",
    }
    or C == "zhTW" and { -- 38/43 (88%)
      "技能", "也要使用名稱相同的物品", z, z, "戰寵", "戰寵", "行事曆", "自訂巨集", "飛龍騎術坐騎", "套裝",
      "裝備欄位", "套裝", "已裝備", "額外動作按鈕", "飛行坐騎", "遊戲選項", "地面坐騎", "介面視窗", "物品", "物品",
      "巨集", "巨集", "雜項", "坐騎", "坐騎", "新增巨集", "只有裝備在身上時才顯示", "服裝", z, "寵物技能",
      "寵物技能", "團隊標記圖示", "團隊世界標記圖示", "團隊標記圖示", "無法使用時顯示暫代圖示", "技能", "玩具", "玩具", "介面視窗", z,
      z, "使用已學會的最高等級", "區域能力",
    }
    or C == "ptBR" and { -- 39/43 (90%)
      "Habilidades", "Também usar itens com o mesmo nome", z, z, "Batalha de mascote", "Mascotes de batalha", "Calendário", "Macro Personalizada", "Montaria de Dragonaria", "Conjunto de equipamento",
      "Slot de Equipamento", "Conjuntos de equipamentos", "Equipado", "Botão de ação extra", "Montaria Voadora", "Menu do Jogo", "Montaria Terrestre", "Painel de Interface", "Item", "Itens",
      "Macro", "Macros", "Variados", "Montaria", "Montarias", "Novo Macro", "Apenas mostrar quando equipado", "Roupa", "Conjuntos", "Habilidade de Mascote",
      "Habilidades de Mascote", "Marcadores de Raide", "Marcadores Globais de Raide", "Marcadores de raide", "Sempre mostrar essa fatia quando indisponível", "Feitiço", "Brinquedo", "Bringquedos", "Painéis de UI", z,
      z, "Usar o mais alto ranque conhecido", "Habilidades da Zona",
    } or nil

K = V and {
      "Abilities", "Also use items with the same name", "Appearance locked", "Appearance unlocked", "Battle Pet", "Battle pets", "Calendar", "Custom Macro", "Dragonriding Mount", "Equipment Set",
      "Equipment Slot", "Equipment sets", "Equipped", "Extra Action Button", "Flying Mount", "Game Menu", "Ground Mount", "Interface Panel", "Item", "Items",
      "Macro", "Macros", "Miscellaneous", "Mount", "Mounts", "New Macro", "Only show when equipped", "Outfit", "Outfits", "Pet Ability",
      "Pet abilities", "Raid Marker", "Raid World Marker", "Raid markers", "Show a placeholder when unavailable", "Spell", "Toy", "Toys", "UI panels", "Use again to allow this apperance to be replaced by a Situation.",
      "Use again to prevent this apperance from being replaced by a Situation.", "Use the highest known rank", "Zone Abilities",
}

for i=1,K and #K or 0 do
	L[K[i]] = V[i]
end