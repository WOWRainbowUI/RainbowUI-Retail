
    -- ...existing code...

    _G.CustomSoulShardBarOptions = {
	  name = "|cFF8787ED靈魂裂片條|r",
	  type = "group",
	  args = {
		showCountText = {
		  type = "toggle",
		  name = "顯示靈魂裂片數字",
		  desc = "在靈魂裂片條中央顯示或隱藏數字。",
		  order = 9.1,
		  get = function() return CustomSoulShardBarDB.showCountText ~= false end,
		  set = function(_, val)
			CustomSoulShardBarDB.showCountText = val
			if type(UpdateSoulShards) == "function" then
			  UpdateSoulShards()
			end
		  end,
		},

		-- ...其他既有選項...

		anchoring = {
		  type = "group",
		  name = "位置設定",
		  order = 20,
		  args = {
			anchorToPRD = {
			  type = "toggle",
			  name = "對齊個人資源條",
			  desc = "將靈魂裂片條對齊到個人資源條的血量或能量條。",
			  get = function() return CustomSoulShardBarDB.anchorToPRD end,
			  set = function(_, val)
				CustomSoulShardBarDB.anchorToPRD = val
				ApplyBarSettings()
			  end,
			  order = 1,
			},

			anchorTarget = {
			  type = "select",
			  name = "對齊到",
			  desc = "選擇對齊到個人資源條的血量條或能量條。",
			  values = { HEALTH = "血量條", POWER = "能量條" },
			  get = function() return CustomSoulShardBarDB.anchorTarget or "HEALTH" end,
			  set = function(_, val)
				CustomSoulShardBarDB.anchorTarget = val
				ApplyBarSettings()
			  end,
			  order = 2,
			  disabled = function() return not CustomSoulShardBarDB.anchorToPRD end,
			},

			anchorPosition = {
			  type = "select",
			  name = "位置",
			  desc = "將靈魂裂片條放置在上方或下方。",
			  values = { ABOVE = "上方", BELOW = "下方" },
			  get = function() return CustomSoulShardBarDB.anchorPosition or "BELOW" end,
			  set = function(_, val)
				CustomSoulShardBarDB.anchorPosition = val
				ApplyBarSettings()
			  end,
			  order = 3,
			  disabled = function() return not CustomSoulShardBarDB.anchorToPRD end,
			},

			anchorOffset = {
			  type = "range",
			  name = "偏移",
			  desc = "與對齊目標的距離 (像素)。",
			  min = -100,
			  max = 100,
			  step = 1,
			  get = function() return CustomSoulShardBarDB.anchorOffset or 10 end,
			  set = function(_, val)
				CustomSoulShardBarDB.anchorOffset = val
				ApplyBarSettings()
			  end,
			  order = 4,
			  disabled = function() return not CustomSoulShardBarDB.anchorToPRD end,
			},
		  }
		},
	  }
	}

local _, class = UnitClass("player")
if class ~= "WARLOCK" then return end

local function HideBlizzardSoulShardOrbs()
    local _, class = UnitClass("player")
    if class == "ROGUE" then return end
    local np = _G.ClassNameplateBarWarlockFrame
    if np then
        if np.Hide then np:Hide() end
        if np.comboPoints then
            for i, orb in ipairs(np.comboPoints) do
                if orb and orb.Hide then orb:Hide() end
            end
        end
    end
    if _G.prdClassFrame and _G.prdClassFrame.GetChildren then
        for _, child in ipairs({_G.prdClassFrame:GetChildren()}) do
            if child and child.Hide then child:Hide() end
        end
    end
end




local NUM_SOUL_SHARDS = 5 
local SOUL_SHARD_POWER_TYPE = Enum and Enum.PowerType and Enum.PowerType.SoulShards or 7 


local function SafeUnpackColor(color, default)
    if type(color) ~= "table" then
        return unpack(default or {1,1,1,1})
    end
    if color.r then
        return tonumber(color.r) or (default and default[1]) or 1,
               tonumber(color.g) or (default and default[2]) or 1,
               tonumber(color.b) or (default and default[3]) or 1,
               tonumber(color.a) or (default and default[4]) or 1
    end
    return tonumber(color[1]) or (default and default[1]) or 1,
           tonumber(color[2]) or (default and default[2]) or 1,
           tonumber(color[3]) or (default and default[3]) or 1,
           tonumber(color[4]) or (default and default[4]) or 1
