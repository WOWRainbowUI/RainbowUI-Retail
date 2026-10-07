--=====================================================================================
-- RGX | Simple Quest Plates! - nameplates.lua

-- Author: DonnieDice
-- Description: Nameplate management and tracking system
--=====================================================================================

local addonName, SQP = ...
local SQPSettings = SQP.db.global
local RGX = _G.RGXFramework

local function nowSeconds()
    if type(GetTimePreciseSec) == "function" then
        return GetTimePreciseSec()
    end
    if type(debugprofilestop) == "function" then
        return debugprofilestop() / 1000
    end
    if type(GetTime) == "function" then
        return GetTime()
    end
    return 0
end

local function reportSlowPath(label, started)
    local elapsed = nowSeconds() - started
    if elapsed < 0.050 then
        return
    end

    local now = nowSeconds()
    SQP._lastSlowPathReport = SQP._lastSlowPathReport or {}
    if (SQP._lastSlowPathReport[label] or 0) + 2 > now then
        return
    end

    SQP._lastSlowPathReport[label] = now
    local message = string.format("[SQP:slow] %s took %.1fms", tostring(label), elapsed * 1000)
    if type(_G.geterrorhandler) == "function" then
        _G.geterrorhandler()(message)
    else
        print("|cffffaa00" .. message .. "|r")
    end
end

local function normalizeFontPath(path)
    if type(path) ~= "string" or path == "" then
        return "Fonts\\FRIZQT__.TTF"
    end
    return path:gsub("/", "\\")
end

local function setFontSafe(fontString, fontPath, fontSize, fontFlags)
    if not fontString or type(fontString.SetFont) ~= "function" then
        return false
    end

    fontPath = normalizeFontPath(fontPath)
    local ok, applied = pcall(fontString.SetFont, fontString, fontPath, fontSize, fontFlags or "")
    if ok and applied ~= false then
        return true
    end

    pcall(fontString.SetFont, fontString, "Fonts\\FRIZQT__.TTF", fontSize, fontFlags or "")
    return false
end

function SQP:UsesLevelChip(typeKey)
    local value = typeKey and SQPSettings[typeKey .. "LevelChip"]
    if value == nil then value = SQPSettings.unifiedNameplates end
    return value == true
end

function SQP:UsesTextMode(typeKey)
    local value = typeKey and SQPSettings[typeKey .. "ShowIconBackground"]
    if value == nil then value = SQPSettings.showIconBackground end
    return value == false
end

-- Background choice and text format are independent: Forever can retain
-- its chip while Text Mode formats the count as an objective ratio.
function SQP:GetDisplayStyle(typeKey)
    if self:UsesLevelChip(typeKey) then return "chip" end
    return self:UsesTextMode(typeKey) and "text" or "icon"
end

-- This is the sole placement/size model for real and preview overlays.
function SQP:ApplyQuestLayout(questFrame, anchorTarget, parentScaleRatio)
    local icon = questFrame.icon
    if not icon or not anchorTarget then return end
    questFrame:SetScale(self:GetSettingValue("scale") * (parentScaleRatio or 1))
    icon:SetSize(28, 22)
    icon:ClearAllPoints()
    local typeKey = questFrame._displayType or (questFrame.hasItem and "loot") or (questFrame.questType == 3 and "percent") or "kill"
    local x = self:GetSettingValue("offsetX")
    if self:UsesTextMode(typeKey) then x = x - 3 end
    icon:SetPoint(self:GetSettingValue("anchor"), anchorTarget,
        self:GetSettingValue("relativeTo"), x, self:GetSettingValue("offsetY"))
    for _, key in ipairs({ "kill", "loot" }) do
        local badge = questFrame[key .. "Icon"]
        if badge then
            self:AnchorTaskIcon(badge, icon, key)
            local size = self:GetSettingValue(key .. "IconSize")
            badge:SetSize(size, size)
        end
    end
    questFrame._anchorTarget = anchorTarget
end

-- Position the percent sign ("icon" mode) or the combined percent text
-- ("text" mode). In icon mode the side setting controls placement: hugging
-- the number's left/right side, or in the kill/loot mini-icon badge slots.
-- The offset sliders measure from the shipped baseline look (BASE_SPACING):
-- slider 0 renders exactly where the old hard-coded 18px default sat, so the
-- current settings ARE the new zero.
local PERCENT_BASE_SPACING = 18

function SQP:AnchorPercentSign(percentIcon, icon, textMode)
    if not percentIcon or not icon then
        return
    end
    local offX = PERCENT_BASE_SPACING + self:GetSettingValue("percentIconOffsetX")
    local offY = self:GetSettingValue("percentIconOffsetY")
    percentIcon:ClearAllPoints()
    if textMode then
        percentIcon:SetPoint('CENTER', icon, self:GetSettingValue("percentIconOffsetX"), offY)
        return
    end
    local side = SQPSettings.percentSignSide or "right"
    if side == "left" then
        percentIcon:SetPoint('CENTER', icon, -offX, offY)
    else
        percentIcon:SetPoint('CENTER', icon, offX, offY)
    end
