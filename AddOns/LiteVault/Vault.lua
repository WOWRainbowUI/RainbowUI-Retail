local addonName, lv = ...
local L = lv.L

local currentVaultChar = nil

local LVVaultWindow = CreateFrame("Frame", "LiteVaultVaultWindow", UIParent, "BackdropTemplate")
LVVaultWindow:SetSize(560, 308)
LVVaultWindow:SetPoint("CENTER")
LVVaultWindow:SetFrameStrata("DIALOG")
LVVaultWindow:SetMovable(true)
LVVaultWindow:EnableMouse(true)
LVVaultWindow:SetToplevel(true)
LVVaultWindow:RegisterForDrag("LeftButton")
LVVaultWindow:SetScript("OnDragStart", LVVaultWindow.StartMoving)
LVVaultWindow:SetScript("OnDragStop", LVVaultWindow.StopMovingOrSizing)
LVVaultWindow:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
LVVaultWindow:Hide()

lv.LVVaultWindow = LVVaultWindow

C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(LVVaultWindow, function(f, theme)
            f:SetBackdropColor(unpack(theme.backgroundSolid))
            f:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end)
        local t = lv.GetTheme()
        LVVaultWindow:SetBackdropColor(unpack(t.backgroundSolid))
        LVVaultWindow:SetBackdropBorderColor(unpack(t.borderPrimary))
    end
end)

LVVaultWindow.title = LVVaultWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
LVVaultWindow.title:SetPoint("TOPLEFT", 16, -12)

local closeBtn = CreateFrame("Button", nil, LVVaultWindow, "BackdropTemplate")
closeBtn:SetSize(60, 22)
closeBtn:SetPoint("TOPRIGHT", -8, -8)
closeBtn:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
closeBtn.Text = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
closeBtn.Text:SetPoint("CENTER")
closeBtn.Text:SetText((L["BUTTON_CLOSE"] ~= "BUTTON_CLOSE") and L["BUTTON_CLOSE"] or "Close")

C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(closeBtn, function(btn, theme)
            btn:SetBackdropColor(unpack(theme.buttonBgAlt))
            btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
            btn.Text:SetTextColor(unpack(theme.textPrimary))
        end)
        local t = lv.GetTheme()
        closeBtn:SetBackdropColor(unpack(t.buttonBgAlt))
        closeBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
        closeBtn.Text:SetTextColor(unpack(t.textPrimary))
    end
end)

closeBtn:SetScript("OnClick", function()
    LVVaultWindow:Hide()
end)
closeBtn:SetScript("OnEnter", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderHover))
    self:SetBackdropColor(unpack(t.buttonBgHover))
end)
closeBtn:SetScript("OnLeave", function(self)
    local t = lv.GetTheme()
    self:SetBackdropBorderColor(unpack(t.borderPrimary))
    self:SetBackdropColor(unpack(t.buttonBgAlt))
end)

local subtitle = LVVaultWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", LVVaultWindow.title, "BOTTOMLEFT", 0, -6)
subtitle:SetText("")

local summaryBox = CreateFrame("Frame", nil, LVVaultWindow, "BackdropTemplate")
summaryBox:SetSize(528, 40)
summaryBox:SetPoint("TOPLEFT", 16, -48)
summaryBox:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})

summaryBox.label = summaryBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
summaryBox.label:SetPoint("LEFT", 14, 0)
summaryBox.label:SetTextColor(1, 0.82, 0)
summaryBox.label:SetText((L["TITLE_GREAT_VAULT"] ~= "TITLE_GREAT_VAULT") and L["TITLE_GREAT_VAULT"] or "The Great Vault")

summaryBox.value = summaryBox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summaryBox.value:SetPoint("RIGHT", -14, 0)
summaryBox.value:SetJustifyH("RIGHT")

C_Timer.After(0, function()
    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(summaryBox, function(f, theme)
            f:SetBackdropColor(unpack(theme.dataBoxBgAlt or theme.dataBoxBg))
            f:SetBackdropBorderColor(unpack(theme.borderPrimary))
        end)
        local t = lv.GetTheme()
        summaryBox:SetBackdropColor(unpack(t.dataBoxBgAlt or t.dataBoxBg))
        summaryBox:SetBackdropBorderColor(unpack(t.borderPrimary))
    end
end)

