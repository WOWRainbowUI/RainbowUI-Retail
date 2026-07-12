local _, ns = ...

-------------------------------------------------------------------------------
-- UggPvpTalentAdapter: feed the PvP talent path (ClassCodexBnetPvpTalents,
-- read by PvPData's GetPvPBuilds) from u.gg PvP data.
--
-- u.gg PvP carries, per spec, the top hero's talent node string + the most
-- popular honor (PvP) talents. We surface them under the 3v3 bracket: honor
-- talents need no encoding; the talent build's exportString is encoded in-game
-- for the ACTIVE spec (TalentEncode needs the loaded tree), same as PvE.
-------------------------------------------------------------------------------

if not ClassCodexUggPvp then return end

local BRACKET = "pvp-3v3"

local function BuildUggPvpTalents()
    if not ClassCodexUggPvp then return end
    local activeClass, activeSpec
    if ns.GetClassAndSpec then activeClass, activeSpec = ns.GetClassAndSpec() end
    ClassCodexBnetPvpTalents = ClassCodexBnetPvpTalents or {}
    for class, specs in pairs(ClassCodexUggPvp) do
        ClassCodexBnetPvpTalents[class] = ClassCodexBnetPvpTalents[class] or {}
        for spec, sd in pairs(specs) do
            local t = sd.talent
            if t then
                local bracket = {}
                if t.honorTalents and #t.honorTalents > 0 then
                    bracket.pvpTalentSets = { { talents = t.honorTalents } }
                end
                -- Encode the talent build for the active spec only.
                if class == activeClass and spec == activeSpec and t.nodes and ns.EncodeUggTalents then
                    local ok, export = pcall(ns.EncodeUggTalents, t.nodes)
                    if ok and export and export ~= "" then
                        bracket.builds = { { exportString = export, heroTalent = t.hero } }
                    end
                end
                local entry = ClassCodexBnetPvpTalents[class][spec] or {}
                entry.brackets = entry.brackets or {}
                entry.brackets[BRACKET] = bracket
                ClassCodexBnetPvpTalents[class][spec] = entry
            end
        end
    end
end

BuildUggPvpTalents()

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
f:SetScript("OnEvent", function() BuildUggPvpTalents() end)
