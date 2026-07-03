local Name, AddOnesTable = ...
local VCH = AddOnesTable.VCH
local D = AddOnesTable.D
local P = AddOnesTable.P

local frame = CreateFrame("Frame", "VoidcoreHelperFrame", UIParent)
tinsert(UISpecialFrames, frame:GetName())

frame:SetSize(500, 300)
local framePos = D:ReadDB('Pos', {
    'CENTER', 'CENTER', 0, 0
}, true)
frame:SetPoint(framePos[1], UIParent, framePos[2], framePos[3], framePos[4])
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint()
    D:SaveDB('Pos', { point, relativePoint, offsetX, offsetY }, true)
end)

-- 创建一个边框
frame.border = frame.border or frame:CreateTexture(nil, "BACKGROUND", nil, 1)
frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -5, 5)
frame.border:SetSize(frame:GetWidth() + 10, frame:GetHeight() + 10) -- 设置边框比背景稍大
frame.border:SetColorTexture(19 / 255, 18 / 255, 54 / 255, 0.5)     -- 设置边框颜色为灰色（RGBA）

-- 创建一个背景纹理并设置为黑色
frame.background = frame.background or frame:CreateTexture(nil, "BACKGROUND", nil, 2)
frame.background:SetAllPoints(frame)           -- 设置背景纹理填满整个框
frame.background:SetColorTexture(0, 0, 0, 0.7) -- 设置背景颜色为黑色（RGBA）

-- 关闭按钮
frame.closeBtn = frame.closeBtn or CreateFrame("Button", nil, frame, "VCHButton")
frame.closeBtn:SetPoint("TOPRIGHT", -5, -5)
frame.closeBtn:SetSize(30, 30)
frame.closeBtn:SetScript("OnClick", function() frame:Hide() end)
frame.closeBtn.icon = frame.closeBtn.icon or frame.closeBtn:CreateTexture(nil, "BACKGROUND")
frame.closeBtn.icon:SetAllPoints()
frame.closeBtn.icon:SetColorTexture(0, 0, 0, 0)
frame.closeBtn:SetText("X")
frame.closeBtn.Text:SetTextColor(1, 1, 1)

-- 标题
frame.title = frame.title or frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
frame.title:SetPoint("TOP", 0, -15)
frame.title:SetText("VoidcoreHelper")

frame.labelFrame = frame.labelFrame or CreateFrame("Frame", nil, frame)
frame.labelFrame:SetPoint("TOP", 0, -15)
frame.labelFrame:SetSize(250, 20)
frame.labelFrame:SetMovable(true)
frame.labelFrame:EnableMouse(true)
frame.labelFrame:RegisterForDrag("LeftButton")

frame.labelFrame:SetScript("OnEnter", function(self)
end)
frame.labelFrame:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

frame.labelFrame:SetScript("OnDragStart", function(self)
    self:GetParent():StartMoving()
end)
frame.labelFrame:SetScript("OnDragStop", function(self)
    self:GetParent():StopMovingOrSizing()
end)

-- 小地图按钮图标
frame.UG = frame.UG or CreateFrame("Frame", "", frame)
frame.UG.bg = frame.UG.bg or frame:CreateTexture(nil, "BACKGROUND", nil, 2)
frame.UG.bg:SetAllPoints(frame.UG)
frame.UG.bg:SetAtlas("delves-bountiful")


frame.hunt = frame.hunt or CreateFrame("Frame", "", frame)
frame.hunt.bg = frame.hunt.bg or frame:CreateTexture(nil, "BACKGROUND", nil, 2)
frame.hunt.bg:SetAllPoints(frame.hunt)
-- UI-EventPoi-PreyCrystal UI-EventPoi-Horn-small-corner
frame.hunt.bg:SetAtlas("UI-EventPoi-PreyCrystal")

frame.hunt:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetItemByID(VCH.UG_displayItemIDs[2], nil, 55, 0)
    GameTooltip:Show()
end)
frame.hunt:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

local delves_tier = 11

local dropdown = CreateFrame("Frame", "VCH_dropdown", frame, "UIDropDownMenuTemplate")

UIDropDownMenu_SetWidth(dropdown, 100)
UIDropDownMenu_SetText(dropdown, format(RECENT_ALLY_DELVE_TIER_LABEL, delves_tier))


