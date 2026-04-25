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

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, event, addon)
    if event == "ADDON_LOADED" and addon == addonName then
        -- Initialize database silently
        _G.RGXFrameworkDB = _G.RGXFrameworkDB or {}
        RGX.db = _G.RGXFrameworkDB

        -- Initialize modules that need post-load startup
        local function TryInit(global)
            local mod = _G[global]
            if mod and type(mod.Init) == "function" then
                local ok, err = pcall(mod.Init, mod)
                if not ok then
                    print("|cFFFF4444[RGX] Init error " .. global .. ": " .. tostring(err) .. "|r")
                end
            end
        end

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
    end
end)
