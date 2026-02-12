local addonName = ...
local addonPath = "Interface\\AddOns\\" .. addonName

-- ============================================================================
-- SKIN VARIANTS
-- - skinName: current Midnight skin with visible wallpaper background
-- - skinNameNoBackground: same skin but wallpaper alpha forced to 0
-- - skinNameRounded: Midnight (Rounded) variant with alternate bar texture
-- - skinNameRoundedNoBackground: Rounded variant with wallpaper alpha forced to 0
-- - skinNamePersonal: Midnight (Personal) variant with MelliDark bars
-- - skinNamePersonalNoBackground: Personal variant with wallpaper alpha forced to 0
-- ============================================================================
local skinName = "|cff7fd8ff至暗之夜|r"
local skinNameNoBackground = "|cff7fd8ff至暗之夜|r (無背景)"
local skinNameRounded = "|cff7fd8ff至暗之夜|r (圓角)"
local skinNameRoundedNoBackground = "|cff7fd8ff至暗之夜|r (圓角無背景)"
local skinNamePersonal = "|cff7fd8ff至暗之夜|r (個人)"
local skinNamePersonalNoBackground = "|cff7fd8ff至暗之夜|r (個人無背景)"

-- ============================================================================
-- TEXTURE CONFIG
-- Change these file paths to swap textures for base and variant skins.
-- ============================================================================
local textureFiles = {
    header = addonPath .. "\\Textures\\ui-damagemeters-header-bar-2x.png",
    bar = addonPath .. "\\Textures\\BlizzardDF_bar",
    windowBackground = addonPath .. "\\Textures\\damagemeters-background.png",

    -- Rounded variant bar texture.
    testBar = addonPath .. "\\Textures\\ui-hud-cooldownmanager-bar-2x.png",

    -- Personal variant bar texture.
    personalBar = addonPath .. "\\Textures\\MelliDarkRough.tga"
}

local textureHeader = "Midnight Header"
local textureBar = "Midnight Bar"
local textureWindowBackground = "Midnight Window Background"
local textureBarRounded = "Midnight Rounded Bar"
local textureBarPersonal = "Midnight Personal Bar"

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
    -- Horizontal crop for header texture (0-1). Use to trim transparent side padding.
    headerTexCoordLeft = 0.045,
    headerTexCoordRight = 0.965,    
    headerTexCoordTop = 4 / 60,
    headerTexCoordBottom = 56 / 60,

    -- No-background variants share this override value.
    noBackgroundSkin = {
        wallpaperAlpha = 0.0
    }
}

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

local originalSpecCoords
local croppedSpecCoords
local hookedSizeFrames = setmetatable({}, {__mode = "k"})

-- Match both Midnight variants so all behavior stays identical.
local function isMidnightSkin(skin)
    return skin == skinName
        or skin == skinNameNoBackground
        or skin == skinNameRounded
        or skin == skinNameRoundedNoBackground
        or skin == skinNamePersonal
        or skin == skinNamePersonalNoBackground
end

local function copySpecCoords(source)
    local copied = {}
    for specId, coord in pairs(source or {}) do
        copied[specId] = {coord[1], coord[2], coord[3], coord[4]}
    end
    return copied
end

local function buildCroppedSpecCoords(source, inset)
    local cropped = {}
    for specId, coord in pairs(source or {}) do
        local l, r, t, b = coord[1], coord[2], coord[3], coord[4]
        if (r - l) > (inset * 2) and (b - t) > (inset * 2) then
            cropped[specId] = {l + inset, r - inset, t + inset, b - inset}
        else
            cropped[specId] = {l, r, t, b}
        end
    end
    return cropped
end

local function hasActiveMidnightSkin()
    if not Details or not Details.GetNumInstances or not Details.GetInstance then
        return false
    end

    for instanceId = 1, Details:GetNumInstances() do
        local instance = Details:GetInstance(instanceId)
        if instance and instance.ativa and isMidnightSkin(instance.skin) then
            return true
        end
    end

    return false
end

local function updateSpecIconCoords()
    if not Details or not Details.class_specs_coords then
        return
    end

    if not originalSpecCoords then
        originalSpecCoords = copySpecCoords(Details.class_specs_coords)
    end

    if not croppedSpecCoords then
        croppedSpecCoords = buildCroppedSpecCoords(originalSpecCoords, specIconInset)
    end

    if hasActiveMidnightSkin() then
        Details.class_specs_coords = croppedSpecCoords
    else
        Details.class_specs_coords = originalSpecCoords
    end
end

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

local function updateTitleBarTexCoords()
    if not Details or not Details.GetNumInstances or not Details.GetInstance then
        return
    end

    for instanceId = 1, Details:GetNumInstances() do
        local instance = Details:GetInstance(instanceId)
        updateTitleBarTexCoordForInstance(instance)
    end
end

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

local function updateBarInsets()
    if not Details or not Details.GetNumInstances or not Details.GetInstance then
        return
    end

    for instanceId = 1, Details:GetNumInstances() do
        local instance = Details:GetInstance(instanceId)
        if instance and instance.ativa and isMidnightSkin(instance.skin) then
            ensureBarInsetResizeHook(instance)
            applyBarInsetsForInstance(instance)
            applyWallpaperInsetsForInstance(instance)
            hideNoStatusbarCornersForInstance(instance)
        end
    end
