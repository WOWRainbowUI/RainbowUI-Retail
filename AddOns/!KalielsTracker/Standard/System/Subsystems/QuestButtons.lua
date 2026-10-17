--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("QuestButtons")

local LSM = LibStub("LibSharedMedia-3.0")
local _DBG = function(...) if _DBG then _DBG("KT", ...) end end

-- Lua API
local ipairs = ipairs
local pairs = pairs
local tinsert = table.insert
local tremove = table.remove
local wipe = table.wipe

local db
local freeTags = {}
local freeButtons = {}
local fixedButtons = {}
local orderedSpellFrames = {}
local needReanchor = false
local needRebuild = false

local KTF
local OTF = KT_ObjectiveTrackerFrame

local KTBSetPoint, KTBClearAllPoints

-- ---------------------------------------------------------------------------------------------------------------------

local function AddFixedTag(block, tag)
    if block.rightEdgeFrame == tag then
        return
    end

    tag:ClearAllPoints()

    local settings = block.parentModule.questItemButtonSettings
    local spacing = block.parentModule.rightEdgeFrameSpacing
    if block.rightEdgeFrame then
        tag:SetPoint("RIGHT", block.rightEdgeFrame, "LEFT", -spacing, 0)
    else
        tag:SetPoint("TOPRIGHT", block, settings.offsetX + 6, settings.offsetY + 3)
        block:AdjustRightEdgeOffset(settings.offsetX)
    end

    tag:Show()

    block.rightEdgeFrame = tag
    block:AdjustRightEdgeOffset(-tag:GetWidth() - spacing)
    local isManaged = true
    block:OnAddedRegion(tag, isManaged)
end

local function RemoveFixedTag(block)
    local tag = block.fixedTag
    if tag then
        tinsert(freeTags, tag)
        tag.text:SetText("")
        tag:Hide()
        block.fixedTag = nil
    end
end

local function CreateFixedTag(block, x, y, anchor)
    local tag = block.fixedTag
    if not tag then
        local numFreeButtons = #freeTags
        if numFreeButtons > 0 then
            tag = freeTags[numFreeButtons]
            tremove(freeTags, numFreeButtons)
            tag:SetParent(block)
            tag:ClearAllPoints()
        else
            tag = CreateFrame("Frame", nil, block, "BackdropTemplate")
            tag:SetSize(32, 32)
            tag:SetBackdrop({ bgFile = KT.MEDIA_PATH.."UI-KT-QuestItemTag" })
            tag.text = tag:CreateFontString(nil, "ARTWORK", "GameFontNormalMed1")
            tag.text:SetFont(LSM:Fetch("font", "Arial Narrow"), 13, "")
            tag.text:SetPoint("CENTER", -0.5, 1)
        end
        block.fixedTag = tag
    end

    if not anchor then
        AddFixedTag(block, tag)
    else
        tag:SetPoint(anchor, block, x, y)
        tag:Show()
    end

    local colorStyle = KT_OBJECTIVE_TRACKER_COLOR["Normal"]
    if block.isHighlighted and colorStyle.reverse then
        colorStyle = colorStyle.reverse
    end
    tag:SetBackdropColor(colorStyle.r, colorStyle.g, colorStyle.b)
    tag.text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b)
end

-- ---------------------------------------------------------------------------------------------------------------------

local ItemButton_OnEvent = KT_QuestObjectiveItemButtonMixin.OnEvent
local ItemButton_OnShow = KT_QuestObjectiveItemButtonMixin.OnShow
local ItemButton_OnHide = KT_QuestObjectiveItemButtonMixin.OnHide
local ItemButton_UpdateCooldown = KT_QuestObjectiveItemButtonMixin.UpdateCooldown

local function ItemButton_OnUpdate(self, elapsed)  -- C KT_QuestObjectiveItemButtonMixin:OnUpdate
    local questLogIndex = self:GetAttribute("questLogIndex");
    if not questLogIndex then return end  -- for EditMode

    local rangeTimer = self.rangeTimer
    if rangeTimer then
        rangeTimer = rangeTimer - elapsed
        if rangeTimer <= 0 then
            local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
            if not charges or charges ~= self.charges then
                KT_QuestObjectiveTracker:MarkDirty()
                return
            end
            local count = self.HotKey
            local valid = IsQuestLogSpecialItemInRange(questLogIndex)
            if count:GetText() == RANGE_INDICATOR then
                if valid == 0 then
                    count:Show()
                    count:SetVertexColor(1.0, 0.1, 0.1)
                elseif valid == 1 then
                    count:Show()
                    count:SetVertexColor(0.6, 0.6, 0.6)
                else
                    count:Hide()
                end
            else
                if valid == 0 then
                    count:SetVertexColor(1.0, 0.1, 0.1)
                else
                    count:SetVertexColor(0.6, 0.6, 0.6)
                end
            end
            rangeTimer = TOOLTIP_UPDATE_TIME
        end
        self.rangeTimer = rangeTimer
    end
