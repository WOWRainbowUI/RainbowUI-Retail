
-- Ensure we have the correct button size by waiting on login
local ApplyActionBarSkinOnLogin = CreateFrame("Frame")
ApplyActionBarSkinOnLogin:RegisterEvent("PLAYER_LOGIN")
ApplyActionBarSkinOnLogin:SetScript("OnEvent", function()

	local IsAddOnEnabled = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded
	if IsAddOnEnabled("HideButtonGlow") then return end

	local function CreateGoldenBorder(button) -- hooksecurefunc("ActionButton_SetupOverlayGlow", function(button)

		if button.HideActionbarAnimations_SpellActivationAlert then return end

		local overlay = CreateFrame("Frame", nil, button)
		button.HideActionbarAnimations_SpellActivationAlert = overlay

		overlay.Spark = overlay:CreateTexture(nil, "BACKGROUND")
		overlay.Spark:SetPoint("CENTER")
		overlay.Spark:SetAlpha(0)
		overlay.Spark:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		overlay.Spark:SetTexCoord(0.00781250, 0.61718750, 0.00390625, 0.26953125)

		overlay.InnerGlow = overlay:CreateTexture(nil, "ARTWORK")
		overlay.InnerGlow:SetPoint("CENTER")
		overlay.InnerGlow:SetAlpha(0)
		overlay.InnerGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		overlay.InnerGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)

		overlay.InnerGlowOver = overlay:CreateTexture(nil, "ARTWORK")
		overlay.InnerGlowOver:SetPoint("TOPLEFT", overlay.InnerGlow, "TOPLEFT")
		overlay.InnerGlowOver:SetPoint("BOTTOMRIGHT", overlay.InnerGlow, "BOTTOMRIGHT")
		overlay.InnerGlowOver:SetAlpha(0)
		overlay.InnerGlowOver:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		overlay.InnerGlowOver:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)

		overlay.OuterGlow = overlay:CreateTexture(nil, "ARTWORK")
		overlay.OuterGlow:SetPoint("CENTER")
		overlay.OuterGlow:SetAlpha(0)
		overlay.OuterGlow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		overlay.OuterGlow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)

		overlay.OuterGlowOver = overlay:CreateTexture(nil, "ARTWORK")
		overlay.OuterGlowOver:SetPoint("TOPLEFT", overlay.OuterGlow, "TOPLEFT")
		overlay.OuterGlowOver:SetPoint("BOTTOMRIGHT", overlay.OuterGlow, "BOTTOMRIGHT")
		overlay.OuterGlowOver:SetAlpha(0)
		overlay.OuterGlowOver:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
		overlay.OuterGlowOver:SetTexCoord(0.00781250, 0.50781250, 0.53515625, 0.78515625)

		overlay.Ants = overlay:CreateTexture(nil, "OVERLAY")
		overlay.Ants:SetPoint("CENTER")
		overlay.Ants:SetAlpha(0)
		overlay.Ants:SetTexture("Interface\\SpellActivationOverlay\\IconAlertAnts")

		overlay:SetScript("OnUpdate", function(button, elapsed)
			AnimateTexCoords(button.Ants, 256, 256, 48, 48, 22, elapsed, 0.01)
			local cooldown = button:GetParent().cooldown
			-- we need some threshold to avoid dimming the glow during the gdc
			-- (using 1500 exactly seems risky, what if casting speed is slowed or something?)
			if(cooldown and cooldown:IsShown() and cooldown:GetCooldownDuration() > 3000) then
				button:SetAlpha(0.5)
			else
				button:SetAlpha(1.0)
			end
		end)

		overlay.animIn = overlay:CreateAnimationGroup()
    
			local SparkScale = overlay.animIn:CreateAnimation("Scale") SparkScale:SetTarget(overlay.Spark) SparkScale:SetDuration(0.2) SparkScale:SetScale(1.5, 1.5) SparkScale:SetOrder(1)
			local SparkAlpha = overlay.animIn:CreateAnimation("Alpha") SparkAlpha:SetTarget(overlay.Spark) SparkAlpha:SetDuration(0.2) SparkAlpha:SetFromAlpha(0) SparkAlpha:SetToAlpha(1) SparkAlpha:SetOrder(1)
			local InnerGlowScale = overlay.animIn:CreateAnimation("Scale") InnerGlowScale:SetTarget(overlay.InnerGlow) InnerGlowScale:SetDuration(0.3) InnerGlowScale:SetScale(2, 2) InnerGlowScale:SetOrder(1)
			local InnerGlowOverScale = overlay.animIn:CreateAnimation("Scale") InnerGlowOverScale:SetTarget(overlay.InnerGlowOver) InnerGlowOverScale:SetDuration(0.3) InnerGlowOverScale:SetScale(2, 2) InnerGlowOverScale:SetOrder(1)
			local InnerGlowOverAlpha = overlay.animIn:CreateAnimation("Alpha") InnerGlowOverAlpha:SetTarget(overlay.InnerGlowOver) InnerGlowOverAlpha:SetDuration(0.3) InnerGlowOverAlpha:SetFromAlpha(1) InnerGlowOverAlpha:SetToAlpha(0) InnerGlowOverAlpha:SetOrder(1)
			local OuterGlowScale = overlay.animIn:CreateAnimation("Scale") OuterGlowScale:SetTarget(overlay.OuterGlow) OuterGlowScale:SetDuration(0.3) OuterGlowScale:SetScale(0.5, 0.5) OuterGlowScale:SetOrder(1)
			local OuterGlowOverScale = overlay.animIn:CreateAnimation("Scale") OuterGlowOverScale:SetTarget(overlay.OuterGlowOver) OuterGlowOverScale:SetDuration(0.3) OuterGlowOverScale:SetScale(0.5, 0.5) OuterGlowOverScale:SetOrder(1)
			local OuterGlowOverAlpha = overlay.animIn:CreateAnimation("Alpha") OuterGlowOverAlpha:SetTarget(overlay.OuterGlowOver) OuterGlowOverAlpha:SetDuration(0.3) OuterGlowOverAlpha:SetFromAlpha(1) OuterGlowOverAlpha:SetToAlpha(0) OuterGlowOverAlpha:SetOrder(1)
			local Spark2Scale = overlay.animIn:CreateAnimation("Scale") Spark2Scale:SetTarget(overlay.Spark) Spark2Scale:SetStartDelay(0.2) Spark2Scale:SetDuration(0.2) Spark2Scale:SetScale(0.666666, 0.666666) Spark2Scale:SetOrder(1)
			local Spark2Alpha = overlay.animIn:CreateAnimation("Alpha") Spark2Alpha:SetTarget(overlay.Spark) Spark2Alpha:SetStartDelay(0.2) Spark2Alpha:SetDuration(0.2) Spark2Alpha:SetFromAlpha(1) Spark2Alpha:SetToAlpha(0) Spark2Alpha:SetOrder(1)
			local InnerGlowAlpha = overlay.animIn:CreateAnimation("Alpha") InnerGlowAlpha:SetTarget(overlay.InnerGlow) InnerGlowAlpha:SetStartDelay(0.3) InnerGlowAlpha:SetDuration(0.2) InnerGlowAlpha:SetFromAlpha(1) InnerGlowAlpha:SetToAlpha(0) InnerGlowAlpha:SetOrder(1)
			local AntsAlpha = overlay.animIn:CreateAnimation("Alpha") AntsAlpha:SetTarget(overlay.Ants) AntsAlpha:SetStartDelay(0.3) AntsAlpha:SetDuration(0.2) AntsAlpha:SetFromAlpha(0) AntsAlpha:SetToAlpha(1) AntsAlpha:SetOrder(1)

		overlay.animIn:SetScript("OnPlay", function(button)
			local frame = button:GetParent()
			local frameWidth, frameHeight = frame:GetSize()
			frame.Spark:SetSize(frameWidth, frameHeight)
			frame.Spark:SetAlpha(0.3)
			frame.InnerGlow:SetSize(frameWidth / 2, frameHeight / 2)
			frame.InnerGlow:SetAlpha(1.0)
			frame.InnerGlowOver:SetAlpha(1.0)
			frame.OuterGlow:SetSize(frameWidth * 2, frameHeight * 2)
			frame.OuterGlow:SetAlpha(1.0)
			frame.OuterGlowOver:SetAlpha(1.0)
			frame.Ants:SetSize(frameWidth * 0.85, frameHeight * 0.85)
			frame.Ants:SetAlpha(0)
			frame:Show()
		end)

		overlay.animIn:SetScript("OnFinished", function(button)
			local frame = button:GetParent()
			local frameWidth, frameHeight = frame:GetSize()
			frame.Spark:SetAlpha(0)
			frame.InnerGlow:SetAlpha(0)
			frame.InnerGlow:SetSize(frameWidth, frameHeight)
			frame.InnerGlowOver:SetAlpha(0.0)
			frame.OuterGlow:SetSize(frameWidth, frameHeight)
			frame.OuterGlowOver:SetAlpha(0.0)
			frame.OuterGlowOver:SetSize(frameWidth, frameHeight)
			frame.Ants:SetAlpha(1.0)
		end)

		overlay.animOut = overlay:CreateAnimationGroup()

			local OuterGlowOverAlpha = overlay.animOut:CreateAnimation("Alpha") OuterGlowOverAlpha:SetTarget(overlay.OuterGlowOver) OuterGlowOverAlpha:SetDuration(0.2) OuterGlowOverAlpha:SetFromAlpha(0) OuterGlowOverAlpha:SetToAlpha(1) OuterGlowOverAlpha:SetOrder(1)
			local AntsAlpha = overlay.animOut:CreateAnimation("Alpha") AntsAlpha:SetTarget(overlay.Ants) AntsAlpha:SetDuration(0.2) AntsAlpha:SetFromAlpha(1) AntsAlpha:SetToAlpha(0) AntsAlpha:SetOrder(1)
			local OuterGlowOverAlpha = overlay.animOut:CreateAnimation("Alpha") OuterGlowOverAlpha:SetTarget(overlay.OuterGlowOver) OuterGlowOverAlpha:SetDuration(0.2) OuterGlowOverAlpha:SetFromAlpha(1) OuterGlowOverAlpha:SetToAlpha(0) OuterGlowOverAlpha:SetOrder(2)
			local OuterGlowAlpha = overlay.animOut:CreateAnimation("Alpha") OuterGlowAlpha:SetTarget(overlay.OuterGlow) OuterGlowAlpha:SetDuration(0.2) OuterGlowAlpha:SetFromAlpha(1) OuterGlowAlpha:SetToAlpha(0) OuterGlowAlpha:SetOrder(2)

		overlay.animOut:SetScript("OnFinished", function(button)
			local overlay = button:GetParent()
			overlay:Hide()
		end)

	end --end)

    hooksecurefunc("ActionButton_ShowOverlayGlow", function(button)
		if button.HideActionbarAnimations_SpellActivationAlert then
			if not button.HideActionbarAnimations_SpellActivationAlert:IsVisible() then
				button.HideActionbarAnimations_SpellActivationAlert:Show()
				button.HideActionbarAnimations_SpellActivationAlert.animIn:Play()
			end
			if button.HideActionbarAnimations_SpellActivationAlert.animOut:IsPlaying() then
				button.HideActionbarAnimations_SpellActivationAlert.animOut:Stop()
				button.HideActionbarAnimations_SpellActivationAlert.animIn:Play()
			end
		else
			CreateGoldenBorder(button)
			local frameWidth, frameHeight = button:GetSize()
			button.HideActionbarAnimations_SpellActivationAlert:ClearAllPoints()
			button.HideActionbarAnimations_SpellActivationAlert:SetSize(frameWidth * 1.4, frameHeight * 1.4)
			button.HideActionbarAnimations_SpellActivationAlert:SetPoint("TOPLEFT", button, "TOPLEFT", -frameWidth * 0.2, frameHeight * 0.2)
			button.HideActionbarAnimations_SpellActivationAlert:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", frameWidth * 0.2, -frameHeight * 0.2)
			button.HideActionbarAnimations_SpellActivationAlert.animIn:Play()
		end
		-- Hide the 10.1.5 ones
		button.SpellActivationAlert:Hide() --button.SpellActivationAlert.ProcStartFlipbook:Hide() button.SpellActivationAlert.ProcLoopFlipbook:Hide()
    end)

    hooksecurefunc("ActionButton_HideOverlayGlow", function(button)
		if not button.HideActionbarAnimations_SpellActivationAlert then return end

        if button.HideActionbarAnimations_SpellActivationAlert.animIn:IsPlaying() then
            button.HideActionbarAnimations_SpellActivationAlert.animIn:Stop()
        end

        if button:IsVisible() then
			button.HideActionbarAnimations_SpellActivationAlert.animOut:Play()
		else
			button.HideActionbarAnimations_SpellActivationAlert:Hide() --We aren't shown anyway, so we'll instantly hide it.
        end
    end)

end)
