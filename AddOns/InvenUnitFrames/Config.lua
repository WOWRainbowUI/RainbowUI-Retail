local IUF = InvenUnitFrames

local _G = _G
local type = _G.type
local ipairs = _G.ipairs
local UnitName = _G.UnitName
local GetRealmName = _G.GetRealmName
local InCombatLockdown = _G.InCombatLockdown

local units = { "player", "pet", "pettarget", "target", "targettarget", "targettargettarget", "focus", "focustarget", "focustargettarget", "party", "partypet", "partytarget", "boss" }

local function createNewProfiles(profile)
	if InvenUnitFramesDB.profiles[profile] then return end
	InvenUnitFramesDB.profiles[profile] = {
		skin = "Default", units = {}, classBar = { use = true, pos = "BOTTOM", useBlizzard = false, texture = "Smooth v2" }, backup = {},
		scale = 1, tooltip = 1, barAnimation = true, hideInRaid = true, barBackgroundAlpha = 0.2, highlightAlpha = 0.15, lock = true,
		aggroBorder = 1,
	}
	for _, unit in ipairs(units) do
		InvenUnitFramesDB.profiles[profile].units[unit] = { active = true, skin = {}, pos = {} }
	end
	InvenUnitFramesDB.profiles[profile].units.pettarget.active = false
end

local function addNewConfig(db)
	if type(db.dispel) ~= "table" then
		db.dispel = { active = true, alpha = 0.5 }
	end
	if type(db.heal) ~= "table" then
		db.heal = { active = true, alpha = 0.4, player = true }
	end
	if type(db.backup) ~= "table" then
		db.backup = {}
	end
	if type(db.focusKey) ~= "table" then
		db.focusKey = { mod = 4, button = 2 }
	end
	if type(db.colors) == "table" then
		db.colors = nil
	end
	if type(db.classBar) == "table" then
		db.classBar.DRUID, db.classBar.DEATHKNIGHT, db.classBar.WARLOCK, db.classBar.PALADIN = nil
	else
		db.classBar = {}
	end
	if not db.classBar.pos then
		db.classBar.pos = "BOTTOM"
	end
	if not db.classBar.texture then
		db.classBar.use = true
		db.classBar.texture = "Smooth v2"
		db.classBar.useBlizzard = false
	end
	db.units.boss = db.units.boss or { active = true, skin = {}, pos = {} }
	db.units.pettarget = db.units.pettarget or { active = false, skin = {}, pos = {} }
	for skin in pairs(db.backup) do
		db.backup[skin].boss = db.backup[skin].boss or { active = true, skin = {}, pos = {} }
		db.backup[skin].pettarget = db.backup[skin].pettarget or { active = false, skin = {}, pos = {} }
	end
	if db.aggroBorder == nil then
		db.aggroBorder = 1
	end
end

local function clearGarbage(db)
	for unit, unitdb in pairs(db.units) do
		for p in pairs(unitdb) do
			if not(p == "active" or p == "skin" or p == "pos") then
				unitdb[p] = nil
			end
		end
	end
end