end


CustomSoulShardBarDB = CustomSoulShardBarDB or {
    x = 0, y = -120, orbWidth = 24, orbHeight = 24, locked = false,
    orbBgColor = {0, 0, 0, 0.01}, 
    gradientColor1 = {0.7, 0, 1, 1}, 
    gradientColor2 = {1, 0.2, 0.7, 1}, 
    hideWhileMounted = false, 
    fillDirection = "vertical", -- "vertical" or "horizontal"
}



_G.CustomSoulShardBarOptions = {
    name = "|cFF8787ED靈魂裂片條|r",
    type = "group",
    args = {
        showCountText = {
            type = "toggle",
            name = "顯示靈魂裂片數字",
			desc = "在靈魂裂片條中央顯示或隱藏數字。",
            order = 9.1,
            get = function() return CustomSoulShardBarDB.showCountText ~= false end,
            set = function(_, val)
                CustomSoulShardBarDB.showCountText = val
                if type(UpdateSoulShards) == "function" then
                    UpdateSoulShards()
                end
            end,
        },
        fillDirection = {
            type = "select",
            name = "填滿方向",
            desc = "選擇裂片是垂直填滿（由下到上）或水平填滿（由左到右）。",
            values = { vertical = "垂直（由下到上）", horizontal = "水平（由左到右）" },
            get = function() return CustomSoulShardBarDB.fillDirection or "vertical" end,
            set = function(_, val)
                CustomSoulShardBarDB.fillDirection = val
                UpdateSoulShards()
            end,
            order = 0.5,
        },
        orbWidth = {
            type = "range", name = "裂片寬度", min = 10, max = 100, step = 0.001,
            get = function() return CustomSoulShardBarDB.orbWidth end,
            set = function(_, val)
                CustomSoulShardBarDB.orbWidth = val
                ApplyBarSettings()
                UpdateSoulShards()
            end,
            order = 1,
        },
        orbHeight = {
            type = "range", name = "裂片高度", min = 10, max = 100, step = 1,
            get = function() return CustomSoulShardBarDB.orbHeight end,
            set = function(_, val)
                CustomSoulShardBarDB.orbHeight = val
                ApplyBarSettings()
                UpdateSoulShards()
            end,
            order = 2,
        },
        x = {
            type = "range",
            name = "水平位置",
            desc = "水平移動靈魂裂片條。",
            min = -1000, max = 1000, step = 1,
            get = function() return CustomSoulShardBarDB.x end,
            set = function(_, val)
                CustomSoulShardBarDB.x = val
                ApplyBarSettings()
            end,
            order = 3,
        },
        y = {
            type = "range",
            name = "垂直位置",
            desc = "垂直移動靈魂裂片條。",
            min = -1000, max = 1000, step = 1,
            get = function() return CustomSoulShardBarDB.y end,
            set = function(_, val)
                CustomSoulShardBarDB.y = val
                ApplyBarSettings()
            end,
            order = 4,
        },
        anchoring = {
			type = "group",
			name = "位置設定",
			order = 4.1,
			inline = true,
			args = {
				anchorToPRD = {
					type = "toggle",
					name = "對齊個人資源條",
					desc = "將靈魂裂片條對齊到個人資源條的血量或能量條。",
					get = function() return CustomSoulShardBarDB.anchorToPRD end,
					set = function(_, val)
						CustomSoulShardBarDB.anchorToPRD = val
						ApplyBarSettings()
					end,
					order = 1,
				},
				anchorTarget = {
					type = "select",
					name = "對齊到",
					desc = "選擇對齊到個人資源條的血量條或能量條。",
					values = { HEALTH = "血量條", POWER = "能量條" },
					get = function() return CustomSoulShardBarDB.anchorTarget or "HEALTH" end,
					set = function(_, val)
						CustomSoulShardBarDB.anchorTarget = val
						ApplyBarSettings()
					end,
					order = 2,
					disabled = function() return not CustomSoulShardBarDB.anchorToPRD end,
				},
				anchorPosition = {
					type = "select",
					name = "位置",
					desc = "將靈魂裂片條放置在上方或下方。",
					values = { ABOVE = "上方", BELOW = "下方" },
					get = function() return CustomSoulShardBarDB.anchorPosition or "BELOW" end,
					set = function(_, val)
						CustomSoulShardBarDB.anchorPosition = val
						ApplyBarSettings()
					end,
					order = 3,
					disabled = function() return not CustomSoulShardBarDB.anchorToPRD end,
				},
				anchorOffset = {
					type = "range",
					name = "偏移",
					desc = "與對齊目標的距離 (像素)。",
					min = -100, max = 100, step = 1,
					get = function() return CustomSoulShardBarDB.anchorOffset or 10 end,
					set = function(_, val)
						CustomSoulShardBarDB.anchorOffset = val
						ApplyBarSettings()
					end,
					order = 4,
					disabled = function() return not CustomSoulShardBarDB.anchorToPRD end,
				},
			}
		},

        orbBgColor = {
            type = "color",
            name = "裂片背景顏色",
            hasAlpha = true,
            get = function() return unpack(CustomSoulShardBarDB.orbBgColor) end,
            set = function(_, r, g, b, a)
                CustomSoulShardBarDB.orbBgColor = {r, g, b, a}
                ApplyBarSettings()
                UpdateSoulShards()
            end,
            order = 5,
        },
        orbBgColor_reset = {
            type = "execute",
            name = "重設背景為透明",
            order = 5.1,
            func = function()
                CustomSoulShardBarDB.orbBgColor = {0, 0, 0, 0}
                ApplyBarSettings()
                UpdateSoulShards()
            end,
        },
        gradientColor1 = {
            type = "color",
            name = "漸層色 1",
            hasAlpha = true,
            get = function()
                local c = CustomSoulShardBarDB.gradientColor1 or {0.7, 0, 1, 1}
                if type(c) == "table" then
                    if c.r then
                        return tonumber(c.r) or 0.7, tonumber(c.g) or 0, tonumber(c.b) or 1, tonumber(c.a) or 1
                    else
                        return tonumber(c[1]) or 0.7, tonumber(c[2]) or 0, tonumber(c[3]) or 1, tonumber(c[4]) or 1
                    end
                end
                return 0.7, 0, 1, 1
            end,
            set = function(_, r, g, b, a)
                CustomSoulShardBarDB.gradientColor1 = {r = r, g = g, b = b, a = a}
                ApplyBarSettings()
                UpdateSoulShards()
            end,
            order = 6,
        },
        gradientColor1_reset = {
            type = "execute",
            name = "重設為預設",
            order = 6.1,
            func = function()
                CustomSoulShardBarDB.gradientColor1 = {0.7, 0, 1, 1}
                ApplyBarSettings()
                UpdateSoulShards()
            end,
        },
        gradientColor1_random = {
            type = "execute",
            name = "隨機化",
            order = 6.2,
            func = function()
                CustomSoulShardBarDB.gradientColor1 = {math.random(), math.random(), math.random(), 1}
                ApplyBarSettings()
                UpdateSoulShards()
            end,
        },
        gradientColor1_copy = {
            type = "input",
            name = "貼上 RGBA（逗號分隔）",
            order = 6.3,
            set = function(_, val)
                local r, g, b, a = string.match(val, "(%d*%.?%d+),%s*(%d*%.?%d+),%s*(%d*%.?%d+),%s*(%d*%.?%d+)")
                if r and g and b and a then
                    CustomSoulShardBarDB.gradientColor1 = {tonumber(r), tonumber(g), tonumber(b), tonumber(a)}
                    ApplyBarSettings()
                    UpdateSoulShards()
                end
            end,
            get = function()
                local c = CustomSoulShardBarDB.gradientColor1 or {0.7, 0, 1, 1}
                return string.format("%.3f, %.3f, %.3f, %.3f", SafeUnpackColor(c, {0.7, 0, 1, 1}))
            end,
        },
        gradientColor1_hex = {
            type = "description",
            name = function()
                local c = CustomSoulShardBarDB.gradientColor1 or {0.7, 0, 1, 1}
                local r, g, b, a = SafeUnpackColor(c, {0.7, 0, 1, 1})
                return string.format("十六進位: #%02X%02X%02X  透明度: %.2f", r*255, g*255, b*255, a)
            end,
            order = 6.4,
        },
        gradientColor1_presets = {
            type = "select",
            name = "預設",
            order = 6.5,
            values = {
                warlock = "經典術士（紫色）",
                rainbow = "彩虹（紅色）",
                green = "綠色",
                blue = "藍色",
                white = "白色",
                black = "黑色",
            },
            set = function(_, val)
                local presets = {
                    warlock = {0.7, 0, 1, 1},
                    rainbow = {1, 0, 0, 1},
                    green = {0, 1, 0, 1},
                    blue = {0, 0.5, 1, 1},
                    white = {1, 1, 1, 1},
                    black = {0, 0, 0, 1},
                }
                CustomSoulShardBarDB.gradientColor1 = presets[val] or {0.7, 0, 1, 1}
                ApplyBarSettings()
                UpdateSoulShards()
            end,
            get = function() return nil end,
        },
        gradientColor1_sync = {
            type = "execute",
            name = "同步兩個顏色",
            order = 6.6,
            func = function()
                CustomSoulShardBarDB.gradientColor2 = CustomSoulShardBarDB.gradientColor1
                ApplyBarSettings()
                UpdateSoulShards()
            end,
        },
        gradientColor1_swap = {
            type = "execute",
            name = "交換起始/結束",
            order = 6.7,
            func = function()
                local tmp = CustomSoulShardBarDB.gradientColor1
                CustomSoulShardBarDB.gradientColor1 = CustomSoulShardBarDB.gradientColor2
                CustomSoulShardBarDB.gradientColor2 = tmp
                ApplyBarSettings()
                UpdateSoulShards()
            end,
        },
        gradientColor2 = {
            type = "color",
            name = "漸層色 2",
            hasAlpha = true,
            get = function()
                local c = CustomSoulShardBarDB.gradientColor2 or {1, 0.2, 0.7, 1}
                if type(c) == "table" then
                    if c.r then
                        return tonumber(c.r) or 1, tonumber(c.g) or 0.2, tonumber(c.b) or 0.7, tonumber(c.a) or 1
                    else
                        return tonumber(c[1]) or 1, tonumber(c[2]) or 0.2, tonumber(c[3]) or 0.7, tonumber(c[4]) or 1
                    end
                end
                return 1, 0.2, 0.7, 1
            end,
            set = function(_, r, g, b, a)
                CustomSoulShardBarDB.gradientColor2 = {r = r, g = g, b = b, a = a}
                ApplyBarSettings()
                UpdateSoulShards()
            end,
            order = 7,
        },
        gradientColor2_reset = {
            type = "execute",
            name = "重設為預設",
            order = 7.1,
            func = function()
                CustomSoulShardBarDB.gradientColor2 = {1, 0.2, 0.7, 1}
                ApplyBarSettings()
                UpdateSoulShards()
            end,
        },
        gradientColor2_random = {
            type = "execute",
            name = "隨機化",
            order = 7.2,
            func = function()
                CustomSoulShardBarDB.gradientColor2 = {math.random(), math.random(), math.random(), 1}
                ApplyBarSettings()
                UpdateSoulShards()
            end,
        },
        gradientColor2_copy = {
            type = "input",
            name = "貼上 RGBA（逗號分隔）",
            order = 7.3,
            set = function(_, val)
                local r, g, b, a = string.match(val, "(%d*%.?%d+),%s*(%d*%.?%d+),%s*(%d*%.?%d+),%s*(%d*%.?%d+)")
                if r and g and b and a then
                    CustomSoulShardBarDB.gradientColor2 = {tonumber(r), tonumber(g), tonumber(b), tonumber(a)}
                    ApplyBarSettings()
                    UpdateSoulShards()
                end
            end,
            get = function()
                local c = CustomSoulShardBarDB.gradientColor2 or {1, 0.2, 0.7, 1}
                return string.format("%.3f, %.3f, %.3f, %.3f", SafeUnpackColor(c, {1, 0.2, 0.7, 1}))
            end,
        },
        gradientColor2_hex = {
            type = "description",
            name = function()
                local c = CustomSoulShardBarDB.gradientColor2 or {1, 0.2, 0.7, 1}
                local r, g, b, a = SafeUnpackColor(c, {1, 0.2, 0.7, 1})
                return string.format("十六進位: #%02X%02X%02X  透明度: %.2f", r*255, g*255, b*255, a)
            end,
            order = 7.4,
        },
        gradientColor2_presets = {
            type = "select",
            name = "預設",
            order = 7.5,
            values = {
                warlock = "經典術士（紫色）",
                rainbow = "彩虹（紅色）",
                green = "綠色",
                blue = "藍色",
                white = "白色",
                black = "黑色",
            },
            set = function(_, val)
                local presets = {
                    warlock = {1, 0.2, 0.7, 1},
                    rainbow = {1, 0, 0, 1},
                    green = {0, 1, 0, 1},
                    blue = {0, 0.5, 1, 1},
                    white = {1, 1, 1, 1},
                    black = {0, 0, 0, 1},
                }
                CustomSoulShardBarDB.gradientColor2 = presets[val] or {1, 0.2, 0.7, 1}
                ApplyBarSettings()
                UpdateSoulShards()
            end,
            get = function() return nil end,
        },
        gradientColor2_sync = {
            type = "execute",
            name = "同步兩個顏色",
            order = 7.6,
            func = function()
                CustomSoulShardBarDB.gradientColor1 = CustomSoulShardBarDB.gradientColor2
                ApplyBarSettings()
                UpdateSoulShards()
            end,
        },
        gradientColor2_swap = {
            type = "execute",
            name = "交換起始/結束",
            order = 7.7,
            func = function()
                local tmp = CustomSoulShardBarDB.gradientColor1
                CustomSoulShardBarDB.gradientColor1 = CustomSoulShardBarDB.gradientColor2
                CustomSoulShardBarDB.gradientColor2 = tmp
                ApplyBarSettings()
                UpdateSoulShards()
            end,
        },
        locked = {
            type = "toggle",
            name = "鎖定位置",
            get = function() return CustomSoulShardBarDB.locked end,
            set = function(_, val) CustomSoulShardBarDB.locked = val end,
            order = 8,
        },
        hideWhileMounted = {
            type = "toggle",
            name = "騎乘時隱藏",
            desc = "騎乘時隱藏自訂靈魂裂片條。",
            get = function() return CustomSoulShardBarDB.hideWhileMounted end,
            set = function(_, val)
                CustomSoulShardBarDB.hideWhileMounted = val
                UpdateVisibility()
            end,
            order = 9,
        },
        showOnlyInCombat = {
            type = "toggle",
            name = "只在戰鬥中顯示",
			desc = "只在你進入戰鬥時顯示自訂的靈魂裂片條。",
            get = function() return CustomSoulShardBarDB.showOnlyInCombat end,
            set = function(_, val)
                CustomSoulShardBarDB.showOnlyInCombat = val
                UpdateVisibility()
            end,
            order = 9.1,
        },
    },
}

