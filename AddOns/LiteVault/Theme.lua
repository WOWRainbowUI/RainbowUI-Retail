-- Theme.lua - LiteVault Theme System
local addonName, lv = ...

-- ============================================================
-- THEME DEFINITIONS
-- ============================================================

local LITEVAULT_PALETTE = {
        name = "Steel Slate",

        -- Main window backgrounds
        background = {0.208, 0.251, 0.294, 0.985},
        backgroundSolid = {0.208, 0.251, 0.294, 1.0},
        backgroundTransparent = {0.208, 0.251, 0.294, 0.92},
        backgroundAlt = {0.251, 0.298, 0.341, 1.0},

        -- Borders
        borderPrimary = {0.110, 0.133, 0.161, 1},
        borderSecondary = {0.376, 0.424, 0.475, 1},
        borderHover = {0.376, 0.424, 0.475, 1},
        borderSubdued = {0.376, 0.424, 0.475, 0.72},
        borderMuted = {0.376, 0.424, 0.475, 0.88},

        -- Button backgrounds
        buttonBg = {0.251, 0.298, 0.341, 1.0},
        buttonBgHover = {0.290, 0.341, 0.388, 1.0},
        buttonBgAlt = {0.208, 0.251, 0.294, 1.0},
        buttonBgActive = {0.208, 0.251, 0.294, 1.0},

        -- Data box backgrounds
        dataBoxBg = {0.251, 0.298, 0.341, 0.98},
        dataBoxBgAlt = {0.208, 0.251, 0.294, 0.98},
        dataBoxBgVault = {0.290, 0.341, 0.388, 0.98},

        -- Text colors
        textPrimary = {0.925, 0.937, 0.949, 1},
        textSecondary = {0.710, 0.741, 0.776, 1},
        textMuted = {0.710, 0.741, 0.776, 0.82},
        textGold = {1, 0.82, 0, 1},
        textAccent = {0.710, 0.741, 0.776, 1},
        textSubtitle = {0.710, 0.741, 0.776, 1},

        -- Calendar specific
        calendarDayBg = {0.251, 0.298, 0.341, 0.98},
        calendarDayHighlight = {0.337, 0.388, 0.435, 0.34},
        calendarDayHighlightTransition = {0.337, 0.388, 0.435, 0.16},
        calendarDayLowerShade = {0, 0, 0, 0.20},
        calendarProfitPositive = {0.086, 0.227, 0.153, 0.98},
        calendarProfitPositiveBest = {0.110, 0.270, 0.180, 0.98},
        calendarProfitPositiveHighlight = {0.165, 0.349, 0.231, 0.42},
        calendarProfitPositiveHighlightTransition = {0.165, 0.349, 0.231, 0.20},
        calendarProfitNegative = {0.290, 0.125, 0.157, 0.98},
        calendarProfitNegativeWorst = {0.335, 0.145, 0.175, 0.98},
        calendarProfitNegativeHighlight = {0.408, 0.188, 0.224, 0.40},
        calendarProfitNegativeHighlightTransition = {0.408, 0.188, 0.224, 0.19},
        calendarDayBorder = {0.376, 0.424, 0.475, 0.95},
        calendarTodayTint = {1, 0.82, 0, 0.07},
        calendarTodayTintTransition = {1, 0.82, 0, 0.03},
        calendarTodayBorder = {1, 0.82, 0, 1},
        calendarHoverLift = 0.035,
        calendarHeaderBg = {0.208, 0.251, 0.294, 0.98},

        -- Dashboard Weekly Quests interior rows
        weeklyQuestRowBg = {0.251, 0.298, 0.341, 0.98},
        weeklyQuestRowBorder = {0.235, 0.270, 0.310, 0.82},
        weeklyQuestSummaryText = {0.78, 0.81, 0.84, 0.92},
        weeklyQuestCompleteText = {0.45, 0.90, 0.55, 1},
        weeklyQuestNotStartedText = {1, 0.42, 0.42, 1},

        -- Row striping
        rowStripeEven = {1, 1, 1, 0.05},
        rowStripeOdd = {0.02, 0.03, 0.08, 0.18},
        rowTotal = {0.290, 0.341, 0.388, 0.30},
        rowNet = {0.110, 0.133, 0.161, 0.28},

        -- Dividers/separators
        divider = {0.376, 0.424, 0.475, 0.38},
        dividerBright = {0.376, 0.424, 0.475, 0.72},

        -- Tab colors
        tabActive = {0.290, 0.341, 0.388, 1},
        tabActiveBorder = {0.376, 0.424, 0.475, 1},
        tabInactive = {0.251, 0.298, 0.341, 0.96},
        tabInactiveBorder = {0.110, 0.133, 0.161, 1},

        -- Portrait frame
        portraitBorder = {0.376, 0.424, 0.475, 1},
}

