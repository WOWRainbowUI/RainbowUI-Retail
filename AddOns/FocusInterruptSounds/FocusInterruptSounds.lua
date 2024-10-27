----------------------------
--      Constants         --
----------------------------

local _

local CASTING_SOUND_FILE_LOW_VOLUME = "Interface\\AddOns\\FocusInterruptSounds\\kickcast-lv.ogg";
local CASTING_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\kickcast.ogg";

local CASTING_SOUND_FILE_LOW_VOLUME2 = "Interface\\AddOns\\FocusInterruptSounds\\casting-lv.ogg";
local CASTING_SOUND_FILE2 = "Interface\\AddOns\\FocusInterruptSounds\\casting.ogg";

local CASTING_SOUND_FILE_LOW_VOLUME3 = "Interface\\AddOns\\FocusInterruptSounds\\secure-lv.ogg";
local CASTING_SOUND_FILE3 = "Interface\\AddOns\\FocusInterruptSounds\\secure.ogg";

local CASTING_SOUND_FILE_LOW_VOLUME4 = "Interface\\AddOns\\FocusInterruptSounds\\princess-connect-lv.ogg";
local CASTING_SOUND_FILE4 = "Interface\\AddOns\\FocusInterruptSounds\\princess-connect.ogg";

local LOWPRI_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\lowpri.ogg";

local CC_SOUND_FILE_LOW_VOLUME = "Interface\\AddOns\\FocusInterruptSounds\\cc-lv.ogg";
local CC_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\cc.ogg";

local INTERRUPTED_SOUND_FILE_LOW_VOLUME = "Interface\\AddOns\\FocusInterruptSounds\\interrupted-lv.ogg";
local INTERRUPTED_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\interrupted.ogg";

local POLYMORPH_SOUND_FILE_LOW_VOLUME = "Interface\\AddOns\\FocusInterruptSounds\\sheep-lv.ogg";
local POLYMORPH_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\sheep.ogg";

local INNERVATE_SOUND_FILE_LOW_VOLUME = "Interface\\AddOns\\FocusInterruptSounds\\innervate-lv.ogg";
local INNERVATE_SOUND_FILE = "Interface\\AddOns\\FocusInterruptSounds\\innervate.ogg";

-- Don't play the same sound more than once per second
local MINIMUM_SOUND_COOLDOWN = 1.0;

local SETTING_MODE_ON = "on";
local SETTING_MODE_OFF = "off";
local SETTING_MODE_IF_FOCUS_MISSING = "iffocusmissing";

local SCHOOL_PHYSICAL	= 0x01;
local SCHOOL_HOLY	= 0x02;
local SCHOOL_FIRE	= 0x04;
local SCHOOL_NATURE	= 0x08;
local SCHOOL_FROST	= 0x10;
local SCHOOL_SHADOW	= 0x20;
local SCHOOL_ARCANE	= 0x40;
local SCHOOL_ALL	= 0x7F;

local DEFAULT_GLOBAL_OVERRIDES =
[[喚霧者->拍蛋糕
]];

local DEFAULT_BLACKLIST =
[[星裔觀察者->星辰轟擊
鐵潮劫奪者->痛苦動機
瘋狂凝視->滋育瘋狂
至高判決者阿利茲->能量彈
崔朵瓦->吞噬
]];

local DEFAULT_LOW_PRIORITY_SPELLS =
[[; Dragonflight S1
152814; SBG Shadow Bolt
397888; TotJS Hydrolance
388862; AA Surge
371306; AV Arcane Bolt
377503; AV Condensed Frost
381530; NO Storm Shock
; Dragonflight S2
281420; FH Water Bolt
259092; FH Lightning Bolt
257899; FH Painful Motivation
378155; BH Earth Bolt
382474; BH Decay Surge
374706; HoI Pyretic Burst
410760; VP Wind Bolt
88959; VP Holy Smite
369674; Uld Stone Spike
272180; Undr Void Spit
; Dragonflight S3
426731; ToT Water Bolt
264024; WCM Soul Bolt
164973; EVB Dancing Thorns
168040; EVB Nature's Wrath
168092; EVB Water Bolt
400165; DIMR Epoch Bolt
418202; DIMR Temporal Blast
; TWW S1
333602; NW Frostbolt
434786; AK Web Bolt
429110; SV Alloy Bolt
451261; GB Earth Bolt
76369; GB Shadowflame Bolt
257063; SOB Brackish Bolt
272581; SOB Water Bolt
]];
-- 376399; ignore test
-- 392279; ignore test

local DEFAULT_PLAYER_INTERRUPT_SPELLS =
[[p89766; (寵物) 投擲利斧
p19647; (寵物) 法術封鎖
31935;  復仇之盾
147362; 駁火反擊
2139;   法術反制
183752; 干擾
1766;   腳踢
47528;  心智冰封
187707; 封口
6552;   拳擊
351338; 壓制
96231;  責難
15487;  沉默
106839; 碎顱猛擊
78675;  太陽光束
116705; 天矛鎖喉手
57994;  削風術
]];

local DEFAULT_AURA_BLACKLIST =
[[聖盾術 -> *
]];

local DEFAULT_INCOMING_CC =
[[颶風術
恐懼術
變形術
誘惑
妖術
]];

local DEFAULT_PARTNER_CC_MAGIC =
[[變形術
懺悔
誘惑
]];

local DEFAULT_PARTNER_CC_POISON =
[[
]];


