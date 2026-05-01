--[[ RGX-Framework - Commands ]]

local _, RGX = ...

RGX:RegisterSlashCommand("rgx", function(msg)
local input = strtrim(msg or "")
local cmd, rest = input:match("^(%S+)%s*(.-)$")
cmd = (cmd or ""):lower()
rest = rest or ""

if cmd == "modules" then
local mods = RGX:GetLoadedModules()
print("|cFF00A2FF[RGX]|r Modules:", table.concat(mods, ", "))

elseif cmd == "fonts" or cmd == "font" then
local Fonts = RGX:GetModule("fonts")
if Fonts then
local list = Fonts:ListAvailable()
print("|cFF00A2FF[RGX]|r Fonts:", #list, "available")
for i, f in ipairs(list) do
print("  ", f.name, "-", f.displayName, "-", f.category)
end
end

elseif cmd == "debug" then
local Fonts = RGX:GetModule("fonts")
if Fonts then
Fonts._forceDebug = not Fonts._forceDebug
print("|cFF00A2FF[RGX]|r Font debug:", Fonts._forceDebug and "ON" or "OFF")
end

else
print("|cFF00A2FF[RGX]|r Commands: modules, fonts, debug")
end
end, "RGX")
