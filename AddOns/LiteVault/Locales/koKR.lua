-- koKR.lua - Korean locale for LiteVault
local addonName, lv = ...

local L = {
    -- ==========================================================================
    -- ADDON INFO
    -- ==========================================================================
    ADDON_NAME = "LiteVault",

    -- ==========================================================================
    -- COMMON UI ELEMENTS
    -- ==========================================================================
    BUTTON_CLOSE = "닫기",
    BUTTON_YES = "예",
    BUTTON_NO = "아니오",
    BUTTON_MANAGE = "관리",
    BUTTON_BACK = "뒤로",
    BUTTON_ALL = "모두",
    BUTTON_NONE = "없음",
    BUTTON_FILTER = "필터",
    TAB_TRACKERS = "추적기",
    TAB_META_ACHIEVEMENTS = "메타 업적",
    TEXT_FOLIO_NODE_FMT = "노드 %d",
    TEXT_GEAR_TITLE_FMT = "%s의 %s",
    LABEL_GEAR_CRIT = "치명타",
    LABEL_GEAR_HASTE = "가속",
    LABEL_GEAR_MASTERY = "특화",
    LABEL_GEAR_VERS = "유연성",
    TEXT_GEAR_ILVL_COLORED_FMT = "아이템 레벨 |c%s%d|r",
    STATUS_LIVE = "[실시간]",
    STATUS_CACHED = "[캐시됨]",
    STATUS_STALE = "[오래됨]",
    TAB_OVERVIEW = "개요",
    DIALOG_DELETE_CHAR = "LiteVault에서 %s 삭제할까요?",
    LABEL_MYTHIC_PLUS = "M+",

    -- ==========================================================================
    -- MAIN WINDOW
    -- ==========================================================================
    TITLE_LITEVAULT = "LiteVault",
    TITLE_MAP_FILTERS = "지도 필터",

    BUTTON_RAID_LOCKOUTS = "공격대 귀속",
    BUTTON_WORLD_EVENTS = "월드 이벤트",

    TOOLTIP_RAID_LOCKOUTS_TITLE = "공격대 귀속",
    TOOLTIP_RAID_LOCKOUTS_DESC = "모든 캐릭터의 보스 처치 현황 보기",
    TOOLTIP_THEME_TITLE = "테마 전환",
    TOOLTIP_THEME_DESC = "다크 모드와 라이트 모드 전환",
    TOOLTIP_FILTER_TITLE = "지도 필터",
    TOOLTIP_FILTER_DESC = "전체 목록 보기 클릭",
    TOOLTIP_WORLD_EVENTS_TITLE = "월드 이벤트",
    TOOLTIP_WORLD_EVENTS_DESC = "월드 이벤트 보기",

    -- Sort controls
    LABEL_SORT_BY = "정렬:",
    SORT_GOLD = "골드",
    SORT_ILVL = "템렙",
    SORT_MPLUS = "M+",
    SORT_LAST_ACTIVE = "활동",

    -- ==========================================================================
    -- TRACKING DISPLAYS
    -- ==========================================================================
    LABEL_WEEKLY_QUESTS = "%s의 주간 퀘스트",
    LABEL_WEEKLY_COMPLETION_SUMMARY = "%d / %d 완료",
    BUTTON_WEEKLIES = "주간",
    BUTTON_EVENTS = "이벤트",
    BUTTON_FACTIONS = "세력",
    BUTTON_AMANI_TRIBE = "아마니 부족",
    BUTTON_HARATI = "하라티",
    BUTTON_SINGULARITY = "특이점",
    BUTTON_SILVERMOON_COURT = "실버문 궁정",
    TITLE_FACTION_WEEKLIES = "%s의 세력 주간 퀘스트",
    WARNING_EVENT_QUESTS = "이 이벤트 중 일부는 게임 내에서 버그가 있거나 잠겨 있을 수 있습니다.",

    WARNING_WEEKLY_HARATI_CHOICE = "경고! 하라니르 전설 퀘스트를 선택하면 계정 전체에 잠깁니다.",
    WARNING_WEEKLY_RUNESTONES = "경고! 룬석 퀘스트는 신중히 선택하세요. 이번 주에 하나를 고르면 그 선택은 계정 전체에 적용됩니다.",
    LABEL_WEEKLY_PROFIT = "주간 수익:",
    LABEL_WARBAND_PROFIT = "전투단 수익:",
    LABEL_WARBAND_BANK = "전투단 은행:",
    LABEL_TOP_EARNERS = "최고 수익 (주간):",
    LABEL_TOTAL_GOLD = "총 골드: %s",
    LABEL_TOTAL_TIME = "총 시간: %s",
    LABEL_COMBINED_TIME = "합계 시간: %d일 %d시간",

    TOOLTIP_TOTAL_TIME_TITLE = "총 시간",
    TOOLTIP_TOTAL_TIME_DESC = "추적 중인 모든 캐릭터의 총 플레이 시간",
    TOOLTIP_TOTAL_TIME_CLICK = "형식 변경 클릭",

    -- Quest status
    STATUS_DONE = "[완료]",
    STATUS_IN_PROGRESS = "[진행 중]",
    STATUS_NOT_STARTED = "[시작 안 함]",

    -- ==========================================================================
    -- CHARACTER LIST
    -- ==========================================================================
    TOOLTIP_MANAGE_TITLE = "캐릭터 관리",
    TOOLTIP_MANAGE_BACK = "메인 탭으로 돌아가기",
    TOOLTIP_MANAGE_VIEW = "무시된 캐릭터 보기",

    TOOLTIP_CATALYST_TITLE = "촉매 충전",
    TOOLTIP_SPARKS_TITLE = "제작 불꽃",
    TOOLTIP_VOIDSHARDS_TITLE = "승천한 공허 파편",
    TOOLTIP_VOIDCORES_TITLE = "승천한 공허핵",

    TOOLTIP_VAULT_TITLE = "대금고",
    TOOLTIP_VAULT_DESC = "대금고 열기 클릭",
    TOOLTIP_VAULT_ACTIVE_ONLY = "대금고 열기.",
    TOOLTIP_VAULT_ALT_ONLY = "대금고는 현재 활성 캐릭터로만 열 수 있습니다.",

    TOOLTIP_CURRENCY_TITLE = "캐릭터 화폐",
    TOOLTIP_CURRENCY_DESC = "전체 목록 보기 클릭",

    TOOLTIP_BAGS_TITLE = "가방 보기",
    TOOLTIP_BAGS_DESC = "이 캐릭터의 저장된 가방 및 재료 가방 내용 보기.",

    TOOLTIP_LEDGER_DESC = "출처별 골드 수입 및 지출 추적",

    TOOLTIP_WARBAND_BANK_TITLE = "전투단 은행 장부",
    TOOLTIP_WARBAND_BANK_DESC = "전투단 은행 거래 내역 보기 클릭",

    TOOLTIP_RESTORE_TITLE = "복원",
    TOOLTIP_RESTORE_DESC = "이 캐릭터를 메인 페이지로 복원",

    TOOLTIP_IGNORE_TITLE = "무시",
    TOOLTIP_IGNORE_DESC = "이 캐릭터를 메인 페이지에서 제거",

    TOOLTIP_DELETE_TITLE = "삭제",
    TOOLTIP_DELETE_DESC = "이 캐릭터의 데이터 영구 삭제",
    TOOLTIP_DELETE_WARNING = "경고: 이 작업은 취소할 수 없습니다!",

    TOOLTIP_FAVORITE_TITLE = "즐겨찾기",
    TOOLTIP_FAVORITE_DESC = "이 캐릭터를 목록 상단에 고정",

    -- Character data displays
    LABEL_ILVL = "템렙: %d",
    LABEL_MPLUS_SCORE = "쐐기 점수: %d",
    LABEL_NO_KEY = "쐐기 열쇠 없음",
    LABEL_NO_PROFESSIONS = "전문 기술 없음",
    LABEL_UNKNOWN = "알 수 없음",
    LABEL_SKILL_LEVEL = "기술: %d/%d",
    LABEL_CONCENTRATION = "집중력: %d/%d",
    LABEL_CONC_DAILY_RESET = "일일: %d시간 %d분",
    LABEL_CONC_WEEKLY_RESET = "전체 초기화: %d일 %d시간",
    LABEL_CONC_FULL = "(최대)",
    LABEL_KNOWLEDGE_AVAILABLE = "%d 지식 포인트 사용 가능",
    LABEL_NO_KNOWLEDGE = "사용 가능한 지식 없음",
    LABEL_VAULT_PROGRESS = "공: %d/3    쐐기: %d/3    월드: %d/3",
    BUTTON_PROFS = "전문",

    TOOLTIP_PROFS_TITLE = "전문 기술",
    TOOLTIP_PROFS_DESC = "집중력과 지식 포인트 보기",
    TITLE_PROFESSIONS = "%s의 전문 기술",
    TITLE_KNOWLEDGE_SOURCES = "지식 출처",
    TAB_TREASURES = "보물",
    LABEL_UNIQUE_TREASURES = "고유 보물",
    LABEL_WEEKLY_TREASURES = "주간 보물",
    LABEL_HOVER_TREASURE_CHECKLIST = "보물 목록을 보려면 마우스를 올리세요",
    TITLE_PROF_TREASURES_FMT = "%s 보물",
    LABEL_PROFESSION = "전문 기술",
    LABEL_UNIQUE_TREASURE_FMT = "%s 고유 보물 %d",
    LABEL_WEEKLY_TREASURE_FMT = "%s 주간 보물 %d",

    -- ==========================================================================
    -- CALENDAR
    -- ==========================================================================
    DAY_SUN = "일",
    DAY_MON = "월",
    DAY_TUE = "화",
    DAY_WED = "수",
    DAY_THU = "목",
    DAY_FRI = "금",
    DAY_SAT = "토",

    TOOLTIP_ACTIVITY_FOR = "%d/%d/%d 활동",
    MSG_NO_WORLD_EVENTS = "이번 달 월드 이벤트 없음",

    -- Filter categories
    FILTER_TIMEWALKING = "시간여행",
    FILTER_DARKMOON = "다크문",
    FILTER_DUNGEONS = "던전",
    FILTER_PVP = "PvP",
    FILTER_BONUS = "보너스",

    -- World events
    WORLD_EVENT_LOVE = "온 세상에 사랑을",
    WORLD_EVENT_LUNAR = "달의 축제",
    WORLD_EVENT_NOBLEGARDEN = "귀족의 정원",
    WORLD_EVENT_CHILDREN = "어린이 주간",
    WORLD_EVENT_MIDSUMMER = "한여름 불꽃축제",
    WORLD_EVENT_BREWFEST = "가을 축제",
    WORLD_EVENT_HALLOWS = "할로윈 축제",
    WORLD_EVENT_WINTERVEIL = "겨울맞이 축제",
    WORLD_EVENT_DEAD = "망자의 날",
    WORLD_EVENT_PIRATES = "해적의 날",
    WORLD_EVENT_STYLE = "스타일의 시험",
    WORLD_EVENT_OUTLAND = "아웃랜드 컵",
    WORLD_EVENT_NORTHREND = "노스렌드 컵",
    WORLD_EVENT_KALIMDOR = "칼림도어 컵",
    WORLD_EVENT_EASTERN = "동부 왕국 컵",
    WORLD_EVENT_WINDS = "신비로운 행운의 바람",

    -- ==========================================================================
    -- CURRENCY WINDOW
    -- ==========================================================================
    TITLE_CURRENCIES = "%s의 화폐",

    -- ==========================================================================
    -- RAID LOCKOUTS WINDOW
    -- ==========================================================================
    TITLE_RAID_FORMAT = "%s의 %s %s - 마나포지 오메가",

    DIFFICULTY_NORMAL = "일반",
    DIFFICULTY_HEROIC = "영웅",
    DIFFICULTY_MYTHIC = "신화",

    MSG_NO_CHAR_DATA = "캐릭터 데이터 없음",
    MSG_NO_PROGRESSION = "%s 진행도 기록 없음",
    MSG_NO_LOCKOUT = "이번 주 %s 귀속 없음",

    LABEL_BOSS = "보스 %d",
    LABEL_PROGRESS_COUNT = "%d/8",

    -- ==========================================================================
    -- WARBAND BANK LEDGER
    -- ==========================================================================
    TITLE_WARBAND_LEDGER = "전투단 은행 장부",
    LABEL_CURRENT_BALANCE = "현재 잔액:",
    LABEL_RECENT_TRANSACTIONS = "최근 거래:",
    MSG_NO_TRANSACTIONS = "(거래 기록 없음)",
    TIP_RELOAD_SAVE = "팁: 캐릭터 변경 전 /reload로 저장",
    ACTION_DEPOSITED = "입금",
    ACTION_WITHDREW = "출금",

    -- ==========================================================================
    -- CHARACTER LEDGER
    -- ==========================================================================
    LABEL_RESETS_IN = "%d일 %d시간 후 초기화",

    TAB_SUMMARY = "요약",
    TAB_HISTORY = "기록",
    TAB_WARBAND = "Warband",
    HEADER_SOURCE = "출처",
    HEADER_INCOME = "수입",
    HEADER_EXPENSE = "지출",

    LABEL_TOTAL = "합계",
    LABEL_NET_PROFIT = "순수익",
    MSG_NO_GOLD_ACTIVITY = "이번 주 골드 활동 없음",
    MSG_NO_TRANSACTIONS_WEEK = "이번 주 거래 없음",

    -- Ledger source categories
    LEDGER_QUESTS = "퀘스트",
    LEDGER_AUCTION = "경매장",
    LEDGER_TRADE = "거래",
    LEDGER_VENDOR = "상인",
    LEDGER_REPAIRS = "수리",
    LEDGER_TRANSMOG = "형상변환",
    LEDGER_FLIGHT = "비행 경로",
    LEDGER_CRAFTING = "제작",
    LEDGER_CACHE = "상자/보물",
    LEDGER_MAIL = "우편",
    LEDGER_LOOT = "전리품",
    LEDGER_WARBAND_BANK = "전투단 은행",
    LEDGER_OTHER = "기타",

    -- ==========================================================================
    -- FRESHNESS INDICATORS
    -- ==========================================================================
    FRESH_NEVER = "없음",
    FRESH_TODAY = "오늘 활동",
    FRESH_1_DAY = "1일 전",
    FRESH_DAYS = "%d일 전",

    -- Time format styles
    TIME_YEARS_DAYS = "%d년 %d일",
    TIME_DAYS_HOURS = "%d일 %d시간",
    TIME_DAYS = "%s 일",
    TIME_HOURS = "%s 시간",

    -- ==========================================================================
    -- TRACKING PROMPT
    -- ==========================================================================
    PROMPT_GREETINGS = "%s님, 안녕하세요!\nLiteVault가 이 캐릭터를 추적하길 원하시나요?",

    -- ==========================================================================
    -- CHAT MESSAGES
    -- ==========================================================================
    MSG_PREFIX = "LiteVault:",
    MSG_WEEKLY_RESET = "주간 초기화 감지! 공격대 귀속이 초기화되었습니다.",
    MSG_ALREADY_TRACKED = "이 캐릭터는 이미 추적 중입니다.",
    MSG_CHAR_ADDED = "%s이(가) 추적에 추가되었습니다.",
    MSG_RAID_RESET_SEASON = "공격대 진행도가 미드나잇 시즌 1로 초기화되었습니다!",
    MSG_CLEARED_PROGRESSION = "%d개 캐릭터의 진행도 데이터가 삭제되었습니다.",
    MSG_WEEKLY_PROFIT_RESET = "%d개 캐릭터의 주간 수익 추적이 초기화되었습니다.",
    MSG_WARBAND_BALANCE = "전투단: %s",
    MSG_WARBAND_BANK_BALANCE = "전투단 은행: %s",
    MSG_WEEKLY_DATA_RESET = "%d개 캐릭터의 주간 데이터가 초기화되었습니다.",
    MSG_RAID_MANUAL_RESET = "공격대 진행도가 수동으로 초기화되었습니다!",
    MSG_CLEARED_DATA = "%d개 캐릭터의 데이터가 삭제되었습니다.",
    MSG_TIMEPLAYED_INITIAL_UNSUPPRESSABLE = "블리자드의 초기 플레이 시간 메시지는 숨길 수 없습니다.",

    -- Slash command help
    HELP_RESET_TITLE = "LiteVault 초기화 명령어",
    HELP_REGION = "지역: %s (초기화 %s)",
    HELP_LAST_SEASON = "마지막 시즌 초기화: %s",
    HELP_RESET_WEEKLY = "/lvreset weekly - 주간 수익 추적 초기화",
    HELP_RESET_SEASON = "/lvreset season - 공격대 진행도 초기화 (새 시즌)",
    HELP_NEVER = "없음",

    -- ==========================================================================
    -- LANGUAGE SELECTION
    -- ==========================================================================
    BUTTON_LANGUAGE = "언어",
    TOOLTIP_LANGUAGE_TITLE = "언어",
    TOOLTIP_LANGUAGE_DESC = "인터페이스 언어 변경",
    TITLE_LANGUAGE_SELECT = "언어 선택",
    LANG_AUTO = "자동 (감지)",
    MSG_LANGUAGE_CHANGED = "언어가 변경되었습니다. 모든 변경사항을 적용하려면 UI를 다시 로드하세요.",

    -- ==========================================================================
    -- OPTIONS
    -- ==========================================================================
    BUTTON_OPTIONS = "옵션",
    TOOLTIP_OPTIONS_TITLE = "옵션",
    TOOLTIP_OPTIONS_DESC = "LiteVault 설정 구성",
    TITLE_OPTIONS = "LiteVault 옵션",
    OPTION_DISABLE_TIMEPLAYED = "플레이 시간 추적 비활성화",
    OPTION_DISABLE_TIMEPLAYED_DESC = "/played 메시지가 채팅에 표시되지 않도록 합니다",
    OPTION_DISABLE_BAG_VIEWING = "가방/은행 뷰어 비활성화",
    OPTION_DISABLE_BAG_VIEWING_DESC = "가방 버튼을 숨기고 저장된 가방, 은행, 전투부대 은행 보기를 비활성화합니다.",
    OPTION_DISABLE_CHARACTER_OVERLAY = "오버레이 시스템 비활성화",
    OPTION_DISABLE_CHARACTER_OVERLAY_DESC = "캐릭터 및 장비 검사 화면에서 LiteVault의 아이템 레벨 및 잠금 오버레이를 숨깁니다.",
    OPTION_DISABLE_MPLUS_TELEPORTS = "M+ 텔레포트 비활성화",
    OPTION_DISABLE_MPLUS_TELEPORTS_DESC = "M+ 텔레포트 배지를 숨기고 LiteVault의 텔레포트 패널을 비활성화합니다.",

    -- Month names
    MONTH_1 = "1월",
    MONTH_2 = "2월",
    MONTH_3 = "3월",
    MONTH_4 = "4월",
    MONTH_5 = "5월",
    MONTH_6 = "6월",
    MONTH_7 = "7월",
    MONTH_8 = "8월",
    MONTH_9 = "9월",
    MONTH_10 = "10월",
    MONTH_11 = "11월",
    MONTH_12 = "12월",

    -- ==========================================================================
    -- CURRENCIES
    -- ==========================================================================
    ["복원된 금고 열쇠"] = "복원된 금고 열쇠",
    ["지하 주화"] = "지하 주화",
    ["케즈"] = "케즈",
    ["공명 수정"] = "공명 수정",
    ["황혼의 칼날 휘장"] = "황혼의 칼날 휘장",

    ["둔둔의 파편"] = "둔둔의 파편",
    ["용맹석"] = "용맹석",
    ["낡은 에테리얼 문장"] = "낡은 에테리얼 문장",
    ["조각된 에테리얼 문장"] = "조각된 에테리얼 문장",
    ["룬이 새겨진 에테리얼 문장"] = "룬이 새겨진 에테리얼 문장",
    ["금박 에테리얼 문장"] = "금박 에테리얼 문장",
    ["모험가 문장"] = "모험가 문장",
    ["숙련자 문장"] = "숙련자 문장",
    ["용사 문장"] = "용사 문장",
    ["영웅 문장"] = "영웅 문장",
    ["여명빛 마나유동"] = "여명빛 마나유동",

    -- ==========================================================================
    -- WEEKLY QUESTS
    -- ==========================================================================
    ["세계영혼의 부름"] = "세계영혼의 부름",
    ["극단 공연"] = "극단 공연",
    ["기계 깨우기"] = "기계 깨우기",
    ["역사 탐구"] = "역사 탐구",
    ["세계적 연구"] = "세계적 연구",
    ["급등 충동"] = "급등 충동",
    ["빛 전파"] = "빛 전파",
    -- Midnight Weekly Quests
    ["커뮤니티 참여"] = "커뮤니티 참여",
    WARNING_ACCOUNT_BOUND = "계정 귀속",
    ["자정: 먹잇감"] = "자정: 먹잇감",

    ["살테릴의 연회"] = "살테릴의 연회",
    ["풍요 이벤트"] = "풍요 이벤트",
    ["하라니르의 전설"] = "하라니르의 전설",
    ["해체된 어둠"] = "해체된 어둠",
    ["공허 수확"] = "공허 수확",
    ["한밤중: 살테릴의 연회"] = "한밤중: 살테릴의 연회",
    ["룬석 강화: 혈기사단"] = "룬석 강화: 혈기사단",
    ["룬석 강화: 골목의 그림자"] = "룬석 강화: 골목의 그림자",
    ["룬석 강화: 마법학자단"] = "룬석 강화: 마법학자단",
    ["룬석 강화: 원정순찰대"] = "룬석 강화: 원정순찰대",
    ["걸음에 탄력을 더해라"] = "걸음에 탄력을 더해라",
    ["가벼운 간식"] = "가벼운 간식",
    ["무법을 줄여라"] = "무법을 줄여라",
    ["미묘한 게임"] = "미묘한 게임",
    ["구애의 성공"] = "구애의 성공",

    -- ==========================================================================
    -- PROFESSION NAMES
    -- ==========================================================================
    ["연금술"] = "연금술",
    ["대장기술"] = "대장기술",
    ["마법부여"] = "마법부여",
    ["기계공학"] = "기계공학",
    ["주문각인"] = "주문각인",
    ["보석세공"] = "보석세공",
    ["가죽세공"] = "가죽세공",
    ["재봉술"] = "재봉술",
    ["약초채집"] = "약초채집",
    ["채광"] = "채광",
    ["무두질"] = "무두질",

    ["고뇌의 잔재"] = "고뇌의 잔재",
    ["신화 문장"] = "신화 문장",
    ["넘쳐나는 비전력"] = "넘쳐나는 비전력",
    ["공허빛 이회토"] = "공허빛 이회토",
    ["주사위를 던지기"] = "주사위를 던지기",
    ["보충이 필요해"] = "보충이 필요해",
    ["사랑스러운 깃털장식"] = "사랑스러운 깃털장식",
    ["메아리의 가마솥"] = "메아리의 가마솥",
    ["메아리 없는 불꽃"] = "메아리 없는 불꽃",
    ["숨겨진 은신처"] = "숨겨진 은신처",
    ["승리의 스톰아리온 정상 보관함"] = "승리의 스톰아리온 정상 보관함",
    ["넘쳐흐르는 풍요의 주머니"] = "넘쳐흐르는 풍요의 주머니",
    ["열성적인 학습자의 보급품 꾸러미"] = "열성적인 학습자의 보급품 꾸러미",
    ["남는 파티 선물 자루"] = "남는 파티 선물 자루",
    OPTION_ENABLE_24HR_CLOCK = "24시간 시계 사용",
    OPTION_ENABLE_24HR_CLOCK_DESC = "24시간제와 12시간제 사이를 전환합니다",
    TELEPORT_PANEL_TITLE = "M+ 지문 이동",
    TELEPORT_CAST_BTN = "이동",
    TELEPORT_ERR_COMBAT = "전투 중에는 이동할 수 없습니다.",
    BUTTON_VAULT = "금고",
    BUTTON_ACTIONS = "액션",
    BUTTON_RAIDS = "공격대",
    BUTTON_FAVORITE = "즐겨찾기",
    BUTTON_UNFAVORITE = "즐겨찾기 해제",
    BUTTON_IGNORE = "무시",
    BUTTON_RESTORE = "복원",
    BUTTON_DELETE = "삭제",
    TOOLTIP_ACTIONS_TITLE = "캐릭터 액션",
    TOOLTIP_ACTIONS_DESC = "액션 메뉴 열기",
    BUTTON_INSTANCES = "인스턴스",
    TOOLTIP_INSTANCE_TRACKER_TITLE = "인스턴스 추적기",
    TOOLTIP_INSTANCE_TRACKER_DESC = "던전과 공격대 기록 추적",
    LABEL_RENOWN_PROGRESS = "명성 %d (%d/%d)",

    LABEL_RENOWN = "명성",
    LABEL_RENOWN_LEVEL = "레벨",
    LABEL_RENOWN_UNAVAILABLE = "명성 정보 없음",
    MSG_NO_WEEKLY_QUESTS_CONFIGURED = "아직 설정된 세력 주간 퀘스트가 없습니다.",
    BUTTON_KNOWLEDGE = "지식",
    WORLD_EVENT_SALTHERIL = "살테릴의 사로연",
    WORLD_EVENT_ABUNDANCE = "풍요",
    WORLD_EVENT_HARANIR = "하라니르 전설",
    WORLD_EVENT_STORMARION = "스톰마리온 공습",
    TITLE_KNOWLEDGE_TRACKER = "지식 추적기",
    TOOLTIP_KNOWLEDGE_DESC = "소모, 미사용, 최대 지식 점수 보기",
    LABEL_SPENT = "사용함",
    LABEL_UNSPENT = "미사용",
    LABEL_MAX = "최대",
    LABEL_EARNED = "획득",
    LABEL_TREATISE = "논문",
    LABEL_ARTISAN_QUEST = "장인",
    LABEL_CATCHUP = "보충",
    LABEL_WEEKLY = "주간",
    LABEL_UNLOCKED = "해금됨",
    LABEL_UNLOCK_REQUIREMENTS = "해금 조건",
    LABEL_SOURCE_NOTE = "주간 획득처 및 보충 현황",
    LABEL_TREASURE_CLICK_HINT = "고유 보물을 클릭하면 경로 표시를 설정합니다",
    LABEL_ZONE = "지역",
    LABEL_COORDINATES = "좌표",
    TOOLTIP_TREASURE_SET_WAYPOINT = "클릭하여 TomTom 경로 표시 설정",
    TOOLTIP_TREASURE_SET_BLIZZ_WAYPOINT = "클릭하여 지도 경로 표시 설정",
    TOOLTIP_TREASURE_NO_FIXED_LOCATION = "이 보물은 고정 위치가 없습니다",
    MSG_TREASURE_NO_WAYPOINT = "이 보물은 고정 경로 표시가 없습니다.",
    MSG_TOMTOM_NOT_DETECTED = "TomTom이 감지되지 않았습니다.",
    MSG_TREASURE_WAYPOINT_SET = "경로 표시 설정: %s (%.1f, %.1f)",
    MSG_TREASURE_BLIZZ_WAYPOINT_SET = "지도 경로 표시 설정: %s (%.1f, %.1f)",
    STATUS_DONE_WORD = "완료",
    STATUS_MISSING_WORD = "부족",
    LABEL_MIDNIGHT_SEASON_1 = "미드나이트 시즌 1",
    TAB_SOURCES = "출처",
    TIME_TODAY = "오늘 %H:%M",
    MSG_CAP_WARNING = "인스턴스 제한 경고! 이 시간에 %d/10 인스턴스를 사용했습니다.",
    MSG_CAP_SLOT_OPEN = "인스턴스 자리가 이제 비었습니다! (%d/10 사용 중)",
    MSG_RELOAD_TIMEPLAYED = "플레이 시간 메시지 숨김을 적용하려면 UI를 새로고침하세요.",
    MSG_RAID_DEBUG_ON = "LiteVault 공격대 디버그: 켜짐",
    MSG_RAID_DEBUG_OFF = "LiteVault 공격대 디버그: 꺼짐",
    MSG_RAID_DEBUG_TIP = "디버그 출력을 끄려면 /lvraiddbg를 다시 사용하세요.",
    MSG_TRACKED_KILL = "%s 처치 기록: %s (%s)",
    LOCALE_DEBUG_ON = "로케일 디버그 모드 켜짐 - 문자열 키를 표시합니다",
    LOCALE_DEBUG_OFF = "로케일 디버그 모드 꺼짐 - 번역문을 표시합니다",
    LOCALE_BORDERS_ON = "경계 모드 켜짐 - 텍스트 경계를 표시합니다",
    LOCALE_BORDERS_HINT = "초록 = 맞음, 빨강 = 넘을 수 있음",
    LOCALE_BORDERS_OFF = "경계 모드 꺼짐",
    LOCALE_FORCED = "로케일이 %s로 강제되었습니다",
    LOCALE_RESET_TIP = "자동 감지로 돌아가려면 /lvlocale reset을 사용하세요.",
    LOCALE_INVALID = "잘못된 로케일입니다. 유효한 옵션:",
    LOCALE_RESET = "로케일이 자동 감지로 초기화되었습니다: %s",
    LOCALE_TITLE = "LiteVault 로케일",
    LOCALE_DETECTED = "감지된 로케일: %s",
    LOCALE_FORCED_TO = "강제된 로케일: %s",
    LOCALE_DEBUG_KEYS = "디버그 키:",
    LOCALE_DEBUG_BORDERS = "디버그 경계:",
    LOCALE_ON = "켜짐",
    LOCALE_OFF = "꺼짐",
    LOCALE_COMMANDS = "명령어:",
    LOCALE_CMD_DEBUG = "/lvlocale debug - 키 표시 모드 전환",
    LOCALE_CMD_BORDERS = "/lvlocale borders - 텍스트 경계 표시 전환",
    LOCALE_CMD_LANG = "/lvlocale lang XX - 로케일 강제 설정 (예: deDE, zhCN)",
    LOCALE_CMD_RESET = "/lvlocale reset - 자동 감지로 초기화",
    TITLE_INSTANCE_TRACKER = "인스턴스 추적기",
    SECTION_INSTANCE_CAP = "인스턴스 제한 (시간당 10회)",
    LABEL_CAP_CURRENT = "현재: %d/10",
    LABEL_CAP_STATUS = "상태: %s",
    LABEL_NEXT_SLOT = "다음 자리까지: %s",
    STATUS_SAFE = "안전",
    STATUS_WARNING = "경고",
    STATUS_LOCKED = "잠김",
    SECTION_CURRENT_RUN = "현재 진행",
    LABEL_DURATION = "진행 시간: %s",
    LABEL_NOT_IN_INSTANCE = "인스턴스 안에 있지 않음",
    SECTION_PERFORMANCE = "오늘의 기록",
    LABEL_DUNGEONS_TODAY = "던전: %d",
    LABEL_RAIDS_TODAY = "공격대: %d",
    LABEL_AVG_TIME = "평균: %s",
    SECTION_LEGACY_RAIDS = "이번 주 레거시 공격대",
    LABEL_LEGACY_RUNS = "횟수: %d",
    LABEL_GOLD_EARNED = "골드: %s",
    SECTION_RECENT_RUNS = "최근 진행",
    LABEL_NO_RECENT_RUNS = "최근 진행기록 없음",
    SECTION_MPLUS = "신화+",
    LABEL_MPLUS_CURRENT_KEY = "현재 열쇠:",
    LABEL_RUNS_TODAY = "오늘 진행: %d",
    LABEL_RUNS_THIS_WEEK = "이번 주 진행: %d",
    SECTION_RECENT_MPLUS_RUNS = "최근 신화+ 진행",
    LABEL_NO_RECENT_MPLUS_RUNS = "최근 신화+ 진행기록 없음",
    LABEL_QUEST = "퀘스트",
    BUTTON_DASHBOARD = "대시보드",
    BUTTON_PROFIT = "수익",
    LABEL_PROFIT_GOALS = "전투부대 목표",
    LABEL_WEEKLY_GOAL = "주간 목표",
    LABEL_MONTHLY_GOAL = "월간 목표",
    BUTTON_EDIT = "편집",
    TEXT_TOP_WEEKLY_EARNERS_SUBTITLE = "이번 초기화 기간의 최고 순수익입니다.",
    TEXT_TOP_MONTHLY_EARNERS_SUBTITLE = "현재 달의 최고 순수익입니다.",
    BUTTON_ACHIEVEMENTS = "업적",
    TITLE_ACHIEVEMENTS = "업적",
    DESC_ACHIEVEMENTS = "자세한 진행 상황을 보려면 업적 추적기를 선택하세요.",
    BUTTON_MIDNIGHT_GLYPH_HUNTER = "미드나이트 글리프 사냥꾼",
    TITLE_MIDNIGHT_GLYPH_HUNTER = "미드나이트 글리프 사냥꾼",
    LABEL_REWARD = "보상",
    DESC_GLYPH_REWARD = "미드나이트 글리프 사냥꾼을 완료하여 이 탈것을 획득하세요.",
    MSG_NO_ACHIEVEMENT_DATA = "사용 가능한 업적 추적 데이터가 없습니다.",
    LABEL_CRITERIA = "조건",
    LABEL_GLYPHS_COLLECTED = "수집한 글리프",
    LABEL_ACHIEVEMENT = "업적",
    BUTTON_BAGS = "가방",
    BUTTON_BANK = "은행",
    BUTTON_WARBAND_BANK = "전투부대 은행",
    BAGS_EMPTY_STATE = "이 캐릭터의 저장된 가방 아이템이 없습니다.",
    BANK_EMPTY_STATE = "이 캐릭터의 저장된 은행 아이템이 없습니다.",
    WARBANK_EMPTY_STATE = "저장된 전투부대 은행 아이템이 없습니다.",
    LABEL_BAG_SLOTS = "슬롯: %d / %d 사용 중",
    LABEL_SCANNED = "스캔됨",
    ["금고 열쇠 조각"] = "금고 열쇠 조각",
    BUTTON_WEEKLY_PLANNER = "플래너",
    TITLE_WEEKLY_PLANNER = "주간 플래너",
    TITLE_CHARACTER_WEEKLY_PLANNER_FMT = "%s's %s",
    TOOLTIP_WEEKLY_PLANNER_TITLE = "주간 플래너",
    TOOLTIP_WEEKLY_PLANNER_DESC = "캐릭터별로 수정 가능한 주간 체크리스트입니다. 완료한 항목은 매주 초기화됩니다.",
    TOOLTIP_VAULT_STATUS = "금고 상태를 확인합니다.",
    TITLE_GREAT_VAULT = "위대한 금고",
    TITLE_CHARACTER_GREAT_VAULT_FMT = "%s's %s",
    LABEL_VAULT_ROW_RAID = "공격대",
    LABEL_VAULT_ROW_DUNGEONS = "던전",
    LABEL_VAULT_ROW_WORLD = "세계",
    LABEL_VAULT_SLOTS_UNLOCKED = "%d/9 슬롯 해금됨",
    LABEL_VAULT_OVERALL_PROGRESS = "Overall progress: %d/%d",
    MSG_VAULT_NO_THRESHOLD = "아직 저장된 조건 데이터가 없습니다.",
    MSG_VAULT_LIVE_ACTIVE = "현재 캐릭터의 위대한 금고 실시간 진행 상황입니다.",
    MSG_VAULT_LIVE = "위대한 금고 실시간 진행 상황입니다.",
    MSG_VAULT_SAVED = "이 캐릭터의 마지막 접속 시 저장된 위대한 금고 스냅샷입니다.",
    SECTION_DELVE_CURRENCY = "구렁 화폐",
    SECTION_UPGRADE_CRESTS = "업그레이드 문장",
    LABEL_CAP_SHORT = "상한 %s",
    ["한밤의 보물"] = "한밤의 보물",
    ["한밤의 보물 업적 4개와 해당 보상을 추적합니다."] = "한밤의 보물 업적 4개와 해당 보상을 추적합니다.",
    ["한밤의 구렁 탐험가의 영예"] = "한밤의 구렁 탐험가의 영예",
    ["이 탈것을 얻으려면 '한밤의 구렁 탐험가의 영예'를 완료하세요."] = "이 탈것을 얻으려면 '한밤의 구렁 탐험가의 영예'를 완료하세요.",
    ["한밤의 희귀 업적 4개와 지역 희귀 보상을 추적합니다."] = "한밤의 희귀 업적 4개와 지역 희귀 보상을 추적합니다.",
    ["한밤의 희귀 업적 4개를 추적합니다."] = "한밤의 희귀 업적 4개를 추적합니다.",
    ["이 지역의 망원경 5개를 완료하세요."] = "이 지역의 망원경 5개를 완료하세요.",
    ["이 메타 업적을 완료하려면 한밤의 구렁 탐험가 지원 업적 4개를 모두 완료하세요."] = "이 메타 업적을 완료하려면 한밤의 구렁 탐험가 지원 업적 4개를 모두 완료하세요.",
    ["진홍빛 용매"] = "진홍빛 용매",
    ["기간토 마니스"] = "기간토 마니스",
    ["업적"] = "업적",
    ["보상"] = "보상",
    ["세부 정보"] = "세부 정보",
    ["조건"] = "조건",
    ["정보"] = "정보",
    ["공유 전리품"] = "공유 전리품",
    ["그룹"] = "그룹",
    ["그룹으로 돌아가기"] = "그룹으로 돌아가기",
    ["알 수 없음"] = "알 수 없음",
    ["아이템"] = "아이템",
    ["표시된 업적 보상이 없습니다."] = "표시된 업적 보상이 없습니다.",
    ["클릭하여 웨이포인트를 설정합니다."] = "클릭하여 웨이포인트를 설정합니다.",
    ["클릭하여 이 추적기를 엽니다."] = "클릭하여 이 추적기를 엽니다.",
    ["추적기가 아직 추가되지 않았습니다."] = "추적기가 아직 추가되지 않았습니다.",
    ["좌표 대기 중."] = "좌표 대기 중.",
    ["이곳에서 동굴 진행을 완료해야 업적이 인정됩니다."] = "이곳에서 동굴 진행을 완료해야 업적이 인정됩니다.",
    ["방어 이벤트를 시작하려면 룬석에 잠재된 비전을 충전하세요."] = "방어 이벤트를 시작하려면 룬석에 잠재된 비전을 충전하세요.",
    ["업적 인정 출처:"] = "업적 인정 출처:",
    ["스톰아리온 공습"] = "스톰아리온 공습",
    ["영원의 그림"] = "영원의 그림",
    ["알려진 Ever-Painting 캔버스를 추적합니다. x/y 표시됨."] = "알려진 Ever-Painting 캔버스를 추적합니다. x/y 표시됨.",
    ["Ever-Painting용 추적 항목은 아직 추가되지 않았습니다."] = "Ever-Painting용 추적 항목은 아직 추가되지 않았습니다.",
    ["룬석 질주"] = "룬석 질주",
    ["알려진 Runestone Rush 항목을 추적합니다. x/y 표시됨."] = "알려진 Runestone Rush 항목을 추적합니다. x/y 표시됨.",
    ["Runestone Rush용 추적 항목은 아직 추가되지 않았습니다."] = "Runestone Rush용 추적 항목은 아직 추가되지 않았습니다.",
    ["파티는 계속되어야 한다"] = "파티는 계속되어야 한다",
    ["파티는 계속되어야 한다 업적의 4개 진영 초대를 추적합니다. x/y 표시됨."] = "파티는 계속되어야 한다 업적의 4개 진영 초대를 추적합니다. x/y 표시됨.",
    ["파티는 계속되어야 한다용 추적 항목은 아직 추가되지 않았습니다."] = "파티는 계속되어야 한다용 추적 항목은 아직 추가되지 않았습니다.",
    ["탐험 추적기"] = "탐험 추적기",
    ["Explore Eversong Woods 진행 상황을 추적합니다. x/y 표시됨."] = "Explore Eversong Woods 진행 상황을 추적합니다. x/y 표시됨.",
    ["Explore Eversong Woods용 추적 항목은 아직 추가되지 않았습니다."] = "Explore Eversong Woods용 추적 항목은 아직 추가되지 않았습니다.",
    ["Explore Voidstorm 진행 상황을 추적합니다. x/y 표시됨."] = "Explore Voidstorm 진행 상황을 추적합니다. x/y 표시됨.",
    ["Explore Voidstorm용 추적 항목은 아직 추가되지 않았습니다."] = "Explore Voidstorm용 추적 항목은 아직 추가되지 않았습니다.",
    ["Explore Zul'Aman 진행 상황을 추적합니다. x/y 표시됨."] = "Explore Zul'Aman 진행 상황을 추적합니다. x/y 표시됨.",
    ["Explore Zul'Aman용 추적 항목은 아직 추가되지 않았습니다."] = "Explore Zul'Aman용 추적 항목은 아직 추가되지 않았습니다.",
    ["Explore Harandar 진행 상황을 추적합니다. x/y 표시됨."] = "Explore Harandar 진행 상황을 추적합니다. x/y 표시됨.",
    ["Explore Harandar용 추적 항목은 아직 추가되지 않았습니다."] = "Explore Harandar용 추적 항목은 아직 추가되지 않았습니다.",
    ["추격의 스릴"] = "추격의 스릴",
    ["Voidstorm에서 굶주린 존재의 손아귀를 최소 60초 동안 피하세요."] = "Voidstorm에서 굶주린 존재의 손아귀를 최소 60초 동안 피하세요.",
    ["이 업적은 LiteVault에서 좌표 추적이 필요하지 않습니다. Voidstorm에서 굶주린 존재 이벤트를 최소 60초 동안 버티세요."] = "이 업적은 LiteVault에서 좌표 추적이 필요하지 않습니다. Voidstorm에서 굶주린 존재 이벤트를 최소 60초 동안 버티세요.",
    ["추격의 스릴용 추적 항목은 아직 추가되지 않았습니다."] = "추격의 스릴용 추적 항목은 아직 추가되지 않았습니다.",
    ["망설일 시간은 없다"] = "망설일 시간은 없다",
    ["포식자의 추적 중첩 15 이상 상태로 Harandar 세계 퀘스트 '발톱 단속'을 완료하세요."] = "포식자의 추적 중첩 15 이상 상태로 Harandar 세계 퀘스트 '발톱 단속'을 완료하세요.",
    ["이 업적은 LiteVault에서 좌표 추적이 필요하지 않습니다. 포식자의 추적 중첩 15 이상 상태로 Harandar 세계 퀘스트 '발톱 단속'을 완료하세요."] = "이 업적은 LiteVault에서 좌표 추적이 필요하지 않습니다. 포식자의 추적 중첩 15 이상 상태로 Harandar 세계 퀘스트 '발톱 단속'을 완료하세요.",
    ["망설일 시간은 없다용 추적 항목은 아직 추가되지 않았습니다."] = "망설일 시간은 없다용 추적 항목은 아직 추가되지 않았습니다.",
    ["요람에서 무덤까지"] = "요람에서 무덤까지",
    ["Harandar 상공 높이 떠 있는 The Cradle까지 날아가 보세요."] = "Harandar 상공 높이 떠 있는 The Cradle까지 날아가 보세요.",
    ["이 업적을 완료하려면 Harandar 상공 높이 떠 있는 The Cradle로 날아가세요."] = "이 업적을 완료하려면 Harandar 상공 높이 떠 있는 The Cradle로 날아가세요.",
    ["하라니르의 연대기 작가"] = "하라니르의 연대기 작가",
    ["이 일지는 주간 퀘스트 '하라니르의 전설' 진행 중에만 얻을 수 있습니다. 환영 속에서는 미니맵의 돋보기 아이콘을 찾으세요."] = "이 일지는 주간 퀘스트 '하라니르의 전설' 진행 중에만 얻을 수 있습니다. 환영 속에서는 미니맵의 돋보기 아이콘을 찾으세요.",
    ["아래에 나열된 하라니르 일지 항목을 회수하세요."] = "아래에 나열된 하라니르 일지 항목을 회수하세요.",
    ["아래에 나열된 하라니르 일지 항목을 회수하세요. x/y 표시됨."] = "아래에 나열된 하라니르 일지 항목을 회수하세요. x/y 표시됨.",
    ["전설은 죽지 않는다"] = "전설은 죽지 않는다",
    ["이것은 주간 퀘스트 '하라니르의 전설'과 연결되어 있습니다. 아직 진행도가 없다면 완료까지 약 7주가 걸릴 것으로 예상됩니다."] = "이것은 주간 퀘스트 '하라니르의 전설'과 연결되어 있습니다. 아직 진행도가 없다면 완료까지 약 7주가 걸릴 것으로 예상됩니다.",
    ["아래에 나열된 각 하라니르 전설 위치를 방어하세요."] = "아래에 나열된 각 하라니르 전설 위치를 방어하세요.",
    ["아래에 나열된 각 하라니르 전설 위치를 보호하세요. x/y 표시됨."] = "아래에 나열된 각 하라니르 전설 위치를 보호하세요. x/y 표시됨.",
    ["먼지를 털어내라"] = "먼지를 털어내라",
    ["Harandar에 숨어 있는 모든 빛나는 나방을 찾으세요. x/y 찾음."] = "Harandar에 숨어 있는 모든 빛나는 나방을 찾으세요. x/y 찾음.",
    ["좌표 그룹은 아직 추가되지 않았습니다."] = "좌표 그룹은 아직 추가되지 않았습니다.",
    ["이 추적기는 나방 경로를 관리하기 쉽도록 40개 좌표씩 3개 그룹으로 나뉘어 있습니다."] = "이 추적기는 나방 경로를 관리하기 쉽도록 40개 좌표씩 3개 그룹으로 나뉘어 있습니다.",
    ["나방 1-40은 Hara'ti 평판 1에서 나타나며, 추적은 평판 2에서 가능합니다."] = "나방 1-40은 Hara'ti 평판 1에서 나타나며, 추적은 평판 2에서 가능합니다.",
    ["나방 41-80은 Hara'ti 평판 4에서 나타나며, 추적은 평판 6에서 가능합니다."] = "나방 41-80은 Hara'ti 평판 4에서 나타나며, 추적은 평판 6에서 가능합니다.",
    ["나방 81-120은 Hara'ti 평판 9에서 나타나며, 추적은 평판 11에서 가능합니다."] = "나방 81-120은 Hara'ti 평판 9에서 나타나며, 추적은 평판 11에서 가능합니다.",
    ["LiteVault 경로는 이미 Hara'ti 평판 11이 해금되어 있다고 가정합니다."] = "LiteVault 경로는 이미 Hara'ti 평판 11이 해금되어 있다고 가정합니다.",
    ["%s에는 나방 좌표 %d개가 포함되어 있습니다. 웨이포인트를 놓으려면 나방을 클릭하세요."] = "%s에는 나방 좌표 %d개가 포함되어 있습니다. 웨이포인트를 놓으려면 나방을 클릭하세요.",
    ["그룹 1"] = "그룹 1",
    ["그룹 2"] = "그룹 2",
    ["그룹 3"] = "그룹 3",
    ["나방"] = "나방",
    ["특이한 문제"] = "특이한 문제",
    ["Stormarion Assault의 세 물결을 모두 완료하세요. x/y 표시됨."] = "Stormarion Assault의 세 물결을 모두 완료하세요. x/y 표시됨.",
    ["특이한 문제용 추적 항목은 아직 추가되지 않았습니다."] = "특이한 문제용 추적 항목은 아직 추가되지 않았습니다.",
    ["풍요: 번영의 충만함!"] = "풍요: 번영의 충만함!",
    ["각 위치에서 풍성한 수확 동굴 진행을 완료하세요. x/y 표시됨."] = "각 위치에서 풍성한 수확 동굴 진행을 완료하세요. x/y 표시됨.",
    ["인정을 받으려면 각 위치에서 풍성한 수확 동굴 진행을 완료해야 합니다. 동굴을 방문하는 것만으로는 충분하지 않습니다."] = "인정을 받으려면 각 위치에서 풍성한 수확 동굴 진행을 완료해야 합니다. 동굴을 방문하는 것만으로는 충분하지 않습니다.",
    ["풍요: 번영의 충만함!용 추적 항목은 아직 추가되지 않았습니다."] = "풍요: 번영의 충만함!용 추적 항목은 아직 추가되지 않았습니다.",
    ["축복의 제단"] = "축복의 제단",
    ["인정을 받으려면 나열된 각 축복 효과를 발동시키세요."] = "인정을 받으려면 나열된 각 축복 효과를 발동시키세요.",
    ["나열된 각 축복 효과를 발동시키세요. x/y 표시됨."] = "나열된 각 축복 효과를 발동시키세요. x/y 표시됨.",
    ["메타 업적 요약"] = "메타 업적 요약",
    ["아래에 나열된 Eversong Woods 업적을 완료하세요. x/y 완료."] = "아래에 나열된 Eversong Woods 업적을 완료하세요. x/y 완료.",
    ["아래에 나열된 Voidstorm 업적을 모두 완료하세요. x/y 완료."] = "아래에 나열된 Voidstorm 업적을 모두 완료하세요. x/y 완료.",
    ["아래에 나열된 Zul'Aman 업적을 모두 완료하세요. x/y 완료."] = "아래에 나열된 Zul'Aman 업적을 모두 완료하세요. x/y 완료.",
    ["아래 업적을 완료하여 Hara'ti를 도우세요. x/y 완료."] = "아래 업적을 완료하여 Hara'ti를 도우세요. x/y 완료.",
    ["아래 업적을 완료하여 Xal'atath에 맞설 병력을 규합하세요. x/y 완료."] = "아래 업적을 완료하여 Xal'atath에 맞설 병력을 규합하세요. x/y 완료.",
    ["Making an Amani Out of You용 추적 항목은 아직 추가되지 않았습니다."] = "Making an Amani Out of You용 추적 항목은 아직 추가되지 않았습니다.",
    ["That's Aln, Folks!용 추적 항목은 아직 추가되지 않았습니다."] = "That's Aln, Folks!용 추적 항목은 아직 추가되지 않았습니다.",
    ["Forever Song용 추적 항목은 아직 추가되지 않았습니다."] = "Forever Song용 추적 항목은 아직 추가되지 않았습니다.",
    ["Yelling into the Voidstorm용 추적 항목은 아직 추가되지 않았습니다."] = "Yelling into the Voidstorm용 추적 항목은 아직 추가되지 않았습니다.",
    ["Light Up the Night용 추적 항목은 아직 추가되지 않았습니다."] = "Light Up the Night용 추적 항목은 아직 추가되지 않았습니다.",
    ["탈것: 찬란한 꽃잎날개"] = "탈것: 찬란한 꽃잎날개",
    ["주택 장식: 온오히아의 부름"] = "주택 장식: 온오히아의 부름",
    ["칭호: \"먼지군주\""] = "칭호: \"먼지군주\"",
    ["칭호: \"하라니르의 연대기 작가\""] = "칭호: \"하라니르의 연대기 작가\"",
    ["집 보상 라벨:"] = "집 보상 라벨:",
}

