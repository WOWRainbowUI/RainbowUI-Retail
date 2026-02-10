CustomRogueComboBarOptions = {
    name = "|cFFFFF569Custom Rogue Combo Point Bar|r",
    type = "group",
    args = {
        enableCustomComboBar = {
            name = "Enable Custom Combo Bar",
            desc = "Show the custom combo bar. Disable to use default PRD combo points.",
            type = "toggle",
            get = function() return CustomRogueComboBarDB.enabled ~= false end,
            set = function(_, val)
                CustomRogueComboBarDB.enabled = val
                if UpdateRogueComboBarEnabled then UpdateRogueComboBarEnabled() end
            end,
            order = 0.5,
        },
        comboPointWidth = {
            name = "Combo Point Width (per point)",
            desc = "Set the width of each combo point. If 'Total Bar Width' is set, this is ignored.",
            type = "range",
            min = 10, max = 100, step = 0.001,
            get = function() return CustomRogueComboBarDB.comboPointWidth end,
            set = function(_, val)
                CustomRogueComboBarDB.comboPointWidth = val
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 1,
        },
        totalWidth = {
            name = "Total Bar Width",
            desc = "Set the total width for all combo points combined. If set, points will auto-fit to this width.",
            type = "range",
            min = 60, max = 600, step = 0.1,
            get = function() return CustomRogueComboBarDB.totalWidth or 0 end,
            set = function(_, val)
                if val > 0 then
                    CustomRogueComboBarDB.totalWidth = val
                else
                    CustomRogueComboBarDB.totalWidth = nil
                end
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 1.5,
        },
        comboPointHeight = {
            name = "Combo Point Height",
            desc = "Set the height of each combo point.",
            type = "range",
            min = 10, max = 100, step = 0.001,
            get = function() return CustomRogueComboBarDB.comboPointHeight end,
            set = function(_, val)
                CustomRogueComboBarDB.comboPointHeight = val
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 2,
        },
        lock = {
            name = "Lock Bar",
            desc = "Lock or unlock the combo point bar for dragging.",
            type = "toggle",
            get = function() return CustomRogueComboBarDB.locked end,
            set = function(_, val) CustomRogueComboBarDB.locked = val end,
            order = 3,
        },
        anchorToPRD = {
            name = "Anchor to Personal Resource Display",
            desc = "Attach the combo bar to the PRD health or power bar.",
            type = "toggle",
            get = function() return CustomRogueComboBarDB.anchorToPRD end,
            set = function(_, val)
                CustomRogueComboBarDB.anchorToPRD = val
                if UpdateRogueComboBarSettings then UpdateRogueComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.2,
        },
        anchorTarget = {
            name = "Anchor Target",
            desc = "Choose which PRD bar to anchor to.",
            type = "select",
            values = { HEALTH = "Health Bar", POWER = "Power Bar" },
            get = function() return CustomRogueComboBarDB.anchorTarget or "HEALTH" end,
            set = function(_, val)
                CustomRogueComboBarDB.anchorTarget = val
                if UpdateRogueComboBarSettings then UpdateRogueComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.3,
            disabled = function() return not CustomRogueComboBarDB.anchorToPRD end,
        },
        anchorPosition = {
            name = "Anchor Position",
            desc = "Place above or below the selected PRD bar.",
            type = "select",
            values = { ABOVE = "Above", BELOW = "Below" },
            get = function() return CustomRogueComboBarDB.anchorPosition or "BELOW" end,
            set = function(_, val)
                CustomRogueComboBarDB.anchorPosition = val
                if UpdateRogueComboBarSettings then UpdateRogueComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.4,
            disabled = function() return not CustomRogueComboBarDB.anchorToPRD end,
        },
        anchorOffset = {
            name = "Anchor Offset",
            desc = "Vertical offset from the PRD bar when anchored.",
            type = "range",
            min = -100, max = 200, step = 1,
            get = function() return CustomRogueComboBarDB.anchorOffset or 10 end,
            set = function(_, val)
                CustomRogueComboBarDB.anchorOffset = val
                if UpdateRogueComboBarSettings then UpdateRogueComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.5,
            disabled = function() return not CustomRogueComboBarDB.anchorToPRD end,
        },
        x = {
            name = "X Position",
            desc = "Horizontal position when not anchored.",
            type = "range",
            min = -1000, max = 1000, step = 1,
            get = function() return CustomRogueComboBarDB.x or 0 end,
            set = function(_, val)
                CustomRogueComboBarDB.x = val
                if UpdateRogueComboBarSettings then UpdateRogueComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.6,
            disabled = function() return CustomRogueComboBarDB.anchorToPRD end,
        },
        y = {
            name = "Y Position",
            desc = "Vertical position when not anchored.",
            type = "range",
            min = -1000, max = 1000, step = 1,
            get = function() return CustomRogueComboBarDB.y or 0 end,
            set = function(_, val)
                CustomRogueComboBarDB.y = val
                if UpdateRogueComboBarSettings then UpdateRogueComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.7,
            disabled = function() return CustomRogueComboBarDB.anchorToPRD end,
        },
        comboPointBgColor = {
            name = "Combo Point Background Color",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomRogueComboBarDB.comboPointBgColor or {0, 0, 0, 0.5}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomRogueComboBarDB.comboPointBgColor = {r, g, b, a}
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 10,
        },
        chargedComboPointBgColor = {
            name = "Charged Combo Point Background",
            desc = "Background color for charged (critical) combo points.",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomRogueComboBarDB.chargedComboPointBgColor or {0.1, 0.3, 0.5, 0.7}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomRogueComboBarDB.chargedComboPointBgColor = {r, g, b, a}
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 98,
        },
        chargedComboPointColor = {
            name = "Charged Combo Point Color",
            desc = "Color for charged (critical) combo points.",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomRogueComboBarDB.chargedComboPointColor or {0.2, 0.6, 1, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomRogueComboBarDB.chargedComboPointColor = {r, g, b, a}
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 99,
        },
        gradientColoringEnabled = {
            name = "Enable Gradient Coloring",
            desc = "Override all combo points with a gradient between two colors.",
            type = "toggle",
            get = function() return CustomRogueComboBarDB.gradientColoringEnabled end,
            set = function(_, val)
                CustomRogueComboBarDB.gradientColoringEnabled = val
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 100,
        },
        gradientColorStart = {
            name = "Gradient Start Color",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomRogueComboBarDB.gradientColorStart
                if type(c) ~= "table" or not c[1] then c = {1, 0, 0, 1} end
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomRogueComboBarDB.gradientColorStart = {r, g, b, a}
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 101,
            disabled = function() return not CustomRogueComboBarDB.gradientColoringEnabled end,
        },
        gradientColorEnd = {
            name = "Gradient End Color",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomRogueComboBarDB.gradientColorEnd
                if type(c) ~= "table" or not c[1] then c = {1, 1, 0, 1} end
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomRogueComboBarDB.gradientColorEnd = {r, g, b, a}
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 102,
            disabled = function() return not CustomRogueComboBarDB.gradientColoringEnabled end,
        },
    },
}
for i = 1, 7 do
    CustomRogueComboBarOptions.args["comboPointFillColor"..i] = {
        name = "Combo Point "..i.." Color",
        type = "color",
        hasAlpha = true,
        get = function()
            local c = CustomRogueComboBarDB.comboPointFillColors[i] or {1, 0.7, 0.2, 1}
            return c[1], c[2], c[3], c[4]
        end,
        set = function(_, r, g, b, a)
            CustomRogueComboBarDB.comboPointFillColors[i] = {r, g, b, a}
            if UpdateComboPoints then UpdateComboPoints() end
        end,
        order = 20 + i,
    }
end
_G.CustomRogueComboBarOptions = CustomRogueComboBarOptions