-- Standalone AceConfig registration for Soul Shard Bar


ApplyBarSettings = nil
UpdateSoulShards = nil



-- Register Soul Shard Bar options in the main options UI
local function RegisterSoulShardBarOptions()
    if PersonalResourceReskinPlus_Options and PersonalResourceReskinPlus_Options.RegisterSubOptions then
        PersonalResourceReskinPlus_Options.RegisterSubOptions("CustomSoulShardBar", _G.CustomSoulShardBarOptions)
    end
end

RegisterSoulShardBarOptions()

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function()
    RegisterSoulShardBarOptions()
end)




-- Create the custom soul shard bar frame
local shardBar = CreateFrame("Frame", "CustomSoulShardBar", UIParent)
shardBar:SetSize(180, 32)
shardBar:SetPoint("CENTER", UIParent, "CENTER", CustomSoulShardBarDB.x, CustomSoulShardBarDB.y)
shardBar:SetFrameStrata("MEDIUM")
shardBar.orbs = {}

for i = 1, NUM_SOUL_SHARDS do
    local orb = CreateFrame("Frame", nil, shardBar)
    orb:SetSize(CustomSoulShardBarDB.orbWidth, CustomSoulShardBarDB.orbHeight)
    orb:SetPoint("LEFT", shardBar, "LEFT", (i-1)*(CustomSoulShardBarDB.orbWidth+6), 0)
    orb.bg = orb:CreateTexture(nil, "BACKGROUND")
    orb.bg:SetAllPoints()
    local bg = CustomSoulShardBarDB.orbBgColor or {0, 0, 0, 0.01}
    orb.bg:SetColorTexture(bg[1], bg[2], bg[3], bg[4] or 0.01)
    -- Fill texture only covers the filled portion
    orb.fill = orb:CreateTexture(nil, "ARTWORK")
    orb.fill:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT")
    orb.fill:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT")
    orb.fill:SetHeight(CustomSoulShardBarDB.orbHeight) 
    orb.borderTop = orb:CreateTexture(nil, "OVERLAY")
    orb.borderTop:SetColorTexture(0, 0, 0, 1)
    orb.borderTop:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
    orb.borderTop:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
    orb.borderTop:SetHeight(1)
    orb.borderBottom = orb:CreateTexture(nil, "OVERLAY")
    orb.borderBottom:SetColorTexture(0, 0, 0, 1)
    orb.borderBottom:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
    orb.borderBottom:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
    orb.borderBottom:SetHeight(1)
    orb.borderLeft = orb:CreateTexture(nil, "OVERLAY")
    orb.borderLeft:SetColorTexture(0, 0, 0, 1)
    orb.borderLeft:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
    orb.borderLeft:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
    orb.borderLeft:SetWidth(1)
    orb.borderRight = orb:CreateTexture(nil, "OVERLAY")
    orb.borderRight:SetColorTexture(0, 0, 0, 1)
    orb.borderRight:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
    orb.borderRight:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
    orb.borderRight:SetWidth(1)
    shardBar.orbs[i] = orb
