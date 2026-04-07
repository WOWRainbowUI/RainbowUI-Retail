local _, DR = ...

local L = DR.L
local defaultsTable = DR.defaultsTable

---@type LibAdvFlight
local LibAdvFlight = LibStub:GetLibrary("LibAdvFlight-1.1")

local SCROLL_DURATION = 40
local GROUND_SKIM_AURA = 404184
local ANIM_DURATION = 0.35
local gsScrollPaused = false

local function GetGroundSkimmingColor()
	if DragonRider_DB and DragonRider_DB.groundSkimmingColor and DragonRider_DB.groundSkimmingColor.main then
		local c = DragonRider_DB.groundSkimmingColor.main;
		return c.r or 0.45, c.g or 0.85, c.b or 1.0, c.a or 1.0;
	end
	return 0.45, 0.85, 1.0, 1.0;
end

local function CreateFlareFrame(name, flipV, parent)
	local frame = CreateFrame("Frame", name, parent)
	frame:SetSize(256, 32)

	local baseFlare = frame:CreateTexture(nil, "BACKGROUND")
	baseFlare:SetAtlas("UI-HUD-Nameplates-Aggro-Flare")
	baseFlare:SetAllPoints(frame)
	baseFlare:SetHorizTile(true)

	local additiveFlare = frame:CreateTexture(nil, "BACKGROUND")
	additiveFlare:SetAtlas("UI-HUD-Nameplates-Aggro-Flare")
	additiveFlare:SetAllPoints(frame)
	additiveFlare:SetHorizTile(true)
	additiveFlare:SetBlendMode("ADD")
	additiveFlare:SetAlpha(0.4)

	local flareMask = frame:CreateMaskTexture()
	flareMask:SetAllPoints(frame)
	if flipV then
		flareMask:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\uinameplatesmask_flipped.png");
	else
		flareMask:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\uinameplatesmask.png");
	end
	baseFlare:AddMaskTexture(flareMask)
	additiveFlare:AddMaskTexture(flareMask)

	frame.baseFlare = baseFlare
	frame.additiveFlare = additiveFlare
	frame.flareMask = flareMask
	frame.isVertical = false
	frame.flipV = flipV

	return frame
end

local gsContainer = CreateFrame("Frame", "DragonRider_GroundSkimming", UIParent)
gsContainer:SetAlpha(0)
gsContainer:Hide()
DR.groundSkimmingContainer = gsContainer

local topFrame = CreateFlareFrame("CenterAggroFlareTop", false, gsContainer)
local bottomFrame = CreateFlareFrame("CenterAggroFlareBottom", true, gsContainer)

local scrollU = 0

gsContainer:SetScript("OnUpdate", function(self, elapsed)
	if gsScrollPaused then
		--topFrame.additiveFlare:SetTexCoord(0, 0.5, 0.0078125, 0.4765625);
		--topFrame.baseFlare:SetTexCoord( 0, -0.5, 0.0078125, 0.4765625);
		--bottomFrame.additiveFlare:SetTexCoord(0, 0.5, 0.0078125, 0.4765625);
		--bottomFrame.baseFlare:SetTexCoord( 0, -0.5, 0.0078125, 0.4765625);
		return
	end

	scrollU = (scrollU + elapsed / SCROLL_DURATION) % 1

	for _, f in ipairs({ topFrame, bottomFrame }) do
		local vTop = f.flipV and 1 or 0;
		local vBottom = f.flipV and 0 or 1;

		if f.isVertical then
			f.additiveFlare:SetTexCoord(scrollU + 1, vBottom, scrollU, vBottom, scrollU + 1, vTop, scrollU, vTop);
			f.baseFlare:SetTexCoord(-scrollU + 1, vBottom, -scrollU, vBottom, -scrollU + 1, vTop, -scrollU, vTop);
		else
			f.baseFlare:SetTexCoord(scrollU, scrollU + 1, vTop, vBottom);
			f.additiveFlare:SetTexCoord(-scrollU, -scrollU + 1, vTop, vBottom);
		end
	end
end)