UIDropDownMenu_Initialize(dropdown, function(self, level)
    for idx = 1, 11 do
        local info = {
            text       = format(RECENT_ALLY_DELVE_TIER_LABEL, idx),
            value      = idx,
            checked    = (idx == delves_tier),
            isNotRadio = false,
            -- minWidth = 140
        }
        info.func = function()
            UIDropDownMenu_SetSelectedValue(dropdown, info.value)
            UIDropDownMenu_SetText(dropdown, info.text)
            delves_tier = info.value
        end
        UIDropDownMenu_AddButton(info)
    end
end)

frame.UG:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetItemByID(VCH.UG_displayItemIDs[1], nil, 108, delves_tier)
    GameTooltip:Show()
end)
frame.UG:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- 地下堡按钮
local delvesFrame = CreateFrame("Frame", "VCH_Delves_Frame", UIParent)

delvesFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetItemByID(VCH.UG_displayItemIDs[1], nil, 108, delves_tier)
    GameTooltip:Show()
end)
delvesFrame:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

delvesFrame:RegisterEvent("ADDON_LOADED")
delvesFrame:RegisterEvent("CVAR_UPDATE")
delvesFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addOnName, containsBindings = ...
        if addOnName == "Blizzard_DelvesDifficultyPicker" then
            if DelvesDifficultyPickerFrame then
                DelvesDifficultyPickerFrame:HookScript("OnShow", function()
                    delves_tier = DelvesDifficultyPickerFrame:GetSelectedTierInfo().tier
                    local isBountiful = false
                    for _, widgetFrame in UIWidgetManager:EnumerateWidgetsByWidgetTag("delveBountiful") do
                        isBountiful = true
                    end
                    if not isBountiful then return end
                    delvesFrame.bg = delvesFrame.bg or delvesFrame:CreateTexture(nil, "BACKGROUND", nil, 2)
                    delvesFrame.bg:SetAllPoints(delvesFrame)
                    delvesFrame.bg:SetTexture(7658128)
                    local uiScale = UIParent:GetEffectiveScale()
                    delvesFrame:SetSize(25 / uiScale, 25 / uiScale)
                    delvesFrame:SetPoint("TOPLEFT", DelvesDifficultyPickerFrame, "TOPRIGHT", 20, -20)
                    delvesFrame:Show()
                end)
                DelvesDifficultyPickerFrame:HookScript("OnHide", function()
                    delvesFrame:Hide()
                end)
                delvesFrame:UnregisterEvent("ADDON_LOADED")
            end
        end
    end
    if event == "CVAR_UPDATE" then
        local cvarName, value = ...
        if cvarName == "lastSelectedTieredEntranceTier" then
            delves_tier = DelvesDifficultyPickerFrame:GetSelectedTierInfo().tier
        end
    end
end)

-- local lastTime = GetTime()
-- frame:SetScript("OnUpdate", function(self)
--     local now = GetTime()
--     if now - lastTime > 1 and self:IsShown() then
--         lastTime = now
--         local lootData = D:ReadDB("lootData", {})

--         local data = {}
--         for _, displayItemID in pairs(VCH.MG_displayItemIDs) do
--             tinsert(data, lootData[displayItemID .. "_" .. VCH.treasureContextLevel_2])
--         end
--         VCH:InItList(data)
--     end
-- end)