L["공격대 재동기화를 사용할 수 없습니다."] = "공격대 재동기화를 사용할 수 없습니다."
L["플레이 시간 메시지가 숨겨집니다."] = "플레이 시간 메시지가 숨겨집니다."
L["플레이 시간 메시지가 복원되었습니다."] = "플레이 시간 메시지가 복원되었습니다."
L["%d분 %02d초"] = "%d분 %02d초"
L["문장:"] = "문장:"
L["탈것 획득"] = "탈것 획득"
L["(수집함)"] = "(수집함)"
L["(미수집)"] = "(미수집)"
L["탈것: %d/%d"] = "탈것: %d/%d"
L["공허의 첨탑"] = "공허의 첨탑"
L["꿈의 균열"] = "꿈의 균열"
L["쿠엘다나스 진군"] = "쿠엘다나스 진군"
L["공격대 진행도"] = "공격대 진행도"
L["여군주 리아드린 주간"] = "여군주 리아드린 주간"
L["변경 로그"] = "변경 로그"
L["뒤로"] = "뒤로"
L["전투부대 은행"] = "전투부대 은행"
L["논문"] = "논문"
L["장인"] = "장인"
L["따라잡기"] = "따라잡기"
L["LiteVault 업데이트 요약"] = "LiteVault 업데이트 요약"
L["화폐 아이콘, 공격대 아이콘, 전문 기술 바, 위대한 금고 추적기를 포함한 여러 핵심 UI 요소를 새로 다듬었습니다."] = "화폐 아이콘, 공격대 아이콘, 전문 기술 바, 위대한 금고 추적기를 포함한 여러 핵심 UI 요소를 새로 다듬었습니다."
L["금고 아이템 레벨 표시를 블리자드 기본 위대한 금고 표시 방식에 더 가깝게 맞추도록 업데이트했습니다."] = "금고 아이템 레벨 표시를 블리자드 기본 위대한 금고 표시 방식에 더 가깝게 맞추도록 업데이트했습니다."
L["지원되는 여러 언어에 대규모 신규 번역을 추가했습니다."] = "지원되는 여러 언어에 대규모 신규 번역을 추가했습니다."
L["애드온 전반에서 현지화 텍스트의 표시 및 새로고침 동작을 개선했습니다."] = "애드온 전반에서 현지화 텍스트의 표시 및 새로고침 동작을 개선했습니다."
L["버튼, 가방 탭, 주간 텍스트 및 기타 UI 라벨에 대한 현지화 지원을 업데이트했습니다."] = "버튼, 가방 탭, 주간 텍스트 및 기타 UI 라벨에 대한 현지화 지원을 업데이트했습니다."
L["현지화 관련 레이아웃 문제를 여러 건 수정했습니다."] = "현지화 관련 레이아웃 문제를 여러 건 수정했습니다."
L["현지화 관련 충돌 문제를 여러 건 수정했습니다."] = "현지화 관련 충돌 문제를 여러 건 수정했습니다."

