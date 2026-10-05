local myname, ns = ...

local core = LibStub("AceAddon-3.0"):GetAddon("SilverDragon")
local module = core:GetModule("Browser")
local Debug = core.Debug

local LibWindow = LibStub("LibWindow-1.1")

function module:RegisterConfig()
	local config = core:GetModule("Config", true)
	if not config then return end
	config.options.plugins.browser = { browser = {
		type = "group",
		name = "稀有怪瀏覽器",
		order = 16, -- straight after Mobs, which is where the rest of this lives
		get = function(info) return self.db.profile[info[#info]] end,
		set = function(info, v)
			self.db.profile[info[#info]] = v
			self:Refresh()
		end,
		args = {
			about = config.desc("列出所有已知稀有怪、出現位置與掉落戰利品的瀏覽視窗。", 0),
			open = {
				type = "execute",
				name = "瀏覽稀有怪",
				func = function() self:Toggle() end,
				order = 5,
			},
			style = {
				type = "select",
				name = "樣式",
				desc = "視窗的外觀樣式",
				values = function(info)
					local values = {}
					for key in pairs(self.Looks) do
						values[key] = core:GetModule("Config").LookName(key)
					end
					-- replace ourself with the built values table
					info.option.values = values
					return values
				end,
				set = function(info, v)
					self:SetLook(v)
				end,
				order = 10,
			},
			model = {
				type = "toggle",
				name = "顯示 3D 模型",
				desc = "是否顯示所選稀有怪的完整 3D 模型",
				set = function(info, v)
					self.db.profile[info[#info]] = v
					if self.window then
						self.window.detailPane:SetMob(self.selectedMob)
					end
				end,
				order = 15,
			},
			showMap = {
				type = "toggle",
				name = "顯示地圖",
				desc = "是否顯示區域地圖並標示稀有怪位置",
				set = function(info, v)
					self.db.profile[info[#info]] = v
					if self.window then
						self.window:Layout()
					end
				end,
				order = 20,
			},
			mapShowAll = {
				type = "toggle",
				name = "顯示區域內其他稀有怪",
				desc = "選取稀有怪時，是否將區域內其他稀有怪以淡化圖示保留在地圖上；停用則隱藏。",
				set = function(info, v)
					self.db.profile[info[#info]] = v
					self:RefreshMap()
				end,
				order = 25,
			},
			scale = {
				type = "range",
				name = UI_SCALE,
				width = "full",
				min = 0.5, max = 2, step = 0.05, isPercent = true,
				get = function() return self.db.profile.position.scale end,
				set = function(info, v)
					if not self.window then return end
					LibWindow.SetScale(self.window, v)
				end,
				order = 30,
			},
			style_options = {
				type = "group",
				name = "樣式選項",
				order = 40,
				-- no style has any yet, and an empty tab reads as a fault
				hidden = function()
					return not next(self.LookConfig)
				end,
				get = function(info)
					local value = self.db.profile.style_options[info[#info - 1]][info[#info]]
					if info.type == "color" then
						return unpack(value)
					end
					return value
				end,
				set = function(info, ...)
					local value = ...
					if info.type == "color" then
						value = {...}
					end
					self.db.profile.style_options[info[#info - 1]][info[#info]] = value
					if self.window and self.window.look == info[#info - 1] then
						self:ResetLook(self.window)
						self:ApplyLook(self.window, self.window.look)
					end
				end,
				args = self.LookConfig,
			},
		},
	} }
end