end

local function ItemButton_OnEnter(self)  -- C KT_QuestObjectiveItemButtonMixin:OnEnter
    self.block.isHighlighted = true
    self.block:UpdateHighlight()
    if KTF.anchorLeft then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", db.frameScale * 3)
    else
        GameTooltip:SetOwner(self, "ANCHOR_LEFT", db.frameScale * -3)
    end
    local questLogIndex = self:GetAttribute("questLogIndex");
    GameTooltip:SetQuestLogSpecialItem(questLogIndex)
end
KT_QuestObjectiveItemButtonMixin.OnEnter = ItemButton_OnEnter

local function ItemButton_OnLeave(self)  -- C KT_QuestObjectiveItemButtonMixin:OnLeave
    self.block.isHighlighted = false
    self.block:UpdateHighlight()
    GameTooltip:Hide()
end

local function SpellButton_OnEnter(self)  -- C KT_ScenarioSpellButtonMixin:OnEnter
    if KTF.anchorLeft then
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 3)
    else
        GameTooltip:SetOwner(self, "ANCHOR_LEFT", -3)
    end
    GameTooltip:SetSpellByID(self.spellID)
end

-- ---------------------------------------------------------------------------------------------------------------------

local function GetFixedButton(questID)
    return fixedButtons[questID]
end

local function CreateFixedButton(block, isSpell)
    local questID = block.id
    local button = GetFixedButton(questID)
    if not button then
        if InCombatLockdown() then
            _DBG(" - STOP Create button")
            needRebuild = true
            return
        end

        local numFreeButtons = #freeButtons
        if numFreeButtons > 0 then
            _DBG(" - USE button "..questID)
            button = freeButtons[numFreeButtons]
            tremove(freeButtons, numFreeButtons)
        else
            _DBG(" - CREATE button "..questID)
            button = CreateFrame("Button", nil, KTF.Buttons, "SecureActionButtonTemplate")
            button:SetSize(26, 26)

            button.icon = button:CreateTexture(nil, "BORDER")
            button.icon:SetAllPoints()
            button.Icon = button.icon   -- for Spell

            button.Count = button:CreateFontString(nil, "BORDER", "NumberFontNormal")
            button.Count:SetJustifyH("RIGHT")
            button.Count:SetPoint("BOTTOMRIGHT", button.icon, 0, 2)

            button.Cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
            button.Cooldown:SetAllPoints()

            button.HotKey = button:CreateFontString(nil, "ARTWORK", "NumberFontNormalSmallGray")
            button.HotKey:SetSize(29, 10)
            button.HotKey:SetJustifyH("RIGHT")
            button.HotKey:SetText(RANGE_INDICATOR)
            button.HotKey:SetPoint("TOPRIGHT", button.icon, 2, -2)

            button.text = button:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
            button.text:SetSize(29, 10)
            button.text:SetJustifyH("LEFT")
            button.text:SetPoint("TOPLEFT", button.icon, 1, -3)

            button:RegisterForClicks("AnyDown", "AnyUp")

            button:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
            do local tex = button:GetNormalTexture()
                tex:ClearAllPoints()
                tex:SetPoint("CENTER")
                tex:SetSize(44, 44)
            end
            button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
            button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
            button:SetFrameLevel(KTF:GetFrameLevel() + 1)
            --button:Hide()  -- Cooldown init

            if KT:Addon_IsModule(KT.AddonMasque) then
                KT.AddonMasque:AddButton(button, 1)
            end
        end
        if not isSpell then
            button:SetScript("OnEvent", ItemButton_OnEvent)
            button:SetScript("OnUpdate", ItemButton_OnUpdate)
            button:SetScript("OnShow", ItemButton_OnShow)
            button:SetScript("OnHide", ItemButton_OnHide)
            button:SetScript("OnEnter", ItemButton_OnEnter)
            button:SetScript("OnLeave", ItemButton_OnLeave)
        else
            button.HotKey:Hide()
            button:SetScript("OnEvent", nil)
            button:SetScript("OnUpdate", nil)
            button:SetScript("OnShow", nil)
            button:SetScript("OnHide", nil)
            button:SetScript("OnEnter", SpellButton_OnEnter)
            button:SetScript("OnLeave", GameTooltip_Hide)
        end
        button:SetAttribute("type", isSpell and "spell" or "item")
        button:Show()
        fixedButtons[questID] = button
        needReanchor = true
    end
    button.block = block
    block.ItemButton = button  -- reset inside Core
    button:SetAlpha(1)
    return button
end

