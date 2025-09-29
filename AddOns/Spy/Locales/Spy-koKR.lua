local L = LibStub("AceLocale-3.0"):NewLocale("Spy", "koKR")
if not L then return end
-- TOC Note: "근처에 있는 적 플레이어를 탐지하고 경고합니다."

-- Configuration
L["Spy"] = "Spy"
L["Version"] = "버전"
L["Spy Option"] = "Spy"
L["Profiles"] = "프로필"

-- About
L["About"] = "정보"
L["SpyDescription1"] = [[
Spy는 근처에 있는 적 플레이어를 알려주는 애드온 입니다.

]]

L["SpyDescription2"] = [[
|cffffd000 근접한 적 목록 |cffffffff
근접한 적 목록은 근처에 있는 탐지 된 적을 표시합니다. 근접한 적 목록을 클릭하면 적을 타겟팅하지만, 전투 상황은 아닙니다. 근접한 적에 등록된 플레이어가 일정 시간이 지나도 탐지되지 않는다면 자동으로 지워집니다.

|cffffd000 1시간 내 목록 |cffffffff
한 시간 안에 감지 된 모든 적을 표시합니다.

|cffffd000 제외 목록 |cffffffff
제외 목록에 포함 된 적 플레이어는 Spy에 기록되지 않습니다. 드롭다운 메뉴 또는 목록을 Ctrl + 좌클릭 으로 플레이어를 제외목록에 추가 / 제거 할 수 있습니다.

|cffffd000 살생부 명단 |cffffffff
살생부 명단에 있는 적이 탐지되었을 때 알람이 울립니다. 드롭다운 메뉴 또는 목록을 Shift + 좌클릭 으로 플레이어를 살생부에 추가 / 제거 할 수 있습니다. 드롭다운 메뉴로 살생부 명단에 추가한 이유를 설정 할 수 있습니다. 만약 알맞은 이유가 없다면, "이유를 입력하세요..." 를 선택해 직접 작성 할 수 있습니다.

]]

L["SpyDescription3"] = [[
|cffffd000 Statistics Window |cffffffff
The Statistics Window contains a list of all enemy encounters which can be sorted by name, level, guild, wins, losses and the last time an enemy was detected. It also provides the ability to search for a specific enemy by name or guild and has filters to show only enemies that are marked as Kill on Sight, with a Win/Loss or entered Reasons.

|cffffd000 Kill On Sight Button |cffffffff
If enabled, this button will be located on the enemy players target frame. Clicking on this button will add/remove the enemy target to/from the Kill On Sight list. Right clicking on the button will allow you to enter Kill on Sight reasons.

|cffffd000 제작자:|cffffffff Slipjack
]]

-- General Settings
L["GeneralSettings"] = "일반 설정"
L["GeneralSettingsDescription"] = [[
Spy 가 활성화 또는 비활성화 된 경우에 대한 옵션입니다.
]] 
L["EnableSpy"] = "Spy 활성화"
L["EnableSpyDescription"] = "Spy 활성화 또는 비활성화."
L["EnabledInBattlegrounds"] = "전장일 때 Spy 활성화"
L["EnabledInBattlegroundsDescription"] = "전장에 있을 때 Spy를 활성화 또는 비활성화 합니다."
L["EnabledInArenas"] = "아레나에 있을 때 Spy 활성화"
L["EnabledInArenasDescription"] = "아레나에 있을 때 Spy를 활성화 또는 비활성화 합니다."
L["EnabledInWintergrasp"] = "대규모 전장일 때 Spy 활성화"
L["EnabledInWintergraspDescription"] = "겨울손아귀 호수와 같은 대규모 전장일 경우 Spy를 활성화 또는 비활성화 합니다."
L["EnabledInSanctuaries"] = "Enable Spy in Sanctuaries."
L["EnabledInSanctuariesDescription"] = "Enables or disables Spy when you are in a Sanctuary."
L["DisableWhenPVPUnflagged"] = "PVP 상태가 아닐 때 Spy 비활성화"
L["DisableWhenPVPUnflaggedDescription"] = "PVP 상태일 경우 Spy를 활성화 또는 비활성화 합니다."
L["DisabledInZones"] = "Disable Spy while in these locations"
L["DisabledInZonesDescription"]	= "Select locations where Spy will be disabled"
L["Booty Bay"] = "무법항"
L["Everlook"] = "눈망루 마을"						
L["Gadgetzan"] = "가젯잔"
L["Ratchet"] = "톱니항"
L["The Salty Sailor Tavern"] = "뱃사공의 선술집"
L["Cenarion Hold"] = "세나리온 요새"
L["Shattrath City"] = "샤트라스"
L["Area 52"] = "52번 구역"
L["Dalaran"] = "달라란"
L["Bogpaddle"] = "수렁진흙탕"
L["The Vindicaar"] = "구원호"
L["Krasus' Landing"] = "크라서스 착륙장"
L["The Violet Gate"] = "보랏빛 관문"
L["Magni's Encampment"] = "마그니의 야영지"
L["Silithus"] = "실리더스"
L["Chamber of Heart"] = "심장의 방"
L["Hall of Ancient Paths"] = "고대 길의 전당"
L["Sanctum of the Sages"] = "현자의 성소"
L["Rustbolt"] = "녹슨나사"
L["Oribos"] = "오리보스"
L["Valdrakken"] = "발드라켄"
L["The Roasted Ram"] = "양꼬치 주점"
L["Dornogal"] = "도르노갈"
L["Stonelight Rest"] = "돌빛 쉼터"
L["Delver's Headquarters"] = "구렁 탐험가 본부"

