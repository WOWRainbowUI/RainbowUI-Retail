
if (GetLocale() ~= "koKR") then return end

local L = MikSBT.translations




L.MSG_NEW_PROFILE					= "새로운 프로필"
L.MSG_PROFILE_ALREADY_EXISTS		= "프로필이 이미 존재합니다."
L.MSG_INVALID_PROFILE_NAME			= "허용되지 않는 프로필 이름입니다."
L.MSG_NEW_SCROLL_AREA				= "새로운 스크롤 영역"
L.MSG_SCROLL_AREA_ALREADY_EXISTS	= "스크롤 영역 이름이 이미 존재합니다."
L.MSG_INVALID_SCROLL_AREA_NAME		= "허용되지 않는 스크롤 영역 이름입니다."
L.MSG_ACKNOWLEDGE_TEXT				= "이 동작을 수행 하시겠습니까?"
L.MSG_NORMAL_PREVIEW_TEXT			= "기본"
L.MSG_DISPLAY_QUALITY				= "이 품질의 아이템을 위한 알림을 표시합니다."
L.MSG_ITEM_QUALITIES				= "아이템 품질"
L.MSG_ITEMS							= "아이템"
L.MSG_ITEM_ALREADY_EXISTS			= "아이템 이름이 이미 존재합니다."
L.MSG_INVALID_ITEM_NAME				= "잘못된 아이템 이름."



obj = L.TABS
obj["general"] = { label="일반", tooltip="전반적인 설정을 표시합니다."}
obj["scrollAreas"] = { label="스크롤 영역", tooltip="스크롤 영역의 생성, 삭제, 배치에 관한 설정을 표시합니다.\n\n더 많은 정보를 얻으려면 아이콘 버튼에 마우스 커서를 올리세요."}
obj["events"] = { label="이벤트", tooltip="이벤트에 관한 설정을 표시합니다.\n\n더 많은 정보를 얻으려면 아이콘 버튼에 마우스 커서를 올리세요."}
obj["lootAlerts"]	= { label="획득 알림", tooltip="전리품 획득 안내에 대한 설정을 표시합니다."}



obj = L.CHECKBOXES

obj["disableMSBTInGroup"]		= { label="Disable MSBT In Group", tooltip="Automatically disable MSBT while in a party or raid."}
obj["stickyCrits"]				= { label="치명타 고정", tooltip="치명타를 고정 스타일로 표시합니다."}
obj["colorPartialEffects"]		= { label="부분 속성 색상", tooltip="부분 속성을 선택한 색상으로 표시합니다."}
obj["crushing"]					= { label="강타", tooltip="강타를 표시합니다."}
obj["glancing"]					= { label="비껴맞음", tooltip="비껴맞음을 표시합니다."}
obj["absorb"]					= { label="흡수", tooltip="흡수량을 표시합니다."}
obj["block"]					= { label="방어", tooltip="방어량을 표시합니다."}
obj["resist"]					= { label="저항", tooltip="부분 저항 피해량을 표시합니다."}
obj["vulnerability"]			= { label="약점 보너스", tooltip="약점 보너스를 표시합니다."}
obj["overheal"]					= { label="초과 치유", tooltip="초과 치유량을 표시합니다."}
obj["overkill"]					= { label="초과 피해", tooltip="초과 피해량을 표시합니다."}
obj["colorUnitNames"]			= { label="유닛 이름 색상", tooltip="유닛 이름을 지정한 직업 색상으로 표시합니다."}
obj["colorClassEntry"]			= { tooltip="이 직업의 색상을 활성화 합니다."}
obj["enableScrollArea"]			= { tooltip="이 스크롤 영역을 활성화 합니다."}
obj["inheritField"]				= { label="상속", tooltip="이 항목 값을 상속합니다. 체크를 하지 않으면 무시됩니다."}
obj["hideSkillIcons"]			= { label="아이콘 숨김", tooltip="이 스크롤 영역 안에 아이콘을 표시하지 않습니다."}
obj["stickyEvent"]				= { label="항상 고정", tooltip="항상 고정 스타일로 이벤트를 표시합니다."}
obj["enableTrigger"]			= { tooltip="트리거를 활성화합니다."}
obj["allPowerGains"]			= { label="모든 마력 (마나/분노 등) 획득", tooltip="전투 로그로 나타나지 않는 것을 포함한 모든 마력 (마나, 분노, 기력, 룬 마력) 획득을 표시합니다..\n\n주의: 이 옵션은 마력 표시 기준 및 출력시간 설정을 무시하므로 원치 않는 메시지를 많이 표시할수 있습니다.\n\n[비 추천]"}
obj["abbreviateSkills"]			= { label="짧은 기술 이름", tooltip="기술 이름을 짧게 표시해줍니다(영문).\n\n이 설정은 %sl 이벤트 코드를 사용한 이벤트에서 무시되어집니다."}
obj["mergeSwings"]				= { label="타격 병합", tooltip="짧은 시간 내에 가한 일반 근접딜러 타격을 병합합니다."}
obj["hideSkills"]				= { label="기술 이름 숨김", tooltip="받은, 대상이 받은 이벤트에서 기술 이름을 표시하지 않습니다.\n\n이 옵션을 사용하면 %s 이벤트 코드를 무시하므로 이벤트에 대한 사용자 설정이 무시되어질 것입니다."}
obj["hideNames"]				= { label="유닛 이름 숨김", tooltip="받은, 대상이 받은 이벤트에서 유닛 이름을 표시하지 않는다.\n\n이 옵션을 사용하면 %n 이벤트 코드를 무시하므로 이벤트에 대한 사용자 설정이 무시되어질 것입니다."}
obj["hideFullOverheals"]		= { label="최대 초과치유 숨김", tooltip="0의 치유량 효과를 가진 치유는 표시하지 않습니다."}
obj["hideMergeTrailer"]			= { label="요약 병합 숨김", tooltip="적중 및 치명타로 병합된 이벤트 마지막에 특정한 숫자 요약을 표시하지 않습니다."}
obj["lootedItems"]				= { label="획득한 아이템", tooltip="아이템을 획득했을때 알림 메세지를 표시합니다."}
obj["moneyGains"]				= { label="금전 획득", tooltip="당신의 금전 획득 사용."}
obj["alwaysShowQuestItems"]		= { label="퀘스트 아이템 항상 표시", tooltip="선택된 품질에 관계없이 퀘스트 아이템을 항상 표시합니다."}
obj["enableIcons"]				= { label="기술 아이콘 사용", tooltip="이벤트에 사용 가능한 기술 아이콘이 있을때 아이콘을 표시합니다."}