local rowDefs = {
    { key = "raid", label = (L["LABEL_VAULT_ROW_RAID"] ~= "LABEL_VAULT_ROW_RAID") and L["LABEL_VAULT_ROW_RAID"] or "Raid", iconAtlas = "Raid" },
    { key = "mythic", label = (L["LABEL_VAULT_ROW_DUNGEONS"] ~= "LABEL_VAULT_ROW_DUNGEONS") and L["LABEL_VAULT_ROW_DUNGEONS"] or "Dungeons", iconAtlas = "Dungeon" },
    { key = "delve", label = (L["LABEL_VAULT_ROW_WORLD"] ~= "LABEL_VAULT_ROW_WORLD") and L["LABEL_VAULT_ROW_WORLD"] or "World", iconAtlas = "delves-regular" },
}

local function BuildEmptySlotEntry()
    return {
        progress = 0,
        threshold = 0,
        unlocked = false,
        rewardText = nil,
        itemLevel = 0,
        highest = 0,
    }
end

local rows = {}
for index, def in ipairs(rowDefs) do
    local row = CreateFrame("Frame", nil, LVVaultWindow, "BackdropTemplate")
    row:SetSize(528, 58)
    row:SetPoint("TOPLEFT", 16, -96 - ((index - 1) * 66))
    row:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })

    row.iconHolder = CreateFrame("Frame", nil, row)
    row.iconHolder:SetSize(42, 42)
    row.iconHolder:SetPoint("LEFT", 10, 0)

    row.iconGlow = row.iconHolder:CreateTexture(nil, "BACKGROUND")
    row.iconGlow:SetSize(28, 28)
    row.iconGlow:SetPoint("CENTER", 0, 0)
    row.iconGlow:SetTexture("Interface\\Buttons\\WHITE8X8")
    row.iconGlow:SetVertexColor(1, 0.82, 0, 0.10)
    row.iconGlowMask = row.iconHolder:CreateMaskTexture()
    row.iconGlowMask:SetAllPoints(row.iconGlow)
    row.iconGlowMask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    row.iconGlow:AddMaskTexture(row.iconGlowMask)

    row.iconBg = row.iconHolder:CreateTexture(nil, "ARTWORK")
    row.iconBg:SetAllPoints()
    if def.backgroundAtlas then
        row.iconBg:SetAtlas(def.backgroundAtlas, true)
        row.iconBg:Show()
    else
        row.iconBg:Hide()
    end

    row.iconHighlight = row.iconHolder:CreateTexture(nil, "OVERLAY")
    row.iconHighlight:SetAllPoints()
    if def.highlightAtlas then
        row.iconHighlight:SetAtlas(def.highlightAtlas, true)
        row.iconHighlight:Show()
    else
        row.iconHighlight:Hide()
    end

    row.icon = row.iconHolder:CreateTexture(nil, "OVERLAY")
    row.icon:SetSize(def.key == "delve" and 34 or 22, def.key == "delve" and 34 or 22)
    row.icon:SetPoint("CENTER", 0, 0)
    row.icon:SetAtlas(def.iconAtlas, true)

    row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    row.label:SetPoint("TOPLEFT", row.iconHolder, "TOPRIGHT", 12, -2)
    row.label:SetText(def.label)
    row.label:SetWidth(120)
    row.label:SetJustifyH("LEFT")

    row.meta = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.meta:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", 0, -5)
    row.meta:SetJustifyH("LEFT")
    row.meta:SetWidth(140)

    row.slotBoxes = {}
    for slot = 1, 3 do
        local box = CreateFrame("Frame", nil, row, "BackdropTemplate")
        box:SetSize(84, 38)
        if slot == 1 then
            box:SetPoint("RIGHT", -194, 0)
        else
            box:SetPoint("LEFT", row.slotBoxes[slot - 1], "RIGHT", 8, 0)
        end
        box:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })

        box.top = box:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        box.top:SetPoint("TOP", 0, -5)
        box.top:SetWidth(72)
        box.top:SetJustifyH("CENTER")

        box.bottom = box:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        box.bottom:SetPoint("BOTTOM", 0, 5)
        box.bottom:SetWidth(72)
        box.bottom:SetJustifyH("CENTER")

        row.slotBoxes[slot] = box
    end

    rows[def.key] = row

    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            lv.RegisterThemedElement(row, function(f, theme)
                f:SetBackdropColor(unpack(theme.dataBoxBg))
                f:SetBackdropBorderColor(unpack(theme.borderPrimary))
                for _, box in ipairs(f.slotBoxes or {}) do
                    box:SetBackdropColor(unpack(theme.dataBoxBgVault or theme.dataBoxBgAlt or theme.dataBoxBg))
                    box:SetBackdropBorderColor(unpack(theme.borderPrimary))
                end
                f.iconGlow:Hide()
            end)
            local t = lv.GetTheme()
            row:SetBackdropColor(unpack(t.dataBoxBg))
            row:SetBackdropBorderColor(unpack(t.borderPrimary))
            for _, box in ipairs(row.slotBoxes) do
                box:SetBackdropColor(unpack(t.dataBoxBgVault or t.dataBoxBgAlt or t.dataBoxBg))
                box:SetBackdropBorderColor(unpack(t.borderPrimary))
            end
            row.defKey = def.key
            row.iconGlow:Hide()
        end
    end)
