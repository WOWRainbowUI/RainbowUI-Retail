local addonName = ...
local addonPath = "Interface\\AddOns\\" .. addonName

-- ============================================================================
-- SKIN VARIANTS
-- - skinName: current Midnight skin with visible wallpaper background
-- - skinNameNoBackground: same skin but wallpaper alpha forced to 0
-- - skinNameRounded: Midnight (Rounded) variant with alternate bar texture
-- - skinNameRoundedNoBackground: Rounded variant with wallpaper alpha forced to 0
-- - skinNameRoundedBordered: Rounded variant with bordered bar background
-- - skinNameRoundedBorderedNoBackground: Rounded-Bordered variant with wallpaper alpha forced to 0
-- - skinNameMelPlusPlus: Midnight (Mel++) variant with MelliDarkRough bars
-- - skinNameMelPlusPlusNoBackground: Mel++ variant with wallpaper alpha forced to 0
-- - skinNameMelPlus: Midnight (Mel+) variant with MelliDark bars
-- - skinNameMelPlusNoBackground: Mel+ variant with wallpaper alpha forced to 0
-- - skinNameMel: Midnight (Mel) variant with Melli bars
-- - skinNameMelNoBackground: Mel variant with wallpaper alpha forced to 0
-- - skinNameDF: Midnight (DF) variant with Dragonflight bars
-- - skinNameDFNoBackground: DF variant with wallpaper alpha forced to 0
-- - skinNameSv2: Midnight (Sv2) variant with Smoothv2 bars
-- - skinNameSv2NoBackground: Sv2 variant with wallpaper alpha forced to 0
-- ============================================================================
local skinName = "|cff7fd8ff至暗之夜|r"
local skinNameNoBackground = "|cff7fd8ff至暗之夜|r (無背景)"
local skinNameRounded = "|cff7fd8ff至暗之夜|r (圓角)"
local skinNameRoundedNoBackground = "|cff7fd8ff至暗之夜|r (圓角 無背景)"
local skinNameRoundedBordered = "|cff7fd8ff至暗之夜|r (圓角外框)"
local skinNameRoundedBorderedNoBackground = "|cff7fd8ff至暗之夜|r (圓角外框 無背景)"
local skinNameMelPlusPlus = "|cff7fd8ff至暗之夜|r (Mel++)"
local skinNameMelPlusPlusNoBackground = "|cff7fd8ff至暗之夜|r (Mel++ 無背景)"
local skinNameMelPlus = "|cff7fd8ff至暗之夜|r (Mel+)"
local skinNameMelPlusNoBackground = "|cff7fd8ff至暗之夜|r (Mel+ 無背景)"
local skinNameMel = "|cff7fd8ff至暗之夜|r (Mel)"
local skinNameMelNoBackground = "|cff7fd8ff至暗之夜|r (Mel 無背景)"
local skinNameDF = "|cff7fd8ff至暗之夜|r (DF)"
local skinNameDFNoBackground = "|cff7fd8ff至暗之夜|r (DF 無背景)"
local skinNameSv2 = "|cff7fd8ff至暗之夜|r (Sv2)"
local skinNameSv2NoBackground = "|cff7fd8ff至暗之夜|r (Sv2 無背景)"

-- ============================================================================
-- TEXTURE CONFIG
-- Change these file paths to swap textures for base and variant skins.
-- ============================================================================
local textureFiles = {
    header = addonPath .. "\\Textures\\ui-damagemeters-header-bar-2x.png",
    bar = addonPath .. "\\Textures\\BlizzardDF_bar",
    windowBackground = addonPath .. "\\Textures\\damagemeters-background.png",

    -- Rounded variant bar texture.
    roundedBar = addonPath .. "\\Textures\\ui-hud-cooldownmanager-bar-2x.png",

    -- Rounded variant bar background texture.
    roundedBarBackground = addonPath .. "\\Textures\\ui-damagemeters-bar-shadowbg-2x.png",

    -- Rounded-Bordered variant bar texture (custom matched canvas).
    roundedBorderedBar = addonPath .. "\\Textures\\rounded_fill_256x32(y1).png",

    -- Rounded-Bordered variant bar background texture.
    roundedBorderedBarBackground = addonPath .. "\\Textures\\rounded_bg_256x32.png",

    -- Shared flat bar background (used by all non-rounded skins).
    solidBarBackground = addonPath .. "\\Textures\\solid.png",

    -- Mel++ variant bar texture.
    melPlusPlusBar = addonPath .. "\\Textures\\MelliDarkRough.tga",

    -- Mel+ variant bar texture.
    melPlusBar = addonPath .. "\\Textures\\MelliDark.tga",

    -- Mel variant bar texture.
    melBar = addonPath .. "\\Textures\\Melli.tga",

    -- Dragonflight variant bar texture.
    dfBar = addonPath .. "\\Textures\\Dragonflight.tga",

    -- Smoothv2 variant bar texture.
    sv2Bar = addonPath .. "\\Textures\\Smoothv2.tga"
}

