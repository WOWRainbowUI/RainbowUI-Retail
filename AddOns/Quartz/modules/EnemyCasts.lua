--[[
	Copyright (C) 2006-2007 Nymbia
	Copyright (C) 2010-2017 Hendrik "Nevcairiel" Leppkes < h.leppkes@gmail.com >

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]
local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")
local L = LibStub("AceLocale-3.0"):GetLocale("Quartz3")

local MODNAME = "EnemyCasts"
local Enemy = Quartz3:NewModule(MODNAME, "AceEvent-3.0")

local Player = Quartz3:GetModule("Player")
local Focus = Quartz3:GetModule("Focus", true)
local Target = Quartz3:GetModule("Target", true)

local TimeFmt = Quartz3.Util.TimeFormat
local ApplyFontStyle = Quartz3.Util.ApplyFontStyle

local media = LibStub("LibSharedMedia-3.0")
local lsmlist = AceGUIWidgetLSMlists

----------------------------
-- Upvalues
-- GLOBALS: CastingBarFrame
local tsort, tinsert = table.sort, table.insert
local bit_band, bit_bor = bit.band, bit.bor

local locked = true
local db, getOptions, castBar
local barColorObj, noInterruptColorObj

local defaults = {
	profile = {
		icons = true,
		iconside = "left",

		raidicons = true,
		raidiconside = "left",

		anchor = "free", -- "free"
		growdirection = "down", -- "up"

		position = "topleft",

		gap = 1,
		spacing = 1,
		offset = 3,

		nametext = true,
		timetext = true,

		texture = "Minimalist",
		width = 150,
		height = 16,
		font = "Friz Quadrata TT",
		fontsize = 10,
		fontOutline = "SHADOW",
		fontShadowColor = {0, 0, 0, 1},
		fontShadowOffsetX = 0.8,
		fontShadowOffsetY = -0.8,
		alpha = 1,

		textcolor = {1, 1, 1},
		barcolor = {0.71, 0, 1},
		noInterruptColor = {0.5, 0.5, 0.5},

		instanceonly = true,
	}
}

local function OnHide(frame)
	frame:SetScript("OnUpdate", nil)
end
local castbars = setmetatable({}, {
	__index = function(t,k)
		local bar = Quartz3:CreateStatusBar(nil, UIParent)
		t[k] = bar
		bar:SetFrameStrata("MEDIUM")
		bar:Hide()
		bar:SetScript("OnHide", OnHide)
		bar:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16})
		bar:SetBackdropColor(0,0,0)

		-- TextFrame ensures text is always above bars and overlays (like CastBarTemplate)
		bar.TextFrame = CreateFrame("Frame", nil, bar)
		bar.TextFrame:SetAllPoints(bar)
		bar.TextFrame:SetFrameLevel(bar:GetFrameLevel() + 4)
		
		bar.Text = bar.TextFrame:CreateFontString(nil, "OVERLAY")
		bar.TimeText = bar.TextFrame:CreateFontString(nil, "OVERLAY")
		bar.Icon = bar:CreateTexture(nil, "ARTWORK")

		bar.RaidIcon = bar:CreateTexture(nil, "OVERLAY")
		bar.RaidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
		bar.RaidIcon:Hide()

		Enemy:ApplySettings()
		return bar
	end
})

local casts = {}
local new, del
do
	local tblCache = setmetatable({}, {__mode="k"})
	function new()
		local entry = next(tblCache)
		if entry then tblCache[entry] = nil else entry = {} end
		return entry
	end

	function del(t)
		wipe(t)
		tblCache[t] = true
	end
end

local mover
local PLACEHOLDER_BARS = 3

-- Center-relative free coordinates, kept out of the defaults so stored legacy bottom-left values can be migrated once.
local FREE_DEFAULT_X, FREE_DEFAULT_Y = 0, 150

local function freeX()
	local x = db.x
	if x == nil then x = FREE_DEFAULT_X end
	return x
end

local function freeY()
	local y = db.y
	if y == nil then y = FREE_DEFAULT_Y end
	return y