-- Display
L["DisplayOptions"] = "디스플레이"
L["DisplayOptionsDescription"] = [[
Spy 창 및 툴팁 옵션.
]]
L["ShowOnDetection"] = "적 플레이어가 탐지될 경우 Spy 창 표시"
L["ShowOnDetectionDescription"] = "Spy 창이 숨겨져 있을 때 적 플레이어가 탐지될 경우 근접한 적 목록을 표시하려면 체크하십시오."
L["HideSpy"] = "적 플레이어가 없을 때 Spy 숨기기"
L["HideSpyDescription"] = "근접한 적 목록이 비었을 때 Spy 창을 숨기고 싶다면 체크하십시오. 지우기 버튼을 눌러 목록을 비웠을 경우, Spy 창은 숨겨지지 않습니다."
L["ShowOnlyPvPFlagged"] = "PVP상태가 활성화 된 적 플레이어만 표시"
L["ShowOnlyPvPFlaggedDescription"] = "근접한 적 목록에 PVP상태가 활성화 된 적 플레이어만 표시하려면 체크하십시오."
L["ShowKoSButton"] = "적 타겟 프레임에 살생부 버튼 표시"
L["ShowKoSButtonDescription"] = "적 개체창에 살생부 버튼을 표시하려면 체크하십시오."
L["Alpha"] = "투명도"
L["AlphaDescription"] = "Spy 창의 투명도를 설정하십시오."
L["AlphaBG"] = "전장의 투명성"
L["AlphaBGDescription"] = "전장에서 Spy 창의 투명도를 설정하십시오."
L["LockSpy"] = "Spy 창 잠금"
L["LockSpyDescription"] = "Spy 창이 움직이지 않도록 고정합니다."
L["ClampToScreen"] = "화면에 고정"
L["ClampToScreenDescription"] = "Spy 창이 화면 밖으로 벗어나지 못하게 합니다"
L["InvertSpy"] = "Spy 창 뒤집음"
L["InvertSpyDescription"] = "Spy 창을 위아래로 뒤집습니다."
L["Reload"] = "UI 새로고침"
L["ReloadDescription"] = "Spy 창을 변경 하려면 UI 새로고침을 해야합니다."
L["ResizeSpy"] = "Spy 창 크기 자동조절"
L["ResizeSpyDescription"] = "적 플레이어가 추가/제거될 때 Spy 창 크기를 자동으로 조절하려면 체크하십시오"
L["ResizeSpyLimit"] = "목록 갯수 제한"
L["ResizeSpyLimitDescription"] = "Spy 창에 표시되는 적 플레이어 수 제한."
L["DisplayTooltipNearSpyWindow"] = "Spy 창 근처에 툴팁 표시"
L["DisplayTooltipNearSpyWindowDescription"] = "Spy 창 근처에 툴팁을 표시하려면 이것을 설정하십시오."
L["SelectTooltipAnchor"] = "툴팁 앵커 포인트"
L["SelectTooltipAnchorDescription"] = "위의 옵션을 선택한 경우 툴팁의 기준점을 선택하십시오."
L["ANCHOR_CURSOR"] = "커서"
L["ANCHOR_TOP"] = "위에"
L["ANCHOR_BOTTOM"] = "아래에"
L["ANCHOR_LEFT"] = "왼쪽"			
L["ANCHOR_RIGHT"] = "오른쪽"
L["TooltipDisplayWinLoss"] = "적 플레이어 툴팁에 승/패 표시"
L["TooltipDisplayWinLossDescription"] = "적 플레이어 툴팁에 승/패를 표시하려면 체크하십시오."
L["TooltipDisplayKOSReason"] = "적 플레이어 툴팁에 살생부 이유 표시"
L["TooltipDisplayKOSReasonDescription"] = "적 플레이어 툴팁에 살생부 이유를 표시하려면 체크하십시오."
L["TooltipDisplayLastSeen"] = "적 플레이어 툴팁에 마지막 탐지 시간 표시"
L["TooltipDisplayLastSeenDescription"] = "적 플레이어 툴팁에 마지막으로 탐지된 시간과 위치를 표시하려면 체크하십시오."
L["DisplayListData"] = "표시 할 적의 데이터를 선택하십시오"
L["Name"] = "이름"
L["Class"] = "직업"
L["Rank"] = "등급"
L["SelectFont"] = "폰트 설정"
L["SelectFontDescription"] = "Spy 창의 폰트를 선택하세요."
L["RowHeight"] = "열 높이 설정"
L["RowHeightDescription"] = "Spy 창의 열 높이를 설정하세요."
L["Texture"] = "질감 배경"
L["TextureDescription"] = "Spy 창의 질감을 선택하십시오"

