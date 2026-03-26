local addonName, lv = ...

local SLOT_LAYOUT_RIGHT = {"LEFT", "RIGHT", 10, 0}
local SLOT_LAYOUT_LEFT = {"RIGHT", "LEFT", -10, 0}
local SLOT_INSET_POSITIONS = {
    CharacterMainHandSlot = {"TOPRIGHT", "TOPLEFT", -10, 0},
    InspectMainHandSlot = {"TOPRIGHT", "TOPLEFT", -10, 0},
    CharacterSecondaryHandSlot = {"TOPLEFT", "TOPRIGHT", 6, 0},
    InspectSecondaryHandSlot = {"TOPLEFT", "TOPRIGHT", 6, 0},
}

for _, slot in ipairs({ "Head", "Neck", "Shoulder", "Back", "Chest", "Wrist" }) do
    SLOT_INSET_POSITIONS["Character" .. slot .. "Slot"] = SLOT_LAYOUT_RIGHT
    SLOT_INSET_POSITIONS["Inspect" .. slot .. "Slot"] = SLOT_LAYOUT_RIGHT
end

for _, slot in ipairs({ "Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1" }) do
    SLOT_INSET_POSITIONS["Character" .. slot .. "Slot"] = SLOT_LAYOUT_LEFT
    SLOT_INSET_POSITIONS["Inspect" .. slot .. "Slot"] = SLOT_LAYOUT_LEFT
end

local EQUIP_LOC_TO_SLOTS = {
    INVTYPE_HEAD = { 1 },
    INVTYPE_NECK = { 2 },
    INVTYPE_SHOULDER = { 3 },
    INVTYPE_CHEST = { 5 },
    INVTYPE_ROBE = { 5 },
    INVTYPE_WAIST = { 6 },
    INVTYPE_LEGS = { 7 },
    INVTYPE_FEET = { 8 },
    INVTYPE_WRIST = { 9 },
    INVTYPE_HAND = { 10 },
    INVTYPE_FINGER = { 11, 12 },
    INVTYPE_TRINKET = { 13, 14 },
    INVTYPE_CLOAK = { 15 },
    INVTYPE_WEAPONMAINHAND = { 16 },
    INVTYPE_2HWEAPON = { 16 },
    INVTYPE_RANGED = { 16 },
    INVTYPE_RANGEDRIGHT = { 16 },
    INVTYPE_WEAPON = { 16, 17 },
    INVTYPE_SHIELD = { 17 },
    INVTYPE_HOLDABLE = { 17 },
    INVTYPE_WEAPONOFFHAND = { 17 },
}

local PAPERDOLL_GEAR_SLOT_IDS = {
    [1] = true,
    [2] = true,
    [3] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
}

local BUTTON_STATE = setmetatable({}, { __mode = "k" })
local ENABLE_BAG_OVERLAYS = false
local baganatorHooked = false
local litePackHooked = false
local bagnonHooked = false
local hookedBlizzardBagFrames = setmetatable({}, { __mode = "k" })

local function SetLevelFont(fs, variant)
    if variant == "bags" then
        fs:SetFontObject(NumberFontNormal)
        fs:SetShadowOffset(1, -1)
        fs:SetShadowColor(0, 0, 0, 1)
        return
    end
    fs:SetFont("Interface\\AddOns\\LiteVault\\Fonts\\bubble-mint1.otf", 13, "OUTLINE,MONOCHROME")
    fs:SetShadowOffset(1, -1)
    fs:SetShadowColor(0, 0, 0, 1)
end

local function SetIndicatorFont(fs)
    fs:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE,MONOCHROME")
    fs:SetShadowOffset(1, -1)
    fs:SetShadowColor(0, 0, 0, 1)
end

