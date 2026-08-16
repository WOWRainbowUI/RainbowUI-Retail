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

local MODNAME = "Buff"
local Buff = Quartz3:NewModule(MODNAME, "AceEvent-3.0")
local Player = Quartz3:GetModule("Player")
local Focus = Quartz3:GetModule("Focus", true)
local Target = Quartz3:GetModule("Target", true)

local ApplyFontStyle = Quartz3.Util.ApplyFontStyle

local media = LibStub("LibSharedMedia-3.0")
local lsmlist = AceGUIWidgetLSMlists

----------------------------
-- Upvalues
-- GLOBALS: AuraContainerSortMethod AuraContainerSortDirection AnchorUtil Enum CreateColor
-- GLOBALS: UnitCanAssist UnitCanAttack UnitIsFriend UnitIsEnemy issecretvalue
-- GLOBALS: UnitIsConnected UnitPhaseReason UnitIsVisible
local CreateFrame, UIParent = CreateFrame, UIParent
local unpack, pairs, ipairs, pcall = unpack, pairs, ipairs, pcall

-- The AuraContainer widget family only exists on retail clients, the module stays dormant on older ones.
local hasAuraContainers = (AuraContainerSortMethod ~= nil)

-- Matches CustomAuraContainerConstants.FrameCreationBatchSize so a group's buttons are created in one batch on first use.
local MAX_AURAS = 10

local lockstate = { target = true, focus = true, player = true }

local db

local containers = {} -- unit token -> AuraContainer
local movers = {}     -- unit token -> drag handle used by the free anchor
local buttons = {}    -- registry of dressed AuraButtons, for restyling on ApplySettings
local appliedFilters = {} -- unit token -> group key -> last applied filter token

local UNIT_LIST = { "target", "focus", "player" }

local defaults = {
	profile = {
		target = true,
		targeticons = true,
		targeticonside = "right",

		targetanchor = "player",--L["Free"], L["Target"], L["Focus"]
		targetgrowdirection = "up", --L["Down"]
		targetposition = "topright",

		targetgap = 1,
		targetspacing = 1,
		targetoffset = 3,

		targetwidth = 120,
		targetheight = 12,

		focus = true,
		focusicons = true,
		focusiconside = "left",

		focusanchor = "player",--L["Free"], L["Target"], L["Focus"]
		focusgrowdirection = "up", --L["Down"]
		focusposition = "bottomleft",

		focusgap = 15,
		focusspacing = 1,
		focusoffset = 3,

		focuswidth = 120,
		focusheight = 12,

		player = true,
		playericons = true,
		playericonside = "left",

		playeranchor = "player",--L["Free"], L["Target"], L["Focus"]
		playergrowdirection = "up", --L["Down"]
		playerposition = "topleft",

		playergap = 1,
		playerspacing = 1,
		playeroffset = 3,

		playerwidth = 120,
		playerheight = 12,

		buffnametext = true,
		bufftimetext = true,

		bufftexture = "LiteStep",
		bufffont = "Friz Quadrata TT",
		bufffontsize = 9,
		bufffontOutline = "SHADOW",
		bufffontShadowColor = {0, 0, 0, 1},
		bufffontShadowOffsetX = 0.8,
		bufffontShadowOffsetY = -0.8,
		buffalpha = 1,

		pandemic = true,
		pandemiccolor = {1, 1, 1, 0.5},

		buffcolor = {0,0.49, 1},
		stealcolor = {1, 1, 1},

		debuffsbytype = true,
		debuffcolor = {1.0, 0.7, 0},
		Poison = {0, 1, 0},
		Magic = {0, 0, 1},
		Disease = {.55, .15, 0},
		Curse = {1, 0, 1},

		bufftextcolor = {1,1,1},

		timesort = true,
	}
}

----------------------------
-- AuraButton dressing
--
-- The container creates the buttons and their Forbidden Aspects block addon script handlers, so every dynamic element goes through the native Set* bindings.

local styleButton