local function InitMinimapButton()
    local MinimapButton = CreateFrame("Button", Name .. "MinimapButton", Minimap)
    -- 设置按钮属性
    MinimapButton:SetSize(25, 25) -- 标准尺寸
    MinimapButton:SetFrameStrata("MEDIUM")
    MinimapButton:SetMovable(true)
    MinimapButton:RegisterForDrag("LeftButton")
    MinimapButton:SetClampedToScreen(true)
    MinimapButton:RegisterForClicks("LeftButtonDown", "RightButtonDown")

    -- 创建图标纹理
    MinimapButton.icon = MinimapButton:CreateTexture(nil, "BACKGROUND")
    MinimapButton.icon:SetAllPoints()
    MinimapButton.icon:SetTexture(7658128)

    -- 点击事件
    MinimapButton:SetScript("OnMouseUp", function(self, button, down)
        -- for itemID = 268000, 270000 do
        --     local name = C_Item.GetItemInfo(itemID)
        --     if name and name:find("晦暗虚空宝箱") then
        --         print(itemID, name)
        --     end
        -- end

        if frame:IsShown() then
            frame:Hide()
        else
            -- VCH:FreshDungeon(VCH.MG_displayItemIDs, VCH.treasureContextLevel_2)

            local uiScale = UIParent:GetEffectiveScale()
            frame.UG:SetPoint("CENTER", frame, "CENTER", -95, 0)
            frame.UG:SetSize(45, 45)

            frame.hunt:SetPoint("CENTER", frame, "CENTER", 95, 0)
            frame.hunt:SetSize(45, 45)

            dropdown:SetPoint("TOP", frame.UG, "BOTTOM", 0, -20)


            frame:Show()
        end
    end)

    -- 拖动开始
    MinimapButton:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    MinimapButton:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, relativeTo, relativePoint, offsetX, offsetY = self:GetPoint()
        relativeTo = relativeTo and relativeTo:GetName() or 'UIParent'
        D:SaveDB('point', { point, relativeTo, relativePoint, offsetX, offsetY }, true)
    end)
    MinimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
        GameTooltip:AddLine(Name)
        GameTooltip:Show()
    end)
    MinimapButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    local point = D:ReadDB('point', {
        "TOP", 'Minimap', "BOTTOM", 0, 0
    }, true)
    local point2, relativeTo, relativePoint, offsetX, offsetY = unpack(point)
    MinimapButton:SetPoint(point2, _G[relativeTo], relativePoint, offsetX, offsetY)
end

InitMinimapButton()

frame.contents = {}

local function getContent(frame)
    local re
    for _, c in ipairs(frame.contents) do
        if not c.isUsed then
            c.isUsed = true
            re = c
            break
        end
    end
    if not re then
        re = CreateFrame("Frame", nil, frame)
        re:Hide()
        re:SetScript("OnEnter", function(self)
            if self.itemName then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                -- |cnIQ4:|Hitem:250256::::::::90:105::16:4:13440:6652:12699:12798:1:28:1279:::::|h[风之心]|h|r
                -- |cnIQ3:|Hitem:250256::::::::90:105::  : :     :    :     :     : :            |h[风之心]|h|r
                GameTooltip:AddLine(self.itemName)
                GameTooltip:AddLine(self.itemLevel)
                GameTooltip:AddLine(self.upper)
                GameTooltip:Show()
            end
        end)
        re:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        re.isUsed = true
        table.insert(frame.contents, re)
    end
    return re
end

frame.points = {}

local function getPoint(frame, fontScale)
    local re
    for _, p in ipairs(frame.points) do
        if not p.isUsed then
            p.isUsed = true
            re = p
            break
        end
    end
    if not re then
        re = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        local font, size, flags = re:GetFont()
        local fontScale = fontScale or 1
        re:SetFont(font, size * fontScale, flags)
        re:Hide()
        re.isUsed = true
        table.insert(frame.points, re)
    end
    return re
end

function VCH:InItList(lootData)
    for _, c in ipairs(frame.contents) do
        c.isUsed = false
        c:Hide()
    end
    for _, p in ipairs(frame.points) do
        p.isUsed = false
        p:Hide()
    end

    local line_count = 4
    local idx = 0
    local curr_content = {}
    for _, data in pairs(lootData) do
        idx = idx + 1
        local content = getContent()
        local w, h = 170, 10
        content:Show()
        tinsert(curr_content, content)

        local p = getPoint(1)
        p:SetText("|cffffff00" .. data.displayName .. "|r")
        p:SetPoint("TOPLEFT", content, "TOPLEFT", 10, 0)
        p:Show()

        for item_idx, item in ipairs(data.item) do
            local p = getPoint()
            local cur_tip = getContent()
            p:SetText(item)
            p:Show()

            cur_tip.itemName = item
            cur_tip.itemLevel = format(ITEM_LEVEL, data.itemLevel)
            cur_tip.upper = data.upper
            local font, size, flags = p:GetFont()
            local p_h = 0
            p_h = -size * item_idx * 1.2 - 20
            p:SetPoint("TOPLEFT", content, "TOPLEFT", 10, p_h)

            cur_tip:SetAllPoints(p)
            cur_tip:Show()
        end

        local next_line = math.ceil(idx / line_count) - 1
        local x = (idx - next_line * line_count - 1) * 200 + 20
        content:SetPoint("TOPLEFT", frame, "TOPLEFT", x, -next_line * 350 - 50)
        content:SetSize(w, h)
    end
end

-- local VoidcoreHelperMiniFrame = CreateFrame("Frame", "VoidcoreHelperMiniFrame", UIParent)
-- local lastTime2 = GetTime()

