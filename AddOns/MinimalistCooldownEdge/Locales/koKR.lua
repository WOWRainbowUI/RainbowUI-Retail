-- koKR.lua (Korean)
local L = LibStub("AceLocale-3.0"):NewLocale("MinimalistCooldownEdge", "koKR")
if not L then return end

L["MINIAURAS_COUNTDOWN_COLORS_NOTICE"] = "MiniAuras가 카운트다운 임계값 색상을 관리합니다. MiniAuras > Misc > Countdown Colours에서 설정하세요."
L["MINIAURAS_SWIPE_ALPHA_DESC"] = "0% = 투명, 100% = 완전히 어둡게. 모든 MiniAuras 모듈 그룹에 적용됩니다. 80%는 MiniAuras가 직접 그리는 쿨다운 효과와 같습니다."

-- Core
L["MiniAuras test command is unavailable."] = "MiniAuras 테스트 명령을 사용할 수 없습니다."

-- Category Names
L["Action Bars"] = "행동 단축바"
L["Nameplates"] = "이름표"
L["Unit Frames"] = "유닛 프레임"
L["Party / Raid Frames"] = "파티/공격대 프레임"
L["CooldownManager"] = "CooldownManager"
L["MiniAuras"] = "MiniAuras"

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
L["MiniAuras Frame Types"] = "MiniAuras 프레임 유형"

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
L["Essential Viewer Stack Size"] = "Essential 뷰어 중첩 크기"
L["Utility Viewer Stack Size"] = "Utility 뷰어 중첩 크기"
L["Buff Icon Viewer Stack Size"] = "버프 아이콘 뷰어 중첩 크기"
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
L["Toggle MiniAuras' built-in test icons using /miniauras test."] = "/miniauras test로 MiniAuras 기본 테스트 아이콘을 켜거나 끕니다."

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
L["Top"] = "위"
L["Bottom"] = "아래"
L["Left"] = "왼쪽"
L["Right"] = "오른쪽"

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
L["Retired"] = "지원 중단"

-- General Dashboard
L["Enable categories styling"] = "카테고리 스타일 활성화"
L["LIVE_CONTROLS_DESC"] = "변경 사항은 즉시 적용됩니다. 더 깔끔한 설정을 위해 실제로 사용하는 카테고리만 활성화해 두세요."
L["COMPACT_PARTY_AURA_TEXT_DESC"] = "파티/공격대 프레임 활성화는 이 카테고리의 메인 스위치 역할을 합니다. 공격대 오라 텍스트 활성화는 동일한 스타일을 Blizzard 공격대 프레임까지 확장합니다."
L["PARTY_RAID_FRAMES_RETIRED_DESC"] = "파티/공격대 프레임 지원은 중단되었습니다. Blizzard 패치 12.0.5 이후 MiniCE는 더 이상 간소형 파티 및 공격대 프레임을 후킹하거나 스타일링하지 않습니다."
L["PARTY_RAID_FRAMES_AURAS_TITLE"] = "새로 개발 중인 애드온: Raid Frame Auras"
L["PARTY_RAID_FRAMES_AURAS_DESC"] = "Raid Frame Auras는 이제 CurseForge에서 받을 수 있습니다. Blizzard의 기존 아이콘을 스타일링하는 대신 자체 오버레이 프레임을 사용하므로 MiniCE와 분리되어 있으며, 독립 애드온으로 두는 편이 더 잘 맞습니다."

-- Links
L["Copy this link to open the CurseForge project page in your browser."] = "이 링크를 복사해 브라우저에서 CurseForge 프로젝트 페이지를 여세요."
L["Copy this link to open Raid Frame Auras on CurseForge."] = "이 링크를 복사해 CurseForge에서 Raid Frame Auras를 여세요."
L["Copy this link to view other projects from Anahkas on CurseForge."] = "이 링크를 복사해 CurseForge에서 Anahkas의 다른 프로젝트를 확인하세요."

