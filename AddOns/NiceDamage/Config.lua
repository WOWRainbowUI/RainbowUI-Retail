local addonName, addon = ...
local LSM = LibStub("LibSharedMedia-3.0")

function addon:GetOptions()
    return {
        name = "NiceDamage (Reloaded)",
        type = "group",
        args = {
            settings = {
                name = "General Settings",
                type = "group",
                inline = true,
                order = 1,
                args = {
                    enable = {
                        type = "toggle",
                        name = "Enable Addon",
                        desc = "Toggle the replacement of combat text fonts.",
                        get = function() return self.db.profile.enabled end,
                        set = function(_, v) 
                            self.db.profile.enabled = v
                            self:ApplySystemFonts() 
                        end,
                        order = 1,
                    },
                    minimap = {
                        type = "toggle",
                        name = "Show Minimap Icon",
                        desc = "Toggle the display of the minimap button.",
                        get = function() return not self.db.global.minimap.hide end,
                        set = function(_, v) 
                            self.db.global.minimap.hide = not v
                            self:UpdateMinimapIcon() 
                        end,
                        order = 2,
                    },
                    loadCustom = {
                        type = "toggle",
                        name = "Load Custom Font",
                        desc = "Load and auto-select 'Custom Font NDR'. |cFFFF0000(Requires you to log out and in to see in list)|r",
                        get = function() return self.db.profile.loadCustomFont end,
                        set = function(_, v) 
                            self.db.profile.loadCustomFont = v
                            if v then
                                self.db.profile.fontName = "Custom Font NDR"
                                self.db.profile.uiFont = "Custom Font NDR"
                            else
                                self.db.profile.fontName = "Pepsi Modern"
                                self.db.profile.uiFont = "Pepsi Modern"
                            end
                            self:ApplySystemFonts()
                        end,
                        order = 3,
                    },
                }
            },
            targets = {
                name = "Text to update",
                type = "group",
                inline = true,
                order = 2,
                args = {
                    world = {
                        type = "toggle",
                        name = "Combat Damage",
                        desc = "Apply font to damage and healing numbers floating over units. |cFFFF0000(Requires Log Out)|r",
                        get = function() return self.db.profile.updateWorldText end,
                        set = function(_, v) 
                            self.db.profile.updateWorldText = v
                            self:ApplySystemFonts() 
                        end,
                        order = 1,
                    },
                    ui = {
                        type = "toggle",
                        name = "Scrolling Combat Text",
                        desc = "Apply font to damage you receive and scrolling combat text.",
                        get = function() return self.db.profile.updateUiText end,
                        set = function(_, v) 
                            self.db.profile.updateUiText = v
                            self:ApplySystemFonts() 
                        end,
                        order = 2,
                    },
                }
            },
            worldFontGroup = {
                name = "Combat Damage Appearance",
                type = "group",
                inline = true,
                order = 3,
                args = {
                    warning = {
                        type = "description",
                        name = "|cFFFF0000Important:|r Changing the Combat Font requires you to Log Out. Size changes apply instantly.",
                        order = 1,
                        fontSize = "medium",
                    },
                    worldFont = {
                        type = "select",
                        name = "Combat Damage Font",
                        desc = "Select the font for damage dealt to enemies.",
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable("font"),
                        get = function() return self.db.profile.fontName end,
                        set = function(_, v) 
                            self.db.profile.fontName = v
                            self:ApplySystemFonts() 
                        end,
                        order = 2,
                    },
                    fontSize = {
                        type = "range",
                        name = "Combat Damage Scale (World)",
                        desc = "Adjust the scale of numbers over heads. 1.0 is default.",
                        min = 0.5, max = 5, step = 0.1,
                        get = function() return self.db.profile.fontSize end,
                        set = function(_, v) 
                            self.db.profile.fontSize = v
                            self:ApplySystemFonts() 
                        end,
                        order = 3,
                    },
                    fontGravity = {
                        type = "range",
                        name = "Combat Text Gravity",
                        desc = "Controls how fast damage numbers fall. 0.5 is default.",
                        min = -10, max = 10, step = 0.5,
                        get = function() return self.db.profile.fontGravity end,
                        set = function(_, v) 
                            self.db.profile.fontGravity = v
                            self:ApplySystemFonts() 
                        end,
                        order = 4,
                    },
                    fontRampDuration = {
                        type = "range",
                        name = "Combat Text Ramp Duration",
                        desc = "Controls how long damage numbers stay visible. 1.0 is default.",
                        min = 0.1, max = 3.0, step = 0.01,
                        get = function() return self.db.profile.fontRampDuration end,
                        set = function(_, v) 
                            self.db.profile.fontRampDuration = v
                            self:ApplySystemFonts() 
                        end,
                        order = 5,
                    },
                },
            },
            uiFontGroup = {
                name = "Scrolling Combat Text Appearance",
                type = "group",
                inline = true,
                order = 4,
                args = {
                    uiFont = {
                        type = "select",
                        name = "Scrolling Combat Font",
                        desc = "Select the font for incoming damage/heals.",
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable("font"),
                        get = function() return self.db.profile.uiFont end,
                        set = function(_, v) 
                            self.db.profile.uiFont = v
                            self:ApplySystemFonts() 
                        end,
                        order = 1,
                    },
                    fontOutline = {
                        type = "select",
                        name = "Font Outline",
                        desc = "Set the outline style for the scrolling text.",
                        values = {
                            [""] = "None",
                            ["OUTLINE"] = "Thin Outline",
                            ["THICKOUTLINE"] = "Thick Outline",
                        },
                        get = function() return self.db.profile.uiOutline or "OUTLINE" end,
                        set = function(_, v) 
                            self.db.profile.uiOutline = v
                            self:ApplySystemFonts() 
                        end,
                        order = 2,
                    },
                    uiMonochrome = {
                        type = "toggle",
                        name = "Monochrome",
                        desc = "Disable anti-aliasing (removes font smoothing). Best for pixel fonts.",
                        get = function() return self.db.profile.uiMonochrome end,
                        set = function(_, v) 
                            self.db.profile.uiMonochrome = v
                            self:ApplySystemFonts() 
                        end,
                        order = 3,
                    },
                    uiShadowOffset = {
                        type = "range",
                        name = "Shadow Offset",
                        desc = "Set the distance of the font shadow. 0 is off.",
                        min = 0, max = 10, step = 1,
                        get = function() return self.db.profile.uiShadowOffset end,
                        set = function(_, v) 
                            self.db.profile.uiShadowOffset = v
                            self:ApplySystemFonts() 
                        end,
                        order = 4,
                    },
                }
            }
        }
    }
end