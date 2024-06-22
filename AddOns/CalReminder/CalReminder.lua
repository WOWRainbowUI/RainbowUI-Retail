CalReminder = LibStub("AceAddon-3.0"):NewAddon("CalReminder", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CalReminder", true)
local ACD = LibStub("AceConfigDialog-3.0")

CalReminderGlobal_CommPrefix = "CalReminder"

firstPendingEvent = false
firstEvent = nil
firstEventMonthOffset = nil
firstEventDay = nil
firstEventId = nil
firstEventDate = nil
firstEventIsTomorrow = false
firstEventIsToday = false

function CalReminder:OnInitialize()
	-- Called when the addon is loaded
	
	if not maxDaysToCheck then
		maxDaysToCheck = 31
	elseif maxDaysToCheck < 2 then
		maxDaysToCheck = 2
	elseif maxDaysToCheck > 62 then
		maxDaysToCheck = 62
	end
end

function CalReminder:OnEnable()
	-- Called when the addon is enabled
	C_Calendar.OpenCalendar()

	self:RegisterEvent("PLAYER_STARTED_MOVING", "ReloadData") -- Not SPELLS_CHANGED we want to be sure the player is not afk.
    --self:RegisterEvent("CALENDAR_ACTION_PENDING", "ReloadData")

	loadCalReminderOptions()

	self:RegisterChatCommand("crm", "CalReminderChatCommand")
	self:Print(L["CALREMINDER_WELCOME"])
end

function CalReminder:CalReminderChatCommand()
	CalReminder_OpenOptions()
end

function CalReminder_OpenOptions()
	ACD:Open("CalReminder")
end

function CalReminder:ReloadData()
	CalReminder:UnregisterEvent("PLAYER_STARTED_MOVING")
	CalReminder:RegisterEvent("CALENDAR_ACTION_PENDING", "ReloadData")
	local curHour, curMinute = GetGameTime()
	local curDate = C_DateAndTime.GetCurrentCalendarTime()
	local calDate = C_Calendar.GetMonthInfo()
	local month, day, year = calDate.month, curDate.monthDay, calDate.year
	local curMonth, curYear = curDate.month, curDate.year
	local monthOffset = -12 * (curYear - year) + month - curMonth
	local numEvents = 0

	local monthOffsetLoopId = monthOffset
	local dayLoopId = day
	local loopId = 1
	local dayOffsetLoopId = 0
	while not firstPendingEvent and dayOffsetLoopId <= maxDaysToCheck do
		while not firstPendingEvent and dayLoopId <= 31 and dayOffsetLoopId <= maxDaysToCheck do
			numEvents = C_Calendar.GetNumDayEvents(monthOffsetLoopId, dayLoopId)
			while not firstPendingEvent and loopId <= numEvents do
				firstEvent = C_Calendar.GetDayEvent(monthOffsetLoopId, dayLoopId, loopId)
				if firstEvent then
					CalReminder:UnregisterEvent("CALENDAR_ACTION_PENDING")
					if firstEvent.calendarType == "PLAYER" or firstEvent.calendarType == "GUILD_EVENT" then
						if monthOffsetLoopId == monthOffset
							and dayLoopId == day
								and curHour >= firstEvent.startTime.hour
									and curMinute >= firstEvent.startTime.minute then 
							--too late
						else
							if firstEvent.inviteStatus == Enum.CalendarStatus.Invited
									or firstEvent.inviteStatus == Enum.CalendarStatus.Tentative then
								--need response
								if dayLoopId == day then
									firstEventIsToday = true
								elseif dayLoopId == day + 1 then
									firstEventIsTomorrow = true
								end
								firstEventMonthOffset = monthOffsetLoopId
								firstEventDay = dayLoopId
								firstEventId = loopId
								firstPendingEvent = true
							end
						end
					end
				end
				loopId = loopId + 1
			end
			dayLoopId = dayLoopId + 1
			dayOffsetLoopId = dayOffsetLoopId + 1
			loopId = 1
		end
		monthOffsetLoopId = monthOffsetLoopId + 1
		dayLoopId = 1
	end
	
	if firstPendingEvent and firstEvent then
		englishFaction, localizedFaction = UnitFactionGroup("player")
		local chief = CalReminderOptionsData["HORDE_NPC"] or "GAMON"
		if englishFaction == "Alliance" then
			chief = CalReminderOptionsData["ALLIANCE_NPC"] or "SHANDRIS"
		end
		local frame = nil
		if firstEventIsToday then
			if not CalReminderOptionsData["SoundsDisabled"] then
				EZBlizzUiPop_PlaySound(12867)
			end
			frame = EZBlizzUiPop_npcDialog(chief, string.format(L["CALREMINDER_DDAY_REMINDER"], UnitName("player"), L["SPACE_BEFORE_DOT"], firstEvent.title), "CalReminderFrameTemplate")
		elseif firstEventIsTomorrow then
			if not CalReminderOptionsData["SoundsDisabled"] then
				EZBlizzUiPop_PlaySound(12867)
			end
			frame = EZBlizzUiPop_npcDialog(chief, string.format(L["CALREMINDER_LDAY_REMINDER"], UnitName("player"), L["SPACE_BEFORE_DOT"], firstEvent.title), "CalReminderFrameTemplate")
		end
		if not frame then
			EZBlizzUiPop_ToastFakeAchievementNew(CalReminder, firstEvent.title, 9680, not CalReminderOptionsData["SoundsDisabled"], 10, L["CALREMINDER_ACHIV_REMINDER"], function()  CalReminderShowCalendar(firstEventMonthOffset, firstEventDay, firstEventId)  end)
		end
	end
end

function CalReminderShowCalendar(monthOffset, day, id)
	if ( not IsAddOnLoaded("Blizzard_Calendar") ) then
		UIParentLoadAddOn("Blizzard_Calendar")
	end
	if ( Calendar_Toggle ) then
		Calendar_Toggle()
		ShowUIPanel(CalendarFrame)
	end
	--CalendarFrame_Update()
	--ShowUIPanel(CalendarFrame)
	if monthOffset and day and id then
		C_Calendar.OpenEvent(monthOffset, day, id)
		--EZBlizzUiPop_OverlayFrame:RegisterEvent("CALENDAR_OPEN_EVENT")
	end
end

