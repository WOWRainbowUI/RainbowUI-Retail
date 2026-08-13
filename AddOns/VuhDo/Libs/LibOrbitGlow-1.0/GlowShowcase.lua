local LCG = LibStub and LibStub("LibOrbitGlow-1.0", true)
if not (LCG and LCG.GetGlowList) then return end
if LCG.Showcase then return end

-- [ GLOW SHOWCASE ] ---------------------------------------------------------------------------------

local SHOW_PALETTE = {
    { 0.95, 0.25, 0.25, 1 }, { 1.00, 0.55, 0.15, 1 }, { 1.00, 0.82, 0.20, 1 }, { 0.40, 0.92, 0.40, 1 },
    { 0.30, 0.85, 1.00, 1 }, { 0.45, 0.55, 1.00, 1 }, { 0.80, 0.45, 1.00, 1 }, { 1.00, 0.45, 0.85, 1 },
}
local lastTintIdx
local function PickTint()
    local idx = math.random(#SHOW_PALETTE)
    if idx == lastTintIdx then idx = idx % #SHOW_PALETTE + 1 end
    lastTintIdx = idx
    return SHOW_PALETTE[idx]
end

local LIB_SOURCE = "LibOrbitGlow"
local ICON, COLS = 38, 10
local CELL_W, CELL_H = ICON + 18, ICON + 24
local HEADER_TOP, MAX_VIEWPORT = 52, 460
local SHOW_KEY, TEST_KEY = "show", "orbitglowtest"
local panel, currentButtonGlow

local function GroupedGlows()
    local buckets, order = {}, {}
    for _, name in ipairs(LCG:GetGlowList()) do
        local info = LCG:GetGlowInfo(name)
        local src = (info and info.source) or "Other"
        if not buckets[src] then buckets[src] = {}; order[#order + 1] = src end
        buckets[src][#buckets[src] + 1] = name
    end
    table.sort(order, function(a, b)
        if (a == LIB_SOURCE) ~= (b == LIB_SOURCE) then return a == LIB_SOURCE end
        return a < b
    end)
    return order, buckets
end

local function PlayCell(cell)
    LCG.Proc:Loop(cell, { glow = cell.glow, shape = "square", key = SHOW_KEY, color = cell.tint, frameLevel = 8 })
end

local function ClearCell(cell)
    LCG.Proc:Clear(cell, { glow = cell.glow, key = SHOW_KEY })
end

local function Reroll()
    if not (panel and panel.sections) then return end
    local tint = PickTint()
    for _, sec in ipairs(panel.sections) do
        if not sec.collapsed then
            for _, cell in ipairs(sec.cells) do cell.tint = tint; PlayCell(cell) end
        end
    end
end

local function ApplyToActionButton(glow)
    local btn = _G.ActionButton1
    if not btn then print("|cffff4444ActionButton1 not found|r"); return end
    LCG.Proc:Clear(btn, { glow = currentButtonGlow, key = TEST_KEY })
    if currentButtonGlow == glow then currentButtonGlow = nil; return end
    currentButtonGlow = glow
    LCG.Proc:Loop(btn, { glow = glow, shape = "square", key = TEST_KEY, color = PickTint(), frameLevel = 8 })
end

local function Relayout()
    if not panel then return end
    local content, y = panel.content, 6
    for _, sec in ipairs(panel.sections) do
        sec.arrow:ClearAllPoints()
        sec.arrow:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -y)
        sec.header:ClearAllPoints()
        sec.header:SetPoint("TOPLEFT", content, "TOPLEFT", 26, -y - 2)
        y = y + 24
        if sec.collapsed then
            for _, cell in ipairs(sec.cells) do cell:Hide() end
        else
            for i, cell in ipairs(sec.cells) do
                local col, row = (i - 1) % COLS, math.floor((i - 1) / COLS)
                cell:ClearAllPoints()
                cell:SetPoint("TOPLEFT", content, "TOPLEFT", 10 + col * CELL_W, -(y + row * CELL_H))
                cell:Show()
            end
            y = y + math.ceil(#sec.cells / COLS) * CELL_H + 10
        end
    end
    content:SetHeight(math.max(y, 1))
    local vp = math.min(y, MAX_VIEWPORT)
    panel.scroll:SetHeight(vp)
    panel:SetHeight(HEADER_TOP + vp + 12)
    if panel.scrollBar.Update then panel.scrollBar:Update() end
end

local function ToggleSection(sec)
    sec.collapsed = not sec.collapsed
    sec.arrow:SetNormalTexture(sec.collapsed and "Interface\\Buttons\\UI-PlusButton-UP" or "Interface\\Buttons\\UI-MinusButton-UP")
    for _, cell in ipairs(sec.cells) do
        if sec.collapsed then ClearCell(cell) else PlayCell(cell) end
    end
    Relayout()
end

local function Stop()
    if not panel then return end
    for _, sec in ipairs(panel.sections) do
        for _, cell in ipairs(sec.cells) do ClearCell(cell) end
    end
    if currentButtonGlow and _G.ActionButton1 then
        LCG.Proc:Clear(_G.ActionButton1, { glow = currentButtonGlow, key = TEST_KEY })
        currentButtonGlow = nil
    end
    panel:Hide()
end

local function Build()
    if panel then return panel end
    local order, buckets = GroupedGlows()
    local f = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    f:SetFrameStrata("DIALOG")
    f:SetWidth(COLS * CELL_W + 52)
    f:SetPoint("CENTER")
    f:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    f:SetBackdropColor(0.04, 0.04, 0.06, 0.96)
    f:SetBackdropBorderColor(0.30, 0.30, 0.36, 1)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetScript("OnMouseUp", function(_, button) if button == "RightButton" then Reroll() end end)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 14, -12)
    title:SetText("Orbit Glow Showcase")
    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", 14, -30)
    hint:SetText("left-click a glow -> ActionButton1   ::   right-click -> re-roll colours   ::   arrow -> collapse")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 2, 2)
    close:SetScript("OnClick", function() Stop() end)

    local scroll = CreateFrame("ScrollFrame", nil, f)
    scroll:SetPoint("TOPLEFT", 12, -HEADER_TOP)
    scroll:SetSize(COLS * CELL_W + 8, MAX_VIEWPORT)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(COLS * CELL_W + 8, 10)
    scroll:SetScrollChild(content)
    local scrollBar = CreateFrame("EventFrame", nil, f, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scroll, "TOPRIGHT", 10, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scroll, "BOTTOMRIGHT", 10, 0)
    scrollBar:SetHideIfUnscrollable(true)
    ScrollUtil.InitScrollFrameWithScrollBar(scroll, scrollBar)
    f.scroll, f.scrollBar, f.content = scroll, scrollBar, content

    f.sections = {}
    for _, src in ipairs(order) do
        local sec = { src = src, collapsed = false, cells = {} }
        local arrow = CreateFrame("Button", nil, content)
        arrow:SetSize(18, 18)
        arrow:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-UP")
        arrow:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
        arrow:SetScript("OnClick", function() ToggleSection(sec) end)
        sec.arrow = arrow
        sec.header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        sec.header:SetText(src .. "  |cff808080(" .. #buckets[src] .. ")|r")
        for _, glow in ipairs(buckets[src]) do
            local cell = CreateFrame("Frame", nil, content)
            cell:SetSize(ICON, ICON)
            cell:EnableMouse(true)
            local bg = cell:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            bg:SetColorTexture(0.12, 0.12, 0.15, 1)
            local lbl = cell:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            lbl:SetPoint("TOP", cell, "BOTTOM", 0, -2)
            lbl:SetText(glow)
            cell.glow = glow
            cell.tint = SHOW_PALETTE[1]
            cell:SetScript("OnMouseUp", function(_, button)
                if button == "RightButton" then Reroll() else ApplyToActionButton(glow) end
            end)
            sec.cells[#sec.cells + 1] = cell
        end
        f.sections[#f.sections + 1] = sec
    end
    panel = f
    Relayout()
    return f
end

local function Start()
    local f = Build()
    local tint = PickTint()
    f:Show()
    for _, sec in ipairs(f.sections) do
        if not sec.collapsed then
            for _, cell in ipairs(sec.cells) do cell.tint = tint; PlayCell(cell) end
        end
    end
end

LCG.Showcase = {}
function LCG.Showcase:Toggle() if panel and panel:IsShown() then Stop() else Start() end end
function LCG.Showcase:Show() if not (panel and panel:IsShown()) then Start() end end
function LCG.Showcase:Hide() if panel and panel:IsShown() then Stop() end end

-- Built-in convenience command -- guarded so an embedder (or another addon) that already owns /orbitglow keeps it. Hosts wanting their own binding can just call LCG.Showcase:Toggle().
if not SlashCmdList["ORBITGLOW"] then
    SLASH_ORBITGLOW1 = "/orbitglow"
    SlashCmdList["ORBITGLOW"] = function() LCG.Showcase:Toggle() end
end
