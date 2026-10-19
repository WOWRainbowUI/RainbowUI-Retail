-- Fit against literal timer samples, never the contents of a live countdown.
local _, addon = ...
local metrics = {}
local watched = setmetatable({}, addon.weakMeta)
local pending = setmetatable({}, addon.weakMeta)
local measure
local samples = { "88:88", "888.8", "888d", "888h", "888m", "888s" }

local function ReadDimension(frame, method)
    return frame[method](frame)
end

local function PublicDimension(frame, method)
    if not frame or addon.IsSecretValue(frame) then return nil end
    local ok, value = pcall(ReadDimension, frame, method)
    if not ok or addon.IsSecretValue(value) or type(value) ~= "number"
        or value ~= value or value <= 0 or value == math.huge then return nil end
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
    return math.max(1, math.min(size, size * (width - 4) / metric.width,
        size * (height - 4) / metric.height))
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