end


if not shardBar.countText then
    shardBar.countText = shardBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    shardBar.countText:SetPoint("CENTER", shardBar, "CENTER", 0, 0)
    shardBar.countText:SetJustifyH("CENTER")
    shardBar.countText:SetJustifyV("MIDDLE")
    shardBar.countText:SetDrawLayer("OVERLAY", 1)
    local tooltipFrame = CreateFrame("Frame", nil, shardBar)
    tooltipFrame:SetAllPoints(shardBar.countText)
        tooltipFrame:SetFrameStrata("MEDIUM")
        shardBar.countText:SetParent(tooltipFrame)
    if shardBar.countText.SetFont then
        local font, size, flags = shardBar.countText:GetFont()
        shardBar.countText:SetFont(font, size, "OUTLINE")
        shardBar.countText:SetTextColor(1, 1, 1, 1)
    end
end

-- Update function
UpdateSoulShards = function()
    local current = UnitPower("player", SOUL_SHARD_POWER_TYPE, true) / 10
    local bg = CustomSoulShardBarDB.orbBgColor or {0, 0, 0, 0.01}
    local gradients = CustomSoulShardBarDB.gradients
    local fillDir = CustomSoulShardBarDB.fillDirection or "vertical"
    for i, orb in ipairs(shardBar.orbs) do
        orb.bg:SetColorTexture(bg[1], bg[2], bg[3], bg[4] or 0.01)
        local fillAmount = 0
        local shardIndex = i
        if current >= shardIndex then
            fillAmount = 1
        elseif current > (shardIndex - 1) then
            fillAmount = current - (shardIndex - 1)
        else
            fillAmount = 0
        end
        if fillAmount > 0 then
            orb.fill:Show()
            local c1, c2
            if gradients and gradients[i] then
                c1 = gradients[i][1]
                c2 = gradients[i][2]
            else
                c1 = CustomSoulShardBarDB.gradientColor1 or {0.7, 0, 1, 1}
                c2 = CustomSoulShardBarDB.gradientColor2 or {1, 0.2, 0.7, 1}
            end
            local r1, g1, b1, a1 = SafeUnpackColor(c1, {0.7, 0, 1, 1})
            local r2, g2, b2, a2 = SafeUnpackColor(c2, {1, 0.2, 0.7, 1})
            orb.fill:SetColorTexture(r1, g1, b1, a1)
            orb.fill:SetAlpha(1)

            orb.fill:ClearAllPoints()
            if fillDir == "vertical" then
                local totalHeight = CustomSoulShardBarDB.orbHeight
                orb.fill:SetHeight(totalHeight * fillAmount)
                orb.fill:SetWidth(CustomSoulShardBarDB.orbWidth)
                orb.fill:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT")
                orb.fill:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT")
            else -- horizontal
                local totalWidth = CustomSoulShardBarDB.orbWidth
                orb.fill:SetWidth(totalWidth * fillAmount)
                orb.fill:SetHeight(CustomSoulShardBarDB.orbHeight)
                orb.fill:SetPoint("LEFT", orb, "LEFT")
                orb.fill:SetPoint("TOPLEFT", orb, "TOPLEFT")
                orb.fill:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT")
            end
            if orb.fill.SetGradient then
                orb.fill:SetGradient("HORIZONTAL", CreateColor(r1, g1, b1, a1), CreateColor(r2, g2, b2, a2))
            end
            if orb.gradient then orb.gradient:Hide() end
        else
            orb.fill:Hide()
            if orb.gradient then orb.gradient:Hide() end
        end
    end

    local display = string.format("%.1f/%d", current, NUM_SOUL_SHARDS)
    shardBar.countText:SetText(display)
    if CustomSoulShardBarDB and CustomSoulShardBarDB.showCountText == false then
        shardBar.countText:Hide()
    else
        shardBar.countText:Show()
    end