-- ============================================================
-- THEME API FUNCTIONS
-- ============================================================

-- Get the single canonical LiteVault palette.
function lv.GetTheme()
    return LITEVAULT_PALETTE
end

-- Get a specific color from the current theme (returns r, g, b, a)
function lv.GetColor(colorKey)
    local theme = lv.GetTheme()
    local color = theme[colorKey]
    if color then
        return unpack(color)
    end
    return 1, 1, 1, 1
end

-- Get a specific color as a table
function lv.GetColorTable(colorKey)
    local theme = lv.GetTheme()
    return theme[colorKey] or {1, 1, 1, 1}
end

-- ============================================================
-- BORDER STYLES
-- Construction is kept separate from color application so theme
-- refreshes never rebuild backdrops or duplicate border layers.
-- ============================================================

local PANEL_STRUCTURAL_STYLE = {
    outerColor = "borderPrimary",
    chassisColor = "borderPrimary",
    chassisInset = -3,
    chassisThickness = 2,
    chassisFrameLevelOffset = 1,
    helperOuter = true,
    outerInset = 0,
    outerThickness = 2,
    innerColor = "borderSecondary",
    innerInset = 3,
    innerThickness = 1,
    recessedColor = "borderPrimary",
    recessedInset = 5,
    recessedThickness = 1,
    recessedAlpha = 0.52,
    detailColor = "borderSecondary",
    detailInset = -3,
    cornerLength = 8,
    cornerThickness = 1,
    showTopRail = false,
    showBottomRail = false,
    cornerAlpha = 0.62,
    frameLevelOffset = 2,
}