end

local function BuildRewardText(categoryKey, info)
    local highest = info and info.highest or 0
    local rewardText = info and info.rewardText

    if rewardText and rewardText ~= "" then
        return rewardText
    end

    if categoryKey == "raid" then
        if not highest or highest <= 0 then
            return "-"
        end
        if highest == 17 then
            return "LFR"
        elseif highest == 14 then
            return (L["DIFFICULTY_NORMAL"] ~= "DIFFICULTY_NORMAL") and L["DIFFICULTY_NORMAL"] or "Normal"
        elseif highest == 15 then
            return (L["DIFFICULTY_HEROIC"] ~= "DIFFICULTY_HEROIC") and L["DIFFICULTY_HEROIC"] or "Heroic"
        elseif highest == 16 then
            return (L["DIFFICULTY_MYTHIC"] ~= "DIFFICULTY_MYTHIC") and L["DIFFICULTY_MYTHIC"] or "Mythic"
        end
        return tostring(highest)
    end

    if categoryKey == "mythic" then
        if highest == 0 and (info and (info.threshold or 0) > 0) and (info.progress or 0) >= (info.threshold or 0) then
            return "M0"
        end
        if not highest or highest <= 0 then
            return "-"
        end
        return string.format("+%d", highest)
    end

    if not highest or highest <= 0 then
        return "-"
    end

    return string.format("Tier %d", highest)
end

local function BuildFallbackSnapshotFromSlots(data)
    return {
        raid = { progress = 0, threshold = 0, slots = data and data.vR or 0, highest = 0, rewardText = nil, itemLevel = 0, slotData = { BuildEmptySlotEntry(), BuildEmptySlotEntry(), BuildEmptySlotEntry() } },
        mythic = { progress = 0, threshold = 0, slots = data and data.vM or 0, highest = 0, rewardText = nil, itemLevel = 0, slotData = { BuildEmptySlotEntry(), BuildEmptySlotEntry(), BuildEmptySlotEntry() } },
        delve = { progress = 0, threshold = 0, slots = data and data.vW or 0, highest = 0, rewardText = nil, itemLevel = 0, slotData = { BuildEmptySlotEntry(), BuildEmptySlotEntry(), BuildEmptySlotEntry() } },
    }
end

local function GetVaultSnapshotForCharacter(charKey)
    local data = LiteVaultDB and LiteVaultDB[charKey]
    if charKey == lv.PLAYER_KEY then
        local acts = C_WeeklyRewards.GetActivities and C_WeeklyRewards.GetActivities() or nil
        if acts and lv.BuildVaultSnapshotFromActivities then
            return lv.BuildVaultSnapshotFromActivities(acts), true
        end
    end

    if data and data.vaultDetails then
        return data.vaultDetails, false
    end

    return BuildFallbackSnapshotFromSlots(data), false
end

