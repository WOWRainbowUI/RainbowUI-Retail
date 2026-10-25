local addonName, ns = ...
local CCS = ns.CCS
--
-- The first two map values for frame_tl, stats_tl, and paper_tl set the corner size
-- The corner size sets the overall border thickness.
--
CCS.Themes = {
    enabled = true,
    --========================================================--
    -- Darkmoon Faire
    --========================================================--
    ["Darkmoon Faire"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkmoonFaire\\",
        statbgcolor = { 0.486, 0.333, 0.137, 1.0 }, -- Color behind the stats scrollframe 
        bcolor = { 0.486, 0.333, 0.137, 1.0 }, -- Border Color
        hcolor = { 0.671, 0.529, 0.263, 1.0 }, -- Highlight Color (for buttons/etc)
        ncolor = { 0.486, 0.333, 0.137, 1.0 }, -- Normal Color (for buttons/etc)
        bncolor = { 0.416, 0.173, 0.627, 1.0}, -- Banner Color (for Rewards)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-15,cy=23, map = {68, 68, 0.007, 0.246, 0.007, 0.245} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {145, 68, 0.246, 0.754, 0.007, 0.245} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=15,cy=23, map = {68, 68, 0.754, 0.993, 0.007, 0.245} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {68, 146, 0.754, 0.993, 0.245, 0.755} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=15,cy=-23, map = {68, 68, 0.754, 0.993, 0.755, 0.993} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {145, 68, 0.246, 0.754, 0.755, 0.993} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-15,cy=-23, map = {68, 68, 0.007, 0.246, 0.755, 0.993} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {68, 146, 0.007, 0.246, 0.245, 0.755} },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = 410, h = 72.307, cx = 0, cy = -17 },
        frame_left_img = { texture = "frame_left_img.png", w = 65, h = 418.438, cx = 0, cy = 0 },
        frame_right_img = { texture = "frame_right_img.png", w = 65, h = 418.438, cx = 0, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {20, 20, 0, 0.089, 0, 0.09} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {184, 20, 0.089, 0.907, 0, 0.09} },
        stats_tr       = { texture = "stats_border.png", cx=0, cy=0, map = {21, 20, 0.907, 1, 0, 0.09} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {21, 182, 0.907, 1, 0.09, 0.906} },
        stats_br       = { texture = "stats_border.png", cx=0, cy=0, map = {21, 21, 0.907, 1, 0.906, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {184, 21, 0.089, 0.907, 0.906, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {20, 21, 0, 0.089, 0.906, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {20, 182, 0, 0.089, 0.09, 0.906} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-10, cy=10, map = {40, 40, 0, 0.152, 0, 0.153} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=10, map = {70, 40, 0.152, 0.418, 0, 0.153} },
        paper_tr       = { texture = "paperdoll_border.png", cx=8, cy=10, map = {40, 40, 0.848, 1, 0, 0.153} },
        paper_r        = { texture = "paperdoll_border.png", cx=8, cy=0, map = {40, 55, 0.848, 1, 0.164, 0.374} },
        paper_br       = { texture = "paperdoll_border.png", cx=8, cy=-15, map = {40, 40, 0.848, 1, 0.847, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=-15, map = {70, 40, 0.152, 0.418, 0.847, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-10, cy=-15, map = {40, 40, 0, 0.152, 0.847, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=-10, cy=0, map = {40, 55, 0, 0.152, 0.164, 0.374} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Alliance
    --========================================================--
    ["Alliance"] =  {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\Alliance\\",
        statbgcolor = {0.1059, 0.1843, 0.4314, 1.0}, -- Color behind the stats scrollframe -- 2f3d64
        bcolor = {0.1059, 0.1843, 0.4314, 1.0}, -- Border Color -- 102252
        hcolor = {0.4753, 0.5365, 0.7153, 1.0}, -- Highlight Color (for buttons/etc) -- 203a86
        ncolor = {0.2847, 0.3474, 0.5451, 1.0}, -- Normal Color (for buttons/etc) --1b2f6e 
        bncolor = { 0.902, 0.784, 0.471, 1.0}, -- Banner Color (for Rewards)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-15,cy=30, map = {68, 68, 0.002, 0.237, 0.004, 0.238} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {289, 128, 0.237, 0.763, 0.004, 0.238} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=15,cy=30, map = {129, 128, 0.763, 0.998, 0.004, 0.238} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {129, 286, 0.763, 0.998, 0.238, 0.762} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=15,cy=-25, map = {129, 130, 0.763, 0.998, 0.762, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {289, 130, 0.237, 0.763, 0.762, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-15,cy=-25, map = {129, 130, 0.002, 0.237, 0.762, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {129, 286, 0.002, 0.237, 0.238, 0.762} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 408.2366, h = 82, cx = 0, cy = -19 },
        frame_left_img = { texture = "frame_left_img.png", w = 60, h = 392, cx = 6, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 60, h = 392, cx = -6, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1}},
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.089, 0, 0.09} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {138, 15, 0.089, 0.911, 0, 0.09} },
        stats_tr       = { texture = "stats_border.png", cx=0, cy=0, map = {15, 15, 0.911, 1, 0, 0.09} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {15, 136, 0.911, 1, 0.09, 0.91} },
        stats_br       = { texture = "stats_border.png", cx=0, cy=0, map = {15, 15, 0.911, 1, 0.91, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {138, 15, 0.089, 0.911, 0.91, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.089, 0.91, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {15, 136, 0, 0.089, 0.09, 0.91} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-7, cy=12, map = {40, 40, 0, 0.168, 0, 0.167} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {277, 70, 0.168, 0.832, 0, 0.167} },
        paper_tr       = { texture = "paperdoll_border.png", cx=5, cy=12, map = {70, 70, 0.832, 1, 0, 0.167}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {70, 279, 0.832, 1, 0.167, 0.833} },
        paper_br       = { texture = "paperdoll_border.png", cx=5, cy=-5, map = {70, 70, 0.832, 1, 0.833, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {277, 70, 0.168, 0.832, 0.833, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-7, cy=-5, map = {70, 70, 0, 0.168, 0.833, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {70, 279, 0, 0.168, 0.167, 0.833} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Horde
    --========================================================--
    ["Horde"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\Horde\\",
        statbgcolor = {  0.3209, 0.0941, 0.1020, 1.0}, -- Color behind the stats scrollframe 932625
        bcolor = {0.4745, 0.1059, 0.1137, 1.0}, -- Border Color 791b1d
        hcolor = {0.6657, 0.2004, 0.1690, 1.0}, -- Highlight Color (for buttons/etc) -- 98011f
        ncolor = {0.5961, 0.0039, 0.1216, 1.0}, -- Normal Color (for buttons/etc) 9d2e26
        bncolor = {0.651, 0.486, 0.322, 1.0 }, -- Banner Color (for Rewards)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-17,cy=25, map = {68, 68, 0, 0.263, 0, 0.269} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {270, 150, 0.263, 0.737, 0, 0.269} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=17,cy=25, map = {150, 150, 0.737, 1, 0, 0.269} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {150, 258, 0.737, 1, 0.269, 0.731} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=17,cy=-25, map = {150, 150, 0.737, 1, 0.731, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {270, 150, 0.263, 0.737, 0.731, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-17,cy=-25, map = {150, 150, 0, 0.263, 0.731, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {150, 258, 0, 0.263, 0.269, 0.731} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 417.2088, h = 82, cx = 0, cy = -19 },
        frame_left_img = { texture = "frame_left_img.png", w = 81, h = 398, cx = 10, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 81, h = 398, cx = -10, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.127, 0, 0.134} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {293, 50, 0.127, 0.873, 0, 0.134} },
        stats_tr       = { texture = "stats_border.png", cx=0, cy=0, map = {50, 50, 0.873, 1, 0, 0.134} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {50, 274, 0.873, 1, 0.134, 0.866} },
        stats_br       = { texture = "stats_border.png", cx=0, cy=0, map = {50, 50, 0.873, 1, 0.866, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {293, 50, 0.127, 0.873, 0.866, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {50, 50, 0, 0.127, 0.866, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {50, 274, 0, 0.127, 0.134, 0.866} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-7, cy=6, map = {20, 20, 0, 0.065, 0, 0.068} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {402, 30, 0.065, 0.935, 0, 0.068} },
        paper_tr       = { texture = "paperdoll_border.png", cx=4, cy=6, map = {30, 30, 0.935, 1, 0, 0.068}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {30, 383, 0.935, 1, 0.068, 0.932} },
        paper_br       = { texture = "paperdoll_border.png", cx=4, cy=-3, map = {30, 30, 0.935, 1, 0.932, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {402, 30, 0.065, 0.935, 0.932, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-7, cy=-3, map = {30, 30, 0, 0.065, 0.932, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {30, 383, 0, 0.065, 0.068, 0.932} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Dusklight
    --========================================================--
    ["Dusklight"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\Dusklight\\",
        statbgcolor = {0.1451, 0.1451, 0.1451, 1.0}, -- Color behind the stats scrollframe 
        bcolor = {0.3412, 0.2235, 0, 1.0}, -- Border Color
        hcolor = {0.7255, 0.5686, 0.3843, 1.0}, -- Highlight Color (for buttons/etc)
        ncolor = {0.5725, 0.451, 0.298, 1.0}, -- Normal Color (for buttons/etc)
        --bncolor = {0.051, 0.059, 0.071, 1.0}, -- Banner Color (for Rewards)
        bncolor = {0.469, 0.404, 0.327, 1.0}, -- Banner Color (for Rewards)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-17,cy=19, map = {55, 55, 0, 0.11, 0, 0.11} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {392, 55, 0.11, 0.89, 0, 0.11} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=17,cy=19, map = {55, 55, 0.89, 1, 0, 0.11} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {55, 389, 0.89, 1, 0.11, 0.89} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=17,cy=-19, map = {55, 55, 0.89, 1, 0.89, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {392, 55, 0.11, 0.89, 0.89, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-17,cy=-19, map = {55, 55, 0, 0.11, 0.89, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {55, 389, 0, 0.11, 0.11, 0.89} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 408.236, h = 82, cx = 0, cy = -17 },
        frame_left_img = { texture = "frame_left_img.png", w = 52, h = 403, cx = 0, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 52, h = 403, cx = 0, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.091, 0, 0.092} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {315, 35, 0.091, 0.909, 0, 0.092} },
        stats_tr       = { texture = "stats_border.png", cx=0, cy=0, map = {35, 35, 0.909, 1, 0, 0.092} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {35, 311, 0.909, 1, 0.092, 0.908} },
        stats_br       = { texture = "stats_border.png", cx=0, cy=0, map = {35, 35, 0.909, 1, 0.908, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {315, 35, 0.091, 0.909, 0.908, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {35, 35, 0, 0.091, 0.908, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {35, 311, 0, 0.091, 0.092, 0.908} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-7, cy=6, map = {20, 20, 0, 0.087, 0, 0.088} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {381, 40, 0.087, 0.913, 0, 0.088} },
        paper_tr       = { texture = "paperdoll_border.png", cx=4, cy=6, map = {40, 40, 0.913, 1, 0, 0.088}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {40, 376, 0.913, 1, 0.088, 0.912} },
        paper_br       = { texture = "paperdoll_border.png", cx=4, cy=-3, map = {40, 40, 0.913, 1, 0.912, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {381, 40, 0.087, 0.913, 0.912, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-7, cy=-3, map = {40, 40, 0, 0.087, 0.912, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {40, 376, 0, 0.087, 0.088, 0.912} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- High Heavens
    --========================================================--
    ["High Heavens"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\HighHeavens\\",
        statbgcolor = {0.1686, 0.2863, 0.6667, 1.0}, -- Color behind the stats scrollframe 
        bcolor = {0.1059, 0.1843, 0.4314, 1.0}, -- Border Color 
        hcolor = {0.4753, 0.5365, 0.7153, 1.0}, -- Highlight Color (for buttons/etc)
        ncolor = {0.2847, 0.3474, 0.5451, 1.0}, -- Normal Color (for buttons/etc)
        bncolor = {0.769, 0.604, 0.227, 1.0}, -- Banner Color (for Rewards)
       -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-20,cy=28, map = {68, 68, 0, 0.268, 0, 0.271} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {234, 135, 0.268, 0.732, 0, 0.271} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=20,cy=28, map = {135, 135, 0.732, 1, 0, 0.271} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {135, 229, 0.732, 1, 0.271, 0.729} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=20,cy=-28, map = {135, 135, 0.732, 1, 0.729, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {234, 135, 0.268, 0.732, 0.729, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-20,cy=-28, map = {135, 135, 0, 0.268, 0.729, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {135, 229, 0, 0.268, 0.271, 0.729} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 410, h = 88.322, cx = 0, cy = -14 },
        frame_left_img = { texture = "frame_left_img.png", w = 60, h = 341.4084507, cx = 3, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 60, h = 341.4084507, cx = -3, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.083, 0, 0.084} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {322, 32, 0.083, 0.917, 0, 0.084} },
        stats_tr       = { texture = "stats_border.png", cx=0, cy=0, map = {32, 32, 0.917, 1, 0, 0.084} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {32, 316, 0.917, 1, 0.084, 0.916} },
        stats_br       = { texture = "stats_border.png", cx=0, cy=0, map = {32, 32, 0.917, 1, 0.916, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {322, 32, 0.083, 0.917, 0.916, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {32, 32, 0, 0.083, 0.916, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {32, 316, 0, 0.083, 0.084, 0.916} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-5, cy=3, map = {20, 20, 0, 0.157, 0, 0.162} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {319, 73, 0.157, 0.843, 0, 0.162} },
        paper_tr       = { texture = "paperdoll_border.png", cx=1, cy=3, map = {73, 73, 0.843, 1, 0, 0.162}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {73, 306, 0.843, 1, 0.162, 0.838} },
        paper_br       = { texture = "paperdoll_border.png", cx=1, cy=-3, map = {73, 73, 0.843, 1, 0.838, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {319, 73, 0.157, 0.843, 0.838, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-5, cy=-3, map = {73, 73, 0, 0.157, 0.838, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {73, 306, 0, 0.157, 0.162, 0.838} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Fallen Sanctum (Diablo Inspired)
    --========================================================--
    ["Fallen Sanctum"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\FallenSanctum\\",
        statbgcolor = {  0.3209, 0.0941, 0.1020, 1.0}, -- Color behind the stats scrollframe 932625
        bcolor = {0.4745, 0.1059, 0.1137, 1.0}, -- Border Color 791b1d
        hcolor = {0.6657, 0.2004, 0.1690, 1.0}, -- Highlight Color (for buttons/etc) -- 98011f
        ncolor = {0.5961, 0.0039, 0.1216, 1.0}, -- Normal Color (for buttons/etc) 9d2e26
        bncolor = {  0.020, 0.024, 0.027, 1.0  }, -- Banner Color (for Rewards)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom   
        frame_tl      = { texture = "char_frame_border.png", cx=-17,cy=25, map = {68, 68, 0, 0.229, 0, 0.232} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {379, 160, 0.229, 0.771, 0, 0.232} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=17,cy=25, map = {160, 160, 0.771, 1, 0, 0.232} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {160, 371, 0.771, 1, 0.232, 0.768} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=17,cy=-25, map = {160, 160, 0.771, 1, 0.768, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {379, 160, 0.229, 0.771, 0.768, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-17,cy=-25, map = {160, 160, 0, 0.229, 0.768, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {160, 371, 0, 0.229, 0.232, 0.768} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 410, h = 82, cx = 0, cy = -21 },
        frame_left_img = { texture = "frame_left_img.png", w = 72, h = 403, cx = 10, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 72, h = 403, cx = -10, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {1080, 720, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.119, 0, 0.118} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {288, 45, 0.119, 0.881, 0, 0.118} },
        stats_tr       = { texture = "stats_border.png", cx=0, cy=0, map = {45, 45, 0.881, 1, 0, 0.118} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {45, 291, 0.881, 1, 0.118, 0.882} },
        stats_br       = { texture = "stats_border.png", cx=0, cy=0, map = {45, 45, 0.881, 1, 0.882, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {288, 45, 0.119, 0.881, 0.882, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {45, 45, 0, 0.119, 0.882, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {45, 291, 0, 0.119, 0.118, 0.882} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-7, cy=3, map = {20, 20, 0, 0.139, 0, 0.144} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {339, 65, 0.139, 0.861, 0, 0.144} },
        paper_tr       = { texture = "paperdoll_border.png", cx=4, cy=3, map = {65, 65, 0.861, 1, 0, 0.144}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {65, 322, 0.861, 1, 0.144, 0.856} },
        paper_br       = { texture = "paperdoll_border.png", cx=4, cy=-3, map = {65, 65, 0.861, 1, 0.856, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {339, 65, 0.139, 0.861, 0.856, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-7, cy=-3, map = {65, 65, 0, 0.139, 0.856, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {65, 322, 0, 0.139, 0.144, 0.856} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },
    
    --========================================================--
    -- Explorer (Leatherbound details)
    --========================================================--
    ["Explorer"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\Explorer\\",
        statbgcolor = {0.3843, 0.2627, 0.1961, 1.0}, -- Color behind the stats scrollframe 
        bcolor = {0.2863, 0.1961, 0.1451, 1.0}, -- Border Color
        hcolor = {0.7137, 0.4941, 0.3569, 1.0}, -- Highlight Color (for buttons/etc)
        ncolor = {0.4863, 0.3333, 0.2431, 1.0}, -- Normal Color (for buttons/etc)
        bncolor = {0.184, 0.310, 0.620, 1.0}, -- Banner Color (for Rewards)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-27,cy=33, map = {63, 63, 0, 0.179, 0, 0.181} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {450, 125, 0.179, 0.821, 0, 0.181} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=27,cy=33, map = {125, 125, 0.821, 1, 0, 0.181} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {125, 441, 0.821, 1, 0.181, 0.819} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=27,cy=-30, map = {125, 125, 0.821, 1, 0.819, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {450, 125, 0.179, 0.821, 0.819, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-27,cy=-30, map = {125, 125, 0, 0.179, 0.819, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {125, 441, 0, 0.179, 0.181, 0.819} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 400, h = 93.65, cx = 0, cy = -15 },
        frame_left_img = { texture = "frame_left_img.png", w = 60, h = 331.2329, cx = 0, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 60, h = 331.2329, cx = 0, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.083, 0, 0.084} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {322, 32, 0.083, 0.917, 0, 0.084} },
        stats_tr       = { texture = "stats_border.png", cx=0, cy=0, map = {32, 32, 0.917, 1, 0, 0.084} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {32, 317, 0.917, 1, 0.084, 0.916} },
        stats_br       = { texture = "stats_border.png", cx=0, cy=0, map = {32, 32, 0.917, 1, 0.916, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {322, 32, 0.083, 0.917, 0.916, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {32, 32, 0, 0.083, 0.916, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {32, 317, 0, 0.083, 0.084, 0.916} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-7, cy=6, map = {20, 20, 0, 0.084, 0, 0.088} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {394, 40, 0.084, 0.916, 0, 0.088} },
        paper_tr       = { texture = "paperdoll_border.png", cx=4, cy=6, map = {40, 40, 0.916, 1, 0, 0.088}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {40, 372, 0.916, 1, 0.088, 0.912} },
        paper_br       = { texture = "paperdoll_border.png", cx=4, cy=-3, map = {40, 40, 0.916, 1, 0.912, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {394, 40, 0.084, 0.916, 0.912, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-7, cy=-3, map = {40, 40, 0, 0.084, 0.912, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {40, 372, 0, 0.084, 0.088, 0.912} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Hearthstone Tavern
    --========================================================--
    ["Hearthstone Tavern"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\HearthstoneTavern\\",
        statbgcolor = {0.355, 0.204, 0.118, 1.0}, -- Carved Hearthwood Brown (#5A341E)
        bcolor      = {0.453, 0.243, 0.157, 1.0}, -- Deep Tavern Timber (dark carved wood)
        ncolor      = {0.481, 0.310, 0.196, 1.0}, -- Hearth Oak Medium (neutral warm oak)
        hcolor      = {0.784, 0.404, 0.290, 1.0}, -- Lanternfire Gold (warm orange-gold highlight)
        bncolor     = {0.498, 0.847, 1.000, 1.0}, -- Frostlight Blue (icy swirl accent)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-20,cy=25, map = {65, 65, 0, 0.195, 0, 0.201} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {407, 130, 0.195, 0.805, 0, 0.201} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=20,cy=25, map = {130, 130, 0.805, 1, 0, 0.201} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {130, 388, 0.805, 1, 0.201, 0.799} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=20,cy=-25, map = {130, 130, 0.805, 1, 0.799, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {407, 130, 0.195, 0.805, 0.799, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-20,cy=-25, map = {130, 130, 0, 0.195, 0.799, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {130, 388, 0, 0.195, 0.201, 0.799} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 400, h = 84.294, cx = 0, cy = -20 },
        frame_left_img = { texture = "frame_left_img.png", w = 60, h = 374.79, cx = 10, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 60, h = 374.79, cx = -10, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.077, 0, 0.078} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {332, 30, 0.077, 0.923, 0, 0.078} },
        stats_tr       = { texture = "stats_border.png", cx=0, cy=0, map = {30, 30, 0.923, 1, 0, 0.078} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {30, 324, 0.923, 1, 0.078, 0.922} },
        stats_br       = { texture = "stats_border.png", cx=0, cy=0, map = {30, 30, 0.923, 1, 0.922, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {332, 30, 0.077, 0.923, 0.922, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {30, 30, 0, 0.077, 0.922, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {30, 324, 0, 0.077, 0.078, 0.922} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-10, cy=6, map = {16, 16, 0, 0.108, 0, 0.11} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {362, 50, 0.108, 0.892, 0, 0.11} },
        paper_tr       = { texture = "paperdoll_border.png", cx=4, cy=6, map = {50, 50, 0.892, 1, 0, 0.11}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {50, 356, 0.892, 1, 0.11, 0.89} },
        paper_br       = { texture = "paperdoll_border.png", cx=4, cy=-3, map = {50, 50, 0.892, 1, 0.89, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {362, 50, 0.108, 0.892, 0.89, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-10, cy=-3, map = {50, 50, 0, 0.108, 0.89, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {50, 356, 0, 0.108, 0.11, 0.89} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Witcher
    --========================================================--
    ["Witcher"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\Witcher\\",
        statbgcolor = {0.235, 0.290, 0.341, 1.0}, -- Moonlit Frost Steel (#3C4A57)
        bcolor = {0.290, 0.337, 0.388, 1.0}, -- Moonsteel Edge Grey (#4A5663)
        ncolor      = {0.353, 0.290, 0.235, 1.0}, -- Frost-Tanned Leather (#5A4A3C)
        hcolor      = {0.620, 0.659, 0.722, 1.0}, -- Aether Silver Glow (#9EA8B8)
        bncolor     = {0.776, 0.227, 0.227, 1.0}, -- Mutagen Crimson (#C63A3A)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-19,cy=20, map = {70, 70, 0, 0.272, 0, 0.285} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {311, 185, 0.272, 0.728, 0, 0.285} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=19,cy=20, map = {185, 185, 0.728, 1, 0, 0.285} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {185, 280, 0.728, 1, 0.285, 0.715} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=19,cy=-20, map = {185, 185, 0.728, 1, 0.715, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {311, 185, 0.272, 0.728, 0.715, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-19,cy=-20, map = {185, 185, 0, 0.272, 0.715, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {185, 280, 0, 0.272, 0.285, 0.715} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 400, h = 76.190, cx = 0, cy = -25 },
        frame_left_img = { texture = "frame_left_img.png", w = 50, h = 487, cx = 0, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 50, h = 487, cx = 0, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.115, 0, 0.117} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {302, 45, 0.115, 0.885, 0, 0.117} },
        stats_tr       = { texture = "stats_border.png", cx=0, cy=0, map = {45, 45, 0.885, 1, 0, 0.117} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {45, 294, 0.885, 1, 0.117, 0.883} },
        stats_br       = { texture = "stats_border.png", cx=0, cy=0, map = {45, 45, 0.885, 1, 0.883, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {302, 45, 0.115, 0.885, 0.883, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {45, 45, 0, 0.115, 0.883, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {45, 294, 0, 0.115, 0.117, 0.883} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-10, cy=6, map = {40, 40, 0, 0.197, 0, 0.204} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {282, 92, 0.197, 0.803, 0, 0.204} },
        paper_tr       = { texture = "paperdoll_border.png", cx=4, cy=6, map = {92, 92, 0.803, 1, 0, 0.204}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {92, 268, 0.803, 1, 0.204, 0.796} },
        paper_br       = { texture = "paperdoll_border.png", cx=4, cy=-3, map = {92, 92, 0.803, 1, 0.796, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {282, 92, 0.197, 0.803, 0.796, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-10, cy=-3, map = {92, 92, 0, 0.197, 0.796, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {92, 268, 0, 0.197, 0.204, 0.796} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Silver
    --========================================================--
    ["Moonlit Silver"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\MoonlitSilver\\",
        statbgcolor = {0.280, 0.305, 0.350, 1.0}, -- Moonshadow Steel (#475060)
        bcolor      = {0.300, 0.340, 0.380, 1.0}, -- Argent Edge (#4C5661)
        hcolor      = {0.650, 0.690, 0.740, 1.0}, -- Lunar Highlight (#A6B0BD)
        ncolor      = {0.420, 0.450, 0.490, 1.0}, -- Silverstone Neutral (#6B737D)
        bncolor     = {0.420, 0.520, 0.780, 1.0}, -- Moonlit Sapphire Banner (#6B85C7)

        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-17,cy=20, map = {65, 65, 0, 0.175, 0, 0.179} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {447, 120, 0.175, 0.825, 0, 0.179} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=17,cy=20, map = {120, 120, 0.825, 1, 0, 0.179} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {120, 429, 0.825, 1, 0.179, 0.821} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=17,cy=-18, map = {120, 120, 0.825, 1, 0.821, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {447, 120, 0.175, 0.825, 0.821, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-17,cy=-18, map = {120, 120, 0, 0.175, 0.821, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {120, 429, 0, 0.175, 0.179, 0.821} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 398, h = 96, cx = 0, cy = -23 },
        frame_left_img = { texture = "frame_left_img.png", w = 56, h = 424, cx = 0, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 56, h = 424, cx = 0, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.077, 0, 0.079} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {331, 30, 0.077, 0.923, 0, 0.079} },
        stats_tr       = { texture = "stats_border.png", cx=3, cy=0, map = {30, 30, 0.923, 1, 0, 0.079} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {30, 321, 0.923, 1, 0.079, 0.921} },
        stats_br       = { texture = "stats_border.png", cx=3, cy=0, map = {30, 30, 0.923, 1, 0.921, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {331, 30, 0.077, 0.923, 0.921, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {30, 30, 0, 0.077, 0.921, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {30, 321, 0, 0.077, 0.079, 0.921} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-12, cy=8, map = {40, 40, 0, 0.149, 0, 0.149} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {461, 98, 0.149, 0.851, 0, 0.149} },
        paper_tr       = { texture = "paperdoll_border.png", cx=8, cy=8, map = {98, 98, 0.851, 1, 0, 0.149}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {98, 460, 0.851, 1, 0.149, 0.851} },
        paper_br       = { texture = "paperdoll_border.png", cx=8, cy=-8, map = {98, 98, 0.851, 1, 0.851, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {461, 98, 0.149, 0.851, 0.851, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-12, cy=-8, map = {98, 98, 0, 0.149, 0.851, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {98, 460, 0, 0.149, 0.149, 0.851} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Arcane Glass
    --========================================================--
    ["Arcane Glass"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\ArcaneGlass\\",
        statbgcolor = {0.330, 0.285, 0.380, 1.0}, -- Frosted Aether Violet (#544963)
        bcolor      = {0.620, 0.560, 0.740, 1.0}, -- Arcane Glass Lavender (#9E8EBD)
        hcolor      = {0.780, 0.680, 0.980, 1.0}, -- Amethyst Spellglow (#C7ADF9)
        ncolor      = {0.520, 0.470, 0.620, 1.0}, -- Twilight Glass Lilac (#85789E)
        bncolor = {0.380, 0.780, 0.980, 1.0}, -- Icy Aether Blue (#61C7F9)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-20,cy=27, map = {65, 65, 0, 0.26, 0, 0.264} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {331, 180, 0.26, 0.74, 0, 0.264} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=20,cy=27, map = {180, 180, 0.74, 1, 0, 0.264} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {180, 323, 0.74, 1, 0.264, 0.736} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=20,cy=-27, map = {180, 180, 0.74, 1, 0.736, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {331, 180, 0.26, 0.74, 0.736, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-20,cy=-27, map = {180, 180, 0, 0.26, 0.736, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {180, 323, 0, 0.26, 0.264, 0.736} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 400, h = 93.204, cx = 0, cy = -19 },
        frame_left_img = { texture = "frame_left_img.png", w = 57, h = 471, cx = 0, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 57, h = 471, cx = 0, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.104, 0, 0.105} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {305, 40, 0.104, 0.896, 0, 0.105} },
        stats_tr       = { texture = "stats_border.png", cx=1, cy=0, map = {40, 40, 0.896, 1, 0, 0.105} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {40, 301, 0.896, 1, 0.105, 0.895} },
        stats_br       = { texture = "stats_border.png", cx=1, cy=0, map = {40, 40, 0.896, 1, 0.895, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {305, 40, 0.104, 0.896, 0.895, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {40, 40, 0, 0.104, 0.895, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {40, 301, 0, 0.104, 0.105, 0.895} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-14, cy=7, map = {38, 38, 0, 0.16, 0, 0.166} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {318, 75, 0.16, 0.84, 0, 0.166} },
        paper_tr       = { texture = "paperdoll_border.png", cx=8, cy=7, map = {75, 75, 0.84, 1, 0, 0.166}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {75, 302, 0.84, 1, 0.166, 0.834} },
        paper_br       = { texture = "paperdoll_border.png", cx=8, cy=-5, map = {75, 75, 0.84, 1, 0.834, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {318, 75, 0.16, 0.84, 0.834, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-14, cy=-5, map = {75, 75, 0, 0.16, 0.834, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {75, 302, 0, 0.16, 0.166, 0.834} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Titans
    --========================================================--
    ["Titans"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\Titans\\",
        statbgcolor = {0.305, 0.290, 0.255, 1.0}, -- Titan Granite Dust (#4E4A41)
        bcolor      = {0.520, 0.505, 0.455, 1.0}, -- Forged Stone Alloy (#858174)
        hcolor      = {0.380, 0.820, 0.900, 1.0}, -- Titan Rune Cyan (#61D1E6)
        ncolor      = {0.430, 0.415, 0.380, 1.0}, -- Runeforge Slate (#6E6A61)
        bncolor     = {0.480, 0.900, 0.980, 1.0}, -- Heart of the Makers Blue (#7AE6FA)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-20,cy=23, map = {65, 65, 0, 0.222, 0, 0.224} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {376, 150, 0.222, 0.778, 0, 0.224} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=25,cy=23, map = {150, 150, 0.778, 1, 0, 0.224} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {150, 369, 0.778, 1, 0.224, 0.776} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=25,cy=-23, map = {150, 150, 0.778, 1, 0.776, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {376, 150, 0.222, 0.778, 0.776, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-20,cy=-23, map = {150, 150, 0, 0.222, 0.776, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {150, 369, 0, 0.222, 0.224, 0.776} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 405, h = 96, cx = 0, cy = -17 },
        frame_left_img = { texture = "frame_left_img.png", w = 57, h = 353, cx = 0, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 57, h = 353, cx = 0, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.104, 0, 0.105} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {305, 40, 0.104, 0.896, 0, 0.105} },
        stats_tr       = { texture = "stats_border.png", cx=1, cy=0, map = {40, 40, 0.896, 1, 0, 0.105} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {40, 300, 0.896, 1, 0.105, 0.895} },
        stats_br       = { texture = "stats_border.png", cx=1, cy=0, map = {40, 40, 0.896, 1, 0.895, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {305, 40, 0.104, 0.896, 0.895, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {40, 40, 0, 0.104, 0.895, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {40, 300, 0, 0.104, 0.105, 0.895} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-8, cy=5, map = {40, 40, 0, 0.207, 0, 0.21} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {270, 95, 0.207, 0.793, 0, 0.21} },
        paper_tr       = { texture = "paperdoll_border.png", cx=3, cy=5, map = {95, 95, 0.793, 1, 0, 0.21}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {95, 262, 0.793, 1, 0.21, 0.79} },
        paper_br       = { texture = "paperdoll_border.png", cx=3, cy=-5, map = {95, 95, 0.793, 1, 0.79, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {270, 95, 0.207, 0.793, 0.79, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-8, cy=-5, map = {95, 95, 0, 0.207, 0.79, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {95, 262, 0, 0.207, 0.21, 0.79} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Old Gods
    --========================================================--
    ["Old Gods"] = {
        enabled = true,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\OldGods\\",
        statbgcolor = {0.220, 0.160, 0.300, 1.0}, -- Soft Void Amethyst (#38294C)
        bcolor      = {0.180, 0.140, 0.240, 1.0}, -- Blackened Void Alloy (#2E243D)
        hcolor      = {0.560, 0.260, 0.720, 1.0}, -- Subtle Voidglow Violet (#8F43B7)
        ncolor      = {0.320, 0.280, 0.420, 1.0}, -- Voidshadow Slate (#52486B)
        bncolor     = {0.520, 0.360, 0.900, 1.0}, -- Luminous Void Indigo (#855CE6)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom  
        frame_tl      = { texture = "char_frame_border.png", cx=-22,cy=32, map = {95, 95, 0, 0.28, 0, 0.284} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", cx=0,cy=0, map = {299, 190, 0.28, 0.72, 0, 0.284} },  -- top
        frame_tr      = { texture = "char_frame_border.png", cx=22,cy=32, map = {190, 190, 0.72, 1, 0, 0.284} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", cx=0,cy=0, map = {190, 289, 0.72, 1, 0.284, 0.716} },  -- right
        frame_br      = { texture = "char_frame_border.png", cx=22,cy=-32, map = {190, 190, 0.72, 1, 0.716, 1} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", cx=0,cy=0, map = {299, 190, 0.28, 0.72, 0.716, 1} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", cx=-22,cy=-32, map = {190, 190, 0, 0.28, 0.716, 1} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", cx=0,cy=0, map = {190, 289, 0, 0.28, 0.284, 0.716} },  -- left

        -- Character Frame Images
        frame_top_img =  { texture = "frame_top_img.png", w = 400, h = 80.167, cx = 0, cy = -17 },
        frame_left_img = { texture = "frame_left_img.png", w = 50, h = 428.0702, cx = 0, cy = 0 },
        frame_right_img ={ texture = "frame_right_img.png", w = 50, h = 428.0702, cx = 0, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = {720, 480, 0,1,0,1} },
        frame_item     = { texture = "frame_item.png", map = nil },
        frame_check     = { texture = "check.png", map = nil },
        frame_lock     = { texture = "lock.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", cx=-3, cy=0, map = {15, 15, 0, 0.118, 0, 0.118} },
        stats_t        = { texture = "stats_border.png", cx=0, cy=0, map = {290, 45, 0.118, 0.882, 0, 0.118} },
        stats_tr       = { texture = "stats_border.png", cx=1, cy=0, map = {45, 45, 0.882, 1, 0, 0.118} },
        stats_r        = { texture = "stats_border.png", cx=0, cy=0, map = {45, 290, 0.882, 1, 0.118, 0.882} },
        stats_br       = { texture = "stats_border.png", cx=1, cy=0, map = {45, 45, 0.882, 1, 0.882, 1} },
        stats_b        = { texture = "stats_border.png", cx=0, cy=0, map = {290, 45, 0.118, 0.882, 0.882, 1} },
        stats_bl       = { texture = "stats_border.png", cx=-3, cy=0, map = {45, 45, 0, 0.118, 0.882, 1} },
        stats_l        = { texture = "stats_border.png", cx=0, cy=0, map = {45, 290, 0, 0.118, 0.118, 0.882} },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", cx=-10, cy=6, map = {35, 35, 0, 0.15, 0, 0.155} },
        paper_t        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {328, 70, 0.15, 0.85, 0, 0.155} },
        paper_tr       = { texture = "paperdoll_border.png", cx=4, cy=6, map = {70, 70, 0.85, 1, 0, 0.155}},
        paper_r        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {70, 312, 0.85, 1, 0.155, 0.845} },
        paper_br       = { texture = "paperdoll_border.png", cx=4, cy=-3, map = {70, 70, 0.85, 1, 0.845, 1} },
        paper_b        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {328, 70, 0.15, 0.85, 0.845, 1} },
        paper_bl       = { texture = "paperdoll_border.png", cx=-10, cy=-3, map = {70, 70, 0, 0.15, 0.845, 1} },
        paper_l        = { texture = "paperdoll_border.png", cx=0, cy=0, map = {70, 312, 0, 0.15, 0.155, 0.845} },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

}

function CCS.GetEnabledThemeList()
    local list = {}

    -- Collect enabled themes
    for name, data in pairs(CCS.Themes) do
        if type(data) == "table" and data.enabled == true then
            table.insert(list, name)
        end
    end

    table.sort(list)

    -- Insert "None" at the top
    table.insert(list, 1, "None")

    return list
end
