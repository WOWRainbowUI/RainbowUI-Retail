-- koKR.lua (Korean)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "koKR")
if not L then return end

-- Core
L["Cannot open options in combat."] = "전투 중에는 옵션을 열 수 없습니다."
L["MiniCC test command is unavailable."] = "MiniCC 테스트 명령을 사용할 수 없습니다."

-- Category Names
L["Action Bars"] = "행동 단축바"
L["Nameplates"] = "이름표"
L["Unit Frames"] = "유닛 프레임"
L["CooldownManager"] = "CooldownManager"
L["MiniCC"] = "MiniCC"
L["Others"] = "기타"

-- Group Headers
L["General"] = "일반"
L["Typography (Cooldown Numbers)"] = "글꼴 (재사용 대기시간 숫자)"
L["Swipe Animation"] = "스와이프 애니메이션"
L["Stack Counters / Charges"] = "중첩 수 / 충전"
L["Maintenance"] = "유지보수"
L["Danger Zone"] = "위험 구역"
L["Style"] = "스타일"
L["Positioning"] = "위치"
L["CooldownManager Viewers"] = "CooldownManager 뷰어"
L["MiniCC Frame Types"] = "MiniCC 프레임 유형"

-- Toggles & Settings
L["Enable %s"] = "%s 활성화"
L["Toggle styling for this category."] = "이 카테고리의 스타일 적용을 켜거나 끕니다."
L["Font Face"] = "글꼴"
L["Font"] = "글꼴"
L["Size"] = "크기"
L["Outline"] = "외곽선"
L["Color"] = "색상"
L["Hide Numbers"] = "숫자 숨기기"
L["Compact Party / Raid Aura Text"] = "파티/공격대 간소형 오라 텍스트"
L["Enable Party Aura Text"] = "파티 오라 텍스트 활성화"
L["Enable Raid Aura Text"] = "공격대 오라 텍스트 활성화"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "텍스트를 완전히 숨깁니다. 스와이프 가장자리나 중첩만 보고 싶을 때 유용합니다."
L["Shows styled countdown text on Blizzard CompactPartyFrame buff and debuff icons. Disabling this hides aura countdown text on party frames."] = "Blizzard CompactPartyFrame의 강화 및 약화 효과 아이콘에 스타일이 적용된 카운트다운 텍스트를 표시합니다. 끄면 파티 프레임의 오라 카운트다운 텍스트가 숨겨집니다."
L["Shows styled countdown text on Blizzard CompactRaidFrame buff and debuff icons. Disabling this hides aura countdown text on raid frames."] = "Blizzard CompactRaidFrame의 강화 및 약화 효과 아이콘에 스타일이 적용된 카운트다운 텍스트를 표시합니다. 끄면 공격대 프레임의 오라 카운트다운 텍스트가 숨겨집니다."
L["Anchor Point"] = "고정점"
L["Offset X"] = "X 오프셋"
L["Offset Y"] = "Y 오프셋"
L["Essential Viewer Size"] = "Essential 뷰어 크기"
L["Utility Viewer Size"] = "Utility 뷰어 크기"
L["Buff Icon Viewer Size"] = "버프 아이콘 뷰어 크기"
L["CC Text Size"] = "CC 텍스트 크기"
L["Nameplates Text Size"] = "이름표 텍스트 크기"
L["Portraits Text Size"] = "초상화 텍스트 크기"
L["Alerts / Overlay Text Size"] = "경고 / 오버레이 텍스트 크기"
L["Toggle Test Icons"] = "테스트 아이콘 전환"
L["Show Swipe Edge"] = "스와이프 가장자리 표시"
L["Shows the white line indicating cooldown progress."] = "재사용 대기시간 진행을 나타내는 흰색 선을 표시합니다."
L["Edge Thickness"] = "가장자리 두께"
L["Scale of the swipe line (1.0 = Default)."] = "스와이프 선의 크기입니다 (1.0 = 기본값)."
L["Customize Stack Text"] = "중첩 텍스트 사용자 지정"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "충전 카운터를 직접 제어합니다 (예: 점화 2충전)."
L["Reset %s"] = "%s 초기화"
L["Revert this category to default settings."] = "이 카테고리를 기본 설정으로 되돌립니다."
L["Toggle MiniCC's built-in test icons using /minicc test."] = "/minicc test로 MiniCC 기본 테스트 아이콘을 켜거나 끕니다."