L["상세 내역"] = "상세 내역"
L["전투부대 내역"] = "전투부대 내역"
L["의식 장소"] = "의식 장소"
L["최대 영예"] = "최대 영예"
L["불멸의 동맹"] = "불멸의 동맹"
L["보상: %s"] = "보상: %s"
L["보상 데이터 불러오는 중..."] = "보상 데이터 불러오는 중..."
L["클릭하여 이 진영으로 전환합니다."] = "클릭하여 이 진영으로 전환합니다."
L["획득"] = "획득"
L["주요 출처"] = "주요 출처"
L["최고 수입 출처"] = "최고 수입 출처"
L["최고 지출 출처"] = "최고 지출 출처"
L["전투부대의 주간 수입 및 지출 출처 구성을 표시합니다."] = "전투부대의 주간 수입 및 지출 출처 구성을 표시합니다."
L["이번 주 전투부대가 가장 많은 골드를 획득한 출처입니다."] = "이번 주 전투부대가 가장 많은 골드를 획득한 출처입니다."
L["이번 주 전투부대가 가장 많은 골드를 사용한 출처입니다."] = "이번 주 전투부대가 가장 많은 골드를 사용한 출처입니다."
L["아직 기록된 수입이 없습니다."] = "아직 기록된 수입이 없습니다."
L["아직 기록된 지출이 없습니다."] = "아직 기록된 지출이 없습니다."
L["활성화된 골드 전역 퀘스트를 찾을 수 없습니다."] = "활성화된 골드 전역 퀘스트를 찾을 수 없습니다."
L["전역 퀘스트"] = "전역 퀘스트"
L["강화"] = "강화"
L["지도 룬석 표시 비활성화"] = "지도 룬석 표시 비활성화"
L["영원노래 숲 지도에서 LiteVault의 룬석 표시를 숨깁니다."] = "영원노래 숲 지도에서 LiteVault의 룬석 표시를 숨깁니다."
L["달력 수익 강조 표시 활성화"] = "달력 수익 강조 표시 활성화"
L["달력에 수익 날짜를 녹색 및 빨간색으로 강조 표시합니다."] = "달력에 수익 날짜를 녹색 및 빨간색으로 강조 표시합니다."
L["다음 주: %s"] = "다음 주: %s"
L["월간 수익"] = "월간 수익"
L["주간 최고 수익 캐릭터"] = "주간 최고 수익 캐릭터"
L["월간 최고 수익 캐릭터"] = "월간 최고 수익 캐릭터"

