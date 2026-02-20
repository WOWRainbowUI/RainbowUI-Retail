-- PersonalBuffs.lua
-- PersonalBuffs - Independent Buff & Trinket Tracker (unified list, full corrected)
-- All SpellIDs are stored in PersonalBuffsDB.spellData (single unified list).
-- IMPORTANT: Your .toc must include:
-- ## SavedVariables: PersonalBuffsDB
-- And list this file:
-- PersonalBuffs.lua

local ADDON_NAME = "PersonalBuffs"
local PersonalBuffs = CreateFrame("Frame", "PersonalBuffsFrame")

-----------------------------------------------------------
-- SavedVariables (single unified list)
-----------------------------------------------------------
PersonalBuffsDB = PersonalBuffsDB or {
    trinketData = {}, -- [itemID] = { buffSpellId, useSpellId, icon, duration }
    spellData   = {}, -- [spellID] = { buffSpellId, icon, duration }  <-- unified list
    config = {
        iconWidth = 60,
        iconHeight = 60,
        columns = 3,
        hSpacing = 2,
        vSpacing = 2,
        growUp = true,
        offsetX = 0,
        offsetY = -200,
        locked = true,
        showCooldownText = true,
        maxIcons = 12,
        countAnchor = "BOTTOMRIGHT",
        countOffsetX = -3,
        countOffsetY = 3,
        countFontSize = 16,
    },
    debugMode = false,
}

local function EnsureConfig()
    PersonalBuffsDB.trinketData = PersonalBuffsDB.trinketData or {}
    PersonalBuffsDB.spellData = PersonalBuffsDB.spellData or {}
    PersonalBuffsDB.config = PersonalBuffsDB.config or {}
    local c = PersonalBuffsDB.config
    c.iconWidth = c.iconWidth or 60
    c.iconHeight = c.iconHeight or 60
    c.columns = math.max(1, c.columns or 3)
    c.hSpacing = c.hSpacing or 2
    c.vSpacing = c.vSpacing or 2
    if c.growUp == nil then c.growUp = true end
    c.offsetX = c.offsetX or 0
    c.offsetY = c.offsetY or -200
    if c.locked == nil then c.locked = true end
    if c.showCooldownText == nil then c.showCooldownText = true end
    c.maxIcons = c.maxIcons or 12
    c.countAnchor = c.countAnchor or "BOTTOMRIGHT"
    c.countOffsetX = (c.countOffsetX ~= nil) and c.countOffsetX or -3
    c.countOffsetY = (c.countOffsetY ~= nil) and c.countOffsetY or 3
    c.countFontSize = c.countFontSize or 16
end

-----------------------------------------------------------
-- State
-----------------------------------------------------------
local State = {
    equippedTrinkets = {}, -- [slot] = itemId
    activeBuffs = {},      -- [key] = { icon, duration, expirationTime, applications, source, sourceId, isTargetAura, isHarmful }
    learningMode = false,
    pendingLearning = {},  -- [itemId] = { useSpellId, timestamp }
    cleanupTicker = nil,
}

-----------------------------------------------------------
-- UI: anchor & icon pool
-----------------------------------------------------------
local anchorFrame = nil
local iconPool = {}
local listFrame = nil
local configFrame = nil

local function CreateAnchor()
    if anchorFrame then return end
    anchorFrame = CreateFrame("Frame", "PersonalBuffs_Anchor", UIParent)
    anchorFrame:SetSize(16, 16)
    anchorFrame:SetPoint("CENTER", UIParent, "CENTER", PersonalBuffsDB.config.offsetX, PersonalBuffsDB.config.offsetY)
    anchorFrame:EnableMouse(true)
    anchorFrame:SetMovable(true)
    anchorFrame:RegisterForDrag("LeftButton")
    anchorFrame:SetClampedToScreen(true)

    anchorFrame.bg = anchorFrame:CreateTexture(nil, "BACKGROUND")
    anchorFrame.bg:SetAllPoints()
    anchorFrame.bg:SetColorTexture(0, 1, 0, PersonalBuffsDB.config.locked and 0 or 0.12)

    anchorFrame:SetScript("OnDragStart", function(self)
        if not PersonalBuffsDB.config.locked then self:StartMoving() end
    end)
    anchorFrame:SetScript("OnDragStop", function(self)
        if not PersonalBuffsDB.config.locked then
            self:StopMovingOrSizing()
            local _, _, _, x, y = self:GetPoint()
            PersonalBuffsDB.config.offsetX = x or PersonalBuffsDB.config.offsetX
            PersonalBuffsDB.config.offsetY = y or PersonalBuffsDB.config.offsetY
        end
    end)
    anchorFrame:Hide()
end

local function UpdateAnchorVisual()
    if not anchorFrame then return end
    anchorFrame.bg:SetColorTexture(0, 1, 0, PersonalBuffsDB.config.locked and 0 or 0.12)
    if PersonalBuffsDB.config.locked then anchorFrame:Hide() else anchorFrame:Show() end
end

local function SetCountAnchorForIcon(icon)
    if not icon or not icon.count then return end
    local anchor = PersonalBuffsDB.config.countAnchor or "BOTTOMRIGHT"
    local ox = PersonalBuffsDB.config.countOffsetX or -3
    local oy = PersonalBuffsDB.config.countOffsetY or 3
    local size = PersonalBuffsDB.config.countFontSize or 16

    icon.count:ClearAllPoints()
    icon.count:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")

    if anchor == "TOPLEFT" then
        icon.count:SetPoint("TOPLEFT", icon, "TOPLEFT", ox, oy)
    elseif anchor == "TOPRIGHT" then
        icon.count:SetPoint("TOPRIGHT", icon, "TOPRIGHT", ox, oy)
    elseif anchor == "BOTTOMLEFT" then
        icon.count:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", ox, oy)
    elseif anchor == "CENTER" then
        icon.count:SetPoint("CENTER", icon, "CENTER", ox, oy)
    else
        icon.count:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", ox, oy)
    end
