---@class RemixGemHelperPrivate
local Private = select(2, ...)
local const = Private.constants
local gemUtil = Private.GemUtil
local misc = Private.Misc

local uiElements = {}
Private.UIElements = uiElements
local function extractPreClick(self)
    if not misc:IsAllowedForClick("EXTRACT_PRECLICK") then return end
    if not self.info then return end
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
    if not misc:IsAllowedForClick("EXTRACT_POSTCLICK") then return end
    if not self.info then return end
    local info = self.info
    if info.locType == "BAG_GEM" then
        ClearCursor()
        if not info.freeSlot then
            misc:PrintError("你沒有能夠插這顆寶石的空插槽")
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
    dropDown.SetValue = function (selectionValue, selectionIndex)
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