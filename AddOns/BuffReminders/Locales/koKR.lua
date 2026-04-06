local _, BR = ... -- luacheck: ignore 211
if GetLocale() ~= "koKR" then
    return
end

local L = BR.L -- luacheck: ignore 211

-- Credit by Elnarfim

-- ============================================================================
-- CATEGORY LABELS
-- ============================================================================
L["Category.Raid"] = "공격대 버프"
L["Category.Presence"] = "특수 버프"
L["Category.Targeted"] = "대상 지정"
L["Category.Self"] = "자신"
L["Category.Pet"] = "소환수"
L["Category.Consumable"] = "소모품"
L["Category.Custom"] = "사용자 지정"

-- Long form (used in Options section headers)
L["Category.RaidBuffs"] = "공격대 버프"
L["Category.TargetedBuffs"] = "대상 지정 버프"
L["Category.Consumables"] = "소모품"
L["Category.PresenceBuffs"] = "특수 버프"
L["Category.SelfBuffs"] = "내 전용 버프"
L["Category.PetReminders"] = "소환수 알림"
L["Category.CustomBuffs"] = "사용자 지정 버프"

-- Category notes
L["Category.RaidNote"] = "(그룹 전체 대상)"
L["Category.TargetedNote"] = "(다른 대상에게 거는 버프)"
L["Category.ConsumableNote"] = "(물약, 음식, 룬, 오일)"
L["Category.PresenceNote"] = "(최소 1명 필요)"
L["Category.SelfNote"] = "(자신에게만 거는 버프)"
L["Category.PetNote"] = "(소환수 소환 알림)"
L["Category.CustomNote"] = "(주문 ID로 버프/반짝임 추적)"

-- ============================================================================
-- BUFF OVERLAY TEXT
-- ============================================================================
-- These must be kept very short (2-4 chars per line) to fit on small icons.
L["Overlay.NoDrPoison"] = "독\n없음"
L["Overlay.NoAura"] = "오라\n없음"
L["Overlay.NoStone"] = "영석\n없음"
L["Overlay.NoFaith"] = "신봉\n없음"
L["Overlay.NoLight"] = "봉화\n없음"
L["Overlay.NoES"] = "대보\n없음"
L["Overlay.NoSource"] = "원천\n없음"
L["Overlay.NoScales"] = "비늘\n없음"
L["Overlay.NoLink"] = "공생\n없음"
L["Overlay.NoAttune"] = "조율\n없음"
L["Overlay.NoFamiliar"] = "전령\n없음"
L["Overlay.DropWell"] = "영혼샘\n깔기"
L["Overlay.NoGrim"] = "흑마법서\n없음"
L["Overlay.BurningRush"] = "RUSH"
L["Overlay.NoRite"] = "의식\n없음"
L["Overlay.ApplyPoison"] = "독\n바르기"
L["Overlay.NoForm"] = "형상\n꺼짐"
L["Overlay.NoEL"] = "대지생명\n없음"
L["Overlay.NoFT"] = "불꽃\n없음"
L["Overlay.NoTG"] = "수호\n없음"
L["Overlay.NoWF"] = "바람분노\n없음"
L["Overlay.NoSelfES"] = "내 대보\n없음"
L["Overlay.NoShield"] = "보호막\n없음"
L["Overlay.NoPet"] = "소환수\n없음"
L["Overlay.PassivePet"] = "수동적\n소환수"
L["Overlay.WrongPet"] = "잘못된\n소환수"
L["Overlay.NoRune"] = "증강\n없음"
L["Overlay.DKWrongRune"] = "룬 조각\n오류"
L["Overlay.DKWrongRuneOH"] = "보조손\n룬\n오류"
L["Overlay.NoFlask"] = "영약\n없음"
L["Overlay.NoFood"] = "음식\n없음"
L["Overlay.NoWeaponBuff"] = "무기 버프\n없음"
L["Overlay.Buff"] = "버프!"
L["Overlay.MinutesFormat"] = "%d분"
L["Overlay.LessThanOneMinute"] = "<1분"
L["Overlay.SecondsFormat"] = "%d초"

-- ============================================================================
-- BUFF GROUP DISPLAY NAMES
-- ============================================================================
L["Group.Beacons"] = "봉화"
L["Group.DKRunes"] = "룬 조각"
L["Group.ShamanImbues"] = "주술사 무기 강화"
L["Group.PaladinRites"] = "성기사 의식"
L["Group.Pets"] = "소환수"
L["Group.ShamanShields"] = "주술사 보호막"
L["Group.Flask"] = "영약"
L["Group.Food"] = "음식"
L["Group.DelveFood"] = "구렁 음식"
L["Group.Healthstone"] = "생명석"
L["Group.AugmentRune"] = "증강 룬"
L["Group.WeaponBuff"] = "무기 버프"

-- ============================================================================
-- BUFF INFO TOOLTIPS
-- ============================================================================
L["Tooltip.MayShowExtraIcon"] = "추가 아이콘이 표시될 수 있음"
L["Tooltip.MayShowExtraIcon.Desc"] =
    "이 주문을 시전하기 전까지, 이 알림과 물/번개 보호막 알림이 동시에 표시될 수 있습니다. 대지의 보호막을 자신에게 걸려는 건지, 아니면 아군에게 걸고 자신은 물/번개 보호막을 걸려는 건지 구분할 수 없기 때문입니다."
