--[[
    Media.lua - BliZzi_Interrupts
    Font and texture resolution.
    Uses LibSharedMedia-3.0 if available, with manual fallbacks.
]]

BIT = BIT or {}
BIT.Media = {}

local LOCALE_FONT_OVERRIDES = {
    ["koKR"] = "Fonts\\2002.TTF",
    ["zhCN"] = "Fonts\\ARKai_T.TTF",
    ["zhTW"] = "Fonts\\blei00d.TTF",
    ["ruRU"] = "Fonts\\FRIZQT___CYR.TTF",
}

-- Built-in WoW fonts (always available, no addon needed)
local BUILTIN_FONTS = {
    { name = "Friz Quadrata (Default)", path = "Fonts\\FRIZQT__.TTF"  },
    { name = "Arial Narrow",            path = "Fonts\\ARIALN.TTF"    },
    { name = "Skurri",                  path = "Fonts\\SKURRI.TTF"    },
    { name = "Morpheus",                path = "Fonts\\MORPHEUS.TTF"  },
}

-- Built-in WoW border textures (always available)
-- Built-in WoW border textures. Only paths that work as Blizzard
-- backdrop `edgeFile` (8-direction sliced edge textures) are kept.
-- Each entry has a `minSize` — the minimum edgeSize at which the texture
-- still reads correctly. Below that the texture collapses to a dark
-- smear, so BIT.UI.ApplyBorderToFrame bumps the effective edgeSize up
-- to this value when drawing.
-- "Solid" uses the flat white texture so users can get a plain coloured
-- border whose look is driven entirely by the Border Color picker.
local BUILTIN_BORDERS = {
    { name = "None",             path = nil,                                                       minSize = 0  },
    { name = "Solid",            path = "Interface\\BUTTONS\\WHITE8X8",                            minSize = 1  },
    { name = "Tooltip (thin)",   path = "Interface\\Tooltips\\UI-Tooltip-Border",                  minSize = 8  },
    { name = "Dialog (wooden)",  path = "Interface\\DialogFrame\\UI-DialogBox-Border",             minSize = 16 },
    { name = "Achievement Wood", path = "Interface\\AchievementFrame\\UI-Achievement-WoodBorder",  minSize = 16 },
    { name = "Achievement Gold", path = "Interface\\AchievementFrame\\UI-Achievement-Border",      minSize = 14 },
    { name = "Tutorial",         path = "Interface\\TutorialFrame\\TutorialFrameBorder",           minSize = 12 },
}

-- Built-in WoW sounds (always available, no addon needed)
local BUILTIN_SOUNDS = {
    { name = "None"                                                                         },
    { name = "Raid Warning",  file = "Sound\\Interface\\RaidWarning.ogg"                  },
    { name = "Error",         file = "Sound\\Interface\\IfloopIsEnd.ogg"                  },
    { name = "Alarm",         file = "Sound\\Interface\\AlarmClockWarning1.ogg"           },
    { name = "Coin",          file = "Sound\\Spells\\SimonGame_Visual_CoinDing.ogg"       },
    { name = "Ping",          file = "Sound\\Doodad\\BellTollNight.ogg"                   },
}

