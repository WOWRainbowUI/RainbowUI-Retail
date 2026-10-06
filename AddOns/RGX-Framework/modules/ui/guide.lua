-- One-page, in-game entry point to RGX-Framework. RGX-Hello remains the
-- runnable example and visual test suite; this page is a compact field guide.
local addonName, RGX = ...

local function AddLine(UI, card, text)
    local label = UI:CreateLabel(card.content, {
        text = text, size = "normal", color = "normal", width = 292,
    })
    card.flow:Add(label)
end

local function BuildGuide(content)
    local UI = RGX:GetUI()
    local left, right = UI:CreateColumns(content, 2, { card = false, gap = 8 })

    -- Sections read like a book: opener, the model, what ships today, then
    -- current runtime facts from the actual loaded framework (not docs text).

    -- FIRST: the operator-facing theme controls (the coolest options lead).
    local Design = RGX:GetDesign()
    local theme = UI:CreateCard(left, { title = "Theme" })
    if Design and Design.THEME_PRESETS then
        local Drops = _G.RGXDropdowns
        if Drops and type(Drops.CreateNestedDropdown) == "function" then
            local items = {}
            for name in pairs(Design.THEME_PRESETS) do items[#items + 1] = { text = name, value = name } end
            table.sort(items, function(a, b) return a.value < b.value end)
            local themeDD = Drops:CreateNestedDropdown(theme.content, {
                label = "Main color",
                width = 300, buttonWidth = 290, triggerStyle = "retail",
                value = Design:GetThemePreset() or "cyan",
                items = items,
                onChange = function(value)
                    if Design:SetThemePreset(value) then
                        RGX.db.themePreset = value
                    end
                end,
            })
            if themeDD then
                themeDD:SetPoint("TOPLEFT", 8, -8)
                themeDD:SetPoint("TOPRIGHT", theme.content, "TOPRIGHT", -8, -8)
            end
        end
        local corners = UI:CreateButtonGroup(theme.content, { "Rounded", "Square" },
            { buttonWidth = 100, height = 22 })
        corners:SetPoint("TOPLEFT", 8, -52)
        local function UpdateCornerButtons()
            local square = Design.cornerStyle == "square"
            corners.buttons[1]:SetAlpha(square and 0.6 or 1)
            corners.buttons[2]:SetAlpha(square and 1 or 0.6)
        end
        UpdateCornerButtons()
        corners.buttons[1]:SetScript("OnClick", function()
            Design:SetCornerStyle("rounded")
            RGX.db.cornerStyle = "rounded"
            UpdateCornerButtons()
        end)
        corners.buttons[2]:SetScript("OnClick", function()
            Design:SetCornerStyle("square")
            RGX.db.cornerStyle = "square"
            UpdateCornerButtons()
        end)
        local note = UI:CreateLabel(theme.content, {
            text = "Applies to every RGX panel; reload to re-skin already-open windows.",
            size = "small", color = "muted", width = 292,
        })
        theme.flow:AddSpacer(74)
        theme.flow:Add(note)
    end
    theme:AutoHeight()

    local about = UI:CreateCard(left, { title = "About RGX-Framework", above = nil })
    about:ClearAllPoints()
    about:SetPoint("TOPLEFT", theme, "BOTTOMLEFT", 0, -8)
    about:SetPoint("TOPRIGHT", theme, "BOTTOMRIGHT", 0, -8)
    AddLine(UI, about, "One shared foundation for the RGX Mods suite. Addons depend on it once and inherit events, timers, profiles, options, and safety boundaries instead of rebuilding them.")
    AddLine(UI, about, "The design goal is to make common addon bugs unrepresentable at the consumer boundary rather than fixed repeatedly in every product.")
    AddLine(UI, about, "Feature content stays in the addon; reusable plumbing belongs here.")
    about:AutoHeight()

    local runtime = UI:CreateCard(left, { title = "This install" })
    runtime:ClearAllPoints()
    runtime:SetPoint("TOPLEFT", about, "BOTTOMLEFT", 0, -8)
    runtime:SetPoint("TOPRIGHT", about, "BOTTOMRIGHT", 0, -8)    local version = (RGX.GetMetadata and RGX:GetMetadata(addonName, "Version")) or RGX.version or "unknown"
    local modules = RGX.GetLoadedModules and RGX:GetLoadedModules() or {}
    AddLine(UI, runtime, "Framework version: " .. tostring(version))
    AddLine(UI, runtime, "Loaded modules: " .. tostring(#modules) .. (modules[1] and (" (" .. table.concat(modules, ", ") .. ")") or ""))
    AddLine(UI, runtime, "Login messages: " .. (RGX:IsLoginMessagesEnabled() and "on (/rgx login off to disable)" or "off"))
    runtime:AutoHeight()

    local credits = UI:CreateCard(left, { title = "Credits & resources" })
    credits:ClearAllPoints()
    credits:SetPoint("TOPLEFT", runtime, "BOTTOMLEFT", 0, -8)
    credits:SetPoint("TOPRIGHT", runtime, "BOTTOMRIGHT", 0, -8)
    AddLine(UI, credits, "RGX-Framework by RGX Mods. Modular addon infrastructure for WoW.")
    AddLine(UI, credits, "Docs: github.com/RGXMods/RGX-Framework")
    AddLine(UI, credits, "RGX-Hello provides a complete example and visual controls tour.")
    credits:AutoHeight()

    local build = UI:CreateCard(right, { title = "Build with RGX" })
    AddLine(UI, build, 'TOC: add "RequiredDeps: RGX-Framework".')
    AddLine(UI, build, 'Start: RGXAddon "MyAddon" { db = { enabled = true }, slash = "myaddon" }.')
    AddLine(UI, build, "Controls: RGXUI toggles, sliders, colors, dropdowns, cards and pages; settings bind to the RGX database.")
    build:AutoHeight()

    local modulesCard = UI:CreateCard(right, { title = "Modules" })
    modulesCard:ClearAllPoints()
    modulesCard:SetPoint("TOPLEFT", build, "BOTTOMLEFT", 0, -8)
    modulesCard:SetPoint("TOPRIGHT", build, "BOTTOMRIGHT", 0, -8)
    AddLine(UI, modulesCard, "Database, events, timers, messages and combat-safe operations.")
    AddLine(UI, modulesCard, "UI, design, fonts, dropdowns, textures, colors and minimap.")
    AddLine(UI, modulesCard, "Quest, loot, pet battle, reputation, sound and other game integrations.")
    modulesCard:AutoHeight()

    local debugCard = UI:CreateCard(right, { title = "Debug & help" })
    debugCard:ClearAllPoints()
    debugCard:SetPoint("TOPLEFT", modulesCard, "BOTTOMLEFT", 0, -8)
    debugCard:SetPoint("TOPRIGHT", modulesCard, "BOTTOMRIGHT", 0, -8)
    AddLine(UI, debugCard, "/rgx modules - inspect available modules")
    AddLine(UI, debugCard, "/rgx debug - toggle framework diagnostics")
    AddLine(UI, debugCard, "/rgx dbtest - check profile persistence")
    AddLine(UI, debugCard, "/rgxvisual - RGX-Hello's visual suite (if installed)")
    debugCard:AutoHeight()
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
        subtitle = "Theme, help, docs and about",
        icon = "Interface\\AddOns\\RGX-Framework\\media\\logo.tga",
        author = "RGX Mods",
        website = "github.com/RGXMods/RGX-Framework",
        content = BuildGuide,
        registerInSettings = false,
    })
end, "RGX_GUIDE_PANEL")