local function initButton(button, unit, isBuff, gen)
	local entry = { button = button, unit = unit, isBuff = isBuff, gen = gen }

	-- Historical click-through, pcall'd because the calls are input-restricted on some builds.
	pcall(button.SetMouseMotionEnabled, button, false)
	pcall(button.SetMouseClickEnabled, button, false)

	local bar = CreateFrame("StatusBar", nil, button)
	bar:SetMinMaxValues(0, 1)
	bar:SetReverseFill(true)
	entry.bar = bar

	-- Inverse fill: a black statusbar mask grows over the colored LSM background as the aura elapses.
	entry.bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	entry.bg:SetAllPoints(bar)
	entry.dispel = bar:CreateTexture(nil, "BACKGROUND", nil, 1)
	entry.dispel:SetAllPoints(bar)
	entry.steal = bar:CreateTexture(nil, "BACKGROUND", nil, 2)
	entry.steal:SetAllPoints(bar)

	entry.icon = button:CreateTexture(nil, "ARTWORK")
	entry.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

	entry.name = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	entry.time = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	entry.stacks = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")

	-- No addon OnUpdate runs on button children, so the pandemic pulse is a native looping animation.
	entry.pandemic = bar:CreateTexture(nil, "OVERLAY")
	entry.pandemic:SetAllPoints(bar)
	entry.pandemic:SetTexture("Interface\\BUTTONS\\WHITE8X8")
	local pulseGroup = entry.pandemic:CreateAnimationGroup()
	pulseGroup:SetLooping("BOUNCE")
	entry.pulse = pulseGroup:CreateAnimation("Alpha")
	entry.pulse:SetFromAlpha(0)
	entry.pulse:SetDuration(0.5)
	pulseGroup:Play()

	button:SetDurationBar(bar, { interpolation = Enum.StatusBarInterpolation.Immediate, direction = Enum.StatusBarTimerDirection.ElapsedTime })
	button:SetApplicationCount(entry.stacks, {})

	buttons[#buttons + 1] = entry
	styleButton(entry)
end

function styleButton(entry)
	local unit, button, bar = entry.unit, entry.button, entry.bar
	local width = db[unit .. "width"]
	local height = db[unit .. "height"]
	local icons = db[unit .. "icons"]
	local iconside = db[unit .. "iconside"]

	local totalWidth = width + (icons and (height + 1) or 0)
	button:SetSize(totalWidth, height)

	bar:ClearAllPoints()
	if icons and iconside == "left" then
		bar:SetPoint("TOPLEFT", button, "TOPLEFT", height + 1, 0)
		bar:SetPoint("BOTTOMRIGHT", button)
	elseif icons then
		bar:SetPoint("TOPLEFT", button)
		bar:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -(height + 1), 0)
	else
		bar:SetAllPoints(button)
	end

	bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
	bar:GetStatusBarTexture():SetVertexColor(0, 0, 0, 1)

	local tex = media:Fetch("statusbar", db.bufftexture)
	entry.bg:SetTexture(tex)
	entry.dispel:SetTexture(tex)
	entry.steal:SetTexture(tex)
	if entry.isBuff then
		entry.bg:SetVertexColor(unpack(db.buffcolor))
	else
		entry.bg:SetVertexColor(unpack(db.debuffcolor))
	end

	-- The overlays only show natively for stealable buffs / dispellable debuffs, everything else falls through to the bg.
	button:ClearDispelTypeTextures()
	entry.dispel:Hide()
	entry.steal:Hide()
	if entry.isBuff then
		local stealColor = CreateColor(unpack(db.stealcolor))
		button:AddDispelTypeTexture(entry.steal, {
			showWhenHelpful = true,
			showWhenHarmful = false,
			showWithoutDispelType = true,
			stealableFilter = Enum.CustomAuraButtonDispelTypeStealableFilter.Stealable,
			style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
			customDispelColorMap = {
				None = stealColor,
				Magic = stealColor,
				Curse = stealColor,
				Disease = stealColor,
				Poison = stealColor,
				Enrage = stealColor,
			},
		})
	elseif db.debuffsbytype then
		button:AddDispelTypeTexture(entry.dispel, {
			showWhenHarmful = true,
			showWhenHelpful = false,
			style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset,
			customDispelColorMap = {
				Magic = CreateColor(unpack(db.Magic)),
				Curse = CreateColor(unpack(db.Curse)),
				Disease = CreateColor(unpack(db.Disease)),
				Poison = CreateColor(unpack(db.Poison)),
			},
		})
	end

	local pr, pg, pb, pa = unpack(db.pandemiccolor)
	entry.pandemic:SetVertexColor(pr, pg, pb)
	entry.pulse:SetToAlpha(pa or 0.5)
	button:ClearPandemicRegions()
	if db.pandemic then
		button:AddPandemicRegion(entry.pandemic)
	else
		entry.pandemic:Hide()
	end

	local font = media:Fetch("font", db.bufffont)
	for _, fontString in ipairs({ entry.name, entry.time, entry.stacks }) do
		ApplyFontStyle(fontString, font, db.bufffontsize, db.bufffontOutline, db.bufffontShadowColor, db.bufffontShadowOffsetX, db.bufffontShadowOffsetY)
		fontString:SetTextColor(unpack(db.bufftextcolor))
	end

	local timerWidth = db.bufftimetext and 30 or 0

	entry.name:ClearAllPoints()
	entry.name:SetPoint("LEFT", bar, "LEFT", 2, 0)
	entry.name:SetJustifyH("LEFT")
	entry.name:SetNonSpaceWrap(false)
	entry.name:SetHeight(height)
	entry.name:SetWidth(width - timerWidth)
	if db.buffnametext then
		button:SetSpellName(entry.name)
		entry.name:Show()
	else
		button:ClearSpellName()
		entry.name:Hide()
	end

	entry.time:ClearAllPoints()
	entry.time:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
	entry.time:SetJustifyH("RIGHT")
	if db.bufftimetext then
		button:SetDurationText(entry.time, {})
		entry.time:Show()
	else
		button:ClearDurationText()
		entry.time:Hide()
	end

	entry.stacks:ClearAllPoints()
	if icons then
		entry.stacks:SetPoint("BOTTOMRIGHT", entry.icon, "BOTTOMRIGHT", 1, 0)
	else
		entry.stacks:SetPoint("RIGHT", bar, "RIGHT", -(timerWidth + 2), 0)
	end
	entry.stacks:SetJustifyH("RIGHT")

	entry.icon:ClearAllPoints()
	if icons then
		entry.icon:SetSize(height - 1, height - 1)
		if iconside == "left" then
			entry.icon:SetPoint("LEFT", button, "LEFT", 0, 0)
		else
			entry.icon:SetPoint("RIGHT", button, "RIGHT", 0, 0)
		end
		button:SetIcon(entry.icon)
		entry.icon:Show()
	else
		button:ClearIcon()
		entry.icon:Hide()
	end
end

----------------------------
-- Containers and movers

local PLACEHOLDER_BUFFS, PLACEHOLDER_DEBUFFS = 3, 2

-- Center-relative free coordinates, kept out of the defaults so stored legacy bottom-left values can be migrated once.
local FREE_DEFAULTS = {
	targetx = 200, targety = 0,
	focusx = -200, focusy = 0,
	playerx = 0, playery = -150,
}

local function freeCoord(key)
	local value = db[key]
	if value == nil then
		value = FREE_DEFAULTS[key]
	end
	return value
end

local POSITION_GROWS_UP = { top = true, topright = true, topleft = true, leftup = true, rightup = true }

local function unitGrowUp(unit)
	if db[unit .. "anchor"] == "free" then
		return db[unit .. "growdirection"] == "up"
	end
	return POSITION_GROWS_UP[db[unit .. "position"]] or false
end