obj = L.DROPDOWNS
obj["profile"]				= { label="현재 프로필:", tooltip="현재 프로필을 설정합니다."}
obj["normalFont"]			= { label="보통 글꼴:", tooltip="치명타가 아닐때 사용할 글꼴을 설정합니다."}
obj["critFont"]				= { label="치명타 글꼴:", tooltip="치명타에 사용할 글꼴을 설정합니다."}
obj["normalOutline"]		= { label="보통 외곽선:", tooltip="치명타가 아닐때 사용할 글꼴의 외곽선을 설정합니다"}
obj["critOutline"]			= { label="치명타 외곽선:", tooltip="치명타에 사용할 글꼴의 외곽선을 설정합니다."}
obj["scrollArea"]			= { label="스크롤 영역:", tooltip="설정할 스크롤 영역을 선택합니다."}
obj["animationStyle"]		= { label="애니메이션 유형:", tooltip="스크롤 영역에 고정되지 않는 애니매이션 유형."}
obj["stickyAnimationStyle"]	= { label="고정 형태:", tooltip="스크롤 영역에 고정된 애니매이션 유형."}
obj["direction"]			= { label="방향:", tooltip="애니메이션의 방향."}
obj["behavior"]				= { label="움직임:", tooltip="애니메이션의 움직임."}
obj["textAlign"]			= { label="텍스트 정렬:", tooltip="애니메이션의 텍스트 정렬."}
obj["iconAlign"]			= { label="아이콘 정렬:", tooltip="문자와 관련된 기술 아이콘의 정렬."}
obj["eventCategory"]		= { label="이벤트 분류:", tooltip="설정하려는 이벤트 분류."}
obj["outputScrollArea"]		= { label="출력 스크롤 영역:", tooltip="출력에 사용할 스크롤 영역을 선택합니다."}



obj = L.BUTTONS
obj["copyProfile"]				= { label="프로필 복사", tooltip="명시된 이름의 새 프로필로 프로필을 복사합니다."}
obj["resetProfile"]				= { label="프로필 초기화", tooltip="기본 설정으로 프로필을 초기화합니다."}
obj["deleteProfile"]			= { label="프로필 삭제", tooltip="프로필을 삭제합니다."}
obj["masterFont"]				= { label="주 글꼴 설정", tooltip="모든 스크롤 영역과 이벤트에 상속 적용될(무시되지 않을 경우) 주 글꼴을 설정합니다."}
obj["partialEffects"]			= { label="부분 효과", tooltip="색상으로 표시할 부분 효과를 설정합니다."}
obj["damageColors"]				= { label="피해량 속성 색상", tooltip="피해 유형별 색상을 설정합니다."}
obj["classColors"]				= { label="직업 색상", tooltip="자신의 직업 및 각 직업에 대해 어떤 색상을 사용할 지에 대해 유닛 이름의 색상 코드를 설정합니다." }
obj["inputOkay"]				= { label=OKAY, tooltip="입력을 확인합니다."}
obj["inputCancel"]				= { label=CANCEL, tooltip="입력을 취소합니다."}
obj["genericSave"]				= { label=SAVE, tooltip="변경사항을 저장합니다."}
obj["genericCancel"]			= { label=CANCEL, tooltip="변경사항을 취소합니다."}
obj["addScrollArea"]			= { label="스크롤 영역 추가", tooltip="이벤트와 트리거를 지정할 수 있는 새 스크롤 영역을 추가합니다."}
obj["configScrollAreas"]		= { label="스크롤 영역 배치", tooltip="기본 및 고정 애니메이션 유형, 텍스트 정렬, 스크롤 넓이/높이, 스크롤 영역의 위치를 설정합니다."}
obj["editScrollAreaName"]		= { tooltip="스크롤 영역의 이름을 수정하려면 클릭하세요."}
obj["scrollAreaFontSettings"]	= { tooltip="스크롤 영역에 표시되는 모든 이벤트에 상속 적용될(무시되지 않을 경우) 글꼴 설정을 수정하려면 클릭하세요"}
obj["deleteScrollArea"]			= { tooltip="스크롤 영역을 삭제하려면 클릭하세요."}
obj["scrollAreasPreview"]		= { label="미리보기", tooltip="변경사항을 미리 봅니다."}
obj["toggleAll"]				= { label="모두 바꾸기", tooltip="선택한 분류의 모든 이벤트의 (비)활성화 상태를 반대로 바꿉니다."}
obj["moveAll"]					= { label="모두 이동", tooltip="선택한 분류의 모든 이벤트를 지정한 스크롤 영역으로 이동시킵니다."}
obj["eventFontSettings"]		= { tooltip="이벤트에 대한 글꼴 설정을 수정하려면 클릭하세요."}
obj["eventSettings"]			= { tooltip="스크롤 영역, 출력 메시지, 효과음 등과 같은 이벤트 설정을 수정하려면 클릭하세요."}
obj["itemsAllowed"]				= { label="허용된 아이템", tooltip="아이템 품질에 관계없이 특정한 아이템을 항상 표시합니다."}
obj["itemExclusions"]			= { label="제외 아이템", tooltip="특정한 아이템이 계속 표시되는 것으로부터 방지합니다."}
obj["addItem"]					= { label="아이템 추가", tooltip="목록에 새로운 아이템을 추가합니다."}
obj["deleteItem"]				= { tooltip="클릭하여 아이템을 삭제합니다."}



obj = L.EDITBOXES
obj["copyProfile"]		= { label="새 프로필 이름 입력:", tooltip="선택된 프로필로부터 복사될 새로운 프로필의 이름."}
obj["partialEffect"]	= { tooltip="부분 효과 발생 시 추가될 메세지."}
obj["scrollAreaName"]	= { label="새 스크롤 영역 이름 입력:", tooltip="새로운 스크롤 영역의 이름."}
obj["xOffset"]			= { label="X 좌표:", tooltip="선택된 스크롤 영역의 X 좌표."}
obj["yOffset"]			= { label="Y 좌표:", tooltip="선택된 스크롤 영역의 Y 좌표."}
obj["eventMessage"]		= { label="출력 메세지 입력:", tooltip="이벤트 발생시 출력되는 메세지."}
obj["iconSkill"]		= { label="기술 아이콘:", tooltip="이벤트 발생 시 아이콘을 표시할 기술의 이름입니다."}
obj["itemName"]			= { label="아이템 이름:", tooltip="추가시킬 아이템의 이름."}