end

local POSITION_GROWS_UP = { top = true, topright = true, topleft = true, leftup = true, rightup = true }

local function growsUp()
	if db.anchor == "free" then
		return db.growdirection == "up"
	end
	return POSITION_GROWS_UP[db.position] or false
end

-- The real bars have secret anchors, dragging and position reads go through this placeholder box.
local function ensureMover()
	if mover then return mover end

	mover = CreateFrame("Frame", nil, UIParent)
	mover:SetFrameStrata("MEDIUM")
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:EnableMouse(false)
	mover:RegisterForDrag("LeftButton")
	mover:Hide()

	mover.bg = mover:CreateTexture(nil, "BACKGROUND")
	mover.bg:SetAllPoints(mover)
	mover.bg:SetColorTexture(0, 0.5, 1, 0.25)

	mover.rows = {}
	for i = 1, PLACEHOLDER_BARS do
		local row = CreateFrame("StatusBar", nil, mover)
		row:SetMinMaxValues(0, 1)
		row.bg = row:CreateTexture(nil, "BACKGROUND")
		row.bg:SetAllPoints(row)
		row.bg:SetColorTexture(0, 0, 0, 1)
		row.icon = row:CreateTexture(nil, "ARTWORK")
		row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.time = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		mover.rows[i] = row
	end

	mover:SetScript("OnDragStart", mover.StartMoving)
	mover:SetScript("OnDragStop", function(frame)
		frame:StopMovingOrSizing()
		local scale = frame:GetScale()
		local cx = UIParent:GetWidth() / 2 / scale
		local cy = UIParent:GetHeight() / 2 / scale
		db.x = frame:GetLeft() - cx
		if db.growdirection == "up" then
			db.y = frame:GetBottom() - cy
		else
			db.y = frame:GetTop() - cy - db.height
		end
		Enemy:ApplySettings()
	end)

	local demoTime = 0
	mover:SetScript("OnUpdate", function(self, elapsed)
		demoTime = demoTime + elapsed
		for i, row in ipairs(self.rows) do
			row:SetValue((demoTime * 0.35 + i * 0.33) % 1)
		end
	end)

	return mover
end