L["BUTTON_CANCEL"] = "Cancel"
L["BUTTON_EDIT_MONTHLY_GOAL"] = "Edit Monthly Goal"
L["BUTTON_EDIT_WEEKLY_GOAL"] = "Edit Weekly Goal"
L["BUTTON_EXPORT_CSV"] = "Export CSV"
L["BUTTON_MONTHLY_PROFIT_EXPORT"] = "Monthly Profit CSV"
L["BUTTON_SAVE"] = "Save"
L["BUTTON_SELECT_ALL"] = "Select All"
L["BUTTON_SET"] = "Set"
L["BUTTON_WARBAND_BANK_HISTORY"] = "Warband Bank History"
L["BUTTON_WARBAND_PROFIT_EXPORT"] = "Warband Weekly Profit CSV"
L["BUTTON_WEEKLY_PROFIT_EXPORT"] = "Weekly Profit CSV"
L["LABEL_CHARACTER_TIME"] = "Character / Time"
L["LABEL_CURRENT"] = "Current"
L["LABEL_DEFENSE_FMT"] = "Defense: %s"
L["LABEL_DETAIL"] = "Detail"
L["LABEL_DETAILS"] = "Details"
L["LABEL_GOLD"] = "Gold"
L["LABEL_GOAL_AMOUNT"] = "Goal Amount (gold)"
L["LABEL_HISTORY_COUNT"] = "기록 항목 수"
L["LABEL_LAST_UPDATED"] = "Last Updated"
L["LABEL_NET"] = "Net"
L["LABEL_PREVIOUS"] = "Previous"
L["LABEL_RECENT_HISTORY"] = "Recent History"
L["LABEL_RUNESTONE"] = "Runestone"
L["LABEL_SHARE"] = "Share"
L["LABEL_SOURCE"] = "Source"
L["LABEL_STATUS"] = "Status"
L["LABEL_TOKEN_AFFORDABLE"] = "구매 가능"
L["LABEL_TOKEN_DELTA"] = "차이"
L["LABEL_TOKEN_NOT_AFFORDABLE"] = "Cannot Afford"
L["LABEL_TOKEN_STALE"] = "Stale"
L["LABEL_WARBAND_WEEKLY_PROFIT"] = "Warband Weekly Profit"
L["LABEL_WOW_TOKEN"] = "WoW Token:"
L["MSG_NIT_TIMEPLAYED_WARNING"] = "NovaInstanceTracker detected. The /played message may be suppressed by NIT even when LiteVault's option is disabled."
L["MSG_PROFIT_GOAL_INVALID"] = "Enter a valid gold amount."
L["MSG_PROFIT_GOAL_NOT_SET"] = "No goal set"
L["MSG_RAID_RESYNC_COMPLETE"] = "Raid resync complete."
L["MSG_RAID_RESYNC_STARTED"] = "Raid resync started..."
L["MSG_RAID_RESYNC_UNAVAILABLE"] = "Raid resync unavailable."
L["MSG_TIMEPLAYED_RESTORED"] = "Time played messages restored."
L["MSG_TIMEPLAYED_SUPPRESSED"] = "Time played messages will be suppressed."
L["MSG_WOW_TOKEN_API_UNAVAILABLE"] = "WoW Token API is unavailable in this client."
L["MSG_WOW_TOKEN_DATA_UNAVAILABLE"] = "WoW Token data unavailable."
L["MSG_WOW_TOKEN_VISIT_AH"] = "Visit the Auction House to update WoW Token price."
L["MSG_WOW_TOKEN_VISIT_AH_SHORT"] = "Visit AH"
L["TAB_GLYPHS"] = "Glyphs"
L["TEXT_PROFIT_EXPORT_HINT"] = "Click in the box and press Ctrl+C to copy."
L["TEXT_PROFIT_EXPORT_SUBTITLE"] = "Copy the CSV text below."
L["TEXT_PROFIT_FALLBACK_APPEARANCE_COST"] = "Appearance cost"
L["TEXT_PROFIT_FALLBACK_AUCTION_DEPOSIT"] = "Auction deposit"
L["TEXT_PROFIT_FALLBACK_AUCTION_FEE"] = "Auction fee"
L["TEXT_PROFIT_FALLBACK_AUCTION_PURCHASE"] = "Auction purchase"
L["TEXT_PROFIT_FALLBACK_AUCTION_SALE"] = "Auction sale"
L["TEXT_PROFIT_FALLBACK_BARBER_COST"] = "Barber cost"
L["TEXT_PROFIT_FALLBACK_BLACK_MARKET_PURCHASE"] = "Black Market purchase"
L["TEXT_PROFIT_FALLBACK_CRAFTING_ORDER"] = "Crafting order"
L["TEXT_PROFIT_FALLBACK_GEAR_UPGRADE"] = "Gear upgrade"
L["TEXT_PROFIT_FALLBACK_GOLD_RECEIVED"] = "Gold received"
L["TEXT_PROFIT_FALLBACK_GOLD_REWARD"] = "Gold reward"
L["TEXT_PROFIT_FALLBACK_GOLD_SENT"] = "Gold sent"
L["TEXT_PROFIT_FALLBACK_GUILD_DEPOSIT"] = "Guild deposit"
L["TEXT_PROFIT_FALLBACK_GUILD_WITHDRAWAL"] = "Guild withdrawal"
L["TEXT_PROFIT_FALLBACK_RAW_GOLD"] = "Raw gold"
L["TEXT_PROFIT_FALLBACK_SERVICE_COST"] = "Service cost"
L["TEXT_PROFIT_FALLBACK_TRADE_GAIN"] = "Trade gain"
L["TEXT_PROFIT_FALLBACK_TRADE_PAYMENT"] = "Trade payment"
L["TEXT_PROFIT_FALLBACK_TRAINING_COST"] = "Training cost"
L["TEXT_PROFIT_FALLBACK_TRAVEL_COST"] = "Travel cost"
L["TEXT_PROFIT_FALLBACK_WOW_TOKEN_PURCHASE"] = "WoW 토큰 구매"
L["TEXT_PROFIT_ITEM_FALLBACK_FMT"] = "아이템 %d"
L["TEXT_PROFIT_GOALS_SUBTITLE"] = "전투부대의 주간 및 월간 순이익 목표입니다."
L["TEXT_PROFIT_GOAL_EDITOR_HINT"] = "골드 단위로 목표를 입력하세요. 비워 두거나 0을 입력하면 삭제됩니다."
L["TEXT_PROFIT_GRAPH_EMPTY_MONTHLY"] = "No monthly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND"] = "No warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY"] = "No monthly warband profit history recorded yet."
L["TEXT_PROFIT_GRAPH_EMPTY_WEEKLY"] = "No weekly profit history recorded yet."
L["TEXT_PROFIT_GRAPH_PENDING_MONTHLY"] = "월간 그래프 기록 추적이 시작되었으며 골드를 획득하거나 사용하면 데이터가 채워집니다."
L["TEXT_PROFIT_GRAPH_PENDING_WARBAND_MONTHLY"] = "전투부대 월간 그래프 기록 추적이 시작되었으며 골드 변동이 기록되면 데이터가 채워집니다."
L["TEXT_PROFIT_LEDGER_EMPTY_MONTHLY"] = "No monthly ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WARBAND"] = "No warband ledger transactions recorded yet."
L["TEXT_PROFIT_LEDGER_EMPTY_WEEKLY"] = "No weekly ledger transactions recorded yet."
L["TEXT_PROFIT_MONTHLY_GRAPH_SUBTITLE"] = "현재 캐릭터의 이번 달 일일 순이익입니다. 골드 변동이 기록되면 새 데이터가 채워집니다."
L["TEXT_PROFIT_MONTHLY_LEDGER_SUBTITLE"] = "현재 캐릭터의 최근 월간 거래입니다."
L["TEXT_PROFIT_SUBTITLE"] = "Weekly and monthly profit across your tracked characters."
L["TEXT_PROFIT_WARBAND_GRAPH_SUBTITLE"] = "최근 7일 동안 추적 중인 캐릭터의 일일 합산 이익입니다."
L["TEXT_PROFIT_WARBAND_LEDGER_WEEKLY_SUBTITLE"] = "추적 중인 캐릭터의 최근 주간 합산 거래입니다."
L["TEXT_PROFIT_WARBAND_MONTHLY_GRAPH_SUBTITLE"] = "추적 중인 캐릭터의 이번 달 일일 합산 이익입니다."
L["TEXT_PROFIT_SOURCE_AH_FEE"] = "경매장 수수료"
L["TEXT_PROFIT_SOURCE_BLACK_MARKET"] = "Black Market"
L["TEXT_PROFIT_SOURCE_CHEST"] = "Chest"
L["TEXT_PROFIT_SOURCE_CRAFT"] = "Craft"
L["TEXT_PROFIT_SOURCE_FLIGHT_PATH"] = "Flight Path"
L["TEXT_PROFIT_SOURCE_GUILD_BANK"] = "Guild Bank"
L["TEXT_PROFIT_SOURCE_LOOTED"] = "Looted"
L["TEXT_PROFIT_SOURCE_REPAIR"] = "Repair"
L["TEXT_PROFIT_SOURCE_TRAINING"] = "Training"
L["TEXT_PROFIT_SOURCE_WORLD_QUEST"] = "World Quest"
L["TEXT_PROFIT_WEEKLY_GRAPH_SUBTITLE"] = "현재 캐릭터의 최근 7일간 일일 순이익입니다."
L["TEXT_PROFIT_WEEKLY_LEDGER_SUBTITLE"] = "현재 캐릭터의 최근 주간 거래입니다."
L["TEXT_TRACKED_ACHIEVEMENT_ENTRIES_UNAVAILABLE_FMT"] = "%s의 추적 항목은 아직 추가되지 않았습니다."
L["TIME_DAYS_AGO_FMT"] = "%d일 전"
L["TIME_HOURS_AGO_FMT"] = "%d시간 전"
L["TIME_JUST_NOW"] = "Just now"
L["TIME_MINUTES_AGO_FMT"] = "%d분 전"
L["TIME_YESTERDAY"] = "Yesterday"
L["TITLE_GLYPH_HUNTER"] = "Glyph Hunter"
L["OPTION_ENABLE_MINI_OMNIUM_FOLIO"] = "Enable Mini Omnium Folio"
L["OPTION_ENABLE_MINI_OMNIUM_FOLIO_DESC"] = "Show a movable Omnium Folio panel outside the main LiteVault window for quick node access."
L["TEXT_FOLIO_AVAILABLE_POINTS_FMT"] = "Available Points: %d"
L["TEXT_OMNIUM_FOLIO_UNAVAILABLE"] = "Omnium Folio is unavailable."
L["TITLE_MINI_OMNIUM_FOLIO"] = "Omnium Folio"
L["TOOLTIP_HIDE_MINI_FOLIO"] = "Hide Mini Folio"
L["TOOLTIP_LOCK_MINI_FOLIO"] = "Lock Mini Folio"
L["TOOLTIP_UNLOCK_MINI_FOLIO"] = "Unlock Mini Folio"
L["TEXT_PROFIT_TOKENS_THIS_MONTH_FMT"] = "이번 달 토큰: %d"
L["TITLE_PROFIT_WOW_TOKENS_THIS_MONTH"] = "이번 달 WoW 토큰"
L["TITLE_WOW_TOKEN_HISTORY"] = "WoW Token History"
L["TOOLTIP_PROFIT_WOW_TOKENS_THIS_MONTH"] = "현재 달에 구매한 WoW 토큰을 집계합니다. 토큰 구매 비용은 총이익에서 제외됩니다."
L["TOOLTIP_RUNESTONE_EVENT"] = "Fortify the Runestones"
L["TOOLTIP_RUNESTONE_SET_WAYPOINT"] = "Click to set waypoint."
L["TOOLTIP_WOW_TOKEN_DESC"] = "Last known WoW Token market price."
L["TOOLTIP_WOW_TOKEN_TITLE"] = "WoW Token"