local textureHeader = "Midnight Header"
local textureBar = "Midnight Bar"
local textureBarRounded = "Midnight Rounded Bar"
local textureBarRoundedBordered = "Midnight Rounded-Bordered Bar"
local textureBarMelPlusPlus = "Midnight Mel++ Bar"
local textureBarMelPlus = "Midnight Mel+ Bar"
local textureBarMel = "Midnight Mel Bar"
local textureBarDF = "Midnight DF Bar"
local textureBarSv2 = "Midnight Sv2 Bar"
local textureBarRoundedBackground = "Midnight Rounded Bar Background"
local textureBarRoundedBorderedBackground = "Midnight Rounded-Bordered Bar Background"
local textureBarBackgroundSolid = "Midnight Solid Bar Background"

-- ============================================================================
-- STYLE CONFIG
-- Central place for alpha + padding/inset values.
-- ============================================================================
local styleConfig = {
    -- Main Midnight skin / shared defaults.
    -- Window wallpaper alpha (0-1).
    wallpaperAlpha = 0.4,
    -- Horizontal inset for bar+icon group as % of window width.
    barInsetPercent = 0.02,
    -- Bar height in pixels (major factor for how many bars fit).
    barHeight = 20,
    -- Rounded skin row height override (Rounded / Rounded 無背景 / Rounded-Bordered).
    roundedRowHeight = 24,
    -- Vertical spacing between bars.
    barSpacingBetween = 5,
    -- Vertical gap between header and first bar.
    barOffsetTop = 0,
    -- Vertical gap between last bar and bottom of the window.
    barOffsetBottom = 0,
    -- Horizontal inset for wallpaper as % of window width.
    backgroundInsetPercent = 0.00,
    -- Crop wallpaper texture on all sides (0.02 = 2% per side).
    wallpaperTexCoordInset = 0.02,
    -- Dark bar background alpha behind the class-colored fill (0-1).
    barBackgroundAlpha = 0.4,
    -- Baseframe backdrop alpha (keep 0 when using only wallpaper).
    windowBaseBgAlpha = 0,

    -- Header controls.
    titlebarHeight = 32,
    -- Header title text size.
    headerTextSize = 12,
    -- Horizontal crop for header texture (0-1). Use to trim transparent side padding.
    headerTexCoordLeft = 0.045,
    headerTexCoordRight = 0.965,    
    headerTexCoordTop = 4 / 60,
    headerTexCoordBottom = 56 / 60,

    -- Row controls.
    barFontSize = 14,
    rowSpaceLeft = 5,
    rowSpaceRight = -5,
    defaultIconOffset = {-30, 0},

    -- No-background variants share this override value.
    noBackgroundSkin = {
        wallpaperAlpha = 0.0
    }
}

-- Cached style values used throughout the skin builder and runtime adjusters.
local wallpaperAlphaDefault = styleConfig.wallpaperAlpha
local wallpaperAlphaNoBackground = styleConfig.noBackgroundSkin.wallpaperAlpha
local specIconInset = 2 / 512
local barInsetPercent = styleConfig.barInsetPercent
local backgroundInsetPercent = styleConfig.backgroundInsetPercent
local wallpaperTexCoordInset = styleConfig.wallpaperTexCoordInset
local headerTexCoordLeft = styleConfig.headerTexCoordLeft
local headerTexCoordRight = styleConfig.headerTexCoordRight
local headerTexCoordTop = styleConfig.headerTexCoordTop
local headerTexCoordBottom = styleConfig.headerTexCoordBottom

