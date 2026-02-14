
local LMB = LibStub("Masque", true)
if not LMB then return end

local Buffs = LMB:Group("內建增益/減益", "增益")
local Debuffs = LMB:Group("內建增益/減益", "減益")
local TargetBuffs = LMB:Group("內建增益/減益", "目標增益")
local TargetDebuffs = LMB:Group("內建增益/減益", "目標減益")


local dispelColorCurve
if C_CurveUtil then
	local DEBUFF_DISPLAY_COLOR_INFO = {
		[0] = DEBUFF_TYPE_NONE_COLOR,
		[1] = DEBUFF_TYPE_MAGIC_COLOR,
		[2] = DEBUFF_TYPE_CURSE_COLOR,
		[3] = DEBUFF_TYPE_DISEASE_COLOR,
		[4] = DEBUFF_TYPE_POISON_COLOR,
		[9] = DEBUFF_TYPE_BLEED_COLOR, -- enrage
		[11] = DEBUFF_TYPE_BLEED_COLOR,
	}
	dispelColorCurve = C_CurveUtil.CreateColorCurve()
	dispelColorCurve:SetType(Enum.LuaCurveType.Step)
	for i, c in pairs(DEBUFF_DISPLAY_COLOR_INFO) do
		dispelColorCurve:AddPoint(i, c)
	end
end