local function positionMover()
	if not mover then return end

	local width, height, spacing = db.width, db.height, db.spacing
	local growUp = growsUp()
	local rows = #mover.rows

	mover:SetScale(Player.db.profile.scale)
	mover:SetSize(width, rows * height + (rows - 1) * spacing)
	mover:ClearAllPoints()
	if db.anchor == "free" then
		local x, y = freeX(), freeY()
		if growUp then
			mover:SetPoint("BOTTOMLEFT", UIParent, "CENTER", x, y)
		else
			mover:SetPoint("TOPLEFT", UIParent, "CENTER", x, y + height)
		end
	else
		local qpdb = Player.db.profile
		local position, gap, offset = db.position, db.gap, db.offset
		local showicons, iconside = db.icons, db.iconside
		local anchorframe
		if db.anchor == "focus" and Focus and Focus.Bar then
			anchorframe = Focus.Bar
		elseif db.anchor == "target" and Target and Target.Bar then
			anchorframe = Target.Bar
		else -- L["Player"]
			anchorframe = Player.Bar
		end

		if position == "top" then
			mover:SetPoint("BOTTOM", anchorframe, "TOP", 0, gap)
		elseif position == "bottom" then
			mover:SetPoint("TOP", anchorframe, "BOTTOM", 0, -1 * gap)
		elseif position == "topright" then
			mover:SetPoint("BOTTOMRIGHT", anchorframe, "TOPRIGHT", -1 * offset, gap)
		elseif position == "bottomright" then
			mover:SetPoint("TOPRIGHT", anchorframe, "BOTTOMRIGHT", -1 * offset, -1 * gap)
		elseif position == "topleft" then
			mover:SetPoint("BOTTOMLEFT", anchorframe, "TOPLEFT", offset, gap)
		elseif position == "bottomleft" then
			mover:SetPoint("TOPLEFT", anchorframe, "BOTTOMLEFT", offset, -1 * gap)
		elseif position == "leftup" then
			if iconside == "right" and showicons then
				offset = offset + db.height
			end
			if db.raidiconside == "right" and db.raidicons then
				offset = offset + db.height
			end
			if qpdb.iconposition == "left" and not qpdb.hideicon then
				offset = offset + qpdb.h
			end
			mover:SetPoint("BOTTOMRIGHT", anchorframe, "BOTTOMLEFT", -1 * offset, gap)
		elseif position == "leftdown" then
			if iconside == "right" and showicons then
				offset = offset + db.height
			end
			if db.raidiconside == "right" and db.raidicons then
				offset = offset + db.height
			end
			if qpdb.iconposition == "left" and not qpdb.hideicon then
				offset = offset + qpdb.h
			end
			mover:SetPoint("TOPRIGHT", anchorframe, "TOPLEFT", -3 * offset, -1 * gap)
		elseif position == "rightup" then
			if iconside == "left" and showicons then
				offset = offset + db.height
			end
			if db.raidiconside == "left" and db.raidicons then
				offset = offset + db.height
			end
			if qpdb.iconposition == "right" and not qpdb.hideicon then
				offset = offset + qpdb.h
			end
			mover:SetPoint("BOTTOMLEFT", anchorframe, "BOTTOMRIGHT", offset, gap)
		elseif position == "rightdown" then
			if iconside == "left" and showicons then
				offset = offset + db.height
			end
			if db.raidiconside == "left" and db.raidicons then
				offset = offset + db.height
			end
			if qpdb.iconposition == "right" and not qpdb.hideicon then
				offset = offset + qpdb.h
			end
			mover:SetPoint("TOPLEFT", anchorframe, "TOPRIGHT", offset, -1 * gap)
		end
	end

	local tex = media:Fetch("statusbar", db.texture)
	local font = media:Fetch("font", db.font)
	for i, row in ipairs(mover.rows) do
		row:SetSize(width, height)
		row:ClearAllPoints()
		local offset = (i - 1) * (height + spacing)
		if growUp then
			row:SetPoint("BOTTOMLEFT", mover, "BOTTOMLEFT", 0, offset)
		else
			row:SetPoint("TOPLEFT", mover, "TOPLEFT", 0, -offset)
		end
		row:SetStatusBarTexture(tex)
		if i == 2 then
			row:SetStatusBarColor(unpack(db.noInterruptColor))
		else
			row:SetStatusBarColor(unpack(db.barcolor))
		end
		row:SetValue(0.7)
		if db.icons then
			row.icon:SetSize(height, height)
			row.icon:SetTexture("Interface\\Icons\\Temp")
			row.icon:ClearAllPoints()
			if db.iconside == "left" then
				row.icon:SetPoint("RIGHT", row, "LEFT", -1, 0)
			else
				row.icon:SetPoint("LEFT", row, "RIGHT", 1, 0)
			end
			row.icon:Show()
		else
			row.icon:Hide()
		end
		for _, fontString in ipairs({ row.name, row.time }) do
			ApplyFontStyle(fontString, font, db.fontsize, db.fontOutline, db.fontShadowColor, db.fontShadowOffsetX, db.fontShadowOffsetY)
			fontString:SetTextColor(unpack(db.textcolor))
		end
		row.name:ClearAllPoints()
		row.name:SetPoint("LEFT", row, "LEFT", 2, 0)
		row.name:SetJustifyH("LEFT")
		local topIndex = growUp and rows or 1
		row.name:SetText(i == topIndex and L["Enemy CastBars"] or ("nameplate" .. i))
		row.name:SetShown(db.nametext)
		row.time:ClearAllPoints()
		row.time:SetPoint("RIGHT", row, "RIGHT", -2, 0)
		row.time:SetJustifyH("RIGHT")
		row.time:SetText("1.5")
		row.time:SetShown(db.timetext)
	end
end