end

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
    LSM:Register("statusbar", textureBarRounded, textureFiles.testBar)
    LSM:Register("statusbar", textureBarPersonal, textureFiles.personalBar)
    LSM:Register("background", textureWindowBackground, textureFiles.windowBackground)
end

local function buildSkinTable(wallpaperAlpha, textureOverrides)
    if type(wallpaperAlpha) ~= "number" then
        wallpaperAlpha = wallpaperAlphaDefault
    end

    textureOverrides = textureOverrides or {}
    local barTextureName = textureOverrides.barTextureName or textureBar
    local barTextureFile = textureOverrides.barTextureFile or textureFiles.bar
    local barBackgroundTextureName = textureOverrides.barBackgroundTextureName or barTextureName
    local barBackgroundTextureFile = textureOverrides.barBackgroundTextureFile or barTextureFile

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
            size = 14,
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
                shadow = false,
                side = 1,
                text_size = 16,
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
                fixed_texture_background_color = {0, 0, 0, styleConfig.barBackgroundAlpha},

                texture_background_class_color = false,
                texture_class_colors = true,
                alpha = 1,

                height = styleConfig.barHeight,
                space = {left = 5, right = -5, between = styleConfig.barSpacingBetween},
                row_offsets = {left = 30, right = -40, top = styleConfig.barOffsetTop, bottom = styleConfig.barOffsetBottom},

                no_icon = false,
                start_after_icon = true,
                use_spec_icons = true,
                spec_file = addonPath .. "\\Textures\\spec_icons_normal.jpg",
                icon_mask = "",
                icon_file = addonPath .. "\\Textures\\classes_small",
                icon_offset = {-30, 0},
                icon_size_offset = 0,

                texture = barTextureName,
                texture_file = barTextureFile,
                texture_background = barBackgroundTextureName,
                texture_background_file = barBackgroundTextureFile,

                font_face = "Friz Quadrata TT",
                font_face_file = "Fonts\\FRIZQT__.TTF",
                font_size = 16,
                text_yoffset = 0,

                textL_show_number = true,
                textL_enable_custom_text = false,
                textL_custom_text = "{data3}",
                textL_class_colors = false,
                textL_outline = false,

                textR_enable_custom_text = false,
                textR_custom_text = "{data1} ({data2}, {data3}%)",
                textR_show_data = {true, true, true},
                textR_separator = ",",
                textR_bracket = "(",
                textR_class_colors = false,
                textR_outline = false,

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
        barTextureName = textureBarRounded,
        barTextureFile = textureFiles.testBar
    }))

    -- Fourth skin variant: rounded bars with no wallpaper background.
    local okRoundedNoBackground = pcall(Details.InstallSkin, Details, skinNameRoundedNoBackground, buildSkinTable(wallpaperAlphaNoBackground, {
        barTextureName = textureBarRounded,
        barTextureFile = textureFiles.testBar
    }))

    -- Fifth skin variant: Personal bars with wallpaper visible.
    local okPersonal = pcall(Details.InstallSkin, Details, skinNamePersonal, buildSkinTable(wallpaperAlphaDefault, {
        barTextureName = textureBarPersonal,
        barTextureFile = textureFiles.personalBar
    }))

    -- Sixth skin variant: Personal bars with no wallpaper background.
    local okPersonalNoBackground = pcall(Details.InstallSkin, Details, skinNamePersonalNoBackground, buildSkinTable(wallpaperAlphaNoBackground, {
        barTextureName = textureBarPersonal,
        barTextureFile = textureFiles.personalBar
    }))

    return okMain and okNoBackground and okRounded and okRoundedNoBackground and okPersonal and okPersonalNoBackground
end

local function refreshActiveWindows()
    if not Details or not Details.GetNumInstances or not Details.GetInstance then
        return
    end

    for instanceId = 1, Details:GetNumInstances() do
        local instance = Details:GetInstance(instanceId)
        if instance and instance.baseframe and instance.ativa and instance.ChangeSkin then
            pcall(instance.ChangeSkin, instance)
            updateTitleBarTexCoordForInstance(instance)
            ensureBarInsetResizeHook(instance)
            applyBarInsetsForInstance(instance)
            applyWallpaperInsetsForInstance(instance)
            hideNoStatusbarCornersForInstance(instance)
        end
    end
end

local function setupAfterLogin()
    if Details and Details.IsLoaded and not Details.IsLoaded() then
        C_Timer.After(0.2, setupAfterLogin)
        return
    end

    registerMedia()
    installSkins()
    updateSpecIconCoords()
    updateTitleBarTexCoords()
    updateBarInsets()

    if hooksecurefunc and Details and Details.ChangeSkin then
        hooksecurefunc(Details, "ChangeSkin", function()
            updateSpecIconCoords()
            updateTitleBarTexCoords()
            updateBarInsets()
        end)
    end

    refreshActiveWindows()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", setupAfterLogin)