obj = L.SLIDERS
obj["animationSpeed"]		= { label="애니메이션 속도", tooltip="기본 애니메이션 속도를 설정합니다..\n\n각 스크롤 영역은 각기 다른 속도로 설정될수도 있습니다.."}
obj["normalFontSize"]		= { label="보통 크기", tooltip="치명타가 아닐때 사용할 글꼴 크기를 설정합니다."}
obj["normalFontOpacity"]	= { label="보통 투명도", tooltip="치명타가 아닐때 사용할 글꼴 투명도를 설정합니다."}
obj["critFontSize"]			= { label="치명타 폰트 크기", tooltip="치명타에 사용할 글꼴 크기를 설정합니다."}
obj["critFontOpacity"]		= { label="치명타 폰트 간격", tooltip="치명타에 사용할 글꼴 투명도를 설정합니다."}
obj["scrollHeight"]			= { label="스크롤 높이", tooltip="스크롤 영역의 높이."}
obj["scrollWidth"]			= { label="스크롤 넓이", tooltip="스크롤 영역의 넓이."}
obj["scrollAnimationSpeed"]	= { label="애니메이션 속도", tooltip="스크롤 영역의 애니메이션 속도를 설정합니다."}
obj["dotThrottleTime"]		= { label="지속적인 피해량 (DoT) 출력시간", tooltip="지속적인 피해량 (DoT)을 출력하는 단위시간 (초)."}
obj["hotThrottleTime"]		= { label="지속적인 치유량 (HoT) 출력시간", tooltip="지속적인 치유량 (HoT)을 출력하는 단위시간 (초)."}
obj["powerThrottleTime"]	= { label="마력 변화 출력시간", tooltip="마력 (마나, 분노, 기력, 룬 마력) 변화를 출력하는 단위시간 (초)"}


obj = L.EVENT_CATEGORIES
obj[1] = "자신이 받은 메시지"
obj[2] = "자신이 받은 메시지 [소환수]"
obj[3] = "대상이 받은 메시지"
obj[4] = "대상이 받은 메시지 [소환수]"
obj[5] = "알림 메시지"



obj = L.EVENT_CODES
obj["DAMAGE_TAKEN"]			= "%a - 받은 피해량.\n"
obj["HEALING_TAKEN"]		= "%a - 받은 치유량.\n"
obj["DAMAGE_DONE"]			= "%a - 피해량.\n"
obj["HEALING_DONE"]			= "%a - 치유량.\n"
obj["ABSORBED_AMOUNT"]		= "%a - 피해 흡수량.\n"
obj["AURA_AMOUNT"]			= "%a - 오라에 대한 중첩량.\n"
obj["HONOR_AMOUNT"]			= "%a - 명예 점수.\n"
obj["REP_AMOUNT"]			= "%a - 평판 수치.\n"
obj["ITEM_AMOUNT"]			= "%a - 획득한 아이템 수량.\n"
obj["SKILL_AMOUNT"]			= "%a - 기술 점수.\n"
obj["EXPERIENCE_AMOUNT"]	= "%a - 획득한 경험치.\n"
obj["PARTIAL_AMOUNT"]		= "%a - 부분 효과 횟수.\n"
obj["ATTACKER_NAME"]		= "%n - 공격자 이름.\n"
obj["HEALER_NAME"]			= "%n - 치유자 이름.\n"
obj["ATTACKED_NAME"]		= "%n - 피해자 이름.\n"
obj["HEALED_NAME"]			= "%n - 치유 받은 유닛 이름.\n"
obj["BUFFED_NAME"]			= "%n - 버프 받은 유닛 이름.\n"
obj["UNIT_KILLED"]			= "%n - 죽은 유닛의 이름.\n"
obj["SKILL_NAME"]			= "%s - 기술의 이름.\n"
obj["SPELL_NAME"]			= "%s - 주문의 이름.\n"
obj["DEBUFF_NAME"]			= "%s - 디버프의 이름.\n"
obj["BUFF_NAME"]			= "%s - 버프의 이름.\n"
obj["ITEM_BUFF_NAME"]		= "%s - 아이템 버프의 이름.\n"
obj["EXTRA_ATTACKS"]		= "%s - 추가타 공격을 부여한 기술의 이름.\n"
obj["SKILL_LONG"]			= "%sl - %s의 긴 이름. 이벤트 설정에서 짧은 이름 사용 무시.\n"
obj["DAMAGE_TYPE_TAKEN"]	= "%t - 받은 피해량 속성.\n"
obj["DAMAGE_TYPE_DONE"]		= "%t - 피해량 속성.\n"
obj["ENVIRONMENTAL_DAMAGE"]	= "%e - 피해량 원인 (낙하, 호흡, 용암 등...)\n"
obj["FACTION_NAME"]			= "%e - 평판 이름.\n"
obj["EMOTE_TEXT"]			= "%e - 감정 표현 텍스트.\n"
obj["MONEY_TEXT"]			= "%e - 획득한 금전의 텍스트.\n"
obj["ITEM_NAME"]			= "%e - 획득한 아이템의 이름.\n"
obj["TOTAL_ITEMS"]			= "%t - 소지품 속 획득한 아이템의 합계."



