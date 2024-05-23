---@class RemixGemHelperPrivate
local Private = select(2, ...)
local const = Private.constants
local gemUtil = Private.GemUtil
local misc = Private.Misc
local addon = Private.Addon

local uiElements = {}
Private.UIElements = uiElements
local function extractPreClick(self)
    if not self.info then return end
    if not misc:IsAllowedForClick("EXTRACT_PRECLICK") then return end
    local info = self.info
    if info.locType == "EQUIP_SOCKET" then
        SocketInventoryItem(info.locIndex)
    elseif info.locType == "BAG_SOCKET" then
        C_Container.SocketContainerItem(info.locIndex, info.locSlot)
    elseif info.locType == "BAG_GEM" then
        local equipSlot, equipSocket = select(3, gemUtil:GetSocketsInfo(info.gemType))
        C_Container.PickupContainerItem(info.locIndex, info.locSlot)
        SocketInventoryItem(equipSlot)
        info.freeSlot = equipSocket
    end
end

local function extractPostClick(self)
    if not self.info then return end
    if not misc:IsAllowedForClick("EXTRACT_POSTCLICK") then return end
    local info = self.info
    if info.locType == "BAG_GEM" then
        ClearCursor()
        if not info.freeSlot then
            misc:PrintError(addon.Loc["You don't have a valid free Slot for this Gem"])
            CloseSocketInfo()
            return
        end
        C_Container.PickupContainerItem(info.locIndex, info.locSlot)
        ClickSocketButton(info.freeSlot)
        AcceptSockets()
    end
    CloseSocketInfo()
end
function uiElements:CreateExtractButton(parent)
    ---@class ExtractButton : Button
    ---@field UpdateInfo fun(self:ExtractButton, infoType:"BAG_GEM"|"BAG_SOCKET"|"EQUIP_SOCKET"|table, infoIndex:number|?, infoSlot:number|?, infoGemType:"Meta"|"Cogwheel"|"Tinker"|"Prismatic"|"Primordial"|?, newGemSlot:number|?)
    local extractButton = CreateFrame("Button", nil, parent, "InsecureActionButtonTemplate")
    extractButton:SetAllPoints()
    extractButton:SetScript("PreClick", extractPreClick)
    extractButton:SetScript("PostClick", extractPostClick)
    extractButton:SetScript("OnHide", function(btn)
        btn:EnableMouse(false)
    end)
    extractButton:SetScript("OnShow", function(btn)
        btn:EnableMouse(true)
    end)
    extractButton:RegisterForClicks("AnyDown")
    extractButton:SetAttribute("pressAndHoldAction", 1)
    extractButton:SetAttribute("type", "macro")

    function extractButton:UpdateInfo(newType, newIndex, newSlot, newGemType, newGemSlot)
        if type(newType) == "table" then
            self.info = newType
        else
            self.info = {
                locType = newType,
                locIndex = newIndex,
                locSlot = newSlot,
                gemType = newGemType,
                gemSlot = newGemSlot,
            }
        end
        local locType = self.info.locType
        local locSlot = locType == "BAG_SOCKET" and self.info.gemSlot or self.info.locSlot
        local txt = ""
        if locType == "EQUIP_SOCKET" or locType == "BAG_SOCKET" then
            txt = "/cast " .. const.EXTRACT_GEM_SPELL
            if locSlot == "Primordial" then
                txt = "/click ExtraActionButton1"
            end
            txt = string.format("%s\n/click ItemSocketingSocket%s", txt, locSlot)
        end
        self:SetAttribute("macrotext", txt)
    end

    return extractButton
end

function uiElements:CreateCheckButton(parent, data)
    local checkButton = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    ---@diagnostic disable-next-line: deprecated
    checkButton:SetPoint(unpack(data.point))
    checkButton.Text:SetFontObject(const.FONT_OBJECTS.NORMAL)
    checkButton.Text:SetPoint("LEFT", checkButton, "RIGHT")
    checkButton.Text:SetText(data.text)
    checkButton.tooltip = data.tooltip
    checkButton:HookScript("OnClick", data.onClick)
    local check = checkButton:CreateTexture()
    local checkDisable = checkButton:CreateTexture()
    check:SetAtlas("checkmark-minimal")
    checkDisable:SetAtlas("checkmark-minimal-disabled")
    checkButton:SetDisabledCheckedTexture(checkDisable)
    checkButton:SetCheckedTexture(check)
    checkButton:SetNormalAtlas("checkbox-minimal")
    checkButton:SetPushedAtlas("checkbox-minimal")
    return checkButton
