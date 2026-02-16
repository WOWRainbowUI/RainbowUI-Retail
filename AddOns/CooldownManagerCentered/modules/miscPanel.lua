local _, ns = ...

local MiscPanel = {}
ns.MiscPanel = MiscPanel

local DB = ns.TrackerDB
local ItemsData = ns.TrackerItemsData
local ItemVisuals = ns.TrackerItemVisuals
local ItemViewer = ns.TrackerItemViewer

local ITEM_STATE_SHOWN = ItemsData.ITEM_STATE_SHOWN
local ITEM_STATE_HIDDEN = ItemsData.ITEM_STATE_HIDDEN
local ITEM_STATE_TRACKER1 = ItemsData.ITEM_STATE_TRACKER1
local ITEM_STATE_TRACKER2 = ItemsData.ITEM_STATE_TRACKER2

local reorderSourceItem = nil
local reorderTarget = nil
local reorderTargetItem = nil
local reorderOffset = 0
local reorderEatNextGlobalMouseUp = nil
local reorderMarker = nil
local reorderCursor = nil
local reorderCursorFollow = false

local function IsTabButton(child)
    if not child then
        return false
    end
    if child._CMCTracker_IsTabButton then
        return true
    end
    local name = child:GetName()
    return name and name:find("Tab") ~= nil
end

function MiscPanel:HideMiscPanel(settingsFrame)
    if settingsFrame._CMCTracker_MiscPanel then
        settingsFrame._CMCTracker_MiscPanel:Hide()
    end

    local hidden = settingsFrame._CMCTracker_HiddenChildren
    if hidden then
        for _, child in ipairs(hidden) do
            if child and not child:IsShown() then
                child:Show()
            end
        end
        settingsFrame._CMCTracker_HiddenChildren = nil
    end
end

local function GetMiscPanelFrame()
    local settings = _G["CooldownViewerSettings"]
    return settings and settings._CMCTracker_MiscPanel or nil
end

local function GetEntryKindAndID(button)
    if not button then
        return nil, nil
    end
    return button._CMCTracker_EntryKind, button._CMCTracker_EntryID
end

local function SetButtonEntry(button, kind, id)
    if not button then
        return
    end
    button._CMCTracker_EntryKind = kind
    button._CMCTracker_EntryID = id
    if kind == "item" then
        button.itemID = id
        button.spellID = nil
    else
        button.itemID = nil
        button.spellID = id
    end
end

local function BuildEntry(kind, id)
    if not kind or not id then
        return nil
    end
    return {
        kind = kind,
        id = id,
    }
end

local function SetIconFromEntry(target, kind, id)
    if not target or not target.Icon then
        return
    end
    local quality = C_TradeSkillUI.GetItemReagentQualityByItemInfo(id)
    if quality then
        if not target.Icon._quality then
            target.Icon._quality_frame = CreateFrame("Frame", nil, target)
            target.Icon._quality_frame:SetAllPoints(target.Icon)
            target.Icon._quality_frame:SetFrameStrata("MEDIUM")
            target.Icon._quality_frame:SetFrameLevel(20)
            target.Icon._quality = target.Icon._quality_frame:CreateTexture(nil, "ARTWORK")
            target.Icon._quality:SetSize(33, 28)
        end
        target.Icon._quality:SetAtlas("Professions-Icon-Quality-Tier" .. quality .. "-Inv", false)
        target.Icon._quality:Show()
        target.Icon._quality:ClearAllPoints()
        target.Icon._quality:SetPoint("TOPLEFT", target.Icon, "TOPLEFT", -4, 4)
    else
        if target.Icon._quality then
            target.Icon._quality:Hide()
        end
    end

    if ItemVisuals.GetEntryIcon then
        target.Icon:SetTexture(ItemVisuals:GetEntryIcon(kind, id))
        return
    end
    local icon = nil
    if kind == "spell" then
        icon = C_Spell.GetSpellTexture(id)
    else
        icon = C_Item.GetItemIconByID(id)
    end
    target.Icon:SetTexture(icon or 134400)
end

local function IsEntryOwned(owned, kind, id)
    if not owned then
        return false
    end
    if kind == "spell" then
        return owned.spells[id]
    end
    return owned.items[id]
end