-- Built-in WoW textures (always available)
local BUILTIN_TEXTURES = {
    { name = "Flat",               path = "Interface\\BUTTONS\\WHITE8X8"               },
    { name = "Blizzard (Default)", path = "Interface\\TargetingFrame\\UI-StatusBar"    },
    { name = "Blizzard Raid Bar",  path = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill"     },
}

------------------------------------------------------------
-- Existence checks (for non-LibSM paths)
------------------------------------------------------------
local _probeTex = nil
local _probeFS  = nil

local function GetProbeTex()
    if not _probeTex then
        _probeTex = UIParent:CreateTexture(nil, "ARTWORK")
        _probeTex:SetSize(64, 64)
        _probeTex:Hide()
    end
    return _probeTex
end

local function GetProbeFS()
    if not _probeFS then
        _probeFS = UIParent:CreateFontString(nil, "ARTWORK")
        _probeFS:Hide()
    end
    return _probeFS
end

local function TextureExists(path)
    if not path or path == "" then return false end
    local probe = GetProbeTex()
    probe:SetTexture(path)
    local loaded = probe:GetTexture()
    probe:SetTexture(nil)
    return loaded ~= nil and loaded ~= ""
end

local function FontExists(path)
    local probe = GetProbeFS()
    local ok = pcall(function() probe:SetFont(path, 12, "") end)
    if not ok then return false end
    local loadedPath = probe:GetFont()
    if not loadedPath then return false end
    local normLoaded = loadedPath:lower():gsub("\\", "/")
    local normTarget = path:lower():gsub("\\", "/")
    return normLoaded:find(normTarget:match("[^/]+$") or normTarget, 1, true) ~= nil
end

------------------------------------------------------------
-- Get LibSharedMedia if available
------------------------------------------------------------
local function GetLSM()
    return LibStub and LibStub("LibSharedMedia-3.0", true) or nil
end

------------------------------------------------------------
-- Build available font list
------------------------------------------------------------
function BIT.Media:GetAvailableFonts()
    local out = {}
    local seen = {}

    local lsm = GetLSM()
    if lsm then
        -- Get all fonts registered in LibSharedMedia
        local list = lsm:List("font")
        if list then
            table.sort(list)
            for _, name in ipairs(list) do
                local path = lsm:Fetch("font", name)
                if path and not seen[name] then
                    seen[name] = true
                    table.insert(out, { name = name, path = path })
                end
            end
        end
    end

    -- Always add built-ins if not already covered by LSM
    for _, e in ipairs(BUILTIN_FONTS) do
        if not seen[e.name] and FontExists(e.path) then
            seen[e.name] = true
            table.insert(out, { name = e.name, path = e.path })
        end
    end

    return out
end

------------------------------------------------------------
-- Build available texture list
------------------------------------------------------------
function BIT.Media:GetAvailableTextures()
    local out = {}
    local seen = {}

    local lsm = GetLSM()
    if lsm then
        local list = lsm:List("statusbar")
        if list then
            table.sort(list)
            for _, name in ipairs(list) do
                local path = lsm:Fetch("statusbar", name)
                if path and not seen[name] then
                    seen[name] = true
                    table.insert(out, { name = name, path = path })
                end
            end
        end
    end

    -- Always add built-ins
    for _, e in ipairs(BUILTIN_TEXTURES) do
        if not seen[e.name] then
            seen[e.name] = true
            table.insert(out, { name = e.name, path = e.path })
        end
    end

    return out
end

------------------------------------------------------------
-- Build available border list
------------------------------------------------------------
function BIT.Media:GetAvailableBorders()
    local out  = {}
    local seen = {}

    -- "None" always first
    table.insert(out, { name = "None", path = nil, minSize = 0 })
    seen["None"] = true

    local lsm = GetLSM()
    if lsm then
        local list = lsm:List("border")
        if list then
            table.sort(list)
            for _, name in ipairs(list) do
                local path = lsm:Fetch("border", name)
                if path and not seen[name] then
                    seen[name] = true
                    -- LSM entries have no minSize; conservative default.
                    table.insert(out, { name = name, path = path, minSize = 8 })
                end
            end
        end
    end

    -- Built-in fallbacks
    for _, e in ipairs(BUILTIN_BORDERS) do
        if e.path and not seen[e.name] then
            seen[e.name] = true
            table.insert(out, { name = e.name, path = e.path, minSize = e.minSize or 8 })
        end
    end

    return out
end

-- Returns the minimum edgeSize that keeps the named border texture readable.
-- ApplyBorderToFrame uses this to bump small user-picked sizes up internally
-- so decorative textures (Dialog, Achievement …) don't collapse into a black
-- smear when the user has their Border Size slider at a low value.
function BIT.Media:GetBorderMinSize(name)
    if not name or name == "None" then return 0 end
    for _, e in ipairs(BUILTIN_BORDERS) do
        if e.name == name then return e.minSize or 1 end
    end
    -- LSM / unknown name — conservative default that handles most cases.
    return 8
end


function BIT.Media:Load()
    self.flatTexture = "Interface\\BUTTONS\\WHITE8X8"

    local db     = BIT.db
    -- Font outline: "NONE" maps to empty string for WoW SetFont API
    local outline = db and db.fontOutline or "OUTLINE"
    self.fontFlags = (outline == "NONE") and "" or outline
    local locale = GetLocale()
    local lsm    = GetLSM()

    -- ── Font ──────────────────────────────────────────────
    if db and db.fontPath and FontExists(db.fontPath) then
        -- User override saved and file is still accessible right now
        self.font     = db.fontPath
        self.fontName = db.fontName or "Custom"
    else
        -- Path doesn't resolve. Common scenario on a FRESH WoW restart:
        -- the addon that provided the font hasn't finished loading yet,
        -- so the .ttf isn't in WoW's font cache and FontExists() returns
        -- false. On `/reload` the same check passes because the providing
        -- addon was already loaded in the previous session. Pre-3.6.0 we
        -- wiped db.fontPath here, which permanently destroyed the user's
        -- preference on every cold boot.
        --
        -- New behaviour:
        --   1) Try to re-resolve by NAME via LSM (might give us a working
        --      path even when the saved path is stale).
        --   2) If still no luck, fall back to auto-detect for THIS
        --      session ONLY and KEEP the saved preference intact — the
        --      providing addon may load successfully next time.
        local resolved
        if db and db.fontName and lsm and lsm.IsValid then
            if lsm:IsValid("font", db.fontName) then
                local p = lsm:Fetch("font", db.fontName)
                if p and FontExists(p) then
                    resolved = p
                end
            end
        end

        if resolved then
            -- Re-resolved by name — refresh the saved path so future
            -- loads have the corrected pointer.
            self.font     = resolved
            self.fontName = db.fontName
            db.fontPath   = resolved
        else
            -- No resolution available. Use a session-local fallback but
            -- DO NOT wipe db.fontPath / db.fontName. The user's choice
            -- stays put for the next load attempt.
            if LOCALE_FONT_OVERRIDES[locale] then
                self.font     = LOCALE_FONT_OVERRIDES[locale]
                self.fontName = "Locale-" .. locale
            else
                self.font     = "Fonts\\FRIZQT__.TTF"
                self.fontName = "Friz Quadrata (Default)"
                if lsm then
                    -- Prefer these LSM-registered fonts in order, if present
                    local preferred = { "Naowh", "PT Sans Narrow", "Expressway" }
                    for _, name in ipairs(preferred) do
                        if lsm:IsValid("font", name) then
                            self.font     = lsm:Fetch("font", name)
                            self.fontName = name
                            break
                        end
                    end
                end
            end
        end
    end

    -- ── Texture ───────────────────────────────────────────
    if db and db.barTexturePath then
        self.barTexture     = db.barTexturePath
        self.barTextureName = db.barTextureName or "Custom"
    else
        self.barTexture     = self.flatTexture
        self.barTextureName = "Flat"

        if lsm then
            local preferred = { "Naowh", "Norm", "Minimalist", "Aluminium" }
            for _, name in ipairs(preferred) do
                if lsm:IsValid("statusbar", name) then
                    self.barTexture     = lsm:Fetch("statusbar", name)
                    self.barTextureName = name
                    break
                end
            end
        end
    end

    -- ── Deferred retry (load-order safety) ────────────────
    -- If the user's saved font / texture isn't resolvable RIGHT NOW (the
    -- providing addon may load slightly after BIT on a fresh WoW launch),
    -- schedule a single re-resolve attempt after addon loading settles.
    -- Without this the user would see the fallback font for the rest of
    -- the session even though their saved preference is intact.
    if not self._loadRetryScheduled then
        self._loadRetryScheduled = true
        C_Timer.After(3, function()
            local lsm2 = GetLSM()
            if not lsm2 or not BIT.db then return end
            local refreshed = false
            -- Font: if saved name resolves now to a path we can load and
            -- it differs from the currently-applied one, swap it in.
            if BIT.db.fontName and lsm2.IsValid and lsm2:IsValid("font", BIT.db.fontName) then
                local p = lsm2:Fetch("font", BIT.db.fontName)
                if p and FontExists(p) and p ~= self.font then
                    self.font     = p
                    self.fontName = BIT.db.fontName
                    BIT.db.fontPath = p
                    refreshed = true
                end
            end
            -- Texture: same idea for the bar texture
            if BIT.db.barTextureName and lsm2.IsValid and lsm2:IsValid("statusbar", BIT.db.barTextureName) then
                local p = lsm2:Fetch("statusbar", BIT.db.barTextureName)
                if p and p ~= self.barTexture then
                    self.barTexture     = p
                    self.barTextureName = BIT.db.barTextureName
                    BIT.db.barTexturePath = p
                    refreshed = true
                end
            end
            if refreshed then
                if BIT.UI and BIT.UI.RebuildBars then BIT.UI:RebuildBars() end
                if BIT.SyncCD and BIT.SyncCD.Rebuild then BIT.SyncCD:Rebuild() end
                if BIT.KeystoneList and BIT.KeystoneList.OnSettingsChanged then
                    BIT.KeystoneList:OnSettingsChanged()
                end
            end
        end)
    end
