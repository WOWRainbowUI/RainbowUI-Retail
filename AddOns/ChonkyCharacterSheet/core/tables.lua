local addonName, ns = ...
local L = ns.L  -- grab the localization table
local CCS = ns.CCS
local locale = GetLocale()
local _, _, _, tocversion = GetBuildInfo()
CCS.tocversion = tocversion
CCS.expansionID = GetExpansionLevel()
local playerLevel = UnitLevel("player")

CCS.EventStats = {}
CCS.EventStatsEnabled = false
CCS.statsUpdatePending = false
CCS.characterUpdatePending = false
CCS.inspectUpdatePending = false
CCS.mythicUpdatePending = false
CCS.raidUpdatePending = false
CCS.optionsUpdatePending = false
CCS.Hooked = false
CCS.HookedInspect = false
CCS.incombat = false
CCS.ActiveFontMenu = nil
CCS.secretsdisabled = false
CCS.raidupdatedisabled = false
CCS.activeClickedRow = nil
CCS.initall = nil

-- Game version flags
CCS.RETAIL  = 1
CCS.CLASSIC = 2
CCS.TBC     = 4
CCS.WRATH   = 8
CCS.CATA    = 16
CCS.MOP     = 32
CCS.ALL = bit.bor(
    CCS.RETAIL,
    CCS.CLASSIC,
    CCS.TBC,
    CCS.WRATH,
    CCS.CATA,
    CCS.MOP)

CCS.GEM_NONE = 0
CCS.GEM_META = 1
CCS.GEM_HYDRAULIC = 5
CCS.GEM_COGWHEEL = 6
CCS.GEM_PRISMATIC = 7
CCS.GEM_PUNCHCARDRED = 19
CCS.GEM_PUNCHCARDYELLOW = 20
CCS.GEM_PUNCHCARDBLUE = 21
CCS.GEM_DOMINATION = 22

CCS.ModelAspect = 1.385

CCS.Modules = CCS.Modules or {}
CCS.MaxLevel = GetMaxPlayerLevel()

-- For throttling event handling, wow is pretty chatty.
CCS.Throttles = {
    CharacterStats = 0,
    MythicPlus = 0,
    PlayerLootSpec = 0,
    RaidProgress = 0,
    Init = 0,
}

function CCS:GetDefaultFontForLocale()

--Testing info
--locale = "enUS" --	English (United States) enGB clients return enUS
--locale = "koKR" --	Korean (Korea)
--locale = "frFR" --	French (France)
--locale = "deDE" --	German (Germany)
--locale = "zhCN" --	Chinese (Simplified, PRC)
--locale = "esES" --	Spanish (Spain)
--locale = "zhTW" --	Chinese (Traditional, Taiwan)
--locale = "esMX" --	Spanish (Mexico)
--locale = "ruRU" --	Russian (Russia)
--locale = "ptBR" --	Portuguese (Brazil)
--locale = "itIT" --	Italian (Italy)

    if locale == "zhCN" then
        return "Fonts\\ARKai_C.ttf" -- Simplified Chinese
    elseif locale == "zhTW" then
        return "Fonts\\bLEI00D.TTF" -- Traditional Chinese (default font for main client)
    elseif locale == "koKR" then
        return "Fonts\\2002.TTF" -- Korean
    elseif locale == "ruRU" then
        return "Fonts\\FRIZQT___CYR.TTF" -- Cyrillic
    end

    -- Default for enUS and others
    return "Fonts\\FRIZQT__.TTF"
end


-- Determine current game version flag
function CCS.GetCurrentVersion()
    local project = _G.WOW_PROJECT_ID
    if project == _G.WOW_PROJECT_MAINLINE then
        return CCS.RETAIL
    elseif project == _G.WOW_PROJECT_CLASSIC then
        return CCS.CLASSIC
    elseif project == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
        return CCS.TBC
    elseif project == _G.WOW_PROJECT_WRATH_CLASSIC then
        return CCS.WRATH
    elseif project == _G.WOW_PROJECT_CATACLYSM_CLASSIC then
        return CCS.CATA
    elseif project == _G.WOW_PROJECT_MISTS_CLASSIC then
        return CCS.MOP
    else
        return CCS.ALL -- fallback
    end
end


-- Option definitions table

