-- One-page, in-game entry point to RGX-Framework. RGX-Hello remains the
-- runnable example and visual test suite; this page is a compact field guide.
local addonName, RGX = ...

local function AddLine(UI, card, text)
    -- wrap, not a fixed width: the row takes the card's width, so the page fills the panel.
    local label = UI:CreateLabel(card.content, {
        text = text, size = "normal", color = "normal", wrap = true,
    })
    card.flow:Add(label, { fill = true })
end

-- The global theme controls (main color, interface style) change the framework's shared theme, which
-- only addons that build under it follow. Every other RGX addon paints its own brand, so for them the controls
-- would do nothing. Show them only when one of the addons that follow the global theme is loaded.
local THEME_CONSUMERS = { "BLU", "BLU_Classic", "BLU_Forever", "SimpleQuestPlates", "SimpleQuestPlates_Classic",
    "RGXProfessions", "RGXQoL" }

local function ThemeConsumerLoaded()
    local isLoaded = (_G.C_AddOns and _G.C_AddOns.IsAddOnLoaded) or _G.IsAddOnLoaded
    if type(isLoaded) ~= "function" then return false end
    for _, name in ipairs(THEME_CONSUMERS) do
        local ok, loaded = pcall(isLoaded, name)
        if ok and loaded then return true end
    end
    return false
end

