------------------------------------------------------------
-- BliZzi Interrupts — Smart Misdirect
--
-- Optional extra feature for Hunters (Misdirection 34477) and
-- Rogues (Tricks of the Trade 57934). A pair of secure action
-- buttons picks the most useful target based on user preference
-- (manual override → focus → tanks → pet) and re-targets itself
-- whenever the group, focus, or role assignments change. A macro
-- can be generated from the settings panel with a single click.
--
-- The module is a no-op for every class that is not Hunter or
-- Rogue — the secure buttons are never created on non-eligible
-- classes so the feature is invisible to them.
------------------------------------------------------------

local MISDIRECTION_ID       = 34477  -- Hunter
local TRICKS_OF_THE_TRADE_ID = 57934  -- Rogue

BIT.SmartMisdirect = BIT.SmartMisdirect or {}
local SM = BIT.SmartMisdirect

-- runtime state
SM.buttons         = {}     -- array of 2 secure action buttons
SM._updateQueued   = false
SM._currentTarget  = nil    -- string: "Name" / "Name-Realm" / "pet"
SM._wasMounted     = false

------------------------------------------------------------
-- Helpers
------------------------------------------------------------
local function IsEligibleClass()
    local cls = BIT.Self and BIT.Self.class or BIT.myClass
    return cls == "HUNTER" or cls == "ROGUE"
end

local function IsHunter()
    local cls = BIT.Self and BIT.Self.class or BIT.myClass
    return cls == "HUNTER"
end

local function GetActiveSpellID()
    return IsHunter() and MISDIRECTION_ID or TRICKS_OF_THE_TRADE_ID
end

-- Name-realm helper.  Cross-realm players come back from UnitName as
-- ("Name", "Realm"); same-realm as ("Name", ""). We keep the Realm
-- suffix only for cross-realm so the secure button's "unit" attribute
-- matches what WoW expects.
local function FullName(name, realm)
    if not name then return nil end
    if realm and realm ~= "" then
        return name .. "-" .. realm
    end
    return name
end