-- Outline Values
L["None"] = "없음"
L["Thick"] = "두껍게"
L["Mono"] = "모노"

-- Anchor Point Values
L["Bottom Right"] = "오른쪽 아래"
L["Bottom Left"] = "왼쪽 아래"
L["Top Right"] = "오른쪽 위"
L["Top Left"] = "왼쪽 위"
L["Center"] = "가운데"

-- General Tab
L["Factory Reset (All)"] = "공장 초기화 (전체)"
L["Resets the entire profile to default values and reloads the UI."] = "전체 프로필을 기본값으로 재설정하고 UI를 다시 불러옵니다."
L["Import / Export"] = "가져오기 / 내보내기"
L["PROFILE_IMPORT_EXPORT_DESC"] = "활성 AceDB 프로필을 공유 가능한 문자열로 내보내거나 문자열을 가져와 현재 프로필 설정을 덮어씁니다."
L["Export current profile"] = "현재 프로필 내보내기"
L["Generate export"] = "내보내기 생성"
L["Export code"] = "내보내기 코드"
L["Generate an export string, then click inside this box and copy it with Ctrl+C."] = "내보내기 문자열을 생성한 뒤 이 상자를 클릭하고 Ctrl+C로 복사하세요."
L["Import profile"] = "프로필 가져오기"
L["Import code"] = "가져오기 코드"
L["Paste an exported string here, then click Import."] = "내보낸 문자열을 여기에 붙여넣은 뒤 가져오기를 클릭하세요."
L["Import"] = "가져오기"
L["Importing will overwrite the current profile settings. Continue?"] = "가져오기를 진행하면 현재 프로필 설정을 덮어씁니다. 계속하시겠습니까?"
L["Export string generated. Copy it with Ctrl+C."] = "내보내기 문자열이 생성되었습니다. Ctrl+C로 복사하세요."
L["Profile import completed."] = "프로필 가져오기가 완료되었습니다."
L["No active profile available."] = "활성 프로필이 없습니다."
L["Failed to encode export string."] = "내보내기 문자열 인코딩에 실패했습니다."
L["Paste an import string first."] = "먼저 가져오기 문자열을 붙여넣으세요."
L["Invalid import string format."] = "가져오기 문자열 형식이 올바르지 않습니다."
L["Failed to decode import string."] = "가져오기 문자열 디코딩에 실패했습니다."
L["Failed to decompress import string."] = "가져오기 문자열 압축 해제에 실패했습니다."
L["Failed to deserialize import string."] = "가져오기 문자열 역직렬화에 실패했습니다."

-- Banner
L["BANNER_DESC"] = "쿨다운을 위한 미니멀 설정입니다. 시작하려면 왼쪽에서 카테고리를 선택하세요."

-- Chat Messages
L["%s settings reset."] = "%s 설정이 초기화되었습니다."
L["Profile reset. Reloading UI..."] = "프로필이 초기화되었습니다. UI를 다시 불러오는 중..."

-- Status Indicators
L["ON"] = "켜짐"
L["OFF"] = "꺼짐"

-- General Dashboard
L["Enable categories styling"] = "카테고리 스타일 활성화"
L["LIVE_CONTROLS_DESC"] = "변경 사항은 즉시 적용됩니다. 더 깔끔한 설정을 위해 실제로 사용하는 카테고리만 활성화해 두세요."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "Blizzard CompactPartyFrame 및 CompactRaidFrame의 강화 및 약화 효과 아이콘에 스타일이 적용된 카운트다운 텍스트를 표시합니다. 파티와 공격대는 각각 따로 전환할 수 있습니다. 이 기능은 기타 카테고리와 별개입니다."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "이 링크를 복사해 브라우저에서 CurseForge 프로젝트 페이지를 여세요."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "이 링크를 복사해 CurseForge에서 Anahkas의 다른 프로젝트를 확인하세요."