end

-- Position the kill/loot task icons relative to the main quest icon.
-- Side flips the badge between the lower-left and lower-right slots; the
-- per-type X/Y offsets fine-tune from there.
function SQP:AnchorTaskIcon(iconTex, icon, typeKey)
    if not iconTex or not icon then return end
    local x = self:GetSettingValue(typeKey .. "IconOffsetX")
    local y = self:GetSettingValue(typeKey .. "IconOffsetY")
    local side = self:GetSettingValue(typeKey .. "IconSide")
    if self:GetSettingValue("anchor") == "LEFT" then
        side = "right"
        -- Legacy Loot uses a negative X baseline to reach the left badge slot.
        -- Preserve user adjustments while resolving the right-side baseline.
        local legacyX = typeKey == "loot" and -38 or 2
        x = x - legacyX + 2
    end
    iconTex:ClearAllPoints()
    if side == "left" then
        iconTex:SetPoint('TOPRIGHT', icon, 'BOTTOMLEFT', x, y)
    else
        iconTex:SetPoint('TOPLEFT', icon, 'BOTTOMRIGHT', x, y)
    end
end

-- Apply the selected art to both new chips and existing chips on refresh.
-- Atlas names are not texture file paths; never pass them to SetTexture.
function SQP:ApplyChipTexture(chip)
    local background = chip.background
    local chosen = SQPSettings.chipTexture or "square"
    local texture = self.CHIP_TEXTURES[chosen] or self.CHIP_TEXTURES.square
    background:SetTexture(nil)
    background:SetTexCoord(0, 1, 0, 1)
    background:SetVertexColor(1, 1, 1, 1)
    background:SetAlpha(0.85)
    if type(texture) == "table" and texture.file then
        background:SetTexture(texture.file)
        background:SetTexCoord(unpack(texture.coords))
    elseif type(texture) == "table" then
        local atlas = texture.atlas
        local info = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas)
        if info and background.SetAtlas then
            background:SetAtlas(atlas)
        else
            background:SetTexture(self.CHIP_TEXTURES.logo)
        end
    else
        background:SetTexture(texture)
    end
end

-- Like Forever's NameplateLevelFrame, the chip is a frame container with
-- background artwork. The normal frame graphic is independent of Blizzard's
-- separate target/focus selectedBorder; no selection highlight is added here.
function SQP:CreateLevelChip(parent)
    local chip = CreateFrame("Frame", nil, parent)
    chip:EnableMouse(false)
    -- Share the overlay's level so BACKGROUND artwork stays below its text.
    chip:SetFrameLevel(parent:GetFrameLevel())
    local background = chip:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(chip)
    chip.background = background
    self:ApplyChipTexture(chip)
    chip:Hide()
    return chip
end

-- Background geometry follows the normal quest icon dimensions, not font size.
-- Global Scale scales the overlay; Font Size changes only its text.
function SQP:UpdateUnifiedChip(questFrame)
    local chip = questFrame and questFrame.levelChip
    if not chip then
        return
    end
    local iconText = questFrame.iconText
    if not iconText or not iconText.IsShown or not iconText:IsShown() then
        chip:Hide()
        return
    end
    local text = iconText:GetText()
    if not text or text == "" then
        chip:Hide()
        return
    end
    chip:ClearAllPoints()
    chip:SetPoint("CENTER", iconText, "CENTER", 0, 0)
    chip:SetSize(28, 22)
    self:ApplyChipTexture(chip)
    chip:Show()
end

