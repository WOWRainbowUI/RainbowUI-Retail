-- AldrachiReaverTrackers.lua
-- Tracker for Aldrachi Reaver Hero Talents (Demon Hunter, Vengeance/Havoc)
-- Triggers on SPELL_CAST_SUCCESS for spellID 1283344, displays icons for spenders 228477 and 263642

local SPELL_TRIGGER_ID = 1283344
local SPENDERS = {
	[228477] = { icon = 1344653 }, -- Soul Cleave
	[263642] = { icon = 1388065 }, -- Fracture
}
local spenderList = {228477, 263642}

local _, class = UnitClass("player")
if class ~= "DEMONHUNTER" then return end

local function IsVengeanceOrHavoc()
	local spec = GetSpecialization and GetSpecialization() or nil
	return spec == 1 or spec == 2 -- 1 = Havoc, 2 = Vengeance
end
local function getDB(key, default)
	local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
	if not db then return default end
	if db["NewSpenderTracker_"..key] == nil then return default end
	return db["NewSpenderTracker_"..key]
end
local function showGlow() return getDB("showGlow", true) end
local function setDB(key, value)
	local db = PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
	if not db then return end
	db["NewSpenderTracker_"..key] = value
end

local frame = CreateFrame("Frame", "NewSpenderTrackerFrame", UIParent)
frame:SetSize(getDB("iconSize", 40)*2 + getDB("iconSpacing", 0), getDB("iconSize", 40))
frame:SetPoint("CENTER", UIParent, "CENTER", getDB("xOffset", 0), getDB("yOffset", 0))
frame:Hide()
frame.locked = getDB("locked", true)
local iconFrames = {}
local iconSize = getDB("iconSize", 40)
local iconSpacing = getDB("iconSpacing", 0)
local activeSpenders = {}
local spenderTimers = {}

function ShowSpenderIcons()
	wipe(activeSpenders)
	wipe(spenderTimers)
	for _, spellID in ipairs(spenderList) do
		activeSpenders[spellID] = true
		spenderTimers[spellID] = GetTime() + 30
	end
	UpdateSpenderIcons()
end

local LibCustomGlow = _G.LibStub and _G.LibStub("LibCustomGlow-1.0", true)
function UpdateSpenderIcons()
	iconSize = getDB("iconSize", 40)
	iconSpacing = getDB("iconSpacing", 0)
	local shown = 0
	for idx, spellID in ipairs(spenderList) do
		if not iconFrames[idx] then
			local f = CreateFrame("Frame", nil, frame)
			f:SetSize(iconSize, iconSize)
			f:SetParent(frame)
			f:SetFrameStrata("HIGH")
			f.icon = f:CreateTexture(nil, "ARTWORK")
			f.icon:SetAllPoints(f)
			f.cooldown = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
			f.cooldown:SetAllPoints(f)
			iconFrames[idx] = f
		end
		local f = iconFrames[idx]
		f:SetSize(iconSize, iconSize)
		if activeSpenders[spellID] then
			f.icon:SetTexture(SPENDERS[spellID].icon)
			f:SetPoint("LEFT", frame, "LEFT", shown*(iconSize+iconSpacing), 0)
			f:Show()
			if LibCustomGlow and LibCustomGlow.PixelGlow_Stop then
				LibCustomGlow.PixelGlow_Stop(f, "spenderglow"..spellID)
			end
			if showGlow() and LibCustomGlow and LibCustomGlow.PixelGlow_Start then
				LibCustomGlow.PixelGlow_Start(f, {1,1,0,1}, 8, 0.25, 8, 2, 0, 0, true, "spenderglow"..spellID)
			end
			if spenderTimers[spellID] then
				local start = GetTime()
				local duration = spenderTimers[spellID] - start
				if duration > 0 then
					f.cooldown:SetCooldown(start, duration)
				else
					f.cooldown:Clear()
				end
			else
				f.cooldown:Clear()
			end
			shown = shown + 1
		else
			if LibCustomGlow and LibCustomGlow.PixelGlow_Stop then
				LibCustomGlow.PixelGlow_Stop(iconFrames[idx], "spenderglow"..spellID)
			end
			f:Hide()
		end
	end
	if shown > 0 then
		frame:SetWidth(shown * iconSize + math.max(0, shown-1)*iconSpacing)
		frame:SetHeight(iconSize)
		frame:Show()
	else
		frame:Hide()
	end
end

local function StartDrag()
	if not frame.locked then
		frame:StartMoving()
	end
end
local function StopDrag()
	frame:StopMovingOrSizing()
	local x, y = frame:GetCenter()
	local ux, uy = UIParent:GetCenter()
	setDB("xOffset", math.floor(x - ux))
	setDB("yOffset", math.floor(y - uy))
end

frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function(self)
	if not self.locked then
		self:StartMoving()
	end