L["Tooltip.InstanceEntryReminder"] = "인스턴스 입장 알림"
L["Tooltip.InstanceEntryReminder.Desc"] =
    "던전 입장 시 영혼샘을 깔라는 알림이 잠시 표시됩니다. 시전하거나 30초가 지나면 사라집니다."
L["Tooltip.DelvesOnly"] = "구렁 전용"
L["Tooltip.DelvesOnly.Desc"] =
    "구렁 입장 시 발리라의 음식을 먹으라는 알림이 잠시 표시됩니다. 30초 후 또는 버프가 감지되면 사라집니다."

-- ============================================================================
-- GLOW TYPE NAMES
-- ============================================================================
L["Glow.Pixel"] = "픽셀"
L["Glow.AutoCast"] = "자동 시전"
L["Glow.Border"] = "테두리"
L["Glow.Proc"] = "발동"

-- ============================================================================
-- CORE
-- ============================================================================
L["Core.Any"] = "모두"

-- ============================================================================
-- PROFILES
-- ============================================================================
L["Profile.SwitchQueued"] = "전투 종료 후 프로필이 전환됩니다."
L["Profile.Switched"] = "'%s' 프로필로 전환했습니다."

-- ============================================================================
-- MOVERS
-- ============================================================================
L["Mover.SetPosition"] = "위치 설정"
L["Mover.AnchorFrame"] = "고정할 프레임"
L["Mover.AnchorPoint"] = "고정 지점"
L["Mover.NoneScreenCenter"] = "없음 (화면 중앙)"
L["Mover.Apply"] = "적용"
L["Mover.BuffAnchor"] = "버프 위치"
L["Mover.DragTooltip"] = "드래그로 위치 조정\n클릭으로 좌표 편집기 열기/닫기"
L["Mover.MainEmpty"] = "메인 (비어있음)"
L["Mover.MainAll"] = "메인 (전체)"
L["Mover.Detached"] = "분리됨"

-- ============================================================================
-- DISPLAY
-- ============================================================================
L["Display.FramesLocked"] = "프레임 위치를 고정했습니다."
L["Display.FramesUnlocked"] = "프레임의 고정이 해제됐습니다."
L["Display.MinimapHidden"] = "미니맵 아이콘이 숨겨졌습니다."
L["Display.MinimapShown"] = "미니맵 아이콘이 표시됩니다."
L["Display.Description"] = "누락된 버프를 한꺼번에 확인하세요."
L["Display.OpenOptions"] = "옵션 열기"
L["Display.SlashCommands"] = "슬래시 명령어: /br, /br lock, /br unlock, /br test, /br minimap"
L["Display.MinimapLeftClick"] = "|cFFCFCFCF좌클릭|r: 옵션"
L["Display.MinimapRightClick"] = "|cFFCFCFCF우클릭|r: 테스트 모드"
L["Display.DismissConsumables"] = "다음 로딩 화면 전까지 소모품 알림 숨기기"
L["Display.LoginFirstInstall"] =
    "설치해 주셔서 감사합니다! |cFFFFD100/br unlock|r을 입력하여 버프 표시를 이동하거나, |cFFFFD100/br|r 옵션 패널 하단의 버튼을 사용하세요."
L["Display.LoginGearIcons"] =
    "일부 버프 설정(생명석, 영혼석, 소환수)이 버프 탭의 체크박스 옆 톱니바퀴 아이콘으로 이동했습니다."

-- ============================================================================
-- OPTIONS: TAB LABELS
-- ============================================================================
L["Tab.Buffs"] = "버프"
L["Tab.DisplayBehavior"] = "표시/동작"
L["Tab.Settings"] = "설정"
L["Tab.Profiles"] = "프로필"

-- ============================================================================
-- OPTIONS: GLOBAL DEFAULTS
-- ============================================================================
L["Options.GlobalDefaults"] = "전체 기본값"
L["Options.GlobalDefaults.Note"] =
    "(사용자 지정 외형으로 덮어쓰지 않는 한 모든 카테고리에 적용됨)"
L["Options.Default"] = "기본값"
L["Options.Font"] = "폰트"

-- ============================================================================
-- OPTIONS: GLOW SETTINGS
-- ============================================================================
L["Options.GlowReminderIcons"] = "알림 아이콘 반짝임"
L["Options.GlowReminderIcons.Title"] = "알림 아이콘 반짝임"
L["Options.GlowReminderIcons.Desc"] =
    "누락 및 만료 버프를 포함해 표시되는 모든 알림 아이콘에 반짝임 효과를 추가합니다."
L["Options.GlowKind.Expiring"] = "만료"
L["Options.GlowKind.Missing"] = "누락"
L["Options.GlowSettings.Expiring"] = "반짝임 설정 — 만료"
L["Options.GlowSettings.Missing"] = "반짝임 설정 — 누락"
L["Options.Glow.Enabled"] = "활성화"
L["Options.Threshold"] = "기준값"
L["Options.GlowMissingPets"] = "누락 소환수 반짝임"
L["Options.CustomGlowStyle"] = "사용자 지정 반짝임 스타일"
L["Options.Expiration"] = "만료"
L["Options.Glow"] = "반짝임"
L["Options.UseCustomColor"] = "사용자 지정 색상 사용"
L["Options.UseCustomColor.Desc"] =
    "활성화하면 발동 반짝임의 채도를 낮추고 색상을 변경합니다.\n기본 발동 반짝임보다 덜 선명하게 보일 수 있습니다."