-- Synchronize only enabled, playing pulses. A refresh must not continually
-- restart them or re-enable a pulse the user has turned off.
function SQP:SyncQuestPulses(questFrame)
    if not questFrame then return end
    local pulses = { questFrame.iconPulse, questFrame.percentPulse,
        questFrame.percentOutlinePulse, questFrame.killIconPulse, questFrame.lootIconPulse }
    local active, signature = {}, {}
    for i, p in ipairs(pulses) do
        if p and p:IsPlaying() then
            active[#active + 1] = p
            signature[#signature + 1] = i .. ":" .. tostring(p._pulseDuration)
        end
    end
    local key = table.concat(signature, ",")
    if questFrame._pulseSyncSignature == key then return end
    questFrame._pulseSyncSignature = key
    for _, p in ipairs(active) do p:Stop() end
    for _, p in ipairs(active) do p:Play() end
end

function SQP:ClearQuestPulseSync(questFrame)
    if questFrame then questFrame._pulseSyncSignature = nil end
end

-- Nameplate storage
SQP.Nameplates = {} -- [plate] = frame
SQP.ActiveNameplates = {} -- [plate] = frame (visible only)
SQP.PlateGUIDs = {} -- [guid] = plate
SQP.QuestPlates = {} -- [plate] = questFrame

-- ── Unified nameplates ─────────────────────────────────────────────────────────
-- When enabled, quest overlays are parented to Blizzard's own UnitFrame and
-- anchored to its HealthBarsContainer (the technique MelloUI uses), so they
-- move, scale and fade with the native nameplate instead of floating beside
-- the plate boundary.

function SQP:IsUnifiedMode(nameplate)
    if SQPSettings.unifiedNameplates ~= true then
        return false
    end
    if not nameplate or not nameplate.UnitFrame then
        return false
    end
    if nameplate.UnitFrame.IsForbidden and nameplate.UnitFrame:IsForbidden() then
        return false
    end
    return true
end

-- The frame quest icons anchor against. Both modes prefer Blizzard's health
-- bar container so icons start flush with the bar by default (the outer
-- plate boundary moves around with cast bars and buff space, which is why
-- the old defaults never looked aligned). Older clients without those
-- internals fall back to the outer plate.
function SQP:GetPlateAnchorTarget(plate)
    local uf = plate and plate.UnitFrame
    if uf and not (uf.IsForbidden and uf:IsForbidden()) then
        if uf.HealthBarsContainer then
            return uf.HealthBarsContainer
        end
        if uf.healthBar then
            return uf.healthBar
        end
    end
    return plate
end

-- Create quest plate frame for new nameplates
-- One toast construction/update path for live overlays and the options preview.
function SQP:CreateQuestToast(questFrame, icon)
    -- BACKGROUND layer keeps the toast behind the quest display frame, icon,
    -- and overlay text instead of covering the whole stack.
    local qmark = questFrame:CreateTexture(nil, 'BACKGROUND')
    qmark:SetPoint('CENTER', icon)
    qmark:SetTexture('Interface/WorldMap/UI-WorldMap-QuestIcon')
    qmark:SetTexCoord(0, 0.56, 0.5, 1)
    qmark:SetAlpha(0)
    questFrame.qmark = qmark
    local group = qmark:CreateAnimationGroup()
    local alpha = group:CreateAnimation('Alpha')
    alpha:SetOrder(1)
    alpha:SetFromAlpha(0)
    alpha:SetToAlpha(1)
    alpha:SetDuration(0)
    local translation = group:CreateAnimation('Translation')
    translation:SetOrder(1)
    translation:SetSmoothing('OUT')
    local fade = group:CreateAnimation('Alpha')
    fade:SetOrder(1)
    fade:SetFromAlpha(1)
    fade:SetToAlpha(0)
    fade:SetSmoothing('OUT')
    questFrame.ani = group
    questFrame.toastTranslation = translation
    questFrame.toastFade = fade
    group:SetLooping("NONE")
    self:UpdateQuestToast(questFrame, false)
    return group
end

function SQP:SetQuestToastSelected(questFrame, selected)
    questFrame.toastSelected = selected and true or nil
    self:UpdateQuestToast(questFrame, true)
end

function SQP:UpdateQuestToast(questFrame, replay)
    if not questFrame.qmark or not questFrame.ani then return end
    -- Baselines shared with SQP.DEFAULTS: duration 1.3s, offset 30, size 40.
    local size = SQPSettings.questMarkerSize or 40
    local duration = SQPSettings.toastDuration or 1.3
    questFrame.qmark:SetSize(size, size)
    questFrame.toastTranslation:SetOffset(0, SQPSettings.toastHeight or 30)
    questFrame.toastTranslation:SetDuration(duration)
    questFrame.toastFade:SetDuration(duration)

    local group = questFrame.ani
    if SQPSettings.enabled == false or SQPSettings.animationsEnabled == false or SQPSettings.showQuestMarker == false
        or not questFrame.toastSelected then
        if group:IsPlaying() then group:Stop() end
        questFrame.qmark:SetAlpha(0)
    elseif replay then
        -- One play per explicit request (the Preview toast button or a live
        -- plate show); ordinary preview/layout refreshes must not restart it.
        if group:IsPlaying() then group:Stop() end
        group:Play()
    end
end

-- Animate visible count text when Text Mode hides the jellybean.
function SQP:UpdateTextPulses(questFrame, typeKey, visible)
    local enabled = visible and self:UsesTextMode(typeKey) and self:IsAnimationEnabled(typeKey, false)
    for _, key in ipairs({ "iconText", "iconTextOutline" }) do
        local region = questFrame[key]
        if region then
            local pulse = questFrame[key .. "Pulse"]
            if enabled and not pulse then
                pulse = region:CreateAnimationGroup()
                pulse:SetLooping("REPEAT")
                local out = pulse:CreateAnimation("Alpha")
                out:SetOrder(1); out:SetFromAlpha(1); out:SetToAlpha(0.15); out:SetDuration(0.5)
                local back = pulse:CreateAnimation("Alpha")
                back:SetOrder(2); back:SetFromAlpha(0.15); back:SetToAlpha(1); back:SetDuration(0.5)
                pulse._fadeOut = out; pulse._fadeIn = back
                questFrame[key .. "Pulse"] = pulse
            end
            if pulse then
                self:ApplyPulseDuration(pulse, self:GetAnimationDuration(typeKey, true))
                if enabled then
                    if not pulse:IsPlaying() then pulse:Play() end
                else
                    if pulse:IsPlaying() then pulse:Stop() end
                    region:SetAlpha(1)
                end
            end
        end
    end
end

function SQP:CreateQuestPlate(nameplate)
    -- Check if nameplate already has quest frame to prevent duplicates
    if self.QuestPlates[nameplate] then
        return
    end

    -- Store reference to nameplate frame
    self.Nameplates[nameplate] = nameplate

    local unified = self:IsUnifiedMode(nameplate)
    local parent = unified and nameplate.UnitFrame or nameplate

    -- Create quest overlay on the plate (or inside Blizzard's UnitFrame)
    local questFrame = CreateFrame('frame', nil, parent)
    questFrame:Hide()
    questFrame:SetAllPoints(parent)
    questFrame:EnableMouse(false)
    if unified then
        -- Draw above the health bar and its kit regions (gem caps etc.)
        local hb = nameplate.UnitFrame.HealthBarsContainer
            and nameplate.UnitFrame.HealthBarsContainer.healthBar
        local ok, level = pcall(function()
            return (hb or nameplate.UnitFrame):GetFrameLevel()
        end)
        if ok and type(level) == "number" then
            questFrame:SetFrameLevel(level + 5)
        end

    end
    -- A texture choice is available in both parent/integration modes.
    questFrame.levelChip = self:CreateLevelChip(questFrame)
    self.QuestPlates[nameplate] = questFrame
    
    -- Quest icon (jellybean)
    local icon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    icon:SetSize(28, 22)
    icon:SetTexture('Interface/QuestFrame/AutoQuest-Parts')
    icon:SetTexCoord(0.30273438, 0.41992188, 0.015625, 0.953125)
    local anchorTarget = self:GetPlateAnchorTarget(nameplate)
    questFrame.icon = icon
    self:ApplyQuestLayout(questFrame, anchorTarget)

    -- Dramatic pulse for main quest icon (more noticeable)
    local function CreateMainPulse(region)
        local pulse = region:CreateAnimationGroup()
        pulse:SetLooping("REPEAT")
        local fadeOut = pulse:CreateAnimation("Alpha")
        fadeOut:SetOrder(1)
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0.15)
        fadeOut:SetDuration(0.5)
        fadeOut:SetSmoothing("IN_OUT")
        local fadeIn = pulse:CreateAnimation("Alpha")
        fadeIn:SetOrder(2)
        fadeIn:SetFromAlpha(0.15)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.5)
        fadeIn:SetSmoothing("IN_OUT")
        pulse._fadeOut = fadeOut
        pulse._fadeIn = fadeIn
        return pulse
    end

    -- Subtle pulse for task type icons (kill/loot)
    local function CreatePulse(region)
        local pulse = region:CreateAnimationGroup()
        pulse:SetLooping("REPEAT")
        local fadeOut = pulse:CreateAnimation("Alpha")
        fadeOut:SetOrder(1)
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0.6)
        fadeOut:SetDuration(0.6)
        fadeOut:SetSmoothing("IN_OUT")
        local fadeIn = pulse:CreateAnimation("Alpha")
        fadeIn:SetOrder(2)
        fadeIn:SetFromAlpha(0.6)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(0.6)
        fadeIn:SetSmoothing("IN_OUT")
        pulse._fadeOut = fadeOut
        pulse._fadeIn = fadeIn
        return pulse
    end
    
    -- Item texture
    local itemTexture = questFrame:CreateTexture(nil, nil, nil, 1)
    itemTexture:SetPoint('TOPRIGHT', icon, 'BOTTOMLEFT', 12, 12)
    itemTexture:SetSize(16, 16)
    itemTexture:SetMask('Interface/CharacterFrame/TempPortraitAlphaMask')
    itemTexture:Hide()
    questFrame.itemTexture = itemTexture

    -- Kill quest icon (hostile cursor knife/sword)
    local killIcon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    self:AnchorTaskIcon(killIcon, icon, "kill")
    killIcon:SetSize(self:GetSettingValue("killIconSize"), self:GetSettingValue("killIconSize"))
    killIcon:SetTexture('Interface/Cursor/Attack')
    if not killIcon:GetTexture() then
        killIcon:SetTexture('Interface/Icons/INV_Sword_04')
        killIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    killIcon:Hide()
    questFrame.killIcon = killIcon
    questFrame.killIconPulse = CreatePulse(killIcon)

    -- Loot icon
    local lootIcon = questFrame:CreateTexture(nil, "OVERLAY", nil, 1)
    if lootIcon.SetAtlas then
        lootIcon:SetAtlas('Banker')
    else
        lootIcon:SetTexture('Interface/Icons/INV_Misc_Bag_10')
        lootIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    lootIcon:SetSize(self:GetSettingValue("lootIconSize"), self:GetSettingValue("lootIconSize"))
    self:AnchorTaskIcon(lootIcon, icon, "loot")
    lootIcon:Hide()
    questFrame.lootIcon = lootIcon
    questFrame.lootIconPulse = CreatePulse(lootIcon)

    -- Quest count text
    local iconText = questFrame:CreateFontString(nil, 'OVERLAY', 'SystemFont_Outline_Small')
    if iconText.SetDrawLayer then
        iconText:SetDrawLayer('OVERLAY', 2)
    end
    iconText:SetPoint('CENTER', icon, 0.8, 0)
    iconText:SetShadowOffset(1, -1)
    iconText:SetTextColor(1, 0.82, 0)

    -- Outline text (separate layer for custom outline color)
    local iconTextOutline = questFrame:CreateFontString(nil, 'OVERLAY', 'SystemFont_Outline_Small')
    if iconTextOutline.SetDrawLayer then
        iconTextOutline:SetDrawLayer('OVERLAY', 1)
    end
    iconTextOutline:SetPoint('CENTER', icon, 0.8, 0)
    iconTextOutline:SetShadowOffset(0, 0)
    iconTextOutline:SetTextColor(0, 0, 0, 1)
    
    -- Percent icon (used for percentage quests)
    local percentIcon = questFrame:CreateFontString(nil, 'OVERLAY', 'SystemFont_Outline_Small')
    if percentIcon.SetDrawLayer then
        percentIcon:SetDrawLayer('OVERLAY', 2)
    end
    self:AnchorPercentSign(percentIcon, icon, false)
    percentIcon:SetTextColor(0.2, 1, 1)
    percentIcon:Hide()

    local percentIconOutline = questFrame:CreateFontString(nil, 'OVERLAY', 'SystemFont_Outline_Small')
    if percentIconOutline.SetDrawLayer then
        percentIconOutline:SetDrawLayer('OVERLAY', 1)
    end
    self:AnchorPercentSign(percentIconOutline, icon, false)
    percentIconOutline:SetTextColor(0, 0, 0, 1)
    percentIconOutline:Hide()

    -- Apply font settings
    self:UpdateQuestFont(iconText, iconTextOutline, percentIcon, percentIconOutline)
    
    questFrame.iconText = iconText
    questFrame.iconTextOutline = iconTextOutline
    questFrame.percentIcon = percentIcon
    questFrame.percentIconOutline = percentIconOutline
    questFrame.iconPulse = CreateMainPulse(icon)
    questFrame.percentPulse = CreatePulse(percentIcon)
    questFrame.percentOutlinePulse = CreatePulse(percentIconOutline)
    self:ApplyQuestLayout(questFrame, anchorTarget)
    
    -- Quest complete animation (quick "pops" when the quest frame shows)
    self:CreateQuestToast(questFrame, icon)
    -- Live overlays play on show when the feature is enabled; the options
    -- preview stays silent until it is explicitly selected as the toast target.
    questFrame.toastSelected = true
    
    questFrame:HookScript('OnShow', function(self)
        SQP:UpdateQuestToast(self, true)
        if SQPSettings.syncAnimations then
            SQP:SyncQuestPulses(self)
        end
    end)