-- Help
L["Help & Support"] = "도움말 및 지원"
L["Project"] = "프로젝트"
L["Useful Addons"] = "유용한 애드온"
L["Support & Feedback"] = "지원 및 의견"
L["MCE_HELP_INTRO"] = "빠른 프로젝트 링크와 함께 써볼 만한 애드온 몇 가지입니다."
L["HELP_SUPPORT_DESC"] = "제안과 피드백은 언제나 환영합니다.\n\n버그를 발견했거나 기능 아이디어가 있다면 CurseForge에 댓글이나 개인 메시지를 남겨 주세요."
L["HELP_COMPANION_DESC"] = "MiniCE와 잘 어울리는 깔끔한 추천 애드온입니다."
L["HELP_MINIAURAS_DESC"] = "사용자 설정 오라, 군중 제어, 재사용 대기시간 및 PvP 표시 모음입니다. MiniCE로 재사용 대기시간 텍스트도 꾸밀 수 있습니다."
L["Copy this link to open the MiniAuras CurseForge page in your browser."] = "이 링크를 복사해 브라우저에서 MiniAuras CurseForge 페이지를 여세요."
L["HELP_PVPTAB_DESC"] = "PvP에서 TAB이 플레이어만 대상으로 잡게 해 줍니다. 투기장과 전장에 특히 좋습니다."
L["Copy this link to open Smart PvP Tab Targeting on CurseForge."] = "이 링크를 복사해 CurseForge에서 Smart PvP Tab Targeting을 여세요."

-- Quick Toggles Dashboard
L["QUICK_TOGGLES_DESC"] = "주요 쿨다운 카테고리를 한곳에서 켜고 끕니다."

-- Danger Zone / Maintenance
L["DANGER_ZONE_DESC"] = "이 작업은 되돌릴 수 없습니다. 프로필이 완전히 초기화되고 UI가 다시 불러와집니다."
L["MAINTENANCE_DESC"] = "이 카테고리를 기본 설정으로 되돌립니다. 다른 카테고리는 영향을 받지 않습니다."

-- Category Descriptions
L["ACTIONBAR_DESC"] = "행동 단축바의 쿨다운을 꾸밉니다."
L["NAMEPLATE_DESC"] = "적과 아군 이름표의 쿨다운을 꾸밉니다."
L["UNITFRAME_DESC"] = "대상, 주시 대상 및 지원되는 유닛 프레임의 오라 쿨다운을 꾸밉니다."
L["COOLDOWNMANAGER_DESC"] = "CooldownManager 아이콘 쿨다운을 꾸밉니다."
L["MINIAURAS_DESC"] = "MiniAuras 쿨다운 아이콘을 꾸밉니다."

-- Dynamic Text Colors
L["Dynamic Text Colors"] = "동적 텍스트 색상"
L["Color by Remaining Time"] = "남은 시간에 따라 색상 지정"
L["Dynamically colors the countdown text based on how much time is left."] = "남은 시간에 따라 카운트다운 텍스트 색상을 동적으로 바꿉니다."
L["DYNAMIC_COLORS_DESC"] = "남은 쿨다운 시간에 따라 텍스트 색상을 바꿉니다. 활성화하면 위의 고정 색상을 덮어씁니다."
L["DYNAMIC_COLORS_GENERAL_DESC"] = "남은 시간 임계값은 활성화된 MiniCE 카테고리별로 허용하거나 차단할 수 있습니다. Blizzard가 숨겨진 값을 제공할 때도 자정 경계를 안전하게 처리합니다."
L["Expiring Soon"] = "곧 만료"
L["Short Duration"] = "짧은 지속시간"
L["Long Duration"] = "긴 지속시간"
L["Threshold (seconds)"] = "임계값(초)"
L["Default Color"] = "기본 색상"
L["Color used when the remaining time exceeds all thresholds."] = "남은 시간이 모든 임계값을 초과할 때 사용하는 색상입니다."

-- Abbreviation
L["Abbreviate Above"] = "다음 이상 축약"
L["Abbreviate Above (seconds)"] = "축약 기준 (초)"
L["Cooldown numbers above this threshold will be abbreviated (e.g. 5m instead of 300)."] = "이 임계값을 초과하는 재사용 대기시간 숫자가 축약됩니다 (예: 300 대신 5m)."
L["ABBREV_THRESHOLD_DESC"] = "재사용 대기시간 숫자가 축약 형식으로 전환되는 시점을 제어합니다. 이 임계값을 초과하는 타이머는 5m 또는 1h과 같은 축약 값을 표시합니다."

