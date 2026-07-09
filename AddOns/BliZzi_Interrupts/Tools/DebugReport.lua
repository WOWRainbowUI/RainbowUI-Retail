------------------------------------------------------------
-- DebugReport.lua — Graphical debug report window
-- /bitreport  →  opens / closes the window
------------------------------------------------------------

-- BIT is defined in Core.lua as BIT = BIT or {}
if not BIT then return end

local ADDON_NAME = "BliZzi_Interrupts"

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function SpellName(id)
    if not id then return "?" end
    local ok, n = pcall(C_Spell.GetSpellName, id)
    return (ok and n and n ~= "") and n or ("spell:" .. id)
end

local function SpecName(specID)
    if not specID or specID == 0 then return "Unknown" end
    local ok, _, name = pcall(GetSpecializationInfoByID, specID)
    return (ok and name) and name or ("specID:" .. specID)
end

local function Pad(str, width)
    str = tostring(str or "")
    if #str >= width then return str end
    return str .. string.rep(" ", width - #str)
end

------------------------------------------------------------
-- Report text builder
------------------------------------------------------------
local function BuildReport()
    local lines = {}
    local function L(s) lines[#lines + 1] = s or "" end
    local function HR(ch) L(string.rep(ch or "-", 60)) end

    local now = GetTime()

    local ver = (C_AddOns and C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")) or "?"
    L("BliZzi_Interrupts v" .. ver .. "  —  Debug Report")
    L("Generated : " .. date("%Y-%m-%d %H:%M:%S"))
    HR()

    -- Instance
    L("")
    L("[INSTANCE]")
    local ok1, iName, iType, _, iDiff = pcall(GetInstanceInfo)
    if ok1 then
        iName = iName or "none"
        iType = iType or "none"
        iDiff = (iDiff and iDiff ~= "") and ("  (" .. iDiff .. ")") or ""
        L("  Name     : " .. iName)
        L("  Type     : " .. iType .. iDiff)
    else
        L("  (GetInstanceInfo failed)")
    end

    local keyLevel = 0
    if C_ChallengeMode then
        local ok2, lvl = pcall(C_ChallengeMode.GetActiveKeystoneInfo)
        if ok2 and lvl and lvl > 0 then keyLevel = lvl end
    end
    L("  Keystone : " .. (keyLevel > 0 and ("M+" .. keyLevel) or "n/a"))

    if C_Map and C_Map.GetBestMapForUnit then
        local mapID = C_Map.GetBestMapForUnit("player")
        if mapID then
            local info = C_Map.GetMapInfo(mapID)
            if info and info.name then L("  Zone     : " .. info.name) end
        end
    end

    -- Group
    L("")
    L("[GROUP]")
    local function PrintMember(unit, label)
        local pname = (unit == "player") and BIT.myName or UnitName(unit)
        if not pname then return end
        local _, pclass = UnitClass(unit)
        local specID = 0
        if unit == "player" then
            local si = GetSpecialization and GetSpecialization()
            if si then specID = GetSpecializationInfo(si) or 0 end
        else
            specID = (GetInspectSpecialization and GetInspectSpecialization(unit)) or 0
        end
        local ue = BIT.SyncCD and BIT.SyncCD.users and BIT.SyncCD.users[pname]
        local tag = (unit == "player") and "[you]"
                    or (ue and (ue._fromCache and "[addon/cache]" or "[addon]") or "[no addon]")
        L(string.format("  %s %s  %s / %s  %s",
            label, Pad(pname, 16), Pad(pclass or "?", 12), Pad(SpecName(specID), 18), tag))

        local ks = ue and ue.knownSpells
        if ks then
            local ids = {}
            for sid in pairs(ks) do ids[#ids + 1] = sid end
            table.sort(ids)
            local parts = {}
            for _, sid in ipairs(ids) do
                parts[#parts + 1] = sid .. "(" .. SpellName(sid) .. ")"
            end
            if #parts > 0 then
                local prefix  = "             Spells: "
                local cont    = "                     "
                local cur = prefix
                for i, p in ipairs(parts) do
                    local sep = i < #parts and ", " or ""
                    if #cur + #p + #sep > 108 and cur ~= prefix then
                        L(cur); cur = cont .. p .. sep
                    else
                        cur = cur .. p .. sep
                    end
                end
                if cur ~= prefix then L(cur) end
            else
                L("             Spells: (none)")
            end
        elseif unit ~= "player" and not ue then
            L("             Spells: (no addon)")
        else
            L("             Spells: (not scanned yet)")
        end
    end

    PrintMember("player", "[player]")
    for i = 1, 4 do
        local u = "party" .. i
        if UnitExists(u) then PrintMember(u, "[party" .. i .. "]") end
    end

    -- SyncCD users
    L("")
    L("[SYNCCD USERS  (who sent HELLO / restored from cache)]")
    local anyUser = false
    if BIT.SyncCD and BIT.SyncCD.users then
        for uname, ue in pairs(BIT.SyncCD.users) do
            anyUser = true
            local tags = {}
            if ue._fromCache then tags[#tags + 1] = "cache" end
            if ue.class      then tags[#tags + 1] = "class=" .. ue.class end
            if ue.specID     then tags[#tags + 1] = "spec=" .. ue.specID .. "(" .. SpecName(ue.specID) .. ")" end
            L("  " .. Pad(uname, 16) .. "  " .. table.concat(tags, "  "))
        end
    end
    if not anyUser then L("  (empty)") end

    -- Active cooldowns
    L("")
    L("[ACTIVE COOLDOWNS]")
    local anyCD = false
    if BIT.syncCdState then
        local rows = {}
        for uname, spells in pairs(BIT.syncCdState) do
            for sid, cdEnd in pairs(spells) do
                local rem = cdEnd - now
                if rem > 0 then rows[#rows + 1] = { name = uname, sid = sid, rem = rem } end
            end
        end
        table.sort(rows, function(a, b)
            return a.name ~= b.name and a.name < b.name or a.rem < b.rem
        end)
        for _, r in ipairs(rows) do
            anyCD = true
            L(string.format("  %s  spell=%-6d (%s)  rem=%.1fs",
                Pad(r.name, 16), r.sid, SpellName(r.sid), r.rem))
        end
    end
    if not anyCD then L("  (none)") end

    -- Dev log
    L("")
    local buf = BIT.DevLogGetBuffer and BIT.DevLogGetBuffer() or {}
    local t0  = BIT.DevLogGetStartTime and BIT.DevLogGetStartTime() or now
    if #buf > 0 then
        local elapsed = string.format("%.0f", now - t0)
        L("[DEV LOG]  " .. #buf .. " entries,  started " .. elapsed .. "s ago")
        HR()
        for _, entry in ipairs(buf) do L(entry) end
    else
        L("[DEV LOG]  (empty — use /bitdevlog to start, then /bitreport)")
    end

    HR("=")
    return table.concat(lines, "\n")
end

------------------------------------------------------------
-- Window
------------------------------------------------------------
local WIN_W = 740
local WIN_H = 560
local reportFrame = nil

local function MakeButton(parent, label, w, h)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(w, h)
    btn:SetBackdrop({
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 1,
    })
    btn:SetBackdropColor(0.15, 0.15, 0.15, 1)
    btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.25, 1)
        self:SetBackdropBorderColor(0, 0.57, 0.93, 1)
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.15, 1)
        self:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    end)
    local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetAllPoints()
    fs:SetText(label)
    btn._label = fs
    return btn
end

local function CreateReportFrame()
    local f = CreateFrame("Frame", "BITDebugReportFrame", UIParent, "BackdropTemplate")
    f:SetSize(WIN_W, WIN_H)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(100)
    f:SetBackdrop({
        bgFile   = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeSize = 2,
    })
    f:SetBackdropColor(0.05, 0.05, 0.07, 0.96)
    f:SetBackdropBorderColor(0, 0.57, 0.93, 1)

    -- Title
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", f, "TOPLEFT", 14, -12)
    title:SetText("|cff0091edBliZzi|r |cffffa300Party Tools|r  —  Debug Report")

    -- Close button (X)
    local closeBtn = CreateFrame("Button", nil, f)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -8)
    local closeTex = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeTex:SetAllPoints()
    closeTex:SetText("|cffff4444X|r")
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- Divider line below title
    local divider = f:CreateTexture(nil, "ARTWORK")
    divider:SetColorTexture(0, 0.57, 0.93, 0.4)
    divider:SetHeight(1)
    divider:SetPoint("TOPLEFT",  f, "TOPLEFT",  8, -32)
    divider:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -32)

    -- Bottom buttons
    local BPAD = 8
    local BW   = 120
    local BH   = 22
    local BY   = 10

    local refreshBtn = MakeButton(f, "Refresh", BW, BH)
    refreshBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", BPAD, BY)

    local devlogBtn  = MakeButton(f, "Start Recording", BW + 20, BH)
    devlogBtn:SetPoint("LEFT", refreshBtn, "RIGHT", BPAD, 0)

    local selectBtn  = MakeButton(f, "Select All  (then Ctrl+C)", BW + 40, BH)
    selectBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -BPAD, BY)

    local function UpdateDevlogBtn()
        if BIT.devLogMode then
            devlogBtn._label:SetText("|cff44ff44Recording...|r  (click to stop)")
        else
            devlogBtn._label:SetText("Start Recording")
        end
    end

    devlogBtn:SetScript("OnClick", function()
        BIT.devLogMode = not BIT.devLogMode
        if BIT.devLogMode then BIT.DevLogStart() end
        UpdateDevlogBtn()
    end)

    -- Scroll frame + EditBox (content area)
    local TOP_OFF = -36
    local BOT_OFF =  BH + BY + BPAD + 4

    local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT",     f, "TOPLEFT",     8, TOP_OFF)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -28, BOT_OFF)

    local editBox = CreateFrame("EditBox", nil, scrollFrame)
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetFont("Fonts\\FRIZQT__.TTF", 11, "")
    editBox:SetTextColor(0.85, 0.95, 0.85, 1)
    editBox:SetWidth(scrollFrame:GetWidth())
    editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    scrollFrame:SetScrollChild(editBox)

    local function RefreshReport()
        UpdateDevlogBtn()
        local text = BuildReport()
        editBox:SetText(text)
        editBox:SetWidth(scrollFrame:GetWidth())
        scrollFrame:SetVerticalScroll(0)
    end

    refreshBtn:SetScript("OnClick", RefreshReport)
    selectBtn:SetScript("OnClick", function()
        editBox:SetFocus()
        editBox:HighlightText()
    end)

    f:SetScript("OnShow", RefreshReport)

    scrollFrame:SetScript("OnSizeChanged", function()
        editBox:SetWidth(scrollFrame:GetWidth())
    end)

    f:Hide()  -- start hidden; Show() triggers OnShow → RefreshReport
    return f
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------
function BIT.ToggleDebugReport()
    if not reportFrame then
        local ok, err = pcall(function()
            reportFrame = CreateReportFrame()
        end)
        if not ok then
            print("|cffff4444BIT DebugReport|r frame creation failed: " .. tostring(err))
            return
        end
    end
    if reportFrame:IsShown() then
        reportFrame:Hide()
    else
        reportFrame:Show()
    end
end

function BIT.OpenDebugReport()
    if not reportFrame then
        local ok, err = pcall(function()
            reportFrame = CreateReportFrame()
        end)
        if not ok then
            print("|cffff4444BIT DebugReport|r frame creation failed: " .. tostring(err))
            return
        end
    end
    reportFrame:Show()
end
