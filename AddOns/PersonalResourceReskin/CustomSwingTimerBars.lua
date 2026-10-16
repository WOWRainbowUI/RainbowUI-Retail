--[[
CustomSwingTimerBars.lua

Reskins the three "Swing Timer" bars added by WoW Classic Forever:
    SwingTimerMainHandFrame, SwingTimerOffHandFrame, SwingTimerRangedFrame

Each of those frames follows the same layout (confirmed in-game via the UI
frame-stack debug tool):
    <FrameName>                     -- container
        .StatusBar                  -- the actual progress bar
            .TypeLabel               -- FontString, e.g. "主手"
            .TypeLabelShadow         -- FontString, drop-shadow copy of TypeLabel
            .Pip                     -- (Main Hand only) swing marker, left untouched
        .Background                 -- Blizzard's background texture
        .Border                     -- Blizzard's border texture

This module:
    - Hides Blizzard's own Background/Border on each bar
    - Draws our own 1px border + a color-pickable background instead
      (optionally, per bar, you can flip "使用預設邊框與背景" to
      keep Blizzard's original background/border instead - bar texture/color
      and font settings still apply on top of it)
    - Lets you retexture / recolor the status bar fill
    - Lets you set the font (family/size/outline/color) used for the bar's
      text (TypeLabel + TypeLabelShadow, plus any other FontString Blizzard
      might add to the bar under a different name - see the generic
      FontString sweep in ApplyBarFonts)
    - Exposes all of the above through an AceConfig options panel opened
      with /swingprd (and, if present, also plugs into the shared
      PersonalResourceReskinPlus options panel opened with /prr, the same
      way CustomEssenceBar/CustomHolyPowerBar/etc. do)

Everything here is defensive (pcall + existence checks) in the same style
as the rest of the addon, since this targets a brand-new client feature
whose exact internals may still shift between Classic Forever patches.
]]

local ADDON_NAME = ...

local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
local AceConfig = LibStub and LibStub("AceConfig-3.0", true)
local AceConfigDialog = LibStub and LibStub("AceConfigDialog-3.0", true)

-- ============================================================================
-- Saved variables
-- ============================================================================

CustomSwingTimerBarDB = CustomSwingTimerBarDB or {}

local BAR_INFO = {
    mainhand = { frameName = "SwingTimerMainHandFrame", label = "主手" },
    offhand  = { frameName = "SwingTimerOffHandFrame",  label = "副手"  },
    ranged   = { frameName = "SwingTimerRangedFrame",   label = "遠程"    },
}

-- Order kept stable for iteration in the UI / copy-to-others logic
local BAR_ORDER = { "mainhand", "offhand", "ranged" }

local function GetBarDefaults()
    return {
        enabled = true,
        texture = "White8x8",           -- LSM statusbar key
        useCustomBarColor = false,
        barColor = {1, 1, 1, 1},
        useDefaultBorderBackground = false, -- true = keep Blizzard's own Background/Border, skip our custom backdrop entirely
        bgColor = {0, 0, 0, 0.5},
        showCustomBorder = true,
        borderColor = {0, 0, 0, 1},
        borderSize = 1,
        font = "Friz Quadrata TT",      -- LSM font key
        fontSize = 12,
        fontFlags = "OUTLINE",          -- "", "OUTLINE", "THICKOUTLINE", "OUTLINE, MONOCHROME"
        fontColor = {1, 1, 1, 1},

        -- Name text (TypeLabel + its shadow), e.g. "主手".
        -- Off by default = Blizzard's own position is left alone.
        customNamePosition = false,
        namePoint = "LEFT",             -- point on the text that gets anchored
        nameRelPoint = "LEFT",          -- point on the bar it attaches to
        nameX = 4,
        nameY = 0,

        -- Timer text (TimeLabel), e.g. "1.2".
        customTimerPosition = false,
        timerPoint = "RIGHT",
        timerRelPoint = "RIGHT",
        timerX = -4,
        timerY = 0,
    }
end

-- Returns CustomSwingTimerBarDB[key], creating it (and filling in any
-- missing fields, e.g. after an addon update adds a new option) as needed.
local function EnsureBarDefaults(key)
    CustomSwingTimerBarDB[key] = CustomSwingTimerBarDB[key] or {}
    local settings = CustomSwingTimerBarDB[key]
    local defaults = GetBarDefaults()
    for k, v in pairs(defaults) do
        if settings[k] == nil then
            settings[k] = v
        end
    end
    return settings
