local module = {}
local moduleName = "Designs"
MSBTOptions[moduleName] = module



-- The options window comes in designs. A design is a table with a label and the functions Show,
-- Hide and IsShown of its window, registered under a key. Hide gets true when the window is only
-- put away and comes back with the next Show. A design may add SkinPopup, which receives each
-- popup of the design's own set once, when it is made. The classic design registers itself in
-- MSBTOptionsMain.lua. A further design keeps its files in a folder of its own,
-- MSBTOptions\Designs\<Name>, and registers itself when they load.
-- What a design's window does itself: its Show takes the design's popups with
-- MSBTOptions.Popups.UseDesignPopups(key). Its Hide closes the popups with
-- MSBTOptions.Main.HidePopups, and unless the window is only put away it gives the popups back
-- with UseDesignPopups("classic").
local DEFAULT_DESIGN = "classic"

local designs = {}
local designKeys = {}

-- The design Hide put away, which the next Show brings back.
local reopenKey



local function Register(key, design)
	designKeys[#designKeys + 1] = key
	designs[key] = design
end


-- The chosen design, or the classic one without a choice or while the chosen one is not there.
local function GetSelected()
	local key = MikSBT.Profiles.savedVariables.optionsDesign
	return designs[key] and key or DEFAULT_DESIGN
end


local function GetShown()
	for _, key in ipairs(designKeys) do
		if designs[key].IsShown() then return key end
	end
end


-- Only one design is open at a time. A frame shows the moment it is created, so the design that
-- takes over may already count as open beside the one that gives way.
local function HideOthers(key)
	for _, other in ipairs(designKeys) do
		if other ~= key and designs[other].IsShown() then designs[other].Hide() end
	end
end


-- Opens the options in the chosen design, or in the one Hide put away. While the game's settings
-- window shows the options, they are open already. While the scroll areas are positioned, a
-- further design does not open. The classic window checks that itself, because it first leads
-- back into the game's settings window when it was put away from there.
local function Show()
	local key = reopenKey or GetSelected()
	reopenKey = nil
	if MSBTOptions.Main.IsDocked() then return end
	HideOthers(key)
	local positioning = MSBTScrollAreasConfigFrame
	if key ~= DEFAULT_DESIGN and positioning and positioning:IsShown() then return end
	designs[key].Show()
end


-- Puts the options away until the next Show.
local function Hide()
	reopenKey = GetShown()
	if reopenKey then designs[reopenKey].Hide(true) end
end


-- Saves the choice, the classic design as no choice. An open window switches to it at once, and
-- a choice made while the options are put away is what the next Show opens.
local function Select(key)
	if not designs[key] then return false end
	MikSBT.Profiles.savedVariables.optionsDesign = key ~= DEFAULT_DESIGN and key or nil
	reopenKey = nil
	if GetShown() then Show() end
	return true
end




module.designs			= designs
module.keys				= designKeys
module.Register			= Register
module.GetSelected		= GetSelected
module.Show				= Show
module.Hide				= Hide
module.HideOthers		= HideOthers
module.Select			= Select
