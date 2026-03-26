-- Utils.lua
local addonName, lv = ...
local L = lv.L

lv.BadgePalettes = lv.BadgePalettes or {}

-- Approved non-currency badge visuals. These are intentionally different from
-- the Myth crest currency palette below; do not "sync" them by eye.
lv.BadgePalettes.shared = {
    default = {
        shell = {0.05, 0.05, 0.05, 0.70},
        inner = {1, 1, 1, 0},
        icon = {1, 1, 1, 1},
        boost = {1, 1, 1, 0},
    },
    hover = {
        shell = {0.92, 0.76, 0.28, 0.95},
        inner = {1, 1, 1, 0},
        icon = {1, 1, 1, 1},
        boost = {1, 1, 1, 0.10},
    },
}

-- Approved currency badge visuals for the Myth Dawncrest art. This palette
-- runs hotter than the shared badges on purpose.
lv.BadgePalettes.currency = {
    default = {
        shell = {0.58, 0.46, 0.18, 0.92},
        inner = {1, 1, 1, 0},
        icon = {1, 1, 1, 1},
        boost = {1, 1, 1, 0},
    },
    hover = {
        shell = {0.86, 0.70, 0.30, 1},
        inner = {1, 1, 1, 0},
        icon = {1, 1, 1, 1},
        boost = {1, 1, 1, 0.10},
    },
}

local function ResolveBadgePalette(palette)
    if type(palette) == "string" then
        return lv.BadgePalettes and lv.BadgePalettes[palette]
    end
    if palette then
        return palette
    end
    return lv.BadgePalettes and lv.BadgePalettes.shared
end

function lv.ApplyBadgePalette(badge, palette, hovered)
    if not badge then return end
    local resolved = ResolveBadgePalette(palette or badge._badgePalette)
    if not resolved then return end
    local state = hovered and resolved.hover or resolved.default
    if hovered then
        if badge.hover then badge.hover:Show() end
    else
        if badge.hover then badge.hover:Hide() end
    end
    if badge.shell then badge.shell:SetVertexColor(unpack(state.shell)) end
    if badge.inner then badge.inner:SetVertexColor(unpack(state.inner)) end
    if badge.icon then badge.icon:SetVertexColor(unpack(state.icon)) end
    if badge.iconBoost then badge.iconBoost:SetVertexColor(unpack(state.boost)) end
end

function lv.SetCircularBadgeState(badge, hovered)
    lv.ApplyBadgePalette(badge, badge and badge._badgePalette or "shared", hovered)
end

function lv.SetCircularBadgeTexture(badge, texture)
    if not badge then return end
    if badge.icon then
        badge.icon:SetTexture(texture)
    end
    if badge.iconBoost then
        badge.iconBoost:SetTexture(texture)
    end
end

function lv.CreateCircularBadge(parent, point, relativeTo, relativePoint, xOffset, yOffset, style, palette)
    style = style or {}
    local frameSize = style.frameSize or 28
    local hoverSize = style.hoverSize or 24
    local shellSize = style.shellSize or 22
    local innerSize = style.innerSize or 20
    local iconSize = style.iconSize or 20
    local texCoord = style.texCoord or 0.04
    local hoverAlpha = style.hoverAlpha or 0.08

    local badge = CreateFrame("Frame", nil, parent)
    badge:SetSize(frameSize, frameSize)
    badge:SetPoint(point, relativeTo, relativePoint, xOffset or 0, yOffset or 0)

    badge.hover = badge:CreateTexture(nil, "BACKGROUND")
    badge.hover:SetSize(hoverSize, hoverSize)
    badge.hover:SetPoint("CENTER")
    badge.hover:SetTexture("Interface\\Buttons\\WHITE8X8")
    badge.hover:SetVertexColor(1, 0.88, 0.35, hoverAlpha)
    badge.hoverMask = badge:CreateMaskTexture()
    badge.hoverMask:SetAllPoints(badge.hover)
    badge.hoverMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    badge.hover:AddMaskTexture(badge.hoverMask)

    badge.shell = badge:CreateTexture(nil, "BORDER")
    badge.shell:SetSize(shellSize, shellSize)
    badge.shell:SetPoint("CENTER")
    badge.shell:SetTexture("Interface\\Buttons\\WHITE8X8")
    badge.shellMask = badge:CreateMaskTexture()
    badge.shellMask:SetAllPoints(badge.shell)
    badge.shellMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    badge.shell:AddMaskTexture(badge.shellMask)

    badge.inner = badge:CreateTexture(nil, "ARTWORK")
    badge.inner:SetSize(innerSize, innerSize)
    badge.inner:SetPoint("CENTER")
    badge.inner:SetTexture("Interface\\Buttons\\WHITE8X8")
    badge.innerMask = badge:CreateMaskTexture()
    badge.innerMask:SetAllPoints(badge.inner)
    badge.innerMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    badge.inner:AddMaskTexture(badge.innerMask)

    badge.icon = badge:CreateTexture(nil, "ARTWORK")
    badge.icon:SetSize(iconSize, iconSize)
    badge.icon:SetPoint("CENTER")
    badge.icon:SetTexCoord(texCoord, 1 - texCoord, texCoord, 1 - texCoord)
    badge.icon:SetBlendMode("BLEND")
    badge.iconMask = badge:CreateMaskTexture()
    badge.iconMask:SetAllPoints(badge.icon)
    badge.iconMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    badge.icon:AddMaskTexture(badge.iconMask)

    badge.iconBoost = badge:CreateTexture(nil, "OVERLAY")
    badge.iconBoost:SetSize(iconSize, iconSize)
    badge.iconBoost:SetPoint("CENTER")
    badge.iconBoost:SetTexCoord(texCoord, 1 - texCoord, texCoord, 1 - texCoord)
    badge.iconBoost:SetBlendMode("ADD")
    badge.iconBoostMask = badge:CreateMaskTexture()
    badge.iconBoostMask:SetAllPoints(badge.iconBoost)
    badge.iconBoostMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    badge.iconBoost:AddMaskTexture(badge.iconBoostMask)

    badge._badgePalette = ResolveBadgePalette(palette) or lv.BadgePalettes.shared
    lv.ApplyBadgePalette(badge, badge._badgePalette, false)
    return badge