L["Options.ExpirationReminder"] = "만료 알림"

-- Glow params
L["Options.Glow.Type"] = "유형:"
L["Options.Glow.Size"] = "크기:"
L["Options.Glow.Duration"] = "지속시간"
L["Options.Glow.Frequency"] = "빈도"
L["Options.Glow.Length"] = "길이"
L["Options.Glow.Lines"] = "선"
L["Options.Glow.Particles"] = "입자"
L["Options.Glow.Scale"] = "크기 비율"
L["Options.Glow.Speed"] = "속도"
L["Options.Glow.StartAnimation"] = "시작 애니메이션"
L["Options.Glow.XOffset"] = "X 조정"
L["Options.Glow.YOffset"] = "Y 조정"

-- ============================================================================
-- OPTIONS: CONTENT VISIBILITY
-- ============================================================================
L["Options.HidePvPMatchStart"] = "PvP 경기 시작 시 숨기기"
L["Options.HidePvPMatchStart.Title"] = "PvP 경기 시작 시 숨기기"
L["Options.HidePvPMatchStart.Desc"] =
    "PvP 경기가 시작되면 (준비 단계 종료 후) 이 카테고리를 숨깁니다."
L["Options.ReadyCheckOnly"] = "전투 준비 시에만 표시"
L["Options.ReadyCheckOnly.Desc"] = "전투 준비 후 15초 동안만 이 카테고리의 버프를 표시합니다."
L["Options.Visibility"] = "표시 조건"
L["Options.PerCategoryCustomization"] = "카테고리별 사용자 지정"
L["Options.DetachIcon"] = "분리"
L["Options.DetachIcon.Desc"] =
    "이 아이콘을 독립적으로 위치를 옮길 수 있는 별도의 프레임으로 이동시킵니다."

-- ============================================================================
-- OPTIONS: HEALTHSTONE
-- ============================================================================
L["Options.Healthstone.ReadyCheckOnly"] = "전투 준비 시에만"
L["Options.Healthstone.ReadyCheckWarlock"] = "전투 준비 + 흑마법사는 항상 표시"
L["Options.Healthstone.AlwaysShow"] = "항상 표시"
L["Options.Healthstone.Visibility"] = "생명석 표시"
L["Options.Healthstone.Visibility.Desc"] =
    "생명석 알림이 표시되는 시점을 설정합니다.\n\n|cffffcc00전투 준비 시에만:|r 전투 준비(15초)때만 표시.\n|cffffcc00전투 준비 + 흑마법사는 항상 표시:|r 흑마법사는 항상 표시, 다른 직업은 전투 준비때만.\n|cffffcc00항상 표시:|r 설정에 맞는 콘텐츠에 있을 때 항상 표시."
L["Options.Healthstone.WarlockAlwaysDesc"] =
    "흑마법사는 항상 알림 표시, 다른 직업은 전투 준비때만"
L["Options.Healthstone.ReadyCheckDesc"] = "전투 준비 후 15초 동안 표시"
L["Options.Healthstone.AlwaysDesc"] = "해당 콘텐츠 유형과 일치할 때 항상 표시"
L["Options.Healthstone.LowStock"] = "부족 시 경고"
L["Options.Healthstone.LowStock.Desc"] =
    "생명석이 있지만 부족할 때 경고를 표시합니다. 생명석이 없는 경우(0개)는 이 설정과 관계없이 항상 추적됩니다."
L["Options.Healthstone.Threshold"] = "경고 기준 수량"
L["Options.Healthstone.Threshold.Desc"] =
    "생명석이 이 수량 이하일 때 부족 경고를 표시합니다.\n\n|cffffcc001:|r 정확히 1개일 때 경고.\n|cffffcc002:|r 1개 또는 2개일 때 경고."

-- ============================================================================
-- OPTIONS: SOULSTONE
-- ============================================================================
L["Options.Soulstone.Visibility"] = "영혼석 표시"
L["Options.Soulstone.Visibility.Desc"] =
    "영혼석 알림이 표시되는 시점을 설정합니다.\n\n|cffffcc00전투 준비 시에만:|r 전투 준비 시에만 표시 (기본값).\n|cffffcc00전투 준비 + 흑마법사는 항상 표시:|r 흑마법사는 항상 보이고, 다른 직업은 전투 준비 시에만.\n|cffffcc00항상 표시:|r 존재 카테고리가 보일 때마다 표시."
L["Options.Soulstone.ReadyCheckOnly"] = "전투 준비 시에만"
L["Options.Soulstone.ReadyCheckWarlock"] = "전투 준비 + 흑마법사는 항상 표시"
L["Options.Soulstone.AlwaysShow"] = "항상 표시"
L["Options.Soulstone.ReadyCheckDesc"] = "전투 준비 후 15초 동안 표시"
L["Options.Soulstone.WarlockAlwaysDesc"] = "흑마법사는 항상 알림 표시, 다른 직업은 전투 준비때만"
L["Options.Soulstone.AlwaysDesc"] = "존재 카테고리가 보일 때마다 표시"
L["Options.Soulstone.HideCooldown"] = "재사용 대기 중 숨기기 (흑마법사)"
L["Options.Soulstone.HideCooldown.Desc"] =
    "활성화 시, 주문이 재사용 대기 중일 때 흑마법사에게 영혼석 알림을 표시하지 않습니다. 흑마법사에게만 적용됩니다."