ns.optionDefs = {
    -- Ignore these specific ones
    { type="slider", cat="IGNORE", ver=bit.bor(CCS.ALL), key="optionsheetscale", label="", value=1, default=1, min=0.5, max=1.25, step=0.05, slots=1 },
    { type="checkbox", cat="IGNORE", ver=bit.bor(CCS.ALL), key="globalprofile", label=L["GLOBAL_PROFILE"], value=true, default=true, slots=1 },
    -- Character Sheet Modules
    { type="divider", cat="GENERAL", ver=bit.bor(CCS.ALL), slots=4 }, -- color={1,1,1}
    { type="header", cat="GENERAL", ver=bit.bor(CCS.ALL), key=nil, label=L["HEADER_MODULE_SIZE"], slots=4, color={1, 1, 1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="divider", cat="GENERAL", ver=bit.bor(CCS.ALL), slots=4 },
    { type="checkbox", cat="GENERAL", ver=bit.bor(CCS.RETAIL, CCS.TBC), key="showcharacterstats", label=L["SHOW_CHARACTER_STATS"], value=true, default=true, slots=1 },
    { type="checkbox", cat="GENERAL", ver=bit.bor(CCS.ALL), key="show_inspect", label=L["SHOW_INSPECT"], value=true, default=true, slots=1 },
    { type="checkbox", cat="GENERAL", ver=bit.bor(CCS.RETAIL), key="showraidprogress", label=L["SHOW_RAID_PROGRESS"], value=true, default=true, slots=1 },
    { type="header", cat="GENERAL", ver=bit.bor(CCS.ALL), key=nil, label="", slots=1, color={1, 1, 1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="checkbox", cat="GENERAL", ver=bit.bor(CCS.RETAIL), key="showm_sp", label=L["SHOW_MYTHIC_SP"], value=true, default=false, slots=1 },
    { type="checkbox", cat="GENERAL", ver=bit.bor(CCS.RETAIL), key="showm_sp_btn", label=L["SHOW_MYTHIC_SP_BTN"], value=true, default=true, slots=1 },    
    { type="checkbox", cat="GENERAL", ver=bit.bor(CCS.RETAIL), key="showm_sp_onopen", label=L["SHOW_MYTHIC_SP_ONOPEN"], value=true, default=true, slots=2 },    
    { type="divider", cat="GENERAL", ver=bit.bor(CCS.ALL), slots=4 },
    { type="slider", cat="GENERAL", ver=bit.bor(CCS.ALL), key="sheetscale", label=L["SHEET_SCALE"], value=1, default=1, min=0.5, max=1.25, step=0.05, slots=2 },
    { type="slider", cat="GENERAL", ver=bit.bor(CCS.ALL), key="vpad", label=L["V_PAD"], value=23, default=23, min=0, max=40, step=1, slots=2 },
    { type="slider", cat="GENERAL", ver=bit.bor(CCS.ALL), key="hpad", label=L["H_PAD"], value=279, default=279, min=0, max=500, step=1, slots=2 },
    { type="slider", cat="GENERAL", ver=bit.bor(CCS.RETAIL), key="mplus_sp_scale", label=L["MPLUS_SP_SCALE"], value=1, default=1, min=0.5, max=1.5, step=0.1, slots=2 },
    { type="slider", cat="GENERAL", ver=bit.bor(CCS.ALL), key="sheetscale_inspect", label=L["SHEET_SCALE_INSPECT"], value=1, default=1, min=0.5, max=1.25, step=0.1, slots=2 },
    { type="slider", cat="GENERAL", ver=bit.bor(CCS.ALL), key="vpad_inspect", label=L["V_PAD_INSPECT"], value=23, default=23, min=0, max=40, step=1, slots=2 },
    { type="slider", cat="GENERAL", ver=bit.bor(CCS.RETAIL), key="raid_sp_scale", label=L["RAID_SP_SCALE"], value=1, default=1, min=0.5, max=1.5, step=0.1, slots=2 },
    { type="divider", cat="GENERAL", ver=bit.bor(CCS.ALL), slots=4 },
    { type="font", cat="GENERAL", ver=bit.bor(CCS.ALL), key="default_font", label=L["DEFAULT_FONT_NAME"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2},
    { type="button", cat="GENERAL", ver=bit.bor(CCS.ALL), key=nil, label=L["Apply Font to All"],  slots = 2, 
            onClick = function()
                local value = CCS.CurrentProfile["default_font"]
                if value ~= nil then
                    for _, def in ipairs(ns.optionDefs) do
                        if def.type == "font" and def.frame then
                            if def.frame.isCCSScrollDropdown and def.frame.SetSelectedValue then
                                -- custom scroll dropdown: let its shim handle both value and display name
                                def.frame:SetSelectedValue(value)
                            else
                                -- native Blizzard dropdown
                                UIDropDownMenu_SetSelectedValue(def.frame, value)
                                local display = CCS.fontPathsLocalized[value] or value
                                UIDropDownMenu_SetText(def.frame, display)
                            end

                            CCS:UpdateOption(def, value)
                        end
                    end
                    CCS:RefreshOptionsUI()
                    CCS.InitializeModules()
                end
            end},
    { type="checkbox", cat="GENERAL", ver=bit.bor(CCS.ALL), key="showfontshadow", label=L["Show Font Shadow"], value=false, default=false, slots=1 },
    { type="color", cat="GENERAL", ver=bit.bor(CCS.ALL), key="fontshadowcolor", label=L["Shadow Color"], value={0,0,0,1}, default={0,0,0,1}, slots=1 },
    { type="slider", cat="GENERAL", ver=bit.bor(CCS.ALL), key="fontshadowx", label=L["Shadow X Offset"], value=0, default=0, min=-15, max=15, step=1, slots=1 },
    { type="slider", cat="GENERAL", ver=bit.bor(CCS.ALL), key="fontshadowy", label=L["Shadow Y Offset"], value=0, default=0, min=-15, max=15, step=1, slots=1 },
    { type="dropdown", cat="GENERAL", ver=bit.bor(CCS.ALL), key="textoutline", label=L["TEXT_OUTLINE"], value="Thin Outline", default="Thin Outline", values={"No Outline", "Thin Outline", "Thick Outline"}, slots=2 },
    { type="divider", cat="GENERAL", ver=bit.bor(CCS.ALL), slots=4 },
    { type="header", cat="GENERAL", ver=bit.bor(CCS.ALL), key=nil, label=L["ADDON COLORS"], slots=4, color={1, 1, 1}, fontSize=16, fontOutline="THICKOUTLINE" },
    { type="color", cat="GENERAL", ver=bit.bor(CCS.ALL), key="button_color", label=L["Button Foreground Color"], value={0.49, 0.196, 0.659, 1}, default={0.49, 0.196, 0.659, 1}, slots=1 },
    { type="color", cat="GENERAL", ver=bit.bor(CCS.ALL), key="highlight_color", label=L["Highlight Color"], value={0.8, .2, 1, 1}, default={0.8, .2, 1, 1}, slots=1 },
    { type="color", cat="GENERAL", ver=bit.bor(CCS.ALL), key="border_color", label=L["Border Color"], value={0.3, 0.1, 0.4, 1}, default={0.3, 0.1, 0.4, 1}, slots=1 },
    { type="checkbox", cat="GENERAL", ver=bit.bor(CCS.ALL), key="style_class_color", label=L["Use Class Color"], value=false, default=false, slots=1 },
    
    -- Character Sheet General Display Settings
    { type="divider", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), slots=4 },
    { type="header", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key=nil, label=L["HEADER_GENERAL_DISPLAY"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="divider", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), slots=4 },
    { type="color", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="bgcolor", label=L["CCS_BG_COLOR"], value={0,0,0,0.89}, default={0,0,0,0.89}, slots=1 },
    { type="dropdown", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL), key="bgtype", label=L["BG_TYPE"], value="Midnight", default="Midnight", values={"Default", "Class", "Race", "Midnight", "Hide"}, slots=2 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL), key="showbganimations", label=ANIMATION, value=true, default=true, slots=1 },
    { type="divider", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key=nil, label=L["HEADER_ITEM_DISPLAY"], slots=4, color={1,1,1}, fontSize=16, fontOutline="THICKOUTLINE" },
    { type="divider", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), slots=4 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showitemname", label=L["SHOW_ITEM_NAME"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="itemcolorwhite", label=L["ITEM_COLOR_WHITE"], value=false, default=false, slots=1 },
    { type="slider", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="itemnamelength", label=L["ITEM_NAME_LENGTH"], value=75, default=75, min=1, max=75, step=1, slots=2 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showdurability", label=L["SHOW_DURABILITY"], value=false, default=false, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showdurabilitybar", label=L["SHOW_DURABILITY_BAR"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="hideshowchbtn", label=L["HIDE_SHOW_CHAR_BTN"], value=false, default=false, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="hideiconborders", label=L["HIDE_ICON_BORDERS"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showenchants", label=L["SHOW_ENCHANTS"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showgems", label=L["SHOW_GEMS"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showilvl", label=L["SHOW_ILVL"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showpvpilvl", label=L["SHOW_PVP_ILVL"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showenchantgemerrors", label=L["SHOW_ENCHANT_GEM_ERRORS"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL), key="showmissingsockets", label=L["SHOW_MISSING_SOCKETS"], value=false, default=false, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showitemupgrade", label=L["SHOW_ITEM_UPGRADE"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="upgradecolorrarity", label=L["Upgrade Color by Rarity"], value=false, default=false, slots=1 },
    { type="color", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="itemupgradecolor", label=L["ITEM_UPGRADE_COLOR"], value={0.98,0.60,0.35,1}, default={0.98,0.60,0.35,1}, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showitemcolor", label=L["SHOW_ITEM_COLOR_BG"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showsetitems", label=L["SHOW_SET_ITEMS"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="showsetclasscolor", label=L["SHOW_SET_CLASS_COLOR"], value=true, default=true, slots=1 },
    { type="color", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="setitemcolor", label=L["SET_ITEM_COLOR"], value={0.05,0.75,0.45,1}, default={0.05,0.75,0.45,1}, slots=4 },
    { type="slider", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="itemcolorbrightness", label=L["Item Background Brightness"], value=1.00, default=1.00, min=0.30, max=1.00, step=0.01, slots=2 },
    { type="slider", cat="CHAR-SHEET", ver=bit.bor(CCS.ALL), key="enchantnamelength", label=L["ENCHANT_NAME_LENGTH"], value=100, default=100, min=20, max=100, step=1, slots=2 },

    -- Spec Display Options
    { type="divider", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL, CCS.MOP), slots=4 },
    { type="header", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL, CCS.MOP), key=nil, label=L["HEADER_SPEC_DISPLAY"], slots=4, color={1,1,1}, fontSize=16, fontOutline="THICKOUTLINE" },
    { type="divider", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL, CCS.MOP), slots=4 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="showspec", label=L["SHOW_SPEC"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="showspectitle", label=L["SHOW_SPEC_TITLE"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="showlootspec", label=L["SHOW_LOOT_SPEC"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-SHEET", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="showlootspectitle", label=L["SHOW_LOOT_SPEC_TITLE"], value=true, default=true, slots=1 },

    -- Character Sheet Font Settings
    { type="divider", cat="CHAR-FONT", ver=bit.bor(CCS.ALL), slots=4 },
    { type="header", cat="CHAR-FONT", ver=bit.bor(CCS.ALL), key=nil, label=L["HEADER_FONT_SETTINGS"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="divider", cat="CHAR-FONT", ver=bit.bor(CCS.ALL), slots=4 },
    { type="font", cat="CHAR-FONT", ver=bit.bor(CCS.ALL), key="fontname_nametitle", label=L["FONT_NAME_NAMETITLE"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2},
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.ALL), key="fontsize_nametitle", label=FONT_SIZE, value=12, default=12, min=3, max=36, step=1, slots=1 },
    { type="color", cat="CHAR-FONT", ver=bit.bor(CCS.ALL), key="fontcolor_nametitle", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },
    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.ALL),   key="fontname_levelclass", label=L["FONT_NAME_LEVELCLASS"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.ALL), key="fontsize_levelclass", label=FONT_SIZE, value=12, default=12, min=3, max=36, step=1, slots=1 },
    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.ALL),   key="fontname_durability", label=L["FONT_NAME_DURABILITY"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.ALL), key="fontsize_durability", label=FONT_SIZE, value=10, default=10, min=3, max=36, step=1, slots=1 },
    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.ALL),   key="fontname_enchant", label=L["FONT_NAME_ENCHANT"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.ALL), key="fontsize_enchant", label=FONT_SIZE, value=10, default=10, min=3, max=36, step=1, slots=1 },
    { type="color",  cat="CHAR-FONT", ver=bit.bor(CCS.ALL), key="fontcolor_enchant", label=COLOR, value={0.1647, 0.9804, 0.7098, 1}, default={0.1647, 0.9804, 0.7098, 1}, slots=1 },
    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.ALL),   key="fontname_iilvl", label=L["FONT_NAME_IILVL"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.ALL), key="fontsize_iilvl", label=FONT_SIZE, value=10, default=10, min=3, max=36, step=1, slots=1 },
    { type="color",  cat="CHAR-FONT", ver=bit.bor(CCS.ALL), key="fontcolor_iilvl", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },
    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.ALL),   key="fontname_iname", label=L["FONT_NAME_INAME"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.ALL), key="fontsize_iname", label=FONT_SIZE, value=11, default=11, min=3, max=36, step=1, slots=1 },
    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP),   key="fontname_reputation", label=L["FONT_NAME_REPUTATION"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="fontsize_reputation", label=FONT_SIZE, value=10, default=10, min=3, max=36, step=1, slots=1 },
    { type="color",  cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="fontcolor_reputation", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },
    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP),   key="fontname_repstanding", label=L["FONT_NAME_REPSTANDING"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="fontsize_repstanding", label=FONT_SIZE, value=10, default=10, min=3, max=36, step=1, slots=1 },
    { type="color",  cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="fontcolor_repstanding", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },

    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL),   key="fontname_currency", label=L["FONT_NAME_CURRENCY"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL), key="fontsize_currency", label=FONT_SIZE, value=12, default=12, min=3, max=36, step=1, slots=1 },
    { type="color",  cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL), key="fontcolor_currency", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },
    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP),   key="fontname_showchar", label=L["FONT_NAME_SHOWCHAR"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="fontsize_showchar", label=FONT_SIZE, value=10, default=10, min=3, max=36, step=1, slots=1 },
    { type="color",  cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="fontcolor_showchar", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },
    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP),   key="fontname_lootspec", label=L["FONT_NAME_LOOTSPEC"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="fontsize_lootspec", label=FONT_SIZE, value=10, default=10, min=3, max=34, step=1, slots=1 },
    { type="color",  cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="fontcolor_lootspec", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },
    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP),   key="fontname_specs", label=L["FONT_NAME_SPECS"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="fontsize_specs", label=FONT_SIZE, value=10, default=10, min=3, max=34, step=1, slots=1 },
    { type="color",  cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="fontcolor_specs", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },
    { type="font",   cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP),   key="fontname_titles", label=L["FONT_NAME_TITLES"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-FONT", ver=bit.bor(CCS.RETAIL, CCS.MOP), key="fontsize_titles", label=FONT_SIZE, value=10, default=10, min=3, max=34, step=1, slots=1 },

    -- Character Stats Section
    { type="divider", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL, CCS.TBC), slots=4 },
    { type="header", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL, CCS.TBC), key=nil, label=L["HEADER_STATS_MODULE"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="divider", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL, CCS.TBC), slots=4 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL, CCS.TBC), key="show_headers", label=L["SHOW_HEADERS"], value=true, default=true, slots=1 },
    { type="slider", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL, CCS.TBC), key="round", label=L["STATS_ROUNDING"], value=2, default=2, min=0, max=2, step=1, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_inbag_ilvl", label=L["SHOW_INBAG_ILVL"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_stat_icons", label=L["show_stat_icons"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_diminishing_returns", label=L["show_diminishing_returns"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_hide_zero_stats", label=L["hide_zero_stats"], value=false, default=false, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_secondarypriority", label=L["Show wowhead recommended secondary stat priority"], value=false, default=false, slots=2 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_stathighlights", label=ENABLE..": "..L["STATS_TOGGLE"], value=true, default=true, slots=2 },
    { type="dropdown", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="long_text_handling", label=L["Long Text Handling"], value="Truncate", default="Truncate", values={"Full Text", "Truncate", "Wrap Text"}, slots=2 },

    { type="divider", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key=nil, label=L["Attributes"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_attributes", label=L["show_attributes"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="collapse_attributes", label=L["collapse_attributes"], value=false, default=false, slots=1 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="attribute_color", label=L["BGCOLOR_ATTRIBUTES"], value={0.90, 0.70, 0.20, 1}, default={0.90, 0.70, 0.20, 1}, slots=2 }, -- Gold

    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="attribute_primary",   label=L["attribute_primary"],   value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="attribute_stamina",   label=L["attribute_stamina"],   value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="attribute_health",    label=L["attribute_health"],    value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="attribute_power",     label=L["attribute_power"],     value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="attribute_gcd",       label=L["attribute_gcd"],       value=true, default=true, slots=1 },

    { type="divider", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key=nil, label=L["Secondary"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_secondary", 	label=L["show_secondary"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="collapse_secondary", label=L["collapse_secondary"], value=false, default=false, slots=1 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="secondary_stats_color", label=L["BGCOLOR_SECONDARY_STATS"], value={0.40, 0.80, 0.40, 1}, default={0.40, 0.80, 0.40, 1}, slots=2 }, -- Dark Green
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="secondary_crit",        label=L["secondary_crit"],        value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="secondary_haste",       label=L["secondary_haste"],       value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="secondary_mastery",     label=L["secondary_mastery"],     value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="secondary_versatility", label=L["secondary_versatility"], value=true, default=true, slots=1 },
    { type="dropdown", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="secondary_versatility_display", label=L["Versatility Display"], value="All", default="All", values={"All", "Damage/Healing", "Damage Reduction"}, slots=2 },


    { type="divider", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key=nil, label=L["Attack"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_attack", label=L["show_attack"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="collapse_attack", label=L["collapse_attack"], value=false, default=false, slots=1 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="attack_stats_color", label=L["BGCOLOR_ATTACK_STATS"], value={0.8, 0.3, .3, 1}, default={0.8, 0.3, .3, 1}, slots=2 }, -- Dark Red
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="attack_power", label=L["attack_power"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="attack_speed", label=L["attack_speed"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="attack_spell", label=L["attack_spell"], value=true, default=true, slots=1 },

    { type="divider", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key=nil, label=L["Defense"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_defense", label=L["show_defense"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="collapse_defense", label=L["collapse_defense"], value=false, default=false, slots=1 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="defense_stats_color", label=L["BGCOLOR_DEFENSE_STATS"], value={0.29, 0.46, 0.9, 1}, default={0.29, 0.46, 0.9, 1}, slots=2 }, -- Dark Blue
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="defense_armor",   label=L["defense_armor"],   value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="defense_dodge",   label=L["defense_dodge"],   value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="defense_parry",   label=L["defense_parry"],   value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="defense_block",   label=L["defense_block"],   value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="defense_stagger", label=L["defense_stagger"], value=true, default=true, slots=1 },

    { type="divider", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key=nil, label=L["General"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_general", label=L["show_general"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="collapse_general", label=L["collapse_general"], value=false, default=false, slots=1 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="general_color", label=L["BGCOLOR_GENERAL_STATS"], value={0.7, 0.7, 0.7, 1}, default={0.7, 0.7, 0.7, 1}, slots=2 }, -- Gray
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="general_durability", label=L["general_durability"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="general_leech",      label=L["general_leech"],      value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="general_avoidance",  label=L["general_avoidance"],  value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="general_speed",      label=L["general_speed"],      value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="general_movespeed",  label=L["general_movespeed"],  value=true, default=true, slots=1 },

    { type="divider", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key=nil, label=L["Crests"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_crests", label=L["show_crests"], value=false, default=false, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="collapse_crests", label=L["collapse_crests"], value=false, default=false, slots=1 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="crests_color", label=L["BGCOLOR_CRESTS_STATS"], value={0.85, 0.55, 1, 1}, default={0.85, 0.55, 1, 1}, slots=2 }, -- Gray
--REMOVED BY BLIZ for Midnight S1.  Keeping just in case.    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="crests_valorstone", label=L["crests_valorstone"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="crests_myth",       label=L["crests_myth"],       value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="crests_hero",       label=L["crests_hero"],       value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="crests_champion",   label=L["crests_champion"],   value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="crests_veteran",    label=L["crests_veteran"],    value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="crests_adventurer", label=L["crests_adventurer"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="crests_catalyst", label=L["crests_catalyst"], value=true, default=true, slots=1 },

    { type="divider", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key=nil, label=L["PvP"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="show_pvp", label=L["show_pvp"], value=false, default=false, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="collapse_pvp", label=L["collapse_pvp"], value=false, default=false, slots=1 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="pvp_color", label=L["BGCOLOR_PVP_STATS"], value={0.95, 0.25, 0.60, 1}, default={0.95, 0.25, 0.60, 1}, slots=2 }, -- Gray
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="pvp_honorlevel", label=L["pvp_honorlevel"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="pvp_honor",      label=L["pvp_honor"],      value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="pvp_conquest",   label=L["pvp_conquest"],   value=true, default=true, slots=1 },
   -- { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="pvp_bloodtokens",label=L["pvp_bloodtokens"],value=true, default=true, slots=1 },
   -- { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key="pvp_trophy",     label=L["pvp_trophy"],     value=true, default=true, slots=1 },

    -- Custom Priority Profiles (dynamic section - UI managed by options.lua)
    { type="divider", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header",  cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key=nil, label=L["Custom Priority Profiles"], slots=4, color={1,1,1}, fontSize=16, fontOutline="THICKOUTLINE" },
    { type="priority_slots_section", cat="CHAR-STATS", ver=bit.bor(CCS.RETAIL), key=nil, slots=4 },

    -- TBC and Classic Stats Options
    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.TBC), key="show_basestats", label=L["SHOW_BASESTATS"], value=true, default=true, slots=2 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.TBC), key="ccs_basestats_color", label=L["BGCOLOR_BASESTATS"], value={0.64, 0.47, 0.1, 0.4}, default={0.64, 0.47, 0.1, 0.4}, slots=2 }, -- Gold

    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.TBC), key="show_melee_stats", label=L["SHOW_MELEE_STATS"], value=true, default=true, slots=2 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.TBC), key="ccs_melee_stats_color", label=L["BGCOLOR_MELEE_STATS"], value={0.16, 0.34, 0.08, 0.4}, default={0.16, 0.34, 0.08, 0.4}, slots=2 }, -- Dark Green

    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.TBC), key="show_ranged_stats", label=L["SHOW_RANGED_STATS"], value=true, default=true, slots=2 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.TBC), key="ccs_ranged_stats_color", label=L["BGCOLOR_RANGED_STATS"], value={0.41, 0, 0, 0.4}, default={0.41, 0, 0, 0.4}, slots=2 }, -- Dark Red

    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.TBC), key="show_spell_stats", label=L["SHOW_SPELL_STATS"], value=true, default=true, slots=2 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.TBC), key="ccs_spell_stats_color", label=L["BGCOLOR_SPELL_STATS"], value={0, 0.13, 0.38, 0.4}, default={0, 0.13, 0.38, 0.4}, slots=2 }, -- Dark Blue

    { type="checkbox", cat="CHAR-STATS", ver=bit.bor(CCS.TBC), key="show_defenses_stats", label=L["SHOW_DEFENSES_STATS"], value=true, default=true, slots=2 },
    { type="color",    cat="CHAR-STATS", ver=bit.bor(CCS.TBC), key="ccs_defenses_color", label=L["BGCOLOR_DEFENSES_STATS"], value={0.45, 0.45, 0.45, 0.4}, default={0.45, 0.45, 0.45, 0.4}, slots=2 }, -- Gray
    
    -- Stats Font Settings
    { type="divider", cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC), slots=4 },
    { type="header", cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC), key=nil, label=L["HEADER_STATS_FONT"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="divider", cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC), slots=4 },
    { type="font",   cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC),   key="fontname_cilvl", label=L["FONT_NAME_CILVL"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC), key="fontsize_cilvl", label=FONT_SIZE, value=20, default=20, min=3, max=34, step=1, slots=1 },

    { type="font",   cat="CHAR-STATS-FONT", ver=bit.bor(CCS.TBC),   key="fontname_hppower", label=L["FONT_NAME_HPPOWER"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-STATS-FONT", ver=bit.bor(CCS.TBC), key="fontsize_hppower", label=FONT_SIZE, value=12, default=12, min=3, max=34, step=1, slots=1 },
    { type="color",  cat="CHAR-STATS-FONT", ver=bit.bor(CCS.TBC), key="fontcolor_hppower", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },

    { type="font",   cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC),   key="fontname_statheaders", label=L["FONT_NAME_STATHEADERS"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC), key="fontsize_statheaders", label=FONT_SIZE, value=14, default=14, min=3, max=34, step=1, slots=1 },
    { type="color",  cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC), key="fontcolor_statheaders", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },

    { type="font",   cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC),   key="fontname_statname", label=L["FONT_NAME_STATNAME"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC), key="fontsize_statname", label=FONT_SIZE, value=10, default=10, min=3, max=34, step=1, slots=1 },
    { type="color",  cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC), key="fontcolor_statname", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },

    { type="font",   cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC),   key="fontname_stats", label=L["FONT_NAME_STATS"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC), key="fontsize_stats", label=FONT_SIZE, value=10, default=10, min=3, max=34, step=1, slots=1 },
    { type="color",  cat="CHAR-STATS-FONT", ver=bit.bor(CCS.RETAIL, CCS.TBC), key="fontcolor_stats", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },


    -- Mythic+ Side Panel
    { type="divider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key=nil, label=L["HEADER_MYTHIC_PANEL"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="divider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="checkbox", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="showmythicplusscore", label=L["SHOW_MYTHIC_SCORE"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="showm_overundertime", label=L["SHOW_M_OVERUNDER"], value=true, default=true, slots=1 },
    { type="color", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="ccsmbgcolor", label=L["CCS_M_BG_COLOR"], value={0,0,0,0.85}, default={0,0,0,0.85}, slots=2 },
    { type="divider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="font",   cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontname_mplus", label=L["FONT_NAME_MPLUS"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontsize_mplus", label=L["FONT_SIZE_MPLUS"], value=11, default=11, min=3, max=34, step=1, slots=2 },
    { type="divider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), slots=4 },

    { type="font",   cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontname_mplus_affix", label=L["FONT_NAME_MPLUS_AFFIX"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontsize_mplus_affix", label=FONT_SIZE, value=11, default=11, min=3, max=34, step=1, slots=1 },
    { type="color",  cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontcolor_mplus_affix", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },
    { type="divider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), slots=4 },

    { type="font",   cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL),   key="fontname_mplus_header", label=L["FONT_NAME_MPLUS_HEADER"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontsize_mplus_header", label=FONT_SIZE, value=14, default=14, min=3, max=34, step=1, slots=1 },
    { type="color",  cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontcolor_mplus_header", label=COLOR, value={0.165, 0.980, 0.710, 1}, default={0.165, 0.980, 0.710, 1}, slots=1 },
    { type="divider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="font",   cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontname_mplus_title", label=L["FONT_NAME_MPLUS_TITLE"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontsize_mplus_title", label=FONT_SIZE, value=16, default=16, min=3, max=34, step=1, slots=1 },
    
    { type="divider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="font",   cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontname_mplus_key", label=L["FONT_NAME_MPLUS_KEY"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontsize_mplus_key", label=FONT_SIZE, value=10, default=10, min=3, max=34, step=1, slots=1 },
    
    { type="divider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="font",   cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontname_mplus_row", label=L["FONT_NAME_MPLUS_ROW"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-MPLUS", ver=bit.bor(CCS.RETAIL), key="fontsize_mplus_row", label=FONT_SIZE, value=14, default=14, min=3, max=34, step=1, slots=1 },
    ------------------
    -- Weekly Rewards
    ------------------
    { type="divider", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key=nil, label=L["HEADER_REWARDS"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="divider", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="checkbox", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="showm_mplusrewards", label=L["SHOW_M_MPLUS_REWARDS"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="showm_raidrewards", label=L["SHOW_M_RAID_REWARDS"], value=true, default=true, slots=1 },
    { type="checkbox", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="showm_worldrewards", label=L["SHOW_M_WORLD_REWARDS"], value=true, default=true, slots=1 },
    { type="divider", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="color", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="wc_bgcolor", label=L["WC_BGCOLOR"], value={0.2, 0, .3, 1}, default={0.2, 0, .3, 1}, slots=2 },
    { type="color", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="wc_ilvlbannercolor", label=L["WC_ILVLBANNERCOLOR"], value={0.64, 0.21, 0.93, .5}, default={0.64, 0.21, 0.93, .5}, slots=2 },
    { type="divider", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), slots=4 },
    
    -- Weekly Chest Objective (Top Line)
    { type="font",   cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontname_wc_obj", label=L["FONT_NAME_WC_OBJ"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontsize_wc_obj", label=FONT_SIZE, value=10, default=10, min=3, max=34, step=1, slots=2 },
    { type="color",  cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontcolor_wc_obj_incomplete", label=L["FONT_COLOR_WC_OBJI"], value={0.62, 0.62, 0.62, 1}, default={0.62, 0.62, 0.62, 1}, slots=2 },
    { type="color",  cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontcolor_wc_obj_complete", label=L["FONT_COLOR_WC_OBJC"], value={1,1,1,1}, default={1,1,1,1}, slots=2 },
    { type="divider", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), slots=4 },
    -- Weekly Chest Difficulty
    { type="font",   cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontname_wc_diff", label=L["FONT_NAME_WC_DIFF"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontsize_wc_diff", label=FONT_SIZE, value=10, default=10, min=3, max=34, step=1, slots=2 },
    { type="color",  cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontcolor_wc_diff_complete", label=L["FONT_COLOR_WC_DIFFC"], value={0.12, 1, 0, 1}, default={0.12, 1, 0, 1}, slots=2 },
    { type="divider", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), slots=4 },
    -- Weekly Chest Progress
    { type="font",   cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontname_wc_prog", label=L["FONT_NAME_WC_PROG"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontsize_wc_prog", label=FONT_SIZE, value=10, default=10, min=3, max=34, step=1, slots=2 },
    { type="color",  cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontcolor_wc_prog_incomplete", label=L["FONT_COLOR_WC_PROGI"], value={0.62, 0.62, 0.62, 1}, default={0.62, 0.62, 0.62, 1}, slots=2 },
    { type="color",  cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontcolor_wc_prog_complete", label=L["FONT_COLOR_WC_PROGC"], value={0.12, 1, 0, 1}, default={0.12, 1, 0, 1}, slots=2 },
    { type="divider", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), slots=4 },
    -- Weekly Chest Reward ILVL
    { type="font",   cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontname_wc_ilvl", label=L["FONT_NAME_WC_ILVL"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontsize_wc_ilvl", label=FONT_SIZE, value=20, default=20, min=3, max=34, step=1, slots=2 },
    { type="color",  cat="CHAR-REWARDS", ver=bit.bor(CCS.RETAIL), key="fontcolor_wc_ilvl", label=L["FONT_COLOR_WC_ILVL"], value={1,1,1,1}, default={1,1,1,1}, slots=2 },

    -- Raid Progress Module Font Settings
    { type="divider", cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), key=nil, label=L["HEADER_RAID_PROGRESS"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="divider", cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="color", cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), key="bgcolor_raid", label=L["RAID_BG_COLOR"], value={.12,.12,.12,1}, default={.12,.12,.12,1}, slots=4 },
    { type="font",   cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), key="fontname_raidtitle", label=L["FONT_NAME_RAID_TITLE"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), key="fontsize_raidtitle", label=L["FONT_SIZE_RAID_TITLE"], value=20, default=20, min=3, max=34, step=1, slots=2 },
    { type="font",   cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), key="fontname_raiddiff", label=L["FONT_NAME_RAID_DIFFICULTY"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), key="fontsize_raiddiff", label=L["FONT_SIZE_RAID_DIFFICULTY"], value=14, default=14, min=3, max=34, step=1, slots=2 },
	{ type="font",   cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), key="fontname_raidboss", label=L["FONT_NAME_RAID_BOSS"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), key="fontsize_raidboss", label=L["FONT_SIZE_RAID_BOSS"], value=14, default=14, min=3, max=34, step=1, slots=2 },
    { type="divider", cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="header", cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), key=nil, label=L["ON_CHARACTER_SHEET"], slots=4, color={1,1,1}, fontSize=16, fontOutline="THICKOUTLINE" },
    { type="divider", cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), slots=4 },
    { type="font",   cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), key="fontname_raid", label=L["FONT_NAME_RAID"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="CHAR-RAID", ver=bit.bor(CCS.RETAIL), key="fontsize_raid", label=L["FONT_SIZE_RAID"], value=11, default=11, min=3, max=34, step=1, slots=2 },

    -- Inspect Sheet Display Options
    { type="divider", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), slots=4 },
    { type="header", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key=nil, label=L["HEADER_INSPECT_DISPLAY"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="divider", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), slots=4 },
    { type="color", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="bgcolor_inspect", label=L["INSPECT_BG_COLOR"], value={0,0,0,0.89}, default={0,0,0,0.89}, slots=2 },
    { type="dropdown", cat="INSPECT-SHEET", ver=bit.bor(CCS.RETAIL), key="bgtype_inspect", label=L["INSPECT_BG_TYPE"], value="Default", default="Default", values={"Default", "Class", "Race", "Hide"}, slots=2 },

    { type="divider", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), slots=4 },    
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="showilvl_inspect", label=L["SHOW_ILVL_INSPECT"], value=true, default=true, slots=1 },
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="showenchants_inspect", label=L["SHOW_ENCHANTS_INSPECT"], value=true, default=true, slots=1 },
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="showgems_inspect", label=L["SHOW_GEMS_INSPECT"], value=true, default=true, slots=1 },
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="showenchantgemerrors_inspect", label=L["SHOW_ENCHANT_GEM_ERRORS"], value=true, default=true, slots=1 },
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="showitemcolor_inspect", label=L["SHOW_ITEM_COLOR_INSPECT"], value=true, default=true, slots=1 },
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="showmodel_inspect", label=L["SHOW_MODEL_INSPECT"], value=true, default=true, slots=1 },
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.RETAIL), key="showmythicplusscore_inspect", label=L["SHOW_MYTHIC_SCORE_INSPECT"], value=true, default=true, slots=1 },


    { type="divider", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), slots=4 },        
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="showilvl_inspect", label=L["SHOW_ITEMILVL_INSPECT"], value=true, default=true, slots=1 },
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="showitemname_inspect", label=L["SHOW_ITEMNAME_INSPECT"], value=true, default=true, slots=1 },
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="itemcolorwhite_inspect", label=L["ITEM_COLOR_WHITE_INSPECT"], value=false, default=false, slots=1 },
    { type="slider", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="itemnamelength_inspect", label=L["ITEMNAME_LENGTH_INSPECT"], value=75, default=75, min=1, max=75, step=1, slots=1 },

    { type="divider", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), slots=4 },    
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="showsetitems_inspect", label=L["SHOW_SET_ITEMS"], value=true, default=true, slots=1 },
    { type="color", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="setitemcolor_inspect", label=L["SET_ITEM_COLOR"], value={0.05,0.75,0.45,1}, default={0.05,0.75,0.45,1}, slots=1 },
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.ALL), key="showsetclasscolor_inspect", label=L["SHOW_SET_CLASS_COLOR"], value=true, default=true, slots=1 },

    { type="divider", cat="INSPECT-SHEET", ver=bit.bor(CCS.RETAIL), slots=4 },    
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.RETAIL), key="showitemupgrade_inspect", label=L["SHOW_ITEM_UPGRADE_INSPECT"], value=true, default=true, slots=1 },
    { type="color", cat="INSPECT-SHEET", ver=bit.bor(CCS.RETAIL), key="itemupgradecolor_inspect", label=L["ITEM_UPGRADE_COLOR_INSPECT"], value={0.98,0.60,0.36,1}, default={0.98,0.60,0.36,1}, slots=2 },
    { type="checkbox", cat="INSPECT-SHEET", ver=bit.bor(CCS.RETAIL), key="showilvl_spec_ontt", label=TARGET_TOOLTIP_OPTION, value=false, default=false, slots=1 },

    -- Inspect Font Settings
    { type="divider", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), slots=4 },
    { type="header", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key=nil, label=L["HEADER_INSPECT_FONT"], slots=4, color={1,1,1}, fontSize=20, fontOutline="THICKOUTLINE" },
    { type="divider", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), slots=4 },

    { type="font", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontname_nametitle_inspect", label=L["FONT_NAME_INSPECT_NAME"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2},
    { type="slider", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontsize_nametitle_inspect", label=FONT_SIZE, value=12, default=12, min=3, max=36, step=1, slots=1 },
    { type="color", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontcolor_nametitle_inspect", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },

    { type="font",   cat="INSPECT-FONT", ver=bit.bor(CCS.ALL),   key="fontname_levelclass_inspect", label=L["FONT_NAME_INSPECT_LEVELCLASS"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontsize_levelclass_inspect", label=FONT_SIZE, value=12, default=12, min=3, max=36, step=1, slots=2 },

    { type="font",   cat="INSPECT-FONT", ver=bit.bor(CCS.RETAIL),   key="fontname_inspect_mplus", label=L["FONT_NAME_INSPECT_MPLUS"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="INSPECT-FONT", ver=bit.bor(CCS.RETAIL), key="fontsize_inspect_mplus", label=FONT_SIZE, value=11, default=11, min=3, max=36, step=1, slots=2 },

    { type="font",   cat="INSPECT-FONT", ver=bit.bor(CCS.ALL),   key="fontname_inspect_ilvl", label=L["FONT_NAME_INSPECT_ILEVEL"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2 },
    { type="slider", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontsize_inspect_ilvl", label=FONT_SIZE, value=20, default=20, min=3, max=36, step=1, slots=2 },

    { type="font", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontname_enchant_inspect", label=L["FONT_NAME_INSPECT_ENCHANT"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2},
    { type="slider", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontsize_enchant_inspect", label=FONT_SIZE, value=10, default=10, min=3, max=36, step=1, slots=1 },
    { type="color", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontcolor_enchant_inspect", label=COLOR, value={0.1647, 0.9804, 0.7098, 1}, default={0.1647, 0.9804, 0.7098, 1}, slots=1 },

    { type="font", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontname_iilvl_inspect", label=L["FONT_NAME_INSPECT_ITEMILVL"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2},
    { type="slider", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontsize_iilvl_inspect", label=FONT_SIZE, value=10, default=10, min=3, max=36, step=1, slots=1 },
    { type="color", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontcolor_iilvl_inspect", label=COLOR, value={1,1,1,1}, default={1,1,1,1}, slots=1 },

    { type="font", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontname_iname_inspect", label=L["FONT_NAME_INSPECT_ITEMNAME"], value="Fonts\\FRIZQT__.TTF", default="Fonts\\FRIZQT__.TTF", slots=2},
    { type="slider", cat="INSPECT-FONT", ver=bit.bor(CCS.ALL), key="fontsize_iname_inspect", label=FONT_SIZE, value=12, default=12, min=3, max=36, step=1, slots=1 },

}

-- Alls fonts defined so we can look them up later.
CCS.fonts = {
    ["2002 (Korean)"] = "Fonts\\2002.TTF", -- BLIZ koKR
    ["Accidental Presidency"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Accidental Presidency.ttf",
    ["Anonymous Pro"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\AnonymousPro-Bold.ttf",
    ["Arial Narrow"] = "Fonts\\ARIALN.TTF", -- BLIZ
    ["AR Hei"] = "Fonts\\ARHei.TTF", -- Blizz zhCN
    ["AR Hei UHK Bold"] = "Fonts\\ARHEIUHK_BD.TTF", -- Blizz zhTW
    ["ARKai_C (Simplified Chinese)"] = "Fonts\\ARKai_C.ttf", -- BLIZ zhCN
    ["ARKai_T (Traditional Chinese)"] = "Fonts\\ARKai_T.ttf", -- BLIZ zhCN
    ["Avengeance"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Avengeance.ttf",
    ["Bazooka"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Bazooka.ttf",
    ["BHEI00M (Traditional Chinese)"] = "Fonts\\bHEI00M.ttf", -- BLIZ zhTW
    ["BL Hei"] = "Fonts\\BLEI00D.TTF", -- Bliz zhTW
    ["BKai Medium"] = "Fonts\\BKAI00M.TTF", -- Bliz zhTW    
    ["Bradley Gratis"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\BradleyGratis.ttf",
    ["Brave"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Brave.ttf",
    ["CaptainMarvel"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Danvers.ttf",
    ["Carlito"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Carlito-Regular.ttf",
    ["Crystal"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\CRYSRG__.TTF",
    ["DejaVu Sans Mono"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\DejaVuSansMono.ttf",
    ["Doris PP"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\DORISPP.TTF",
    ["El Messiri"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\ElMessiri-VariableFont_wght.ttf",
    ["Emblem"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Emblem.ttf",
    ["Enigmatic Unicode"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Enigma__2.TTF",
    ["Fira Mono"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\FiraMono-Regular.ttf",
    ["Fira Mono Medium"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\FiraMono-Medium.ttf",
    ["Fira Sans Condensed Heavy"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\FiraSansCondensed-Heavy.ttf",
    ["Fira Sans Condensed Medium"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\FiraSansCondensed-Medium.ttf",
    ["Fira Sans Heavy"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\FiraSans-Heavy.ttf",
    ["Fira Sans Medium"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\FiraSans-Medium.ttf",
    ["Fixedsys Excelsior 3.01"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\FSEX300.ttf",
    ["FORCED SQUARE"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\FORCED SQUARE.ttf",
    ["Friz Quadrata (Cyrillic)"] = "Fonts\\FRIZQT___CYR.TTF", -- BLIZ ruRU
    ["Friz Quadrata TT"] = "Fonts\\FRIZQT__.TTF", -- BLIZ
    ["Futura"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Futura Condensed.ttf",
    ["Harry P"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\HARRYP__.TTF",
    ["Korean Page Text"] = "Fonts\\K_PAGETEXT.TTF", -- Bliz koKR
    ["Liberation Sans"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\LiberationSans-Regular.ttf",
    ["Monofonto"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\MONOFONT.TTF",
    --["Morpheus"] = "Fonts\\MORPHEUS.TTF", -- BLIZ
    ["Morpheus"] = "Fonts\\MORPHEUS_CYR.TTF", -- Bliz ruRU    
    ["Mouse Memoirs"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Memoirs.ttf",
    ["New Walt Disney Font"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Walt.ttf",
    ["Noto Naskh Arabic"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\NotoNaskhArabic-Regular.ttf",
    ["Nueva Std Cond"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Nueva Std Cond.ttf",
    ["Oswald"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Oswald-Regular.ttf",
    ["Rebellion"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Rebellion.ttf",
    ["SF Diego Sans"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\SF Diego Sans.ttf",
    ["Star Jedi"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Jedi.ttf",
    ["Star Shield"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Shield.ttf",
    ["Skurri"] = "Fonts\\SKURRI.TTF", -- BLIZ
    ["TrashHand"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\TrashHand.TTF",
    ["Wakanda 4 Ever"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\Wakanda.ttf",
    ["White Rabbit"] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Fonts\\WHITRABT.TTF",
}

CCS.fontLabels = {
    ["2002 (Korean)"] = {
        enUS = "2002 (Korean)",
        koKR = "2002 글꼴",
        frFR = "2002 (coréen)",
        deDE = "2002 (Koreanisch)",
        zhCN = "2002（韩文）",
        esES = "2002 (coreano)",
        zhTW = "2002（韓文）",
        esMX = "2002 (coreano)",
        ruRU = "2002 (корейский)",
        ptBR = "2002 (coreano)",
        itIT = "2002 (coreano)",
    },
    ["Accidental Presidency"] = {
        enUS = "Accidental Presidency",
        koKR = "어센덴털 프레지던시",
        frFR = "Présidence Accidentelle",
        deDE = "Zufällige Präsidentschaft",
        zhCN = "意外总统体",
        esES = "Presidencia Accidental",
        zhTW = "意外總統體",
        esMX = "Presidencia Accidental",
        ruRU = "Случайное Президентство",
        ptBR = "Presidência Acidental",
        itIT = "Presidenza Accidentale",
    },
    ["Anonymous Pro"] = {
        enUS = "Anonymous Pro",
        koKR = "어노니머스 프로",
        frFR = "Anonymous Pro",
        deDE = "Anonymous Pro",
        zhCN = "匿名专业体",
        esES = "Anonymous Pro",
        zhTW = "匿名專業體",
        esMX = "Anonymous Pro",
        ruRU = "Anonymous Pro",
        ptBR = "Anonymous Pro",
        itIT = "Anonymous Pro",
    },
    ["AR Hei"] = {
        enUS = "AR Hei",
        koKR = "AR 헤이",
        frFR = "AR Hei",
        deDE = "AR Hei",
        zhCN = "雅黑",
        esES = "AR Hei",
        zhTW = "雅黑",
        esMX = "AR Hei",
        ruRU = "AR Хэй",
        ptBR = "AR Hei",
        itIT = "AR Hei",
    },

    ["AR Hei UHK Bold"] = {
        enUS = "AR Hei UHK Bold",
        koKR = "AR 헤이 UHK 볼드",
        frFR = "AR Hei UHK Gras",
        deDE = "AR Hei UHK Fett",
        zhCN = "雅黑加粗",
        esES = "AR Hei UHK Negrita",
        zhTW = "雅黑加粗",
        esMX = "AR Hei UHK Negrita",
        ruRU = "AR Хэй UHK Полужирный",
        ptBR = "AR Hei UHK Negrito",
        itIT = "AR Hei UHK Grassetto",
    },
    ["Arial Narrow"] = {
        enUS = "Arial Narrow",
        koKR = "에리얼 내로우",
        frFR = "Arial étroit",
        deDE = "Arial Schmal",
        zhCN = "窄体 Arial",
        esES = "Arial estrecha",
        zhTW = "窄體 Arial",
        esMX = "Arial estrecha",
        ruRU = "Arial Узкий",
        ptBR = "Arial Estreito",
        itIT = "Arial Stretto",
    },
    ["ARKai_C (Simplified Chinese)"] = {
        enUS = "ARKai_C (Simplified Chinese)",
        koKR = "ARKai_C (중국어 간체)",
        frFR = "ARKai_C (chinois simplifié)",
        deDE = "ARKai_C (vereinfachtes Chinesisch)",
        zhCN = "ARKai_C（简体中文）",
        esES = "ARKai_C (chino simplificado)",
        zhTW = "ARKai_C（簡體中文）",
        esMX = "ARKai_C (chino simplificado)",
        ruRU = "ARKai_C (упрощенный китайский)",
        ptBR = "ARKai_C (chinês simplificado)",
        itIT = "ARKai_C (cinese semplificato)",
    },
    ["ARKai_T (Traditional Chinese)"] = {
        enUS = "ARKai_T (Traditional Chinese)",
        koKR = "ARKai_T (중국어 번체)",
        frFR = "ARKai_T (chinois traditionnel)",
        deDE = "ARKai_T (traditionelles Chinesisch)",
        zhCN = "ARKai_T（繁体中文）",
        zhTW = "ARKai_T（繁體中文）",
        esES = "ARKai_T (chino tradicional)",
        esMX = "ARKai_T (chino tradicional)",
        ruRU = "ARKai_T (традиционный китайский)",
        ptBR = "ARKai_T (chinês tradicional)",
        itIT = "ARKai_T (cinese tradizionale)",
    },
    ["Avengeance"] = {
        enUS = "Avengeance",
        koKR = "어벤전스",
        frFR = "Vengeance",
        deDE = "Vergeltung",
        zhCN = "复仇者体",
        esES = "Venganza",
        zhTW = "復仇者體",
        esMX = "Venganza",
        ruRU = "Месть",
        ptBR = "Vingança",
        itIT = "Vendetta",
    },
    ["Bazooka"] = {
        enUS = "Bazooka",
        koKR = "바주카",
        frFR = "Bazooka",
        deDE = "Bazooka",
        zhCN = "火箭筒体",
        esES = "Bazooka",
        zhTW = "火箭筒體",
        esMX = "Bazooka",
        ruRU = "Базука",
        ptBR = "Bazuca",
        itIT = "Bazooka",
    },
    ["BHEI00M (Traditional Chinese)"] = {
        enUS = "BHEI00M (Traditional Chinese)",
        koKR = "BHEI00M (중국어 번체)",
        frFR = "BHEI00M (chinois traditionnel)",
        deDE = "BHEI00M (traditionelles Chinesisch)",
        zhCN = "BHEI00M（繁体中文）",
        zhTW = "BHEI00M（繁體中文）",
        esES = "BHEI00M (chino tradicional)",
        esMX = "BHEI00M (chino tradicional)",
        ruRU = "BHEI00M (традиционный китайский)",
        ptBR = "BHEI00M (chinês tradicional)",
        itIT = "BHEI00M (cinese tradizionale)",
    },
    ["BL Hei"] = {
        enUS = "BL Hei",
        koKR = "BL 헤이",
        frFR = "BL Hei",
        deDE = "BL Hei",
        zhCN = "BL 黑",
        esES = "BL Hei",
        zhTW = "BL 黑",
        esMX = "BL Hei",
        ruRU = "BL Хэй",
        ptBR = "BL Hei",
        itIT = "BL Hei",
    },

    ["BKai Medium"] = {
        enUS = "BKai Medium",
        koKR = "BKai 미디엄",
        frFR = "BKai Moyen",
        deDE = "BKai Mittel",
        zhCN = "标楷体",
        esES = "BKai Medio",
        zhTW = "標楷體",
        esMX = "BKai Medio",
        ruRU = "BKai Средний",
        ptBR = "BKai Médio",
        itIT = "BKai Medio",
    },    
    ["Bradley Gratis"] = {
        enUS = "Bradley Gratis",
        koKR = "브래들리 그라티스",
        frFR = "Bradley Gratuit",
        deDE = "Bradley Kostenlos",
        zhCN = "布拉德利免费体",
        esES = "Bradley Gratis",
        zhTW = "布拉德利免費體",
        esMX = "Bradley Gratis",
        ruRU = "Bradley Бесплатный",
        ptBR = "Bradley Grátis",
        itIT = "Bradley Gratis",
    },
    ["Brave"] = {
        enUS = "Brave",
        koKR = "브레이브",
        frFR = "Brave",
        deDE = "Tapfer",
        zhCN = "勇敢体",
        esES = "Valiente",
        zhTW = "勇敢體",
        esMX = "Valiente",
        ruRU = "Храбрый",
        ptBR = "Bravo",
        itIT = "Coraggioso",
    },
    ["CaptainMarvel"] = {
        enUS = "CaptainMarvel",
        koKR = "캡틴마블",
        frFR = "Captain Marvel",
        deDE = "Captain Marvel",
        zhCN = "惊奇队长体",
        esES = "Capitana Marvel",
        zhTW = "驚奇隊長體",
        esMX = "Capitana Marvel",
        ruRU = "Капитан Марвел",
        ptBR = "Capitã Marvel",
        itIT = "Capitan Marvel",
    },
    ["Carlito"] = {
        enUS = "Carlito",
        koKR = "카를리토",
        frFR = "Carlito",
        deDE = "Carlito",
        zhCN = "卡利托体",
        esES = "Carlito",
        zhTW = "卡利托體",
        esMX = "Carlito",
        ruRU = "Карлито",
        ptBR = "Carlito",
        itIT = "Carlito",
    },
    ["Crystal"] = {
        enUS = "Crystal",
        koKR = "크리스탈",
        frFR = "Cristal",
        deDE = "Kristall",
        zhCN = "水晶体",
        esES = "Cristal",
        zhTW = "水晶體",
        esMX = "Cristal",
        ruRU = "Кристалл",
        ptBR = "Cristal",
        itIT = "Cristallo",
    },
    ["DejaVu Sans Mono"] = {
        enUS = "DejaVu Sans Mono",
        koKR = "데자뷰 산스 모노",
        frFR = "DejaVu Sans Mono",
        deDE = "DejaVu Sans Mono",
        zhCN = "DejaVu 等宽体",
        esES = "DejaVu Sans Mono",
        zhTW = "DejaVu 等寬體",
        esMX = "DejaVu Sans Mono",
        ruRU = "DejaVu Моно",
        ptBR = "DejaVu Sans Mono",
        itIT = "DejaVu Sans Mono",
    },
    ["Doris PP"] = {
        enUS = "Doris PP",
        koKR = "도리스 PP",
        frFR = "Doris PP",
        deDE = "Doris PP",
        zhCN = "多丽丝 PP",
        esES = "Doris PP",
        zhTW = "多麗絲 PP",
        esMX = "Doris PP",
        ruRU = "Дорис PP",
        ptBR = "Doris PP",
        itIT = "Doris PP",
    },
    ["El Messiri"] = {
        enUS = "El Messiri",
        koKR = "엘 메시리",
        frFR = "El Messiri",
        deDE = "El Messiri",
        zhCN = "埃尔·梅西里体",
        esES = "El Messiri",
        zhTW = "埃爾·梅西里體",
        esMX = "El Messiri",
        ruRU = "Эль Мессири",
        ptBR = "El Messiri",
        itIT = "El Messiri",
    },
    ["Emblem"] = {
        enUS = "Emblem",
        koKR = "엠블럼",
        frFR = "Emblème",
        deDE = "Emblem",
        zhCN = "徽章体",
        esES = "Emblema",
        zhTW = "徽章體",
        esMX = "Emblema",
        ruRU = "Эмблема",
        ptBR = "Emblema",
        itIT = "Emblema",
    },
    ["Enigmatic Unicode"] = {
        enUS = "Enigmatic Unicode",
        koKR = "에니그매틱 유니코드",
        frFR = "Unicode énigmatique",
        deDE = "Rätselhafter Unicode",
        zhCN = "神秘 Unicode",
        esES = "Unicode enigmático",
        zhTW = "神秘 Unicode",
        esMX = "Unicode enigmático",
        ruRU = "Загадочный Unicode",
        ptBR = "Unicode enigmático",
        itIT = "Unicode enigmatico",
    },
    ["Fira Mono"] = {
        enUS = "Fira Mono",
        koKR = "피라 모노",
        frFR = "Fira Mono",
        deDE = "Fira Mono",
        zhCN = "Fira 等宽体",
        esES = "Fira Mono",
        zhTW = "Fira 等寬體",
        esMX = "Fira Mono",
        ruRU = "Fira Моно",
        ptBR = "Fira Mono",
        itIT = "Fira Mono",
    },
    ["Fira Mono Medium"] = {
        enUS = "Fira Mono Medium",
        koKR = "피라 모노 미디엄",
        frFR = "Fira Mono Medium",
        deDE = "Fira Mono Medium",
        zhCN = "Fira 中等宽体",
        esES = "Fira Mono Medium",
        zhTW = "Fira 中等寬體",
        esMX = "Fira Mono Medium",
        ruRU = "Fira Моно Средний",
        ptBR = "Fira Mono Médio",
        itIT = "Fira Mono Medio",
    },
    ["Fira Sans Condensed Heavy"] = {
        enUS = "Fira Sans Condensed Heavy",
        koKR = "피라 산스 압축 헤비",
        frFR = "Fira Sans Condensé Gras",
        deDE = "Fira Sans Komprimiert Fett",
        zhCN = "Fira Sans 压缩粗体",
        esES = "Fira Sans Condensado Negrita",
        zhTW = "Fira Sans 壓縮粗體",
        esMX = "Fira Sans Condensado Negrita",
        ruRU = "Fira Sans Сжатый Жирный",
        ptBR = "Fira Sans Condensado Pesado",
        itIT = "Fira Sans Compresso Grassetto",
    },
    ["Fira Sans Condensed Medium"] = {
        enUS = "Fira Sans Condensed Medium",
        koKR = "피라 산스 압축 미디엄",
        frFR = "Fira Sans Condensé Moyen",
        deDE = "Fira Sans Komprimiert Mittel",
        zhCN = "Fira Sans 压缩中等体",
        esES = "Fira Sans Condensado Medio",
        zhTW = "Fira Sans 壓縮中等體",
        esMX = "Fira Sans Condensado Medio",
        ruRU = "Fira Sans Сжатый Средний",
        ptBR = "Fira Sans Condensado Médio",
        itIT = "Fira Sans Compresso Medio",
    },
    ["Fira Sans Heavy"] = {
        enUS = "Fira Sans Heavy",
        koKR = "피라 산스 헤비",
        frFR = "Fira Sans Gras",
        deDE = "Fira Sans Fett",
        zhCN = "Fira Sans 粗体",
        esES = "Fira Sans Negrita",
        zhTW = "Fira Sans 粗體",
        esMX = "Fira Sans Negrita",
        ruRU = "Fira Sans Жирный",
        ptBR = "Fira Sans Pesado",
        itIT = "Fira Sans Grassetto",
    },
    ["Fira Sans Medium"] = {
        enUS = "Fira Sans Medium",
        koKR = "피라 산스 미디엄",
        frFR = "Fira Sans Moyen",
        deDE = "Fira Sans Mittel",
        zhCN = "Fira Sans 中等体",
        esES = "Fira Sans Medio",
        zhTW = "Fira Sans 中等體",
        esMX = "Fira Sans Medio",
        ruRU = "Fira Sans Средний",
        ptBR = "Fira Sans Médio",
        itIT = "Fira Sans Medio",
    },
    ["Fixedsys Excelsior 3.01"] = {
        enUS = "Fixedsys Excelsior 3.01",
        koKR = "픽스드시스 엑셀시오르 3.01",
        frFR = "Fixedsys Excelsior 3.01",
        deDE = "Fixedsys Excelsior 3.01",
        zhCN = "固定系统卓越体 3.01",
        esES = "Fixedsys Excelsior 3.01",
        zhTW = "固定系統卓越體 3.01",
        esMX = "Fixedsys Excelsior 3.01",
        ruRU = "Fixedsys Excelsior 3.01",
        ptBR = "Fixedsys Excelsior 3.01",
        itIT = "Fixedsys Excelsior 3.01",
    },
    ["FORCED SQUARE"] = {
        enUS = "FORCED SQUARE",
        koKR = "포스드 스퀘어",
        frFR = "Carré Forcé",
        deDE = "Erzwungenes Quadrat",
        zhCN = "强制方块体",
        esES = "Cuadrado Forzado",
        zhTW = "強制方塊體",
        esMX = "Cuadrado Forzado",
        ruRU = "Принудительный квадрат",
        ptBR = "Quadrado Forçado",
        itIT = "Quadrato Forzato",
    },
    ["Friz Quadrata (Cyrillic)"] = {
        enUS = "Friz Quadrata (Cyrillic)",
        koKR = "Friz Quadrata (키릴 문자)",
        frFR = "Friz Quadrata (cyrillique)",
        deDE = "Friz Quadrata (kyrillisch)",
        zhCN = "Friz Quadrata（西里尔文）",
        zhTW = "Friz Quadrata（西里爾文）",
        esES = "Friz Quadrata (cirílico)",
        esMX = "Friz Quadrata (cirílico)",
        ruRU = "Friz Quadrata (кириллица)",
        ptBR = "Friz Quadrata (cirílico)",
        itIT = "Friz Quadrata (cirillico)",
    },
    ["Friz Quadrata TT"] = {
        enUS = "Friz Quadrata TT",
        koKR = "Friz Quadrata TT",
        frFR = "Friz Quadrata TT",
        deDE = "Friz Quadrata TT",
        zhCN = "Friz Quadrata TT",
        zhTW = "Friz Quadrata TT",
        esES = "Friz Quadrata TT",
        esMX = "Friz Quadrata TT",
        ruRU = "Friz Quadrata TT",
        ptBR = "Friz Quadrata TT",
        itIT = "Friz Quadrata TT",
    },
    ["Futura"] = {
        enUS = "Futura",
        koKR = "퓨처라",
        frFR = "Futura",
        deDE = "Futura",
        zhCN = "未来体",
        esES = "Futura",
        zhTW = "未來體",
        esMX = "Futura",
        ruRU = "Футура",
        ptBR = "Futura",
        itIT = "Futura",
    },
    ["Harry P"] = {
        enUS = "Harry P",
        koKR = "해리 P",
        frFR = "Harry P",
        deDE = "Harry P",
        zhCN = "哈利 P",
        esES = "Harry P",
        zhTW = "哈利 P",
        esMX = "Harry P",
        ruRU = "Гарри P",
        ptBR = "Harry P",
        itIT = "Harry P",
    },
    ["Korean Page Text"] = {
        enUS = "Korean Page Text",
        koKR = "페이지 텍스트",
        frFR = "Texte de Page Coréen",
        deDE = "Koreanischer Seitentext",
        zhCN = "韩文页面文字",
        esES = "Texto de Página Coreano",
        zhTW = "韓文頁面文字",
        esMX = "Texto de Página Coreano",
        ruRU = "Корейский текст страницы",
        ptBR = "Texto de Página Coreano",
        itIT = "Testo di Pagina Coreano",
    },    
    ["Liberation Sans"] = {
        enUS = "Liberation Sans",
        koKR = "리버레이션 산스",
        frFR = "Liberation Sans",
        deDE = "Liberation Sans",
        zhCN = "解放 Sans",
        esES = "Liberation Sans",
        zhTW = "解放 Sans",
        esMX = "Liberation Sans",
        ruRU = "Liberation Sans",
        ptBR = "Liberation Sans",
        itIT = "Liberation Sans",
    },
    ["Monofonto"] = {
        enUS = "Monofonto",
        koKR = "모노폰토",
        frFR = "Monofonto",
        deDE = "Monofonto",
        zhCN = "单宽字体 Monofonto",
        esES = "Monofonto",
        zhTW = "單寬字體 Monofonto",
        esMX = "Monofonto",
        ruRU = "Monofonto",
        ptBR = "Monofonto",
        itIT = "Monofonto",
    },
    ["Morpheus"] = {
        enUS = "Morpheus",
        koKR = "모피어스",
        frFR = "Morphée",
        deDE = "Morpheus",
        zhCN = "莫菲斯",
        esES = "Morfeo",
        zhTW = "莫菲斯",
        esMX = "Morfeo",
        ruRU = "Морфей",
        ptBR = "Morpheus",
        itIT = "Morpheus",
    },
    ["Morpheus (Cyrillic)"] = {
        enUS = "Morpheus (Cyrillic)",
        koKR = "모피어스 (키릴문자)",
        frFR = "Morphée (Cyrillique)",
        deDE = "Morpheus (Kyrillisch)",
        zhCN = "莫菲斯 (西里尔字母)",
        esES = "Morfeo (Cirílico)",
        zhTW = "莫菲斯 (西里爾文)",
        esMX = "Morfeo (Cirílico)",
        ruRU = "Морфей (кириллица)",
        ptBR = "Morpheus (Cirílico)",
        itIT = "Morpheus (Cirillico)",
    },    
    ["Mouse Memoirs"] = {
        enUS = "Mouse Memoirs",
        koKR = "마우스 메모리즈",
        frFR = "Souvenirs de Souris",
        deDE = "Maus-Erinnerungen",
        zhCN = "鼠标回忆录",
        esES = "Memorias del Ratón",
        zhTW = "滑鼠回憶錄",
        esMX = "Memorias del Ratón",
        ruRU = "Мышиные мемуары",
        ptBR = "Memórias do Rato",
        itIT = "Memorie del Topo",
    },
    ["New Walt Disney Font"] = {
        enUS = "New Walt Disney Font",
        koKR = "뉴 월트 디즈니 폰트",
        frFR = "Nouvelle Police Walt Disney",
        deDE = "Neue Walt Disney Schriftart",
        zhCN = "新迪士尼字体",
        esES = "Nueva Fuente Walt Disney",
        zhTW = "新迪士尼字型",
        esMX = "Nueva Fuente Walt Disney",
        ruRU = "Новый шрифт Диснея",
        ptBR = "Nova Fonte Walt Disney",
        itIT = "Nuovo Font Walt Disney",
    },
    ["Noto Naskh Arabic"] = {
        enUS = "Noto Naskh Arabic",
        koKR = "노토 나스크 아랍어",
        frFR = "Noto Naskh Arabe",
        deDE = "Noto Naskh Arabisch",
        zhCN = "Noto Naskh 阿拉伯文",
        esES = "Noto Naskh Árabe",
        zhTW = "Noto Naskh 阿拉伯文",
        esMX = "Noto Naskh Árabe",
        ruRU = "Noto Naskh Арабский",
        ptBR = "Noto Naskh Árabe",
        itIT = "Noto Naskh Arabo",
    },
    ["Nueva Std Cond"] = {
        enUS = "Nueva Std Cond",
        koKR = "누에바 스탠다드 콘덴스드",
        frFR = "Nueva Std Condensé",
        deDE = "Nueva Std Komprimiert",
        zhCN = "Nueva 标准压缩体",
        esES = "Nueva Std Condensado",
        zhTW = "Nueva 標準壓縮體",
        esMX = "Nueva Std Condensado",
        ruRU = "Nueva Стандарт Сжатый",
        ptBR = "Nueva Std Condensado",
        itIT = "Nueva Std Compresso",
    },
    ["Oswald"] = {
        enUS = "Oswald",
        koKR = "오스왈드",
        frFR = "Oswald",
        deDE = "Oswald",
        zhCN = "奥斯瓦尔德体",
        esES = "Oswald",
        zhTW = "奧斯瓦爾德體",
        esMX = "Oswald",
        ruRU = "Освальд",
        ptBR = "Oswald",
        itIT = "Oswald",
    },
    ["Rebellion"] = {
        enUS = "Rebellion",
        koKR = "리벨리온",
        frFR = "Rébellion",
        deDE = "Rebellion",
        zhCN = "叛逆体",
        esES = "Rebelión",
        zhTW = "叛逆體",
        esMX = "Rebelión",
        ruRU = "Мятеж",
        ptBR = "Rebelião",
        itIT = "Ribellione",
    },
    ["SF Diego Sans"] = {
        enUS = "SF Diego Sans",
        koKR = "SF 디에고 산스",
        frFR = "SF Diego Sans",
        deDE = "SF Diego Sans",
        zhCN = "SF 迭戈无衬线体",
        esES = "SF Diego Sans",
        zhTW = "SF 迭戈無襯線體",
        esMX = "SF Diego Sans",
        ruRU = "SF Диего Санс",
        ptBR = "SF Diego Sans",
        itIT = "SF Diego Sans",
    },
    ["Star Jedi"] = {
        enUS = "Star Jedi",
        koKR = "스타 제다이",
        frFR = "Star Jedi",
        deDE = "Star Jedi",
        zhCN = "星际绝地体",
        esES = "Star Jedi",
        zhTW = "星際絕地體",
        esMX = "Star Jedi",
        ruRU = "Звёздный Джедай",
        ptBR = "Star Jedi",
        itIT = "Star Jedi",
    },
    ["Star Shield"] = {
        enUS = "Star Shield",
        koKR = "스타 실드",
        frFR = "Bouclier Stellaire",
        deDE = "Sternenschild",
        zhCN = "星盾体",
        esES = "Escudo Estelar",
        zhTW = "星盾體",
        esMX = "Escudo Estelar",
        ruRU = "Звёздный Щит",
        ptBR = "Escudo Estelar",
        itIT = "Scudo Stellare",
    },
    ["Skurri"] = {
        enUS = "Skurri",
        koKR = "스커리",
        frFR = "Skurri",
        deDE = "Skurri",
        zhCN = "斯库里体",
        esES = "Skurri",
        zhTW = "斯庫里體",
        esMX = "Skurri",
        ruRU = "Скурри",
        ptBR = "Skurri",
        itIT = "Skurri",
    },
    ["TrashHand"] = {
        enUS = "TrashHand",
        koKR = "트래시핸드",
        frFR = "TrashHand",
        deDE = "TrashHand",
        zhCN = "手写垃圾体",
        esES = "TrashHand",
        zhTW = "手寫垃圾體",
        esMX = "TrashHand",
        ruRU = "ТрэшХэнд",
        ptBR = "TrashHand",
        itIT = "TrashHand",
    },
    ["Wakanda 4 Ever"] = {
        enUS = "Wakanda 4 Ever",
        koKR = "와칸다 포에버",
        frFR = "Wakanda pour toujours",
        deDE = "Wakanda für immer",
        zhCN = "瓦坎达永存体",
        esES = "Wakanda por siempre",
        zhTW = "瓦坎達永存體",
        esMX = "Wakanda por siempre",
        ruRU = "Ваканда навсегда",
        ptBR = "Wakanda para sempre",
        itIT = "Wakanda per sempre",
    },
    ["White Rabbit"] = {
        enUS = "White Rabbit",
        koKR = "화이트 래빗",
        frFR = "Lapin Blanc",
        deDE = "Weißes Kaninchen",
        zhCN = "白兔体",
        esES = "Conejo Blanco",
        zhTW = "白兔體",
        esMX = "Conejo Blanco",
        ruRU = "Белый Кролик",
        ptBR = "Coelho Branco",
        itIT = "Coniglio Bianco",
    },
}

-- Build reverse lookup: path → localized label
CCS.fontPathsLocalized = {}

for label, path in pairs(CCS.fonts) do
    local localized = CCS.fontLabels[label] and CCS.fontLabels[label][locale] or label
    CCS.fontPathsLocalized[path] = localized
end

--/dump LibStub("LibSharedMedia-3.0"):List("font")[x] for each entry
--/dump LibStub("LibSharedMedia-3.0"):Fetch("font", LibStub("LibSharedMedia-3.0"):List("font")[1])
local LSM = LibStub("LibSharedMedia-3.0")

if LSM then
    for label, path in pairs(CCS.fonts) do
        LSM:Register("font", CCS.fontPathsLocalized[path], path)
    end
end


-- Key is Paragon Quest ID
CCS.Paragon_Factions = {
    --Legion
    [48976] = { factionID = 2170},-- Argussian Reach
    [46777] = { factionID = 2045},-- Armies of Legionfall
    [48977] = { factionID = 2165},-- Army of the Light
    [46745] = { factionID = 1900},-- Court of Farondis
    [46747] = { factionID = 1883},-- Dreamweavers
    [46743] = { factionID = 1828},-- Highmountain Tribes
    [46748] = { factionID = 1859},-- The Nightfallen
    [46749] = { factionID = 1894},-- The Wardens
    [46746] = { factionID = 1948},-- Valarjar
    --Battle for Azeroth
    [54453] = { factionID = 2164},--Champions of Azeroth
    [58096] = { factionID = 2415},--Rajani
    [55348] = { factionID = 2391},--Rustbolt Resistance
    [54451] = { factionID = 2163},--Tortollan Seekers
    [58097] = { factionID = 2417},--Uldum Accord
    [54460] = { factionID = 2156},--Talanji's Expedition
    [54455] = { factionID = 2157},--The Honorbound
    [53982] = { factionID = 2373},--The Unshackled
    [54461] = { factionID = 2158},--Voldunai
    [54462] = { factionID = 2103},--Zandalari Empire
    [54456] = { factionID = 2161},--Order of Embers
    [54458] = { factionID = 2160},--Proudmoore Admiralty
    [54457] = { factionID = 2162},--Storm's Wake
    [54454] = { factionID = 2159},--The 7th Legion
    [55976] = { factionID = 2400},--Waveblade Ankoan
    --Shadowlands
    [61100] = { factionID = 2413},--Court of Harvesters
    [64012] = { factionID = 2470},--Death's Advance
    [64266] = { factionID = 2472},--The Archivist's Codex
    [61097] = { factionID = 2407},--The Ascended
    [64867] = { factionID = 2478},--The Enlightened
    [61095] = { factionID = 2410},--The Undying Army
    [61098] = { factionID = 2465},--The Wild Hunt
    [64267] = { factionID = 2432},--Ve'nari
    -- Dragonflight
    [65606] = { factionID = 2503},-- Maruuk Centaur
    [66156] = { factionID = 2507},-- Dragonscale Expedition
    [71023] = { factionID = 2510},-- Valdrakken Accord
    [66511] = { factionID = 2511},-- Iskaara Tuskarr
    [75290] = { factionID = 2564},-- Loamm Niffen    
    [76425] = { factionID = 2574},-- Dream Wardens
    -- The War Within
    [79219] = { factionID = 2590},-- Council of Dornogal
    [79218] = { factionID = 2570},-- Hallowfall Arathi
    [79220] = { factionID = 2594},-- The Assembly of the Deeps
    [79196] = { factionID = 2600},-- The Severed Threads
    [79196] = { factionID = 2736},-- Manaforge Vandals
}

CCS.GemInfo = {
    [136256]  = { text = EMPTY_SOCKET_BLUE, gtype = CCS.GEM_PRISMATIC},
    [407324]  = { text = EMPTY_SOCKET_COGWHEEL, gtype = CCS.GEM_COGWHEEL},
    [4624650]  = { text = EMPTY_SOCKET_TINKER, gtype = CCS.GEM_COGWHEEL},
    [4624651]  = { text = EMPTY_SOCKET_TINKER, gtype = CCS.GEM_COGWHEEL},
    [4624652]  = { text = EMPTY_SOCKET_TINKER, gtype = CCS.GEM_COGWHEEL},
    [4624653]  = { text = EMPTY_SOCKET_TINKER, gtype = CCS.GEM_COGWHEEL},
    [4624654]  = { text = EMPTY_SOCKET_TINKER, gtype = CCS.GEM_COGWHEEL},
    [4624655]  = { text = EMPTY_SOCKET_TINKER, gtype = CCS.GEM_COGWHEEL},
    [4095404] = { text = EMPTY_SOCKET_DOMINATION, gtype = CCS.GEM_DOMINATION},
    [407325]  = { text = EMPTY_SOCKET_HYDRAULIC, gtype = CCS.GEM_HYDRAULIC},
    [136257]  = { text = EMPTY_SOCKET_META, gtype = CCS.GEM_META},
    [458977]  = { text = EMPTY_SOCKET_PRISMATIC, gtype = CCS.GEM_PRISMATIC},
    [2958629] = { text = EMPTY_SOCKET_PUNCHCARDBLUE, gtype = CCS.GEM_PUNCHCARDBLUE},
    [2958630] = { text = EMPTY_SOCKET_TINKER, gtype = CCS.GEM_PUNCHCARDRED},
    [2958631] = { text = EMPTY_SOCKET_PUNCHCARDYELLOW, gtype = CCS.GEM_PUNCHCARDYELLOW},
    [136258]  = { text = EMPTY_SOCKET_RED, gtype = CCS.GEM_PRISMATIC},
    [136259]  = { text = EMPTY_SOCKET_YELLOW, gtype = CCS.GEM_PRISMATIC},    
}    

CCS.Class_Bg = {
    [1] = { -- Warrior
        [1] = { name = "Arms", texture = "Interface\\TalentFrame\\TalentsClassBackgroundWarrior1", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Fury", texture = "Interface\\TalentFrame\\TalentsClassBackgroundWarrior1", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Protection", texture = "Interface\\TalentFrame\\TalentsClassBackgroundWarrior2", map = {1612, 774, 0.000488281, 0.787598, 0.000976562, 0.756836} },
    },
    [2] = { -- Paladin
        [1] = { name = "Holy", texture = "Interface\\TalentFrame\\TalentsClassBackgroundPaladin1", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Protection", texture = "Interface\\TalentFrame\\TalentsClassBackgroundPaladin1", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Retribution", texture = "Interface\\TalentFrame\\TalentsClassBackgroundPaladin2", map = {1612, 774, 0.000488281, 0.787598, 0.000976562, 0.756836} },
    },
    [3] = { -- Hunter
        [1] = { name = "Beast Mastery", texture = "Interface\\TalentFrame\\TalentsClassBackgroundHunter1", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Marksmanship", texture = "Interface\\TalentFrame\\TalentsClassBackgroundHunter1", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Survival", texture = "Interface\\TalentFrame\\TalentsClassBackgroundHunter2", map = {1612, 774, 0.000488281, 0.787598, 0.000976562, 0.756836} },
    },
    [4] = { -- Rogue
        [1] = { name = "Assassination", texture = "Interface\\TalentFrame\\TalentsClassBackgroundRogue1", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Outlaw", texture = "Interface\\TalentFrame\\TalentsClassBackgroundRogue1", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Subtlety", texture = "Interface\\TalentFrame\\TalentsClassBackgroundRogue2", map = {1612, 774, 0.000488281, 0.787598, 0.000976562, 0.756836} },
    },
    [5] = { -- Priest
        [1] = { name = "Discipline", texture = "Interface\\TalentFrame\\TalentsClassBackgroundPriest1", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Holy", texture = "Interface\\TalentFrame\\TalentsClassBackgroundPriest1", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Shadow", texture = "Interface\\TalentFrame\\TalentsClassBackgroundPriest2", map = {1612, 774, 0.000488281, 0.787598, 0.000976562, 0.756836} },
    },
    [6] = { -- Death Knight
        [1] = { name = "Blood", texture = "Interface\\TalentFrame\\TalentsClassBackgroundDeathKnight1", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Frost", texture = "Interface\\TalentFrame\\TalentsClassBackgroundDeathKnight1", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Unholy", texture = "Interface\\TalentFrame\\TalentsClassBackgroundDeathKnight2", map = {1612, 774, 0.000488281, 0.787598, 0.000976562, 0.756836} },
    },
    [7] = { -- Shaman
        [1] = { name = "Elemental", texture = "Interface\\TalentFrame\\TalentsClassBackgroundShaman1", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Enhancement", texture = "Interface\\TalentFrame\\TalentsClassBackgroundShaman1", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Restoration", texture = "Interface\\TalentFrame\\TalentsClassBackgroundShaman2", map = {1612, 774, 0.000488281, 0.787598, 0.000976562, 0.756836} },
    },
    [8] = { -- Mage
        [1] = { name = "Arcane", texture = "Interface\\TalentFrame\\TalentsClassBackgroundMage1", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Fire", texture = "Interface\\TalentFrame\\TalentsClassBackgroundMage1", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Frost", texture = "Interface\\TalentFrame\\TalentsClassBackgroundMage2", map = {1612, 774, 0.000488281, 0.787598, 0.000976562, 0.756836} },
    },
    [9] = { -- Warlock
        [1] = { name = "Affliction", texture = "Interface\\TalentFrame\\TalentsClassBackgroundWarlock1", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Demonology", texture = "Interface\\TalentFrame\\TalentsClassBackgroundWarlock1", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Destruction", texture = "Interface\\TalentFrame\\TalentsClassBackgroundWarlock2", map = {1612, 774, 0.000488281, 0.787598, 0.000976562, 0.756836} },
    },
    [10] = { -- Monk
        [1] = { name = "Brewmaster", texture = "Interface\\TalentFrame\\TalentsClassBackgroundMonk1", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Mistweaver", texture = "Interface\\TalentFrame\\TalentsClassBackgroundMonk1", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Windwalker", texture = "Interface\\TalentFrame\\TalentsClassBackgroundMonk2", map = {1612, 774, 0.000488281, 0.787598, 0.000976562, 0.756836} },
    },
    [11] = { -- Druid
        [1] = { name = "Balance", texture = "Interface\\TalentFrame\\TalentsClassBackgroundDruid1", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Feral", texture = "Interface\\TalentFrame\\TalentsClassBackgroundDruid1", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Guardian", texture = "Interface\\TalentFrame\\TalentsClassBackgroundDruid2", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [4] = { name = "Restoration", texture = "Interface\\TalentFrame\\TalentsClassBackgroundDruid2", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
    },
    [12] = { -- Demon Hunter
        [1] = { name = "Havoc", texture = "Interface\\TalentFrame\\TalentsClassBackgroundDemonHunter", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Vengeance", texture = "Interface\\TalentFrame\\TalentsClassBackgroundDemonHunter", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
    },
    [13] = { -- Evoker
        [1] = { name = "Devastation", texture = "Interface\\TalentFrame\\TalentsClassBackgroundEvoker", map = {1612, 774, 0.000488281, 0.787598, 0.000488281, 0.378418} },
        [2] = { name = "Preservation", texture = "Interface\\TalentFrame\\TalentsClassBackgroundEvoker", map = {1612, 774, 0.000488281, 0.787598, 0.379395, 0.757324} },
        [3] = { name = "Augmentation", texture = "Interface\\TalentFrame\\TalentsClassBackgroundEvoker2", map = {1612, 774, 0.000488281, 0.787598, 0.000976562, 0.756836} },
    },
}

CCS.Race_Bg = {
    [1] = { -- Human
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones2",
        map     = {1022, 664, 0.000488281, 0.499512, 0.650879, 0.975098},
    },
    [2] = { -- Orc
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones3",
        map     = {1022, 664, 0.500488, 0.999512, 0.650879, 0.975098},
    },
    [3] = { -- Dwarf
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones2",
        map     = {1022, 664, 0.000488281, 0.499512, 0.000488281, 0.324707},
    },
    [4] = { -- Night Elf
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones3",
        map     = {1022, 664, 0.000488281, 0.499512, 0.650879, 0.975098},
    },
    [5] = { -- Undead (Scourge)
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones4",
        map     = {1022, 664, 0.500488, 0.999512, 0.325684, 0.649902},
    },
    [6] = { -- Tauren
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones4",
        map     = {1022, 664, 0.500488, 0.999512, 0.000488281, 0.324707},
    },
    [7] = { -- Gnome
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones2",
        map     = {1022, 664, 0.500488, 0.999512, 0.000488281, 0.324707},
    },
    [8] = { -- Troll
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones4",
        map     = {1022, 664, 0.000488281, 0.499512, 0.325684, 0.649902},
    },
    [9] = { -- Goblin
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones2",
        map     = {1022, 664, 0.000488281, 0.499512, 0.325684, 0.649902},
    },
    [10] = { -- Blood Elf
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones1",
        map     = {1022, 664, 0.000488281, 0.499512, 0.000488281, 0.324707},
    },
    [11] = { -- Draenei
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones1",
        map     = {1022, 664, 0.500488, 0.999512, 0.650879, 0.975098},
    },
    [22] = { -- Worgen
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones5",
        map     = {1022, 664, 0.000488281, 0.999512, 0.000488281, 0.324707},
    },
    [24] = { -- Pandaren
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones4",
        map     = {1022, 664, 0.000488281, 0.499512, 0.000488281, 0.324707},
    },
    [27] = { -- Nightborne
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones3",
        map     = {1022, 664, 0.500488, 0.999512, 0.325684, 0.649902},
    },
    [28] = { -- Highmountain Tauren
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones2",
        map     = {1022, 664, 0.500488, 0.999512, 0.325684, 0.649902},
    },
    [29] = { -- Void Elf
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones4",
        map     = {1022, 664, 0.000488281, 0.499512, 0.650879, 0.975098},
    },
    [30] = { -- Lightforged Draenei
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones3",
        map     = {1022, 664, 0.000488281, 0.499512, 0.000488281, 0.324707},
    },
    [31] = { -- Zandalari Troll
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones5",
        map     = {1022, 664, 0.000488281, 0.999512, 0.325684, 0.649902},
    },
    [32] = { -- Kul Tiran
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones2",
        map     = {1022, 664, 0.500488, 0.999512, 0.650879, 0.975098},
    },
    [34] = { -- Dark Iron Dwarf
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones1",
        map     = {1022, 664, 0.500488, 0.999512, 0.000488281, 0.324707},
    },
    [35] = { -- Vulpera
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones4",
        map     = {1022, 664, 0.500488, 0.999512, 0.650879, 0.975098},
    },
    [36] = { -- Mag'har Orc
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones3",
        map     = {1022, 664, 0.500488, 0.999512, 0.000488281, 0.324707},
    },
    [37] = { -- Mechagnome
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones3",
        map     = {1022, 664, 0.000488281, 0.499512, 0.325684, 0.649902},
    },
    [52] = { -- Dracthyr (Alliance) [Placeholder]
        texture = "Interface\\DRESSUPFRAME\\DressUpBackground-Dracthyr1",
        map     = {512, 512, 0, 1, 0, 1},
    },
    [70] = { -- Dracthyr (Horde) [Placeholder]
        texture = "Interface\\DRESSUPFRAME\\DressUpBackground-Dracthyr1",
        map     = {512, 512, 0, 1, 0, 1},
    },
    [84] = { -- Earthen (Horde) 
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones5",
        map     = {1022, 664, 0.000488281, 0.999512, 0.650879, 0.975098},
    },
    [85] = { -- Earthen (Alliance) 
        texture = "Interface\\Glues\\CharacterCreate\\CharacterCreateStartingZones5",
        map     = {1022, 664, 0.000488281, 0.999512, 0.650879, 0.975098},
    },
    [998] = { -- Death Knight
        texture = "Interface\\Glues\\Models\\UI_DeathKnight\\UI_Deathknight_LowRes",
        map     = {1024, 512, 0, 1, 0, 1},
    },
    [999] = { -- Demon Hunter
        texture = "Interface\\Glues\\Models\\UI_DemonHunter\\UI_DemonHunter_LowRes",
        map     = {1024, 512, 0, 1, 0, 1},
    },
}

CCS.Dungeon_Teleports = {
    -- [mapID]= {spellID = xxxxxx}, 
    [2]=   { spellID = 131204},    --  Temple of the Jade Serpent
    [56]=  { spellID = 131205},    --  Stormstout Brewery
    [57]=  { spellID = 131225},    --  Gate of the Setting Sun
    [58]=  { spellID = 131206},    --  Shado-Pan Monastery
    [59]=  { spellID = 131228},    --  Siege of Niuzao Temple
    [60]=  { spellID = 131222},    --  Mogu'shan Palace
    [76]=  { spellID = 131232},    --  Scholomance
    [77]=  { spellID = 131231},    --  Scarlet Halls
    [78]=  { spellID = 131229},    --  Scarlet Monastery
    [161]= { spellID = 159898},    --  Skyreach
    [163]= { spellID = 159895},    --  Bloodmaul Slag Mines
    [164]= { spellID = 159897},    --  Auchindoun
    [165]= { spellID = 159899},    --  Shadowmoon Burial Grounds
    [166]= { spellID = 159900},    --  Grimrail Depot
    [167]= { spellID = 159902},    --  Upper Blackrock Spire
    [168]= { spellID = 159901},    --  The Everbloom
    [169]= { spellID = 159896},    --  Iron Docks
    [197]= { spellID = 0},        --  Eye of Azshara
    [198]= { spellID = 424163},    --  Darkheart Thicket
    [199]= { spellID = 424153},    --  Black Rook Hold
    [200]= { spellID = 393764},    --  Halls of Valor
    [206]= { spellID = 410078},    --  Neltharion's Lair
    [207]= { spellID = 0},        --  Vault of the Wardens
    [208]= { spellID = 0},        --  Maw of Souls
    [209]= { spellID = 0},        --  The Arcway
    [210]= { spellID = 393766},    --  Court of Stars
    [227]= { spellID = 373262},    --  Return to Karazhan: Lower
    [233]= { spellID = 0},        --  Cathedral of Eternal Night
    [234]= { spellID = 373262},    --  Return to Karazhan: Upper
    [239]= { spellID = 1254551},        --  Seat of the Triumvirate
    -- Battle for Azeroth
    [244]= { spellID = 424187},    --  Atal'Dazar
    [245]= { spellID = 410071},    --  Freehold
    [246]= { spellID = 0},        --  Tol Dagor
    [247]= { spellID = 467553},        --  The MOTHERLODE!!
    [247]= { spellID = 467555},        --  The MOTHERLODE!!
    [248]= { spellID = 424167},    --  Waycrest Manor
    [249]= { spellID = 0},        --  Kings' Rest
    [250]= { spellID = 0},        --  Temple of Sethraliss
    [251]= { spellID = 410074},    --  The Underrot
    [252]= { spellID = 0},        --  Shrine of the Storm
    [353]= { spellID = 445418},    --  Siege of Boralus (Alliance)
    [353]= { spellID = 464256},    --  Siege of Boralus (Horde)
    [369]= { spellID = 373274},     --  Operation: Mechagon - Junkyard
    [370]= { spellID = 373274},    --  Operation: Mechagon - Workshop
    -- Shadowlands
    [375]= { spellID = 354464},    --  Mists of Tirna Scithe
    [376]= { spellID = 354462},    --  The Necrotic Wake
    [377]= { spellID = 354468},    --  De Other Side
    [378]= { spellID = 354465},    --  Halls of Atonement
    [379]= { spellID = 354463},    --  Plaguefall
    [380]= { spellID = 354469},    --  Sanguine Depths
    [381]= { spellID = 354466},    --  Spires of Ascension
    [382]= { spellID = 354467},    --  Theater of Pain
    [391]= { spellID = 367416},    --  Tazavesh: Streets of Wonder
    [392]= { spellID = 367416},    --  Tazavesh: So'leah's Gambit
    -- Dragonflight
    [399]= { spellID = 393256},    --  Ruby Life Pools
    [400]= { spellID = 393262},    --  The Nokhud Offensive
    [401]= { spellID = 393279},    --  The Azure Vault
    [402]= { spellID = 393273},    --  Algeth'ar Academy
    [403]= { spellID = 393222},    --  Uldaman: Legacy of Tyr
    [404]= { spellID = 393276},    --  Neltharus
    [405]= { spellID = 393267},    --  Brackenhide Hollow
    [406]= { spellID = 393283},    --  Halls of Infusion
    [438]= { spellID = 410080},    --  The Vortex Pinnacle
    [456]= { spellID = 424142},    --  Throne of the Tides
    [463]= { spellID = 424197},    --  Dawn of the Infinite: Galakrond's Fall
    [464]= { spellID = 424197},    --  Dawn of the Infinite: Murozond's Rise
    -- The War Within
    [499]= { spellID = 445444},    --  Priory of the Sacred Flame
    [500]= { spellID = 445443},    --  The Rookery
    [501]= { spellID = 445269},    --  The Stonevault
    [502]= { spellID = 445416},    --  City of Threads
    [503]= { spellID = 445417},    --  Ara-kara, City of Echoes
    [504]= { spellID = 445441},    --  Darkflame Cleft
    [505]= { spellID = 445414},    --  The Dawnbreaker
    [506]= { spellID = 445440},    --  Cinderbrew Meadery
    [507]= { spellID = 445424},    --  Grim Batol
    [525]= { spellID = 1216786},   --  Operation: Floodgate    
    [542]= { spellID = 1237215},   --  Eco-Dome Al'dani
    -- Midnight
    [556]= { spellID = 1254555}, -- Pit of Saron
    [557]= { spellID = 1254400}, -- Windrunner Spire
    [558]= { spellID = 1254572}, -- Magister's Terrace
    [559]= { spellID = 1254563}, -- Nexus Point Xenas
    [560]= { spellID = 1254559}, -- Maisara Caverns
    --Placeholder for: Den of Nalorakk
    --Placeholder for:Murder Row
    --Placeholder for:The Blinding Vale
    --Placeholder for:Voidscar Arena
    
}

CCS.RAID_DIFFICULTY_COLORS ={
    [1] = { 0.12, 1.00, 0.00, 'ff1eff00' }, 
    [2] = { 0.00, 0.44, 0.87, 'ff0070dd' },
    [3] = { 0.64, 0.21, 0.93, 'ffa335ee' }
}

CCS.RAID_DIFFICULTY_NAMES = {
    [1] = PLAYER_DIFFICULTY1, -- Normal
    [2] = PLAYER_DIFFICULTY2, -- Heroic
    [3] = PLAYER_DIFFICULTY6  -- Mythic
}

if CCS.GetCurrentVersion() == CCS.RETAIL then

CCS.SRI = { 
    -- Liberation of Undermine C_Map.GetMapInfo(2406).name
    [1] = { boss=2639, raid=2406, name = select(1, EJ_GetEncounterInfo(2639)), icon = select(5, EJ_GetCreatureInfo(1, 2639)), normal=41300, heroic=41301, mythic=41302}, -- Vexie and the Geargrinders
    [2] = { boss=2640, raid=2406, name = select(1, EJ_GetEncounterInfo(2640)), icon = select(5, EJ_GetCreatureInfo(1, 2640)), normal=41304, heroic=41305, mythic=41306}, -- Cauldrons of Carnage
    [3] = { boss=2641, raid=2406, name = select(1, EJ_GetEncounterInfo(2641)), icon = select(5, EJ_GetCreatureInfo(1, 2641)), normal=41308, heroic=41309, mythic=41310}, -- Rik Reverb
    [4] = { boss=2642, raid=2406, name = select(1, EJ_GetEncounterInfo(2642)), icon = select(5, EJ_GetCreatureInfo(1, 2642)), normal=41312, heroic=41313, mythic=41314}, -- Stix Bunkjunker
    [5] = { boss=2643, raid=2406, name = select(1, EJ_GetEncounterInfo(2653)), icon = select(5, EJ_GetCreatureInfo(1, 2653)), normal=41316, heroic=41317, mythic=41318}, -- Sprocketmonger Lockenstock
    [6] = { boss=2644, raid=2406, name = select(1, EJ_GetEncounterInfo(2644)), icon = select(5, EJ_GetCreatureInfo(1, 2644)), normal=41320, heroic=41321, mythic=41322}, -- The One-Armed Bandit
    [7] = { boss=2645, raid=2406, name = select(1, EJ_GetEncounterInfo(2645)), icon = select(5, EJ_GetCreatureInfo(1, 2645)), normal=41324, heroic=41325, mythic=41326}, -- Mug'Zee, Heads of Security
    [8] = { boss=2646, raid=2406, name = select(1, EJ_GetEncounterInfo(2646)), icon = select(5, EJ_GetCreatureInfo(1, 2646)), normal=41328, heroic=41329, mythic=41330}, -- Chrome King Gallywix
    
    -- Manaforge Omega C_Map.GetMapInfo(2460).name
    [11] = { boss=2684, raid=2460, name = select(1, EJ_GetEncounterInfo(2684)), icon = select(5, EJ_GetCreatureInfo(1, 2684)), normal=41634, heroic=41635, mythic=41636}, -- Plexus Sentinel
    [12] = { boss=2686, raid=2460, name = select(1, EJ_GetEncounterInfo(2686)), icon = select(5, EJ_GetCreatureInfo(1, 2686)), normal=41638, heroic=41639, mythic=41640}, -- Loom'ithar 
    [13] = { boss=2685, raid=2460, name = select(1, EJ_GetEncounterInfo(2685)), icon = select(5, EJ_GetCreatureInfo(1, 2685)), normal=41642, heroic=41643, mythic=41644}, -- Soulbinder Naazindhri
    [14] = { boss=2687, raid=2460, name = select(1, EJ_GetEncounterInfo(2687)), icon = select(5, EJ_GetCreatureInfo(1, 2687)), normal=41646, heroic=41647, mythic=41648}, -- Forgeweaver Araz
    [15] = { boss=2688, raid=2460, name = select(1, EJ_GetEncounterInfo(2688)), icon = select(5, EJ_GetCreatureInfo(1, 2688)), normal=41650, heroic=41651, mythic=41652}, -- The Soul Hunters
    [16] = { boss=2747, raid=2460, name = select(1, EJ_GetEncounterInfo(2747)), icon = select(5, EJ_GetCreatureInfo(1, 2747)), normal=41654, heroic=41655, mythic=41656}, -- Fractillus
    [17] = { boss=2690, raid=2460, name = select(1, EJ_GetEncounterInfo(2690)), icon = select(5, EJ_GetCreatureInfo(1, 2690)), normal=41658, heroic=41659, mythic=41660}, -- Nexus-King Salhadaar
    [18] = { boss=2691, raid=2460, name = select(1, EJ_GetEncounterInfo(2691)), icon = select(5, EJ_GetCreatureInfo(1, 2691)), normal=41662, heroic=41663, mythic=41664}, -- Dimensiue, the All-Devouring

  -- Midnight Season 1 Raids
  -- The Dreamrift C_Map.GetMapInfo(2531).name
    [21] = { boss=2795, raid=2531, name = select(1, EJ_GetEncounterInfo(2795)), icon = select(5, EJ_GetCreatureInfo(1, 2795)), normal=61475, heroic=61476, mythic=61477 }, -- Chimaerus the Undreamt God
  -- The VoidSpire C_Map.GetMapInfo(2529).name
    [22] = { boss=2733, raid=2529, name = select(1, EJ_GetEncounterInfo(2733)), icon = select(5, EJ_GetCreatureInfo(1, 2733)), normal=61277, heroic=61278, mythic=61279 }, -- Imperator Averzian
    [23] = { boss=2734, raid=2529, name = select(1, EJ_GetEncounterInfo(2734)), icon = select(5, EJ_GetCreatureInfo(1, 2734)), normal=61281, heroic=61282, mythic=61283 }, -- Vorasius
    [24] = { boss=2736, raid=2529, name = select(1, EJ_GetEncounterInfo(2736)), icon = select(5, EJ_GetCreatureInfo(1, 2736)), normal=61285, heroic=61286, mythic=61287 }, -- Fallen-King Salhadaar
    [25] = { boss=2735, raid=2529, name = select(1, EJ_GetEncounterInfo(2735)), icon = select(5, EJ_GetCreatureInfo(1, 2735)), normal=61289, heroic=61290, mythic=61291 }, -- Vaelgor & Ezzorak
    [26] = { boss=2737, raid=2529, name = select(1, EJ_GetEncounterInfo(2737)), icon = select(5, EJ_GetCreatureInfo(1, 2737)), normal=61293, heroic=61294, mythic=61295 }, -- Lightblinded Vanguard
    [27] = { boss=2738, raid=2529, name = select(1, EJ_GetEncounterInfo(2738)), icon = select(5, EJ_GetCreatureInfo(1, 2738)), normal=61297, heroic=61298, mythic=61299 }, -- Crown of the Cosmos
  -- March on Quel'Danas C_Map.GetMapInfo(2533).name
    [28] = { boss=2739, raid=2533, name = select(1, EJ_GetEncounterInfo(2739)), icon = select(5, EJ_GetCreatureInfo(1, 2739)), normal=61301, heroic=61302, mythic=61303 }, -- Belo'ren, Child of Al'ar
    [29] = { boss=2740, raid=2533, name = select(1, EJ_GetEncounterInfo(2740)), icon = select(5, EJ_GetCreatureInfo(1, 2740)), normal=61305, heroic=61306, mythic=61307 }, -- Midnight Falls
    
}

CCS.RaidLayout = {
  {
    raid = 2406, -- Liberation of Undermine
    num_bosses = 8,
    tocinfo = {110100, 110200},
    shortname = "LoU",
    title = C_Map.GetMapInfo(2406).name,
    bosses = { 1, 2, 3, 4, 5, 6, 7, 8 }
  },
  {
    raid = 2460, -- Manaforge Omega
    num_bosses = 8,
    tocinfo = {110200, 110300},
    shortname = "MFO",
    title = C_Map.GetMapInfo(2460).name,
    bosses = { 11, 12, 13, 14, 15, 16, 17, 18 }
  },
  {
    raid = 2531, -- The Dreamrift C_Map.GetMapInfo(2531).name
    num_bosses = 1,
    tocinfo = {120000, 120100},
    shortname = "DR",
    title = (C_Map.GetMapInfo(2531) and C_Map.GetMapInfo(2531).name) or "Unknown",
    bosses = { 21 }
  },
  {
    raid = 2529, -- The VoidSpire C_Map.GetMapInfo(2529).name
    num_bosses = 6,
    tocinfo = {120000, 120100},
    shortname = "VS",
    title = (C_Map.GetMapInfo(2529) and C_Map.GetMapInfo(2529).name) or "Unknown",
    bosses = { 22, 23, 24, 25, 26, 27 }
  },
  {
    raid = 2533,-- March on Quel'Danas C_Map.GetMapInfo(2533).name
    num_bosses = 2,
    tocinfo = {120000, 120100},
    shortname = "MOQD",    
    title = (C_Map.GetMapInfo(2533) and C_Map.GetMapInfo(2533).name) or "Unknown",
    bosses = { 28, 29 }
  },
}

end


CCS.POWER_TYPES_TABLE = {
    [0] = POWER_TYPE_MANA, -- Mana
    [1] = POWER_TYPE_RED_POWER, -- Rage
    [2] = POWER_TYPE_FOCUS, -- Focus
    [3] = POWER_TYPE_ENERGY, -- Energy
    [4] = COMBO_POINTS_POWER, -- Combo Points
    [5] = RUNES, -- Runes
    [6] = POWER_TYPE_RUNIC_POWER, -- Runic Power
    [7] = SOUL_SHARDS_POWER, -- Soul Shards
    [8] = POWER_TYPE_LUNAR_POWER, -- Lunar Power
    [9] = HOLY_POWER, -- Holy Power
    [10] = POWER_TYPE_POWER, -- Alternate
    [11] = POWER_TYPE_MAELSTROM, -- Maelstrom
    [12] = CHI, -- Chi
    [13] = POWER_TYPE_INSANITY, -- Insanity
    [14] = POWER_TYPE_POWER, -- OBSOLETE
    [15] = POWER_TYPE_POWER, -- OBSOLETE
    [16] = POWER_TYPE_ARCANE_CHARGES, -- Arcane Charges
    [17] = POWER_TYPE_FURY, -- Fury
    [18] = POWER_TYPE_PAIN, -- Pain
    [19] = POWER_TYPE_ESSENCE -- essence
};

CCS.rarityHexColors = {
    [0] = "9d9d9d", -- Poor
    [1] = "ffffff", -- Common
    [2] = "1eff00", -- Uncommon
    [3] = "0070dd", -- Rare
    [4] = "a335ee", -- Epic
    [5] = "ff8000", -- Legendary
    [6] = "e6cc80", -- Artifact
    [7] = "00ccff", -- Heirloom
    [8] = "00e6e6", -- WoW Token
}

CCS.slotNames = {
    [1] = "Head",
    [2] = "Neck",
    [3] = "Shoulder",
    [5] = "Chest",
    [6] = "Waist",
    [7] = "Legs",
    [8] = "Feet",
    [9] = "Wrist",
    [10] = "Hands",
    [11] = "Finger0",
    [12] = "Finger1",
    [13] = "Trinket0",
    [14] = "Trinket1",
    [15] = "Back",
    [16] = "MainHand",
    [17] = "SecondaryHand",
}

CCS.embellishmentBonus = {
    [222868] = { stat = "CRIT_RATING", value = 756 },
    [222869] = { stat = "CRIT_RATING", value = 756 },
    [222870] = { stat = "CRIT_RATING", value = 756 },
    [222871] = { stat = "VERSATILITY", value = 756 },
    [222872] = { stat = "VERSATILITY", value = 756 },
    [222873] = { stat = "VERSATILITY", value = 756 },
}

CCS.enchantLookup = {
    -- The War Within
    [7353] = { { stat="AGILITY" , value=360 } }, --Stormrider's Agility |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7354] = { { stat="AGILITY" , value=440 } }, --Stormrider's Agility |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7355] = { { stat="AGILITY" , value=520 } }, --Stormrider's Agility |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    [7356] = { { stat="INTELLECT" , value=360 } }, --Council's Intellect |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7357] = { { stat="INTELLECT" , value=440 } }, --Council's Intellect |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7358] = { { stat="INTELLECT" , value=520 } }, --Council's Intellect |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    [7359] = { { stat="STRENGTH" , value=360 } }, --Oathsworn's Strength |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7360] = { { stat="STRENGTH" , value=440 } }, --Oathsworn's Strength |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7361] = { { stat="STRENGTH" , value=520 } }, --Oathsworn's Strength |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    [7362] = { { stat="STRENGTH" , value=520 }, { stat="AGILITY" , value=520 }, { stat="INTELLECT" , value=520 } }, --Crystalline Radiance |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7363] = { { stat="STRENGTH" , value=630 }, { stat="AGILITY" , value=630 }, { stat="INTELLECT" , value=630 } }, --Crystalline Radiance |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7364] = { { stat="STRENGTH" , value=745 }, { stat="AGILITY" , value=745 }, { stat="INTELLECT" , value=745 } }, --Crystalline Radiance |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    [7422] = { { stat="STAMINA" , value=625 } }, --Defender's March |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7423] = { { stat="STAMINA" , value=760 } }, --Defender's March |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7424] = { { stat="STAMINA" , value=895 } }, --Defender's March |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    [7468] = { { stat="CRIT_RATING" , value=270 }, { stat="HASTE_RATING" , value=-80 } }, --Cursed Critical Strike 1
    [7469] = { { stat="CRIT_RATING" , value=335 }, { stat="HASTE_RATING" , value=-100 } }, --Cursed Critical Strike 2
    [7470] = { { stat="CRIT_RATING" , value=390 }, { stat="HASTE_RATING" , value=-115 } }, --Cursed Critical Strike 3
    [7471] = { { stat="HASTE_RATING" , value=270 }, { stat="VERSATILITY" , value=-80 } }, --Cursed Haste 1
    [7472] = { { stat="HASTE_RATING" , value=335 }, { stat="VERSATILITY" , value=-100 } }, --Cursed Haste 2
    [7473] = { { stat="HASTE_RATING" , value=390 }, { stat="VERSATILITY" , value=-115 } }, --Cursed Haste 3
    [7474] = { { stat="VERSATILITY" , value=270 }, { stat="MASTERY_RATING" , value=-80 } }, --Cursed Versatility 1
    [7475] = { { stat="VERSATILITY" , value=335 }, { stat="MASTERY_RATING" , value=-100 } }, --Cursed Versatility 2
    [7476] = { { stat="VERSATILITY" , value=390 }, { stat="MASTERY_RATING" , value=-115 } }, --Cursed Versatility 3
    [7477] = { { stat="MASTERY_RATING" , value=270 }, { stat="CRIT_RATING" , value=-80 } }, --Cursed Mastery 1
    [7478] = { { stat="MASTERY_RATING" , value=335 }, { stat="CRIT_RATING" , value=-100 } }, --Cursed Mastery 2
    [7479] = { { stat="MASTERY_RATING" , value=390 }, { stat="CRIT_RATING" , value=-115 } }, --Cursed Mastery 3
    [7529] = { { stat="INTELLECT" , value=650 } }, --Daybreak Spellthread |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7530] = { { stat="INTELLECT" , value=790 } }, --Daybreak Spellthread |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7531] = { { stat="INTELLECT" , value=930 } }, --Daybreak Spellthread |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    [7532] = { { stat="INTELLECT" , value=650 }, { stat="STAMINA" , value=625 } }, --Sunset Spellthread |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7533] = { { stat="INTELLECT" , value=790 }, { stat="STAMINA" , value=760 } }, --Sunset Spellthread |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7534] = { { stat="INTELLECT" , value=930 }, { stat="STAMINA" , value=895 } }, --Sunset Spellthread |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    [7535] = { { stat="INTELLECT" , value=430 } }, --Weavercloth Spellthread |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7536] = { { stat="INTELLECT" , value=525 } }, --Weavercloth Spellthread |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7537] = { { stat="INTELLECT" , value=620 } }, --Weavercloth Spellthread |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    [7593] = { { stat="STRENGTH" , value=650 }, { stat="AGILITY" , value=650 } }, --Defender's Armor Kit |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7594] = { { stat="STRENGTH" , value=790 }, { stat="AGILITY" , value=790 } }, --Defender's Armor Kit |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7595] = { { stat="STRENGTH" , value=930 }, { stat="AGILITY" , value=930 } }, --Defender's Armor Kit |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    [7596] = { { stat="STRENGTH" , value=430 }, { stat="AGILITY" , value=430 } }, --Dual Layered Armor Kit |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7597] = { { stat="STRENGTH" , value=525 }, { stat="AGILITY" , value=525 } }, --Dual Layered Armor Kit |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7598] = { { stat="STRENGTH" , value=620 }, { stat="AGILITY" , value=620 } }, --Dual Layered Armor Kit |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    [7599] = { { stat="STRENGTH" , value=650 }, { stat="AGILITY" , value=650 }, { stat="STAMINA" , value=625 } }, --Stormbound Armor Kit |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7600] = { { stat="STRENGTH" , value=790 }, { stat="AGILITY" , value=790 }, { stat="STAMINA" , value=760 } }, --Stormbound Armor Kit |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7601] = { { stat="STRENGTH" , value=930 }, { stat="AGILITY" , value=930 }, { stat="STAMINA" , value=895 } }, --Stormbound Armor Kit |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    [7652] = { { stat="STRENGTH" , value=585 }, { stat="AGILITY" , value=585 }, { stat="INTELLECT" , value=585 }, { stat="STAMINA" , value=562 } }, --Charged Armor Kit |A:Professions-ChatIcon-Quality-Tier1:20:20|a
    [7653] = { { stat="STRENGTH" , value=711 }, { stat="AGILITY" , value=711 }, { stat="INTELLECT" , value=711 }, { stat="STAMINA" , value=684 } }, --Charged Armor Kit |A:Professions-ChatIcon-Quality-Tier2:20:20|a
    [7654] = { { stat="STRENGTH" , value=837 }, { stat="AGILITY" , value=837 }, { stat="INTELLECT" , value=837 }, { stat="STAMINA" , value=805 } }, --Charged Armor Kit |A:Professions-ChatIcon-Quality-Tier3:20:20|a
    -- Midnight Chest
    [7956] = { { stat="STRENGTH" , value=32 }, { stat="STAMINA" , value=93 }}, --Enchant Chest - Mark of Nalorakk |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [7957] = { { stat="STRENGTH" , value=40 }, { stat="STAMINA" , value=116 }}, --Enchant Chest - Mark of Nalorakk |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [7984] = { { stat="AGILITY" , value=32 } }, --Enchant Chest - Mark of the Rootwarden |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [7985] = { { stat="AGILITY" , value=40 } }, --Enchant Chest - Mark of the Rootwarden |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [7986] = { { stat="STRENGTH" , value=36 }, { stat="AGILITY" , value=36 }, { stat="INTELLECT" , value=36  } }, --Enchant Chest - Mark of the Worldsoul |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [7987] = { { stat="STRENGTH" , value=50 }, { stat="AGILITY" , value=50 }, { stat="INTELLECT" , value=50  } }, --Enchant Chest - Mark of the Worldsoul |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [8012] = { { stat="INTELLECT" , value=32 } }, --Enchant Chest - Mark of the Magister |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [8013] = { { stat="INTELLECT" , value=40 } }, --Enchant Chest - Mark of the Magister |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    -- Midnight Boots
    [7962] = { { stat="STAMINA" , value=186 } }, --Enchant Boots - Lynx's Dexterity |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [7963] = { { stat="STAMINA" , value=232 } }, --Enchant Boots - Lynx's Dexterity |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [7992] = { { stat="STAMINA" , value=186 } }, --Enchant Boots - Shaladrassil's Roots |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [7993] = { { stat="STAMINA" , value=232 } }, --Enchant Boots - Shaladrassil's Roots |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [8018] = { { stat="STAMINA" , value=186 } }, --Enchant Boots - Farstrider's Hunt |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [8019] = { { stat="STAMINA" , value=232 } }, --Enchant Boots - Farstrider's Hunt |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    -- Midnight Rings
    [7964] = { { stat="MASTERY_RATING" , value=9 } }, --Enchant Ring - Amani Mastery |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [7965] = { { stat="MASTERY_RATING" , value=13 } }, --Enchant Ring - Amani Mastery |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [7968] = { { stat="MASTERY_RATING" , value=17 } }, --Enchant Ring - Zul'jins Mastery |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [7969] = { { stat="MASTERY_RATING" , value=22 } }, --Enchant Ring - Zul'jins Mastery |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [7994] = { { stat="CRIT_RATING" , value=9 } }, --Enchant Ring - Nature's Wrath |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [7995] = { { stat="CRIT_RATING" , value=13 } }, --Enchant Ring - Nature's Wrath |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [7996] = { { stat="CRIT_RATING" , value=17 } }, --Enchant Ring - Nature's Fury |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [7997] = { { stat="CRIT_RATING" , value=22 } }, --Enchant Ring - Nature's Fury |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [8020] = { { stat="HASTE_RATING" , value=9 } }, --Enchant Ring - Thalassian Haste |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [8021] = { { stat="HASTE_RATING" , value=13 } }, --Enchant Ring - Thalassian Haste |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [8022] = { { stat="VERSATILITY" , value=9 } }, --Enchant Ring - Thalassian Versatility |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [8023] = { { stat="VERSATILITY" , value=13 } }, --Enchant Ring - Thalassian Versatility |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [8024] = { { stat="HASTE_RATING" , value=17 } }, --Enchant Ring - Silvermoon's Alacrity |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [8025] = { { stat="HASTE_RATING" , value=22 } }, --Enchant Ring - Silvermoon's Alacrity |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
    [8026] = { { stat="VERSATILITY" , value=17 } }, --Enchant Ring - Silvermoon's Tenacity |A:Professions-ChatIcon-Quality-12-Tier1:20:20|a
    [8027] = { { stat="VERSATILITY" , value=22 } }, --Enchant Ring - Silvermoon's Tenacity |A:Professions-ChatIcon-Quality-12-Tier2:20:20|a
}

-- /dump UnitClass("player")
-- /dump PlayerUtil.GetCurrentSpecID()
-- /dump C_ClassTalents.GetActiveHeroTalentSpec()
-- /dump C_ClassTalents.GetHeroTalentSpecsForClassSpec()
CCS.ClassSpecStatPriority = {
    [6] = { -- Death Knight
        -- Blood {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [31] = {2,2,1,2}, -- San'layn
            [32] = {1,1,1,1}, --  *** Rider of the Apocalypse
            [33] = {2,1,3,2}, -- Deathbringer
        },
        -- Frost
        [2] = {
            [31] = {1,1,1,1}, --  *** San'layn
            [32] = {2,1,3,4}, -- Rider of the Apocalypse
            [33] = {2,1,3,4}, -- Deathbringer
        },
        -- Unholy
        [3] = {
            [31] = {1,2,3,4}, -- San'layn
            [32] = {1,2,3,4}, -- Rider of the Apocalypse
            [33] = {1,1,1,1}, -- *** Deathbringer
        },
    },
    [12] = { -- Demon Hunter
        -- Havoc {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [34] = {2,1,3,4}, -- Fel-Scarred
            [35] = {2,1,3,4}, -- Aldrachi Reaver
            [124] = {1,1,1,1}, -- *** Annihilator
        },
        -- Vengeance
        [2] = {
            [34] = {1,1,1,1}, -- *** Fel-Scarred
            [35] = {4,2,1,3}, -- Aldrachi Reaver
            [124] = {4,2,1,3}, -- Annihilator
        },
        -- Devourer
        [3] = {
            [34] = {1,1,1,1}, -- *** Fel-Scarred
            [35] = {1,1,1,1}, -- *** Aldrachi Reaver
            [124] = {2,3,1,4}, -- Annihilator
            [126] = {1,3,2,4}, -- Void-scarred
        },        
    },
    [11] = { -- Druid
        -- Balance {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [21] = {1,1,1,1}, -- *** Druid of the Claw
            [22] = {1,1,1,1}, -- *** Wildstalker
            [23] = {1,2,2,3}, -- Keeper of the Grove
            [24] = {1,3,2,4}, -- Elune's Chosen
        },
        -- Feral
        [2] = {
            [21] = {1,3,2,4}, -- Druid of the Claw
            [22] = {1,2,3,4}, -- Wildstalker
            [23] = {1,1,1,1}, -- *** Keeper of the Grove
            [24] = {1,1,1,1}, -- *** Elune's Chosen
        },
        -- Guardian
        [3] = {
            [21] = {4,3,1,2}, -- Druid of the Claw
            [22] = {1,1,1,1}, -- *** Wildstalker
            [23] = {1,1,1,1}, -- *** Keeper of the Grove
            [24] = {4,3,1,2}, -- Elune's Chosen
        },
        -- Restoration
        [4] = {
            [21] = {1,1,1,1}, -- *** Druid of the Claw
            [22] = {2,4,1,3}, -- Wildstalker
            [23] = {2,4,1,3}, -- Keeper of the Grove
            [24] = {1,1,1,1}, -- *** Elune's Chosen
        },
    },
    [13] = { -- Evoker
        -- Devastation {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [36] = {3,1,2,4}, -- Scalecommander
            [37] = {3,1,2,4}, -- Flameshaper
            [38] = {1,1,1,1}, -- *** Chronowarden
        },
        -- Preservation
        [2] = {
            [36] = {1,1,1,1}, -- *** Scalecommander
            [37] = {1,3,2,4}, -- Flameshaper
            [38] = {1,3,2,4}, -- Chronowarden
        },
        -- Augmentation
        [3] = {
            [36] = {3,1,2,4}, -- Scalecommander
            [37] = {1,1,1,1}, -- *** Flameshaper
            [38] = {3,1,2,4}, -- Chronowarden
        },
    },
    [3] = { -- Hunter
        -- Beast Mastery {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [42] = {1,1,1,1}, -- *** Sentinel
            [43] = {1,3,2,4}, -- Pack Leader
            [44] = {1,3,2,4}, -- Dark Ranger
        },
        -- Marksmanship
        [2] = {
            [42] = {2,1,4,3}, -- Sentinel
            [43] = {1,1,1,1}, -- *** Pack Leader
            [44] = {2,1,4,3}, -- Dark Ranger
        },
        -- Survival
        [3] = {
            [42] = {1,2,3,4}, -- Sentinel
            [43] = {1,2,2,3}, -- Pack Leader
            [44] = {1,1,1,1}, -- *** Dark Ranger ***
        },
    },
    [8] = { -- Mage
        -- Arcane {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [39] = {1,3,2,4}, -- Sunfury
            [40] = {1,3,2,4}, -- Spellslinger
            [41] = {1,1,1,1}, -- *** Frostfire
        },
        -- Fire
        [2] = {
            [39] = {2,4,1,3}, -- Sunfury
            [40] = {1,1,1,1}, -- *** Spellslinger
            [41] = {2,4,1,3}, -- Frostfire
        },
        -- Frost
        [3] = {
            [39] = {1,1,1,1}, -- *** Sunfury
            [40] = {1,2,3,4}, -- Spellslinger
            [41] = {1,2,3,4}, -- Frostfire
        },
    },
    [10] = { -- Monk
        -- Brewmaster {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [64] = {1,1,1,1}, -- *** Conduit of the Celestials
            [65] = {1,1,2,1}, -- Shado-pan
            [66] = {1,1,2,1}, -- Master of Harmony
        },
        -- Mistweaver
        [2] = {
            [64] = {4,2,1,3}, -- Conduit of the Celestials
            [65] = {1,1,1,1}, -- *** Shado-pan
            [66] = {4,2,1,3}, -- Master of Harmony
        },
        -- Windwalker
        [3] = {
            [64] = {2,3,1,4}, -- Conduit of the Celestials
            [65] = {3,2,1,4}, -- Shado-pan
            [66] = {1,1,1,1}, -- *** Master of Harmony
        },
    },
    [2] = { -- Paladin
        -- Holy {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [48] = {1,1,1,1}, -- *** Templar
            [49] = {1,2,2,3}, -- Lightsmith
            [50] = {1,2,2,3}, -- Herald of the Sun
        },
        -- Protection
        [2] = {
            [48] = {3,3,1,2}, -- Templar
            [49] = {3,3,1,2}, -- Lightsmith
            [50] = {1,1,1,1}, -- *** Herald of the Sun
        },
        -- Retribution
        [3] = {
            [48] = {1,2,3,4}, -- Templar
            [49] = {1,1,1,1}, -- *** Lightsmith
            [50] = {1,2,3,4}, -- Herald of the Sun
        },
    },
    [5] = { -- Priest
        -- Discipline {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [18] = {3,2,1,4}, -- Voidweaver
            [19] = {1,1,1,1}, -- *** Archon
            [20] = {3,2,1,4}, -- Oracle
        },
        -- Holy
        [2] = {
            [18] = {1,1,1,1}, -- *** Voidweaver
            [19] = {2,1,3,2}, -- Archon
            [20] = {2,1,3,2}, -- Oracle
        },
        -- Shadow
        [3] = {
            [18] = {2,3,1,4}, -- Voidweaver
            [19] = {2,3,1,4}, -- Archon
            [20] = {1,1,1,1}, -- *** Oracle
        },
    },
    [4] = { -- Rogue
        -- Assassination {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [51] = {1,1,1,1}, -- *** Trickster
            [52] = {3,1,2,4}, -- Fatebound
            [53] = {3,1,2,4}, -- Deathstalker
        },
        -- Outlaw
        [2] = {
            [51] = {4,2,1,3}, -- Trickster
            [52] = {4,2,1,3}, -- Fatebound
            [53] = {1,1,1,1}, -- *** Deathstalker
        },
        -- Subtlety
        [3] = {
            [51] = {1,3,2,4}, -- Trickster
            [52] = {1,1,1,1}, -- *** Fatebound
            [53] = {1,3,2,4}, -- Deathstalker
        },
    },
    [7] = { -- Shaman
        -- Elemental {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [54] = {1,1,1,1}, -- *** Totemic
            [55] = {1,2,2,3}, -- Stormbringer
            [56] = {1,2,2,3}, -- Farseer
        },
        -- Enhancement
        [2] = {
            [54] = {1,3,2,4}, -- Totemic
            [55] = {2,2,1,3}, -- Stormbringer
            [56] = {1,1,1,1}, -- *** Farseer
        },
        -- Restoration
        [3] = {
            [54] = {2,1,3,2}, -- Totemic
            [55] = {2,1,3,2}, -- *** Stormbringer
            [56] = {2,1,3,2}, -- Farseer
        },
    },
    [9] = { -- Warlock
        -- Affliction {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [57] = {1,1,2,3}, -- Soul Harvester
            [58] = {1,1,2,3}, -- Hellcaller
            [59] = {1,1,1,1}, -- *** Diabolist
        },
        -- Demonology
        [2] = {
            [57] = {2,1,1,3}, -- Soul Harvester
            [58] = {1,1,1,1}, -- *** Hellcaller
            [59] = {2,1,1,3}, -- Diabolist
        },
        -- Destruction
        [3] = {
            [57] = {1,1,1,1}, -- *** Soul Harvester
            [58] = {2,2,1,3}, -- Hellcaller
            [59] = {2,2,1,3}, -- Diabolist
        },
    },
    [1] = { -- Warrior
        -- Arms {"Mastery","CriticalStrike","Haste","Versatility"}
        [1] = {
            [60] = {3,1,2,4}, -- Slayer
            [61] = {1,1,1,1}, -- *** Mountain Thane
            [62] = {3,1,2,4}, -- Colossus
        },
        -- Fury
        [2] = {
            [60] = {2,3,1,4}, -- Slayer
            [61] = {2,3,1,4}, -- Mountain Thane
            [62] = {1,1,1,1}, -- *** Colossus
        },
        -- Protection
        [3] = {
            [60] = {1,1,1,1}, -- *** Slayer
            [61] = {4,2,1,3}, -- Mountain Thane
            [62] = {4,2,1,3}, -- Colossus
        },
    },
}


CCS.UpgradeTrackNames = {
    enUS = {
        ["Explorer"]   = {0.62, 0.62, 0.62, 1}, -- Grey
        ["Adventurer"] = {1.00, 1.00, 1.00, 1}, -- White
        ["Veteran"]    = {0.12, 1.00, 0.00, 1}, -- Green
        ["Champion"]   = {0.00, 0.44, 0.87, 1}, -- Blue
        ["Hero"]       = {1, .3, 1, 1}, -- Purple
        ["Myth"]       = {1.00, 0.50, 0.00, 1}, -- Orange
    },
    esES = {
        ["Expedicionario"] = {0.62, 0.62, 0.62, 1},
        ["Aventurero"]     = {1.00, 1.00, 1.00, 1},
        ["Veterano"]       = {0.12, 1.00, 0.00, 1},
        ["Campeón"]        = {0.00, 0.44, 0.87, 1},
        ["Héroe"]          = {1, .3, 1, 1},
        ["Mito"]           = {1.00, 0.50, 0.00, 1},
    },
    esMX = {
        ["Expedicionario"] = {0.62, 0.62, 0.62, 1},
        ["Aventurero"]     = {1.00, 1.00, 1.00, 1},
        ["Veterano"]       = {0.12, 1.00, 0.00, 1},
        ["Campeón"]        = {0.00, 0.44, 0.87, 1},
        ["Héroe"]          = {1, .3, 1, 1},
        ["Mito"]           = {1.00, 0.50, 0.00, 1},
    },    
    deDE = {
        ["Forscher"]   = {0.62, 0.62, 0.62, 1},
        ["Abenteurer"] = {1.00, 1.00, 1.00, 1},
        ["Veteran"]    = {0.12, 1.00, 0.00, 1},
        ["Champion"]   = {0.00, 0.44, 0.87, 1},
        ["Held"]       = {1, .3, 1, 1},
        ["Mythos"]     = {1.00, 0.50, 0.00, 1},
    },
    frFR = {
        ["Explorateur"] = {0.62, 0.62, 0.62, 1},
        ["Aventurier"]  = {1.00, 1.00, 1.00, 1},
        ["Vétéran"]     = {0.12, 1.00, 0.00, 1},
        ["Champion"]    = {0.00, 0.44, 0.87, 1},
        ["Héros"]       = {1, .3, 1, 1},
        ["Mythe"]       = {1.00, 0.50, 0.00, 1},
    },
    itIT = {
        ["Esploratore"]   = {0.62, 0.62, 0.62, 1},
        ["Avventuriero"]  = {1.00, 1.00, 1.00, 1},
        ["Veterano"]      = {0.12, 1.00, 0.00, 1},
        ["Campione"]      = {0.00, 0.44, 0.87, 1},
        ["Eroe"]          = {1, .3, 1, 1},
        ["Mito"]          = {1.00, 0.50, 0.00, 1},
    },
    ptBR = {
        ["Explorador"]  = {0.62, 0.62, 0.62, 1},
        ["Aventureiro"] = {1.00, 1.00, 1.00, 1},
        ["Veterano"]    = {0.12, 1.00, 0.00, 1},
        ["Campeão"]     = {0.00, 0.44, 0.87, 1},
        ["Herói"]       = {1, .3, 1, 1},
        ["Mito"]        = {1.00, 0.50, 0.00, 1},
    },
    ruRU = {
        ["Исследователь"]          = {0.62, 0.62, 0.62, 1},
        ["Искатель приключений"]   = {1.00, 1.00, 1.00, 1},
        ["Ветеран"]                = {0.12, 1.00, 0.00, 1},
        ["Защитник"]               = {0.00, 0.44, 0.87, 1},
        ["Герой"]                  = {1, .3, 1, 1},
        ["Легенда"]                = {1.00, 0.50, 0.00, 1},
    },
    koKR = {
        ["탐험가"] = {0.62, 0.62, 0.62, 1},
        ["모험가"] = {1.00, 1.00, 1.00, 1},
        ["노련가"] = {0.12, 1.00, 0.00, 1},
        ["챔피언"] = {0.00, 0.44, 0.87, 1},
        ["영웅"]   = {1, .3, 1, 1},
        ["신화"]   = {1.00, 0.50, 0.00, 1},
    },
    zhCN = {
        ["探索者"] = {0.62, 0.62, 0.62, 1},
        ["冒险者"] = {1.00, 1.00, 1.00, 1},
        ["老兵"]   = {0.12, 1.00, 0.00, 1},
        ["勇士"]   = {0.00, 0.44, 0.87, 1},
        ["英雄"]   = {1, .3, 1, 1},
        ["神话"]   = {1.00, 0.50, 0.00, 1},
    },
    zhTW = {
        ["探險者"] = {0.62, 0.62, 0.62, 1},
        ["冒險者"] = {1.00, 1.00, 1.00, 1},
        ["精兵"]   = {0.12, 1.00, 0.00, 1},
        ["勇士"]   = {0.00, 0.44, 0.87, 1},
        ["英雄"]   = {1, .3, 1, 1},
        ["神話"]   = {1.00, 0.50, 0.00, 1},
    },
}

CCS.statKeyMap = {
    secondary_crit        = "CRIT_RATING",
    secondary_haste       = "HASTE_RATING",
    secondary_mastery     = "MASTERY_RATING",
    secondary_versatility = "VERSATILITY",
}