L["TEXT_ACHIEVEMENT_MOUNT_FMT"] = "Mount: %s"
L["LABEL_INFO"] = "Info"
L["Achievements"] = "Achievements"
L["Criteria"] = "Criteria"
L["Details"] = "Details"
L["Groups"] = "Groups"
L["Treasures of Midnight"] = "Treasures of Midnight"
L["Glory of the Midnight Delver"] = "Glory of the Midnight Delver"
L["Runestone Rush"] = "Runestone Rush"
L["The Party Must Go On"] = "The Party Must Go On"
L["A Singular Problem"] = "A Singular Problem"
L["From The Cradle to the Grave"] = "From The Cradle to the Grave"
L["Chronicler of the Haranir"] = "Chronicler of the Haranir"
L["Legends Never Die"] = "Legends Never Die"
L["Dust 'Em Off"] = "Dust 'Em Off"
L["No Time to Paws"] = "No Time to Paws"
L["Stormarion Assault"] = "Stormarion Assault"
L["Moths"] = "Moths"
L["Rares of Midnight"] = "Rares of Midnight"
L["Discover all of the lore objects found on the Coiled Isle."] = "Coiled Isle의 모든 전승 물체를 발견하세요."
L["%s contains %d moth coordinates. Click a moth to place a waypoint."] = "%s에 나방 좌표 %d개가 있습니다. 나방을 클릭하면 경유지를 설정합니다."
L["Abundance: Prosperous Plentitude!"] = "Abundance: Prosperous Plentitude!"


