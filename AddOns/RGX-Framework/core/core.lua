--[[
    RGX-Framework - Core Library

    A modular framework providing fonts, colors, textures, events, timers,
    and UI controls for WoW addons.

    Quick start:
        ## RequiredDeps: RGX-Framework

        local RGX = _G.RGXFramework

        -- Module shortcuts
        local Fonts      = RGX:GetFonts()
        local Colors     = RGX:GetColors()
        local Textures   = RGX:GetTextures()
        local Drops      = RGX:GetDropdowns()
        local UI         = RGX:GetUI()
        local PetBattles = RGX:GetPetBattles()

        -- Pet battle callbacks
        PetBattles:OnLevelUp(function(petID, petSlot, newLevel, oldLevel) end)
        PetBattles:OnCapture(function(petID, petSlot) end)
        PetBattles:OnBattleStart(function() end)
        PetBattles:OnBattleEnd(function() end)

        -- Generic getter (normalizes name)
        local mod = RGX:GetModule("fonts")

        -- Hard dependency (logs error if missing)
        local mod = RGX:RequireModule("fonts")

        -- Events / messages
        RGX:RegisterEvent("PLAYER_LOGIN", myHandler)
        RGX:SendMessage("MY_ADDON_READY", data)

        -- Timers
        RGX:After(1.0, function() print("one second later") end)
        local ticker = RGX:Every(5.0, myCallback)
        RGX:CancelTimer(ticker)

        -- Slash commands
        RGX:RegisterSlashCommand("mycommand", function(msg) end, "MYADDON")
--]]

local addonName, RGX = ...
_G.RGXFramework = RGX

local function GetAddOnMetadataCompat(name, field)
    if C_AddOns and type(C_AddOns.GetAddOnMetadata) == "function" then
        return C_AddOns.GetAddOnMetadata(name, field)
    end

    if type(GetAddOnMetadata) == "function" then
        return GetAddOnMetadata(name, field)
    end

    return nil
end