-- Runtime state guards.
-- hookedSizeFrames is weak-keyed so frames can still be garbage-collected.
local hookedSizeFrames = setmetatable({}, {__mode = "k"})
local classIconHookInstalled = false
local adjustmentRefreshQueued = false
local runningSkinRefresh = false

-- True when the provided skin name belongs to any Midnight variant.
local function isMidnightSkin(skin)
    return skin == skinName
        or skin == skinNameNoBackground
        or skin == skinNameRounded
        or skin == skinNameRoundedNoBackground
        or skin == skinNameRoundedBordered
        or skin == skinNameRoundedBorderedNoBackground
        or skin == skinNameMelPlusPlus
        or skin == skinNameMelPlusPlusNoBackground
        or skin == skinNameMelPlus
        or skin == skinNameMelPlusNoBackground
        or skin == skinNameMel
        or skin == skinNameMelNoBackground
        or skin == skinNameDF
        or skin == skinNameDFNoBackground
        or skin == skinNameSv2
        or skin == skinNameSv2NoBackground
end

-- Applies a tiny inset crop to spec icons, but only on Midnight windows.
local function applyMidnightSpecInsetToTexture(texture, instance)
    if not texture or not instance or not isMidnightSkin(instance.skin) then
        return
    end

    local rowInfo = instance.row_info
    if not rowInfo or not rowInfo.use_spec_icons then
        return
    end

    local specFile = rowInfo.spec_file
    if not specFile or texture:GetTexture() ~= specFile then
        return
    end

    local l, r, t, b = texture:GetTexCoord()
    if not l or not r or not t or not b then
        return
    end

    if (r - l) <= (specIconInset * 2) or (b - t) <= (specIconInset * 2) then
        return
    end

    texture:SetTexCoord(l + specIconInset, r - specIconInset, t + specIconInset, b - specIconInset)
end

-- Installs a single hook into Details.SetClassIcon so Midnight can tweak spec icon texcoords.
local function ensureClassIconHook()
    if classIconHookInstalled or not hooksecurefunc or not Details or not Details.SetClassIcon then
        return
    end

    -- Keep spec icon crop local to Midnight windows instead of mutating global coords.
    hooksecurefunc(Details, "SetClassIcon", function(actorObject, texture, instance)
        applyMidnightSpecInsetToTexture(texture, instance)
    end)

    classIconHookInstalled = true
end

-- Sets custom titlebar crop only for Midnight skins; resets to full texture for other skins.
local function updateTitleBarTexCoordForInstance(instance)
    if not instance or not instance.baseframe or not instance.baseframe.titleBar or not instance.baseframe.titleBar.texture then
        return
    end

    if isMidnightSkin(instance.skin) then
        instance.baseframe.titleBar.texture:SetTexCoord(headerTexCoordLeft, headerTexCoordRight, headerTexCoordTop, headerTexCoordBottom)
    else
        instance.baseframe.titleBar.texture:SetTexCoord(0, 1, 0, 1)
    end
end

-- Recomputes left/right bar insets from current window width so bars stay proportionally padded.
local function applyBarInsetsForInstance(instance)
    if not instance or not isMidnightSkin(instance.skin) then
        return
    end

    local baseframe = instance.baseframe
    local rowInfo = instance.row_info
    if not baseframe or not rowInfo or not rowInfo.space or not rowInfo.row_offsets then
        return
    end

    local width = baseframe:GetWidth() or 0
    if width <= 0 then
        return
    end

    local insetX = math.floor((width * barInsetPercent) + 0.5)
    local iconOffsetX = -30
    if rowInfo.icon_offset and rowInfo.icon_offset[1] then
        iconOffsetX = rowInfo.icon_offset[1]
    end

    local targetLeft = insetX - iconOffsetX
    local targetRight = (-2 * insetX) + iconOffsetX
    if rowInfo.space.left == 0
        and rowInfo.space.right == 0
        and rowInfo.row_offsets.left == targetLeft
        and rowInfo.row_offsets.right == targetRight
        and instance._midnightBarInsetX == insetX
        and instance._midnightBarIconOffsetX == iconOffsetX
    then
        return
    end

    -- Keep icon+bar group inset by percentage on left and right only.
    rowInfo.space.left = 0
    rowInfo.space.right = 0
    rowInfo.row_offsets.left = targetLeft
    rowInfo.row_offsets.right = targetRight

    instance._midnightBarInsetX = insetX
    instance._midnightBarIconOffsetX = iconOffsetX

    if instance.SetBarGrowDirection then
        pcall(instance.SetBarGrowDirection, instance, instance.bars_grow_direction)
    end