local function PrepareButton(button, variant)
    if not button or BUTTON_STATE[button] then
        if button and BUTTON_STATE[button] then
            BUTTON_STATE[button].variant = variant or BUTTON_STATE[button].variant
        end
        return BUTTON_STATE[button]
    end

    local overlay = CreateFrame("Frame", nil, button)
    overlay:SetAllPoints()
    overlay:SetFrameLevel((button:GetFrameLevel() or 1) + 1)

    local levelText = overlay:CreateFontString(nil, "OVERLAY")
    SetLevelFont(levelText, variant)

    local upgradeText = overlay:CreateFontString(nil, "OVERLAY")
    SetIndicatorFont(upgradeText)
    upgradeText:SetText("+")
    upgradeText:SetTextColor(0.2, 1, 0.2)
    upgradeText:Hide()

    local boundTex = overlay:CreateTexture(nil, "OVERLAY")
    boundTex:SetTexture("Interface\\Buttons\\LockButton-Locked-Up")
    boundTex:SetSize(12, 12)
    boundTex:Hide()

    BUTTON_STATE[button] = {
        overlay = overlay,
        levelText = levelText,
        upgradeText = upgradeText,
        boundTex = boundTex,
        variant = variant,
    }

    return BUTTON_STATE[button]
end

local function LayoutButton(button, state)
    state = state or BUTTON_STATE[button]
    if not state then
        return
    end

    state.levelText:ClearAllPoints()
    state.upgradeText:ClearAllPoints()
    state.boundTex:ClearAllPoints()

    local name = button:GetName()
    local inset = name and SLOT_INSET_POSITIONS[name]
    if inset and (state.variant == "character" or state.variant == "inspect") then
        state.levelText:SetPoint(inset[1], state.overlay, inset[2], inset[3], inset[4])
        state.levelText:SetJustifyH(inset[1] == "LEFT" and "LEFT" or "RIGHT")
    else
        state.levelText:SetPoint("TOPRIGHT", state.overlay, "TOPRIGHT", -2, -2)
        state.levelText:SetJustifyH("RIGHT")
    end

    state.upgradeText:SetPoint("TOPLEFT", state.overlay, "TOPLEFT", 2, -2)
    state.boundTex:SetPoint("BOTTOMLEFT", state.overlay, "BOTTOMLEFT", 1, 1)
end

local function ClearButton(button)
    local state = BUTTON_STATE[button]
    if not state then
        return
    end
    state.levelText:Hide()
    state.upgradeText:Hide()
    state.boundTex:Hide()
end

lv.ClearItemLevelOverlay = ClearButton

function lv.IsCharacterOverlayEnabled()
    -- return not (LiteVaultDB and LiteVaultDB.disableCharacterOverlay)
	return false -- 自行修改
end

local function GetShownItemLevel(link)
    if not link then
        return nil
    end
    local effectiveILvl, isPreview, baseILvl = GetDetailedItemLevelInfo(link)
    return isPreview and baseILvl or effectiveILvl
end

local function GetItemQuality(link)
    if not link then
        return nil
    end
    local quality = select(3, GetItemInfo(link))
    if quality then
        return quality
    end
    local itemID = GetItemInfoInstant(link)
    if itemID and C_Item and C_Item.GetItemQualityByID then
        return C_Item.GetItemQualityByID(itemID)
    end
    return nil
end

local function IsEquippableBagItem(itemID, link)
    if not itemID then
        return false
    end
    local _, _, _, equipLoc, _, classID = C_Item.GetItemInfoInstant(link or itemID)
    if not equipLoc or equipLoc == "" or equipLoc == "INVTYPE_BAG" then
        return false
    end
    return classID == Enum.ItemClass.Weapon or classID == Enum.ItemClass.Armor
end

local function GetEquippedComparisonLevel(slotIDs)
    local best
    for _, slotID in ipairs(slotIDs or {}) do
        local equippedLink = GetInventoryItemLink("player", slotID)
        local equippedLevel = GetShownItemLevel(equippedLink)
        if equippedLevel then
            if not best or equippedLevel < best then
                best = equippedLevel
            end
        end
    end
    return best