end

-- ============================================================================
-- Reskin engine
-- ============================================================================

local function GetStatusBarTexturePath(key)
    local settings = EnsureBarDefaults(key)
    local path = LSM and LSM:Fetch("statusbar", settings.texture)
    return path or "Interface\\TargetingFrame\\UI-StatusBar"
end

local function GetFontPath(settings)
    local path = LSM and LSM:Fetch("font", settings.font)
    return path or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
end

local function ApplyFontToRegion(region, font, size, flags, color)
    if not region or not region.SetFont then return end
    pcall(region.SetFont, region, font, size, flags or "")
    if color and region.SetTextColor then
        pcall(region.SetTextColor, region, color[1], color[2], color[3], color[4])
    end
end

-- Applies the configured font to TypeLabel/TypeLabelShadow, and (defensively)
-- to any other FontString region living directly on the status bar, in case
-- a future patch renames or adds a text element we don't know about yet.
local function ApplyBarFonts(statusBar, settings)
    if not statusBar then return end
    local font = GetFontPath(settings)
    local flags = (settings.fontFlags ~= "NONE" and settings.fontFlags) or ""

    local handled = {}
    if statusBar.TypeLabel then
        ApplyFontToRegion(statusBar.TypeLabel, font, settings.fontSize, flags, settings.fontColor)
        handled[statusBar.TypeLabel] = true
    end
    if statusBar.TypeLabelShadow then
        -- Keep the shadow copy in sync so the two never fall out of alignment;
        -- shadows read best as pure black at the same alpha as the label.
        local shadowColor = { 0, 0, 0, settings.fontColor[4] or 1 }
        ApplyFontToRegion(statusBar.TypeLabelShadow, font, settings.fontSize, flags, shadowColor)
        handled[statusBar.TypeLabelShadow] = true
    end

    if statusBar.GetRegions then
        local ok, regions = pcall(function() return { statusBar:GetRegions() } end)
        if ok then
            for _, region in ipairs(regions) do
                if region and not handled[region] and region.GetObjectType then
                    local objType
                    pcall(function() objType = region:GetObjectType() end)
                    if objType == "FontString" then
                        ApplyFontToRegion(region, font, settings.fontSize, flags, settings.fontColor)
                    end
                end
            end
        end
    end
end

