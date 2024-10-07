function CalReminder_playerCharacter()
	local playerName, playerRealm = UnitNameUnmodified("player")
	return CalReminder_addRealm(playerName, playerRealm)
end

function CalReminder_isPlayerCharacter(aName)
	return CalReminder_playerCharacter() == CalReminder_addRealm(aName)
end

function CalReminder_addRealm(aName, aRealm)
	if aName and not string.match(aName, "-") then
		if aRealm and aRealm ~= "" then
			aName = aName.."-"..aRealm
		else
			local realm = GetNormalizedRealmName() or UNKNOWN
			aName = aName.."-"..realm
		end
	end
	return aName
end

-- Converts a date into a timestamp (number of seconds since epoch)
function CalReminder_dateToTimestamp(day, month, year)
    return time({year = year, month = month, day = day, hour = 0, min = 0, sec = 0})
end

function CalReminder_getCurrentDate()
	local curDate = C_DateAndTime.GetCurrentCalendarTime()
	return curDate.monthDay, curDate.month, curDate.year
end

function CalReminder_getTimeUTCinMS()
	return tostring(time(date("!*t")))
end

function CalReminder_countTableElements(table)
	local count = 0
	if table then
		for _ in pairs(table) do
			count = count + 1
		end
	end
	return count
end
