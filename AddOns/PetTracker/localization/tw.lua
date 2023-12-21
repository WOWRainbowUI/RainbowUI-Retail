--[[
	Chinese Traditional Localization
--]]

local ADDON = ...
local L = LibStub('AceLocale-3.0'):NewLocale(ADDON, 'zhTW')
if not L then return end

-- main
L.ADDON = '戰寵'
L.AddWaypoint = '新增導航目的地'
L.AskForfeit = '沒有可供升級的寵物，是否要退出對戰?'
L.AvailableBreeds = '可提供的品級'
L.Breed = '品級'
L.BreedExplanation = '決定每個等級如何分配屬性。'
L.CapturedPets = '顯示已捕捉'
L.CommonSearches = '常用搜尋'
L.FilterSpecies = '過濾種類'
L.LoadTeam = '載入隊伍'
L.Ninja = '亂入者'
L.NoHistory = '戰寵助手從未見你\n與這個對手戰鬥過'
L.NoneCollected = '尚未收集'
L.Rivals = '對手'
L.ShowJournal = '顯示於寵物日誌'
L.ShowPets = '顯示戰寵'
L.ShowStables = '顯示獸欄'
L.Species = '種類'
L.StableTip = '|cffffd200到這裡治療你的寵物|n只需少許的花費。|r'
L.TellMore = '告訴我更多關於你的信息。'
L.UpgradeAlert = '出現可升級的野外對戰!'
L.TotalRivals = '對手總數'
L.ZoneTracker = '區域追蹤'

-- options
L.AlertUpgrades = '升級提醒'
L.AlertUpgradesTip = '停用時，戰鬥中不會顯示野外的升級提醒，但仍會標記這個符號 (|TInterface/GossipFrame/AvailableQuestIcon:0:0:-1:-2|t) 表示可以升級。'
L.FAQDescription = '這些是最常被問到的問題。要再次觀看教學，請按左下角的 "預設值" 按鈕來重置插件設定。'
L.Forfeit = '提示退出'
L.ForfeitTip = '啟用時，沒有可升級的寵物時會提示你放棄對戰。'
L.OptionsDescription = '這些選項讓你能夠開啟或關閉戰寵助手的一般功能，立志成為寶可夢大師!'
L.RivalPortraits = '對手頭像'
L.RivalPortraitsTip = '啟用時，世界地圖和對戰地圖上的對手會顯示為頭像。'
L.SpecieIcons = '種類圖示'
L.SpecieIconsTip = '啟用時，世界地圖和對戰地圖上的寵物會顯示為種類，而不是類型。'
L.Switcher = '增強介面'
L.SwitcherTip = '啟用時，對戰中切換寵物的預設介面會改為增強型的介面。'
L.ZoneTrackerTip = '啟用時，當前區域的寵物捕捉進度會顯示在任務追蹤清單下方。|n|n|cff20ff20寵物日誌中也能開關此選項。|r'

L.FAQ = {
'如何在地圖上顯示/隱藏全部寵物？',
'點擊地圖右上角落的放大鏡按鈕，點擊顯示戰鬥寵物。',

'如何只在地圖上顯示特定的寵物？',
'在世界地圖右上角有個過濾框。參見教學獲得更多的訊息和常見的範例。',

'如何再次顯示區域追踪？',
'打開寵物日誌界面並點擊右下方的區域追踪。',

'如何在區域追踪中顯示已捕獲的寵物？',
'點擊寵物對戰追踪並啟用已捕獲寵物。',

'如何停用全部野生寵物出現提示？',
'到主介面選單，打開插件列表並停用 PetTracker 野生寵物出現。',

'如何再次查看教學？',
'點擊右側按鈕。'

}

L.Tutorial = {
[[歡迎！現在使用的是 |cffffd200PetTracker|r，由 |cffffd200Jaliborc|r 製作。

這個小教學幫助你快速了解此插件，這樣就可以知道什麼是真正需要去做的：把……他們……一網打盡！]],

[[PetTracker 將幫助監視目前區域的進度。

|cffffd200區域追踪|r顯示缺少的寵物、來源及捕獲寵物的稀有度。]],

[[點擊|cffffd200戰鬥寵物|r切換追踪或更多選項。]],

[[打開|cffffd200世界地圖|r來查看 PetTracker 能為你的歷險做些什麼。]],

[[PetTracker 在世界地圖上顯示可能的寵物來源，從更新點到供應商。也能顯示寵物對戰師普通和附加訊息。

如要隱藏此位置，打開追踪選單並停用|cffffd200寵物|r分類中的|cffffd200種類|r。]],

[[你可以過濾顯示的搜索框中輸入的寵物。舉例說明：

- |cffffd200貓（Cat）|r代表貓種類。
- |cffffd200缺少（Missing）|r代表你並未擁有。
- |cffffd200水棲（Aquatic）|r代表水棲類。
- |cffffd200任務（Quest）|r代表從任務獲取的寵物。
- |cffffd200森林（Forest）|r代表棲息在森林。]],

[[打開|cffffd200寵物日誌|r 來查看 PetTracker 能為你的歷險做些什麼。]],
[[此選擇框可以切換|cffffd200區域追踪|r。這是一個特別有用的追踪加入你沒有用過追踪的話。]],
[[打開|cffffd200對手|r欄來了解關於他們更多。]],
[[|cffffd200對手|r欄提供了已知寵物戰鬥訊息，例如：

- 敵對寵物和它們的技能。
- 日常任務和獎勵。
- 戰鬥位置。]],
[[你可以在搜尋框內過濾要顯示的寵物。例如：

- |cffffd200雅姬（Aki）|r為『天選』雅姬。
- |cffffd200勇氣（Valor）|r為獎勵勇氣的對手。
- |cffffd200德拉諾（Dreenor）|r為德拉諾的對手。
- |cffffd200史詩（Epic）|r為對手使用史詩隊伍。
- |cffffd200> 20|r為等級大於20的對手。]],
[[PetTracker 記錄每個與之對戰的對手。選擇戰鬥並點擊|cffffd200載入隊伍|r來快速載入你所選擇的寵物。]]
}