-- VoidcoreHelperMiniFrame:SetSize(200, 200)
-- VoidcoreHelperMiniFrame.background = VoidcoreHelperMiniFrame.background or
--     VoidcoreHelperMiniFrame:CreateTexture(nil, "BACKGROUND", nil, 2)
-- VoidcoreHelperMiniFrame.background:SetAllPoints(VoidcoreHelperMiniFrame) -- 设置背景纹理填满整个框
-- VoidcoreHelperMiniFrame.background:SetColorTexture(0, 0, 0, 0.7)         -- 设置背景颜色为黑色（RGBA）
-- VoidcoreHelperMiniFrame:Hide()
-- VoidcoreHelperMiniFrame.points = {}
-- VoidcoreHelperMiniFrame.contents = {}
-- VoidcoreHelperMiniFrame:SetScript("OnUpdate", function(self)
--     local now = GetTime()
--     if now - lastTime2 > 0.2 and self:IsShown() then
--         lastTime2 = now

--         for _, p in ipairs(self.points) do
--             p.isUsed = false
--             p:Hide()
--         end
--         for _, c in ipairs(self.contents) do
--             c.isUsed = false
--             c:Hide()
--         end

--         local lootData = D:ReadDB("lootData", {})

--         local data = lootData[self.currSelectId]
--         if not data then return end
--         local max_h = 0
--         local max_w = 0
--         for item_idx, item in ipairs(data.item or {}) do
--             local p = getPoint(self)
--             local cur_tip = getContent(self)
--             p:SetText(item)
--             p:Show()

--             cur_tip.itemName = item
--             cur_tip.itemLevel = format(ITEM_LEVEL, data.itemLevel)
--             cur_tip.upper = data.upper
--             local font, size, flags = p:GetFont()
--             local p_h = 0
--             p_h = size * item_idx * 1.2

--             p:SetPoint("TOPRIGHT", self, "TOPRIGHT", -10, -p_h)
--             local m_h = size * (item_idx + 2) * 1.2
--             if m_h > max_h then max_h = m_h end

--             local w = string.utf8len(data.orgItem[item_idx]) * size + 10
--             if w > max_w then max_w = w end

--             cur_tip:SetAllPoints(p)
--             cur_tip:Show()
--         end
--         self:SetSize(max_w, max_h)
--     end
-- end)

local currDisplayItemID = nil
-- 地下城手册按钮
local pFrame            = CreateFrame("Frame", "VCH_P_Frame", UIParent)

VCH.add10               = true

local specName, specIcon
local function currSpec()
    local specId = GetLootSpecialization()
    if specId == 0 then
        local specIdx = GetSpecialization()
        local _, currentSpecName, _, icon = GetSpecializationInfo(specIdx)
        specName = currentSpecName
        specIcon = icon
    else
        local _, name, _, icon = GetSpecializationInfoByID(specId)
        specName = name
        specIcon = icon
    end
end

local function freshTip()
    local fresh = VCH.MG_displayItemIDs[1315]
    if fresh == currDisplayItemID then
        fresh = VCH.MG_displayItemIDs[1299]
    end
    GameTooltip:SetItemByID(fresh)
    GameTooltip:Hide()
end