local BORDER_STYLES = {
    window = {
        outerColor = "borderPrimary",
        innerColor = "borderSecondary",
        innerInset = 6,
        recessedColor = "borderPrimary",
        recessedInset = 8,
        recessedAlpha = 0.72,
        detailColor = "borderSecondary",
        detailInset = 8,
        cornerLength = 12,
        cornerThickness = 2,
        railInset = 26,
        railOffset = 10,
        topRailAlpha = 0.42,
        bottomRailAlpha = 0.28,
        cornerAlpha = 0.68,
    },
    panel = {
        outerColor = "borderPrimary",
        innerColor = "borderSecondary",
        innerInset = 5,
        recessedColor = "borderPrimary",
        recessedInset = 7,
        recessedAlpha = 0.68,
        detailColor = "borderSecondary",
        detailInset = 8,
        cornerLength = 12,
        cornerThickness = 1,
        railInset = 28,
        railOffset = 7,
        topRailAlpha = 0.38,
        bottomRailAlpha = 0.25,
        cornerAlpha = 0.72,
    },
    -- Controlled Level 2 chassis test: identical to panel, with the shared
    -- exterior structural shell enabled.
    panelChassis = {
        outerColor = "borderPrimary",
        chassisColor = "borderPrimary",
        chassisInset = -3,
        chassisThickness = 2,
        chassisFrameLevelOffset = 1,
        innerColor = "borderSecondary",
        innerInset = 5,
        recessedColor = "borderPrimary",
        recessedInset = 7,
        recessedAlpha = 0.68,
        detailColor = "borderSecondary",
        detailInset = -3,
        cornerLength = 12,
        cornerThickness = 1,
        railInset = 28,
        railOffset = 7,
        topRailAlpha = 0.38,
        bottomRailAlpha = 0.25,
        cornerAlpha = 0.72,
    },
    panelMedium = {
        outerColor = "borderPrimary",
        innerColor = "borderSecondary",
        innerInset = 5,
        recessedColor = "borderPrimary",
        recessedInset = 7,
        recessedAlpha = 0.64,
        detailColor = "borderSecondary",
        detailInset = 8,
        cornerLength = 10,
        cornerThickness = 1,
        railInset = 26,
        railOffset = 7,
        topRailAlpha = 0.32,
        bottomRailAlpha = 0.22,
        cornerAlpha = 0.66,
    },
    -- Canonical major structural-panel shell. Keep the former Calendar name as
    -- a compatibility alias to this exact table during the migration period.
    panelStructural = PANEL_STRUCTURAL_STYLE,
    panelCalendar = PANEL_STRUCTURAL_STYLE,
    panelCompact = {
        outerColor = "borderPrimary",
        innerColor = "borderSecondary",
        innerInset = 4,
        recessedColor = "borderPrimary",
        recessedInset = 6,
        recessedAlpha = 0.56,
        detailColor = "borderSecondary",
        detailInset = 7,
        cornerLength = 8,
        cornerThickness = 1,
        showTopRail = false,
        showBottomRail = false,
        cornerAlpha = 0.60,
    },
    -- Controlled medium-panel chassis test: identical to panelCompact, with
    -- only the shared exterior structural shell added.
    panelCompactChassis = {
        outerColor = "borderPrimary",
        chassisColor = "borderPrimary",
        chassisInset = -3,
        chassisThickness = 2,
        chassisFrameLevelOffset = 1,
        innerColor = "borderSecondary",
        innerInset = 4,
        recessedColor = "borderPrimary",
        recessedInset = 6,
        recessedAlpha = 0.56,
        detailColor = "borderSecondary",
        detailInset = 7,
        cornerLength = 8,
        cornerThickness = 1,
        showTopRail = false,
        showBottomRail = false,
        cornerAlpha = 0.60,
    },
    -- Dashboard Weekly Quests keeps compact geometry while seating its existing
    -- corner brackets against the shared exterior chassis.
    panelCompactChassisOutward = {
        outerColor = "borderPrimary",
        chassisColor = "borderPrimary",
        chassisInset = -3,
        chassisThickness = 2,
        chassisFrameLevelOffset = 1,
        innerColor = "borderSecondary",
        innerInset = 4,
        recessedColor = "borderPrimary",
        recessedInset = 6,
        recessedAlpha = 0.56,
        detailColor = "borderSecondary",
        detailInset = -3,
        cornerLength = 8,
        cornerThickness = 1,
        showTopRail = false,
        showBottomRail = false,
        cornerAlpha = 0.60,
    },
    panelTabbed = {
        outerColor = "borderPrimary",
        innerColor = "borderSecondary",
        innerInset = 5,
        recessedColor = "borderPrimary",
        recessedInset = 7,
        recessedAlpha = 0.64,
        detailColor = "borderSecondary",
        detailInset = 8,
        cornerLength = 10,
        cornerThickness = 1,
        railInset = 26,
        railOffset = 7,
        showTopRail = false,
        bottomRailAlpha = 0.22,
        cornerAlpha = 0.66,
    },
}

local function CreateBorderDetailTexture(parent)
    local texture = parent:CreateTexture(nil, "BORDER")
    texture:SetDrawLayer("BORDER", 0)
    return texture
end

local function ResolveBorderGeometry(style)
    return {
        chassisInset = style.chassisInset or 0,
        chassisThickness = style.chassisThickness or 1,
        outerInset = style.outerInset or 0,
        outerThickness = style.outerThickness or 1,
        innerInset = style.innerInset or 5,
        innerThickness = style.innerThickness or style.cornerThickness or 1,
        recessedInset = style.recessedInset or 7,
        recessedThickness = style.recessedThickness or style.cornerThickness or 1,
        detailInset = style.detailInset or style.recessedInset or style.innerInset or 8,
        cornerLength = style.cornerLength or 10,
        cornerThickness = style.cornerThickness or 1,
        railInset = style.railInset or 24,
        railOffset = style.railOffset or ((style.detailInset or 8) + 2),
    }
end