-- MyDRs / sArena
L["MYDRS_SWIPE_ALPHA_DESC"] = "0% = 투명, 100% = 완전히 어둡게. 이 카테고리가 활성화된 동안 MyDRs의 Cooldown Swipe Alpha 설정을 대체합니다. 100%는 MyDRs가 직접 그리는 스와이프와 같습니다."
L["MyDRs test command is unavailable."] = "MyDRs 테스트 명령을 사용할 수 없습니다."
L["Toggle MyDRs' built-in test icons using /mydrs test."] = "/mydrs test로 MyDRs 기본 테스트 아이콘을 켜거나 끕니다."
L["sArena slash command is unavailable."] = "sArena 슬래시 명령을 사용할 수 없습니다."

-- Category Names
L["Player Auras"] = "플레이어 오라"
L["CooldownManagerCentered"] = "CooldownManagerCentered"
L["HealerCC"] = "HealerCC"
L["MyDRs"] = "MyDRs"
L["sArena"] = "sArena"
L["TellMeWhen"] = "TellMeWhen"
L["Profiles"] = "프로필"
L["ShinyAuras"] = "ShinyAuras"
L["Dominos"] = "Dominos"
L["ElvUI"] = "ElvUI"

-- Group Headers
L["Swipe Edge"] = "스와이프 가장자리"
L["MiniAuras Module Groups"] = "MiniAuras 모듈 그룹"
L["sArena Cooldown Types"] = "sArena 쿨다운 유형"
L["Aura Targets"] = "오라 대상"
L["Buff Styling"] = "강화 효과 스타일"
L["Debuff Styling"] = "약화 효과 스타일"
L["External Defensive Buffs Styling"] = "외부 방어 강화 효과 스타일"

