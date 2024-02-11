local L = LibStub("AceLocale-3.0"):GetLocale("CalReminder", true)

function CalReminderFrame_OnLoad(self, ...)
	self:RegisterEvent("TALKINGHEAD_CLOSE")
	self.ShowCalendarButton:SetText(L["CALREMINDER_SHOWEVENT"])
end

function CalReminderFrame_OnMouseUp(self, ...)
	TalkingHeadFrame:FadeoutFrames()
end

function CalReminderFrameShowCalendarButton_OnClick(self, ...)
	if firstPendingEvent and firstEvent then
		CalReminderShowCalendar(firstEventMonthOffset, firstEventDay, firstEventId)
	end
	CalReminderFrame_OnMouseUp(CalReminderFrame)
end
