--[[
    RGX-Framework - Initialization
--]]

local addonName, RGX = ...

-- Lifecycle state
RGX._ready = false
RGX._readyCallbacks = RGX._readyCallbacks or {}

function RGX:IsReady()
    return self._ready == true
end

function RGX:OnReady(fn)
    if type(fn) ~= "function" then return end
    if self._ready then
        local ok, err = pcall(fn)
        if not ok then
            print("|cFFFF4444[RGX] OnReady error: " .. tostring(err) .. "|r")
        end
    else
        self._readyCallbacks[#self._readyCallbacks + 1] = fn
    end
end

-- Lifecycle shortcuts — addon authors shouldn't need to know WoW event names.

-- Run fn when the player logs in and the UI is ready.
function RGX:OnLogin(fn)
    self:RegisterEvent("PLAYER_LOGIN", fn)
end

-- Run fn when a specific addon finishes loading.
function RGX:OnLoad(addonName, fn)
    self:RegisterEvent("ADDON_LOADED", function(_, name)
        if name == addonName then fn(name) end
    end)
end

-- Create a minimap button.  Shortcut for RGX:GetMinimap():Create(config).
function RGX:Minimap(config)
    local MM = self:GetMinimap()
    if MM then return MM:Create(config) end
end

-- Convenience wrapper for the common addon minimap pattern.
function RGX:CreateMinimapButton(config)
    config = config or {}

    if type(config.onRightClick) ~= "function" and type(config.openOptions) == "function" then
        config.onRightClick = function(btn)
            config.openOptions(btn)
        end
    end

    if type(config.onCtrlRight) ~= "function" and type(config.toggleVisibility) == "function" then
        config.onCtrlRight = function()
            config.toggleVisibility(false)
        end
    end

    return self:Minimap(config)
end

-- Create a tabbed options panel registered with WoW Settings.
--   local panel = RGX:Options({ title="MyAddon", tabs={{ text="General", content=fn }} })
--   panel:Open()
function RGX:Options(config)
    local UI = self:GetUI()
    if UI then return UI:CreateOptionsPanel(config) end
end

-- Options panel widget shortcuts — call inside a tab content function.
function RGX:Toggle(parent, opts)      local UI = self:GetUI(); if UI then return UI:CreateToggle(parent, opts)      end end
function RGX:Slider(parent, opts)      local UI = self:GetUI(); if UI then return UI:CreateSlider(parent, opts)      end end
function RGX:ColorPicker(parent, opts) local UI = self:GetUI(); if UI then return UI:CreateColorPicker(parent, opts) end end
function RGX:Section(parent, opts)     local UI = self:GetUI(); if UI then return UI:CreateSection(parent, opts)     end end
function RGX:Label(parent, opts)       local UI = self:GetUI(); if UI then return UI:CreateLabel(parent, opts)       end end

RGX:RegisterEvent("ADDON_LOADED", function(_, addon)
    if addon == addonName then
        -- Initialize database silently
        _G.RGXFrameworkDB = _G.RGXFrameworkDB or {}
        RGX.db = _G.RGXFrameworkDB

        -- Initialize modules that need post-load startup.
        -- TryInit is a no-op when a module's global is nil (i.e. its file was
        -- not loaded). The three calls below are retained so that re-adding a
        -- module to RGX-Framework.xml automatically hooks its Init() without
        -- requiring a matching change here.
        -- SharedMedia, Combat, and Reputation are currently not loaded by the
        -- XML (removed at v1.5.18). PetBattles self-inits and does not use TryInit.
        local function TryInit(global)
            local mod = _G[global]
            if mod and type(mod.Init) == "function" then
                local ok, err = pcall(mod.Init, mod)
                if not ok then
                    print("|cFFFF4444[RGX] Init error " .. global .. ": " .. tostring(err) .. "|r")
                end
            end
        end

        TryInit("RGXFonts")
        TryInit("RGXSharedMedia")
        TryInit("RGXCombat")
        TryInit("RGXReputation")

        -- Mark ready and fire queued callbacks
        RGX._ready = true
        local callbacks = RGX._readyCallbacks
        RGX._readyCallbacks = nil
        for i = 1, #callbacks do
            local ok, err = pcall(callbacks[i])
            if not ok then
                print("|cFFFF4444[RGX] OnReady error: " .. tostring(err) .. "|r")
            end
        end

        RGX:UnregisterEvent("ADDON_LOADED", "RGX_Init")
    end
end, "RGX_Init")
