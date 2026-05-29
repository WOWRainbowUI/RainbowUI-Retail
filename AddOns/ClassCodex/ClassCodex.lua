local addonName, ns = ...

-- Saved variables (initialized in ADDON_LOADED)
-- ClassCodexDB: account-wide settings
-- ClassCodexCharDB: per-character state

local DATA = ClassCodexData
if not DATA then return end

local L = ns.L

-------------------------------------------------------------------------------
-- Constants
-------------------------------------------------------------------------------

local PANEL_WIDTH = 312
local PANEL_PADDING = 12
local CONTENT_INSET = 8 -- less than PANEL_PADDING to compensate for dropdown/section internal offsets
local BUTTON_SIZE = 36
local WIDGET_DEFAULT_OFFSET_X = -1
local WIDGET_DEFAULT_OFFSET_Y = -148
local WIDGET_OFFSET_MIN = -500
local WIDGET_OFFSET_MAX = 500
local FADE_DURATION = 0.15
local ROW_HEIGHT = 22
local SECTION_HEADER_HEIGHT = 24
local DROPDOWN_HEIGHT = 26
local SUBHEADER_HEIGHT = 30

local RANK_COLORS = {
    { r = 0.64, g = 0.21, b = 0.93 }, -- #1 epic purple
    { r = 0.00, g = 0.44, b = 0.87 }, -- #2 rare blue
    { r = 0.12, g = 1.00, b = 0.00 }, -- #3 uncommon green
    { r = 1.00, g = 1.00, b = 1.00 }, -- #4 common white
    { r = 0.62, g = 0.62, b = 0.62 }, -- #5 poor gray
}

local HERO_TALENT_ATLAS = {
    -- Death Knight
    ["San'layn"]                  = "talents-heroclass-deathknight-sanlayn",
    ["Rider of the Apocalypse"]   = "talents-heroclass-deathknight-rideroftheapocalypse",
    ["Deathbringer"]              = "talents-heroclass-deathknight-deathbringer",
    -- Demon Hunter
    ["Fel-Scarred"]               = "talents-heroclass-demonhunter-felscarred",
    ["Aldrachi Reaver"]           = "talents-heroclass-demonhunter-aldrachireaver",
    ["Annihilator"]               = "talents-heroclass-demonhunter-annihilator",
    ["Void-Scarred"]              = "talents-heroclass-demonhunter-felscarred2",
    -- Druid
    ["Druid of the Claw"]         = "talents-heroclass-druid-druidoftheclaw",
    ["Wildstalker"]               = "talents-heroclass-druid-wildstalker",
    ["Keeper of the Grove"]       = "talents-heroclass-druid-keeperofthegrove",
    ["Elune's Chosen"]            = "talents-heroclass-druid-eluneschosen",
    -- Evoker
    ["Scalecommander"]            = "talents-heroclass-evoker-scalecommander",
    ["Flameshaper"]               = "talents-heroclass-evoker-flameshaper",
    ["Chronowarden"]              = "talents-heroclass-evoker-chronowarden",
    -- Hunter
    ["Sentinel"]                  = "talents-heroclass-hunter-sentinel",
    ["Pack Leader"]               = "talents-heroclass-hunter-packleader",
    ["Dark Ranger"]               = "talents-heroclass-hunter-darkranger",
    -- Mage
    ["Sunfury"]                   = "talents-heroclass-mage-sunfury",
    ["Spellslinger"]              = "talents-heroclass-mage-spellslinger",
    ["Frostfire"]                 = "talents-heroclass-mage-frostfire",
    -- Monk
    ["Conduit of the Celestials"] = "talents-heroclass-monk-conduitofthecelestials",
    ["Shado-Pan"]                 = "talents-heroclass-monk-shadopan",
    ["Shado-pan"]                 = "talents-heroclass-monk-shadopan",
    ["Master of Harmony"]         = "talents-heroclass-monk-masterofharmony",
    -- Paladin
    ["Templar"]                   = "talents-heroclass-paladin-templar",
    ["Lightsmith"]                = "talents-heroclass-paladin-lightsmith",
    ["Herald of the Sun"]         = "talents-heroclass-paladin-heraldofthesun",
    -- Priest
    ["Voidweaver"]                = "talents-heroclass-priest-voidweaver",
    ["Archon"]                    = "talents-heroclass-priest-archon",
    ["Oracle"]                    = "talents-heroclass-priest-oracle",
    -- Rogue
    ["Trickster"]                 = "talents-heroclass-rogue-trickster",
    ["Fatebound"]                 = "talents-heroclass-rogue-fatebound",
    ["Deathstalker"]              = "talents-heroclass-rogue-deathstalker",
    -- Shaman
    ["Totemic"]                   = "talents-heroclass-shaman-totemic",
    ["Stormbringer"]              = "talents-heroclass-shaman-stormbringer",
    ["Farseer"]                   = "talents-heroclass-shaman-farseer",
    -- Warlock
    ["Soul Harvester"]            = "talents-heroclass-warlock-soulharvester",
    ["Hellcaller"]                = "talents-heroclass-warlock-hellcaller",
    ["Diabolist"]                 = "talents-heroclass-warlock-diabolist",
    -- Warrior
    ["Slayer"]                    = "talents-heroclass-warrior-slayer",
    ["Mountain Thane"]            = "talents-heroclass-warrior-mountainthane",
    ["Colossus"]                  = "talents-heroclass-warrior-colossus",
}

-- Reverse map: atlas texture → English hero talent name (locale-independent).
-- Used by GetActiveHeroTalentName() to convert the API's iconAtlas into the
-- English key that matches data.lua entries and HERO_TALENT_ATLAS lookups.
local ATLAS_TO_HERO = {}
for name, atlas in pairs(HERO_TALENT_ATLAS) do
    ATLAS_TO_HERO[atlas] = ATLAS_TO_HERO[atlas] or name
end

-------------------------------------------------------------------------------
-- State
-------------------------------------------------------------------------------

local isFloating = false
local isMinimized = false

-- Registered dock hosts (frames the docked panel can anchor to). External UI
-- suites (e.g. GW2_UI) populate this via ns.RegisterDockHost; built-in entries
-- for PaperDollFrame and CharacterFrame are added during panel setup.
local dockHosts = {}

-------------------------------------------------------------------------------
-- Utility
-------------------------------------------------------------------------------

-- Locale-independent spec key lookup: maps (classToken, specIndex) → data key.
-- specIndex from GetSpecialization() is a number (1-4) and never localized.
local SPEC_KEYS = {
    DEATHKNIGHT  = { "blood", "frost", "unholy" },
    DEMONHUNTER  = { "havoc", "vengeance", "devourer" },
    DRUID        = { "balance", "feral", "guardian", "restoration" },
    EVOKER       = { "devastation", "preservation", "augmentation" },
    HUNTER       = { "beast-mastery", "marksmanship", "survival" },
    MAGE         = { "arcane", "fire", "frost" },
    MONK         = { "brewmaster", "mistweaver", "windwalker" },
    PALADIN      = { "holy", "protection", "retribution" },
    PRIEST       = { "discipline", "holy", "shadow" },
    ROGUE        = { "assassination", "outlaw", "subtlety" },
    SHAMAN       = { "elemental", "enhancement", "restoration" },
    WARLOCK      = { "affliction", "demonology", "destruction" },
    WARRIOR      = { "arms", "fury", "protection" },
}

local function GetClassAndSpec()
    local _, classToken = UnitClass("player")
    local specIndex = GetSpecialization()
    if not specIndex then return classToken, nil end
    local keys = SPEC_KEYS[classToken]
    if not keys or not keys[specIndex] then return classToken, nil end
    return classToken, keys[specIndex]
end

local function GetSpecData()
    local classToken, specKey = GetClassAndSpec()
    if not classToken or not specKey then return nil end
    local classData = DATA[classToken]
    if not classData then return nil end
    return classData[specKey], classToken, specKey
end

local function GetSpecKey()
    local classToken, specKey = GetClassAndSpec()
    if classToken and specKey then return classToken .. "-" .. specKey end
    return nil
end

local function GetActiveHeroTalentName()
    if not C_ClassTalents or not C_ClassTalents.GetActiveHeroTalentSpec then return nil end
    local subTreeID = C_ClassTalents.GetActiveHeroTalentSpec()
    if not subTreeID or subTreeID == 0 then return nil end
    -- C_Traits.GetSubTreeInfo may need configID in some builds; wrap in pcall
    if C_Traits and C_Traits.GetSubTreeInfo then
        local ok, info = pcall(C_Traits.GetSubTreeInfo, subTreeID)
        if not ok and C_ClassTalents.GetActiveConfigID then
            -- Try with configID if single-arg failed
            local configID = C_ClassTalents.GetActiveConfigID()
            if configID then
                ok, info = pcall(C_Traits.GetSubTreeInfo, configID, subTreeID)
            end
        end
        if ok and info then
            -- Prefer locale-independent atlas reverse lookup over localized name
            if info.iconAtlas and ATLAS_TO_HERO[info.iconAtlas] then
                return ATLAS_TO_HERO[info.iconAtlas]
            end
            if info.name then return info.name end
        end
    end
    return nil
end

local function GetSpecIcon()
    local specIndex = GetSpecialization()
    if not specIndex then return nil end
    local _, _, _, icon = GetSpecializationInfo(specIndex)
    return icon
end

local function FadeIn(frame)
    if frame.fadeAnim then frame.fadeAnim:Stop() end
    frame:SetAlpha(0)
    frame:Show()
    if not frame.fadeAnim then
        local ag = frame:CreateAnimationGroup()
        local fade = ag:CreateAnimation("Alpha")
        fade:SetFromAlpha(0)
        fade:SetToAlpha(1)
        fade:SetDuration(FADE_DURATION)
        ag:SetScript("OnFinished", function() frame:SetAlpha(1) end)
        frame.fadeAnim = ag
    end
    frame.fadeAnim:Play()
end

local function GetPanelWidth()
    return PANEL_WIDTH
end