-- Iterate every group member (player + party / player + raidN).
-- Yields unit tokens; skips ones that do not currently exist.
local function IterGroupUnits()
    local units = {}
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local u = "raid" .. i
            if UnitExists(u) then units[#units+1] = u end
        end
    else
        units[#units+1] = "player"
        for i = 1, (GetNumGroupMembers() or 0) - 1 do
            local u = "party" .. i
            if UnitExists(u) then units[#units+1] = u end
        end
    end
    return units
end

------------------------------------------------------------
-- Secure buttons
------------------------------------------------------------
function SM:CreateButtons()
    if not IsEligibleClass() then return end
    if #self.buttons > 0 then return end
    -- Secure action buttons must not be created/configured in combat.
    -- Defer to PLAYER_REGEN_ENABLED; the Core dispatcher re-runs
    -- ProcessQueuedUpdate which calls CreateButtons again.
    if InCombatLockdown() then
        self._updateQueued = true
        return
    end

    local spellID = GetActiveSpellID()
    for i = 1, 2 do
        local name = "BIT_SmartMisdirectButton" .. i
        local btn  = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
        btn:Hide()
        btn:SetAttribute("type", "spell")
        btn:SetAttribute("typerelease", "spell")
        btn:SetAttribute("spell", spellID)
        btn:SetAttribute("pressAndHoldAction", "1")
        btn:SetAttribute("allowVehicleTarget", false)
        btn:SetAttribute("checkselfcast", false)
        btn:SetAttribute("checkfocuscast", false)
        btn:RegisterForClicks("LeftButtonDown", "LeftButtonUp")
        self.buttons[i] = btn
    end
    BIT.DevLog("[SMD] created "..#self.buttons.." secure buttons (spellID="..spellID..")")
end

------------------------------------------------------------
-- Target resolution
------------------------------------------------------------

-- Collect tanks from the group, formatted as "Name" / "Name-Realm".
-- method: "byRole" | "roleAndMainTank" | "mainTankFirst" | "mainTankOnly"
function SM:GetTanks()
    local method = (BIT.db and BIT.db.smartMdTankMethod) or "byRole"
    local result = {}
    local seen   = {}

    local function addIf(unit, wantRole, wantMain)
        local name, realm = UnitName(unit)
        if not name then return end
        local full = FullName(name, realm)
        if seen[full] then return end
        local isTankRole = UnitGroupRolesAssigned(unit) == "TANK"
        local isMainTank = GetPartyAssignment and GetPartyAssignment("MAINTANK", unit, true)
        if (wantRole and isTankRole) or (wantMain and isMainTank) then
            seen[full] = true
            result[#result+1] = full
        end
    end

    local units = IterGroupUnits()

    if method == "mainTankFirst" then
        -- main tanks first, then role-tanks, each group sorted
        local mains, tanks = {}, {}
        local seenM, seenT = {}, {}
        for _, u in ipairs(units) do
            local name, realm = UnitName(u)
            if name then
                local full = FullName(name, realm)
                if GetPartyAssignment and GetPartyAssignment("MAINTANK", u, true) and not seenM[full] then
                    seenM[full] = true
                    mains[#mains+1] = full
                elseif UnitGroupRolesAssigned(u) == "TANK" and not seenT[full] then
                    seenT[full] = true
                    tanks[#tanks+1] = full
                end
            end
        end
        table.sort(mains)
        table.sort(tanks)
        for _, v in ipairs(mains) do result[#result+1] = v end
        for _, v in ipairs(tanks) do result[#result+1] = v end
        return result
    end

    if method == "mainTankOnly" then
        for _, u in ipairs(units) do addIf(u, false, true) end
    elseif method == "roleAndMainTank" then
        for _, u in ipairs(units) do addIf(u, true, true) end
    else
        -- default: byRole
        for _, u in ipairs(units) do addIf(u, true, false) end
    end

    table.sort(result)
    return result
end

-- Build the prioritised target list. Order:
--   0. Manual override (highest)
--   1. Focus (if opted in)
--   2. Tanks (by selection method)
--   3. Hunter pet (if nothing else and opted in; hunters only)
function SM:GetTargets()
    if not IsEligibleClass() then return {} end
    if not (BIT.db and BIT.db.smartMdEnabled) then return {} end

    local out, seen = {}, {}
    local function push(x) if x and not seen[x] then seen[x] = true; out[#out+1] = x end end

    -- 0. Manual override
    local manualName  = BIT.db.smartMdManualName  or ""
    local manualRealm = BIT.db.smartMdManualRealm or ""
    if manualName ~= "" then
        local wantName  = manualName:lower()
        local wantRealm = manualRealm:lower()
        for _, u in ipairs(IterGroupUnits()) do
            local name, realm = UnitName(u)
            if name and name:lower() == wantName then
                if wantRealm ~= "" then
                    if realm and realm:lower() == wantRealm then
                        push(name .. "-" .. realm); break
                    end
                else
                    -- same-realm or realm empty → accept any
                    push(FullName(name, realm)); break
                end
            end
        end
    end

    -- 1. Focus
    if BIT.db.smartMdPrioritizeFocus then
        if UnitExists("focus") and (UnitInParty("focus") or UnitInRaid("focus")) then
            local fn, fr = UnitName("focus")
            push(FullName(fn, fr))
        end
    end

    -- 2. Tanks
    for _, tank in ipairs(self:GetTanks()) do push(tank) end

    -- 3. Pet fallback (Hunters only — Rogues can't Tricks their own pet)
    if IsHunter() and BIT.db.smartMdIncludePet and #out == 0 then
        if UnitExists("pet") then push("pet") end
    end

    return out
end

------------------------------------------------------------
-- Apply targets to the secure buttons
------------------------------------------------------------
function SM:QueueUpdate()
    if not IsEligibleClass() then return end
    self._updateQueued = true
    self:ProcessQueuedUpdate()
end

-- Explicit "clear everything" path — called when the user flips the
-- master toggle off so the secure buttons don't keep pointing at the
-- last target.
function SM:ClearButtons()
    if InCombatLockdown() then
        -- Defer; PLAYER_REGEN_ENABLED will re-run ProcessQueuedUpdate,
        -- which calls GetTargets() and sees smartMdEnabled == false.
        self._updateQueued = true
        return
    end
    for _, btn in ipairs(self.buttons) do
        btn:SetAttribute("type", nil)
        btn:SetAttribute("unit", nil)
    end
    self._currentTarget = nil
end

function SM:ProcessQueuedUpdate()
    if not IsEligibleClass() then return end
    if not self._updateQueued then return end
    if InCombatLockdown() then return end
    self._updateQueued = false

    -- GetTargets() returns {} when disabled — the clear loop below
    -- then wipes both buttons automatically.
    if #self.buttons == 0 and BIT.db and BIT.db.smartMdEnabled then
        self:CreateButtons()
    end

    local targets = self:GetTargets()
    local primary = targets[1]

    -- Suppress chat while mounted / in PvP — prevents spam as the
    -- pet despawns on mount and tanks constantly change in BG/Arena.
    local mounted = IsMounted()
    local _, insType = IsInInstance()
    local suppress = mounted or self._wasMounted
        or insType == "pvp" or insType == "arena"

    if BIT.db.smartMdAnnounceTarget then
        if primary and primary ~= self._currentTarget then
            self._currentTarget = primary
            if not suppress then
                print(string.format("|cff0091edBIT|r %s |cFFFFD700%s|r",
                    BIT.L["SMD_TARGET_NOW"] or "Smart Misdirect target:", primary))
            end
        elseif not primary and self._currentTarget then
            self._currentTarget = nil
            if not suppress then
                print("|cff0091edBIT|r |cffff5555" ..
                    (BIT.L["SMD_NO_TARGET"] or "Smart Misdirect: no valid target") .. "|r")
            end
        end
    else
        self._currentTarget = primary
    end
    self._wasMounted = mounted

    -- Apply or clear attributes on the two buttons
    for i, btn in ipairs(self.buttons) do
        local t = targets[i]
        if t then
            btn:SetAttribute("type", "spell")
            btn:SetAttribute("unit", t)
        else
            btn:SetAttribute("type", nil)
            btn:SetAttribute("unit", nil)
        end
    end
end

------------------------------------------------------------
-- Manual override helpers
------------------------------------------------------------
function SM:ClearManualOverride(silent)
    if not IsEligibleClass() then return end
    BIT.db.smartMdManualName  = ""
    BIT.db.smartMdManualRealm = ""
    if not silent then
        print("|cff0091edBIT|r " ..
            (BIT.L["SMD_OVERRIDE_CLEARED"] or "Manual override cleared."))
    end
    self:QueueUpdate()
end

function SM:OnGroupLeft()
    if not IsEligibleClass() then return end
    if not (BIT.db and BIT.db.smartMdEnabled) then return end
    local has = (BIT.db.smartMdManualName or "") ~= ""
    if has then
        self:ClearManualOverride(true)
    else
        self:QueueUpdate()
    end
end

-- Called when the user toggles the active spec; re-read the
-- active spellID so a Hunter multi-boxing a Rogue alt still
-- gets the correct spell wired up.
function SM:OnSpecChanged()
    if not IsEligibleClass() then return end
    if #self.buttons == 0 then return end
    if InCombatLockdown() then return end
    local spellID = GetActiveSpellID()
    for _, btn in ipairs(self.buttons) do
        btn:SetAttribute("spell", spellID)
    end
end

------------------------------------------------------------
-- Macro creation (triggered from the settings panel)
------------------------------------------------------------
-- Returns (index, wasCreated, wasUpdated).  The macro body consists of
-- a straight /cast by spell name — clicking it triggers the secure
-- button machinery because the player's own spell cast re-targets
-- whatever the selected "target" happens to be. To make the macro
-- actually leverage our secure buttons we use /click on the first
-- button; for the second we fall back to /click on the backup.
--
-- /click BIT_SmartMisdirectButton1
-- /click BIT_SmartMisdirectButton2
--
-- The macro is created per-character (perCharacter = 1). It uses the
-- spell icon so it looks familiar on the action bar.
function SM:CreateMacro()
    if not IsEligibleClass() then
        print("|cff0091edBIT|r |cffff5555" ..
            (BIT.L["SMD_MACRO_WRONG_CLASS"] or "Smart Misdirect macro is only available for Hunters and Rogues.") .. "|r")
        return nil, false, false
    end
    if InCombatLockdown() then
        print("|cff0091edBIT|r |cffff5555" ..
            (BIT.L["SMD_MACRO_IN_COMBAT"] or "Cannot create macros while in combat.") .. "|r")
        return nil, false, false
    end

    -- Make sure the buttons exist so /click has something to click.
    if #self.buttons == 0 then self:CreateButtons() end
    self:QueueUpdate()

    local hunter = IsHunter()
    local macroName = hunter and "SmartMD" or "SmartTotT"
    local icon      = hunter and 132180 or 236283  -- Misdirection / Tricks icon
    local body      = string.format(
        "#showtooltip\n/click BIT_SmartMisdirectButton1\n/click BIT_SmartMisdirectButton2")

    local existing = GetMacroIndexByName(macroName)
    if existing and existing > 0 then
        -- EditMacro(index, name, icon, body) — updates in place regardless of tab.
        EditMacro(existing, macroName, icon, body)
        print("|cff0091edBIT|r " .. string.format(
            BIT.L["SMD_MACRO_UPDATED"] or "Updated macro '%s' (per-character).", macroName))
        return existing, false, true
    end

    -- CreateMacro(name, icon, body, perCharacter)
    --   perCharacter = 1 → character-specific macro tab
    --   perCharacter = nil → global macro tab
    local idx = CreateMacro(macroName, icon, body, 1)
    if not idx then
        -- Macro slot full — tell the user so they can make room.
        print("|cff0091edBIT|r |cffff5555" ..
            (BIT.L["SMD_MACRO_FULL"] or "Macro slots are full — free one and retry.") .. "|r")
        return nil, false, false
    end
    print("|cff0091edBIT|r " .. string.format(
        BIT.L["SMD_MACRO_CREATED"] or "Created macro '%s' — drag it onto your action bar.", macroName))
    return idx, true, false
end

------------------------------------------------------------
-- Debug: print current target list
------------------------------------------------------------
function SM:DebugPrintTargets()
    if not IsEligibleClass() then
        print("|cff0091edBIT|r Smart Misdirect — wrong class")
        return
    end
    local ts = self:GetTargets()
    print("|cff0091edBIT|r Smart Misdirect targets (" .. #ts .. "):")
    for i, t in ipairs(ts) do
        print(string.format("  %d. %s", i, t))
    end
    if #ts == 0 then
        print("  |cffff5555none|r")
    end
end

------------------------------------------------------------
-- Initialize — called from BIT:Initialize() after SavedVars load
------------------------------------------------------------
function SM:Initialize()
    -- Guard on class: non-eligible classes never create buttons and never
    -- subscribe to the PLAYER_FOCUS_CHANGED / GROUP_LEFT events.
    if not IsEligibleClass() then return end

    -- Create our own event frame for the two events that are not
    -- already dispatched by Core.lua. GROUP_ROSTER_UPDATE /
    -- PLAYER_ENTERING_WORLD / PLAYER_REGEN_ENABLED are handled by
    -- Core.lua and forwarded into SM:QueueUpdate() from there.
    local ef = CreateFrame("Frame")
    ef:RegisterEvent("PLAYER_FOCUS_CHANGED")
    ef:RegisterEvent("GROUP_LEFT")
    ef:RegisterEvent("PLAYER_ROLES_ASSIGNED")  -- role assignments changed
    ef:SetScript("OnEvent", function(_, event)
        if event == "GROUP_LEFT" then
            SM:OnGroupLeft()
        else
            SM:QueueUpdate()
        end
    end)

    if BIT.db and BIT.db.smartMdEnabled then
        self:CreateButtons()
        -- Slight delay so GROUP_ROSTER_UPDATE / role data is ready
        C_Timer.After(2, function() SM:QueueUpdate() end)
    end
end