L["DIFFICULTY_LFR"] = "LFR"
L["LABEL_VAULT_TIER_FMT"] = "Tier %d"
L["LABEL_CRESTS"] = "Crests:"
L["TITLE_MOUNT_DROPS"] = "Mount Drops"
L["STATUS_COLLECTED_PARENS"] = "(Collected)"
L["STATUS_UNCOLLECTED_PARENS"] = "(Uncollected)"

L["BUTTON_BREAKDOWN"] = "Breakdown"
L["BUTTON_WARBAND_PROFIT_BREAKDOWN"] = "Warband Breakdown"
L["BUTTON_RITUAL_SITES"] = "Ritual Sites"
L["LABEL_MAX_RENOWN"] = "최대 영예"
L["LABEL_PARAGON"] = "불멸의 동맹"
L["LABEL_REWARD_FMT"] = "보상: %s"
L["LABEL_REWARD_LOADING"] = "보상 데이터 불러오는 중..."
L["TOOLTIP_FACTION_CARD_HINT"] = "Click to switch this faction."
L["LABEL_GAINED"] = "획득"
L["LABEL_TOP_SOURCES"] = "주요 출처"
L["LABEL_TOP_INCOME_SOURCE"] = "최고 수입 출처"
L["LABEL_TOP_EXPENSE_SOURCE"] = "최고 지출 출처"
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SUBTITLE"] = "전투부대의 주간 수입과 지출 출처 구성입니다."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_GAINS"] = "이번 주 전투부대가 가장 많은 골드를 획득한 출처입니다."
L["TEXT_PROFIT_WARBAND_BREAKDOWN_SPEND"] = "이번 주 전투부대가 가장 많은 골드를 지출한 항목입니다."
L["MSG_PROFIT_NO_INCOME"] = "아직 기록된 수입이 없습니다."
L["MSG_PROFIT_NO_SPENDING"] = "아직 기록된 지출이 없습니다."
L["MSG_NO_GOLD_WORLD_QUESTS"] = "No active gold world quests found."
L["LEDGER_WORLD_QUESTS"] = "World Quests"
L["LEDGER_UPGRADE"] = "업그레이드"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS"] = "룬석 지도 표식 비활성화"
L["OPTION_DISABLE_RUNESTONE_MAP_PINS_DESC"] = "영원노래 숲 지도에 LiteVault 룬석 표식을 더 이상 표시하지 않습니다."
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS"] = "달력 수익 강조 표시 활성화"
L["OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC"] = "Show green and red profit-day highlights on the calendar."
L["Community Engagement"] = "Community Engagement"
L["Void Strike"] = "Void Strike"
L["Void Assaults"] = "Void Assaults"
L["Void Assaults: Eversong Woods"] = "Void Assaults: Eversong Woods"
L["Void Assaults: Zul'Aman"] = "Void Assaults: Zul'Aman"
L["LABEL_NEXT_WEEK_FMT"] = "Next Week: %s"
L["Midnight: Prey"] = "Midnight: Prey"
L["Saltheril's Soiree"] = "Saltheril's Soiree"
L["Abundance Event"] = "Abundance Event"
L["Legends of the Haranir"] = "Legends of the Haranir"
L["Darkness Unmade"] = "Darkness Unmade"
L["Harvesting the Void"] = "Harvesting the Void"
L["Alchemy"] = "Alchemy"
L["Blacksmithing"] = "Blacksmithing"
L["Enchanting"] = "Enchanting"
L["Engineering"] = "Engineering"
L["Inscription"] = "Inscription"
L["Jewelcrafting"] = "Jewelcrafting"
L["Leatherworking"] = "Leatherworking"
L["Tailoring"] = "Tailoring"
L["Herbalism"] = "Herbalism"
L["Mining"] = "Mining"
L["Skinning"] = "Skinning"
L["Remnant of Anguish"] = "Remnant of Anguish"
L["Brimming Arcana"] = "Brimming Arcana"
L["Voidlight Marl"] = "Voidlight Marl"
L["Undercoin"] = "Undercoin"
L["Coffer Key Shards"] = "Coffer Key Shards"
L["Shard of Dundun"] = "Shard of Dundun"
L["Adventurer Dawncrest"] = "Adventurer Dawncrest"
L["Veteran Dawncrest"] = "Veteran Dawncrest"
L["Champion Dawncrest"] = "Champion Dawncrest"
L["Hero Dawncrest"] = "Hero Dawncrest"
L["Myth Dawncrest"] = "Myth Dawncrest"
L["Raid resync unavailable."] = "Raid resync unavailable."
L["Time played messages will be suppressed."] = "Time played messages will be suppressed."
L["Time played messages restored."] = "Time played messages restored."
L["%dm %02ds"] = "%dm %02ds"
L["LABEL_MOUNTS_FMT"] = "Mounts: %d/%d"
L["The Voidspire"] = "The Voidspire"
L["The Dreamrift"] = "The Dreamrift"
L["March of Quel'Danas"] = "March of Quel'Danas"
L["Lady Liadrin Weekly"] = "여군주 리아드린 주간 퀘스트"
L["Back"] = "Back"
L["Warband Bank"] = "Warband Bank"
L["Treatise"] = "논문"
L["Artisan"] = "장인"
L["Catch-up"] = "Catch-up"
L["LABEL_MONTHLY_PROFIT"] = "월간 수익"
L["LABEL_TOP_WEEKLY_EARNERS"] = "주간 최고 수익 캐릭터"
L["LABEL_TOP_MONTHLY_EARNERS"] = "월간 최고 수익 캐릭터"

L["LABEL_CHARACTER"] = "Character"


L["Ever-Painting"] = "Ever-Painting"
L["Midnight, the Highest Peaks"] = "Midnight, the Highest Peaks"
L["Explore Eversong Woods"] = "Explore Eversong Woods"
L["Explore Voidstorm"] = "Explore Voidstorm"
L["Explore Zul'Aman"] = "Explore Zul'Aman"
L["Explore Harandar"] = "Explore Harandar"
L["Thrill of the Chase"] = "Thrill of the Chase"
L["Making an Amani Out of You"] = "Making an Amani Out of You"
L["That's Aln, Folks!"] = "That's Aln, Folks!"
L["Forever Song"] = "Forever Song"
L["Yelling into the Voidstorm"] = "Yelling into the Voidstorm"
L["Light Up the Night"] = "Light Up the Night"
L["Altar of Blessings: Sacred Buffet Devotee"] = "Altar of Blessings: Sacred Buffet Devotee"

-- Register this locale
L["LABEL_FIRST_KILL"] = "첫 처치:"
L["LABEL_EARLIEST_RECORDED_KILL"] = "가장 이른 기록 처치:"
L["TEXT_HISTORICAL_DATA_UNAVAILABLE"] = "과거 기록을 사용할 수 없습니다"
L["LABEL_KNOWN_KILLS"] = "알려진 처치:"
L["LABEL_ALSO_KILLED_BY"] = "추가 처치 캐릭터:"
L["TEXT_KILL_DATE_UNAVAILABLE"] = "처치 날짜를 사용할 수 없습니다"