end

-- Reanchors wallpaper each time size changes so it covers header + body using configured insets.
local function applyWallpaperInsetsForInstance(instance)
    if not instance or not isMidnightSkin(instance.skin) then
        return
    end

    local baseframe = instance.baseframe
    if not baseframe or not baseframe.wallpaper then
        return
    end

    local width = baseframe:GetWidth() or 0
    if width <= 0 then
        return
    end

    local insetX = math.floor((width * backgroundInsetPercent) + 0.5)

    -- Anchor wallpaper to the title bar top so header + body share the same background.
    local topFrame = baseframe.titleBar or baseframe
    baseframe.wallpaper:ClearAllPoints()
    baseframe.wallpaper:SetPoint("topleft", topFrame, "topleft", insetX, 0)
    baseframe.wallpaper:SetPoint("bottomright", baseframe, "bottomright", -insetX, 0)
end

-- Hides the default no-statusbar corner ornaments that can leak through on Midnight skins.
local function hideNoStatusbarCornersForInstance(instance)
    if not instance or not isMidnightSkin(instance.skin) then
        return
    end

    local baseframe = instance.baseframe
    local rodape = baseframe and baseframe.rodape
    if not rodape then
        return
    end

    if rodape.esquerdo_nostatusbar then
        rodape.esquerdo_nostatusbar:Hide()
    end
    if rodape.direita_nostatusbar then
        rodape.direita_nostatusbar:Hide()
    end
end

-- Hooks window resize once per frame so percentage-based insets stay correct while resizing.
local function ensureBarInsetResizeHook(instance)
    if not instance or not instance.baseframe then
        return
    end

    if hookedSizeFrames[instance.baseframe] then
        return
    end

    instance.baseframe:HookScript("OnSizeChanged", function()
        applyBarInsetsForInstance(instance)
        applyWallpaperInsetsForInstance(instance)
    end)
    hookedSizeFrames[instance.baseframe] = true
end

-- Runs all runtime visual fixes over active Details windows.
local function applyMidnightAdjustmentsForAllInstances()
    if not Details or not Details.GetNumInstances or not Details.GetInstance then
        return
    end

    for instanceId = 1, Details:GetNumInstances() do
        local instance = Details:GetInstance(instanceId)
        if instance and instance.baseframe and instance.ativa then
            updateTitleBarTexCoordForInstance(instance)

            if isMidnightSkin(instance.skin) then
                ensureBarInsetResizeHook(instance)
                applyBarInsetsForInstance(instance)
                applyWallpaperInsetsForInstance(instance)
                hideNoStatusbarCornersForInstance(instance)
            end
        end
    end
end

-- Debounces adjustment passes to avoid running multiple times in the same frame.
local function scheduleMidnightAdjustments()
    if adjustmentRefreshQueued then
        return
    end

    adjustmentRefreshQueued = true

    local runAdjustments = function()
        adjustmentRefreshQueued = false
        applyMidnightAdjustmentsForAllInstances()
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(0, runAdjustments)
    else
        runAdjustments()
    end
end

-- Registers all textures used by Midnight skins in LibSharedMedia.
local function registerMedia()
    if not LibStub then
        return
    end

    local LSM = LibStub("LibSharedMedia-3.0", true)
    if not LSM then
        return
    end

    LSM:Register("statusbar", textureHeader, textureFiles.header)
    LSM:Register("statusbar", textureBar, textureFiles.bar)
    LSM:Register("statusbar", textureBarRounded, textureFiles.roundedBar)
    LSM:Register("statusbar", textureBarRoundedBordered, textureFiles.roundedBorderedBar)
    LSM:Register("statusbar", textureBarMelPlusPlus, textureFiles.melPlusPlusBar)
    LSM:Register("statusbar", textureBarMelPlus, textureFiles.melPlusBar)
    LSM:Register("statusbar", textureBarMel, textureFiles.melBar)
    LSM:Register("statusbar", textureBarDF, textureFiles.dfBar)
    LSM:Register("statusbar", textureBarSv2, textureFiles.sv2Bar)
    LSM:Register("statusbar", textureBarRoundedBackground, textureFiles.roundedBarBackground)
    LSM:Register("statusbar", textureBarRoundedBorderedBackground, textureFiles.roundedBorderedBarBackground)
    LSM:Register("statusbar", textureBarBackgroundSolid, textureFiles.solidBarBackground)
