local _, ns = ...
local L = ns.L

-------------------------------------------------------------------------------
-- Settings panel registration (WoW Settings API)
--
-- One vertical category with section headers (the proven single-page pattern,
-- matching Void Chimes). Controls that only make sense in a sub-context use a
-- shown-predicate to appear/hide — e.g. the Loadout Dock's detail options are
-- hidden until the dock is enabled. Local `Add*` helpers close over the single
-- (category, layout) pair and collapse the RegisterAddOnSetting + callback
-- boilerplate. All DB variable names + defaults are unchanged, so existing
-- settings carry over.
-------------------------------------------------------------------------------

local WIDGET_DEFAULT_OFFSET_X = -1
local WIDGET_DEFAULT_OFFSET_Y = -148
local WIDGET_OFFSET_MIN = -500
local WIDGET_OFFSET_MAX = 500

local function fmtPlain(v) return tostring(v) end
local function fmtPercent(v) return v .. "%" end
local function fmtPixels(v) return v .. "px" end

function ns.RegisterSettings()
    local ok, err = pcall(function()
        local category, layout = Settings.RegisterVerticalLayoutCategory("Class Codex")

        -- Gate an initializer behind a predicate (hidden when it returns false).
        local function shownIf(init, pred)
            if pred and init and init.AddShownPredicate then init:AddShownPredicate(pred) end
            return init
        end

        local function header(label, pred)
            local init = CreateSettingsListSectionHeaderInitializer(label)
            shownIf(init, pred)
            layout:AddInitializer(init)
        end

        local function check(variable, name, tooltip, default, onChange, pred)
            local setting = Settings.RegisterAddOnSetting(
                category, variable, variable, ClassCodexDB, type(default), name, default)
            if onChange then
                Settings.SetOnValueChangedCallback(variable, function() onChange(ClassCodexDB[variable]) end)
            end
            shownIf(Settings.CreateCheckbox(category, setting, tooltip), pred)
        end

        local function dropdown(variable, name, tooltip, default, options, onChange, pred)
            local setting = Settings.RegisterAddOnSetting(
                category, variable, variable, ClassCodexDB, type(default), name, default)
            if onChange then
                Settings.SetOnValueChangedCallback(variable, function() onChange(ClassCodexDB[variable]) end)
            end
            shownIf(Settings.CreateDropdown(category, setting, function()
                local container = Settings.CreateControlTextContainer()
                for _, opt in ipairs(options) do container:Add(opt.value, opt.label) end
                return container:GetData()
            end, tooltip), pred)
        end

        local function slider(variable, name, tooltip, default, minV, maxV, step, fmt, onChange, pred)
            local setting = Settings.RegisterAddOnSetting(
                category, variable, variable, ClassCodexDB, Settings.VarType.Number, name, default)
            if onChange then Settings.SetOnValueChangedCallback(variable, function() onChange() end) end
            local opts = Settings.CreateSliderOptions(minV, maxV, step)
            opts:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, fmt or fmtPlain)
            shownIf(Settings.CreateSlider(category, setting, opts, tooltip), pred)
        end

        -- ===== General =====
        header(L["settings.header.general"])
        check("showMinimapButton", L["settings.label.minimap_button"],
            L["settings.tooltip.minimap_button"], true, function(val)
                if ns.LDBIcon then
                    ClassCodexDB.minimap.hide = not val
                    if val then ns.LDBIcon:Show("ClassCodex") else ns.LDBIcon:Hide("ClassCodex") end
                end
            end)
        check("showLoginMessage", L["settings.label.login_message"],
            L["settings.tooltip.login_message"], false)

        header(L["settings.header.talent_pane"])
        check("talentPaneEnabled", L["settings.label.talent_pane_show"],
            L["settings.tooltip.talent_pane_show"], true,
            function(val) if ns.SetTalentPaneEnabled then ns.SetTalentPaneEnabled(val) end end)

        header(L["settings.header.unit_menus"])
        check("unitMenuEnabled", L["settings.label.unit_menu_enabled"],
            L["settings.tooltip.unit_menu_enabled"], true)

        -- ===== Character Button ===== (reset via Shift+Right-click on the gear icon)
        header(L["settings.header.character_pane_button"])
        check("widgetLocked", L["settings.label.lock_button_position"],
            L["settings.tooltip.lock_button_position"], false,
            function() if ns.RefreshWidgetTooltip then ns.RefreshWidgetTooltip() end end)
        local function applyPos() if ns.ApplyWidgetPosition then ns.ApplyWidgetPosition() end end
        slider("widgetOffsetX", L["settings.label.horizontal_offset"],
            L["settings.tooltip.horizontal_offset"], WIDGET_DEFAULT_OFFSET_X,
            WIDGET_OFFSET_MIN, WIDGET_OFFSET_MAX, 1, fmtPlain, applyPos)
        slider("widgetOffsetY", L["settings.label.vertical_offset"],
            L["settings.tooltip.vertical_offset"], WIDGET_DEFAULT_OFFSET_Y,
            WIDGET_OFFSET_MIN, WIDGET_OFFSET_MAX, 1, fmtPlain, applyPos)

        -- ===== Tooltips =====
        header(L["settings.header.tooltips"])
        check("showTooltipBadges", L["settings.label.stat_priority_ranks"],
            L["settings.tooltip.stat_priority_ranks"], true)
        dropdown("tooltipFooterMode", L["settings.label.stat_priority_source_line"],
            L["settings.tooltip.bis_source"], 0, {
                { value = 0, label = L["settings.value.off"] },
                { value = 1, label = L["settings.value.always"] },
                { value = 2, label = L["settings.value.only_when_different"] },
            })
        dropdown("tooltipBisScope", L["settings.label.bis_scope"],
            L["settings.tooltip.bis_scope"], "all", {
                { value = "all", label = L["settings.value.bis_scope_all"] },
                { value = "group", label = L["settings.value.bis_scope_group"] },
                { value = "self", label = L["settings.value.bis_scope_self"] },
                { value = "off", label = L["settings.value.off"] },
            }, function() ns.InvalidateTooltipCache() end)
        dropdown("tooltipSourceStyle", L["settings.label.source_display"],
            L["settings.tooltip.source_display"], 1, {
                { value = 1, label = L["settings.value.icons"] },
                { value = 2, label = L["settings.value.labels"] },
                { value = 3, label = L["settings.value.both"] },
            }, function() ns.InvalidateTooltipCache() end)
        check("showUggBisTooltip", L["settings.label.ugg_bis"],
            L["settings.tooltip.ugg_bis"], true, ns.InvalidateTooltipCache)
        check("showIcyVeinsBisTooltip", L["settings.label.icy_veins_bis"],
            L["settings.tooltip.icy_veins_bis"], true, ns.InvalidateTooltipCache)
        check("showTrinketTooltip", L["settings.label.trinket_tier"],
            L["settings.tooltip.trinket_tier"], true, ns.InvalidateTooltipCache)

        -- ===== Panel =====
        header(L["settings.header.panel"])
        check("highlightOwnedGear", L["settings.label.highlight_owned"],
            L["settings.tooltip.highlight_owned"], true, function() ns.UpdatePanelIfVisible() end)
        slider("panelWidth", L["settings.label.panel_width"],
            L["settings.tooltip.panel_width"], 312, 260, 500, 10, fmtPixels,
            function() ns.UpdatePanelIfVisible() end)

        header(L["settings.header.crafting"])
        check("craftingTopPicksOnly", L["settings.label.crafting_top_picks_only"],
            L["settings.tooltip.crafting_top_picks_only"], true, function()
                if ns.UpdatePanel then ns:UpdatePanel() end
                if ns.UpdateCompendium then ns:UpdateCompendium() end
            end)

        -- Section visibility per panel mode. `prefix` ("dock"/"float") keys the
        -- DB variable and tooltip string; `mode` drives the live refresh.
        local function sections(prefix, mode)
            local function refresh() ns.UpdatePanelIfVisible(mode) end
            local function row(suffix, label, tipKey)
                check(prefix .. suffix, label, L["settings.tooltip." .. prefix .. "_" .. tipKey], true, refresh)
            end
            row("ShowStats", L["settings.label.show_stat_priority"], "show_stat_priority")
            row("ShowStatTargets", L["settings.label.show_stat_targets"], "show_stat_targets")
            row("ShowTalents", L["settings.label.show_talents"], "show_talents")
            row("ShowRotation", L["settings.label.show_rotation"], "show_rotation")
            row("ShowEnchants", L["settings.label.show_enchants"], "show_enchants")
            row("ShowGems", L["settings.label.show_gems"], "show_gems")
            row("ShowConsumables", L["settings.label.show_consumables"], "show_consumables")
            row("ShowTrinkets", L["settings.label.show_trinkets"], "show_trinkets")
            row("ShowCrafts", L["settings.label.show_crafts"], "show_crafts")
            row("ShowEmbellishments", L["settings.label.show_embellishments"], "show_embellishments")
            row("ShowBisGear", L["settings.label.show_bis_gear"], "show_bis_gear")
        end
        header(L["settings.header.docked_panel"])
        sections("dock", "docked")
        header(L["settings.header.floating_panel"])
        sections("float", "floating")

        -- ===== Loadout Dock ===== (detail options hidden until the dock is on)
        local function dockOn() return ClassCodexDB and ClassCodexDB.dockLoadoutEnabled end
        local function refreshDock() if ns.RefreshLoadoutDock then ns.RefreshLoadoutDock() end end
        local function refreshVis() if ns.UpdateLoadoutDockVisibility then ns.UpdateLoadoutDockVisibility() end end
        header(L["settings.header.loadout_dock"])
        check("dockLoadoutEnabled", L["settings.label.show_loadout_dock"],
            L["settings.tooltip.show_loadout_dock"], false, refreshVis)
        check("dockLoadoutHideInCombat", L["settings.label.dock_hide_in_combat"],
            L["settings.tooltip.dock_hide_in_combat"], true, refreshVis, dockOn)
        check("dockLoadoutLocked", L["settings.label.dock_lock_position"],
            L["settings.tooltip.dock_lock_position"], false, nil, dockOn)
        check("dockLoadoutShowSpecIcon", L["settings.label.dock_show_spec_icon"],
            L["settings.tooltip.dock_show_spec_icon"], true, refreshDock, dockOn)
        check("dockLoadoutShowHeroIcon", L["settings.label.dock_show_hero_icon"],
            L["settings.tooltip.dock_show_hero_icon"], true, refreshDock, dockOn)
        check("dockLoadoutShowSaved", L["settings.label.dock_show_saved"],
            L["settings.tooltip.dock_show_saved"], true, nil, dockOn)
        check("dockLoadoutShowCodexBuilds", L["settings.label.dock_show_codexbuilds"],
            L["settings.tooltip.dock_show_codexbuilds"], true, nil, dockOn)
        check("dockLoadoutShowUgg", L["settings.label.dock_show_ugg"],
            L["settings.tooltip.dock_show_ugg"], true, nil, dockOn)
        check("dockLoadoutShowIcyVeins", L["settings.label.dock_show_icyveins"],
            L["settings.tooltip.dock_show_icyveins"], true, refreshDock, dockOn)
        slider("dockLoadoutOpacity", L["settings.label.dock_opacity"],
            L["settings.tooltip.dock_opacity"], 95, 0, 100, 5, fmtPercent,
            function() if ns.ApplyLoadoutDockOpacity then ns.ApplyLoadoutDockOpacity() end end, dockOn)
        check("dockLoadoutAutoWidth", L["settings.label.dock_auto_width"],
            L["settings.tooltip.dock_auto_width"], false, refreshDock, dockOn)
        slider("dockLoadoutWidth", L["settings.label.dock_width"],
            L["settings.tooltip.dock_width"], 200, 120, 400, 10, fmtPixels,
            function() if ns.ApplyLoadoutDockWidth then ns.ApplyLoadoutDockWidth() end end, dockOn)
        slider("dockLoadoutScale", L["settings.label.dock_scale"],
            L["settings.tooltip.dock_scale"], 100, 50, 200, 5, fmtPercent,
            function() if ns.ApplyLoadoutDockScale then ns.ApplyLoadoutDockScale() end end, dockOn)
        dropdown("dockLoadoutAlignment", L["settings.label.dock_alignment"],
            L["settings.tooltip.dock_alignment"], "LEFT", {
                { value = "LEFT", label = L["settings.value.left"] },
                { value = "CENTER", label = L["settings.value.center"] },
                { value = "RIGHT", label = L["settings.value.right"] },
            }, refreshDock, dockOn)
        check("dockLoadoutShowBorder", L["settings.label.dock_show_border"],
            L["settings.tooltip.dock_show_border"], true,
            function() if ns.ApplyLoadoutDockBorder then ns.ApplyLoadoutDockBorder() end end, dockOn)

        Settings.RegisterAddOnCategory(category)
        ns.settingsCategory = category
    end)

    -- Public helper used by the dock right-click menu and slash commands so
    -- callers don't need to know about the category internals.
    function ns.OpenSettings()
        if Settings and Settings.OpenToCategory and ns.settingsCategory then
            Settings.OpenToCategory(ns.settingsCategory:GetID())
        end
    end
    if not ok then
        print("|cffff0000Class Codex:|r " .. L["chat.settings_registration_failed"]:format(tostring(err)))
    end
end