end

local function UpdateAllCountAnchors()
    for _, ic in ipairs(iconPool) do
        SetCountAnchorForIcon(ic)
    end
end

local function CreateIcon(index)
    local f = CreateFrame("Frame", ADDON_NAME.."Icon"..index, UIParent)
    f:SetSize(PersonalBuffsDB.config.iconWidth, PersonalBuffsDB.config.iconHeight)
    f:Hide()

    f.border = f:CreateTexture(nil, "BACKGROUND")
    f.border:SetAllPoints()
    f.border:SetColorTexture(0, 0, 0, 1)

    f.inner = f:CreateTexture(nil, "BACKGROUND")
    f.inner:SetPoint("TOPLEFT", f, "TOPLEFT", 1, -1)
    f.inner:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)
    f.inner:SetColorTexture(0.3, 0.3, 0.3, 1)

    f.bg = f:CreateTexture(nil, "BORDER")
    f.bg:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2)
    f.bg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
    f.bg:SetColorTexture(0, 0, 0, 0.8)

    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2)
    f.icon:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
    f.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    f.cooldown = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
    f.cooldown:SetPoint("TOPLEFT", f, "TOPLEFT", 2, -2)
    f.cooldown:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
    f.cooldown:SetDrawEdge(false)
    f.cooldown:SetDrawSwipe(true)
    f.cooldown:SetSwipeColor(0, 0, 0, 0.8)
    f.cooldown:SetHideCountdownNumbers(not PersonalBuffsDB.config.showCooldownText)

    f.count = f:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    f.count:SetFont(STANDARD_TEXT_FONT, PersonalBuffsDB.config.countFontSize or 16, "OUTLINE")
    f.count:SetTextColor(1, 1, 1, 1)

    if index == 1 then
        f:EnableMouse(true)
        f:SetMovable(true)
        f:RegisterForDrag("LeftButton")
        f:SetClampedToScreen(true)
        f:SetScript("OnDragStart", function(self)
            if IsShiftKeyDown() and not PersonalBuffsDB.config.locked then self:StartMoving() end
        end)
        f:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local _, _, _, x, y = self:GetPoint()
            PersonalBuffsDB.config.offsetX = x or PersonalBuffsDB.config.offsetX
            PersonalBuffsDB.config.offsetY = y or PersonalBuffsDB.config.offsetY
            UpdateAnchorVisual()
            ApplyCenteredLayout()
        end)
    end

    f.buffSource = nil
    f.buffSourceId = nil
    return f
end

local function InitializeIconPool()
    EnsureConfig()
    CreateAnchor()
    iconPool = {}
    for i = 1, PersonalBuffsDB.config.maxIcons do
        iconPool[i] = CreateIcon(i)
        iconPool[i]:SetSize(PersonalBuffsDB.config.iconWidth, PersonalBuffsDB.config.iconHeight)
    end
    UpdateAllCountAnchors()
    UpdateAnchorVisual()
end

-----------------------------------------------------------
-- Layout: centered grid
-----------------------------------------------------------
local function ApplyCenteredLayout()
    EnsureConfig()
    if not anchorFrame then return end

    anchorFrame:ClearAllPoints()
    anchorFrame:SetPoint("CENTER", UIParent, "CENTER", PersonalBuffsDB.config.offsetX, PersonalBuffsDB.config.offsetY)

    local visible = {}
    for _, icon in ipairs(iconPool) do
        if icon:IsShown() then table.insert(visible, icon) end
    end

    local totalIcons = #visible
    if totalIcons == 0 then return end

    local cols = math.max(1, PersonalBuffsDB.config.columns)
    local hSpacing = PersonalBuffsDB.config.hSpacing
    local vSpacing = PersonalBuffsDB.config.vSpacing
    local growUp = PersonalBuffsDB.config.growUp

    local rows = math.ceil(totalIcons / cols)
    local rowChildren, rowHeights = {}, {}
    for r = 1, rows do rowChildren[r] = {} rowHeights[r] = 0 end

    for i = 1, totalIcons do
        local r = math.floor((i - 1) / cols) + 1
        local child = visible[i]
        table.insert(rowChildren[r], child)
        rowHeights[r] = math.max(rowHeights[r], child:GetHeight() or PersonalBuffsDB.config.iconHeight)
    end

    for r = 1, rows do
        local childrenThisRow = rowChildren[r]
        local rowHeight = rowHeights[r] or PersonalBuffsDB.config.iconHeight
        local numIcons = #childrenThisRow

        local totalWidth = 0
        for _, c in ipairs(childrenThisRow) do totalWidth = totalWidth + (c:GetWidth() or PersonalBuffsDB.config.iconWidth) end
        totalWidth = totalWidth + (numIcons - 1) * hSpacing

        local xOffset = -totalWidth / 2
        local yOffset = 0
        for pr = 1, r - 1 do yOffset = yOffset + (rowHeights[pr] or PersonalBuffsDB.config.iconHeight) + vSpacing end
        if not growUp then yOffset = -yOffset end

        for ci = 1, numIcons do
            local child = childrenThisRow[ci]
            child:ClearAllPoints()
            child:SetPoint("CENTER", anchorFrame, "CENTER",
                xOffset + (child:GetWidth() or PersonalBuffsDB.config.iconWidth) / 2,
                yOffset)
            xOffset = xOffset + (child:GetWidth() or PersonalBuffsDB.config.iconWidth) + hSpacing
        end
    end
end