local function GetHeroTalentOptions(specData)
    local seen, options = {}, {}
    local function add(name)
        if name and name ~= "All" and not seen[name] then
            seen[name] = true
            options[#options + 1] = name
        end
    end
    -- Only use priorities — the cleanest source of canonical hero talent names
    if specData.priorities then for _, p in ipairs(specData.priorities) do add(p.heroTalent) end end
    return options
end

local function GetContextOptions(specData, heroTalent)
    local seen, options = {}, {}
    local function add(ctx)
        if ctx and not seen[ctx] then seen[ctx] = true; options[#options + 1] = ctx end
    end
    local function matchesHero(h)
        return h == heroTalent or h == "All" or heroTalent == "All"
    end
    -- Use talent contexts as the primary context source (Raid ST, Mythic+, Delves)
    if specData.talents then
        for _, t in ipairs(specData.talents) do if matchesHero(t.heroTalent) then add(t.context) end end
    end
    -- Fallback: priority contexts
    if #options == 0 and specData.priorities then
        for _, p in ipairs(specData.priorities) do if matchesHero(p.heroTalent) then add(p.context) end end
    end
    return options
end

local function HeroMatches(entryHero, heroTalent)
    if entryHero == heroTalent then return true end
    -- Prefix match: "Templar" matches "Templar ES", "Templar RG", etc.
    if heroTalent and entryHero:sub(1, #heroTalent) == heroTalent
        and entryHero:sub(#heroTalent + 1, #heroTalent + 1) == " " then
        return true
    end
    -- Reverse: heroTalent is longer (e.g. "Templar ES" matches entry "Templar")
    if entryHero and heroTalent:sub(1, #entryHero) == entryHero
        and heroTalent:sub(#entryHero + 1, #entryHero + 1) == " " then
        return true
    end
    return false
end

-- Get unique rotation contexts for a given hero talent (preserves data order)
local function GetRotationContextOptions(specData, heroTalent)
    if not specData.rotation then return {} end
    local seen, options = {}, {}
    local function add(ctx)
        if ctx and not seen[ctx] then seen[ctx] = true; options[#options + 1] = ctx end
    end
    for _, r in ipairs(specData.rotation) do
        if r.heroTalent == heroTalent or r.heroTalent == "All" or HeroMatches(r.heroTalent, heroTalent) then
            add(r.context)
        end
    end
    -- If no matches for this hero, fall back to all available contexts
    if #options == 0 then
        for _, r in ipairs(specData.rotation) do add(r.context) end
    end
    return options
end

-- Find a rotation entry matching hero + rotation context
local function FindRotationByContext(rotations, heroTalent, rotContext)
    if not rotations then return nil end
    -- Exact hero + context
    for _, r in ipairs(rotations) do
        if r.heroTalent == heroTalent and r.context == rotContext then return r end
    end
    -- Prefix hero + context
    for _, r in ipairs(rotations) do
        if HeroMatches(r.heroTalent, heroTalent) and r.context == rotContext then return r end
    end
    -- "All" hero + context
    for _, r in ipairs(rotations) do
        if r.heroTalent == "All" and r.context == rotContext then return r end
    end
    -- Last resort: first entry matching context
    for _, r in ipairs(rotations) do
        if r.context == rotContext then return r end
    end
    return nil
end

-- Get talent builds matching hero + context, returns list of {build, label}
local function GetTalentBuilds(specData, heroTalent, context)
    if not specData.talents then return {} end
    local builds = {}
    -- 1. Exact hero + context
    for _, t in ipairs(specData.talents) do
        if (t.heroTalent == heroTalent or t.heroTalent == "All") and t.context == context then
            builds[#builds + 1] = t
        end
    end
    -- 2. Exact hero, any context
    if #builds == 0 then
        for _, t in ipairs(specData.talents) do
            if t.heroTalent == heroTalent or t.heroTalent == "All" then
                builds[#builds + 1] = t
            end
        end
    end
    return builds
end

-- Get all talent builds for a hero (regardless of context), for the rows display
local function GetAllTalentBuildsForHero(specData, heroTalent)
    if not specData.talents then return {} end
    local builds = {}
    for _, t in ipairs(specData.talents) do
        if t.heroTalent == heroTalent or t.heroTalent == "All" or HeroMatches(t.heroTalent, heroTalent) then
            builds[#builds + 1] = t
        end
    end
    return builds
end

-- Check if stat priorities differ across contexts for a given hero
local function GetStatContextOptions(specData, heroTalent)
    if not specData.priorities then return {} end
    local seen, options = {}, {}
    local statsPerContext = {}
    for _, p in ipairs(specData.priorities) do
        if p.heroTalent == heroTalent or p.heroTalent == "All" or HeroMatches(p.heroTalent, heroTalent) then
            if not seen[p.context] then
                seen[p.context] = true
                options[#options + 1] = p.context
                -- Serialize stats for comparison
                local key = ""
                for _, tier in ipairs(p.stats) do
                    key = key .. table.concat(tier, "=") .. ">"
                end
                statsPerContext[p.context] = key
            end
        end
    end
    -- Only return options if stats actually differ across contexts
    if #options <= 1 then return {} end
    local firstStats = statsPerContext[options[1]]
    for i = 2, #options do
        if statsPerContext[options[i]] ~= firstStats then
            return options -- stats differ, show dropdown
        end
    end
    return {} -- all same, no dropdown needed
end

local function GetPerSpecState()
    local specKey = GetSpecKey()
    if not specKey or not ClassCodexCharDB then return nil end
    if not ClassCodexCharDB.perSpec then ClassCodexCharDB.perSpec = {} end
    if not ClassCodexCharDB.perSpec[specKey] then
        ClassCodexCharDB.perSpec[specKey] = { heroTalent = nil, statContext = nil, rotationContext = nil, trinketContext = nil, bisTab = nil }
    end
    return ClassCodexCharDB.perSpec[specKey]
end

local function FormatRotationStep(stepText)
    return stepText:gsub("{(%d+)}", function(id)
        local spellId = tonumber(id)
        local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellId)
        if info and info.name then return info.name end
        return "Unknown Spell"
    end)
end

-- Evaluate a compound boolean expression over spell IDs and hero-tree labels:
--   number       → IsPlayerSpell(n)
--   H"label"     → currentHeroTalent == label
--   !x           → not x
--   x & y        → both
--   x | y        → either
--   ( ... )      → grouping
-- `&` binds tighter than `|`. Whitespace tolerated. Returns false on any
-- parse failure (safer than throwing — the step just hides).
local function EvalConditionExpr(expr, currentHeroTalent)
    local pos, len = 1, #expr
    local function peek()
        if pos > len then return nil end
        return expr:sub(pos, pos)
    end
    local function eatWs()
        while pos <= len and expr:sub(pos, pos) == " " do pos = pos + 1 end
    end
    local parseOr
    local function parseUnary()
        eatWs()
        local c = peek()
        if c == "!" then
            pos = pos + 1
            return not parseUnary()
        elseif c == "(" then
            pos = pos + 1
            local v = parseOr()
            eatWs()
            if peek() == ")" then pos = pos + 1 end
            return v
        elseif c == "H" and expr:sub(pos + 1, pos + 1) == '"' then
            -- Hero-tree literal: H"<label>". Both sides are normalized to
            -- English (currentHeroTalent via ATLAS_TO_HERO reverse-lookup
            -- in GetActiveHeroTalentName; the label here from Wowhead's
            -- English BBCode), but the addon already case-insensitive-
            -- matches hero options elsewhere (see line ~2714) so we mirror
            -- that here to absorb Wowhead casing drift like Shado-Pan vs
            -- Shado-pan.
            local closing = expr:find('"', pos + 2, true)
            if not closing then return false end
            local label = expr:sub(pos + 2, closing - 1)
            pos = closing + 1
            if not currentHeroTalent then return false end
            return currentHeroTalent:lower() == label:lower()
        else
            local s, e = expr:find("^(%d+)", pos)
            if not s then return false end
            pos = e + 1
            return IsPlayerSpell(tonumber(expr:sub(s, e))) and true or false
        end
    end
    local function parseAnd()
        local v = parseUnary()
        eatWs()
        while peek() == "&" do
            pos = pos + 1
            v = parseUnary() and v
            eatWs()
        end
        return v
    end
    parseOr = function()
        local v = parseAnd()
        eatWs()
        while peek() == "|" do
            pos = pos + 1
            v = parseAnd() or v
            eatWs()
        end
        return v
    end
    return parseOr() and true or false
end

local function ShouldShowStep(stepText, currentHeroTalent)
    local reqId = stepText:match("^%?{(%d+)}:")
    if reqId then return IsPlayerSpell(tonumber(reqId)) end
    local negId = stepText:match("^%?!{(%d+)}:")
    if negId then return not IsPlayerSpell(tonumber(negId)) end
    -- %b() balances nested parens correctly; lazy `.-` would stop at the
    -- first ')' inside an expression like ?((1&2)|3):.
    local exprParen = stepText:match("^%?(%b()):")
    if exprParen then return EvalConditionExpr(exprParen:sub(2, -2), currentHeroTalent) end
    return true
end

local function StripConditionPrefix(stepText)
    stepText = stepText:gsub("^%?!?{%d+}:%s*", "")
    stepText = stepText:gsub("^%?%b():%s*", "")
    return stepText
end

local function GetStepSpellIcon(stepText)
    local stripped = StripConditionPrefix(stepText)
    local spellId = stripped:match("{(%d+)}")
    if spellId then
        local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(tonumber(spellId))
        if info and info.iconID then return info.iconID end
    end
    return "Interface\\Icons\\INV_Misc_QuestionMark"
end

local function FindMatch(entries, heroTalent, context)
    if not entries then return nil end
    -- Exact hero + context
    for _, e in ipairs(entries) do
        if e.heroTalent == heroTalent and e.context == context then return e end
    end
    -- Exact hero, any context
    for _, e in ipairs(entries) do
        if e.heroTalent == heroTalent then return e end
    end
    -- Prefix hero + context
    for _, e in ipairs(entries) do
        if HeroMatches(e.heroTalent, heroTalent) and e.context == context then return e end
    end
    -- Prefix hero, any context
    for _, e in ipairs(entries) do
        if HeroMatches(e.heroTalent, heroTalent) then return e end
    end
    -- "All" + context
    for _, e in ipairs(entries) do
        if e.heroTalent == "All" and e.context == context then return e end
    end
    -- "All", any context
    for _, e in ipairs(entries) do
        if e.heroTalent == "All" then return e end
    end
    return entries[1]
end

local function FindOpener(rotations, heroTalent)
    if not rotations then return nil end
    -- Exact hero match first
    for _, r in ipairs(rotations) do
        if r.context:lower():find("opener") and r.heroTalent == heroTalent then
            return r
        end
    end
    -- Prefix hero match
    for _, r in ipairs(rotations) do
        if r.context:lower():find("opener") and HeroMatches(r.heroTalent, heroTalent) then
            return r
        end
    end
    -- Fallback to "All"
    for _, r in ipairs(rotations) do
        if r.context:lower():find("opener") and r.heroTalent == "All" then
            return r
        end
    end
    -- Last resort: first opener entry
    for _, r in ipairs(rotations) do
        if r.context:lower():find("opener") then
            return r
        end
    end
    return nil
end

local function FindRotation(rotations, heroTalent, context)
    if not rotations then return nil end
    -- Exact hero + context match
    for _, r in ipairs(rotations) do
        if not r.context:lower():find("opener")
            and r.heroTalent == heroTalent and r.context == context then
            return r
        end
    end
    -- Exact hero, any context
    for _, r in ipairs(rotations) do
        if not r.context:lower():find("opener") and r.heroTalent == heroTalent then
            return r
        end
    end
    -- Prefix hero + context match
    for _, r in ipairs(rotations) do
        if not r.context:lower():find("opener")
            and HeroMatches(r.heroTalent, heroTalent) and r.context == context then
            return r
        end
    end
    -- Prefix hero, any context
    for _, r in ipairs(rotations) do
        if not r.context:lower():find("opener") and HeroMatches(r.heroTalent, heroTalent) then
            return r
        end
    end
    -- "All" + context match
    for _, r in ipairs(rotations) do
        if not r.context:lower():find("opener")
            and r.heroTalent == "All" and r.context == context then
            return r
        end
    end
    -- "All", any context
    for _, r in ipairs(rotations) do
        if not r.context:lower():find("opener") and r.heroTalent == "All" then
            return r
        end
    end
    -- Last resort: first non-opener entry (e.g., priorities use "All" but rotation has specific heroes)
    for _, r in ipairs(rotations) do
        if not r.context:lower():find("opener") then
            return r
        end
    end
    return nil
end

-------------------------------------------------------------------------------
-- Panel Frame
-------------------------------------------------------------------------------

local panel = CreateFrame("Frame", "ClassCodexPanel", UIParent, "BackdropTemplate")
panel:SetSize(PANEL_WIDTH, 1)
panel:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 14,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
panel:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
panel:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.8)
panel:SetFrameStrata("HIGH")
panel:SetClampedToScreen(true)
panel:EnableMouse(true)
panel:Hide()

-------------------------------------------------------------------------------
-- Title Bar
-------------------------------------------------------------------------------

local titleBar = CreateFrame("Frame", nil, panel)
titleBar:SetHeight(24)
titleBar:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -6)
titleBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, -6)

local ADDON_ICON_PATH = "Interface\\AddOns\\ClassCodex\\icon"

local specIcon = titleBar:CreateTexture(nil, "ARTWORK")
specIcon:SetSize(18, 18)
specIcon:SetPoint("LEFT", titleBar, "LEFT", PANEL_PADDING, 0)

local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
titleText:SetPoint("LEFT", specIcon, "RIGHT", 6, 0)
local addonVersion = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
titleText:SetText(L["Class Codex"])
titleText:SetTextColor(1, 0.82, 0)
titleText:SetWordWrap(false)
titleText:SetNonSpaceWrap(false)
titleText:SetMaxLines(1)

local closeBtn = CreateFrame("Button", nil, titleBar, "UIPanelCloseButtonNoScripts")
closeBtn:SetSize(20, 20)
closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -PANEL_PADDING + 2, 0)
closeBtn:RegisterForClicks("LeftButtonUp")
closeBtn:SetScript("OnClick", function()
    panel:Hide()
    if ClassCodexCharDB then ClassCodexCharDB.panelOpen = false end
end)

local pinBtn = CreateFrame("Button", nil, titleBar)
pinBtn:SetSize(18, 18)
pinBtn:SetPoint("RIGHT", closeBtn, "LEFT", -1, 0)

local minimizeBtn = CreateFrame("Button", nil, titleBar)
minimizeBtn:SetSize(18, 18)
minimizeBtn:SetPoint("RIGHT", pinBtn, "LEFT", 3, 0)
minimizeBtn:RegisterForClicks("LeftButtonUp")
minimizeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Up")
minimizeBtn:SetHighlightTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Highlight")
minimizeBtn:Hide() -- hidden by default (docked mode); shown by FloatPanel()
minimizeBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(isMinimized and "Expand" or "Minimize", 1, 1, 1)
    GameTooltip:Show()
end)
minimizeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
pinBtn:SetNormalTexture("Interface\\Buttons\\UI-RotationRight-Button-Up")
pinBtn:SetHighlightTexture("Interface\\Buttons\\UI-RotationRight-Button-Up")
pinBtn:GetHighlightTexture():SetAlpha(0.3)
pinBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(isFloating and L["Dock to Character Frame"] or L["Float (detach)"], 1, 1, 1)
    GameTooltip:AddLine(L["Right-click to configure sections"], 0.7, 0.7, 0.7)
    GameTooltip:Show()
end)
pinBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
pinBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

-- Constrain title text to not overlap buttons
titleText:SetPoint("RIGHT", pinBtn, "LEFT", -4, 0)

-- Dragging (only when floating)
titleBar:EnableMouse(true)
titleBar:RegisterForDrag("LeftButton")
titleBar:SetScript("OnDragStart", function()
    if isFloating then panel:StartMoving() end
end)
titleBar:SetScript("OnDragStop", function()
    panel:StopMovingOrSizing()
    if ClassCodexCharDB and isFloating then
        ClassCodexCharDB.floatX = panel:GetLeft()
        ClassCodexCharDB.floatY = panel:GetTop()
    end
end)

-------------------------------------------------------------------------------
-- Side Tabs
-------------------------------------------------------------------------------

local SIDE_TAB_W = 26
local SIDE_TAB_H = 28
local SIDE_TAB_GAP = 2
local activeTab = "guide" -- "guide", "stats", "talents", "bis", "trinkets", "enhancements", "crafts", "about", "supporters"

-- Side tabs use the same BackdropTemplate idiom as section headers and
-- the rest of the addon, plus a HIGHLIGHT layer for native mouse hover
-- (no manual OnEnter alpha tween). The tab anchors with a 1-pixel
-- overlap into the panel so the BackdropTemplate left edge tucks under
-- the panel's own border — visually the two frames still merge.
local function CreateSideTab(parent, icon, tooltip, tabKey)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(SIDE_TAB_W, SIDE_TAB_H)
    btn:RegisterForClicks("LeftButtonUp")
    btn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    btn:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.6)

    -- Native hover highlight (auto-shown on MouseEnter by the engine).
    local hl = btn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.05)

    local tex = btn:CreateTexture(nil, "ARTWORK")
    tex:SetSize(16, 16)
    tex:SetPoint("CENTER", -1, 0)
    if type(icon) == "number" then
        tex:SetTexture(icon)
    elseif type(icon) == "string" and icon:find("[\\/]") then
        tex:SetTexture(icon)
    else
        tex:SetAtlas(icon)
    end
    tex:SetDesaturated(true)
    btn.icon = tex
    btn.tabKey = tabKey

    btn:SetScript("OnEnter", function(self)
        self.icon:SetDesaturated(false)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(tooltip, 1, 1, 1)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        if activeTab ~= self.tabKey and not self.noDesaturate then self.icon:SetDesaturated(true) end
        GameTooltip:Hide()
    end)
    return btn
end

local sideTabs = {}
local bottomTabs = {}

local guideTab = CreateSideTab(panel, "Interface\\Icons\\INV_Misc_Book_11", L["tab.guide"], "guide")
guideTab:SetPoint("TOPLEFT", panel, "TOPRIGHT", -1, -40)
sideTabs[#sideTabs + 1] = guideTab

local statsTab = CreateSideTab(panel, "Interface\\Icons\\INV_Misc_Note_01", L["section.stat_targets"], "stats")
statsTab:SetPoint("TOPLEFT", guideTab, "BOTTOMLEFT", 0, -SIDE_TAB_GAP)
sideTabs[#sideTabs + 1] = statsTab

local talentsTab = CreateSideTab(panel, "Interface\\Icons\\INV_Inscription_TalentTome01", L["section.talents"], "talents")
talentsTab:SetPoint("TOPLEFT", statsTab, "BOTTOMLEFT", 0, -SIDE_TAB_GAP)
sideTabs[#sideTabs + 1] = talentsTab

local bisTab = CreateSideTab(panel, 132349, L["tab.bis_gear"], "bis") -- INV_Chest_Chain_15 (armor)
bisTab:SetPoint("TOPLEFT", talentsTab, "BOTTOMLEFT", 0, -SIDE_TAB_GAP)
sideTabs[#sideTabs + 1] = bisTab

local trinketsTab = CreateSideTab(panel, 135934, L["tab.trinkets"], "trinkets") -- INV_Jewelry_Talisman_07
trinketsTab:SetPoint("TOPLEFT", bisTab, "BOTTOMLEFT", 0, -SIDE_TAB_GAP)
sideTabs[#sideTabs + 1] = trinketsTab

local enhancementsTab = CreateSideTab(panel, 136244, L["tab.enhancements"], "enhancements") -- Trade_Engraving
enhancementsTab:SetPoint("TOPLEFT", trinketsTab, "BOTTOMLEFT", 0, -SIDE_TAB_GAP)
sideTabs[#sideTabs + 1] = enhancementsTab

local craftsTab = CreateSideTab(panel, 136241, L["tab.crafts"], "crafts") -- Trade_BlackSmithing
craftsTab:SetPoint("TOPLEFT", enhancementsTab, "BOTTOMLEFT", 0, -SIDE_TAB_GAP)
sideTabs[#sideTabs + 1] = craftsTab

local supporters = {}
supporters.tab = CreateSideTab(panel, "Interface\\Icons\\Spell_Holy_PrayerOfHealing", L["about.supporters"], "supporters") -- exact same texture path as the Patreon button
supporters.tab.noDesaturate = true -- keep this one in color so it visually matches the Patreon button
supporters.tab.icon:SetDesaturated(false)
bottomTabs[#bottomTabs + 1] = supporters.tab

local aboutTab = CreateSideTab(panel, "Interface\\Icons\\Achievement_Faction_Lorewalkers", L["tab.about"], "about")
bottomTabs[#bottomTabs + 1] = aboutTab

local allTabs = {}
local function UpdateTabAppearance()
    for _, tab in ipairs(allTabs) do
        if activeTab == tab.tabKey then
            tab:SetBackdropBorderColor(1, 0.82, 0, 1)
            tab:SetBackdropColor(0.15, 0.15, 0.15, 0.95)
            tab.icon:SetDesaturated(false)
        else
            tab:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.6)
            tab:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
            if not tab.noDesaturate then tab.icon:SetDesaturated(true) end
        end
    end
end

for _, t in ipairs(sideTabs) do allTabs[#allTabs + 1] = t end
for _, t in ipairs(bottomTabs) do allTabs[#allTabs + 1] = t end
UpdateTabAppearance()

for _, tab in ipairs(allTabs) do
    tab:SetScript("OnClick", function(self)
        activeTab = self.tabKey
        if ClassCodexCharDB then ClassCodexCharDB.activeTab = activeTab end
        UpdateTabAppearance()
        ns:UpdatePanel()
    end)
end

-- Tab visibility rules: which DB keys must ALL be false to hide a tab.
-- The Stats tab uses the same `Stats` DB key as the Guide tab's stat-priority
-- section — toggling stats off in settings hides both surfaces consistently.
local TAB_VISIBILITY_RULES = {
    { tab = guideTab,         tabKey = "guide",         keys = { "Stats", "Talents", "Rotation" } },
    { tab = statsTab,         tabKey = "stats",         keys = { "StatTargets" } },
    { tab = talentsTab,       tabKey = "talents",       keys = { "Talents" } },
    { tab = bisTab,           tabKey = "bis",           keys = { "BisGear" } },
    { tab = trinketsTab,      tabKey = "trinkets",      keys = { "Trinkets" } },
    { tab = enhancementsTab,  tabKey = "enhancements",  keys = { "Enchants", "Gems", "Consumables" } },
    { tab = craftsTab,        tabKey = "crafts",        keys = { "Crafts" } },
}

function ns:UpdateSideTabVisibility(prefix, currentActiveTab)
    local db = ClassCodexDB
    if not db then return currentActiveTab end
    for _, rule in ipairs(TAB_VISIBILITY_RULES) do
        local allDisabled = true
        for _, key in ipairs(rule.keys) do
            if db[prefix .. key] ~= false then allDisabled = false; break end
        end
        if allDisabled then
            rule.tab:Hide()
            if currentActiveTab == rule.tabKey then
                currentActiveTab = "about"
                UpdateTabAppearance()
            end
        else
            rule.tab:Show()
        end
    end
    return currentActiveTab
end

-------------------------------------------------------------------------------
-- Content Container
-------------------------------------------------------------------------------

local contentFrame = CreateFrame("Frame", nil, panel)
contentFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 0, -2)
contentFrame:SetPoint("RIGHT", panel, "RIGHT", 0, 0)
contentFrame:SetHeight(400) -- initial height, updated in LayoutPanel

-------------------------------------------------------------------------------
-- Sub-header: Hero Talent + Context Dropdowns
-------------------------------------------------------------------------------

local subheaderFrame = CreateFrame("Frame", nil, contentFrame)
subheaderFrame:SetHeight(SUBHEADER_HEIGHT)
subheaderFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, 0)
subheaderFrame:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", -CONTENT_INSET, 0)

-- ns.CreateOptionDropdown(name, parent, width) -> Frame
-- Native Blizzard dropdown (WowStyle1DropdownTemplate) wrapped in the
-- minimal API the addon needs. Caller drives state via SetOptions:
--
--   dd:SetOptions(opts, current, onSelect)
--     opts:    array of strings or { label = "Display", value = "key" }
--     current: the value currently selected (drives the closed-state
--              label and the radio checkmark)
--     onSelect(value): invoked when the user picks an option
--
-- The popup, hover state, outside-click dismissal, and gold-on-current
-- styling come from the template — same widget the talent-pane source
-- picker (and now every other dropdown in the addon) uses.
local function CreateOptionDropdown(name, parent, width)
    local dd = CreateFrame("DropdownButton", name, parent, "WowStyle1DropdownTemplate")
    dd:SetSize(width or 140, DROPDOWN_HEIGHT)

    dd._opts, dd._current, dd._onSelect = nil, nil, nil
    dd:SetupMenu(function(_, rootDescription)
        if not dd._opts then return end
        for _, opt in ipairs(dd._opts) do
            local label, value
            if type(opt) == "table" then
                label, value = opt.label or opt.value, opt.value
            else
                label, value = opt, opt
            end
            rootDescription:CreateRadio(
                label,
                function() return value == dd._current end,
                function() if dd._onSelect then dd._onSelect(value) end end
            )
        end
    end)

    function dd:SetOptions(opts, current, onSelect)
        self._opts, self._current, self._onSelect = opts, current, onSelect
        -- WowStyle1Dropdown reads the closed-state label off the option
        -- whose IsSelected returns true. SetDefaultText is the fallback
        -- when no option matches (e.g. spec has no contexts available).
        local fallbackLabel
        if opts and current then
            for _, opt in ipairs(opts) do
                local l, v
                if type(opt) == "table" then l, v = opt.label or opt.value, opt.value
                else l, v = opt, opt end
                if v == current then fallbackLabel = l; break end
            end
        end
        if self.SetDefaultText then self:SetDefaultText(fallbackLabel or current or "") end
        if self.GenerateMenu then self:GenerateMenu() end
    end

    return dd
end

-- Hero dropdown: width is recomputed in LayoutSubheader to span the
-- subheader. The hero atlas icon is embedded inline in the option
-- label via |A:atlas:14:14|a so the closed-state shows the icon
-- without needing a separate texture child anchored to the template.
local heroDropdown = CreateOptionDropdown("ClassCodexHeroDropdown", subheaderFrame)

local function LayoutSubheader(showHero)
    heroDropdown:ClearAllPoints()
    if showHero then
        -- Anchor TOP (not LEFT) so the dropdown sits flush against the
        -- subheader's top edge — without this the LEFT anchor centers
        -- it vertically inside the 30-px subheader, which puts ~3 px of
        -- gap above the dropdown and breaks parity with the Stats tab.
        heroDropdown:SetPoint("TOPLEFT", subheaderFrame, "TOPLEFT", 0, 0)
        heroDropdown:SetPoint("TOPRIGHT", subheaderFrame, "TOPRIGHT", 0, 0)
        heroDropdown:Show()
    else
        heroDropdown:Hide()
        subheaderFrame:SetHeight(1)
    end
end

-- The bespoke dropdownMenu / pool / hider machinery used to live here.
-- Migrated to WowStyle1DropdownTemplate (see CreateOptionDropdown above);
-- the template owns its own popup, hover, outside-click dismissal, and
-- panel-hide cleanup, so none of that scaffolding is needed anymore.

-------------------------------------------------------------------------------
-- Section: Stat Priority
-------------------------------------------------------------------------------

-- Section header used across the docked panel, GearingSections, and
-- Compendium. BackdropTemplate background + hover highlight + right-side
-- arrow so all three surfaces share the same Blizzard-modern visual
-- language. Pass collapsible=false (or omit, defaults to true) to drop
-- the arrow + hover affordance for single-section tabs.
local function CreateSectionHeader(parent, labelText, collapsible)
    if collapsible == nil then collapsible = true end

    local header = CreateFrame("Button", nil, parent)
    header:SetHeight(SECTION_HEADER_HEIGHT)
    header:SetPoint("TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", 0, 0)
    header:RegisterForClicks("LeftButtonUp")
    header:EnableMouse(true)

    local bg = CreateFrame("Frame", nil, header, "BackdropTemplate")
    bg:SetAllPoints()
    bg:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    bg:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    bg:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.6)
    header.bg = bg

    local text = bg:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", 8, 0)
    text:SetText(labelText)
    text:SetTextColor(1, 0.82, 0)
    header.label = text
    header.text = text -- back-compat alias for any old callers

    if collapsible then
        local arrow = bg:CreateTexture(nil, "OVERLAY")
        arrow:SetSize(12, 12)
        arrow:SetPoint("RIGHT", -6, 0)
        arrow:SetTexture("Interface\\Buttons\\UI-MinusButton-Up")
        header.arrow = arrow

        header:SetScript("OnEnter", function(self)
            self.bg:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
            self.bg:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
        end)
        header:SetScript("OnLeave", function(self)
            self.bg:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            self.bg:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.6)
        end)
    end

    return header
end

local function SetCollapsed(content, header, collapsed)
    if collapsed then
        content:Hide()
        if header.arrow then header.arrow:SetTexture("Interface\\Buttons\\UI-PlusButton-Up") end
    else
        content:Show()
        if header.arrow then header.arrow:SetTexture("Interface\\Buttons\\UI-MinusButton-Up") end
    end
end

-- Tab title (non-collapsible, text set dynamically per active tab)
local tabTitle = CreateFrame("Frame", nil, contentFrame)
tabTitle:SetHeight(SECTION_HEADER_HEIGHT)
local tabTitleText = tabTitle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
tabTitleText:SetPoint("LEFT", 2, 0)
tabTitleText:SetTextColor(1, 0.82, 0)
tabTitle:Hide()

local TAB_TITLE_LABELS = {
    guide        = L["tab.guide"],
    stats        = L["section.stat_targets"],
    talents      = L["section.talents"],
    enhancements = L["tab.enhancements"],
}

-- Stat priority info icon on Guide title row (right-aligned)
local statInfoBtn = CreateFrame("Button", nil, tabTitle)
statInfoBtn:SetSize(12, 12)
statInfoBtn:SetPoint("RIGHT", -2, 0)
local statInfoIcon = statInfoBtn:CreateTexture(nil, "ARTWORK")
statInfoIcon:SetAllPoints()
statInfoIcon:SetAtlas("QuestTurnin")
statInfoIcon:SetVertexColor(0.5, 0.5, 0.5)
statInfoBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["settings.label.stat_priority_on_tooltips"], 1, 0.82, 0)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Item tooltips show the stat priority rank (e.g. #1, #2, #3) next to each stat name based on the currently selected hero talent and context.", 1, 1, 1, true)
    GameTooltip:Show()
    statInfoIcon:SetVertexColor(1, 1, 1)
end)
statInfoBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
    statInfoIcon:SetVertexColor(0.5, 0.5, 0.5)
end)

-- Source / attribution info icon on the Stats tab title row. Mirrors the
-- Guide info icon: small grey "?" texture at the right edge, gold-text
-- tooltip on hover with the Archon source URL + sample size + capture
-- date. Click to copy the URL. Updated per-render with the active
-- snapshot via UI.UpdateStatTargetsInfo (defined later).
local statTargetsInfoBtn = CreateFrame("Button", nil, tabTitle)
statTargetsInfoBtn:SetSize(12, 12)
statTargetsInfoBtn:SetPoint("RIGHT", -2, 0)
statTargetsInfoBtn:RegisterForClicks("LeftButtonUp")
local statTargetsInfoIcon = statTargetsInfoBtn:CreateTexture(nil, "ARTWORK")
statTargetsInfoIcon:SetAllPoints()
statTargetsInfoIcon:SetAtlas("QuestTurnin")
statTargetsInfoIcon:SetVertexColor(0.5, 0.5, 0.5)
statTargetsInfoBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("From Archon", 1, 0.82, 0)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Empirical secondary-stat rating targets harvested from the top players for your spec on Archon.gg.", 1, 1, 1, true)
    if self.url then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Click to copy URL", 0.55, 0.55, 0.55)
    end
    GameTooltip:Show()
    statTargetsInfoIcon:SetVertexColor(1, 1, 1)
end)
statTargetsInfoBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
    statTargetsInfoIcon:SetVertexColor(0.5, 0.5, 0.5)
end)
statTargetsInfoBtn:SetScript("OnClick", function(self)
    if self.url and ns.ShowCopyPopup then ns.ShowCopyPopup(self.url, self) end
end)

local statSection = CreateFrame("Frame", nil, contentFrame)
local statHeader = CreateSectionHeader(statSection, L["section.stat_priority"])

local statContent = CreateFrame("Frame", nil, statSection)
statContent:SetPoint("TOPLEFT", statHeader, "BOTTOMLEFT", 0, 0)
statContent:SetPoint("RIGHT", 0, 0)
statContent:SetHeight(200) -- updated dynamically

-- Stat context dropdown (only shown when stats differ across contexts)
local statCtxDropdown = CreateOptionDropdown("ClassCodexStatCtxDropdown", statContent)
statCtxDropdown:SetPoint("TOPLEFT", 0, 0)
statCtxDropdown:SetPoint("TOPRIGHT", 0, 0)
statCtxDropdown:Hide()
local currentStatContext = nil

local statFrames = {}
local MAX_STATS = 10

for i = 1, MAX_STATS do
    local row = CreateFrame("Frame", nil, statContent)
    row:SetHeight(20)
    row:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)
    row:SetPoint("RIGHT", 0, 0)
    local rank = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rank:SetPoint("LEFT", 0, 0)
    rank:SetWidth(20)
    rank:SetJustifyH("CENTER")
    row.rank = rank
    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("LEFT", rank, "RIGHT", 6, 0)
    name:SetPoint("RIGHT", 0, 0)
    name:SetJustifyH("LEFT")
    row.statName = name
    statFrames[i] = row
end

local statSectionCollapsed = false

-------------------------------------------------------------------------------
-- Section: Stat Targets (only shown on the Stats tab)
--
-- Pairs the priority list above with empirical secondary-stat rating
-- targets harvested from Archon (M+ / Raid). Each row carries the live
-- player rating, a Blizzard StatusBar filled toward the target, and a
-- coloured delta arrow. Bars use the standard UI-StatusBar texture so the
-- visual language matches the rest of WoW (cast bars, talent points, etc).
-------------------------------------------------------------------------------

-- Two-line row: stat name + rating readout + status icon on the top line,
-- full-width bar across the bottom. The status icon is a coloured arrow
-- (or check) showing how the player's rating compares to the Archon
-- target — green up = ahead, gold check = on target, red down = behind.
-- Stats tab carries no inner section header: the tab title is the only
-- header, and the visibility of the entire tab is gated by the "Show
-- Stat Targets" setting.
local STAT_TARGET_ROW_HEIGHT = 40
local STAT_TARGET_ROW_GAP = 5
local STAT_TARGET_BAR_HEIGHT = 16
local STAT_TARGETS_MAX_ROWS = 4
-- The bar visualises 0 → 1.3× target so "above" can overshoot the tick
-- mark, "at" sits right on it, and "below" stops short. Without the
-- overshoot range the bar would clamp at 100 % and you couldn't tell
-- "exactly at target" from "way past".
local STAT_TARGET_BAR_MAX_RATIO = 1.3
-- "below" reuses the up-arrow texture vertically flipped (via texCoord) so
-- both arrows share the exact same pixel grid — Blizzard's stock
-- Arrow-Down-Up texture has asymmetric whitespace and renders offset.
-- Status colour semantics: blue = above target (overcapped, can shift
-- stat), green = at target (right where you want to be), red = below
-- target (need more of this stat).
local STAT_STATUS_ICONS = {
    above = { texture = "Interface\\BUTTONS\\Arrow-Up-Up",       r = 0.40, g = 0.70, b = 1.00, texCoord = { 0, 1, 0, 1 } },
    at    = { texture = "Interface\\BUTTONS\\UI-CheckBox-Check", r = 0.40, g = 1.00, b = 0.45, texCoord = { 0, 1, 0, 1 } },
    below = { texture = "Interface\\BUTTONS\\Arrow-Up-Up",       r = 1.00, g = 0.40, b = 0.40, texCoord = { 0, 1, 1, 0 } },
}
-- Bar fill colours (top of the gradient — bottom darkens via the texture).
-- Brighter than the icon set since the gradient washes the bottom out.
local STAT_BAR_COLORS = {
    above = { 0.35, 0.65, 1.00 },
    at    = { 0.40, 1.00, 0.45 },
    below = { 0.95, 0.40, 0.40 },
}
local statTargets = {
    section = CreateFrame("Frame", nil, contentFrame),
    rows = {},
    currentCtx = nil,
}
statTargets.content = CreateFrame("Frame", nil, statTargets.section)
statTargets.content:SetPoint("TOPLEFT", 0, 0)
statTargets.content:SetPoint("RIGHT", 0, 0)
statTargets.content:SetHeight(140)
statTargets.ctxDropdown = CreateOptionDropdown("ClassCodexStatTargetCtxDropdown", statTargets.content)
statTargets.ctxDropdown:SetPoint("TOPLEFT", 0, 0)
statTargets.ctxDropdown:SetPoint("TOPRIGHT", 0, 0)
for i = 1, STAT_TARGETS_MAX_ROWS do
    local row = CreateFrame("Frame", nil, statTargets.content)
    row:SetHeight(STAT_TARGET_ROW_HEIGHT)
    row:SetPoint("LEFT", 0, 0); row:SetPoint("RIGHT", 0, 0)

    local statusIcon = row:CreateTexture(nil, "ARTWORK")
    statusIcon:SetSize(14, 14)
    statusIcon:SetPoint("TOPRIGHT", -2, -2)
    row.statusIcon = statusIcon

    local rating = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rating:SetPoint("RIGHT", statusIcon, "LEFT", -4, 0)
    rating:SetJustifyH("RIGHT")
    row.rating = rating

    local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    name:SetPoint("TOPLEFT", 4, -2)
    name:SetPoint("RIGHT", rating, "LEFT", -4, 0)
    name:SetJustifyH("LEFT")
    row.statName = name

    -- WoW-pattern status bar, modeled on the cast / XP bar:
    --   1px outer black ring   (frame the bar against any backdrop)
    --   1px inner tan bevel    (the WoW gold edge)
    --   dark recessed plate    (the empty/track portion)
    --   1px inner top shadow   (pushes the plate "into" the frame)
    --   gradient fill          (Interface\TargetingFrame\UI-StatusBar)
    --   upper gloss band       (the glassy shine running across the top)
    -- Built from explicit textures rather than BackdropTemplate because
    -- backdrops rendered unreliably as a "red square" at small sizes.
    local barFrame = CreateFrame("Frame", nil, row)
    barFrame:SetPoint("BOTTOMLEFT", 4, 3)
    barFrame:SetPoint("BOTTOMRIGHT", -2, 3)
    barFrame:SetHeight(STAT_TARGET_BAR_HEIGHT)

    local function colorEdge(layer, r, g, b, a)
        local t = barFrame:CreateTexture(nil, layer)
        t:SetColorTexture(r, g, b, a or 1)
        return t
    end
    -- Outer 1px black ring.
    local oTop    = colorEdge("BORDER", 0, 0, 0); oTop:SetPoint("TOPLEFT");        oTop:SetPoint("TOPRIGHT");        oTop:SetHeight(1)
    local oBot    = colorEdge("BORDER", 0, 0, 0); oBot:SetPoint("BOTTOMLEFT");     oBot:SetPoint("BOTTOMRIGHT");     oBot:SetHeight(1)
    local oLeft   = colorEdge("BORDER", 0, 0, 0); oLeft:SetPoint("TOPLEFT");       oLeft:SetPoint("BOTTOMLEFT");     oLeft:SetWidth(1)
    local oRight  = colorEdge("BORDER", 0, 0, 0); oRight:SetPoint("TOPRIGHT");     oRight:SetPoint("BOTTOMRIGHT");   oRight:SetWidth(1)
    -- Inner 1px WoW-tan bevel.
    local iTop    = colorEdge("BORDER", 0.62, 0.51, 0.27); iTop:SetPoint("TOPLEFT", 1, -1);     iTop:SetPoint("TOPRIGHT", -1, -1);    iTop:SetHeight(1)
    local iBot    = colorEdge("BORDER", 0.62, 0.51, 0.27); iBot:SetPoint("BOTTOMLEFT", 1, 1);   iBot:SetPoint("BOTTOMRIGHT", -1, 1);  iBot:SetHeight(1)
    local iLeft   = colorEdge("BORDER", 0.62, 0.51, 0.27); iLeft:SetPoint("TOPLEFT", 1, -1);    iLeft:SetPoint("BOTTOMLEFT", 1, 1);   iLeft:SetWidth(1)
    local iRight  = colorEdge("BORDER", 0.62, 0.51, 0.27); iRight:SetPoint("TOPRIGHT", -1, -1); iRight:SetPoint("BOTTOMRIGHT", -1, 1); iRight:SetWidth(1)

    -- Dark recessed plate (empty portion of the bar).
    local barBg = barFrame:CreateTexture(nil, "BACKGROUND")
    barBg:SetPoint("TOPLEFT", 2, -2)
    barBg:SetPoint("BOTTOMRIGHT", -2, 2)
    barBg:SetColorTexture(0.05, 0.05, 0.05, 1)

    -- 1px inner top shadow: the plate looks pressed into the frame.
    local innerShadow = barFrame:CreateTexture(nil, "BACKGROUND", nil, 1)
    innerShadow:SetColorTexture(0, 0, 0, 0.55)
    innerShadow:SetPoint("TOPLEFT", 2, -2)
    innerShadow:SetPoint("TOPRIGHT", -2, -2)
    innerShadow:SetHeight(1)

    -- Fill: classic UI-StatusBar gradient texture, recoloured per row.
    local fill = barFrame:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("TOPLEFT", 2, -2)
    fill:SetPoint("BOTTOMLEFT", 2, 2)
    fill:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    fill:SetVertexColor(0.85, 0.45, 0.45, 1)
    fill:SetWidth(0)

    -- Upper gloss band — gives the fill the glassy WoW shine. Anchored
    -- to the fill so it tracks the leading edge as progress changes.
    local glossHeight = math.max(2, math.floor((STAT_TARGET_BAR_HEIGHT - 4) * 0.4))
    local gloss = barFrame:CreateTexture(nil, "OVERLAY")
    gloss:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    gloss:SetVertexColor(1, 1, 1, 0.16)
    gloss:SetBlendMode("ADD")
    gloss:SetPoint("TOPLEFT", fill, "TOPLEFT", 0, 0)
    gloss:SetPoint("TOPRIGHT", fill, "TOPRIGHT", 0, 0)
    gloss:SetHeight(glossHeight)

    -- Target tick: a 2px tan line at the 100 %-of-target position. Lets
    -- the eye read distance-to-target without doing math — fill short of
    -- the tick = behind, on the tick = at, past the tick = above.
    local tick = barFrame:CreateTexture(nil, "OVERLAY")
    tick:SetColorTexture(0.95, 0.86, 0.55, 0.95)
    tick:SetWidth(2)
    barFrame.tick = tick

    barFrame:SetScript("OnSizeChanged", function(self, w)
        local p = self.progress or 0
        local inner = math.max(0, w - 4)
        self.fill:SetWidth(math.max(p > 0 and 2 or 0, math.min(p * inner, inner)))
        if self.tick then
            local tickX = 2 + math.floor((1 / STAT_TARGET_BAR_MAX_RATIO) * inner + 0.5)
            self.tick:ClearAllPoints()
            self.tick:SetPoint("TOP", self, "TOPLEFT", tickX, -2)
            self.tick:SetPoint("BOTTOM", self, "BOTTOMLEFT", tickX, 2)
        end
    end)
    barFrame.fill = fill
    row.bar = barFrame

    statTargets.rows[i] = row
end

-- Shown in place of the rating rows when the PvP context is selected
-- for a spec without Murlok data. Keeps PvP discoverable in the
-- dropdown while making it explicit that nothing is being suppressed.
statTargets.pvpFallback = statTargets.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
statTargets.pvpFallback:SetTextColor(0.5, 0.5, 0.5)
statTargets.pvpFallback:SetJustifyH("LEFT")
statTargets.pvpFallback:SetWordWrap(true)
statTargets.pvpFallback:Hide()

-- Shown in place of the rating rows while the player is in combat —
-- Blizzard's taint protection returns "secret" values from
-- GetCombatRating in combat, so we can't compute the bars reliably.
statTargets.combatFallback = statTargets.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
statTargets.combatFallback:SetTextColor(0.5, 0.5, 0.5)
statTargets.combatFallback:SetJustifyH("LEFT")
statTargets.combatFallback:SetWordWrap(true)
statTargets.combatFallback:Hide()

-------------------------------------------------------------------------------
-- Section: Talents
-------------------------------------------------------------------------------

local talentSection = CreateFrame("Frame", nil, contentFrame)
local talentHeader = CreateSectionHeader(talentSection, L["section.talents"])

local talentContent = CreateFrame("Frame", nil, talentSection)
talentContent:SetPoint("TOPLEFT", talentHeader, "BOTTOMLEFT", 0, 0)
talentContent:SetPoint("RIGHT", 0, 0)
talentContent:SetHeight(100) -- updated dynamically

local MAX_TALENT_BUTTONS = 10
local talentButtons = {}
local TALENT_BTN_HEIGHT = 22
local TALENT_BTN_GAP = 4

local TALENT_ACTION_SIZE = 18
local TALENT_ACTION_GAP = 2

local function CreateTalentActionButton(parent, icon, tooltip)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(TALENT_ACTION_SIZE, TALENT_ACTION_SIZE)
    b:RegisterForClicks("LeftButtonUp")
    local tex = b:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture(icon)
    tex:SetDesaturated(true)
    tex:SetVertexColor(0.7, 0.7, 0.7)
    b.icon = tex
    local hl = b:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetTexture(icon)
    hl:SetAlpha(0.3)
    b:SetScript("OnEnter", function(self)
        self.icon:SetDesaturated(false)
        self.icon:SetVertexColor(1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(tooltip, 1, 1, 1)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function(self)
        self.icon:SetDesaturated(true)
        self.icon:SetVertexColor(0.7, 0.7, 0.7)
        GameTooltip:Hide()
    end)
    return b
end

for i = 1, MAX_TALENT_BUTTONS do
    local row = CreateFrame("Frame", nil, talentContent, "BackdropTemplate")
    row:SetHeight(TALENT_BTN_HEIGHT)
    row:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    row:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
    row:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

    -- Apply button (rightmost)
    local applyBtn = CreateTalentActionButton(row,
        "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "Apply talents")
    applyBtn:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    row.applyBtn = applyBtn

    -- Copy button (left of apply)
    local copyBtn = CreateTalentActionButton(row,
        "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", "Copy talent string")
    copyBtn:SetPoint("RIGHT", applyBtn, "LEFT", -TALENT_ACTION_GAP, 0)
    row.copyBtn = copyBtn

    -- Label
    local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("LEFT", 8, 0)
    text:SetPoint("RIGHT", copyBtn, "LEFT", -4, 0)
    text:SetJustifyH("LEFT")
    text:SetTextColor(0.8, 0.8, 0.8)
    row.label = text

    row:SetScript("OnEnter", function(self)
        if not self.isActive then
            self:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
        end
        self.label:SetTextColor(1, 1, 1)
    end)
    row:SetScript("OnLeave", function(self)
        if not self.isActive then
            self:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
        end
        self.label:SetTextColor(self.isActive and 0.3 or 0.8, self.isActive and 1 or 0.8, self.isActive and 0.3 or 0.8)
    end)
    row:Hide()
    talentButtons[i] = row
end

local talentFallback = CreateFrame("Frame", nil, talentContent)
talentFallback:SetHeight(20)
local talentFallbackText = talentFallback:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
talentFallbackText:SetPoint("LEFT", 0, 0)
talentFallbackText:SetPoint("RIGHT", 0, 0)
talentFallbackText:SetJustifyH("LEFT")
talentFallbackText:SetTextColor(0.5, 0.5, 0.5)
talentFallback:Hide()

-- Copy popup — one shared instance for talent strings, source URLs,
-- and anything else the addon wants the user to paste elsewhere.
-- Uses the standard DialogBox bgFile + InputBoxTemplate edit so it
-- reads as a Blizzard dialog rather than yet another bespoke widget.
local copyPopup = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
copyPopup:SetSize(280, 28)
copyPopup:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
copyPopup:SetFrameStrata("DIALOG")
copyPopup:Hide()

local copyEdit = CreateFrame("EditBox", nil, copyPopup, "InputBoxTemplate")
copyEdit:SetSize(260, 18)
copyEdit:SetPoint("CENTER")
copyEdit:SetAutoFocus(true)
copyEdit:SetScript("OnEscapePressed", function() copyPopup:Hide() end)
copyEdit:SetScript("OnEditFocusLost", function() copyPopup:Hide() end)

-- Show the popup with `text` pre-selected. When `anchor` is provided
-- the popup sits below it; otherwise it centers on UIParent (used by
-- the talent-pane build picker, which has no convenient row anchor).
-- Replaces the per-section talentCopyBox / sourceCopyBox / UI.copyBox
-- / TalentPaneDropdown copyBox quartet — one shared widget across
-- every surface that lets the user copy a string.
local function ShowCopyPopup(text, anchor, yOffset)
    copyPopup:ClearAllPoints()
    if anchor then
        copyPopup:SetPoint("TOP", anchor, "BOTTOM", 0, yOffset or -4)
    else
        copyPopup:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    copyEdit:SetText(text or "")
    copyPopup:Show()
    copyEdit:SetFocus()
    copyEdit:HighlightText()
end
ns.ShowCopyPopup = ShowCopyPopup

local talentSectionCollapsed = false

-------------------------------------------------------------------------------
-- Talents Tab: grouped-by-context layout (all heroes, all builds)
--
-- All construction + render helpers below are scoped inside a do block
-- to keep them off the chunk's local table — ClassCodex.lua's main
-- function is dense and brushes against Lua's 200-local cap.
-------------------------------------------------------------------------------

local allTalentContent = CreateFrame("Frame", nil, contentFrame)
allTalentContent:SetHeight(1)
allTalentContent:Hide()

do
local TALENT_CONTEXT_HEADER_HEIGHT = 22
local ALL_TALENT_INDENT = 8
local ALL_TALENT_TOGGLE_HEIGHT = 32 -- DROPDOWN_HEIGHT (26) + 6 gap before sections

-- Header + row pools grow on demand: Wowhead path tops out at ~5
-- hero × ~3 contexts, but Archon adds ~30 encounter rows (M+ overview
-- + dungeons + raid Heroic/Mythic overviews + bosses) plus 3 section
-- headers, so a fixed pre-allocation isn't enough.
-- Per-section collapse state, keyed by header text. Stored alongside
-- the addon's other section-collapse flags so Mythic+ etc. persist
-- across reloads.
local function GetArchonSectionCollapsed(name)
    if not ClassCodexCharDB or not ClassCodexCharDB.collapsed then return false end
    local s = ClassCodexCharDB.collapsed.archonSections
    return s and s[name] or false
end

local function SetArchonSectionCollapsed(name, collapsed)
    if not ClassCodexCharDB then return end
    ClassCodexCharDB.collapsed = ClassCodexCharDB.collapsed or {}
    ClassCodexCharDB.collapsed.archonSections = ClassCodexCharDB.collapsed.archonSections or {}
    -- Store nil for the default (expanded) so the table doesn't grow
    -- with every section the user has ever seen.
    ClassCodexCharDB.collapsed.archonSections[name] = collapsed and true or nil
end

-- Talents-tab section headers reuse the same ns.CreateSectionHeader as
-- every other section in the panel (BackdropTemplate background +
-- right-side arrow + hover highlight), so the Archon Mythic+ / Raid
-- Heroic / Raid Mythic rows look identical to Stat Priority, Talents,
-- Rotation, Enchants, Gems, Consumables.
local allTalentHeaders = {}
local function EnsureTalentHeader(i)
    if allTalentHeaders[i] then return allTalentHeaders[i] end
    local hdr = CreateSectionHeader(allTalentContent, "", true)
    hdr:Hide()
    allTalentHeaders[i] = hdr
    return hdr
end

local allTalentRows = {}
local function EnsureTalentRow(i)
    if allTalentRows[i] then return allTalentRows[i] end
    local row = CreateFrame("Frame", nil, allTalentContent, "BackdropTemplate")
    row:SetHeight(TALENT_BTN_HEIGHT)
    row:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    row:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
    row:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)

    local applyBtn = CreateTalentActionButton(row,
        "Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up", "Apply talents")
    applyBtn:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    row.applyBtn = applyBtn

    local copyBtn = CreateTalentActionButton(row,
        "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", "Copy talent string")
    copyBtn:SetPoint("RIGHT", applyBtn, "LEFT", -TALENT_ACTION_GAP, 0)
    row.copyBtn = copyBtn

    local heroIcon = row:CreateTexture(nil, "ARTWORK")
    heroIcon:SetSize(14, 14)
    heroIcon:SetPoint("LEFT", 6, 0)
    row.heroIcon = heroIcon

    local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("LEFT", heroIcon, "RIGHT", 4, 0)
    text:SetPoint("RIGHT", copyBtn, "LEFT", -4, 0)
    text:SetJustifyH("LEFT")
    text:SetTextColor(0.8, 0.8, 0.8)
    row.label = text

    row:SetScript("OnEnter", function(self)
        if not self.isActive then
            self:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
        end
        self.label:SetTextColor(1, 1, 1)
    end)
    row:SetScript("OnLeave", function(self)
        if not self.isActive then
            self:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
        end
        self.label:SetTextColor(self.isActive and 0.3 or 0.8, self.isActive and 1 or 0.8, self.isActive and 0.3 or 0.8)
    end)
    row:Hide()
    allTalentRows[i] = row
    return row
end

local allTalentFallback = allTalentContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
allTalentFallback:SetTextColor(0.5, 0.5, 0.5)
allTalentFallback:SetText(L["loadout_dock.no_talent_builds"])
allTalentFallback:Hide()

-- Source dropdown (Wowhead | Archon). Persisted via the same per-spec
-- key as the talent pane and Compendium, so flipping one updates all.
-- Each option is prefixed with the source's brand icon via a |T...|t
-- texture escape — no extra widget plumbing needed.
local SOURCE_ICON_WOWHEAD = "|TInterface\\AddOns\\ClassCodex\\Textures\\wowhead:12:12:0:0|t  Wowhead"
local SOURCE_ICON_ARCHON  = "|TInterface\\AddOns\\ClassCodex\\Textures\\archon:12:12:0:0|t  Archon"
local SOURCE_ICON_PVP     = "|TInterface\\AddOns\\ClassCodex\\Textures\\bnet:12:12:0:0|t  PvP"

local allTalentSourceDropdown = CreateOptionDropdown("ClassCodexAllTalentSourceDropdown", allTalentContent, 140)
allTalentSourceDropdown:Hide()
-- Options + current selection are pushed in by UpdateAllTalents via
-- :SetOptions; the WowStyle1Dropdown template owns click + popup.

local function BindAllTalentCopy(row, exportString)
    row.copyBtn:SetScript("OnClick", function()
        ShowCopyPopup(exportString, row)
    end)
end

local function BindAllTalentApply(row, exportString, loadoutLabel)
    row.applyBtn:SetScript("OnClick", function(self)
        local ok, err = ns.ApplyTalentExportString(exportString, loadoutLabel)
        if not ok then
            self.icon:SetVertexColor(1, 0.2, 0.2)
            print("|cff00ccffClass Codex:|r " .. (err or "Failed to apply talents"))
        else
            self.icon:SetVertexColor(1, 0.8, 0)
        end
        C_Timer.After(1.5, function()
            if self.icon then
                self.icon:SetDesaturated(true)
                self.icon:SetVertexColor(0.7, 0.7, 0.7)
            end
        end)
    end)
end

local function RenderAllTalentsWowhead(specData, yPos)
    local talents = specData.talents
    if not talents or #talents == 0 then
        allTalentFallback:SetText(L["loadout_dock.no_talent_builds"])
        allTalentFallback:ClearAllPoints()
        allTalentFallback:SetPoint("TOPLEFT", allTalentContent, "TOPLEFT", 0, -yPos)
        allTalentFallback:Show()
        return yPos + 20
    end

    local activeTalentData = ns.GetActiveTalentSignature()
    local activeHero = GetActiveHeroTalentName and GetActiveHeroTalentName() or nil
    local heroOrder, heroBuilds = ns.GroupBuildsByHero(talents)

    local hdrIdx, rowIdx = 0, 0
    for _, hero in ipairs(heroOrder) do
        hdrIdx = hdrIdx + 1
        local hdr = EnsureTalentHeader(hdrIdx)

        hdr.label:SetText(ns.FormatHeroHeaderText(hero))
        if activeHero and hero ~= activeHero then
            hdr.label:SetTextColor(0.6, 0.55, 0.35)
        else
            hdr.label:SetTextColor(1, 0.82, 0)
        end
        -- Wowhead headers aren't collapsible per-hero — hide the
        -- arrow and clear any leftover OnClick from a prior Archon
        -- render. (The shared CreateSectionHeader's hover effect
        -- stays so the visual style matches the rest of the panel.)
        if hdr.arrow then hdr.arrow:Hide() end
        hdr:SetScript("OnClick", nil)
        hdr:ClearAllPoints()
        hdr:SetPoint("TOPLEFT", allTalentContent, "TOPLEFT", 0, -yPos)
        hdr:SetPoint("RIGHT", allTalentContent, "RIGHT", 0, 0)
        hdr:Show()
        yPos = yPos + TALENT_CONTEXT_HEADER_HEIGHT

        local isActiveHero = not activeHero or hero == activeHero

        for _, build in ipairs(heroBuilds[hero]) do
            rowIdx = rowIdx + 1
            local row = EnsureTalentRow(rowIdx)
            row.heroIcon:Hide()

            local isActive = activeTalentData and ns.ExtractTalentBits(build.exportString) == activeTalentData
            row.isActive = isActive
            if isActive then
                row:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
                row.label:SetTextColor(0.3, 1, 0.3)
            else
                row:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
                if isActiveHero then
                    row.label:SetTextColor(0.8, 0.8, 0.8)
                else
                    row.label:SetTextColor(0.55, 0.55, 0.55)
                end
            end
            row.label:ClearAllPoints()
            row.label:SetPoint("LEFT", row.heroIcon, "RIGHT", 4, 0)
            row.label:SetPoint("RIGHT", row.copyBtn, "LEFT", -4, 0)
            row.label:SetText(ns.FormatBuildLabel(build))

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", allTalentContent, "TOPLEFT", ALL_TALENT_INDENT, -yPos)
            row:SetPoint("RIGHT", allTalentContent, "RIGHT", 0, 0)

            BindAllTalentCopy(row, build.exportString)
            BindAllTalentApply(row, build.exportString, hero .. " " .. (build.context or ""))

            row:Show()
            yPos = yPos + TALENT_BTN_HEIGHT + TALENT_BTN_GAP
        end
        yPos = yPos + 4
    end
    return yPos
end

local function RenderAllTalentsArchon(class, spec, yPos)
    local archon = ns.GetArchonSpecData and ns.GetArchonSpecData(class, spec) or nil
    if not archon or not archon.contexts or not next(archon.contexts) then
        allTalentFallback:SetText(L["loadout_dock.no_archon_builds"] or "No Archon builds available.")
        allTalentFallback:ClearAllPoints()
        allTalentFallback:SetPoint("TOPLEFT", allTalentContent, "TOPLEFT", 0, -yPos)
        allTalentFallback:Show()
        return yPos + 20
    end

    -- ns.BuildMatchesActive (lifted from TalentPaneDropdown.lua) does
    -- map-based equality so Archon's bit-ordering quirks don't hide the
    -- applied build. Falls back to bit-compare if the helper isn't
    -- loaded yet (toc order makes this unreachable in practice but
    -- the guard is cheap).
    local matchActive = ns.BuildMatchesActive
    local activeTalentBits = (not matchActive) and ns.GetActiveTalentSignature() or nil
    local groups = ns.GroupArchonContexts(archon)
    local hdrIdx, rowIdx = 0, 0

    local function emitSection(headerText, entries)
        if not entries or #entries == 0 then return end
        hdrIdx = hdrIdx + 1
        local hdr = EnsureTalentHeader(hdrIdx)
        local collapsed = GetArchonSectionCollapsed(headerText)

        hdr.label:SetText(headerText)
        hdr.label:SetTextColor(1, 0.82, 0)
        if hdr.arrow then
            hdr.arrow:SetTexture(collapsed
                and "Interface\\Buttons\\UI-PlusButton-Up"
                or "Interface\\Buttons\\UI-MinusButton-Up")
            hdr.arrow:Show()
        end
        hdr:SetScript("OnClick", function()
            SetArchonSectionCollapsed(headerText, not GetArchonSectionCollapsed(headerText))
            ns:UpdatePanel()
        end)
        hdr:ClearAllPoints()
        hdr:SetPoint("TOPLEFT", allTalentContent, "TOPLEFT", 0, -yPos)
        hdr:SetPoint("RIGHT", allTalentContent, "RIGHT", 0, 0)
        hdr:Show()
        yPos = yPos + TALENT_CONTEXT_HEADER_HEIGHT

        if collapsed then
            yPos = yPos + 4
            return
        end

        for _, entry in ipairs(entries) do
            local ctx = entry.ctx
            local build = ctx.builds and ctx.builds[1]
            if build then
                rowIdx = rowIdx + 1
                local row = EnsureTalentRow(rowIdx)

                local heroAtlas = build.heroTalent and ns.HERO_TALENT_ATLAS
                    and ns.HERO_TALENT_ATLAS[build.heroTalent]
                if heroAtlas then
                    row.heroIcon:SetAtlas(heroAtlas)
                    row.heroIcon:Show()
                else
                    row.heroIcon:Hide()
                end

                local isActive
                if matchActive then
                    isActive = matchActive(build)
                elseif activeTalentBits then
                    isActive = ns.ExtractTalentBits(build.exportString) == activeTalentBits
                else
                    isActive = false
                end
                row.isActive = isActive
                if isActive then
                    row:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
                    row.label:SetTextColor(0.3, 1, 0.3)
                else
                    row:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
                    row.label:SetTextColor(0.8, 0.8, 0.8)
                end

                row.label:ClearAllPoints()
                local labelLeftOffset = heroAtlas and 24 or 8
                row.label:SetPoint("LEFT", row, "LEFT", labelLeftOffset, 0)
                row.label:SetPoint("RIGHT", row.copyBtn, "LEFT", -4, 0)
                local fullLabel = (ns.GetArchonEncounterLabel and ns.GetArchonEncounterLabel(ctx))
                    or ctx.encounterLabel or "Build"
                row.label:SetText(fullLabel)

                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", allTalentContent, "TOPLEFT", ALL_TALENT_INDENT, -yPos)
                row:SetPoint("RIGHT", allTalentContent, "RIGHT", 0, 0)

                BindAllTalentCopy(row, build.exportString)
                BindAllTalentApply(row, build.exportString,
                    (build.heroTalent or "Archon") .. " " .. fullLabel)

                row:Show()
                yPos = yPos + TALENT_BTN_HEIGHT + TALENT_BTN_GAP
            end
        end
        yPos = yPos + 4
    end

    local mplus = {}
    if groups.mplusOverview then mplus[#mplus + 1] = groups.mplusOverview end
    for _, e in ipairs(groups.mplusDungeons) do mplus[#mplus + 1] = e end
    emitSection("Mythic+", mplus)

    local heroic = {}
    if groups.raidOverviewHeroic then heroic[#heroic + 1] = groups.raidOverviewHeroic end
    for _, e in ipairs(groups.raidHeroicBosses) do heroic[#heroic + 1] = e end
    emitSection("Raid — Heroic", heroic)

    local mythic = {}
    if groups.raidOverviewMythic then mythic[#mythic + 1] = groups.raidOverviewMythic end
    for _, e in ipairs(groups.raidMythicBosses) do mythic[#mythic + 1] = e end
    emitSection("Raid — Mythic", mythic)

    return yPos
end

-- Render the PvP source on the docked Talents side tab. Brackets are
-- grouped under "Arena" / "Battleground" headers (same split the
-- LoadoutDock submenu uses) and rendered using the existing talent-row
-- pool. When no PvP data exists for the spec, writes the talent
-- fallback line — same pattern as RenderAllTalentsArchon.
local function RenderAllTalentsPvP(class, spec, yPos)
    local brackets = ns.GetPvPBracketsWithData
        and ns.GetPvPBracketsWithData(class, spec)
        or {}
    if not brackets or #brackets == 0 then
        allTalentFallback:SetText(L["pvp.no_builds"] or "No PvP builds available.")
        allTalentFallback:ClearAllPoints()
        allTalentFallback:SetPoint("TOPLEFT", allTalentContent, "TOPLEFT", 0, -yPos)
        allTalentFallback:Show()
        return yPos + 20
    end

    local ARENA_GROUP = { "pvp-shuffle", "pvp-2v2", "pvp-3v3" }
    local BG_GROUP    = { "pvp-blitz", "pvp-rbg" }
    local available = {}
    for _, k in ipairs(brackets) do available[k] = true end

    local matchActive = ns.BuildMatchesActive
    local hdrIdx, rowIdx = 0, 0

    local function emitSection(headerText, group)
        local hasAny = false
        for _, k in ipairs(group) do if available[k] then hasAny = true; break end end
        if not hasAny then return end
        hdrIdx = hdrIdx + 1
        local hdr = EnsureTalentHeader(hdrIdx)
        hdr.label:SetText(headerText)
        hdr.label:SetTextColor(1, 0.82, 0)
        if hdr.arrow then hdr.arrow:Hide() end
        hdr:SetScript("OnClick", nil)
        hdr:ClearAllPoints()
        hdr:SetPoint("TOPLEFT", allTalentContent, "TOPLEFT", 0, -yPos)
        hdr:SetPoint("RIGHT", allTalentContent, "RIGHT", 0, 0)
        hdr:Show()
        yPos = yPos + TALENT_CONTEXT_HEADER_HEIGHT

        for _, bracketKey in ipairs(group) do
            if available[bracketKey] then
                local data = ns.GetPvPBuilds and ns.GetPvPBuilds(class, spec, bracketKey)
                local build = data and data.builds and data.builds[1]
                if build then
                    rowIdx = rowIdx + 1
                    local row = EnsureTalentRow(rowIdx)
                    if row.heroIcon then row.heroIcon:Hide() end

                    local isActive = matchActive and matchActive({ exportString = build.exportString }) or false
                    row.isActive = isActive
                    if isActive then
                        row:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
                        row.label:SetTextColor(0.3, 1, 0.3)
                    else
                        row:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
                        row.label:SetTextColor(0.8, 0.8, 0.8)
                    end

                    local bracketLabel = (ns.GetPvPBracketName and ns.GetPvPBracketName(bracketKey)) or bracketKey
                    if data.lowConfidence then
                        bracketLabel = bracketLabel .. " |cff999999(low confidence)|r"
                    end
                    row.label:ClearAllPoints()
                    row.label:SetPoint("LEFT", row, "LEFT", 8, 0)
                    row.label:SetPoint("RIGHT", row.copyBtn, "LEFT", -4, 0)
                    row.label:SetText(bracketLabel)

                    row:ClearAllPoints()
                    row:SetPoint("TOPLEFT", allTalentContent, "TOPLEFT", ALL_TALENT_INDENT, -yPos)
                    row:SetPoint("RIGHT", allTalentContent, "RIGHT", 0, 0)
                    BindAllTalentCopy(row, build.exportString)
                    BindAllTalentApply(row, build.exportString, "PvP " .. bracketLabel)
                    row:Show()
                    yPos = yPos + TALENT_BTN_HEIGHT + TALENT_BTN_GAP
                end
            end
        end
        yPos = yPos + 4
    end

    emitSection(L["pvp.arena"] or "Arena", ARENA_GROUP)
    emitSection(L["pvp.battleground"] or "Battleground", BG_GROUP)
    return yPos
end

function ns:UpdateAllTalents(specData, classToken, specKey)
    for _, h in ipairs(allTalentHeaders) do h:Hide() end
    for _, r in ipairs(allTalentRows) do r:Hide() end
    allTalentFallback:Hide()

    local archonAvailable = classToken and specKey
        and ns.GetArchonSpecData and ns.GetArchonSpecData(classToken, specKey) ~= nil

    local source = (ns.GetEffectiveTalentSource and ns.GetEffectiveTalentSource()) or "wowhead"
    if source == "archon" and not archonAvailable then source = "wowhead" end

    allTalentSourceDropdown:ClearAllPoints()
    allTalentSourceDropdown:SetPoint("TOPLEFT", allTalentContent, "TOPLEFT", 0, 0)
    allTalentSourceDropdown:SetPoint("TOPRIGHT", allTalentContent, "TOPRIGHT", 0, 0)
    -- PvP always appears for discoverability; RenderAllTalentsPvP shows
    -- the fallback line when no data exists for the spec.
    local sourceOpts = {
        { label = SOURCE_ICON_WOWHEAD, value = "wowhead" },
    }
    if archonAvailable then
        sourceOpts[#sourceOpts + 1] = { label = SOURCE_ICON_ARCHON, value = "archon" }
    end
    sourceOpts[#sourceOpts + 1] = { label = SOURCE_ICON_PVP, value = "pvp" }
    allTalentSourceDropdown:SetOptions(sourceOpts, source, function(picked)
        if ns.SetPersistedTalentSource then ns.SetPersistedTalentSource(picked) end
        ns:UpdatePanel()
    end)
    allTalentSourceDropdown:Show()

    local yPos = ALL_TALENT_TOGGLE_HEIGHT
    if source == "archon" then
        yPos = RenderAllTalentsArchon(classToken, specKey, yPos)
    elseif source == "pvp" then
        yPos = RenderAllTalentsPvP(classToken, specKey, yPos)
    else
        yPos = RenderAllTalentsWowhead(specData, yPos)
    end

    allTalentContent:SetHeight(yPos)
    allTalentContent:Show()
end
end -- talents tab construction block

-------------------------------------------------------------------------------
-- Section: Rotation
-------------------------------------------------------------------------------

local rotationSection = CreateFrame("Frame", nil, contentFrame)
local rotationHeader = CreateSectionHeader(rotationSection, L["section.rotation"])

local rotationContent = CreateFrame("Frame", nil, rotationSection)
rotationContent:SetPoint("TOPLEFT", rotationHeader, "BOTTOMLEFT", 0, 0)
rotationContent:SetPoint("RIGHT", 0, 0)
rotationContent:SetHeight(400) -- updated dynamically

-- Rotation context dropdown
local rotCtxDropdown = CreateOptionDropdown("ClassCodexRotCtxDropdown", rotationContent)
rotCtxDropdown:SetPoint("TOPLEFT", 0, 0)
rotCtxDropdown:SetPoint("TOPRIGHT", 0, 0)
local currentRotationContext = nil

local rotationFrames = {}
local MAX_ROTATION_STEPS = 20
local lastRotationContentHeight = 0 -- track actual height for layout

for i = 1, MAX_ROTATION_STEPS do
    local row = CreateFrame("Frame", nil, rotationContent)
    row:SetHeight(ROW_HEIGHT)
    local rank = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rank:SetPoint("TOPLEFT", 0, 0)
    rank:SetWidth(18)
    rank:SetJustifyH("RIGHT")
    rank:SetTextColor(0.5, 0.5, 0.5)
    row.rank = rank
    local icon = row:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetPoint("TOPLEFT", rank, "TOPRIGHT", 4, 0)
    row.icon = icon
    local stepText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    stepText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 4, 0)
    stepText:SetPoint("RIGHT", row, "RIGHT", 0, 0)
    stepText:SetJustifyH("LEFT")
    stepText:SetJustifyV("TOP")
    stepText:SetWordWrap(true)
    stepText:SetNonSpaceWrap(true)
    row.stepText = stepText
    row:EnableMouse(true)
    row:SetScript("OnEnter", function(self)
        if self.spellId then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(self.spellId)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    rotationFrames[i] = row
end

local rotationFallback = CreateFrame("Frame", nil, rotationContent)
rotationFallback:SetHeight(20)
local rotationFallbackText = rotationFallback:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
rotationFallbackText:SetPoint("LEFT", 0, 0)
rotationFallbackText:SetPoint("RIGHT", 0, 0)
rotationFallbackText:SetJustifyH("LEFT")
rotationFallbackText:SetTextColor(0.5, 0.5, 0.5)
rotationFallback:Hide()

local rotationSectionCollapsed = false

-------------------------------------------------------------------------------
-- Footer
-------------------------------------------------------------------------------

local footerSeparator = contentFrame:CreateTexture(nil, "ARTWORK")
footerSeparator:SetHeight(1)
footerSeparator:SetColorTexture(0.4, 0.4, 0.4, 0.5)

local footerFrame = CreateFrame("Frame", nil, contentFrame)
footerFrame:SetHeight(18)

local footerVersion = footerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
footerVersion:SetPoint("LEFT", 0, 0)
footerVersion:SetTextColor(0.4, 0.4, 0.4)
footerVersion:SetText("v" .. (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Version") or GetAddOnMetadata(addonName, "Version") or "?"))

-- Wrapped in `do ... end` so the date helpers don't add to the main-chunk
-- local count — ClassCodex.lua sits close to Lua's 200-locals-per-function
-- ceiling and these helpers don't need to leak outward.
do
    local footerDateButton = CreateFrame("Frame", nil, footerFrame)
    footerDateButton:SetPoint("RIGHT", footerFrame, "RIGHT", 0, 0)
    footerDateButton:SetHeight(18)
    footerDateButton:EnableMouse(true)
    footerDateButton:Hide()

    local footerDate = footerDateButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    footerDate:SetAllPoints(footerDateButton)
    footerDate:SetJustifyH("RIGHT")
    footerDate:SetTextColor(0.4, 0.4, 0.4)

    local MONTH_ABBREV = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }

    local function ParseISODate(iso)
        if type(iso) ~= "string" then return nil end
        local y, m, d = iso:match("^(%d+)-(%d+)-(%d+)$")
        if not y then return nil end
        return tonumber(y), tonumber(m), tonumber(d)
    end

    local function DaysSinceISO(iso)
        local y, m, d = ParseISODate(iso)
        if not y then return nil end
        local then_ = time({ year = y, month = m, day = d, hour = 12 })
        local diff = math.floor((time() - then_) / 86400)
        if diff < 0 then return 0 end
        return diff
    end

    local function FormatAbsoluteDate(iso)
        local y, m, d = ParseISODate(iso)
        if not y then return iso or "" end
        return string.format("%s %d, %d", MONTH_ABBREV[m] or tostring(m), d, y)
    end

    local function FormatRelativeDate(iso)
        local days = DaysSinceISO(iso)
        if not days then return iso or "" end
        if days == 0 then return L["footer.today"] end
        if days == 1 then return L["footer.yesterday"] end
        if days <= 6 then return L["footer.days_ago"]:format(days) end
        return FormatAbsoluteDate(iso)
    end

    -- Muted yellow/red so a stale stamp catches the eye without looking jarring
    -- against the soft-grey footer text the player sees on normal days.
    local function StaleColor(iso)
        local days = DaysSinceISO(iso)
        if not days then return 0.4, 0.4, 0.4 end
        if days >= 5 then return 0.78, 0.40, 0.40 end
        if days >= 2 then return 0.80, 0.66, 0.30 end
        return 0.4, 0.4, 0.4
    end

    local function RefreshFooterDate()
        local iso = ClassCodex_LastScrape
        if type(iso) ~= "string" or iso == "" then
            footerDate:SetText("")
            footerDateButton:Hide()
            return
        end
        footerDate:SetText(FormatRelativeDate(iso))
        footerDate:SetTextColor(StaleColor(iso))
        footerDateButton:SetWidth(math.max(footerDate:GetStringWidth() + 4, 1))
        footerDateButton:Show()
    end

    footerDateButton:SetScript("OnEnter", function(self)
        local iso = ClassCodex_LastScrape
        if type(iso) ~= "string" or iso == "" then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(L["footer.last_refreshed"]:format(FormatAbsoluteDate(iso)), 1, 0.82, 0)
        GameTooltip:AddLine(L["footer.data_refresh_hint"], 1, 1, 1, true)
        GameTooltip:Show()
    end)
    footerDateButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

    RefreshFooterDate()
end


-------------------------------------------------------------------------------
-- Supporters Tab Content
-------------------------------------------------------------------------------

supporters.title = CreateFrame("Frame", nil, contentFrame)
supporters.title:SetHeight(SECTION_HEADER_HEIGHT)
do
    local title = supporters.title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", 2, 0)
    title:SetText(L["about.supporters"])
    title:SetTextColor(1, 0.82, 0)
end
supporters.title:Hide()

supporters.content = CreateFrame("Frame", nil, contentFrame)
supporters.content:SetHeight(1)
supporters.content:Hide()

-- Hand-curated for now. Tomorrow this becomes an auto-fetched list
-- pulled from the Patreon API; until then, names land here in the
-- order they pledged. Tier order matches display order — Champions
-- render above Supporters.
local CHAMPIONS = {
    "Tantify",
}
local SUPPORTERS = {
    "Bxnane",
    "Rod",
    "Alida Bell",
    "Furkan Yünkül",
}

do
    local desc = supporters.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", 2, 0)
    desc:SetWidth(PANEL_WIDTH - SIDE_TAB_W - CONTENT_INSET * 2 - 10)
    desc:SetJustifyH("LEFT")
    desc:SetWordWrap(true)
    desc:SetTextColor(0.7, 0.7, 0.7)
    desc:SetText(L["about.free_message"])

    -- supporters.lastChild is the bottom-most rendered element, so the
    -- layout in the supporters tab can size the content frame correctly.
    if #CHAMPIONS == 0 and #SUPPORTERS == 0 then
        supporters.empty = supporters.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        supporters.empty:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
        supporters.empty:SetTextColor(0.5, 0.5, 0.5)
        supporters.empty:SetText(L["about.be_first_supporter"])
        supporters.lastChild = supporters.empty
    else
        local heart = "|TInterface\\Icons\\Spell_Holy_PrayerOfHealing:14:14:0:0|t"
        local prev = desc
        local firstName = true

        -- Renders each name in `names` with `color`. Tier is conveyed by
        -- colour alone — Champions (gold) above Supporters (coral) —
        -- with no header rows separating the groups so a short list
        -- doesn't feel padded. `firstName` toggles the larger top gap
        -- on the very first row, regardless of which tier it belongs to.
        local function renderTier(names, color)
            for _, name in ipairs(names) do
                local row = supporters.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, firstName and -14 or -2)
                row:SetText(heart .. "  " .. name)
                row:SetTextColor(color[1], color[2], color[3])
                prev = row
                firstName = false
            end
        end

        -- Champions: gold to signal the higher tier. Supporters keep
        -- the coral tint that matches the Patreon button so the colour
        -- language already familiar to users carries over.
        renderTier(CHAMPIONS, { 0.98, 0.78, 0.18 })
        renderTier(SUPPORTERS, { 0.98, 0.65, 0.50 })
        supporters.lastChild = prev
    end
end

-- supporters.patreonBtn created after CreateAboutButton is defined (see below)

-------------------------------------------------------------------------------
-- About Tab Content
-------------------------------------------------------------------------------

-- About tab title (non-collapsible, matches style of other tab titles)
local addonVersion = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(addonName, "Version") or GetAddOnMetadata(addonName, "Version") or "?"
local aboutTabTitle = CreateFrame("Frame", nil, contentFrame)
aboutTabTitle:SetHeight(SECTION_HEADER_HEIGHT)
local aboutTabTitleText = aboutTabTitle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
aboutTabTitleText:SetPoint("LEFT", 2, 0)
aboutTabTitleText:SetText(L["about.title"]:format(addonVersion))
aboutTabTitleText:SetTextColor(1, 0.82, 0)
aboutTabTitle:Hide()

local aboutContent = CreateFrame("Frame", nil, contentFrame)
aboutContent:SetHeight(1) -- dynamically sized in layout
aboutContent:Hide()

local ABOUT_TEXT_WIDTH = PANEL_WIDTH - SIDE_TAB_W - CONTENT_INSET * 2 - 10

local aboutDesc = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
aboutDesc:SetPoint("TOPLEFT", 2, 0)
aboutDesc:SetWidth(ABOUT_TEXT_WIDTH)
aboutDesc:SetJustifyH("LEFT")
aboutDesc:SetWordWrap(true)
aboutDesc:SetNonSpaceWrap(true)
aboutDesc:SetText(L["about.description"])

-- Shared copy box for URLs (used by author + data links)
-- About-tab links share the same copyPopup as the talent rows; no
-- separate widget is needed.

-- Links section
local LINK_INDENT = 10

local function CreateAboutLink(parent, anchor, label, url, yOffset)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(16)
    btn:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOffset or -6)
    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("LEFT", LINK_INDENT, 0)
    text:SetTextColor(0.27, 0.6, 1)
    text:SetText(label)
    btn:SetSize(text:GetStringWidth() + LINK_INDENT + 4, 16)
    btn:SetScript("OnEnter", function()
        text:SetTextColor(0.4, 0.7, 1)
        GameTooltip:SetOwner(btn, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine("Click to copy URL", 1, 1, 1)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        text:SetTextColor(0.27, 0.6, 1)
        GameTooltip:Hide()
    end)
    btn:SetScript("OnClick", function()
        ShowCopyPopup(type(url) == "function" and url() or url, btn)
    end)
    return btn
end

-- Commands hint
local aboutSlash = aboutContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
aboutSlash:SetPoint("LEFT", aboutDesc, "LEFT", 0, 0)
aboutSlash:SetPoint("TOP", aboutDesc, "BOTTOM", 0, -10)
aboutSlash:SetWidth(ABOUT_TEXT_WIDTH)
aboutSlash:SetJustifyH("LEFT")
aboutSlash:SetTextColor(0.5, 0.5, 0.5)
aboutSlash:SetText(L["about.help_hint"])


-- Settings button — dropdown style, full width, anchored to bottom of panel area
local aboutSettingsBtn = CreateFrame("Button", nil, contentFrame, "BackdropTemplate")
aboutSettingsBtn:SetHeight(24)
aboutSettingsBtn:Hide()
aboutSettingsBtn:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
aboutSettingsBtn:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
aboutSettingsBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
local aboutSettingsText = aboutSettingsBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
aboutSettingsText:SetPoint("CENTER", 0, 0)
aboutSettingsText:SetText("|TInterface\\Buttons\\UI-OptionsButton:12:12:0:0|t  " .. L["compendium.open_settings"])
aboutSettingsText:SetTextColor(0.8, 0.8, 0.8)
aboutSettingsBtn:SetScript("OnEnter", function(self)
    self:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    aboutSettingsText:SetTextColor(1, 1, 1)
end)
aboutSettingsBtn:SetScript("OnLeave", function(self)
    self:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
    aboutSettingsText:SetTextColor(0.8, 0.8, 0.8)
end)
aboutSettingsBtn:SetScript("OnClick", function()
    if Settings and Settings.OpenToCategory and ns.settingsCategory then
        Settings.OpenToCategory(ns.settingsCategory:GetID())
    end
end)

-- Compendium button (above settings button)
local aboutCompendiumBtn = CreateFrame("Button", nil, contentFrame, "BackdropTemplate")
aboutCompendiumBtn:SetHeight(24)
aboutCompendiumBtn:Hide()
aboutCompendiumBtn:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
})
aboutCompendiumBtn:SetBackdropColor(0.15, 0.15, 0.15, 0.9)
aboutCompendiumBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
local aboutCompendiumText = aboutCompendiumBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
aboutCompendiumText:SetPoint("CENTER", 0, 0)
aboutCompendiumText:SetText("|TInterface\\Icons\\INV_Misc_Book_09:12:12:0:0|t  " .. L["compendium.open_compendium"])
aboutCompendiumText:SetTextColor(0.8, 0.8, 0.8)
aboutCompendiumBtn:SetScript("OnEnter", function(self)
    self:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
    aboutCompendiumText:SetTextColor(1, 1, 1)
end)
aboutCompendiumBtn:SetScript("OnLeave", function(self)
    self:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
    aboutCompendiumText:SetTextColor(0.8, 0.8, 0.8)
end)
aboutCompendiumBtn:SetScript("OnClick", function()
    if ns.OpenCompendium then ns:OpenCompendium() end
end)
ns.aboutCompendiumBtn = aboutCompendiumBtn

-- About tab action buttons (Discord, Data, Compendium, Settings)
local function CreateAboutButton(label, bgR, bgG, bgB, borderR, borderG, borderB)
    local btn = CreateFrame("Button", nil, contentFrame, "BackdropTemplate")
    btn:SetHeight(24)
    btn:Hide()
    btn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    btn:SetBackdropColor(bgR or 0.15, bgG or 0.15, bgB or 0.15, 0.9)
    btn:SetBackdropBorderColor(borderR or 0.4, borderG or 0.4, borderB or 0.4, 0.8)
    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("CENTER", 0, 0)
    text:SetText(label)
    text:SetTextColor(0.8, 0.8, 0.8)
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor((borderR or 0.4) + 0.2, (borderG or 0.4) + 0.2, (borderB or 0.4) + 0.2, 1)
        text:SetTextColor(1, 1, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(borderR or 0.4, borderG or 0.4, borderB or 0.4, 0.8)
        text:SetTextColor(0.8, 0.8, 0.8)
    end)
    return btn
end

local function SetCopyOnClick(btn, url)
    btn:SetScript("OnClick", function()
        ShowCopyPopup(type(url) == "function" and url() or url, btn)
    end)
end

-- Discord button (blurple tint)
local aboutDiscordBtn = CreateAboutButton("|TInterface\\ChatFrame\\UI-ChatIcon-Chat-Up:12:12:0:0|t  Join Discord — Bugs, Feedback & Help", 0.34, 0.40, 0.95, 0.34, 0.40, 0.95)
SetCopyOnClick(aboutDiscordBtn, "https://discord.gg/WY7HQaVkRw")

-- Patreon button (coral tint) — shared style, used on both About and Supporters tabs
local patreonLabel = "|TInterface\\Icons\\Spell_Holy_PrayerOfHealing:12:12:0:0|t  " .. L["about.support_patreon"]
local aboutPatreonBtn = CreateAboutButton(patreonLabel, 0.6, 0.25, 0.20, 0.98, 0.41, 0.33)
SetCopyOnClick(aboutPatreonBtn, "https://www.patreon.com/classcodex")

supporters.patreonBtn = CreateAboutButton(patreonLabel, 0.6, 0.25, 0.20, 0.98, 0.41, 0.33)
SetCopyOnClick(supporters.patreonBtn, "https://www.patreon.com/classcodex")

-- Data source buttons — neutral chrome, bundled site logos
local aboutDataBtn = CreateAboutButton("|TInterface\\AddOns\\ClassCodex\\Textures\\wowhead:12:12:0:0|t  Wowhead Data")
SetCopyOnClick(aboutDataBtn, function()
    local specData = GetSpecData()
    return specData and specData.sourceUrl or "https://www.wowhead.com"
end)

local aboutIcyVeinsBtn = CreateAboutButton("|TInterface\\AddOns\\ClassCodex\\Textures\\icyveins:12:12:0:0|t  Icy Veins (BiS Gear) Data")
SetCopyOnClick(aboutIcyVeinsBtn, function()
    local classToken = select(2, UnitClass("player"))
    local specKey = ns.GetSpecKey and ns.GetSpecKey() or nil
    local spec = specKey and (specKey:match("-(.+)") or specKey)
    if classToken and spec and ns.GetIcyVeinsSpecData then
        local ivData = ns:GetIcyVeinsSpecData(classToken, spec)
        if ivData then return ivData.sourceUrl end
    end
    return "https://www.icy-veins.com"
end)

local aboutArchonBtn = CreateAboutButton("|TInterface\\AddOns\\ClassCodex\\Textures\\archon:12:12:0:0|t  Archon (Per-Encounter Builds) Data")
SetCopyOnClick(aboutArchonBtn, function()
    -- Prefer the player's current spec's M+ overview page; fall back
    -- to the site root when we can't resolve a spec.
    local classToken = select(2, UnitClass("player"))
    local specKey = ns.GetSpecKey and ns.GetSpecKey() or nil
    local spec = specKey and (specKey:match("-(.+)") or specKey)
    if classToken and spec and ns.GetArchonSpecData then
        local archon = ns.GetArchonSpecData(classToken, spec)
        if archon and archon.contexts then
            local overview = archon.contexts["mythic-plus:high-keys:all-dungeons"]
                or archon.contexts["raid:heroic:all-bosses"]
            if overview and overview.sourceUrl then return overview.sourceUrl end
        end
    end
    return "https://www.archon.gg/wow"
end)

-------------------------------------------------------------------------------
-- Section Collapse
-------------------------------------------------------------------------------

statHeader:SetScript("OnClick", function()
    statSectionCollapsed = not statSectionCollapsed
    SetCollapsed(statContent, statHeader, statSectionCollapsed)
    if ClassCodexCharDB and ClassCodexCharDB.collapsed then
        ClassCodexCharDB.collapsed.stats = statSectionCollapsed
    end
    ns:LayoutPanel()
end)
talentHeader:SetScript("OnClick", function()
    talentSectionCollapsed = not talentSectionCollapsed
    SetCollapsed(talentContent, talentHeader, talentSectionCollapsed)
    if ClassCodexCharDB and ClassCodexCharDB.collapsed then
        ClassCodexCharDB.collapsed.talents = talentSectionCollapsed
    end
    ns:LayoutPanel()
end)
rotationHeader:SetScript("OnClick", function()
    rotationSectionCollapsed = not rotationSectionCollapsed
    SetCollapsed(rotationContent, rotationHeader, rotationSectionCollapsed)
    if ClassCodexCharDB and ClassCodexCharDB.collapsed then
        ClassCodexCharDB.collapsed.rotation = rotationSectionCollapsed
    end
    ns:LayoutPanel()
end)
-------------------------------------------------------------------------------
-- Stat Targets renderer
--
-- Pulls the empirical targets from ClassCodexArchonStats (loaded from
-- per-class archon-stats.lua) for the (class, spec, context) tuple, then
-- compares them against the live player ratings. Returns the count of
-- visible rows so LayoutPanel can size the section correctly.
-------------------------------------------------------------------------------

-- Stable rendering order: highest target first, but anchored by the canonical
-- secondary stats so the layout doesn't reorder while gear is being swapped.
local STAT_TARGETS_DISPLAY_ORDER = { "mastery", "haste", "crit", "versatility" }

-- Update the Stats-tab title-row info icon with the active snapshot's
-- Archon source URL. Hides the icon when there's no snapshot (no data →
-- no source to show).
local function UpdateStatTargetsInfoIcon(snapshot)
    statTargetsInfoBtn.url = snapshot and snapshot.sourceUrl or nil
end

local function RenderStatTargets(classToken, specKey)
    statTargets.combatFallback:Hide()
    if not classToken or not specKey then
        for i = 1, STAT_TARGETS_MAX_ROWS do statTargets.rows[i]:Hide() end
        UpdateStatTargetsInfoIcon(nil)
        return 0
    end

    -- Build the list of contexts. Mythic+ / Raid only show when Archon
    -- has data; PvP is ALWAYS surfaced so users can discover the feature
    -- — when Murlok has no priority for this spec the dropdown still
    -- offers PvP and we render a "no data" line inside instead of bars.
    local availableContexts = {}
    for _, ctx in ipairs({ "Mythic+", "Raid" }) do
        if ns.GetStatTargets(classToken, specKey, ctx) then
            availableContexts[#availableContexts + 1] = ctx
        end
    end
    local pvpTargets = ns.GetPvPStatTargets and ns.GetPvPStatTargets(classToken, specKey) or nil
    availableContexts[#availableContexts + 1] = "PvP"

    -- If Mythic+ / Raid ALSO have no data and Murlok has none, the
    -- whole side tab is empty — hide it instead of showing a lone
    -- PvP-no-data line for a spec we know nothing about.
    if #availableContexts == 1 and not pvpTargets then
        statTargets.ctxDropdown:Hide()
        statTargets.pvpFallback:Hide()
        for i = 1, STAT_TARGETS_MAX_ROWS do statTargets.rows[i]:Hide() end
        UpdateStatTargetsInfoIcon(nil)
        return 0
    end

    -- Resolve "still has data?" for the persisted context. Mythic+ /
    -- Raid bail upstream if missing; PvP-with-no-data routes to the
    -- fallback branch below.
    local function resolveCtx(ctx)
        if ctx == "PvP" then return pvpTargets end
        return ns.GetStatTargets(classToken, specKey, ctx)
    end

    -- Mythic+ / Raid coverage check excludes PvP — the fallback branch
    -- below handles that case explicitly. Without this, PvP-only specs
    -- (where Mythic+/Raid both miss) would skip the persisted-context
    -- correction and possibly land on a stale Mythic+ value.
    local hasNonPvpCtx = false
    for _, ctx in ipairs(availableContexts) do
        if ctx ~= "PvP" then hasNonPvpCtx = true; break end
    end
    if not statTargets.currentCtx or
        (statTargets.currentCtx ~= "PvP" and not resolveCtx(statTargets.currentCtx)) then
        statTargets.currentCtx = hasNonPvpCtx and availableContexts[1] or "PvP"
    end

    if #availableContexts > 1 then
        statTargets.ctxDropdown:Show()
        statTargets.ctxDropdown:SetOptions(availableContexts, statTargets.currentCtx, function(selected)
            statTargets.currentCtx = selected
            ns:UpdatePanel()
        end)
    else
        statTargets.ctxDropdown:Hide()
    end

    -- PvP-no-data branch: dropdown stays visible, bars hide, fallback
    -- line shows. Returns a row count of 1 so LayoutPanel reserves
    -- vertical space for the fallback line.
    if statTargets.currentCtx == "PvP" and not pvpTargets then
        for i = 1, STAT_TARGETS_MAX_ROWS do statTargets.rows[i]:Hide() end
        UpdateStatTargetsInfoIcon(nil)
        local yOffset = (#availableContexts > 1) and -28 or -4
        statTargets.pvpFallback:SetText(L["pvp.no_stat_targets"]
            or "No PvP stat targets for this spec yet.")
        statTargets.pvpFallback:ClearAllPoints()
        statTargets.pvpFallback:SetPoint("TOPLEFT", statTargets.content, "TOPLEFT", 4, yOffset)
        statTargets.pvpFallback:SetPoint("RIGHT", statTargets.content, "RIGHT", -4, 0)
        statTargets.pvpFallback:Show()
        return 1
    end
    statTargets.pvpFallback:Hide()

    local snapshot = resolveCtx(statTargets.currentCtx)
    if not snapshot or not snapshot.targets then
        for i = 1, STAT_TARGETS_MAX_ROWS do statTargets.rows[i]:Hide() end
        UpdateStatTargetsInfoIcon(nil)
        return 0
    end

    -- In combat, GetCombatRating / GetCombatRatingBonus return Blizzard
    -- "secret" values to tainted code — they pass type() but error on
    -- arithmetic. Skip rendering the bars and surface a placeholder;
    -- PLAYER_REGEN_ENABLED triggers a full re-render once combat ends.
    if InCombatLockdown() then
        for i = 1, STAT_TARGETS_MAX_ROWS do statTargets.rows[i]:Hide() end
        UpdateStatTargetsInfoIcon(snapshot)
        local yOffset = (#availableContexts > 1) and -28 or -4
        statTargets.combatFallback:SetText(
            L["stat_targets.combat_warning"]
            or "Stat targets can't be computed in combat — values update after combat ends.")
        statTargets.combatFallback:ClearAllPoints()
        statTargets.combatFallback:SetPoint("TOPLEFT", statTargets.content, "TOPLEFT", 4, yOffset)
        statTargets.combatFallback:SetPoint("RIGHT", statTargets.content, "RIGHT", -4, 0)
        statTargets.combatFallback:Show()
        return 1
    end

    UpdateStatTargetsInfoIcon(snapshot)

    local yOffset = (#availableContexts > 1) and -28 or -4
    local visibleCount = 0

    for _, statKey in ipairs(STAT_TARGETS_DISPLAY_ORDER) do
        local target = snapshot.targets[statKey]
        if target and target > 0 then
            visibleCount = visibleCount + 1
            local row = statTargets.rows[visibleCount]
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", statTargets.content, "TOPLEFT", 0, yOffset)
            row:SetPoint("TOPRIGHT", statTargets.content, "TOPRIGHT", 0, yOffset)
            row:Show()
            yOffset = yOffset - STAT_TARGET_ROW_HEIGHT - STAT_TARGET_ROW_GAP

            local current = ns.GetPlayerStatRating(statKey)
            local livePct = ns.GetPlayerStatPercent(statKey)
            row.statName:SetText(ns.STAT_LABELS[statKey] or statKey)

            -- Status: position vs. Archon target (above / at / below).
            local kind = ns.ClassifyStatDelta(current, target) or "below"
            local status = STAT_STATUS_ICONS[kind]
            row.statusIcon:SetTexture(status.texture)
            row.statusIcon:SetTexCoord(status.texCoord[1], status.texCoord[2], status.texCoord[3], status.texCoord[4])
            row.statusIcon:SetVertexColor(status.r, status.g, status.b)

            -- Readout: live percent + current/target rating, so the gap
            -- to target is readable as raw numbers in addition to the
            -- bar's visual position vs the tick mark.
            row.rating:SetText(string.format("%.1f%%  |cff9a9a9a%d / %d|r", livePct, current, target))

            -- Diminishing returns: True Stat Value style. The DR formula
            -- buckets stats by post-DR percentage — once you cross a
            -- bracket the next rating point gives less than its linear
            -- value. Tint the readout by remaining effectiveness so users
            -- can spot at a glance whether stacking more is still worth it.
            local marginal = ns.GetMarginalDR and ns.GetMarginalDR(livePct) or 1
            if marginal >= 1 then
                row.rating:SetTextColor(0.85, 0.85, 0.85)              -- white-ish (no DR yet)
            elseif marginal >= 0.8 then
                row.rating:SetTextColor(1, 0.85, 0.4)                  -- yellow (light DR)
            elseif marginal >= 0.6 then
                row.rating:SetTextColor(1, 0.65, 0.1)                  -- amber (moderate)
            else
                row.rating:SetTextColor(1, 0.4, 0.2)                   -- deep orange (heavy)
            end

            -- Hover tooltip: full TSV-style breakdown via the shared
            -- builder. Stash statKey + snapshot so the OnEnter handler
            -- (set once at row creation) can rebuild on demand.
            row:EnableMouse(true)
            row.statKey = statKey
            row.snapshot = snapshot
            if not row._statTooltipBound then
                row:SetScript("OnEnter", function(self)
                    if not self.statKey then return end
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    if ns.AppendStatExtrasToTooltip then
                        ns.AppendStatExtrasToTooltip(GameTooltip, self.statKey, self.snapshot, { includeTitle = true })
                    end
                    GameTooltip:Show()
                end)
                row:SetScript("OnLeave", function() GameTooltip:Hide() end)
                row._statTooltipBound = true
            end

            -- Map current/target to the 0..MAX_RATIO bar scale so above-
            -- target overshoot is visible past the tick.
            local rawRatio = current / target
            local progress = math.min(rawRatio, STAT_TARGET_BAR_MAX_RATIO) / STAT_TARGET_BAR_MAX_RATIO
            row.bar.progress = progress
            local barW = row.bar:GetWidth()
            local inner = math.max(0, barW - 4)
            row.bar.fill:SetWidth(math.max(progress > 0 and 2 or 0, math.min(progress * inner, inner)))

            -- Reposition the target tick for the current width — the
            -- OnSizeChanged handler covers resizes but the first draw can
            -- happen before the layout pass fires that event.
            if row.bar.tick then
                local tickX = 2 + math.floor((1 / STAT_TARGET_BAR_MAX_RATIO) * inner + 0.5)
                row.bar.tick:ClearAllPoints()
                row.bar.tick:SetPoint("TOP", row.bar, "TOPLEFT", tickX, -2)
                row.bar.tick:SetPoint("BOTTOM", row.bar, "BOTTOMLEFT", tickX, 2)
            end

            local barColor = STAT_BAR_COLORS[kind]
            row.bar.fill:SetVertexColor(barColor[1], barColor[2], barColor[3], 1)
        end
    end

    for i = visibleCount + 1, STAT_TARGETS_MAX_ROWS do statTargets.rows[i]:Hide() end

    return visibleCount
end

-------------------------------------------------------------------------------
-- Collapse state restore (extracted to avoid upvalue pressure on UpdatePanel)
-------------------------------------------------------------------------------

local function RestoreCollapseState()
    local saved = ClassCodexCharDB and ClassCodexCharDB.collapsed
    if saved then
        statSectionCollapsed = saved.stats or false
        talentSectionCollapsed = saved.talents or false
        rotationSectionCollapsed = saved.rotation or false
        SetCollapsed(statContent, statHeader, statSectionCollapsed)
        SetCollapsed(talentContent, talentHeader, talentSectionCollapsed)
        SetCollapsed(rotationContent, rotationHeader, rotationSectionCollapsed)
    end
end

-------------------------------------------------------------------------------
-- Expose shared utilities for GearingSections.lua
-------------------------------------------------------------------------------

ns.CreateSectionHeader = CreateSectionHeader
ns.SetCollapsed = SetCollapsed
ns.contentFrame = contentFrame
ns.panel = panel
ns.CreateOptionDropdown = CreateOptionDropdown
ns.GetPanelWidth = GetPanelWidth
ns.GetClassAndSpec = GetClassAndSpec
ns.GetSpecKey = GetSpecKey
ns.GetSpecData = GetSpecData
ns.GetPerSpecState = GetPerSpecState
ns.GetActiveHeroTalentName = GetActiveHeroTalentName
ns.CONTENT_INSET = CONTENT_INSET
ns.ROW_HEIGHT = ROW_HEIGHT
ns.SECTION_HEADER_HEIGHT = SECTION_HEADER_HEIGHT
ns.PANEL_PADDING = PANEL_PADDING
ns.isFloating = function() return isFloating end
ns.getActiveTab = function() return activeTab end
ns.setActiveTab = function(tab) activeTab = tab; UpdateTabAppearance() end
ns.HERO_TALENT_ATLAS = HERO_TALENT_ATLAS
ns.SPEC_KEYS = SPEC_KEYS

-------------------------------------------------------------------------------
-- Main Update
-------------------------------------------------------------------------------

local currentHeroTalent = nil

function ns:UpdatePanel()
    cachedRanks = nil -- invalidate stat rank cache on hero/context change
    local specData, classToken, specKey = GetSpecData()
    if not specData then panel:Hide(); return end

    RestoreCollapseState()

    local panelWidth = GetPanelWidth()
    panel:SetWidth(panelWidth)

    -- Spec icon
    local icon = GetSpecIcon()
    if icon then specIcon:SetTexture(icon); specIcon:Show() else specIcon:Hide() end

    -- Hero talent
    local heroOptions = GetHeroTalentOptions(specData)
    local showHero = #heroOptions > 1
    local perSpec = GetPerSpecState()

    if perSpec and perSpec.heroTalent then
        currentHeroTalent = perSpec.heroTalent
    else
        local detected = GetActiveHeroTalentName()
        if detected then
            local matched = false
            for _, opt in ipairs(heroOptions) do
                if opt:lower() == detected:lower() then
                    currentHeroTalent = opt
                    matched = true
                    break
                end
            end
            if not matched then currentHeroTalent = heroOptions[1] or "All" end
        else
            currentHeroTalent = heroOptions[1] or "All"
        end
    end

    -- Subheader (hero dropdown only)
    LayoutSubheader(showHero)
    if not showHero then
        subheaderFrame:SetHeight(1)
    else
        subheaderFrame:SetHeight(SUBHEADER_HEIGHT)
    end
    if showHero then
        -- Wrap each hero option with its atlas icon so the closed-state
        -- and the menu both show the icon inline (replaces the old
        -- heroIcon texture child that the WowStyle1Dropdown can't host).
        local heroOpts = {}
        for _, hero in ipairs(heroOptions) do
            local atlas = HERO_TALENT_ATLAS[hero]
            local label = atlas and ("|A:" .. atlas .. ":14:14|a  " .. hero) or hero
            heroOpts[#heroOpts + 1] = { label = label, value = hero }
        end
        heroDropdown:SetOptions(heroOpts, currentHeroTalent, function(selected)
            local perSpec = GetPerSpecState()
            if not perSpec then return end
            perSpec.heroTalent = selected
            ns:UpdatePanel()
        end)
    end

    -- Stats (with optional inline context dropdown)
    local statCtxOptions = GetStatContextOptions(specData, currentHeroTalent)
    local showStatCtx = #statCtxOptions > 0

    if showStatCtx then
        -- Restore saved stat context or default to first
        if perSpec and perSpec.statContext then
            local found = false
            for _, c in ipairs(statCtxOptions) do
                if c == perSpec.statContext then found = true; break end
            end
            currentStatContext = found and perSpec.statContext or statCtxOptions[1]
        else
            currentStatContext = statCtxOptions[1]
        end
        statCtxDropdown:Show()
        statCtxDropdown:SetOptions(statCtxOptions, currentStatContext, function(selected)
            local perSpec = GetPerSpecState()
            if not perSpec then return end
            perSpec.statContext = selected
            ns:UpdatePanel()
        end)
    else
        statCtxDropdown:Hide()
        currentStatContext = nil
    end

    local statLookupCtx = currentStatContext or "General"
    local priority = FindMatch(specData.priorities, currentHeroTalent, statLookupCtx)
    if priority then
        local yOffset = showStatCtx and -30 or 0
        for i = 1, MAX_STATS do statFrames[i]:Hide() end
        for i = 1, math.min(#priority.stats, MAX_STATS) do
            local row = statFrames[i]
            local color = RANK_COLORS[i]
            row.rank:SetTextColor(color and color.r or 0.6, color and color.g or 0.6, color and color.b or 0.6)
            row.rank:SetText(i .. ".")
            local names = {}
            for _, stat in ipairs(priority.stats[i]) do
                names[#names + 1] = stat
            end
            row.statName:SetTextColor(#priority.stats[i] > 1 and 0.8 or 1, #priority.stats[i] > 1 and 0.8 or 1, #priority.stats[i] > 1 and 0.6 or 1)
            row.statName:SetText(table.concat(names, " / "))
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", 0, yOffset - (i - 1) * ROW_HEIGHT)
            row:SetPoint("RIGHT", 0, 0)
            row:Show()
        end
        statSection:Show()
    else
        statSection:Hide()
    end

    -- Talents (show all builds for selected hero as rows)
    for i = 1, MAX_TALENT_BUTTONS do talentButtons[i]:Hide() end
    talentFallback:Hide()

    if not specData.talents or #specData.talents == 0 then
        talentFallbackText:SetText(L["empty.no_builds_details"])
        talentFallback:ClearAllPoints()
        talentFallback:SetPoint("TOPLEFT", talentContent, "TOPLEFT", 0, 0)
        talentFallback:SetPoint("RIGHT", talentContent, "RIGHT", 0, 0)
        talentFallback:Show()
        talentSection:Show()
    else
        local talentBuilds = GetAllTalentBuildsForHero(specData, currentHeroTalent)

        if #talentBuilds > 0 then
            local activeTalentData = ns.GetActiveTalentSignature()

            local count = math.min(#talentBuilds, MAX_TALENT_BUTTONS)
            for i = 1, count do
                local t = talentBuilds[i]
                local btn = talentButtons[i]

                local label = ns.FormatBuildLabel(t)

                -- Highlight active build (compare talent data, skip tree hash)
                local isActive = activeTalentData and ns.ExtractTalentBits(t.exportString) == activeTalentData
                btn.isActive = isActive
                if isActive then
                    btn:SetBackdropBorderColor(0.2, 0.8, 0.2, 1)
                    btn.label:SetTextColor(0.3, 1, 0.3)
                else
                    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
                    btn.label:SetTextColor(0.8, 0.8, 0.8)
                end
                btn.label:SetText(label)

                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", talentContent, "TOPLEFT", 0, -((i - 1) * (TALENT_BTN_HEIGHT + TALENT_BTN_GAP)))
                btn:SetPoint("RIGHT", talentContent, "RIGHT", 0, 0)
                btn.copyBtn:SetScript("OnClick", function()
                    ShowCopyPopup(t.exportString, btn)
                end)
                btn.applyBtn:SetScript("OnClick", function(self)
                    -- Build loadout name from raw fields (no color codes)
                    local rawLabel = t.context or "Build"
                    if t.buildLabel and t.buildLabel ~= "" then
                        rawLabel = rawLabel .. " — " .. t.buildLabel
                    end
                    local loadoutLabel = currentHeroTalent and currentHeroTalent ~= "All"
                        and (currentHeroTalent .. " " .. rawLabel) or rawLabel
                    local ok, err = ns.ApplyTalentExportString(t.exportString, loadoutLabel)
                    if not ok then
                        -- Pre-flight error (wrong spec, in combat, etc.)
                        self.icon:SetVertexColor(1, 0.2, 0.2)
                        print("|cff00ccffClass Codex:|r " .. (err or "Failed to apply talents"))
                        C_Timer.After(1.5, function()
                            if self.icon then
                                self.icon:SetDesaturated(true)
                                self.icon:SetVertexColor(0.7, 0.7, 0.7)
                            end
                        end)
                    else
                        -- Staging succeeded, commit runs on next frame
                        self.icon:SetVertexColor(1, 0.8, 0)
                        C_Timer.After(1.5, function()
                            if self.icon then
                                self.icon:SetDesaturated(true)
                                self.icon:SetVertexColor(0.7, 0.7, 0.7)
                            end
                        end)
                    end
                end)
                btn:Show()
            end
            talentSection:Show()
        else
            talentFallbackText:SetText(L["empty.no_builds_for"]:format(currentHeroTalent))
            talentFallback:ClearAllPoints()
            talentFallback:SetPoint("TOPLEFT", talentContent, "TOPLEFT", 0, 0)
            talentFallback:SetPoint("RIGHT", talentContent, "RIGHT", 0, 0)
            talentFallback:Show()
            talentSection:Show()
        end
    end

    -- Rotation
    local rotCtxOptions = GetRotationContextOptions(specData, currentHeroTalent)
    local showRotCtx = #rotCtxOptions > 1

    -- Restore saved rotation context or default to first option
    local perSpecRot = GetPerSpecState()
    if perSpecRot and perSpecRot.rotationContext then
        local found = false
        for _, c in ipairs(rotCtxOptions) do
            if c == perSpecRot.rotationContext then found = true; break end
        end
        currentRotationContext = found and perSpecRot.rotationContext or (rotCtxOptions[1] or "General")
    else
        currentRotationContext = rotCtxOptions[1] or "General"
    end

    if showRotCtx then
        rotCtxDropdown:Show()
        rotCtxDropdown:SetOptions(rotCtxOptions, currentRotationContext, function(selected)
            local perSpec = GetPerSpecState()
            if not perSpec then return end
            perSpec.rotationContext = selected
            ns:UpdatePanel()
        end)
    elseif #rotCtxOptions == 1 then
        rotCtxDropdown:Hide()
        currentRotationContext = rotCtxOptions[1]
    else
        rotCtxDropdown:Hide()
    end

    local rotation = FindRotationByContext(specData.rotation, currentHeroTalent, currentRotationContext)

    for i = 1, MAX_ROTATION_STEPS do rotationFrames[i]:Hide() end
    rotationFallback:Hide()
    lastRotationContentHeight = 0

    if rotation then
        local yOffset = showRotCtx and -30 or 0
        local textAreaWidth = GetPanelWidth() - CONTENT_INSET * 2 - 42 -- 42 = rank(18) + gaps(8) + icon(16)
        local visibleStep = 0
        local currentY = yOffset
        for _, step in ipairs(rotation.steps) do
            if ShouldShowStep(step, currentHeroTalent) then
                visibleStep = visibleStep + 1
                if visibleStep > MAX_ROTATION_STEPS then break end
                local row = rotationFrames[visibleStep]
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", rotationContent, "TOPLEFT", 0, currentY)
                row:SetPoint("RIGHT", rotationContent, "RIGHT", 0, 0)
                row.rank:SetText(visibleStep .. ".")
                row.icon:SetTexture(GetStepSpellIcon(step))
                local cleanStep = StripConditionPrefix(step)
                row.stepText:SetText(FormatRotationStep(cleanStep))
                row.spellId = tonumber(cleanStep:match("{(%d+)}"))
                row.stepText:SetWidth(textAreaWidth)
                local textHeight = row.stepText:GetStringHeight() or 12
                local rowHeight = math.max(ROW_HEIGHT, textHeight + 6)
                row:SetHeight(rowHeight)
                row:Show()
                currentY = currentY - rowHeight
            end
        end
        lastRotationContentHeight = math.abs(currentY - yOffset)
        rotationSection:Show()
    elseif specData.rotation and #specData.rotation > 0 then
        local yOffset = showRotCtx and -30 or 0
        rotationFallbackText:SetText(L["empty.no_rotation_for_details"]:format(currentHeroTalent))
        rotationFallback:ClearAllPoints()
        rotationFallback:SetPoint("TOPLEFT", rotationContent, "TOPLEFT", 0, yOffset)
        rotationFallback:SetPoint("RIGHT", rotationContent, "RIGHT", 0, 0)
        rotationFallback:Show()
        lastRotationContentHeight = ROW_HEIGHT
        rotationSection:Show()
    else
        rotationSection:Hide()
    end

    -- Talents tab: grouped-by-context layout showing all builds
    if activeTab == "talents" then
        ns:UpdateAllTalents(specData, classToken, specKey)
    else
        allTalentContent:Hide()
    end

    -- Gearing sections
    if ns.UpdateGearingSections then ns:UpdateGearingSections() end

    -- Tab visibility:
    --   guide → priority list + talents + rotation
    --   stats → just the live target bars
    --   other → everything hidden
    if activeTab == "guide" then
        subheaderFrame:Show()
        statTargets.section:Hide()
    elseif activeTab == "stats" then
        statSection:Hide() -- priority list lives on Guide; no duplication here
        talentSection:Hide()
        rotationSection:Hide()
        subheaderFrame:SetHeight(1)
        subheaderFrame:Hide()
        local statRowCount = RenderStatTargets(classToken, specKey)
        if statRowCount > 0 then
            statTargets.section:Show()
        else
            statTargets.section:Hide()
        end
    else
        statSection:Hide()
        statTargets.section:Hide()
        talentSection:Hide()
        rotationSection:Hide()
        subheaderFrame:SetHeight(1)
        subheaderFrame:Hide()
    end
    -- GearingSections.lua handles its own tab visibility via ns.getActiveTab()

    -- Hide sections disabled for current mode + hide empty tabs
    if ClassCodexDB then
        local prefix = isFloating and "floatShow" or "dockShow"
        if activeTab == "guide" then
            if not ClassCodexDB[prefix .. "Stats"] then statSection:Hide() end
            if not ClassCodexDB[prefix .. "Talents"] then talentSection:Hide() end
            if not ClassCodexDB[prefix .. "Rotation"] then rotationSection:Hide() end
        elseif activeTab == "stats" then
            if not ClassCodexDB[prefix .. "StatTargets"] then statTargets.section:Hide() end
        elseif activeTab == "talents" then
            if not ClassCodexDB[prefix .. "Talents"] then allTalentContent:Hide() end
        end
        activeTab = ns:UpdateSideTabVisibility(prefix, activeTab)
    end

    ns:LayoutPanel()
end

-------------------------------------------------------------------------------
-- Layout
-------------------------------------------------------------------------------

function ns:LayoutPanel()
    local y = 0

    -- Tab title
    local titleLabel = TAB_TITLE_LABELS[activeTab]
    if titleLabel then
        tabTitleText:SetText(titleLabel)
        tabTitle:Show()
        tabTitle:ClearAllPoints()
        tabTitle:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        tabTitle:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        statInfoBtn:SetShown(activeTab == "guide")
        statTargetsInfoBtn:SetShown(activeTab == "stats" and statTargetsInfoBtn.url ~= nil)
        y = y - SECTION_HEADER_HEIGHT
    else
        tabTitle:Hide()
    end

    -- Subheader (only shown on guide tab). No leading gap so the
    -- dropdowns sit flush against the tab title — matches the Stats tab
    -- where the context dropdown is immediately below the title.
    subheaderFrame:ClearAllPoints()
    if subheaderFrame:IsShown() then
        subheaderFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        subheaderFrame:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        y = y - SUBHEADER_HEIGHT - 2
    end

    -- Helper to layout a section
    local function LayoutSection(section, collapsed, contentHeight)
        if not section:IsShown() then return end
        section:ClearAllPoints()
        section:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        section:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        local sectionHeight = SECTION_HEADER_HEIGHT
        if not collapsed then
            sectionHeight = sectionHeight + contentHeight + 4
        end
        section:SetHeight(sectionHeight)
        y = y - sectionHeight - 3
    end

    -- Stat section: count visible rows + optional dropdown
    local statContentHeight = 0
    if statSection:IsShown() and not statSectionCollapsed then
        if statCtxDropdown:IsShown() then
            statContentHeight = statContentHeight + 30
        end
        local n = 0
        for i = 1, MAX_STATS do if statFrames[i]:IsShown() then n = n + 1 end end
        statContentHeight = statContentHeight + n * ROW_HEIGHT
    end
    LayoutSection(statSection, statSectionCollapsed, statContentHeight)

    -- Stat targets section: no inner header, anchored directly under the
    -- tab title. Height is exactly the visible rows + optional context
    -- dropdown.
    if statTargets.section:IsShown() then
        local h = 0
        if statTargets.ctxDropdown:IsShown() then
            h = h + 28
        end
        local n = 0
        for i = 1, STAT_TARGETS_MAX_ROWS do
            if statTargets.rows[i]:IsShown() then n = n + 1 end
        end
        if n > 0 then
            h = h + n * STAT_TARGET_ROW_HEIGHT + (n - 1) * STAT_TARGET_ROW_GAP + 4
        elseif statTargets.pvpFallback:IsShown() then
            -- "No PvP stat targets..." line replaces the row stack; one
            -- text line + a small bottom margin.
            h = h + 24
        end
        statTargets.section:ClearAllPoints()
        statTargets.section:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        statTargets.section:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        statTargets.section:SetHeight(h)
        y = y - h - 3
    end

    -- Talent section
    local talentContentHeight = 0
    if talentSection:IsShown() and not talentSectionCollapsed then
        if talentFallback:IsShown() then
            talentContentHeight = 20
        else
            local count = 0
            for i = 1, MAX_TALENT_BUTTONS do
                if talentButtons[i]:IsShown() then count = count + 1 end
            end
            if count > 0 then
                talentContentHeight = count * TALENT_BTN_HEIGHT + (count - 1) * TALENT_BTN_GAP
            end
        end
    end
    LayoutSection(talentSection, talentSectionCollapsed, talentContentHeight)

    -- Rotation section
    local rotationContentHeight = 0
    if rotationSection:IsShown() and not rotationSectionCollapsed then
        if rotCtxDropdown:IsShown() then
            rotationContentHeight = rotationContentHeight + 30
        end
        rotationContentHeight = rotationContentHeight + lastRotationContentHeight
    end
    LayoutSection(rotationSection, rotationSectionCollapsed, rotationContentHeight)

    -- Talents tab: all-builds grouped content
    if allTalentContent:IsShown() then
        allTalentContent:ClearAllPoints()
        allTalentContent:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        allTalentContent:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        y = y - allTalentContent:GetHeight() - 8
    end

    -- Gearing sections layout
    if ns.LayoutGearingSections then
        y = ns:LayoutGearingSections(y)
    end

    -- Supporters tab
    if activeTab == "supporters" then
        supporters.title:Show()
        supporters.title:ClearAllPoints()
        supporters.title:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        supporters.title:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        y = y - SECTION_HEADER_HEIGHT

        supporters.content:Show()
        supporters.content:ClearAllPoints()
        supporters.content:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        supporters.content:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        local lastBottom = supporters.lastChild and supporters.lastChild:GetBottom()
        local contentTop = supporters.content:GetTop()
        local contentH = (lastBottom and lastBottom > 0 and contentTop and contentTop > 0)
            and (contentTop - lastBottom)
            or 80
        supporters.content:SetHeight(contentH)
        y = y - contentH - 16

        supporters.patreonBtn:ClearAllPoints()
        supporters.patreonBtn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        supporters.patreonBtn:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        supporters.patreonBtn:Show()
        y = y - 28
    else
        supporters.title:Hide()
        supporters.content:Hide()
        supporters.patreonBtn:Hide()
    end

    -- About tab title + content + buttons
    if activeTab == "about" then
        aboutTabTitle:Show()
        aboutTabTitle:ClearAllPoints()
        aboutTabTitle:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        aboutTabTitle:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        y = y - SECTION_HEADER_HEIGHT

        aboutContent:Show()
        aboutContent:ClearAllPoints()
        aboutContent:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        aboutContent:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        -- Dynamically size aboutContent based on last child
        local contentH = aboutSlash:GetBottom() and (aboutContent:GetTop() - aboutSlash:GetBottom()) or 200
        aboutContent:SetHeight(contentH)
        y = y - contentH - 34

        local function LayoutSeparator(sep)
            y = y - 4
            sep:ClearAllPoints()
            sep:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
            sep:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
            sep:Show()
            y = y - 7
        end

        if not aboutSepTop then
            aboutSepTop = contentFrame:CreateTexture(nil, "ARTWORK")
            aboutSepTop:SetHeight(1)
            aboutSepTop:SetColorTexture(0.3, 0.3, 0.3, 0.6)
        end
        LayoutSeparator(aboutSepTop)

        aboutCompendiumBtn:ClearAllPoints()
        aboutCompendiumBtn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        aboutCompendiumBtn:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        aboutCompendiumBtn:Show()
        y = y - 28

        aboutSettingsBtn:ClearAllPoints()
        aboutSettingsBtn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        aboutSettingsBtn:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        aboutSettingsBtn:Show()
        y = y - 28

        if not aboutSepBottom then
            aboutSepBottom = contentFrame:CreateTexture(nil, "ARTWORK")
            aboutSepBottom:SetHeight(1)
            aboutSepBottom:SetColorTexture(0.3, 0.3, 0.3, 0.6)
        end
        LayoutSeparator(aboutSepBottom)

        aboutDataBtn:ClearAllPoints()
        aboutDataBtn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        aboutDataBtn:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        aboutDataBtn:Show()
        y = y - 28

        aboutIcyVeinsBtn:ClearAllPoints()
        aboutIcyVeinsBtn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        aboutIcyVeinsBtn:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        aboutIcyVeinsBtn:Show()
        y = y - 28

        aboutArchonBtn:ClearAllPoints()
        aboutArchonBtn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        aboutArchonBtn:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        aboutArchonBtn:Show()
        y = y - 28

        if not aboutSepSocial then
            aboutSepSocial = contentFrame:CreateTexture(nil, "ARTWORK")
            aboutSepSocial:SetHeight(1)
            aboutSepSocial:SetColorTexture(0.3, 0.3, 0.3, 0.6)
        end
        LayoutSeparator(aboutSepSocial)

        aboutPatreonBtn:ClearAllPoints()
        aboutPatreonBtn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        aboutPatreonBtn:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        aboutPatreonBtn:Show()
        y = y - 28

        aboutDiscordBtn:ClearAllPoints()
        aboutDiscordBtn:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", CONTENT_INSET, y)
        aboutDiscordBtn:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET, 0)
        aboutDiscordBtn:Show()
        y = y - 28
    else
        aboutTabTitle:Hide()
        aboutContent:Hide()
        aboutDiscordBtn:Hide()
        aboutPatreonBtn:Hide()
        aboutDataBtn:Hide()
        aboutIcyVeinsBtn:Hide()
        aboutArchonBtn:Hide()
        if aboutSepTop then aboutSepTop:Hide() end
        if aboutSepBottom then aboutSepBottom:Hide() end
        if aboutSepSocial then aboutSepSocial:Hide() end
        aboutCompendiumBtn:Hide()
        aboutSettingsBtn:Hide()
    end

    -- Calculate minimum panel height
    local contentBottom = math.abs(y)
    local footerHeight = 24 + 3 -- separator + footer
    local panelOverhead = 24 + 2 + PANEL_PADDING + 2

    -- Minimum height: enough for all side + bottom tabs to be visible
    -- Side tabs are now a single top-anchored stack (top tabs → section gap → bottom tabs).
    local SIDE_TAB_SECTION_GAP = 12
    local tabMinHeight = 40 + #sideTabs * (SIDE_TAB_H + SIDE_TAB_GAP) + SIDE_TAB_SECTION_GAP + #bottomTabs * (SIDE_TAB_H + SIDE_TAB_GAP) + 10
    local minPanelHeight = tabMinHeight
    -- When docked, also match CharacterFrame height
    if not isFloating and CharacterFrame and CharacterFrame:IsShown() then
        local charHeight = CharacterFrame:GetHeight()
        if charHeight and charHeight > minPanelHeight then minPanelHeight = charHeight end
    end

    local naturalHeight = contentBottom + footerHeight + panelOverhead
    local panelHeight = math.max(naturalHeight, minPanelHeight)
    local contentHeight = panelHeight - panelOverhead

    if isMinimized then
        contentFrame:Hide()
        panel:SetHeight(36)
        for _, tab in ipairs(allTabs) do tab:Hide() end
    else
        -- Show all tabs first, then re-apply mode visibility and re-layout.
        for _, tab in ipairs(bottomTabs) do tab:Show() end
        for _, tab in ipairs(sideTabs) do tab:Show() end
        if ClassCodexDB then
            local prefix = isFloating and "floatShow" or "dockShow"
            activeTab = ns:UpdateSideTabVisibility(prefix, activeTab)
        end
        -- Re-layout visible side tabs to remove gaps
        local prevTab = nil
        for _, tab in ipairs(sideTabs) do
            if tab:IsShown() then
                tab:ClearAllPoints()
                if prevTab then
                    tab:SetPoint("TOPLEFT", prevTab, "BOTTOMLEFT", 0, -SIDE_TAB_GAP)
                else
                    tab:SetPoint("TOPLEFT", panel, "TOPRIGHT", -1, -40)
                end
                prevTab = tab
            end
        end
        -- Bottom side tabs (About, Supporters):
        --   Floating: anchor to the last top tab so they don't drift down when the
        --             panel expands to fit tall content.
        --   Docked:   anchor to panel bottom (CharacterFrame is fixed-height, so they
        --             sit near the end of the frame as expected).
        if isFloating then
            local gap = SIDE_TAB_SECTION_GAP
            for _, tab in ipairs(bottomTabs) do
                tab:ClearAllPoints()
                if prevTab then
                    tab:SetPoint("TOPLEFT", prevTab, "BOTTOMLEFT", 0, -gap)
                else
                    tab:SetPoint("TOPLEFT", panel, "TOPRIGHT", -1, -40)
                end
                prevTab = tab
                gap = SIDE_TAB_GAP
            end
        else
            -- bottomTabs order is [supporters.tab, aboutTab]; About sits at the bottom
            aboutTab:ClearAllPoints()
            aboutTab:SetPoint("BOTTOMLEFT", panel, "BOTTOMRIGHT", -1, 30)
            supporters.tab:ClearAllPoints()
            supporters.tab:SetPoint("BOTTOMLEFT", aboutTab, "TOPLEFT", 0, SIDE_TAB_GAP)
        end
        contentFrame:Show()
        contentFrame:SetHeight(contentHeight)
        panel:SetHeight(panelHeight)

        -- Footer always at the bottom of content
        footerSeparator:ClearAllPoints()
        footerSeparator:SetPoint("BOTTOMLEFT", contentFrame, "BOTTOMLEFT", CONTENT_INSET + 2, 24)
        footerSeparator:SetPoint("RIGHT", contentFrame, "RIGHT", -CONTENT_INSET - 2, 0)

        footerFrame:ClearAllPoints()
        footerFrame:SetPoint("BOTTOMLEFT", contentFrame, "BOTTOMLEFT", PANEL_PADDING, 2)
        footerFrame:SetPoint("RIGHT", contentFrame, "RIGHT", -PANEL_PADDING, 0)
    end
end

-------------------------------------------------------------------------------
-- Float / Dock
-------------------------------------------------------------------------------

-- Returns the highest-priority registered dock host that is currently shown,
-- or nil if none are visible.
local function GetActiveDockHost()
    for _, host in ipairs(dockHosts) do
        local frame = host.frame
        if frame and frame.IsShown and frame:IsShown() then
            return host
        end
    end
end

-- Anchor the docked panel next to the active host frame. PaperDollFrame is the
-- default high-priority host; external UI suites can register their own.
local function AnchorDockedPanel()
    if isFloating then return end
    local host = GetActiveDockHost()
    if not host then return end
    local xDelta = 0
    if ClassCodexDB and ClassCodexDB.widgetOffsetX then
        xDelta = ClassCodexDB.widgetOffsetX - WIDGET_DEFAULT_OFFSET_X
    end
    panel:ClearAllPoints()
    panel:SetPoint(host.point, host.frame, host.relativePoint, host.xOffset + xDelta, host.yOffset)
end

local function DockPanel()
    isFloating = false
    -- Auto-expand if minimized when docking
    if isMinimized then
        isMinimized = false
        minimizeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Up")
    end
    minimizeBtn:Hide()
    panel:SetMovable(false)
    local host = GetActiveDockHost()
    panel:SetParent((host and host.parent) or CharacterFrame)
    AnchorDockedPanel()
    panel:SetFrameStrata("DIALOG")
    if ClassCodexCharDB then ClassCodexCharDB.floating = false end
end

local function FloatPanel()
    isFloating = true
    panel:SetParent(UIParent)
    panel:SetFrameStrata("HIGH")
    panel:SetMovable(true)
    if ClassCodexCharDB and ClassCodexCharDB.floatX and ClassCodexCharDB.floatY then
        panel:ClearAllPoints()
        panel:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", ClassCodexCharDB.floatX, ClassCodexCharDB.floatY)
    else
        panel:ClearAllPoints()
        panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    if ClassCodexCharDB then ClassCodexCharDB.floating = true end
    minimizeBtn:Show()
    -- Restore minimized state when floating
    if ClassCodexCharDB and ClassCodexCharDB.minimized then
        isMinimized = true
        minimizeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Up")
    end
end

-------------------------------------------------------------------------------
-- Dock Host API — for UI suites that replace the Blizzard character window.
-------------------------------------------------------------------------------
-- The docked panel anchors to whichever registered host is currently shown
-- (highest priority wins). Built-ins:
--   PaperDollFrame  priority 10  (default Blizzard content area)
--   CharacterFrame  priority  0  (fallback for non-PaperDoll tabs)
-- GW2_UI's GwCharacterWindow is auto-registered at PLAYER_ENTERING_WORLD with
-- priority 50; calling RegisterDockHost again just overwrites that entry.
--
-- Integrating a new UI suite:
--   1. Once your replacement character window frame exists (typically during
--      your addon init or on first show), call:
--          ClassCodex.RegisterDockHost(MyCharWindow, { priority = 50 })
--      We auto-hook OnShow/OnHide on the registered frame, so the docked
--      panel and widget button appear/disappear with your window — no extra
--      hooking needed on your side.
--   2. To clean up if your suite is disabled, call
--          ClassCodex.UnregisterDockHost(MyCharWindow)
--   3. ClassCodex.RefreshDock() is available if you ever need to nudge the
--      panel to re-anchor without a show/hide cycle.
--
-- opts (all optional):
--   priority      number  default 0    higher wins when multiple hosts shown
--   parent        Frame   default frame frame to SetParent panel to (use the
--                                       enclosing window if your host is
--                                       nested, e.g. a content sub-frame)
--   point         string  default "TOPLEFT"   anchor point on the panel
--   relativePoint string  default "TOPRIGHT"  anchor point on the host frame
--   xOffset       number  default -2          x offset for SetPoint
--   yOffset       number  default 0           y offset for SetPoint
--
-- Things to verify when integrating:
--   - The frame you pass must be the visible/sized window (its IsShown/edges
--     are what we read). Don't pass a hidden parent or a 0-sized container.
--   - Set priority above 10 to win over PaperDollFrame, below 10 to be a
--     fallback only when PaperDollFrame isn't shown.
function ns.RegisterDockHost(frame, opts)
    if type(frame) ~= "table" then return end
    opts = opts or {}
    local host
    for _, h in ipairs(dockHosts) do
        if h.frame == frame then host = h; break end
    end
    local isNew = not host
    host = host or { frame = frame }
    host.parent        = opts.parent or frame
    host.point         = opts.point or "TOPLEFT"
    host.relativePoint = opts.relativePoint or "TOPRIGHT"
    host.xOffset       = opts.xOffset or -2
    host.yOffset       = opts.yOffset or 0
    host.priority      = opts.priority or 0
    if isNew then
        table.insert(dockHosts, host)
        if ns.InstallHostHooks then ns.InstallHostHooks(host) end
    end
    table.sort(dockHosts, function(a, b) return a.priority > b.priority end)
    if not isFloating and panel and panel:IsShown() then DockPanel() end
end

function ns.UnregisterDockHost(frame)
    for i, h in ipairs(dockHosts) do
        if h.frame == frame then
            table.remove(dockHosts, i)
            if not isFloating and panel and panel:IsShown() then DockPanel() end
            return
        end
    end
end

-- Re-runs dock anchoring; call from a host frame's OnShow/OnHide if its show
-- state isn't already tied to PaperDollFrame's lifecycle.
function ns.RefreshDock()
    if not isFloating and panel and panel:IsShown() then
        AnchorDockedPanel()
        ns:LayoutPanel()
    end
end

-- Built-in dock hosts: PaperDollFrame is the active content area when the
-- character pane is open; CharacterFrame is the fallback (slightly different
-- offset to account for its visual chrome).
ns.RegisterDockHost(PaperDollFrame, { priority = 10, parent = CharacterFrame, xOffset = -2, yOffset = 0 })
ns.RegisterDockHost(CharacterFrame, { priority = 0, parent = CharacterFrame, xOffset = -2, yOffset = -1 })

-- Public global namespace for cross-addon integration (e.g. UI suites that want
-- to register their character window as a dock host).
_G.ClassCodex = _G.ClassCodex or {}
_G.ClassCodex.RegisterDockHost   = ns.RegisterDockHost
_G.ClassCodex.UnregisterDockHost = ns.UnregisterDockHost
_G.ClassCodex.RefreshDock        = ns.RefreshDock

pinBtn:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
        -- Section visibility menu — native context menu with proper
        -- checkboxes and "stays open while you toggle" semantics. The
        -- mode prefix (float / dock) is captured at open time and
        -- baked into each checkbox's get/set closures.
        local prefix = isFloating and "float" or "dock"
        local options = {
            { key = prefix .. "ShowStats",    label = L["section.stat_priority"] },
            { key = prefix .. "ShowTalents",  label = L["section.talents"] },
            { key = prefix .. "ShowRotation", label = L["section.rotation"] },
        }
        local gearingOpts = isFloating and ns.gearingFloatOptions or ns.gearingDockOptions
        if gearingOpts then
            for _, opt in ipairs(gearingOpts) do options[#options + 1] = opt end
        end
        MenuUtil.CreateContextMenu(pinBtn, function(_, rootDescription)
            for _, opt in ipairs(options) do
                rootDescription:CreateCheckbox(
                    opt.label,
                    function() return ClassCodexDB[opt.key] ~= false end,
                    function()
                        ClassCodexDB[opt.key] = not (ClassCodexDB[opt.key] ~= false)
                        if panel:IsShown() then ns:UpdatePanel() end
                        return MenuResponse.Refresh
                    end
                )
            end
        end)
        return
    end
    if isFloating then DockPanel() else FloatPanel() end
    ns:UpdatePanel()
end)

minimizeBtn:SetScript("OnClick", function()
    isMinimized = not isMinimized
    if ClassCodexCharDB then ClassCodexCharDB.minimized = isMinimized end
    minimizeBtn:SetNormalTexture(isMinimized
        and "Interface\\Buttons\\UI-Panel-ExpandButton-Up"
        or "Interface\\Buttons\\UI-Panel-CollapseButton-Up")
    ns:LayoutPanel()
end)

-- rotCtxDropdown wiring lives in UpdatePanel via :SetOptions.

-- heroDropdown wiring lives in UpdatePanel via :SetOptions; the
-- WowStyle1Dropdown template owns the click + popup itself.

-- statCtxDropdown wiring lives in UpdatePanel via :SetOptions.


-------------------------------------------------------------------------------
-- Widget Button (deferred until PaperDollFrame exists)
-------------------------------------------------------------------------------

local widgetContainer, widgetBtn, widgetIcon, activeGlow

local function ApplyWidgetPosition()
    if not widgetContainer or not ClassCodexDB then return end
    local host = GetActiveDockHost()
    local anchor = (host and host.frame) or PaperDollFrame
    local x = ClassCodexDB.widgetOffsetX or WIDGET_DEFAULT_OFFSET_X
    local y = ClassCodexDB.widgetOffsetY or WIDGET_DEFAULT_OFFSET_Y
    if widgetContainer:GetParent() ~= anchor then
        widgetContainer:SetParent(anchor)
    end
    widgetContainer:ClearAllPoints()
    widgetContainer:SetPoint("CENTER", anchor, "TOPRIGHT", x, y)
    if not isFloating and panel and panel:IsShown() then
        AnchorDockedPanel()
    end
end
ns.ApplyWidgetPosition = ApplyWidgetPosition

local function RefreshWidgetTooltip()
    if not widgetBtn or not GameTooltip:IsOwned(widgetBtn) then return end
    widgetBtn:GetScript("OnEnter")(widgetBtn)
end
ns.RefreshWidgetTooltip = RefreshWidgetTooltip

local function SetupWidgetButton()
    if widgetContainer then return end -- already set up

    widgetContainer = CreateFrame("Frame", nil, PaperDollFrame)
    widgetContainer:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    widgetContainer:SetFrameStrata("TOOLTIP")
    widgetContainer:SetMovable(true)
    widgetContainer:SetClampedToScreen(true)

    widgetBtn = CreateFrame("Button", "ClassCodexWidgetButton", widgetContainer)
    widgetBtn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    widgetBtn:SetPoint("CENTER")
    widgetBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    widgetBtn:RegisterForDrag("LeftButton")

    widgetIcon = widgetBtn:CreateTexture(nil, "ARTWORK")
    widgetIcon:SetSize(BUTTON_SIZE - 8, BUTTON_SIZE - 8)
    widgetIcon:SetPoint("CENTER")
    widgetIcon:SetAtlas("mechagon-projects")
    widgetIcon:SetDesaturated(true)
    widgetIcon:SetVertexColor(0.85, 0.85, 0.85)

    local widgetHighlight = widgetBtn:CreateTexture(nil, "HIGHLIGHT")
    widgetHighlight:SetAllPoints(widgetIcon)
    widgetHighlight:SetAtlas("mechagon-projects")
    widgetHighlight:SetAlpha(0.4)
    widgetHighlight:SetBlendMode("ADD")

    activeGlow = widgetBtn:CreateTexture(nil, "OVERLAY")
    activeGlow:SetSize(BUTTON_SIZE + 4, BUTTON_SIZE + 4)
    activeGlow:SetPoint("CENTER")
    activeGlow:SetAtlas("bags-glow-flash")
    activeGlow:SetVertexColor(0.3, 0.6, 1.0, 0.6)
    activeGlow:SetBlendMode("ADD")
    activeGlow:Hide()

    local function IsLocked()
        return ClassCodexDB and ClassCodexDB.widgetLocked
    end

    widgetBtn:SetScript("OnEnter", function(self)
        widgetIcon:SetDesaturated(false)
        widgetIcon:SetVertexColor(1, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["Class Codex"], 1, 1, 1)
        GameTooltip:AddLine(L["character_pane.click_to_toggle"], 0.7, 0.7, 0.7)
        if IsLocked() then
            GameTooltip:AddLine(L["character_pane.position_locked"], 0.55, 0.55, 0.55)
        else
            GameTooltip:AddLine(L["character_pane.shift_drag_hint"], 0.45, 0.75, 0.45)
        end
        GameTooltip:Show()
    end)
    widgetBtn:SetScript("OnLeave", function()
        widgetIcon:SetDesaturated(true)
        widgetIcon:SetVertexColor(0.85, 0.85, 0.85)
        GameTooltip:Hide()
    end)

    widgetBtn:SetScript("OnDragStart", function()
        if IsLocked() or not IsShiftKeyDown() then return end
        widgetContainer:StartMoving()
        widgetContainer.isMoving = true
    end)

    widgetBtn:SetScript("OnDragStop", function()
        if not widgetContainer.isMoving then return end
        widgetContainer:StopMovingOrSizing()
        widgetContainer.isMoving = false
        local cx, cy = widgetContainer:GetCenter()
        local anchor = widgetContainer:GetParent() or PaperDollFrame
        local right, top = anchor:GetRight(), anchor:GetTop()
        if cx and cy and right and top then
            ClassCodexDB.widgetOffsetX = math.floor(cx - right + 0.5)
            ClassCodexDB.widgetOffsetY = math.floor(cy - top + 0.5)
        end
        ApplyWidgetPosition()
        RefreshWidgetTooltip()
    end)

    widgetBtn:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
            if IsLocked() or not IsShiftKeyDown() then return end
            ClassCodexDB.widgetOffsetX = WIDGET_DEFAULT_OFFSET_X
            ClassCodexDB.widgetOffsetY = WIDGET_DEFAULT_OFFSET_Y
            ApplyWidgetPosition()
            return
        end
        if IsShiftKeyDown() and not IsLocked() then return end -- swallow shift-clicks used for repositioning
        if panel:IsShown() and not isFloating then
            panel:Hide()
            ClassCodexCharDB.panelOpen = false
            activeGlow:Hide()
        else
            if not isFloating then DockPanel() end
            ns:UpdatePanel()
            FadeIn(panel)
            ClassCodexCharDB.panelOpen = true
            activeGlow:Show()
        end
    end)

    -- Shared show/hide handlers usable by any registered dock host
    -- (PaperDollFrame, GW2_UI's GwCharacterWindow, etc.)
    local function OnAnyHostShow()
        local ok, err = pcall(function()
            ApplyWidgetPosition()
            if not isFloating then
                DockPanel()
                if ClassCodexCharDB and ClassCodexCharDB.panelOpen then
                    ns:UpdatePanel()
                    FadeIn(panel)
                    if activeGlow then activeGlow:Show() end
                elseif activeGlow then
                    activeGlow:Hide()
                end
                -- Deferred re-anchor: addons like Chonky reposition CharacterFrame
                -- children in a hooksecurefunc on Show that runs after this hook
                C_Timer.After(0, function()
                    if not isFloating and panel:IsShown() then
                        AnchorDockedPanel()
                        ns:LayoutPanel()
                    end
                end)
            end
        end)
        if not ok then
            print("|cffff0000Class Codex:|r Panel error: " .. tostring(err))
        end
    end

    local function OnAnyHostHide()
        if not isFloating then
            panel:Hide()
            copyPopup:Hide()
        end
        if activeGlow then activeGlow:Hide() end
    end

    PaperDollFrame:HookScript("OnShow", OnAnyHostShow)
    PaperDollFrame:HookScript("OnHide", OnAnyHostHide)

    -- Re-layout when CharacterFrame is resized (e.g. by Chonky Character Sheet)
    -- so the panel height stays in sync.
    CharacterFrame:HookScript("OnSizeChanged", function()
        if not isFloating and panel:IsShown() then
            AnchorDockedPanel()
            ns:LayoutPanel()
        end
    end)

    -- Install hooks on external dock hosts (e.g. GW2_UI's GwCharacterWindow)
    -- so the panel and widget appear/disappear with their character window.
    function ns.InstallHostHooks(host)
        if host._hooked then return end
        if host.frame == PaperDollFrame or host.frame == CharacterFrame then return end
        host._hooked = true
        host.frame:HookScript("OnShow", OnAnyHostShow)
        host.frame:HookScript("OnHide", OnAnyHostHide)
    end
    -- Catch any external hosts registered before SetupWidgetButton ran.
    for _, host in ipairs(dockHosts) do ns.InstallHostHooks(host) end

end

-------------------------------------------------------------------------------
-- Addon Compartment
-------------------------------------------------------------------------------

function ClassCodex_OnAddonCompartmentClick()
    if ns.OpenCompendium then
        ns:OpenCompendium()
    end
end

function ClassCodex_OnAddonCompartmentEnter(_, menuButtonFrame)
    local ver = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
    GameTooltip:SetOwner(menuButtonFrame, "ANCHOR_RIGHT")
    GameTooltip:AddLine("Class Codex v" .. ver, 1, 1, 1)
    GameTooltip:AddLine("Click to open Compendium", 0.7, 0.7, 0.7)
    GameTooltip:Show()
end

function ClassCodex_OnAddonCompartmentLeave()
    GameTooltip:Hide()
end

-------------------------------------------------------------------------------
-- Tooltip Rank Badges
-------------------------------------------------------------------------------

-- Map localized stat names → English data keys for tooltip matching.
-- Uses WoW global strings so tooltips work in every locale (ko, zh, de, …).
-- Some locales (e.g. deDE) use a different word in STAT_* (character sheet)
-- vs ITEM_MOD_*_SHORT (item tooltips), so we register both as fallbacks.
local STAT_LOOKUP = {}
do
    local stats = {
        { key = "Critical Strike", globals = { "STAT_CRITICAL_STRIKE", "ITEM_MOD_CRIT_RATING_SHORT" } },
        { key = "Haste",           globals = { "STAT_HASTE", "ITEM_MOD_HASTE_RATING_SHORT" } },
        { key = "Mastery",         globals = { "STAT_MASTERY", "ITEM_MOD_MASTERY_RATING_SHORT" } },
        { key = "Versatility",     globals = { "STAT_VERSATILITY", "ITEM_MOD_VERSATILITY" } },
    }
    for _, s in ipairs(stats) do
        for _, g in ipairs(s.globals) do
            local localized = _G[g]
            if localized and localized ~= "" and not STAT_LOOKUP[localized] then
                STAT_LOOKUP[localized] = s.key
            end
        end
        -- Ensure English key is always present as a fallback
        if not STAT_LOOKUP[s.key] then
            STAT_LOOKUP[s.key] = s.key
        end
    end
end

-- Tooltip helpers (hoisted to file scope to avoid re-creation per hover)
local BIS_TIER_HEX = {
    S = "|cffff8000", A = "|cffa336ee",
    B = "|cff0070dd", C = "|cff1eff00",
    D = "|cff9e9e9e",
}
local BIS_TIER_ORDER = { S = 1, A = 2, B = 3, C = 4, D = 5 }
local BIS_CLASS_ID_MAP = {
    WARRIOR = 1, PALADIN = 2, HUNTER = 3, ROGUE = 4, PRIEST = 5,
    DEATHKNIGHT = 6, SHAMAN = 7, MAGE = 8, WARLOCK = 9, MONK = 10,
    DRUID = 11, DEMONHUNTER = 12, EVOKER = 13,
}

-- Pre-cached icon/color strings: classToken → string, classToken|specKey → string
local iconCache = {}
local colorCache = {}

local function GetClassColorHex(classToken)
    local cached = colorCache[classToken]
    if cached then return cached end
    local color = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classToken]
    if color then
        cached = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
    else
        cached = "|cffffffff"
    end
    colorCache[classToken] = cached
    return cached
end

local function GetClassIcon(classToken)
    local key = classToken
    local cached = iconCache[key]
    if cached then return cached end
    local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classToken]
    if coords then
        local l, r, t, b = coords[1], coords[2], coords[3], coords[4]
        cached = string.format("|TInterface\\GLUES\\CHARACTERCREATE\\UI-CharacterCreate-Classes:14:14:0:0:256:256:%d:%d:%d:%d|t",
            l * 256 + 6, r * 256 - 6, t * 256 + 6, b * 256 - 6)
    else
        cached = ""
    end
    iconCache[key] = cached
    return cached
end

local function GetSpecIcon(classToken, specKey)
    local key = classToken .. "|" .. specKey
    local cached = iconCache[key]
    if cached then return cached end
    local classID = BIS_CLASS_ID_MAP[classToken]
    if classID and GetSpecializationInfoForClassID then
        local keys = SPEC_KEYS[classToken]
        if keys then
            for i, k in ipairs(keys) do
                if k == specKey then
                    local _, _, _, icon = GetSpecializationInfoForClassID(classID, i)
                    if icon then
                        cached = string.format("|T%s:14:14:0:0|t", tostring(icon))
                        iconCache[key] = cached
                        return cached
                    end
                    break
                end
            end
        end
    end
    cached = GetClassIcon(classToken)
    iconCache[key] = cached
    return cached
end

local function GetEntryIcon(entry)
    if entry.consolidated then
        return GetClassIcon(entry.class)
    else
        return GetSpecIcon(entry.class, entry.spec)
    end
end

-- Multi-item tooltip cache: handles simultaneous tooltips (bag item + 2 equipped comparisons)
local tooltipCache = {}       -- cacheKey → { entries, source, hasTrinketEntries }
local tooltipCacheClassOnly = false  -- tracks the classOnly flag the cache was built with
local playerClassToken = nil  -- set once at ADDON_LOADED

local function BuildTooltipEntries(itemId)
    local classOnly = ClassCodexDB.bisCurrentClassOnly and playerClassToken or false

    -- Invalidate entire cache if classOnly setting changed
    if tooltipCacheClassOnly ~= classOnly then
        wipe(tooltipCache)
        tooltipCacheClassOnly = classOnly
    end

    local cached = tooltipCache[itemId]
    if cached then
        return cached.entries, cached.source, cached.hasTrinketEntries
    end

    local entries = {}
    local seen = {}
    local hasTrinketEntries = false
    local source = nil

    -- Trinket tiers
    if ClassCodexDB.showTrinketTooltip and ns.GetTrinketSpecs then
        local trinketSpecs = ns:GetTrinketSpecs(itemId)
        if trinketSpecs then
            if ns.GetTrinketSource then source = ns:GetTrinketSource(itemId) end
            for _, entry in ipairs(trinketSpecs) do
                if not classOnly or entry.class == classOnly then
                    local hex = BIS_TIER_HEX[entry.tier] or "|cffffffff"
                    entries[#entries + 1] = {
                        left = GetEntryIcon(entry) .. " " .. GetClassColorHex(entry.class) .. entry.label .. "|r",
                        right = hex .. entry.tier .. "|r",
                        classToken = entry.class,
                        sortKey = BIS_TIER_ORDER[entry.tier] or 6,
                        isTrinketEntry = true,
                    }
                    seen[entry.label] = true
                    hasTrinketEntries = true
                end
            end
        end
    end

    -- BiS gear — merged per-spec approach (Wowhead + Icy Veins)
    local showWH = ClassCodexDB.showWowheadBisTooltip
    local showIV = ClassCodexDB.showIcyVeinsBisTooltip
    local bothEnabled = showWH and showIV

    -- Collect WH entries by spec label
    local bisBySpec = {} -- label → { class, hasWH, hasIV, ivTabs = {} }
    local bisOrder = {}

    if showWH and ns.GetWowheadBisSpecs then
        local bisSpecs = ns:GetWowheadBisSpecs(itemId)
        if bisSpecs then
            for _, entry in ipairs(bisSpecs) do
                if not seen[entry.label] and (not classOnly or entry.class == classOnly) then
                    bisBySpec[entry.label] = { class = entry.class, spec = entry.spec, consolidated = entry.consolidated, hasWH = true, hasIV = false, ivTabs = {} }
                    bisOrder[#bisOrder + 1] = entry.label
                end
            end
        end
    end

    -- Collect IV entries by spec label, merge into same table
    -- Skip IV for trinkets — tier info is sufficient
    if showIV and not hasTrinketEntries and ns.GetIcyVeinsBisSpecs then
        local ivSpecs = ns:GetIcyVeinsBisSpecs(itemId)
        if ivSpecs then
            for _, entry in ipairs(ivSpecs) do
                if not classOnly or entry.class == classOnly then
                    local existing = bisBySpec[entry.label]
                    if existing then
                        -- Merge IV tabs into existing entry
                        existing.hasIV = true
                        if entry.tabs then
                            for _, t in ipairs(entry.tabs) do
                                existing.ivTabs[#existing.ivTabs + 1] = t
                            end
                        end
                    else
                        -- New spec only in IV
                        bisBySpec[entry.label] = { class = entry.class, spec = entry.spec, consolidated = entry.consolidated, hasWH = false, hasIV = true, ivTabs = entry.tabs or {} }
                        bisOrder[#bisOrder + 1] = entry.label
                    end
                end
            end
        end
    end

    -- Build merged entries
    for _, label in ipairs(bisOrder) do
        if not seen[label] then
            local info = bisBySpec[label]
            local rightLabel = nil

            if info.hasWH or info.hasIV then
                local style = ClassCodexDB.tooltipSourceStyle or 1
                local showIcon = style == 1 or style == 3
                local showLabel = style == 2 or style == 3
                local parts = {}
                if info.hasWH then
                    local s = ""
                    if showIcon then s = s .. "|TInterface\\AddOns\\ClassCodex\\Textures\\wowhead:12:12:0:0|t" end
                    if showLabel then s = s .. (showIcon and " " or "") .. "|cffff8000WH|r" end
                    parts[#parts + 1] = s
                end
                if info.hasIV then
                    -- Deduplicate tabs
                    local uniqueTabs = {}
                    local tabSeen = {}
                    for _, t in ipairs(info.ivTabs) do
                        if not tabSeen[t] then
                            tabSeen[t] = true
                            uniqueTabs[#uniqueTabs + 1] = t
                        end
                    end
                    local s = ""
                    if showIcon then s = s .. "|TInterface\\AddOns\\ClassCodex\\Textures\\icyveins:12:12:0:0|t" end
                    -- Show tab context when not all tabs (shorten Mythic+ → M+)
                    if #uniqueTabs > 0 and #uniqueTabs < 3 then
                        local shortTabs = {}
                        for _, t in ipairs(uniqueTabs) do
                            shortTabs[#shortTabs + 1] = t == "Mythic+" and "M+" or t
                        end
                        s = s .. " \194\183 " .. "|cff00ccff" .. table.concat(shortTabs, ", ") .. "|r"
                    elseif showLabel then
                        s = s .. (showIcon and " " or "") .. "|cff00ccffIV|r"
                    end
                    parts[#parts + 1] = s
                end
                rightLabel = table.concat(parts, "  ")
            end

            entries[#entries + 1] = {
                left = GetEntryIcon(info) .. " " .. GetClassColorHex(info.class) .. label .. "|r",
                right = rightLabel,
                classToken = info.class,
                sortKey = 0,
            }
            seen[label] = true
        end
    end

    if #entries > 0 then
        table.sort(entries, function(a, b) return a.sortKey < b.sortKey end)
    end

    tooltipCache[itemId] = { entries = entries, source = source, hasTrinketEntries = hasTrinketEntries }
    return entries, source, hasTrinketEntries
end

-- Cached stat priority ranks (invalidated when hero/context changes)
local cachedRanks = nil
local cachedRanksHero = nil
local cachedRanksCtx = nil

local function GetCachedRanks()
    local specData = GetSpecData()
    if not specData then return nil end
    -- Lazy-detect hero talent so tooltip ranks are correct before panel opens
    if not currentHeroTalent then
        local perSpec = GetPerSpecState()
        if perSpec and perSpec.heroTalent then
            currentHeroTalent = perSpec.heroTalent
        else
            local detected = GetActiveHeroTalentName()
            if detected then
                local heroOptions = GetHeroTalentOptions(specData)
                for _, opt in ipairs(heroOptions) do
                    if opt:lower() == detected:lower() then
                        currentHeroTalent = opt
                        break
                    end
                end
            end
        end
    end
    local hero = currentHeroTalent or "All"
    local ctx = currentStatContext or "General"
    if cachedRanks and cachedRanksHero == hero and cachedRanksCtx == ctx then
        return cachedRanks
    end
    local priority = FindMatch(specData.priorities, hero, ctx)
    if not priority then cachedRanks = nil; return nil end
    cachedRanks = {}
    for i, tier in ipairs(priority.stats) do
        for _, stat in ipairs(tier) do cachedRanks[stat] = i end
    end
    cachedRanksHero = hero
    cachedRanksCtx = ctx
    return cachedRanks
end

local function OnTooltipItem(tooltip, tooltipData)
    if not ClassCodexDB then return end

    -- Extract item ID from tooltip data
    local itemId = tooltipData and tooltipData.id

    -- Trinket tier badge on the title line (right side) — current spec only
    if ClassCodexDB.showTrinketTooltip and itemId and ns.GetTrinketTier then
        local tier, tierColor = ns:GetTrinketTier(itemId)
        if tier and tierColor then
            local titleRight = _G[tooltip:GetName() .. "TextRight1"]
            if titleRight and titleRight:GetFont() then
                local hex = string.format("|cff%02x%02x%02x", tierColor.r * 255, tierColor.g * 255, tierColor.b * 255)
                titleRight:SetText(hex .. tier .. "|r")
                titleRight:Show()
            end
        end
    end

    -- Cross-spec BiS + trinket tier info
    if itemId and (ClassCodexDB.showWowheadBisTooltip or ClassCodexDB.showIcyVeinsBisTooltip or ClassCodexDB.showTrinketTooltip) then
        local entries, source, hasTrinketEntries = BuildTooltipEntries(itemId)

        if #entries > 0 then
            tooltip:AddLine(" ")
            local style = ClassCodexDB.tooltipSourceStyle or 1
            local showIcon = style == 1 or style == 3
            local showLabel = style == 2 or style == 3
            local headerSources = {}
            if ClassCodexDB.showWowheadBisTooltip then
                local s = ""
                if showIcon then s = s .. "|TInterface\\AddOns\\ClassCodex\\Textures\\wowhead:12:12:0:0|t" end
                if showLabel then s = s .. (showIcon and " " or "") .. "|cffff8000WH|r" end
                headerSources[#headerSources + 1] = s
            end
            if ClassCodexDB.showIcyVeinsBisTooltip then
                local s = ""
                if showIcon then s = s .. "|TInterface\\AddOns\\ClassCodex\\Textures\\icyveins:12:12:0:0|t" end
                if showLabel then s = s .. (showIcon and " " or "") .. "|cff00ccffIV|r" end
                headerSources[#headerSources + 1] = s
            end
            if #headerSources > 0 then
                tooltip:AddDoubleLine("Best in Slot", table.concat(headerSources, "  "), 0.9, 0.8, 0.5, 0.9, 0.8, 0.5)
            else
                tooltip:AddLine("Best in Slot", 0.9, 0.8, 0.5)
            end

            if hasTrinketEntries and source then
                tooltip:AddDoubleLine("Source", source, 0.5, 0.5, 0.5, 1, 0.82, 0)
            end

            for _, e in ipairs(entries) do
                local cclr = RAID_CLASS_COLORS and RAID_CLASS_COLORS[e.classToken]
                local cr, cg, cb = 1, 1, 1
                if cclr then cr, cg, cb = cclr.r, cclr.g, cclr.b end
                if e.right then
                    tooltip:AddDoubleLine(e.left, e.right, cr, cg, cb, cr, cg, cb)
                else
                    tooltip:AddLine(e.left, cr, cg, cb)
                end
            end
        end
    end

    -- Stat priority ranks (cached until hero/context changes)
    if not ClassCodexDB.showTooltipBadges then return end
    local ranks = GetCachedRanks()
    if not ranks then return end

    local annotated = false
    for i = 2, tooltip:NumLines() do
        local line = _G[tooltip:GetName() .. "TextLeft" .. i]
        if line then
            local text = line:GetText()
            if text then
                -- Skip tainted/secret strings (secure tooltip contexts like quest items)
                local ok, _ = pcall(string.len, text)
                if ok and line:GetFont() then
                    for localizedStat, englishStat in pairs(STAT_LOOKUP) do
                        if text:find(localizedStat, 1, true) and not text:find("#%d") then
                            local rank = ranks[englishStat]
                            if rank then
                                local color = RANK_COLORS[rank]
                                if color then
                                    local hex = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
                                    line:SetText(text .. "  " .. hex .. "#" .. rank .. "|r")
                                    annotated = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Optional footer line: which hero/context the ranks come from.
    -- tooltipFooterMode: 0 = off, 1 = always, 2 = only when resolved
    -- hero differs from the player's currently active hero.
    if annotated then
        local mode = ClassCodexDB.tooltipFooterMode or 0
        if mode > 0 then
            local activeHero = GetActiveHeroTalentName()
            local heroDiffers = activeHero
                and cachedRanksHero
                and cachedRanksHero ~= "All"
                and activeHero:lower() ~= cachedRanksHero:lower()
            local suppress = (mode == 2) and not heroDiffers
            if not suppress then
                tooltip:AddLine(string.format("|cff808080%s: %s · %s|r",
                    L["tooltip.stat_priority_footer"], cachedRanksHero or "All", cachedRanksCtx or "General"))
            end
        end
    end
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipItem)
end

-------------------------------------------------------------------------------
-- Static Popups
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- Settings panel helpers
--
-- ns.RegisterSettings (defined in Settings.lua) calls these to refresh the
-- panel after a setting changes, instead of capturing panel/isFloating
-- directly from this file's scope.
-------------------------------------------------------------------------------

function ns.UpdatePanelIfVisible(mode)
    if not panel:IsShown() then return end
    if mode == "docked" and isFloating then return end
    if mode == "floating" and not isFloating then return end
    ns:UpdatePanel()
end

function ns.InvalidateTooltipCache()
    wipe(tooltipCache)
    tooltipCacheClassOnly = nil
end


-------------------------------------------------------------------------------
-- Events
-------------------------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
-- Live stat target updates: refresh bars when ratings change. Throttled
-- via the existing UpdatePanel call path so a flurry of equipment swaps
-- collapses to one re-render.
eventFrame:RegisterEvent("COMBAT_RATING_UPDATE")
eventFrame:RegisterEvent("UNIT_STATS")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
-- Drives the "owned" overlay on BiS rows. Blizzard debounces this
-- event already, so loot/bank/mail churn collapses to one refresh.
eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
-- Re-render Stat Targets on combat transitions so the in-combat
-- placeholder swaps in/out predictably (GetCombatRating only returns
-- real values to tainted code outside combat).
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        local dbDefaults = {
            showLoginMessage = false,
            showTooltipBadges = true,
            tooltipFooterMode = 0, -- 0 off, 1 always, 2 only when different
            showWowheadBisTooltip = true,
            showIcyVeinsBisTooltip = true,
            showTrinketTooltip = true,
            bisCurrentClassOnly = false,
            highlightOwnedGear = true,
            tooltipSourceStyle = 1,
            minimap = { hide = false },
            showMinimapButton = true,
            floatShowStats = true,
            floatShowStatTargets = true,
            floatShowTalents = true,
            floatShowRotation = true,
            floatShowEnchants = true,
            floatShowGems = true,
            floatShowConsumables = true,
            floatShowTrinkets = true,
            floatShowCrafts = true,
            floatShowBisGear = true,
            dockShowStats = true,
            dockShowStatTargets = true,
            dockShowTalents = true,
            dockShowRotation = true,
            dockShowEnchants = true,
            dockShowGems = true,
            dockShowConsumables = true,
            dockShowTrinkets = true,
            dockShowCrafts = true,
            dockShowBisGear = true,
            widgetOffsetX = WIDGET_DEFAULT_OFFSET_X,
            widgetOffsetY = WIDGET_DEFAULT_OFFSET_Y,
            widgetLocked = false,
            dockLoadoutEnabled = false,
            dockLoadoutHideInCombat = true,
            dockLoadoutLocked = false,
            dockLoadoutShowSpecIcon = true,
            dockLoadoutShowHeroIcon = true,
            dockLoadoutShowSaved = true,
            dockLoadoutShowWowhead = true,
            dockLoadoutShowArchon = true,
            dockLoadoutOpacity = 95,
            dockLoadoutWidth = 200,
            dockLoadoutAutoWidth = false,
            dockLoadoutScale = 100,
            dockLoadoutAlignment = "LEFT",
            dockLoadoutShowBorder = true,
        }
        local charDefaults = {
        panelOpen = true, floating = false, minimized = false, perSpec = {},
        collapsed = {
            stats = false,
            statTargets = false,
            talents = false,
            rotation = false,
            enchants = false,
            gems = false,
        },
    }

        if not ClassCodexDB then ClassCodexDB = {} end
        -- Migrate old showBisTooltip → showWowheadBisTooltip
        if ClassCodexDB.showBisTooltip ~= nil then
            ClassCodexDB.showWowheadBisTooltip = ClassCodexDB.showBisTooltip
            ClassCodexDB.showBisTooltip = nil
        end
        -- Migrate old tab keys to new merged tabs
        local TAB_MIGRATION = { enchants = "enhancements", consumables = "enhancements", gear = "bis" }
        if ClassCodexDB.compendiumTab then
            ClassCodexDB.compendiumTab = TAB_MIGRATION[ClassCodexDB.compendiumTab] or ClassCodexDB.compendiumTab
        end
        -- Loadout Dock position: was per-character on ClassCodexCharDB.loadoutDock
        -- during the preview, now account-wide on ClassCodexDB.dockLoadoutPosition.
        -- Migrate the first character's saved position so users don't lose it.
        if ClassCodexCharDB and ClassCodexCharDB.loadoutDock then
            local old = ClassCodexCharDB.loadoutDock
            if old.point and old.x and old.y and not ClassCodexDB.dockLoadoutPosition then
                ClassCodexDB.dockLoadoutPosition = {
                    point = old.point,
                    relativePoint = old.relativePoint,
                    x = old.x,
                    y = old.y,
                }
            end
            ClassCodexCharDB.loadoutDock = nil
        end
        -- Migrate the early two-checkbox tooltip-footer scheme into the
        -- consolidated tooltipFooterMode dropdown so users who tried the
        -- preview keep their preference.
        if ClassCodexDB.showTooltipPriorityFooter ~= nil and ClassCodexDB.tooltipFooterMode == nil then
            if ClassCodexDB.showTooltipPriorityFooter then
                ClassCodexDB.tooltipFooterMode = ClassCodexDB.tooltipFooterOnlyWhenDifferent and 2 or 1
            else
                ClassCodexDB.tooltipFooterMode = 0
            end
        end
        ClassCodexDB.showTooltipPriorityFooter = nil
        ClassCodexDB.tooltipFooterOnlyWhenDifferent = nil
        for k, v in pairs(dbDefaults) do if ClassCodexDB[k] == nil then ClassCodexDB[k] = v end end
        -- Guardrail: if a mode has every content toggle disabled, recover to guide defaults.
        local function EnsureAtLeastOneVisibleTab(modePrefix)
            local hasGuide = ClassCodexDB[modePrefix .. "Stats"] ~= false
                or ClassCodexDB[modePrefix .. "Talents"] ~= false
                or ClassCodexDB[modePrefix .. "Rotation"] ~= false
            local hasGearing = ClassCodexDB[modePrefix .. "Enchants"] ~= false
                or ClassCodexDB[modePrefix .. "Gems"] ~= false
                or ClassCodexDB[modePrefix .. "Consumables"] ~= false
                or ClassCodexDB[modePrefix .. "Trinkets"] ~= false
                or ClassCodexDB[modePrefix .. "Crafts"] ~= false
                or ClassCodexDB[modePrefix .. "BisGear"] ~= false
            if not hasGuide and not hasGearing then
                ClassCodexDB[modePrefix .. "Stats"] = true
                ClassCodexDB[modePrefix .. "Talents"] = true
                ClassCodexDB[modePrefix .. "Rotation"] = true
            end
        end
        EnsureAtLeastOneVisibleTab("dockShow")
        EnsureAtLeastOneVisibleTab("floatShow")
        if type(ClassCodexDB.minimap) ~= "table" then ClassCodexDB.minimap = { hide = false } end
        -- Reconcile minimap visibility (showMinimapButton drives minimap.hide)
        ClassCodexDB.minimap.hide = not ClassCodexDB.showMinimapButton
        if not ClassCodexCharDB then ClassCodexCharDB = {} end
        for k, v in pairs(charDefaults) do if ClassCodexCharDB[k] == nil then ClassCodexCharDB[k] = v end end
        if ClassCodexCharDB.activeTab then
            ClassCodexCharDB.activeTab = TAB_MIGRATION[ClassCodexCharDB.activeTab] or ClassCodexCharDB.activeTab
        end

        playerClassToken = select(2, UnitClass("player"))
        ns.RegisterSettings()

        -- Minimap button (LibDBIcon)
        local LDB = LibStub("LibDataBroker-1.1", true)
        local LDBIcon = LibStub("LibDBIcon-1.0", true)
        if LDB and LDBIcon then
            local dataObj = LDB:NewDataObject("ClassCodex", {
                type = "launcher",
                icon = "Interface\\AddOns\\ClassCodex\\icon",
                OnClick = function(_, button)
                    if button == "LeftButton" then
                        if ns.OpenCompendium then
                            ns:OpenCompendium()
                        end
                    elseif button == "RightButton" then
                        if ns.settingsCategory then
                            Settings.OpenToCategory(ns.settingsCategory:GetID())
                        end
                    end
                end,
                OnTooltipShow = function(tip)
                    local ver = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
                    tip:AddLine(L["Class Codex"] .. " v" .. ver, 1, 1, 1)
                    tip:AddLine(L["Left-click to open Compendium"], 0.7, 0.7, 0.7)
                    tip:AddLine(L["Right-click to open Settings"], 0.7, 0.7, 0.7)
                end,
            })
            LDBIcon:Register("ClassCodex", dataObj, ClassCodexDB.minimap)
            ns.LDBIcon = LDBIcon
        end

        if ClassCodexCharDB.floating then FloatPanel() end

        isMinimized = ClassCodexCharDB.minimized or false
        if isMinimized then
            minimizeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-ExpandButton-Up")
        end

        if ClassCodexCharDB.activeTab then
            ns.setActiveTab(ClassCodexCharDB.activeTab)
        end

        -- Setup widget if PaperDollFrame already exists, otherwise wait
        if PaperDollFrame then
            SetupWidgetButton()
        end

    elseif event == "ADDON_LOADED" and PaperDollFrame and not widgetContainer then
        SetupWidgetButton()

    elseif event == "PLAYER_ENTERING_WORLD" then
        if PaperDollFrame and not widgetContainer then
            SetupWidgetButton()
        end
        -- Auto-register known UI suites as dock hosts so users get the right
        -- anchor without those addons needing to call ns.RegisterDockHost first.
        -- (GW2_UI replaces the character window with GwCharacterWindow.)
        if _G.GwCharacterWindow then
            ns.RegisterDockHost(_G.GwCharacterWindow, { priority = 50 })
        end
        -- if ClassCodexDB and ClassCodexDB.showLoginMessage then
        --     local ver = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
        --     print("|cff00ccffClass Codex|r v" .. ver .. " " .. L["chat.loaded"])
        -- end
        -- Restore floating panel if it was open before logout
        if isFloating and ClassCodexCharDB and ClassCodexCharDB.panelOpen then
            ns:UpdatePanel()
            panel:Show()
        end
        -- Re-render the docked panel's Talents tab when zone/encounter
        -- flips the effective Archon source. Talent pane and Compendium
        -- handle this themselves; the docked panel needs the same.
        if ns.RegisterArchonContextCallback then
            ns.RegisterArchonContextCallback(function()
                if panel:IsShown() and ns.getActiveTab and ns.getActiveTab() == "talents" then
                    ns:UpdatePanel()
                end
            end)
        end
        eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        if widgetContainer then
            eventFrame:UnregisterEvent("ADDON_LOADED")
        end

    elseif event == "PLAYER_SPECIALIZATION_CHANGED" and arg1 == "player" then
        local perSpec = GetPerSpecState()
        if perSpec then
            local oldHero = perSpec.heroTalent
            perSpec.heroTalent = nil
            local newHero = GetActiveHeroTalentName()
            if oldHero and oldHero ~= newHero then
                print("|cff00ccffClass Codex:|r " .. L["chat.switched_to"]:format(newHero or "auto-detect"))
            end
        end
        currentHeroTalent = nil
        cachedRanks = nil
        if panel:IsShown() then ns:UpdatePanel() end

    elseif event == "TRAIT_CONFIG_UPDATED" then
        local perSpec = GetPerSpecState()
        if perSpec then perSpec.heroTalent = nil end
        currentHeroTalent = nil
        cachedRanks = nil
        if panel:IsShown() then ns:UpdatePanel() end

    elseif event == "COMBAT_RATING_UPDATE" or event == "UNIT_STATS" then
        -- Cheap path: only re-render when the Stats tab is visible. Other
        -- tabs don't display live ratings so they don't need to repaint.
        if panel:IsShown() and activeTab == "stats" then
            ns:UpdatePanel()
        end

    elseif event == "PLAYER_EQUIPMENT_CHANGED" or event == "BAG_UPDATE_DELAYED" then
        -- Stats tab needs equipment-driven rating updates; BiS and
        -- Trinkets tabs need their "owned" row tint refreshed when
        -- bags/equipped slots change. Other tabs don't reflect either.
        if panel:IsShown() and (activeTab == "stats" or activeTab == "bis" or activeTab == "trinkets") then
            ns:UpdatePanel()
        end

    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        if panel:IsShown() and activeTab == "stats" then
            ns:UpdatePanel()
        end
    end
end)

-------------------------------------------------------------------------------
-- Slash Commands
-------------------------------------------------------------------------------

SLASH_CLASSCODEX1 = "/cc"
SLASH_CLASSCODEX2 = "/classcodex"
SlashCmdList["CLASSCODEX"] = function(msg)
    msg = msg:lower():trim()
    if msg == "toggle" or msg == "" then
        if isFloating then
            if panel:IsShown() then
                panel:Hide(); ClassCodexCharDB.panelOpen = false
            else
                ns:UpdatePanel(); FadeIn(panel); ClassCodexCharDB.panelOpen = true
            end
        elseif CharacterFrame:IsShown() then
            if panel:IsShown() then
                panel:Hide(); ClassCodexCharDB.panelOpen = false
            else
                ns:UpdatePanel(); FadeIn(panel); ClassCodexCharDB.panelOpen = true
            end
        else
            ToggleCharacter("PaperDollFrame"); ClassCodexCharDB.panelOpen = true
        end
    elseif msg == "float" then
        if isFloating then DockPanel(); print("|cff00ccffClass Codex:|r " .. L["chat.mode_docked"])
        else FloatPanel(); print("|cff00ccffClass Codex:|r " .. L["chat.mode_floating"]) end
        if panel:IsShown() then ns:UpdatePanel() end
    elseif msg == "settings" then
        if ns.settingsCategory then Settings.OpenToCategory(ns.settingsCategory:GetID()) end
    elseif msg == "reset" then
        ClassCodexCharDB.floating = false
        ClassCodexCharDB.floatX = nil
        ClassCodexCharDB.floatY = nil
        ClassCodexCharDB.minimized = false
        isFloating = false; isMinimized = false
        DockPanel()
        minimizeBtn:SetNormalTexture("Interface\\Buttons\\UI-Panel-CollapseButton-Up")
        print("|cff00ccffClass Codex:|r " .. L["chat.mode_reset"])
        if panel:IsShown() then ns:UpdatePanel() end
    elseif msg == "compendium" then
        if ns.OpenCompendium then ns:OpenCompendium()
        else print("|cff00ccffClass Codex:|r " .. L["chat.compendium_not_available"]) end
    elseif msg == "dock" then
        if ClassCodexDB then
            ClassCodexDB.dockLoadoutEnabled = not ClassCodexDB.dockLoadoutEnabled
        end
        if ns.UpdateLoadoutDockVisibility then ns.UpdateLoadoutDockVisibility() end
    elseif msg == "minimap" then
        if ns.LDBIcon then
            local db = ClassCodexDB.minimap
            if db.hide then
                db.hide = false
                ClassCodexDB.showMinimapButton = true
                ns.LDBIcon:Show("ClassCodex")
                print("|cff00ccffClass Codex:|r " .. L["chat.minimap_shown"])
            else
                db.hide = true
                ClassCodexDB.showMinimapButton = false
                ns.LDBIcon:Hide("ClassCodex")
                print("|cff00ccffClass Codex:|r " .. L["chat.minimap_hidden"])
            end
        else
            print("|cff00ccffClass Codex:|r " .. L["chat.minimap_not_available"])
        end
    elseif msg == "inspectdump" then
        if ns.DumpInspectState then
            ns.DumpInspectState()
        else
            print("|cff00ccffClass Codex:|r inspect dump unavailable.")
        end
    elseif msg == "help" then
        print("|cff00ccffClass Codex|r commands:")
        print("  /cc - Toggle panel")
        print("  /cc float - Toggle float/dock")
        print("  /cc compendium - Open compendium")
        print("  /cc settings - Open settings")
        print("  /cc minimap - Toggle minimap button")
        print("  /cc reset - Reset position")
        print("  /cc inspectdump - Print inspect-mode diagnostics")
    else
        print("|cff00ccffClass Codex:|r " .. L["chat.unknown_command"])
    end
end
