--[[
    RGX-Framework - UI Layout Engine

    Algorithmic placement for option pages. Pure geometry only: this module
    never touches textures, fonts, or colors. Visual styling lives in
    modules/design/design.lua and the section factory in controls.lua
    (UI:CreateSection). Layout and skin stay separate modules.

    Usage:
        local UI = RGX:GetUI()

        -- Flow layout: pack widgets top-down inside any host frame
        local flow = UI:CreateFlowLayout(host, { gap = 8 })
        flow:Add(label)
        flow:AddRow({ label, { child = btn, align = "right" } })
        flow:AddSpacer(6)
        local used = flow:Apply()   -- places children, returns used height

        -- Columns: consumer-proven split (edge to center to edge)
        -- Returns the content frame of each column (usable as a parent).
        local left, right = UI:CreateColumns(parent, 2, { gap = 8 })

        -- Cards: section visuals (Design) + attached flow + auto height
        local card = UI:CreateCard(parent, { title = "Section" })
        card.flow:AddRow({ { child = switch, align = "right" } })
        card:AutoHeight()
]]

local _, UI = ...
local RGX = _G.RGXFramework

if not RGX then
    error("RGX UI Layout: RGX-Framework not loaded")
    return
end

-- Constants kept in sync with UI:CreateSection content insets in controls.lua.
local TITLED_CONTENT_TOP = 42   -- Design:CreateSection content inset
local UNTITLED_CONTENT_TOP = 10
local CONTENT_BOTTOM = 12

local DEFAULT_GAP = 8
local MIN_ROW_HEIGHT = 12

-- Shared control-row alignment: one right inset for every reset control,
-- while the vertical center follows the actual track or dropdown trigger.
function UI:AnchorRowReset(row, reset, control, inset)
    local anchor = CreateFrame("Frame", nil, row)
    anchor:SetWidth(reset:GetWidth())
    anchor:SetPoint("TOP", control, "TOP")
    anchor:SetPoint("BOTTOM", control, "BOTTOM")
    anchor:SetPoint("RIGHT", row, "RIGHT", -(inset or 8), 0)
    reset:ClearAllPoints()
    reset:SetPoint("CENTER", anchor, "CENTER")
    return anchor
end