-- ============================================================================
-- OPTIONS: FREE CONSUMABLES
-- ============================================================================
L["Options.FreeConsumables"] = "무료 소모품"
L["Options.FreeConsumables.Note"] = "(생명석, 영구 증강 룬)"
L["Options.FreeConsumables.Override"] = "콘텐츠 필터 임의 적용"
L["Options.FreeConsumables.Override.Desc"] =
    "체크 시, 무료 소모품은 아래 임의의 콘텐츠 유형 설정을 사용합니다.\n\n체크 해제 시, 다른 소모품과 동일한 콘텐츠 필터를 따릅니다."

-- ============================================================================
-- OPTIONS: ICONS
-- ============================================================================
L["Options.Icons"] = "아이콘"
L["Options.ShowText"] = "아이콘에 텍스트 표시"
L["Options.ShowText.Desc"] =
    "이 카테고리의 버프 아이콘에 횟수나 누락 텍스트 오버레이를 표시합니다."
L["Options.ShowMissingCountOnly"] = "누락 숫자만 표시"
L["Options.ShowMissingCountOnly.Desc"] =
    '전체 숫자(예: "19/20") 대신 누락된 버프 수(예: "1")만 표시합니다.'
L["Options.ShowBuffReminderText"] = '"버프!" 알림 텍스트 표시'
L["Options.BuffTextOffsetX"] = '"버프!" X'
L["Options.BuffTextOffsetY"] = '"버프!" Y'
L["Options.Size"] = "크기"

-- ============================================================================
-- OPTIONS: CLICK TO CAST
-- ============================================================================
L["Options.ClickToCast"] = "클릭으로 시전"
L["Options.ClickToCast.DescFull"] =
    "버프 아이콘을 클릭해 해당 주문을 시전할 수 있습니다.(비전투 시에만) 당신의 캐릭터가 시전 가능한 주문에만 작동합니다."
L["Options.HoverHighlight"] = "마우스 오버 강조"
L["Options.HoverHighlight.Desc"] =
    "클릭 가능한 버프 아이콘에 마우스를 올리면 희미한 강조 효과가 표시됩니다."

-- ============================================================================
-- OPTIONS: PET
-- ============================================================================
L["Options.PetSpecIcon"] = "마우스 오버시 사냥꾼 소환수 특성 아이콘 표시"
L["Options.PetSpecIcon.Title"] = "마우스 오버시 소환수 특성 아이콘"
L["Options.PetSpecIcon.Desc"] =
    "마우스를 올리면 소환수 아이콘이 해당 특성 능력(교활, 야성, 인내)으로 바뀝니다."
L["Options.ShowItemTooltips"] = "아이템 툴팁 표시"
L["Options.ShowItemTooltips.Desc"] =
    "소모품 아이콘에 마우스를 올리면 아이템 툴팁이 표시됩니다."
L["Options.Behavior"] = "동작"
L["Options.PetPassiveCombat"] = "전투 중에만 수동적 소환수 알림"
L["Options.PetPassiveCombat.Desc"] =
    "전투 중에만 수동적 소환수 알림을 표시합니다. 비활성화 시 항상 표시됩니다."
L["Options.FelDomination"] = "소환 전 지옥 지배 사용"
L["Options.FelDomination.Title"] = "지옥 지배"
L["Options.FelDomination.Desc"] =
    "클릭 시전으로 악마를 소환하기 전에 자동으로 지옥 지배를 시전합니다. 지옥 지배가 쿨타임일 땐 소환은 일반 방식대로 진행됩니다. 지옥 지배 특성이 필요합니다."

-- ============================================================================
-- OPTIONS: PET DISPLAY
-- ============================================================================
L["Options.PetDisplay"] = "소환수 표시"
L["Options.PetDisplay.Generic"] = "기본 아이콘"
L["Options.PetDisplay.GenericDesc"] = "단일 기본 '소환수 없음' 아이콘"
L["Options.PetDisplay.Summon"] = "소환 주문"
L["Options.PetDisplay.SummonDesc"] = "각 소환수 주문을 개별 아이콘으로 표시"
L["Options.PetDisplay.Mode"] = "소환수 표시 모드"
L["Options.PetDisplay.Mode.Desc"] = "누락 소환수 알림의 표시 방식을 설정합니다."
L["Options.PetLabels"] = "소환수 레이블"
L["Options.PetLabels.Desc"] = "각 아이콘 아래에 소환수 이름과 특성을 표시합니다."
L["Options.PetLabels.SizePct"] = "크기 %"

-- ============================================================================
-- OPTIONS: CONSUMABLE DISPLAY
-- ============================================================================
L["Options.ConsumableTextScale"] = "텍스트 크기"
L["Options.ConsumableTextScale.Title"] = "소모품 텍스트 크기"
L["Options.ConsumableTextScale.Desc"] =
    "아이콘 크기 대비 아이템 수량 및 등급(R1/R2/R3) 레이블의 폰트 크기 비율입니다."
