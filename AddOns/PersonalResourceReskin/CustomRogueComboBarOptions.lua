CustomRogueComboBarDB = CustomRogueComboBarDB or {
    x = 0, y = -120, comboPointWidth = 24, comboPointHeight = 24, locked = false,
    totalWidth = nil,
    comboPointBgColor = {0, 0, 0, 0.5},
    chargedComboPointBgColor = {0.1, 0.3, 0.5, 0.7},
    comboPointFillColors = {
        {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1},
        {1, 0.7, 0.2, 1}, {1, 0.7, 0.2, 1},
    },
    chargedComboPointColor = {0.2, 0.6, 1, 1},
    gradientColoringEnabled = false,
    gradientColorStart = {1, 0, 0, 1},
    gradientColorEnd = {1, 1, 0, 1},
    anchorToPRD = false,
    anchorPosition = "BELOW",
    anchorOffset = 10,
    anchorTarget = "HEALTH", -- HEALTH or POWER
    debug = false,
    enabled = true,
}

CustomRogueComboBarOptions = {
    name = "|cFFFFF569自訂盜賊連擊點數條|r",
    type = "group",
    args = {
        enableCustomComboBar = {
            name = "啟用自訂連擊點數條",
            desc = "顯示自訂連擊點數條。停用以使用預設個人資源條連擊點數。",
            type = "toggle",
            get = function() return CustomRogueComboBarDB.enabled ~= false end,
            set = function(_, val)
                CustomRogueComboBarDB.enabled = val
                if UpdateRogueComboBarEnabled then UpdateRogueComboBarEnabled() end
            end,
            order = 0.5,
        },
        comboPointWidth = {
            name = "連擊點數寬度",
            desc = "設定每個連擊點數的寬度。若已設定「整條寬度」，此設定將被忽略。",
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
            name = "整條寬度",
            desc = "設定所有連擊點數合計的總寬度。若設定，點數將自動調整以符合此寬度。",
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
            name = "連擊點數高度",
            desc = "設定每個連擊點數的高度。",
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
            name = "鎖定位置",
            desc = "鎖定或解鎖連擊點數條以便拖曳。",
            type = "toggle",
            get = function() return CustomRogueComboBarDB.locked end,
            set = function(_, val) CustomRogueComboBarDB.locked = val end,
            order = 3,
        },
        anchorToPRD = {
            name = "對齊到個人資源條",
            desc = "將連擊點數條附加到個人資源條的血量條或能量條。",
            type = "toggle",
            get = function() return CustomRogueComboBarDB.anchorToPRD end,
            set = function(_, val)
                CustomRogueComboBarDB.anchorToPRD = val
                if UpdateRogueComboBarSettings then UpdateRogueComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.2,
        },
        anchorTarget = {
            name = "對齊目標",
            desc = "選擇要對齊到哪一個個人資源條。",
            type = "select",
            values = { HEALTH = "血量條", POWER = "能量條" },
            get = function() return CustomRogueComboBarDB.anchorTarget or "HEALTH" end,
            set = function(_, val)
                CustomRogueComboBarDB.anchorTarget = val
                if UpdateRogueComboBarSettings then UpdateRogueComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.3,
            disabled = function() return not CustomRogueComboBarDB.anchorToPRD end,
        },
        anchorPosition = {
            name = "對齊位置",
            desc = "放置在所選個人資源條的上方或下方。",
            type = "select",
            values = { ABOVE = "上方", BELOW = "下方" },
            get = function() return CustomRogueComboBarDB.anchorPosition or "BELOW" end,
            set = function(_, val)
                CustomRogueComboBarDB.anchorPosition = val
                if UpdateRogueComboBarSettings then UpdateRogueComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.4,
            disabled = function() return not CustomRogueComboBarDB.anchorToPRD end,
        },
        anchorOffset = {
            name = "對齊偏移",
            desc = "對齊到個人資源條時的垂直偏移量。",
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
            name = "水平偏移",
            desc = "未對齊時的水平位置。",
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
            name = "垂直偏移",
            desc = "未對齊時的垂直位置。",
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
            name = "連擊點數背景顏色",
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
            name = "充能連擊點數背景",
            desc = "充能（關鍵）連擊點數的背景顏色。",
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
            name = "充能連擊點數顏色",
            desc = "充能（關鍵）連擊點數的顏色。",
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
            name = "啟用漸層色",
            desc = "以兩種顏色之間的漸層覆蓋所有連擊點數。",
            type = "toggle",
            get = function() return CustomRogueComboBarDB.gradientColoringEnabled end,
            set = function(_, val)
                CustomRogueComboBarDB.gradientColoringEnabled = val
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 100,
        },
        gradientColorStart = {
            name = "漸層起始色",
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
            name = "漸層結束色",
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
        name = "連擊點數 "..i.." 顏色",
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
