local MAJOR, MINOR = "LibEditModeDrawer", 1
local LibStub = _G.LibStub
if not LibStub then
    return
end

local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then
    return
end

lib.drawers = lib.drawers or {}
lib.nextCreateIndex = lib.nextCreateIndex or 0
lib.updateFrame = lib.updateFrame or CreateFrame("Frame")

local STACK_X_OFFSET = 4
local STACK_Y_GAP = 4
local REFLOW_INTERVAL = 0.2

local function NormalizeSortLabel(value)
    if type(value) ~= "string" then
        return ""
    end

    local normalized = value
    normalized = normalized:gsub("|T.-|t", "")
    normalized = normalized:gsub("|A.-|a", "")
    normalized = normalized:gsub("|c%x%x%x%x%x%x%x%x", "")
    normalized = normalized:gsub("|r", "")
    normalized = normalized:gsub("^%s+", ""):gsub("%s+$", "")

    return normalized:lower()
end

local function GetDrawerAnchor(drawer)
    if drawer.secondaryOwner and drawer.secondaryOwner:IsShown() then
        return drawer.secondaryOwner
    end
    return drawer.owner
end

local function IsDrawerVisible(drawer)
    return drawer
        and drawer.frame
        and drawer.frame:IsShown()
        and drawer.hasEntries
        and drawer.owner
        and drawer.owner:IsShown()
end

