local ParserNotifications = {}
ParserNotifications.__index = ParserNotifications

function ParserNotifications:New()
	return setmetatable({
	}, self)
end

function ParserNotifications:HandleHonor(event)
	if event.recipientUnit == "player" then
		return "NOTIFICATION_HONOR_GAIN"
	end
	return nil
end

function ParserNotifications:HandleReputation(event)
	if event.recipientUnit ~= "player" then
		return nil
	end
	return "NOTIFICATION_REP_" .. (event.isLoss and "LOSS" or "GAIN"),
		event.factionName
end

function ParserNotifications:HandleProficiency(event)
	if event.recipientUnit == "player" then
		return "NOTIFICATION_SKILL_GAIN", event.skillName
	end
	return nil
end

-- The icon of a skill line of yours, found by the name its gain gives
-- (SkillLineIcons.lua). The spell of that name is no help on Forever: the
-- client has one for every profession, each with the same gem icon.
local function FindSkillIcon(skillName)
	local icons, info = MikSBT.SKILL_LINE_ICONS, C_SkillInfo
	if not icons or not info then return nil end
	for index = 1, info.GetNumSkillLines() do
		local line = info.GetSkillLineInfo(index)
		if line and line.name == skillName then return icons[line.skillID] end
	end
end

function ParserNotifications:SkillIcon(skillName)
	local found, icon = pcall(FindSkillIcon, skillName)
	return found and icon or nil
end

function ParserNotifications:HandleExperience(event)
	if event.recipientUnit == "player" then
		return "NOTIFICATION_EXPERIENCE_GAIN"
	end
	return nil
end

MikSBT.Components = MikSBT.Components or {}
MikSBT.Components.ParserNotifications = ParserNotifications

return ParserNotifications