function Enemy:SetMoverLocked(lock)
	locked = lock
	ensureMover()
	mover:EnableMouse(not lock and db.anchor == "free")
	mover:SetShown(not lock)
	if not lock then
		positionMover()
	end
	self:UpdateBars()
end

function Enemy:Unlock()
	if not self:IsEnabled() then return end
	self:SetMoverLocked(false)
end

function Enemy:Lock()
	if not self:IsEnabled() then return end
	self:SetMoverLocked(true)
end

function Enemy:OnInitialize()
	self.db = Quartz3.db:RegisterNamespace(MODNAME, defaults)
	db = self.db.profile

	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, L["Enemy CastBars"])
end

function Enemy:OnEnable()
	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	self:RegisterEvent("UNIT_SPELLCAST_STOP")
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	-- Clean up when nameplates are removed (recycled)
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	-- Clean up when leaving combat or dying
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_DEAD")
	-- Refresh bars when raid markers change
	self:RegisterEvent("RAID_TARGET_UPDATE")
	
	media.RegisterCallback(self, "LibSharedMedia_SetGlobal", function(mtype, override)
		if mtype == "statusbar" then
			for i, v in pairs(castbars) do
				v:SetStatusBarTexture(media:Fetch("statusbar", override))
			end
		end
	end)

	media.RegisterCallback(self, "LibSharedMedia_Registered", function(mtype, key)
		if mtype == "statusbar" and key == db.texture then
			for i, v in pairs(castbars) do
				v:SetStatusBarTexture(media:Fetch("statusbar", db.texture))
			end
		end
	end)

	self:ApplySettings()
end

-- Refresh bars when leaving combat or dying
function Enemy:PLAYER_REGEN_ENABLED()
	self:UpdateBars()
end

function Enemy:PLAYER_DEAD()
	-- Hide all bars on death and clear OnUpdate
	for i, bar in pairs(castbars) do
		bar:Hide()
		bar:SetScript("OnUpdate", nil)
		bar.durationObj = nil
	end
end

function Enemy:RAID_TARGET_UPDATE()
	self:UpdateBars()
end

-- Clean up when nameplate is removed
function Enemy:NAME_PLATE_UNIT_REMOVED(event, unit)
	self:UpdateBars()
end

function Enemy:OnDisable()
	if mover then
		locked = true
		mover:EnableMouse(false)
		mover:Hide()
	end

	for _, v in pairs(castbars) do
		v:Hide()
	end

	media.UnregisterCallback(self, "LibSharedMedia_SetGlobal")
	media.UnregisterCallback(self, "LibSharedMedia_Registered")
end

function Enemy:UNIT_SPELLCAST_START(event, unit)
	-- Only trigger for nameplate units
	if not unit:match("^nameplate") then return end
	self:UpdateBars()
end

function Enemy:UNIT_SPELLCAST_CHANNEL_START(event, unit)
	if not unit:match("^nameplate") then return end
	self:UpdateBars()
end

function Enemy:UNIT_SPELLCAST_STOP(event, unit)
	if not unit:match("^nameplate") then return end
	self:UpdateBars()
end
Enemy.UNIT_SPELLCAST_CHANNEL_STOP = Enemy.UNIT_SPELLCAST_STOP
Enemy.UNIT_SPELLCAST_INTERRUPTED = Enemy.UNIT_SPELLCAST_STOP
Enemy.UNIT_SPELLCAST_FAILED = Enemy.UNIT_SPELLCAST_STOP
Enemy.UNIT_SPELLCAST_SUCCEEDED = Enemy.UNIT_SPELLCAST_STOP


