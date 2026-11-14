-- Fit against literal timer samples, never the contents of a live countdown.
local _, addon = ...
local metrics = {}
local watched = setmetatable({}, addon.weakMeta)
local pending = setmetatable({}, addon.weakMeta)
local measure
-- Reserve a readable short timer rather than a worst-case clock on every aura.
-- Long formats may extend beyond small icons; fitting never reads live text.
local samples = { "88", "8.8", "8m", "8h", "8d" }

local function ReadDimension(frame, method)
    return frame[method](frame)
end

-- Clients without canaccessallvalues have no tainted access rules to honour.
local function IsReadable(value)
    if addon.IsSecretValue(value) then return false end
    return canaccessallvalues == nil or addon.CanAccessAllValues(value)
end

local function IsUsableDimension(value)
    return value == value and value > 0 and value ~= math.huge
end

-- Geometry of a frame anchored to secure content can come back secret while
-- execution is tainted. Never compare a value before proving it is readable,
-- and keep the range check protected in case the client still refuses it.
local function PublicDimension(frame, method)
    if not frame or not IsReadable(frame) then return nil end
    local ok, value = pcall(ReadDimension, frame, method)
    if not ok or type(value) ~= "number" or not IsReadable(value) then return nil end
    local checked, usable = pcall(IsUsableDimension, value)
    if not checked or not usable then return nil end
    return value
end

function addon.GetFittedFontSize(frame, font, size, flags, enabled)
    if not enabled then return size end
    local width = PublicDimension(frame, "GetWidth")
    local height = PublicDimension(frame, "GetHeight")
    if not width or not height or width <= 4 or height <= 4 then return size end
    local key = font .. "\031" .. size .. "\031" .. (flags or "")
    local metric = metrics[key]
    if not metric then
        if not measure then
            local owner = CreateFrame("Frame")
            owner:Hide()
            measure = owner:CreateFontString(nil, "OVERLAY")
        end
        if not measure:SetFont(font, size, flags) then return size end
        local sampleWidth, sampleHeight = 0, 0
        for i = 1, #samples do
            measure:SetText(samples[i])
            sampleWidth = math.max(sampleWidth, measure:GetStringWidth())
            sampleHeight = math.max(sampleHeight, measure:GetStringHeight())
        end
        if sampleWidth <= 0 or sampleHeight <= 0 then return size end
        metric = { width = sampleWidth, height = sampleHeight }
        metrics[key] = metric
    end
    -- A fixed two-pixel inset on each side consumed a quarter of a 16px
    -- aura. Reserve 5% per side, capped at the original inset on large icons.
    local insetX = math.min(2, width * 0.05)
    local insetY = math.min(2, height * 0.05)
    return math.max(1, math.min(size, size * (width - 2 * insetX) / metric.width,
        size * (height - 2 * insetY) / metric.height))
end

function addon.WatchTextFit(frame, enabled, callback)
    if not frame or addon.IsSecretValue(frame) or not addon.CanAccessAllValues(frame) then return end
    local state = watched[frame]
    if not state then
        if not enabled or type(frame.HookScript) ~= "function" then return end
        state = {}
        local ok = pcall(frame.HookScript, frame, "OnSizeChanged", function(self)
            local current = watched[self]
            if not current or not current.enabled or pending[self] then return end
            pending[self] = true
            addon.RunNextFrame(function()
                pending[self] = nil
                current = watched[self]
                if current and current.enabled then current.callback(self) end
            end)
        end)
        if not ok then return end
        watched[frame] = state
    end
    state.enabled, state.callback = enabled, callback
end