end

local function IsUpgradeLink(link, suppressForEquipped)
    if suppressForEquipped or not link then
        return false
    end
    local equipLoc = select(4, GetItemInfoInstant(link))
    local slotIDs = equipLoc and EQUIP_LOC_TO_SLOTS[equipLoc]
    if not slotIDs then
        return false
    end
    local level = GetShownItemLevel(link)
    local equippedLevel = GetEquippedComparisonLevel(slotIDs)
    return level and equippedLevel and level > equippedLevel or false
end

local function IsBoundAtLocation(location)
    if not (location and C_Item and C_Item.IsBound) then
        return false
    end
    if location.IsValid and not location:IsValid() then
        return false
    end
    return C_Item.IsBound(location) or false
end

local function ApplyDisplay(button, info)
    local state = PrepareButton(button, info.variant)
    if not state then
        return
    end
    state.variant = info.variant or state.variant
    SetLevelFont(state.levelText, state.variant)
    LayoutButton(button, state)

    if not info.link then
        ClearButton(button)
        return
    end

    local level = info.level or GetShownItemLevel(info.link)
    if level then
        state.levelText:SetText(math.floor(level))
        local quality = info.quality or GetItemQuality(info.link)
        if quality and C_Item and C_Item.GetItemQualityColor then
            local r, g, b = C_Item.GetItemQualityColor(quality)
            state.levelText:SetTextColor(r, g, b)
        else
            state.levelText:SetTextColor(1, 1, 1)
        end
        state.levelText:Show()
    else
        state.levelText:Hide()
    end

    if info.upgrade then
        state.upgradeText:Show()
    else
        state.upgradeText:Hide()
    end

    if info.bound then
        state.boundTex:Show()
    else
        state.boundTex:Hide()
    end
end

local function UpdateItemButton(button, link, variant, opts)
    if not button then
        return
    end
    if not lv.IsCharacterOverlayEnabled() then
        ClearButton(button)
        return
    end
    if button.liteVaultNoItemLevel then
        ClearButton(button)
        return
    end
    opts = opts or {}
    ApplyDisplay(button, {
        link = link,
        variant = variant,
        level = opts.level,
        quality = opts.quality,
        upgrade = opts.upgrade ~= nil and opts.upgrade or IsUpgradeLink(link, opts.suppressUpgrade),
        bound = opts.bound,
    })
end

local function UpdateCharacterSlotButton(button, unit, variant)
    if not button then
        return
    end
    if not lv.IsCharacterOverlayEnabled() then
        ClearButton(button)
        return
    end
    local slotID = button:GetID()
    if not PAPERDOLL_GEAR_SLOT_IDS[slotID] then
        ClearButton(button)
        return
    end
    local link = slotID and GetInventoryItemLink(unit or "player", slotID)
    UpdateItemButton(button, link, variant or "character", { suppressUpgrade = true })
end

function lv.RefreshCharacterOverlays()
    for button in pairs(BUTTON_STATE) do
        ClearButton(button)
    end

    if not lv.IsCharacterOverlayEnabled() then
        return
    end

    for _, slotName in ipairs({
        "Head", "Neck", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist",
        "Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand", "SecondaryHand",
    }) do
        local characterButton = _G["Character" .. slotName .. "Slot"]
        if characterButton and characterButton:IsShown() then
            UpdateCharacterSlotButton(characterButton, "player", "character")
        end

        local inspectButton = _G["Inspect" .. slotName .. "Slot"]
        if inspectButton and inspectButton:IsShown() then
            UpdateCharacterSlotButton(inspectButton, InspectFrame and InspectFrame.unit or "target", "inspect")
        end
    end

    if EquipmentFlyoutFrame and EquipmentFlyoutFrame.buttons then
        for _, button in ipairs(EquipmentFlyoutFrame.buttons) do
            if button and button:IsShown() then
                local link, bound = ItemFromEquipmentFlyoutDisplayButton(button)
                UpdateItemButton(button, link, "character", { bound = bound })
            end
        end
    end

    if ENABLE_BAG_OVERLAYS then
        RefreshOpenBlizzardBags()
    end