end

function uiElements:HighlightEquipmentSlot(equipmentSlot)
    if not self.highlightFrame then
        local highlightSlot = CreateFrame("Frame", nil, UIParent)
        highlightSlot:SetFrameStrata("TOOLTIP")
        local hsTex = highlightSlot:CreateTexture()
        hsTex:SetAllPoints()
        hsTex:SetAtlas("CosmeticIconFrame")
        self.highlightFrame = highlightSlot
    end
    local eqSlotName = const.SOCKET_EQUIPMENT_SLOTS_FRAMES[equipmentSlot]
    local eqSlot = _G[eqSlotName]
    if not eqSlot then return end
    self.highlightFrame:Show()
    self.highlightFrame:ClearAllPoints()
    self.highlightFrame:SetAllPoints(eqSlot)
end

function uiElements:CreateDropdown(parent, data)
    ---@class Dropdown : Frame
    ---@field SetValue fun(self:Dropdown, ...:any)
    ---@field Text FontString
    local dropDown = CreateFrame("Frame", nil, parent, "UIDropDownMenuTemplate")
    dropDown.initializer = data.initializer
    dropDown.selectionCallback = data.selectionCallback
    dropDown.selection = nil
    for _, point in ipairs(data.points) do
        ---@diagnostic disable-next-line: deprecated
        dropDown:SetPoint(unpack(point))
    end

    function dropDown.UpdateSelection(dd, selectionIndex, selectionValue)
        selectionIndex = selectionIndex or 0
        if selectionIndex == dd.selection then return end
        dd.selection = selectionIndex
        UIDropDownMenu_SetSelectedID(dd, selectionIndex + 1)
        CloseDropDownMenus()
        if dd.selectionCallback then
            dd:selectionCallback(selectionValue, selectionIndex)
        end
    end

    dropDown.SetValue = function(selectionValue, selectionIndex)
        ---@class dropdownRow
        ---@field value number
        ---@cast selectionValue dropdownRow
        dropDown:UpdateSelection(selectionIndex, selectionValue.value)
    end

    UIDropDownMenu_Initialize(dropDown, function(...)
        local info = UIDropDownMenu_CreateInfo()
        if dropDown.initializer then
            dropDown:initializer(info, ...)
        end
        if not dropDown.selection then
            dropDown:UpdateSelection(dropDown.selection)
        end
    end)

    function dropDown.SetCallback(dd, name, func)
        dd[name] = func
    end

    return dropDown
end

