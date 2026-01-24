local addonName, addonTable = ...
if GetLocale() ~= "koKR" then return end
local L = addonTable.L

L["SETTINGS_FILTER"] = "필터"
L["SETTINGS_APPEARANCE"] = "외형"
L["SETTINGS_BEHAVIOR"] = "그룹 동작"
L["SETTINGS_AUTOMATION"] = "자동화"
L["SETTINGS_RESET"] = "|cffff0000기본값 초기화|r"

L["SET_HIDE_OFFLINE"] = "오프라인 친구 숨기기"
L["SET_HIDE_AFK"] = "자리 비움(AFK) 친구 숨기기"
L["SET_HIDE_EMPTY"] = "빈 그룹 숨기기"
L["SET_INGAME_ONLY"] = "게임 내 친구만 표시"
L["SET_RETAIL_ONLY"] = "본섭(Retail) 친구만 표시"
L["SET_CLASS_COLOR"] = "직업 색상 이름 사용"
L["SET_FACTION_ICONS"] = "진영 아이콘 표시"
L["SET_GRAY_FACTION"] = "상대 진영 흐리게 표시"
L["SET_SHOW_REALM"] = "서버 표시"
L["SET_SHOW_BTAG"] = "배틀태그만 표시"
L["SET_HIDE_MAX_LEVEL"] = "최고 레벨 숨기기"
L["SET_MOBILE_AFK"] = "모바일 접속을 자리 비움으로 표시"
L["SET_FAV_GROUP"] = "즐겨찾기 그룹 활성화"
L["SET_COLLAPSE"] = "그룹 자동 접기"
L["SET_AUTO_ACCEPT"] = "초대 자동 수락"

L["MENU_RENAME"] = "그룹 이름 변경"
L["MENU_REMOVE"] = "그룹 삭제"
L["MENU_INVITE"] = "그룹 파티 초대"
L["MENU_MAX_40"] = " (최대 40)"

L["DROP_TITLE"] = "FriendGroups"
L["DROP_COPY_NAME"] = "이름-서버 복사"
L["DROP_COPY_BTAG"] = "배틀태그 복사"
L["DROP_CREATE"] = "새 그룹 생성"
L["DROP_ADD"] = "그룹에 추가"
L["DROP_REMOVE"] = "그룹에서 제거"
L["DROP_CANCEL"] = "취소"

L["POPUP_ENTER_NAME"] = "새 그룹 이름을 입력하세요"
L["POPUP_COPY"] = "복사하려면 Ctrl+C를 누르세요:"

L["GROUP_FAVORITES"] = "[즐겨찾기]"
L["GROUP_NONE"] = "[그룹 없음]"
L["GROUP_EMPTY"] = "친구 목록이 비어 있습니다"

L["STATUS_MOBILE"] = "모바일"
L["SEARCH_PLACEHOLDER"] = "FriendGroups 검색"
L["MSG_RESET"] = "|cFF33FF99FriendGroups|r: 설정이 초기화되었습니다."
L["MSG_BUG_WARNING"] = "|cFF33FF99FriendGroups|r: 배틀넷 API 오류가 감지되었습니다. 게임을 재시작해주세요."
L["MSG_WELCOME"] = "버전 %s (Osiris the Kiwi 12.0 패치 업데이트)"

L["SEARCH_TOOLTIP"] = "FriendGroups: 친구 검색! 이름, 서버, 직업 및 메모"

L["RELOAD_BTN_TEXT"]      = "FriendGroups 새로고침"
L["RELOAD_TOOLTIP_TITLE"] = "FriendGroups 새로고침"
L["RELOAD_TOOLTIP_DESC"]  = "FriendGroups를 복구하기 위해 UI를 새로 고칩니다."

L["SHIELD_MSG"]           = "|cffFF0000FriendGroups 활성|r\n\n블리자드 보안 제한으로 인해,\n하우징을 보려면 리로드해야 합니다."
L["SHIELD_BTN_TEXT"]      = "리로드하고 하우징 보기"
L["SAFE_MODE_WARNING"]    = "|cffFF0000하우징 보기:|r 하우징을 보기 위해 FriendGroups가 비활성화되었습니다."