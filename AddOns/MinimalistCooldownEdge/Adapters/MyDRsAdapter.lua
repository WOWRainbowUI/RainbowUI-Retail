-- Adapters/MyDRsAdapter.lua - MyDRs diminishing-returns cooldown discovery
--
-- MyDRs creates one named Button per DR category (MyDRsIconTracker<N>) inside
-- MyDRsContainer.iconsContainer and attaches an unnamed Cooldown to each one.
-- MyDRs also parents its own DR state label ("50%" / "IMM") to that cooldown,
-- so StyleEngine restricts this category to the countdown FontString and the
-- label keeps MyDRs' font, anchor, and text.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("MyDRsAdapter")

local type, pairs, pcall = type, pairs, pcall
local strmatch = string.match
local hooksecurefunc = hooksecurefunc
local _G = _G

local CATEGORY = C.Categories
local MYDRS = C.Adapter.MyDRs

local Registry
local updateConfigHookInstalled = false

-- =========================================================================
-- FRAME IDENTITY HELPERS
-- =========================================================================

local function GetParentSafe(frame)
    local getParent = MCE:SafeTableGet(frame, "GetParent")
    if type(getParent) ~= "function" then return nil end

    local ok, parent = pcall(getParent, frame)
    if not ok or not MCE:CanUseFrameAsTableKey(parent) then return nil end

    return parent
end

local function IsMyDRsIconButton(frame)
    local name = MCE:GetFrameName(frame)
    return type(name) == "string"
        and strmatch(name, MYDRS.IconButtonPattern) ~= nil
end

local function GetMyDRsProfile()
    local myDRs = MCE:SafeTableGet(_G, "MyDRs")
    local db = myDRs and MCE:SafeTableGet(myDRs, "db") or nil
    local profile = db and MCE:SafeTableGet(db, "profile") or nil
    return type(profile) == "table" and profile or nil
end

-- =========================================================================
-- MYDRS OPTION SYNC
-- =========================================================================

-- MyDRs routes every option and profile change through this one entry point,
-- including its own "Show countdown text" toggle. Restyle from there so MiniCE
-- re-reads the setting instead of enforcing the state it applied earlier.
-- The refresh is debounced because MyDRs calls this on every slider step.
local function InstallUpdateConfigHook()
    if updateConfigHookInstalled then return end

    local myDRs = MCE:SafeTableGet(_G, "MyDRs")
    if type(myDRs) ~= "table"
       or type(MCE:SafeTableGet(myDRs, "UpdateConfig")) ~= "function" then
        return
    end

    updateConfigHookInstalled = pcall(hooksecurefunc, myDRs, "UpdateConfig", function()
        MCE:RequestDebouncedOptionRefresh(false)
    end)
end

-- =========================================================================
-- ADAPTER API
-- =========================================================================

local function RegisterIconButton(button)
    if not IsMyDRsIconButton(button) then return end

    local cooldown = MCE:SafeTableGet(button, "cooldown")
    if Registry and MCE:CanUseFrameAsTableKey(cooldown) then
        Registry:Register(cooldown, CATEGORY.MyDRs)
    end
end

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.MyDRs, self)
end

function Adapter:Rebuild()
    if not MCE:IsMyDRsAvailable() then return end

    InstallUpdateConfigHook()

    -- MyDRs keeps its own category -> icon button map on the icons container.
    local container = MCE:SafeTableGet(_G, MYDRS.ContainerName)
    local iconsContainer = container and MCE:SafeTableGet(container, "iconsContainer") or nil
    local framesByCategory = iconsContainer
        and MCE:SafeTableGet(iconsContainer, "drFramesByCategory") or nil

    if type(framesByCategory) == "table" then
        for _, button in pairs(framesByCategory) do
            RegisterIconButton(button)
        end
        return
    end

    -- Fallback: every icon button is globally named, so a bounded lookup finds
    -- them even when the container field is not exposed yet.
    for index = 1, MYDRS.MaxIconIndex do
        RegisterIconButton(MCE:SafeTableGet(_G, MYDRS.IconButtonPrefix .. index))
    end
end

function Adapter:TryClaim(cooldown)
    if not MCE:IsMyDRsAvailable() or not MCE:CanUseFrameAsTableKey(cooldown) then
        return nil
    end

    if not IsMyDRsIconButton(GetParentSafe(cooldown)) then return nil end

    InstallUpdateConfigHook()
    return CATEGORY.MyDRs
end

--- MyDRs owns whether its DR icons show countdown numbers at all.
--- Returns nil when the setting cannot be read.
function Adapter:IsCountdownTextEnabled()
    local profile = GetMyDRsProfile()
    if not profile then return nil end

    return MCE:SafeTableGet(profile, "showCountdownText") ~= false
end