function uiElements:AddTooltip(parent, tooltipText, isHyperlink)
    parent.tooltipText = tooltipText
    parent.isHyperlink = isHyperlink
    if parent.hasTooltip then return end
    parent:HookScript("OnEnter", function(frame)
        GameTooltip:SetOwner(frame, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:ClearLines()
        if frame.isHyperlink then
            GameTooltip:SetHyperlink(frame.tooltipText)
        else
            GameTooltip:AddLine(frame.tooltipText, const.COLORS.WHITE:GetRGBA())
        end
        GameTooltip:Show()
    end)
    parent:HookScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    parent.hasTooltip = true
end

local function updateCooldown(self)
    if not self:IsVisible() then return end
    local now = GetTime()
    if self.lastUpdate + 0.1 < now then
        local start, duration, modRate
        if self.type == "SPELL" then
            start, duration, _, modRate = GetSpellCooldown(self.infoC)
            local charges = { GetSpellCharges(self.infoC) }
            if charges[1] and charges[1] ~= charges[2] and charges[4] > 60 then
                start, duration, modRate = select(3, unpack(charges))
            end
        elseif self.type == "ITEM" then
            start, duration, modRate = C_Item.GetItemCooldown(self.infoC)
        end
        if not start then return end
        if type(modRate) ~= "number" then
            modRate = 1
        end
        if duration == 0 then
            self.cooldownText:SetText("")
            return
        end
        self.cooldown:SetCooldown(start, duration, modRate)
        self.lastUpdate = now
        if not self.cooldownText:IsVisible() then return end
        local secondsLeft = start + duration - now
        self.cooldownText:SetText(secondsLeft > 0 and Private.TimeFormatter:Format(secondsLeft) or "")
    end
end

local function iconHoverEnter(self)
    self.cooldownText:Show()
end
local function iconHoverLeave(self)
    self.cooldownText:Hide()
end

local function getBagSlotString(itemID)
    local bagSlotString, bagIndex, slotIndex = "", 0, 0
    for bag = BACKPACK_CONTAINER, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local containerItemID = C_Container.GetContainerItemID(bag, slot)
            if containerItemID and containerItemID == itemID then
                return string.format("%d %d", bag, slot), bag, slot
            end
        end
    end
    return bagSlotString, bagIndex, slotIndex
end

local function updateSpellCount(self)
    if not self:IsVisible() then return end
    local charges, maxCharges = GetSpellCharges(self.id)
    if not charges then maxCharges = 0 end
    self.count:SetText(maxCharges > 1 and charges or "")
end
local function updateItemCountOrSlot(self, event)
    if not self:IsVisible() then return end
    if not event or event == "ITEM_COUNT_CHANGED" then
        local count = C_Item.GetItemCount(self.id)
        self.count:SetText((not self.hideCount and count > 1) and count or "")
        self.icon:SetDesaturated(count < 1)
    elseif event and event == "BAG_UPDATE_DELAYED" and self.isClickable then
        local bagSlotString, bag, slot = getBagSlotString(self.id)
        self:SetAttribute("macrotext", "/use " .. bagSlotString)
        local gemType = const.GEM_SOCKET_TYPE[self.id]
        self.info = {
            locIndex = bag,
            locSlot = slot,
            gemType = gemType,
            locType = gemType and "BAG_GEM" or "",
        }
    end
end

---@class IconSettings
---@field width number?
---@field height number?
---@field points table?
---@field isClickable boolean?
---@field actionType "SPELL"|"ITEM"?
---@field actionID number?
---@field count number?

---@param parent Frame
---@param data IconSettings
function uiElements:CreateIcon(parent, data)
    data.width         = data.width or 40
    data.height        = data.height or 40
    ---@class IconButton:Button,BackdropTemplate
    local button       = CreateFrame("Button", nil, parent, "InsecureActionButtonTemplate,BackdropTemplate")
    local textFrame    = CreateFrame("Frame", nil, button)
    local icon         = button:CreateTexture(nil, "BACKGROUND")
    local mask         = button:CreateMaskTexture(nil, "BACKGROUND")
    local count        = textFrame:CreateFontString()
    local cooldown     = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    local cooldownText = textFrame:CreateFontString()

    button:SetBackdrop({ edgeFile = "interface/buttons/white8x8.blp" })
    button:SetBackdropBorderColor(0, 0, 0)

    textFrame:SetAllPoints()
    textFrame:SetFrameStrata("HIGH")

    cooldownText:SetPoint("BOTTOM")
    cooldownText:SetFont(const.MEDIA.FONTS.DEFAULT, 9, "OUTLINE")
    cooldownText:Hide()

    cooldown:SetAllPoints()
    cooldown:SetHideCountdownNumbers(true)
    cooldown:SetDrawEdge(false)

    count:SetAllPoints()
    count:SetFont(const.MEDIA.FONTS.DEFAULT, 11, "OUTLINE")
    count:SetText(tostring(data.count))

    mask:SetAllPoints(icon)
    mask:SetAtlas("UI-Frame-IconMask")

    icon:AddMaskTexture(mask)
    button:SetSize(data.width, data.height)
    if data.points then
        for _, point in ipairs(data.points) do
            button:SetPoint(unpack(point))
        end
    end

    button.cooldown = cooldown
    button.cooldownText = cooldownText
    button.count = count
    button.icon = icon
    button.lastUpdate = 0

    function button:UpdateClickable(isClickable, actionType, actionID, noExtract, hyperLink)
        self:UnregisterAllEvents()
        self:SetScript("OnEvent", nil)
        self:SetScript("PreClick", nil)
        self:SetScript("PostClick", nil)
        if actionType == "SPELL" then
            actionID = FindBaseSpellByID(actionID)
        end
        self.isClickable = isClickable
        self.type = actionType
        self.id = actionID
        self.infoC = actionID
        self.hideCount = hyperLink and true or false
        self.info = nil
        if isClickable and actionType then
            self:RegisterForClicks("AnyUp", "AnyDown")
            self:SetAttribute("type", actionType == "SPELL" and "spell" or "macro")
        end
        if not actionID then
            icon:SetAtlas("bags-item-slot64")
        end
        

        if actionType == "SPELL" then
            icon:SetTexture(GetSpellTexture(actionID))
            icon:SetDesaturated(not IsSpellKnown(actionID))
            if data.isClickable then
                self:SetAttribute("spell", actionID)
            end
            Private.Cache:GetSpellInfo(actionID, function(spellInfo)
                uiElements:AddTooltip(self, spellInfo.link, true)
            end)
            self:RegisterEvent("SPELL_UPDATE_CHARGES")
            self:SetScript("OnEvent", updateSpellCount)
            updateSpellCount(self)
        elseif actionType == "ITEM" then
            icon:SetTexture(select(5, C_Item.GetItemInfoInstant(actionID)))
            Private.Cache:GetItemInfo(actionID, function(itemInfo)
                if hyperLink then
                    uiElements:AddTooltip(self, hyperLink, true)
                    self.infoC = hyperLink
                else
                    uiElements:AddTooltip(self,
                        string.format("%s%s", const.COLORS.GREY:GenerateHexColorMarkup(), itemInfo
                            .description))
                    self.infoC = itemInfo.link
                end
            end)
            self:RegisterEvent("ITEM_COUNT_CHANGED")
            self:RegisterEvent("BAG_UPDATE_DELAYED")
            self:SetScript("OnEvent", updateItemCountOrSlot)
            if not noExtract then
                self:SetScript("PreClick", extractPreClick)
                self:SetScript("PostClick", extractPostClick)
            end
            updateItemCountOrSlot(self)
            updateItemCountOrSlot(self, "BAG_UPDATE_DELAYED")
        end
    end

    button:UpdateClickable(data.isClickable, data.actionType, data.actionID)

    button:SetScript("OnUpdate", updateCooldown)
    button:SetScript("OnEnter", iconHoverEnter)
    button:SetScript("OnLeave", iconHoverLeave)
    button:SetScript("OnHide", function()
        button:EnableMouse(false)
    end)
    button:SetScript("OnShow", function()
        button:EnableMouse(true)
        updateSpellCount(button)
        updateItemCountOrSlot(button)
    end)
    button:SetNormalTexture(icon)
    return button
end

---@class ScrollableAnchorSettings
---@field with_scroll_bar Anchor
---@field without_scroll_bar Anchor

---@class ScrollableSettings
---@field width number?
---@field height number?
---@field element_height number?
---@field extent_calculator fun(dataIndex:number, node:table)?
---@field type "LIST"|"GRID"|?
---@field template string?
---@field elements_per_row number?
---@field element_padding number?
---@field fill_width boolean?
---@field anchors ScrollableAnchorSettings
---@field initializer fun(frame:Frame, data:table)

---@param parent Frame
---@param data ScrollableSettings
function uiElements:CreateScrollable(parent, data)
    parent = parent or UIParent
    data.element_height = data.element_height or 25
    data.type = data.type or "LIST"
    data.template = data.template or "BackdropTemplate"

    ---@class ScrollBoxFrame : Frame
    ---@field GetScrollPercentage fun(self:ScrollBoxFrame)
    ---@field SetScrollPercentage fun(self:ScrollBoxFrame, percentage:number)
    local scrollBox = CreateFrame("Frame", nil, parent, "WowScrollBoxList")
    scrollBox:SetSize(data.width or 100, data.height or 100)

    ---@class ScrollBar : EventFrame
    ---@field SetHideIfUnscrollable fun(self:ScrollBar, hideScrollBar:boolean)
    local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 5, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT")
    scrollBar:SetHideIfUnscrollable(true)

    ---@class ScrollView : Frame
    ---@field SetElementExtentCalculator fun(self:ScrollView, extentCalculator:fun(dataIndex:number, node:table))
    ---@field SetElementExtent fun(self:ScrollView, extent:number)
    ---@field Flush fun(self:ScrollView)
    ---@field SetDataProvider fun(self:ScrollView, dataProvider:table)
    ---@field GetDataProvider fun(self:ScrollView)
    local scrollView = nil
    if data.type == "LIST" then
        scrollView = CreateScrollBoxListLinearView()
        scrollView:SetElementInitializer(data.template, data.initializer)
        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)
    elseif data.type == "GRID" then
        local fillWidth = (parent:GetWidth() - (data.elements_per_row - 1) * data.element_padding) /
            data.elements_per_row
        scrollView = CreateScrollBoxListGridView(data.elements_per_row, 0, 0, 0, 0, data.element_padding,
            data.element_padding);
        scrollView:SetElementInitializer(data.template, function(button, elementData)
            button:SetSize(data.fill_width and fillWidth or data.element_height, data.element_height)
            data.initializer(button, elementData)
        end)
        ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView);
    end
    if data.extent_calculator then
        scrollView:SetElementExtentCalculator(data.extent_calculator)
    else
        scrollView:SetElementExtent(data.element_height)
    end
    -- seems buggy so write my own func for this
    --ScrollUtil.AddManagedScrollBarVisibilityBehavior(scrollBox, scrollBar, options.anchors.with_scroll_bar,
    --options.anchors.without_scroll_bar)
    local function setAnchors(withScrollBar)
        scrollBox:ClearAllPoints()
        for _, anchor in ipairs(withScrollBar and data.anchors.with_scroll_bar or data.anchors.without_scroll_bar) do
            scrollBox:SetPoint(anchor:Get())
        end
    end
    scrollBar:HookScript("OnShow", function()
        setAnchors(true)
    end)
    scrollBar:HookScript("OnHide", function()
        setAnchors()
    end)
    setAnchors()

    function scrollView:UpdateContentData(contentData, keepOldData)
        if not contentData then return end
        if not scrollBox:IsVisible() then return end
        local scrollPercent = scrollBox:GetScrollPercentage()
        local dataProvider = self:GetDataProvider()
        if not dataProvider then
            dataProvider = CreateDataProvider()
            self:SetDataProvider(dataProvider)
        end
        if not keepOldData then
            dataProvider:Flush()
        else
        end
        for _, part in ipairs(contentData) do
            dataProvider:Insert(part)
        end
        scrollBox:SetScrollPercentage(scrollPercent or 1)
    end

    return scrollBox, scrollView, scrollBar
