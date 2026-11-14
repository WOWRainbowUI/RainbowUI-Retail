-- Run from the addon root with Lua 5.1: lua Tests/Feedback.lua
-- Geometry and provider mocks verify routing and sizing, not in-game visuals.
local unpack = unpack or table.unpack
local modules, loaded, queued = {}, {}, {}
local ns = { ClientCompat = { IsForever = true } }
local MCE = {}
local count = 0
local function check(value, label)
    assert(value, label)
    count = count + 1
end
function wipe(t) for k in pairs(t) do t[k] = nil end end
function CopyTable(t)
    local out = {}
    for k, v in pairs(t) do out[k] = type(v) == "table" and CopyTable(v) or v end
    return out
end
function issecretvalue(value) return type(value) == "table" and value.secret == true end
function canaccessallvalues(value) return not issecretvalue(value) end
function GetBuildInfo() return "1.60.1", "test", "test", 16001 end
function GetTime() return 0 end
function strtrim(s) return s:match("^%s*(.-)%s*$") end
STANDARD_TEXT_FONT = "test"
StaticPopupDialogs = {}
C_Timer = {}
C_AddOns = {
    IsAddOnLoaded = function(name) return loaded[name] == true end,
    GetAddOnMetadata = function() return "test" end,
}
local function Frame(name, parent)
    local f = {name = name, parent = parent, width = 36, height = 36, scripts = {}}
    function f:GetName() return self.name end
    function f:GetParent() return self.parent end
    function f:IsForbidden() return false end
    function f:GetWidth() return self.width end
    function f:GetHeight() return self.height end
    function f:Hide() end
    function f:SetScript(event, fn) self.scripts[event] = fn end
    function f:HookScript(event, fn)
        local old = self.scripts[event]
        self.scripts[event] = function(...) if old then old(...) end; fn(...) end
    end
    function f:CreateFontString() return Frame() end
    function f:SetFont(font, size, flags) self.font, self.size, self.flags = font, size, flags; return true end
    function f:GetFont() return self.font, self.size, self.flags end
    function f:SetText(text) self.text = text end
    function f:GetStringWidth() return #self.text * self.size * 0.6 end
    function f:GetStringHeight() return self.size end
    function f:GetText() error("live countdown must never be inspected") end
    return f
end
function CreateFrame(_, name, parent) return Frame(name, parent) end
UIParent = Frame("UIParent")
function hooksecurefunc() end
function MCE:NewModule(name) local module = {}; modules[name] = module; return module end
function MCE:GetModule(name) return modules[name] end
local locale = setmetatable({}, {__index = function(_, key) return key end})
function LibStub(name, optional)
    if name == "AceAddon-3.0" then return {NewAddon = function() return MCE end, GetAddon = function() return MCE end} end
    if name == "AceLocale-3.0" then return {GetLocale = function() return locale end} end
    if name == "AceDBOptions-3.0" then return {GetOptionsTable = function() return {} end} end
    if name == "AceConfigRegistry-3.0" then return {NotifyChange = function() end} end
    if optional then return nil end
    return {}
