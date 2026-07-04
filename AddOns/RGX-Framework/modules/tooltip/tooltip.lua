--=====================================================================================
-- RGX-Framework | RGXTooltip
-- Tooltip composition and native-tooltip augmentation for any RGX-Framework addon.
-- Generalizes the pattern used across BattlePetUtility's 71 GameTooltip call sites
-- (SetOwner -> ClearLines -> AddLine/AddDoubleLine x N -> Show, and Hide on leave)
-- into one call, and wraps Blizzard's TooltipDataProcessor so a consumer's hook
-- cannot break every tooltip in the game if it errors (verified against
-- Blizzard_SharedXMLGame/Tooltip/TooltipDataHandler.lua and
-- TooltipInfoSharedDocumentation.lua in the wow-ui-source mirror, Midnight 12.0.7:
-- TooltipDataProcessor.AddTooltipPostCall(tooltipType, func) / AddTooltipPreCall
-- dispatch is NOT pcall-wrapped by Blizzard, so an uncaught error in any one
-- registered callback breaks tooltip rendering addon-suite-wide).
--
-- Usage (zero boilerplate):
--   local Tip = RGX:GetTooltip()
--
--   -- Composed tooltip on hover (replaces SetOwner/ClearLines/AddLine.../Show/Hide)
--   frame:SetScript("OnEnter", function(self)
--       Tip:Show(self, {
--           anchor = "ANCHOR_RIGHT",
--           lines = {
--               "Pet Charms",
--               { "Total", tostring(amount) },              -- double-line: left, right
--               { text = "Missing", r = 1, g = 0.2, b = 0.2 }, -- colored single line
--               { text = snapshot.detail, wrap = true },
--           },
--       })
--   end)
--   frame:SetScript("OnLeave", function() Tip:Hide() end)
--
--   -- Or wire both handlers in one call:
--   Tip:Attach(frame, function() return { lines = { "Hovered!" } } end)
--
--   -- Augment Blizzard's native item/spell/unit tooltip (human vocabulary,
--   -- never Enum.TooltipDataType values -- see triggerNameToType below)
--   Tip:HookNative("item", function(tooltip, data)
--       tooltip:AddLine("Extra RGX line", 1, 1, 1)
--   end)
--=====================================================================================

local addonName, RGX = ...

local Tooltip = {}

-- tooltipType (human name) -> per-type callback list
Tooltip._nativeHooks = {}
Tooltip._nativeHooked = {}

-- Human vocabulary -> Enum.TooltipDataType, per Simplicity Contract rule 2
-- (verified against TooltipInfoSharedDocumentation.lua): consumers never write
-- Blizzard enum names.
local TYPE_NAMES = {
    item      = "Item",
    spell     = "Spell",
    unit      = "Unit",
    aura      = "UnitAura",
    pet       = "CompanionPet",
    mount     = "Mount",
    macro     = "Macro",
}

-- ── Composition ───────────────────────────────────────────────────────────────

local function AddComposedLine(tooltip, line)
    if type(line) == "string" then
        tooltip:AddLine(line, 1, 1, 1, true)
        return
    end
    if type(line) ~= "table" then
        return
    end

    if line.text ~= nil or (line.r or line.g or line.b) then
        local r = line.r or 1
        local g = line.g or 1
        local b = line.b or 1
        tooltip:AddLine(line.text or "", r, g, b, line.wrap ~= false)
        return
    end

    -- Array-shaped { left, right } or { left, right, r,g,b, r2,g2,b2 } -> double-line
    if line[1] ~= nil then
        local lr, lg, lb = line.leftR or 1, line.leftG or 1, line.leftB or 1
        local rr, rg, rb = line.rightR or 0.9, line.rightG or 0.9, line.rightB or 0.9
        tooltip:AddDoubleLine(tostring(line[1]), tostring(line[2] or ""), lr, lg, lb, rr, rg, rb)
    end
end