local function UpdateBorderStyleGeometry(frame, style)
    local geometry = ResolveBorderGeometry(style)
    frame.lvBorderResolvedGeometry = geometry

    local chassis = frame.lvBorderStyleChassis
    if chassis then
        chassis:ClearAllPoints()
        chassis:SetPoint("TOPLEFT", frame, "TOPLEFT", geometry.chassisInset, -geometry.chassisInset)
        chassis:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -geometry.chassisInset, geometry.chassisInset)
        chassis:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = geometry.chassisThickness })
    end

    local outerBorder = frame.lvBorderStyleOuter
    if outerBorder then
        outerBorder:ClearAllPoints()
        outerBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", geometry.outerInset, -geometry.outerInset)
        outerBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -geometry.outerInset, geometry.outerInset)
        outerBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = geometry.outerThickness })
    end

    local innerBorder = frame.lvBorderStyleInner
    if innerBorder then
        innerBorder:ClearAllPoints()
        innerBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", geometry.innerInset, -geometry.innerInset)
        innerBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -geometry.innerInset, geometry.innerInset)
        innerBorder:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = geometry.innerThickness })
    end

    local recessed = frame.lvBorderStyleRecessed
    if recessed then
        recessed:ClearAllPoints()
        recessed:SetPoint("TOPLEFT", frame, "TOPLEFT", geometry.recessedInset, -geometry.recessedInset)
        recessed:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -geometry.recessedInset, geometry.recessedInset)
        recessed:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = geometry.recessedThickness })
    end

    local details = frame.lvBorderStyleDetails
    if details then
        local cornerDefs = {
            {"TOPLEFT", geometry.detailInset, -geometry.detailInset, geometry.cornerLength, geometry.cornerThickness},
            {"TOPLEFT", geometry.detailInset, -geometry.detailInset, geometry.cornerThickness, geometry.cornerLength},
            {"TOPRIGHT", -geometry.detailInset, -geometry.detailInset, geometry.cornerLength, geometry.cornerThickness},
            {"TOPRIGHT", -geometry.detailInset, -geometry.detailInset, geometry.cornerThickness, geometry.cornerLength},
            {"BOTTOMLEFT", geometry.detailInset, geometry.detailInset, geometry.cornerLength, geometry.cornerThickness},
            {"BOTTOMLEFT", geometry.detailInset, geometry.detailInset, geometry.cornerThickness, geometry.cornerLength},
            {"BOTTOMRIGHT", -geometry.detailInset, geometry.detailInset, geometry.cornerLength, geometry.cornerThickness},
            {"BOTTOMRIGHT", -geometry.detailInset, geometry.detailInset, geometry.cornerThickness, geometry.cornerLength},
        }
        for index, def in ipairs(cornerDefs) do
            local texture = details.corners[index]
            texture:ClearAllPoints()
            texture:SetSize(def[4], def[5])
            texture:SetPoint(def[1], details.frame, def[1], def[2], def[3])
        end

        if details.topRail then
            details.topRail:ClearAllPoints()
            details.topRail:SetPoint("TOPLEFT", details.frame, "TOPLEFT", geometry.railInset, -geometry.railOffset)
            details.topRail:SetPoint("TOPRIGHT", details.frame, "TOPRIGHT", -geometry.railInset, -geometry.railOffset)
            details.topRail:SetHeight(geometry.cornerThickness)
        end
        if details.bottomRail then
            details.bottomRail:ClearAllPoints()
            details.bottomRail:SetPoint("BOTTOMLEFT", details.frame, "BOTTOMLEFT", geometry.railInset, geometry.railOffset)
            details.bottomRail:SetPoint("BOTTOMRIGHT", details.frame, "BOTTOMRIGHT", -geometry.railInset, geometry.railOffset)
            details.bottomRail:SetHeight(geometry.cornerThickness)
        end
    end
end

