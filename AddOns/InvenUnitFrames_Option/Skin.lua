local IUF = InvenUnitFrames
local Option = IUF.optionFrame

local _G = _G
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local InCombatLockdown = _G.InCombatLockdown

local function updateAllIcons(object)
	for method, func in pairs(IUF.callbacks) do
		if method:find("Icon$") and type(func) == "function" then
			func(object)
		end
	end
end

local function setSkin()
	IUF:SetScale(IUF.db.scale)
	if IUF.db.skin == "Default" then
		if type(IUF.SetDefaultSkinSquare) == "function" then
			IUF:SetDefaultSkinSquare(nil)
		end
	elseif IUF.db.skin == "DefaultSquare" then
		if type(IUF.SetDefaultSkinSquare) == "function" then
			IUF:SetDefaultSkinSquare(true)
		end
	end
	for _, unit in ipairs(IUF.objectOrder) do
		if IUF.units[unit].needElement then
			IUF.units[unit]:SetLocation()
		else
			IUF:SetObjectSkin(IUF.units[unit])

			updateAllIcons(IUF.units[unit])
		end
		if IUF.units[unit].preview then
			IUF:SetObjectSkin(IUF.units[unit].preview)
			updateAllIcons(IUF.units[unit].preview)
		end
	end
	IUF:CollectGarbage()
end

local function clearSetting()
	IUF.db.scale = 1
	for unit, unitdb in pairs(IUF.db.units) do
		for skindb in pairs(unitdb.skin) do
			unitdb.skin[skindb] = nil
		end
	end

end

local function clearLocation()
	for unit, unitdb in pairs(IUF.db.units) do
		unitdb.pos[1], unitdb.pos[2] = nil
	end
end

local function needBackup()
	if IUF.db.scale == 1 then
		for _, unitdb in pairs(IUF.db.units) do
			if unitdb.pos[1] then
				return true
			else
				for _ in pairs(unitdb.skin) do
					return true
				end
			end
		end
		return nil
	else
		return true
	end
end

function Option:BackupSkin()
	if IUF.db then
		if needBackup() then
			IUF.db.backup[IUF.db.skin] = CopyTable(IUF.db.units)
			IUF.db.backup[IUF.db.skin].scale = IUF.db.scale
		else
			IUF.db.backup[IUF.db.skin] = nil
		end
	end
end

function Option:SetSkin(skin)
	-- 프레임 전체에 스킨 적용
	if not InCombatLockdown() and skin and IUF:LoadSkinAddOn(skin) and IUF.skins[skin] then
		if IUF.db.skin ~= skin then
			self:BackupSkin()
		end
		IUF.db.skin = skin
		IUF.db.skinName = IUF.skinDB.idx[IUF.db.skin]
		if IUF.db.backup[skin] then
			IUF.db.scale = IUF.db.backup[skin].scale
			IUF.db.units = CopyTable(IUF.db.backup[skin])
			IUF.db.units.scale = nil
			IUF.db.backup[skin] = nil
		else
			IUF.db.scale = 1
			clearSetting()
			clearLocation()
		end
		setSkin()
	end
end

function Option:ClearSetting()
	if not InCombatLockdown() then
		clearSetting()
		setSkin()
	end
end

function Option:ClearLocation()
	if not InCombatLockdown() then
		clearLocation()
		for _, unit in ipairs(IUF.objectOrder) do
			IUF.units[unit]:SetLocation()
			if IUF.units[unit].preview then
				IUF.units[unit].preview:SetLocation()
			end
		end
		IUF:CollectGarbage()
	end
end

local skinTypes = {}

local function isSettingSkin(s)
	if type(s) == "table" then
		if s.default then
			for p in pairs(s) do
				if p ~= "default" then
					return true
				end
			end
		else
			return true
		end
	end
	return nil
end

local sortID = {
	base = 1, player = 2, pet = 3, pettarget = 4,
	target = 5, targettarget = 6, targettargettarget = 7,
	focus = 8, focustarget = 9, focustargettarget = 10,
	party = 11, partypet = 12, partytarget = 13,
	boss = 14,
}

local function sortfunc(a, b)
	if sortID[a] and sortID[b] then
		return sortID[a] < sortID[b]
	elseif sortID[a] then
		return false
	elseif sortID[b] then
		return true
	else
		return a < b
	end
end

function Option:GetSkinTypes(objectType)
	for p in pairs(skinTypes) do
		skinTypes[p] = nil
	end
	for p, v in pairs(IUF.skins[IUF.db.skin]) do
		if isSettingSkin(v) and objectType ~= p and not(p == "base" and objectType and not IUF.skins[IUF.db.skin][objectType]) then
			if IUF.db.skin == "Blizzard" and p == "pet" then
				-- ignore
			else
				tinsert(skinTypes, p)
			end
		end
	end
	sort(skinTypes, sortfunc)
	tinsert(skinTypes, 1, "기본값")
	return skinTypes
end