-- The mover is a box of placeholder bars, real AuraButtons are access-restricted and cannot be dragged.
local function ensureMover(unit)
	local mover = movers[unit]
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
	for i = 1, PLACEHOLDER_BUFFS + PLACEHOLDER_DEBUFFS do
		local row = CreateFrame("StatusBar", nil, mover)
		row:SetMinMaxValues(0, 1)
		row:SetReverseFill(true)
		row.bg = row:CreateTexture(nil, "BACKGROUND")
		row.bg:SetAllPoints(row)
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
		db[unit .. "x"] = frame:GetLeft() - cx
		if db[unit .. "growdirection"] == "up" then
			db[unit .. "y"] = frame:GetBottom() - cy
		else
			db[unit .. "y"] = frame:GetTop() - cy - db[unit .. "height"]
		end
		Buff:ApplySettings()
	end)

	movers[unit] = mover
	return mover
end

local function positionMover(unit)
	local mover = movers[unit]
	if not mover then return end

	local width = db[unit .. "width"]
	local height = db[unit .. "height"]
	local icons = db[unit .. "icons"]
	local iconside = db[unit .. "iconside"]
	local spacing = db[unit .. "spacing"]
	local growUp = unitGrowUp(unit)
	local rows = #mover.rows
	local totalWidth = width + (icons and (height + 1) or 0)
	local unitLabel = unit == "target" and L["Target"] or unit == "focus" and L["Focus"] or L["Player"]

	mover:SetScale(Player.db.profile.scale)
	mover:SetSize(totalWidth, rows * height + (rows - 1) * spacing)
	mover:ClearAllPoints()
	if db[unit .. "anchor"] == "free" then
		local x = freeCoord(unit .. "x")
		local y = freeCoord(unit .. "y")
		if growUp then
			mover:SetPoint("BOTTOMLEFT", UIParent, "CENTER", x, y)
		else
			mover:SetPoint("TOPLEFT", UIParent, "CENTER", x, y + height)
		end
	else
		local qpdb = Player.db.profile
		local anchor = db[unit .. "anchor"]
		local position = db[unit .. "position"]
		local gap = db[unit .. "gap"]
		local offset = db[unit .. "offset"]
		local anchorframe
		if anchor == "focus" and Focus and Focus.Bar then
			anchorframe = Focus.Bar
		elseif anchor == "target" and Target and Target.Bar then
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
			if qpdb.iconposition == "left" and not qpdb.hideicon then
				offset = offset + qpdb.h
			end
			mover:SetPoint("BOTTOMRIGHT", anchorframe, "BOTTOMLEFT", -1 * offset, gap)
		elseif position == "leftdown" then
			if qpdb.iconposition == "left" and not qpdb.hideicon then
				offset = offset + qpdb.h
			end
			mover:SetPoint("TOPRIGHT", anchorframe, "TOPLEFT", -3 * offset, -1 * gap)
		elseif position == "rightup" then
			if qpdb.iconposition == "right" and not qpdb.hideicon then
				offset = offset + qpdb.h
			end
			mover:SetPoint("BOTTOMLEFT", anchorframe, "BOTTOMRIGHT", offset, gap)
		elseif position == "rightdown" then
			if qpdb.iconposition == "right" and not qpdb.hideicon then
				offset = offset + qpdb.h
			end
			mover:SetPoint("TOPLEFT", anchorframe, "TOPRIGHT", offset, -1 * gap)
		end
	end
	local tex = media:Fetch("statusbar", db.bufftexture)
	local font = media:Fetch("font", db.bufffont)
	local barX = (icons and iconside == "left") and (height + 1) or 0
	for i, row in ipairs(mover.rows) do
		row:SetSize(width, height)
		row:ClearAllPoints()
		local offset = (i - 1) * (height + spacing)
		if growUp then
			row:SetPoint("BOTTOMLEFT", mover, "BOTTOMLEFT", barX, offset)
		else
			row:SetPoint("TOPLEFT", mover, "TOPLEFT", barX, -offset)
		end
		row:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		row:GetStatusBarTexture():SetVertexColor(0, 0, 0, 1)
		row:SetValue(i / (rows + 1))
		row.bg:SetTexture(tex)
		if i <= PLACEHOLDER_BUFFS then
			row.bg:SetVertexColor(unpack(db.buffcolor))
		elseif db.debuffsbytype and i == PLACEHOLDER_BUFFS + 1 then
			row.bg:SetVertexColor(unpack(db.Magic))
		else
			row.bg:SetVertexColor(unpack(db.debuffcolor))
		end
		if icons then
			row.icon:SetSize(height - 1, height - 1)
			row.icon:SetTexture("Interface\\Icons\\Temp")
			row.icon:ClearAllPoints()
			if iconside == "left" then
				row.icon:SetPoint("RIGHT", row, "LEFT", -1, 0)
			else
				row.icon:SetPoint("LEFT", row, "RIGHT", 1, 0)
			end
			row.icon:Show()
		else
			row.icon:Hide()
		end
		for _, fontString in ipairs({ row.name, row.time }) do
			ApplyFontStyle(fontString, font, db.bufffontsize, db.bufffontOutline, db.bufffontShadowColor, db.bufffontShadowOffsetX, db.bufffontShadowOffsetY)
			fontString:SetTextColor(unpack(db.bufftextcolor))
		end
		row.name:ClearAllPoints()
		row.name:SetPoint("LEFT", row, "LEFT", 2, 0)
		row.name:SetJustifyH("LEFT")
		local topIndex = growUp and rows or 1
		row.name:SetText(i == topIndex and (L["Buff"] .. ": " .. unitLabel) or unitLabel)
		row.name:SetShown(db.buffnametext)
		row.time:ClearAllPoints()
		row.time:SetPoint("RIGHT", row, "RIGHT", -2, 0)
		row.time:SetJustifyH("RIGHT")
		row.time:SetText("12.3")
		row.time:SetShown(db.bufftimetext)
	end
end

function Buff:SetMoverLocked(unit, locked)
	local mover = movers[unit]
	if not mover then return end
	lockstate[unit] = locked
	mover:EnableMouse(not locked and db[unit .. "anchor"] == "free")
	mover:SetShown((not locked and db[unit] and self:IsEnabled()) and true or false)
	local container = containers[unit]
	if container then
		container:SetShown((db[unit] and locked and self:IsEnabled()) and true or false)
	end
end

function Buff:Unlock()
	for unit in pairs(movers) do
		self:SetMoverLocked(unit, false)
	end