local function EnsureReorderMarker()
    if reorderMarker then
        return reorderMarker
    end

    local miscPanel = GetMiscPanelFrame()
    if not miscPanel then
        return nil
    end

    local marker = nil
    if _G["CooldownViewerSettingsReorderMarkerTemplate"] then
        local ok, created = pcall(CreateFrame, "Frame", nil, miscPanel, "CooldownViewerSettingsReorderMarkerTemplate")
        if ok then
            marker = created
        end
    end

    if not marker or not marker.Texture then
        marker = CreateFrame("Frame", nil, miscPanel)
        marker:SetSize(12, 12)
        marker.Texture = marker:CreateTexture(nil, "OVERLAY")
        marker.Texture:SetAllPoints()
    end

    if not marker.SetHorizontal then
        function marker:SetHorizontal()
            if self.Texture and self.Texture.SetAtlas then
                self.Texture:SetAtlas("cdm-vertical", true)
            elseif self.Texture then
                self.Texture:SetColorTexture(1, 1, 1, 1)
            end
        end
    end

    marker:Hide()
    local spacing = miscPanel._CMCTracker_ItemSpacing or 8
    local itemSize = miscPanel._CMCTracker_ItemSize or 38
    marker:SetSize(spacing, itemSize)
    reorderMarker = marker
    return reorderMarker
end

local function EnsureReorderCursor()
    if reorderCursor then
        return reorderCursor
    end

    local frame = CreateFrame("Frame", nil, GetAppropriateTopLevelParent(), "CooldownViewerSettingsDraggedItemTemplate")
    frame:Hide()
    reorderCursor = frame
    return reorderCursor
end

local function PickupItemCursor(itemButton)
    local cursor = EnsureReorderCursor()
    if not cursor then
        return
    end

    if cursor.SetToCursor then
        cursor:SetToCursor(itemButton)
        reorderCursorFollow = false
    else
        if cursor.Icon and itemButton and itemButton.Icon then
            cursor.Icon:SetTexture(itemButton.Icon:GetTexture())
        end
        cursor:Show()
        reorderCursorFollow = true
    end
end

local function ClearItemCursor()
    if reorderCursor then
        if reorderCursor.StopMovingOrSizing then
            reorderCursor:StopMovingOrSizing()
        end
        reorderCursor:Hide()
    end
    reorderCursorFollow = false
end

local function IsReordering()
    return reorderSourceItem ~= nil
end

local function SetReorderTarget(target)
    if IsReordering() then
        reorderTarget = target
    end
end

local function UpdateReorderMarker()
    local marker = EnsureReorderMarker()
    if not marker then
        return
    end

    local miscPanel = GetMiscPanelFrame()
    if miscPanel then
        local spacing = miscPanel._CMCTracker_ItemSpacing or 8
        local itemSize = miscPanel._CMCTracker_ItemSize or 38
        marker:SetSize(spacing, itemSize)
    end

    local target = reorderTarget
    marker:SetShown(target ~= nil)
    if not target then
        return
    end

    local cursorX, cursorY = GetCursorPosition()
    local scale = GetAppropriateTopLevelParent():GetScale()
    cursorX, cursorY = cursorX / scale, cursorY / scale

    local targetItem = target.GetBestCooldownItemTarget and target:GetBestCooldownItemTarget(cursorX, cursorY) or nil
    reorderTargetItem = targetItem
    if targetItem and targetItem.UpdateReorderMarkerPosition then
        marker:ClearAllPoints()
        local isMarkerAfterTarget = targetItem:UpdateReorderMarkerPosition(marker, cursorX, cursorY)
        reorderOffset = isMarkerAfterTarget and 1 or 0
    end

    if reorderCursorFollow and reorderCursor then
        reorderCursor:ClearAllPoints()
        reorderCursor:SetPoint("TOPLEFT", GetAppropriateTopLevelParent(), "BOTTOMLEFT", cursorX, cursorY)
    end
end

local function CancelOrderChange()
    if reorderSourceItem and reorderSourceItem.SetReorderLocked then
        reorderSourceItem:SetReorderLocked(false)
    end
    if reorderMarker then
        reorderMarker:Hide()
    end
    reorderSourceItem = nil
    reorderTarget = nil
    reorderTargetItem = nil
    reorderOffset = 0
    reorderEatNextGlobalMouseUp = nil
    ClearItemCursor()

    local miscPanel = GetMiscPanelFrame()
    if miscPanel then
        miscPanel:SetScript("OnUpdate", nil)
        miscPanel:UnregisterEvent("GLOBAL_MOUSE_UP")
    end
end

