CustomMageArcaneOrbOptions = {
    name = "|cFF40C7EBCustom Mage Arcane Orb Bar|r",
    type = "group",
    args = {
        enableCustomArcaneOrb = {
            name = "Enable Custom Arcane Orb Bar",
            desc = "Show the custom arcane orb bar. Disable to use default PRD arcane orbs.",
            type = "toggle",
            get = function() return CustomMageArcaneOrbDB.enabled ~= false end,
            set = function(_, val)
                CustomMageArcaneOrbDB.enabled = val
                if UpdateMageArcaneOrbEnabled then UpdateMageArcaneOrbEnabled() end
            end,
            order = 0.5,
        },
        arcaneOrbWidth = {
            name = "Arcane Orb Width (per orb)",
            desc = "Set the width of each arcane orb. If 'Total Bar Width' is set, this is ignored.",
            type = "range",
            min = 10, max = 100, step = 0.001,
            get = function() return CustomMageArcaneOrbDB.arcaneOrbWidth end,
            set = function(_, val)
                CustomMageArcaneOrbDB.arcaneOrbWidth = val
                if UpdateArcaneOrbs then UpdateArcaneOrbs() end
            end,
            order = 1,
        },
        totalWidth = {
            name = "Total Bar Width",
            desc = "Set the total width for all arcane orbs combined. If set, orbs will auto-fit to this width.",
            type = "range",
            min = 60, max = 600, step = 0.1,
            get = function() return CustomMageArcaneOrbDB.totalWidth or 0 end,
            set = function(_, val)
                if val > 0 then
                    CustomMageArcaneOrbDB.totalWidth = val
                else
                    CustomMageArcaneOrbDB.totalWidth = nil
                end
                if UpdateArcaneOrbs then UpdateArcaneOrbs() end
            end,
            order = 1.5,
        },
        arcaneOrbHeight = {
            name = "Arcane Orb Height",
            desc = "Set the height of each arcane orb.",
            type = "range",
            min = 10, max = 100, step = 0.001,
            get = function() return CustomMageArcaneOrbDB.arcaneOrbHeight end,
            set = function(_, val)
                CustomMageArcaneOrbDB.arcaneOrbHeight = val
                if UpdateArcaneOrbs then UpdateArcaneOrbs() end
            end,
            order = 2,
        },
        arcaneOrbBgColor = {
            name = "Arcane Orb Background Color",
            desc = "Set the background color of the arcane orbs.",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomMageArcaneOrbDB.arcaneOrbBgColor or {0, 0, 0, 0.5}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomMageArcaneOrbDB.arcaneOrbBgColor = {r, g, b, a}
                if UpdateArcaneOrbs then UpdateArcaneOrbs() end
            end,
            order = 3,
        },
        arcaneOrbFillColor1 = {
            name = "Arcane Orb Fill Color 1",
            desc = "Set the fill color for the first arcane orb.",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomMageArcaneOrbDB.arcaneOrbFillColors[1] or {0.2, 0.4, 1, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomMageArcaneOrbDB.arcaneOrbFillColors[1] = {r, g, b, a}
                if UpdateArcaneOrbs then UpdateArcaneOrbs() end
            end,
            order = 4,
        },
        arcaneOrbFillColor2 = {
            name = "Arcane Orb Fill Color 2",
            desc = "Set the fill color for the second arcane orb.",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomMageArcaneOrbDB.arcaneOrbFillColors[2] or {0.2, 0.4, 1, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomMageArcaneOrbDB.arcaneOrbFillColors[2] = {r, g, b, a}
                if UpdateArcaneOrbs then UpdateArcaneOrbs() end
            end,
            order = 5,
        },
        arcaneOrbFillColor3 = {
            name = "Arcane Orb Fill Color 3",
            desc = "Set the fill color for the third arcane orb.",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomMageArcaneOrbDB.arcaneOrbFillColors[3] or {0.2, 0.4, 1, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomMageArcaneOrbDB.arcaneOrbFillColors[3] = {r, g, b, a}
                if UpdateArcaneOrbs then UpdateArcaneOrbs() end
            end,
            order = 6,
        },
        arcaneOrbFillColor4 = {
            name = "Arcane Orb Fill Color 4",
            desc = "Set the fill color for the fourth arcane orb.",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomMageArcaneOrbDB.arcaneOrbFillColors[4] or {0.2, 0.4, 1, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomMageArcaneOrbDB.arcaneOrbFillColors[4] = {r, g, b, a}
                if UpdateArcaneOrbs then UpdateArcaneOrbs() end
            end,
            order = 7,
        },
        gradientColoringEnabled = {
            name = "Enable Gradient Coloring",
            desc = "Enable gradient coloring for the arcane orbs based on position.",
            type = "toggle",
            get = function() return CustomMageArcaneOrbDB.gradientColoringEnabled end,
            set = function(_, val)
                CustomMageArcaneOrbDB.gradientColoringEnabled = val
                if UpdateArcaneOrbs then UpdateArcaneOrbs() end
            end,
            order = 8,
        },
        gradientColorStart = {
            name = "Gradient Start Color",
            desc = "Set the start color for gradient coloring.",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomMageArcaneOrbDB.gradientColorStart or {0, 0, 1, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomMageArcaneOrbDB.gradientColorStart = {r, g, b, a}
                if UpdateArcaneOrbs then UpdateArcaneOrbs() end
            end,
            order = 9,
        },
        gradientColorEnd = {
            name = "Gradient End Color",
            desc = "Set the end color for gradient coloring.",
            type = "color",
            hasAlpha = true,
            get = function()
                local c = CustomMageArcaneOrbDB.gradientColorEnd or {1, 1, 0, 1}
                return c[1], c[2], c[3], c[4]
            end,
            set = function(_, r, g, b, a)
                CustomMageArcaneOrbDB.gradientColorEnd = {r, g, b, a}
                if UpdateArcaneOrbs then UpdateArcaneOrbs() end
            end,
            order = 10,
        },
        anchorToPRD = {
            name = "Anchor to PRD",
            desc = "Anchor the arcane orb bar to the Personal Resource Display.",
            type = "toggle",
            get = function() return CustomMageArcaneOrbDB.anchorToPRD end,
            set = function(_, val)
                CustomMageArcaneOrbDB.anchorToPRD = val
                if UpdateMageArcaneOrbSettings then UpdateMageArcaneOrbSettings() end
            end,
            order = 11,
        },
        anchorPosition = {
            name = "Anchor Position",
            desc = "Position the bar above or below the PRD.",
            type = "select",
            values = {
                ABOVE = "Above",
                BELOW = "Below",
            },
            get = function() return CustomMageArcaneOrbDB.anchorPosition end,
            set = function(_, val)
                CustomMageArcaneOrbDB.anchorPosition = val
                if UpdateMageArcaneOrbSettings then UpdateMageArcaneOrbSettings() end
            end,
            order = 12,
        },
        anchorOffset = {
            name = "Anchor Offset",
            desc = "Offset from the PRD anchor point.",
            type = "range",
            min = -50, max = 50, step = 1,
            get = function() return CustomMageArcaneOrbDB.anchorOffset or 10 end,
            set = function(_, val)
                CustomMageArcaneOrbDB.anchorOffset = val
                if UpdateMageArcaneOrbSettings then UpdateMageArcaneOrbSettings() end
            end,
            order = 13,
        },
        anchorTarget = {
            name = "Anchor Target",
            desc = "Which PRD bar to anchor to.",
            type = "select",
            values = {
                HEALTH = "Health Bar",
                POWER = "Power Bar",
            },
            get = function() return CustomMageArcaneOrbDB.anchorTarget end,
            set = function(_, val)
                CustomMageArcaneOrbDB.anchorTarget = val
                if UpdateMageArcaneOrbSettings then UpdateMageArcaneOrbSettings() end
            end,
            order = 14,
        },
        locked = {
            name = "Lock Position",
            desc = "Lock the bar in place to prevent accidental movement.",
            type = "toggle",
            get = function() return CustomMageArcaneOrbDB.locked end,
            set = function(_, val)
                CustomMageArcaneOrbDB.locked = val
            end,
            order = 15,
        },
        debug = {
            name = "Debug Mode",
            desc = "Enable debug prints.",
            type = "toggle",
            get = function() return CustomMageArcaneOrbDB.debug end,
            set = function(_, val)
                CustomMageArcaneOrbDB.debug = val
            end,
            order = 16,
        },
    },
}

_G.CustomMageArcaneOrbOptions = CustomMageArcaneOrbOptions