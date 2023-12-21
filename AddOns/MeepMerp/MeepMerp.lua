--[[CLEU Arguments
1. CLEU
2. Timestamp
3. Type of event in CLEU
4. hideCaster
5. sourceGUID
6. sourceName
7. sourceFlags
8. sourceRaidFlags
9. destGUID
10. destName
11. destFlags
12. destRaidFlags
13. spellID
14. spellName
15. spellSchool
16. failedType]]--

local soundFile = "Interface\\AddOns\\MeepMerp\\Bonk.ogg" -- 音效檔案位置和檔名
local playerName = UnitName("player");

local MeepMerp = CreateFrame("Frame", "MeepMerp")
	MeepMerp:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	MeepMerp:SetScript("OnEvent", function(self, eventName, ...)
		return self[eventName](self, eventName, ...)
	end)

function MeepMerp:COMBAT_LOG_EVENT_UNFILTERED(event)
	local playerVehicleName = UnitName("vehicle");
	local _, subevent, _, _, sourceName, _, _, _, _, _, _, _, _, _, failureReason = CombatLogGetCurrentEventInfo()

	if (sourceName == playerName or sourceName == playerVehicleName) then
		if subevent == "SPELL_CAST_FAILED" then
			if failureReason == "超出範圍" then
				PlaySoundFile(soundFile, "Master");
			end
		end
	else
		return
	end
end

SLASH_SOUNDTOMAKE1 = "/meepmerp"
SlashCmdList.SOUNDTOMAKE = function()
	print("要更改超出法術範圍的提示音效，將聲音檔案 (MP3 或 OGG) 複製到遊戲安裝資料夾 > Interface > AddOns > MeepMerp 資料夾裡面，然後用記事本編輯 MeepMerp.lua，將音效檔案位置和檔名那一行裡面的 Bonk.ogg 改為新的聲音檔案名稱，要記得加上副檔名 .mp3 或 .ogg。完成後要重新啟動遊戲才會生效，重新載入無效。")
end