local function EndOrderChange()
    local sourceItem = reorderSourceItem
    local targetItem = reorderTargetItem

    if sourceItem and targetItem and sourceItem ~= targetItem then
        local targetState = targetItem.categoryState or sourceItem.categoryState
        local sourceKind, sourceID = GetEntryKindAndID(sourceItem)
        if sourceKind and sourceID then
            if targetItem._CMCTracker_Empty then
                if sourceItem.categoryState ~= targetState then
                    ItemsData:SetEntryState(sourceKind, sourceID, targetState)
                end
                ItemsData:InsertItemAt(targetState, BuildEntry(sourceKind, sourceID), nil, false)
            else
                local targetKind, targetID = GetEntryKindAndID(targetItem)
                if targetKind and targetID then
                    if sourceItem.categoryState ~= targetState then
                        ItemsData:SetEntryState(sourceKind, sourceID, targetState)
                    end
                    ItemsData:InsertItemAt(
                        targetState,
                        BuildEntry(sourceKind, sourceID),
                        BuildEntry(targetKind, targetID),
                        reorderOffset == 0
                    )
                end
            end
        end
    end

    CancelOrderChange()
    MiscPanel:RefreshMiscPanel()
    ItemViewer:RefreshItemViewerFrames()
end

local function BeginOrderChange(itemButton, eatNextGlobalMouseUp)
    if IsReordering() or not itemButton or itemButton._CMCTracker_Empty then
        return
    end

    reorderSourceItem = itemButton
    reorderTarget = itemButton
    reorderTargetItem = itemButton
    reorderOffset = 0
    reorderEatNextGlobalMouseUp = eatNextGlobalMouseUp

    if itemButton.SetReorderLocked then
        itemButton:SetReorderLocked(true)
    end

    PickupItemCursor(itemButton)
    EnsureReorderMarker()

    local miscPanel = GetMiscPanelFrame()
    if miscPanel then
        miscPanel:SetScript("OnUpdate", function()
            UpdateReorderMarker()
        end)
        miscPanel:SetScript("OnEvent", function(_self, event, ...)
            if event == "GLOBAL_MOUSE_UP" then
                local button = ...
                if reorderEatNextGlobalMouseUp == button then
                    reorderEatNextGlobalMouseUp = nil
                    return
                end
                if PlaySound and SOUNDKIT and SOUNDKIT.UI_CURSOR_DROP_OBJECT then
                    PlaySound(SOUNDKIT.UI_CURSOR_DROP_OBJECT)
                end
                if button == "LeftButton" then
                    EndOrderChange()
                elseif button == "RightButton" then
                    CancelOrderChange()
                end
            end
        end)
        miscPanel:RegisterEvent("GLOBAL_MOUSE_UP")
    end
end

local function ShowItemContextMenu(button)
    if not button then
        return
    end
    local kind, id = GetEntryKindAndID(button)
    if not kind or not id then
        return
    end
    local hiddenLabel = "Move to Not Displayed"

    local function Generator(owner, rootDescription)
        rootDescription:CreateButton("Show in First Tracker", function()
            ItemsData:SetEntryState(kind, id, ITEM_STATE_TRACKER1)
            MiscPanel:RefreshMiscPanel()
            ItemViewer:RefreshItemViewerFrames()
        end)
        rootDescription:CreateButton("Show in Second Tracker", function()
            ItemsData:SetEntryState(kind, id, ITEM_STATE_TRACKER2)
            MiscPanel:RefreshMiscPanel()
            ItemViewer:RefreshItemViewerFrames()
        end)
        rootDescription:CreateButton(hiddenLabel, function()
            ItemsData:SetEntryState(kind, id, ITEM_STATE_HIDDEN)
            MiscPanel:RefreshMiscPanel()
            ItemViewer:RefreshItemViewerFrames()
        end)
    end

    MenuUtil.CreateContextMenu(button, Generator)
end