end

local function UpdateContainerButton(button, bag, slot)
    if not button or not bag or not slot then
        return
    end
    if button.itemLevelText and button.litePackBag then
        button.itemLevelText:SetText("")
        button.itemLevelText:Hide()
    end
    local info = C_Container and C_Container.GetContainerItemInfo and C_Container.GetContainerItemInfo(bag, slot)
    local location = ItemLocation and ItemLocation:CreateFromBagAndSlot(bag, slot)
    local item = Item and Item.CreateFromBagAndSlot and Item:CreateFromBagAndSlot(bag, slot)
    local token = tostring(bag) .. ":" .. tostring(slot)
    local itemID = info and info.itemID

    button.liteVaultBagToken = token

    if info and info.stackCount and info.stackCount > 1 then
        ClearButton(button)
        return
    end

    if not IsEquippableBagItem(itemID, info and info.hyperlink) then
        ClearButton(button)
        return
    end

    if item and not item:IsItemEmpty() then
        item:ContinueOnItemLoad(function()
            if not button or button.liteVaultBagToken ~= token then
                return
            end
            local link = item:GetItemLink()
            if not IsEquippableBagItem(itemID or item:GetItemID(), link) then
                ClearButton(button)
                return
            end
            local level = item.GetCurrentItemLevel and item:GetCurrentItemLevel() or nil
            UpdateItemButton(button, link, "bags", {
                quality = item.GetItemQuality and item:GetItemQuality() or (info and info.quality),
                bound = IsBoundAtLocation(location),
                level = level,
            })
        end)
        return
    end

    UpdateItemButton(button, info and info.hyperlink, "bags", {
        quality = info and info.quality,
        bound = IsBoundAtLocation(location),
        level = info and info.hyperlink and GetShownItemLevel(info.hyperlink) or nil,
    })
end

local function RefreshContainerFrame(frame)
    if not frame then
        return
    end
    if not frame.EnumerateValidItems then
        return
    end
    for _, itemButton in frame:EnumerateValidItems() do
        local bag = itemButton.GetBagID and itemButton:GetBagID()
        local slot = itemButton.GetID and itemButton:GetID()
        if bag ~= nil and slot then
            UpdateContainerButton(itemButton, bag, slot)
        else
            ClearButton(itemButton)
        end
    end
end

local function RefreshOpenBlizzardBags()
    if _G.ContainerFrameCombinedBags and ContainerFrameCombinedBags.IsShown and ContainerFrameCombinedBags:IsShown() then
        RefreshContainerFrame(ContainerFrameCombinedBags)
    end
    for _, frame in ipairs((ContainerFrameContainer or UIParent).ContainerFrames or {}) do
        if frame and frame.IsShown and frame:IsShown() then
            RefreshContainerFrame(frame)
        end
    end
end

local function HookDynamicBlizzardBagFrames()
    if _G.ContainerFrameCombinedBags and ContainerFrameCombinedBags.UpdateItems and not hookedBlizzardBagFrames[ContainerFrameCombinedBags] then
        hookedBlizzardBagFrames[ContainerFrameCombinedBags] = true
        hooksecurefunc(ContainerFrameCombinedBags, "UpdateItems", RefreshContainerFrame)
    end

    for _, frame in ipairs((ContainerFrameContainer or UIParent).ContainerFrames or {}) do
        if frame and frame.UpdateItems and not hookedBlizzardBagFrames[frame] then
            hookedBlizzardBagFrames[frame] = true
            hooksecurefunc(frame, "UpdateItems", RefreshContainerFrame)
        end
    end
end