-- Alerts
L["AlertOptions"] = "경고"
L["AlertOptionsDescription"] = [[
적 플레이어가 감지 될 때 경고, 알림 및 경고 옵션.
]]
L["SoundChannel"] = "사운드 채널을 선택하십시오"
L["Master"] = "주 음량"
L["SFX"] = "효과음"
L["Music"] = "배경음악"
L["Ambience"] = "환경 소리"
L["Announce"] = "공지 사항 보내기 :"
L["None"] = "없음"
L["NoneDescription"] = "적 플레이어가 탐지되어도 알리지 않습니다."
L["Self"] = "자기자신"
L["SelfDescription"] = "적 플레이어가 탐지되면 자기 자신에게만 알립니다."
L["Party"] = "파티"
L["PartyDescription"] = "적 플레이어가 탐지되면 파티에 알립니다."
L["Guild"] = "길드"
L["GuildDescription"] = "적 플레이어가 탐지되면 길드에 알립니다."
L["Raid"] = "공격대"
L["RaidDescription"] = "적 플레이어가 탐지되면 공격대에 알립니다."
L["LocalDefense"] = "수비"
L["LocalDefenseDescription"] = "적 플레이어가 탐지되면 수비 채널에 알립니다."
L["OnlyAnnounceKoS"] = "살생부 명단에 있는 플레이어가 탐지될 때만 알림"
L["OnlyAnnounceKoSDescription"] = "살생부 명단에 있는 플레이어만 알리고 싶으시면 체크하십시오."
L["WarnOnStealth"] = "은신 탐지시 경고"
L["WarnOnStealthDescription"] = "적 플레이어가 은신 할때 경고 알림과 소리를 재생하고 싶으시면 체크하십시오."
L["WarnOnKOS"] = "살생부 명단에 있는 플레이어 탐지시 경고"
L["WarnOnKOSDescription"] = "살생부 명단에 있는 적 플레이어가 탐지 될 때 경고 알림과 소리를 재생하고 싶으시면 체크하십시오."
L["WarnOnKOSGuild"] = "살생부 명단에 있는 플레이어의 길드 탐지시 경고"
L["WarnOnKOSGuildDescription"] = "살생부 명단에 있는 적 플레이어와 같은 길드인 적 플레이어가 탐지 될 때 경고알림과 소리를 재생하고 싶으시면 체크하십시오."
L["WarnOnRace"] = "종족 탐지시 경고"
L["WarnOnRaceDescription"] = "선택한 종족이 탐지되었을때 소리를 재생하고 싶으시면 체크하십시오."
L["SelectWarnRace"] = "탐지할 종족 선택"
L["SelectWarnRaceDescription"] = "탐지할 종족을 선택합니다. 탐지시 소리가 재생됩니다."
L["WarnRaceNote"] = "주의: 적 플레이어를 최소 한번이라도 타겟팅해야 적의 종족이 데이터베이스에 추가됩니다. 그 다음 탐지 시 소리가 재생됩니다. 근접한 적을 탐지하는 것과는 다르게 동작합니다."
L["DisplayWarningsInErrorsFrame"] = "오류 프레임으로 경고 표시"
L["DisplayWarningsInErrorsFrameDescription"] = "그래픽 팝업 프레임 대신 오류 프레임으로 경고를 표시하려면 체크하십시오."
L["DisplayWarnings"] = "경고 메시지 위치 선택"
L["Default"] = "기본 위치"
L["ErrorFrame"] = "오류 프레임"
L["Moveable"] = "움직일 수 있는"
L["EnableSound"] = "경고 소리 활성화"
L["EnableSoundDescription"] = "적 플레이어가 탐지될 때 소리를 활성화하려면 체크하십시오. 은신을 탐지할 때와 살생부 명단을 탐지할 때의 소리는 다릅니다."
L["OnlySoundKoS"] = "살생부 명단에 한하여 경고 소리 재생"
L["OnlySoundKoSDescription"] = "살생부 명단에 있는 적 플레이어를 탐지할 때만 소리를 재생시키려면 체크하십시오."
L["StopAlertsOnTaxi"] = "비행 경로에서 알림 끄기"
L["StopAlertsOnTaxiDescription"] = "비행 경로에서 모든 새로운 경고 및 경고를 중지."

