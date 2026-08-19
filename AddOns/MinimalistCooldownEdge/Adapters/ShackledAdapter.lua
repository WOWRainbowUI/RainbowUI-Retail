-- Adapters/ShackledAdapter.lua - Shackled arena CC-tracker cooldown discovery
--
-- Shackled pools its icons as anonymous frames (CreateFrame("Frame", nil, bar))
-- parented directly to the globally named "ShackledBar". Each icon carries a
-- standard Cooldown widget (icon.cd, CooldownFrameTemplate) with Blizzard's own
-- countdown numbers explicitly disabled (SetHideCountdownNumbers(true) plus the
-- OmniCC-family noCooldownCount opt-out) -- Shackled draws its own remaining-time
-- text on a sibling FontString (icon.timeText) instead.
--
-- Unlike MiniAuras, none of this is secure or secret: it is a plain
-- player-made frame tree, so identity and text-region capture are both
-- pure structural lookups with no hooks required.

local _, addon = ...
local C = addon.Constants
local MCE = LibStub("AceAddon-3.0"):GetAddon(C.Addon.AceName)
local Adapter = MCE:NewModule("ShackledAdapter")

local type = type
local GetParentSafe = addon.GetParentSafe

local CATEGORY = C.Categories
local SHACKLED = C.Adapter.Shackled

local Registry

-- =========================================================================
-- FRAME IDENTITY HELPERS
-- =========================================================================

-- cooldown -> icon -> bar ("ShackledBar"). Icons are anonymous, so identity is
-- purely structural: the cooldown's grandparent must be the named bar frame.
local function GetShackledIcon(cooldown)
    local icon = GetParentSafe(cooldown)
    if not icon then return nil end

    local bar = GetParentSafe(icon)
    if not bar or MCE:GetFrameName(bar) ~= SHACKLED.BarFrameName then
        return nil
    end

    return icon
end

-- =========================================================================
-- ADAPTER API
-- =========================================================================

function Adapter:OnEnable()
    Registry = MCE:GetModule("TargetRegistry")
    Registry:RegisterAdapter(CATEGORY.Shackled, self)
end

-- Shackled's icon pool is small (bounded by the user's bar capacity) and fully
-- enumerable through the named bar frame's children, so a rebuild is a plain,
-- single-pass structural scan -- no MiniAuras-style resumable discovery needed.
function Adapter:Rebuild()
    if not MCE:IsShackledAvailable() then return end

    local bar = _G[SHACKLED.BarFrameName]
    if not bar or MCE:IsForbidden(bar) or type(bar.GetChildren) ~= "function" then
        return
    end

    local children = { bar:GetChildren() }
    for i = 1, #children do
        local icon = children[i]
        local cooldown = icon and MCE:SafeTableGet(icon, "cd")
        if MCE:CanUseFrameAsTableKey(cooldown) then
            Registry:Register(cooldown, CATEGORY.Shackled)
        end
    end
end

function Adapter:TryClaim(cooldown)
    if not MCE:IsShackledAvailable() or not MCE:CanUseFrameAsTableKey(cooldown) then
        return nil
    end

    if not GetShackledIcon(cooldown) then return nil end

    return CATEGORY.Shackled
end

-- StyleEngine calls this lazily (and caches the result) the first time it needs
-- a text region for a Shackled cooldown -- see GetCooldownTextRegions. Since the
-- capture is a cheap, always-valid structural lookup, the adapter does not need
-- to pre-populate it at claim time or preserve it across StyleEngine:WipeState.
function Adapter:ResolveDurationText(cooldown)
    local icon = GetShackledIcon(cooldown)
    if not icon then return nil end

    local timeText = MCE:SafeTableGet(icon, "timeText")
    if type(MCE:SafeTableGet(timeText, "SetText")) ~= "function" then
        return nil
    end

    return timeText
end