local function InitializeItemButton(button)
    if button._CMCTracker_Initialized then
        return
    end

    if button.Cooldown then
        if ItemVisuals then
            ItemVisuals:ClearCooldown(button, nil)
        else
            CooldownFrame_Clear(button.Cooldown)
            button.Cooldown:SetDrawSwipe(false)
        end
        button.Cooldown:SetDrawEdge(false)
    end

    if button.OutOfRange then
        button.OutOfRange:Hide()
    end

    button:SetScript("OnMouseUp", function(self, mouseButton)
        if mouseButton == "RightButton" then
            ShowItemContextMenu(self)
        elseif mouseButton == "LeftButton" and not self._CMCTracker_Empty then
            if PlaySound and SOUNDKIT and SOUNDKIT.UI_CURSOR_PICKUP_OBJECT then
                PlaySound(SOUNDKIT.UI_CURSOR_PICKUP_OBJECT)
            end
            BeginOrderChange(self, mouseButton)
        end
    end)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(self)
        if self._CMCTracker_Empty then
            return
        end
        if PlaySound and SOUNDKIT and SOUNDKIT.UI_CURSOR_PICKUP_OBJECT then
            PlaySound(SOUNDKIT.UI_CURSOR_PICKUP_OBJECT)
        end
        BeginOrderChange(self)
    end)
    button:SetScript("OnEnter", function(self)
        SetReorderTarget(self)
        if self._CMCTracker_Empty then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if GameTooltip_SetTitle then
                GameTooltip_SetTitle(GameTooltip, "Empty Slot")
            else
                GameTooltip:SetText("Empty Slot")
            end
            GameTooltip:Show()
        else
            local kind, id = GetEntryKindAndID(self)
            if kind and id then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if kind == "spell" then
                    if GameTooltip.SetSpellByID then
                        GameTooltip:SetSpellByID(id)
                    else
                        local name = ItemsData:GetEntryName(kind, id)
                        if name then
                            GameTooltip:SetText(name)
                        end
                    end
                else
                    GameTooltip:SetItemByID(id)
                end
                GameTooltip:Show()
            end
        end
    end)
    button:SetScript("OnLeave", function()
        GameTooltip_Hide()
    end)

    function button:SetReorderLocked(locked)
        self._CMCTracker_ReorderLocked = locked and true or false
        if self.Icon then
            self.Icon:SetDesaturated(self._CMCTracker_ReorderLocked)
        end
    end

    function button:IsReorderLocked()
        return self._CMCTracker_ReorderLocked == true
    end

    function button:IsEmptyCategory()
        return self._CMCTracker_Empty == true
    end

    function button:GetBestCooldownItemTarget(_cursorX, _cursorY)
        return self
    end

    function button:UpdateReorderMarkerPosition(marker, cursorX, _cursorY)
        if marker and marker.SetHorizontal then
            marker:SetHorizontal()
        end
        local centerX = self:GetCenter()
        if centerX and cursorX < centerX then
            marker:SetPoint("CENTER", self, "LEFT", -4, 0)
            return false
        else
            marker:SetPoint("CENTER", self, "RIGHT", 4, 0)
            return true
        end
    end

    button:HookScript("OnShow", function(self)
        if not self.Icon then
            return
        end
        if self._CMCTracker_Empty then
            if ItemVisuals then
                ItemVisuals:SetEmptySlot(self)
            else
                self.Icon:SetTexture(nil)
                self.Icon:SetAtlas("cdm-empty", true)
            end
        else
            local kind, id = GetEntryKindAndID(self)
            if kind and id then
                SetIconFromEntry(self, kind, id)
            end
        end
    end)

    button._CMCTracker_Initialized = true
end

local function AcquireItemButton(category)
    local button = category.itemPool:Acquire()
    InitializeItemButton(button)
    button:Show()
    return button
end

local function ResetCategoryButtons(category)
    category.itemPool:ReleaseAll()

    local container = category.Container
    if container then
        for _, child in ipairs({ container:GetChildren() }) do
            if child.layoutIndex ~= nil then
                child.layoutIndex = nil
            end
        end
    end
end

function MiscPanel:LayoutCategory(category, entries, owned)
    ResetCategoryButtons(category)

    local container = category.Container or category.Content
    local headerHeight = category.Header:GetHeight()
    local isCollapsed = category.IsCollapsed and category:IsCollapsed() or category.Collapsed
    if isCollapsed then
        if category.SetCollapsed then
            category:SetCollapsed(true)
        elseif container then
            container:Hide()
        end
        category:SetHeight(headerHeight)
        return
    end

    if category.SetCollapsed then
        category:SetCollapsed(false)
    elseif container then
        container:Show()
    end

    local size = 38
    local spacing = 8

    local miscPanel = GetMiscPanelFrame()
    if miscPanel then
        miscPanel._CMCTracker_ItemSpacing = spacing
        miscPanel._CMCTracker_ItemSize = size
    end

    if #entries == 0 then
        local emptyButton = AcquireItemButton(category)
        SetButtonEntry(emptyButton, nil, nil)
        emptyButton._CMCTracker_Empty = true
        emptyButton.categoryState = category.state
        emptyButton.layoutIndex = 1
        emptyButton:ClearAllPoints()
        emptyButton:SetSize(size, size)
        if ItemVisuals then
            ItemVisuals:SetEmptySlot(emptyButton)
        else
            if emptyButton.Icon then
                emptyButton.Icon:SetTexture(nil)
                emptyButton.Icon:SetAtlas("cdm-empty", true)
                emptyButton.Icon:SetDesaturated(false)
            end
            if emptyButton.Cooldown then
                CooldownFrame_Clear(emptyButton.Cooldown)
            end
        end
    else
        for index, entry in ipairs(entries) do
            local button = AcquireItemButton(category)
            SetButtonEntry(button, entry.kind, entry.id)
            button._CMCTracker_Empty = false
            button.categoryState = category.state
            button.layoutIndex = index
            button:ClearAllPoints()
            button:SetSize(size, size)

            SetIconFromEntry(button, entry.kind, entry.id)
            if button.Icon then
                button.Icon:SetDesaturated(not IsEntryOwned(owned, entry.kind, entry.id))
            end

            if button.Cooldown then
                CooldownFrame_Clear(button.Cooldown)
            end
        end
    end

    if container and container.Layout then
        container.childXPadding = spacing
        container.childYPadding = spacing
        container.isHorizontal = true
        container.stride = 7
        container.layoutFramesGoingRight = true
        container.layoutFramesGoingUp = false
        container.alwaysUpdateLayout = true
        container:Layout()
    end

    local contentHeight = container and container:GetHeight() or 0
    local totalHeight = nil
    if category.Header and container then
        local headerTop = category.Header:GetTop()
        local containerBottom = container:GetBottom()
        if headerTop and containerBottom then
            totalHeight = headerTop - containerBottom
        end
    end
    category:SetHeight(totalHeight or (headerHeight + 6 + contentHeight))