local function ItemFromEquipmentFlyoutDisplayButton(button)
    if not button then
        return nil, nil
    end

    if button.GetItemLocation then
        local itemLocation = button:GetItemLocation()
        if itemLocation and (not itemLocation.IsValid or itemLocation:IsValid()) then
            local link = C_Item and C_Item.GetItemLink and C_Item.GetItemLink(itemLocation)
            return link, IsBoundAtLocation(itemLocation)
        end
    end

    local location = button.location
    if not location then
        return nil, nil
    end
    if EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION and location >= EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION then
        return nil, nil
    end

    if EquipmentManager_GetLocationData then
        local locationData = EquipmentManager_GetLocationData(location)
        if locationData and locationData.isBags then
            local itemLocation = ItemLocation and ItemLocation:CreateFromBagAndSlot(locationData.bag, locationData.slot)
            local link = C_Container and C_Container.GetContainerItemLink and C_Container.GetContainerItemLink(locationData.bag, locationData.slot)
            return link, IsBoundAtLocation(itemLocation)
        end
        if locationData and locationData.isPlayer then
            return GetInventoryItemLink("player", locationData.slot), false
        end
    end

    if EquipmentManager_UnpackLocation then
        local player, bank, bags, voidStorage, slot, bag = EquipmentManager_UnpackLocation(location)
        if type(voidStorage) ~= "boolean" then
            slot, bag = voidStorage, slot
            voidStorage = false
        end
        if bags then
            local itemLocation = ItemLocation and ItemLocation:CreateFromBagAndSlot(bag, slot)
            local link = C_Container and C_Container.GetContainerItemLink and C_Container.GetContainerItemLink(bag, slot)
            return link, IsBoundAtLocation(itemLocation)
        end
        if player and not voidStorage then
            return GetInventoryItemLink("player", slot), false
        end
    end

    return nil, nil
end

local function HookCharacter()
    if _G.PaperDollItemSlotButton_Update then
        hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
            UpdateCharacterSlotButton(button, "player", "character")
        end)
    end
    if _G.CharacterFrame then
        CharacterFrame:HookScript("OnShow", function()
            for _, slotName in ipairs({
                "Head", "Neck", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist",
                "Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand", "SecondaryHand",
            }) do
                local button = _G["Character" .. slotName .. "Slot"]
                if button then
                    UpdateCharacterSlotButton(button, "player", "character")
                end
            end
        end)
    end
end

local function HookInspect()
    if _G.InspectPaperDollItemSlotButton_Update then
        hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(button)
            UpdateCharacterSlotButton(button, InspectFrame and InspectFrame.unit or "target", "inspect")
        end)
    end
end

local function HookFlyout()
    if _G.EquipmentFlyout_UpdateItems then
        hooksecurefunc("EquipmentFlyout_UpdateItems", function()
            if not EquipmentFlyoutFrame or not EquipmentFlyoutFrame.buttons then
                return
            end
            for _, button in ipairs(EquipmentFlyoutFrame.buttons) do
                if button and button:IsShown() then
                    local link, bound = ItemFromEquipmentFlyoutDisplayButton(button)
                    UpdateItemButton(button, link, "character", { bound = bound })
                else
                    ClearButton(button)
                end
            end
        end)
    end
end