-- Toggles & Settings
L["Style Buffs"] = "강화 효과 스타일 적용"
L["Style Debuffs"] = "약화 효과 스타일 적용"
L["Style External Defensive Buffs"] = "외부 방어 강화 효과 스타일 적용"
L["Style Blizzard's default player buff buttons."] = "Blizzard 기본 플레이어 강화 효과 아이콘에 스타일을 적용합니다."
L["Style Blizzard's default player debuff buttons."] = "Blizzard 기본 플레이어 약화 효과 아이콘에 스타일을 적용합니다."
L["Style Blizzard's external defensive buff buttons."] = "Blizzard 외부 방어 강화 효과 아이콘에 스타일을 적용합니다."
L["Timer Inside Icon"] = "아이콘 안에 타이머 표시"
L["Place the aura timer in the center of the icon instead of Blizzard's default outside position."] = "Blizzard의 기본 외부 위치 대신 오라 타이머를 아이콘 중앙에 배치합니다."
L["Hide Swipe"] = "스와이프 숨기기"
L["Only Mine (Timer Text)"] = "내 것만 (타이머 텍스트)"
L["Aura Visibility"] = "오라 표시 여부"
L["Only My Debuffs"] = "내 약화 효과만"
L["Only My Buffs"] = "내 강화 효과만"
L["Disable fading/blinking"] = "페이드/깜빡임 비활성화"
L["Enables styled countdown text on Party / Raid Frames. When disabled, both party and raid aura text styling are turned off."] = "파티/공격대 프레임에 스타일이 적용된 카운트다운 텍스트를 활성화합니다. 끄면 파티와 공격대 오라 텍스트 스타일이 모두 꺼집니다."
L["Also apply styled countdown text to Blizzard CompactRaidFrame buff and debuff icons. Requires Party / Raid Frames to be enabled."] = "Blizzard CompactRaidFrame의 강화 및 약화 효과 아이콘에도 스타일이 적용된 카운트다운 텍스트를 적용합니다. 파티/공격대 프레임이 활성화되어 있어야 합니다."
L["Hide the swipe animation for this frame group (countdown text still shows)."] = "이 프레임 그룹의 스와이프 애니메이션을 숨깁니다 (카운트다운 텍스트는 계속 표시됩니다)."
L["Only show cooldown timer text on your own auras. Uses Blizzard's large-aura heuristic instead of a direct sourceUnit check."] = "자신의 오라에만 쿨다운 타이머 텍스트를 표시합니다. 직접적인 sourceUnit 확인 대신 Blizzard의 큰 오라 추정 방식을 사용합니다."
L["UNITFRAME_ONLY_MINE_DESC"] = "본인이 시전한 오라에만 타이머 텍스트를 표시합니다. WoW 12.1용 MiniCE의 대상/주시 대상 컨테이너는 Blizzard의 플레이어 필터를 사용하며, 호환 애드온 및 레거시 프레임은 그룹 메타데이터나 큰 오라 대체 방식을 사용합니다."
L["UNITFRAME_ONLY_MINE_DEBUFFS_DESC"] = "대상 및 주시 대상 프레임에서 다른 플레이어가 시전한 약화 효과를 숨깁니다. MiniCE가 WoW 12.1에서 이 오라 컨테이너를 관리하므로 Blizzard 자체 약화 효과 필터가 더 이상 적용되지 않습니다."
L["UNITFRAME_ONLY_MINE_BUFFS_DESC"] = "대상 및 주시 대상 프레임에서 다른 플레이어가 시전한 강화 효과를 숨깁니다. MiniCE가 WoW 12.1에서 이 오라 컨테이너를 관리하므로 Blizzard 자체 강화 효과 필터가 더 이상 적용되지 않습니다."
L["Cast Bar"] = "시전 바"
L["Reposition Cast Bar"] = "시전 바 위치 조정"
L["UNITFRAME_CASTBAR_REPOSITION_DESC"] = "대상 및 주시 대상의 시전 바를 마지막 강화/약화 효과 줄 아래에 고정합니다. MiniCE가 WoW 12.1에서 이 오라 컨테이너를 관리하므로, 이 설정이 없으면 Blizzard 시전 바가 프레임에 붙어 오라와 걹칩니다."
L["Keeps player aura buttons fully opaque when they are close to expiring."] = "플레이어 오라 아이콘이 곧 만료될 때도 완전히 불투명하게 유지합니다."
L["When a CooldownManager slot is temporarily showing aura time, use a dedicated buff color instead of remaining-time threshold colors."] = "CooldownManager 슬롯이 일시적으로 오라 시간을 표시할 때 남은 시간 임계값 색상 대신 전용 강화 효과 색상을 사용합니다."
L["Applied while the slot is showing aura duration. When the aura ends and the slot switches back to cooldown time, threshold colors resume."] = "슬롯이 오라 지속시간을 표시하는 동안 적용됩니다. 오라가 끝나고 슬롯이 쿨다운 시간으로 다시 전환되면 임계값 색상이 재개됩니다."
L["Buff / Debuff Size"] = "강화/약화 효과 크기"
L["Defensive Buff Size"] = "방어 강화 효과 크기"
L["Use Buff Color"] = "강화 효과 색상 사용"
L["Buff Color"] = "강화 효과 색상"
L["Essential Viewer"] = "Essential 뷰어"
L["Utility Viewer"] = "Utility 뷰어"
L["Buff Icon Viewer"] = "버프 아이콘 뷰어"
L["CC Frames Text Size"] = "CC 프레임 텍스트 크기"
L["CC / Friendly Frames Text Size"] = "CC / 아군 프레임 텍스트 크기"
L["Raid Frame Auras Text Size"] = "공격대 프레임 오라 텍스트 크기"
L["Class Icon Text Size"] = "직업 아이콘 텍스트 크기"
L["DR Cooldown Text Size"] = "DR 쿨다운 텍스트 크기"
L["Alerts / Trackers / Custom Auras Text Size"] = "경고 / 추적기 / 사용자 지정 오라 텍스트 크기"
L["Trinket / Racial Text Size"] = "장신구 / 종족 특성 텍스트 크기"
L["Show Test Frames"] = "테스트 프레임 표시"
L["Hide Test Frames"] = "테스트 프레임 숨기기"
L["Show Swipe Animation"] = "스와이프 애니메이션 표시"
L["Shows the dark overlay that sweeps during a cooldown."] = "쿨다운 중에 진행되는 어두운 오버레이를 표시합니다."
L["Swipe Shade Alpha"] = "스와이프 음영 불투명도"
L["0% = transparent, 100% = full dark."] = "0% = 투명, 100% = 완전히 어둡게."
L["Reverse Swipe"] = "스와이프 반전"
L["Reverse the swipe direction so the shade fills in the opposite direction."] = "스와이프 방향을 반전시켜 음영이 반대 방향으로 채워지게 합니다."
L["Hide Charge Timers"] = "충전 타이머 숨기기"
L["Hide timers while charges are restoring (only show timer when all charges are spent)."] = "충전이 회복되는 동안 타이머를 숨깁니다 (모든 충전을 소모했을 때만 타이머를 표시합니다)."
L["Hide Stack Text"] = "중첩 텍스트 숨기기"
L["Hide stacks and charges entirely."] = "중첩과 충전을 완전히 숨깁니다."
L["MiniAuras text settings are grouped by module family so similar widgets share the same countdown size."] = "MiniAuras 텍스트 설정은 모듈 계열별로 묶여 있어 비슷한 위젯이 동일한 카운트다운 크기를 공유합니다."
L["Applies to MiniAuras CC module (enemy crowd controls)."] = "MiniAuras CC 모듈(적 군중 제어)에 적용됩니다."
L["Applies to MiniAuras CC, Friendly CDs, and Friendly Indicators modules."] = "MiniAuras CC, Friendly CDs, Friendly Indicators 모듈에 적용됩니다."
L["Applies to the MiniAuras Raid Frame Auras module."] = "MiniAuras Raid Frame Auras 모듈에 적용됩니다."
L["Applies to MiniAuras portrait icons."] = "MiniAuras 초상화 아이콘에 적용됩니다."
L["Applies to MiniAuras Alerts, Healer CC, Kick Timer, Precognition, Trinkets, and Custom Auras modules."] = "MiniAuras Alerts, Healer CC, Kick Timer, Precognition, Trinkets, Custom Auras 모듈에 적용됩니다."
L["Show sArena test frames using /sarena test."] = "/sarena test로 sArena 테스트 프레임을 표시합니다."
L["Hide sArena test frames using /sarena hide."] = "/sarena hide로 sArena 테스트 프레임을 숨깁니다."