end

function MiscPanel:CreateItemCategory(parent, title, state)
    local categoryDisplay = CreateFrame("Frame", nil, parent, "CooldownViewerSettingsCategoryTemplate")
    categoryDisplay.state = state
    categoryDisplay.Collapsed = false
    categoryDisplay.Header:SetHeaderText(title)

    function categoryDisplay:SetCollapsed(collapsed)
        self.Collapsed = collapsed and true or false
        if self.Header and self.Header.UpdateCollapsedState then
            self.Header:UpdateCollapsedState(self.Collapsed)
        end
        if self.Header then
            local title = self.Header.TitleText or self.Header.Title
            if title then
                if not self.Header._CMCTracker_TitlePoints then
                    self.Header._CMCTracker_TitlePoints = {}
                    for i = 1, title:GetNumPoints() do
                        self.Header._CMCTracker_TitlePoints[i] = { title:GetPoint(i) }
                    end
                end
                if self.Header._CMCTracker_TitlePoints and #self.Header._CMCTracker_TitlePoints > 0 then
                    title:ClearAllPoints()
                    for _, point in ipairs(self.Header._CMCTracker_TitlePoints) do
                        title:SetPoint(unpack(point))
                    end
                end
            end
        end
        if self.Container then
            self.Container:SetShown(not self.Collapsed)
            if self.Container.Layout then
                self.Container:Layout()
            end
        end
    end

    function categoryDisplay:IsCollapsed()
        return self.Collapsed == true
    end

    function categoryDisplay:ToggleCollapsed()
        self:SetCollapsed(not self:IsCollapsed())
        MiscPanel:RefreshMiscPanel()
    end

    if categoryDisplay.Header then
        if categoryDisplay.Header.CollapseButton then
            categoryDisplay.Header.CollapseButton:Hide()
            categoryDisplay.Header.CollapseButton:Disable()
        end
        if categoryDisplay.Header.Toggle then
            categoryDisplay.Header.Toggle:Hide()
            categoryDisplay.Header.Toggle:Disable()
        end
    end

    if not categoryDisplay.Container then
        categoryDisplay.Container = CreateFrame("Frame", nil, categoryDisplay)
        categoryDisplay.Container:SetPoint("TOPLEFT", categoryDisplay, "TOPLEFT", 0, 0)
        categoryDisplay.Container:SetPoint("TOPRIGHT", categoryDisplay, "TOPRIGHT", 0, 0)
    end

    categoryDisplay:SetScript("OnEnter", function(self)
        SetReorderTarget(self)
    end)
    if categoryDisplay.Container then
        categoryDisplay.Container:SetScript("OnEnter", function()
            SetReorderTarget(categoryDisplay)
        end)
    end

    categoryDisplay.itemPool = CreateFramePool(
        "Frame",
        categoryDisplay.Container,
        "CooldownViewerSettingsItemTemplate",
        function(_, frame)
            frame:Hide()
            frame.layoutIndex = nil
            frame.itemID = nil
            frame.spellID = nil
            frame._CMCTracker_EntryKind = nil
            frame._CMCTracker_EntryID = nil
            frame._CMCTracker_Empty = nil
            if frame.Icon then
                frame.Icon:SetTexture(nil)
            end
        end
    )

    function categoryDisplay:GetNearestItemToCursorWeighted(cursorX, cursorY)
        local nearestItem = nil
        local nearestVertical = math.huge
        local nearestHorizontal = math.huge

        for item in self.itemPool:EnumerateActive() do
            local left, right, bottom, top = item:GetLeft(), item:GetRight(), item:GetBottom(), item:GetTop()
            if left and right and bottom and top then
                local centerX = (left + right) / 2
                local centerY = (bottom + top) / 2
                local horizontalDistance = math.abs(centerX - cursorX)
                local verticalDistance = math.abs(centerY - cursorY)
                if cursorY > bottom and cursorY < top then
                    verticalDistance = 0
                end
                if
                    verticalDistance < nearestVertical
                    or (verticalDistance == nearestVertical and horizontalDistance < nearestHorizontal)
                then
                    nearestItem = item
                    nearestVertical = verticalDistance
                    nearestHorizontal = horizontalDistance
                end
            end
        end

        return nearestItem
    end

    function categoryDisplay:GetBestCooldownItemTarget(cursorX, cursorY)
        return self:GetNearestItemToCursorWeighted(cursorX, cursorY)
    end

    if categoryDisplay.Header and categoryDisplay.Header.SetClickHandler then
        categoryDisplay.Header:SetClickHandler(function(_, button)
            if button == "LeftButton" then
                categoryDisplay:ToggleCollapsed()
            end
        end)
    elseif categoryDisplay.Header then
        categoryDisplay.Header:SetScript("OnMouseUp", function(_, button)
            if button == "LeftButton" then
                categoryDisplay:ToggleCollapsed()
            end
        end)
    end

    categoryDisplay:SetCollapsed(false)

    return categoryDisplay
