local _, lv = ...
local L = lv.L

local FRAME_MIN_WIDTH = 360
local FRAME_HEIGHT = 98
local DEFAULT_POSITION = {
    point = "CENTER",
    relativePoint = "CENTER",
    x = 0,
    y = 160,
}

local miniFrame
local miniViewRegistered = false
local lastFolioState
local lastFolioReason

local VALID_POINTS = {
    TOPLEFT = true,
    TOP = true,
    TOPRIGHT = true,
    LEFT = true,
    CENTER = true,
    RIGHT = true,
    BOTTOMLEFT = true,
    BOTTOM = true,
    BOTTOMRIGHT = true,
}

local function Text(key, fallback)
    local value = L and L[key]
    if value and value ~= "" and value ~= key then
        return value
    end
    local enUS = lv.LocaleData and lv.LocaleData["enUS"]
    value = enUS and enUS[key]
    if value and value ~= "" then
        return value
    end
    return fallback or key
end

local function EnsureMiniFolioDB()
    LiteVaultDB = LiteVaultDB or {}
    if LiteVaultDB.miniFolioLocked == nil then
        LiteVaultDB.miniFolioLocked = false
    end
    return LiteVaultDB
end

local function GetSavedPosition()
    local db = EnsureMiniFolioDB()
    local pos = db.miniFolioPosition
    if type(pos) ~= "table" then
        return DEFAULT_POSITION
    end

    local point = type(pos.point) == "string" and pos.point or DEFAULT_POSITION.point
    local relativePoint = type(pos.relativePoint) == "string" and pos.relativePoint or DEFAULT_POSITION.relativePoint
    local x = tonumber(pos.x)
    local y = tonumber(pos.y)
    if not VALID_POINTS[point] or not VALID_POINTS[relativePoint] or not x or not y then
        return DEFAULT_POSITION
    end

    return {
        point = point,
        relativePoint = relativePoint,
        x = x,
        y = y,
    }
end

local function RestoreMiniFolioPosition(frame)
    local pos = GetSavedPosition()
    frame:ClearAllPoints()
    frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
end

local function SaveMiniFolioPosition(frame)
    if not frame then
        return
    end

    local point, _, relativePoint, x, y = frame:GetPoint(1)
    if not VALID_POINTS[point] or not VALID_POINTS[relativePoint] then
        point = DEFAULT_POSITION.point
        relativePoint = DEFAULT_POSITION.relativePoint
        x = DEFAULT_POSITION.x
        y = DEFAULT_POSITION.y
    end

    local db = EnsureMiniFolioDB()
    db.miniFolioPosition = {
        point = point,
        relativePoint = relativePoint,
        x = tonumber(x) or 0,
        y = tonumber(y) or 0,
    }
end

local function StyleMiniControlButton(button, active)
    local theme = lv.GetTheme and lv.GetTheme() or nil
    if not button or not theme then
        return
    end
    local bg = (active and theme.buttonBgActive) or theme.buttonBgAlt or theme.buttonBg
    local border = (active and theme.borderHover) or theme.borderSubdued or theme.borderPrimary
    button:SetBackdropColor(bg[1], bg[2], bg[3], active and 0.45 or 0.18)
    button:SetBackdropBorderColor(border[1], border[2], border[3], active and 0.85 or 0.28)
    if button.Text then
        button.Text:SetTextColor(unpack(active and (theme.textGold or theme.textPrimary) or theme.textPrimary))
    end
end

local function ApplyMiniFolioTheme(frame, theme)
    if not frame or not theme then
        return
    end

    local bg = theme.backgroundSolid or theme.background
    frame:SetBackdropColor(bg[1], bg[2], bg[3], 0.035)
    frame:SetBackdropBorderColor(0, 0, 0, 0)
    if frame.title then
        frame.title:SetTextColor(unpack(theme.textGold or theme.textPrimary))
    end
    if frame.pointsText then
        frame.pointsText:SetTextColor(unpack(theme.textPrimary))
    end
    if frame.emptyText then
        frame.emptyText:SetTextColor(unpack(theme.textSecondary or theme.textPrimary))
    end
    for _, button in ipairs(frame.nodeButtons or {}) do
        if lv.ApplyFolioNodeButtonTheme then
            lv.ApplyFolioNodeButtonTheme(button, theme)
        end
    end
    StyleMiniControlButton(frame.lockButton, LiteVaultDB and LiteVaultDB.miniFolioLocked)
    StyleMiniControlButton(frame.closeButton, false)
    if lv.ApplySharedFolioTheme then
        lv.ApplySharedFolioTheme(theme)
    end
end

local function UpdateMiniFolioLockState()
    if not miniFrame then
        return
    end

    local locked = LiteVaultDB and LiteVaultDB.miniFolioLocked
    miniFrame.lockButton.Text:SetText(locked and "U" or "L")
    StyleMiniControlButton(miniFrame.lockButton, locked)