local function InitPoint(displayItemID, itemContext, isRaid)
    pFrame.bg = pFrame.bg or pFrame:CreateTexture(nil, "BACKGROUND", nil, 2)
    pFrame.bg:SetAllPoints(pFrame)
    pFrame.bg:SetTexture(7658128)
    local uiScale = UIParent:GetEffectiveScale()
    pFrame:SetSize(25 / uiScale, 25 / uiScale)
    pFrame:SetPoint("TOPLEFT", EncounterJournal, "TOPRIGHT", 20, -20)
    if EncounterJournal:IsShown() then
        pFrame:Show()
    end

    pFrame.chickBtn1 = pFrame.chickBtn1 or CreateFrame("CheckButton", "", pFrame, "UICheckButtonTemplate")
    pFrame.chickBtn2 = pFrame.chickBtn2 or CreateFrame("CheckButton", "", pFrame, "UICheckButtonTemplate")

    pFrame.chickBtn1.Text:SetText("10+")
    pFrame.chickBtn2.Text:SetText("<10")
    pFrame.chickBtn1:SetPoint("TOPLEFT", pFrame, "TOPRIGHT", 10 / uiScale, 0)
    pFrame.chickBtn2:SetPoint("TOPLEFT", pFrame, "TOPRIGHT", 10 / uiScale, -20 / uiScale)

    if isRaid then
        pFrame.chickBtn1:Hide()
        pFrame.chickBtn2:Hide()
    else
        pFrame.chickBtn1:Show()
        pFrame.chickBtn2:Show()
    end

    if VCH.add10 then
        pFrame.chickBtn1:SetChecked(true)
        pFrame.chickBtn2:SetChecked(false)
    else
        pFrame.chickBtn1:SetChecked(false)
        pFrame.chickBtn2:SetChecked(true)
    end



    pFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(displayItemID, nil, itemContext,
            isRaid and VCH.MR_upper[displayItemID] or (VCH.add10 and 10 or 2))
        currDisplayItemID = displayItemID
        GameTooltip:Show()
    end)
    pFrame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    pFrame.chickBtn1:SetScript('OnClick', function(self, ...)
        VCH.add10 = true
        if VCH.add10 then
            pFrame.chickBtn1:SetChecked(true)
            pFrame.chickBtn2:SetChecked(false)
        else
            pFrame.chickBtn1:SetChecked(false)
            pFrame.chickBtn2:SetChecked(true)
        end
    end)
    pFrame.chickBtn2:SetScript('OnClick', function(self, ...)
        VCH.add10 = false
        if VCH.add10 then
            pFrame.chickBtn1:SetChecked(true)
            pFrame.chickBtn2:SetChecked(false)
        else
            pFrame.chickBtn1:SetChecked(false)
            pFrame.chickBtn2:SetChecked(true)
        end
    end)
end

local Difficulty = {
    [17] = 4,
    [14] = 3,
    [15] = 5,
    [16] = 6,
}

pFrame:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
pFrame:RegisterEvent("ADDON_LOADED")
pFrame:RegisterEvent("PLAYER_LOGIN")
pFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
pFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOOT_SPEC_UPDATED" then
        freshTip()
        currSpec()
    end
    if event == "PLAYER_SPECIALIZATION_CHANGED" then
        local unitTarget = ...
        if UnitIsUnit(unitTarget, "player") then
            freshTip()
            currSpec()
        end
    end
    if event == "ADDON_LOADED" then
        local addOnName = ...
        if addOnName == "Blizzard_EncounterJournal" then
            if not VCH.loadFinish then
                VCH:LoadFrame()
            end
            if not VCH.loadRaidFinish then
                VCH:LoadRaidFrame()
            end
            VCH:LoadLootList()
            self:UnregisterEvent("ADDON_LOADED")
        end
    end
    if event == "PLAYER_LOGIN" then
        currSpec()

        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
            if data and data.id then
                local isShow = false
                for k, displayItemID in pairs(VCH.MG_displayItemIDs) do
                    if displayItemID == data.id then
                        isShow = true
                        break
                    end
                end
                for k, displayItemID in pairs(VCH.MR_displayItemIDs) do
                    if displayItemID == data.id then
                        isShow = true
                        break
                    end
                end
                for k, displayItemID in pairs(VCH.UG_displayItemIDs) do
                    if displayItemID == data.id then
                        isShow = true
                        break
                    end
                end
                if isShow then
                    currSpec()
                    if specName and specName ~= "" then
                        tooltip:AddLine(specName)
                        tooltip:AddTexture(specIcon, { width = 32, height = 32 })
                    end


                    local content = data.lines
                    local itemString = "^-%s(.*)"


                    local currLootData = {}

                    for i, tooltipDataLine in ipairs(content) do
                        local text = tooltipDataLine.leftText
                        local item_text = strmatch(text, itemString)
                        if item_text then
                            tinsert(currLootData, item_text)
                        end
                    end
                    local Lootcache = D:ReadDB("Lootcache", {})
                    Lootcache[data.id] = Lootcache[data.id] or {}
                    Lootcache[data.id][specIcon] = currLootData
                end
            end
        end)
    end
end)

-- hooksecurefunc("EncounterJournal_LoadUI", function()
--     if not VCH.loadFinish then
--         VCH:LoadFrame()
--     end
--     if not VCH.loadRaidFinish then
--         VCH:LoadRaidFrame()
--     end
-- end)
-- 狩猎按钮
local gFrame = CreateFrame("Frame", "VCH_G_Frame", UIParent)
gFrame.bg = gFrame.bg or gFrame:CreateTexture(nil, "BACKGROUND", nil, 2)
gFrame.bg:SetAllPoints(gFrame)
gFrame.bg:SetTexture(7658128)