local function NormalizeModuleName(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    return string.lower(name)
end

RGX.version = GetAddOnMetadataCompat(addonName, "Version") or "unknown"
RGX.debugMode = false

-- Contract compatibility handshake. Contract formats are additive: a
-- framework that speaks format N also speaks every lower format. This
-- constant is independent of the framework version so the contract can
-- evolve without renumbering releases.
RGX.CONTRACT_FORMAT_VERSION = 1

-- Parse a dotted version string ("2.9.0", "v2.9", "2.10.0-beta.1").
-- Returns the numeric segments plus an optional prerelease tail, or nil
-- when the string does not start with a numeric segment.
local function ParseVersion(value)
    if type(value) ~= "string" then
        return nil
    end

    local text = (value:gsub("^%s+", "")):gsub("%s+$", "")
    text = (text:gsub("^v", ""))

    local segments = {}
    local prerelease = nil
    local index = 1
    while index <= #text do
        local number = text:match("^%d+", index)
        if number then
            segments[#segments + 1] = tonumber(number)
            index = index + #number
        elseif text:sub(index, index) == "." and #segments > 0 then
            index = index + 1
            if not text:match("^%d", index) then
                local tail = text:sub(index)
                if tail ~= "" then
                    prerelease = tail
                end
                break
            end
        else
            if #segments == 0 then
                return nil
            end
            prerelease = text:sub(index)
            break
        end
    end

    if #segments == 0 then
        return nil
    end

    return segments, prerelease
end

-- Compare two dotted version strings. Returns -1, 0, or 1; nil when
-- either side cannot be parsed. Missing segments count as zero
-- ("2.9" == "2.9.0") and a prerelease tail sorts before the same
-- version without one.
function RGX:CompareVersions(left, right)
    local leftSegments, leftPrerelease = ParseVersion(left)
    local rightSegments, rightPrerelease = ParseVersion(right)
    if not leftSegments or not rightSegments then
        return nil
    end

    local count = math.max(#leftSegments, #rightSegments)
    for index = 1, count do
        local leftValue = leftSegments[index] or 0
        local rightValue = rightSegments[index] or 0
        if leftValue < rightValue then return -1 end
        if leftValue > rightValue then return 1 end
    end

    if leftPrerelease and not rightPrerelease then return -1 end
    if rightPrerelease and not leftPrerelease then return 1 end
    if leftPrerelease and rightPrerelease then
        if leftPrerelease < rightPrerelease then return -1 end
        if leftPrerelease > rightPrerelease then return 1 end
    end

    return 0
end

-- Additive capability query: can this framework consume a consumer
-- authored against the given contract format? Non-integer, sub-1, or
-- unknown values are simply unsupported -- the query never errors.
function RGX:SupportsContract(formatVersion)
    return type(formatVersion) == "number"
        and formatVersion >= 1
        and math.floor(formatVersion) == formatVersion
        and formatVersion <= self.CONTRACT_FORMAT_VERSION
end

-- Compatibility guard for generated consumers. Returns true when the
-- installed framework speaks the requested contract format and meets the
-- optional framework floor; otherwise errors with one clear message so an
-- old framework fails loudly instead of silently ignoring behavior.
function RGX:RequireContract(addonName, formatVersion, minFrameworkVersion)
    local consumer = tostring(addonName or "RGX consumer")
    if type(formatVersion) ~= "number"
        or math.floor(formatVersion) ~= formatVersion
        or formatVersion < 1 then
        error(string.format(
            "%s requested an invalid RGX contract format (%s).",
            consumer, tostring(formatVersion)), 2)
    end

    if formatVersion > self.CONTRACT_FORMAT_VERSION then
        error(string.format(
            "%s requires RGX contract format %d; this RGX-Framework supports format %d. Update RGX-Framework.",
            consumer, formatVersion, self.CONTRACT_FORMAT_VERSION), 2)
    end

    if minFrameworkVersion ~= nil then
        local comparison = self:CompareVersions(self.version, minFrameworkVersion)
        if comparison == nil then
            error(string.format(
                "%s requires RGX-Framework %s or newer; the installed RGX-Framework reports version %s and could not be verified. Update RGX-Framework.",
                consumer, tostring(minFrameworkVersion), tostring(self.version)), 2)
        elseif comparison < 0 then
            error(string.format(
                "%s requires RGX-Framework %s or newer; installed RGX-Framework is %s. Update RGX-Framework.",
                consumer, tostring(minFrameworkVersion), tostring(self.version)), 2)
        end
    end

    return true
end

-- Module storage
RGX.modules = {}
RGX.loadedModules = {}
RGX.moduleAliases = {
  fonts = "RGXFonts",
  colors = "RGXColors",
  textures = "RGXTextures",
  dropdowns = "RGXDropdowns",
  ui = "RGXUI",
  colorpicker = "RGXColorPicker",
  minimap = "RGXMinimap",
  petbattles = "RGXPetBattles",
  sharedmedia = "RGXSharedMedia",
  design = "RGXDesign",
  display = "RGXDisplay",
  combat = "RGXCombat",
  reputation = "RGXReputation",
  databroker = "RGXDataBroker",
  sound = "RGXSound",
  collectibles = "RGXCollectibles",
  loot = "RGXLoot",
  achievement = "RGXAchievement",
  levelup = "RGXLevelUp",
  quest = "RGXQuest",
  honor = "RGXHonor",
  delves = "RGXDelves",
  housing = "RGXHousing",
  tradingpost = "RGXTradingPost",
  prey = "RGXPrey",
  timers = "RGXTimers",
  worldmap = "RGXWorldMap",
}

local function ResolveModuleAlias(self, normalizedName)
    local alias = self.moduleAliases and self.moduleAliases[normalizedName]
    if type(alias) ~= "string" then
        return nil
    end

    local module = rawget(_G, alias)
    if type(module) ~= "table" then
        return nil
    end

    self.modules[normalizedName] = module
    self.loadedModules[normalizedName] = true
    return module
end

-- Module management
function RGX:RegisterModule(name, module, opts)
    local normalizedName = NormalizeModuleName(name)
    if not normalizedName then return false end
    if type(module) ~= "table" then return false end
    if self.modules[normalizedName] and self.modules[normalizedName] ~= module then return false end
    -- Flavor gate is enforced centrally: even a module that forgot its own
    -- guard cannot register on a client that lacks its driving API.
    if type(self.ModuleSupported) == "function" and not self:ModuleSupported(normalizedName) then
        if type(self.Debug) == "function" then
            self:Debug("[RGX] Refused module registration on unsupported client: " .. normalizedName)
        end
        return false
    end

    module.name = module.name or normalizedName
    module.framework = self
    module.available = true
    -- Architectural metadata (additive; runtime semantics unchanged).
    -- category: "library" (reusable framework capability) or "game"
    -- depends: module names this module requires; recorded for the checker
    -- stability: stable | experimental | deprecated | internal
    -- flavors: flavor names the module is allowed on (nil/absent = all)
    if type(opts) == "table" then
        module.category = opts.category or module.category
        module.depends = opts.depends or module.depends
        module.stability = opts.stability or module.stability or "stable"
        if opts.flavors ~= nil then
            self.moduleFlavorMap = self.moduleFlavorMap or {}
            self.moduleFlavorMap[normalizedName] = opts.flavors
        end
    end

    self.modules[normalizedName] = module
    self.loadedModules[normalizedName] = true

    local globalAlias = type(opts) == "table" and opts.global or self.moduleAliases[normalizedName]
    if type(globalAlias) == "string" and rawget(_G, globalAlias) == nil then
        _G[globalAlias] = module
    end

    return true
end

function RGX:GetModule(name)
    local normalizedName = NormalizeModuleName(name)
    if not normalizedName then
        return nil
    end

    local module = self.modules[normalizedName] or ResolveModuleAlias(self, normalizedName)
    if module and type(self.IsModuleAvailable) == "function" and not self:IsModuleAvailable(normalizedName) then
        return nil
    end
    return module
end

function RGX:RequireModule(name)
    local module = self:GetModule(name)
    if not module then
        local msg = string.format("[RGX] RequireModule: '%s' not loaded", tostring(name))
        -- A throwing error-display addon must not turn a missing-module
        -- report into an error in the caller's frame.
        if type(_G.geterrorhandler) == "function" then
            pcall(_G.geterrorhandler(), msg)
        else
            self:Error(msg)
        end
    end
    return module
end

-- Module shortcuts
function RGX:GetFonts()       return self:GetModule("fonts")       end
function RGX:GetColors()      return self:GetModule("colors")      end
function RGX:GetTextures()    return self:GetModule("textures")    end
function RGX:GetDropdowns()   return self:GetModule("dropdowns")   end
function RGX:GetUI()          return self:GetModule("ui")          end
function RGX:GetColorPicker() return self:GetModule("colorpicker") end
function RGX:GetMinimap()      return self:GetModule("minimap")      end
function RGX:GetTimers()       return self:GetModule("timers")       end
function RGX:GetPetBattles()   return self:GetModule("petbattles")   end
function RGX:GetSharedMedia()  return self:GetModule("sharedmedia")  end
function RGX:GetDesign()       return self:GetModule("design")       end
function RGX:GetDisplay()      return self:GetModule("display")      end
function RGX:GetCombat()       return self:GetModule("combat")       end
function RGX:GetReputation()   return self:GetModule("reputation")   end
function RGX:GetAuras()        return self:GetModule("auras")        end
function RGX:GetTooltip()      return self:GetModule("tooltip")      end
function RGX:GetDataBroker() return self:GetModule("databroker") end
function RGX:GetSound()        return self:GetModule("sound")        end
function RGX:GetCollectibles() return self:GetModule("collectibles") end
function RGX:GetLoot()         return self:GetModule("loot")         end
function RGX:GetAchievement()  return self:GetModule("achievement")  end
function RGX:GetLevelUp()      return self:GetModule("levelup")      end
function RGX:GetQuest()        return self:GetModule("quest")        end
function RGX:GetHonor()        return self:GetModule("honor")        end
function RGX:GetDelves()       return self:GetModule("delves")       end
function RGX:GetHousing()      return self:GetModule("housing")      end
function RGX:GetTradingPost()  return self:GetModule("tradingpost")  end
function RGX:GetPrey()         return self:GetModule("prey")         end
function RGX:GetWorldMap()     return self:GetModule("worldmap")   end

-- Addon registry -- every RGX.Addon is recorded here so other files (or the
-- same addon's advanced-pattern files) can reach its object and panel by name.
RGX._addons = RGX._addons or {}
function RGX:GetAddon(name) return self._addons and self._addons[name] end

-- Extra options tabs registered against an addon *by name*, before its panel is
-- built. The declarative panel builder in RGX.Addon appends these after the
-- addon's own `options` tabs, so a second file (e.g. a bundled dev/test suite)
-- can extend the same panel instead of standing up a separate window.
--   RGX:AddOptionsTab("RGX-Hello", "Colors", function(frame) ... end,
--                     { maxPerRow = 5, width = 820, height = 640 })
-- The optional 4th arg carries panel-geometry hints; the largest hint across
-- all registrations wins, so the host addon's minimal example need not know the
-- suite exists. Must be called before the addon's ADDON_LOADED (i.e. at file
-- parse time) to be picked up -- panels are not rebuilt after creation.
RGX._pendingTabs = RGX._pendingTabs or {}
RGX._pendingPanelOpts = RGX._pendingPanelOpts or {}
function RGX:AddOptionsTab(addonName, text, builder, geom)
    if type(addonName) ~= "string" or type(text) ~= "string" or type(builder) ~= "function" then return end
    self._pendingTabs[addonName] = self._pendingTabs[addonName] or {}
    table.insert(self._pendingTabs[addonName], { text = text, content = builder })
    if type(geom) == "table" then
        local g = self._pendingPanelOpts[addonName] or {}
        g.width     = math.max(g.width     or 0, geom.width     or 0)
        g.height    = math.max(g.height    or 0, geom.height    or 0)
        g.maxPerRow = math.max(g.maxPerRow or 0, geom.maxPerRow or 0)
        self._pendingPanelOpts[addonName] = g
    end
end

function RGX:SetTheme(config)
    local Design = self:GetDesign()
    if Design and type(Design.SetTheme) == "function" then
        Design:SetTheme(config)
    end
end

-- Dismiss the shared color picker popup without firing its callback.
-- Tab and page switches call this so a popup never outlives its opener page.
function RGX:DismissColorPicker()
    local ok, CP = pcall(self.GetColorPicker, self)
    if ok and CP and type(CP.Cancel) == "function" then
        pcall(CP.Cancel, CP)
    end
end

function RGX:SetHighlightColor(color, accent)
    local Design = self:GetDesign()
    if Design and type(Design.SetHighlightColor) == "function" then
        Design:SetHighlightColor(color, accent)
    end
end

-- One-call sound playback: looks up path from RGXSharedMedia and plays it.
-- RGX:PlaySound("mysoundpack:Kill Shot")
-- RGX:PlaySound("mysoundpack:Kill Shot", "SFX")
function RGX:PlaySound(id, channel)
    local SM = self:GetModule("sharedmedia")
    if not SM then return false end
    local path = SM:GetPath("sound", id)
    if not path then return false end
    return PlaySoundFile(path, channel or "Master")
end

function RGX:IsModuleLoaded(name)
    local normalizedName = NormalizeModuleName(name)
    if not normalizedName then
        return false
    end

    return self.loadedModules[normalizedName] == true or ResolveModuleAlias(self, normalizedName) ~= nil
end

function RGX:GetLoadedModules()
    local list = {}
    for name in pairs(self.loadedModules) do
        table.insert(list, name)
    end
    table.sort(list)
    return list
end

-- Object composition: copy all fields from source mixins into target
function RGX:Mixin(target, ...)
    for i = 1, select("#", ...) do
        local source = select(i, ...)
        if type(source) == "table" then
            for k, v in pairs(source) do
                target[k] = v
            end
        end
    end
    return target
end

-- Utilities
function RGX:Debug(...)
    if not self.debugMode then return end
    print(self:CreateChatPrefix({ tagColor = "00ff00" }), ...)
end

function RGX:CopyTable(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for k, v in next, orig, nil do
            copy[self:CopyTable(k)] = self:CopyTable(v)
        end
        setmetatable(copy, self:CopyTable(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function RGX:Clamp(val, min, max)
    return math.min(math.max(val, min), max)
end

function RGX:Lerp(a, b, t)
    t = self:Clamp(tonumber(t) or 0, 0, 1)
    return a + (b - a) * t
end

-- Table helpers
function RGX:TableCount(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

local function IsValidTimerName(name)
    if type(name) ~= "string" or #name == 0 then return false end
    local hasNonSpace = false
    for index = 1, #name do
        local byte = string.byte(name, index)
        if byte < 32 or byte == 127 then return false end
        if byte ~= 32 then hasNonSpace = true end
    end
    return hasNonSpace
end

local function CompileDeclarativeEvery(timers)
    if timers == nil then return nil end
    if type(timers) ~= "table" then
        error("RGXAddon: 'every' must be a table of name = { seconds, function } entries", 3)
    end

    local compiled = {}
    for timerName, definition in pairs(timers) do
        if not IsValidTimerName(timerName) then
            error("RGXAddon: every 'every' timer must have a printable non-empty name", 3)
        end
        if type(definition) ~= "table" then
            error("RGXAddon: 'every." .. timerName .. "' must be { seconds, function }", 3)
        end
        for key in pairs(definition) do
            if key ~= 1 and key ~= 2 then
                error("RGXAddon: 'every." .. timerName .. "' must contain exactly seconds and handler", 3)
            end
        end

        local seconds = rawget(definition, 1)
        local handler = rawget(definition, 2)
        if type(seconds) ~= "number" or seconds ~= seconds or seconds <= 0 or seconds >= math.huge then
            error("RGXAddon: interval for 'every." .. timerName .. "' must be a finite number greater than zero", 3)
        end
        if type(handler) ~= "function" then
            error("RGXAddon: handler for 'every." .. timerName .. "' must be a function", 3)
        end

        compiled[#compiled + 1] = {
            name = timerName,
            seconds = seconds,
            handler = handler,
        }
    end

    table.sort(compiled, function(a, b) return a.name < b.name end)
    return compiled
end

local function ResolveCompatPath(path)
    if type(path) ~= "string" or path == "" then return nil end
    if path:sub(1, 1) == "." or path:sub(-1) == "." or path:find("%.%.") then return nil end
    local node = _G
    for segment in path:gmatch("[^%.]+") do
        if type(node) ~= "table" then return nil end
        node = node[segment]
    end
    if type(node) == "function" then return node end
    return nil
end

-- Declarative compatibility shims: each entry names one or more global API
-- paths (for example "C_GossipInfo.GetAvailableQuests" or
-- "GetGossipAvailableQuests"); the first callable path on the current client
-- wins, and an optional normalize function receives the raw return values.
-- A declaration whose paths are all absent fails before the addon registers,
-- so the wrong-API-for-expansion class cannot reach runtime.
local function CompileDeclarativeCompat(declarations)
    if declarations == nil then return nil end
    if type(declarations) ~= "table" then
        error("RGXAddon: 'compat' must be a table of name = path declarations", 3)
    end

    local compiled = {}
    for name, declaration in pairs(declarations) do
        if type(name) ~= "string" or not name:match("^[%a_][%a%d_]*$") then
            error("RGXAddon: compat name must be a non-empty identifier", 3)
        end

        local paths
        local normalize
        if type(declaration) == "string" then
            paths = { declaration }
        elseif type(declaration) == "table" then
            paths = {}
            if type(declaration.prefer) == "string" then
                paths[#paths + 1] = declaration.prefer
                if type(declaration.fallback) == "string" then
                    paths[#paths + 1] = declaration.fallback
                end
            elseif type(rawget(declaration, 1)) == "string" then
                for index = 1, #declaration do
                    if type(declaration[index]) ~= "string" then
                        error("RGXAddon: 'compat." .. name .. "' path list must contain only strings", 3)
                    end
                    paths[#paths + 1] = declaration[index]
                end
            else
                error("RGXAddon: 'compat." .. name .. "' must declare at least one API path", 3)
            end
            normalize = declaration.normalize
        else
            error("RGXAddon: 'compat." .. name .. "' must be a path, path list, or prefer/fallback table", 3)
        end

        if #paths == 0 then
            error("RGXAddon: 'compat." .. name .. "' must declare at least one API path", 3)
        end
        if normalize ~= nil and type(normalize) ~= "function" then
            error("RGXAddon: normalize for 'compat." .. name .. "' must be a function", 3)
        end

        local selected
        for index = 1, #paths do
            selected = ResolveCompatPath(paths[index])
            if selected then break end
        end
        if not selected then
            error("RGXAddon: 'compat." .. name .. "' has no callable path on this client", 3)
        end

        if normalize then
            compiled[name] = function(...)
                return normalize(selected(...))
            end
        else
            compiled[name] = function(...)
                return selected(...)
            end
        end
    end
    return compiled
end

local function BindDeclarativeEvery(addon, timers)
    if not timers then return end

    -- UpdateTimers walks newest-to-oldest, so reverse registration preserves
    -- lexical name order when timers in this declaration become due together.
    for index = #timers, 1, -1 do
        local definition = timers[index]
        local timer = addon:Every(definition.seconds, function(timerRef)
            return definition.handler(addon, timerRef)
        end, addon.name .. ":every:" .. definition.name)

        timer.name = definition.name
        timer.declarativeName = definition.name
    end
end

-- ── RGX.Addon — one call spins up an addon ────────────────────────────────────

-- Compile before registering resources; malformed strings must not silently
-- disappear when a lazy tab is first opened. Tooling mirrors this grammar.
local function ParseInlineControl(raw, owner)
    raw = raw:gsub("%s+$", "")
    local function invalid()
        error("RGXAddon: invalid control string: " .. tostring(raw), 3)
    end
    local kind, rest = raw:match("^(%l[%l_]*)%s+(.+)$")
    if not kind then return invalid() end
    if kind == "header" or kind == "label" then
        local text = rest:match("^'([^']*)'%s*$")
        if not text then return invalid() end
        return { section = text }
    elseif kind == "button" then
        local text, method = rest:match("^'([^']*)'%s+([%a_][%w_]*)%s*$")
        if not text then return invalid() end
        return { button = text, action = function()
            local fn = owner[method]
            if type(fn) ~= "function" then error("RGXAddon: missing button method '" .. method .. "'") end
            return fn(owner)
        end }
    end
    local core, label = rest:match("^(.-)%s+'([^']*)'%s*$")
    core = core or rest
    if kind == "toggle" or kind == "color" or kind == "font" or kind == "textbox" or kind == "panel_alpha" then
        local key = core:match("^([^%s'\"]+)$")
        if not key then return invalid() end
        return { [kind] = key, label = label }
    elseif kind == "slider" then
        local key, range, step = core:match("^([^%s'\"]+)%s+(%S+)%s*(%S*)$")
        local low, high
        if range then low, high = range:match("^([+-]?%d*%.?%d+)%-([+-]?%d*%.?%d+)$") end
        low, high = tonumber(low), tonumber(high)
        local increment = step == "" and 1 or tonumber(step)
        if not key or not low or not high or low > high or high >= math.huge or low <= -math.huge
            or not increment or increment <= 0 or increment >= math.huge
            or (step ~= "" and not step:match("^[+-]?%d*%.?%d+$")) then return invalid() end
        return { slider = key, min = low, max = high, step = increment, label = label }
    elseif kind == "dropdown" then
        local key, list = core:match("^([^%s'\"]+)%s+([^%s'\"]+)$")
        if not key or list:sub(1, 1) == "|" or list:sub(-1) == "|" or list:find("||", 1, true) then return invalid() end
        local items = {}
        for value in list:gmatch("[^|]+") do items[#items + 1] = value end
        return { dropdown = key, label = label, items = items }
    end
    return invalid()
end

-- options.columns selects the tab content grid (1-3); anything else is
-- rejected before the addon registers, like every other declaration error.
local function CompileDeclarativeColumns(options)
    if type(options) ~= "table" then return 1 end
    local columns = options.columns
    if columns == nil then return 1 end
    if columns ~= 1 and columns ~= 2 and columns ~= 3 then
        error("RGXAddon: options.columns must be 1, 2, or 3", 3)
    end
    return columns
end

-- Declarative page/card layout: a tab that uses pages contains only page
-- nodes. Each page holds a 1-2 column card grid; each card holds controls.
-- Structural errors (and nested one-line strings) are rejected before the
-- addon registers, mirroring every/options.columns validation.
local function IsDeclarativePageNode(entry)
    return type(entry) == "table" and type(entry.page) == "string"
end

local DECLARATIVE_CONTROL_KINDS = {
    toggle = true, slider = true, panel_alpha = true, textbox = true,
    color = true, font = true, dropdown = true, button = true, section = true,
}

local function ValidateDeclarativeLayoutControls(owner, pageName, cardName, controls, compiledStrings)
    if type(controls) ~= "table" then
        error("RGXAddon: controls for '" .. cardName .. "' on page '" .. pageName .. "' must be a table", 3)
    end
    if #controls == 0 then
        error("RGXAddon: card '" .. cardName .. "' on page '" .. pageName .. "' must contain at least one control", 3)
    end
    for index = 1, #controls do
        local control = controls[index]
        if control == nil then
            error("RGXAddon: control list for card '" .. cardName .. "' on page '" .. pageName
                .. "' has a hole at position " .. index, 3)
        end
        if type(control) == "string" then
            compiledStrings[control] = ParseInlineControl(control, owner)
        elseif type(control) == "table" then
            if type(control.page) == "string" or type(control.card) == "string" then
                error("RGXAddon: pages and cards cannot nest inside '" .. cardName .. "'", 3)
            end
            -- A table control must name exactly one recognized kind. An
            -- empty table or a typo'd key ({ toogle = "x" }) previously
            -- passed validation and then silently rendered nothing.
            local kinds = {}
            for key in pairs(control) do
                if DECLARATIVE_CONTROL_KINDS[key] then
                    kinds[#kinds + 1] = key
                end
            end
            if #kinds == 0 then
                error("RGXAddon: unrecognized control table in card '" .. cardName .. "' on page '"
                    .. pageName .. "'; expected exactly one of toggle, slider, panel_alpha, textbox, "
                    .. "color, font, dropdown, button, section", 3)
            end
            if #kinds > 1 then
                error("RGXAddon: control table in card '" .. cardName .. "' on page '" .. pageName
                    .. "' declares multiple kinds (" .. table.concat(kinds, ", ") .. ")", 3)
            end
            if control.button ~= nil and type(control.action) ~= "function" then
                error("RGXAddon: button control in card '" .. cardName .. "' requires an action function", 3)
            end
        else
            error("RGXAddon: controls for '" .. cardName .. "' must be control tables or strings", 3)
        end
    end
end

local function CompileDeclarativeLayout(options, owner, compiledStrings)
    if type(options) ~= "table" then return end
    for tabName, controls in pairs(options) do
        if tabName ~= "columns" and type(controls) == "table" then
            local pageCount = 0
            for _, entry in ipairs(controls) do
                if IsDeclarativePageNode(entry) then pageCount = pageCount + 1 end
            end
            if pageCount > 0 then
                if options.columns ~= nil then
                    error("RGXAddon: options.columns cannot be combined with page layouts", 3)
                end
                if pageCount ~= #controls then
                    error("RGXAddon: options tab '" .. tostring(tabName) .. "' cannot mix pages with controls", 3)
                end
                for _, page in ipairs(controls) do
                    if page.page == "" then
                        error("RGXAddon: page names must be non-empty", 3)
                    end
                    if page.grid ~= nil and page.grid ~= 1 and page.grid ~= 2 then
                        error("RGXAddon: grid for page '" .. page.page .. "' must be 1 or 2", 3)
                    end
                    if type(page.cards) ~= "table" or #page.cards == 0 then
                        error("RGXAddon: page '" .. page.page .. "' must contain at least one card", 3)
                    end
                    for _, card in ipairs(page.cards) do
                        if type(card) ~= "table" or type(card.card) ~= "string" or card.card == "" then
                            error("RGXAddon: page '" .. page.page .. "' cards must use a non-empty card title", 3)
                        end
                        if card.columns ~= nil and card.columns ~= 1 and card.columns ~= 2 then
                            error("RGXAddon: columns for card '" .. card.card .. "' must be 1 or 2", 3)
                        end
                        ValidateDeclarativeLayoutControls(owner, page.page, card.card, card.controls, compiledStrings)
                    end
                end
            end
        end
    end
end

function RGX.Addon(name, opts)
    if type(name) ~= "string" or name == "" then return end
    if opts == nil then
        opts = {}
    elseif type(opts) ~= "table" then
        error("RGXAddon: options must be a table", 2)
    end
    local RGX = _G.RGXFramework
    local declarativeEvery = CompileDeclarativeEvery(opts.every)
    local declarativeCompat = CompileDeclarativeCompat(opts.compat)
    local declarativeColumns = CompileDeclarativeColumns(opts.options)

    -- options requires db: the panel and every db-bound control need the
    -- database the declarative contract promises. Failing at registration
    -- beats building nothing silently at ADDON_LOADED. A pre-existing table
    -- that already carries its own .db is the imperative escape hatch.
    if type(opts.options) == "table" and opts.db == nil
        and not (type(opts.table) == "table" and type(opts.table.db) == "table") then
        error("RGXAddon: '" .. name .. "' declares options without db; "
            .. "options controls bind to addon.db, so pass db = { ... }", 2)
    end

    if RGX._addons and RGX._addons[name] then
        error("RGXAddon: addon '" .. name .. "' is already registered", 2)
    end
    if opts.table ~= nil and type(opts.table) ~= "table" then
        error("RGXAddon: 'table' must be a table", 2)
    end

    local addon = opts.table or {}
    local compiledOptions
    local compiledStrings = {}
    if type(opts.options) == "table" then
        compiledOptions = {}
        for tab, controls in pairs(opts.options) do
            if tab ~= "columns" then
                if type(controls) ~= "table" then error("RGXAddon: options tab '" .. tostring(tab) .. "' must be a control list", 2) end
                for _, control in ipairs(controls) do
                    if type(control) == "string" then compiledStrings[control] = ParseInlineControl(control, addon) end
                end
                -- Keep the existing table list live: imperative setup may
                -- append/replace table controls before lazy tab construction.
                compiledOptions[tab] = controls
            end
        end
        CompileDeclarativeLayout(opts.options, addon, compiledStrings)
    end
    addon.name = name
    RGX._addons = RGX._addons or {}
    RGX._addons[name] = addon
    addon._rgxEventIds = addon._rgxEventIds or {}
    addon._rgxUnitEventIds = addon._rgxUnitEventIds or {}
    addon._rgxMessageIds = addon._rgxMessageIds or {}
    if declarativeCompat then
        addon.compat = addon.compat or {}
        for name, shim in pairs(declarativeCompat) do
            addon.compat[name] = shim
        end
    end

    -- Brand
    local color = type(opts.brand) == "string" and opts.brand or "58be81"
    local prefix = "|cff" .. color .. "[" .. name:upper() .. "]|r "
    function addon:Print(msg)  print(prefix .. msg) end
    function addon:Warn(msg)   print("|cffffcc00" .. prefix .. msg .. "|r") end
    function addon:Error(msg)  print("|cffff4444" .. prefix .. msg .. "|r") end

    local function defaultScopedId(kind, eventName)
        return string.format("%s_%s_%s", tostring(name), tostring(kind), tostring(eventName))
    end

    function addon:RegisterEvent(eventName, callback, id)
        if type(eventName) ~= "string" or eventName == "" then return false end
        local handlerId = id or defaultScopedId("event", eventName)
        local registered = RGX:RegisterEvent(eventName, callback, handlerId, self)
        if registered then
            self._rgxEventIds[eventName] = self._rgxEventIds[eventName] or {}
            self._rgxEventIds[eventName][handlerId] = true
        end
        return registered
    end

    function addon:UnregisterEvent(eventName, id)
        if type(eventName) ~= "string" or eventName == "" then return false end
        if id then
            local removed = RGX:UnregisterEvent(eventName, id)
            if self._rgxEventIds[eventName] then
                self._rgxEventIds[eventName][id] = nil
                if not next(self._rgxEventIds[eventName]) then
                    self._rgxEventIds[eventName] = nil
                end
            end
            return removed
        end
        local ids = self._rgxEventIds[eventName]
        if not ids then return false end
        local removed = false
        for handlerId in pairs(ids) do
            if RGX:UnregisterEvent(eventName, handlerId) then
                removed = true
            end
        end
        self._rgxEventIds[eventName] = nil
        return removed
    end

    function addon:RegisterUnitEvent(eventName, unit, callback, id)
        if type(eventName) ~= "string" or eventName == "" then return false end
        local handlerId = id or defaultScopedId("unit", eventName)
        local registered = RGX:RegisterUnitEvent(eventName, unit, callback, handlerId, self)
        if registered then
            self._rgxUnitEventIds[eventName] = self._rgxUnitEventIds[eventName] or {}
            self._rgxUnitEventIds[eventName][handlerId] = true
        end
        return registered
    end

    function addon:UnregisterUnitEvent(eventName, id)
        if type(eventName) ~= "string" or eventName == "" then return false end
        if id then
            local removed = RGX:UnregisterUnitEvent(eventName, id)
            if self._rgxUnitEventIds[eventName] then
                self._rgxUnitEventIds[eventName][id] = nil
                if not next(self._rgxUnitEventIds[eventName]) then
                    self._rgxUnitEventIds[eventName] = nil
                end
            end
            return removed
        end
        local ids = self._rgxUnitEventIds[eventName]
        if not ids then return false end
        local removed = false
        for handlerId in pairs(ids) do
            if RGX:UnregisterUnitEvent(eventName, handlerId) then
                removed = true
            end
        end
        self._rgxUnitEventIds[eventName] = nil
        return removed
    end

    function addon:RegisterMessage(message, callback, id)
        if type(message) ~= "string" or message == "" then return false end
        local handlerId = id or defaultScopedId("message", message)
        local registered = RGX:RegisterMessage(message, callback, handlerId, self)
        if registered then
            self._rgxMessageIds[message] = self._rgxMessageIds[message] or {}
            self._rgxMessageIds[message][handlerId] = true
        end
        return registered
    end

    function addon:UnregisterMessage(message, id)
        if type(message) ~= "string" or message == "" then return false end
        if id then
            local removed = RGX:UnregisterMessage(message, id)
            if self._rgxMessageIds[message] then
                self._rgxMessageIds[message][id] = nil
                if not next(self._rgxMessageIds[message]) then
                    self._rgxMessageIds[message] = nil
                end
            end
            return removed
        end
        local ids = self._rgxMessageIds[message]
        if not ids then return false end
        local removed = false
        for handlerId in pairs(ids) do
            if RGX:UnregisterMessage(message, handlerId) then
                removed = true
            end
        end
        self._rgxMessageIds[message] = nil
        return removed
    end

    function addon:SendMessage(...)
        return RGX:SendMessage(...)
    end

    addon.Emit = addon.SendMessage

    function addon:After(duration, callback, label)
        local timer = RGX:After(duration, callback, label)
        if timer then timer.owner = self end
        return timer
    end

    function addon:Every(duration, callback, label)
        local timer = RGX:Every(duration, callback, label)
        if timer then timer.owner = self end
        return timer
    end

    function addon:CancelTimer(timer)
        return RGX:CancelTimer(timer)
    end

    -- Slash — register at file scope, no ADDON_LOADED needed
    -- Slash — bare: string or array of aliases, default handler opens the
    -- options panel. Advanced: same table with a `handler` key
    -- (handler(addon, msg)) when opening the panel isn't the right default.
    if opts.slash then
        local cmds = type(opts.slash) == "table" and opts.slash or { opts.slash }
        local customHandler = type(opts.slash) == "table" and type(opts.slash.handler) == "function"
            and opts.slash.handler or nil
        RGX:RegisterSlashCommand(cmds, function(msg)
            if customHandler then customHandler(addon, msg) return end
            if addon.panel then addon.panel:Open() return end
            addon:Print("no options panel is configured; pass a custom handler "
                .. "via slash = { handler = function(addon, msg) ... } }")
        end, name:upper())
    end

    -- Database + options + minimap deferred to ADDON_LOADED
    RGX:RegisterEvent("ADDON_LOADED", function(_, loaded)
        if loaded ~= name then return end

        if opts.db ~= nil then
            local defaults = type(opts.db) == "table" and opts.db or {}
            -- Auto-derived SavedVariables name strips non-identifier characters
            -- ("RGX-Hello" -> RGXHelloDB, matching what rgx_generate_addon
            -- emits); pass dbName to use something else.
            local dbName = opts.dbName or (name:gsub("[^%w_]", "") .. "DB")
            if not addon.db then
                addon.db = RGX:NewDatabase(dbName, defaults, { global = opts.global, onSwitch = opts.onSwitch })
            end
        end

        -- Minimap — bare: true (default icon) or an icon path string. Advanced:
        -- a full MM:Create opts table (tooltip, onRightClick, defaultAngle, ...).
        -- Runs after db creation so the dragged angle persists to addon.db by
        -- default -- creating it earlier silently lost the position on reload.
        if opts.minimap then
            local MM = RGX:GetMinimap()
            if MM then
                local mmOpts = type(opts.minimap) == "table" and opts.minimap or {}
                mmOpts.name = mmOpts.name or name
                mmOpts.icon = mmOpts.icon
                    or (type(opts.minimap) == "string" and opts.minimap)
                    or "Interface\\Icons\\inv_misc_questionmark"
                mmOpts.storage = mmOpts.storage or addon.db or RGX.db
                if not mmOpts.onLeftClick then
                    mmOpts.onLeftClick = function()
                        if addon.panel then addon.panel:Open() end
                    end
                end
                addon.minimapButton = MM:Create(mmOpts)
            end
        end

        if type(opts.options) == "table" and addon.db then
            local UI = RGX:GetUI()
            if UI and UI.CreateOptionsPanel then
                local function resolveControl(control)
                    if type(control) == "string" then
                        return compiledStrings[control] or ParseInlineControl(control, addon)
                    end
                    return control
                end
                local tabs = UI:_BuildAddonOptionTabs(addon, compiledOptions, declarativeColumns, resolveControl)
                -- Append any tabs a second file registered via RGX:AddOptionsTab
                -- (e.g. RGX-Hello's bundled visual-test suite) so they share this
                -- one panel instead of opening a separate window.
                local pend = RGX._pendingTabs and RGX._pendingTabs[name]
                if pend then
                    for _, t in ipairs(pend) do
                        tabs[#tabs + 1] = { text = t.text, content = t.content }
                    end
                end
                local geom = (RGX._pendingPanelOpts and RGX._pendingPanelOpts[name]) or {}
                local function pick(explicit, hint)
                    if explicit then return explicit end
                    if hint and hint > 0 then return hint end
                    return nil
                end
                -- The brand color selected for chat also themes the panel
                -- (tabs, header emphasis) so bare declarative addons get their
                -- brand look without writing theme tables.
                local theme = opts.theme or opts.colors
                if not theme and type(opts.brand) == "string" and #opts.brand == 6 then
                    local r = tonumber(opts.brand:sub(1, 2), 16) / 255
                    local g = tonumber(opts.brand:sub(3, 4), 16) / 255
                    local b = tonumber(opts.brand:sub(5, 6), 16) / 255
                    theme = { primary = { r, g, b } }
                end
                addon.panel = UI:CreateOptionsPanel({
                    addonName = name,
                    title     = opts.title or name,
                    tabs      = tabs,
                    width     = pick(opts.panelWidth,  geom.width),
                    height    = pick(opts.panelHeight, geom.height),
                    maxPerRow = pick(opts.maxPerRow,   geom.maxPerRow),
                    theme     = theme,
                })
                if addon.db.OnProfileChanged then
                    addon.db:OnProfileChanged(function()
                        if addon.panel then
                            addon.panel:InvalidateAllTabs()
                            addon.panel:Refresh()
                        end
                    end)
                end
            end -- UI check
        end -- addon.db check

        BindDeclarativeEvery(addon, declarativeEvery)
        -- Declarative welcome is a login message: it uses the framework chat
        -- prefix and obeys the global login-message preference (/rgxf login off).
        if opts.welcome then RGX:LoginMessage(opts.welcome) end
        if opts.onInit then opts.onInit(addon) end
        RGX:UnregisterEvent("ADDON_LOADED", name .. "_RGXAddon")
    end, name .. "_RGXAddon")

    return addon
end

-- Global entry point per the Simplicity Contract (docs/DECLARATIVE-API.md):
-- line 1 of a consumer addon is the addon — RequiredDeps guarantees this
-- global exists. Supports both call forms:
--   RGXAddon("MyAddon", { ... })
--   RGXAddon "MyAddon" { ... }     -- curried; plain Lua sugar
function _G.RGXAddon(name, opts)
    if opts == nil then
        return function(tbl) return RGX.Addon(name, tbl) end
    end
    return RGX.Addon(name, opts)
end
