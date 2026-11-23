---@class ACNamespace
local private = select(2, ...)

local _G = getfenv(0)
local pairs, ipairs, table, math, string, type = _G.pairs, _G.ipairs, _G.table, _G.math, _G.string, _G.type
local floor, max = math.floor, math.max
local format = string.format
local CreateFrame, UIParent = _G.CreateFrame, _G.UIParent
local FauxScrollFrame_Update, FauxScrollFrame_GetOffset = _G.FauxScrollFrame_Update, _G.FauxScrollFrame_GetOffset
local FauxScrollFrame_OnVerticalScroll = _G.FauxScrollFrame_OnVerticalScroll
local GameTooltip = _G.GameTooltip

local L = LibStub("AceLocale-3.0"):GetLocale("Accountant_Classic")

local function getAddon()
	return private.addon or _G.Accountant_Classic or (LibStub and LibStub("AceAddon-3.0", true) and LibStub("AceAddon-3.0"):GetAddon("Accountant_Classic", true))
end

local function formatMoney(amount)
	local ac = getAddon()
	if not ac or not ac.GetFormattedValue then
		return tostring(amount or 0)
	end
	if not amount or amount == 0 then
		return "0"
	end
	local str = ac:GetFormattedValue(amount)
	return (str and str ~= "") and str or "0"
end

local ZoneBreakdown = {}
private.ZoneBreakdown = ZoneBreakdown

local DRAWER_WIDTH = 320
local DRAWER_HEIGHT = 512
local ROW_HEIGHT = 22
local NUM_VISIBLE_ROWS = 17

local drawer
local currentRow
local currentLogType
local currentCashflow
local sortedZones = {}
local totalAmount = 0
local topAmount = 0

---Parses raw zone key (e.g. "Thousand Needles - Freewind Post" or "Thunder Bluff") into mainZone and subZone.
---@param raw string
---@return string mainZone
---@return string subZone
local function parseZone(raw)
	if not raw or raw == "" then
		return L["Unknown"] or "Unknown", L["Unknown"] or "Unknown"
	end
	-- Core.lua formats zone keys with literal " - "; avoid byte-class patterns like [%-–—]
	-- because UTF-8 multi-byte trail bytes (0x80/0x93/0x94) corrupt CJK characters into mojibake.
	local sepStart, sepEnd = raw:find(" - ", 1, true)
	if sepStart then
		local mainZone = raw:sub(1, sepStart - 1)
		local subZone = raw:sub(sepEnd + 1)
		if mainZone ~= "" and subZone ~= "" then
			return mainZone, subZone
		end
	end
	return raw, raw
end