end

-- Builds a Details skin table with optional wallpaper alpha and bar texture overrides.
local function buildSkinTable(wallpaperAlpha, textureOverrides)
    if type(wallpaperAlpha) ~= "number" then
        wallpaperAlpha = wallpaperAlphaDefault
    end

    textureOverrides = textureOverrides or {}
    local barTextureName = textureOverrides.barTextureName or textureBar
    local barTextureFile = textureOverrides.barTextureFile or textureFiles.bar
    local barBackgroundTextureName = textureOverrides.barBackgroundTextureName or textureBarBackgroundSolid
    local barBackgroundTextureFile = textureOverrides.barBackgroundTextureFile or textureFiles.solidBarBackground
    local barBackgroundAlpha = textureOverrides.barBackgroundAlpha or styleConfig.barBackgroundAlpha
    local barBackgroundColor = textureOverrides.barBackgroundColor or {0, 0, 0, barBackgroundAlpha}
    local rowHeight = textureOverrides.rowHeight or styleConfig.barHeight
    local defaultIconOffset = styleConfig.defaultIconOffset or {-30, 0}
    local iconOffset = textureOverrides.iconOffset or defaultIconOffset
    local attributeTextShadow = textureOverrides.attributeTextShadow == true
    local rowTextShadow = textureOverrides.rowTextShadow == true
    local rowTextOutlineSmall = textureOverrides.rowTextOutlineSmall == true
    local rowTextShadowColor = textureOverrides.rowTextShadowColor or {0, 0, 0, 1}

    local version = "1.0.0"
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        version = C_AddOns.GetAddOnMetadata(addonName, "Version") or version
    end

    local skinTable = {
        file = [[Interface\AddOns\Details\images\skins\default_skin.blp]],
        author = "Midnight",
        version = version,
        desc = "Midnight skin.",
        no_cache = true,

        micro_frames = {
            color = {1, 1, 1, 1},
            font = "Friz Quadrata TT",
            size = 12,
            textymod = 1
        },

        can_change_alpha_head = false,
        icon_anchor_main = {-1, -5},
        icon_anchor_plugins = {-7, -13},
        icon_plugins_size = {19, 18},

        icon_point_anchor = {-37, 0},
        left_corner_anchor = {-107, 0},
        right_corner_anchor = {96, 0},

        icon_point_anchor_bottom = {-37, 12},
        left_corner_anchor_bottom = {-107, 0},
        right_corner_anchor_bottom = {96, 0},

        icon_on_top = true,
        icon_ignore_alpha = true,
        icon_titletext_position = {3, 3},

        instance_cprops = {
            titlebar_shown = true,
            titlebar_height = styleConfig.titlebarHeight,
            titlebar_texture = textureHeader,
            titlebar_texture_color = {1, 1, 1, 1},

            toolbar_icon_file = "Interface\\AddOns\\Details\\images\\toolbar_icons_shadow",
            toolbar_side = 1,
            menu_anchor = {5, 10, side = 2},
            menu_anchor_down = {16, -3},
            attribute_text = {
                enabled = true,
                shadow = attributeTextShadow,
                side = 1,
                text_size = styleConfig.headerTextSize,
                custom_text = "{name}",
                text_face = "Friz Quadrata TT",
                anchor = {-4, 10},
                text_color = {
                    NORMAL_FONT_COLOR.r,
                    NORMAL_FONT_COLOR.g,
                    NORMAL_FONT_COLOR.b,
                    NORMAL_FONT_COLOR.a
                },
                enable_custom_text = false,
                show_timer = true
            },

            row_info = {
                texture_highlight = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
                fixed_text_color = {1, 1, 1},
                fixed_texture_color = {1, 1, 1, 1},
                fixed_texture_background_color = {
                    barBackgroundColor[1] or 0,
                    barBackgroundColor[2] or 0,
                    barBackgroundColor[3] or 0,
                    barBackgroundColor[4] or barBackgroundAlpha
                },

                texture_background_class_color = false,
                texture_class_colors = true,
                alpha = 1,

                height = rowHeight,
                space = {left = styleConfig.rowSpaceLeft, right = styleConfig.rowSpaceRight, between = styleConfig.barSpacingBetween},
                row_offsets = {left = 30, right = -40, top = styleConfig.barOffsetTop, bottom = styleConfig.barOffsetBottom},

                no_icon = false,
                start_after_icon = true,
                use_spec_icons = true,
                spec_file = addonPath .. "\\Textures\\spec_icons_normal.jpg",
                icon_mask = "",
                icon_file = addonPath .. "\\Textures\\classes_small",
                icon_offset = {iconOffset[1] or defaultIconOffset[1] or -30, iconOffset[2] or defaultIconOffset[2] or 0},
                icon_size_offset = 0,

                texture = barTextureName,
                texture_file = barTextureFile,
                texture_background = barBackgroundTextureName,
                texture_background_file = barBackgroundTextureFile,

                font_face = "Friz Quadrata TT",
                font_face_file = "Fonts\\FRIZQT__.TTF",
                font_size = styleConfig.barFontSize,
                text_yoffset = 0,

                textL_show_number = true,
                textL_enable_custom_text = false,
                textL_custom_text = "{data3}",
                textL_class_colors = false,
                textL_outline = rowTextShadow,
                textL_outline_small = rowTextOutlineSmall,
                textL_outline_small_color = {
                    rowTextShadowColor[1] or 0,
                    rowTextShadowColor[2] or 0,
                    rowTextShadowColor[3] or 0,
                    rowTextShadowColor[4] or 1
                },

                textR_enable_custom_text = false,
                textR_custom_text = "{data1} ({data2}, {data3}%)",
                textR_show_data = {true, true, true},
                textR_separator = ",",
                textR_bracket = "(",
                textR_class_colors = false,
                textR_outline = rowTextShadow,
                textR_outline_small = rowTextOutlineSmall,
                textR_outline_small_color = {
                    rowTextShadowColor[1] or 0,
                    rowTextShadowColor[2] or 0,
                    rowTextShadowColor[3] or 0,
                    rowTextShadowColor[4] or 1
                },

                percent_type = 1,
                fast_ps_update = false
            },

            show_statusbar = false,
            show_sidebars = true,
            menu_icons_size = 1.07,
            menu_icons_alpha = 1,

            color = {0.33, 0.33, 0.33, 0},
            bg_r = 1,
            bg_g = 1,
            bg_b = 1,
            bg_alpha = styleConfig.windowBaseBgAlpha,

            color_buttons = {
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                NORMAL_FONT_COLOR.a
            },
            auto_hide_menu = {left = false, right = false},
            hide_icon = true,

            bars_sort_direction = 1,
            bars_grow_direction = 1,
            plugins_grow_direction = 1,
            stretch_button_side = 1,

            instance_button_anchor = {-27, 1},
            micro_displays_locked = true,
            micro_displays_side = 2,

            menu_alpha = {
                enabled = false,
                onenter = 1,
                onleave = 1,
                iconstoo = true,
                ignorebars = false
            },

            statusbar_info = {
                alpha = 1,
                overlay = {1, 1, 1}
            },

            tooltip = {
                n_abilities = 3,
                n_enemies = 3
            },

            wallpaper = {
                enabled = true,
                texture = textureFiles.windowBackground,
                texcoord = {
                    wallpaperTexCoordInset,
                    1 - wallpaperTexCoordInset,
                    wallpaperTexCoordInset,
                    1 - wallpaperTexCoordInset
                },
                overlay = {1, 1, 1, 1},
                anchor = "all",
                height = 114.04,
                alpha = wallpaperAlpha,
                width = 283
            }
        }
    }

    return skinTable
