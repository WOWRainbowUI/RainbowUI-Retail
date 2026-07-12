local _, ns = ...

-------------------------------------------------------------------------------
-- Data-source registry — single source of truth for every external provider
-- whose data the addon surfaces. Name, homepage and brand icon all live here;
-- dropdown labels, About-tab links and per-section attribution buttons read
-- from this table instead of redefining texture-escape strings inline.
-------------------------------------------------------------------------------

local TEX = "Interface\\AddOns\\ClassCodex\\Textures\\"

-- `color` is the brand accent (r, g, b 0-1) used by the About-tab source cards.
ns.SOURCES = {
    icyveins = { key = "icyveins", name = "Icy Veins", homepage = "https://www.icy-veins.com", iconTex = "icyveins", color = { 0.30, 0.62, 0.90 } },
    ugg      = { key = "ugg",      name = "u.gg",      homepage = "https://u.gg/wow",          iconTex = "ugg",      color = { 0.36, 0.09, 0.77 } },
    bnet     = { key = "bnet",     name = "Blizzard",  homepage = "https://worldofwarcraft.blizzard.com", iconTex = "bnet", color = { 0.10, 0.58, 0.90 } },
}

-- Inline 12px brand icon (texture-escape string) for a source key.
function ns.SourceIcon(key, size, yoff)
    local src = ns.SOURCES[key]
    if not src then return "" end
    size = size or 12
    return "|T" .. TEX .. src.iconTex .. ":" .. size .. ":" .. size .. ":0:" .. (yoff or 0) .. "|t"
end

-- "<icon>  Name" label used by the source dropdowns.
function ns.SourceLabelText(key)
    local src = ns.SOURCES[key]
    if not src then return "" end
    return ns.SourceIcon(key) .. "  " .. src.name
end

-- The texture path consumed by Texture:SetTexture for a source key.
function ns.SourceTexturePath(key)
    local src = ns.SOURCES[key]
    return src and (TEX .. src.iconTex) or nil
end

-------------------------------------------------------------------------------
-- Source attribution affordance — a footer source tag (see CreateSourceTag).
-------------------------------------------------------------------------------
-- Source tag: a right-aligned, click-to-copy label reading "Source:  <logo>
-- Name" (or just "<logo> Name" when opts.noPrefix) for whatever source feeds
-- the active view. The caller anchors it. Call :SetSource(key, url) per render;
-- a nil/unknown key hides it.
function ns.CreateSourceTag(parent, opts)
    opts = opts or {}
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(18)
    btn:RegisterForClicks("LeftButtonUp")

    -- Source logo as a real texture pinned to the right edge. Both the logo and
    -- the text anchor independently to the button (not to each other), so the
    -- +1 y-nudge lifts the logo onto the text's visual centre — the small font's
    -- unused descender space sits the bbox centre ~1px below the visual middle.
    local ICON = 11
    local icon = btn:CreateTexture(nil, "OVERLAY")
    icon:SetSize(ICON, ICON)
    icon:SetPoint("RIGHT", btn, "RIGHT", 0, 1)
    btn.icon = icon

    -- Resting text colour; caller can override (e.g. the Compendium, where the
    -- default dim grey blends into the lighter inset background).
    local rc = opts.textColor or { 0.5, 0.5, 0.5 }
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("RIGHT", btn, "RIGHT", -(ICON + 3), 0)
    fs:SetJustifyH("RIGHT")
    fs:SetTextColor(rc[1], rc[2], rc[3])
    btn.text = fs
    btn:Hide()

    function btn:SetSource(key, url)
        local src = key and ns.SOURCES[key]
        if not src then
            self.url, self.srcName = nil, nil
            self:Hide()
            return
        end
        self.url = url
        self.srcName = src.name
        -- "[Check out] Name <logo>" — text, then the source logo at the end.
        self.icon:SetTexture(ns.SourceTexturePath(key))
        local cta = opts.noPrefix and "" or (ns.L["attribution.visit_cta"] .. " ")
        fs:SetText(cta .. src.name)
        self:SetWidth(fs:GetStringWidth() + 3 + self.icon:GetWidth() + 1)
        self:Show()
    end

    btn:SetScript("OnEnter", function(self)
        if not self.srcName then return end
        self.text:SetTextColor(0.9, 0.9, 0.9)
        -- Footer tags sit at the bottom of the panel — anchor the tooltip above
        -- them so it doesn't run off-screen. Others anchor to the left.
        if opts.tooltipAbove then
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 4)
        else
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        end
        -- Title invites the visit, the page URL shows the destination, then a
        -- blank line and a green actionable hint (the WoW instruction-line idiom).
        GameTooltip:SetText(ns.L["attribution.visit_source"]:format(self.srcName), 1, 0.82, 0)
        if self.url then GameTooltip:AddLine(self.url, 0.6, 0.6, 0.6, true) end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(ns.L["attribution.copy_url"], 0.45, 0.75, 0.45)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        self.text:SetTextColor(rc[1], rc[2], rc[3])
        GameTooltip:Hide()
    end)
    btn:SetScript("OnClick", function(self)
        if self.url and ns.ShowCopyPopup then ns.ShowCopyPopup(self.url, self) end
    end)

    return btn
end

-------------------------------------------------------------------------------
-- Attribution resolution
--
-- Given a logical surface (the active tab / section) and the current class /
-- spec, return the source key + exact page URL to credit. Resolution reads the
-- same saved-vars and data accessors the sections themselves use, so it tracks
-- whatever the user currently has selected without reaching into render state.
-- Returns (key, url) or nil when there's nothing to attribute.
-------------------------------------------------------------------------------

