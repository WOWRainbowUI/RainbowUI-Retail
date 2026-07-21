local _, ns = ...

-- SourceData — the single seam the UI reads the normalized data through. Instead
-- of per-source legacy globals + adapters, every data accessor resolves against
-- ClassCodexSource[source].data[CLASS][spec][category][hero][context].
--
-- This replaces the reconstruction approach: no rebuilt legacy globals, the UI
-- accessors call these directly. Categories a source lacks simply resolve to nil.

local WILDCARD = "all"

-- The category table for one spec from one source, or nil.
function ns.SourceSpec(source, class, spec)
  local src = ClassCodexSource and ClassCodexSource[source]
  local byClass = src and src.data and src.data[class]
  return byClass and byClass[spec] or nil
end

-- Context resolution: most-specific first (raid:123 -> raid -> all).
local function contextChain(context)
  local chain = { context }
  local sep = context:find(":", 1, true)
  if sep then chain[#chain + 1] = context:sub(1, sep - 1) end
  if context ~= WILDCARD then chain[#chain + 1] = WILDCARD end
  return chain
end
ns.ContextChain = contextChain

-- Resolve a [hero][context] category payload: prefer the given hero then "all",
-- walking the context up to its parent then "all". Returns payload, matchedHero,
-- matchedContext (or nil).
function ns.ResolveCategory(category, hero, context)
  if not category then return nil end
  local heroes = hero == WILDCARD and { WILDCARD } or { hero, WILDCARD }
  for _, ctx in ipairs(contextChain(context)) do
    for _, h in ipairs(heroes) do
      local byContext = category[h]
      if byContext and byContext[ctx] ~= nil then return byContext[ctx], h, ctx end
    end
  end
  return nil
end

-- Convenience: source + class + spec + category + hero + context -> payload.
function ns.SourceValue(source, class, spec, category, hero, context)
  local sd = ns.SourceSpec(source, class, spec)
  return sd and ns.ResolveCategory(sd[category], hero or WILDCARD, context or WILDCARD) or nil
end

-- Whether a source has any data for a spec+category (for source-availability gates).
function ns.SourceHas(source, class, spec, category)
  local sd = ns.SourceSpec(source, class, spec)
  return sd ~= nil and sd[category] ~= nil
end

-- Default read priority. A new db_<source>.lua just works: it's discovered from
-- ClassCodexSource and appended after the known ones, so it's used wherever no
-- higher-priority source has the data (and can be user-selected). No code change
-- needed to add a source — only its db_ file + a TOC line.
local DEFAULT_PRIORITY = { "icyveins", "ugg", "blizzard" }

function ns.Sources()
  local order, seen = {}, {}
  if not ClassCodexSource then return order end
  for _, s in ipairs(DEFAULT_PRIORITY) do
    if ClassCodexSource[s] then order[#order + 1] = s; seen[s] = true end
  end
  for s in pairs(ClassCodexSource) do
    if not seen[s] then order[#order + 1] = s end -- unknown/new source
  end
  return order
end

-- Resolve a value across sources by priority; `prefer` (optional) is tried first.
-- Returns value, source, matchedHero, matchedContext.
function ns.ResolveAny(class, spec, category, hero, context, prefer)
  local function try(source)
    if not source then return nil end
    local v, h, c = ns.SourceValue(source, class, spec, category, hero, context)
    if v ~= nil then return v, source, h, c end
  end
  local v, s, h, c = try(prefer)
  if v ~= nil then return v, s, h, c end
  for _, source in ipairs(ns.Sources()) do
    if source ~= prefer then
      v, s, h, c = try(source)
      if v ~= nil then return v, s, h, c end
    end
  end
end