-- A centered group retains its alignment as its parent card changes width.
function UI:CreateButtonGroup(parent, labels, opts)
    opts = opts or {}
    local width, height, gap = opts.buttonWidth or 84, opts.height or 20, opts.gap or 8
    local group = CreateFrame("Frame", nil, parent)
    group:SetSize(#labels * width + math.max(0, #labels - 1) * gap, height)
    group:SetPoint("TOP", parent, "TOP", 0, opts.y or 0)
    group.buttons = {}
    for i, text in ipairs(labels) do
        local button = self:CreateButton(group, text, width, height)
        button:SetPoint("TOPLEFT", group, "TOPLEFT", (i - 1) * (width + gap), 0)
        group.buttons[i] = button
    end
    return group
end

-- Measure a child's natural size. FontStrings auto-size once their text is
-- set; frames report whatever SetSize gave them. Zero widths are treated as
-- "fill the row" candidates by the packing algorithm.
local function NaturalWidth(child)
    if child and child.GetWidth then
        local w = child:GetWidth()
        if type(w) == "number" and w > 0 then
            return w
        end
    end
    return nil
end

local function NaturalHeight(child, fallback)
    if child and child.GetHeight then
        local h = child:GetHeight()
        if type(h) == "number" and h > 0 then
            return h
        end
    end
    return fallback
end

local function Place(child, x, y, w)
    child:ClearAllPoints()
    if w then
        child:SetWidth(w)
    end
    child:SetPoint("TOPLEFT", x, y)
end

--[[============================================================================
    Flow layout
============================================================================]]

function UI:CreateFlowLayout(host, opts)
    opts = opts or {}
    local defaultGap = opts.gap or DEFAULT_GAP
    local gapY = opts.gapY or defaultGap
    local gapX = opts.gapX or defaultGap

    local entries = {} -- sequence of { kind = "row"|"spacer", ... }
    local layout

    local function Normalize(children)
        -- Accept a bare frame or an entry table { child = ..., align = ... }
        local out = {}
        for i = 1, #children do
            local e = children[i]
            if type(e) == "table" and e.child then
                out[#out + 1] = e
            else
                out[#out + 1] = { child = e }
            end
        end
        return out
    end

    layout = {
        -- Add one full-width row item. opts: align ("left"|"center"|"right"),
        -- width (fixed px), fill (bool: share remaining width).
        Add = function(_, child, itemOpts)
            entries[#entries + 1] = {
                kind = "row",
                children = { { child = child, align = (itemOpts or {}).align,
                    width = (itemOpts or {}).width, fill = (itemOpts or {}).fill } },
                opts = itemOpts or {},
            }
            return child
        end,

        -- Add one row of children packed left-to-right; entries tagged
        -- align = "right" are packed from the right edge instead.
        -- opts: gap (px between children), height (row height override).
        AddRow = function(_, children, rowOpts)
            rowOpts = rowOpts or {}
            entries[#entries + 1] = {
                kind = "row",
                children = Normalize(children or {}),
                opts = rowOpts,
            }
        end,

        AddSpacer = function(_, px)
            entries[#entries + 1] = { kind = "spacer", px = px or gapY }
        end,

        -- Pack and place everything. Returns the used content height.
        Apply = function()
            local avail = host:GetWidth()
            if not avail or avail <= 0 then
                avail = 0
            end
            local y = 0

            for _, entry in ipairs(entries) do
                if entry.kind == "spacer" then
                    y = y + entry.px
                else
                    local rowOpts = entry.opts
                    local gap = rowOpts.gap or gapX
                    local children = entry.children

                    -- Partition into left group and right group.
                    local leftGroup, rightGroup = {}, {}
                    for _, e in ipairs(children) do
                        if e.align == "right" then
                            rightGroup[#rightGroup + 1] = e
                        else
                            leftGroup[#leftGroup + 1] = e
                        end
                    end

                    -- Fixed widths first, then distribute the remainder
                    -- among fill entries (left group only).
                    local fixedTotal = 0
                    for _, e in ipairs(leftGroup) do
                        if e.width then
                            fixedTotal = fixedTotal + e.width
                        elseif e.fill then
                            -- counted below
                        else
                            local w = NaturalWidth(e.child)
                            if w then
                                e.width = w
                                fixedTotal = fixedTotal + w
                            end
                        end
                    end
                    local fillCount = 0
                    for _, e in ipairs(leftGroup) do
                        if not e.width and (e.fill or not NaturalWidth(e.child)) then
                            fillCount = fillCount + 1
                        end
                    end

                    local fillWidth = 0
                    if fillCount > 0 then
                        local room = avail - fixedTotal - gap * (#leftGroup - 1)
                        fillWidth = math.max(0, room / fillCount)
                    end

                    -- Row height.
                    local rowH = rowOpts.height
                    if not rowH then
                        rowH = MIN_ROW_HEIGHT
                        for _, e in ipairs(children) do
                            local h = NaturalHeight(e.child, MIN_ROW_HEIGHT)
                            if h > rowH then rowH = h end
                        end
                    end

                    -- Place the left group from the left edge.
                    local x = 0
                    for _, e in ipairs(leftGroup) do
                        local w = e.width or fillWidth
                        local h = NaturalHeight(e.child, MIN_ROW_HEIGHT)
                        local childY = y + (rowH - h) / 2
                        Place(e.child, x, -childY, (e.fill or not e.width) and w or nil)
                        x = x + w + gap
                    end

                    -- Place the right group from the right edge.
                    local rx = avail
                    for i = #rightGroup, 1, -1 do
                        local e = rightGroup[i]
                        local w = e.width or NaturalWidth(e.child) or 0
                        rx = rx - w
                        local h = NaturalHeight(e.child, MIN_ROW_HEIGHT)
                        local childY = y + (rowH - h) / 2
                        Place(e.child, rx, -childY, e.width and w or nil)
                        rx = rx - gap
                    end

                    -- Single-item alignment for plain Add() rows.
                    if #children == 1 and children[1].align == "center" then
                        local e = children[1]
                        local w = e.width or fillWidth or NaturalWidth(e.child) or 0
                        local xOff = (avail - w) / 2
                        local h = NaturalHeight(e.child, MIN_ROW_HEIGHT)
                        Place(e.child, xOff, -(y + (rowH - h) / 2),
                            (e.fill or not e.width) and w or nil)
                    end

                    y = y + rowH + gapY
                end
            end

            -- No trailing gap after the final row.
            local used = y - (entries[#entries] and (entries[#entries].kind == "row" and gapY or 0) or 0)
            return math.max(0, used)
        end,
    }

    return layout
end

--[[============================================================================
    Pager

    Consumer-style tab content paging: a "Page X of Y" label with Prev/Next
    buttons anchored top-right of the host, and N full-size page frames of
    which only the active one is shown. Single-page pagers hide the chrome
    entirely. Visuals come from Design (buttons/labels); this module owns
    only the paging algorithm.
============================================================================]]

function UI:CreatePager(parent, opts)
    opts = opts or {}
    local format = string.format
    local pageCount = math.max(1, opts.pages or 1)
    local startPage = math.min(math.max(1, opts.startPage or 1), pageCount)
    local onPageChanged = opts.onPageChanged
    local buttonWidth = opts.buttonWidth or 56
    local buttonHeight = opts.buttonHeight or 20
    local D = RGX:GetDesign()

    local navHeight = buttonHeight + 8
    local topOffset = pageCount > 1 and -navHeight or 0

    local frames = {}
    for i = 1, pageCount do
        local f = CreateFrame("Frame", nil, parent)
        f:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, topOffset)
        f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
        f:Hide()
        frames[i] = f
    end

    local pager

    local nav = CreateFrame("Frame", nil, parent)
    nav:SetHeight(buttonHeight)
    nav:SetWidth(buttonWidth * 2 + 8 + 110)
    nav:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, -4)

    local nextBtn = UI:CreateButton(nav, "Next", buttonWidth, buttonHeight)
    nextBtn:SetPoint("TOPRIGHT", nav, "TOPRIGHT", 0, 0)
    local prevBtn = UI:CreateButton(nav, "Prev", buttonWidth, buttonHeight)
    prevBtn:SetPoint("TOPRIGHT", nextBtn, "TOPLEFT", -8, 0)

    local label = nav:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("RIGHT", prevBtn, "LEFT", -10, 0)
    label:SetJustifyH("RIGHT")
    label:SetTextColor(D:Unpack("subtext"))

    local function UpdateNav()
        label:SetText(format("Page %d of %d", pager.page, pageCount))
        local tr, tg, tb = D:Unpack("text")
        local sr, sg, sb = D:Unpack("subtext")
        if pager.page > 1 then
            prevBtn:Enable()
            if prevBtn.label then prevBtn.label:SetTextColor(tr, tg, tb) end
        else
            prevBtn:Disable()
            if prevBtn.label then prevBtn.label:SetTextColor(sr, sg, sb) end
        end
        if pager.page < pageCount then
            nextBtn:Enable()
            if nextBtn.label then nextBtn.label:SetTextColor(tr, tg, tb) end
        else
            nextBtn:Disable()
            if nextBtn.label then nextBtn.label:SetTextColor(sr, sg, sb) end
        end
    end

    pager = {
        frames = frames,
        nav = nav,
        label = label,
        prevBtn = prevBtn,
        nextBtn = nextBtn,
        page = startPage,
        pageCount = pageCount,
        SetPage = function(self, n)
            n = math.min(math.max(1, n or self.page), pageCount)
            local changed = n ~= self.page
            self.page = n
            for i = 1, pageCount do
                frames[i]:SetShown(i == n)
            end
            UpdateNav()
            if changed and onPageChanged then
                onPageChanged(n)
            end
        end,
        Next = function(self) self:SetPage(self.page + 1) end,
        Prev = function(self) self:SetPage(self.page - 1) end,
        GetPage = function(self) return self.page end,
    }

    prevBtn:SetScript("OnClick", function() pager:Prev() end)
    nextBtn:SetScript("OnClick", function() pager:Next() end)

    if pageCount <= 1 then
        nav:Hide()
    end

    for i = 1, pageCount do
        frames[i]:SetShown(i == startPage)
    end
    UpdateNav()
    if onPageChanged then
        onPageChanged(startPage)
    end

    return pager
end

--[[============================================================================
    Card

    A titled or untitled section (visuals from UI:CreateSection / Design)
    with an attached flow layout and algorithmic auto height.
============================================================================]]

function UI:CreateCard(parent, opts)
    opts = opts or {}
    local card = UI:CreateSection(parent, {
        title = opts.title or "",
        height = opts.height or 120,
    })

    -- Fill the parent width immediately so flow measurement (fill children,
    -- AutoHeight) sees the real available width. A parent flow's Apply()
    -- re-anchors cards it manages, overriding these anchors.
    card:ClearAllPoints()
    card:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    card:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)

    card.flow = UI:CreateFlowLayout(card.content, {
        gap = opts.gap or DEFAULT_GAP,
    })

    -- Resize the card to exactly fit its flow content. Call after all
    -- flow:Add/AddRow calls. Extra px can be appended via the argument.
    card.AutoHeight = function(first, extra)
        -- Normal method calls pass the card first. Keep the original dot-call
        -- form available to consumers that already use AutoHeight(extra).
        if first ~= card then extra = first end
        local used = card.flow:Apply()
        local top = card.headerBand and TITLED_CONTENT_TOP or UNTITLED_CONTENT_TOP
        card:SetHeight(top + used + CONTENT_BOTTOM + (extra or 0))
        return card
    end

    return card
end
