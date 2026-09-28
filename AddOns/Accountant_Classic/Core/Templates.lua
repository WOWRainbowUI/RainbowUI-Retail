--[[
$Id: Templates.lua 418 2026-09-19 03:18:51Z arithmandar $
]]
-----------------------------------------------------------------------
-- Description: Creates the reusable row templates used by the Accountant Classic UI.
-- This file is used to build the data rows and their text columns for the main frame.
-----------------------------------------------------------------------

local _, private = ...

local function createRowColumn(parent, key, width, offset, font, justify)
	local button = CreateFrame("Button", parent:GetName()..key, parent)
	button:SetSize(width, 19)
	button:SetPoint("TOPLEFT", parent, "TOPLEFT", offset, 0)
	button.Text = button:CreateFontString(parent:GetName()..key.."_Text", "OVERLAY", font)
	button.Text:SetSize(width, 19)
	button.Text:SetPoint("TOPLEFT", button, "TOPLEFT")
	button.Text:SetJustifyH(justify)
	if button.Text.SetNonSpaceWrap then
		button.Text:SetNonSpaceWrap(true)
	end
	button:SetScript("OnEnter", function(self)
		AccountantClassic_LogTypeOnShow(self)
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	return button
end

function AccountantClassic_InitializeRow(row)
	row:SetSize(600, 19)
	row.Title = createRowColumn(row, "Title", 280, 3, "GameFontNormal", "LEFT")
	row.In = createRowColumn(row, "In", 160, 273, "NumberFontNormal", "RIGHT")
	row.Out = createRowColumn(row, "Out", 160, 434, "NumberFontNormal", "RIGHT")
	return row
end

function AccountantClassic_CreateRow(parent, name)
	return AccountantClassic_InitializeRow(CreateFrame("Frame", name, parent))
end
