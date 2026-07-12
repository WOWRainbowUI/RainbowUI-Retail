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

    local gear = _G.ClassCodexUggGearData and _G.ClassCodexUggGearData[class] and _G.ClassCodexUggGearData[class][spec]
    local bisTabs = gear and gear.bisGear
    line("Gear (u.gg)", bisTabs and #bisTabs > 0, bisTabs and (#bisTabs .. " tabs") or nil)
    line("Enchants (u.gg)", gear and gear.enchants and #gear.enchants > 0, gear and gear.enchants and (#gear.enchants .. " slots") or nil)

    local legacy = _G.ClassCodexGearData and _G.ClassCodexGearData[class] and _G.ClassCodexGearData[class][spec]
    local gems = legacy and legacy.gems
    line("Gems (u.gg)", gems and (gems.primary or (gems.secondary and #gems.secondary > 0)), gems and gems.primary and "primary + " .. count(gems.secondary) .. " secondary" or nil)
    line("Trinkets (u.gg)", legacy and legacy.trinkets and #legacy.trinkets > 0, legacy and legacy.trinkets and (#legacy.trinkets .. " ranked") or nil)

    local data = _G.ClassCodexData and _G.ClassCodexData[class] and _G.ClassCodexData[class][spec]
    line("Stat priority (u.gg)", data and data.priorities and #data.priorities > 0)
    line("Rotation (Icy Veins)", data and data.rotation and #data.rotation > 0, data and data.rotation and (#data.rotation .. " steps") or nil)

    local uggBuilds = _G.ClassCodexUggBuilds and _G.ClassCodexUggBuilds[class] and _G.ClassCodexUggBuilds[class][spec]
    line("Talents (u.gg)", uggBuilds and uggBuilds.contexts and next(uggBuilds.contexts) ~= nil)
    local ivT = _G.ClassCodexIcyVeinsTalentData and _G.ClassCodexIcyVeinsTalentData[class] and _G.ClassCodexIcyVeinsTalentData[class][spec]
    line("Talents (Icy Veins)", ivT and ivT.talents and #ivT.talents > 0)

    local craft = _G.ClassCodexCraftingData and _G.ClassCodexCraftingData[class] and _G.ClassCodexCraftingData[class][spec]
    line("Crafting (u.gg + Icy Veins)", craft ~= nil)

    local pvp = _G.ClassCodexUggPvp and _G.ClassCodexUggPvp[class] and _G.ClassCodexUggPvp[class][spec]
    line("PvP (u.gg)", pvp ~= nil)

    local emb = _G.ClassCodexEmbellishmentEffects and _G.ClassCodexEmbellishmentEffects.byItemId
    line("Embellishment effect map", emb and count(emb) > 0, emb and (count(emb) .. " items") or nil)

    -- Global coverage across all specs, so a per-spec gap vs a total outage is
    -- obvious at a glance.
    print(PREFIX .. "coverage across all specs: "
        .. "gear " .. specCount(_G.ClassCodexUggGearData) .. ", "
        .. "talents " .. specCount(_G.ClassCodexUggBuilds) .. ", "
        .. "crafting " .. specCount(_G.ClassCodexCraftingData) .. ", "
        .. "pvp " .. specCount(_G.ClassCodexUggPvp))
end