L["Options.ItemDisplay"] = "아이템 표시"
L["Options.ItemDisplay.IconOnly"] = "아이콘만 표시"
L["Options.ItemDisplay.IconOnlyDesc"] = "수량이 가장 많은 아이템 표시"
L["Options.ItemDisplay.SubIcons"] = "하위 아이콘"
L["Options.ItemDisplay.SubIconsDesc"] = "각 아이콘 아래에 작은 아이템 변형 아이콘 표시"
L["Options.ItemDisplay.Expanded"] = "확장"
L["Options.ItemDisplay.ExpandedDesc"] = "각 아이템 변형을 전체 크기 아이콘으로 표시"
L["Options.ItemDisplay.Mode"] = "소모품 아이템 표시"
L["Options.ItemDisplay.Mode.Desc"] =
    "여러 변종이 있는 소모품 아이템(예: 다양한 영약 유형)의 표시 방식을 설정합니다."
L["Options.SubIconSide"] = "방향"
L["Options.SubIconSide.Bottom"] = "아래"
L["Options.SubIconSide.Top"] = "위"
L["Options.SubIconSide.Left"] = "왼쪽"
L["Options.SubIconSide.Right"] = "오른쪽"
L["Options.ShowWithoutItems"] = "소지품에 없을 때도 표시"
L["Options.ShowWithoutItems.Title"] = "아이템이 없어도 표시"
L["Options.ShowWithoutItems.Desc"] =
    "활성화 시, 소지품에 아이템이 없어도 소모품 알림이 표시됩니다. 비활성화 시, 실제로 보유한 소모품만 표시됩니다."
L["Options.DelveFoodOnly"] = "구렁에선 구렁 음식만 표시"
L["Options.DelveFoodOnly.Desc"] = "구렁에선 구렁 음식을 제외한 모든 소모품 알림을 숨깁니다."

-- ============================================================================
-- OPTIONS: DK RUNEFORGE PREFERENCES
-- ============================================================================
L["Options.RuneforgePreferences"] = "룬 조각 설정"
L["Options.RuneforgeNote"] =
    "각 전문화별 기대하는 룬 조각을 선택하세요. 잘못된 룬 조각이 적용되어 있거나 없으면 알림이 표시됩니다."
L["Options.RuneMainHand"] = "주 손"
L["Options.RuneOffHand"] = "보조 손"
L["Options.RuneTwoHanded"] = "양손"
L["Options.RuneDualWield"] = "쌍수"

-- ============================================================================
-- OPTIONS: BUFF SETTINGS GEAR ICONS
-- ============================================================================
L["Options.HealthstoneSettings"] = "생명석 설정"
L["Options.HealthstoneSettings.Note"] = "표시 조건 및 부족 기준값을 설정합니다."
L["Options.SoulstoneSettings"] = "영혼석 설정"
L["Options.SoulstoneSettings.Note"] = "영혼석 알림이 표시되는 시점을 설정합니다."
L["Options.PetPassiveSettings"] = "소환수 수동 설정"
L["Options.PetPassiveSettings.Note"] = "수동 모드 소환수 알림을 설정합니다."
L["Options.PetSummonSettings"] = "소환수 소환 설정"
L["Options.PetSummonSettings.Note"] = "소환수 소환 동작을 설정합니다."

-- ============================================================================
-- OPTIONS: LAYOUT
-- ============================================================================
L["Options.Layout"] = "레이아웃"
L["Options.Priority"] = "우선순위"
L["Options.Priority.Desc"] =
    "통합 프레임에서 이 카테고리의 순서를 조정합니다. 낮은 값이 먼저 표시됩니다."
L["Options.SplitFrame"] = "개별 프레임으로 분리"
L["Options.SplitFrame.Desc"] =
    "이 카테고리의 버프를 독립적으로 이동 가능한 별도의 프레임에 표시합니다."
L["Options.DisplayPriority"] = "표시 우선순위"

-- ============================================================================
-- OPTIONS: APPEARANCE
-- ============================================================================
L["Options.CustomAppearance"] = "사용자 지정 외형 사용"
L["Options.CustomAppearance.Desc"] =
    "비활성화 시, 이 카테고리는 전체 기본값의 외형 설정을 상속받습니다. 성장 방향은 개별 프레임으로 분리해야 합니다."
L["Options.Customize"] = "사용자 지정"
L["Options.ResetPosition"] = "위치 초기화"
L["Options.MasqueNote"] = "확대 및 테두리 설정은 Masque에서 관리합니다."

-- ============================================================================
-- OPTIONS: SETTINGS TAB
-- ============================================================================
L["Options.ShowLoginMessages"] = "로그인 메시지 표시"
L["Options.ShowMinimapButton"] = "미니맵 버튼 표시"
L["Options.ShowOnlyInGroup"] = "파티/공격대에서만 표시"

-- Hide when section
L["Options.HideWhen"] = "숨김 조건:"
L["Options.HideWhen.Resting"] = "휴식 중"
L["Options.HideWhen.Resting.Title"] = "휴식 중 숨김"
L["Options.HideWhen.Resting.Desc"] = "여관이나 대도시에 있을 때 버프 알림을 숨깁니다."
L["Options.HideWhen.Combat"] = "전투 중"
L["Options.HideWhen.Expiring"] = "전투 중에 만료 버프만"
L["Options.HideWhen.Expiring.Title"] = "전투 중 만료 버프 숨기기"
L["Options.HideWhen.Expiring.Desc"] =
    "전투 중에는 곧 끝날 버프를 숨기고 완전히 누락된 버프만 표시합니다."
