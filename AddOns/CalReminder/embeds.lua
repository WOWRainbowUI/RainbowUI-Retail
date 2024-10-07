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

function CalReminderButton_OnEnter(self)
	local tooltip = self:GetAttribute("tooltip")
	local tooltipDetail = self:GetAttribute("tooltipDetail")
	CalReminderTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
	if tooltip then
		CalReminderTooltip:SetText(tooltip)
		if tooltipDetail then
			for index,value in pairs(tooltipDetail) do
				CalReminderTooltip:AddLine(value, 1.0, 1.0, 1.0)
			end
		end
		CalReminderTooltip:Show()
	end
end

function CalReminderButton_OnLeave(self)
	CalReminderTooltip:Hide()
end
