--=====================================================================================
-- RGX-Framework | RGXDisplay
-- Bare-metal screen elements: anchored, scalable display units for aura icons,
-- alerts, and other consumer visuals.
--
-- Elements are sandwich frames. The container frame carries the position
-- anchor; the child content frame carries scale and alpha so a consumer can
-- resize/recolor its own content without touching layout state.
--
-- Usage:
--   local Display = RGX:GetDisplay()
--   local icon = Display:CreateElement({
--       name     = "MyAddon_Icon",
--       position = "LEFT",
--       storage  = MyAddonDB,
--   })
--   icon:SetOffset(-8, 0)
--
-- Public API:
--   Display:RegisterPosition(name, spec)     -- add/replace a named position
--   Display:GetPosition(name)                -- copy of a position spec
--   Display:ListPositions()                  -- sorted position names
--   Display:CreateElement(opts)              -- element or nil, error
--   Display:RegisterDefaults(context, opts)  -- merge scale/alpha defaults
--   Display:GetDefaults(context)             -- resolved copy
--   Display:SetEditMode(on)
--   Display:IsEditMode()
--=====================================================================================

local addonName, RGX = ...

local Display = {}

Display.name    = "display"
Display.version = "1.0.0"

local DEFAULT_SCALE  = 100
local DEFAULT_ALPHA  = 1
local DEFAULT_SIZE   = 64
local OUTSIDE_OFFSET = 160

local function Clamp01(value)
    if value < 0 then return 0 end
    if value > 1 then return 1 end
    return value
end

--[[============================================================================
    POSITIONS
============================================================================]]

-- A position spec anchors the element container against its parent:
--   point, relativePoint - anchor pair
--   x, y                 - base offset in parent units
--   spreadX, spreadY     - direction a positive element spread pushes toward
local function NormalizePositionSpec(spec)
    if type(spec) ~= "table" then
        return nil, "position must be a name or a spec table"
    end
    local point = spec.point
    if type(point) ~= "string" or point == "" then
        return nil, "position.point is required"
    end
    local relativePoint = spec.relativePoint
    if relativePoint == nil then relativePoint = point end
    if type(relativePoint) ~= "string" or relativePoint == "" then
        return nil, "position.relativePoint must be a string"
    end
    local normalized = { point = point, relativePoint = relativePoint }
    for _, key in ipairs({ "x", "y", "spreadX", "spreadY" }) do
        local value = spec[key]
        if value == nil then
            normalized[key] = 0
        elseif type(value) ~= "number" then
            return nil, "position." .. key .. " must be a number"
        else
            normalized[key] = value
        end
    end
    return normalized
end

local function CopyPositionSpec(spec)
    local copy = {}
    for key, value in pairs(spec) do
        copy[key] = value
    end
    return copy
end

local positions = {}

local BUILTIN_POSITIONS = {
    CENTER       = { point = "CENTER", relativePoint = "CENTER" },
    LEFT         = { point = "RIGHT",  relativePoint = "LEFT",  spreadX = -1 },
    RIGHT        = { point = "LEFT",   relativePoint = "RIGHT", spreadX = 1 },
    TOP          = { point = "BOTTOM", relativePoint = "TOP",   spreadY = 1 },
    BOTTOM       = { point = "TOP",    relativePoint = "BOTTOM", spreadY = -1 },
    LEFTOUTSIDE  = { point = "RIGHT",  relativePoint = "LEFT",  x = -OUTSIDE_OFFSET, spreadX = -1 },
    RIGHTOUTSIDE = { point = "LEFT",   relativePoint = "RIGHT", x = OUTSIDE_OFFSET,  spreadX = 1 },
}

for name, spec in pairs(BUILTIN_POSITIONS) do
    positions[name] = NormalizePositionSpec(spec)
end

function Display:RegisterPosition(name, spec)
    if type(name) ~= "string" or name == "" then
        return nil, "position name must be a non-empty string"
    end
    local normalized, err = NormalizePositionSpec(spec)
    if not normalized then return nil, err end
    positions[name] = normalized
    return true
end

function Display:GetPosition(name)
    local spec = positions[name]
    if not spec then return nil end
    return CopyPositionSpec(spec)
end