L["Options.HideWhen.Vehicle"] = "차량 탑승 중"
L["Options.HideWhen.Vehicle.Title"] = "차량 탑승 중 숨기기"
L["Options.HideWhen.Vehicle.Desc"] =
    "퀘스트 차량을 이용 중일 때 모든 버프 알림을 숨깁니다. 비활성화 시에도 공격대 및 특수 버프는 표시됩니다."
L["Options.HideWhen.Mounted"] = "탈것 탔을 때"
L["Options.HideWhen.Mounted.Title"] = "탈것 타는 중 숨기기"
L["Options.HideWhen.Mounted.Desc"] =
    "탈것을 탔을 때 모든 버프 알림을 숨깁니다. 카테고리별 소환수 탈것 숨기기 설정보다 우선 적용됩니다."
L["Options.HideWhen.Legacy"] = "구 인스턴스"
L["Options.HideWhen.Legacy.Title"] = "구 인스턴스에서 숨기기"
L["Options.HideWhen.Legacy.Desc"] =
    "유산 전리품이 활성화된 구 인스턴스에서 모든 버프 알림을 숨깁니다."

-- ============================================================================
-- OPTIONS: BUFF TRACKING MODE
-- ============================================================================
L["Options.BuffTracking"] = "버프 추적"
L["Options.BuffTracking.All"] = "모든 버프, 모든 플레이어"
L["Options.BuffTracking.All.Desc"] =
    "모든 직업의 공격대 및 특수 버프를 표시하고 그룹 전체 적용 여부를 추적합니다."
L["Options.BuffTracking.MyBuffs"] = "내 버프만, 모든 플레이어"
L["Options.BuffTracking.MyBuffs.Desc"] =
    "내 직업이 제공할 수 있는 버프만 표시하되, 그룹 전체 적용 여부는 추적합니다."
L["Options.BuffTracking.OnlyMine"] = "내가 필요한 버프만"
L["Options.BuffTracking.OnlyMine.Desc"] =
    "모든 버프 유형을 표시하지만, 자신에게 적용됐는지만 확인합니다. 그룹 수량 없음."
L["Options.BuffTracking.Smart"] = "스마트"
L["Options.BuffTracking.Smart.Desc"] =
    "내 직업이 제공하는 버프는 그룹 전체 적용 여부를 추적하고, 다른 직업 버프는 자신에게만 확인합니다."
L["Options.BuffTracking.Mode"] = "버프 추적 모드"
L["Options.BuffTracking.Mode.Desc"] =
    "표시할 공격대 및 특수 버프와 그룹 전체 또는 자신만 추적할지 설정합니다."

-- ============================================================================
-- OPTIONS: PROFILES TAB
-- ============================================================================
L["Options.ActiveProfile"] = "활성 프로필"
L["Options.ActiveProfile.Desc"] =
    "저장된 설정 간에 전환합니다. 각 캐릭터마다 다른 프로필을 사용할 수 있습니다."
L["Options.SelectProfile"] = "프로필 선택"
L["Options.Profile"] = "프로필"
L["Options.CopyFrom"] = "다음에서 복사"
L["Options.Delete"] = "삭제"
L["Options.PerSpecProfiles"] = "전문화별 프로필"
L["Options.PerSpecProfiles.Desc"] = "전문화 변경 시 자동으로 프로필을 전환합니다."
L["Options.PerSpecProfiles.Enable"] = "전문화별 프로필 활성화"

-- ============================================================================
-- OPTIONS: IMPORT/EXPORT
-- ============================================================================
L["Options.ExportSettings"] = "설정 내보내기"
L["Options.ExportSettings.Desc"] = "아래 문자열을 복사해서 설정을 공유하세요."
L["Options.ImportSettings"] = "설정 가져오기"
L["Options.ImportSettings.DescPlain"] = "아래에 설정 문자열을 붙여넣으세요."
L["Options.ImportSettings.Overwrite"] = "활성 프로필을 덮어씁니다."
L["Options.Export"] = "내보내기"
L["Options.Import"] = "가져오기"
L["Options.ImportSuccess"] = "설정을 성공적으로 가져왔습니다!"
L["Options.FailedExport"] = "내보내기 실패"
L["Options.UnknownError"] = "알 수 없는 오류"

-- ============================================================================
-- OPTIONS: DIALOGS
-- ============================================================================
L["Dialog.Cancel"] = "취소"
L["Dialog.DeleteCustomBuff"] = '사용자 지정 버프 "%s"|1을;를; 삭제하시겠습니까?'
L["Dialog.ResetProfile"] =
    "활성 프로필을 기본값으로 초기화하시겠습니까?\n\n현재 프로필의 모든 사용자 지정 설정이\n삭제되고 UI가 재로드됩니다."
L["Dialog.Reset"] = "초기화"
L["Dialog.ReloadPrompt"] =
    "설정을 성공적으로 가져왔습니다!\n변경 사항을 적용하려면 UI를 재로드하시겠습니까?"