-- Nearby List
L["ListOptions"] = "근접한 적 목록"
L["ListOptionsDescription"] = [[
적 플레이어를 추가하고 제거하는 방법에 대한 옵션.
]]
L["RemoveUndetected"] = "근접한 적 목록에서 지워지는 시간:"
L["1Min"] = "1 분"
L["1MinDescription"] = "1 분 이상 탐지되지 않은 적 플레이어를 지웁니다."
L["2Min"] = "2 분"
L["2MinDescription"] = "2 분 이상 탐지되지 않은 적 플레이어를 지웁니다."
L["5Min"] = "5 분"
L["5MinDescription"] = "5 분 이상 탐지되지 않은 적 플레이어를 지웁니다."
L["10Min"] = "10 분"
L["10MinDescription"] = "10 분 이상 탐지되지 않은 적 플레이어를 지웁니다."
L["15Min"] = "15 분"
L["15MinDescription"] = "15 분 이상 탐지되지 않은 적 플레이어를 지웁니다."
L["Never"] = "지우지 않음"
L["NeverDescription"] = "적 플레이어를 지우지 않습니다. 근접한 적 목록은 수동으로 지울 수 있습니다."
L["ShowNearbyList"] = "적 플레이어 탐지 시 근접한 적 목록으로 전환"
L["ShowNearbyListDescription"] = "근접한 적 목록을 표시하지 않을 때, 적 플레이어를 탐지한 경우 근접한 적 목록으로 전환하려면 체크하십시오."
L["PrioritiseKoS"] = "살생부 명단에 있는 근접한 적을 우선 표시"
L["PrioritiseKoSDescription"] = "살생부 명단에 있는 적을 근접한 적 목록의 최우선으로 표시하려면 체크하십시오."