end

function BIT.Media:SetFont(fontString, size)
    local path = self.font
    -- safety: if font path is invalid, fall back to WoW default
    if path then
        local ok = pcall(function() fontString:SetFont(path, size, self.fontFlags or "OUTLINE") end)
        if ok and fontString:GetFont() then return end
    end
    -- fallback — guaranteed to work
    fontString:SetFont("Fonts\\FRIZQT__.TTF", size, "OUTLINE")
end

function BIT.Media:SetBarTexture(widget)
    local tex = self.barTexture or self.flatTexture
    if widget.SetStatusBarTexture then widget:SetStatusBarTexture(tex)
    elseif widget.SetTexture then widget:SetTexture(tex) end
end

------------------------------------------------------------
-- Build available sound list (LSM sounds + built-ins)
------------------------------------------------------------
function BIT.Media:GetAvailableSounds()
    local out  = {}
    local seen = {}
    local lsm  = GetLSM()
    if lsm then
        local list = lsm:List("sound")
        if list then
            table.sort(list)
            for _, name in ipairs(list) do
                local path = lsm:Fetch("sound", name)
                if path and not seen[name] then
                    seen[name] = true
                    out[#out + 1] = { name = name, file = path }
                end
            end
        end
    end
    for _, s in ipairs(BUILTIN_SOUNDS) do
        if not seen[s.name] then
            seen[s.name] = true
            out[#out + 1] = s
        end
    end
    return out
end

------------------------------------------------------------
-- Play a sound by name
------------------------------------------------------------
function BIT.Media:PlayKickSound(soundName)
    if not soundName or soundName == "None" then return end
    local lsm = GetLSM()
    if lsm then
        local path = lsm:Fetch("sound", soundName, true)
        if path then PlaySoundFile(path, "Master"); return end
    end
    for _, s in ipairs(BUILTIN_SOUNDS) do
        if s.name == soundName and s.file then
            PlaySoundFile(s.file, "Master")
            return
        end
    end
end