function Display:ListPositions()
    local names = {}
    for name in pairs(positions) do
        names[#names + 1] = name
    end
    table.sort(names)
    return names
end

--[[============================================================================
    DEFAULTS
============================================================================]]

-- Context defaults hold scale/alpha overrides (for example a "combat" context
-- with a larger scale). RegisterDefaults merges into the existing context so
-- a later call may adjust only one of the values.
local defaults = {}

function Display:RegisterDefaults(context, values)
    if type(context) ~= "string" or context == "" then
        return nil, "context must be a non-empty string"
    end
    if type(values) ~= "table" then
        return nil, "defaults must be a table"
    end
    local scale = values.scale
    if scale ~= nil and (type(scale) ~= "number" or scale <= 0) then
        return nil, "scale must be a number > 0"
    end
    local alpha = values.alpha
    if alpha ~= nil and type(alpha) ~= "number" then
        return nil, "alpha must be a number"
    end
    local entry = defaults[context]
    if not entry then
        entry = {}
        defaults[context] = entry
    end
    if scale ~= nil then entry.scale = scale end
    if alpha ~= nil then entry.alpha = Clamp01(alpha) end
    return true
end

function Display:GetDefaults(context)
    context = context or "default"
    local entry = defaults[context]
    return {
        scale = (entry and entry.scale) or DEFAULT_SCALE,
        alpha = (entry and entry.alpha) or DEFAULT_ALPHA,
    }
end

--[[============================================================================
    PERSISTENCE
============================================================================]]

-- Durable element offsets inside the framework's own SavedVariables. A
-- consumer's SavedVariables can be lost during client crashes or storage
-- wipes; the framework database survives those, so dragged offsets recorded
-- here are restored instead of resetting to the consumer default.
local function GetDurableOffsets()
    local db = _G.RGXFrameworkDB
    if type(db) ~= "table" then return nil end
    if type(db.RGXDisplayPositions) ~= "table" then
        db.RGXDisplayPositions = {}
    end
    return db.RGXDisplayPositions
end

local function PersistElement(element)
    if type(element._storage) == "table" then
        local entry = element._storage[element._offsetKey]
        if type(entry) ~= "table" then
            entry = {}
            element._storage[element._offsetKey] = entry
        end
        entry.x = element._x
        entry.y = element._y
    end
    local durable = GetDurableOffsets()
    if durable then
        durable[element._name] = { x = element._x, y = element._y }
    end
end

--[[============================================================================
    ELEMENTS
============================================================================]]

local elements = {}
local editMode = false

local Element = {}
Element.__index = Element

local function ResolvePositionSpec(element)
    if element._inlineSpec then
        return element._inlineSpec
    end
    return positions[element._positionName] or positions.CENTER
end

local function ResolveScaleAlpha(element)
    local entry = defaults[element._context]
    local scale = element._scale or (entry and entry.scale) or DEFAULT_SCALE
    local alpha = element._alpha or (entry and entry.alpha) or DEFAULT_ALPHA
    return scale, alpha
end

function Element:Apply()
    local spec = ResolvePositionSpec(self)
    local appliedX = (spec.x or 0) + self._x + self._spread * (spec.spreadX or 0)
    local appliedY = (spec.y or 0) + self._y + self._spread * (spec.spreadY or 0)
    self.frame:ClearAllPoints()
    self.frame:SetPoint(spec.point, self._parent, spec.relativePoint, appliedX, appliedY)
    local scale, alpha = ResolveScaleAlpha(self)
    self.content:SetScale(scale / 100)
    self.content:SetAlpha(alpha)
    return true
end

function Element:SetScale(value)
    if value == nil then
        self._scale = nil
    elseif type(value) ~= "number" or value <= 0 then
        return nil, "scale must be a number > 0"
    else
        self._scale = value
    end
    return self:Apply()
end

function Element:SetAlpha(value)
    if value == nil then
        self._alpha = nil
    elseif type(value) ~= "number" then
        return nil, "alpha must be a number"
    else
        self._alpha = Clamp01(value)
    end
    return self:Apply()
end

function Element:SetOffset(x, y)
    if type(x) ~= "number" or type(y) ~= "number" then
        return nil, "offset requires numeric x and y"
    end
    self._x, self._y = x, y
    self:Apply()
    PersistElement(self)
    return true
end

function Element:SetSpread(value)
    if type(value) ~= "number" then
        return nil, "spread must be a number"
    end
    self._spread = value
    return self:Apply()
end

function Element:SetPositionName(name)
    if type(name) ~= "string" or not positions[name] then
        return nil, "unknown position: " .. tostring(name)
    end
    self._positionName = name
    self._inlineSpec = nil
    return self:Apply()
end

function Element:SetContext(context)
    if type(context) ~= "string" or context == "" then
        return nil, "context must be a non-empty string"
    end
    self._context = context
    return self:Apply()
end

function Element:SetSize(width, height)
    if type(width) ~= "number" or width <= 0 or type(height) ~= "number" or height <= 0 then
        return nil, "size requires numeric width and height > 0"
    end
    self._width, self._height = width, height
    self.frame:SetSize(width, height)
    return true
end

function Element:SetShown(show)
    self.frame:SetShown(show and true or false)
end

function Element:IsShown()
    return self.frame:IsShown()
end

function Element:GetResolved()
    local spec = ResolvePositionSpec(self)
    local scale, alpha = ResolveScaleAlpha(self)
    return {
        position      = self._positionName or "CUSTOM",
        point         = spec.point,
        relativePoint = spec.relativePoint,
        x             = (spec.x or 0) + self._x + self._spread * (spec.spreadX or 0),
        y             = (spec.y or 0) + self._y + self._spread * (spec.spreadY or 0),
        spread        = self._spread,
        scale         = scale,
        alpha         = alpha,
    }
end

function Element:Destroy()
    elements[self._name] = nil
    self._destroyed = true
    if self._mover then
        self._mover:Hide()
    end
    self.frame:Hide()
    return true
end

--[[============================================================================
    EDIT MODE
============================================================================]]

-- A mover overlay is created lazily per element. While edit mode is on it
-- sits above the content, captures left-drag, and writes live offsets both
-- to the consumer storage and the durable framework store on release.
function Element:_EnsureMover()
    if self._mover then return self._mover end
    local mover = CreateFrame("Frame", nil, self.content)
    mover:SetAllPoints(self.content)
    mover:EnableMouse(true)
    mover:RegisterForDrag("LeftButton")
    local tint = mover:CreateTexture(nil, "BACKGROUND")
    tint:SetAllPoints(mover)
    tint:SetColorTexture(0.02, 0.87, 0.98, 0.22)
    mover:SetScript("OnDragStart", function()
        local scale = self.frame:GetEffectiveScale()
        if not (type(scale) == "number" and scale > 0) then scale = 1 end
        local cursorX, cursorY = GetCursorPosition()
        self._drag = {
            startX  = self._x,
            startY  = self._y,
            cursorX = cursorX / scale,
            cursorY = cursorY / scale,
        }
        mover:SetScript("OnUpdate", function()
            local current = self.frame:GetEffectiveScale()
            if not (type(current) == "number" and current > 0) then current = 1 end
            local nowX, nowY = GetCursorPosition()
            self._x = self._drag.startX + (nowX / current - self._drag.cursorX)
            self._y = self._drag.startY + (nowY / current - self._drag.cursorY)
            self:Apply()
        end)
    end)
    mover:SetScript("OnDragStop", function()
        mover:SetScript("OnUpdate", nil)
        self._drag = nil
        PersistElement(self)
        if type(self._onMove) == "function" then
            local ok, err = pcall(self._onMove, self)
            if not ok then
                RGX:Error("RGXDisplay: onMove error: " .. tostring(err))
            end
        end
    end)
    mover:Hide()
    self._mover = mover
    return mover
end

function Display:SetEditMode(on)
    editMode = not not on
    for _, element in pairs(elements) do
        if editMode then
            element:_EnsureMover():Show()
        elseif element._mover then
            element._mover:Hide()
        end
    end
    return editMode
end

function Display:IsEditMode()
    return editMode
end

--[[============================================================================
    CREATE
============================================================================]]

--[[
    CreateElement(opts) -> element or nil, error

    opts:
        name       (string, required) unique persistence key; prefix with the
                                      consumer addon name to stay globally unique
        position   (string | spec)    named position or inline spec (default CENTER)
        x, y       (number)           element offset in parent units (default 0)
        spread     (number)           offset along the position's spread axis (default 0)
        scale      (number)           explicit percent scale; nil inherits context
        alpha      (number)           0-1; nil inherits context
        context    (string)           defaults context (default "default")
        parent     (frame)            anchor target (default UIParent)
        width      (number)           container width (default 64)
        height     (number)           container height (default 64)
        storage    (table)            consumer storage for offset persistence
        offsetKey  (string)           storage key (default name)
        onMove     (fn(element))      called after a drag settles
]]
function Display:CreateElement(opts)
    if type(opts) ~= "table" then
        return nil, "CreateElement requires an options table"
    end
    local name = opts.name
    if type(name) ~= "string" or name == "" then
        return nil, "CreateElement requires opts.name"
    end
    if elements[name] then
        return nil, "element already exists: " .. name
    end

    local position = opts.position
    local positionName, inlineSpec
    if position == nil then
        positionName = "CENTER"
    elseif type(position) == "string" then
        if not positions[position] then
            return nil, "unknown position: " .. position
        end
        positionName = position
    elseif type(position) == "table" then
        local normalized, err = NormalizePositionSpec(position)
        if not normalized then return nil, err end
        inlineSpec = normalized
    else
        return nil, "position must be a name or a spec table"
    end

    local x, y = opts.x, opts.y
    if x ~= nil and type(x) ~= "number" then return nil, "opts.x must be a number" end
    if y ~= nil and type(y) ~= "number" then return nil, "opts.y must be a number" end
    local spread = opts.spread
    if spread ~= nil and type(spread) ~= "number" then return nil, "opts.spread must be a number" end
    local scale = opts.scale
    if scale ~= nil and (type(scale) ~= "number" or scale <= 0) then
        return nil, "opts.scale must be a number > 0"
    end
    local alpha = opts.alpha
    if alpha ~= nil and type(alpha) ~= "number" then return nil, "opts.alpha must be a number" end
    local width, height = opts.width, opts.height
    if width ~= nil and (type(width) ~= "number" or width <= 0) then
        return nil, "opts.width must be a number > 0"
    end
    if height ~= nil and (type(height) ~= "number" or height <= 0) then
        return nil, "opts.height must be a number > 0"
    end

    x = x or 0
    y = y or 0
    spread = spread or 0
    width = width or DEFAULT_SIZE
    height = height or DEFAULT_SIZE

    local context = opts.context or "default"
    local parent = opts.parent or _G.UIParent
    local storage = opts.storage
    local offsetKey = opts.offsetKey or name
    local onMove = opts.onMove

    -- The durable store is read before consumer storage so wins always come
    -- from the stickier source; below, a durable win is mirrored back.
    local durable = GetDurableOffsets()
    local saved = durable and durable[name]
    local savedValid = type(saved) == "table"
        and type(saved.x) == "number" and type(saved.y) == "number"
    if savedValid then
        x, y = saved.x, saved.y
    elseif type(storage) == "table" then
        local entry = storage[offsetKey]
        if type(entry) == "table"
            and type(entry.x) == "number" and type(entry.y) == "number" then
            x, y = entry.x, entry.y
        end
    end

    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(width, height)
    local content = CreateFrame("Frame", nil, frame)
    content:SetAllPoints(frame)

    local element = setmetatable({
        frame        = frame,
        content      = content,
        _parent      = parent,
        _name        = name,
        _context     = context,
        _width       = width,
        _height      = height,
        _storage     = storage,
        _offsetKey   = offsetKey,
        _onMove      = onMove,
        _x           = x,
        _y           = y,
        _spread      = spread,
        _scale       = scale,
        _alpha       = alpha ~= nil and Clamp01(alpha) or nil,
        _positionName = positionName,
        _inlineSpec  = inlineSpec,
    }, Element)

    elements[name] = element

    if savedValid and type(storage) == "table" then
        local entry = storage[offsetKey]
        if type(entry) ~= "table" then
            entry = {}
            storage[offsetKey] = entry
        end
        entry.x = x
        entry.y = y
    end

    element:Apply()
    if editMode then
        element:_EnsureMover():Show()
    end
    return element
end

--[[============================================================================
    REGISTRATION
============================================================================]]

_G.RGXDisplay = Display
RGX:RegisterModule("display", Display, { category = "library" })