-- Import / Export
L["Import string is too large."] = "가져오기 문자열이 너무 큽니다."
L["Import profile contains invalid data."] = "가져온 프로필에 잘못된 데이터가 있습니다."
L["Failed to apply imported profile."] = "가져온 프로필을 적용하지 못했습니다."

-- Chat Messages
L["Some changes require a UI reload to be fully applied.\n\nReload the interface now?"] = "일부 변경 사항은 UI를 다시 불러와야 완전히 적용됩니다.\n\n지금 인터페이스를 다시 불러오시겠습니까?"

-- Addon Integrations
L["Addon Integrations"] = "애드온 연동"
L["ADDON_INTEGRATIONS_DESC"] = "외부 쿨다운을 MiniCE 카테고리로 연결하는 선택적 애드온 브리지를 켜거나 끕니다."
L["Routes ShinyAuras cooldowns through the Unit Frames category. Disable this if you want ShinyAuras to keep its native countdowns untouched."] = "ShinyAuras 쿨다운을 유닛 프레임 카테고리를 통해 연결합니다. ShinyAuras의 기본 카운트다운을 그대로 유지하려면 비활성화하세요."
L["Routes supported Dominos action bar cooldowns through the Action Bars category. Disable this if you want Dominos to keep its native cooldown styling untouched."] = "지원되는 Dominos 행동 단축바 쿨다운을 행동 단축바 카테고리를 통해 연결합니다. Dominos의 기본 쿨다운 스타일을 그대로 유지하려면 비활성화하세요."
L["Routes supported Bartender4 action bar cooldowns through the Action Bars category. Disable this if you want Bartender4 to keep its native cooldown styling untouched."] = "지원되는 Bartender4 행동 단축바 쿨다운을 행동 단축바 카테고리를 통해 연결합니다. Bartender4의 기본 쿨다운 스타일을 그대로 유지하려면 비활성화하세요."
L["Routes supported ElvUI action bar, unit frame, and nameplate cooldowns through MiniCE categories. Disable this if you want ElvUI to keep its native cooldown styling untouched."] = "지원되는 ElvUI 행동 단축바, 유닛 프레임, 이름표 쿨다운을 MiniCE 카테고리를 통해 연결합니다. ElvUI의 기본 쿨다운 스타일을 그대로 유지하려면 비활성화하세요."
L["CooldownManagerCentered also styles %s. This may add a small performance cost. Disable CMC timer fonts if you want MiniCE to remain the only owner of those viewer timers."] = "CooldownManagerCentered는 %s에도 스타일을 적용합니다. 약간의 성능 부담이 있을 수 있습니다. MiniCE가 해당 뷰어 타이머를 단독으로 관리하게 하려면 CMC 타이머 글꼴을 비활성화하세요."