end

function Buff:Lock()
	for unit in pairs(movers) do
		self:SetMoverLocked(unit, true)
	end
end

local function sectionsFor(unit)
	local AF = Quartz3:GetModule("AuraFilters", true)
	if AF then
		return AF:GetUnitSections(unit), AF:GetRevision()
	end
	return {
		{ key = "MINE_HELPFUL", filterString = "HELPFUL|PLAYER", isHelpful = true },
		{ key = "MINE_HARMFUL", filterString = "HARMFUL|PLAYER", isHelpful = false },
	}, 0
end

-- Groups can neither be removed nor change polarity, so a polarity-sequence change requires a new container.
local function structuralSignature(sections)
	local signature = {}
	for i, section in ipairs(sections) do
		signature[i] = section.isHelpful and "h" or "d"
	end
	return table.concat(signature)
end

-- The reaction APIs can return secret booleans on restricted maps, hence the fallbacks.
local function unitReaction(unit)
	if unit == "player" then return "assist" end
	local ok, value = pcall(UnitCanAssist, "player", unit)
	if ok and not issecretvalue(value) then
		if value then return "assist" end
		local okAttack, attack = pcall(UnitCanAttack, "player", unit)
		if okAttack and not issecretvalue(attack) then
			return attack and "attack" or "none"
		end
	end
	local okFriend, friend = pcall(UnitIsFriend, unit, "player")
	local okEnemy, enemy = pcall(UnitIsEnemy, unit, "player")
	local isEnemy = okEnemy and enemy and true or false
	if okFriend and friend and not isEnemy then
		return "assist"
	end
	return isEnemy and "attack" or "none"
end

-- The identity gate ignores spell-ID filters for helpful auras on non-assistable units and harmful ones on assistable units, custom sections are muted there.
local function sectionMuted(section, state)
	if not section.custom then return false end
	if section.isHelpful then
		return state ~= "assist"
	end
	return state == "assist"
end

-- Out of AOI the identity gate drops every spell-ID filter, so sections lose their whitelists and show duplicates.
local function unitReachable(unit)
	if unit == "player" then return true end
	local okConnected, connected = pcall(UnitIsConnected, unit)
	if okConnected and not issecretvalue(connected) and not connected then
		return false
	end
	local okPhase, phase = pcall(UnitPhaseReason, unit)
	if okPhase and not issecretvalue(phase) and phase ~= nil then
		return false
	end
	local okVisible, visible = pcall(UnitIsVisible, unit)
	if okVisible and not issecretvalue(visible) and not visible then
		return false
	end
	return true
end

local reaction = {}
local reachable = {}
local generation = {}

local function createContainer(unit, sections)
	local container = CreateFrame("AuraContainer", nil, UIParent, "CustomAuraContainerTemplate")
	container:SetFrameStrata("MEDIUM")
	container:SetUnit(unit)

	generation[unit] = (generation[unit] or 0) + 1
	local gen = generation[unit]
	local sortMethod = db.timesort and AuraContainerSortMethod.ExpirationOnly or AuraContainerSortMethod.NameOnly
	-- maxDuration hides permanent auras, matching the old "duration > 0" rule.
	for i, section in ipairs(sections) do
		local isHelpful = section.isHelpful
		pcall(container.AddAuraGroup, container, "section" .. i, section.filterString, {
			maxFrameCount = MAX_AURAS,
			initializeFrame = function(button) initButton(button, unit, isHelpful, gen) end,
			candidateFilters = { maxDuration = math.huge },
			sortMethod = sortMethod,
		})
	end
	container.structural = structuralSignature(sections)

	containers[unit] = container
	return container
end

local function configureContainer(unit)
	local sections, revision = sectionsFor(unit)
	local structural = structuralSignature(sections)
	local container = containers[unit]

	if container and container.structural ~= structural then
		container:SetEnabled(false)
		container:Hide()
		containers[unit] = nil
		appliedFilters[unit] = nil
		container = nil
	end
	if not container then
		container = createContainer(unit, sections)
	end
	container.sections = sections

	local enabled = db[unit] and true or false
	reachable[unit] = unitReachable(unit)
	container:SetEnabled((enabled and reachable[unit]) and true or false)
	container:SetShown((enabled and lockstate[unit]) and true or false)
	if not enabled then return end

	local spacing = db[unit .. "spacing"]

	container:SetScale(Player.db.profile.scale)
	container:SetAlpha(db.buffalpha)

	local sortMethod = db.timesort and AuraContainerSortMethod.ExpirationOnly or AuraContainerSortMethod.NameOnly
	local state = unitReaction(unit)
	reaction[unit] = state

	-- SetAuraGroupCandidateFilters triggers a full aura rebuild on every call, so it is only re-applied on change.
	local applied = appliedFilters[unit]
	if not applied then
		applied = {}
		appliedFilters[unit] = applied
	end

	-- Vertical axis: one column of groups separated by groupSpacing (forceNewLine would start a side column).
	container:SetFlowLayoutAxis(AnchorUtil.FlowLayoutAxis.Vertical)

	for i, section in ipairs(sections) do
		local key = "section" .. i
		pcall(container.SetAuraGroupFilterString, container, key, section.filterString)
		pcall(container.SetAuraGroupSortMethod, container, key, sortMethod, AuraContainerSortDirection.Normal)
		pcall(container.SetAuraGroupMaxFrameCount, container, key, sectionMuted(section, state) and 0 or MAX_AURAS)
		pcall(container.SetAuraGroupLayout, container, key, { elementSpacing = spacing, groupSpacing = section.glued and 0 or spacing })
		local token = revision .. "#" .. section.key .. "#" .. tostring(section.glued)
		if applied[key] ~= token then
			applied[key] = token
			pcall(container.SetAuraGroupCandidateFilters, container, key, {
				maxDuration = math.huge,
				includeSpellIDs = section.include,
				excludeSpellIDs = section.exclude,
			})
		end
	end

	local growUp = unitGrowUp(unit)
	local point = growUp and "BOTTOMLEFT" or "TOPLEFT"
	container:ClearAllPoints()
	container:SetPoint(point, movers[unit], point)

	container:SetFlowLayoutAnchorPoint(point)
	container:SetFlowLayoutGrowthDirection(AnchorUtil.FlowDirection.Right, growUp and AnchorUtil.FlowDirection.Up or AnchorUtil.FlowDirection.Down)