local function perSpec(specKey)
    if specKey and ClassCodexCharDB and ClassCodexCharDB.perSpec then
        return ClassCodexCharDB.perSpec[specKey]
    end
    return nil
end

-- All attribution URLs live in one consolidated table, grouped by source then
-- page, generated per class (see scraper/generate-sources-lua.ts):
--   ClassCodexSources[classToken][specSlug] = {
--     icyveins = { bis, talents, leveling }, ugg = { build } }
-- The helpers below just read from it.

-- Player's class token + spec slug, for the no-arg helpers (docked pane / About
-- tab), which always credit the active spec.
local function playerClassSpec()
    local classToken = select(2, UnitClass("player"))
    local specKey = ns.GetSpecKey and ns.GetSpecKey()
    local spec = specKey and (specKey:match("-(.+)") or specKey) or nil
    return classToken, spec
end

local function srcUrl(class, spec, source, page)
    if not (class and spec) then class, spec = playerClassSpec() end
    local s = _G.ClassCodexSources
    local rec = class and spec and s and s[class] and s[class][spec]
    local pages = rec and rec[source]
    return pages and pages[page] or nil
end

local function icyVeinsGearUrl(class, spec)
    return srcUrl(class, spec, "icyveins", "bis") or ns.SOURCES.icyveins.homepage
end

-- Icy Veins talents page; pass leveling=true for the leveling-guide URL.
local function icyVeinsTalentsUrl(class, spec, leveling)
    if leveling then
        return srcUrl(class, spec, "icyveins", "leveling")
            or srcUrl(class, spec, "icyveins", "talents")
            or ns.SOURCES.icyveins.homepage
    end
    return srcUrl(class, spec, "icyveins", "talents") or ns.SOURCES.icyveins.homepage
end

-- u.gg spec pages are fully deterministic from class + spec, so we build the
-- exact page we scrape each surface from (e.g. .../frost/death_knight/gear)
-- rather than storing per-spec URLs. `page` nil yields the spec root.
local UGG_CLASS_SLUG = { DEATHKNIGHT = "death_knight", DEMONHUNTER = "demon_hunter" }
local function uggPageUrl(class, spec, page)
    if not class or not spec then return ns.SOURCES.ugg.homepage end
    local classSlug = UGG_CLASS_SLUG[class] or class:lower()
    local specSlug = spec:gsub("-", "_")
    local base = string.format("https://u.gg/wow/%s/%s", specSlug, classSlug)
    return page and (base .. "/" .. page) or base
end

local function uggOverviewUrl(class, spec) return uggPageUrl(class, spec, "talents") end
local function uggTalentsUrl(class, spec)  return uggPageUrl(class, spec, "talents") end
local function uggGearUrl(class, spec)     return uggPageUrl(class, spec, "gear") end
local function uggEnchantsUrl(class, spec) return uggPageUrl(class, spec, "gems-and-enchants") end
local function uggTrinketsUrl(class, spec) return uggPageUrl(class, spec, "trinkets") end

-- URL helpers exposed for surfaces that resolve their own selection state
-- (e.g. the Compendium, the talent dropdown). Each falls back to the source
-- homepage when the exact page is unavailable.
ns.SourceUrls = {
    icyVeinsGear   = icyVeinsGearUrl,
    icyVeinsTalents = icyVeinsTalentsUrl,
    uggOverview    = uggOverviewUrl,
    uggTalents     = uggTalentsUrl,
}

-- BiS page URL for a resolved gear-source key (u.gg or Icy Veins).
function ns.BisUrlForKey(key, class, spec)
    if key == "icyveins" then return icyVeinsGearUrl(class, spec) end
    return uggGearUrl(class, spec)
end

-- Map a Gear/Enhancements dropdown string ("Icy Veins"/"u.gg"/"PvP") to a
-- registry key + URL. PvP gear comes from u.gg; defaults to u.gg.
local function fromDropdown(picked, dataType, class, spec)
    if picked == "Icy Veins" then return "icyveins", icyVeinsGearUrl(class, spec) end
    return "ugg", uggGearUrl(class, spec)
end

-- surface: the active tab. class: class token ("MAGE"). specKey: the per-spec
-- saved-var key ("MAGE-frost"); the data-lookup slug ("frost") is derived from
-- it. Returns (key, url) or nil.
function ns.ResolveAttribution(surface, class, specKey)
    local ps = perSpec(specKey)
    local spec = specKey and (specKey:match("-(.+)") or specKey) or nil

    if surface == "guide" then
        -- The Guide's stat priority + talent preview are both Icy Veins.
        return "icyveins", icyVeinsTalentsUrl(class, spec)

    elseif surface == "trinkets" then
        return "ugg", uggTrinketsUrl(class, spec)

    elseif surface == "talents" then
        -- PvP talents come from Blizzard's armory (bnet); the rest from u.gg /
        -- Icy Veins.
        local ts = ns.GetEffectiveTalentSource and ns.GetEffectiveTalentSource() or "ugg"
        if ts == "icyveins" then return "icyveins", icyVeinsTalentsUrl(class, spec) end
        if ts == "pvp" then return "bnet", ns.SOURCES.bnet.homepage end
        return "ugg", uggTalentsUrl(class, spec)

    elseif surface == "bis" then
        local picked = (ps and ps.bisSource) or "Icy Veins"
        return fromDropdown(picked, "bis", class, spec)

    elseif surface == "enhancements" then
        return "ugg", uggEnchantsUrl(class, spec)

    elseif surface == "crafting" then
        return "icyveins", icyVeinsGearUrl(class, spec)

    elseif surface == "stats" then
        -- Stat targets are summed from u.gg's BiS gear list.
        return "ugg", uggGearUrl(class, spec)
    end

    return nil
end
