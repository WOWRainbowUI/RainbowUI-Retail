local _, DFFN = ...

DFFN.Locales = DFFN.Locales or {}
local L = DFFN.Locales["enUS"] or {}
DFFN.Locales["enUS"] = L

L.TAB_NAMEPLATES = "Nameplates"
L.TAB_WORLDTEXT = "World Text"
L.TAB_EXTENDED = "Extended"
L.VERSION_PREFIX = "Version: "

L.NP_ENABLE_FRIENDLY = "Enable Friendly Nameplates"
L.NP_SHOW_ONLY_NAME = "Show Only Name"
L.NP_SHOW_ONLY_NAME_NPC = "Show Only Name (NPC)"
L.NP_NPC_ALWAYS = "always"
L.NP_NPC_DUNGEON = "only dungeon"
L.NP_NPC_RAIDS = "only raids"
L.NP_NPC_DUNGEON_RAIDS = "dungeon + raids"
L.NP_HIDE_CAST_BAR = "Hide Cast Bar"
L.NP_RELOAD_REQUIRED = "Required Reload UI"
L.NP_SECTION_COLORS = "Colors:"
L.NP_SHOW_CLASS_COLOR = "Show Class Color Name"
L.NP_SHOW_COLOR_BY_SELECTION = "Show Colors By Unit Type"
L.NP_SECTION_FONT = "Font:"
L.NP_CUSTOM_FONT = "Custom Font"
L.NP_FONT_LABEL = "Font:"
L.NP_FONT_DEFAULT_GAME = "Default Game Font"
L.NP_SIZE_LABEL = "Size:"
L.NP_STYLE_LABEL = "Style:"
L.NP_STYLE_NONE = "None"
L.NP_STYLE_OUTLINE = "Outline"
L.NP_STYLE_SLUG = "Slug"
L.NP_STYLE_OUTLINE_SLUG = "Outline, Slug"

L.WT_ENABLE = "Enable World Text Names"
L.WT_TIP_ENABLE = "This will turn off/on 'Enable Friendly Nameplates' option"
L.WT_ALWAYS_APPLY = "Always apply settings"
L.WT_TIP_ALWAYS = "World Text Size and World Text Alpha settings will always be applied,|n|n" ..
    "even if 'Enable World Text Names' is disabled"
L.WT_HIDE_GUILD = "Hide player guild"
L.WT_HIDE_TITLE = "Hide player title"
L.WT_SIZE = "World Text size"
L.WT_ALPHA = "World Text alpha"

L.EX_BLIZZ_SIZE = "Blizzard Nameplate Size"
L.EX_BLIZZ_STYLE = "Blizzard Style:"
L.EX_STYLE_MODERN = "Modern (0)"
L.EX_STYLE_THIN = "Thin Bars (1)"
L.EX_STYLE_BLOCKY = "Blocky Bars (2)"
L.EX_STYLE_CLEAN_HEALTH = "Clean Health (3)"
L.EX_STYLE_BLOCKY_CAST = "Blocky Cast (4)"
L.EX_STYLE_LEGACY_RED = "Legacy Red (5)"
L.EX_HIDE_OPEN_WORLD = "Hide Friendly Nameplates in Open World"
L.EX_CUSTOM_WIDTH = "Custom Width"
L.EX_OPEN_BLIZZ_SETTINGS = "Open Blizzard Nameplate settings"

L.UI_LANGUAGE = "Language"
L.UI_RELOAD_LANG = "Reload to apply language change"