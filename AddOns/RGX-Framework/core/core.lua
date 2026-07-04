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

RGX.version = GetAddOnMetadataCompat(addonName, "Version") or "1.0.0"
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

    return self.modules[normalizedName] or ResolveModuleAlias(self, normalizedName)
end

function RGX:RequireModule(name)
    local module = self:GetModule(name)
    if not module then
        local msg = string.format("[RGX] RequireModule: '%s' not loaded", tostring(name))
        if type(_G.geterrorhandler) == "function" then
            _G.geterrorhandler()(msg)
        else
            print("|cFFFF4444" .. msg .. "|r")
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
    print("|cFF00FF00[RGX]|r", ...)
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

-- ── RGX.Addon — one call spins up an addon ────────────────────────────────────

function RGX.Addon(name, opts)
    if type(name) ~= "string" or name == "" then return end
    opts = opts or {}
    local RGX = _G.RGXFramework

    local addon = opts.table or {}
    addon.name = name
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

    function addon:After(...)
        return RGX:After(...)
    end

    function addon:Every(...)
        return RGX:Every(...)
    end

    function addon:CancelTimer(...)
        return RGX:CancelTimer(...)
    end

    -- Slash — register at file scope, no ADDON_LOADED needed
    if opts.slash then
        local cmds = type(opts.slash) == "table" and opts.slash or { opts.slash }
        for _, cmd in ipairs(cmds) do
            RGX:RegisterSlashCommand(cmd, function(msg)
                if addon.panel then addon.panel:Open() return end
                addon:Print(cmd .. " v?" )
            end, name:upper())
        end
    end

    -- Minimap — true uses default icon, string uses custom path
    if opts.minimap then
        local icon = type(opts.minimap) == "string" and opts.minimap or "Interface\\Icons\\inv_misc_questionmark"
        local MM = RGX:GetMinimap()
        if MM then MM:Create({ name = name, icon = icon }) end
    end

    -- Database + options deferred to ADDON_LOADED
    RGX:RegisterEvent("ADDON_LOADED", function(_, loaded)
        if loaded ~= name then return end

        if opts.db ~= nil then
            local defaults = type(opts.db) == "table" and opts.db or {}
            local dbName = opts.dbName or (name .. "DB")
            if not addon.db then
                addon.db = RGX:NewDatabase(dbName, defaults, { global = opts.global, onSwitch = opts.onSwitch })
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
                                        UI:CreateSlider(frame, { key = ctrl.slider, label = ctrl.label or ctrl.slider:gsub("^%l", string.upper), storage = addon.db, min = ctrl.min or 0, max = ctrl.max or 100, step = ctrl.step or 1 })
                                    elseif type(ctrl.dropdown) == "string" and Drops then
                                        local items = {}
                                        for _, v in ipairs(ctrl.items or {}) do items[#items+1] = { text = tostring(v), value = v } end
                                        Drops:CreateNestedDropdown(frame, { label = ctrl.label or ctrl.dropdown:gsub("^%l", string.upper), items = items, width = ctrl.width or 260, onChange = function(v) addon.db[ctrl.dropdown] = v end })
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
                addon.panel = UI:CreateOptionsPanel({ addonName = name, title = opts.title or name, tabs = tabs })
            end -- UI check
        end -- addon.db check

        if opts.welcome then addon:Print(opts.welcome) end
        if opts.onInit then opts.onInit(addon) end
        RGX:UnregisterEvent("ADDON_LOADED", name .. "_RGXAddon")
    end, name .. "_RGXAddon")

    return addon
end

-- Global entry point per the Simplicity Contract (docs/DECLARATIVE-DSL.md):
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