-----------------------------------------------------------
-- Equipment scanning
-----------------------------------------------------------
local function ScanEquippedTrinkets()
    wipe(State.equippedTrinkets)
    for slot = 13, 14 do
        local itemId = GetInventoryItemID("player", slot)
        if itemId then
            State.equippedTrinkets[slot] = itemId
            if PersonalBuffsDB.debugMode then
                local itemName = C_Item.GetItemNameByID(itemId)
                local data = PersonalBuffsDB.trinketData[itemId]
                local status = data and "(learned)" or "(not learned)"
                print("PersonalBuffs: Slot", slot, "-", itemName or ("Item "..itemId), status)
            end
        end
    end
end

-----------------------------------------------------------
-- Display & Cleanup (combat-safe)
-----------------------------------------------------------
local function UpdateDisplay()
    for _, icon in ipairs(iconPool) do icon:Hide() end

    local sortedBuffs = {}
    for key, buffData in pairs(State.activeBuffs) do
        local valid = true

        if type(key) == "string" and key:match("^spell_") then
            if not buffData.expirationTime or buffData.expirationTime == 0 then
                valid = false
            end
        end

        if valid and buffData.source == "item" then
            local equipped = (State.equippedTrinkets[13] == buffData.sourceId) or (State.equippedTrinkets[14] == buffData.sourceId)
            if not equipped then
                valid = false
            elseif not buffData.expirationTime or buffData.expirationTime == 0 then
                valid = false
            end
        end

        if valid then
            table.insert(sortedBuffs, buffData)
        end
    end

    table.sort(sortedBuffs, function(a, b)
        return (a.expirationTime or 0) < (b.expirationTime or 0)
    end)

    local shown = math.min(#sortedBuffs, PersonalBuffsDB.config.maxIcons)
    for i = 1, shown do
        local buffData = sortedBuffs[i]
        local icon = iconPool[i]
        icon.icon:SetTexture(buffData.icon)

        if buffData.isTargetAura then
            if buffData.isHarmful then
                icon.inner:SetColorTexture(0.6, 0.12, 0.12, 1)
            else
                icon.inner:SetColorTexture(0.12, 0.45, 0.8, 1)
            end
        else
            icon.inner:SetColorTexture(0.3, 0.3, 0.3, 1)
        end

        if buffData.duration and buffData.duration > 0 and buffData.expirationTime and buffData.expirationTime > 0 then
            icon.cooldown:SetHideCountdownNumbers(not PersonalBuffsDB.config.showCooldownText)
            icon.cooldown:SetCooldown(buffData.expirationTime - buffData.duration, buffData.duration)
        else
            icon.cooldown:Clear()
        end

        if buffData.applications and buffData.applications > 1 then
            icon.count:SetText(buffData.applications)
        else
            icon.count:SetText("")
        end

        SetCountAnchorForIcon(icon)
        icon.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        icon:Show()
    end

    ApplyCenteredLayout()
end

local function CleanupExpiredBuffs()
    local now = GetTime()
    local removed = false
    for key, buffData in pairs(State.activeBuffs) do
        if buffData.expirationTime and buffData.expirationTime > 0 and buffData.expirationTime <= now then
            State.activeBuffs[key] = nil
            removed = true
            if PersonalBuffsDB.debugMode then print("PersonalBuffs: Removed expired buff", key) end
        end

        if (type(key) == "string" and key:match("^spell_")) and (not buffData.expirationTime or buffData.expirationTime == 0) then
            State.activeBuffs[key] = nil
            removed = true
            if PersonalBuffsDB.debugMode then print("PersonalBuffs: Removed stale learned entry", key) end
        end

        if PersonalBuffsDB.trinketData[key] and (not buffData.expirationTime or buffData.expirationTime == 0) then
            State.activeBuffs[key] = nil
            removed = true
            if PersonalBuffsDB.debugMode then print("PersonalBuffs: Removed stale trinket entry", key) end
        end
    end
    if removed then UpdateDisplay() end
end

-----------------------------------------------------------
-- Auto-Learning (trinkets and spells) - learning/writes disabled in combat
-----------------------------------------------------------
local function AttemptAutoLearnSpell(spellId)
    if InCombatLockdown() then
        if PersonalBuffsDB.debugMode then print("PersonalBuffs: Spell used in combat; queued for post-combat learn", spellId) end
        return
    end

    C_Timer.After(0.3, function()
        if InCombatLockdown() then return end
        local bestMatch = nil
        local now = GetTime()
        for i = 1, 40 do
            local auraData = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
            if not auraData then break end
            local age = auraData.expirationTime and (auraData.duration - (auraData.expirationTime - now)) or 999
            if auraData.duration and auraData.duration >= 3 and age < 2 then
                local icon = C_Spell.GetSpellTexture(auraData.spellId)
                if icon and (not bestMatch or age < bestMatch.age) then
                    bestMatch = {
                        spellId = auraData.spellId,
                        icon = icon,
                        duration = auraData.duration,
                        age = age,
                        expirationTime = auraData.expirationTime,
                    }
                end
            end
        end

        if bestMatch then
            PersonalBuffsDB.spellData[spellId] = {
                buffSpellId = bestMatch.spellId,
                icon = bestMatch.icon,
                duration = bestMatch.duration,
            }

            if bestMatch.expirationTime and bestMatch.expirationTime > 0 then
                State.activeBuffs["spell_"..spellId] = {
                    icon = bestMatch.icon,
                    duration = bestMatch.duration,
                    expirationTime = bestMatch.expirationTime,
                    applications = 1,
                    source = "spell",
                    sourceId = spellId,
                }
            end

            local info = C_Spell.GetSpellInfo(spellId)
            print("PersonalBuffs: ✓ Auto-learned", (info and info) or ("Spell "..spellId))
            UpdateDisplay()
        else
            print("PersonalBuffs: Could not auto-learn spell", spellId)
        end
    end)
end

local function AttemptAutoLearn(itemId, useSpellId)
    if InCombatLockdown() then
        State.pendingLearning[itemId] = { useSpellId = useSpellId, timestamp = GetTime() }
        if PersonalBuffsDB.debugMode then print("PersonalBuffs: Trinket used in combat; queued for learning:", itemId) end
        return
    end

    C_Timer.After(0.3, function()
        if InCombatLockdown() then
            State.pendingLearning[itemId] = { useSpellId = useSpellId, timestamp = GetTime() }
            return
        end

        local bestMatch = nil
        local now = GetTime()
        for i = 1, 40 do
            local auraData = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
            if not auraData then break end
            local age = auraData.expirationTime and (auraData.duration - (auraData.expirationTime - now)) or 999
            if auraData.duration and auraData.duration >= 3 and age < 2 then
                local icon = C_Spell.GetSpellTexture(auraData.spellId)
                if icon and (not bestMatch or age < bestMatch.age) then
                    bestMatch = {
                        spellId = auraData.spellId,
                        icon = icon,
                        duration = auraData.duration,
                        age = age,
                        expirationTime = auraData.expirationTime,
                    }
                end
            end
        end

        if bestMatch then
            PersonalBuffsDB.trinketData[itemId] = {
                buffSpellId = bestMatch.spellId,
                useSpellId = useSpellId,
                icon = bestMatch.icon,
                duration = bestMatch.duration,
            }

            if bestMatch.expirationTime and bestMatch.expirationTime > 0 then
                State.activeBuffs[itemId] = {
                    icon = bestMatch.icon,
                    duration = bestMatch.duration,
                    expirationTime = bestMatch.expirationTime,
                    applications = 1,
                    source = "item",
                    sourceId = itemId,
                }
            end

            local itemName = C_Item.GetItemNameByID(itemId)
            print("PersonalBuffs: ✓ Auto-learned", itemName or ("Item "..itemId))
            UpdateDisplay()
        else
            State.activeBuffs[itemId] = nil
            UpdateDisplay()
            print("PersonalBuffs: Could not auto-learn trinket", itemId)
        end
    end)
end

local function ProcessPendingLearning()
    if InCombatLockdown() or not next(State.pendingLearning) then return end
    for itemId, data in pairs(State.pendingLearning) do
        AttemptAutoLearn(itemId, data.useSpellId)
    end
    wipe(State.pendingLearning)
end

-----------------------------------------------------------
-- Combat-safe Buff scanning and cast handling (includes target auras)
-----------------------------------------------------------
local function ScanBuffs()
    local buffToSource = {}

    for itemId, d in pairs(PersonalBuffsDB.trinketData) do
        if d.buffSpellId and (State.equippedTrinkets[13] == itemId or State.equippedTrinkets[14] == itemId) then
            buffToSource[d.buffSpellId] = { type = "item", id = itemId, cached = d }
        end
    end

    for spellId, d in pairs(PersonalBuffsDB.spellData) do
        if d.buffSpellId then
            buffToSource[d.buffSpellId] = { type = "spell", id = spellId, cached = d }
        end
    end

    for key, _ in pairs(State.activeBuffs) do
        if (type(key) == "string" and (key:match("^spell_") or key:match("^target_"))) or PersonalBuffsDB.trinketData[key] then
            State.activeBuffs[key] = nil
        end
    end

    local now = GetTime()

    for i = 1, 40 do
        local auraData = C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
        if not auraData then break end
        local source = buffToSource[auraData.spellId]
        if source then
            local key = source.type == "item" and source.id or ("spell_"..source.id)
            local cached = source.cached
            State.activeBuffs[key] = {
                icon = cached and cached.icon or C_Spell.GetSpellTexture(auraData.spellId),
                duration = auraData.duration or (cached and cached.duration) or 0,
                expirationTime = auraData.expirationTime or (auraData.duration and (now + auraData.duration) or 0),
                applications = auraData.applications or 1,
                source = source.type,
                sourceId = source.id,
                isTargetAura = false,
                isHarmful = false,
            }
        end
    end

    if UnitExists("target") then
        for i = 1, 40 do
            local auraData = C_UnitAuras.GetAuraDataByIndex("target", i, "HELPFUL")
            if not auraData then break end
            local source = buffToSource[auraData.spellId]
            if source then
                local key = "target_spell_" .. tostring(auraData.spellId)
                local cached = source.cached
                State.activeBuffs[key] = {
                    icon = cached and cached.icon or C_Spell.GetSpellTexture(auraData.spellId),
                    duration = auraData.duration or (cached and cached.duration) or 0,
                    expirationTime = auraData.expirationTime or (auraData.duration and (now + auraData.duration) or 0),
                    applications = auraData.applications or 1,
                    source = "target",
                    sourceId = auraData.spellId,
                    isTargetAura = true,
                    isHarmful = false,
                }
            end
        end

        for i = 1, 40 do
            local auraData = C_UnitAuras.GetAuraDataByIndex("target", i, "HARMFUL")
            if not auraData then break end
            local source = buffToSource[auraData.spellId]
            if source then
                local key = "target_spell_" .. tostring(auraData.spellId)
                local cached = source.cached
                State.activeBuffs[key] = {
                    icon = cached and cached.icon or C_Spell.GetSpellTexture(auraData.spellId),
                    duration = auraData.duration or (cached and cached.duration) or 0,
                    expirationTime = auraData.expirationTime or (auraData.duration and (now + auraData.duration) or 0),
                    applications = auraData.applications or 1,
                    source = "target",
                    sourceId = auraData.spellId,
                    isTargetAura = true,
                    isHarmful = true,
                }
            end
        end
    end
end

local function OnSpellCastSucceeded(unit, castGUID, spellId)
    if unit ~= "player" then return end

    if PersonalBuffsDB.spellData[spellId] then
        C_Timer.After(0.12, function()
            ScanBuffs()
            UpdateDisplay()
        end)
        return
    end

    for slot = 13, 14 do
        local itemId = State.equippedTrinkets[slot]
        if itemId then
            local cached = PersonalBuffsDB.trinketData[itemId]
            if cached and (cached.useSpellId == spellId or cached.buffSpellId == spellId) then
                State.activeBuffs[itemId] = {
                    icon = cached.icon,
                    duration = cached.duration,
                    expirationTime = GetTime() + (cached.duration or 0),
                    applications = 1,
                    source = "item",
                    sourceId = itemId,
                    isTargetAura = false,
                    isHarmful = false,
                }
                C_Timer.After(0.12, function()
                    ScanBuffs()
                    UpdateDisplay()
                end)
                UpdateDisplay()
                return
            end
        end
    end

    if not State.learningMode then return end

    C_Timer.After(0.1, function()
        local slot13Item = State.equippedTrinkets[13]
        local slot14Item = State.equippedTrinkets[14]

        local start13, duration13 = 0, 0
        local start14, duration14 = 0, 0
        if slot13Item then start13, duration13 = GetInventoryItemCooldown("player", 13) end
        if slot14Item then start14, duration14 = GetInventoryItemCooldown("player", 14) end

        local cooldownSlots = {}
        if start13 > 0 and duration13 > 1.5 and slot13Item and not PersonalBuffsDB.trinketData[slot13Item] then
            table.insert(cooldownSlots, { slot = 13, itemId = slot13Item })
        end
        if start14 > 0 and duration14 > 1.5 and slot14Item and not PersonalBuffsDB.trinketData[slot14Item] then
            table.insert(cooldownSlots, { slot = 14, itemId = slot14Item })
        end

        if #cooldownSlots == 1 then
            AttemptAutoLearn(cooldownSlots[1].itemId, spellId)
        elseif #cooldownSlots > 1 then
            print("PersonalBuffs: Both trinkets on cooldown - use separately to learn")
        else
            AttemptAutoLearnSpell(spellId)
        end
    end)
end

-----------------------------------------------------------
-- Unified list management (single storage PersonalBuffsDB.spellData)
-----------------------------------------------------------
local function AddUnifiedSpellID(spellId)
    if not spellId then return false end
    if PersonalBuffsDB.spellData[spellId] then return false end

    local icon = C_Spell.GetSpellTexture(spellId)
    PersonalBuffsDB.spellData[spellId] = { buffSpellId = spellId, icon = icon, duration = 0 }

    ScanBuffs()
    UpdateDisplay()
    return true
end

local function RemoveUnifiedSpellID(spellId)
    if not spellId or not PersonalBuffsDB.spellData[spellId] then return false end
    PersonalBuffsDB.spellData[spellId] = nil
    ScanBuffs()
    UpdateDisplay()
    return true
end

local function ListUnifiedSpellIDs()
    local out = {}
    for id, info in pairs(PersonalBuffsDB.spellData) do
        table.insert(out, { id = id, icon = (type(info)=="table" and info.icon) or C_Spell.GetSpellTexture(id) })
    end
    table.sort(out, function(a,b) return a.id < b.id end)
    return out
end

-----------------------------------------------------------
-- Global Test Icons (now uses unified list) — fixed syntax
-----------------------------------------------------------
function PersonalBuffs:ShowGlobalTestIcons()
    EnsureConfig()
    local entries = {}
    for spellId, info in pairs(PersonalBuffsDB.spellData or {}) do
        local icon = (type(info) == "table" and info.icon) or C_Spell.GetSpellTexture(spellId)
        if icon then table.insert(entries, { id = spellId, icon = icon }) end
    end
    if #entries == 0 then
        print("PersonalBuffs: Unified list is empty — nothing to test.")
        return
    end

    local shown = math.min(#entries, PersonalBuffsDB.config.maxIcons or 12)
    for i = 1, shown do
        local e = entries[i]
        local ic = iconPool[i]
        if ic and ic.icon then
            ic.icon:SetTexture(e.icon)
            ic.cooldown:Clear()
            ic.count:SetText("")
            ic.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            SetCountAnchorForIcon(ic)
            ic:Show()
        end
    end
    ApplyCenteredLayout()
    print("PersonalBuffs: Showing", shown, "test icons from unified list.")
end

-----------------------------------------------------------
-- Events
-----------------------------------------------------------
PersonalBuffs:RegisterEvent("ADDON_LOADED")
PersonalBuffs:RegisterEvent("PLAYER_LOGIN")
PersonalBuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
PersonalBuffs:RegisterEvent("UNIT_AURA")
PersonalBuffs:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
PersonalBuffs:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
PersonalBuffs:RegisterEvent("PLAYER_REGEN_DISABLED")
PersonalBuffs:RegisterEvent("PLAYER_REGEN_ENABLED")

PersonalBuffs:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        EnsureConfig()
        InitializeIconPool()
        if State.cleanupTicker then State.cleanupTicker:Cancel() end
        State.cleanupTicker = C_Timer.NewTicker(0.5, CleanupExpiredBuffs)
        print("|cff00ff00PersonalBuffs|r Loaded: Independent Buff & Trinket Tracker (unified list)")
        print("  /pbuffs config  /pbuffs learn  /pbuffs list  /pbuffs global  /pbuffs move  /pbuffs debug  /pbuffs clear")
        local count = 0
        for _ in pairs(PersonalBuffsDB.spellData or {}) do count = count + 1 end
        if count > 0 then print("PersonalBuffs: Unified list entries:", count) end
    elseif event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        EnsureConfig()
        InitializeIconPool()
        ScanEquippedTrinkets()
        ScanBuffs()
        UpdateDisplay()
        UpdateAnchorVisual()
    elseif event == "PLAYER_REGEN_ENABLED" then
        ProcessPendingLearning()
        ScanBuffs()
        UpdateDisplay()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        OnSpellCastSucceeded(arg1, arg2, arg3)
    elseif event == "UNIT_AURA" and arg1 == "player" then
        ScanBuffs()
        UpdateDisplay()
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        ScanEquippedTrinkets()
        ScanBuffs()
        UpdateDisplay()
    end
end)

-----------------------------------------------------------
-- Config UI (full settings window with width/height inputs)
-----------------------------------------------------------
local function CreateSlider(parent, labelText, min, max, step, initial, onChanged)
    local s = CreateFrame("Slider", nil, parent, "OptionsSliderTemplate")
    s:SetWidth(260)
    s:SetMinMaxValues(min, max)
    s:SetValueStep(step)
    s:SetObeyStepOnDrag(true)
    s.Low:SetText(tostring(min))
    s.High:SetText(tostring(max))
    s:SetValue(initial)

    s.label = s:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    s.label:SetPoint("BOTTOMLEFT", s, "TOPLEFT", 0, 6)
    s.label:SetText(labelText .. ": " .. tostring(initial))

    s:SetScript("OnValueChanged", function(self, val)
        if step >= 1 then val = math.floor(val + 0.5) end
        s.label:SetText(labelText .. ": " .. tostring(val))
        onChanged(val)
        UpdateDisplay()
    end)

    return s
end

local function CreateConfigUI()
    EnsureConfig()
    if configFrame and configFrame:IsShown() then configFrame:Show(); return end

    if not configFrame then
        local f = CreateFrame("Frame", "PersonalBuffs_Config", UIParent, "BasicFrameTemplateWithInset")
        f:SetSize(460, 720)
        f:SetPoint("CENTER")
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        f:SetClampedToScreen(true)

        f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.title:SetPoint("TOP", 0, -6)
        f.title:SetText("PersonalBuffs Settings")

        local scroll = CreateFrame("ScrollFrame", "PersonalBuffs_ConfigScroll", f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 12, -36)
        scroll:SetPoint("BOTTOMRIGHT", -30, 48)

        local content = CreateFrame("Frame", "PersonalBuffs_ConfigContent", scroll)
        content:SetSize(1, 1)
        scroll:SetScrollChild(content)
        f.content = content

        local y = -8

        local widthSlider = CreateSlider(content, "Icon Width", 20, 200, 1, PersonalBuffsDB.config.iconWidth, function(v)
            PersonalBuffsDB.config.iconWidth = v
            for _, ic in ipairs(iconPool) do ic:SetWidth(v) end
            UpdateAllCountAnchors()
            ApplyCenteredLayout()
        end)
        widthSlider:SetPoint("TOPLEFT", 12, y); y = y - 70

        local heightSlider = CreateSlider(content, "Icon Height", 20, 200, 1, PersonalBuffsDB.config.iconHeight, function(v)
            PersonalBuffsDB.config.iconHeight = v
            for _, ic in ipairs(iconPool) do ic:SetHeight(v) end
            UpdateAllCountAnchors()
            ApplyCenteredLayout()
        end)
        heightSlider:SetPoint("TOPLEFT", 12, y); y = y - 70

        local colsSlider = CreateSlider(content, "Columns", 1, 8, 1, PersonalBuffsDB.config.columns, function(v) PersonalBuffsDB.config.columns = v end)
        colsSlider:SetPoint("TOPLEFT", 12, y); y = y - 70

        local hSlider = CreateSlider(content, "Horizontal Spacing", -30, 60, 1, PersonalBuffsDB.config.hSpacing, function(v) PersonalBuffsDB.config.hSpacing = v end)
        hSlider:SetPoint("TOPLEFT", 12, y); y = y - 70

        local vSlider = CreateSlider(content, "Vertical Spacing", -30, 60, 1, PersonalBuffsDB.config.vSpacing, function(v) PersonalBuffsDB.config.vSpacing = v end)
        vSlider:SetPoint("TOPLEFT", 12, y); y = y - 70

        local growCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        growCheckbox:SetPoint("TOPLEFT", 12, y)
        growCheckbox.text:SetText("Grow Upwards")
        growCheckbox:SetChecked(PersonalBuffsDB.config.growUp)
        growCheckbox:SetScript("OnClick", function(self) PersonalBuffsDB.config.growUp = self:GetChecked() and true or false; ApplyCenteredLayout() end)
        y = y - 36

        local lockCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        lockCheckbox:SetPoint("TOPLEFT", 12, y)
        lockCheckbox.text:SetText("Lock Position")
        lockCheckbox:SetChecked(PersonalBuffsDB.config.locked)
        lockCheckbox:SetScript("OnClick", function(self) PersonalBuffsDB.config.locked = self:GetChecked() and true or false; UpdateAnchorVisual() end)
        y = y - 36

        local cdCheckbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        cdCheckbox:SetPoint("TOPLEFT", 12, y)
        cdCheckbox.text:SetText("Show Cooldown Numbers")
        cdCheckbox:SetChecked(PersonalBuffsDB.config.showCooldownText)
        cdCheckbox:SetScript("OnClick", function(self) PersonalBuffsDB.config.showCooldownText = self:GetChecked() and true or false; UpdateDisplay() end)
        y = y - 36

        local function MakePosButton(text, anchorName, xOffset)
            local b = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
            b:SetSize(90, 22)
            b:SetText(text)
            b:SetPoint("TOPLEFT", 12 + xOffset, y)
            b:SetScript("OnClick", function()
                PersonalBuffsDB.config.countAnchor = anchorName
                UpdateAllCountAnchors()
                UpdateDisplay()
            end)
            return b
        end

        local topLeftBtn = MakePosButton("Top Left", "TOPLEFT", 0)
        local topRightBtn = MakePosButton("Top Right", "TOPRIGHT", 100)
        y = y - 30

        local bottomLeftBtn = MakePosButton("Bottom Left", "BOTTOMLEFT", 0)
        local bottomRightBtn = MakePosButton("Bottom Right", "BOTTOMRIGHT", 100)
        y = y - 30

        local centerBtn = MakePosButton("Center", "CENTER", 0)
        centerBtn:SetPoint("TOPLEFT", 12, y)
        y = y - 36

        local offsetXSlider = CreateSlider(content, "Count Offset X", -50, 50, 1, PersonalBuffsDB.config.countOffsetX or -3, function(v)
            PersonalBuffsDB.config.countOffsetX = v
            UpdateAllCountAnchors()
        end)
        offsetXSlider:SetPoint("TOPLEFT", 12, y); y = y - 70

        local offsetYSlider = CreateSlider(content, "Count Offset Y", -50, 50, 1, PersonalBuffsDB.config.countOffsetY or 3, function(v)
            PersonalBuffsDB.config.countOffsetY = v
            UpdateAllCountAnchors()
        end)
        offsetYSlider:SetPoint("TOPLEFT", 12, y); y = y - 70

        local fontSlider = CreateSlider(content, "Count Font Size", 6, 36, 1, PersonalBuffsDB.config.countFontSize or 16, function(v)
            PersonalBuffsDB.config.countFontSize = v
            UpdateAllCountAnchors()
        end)
        fontSlider:SetPoint("TOPLEFT", 12, y); y = y - 70

        y = y - 10

        local contentHeight = math.abs(y) + 20
        content:SetHeight(contentHeight)
        content:SetWidth(420)

        local close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        close:SetSize(100, 24)
        close:SetPoint("BOTTOM", f, "BOTTOM", 0, 10)
        close:SetText("Close")
        close:SetScript("OnClick", function() f:Hide() end)

        configFrame = f
    else
        configFrame:Show()
    end
end

-----------------------------------------------------------
-- List UI (manual SpellID input) - unified list
-----------------------------------------------------------
local function AddManualSpellID(inputBox)
    if not inputBox then return end
    local spellId = tonumber(inputBox:GetText())
    if not spellId then
        print("|cffff0000PersonalBuffs:|r Please enter a valid numeric SpellID.")
        return
    end
    if PersonalBuffsDB.spellData[spellId] then
        print("|cffff8800PersonalBuffs:|r SpellID already in list:", spellId)
        inputBox:SetText("")
        return
    end

    local info = C_Spell.GetSpellInfo(spellId)
    local icon = C_Spell.GetSpellTexture(spellId)
    if not info or not icon then
        print("|cffff0000PersonalBuffs:|r Invalid SpellID or no icon available:", spellId)
        return
    end

    PersonalBuffsDB.spellData[spellId] = {
        buffSpellId = spellId,
        icon = icon,
        duration = 0,
    }

    print("|cff00ff00PersonalBuffs:|r Added SpellID", spellId, "-", info)
    inputBox:SetText("")
    ScanBuffs()
    UpdateDisplay()
    if listFrame then listFrame:Hide() end
    C_Timer.After(0.05, function() if PersonalBuffs.ShowListUI then PersonalBuffs:ShowListUI() end end)
end

function PersonalBuffs:ShowListUI()
    if listFrame and listFrame:IsShown() then listFrame:Show(); return end
    if not listFrame then
        local f = CreateFrame("Frame", "PersonalBuffs_List", UIParent, "BasicFrameTemplateWithInset")
        f:SetSize(420, 520)
        f:SetPoint("CENTER")
        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)
        f:SetClampedToScreen(true)

        f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.title:SetPoint("TOP", 0, -6)
        f.title:SetText("PersonalBuffs — Unified Spell List")

        local label = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("TOPLEFT", 14, -34)
        label:SetText("Add SpellID:")

        local input = CreateFrame("EditBox", "PersonalBuffs_ListInput", f, "InputBoxTemplate")
        input:SetSize(110, 22)
        input:SetPoint("LEFT", label, "RIGHT", 8, 0)
        input:SetAutoFocus(false)
        input:SetNumeric(true)
        input:SetMaxLetters(8)

        local addButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        addButton:SetSize(60, 22)
        addButton:SetPoint("LEFT", input, "RIGHT", 6, 0)
        addButton:SetText("Add")

        input:SetScript("OnEnterPressed", function(self) AddManualSpellID(self); self:ClearFocus() end)
        addButton:SetScript("OnClick", function() AddManualSpellID(input) end)

        f.inputBox = input
        f.addButton = addButton

        local testBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        testBtn:SetSize(120, 22)
        testBtn:SetPoint("LEFT", addButton, "RIGHT", 8, 0)
        testBtn:SetText("Test Icons")
        testBtn:SetScript("OnClick", function() PersonalBuffs:ShowGlobalTestIcons() end)

        local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 10, -68)
        scroll:SetPoint("BOTTOMRIGHT", -30, 12)
        local content = CreateFrame("Frame", nil, scroll)
        content:SetSize(1, 1)
        scroll:SetScrollChild(content)
        f.content = content

        listFrame = f
    end

    local entries = {}
    for itemId, data in pairs(PersonalBuffsDB.trinketData) do
        if data.buffSpellId and data.icon then
            table.insert(entries, { id = data.buffSpellId, icon = data.icon, type = "trinket", itemId = itemId })
        end
    end
    for spellId, data in pairs(PersonalBuffsDB.spellData) do
        if data.buffSpellId and data.icon then
            table.insert(entries, { id = data.buffSpellId, icon = data.icon, type = "spell", spellId = spellId })
        end
    end
    table.sort(entries, function(a, b) return a.id < b.id end)

    for _, child in ipairs({ listFrame.content:GetChildren() }) do child:Hide(); child:SetParent(nil) end

    local y = 0
    for i, entry in ipairs(entries) do
        local row = CreateFrame("Frame", nil, listFrame.content)
        row:SetSize(360, 28)
        row:SetPoint("TOPLEFT", 0, -y)

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(22, 22)
        row.icon:SetPoint("LEFT", 2, 0)
        row.icon:SetTexture(entry.icon)
        row.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
        row.text:SetText("SpellID: "..entry.id .. (entry.type == "trinket" and " (Trinket)" or " (Spell)"))

        row.remove = CreateFrame("Button", nil, row, "UIPanelCloseButton")
        row.remove:SetSize(18, 18)
        row.remove:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        row.remove:SetScript("OnClick", function()
            if entry.type == "trinket" then PersonalBuffsDB.trinketData[entry.itemId] = nil else PersonalBuffsDB.spellData[entry.spellId] = nil end
            ScanBuffs()
            UpdateDisplay()
            PersonalBuffs:ShowListUI()
        end)

        row:SetScript("OnEnter", function(self)
            local name = C_Spell.GetSpellInfo(entry.id)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            if name then
                GameTooltip:AddLine(name, 1, 1, 1)
                GameTooltip:AddLine("SpellID: "..entry.id, 0.8, 0.8, 0.8)
            else
                GameTooltip:AddLine("SpellID: "..entry.id, 1, 1, 1)
            end
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        y = y + 30
    end

    listFrame:Show()
end

-----------------------------------------------------------
-- Slash commands (operate on unified list)
-----------------------------------------------------------
SLASH_PERSONALBUFFS1 = "/pbuffs"
SlashCmdList["PERSONALBUFFS"] = function(msg)
    msg = (msg or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")
    cmd = (cmd or ""):lower()

    if cmd == "config" then
        CreateConfigUI()
        return
    end

    if cmd == "list" then
        PersonalBuffs:ShowListUI()
        return
    end

    if cmd == "learn" then
        State.learningMode = not State.learningMode
        print("PersonalBuffs: Learning mode", State.learningMode and "ENABLED" or "DISABLED")
        return
    end

    if cmd == "move" then
        PersonalBuffsDB.config.locked = false
        UpdateAnchorVisual()
        print("PersonalBuffs: Unlocked. Drag the anchor or hold SHIFT and drag the first icon to move.")
        return
    end

    if cmd == "test" then
        for i = 1, math.min(6, PersonalBuffsDB.config.maxIcons) do
            local icon = iconPool[i]
            icon.icon:SetTexture(136235)
            icon.cooldown:Clear()
            icon.count:SetText(i % 3 == 0 and "2" or "")
            icon.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            SetCountAnchorForIcon(icon)
            icon:Show()
        end
        ApplyCenteredLayout()
        return
    end

    if cmd == "clear" then
        StaticPopupDialogs["PERSONALBUFFS_CLEAR_CONFIRM"] = {
            text = "Remove all learned trinkets and spells?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                wipe(PersonalBuffsDB.trinketData)
                wipe(PersonalBuffsDB.spellData)
                wipe(State.activeBuffs)
                UpdateDisplay()
                print("PersonalBuffs: Cleared learned data")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("PERSONALBUFFS_CLEAR_CONFIRM")
        return
    end

    if cmd == "debug" then
        PersonalBuffsDB.debugMode = not PersonalBuffsDB.debugMode
        print("PersonalBuffs: Debug mode", PersonalBuffsDB.debugMode and "ON" or "OFF")
        return
    end

    if cmd == "dump" then
        for k,v in pairs(State.activeBuffs) do
            print(k, v.source, v.sourceId, v.duration or "no-dur", v.expirationTime and string.format("%.1f", v.expirationTime - GetTime()) or "no-exp")
        end
        return
    end

    if cmd == "global" then
        if (rest or "") == "" then
            PersonalBuffs:ShowListUI()
            return
        end

        local sub, arg = rest:match("^(%S*)%s*(.-)$")
        sub = (sub or ""):lower()
        if sub == "add" then
            local id = tonumber(arg)
            if not id then print("PersonalBuffs: Usage: /pbuffs global add <SpellID>") return end
            if AddUnifiedSpellID(id) then print("PersonalBuffs: Added SpellID", id) else print("PersonalBuffs: SpellID already in list or failed:", id) end
            return
        elseif sub == "remove" or sub == "rm" then
            local id = tonumber(arg)
            if not id then print("PersonalBuffs: Usage: /pbuffs global remove <SpellID>") return end
            if RemoveUnifiedSpellID(id) then print("PersonalBuffs: Removed SpellID", id) else print("PersonalBuffs: Not found in list:", id) end
            return
        elseif sub == "list" or sub == "ls" then
            local list = ListUnifiedSpellIDs()
            if #list == 0 then print("PersonalBuffs: Unified list is empty") else
                print("PersonalBuffs: Unified SpellIDs:")
                for _, e in ipairs(list) do
                    local name = C_Spell.GetSpellInfo(e.id) or ("Spell "..e.id)
                    print("  ", e.id, "-", name)
                end
            end
            return
        elseif sub == "test" then
            PersonalBuffs:ShowGlobalTestIcons()
            return
        else
            print("PersonalBuffs global commands (operate on unified list):")
            print("  /pbuffs global        - open unified list UI")
            print("  /pbuffs global add <SpellID>")
            print("  /pbuffs global remove <SpellID>")
            print("  /pbuffs global list")
            print("  /pbuffs global test")
            return
        end
    end

    print("PersonalBuffs commands:")
    print("  /pbuffs config  - open settings")
    print("  /pbuffs list    - manage unified SpellIDs")
    print("  /pbuffs global  - alias to unified list (add/remove/list/test)")
    print("  /pbuffs learn   - toggle learning mode")
    print("  /pbuffs move    - unlock and move layout")
    print("  /pbuffs test    - show test icons")
    print("  /pbuffs clear   - clear learned data")
    print("  /pbuffs debug   - toggle debug logs")
end

-----------------------------------------------------------
-- Init helper
-----------------------------------------------------------
local init = CreateFrame("Frame")
init:RegisterEvent("PLAYER_LOGIN")
init:SetScript("OnEvent", function()
    EnsureConfig()
    InitializeIconPool()
    ScanEquippedTrinkets()
    ScanBuffs()
    UpdateDisplay()
    UpdateAnchorVisual()
end)