end

function MiscPanel:RefreshMiscPanel(settingsFrame)
    if not ns.db.profile.tracker_enabled then
        return
    end
    local owned = ItemsData:ScanOwnedItems()
    ItemsData:EnsureTrackedItems(owned)

    local frame = settingsFrame or _G["CooldownViewerSettings"]
    local miscPanel = frame._CMCTracker_MiscPanel
    if not miscPanel then
        return
    end

    if miscPanel.SetPortraitToSpecIcon then
        miscPanel:SetPortraitToSpecIcon()
    end

    local showUnusable = DB.GetShowingUnusable()
    local tracker1Entries = ItemsData:GetEntriesByState(ITEM_STATE_TRACKER1)
    local tracker2Entries = ItemsData:GetEntriesByState(ITEM_STATE_TRACKER2)
    local hiddenEntries = ItemsData:GetEntriesByState(ITEM_STATE_HIDDEN)

    if not showUnusable then
        -- Filter out items the player does not own (same logic as icon desaturation)
        local filteredTracker1Entries = {}
        for _, entry in ipairs(tracker1Entries) do
            if IsEntryOwned(owned, entry.kind, entry.id) then
                table.insert(filteredTracker1Entries, entry)
            end
        end
        local filteredTracker2Entries = {}
        for _, entry in ipairs(tracker2Entries) do
            if IsEntryOwned(owned, entry.kind, entry.id) then
                table.insert(filteredTracker2Entries, entry)
            end
        end
        local filteredHidden = {}
        for _, entry in ipairs(hiddenEntries) do
            if IsEntryOwned(owned, entry.kind, entry.id) then
                table.insert(filteredHidden, entry)
            end
        end
        tracker1Entries = filteredTracker1Entries
        tracker2Entries = filteredTracker2Entries
        hiddenEntries = filteredHidden
    end

    -- Filter by search term
    local searchTerm = miscPanel._CMCTracker_SearchTerm or ""
    if searchTerm ~= "" then
        local function matchesSearch(entry)
            local name = ItemsData:GetEntryName(entry.kind, entry.id)
            return name and name:lower():find(searchTerm:lower(), 1, true)
        end
        local filteredTracker1 = {}
        for _, entry in ipairs(tracker1Entries) do
            if matchesSearch(entry) then
                table.insert(filteredTracker1, entry)
            end
        end
        local filteredTracker2 = {}
        for _, entry in ipairs(tracker2Entries) do
            if matchesSearch(entry) then
                table.insert(filteredTracker2, entry)
            end
        end
        local filteredHidden = {}
        for _, entry in ipairs(hiddenEntries) do
            if matchesSearch(entry) then
                table.insert(filteredHidden, entry)
            end
        end
        tracker1Entries = filteredTracker1
        tracker2Entries = filteredTracker2
        hiddenEntries = filteredHidden
    end

    local categories = miscPanel._CMCTracker_Categories
    if not categories then
        return
    end

    ItemsData:CleanupHiddenEntries(owned)
    self:LayoutCategory(categories[1], tracker1Entries, owned)
    self:LayoutCategory(categories[2], tracker2Entries, owned)
    self:LayoutCategory(categories[3], hiddenEntries, owned)

    local scrollChild = miscPanel._CMCTracker_ScrollChild
    if scrollChild then
        local yOffset = 0
        local previousCategory = nil
        for _, category in ipairs(categories) do
            category:ClearAllPoints()
            if previousCategory then
                category:SetPoint("TOPLEFT", previousCategory, "BOTTOMLEFT", 0, -18)
            else
                category:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
            end
            yOffset = yOffset + category:GetHeight() + (previousCategory and 18 or 0)
            previousCategory = category
        end
        local scrollFrame = miscPanel._CMCTracker_ScrollFrame
        if scrollFrame then
            local paddingHeight = 18
            local frameHeight = scrollFrame:GetHeight() or 0
            local needsScrollPadding = previousCategory and (frameHeight > 0 and yOffset > frameHeight)
            if needsScrollPadding then
                if not miscPanel._CMCTracker_ScrollPadding then
                    miscPanel._CMCTracker_ScrollPadding = CreateFrame("Frame", nil, scrollChild)
                    miscPanel._CMCTracker_ScrollPadding:SetHeight(paddingHeight)
                end
                miscPanel._CMCTracker_ScrollPadding:ClearAllPoints()
                miscPanel._CMCTracker_ScrollPadding:SetPoint("TOPLEFT", previousCategory, "BOTTOMLEFT")
                miscPanel._CMCTracker_ScrollPadding:SetPoint("TOPRIGHT", previousCategory, "BOTTOMRIGHT")
                miscPanel._CMCTracker_ScrollPadding:Show()
                scrollChild:SetHeight(math.max(1, yOffset + paddingHeight))
            elseif miscPanel._CMCTracker_ScrollPadding then
                miscPanel._CMCTracker_ScrollPadding:Hide()
                scrollChild:SetHeight(math.max(1, yOffset))
            end

            scrollFrame:UpdateScrollChildRect()
        else
            scrollChild:SetHeight(math.max(1, yOffset))
        end
    end
