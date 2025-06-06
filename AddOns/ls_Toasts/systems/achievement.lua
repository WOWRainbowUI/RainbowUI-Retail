local _, addonTable = ...
local E, L, C = addonTable.E, addonTable.L, addonTable.C

-- Lua
local _G = getfenv(0)

-- Mine
local function Toast_OnClick(self)
	if self._data.ach_id and not InCombatLockdown() then
		if not AchievementFrame then
			AchievementFrame_LoadUI()
		end

		if AchievementFrame then
			ShowUIPanel(AchievementFrame)
			AchievementFrame_SelectAchievement(self._data.ach_id)
		end
	end
end

local function Toast_OnEnter(self)
	if self._data.ach_id then
		local _, name, _, _, month, day, year, description = GetAchievementInfo(self._data.ach_id)
		if name then
			if day and day > 0 then
				GameTooltip:AddDoubleLine(name, FormatShortDate(day, month, year), nil, nil, nil, 0.5, 0.5, 0.5)
			else
				GameTooltip:AddLine(name)
			end

			if description then
				GameTooltip:AddLine(description, 1, 1, 1, true)
			end
		end

		GameTooltip:Show()
	end
end

local function Toast_SetUp(event, achievementID, alreadyEarned, criteriaDescription)
	local _, name, points, _, _, _, _, _, _, icon, _, isGuildAchievement = GetAchievementInfo(achievementID)
	local toast = E:GetToast()

	if criteriaDescription then
		toast.Title:SetText(L["ACHIEVEMENT_PROGRESSED"])
		toast.Text:SetText(criteriaDescription)

		toast.IconText1:SetText("")
	else
		toast.Title:SetText(isGuildAchievement and L["GUILD_ACHIEVEMENT_UNLOCKED"] or L["ACHIEVEMENT_UNLOCKED"])
		toast.Text:SetText(name)

		if not toast:ShouldHideLeaves() then
			toast:ShowLeaves()
		end

		if alreadyEarned then
			toast.IconText1:SetText("")
		else
			if C.db.profile.colors.border then
				toast.Border:SetVertexColor(1, 0.675, 0.125) -- ACHIEVEMENT_GOLD_BORDER_COLOR
				toast:SetLeavesVertexColor(1, 0.675, 0.125)
			end

			if C.db.profile.colors.icon_border then
				toast.IconBorder:SetVertexColor(1, 0.675, 0.125)
			end

			toast.IconText1:SetText(points == 0 and "" or points)
		end
	end

	toast.Icon:SetTexture(icon)
	toast.IconBorder:Show()

	toast._data.event = event
	toast._data.ach_id = achievementID

	if C.db.profile.types.achievement.tooltip then
		toast:HookScript("OnEnter", Toast_OnEnter)
	end

	toast:HookScript("OnClick", Toast_OnClick)
	toast:Spawn(C.db.profile.types.achievement.anchor, C.db.profile.types.achievement.dnd)
end

local function ACHIEVEMENT_EARNED(achievementID, alreadyEarned)
	if alreadyEarned and not C.db.profile.types.achievement.earned then
		return
	end

	Toast_SetUp("ACHIEVEMENT_EARNED", achievementID, alreadyEarned)
end

local function CRITERIA_EARNED(achievementID, criteriaDescription, achievementAlreadyEarned)
	if achievementAlreadyEarned and not C.db.profile.types.achievement.earned then
		return
	end

	Toast_SetUp("CRITERIA_EARNED", achievementID, achievementAlreadyEarned, criteriaDescription)
end

local function Enable()
	if C.db.profile.types.achievement.enabled then
		E:RegisterEvent("ACHIEVEMENT_EARNED", ACHIEVEMENT_EARNED)
		E:RegisterEvent("CRITERIA_EARNED", CRITERIA_EARNED)
	end
end

local function Disable()
	E:UnregisterEvent("ACHIEVEMENT_EARNED", ACHIEVEMENT_EARNED)
	E:UnregisterEvent("CRITERIA_EARNED", CRITERIA_EARNED)
end

local function Test()
	-- new, Shave and a Haircut
	Toast_SetUp("ACHIEVEMENT_TEST", 545, false)

	-- earned, Reach Level 10
	Toast_SetUp("ACHIEVEMENT_TEST", 6, true)

	-- guild, Everyone Needs a Logo
	Toast_SetUp("ACHIEVEMENT_TEST", 5362)
end

E:RegisterOptions("achievement", {
	enabled = false,
	anchor = 1,
	dnd = false,
	tooltip = true,
	earned = false,
}, {
	name = L["TYPE_ACHIEVEMENT"],
	get = function(info)
		return C.db.profile.types.achievement[info[#info]]
	end,
	set = function(info, value)
		C.db.profile.types.achievement[info[#info]] = value
	end,
	args = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["ENABLE"],
			set = function(_, value)
				C.db.profile.types.achievement.enabled = value

				if value then
					Enable()
				else
					Disable()
				end
			end,
		},
		dnd = {
			order = 2,
			type = "toggle",
			name = L["DND"],
			desc = L["DND_TOOLTIP"],
		},
		tooltip = {
			order = 3,
			type = "toggle",
			name = L["TOOLTIPS"],
		},
		earned = {
			order = 4,
			type = "toggle",
			name = L["EARNED"],
		},
		test = {
			type = "execute",
			order = 99,
			width = "full",
			name = L["TEST"],
			func = Test,
		},
	},
})

E:RegisterSystem("achievement", Enable, Disable, Test)
