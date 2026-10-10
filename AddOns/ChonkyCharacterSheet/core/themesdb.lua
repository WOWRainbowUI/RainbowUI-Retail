local addonName, ns = ...
local CCS = ns.CCS

--[[  
Theme Layout/Instructions

ChonkyCharacterSheet\Themes\<ThemeName>\

-- Character Frame
character_frame_borders.png              -- all 8 character frame border slices in one file
character_frame_top_image.png
character_frame_left_image.png
character_frame_right_image.png
character_background_texture.png
character_frame_item_container_texture.png

-- Character Tabs
character_tab_texture.png
character_tab_highlight.png
character_tab_border.png
character_tab_active.png

-- Character Stats
character_stats_borders.png              -- all 8 stats border slices in one file
character_stats_section_bg_texture.png
character_stats_header_texture.png
character_stats_row_texture.png

-- Paperdoll
paperdoll_borders.png                    -- all 8 paperdoll border slices in one file

-- Reputation + Token (shared)
rep_token_frame_header_texture.png
rep_token_header_bar_texture.png
rep_token_main_bar_texture.png
rep_token_rep_bar_texture.png

--]]

CCS.Themes = {

    --========================================================--
    -- 1. Darkmoon Faire
    --========================================================--
    ["Darkmoon Faire"] = {
        ["Character Frame Top Left"] = { texture = nil, map = nil },
        ["Character Frame Top"] = { texture = nil, map = nil },
        ["Character Frame Top Right"] = { texture = nil, map = nil },
        ["Character Frame Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom"] = { texture = nil, map = nil },
        ["Character Frame Bottom Left"] = { texture = nil, map = nil },
        ["Character Frame Left"] = { texture = nil, map = nil },
        ["Character Frame Top Image"] = { texture = nil, map = nil },
        ["Character Frame Left Image"] = { texture = nil, map = nil },
        ["Character Frame Right Image"] = { texture = nil, map = nil },
        ["Character Background Texture"] = { texture = nil, map = nil },
        ["Character Tab Texture"] = { texture = nil, map = nil },
        ["Character Tab Highlight"] = { texture = nil, map = nil },
        ["Character Tab Border"] = { texture = nil, map = nil },
        ["Character Tab Active"] = { texture = nil, map = nil },
        ["Character Frame Item Container Texture"] = { texture = nil, map = nil },

        ["Character Stats Border Top Left"] = { texture = nil, map = nil },
        ["Character Stats Border Top"] = { texture = nil, map = nil },
        ["Character Stats Border Top Right"] = { texture = nil, map = nil },
        ["Character Stats Border Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Left"] = { texture = nil, map = nil },
        ["Character Stats Border Left"] = { texture = nil, map = nil },
        ["Character Stats Section Bg Texture"] = { texture = nil, map = nil },
        ["Character Stats Header Texture"] = { texture = nil, map = nil },
        ["Character Stats Row Texture"] = { texture = nil, map = nil },

        ["Paperdoll Border Top Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Top"] = { texture = nil, map = nil },
        ["Paperdoll Border Top Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Left"] = { texture = nil, map = nil },

        ["Reputation Frame Header Texture"] = { texture = nil, map = nil },
        ["Reputation Header bar texture"] = { texture = nil, map = nil },
        ["Reputation Main bar texture"] = { texture = nil, map = nil },
        ["Reputation Rep bar texture"] = { texture = nil, map = nil },

        ["Token Frame Header Texture"] = { texture = nil, map = nil },
        ["Token Header bar texture"] = { texture = nil, map = nil },
        ["Token Main bar texture"] = { texture = nil, map = nil },
        ["Token Rep bar texture"] = { texture = nil, map = nil },
    },

    --========================================================--
    -- 2. Alliance
    --========================================================--
    ["Alliance"] = {
        ["Character Frame Top Left"] = { texture = nil, map = nil },
        ["Character Frame Top"] = { texture = nil, map = nil },
        ["Character Frame Top Right"] = { texture = nil, map = nil },
        ["Character Frame Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom"] = { texture = nil, map = nil },
        ["Character Frame Bottom Left"] = { texture = nil, map = nil },
        ["Character Frame Left"] = { texture = nil, map = nil },
        ["Character Frame Top Image"] = { texture = nil, map = nil },
        ["Character Frame Left Image"] = { texture = nil, map = nil },
        ["Character Frame Right Image"] = { texture = nil, map = nil },
        ["Character Background Texture"] = { texture = nil, map = nil },
        ["Character Tab Texture"] = { texture = nil, map = nil },
        ["Character Tab Highlight"] = { texture = nil, map = nil },
        ["Character Tab Border"] = { texture = nil, map = nil },
        ["Character Tab Active"] = { texture = nil, map = nil },
        ["Character Frame Item Container Texture"] = { texture = nil, map = nil },

        ["Character Stats Border Top Left"] = { texture = nil, map = nil },
        ["Character Stats Border Top"] = { texture = nil, map = nil },
        ["Character Stats Border Top Right"] = { texture = nil, map = nil },
        ["Character Stats Border Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Left"] = { texture = nil, map = nil },
        ["Character Stats Border Left"] = { texture = nil, map = nil },
        ["Character Stats Section Bg Texture"] = { texture = nil, map = nil },
        ["Character Stats Header Texture"] = { texture = nil, map = nil },
        ["Character Stats Row Texture"] = { texture = nil, map = nil },

        ["Paperdoll Border Top Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Top"] = { texture = nil, map = nil },
        ["Paperdoll Border Top Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Left"] = { texture = nil, map = nil },

        ["Reputation Frame Header Texture"] = { texture = nil, map = nil },
        ["Reputation Header bar texture"] = { texture = nil, map = nil },
        ["Reputation Main bar texture"] = { texture = nil, map = nil },
        ["Reputation Rep bar texture"] = { texture = nil, map = nil },

        ["Token Frame Header Texture"] = { texture = nil, map = nil },
        ["Token Header bar texture"] = { texture = nil, map = nil },
        ["Token Main bar texture"] = { texture = nil, map = nil },
        ["Token Rep bar texture"] = { texture = nil, map = nil },
    },

    --========================================================--
    -- 3. Horde
    --========================================================--
    ["Horde"] = {
        ["Character Frame Top Left"] = { texture = nil, map = nil },
        ["Character Frame Top"] = { texture = nil, map = nil },
        ["Character Frame Top Right"] = { texture = nil, map = nil },
        ["Character Frame Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom"] = { texture = nil, map = nil },
        ["Character Frame Bottom Left"] = { texture = nil, map = nil },
        ["Character Frame Left"] = { texture = nil, map = nil },
        ["Character Frame Top Image"] = { texture = nil, map = nil },
        ["Character Frame Left Image"] = { texture = nil, map = nil },
        ["Character Frame Right Image"] = { texture = nil, map = nil },
        ["Character Background Texture"] = { texture = nil, map = nil },
        ["Character Tab Texture"] = { texture = nil, map = nil },
        ["Character Tab Highlight"] = { texture = nil, map = nil },
        ["Character Tab Border"] = { texture = nil, map = nil },
        ["Character Tab Active"] = { texture = nil, map = nil },
        ["Character Frame Item Container Texture"] = { texture = nil, map = nil },

        ["Character Stats Border Top Left"] = { texture = nil, map = nil },
        ["Character Stats Border Top"] = { texture = nil, map = nil },
        ["Character Stats Border Top Right"] = { texture = nil, map = nil },
        ["Character Stats Border Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Left"] = { texture = nil, map = nil },
        ["Character Stats Border Left"] = { texture = nil, map = nil },
        ["Character Stats Section Bg Texture"] = { texture = nil, map = nil },
        ["Character Stats Header Texture"] = { texture = nil, map = nil },
        ["Character Stats Row Texture"] = { texture = nil, map = nil },

        ["Paperdoll Border Top Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Top"] = { texture = nil, map = nil },
        ["Paperdoll Border Top Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Left"] = { texture = nil, map = nil },

        ["Reputation Frame Header Texture"] = { texture = nil, map = nil },
        ["Reputation Header bar texture"] = { texture = nil, map = nil },
        ["Reputation Main bar texture"] = { texture = nil, map = nil },
        ["Reputation Rep bar texture"] = { texture = nil, map = nil },

        ["Token Frame Header Texture"] = { texture = nil, map = nil },
        ["Token Header bar texture"] = { texture = nil, map = nil },
        ["Token Main bar texture"] = { texture = nil, map = nil },
        ["Token Rep bar texture"] = { texture = nil, map = nil },
    },

    --========================================================--
    -- 4. Void / Old God
    --========================================================--
    ["Void"] = {
        ["Character Frame Top Left"] = { texture = nil, map = nil },
        ["Character Frame Top"] = { texture = nil, map = nil },
        ["Character Frame Top Right"] = { texture = nil, map = nil },
        ["Character Frame Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom"] = { texture = nil, map = nil },
        ["Character Frame Bottom Left"] = { texture = nil, map = nil },
        ["Character Frame Left"] = { texture = nil, map = nil },
        ["Character Frame Top Image"] = { texture = nil, map = nil },
        ["Character Frame Left Image"] = { texture = nil, map = nil },
        ["Character Frame Right Image"] = { texture = nil, map = nil },
        ["Character Background Texture"] = { texture = nil, map = nil },
        ["Character Tab Texture"] = { texture = nil, map = nil },
        ["Character Tab Highlight"] = { texture = nil, map = nil },
        ["Character Tab Border"] = { texture = nil, map = nil },
        ["Character Tab Active"] = { texture = nil, map = nil },
        ["Character Frame Item Container Texture"] = { texture = nil, map = nil },

        ["Character Stats Border Top Left"] = { texture = nil, map = nil },
        ["Character Stats Border Top"] = { texture = nil, map = nil },
        ["Character Stats Border Top Right"] = { texture = nil, map = nil },
        ["Character Stats Border Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Left"] = { texture = nil, map = nil },
        ["Character Stats Border Left"] = { texture = nil, map = nil },
        ["Character Stats Section Bg Texture"] = { texture = nil, map = nil },
        ["Character Stats Header Texture"] = { texture = nil, map = nil },
        ["Character Stats Row Texture"] = { texture = nil, map = nil },

        ["Paperdoll Border Top Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Top"] = { texture = nil, map = nil },
        ["Paperdoll Border Top Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Left"] = { texture = nil, map = nil },

        ["Reputation Frame Header Texture"] = { texture = nil, map = nil },
        ["Reputation Header bar texture"] = { texture = nil, map = nil },
        ["Reputation Main bar texture"] = { texture = nil, map = nil },
        ["Reputation Rep bar texture"] = { texture = nil, map = nil },

        ["Token Frame Header Texture"] = { texture = nil, map = nil },
        ["Token Header bar texture"] = { texture = nil, map = nil },
        ["Token Main bar texture"] = { texture = nil, map = nil },
        ["Token Rep bar texture"] = { texture = nil, map = nil },
    },

    --========================================================--
    -- 5. Monster Hunter (Witcher Inspired)
    --========================================================--
    ["Monster Hunter"] = {
        ["Character Frame Top Left"] = { texture = nil, map = nil },
        ["Character Frame Top"] = { texture = nil, map = nil },
        ["Character Frame Top Right"] = { texture = nil, map = nil },
        ["Character Frame Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom"] = { texture = nil, map = nil },
        ["Character Frame Bottom Left"] = { texture = nil, map = nil },
        ["Character Frame Left"] = { texture = nil, map = nil },
        ["Character Frame Top Image"] = { texture = nil, map = nil },
        ["Character Frame Left Image"] = { texture = nil, map = nil },
        ["Character Frame Right Image"] = { texture = nil, map = nil },
        ["Character Background Texture"] = { texture = nil, map = nil },
        ["Character Tab Texture"] = { texture = nil, map = nil },
        ["Character Tab Highlight"] = { texture = nil, map = nil },
        ["Character Tab Border"] = { texture = nil, map = nil },
        ["Character Tab Active"] = { texture = nil, map = nil },
        ["Character Frame Item Container Texture"] = { texture = nil, map = nil },

        ["Character Stats Border Top Left"] = { texture = nil, map = nil },
        ["Character Stats Border Top"] = { texture = nil, map = nil },
        ["Character Stats Border Top Right"] = { texture = nil, map = nil },
        ["Character Stats Border Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Left"] = { texture = nil, map = nil },
        ["Character Stats Border Left"] = { texture = nil, map = nil },
        ["Character Stats Section Bg Texture"] = { texture = nil, map = nil },
        ["Character Stats Header Texture"] = { texture = nil, map = nil },
        ["Character Stats Row Texture"] = { texture = nil, map = nil },

        ["Paperdoll Border Top Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Top"] = { texture = nil, map = nil },
        ["Paperdoll Border Top Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Left"] = { texture = nil, map = nil },

        ["Reputation Frame Header Texture"] = { texture = nil, map = nil },
        ["Reputation Header bar texture"] = { texture = nil, map = nil },
        ["Reputation Main bar texture"] = { texture = nil, map = nil },
        ["Reputation Rep bar texture"] = { texture = nil, map = nil },

        ["Token Frame Header Texture"] = { texture = nil, map = nil },
        ["Token Header bar texture"] = { texture = nil, map = nil },
        ["Token Main bar texture"] = { texture = nil, map = nil },
        ["Token Rep bar texture"] = { texture = nil, map = nil },
    },

    --========================================================--
    -- 6. Sanctum of the Fallen (Diablo Inspired)
    --========================================================--
    ["Sanctum of the Fallen"] = {
        ["Character Frame Top Left"] = { texture = nil, map = nil },
        ["Character Frame Top"] = { texture = nil, map = nil },
        ["Character Frame Top Right"] = { texture = nil, map = nil },
        ["Character Frame Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom"] = { texture = nil, map = nil },
        ["Character Frame Bottom Left"] = { texture = nil, map = nil },
        ["Character Frame Left"] = { texture = nil, map = nil },
        ["Character Frame Top Image"] = { texture = nil, map = nil },
        ["Character Frame Left Image"] = { texture = nil, map = nil },
        ["Character Frame Right Image"] = { texture = nil, map = nil },
        ["Character Background Texture"] = { texture = nil, map = nil },
        ["Character Tab Texture"] = { texture = nil, map = nil },
        ["Character Tab Highlight"] = { texture = nil, map = nil },
        ["Character Tab Border"] = { texture = nil, map = nil },
        ["Character Tab Active"] = { texture = nil, map = nil },
        ["Character Frame Item Container Texture"] = { texture = nil, map = nil },

        ["Character Stats Border Top Left"] = { texture = nil, map = nil },
        ["Character Stats Border Top"] = { texture = nil, map = nil },
        ["Character Stats Border Top Right"] = { texture = nil, map = nil },
        ["Character Stats Border Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Left"] = { texture = nil, map = nil },
        ["Character Stats Border Left"] = { texture = nil, map = nil },
        ["Character Stats Section Bg Texture"] = { texture = nil, map = nil },
        ["Character Stats Header Texture"] = { texture = nil, map = nil },
        ["Character Stats Row Texture"] = { texture = nil, map = nil },

        ["Paperdoll Border Top Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Top"] = { texture = nil, map = nil },
        ["Paperdoll Border Top Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Left"] = { texture = nil, map = nil },

        ["Reputation Frame Header Texture"] = { texture = nil, map = nil },
        ["Reputation Header bar texture"] = { texture = nil, map = nil },
        ["Reputation Main bar texture"] = { texture = nil, map = nil },
        ["Reputation Rep bar texture"] = { texture = nil, map = nil },

        ["Token Frame Header Texture"] = { texture = nil, map = nil },
        ["Token Header bar texture"] = { texture = nil, map = nil },
        ["Token Main bar texture"] = { texture = nil, map = nil },
        ["Token Rep bar texture"] = { texture = nil, map = nil },
    },

    --========================================================--
    -- 7. Minimalist Black
    --========================================================--
    ["Minimalist Black"] = {
        ["Character Frame Top Left"] = { texture = nil, map = nil },
        ["Character Frame Top"] = { texture = nil, map = nil },
        ["Character Frame Top Right"] = { texture = nil, map = nil },
        ["Character Frame Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom"] = { texture = nil, map = nil },
        ["Character Frame Bottom Left"] = { texture = nil, map = nil },
        ["Character Frame Left"] = { texture = nil, map = nil },
        ["Character Frame Top Image"] = { texture = nil, map = nil },
        ["Character Frame Left Image"] = { texture = nil, map = nil },
        ["Character Frame Right Image"] = { texture = nil, map = nil },
        ["Character Background Texture"] = { texture = nil, map = nil },
        ["Character Tab Texture"] = { texture = nil, map = nil },
        ["Character Tab Highlight"] = { texture = nil, map = nil },
        ["Character Tab Border"] = { texture = nil, map = nil },
        ["Character Tab Active"] = { texture = nil, map = nil },
        ["Character Frame Item Container Texture"] = { texture = nil, map = nil },

        ["Character Stats Border Top Left"] = { texture = nil, map = nil },
        ["Character Stats Border Top"] = { texture = nil, map = nil },
        ["Character Stats Border Top Right"] = { texture = nil, map = nil },
        ["Character Stats Border Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Left"] = { texture = nil, map = nil },
        ["Character Stats Border Left"] = { texture = nil, map = nil },
        ["Character Stats Section Bg Texture"] = { texture = nil, map = nil },
        ["Character Stats Header Texture"] = { texture = nil, map = nil },
        ["Character Stats Row Texture"] = { texture = nil, map = nil },

        ["Paperdoll Border Top Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Top"] = { texture = nil, map = nil },
        ["Paperdoll Border Top Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Left"] = { texture = nil, map = nil },

        ["Reputation Frame Header Texture"] = { texture = nil, map = nil },
        ["Reputation Header bar texture"] = { texture = nil, map = nil },
        ["Reputation Main bar texture"] = { texture = nil, map = nil },
        ["Reputation Rep bar texture"] = { texture = nil, map = nil },

        ["Token Frame Header Texture"] = { texture = nil, map = nil },
        ["Token Header bar texture"] = { texture = nil, map = nil },
        ["Token Main bar texture"] = { texture = nil, map = nil },
        ["Token Rep bar texture"] = { texture = nil, map = nil },
    },

    --========================================================--
    -- 8. Silverframe
    --========================================================--
    ["Silverframe"] = {
        ["Character Frame Top Left"] = { texture = nil, map = nil },
        ["Character Frame Top"] = { texture = nil, map = nil },
        ["Character Frame Top Right"] = { texture = nil, map = nil },
        ["Character Frame Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom"] = { texture = nil, map = nil },
        ["Character Frame Bottom Left"] = { texture = nil, map = nil },
        ["Character Frame Left"] = { texture = nil, map = nil },
        ["Character Frame Top Image"] = { texture = nil, map = nil },
        ["Character Frame Left Image"] = { texture = nil, map = nil },
        ["Character Frame Right Image"] = { texture = nil, map = nil },
        ["Character Background Texture"] = { texture = nil, map = nil },
        ["Character Tab Texture"] = { texture = nil, map = nil },
        ["Character Tab Highlight"] = { texture = nil, map = nil },
        ["Character Tab Border"] = { texture = nil, map = nil },
        ["Character Tab Active"] = { texture = nil, map = nil },
        ["Character Frame Item Container Texture"] = { texture = nil, map = nil },

        ["Character Stats Border Top Left"] = { texture = nil, map = nil },
        ["Character Stats Border Top"] = { texture = nil, map = nil },
        ["Character Stats Border Top Right"] = { texture = nil, map = nil },
        ["Character Stats Border Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Left"] = { texture = nil, map = nil },
        ["Character Stats Border Left"] = { texture = nil, map = nil },
        ["Character Stats Section Bg Texture"] = { texture = nil, map = nil },
        ["Character Stats Header Texture"] = { texture = nil, map = nil },
        ["Character Stats Row Texture"] = { texture = nil, map = nil },

        ["Paperdoll Border Top Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Top"] = { texture = nil, map = nil },
        ["Paperdoll Border Top Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Left"] = { texture = nil, map = nil },

        ["Reputation Frame Header Texture"] = { texture = nil, map = nil },
        ["Reputation Header bar texture"] = { texture = nil, map = nil },
        ["Reputation Main bar texture"] = { texture = nil, map = nil },
        ["Reputation Rep bar texture"] = { texture = nil, map = nil },

        ["Token Frame Header Texture"] = { texture = nil, map = nil },
        ["Token Header bar texture"] = { texture = nil, map = nil },
        ["Token Main bar texture"] = { texture = nil, map = nil },
        ["Token Rep bar texture"] = { texture = nil, map = nil },
    },

    --========================================================--
    -- 9. Arcane Glass
    --========================================================--
    ["Arcane Glass"] = {
        ["Character Frame Top Left"] = { texture = nil, map = nil },
        ["Character Frame Top"] = { texture = nil, map = nil },
        ["Character Frame Top Right"] = { texture = nil, map = nil },
        ["Character Frame Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom"] = { texture = nil, map = nil },
        ["Character Frame Bottom Left"] = { texture = nil, map = nil },
        ["Character Frame Left"] = { texture = nil, map = nil },
        ["Character Frame Top Image"] = { texture = nil, map = nil },
        ["Character Frame Left Image"] = { texture = nil, map = nil },
        ["Character Frame Right Image"] = { texture = nil, map = nil },
        ["Character Background Texture"] = { texture = nil, map = nil },
        ["Character Tab Texture"] = { texture = nil, map = nil },
        ["Character Tab Highlight"] = { texture = nil, map = nil },
        ["Character Tab Border"] = { texture = nil, map = nil },
        ["Character Tab Active"] = { texture = nil, map = nil },
        ["Character Frame Item Container Texture"] = { texture = nil, map = nil },

        ["Character Stats Border Top Left"] = { texture = nil, map = nil },
        ["Character Stats Border Top"] = { texture = nil, map = nil },
        ["Character Stats Border Top Right"] = { texture = nil, map = nil },
        ["Character Stats Border Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Left"] = { texture = nil, map = nil },
        ["Character Stats Border Left"] = { texture = nil, map = nil },
        ["Character Stats Section Bg Texture"] = { texture = nil, map = nil },
        ["Character Stats Header Texture"] = { texture = nil, map = nil },
        ["Character Stats Row Texture"] = { texture = nil, map = nil },

        ["Paperdoll Border Top Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Top"] = { texture = nil, map = nil },
        ["Paperdoll Border Top Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Left"] = { texture = nil, map = nil },

        ["Reputation Frame Header Texture"] = { texture = nil, map = nil },
        ["Reputation Header bar texture"] = { texture = nil, map = nil },
        ["Reputation Main bar texture"] = { texture = nil, map = nil },
        ["Reputation Rep bar texture"] = { texture = nil, map = nil },

        ["Token Frame Header Texture"] = { texture = nil, map = nil },
        ["Token Header bar texture"] = { texture = nil, map = nil },
        ["Token Main bar texture"] = { texture = nil, map = nil },
        ["Token Rep bar texture"] = { texture = nil, map = nil },
    },

    --========================================================--
    -- 10. Leatherbound
    --========================================================--
    ["Leatherbound"] = {
        ["Character Frame Top Left"] = { texture = nil, map = nil },
        ["Character Frame Top"] = { texture = nil, map = nil },
        ["Character Frame Top Right"] = { texture = nil, map = nil },
        ["Character Frame Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom"] = { texture = nil, map = nil },
        ["Character Frame Bottom Left"] = { texture = nil, map = nil },
        ["Character Frame Left"] = { texture = nil, map = nil },
        ["Character Frame Top Image"] = { texture = nil, map = nil },
        ["Character Frame Left Image"] = { texture = nil, map = nil },
        ["Character Frame Right Image"] = { texture = nil, map = nil },
        ["Character Background Texture"] = { texture = nil, map = nil },
        ["Character Tab Texture"] = { texture = nil, map = nil },
        ["Character Tab Highlight"] = { texture = nil, map = nil },
        ["Character Tab Border"] = { texture = nil, map = nil },
        ["Character Tab Active"] = { texture = nil, map = nil },
        ["Character Frame Item Container Texture"] = { texture = nil, map = nil },

        ["Character Stats Border Top Left"] = { texture = nil, map = nil },
        ["Character Stats Border Top"] = { texture = nil, map = nil },
        ["Character Stats Border Top Right"] = { texture = nil, map = nil },
        ["Character Stats Border Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Left"] = { texture = nil, map = nil },
        ["Character Stats Border Left"] = { texture = nil, map = nil },
        ["Character Stats Section Bg Texture"] = { texture = nil, map = nil },
        ["Character Stats Header Texture"] = { texture = nil, map = nil },
        ["Character Stats Row Texture"] = { texture = nil, map = nil },

        ["Paperdoll Border Top Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Top"] = { texture = nil, map = nil },
        ["Paperdoll Border Top Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Left"] = { texture = nil, map = nil },

        ["Reputation Frame Header Texture"] = { texture = nil, map = nil },
        ["Reputation Header bar texture"] = { texture = nil, map = nil },
        ["Reputation Main bar texture"] = { texture = nil, map = nil },
        ["Reputation Rep bar texture"] = { texture = nil, map = nil },

        ["Token Frame Header Texture"] = { texture = nil, map = nil },
        ["Token Header bar texture"] = { texture = nil, map = nil },
        ["Token Main bar texture"] = { texture = nil, map = nil },
        ["Token Rep bar texture"] = { texture = nil, map = nil },
    },

    --========================================================--
    -- 11. Stone Tablet
    --========================================================--
    ["Stone Tablet"] = {
        ["Character Frame Top Left"] = { texture = nil, map = nil },
        ["Character Frame Top"] = { texture = nil, map = nil },
        ["Character Frame Top Right"] = { texture = nil, map = nil },
        ["Character Frame Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom Right"] = { texture = nil, map = nil },
        ["Character Frame Bottom"] = { texture = nil, map = nil },
        ["Character Frame Bottom Left"] = { texture = nil, map = nil },
        ["Character Frame Left"] = { texture = nil, map = nil },
        ["Character Frame Top Image"] = { texture = nil, map = nil },
        ["Character Frame Left Image"] = { texture = nil, map = nil },
        ["Character Frame Right Image"] = { texture = nil, map = nil },
        ["Character Background Texture"] = { texture = nil, map = nil },
        ["Character Tab Texture"] = { texture = nil, map = nil },
        ["Character Tab Highlight"] = { texture = nil, map = nil },
        ["Character Tab Border"] = { texture = nil, map = nil },
        ["Character Tab Active"] = { texture = nil, map = nil },
        ["Character Frame Item Container Texture"] = { texture = nil, map = nil },

        ["Character Stats Border Top Left"] = { texture = nil, map = nil },
        ["Character Stats Border Top"] = { texture = nil, map = nil },
        ["Character Stats Border Top Right"] = { texture = nil, map = nil },
        ["Character Stats Border Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Right"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom"] = { texture = nil, map = nil },
        ["Character Stats Border Bottom Left"] = { texture = nil, map = nil },
        ["Character Stats Border Left"] = { texture = nil, map = nil },
        ["Character Stats Section Bg Texture"] = { texture = nil, map = nil },
        ["Character Stats Header Texture"] = { texture = nil, map = nil },
        ["Character Stats Row Texture"] = { texture = nil, map = nil },

        ["Paperdoll Border Top Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Top"] = { texture = nil, map = nil },
        ["Paperdoll Border Top Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Right"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom"] = { texture = nil, map = nil },
        ["Paperdoll Border Bottom Left"] = { texture = nil, map = nil },
        ["Paperdoll Border Left"] = { texture = nil, map = nil },

        ["Reputation Frame Header Texture"] = { texture = nil, map = nil },
        ["Reputation Header bar texture"] = { texture = nil, map = nil },
        ["Reputation Main bar texture"] = { texture = nil, map = nil },
        ["Reputation Rep bar texture"] = { texture = nil, map = nil },

        ["Token Frame Header Texture"] = { texture = nil, map = nil },
        ["Token Header bar texture"] = { texture = nil, map = nil },
        ["Token Main bar texture"] = { texture = nil, map = nil },
        ["Token Rep bar texture"] = { texture = nil, map = nil },
    },
}