-- Help
L["Help & Support"] = "도움말 및 지원"
L["Project"] = "프로젝트"
L["Useful Addons"] = "유용한 애드온"
L["Support & Feedback"] = "지원 및 의견"
L["MCE_HELP_INTRO"] = "빠른 프로젝트 링크와 함께 써볼 만한 애드온 몇 가지입니다."
L["HELP_SUPPORT_DESC"] = "제안과 피드백은 언제나 환영합니다.\n\n버그를 발견했거나 기능 아이디어가 있다면 CurseForge에 댓글이나 개인 메시지를 남겨 주세요."
L["HELP_COMPANION_DESC"] = "MiniCE와 잘 어울리는 깔끔한 추천 애드온입니다."
L["HELP_MINICC_DESC"] = "간결한 군중 제어 추적기입니다. MiniCE는 이 텍스트도 꾸밀 수 있습니다."
L["Copy this link to open the MiniCC CurseForge page in your browser."] = "이 링크를 복사해 브라우저에서 MiniCC CurseForge 페이지를 여세요."
L["HELP_PVPTAB_DESC"] = "PvP에서 TAB이 플레이어만 대상으로 잡게 해 줍니다. 투기장과 전장에 특히 좋습니다."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "이 링크를 복사해 CurseForge에서 Smart PvP Tab Targeting을 여세요."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "주요 쿨다운 카테고리를 한곳에서 켜고 끕니다."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "이 작업은 되돌릴 수 없습니다. 프로필이 완전히 초기화되고 UI가 다시 불러와집니다."
L["MAINTENANCE_DESC"] = "이 카테고리를 기본 설정으로 되돌립니다. 다른 카테고리는 영향을 받지 않습니다."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "Bartender4 및 Dominos를 포함한 주요 행동 단축바의 쿨다운을 꾸밉니다."
L["NAMEPLATE_DESC"] = "적과 아군 이름표에 표시되는 쿨다운을 꾸밉니다 (Plater, KuiNameplates 등)."
L["UNITFRAME_DESC"] = "플레이어, 대상, 주시 대상 유닛 프레임의 쿨다운 스타일을 조정합니다."
L["COOLDOWNMANAGER_DESC"] = "CooldownManager 뷰어에 공통으로 적용되는 아이콘 스타일입니다. 카운트다운 텍스트 크기는 Essential, Utility, 버프 아이콘 뷰어별로 따로 설정할 수 있습니다."
L["MINICC_DESC"] = "MiniCC 쿨다운 아이콘 전용 스타일입니다. MiniCC가 로드되어 있으면 군중 제어 아이콘, 이름표, 초상화, 오버레이형 모듈까지 지원합니다."
L["OTHERS_DESC"] = "다른 카테고리에 속하지 않는 쿨다운을 위한 묶음 카테고리입니다 (가방, 메뉴, 기타 애드온)."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "동적 텍스트 색상"
L["Color by Remaining Time"] = "남은 시간에 따라 색상 지정"
L["Dynamically colors the countdown text based on how much time is left."] = "남은 시간에 따라 카운트다운 텍스트 색상을 동적으로 바꿉니다."
L["DYNAMIC_COLORS_DESC"] = "남은 쿨다운 시간에 따라 텍스트 색상을 바꿉니다. 활성화하면 위의 고정 색상을 덮어씁니다."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "간소형 파티/공격대 오라 텍스트를 포함해 활성화된 모든 MiniCE 카테고리에 동일한 남은 시간 임계값을 적용합니다. Blizzard가 숨겨진 값을 제공할 때도 자정 경계를 안전하게 처리합니다."
L["Expiring Soon"] = "곧 만료"
L["Short Duration"] = "짧은 지속시간"
L["Long Duration"] = "긴 지속시간"
L["Beyond Thresholds"] = "임계값 초과"
L["Threshold (seconds)"] = "임계값(초)"
L["Default Color"] = "기본 색상"
L["Color used when the remaining time exceeds all thresholds."] = "남은 시간이 모든 임계값을 초과할 때 사용하는 색상입니다."

-- Abbreviation
L["Abbreviate Above"] = "다음 이상 축약"
L["Abbreviate Above (seconds)"] = "축약 기준 (초)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "이 임계값을 초과하는 재사용 대기시간 숫자가 축약됩니다 (예: 300 대신 5m)."
L["ABBREV_THRESHOLD_DESC"] = "재사용 대기시간 숫자가 축약 형식으로 전환되는 시점을 제어합니다. 이 임계값을 초과하는 타이머는 5m 또는 1h과 같은 축약 값을 표시합니다."