L["Dialog.Reload"] = "재로드"
L["Dialog.NewProfilePrompt"] = "새 프로필의 이름을 입력하세요:"
L["Dialog.Create"] = "생성"
L["Dialog.DiscordPrompt"] = "BuffReminders Discord에 참여하세요!\n아래 URL을 복사하세요 (Ctrl+C):"
L["Dialog.Close"] = "닫기"

-- ============================================================================
-- OPTIONS: TEST / LOCK
-- ============================================================================
L["Options.LockUnlock"] = "잠금 / 해제"
L["Options.LockUnlock.Desc"] =
    "잠금을 해제하면 버프 프레임 위치를 조정할 수 있는 앵커 핸들이 표시됩니다."
L["Options.TestAppearance"] = "아이콘 모양 테스트"
L["Options.TestAppearance.Desc"] =
    "가짜 값으로 선택한 버프를 표시해서 모양을 미리 볼 수 있습니다."
L["Options.Test"] = "테스트"
L["Options.StopTest"] = "테스트 중지"
L["Options.AnchorHint"] = "앵커를 클릭해서 앵커 지점 또는 좌표를 변경하세요."
L["Options.Lock"] = "잠금"
L["Options.Unlock"] = "잠금 해제"

-- ============================================================================
-- OPTIONS: CUSTOM BUFF MODAL
-- ============================================================================
L["CustomBuff.Edit"] = "사용자 지정 버프 편집"
L["CustomBuff.Add"] = "사용자 지정 버프 추가"
L["CustomBuff.AddButton"] = "+ 사용자 지정 버프 추가"
L["CustomBuff.SpellIDs"] = "주문 ID:"
L["CustomBuff.Lookup"] = "조회"
L["CustomBuff.AddSpellID"] = "+ 주문 ID 추가"
L["CustomBuff.Name"] = "이름:"
L["CustomBuff.Text"] = "텍스트:"
L["CustomBuff.LineBreakHint"] = "(줄바꿈은 \\n 텍스트 사용)"
L["CustomBuff.Appearance"] = "모양"
L["CustomBuff.Conditions"] = "조건"
L["CustomBuff.ShowIn"] = "표시 위치"
L["CustomBuff.ClickAction"] = "클릭 동작"
L["CustomBuff.SettingsMovedNote"] =
    "표시 조건 및 전투 준비 설정이 각 버프의 편집 메뉴로 이동했습니다."

-- Custom buff mode toggles
L["CustomBuff.WhenActive"] = "활성 상태일 때"
L["CustomBuff.WhenMissing"] = "없을 때"
L["CustomBuff.OnlyIfSpellKnown"] = "주문을 알고 있을 때만"

-- Custom buff class dropdown
L["Class.Any"] = "모두"
L["Class.DeathKnight"] = "죽음의 기사"
L["Class.DemonHunter"] = "악마 사냥꾼"
L["Class.Druid"] = "드루이드"
L["Class.Evoker"] = "기원사"
L["Class.Hunter"] = "사냥꾼"
L["Class.Mage"] = "마법사"
L["Class.Monk"] = "수도사"
L["Class.Paladin"] = "성기사"
L["Class.Priest"] = "사제"
L["Class.Rogue"] = "도적"
L["Class.Shaman"] = "주술사"
L["Class.Warlock"] = "흑마법사"
L["Class.Warrior"] = "전사"

-- Custom buff fields
L["CustomBuff.Spec"] = "전문화:"
L["CustomBuff.Class"] = "직업:"
L["CustomBuff.RequireItem"] = "아이템 필요:"
L["CustomBuff.RequireItem.EquippedBags"] = "착용 중/소지품"
L["CustomBuff.RequireItem.Equipped"] = "착용 중"
L["CustomBuff.RequireItem.InBags"] = "소지품"
L["CustomBuff.RequireItem.Hint"] = "아이템 ID — 없으면 숨김"

-- Bar glow options
L["CustomBuff.BarGlow.WhenGlowing"] = "반짝임 상태일 때 감지"
L["CustomBuff.BarGlow.WhenNotGlowing"] = "반짝임 상태가 아닐 때 감지"
L["CustomBuff.BarGlow.Disabled"] = "비활성화"
L["CustomBuff.BarGlow"] = "액션 바 반짝임:"
L["CustomBuff.BarGlow.Title"] = "액션 바 반짝임 대체 감지"
L["CustomBuff.BarGlow.Desc"] =
    "버프 API가 제한되는 신화+/PvP/전투 중에 액션 바 주문 반짝임을 사용한 대체 감지 방식입니다. 버프 존재 여부만 추적하려면 비활성화하세요."

-- Ready check / level
L["CustomBuff.ReadyCheckOnly"] = "전투 준비 시에만"
L["CustomBuff.Level"] = "레벨:"
L["CustomBuff.Level.Any"] = "모든 레벨"
L["CustomBuff.Level.Max"] = "최대 레벨만"
L["CustomBuff.Level.BelowMax"] = "최대 레벨 미만"

