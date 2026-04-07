local addonName, lv = ...
local L = lv.L

local function LT(text)
    return (L and L[text] and L[text] ~= text) and L[text] or text
end

function lv.IsMPlusTeleportsEnabled()
    return not (LiteVaultDB and LiteVaultDB.disableMPlusTeleports)
end

local skyreachSpellID = 1254557
if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
    if not C_SpellBook.IsSpellInSpellBook(skyreachSpellID) then
        skyreachSpellID = 159898
    end
elseif IsSpellKnown and not IsSpellKnown(skyreachSpellID) then
    skyreachSpellID = 159898
end

-- Midnight Season 1 M+ dungeon pool.
-- spellID = primary teleport spell learned after completing the dungeon at qualifying keystone level.
-- alternateSpellIDs = fallback spell IDs observed for the same teleport.
lv.TELEPORT_DUNGEONS = {
    { name = "Magisters' Terrace",      spellID = 1254572 },
    { name = "Maisara Caverns",         spellID = 1254559 },
    { name = "Nexus-Point Xenas",       spellID = 1254563 },
    { name = "Windrunner Spire",        spellID = 1254400 },
    { name = "Algethar Academy",        spellID = 393273 },
    { name = "Pit of Saron",            spellID = 1254555 },
    { name = "Seat of the Triumvirate", spellID = 1254551 },
    { name = "Skyreach",                spellID = skyreachSpellID },
}