function lv.UpdateVaultWindow()
    local data = LiteVaultDB and LiteVaultDB[currentVaultChar or lv.PLAYER_KEY]
    local nameOnly = (currentVaultChar or lv.PLAYER_KEY or ""):match("^([^-]+)") or UnitName("player") or "Unknown"
    local cc = C_ClassColor.GetClassColor((data and data.class) or select(2, UnitClass("player")) or "WARRIOR")
    local coloredName = cc and cc:WrapTextInColorCode(nameOnly) or nameOnly
    LVVaultWindow.title:SetText(string.format((((L["TITLE_CHARACTER_GREAT_VAULT_FMT"] ~= "TITLE_CHARACTER_GREAT_VAULT_FMT") and L["TITLE_CHARACTER_GREAT_VAULT_FMT"]) or "%s's %s"), coloredName, ((L["TITLE_GREAT_VAULT"] ~= "TITLE_GREAT_VAULT") and L["TITLE_GREAT_VAULT"] or "The Great Vault")))
    local snapshot, isLive = GetVaultSnapshotForCharacter(currentVaultChar or lv.PLAYER_KEY)
    if currentVaultChar == lv.PLAYER_KEY then
        subtitle:SetText("|cff999999" .. (((L["MSG_VAULT_LIVE_ACTIVE"] ~= "MSG_VAULT_LIVE_ACTIVE") and L["MSG_VAULT_LIVE_ACTIVE"]) or "Live Great Vault progress for the active character.") .. "|r")
    elseif isLive then
        subtitle:SetText("|cff999999" .. (((L["MSG_VAULT_LIVE"] ~= "MSG_VAULT_LIVE") and L["MSG_VAULT_LIVE"]) or "Live Great Vault progress.") .. "|r")
    else
        subtitle:SetText("|cff999999" .. (((L["MSG_VAULT_SAVED"] ~= "MSG_VAULT_SAVED") and L["MSG_VAULT_SAVED"]) or "Saved Great Vault snapshot from this character's last login.") .. "|r")
    end
    local totalSlots = ((snapshot.raid and snapshot.raid.slots) or 0) + ((snapshot.mythic and snapshot.mythic.slots) or 0) + ((snapshot.delve and snapshot.delve.slots) or 0)
    summaryBox.value:SetText(string.format("|cffffd100" .. ((((L["LABEL_VAULT_SLOTS_UNLOCKED"] ~= "LABEL_VAULT_SLOTS_UNLOCKED") and L["LABEL_VAULT_SLOTS_UNLOCKED"]) or "%d/9 slots unlocked")) .. "|r", totalSlots))
    local ordered = {
        { key = "raid", row = rows.raid },
        { key = "mythic", row = rows.mythic },
        { key = "delve", row = rows.delve },
    }

    for _, entry in ipairs(ordered) do
        local info = snapshot[entry.key]
        if not info then
            entry.row.meta:SetText("")
            for slot = 1, 3 do
                local box = entry.row and entry.row.slotBoxes and entry.row.slotBoxes[slot]
                if box then
                    box.top:SetText("")
                    box.bottom:SetText("")
                end
            end
        else
            local threshold = info.threshold or 0
            local progress = math.min(info.progress or 0, threshold)
            if threshold > 0 then
                entry.row.meta:SetText(string.format("|cff999999" .. ((((L["LABEL_VAULT_OVERALL_PROGRESS"] ~= "LABEL_VAULT_OVERALL_PROGRESS") and L["LABEL_VAULT_OVERALL_PROGRESS"]) or "Overall progress: %d/%d")) .. "|r", progress, threshold))
            else
                entry.row.meta:SetText("|cff999999" .. ((((L["MSG_VAULT_NO_THRESHOLD"] ~= "MSG_VAULT_NO_THRESHOLD") and L["MSG_VAULT_NO_THRESHOLD"]) or "No threshold data saved yet.")) .. "|r")
            end

            local slotData = info.slotData or {}
            for slot = 1, 3 do
                local slotInfo = slotData[slot] or BuildEmptySlotEntry()
                local box = entry.row and entry.row.slotBoxes and entry.row.slotBoxes[slot]
                if box then
                    box.top:SetText(BuildRewardText(entry.key, slotInfo))

                    if slotInfo.itemLevel and slotInfo.itemLevel > 0 then
                        box.bottom:SetText(tostring(slotInfo.itemLevel))
                    elseif (slotInfo.threshold or 0) > 0 then
                        box.bottom:SetText(string.format("%d/%d", math.min(slotInfo.progress or 0, slotInfo.threshold or 0), slotInfo.threshold or 0))
                    else
                        box.bottom:SetText("")
                    end
                end
            end
        end
    end
end

function lv.ShowVaultWindow(charKey)
    if not charKey then
        return
    end

    if LVVaultWindow:IsShown() and currentVaultChar == charKey then
        LVVaultWindow:Hide()
        currentVaultChar = nil
        return
    end

    currentVaultChar = charKey
    if charKey == lv.PLAYER_KEY and lv.UpdateCurrentCharData then
        lv.UpdateCurrentCharData()
    end
    LVVaultWindow:Show()
    lv.UpdateVaultWindow()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("WEEKLY_REWARDS_UPDATE")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    if LVVaultWindow:IsShown() then
        lv.UpdateVaultWindow()
    end
end)
