CustomDruidComboBarOptions = {
    name = "|cFFFF7C0A自訂德魯伊連擊點數條|r",
    type = "group",
    args = {
        enableCustomComboBar = {
            name = "啟用自訂連擊點數條",
            desc = "顯示自訂連擊點數條。停用以使用預設的個人資源條連擊點數。",
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
            name = "騎乘坐騎時隱藏",
            desc = "當在坐騎上時隱藏連擊點數條。",
            get = function() return CustomDruidComboBarDB.hideWhenMounted end,
            set = function(_, val)
                CustomDruidComboBarDB.hideWhenMounted = val
                if UpdateDruidComboBarEnabled then UpdateDruidComboBarEnabled() end
            end,
        },
        comboPointWidth = {
            name = "連擊點數寬度 (每點)",
            desc = "設定每個連擊點數的寬度。若有設定「連擊條總寬度」，此設定將被忽略。",
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
            name = "連擊條總寬度",
            desc = "設定所有連擊點數加總的總寬度。若有設定，點數寬度將自動調整以符合此寬度。",
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
            name = "連擊點數高度",
            desc = "設定每個連擊點數的高度。",
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
            name = "鎖定連擊條",
            desc = "鎖定或解鎖連擊點數條以便拖曳。",
            type = "toggle",
            get = function() return CustomDruidComboBarDB.locked end,
            set = function(_, val) CustomDruidComboBarDB.locked = val end,
            order = 3,
        },
        anchorToPRD = {
            name = "對齊到個人資源條",
            desc = "將連擊點數條附著在個人資源條的血量條或能量條上。",
            type = "toggle",
            get = function() return CustomDruidComboBarDB.anchorToPRD end,
            set = function(_, val)
                CustomDruidComboBarDB.anchorToPRD = val
                if UpdateDruidComboBarSettings then UpdateDruidComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.2,
        },
        anchorTarget = {
            name = "對齊目標",
            desc = "對齊目標",
            type = "select",
            values = { HEALTH = "血量條", POWER = "能量條" },
            get = function() return CustomDruidComboBarDB.anchorTarget or "HEALTH" end,
            set = function(_, val)
                CustomDruidComboBarDB.anchorTarget = val
                if UpdateDruidComboBarSettings then UpdateDruidComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.3,
            disabled = function() return not CustomDruidComboBarDB.anchorToPRD end,
        },
        anchorPosition = {
            name = "對齊位置",
            desc = "放置在選擇的個人資源條上方或下方。",
            type = "select",
            values = { ABOVE = "上方", BELOW = "下方" },
            get = function() return CustomDruidComboBarDB.anchorPosition or "BELOW" end,
            set = function(_, val)
                CustomDruidComboBarDB.anchorPosition = val
                if UpdateDruidComboBarSettings then UpdateDruidComboBarSettings() elseif UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 3.4,
            disabled = function() return not CustomDruidComboBarDB.anchorToPRD end,
        },
        anchorOffset = {
            name = "位置偏移",
            desc = "對齊時相對於個人資源條的垂直偏移量",
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
            name = "水平偏移",
            desc = "對齊時的水平位置。",
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
            name = "垂直偏移",
            desc = "對齊時的垂直位置。",
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
            name = "連擊點數背景顏色",
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
            name = "充能連擊點數背景",
            desc = "充能 (爆擊) 連擊點數的背景顏色。",
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
            name = "充能連擊點數顏色",
            desc = "充能 (爆擊) 連擊點數的顏色。",
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
            name = "啟用漸層色",
            desc = "使用雙色漸層覆蓋所有連擊點數顏色。",
            type = "toggle",
            get = function() return CustomDruidComboBarDB.gradientColoringEnabled end,
            set = function(_, val)
                CustomDruidComboBarDB.gradientColoringEnabled = val
                if UpdateComboPoints then UpdateComboPoints() end
            end,
            order = 100,
        },
        gradientColorStart = {
            name = "漸層起始色",
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
            name = "漸層結束色",
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
        name = "連擊點數 "..i.." 顏色",
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
