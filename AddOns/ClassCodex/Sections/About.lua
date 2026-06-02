local _, ns = ...
ns.Sections = ns.Sections or {}

local L = ns.L

local About = {}
ns.Sections.About = About

-------------------------------------------------------------------------------
-- Button factory (also used by Supporters for its Patreon button)
-------------------------------------------------------------------------------

local function CreateAboutButton(parent, label, bgR, bgG, bgB, borderR, borderG, borderB)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
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
        local resolved = type(url) == "function" and url() or url
        if ns.ShowCopyPopup then ns.ShowCopyPopup(resolved, btn) end
    end)
end

-- Exposed for any future callers that need the same backdrop button style.
About.CreateButton = CreateAboutButton
About.SetCopyOnClick = SetCopyOnClick

-------------------------------------------------------------------------------
-- Panel surface (Compendium has no About tab)
-------------------------------------------------------------------------------

local panel = {}

-- opts.parent (contentFrame), opts.contentWidth (text wrap width),
-- opts.version (addon version string).
function About.InitPanel(opts)
    panel.parent = opts.parent

    -- Title row
    panel.title = CreateFrame("Frame", nil, opts.parent)
    panel.title:SetHeight(ns.SECTION_HEADER_HEIGHT)
    local titleText = panel.title:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", 2, 0)
    titleText:SetText(L["about.title"]:format(opts.version or "?"))
    titleText:SetTextColor(1, 0.82, 0)
    panel.title:Hide()

    -- Content (description + slash hint)
    panel.content = CreateFrame("Frame", nil, opts.parent)
    panel.content:SetHeight(1)
    panel.content:Hide()

    local desc = panel.content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    desc:SetPoint("TOPLEFT", 2, 0)
    desc:SetWidth(opts.contentWidth)
    desc:SetJustifyH("LEFT"); desc:SetWordWrap(true); desc:SetNonSpaceWrap(true)
    desc:SetText(L["about.description"])

    local slash = panel.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    slash:SetPoint("LEFT", desc, "LEFT", 0, 0)
    slash:SetPoint("TOP", desc, "BOTTOM", 0, -10)
    slash:SetWidth(opts.contentWidth)
    slash:SetJustifyH("LEFT")
    slash:SetTextColor(0.5, 0.5, 0.5)
    slash:SetText(L["about.help_hint"])
    panel.lastChild = slash

    -- Settings button (dropdown style)
    panel.settingsBtn = CreateAboutButton(opts.parent,
        "|TInterface\\Buttons\\UI-OptionsButton:12:12:0:0|t  " .. L["compendium.open_settings"])
    panel.settingsBtn:SetScript("OnClick", function()
        if Settings and Settings.OpenToCategory and ns.settingsCategory then
            Settings.OpenToCategory(ns.settingsCategory:GetID())
        end
    end)

    -- Compendium button
    panel.compendiumBtn = CreateAboutButton(opts.parent,
        "|TInterface\\Icons\\INV_Misc_Book_09:12:12:0:0|t  " .. L["compendium.open_compendium"])
    panel.compendiumBtn:SetScript("OnClick", function()
        if ns.OpenCompendium then ns:OpenCompendium() end
    end)
    ns.aboutCompendiumBtn = panel.compendiumBtn

    -- Discord button (blurple)
    panel.discordBtn = CreateAboutButton(opts.parent,
        "|TInterface\\ChatFrame\\UI-ChatIcon-Chat-Up:12:12:0:0|t  Join Discord — Bugs, Feedback & Help",
        0.34, 0.40, 0.95, 0.34, 0.40, 0.95)
    SetCopyOnClick(panel.discordBtn, "https://discord.gg/WY7HQaVkRw")

    -- Patreon button (coral) — also shared with the Supporters tab
    local patreonLabel = "|TInterface\\Icons\\Spell_Holy_PrayerOfHealing:12:12:0:0|t  " .. L["about.support_patreon"]
    panel.patreonBtn = CreateAboutButton(opts.parent, patreonLabel,
        0.6, 0.25, 0.20, 0.98, 0.41, 0.33)
    SetCopyOnClick(panel.patreonBtn, "https://www.patreon.com/classcodex")

    if ns.Sections.Supporters and ns.Sections.Supporters.SetPatreonButton then
        local supPatreon = CreateAboutButton(opts.parent, patreonLabel,
            0.6, 0.25, 0.20, 0.98, 0.41, 0.33)
        SetCopyOnClick(supPatreon, "https://www.patreon.com/classcodex")
        ns.Sections.Supporters.SetPatreonButton(supPatreon)
    end

    -- Data buttons (Wowhead / Icy Veins / Archon) — neutral chrome
    panel.dataBtn = CreateAboutButton(opts.parent,
        "|TInterface\\AddOns\\ClassCodex\\Textures\\wowhead:12:12:0:0|t  Wowhead Data")
    SetCopyOnClick(panel.dataBtn, function()
        local specData = ns.GetSpecData and ns.GetSpecData()
        return specData and specData.sourceUrl or "https://www.wowhead.com"
    end)

    panel.icyVeinsBtn = CreateAboutButton(opts.parent,
        "|TInterface\\AddOns\\ClassCodex\\Textures\\icyveins:12:12:0:0|t  Icy Veins (BiS Gear) Data")
    SetCopyOnClick(panel.icyVeinsBtn, function()
        local classToken = select(2, UnitClass("player"))
        local specKey = ns.GetSpecKey and ns.GetSpecKey() or nil
        local spec = specKey and (specKey:match("-(.+)") or specKey)
        if classToken and spec and ns.GetIcyVeinsSpecData then
            local ivData = ns:GetIcyVeinsSpecData(classToken, spec)
            if ivData then return ivData.sourceUrl end
        end
        return "https://www.icy-veins.com"
    end)

    panel.archonBtn = CreateAboutButton(opts.parent,
        "|TInterface\\AddOns\\ClassCodex\\Textures\\archon:12:12:0:0|t  Archon (Per-Encounter Builds) Data")
    SetCopyOnClick(panel.archonBtn, function()
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

    -- Separators are lazily created in LayoutPanel (matches the original
    -- inline-creation flow so re-renders are cheap).
    panel.separators = {}
end

local function MakeSeparator()
    local sep = panel.parent:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetColorTexture(0.3, 0.3, 0.3, 0.6)
    return sep
end

local function GetSep(key)
    if not panel.separators[key] then
        panel.separators[key] = MakeSeparator()
    end
    return panel.separators[key]
end

-- y = top offset; opts.parent + opts.inset
function About.LayoutPanel(y, opts)
    local inset = opts.inset

    panel.title:Show()
    panel.title:ClearAllPoints()
    panel.title:SetPoint("TOPLEFT", opts.parent, "TOPLEFT", inset, y)
    panel.title:SetPoint("RIGHT", opts.parent, "RIGHT", -inset, 0)
    y = y - ns.SECTION_HEADER_HEIGHT

    panel.content:Show()
    panel.content:ClearAllPoints()
    panel.content:SetPoint("TOPLEFT", opts.parent, "TOPLEFT", inset, y)
    panel.content:SetPoint("RIGHT", opts.parent, "RIGHT", -inset, 0)
    local lastBottom = panel.lastChild and panel.lastChild:GetBottom()
    local contentTop = panel.content:GetTop()
    local contentH = (lastBottom and contentTop) and (contentTop - lastBottom) or 200
    panel.content:SetHeight(contentH)
    y = y - contentH - 34

    local function placeSeparator(key)
        local sep = GetSep(key)
        y = y - 4
        sep:ClearAllPoints()
        sep:SetPoint("TOPLEFT", opts.parent, "TOPLEFT", inset, y)
        sep:SetPoint("RIGHT", opts.parent, "RIGHT", -inset, 0)
        sep:Show()
        y = y - 7
    end

    local function placeButton(btn)
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", opts.parent, "TOPLEFT", inset, y)
        btn:SetPoint("RIGHT", opts.parent, "RIGHT", -inset, 0)
        btn:Show()
        y = y - 28
    end

    placeSeparator("top")
    placeButton(panel.compendiumBtn)
    placeButton(panel.settingsBtn)
    placeSeparator("bottom")
    placeButton(panel.dataBtn)
    placeButton(panel.icyVeinsBtn)
    placeButton(panel.archonBtn)
    placeSeparator("social")
    placeButton(panel.patreonBtn)
    placeButton(panel.discordBtn)

    return y
end

function About.HidePanel()
    if not panel.title then return end
    panel.title:Hide()
    panel.content:Hide()
    panel.discordBtn:Hide()
    panel.patreonBtn:Hide()
    panel.dataBtn:Hide()
    panel.icyVeinsBtn:Hide()
    panel.archonBtn:Hide()
    panel.compendiumBtn:Hide()
    panel.settingsBtn:Hide()
    for _, sep in pairs(panel.separators or {}) do sep:Hide() end
end