end

-- Ensure a quest overlay exists for this plate and matches the current mode.
-- In unified mode the UnitFrame can be replaced by Blizzard on plate reuse,
-- so a cached overlay parented to a stale UnitFrame must be rebuilt.
function SQP:EnsureQuestPlate(nameplate)
    local questFrame = self.QuestPlates[nameplate]
    if questFrame and SQPSettings.unifiedNameplates then
        local expectedParent = nameplate.UnitFrame
        if expectedParent and questFrame:GetParent() ~= expectedParent then
            questFrame:Hide()
            pcall(function() questFrame:SetParent(nil) end)
            self.QuestPlates[nameplate] = nil
        end
    end
    if not self.QuestPlates[nameplate] then
        self:CreateQuestPlate(nameplate)
    end

    -- Re-anchor when Blizzard recycled the plate's internals (pool reuse,
    -- death/resurrection, style swaps): the icon may still point at a stale
    -- health bar container that no longer belongs to this plate.
    self:RefreshQuestPlateAnchor(nameplate)
end

-- Only our own icon is re-anchored. Blizzard restricts GetLeft/GetTop on
-- nameplate regions, so live plates must not inspect their geometry.
function SQP:RefreshQuestPlateAnchor(nameplate, force)
    local questFrame = self.QuestPlates[nameplate]
    if not questFrame or not questFrame.icon then
        return
    end

    local target = self:GetPlateAnchorTarget(nameplate)
    self:ApplyQuestLayout(questFrame, target)