end

-- Event handler
shardBar:RegisterEvent("UNIT_POWER_UPDATE")
shardBar:RegisterEvent("PLAYER_ENTERING_WORLD")
shardBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
shardBar:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_POWER_UPDATE" then
        local unit, powerType = ...
        if unit == "player" and (powerType == "SOUL_SHARDS" or powerType == SOUL_SHARD_POWER_TYPE) then
            UpdateSoulShards()
        end
    else
        UpdateSoulShards()
    end
end)

-- Only show for Warlock
local function ShouldShowSoulShardBar()
    local _, class = UnitClass("player")
    if class ~= "WARLOCK" then return false end
    if CustomSoulShardBarDB.hideWhileMounted and IsMounted and IsMounted() then
        return false
    end
    if CustomSoulShardBarDB.showOnlyInCombat and not InCombatLockdown() then
        return false
    end
    return true
end

function UpdateVisibility()
    if ShouldShowSoulShardBar() then
        shardBar:Show()
        UpdateSoulShards()
    else
        shardBar:Hide()
    end
end


local function FullUpdateHandler(self, event, ...)
    if ShouldShowSoulShardBar() then
        shardBar:Show()
        UpdateSoulShards()
        HideBlizzardSoulShardOrbs()
    else
        shardBar:Hide()
    end