do
	-- Use durationObj:GetRemainingDuration() for time text
	
	local function onUpdate(bar)
		if bar.durationObj and db.timetext then
			local remaining = bar.durationObj:GetRemainingDuration()
			bar.TimeText:SetFormattedText("%.1f", remaining)
		end
	end
	
	function Enemy:UpdateBars()
		-- Hide ALL existing bars first
		for i, bar in pairs(castbars) do
			bar:Hide()
			bar.durationObj = nil
		end

		-- The placeholder mover replaces the real bars while unlocked
		if not locked then return end

		-- Don't show bars if player is dead or not in combat
		if UnitIsDeadOrGhost("player") then return end
		if not UnitAffectingCombat("player") then return end
		
		-- Instance only filter
		if db.instanceonly and not IsInInstance() then return end
		
		-- Scan all nameplates directly instead of using stored state
		-- This avoids issues with stale entries and secret value comparisons
		local barIndex = 0
		
		for i = 1, 40 do -- Max nameplates
			local unit = "nameplate" .. i
			-- Only show casts from enemies that are in combat
			if UnitExists(unit) and UnitIsEnemy("player", unit) and UnitAffectingCombat(unit) then
				-- Check for cast
				local spellName, _, texture, _, _, _, _, notInterruptible = UnitCastingInfo(unit)
				local isChannel = false
				local durationObj
				
				if spellName then
					durationObj = UnitCastingDuration(unit)
				else
					-- Check for channel
					spellName, _, texture, _, _, _, notInterruptible = UnitChannelInfo(unit)
					if spellName then
						isChannel = true
						durationObj = UnitChannelDuration(unit)
					end
				end
				
				-- Show bar if there's an active cast/channel with duration
				if spellName and durationObj then
					barIndex = barIndex + 1
					local bar = castbars[barIndex]
					
					bar.Text:SetText(spellName)
					bar.Icon:SetTexture(texture)
					bar:SetMinMaxValues(0, 1)
					bar:SetTimerDuration(durationObj)
					
					-- Store durationObj on bar for OnUpdate time text
					bar.durationObj = durationObj
					bar:SetScript("OnUpdate", onUpdate)

					-- Raid target marker
					if db.raidicons then
						local raidTargetIndex = GetRaidTargetIndex(unit)
						if issecretvalue(raidTargetIndex) or raidTargetIndex then
							SetRaidTargetIconTexture(bar.RaidIcon, raidTargetIndex)
							bar.RaidIcon:Show()
						else
							bar.RaidIcon:Hide()
						end
					else
						bar.RaidIcon:Hide()
					end

					if not issecretvalue(notInterruptible) and not notInterruptible then
						notInterruptible = false
					end
					bar:GetStatusBarTexture():SetVertexColorFromBoolean(notInterruptible, noInterruptColorObj, barColorObj)

					bar:Show()
				end
			end
		end
	end
end

