local IUF = InvenUnitFrames
IUF.modules = {}
IUF.skins, IUF.skinPos = {}, {}
IUF.skinDB = { list = {}, name = {}, idx = {} }

local _G = _G
local type = _G.type
local pairs = _G.pairs
local select = _G.select
local tinsert = _G.table.insert
local GetNumAddOns = _G.GetNumAddOns
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMetadata = _G.GetAddOnMetadata
local LoadAddOn = _G.LoadAddOn
local IsAddOnLoaded = _G.IsAddOnLoaded

local loadedSkins, skinAddOns, skinAddOnsIndex = {}, {}, {}
local moduleAddOns = {}

function IUF:SearchModules()
	local enabled, reason, moduletype, loaded
	for i = 1, C_AddOns.GetNumAddOns() do
		enabled, reason = select(4, C_AddOns.GetAddOnInfo(i))
		if enabled or reason == "DEMAND_LOADED" then
			moduletype = C_AddOns.GetAddOnMetadata(i, "X-InvenUnitFrames-Skin")
			loaded = C_AddOns.IsAddOnLoaded(i)
			if moduletype then
				for skin in moduletype:gmatch("[^ ,]+") do
					skin = (skin or ""):trim()
					if skin ~= "" and not skinAddOns[skin] and not loadedSkins[skin] then
						skinAddOns[skin] = i
						if not loaded then
							skinAddOnsIndex[i] = true
						end
					end
				end
			end
			moduletype = C_AddOns.GetAddOnMetadata(i, "X-InvenUnitFrames-Module")
			if moduletype and moduletype ~= "Heal" then
				moduletype = (moduletype or ""):trim()
				if moduletype ~= "" then
					if not loaded then
						moduleAddOns[moduletype] = i
					end
				end
			end
		end
	end
end

function IUF:HasModule(module)
	if module then
		return self.modules[module] or moduleAddOns[module]
	else
		return nil
	end
end

function IUF:LoadModule(module)
	if module then
		if self.modules[module] then
			return true
		elseif moduleAddOns[module] then
			C_AddOns.LoadAddOn(moduleAddOns[module])
			moduleAddOns[module] = nil
			self.modules[module] = self.modules[module] or true
			return self.modules[module]
		end
	end
	return nil
end

local function moduleIsActive(name)
	if type(name) == "string" then
		if type(IUF.db[name]) == "table" then
			return IUF.db[name].active
		else
			name = name:sub(1, 1):lower()..name:sub(2)
			if type(IUF.db[name]) == "table" then
				return IUF.db[name].active
			end
		end
	end
	return nil
end

function IUF:EnableModules()
	for modName in pairs(moduleAddOns) do
		if modName ~= "Option" and moduleIsActive(modName) then
			self:LoadModule(modName)
		end
	end
	for modName, modTable in pairs(self.modules) do
		if type(modTable) == "table" then
			if type(modTable.SetActive) == "function" then
				modTable:SetActive()
			end
			if type(modTable.Setup) == "function" then
				modTable:Setup()
			end
		end
	end
end

function IUF:RegisterSkin(skin, name, config, pos)
	-- 스킨 설정 등록
	if type(skin) == "string" and type(config) == "table" and not self.skins[skin] then
		if config.base or config.player then
			name = ((type(name) == "string" and name:len() > 0) and name or skin):trim()
			if self.skinDB.name[name] then
				config, pos = nil, nil
			else
				loadedSkins[skin] = true
				skinAddOns[skin] = nil
				self.skinDB.name[name] = skin
				self.skinDB.idx[skin] = name
				tinsert(self.skinDB.list, name)
				for _, units in pairs(config) do
					for key, value in pairs(units) do
						if type(value) == "string" and value:find("self") then
							units[key] = "return function(self, object, width, height, IUF)\n"..value.."\nend"
						end
					end
				end
				self.skins[skin] = config
				self.skinPos[skin] = pos
				if skin == "Default" and type(IUF.CreateDefaultSquareSkin) == "function" then
					IUF:CreateDefaultSquareSkin(loadedSkins)
				end
			end
		end
	end
end

function IUF:LoadSkinAddOn(skin)
	if type(skin) == "string" then
		if loadedSkins[skin] then
			return true
		elseif skinAddOns[skin] then
			if skinAddOnsIndex[skinAddOns[skin]] then
				skinAddOnsIndex[skinAddOns[skin]] = nil
				C_AddOns.LoadAddOn(skinAddOns[skin])
			end
			if loadedSkins[skin] then
				return true
			else
				return nil
			end
		end
	end
	return nil
end

function IUF:LoadAllSkinAddOns()
	for i in pairs(skinAddOnsIndex) do
		skinAddOnsIndex[i] = nil
		C_AddOns.LoadAddOn(i)
		for skin, idx in pairs(skinAddOns) do
			if i == idx then
				skinAddOns[skin] = nil
			end
		end
	end
end