function DR.UpdateGroundSkimmingLayout()
	if not DR.vigorBar then return end
	
	local w, h = DR.vigorBar:GetSize()
	if w == 0 or h == 0 then return end
	
	gsContainer:SetSize(w, h)
	topFrame:SetSize(w, h)
	bottomFrame:SetSize(w, h)
	
	local orientation = (DragonRider_DB and DragonRider_DB.vigorBarOrientation) or "Horizontal"
	local isVertical = (orientation == "Vertical")
	
	topFrame.isVertical = isVertical
	bottomFrame.isVertical = isVertical
	
	if isVertical then
		topFrame:ClearAllPoints();
		bottomFrame:ClearAllPoints();
		topFrame:SetPoint("LEFT", gsContainer, "CENTER", -(topFrame:GetWidth()*.04), 0);
		bottomFrame:SetPoint("RIGHT", gsContainer, "CENTER", (bottomFrame:GetWidth()*.04), 0);

		topFrame.flareMask:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\uinameplatesmask_right.png");
		bottomFrame.flareMask:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\uinameplatesmask_left.png");
	else
		topFrame:ClearAllPoints();
		bottomFrame:ClearAllPoints();
		topFrame:SetPoint("BOTTOM", gsContainer, "CENTER", 0, -(topFrame:GetHeight()*.04));
		bottomFrame:SetPoint("TOP", gsContainer, "CENTER", 0, (bottomFrame:GetHeight()*.04));
		
		topFrame.flareMask:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\uinameplatesmask.png");
		bottomFrame.flareMask:SetTexture("Interface\\AddOns\\DragonRider\\Textures\\uinameplatesmask_flipped.png");
	end
end

hooksecurefunc(DR, "UpdateVigorLayout", function()
	if DR.UpdateGroundSkimmingLayout then
		DR.UpdateGroundSkimmingLayout();
	end
end)


local showGroup = gsContainer:CreateAnimationGroup()

local showFade = showGroup:CreateAnimation("Alpha")
showFade:SetFromAlpha(0)
showFade:SetToAlpha(1)
showFade:SetDuration(ANIM_DURATION)
showFade:SetOrder(1)

showGroup:SetScript("OnPlay", function()
	gsContainer:Show();
end)
showGroup:SetScript("OnFinished", function()
	gsContainer:SetAlpha(1);
end)

local hideGroup = gsContainer:CreateAnimationGroup()

local hideFade = hideGroup:CreateAnimation("Alpha")
hideFade:SetFromAlpha(1)
hideFade:SetToAlpha(0)
hideFade:SetDuration(ANIM_DURATION)
hideFade:SetOrder(1)

hideGroup:SetScript("OnPlay", function()
	gsScrollPaused = true;
end)

hideGroup:SetScript("OnFinished", function()
	gsScrollPaused = false;
	gsContainer:SetAlpha(0);
	gsContainer:Hide();
end)

local function ShowGroundSkimming()
	if hideGroup:IsPlaying() then
		hideGroup:Stop();
		gsScrollPaused = false;
	end
	if gsContainer:IsShown() and gsContainer:GetAlpha() == 1 then
		return;
	end
	showGroup:Play();
end

local function HideGroundSkimming()
	if not gsContainer:IsShown() then
		return;
	end
	if showGroup:IsPlaying() then
		showGroup:Stop();
	end
	hideGroup:Play();
end

DR.HideGroundSkimming = HideGroundSkimming;

local function HasGroundSkimmingAura()
	if not issecretvalue(C_UnitAuras.GetPlayerAuraBySpellID(GROUND_SKIM_AURA)) then
		return C_UnitAuras.GetPlayerAuraBySpellID(GROUND_SKIM_AURA) ~= nil;
	end
end

function DR.EvaluateGroundSkimmingVisibility()
	if not DragonRider_DB or not DragonRider_DB.showGroundSkimming then
		HideGroundSkimming();
		return;
	end
	if DR.IsPreviewMode or HasGroundSkimmingAura() then
		ShowGroundSkimming();
	else
		HideGroundSkimming();
	end
end

function DR.UpdateGroundSkimmingColor()
	local r, g, b, a = GetGroundSkimmingColor()
	for _, f in ipairs({ topFrame, bottomFrame }) do
		f.baseFlare:SetVertexColor(r, g, b, a);
		f.additiveFlare:SetVertexColor(r, g, b, a);
	end

	if gsContainer:IsShown() and not showGroup:IsPlaying() and not hideGroup:IsPlaying() then
		gsContainer:SetAlpha(a);
	end
end

local auraWatcher = CreateFrame("Frame")
auraWatcher:RegisterEvent("UNIT_AURA")
auraWatcher:SetScript("OnEvent", function(_, _, unitTarget)
	if not LibAdvFlight or not LibAdvFlight.IsAdvFlyEnabled() then return end
	if unitTarget == "player" then
		DR.EvaluateGroundSkimmingVisibility();
	end
end)

local function GS_OnAddonLoaded()
	if DR.vigorBar then
		gsContainer:ClearAllPoints();
		gsContainer:SetPoint("CENTER", DR.vigorBar, "CENTER", 0, 0);
		
		gsContainer:SetFrameStrata("BACKGROUND");
	end

	DR.UpdateGroundSkimmingLayout();
	DR.UpdateGroundSkimmingColor();
	DR.EvaluateGroundSkimmingVisibility();
end

EventUtil.ContinueOnAddOnLoaded("DragonRider", GS_OnAddonLoaded)