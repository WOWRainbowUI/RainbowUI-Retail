local _, ns = ...
ns.Sections = ns.Sections or {}

local L = ns.L

-- Omnium Folio weekly rune recommendations (Icy Veins). Rendered as a vertical
-- list mirroring the Crafting table: one row per week, each a framed spell icon
-- (ns.CreateSlotIcon + SetSpell) with the rune's spell name and a dimmed week
-- label. Hero- and content-agnostic — the data lives under omniumFolio.all.all.
local Omnium = {}
ns.Sections.Omnium = Omnium

local MAX_WEEKS     = 12
local ICON_SIZE     = 32
-- KL ratio the Quickslot2 bevel renders cleanly at — same as the Crafting table.
local SLOT_RATIO    = 1.8125
local SLOT_FRAME    = math.floor(ICON_SIZE * SLOT_RATIO + 0.5)
local SLOT_OVERHANG = math.floor((SLOT_FRAME - ICON_SIZE) / 2)
local ROW_HEIGHT    = 40
local INSET_X       = 10
local TEXT_X        = INSET_X + ICON_SIZE + SLOT_OVERHANG + 4

local panel = {}

local function SpellName(spellId, fallback)
    local n = spellId and C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spellId)
    return n or fallback or ""
end

local function WeekLabel(i)
    local fmt = L and L["omnium.week"]
    return fmt and fmt:format(i) or ("Week " .. i)
end

-- opts.parent (contentFrame), opts.header (CreateSectionHeader) for collapse hook
function Omnium.InitPanel(opts)
    panel.section = CreateFrame("Frame", nil, opts.parent)
    panel.header = opts.header(panel.section, L["section.omnium"])
    panel.content = CreateFrame("Frame", nil, panel.section)
    panel.content:SetPoint("TOPLEFT", panel.header, "BOTTOMLEFT", 0, 0)
    panel.content:SetPoint("RIGHT", 0, 0)

    panel.rows = {}
    for i = 1, MAX_WEEKS do
        local row = CreateFrame("Frame", nil, panel.content)
        row:SetHeight(ROW_HEIGHT)
        row:EnableMouse(true)

        local icon = ns.CreateSlotIcon(row, { size = ICON_SIZE, slotSize = SLOT_FRAME })
        icon:SetPoint("LEFT", row, "LEFT", INSET_X, 0)
        row.icon = icon

        -- Two-line text block, vertically centred on the row: dimmed week label
        -- above the rune's spell name.
        local week = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        week:SetPoint("BOTTOMLEFT", row, "LEFT", TEXT_X, 2)
        week:SetTextColor(0.6, 0.6, 0.6)
        row.week = week

        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        name:SetPoint("TOPLEFT", row, "LEFT", TEXT_X, -2)
        name:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        name:SetJustifyH("LEFT"); name:SetWordWrap(false)
        row.name = name

        row:SetScript("OnEnter", function(self)
            if self.spellId then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(self.spellId)
                GameTooltip:Show()
            end
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:Hide()
        panel.rows[i] = row
    end

    return panel.section, panel.header, panel.content
end

-- args = { runes = { { spellId, label?, note? }, ... } }
-- Returns content height for the layout pass (0 when there is nothing to show).
function Omnium.RenderPanel(args)
    for i = 1, MAX_WEEKS do panel.rows[i]:Hide() end

    local runes = args and args.runes
    if not runes or #runes == 0 then return 0 end

    local count = math.min(#runes, MAX_WEEKS)
    for i = 1, count do
        local r = runes[i]
        local row = panel.rows[i]
        row.icon:SetSpell(r.spellId)
        row.spellId = r.spellId
        row.week:SetText(WeekLabel(i))
        row.name:SetText(SpellName(r.spellId, r.label))
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 0, -(i - 1) * ROW_HEIGHT)
        row:SetPoint("RIGHT", panel.content, "RIGHT", 0, 0)
        row:Show()
    end

    return count * ROW_HEIGHT
end
