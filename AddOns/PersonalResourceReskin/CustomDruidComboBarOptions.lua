CustomDruidComboBarOptions = {
    name = "|cFFFF7C0ACustom Druid Combo Point Bar|r",
    type = "group",
    args = {
        enableCustomComboBar = {
            name = "Enable Custom Combo Bar",
            desc = "Show the custom combo bar. Disable to use default PRD combo points.",
            type = "toggle",
            get = function() return CustomDruidComboBarDB.enabled ~= false end,
            set = function(_, val)
                CustomDruidComboBarDB.enabled = val
                if UpdateDruidComboBarEnabled then UpdateDruidComboBarEnabled() end
            end,
            order = 0.5,
        },
        hideWhenMounted = {
            order = 1.5,
            type = "toggle",
            name = "Hide When Mounted",
            desc = "Hide the Combo Bar while mounted.",
            get = function() return CustomDruidComboBarDB.hideWhenMounted end,
            set = function(_, val)
                CustomDruidComboBarDB.hideWhenMounted = val
                if UpdateDruidComboBarEnabled then UpdateDruidComboBarEnabled() end
            end,
        },
        comboPointWidth = {
            name = "Combo Point Width (per point)",
            desc = "Set the width of each combo point. If 'Total Bar Width' is set, this is ignored.",
            type = "range",
            min = 10, max = 100, step = 0.001,
            get = function() return CustomDruidComboBarDB.comboPointWidth end,
            set = function(_, val)
                CustomDruidComboBarDB.comboPointWidth = val
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 1,
        },
        totalWidth = {
            name = "Total Bar Width",
            desc = "Set the total width for all combo points combined. If set, points will auto-fit to this width.",
            type = "range",
            min = 60, max = 600, step = 0.1,
            get = function() return CustomDruidComboBarDB.totalWidth or 0 end,
            set = function(_, val)
                if val > 0 then
                    CustomDruidComboBarDB.totalWidth = val
                else
                    CustomDruidComboBarDB.totalWidth = nil
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
            get = function() return CustomDruidComboBarDB.comboPointHeight end,
            set = function(_, val)
                CustomDruidComboBarDB.comboPointHeight = val
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 2,
        },
        lock = {
            name = "Lock Bar",
            desc = "Lock or unlock the combo point bar for dragging.",
            type = "toggle",
            get = function() return CustomDruidComboBarDB.locked end,
            set = function(_, val) CustomDruidComboBarDB.locked = val end,
            order = 3,
        },
        anchorToPRD = {
            name = "Anchor to Personal Resource Display",
            desc = "Attach the combo bar to the PRD health or power bar.",
            type = "toggle",
            get = function() return CustomDruidComboBarDB.anchorToPRD end,
            set = function(_, val)
                CustomDruidComboBarDB.anchorToPRD = val
                if UpdateDruidComboBarSettings then UpdateDruidComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.2,
        },
        anchorTarget = {
            name = "Anchor Target",
            desc = "Choose which PRD bar to anchor to.",
            type = "select",
            values = { HEALTH = "Health Bar", POWER = "Power Bar" },
            get = function() return CustomDruidComboBarDB.anchorTarget or "HEALTH" end,
            set = function(_, val)
                CustomDruidComboBarDB.anchorTarget = val
                if UpdateDruidComboBarSettings then UpdateDruidComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.3,
            disabled = function() return not CustomDruidComboBarDB.anchorToPRD end,
        },
        anchorPosition = {
            name = "Anchor Position",
            desc = "Place above or below the selected PRD bar.",
            type = "select",
            values = { ABOVE = "Above", BELOW = "Below" },
            get = function() return CustomDruidComboBarDB.anchorPosition or "BELOW" end,
            set = function(_, val)
                CustomDruidComboBarDB.anchorPosition = val
                if UpdateDruidComboBarSettings then UpdateDruidComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.4,
            disabled = function() return not CustomDruidComboBarDB.anchorToPRD end,
        },
        anchorOffset = {
            name = "Anchor Offset",
            desc = "Vertical offset from the PRD bar when anchored.",
            type = "range",
            min = -100, max = 200, step = 1,
            get = function() return CustomDruidComboBarDB.anchorOffset or 10 end,
            set = function(_, val)
                CustomDruidComboBarDB.anchorOffset = val
                if UpdateDruidComboBarSettings then UpdateDruidComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.5,
            disabled = function() return not CustomDruidComboBarDB.anchorToPRD end,
        },
        x = {
            name = "X Position",
            desc = "Horizontal position when not anchored.",
            type = "range",
            min = -1000, max = 1000, step = 1,
            get = function() return CustomDruidComboBarDB.x or 0 end,
            set = function(_, val)
                CustomDruidComboBarDB.x = val
                if UpdateDruidComboBarSettings then UpdateDruidComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.6,
            disabled = function() return CustomDruidComboBarDB.anchorToPRD end,
        },
        y = {
            name = "Y Position",
            desc = "Vertical position when not anchored.",
            type = "range",
            min = -1000, max = 1000, step = 1,
            get = function() return CustomDruidComboBarDB.y or 0 end,
            set = function(_, val)
                CustomDruidComboBarDB.y = val
                if UpdateDruidComboBarSettings then UpdateDruidComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.7,
            disabled = function() return CustomDruidComboBarDB.anchorToPRD end,
        },
        comboPointBgColor = {
            name = "Combo Point Background Color",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomDruidComboBarDB.comboPointBgColor or {0, 0, 0, 0.5}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomDruidComboBarDB.comboPointBgColor = {r, g, b, a}
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
                local c = CustomDruidComboBarDB.chargedComboPointBgColor or {0.1, 0.3, 0.5, 0.7}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomDruidComboBarDB.chargedComboPointBgColor = {r, g, b, a}
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
                local c = CustomDruidComboBarDB.chargedComboPointColor or {0.2, 0.6, 1, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomDruidComboBarDB.chargedComboPointColor = {r, g, b, a}
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 99,
        },
        gradientColoringEnabled = {
            name = "Enable Gradient Coloring",
            desc = "Override all combo points with a gradient between two colors.",
            type = "toggle",
            get = function() return CustomDruidComboBarDB.gradientColoringEnabled end,
            set = function(_, val)
                CustomDruidComboBarDB.gradientColoringEnabled = val
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 100,
        },
        gradientColorStart = {
            name = "Gradient Start Color",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomDruidComboBarDB.gradientColorStart
                if type(c) ~= "table" or not c[1] then c = {1, 0, 0, 1} end
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomDruidComboBarDB.gradientColorStart = {r, g, b, a}
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 101,
            disabled = function() return not CustomDruidComboBarDB.gradientColoringEnabled end,
        },
        gradientColorEnd = {
            name = "Gradient End Color",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomDruidComboBarDB.gradientColorEnd
                if type(c) ~= "table" or not c[1] then c = {1, 1, 0, 1} end
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomDruidComboBarDB.gradientColorEnd = {r, g, b, a}
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 102,
            disabled = function() return not CustomDruidComboBarDB.gradientColoringEnabled end,
        },
    },
}
for i = 1, 7 do
    CustomDruidComboBarOptions.args["comboPointFillColor"..i] = {
        name = "Combo Point "..i.." Color",
        type = "color",
        hasAlpha = true,
        get = function()
            local c = CustomDruidComboBarDB.comboPointFillColors[i] or {1, 0.7, 0.2, 1}
            return c[1], c[2], c[3], c[4]
        end,
        set = function(_, r, g, b, a)
            CustomDruidComboBarDB.comboPointFillColors[i] = {r, g, b, a}
            if UpdateComboPoints then UpdateComboPoints() end
        end,
        order = 20 + i,
    }
end
_G.CustomDruidComboBarOptions = CustomDruidComboBarOptions