obj = L.INCOMING_PLAYER_EVENTS
obj["INCOMING_DAMAGE"]						= { label="근접 평타", tooltip="자신이 받은 근접 평타를 활성화합니다."}
obj["INCOMING_DAMAGE_CRIT"]					= { label="근접 치명타", tooltip="자신이 받은 근접 치명타를 활성화합니다."}
obj["INCOMING_MISS"]						= { label="근접 빗나감", tooltip="자신에게 적중하지 않은 근접 공격을 활성화합니다."}
obj["INCOMING_DODGE"]						= { label="근접 회피", tooltip="자신의 근접 회피를 활성화합니다."}
obj["INCOMING_PARRY"]						= { label="근접 막음", tooltip="자신의 근접 막음을 활성화합니다."}
obj["INCOMING_BLOCK"]						= { label="근접 방어", tooltip="자신의 근접 방어를 활성화합니다."}
obj["INCOMING_DEFLECT"]						= { label="근접 튕김", tooltip="자신의 근접 튕김을 활성화합니다."}
obj["INCOMING_ABSORB"]						= { label="근접 흡수", tooltip="자신이 흡수한 근접 피해량을 활성화합니다."}
obj["INCOMING_IMMUNE"]						= { label="근접 면역", tooltip="자신에게 면역인 근접 공격을 활성화합니다."}
obj["INCOMING_SPELL_DAMAGE"]				= { label="주문 적중", tooltip="자신이 받은 주문 피해량을 활성화합니다."}
obj["INCOMING_SPELL_DAMAGE_CRIT"]			= { label="주문 치명상", tooltip="자신이 받은 주문의 치명상 피해량을 활성화합니다."}
obj["INCOMING_SPELL_DOT"]					= { label="주문 주기적 피해", tooltip="자신이 받은 주기적인 주문의 피해량을 활성화합니다."}
obj["INCOMING_SPELL_DOT_CRIT"]				= { label="주문 주기적 치명상 피해", tooltip="자신이 받은 주기적인 주문의 치명상 피해량을 활성화합니다."}
obj["INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="피해막 적중", tooltip="가시, 응보의 오라 등으로 자신이 받은 피해량을 활성화합니다."}
obj["INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="피해막 치명상", tooltip="가시, 응보의 오라 등으로 자신이 받은 치명상을 활성화합니다."}
obj["INCOMING_SPELL_MISS"]					= { label="주문 빗나감", tooltip="자신에게 적중하지 않은 주문 공격을 활성화합니다."}
obj["INCOMING_SPELL_DODGE"]					= { label="주문 회피", tooltip="자신의 주문 회피를 활성화합니다."}
obj["INCOMING_SPELL_PARRY"]					= { label="주문 막음", tooltip="자신의 주문 막음을 활성화합니다."}
obj["INCOMING_SPELL_BLOCK"]					= { label="주문 방어", tooltip="자신의 주문 방어를 활성화합니다."}
obj["INCOMING_SPELL_DEFLECT"]				= { label="주문 튕김", tooltip="자신의 주문 튕김을 활성화합니다."}
obj["INCOMING_SPELL_RESIST"]				= { label="주문 저항", tooltip="자신의 주문 저항을 활성화합니다."}
obj["INCOMING_SPELL_ABSORB"]				= { label="주문 흡수", tooltip="자신이 흡수한 주문 피해량을 활성화합니다."}
obj["INCOMING_SPELL_IMMUNE"]				= { label="주문 면역", tooltip="자신에게 면역인 주문 공격을 활성화합니다."}
obj["INCOMING_SPELL_REFLECT"]				= { label="주문 반사", tooltip="자신이 반사한 주문 피해량을 활성화합니다."}
obj["INCOMING_SPELL_INTERRUPT"]				= { label="주문 차단", tooltip="자신이 받은 주문 차단을 활성화합니다."}
obj["INCOMING_HEAL"]						= { label="치유", tooltip="자신이 받은 치유량을 활성화합니다."}
obj["INCOMING_HEAL_CRIT"]					= { label="치유 극대화", tooltip="자신이 받은 치유 극대화를 활성화합니다."}
obj["INCOMING_HOT"]							= { label="주기적 치유", tooltip="자신이 받은 주기적 치유를 활성화합니다."}
obj["INCOMING_HOT_CRIT"]					= { label="주기적 치유 극대화", tooltip="자신의 받은 주기적 치유 극대화를 활성화합니다."}
obj["INCOMING_ENVIRONMENTAL"]				= { label="환경 피해", tooltip="자신이 받은 환경 피해 (낙하, 호흡, 용암 등...)를 활성화 합니다."}

obj = L.INCOMING_PET_EVENTS
obj["PET_INCOMING_DAMAGE"]						= { label="근접 평타", tooltip="소환수가 받은 근접 평타 활성화합니다."}
obj["PET_INCOMING_DAMAGE_CRIT"]					= { label="근접 치명타", tooltip="소환수가 받은 근접 치명타를 활성화합니다."}
obj["PET_INCOMING_MISS"]						= { label="근접 빗나감", tooltip="소환수에게 적중하지 않은 근접 공격을 활성화합니다."}
obj["PET_INCOMING_DODGE"]						= { label="근접 회피", tooltip="소환수의 근접 회피를 활성화합니다."}
obj["PET_INCOMING_PARRY"]						= { label="근접 막음", tooltip="소환수의 근접 막음을 활성화합니다."}
obj["PET_INCOMING_BLOCK"]						= { label="근접 방어", tooltip="소환수의 근접 방어를 활성화합니다."}
obj["PET_INCOMING_DEFLECT"]						= { label="근접 튕김", tooltip="소환수의 근접 튕김을 활성화합니다."}
obj["PET_INCOMING_ABSORB"]						= { label="근접 흡수", tooltip="소환수가 흡수한 근접 피해량을 활성화합니다."}
obj["PET_INCOMING_IMMUNE"]						= { label="근접 면역", tooltip="소환수에게 면역인 근접 공격을 활성화합니다."}
obj["PET_INCOMING_SPELL_DAMAGE"]				= { label="주문 적중", tooltip="소환수가 받은 주문 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_DAMAGE_CRIT"]			= { label="주문 치명상", tooltip="소환수가 받은 주문의 치명상 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_DOT"]					= { label="주문 주기적 피해", tooltip="소환수가 받은 주기적인 주문 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_DOT_CRIT"]				= { label="주문 주기적 치명상 피해", tooltip="소환수가 받은 주기적인 주문의 치명상 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD"]			= { label="피해막 적중", tooltip="가시, 응보의 오라 등으로 소환수가 받은 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="피해막 치명상", tooltip="가시, 응보의 오라 등으로 소환수가 받은 치명상 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_MISS"]					= { label="주문 공격 빗나감", tooltip="소환수에게 적중하지 않은 주문 공격을 활성화합니다."}
obj["PET_INCOMING_SPELL_DODGE"]					= { label="주문 회피", tooltip="소환수의 주문 회피를 활성화합니다."}
obj["PET_INCOMING_SPELL_PARRY"]					= { label="주문 막음", tooltip="소환수의 주문 막음을 활성화합니다."}
obj["PET_INCOMING_SPELL_BLOCK"]					= { label="주문 방어", tooltip="소환수의 주문 방어를 활성화합니다."}
obj["PET_INCOMING_SPELL_DEFLECT"]				= { label="주문 튕김", tooltip="소환수의 주문 튕김을 활성화합니다."}
obj["PET_INCOMING_SPELL_RESIST"]				= { label="주문 저항", tooltip="소환수의 주문 저항을 활성화합니다."}
obj["PET_INCOMING_SPELL_ABSORB"]				= { label="주문 흡수", tooltip="소환수가 흡수한 주문 피해량을 활성화합니다."}
obj["PET_INCOMING_SPELL_IMMUNE"]				= { label="주문 면역", tooltip="소환수에게 면역인 주문 공격를 활성화합니다."}
obj["PET_INCOMING_HEAL"]						= { label="치유", tooltip="소환수가 받은 치유량을 활성화합니다."}
obj["PET_INCOMING_HEAL_CRIT"]					= { label="치유 극대화", tooltip="소환수가 받은 치유 극대화를 활성화합니다."}
obj["PET_INCOMING_HOT"]							= { label="주기적 치유", tooltip="소환수가 받은 주기적 치유를 활성화합니다."}
obj["PET_INCOMING_HOT_CRIT"]					= { label="주기적 치유 극대화", tooltip="소환수가 받은 받은 주기적 치유 극대화를 활성화합니다."}



obj = L.OUTGOING_PLAYER_EVENTS
obj["OUTGOING_DAMAGE"]						= { label="근접 평타", tooltip="대상이 받은 근접 평타를 활성화합니다."}
obj["OUTGOING_DAMAGE_CRIT"]					= { label="근접 치명타", tooltip="대상이 받은 근접 치명타를 활성화합니다."}
obj["OUTGOING_MISS"]						= { label="근접 빗나감", tooltip="대상에게 적중하지 않은 근접 공격을 활성화합니다."}
obj["OUTGOING_DODGE"]						= { label="근접 회피", tooltip="근접 공격에 대한 대상의 회피를 활성화합니다."}
obj["OUTGOING_PARRY"]						= { label="근접 막음", tooltip="근접 공격에 대한 대상의 막음을 활성화합니다."}
obj["OUTGOING_BLOCK"]						= { label="근접 방어", tooltip="근접 공격에 대한 대상의 방어를 활성화합니다."}
obj["OUTGOING_DEFLECT"]						= { label="근접 튕김", tooltip="근접 공격에 대한 대상의 튕김을 활성화합니다."}
obj["OUTGOING_ABSORB"]						= { label="근접 흡수", tooltip="근접 공격에 대하여 대상이 흡수한 피해량을 활성화합니다."}
obj["OUTGOING_IMMUNE"]						= { label="근접 면역", tooltip="근접 공격에 대한 대상의 면역을 활성화합니다."}
obj["OUTGOING_EVADE"]						= { label="근접 벗어남", tooltip="대상에게 벗어난 근접 공격을 활성화합니다."}
obj["OUTGOING_SPELL_DAMAGE"]				= { label="주문 적중", tooltip="대상이 받은 주문 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="주문 치명타", tooltip="대상이 받은 주문의 치명상 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_DOT"]					= { label="주문 주기적 피해", tooltip="대상이 받은 주기적인 주문 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_DOT_CRIT"]				= { label="주문 주기적 치명상 피해", tooltip="대상이 받은 주기적인 주문의 치명상 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="피해막 적중", tooltip="가시, 응보의 오라 등으로 대상이 받은 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="피해막 치명타", tooltip="가시, 응보의 오라 등으로 대상이 받은 치명상 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_MISS"]					= { label="주문 빗나감", tooltip="대상에게 적중하지 않은 주문 공격을 활성화합니다."}
obj["OUTGOING_SPELL_DODGE"]					= { label="주문 회피", tooltip="주문 공격에 대한 대상의 회피를 활성화합니다."}
obj["OUTGOING_SPELL_PARRY"]					= { label="주문 막음", tooltip="주문 공격에 대한 대상의 막음을 활성화합니다."}
obj["OUTGOING_SPELL_BLOCK"]					= { label="주문 방어", tooltip="주문 공격에 대한 대상의 방어를 활성화합니다."}
obj["OUTGOING_SPELL_DEFLECT"]				= { label="주문 튕김", tooltip="주문 공격에 대한 대상의 튕김을 활성화합니다."}
obj["OUTGOING_SPELL_RESIST"]				= { label="주문 저항", tooltip="주문 공격에 대한 대상의 저항을 활성화합니다."}
obj["OUTGOING_SPELL_ABSORB"]				= { label="주문 흡수", tooltip="주문 공격에 대하여 대상이 흡수한 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_IMMUNE"]				= { label="주문 면역", tooltip="주문 공격에 대한 대상의 면역을 활성화합니다."}
obj["OUTGOING_SPELL_REFLECT"]				= { label="주문 반사", tooltip="주문 공격에 대하여 대상이 반사한 피해량을 활성화합니다."}
obj["OUTGOING_SPELL_INTERRUPT"]				= { label="주문 차단", tooltip="대상이 받은 주문 차단을 활성화합니다."}
obj["OUTGOING_SPELL_EVADE"]					= { label="주문 벗어남", tooltip="대상에게 벗어난 주문 공격을 활성화합니다."}
obj["OUTGOING_HEAL"]						= { label="치유", tooltip="대상이 받은 치유량을 활성화합니다."}
obj["OUTGOING_HEAL_CRIT"]					= { label="치유 극대화", tooltip="대상이 받은 치유 극대화를 활성화합니다."}
obj["OUTGOING_HOT"]							= { label="주기적 치유", tooltip="대상이 받은 주기적 치유를 활성화합니다."}
obj["OUTGOING_HOT_CRIT"]					= { label="주기적 치유 극대화", tooltip="대상이 받은 주기적 치유 극대화를 활성화합니다."}
obj["OUTGOING_DISPEL"]						= { label="해제", tooltip="대상이 받은 해제를 활성화합니다."}

obj = L.OUTGOING_PET_EVENTS
obj["PET_OUTGOING_DAMAGE"]						= { label="근접 평타", tooltip="소환수가 대상에게 준 근접 평타를 활성화합니다."}
obj["PET_OUTGOING_DAMAGE_CRIT"]					= { label="근접 치명타", tooltip="소환수가 대상에게 준 근접 치명타를 활성화합니다."}
obj["PET_OUTGOING_MISS"]						= { label="근접 빗나감", tooltip="대상에게 적중하지 않은 소환수의 근접 공격을 활성화합니다."}
obj["PET_OUTGOING_DODGE"]						= { label="근접 회피", tooltip="소환수의 근접 공격에 대한 대상의 회피를 활성화합니다."}
obj["PET_OUTGOING_PARRY"]						= { label="근접 막음", tooltip="소환수의 근접 공격에 대한 대상의 막음을 활성화합니다."}
obj["PET_OUTGOING_BLOCK"]						= { label="근접 방어", tooltip="소환수의 근접 공격에 대한 대상의 방어를 활성화합니다."}
obj["PET_OUTGOING_DEFLECT"]						= { label="근접 튕김", tooltip="소환수의 근접 공격에 대한 대상의 튕김을 활성화합니다."}
obj["PET_OUTGOING_ABSORB"]						= { label="근접 흡수", tooltip="소환수의 근접 공격에 대하여 대상이 흡수한 피해량을 활성화합니다."}
obj["PET_OUTGOING_IMMUNE"]						= { label="근접 면역", tooltip="소환수의 근접 공격에 대한 대상의 면역을 활성화합니다."}
obj["PET_OUTGOING_EVADE"]						= { label="근접 벗어남", tooltip="대상에게 벗어난 소환수의 근접 공격을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DAMAGE"]				= { label="주문 적중", tooltip="소환수가 대상에게 준 주문 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DAMAGE_CRIT"]			= { label="주문 치명타", tooltip="소환수가 대상에게 준 주문의 치명상 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DOT"]					= { label="주문 주기적 피해", tooltip="소환수가 대상에게 준 주기적인 주문 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DOT_CRIT"]				= { label="주문 주기적 치명상 피해", tooltip="소환수가 대상에게 준 주기적인 주문의 치명상 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD"]			= { label="피해막 적중", tooltip="가시, 응보의 오라 등으로 소환수가 대상에게 준 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT"]	= { label="피해막 치명타", tooltip="가시, 응보의 오라 등으로 소환수가 대상에게 준 치명상 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_MISS"]					= { label="주문 빗나감", tooltip="대상에게 적중하지 않은 소환수의 주문 공격을 활성화합니다."}
obj["PET_OUTGOING_SPELL_DODGE"]					= { label="주문 회피", tooltip="소환수의 주문 공격에 대한 대상의 회피를 활성화합니다."}
obj["PET_OUTGOING_SPELL_PARRY"]					= { label="주문 막음", tooltip="소환수의 주문 공격에 대한 대상의 막음을 활성화합니다."}
obj["PET_OUTGOING_SPELL_BLOCK"]					= { label="주문 방어", tooltip="소환수의 주문 공격에 대한 대상의 방어를 활성화합니다."}
obj["PET_OUTGOING_SPELL_DEFLECT"]				= { label="주문 튕김", tooltip="소환수의 주문 공격에 대한 대상의 튕김을 활성화합니다."}
obj["PET_OUTGOING_SPELL_RESIST"]				= { label="주문 저항", tooltip="소환수의 주문 공격에 대한 대상의 저항을 활성화합니다."}
obj["PET_OUTGOING_SPELL_ABSORB"]				= { label="주문 흡수", tooltip="소환수의 주문 공격에 대하여 대상이 흡수한 피해량을 활성화합니다."}
obj["PET_OUTGOING_SPELL_IMMUNE"]				= { label="주문 면역", tooltip="소환수의 주문 공격에 대한 대상의 면역을 활성화합니다."}
obj["PET_OUTGOING_SPELL_EVADE"]					= { label="주문 벗어남", tooltip="대상에게 벗어난 소환수의 주문 공격을 활성화합니다."}
obj["PET_OUTGOING_HEAL"]						= { label="치유", tooltip="소환수가 받은 치유량을 활성화합니다."}
obj["PET_OUTGOING_HEAL_CRIT"]					= { label="치유 극대화", tooltip="소환수가 받은 치유 극대화를 활성화합니다."}
obj["PET_OUTGOING_HOT"]							= { label="주기적 치유", tooltip="소환수가 받은 주기적 치유를 활성화합니다."}
obj["PET_OUTGOING_HOT_CRIT"]					= { label="주기적 치유 극대화", tooltip="소환수가 받은 주기적 치유 극대화를 활성화합니다."}
obj["PET_OUTGOING_DISPEL"]						= { label="해제", tooltip="소환수의 해제를 활성화합니다."}



obj = L.NOTIFICATION_EVENTS
obj["NOTIFICATION_DEBUFF"]				= { label="디버프", tooltip="당신이 걸린 디버프를 알려줍니다."}
obj["NOTIFICATION_DEBUFF_STACK"]		= { label="중첩 디버프", tooltip="당신이 걸린 중첩 디버프를 알려줍니다."}
obj["NOTIFICATION_BUFF"]				= { label="버프", tooltip="당신이 받은 버프를 알려줍니다."}
obj["NOTIFICATION_BUFF_STACK"]			= { label="중첩 버프", tooltip="당신이 받은 중첩 버프를 알려줍니다."}
obj["NOTIFICATION_ITEM_BUFF"]			= { label="아이템 버프", tooltip="당신이 받은 아이템 버프를 알려줍니다."}
obj["NOTIFICATION_DEBUFF_FADE"]			= { label="디버프 사라짐", tooltip="사라진 디버프를 알려줍니다."}
obj["NOTIFICATION_BUFF_FADE"]			= { label="버프 사라짐", tooltip="사라진 버프를 알려줍니다."}
obj["NOTIFICATION_ITEM_BUFF_FADE"]		= { label="아이템 버프 사라짐", tooltip="사라진 아이템 버프를 알려줍니다."}
obj["NOTIFICATION_COMBAT_ENTER"]		= { label="전투 시작", tooltip="전투 상태 시작을 알려줍니다."}
obj["NOTIFICATION_COMBAT_LEAVE"]		= { label="전투 종료", tooltip="전투 상태 종료를 알려줍니다."}
obj["NOTIFICATION_HONOR_GAIN"]			= { label="명예 획득", tooltip="명예 점수 획득을 알려줍니다.."}
obj["NOTIFICATION_REP_GAIN"]			= { label="평판 상승", tooltip="평판 수치 획득을 알려줍니다.."}
obj["NOTIFICATION_REP_LOSS"]			= { label="평판 하락", tooltip="평판 수치 감소를 알려줍니다."}
obj["NOTIFICATION_SKILL_GAIN"]			= { label="기술 획득", tooltip="기술 점수 획득을 알려줍니다."}
obj["NOTIFICATION_EXPERIENCE_GAIN"]		= { label="경험치 획득", tooltip="경험치 획득을 알려줍니다."}
obj["NOTIFICATION_PC_KILLING_BLOW"]		= { label="플레이어 결정타", tooltip="적대적 대상에 대해 결정타를 입혔을때 알려줍니다."}
obj["NOTIFICATION_NPC_KILLING_BLOW"]	= { label="NPC 결정타", tooltip="NPC에 대해 결정타를 입혔을때 알려줍니다."}
obj["NOTIFICATION_EXTRA_ATTACK"]		= { label="추가타 공격", tooltip="추가타 공격 (우뢰 폭풍, 도검 전문화 등.) 효과를 얻었음을 알려줍니다."}
obj["NOTIFICATION_ENEMY_BUFF"]			= { label="적의 버프 획득", tooltip="당신의 적대적 대상이 버프를 획득하면 알려줍니다."}
obj["NOTIFICATION_MONSTER_EMOTE"]		= { label="몬스터 감정표현", tooltip="당신의 대상 몬스터의 감정 표현을 알려줍니다."}



obj = L.OUTLINES
obj[1] = "없음"
obj[2] = "얇게"
obj[3] = "굵게"

obj = L.TEXT_ALIGNS
obj[1] = "왼쪽"
obj[2] = "가운데"
obj[3] = "오른쪽"






obj = L.ANIMATION_STYLE_DATA
obj["Angled"]		= "각도"
obj["Horizontal"]	= "수평"
obj["Parabola"]		= "포물선"
obj["Straight"]		= "직선"
obj["Static"]		= "고정"
obj["Pow"]			= "타격 효과"

obj["Alternate"]	= "교차"
obj["Left"]			= "좌로"
obj["Right"]		= "우로"
obj["Up"]			= "위로"
obj["Down"]			= "아래로"

obj["AngleUp"]			= "상향 각도로"
obj["AngleDown"]		= "하향 각도로"
obj["GrowUp"]			= "위로 확장"
obj["GrowDown"]			= "아래로 확장"
obj["CurvedLeft"]		= "좌로 휘어짐"
obj["CurvedRight"]		= "우로 휘어짐"
obj["Jiggle"]			= "흔들림"
obj["Normal"]			= "효과 없음"

L.MSG_INVALID_CUSTOM_SOUND_NAME		= "잘못된 소리 이름."
L.MSG_SOUND_NAME_ALREADY_EXISTS		= "소리 이름이 이미 존재합니다."
L.MSG_INVALID_SOUND_FILE			= "효과음은 .ogg 파일이어야 합니다."
L.CHECKBOXES["enableSounds"]				= { label="효과음 사용", tooltip="이벤트와 트리거에 지정된 효과음을 재생합니다."}
L.DROPDOWNS["sound"]				= { label="효과음:", tooltip="이벤트 발생 시 재생할 효과음을 선택하세요."}
L.BUTTONS["addCustomSound"]			= { label="소리 추가", tooltip="사용할 수 있는 소리의 목록에 사용자 소리을 추가합니다.\n\n주의: 와우가 시작됨 *이전에* 소리 파일이 대상의 위치에 존재해야합니다.\n\n문제가 발생되지 않도록 하려면 글꼴은 MikScrollingBattleText\\Sounds 폴더에 넣어두는 것이 좋습니다."}
L.BUTTONS["customSound"]				= { tooltip="사용자 지정 효과음 파일을 입력하려면 클릭하세요." }
L.BUTTONS["playSound"]				= { label="재생", tooltip="선택된 효과음을 재생하려면 클릭하세요."}
L.EDITBOXES["customSoundName"]	= { label="소리 이름:", tooltip="이름은 소리를 식별하는데 사용합니다.\n\n사용예: 나의 소리"}
L.EDITBOXES["customSoundPath"]	= { label="소리 경로:", tooltip="소리 파일이 있는 경로.\n\n노트: 만약 파일이 권장하는 MikScrollingBattleText\\Sounds 폴더 위치에 있으면, 여기엔 오로지 전체 경로 대신 파일 이름을 입력해야 됩니다.\n\n사용예: mySound.ogg "}
L.EDITBOXES["soundFile"]		= { label="효과음 파일명:", tooltip="이벤트 발생시 재생할 효과음 파일."}

-- Recent feature translations (2026-11-13).
L.POPUP_CONFIRM_TITLE = "작업 확인"
L.AURA_TRACKING_TITLE = "위에 사용자 지정 오라가 표시됩니다. 선택을 해제하면 숨깁니다."
L.AURA_TRACKING_INPUT = "오라 주문 ID 또는 이름"
L.AURA_TRACKING_ADD = "오라 추가"
L.AURA_TRACKING_HELP = "표시된 정확한 이름을 입력하면 모든 등급의 오라 획득 및 사라짐 알림을 숨깁니다. 주문 ID는 해당 ID만 숨깁니다. " ..
    "이름의 철자를 확인하세요. 클라이언트가 지원하면 이름 규칙으로 보호된 오라 글자와 아이콘도 숨깁니다. 이렇게 검사한 모든 " ..
    "보호된 오라는 소리가 나지 않습니다. ID 규칙은 읽을 수 있는 주문 ID가 필요합니다. 다시 선택하면 오라를 표시합니다."
L.AURA_TRACKING_ALL_RANKS = "모든 등급"
L.AURA_TRACKING_CHECKBOX = "이 오라의 획득 및 사라짐 알림을 표시합니다."
L.AURA_TRACKING_REMOVE = "이 규칙을 삭제하고 오라를 일반적으로 추적합니다."
L.AURA_TRACKING_UNKNOWN = "알 수 없는 오라"
L.AURA_TRACKING_INVALID = "유효한 주문 ID 또는 표시된 정확한 주문 이름을 입력하세요."
L.RESOURCE_CHECKBOX_TITLE = "자원"
L.RESOURCE_CHECKBOX_HELP = "현재 직업, 전문화 또는 변신 상태에서 사용하는 이 자원의 획득을 표시합니다."
L.RESOURCE_CHECKBOX_SOUND = "숨겨진 자원 유형을 필터링해야 하면 자원 소리가 재생되지 않습니다."
L.RESOURCE_COMBO_POINT = "연계 점수"
L.MSG_SOUND_PLAYBACK_FAILED = "소리를 재생할 수 없습니다. 파일 경로를 확인하고 새 소리 파일을 추가한 뒤 WoW를 재시작하세요."
L.MSG_INVALID_SOUND_FILE = "소리는 .mp3 또는 .ogg 파일이어야 합니다."
L.LANGUAGE_CURRENT = "현재 게임 언어: %s (%s)"
L.LANGUAGE_INFO = "MSBT는 게임 언어를 사용합니다. 다른 언어를 사용하려면 Battle.net 앱에서 게임 언어를 변경한 뒤 WoW를 " ..
    "재시작하세요."
L.RESET_BLIZZARD_INFO = "직접 피해, 주기적 피해 및 소환수 피해에 대한 블리자드 전투 메시지를 복원합니다. 블리자드 피해 표시를 켜고 MSBT를 " ..
    "끕니다. 일반 설정에서 두 옵션을 따로 변경할 수 있습니다."
L.MSG_BLIZZARD_TEXT_RESTORED = "블리자드 전투 메시지를 복원했습니다."

L.TABS.profile.label = "프로필"
L.TABS.profile.tooltip = "프로필을 관리하고 전환합니다."
L.TABS.sounds.label = "소리"
L.TABS.sounds.tooltip = "이벤트 소리를 설정하고 사용자 지정 소리 파일을 추가합니다."
L.TABS.language.label = "언어"
L.TABS.language.tooltip = "현재 게임 언어와 MSBT의 언어 설정 방법을 표시합니다."
L.TABS.resetBlizzardSCT.label = "블리자드 전투 메시지 초기화"
L.TABS.resetBlizzardSCT.tooltip = "블리자드 피해 표시를 켜고 MSBT를 끕니다."

L.CHECKBOXES.enableMSBT.label = "Mik's Scrolling Battle Text 사용"
L.CHECKBOXES.enableMSBT.tooltip = "MSBT를 켜고 모든 블리자드 전투 메시지를 끕니다."
L.CHECKBOXES.enableBlizzardDamage.label = "블리자드 전투 메시지 사용"
L.CHECKBOXES.enableBlizzardDamage.tooltip = "아래에서 선택한 분류에 따라 블리자드 전투 메시지를 표시합니다."
L.CHECKBOXES.disableIncoming.label = "받는 효과 표시 안 함"
L.CHECKBOXES.disableIncoming.tooltip = "이 시스템에서 받은 피해와 치유를 숨깁니다."
L.CHECKBOXES.disableOutgoing.label = "주는 효과 표시 안 함"
L.CHECKBOXES.disableOutgoing.tooltip = "이 시스템에서 준 피해와 치유를 숨깁니다."
L.CHECKBOXES.disableNotifications.label = "알림 표시 안 함"
L.CHECKBOXES.disableNotifications.tooltip = "이 시스템의 강화 효과, 전투 알림 및 기타 알림을 숨깁니다."
L.CHECKBOXES.enableNames.label = "기술 이름 표시"
L.CHECKBOXES.enableNames.tooltip = "받거나 주는 효과의 기술 이름을 표시합니다."
L.CHECKBOXES.lowHealthSound.label = "생명력 부족 경고음"
L.CHECKBOXES.lowHealthSound.tooltip = "생명력 부족 경고음을 10초에 한 번 이하로 재생합니다. 선택을 해제해도 글자 경고는 표시됩니다."
L.CHECKBOXES.lowManaSound.label = "마나 부족 경고음"
L.CHECKBOXES.lowManaSound.tooltip = "마나 부족 경고음을 10초에 한 번 이하로 재생합니다. 선택을 해제해도 글자 경고는 표시됩니다."
L.CHECKBOXES.shortenNumbers.label = "숫자 줄이기"
L.CHECKBOXES.shortenNumbers.tooltip = "숫자를 줄여 표시합니다. 예: 32765 → 33k."
L.CHECKBOXES.groupNumbers.label = "천 단위 구분"
L.CHECKBOXES.groupNumbers.tooltip = "숫자를 천 단위로 구분합니다. 예: 32765 → 32,765."
L.CHECKBOXES.stackSimilarHits.label = "같은 기술 피해 묶기"
L.CHECKBOXES.stackSimilarHits.tooltip = "같은 기술이 짧은 시간 안에 여러 번 적중하면 적중 또는 치명타 횟수를 덧붙입니다. 한 번 적중하면 횟수를 표시하지 " ..
    "않습니다."
L.CHECKBOXES.currencyGains.label = "화폐 획득"
L.CHECKBOXES.currencyGains.tooltip = "화폐 획득 알림을 표시합니다."

L.BUTTONS.resetBlizzardSCT.label = "블리자드 전투 메시지 초기화"
L.BUTTONS.resetBlizzardSCT.tooltip = "블리자드 전투 메시지 설정을 복원하고 MSBT가 해당 설정을 변경하지 않도록 합니다."

L.NOTIFICATION_EVENTS.NOTIFICATION_RESOURCE_GAIN.label = "자원 획득"
L.NOTIFICATION_EVENTS.NOTIFICATION_RESOURCE_GAIN.tooltip = "기술과 효과가 보고한 자원 획득을 표시합니다."
L.NOTIFICATION_EVENTS.NOTIFICATION_ITEM_COOLDOWN.label = "아이템 준비 완료"
L.NOTIFICATION_EVENTS.NOTIFICATION_ITEM_COOLDOWN.tooltip = "사용한 장신구나 물약의 재사용 대기시간이 끝나면 알립니다."
L.NOTIFICATION_EVENTS.NOTIFICATION_CROWD_CONTROL.label = "군중 제어"
L.NOTIFICATION_EVENTS.NOTIFICATION_CROWD_CONTROL.tooltip = "군중 제어 효과와 시전 방해를 표시합니다."
L.NOTIFICATION_EVENTS.NOTIFICATION_PROC.label = "기술 발동"
L.NOTIFICATION_EVENTS.NOTIFICATION_PROC.tooltip = "강조 표시된 기술 발동을 표시합니다."
L.NOTIFICATION_EVENTS.NOTIFICATION_REACTIVE.label = "사용 가능한 기술"
L.NOTIFICATION_EVENTS.NOTIFICATION_REACTIVE.tooltip = "전투 중 사용 가능해진 기술을 표시합니다."
L.NOTIFICATION_EVENTS.NOTIFICATION_PC_KILLING_BLOW.label = "플레이어 결정타"
L.NOTIFICATION_EVENTS.NOTIFICATION_PC_KILLING_BLOW.tooltip = "적대적 플레이어에게 결정타를 가하면 알립니다."
L.NOTIFICATION_EVENTS.NOTIFICATION_NPC_KILLING_BLOW.label = "NPC 결정타"
L.NOTIFICATION_EVENTS.NOTIFICATION_NPC_KILLING_BLOW.tooltip = "NPC 또는 유형을 알 수 없는 대상에게 가한 결정타를 표시합니다."

L.INCOMING_PLAYER_EVENTS.SELF_HEAL.label = "자신 치유"
L.INCOMING_PLAYER_EVENTS.SELF_HEAL.tooltip = "자신에게 한 치유를 표시합니다."
L.INCOMING_PLAYER_EVENTS.SELF_HEAL_CRIT.label = "자신 치유 치명타"
L.INCOMING_PLAYER_EVENTS.SELF_HEAL_CRIT.tooltip = "자신에게 한 치유 치명타를 표시합니다."
L.INCOMING_PLAYER_EVENTS.SELF_HOT.label = "자신 주기적 치유"
L.INCOMING_PLAYER_EVENTS.SELF_HOT.tooltip = "자신에게 한 지속 치유를 표시합니다."
L.INCOMING_PLAYER_EVENTS.SELF_HOT_CRIT.label = "자신 주기적 치유 치명타"
L.INCOMING_PLAYER_EVENTS.SELF_HOT_CRIT.tooltip = "자신에게 한 지속 치유 치명타를 표시합니다."

L.PROFILE_TRANSFER.exportTitle = "프로필 내보내기"
L.PROFILE_TRANSFER.importTitle = "프로필 가져오기"
L.PROFILE_TRANSFER.export = "내보내기"
L.PROFILE_TRANSFER.import = "가져오기"
L.PROFILE_TRANSFER.close = "닫기"
L.PROFILE_TRANSFER.selectAll = "모두 선택"
L.PROFILE_TRANSFER.name = "2. 새 프로필 이름 지정"
L.PROFILE_TRANSFER.copy = "복사 (Ctrl+C)"
L.PROFILE_TRANSFER.exportLabel = "프로필 문자열"
L.PROFILE_TRANSFER.importLabel = "1. 프로필 문자열 붙여넣기"
L.PROFILE_TRANSFER.importAction = "프로필 가져오기"
L.PROFILE_TRANSFER.pasteHint = "여기를 클릭하고 Ctrl+V를 눌러 프로필 문자열을 붙여넣으세요."
L.PROFILE_TRANSFER.exportHelp = "Ctrl+C를 눌러 선택한 프로필 문자열을 복사하세요."
L.PROFILE_TRANSFER.importHelp = "프로필 문자열을 붙여넣고 새 이름을 입력하세요. 가져오면 새 프로필이 생성되고 선택됩니다."
L.PROFILE_TRANSFER.mediaNote = "사용자 지정 글꼴과 소리 파일은 따로 설치해야 합니다. 게임 버전이나 언어에 따라 설정과 주문이 다를 수 있습니다."
L.PROFILE_TRANSFER.imported = "가져온 프로필: %s"
L.PROFILE_TRANSFER.compatibility = "이 프로필은 다른 게임 버전이나 언어에서 만들었습니다. 주문 설정, 조건, 글꼴 및 소리를 확인하세요."
L.PROFILE_TRANSFER.errors.INVALID_NAME = "프로필 이름을 1~64자로 입력하세요."
L.PROFILE_TRANSFER.errors.PROFILE_EXISTS = "이미 있는 프로필입니다. 다른 이름을 선택하세요."
L.PROFILE_TRANSFER.errors.INVALID_TEXT = "유효하지 않거나 손상된 프로필 문자열입니다. 내보낸 문자열 전체를 복사하세요."
L.PROFILE_TRANSFER.errors.INVALID_DATA = "프로필에 유효하지 않거나 지원하지 않는 설정이 있습니다."
L.PROFILE_TRANSFER.errors.TOO_LARGE = "프로필이 지원하는 전송 크기를 초과합니다."
L.PROFILE_TRANSFER.errors.IN_COMBAT = "전투가 끝난 뒤 프로필을 가져오세요."
L.EVENT_CODES.RESOURCE_AMOUNT = "%a - 획득한 자원의 양.\n"
L.EVENT_CODES.RESOURCE_NAME = "%p - 자원 이름.\n"