end

-- 1. ITEM LEVEL COLORING (Midnight S1 dynamic brackets)
function lv.GetiLvLColor(level)
    level = tonumber(level) or 0
    -- Midnight S1 cap.
    local maxIlvl = 289
    local epic = math.floor(maxIlvl * 0.92)       -- near BiS
    local rare = math.floor(maxIlvl * 0.82)       -- geared
    local uncommon = math.floor(maxIlvl * 0.70)   -- entry

    if level >= maxIlvl then return "ffff8000" -- Legendary (Orange)
    elseif level >= epic then return "ff954ae0" -- Epic (Purple)
    elseif level >= rare then return "ff447ce3" -- Rare (Blue)
    elseif level >= uncommon then return "ff1eff00" -- Uncommon (Green)
    else return "ffffffff" -- Common (White)
    end
end

-- 2. MYTHIC+ SCORE COLORING
function lv.GetMPlusColor(score)
    if score >= 2500 then return "ffff8000" 
    elseif score >= 2000 then return "ffa335ee" 
    elseif score >= 1500 then return "ff0070dd" 
    else return "ffffffff" 
    end
end

-- 3. LIST SYNCHRONIZATION
function lv.SyncOrderList()
    if not LiteVaultDB then return end

    -- Add missing characters (exclude special entries like Warband Bank)
    for key, data in pairs(LiteVaultDB) do
        if type(data) == "table" and data.class and key ~= "Warband Bank"
            and (not data.region or data.region == lv.REGION) then
            local found = false
            if LiteVaultOrder then
                for _, oKey in ipairs(LiteVaultOrder) do if oKey == key then found = true break end end
            end
            if not found then
                if not LiteVaultOrder then LiteVaultOrder = {} end
                table.insert(LiteVaultOrder, key)
            end
        end
    end

    -- Remove invalid characters and special entries
    if LiteVaultOrder then
        for i = #LiteVaultOrder, 1, -1 do
            local k = LiteVaultOrder[i]
            local d = LiteVaultDB[k]
            -- Remove if no data, no class, or is a special entry like Warband Bank
            if not d or not d.class or k == "Warband Bank"
                or (d.region and d.region ~= lv.REGION) then
                table.remove(LiteVaultOrder, i)
            end
        end
    end

    -- Re-apply current sort mode to maintain proper order (favorites first, then sorted)
    if lv.SortCharacterList and lv.currentSortMode then
        lv.SortCharacterList(lv.currentSortMode)
    end
end