end


shardBar:RegisterEvent("PLAYER_LOGIN")
shardBar:RegisterEvent("PLAYER_ENTERING_WORLD")
shardBar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
shardBar:RegisterEvent("UNIT_AURA") 
shardBar:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR") 
shardBar:RegisterEvent("PLAYER_REGEN_ENABLED")
shardBar:RegisterEvent("PLAYER_REGEN_DISABLED")
shardBar:SetScript("OnEvent", FullUpdateHandler)



-- PRD anchoring helpers (mirroring soulstrackerveng.lua)
local function GetPRDHealthBar()
    local prd = _G.PersonalResourceDisplayFrame
    if prd and prd.HealthBarsContainer and prd.HealthBarsContainer.healthBar then
        return prd.HealthBarsContainer.healthBar
    end
    return _G.PersonalResourceDisplayHealthBar
end

local function GetPRDPowerBar()
    local prd = _G.PersonalResourceDisplayFrame
    if prd and prd.PowerBarsContainer and prd.PowerBarsContainer.powerBar then
        return prd.PowerBarsContainer.powerBar
    end
    if prd and prd.PowerBar then
        return prd.PowerBar
    end
    return _G.PersonalResourceDisplayPowerBar
end

local function GetPRDAnchorFrame()
    if not CustomSoulShardBarDB.anchorToPRD then return nil end
    local target = CustomSoulShardBarDB.anchorTarget or "HEALTH"
    local f = (target == "POWER") and GetPRDPowerBar() or GetPRDHealthBar()
    return f
