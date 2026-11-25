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
-- A design may also offer to stand in the game's settings window, one panel for each of its pages:
-- DockPages() returns the pages in order as { { key =, label = }, ... }, Dock(panel, key, openers)
-- puts the window into the panel of page key, where openers holds for every key the function that
-- opens the game's settings at that page, Undock(panel) takes it out again, and IsDocked() tells
-- whether it stands in a panel. The classic design does this with its own functions in
-- MSBTOptionsMain.lua.
-- The game's settings window cannot drop a category it has registered, so the design it shows is
-- the one chosen when the game loaded. A different choice leaves the switch pending until the
-- interface is reloaded: IsSwitchPending() tells, and the options show a button that calls
-- ReloadForDesign(where). A choice made inside the settings window asks to reload at once. After
-- the reload the settings window opens again at the addon's own entry, or, when where was
-- "window", the options open in the chosen design. SetSettingsDesign(key, open) tells the registry
-- the design the settings window shows and the function that opens it at that entry.
local DEFAULT_DESIGN = "classic"

local designs = {}
local designKeys = {}

-- The design Hide put away, which the next Show brings back.
local reopenKey

-- The design the game's settings window shows; it is fixed when the game loads.
local settingsKey



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


-- Whether the game's settings window shows the options, in whichever design.
local function IsDocked()
	if MSBTOptions.Main.IsDocked() then return true end
	for _, key in ipairs(designKeys) do
		local isDocked = designs[key].IsDocked
		if isDocked and isDocked() then return true end
	end
	return false
end


-- The question to reload the interface. It is defined when first asked, once the texts are there.
local function AskToReload()
	if not StaticPopupDialogs["MSBT_RELOAD_FOR_DESIGN"] then
		StaticPopupDialogs["MSBT_RELOAD_FOR_DESIGN"] = {
			text = MikSBT.translations.MSG_DESIGN_ASK_RELOAD,
			button1 = YES,
			button2 = NO,
			OnAccept = function() module.ReloadForDesign("settings") end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		}
	end
	StaticPopup_Show("MSBT_RELOAD_FOR_DESIGN")
end


-- Whether the chosen design differs from the one the game's settings window shows.
local function IsSwitchPending()
	return settingsKey ~= nil and GetSelected() ~= settingsKey
end


-- Reloads the interface for the pending design. where says what opens afterwards: "settings" the
-- game's settings window, "window" the options window.
local function ReloadForDesign(where)
	MikSBT.Profiles.savedVariables.openSettingsAfterReload = where
	ReloadUI()
end


-- open opens the game's settings window at the addon's own entry. When the interface was reloaded
-- for a new design, what was asked for runs once at the first PLAYER_ENTERING_WORLD, as the
-- settings window is not ready to open earlier. A flag from an earlier build is true and counts
-- as "settings".
local function SetSettingsDesign(key, open)
	settingsKey = key
	local savedVariables = MikSBT.Profiles.savedVariables
	local where = savedVariables.openSettingsAfterReload
	if not where then return end
	savedVariables.openSettingsAfterReload = nil
	local run = where == "window" and function() module.Show() end or open
	if not run then return end
	local waiter = CreateFrame("Frame")
	waiter:RegisterEvent("PLAYER_ENTERING_WORLD")
	waiter:SetScript("OnEvent", function(this)
		this:UnregisterEvent("PLAYER_ENTERING_WORLD")
		run()
	end)
end


-- Opens the options in the chosen design, or in the one Hide put away. While the game's settings
-- window shows the options, they are open already. While the scroll areas are positioned, a
-- further design does not open. The classic window checks that itself, because it first leads
-- back into the game's settings window when it was put away from there.
local function Show()
	local key = reopenKey or GetSelected()
	if IsDocked() then return end
	local positioning = MSBTScrollAreasConfigFrame
	if key ~= DEFAULT_DESIGN and positioning and positioning:IsShown() then return end
	reopenKey = nil
	HideOthers(key)
	designs[key].Show()
end


-- Puts the options away until the next Show.
local function Hide()
	reopenKey = GetShown()
	if reopenKey then designs[reopenKey].Hide(true) end
end


-- Saves the choice, the classic design as no choice. An open window switches to it at once, and
-- a choice made while the options are put away is what the next Show opens. The game's settings
-- window changes with the next reload only. When the options stand in it, the choice asks to
-- reload at once; otherwise the options show a reload button while the switch is pending.
local function SwitchTo(key, previous)
	MikSBT.Profiles.savedVariables.optionsDesign = key ~= DEFAULT_DESIGN and key or nil
	reopenKey = nil
	-- A window put away for another panel can still have an editing session.
	if previous and previous ~= designs[key] and previous.ConfirmSwitch
		and not previous.IsShown() then
		previous.Hide()
	end
	if IsSwitchPending() and IsDocked() then AskToReload() end
	if GetShown() then Show() end
	return true
end


local function Select(key)
	if not designs[key] then return false end
	local active = designs[GetShown() or reopenKey]
	if key ~= GetSelected() and active and active.ConfirmSwitch
		and active.ConfirmSwitch(function() SwitchTo(key, active) end) then
		return true
	end
	return SwitchTo(key, active)
end




module.designs			= designs
module.keys				= designKeys
module.Register			= Register
module.GetSelected		= GetSelected
module.Show				= Show
module.Hide				= Hide
module.HideOthers		= HideOthers
module.Select			= Select
module.SetSettingsDesign	= SetSettingsDesign
module.IsSwitchPending	= IsSwitchPending
module.ReloadForDesign	= ReloadForDesign