gFrame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetItemByID(VCH.UG_displayItemIDs[2], nil, 55, 0)
    GameTooltip:Show()
end)
gFrame:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)
hooksecurefunc("Garrison_LoadUI", function()
    if CovenantMissionFrame then
        CovenantMissionFrame:HookScript("OnShow", function(self)
            if self.textureKit == "midnight" then
                local uiScale = UIParent:GetEffectiveScale()
                gFrame:SetSize(25 / uiScale, 25 / uiScale)
                gFrame:SetPoint("TOPLEFT", CovenantMissionFrame, "TOPRIGHT", 20, -20)
                gFrame:Show()
            end
        end)
        CovenantMissionFrame:HookScript("OnHide", function()
            gFrame:Hide()
        end)
    end
end)


function VCH:LoadFrame()
    if EncounterJournalEncounterFrameInfo then
        EncounterJournalEncounterFrameInfo:HookScript("OnShow", function()
            C_Timer.After(0, function()
                local displayItemID = VCH.MG_displayItemIDs[EncounterJournal.instanceID]
                if displayItemID then
                    InitPoint(displayItemID, 16)
                end

                -- raid
                local displayItemID = VCH.MR_displayItemIDs[EncounterJournal.encounterID]
                if displayItemID then
                    InitPoint(displayItemID, Difficulty[EJ_GetDifficulty()], true)
                end
            end)
        end)
        EncounterJournalEncounterFrameInfo:HookScript("OnHide", function()
            pFrame:Hide()
        end)
        VCH.loadFinish = true
    end
end

function VCH:LoadRaidFrame()
    if EJ_SelectEncounter then
        EJ_SetDifficulty(16)
        hooksecurefunc("EJ_SelectEncounter", function(encounterID)
            local displayItemID = VCH.MR_displayItemIDs[encounterID]
            if displayItemID then
                InitPoint(displayItemID, Difficulty[EJ_GetDifficulty()], true)
            end
        end)
        VCH.loadRaidFinish = true
    end
end

-- GameTooltip:HookScript("OnShow", function(self)
--     print(self:GetOwner().Display.SubTypeIcon:GetAtlas())
-- end)

function VCH:LoadLootList()
    local lootEventFrame = CreateFrame("Frame", nil, UIParent)
    local preTime = GetTime()
    lootEventFrame:SetScript("OnUpdate", function()
        if GetTime() - preTime > (1 / 60) then
            preTime = GetTime()
            local success, lootFrames = pcall(function()
                return EncounterJournal.encounter.info.LootContainer.ScrollBox:GetFrames()
            end)
            if success then
                local Lootcache = D:ReadDB("Lootcache", {})

                for _, lootFrame in ipairs(lootFrames) do
                    if lootFrame.VCH_ICON then
                        lootFrame.VCH_ICON:Hide()
                    end
                end

                local displayItemID = VCH.MG_displayItemIDs[EncounterJournal.instanceID] or
                    VCH.MR_displayItemIDs[EncounterJournal.encounterID]
                if displayItemID then
                    Lootcache[displayItemID] = Lootcache[displayItemID] or {}
                    local lootData = Lootcache[displayItemID][specIcon] or {}

                    for _, lootFrame in ipairs(lootFrames) do
                        if lootFrame.itemID then
                            local itemName = C_Item.GetItemInfo(lootFrame.itemID)
                            for _, voidCoreLootName in ipairs(lootData) do
                                if voidCoreLootName == itemName then
                                    if not lootFrame.VCH_ICON then
                                        lootFrame.VCH_ICON = lootFrame.VCH_ICON or CreateFrame("Frame", nil, lootFrame)
                                        lootFrame.VCH_ICON.bg = lootFrame.VCH_ICON.bg or
                                            lootFrame.VCH_ICON:CreateTexture(nil, "BACKGROUND", nil, 1)
                                        lootFrame.VCH_ICON.bg:SetAllPoints(lootFrame.VCH_ICON)
                                        lootFrame.VCH_ICON.bg:SetTexture(7658128)
                                        lootFrame.VCH_ICON:SetSize(12, 12)
                                        lootFrame.VCH_ICON:SetPoint("TOPRIGHT", lootFrame, -3, -3)
                                        lootFrame.VCH_ICON:SetAlpha(0.618)
                                    end
                                    lootFrame.VCH_ICON:Show()
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