end
local function load(path) assert(loadfile(path))("MinimalistCooldownEdge", ns) end
load("Core/Constants.lua")
load("Core/Core.lua")
local C = ns.Constants
ns.RunNextFrame = function(fn) queued[#queued + 1] = fn end
local function drain()
    local work = queued; queued = {}
    for _, fn in ipairs(work) do fn() end
end

loaded.ForeverAuras = true
check(MCE:IsForeverAurasAvailable(), "detect ForeverAuras on Forever")
ns.ClientCompat.IsForever = false
check(not MCE:IsForeverAurasAvailable(), "ForeverAuras adapter is inactive on Retail")
ns.ClientCompat.IsForever = true
check(MCE.defaults.profile.categories[C.Categories.ForeverAuras].enabled == false, "integration defaults to opt-in")
check(MCE.defaults.profile.categories[C.Categories.ForeverAuras].fontSize == 18, "category defaults are complete")
MCE.db = {profile = CopyTable(MCE.defaults.profile)}
load("Modules/TargetRegistry.lua")
load("Adapters/ForeverAurasAdapter.lua")
local registry, adapter = modules.TargetRegistry, modules.ForeverAurasAdapter
adapter:OnEnable()
local regions = {}
WeakAuras = {
    GetRegion = function(id, clone) return regions[id .. (clone or "")] end,
    GetActiveStates = function(id)
        if id == "unloaded" then error("no trigger state") end
        return {[""] = {}, clone = {}, missing = {}}
    end,
}
ForeverAurasSaved = {displays = {aura = {}, unloaded = {}}}
local function Icon(id, clone)
    local region = Frame()
    region.regionType, region.id, region.cloneId = "icon", id, clone or ""
    local cooldown = Frame("WeakAurasCooldown" .. id .. (clone or ""), region)
    region.cooldown = cooldown
    regions[id .. (clone or "")] = region
    return cooldown, region
end
local original, originalRegion = Icon("aura")
local clone = Icon("aura", "clone")
adapter:Rebuild()
check(registry:GetCategory(original) == C.Categories.ForeverAuras, "discover existing icon")
check(registry:GetCategory(clone) == C.Categories.ForeverAuras, "discover active clone")
local late = Icon("late", "clone2")
check(registry:TryClaim(late) == C.Categories.ForeverAuras, "claim dynamically created clone through cooldown hooks")
local foreign = Frame("WeakAurasCooldownfake", Frame())
check(adapter:TryClaim(foreign) == nil, "name alone is insufficient")
local oldRegion = regions.aura
regions.aura = Frame()
check(adapter:TryClaim(original) == nil, "reject stale region ownership")
regions.aura = oldRegion
originalRegion.regionType = "aurabar"
check(adapter:TryClaim(original) == nil, "do not claim other region types")
originalRegion.regionType = "icon"
originalRegion.id = {secret = true}
check(adapter:TryClaim(original) == nil, "ignore secret identity")
originalRegion.id = "aura"
MCE:SetAddonLoadState("ForeverAuras", false)
check(adapter:TryClaim(original) == nil, "do not claim without the provider")
MCE:SetAddonLoadState("ForeverAuras", true)

load("Modules/TextFit.lua")
load("Modules/StyleEngine.lua")
local engine = modules.StyleEngine
engine:OnEnable()
local config = {hideCountdownNumbers = false, drawSwipe = true}
original.faHideNumbers = true
check(engine:GetDesiredHideCountdownNumbers(original, C.Categories.ForeverAuras, config) == true,
    "provider can hide native numbers")
original.faHideNumbers = false
check(engine:GetDesiredHideCountdownNumbers(original, C.Categories.ForeverAuras, config) == false,
    "provider can show native numbers")
original.faHideNumbers = {secret = true}
check(engine:GetDesiredHideCountdownNumbers(original, C.Categories.ForeverAuras, config) == nil,
    "leave secret visibility untouched")
original.faHideNumbers = nil
check(engine:GetDesiredHideCountdownNumbers(original, C.Categories.ForeverAuras, config) == nil,
    "leave external timer ownership untouched")
check(engine:GetDesiredDrawSwipe(original, C.Categories.ForeverAuras, config) == nil,
    "leave provider swipe policy untouched")
registry:RegisterAdapter(C.Categories.TellMeWhen, {GetTimerOption = function(_, _, option) return option == "drawSwipe" end})
check(engine:GetDesiredDrawSwipe(original, C.Categories.TellMeWhen, config) == true, "TellMeWhen routing still works")
check(engine:GetDesiredHideCountdownNumbers(original, C.Categories.TellMeWhen, config) == false, "TellMeWhen visibility still works")

local icon = Frame()
icon.width, icon.height = 16, 16
local fitted = ns.GetFittedFontSize(icon, "test", 18, "OUTLINE", true)
check(fitted >= 8 and fitted < 18, "small aura reserves readable text space")
local previous = fitted
for _, dimension in ipairs({20, 24, 36, 64}) do
    icon.width, icon.height = dimension, dimension
    local value = ns.GetFittedFontSize(icon, "test", 18, "OUTLINE", true)
    check(value >= previous and value <= 18, "larger icons grow toward the configured maximum")
    previous = value
end
check(previous == 18, "large icons retain the configured size")
icon.width, icon.height = 16, 36
check(ns.GetFittedFontSize(icon, "test", 18, "OUTLINE", true) == fitted, "narrow rectangular icons fit by width")
check(ns.GetFittedFontSize(icon, "test", 18, "OUTLINE", false) == 18, "fit off preserves configured size")
for _, value in ipairs({0, -1, 0/0, math.huge, {secret = true}}) do
    icon.width = value
    check(ns.GetFittedFontSize(icon, "test", 18, "OUTLINE", true) == 18, "ignore inaccessible geometry")
end
icon.GetWidth = function() error("restricted") end
check(ns.GetFittedFontSize(icon, "test", 18, "OUTLINE", true) == 18, "ignore throwing geometry getter")
-- Tainted execution: a secret number that issecretvalue alone does not flag.
icon = Frame(); icon.width, icon.height = 42, 16
local realCanAccess, realHelper = canaccessallvalues, ns.CanAccessAllValues
ns.CanAccessAllValues = function(value) return value ~= 42 and realHelper(value) end
check(ns.GetFittedFontSize(icon, "test", 18, "OUTLINE", true) == 18, "ignore geometry inaccessible to tainted code")
ns.CanAccessAllValues = function() return false end
canaccessallvalues = nil
icon.width = 16
check(ns.GetFittedFontSize(icon, "test", 18, "OUTLINE", true) == fitted, "fit without canaccessallvalues on Forever")
canaccessallvalues, ns.CanAccessAllValues = realCanAccess, realHelper
icon = Frame(); icon.width, icon.height = 16, 16
local callbacks = 0
ns.WatchTextFit(icon, true, function() callbacks = callbacks + 1 end)
icon.scripts.OnSizeChanged(icon); icon.scripts.OnSizeChanged(icon)
check(#queued == 1, "coalesce repeated resize notifications")
drain(); check(callbacks == 1, "restyle once after resize")
icon.scripts.OnSizeChanged(icon)
ns.WatchTextFit(icon, false)
drain(); check(callbacks == 1, "fit off cancels pending resize work")
local text = Frame(); text:SetFont("test", 18, "OUTLINE")
local shrunk = engine:GetFittedCooldownFontSize(text, icon, "test", 18, "OUTLINE", true, true)
text:SetFont("test", shrunk, "OUTLINE")
wipe(ns.fontState)
check(engine:GetFittedCooldownFontSize(text, icon, "test", 18, "OUTLINE", false, true) == 18,
    "restore provider font after style cache reset")

load("UI/Options.lua")
local options = MCE:GetOptions()
check(options.args[C.Categories.ForeverAuras] ~= nil, "dedicated style panel exists")
check(not options.args[C.Categories.ForeverAuras].hidden(), "style panel visible when provider is loaded")
local toggle = options.args.general.args.quickToggles.args.toggleForeverAuras
check(toggle and not toggle.hidden(), "dashboard toggle visible when provider is loaded")
local fullScan
function MCE:ForceUpdateAll(value) fullScan = value end
function MCE:MarkReloadRequired() end
toggle.set(nil, true)
check(toggle.get() == true and fullScan == true, "enabling from dashboard saves setting and rebuilds ownership")
toggle.set(nil, false)
check(toggle.get() == false, "dashboard can disable integration")
ns.ClientCompat.IsForever = false
check(options.args[C.Categories.ForeverAuras].hidden(), "style panel hidden on Retail")
check(toggle.hidden(), "dashboard toggle hidden on Retail")

-- Login notices can be muted without suppressing command feedback or protection.
local loginToggle = options.args.general.args.showLoginMessages
check(MCE.defaults.profile.showLoginMessages == true and loginToggle.get(), "login messages default to enabled")
local messages = {}
DEFAULT_CHAT_FRAME = {AddMessage = function(_, message) messages[#messages + 1] = message end}
MCE:WarnBetterBlizzFramesUnitFrameConflict()
MCE:WarnBetterBlizzPlatesNameplateConflict()
check(#messages == 2, "both compatibility notices appear by default")
MCE:WarnBetterBlizzFramesUnitFrameConflict()
MCE:WarnBetterBlizzPlatesNameplateConflict()
check(#messages == 2, "compatibility notices only appear once per session")
MCE.betterBlizzFramesUnitFrameConflictWarned = nil
MCE.betterBlizzPlatesNameplateConflictWarned = nil
loginToggle.set(nil, false)
check(not loginToggle.get() and MCE.db.profile.showLoginMessages == false, "toggle saves disabled preference")
MCE:WarnBetterBlizzFramesUnitFrameConflict()
MCE:WarnBetterBlizzPlatesNameplateConflict()
check(#messages == 2, "disabled preference suppresses both login notices")
MCE:SetAddonLoadState("BetterBlizzFrames", true)
MCE:SetAddonLoadState("BetterBlizzPlates", true)
check(MCE:IsCategoryBlockedByAddonConflict(C.Categories.Unitframe), "muted notices retain unit frame conflict protection")
check(MCE:IsCategoryBlockedByAddonConflict(C.Categories.Nameplate), "muted notices retain nameplate conflict protection")
check(options.args.general.args.quickToggles.args.toggleUnitframe.disabled(), "muted unit frame conflict stays visible in settings")
check(options.args.general.args.quickToggles.args.toggleNameplate.disabled(), "muted nameplate conflict stays visible in settings")
MCE:Print("Command feedback")
check(#messages == 3 and messages[3]:find("Command feedback", 1, true), "muting notices preserves normal chat feedback")
loginToggle.set(nil, true)
MCE:WarnBetterBlizzFramesUnitFrameConflict()
MCE:WarnBetterBlizzPlatesNameplateConflict()
check(loginToggle.get() and #messages == 5, "re-enabling permits previously muted notices")
loginToggle.set(nil, false)
local savedProfile = MCE.db.profile
MCE.db.profile = CopyTable(MCE.defaults.profile)
check(loginToggle.get(), "option follows active profile")
MCE.db.profile = savedProfile
check(not loginToggle.get(), "saved preference is read after profile replacement")
print("PASS: " .. count .. " assertions (routing, provider policies, fitting, options, login notices; mocked UI)")