-- ----------------------------------------------------------------------------
-- Text positioning (name label + timer label)
-- ----------------------------------------------------------------------------
-- Blizzard anchors these FontStrings itself and has no option to move them,
-- so when a custom position is enabled we ClearAllPoints + SetPoint them to
-- our own anchor, and hook SetPoint so that if Blizzard re-anchors them
-- (layout refresh, OnShow, etc.) we immediately put them back. When the
-- option is turned off (or the bar's reskin is disabled) the original
-- Blizzard anchors we captured beforehand are restored.

local originalLayout = {}   -- [region] = { points = {...}, justify = "LEFT" }
local positionOwner = {}    -- [region] = { key = "mainhand", kind = "name"|"nameShadow"|"timer", anchorTo = statusBar }
local positionHooked = {}   -- [region] = true
local applyingPosition = false

local ANCHOR_POINTS = {
    TOPLEFT = "左上", TOP = "上方", TOPRIGHT = "右上",
    LEFT = "左側", CENTER = "中央", RIGHT = "右側",
    BOTTOMLEFT = "左下", BOTTOM = "下方", BOTTOMRIGHT = "右下",
}
local ANCHOR_ORDER = {
    "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "CENTER", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT",
}

local function JustifyForPoint(point)
    if point == "LEFT" or point == "TOPLEFT" or point == "BOTTOMLEFT" then return "LEFT" end
    if point == "RIGHT" or point == "TOPRIGHT" or point == "BOTTOMRIGHT" then return "RIGHT" end
    return "CENTER"
end

-- Returns active, point, relPoint, x, y for a given text element.
local function GetPositionSpec(settings, kind)
    if kind == "timer" then
        return settings.customTimerPosition, settings.timerPoint, settings.timerRelPoint,
               settings.timerX or 0, settings.timerY or 0
    end
    -- The shadow sits 1px down/right of the label, like a normal drop shadow.
    local dx, dy = 0, 0
    if kind == "nameShadow" then dx, dy = 1, -1 end
    return settings.customNamePosition, settings.namePoint, settings.nameRelPoint,
           (settings.nameX or 0) + dx, (settings.nameY or 0) + dy
end

local function CaptureOriginalLayout(region)
    if originalLayout[region] then return end
    local layout = { points = {} }
    local ok = pcall(function()
        for i = 1, region:GetNumPoints() do
            local point, relTo, relPoint, x, y = region:GetPoint(i)
            layout.points[i] = { point, relTo, relPoint, x, y }
        end
        if region.GetJustifyH then layout.justify = region:GetJustifyH() end
    end)
    if ok then originalLayout[region] = layout end
end

local function RestoreOriginalLayout(region)
    local layout = originalLayout[region]
    if not layout then return end
    originalLayout[region] = nil
    if #layout.points == 0 then return end
    applyingPosition = true
    pcall(function()
        region:ClearAllPoints()
        for _, p in ipairs(layout.points) do
            region:SetPoint(p[1], p[2], p[3], p[4], p[5])
        end
        if layout.justify and region.SetJustifyH then region:SetJustifyH(layout.justify) end
    end)
    applyingPosition = false
end

local function PlaceRegion(region)
    local owner = positionOwner[region]
    if not owner then return end
    local settings = CustomSwingTimerBarDB[owner.key]
    if not settings or not settings.enabled then return end
    local active, point, relPoint, x, y = GetPositionSpec(settings, owner.kind)
    if not active or not point then return end

    CaptureOriginalLayout(region)
    applyingPosition = true
    pcall(function()
        region:ClearAllPoints()
        region:SetPoint(point, owner.anchorTo, relPoint or point, x, y)
        if region.SetJustifyH then region:SetJustifyH(JustifyForPoint(point)) end
    end)
    applyingPosition = false
end

local function RefreshRegionPosition(region)
    local owner = positionOwner[region]
    if not owner then return end
    local settings = CustomSwingTimerBarDB[owner.key]
    local active = false
    if settings and settings.enabled then
        active = GetPositionSpec(settings, owner.kind)
    end
    if active then
        PlaceRegion(region)
    else
        RestoreOriginalLayout(region)
    end
end

local function SetupRegionPosition(region, statusBar, key, kind)
    if not region or not region.SetPoint then return end
    positionOwner[region] = { key = key, kind = kind, anchorTo = statusBar }
    if not positionHooked[region] then
        positionHooked[region] = true
        hooksecurefunc(region, "SetPoint", function(self)
            if applyingPosition then return end
            PlaceRegion(self)
        end)
    end
    RefreshRegionPosition(region)
end

local function ApplyBarTextPositions(statusBar, key)
    if not statusBar then return end
    SetupRegionPosition(statusBar.TypeLabel, statusBar, key, "name")
    SetupRegionPosition(statusBar.TypeLabelShadow, statusBar, key, "nameShadow")
    SetupRegionPosition(statusBar.TimeLabel, statusBar, key, "timer")
end

local function ApplyStatusBarSkin(statusBar, key, settings)
    if not statusBar then return end
    if statusBar.SetStatusBarTexture then
        pcall(statusBar.SetStatusBarTexture, statusBar, GetStatusBarTexturePath(key))
    end
    if settings.useCustomBarColor and statusBar.SetStatusBarColor then
        local c = settings.barColor
        pcall(statusBar.SetStatusBarColor, statusBar, c[1], c[2], c[3], c[4])
    end
end

local function HideBlizzardChrome(frame)
    if not frame then return end
    if frame.Background and frame.Background.Hide then pcall(frame.Background.Hide, frame.Background) end
    if frame.Border and frame.Border.Hide then pcall(frame.Border.Hide, frame.Border) end
end

local function ShowBlizzardChrome(frame)
    if not frame then return end
    if frame.Background and frame.Background.Show then pcall(frame.Background.Show, frame.Background) end
    if frame.Border and frame.Border.Show then pcall(frame.Border.Show, frame.Border) end
end

-- Some Blizzard frames aren't created with backdrop support built in.
-- Retrofit it so we can draw our own background/border on them.
local function EnsureBackdropSupport(frame)
    if not frame or frame.SetBackdrop then return end
    if Mixin and BackdropTemplateMixin then
        Mixin(frame, BackdropTemplateMixin)
        if frame.OnBackdropLoaded then pcall(frame.OnBackdropLoaded, frame) end
    end
end

local CUSTOM_EDGE_FILE = "Interface\\AddOns\\PersonalResourceReskin\\Media\\white8x8"

local function ApplyCustomBackdrop(frame, settings)
    EnsureBackdropSupport(frame)
    if not frame.SetBackdrop then return end -- this client build doesn't support backdrops here; skip quietly

    local edgeSize = settings.showCustomBorder and (settings.borderSize or 1) or 0
    local ok = pcall(frame.SetBackdrop, frame, {
        bgFile = CUSTOM_EDGE_FILE,
        edgeFile = settings.showCustomBorder and CUSTOM_EDGE_FILE or nil,
        edgeSize = edgeSize,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    if not ok then return end

    local bg = settings.bgColor
    if frame.SetBackdropColor then
        pcall(frame.SetBackdropColor, frame, bg[1], bg[2], bg[3], bg[4])
    end
    if settings.showCustomBorder and frame.SetBackdropBorderColor then
        local bc = settings.borderColor
        pcall(frame.SetBackdropBorderColor, frame, bc[1], bc[2], bc[3], bc[4])
    end
end

local function RemoveCustomBackdrop(frame)
    if frame and frame.SetBackdrop then
        pcall(frame.SetBackdrop, frame, nil)
    end
end

-- Guards against SetStatusBarTexture recursion when we hook it below.
local textureProtected = {}

local function ProtectTexture(statusBar, key)
    if not statusBar or textureProtected[statusBar] then return end
    textureProtected[statusBar] = true
    hooksecurefunc(statusBar, "SetStatusBarTexture", function(self)
        if self.__PRR_ApplyingTexture then return end
        local settings = CustomSwingTimerBarDB[key]
        if not settings or not settings.enabled then return end
        self.__PRR_ApplyingTexture = true
        pcall(self.SetStatusBarTexture, self, GetStatusBarTexturePath(key))
        self.__PRR_ApplyingTexture = false
    end)
end

local function ApplySwingBarSkin(key)
    local info = BAR_INFO[key]
    if not info then return end
    local frame = _G[info.frameName]
    if not frame then return end -- not created yet (e.g. no weapon equipped / never swung)

    local settings = EnsureBarDefaults(key)
    local statusBar = frame.StatusBar or frame

    if not settings.enabled then
        ShowBlizzardChrome(frame)
        RemoveCustomBackdrop(frame)
        ApplyBarTextPositions(statusBar, key) -- restores Blizzard's text anchors
        return
    end

    if settings.useDefaultBorderBackground then
        -- User wants Blizzard's own background/border kept, but still wants
        -- the bar texture/color and font reskinned below.
        ShowBlizzardChrome(frame)
        RemoveCustomBackdrop(frame)
    else
        HideBlizzardChrome(frame)
        ApplyCustomBackdrop(frame, settings)
    end
    ApplyStatusBarSkin(statusBar, key, settings)
    ApplyBarFonts(statusBar, settings)
    ApplyBarTextPositions(statusBar, key)
    ProtectTexture(statusBar, key)
end

local function ApplyAllSwingBars()
    for _, key in ipairs(BAR_ORDER) do
        ApplySwingBarSkin(key)
    end
end
_G.PRR_ApplyAllSwingBars = ApplyAllSwingBars

-- ============================================================================
-- Lifecycle: these bars may not exist until the first swing, so keep trying
-- and re-apply whenever Blizzard shows them.
-- ============================================================================

local hooked = {}

local function HookBar(key)
    if hooked[key] then return end
    local info = BAR_INFO[key]
    local frame = _G[info.frameName]
    if not frame then return end
    hooked[key] = true

    frame:HookScript("OnShow", function() ApplySwingBarSkin(key) end)
    if frame.StatusBar and frame.StatusBar.HookScript then
        frame.StatusBar:HookScript("OnShow", function() ApplySwingBarSkin(key) end)
    end
    ApplySwingBarSkin(key)
end

local function TryHookAll()
    for _, key in ipairs(BAR_ORDER) do
        HookBar(key)
    end
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
initFrame:SetScript("OnEvent", TryHookAll)

-- Fallback poll in case the frames are only created lazily on the first
-- weapon swing rather than existing at login.
do
    local triesLeft = 30
    local ticker
    ticker = C_Timer.NewTicker(1, function()
        TryHookAll()
        local allHooked = true
        for _, key in ipairs(BAR_ORDER) do
            if not hooked[key] then allHooked = false end
        end
        triesLeft = triesLeft - 1
        if allHooked or triesLeft <= 0 then
            if ticker then ticker:Cancel() end
        end
    end)
end

-- ============================================================================
-- Options panel
-- ============================================================================

-- Media (statusbar texture / font) selects follow the same pattern used
-- elsewhere in this addon: values are keyed by filename (what the user sees)
-- and mapped back to the LSM key on get/set, since this addon doesn't load
-- the AceGUI SharedMedia widget extension.
local function BuildMediaValues(mediaType)
    local out = {}
    if not LSM then return out end
    local list = LSM:HashTable(mediaType)
    for k, v in pairs(list) do
        local filename = v:match("[^\\/]+$") or v
        out[filename] = k
    end
    return out
end

local function MediaKeyToFilename(mediaType, key)
    if not LSM then return key end
    local list = LSM:HashTable(mediaType)
    local path = list[key]
    if not path then return key end
    return path:match("[^\\/]+$") or key
end

local function MediaFilenameToKey(mediaType, filename)
    if not LSM then return filename end
    local list = LSM:HashTable(mediaType)
    for k, v in pairs(list) do
        local fn = v:match("[^\\/]+$") or v
        if fn == filename then return k end
    end
    return filename
end

local FONT_FLAG_VALUES = {
    NONE = "無",
    OUTLINE = "描邊",
    THICKOUTLINE = "粗描邊",
    ["OUTLINE, MONOCHROME"] = "單色描邊",
}

-- Builds the "custom position" option block (toggle + anchor points + X/Y)
-- for one text element. `p` names the saved-variable fields to use.
local function BuildPositionArgs(key, p, title, baseOrder)
    local function s() return EnsureBarDefaults(key) end
    local function off() return not s()[p.toggle] end
    local function setter(field)
        return function(_, val)
            s()[field] = val
            ApplySwingBarSkin(key)
        end
    end
    return {
        [p.toggle .. "Header"] = { type = "header", name = title, order = baseOrder },
        [p.toggle] = {
            type = "toggle",
            order = baseOrder + 1,
            name = "自訂位置",
            desc = "自行調整文字位置，停用後恢復暴雪預設位置。",
            get = function() return s()[p.toggle] end,
            set = setter(p.toggle),
        },
        [p.point] = {
            type = "select",
            order = baseOrder + 2,
            name = "文字對齊點",
            desc = "選擇文字上用來對齊計量條的位置。",
            values = ANCHOR_POINTS,
            sorting = ANCHOR_ORDER,
            disabled = off,
            get = function() return s()[p.point] end,
            set = setter(p.point),
        },
        [p.rel] = {
            type = "select",
            order = baseOrder + 3,
            name = "計量條對齊點",
            desc = "選擇計量條上用來對齊文字的位置。",
            values = ANCHOR_POINTS,
            sorting = ANCHOR_ORDER,
            disabled = off,
            get = function() return s()[p.rel] end,
            set = setter(p.rel),
        },
        [p.x] = {
            type = "range",
            order = baseOrder + 4,
            name = "水平偏移",
            min = -200, max = 200, step = 1,
            disabled = off,
            get = function() return s()[p.x] end,
            set = setter(p.x),
        },
        [p.y] = {
            type = "range",
            order = baseOrder + 5,
            name = "垂直偏移",
            min = -100, max = 100, step = 1,
            disabled = off,
            get = function() return s()[p.y] end,
            set = setter(p.y),
        },
    }
end

local function BuildBarOptionsGroup(key, order)
    local info = BAR_INFO[key]
    local group = {
        type = "group",
        name = info.label,
        order = order,
        args = {
            enabled = {
                type = "toggle",
                order = 1,
                name = "啟用外觀增強",
                desc = "調整" .. info.label .. "攻擊計時條的外觀。停用後恢復暴雪預設外觀。",
                get = function() return EnsureBarDefaults(key).enabled end,
                set = function(_, val)
                    EnsureBarDefaults(key).enabled = val
                    ApplySwingBarSkin(key)
                end,
            },
            textureHeader = { type = "header", name = "計量條", order = 2 },
            texture = {
                type = "select",
                order = 3,
                name = "計量條材質",
                values = function() return BuildMediaValues("statusbar") end,
                get = function() return MediaKeyToFilename("statusbar", EnsureBarDefaults(key).texture) end,
                set = function(_, val)
                    EnsureBarDefaults(key).texture = MediaFilenameToKey("statusbar", val)
                    ApplySwingBarSkin(key)
                end,
            },
            useCustomBarColor = {
                type = "toggle",
                order = 4,
                name = "自訂計量條顏色",
                desc = "使用下方顏色取代計量條的預設填充顏色。",
                get = function() return EnsureBarDefaults(key).useCustomBarColor end,
                set = function(_, val)
                    EnsureBarDefaults(key).useCustomBarColor = val
                    ApplySwingBarSkin(key)
                end,
            },
            barColor = {
                type = "color",
                hasAlpha = true,
                order = 5,
                name = "計量條顏色",
                disabled = function() return not EnsureBarDefaults(key).useCustomBarColor end,
                get = function() return unpack(EnsureBarDefaults(key).barColor) end,
                set = function(_, r, g, b, a)
                    EnsureBarDefaults(key).barColor = {r, g, b, a}
                    ApplySwingBarSkin(key)
                end,
            },
            bgHeader = { type = "header", name = "背景與邊框", order = 6 },
            useDefaultBorderBackground = {
                type = "toggle",
                order = 7,
                name = "使用預設邊框與背景",
                desc = "保留暴雪原有的背景及邊框；計量條材質、顏色及字體設定仍然生效。",
                get = function() return EnsureBarDefaults(key).useDefaultBorderBackground end,
                set = function(_, val)
                    EnsureBarDefaults(key).useDefaultBorderBackground = val
                    ApplySwingBarSkin(key)
                end,
            },
            bgColor = {
                type = "color",
                hasAlpha = true,
                order = 8,
                name = "背景顏色",
                desc = "使用此顏色取代暴雪預設背景。",
                disabled = function() return EnsureBarDefaults(key).useDefaultBorderBackground end,
                get = function() return unpack(EnsureBarDefaults(key).bgColor) end,
                set = function(_, r, g, b, a)
                    EnsureBarDefaults(key).bgColor = {r, g, b, a}
                    ApplySwingBarSkin(key)
                end,
            },
            showCustomBorder = {
                type = "toggle",
                order = 9,
                name = "顯示邊框",
                desc = "使用簡單的 1 像素邊框取代暴雪預設邊框。",
                disabled = function() return EnsureBarDefaults(key).useDefaultBorderBackground end,
                get = function() return EnsureBarDefaults(key).showCustomBorder end,
                set = function(_, val)
                    EnsureBarDefaults(key).showCustomBorder = val
                    ApplySwingBarSkin(key)
                end,
            },
            borderColor = {
                type = "color",
                hasAlpha = true,
                order = 10,
                name = "邊框顏色",
                disabled = function()
                    local s = EnsureBarDefaults(key)
                    return s.useDefaultBorderBackground or not s.showCustomBorder
                end,
                get = function() return unpack(EnsureBarDefaults(key).borderColor) end,
                set = function(_, r, g, b, a)
                    EnsureBarDefaults(key).borderColor = {r, g, b, a}
                    ApplySwingBarSkin(key)
                end,
            },
            borderSize = {
                type = "range",
                order = 11,
                name = "邊框粗細",
                min = 1, max = 4, step = 1,
                disabled = function()
                    local s = EnsureBarDefaults(key)
                    return s.useDefaultBorderBackground or not s.showCustomBorder
                end,
                get = function() return EnsureBarDefaults(key).borderSize end,
                set = function(_, val)
                    EnsureBarDefaults(key).borderSize = val
                    ApplySwingBarSkin(key)
                end,
            },
            fontHeader = { type = "header", name = "文字（名稱／計時）", order = 12 },
            font = {
                type = "select",
                order = 13,
                name = "字體",
                values = function() return BuildMediaValues("font") end,
                get = function() return MediaKeyToFilename("font", EnsureBarDefaults(key).font) end,
                set = function(_, val)
                    EnsureBarDefaults(key).font = MediaFilenameToKey("font", val)
                    ApplySwingBarSkin(key)
                end,
            },
            fontSize = {
                type = "range",
                order = 14,
                name = "字體大小",
                min = 6, max = 32, step = 1,
                get = function() return EnsureBarDefaults(key).fontSize end,
                set = function(_, val)
                    EnsureBarDefaults(key).fontSize = val
                    ApplySwingBarSkin(key)
                end,
            },
            fontFlags = {
                type = "select",
                order = 15,
                name = "字體描邊",
                values = FONT_FLAG_VALUES,
                get = function() return EnsureBarDefaults(key).fontFlags end,
                set = function(_, val)
                    EnsureBarDefaults(key).fontFlags = val
                    ApplySwingBarSkin(key)
                end,
            },
            fontColor = {
                type = "color",
                hasAlpha = true,
                order = 16,
                name = "字體顏色",
                get = function() return unpack(EnsureBarDefaults(key).fontColor) end,
                set = function(_, r, g, b, a)
                    EnsureBarDefaults(key).fontColor = {r, g, b, a}
                    ApplySwingBarSkin(key)
                end,
            },
            copyHeader = { type = "header", name = " ", order = 60 },
            copyToOthers = {
                type = "execute",
                order = 61,
                name = "複製到其他計量條",
                desc = "將此計量條的設定複製到另外兩個攻擊計時條。",
                confirm = true,
                confirmText = "將" .. info.label .. "設定複製到其他攻擊計時條？",
                func = function()
                    local src = EnsureBarDefaults(key)
                    for _, otherKey in ipairs(BAR_ORDER) do
                        if otherKey ~= key then
                            local dst = EnsureBarDefaults(otherKey)
                            for k, v in pairs(src) do
                                if type(v) == "table" then
                                    dst[k] = { unpack(v) }
                                else
                                    dst[k] = v
                                end
                            end
                            ApplySwingBarSkin(otherKey)
                        end
                    end
                end,
            },
        },
    }

    local nameArgs = BuildPositionArgs(key, {
        toggle = "customNamePosition", point = "namePoint", rel = "nameRelPoint",
        x = "nameX", y = "nameY",
    }, "名稱文字位置", 20)
    local timerArgs = BuildPositionArgs(key, {
        toggle = "customTimerPosition", point = "timerPoint", rel = "timerRelPoint",
        x = "timerX", y = "timerY",
    }, "計時文字位置", 40)
    for k, v in pairs(nameArgs) do group.args[k] = v end
    for k, v in pairs(timerArgs) do group.args[k] = v end

    return group
end

local CustomSwingTimerBarOptions = {
    type = "group",
    name = "攻擊計時條",
    childGroups = "tab",
    args = {
        mainhand = BuildBarOptionsGroup("mainhand", 1),
        offhand  = BuildBarOptionsGroup("offhand", 2),
        ranged   = BuildBarOptionsGroup("ranged", 3),
    },
}
_G.CustomSwingTimerBarOptions = CustomSwingTimerBarOptions

local OPTIONS_APP_NAME = "CustomSwingTimerBar"

local optionsRegistered = false

local function EnsureOptionsRegistered()
    if not AceConfig or not AceConfigDialog then return false end
    if not optionsRegistered then
        AceConfig:RegisterOptionsTable(OPTIONS_APP_NAME, CustomSwingTimerBarOptions)
        optionsRegistered = true
    end
    return true
end

-- Also plug into the shared PersonalResourceReskinPlus panel (opened with
-- /prr) alongside the other Custom*Bar modules, same as they do, if that
-- shared panel object exists.
local function TryRegisterWithSharedPanel()
    if _G.PersonalResourceReskinPlus_Options and _G.PersonalResourceReskinPlus_Options.RegisterSubOptions then
        pcall(_G.PersonalResourceReskinPlus_Options.RegisterSubOptions, "CustomSwingTimerBar", CustomSwingTimerBarOptions)
    end
end

local optionsInitFrame = CreateFrame("Frame")
optionsInitFrame:RegisterEvent("PLAYER_LOGIN")
optionsInitFrame:SetScript("OnEvent", function()
    EnsureOptionsRegistered()
    TryRegisterWithSharedPanel()
end)

-- ============================================================================
-- /swingprd slash command
-- ============================================================================

SLASH_SWINGPRD1 = "/swingprd"
SlashCmdList["SWINGPRD"] = function()
    if EnsureOptionsRegistered() then
        pcall(AceConfigDialog.Open, AceConfigDialog, OPTIONS_APP_NAME)
    else
        print("|cffff0000[SwingTimerBars]|r AceConfig is not available.")
    end
end