-- Map
L["MapOptions"] = "지도"
L["MapOptionsDescription"] = [[
아이콘 및 툴팁을 포함한 세계지도 및 미니 맵 옵션.
]]
L["MinimapDetection"] = "미니 맵 감지 활성화"
L["MinimapDetectionDescription"] = "미니 맵에서 감지 된 알려진 적 플레이어 위로 커서를 가져 가면 근처 적 목록에 추가됩니다."
L["MinimapNote"] = "          참고 : 휴머노이드를 추적 할 수있는 플레이어 만 사용할 수 있습니다."
L["MinimapDetails"] = "레벨/직업을 툴팁에 표시"
L["MinimapDetailsDescription"] = "적의 이름 옆에 레벨/직업을 지도 툴팁에 표시하려면 체크하십시오."
L["DisplayOnMap"] = "지도에 아이콘 표시"
L["DisplayOnMapDescription"] = "Display map icons for the location of other Spy users in your party, raid and guild when they detect enemies."
L["SwitchToZone"] = "적 탐지시 현재 지역으로 지도 전환"
L["SwitchToZoneDescription"] = "적이 감지되면 플레이어의 현재 영역 맵으로 맵을 변경하십시오."
L["MapDisplayLimit"] = "지도 아이콘 표시 제한:"
L["LimitNone"] = "모든 곳"
L["LimitNoneDescription"] = "현재 위치와 상관 없이 탐지된 모든 적을 지도에 표시합니다."
L["LimitSameZone"] = "같은 지역"
L["LimitSameZoneDescription"] = "같은 지역에 있는 탐지된 적만 지도에 표시합니다."
L["LimitSameContinent"] = "같은 대륙"
L["LimitSameContinentDescription"] = "같은 대륙에 있는 탐지된 적만 지도에 표시합니다."

-- Data Management
L["DataOptions"] = "데이터 관리"
L["DataOptionsDescription"] = [[

Spy 가 데이터를 유지 관리하고 수집하는 방법에 대한 옵션.
]]
L["PurgeData"] = "일정 기간 후 적 데이터 삭제:"
L["OneDay"] = "1 일"
L["OneDayDescription"] = "1 일 동안 탐지되지 않은 적 플레이어의 데이터를 삭제합니다."
L["FiveDays"] = "5 일"
L["FiveDaysDescription"] = "5 일 동안 탐지되지 않은 적 플레이어의 데이터를 삭제합니다."
L["TenDays"] = "10 일"
L["TenDaysDescription"] = "10 일 동안 탐지되지 않은 적 플레이어의 데이터를 삭제합니다."
L["ThirtyDays"] = "30 일"
L["ThirtyDaysDescription"] = "30 일 동안 탐지되지 않은 적 플레이어의 데이터를 삭제합니다."
L["SixtyDays"] = "60 일"
L["SixtyDaysDescription"] = "60 일 동안 탐지되지 않은 적 플레이어의 데이터를 삭제합니다."
L["NinetyDays"] = "90 일"
L["NinetyDaysDescription"] = "90 일 동안 탐지되지 않은 적 플레이어의 데이터를 삭제합니다."
L["PurgeKoS"] = "탐지되지 않은 시간을 기준으로 살생부 명단의 플레이어를 삭제"
L["PurgeKoSDescription"] = "시간 설정 값 기준으로 탐지되지 않는 살생부 명단의 적 플레이어 데이터를 삭제하려면 체크하십시오."
L["PurgeWinLossData"] = "탐지되지 않은 시간을 기준으로 승/패 데이터 삭제"
L["PurgeWinLossDataDescription"] = "시간 설정 값 기준으로 탐지되지 않는 적 플레이어의 승/패 데이터를 삭제하려면 체크하십시오."
L["ShareData"] = "다른 Spy 애드온 유저와 데이터 공유"
L["ShareDataDescription"] = "Spy 애드온을 사용하는 파티원, 길드원, 공격대원과 적 플레이어 정보를 공유하려면 체크하십시오."
L["UseData"] = "다른 Spy 애드온 유저의 데이터를 사용"
L["UseDataDescription"] = "Spy 애드온을 사용하는 파티원, 길드원, 공격대원의 적 플레이어 정보를 수집하려면 체크하십시오."
L["ShareKOSBetweenCharacters"] = "캐릭터 간 살생부 공유"
L["ShareKOSBetweenCharactersDescription"] = "같은 서버, 같은 진영의 캐릭터와 살생부로 표시한 적 플레이어를 공유하려면 체크하십시오."