local function HookBags()
    if not ENABLE_BAG_OVERLAYS then
        return
    end
    if _G.ContainerFrame_Update then
        hooksecurefunc("ContainerFrame_Update", function(container)
            if not container then
                return
            end
            local bag = container:GetID()
            local name = container:GetName()
            local size = container.size or 0
            for i = 1, size do
                local button = name and _G[name .. "Item" .. i]
                if button then
                    UpdateContainerButton(button, bag, i)
                end
            end
        end)
    end

    if _G.ContainerFrameItemButtonMixin and ContainerFrameItemButtonMixin.Update then
        hooksecurefunc(ContainerFrameItemButtonMixin, "Update", function(button)
            if not button then
                return
            end
            local bag = button.GetBagID and button:GetBagID()
            local slot = button.GetID and button:GetID()
            if bag ~= nil and slot then
                UpdateContainerButton(button, bag, slot)
            else
                ClearButton(button)
            end
        end)
    end

    HookDynamicBlizzardBagFrames()

    if _G.BankFrameItemButton_Update then
        hooksecurefunc("BankFrameItemButton_Update", function(button)
            if not button or button.isBag then
                return
            end
            local parent = button.GetParent and button:GetParent()
            local bag = parent and parent.GetID and parent:GetID()
            local slot = button.GetID and button:GetID()
            if bag and slot then
                UpdateContainerButton(button, bag, slot)
            else
                ClearButton(button)
            end
        end)
    end
end

local function HookLoot()
    if _G.LootFrame_UpdateButton then
        hooksecurefunc("LootFrame_UpdateButton", function(index)
            local button = _G["LootButton" .. index]
            if not button or not button:IsEnabled() or not button.slot then
                ClearButton(button)
                return
            end
            local link = GetLootSlotLink(button.slot)
            UpdateItemButton(button, link, "loot")
        end)
    elseif _G.LootFrame and LootFrame.ScrollBox then
        LootFrame.ScrollBox:RegisterCallback("OnUpdate", function()
            LootFrame.ScrollBox:ForEachFrame(function(frame)
                if not frame or not frame.Item then
                    return
                end
                local data = frame.GetElementData and frame:GetElementData()
                local slotIndex = data and data.slotIndex
                local link = slotIndex and GetLootSlotLink(slotIndex)
                UpdateItemButton(frame.Item, link, "loot")
            end)
        end)
    end
end

local function HookBaganator()
    if not ENABLE_BAG_OVERLAYS then
        return
    end
    if baganatorHooked then
        return
    end
    if not (_G.Baganator and Baganator.API and Baganator.API.RegisterCornerWidget) then
        return
    end
    baganatorHooked = true

    local function makeText(size, color)
        return function(itemButton)
            local text = itemButton:CreateFontString(nil, "OVERLAY")
            text:SetFont("Fonts\\ARIALN.TTF", size, "OUTLINE,MONOCHROME")
            if color then
                text:SetTextColor(color[1], color[2], color[3])
            end
            return text
        end
    end

    local function onUpdate(callback)
        return function(cornerFrame, details)
            if not details.itemLink then
                return false
            end
            local button = cornerFrame:GetParent():GetParent()
            local parent = button and button:GetParent()
            local bag = parent and parent:GetID()
            local slot = button and button:GetID()
            local link = details.itemLink
            local bound
            if bag and slot and slot ~= 0 then
                local itemLocation = ItemLocation and ItemLocation:CreateFromBagAndSlot(bag, slot)
                bound = IsBoundAtLocation(itemLocation)
            end
            return callback(cornerFrame, {
                link = link,
                level = GetShownItemLevel(link),
                quality = GetItemQuality(link),
                upgrade = IsUpgradeLink(link, false),
                bound = bound,
            })
        end
    end

    Baganator.API.RegisterCornerWidget("LiteVault: Item Level", "litevault-ilvl",
        onUpdate(function(cornerFrame, data)
            if not data.level then
                return false
            end
            cornerFrame:SetText(data.level)
            if data.quality and C_Item and C_Item.GetItemQualityColor then
                local r, g, b = C_Item.GetItemQualityColor(data.quality)
                cornerFrame:SetTextColor(r, g, b)
            else
                cornerFrame:SetTextColor(1, 1, 1)
            end
            return true
        end),
        makeText(12), { default_position = "top_right", priority = 1 }
    )

    Baganator.API.RegisterCornerWidget("LiteVault: Upgrade", "litevault-upgrade",
        onUpdate(function(cornerFrame, data)
            if not data.upgrade then
                return false
            end
            cornerFrame:SetText("+")
            cornerFrame:SetTextColor(0.2, 1, 0.2)
            return true
        end),
        makeText(11, { 0.2, 1, 0.2 }), { default_position = "top_left", priority = 1 }
    )

    Baganator.API.RegisterCornerWidget("LiteVault: Bound", "litevault-bound",
        onUpdate(function(cornerFrame, data)
            if not data.bound then
                return false
            end
            cornerFrame:SetText("L")
            cornerFrame:SetTextColor(1, 0.82, 0)
            return true
        end),
        makeText(10, { 1, 0.82, 0 }), { default_position = "bottom_left", priority = 1 }
    )
