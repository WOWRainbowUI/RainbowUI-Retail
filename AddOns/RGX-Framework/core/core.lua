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

    module.name = module.name or normalizedName
    module.framework = self
    module.available = true

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
        if type(_G.geterrorhandler) == "function" then
            _G.geterrorhandler()(msg)
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
function RGX:GetPetBattles()   return self:GetModule("petbattles")   end
function RGX:GetSharedMedia()  return self:GetModule("sharedmedia")  end
function RGX:GetDesign()       return self:GetModule("design")       end
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

function RGX.Addon(name, opts)
    if type(name) ~= "string" or name == "" then return end
    if opts == nil then
        opts = {}
    elseif type(opts) ~= "table" then
        error("RGXAddon: options must be a table", 2)
    end
    local RGX = _G.RGXFramework
    local declarativeEvery = CompileDeclarativeEvery(opts.every)

    if RGX._addons and RGX._addons[name] then
        error("RGXAddon: addon '" .. name .. "' is already registered", 2)
    end
    if opts.table ~= nil and type(opts.table) ~= "table" then
        error("RGXAddon: 'table' must be a table", 2)
    end

    local addon = opts.table or {}
    addon.name = name
    RGX._addons = RGX._addons or {}
    RGX._addons[name] = addon
    addon._rgxEventIds = addon._rgxEventIds or {}
    addon._rgxUnitEventIds = addon._rgxUnitEventIds or {}
    addon._rgxMessageIds = addon._rgxMessageIds or {}

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
            addon:Print((cmds[1] or "?") .. " v?")
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
                mmOpts.storage = mmOpts.storage or addon.db
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
            local Drops = RGX:GetDropdowns()
            if UI and UI.CreateOptionsPanel then
                local tabs = {}
                for tabName, controls in pairs(opts.options) do
                    tabs[#tabs + 1] = {
                        text = tabName,
                        content = function(frame)
                            for _, ctrl in ipairs(controls) do
                                if type(ctrl) == "table" then
                                    if type(ctrl.toggle) == "string" then
                                        UI:CreateToggle(frame, { key = ctrl.toggle, label = ctrl.label or ctrl.toggle:gsub("^%l", string.upper), storage = addon.db, default = ctrl.default })
                                    elseif type(ctrl.slider) == "string" then
                                        UI:CreateSlider(frame, { key = ctrl.slider, label = ctrl.label or ctrl.slider:gsub("^%l", string.upper), storage = addon.db, min = ctrl.min or 0, max = ctrl.max or 100, step = ctrl.step or 1, suffix = ctrl.suffix, progress = ctrl.progress })
                                    elseif type(ctrl.color) == "string" then
                                        UI:CreateColorPicker(frame, { key = ctrl.color, label = ctrl.label or ctrl.color:gsub("^%l", string.upper), storage = addon.db, default = ctrl.default or addon.db[ctrl.color], onChange = function(r, g, b) addon.db[ctrl.color] = { r = r, g = g, b = b } end })
                                    elseif type(ctrl.dropdown) == "string" and Drops then
                                        local items = {}
                                        for _, v in ipairs(ctrl.items or {}) do items[#items+1] = { text = tostring(v), value = v } end
                                        -- value restores the saved selection visually; without it the
                                        -- dropdown saved but always reopened blank -- the exact
                                        -- save-without-restore bug class this framework exists to kill.
                                        Drops:CreateNestedDropdown(frame, { label = ctrl.label or ctrl.dropdown:gsub("^%l", string.upper), items = items, width = ctrl.width or 260, value = addon.db[ctrl.dropdown], onChange = function(v) addon.db[ctrl.dropdown] = v end })
                                    elseif type(ctrl.button) == "string" and type(ctrl.action) == "function" then
                                        UI:CreateButton(frame, ctrl.button, ctrl.width or 120, ctrl.height or 22, ctrl.action)
                                    elseif type(ctrl.section) == "string" then
                                        UI:CreateSection(frame, ctrl.section)
                                    end
                                end
                            end
                        end,
                    }
                end
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
                addon.panel = UI:CreateOptionsPanel({
                    addonName = name,
                    title     = opts.title or name,
                    tabs      = tabs,
                    width     = pick(opts.panelWidth,  geom.width),
                    height    = pick(opts.panelHeight, geom.height),
                    maxPerRow = pick(opts.maxPerRow,   geom.maxPerRow),
                })
            end -- UI check
        end -- addon.db check

        BindDeclarativeEvery(addon, declarativeEvery)
        -- Declarative welcome is a login message: it uses the framework chat
        -- prefix and obeys the global login-message preference (/rgx login off).
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