function lv.FormatWarbandTime(seconds, style)
    if not seconds or seconds == 0 then return "0h" end

    style = style or 1
    local days = math.floor(seconds / 86400)

    -- Format 1: Classic (1y 45d)
    if style == 1 then
        local hours = math.floor((seconds % 86400) / 3600)
        local years = math.floor(days / 365)
        local remDays = days % 365

        if years > 0 then
            return "|cffffffff" .. L["TIME_YEARS_DAYS"]:format(years, remDays) .. "|r"
        else
            return "|cffffffff" .. L["TIME_DAYS_HOURS"]:format(remDays, hours) .. "|r"
        end

    -- Format 2: Days Only (427 Days)
    elseif style == 2 then
        return "|cffffffff" .. L["TIME_DAYS"]:format(BreakUpLargeNumbers(days)) .. "|r"

    -- Format 3: Raw Hours (10,250 Hours)
    elseif style == 3 then
        local totalHours = math.floor(seconds / 3600)
        return "|cffffffff" .. L["TIME_HOURS"]:format(BreakUpLargeNumbers(totalHours)) .. "|r"
    end
end

-- 5. FRESHNESS CALCULATION (NEW)
function lv.GetFreshnessInfo(lastActiveTimestamp)
    if not lastActiveTimestamp then return {text = L["FRESH_NEVER"], color = {0.5, 0.5, 0.5}, opacity = 0.4, level = 0} end

    local currentTime = time()
    local daysSince = math.floor((currentTime - lastActiveTimestamp) / 86400)

    if daysSince == 0 then
        return {text = L["FRESH_TODAY"], color = {0.13, 0.77, 0.37}, opacity = 1.0, level = 3} -- Green
    elseif daysSince == 1 then
        return {text = L["FRESH_1_DAY"], color = {0.98, 0.75, 0.14}, opacity = 0.95, level = 2} -- Yellow
    elseif daysSince < 7 then
        return {text = L["FRESH_DAYS"]:format(daysSince), color = {0.98, 0.75, 0.14}, opacity = 0.85, level = 2} -- Yellow
    elseif daysSince < 14 then
        return {text = L["FRESH_DAYS"]:format(daysSince), color = {0.58, 0.64, 0.72}, opacity = 0.7, level = 1} -- Grey
    else
        return {text = L["FRESH_DAYS"]:format(daysSince), color = {0.58, 0.64, 0.72}, opacity = 0.5, level = 0} -- Very grey
    end
end

-- 6. SORTING FUNCTIONS (NEW)
lv.currentSortMode = "gold" -- default sort

function lv.SortCharacterList(mode)
    lv.currentSortMode = mode

    if not LiteVaultOrder or not LiteVaultDB then return end

    -- Separate characters into groups
    local currentPlayer = nil
    local favorites = {}
    local nonFavorites = {}

    for _, key in ipairs(LiteVaultOrder) do
        local data = LiteVaultDB[key]
        if data and data.class and not data.isIgnored then
            if key == lv.PLAYER_KEY then
                -- Current player always goes first
                currentPlayer = {key = key, data = data}
            elseif data.isFavorite then
                table.insert(favorites, {key = key, data = data})
            else
                table.insert(nonFavorites, {key = key, data = data})
            end
        end
    end

    -- Sort function based on mode
    local sortFunc
    if mode == "gold" then
        sortFunc = function(a, b) return (a.data.gold or 0) > (b.data.gold or 0) end
    elseif mode == "ilvl" then
        sortFunc = function(a, b) return (a.data.ilvl or 0) > (b.data.ilvl or 0) end
    elseif mode == "mplus" then
        sortFunc = function(a, b) return (a.data.mplus or 0) > (b.data.mplus or 0) end
    elseif mode == "lastActive" then
        sortFunc = function(a, b) return (a.data.lastActiveTimestamp or 0) > (b.data.lastActiveTimestamp or 0) end
    end

    -- Sort non-favorites by current mode
    -- Favorites maintain their relative order (first favorited = first shown)
    table.sort(nonFavorites, sortFunc)

    -- Rebuild order: Current Player -> Favorites -> Sorted Non-Favorites
    LiteVaultOrder = {}

    -- 1. Current player first
    if currentPlayer then
        table.insert(LiteVaultOrder, currentPlayer.key)
    end

    -- 2. Favorites second
    for _, entry in ipairs(favorites) do
        table.insert(LiteVaultOrder, entry.key)
    end

    -- 3. Sorted non-favorites
    for _, entry in ipairs(nonFavorites) do
        table.insert(LiteVaultOrder, entry.key)
    end

    -- 4. Ignored characters at the end
    for key, data in pairs(LiteVaultDB) do
        if type(data) == "table" and data.class and data.isIgnored
            and (not data.region or data.region == lv.REGION) then
            table.insert(LiteVaultOrder, key)
        end
    end
end