function lv.EnsureBorderStyle(frame, styleName)
    local style = BORDER_STYLES[styleName]
    if not (frame and style) then return nil end

    frame.lvBorderStyle = styleName

    if not style.innerInset then return nil end

    local frameLevelOffset = style.frameLevelOffset or 1

    if style.chassisColor and not frame.lvBorderStyleChassis then
        local chassis = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        chassis:EnableMouse(false)
        chassis:SetFrameLevel(frame:GetFrameLevel() + (style.chassisFrameLevelOffset or frameLevelOffset))
        frame.lvBorderStyleChassis = chassis
    end

    if style.helperOuter and not frame.lvBorderStyleOuter then
        local outerBorder = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        outerBorder:EnableMouse(false)
        outerBorder:SetFrameLevel(frame:GetFrameLevel() + frameLevelOffset)
        frame.lvBorderStyleOuter = outerBorder
    end

    if not frame.lvBorderStyleInner then
        local innerBorder = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        innerBorder:EnableMouse(false)
        innerBorder:SetFrameLevel(frame:GetFrameLevel() + frameLevelOffset)
        frame.lvBorderStyleInner = innerBorder
    end

    if style.recessedInset and not frame.lvBorderStyleRecessed then
        local recessed = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        recessed:EnableMouse(false)
        recessed:SetFrameLevel(frame:GetFrameLevel() + frameLevelOffset)
        frame.lvBorderStyleRecessed = recessed
    end

    if style.detailColor and not frame.lvBorderStyleDetails then
        local detailFrame = CreateFrame("Frame", nil, frame)
        detailFrame:SetAllPoints(frame)
        detailFrame:EnableMouse(false)
        detailFrame:SetFrameLevel(frame:GetFrameLevel() + frameLevelOffset)

        local details = { frame = detailFrame, corners = {} }
        for _ = 1, 8 do
            local texture = CreateBorderDetailTexture(detailFrame)
            details.corners[#details.corners + 1] = texture
        end

        if style.showTopRail ~= false then
            details.topRail = CreateBorderDetailTexture(detailFrame)
        end

        if style.showBottomRail ~= false then
            details.bottomRail = CreateBorderDetailTexture(detailFrame)
        end

        frame.lvBorderStyleDetails = details
    end

    UpdateBorderStyleGeometry(frame, style)
    return frame.lvBorderStyleInner
end

function lv.ApplyBorderStyle(frame, styleName, theme)
    styleName = (frame and frame.lvBorderStyle) or styleName
    local style = BORDER_STYLES[styleName]
    theme = theme or lv.GetTheme()
    if not (frame and style and theme) then return end

    UpdateBorderStyleGeometry(frame, style)

    local outerColor = theme[style.outerColor]
    if outerColor and frame.SetBackdropBorderColor then
        frame:SetBackdropBorderColor(unpack(outerColor))
    end
    if outerColor and frame.lvBorderStyleOuter then
        frame.lvBorderStyleOuter:SetBackdropBorderColor(unpack(outerColor))
    end

    local chassisColor = theme[style.chassisColor]
    if chassisColor and frame.lvBorderStyleChassis then
        frame.lvBorderStyleChassis:SetBackdropBorderColor(unpack(chassisColor))
    end

    local innerBorder = frame.lvBorderStyleInner
    local innerColor = theme[style.innerColor]
    if innerBorder and innerColor then
        innerBorder:SetBackdropBorderColor(unpack(innerColor))
    end

    local recessed = frame.lvBorderStyleRecessed
    local recessedColor = theme[style.recessedColor]
    if recessed and recessedColor then
        recessed:SetBackdropBorderColor(recessedColor[1], recessedColor[2], recessedColor[3], style.recessedAlpha or 0.72)
    end

    local details = frame.lvBorderStyleDetails
    local detailColor = theme[style.detailColor]
    if details and detailColor then
        for _, texture in ipairs(details.corners) do
            texture:SetColorTexture(detailColor[1], detailColor[2], detailColor[3], style.cornerAlpha or 0.68)
        end
        if details.topRail then
            details.topRail:SetColorTexture(detailColor[1], detailColor[2], detailColor[3], style.topRailAlpha or 0.42)
        end
        if details.bottomRail then
            details.bottomRail:SetColorTexture(detailColor[1], detailColor[2], detailColor[3], style.bottomRailAlpha or 0.28)
        end
    end
end

-- ============================================================
-- THEME APPLICATION SYSTEM
-- ============================================================

-- Registry of themed UI elements
lv.ThemedElements = {}

-- Register a frame for theme updates
function lv.RegisterThemedElement(element, updateFunc)
    if element and updateFunc then
        table.insert(lv.ThemedElements, {
            element = element,
            updateFunc = updateFunc
        })
    end
end

-- Apply theme to all registered elements
function lv.ApplyTheme()
    local theme = lv.GetTheme()

    -- Update all registered elements
    for _, entry in ipairs(lv.ThemedElements) do
        if entry.element and entry.updateFunc then
            pcall(entry.updateFunc, entry.element, theme)
        end
    end

    -- Refresh the main UI
    if lv.UpdateUI then
        lv.UpdateUI()
    end

end
