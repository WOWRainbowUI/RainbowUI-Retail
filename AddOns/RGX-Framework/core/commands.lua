--[[
    RGX-Framework - Commands
    
    Minimal slash commands for debugging
--]]

local _, RGX = ...

RGX:RegisterSlashCommand("rgx", function(msg)
	local input = strtrim(msg or "")
	local cmd, rest = input:match("^(%S+)%s*(.-)$")
	cmd = (cmd or ""):lower()
	rest = rest or ""
	
	if cmd == "modules" then
		local mods = RGX:GetLoadedModules()
		print("|cFF00A2FF[RGX]|r Modules:", table.concat(mods, ", "))
		
	elseif cmd == "fonts" then
		local Fonts = RGX:GetModule("fonts")
		if Fonts then
			local list = Fonts:ListAvailable()
			print("|cFF00A2FF[RGX]|r Fonts:", #list, "available")
		end

	elseif cmd == "font" then
		local Fonts = RGX:GetModule("fonts")
		local subcmd = rest:lower()
		if Fonts then
			if rest == "" then
				Fonts:ToggleTestFrame()
			elseif subcmd == "list" then
				local list = Fonts:ListAvailable()
				print("|cFF00A2FF[RGX]|r Fonts:", #list, "available")
			else
				print("|cFF00A2FF[RGX]|r Usage: /rgx font or /rgx fonts")
			end
		end
		
	elseif cmd == "debug" then
		RGX.debugMode = not RGX.debugMode
		print("|cFF00A2FF[RGX]|r Debug:", RGX.debugMode and "ON" or "OFF")
		
	else
		print("|cFF00A2FF[RGX]|r Commands: modules, fonts, font, debug")
	end
end, "RGX")