local function GetDungeonSpellIDs(dungeon)
    local spellIDs = {}
    if dungeon and dungeon.spellID and dungeon.spellID > 0 then
        spellIDs[#spellIDs + 1] = dungeon.spellID
    end
    if dungeon and dungeon.alternateSpellIDs then
        for _, spellID in ipairs(dungeon.alternateSpellIDs) do
            if spellID and spellID > 0 then
                spellIDs[#spellIDs + 1] = spellID
            end
        end
    end
    return spellIDs
end

local function GetKnownTeleportSpellID(dungeon, known)
    for _, spellID in ipairs(GetDungeonSpellIDs(dungeon)) do
        if known then
            if known[spellID] then
                return spellID
            end
        elseif C_SpellBook and C_SpellBook.IsSpellInSpellBook then
            if C_SpellBook.IsSpellInSpellBook(spellID) then
                return spellID
            end
        elseif IsSpellKnown(spellID) then
            return spellID
        end
    end
    return nil
end

-- Scans which teleport spells the current character knows and stores to DB.
-- Called by lv.UpdateCurrentCharData() each login / data refresh.
function lv.ScanTeleports()
    if not LiteVaultDB or not lv.PLAYER_KEY then return end
    local db = LiteVaultDB[lv.PLAYER_KEY]
    if not db then return end

    local known = {}
    for _, dungeon in ipairs(lv.TELEPORT_DUNGEONS) do
        for _, spellID in ipairs(GetDungeonSpellIDs(dungeon)) do
            if C_SpellBook and C_SpellBook.IsSpellInSpellBook then
                known[spellID] = C_SpellBook.IsSpellInSpellBook(spellID) and true or false
            else
                known[spellID] = IsSpellKnown(spellID) and true or false
            end
        end
    end
    db.teleports = known
end

-- Returns count of known teleports for a given char DB entry (for List.lua badge).
function lv.GetTeleportCount(charData)
    if not charData or not charData.teleports then return 0 end
    local count = 0
    for _, dungeon in ipairs(lv.TELEPORT_DUNGEONS) do
        for _, spellID in ipairs(GetDungeonSpellIDs(dungeon)) do
            if charData.teleports[spellID] then
                count = count + 1
                break
            end
        end
    end
    return count
end

local panel = nil
local rows = {}
local combatFrame = CreateFrame("Frame")
local pendingPanelPosition = false
local pendingPanelShow = false
local pendingPanelHide = false

local function GetTeleportAnchorFrame()
    return _G["PVEFrame"] or _G["GroupFinderFrame"]
end

local function PositionTeleportPanel()
    if not panel then return end
    if InCombatLockdown() then
        pendingPanelPosition = true
        return
    end

    pendingPanelPosition = false

    panel:ClearAllPoints()

    local pveFrame = GetTeleportAnchorFrame()
    if pveFrame and pveFrame:IsShown() then
        panel:SetPoint("TOPRIGHT", pveFrame, "TOPLEFT", -6, 0)
    else
        panel:SetPoint("CENTER")
    end
end

local function HideTeleportPanel()
    pendingPanelShow = false

    if not panel then
        pendingPanelHide = false
        return
    end

    if InCombatLockdown() then
        pendingPanelHide = true
        return
    end

    pendingPanelHide = false
    if panel:IsShown() then
        panel:Hide()
    end
end

local function ShowTeleportPanel()
    if not panel then return end
    if InCombatLockdown() then
        pendingPanelShow = true
        pendingPanelHide = false
        return
    end

    pendingPanelShow = false
    pendingPanelHide = false
    panel:Show()
    if lv.UpdateTeleportPanel then
        lv.UpdateTeleportPanel()
    end
end

local function FlushPendingTeleportPanelState()
    if InCombatLockdown() then return end
    if pendingPanelHide then
        HideTeleportPanel()
    end
    if pendingPanelPosition then
        PositionTeleportPanel()
    end
    if pendingPanelShow and lv.IsMPlusTeleportsEnabled() then
        ShowTeleportPanel()
    end
end

local function EnsurePanel()
    if panel then return end

    panel = CreateFrame("Frame", "LiteVaultTeleportPanel", UIParent, "BackdropTemplate")
    panel:SetSize(340, 320)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetToplevel(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:Hide()
    tinsert(UISpecialFrames, "LiteVaultTeleportPanel")

    panel:SetBackdrop({
        bgFile  = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets  = { left=3, right=3, top=3, bottom=3 },
    })

    -- Title
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 14, -12)
    title:SetText(L["TELEPORT_PANEL_TITLE"] or "M+ Teleports")
    lv.ApplyLocaleFont(title, 15)

    -- Close button (top-right, same pattern as InstancePanel)
    local closeBtn = CreateFrame("Button", nil, panel, "BackdropTemplate")
    closeBtn:SetSize(60, 22)
    closeBtn:SetPoint("TOPRIGHT", -10, -10)
    closeBtn:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=12,
        insets={left=3,right=3,top=3,bottom=3} })
    closeBtn.Text = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    closeBtn.Text:SetPoint("CENTER")
    closeBtn.Text:SetText(L["BUTTON_CLOSE"] or "Close")
    closeBtn:SetScript("OnClick", HideTeleportPanel)

    -- Dungeon rows (8 rows, 34px tall each, starting at y=-44)
    for i, dungeon in ipairs(lv.TELEPORT_DUNGEONS) do
        local row = CreateFrame("Frame", nil, panel, "BackdropTemplate")
        row:SetSize(316, 30)
        row:SetPoint("TOPLEFT", 12, -42 - ((i-1) * 34))
        row:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8",
            edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=10,
            insets={left=2,right=2,top=2,bottom=2} })

        -- Dungeon name
        row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.nameText:SetPoint("LEFT", 8, 0)
        row.nameText:SetWidth(160)
        row.nameText:SetText(LT(dungeon.name))
        row.nameText:SetJustifyH("LEFT")
        lv.ApplyLocaleFont(row.nameText, 11)

        -- Cast button
        row.castBtnSkin = CreateFrame("Frame", nil, row, "BackdropTemplate")
        row.castBtnSkin:SetSize(76, 22)
        row.castBtnSkin:SetPoint("RIGHT", -4, 0)
        row.castBtnSkin:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8X8",
            edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=10,
            insets={left=2,right=2,top=2,bottom=2} })

        row.castBtn = CreateFrame("Button", nil, row, "SecureActionButtonTemplate")
        row.castBtn:SetSize(76, 22)
        row.castBtn:SetPoint("RIGHT", -4, 0)
        row.castBtn:SetFrameLevel(row.castBtnSkin:GetFrameLevel() + 1)
        row.castBtn:SetAttribute("type", "spell")
        row.castBtn:SetAttribute("spell", dungeon.spellID)
        row.castBtn.Text = row.castBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.castBtn.Text:SetPoint("CENTER")
        row.castBtn.Text:SetText(L["TELEPORT_CAST_BTN"] or "Teleport")
        lv.ApplyLocaleFont(row.castBtn.Text, 11)
        row.castBtn:RegisterForClicks("AnyUp", "AnyDown")

        row.castBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local spellID = GetKnownTeleportSpellID(dungeon) or dungeon.spellID
            if spellID and spellID > 0 then
                GameTooltip:SetSpellByID(spellID)
            else
                GameTooltip:SetText(LT(dungeon.name))
            end
            GameTooltip:Show()
        end)
        row.castBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row.dungeon = dungeon
        rows[i] = row
    end

    -- Theme registration
    C_Timer.After(0, function()
        if lv.RegisterThemedElement then
            local function applyTheme(f, t)
                f:SetBackdropColor(unpack(t.backgroundSolid or t.background))
                f:SetBackdropBorderColor(unpack(t.borderPrimary))
                closeBtn:SetBackdropColor(unpack(t.buttonBg))
                closeBtn:SetBackdropBorderColor(unpack(t.borderPrimary))
                closeBtn.Text:SetTextColor(unpack(t.textSecondary))
                for _, row in ipairs(rows) do
                    row:SetBackdropColor(unpack(t.backgroundAlt or t.background))
                    row:SetBackdropBorderColor(unpack(t.borderPrimary))
                    row.castBtnSkin:SetBackdropColor(unpack(t.buttonBg))
                    row.castBtnSkin:SetBackdropBorderColor(unpack(t.borderPrimary))
                    row.castBtn.Text:SetTextColor(unpack(t.textSecondary))
                end
            end
            lv.RegisterThemedElement(panel, applyTheme)
            applyTheme(panel, lv.GetTheme())
        end
    end)
