-- koKR.lua (Korean)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "koKR")
if not L then return end

-- Core
L["Cannot open options in combat."] = "전투 중에는 옵션을 열 수 없습니다."

-- Category Names
L["Action Bars"] = "행동 단축바"
L["Nameplates"] = "이름표"
L["Unit Frames"] = "유닛 프레임"
L["CD Manager & Others"] = "쿨다운 관리자 및 기타"

-- Group Headers
L["General"] = "일반"
L["State"] = "상태"
L["Typography (Cooldown Numbers)"] = "글꼴 (재사용 대기시간 숫자)"
L["Swipe Animation"] = "회전 애니메이션"
L["Stack Counters / Charges"] = "중첩 카운터 / 충전"
L["Maintenance"] = "유지보수"
L["Performance & Detection"] = "성능 및 감지"
L["Danger Zone"] = "위험 영역"
L["Style"] = "스타일"
L["Positioning"] = "위치 조정"

-- Toggles & Settings
L["Enable %s"] = "%s 활성화"
L["Toggle styling for this category."] = "이 범주의 스타일링을 전환합니다."
L["Font Face"] = "글꼴"
L["Game Default"] = "게임 기본값"
L["Font"] = "글꼴"
L["Size"] = "크기"
L["Outline"] = "외곽선"
L["Color"] = "색상"
L["Hide Numbers"] = "숫자 숨기기"
L["Hide the text entirely (useful if you only want the swipe edge or stacks)."] = "텍스트를 완전히 숨깁니다 (회전 가장자리나 중첩만 원할 때 유용)."
L["Anchor Point"] = "고정점"
L["Offset X"] = "X 오프셋"
L["Offset Y"] = "Y 오프셋"
L["Show Swipe Edge"] = "회전 가장자리 표시"
L["Shows the white line indicating cooldown progress."] = "재사용 대기시간 진행을 나타내는 흰색 선을 표시합니다."
L["Edge Thickness"] = "가장자리 두께"
L["Scale of the swipe line (1.0 = Default)."] = "회전 선의 크기 (1.0 = 기본값)."
L["Customize Stack Text"] = "중첩 텍스트 사용자 정의"
L["Take control over the charge counter (e.g., 2 stacks of Conflagrate)."] = "충전 카운터를 제어합니다 (예: 타오르는 불길 2중첩)."
L["Reset %s"] = "%s 초기화"
L["Revert this category to default settings."] = "이 범주를 기본 설정으로 되돌립니다."

-- Outline Values
L["None"] = "없음"
L["Thick"] = "두꺼운"
L["Mono"] = "모노"

-- Anchor Point Values
L["Bottom Right"] = "하단 우측"
L["Bottom Left"] = "하단 좌측"
L["Top Right"] = "상단 우측"
L["Top Left"] = "상단 좌측"
L["Center"] = "중앙"

-- General Tab
L["Scan Depth"] = "스캔 깊이"
L["How deep the addon looks into UI frames to find cooldowns."] = "애드온이 재사용 대기시간을 찾기 위해 UI 프레임을 탐색하는 깊이입니다."
L["Factory Reset (All)"] = "공장 초기화 (전체)"
L["Resets the entire profile to default values and reloads the UI."] = "전체 프로필을 기본값으로 재설정하고 UI를 다시 로드합니다."

-- Banner
L["BANNER_DESC"] = "쿨다운을 위한 미니멀 설정입니다. 시작하려면 왼쪽에서 범주를 선택하세요."

-- Scan Depth Help
L["SCAN_DEPTH_HELP"] = "\n|cff00ff00< 10|r : 효율적 (기본 UI)\n|cfffff56910 - 15|r : 보통 (Bartender, Dominos)\n|cffffa500> 15|r : 무거움 (ElvUI, 복잡한 프레임)"

-- Chat Messages
L["%s settings reset."] = "%s 설정 초기화됨."
L["Profile reset. Reloading UI..."] = "프로필 초기화됨. UI 재로딩 중..."
L["Global Scan Depth changed. A /reload is recommended."] = "전역 스캔 깊이가 변경되었습니다. /reload를 권장합니다."