-- Click action
L["CustomBuff.Action.None"] = "없음"
L["CustomBuff.Action.Spell"] = "주문"
L["CustomBuff.Action.Item"] = "아이템"
L["CustomBuff.Action.Macro"] = "매크로"
L["CustomBuff.Action.OnClick"] = "클릭 시:"
L["CustomBuff.Action.Title"] = "클릭 동작"
L["CustomBuff.Action.Desc"] =
    "이 버프 아이콘을 클릭했을 때의 동작을 설정합니다. 주문은 주문 시전, 아이템은 아이템 사용, 매크로는 매크로를 실행합니다."
L["CustomBuff.Action.MacroHint"] = "예: /사용 item:12345\n/사용 13"

-- Save/Cancel/Delete
L["CustomBuff.Save"] = "저장"
L["CustomBuff.ValidateError"] = "유효한 주문 ID가 1개 이상 필요합니다"

-- Custom buff tooltip
L["CustomBuff.Tooltip.Title"] = "사용자 지정 버프"
L["CustomBuff.Tooltip.Desc"] = "우클릭으로 편집 또는 삭제"

-- Custom buff status
L["CustomBuff.InvalidID"] = "잘못된 ID"
L["CustomBuff.NotFound"] = "찾을 수 없음"
L["CustomBuff.NotFoundRetry"] = "찾을 수 없음 (다시 시도)"
L["CustomBuff.Error"] = "오류:"

-- ============================================================================
-- OPTIONS: DISCORD
-- ============================================================================
L["Options.JoinDiscord"] = "Discord 참여"
L["Options.JoinDiscord.Title"] = "초대 링크를 보려면 클릭"
L["Options.JoinDiscord.Desc"] =
    "피드백, 기능 요청, 버그 제보가 있으신가요?\nDiscord에 참여하세요!"

-- ============================================================================
-- OPTIONS: CUSTOM ANCHOR FRAMES
-- ============================================================================
L["Options.CustomAnchorFrames"] = "사용자 지정 앵커 프레임"
L["Options.CustomAnchorFrames.Desc"] =
    "앵커 드롭다운에 전역 프레임 이름을 추가합니다. (예: MyAddon_PlayerFrame)\n게임 내에 존재하지 않는 프레임은 자동으로 건너뜁니다."
L["Options.Add"] = "추가"
L["Options.New"] = "새로 만들기"
L["Options.ResetToDefaults"] = "기본값으로 초기화"

-- ============================================================================
-- OPTIONS: MISC
-- ============================================================================
L["Options.Off"] = "끄기"
L["Options.Always"] = "항상"
L["Options.ReadyCheck"] = "전투 준비"
L["Options.Min"] = "분"

-- ============================================================================
-- COMPONENTS (UI/Components.lua)
-- ============================================================================
-- Content filter tooltip
L["Content.ClickToFilter"] = "%s 난이도별로 필터하려면 클릭"

-- Mover labels
L["Mover.AnchorGrowth"] = "앵커 \194\183 방향 %s"
L["Mover.AnchorGrowthFrame"] = "앵커 \194\183 방향 %s \194\183 > %s"

-- Pet labels
L["Pet.SpiritBeast"] = "야수 정령"

-- Appearance grid labels
L["Appearance.Width"] = "너비"
L["Appearance.Height"] = "높이"
L["Appearance.Zoom"] = "확대"
L["Appearance.Border"] = "테두리"
L["Appearance.Spacing"] = "간격"
L["Appearance.Alpha"] = "투명도"
L["Appearance.Text"] = "텍스트"
L["Appearance.TextX"] = "텍스트 X"
L["Appearance.TextY"] = "텍스트 Y"

-- Slider tooltip
L["Component.AdjustValue"] = "값 조정"
L["Component.AdjustValue.Desc"] = "클릭해서 입력하거나 마우스 휠을 사용하세요."

-- Direction labels
L["Direction.Left"] = "왼쪽"
L["Direction.Center"] = "가운데"
L["Direction.Right"] = "오른쪽"
L["Direction.Up"] = "위"
L["Direction.Down"] = "아래"
L["Direction.Label"] = "방향"

-- Content visibility
L["Content.ShowIn"] = "표시 조건:"

-- Content toggle definitions
L["Content.OpenWorld"] = "야외"
L["Content.Housing"] = "하우징"
L["Content.Scenarios"] = "시나리오 (구렁, 토르가스트 등)"
L["Content.Dungeons"] = "던전 (신화+ 포함)"
L["Content.Raids"] = "공격대"
L["Content.PvP"] = "PvP (투기장과 전장)"

-- Scenario difficulty
L["Content.Delves"] = "구렁"
L["Content.OtherScenarios"] = "기타 시나리오 (토르가스트 등)"

-- Dungeon difficulty
L["Content.NormalDungeons"] = "일반 던전"
L["Content.HeroicDungeons"] = "영웅 던전"
L["Content.MythicDungeons"] = "신화 던전"
L["Content.MythicPlus"] = "신화+ 쐐기돌"
L["Content.TimewalkingDungeons"] = "시간 여행 던전"
L["Content.FollowerDungeons"] = "추종자 던전"

-- Raid difficulty
L["Content.LFR"] = "공격대 찾기"
L["Content.NormalRaids"] = "일반 공격대"
L["Content.HeroicRaids"] = "영웅 공격대"
L["Content.MythicRaids"] = "신화 공격대"

-- PvP types
L["Content.Arena"] = "투기장"
L["Content.Battlegrounds"] = "전장"