---Aggregates zone data from Accountant_ClassicZoneDB for the selected logType and cashflow.
---@param logType string
---@param cashflow "In"|"Out"
local function collectZoneData(logType, cashflow)
	sortedZones = {}
	totalAmount = 0
	topAmount = 0

	local ac = getAddon()
	if not ac or not ac.GetCurrentViewContext then return end
	local serverkey, charkey, logmode = ac:GetCurrentViewContext()
	if not logmode then return end

	local zones = {}
	if charkey then
		-- Single character mode
		local serverData = _G.Accountant_ClassicZoneDB and _G.Accountant_ClassicZoneDB[serverkey]
		local characterData = serverData and serverData[charkey]
		local periodData = characterData and characterData.data and characterData.data[logmode]
		local zoneData = periodData and periodData[logType]
		if zoneData then
			for k_zone, zoneAmounts in pairs(zoneData) do
				local amt = zoneAmounts[cashflow] or 0
				if amt > 0 then
					totalAmount = totalAmount + amt
					local mainZ, subZ = parseZone(k_zone)
					if not zones[mainZ] then
						zones[mainZ] = { name = mainZ, total = 0, subZones = {} }
					end
					zones[mainZ].total = zones[mainZ].total + amt
					zones[mainZ].subZones[subZ] = (zones[mainZ].subZones[subZ] or 0) + amt
				end
			end
		end
	else
		-- "All Chars" mode: aggregate across all characters on current server
		local serverData = _G.Accountant_ClassicZoneDB and _G.Accountant_ClassicZoneDB[serverkey]
		if serverData then
			for _, charData in pairs(serverData) do
				local periodData = charData.data and charData.data[logmode]
				local zoneData = periodData and periodData[logType]
				if zoneData then
					for k_zone, zoneAmounts in pairs(zoneData) do
						local amt = zoneAmounts[cashflow] or 0
						if amt > 0 then
							totalAmount = totalAmount + amt
							local mainZ, subZ = parseZone(k_zone)
							if not zones[mainZ] then
								zones[mainZ] = { name = mainZ, total = 0, subZones = {} }
							end
							zones[mainZ].total = zones[mainZ].total + amt
							zones[mainZ].subZones[subZ] = (zones[mainZ].subZones[subZ] or 0) + amt
						end
					end
				end
			end
		end
	end

	for _, z in pairs(zones) do
		local subs = {}
		for subName, subAmt in pairs(z.subZones) do
			subs[#subs + 1] = { name = subName, amount = subAmt }
		end
		table.sort(subs, function(a, b) return a.amount > b.amount end)
		z.subZones = subs
		sortedZones[#sortedZones + 1] = z
	end

	table.sort(sortedZones, function(a, b) return a.total > b.total end)
	topAmount = sortedZones[1] and sortedZones[1].total or 0
end

---Updates scroll list of status bars.
local function updateScrollFrame()
	if not drawer or not drawer:IsShown() then return end

	FauxScrollFrame_Update(drawer.ScrollFrame, #sortedZones, NUM_VISIBLE_ROWS, ROW_HEIGHT)
	local offset = FauxScrollFrame_GetOffset(drawer.ScrollFrame)

	for i = 1, NUM_VISIBLE_ROWS do
		local row = drawer.rows[i]
		local dataIndex = offset + i
		if dataIndex <= #sortedZones then
			local entry = sortedZones[dataIndex]
			row.entry = entry

			-- Status bar values
			row.bar:SetMinMaxValues(0, max(1, topAmount))
			row.bar:SetValue(entry.total)

			-- Rank and Zone Name
			row.leftText:SetText(format("|cFFFFD100%d.|r %s", dataIndex, entry.name))

			-- Cash and Percentage
			local pct = (totalAmount > 0) and ((entry.total / totalAmount) * 100) or 0
			local cashStr = formatMoney(entry.total)
			row.rightText:SetText(format("%s |cFF888888(%.1f%%)|r", cashStr, pct))

			-- Bar Color
			if currentCashflow == "In" then
				-- Emerald green
				row.bar:SetStatusBarColor(0.12, 0.68, 0.28, 0.85)
			else
				if currentLogType == "REPAIR" then
					-- Red/Orange for repairs
					row.bar:SetStatusBarColor(0.88, 0.32, 0.12, 0.85)
				else
					-- Golden amber for other expenses
					row.bar:SetStatusBarColor(0.85, 0.58, 0.10, 0.85)
				end
			end

			row:Show()
		else
			row.entry = nil
			row:Hide()
		end
	end

	if #sortedZones == 0 then
		drawer.emptyText:Show()
	else
		drawer.emptyText:Hide()
	end
end

---Builds and displays sub-zone tooltip when hovering a level-1 zone bar.
---@param self Button
local function onZoneBarEnter(self)
	local entry = self.entry
	if not entry then return end

	self.bar:SetAlpha(1.0)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	-- Header
	local flowLabel = (currentCashflow == "In") and (L["Incomings"] or "Incomings") or (L["Outgoings"] or "Outgoings")
	GameTooltip:AddLine(entry.name, 1, 1, 1)
	GameTooltip:AddDoubleLine(
		format("%s: %s", flowLabel, formatMoney(entry.total)),
		format("%.1f%% of Total", (totalAmount > 0) and (entry.total / totalAmount * 100) or 0),
		0.9, 0.9, 0.9, 0.7, 0.7, 0.7
	)

	-- Subzones list
	if entry.subZones and #entry.subZones > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["Sub-zone Breakdown"] or "Sub-zone Breakdown", 1, 0.82, 0)
		for _, sub in ipairs(entry.subZones) do
			local subPct = (entry.total > 0) and ((sub.amount / entry.total) * 100) or 0
			local subName = (sub.name == entry.name) and (L["General"] or "General") or sub.name
			GameTooltip:AddDoubleLine(
				"  • " .. subName,
				format("%s |cFF888888(%.1f%%)|r", formatMoney(sub.amount), subPct),
				1, 1, 1, 1, 1, 1
			)
		end
	end

	GameTooltip:Show()
end

---@param self Button
local function onZoneBarLeave(self)
	self.bar:SetAlpha(0.85)
	GameTooltip:Hide()
end

---Creates the drawer UI.
local function createDrawer()
	local backdropTemplate = BackdropTemplateMixin and "BackdropTemplate" or nil
	drawer = CreateFrame("Frame", "AccountantClassicZoneBreakdownFrame", UIParent, backdropTemplate)
	drawer:SetSize(DRAWER_WIDTH, DRAWER_HEIGHT)
	drawer:SetFrameStrata("DIALOG")
	drawer:EnableMouse(true)
	drawer:SetClampedToScreen(true)
	drawer:Hide()

	drawer:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = false,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})
	drawer:SetBackdropColor(0.06, 0.06, 0.07, 1.0)

	-- Close button
	local closeBtn = CreateFrame("Button", nil, drawer, "UIPanelCloseButton")
	closeBtn:SetPoint("TOPRIGHT", drawer, "TOPRIGHT", -3, -3)
	closeBtn:SetScript("OnClick", function() ZoneBreakdown:Hide() end)

	-- Title and Subtitle
	drawer.title = drawer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	drawer.title:SetPoint("TOPLEFT", drawer, "TOPLEFT", 14, -14)
	drawer.title:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", -4, 0)
	drawer.title:SetJustifyH("LEFT")

	drawer.subtitle = drawer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	drawer.subtitle:SetPoint("TOPLEFT", drawer.title, "BOTTOMLEFT", 0, -4)
	drawer.subtitle:SetPoint("TOPRIGHT", drawer, "TOPRIGHT", -14, 0)
	drawer.subtitle:SetJustifyH("LEFT")

	-- Toggle buttons for Incomings / Outgoings (placed cleanly below subtitle)
	local inBtn = CreateFrame("Button", nil, drawer, "UIPanelButtonTemplate")
	inBtn:SetSize(64, 20)
	inBtn:SetPoint("TOPLEFT", drawer.subtitle, "BOTTOMLEFT", 0, -6)
	inBtn:SetText(L["Incomings"] or "Incomings")
	inBtn:SetScript("OnClick", function()
		if currentCashflow ~= "In" then
			ZoneBreakdown:ShowFor(currentRow, currentLogType, "In")
		end
	end)
	drawer.inBtn = inBtn

	local outBtn = CreateFrame("Button", nil, drawer, "UIPanelButtonTemplate")
	outBtn:SetSize(64, 20)
	outBtn:SetPoint("LEFT", inBtn, "RIGHT", 6, 0)
	outBtn:SetText(L["Outgoings"] or "Outgoings")
	outBtn:SetScript("OnClick", function()
		if currentCashflow ~= "Out" then
			ZoneBreakdown:ShowFor(currentRow, currentLogType, "Out")
		end
	end)
	drawer.outBtn = outBtn

	-- Decorative separator line
	local sep = drawer:CreateTexture(nil, "ARTWORK")
	sep:SetHeight(1)
	sep:SetPoint("TOPLEFT", drawer, "TOPLEFT", 10, -78)
	sep:SetPoint("TOPRIGHT", drawer, "TOPRIGHT", -10, -78)
	sep:SetColorTexture(0.3, 0.3, 0.3, 0.8)

	-- Faux ScrollFrame
	local scroll = CreateFrame("ScrollFrame", "AccountantClassicZoneBreakdownScrollBar", drawer, "FauxScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", drawer, "TOPLEFT", 8, -84)
	scroll:SetPoint("BOTTOMRIGHT", drawer, "BOTTOMRIGHT", -26, 12)
	scroll:SetScript("OnVerticalScroll", function(self, offset)
		local onScroll = FauxScrollFrame_OnVerticalScroll or _G.FauxScrollFrame_OnVerticalScroll
		if onScroll then
			onScroll(self, offset, ROW_HEIGHT, updateScrollFrame)
		end
	end)
	drawer.ScrollFrame = scroll

	-- Status Bar rows
	drawer.rows = {}
	local barWidth = DRAWER_WIDTH - 42
	for i = 1, NUM_VISIBLE_ROWS do
		local row = CreateFrame("Button", nil, drawer)
		row:SetSize(barWidth, ROW_HEIGHT)
		row:EnableMouse(true)
		if i == 1 then
			row:SetPoint("TOPLEFT", drawer, "TOPLEFT", 10, -84)
		else
			row:SetPoint("TOPLEFT", drawer.rows[i - 1], "BOTTOMLEFT", 0, -2)
		end

		-- Background slot
		local bg = row:CreateTexture(nil, "BACKGROUND")
		bg:SetAllPoints()
		bg:SetColorTexture(0.11, 0.11, 0.13, 0.9)
		row.bg = bg

		-- Status bar
		local bar = CreateFrame("StatusBar", nil, row)
		bar:SetAllPoints()
		bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
		bar:SetMinMaxValues(0, 100)
		bar:SetValue(50)
		row.bar = bar

		-- Right text (Cash + %) anchored first so leftText can truncate before it
		local rightText = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		rightText:SetPoint("RIGHT", bar, "RIGHT", -6, 0)
		rightText:SetJustifyH("RIGHT")
		row.rightText = rightText

		-- Left text (Zone Name)
		local leftText = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		leftText:SetPoint("LEFT", bar, "LEFT", 6, 0)
		leftText:SetPoint("RIGHT", rightText, "LEFT", -6, 0)
		leftText:SetJustifyH("LEFT")
		if leftText.SetWordWrap then leftText:SetWordWrap(false) end
		row.leftText = leftText

		row:SetScript("OnEnter", onZoneBarEnter)
		row:SetScript("OnLeave", onZoneBarLeave)

		row:Hide()
		drawer.rows[i] = row
	end

	-- Empty state text
	local empty = drawer:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	empty:SetPoint("CENTER", drawer, "CENTER", 0, 0)
	empty:SetText(L["No zone data recorded for this category."] or "No zone data recorded for this category.")
	empty:Hide()
	drawer.emptyText = empty

	-- Keep drawer in sync with AccountantClassicFrame
	local parent = _G["AccountantClassicFrame"]
	if parent then
		parent:HookScript("OnHide", function() ZoneBreakdown:Hide() end)
		parent:HookScript("OnDragStop", function() ZoneBreakdown:UpdatePosition() end)
	end
end

---Refreshes current breakdown data (e.g. after tab or character change).
function ZoneBreakdown:RefreshCurrent()
	if drawer and drawer:IsShown() and currentLogType and currentCashflow then
		self:ShowFor(currentRow, currentLogType, currentCashflow)
	end
end

---Checks if the breakdown drawer is currently open for a logType/cashflow.
---@param logType string?
---@param cashflow string?
---@return boolean
function ZoneBreakdown:IsShownFor(logType, cashflow)
	if not (drawer and drawer:IsShown()) then return false end
	if logType and currentLogType ~= logType then return false end
	if cashflow and currentCashflow ~= cashflow then return false end
	return true
end

---Updates drawer position relative to AccountantClassicFrame.
function ZoneBreakdown:UpdatePosition()
	if not drawer or not drawer:IsShown() then return end
	local parent = _G["AccountantClassicFrame"]
	if not parent or not parent:IsShown() then
		self:Hide()
		return
	end

	drawer:ClearAllPoints()
	local right = parent:GetRight() or 0
	local screenWidth = UIParent:GetWidth() or 1920

	if right + DRAWER_WIDTH + 8 <= screenWidth then
		-- Attach to the right side of the main window
		drawer:SetPoint("TOPLEFT", parent, "TOPRIGHT", 2, 0)
		drawer:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 2, 0)
	else
		-- Attach to the left side
		drawer:SetPoint("TOPRIGHT", parent, "TOPLEFT", -2, 0)
		drawer:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -2, 0)
	end