L["BUTTON_ZULJARRA_FORCES"] = "Zul'jarra's Forces"
L["BUTTON_CAPTAIN_TOKKA"] = "대장 토카"
L["LABEL_VALEERA_SANGUINAR"] = "Valeera Sanguinar"
L["LABEL_SLAYERS_DUELLUM"] = "Slayer's Duellum"
L["LABEL_MAXIMUM"] = "Maximum"
L["BUTTON_FACTION_WEEKLIES"] = "Faction Weeklies"
L["TITLE_TREASURES_OF_THE_DAMNED"] = "Treasures of the Damned"
L["LABEL_COMPLETED"] = "Completed"
L["LABEL_NOT_COMPLETED"] = "Not Completed"
L["LABEL_QUEST_FMT"] = "퀘스트: %s"
L["LABEL_QUEST_ID_FMT"] = "퀘스트 ID: %d"
L["TOOLTIP_TOKKA_TREASURE_HINT"] = "Fish this artifact up on the Coiled Isle and return it to Second Mate Sluggs at Tokka's Folly."
L["WARNING_TOKKA_ONE_TIME_ARTIFACTS"] = "Warning: These artifact quests are one-time Warband turn-ins. They do not reset daily or weekly and can only reward reputation once."
L["Turn Back the Surge"] = "Turn Back the Surge"
L["Purging the Vaults"] = "Purging the Vaults"
L["Spark of Tides"] = "Spark of Tides"
L["Venomblight Manaflux"] = "Venomblight Manaflux"
L["Adventurer Mistcrest"] = "Adventurer Mistcrest"
L["Veteran Mistcrest"] = "Veteran Mistcrest"
L["Champion Mistcrest"] = "Champion Mistcrest"
L["Hero Mistcrest"] = "Hero Mistcrest"
L["Myth Mistcrest"] = "Myth Mistcrest"
L["Corrosive Coin"] = "Corrosive Coin"
L["Trailing Xal'atath"] = "Trailing Xal'atath"
L["My Venomous Nemesis"] = "My Venomous Nemesis"
L.LABEL_CURRENT_CHARACTER = L.LABEL_CURRENT_CHARACTER or "현재 캐릭터"
L.LABEL_WARBAND_THIS_WEEK = L.LABEL_WARBAND_THIS_WEEK or "이번 주 전투부대"
L.LABEL_RUNS = L.LABEL_RUNS or "쐐기"
L.STATUS_TIMED = L.STATUS_TIMED or "시간 내 완료"
L.STATUS_DEPLETED = L.STATUS_DEPLETED or "시간 초과"
L.LABEL_BEST_TIMED = L.LABEL_BEST_TIMED or "최고 시간 내 완료"
L.FILTER_THIS_WEEK = L.FILTER_THIS_WEEK or "이번 주"
L.FILTER_SEASON = L.FILTER_SEASON or "시즌"
L.FILTER_ALL_HISTORY = L.FILTER_ALL_HISTORY or "전체 기록"
L.SECTION_SEASON_BESTS = L.SECTION_SEASON_BESTS or "시즌 최고 기록"
L.LABEL_BEST = L.LABEL_BEST or "최고"
L.LABEL_SCORE = L.LABEL_SCORE or "점수"
L.LABEL_NO_RUN = L.LABEL_NO_RUN or "기록 없음"
L.LABEL_LOWEST_SCORE = L.LABEL_LOWEST_SCORE or "최저 점수"
L.LABEL_NO_MPLUS_KEY = L.LABEL_NO_MPLUS_KEY or "쐐기돌 없음"
L.LABEL_DUNGEON = L.LABEL_DUNGEON or "던전"
L.LABEL_KEY = L.LABEL_KEY or "쐐기돌"
L.LABEL_RESULT = L.LABEL_RESULT or "결과"
L.LABEL_TIME = L.LABEL_TIME or "시간"
L.LABEL_DATE = L.LABEL_DATE or "날짜"
L.LABEL_REWARDS = L.LABEL_REWARDS or "보상"
L.LABEL_MAP_RECORD = L.LABEL_MAP_RECORD or "던전 기록"
L.LABEL_AFFIX_RECORD = L.LABEL_AFFIX_RECORD or "속성 기록"
L.LABEL_MPLUS_SCORE_PLAIN = L.LABEL_MPLUS_SCORE_PLAIN or "쐐기 점수"
L.LABEL_TIMER = L.LABEL_TIMER or "제한 시간"
L.LABEL_TIME_REMAINING = L.LABEL_TIME_REMAINING or "남은 시간"
L.LABEL_OVER_TIMER = L.LABEL_OVER_TIMER or "초과 시간"
L.LABEL_RECORDED_DURATION = L.LABEL_RECORDED_DURATION or "기록된 소요 시간"
L.LABEL_NOT_AVAILABLE = L.LABEL_NOT_AVAILABLE or "--"
L.SECTION_MPLUS_HISTORY = L.SECTION_MPLUS_HISTORY or "쐐기돌 던전 기록"
L.TEXT_NO_MPLUS_RUNS_THIS_WEEK = L.TEXT_NO_MPLUS_RUNS_THIS_WEEK or "이번 주에 완료한 쐐기돌 던전이 없습니다."
L.TEXT_NO_MPLUS_RUNS_THIS_SEASON = L.TEXT_NO_MPLUS_RUNS_THIS_SEASON or "이번 시즌에 완료한 쐐기돌 던전이 없습니다."
L.TEXT_NO_MPLUS_RUNS_RECORDED = L.TEXT_NO_MPLUS_RUNS_RECORDED or "기록된 쐐기돌 던전이 없습니다."
L.BUTTON_PLAN_RATING = L.BUTTON_PLAN_RATING or "점수 계획"
L.TITLE_MPLUS_RATING_PLANNER = L.TITLE_MPLUS_RATING_PLANNER or "쐐기 점수 계획기"
L.BUTTON_BACK_TO_DASHBOARD = L.BUTTON_BACK_TO_DASHBOARD or "대시보드로 돌아가기"
L.LABEL_CURRENT_RATING = L.LABEL_CURRENT_RATING or "현재 점수"
L.LABEL_TARGET_RATING = L.LABEL_TARGET_RATING or "목표 점수"
L.LABEL_MINIMUM_KEY = L.LABEL_MINIMUM_KEY or "최소 쐐기"
L.LABEL_MAXIMUM_KEY = L.LABEL_MAXIMUM_KEY or "최대 쐐기"
L.LABEL_AVOID_DUNGEONS = L.LABEL_AVOID_DUNGEONS or "제외할 던전"
L.BUTTON_CALCULATE_PLAN = L.BUTTON_CALCULATE_PLAN or "계획 계산"
L.LABEL_MAXIMUM_PROJECTED_RATING = L.LABEL_MAXIMUM_PROJECTED_RATING or "최대 예상 점수"
L.LABEL_PROJECTED_RATING = L.LABEL_PROJECTED_RATING or "예상 점수"
L.LABEL_CURRENT = L.LABEL_CURRENT or "현재"
L.LABEL_PLAN = L.LABEL_PLAN or "계획"
L.LABEL_GAIN = L.LABEL_GAIN or "상승"
L.TEXT_PLANNER_ALREADY_REACHED = L.TEXT_PLANNER_ALREADY_REACHED or "이미 이 점수를 달성했습니다."
L.TEXT_PLANNER_UNREACHABLE = L.TEXT_PLANNER_UNREACHABLE or "현재 제한으로 목표에 도달할 수 없습니다."
L.TEXT_PLANNER_INVALID_MINIMUM = L.TEXT_PLANNER_INVALID_MINIMUM or "최소 쐐기는 2 이상의 정수여야 합니다."
L.TEXT_PLANNER_INVALID_MAXIMUM = L.TEXT_PLANNER_INVALID_MAXIMUM or "최대 쐐기는 최소 이상, 20 이하여야 합니다."
L.TEXT_PLANNER_INVALID_TARGET = L.TEXT_PLANNER_INVALID_TARGET or "유효한 정수 목표 점수를 입력하세요."
L.TEXT_PLANNER_TIMED_ASSUMPTION = L.TEXT_PLANNER_TIMED_ASSUMPTION or "예상 점수는 제안된 모든 쐐기를 시간 내 완료한다고 가정합니다."
L.PLANNER_FASTEST = L.PLANNER_FASTEST or "최단"
L.PLANNER_BALANCED = L.PLANNER_BALANCED or "균형"
L.PLANNER_EASIEST = L.PLANNER_EASIEST or "최저 난이도"
local phase2 = {
MSG_NO_FACTION_WEEKLY_COMPLETIONS="추적된 주간 완료 기록이 없습니다.", TOOLTIP_QUEST_ID_FMT="ID: |cffffffff%d", CALENDAR_MONTH_YEAR_FMT="%d년 %s", LABEL_RENOWN_LEVEL_MAXIMUM_FMT="영예 레벨 %d - 최대", LABEL_RENOWN_LEVEL_PROGRESS_FMT="영예 레벨 %d (%d/%d)", LABEL_RENOWN_LEVEL_FMT="영예 레벨 %d", LABEL_RENOWN_VALUE_FMT="영예 %d", TEXT_CRESTS_WITH_VALUES_FMT="문장 %s", TOOLTIP_REWARDS_FMT="보상: %s", TOOLTIP_MOUNT_COLLECTED_FMT="%s (수집함)", TOOLTIP_MOUNT_UNCOLLECTED_FMT="%s (미수집)", LABEL_REWARD="보상", LABEL_NOTE="참고", STATUS_ACTIVE="활성", TOOLTIP_ENTRANCE_COORDINATES_FMT="입구: %.2f, %.2f (지도 %d)", TOOLTIP_INSCRIPTION_COORDINATES_FMT="비문: %.2f, %.2f (지도 %d)", TOOLTIP_ENTRANCE_INSCRIPTION_CLICK_INSTRUCTIONS="Shift-클릭: 입구, 클릭: 비문.", LABEL_100_RENOWN_FMT="영예 100: %s", TOOLTIP_ACHIEVEMENT_CREDIT_FROM_FMT="업적 인정 대상: %s", NOTE_HARANDAR_TREASURE_REQUIREMENTS="일부 보물은 추가 단계나 아이템이 있어야 열 수 있습니다.", NOTE_FORGOTTEN_MASK_LOCATION="그나르도르 섬의 부서진 돌담 위, 구렁 입구 남쪽에 있습니다.", NOTE_HEAD_MASONS_TABLET_LOCATION="동쪽 송곳니 관문 안. 입구: 지도 2512의 45.72, 64.94.", NOTE_PROFANED_PLAQUE_LOCATION="서쪽 송곳니 관문 안으로 들어간 뒤 바로 왼쪽 방. 입구: 지도 2512의 31.80, 64.91.", BUTTON_CANCEL="취소", BUTTON_SAVE="저장", BUTTON_SELECT_ALL="모두 선택", LABEL_COMPLETED="완료", LABEL_NOT_COMPLETED="미완료", LABEL_DETAILS="세부 정보", LABEL_DETAIL="상세", LABEL_INFO="정보", LABEL_MAXIMUM="최대", LABEL_PREVIOUS="이전", LABEL_RECENT_HISTORY="최근 기록", LABEL_SOURCE="출처", LABEL_STATUS="상태", TIME_JUST_NOW="방금", TIME_YESTERDAY="어제",
CALENDAR_MONTH_YEAR_FMT="%s %d년",
BUTTON_BACK_TO_GROUPS="그룹으로 돌아가기", TEXT_COORDINATE_GROUPS_NOT_AVAILABLE="좌표 그룹이 아직 추가되지 않았습니다.", TEXT_ZONE_REWARD_NOT_AVAILABLE="지역 보상이 아직 추가되지 않았습니다.", TEXT_META_REWARD_NOT_AVAILABLE="메타 업적 보상이 아직 추가되지 않았습니다.", TEXT_ACHIEVEMENT_REWARD_NOT_LISTED="업적 보상이 표시되지 않았습니다.", TOOLTIP_RUNESTONE_CHARGE_INSTRUCTION="잠재 비전 마력으로 룬석을 충전해 방어 이벤트를 시작하세요.", TEXT_COORDINATES_PENDING="좌표 준비 중.", TOOLTIP_CLICK_OPEN_TRACKER="클릭하여 이 추적기를 엽니다.", TEXT_TRACKER_NOT_AVAILABLE="추적기가 아직 추가되지 않았습니다.",
MSG_PROFIT_GOAL_INVALID="올바른 골드 금액을 입력하세요.", MSG_PROFIT_GOAL_NOT_SET="설정된 목표 없음", TEXT_PROFIT_EXPORT_HINT="상자를 클릭하고 Ctrl+C를 눌러 복사하세요.", TEXT_PROFIT_EXPORT_SUBTITLE="아래 CSV 텍스트를 복사하세요.", TEXT_PROFIT_SOURCE_BLACK_MARKET="암시장", TEXT_PROFIT_SOURCE_CHEST="상자", TEXT_PROFIT_SOURCE_CRAFT="제작", TEXT_PROFIT_SOURCE_FLIGHT_PATH="비행 경로", TEXT_PROFIT_SOURCE_GUILD_BANK="길드 은행", TEXT_PROFIT_SOURCE_LOOTED="전리품", TEXT_PROFIT_SOURCE_REPAIR="수리", TEXT_PROFIT_SOURCE_TRAINING="훈련", TEXT_PROFIT_SOURCE_WORLD_QUEST="전역 퀘스트", MSG_RAID_RESYNC_COMPLETE="공격대 재동기화가 완료되었습니다.", MSG_RAID_RESYNC_STARTED="공격대 재동기화를 시작했습니다...", MSG_RAID_RESYNC_UNAVAILABLE="공격대 재동기화를 사용할 수 없습니다.",
TEXT_PROFIT_FALLBACK_APPEARANCE_COST="외형 비용", TEXT_PROFIT_FALLBACK_AUCTION_DEPOSIT="경매 보증금", TEXT_PROFIT_FALLBACK_AUCTION_FEE="경매 수수료", TEXT_PROFIT_FALLBACK_AUCTION_PURCHASE="경매 구매", TEXT_PROFIT_FALLBACK_AUCTION_SALE="경매 판매", TEXT_PROFIT_FALLBACK_BARBER_COST="미용실 비용", TEXT_PROFIT_FALLBACK_BLACK_MARKET_PURCHASE="암시장 구매", TEXT_PROFIT_FALLBACK_CRAFTING_ORDER="제작 주문", TEXT_PROFIT_FALLBACK_GEAR_UPGRADE="장비 강화", TEXT_PROFIT_FALLBACK_GOLD_RECEIVED="받은 골드", TEXT_PROFIT_FALLBACK_GOLD_REWARD="골드 보상", TEXT_PROFIT_FALLBACK_GOLD_SENT="보낸 골드", TEXT_PROFIT_FALLBACK_GUILD_DEPOSIT="길드 입금", TEXT_PROFIT_FALLBACK_GUILD_WITHDRAWAL="길드 출금", TEXT_PROFIT_FALLBACK_RAW_GOLD="직접 획득 골드", TEXT_PROFIT_FALLBACK_SERVICE_COST="서비스 비용", TEXT_PROFIT_FALLBACK_TRADE_GAIN="거래 수입", TEXT_PROFIT_FALLBACK_TRADE_PAYMENT="거래 지출", TEXT_PROFIT_FALLBACK_TRAINING_COST="훈련 비용", TEXT_PROFIT_FALLBACK_TRAVEL_COST="이동 비용", TEXT_PROFIT_GRAPH_EMPTY_MONTHLY="아직 월간 수익 기록이 없습니다.", TEXT_PROFIT_GRAPH_EMPTY_WARBAND="아직 전투부대 수익 기록이 없습니다.", TEXT_PROFIT_GRAPH_EMPTY_WARBAND_MONTHLY="아직 월간 전투부대 수익 기록이 없습니다.", TEXT_PROFIT_GRAPH_EMPTY_WEEKLY="아직 주간 수익 기록이 없습니다.", TEXT_PROFIT_LEDGER_EMPTY_MONTHLY="아직 월간 원장 거래 기록이 없습니다.", TEXT_PROFIT_LEDGER_EMPTY_WARBAND="아직 전투부대 원장 거래 기록이 없습니다.", TEXT_PROFIT_LEDGER_EMPTY_WEEKLY="아직 주간 원장 거래 기록이 없습니다.", TEXT_PROFIT_SUBTITLE="추적 중인 캐릭터의 주간 및 월간 수익입니다.",
BUTTON_BREAKDOWN="세부 내역", BUTTON_FILTER="필터", BUTTON_SET="설정", BUTTON_RAIDS="공격대", BUTTON_WARBAND_BANK_HISTORY="전투부대 은행 기록", TITLE_TREASURES_OF_THE_DAMNED="저주받은 자의 보물", TOOLTIP_TOKKA_TREASURE_HINT="Coiled Isle에서 이 유물을 낚아 Tokka's Folly의 Second Mate Sluggs에게 돌려주세요.", WARNING_TOKKA_ONE_TIME_ARTIFACTS="경고: 이 유물 퀘스트는 전투부대에서 한 번만 반납할 수 있습니다. 일일 또는 주간 초기화가 적용되지 않으며 평판 보상도 한 번만 받을 수 있습니다.", MSG_RAID_HISTORY_PRESERVED="공격대 기록이 보존되었습니다. 데이터를 삭제하는 시즌 초기화는 비활성화되어 있습니다.", TOOLTIP_RAID_BOSS_DIFFICULTY_FMT="%s — %s", TITLE_MINI_OMNIUM_FOLIO="옴니움 책자", TOOLTIP_HIDE_MINI_FOLIO="미니 책자 숨기기", TOOLTIP_LOCK_MINI_FOLIO="미니 책자 잠그기", TOOLTIP_UNLOCK_MINI_FOLIO="미니 책자 잠금 해제", TAB_GLYPHS="문양", TITLE_GLYPH_HUNTER="문양 사냥꾼", TOOLTIP_RUNESTONE_SET_WAYPOINT="클릭하여 경로 지점을 설정합니다.", LABEL_CHARACTER_TIME="캐릭터 시간", LABEL_LAST_UPDATED="마지막 업데이트", LABEL_VAULT_OVERALL_PROGRESS="전체 진행도: %d/%d", LABEL_VAULT_ROW_DUNGEONS="던전", TITLE_CHARACTER_GREAT_VAULT_FMT="%s의 위대한 금고: %s", TITLE_CHARACTER_WEEKLY_PLANNER_FMT="%s의 주간 계획: %s", LABEL_NEXT_WEEK_FMT="다음 주: %s",
BUTTON_EDIT_MONTHLY_GOAL="월간 목표 편집", BUTTON_EDIT_WEEKLY_GOAL="주간 목표 편집", BUTTON_EXPORT_CSV="CSV 내보내기", BUTTON_MONTHLY_PROFIT_EXPORT="월간 수익 CSV", BUTTON_WARBAND_PROFIT_BREAKDOWN="전투부대 세부 내역", BUTTON_WARBAND_PROFIT_EXPORT="전투부대 주간 수익 CSV", BUTTON_WEEKLY_PROFIT_EXPORT="주간 수익 CSV", LABEL_GOAL_AMOUNT="목표 금액 (골드)", LABEL_GOLD="골드", LABEL_NET="순액", LABEL_SHARE="공유", LABEL_ZONE="지역", LABEL_WARBAND_WEEKLY_PROFIT="전투부대 주간 수익", MSG_NIT_TIMEPLAYED_WARNING="NovaInstanceTracker가 감지되었습니다. LiteVault 옵션이 비활성화되어 있어도 NIT가 /played 메시지를 숨길 수 있습니다.", MSG_TIMEPLAYED_RESTORED="플레이 시간 메시지가 복원되었습니다.", MSG_TIMEPLAYED_SUPPRESSED="플레이 시간 메시지가 숨겨집니다.", MSG_WOW_TOKEN_API_UNAVAILABLE="이 클라이언트에서는 WoW 토큰 API를 사용할 수 없습니다.", MSG_WOW_TOKEN_DATA_UNAVAILABLE="WoW 토큰 데이터를 사용할 수 없습니다.", MSG_WOW_TOKEN_VISIT_AH="경매장을 방문하여 WoW 토큰 가격을 갱신하세요.", OPTION_ENABLE_CALENDAR_PROFIT_HIGHLIGHTS_DESC="달력에 수익 및 손실 날짜를 녹색과 빨간색으로 표시합니다.",
TITLE_ACHIEVEMENTS="업적", LABEL_ACHIEVEMENT_GROUPS="그룹", LABEL_GLOWING_MOTHS="나방", LABEL_SHARED_LOOT="공유 전리품", LABEL_KNOWLEDGE_CATCHUP="따라잡기", STATUS_ASSAULT_WAVE_1_COMPLETE="1단계 완료", STATUS_ASSAULT_WAVE_2_COMPLETE="2단계 완료", STATUS_ASSAULT_WAVE_3_COMPLETE="3단계 완료", TEXT_MIDNIGHT_RARES_TRACKER_DESCRIPTION="Midnight 희귀 업적, 보상 및 공유 전리품을 추적합니다.", TEXT_MIDNIGHT_TREASURES_TRACKER_DESCRIPTION="Midnight 보물 업적과 보상을 추적합니다.", TEXT_HARANIR_JOURNAL_INSTRUCTION="아래의 Haranir 일지 항목을 회수하세요.", TEXT_HARANIR_LEGEND_DEFENSE_INSTRUCTION="아래에 표시된 각 Haranir 전설 장소를 방어하세요.", TEXT_BLESSING_EFFECT_INSTRUCTION="목록의 각 축복 효과를 발동해 진행도를 획득하세요.", TOOLTIP_CAVE_RUN_CREDIT_INSTRUCTION="이곳의 동굴 탐험을 완료해 진행도를 획득하세요.", TEXT_TELESCOPE_ZONE_REQUIREMENT="이 지역의 망원경 다섯 개를 완료하세요.",
TEXT_MIDNIGHT_DELVER_META_INSTRUCTION="이 메타 업적을 완료하려면 Midnight 구렁 보조 업적 네 개를 모두 완료하세요.", TEXT_COILED_ISLE_META_INSTRUCTION="Coiled Isle 업적을 완료하세요.", TEXT_MIDNIGHT_ZONE_META_REWARD_REQUIREMENT="Midnight 지역 메타 업적 네 개를 완료하고 탈것 보상을 받으세요.", TEXT_CLAW_ENFORCEMENT_REQUIREMENT="Predator's Pursuit 효과를 15회 이상 중첩한 상태로 Harandar 전역 퀘스트 'Claw Enforcement'를 완료하세요.", TEXT_ATALUTEK_META_INSTRUCTION="Vaults of Atal'Utek 업적을 완료하세요.", TEXT_COILED_ISLE_LORE_INSTRUCTION="Coiled Isle의 전승 물체를 발견하세요.", TEXT_HUNGERING_PRESENCE_REQUIREMENT="Voidstorm에서 Hungering Presence의 손아귀를 60초 이상 피하세요.", TEXT_CRADLE_FLIGHT_REQUIREMENT="Harandar 상공의 The Cradle로 날아가 이 업적을 완료하세요.", TEXT_EVERSONG_META_TRACKER_DESCRIPTION="Eversong Woods 메타 업적을 추적하고 하위 추적기로 이동합니다.", TEXT_MIDNIGHT_PEAKS_TRACKER_DESCRIPTION="Midnight, the Highest Peaks의 지역 업적 네 개를 추적합니다.", TEXT_HARANDAR_META_TRACKER_DESCRIPTION="Harandar 메타 업적을 추적하고 하위 추적기로 이동합니다.", TEXT_VOIDSTORM_META_TRACKER_DESCRIPTION="Voidstorm 메타 업적을 추적하고 하위 추적기로 이동합니다.", TEXT_ZULAMAN_META_TRACKER_DESCRIPTION="Zul'Aman 메타 업적을 추적하고 하위 추적기로 이동합니다.", TEXT_CRADLE_FLIGHT_ATTEMPT="Harandar 상공의 The Cradle로 날아가 보세요.", NOTE_MOTH_ROUTE_RENOWN_REQUIREMENT="LiteVault 경로는 Hara'ti Renown 11이 이미 잠금 해제되었다고 가정합니다.",
TEXT_HARATI_META_PROGRESS_INSTRUCTION="아래 업적을 완료해 Hara'ti를 도우세요. x/y 완료.", TEXT_VOIDSTORM_META_PROGRESS_INSTRUCTION="아래의 Voidstorm 업적을 모두 완료하세요. x/y 완료.", TEXT_ZULAMAN_META_PROGRESS_INSTRUCTION="아래의 Zul'Aman 업적을 모두 완료하세요. x/y 완료.", TEXT_STORMARION_ASSAULT_PROGRESS_INSTRUCTION="Stormarion Assault의 세 단계를 모두 완료하세요. x/y 표시됨.", TEXT_ABUNDANT_HARVEST_PROGRESS_INSTRUCTION="각 장소에서 Abundant Harvest 동굴 탐험을 완료하세요. x/y 표시됨.", TEXT_EVERSONG_META_PROGRESS_INSTRUCTION="아래의 Eversong Woods 업적을 완료하세요. x/y 완료.", TEXT_GLOWING_MOTH_PROGRESS="Harandar에 숨어 있는 Glowing Moths를 모두 찾으세요. x/y 발견.", TEXT_HARANIR_LEGEND_PROGRESS="아래의 각 Haranir 전설 장소를 보호하세요. x/y 표시됨.", TEXT_XALATATH_META_PROGRESS="아래 업적을 완료해 Xal'atath에 맞설 병력을 모으세요. x/y 완료.", TEXT_HARANIR_JOURNAL_PROGRESS="아래의 Haranir 일지 항목을 회수하세요. x/y 표시됨.", TEXT_BLESSING_EFFECT_PROGRESS="목록의 각 축복 효과를 발동하세요. x/y 표시됨.", TEXT_FACTION_INVITE_PROGRESS="The Party Must Go On의 진영 초대 네 개를 추적합니다. x/y 표시됨.", TEXT_EVER_PAINTING_PROGRESS="알려진 Ever-Painting 화폭을 추적합니다. x/y 표시됨.", TEXT_RUNESTONE_RUSH_PROGRESS="알려진 Runestone Rush 항목을 추적합니다. x/y 표시됨.",
TEXT_DELVER_MOUNT_REWARD_REQUIREMENT="Glory of the Midnight Delver를 완료해 이 탈것을 획득하세요.", NOTE_MOTH_GROUP_1_RENOWN="나방 1–40은 Hara'ti Renown 1에 등장하며 Renown 2에 추적이 열립니다.", NOTE_MOTH_GROUP_2_RENOWN="나방 41–80은 Hara'ti Renown 4에 등장하며 Renown 6에 추적이 열립니다.", NOTE_MOTH_GROUP_3_RENOWN="나방 81–120은 Hara'ti Renown 9에 등장하며 Renown 11에 추적이 열립니다.", NOTE_HARANIR_JOURNAL_AVAILABILITY="이 일지는 계정 공유 주간 퀘스트 'Legends of the Haranir' 진행 중에만 사용할 수 있습니다. 환영 안에서는 미니맵의 돋보기 아이콘을 찾으세요.", NOTE_CLAW_ENFORCEMENT_NO_COORDINATES="이 업적은 LiteVault 좌표 추적이 필요하지 않습니다. Predator's Pursuit 효과를 15회 이상 중첩한 상태로 Harandar 전역 퀘스트 'Claw Enforcement'를 완료하세요.", NOTE_HUNGERING_PRESENCE_NO_COORDINATES="이 업적은 LiteVault 좌표 추적이 필요하지 않습니다. Voidstorm의 Hungering Presence 이벤트에서 60초 이상 생존하세요.", NOTE_HARANIR_LEGENDS_WEEKLY_ESTIMATE="이 항목은 계정 공유 주간 퀘스트 'Legends of the Haranir'와 연계됩니다. 아직 진행도가 없다면 완료까지 약 7주가 걸립니다.", NOTE_MOTH_TRACKER_GROUPING="나방 경로를 관리하기 쉽도록 이 추적기는 좌표 40개씩 3개 그룹으로 나뉩니다.", TEXT_EVER_PAINTING_TRACKER_PLACEHOLDER="Ever-Painting 진행도를 추적합니다. 세부 항목은 나중에 추가할 수 있습니다.", TEXT_EXPLORE_EVERSONG_TRACKER_PLACEHOLDER="Explore Eversong Woods 진행도를 추적합니다. 세부 항목은 나중에 추가할 수 있습니다.", TEXT_RUNESTONE_RUSH_TRACKER_PLACEHOLDER="Runestone Rush 진행도를 추적합니다. 세부 항목은 나중에 추가할 수 있습니다.", TEXT_PARTY_TRACKER_PLACEHOLDER="The Party Must Go On 진행도를 추적합니다. 세부 항목은 나중에 추가할 수 있습니다.", TOOLTIP_ABUNDANT_HARVEST_CREDIT_REQUIREMENT="각 장소에서 Abundant Harvest 동굴 탐험을 완료해야 합니다. 동굴을 방문하기만 해서는 인정되지 않습니다.",
TEXT_EXPLORE_EVERSONG_PROGRESS="Explore Eversong Woods 진행도를 추적합니다. x/y 표시됨.", TEXT_EXPLORE_HARANDAR_PROGRESS="Explore Harandar 진행도를 추적합니다. x/y 표시됨.", TEXT_EXPLORE_VOIDSTORM_PROGRESS="Explore Voidstorm 진행도를 추적합니다. x/y 표시됨.", TEXT_EXPLORE_ZULAMAN_PROGRESS="Explore Zul'Aman 진행도를 추적합니다. x/y 표시됨.",
}
for key,value in pairs(phase2) do L[key]=value end
lv.RegisterLocale("koKR", L)

-- Store for reload functionality
lv.LocaleData = lv.LocaleData or {}
lv.LocaleData["koKR"] = L