-- Show a fully composed tooltip anchored to a frame. Replaces the repeated
-- SetOwner/ClearLines/AddLine.../Show boilerplate found across every consumer
-- that hand-builds its own hover tooltip.
--
-- opts:
--   anchor  - GameTooltip anchor point string, default "ANCHOR_RIGHT"
--   offsetX, offsetY - optional SetOwner offsets
--   title   - optional first line, shown white
--   lines   - array of string | { text, r,g,b, wrap } | { left, right, ... }
function Tooltip:Show(anchorFrame, opts)
    if not anchorFrame then return false end
    opts = opts or {}

    GameTooltip:SetOwner(anchorFrame, opts.anchor or "ANCHOR_RIGHT", opts.offsetX or 0, opts.offsetY or 0)
    GameTooltip:ClearLines()

    if opts.title then
        GameTooltip:AddLine(opts.title, 1, 1, 1)
    end

    for _, line in ipairs(opts.lines or {}) do
        local ok, err = pcall(AddComposedLine, GameTooltip, line)
        if not ok then
            RGX:Debug("[RGXTooltip] Show line error: " .. tostring(err))
        end
    end

    GameTooltip:Show()
    return true
end

function Tooltip:Hide()
    GameTooltip:Hide()
end

-- Wire OnEnter/OnLeave in one call. builder(frame) returns the opts table
-- Tooltip:Show expects (or nil to skip showing), so callers can compute
-- dynamic content (e.g. live snapshot data) at hover time.
function Tooltip:Attach(frame, builder)
    if not frame or type(builder) ~= "function" then return false end

    frame:SetScript("OnEnter", function(self)
        local ok, opts = pcall(builder, self)
        if not ok then
            RGX:Debug("[RGXTooltip] Attach builder error: " .. tostring(opts))
            return
        end
        if opts then
            Tooltip:Show(self, opts)
        end
    end)
    frame:SetScript("OnLeave", function() Tooltip:Hide() end)
    return true
end

-- ── Native tooltip augmentation ──────────────────────────────────────────────

local function DispatchNativeHooks(tooltipTypeName, tooltip, data)
    local list = Tooltip._nativeHooks[tooltipTypeName]
    if not list then return end
    for _, fn in ipairs(list) do
        local ok, err = pcall(fn, tooltip, data)
        if not ok then
            RGX:Debug("[RGXTooltip] HookNative(" .. tooltipTypeName .. ") error: " .. tostring(err))
        end
    end
end

local function EnsureNativeHooked(tooltipTypeName)
    if Tooltip._nativeHooked[tooltipTypeName] then return true end

    local enumName = TYPE_NAMES[tooltipTypeName]
    if not enumName then return false end

    if not (TooltipDataProcessor and type(TooltipDataProcessor.AddTooltipPostCall) == "function") then
        return false
    end
    if not (Enum and Enum.TooltipDataType and Enum.TooltipDataType[enumName] ~= nil) then
        return false
    end

    -- One real Blizzard registration per type, ever. All RGX consumers for
    -- that type share this single entry point so a single addon's error
    -- (pcall-guarded above) can never take down another addon's tooltips.
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType[enumName], function(tooltip, data)
        DispatchNativeHooks(tooltipTypeName, tooltip, data)
    end)

    Tooltip._nativeHooked[tooltipTypeName] = true
    return true
end

-- Register a callback that runs after Blizzard finishes populating a native
-- tooltip (item/spell/unit/aura/pet/mount/macro -- human names, never
-- Enum.TooltipDataType). callback(tooltip, data) receives the live GameTooltip
-- and the TooltipData payload Blizzard already resolved.
function Tooltip:HookNative(tooltipTypeName, callback)
    if type(tooltipTypeName) ~= "string" or type(callback) ~= "function" then
        return false
    end
    if not TYPE_NAMES[tooltipTypeName] then
        RGX:Debug("[RGXTooltip] HookNative: unknown type '" .. tostring(tooltipTypeName)
            .. "'. Valid: item, spell, unit, aura, pet, mount, macro")
        return false
    end

    if not EnsureNativeHooked(tooltipTypeName) then
        return false
    end

    self._nativeHooks[tooltipTypeName] = self._nativeHooks[tooltipTypeName] or {}
    table.insert(self._nativeHooks[tooltipTypeName], callback)
    return true
end

-- ── Init ──────────────────────────────────────────────────────────────────────

function Tooltip:Init()
    -- Nothing to do at load time; native hooks register lazily on first
    -- HookNative() call per type so addons that only compose custom
    -- tooltips never touch TooltipDataProcessor at all.
end

-- ── Wire into framework ───────────────────────────────────────────────────────

_G.RGXTooltip = Tooltip
RGX:RegisterModule("tooltip", Tooltip)