if AuraButtonMixin then
	-- Dragonflight+
	local skinned = {}

	local function makeHook(group, container)
		local function updateFrames(frames)
			for i = 1, #frames do
				local frame = frames[i]
				if frame.Icon.GetTexture then
					local skinWrapper = skinned[frame]
					if not skinned[frame] then

						-- We have to make a wrapper to hold the skinnable components of the Icon
						-- because the aura frames are not square (and so if we skinned them directly
						-- with Masque, they'd get all distorted and weird).
						skinWrapper = CreateFrame("Frame")
						skinned[frame] = skinWrapper
						skinWrapper:SetParent(frame)
						skinWrapper:SetSize(30, 30)

						-- Blizzard's code constantly tries to reposition the icon,
						-- so we have to make our own icon that it won't try to move.
						frame.Icon:Hide()
						frame.SkinnedIcon = skinWrapper:CreateTexture(nil, "BACKGROUND")
						frame.SkinnedIcon:SetSize(30, 30)
						frame.SkinnedIcon:SetPoint("CENTER")
						frame.SkinnedIcon:SetTexture(frame.Icon:GetTexture())
						hooksecurefunc(frame.Icon, "SetTexture", function(_, tex)
							frame.SkinnedIcon:SetTexture(tex)
						end)

						if frame.Count then
							-- edit mode versions don't have stack text
							frame.Count:SetParent(skinWrapper);
						end
						if frame.DebuffBorder then
							frame.DebuffBorder:SetParent(skinWrapper);
							if AuraUtil.SetAuraBorderAtlas and dispelColorCurve then
								-- WoW Midnight+ - convert atlas that can't be skinned into vertex color
								local texture
								hooksecurefunc(frame.DebuffBorder, "SetAtlas", function(self, atlas)
									if texture then
										self:SetTexture(texture)
									end

									if not issecretvalue(atlas) then
										-- This handles edit mode, and auras out of secret lockdown.
										for type, info in pairs(AuraUtil.GetDebuffDisplayInfoTable()) do
											if atlas == info.dispelAtlas or atlas == info.basicAtlas then
												self:SetVertexColor(info.color:GetRGB())
												return
											end
										end
									end

									-- Handle auras while in combat, where atlas is secret.

									local buttonInfo = frame.buttonInfo

									local auraInstanceID = frame.deadlyInstanceID or (buttonInfo and buttonInfo.auraInstanceID)
									if not auraInstanceID and buttonInfo and buttonInfo.index then
										local aura = C_UnitAuras.GetAuraDataByIndex(frame.unit, buttonInfo.index, frame:GetFilter())
										auraInstanceID = aura and aura.auraInstanceID
									end
									if not auraInstanceID then
										self:SetVertexColor(DEBUFF_TYPE_NONE_COLOR:GetRGB())
										return
									end

									local color = C_UnitAuras.GetAuraDispelTypeColor("player", auraInstanceID, dispelColorCurve)
									self:SetVertexColor(color:GetRGB())
								end)
								hooksecurefunc(frame.DebuffBorder, "SetTexture", function(self, tex)
									-- Capture the texture that gets set by masque so we can override it after the atlas gets set
									texture	= tex
								end)
							end
						end
						if frame.TempEnchantBorder then
							frame.TempEnchantBorder:SetParent(skinWrapper);
							frame.TempEnchantBorder:SetVertexColor(.75, 0, 1)
						end
						if frame.Symbol then
							-- Shows debuff types as text in colorblind mode (except it currently doesnt work)
							frame.Symbol:SetParent(skinWrapper);
						end

						local bType = frame.auraType or "Aura"

						if bType == "DeadlyDebuff" then
							bType = "Debuff"
						end

						group:AddButton(skinWrapper, {
							Icon = frame.SkinnedIcon,
							DebuffBorder = frame.DebuffBorder,
							EnchantBorder = frame.TempEnchantBorder,
							Count = frame.Count,
							HotKey = frame.Symbol
						}, bType)
					end

					-- Update wrapper position (can change via edit mode)
					local auraContainer = container.AuraContainer
					local point = "TOP"
					if auraContainer then
						if auraContainer.isHorizontal then
							if auraContainer.addIconsToTop then
								point = "BOTTOM"
							end
						else
							if auraContainer.addIconsToRight then
								point = "LEFT"
							else
								point = "RIGHT"
							end
						end
					end
					skinWrapper:ClearAllPoints()
					skinWrapper:SetPoint(point)
				end
			end
		end

		return function(self)
			updateFrames(self.auraFrames, group)
			if self.exampleAuraFrames then
				updateFrames(self.exampleAuraFrames, group)
			end
		end
	end

	local buffHook = makeHook(Buffs, BuffFrame)
	hooksecurefunc(BuffFrame, "UpdateAuraButtons", buffHook)
	hooksecurefunc(BuffFrame, "OnEditModeEnter", buffHook)
	hooksecurefunc(BuffFrame, "UpdateGridLayout", buffHook)

	local debuffHook = makeHook(Debuffs, DebuffFrame)
	hooksecurefunc(DebuffFrame, "UpdateAuraButtons", debuffHook)
	hooksecurefunc(DebuffFrame, "OnEditModeEnter", debuffHook)
	hooksecurefunc(DebuffFrame, "UpdateGridLayout", debuffHook)

	-- Target frame buffs/debuffs (uses auraPools with TargetBuffFrameTemplate/TargetDebuffFrameTemplate)
	local targetSkinned = {}
	local function skinTargetAuraFrame(frame, group, auraType)
		if targetSkinned[frame] then return end
		targetSkinned[frame] = true

		group:AddButton(frame, {
			Icon = frame.Icon,
			Border = frame.Border,
			Count = frame.Count,
			Cooldown = frame.Cooldown,
		}, auraType)
	end

	local function hookTargetFrameAuras(targetFrame)
		hooksecurefunc(targetFrame, "UpdateAuras", function(self)
			if not self.auraPools then return end

			local buffPool = self.auraPools:GetPool("TargetBuffFrameTemplate")
			local debuffPool = self.auraPools:GetPool("TargetDebuffFrameTemplate")

			if buffPool then
				for frame in buffPool:EnumerateActive() do
					skinTargetAuraFrame(frame, TargetBuffs, "Buff")
				end
			end

			if debuffPool then
				for frame in debuffPool:EnumerateActive() do
					skinTargetAuraFrame(frame, TargetDebuffs, "Debuff")
				end
			end
		end)
	end

	hookTargetFrameAuras(TargetFrame)
	hookTargetFrameAuras(FocusFrame)
else
	local f = CreateFrame("Frame")
	local TempEnchant = LMB:Group("Blizzard Buffs", "TempEnchant")

	local function NULL()
	end

	local function OnEvent(self, event, addon)
		for i=1, BUFF_MAX_DISPLAY do
			local buff = _G["BuffButton"..i]
			if buff then
				Buffs:AddButton(buff, nil, "Buff")
			end
			if not buff then break end
		end

		for i=1, BUFF_MAX_DISPLAY do
			local debuff = _G["DebuffButton"..i]
			if debuff then
				Debuffs:AddButton(debuff, nil, "Debuff")
			end
			if not debuff then break end
		end

		for i=1, (NUM_TEMP_ENCHANT_FRAMES or 3) do
			local f = _G["TempEnchant"..i]
			--_G["TempEnchant"..i.."Border"].SetTexture = NULL
			if TempEnchant then
				TempEnchant:AddButton(f, nil, "Enchant")
			end
			_G["TempEnchant"..i.."Border"]:SetVertexColor(.75, 0, 1)
		end

		f:SetScript("OnEvent", nil)
	end

	hooksecurefunc("CreateFrame", function (_, name, parent) --dont need to do this for TempEnchant enchant frames because they are hard created in xml
		if parent ~= BuffFrame or type(name) ~= "string" then return end
		if strfind(name, "^DebuffButton%d+$") then
			Debuffs:AddButton(_G[name], nil, "Debuff")
			Debuffs:ReSkin() -- Needed to prevent issues with stack text appearing under the frame.
		elseif strfind(name, "^BuffButton%d+$") then
			Buffs:AddButton(_G[name], nil, "Buff")
			Buffs:ReSkin() -- Needed to prevent issues with stack text appearing under the frame.
		end
	end
	)

	f:SetScript("OnEvent", OnEvent)
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
end