end

-- Installs all Midnight skin variants into Details.
local function installSkins()
    if not Details or not Details.InstallSkin then
        return false
    end

    -- Normal Midnight skin (wallpaper visible)
    local okMain = pcall(Details.InstallSkin, Details, skinName, buildSkinTable(wallpaperAlphaDefault))

    -- Second skin variant: exact same skin with no wallpaper background
    local okNoBackground = pcall(Details.InstallSkin, Details, skinNameNoBackground, buildSkinTable(wallpaperAlphaNoBackground))

    -- Third skin variant: same as main Midnight, but with rounded bar texture.
    local okRounded = pcall(Details.InstallSkin, Details, skinNameRounded, buildSkinTable(wallpaperAlphaDefault, {
        rowHeight = styleConfig.roundedRowHeight,
        barTextureName = textureBarRounded,
        barTextureFile = textureFiles.roundedBar,
        barBackgroundTextureName = textureBarRoundedBackground,
        barBackgroundTextureFile = textureFiles.roundedBarBackground,
        -- Use texture's own color/alpha without darkening.
        barBackgroundColor = {1, 1, 1, 1}
    }))

    -- Fourth skin variant: rounded bars with no wallpaper background.
    local okRoundedNoBackground = pcall(Details.InstallSkin, Details, skinNameRoundedNoBackground, buildSkinTable(wallpaperAlphaNoBackground, {
        rowHeight = styleConfig.roundedRowHeight,
        barTextureName = textureBarRounded,
        barTextureFile = textureFiles.roundedBar,
        barBackgroundTextureName = textureBarRoundedBackground,
        barBackgroundTextureFile = textureFiles.roundedBarBackground,
        -- Use texture's own color/alpha without darkening.
        barBackgroundColor = {1, 1, 1, 1}
    }))

    -- Fifth skin variant: rounded bars with bordered background and full bg alpha.
    local okRoundedBordered = pcall(Details.InstallSkin, Details, skinNameRoundedBordered, buildSkinTable(wallpaperAlphaDefault, {
        rowHeight = styleConfig.roundedRowHeight,
        barTextureName = textureBarRoundedBordered,
        barTextureFile = textureFiles.roundedBorderedBar,
        barBackgroundTextureName = textureBarRoundedBorderedBackground,
        barBackgroundTextureFile = textureFiles.roundedBorderedBarBackground,
        -- Keep fill start aligned with row background on the left edge.
        iconOffset = {-styleConfig.roundedRowHeight, 0},
        -- Rounded-Bordered: add shadow to header text and row texts.
        attributeTextShadow = true,
        rowTextShadow = true,
        -- Use texture's own color/alpha without darkening.
        barBackgroundColor = {1, 1, 1, 1}
    }))

    -- Sixth skin variant: rounded bordered bars with no wallpaper background.
    local okRoundedBorderedNoBackground = pcall(Details.InstallSkin, Details, skinNameRoundedBorderedNoBackground, buildSkinTable(wallpaperAlphaNoBackground, {
        rowHeight = styleConfig.roundedRowHeight,
        barTextureName = textureBarRoundedBordered,
        barTextureFile = textureFiles.roundedBorderedBar,
        barBackgroundTextureName = textureBarRoundedBorderedBackground,
        barBackgroundTextureFile = textureFiles.roundedBorderedBarBackground,
        -- Keep fill start aligned with row background on the left edge.
        iconOffset = {-styleConfig.roundedRowHeight, 0},
        -- Rounded-Bordered: add shadow to header text and row texts.
        attributeTextShadow = true,
        rowTextShadow = true,
        -- Use texture's own color/alpha without darkening.
        barBackgroundColor = {1, 1, 1, 1}
    }))

    -- Seventh skin variant: Mel++ bars with wallpaper visible.
    local okMelPlusPlus = pcall(Details.InstallSkin, Details, skinNameMelPlusPlus, buildSkinTable(wallpaperAlphaDefault, {
        barTextureName = textureBarMelPlusPlus,
        barTextureFile = textureFiles.melPlusPlusBar
    }))

    -- Eighth skin variant: Mel++ bars with no wallpaper background.
    local okMelPlusPlusNoBackground = pcall(Details.InstallSkin, Details, skinNameMelPlusPlusNoBackground, buildSkinTable(wallpaperAlphaNoBackground, {
        barTextureName = textureBarMelPlusPlus,
        barTextureFile = textureFiles.melPlusPlusBar
    }))

    -- Ninth skin variant: Mel+ bars with wallpaper visible.
    local okMelPlus = pcall(Details.InstallSkin, Details, skinNameMelPlus, buildSkinTable(wallpaperAlphaDefault, {
        barTextureName = textureBarMelPlus,
        barTextureFile = textureFiles.melPlusBar
    }))

    -- Tenth skin variant: Mel+ bars with no wallpaper background.
    local okMelPlusNoBackground = pcall(Details.InstallSkin, Details, skinNameMelPlusNoBackground, buildSkinTable(wallpaperAlphaNoBackground, {
        barTextureName = textureBarMelPlus,
        barTextureFile = textureFiles.melPlusBar
    }))

    -- Eleventh skin variant: Mel bars with wallpaper visible.
    local okMel = pcall(Details.InstallSkin, Details, skinNameMel, buildSkinTable(wallpaperAlphaDefault, {
        barTextureName = textureBarMel,
        barTextureFile = textureFiles.melBar
    }))

    -- Twelfth skin variant: Mel bars with no wallpaper background.
    local okMelNoBackground = pcall(Details.InstallSkin, Details, skinNameMelNoBackground, buildSkinTable(wallpaperAlphaNoBackground, {
        barTextureName = textureBarMel,
        barTextureFile = textureFiles.melBar
    }))

    -- Thirteenth skin variant: Dragonflight bars with wallpaper visible.
    local okDF = pcall(Details.InstallSkin, Details, skinNameDF, buildSkinTable(wallpaperAlphaDefault, {
        barTextureName = textureBarDF,
        barTextureFile = textureFiles.dfBar
    }))

    -- Fourteenth skin variant: Dragonflight bars with no wallpaper background.
    local okDFNoBackground = pcall(Details.InstallSkin, Details, skinNameDFNoBackground, buildSkinTable(wallpaperAlphaNoBackground, {
        barTextureName = textureBarDF,
        barTextureFile = textureFiles.dfBar
    }))

    -- Fifteenth skin variant: Smoothv2 bars with wallpaper visible.
    local okSv2 = pcall(Details.InstallSkin, Details, skinNameSv2, buildSkinTable(wallpaperAlphaDefault, {
        barTextureName = textureBarSv2,
        barTextureFile = textureFiles.sv2Bar
    }))

    -- Sixteenth skin variant: Smoothv2 bars with no wallpaper background.
    local okSv2NoBackground = pcall(Details.InstallSkin, Details, skinNameSv2NoBackground, buildSkinTable(wallpaperAlphaNoBackground, {
        barTextureName = textureBarSv2,
        barTextureFile = textureFiles.sv2Bar
    }))

    return okMain
        and okNoBackground
        and okRounded
        and okRoundedNoBackground
        and okRoundedBordered
        and okRoundedBorderedNoBackground
        and okMelPlusPlus
        and okMelPlusPlusNoBackground
        and okMelPlus
        and okMelPlusNoBackground
        and okMel
        and okMelNoBackground
        and okDF
        and okDFNoBackground
        and okSv2
        and okSv2NoBackground
end

-- Reapplies skin to active Midnight windows and then runs the runtime adjustment pass.
local function refreshActiveWindows()
    if not Details or not Details.GetNumInstances or not Details.GetInstance then
        return
    end

    runningSkinRefresh = true
    for instanceId = 1, Details:GetNumInstances() do
        local instance = Details:GetInstance(instanceId)
        if instance and instance.baseframe and instance.ativa and instance.ChangeSkin and isMidnightSkin(instance.skin) then
            pcall(instance.ChangeSkin, instance)
        end
    end
    runningSkinRefresh = false

    applyMidnightAdjustmentsForAllInstances()
end

-- Waits for Details load state, then registers media, installs skins, hooks, and refreshes windows.
local function setupAfterLogin()
    if Details and Details.IsLoaded and not Details.IsLoaded() then
        C_Timer.After(0.2, setupAfterLogin)
        return
    end

    registerMedia()
    installSkins()
    ensureClassIconHook()

    if hooksecurefunc and Details and Details.ChangeSkin then
        hooksecurefunc(Details, "ChangeSkin", function()
            if runningSkinRefresh then
                return
            end
            scheduleMidnightAdjustments()
        end)
    end

    refreshActiveWindows()
end

-- Bootstrap on login.
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", setupAfterLogin)
