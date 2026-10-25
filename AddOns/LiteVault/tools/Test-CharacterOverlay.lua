-- Behavioral test for UI/CharacterOverlay.lua (Lua 5.1): refreshing the item-level overlays
-- while the equipment flyout has buttons must not call an undefined global. The refresh runs
-- when the "disable character overlay" option is toggled; a flyout opened earlier in the
-- session leaves its buttons flagged as shown.
-- Run from the addon root:  lua5.1 tools/Test-CharacterOverlay.lua

local failures, checks = {}, 0
local function check(condition, message)
    checks = checks + 1
    if not condition then failures[#failures + 1] = message end
end

local created = {}
local stubMeta = {}
local function NewStub(kind, name, parent)
    local object = setmetatable({ _kind = kind, _scripts = {}, _events = {}, _shown = false, _parent = parent }, stubMeta)
    created[#created + 1] = object
    if name then _G[name] = object end
    return object
end
stubMeta.__index = function(self, key)
    if key == "CreateFontString" or key == "CreateTexture" then return function(owner) return NewStub(key, nil, owner) end end
    if key == "SetScript" then return function(owner, scriptName, fn) owner._scripts[scriptName] = fn end end
    if key == "RegisterEvent" then return function(owner, event) owner._events[event] = true end end
    if key == "Show" then return function(owner) owner._shown = true end end
    if key == "Hide" then return function(owner) owner._shown = false end end
    if key == "IsShown" or key == "IsVisible" then return function(owner) return owner._shown end end
    if key == "GetParent" then return function(owner) return owner._parent end end
    if key == "GetFrameLevel" then return function() return 1 end end
    if type(key) == "string" and key:match("^%u") then return function() return nil end end
    return nil
end

CreateFrame = function(kind, name, parent) return NewStub(kind, name, parent) end
UIParent = NewStub("Frame", "UIParent")
hooksecurefunc = function() end
C_Timer = { After = function() end }
C_Item = {
    GetItemLink = function() return "|cffa335ee|Hitem:12345::::::::90:::::|h[Test Item]|h|r" end,
    GetDetailedItemLevelInfo = function() return 600 end,
    GetItemInfo = function() return nil end,
    GetItemInfoInstant = function() return 12345 end,
    IsBound = function() return false end,
}
GetInventoryItemLink = function() return nil end
LiteVaultDB = {}

local lv = {}
assert(loadfile("UI/CharacterOverlay.lua"))("LiteVault", lv)
check(type(lv.RefreshCharacterOverlays) == "function", "lv.RefreshCharacterOverlays is missing")
lv.IsCharacterOverlayEnabled = lv.IsCharacterOverlayEnabled or function() return true end

-- A flyout opened earlier: its buttons keep their own shown flag.
local flyoutButton = NewStub("Button")
flyoutButton._shown = true
flyoutButton.GetItemLocation = function()
    return { IsValid = function() return true end }
end
EquipmentFlyoutFrame = { buttons = { flyoutButton } }

local ok, err = pcall(lv.RefreshCharacterOverlays)
check(ok, "refreshing overlays with an open equipment flyout raised: " .. tostring(err))

-- With the overlay disabled the refresh still runs cleanly.
LiteVaultDB.disableCharacterOverlay = true
ok, err = pcall(lv.RefreshCharacterOverlays)
check(ok, "refreshing overlays after disabling them raised: " .. tostring(err))

if #failures > 0 then
    for _, message in ipairs(failures) do print("FAIL: " .. message) end
    error(string.format("%d of %d character overlay checks failed", #failures, checks))
end
print(string.format("Character overlay refresh: %d checks passed", checks))