end

-- Rebuild every quest overlay after switching unified/legacy mode
function SQP:RebuildQuestPlates()
    local active = {}
    for plate in pairs(self.ActiveNameplates) do
        table.insert(active, plate)
    end
    for _, questFrame in pairs(self.QuestPlates) do
        questFrame:Hide()
        pcall(function() questFrame:SetParent(nil) end)
    end
    self.QuestPlates = {}
    for _, plate in ipairs(active) do
        self:CreateQuestPlate(plate)
        self:UpdateQuestIcon(plate, plate._unitID)
    end
end

-- Nameplate show callback
function SQP:OnPlateShow(nameplate, unitID)
    local started = nowSeconds()

    -- Store unit ID on nameplate itself
    nameplate._unitID = unitID
    -- Stable plate token: target/mouseover handlers overwrite _unitID, so
    -- quest re-evaluation needs the original nameplate unit token.
    nameplate._plateUnitID = unitID
    self.ActiveNameplates[nameplate] = nameplate

    self:EnsureQuestPlate(nameplate)
    
    local ok, guid = pcall(UnitGUID, unitID)
    if ok and guid then
        local setOk = pcall(function() self.PlateGUIDs[guid] = nameplate end)
    end

    self:UpdateQuestIcon(nameplate, unitID)

    -- Target glow is retired (see core.lua showTargetGlow): Blizzard's
    -- selection highlight is intentionally left untouched. The previous timer
    -- called a removed ApplyTargetGlow helper and errored when the retired
    -- setting was false.

    -- Recheck shortly after show to allow tooltip data to populate
    local plateRef = nameplate
    local unitRef = unitID
    local function delayedRecheck()
        if SQP.ActiveNameplates[plateRef] and plateRef._unitID == unitRef then
            SQP:UpdateQuestIcon(plateRef, unitRef)
        end
    end

    RGX:After(0.15, delayedRecheck, "SQP nameplate recheck")

    reportSlowPath("OnPlateShow", started)
