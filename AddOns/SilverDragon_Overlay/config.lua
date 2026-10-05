local myname = ...

local core = LibStub("AceAddon-3.0"):GetAddon("SilverDragon")
local module = core:GetModule("Overlay")
local Debug = core.Debug
local ns = core.NAMESPACE

local _, myfullname = C_AddOns.GetAddOnInfo("SilverDragon")

-- Both map sections offer this, and quest/achievement completion is shown either
-- way, so it's only ever about the loot.
local function lootSelect(order)
    return {
        type = "select",
        name = "顯示戰利品",
        desc = "選擇怪物或寶藏戰利品的顯示位置。是否包含一般物品由「浮動提示」設定決定。",
        values = {
            [module.const.LOOT_TOOLTIP] = "在浮動提示中",
            [module.const.LOOT_WINDOW] = "在彈出視窗中",
            [module.const.LOOT_BOTH] = "兩者皆顯示",
            [module.const.LOOT_NONE] = "不顯示",
        },
        sorting = {
            module.const.LOOT_TOOLTIP,
            module.const.LOOT_WINDOW,
            module.const.LOOT_BOTH,
            module.const.LOOT_NONE,
        },
        order = order,
    }
end

local iconThemes = {
    {value = "skulls", text = "骷髏"},
    {value = "circles", text = "圓形"},
    {value = "stars", text = "星形"},
}
local iconColors = {
    {value = "distinct", text = "每個怪物使用不同顏色",
     tip = "區域內每個怪物與寶藏都有各自的顏色。"},
    {value = "completion", text = "依剩餘獎勵",
     tip = "以四種顏色區分：有坐騎、有值得關注的獎勵、沒有值得關注的獎勵，以及完全沒有剩餘獎勵。"},
}
local function selectValues(list)
    local values = {}
    for _, entry in ipairs(list) do
        values[entry.value] = entry.text
    end
    return values
end

local unknownTip = "沒有可判斷的資訊：沒有追蹤任務、成就或已知戰利品"
local nothingTip = "仍可拾取戰利品，但已無值得關注的獎勵"
local doneTip = "已無剩餘獎勵：成就已完成且戰利品已全部拾取，或追蹤任務已完成"
local achievementlessTip = "是否顯示不屬於任何已知成就條件的圖示"

