local MAJOR, MINOR = "XamInsightToolKit", 1
local XITK = LibStub:NewLibrary(MAJOR, MINOR)
if not XITK then
    -- A newer version is already loaded
    return
end

---------------------------------------------------------------------------------------------------
-- WoW Client version workarounds                                                                --
---------------------------------------------------------------------------------------------------

-- Determine WoW TOC Version
XITK.WoWClassicEra, XITK.WoWClassicTBC, XITK.WoWWOTLKC, XITK.WoWRetail = false
local wowversion = select(4, GetBuildInfo())
if wowversion < 20000 then
	XITK.WoWClassicEra = true
elseif wowversion < 30000 then 
	XITK.WoWClassicTBC = true
elseif wowversion < 40000 then 
	XITK.WoWWOTLKC = true
elseif wowversion < 50000 then 
	XITK.WoWCATA = true
elseif wowversion < 60000 then 
	XITK.WoWMISTS = true
elseif wowversion > 90000 then
	XITK.WoWRetail = true

else
	-- n/a
end

function XITK.GetMouseFocus()
	local frame = nil
	if GetMouseFoci then
		local region = GetMouseFoci()
		frame = region[1]
	else
		frame = GetMouseFocus()
	end
	return frame
end

---------------------------------------------------------------------------------------------------
-- Addons functions                                                                              --
---------------------------------------------------------------------------------------------------

-- Returns the "main version" number or 0 on invalid input.
function XITK.getMainVersion(version)
    -- Validate the input first
    if type(version) ~= "string" or version == "" then
        return 0
    end

    -- Extract components safely
    local v1, v2, v3 = strsplit(".", version)

    -- Convert string parts to numbers
    local n1 = tonumber(v1)
    local n2 = tonumber(v2)

    -- If any required part is missing or not numeric, return 0
    if not n1 or not n2 then
        return 0
    end

    -- Compute the main version safely
    -- Note: multiply by 100 assuming format: major * 100 + minor
    return n1 * 100 + n2
end

function XITK.Error(addon, addonName, message)
	if addon and message then
		local messageToPrint = string.format("%s"..XITK.GetPunctuationSpace()..": %s", addonName or "XITK", message)
		UIErrorsFrame:AddMessage(messageToPrint, 1.0, 0.1, 0.1)
		addon:Print("|cFFFF0000"..message)
	end
end

---------------------------------------------------------------------------------------------------
-- Players and names functions                                                                   --
---------------------------------------------------------------------------------------------------

-- Tip by Gello - Hyjal
-- takes an npcID and returns the name of the npc
if (not XamInsightToolKitTooltip) then
	CreateFrame("GameTooltip", "XamInsightToolKitTooltip", UIParent, "GameTooltipTemplate")
	XamInsightToolKitTooltip:SetFrameStrata("TOOLTIP")
	XamInsightToolKitTooltip:Hide()
else
	return
end

function XITK.GetNameFromNpcID(npcID)
	local name = ""
	
	XamInsightToolKitTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	XamInsightToolKitTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d-0000000000", npcID))
	
	local line = _G[("XamInsightToolKitTooltipTextLeft%d"):format(1)]
	if line and line:GetText() then
		name = line:GetText()
	end
	
	return name
end

function XITK.IsPlayerUnitSafe(unit)
    local ok, isPlayer = pcall(UnitIsPlayer, unit)
    if ok then
        return isPlayer
	else
		return false
    end
end


function XITK.addRealm(aName, aRealm)
	if aName and (not issecretvalue or not issecretvalue(aName)) and not string.match(aName, "-") then
		if aRealm and aRealm ~= "" then
			aName = aName.."-"..aRealm
		else
			local realm = GetNormalizedRealmName() or UNKNOWN
			aName = aName.."-"..realm
		end
	end
	return aName
end

function XITK.delRealm(aName)
	if aName and (not issecretvalue or not issecretvalue(aName)) and string.match(aName, "-") then
		aName = strsplit("-", aName)
	end
	return aName
end

