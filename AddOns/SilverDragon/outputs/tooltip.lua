local myname, ns = ...

local core = LibStub("AceAddon-3.0"):GetAddon("SilverDragon")
local module = core:NewModule("Tooltip", "AceEvent-3.0")
local Debug = core.Debug

function module:OnInitialize()
	self.db = core.db:RegisterNamespace("Tooltip", {
		profile = {
			achievement = true,
			drop = true,
			id = false,
			combatdrop = false,
			regularloot = true,
		},
	})

	local config = core:GetModule("Config", true)
	if config then
		config.options.args.general.plugins.tooltip = {
			tooltip = {
				type = "group",
				name = "浮動提示",
				inline = true,
				order = 93,
				get = function(info) return self.db.profile[info[#info]] end,
				set = function(info, v) self.db.profile[info[#info]] = v end,
				args = {
					about = config.desc("在怪物的浮動提示中顯示額外資訊。稀有怪也會顯示是否仍需擊殺以完成成就。", 0),
					achievement = config.toggle("成就", "顯示是否仍需擊殺此稀有怪以完成成就", 1),
					drop = config.toggle("掉落物品", "顯示是否仍需要此怪物掉落的物品", 2),
					combatdrop = config.toggle("戰鬥中也顯示", "戰鬥中也顯示掉落物品", 3),
					regularloot = config.toggle("包含一般戰利品", "同時列出一般物品，不限於能判斷是否已收藏的坐騎或玩具等。地圖標示也使用此設定。", 4),
					id = config.toggle("怪物 ID", "在浮動提示中顯示怪物 ID", 5),
				},
			},
		}
	end
end

function module:OnEnable()
	if _G.C_TooltipInfo then
		-- Cata-classic has TooltipDataProcessor, but doesn't actually use the new tooltips
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, tooltipData)
			if tooltip ~= GameTooltip then return end
			module:UpdateTooltip(ns.IdFromGuid(tooltipData and tooltipData.guid))
		end)
	else
		GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
			local name, unit = tooltip:GetUnit()
			if unit then
				module:UpdateTooltip(core:UnitID(unit))
			end
		end)
	end
end

-- Whether to leave out the plain items and list only the things we can tell
-- whether you already have. The map overlay's tooltips ask this too, so the
-- answer lives here rather than being set up again per-map.
function module:OnlyKnowableLoot()
	return not self.db.profile.regularloot
end

-- This is split out entirely so I can test this without having to actually hunt down a rare:
-- /script SilverDragon:GetModule('Tooltip'):UpdateTooltip(51059)
-- /script SilverDragon:GetModule('Tooltip'):UpdateTooltip(32491)
function module:UpdateTooltip(id, force_achievement, force_drop, force_id)
	if not id then
		return
	end

	if force_achievement or (self.db.profile.achievement and force_achievement ~= false) then
		ns:UpdateTooltipWithCompletion(GameTooltip, id)
	end

	if force_drop or ((self.db.profile.drop and (self.db.profile.combatdrop or not InCombatLockdown())) and force_drop ~= false) then
		ns.Loot.Summary.UpdateTooltip(GameTooltip, id, self:OnlyKnowableLoot())
	end

	if ns.mobdb[id] and ns.mobdb[id].notes then
		GameTooltip:AddLine(core:RenderString(ns.mobdb[id].notes), 1, 1, 1, true)
	end

	if core:ShouldIgnoreMob(id) then
		GameTooltip:AddLine("SilverDragon is ignoring this mob", 1, 0.5, 0)
	end

	if force_id or (self.db.profile.id and force_id ~= false) then
		GameTooltip:AddDoubleLine(ID, id, 1, 1, 0, 1, 1, 0)
	end

	GameTooltip:Show()
end
