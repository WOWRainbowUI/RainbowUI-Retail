local _, ns = ...

-- SourceReader — builds the two UI globals that are read inline in many places
-- (ClassCodexData) or need build-time in-game talent encoding (ClassCodexUggBuilds)
-- from the normalized ClassCodexSource. Every other global was retired: the UI
-- accessors read ClassCodexSource directly through the SourceData seam.
--
-- Runs on PLAYER_LOGIN + PLAYER_SPECIALIZATION_CHANGED (the encode needs the
-- active spec's loaded tree). ClassCodexData is mutated in place (it's upvalued
-- elsewhere), never reassigned.
--
-- The two globals are created empty here at file load — before ClassCodex.lua /
-- Compendium.lua capture them into a file-scope local — so those upvalues hold a
-- live table the event handler then fills in place. (Legacy SourceAdapter did the
-- same; without it the main UI's `local DATA = ClassCodexData` reads nil and bails.)
ClassCodexData = ClassCodexData or {}
ClassCodexUggBuilds = ClassCodexUggBuilds or {}

local WILDCARD = "all"
local STAT_DISPLAY = { crit = "Critical Strike", haste = "Haste", mastery = "Mastery", versatility = "Versatility" }
local ROTATION_CTX = { ["single-target"] = "Single Target", aoe = "AoE", cleave = "Cleave", [WILDCARD] = "Rotation" }
local TALENT_CTX = { raid = "Raid", mplus = "Mythic+", delve = "Delves", leveling = "Leveling", [WILDCARD] = "General" }

local function resolve(category, hero, context)
  if not category then return nil end
  return ns.ResolveCategory and ns.ResolveCategory(category, hero, context) or nil
end

-- ClassCodexData[c][s] = { priorities, rotation, talents } from Icy Veins.
local function buildClassCodexData(iv)
  ClassCodexData = ClassCodexData or {}
  for class, specs in pairs(iv.data) do
    ClassCodexData[class] = ClassCodexData[class] or {}
    for spec, sd in pairs(specs) do
      local entry = {}

      local sp = resolve(sd.statPriority, WILDCARD, WILDCARD)
      if sp and sp.secondary then
        local tiers = {}
        for _, tier in ipairs(sp.secondary) do
          local names = {}
          for _, k in ipairs(tier) do names[#names + 1] = STAT_DISPLAY[k] or k end
          if #names > 0 then tiers[#tiers + 1] = names end
        end
        if #tiers > 0 then entry.priorities = { { heroTalent = "All", context = "General", stats = tiers } } end
      end

      local rot = sd.rotation and sd.rotation[WILDCARD]
      if rot then
        local out = {}
        for playstyle, r in pairs(rot) do
          out[#out + 1] = { heroTalent = "All", context = ROTATION_CTX[playstyle] or playstyle, steps = r.steps }
        end
        if #out > 0 then entry.rotation = out end
      end

      local tal = sd.talents and sd.talents[WILDCARD]
      if tal then
        local out = {}
        for context, builds in pairs(tal) do
          for _, b in ipairs(builds) do
            out[#out + 1] = { heroTalent = "All", context = TALENT_CTX[context] or context, buildLabel = b.label, exportString = b.export }
          end
        end
        if #out > 0 then entry.talents = out end
      end

      ClassCodexData[class][spec] = entry
    end
  end
end

-- my talent context key -> the u.gg context descriptor UggContext.lua consumes.
local function describeUggContext(ctxKey, ref)
  if ctxKey == "mplus" then return "mythic-plus:high-keys:all-dungeons", "mythic-plus", nil, "all-dungeons", "All Dungeons", true end
  if ctxKey == "raid" then return "raid:mythic:all-bosses", "raid", "mythic", "all-bosses", "All Bosses", true end
  local bucket, id = ctxKey:match("^(%a+):(%d+)$")
  local enc = ref and ref.encounters
  if bucket == "mplus" then
    local label = (enc and enc.dungeons and enc.dungeons[tonumber(id)]) or ("Dungeon " .. id)
    return "mythic-plus:high-keys:ugg-" .. id, "mythic-plus", nil, "ugg-" .. id, label, false
  elseif bucket == "raid" then
    local label = (enc and enc.bosses and enc.bosses[tonumber(id)]) or ("Boss " .. id)
    return "raid:mythic:ugg-" .. id, "raid", "mythic", "ugg-" .. id, label, false
  end
  return nil
end

-- Encoded string passes through; a raw node list (contains '#') is encoded in
-- game against the ACTIVE spec's loaded tree, else skipped.
local function resolveExport(export, canEncode)
  if not export then return nil end
  if not export:find("#", 1, true) then return export end
  if canEncode and ns.EncodeUggTalents then
    local ok, s = pcall(ns.EncodeUggTalents, export)
    if ok and s and s ~= "" then return s end
  end
  return nil
end

-- ClassCodexUggBuilds[c][s] = { contexts, contextOrder } from u.gg talents.
local function buildUggBuilds(ugg, ref)
  ClassCodexUggBuilds = ClassCodexUggBuilds or {}
  local activeClass, activeSpec
  if ns.GetClassAndSpec then activeClass, activeSpec = ns.GetClassAndSpec() end
  for class, specs in pairs(ugg.data) do
    ClassCodexUggBuilds[class] = ClassCodexUggBuilds[class] or {}
    for spec, sd in pairs(specs) do
      if sd.talents then
        local canEncode = (class == activeClass and spec == activeSpec)
        local contexts, overview, encounters = {}, {}, {}
        for heroSlug, byContext in pairs(sd.talents) do
          local heroDisplay = (ref and ref.heroNames and ref.heroNames[heroSlug]) or heroSlug
          for ctxKey, builds in pairs(byContext) do
            local uggKey, zoneType, difficulty, encounter, label, isOverview = describeUggContext(ctxKey, ref)
            if uggKey then
              local ctx = contexts[uggKey]
              if not ctx then
                ctx = { zoneType = zoneType, difficulty = difficulty, encounter = encounter, encounterLabel = label, builds = {} }
                contexts[uggKey] = ctx
                if isOverview then overview[#overview + 1] = uggKey else encounters[#encounters + 1] = uggKey end
              end
              for _, b in ipairs(builds) do
                local export = resolveExport(b.export, canEncode)
                if export then ctx.builds[#ctx.builds + 1] = { exportString = export, heroTalent = heroDisplay, pickrate = b.pickrate } end
              end
            end
          end
        end
        for k, ctx in pairs(contexts) do if #ctx.builds == 0 then contexts[k] = nil end end
        local order = {}
        for _, k in ipairs(overview) do if contexts[k] then order[#order + 1] = k end end
        for _, k in ipairs(encounters) do if contexts[k] then order[#order + 1] = k end end
        ClassCodexUggBuilds[class][spec] = next(contexts) and { contexts = contexts, contextOrder = order } or nil
      end
    end
  end
  if ns.RebuildUggLookups then ns.RebuildUggLookups() end
end

local function rebuild()
  local src = ClassCodexSource
  if not src then return end
  if src.icyveins then buildClassCodexData(src.icyveins) end
  if src.ugg then buildUggBuilds(src.ugg, ClassCodexReference) end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED") -- re-encode raw talent builds for the newly-active spec
f:SetScript("OnEvent", rebuild)