end

local function SetMiniFolioDraggingEnabled(frame)
    frame:SetScript("OnMouseDown", function(self, button)
        if button ~= "LeftButton" or (LiteVaultDB and LiteVaultDB.miniFolioLocked) then
            return
        end
        self:StartMoving()
        self.isMoving = true
    end)
    frame:SetScript("OnMouseUp", function(self)
        if self.isMoving then
            self:StopMovingOrSizing()
            self.isMoving = false
            SaveMiniFolioPosition(self)
        end
    end)
end

local function EnsureMiniNodeButtons(frame, count)
    frame.nodeButtons = frame.nodeButtons or {}
    if not lv.CreateFolioNodeButton then
        return
    end
    for index = #frame.nodeButtons + 1, count do
        local button = lv.CreateFolioNodeButton(frame.nodesContainer)
        frame.nodeButtons[index] = button
    end
end

local function RefreshMiniFolio(state, reason)
    lastFolioState = state
    lastFolioReason = reason
    if not miniFrame then
        return
    end

    miniFrame.title:SetText((lv.GetFolioLabelText and lv.GetFolioLabelText()) or Text("TITLE_MINI_OMNIUM_FOLIO", "Omnium Folio"))

    if not state then
        miniFrame.pointsText:SetText(string.format(Text("TEXT_FOLIO_AVAILABLE_POINTS_FMT", "Available Points: %d"), 0))
        miniFrame.emptyText:SetText(reason and Text(reason, reason) or Text("TEXT_OMNIUM_FOLIO_UNAVAILABLE", "Omnium Folio is unavailable."))
        miniFrame.emptyText:Show()
        miniFrame.nodesContainer:Hide()
        if lv.HideFolioSelectionChoices then
            lv.HideFolioSelectionChoices(miniFrame)
        end
        ApplyMiniFolioTheme(miniFrame, lv.GetTheme and lv.GetTheme() or nil)
        return
    end

    miniFrame.pointsText:SetText(string.format(Text("TEXT_FOLIO_AVAILABLE_POINTS_FMT", "Available Points: %d"), tonumber(state.availablePoints) or 0))
    miniFrame.emptyText:Hide()
    miniFrame.nodesContainer:Show()

    local nodeSize, nodeGap = 40, 10
    if lv.GetFolioNodeMetrics then
        nodeSize, nodeGap = lv.GetFolioNodeMetrics()
    end
    nodeGap = 10

    EnsureMiniNodeButtons(miniFrame, #state.nodes)
    local totalWidth = (#state.nodes * nodeSize) + (math.max(0, #state.nodes - 1) * nodeGap)
    miniFrame:SetWidth(math.max(FRAME_MIN_WIDTH, totalWidth + 40))
    miniFrame.nodesContainer:SetSize(math.max(nodeSize, totalWidth), nodeSize)

    for index, button in ipairs(miniFrame.nodeButtons or {}) do
        button:ClearAllPoints()
        if index <= #state.nodes then
            button:SetPoint("LEFT", miniFrame.nodesContainer, "LEFT", (index - 1) * (nodeSize + nodeGap), 0)
            if lv.RefreshFolioNodeButton then
                lv.RefreshFolioNodeButton(button, state.nodes[index])
            end
            button:Show()
        else
            button:Hide()
        end
    end

    ApplyMiniFolioTheme(miniFrame, lv.GetTheme and lv.GetTheme() or nil)
end

local function CreateMiniControlButton(parent, text)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(22, 22)
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    button.Text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.Text:SetPoint("CENTER")
    button.Text:SetText(text)
    return button
end

local function EnsureMiniFolioFrame()
    if miniFrame then
        return miniFrame
    end

    local frame = CreateFrame("Frame", "LiteVaultMiniFolioFrame", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_MIN_WIDTH, FRAME_HEIGHT)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("MEDIUM")
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 14, -12)
    frame.title:SetWidth(150)
    frame.title:SetJustifyH("LEFT")

    frame.pointsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.pointsText:SetPoint("TOPRIGHT", -68, -16)
    frame.pointsText:SetWidth(130)
    frame.pointsText:SetJustifyH("RIGHT")

    frame.lockButton = CreateMiniControlButton(frame, "L")
    frame.lockButton:SetPoint("TOPRIGHT", -38, -10)
    frame.lockButton:SetScript("OnClick", function()
        local db = EnsureMiniFolioDB()
        db.miniFolioLocked = not db.miniFolioLocked
        UpdateMiniFolioLockState()
    end)
    frame.lockButton:SetScript("OnEnter", function(self)
        local theme = lv.GetTheme and lv.GetTheme() or nil
        if theme then
            local bg = theme.buttonBgHover or theme.buttonBgAlt or theme.buttonBg
            local border = theme.borderHover or theme.borderPrimary
            self:SetBackdropColor(bg[1], bg[2], bg[3], 0.42)
            self:SetBackdropBorderColor(border[1], border[2], border[3], 0.8)
        end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine((LiteVaultDB and LiteVaultDB.miniFolioLocked)
            and Text("TOOLTIP_UNLOCK_MINI_FOLIO", "Unlock Mini Folio")
            or Text("TOOLTIP_LOCK_MINI_FOLIO", "Lock Mini Folio"))
        GameTooltip:Show()
    end)
    frame.lockButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
        UpdateMiniFolioLockState()
    end)

    frame.closeButton = CreateMiniControlButton(frame, "X")
    frame.closeButton:SetPoint("TOPRIGHT", -14, -10)
    frame.closeButton:SetScript("OnClick", function()
        if lv.SetMiniFolioEnabled then
            lv.SetMiniFolioEnabled(false)
        end
    end)
    frame.closeButton:SetScript("OnEnter", function(self)
        local theme = lv.GetTheme and lv.GetTheme() or nil
        if theme then
            local bg = theme.buttonBgHover or theme.buttonBgAlt or theme.buttonBg
            local border = theme.borderHover or theme.borderPrimary
            self:SetBackdropColor(bg[1], bg[2], bg[3], 0.42)
            self:SetBackdropBorderColor(border[1], border[2], border[3], 0.8)
        end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(Text("TOOLTIP_HIDE_MINI_FOLIO", "Hide Mini Folio"))
        GameTooltip:Show()
    end)
    frame.closeButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
        StyleMiniControlButton(frame.closeButton, false)
    end)

    frame.emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.emptyText:SetPoint("CENTER", frame, "CENTER", 0, -8)
    frame.emptyText:SetPoint("LEFT", 18, 0)
    frame.emptyText:SetPoint("RIGHT", -18, 0)
    frame.emptyText:SetJustifyH("CENTER")
    frame.emptyText:Hide()

    frame.nodesContainer = CreateFrame("Frame", nil, frame)
    frame.nodesContainer:SetPoint("BOTTOM", frame, "BOTTOM", 0, 16)
    frame.nodesContainer:SetSize(40, 40)

    frame:SetScript("OnHide", function(self)
        if lv.HideFolioSelectionChoices then
            lv.HideFolioSelectionChoices(self)
        end
    end)
    SetMiniFolioDraggingEnabled(frame)

    miniFrame = frame
    lv.MiniFolioFrame = frame

    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(frame, function(f, theme)
            ApplyMiniFolioTheme(f, theme)
        end)
    end

    RestoreMiniFolioPosition(frame)
    UpdateMiniFolioLockState()
    ApplyMiniFolioTheme(frame, lv.GetTheme and lv.GetTheme() or nil)
    return frame