function IUF:InitDB()
	InvenUnitFramesDB = InvenUnitFramesDB or { profile = {}, profiles = {}, minimapButton = { angle = 198.5, show = false, dragable = true } }
	if type(InvenUnitFramesDB.minimapButton) ~= "table" then
		InvenUnitFramesDB.minimapButton = { angle = 198.5, show = false, dragable = true }
	end
	if type(InvenUnitFramesDB.colors) ~= "table" then
		InvenUnitFramesDB.colors = {
			combo = { 1, 1, 0 },
			class = {
				FRIEND = { 0, 1, 0 },
				NEUTRAL = { 1, 1, 0 },
				ENEMY = { 1, 0.12, 0.12 },
				PET = { 0, 1, 0 },
			 },
			 power = {
				[0] = { PowerBarColor[0].r, PowerBarColor[0].g, PowerBarColor[0].b },	-- Mana
				[1] = { PowerBarColor[1].r, PowerBarColor[1].g, PowerBarColor[1].b },	-- Rage
				[2] = { PowerBarColor[2].r, PowerBarColor[2].g, PowerBarColor[2].b },	-- Focus
				[3] = { PowerBarColor[3].r, PowerBarColor[3].g, PowerBarColor[3].b },	-- Energy
				[6] = { PowerBarColor[6].r, PowerBarColor[6].g, PowerBarColor[6].b },	-- Runic Power
				[8] = { PowerBarColor[8].r, PowerBarColor[8].g, PowerBarColor[8].b },	-- Lunar
			},
			casting = {
				NORMAL = { 1, 0.7, 0 },
				SHIELD = { 1, 0, 0 },
				CHANNEL = { 0.4, 0.6, 0.8 },
			},
		}
		for class, color in pairs(RAID_CLASS_COLORS) do
			InvenUnitFramesDB.colors.class[class] = { color.r, color.g, color.b }
		end
	else
		for class, color in pairs(RAID_CLASS_COLORS) do
			InvenUnitFramesDB.colors.class[class] = InvenUnitFramesDB.colors.class[class] or { color.r, color.g, color.b }
		end
	end
	self.colordb = InvenUnitFramesDB.colors
	
	InvenUnitFramesDB.hidePartyFrame = false
	
	createNewProfiles("Default")
	for _, db in pairs(InvenUnitFramesDB.profiles) do
		addNewConfig(db)
		clearGarbage(db)
	end
	self.dbKey = UnitName("player").." - "..GetRealmName()
	InvenUnitFramesDB.profile[self.dbKey] = InvenUnitFramesDB.profile[self.dbKey] or "Default"
	if InvenUnitFramesDB.profiles[InvenUnitFramesDB.profile[self.dbKey]] then
		self.db = InvenUnitFramesDB.profiles[InvenUnitFramesDB.profile[self.dbKey]]
	else
		InvenUnitFramesDB.profile[self.dbKey] = "Default"
		self.db = InvenUnitFramesDB.profiles.Default
	end
	self.version = C_AddOns.GetAddOnMetadata("InvenUnitFrames", "Version")
end

function IUF:SelectProfile(profile)
	if not InCombatLockdown() and type(profile) == "string" and InvenUnitFramesDB.profiles[profile] and InvenUnitFramesDB.profile[self.dbKey] ~= profile then
		self.optionFrame:BackupSkin()
		InvenUnitFramesDB.profile[self.dbKey] = profile
		self.db = InvenUnitFramesDB.profiles[profile]
		self.db.backup[self.db.skin] = CopyTable(self.db.units)
		self.db.backup[self.db.skin].scale = self.db.scale
		self.optionFrame:SetSkin(self.db.skin)
		self:EnableModules()
	end
end

function IUF:ResetProfile(profile)
	if not InCombatLockdown() and type(profile) == "string" and InvenUnitFramesDB.profiles[profile] then
		InvenUnitFramesDB.profiles[profile] = nil
		createNewProfiles(profile)
		addNewConfig(InvenUnitFramesDB.profiles[profile])
		self.optionFrame:SetSkin(self.db.skin)
		self:EnableModules()
		IUF:CollectGarbage()
	end
end

function IUF:CreateNewProfile(newProfile, targetProfile)
	if not InCombatLockdown() and type(newProfile) == "string" and newProfile ~= "Default" and not InvenUnitFramesDB.profiles[newProfile] then
		if type(targetProfile) == "string" and InvenUnitFramesDB.profiles[targetProfile] then
			InvenUnitFramesDB.profiles[newProfile] = CopyTable(InvenUnitFramesDB.profiles[targetProfile])
		else
			createNewProfiles(newProfile)
			addNewConfig(InvenUnitFramesDB.profiles[newProfile])
		end
		self:SelectProfile(newProfile)
		IUF:CollectGarbage()
	end
end

function IUF:DeleteProfile(profile)
	if not InCombatLockdown() and type(profile) == "string" and profile ~= "Default" and InvenUnitFramesDB.profiles[profile] then
		InvenUnitFramesDB.profiles[profile] = nil
		for char, key in pairs(InvenUnitFramesDB.profile) do
			if key == profile then
				InvenUnitFramesDB.profile[char] = "Default"
				if char == self.dbKey then
					IUF:SelectProfile("Default")
				end
			end
		end
		IUF:CollectGarbage()
	end
end