end)
frame:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	local x, y = self:GetCenter()
	local ux, uy = UIParent:GetCenter()
	setDB("xOffset", math.floor(x - ux))
	setDB("yOffset", math.floor(y - uy))
	self:SetPoint("CENTER", UIParent, "CENTER", getDB("xOffset", 0), getDB("yOffset", 0))
	UpdateSpenderIcons()
end)
frame:SetScript("OnMouseDown", function(self, button)
	if button == "LeftButton" and not self.locked then
		self:StartMoving()
	end
end)
frame:SetScript("OnMouseUp", function(self, button)
	if button == "LeftButton" then
		self:StopMovingOrSizing()
		local x, y = self:GetCenter()
		local ux, uy = UIParent:GetCenter()
		setDB("xOffset", math.floor(x - ux))
		setDB("yOffset", math.floor(y - uy))
		self:SetPoint("CENTER", UIParent, "CENTER", getDB("xOffset", 0), getDB("yOffset", 0))
		UpdateSpenderIcons()
	end
end)

function HideSpenderIcons()
	wipe(activeSpenders)
	wipe(spenderTimers)
	UpdateSpenderIcons()
end

local function OnEvent(self, event, ...)
	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local unit, _, spellID = ...
		if unit == "player" then
			if spellID == SPELL_TRIGGER_ID then
				ShowSpenderIcons()
			elseif SPENDERS[spellID] and activeSpenders[spellID] then
				activeSpenders[spellID] = nil
				spenderTimers[spellID] = nil
				UpdateSpenderIcons()
			end
		end
	end
end

frame:SetScript("OnUpdate", function(self, elapsed)
	if next(spenderTimers) then
		local now = GetTime()
		local changed = false
		for spellID, expire in pairs(spenderTimers) do
			if now >= expire then
				activeSpenders[spellID] = nil
				spenderTimers[spellID] = nil
				changed = true
			end
		end
		if changed then
			UpdateSpenderIcons()
		end
	end
end)

frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
frame:SetScript("OnEvent", OnEvent)

-- Options page
local NewSpenderTrackerOptions = {
    type = "group",
    name = "奧達奇掠奪者監控", -- 奧德拉奇掠奪者追蹤器
    order = 950,
    args = {
        header = {
            order = 0,
            type = "header",
            name = "奧達奇掠奪者監控選項", -- 奧德拉奇掠奪者追蹤器選項
        },
        iconSize = {
            order = 1,
            type = "range",
            name = "圖示大小",
            min = 16,
            max = 128,
            step = 1,
            get = function() return getDB("iconSize", 40) end,
            set = function(_, val) setDB("iconSize", val); UpdateSpenderIcons() end,
        },
        iconSpacing = {
            order = 2,
            type = "range",
            name = "圖示間距",
            min = 0,
            max = 64,
            step = 1,
            get = function() return getDB("iconSpacing", 0) end,
            set = function(_, val) setDB("iconSpacing", val); UpdateSpenderIcons() end,
        },
        xOffset = {
            order = 3,
            type = "range",
            name = "水平位置",
            min = -800,
            max = 800,
            step = 1,
            get = function() return getDB("xOffset", 0) end,
            set = function(_, val) setDB("xOffset", val);
                frame:SetPoint("CENTER", UIParent, "CENTER", val, getDB("yOffset", 0));
                UpdateSpenderIcons()
            end,
        },
        yOffset = {
            order = 4,
            type = "range",
            name = "垂直位置",
            min = -600,
            max = 600,
            step = 1,
            get = function() return getDB("yOffset", 0) end,
            set = function(_, val) setDB("yOffset", val);
                frame:SetPoint("CENTER", UIParent, "CENTER", getDB("xOffset", 0), val);
                UpdateSpenderIcons()
            end,
        },
        lock = {
            order = 5,
            type = "toggle",
            name = "鎖定圖示",
            desc = "鎖定/解鎖圖示框架以便拖曳。",
            get = function() return getDB("locked", true) end,
            set = function(_, val) setDB("locked", val); frame.locked = val end,
        },
        showGlow = {
            order = 6,
            type = "toggle",
            name = "顯示像素發光",
            desc = "顯示/隱藏圖示上的像素光暈效果。",
            get = function() return getDB("showGlow", true) end,
            set = function(_, val) setDB("showGlow", val); UpdateSpenderIcons() end,
        },
        test = {
            order = 7,
            type = "execute",
            name = "測試顯示圖示",
            func = function() ShowSpenderIcons() end,
        },
        hide = {
            order = 8,
            type = "execute",
            name = "隱藏圖示",
            func = function() HideSpenderIcons() end,
        },
    },
}

_G.NewSpenderTrackerOptions = NewSpenderTrackerOptions

if _G.PersonalResourceReskinPlus_Options then
	_G.PersonalResourceReskinPlus_Options.RegisterSubOptions("NewSpenderTracker", NewSpenderTrackerOptions)
end