function XITK.fullName(unit)
	local fullName = nil
	if unit then
		local playerName, playerRealm = UnitNameUnmodified(unit)
		if not XITK.IsPlayerUnitSafe(unit) then
			return playerName
		end
		if playerName and playerName ~= "" and playerName ~= UNKNOWN then
			if not playerRealm or playerRealm == "" then
				playerRealm = GetNormalizedRealmName()
			end
			if playerRealm and playerRealm ~= "" then
				fullName = playerName.."-"..playerRealm
			else
				fullName = nil -- prevents too early usage of the function
			end
		end
	end
	return fullName
end

function XITK.isPlayerCharacter(aName)
	return XITK.playerCharacter() == XITK.addRealm(aName)
end

local playerCharacter
function XITK.playerCharacter()
	if not playerCharacter then
		playerCharacter = XITK.fullName("player")
	end
	return playerCharacter
end

function XITK.isPartyMember(unit)
	return unit == "player" or UnitInParty(unit) or UnitInRaid(unit)
end

---------------------------------------------------------------------------------------------------
-- String, number, date and table functions                                                              --
---------------------------------------------------------------------------------------------------

local LOCALES_WITH_PUNCT_SPACE = {
    frFR = true,
}

function XITK.GetPunctuationSpace()
    return LOCALES_WITH_PUNCT_SPACE[GetLocale()] and " " or ""
end

local function upperCaseBusiness(aText)
	return string.utf8upper(aText)
end

function XITK.titleFormat(aText)
	local retOK, ret
	local newText = ""
	if aText then
		newText = strtrim(aText):gsub("%s+", " ")
		retOK, ret = pcall(upperCaseBusiness, string.utf8sub(newText, 1 , 1))
		if retOK then
			newText = ret..string.utf8sub(newText, 2)
		end
	end
	return newText
end


function XITK.upperCase(aText)
	local retOK, ret
	local newText = ""
	if aText then
		retOK, ret = pcall(upperCaseBusiness, aText)
		if retOK then
			newText = ret
		else
			newText = aText
		end
	end
	return newText
end

-- Converts a date into a timestamp (number of seconds since epoch)
function XITK.dateToTimestamp(day, month, year)
    return time({year = year, month = month, day = day, hour = 0, min = 0, sec = 0})
end

function XITK.getCurrentDate()
	local curDate = C_DateAndTime.GetCurrentCalendarTime()
	return curDate.monthDay, curDate.month, curDate.year
end

function XITK.getTimeUTCinMS()
	return tostring(time(date("!*t")))
end

function XITK.countTableElements(table)
	local count = 0
	if table then
		for _ in pairs(table) do
			count = count + 1
		end
	end
	return count
end

function XITK.tonumberzeroonblankornil(aString)
	if aString and aString ~= "" then
		return tonumber(aString)
	else
		return 0
	end
end

function XITK.SimpleRound(val, valStep)
	return floor(val/valStep)*valStep
end

---------------------------------------------------------------------------------------------------
-- Sound handling functions                                                                      --
---------------------------------------------------------------------------------------------------

local willPlay, soundHandle

function XITK.PlaySound(soundID, channel, soundDisabled)
	if soundID and not soundDisabled then
		PlaySound(soundID, channel or "master")
	end
end

function XITK.PlaySoundFile(addonFolder, soundFile, channel, soundDisabled)
	if addonFolder and soundFile and not soundDisabled then
		if soundHandle then
			StopSound(soundHandle)
		end
		willPlay, soundHandle = PlaySoundFile("Interface\\AddOns\\"..addonFolder.."\\sound\\"..soundFile.."_"..GetLocale()..".ogg", channel)
		if not willPlay then
			willPlay, soundHandle = PlaySoundFile("Interface\\AddOns\\"..addonFolder.."\\sound\\"..soundFile..".ogg", channel)
		end
	end
	return soundHandle
end

function XITK.PlaySoundFileID(soundFileID, channel, playSound)
	if playSound then
		if soundHandle then
			StopSound(soundHandle)
		end
		willPlay, soundHandle = PlaySoundFile(soundFileID, channel)
	end
	return soundHandle
end

function XITK.PlayRandomSound(soundFileIDBank, channel, playSound)
	if playSound and soundFileIDBank then
		local nbSounds = #soundFileIDBank
		if nbSounds > 0 then
			local sound = math.random(1, nbSounds)
			return XITK.PlaySoundFileID(soundFileIDBank[sound], channel, playSound)
		end
	end
	return nil
end