do
	local function apply(i, bar, direction)
		local position, showicons, iconside, gap, spacing, offset
		local qpdb = Player.db.profile

		position = db.position
		showicons = db.icons
		iconside = db.iconside
		gap = db.gap
		spacing = db.spacing
		offset = db.offset

		bar:ClearAllPoints()
		bar:SetStatusBarTexture(media:Fetch("statusbar", db.texture))
		bar:SetStatusBarColor(unpack(db.barcolor))
		bar:SetWidth(db.width)
		bar:SetHeight(db.height)
		bar:SetScale(qpdb.scale)
		bar:SetAlpha(db.alpha)

		if i == 1 then
			local m = ensureMover()
			if growsUp() then
				bar:SetPoint("BOTTOMLEFT", m, "BOTTOMLEFT")
				direction = 1
			else
				bar:SetPoint("TOPLEFT", m, "TOPLEFT")
				direction = -1
			end
		else
			if direction == 1 then
				bar:SetPoint("BOTTOMRIGHT", castbars[i-1], "TOPRIGHT", 0, spacing)
			else -- -1
				bar:SetPoint("TOPRIGHT", castbars[i-1], "BOTTOMRIGHT", 0, -1 * spacing)
			end
		end

		local timetext = bar.TimeText
		if db.timetext then
			timetext:Show()
			timetext:ClearAllPoints()
			timetext:SetWidth(db.width)
			timetext:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
			timetext:SetJustifyH("RIGHT")
		else
			timetext:Hide()
		end
		ApplyFontStyle(timetext, media:Fetch("font", db.font), db.fontsize, db.fontOutline, db.fontShadowColor, db.fontShadowOffsetX, db.fontShadowOffsetY)
		timetext:SetTextColor(unpack(db.textcolor))
		timetext:SetNonSpaceWrap(false)
		timetext:SetHeight(db.height)

		local normaltimewidth = db.fontsize * 3

		local text = bar.Text
		if db.nametext then
			text:Show()
			text:ClearAllPoints()
			text:SetPoint("LEFT", bar, "LEFT", 2, 0)
			text:SetJustifyH("LEFT")
			if db.timetext then
				text:SetWidth(db.width - normaltimewidth)
			else
				text:SetWidth(db.width)
			end
		else
			text:Hide()
		end
		ApplyFontStyle(text, media:Fetch("font", db.font), db.fontsize, db.fontOutline, db.fontShadowColor, db.fontShadowOffsetX, db.fontShadowOffsetY)
		text:SetTextColor(unpack(db.textcolor))
		text:SetNonSpaceWrap(false)
		text:SetHeight(db.height)

		local icon = bar.Icon
		if showicons then
			icon:Show()
			icon:SetWidth(db.height-1)
			icon:SetHeight(db.height-1)
			icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			icon:ClearAllPoints()
			if iconside == "left" then
				icon:SetPoint("RIGHT", bar, "LEFT", -1, 0)
			else
				icon:SetPoint("LEFT", bar, "RIGHT", 1, 0)
			end
		else
			icon:Hide()
		end

		local raidIcon = bar.RaidIcon
		if db.raidicons then
			local raidIconSize = db.height - 1
			raidIcon:SetWidth(raidIconSize)
			raidIcon:SetHeight(raidIconSize)
			raidIcon:ClearAllPoints()
			if db.raidiconside == "left" then
				if showicons and iconside == "left" then
					-- Both on the left: raid icon goes outside the spell icon
					raidIcon:SetPoint("RIGHT", icon, "LEFT", -1, 0)
				else
					raidIcon:SetPoint("RIGHT", bar, "LEFT", -1, 0)
				end
			else
				if showicons and iconside == "right" then
					-- Both on the right: raid icon goes outside the spell icon
					raidIcon:SetPoint("LEFT", icon, "RIGHT", 1, 0)
				else
					raidIcon:SetPoint("LEFT", bar, "RIGHT", 1, 0)
				end
			end
			-- Visibility is controlled in UpdateBars based on actual marker data
		else
			raidIcon:Hide()
		end

		return direction
	end

	function Enemy:ApplySettings()
		db = self.db.profile

		local br, bg, bb = unpack(db.barcolor)
		barColorObj = CreateColor(br, bg, bb, 1)
		local nr, ng, nb = unpack(db.noInterruptColor)
		noInterruptColorObj = CreateColor(nr, ng, nb, 1)

		-- One-shot conversion of stored bottom-left free positions to the center-relative system.
		if not db.centerpos then
			db.centerpos = true
			if db.x ~= nil then db.x = db.x - UIParent:GetWidth() / 2 end
			if db.y ~= nil then db.y = db.y - UIParent:GetHeight() / 2 end
		end

		if self:IsEnabled() then
			ensureMover()
			positionMover()
			mover:SetShown(not locked)
			mover:EnableMouse(not locked and db.anchor == "free")
			local direction
			for i, v in pairs(castbars) do
				direction = apply(i, v, direction)
			end
		end
	end
end