end

-- Nameplate hide callback
function SQP:OnPlateHide(nameplate, unitID)
    self.ActiveNameplates[nameplate] = nil
    
    -- Only try to get GUID if we have a valid unitID
    if unitID then
        local ok, guid = pcall(UnitGUID, unitID)
        if ok and guid then
            pcall(function() self.PlateGUIDs[guid] = nil end)
        end
    end
    
    if self.QuestPlates[nameplate] then
        self.QuestPlates[nameplate]:Hide()
    end
end

-- Update font for quest text
-- typeKey: "kill", "loot", "percent", or nil (falls back to global settings)
function SQP:UpdateQuestFont(fontString, outlineFontString, percentFontString, percentOutlineFontString, typeKey)
    local started = nowSeconds()
    local S = SQPSettings or {}

    local function applyFont(main, outline, tk, sizeOverride)
        local Fonts = _G.RGXFonts
        local rgxDefaultFont = (Fonts and type(Fonts.GetDefault) == "function" and Fonts:GetDefault()) or nil
        local requestedFont = (tk and S[tk.."FontFamily"]) or S.fontFamily or rgxDefaultFont
            or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
        local fontName    = requestedFont
        local fontSize    = sizeOverride or (tk and S[tk.."FontSize"]) or S.fontSize or 12
        local fontOutline = (tk and S[tk.."FontOutline"])  or S.fontOutline or ""
        local outlineWidth= (tk and S[tk.."OutlineWidth"])
        if outlineWidth == nil then outlineWidth = S.outlineWidth or 0 end
        local outlineAlpha= (tk and S[tk.."OutlineAlpha"])
        if outlineAlpha  == nil then outlineAlpha  = S.outlineAlpha  or 0 end
        local outlineColor= (tk and S[tk.."OutlineColor"]) or S.outlineColor or {0, 0, 0}

        local noOutline = fontOutline == "" or fontOutline == "NONE"
        if noOutline then outlineWidth = 0 end
        if outlineWidth < 0 then outlineWidth = 0 end

        if Fonts and type(Fonts.ResolvePath) == "function" then
            fontName = Fonts:ResolvePath(requestedFont, rgxDefaultFont or STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF")
        end
        fontName = normalizeFontPath(fontName)

        local mainFlag = outline and "" or (noOutline and "" or fontOutline)
        setFontSafe(main, fontName, fontSize, mainFlag)
        main:SetShadowOffset(1, -1)
        if outlineWidth <= 0 then
            main:SetShadowColor(0, 0, 0, 1)
        else
            main:SetShadowColor(0, 0, 0, 0)
        end

        if outline then
            if outlineWidth <= 0 then
                outline:Hide()
            else
                local flag = outlineWidth >= 3 and "THICKOUTLINE" or "OUTLINE"
                -- Use same fontSize as main so the border aligns correctly
                setFontSafe(outline, fontName, fontSize, flag)
                local r, g, b = unpack(outlineColor)
                outline:SetTextColor(r, g, b, outlineAlpha)
                outline:SetShadowOffset(0, 0)
                outline:SetShadowColor(0, 0, 0, 0)
                outline:Show()
            end
        end
    end

    -- Main count text uses the provided typeKey
    applyFont(fontString, outlineFontString, typeKey)

    -- Percent symbol uses percentIconSize for independent size control
    if percentFontString then
        local signSize = S.percentIconSize or nil
        applyFont(percentFontString, percentOutlineFontString, "percent", signSize)
    end

    reportSlowPath("UpdateQuestFont", started)
end

-- Re-run quest detection for every visible plate. Quest data changes do not
-- re-fire NAME_PLATE_UNIT_ADDED, so without this, mobs already on screen keep
-- stale quest state until their plates are recreated (e.g. toggling the addon
-- off and on) — icons for newly accepted or completed quests never appeared.
function SQP:ReevaluateActivePlates()
    for plate in pairs(self.ActiveNameplates) do
        local unitID = plate._plateUnitID or plate._unitID
        if unitID and UnitExists(unitID) then
            self:UpdateQuestIcon(plate, unitID)
        end
    end
end

-- Refresh all nameplate positions and settings
function SQP:RefreshAllNameplates()
    -- Classic/MoP clients can rescan nameplates to ensure active list stays valid
    if self.RescanNameplates then
        self:RescanNameplates()
    end

    -- Update settings for all quest plates
    for plate, questFrame in pairs(self.QuestPlates) do
        if questFrame and questFrame.icon and not questFrame.isPreview then
            local function IsIconStyleEnabled(typeKey)
                return not self:UsesTextMode(typeKey)
            end

            self:RefreshQuestPlateAnchor(plate, true)

            self:UpdateQuestToast(questFrame, false)

            -- Update font settings
            if questFrame.iconText then
                local fontTypeKey
                if questFrame.hasItem then
                    fontTypeKey = "loot"
                elseif questFrame.questType == 3 then
                    fontTypeKey = "percent"
                else
                    fontTypeKey = "kill"
                end
                self:UpdateQuestFont(
                    questFrame.iconText,
                    questFrame.iconTextOutline,
                    questFrame.percentIcon,
                    questFrame.percentIconOutline,
                    fontTypeKey
                )
                
                -- Re-apply text color based on stored quest info
                if questFrame.questRelatedOnly then
                    questFrame.iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0}))
                    if questFrame.lootIcon then
                        questFrame.lootIcon:Hide()
                    end
                    if questFrame.killIcon then
                        questFrame.killIcon:Hide()
                    end
                elseif questFrame.hasItem then
                    -- Item quest
                    questFrame.iconText:SetTextColor(unpack(SQPSettings.itemColor or {0.2, 1, 0.2}))
                    if questFrame.lootIcon then
                        if SQPSettings.showLootIcon ~= false then
                            questFrame.lootIcon:Show()
                        else
                            questFrame.lootIcon:Hide()
                        end
                    end
                    if questFrame.killIcon then
                        questFrame.killIcon:Hide()
                    end
                elseif questFrame.questType then
                    if questFrame.questType == 1 then
                        -- Kill quest
                        questFrame.iconText:SetTextColor(unpack(SQPSettings.killColor or {1, 0.82, 0}))
                        if questFrame.lootIcon then
                            questFrame.lootIcon:Hide()
                        end
                        if questFrame.killIcon then
                            if SQPSettings.showKillIcon ~= false then
                                questFrame.killIcon:Show()
                            else
                                questFrame.killIcon:Hide()
                            end
                        end
                    elseif questFrame.questType == 2 then
                        -- Completed quest
                        questFrame.iconText:SetTextColor(1, 1, 1)
                        if questFrame.lootIcon then
                            questFrame.lootIcon:Hide()
                        end
                        if questFrame.killIcon then
                            questFrame.killIcon:Hide()
                        end
                    elseif questFrame.questType == 3 then
                        -- Progress quest
                        questFrame.iconText:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
                        if questFrame.lootIcon then
                            questFrame.lootIcon:Hide()
                        end
                        if questFrame.killIcon then
                            questFrame.killIcon:Hide()
                        end
                    end
                end
            end

            if questFrame.percentIcon then
                if questFrame.questType == 3 then
                    local percentIconMode = IsIconStyleEnabled("percent")
                    self:AnchorPercentSign(questFrame.percentIcon, questFrame.icon, not percentIconMode)
                    if SQPSettings.percentTintIcon and SQPSettings.percentTintIconColor then
                        local r, g, b, a = unpack(SQPSettings.percentTintIconColor)
                        questFrame.percentIcon:SetTextColor(r, g, b, a or 1)
                    else
                        questFrame.percentIcon:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
                    end
                    questFrame.percentIcon:Show()
                    if questFrame.percentIconOutline then
                        self:AnchorPercentSign(questFrame.percentIconOutline, questFrame.icon, not percentIconMode)
                        local outlineWidth = SQP:GetOutlineInfo("percent")
                        if outlineWidth and outlineWidth > 0 then
                            questFrame.percentIconOutline:Show()
                        else
                            questFrame.percentIconOutline:Hide()
                        end
                    end
                    if questFrame.icon then
                        if percentIconMode then
                            questFrame.icon:Show()
                        else
                            questFrame.icon:Hide()
                        end
                    end
                else
                    local nonPercentType = questFrame.hasItem and "loot" or "kill"
                    local nonPercentIconMode = IsIconStyleEnabled(nonPercentType)
                    questFrame.percentIcon:Hide()
                    if questFrame.percentIconOutline then
                        questFrame.percentIconOutline:Hide()
                    end
                    if questFrame.icon then
                        if nonPercentIconMode then
                            questFrame.icon:Show()
                        else
                            questFrame.icon:Hide()
                        end
                    end
                end
            end
            
            -- Main icon tinting removed (redundant with color controls)
            questFrame.icon:SetVertexColor(1, 1, 1, 1)

            local killTintEnabled = SQPSettings.killTintIcon and SQPSettings.killTintIconColor
            local killTintR, killTintG, killTintB, killTintA = 1, 1, 1, 1
            if killTintEnabled then
                killTintR, killTintG, killTintB, killTintA = unpack(SQPSettings.killTintIconColor)
            end
            local lootTintEnabled = SQPSettings.lootTintIcon and SQPSettings.lootTintIconColor
            local lootTintR, lootTintG, lootTintB, lootTintA = 1, 1, 1, 1
            if lootTintEnabled then
                lootTintR, lootTintG, lootTintB, lootTintA = unpack(SQPSettings.lootTintIconColor)
            end
            local percentTintEnabled = SQPSettings.percentTintIcon and SQPSettings.percentTintIconColor
            local percentTintR, percentTintG, percentTintB, percentTintA = 1, 1, 1, 1
            if percentTintEnabled then
                percentTintR, percentTintG, percentTintB, percentTintA = unpack(SQPSettings.percentTintIconColor)
            end

            if questFrame.killIcon then
                if killTintEnabled then
                    questFrame.killIcon:SetVertexColor(killTintR, killTintG, killTintB, killTintA)
                else
                    questFrame.killIcon:SetVertexColor(1, 1, 1, 1)
                end
            end
            if questFrame.lootIcon then
                if lootTintEnabled then
                    questFrame.lootIcon:SetVertexColor(lootTintR, lootTintG, lootTintB, lootTintA)
                else
                    questFrame.lootIcon:SetVertexColor(1, 1, 1, 1)
                end
            end
            if questFrame.percentIcon and questFrame.questType == 3 then
                if percentTintEnabled then
                    questFrame.percentIcon:SetTextColor(percentTintR, percentTintG, percentTintB, percentTintA or 1)
                else
                    questFrame.percentIcon:SetTextColor(unpack(SQPSettings.percentColor or {0.2, 1, 1}))
                end
            end
        end
    end
    
    -- Force update quest display
    for plate in pairs(self.ActiveNameplates) do
        self:UpdateQuestIcon(plate, plate._unitID)
    end
    if self.previewFrame and type(self.previewFrame.UpdatePreview) == "function" then
        self.previewFrame:UpdatePreview()
    end
end

-- Settings-driven preview sync without re-arms: some controls activate a
-- specific preview mode by design (type selects, style changes), while setting
-- sliders (sizes, animation intensity, side buttons) must only re-render the
-- currently displayed preview. Shared guard used by every card handler.
function SQP:UpdatePreviewManually()
    local p = SQP.previewFrame
    if p and type(p.UpdatePreview) == "function" and p.questType then
        pcall(function() p:UpdatePreview() end)
    end
end