end

local function HookLitePack()
    if not ENABLE_BAG_OVERLAYS then
        return
    end
    if litePackHooked then
        return
    end
    if not (_G.LitePack and LitePack.Items and LitePack.Items.pool and LitePack.Items.Refresh) then
        return
    end

    litePackHooked = true
    hooksecurefunc(LitePack.Items, "Refresh", function(self)
        for index = 1, (self.activeCount or 0) do
            local button = self.pool and self.pool[index]
            if button and button:IsShown() and button.litePackBag and button.litePackSlot then
                UpdateContainerButton(button, button.litePackBag, button.litePackSlot)
            else
                ClearButton(button)
            end
        end
    end)
end

local function HookBagnonAddon(addon)
    if not (addon and addon.Item and addon.Item.Update) then
        return false
    end

    hooksecurefunc(addon.Item, "Update", function(self)
        local bag = self.GetBag and self:GetBag() or self.bag
        local slot = self.GetID and self:GetID() or nil
        if self and bag ~= nil and slot then
            UpdateContainerButton(self, bag, slot)
        else
            ClearButton(self)
        end
    end)
    return true
end

local function HookBagnon()
    if not ENABLE_BAG_OVERLAYS then
        return
    end
    if bagnonHooked then
        return
    end
    if HookBagnonAddon(_G.Bagnon) or HookBagnonAddon(_G.BagBrother) then
        bagnonHooked = true
    end
end

if ENABLE_BAG_OVERLAYS then
    local bagRefreshEvents = CreateFrame("Frame")
    bagRefreshEvents:RegisterEvent("BAG_UPDATE_DELAYED")
    bagRefreshEvents:RegisterEvent("BANKFRAME_OPENED")
    bagRefreshEvents:SetScript("OnEvent", function()
        HookDynamicBlizzardBagFrames()
        RefreshOpenBlizzardBags()

        if _G.BankFrame and BankFrame.IsShown and BankFrame:IsShown() then
            for index = 1, (NUM_BANKGENERIC_SLOTS or 0) do
                local button = _G["BankFrameItem" .. index]
                if button and button:IsShown() then
                    local parent = button:GetParent()
                    local bag = parent and parent.GetID and parent:GetID()
                    local slot = button:GetID()
                    if bag and slot then
                        UpdateContainerButton(button, bag, slot)
                    end
                end
            end
        end
    end)
end

local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:SetScript("OnEvent", function(_, _, arg1)
    if arg1 == addonName then
        HookCharacter()
        HookFlyout()
        HookBags()
        HookLoot()
        if ENABLE_BAG_OVERLAYS then
            HookBaganator()
            HookLitePack()
            HookBagnon()
        end
        if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Blizzard_InspectUI") then
            HookInspect()
        end
    elseif arg1 == "Blizzard_InspectUI" then
        HookInspect()
    elseif ENABLE_BAG_OVERLAYS and arg1 == "Baganator" then
        HookBaganator()
    elseif ENABLE_BAG_OVERLAYS and arg1 == "LitePack" then
        HookLitePack()
    elseif ENABLE_BAG_OVERLAYS and (arg1 == "Bagnon" or arg1 == "BagBrother") then
        HookBagnon()
    end
end)