-- Commands
L["SlashCommand"] = "Slash 명령어"
L["SpySlashDescription"] = "이 버튼은 /spy 명령어와 동일한 작업을 수행합니다."
L["Enable"] = "활성화"
L["EnableDescription"] = "Spy를 활성화 하고 Spy 창을 띄웁니다."
L["Show"] = "표시"
L["ShowDescription"] = "Spy 창을 띄웁니다."
L["Hide"] = "숨는 장소"
L["HideDescription"] = "메인 윈도우를 숨 깁니다."
L["Reset"] = "초기화"
L["ResetDescription"] = "Spy 창의 외형과 위치를 초기화 합니다."
L["ClearSlash"] = "지우기"
L["ClearSlashDescription"] = "탐지된 적 플레이어의 명단을 지웁니다."
L["Config"] = "설정"
L["ConfigDescription"] = "Spy 애드온 설정창을 엽니다."
L["KOS"] = "살생부"
L["KOSDescription"] = "적 플레이어를 살생부에 추가/제거 합니다."
L["InvalidInput"] = "잘못된 입력"
L["Ignore"] = "제외"
L["IgnoreDescription"] = "적 플레이어를 제외 목록에 추가/제거 합니다."
L["Test"] = "Test"
L["TestDescription"] = "위치를 조정할 수 있도록 경고를 표시합니다."
L["Sanctuary"] = "Sanctuary"
L["SanctuaryDescription"] = "Show/Hide Spy in a Sanctuary area."

-- Lists
L["Nearby"] = "근접한 적"
L["LastHour"] = "1시간 내"
L["Ignore"] = "제외"
L["KillOnSight"] = "살생부"

--Stats
L["Won"] = "승"
L["Lost"] = "패"
L["Time"] = "시간"	
L["List"] = "표식"
L["Filter"] = "검색"
L["Show Only"] = "필터"
L["Realm"] = "서버"
L["KOS"] = "살생부"
L["Won/Lost"] = "승/패"
L["Reason"] = "이유"	 
L["HonorKills"] = "명예 킬"
L["PvPDeaths"] = "PvP 죽음"