end

----------------------------
-- Options

local getOptions
do
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

	local function hidedebuffsbytype()
		return not db.debuffsbytype
	end

	local function gettargetfreeoptionshidden()
		return db.targetanchor ~= "free"
	end

	local function gettargetnotfreeoptionshidden()
		return db.targetanchor == "free"
	end

	local function getfocusfreeoptionshidden()
		return db.focusanchor ~= "free"
	end

	local function getfocusnotfreeoptionshidden()
		return db.focusanchor == "free"
	end

	local function setOpt(info, value)
		db[info.arg or info[#info]] = value
		Buff:ApplySettings()
	end

	local function getOpt(info)
		return db[info.arg or info[#info]]
	end

	local function setOptFocus(info, value)
		db[info.arg or ("focus"..info[#info])] = value
		Buff:ApplySettings()
	end

	local function getOptFocus(info)
		return db[info.arg or ("focus"..info[#info])]
	end

	local function setOptTarget(info, value)
		db[info.arg or ("target"..info[#info])] = value
		Buff:ApplySettings()
	end

	local function getOptTarget(info)
		return db[info.arg or ("target"..info[#info])]
	end

	local function setOptPlayer(info, value)
		db[info.arg or ("player"..info[#info])] = value
		Buff:ApplySettings()
	end

	local function getOptPlayer(info)
		return db[info.arg or ("player"..info[#info])]
	end

	local function getplayerfreeoptionshidden()
		return db.playeranchor ~= "free"
	end

	local function getplayernotfreeoptionshidden()
		return db.playeranchor == "free"
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
				name = L["Buff"],
				order = 590,
				get = getOpt,
				set = setOpt,
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
						order = 100,
					},
					filtersnote = {
						type = "description",
						name = L["Which auras are displayed on each unit is configured in the Aura Filters module."],
						order = 100.5,
					},
					focus = {
						type = "group",
						name = L["Focus"],
						desc = L["Focus"],
						order = 101,
						get = getOptFocus,
						set = setOptFocus,
						args = {
							show = {
								type = "toggle",
								name = L["Enable %s"]:format(L["Focus"]),
								desc = L["Show buffs/debuffs for your %s"]:format(L["Focus"]),
								arg = "focus",
								order = 90,
								width = "full",
								disabled = false,
							},
							nlf = {
								type = "description",
								name = "",
								order = 100,
							},
							width = {
								type = "range",
								name = L["Buff Bar Width"],
								desc = L["Set the width of the buff bars"],
								min = 50, max = 300, step = 1,
								order = 101,
							},
							height = {
								type = "range",
								name = L["Buff Bar Height"],
								desc = L["Set the height of the buff bars"],
								min = 4, max = 25, step = 1,
								order = 101,
							},
							anchor = {
								type = "select",
								name = L["Anchor Frame"],
								desc = L["Select where to anchor the %s bars"]:format(L["Focus"]),
								values = {["player"] = L["Player"], ["free"] = L["Free"], ["target"] = L["Target"], ["focus"] = L["Focus"]},
								order = 102,
							},
							-- free
							focuslock = {
								type = "toggle",
								name = L["Lock"],
								desc = L["Toggle %s bar lock"]:format(L["Focus"]),
								get = function()
									return lockstate.focus
								end,
								set = function(info, v)
									Buff:SetMoverLocked("focus", v)
								end,
								hidden = getfocusfreeoptionshidden,
								order = 103,
							},
							x = {
								type = "range",
								name = L["X"],
								desc = L["Set an exact X value for this bar's position."],
								min = -2560, max = 2560, step = 1,
								get = function() return freeCoord("focusx") end,
								hidden = getfocusfreeoptionshidden,
								order = 104,
							},
							y = {
								type = "range",
								name = L["Y"],
								desc = L["Set an exact Y value for this bar's position."],
								min = -1600, max = 1600, step = 1,
								get = function() return freeCoord("focusy") end,
								hidden = getfocusfreeoptionshidden,
								order = 104,
							},
							growdirection = {
								type = "select",
								name = L["Grow Direction"],
								desc = L["Set the grow direction of the %s bars"]:format(L["Focus"]),
								values = {["up"] = L["Up"], ["down"] = L["Down"]},
								hidden = getfocusfreeoptionshidden,
								order = 105,
							},
							-- anchored to a cast bar
							position = {
								type = "select",
								name = L["Position"],
								desc = L["Position the bars for your %s"]:format(L["Focus"]),
								values = positions,
								hidden = getfocusnotfreeoptionshidden,
								order = 103,
							},
							gap = {
								type = "range",
								name = L["Gap"],
								desc = L["Tweak the vertical position of the bars for your %s"]:format(L["Focus"]),
								min = -35, max = 35, step = 1,
								hidden = getfocusnotfreeoptionshidden,
								order = 104,
							},
							offset = {
								type = "range",
								name = L["Offset"],
								desc = L["Tweak the horizontal position of the bars for your %s"]:format(L["Focus"]),
								min = -35, max = 35,step = 1,
								hidden = getfocusnotfreeoptionshidden,
								order = 106,
							},
							spacing = {
								type = "range",
								name = L["Spacing"],
								desc = L["Tweak the space between bars for your %s"]:format(L["Focus"]),
								min = -35, max = 35, step = 1,
								order = 107,
							},
							nli = {
								type = "description",
								name = "",
								order = 108,
							},
							icons = {
								type = "toggle",
								name = L["Show Icons"],
								desc = L["Show icons on buffs and debuffs for your %s"]:format(L["Focus"]),
								order = 109,
							},
							iconside = {
								type = "select",
								name = L["Icon Position"],
								desc = L["Set the side of the buff bar that the icon appears on"],
								values = {["left"] = L["Left"], ["right"] = L["Right"]},
								order = 110,
							},
						},
					},
					target = {
						type = "group",
						name = L["Target"],
						desc = L["Target"],
						order = 102,
						get = getOptTarget,
						set = setOptTarget,
						args = {
							show = {
								type = "toggle",
								name = L["Enable %s"]:format(L["Target"]),
								desc = L["Show buffs/debuffs for your %s"]:format(L["Target"]),
								arg = "target",
								disabled = false,
								width = "full",
								order = 90,
							},
							nlf = {
								type = "description",
								name = "",
								order = 100,
							},
							width = {
								type = "range",
								name = L["Buff Bar Width"],
								desc = L["Set the width of the buff bars"],
								min = 50, max = 300, step = 1,
								order = 101,
							},
							height = {
								type = "range",
								name = L["Buff Bar Height"],
								desc = L["Set the height of the buff bars"],
								min = 4, max = 25, step = 1,
								order = 101,
							},
							anchor = {
								type = "select",
								name = L["Anchor Frame"],
								desc = L["Select where to anchor the %s bars"]:format(L["Target"]),
								values = {["player"] = L["Player"], ["free"] = L["Free"], ["target"] = L["Target"], ["focus"] = L["Focus"]},
								order = 102,
							},
							-- free
							targetlock = {
								type = "toggle",
								name = L["Lock"],
								desc = L["Toggle %s bar lock"]:format(L["Target"]),
								get = function()
									return lockstate.target
								end,
								set = function(info, v)
									Buff:SetMoverLocked("target", v)
								end,
								hidden = gettargetfreeoptionshidden,
								order = 103,
							},
							x = {
								type = "range",
								name = L["X"],
								desc = L["Set an exact X value for this bar's position."],
								min = -2560, max = 2560, bigStep = 1,
								get = function() return freeCoord("targetx") end,
								hidden = gettargetfreeoptionshidden,
								order = 104,
							},
							y = {
								type = "range",
								name = L["Y"],
								desc = L["Set an exact Y value for this bar's position."],
								min = -1600, max = 1600, bigStep = 1,
								get = function() return freeCoord("targety") end,
								hidden = gettargetfreeoptionshidden,
								order = 104,
							},
							growdirection = {
								type = "select",
								name = L["Grow Direction"],
								desc = L["Set the grow direction of the %s bars"]:format(L["Target"]),
								values = {["up"] = L["Up"], ["down"] = L["Down"]},
								hidden =  gettargetfreeoptionshidden,
								order = 105,
							},
							-- anchored to a cast bar
							position = {
								type = "select",
								name = L["Position"],
								desc = L["Position the bars for your %s"]:format(L["Target"]),
								values = positions,
								hidden = gettargetnotfreeoptionshidden,
								order = 103,
							},
							gap = {
								type = "range",
								name = L["Gap"],
								desc = L["Tweak the vertical position of the bars for your %s"]:format(L["Target"]),
								min = -35, max = 35, step = 1,
								hidden = gettargetnotfreeoptionshidden,
								order = 104,
							},
							offset = {
								type = "range",
								name = L["Offset"],
								desc = L["Tweak the horizontal position of the bars for your %s"]:format(L["Target"]),
								min = -35, max = 35, step = 1,
								hidden = gettargetnotfreeoptionshidden,
								order = 106,
							},
							spacing = {
								type = "range",
								name = L["Spacing"],
								desc = L["Tweak the space between bars for your %s"]:format(L["Target"]),
								min = -35, max = 35, step = 1,
								order = 107,
							},
							nli = {
								type = "description",
								name = "",
								order = 108,
							},
							icons = {
								type = "toggle",
								name = L["Show Icons"],
								desc = L["Show icons on buffs and debuffs for your %s"]:format(L["Target"]),
								order = 109,
							},
							iconside = {
								type = "select",
								name = L["Icon Position"],
								desc = L["Set the side of the buff bar that the icon appears on"],
								values = {["left"] = L["Left"], ["right"] = L["Right"]},
								order = 110,
							},
						},
					},
					player = {
						type = "group",
						name = L["Player"],
						desc = L["Player"],
						order = 103,
						get = getOptPlayer,
						set = setOptPlayer,
						args = {
							show = {
								type = "toggle",
								name = L["Enable %s"]:format(L["Player"]),
								desc = L["Show buffs/debuffs for your %s"]:format(L["Player"]),
								arg = "player",
								disabled = false,
								width = "full",
								order = 90,
							},
							nlf = {
								type = "description",
								name = "",
								order = 100,
							},
							width = {
								type = "range",
								name = L["Buff Bar Width"],
								desc = L["Set the width of the buff bars"],
								min = 50, max = 300, step = 1,
								order = 101,
							},
							height = {
								type = "range",
								name = L["Buff Bar Height"],
								desc = L["Set the height of the buff bars"],
								min = 4, max = 25, step = 1,
								order = 101,
							},
							anchor = {
								type = "select",
								name = L["Anchor Frame"],
								desc = L["Select where to anchor the %s bars"]:format(L["Player"]),
								values = {["player"] = L["Player"], ["free"] = L["Free"], ["target"] = L["Target"], ["focus"] = L["Focus"]},
								order = 102,
							},
							-- free
							playerlock = {
								type = "toggle",
								name = L["Lock"],
								desc = L["Toggle %s bar lock"]:format(L["Player"]),
								get = function()
									return lockstate.player
								end,
								set = function(info, v)
									Buff:SetMoverLocked("player", v)
								end,
								hidden = getplayerfreeoptionshidden,
								order = 103,
							},
							x = {
								type = "range",
								name = L["X"],
								desc = L["Set an exact X value for this bar's position."],
								min = -2560, max = 2560, bigStep = 1,
								get = function() return freeCoord("playerx") end,
								hidden = getplayerfreeoptionshidden,
								order = 104,
							},
							y = {
								type = "range",
								name = L["Y"],
								desc = L["Set an exact Y value for this bar's position."],
								min = -1600, max = 1600, bigStep = 1,
								get = function() return freeCoord("playery") end,
								hidden = getplayerfreeoptionshidden,
								order = 104,
							},
							growdirection = {
								type = "select",
								name = L["Grow Direction"],
								desc = L["Set the grow direction of the %s bars"]:format(L["Player"]),
								values = {["up"] = L["Up"], ["down"] = L["Down"]},
								hidden = getplayerfreeoptionshidden,
								order = 105,
							},
							-- anchored to a cast bar
							position = {
								type = "select",
								name = L["Position"],
								desc = L["Position the bars for your %s"]:format(L["Player"]),
								values = positions,
								hidden = getplayernotfreeoptionshidden,
								order = 103,
							},
							gap = {
								type = "range",
								name = L["Gap"],
								desc = L["Tweak the vertical position of the bars for your %s"]:format(L["Player"]),
								min = -35, max = 35, step = 1,
								hidden = getplayernotfreeoptionshidden,
								order = 104,
							},
							offset = {
								type = "range",
								name = L["Offset"],
								desc = L["Tweak the horizontal position of the bars for your %s"]:format(L["Player"]),
								min = -35, max = 35, step = 1,
								hidden = getplayernotfreeoptionshidden,
								order = 106,
							},
							spacing = {
								type = "range",
								name = L["Spacing"],
								desc = L["Tweak the space between bars for your %s"]:format(L["Player"]),
								min = -35, max = 35, step = 1,
								order = 107,
							},
							nli = {
								type = "description",
								name = "",
								order = 108,
							},
							icons = {
								type = "toggle",
								name = L["Show Icons"],
								desc = L["Show icons on buffs and debuffs for your %s"]:format(L["Player"]),
								order = 109,
							},
							iconside = {
								type = "select",
								name = L["Icon Position"],
								desc = L["Set the side of the buff bar that the icon appears on"],
								values = {["left"] = L["Left"], ["right"] = L["Right"]},
								order = 110,
							},
						},
					},
					settings = {
						type = "group",
						name = L["Settings"],
						order = 1,
						args = {
							timesort = {
								type = "toggle",
								name = L["Sort by Remaining Time"],
								desc = L["Sort the buffs and debuffs by time remaining.  If unchecked, they will be sorted alphabetically."],
								order = 103,
								width = "full",
							},
							buffnametext = {
								type = "toggle",
								name = L["Buff Name Text"],
								desc = L["Display the names of buffs/debuffs on their bars"],
								order = 106,
							},
							bufftimetext = {
								type = "toggle",
								name = L["Buff Time Text"],
								desc = L["Display the time remaining on buffs/debuffs on their bars"],
								order = 107,
							},
							bufffont = {
								type = "select",
								dialogControl = "LSM30_Font",
								name = L["Font"],
								desc = L["Set the font used in the buff bars"],
								values = lsmlist.font,
								order = 108,
							},
							bufftexture = {
								type = "select",
								dialogControl = "LSM30_Statusbar",
								name = L["Texture"],
								desc = L["Set the buff bar Texture"],
								values = lsmlist.statusbar,
								order = 109,
							},
							bufftextcolor = {
								type = "color",
								name = L["Text Color"],
								desc = L["Set the color of the text for the buff bars"],
								order = 110,
								width = "full",
								get = getColor,
								set = setColor,
							},
							bufffontsize = {
								type = "range",
								name = L["Font Size"],
								desc = L["Set the font size for the buff bars"],
								min = 3, max = 15, step = 1,
								order = 111,
							},
							bufffontOutline = {
								type = "select",
								name = L["Font Outline"],
								desc = L["Font Outline"],
								values = {["SHADOW"] = L["Shadow"], [""] = L["None"], ["OUTLINE"] = L["Outline"], ["THICKOUTLINE"] = L["Thick Outline"]},
								order = 112,
							},
							bufffontShadowColor = {
								type = "color",
								name = L["Shadow Color"],
								desc = L["Shadow Color"],
								hasAlpha = true,
								get = getColor,
								set = setColor,
								disabled = function() return db.bufffontOutline ~= "SHADOW" end,
								order = 113,
							},
							bufffontShadowOffsetX = {
								type = "range",
								name = L["Shadow X Offset"],
								desc = L["Shadow X Offset"],
								min = -5, max = 5, step = 0.1,
								disabled = function() return db.bufffontOutline ~= "SHADOW" end,
								order = 114,
							},
							bufffontShadowOffsetY = {
								type = "range",
								name = L["Shadow Y Offset"],
								desc = L["Shadow Y Offset"],
								min = -5, max = 5, step = 0.1,
								disabled = function() return db.bufffontOutline ~= "SHADOW" end,
								order = 115,
							},
							buffalpha = {
								type = "range",
								name = L["Alpha"],
								desc = L["Set the alpha of the buff bars"],
								min = 0.05, max = 1, step = 0.05,
								isPercent = true,
								order = 116,
							},
							pandemic = {
								type = "toggle",
								name = L["Pandemic Highlight"],
								desc = L["Pulse an overlay on the bar while the aura is in its pandemic refresh window"],
								order = 117,
							},
							pandemiccolor = {
								type = "color",
								name = L["Pandemic Color"],
								desc = L["Set the color and maximum opacity of the pandemic overlay"],
								hasAlpha = true,
								get = getColor,
								set = setColor,
								disabled = function() return not db.pandemic end,
								order = 118,
							},
						},
					},
					colors = {
						type = "group",
						name = L["Colors"],
						desc = L["Colors"],
						order = -1,
						args = {
							buffcolor = {
								type = "color",
								name = L["Buff Color"],
								desc = L["Set the color of the bars for buffs"],
								get = getColor,
								set = setColor,
							},
							stealcolor = {
								type = "color",
								name = L["Stealable Color"],
								desc = L["Set the color of the bars for stealable buffs"],
								get = getColor,
								set = setColor,
								order = 100,
							},
							debuffsbytype = {
								type = "toggle",
								name = L["Debuffs by Type"],
								desc = L["Color debuff bars according to their dispel type"],
								order = 101,
							},
							debuffcolor = {
								type = "color",
								name = L["Debuff Color"],
								desc = L["Set the color of the bars for debuffs"],
								get = getColor,
								set = setColor,
								order = 102,
							},
							Curse = {
								type = "color",
								name = L["Curse Color"],
								desc = L["Set the color of the bars for curses"],
								get = getColor,
								set = setColor,
								disabled = hidedebuffsbytype,
								order = 103,
							},
							Disease = {
								type = "color",
								name = L["Disease Color"],
								desc = L["Set the color of the bars for diseases"],
								get = getColor,
								set = setColor,
								disabled = hidedebuffsbytype,
								order = 104,
							},
							Magic = {
								type = "color",
								name = L["Magic Color"],
								desc = L["Set the color of the bars for magic"],
								get = getColor,
								set = setColor,
								disabled = hidedebuffsbytype,
								order = 105,
							},
							Poison = {
								type = "color",
								name = L["Poison Color"],
								desc = L["Set the color of the bars for poisons"],
								get = getColor,
								set = setColor,
								disabled = hidedebuffsbytype,
								order = 106,
							},
						},
					},
				}
			}
		end
		return options
	end
end

----------------------------
-- Module lifecycle

function Buff:OnInitialize()
	self.db = Quartz3.db:RegisterNamespace(MODNAME, defaults)
	db = self.db.profile

	-- fix broken buff text color
	if type(db.bufftextcolor) ~= "table" then
		db.bufftextcolor = {1,1,1}
	end

	self:SetEnabledState(Quartz3:GetModuleEnabled(MODNAME))
	Quartz3:RegisterModuleOptions(MODNAME, getOptions, L["Buff"])
end

function Buff:OnEnable()
	if not hasAuraContainers then
		return
	end

	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("UNIT_FACTION")
	self:RegisterEvent("UNIT_PHASE", "UNIT_FACTION")
	self:RegisterEvent("UNIT_CONNECTION", "UNIT_FACTION")
	self:RegisterEvent("UNIT_AURA")

	local function retexture(tex)
		for _, entry in ipairs(buttons) do
			if entry.gen == generation[entry.unit] and (not entry.button.CanBeAccessedInContext or entry.button:CanBeAccessedInContext()) then
				entry.bg:SetTexture(tex)
				entry.dispel:SetTexture(tex)
				entry.steal:SetTexture(tex)
			end
		end
	end

	media.RegisterCallback(self, "LibSharedMedia_SetGlobal", function(mtype, override)
		if mtype == "statusbar" then
			retexture(media:Fetch("statusbar", override))
		end
	end)

	media.RegisterCallback(self, "LibSharedMedia_Registered", function(mtype, key)
		if mtype == "statusbar" and key == db.bufftexture then
			retexture(media:Fetch("statusbar", key))
		end
	end)

	self:Setup()
end

function Buff:OnDisable()
	media.UnregisterCallback(self, "LibSharedMedia_SetGlobal")
	media.UnregisterCallback(self, "LibSharedMedia_Registered")

	for _, container in pairs(containers) do
		container:SetEnabled(false)
		container:Hide()
	end
	for unit, mover in pairs(movers) do
		lockstate[unit] = true
		mover:EnableMouse(false)
		mover:Hide()
	end
end

function Buff:Setup()
	if not movers.target then
		ensureMover("target")
		ensureMover("focus")
		ensureMover("player")
	end
	self:ApplySettings()
end

function Buff:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:ApplySettings()
end

-- The container does not refresh itself on target/focus switches, same as Blizzard's TargetFrame.
local function refreshUnit(unit)
	local container = containers[unit]
	if not container then return end
	local canReach = unitReachable(unit)
	reachable[unit] = canReach
	pcall(container.SetEnabled, container, (db[unit] and canReach) and true or false)
	local state = unitReaction(unit)
	if state ~= reaction[unit] then
		reaction[unit] = state
		if container.sections then
			for i, section in ipairs(container.sections) do
				pcall(container.SetAuraGroupMaxFrameCount, container, "section" .. i, sectionMuted(section, state) and 0 or MAX_AURAS)
			end
		end
	end
	pcall(container.UpdateAllAuras, container)
end

function Buff:PLAYER_TARGET_CHANGED()
	refreshUnit("target")
end

function Buff:PLAYER_FOCUS_CHANGED()
	refreshUnit("focus")
end

function Buff:UNIT_FACTION(event, unit)
	if unit == "target" or unit == "focus" then
		refreshUnit(unit)
	end
end

-- Crossing the AOI boundary changes the aura payload, so this is the trigger that fires on the transition itself.
function Buff:UNIT_AURA(event, unit)
	if unit ~= "target" and unit ~= "focus" then return end
	if not containers[unit] then return end
	if unitReachable(unit) ~= reachable[unit] then
		refreshUnit(unit)
	end
end

function Buff:ApplySettings()
	db = self.db.profile

	-- One-shot conversion of stored bottom-left free positions to the center-relative system.
	if not db.centerpos then
		db.centerpos = true
		local cx, cy = UIParent:GetWidth() / 2, UIParent:GetHeight() / 2
		for _, unit in ipairs({ "target", "focus", "player" }) do
			if db[unit .. "x"] ~= nil then
				db[unit .. "x"] = db[unit .. "x"] - cx
			end
			if db[unit .. "y"] ~= nil then
				db[unit .. "y"] = db[unit .. "y"] - cy
			end
		end
	end

	if not hasAuraContainers or not self:IsEnabled() or not movers.target then
		return
	end

	for _, unit in ipairs(UNIT_LIST) do
		positionMover(unit)
		configureContainer(unit)
		self:SetMoverLocked(unit, lockstate[unit])
	end
	-- Buttons deny tainted native calls while auras are secret (retry after combat), stale generations are dropped along the way.
	local deferred
	for i = #buttons, 1, -1 do
		local entry = buttons[i]
		if entry.gen ~= generation[entry.unit] then
			table.remove(buttons, i)
		elseif not entry.button.CanBeAccessedInContext or entry.button:CanBeAccessedInContext() then
			styleButton(entry)
		else
			deferred = true
		end
	end
	if deferred then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
	for _, container in pairs(containers) do
		pcall(container.UpdateAllAuras, container)
	end
end