function lib:ReflowDrawers(anchor)
    if not anchor then
        return
    end

    local visible = {}
    for i = 1, #self.drawers do
        local drawer = self.drawers[i]
        if IsDrawerVisible(drawer) then
            if GetDrawerAnchor(drawer) == anchor then
                visible[#visible + 1] = drawer
            end
        end
    end

    table.sort(visible, function(a, b)
        if a.sortLabel ~= b.sortLabel then
            return a.sortLabel < b.sortLabel
        end
        return a.createIndex < b.createIndex
    end)

    local previous
    for i = 1, #visible do
        local drawer = visible[i]
        drawer.frame:ClearAllPoints()
        if previous then
            drawer.frame:SetPoint("TOPLEFT", previous.frame, "BOTTOMLEFT", 0, -STACK_Y_GAP)
        else
            drawer.frame:SetPoint("TOPLEFT", anchor, "TOPRIGHT", STACK_X_OFFSET, 0)
        end
        previous = drawer
    end
end

function lib:ReflowAllVisibleDrawers()
    local anchors = {}
    local seen = {}

    for i = 1, #self.drawers do
        local drawer = self.drawers[i]
        if IsDrawerVisible(drawer) then
            local anchor = GetDrawerAnchor(drawer)
            if anchor and not seen[anchor] then
                seen[anchor] = true
                anchors[#anchors + 1] = anchor
            end
        end
    end

    for i = 1, #anchors do
        self:ReflowDrawers(anchors[i])
    end
end

local function OnUpdateTicker(_, elapsed)
    lib._elapsed = (lib._elapsed or 0) + elapsed
    if lib._elapsed < REFLOW_INTERVAL then
        return
    end
    lib._elapsed = 0
    lib:ReflowAllVisibleDrawers()
end

function lib:RefreshUpdateLoop()
    local shouldRun = false
    for i = 1, #self.drawers do
        if IsDrawerVisible(self.drawers[i]) then
            shouldRun = true
            break
        end
    end

    if shouldRun then
        if not self._tickerRunning then
            self._tickerRunning = true
            self.updateFrame:SetScript("OnUpdate", OnUpdateTicker)
        end
    elseif self._tickerRunning then
        self._tickerRunning = false
        self._elapsed = 0
        self.updateFrame:SetScript("OnUpdate", nil)
    end
end

local drawerProto = {}

function drawerProto:GetEntries()
    if not self.getEntries then
        return {}
    end
    local entries = self.getEntries()
    if type(entries) ~= "table" then
        return {}
    end
    return entries
end

function drawerProto:RefreshLayout()
    local textWidth = self.checkbox.Label:GetStringWidth()
    self.frame:SetSize(math.max(190, textWidth + 82), 44)
    self.checkbox:SetHitRectInsets(0, -(textWidth + 14), 0, 0)
end

function drawerProto:UpdateCheckboxVisual()
    if self.checkbox:GetChecked() then
        self.checkbox.Fill:SetVertexColor(1, 0.82, 0, 1)
    else
        self.checkbox.Fill:SetVertexColor(0, 0, 0, 1)
    end
    self.checkbox.Label:SetTextColor(1, 1, 1)
end

function drawerProto:RefreshCheckbox()
    local checked = true
    if self.getValue then
        checked = self.getValue()
    end
    self.checkbox:SetChecked(checked and true or false)
    self:UpdateCheckboxVisual()
end

function drawerProto:RefreshVisibility()
    local wasShown = self.frame:IsShown()
    self.hasEntries = #self:GetEntries() > 0
    if not self.hasEntries then
        self.frame:Hide()
        if wasShown then
            lib:ReflowDrawers(GetDrawerAnchor(self))
        end
    end
    lib:RefreshUpdateLoop()
end

function drawerProto:ApplyPosition()
    local frame = self.frame

    if not self.owner or not self.owner:IsShown() then
        frame:Hide()
        lib:RefreshUpdateLoop()
        return
    end

    local anchor = self.owner
    if self.secondaryOwner and self.secondaryOwner:IsShown() then
        anchor = self.secondaryOwner
    end

    frame:Show()
    lib:ReflowDrawers(anchor)
    lib:RefreshUpdateLoop()
end

function drawerProto:EnterEditMode()
    self.owner = EditModeManagerFrame
    if not self.owner then
        self.frame:Hide()
        return
    end

    self.secondaryOwner = EditModeManagerExpandedFrame
    self.frame:SetFrameLevel(self.owner:GetFrameLevel() + 2)

    self:RefreshCheckbox()
    self:RefreshLayout()
    self:RefreshVisibility()
    if self.hasEntries then
        self:ApplyPosition()
    else
        lib:RefreshUpdateLoop()
    end
end

function drawerProto:ExitEditMode()
    local anchor = GetDrawerAnchor(self)
    self.frame:Hide()
    lib:ReflowDrawers(anchor)
    lib:RefreshUpdateLoop()
end

function drawerProto:Refresh()
    self:RefreshCheckbox()
    self:RefreshLayout()
    self:RefreshVisibility()
    if self.frame:IsShown() then
        self:ApplyPosition()
    else
        lib:RefreshUpdateLoop()
    end
end

function lib:CreateDrawer(opts)
    if type(opts) ~= "table" then
        return nil
    end

    local frameName = opts.frameName or (opts.id and (opts.id .. "EditModeDrawer"))
    local frame = CreateFrame("Frame", frameName, UIParent, "BackdropTemplate")
    frame:Hide()
    frame:SetFrameStrata("DIALOG")
    frame:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0, 0, 0, 0.85)
    frame:SetBackdropBorderColor(0, 0, 0, 1)

    local checkbox = CreateFrame("CheckButton", nil, frame)
    checkbox:SetPoint("LEFT", frame, "LEFT", 10, 0)
    checkbox:SetSize(24, 24)
    checkbox:SetNormalTexture("")
    checkbox:SetPushedTexture("")
    checkbox:SetHighlightTexture("")

    local checkboxBG = checkbox:CreateTexture(nil, "BACKGROUND")
    checkboxBG:SetAllPoints()
    checkboxBG:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    checkboxBG:SetVertexColor(0, 0, 0, 1)

    local checkboxFill = checkbox:CreateTexture(nil, "ARTWORK")
    checkboxFill:SetPoint("TOPLEFT", checkbox, "TOPLEFT", 2, -2)
    checkboxFill:SetPoint("BOTTOMRIGHT", checkbox, "BOTTOMRIGHT", -2, 2)
    checkboxFill:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    checkboxFill:SetVertexColor(0, 0, 0, 1)

    local checkboxBorder = CreateFrame("Frame", nil, checkbox, "BackdropTemplate")
    checkboxBorder:SetPoint("TOPLEFT", checkbox, "TOPLEFT", -1, 1)
    checkboxBorder:SetPoint("BOTTOMRIGHT", checkbox, "BOTTOMRIGHT", 1, -1)
    checkboxBorder:SetBackdrop({ edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 1 })
    checkboxBorder:SetBackdropBorderColor(0, 0, 0, 1)

    local checkboxLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkboxLabel:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
    checkboxLabel:SetJustifyH("LEFT")
    checkboxLabel:SetText(opts.label or "Addon")
    checkboxLabel:SetTextColor(1, 1, 1)

    checkbox.Fill = checkboxFill
    checkbox.Label = checkboxLabel

    local drawer = {
        frame = frame,
        checkbox = checkbox,
        getEntries = opts.getEntries,
        getValue = opts.getValue,
        setValue = opts.setValue,
        onToggle = opts.onToggle,
        tooltipHeader = opts.tooltipHeader or "Toggle Addon UI",
        tooltipDescriptionTemplate = opts.tooltipDescriptionTemplate or "Show the following %s UI in Edit Mode:\n\n%s\n\nThis checkbox only controls their visibility in Edit Mode. It will not enable or disable these modules.",
        tooltipProductName = opts.tooltipProductName or (opts.label or "Addon"),
        owner = nil,
        secondaryOwner = nil,
        hasEntries = false,
        sortLabel = NormalizeSortLabel(opts.label),
        createIndex = 0,
    }

    setmetatable(drawer, { __index = drawerProto })

    lib.nextCreateIndex = lib.nextCreateIndex + 1
    drawer.createIndex = lib.nextCreateIndex
    lib.drawers[#lib.drawers + 1] = drawer

    checkbox:SetScript("OnClick", function(self)
        local checked = self:GetChecked() and true or false
        drawer:UpdateCheckboxVisual()
        if drawer.setValue then
            drawer.setValue(checked)
        end
        if drawer.onToggle then
            drawer.onToggle(checked)
        end
        drawer:Refresh()
    end)

    checkbox:SetScript("OnEnter", function(self)
        local entries = drawer:GetEntries()
        if #entries == 0 then
            return
        end

        local bulletList = "- " .. table.concat(entries, "\n- ")

        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(drawer.tooltipHeader, 1, 1, 1)
        GameTooltip:AddLine(string.format(drawer.tooltipDescriptionTemplate, drawer.tooltipProductName, bulletList), 1, 0.82, 0, true)
        GameTooltip:Show()
    end)

    checkbox:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    return drawer
end