end

local prdHooked = false
local function HookPRDAnchor()
    local anchorFrame = GetPRDAnchorFrame()
    if not anchorFrame or prdHooked then return end
    local function OnPRDChange()
        ApplyBarSettings()
    end
    anchorFrame:HookScript("OnSizeChanged", OnPRDChange)
    if anchorFrame.SetPoint then
        hooksecurefunc(anchorFrame, "SetPoint", OnPRDChange)
    end
    if anchorFrame.SetScale then
        hooksecurefunc(anchorFrame, "SetScale", OnPRDChange)
    end
    prdHooked = true
end

ApplyBarSettings = function()
    local spacing = 0
    local totalWidth = (CustomSoulShardBarDB.orbWidth + spacing) * #shardBar.orbs - spacing
    shardBar:SetSize(totalWidth, CustomSoulShardBarDB.orbHeight)
    shardBar:ClearAllPoints()
    local anchorFrame = GetPRDAnchorFrame()
    if anchorFrame then
        local pos = CustomSoulShardBarDB.anchorPosition or "BELOW"
        local offset = CustomSoulShardBarDB.anchorOffset or 10
        if pos == "ABOVE" then
            shardBar:SetPoint("BOTTOM", anchorFrame, "TOP", 0, offset)
        else
            shardBar:SetPoint("TOP", anchorFrame, "BOTTOM", 0, -offset)
        end
        if not prdHooked then
            HookPRDAnchor()
        end
    else
        -- Use Bar X Position and Bar Y Position for SetPoint
        shardBar:SetPoint("CENTER", UIParent, "CENTER", CustomSoulShardBarDB.x or 0, CustomSoulShardBarDB.y or 0)
    end
    for i, orb in ipairs(shardBar.orbs) do
        orb:SetSize(CustomSoulShardBarDB.orbWidth, CustomSoulShardBarDB.orbHeight)
        orb:ClearAllPoints()
        orb:SetPoint("LEFT", shardBar, "LEFT", (i-1)*(CustomSoulShardBarDB.orbWidth+spacing), 0)
        -- Update border positions
        orb.borderTop:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
        orb.borderTop:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
        orb.borderTop:SetHeight(1)
        orb.borderBottom:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
        orb.borderBottom:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
        orb.borderBottom:SetHeight(1)
        orb.borderLeft:SetPoint("TOPLEFT", orb, "TOPLEFT", 0, 0)
        orb.borderLeft:SetPoint("BOTTOMLEFT", orb, "BOTTOMLEFT", 0, 0)
        orb.borderLeft:SetWidth(1)
        orb.borderRight:SetPoint("TOPRIGHT", orb, "TOPRIGHT", 0, 0)
        orb.borderRight:SetPoint("BOTTOMRIGHT", orb, "BOTTOMRIGHT", 0, 0)
        orb.borderRight:SetWidth(1)
    end
    if UpdateSoulShards then UpdateSoulShards() end