local function SetFixedButton(block, idx, height, yOfs)
    if block.fixedTag and fixedButtons[block.id] then
        idx = idx + 1
        block.fixedTag.text:SetText(idx)
        fixedButtons[block.id].text:SetText(idx)
        fixedButtons[block.id].num = idx
        yOfs = -(height + 7)
        height = height + 26 + 3
        fixedButtons[block.id]:SetPoint("TOP", 0, yOfs)
    end
    return idx, height, yOfs
end

local function MarkReanchor()
    if KTF.Buttons.num > 0 then
        needReanchor = true
    end
end

-- ---------------------------------------------------------------------------------------------------------------------

local function SetFrames()
    -- Buttons frame
    local Buttons = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    Buttons:SetSize(40, 40)
    Buttons:SetPoint("TOPLEFT", 0, 0)
    Buttons:SetScale(db.frameScale)
    Buttons:SetFrameStrata(db.frameStrata)
    Buttons:SetFrameLevel(KTF:GetFrameLevel() - 1)  -- FIXME: wrong time for set this
    Buttons:SetAlpha(0)
    Buttons:Hide()
    Buttons.num = 0
    KTF.Buttons = Buttons

    -- Frame resets
    local Noop = function() end

    KTBSetPoint = Buttons.SetPoint
    Buttons.SetPoint = Noop
    Buttons.SetAllPoints = Noop
    KTBClearAllPoints = Buttons.ClearAllPoints
    Buttons.ClearAllPoints = Noop
end

-- ---------------------------------------------------------------------------------------------------------------------

local function SetHooks()
    if not KT_ScenarioObjectiveTracker then return end

    hooksecurefunc(KT_ScenarioSpellButtonMixin, "SetSpell", function(self, spellInfo)
        if KT:Module_IsCollapsed(KT_ScenarioObjectiveTracker) then return end

        self:Hide()
        local spellFrame = self:GetParent()
        spellFrame.id = spellInfo.spellID

        CreateFixedTag(spellFrame, 17, -2, "TOPLEFT")

        local button = CreateFixedButton(spellFrame, true)
        if button and not InCombatLockdown() then
            button.spellID = spellInfo.spellID
            button.Icon:SetTexture(spellInfo.spellIcon)
            self.UpdateCooldown(button)
            button:SetAttribute("spell", spellInfo.spellID)
        end
        spellFrame.KTSpellButton = button

        tinsert(orderedSpellFrames, spellFrame)
    end)

    hooksecurefunc(KT_ScenarioObjectiveTracker, "UpdateSpellCooldowns", function(self)
        for spellFrame in self.spellFramePool:EnumerateActive() do
            if spellFrame.KTSpellButton then
                spellFrame.SpellButton.UpdateCooldown(spellFrame.KTSpellButton)
            end
        end
    end)

    local bck_KT_ScenarioObjectiveTracker_MarkBlocksUnused = KT_ScenarioObjectiveTracker.MarkBlocksUnused
    function KT_ScenarioObjectiveTracker:MarkBlocksUnused()
        wipe(orderedSpellFrames)
        for spellFrame in self.spellFramePool:EnumerateActive() do
            KT.QuestButtons_Remove(spellFrame)
            spellFrame.KTSpellButton = nil
        end

        bck_KT_ScenarioObjectiveTracker_MarkBlocksUnused(self)
    end

    hooksecurefunc(KT_ScenarioObjectiveTracker, "FreeUnusedBlocks", function(self)
        if not self.ObjectivesBlock.used then
            for spellFrame in self.spellFramePool:EnumerateActive() do
                KT.QuestButtons_Remove(spellFrame)
                spellFrame.KTSpellButton = nil
            end
        end
    end)
end

-- ---------------------------------------------------------------------------------------------------------------------

function KT.QuestButtons_GetButtons()
    return fixedButtons
end

function KT.QuestButtons_Get(questID)
    return GetFixedButton(questID)
end

function KT.QuestButtons_Add(block, x, y)
    local questLogIndex = C_QuestLog.GetLogIndexForQuestID(block.id)
    if not questLogIndex then return end

    local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
    if item and (not block.questCompleted or showItemWhenComplete) then
        CreateFixedTag(block, x, y)

        if KT:Module_IsCollapsed(block.parentModule) then return end

        local button = CreateFixedButton(block)
        if button and not InCombatLockdown() then
            button:SetAttribute("questLogIndex", questLogIndex)
            button:SetAttribute("questID", block.id)
            button.charges = charges
            button.rangeTimer = -1
            button.item = item
            button.link = link
            SetItemButtonTexture(button, item)
            SetItemButtonCount(button, charges)
            ItemButton_UpdateCooldown(button)
            button:SetAttribute("item", link)
        end
    else
        KT.QuestButtons_Remove(block)
    end
end

