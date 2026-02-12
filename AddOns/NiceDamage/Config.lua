local addonName, addon = ...
local LSM = LibStub("LibSharedMedia-3.0")

function addon:GetOptions()
    return {
        name = "美化戰鬥文字",
        type = "group",
        args = {
            settings = {
                name = "一般設定",
                type = "group",
                inline = true,
                order = 1,
                args = {
                    enable = {
                        type = "toggle",
                        name = "啟用插件",
                        desc = "切換是否替換戰鬥文字字型。",
                        get = function() return self.db.profile.enabled end,
                        set = function(_, v) self.db.profile.enabled = v self:ApplySystemFonts() end,
                        order = 1,
                    },
                    minimap = {
                        type = "toggle",
                        name = "顯示小地圖圖示",
                        desc = "切換小地圖按鈕顯示。",
                        get = function() return not self.db.global.minimap.hide end,
                        set = function(_, v) self.db.global.minimap.hide = not v self:UpdateMinimapIcon() end,
                        order = 2,
                    },
                    loadCustom = {
                        type = "toggle",
                        name = "載入自訂字型",
                        desc = "載入並自動選擇「Custom Font NDR」。|cFFFF0000(需要登出並重新登入才能在列表中看到)|r",
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
                name = "要更新的文字",
                type = "group",
                inline = true,
                order = 2,
                args = {
                    world = {
                        type = "toggle",
                        name = "傷害數字",
                        desc = "套用字型到敵人頭頂的傷害與治療數字。|cFFFF0000(需要登出)|r",
                        get = function() return self.db.profile.updateWorldText end,
                        set = function(_, v) self.db.profile.updateWorldText = v self:ApplySystemFonts() end,
                        order = 1,
                    },
                    ui = {
                        type = "toggle",
                        name = "捲動戰鬥文字",
                        desc = "套用字型到你受到的傷害與捲動戰鬥文字。",
                        get = function() return self.db.profile.updateUiText end,
                        set = function(_, v) self.db.profile.updateUiText = v self:ApplySystemFonts() end,
                        order = 2,
                    },
                }
            },
            worldFontGroup = {
                name = "傷害數字外觀",
                type = "group",
                inline = true,
                order = 3,
                args = {
                    warning = {
                        type = "description",
                        name = "|cFFFF0000重要:|r 更改傷害數字字型需要您登出，更改大小則會立即生效。",
                        order = 1,
                        fontSize = "medium",
                    },
                    worldFont = {
                        type = "select",
                        name = "傷害數字字型",
                        desc = "選擇對敵方造成傷害時使用的字型。",
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable("font"),
                        get = function() return self.db.profile.fontName end,
                        set = function(_, v) self.db.profile.fontName = v self:ApplySystemFonts() end,
                        order = 2,
                    },
                    fontSize = {
                        type = "range",
                        name = "傷害數字縮放 (世界)",
                        desc = "調整頭頂數字的縮放。預設 1.0。",
                        min = 0.5,
                        max = 5,
                        step = 0.1,
                        get = function() return self.db.profile.fontSize end,
                        set = function(_, v) self.db.profile.fontSize = v self:ApplySystemFonts() end,
                        order = 3,
                    },
                    fontGravity = {
                        type = "range",
                        name = "傷害數字重力",
                        desc = "控制傷害數字下落速度。預設 0.5。",
                        min = -10,
                        max = 10,
                        step = 0.5,
                        get = function() return self.db.profile.fontGravity end,
                        set = function(_, v) self.db.profile.fontGravity = v self:ApplySystemFonts() end,
                        order = 4,
                    },
                    fontRampDuration = {
                        type = "range",
                        name = "傷害數字顯示時間",
                        desc = "控制傷害數字停留時間。預設 1.0。",
                        min = 0.1,
                        max = 3.0,
                        step = 0.01,
                        get = function() return self.db.profile.fontRampDuration end,
                        set = function(_, v) self.db.profile.fontRampDuration = v self:ApplySystemFonts() end,
                        order = 5,
                    },
                },
            },
            uiFontGroup = {
                name = "捲動戰鬥文字外觀",
                type = "group",
                inline = true,
                order = 4,
                args = {
                    uiFont = {
                        type = "select",
                        name = "捲動戰鬥文字字型",
                        desc = "選擇用於收到的傷害/治療的字型。",
                        dialogControl = 'LSM30_Font',
                        values = LSM:HashTable("font"),
                        get = function() return self.db.profile.uiFont end,
                        set = function(_, v) self.db.profile.uiFont = v self:ApplySystemFonts() end,
                        order = 1,
                    },
                    fontOutline = {
                        type = "select",
                        name = "文字外框",
                        desc = "設定捲動文字的外框樣式。",
                        values = {
                            [""] = "無",
                            ["OUTLINE"] = "細外框",
                            ["THICKOUTLINE"] = "粗外框",
                        },
                        get = function() return self.db.profile.uiOutline or "OUTLINE" end,
                        set = function(_, v) self.db.profile.uiOutline = v self:ApplySystemFonts() end,
                        order = 2,
                    },
                    uiMonochrome = {
                        type = "toggle",
                        name = "單色 (無消除鋸齒)",
                        desc = "停用消除鋸齒 (移除字型平滑)。適合像素字型。",
                        get = function() return self.db.profile.uiMonochrome end,
                        set = function(_, v) self.db.profile.uiMonochrome = v self:ApplySystemFonts() end,
                        order = 3,
                    },
                    uiShadowOffset = {
                        type = "range",
                        name = "陰影偏移",
                        desc = "設定字型陰影距離。0 為關閉。",
                        min = 0,
                        max = 10,
                        step = 1,
                        get = function() return self.db.profile.uiShadowOffset end,
                        set = function(_, v) self.db.profile.uiShadowOffset = v self:ApplySystemFonts() end,
                        order = 4,
                    },
                }
            }
        }
    }
end