end

local function ShowMiscPanel(settingsFrame)
    local miscPanel = settingsFrame._CMCTracker_MiscPanel
    if not miscPanel then
        return
    end

    local hidden = {}
    for _, child in ipairs({ settingsFrame:GetChildren() }) do
        if child:IsShown() and child ~= miscPanel and not IsTabButton(child) then
            child:Hide()
            table.insert(hidden, child)
        end
    end

    settingsFrame._CMCTracker_HiddenChildren = hidden
    MiscPanel:RefreshMiscPanel(settingsFrame)
    miscPanel:Show()
end

function MiscPanel:EnsureMiscSettingsTab(settingsFrame)
    if settingsFrame._CMCTracker_MiscPanel or not ns.db.profile.tracker_enabled then
        return
    end

    local miscPanel = CreateFrame("Frame", "_CMCTracker_MiscPanel", settingsFrame, "ButtonFrameTemplate")
    miscPanel:SetAllPoints(settingsFrame)
    miscPanel:Hide()
    miscPanel.Inset.Bg:SetAtlas("character-panel-background", true)
    miscPanel.Inset.Bg:SetHorizTile(false)
    miscPanel.Inset.Bg:SetVertTile(false)
    miscPanel.TitleContainer.TitleText:SetText("Cooldown Settings")

    if miscPanel.CloseButton then
        miscPanel.CloseButton:SetScript("OnClick", function()
            HideUIPanel(settingsFrame)
        end)
    end

    settingsFrame._CMCTracker_MiscPanel = miscPanel

    local scrollFrame = CreateFrame("ScrollFrame", "$parent.CooldownScroll", miscPanel, "ScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 17, -72)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 29)

    local scrollChild = CreateFrame("Frame", "$parent.Content", scrollFrame)
    scrollChild:SetSize(300, 1)
    scrollChild:SetPoint("TOPLEFT", 0, 0)
    scrollChild:SetPoint("TOPRIGHT", 0, 0)
    scrollFrame:SetScrollChild(scrollChild)
    scrollFrame.ScrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 6, 0)
    scrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 6, 0)

    scrollFrame:SetScript("OnSizeChanged", function(self)
        scrollChild:SetWidth(self:GetWidth())
        MiscPanel:RefreshMiscPanel(settingsFrame)
    end)

    miscPanel:HookScript("OnShow", function()
        scrollChild:SetWidth(scrollFrame:GetWidth())
        MiscPanel:RefreshMiscPanel(settingsFrame)
    end)

    local firstCategory = self:CreateItemCategory(scrollChild, "First Tracker", ITEM_STATE_TRACKER1)
    local secondCategory = self:CreateItemCategory(scrollChild, "Second Tracker", ITEM_STATE_TRACKER2)
    local hiddenCategory = self:CreateItemCategory(scrollChild, "Not Displayed", ITEM_STATE_HIDDEN)

    miscPanel._CMCTracker_Categories = { firstCategory, secondCategory, hiddenCategory }
    miscPanel._CMCTracker_ScrollChild = scrollChild
    miscPanel._CMCTracker_ScrollFrame = scrollFrame
    local spellsTab = settingsFrame.SpellsTab
    local aurasTab = settingsFrame.AurasTab

    spellsTab._CMCTracker_IsTabButton = true
    aurasTab._CMCTracker_IsTabButton = true

    -- Create a dedicated search box for the MiscPanel, matching Blizzard's CooldownViewerSettings XML
    if not miscPanel._CMCTracker_SearchBox then
        local searchBox = CreateFrame("EditBox", nil, miscPanel, "SearchBoxTemplate")
        searchBox:SetSize(290, 30)
        searchBox:SetPoint("TOPLEFT", miscPanel, "TOPLEFT", 72, -30)
        searchBox.Instructions:SetText("Enter search text")
        searchBox:SetScript("OnTextChanged", function(self)
            self.Instructions:SetShown(self:GetText() == "")
            miscPanel._CMCTracker_SearchTerm = self:GetText()
            MiscPanel:RefreshMiscPanel(settingsFrame)
        end)
        searchBox:Hide()
        miscPanel._CMCTracker_SearchBox = searchBox
    end

    if not miscPanel._CMCTracker_SettingsDropdown then
        local settingsDropdown = CreateFrame("DropdownButton", nil, miscPanel, "UIPanelIconDropdownButtonTemplate")
        settingsDropdown:SetPoint("LEFT", miscPanel._CMCTracker_SearchBox, "RIGHT", 5, 0)
        settingsDropdown:SetupMenu(function(owner, rootDescription)
            rootDescription:CreateCheckbox("Show Unusable", DB.GetShowingUnusable, DB.ToggleShowUnusable)
        end)
        settingsDropdown:Hide()
        miscPanel._CMCTracker_SettingsDropdown = settingsDropdown
    end

    miscPanel:HookScript("OnShow", function(self)
        if self._CMCTracker_SearchBox then
            self._CMCTracker_SearchBox:Show()
        end
        if self._CMCTracker_SettingsDropdown then
            self._CMCTracker_SettingsDropdown:Show()
        end
    end)
    miscPanel:HookScript("OnHide", function(self)
        if self._CMCTracker_SearchBox then
            self._CMCTracker_SearchBox:Hide()
        end
        if self._CMCTracker_SettingsDropdown then
            self._CMCTracker_SettingsDropdown:Hide()
        end
    end)

    -- Do not parent the miscTab to settingsFrame! Doing so will add it to its .TabButtons list and will taint everything inside CooldownViewer as a result.
    local miscTab = CreateFrame("Button", "$parent.MiscTab", UIParent, "CooldownViewerSettingsTabTemplate")
    miscTab._CMCTracker_IsTabButton = true
    miscTab.tooltipText = "CMC Tracker"
    miscTab.displayMode = "tracker"
    miscTab.activeAtlas = "GreenCross"
    miscTab.inactiveAtlas = "GreenCross"
    miscTab:SetChecked(false)
    miscTab:SetPoint("TOP", aurasTab, "BOTTOM", 0, -3)

    -- Hide the tab when the settings window is closed
    settingsFrame:HookScript("OnHide", function()
        miscTab:Hide()
    end)
    settingsFrame:HookScript("OnShow", function()
        miscTab:Show()
    end)

    miscTab:SetScript("OnClick", function(self)
        if settingsFrame._CMCTracker_MiscPanel:IsShown() then
            return
        end

        spellsTab:SetChecked(false)
        aurasTab:SetChecked(false)
        self:SetChecked(true)

        ShowMiscPanel(settingsFrame)
    end)

    hooksecurefunc(settingsFrame, "SetDisplayMode", function(self, mode)
        spellsTab:SetChecked(mode == "spells")
        aurasTab:SetChecked(mode == "auras")
        miscTab:SetChecked(mode == "tracker")
        MiscPanel:HideMiscPanel(self)
    end)

    miscTab:Show()
end