-- Output Messages
L["VersionCheck"] = "|cffc41e3a경고! 잘못된 Spy 버전이 설치되었습니다. Uninstall this version and install the one that matches your current game version."
L["SpyEnabled"] = "|cff9933ffSpy 애드온이 활성화되었습니다.."
L["SpyDisabled"] = "|cff9933ffSpy 애드온이 비활성화되었습니다. |cffffffff/spy show|cff9933ff 을 입력해 활성화 시키십시오."
L["UpgradeAvailable"] = "|cff9933ffA Spy의 새로운 버전을 사용할 수 있습니다. 다운로드 주소:\n|cffffffffhttps://www.curseforge.com/wow/addons/spy"
L["AlertStealthTitle"] = "은신한 적이 탐지되었습니다!"
L["AlertKOSTitle"] = "살생부 명단의 적이 탐지되었습니다!"
L["AlertKOSGuildTitle"] = "살생부 명단의 적 길드가 탐지되었습니다!"
L["AlertTitle_kosaway"] = "살생부 명단의 적의 위치: "
L["AlertTitle_kosguildaway"] = "살생부 명단의 적 길드의 위치: "
L["StealthWarning"] = "|cff9933ff은신한 적 탐지: |cffffffff"
L["KOSWarning"] = "|cffff0000살생부 명단의 적 탐지: |cffffffff"
L["KOSGuildWarning"] = "|cffff0000살생부 명단의 적 길드 탐지: |cffffffff"
L["SpySignatureColored"] = "|cff9933ff[Spy] "
L["PlayerDetectedColored"] = "적 플레이어 탐지: |cffffffff"
L["PlayersDetectedColored"] = "다수의 적 플레이어 탐지: |cffffffff"
L["KillOnSightDetectedColored"] = "살생부 명단의 적 탐지: |cffffffff"
L["PlayerAddedToIgnoreColored"] = "제외 목록에 플레이어 추가: |cffffffff"
L["PlayerRemovedFromIgnoreColored"] = "제외 목록에 플레이어 삭제: |cffffffff"
L["PlayerAddedToKOSColored"] = "살생부 명단에 플레이어 추가: |cffffffff"
L["PlayerRemovedFromKOSColored"] = "살생부 명단에 플레이어 삭제: |cffffffff"
L["PlayerDetected"] = "[Spy] 적 플레이어 탐지: "
L["KillOnSightDetected"] = "[Spy] 살생부 명단의 적 탐지: "
L["Level"] = "레벨"
L["LastSeen"] = "마지막 탐지"
L["LessThanOneMinuteAgo"] = "1분 미만"
L["MinutesAgo"] = "분 전"
L["HoursAgo"] = "시간 전"
L["DaysAgo"] = "일 전"
L["Close"] = "닫기"
L["CloseDescription"] = "|cffffffffSpy창을 숨깁니다. 기본적으로 적 플레이어가 탐지되면 다시 표시됩니다."
L["Left/Right"] = "왼쪽/오른쪽"
L["Left/RightDescription"] = "|cffffffff근접한 적, 1시간 이내, 제외 목록, 살생부 명단으로 이동합니다."
L["Clear"] = "지우기"
L["ClearDescription"] = "|cffffffff탐지된 적 플레이어 명단을 지웁니다. Ctrl + 왼쪽 클릭으로 Spy 애드온을 중지 / 시작할 수 있습니다. Shift- 클릭은 모든 사운드를 켜거나 끕니다."
L["SoundEnabled"] = "소리 알림이 활성화되었습니다"
L["SoundDisabled"] = "소리 알림이 비활성화되었습니다"
L["NearbyCount"] = "근접한 적 인원"
L["NearbyCountDescription"] = "|cffffffff자신에게 근접한 적의 수를 나타냅니다."
L["Statistics"] = "목록"
L["StatsDescription"] = "|cffffffff기록한 적 플레이어의 정보와 승/패, 마지막 탐지 시간을 보여줍니다."
L["AddToIgnoreList"] = "제외 목록에 추가"
L["AddToKOSList"] = "살생부 명단에 추가"
L["RemoveFromIgnoreList"] = "제외 목록에서 삭제"
L["RemoveFromKOSList"] = "살생부 명단에서 삭제"
L["RemoveFromStatsList"] = "목록에서 삭제"
L["AnnounceDropDownMenu"] = "알림"
L["KOSReasonDropDownMenu"] = "살생부 이유 설정"
L["PartyDropDownMenu"] = "파티"
L["RaidDropDownMenu"] = "공격대"
L["GuildDropDownMenu"] = "길드"
L["LocalDefenseDropDownMenu"] = "수비"
L["Player"] = " (플레이어)"
L["KOSReason"] = "살생부"
L["KOSReasonIndent"] = "    "
L["KOSReasonOther"] = "이유를 입력하세요..."
L["EnterKOSReason"] = "%s 의 살생부 이유 작성"
L["KOSReasonClear"] = "이유 지우기"
L["StatsWins"] = "|cff40ff00승: "
L["StatsSeparator"] = "  "
L["StatsLoses"] = "|cff0070dd패: "
L["Located"] = "위치:"
L["DistanceUnit"] = "야드"
L["LocalDefenseChannelName"] = "수비"

Spy_KOSReasonListLength = 6
Spy_KOSReasonList = {
	[1] = {
		["title"] = "전투 시작할 때";
		["content"] = {
			"아무 이유없이 공격",
			"퀘스트 NPC를 공격", 
			"몬스터와 싸울때 공격",
			"던전 근처에서 공격",
			"자리비움 상태에 공격",
			"탈 것을 타는 중에 공격",
			"HP/MP가 부족할 때 공격",
		};
	},
	[2] = {
		["title"] = "전투 스타일";
		["content"] = {
			"뒤에서 습격",
			"항상 나를 보자마자 공격함",
			"높은 레벨로 죽임",
			"단체로 공격",
			"항상 근처에 아군이 있음",
			"항상 도움을 요청",
			"많은 CC기 사용",
		};
	},
	[3] = {
		["title"] = "시체지키기";
		["content"] = {
			"시체지킴",
			"눂은곳에서 시체지킴",
			"낮은 레벨을 시체지킴",
			"은신을 하며 시체지킴",
			"길드맴버와 시체지킴",
			"NPC/목표를 지킴",
			"도시/지역을 지킴",
		};
	},
	[4] = {
		["title"] = "퀘스트";
		["content"] = {
			"퀘스트 하는 와중에 공격",
			"퀘스트를 도와줬는데도 공격",
			"퀘스트를 방해",
			"하고 싶은 퀘스트를 먼저 진행",
			"아군 진영 NPC를 죽임",
			"퀘스트 NPC를 죽임",
		};
	},
	[5] = {
		["title"] = "자원 스틸";
		["content"] = {
			"원하는 약초를 채집",
			"원하는 광물을 채집",
			"원하는 재료를 채집",
			"타겟과 희귀 NPC를 스틸함",
			"내 목표의 가죽을 채집",
			"내 목표를 구함",
			"내 낚시터를 사용",
		};
	},
	[6] = {
		["title"] = "기타";
		["content"] = {
			"PVP 상태 활성화",
			"낭떠러지에서 밈",
			"엔지니어링 트릭을 사용",
			"항상 탈출을 고려함",
			"아이템과 기술을 사용해서 탈출",
			"게임 역학을 이용함",
			"이유를 입력하세요...",
		};
	},
}