local DEFAULT_ARENA_PURGE =
[[啟動
]];

local DEFAULT_PVE_PURGE =
[[; Dragonflight
395820; VoI Frost Barrier
385063; RS Burning Ambition
373972; RS Blaze of Glory
392454; RS Burning Veins
391031; RS Tempest Barrier
198745; HoV Protective Light
386223; NO Stormshield
384686; NO Energy Surge
387596; NO Swift Wind
398151; SBG Sinister Focus
398205; SBG Incorporeal
209033; CoS Fortification
396020; TotJS Golden Barrier
389686; AV Arcane Fury
374778; AV Brilliant Scales
; Dragonflight S3
255579; AD Gilded Claws
; TWW S1
431493; DAWN Darkblade
256957; SOB Watertight Shell
275826; SOB Bolstering Shout
335141; NW Dark Shroud
]];

------------------------------
--      Initialization      --
------------------------------

FocusInterruptSounds = LibStub("AceAddon-3.0"):NewAddon("FocusInterruptSounds", "AceEvent-3.0", "AceConsole-3.0")

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:MapCreateOptions
--
--		Create the options file
--
function FocusInterruptSounds:MapCreateOptions()

	local soundMap = {
		[CASTING_SOUND_FILE_LOW_VOLUME] = "快打斷!",
		[CASTING_SOUND_FILE] = "快打斷! (大聲)",
		[CASTING_SOUND_FILE_LOW_VOLUME2] = "逼逼!",
		[CASTING_SOUND_FILE2] = "逼逼! (大聲)",
		[CASTING_SOUND_FILE_LOW_VOLUME3] = "小櫻 Secure!",
		[CASTING_SOUND_FILE3] = "小櫻 Secure! (大聲)",
		[CASTING_SOUND_FILE_LOW_VOLUME4] = "咕嚕靈波~",
		[CASTING_SOUND_FILE4] = "咕嚕靈波~ (大聲)",
		[CC_SOUND_FILE_LOW_VOLUME] = "滴滴滴",
		[CC_SOUND_FILE] = "滴滴滴 (大聲)",
		[INNERVATE_SOUND_FILE_LOW_VOLUME] = "吱~吱~",
		[INNERVATE_SOUND_FILE] = "吱~吱~ (大聲)",
		[INTERRUPTED_SOUND_FILE_LOW_VOLUME] = "叮!",
		[INTERRUPTED_SOUND_FILE] = "叮! (大聲)",
		[LOWPRI_SOUND_FILE] = "嗶",
		[POLYMORPH_SOUND_FILE_LOW_VOLUME] = "咩~~",
		[POLYMORPH_SOUND_FILE] = "咩~~ (大聲)",
	};

	local onOffMap = {
		[SETTING_MODE_OFF] = "關",
		[SETTING_MODE_ON] = "開",
	};

	local options = {
		type = "group",
		name = "斷法提醒和通報",
		get = function(info) return FocusInterruptSounds.db.profile[ info[#info] ] end,
		set = function(info, value) FocusInterruptSounds.db.profile[ info[#info] ] = value end,
		args = {
			General = {
				order = 1,
				type = "group",
				name = "一般設定",
				desc = "一般設定",
				args = {
					intro = {
						order = 0,
						type = "description",
						name = "你的敵對目標開始施放可以中斷的法術時，會有語音提醒快打斷。"
								.. "PvP 和 PvE 也有其他特殊事件的音效。發現 BUG 了嗎? 請在遊戲中"
								.. "寫信給 Corg, 部落, US-Detheroc (因為我有可能會沒看到 "
								.. "Ace 討論區) 。",
					},

					generalOptions = {
						order = 1,
						type = "header",
						name = "一般選項",
					},

					fEnableText = {
						type = "toggle",
						name = "啟用文字",
						desc = "啟用/停用斷法提醒的聊天視窗文字。",
						order = 2,
					},
					fEnableSound = {
						type = "toggle",
						name = "啟用音效",
						desc = "啟用/停用斷法提醒的音效。",
						order = 3,
					},
					fIgnoreMute = {
						type = "toggle",
						name = "忽略靜音",
						desc = "忽略/使用遊戲的靜音設定 (Ctrl+N)。啟用音效時才能使用這個選項。",
						order = 4,
					},
					fCheckSpellAvailability = {
						type = "toggle",
						name = "檢查法術是否可用",
						desc = "提醒前會檢查是否有可用的斷法和反控場技能。",
						order = 5,
					},
					fDisableInVehicle = {
						type = "toggle",
						name = "載具上停用",
						desc = "在載具/坐騎上時關閉音效。",
						order = 6,
					},
					fAnnounceInterrupts = {
						type = "toggle",
						name = "斷法通報到頻道",
						desc = "斷法成功會通報到隊伍/團隊頻道。",
						order = 7,
					},
					iMinimumCastTime = {
						type = "range",
						name = "最小施法時間 (毫秒)",
						desc = "施法時間小於這個數值的法術不會提醒，以毫秒為單位。",
						order = 8,
						softMin = 0,
						softMax = 3000,
						min = 0,
						max = 20000,
						bigStep = 100,
					},

					---------------------------------------------------------------------------------------------------

					soundCustomization = {
						order = 100,
						type = "header",
						name = "自訂音效",
					},

					strTargetCastingMode = {
						type = "select",
						values = {
							[SETTING_MODE_OFF] = "關",
							[SETTING_MODE_IF_FOCUS_MISSING] = "沒有目標",
							[SETTING_MODE_ON] = "開",
						},
						name = "當前目標施法提醒",
						desc = "當前目標開始唱法時是否要播放音效",
						order = 101,
					},
					strTargetCastingSound = {
						type = "select",
						values = soundMap,
						name = "當前目標施法音效",
						desc = "當前目標開始唱法時播放的音效",
						order = 102,
					},
					strTargetLowPriSound = {
						type = "select",
						values = soundMap,
						name = "當前目標施法音效 (低優先)",
						desc = "當前目標開始唱低優先斷法順序法術時播放的音效",
						order = 103,
					},

					strFocusCastingMode = {
						type = "select",
						values = onOffMap,
						name = "專注目標施法提醒",
						desc = "專注目標開始唱法時是否要播放音效",
						order = 104,
					},
					strFocusCastingSound = {
						type = "select",
						values = soundMap,
						name = "專注目標施法音效",
						desc = "專注目標開始唱法時播放的音效",
						order = 105,
					},
					strFocusLowPriSound = {
						type = "select",
						values = soundMap,
						name = "專注目標施法提醒",
						desc = "專注目標開始唱法時是否要播放音效",
						order = 106,
					},

					strInterruptCelebrationMode = {
						type = "select",
						values = onOffMap,
						name = "斷法成功提醒",
						desc = "斷法成功時是否要播放音效",
						order = 107,
					},
					strInterruptCelebrationSound = {
						type = "select",
						values = soundMap,
						name = "斷法成功音效",
						desc = "斷法成功時播放的音效",
						order = 108,
					},

					strPurgeMode = {
						type = "select",
						values = onOffMap,
						name = "驅散提醒",
						desc = "敵方身上有需要驅散的增益效果時是否要播放音效",
						order = 109,
					},
					strPurgeSound = {
						type = "select",
						values = soundMap,
						name = "驅散音效",
						desc = "敵方身上有需要驅散的增益效果時播放的音效",
						order = 110,
					},

					strGlobalOverrideMode = {
						type = "select",
						values = onOffMap,
						name = "特別提醒",
						desc = "施放特別提醒清單中的法術時是否要播放音效",
						order = 111,
					},
					strGlobalOverrideSound = {
						type = "select",
						values = soundMap,
						name = "特別提醒音效",
						desc = "施放特別提醒清單中的法術時播放的音效",
						order = 112,
					},

					strIncomingCCMode = {
						type = "select",
						values = onOffMap,
						name = "即將控場提醒",
						desc = "如果你有使用敵方技能監控，有正在施放的控場時是否要播放音效 (例如: 根基圖騰、反魔法護罩)",
						order = 113,
					},
					strIncomingCCSound = {
						type = "select",
						values = soundMap,
						name = "即將控場音效",
						desc = "有正在施放的控場時播放的音效",
						order = 114,
					},

					strPartnerCCMode = {
						type = "select",
						values = onOffMap,
						name = "隊友被控場提醒",
						desc = "隊友被控場，而你可以驅散時是否要播放音效",
						order = 115,
					},
					strPartnerCCSound = {
						type = "select",
						values = soundMap,
						name = "隊友被控場音效",
						desc = "隊友被控場時播放的音效",
						order = 116,
					},

					---------------------------------------------------------------------------------------------------

					advancedOptions = {
						order = 200,
						type = "header",
						name = "進階選項",
					},

					strGlobalOverrides = {
						type = "input",
						name = "特別提醒設定",
						desc = "列出一定要發出提醒的施法者和法術 (就算不是"
								.. "你的目標或專注目標)，分隔使用 \"->\"。使用星號 \"*\" 代表任何施法者"
								.. "或任何法術 (但不能同時代表兩者!)。",
						order = 201,
						multiline = true,
						width = "double",
					},

					strBlacklist = {
						type = "input",
						name = "施法者 -> 法術 忽略清單",
						desc = "列出要忽略的施法者和法術配對，分隔使用 \"->\"。"
								.. "使用星號 \"*\"代表任何施法者或任何法術 (但不能同時代表兩者!)。",
						order = 202,
						multiline = true,
						width = "double",
					},
					fIgnorePhysical = {
						type = "toggle",
						name = "忽略物理傷害法術",
						desc = "忽略標示為 \"物理\"。",
						order = 203,
					},
					fEnableBlizzardBlacklist = {
						type = "toggle",
						name = "使用暴雪API忽略清單",
						desc = "忽略 UnitCastingInfo() 標示為不可打斷的法術。",
						order = 204,
					},
					strAuraBlacklist = {
						type = "input",
						name = "光環 -> 法術 忽略清單",
						desc = "列出指定光還要忽略的法術。分隔使用 \"->\"。"
								.. "使用星號 \"*\" 代表任何法術。",
						order = 205,
						multiline = true,
						width = "double",
					},

					strLowPrioritySpells = {
						type = "input",
						name = "低優先斷法順序的法術",
						desc = "列出低優先順序要打斷的法術。分號是註解符號。",
						order = 206,
						multiline = true,
						width = "double",
					},

					strPlayerInterruptSpells = {
						type = "input",
						name = "玩家斷法技能 (加入你的技能，將其他刪除)",
						desc = "列出玩家可以使用的斷法招數。"
								.. "只有在啟用 \"檢查法術是否可用\" 選項時才會用到這個清單。",
						order = 207,
						multiline = true,
						width = "double",
					},

					strIncomingCC = {
						type = "input",
						name = "PvP 即將來臨的控場法術",
						desc = "列出在競技場或附近，即將到來的控場技能。",
						order = 208,
						multiline = true,
						width = "double",
					},
					strPartnerCC = {
						type = "input",
						name = "競技場隊友受到的控場減益",
						desc = "列出套用到競技場隊友身上、需要提醒的減益效果。",
						order = 209,
						multiline = true,
						width = "double",
					},

					strArenaPurge = {
						type = "input",
						name = "競技場要驅散的增益",
						desc = "列出競技場對手所獲得、需要提醒的增益效果。",
						order = 210,
						multiline = true,
						width = "double",
					},

					strPvePurgeIds = {
						type = "input",
						name = "PvE 要驅散的增益",
						desc = "列出 NPC 身上需要驅散的增益效果 ID。",
						order = 211,
						multiline = true,
						width = "double",
					},
				},
			},
		},
	};

	return options;
end

function FocusInterruptSounds:OnInitialize()

	local strGlobalOverrides = DEFAULT_GLOBAL_OVERRIDES;
	local strAuraBlacklist = DEFAULT_AURA_BLACKLIST;
	local strPlayerInterruptSpells = DEFAULT_PLAYER_INTERRUPT_SPELLS;
	local strIncomingCC = "";
	local strPartnerCC = "";
	local strPvePurgeIds = "";

	_, self.strClassName = UnitClass("player");

	self.fHasPurge = false;
	self.fCanDispel = false;
	self.fCanDepoison = false;
	self.tblLastSoundPlayed = {};

	if ("WARLOCK" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_SHADOW;
		self.str30YardSpellName = "射擊";
		self.fHasPurge = true;
		self.fCanDispel = true;
	elseif ("MAGE" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_ARCANE;
		self.str30YardSpellName = "射擊";
		self.fHasPurge = true;
	elseif ("SHAMAN" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_NATURE;
		self.strAntiCCSpellName = "巫毒圖騰";
		self.str30YardSpellName = "閃電箭";
		self.fHasPurge = true;
		self.fCanDepoison = true;
	elseif ("WARRIOR" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_PHYSICAL;
		self.str30YardSpellName = "射擊";
	elseif ("ROGUE" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_PHYSICAL;
		self.strAntiCCSpellName = "暗影披風";
		self.str30YardSpellName = "射擊";
	elseif ("PRIEST" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_SHADOW;
		self.str30YardSpellName = "暗言術：痛";
		self.fHasPurge = true;
		self.fCanDispel = true;
	elseif ("HUNTER" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_PHYSICAL;
		self.strAntiCCSpellName = "假死";
		self.str30YardSpellName = "震盪射擊";
	elseif ("DRUID" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_PHYSICAL;
		self.str30YardSpellName = "治療之觸";
		self.fCanDepoison = true;
	elseif ("DEATHKNIGHT" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_FROST;
		self.strAntiCCSpellName = "反魔法護罩";
		self.str30YardSpellName = "死亡之握";
	elseif ("PALADIN" == self.strClassName) then
		self.fCanDispel = true;
		self.fCanDepoison = true;
	elseif ("MONK" == self.strClassName) then
		self.fCanDispel = true;
		self.fCanDepoison = true;
	elseif ("DEMONHUNTER" == self.strClassName) then
		self.iInterruptSchool = SCHOOL_SHADOW;
		self.fHasPurge = true;
	end

	-- Add additional auras for classes with physical interrupts
	if (self.iInterruptSchool == SCHOOL_PHYSICAL) then
		strAuraBlacklist = strAuraBlacklist .. "保護祝福 -> *\n";
	end

	-- Set up incoming CC warning defaults
	if (nil ~= self.strAntiCCSpellName) then
		strIncomingCC = DEFAULT_INCOMING_CC;
	end

	-- Set up partner CC defaults
	if (self.fCanDispel) then
		strPartnerCC = strPartnerCC .. DEFAULT_PARTNER_CC_MAGIC;
	end

	if (self.fCanDepoison) then
		strPartnerCC = strPartnerCC .. DEFAULT_PARTNER_CC_POISON;
	end

	-- Set up purge defaults
	if (self.fHasPurge) then
		strPvePurgeIds = DEFAULT_PVE_PURGE;
	end

	-- Build the default settings array
	local DEFAULTS = {
		profile = {
			fEnableText = true,
			fEnableSound = true,
			fIgnoreMute = true,
			fCheckSpellAvailability = true,
			fDisableInVehicle = true,
			fAnnounceInterrupts = true,
			iMinimumCastTime = 800,

			strTargetCastingMode = SETTING_MODE_ON,
			strTargetCastingSound = CASTING_SOUND_FILE_LOW_VOLUME,
			strTargetLowPriSound = LOWPRI_SOUND_FILE,
			strFocusCastingMode = SETTING_MODE_ON,
			strFocusCastingSound = CC_SOUND_FILE_LOW_VOLUME,
			strFocusLowPriSound = LOWPRI_SOUND_FILE,

			strInterruptCelebrationMode = SETTING_MODE_ON,
			strInterruptCelebrationSound = INTERRUPTED_SOUND_FILE_LOW_VOLUME,
			strPurgeMode = SETTING_MODE_ON,
			strPurgeSound = INNERVATE_SOUND_FILE_LOW_VOLUME,
			strGlobalOverrideMode = SETTING_MODE_ON,
			strGlobalOverrideSound = CC_SOUND_FILE_LOW_VOLUME,
			strIncomingCCMode = SETTING_MODE_ON,
			strIncomingCCSound = CC_SOUND_FILE_LOW_VOLUME,
			strPartnerCCMode = SETTING_MODE_ON,
			strPartnerCCSound = POLYMORPH_SOUND_FILE_LOW_VOLUME,

			strGlobalOverrides = strGlobalOverrides,
			strBlacklist = DEFAULT_BLACKLIST,
			fIgnorePhysical = false,
			fEnableBlizzardBlacklist = true,
			strAuraBlacklist = strAuraBlacklist,
			strLowPrioritySpells = DEFAULT_LOW_PRIORITY_SPELLS,
			strPlayerInterruptSpells = strPlayerInterruptSpells,
			strIncomingCC = strIncomingCC,
			strPartnerCC = strPartnerCC,
			strArenaPurge = DEFAULT_ARENA_PURGE,
			strPvePurgeIds = strPvePurgeIds,
		}
	};
	self.db = LibStub("AceDB-3.0"):New("FocusInterruptSoundsDB", DEFAULTS, self.strClassName)

	local options = self:MapCreateOptions();
	options.args.Profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("FocusInterruptSounds", options)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("FocusInterruptSounds", 640, 480)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("FocusInterruptSounds", "斷法", nil, "General")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("FocusInterruptSounds", "設定檔", "斷法", "Profile")
	self:RegisterChatCommand("fis", function() LibStub("AceConfigDialog-3.0"):Open("FocusInterruptSounds") end)

end


function FocusInterruptSounds:OnEnable()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	-- self:CheckAndPrintMessage("Add-on activated for the class " .. self.strClassName);
end

function FocusInterruptSounds:OnDisable()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

------------------------------
--        Functions         --
------------------------------

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:CheckAndPrintMessage
--
--		Prints a message, only if the options permit it.
--
function FocusInterruptSounds:CheckAndPrintMessage(strMsg)

	if (self.db.profile.fEnableText) then
		DEFAULT_CHAT_FRAME:AddMessage("|cff7fff7f斷法|r: " .. tostring(strMsg));
	end

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:CheckAndPlaySound
--
--		Plays a sound, only if the options permit it.
--
function FocusInterruptSounds:CheckAndPlaySound(strFile)

	if (self.db.profile.fEnableSound) then
		-- Don't play the sound if we last played it less than a second ago
		local now = GetTime();
		if (nil == self.tblLastSoundPlayed[strFile] or now - self.tblLastSoundPlayed[strFile] > MINIMUM_SOUND_COOLDOWN) then
			-- self:CheckAndPrintMessage("Last played " .. (now - (self.tblLastSoundPlayed[strFile] or 0)) .. "s");
			self.tblLastSoundPlayed[strFile] = now;

			local strChannel = "SFX";
			if (self.db.profile.fIgnoreMute) then
				strChannel = "MASTER";
			end

			PlaySoundFile(strFile, strChannel);
		else
			-- self:CheckAndPrintMessage("Sound played too recently");
		end
	end

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsSourceFocusOrTarget
--
--		Returns true if the source flags are for the target we're making sounds for.
--
function FocusInterruptSounds:FIsSourceFocusOrTarget(iSourceFlags)

	-- Filter out non-hostile sources
	if (0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY)) then
		return false;
	end

	-- Check if the source is the target
	if (0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_TARGET)
			and (SETTING_MODE_ON == self.db.profile.strTargetCastingMode or
				SETTING_MODE_IF_FOCUS_MISSING == self.db.profile.strTargetCastingMode and not UnitCanAttack("player", "focus"))
	) then
		return true, true;
	end

	-- Check if the source is the focus
	if (0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_FOCUS) and SETTING_MODE_ON == self.db.profile.strFocusCastingMode) then
		return true, false;
	end

	return false;
end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:StrEscapeForRegExp
--
--		Returns the string escaped for use with LUA regular expressions.
--
function FocusInterruptSounds:StrEscapeForRegExp(str)

	-- Special characters: ^$()%.[]*+-?
	str = string.gsub(str, "%^", "%%%^");
	str = string.gsub(str, "%$", "%%%$");
	str = string.gsub(str, "%(", "%%%(");
	str = string.gsub(str, "%)", "%%%)");
	str = string.gsub(str, "%%", "%%%%");
	str = string.gsub(str, "%.", "%%%.");
	str = string.gsub(str, "%[", "%%%[");
	str = string.gsub(str, "%]", "%%%]");
	str = string.gsub(str, "%*", "%%%*");
	str = string.gsub(str, "%+", "%%%+");
	str = string.gsub(str, "%-", "%%%-");
	str = string.gsub(str, "%?", "%%%?");

	return str;

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FInList
--
--		Returns true if the given element is in the given newline-delimited list.
--		Allows for ; as the line-comment delimeter in the list.
--
function FocusInterruptSounds:FInList(strElement, strList)

	--self:CheckAndPrintMessage("Looking for " .. strElement);

	return string.find("\n" .. strList .. "\n", "\n%s*" .. self:StrEscapeForRegExp(strElement) .. "%s*[\n;]");

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FInMap
--
--		Returns true if the given key and value are in the given newline-delimited list.
--
function FocusInterruptSounds:FInMap(strKey, strValue, strMap)

	local strKeyEscaped;
	local strValueEscaped;

	if (nil == strKey) then
		strKeyEscaped = ".*";
	else
		strKeyEscaped = self:StrEscapeForRegExp(strKey);
	end

	if (nil == strValue) then
		strValueEscaped = ".*";
	else
		strValueEscaped = self:StrEscapeForRegExp(strValue);
	end

	return string.find("\n" .. strMap .. "\n", "\n%s*" .. strKeyEscaped
				.. "%s*%->%s*" .. strValueEscaped .. "%s*[\n;]");

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsCasterOrSpellGlobalOverride
--
--		Returns true if the given spell (or cast+spell combo) is in the global override list.
--
function FocusInterruptSounds:FIsCasterOrSpellGlobalOverride(strMobName, iMobFlags, strSpellId, strSpellName, iSpellSchool)

	-- Is the spell in the global override?
	if (self:FInMap("*", strSpellName, self.db.profile.strGlobalOverrides)) then
		return true;
	end

	-- Only allow caster overrides for NPCs
	if (0 ~= bit.band(iMobFlags, COMBATLOG_OBJECT_CONTROL_NPC)) then
		-- Is the caster blacklisted?
		if (self:FInMap(strMobName, "*", self.db.profile.strGlobalOverrides)) then
			return true;
		end

		-- Is the caster+spell combo blacklisted?
		if (self:FInMap(strMobName, strSpellName, self.db.profile.strGlobalOverrides)) then
			return true;
		end
	end

	return false;

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsCasterOrSpellBlacklisted
--
--		Returns true if the given spell (or cast+spell combo) is blacklisted.
--
function FocusInterruptSounds:FIsCasterOrSpellBlacklisted(strMobName, iMobFlags, strSpellId, strSpellName, iSpellSchool)

	--- Blacklist based on UnitCastingInfo() API
	if (self.db.profile.fEnableBlizzardBlacklist or self.db.profile.iMinimumCastTime > 0) then
		local strMobId = "target";

		if (0 ~= bit.band(iMobFlags, COMBATLOG_OBJECT_FOCUS)) then
			strMobId = "focus";
		end

		local strSpellNameVerify, _, _, _, iEndTime, _, _, fInterruptImmune = UnitCastingInfo(strMobId);

		-- Is this a channel rather than a cast?
		if (nil == strSpellNameVerify) then
			strSpellNameVerify, _, _, _, iEndTime, _, fInterruptImmune = UnitChannelInfo(strMobId);
		end

		if (nil == strSpellNameVerify) then
			-- If the caster is no longer casting, it was probably a really fast cast (e.g. Nature's Swiftness)
			return true;
		elseif (strSpellNameVerify ~= strSpellName) then
			self:CheckAndPrintMessage("錯誤: UnitCastingInfo 檢查失敗: strSpellNameVerify="
				.. strSpellNameVerify .. " strSpellName=" .. strSpellName);
		else
			if (self.db.profile.fEnableBlizzardBlacklist and fInterruptImmune) then
				return true;
			end

			if (iEndTime - GetTime() * 1000 < self.db.profile.iMinimumCastTime) then
				return true;
			end

		end
	end

	-- Blacklist physical spells
	if (self.db.profile.fIgnorePhysical and 0 ~= bit.band(iSpellSchool, SCHOOL_PHYSICAL)) then
		return true;
	end

	-- Is the spell blacklisted?
	if (self:FInMap("*", strSpellName, self.db.profile.strBlacklist)) then
		return true;
	end

	-- Only allow caster blacklists for NPCs
	if (0 ~= bit.band(iMobFlags, COMBATLOG_OBJECT_CONTROL_NPC)) then
		-- Is the caster blacklisted?
		if (self:FInMap(strMobName, "*", self.db.profile.strBlacklist)) then
			return true;
		end

		-- Is the caster+spell combo blacklisted?
		if (self:FInMap(strMobName, strSpellName, self.db.profile.strBlacklist)) then
			return true;
		end
	end

	return false;

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsAuraBlacklisted
--
--		Returns true if the given spell (or cast+spell combo) is blacklisted.
--
function FocusInterruptSounds:FIsAuraBlacklisted(strAura, strSpellId, strSpellName, iSpellSchool)

	-- self:CheckAndPrintMessage("id = " .. strSpellId .. "; spell name = " .. strSpellName);

	-- Is the aura blacklisted?
	if (self:FInMap(strAura, "*", self.db.profile.strAuraBlacklist)) then
		return true;
	end

	-- Is the aura+spell combo blacklisted?
	if (self:FInMap(strAura, strSpellName, self.db.profile.strAuraBlacklist)) then
		return true;
	end

	return false;

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsSpellCastStart
--
--		Returns true if the given event is the start of a spell cast.  Note that for channeled
--		spells, this is actually going to be SPELL_CAST_SUCCESS.
--
function FocusInterruptSounds:FIsSpellCastStart(strEventType, iMobFlags, strSpellId, strSpellName, iSpellSchool)

	if ("SPELL_CAST_START" == strEventType) then
		return true;
	elseif ("SPELL_CAST_SUCCESS" == strEventType) then
		local strMobId = "target";

		if (0 ~= bit.band(iMobFlags, COMBATLOG_OBJECT_FOCUS)) then
			strMobId = "focus";
		end

		local strSpellNameVerify, _, _, _, _, _, _, _ = UnitChannelInfo(strMobId);
		return strSpellNameVerify == strSpellName;
	end

	return false;

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsCCSpell
--
--		Returns true if the given event is the start of a CC.
--
function FocusInterruptSounds:FIsCCSpell(strSpellId, strSpellName, iSpellSchool)

	return self:FInList(strSpellName, self.db.profile.strIncomingCC);

end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FHasBlacklistedAura
--
--		Returns true if the focus/target has an aura that will make the caster immune to
--		interrupts or will make the cast instant.
--
function FocusInterruptSounds:FHasBlacklistedAura(iSourceFlags, strSpellId, strSpellName, iSpellSchool)

	-- Go through recently cast buffs
	if (nil ~= self.lastInstacastSelfBuffName
		and GetTime() - self.lastInstacastSelfBuffTime < 1
		and self:FIsAuraBlacklisted(self.lastInstacastSelfBuffName, strSpellId, strSpellName, iSpellSchool)
	) then
		return true;
	end

	-- Go through the current buffs
	for i = 1, 40 do
		local strBuffName;

		if (0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_FOCUS)) then
			tbBuffData = C_UnitAuras.GetBuffDataByIndex("focus", i);
		elseif (0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_TARGET)) then
			tbBuffData = C_UnitAuras.GetBuffDataByIndex("target", i);
		end

		if (nil ~= tbBuffData and self:FIsAuraBlacklisted(tbBuffData.name, strSpellId, strSpellName, iSpellSchool)) then
			return true;
		end
	end

	return false;
end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsPlayerSpellAvailable
--
--		Returns true if you can cast the given spell.
--
function FocusInterruptSounds:FIsPlayerSpellAvailable(strSpellName)

	-- Trim off any ; comments
	local iSemiColonIndex = strSpellName:find(";");
	if (nil ~= iSemiColonIndex) then
		strSpellName = strSpellName:sub(1, iSemiColonIndex - 1);
	end

	-- Is it a pet spell
	local iPetIndex = strSpellName:find("p");
	local isPetSpell = false;
	if (1 == iPetIndex) then
		isPetSpell = true;
		strSpellName = strSpellName:sub(2, #strSpellName);
	end

	-- Make sure the user wants these extra checks
	if (not self.db.profile.fCheckSpellAvailability) then
		return true;
	end
	
	-- Make sure there's a pet if this is a pet spell (for some reason, IsSpellKnown() is returning true for Felhunter spells
	-- on my rogue)
	if (isPetSpell and not IsPetActive()) then
		-- self:CheckAndPrintMessage("No pet active");
		return false;
	end
	
	-- Is the spell known?
	if (nil ~= tonumber(strSpellName) and not IsSpellKnown(strSpellName, isPetSpell)) then
		return false;
	end

	-- Verify that the spell isn't on cooldown
	local tbSpellCooldown = C_Spell.GetSpellCooldown(strSpellName);
	if (nil == tbSpellCooldown or tbSpellCooldown.startTime ~= 0 or not tbSpellCooldown.isEnabled) then
		-- self:CheckAndPrintMessage(strSpellName .. " not known or on CD");
		return false;
	end

	-- self:CheckAndPrintMessage(strSpellName .. " available");
	return true;
end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:FIsInterruptAvailable
--
--		Returns true if you can cast any interrupt.
--
function FocusInterruptSounds:FIsInterruptAvailable()

	-- Make sure the user wants these extra checks
	if (not self.db.profile.fCheckSpellAvailability) then
		return true;
	end

	for strSpell in string.gmatch(self.db.profile.strPlayerInterruptSpells, "[^%s][^\r\n]+[^%s]") do
		if (self:FIsPlayerSpellAvailable(strSpell)) then
			return true;
		end
	end

	return false;
end

---------------------------------------------------------------------------------------------------
--	FocusInterruptSounds:COMBAT_LOG_EVENT_UNFILTERED
--
--		Handler for combat log events.
--
function FocusInterruptSounds:COMBAT_LOG_EVENT_UNFILTERED(event)

	iTimestamp, strEventType, fHideCaster, strSourceGuid, strSourceName, iSourceFlags, iSourceFlags2, strDestGuid, strDestName, iDestFlags, iDestFlags2, varParam1, varParam2, varParam3, varParam4, varParam5, varParam6 = CombatLogGetCurrentEventInfo()

	local fHandled = false;

	-- Short circuit this processing if we're essentially disabled
	if (not self.db.profile.fEnableText and not self.db.profile.fEnableSound) then
		return
	end

	-- Track instacast buffs
	if (self:FIsSourceFocusOrTarget(iSourceFlags)
			and "SPELL_CAST_SUCCESS" == strEventType
			and self:FInMap(varParam2, nil, self.db.profile.strAuraBlacklist)
	) then
		self.lastInstacastSelfBuffName = varParam2;
		self.lastInstacastSelfBuffTime = GetTime();
	end

	-- Turn off all notifications while in a vehicle
	if (self.db.profile.fDisableInVehicle and UnitHasVehicleUI("player")) then
		return
	end

	-- Global override sounds
	if (not fHandled
			and SETTING_MODE_ON == self.db.profile.strGlobalOverrideMode
			and self:FIsSpellCastStart(strEventType, iSourceFlags, varParam1, varParam2, varParam3)
			and self:FIsCasterOrSpellGlobalOverride(strSourceName, iSourceFlags, varParam1, varParam2, varParam3)
	) then
		self:CheckAndPrintMessage(strSourceName .. " 正在施放 |cffff4444" .. varParam2 .. "|r!");
		self:CheckAndPlaySound(self.db.profile.strGlobalOverrideSound);
		fHandled = true;
	end

	-- Your partner is sheeped, play a sound
	if (not fHandled
			and SETTING_MODE_ON == self.db.profile.strPartnerCCMode
			and 0 ~= bit.band(iDestFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY)
			and 0 ~= bit.band(iDestFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY)
			and "SPELL_AURA_APPLIED" == strEventType
			and self:FInList(varParam2, self.db.profile.strPartnerCC)
			and IsActiveBattlefieldArena()
	) then
		self:CheckAndPrintMessage(strDestName .. " 被變羊了!");
		self:CheckAndPlaySound(self.db.profile.strPartnerCCSound);
		fHandled = true;
	end

	-- Enemy player in an arena is innervated or PvE mob has a buff that should be purged
	if (not fHandled
			and SETTING_MODE_ON == self.db.profile.strPurgeMode
			and 0 == bit.band(iDestFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY)
			and "SPELL_AURA_APPLIED" == strEventType
			and ((IsActiveBattlefieldArena()
					and self:FInList(varParam2, self.db.profile.strArenaPurge))
				or 0 ~= bit.band(iDestFlags, COMBATLOG_OBJECT_CONTROL_NPC)
					and self:FInList(varParam1, self.db.profile.strPvePurgeIds))
	) then
		self:CheckAndPrintMessage(strDestName .. " 獲得 " .. varParam2 .. "!");
		self:CheckAndPlaySound(self.db.profile.strPurgeSound);
		fHandled = true;
	end

	-- Play a sound when the Target or Focus starts casting
	if (not fHandled) then
		local fIsSourceFocusOrTarget, fIsSourceTarget = self:FIsSourceFocusOrTarget(iSourceFlags);
		if (fIsSourceFocusOrTarget
			and self:FIsSpellCastStart(strEventType, iSourceFlags, varParam1, varParam2, varParam3)
			and not self:FIsCasterOrSpellBlacklisted(strSourceName, iSourceFlags, varParam1, varParam2, varParam3)
			and not self:FHasBlacklistedAura(iSourceFlags, varParam1, varParam2, varParam3)
			and self:FIsInterruptAvailable()
		) then
			self:CheckAndPrintMessage(strSourceName .. " 正在施放 |cffff4444" .. varParam2 .. "|r!");

			local fIsLowPri = self:FInList(varParam1, self.db.profile.strLowPrioritySpells);
			local strCastingSoundFile = nil;
			if (fIsSourceTarget) then
				if (fIsLowPri) then
					strCastingSoundFile = self.db.profile.strTargetLowPriSound;
				else
					strCastingSoundFile = self.db.profile.strTargetCastingSound;
				end
			else
				if (fIsLowPri) then
					strCastingSoundFile = self.db.profile.strFocusLowPriSound;
				else
					strCastingSoundFile = self.db.profile.strFocusCastingSound;
				end
			end

			self:CheckAndPlaySound(strCastingSoundFile);
			fHandled = true;
		end
	end

	-- Play a sound when a hostile player is attempting to CC you
	if (SETTING_MODE_ON == self.db.profile.strIncomingCCMode
			and 0 == bit.band(iSourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY)
			and 0 == bit.band(iSourceFlags, COMBATLOG_OBJECT_CONTROL_NPC)
			and self:FIsSpellCastStart(strEventType, iSourceFlags, varParam1, varParam2, varParam3)
			and self:FIsCCSpell(varParam1, varParam2, varParam3)
	) then
		if (nil ~= self.strAntiCCSpellName
			and self:FIsPlayerSpellAvailable(self.strAntiCCSpellName)
			and (IsActiveBattlefieldArena() or 1 == C_Spell.IsSpellInRange(self.str30YardSpellName, strTarget))
		) then
			self:CheckAndPrintMessage(strSourceName .. " 正在施放控場技: |cffffcc44" .. varParam2 .. "|r!");
			if (not fHandled) then
				self:CheckAndPlaySound(self.db.profile.strIncomingCCSound);
				fHandled = true;
			end
		else
			self:CheckAndPrintMessage(strSourceName .. " 正在施放控場技: |cffffcc44" .. varParam2 .. "|r (距離過遠/無法動作)。");
		end
	end

	-- Play sound when you interrupt a hostile target
	if (not fHandled
			and "SPELL_INTERRUPT" == strEventType
			and 0 ~= bit.band(iSourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE)
			and 0 == bit.band(iDestFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY)
	) then
		self:CheckAndPrintMessage("已成功打斷 |cffaaffff" .. varParam5 .. "|r!");
		if (SETTING_MODE_ON == self.db.profile.strInterruptCelebrationMode) then
			self:CheckAndPlaySound(self.db.profile.strInterruptCelebrationSound);
		end
		if (self.db.profile.fAnnounceInterrupts) then
			local strChannel = nil;
			local fInInstance, instanceType = IsInInstance();

			if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or IsInRaid(LE_PARTY_CATEGORY_INSTANCE) or instanceType == "pvp" or instanceType == "arena") then
				strChannel = "INSTANCE_CHAT";
			elseif (IsInRaid(LE_PARTY_CATEGORY_HOME)) then
				strChannel = "RAID";
			elseif (IsInGroup(LE_PARTY_CATEGORY_HOME)) then
				strChannel = "PARTY";
			end

			if (nil ~= strChannel) then
				SendChatMessage("[斷法] 已打斷 " .. strDestName .. " 的 " .. C_Spell.GetSpellLink(varParam4), strChannel);
			end
		end
		fHandled = true;
	end
end