do

	local function getfreeoptionshidden()
		return db.anchor ~= "free"
	end

	local function getnotfreeoptionshidden()
		return db.anchor == "free"
	end

	local positions = {
		["bottom"] = L["Bottom"],
		["top"] = L["Top"],
		["topleft"] = L["Top Left"],
		["topright"] = L["Top Right"],
		["bottomleft"] = L["Bottom Left"],
		["bottomright"] = L["Bottom Right"],
		["leftup"] = L["Left (grow up)"],
		["leftdown"] = L["Left (grow down)"],
		["rightup"] = L["Right (grow up)"],
		["rightdown"] = L["Right (grow down)"],
	}

	local function setOpt(info, value)
		db[info[#info]] = value
		Enemy:ApplySettings()
	end

	local function getOpt(info)
		return db[info[#info]]
	end

	local function getColor(info)
		return unpack(getOpt(info))
	end

	local function setColor(info, r, g, b, a)
		setOpt(info, {r, g, b, a})
	end

	local options
	function getOptions()
		if not options then
			options = {
				type = "group",
				name = L["Enemy CastBars"],
				order = 600,
				set = setOpt,
				get = getOpt,
				childGroups = "tab",
				args = {
					toggle = {
						type = "toggle",
						name = L["Enable"],
						desc = L["Enable"],
						get = function()
							return Quartz3:GetModuleEnabled(MODNAME)
						end,
						set = function(info, v)
							Quartz3:SetModuleEnabled(MODNAME, v)
						end,
						order = 96,
						width = "full",
					},
					settings = {
						type = "group",
						name = L["Settings"],
						args = {
							anchor = {
								type = "select",
								name = L["Anchor Frame"],
								desc = L["Select where to anchor the bars"],
								values = {["player"] = L["Player"], ["free"] = L["Free"], ["target"] = L["Target"], ["focus"] = L["Focus"]},
							},
							-- free
							lock = {
								type = "toggle",
								name = L["Lock"],
								desc = L["Toggle bar lock"],
								get = function()
									return locked
								end,
								set = function(info, v)
									Enemy:SetMoverLocked(v)
								end,
								hidden = getfreeoptionshidden,
								order = 98,
							},
							instanceonly = {
								type = "toggle",
								name = L["Only in Instances"],
								desc = L["Only show the casts of enemys when inside an instance (dungeon or raid)"],
								order = 99,
							},
							growdirection = {
								type = "select",
								name = L["Grow Direction"],
								desc = L["Set the grow direction of the bars"],
								values = {["up"] = L["Up"], ["down"] = L["Down"]},
								hidden = getfreeoptionshidden,
								order = 102,
							},
							x = {
								type = "range",
								name = L["X"],
								desc = L["Set an exact X value for this bar's position."],
								min = -2560, max = 2560, bigStep = 1,
								get = function() return freeX() end,
								order = 103,
								hidden = getfreeoptionshidden,
							},
							y = {
								type = "range",
								name = L["Y"],
								desc = L["Set an exact Y value for this bar's position."],
								min = -1600, max = 1600, bigStep = 1,
								get = function() return freeY() end,
								order = 103,
								hidden = getfreeoptionshidden,
							},
							-- anchored to a cast bar
							position = {
								type = "select",
								name = L["Position"],
								desc = L["Position the bars"],
								values = positions,
								hidden = getnotfreeoptionshidden,
								order = 101,
							},
							gap = {
								type = "range",
								name = L["Gap"],
								desc = L["Tweak the vertical position of thebars"],
								min = -35, max = 35, step = 1,
								hidden = getnotfreeoptionshidden,
								order = 102,
							},
							offset = {
								type = "range",
								name = L["Offset"],
								desc = L["Tweak the horizontal position of the bars"],
								min = -35, max = 35, step = 1,
								hidden = getnotfreeoptionshidden,
								order = 103,
							},
							spacing = {
								type = "range",
								name = L["Spacing"],
								desc = L["Tweak the space between bars"],
								min = -35, max = 35, step = 1,
								order = 104,
							},
							nl4 = {
								type = "description",
								name = "",
								order = 109,
							},
							icons = {
								type = "toggle",
								name = L["Spell Icon"],
								desc = L["Show the icon of the spell being cast"],
								order = 110,
							},
							iconside = {
								type = "select",
								name = L["Spell Icon Position"],
								desc = L["Set the side of the bar that the icon appears on"],
								values = {["left"] = L["Left"], ["right"] = L["Right"]},
								order = 111,
							},
							nl4b = {
								type = "description",
								name = "",
								order = 111.1,
							},
							raidicons = {
								type = "toggle",
								name = L["Raid Marker"],
								desc = L["Show raid target markers on the cast bars"],
								order = 111.5,
							},
							raidiconside = {
								type = "select",
								name = L["Raid Marker Position"],
								desc = L["Set the side of the bar that the raid icon appears on"],
								values = {["left"] = L["Left"], ["right"] = L["Right"]},
								order = 111.6,
							},
							nl4c = {
								type = "description",
								name = "",
								order = 111.7,
							},
							texture = {
								type = "select",
								dialogControl = "LSM30_Statusbar",
								name = L["Texture"],
								desc = L["Set the bar Texture"],
								values = lsmlist.statusbar,
								order = 112,
							},
							barcolor = {
								type = "color",
								name = L["Bar Color"],
								desc = L["Set the color of the bars"],
								get = getColor,
								set = setColor,
								order = 113,
							},
							noInterruptColor = {
								type = "color",
								name = L["Uninterruptible Color"],
								desc = L["Set the color of the bars for uninterruptible casts"],
								get = getColor,
								set = setColor,
								order = 114,
							},
							nl5 = {
								type = "description",
								name = "",
								order = 115,
							},
							width = {
								type = "range",
								name = L["Bar Width"],
								desc = L["Set the width of the bars"],
								min = 50, max = 300, step = 1,
								order = 116,
							},
							height = {
								type = "range",
								name = L["Bar Height"],
								desc = L["Set the height of the bars"],
								min = 4, max = 25, step = 1,
								order = 116,
							},
							alpha = {
								type = "range",
								name = L["Alpha"],
								desc = L["Set the alpha of the bars"],
								min = 0.05, max = 1, bigStep = 0.05,
								isPercent = true,
								order = 117,
							},
							nl6 = {
								type = "description",
								name = "",
								order = 119,
							},
							nametext = {
								type = "toggle",
								name = L["Spell Name"],
								desc = L["Display the name of the spell on the bars"],
								order = 120,
							},
							timetext = {
								type = "toggle",
								name = L["Remaining Time"],
								desc = L["Display the time remaining on the bars"],
								order = 121,
							},
							font = {
								type = "select",
								dialogControl = "LSM30_Font",
								name = L["Font"],
								desc = L["Set the font used in the bars"],
								values = lsmlist.font,
								order = 122,
							},
							fontsize = {
								type = "range",
								name = L["Font Size"],
								desc = L["Set the font size for the bars"],
								min = 3, max = 15, step = 1,
								order = 123,
							},
							fontOutline = {
								type = "select",
								name = L["Font Outline"],
								desc = L["Font Outline"],
								values = {["SHADOW"] = L["Shadow"], [""] = L["None"], ["OUTLINE"] = L["Outline"], ["THICKOUTLINE"] = L["Thick Outline"]},
								order = 124,
							},
							fontShadowColor = {
								type = "color",
								name = L["Shadow Color"],
								desc = L["Shadow Color"],
								hasAlpha = true,
								get = getColor,
								set = setColor,
								disabled = function() return db.fontOutline ~= "SHADOW" end,
								order = 125,
							},
							fontShadowOffsetX = {
								type = "range",
								name = L["Shadow X Offset"],
								desc = L["Shadow X Offset"],
								min = -5, max = 5, step = 0.1,
								disabled = function() return db.fontOutline ~= "SHADOW" end,
								order = 126,
							},
							fontShadowOffsetY = {
								type = "range",
								name = L["Shadow Y Offset"],
								desc = L["Shadow Y Offset"],
								min = -5, max = 5, step = 0.1,
								disabled = function() return db.fontOutline ~= "SHADOW" end,
								order = 127,
							},
							textcolor = {
								type = "color",
								name = L["Text Color"],
								desc = L["Set the color of the text for the bars"],
								get = getColor,
								set = setColor,
								order = 128,
							},
						}
					},
				},
			}
		end
		return options
	end
end