-- Class descriptions
L["UNKNOWN"] = "미확인"
L["DRUID"] = "드루이드"
L["HUNTER"] = "사냥꾼"
L["MAGE"] = "마법사"
L["PALADIN"] = "성기사"
L["PRIEST"] = "사제"
L["ROGUE"] = "도적"
L["SHAMAN"] = "주술사"
L["WARLOCK"] = "흑마법사"
L["WARRIOR"] = "전사"
L["DEATHKNIGHT"] = "죽음의 기사"
L["MONK"] = "수도사"
L["DEMONHUNTER"] = "악마사냥꾼"
L["EVOKER"] = "기원사"

-- Race descriptions
L["Human"] = "인간"
L["Orc"] = "오크"
L["Dwarf"] = "드워프"
L["Tauren"] = "타우렌"
L["Troll"] = "트롤"
L["Night Elf"] = "나이트 엘프"
L["Undead"] = "언데드"
L["Gnome"] = "노움"
L["Blood Elf"] = "블러드 엘프"
L["Draenei"] = "드레나이"
L["Goblin"] = "고블린"
L["Worgen"] = "늑대인간"
L["Pandaren"] = "판다렌"
L["Highmountain Tauren"] = "높은산 타우렌"
L["Lightforged Draenei"] = "빛벼림 드레나이"
L["Nightborne"] = "나이트본"
L["Void Elf"] = "공허 엘프"
L["Dark Iron Dwarf"] = "검은무쇠 드워프"
L["Mag'har Orc"] = "마그하르 오크"
L["Kul Tiran"] = "쿨 티란"
L["Zandalari Troll"] = "잔달라 트롤"
L["Mechagnome"] = "기계노움"
L["Vulpera"] = "불페라"
L["Dracthyr"] = "드랙티르"
L["Earthen"] = "토석인"

-- Stealth abilities
L["Stealth"] = "은신"
L["Prowl"] = "숨기"

-- Minimap color codes
L["MinimapGuildText"] = "|cffffffff"
L["MinimapClassTextUNKNOWN"] = "|cff191919"
L["MinimapClassTextDRUID"] = "|cffff7c0a"
L["MinimapClassTextHUNTER"] = "|cffaad372"
L["MinimapClassTextMAGE"] = "|cff68ccef"
L["MinimapClassTextPALADIN"] = "|cfff48cba"
L["MinimapClassTextPRIEST"] = "|cffffffff"
L["MinimapClassTextROGUE"] = "|cfffff468"
L["MinimapClassTextSHAMAN"] = "|cff2359ff"
L["MinimapClassTextWARLOCK"] = "|cff9382c9"
L["MinimapClassTextWARRIOR"] = "|cffc69b6d"
L["MinimapClassTextDEATHKNIGHT"] = "|cffc41e3a"
L["MinimapClassTextMONK"] = "|cff00ff96"
L["MinimapClassTextDEMONHUNTER"] = "|cffa330c9"
L["MinimapClassTextEVOKER"] = "|cff33937f"

Spy_IgnoreList = {
	["우체통"]=true, 
	["보물 상자"]=true, 
	["작은 보물 상자"]=true,	
};