-- Help
L["HELP_ARENADR_DESC"] = "투기장에서 적의 점감 효과를 이름표에 직접 표시하여 추적합니다."
L["Copy this link to open ArenaDR Nameplates on CurseForge."] = "이 링크를 복사해 CurseForge에서 ArenaDR Nameplates를 여세요."

-- Category Descriptions
L["BETTERBLIZZFRAMES_UNITFRAME_CONFLICT_WARNING"] = "BetterBlizzFrames가 활성화되어 있어 충돌 가능성을 방지하기 위해 MiniCE의 유닛 프레임 스타일링이 비활성화되었습니다. BetterBlizzFrames 전용 어댑터가 곧 제공될 예정입니다."
L["BETTERBLIZZPLATES_NAMEPLATE_CONFLICT_WARNING"] = "BetterBlizzPlates가 활성화되어 있어 충돌 가능성을 방지하기 위해 MiniCE의 이름표 스타일링이 비활성화되었습니다."
L["PLAYERAURA_DESC"] = "Blizzard 플레이어 강화 및 약화 효과 쿨다운을 꾸밉니다."
L["HEALERCC_DESC"] = "아군과 적의 HealerCC 경고 쿨다운을 꾸밉니다."
L["MYDRS_DESC"] = "MyDRs의 점감 효과 아이콘 쿨다운을 꾸밉니다. MyDRs는 자체 DR 상태 표시(50% / IMM)를 유지합니다."
L["SARENA_DESC"] = "sArena_Reloaded 쿨다운 타이머를 꾸밉니다."
L["TELLMEWHEN_DESC"] = "TellMeWhen 쿨다운 텍스트와 스와이프 가장자리를 꾸밉니다."
L["TELLMEWHEN_TIMER_OPTIONS_NOTICE"] = "타이머 표시 여부, 타이머 텍스트, 음영 방향, GCD 표시는 계속 TellMeWhen이 제어합니다. 스와이프 가장자리 표시 여부와 두께는 여기서 제어합니다."
L["TELLMEWHEN_EDGE_SCALE_DESC"] = "MiniCE가 활성화한 경우 TellMeWhen 스와이프 가장자리의 크기를 조정합니다."

-- Dynamic Text Colors
L["Allow Threshold Colors"] = "임계값 색상 허용"
L["Allows the global \"Color by Remaining Time\" thresholds to override this category's static text color."] = "전역 \"남은 시간에 따라 색상 지정\" 임계값이 이 카테고리의 고정 텍스트 색상을 덮어쓸 수 있도록 허용합니다."
L["Behavior"] = "동작"
L["Advanced Threshold Settings"] = "고급 임계값 설정"
L["Threshold Colors"] = "임계값 색상"
L["THRESHOLD_COLORS_DESC"] = "각 구간은 해당 남은 시간 범위에 사용할 기준값과 색상을 정의합니다."
L["Threshold Transition Offset"] = "임계값 전환 오프셋"
L["Moves the start of each next color band. Negative values switch slightly earlier."] = "다음 색상 구간이 시작되는 시점을 조정합니다. 음수 값은 조금 더 일찍 전환됩니다."
L["Beyond Thresholds Color"] = "임계값 초과 색상"

-- Abbreviation
L["Show Tenths Below (seconds)"] = "다음 미만에서 소수점 첫째 자리 표시 (초)"
L["Cooldown numbers below this threshold will show one decimal place (e.g. 8.7). Set 0 to disable."] = "이 임계값 미만의 재사용 대기시간 숫자는 소수점 첫째 자리까지 표시됩니다 (예: 8.7). 0으로 설정하면 비활성화됩니다."

-- Performance Warning
L["PERF_WARNING_DESC"] = "이 기능은 성능에 영향을 주어 FPS 저하를 유발할 수 있습니다. 사양이 좋은 환경에서만 사용하세요."

-- Font Options
L["Game Default"] = "게임 기본값"