end

---Displays the zone breakdown for a specified row and cashflow.
---@param row ACRow?
---@param logType string
---@param cashflow "In"|"Out"
function ZoneBreakdown:ShowFor(row, logType, cashflow)
	if not drawer then
		createDrawer()
	end

	-- Deselect previous row highlight
	if currentRow and currentRow.selectionHighlight then
		currentRow.selectionHighlight:Hide()
	end

	currentRow = row
	currentLogType = logType
	currentCashflow = cashflow

	-- Show selection highlight on clicked row
	if row then
		if not row.selectionHighlight then
			local hl = row:CreateTexture(nil, "BACKGROUND")
			hl:SetAllPoints(row)
			hl:SetColorTexture(1, 0.82, 0, 0.15)
			row.selectionHighlight = hl
		end
		row.selectionHighlight:Show()
	end

	-- Collect & Aggregate Data
	collectZoneData(logType, cashflow)

	-- Update Drawer Titles
	local onlineData = private.constants and private.constants.onlineData
	local titleText = (onlineData and onlineData[logType] and onlineData[logType].Title) or logType
	local flowText = (cashflow == "In") and (L["Incomings"] or "Incomings") or (L["Outgoings"] or "Outgoings")
	drawer.title:SetText(format("%s - %s %s", titleText, flowText, L["Zone Breakdown"] or "Zone Breakdown"))
	drawer.subtitle:SetText(format("%s: %s |cFF888888(%d %s)|r",
		L["Total"] or "Total",
		formatMoney(totalAmount),
		#sortedZones,
		L["Zones"] or "Zones"
	))

	-- Style toggle buttons
	if cashflow == "In" then
		drawer.inBtn:LockHighlight()
		drawer.outBtn:UnlockHighlight()
	else
		drawer.inBtn:UnlockHighlight()
		drawer.outBtn:LockHighlight()
	end

	-- Show before UpdatePosition because UpdatePosition exits early when drawer is hidden
	drawer:Show()
	self:UpdatePosition()
	updateScrollFrame()
end

---Hides the breakdown drawer and clears highlights.
function ZoneBreakdown:Hide()
	if currentRow and currentRow.selectionHighlight then
		currentRow.selectionHighlight:Hide()
	end
	currentRow = nil
	currentLogType = nil
	currentCashflow = nil
	if drawer then
		drawer:Hide()
	end
end

---Toggles breakdown for a row column when clicked.
---@param col ACRowColumn
function ZoneBreakdown:OnRowColumnClick(col)
	local logType = col.logType
	if not logType or logType == "" then return end

	local cashflow = col.cashflow
	if not cashflow then
		-- Clicking row Title: choose cashflow with larger amount
		local mIn = col.mIn or 0
		local mOut = col.mOut or 0
		cashflow = (mOut > mIn) and "Out" or "In"
	end

	local parentRow = col:GetParent() --[[@as ACRow]]

	-- If already open for this exact row and cashflow, toggle off
	if drawer and drawer:IsShown() and currentLogType == logType and currentCashflow == cashflow then
		self:Hide()
	else
		self:ShowFor(parentRow, logType, cashflow)
	end
end