-- One page of the settings panel: page = "about", "build" or "theme".
local function BuildGuide(content, page)
    local UI = RGX:GetUI()
    -- Two columns that split the page between them, so every page's cards fit without scrolling. Rows wrap to
    -- their column's width.
    local left, right = UI:CreateColumns(content, 2, { card = false, gap = 8 })

    -- Sections read like a book: opener, the model, what ships today, then
    -- current runtime facts from the actual loaded framework (not docs text).

    -- FIRST (when a theme-following addon is loaded): the operator-facing theme controls.
    local Design = RGX:GetDesign()
    local theme = page == "theme" and ThemeConsumerLoaded() and UI:CreateCard(left, { title = "Change framework addon theme options" }) or nil
    if theme and Design and Design.THEME_PRESETS then
        -- The framework theme is optional: with this off the saved colour and style are not applied
        -- at login and addons keep their own look.
        local overrideSwitch = UI:CreateSwitch(theme.content, {
            label = "Beta: override every RGX addon's theme",
            storage = RGX.db, key = "themeOverride", default = false,
            onChange = function(on)
                if on then
                    -- Apply the saved choices now, so windows built from here on use them.
                    if RGX.db.style then Design:SetStyle(RGX.db.style) end
                    if Design.ApplyOverrideTheme then Design:ApplyOverrideTheme(RGX.db)
                    elseif RGX.db.themePreset and Design.SetThemePreset then Design:SetThemePreset(RGX.db.themePreset) end
                else
                    Design:SetStyle("framework")
                    if Design.SetThemePreset then Design:SetThemePreset("cyan") end
                end
                -- Open windows follow at once.
                if Design.NotifyThemeChanged then Design:NotifyThemeChanged() end
            end,
        })
        theme.flow:Add(overrideSwitch, { fill = true })
        local Drops = _G.RGXDropdowns
        if Drops and type(Drops.CreateNestedDropdown) == "function" then
            local items = {}
            for name in pairs(Design.THEME_PRESETS) do items[#items + 1] = { text = name, value = name } end
            table.sort(items, function(a, b) return a.value < b.value end)
            local themeDD = Drops:CreateNestedDropdown(theme.content, {
                label = "Main color",
                width = 300, buttonWidth = 290, triggerStyle = "retail",
                value = RGX.db.themePreset or "cyan",
                items = items,
                onChange = function(value)
                    -- Saved always; applied live only while the override is on (off means addons keep their own).
                    if Design.THEME_PRESETS[value] then
                        RGX.db.themePreset = value
                        -- A preset is a fresh pair: it replaces the custom primary and secondary picks.
                        RGX.db.themePrimary, RGX.db.themeSecondary = nil, nil
                        if theme.RefreshColors then theme.RefreshColors() end
                        if RGX.db.themeOverride == true then
                            Design:SetThemePreset(value)
                            if Design.NotifyThemeChanged then Design:NotifyThemeChanged() end
                        end
                    end
                end,
            })
            if themeDD then theme.flow:Add(themeDD, { fill = true }) end
        end
        -- Primary and secondary colour: the framework colour picker, starting from the chosen preset's pair.
        if type(UI.CreateColorPicker) == "function" then
            local function presetColor(which)
                local pair = Design.GetOverrideTheme and Design:GetOverrideTheme({ themePreset = RGX.db.themePreset }) or {}
                local c = pair[which] or { 1, 1, 1 }
                return { r = c[1], g = c[2], b = c[3] }
            end
            local function applyColors()
                if RGX.db.themeOverride == true then
                    if Design.ApplyOverrideTheme then Design:ApplyOverrideTheme(RGX.db) end
                    if Design.NotifyThemeChanged then Design:NotifyThemeChanged() end
                end
            end
            local pickers = {}
            for _, spec in ipairs({ { key = "themePrimary", which = "primary", label = "Primary color" },
                                    { key = "themeSecondary", which = "accent", label = "Secondary color" } }) do
                -- The swatch shows the custom pick, or the preset's colour while none is set.
                local view = setmetatable({}, {
                    __index = function(_, k) if k == spec.key then return RGX.db[spec.key] or presetColor(spec.which) end end,
                    __newindex = function(_, k, v) if k == spec.key then RGX.db[spec.key] = v end end,
                })
                local picker = UI:CreateColorPicker(theme.content, {
                    label = spec.label, storage = view, key = spec.key,
                    default = presetColor(spec.which),
                    onChange = applyColors,
                })
                if picker then
                    pickers[#pickers + 1] = picker
                    theme.flow:Add(picker, { fill = true })
                end
            end
            theme.RefreshColors = function()
                for _, picker in ipairs(pickers) do if picker.Refresh then picker.Refresh() end end
            end
        end
        if Design and Design.STYLES then
            local Drops = _G.RGXDropdowns
            if Drops and type(Drops.CreateNestedDropdown) == "function" then
                -- Canonical styles in their defined order (legacy aliases are not listed).
                local items = {}
                for _, name in ipairs(Design.STYLE_ORDER or {}) do
                    local style = Design.STYLES[name]
                    if style then
                        items[#items + 1] = { text = style.label or name, value = name }
                    end
                end
                local styleDD = Drops:CreateNestedDropdown(theme.content, {
                    label = "Interface style",
                    width = 300, buttonWidth = 290, triggerStyle = "retail",
                    value = (RGX.db.style and Design:ResolveStyle(RGX.db.style)) or "framework",
                    items = items,
                    onChange = function(value)
                        local id = Design:ResolveStyle(value)
                        if id then
                            RGX.db.style = id
                            if RGX.db.themeOverride == true then
                                Design:SetStyle(id)
                                if Design.NotifyThemeChanged then Design:NotifyThemeChanged() end
                            else
                                RGX:Print("Interface style saved. It applies while the theme override is on.")
                            end
                        end
                    end,
                })
                if styleDD then theme.flow:Add(styleDD, { fill = true }) end
            end
        end
        local note = UI:CreateLabel(theme.content, {
            text = "Beta, global override: while it is on, the colour and interface style replace the own look of every RGX addon that follows the framework theme. Off (the default), each addon keeps its own theme. Each style has its own shape: RGX Material Round is rounded, RGX Framework is square, WoW Classic and WoW Forever use the game's own frames. Open RGX windows change at once; Reload UI re-skins anything that does not.",
            size = "small", color = "muted", wrap = true,
        })
        theme.flow:Add(note, { fill = true })
        -- Already-built windows of every RGX addon only re-skin on a reload, so offer it right here.
        if type(Design.CreateButton) == "function" then
            local reload = Design:CreateButton(theme.content, "Reload UI", 120, 22)
            reload:SetScript("OnClick", function()
                if type(_G.ReloadUI) == "function" then _G.ReloadUI() end
            end)
            theme.flow:Add(reload)
        end
    end
    if theme then theme:AutoHeight() end

    if page == "about" then
        local about = UI:CreateCard(left, { title = "About RGX-Framework", above = nil })
        if theme then
            about:ClearAllPoints()
            about:SetPoint("TOPLEFT", theme, "BOTTOMLEFT", 0, -8)
            about:SetPoint("TOPRIGHT", theme, "BOTTOMRIGHT", 0, -8)
        end
        AddLine(UI, about, "One shared foundation for the RGX Mods suite. Addons depend on it once and inherit events, timers, profiles, options, and safety boundaries instead of rebuilding them.")
        AddLine(UI, about, "The design goal is to make common addon bugs unrepresentable at the consumer boundary rather than fixed repeatedly in every product.")
        AddLine(UI, about, "Feature content stays in the addon; reusable plumbing belongs here.")
        about:AutoHeight()

        local runtime = UI:CreateCard(left, { title = "This install" })
        runtime:ClearAllPoints()
        runtime:SetPoint("TOPLEFT", about, "BOTTOMLEFT", 0, -8)
        runtime:SetPoint("TOPRIGHT", about, "BOTTOMRIGHT", 0, -8)
        -- The version straight from the framework's TOC: a version field on a shared table can be another copy's.
        local getMeta = (_G.C_AddOns and _G.C_AddOns.GetAddOnMetadata) or _G.GetAddOnMetadata
        local okMeta, meta = false, nil
        if type(getMeta) == "function" then okMeta, meta = pcall(getMeta, "RGX-Framework", "Version") end
        local version = (okMeta and meta) or RGX.version or "unknown"
        local modules = RGX.GetLoadedModules and RGX:GetLoadedModules() or {}
        AddLine(UI, runtime, "Framework version: " .. tostring(version))
        AddLine(UI, runtime, "Loaded modules: " .. tostring(#modules) .. (modules[1] and (" (" .. table.concat(modules, ", ") .. ")") or ""))
        AddLine(UI, runtime, "Login messages: " .. (RGX:IsLoginMessagesEnabled() and "on (/rgx login off to disable)" or "off"))
        runtime:AutoHeight()

        local credits = UI:CreateCard(right, { title = "Credits & resources" })
        AddLine(UI, credits, "RGX-Framework by RGX Mods. Modular addon infrastructure for WoW.")
        AddLine(UI, credits, "Docs: github.com/RGXMods/RGX-Framework")
        AddLine(UI, credits, "RGX-Hello provides a complete example and visual controls tour.")
        credits:AutoHeight()
    end

    if page == "build" then
        local build = UI:CreateCard(left, { title = "Build with RGX" })
        AddLine(UI, build, 'TOC: add "RequiredDeps: RGX-Framework".')
        AddLine(UI, build, 'Start: RGXAddon "MyAddon" { db = { enabled = true }, slash = "myaddon" }.')
        AddLine(UI, build, "Controls: RGXUI toggles, sliders, colors, dropdowns, cards and pages; settings bind to the RGX database.")
        build:AutoHeight()

        local modulesCard = UI:CreateCard(left, { title = "Modules" })
        modulesCard:ClearAllPoints()
        modulesCard:SetPoint("TOPLEFT", build, "BOTTOMLEFT", 0, -8)
        modulesCard:SetPoint("TOPRIGHT", build, "BOTTOMRIGHT", 0, -8)
        AddLine(UI, modulesCard, "Database, events, timers, messages and combat-safe operations.")
        AddLine(UI, modulesCard, "UI, design, fonts, dropdowns, textures, colors and minimap.")
        AddLine(UI, modulesCard, "Quest, loot, pet battle, reputation, sound and other game integrations.")
        modulesCard:AutoHeight()

        local debugCard = UI:CreateCard(right, { title = "Debug & help" })
        AddLine(UI, debugCard, "/rgx modules - inspect available modules")
        AddLine(UI, debugCard, "/rgx debug - toggle framework diagnostics")
        AddLine(UI, debugCard, "Database tests run via CI, not in-game")
        AddLine(UI, debugCard, "/rgxvisual - RGX-Hello's visual suite (if installed)")
        debugCard:AutoHeight()
    end
end

function RGX:OpenDefinitionEditor()
    local UI = self:GetUI()
    if type(self:GetDB()) ~= "table" then return false end
    if not self.definitionEditorPanel then
        self.definitionEditorPanel = UI:CreateOptionsPanel({
            addonName = addonName, title = "RGX definition editor", subtitle = "Source development slice",
            width = 760, height = 600, registerInSettings = false, openInSettings = false,
            content = function(content)
                local db = self:GetDB()
                local definition = db.definitionExample
                if type(definition) == "nil" then
                    definition = { version = 1, kind = "label", id = "example", text = "Hello RGX",
                        enabled = true, x = 0, y = 0, scale = 100 }
                end
                local editor, err = UI:CreateDefinitionEditor(content, { definition = definition,
                    onSave = function(saved) db.definitionExample = saved end })
                if editor then editor:SetPoint("TOPLEFT", 10, -10)
                else UI:CreateLabel(content, { text = err or "Unsupported saved definition", width = 460 }):SetPoint("TOPLEFT", 10, -10) end
            end,
        })
    end
    return self.definitionEditorPanel:Open()
end

RGX:RegisterEvent("PLAYER_LOGIN", function()
    if RGX.guidePanel then return end
    local UI = RGX:GetUI()
    if not UI or type(UI.CreateOptionsPanel) ~= "function" then return end
    RGX.guidePanel = UI:CreateOptionsPanel({
        addonName = addonName,
        title = "RGX-Framework",
        subtitle = "Help, docs and about",
        icon = "Interface\\AddOns\\RGX-Framework\\media\\logo.tga",
        author = "RGX Mods",
        website = "github.com/RGXMods/RGX-Framework",
        tabs = (function()
            local tabs = {
                { text = "About", content = function(frame) BuildGuide(frame, "about") end },
                { text = "Build with RGX", content = function(frame) BuildGuide(frame, "build") end },
            }
            -- The global theme controls matter only to addons that follow the framework theme.
            if ThemeConsumerLoaded() then
                tabs[#tabs + 1] = { text = "Theme", content = function(frame) BuildGuide(frame, "theme") end }
            end
            return tabs
        end)(),
        registerInSettings = false,
        registerInSettings = true,
    })
end, "RGX_GUIDE_PANEL")
