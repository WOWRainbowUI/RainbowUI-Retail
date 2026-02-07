local addonName, addonTable = ...
local L = addonTable.L

-- [[ GUARD CLAUSE: STOP IF NOT KR ]] --
if GetLocale() ~= "koKR" then return end

-- ============================================================================
-- [[ SETTINGS MENU HEADERS ]]
-- ============================================================================
L["SETTINGS_SIZE"]       = "목록 크기"
L["SETTINGS_FILTER"]     = "필터"
L["SETTINGS_APPEARANCE"] = "외형"
L["SETTINGS_BEHAVIOR"]   = "동작 설정"
L["SETTINGS_AUTOMATION"] = "자동화"
L["SETTINGS_RESET"]      = "|cffff0000기본값으로 초기화|r"

-- ============================================================================
-- [[ SETTINGS: SIZE ]]
-- ============================================================================
L["SET_SIZE_SMALL"]      = "작게 (기본)"
L["SET_SIZE_MEDIUM"]     = "중간"
L["SET_SIZE_LARGE"]      = "크게"

-- ============================================================================
-- [[ SETTINGS: FILTERS ]]
-- ============================================================================
L["SET_HIDE_OFFLINE"]    = "오프라인 숨기기"
L["SET_HIDE_AFK"]        = "자리 비움 숨기기"
L["SET_MOBILE_AFK"]      = "모바일을 자리 비움으로 표시"
L["SET_HIDE_EMPTY"]      = "빈 그룹 숨기기"
L["SET_INGAME_ONLY"]     = "게임 내 친구만 표시"
L["SET_RETAIL_ONLY"]     = "리테일 친구만 표시"

-- ============================================================================
-- [[ SETTINGS: APPEARANCE ]]
-- ============================================================================
L["SET_SHOW_FLAGS"]      = "서버 국기 표시"
L["SET_SHOW_REALM"]      = "서버 이름 표시"
L["SET_CLASS_COLOR"]     = "직업 색상 사용"
L["SET_FACTION_ICONS"]   = "진영 아이콘 표시"
L["SET_GRAY_FACTION"]    = "상대 진영 흐리게 표시"
L["SET_SHOW_BTAG"]       = "배틀태그만 표시"
L["SET_HIDE_MAX_LEVEL"]  = "만렙 숨기기"

-- ============================================================================
-- [[ SETTINGS: BEHAVIOR ]]
-- ============================================================================
L["SET_FAV_GROUP"]       = "즐겨찾기 그룹 활성화"
L["SET_COLLAPSE"]        = "그룹 자동 접기"

-- ============================================================================
-- [[ SETTINGS: AUTOMATION ]]
-- ============================================================================
L["SET_AUTO_ACCEPT"]     = "파티 초대 자동 수락"
L["SET_AUTO_PARTY_SYNC"] = "파티 동기화 자동 수락"
L["MSG_AUTO_INVITE"]     = "|cFF33FF99FriendGroups|r: %s님이 파티에 초대했습니다. 자동 수락 |cff00ff00활성화됨|r"
L["MSG_AUTO_SYNC"]       = "|cFF33FF99FriendGroups|r: %s님이 파티 동기화를 요청했습니다. 자동 수락 |cff00ff00활성화됨|r"

-- Spirit Behavior Sub-Menu
L["SET_SPIRIT_HEADER"]   = "유령 행동"
L["SET_SPIRIT_NONE"]     = "없음"
L["SET_SPIRIT_RES"]      = "부활 자동 수락"
L["SET_SPIRIT_RELEASE"]  = "자동 영혼 놓아주기"

L["MSG_AUTO_RES"]        = "|cFF33FF99FriendGroups|r: %s님이 부활을 시도합니다. 자동 수락 |cff00ff00활성화됨|r"
L["MSG_AUTO_RELEASE"]    = "|cFF33FF99FriendGroups|r: 사망했습니다. 자동 영혼 놓아주기 |cff00ff00활성화됨|r"

-- ============================================================================
-- [[ CONTEXT MENUS ]]
-- ============================================================================
-- Group Header Right-Click
L["MENU_RENAME"]         = "그룹 이름 변경"
L["MENU_REMOVE"]         = "그룹 삭제"
L["MENU_INVITE"]         = "그룹 초대"
L["MENU_MAX_40"]         = " (최대 40명)"

-- Friend Button Right-Click
L["DROP_TITLE"]          = "FriendGroups"
L["DROP_COPY_NAME"]      = "이름-서버 복사"
L["DROP_COPY_BTAG"]      = "배틀태그 복사"
L["DROP_CREATE"]         = "새 그룹 생성"
L["DROP_ADD"]            = "그룹에 추가"
L["DROP_REMOVE"]         = "그룹에서 제거"
L["DROP_CANCEL"]         = "취소"

-- ============================================================================
-- [[ POPUPS & SYSTEM ]]
-- ============================================================================
L["POPUP_ENTER_NAME"]    = "새 그룹 이름 입력"
L["POPUP_COPY"]          = "복사하려면 Ctrl+C를 누르세요:"

L["SEARCH_PLACEHOLDER"]  = "FriendGroups 검색"
L["SEARCH_TOOLTIP"]      = "FriendGroups: 이름, 서버, 직업, 메모 등으로 친구를 검색하세요."

L["MSG_WELCOME"]         = "버전 %s (Osiris the Kiwi 업데이트 - 패치 12.0)"
L["MSG_RESET"]           = "|cFF33FF99FriendGroups|r: 설정이 초기화되었습니다."
L["MSG_BUG_WARNING"]     = "|cFF33FF99FriendGroups|r: Bnet API 버그 감지됨. 친구 목록이 비어 보이는 현상은 와우 클라이언트 버그입니다. 게임을 재시작해주세요. (해결 보장 없음)"

-- ============================================================================
-- [[ SPECIAL GROUP NAMES ]]
-- ============================================================================
L["GROUP_FAVORITES"]     = "[즐겨찾기]"
L["GROUP_NONE"]          = "[그룹 없음]"
L["GROUP_EMPTY"]         = "친구 목록이 비었습니다"
L["STATUS_MOBILE"]       = "모바일"

-- ============================================================================
-- [[ HOUSING / SAFE MODE ]]
-- ============================================================================
L["RELOAD_BTN_TEXT"]      = "FriendGroups 재시작"
L["RELOAD_TOOLTIP_TITLE"] = "FriendGroups 재시작"
L["RELOAD_TOOLTIP_DESC"]  = "FriendGroups를 복구하기 위해 UI를 재시작합니다."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups 활성 상태|r\n\n블리자드 보안 제한으로 인해,\n하우징을 보려면 재시작해야 합니다."
L["SHIELD_BTN_TEXT"]      = "하우징 보기 (재시작)"
L["SAFE_MODE_WARNING"]    = "|cffFF0000하우징:|r 하우징을 보기 위해 FriendGroups가 비활성화되었습니다. 다시 활성화하려면 재시작하세요."