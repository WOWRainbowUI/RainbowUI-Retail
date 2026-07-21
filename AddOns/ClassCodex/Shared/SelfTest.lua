local _, ns = ...

-------------------------------------------------------------------------------
-- SelfTest: `/cc selftest` — a read-only data-coverage check for QA. Prints,
-- for the player's current spec, which surfaces have data wired (what the
-- sections read), so a tester can confirm every tab will populate in one
-- command instead of clicking through all of them.
--
-- Dev/diagnostic command — raw English, like `/cc inspectdump` / `/cc dumptree`
-- (not player-facing UI, so intentionally not localized).
-------------------------------------------------------------------------------

local PREFIX = "|cff00ccffClass Codex|r "
local function green(s) return "|cff40ff40" .. s .. "|r" end
local function red(s) return "|cffff5555" .. s .. "|r" end

local function count(t)
    if type(t) ~= "table" then return 0 end
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

-- Report one surface: OK with a detail, or EMPTY.
local function line(label, ok, detail)
    print("  " .. (ok and green("OK  ") or red("--  ")) .. label .. (detail and (" — " .. detail) or ""))
end

local function specCount(root)
    if type(root) ~= "table" then return 0 end
    local n = 0
    for _, specs in pairs(root) do n = n + count(specs) end
    return n
end

function ns.RunSelfTest()
    local class, spec
    if ns.GetClassAndSpec then class, spec = ns.GetClassAndSpec() end
    if not class or not spec then
        print(PREFIX .. red("could not resolve your class/spec — open the panel once, then retry."))
        return
    end
    print(PREFIX .. "self-test for " .. green(class .. " / " .. spec) .. ":")

    -- Everything reads the normalized structure through the accessors / seam.
    local gear = ns.GetUggGearSpecData and ns:GetUggGearSpecData(class, spec)
    local bisTabs = gear and gear.bisGear
    line("Gear (u.gg)", bisTabs and #bisTabs > 0, bisTabs and (#bisTabs .. " tabs") or nil)
    line("Enchants (u.gg)", gear and gear.enchants and #gear.enchants > 0, gear and gear.enchants and (#gear.enchants .. " slots") or nil)

    local gd = ns.GetSpecGearData and ns.GetSpecGearData(class, spec)
    local gems = gd and gd.gems
    line("Gems (u.gg)", gems and (gems.primary or (gems.secondary and #gems.secondary > 0)), gems and gems.primary and "primary + " .. count(gems.secondary) .. " secondary" or nil)
    line("Trinkets (u.gg)", gd and gd.trinkets and #gd.trinkets > 0, gd and gd.trinkets and (#gd.trinkets .. " ranked") or nil)

    local data = _G.ClassCodexData and _G.ClassCodexData[class] and _G.ClassCodexData[class][spec]
    line("Stat priority (Icy Veins)", data and data.priorities and #data.priorities > 0)
    line("Rotation (Icy Veins)", data and data.rotation and #data.rotation > 0, data and data.rotation and (#data.rotation .. " builds") or nil)

    local uggBuilds = _G.ClassCodexUggBuilds and _G.ClassCodexUggBuilds[class] and _G.ClassCodexUggBuilds[class][spec]
    line("Talents (u.gg)", uggBuilds and uggBuilds.contexts and next(uggBuilds.contexts) ~= nil)
    local ivT = ns.GetIcyVeinsTalentSpecData and ns:GetIcyVeinsTalentSpecData(class, spec)
    line("Talents (Icy Veins)", ivT and ivT.talents and #ivT.talents > 0)

    line("Crafting (u.gg + Icy Veins)", (ns.SourceHas and (ns.SourceHas("ugg", class, spec, "crafting") or ns.SourceHas("icyveins", class, spec, "crafting"))) or false)
    line("PvP (u.gg)", (ns.HasPvPData and ns.HasPvPData(class, spec)) or false)

    local emb = ClassCodexReference and ClassCodexReference.embellishmentEffects
    line("Embellishment effect map", emb and count(emb) > 0, emb and (count(emb) .. " items") or nil)

    -- Per-source spec coverage, so a per-spec gap vs a total outage is obvious.
    local cov = {}
    for _, src in ipairs(ns.Sources and ns.Sources() or {}) do
        cov[#cov + 1] = src .. " " .. specCount(ClassCodexSource[src] and ClassCodexSource[src].data)
    end
    print(PREFIX .. "coverage across all specs: " .. table.concat(cov, ", "))
end