function KT.QuestButtons_Remove(block)
    if block then
        RemoveFixedTag(block)

        local questID = block.id
        local button = GetFixedButton(questID)
        if button then
            button:SetAlpha(0)
            if InCombatLockdown() then
                _DBG(" - STOP Remove button")
                needRebuild = true
            else
                _DBG(" - REMOVE button "..questID)
                tinsert(freeButtons, button)
                fixedButtons[questID] = nil
                button:Hide()
                needReanchor = true
            end
        end
    else
        for questID, button in pairs(fixedButtons) do
            block = button.block
            if block then
                RemoveFixedTag(block)
            end

            _DBG(" - REMOVE button "..questID)
            tinsert(freeButtons, button)
            fixedButtons[questID] = nil
            button:Hide()
        end
        needReanchor = true
    end
end

function KT.QuestButtons_Move()
    if KTF.Buttons.num == 0 then return end

    if InCombatLockdown() then
        _DBG(" - STOP buttons Move")
        needRebuild = true
        return
    end

    local point, xOfs, yOfs
    if KTF.anchorLeft then
        point = "LEFT"
        xOfs = KTF:GetRight() and KTF:GetRight() + db.qiXOffset
    else
        point = "RIGHT"
        xOfs = KTF:GetLeft() and KTF:GetLeft() - db.qiXOffset
    end
    local hMod = 2 * (4 - db.bgrInset)
    local yMod = 0
    if not db.qiBgrBorder then
        hMod = hMod + 4
        yMod = 2 + (4 - db.bgrInset)
    end
    if KTF.directionUp and (db.maxHeight+hMod) < KTF.Buttons:GetHeight() then
        point = "BOTTOM"..point
        yOfs = KTF:GetBottom() and KTF:GetBottom() - yMod
    else
        point = "TOP"..point
        yOfs = KTF:GetTop() and KTF:GetTop() + yMod
    end
    if xOfs and yOfs then
        KTBClearAllPoints(KTF.Buttons)
        KTBSetPoint(KTF.Buttons, point, UIParent, "BOTTOMLEFT", xOfs, yOfs)
    end
end

function KT.QuestButtons_Rebuild()
    if needRebuild then
        needRebuild = false
        KT.QuestButtons_Remove()
    end
end

function KT.QuestButtons_Reanchor()
    if KTF.Buttons.num == 0 and not needReanchor then return end

    if InCombatLockdown() then
        _DBG(" - STOP buttons Reanchor")
        if KTF.Buttons.num > 0 then
            needRebuild = true
        end
    else
        if needReanchor then
            _DBG(" - REANCHOR buttons", true)
            local yOfs
            local idx = 0
            local contentsHeight = 0

            for _, module in ipairs(OTF.modules) do
                if module:HasContents() then
                    if module == KT_ScenarioObjectiveTracker then
                        if module.ObjectivesBlock.used then
                            for _, spellFrame in ipairs(orderedSpellFrames) do
                                idx, contentsHeight, yOfs = SetFixedButton(spellFrame, idx, contentsHeight, yOfs)
                            end
                        end
                    elseif module.questItemButtonSettings then
                        local block = module.firstBlock
                        while block do
                            if block.ItemButton then
                                idx, contentsHeight, yOfs = SetFixedButton(block, idx, contentsHeight, yOfs)
                            end
                            block = block.nextBlock
                        end
                    end
                end
            end

            if contentsHeight > 0 then
                contentsHeight = contentsHeight + 7 + 4
            end

            KTF.Buttons:SetHeight(contentsHeight)
            KTF.Buttons.num = idx
            needReanchor = false
        end

        if KT:Tracker_IsCollapsed() or KTF.Buttons.num == 0 then
            KTF.Buttons:Hide()
        else
            KTF.Buttons:SetShown(not KT.locked)
        end
    end

    if KT:Tracker_IsCollapsed() or KTF.Buttons.num == 0 then
        KTF.Buttons:SetAlpha(0)
    else
        KTF.Buttons:SetAlpha(1)
    end

    KT:SendSignal("BUTTONS_UPDATED")
end

KT.ItemButton = {
    OnEvent = ItemButton_OnEvent,
    OnUpdate = ItemButton_OnUpdate,
    OnShow = ItemButton_OnShow,
    OnHide = ItemButton_OnHide,
    OnEnter = ItemButton_OnEnter,
    OnLeave = ItemButton_OnLeave,
    UpdateCooldown = ItemButton_UpdateCooldown
}

KT.SpellButton = {
    OnEnter = SpellButton_OnEnter
}

function SS:Init()
    db = KT.db.profile
    KTF = KT.frame

    SetFrames()
    SetHooks()

    KT:RegSignal("MODULES_ORDER_CHANGED", MarkReanchor, self)
    KT:RegSignal("QUESTS_ORDER_CHANGED", MarkReanchor, self)

    KT:RegEvent("ZONE_CHANGED_NEW_AREA", MarkReanchor, self)
    KT:RegEvent("ZONE_CHANGED", MarkReanchor, self)
end