end

function lv.UpdateTeleportPanel()
    if not panel or not panel:IsShown() then return end
    if not lv.IsMPlusTeleportsEnabled() then
        HideTeleportPanel()
        return
    end
    local db = LiteVaultDB and lv.PLAYER_KEY and LiteVaultDB[lv.PLAYER_KEY]
    local known = db and db.teleports or {}

    for _, row in ipairs(rows) do
        local knownSpellID = GetKnownTeleportSpellID(row.dungeon, known)
        local isKnown = knownSpellID and true or false

        if isKnown then
            row.castBtn:SetEnabled(true)
            row.castBtn:SetAlpha(1.0)
            row.castBtnSkin:SetAlpha(1.0)
        else
            row.castBtn:SetEnabled(false)
            row.castBtn:SetAlpha(0.4)
            row.castBtnSkin:SetAlpha(0.4)
        end

        -- Disable cast during combat regardless
        if InCombatLockdown() then
            row.castBtn:SetEnabled(false)
            row.castBtn:SetAlpha(0.4)
            row.castBtnSkin:SetAlpha(0.4)
        end
    end
end

function lv.ShowTeleportPanel()
    if not lv.IsMPlusTeleportsEnabled() then
        HideTeleportPanel()
        return
    end
    EnsurePanel()
    PositionTeleportPanel()
    if lv.HideAllActionMenus then lv.HideAllActionMenus() end
    if lv.CloseAuxPanels then lv.CloseAuxPanels("teleports") end
    ShowTeleportPanel()
end

function lv.ToggleTeleportPanel()
    if not lv.IsMPlusTeleportsEnabled() then
        HideTeleportPanel()
        return
    end
    EnsurePanel()
    if panel:IsShown() then
        HideTeleportPanel()
    else
        lv.ShowTeleportPanel()
    end
end

-- Hook WoW Group Finder ("I" key) to show panel alongside it.
-- Try both frame names for compatibility across expansions.
C_Timer.After(1, function()
    local pveFrame = GetTeleportAnchorFrame()
    if pveFrame then
        pveFrame:HookScript("OnShow", function()
            if not lv.IsMPlusTeleportsEnabled() then
                HideTeleportPanel()
                return
            end
            EnsurePanel()
            PositionTeleportPanel()
            ShowTeleportPanel()
        end)
        pveFrame:HookScript("OnHide", function()
            HideTeleportPanel()
        end)
    end
end)

combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" then
        FlushPendingTeleportPanelState()
    end
    lv.UpdateTeleportPanel()
end)

-- Slash command fallback
SLASH_LVTELEPORT1 = "/lvteleport"
SlashCmdList["LVTELEPORT"] = function()
    lv.ToggleTeleportPanel()
end
