--v1.0.5
-- Event function level up
local Event_Frame_A = CreateFrame("Frame")
Event_Frame_A:RegisterEvent("PLAYER_LEVEL_UP")
Event_Frame_A:SetScript("OnEvent",
	function(self, event, ...)
		PlaySoundFile("Interface\\Addons\\FFLU\\FFXIV_Level_Up.mp3", "Master")
	end)

-- Mute default level up sound
local Event_Frame_B = CreateFrame("Frame")
Event_Frame_B:RegisterEvent("ADDON_LOADED")
Event_Frame_B:SetScript("OnEvent",
	function(self, event, ...)
		MuteSoundFile(569593)
	end)