end

-- Slash commands for config
SLASH_CUSTOMSOULSHARDBAR1 = "/cssb"
SlashCmdList["CUSTOMSOULSHARDBAR"] = function(msg)
    local cmd, arg1, arg2 = msg:match("^(%S*)%s*(%-?%d*)%s*(%-?%d*)$")
    cmd = cmd:lower() or ""
    if cmd == "lock" then
        CustomSoulShardBarDB.locked = true
        print("CustomSoulShardBar 已鎖定。")
    elseif cmd == "unlock" then
        CustomSoulShardBarDB.locked = false
        print("CustomSoulShardBar 已解鎖，可拖曳移動。")
    elseif cmd == "size" and tonumber(arg1) and tonumber(arg2) then
        CustomSoulShardBarDB.orbWidth = tonumber(arg1)
        CustomSoulShardBarDB.orbHeight = tonumber(arg2)
        ApplyBarSettings()
        print("CustomSoulShardBar 大小已設為", arg1, arg2)
    else
        print("/cssb lock | unlock | size <寬度> <高度>")
    end
end


shardBar:SetMovable(true)
shardBar:EnableMouse(true)
shardBar:RegisterForDrag("LeftButton")
shardBar:SetScript("OnDragStart", function(self)
    if not CustomSoulShardBarDB.locked then self:StartMoving() end
end)
shardBar:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    CustomSoulShardBarDB.x = x or 0
    CustomSoulShardBarDB.y = y or 0
end)


local function OnLoginOrReload()
    ApplyBarSettings()
end
shardBar:RegisterEvent("PLAYER_LOGIN")
shardBar:HookScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        OnLoginOrReload()
    end
end)

-- Apply settings on load