function module:RegisterConfig()
    local config = core:GetModule("Config", true)
    if not config then return end
    config.options.plugins.overlay = { overlay = {
        type = "group",
        name = "地圖圖示",
        get = function(info) return self.db.profile[info[#info]] end,
        set = function(info, v)
            self.db.profile[info[#info]] = v
            module:Update()
        end,
        args = {
            display = {
                type = "group",
                name = "要顯示什麼",
                inline = true,
                args = {
                    rares = {
                        type = "group",
                        name = "稀有怪",
                        inline = true,
                        args = {
                            showMobs = {
                                type = "toggle",
                                name = "顯示稀有怪",
                                desc = "是否在地圖上顯示稀有怪",
                                width = "full",
                                order = 0,
                            },
                            filter = {
                                type = "select",
                                name = "顯示哪些稀有怪",
                                desc = "哪些內容「值得關注」由「關注條件」設定決定，通常是可收藏的戰利品。",
                                values = {
                                    everything = "全部",
                                    notable = "值得關注的",
                                },
                                sorting = {"notable", "everything"},
                                disabled = function() return not self.db.profile.showMobs end,
                                width = "double",
                                order = 5,
                            },
                            showUnknown = {
                                type = "toggle",
                                name = "也顯示資料未知的",
                                desc = unknownTip,
                                disabled = function() return not self.db.profile.showMobs or self.db.profile.filter == "everything" end,
                                order = 10,
                            },
                            showNothing = {
                                type = "toggle",
                                name = "也顯示已無所需獎勵的",
                                desc = nothingTip,
                                disabled = function() return not self.db.profile.showMobs or self.db.profile.filter == "everything" end,
                                order = 11,
                            },
                            showDone = {
                                type = "toggle",
                                name = "也顯示已完成的",
                                desc = doneTip,
                                disabled = function() return not self.db.profile.showMobs or self.db.profile.filter == "everything" end,
                                order = 12,
                            },
                            achievementless = {
                                type = "toggle",
                                name = "顯示與成就無關的稀有怪",
                                desc = achievementlessTip,
                                disabled = function() return not self.db.profile.showMobs end,
                                width = "full",
                                order = 20,
                            },
                        },
                        order = 10,
                    },
                    treasures = {
                        type = "group",
                        name = "寶藏",
                        inline = true,
                        args = {
                            showTreasures = {
                                type = "toggle",
                                name = "顯示寶藏",
                                desc = "是否在地圖上顯示寶藏",
                                width = "full",
                                order = 0,
                            },
                            filterTreasure = {
                                type = "select",
                                name = "顯示哪些寶藏",
                                desc = "哪些內容「值得關注」由「關注條件」設定決定，通常是可收藏的戰利品。",
                                values = {
                                    everything = "全部",
                                    notable = "值得關注的",
                                },
                                sorting = {"notable", "everything"},
                                disabled = function() return not self.db.profile.showTreasures end,
                                width = "double",
                                order = 5,
                            },
                            showUnknownTreasure = {
                                type = "toggle",
                                name = "也顯示無法判斷的",
                                desc = unknownTip,
                                disabled = function() return not self.db.profile.showTreasures or self.db.profile.filterTreasure == "everything" end,
                                order = 10,
                            },
                            showNothingTreasure = {
                                type = "toggle",
                                name = "也顯示已無所需獎勵的",
                                desc = nothingTip,
                                disabled = function() return not self.db.profile.showTreasures or self.db.profile.filterTreasure == "everything" end,
                                order = 11,
                            },
                            showDoneTreasure = {
                                type = "toggle",
                                name = "也顯示已拾取的",
                                desc = doneTip,
                                disabled = function() return not self.db.profile.showTreasures or self.db.profile.filterTreasure == "everything" end,
                                order = 12,
                            },
                            achievementlessTreasure = {
                                type = "toggle",
                                name = "顯示與成就無關的寶藏",
                                desc = achievementlessTip,
                                disabled = function() return not self.db.profile.showTreasures end,
                                width = "full",
                                order = 20,
                            },
                        },
                        order = 20,
                    },
                    emphasize = {
                        type = "toggle",
                        name = "強調值得關注的圖示",
                        desc = "放大仍有值得關注獎勵的圖示。在地圖同時顯示已無所需獎勵或已完成的稀有怪時，便於辨識。",
                        width = "full",
                        order = 30,
                    },
                    unhide = {
                        type = "execute",
                        name = "重設隱藏的圖示",
                        desc = "重新顯示所有透過右鍵選單手動隱藏的圖示。",
                        func = function()
                            wipe(self.db.profile.hidden)
                            wipe(self.db.profile.hiddenTreasure)
                            module:Update()
                        end,
                        order = 50,
                    },
                },
                order = 0,
            },
            icon = {
                type = "group",
                name = "圖示設定",
                inline = true,
                args = {
                    desc = {
                        name = "這些設定控制圖示的外觀和樣式。",
                        type = "description",
                        order = 0,
                    },
                    icon_theme = {
                        type = "select",
                        name = "圖示樣式",
                        desc = "選擇要使用的圖示樣式",
                        values = selectValues(iconThemes),
                        order = 40,
                    },
                    icon_color = {
                        type = "select",
                        name = "圖示顏色",
                        desc = "選擇圖示的著色方式。\n\n「依剩餘獎勵」以四種顏色區分：有坐騎、有值得關注的獎勵、沒有值得關注的獎勵，以及完全沒有剩餘獎勵。",
                        values = selectValues(iconColors),
                        order = 50,
                    },
                },
                order = 10,
            },
            worldmap = {
                type = "group",
                name = "世界地圖",
                inline = true,
                get = function(info) return self.db.profile.worldmap[info[#info]] end,
                set = function(info, v)
                    self.db.profile.worldmap[info[#info]] = v
                    module:Update()
                    if WorldMapFrame.RefreshOverlayFrames then
                        WorldMapFrame:RefreshOverlayFrames()
                    end
                end,
                args = {
                    enabled = {
                        type = "toggle",
                        name = "啟用",
                        desc = "在世界地圖上顯示圖示",
                        width = "full",
                        order = 0,
                    },
                    icon_scale = {
                        type = "range",
                        name = "圖示大小",
                        desc = "圖示的縮放大小",
                        min = 0.25, max = 2, step = 0.01,
                        order = 20,
                    },
                    icon_alpha = {
                        type = "range",
                        name = "圖示透明度",
                        desc = "圖示的 Alpha 透明度",
                        min = 0, max = 1, step = 0.01,
                        order = 30,
                    },
                    routes = config.toggle("巡邏路線", "顯示部分怪物的巡邏路線", 40),
                    loot = lootSelect(50),
                    tooltip_help = config.toggle("操作提示", "在浮動提示中顯示滑鼠操作快捷方式", 53),
                },
                order = 20,
            },
            minimap = {
                type = "group",
                name = "小地圖",
                inline = true,
                get = function(info) return self.db.profile.minimap[info[#info]] end,
                set = function(info, v)
                    self.db.profile.minimap[info[#info]] = v
                    module:Update()
                end,
                args = {
                    enabled = {
                        type = "toggle",
                        name = "啟用",
                        desc = "在小地圖上顯示圖示",
                        width = "full",
                        order = 0,
                    },
                    edge = {
                        type = "select",
                        name = "在邊緣顯示",
                        values = {
                            [module.const.EDGE_NEVER] = "永不顯示",
                            [module.const.EDGE_FOCUS] = "顯示追蹤的",
                            [module.const.EDGE_ALWAYS] = "總是顯示",
                        },
                        order = 10,
                    },
                    icon_scale = {
                        type = "range",
                        name = "圖示大小",
                        desc = "圖示的縮放大小",
                        min = 0.25, max = 2, step = 0.01,
                        order = 20,
                    },
                    icon_alpha = {
                        type = "range",
                        name = "圖示透明度",
                        desc = "圖示的 Alpha 透明度",
                        min = 0, max = 1, step = 0.01,
                        order = 30,
                    },
                    routes = config.toggle("巡邏路線", "顯示部分怪物的巡邏路線", 40),
                    loot = lootSelect(41),
                    tooltip_help = config.toggle("操作提示", "在浮動提示中顯示滑鼠操作快捷方式", 43),
                },
                order = 30,
            },
        },
    }, }
end

-- The "what to display" options as a right-click menu. The broker module hangs
-- this off its world-map button; keeping it here means it stays in step with the
-- options above. Worldmap/minimap tuning is left out -- fiddly, and rarely
-- touched -- so those wait on the full panel.
local menuKinds = {
    {name = "稀有怪", show = "showMobs", filter = "filter", showTip = "在地圖上顯示稀有怪",
     also = {
        {key = "showUnknown", text = "也顯示無法判斷的", tip = unknownTip},
        {key = "showNothing", text = "也顯示已無所需獎勵的", tip = nothingTip},
        {key = "showDone", text = "也顯示已完成的", tip = doneTip},
     },
     achless = {key = "achievementless", text = "與成就無關的稀有怪", tip = achievementlessTip}},
    {name = "寶藏", show = "showTreasures", filter = "filterTreasure", showTip = "在地圖上顯示寶藏",
     also = {
        {key = "showUnknownTreasure", text = "也顯示無法判斷的", tip = unknownTip},
        {key = "showNothingTreasure", text = "也顯示已無所需獎勵的", tip = nothingTip},
        {key = "showDoneTreasure", text = "也顯示已拾取的", tip = doneTip},
     },
     achless = {key = "achievementlessTreasure", text = "與成就無關的寶藏", tip = achievementlessTip}},
}

local function displayMenu(owner, rootDescription)
    local odb = module.db.profile

    rootDescription:SetTag("MENU_SILVERDRAGON_OVERLAY_DISPLAY")
    rootDescription:CreateTitle(myfullname)

    -- enabled is a predicate, not a value: the menu polls it, so a row greys out
    -- the moment the toggle it depends on changes, without reopening the menu
    local function toggle(parent, text, key, tip, enabled)
        local item = parent:CreateCheckbox(text,
            function() return odb[key] end,
            function() odb[key] = not odb[key]; module:Update() end)
        item:SetTitleAndTextTooltip(nil, tip)
        if enabled then item:SetEnabled(enabled) end
        return item
    end
    local function filterRadios(parent, key, enabled)
        local function on(v) return function() return odb[key] == v end end
        local function pick(v) return function() odb[key] = v; module:Update(); return MenuResponse.Refresh end end
        local a = parent:CreateRadio("值得關注的", on("notable"), pick("notable"))
        local b = parent:CreateRadio("全部", on("everything"), pick("everything"))
        if enabled then a:SetEnabled(enabled) b:SetEnabled(enabled) end
    end

    for _, k in ipairs(menuKinds) do
        local kindOn = function() return odb[k.show] end
        -- as in the options: the "also show" rows do nothing while everything's
        -- already showing, and nothing at all while the kind is switched off
        local alsoOn = function() return odb[k.show] and odb[k.filter] ~= "everything" end
        local root = toggle(rootDescription, k.name, k.show, k.showTip)
        filterRadios(root, k.filter, kindOn)
        root:CreateDivider()
        for _, row in ipairs(k.also) do
            toggle(root, row.text, row.key, row.tip, alsoOn)
        end
        root:CreateDivider()
        toggle(root, k.achless.text, k.achless.key, k.achless.tip, kindOn)
    end

    toggle(rootDescription, "強調值得關注的圖示", "emphasize", "放大值得關注的圖示")

    rootDescription:CreateDivider()
    rootDescription:CreateTitle("圖示")
    local function picker(text, key, list, tip)
        local submenu = rootDescription:CreateButton(text)
        submenu:SetTitleAndTextTooltip(nil, tip)
        for _, entry in ipairs(list) do
            local item = submenu:CreateRadio(entry.text,
                function() return odb[key] == entry.value end,
                function() odb[key] = entry.value; module:Update(); return MenuResponse.Refresh end)
            if entry.tip then item:SetTitleAndTextTooltip(nil, entry.tip) end
        end
    end
    picker("圖示樣式", "icon_theme", iconThemes, "選擇要使用的圖示樣式")
    picker("圖示顏色", "icon_color", iconColors, "選擇圖示的著色方式")

    rootDescription:CreateDivider()
    rootDescription:CreateButton("開啟設定", function()
        local config = core:GetModule("Config", true)
        if not config then return end
        config:ShowConfig()
        LibStub("AceConfigDialog-3.0"):SelectGroup("SilverDragon", "overlay")
    end)
end

function module:ShowDisplayMenu(owner)
    if not (_G.MenuUtil and MenuUtil.CreateContextMenu) then return false end
    MenuUtil.CreateContextMenu(owner, displayMenu)
    return true
end