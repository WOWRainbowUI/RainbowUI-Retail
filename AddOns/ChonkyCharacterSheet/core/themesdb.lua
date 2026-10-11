local addonName, ns = ...
local CCS = ns.CCS

CCS.Themes = {
    enabled = false,
    --========================================================--
    -- Darkmoon Faire
    --========================================================--
    ["Darkmoon Faire"] = {
        enabled = false,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkMoonFaire\\",
        statbgcolor = { 0.137, 0.118, 0.094, 1.0 }, -- Color behind the stats scrollframe 
        bcolor = { 0.486, 0.333, 0.137, 1.0 }, -- Border Color
        hcolor = { 0.671, 0.529, 0.263, 1.0 }, -- Highlight Color (for buttons/etc)
        ncolor = { 0.486, 0.333, 0.137, 1.0 }, -- Normal Color (for buttons/etc)
        -- Character Frame Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom
        frame_tl      = { texture = "char_frame_border.png", map = {} },  -- top-left
        frame_t       = { texture = "char_frame_border.png", map = {} },  -- top
        frame_tr      = { texture = "char_frame_border.png", map = {} },  -- top-right
        frame_r       = { texture = "char_frame_border.png", map = {} },  -- right
        frame_br      = { texture = "char_frame_border.png", map = {} },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", map = {} },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", map = {} },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", map = {} },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = nil, h = nil, cx = 20, cy = -30 },
        frame_left_img = { texture = "frame_left_img.png", w = nil, h = nil, cx = -12, cy = 0 },
        frame_right_img = { texture = "frame_right_img.png", w = nil, h = nil, cx = 12, cy = 0 },
        frame_bg       = { texture = "frame_bg.png", map = nil },
        frame_item     = { texture = "frame_item.png", map = nil },

        -- Stats Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        stats_tl       = { texture = "stats_border.png", map = nil },
        stats_t        = { texture = "stats_border.png", map = nil },
        stats_tr       = { texture = "stats_border.png", map = nil },
        stats_r        = { texture = "stats_border.png", map = nil },
        stats_br       = { texture = "stats_border.png", map = nil },
        stats_b        = { texture = "stats_border.png", map = nil },
        stats_bl       = { texture = "stats_border.png", map = nil },
        stats_l        = { texture = "stats_border.png", map = nil },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        -- Width, Height, Left, Right, Top, Bottom        
        paper_tl       = { texture = "paperdoll_border.png", map = nil },
        paper_t        = { texture = "paperdoll_border.png", map = nil },
        paper_tr       = { texture = "paperdoll_border.png", map = nil },
        paper_r        = { texture = "paperdoll_border.png", map = nil },
        paper_br       = { texture = "paperdoll_border.png", map = nil },
        paper_b        = { texture = "paperdoll_border.png", map = nil },
        paper_bl       = { texture = "paperdoll_border.png", map = nil },
        paper_l        = { texture = "paperdoll_border.png", map = nil },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Alliance
    --========================================================--
    ["Alliance"] = {
        enabled = false,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkMoonFaire\\",
        statbgcolor = { 0.137, 0.118, 0.094, 1.0 },
        -- Character Frame Borders (8 slices)
        frame_tl      = { texture = "char_frame_border.png", map = nil },  -- top-left
        frame_t       = { texture = "char_frame_border.png", map = nil },  -- top
        frame_tr      = { texture = "char_frame_border.png", map = nil },  -- top-right
        frame_r       = { texture = "char_frame_border.png", map = nil },  -- right
        frame_br      = { texture = "char_frame_border.png", map = nil },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", map = nil },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", map = nil },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", map = nil },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_left_img = { texture = "frame_left_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_right_img = { texture = "frame_right_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_bg       = { texture = "frame_bg.png", map = nil },
        frame_item     = { texture = "frame_item.png", map = nil },

        -- Stats Borders (8 slices)
        stats_tl       = { texture = "stats_border.png", map = nil },
        stats_t        = { texture = "stats_border.png", map = nil },
        stats_tr       = { texture = "stats_border.png", map = nil },
        stats_r        = { texture = "stats_border.png", map = nil },
        stats_br       = { texture = "stats_border.png", map = nil },
        stats_b        = { texture = "stats_border.png", map = nil },
        stats_bl       = { texture = "stats_border.png", map = nil },
        stats_l        = { texture = "stats_border.png", map = nil },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        paper_tl       = { texture = "paperdoll_border.png", map = nil },
        paper_t        = { texture = "paperdoll_border.png", map = nil },
        paper_tr       = { texture = "paperdoll_border.png", map = nil },
        paper_r        = { texture = "paperdoll_border.png", map = nil },
        paper_br       = { texture = "paperdoll_border.png", map = nil },
        paper_b        = { texture = "paperdoll_border.png", map = nil },
        paper_bl       = { texture = "paperdoll_border.png", map = nil },
        paper_l        = { texture = "paperdoll_border.png", map = nil },

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
        enabled = false,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkMoonFaire\\",
        statbgcolor = { 0.137, 0.118, 0.094, 1.0 },
        -- Character Frame Borders (8 slices)
        frame_tl      = { texture = "char_frame_border.png", map = nil },  -- top-left
        frame_t       = { texture = "char_frame_border.png", map = nil },  -- top
        frame_tr      = { texture = "char_frame_border.png", map = nil },  -- top-right
        frame_r       = { texture = "char_frame_border.png", map = nil },  -- right
        frame_br      = { texture = "char_frame_border.png", map = nil },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", map = nil },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", map = nil },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", map = nil },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_left_img = { texture = "frame_left_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_right_img = { texture = "frame_right_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_bg       = { texture = "frame_bg.png", map = nil },
        frame_item     = { texture = "frame_item.png", map = nil },

        -- Stats Borders (8 slices)
        stats_tl       = { texture = "stats_border.png", map = nil },
        stats_t        = { texture = "stats_border.png", map = nil },
        stats_tr       = { texture = "stats_border.png", map = nil },
        stats_r        = { texture = "stats_border.png", map = nil },
        stats_br       = { texture = "stats_border.png", map = nil },
        stats_b        = { texture = "stats_border.png", map = nil },
        stats_bl       = { texture = "stats_border.png", map = nil },
        stats_l        = { texture = "stats_border.png", map = nil },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        paper_tl       = { texture = "paperdoll_border.png", map = nil },
        paper_t        = { texture = "paperdoll_border.png", map = nil },
        paper_tr       = { texture = "paperdoll_border.png", map = nil },
        paper_r        = { texture = "paperdoll_border.png", map = nil },
        paper_br       = { texture = "paperdoll_border.png", map = nil },
        paper_b        = { texture = "paperdoll_border.png", map = nil },
        paper_bl       = { texture = "paperdoll_border.png", map = nil },
        paper_l        = { texture = "paperdoll_border.png", map = nil },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },


    --========================================================--
    -- Old God
    --========================================================--
    ["Old God"] = {
        enabled = false,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkMoonFaire\\",
        statbgcolor = { 0.137, 0.118, 0.094, 1.0 },
        -- Character Frame Borders (8 slices)
        frame_tl      = { texture = "char_frame_border.png", map = nil },  -- top-left
        frame_t       = { texture = "char_frame_border.png", map = nil },  -- top
        frame_tr      = { texture = "char_frame_border.png", map = nil },  -- top-right
        frame_r       = { texture = "char_frame_border.png", map = nil },  -- right
        frame_br      = { texture = "char_frame_border.png", map = nil },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", map = nil },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", map = nil },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", map = nil },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_left_img = { texture = "frame_left_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_right_img = { texture = "frame_right_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_bg       = { texture = "frame_bg.png", map = nil },
        frame_item     = { texture = "frame_item.png", map = nil },

        -- Stats Borders (8 slices)
        stats_tl       = { texture = "stats_border.png", map = nil },
        stats_t        = { texture = "stats_border.png", map = nil },
        stats_tr       = { texture = "stats_border.png", map = nil },
        stats_r        = { texture = "stats_border.png", map = nil },
        stats_br       = { texture = "stats_border.png", map = nil },
        stats_b        = { texture = "stats_border.png", map = nil },
        stats_bl       = { texture = "stats_border.png", map = nil },
        stats_l        = { texture = "stats_border.png", map = nil },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        paper_tl       = { texture = "paperdoll_border.png", map = nil },
        paper_t        = { texture = "paperdoll_border.png", map = nil },
        paper_tr       = { texture = "paperdoll_border.png", map = nil },
        paper_r        = { texture = "paperdoll_border.png", map = nil },
        paper_br       = { texture = "paperdoll_border.png", map = nil },
        paper_b        = { texture = "paperdoll_border.png", map = nil },
        paper_bl       = { texture = "paperdoll_border.png", map = nil },
        paper_l        = { texture = "paperdoll_border.png", map = nil },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },
    
    --========================================================--
    -- Monster Hunter (Witcher Inspired)
    --========================================================--
    ["Monster Hunter"] = {
        enabled = false,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkMoonFaire\\",
        statbgcolor = { 0.137, 0.118, 0.094, 1.0 },
        -- Character Frame Borders (8 slices)
        frame_tl      = { texture = "char_frame_border.png", map = nil },  -- top-left
        frame_t       = { texture = "char_frame_border.png", map = nil },  -- top
        frame_tr      = { texture = "char_frame_border.png", map = nil },  -- top-right
        frame_r       = { texture = "char_frame_border.png", map = nil },  -- right
        frame_br      = { texture = "char_frame_border.png", map = nil },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", map = nil },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", map = nil },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", map = nil },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_left_img = { texture = "frame_left_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_right_img = { texture = "frame_right_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_bg       = { texture = "frame_bg.png", map = nil },
        frame_item     = { texture = "frame_item.png", map = nil },

        -- Stats Borders (8 slices)
        stats_tl       = { texture = "stats_border.png", map = nil },
        stats_t        = { texture = "stats_border.png", map = nil },
        stats_tr       = { texture = "stats_border.png", map = nil },
        stats_r        = { texture = "stats_border.png", map = nil },
        stats_br       = { texture = "stats_border.png", map = nil },
        stats_b        = { texture = "stats_border.png", map = nil },
        stats_bl       = { texture = "stats_border.png", map = nil },
        stats_l        = { texture = "stats_border.png", map = nil },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        paper_tl       = { texture = "paperdoll_border.png", map = nil },
        paper_t        = { texture = "paperdoll_border.png", map = nil },
        paper_tr       = { texture = "paperdoll_border.png", map = nil },
        paper_r        = { texture = "paperdoll_border.png", map = nil },
        paper_br       = { texture = "paperdoll_border.png", map = nil },
        paper_b        = { texture = "paperdoll_border.png", map = nil },
        paper_bl       = { texture = "paperdoll_border.png", map = nil },
        paper_l        = { texture = "paperdoll_border.png", map = nil },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Fallen Sanctum (Diablo Inspired)
    --========================================================--
    ["Fallen Sanctum"] =  {
        enabled = false,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkMoonFaire\\",
        statbgcolor = { 0.137, 0.118, 0.094, 1.0 },
        -- Character Frame Borders (8 slices)
        frame_tl      = { texture = "char_frame_border.png", map = nil },  -- top-left
        frame_t       = { texture = "char_frame_border.png", map = nil },  -- top
        frame_tr      = { texture = "char_frame_border.png", map = nil },  -- top-right
        frame_r       = { texture = "char_frame_border.png", map = nil },  -- right
        frame_br      = { texture = "char_frame_border.png", map = nil },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", map = nil },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", map = nil },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", map = nil },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_left_img = { texture = "frame_left_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_right_img = { texture = "frame_right_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_bg       = { texture = "frame_bg.png", map = nil },
        frame_item     = { texture = "frame_item.png", map = nil },

        -- Stats Borders (8 slices)
        stats_tl       = { texture = "stats_border.png", map = nil },
        stats_t        = { texture = "stats_border.png", map = nil },
        stats_tr       = { texture = "stats_border.png", map = nil },
        stats_r        = { texture = "stats_border.png", map = nil },
        stats_br       = { texture = "stats_border.png", map = nil },
        stats_b        = { texture = "stats_border.png", map = nil },
        stats_bl       = { texture = "stats_border.png", map = nil },
        stats_l        = { texture = "stats_border.png", map = nil },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        paper_tl       = { texture = "paperdoll_border.png", map = nil },
        paper_t        = { texture = "paperdoll_border.png", map = nil },
        paper_tr       = { texture = "paperdoll_border.png", map = nil },
        paper_r        = { texture = "paperdoll_border.png", map = nil },
        paper_br       = { texture = "paperdoll_border.png", map = nil },
        paper_b        = { texture = "paperdoll_border.png", map = nil },
        paper_bl       = { texture = "paperdoll_border.png", map = nil },
        paper_l        = { texture = "paperdoll_border.png", map = nil },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Minimalist Black
    --========================================================--
    ["Minimalist Black"] =  {
        enabled = false,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkMoonFaire\\",
        statbgcolor = { 0.137, 0.118, 0.094, 1.0 },
        -- Character Frame Borders (8 slices)
        frame_tl      = { texture = "char_frame_border.png", map = nil },  -- top-left
        frame_t       = { texture = "char_frame_border.png", map = nil },  -- top
        frame_tr      = { texture = "char_frame_border.png", map = nil },  -- top-right
        frame_r       = { texture = "char_frame_border.png", map = nil },  -- right
        frame_br      = { texture = "char_frame_border.png", map = nil },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", map = nil },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", map = nil },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", map = nil },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_left_img = { texture = "frame_left_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_right_img = { texture = "frame_right_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_bg       = { texture = "frame_bg.png", map = nil },
        frame_item     = { texture = "frame_item.png", map = nil },

        -- Stats Borders (8 slices)
        stats_tl       = { texture = "stats_border.png", map = nil },
        stats_t        = { texture = "stats_border.png", map = nil },
        stats_tr       = { texture = "stats_border.png", map = nil },
        stats_r        = { texture = "stats_border.png", map = nil },
        stats_br       = { texture = "stats_border.png", map = nil },
        stats_b        = { texture = "stats_border.png", map = nil },
        stats_bl       = { texture = "stats_border.png", map = nil },
        stats_l        = { texture = "stats_border.png", map = nil },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        paper_tl       = { texture = "paperdoll_border.png", map = nil },
        paper_t        = { texture = "paperdoll_border.png", map = nil },
        paper_tr       = { texture = "paperdoll_border.png", map = nil },
        paper_r        = { texture = "paperdoll_border.png", map = nil },
        paper_br       = { texture = "paperdoll_border.png", map = nil },
        paper_b        = { texture = "paperdoll_border.png", map = nil },
        paper_bl       = { texture = "paperdoll_border.png", map = nil },
        paper_l        = { texture = "paperdoll_border.png", map = nil },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Silverframe
    --========================================================--
    ["Silverframe"] =  {
        enabled = false,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkMoonFaire\\",
        statbgcolor = { 0.137, 0.118, 0.094, 1.0 },
        -- Character Frame Borders (8 slices)
        frame_tl      = { texture = "char_frame_border.png", map = nil },  -- top-left
        frame_t       = { texture = "char_frame_border.png", map = nil },  -- top
        frame_tr      = { texture = "char_frame_border.png", map = nil },  -- top-right
        frame_r       = { texture = "char_frame_border.png", map = nil },  -- right
        frame_br      = { texture = "char_frame_border.png", map = nil },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", map = nil },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", map = nil },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", map = nil },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_left_img = { texture = "frame_left_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_right_img = { texture = "frame_right_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_bg       = { texture = "frame_bg.png", map = nil },
        frame_item     = { texture = "frame_item.png", map = nil },

        -- Stats Borders (8 slices)
        stats_tl       = { texture = "stats_border.png", map = nil },
        stats_t        = { texture = "stats_border.png", map = nil },
        stats_tr       = { texture = "stats_border.png", map = nil },
        stats_r        = { texture = "stats_border.png", map = nil },
        stats_br       = { texture = "stats_border.png", map = nil },
        stats_b        = { texture = "stats_border.png", map = nil },
        stats_bl       = { texture = "stats_border.png", map = nil },
        stats_l        = { texture = "stats_border.png", map = nil },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        paper_tl       = { texture = "paperdoll_border.png", map = nil },
        paper_t        = { texture = "paperdoll_border.png", map = nil },
        paper_tr       = { texture = "paperdoll_border.png", map = nil },
        paper_r        = { texture = "paperdoll_border.png", map = nil },
        paper_br       = { texture = "paperdoll_border.png", map = nil },
        paper_b        = { texture = "paperdoll_border.png", map = nil },
        paper_bl       = { texture = "paperdoll_border.png", map = nil },
        paper_l        = { texture = "paperdoll_border.png", map = nil },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Arcane Glass
    --========================================================--
    ["Arcane Glass"] =  {
        enabled = false,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkMoonFaire\\",
        statbgcolor = { 0.137, 0.118, 0.094, 1.0 },
        -- Character Frame Borders (8 slices)
        frame_tl      = { texture = "char_frame_border.png", map = nil },  -- top-left
        frame_t       = { texture = "char_frame_border.png", map = nil },  -- top
        frame_tr      = { texture = "char_frame_border.png", map = nil },  -- top-right
        frame_r       = { texture = "char_frame_border.png", map = nil },  -- right
        frame_br      = { texture = "char_frame_border.png", map = nil },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", map = nil },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", map = nil },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", map = nil },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_left_img = { texture = "frame_left_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_right_img = { texture = "frame_right_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_bg       = { texture = "frame_bg.png", map = nil },
        frame_item     = { texture = "frame_item.png", map = nil },

        -- Stats Borders (8 slices)
        stats_tl       = { texture = "stats_border.png", map = nil },
        stats_t        = { texture = "stats_border.png", map = nil },
        stats_tr       = { texture = "stats_border.png", map = nil },
        stats_r        = { texture = "stats_border.png", map = nil },
        stats_br       = { texture = "stats_border.png", map = nil },
        stats_b        = { texture = "stats_border.png", map = nil },
        stats_bl       = { texture = "stats_border.png", map = nil },
        stats_l        = { texture = "stats_border.png", map = nil },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        paper_tl       = { texture = "paperdoll_border.png", map = nil },
        paper_t        = { texture = "paperdoll_border.png", map = nil },
        paper_tr       = { texture = "paperdoll_border.png", map = nil },
        paper_r        = { texture = "paperdoll_border.png", map = nil },
        paper_br       = { texture = "paperdoll_border.png", map = nil },
        paper_b        = { texture = "paperdoll_border.png", map = nil },
        paper_bl       = { texture = "paperdoll_border.png", map = nil },
        paper_l        = { texture = "paperdoll_border.png", map = nil },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Leatherbound
    --========================================================--
    ["Leatherbound"] =  {
        enabled = false,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkMoonFaire\\",
        statbgcolor = { 0.137, 0.118, 0.094, 1.0 },
        -- Character Frame Borders (8 slices)
        frame_tl      = { texture = "char_frame_border.png", map = nil },  -- top-left
        frame_t       = { texture = "char_frame_border.png", map = nil },  -- top
        frame_tr      = { texture = "char_frame_border.png", map = nil },  -- top-right
        frame_r       = { texture = "char_frame_border.png", map = nil },  -- right
        frame_br      = { texture = "char_frame_border.png", map = nil },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", map = nil },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", map = nil },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", map = nil },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_left_img = { texture = "frame_left_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_right_img = { texture = "frame_right_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_bg       = { texture = "frame_bg.png", map = nil },
        frame_item     = { texture = "frame_item.png", map = nil },

        -- Stats Borders (8 slices)
        stats_tl       = { texture = "stats_border.png", map = nil },
        stats_t        = { texture = "stats_border.png", map = nil },
        stats_tr       = { texture = "stats_border.png", map = nil },
        stats_r        = { texture = "stats_border.png", map = nil },
        stats_br       = { texture = "stats_border.png", map = nil },
        stats_b        = { texture = "stats_border.png", map = nil },
        stats_bl       = { texture = "stats_border.png", map = nil },
        stats_l        = { texture = "stats_border.png", map = nil },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        paper_tl       = { texture = "paperdoll_border.png", map = nil },
        paper_t        = { texture = "paperdoll_border.png", map = nil },
        paper_tr       = { texture = "paperdoll_border.png", map = nil },
        paper_r        = { texture = "paperdoll_border.png", map = nil },
        paper_br       = { texture = "paperdoll_border.png", map = nil },
        paper_b        = { texture = "paperdoll_border.png", map = nil },
        paper_bl       = { texture = "paperdoll_border.png", map = nil },
        paper_l        = { texture = "paperdoll_border.png", map = nil },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

    --========================================================--
    -- Titans
    --========================================================--
    ["Titans"] =  {
        enabled = false,
        path = "Interface\\AddOns\\ChonkyCharacterSheet\\Themes\\DarkMoonFaire\\",
        statbgcolor = { 0.137, 0.118, 0.094, 1.0 },
        -- Character Frame Borders (8 slices)
        frame_tl      = { texture = "char_frame_border.png", map = nil },  -- top-left
        frame_t       = { texture = "char_frame_border.png", map = nil },  -- top
        frame_tr      = { texture = "char_frame_border.png", map = nil },  -- top-right
        frame_r       = { texture = "char_frame_border.png", map = nil },  -- right
        frame_br      = { texture = "char_frame_border.png", map = nil },  -- bottom-right
        frame_b       = { texture = "char_frame_border.png", map = nil },  -- bottom
        frame_bl      = { texture = "char_frame_border.png", map = nil },  -- bottom-left
        frame_l       = { texture = "char_frame_border.png", map = nil },  -- left

        -- Character Frame Images
        frame_top_img = { texture = "frame_top_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_left_img = { texture = "frame_left_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_right_img = { texture = "frame_right_img.png", w = nil, h = nil, cx = nil, cy = nil },
        frame_bg       = { texture = "frame_bg.png", map = nil },
        frame_item     = { texture = "frame_item.png", map = nil },

        -- Stats Borders (8 slices)
        stats_tl       = { texture = "stats_border.png", map = nil },
        stats_t        = { texture = "stats_border.png", map = nil },
        stats_tr       = { texture = "stats_border.png", map = nil },
        stats_r        = { texture = "stats_border.png", map = nil },
        stats_br       = { texture = "stats_border.png", map = nil },
        stats_b        = { texture = "stats_border.png", map = nil },
        stats_bl       = { texture = "stats_border.png", map = nil },
        stats_l        = { texture = "stats_border.png", map = nil },

        -- Stats Textures
        stats_header   = { texture = "stats_header.png", map = nil },

        -- Paperdoll Borders (8 slices)
        paper_tl       = { texture = "paperdoll_border.png", map = nil },
        paper_t        = { texture = "paperdoll_border.png", map = nil },
        paper_tr       = { texture = "paperdoll_border.png", map = nil },
        paper_r        = { texture = "paperdoll_border.png", map = nil },
        paper_br       = { texture = "paperdoll_border.png", map = nil },
        paper_b        = { texture = "paperdoll_border.png", map = nil },
        paper_bl       = { texture = "paperdoll_border.png", map = nil },
        paper_l        = { texture = "paperdoll_border.png", map = nil },

        -- Reputation + Token (shared)
        rep_header     = { texture = nil, map = nil },
        rep_bar_header = { texture = nil, map = nil },
        rep_bar_main   = { texture = nil, map = nil },
        rep_bar_rep    = { texture = nil, map = nil },
    },

}