end

local function EnsureMiniFolioRegistration()
    if miniViewRegistered or not lv.RegisterFolioView then
        return
    end
    lv.RegisterFolioView(RefreshMiniFolio)
    miniViewRegistered = true
end

function lv.RefreshMiniFolioOption()
    if lv.miniFolioEnabledCB and LiteVaultDB then
        lv.miniFolioEnabledCB:SetChecked(LiteVaultDB.miniFolioEnabled and true or false)
    end
end

function lv.SetMiniFolioEnabled(enabled)
    local db = EnsureMiniFolioDB()
    db.miniFolioEnabled = enabled and true or false

    if db.miniFolioEnabled then
        local frame = EnsureMiniFolioFrame()
        EnsureMiniFolioRegistration()
        RestoreMiniFolioPosition(frame)
        RefreshMiniFolio(lastFolioState or (lv.GetLiveFolioState and lv.GetLiveFolioState()), lastFolioReason)
        frame:Show()
        if lv.RefreshFolioDisplays then
            lv.RefreshFolioDisplays()
        end
        ApplyMiniFolioTheme(frame, lv.GetTheme and lv.GetTheme() or nil)
    elseif miniFrame then
        if lv.HideFolioSelectionChoices then
            lv.HideFolioSelectionChoices(miniFrame)
        end
        miniFrame:Hide()
    end

    if lv.RefreshMiniFolioOption then
        lv.RefreshMiniFolioOption()
    end
end

function lv.RefreshMiniFolio()
    RefreshMiniFolio(lv.GetLiveFolioState and lv.GetLiveFolioState())
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, addonName)
    if event ~= "ADDON_LOADED" or addonName ~= "LiteVault" then
        return
    end

    local function RestoreIfEnabled()
        EnsureMiniFolioDB()
        if LiteVaultDB.miniFolioEnabled then
            lv.SetMiniFolioEnabled(true)
        elseif lv.RefreshMiniFolioOption then
            lv.RefreshMiniFolioOption()
        end
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(0, RestoreIfEnabled)
    else
        RestoreIfEnabled()
    end
end)