end

---@class BaseFrameSettings
---@field width number?
---@field height number?
---@field points table?
---@field title string?
---@field showPortrait boolean?
---@field frameStyle "Flat"|"Default"|"DefaultBase"|?
---@field isClosable boolean?
---@field frameStrata FrameStrata?

local frameStyles = {
    Flat = "PortraitFrameFlatTemplate",
    Default = "ButtonFrameTemplate",
    DefaultBase = "ButtonFrameBaseTemplate"
}

---@param parent Frame
---@param data BaseFrameSettings
function uiElements:CreateBaseFrame(parent, data)
    local template = frameStyles[data.frameStyle or "Default"]
    ---@class BaseFrame : Frame
    ---@field CloseButton Button
    ---@field SetTitle fun(self:BaseFrame, title:string)
    ---@field Inset Frame?
    ---@field TopTileStreaks Frame
    local frame = CreateFrame("Frame", nil, parent, template)
    frame:SetTitle(data.title)
    frame:SetSize(data.width or 100, data.height or 100)
    if data.points then
        for _, point in ipairs(data.points) do
            frame:SetPoint(unpack(point))
        end
    end
    if data.frameStrata then
        frame:SetFrameStrata(data.frameStrata)
    end
    if not data.showPortrait then
        ButtonFrameTemplate_HidePortrait(frame)
    end
    if not data.isClosable then
        frame.CloseButton:Hide()
    end
    if frame.Inset then
        frame.Inset:ClearAllPoints()
        frame.Inset:SetPoint("TOP", 0, -65)
        frame.Inset:SetPoint("BOTTOM", 0, 35)
        frame.Inset:SetPoint("LEFT", 20, 0)
        frame.Inset:SetPoint("RIGHT", -20, 0)
    end

    return frame
end

---@class ButtonFrameSettings
---@field width number?
---@field height number?
---@field points table?
---@field text string?

---@param parent Frame
---@param data ButtonFrameSettings
function uiElements:CreateButton(parent, data)
    local button = CreateFrame("Button", nil, parent, "MagicButtonTemplate")
    button:SetText(data.text)
    button:SetSize(data.width or 100, data.height or 100)
    if data.points then
        for _, point in ipairs(data.points) do
            button:SetPoint(unpack(point))
        end
    end
    return button
end
