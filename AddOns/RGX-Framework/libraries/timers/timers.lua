--[[
    RGX-Framework - Timers Module (RGXTimers)

    Countdown/progress bars for guide UIs and other consumers that previously
    pulled LibCandyBar-3.0. Bars are real frames: anchors, scripts, show/hide
    and every other frame method work directly on the returned bar.

    Getting the module:
        local Timers = RGX:GetTimers()          -- or RGX:GetModule("timers")

    Creating and running a bar:
        local bar = Timers:New(texture, width, height)
        bar:SetDuration(45)
        bar:SetLabel("Flight to Stormwind")
        bar:SetIcon("Interface\\Icons\\INV_Misc_PocketWatch_02")
        bar:SetColor(1, 0.82, 0, 1)
        bar:SetOnComplete(function(bar) ... end)
        bar:SetOnCancel(function(bar) ... end)
        bar:Start()

    Bar API:
        bar:SetDuration(seconds)     total time; countdown from it, progress to it
        bar:GetDuration()            last configured duration
        bar:SetLabel(text)           label text (left side)
        bar:GetLabel()               current label text
        bar:SetIcon(texture)         icon texture; nil hides the icon
        bar:SetColor(r, g, b, a)     status bar color (0-1 range)
        bar:SetTexture(texture)      status bar texture; nil restores the default
        bar:SetHeight(height)        frame height; keeps the icon square
        bar:SetCountdown(bool)       true (default) drains to 0; false fills to duration
        bar:SetFill(bool)            inverse of SetCountdown (LibCandyBar naming)
        bar:IsCountdown()/IsFill()   current display mode
        bar:SetTimeVisible(bool)     show/hide the remaining-time text
        bar:SetLabelVisible(bool)    show/hide the label text
        bar:SetOnComplete(callback)  fired once when the bar reaches its end
        bar:SetOnCancel(callback)    fired once when Stop() interrupts a running bar
        bar:Start()                  starts timing and shows the bar
        bar:Stop()                   stops a running bar (cancel callback) and hides it
        bar:SetValue(value)          manual update; clamped to [0, duration]
        bar:GetValue()               current value
        bar:IsRunning()              true while the bar is timing

    Compatibility fields maintained for pooled consumers:
        bar.start / bar.exp          absolute GetTime() start and expiry stamps
        bar.duration / bar.remaining configured duration
        bar.running                  timer state
--]]

local RGX = _G.RGXFramework

local Timers = {}

local UPDATE_RATE = 0.1
local DEFAULT_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"

-- Frame-method inheritance: the bar frame's metatable is swapped to the bar
-- prototype, and the prototype falls through to a scratch frame so native
-- frame methods (SetPoint, SetScript, Show, ...) stay reachable.
local frameMethods = CreateFrame("Frame")
local prototypeMT = { __index = frameMethods }
local BarPrototype = setmetatable({}, prototypeMT)
local barMT = { __index = BarPrototype }

-- Weak-key registry so CancelAll can reach running bars without pinning
-- pooled bars after consumers discard them.
Timers.bars = setmetatable({}, { __mode = "k" })

local barCount = 0

local function now()
    return (GetTime and GetTime()) or 0
end

local function formatTime(seconds)
    if seconds < 0 then seconds = 0 end
    local total = math.floor(seconds + 0.5)
    if total >= 3600 then
        local hours = math.floor(total / 3600)
        local minutes = math.floor((total - hours * 3600) / 60)
        return string.format("%d:%02d:%02d", hours, minutes, total - hours * 3600 - minutes * 60)
    end
    local minutes = math.floor(total / 60)
    return string.format("%d:%02d", minutes, total - minutes * 60)
end

-- Create a bar. texture defaults to the Blizzard status bar texture, width to
-- 200 and height to 16. The bar starts hidden.
function Timers:New(texture, width, height)
    width = width or 200
    height = height or 16

    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetWidth(width)
    frame:SetHeight(height)
    frame:SetFrameStrata("MEDIUM")

    local statusBar = CreateFrame("StatusBar", nil, frame)
    statusBar:SetPoint("TOPLEFT", frame, "TOPLEFT")
    statusBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
    statusBar:SetStatusBarTexture(texture or DEFAULT_TEXTURE)

    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetWidth(height)
    icon:SetHeight(height)
    icon:SetPoint("TOPLEFT", frame, "TOPLEFT")
    icon:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
    icon:Hide()

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", icon, "TOPRIGHT", 2, 0)
    label:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 2, 0)
    label:SetJustifyH("LEFT")
    label:SetJustifyV("MIDDLE")

    local time = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    time:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, 0)
    time:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 0)
    time:SetJustifyH("RIGHT")
    time:SetJustifyV("MIDDLE")

    local bar = setmetatable(frame, barMT)
    bar.statusBar = statusBar
    bar.icon = icon
    bar.label = label
    bar.time = time
    bar.duration = 0
    bar.remaining = 0
    bar.value = 0
    bar.running = false
    bar.countdown = true
    bar.updater = nil
    bar.onComplete = nil
    bar.onCancel = nil
    bar.start = nil
    bar.exp = nil
    bar._label = nil
    bar._name = "RGXTimersBar" .. tostring(barCount + 1)
    barCount = barCount + 1

    statusBar:SetStatusBarColor(1, 1, 1, 1)
    bar:Hide()

    Timers.bars[bar] = true
    return bar
end

-- Cancel every running bar. Returns the number of bars that were stopped.
function Timers:CancelAll()
    local cancelled = 0
    for bar in pairs(Timers.bars) do
        if bar.running then
            bar:Stop()
            cancelled = cancelled + 1
        end
    end
    return cancelled
end

--[[============================================================================
    BAR OBJECT
============================================================================]]

function BarPrototype:SetDuration(duration)
    self.duration = duration or 0
    self.remaining = self.duration
    self.statusBar:SetMinMaxValues(0, self.duration)
    if self.running then
        self.start = now()
        self.exp = self.start + self.duration
        self.value = self.countdown and self.duration or 0
    end
    self:_Update()
    return self
end

function BarPrototype:GetDuration()
    return self.duration
end

function BarPrototype:SetLabel(text)
    self._label = text
    self.label:SetText(text or "")
    return self
end

function BarPrototype:GetLabel()
    return self._label
end

function BarPrototype:SetIcon(texture)
    if texture then
        self.icon:SetTexture(texture)
        self.icon:Show()
    else
        self.icon:SetTexture(nil)
        self.icon:Hide()
    end
    return self
end

function BarPrototype:SetColor(r, g, b, a)
    self.statusBar:SetStatusBarColor(r or 1, g or 1, b or 1, a or 1)
    return self
end

function BarPrototype:SetTexture(texture)
    self.statusBar:SetStatusBarTexture(texture or DEFAULT_TEXTURE)
    return self
end

-- Height is applied to the frame and keeps the icon square.
function BarPrototype:SetHeight(height)
    if not height then return self end
    frameMethods.SetHeight(self, height)
    self.icon:SetWidth(height)
    self.icon:SetHeight(height)
    return self
end

function BarPrototype:_SetMode(countdown)
    self.countdown = countdown and true or false
    if self.running then
        self.start = now()
        self.exp = self.start + self.duration
        self.value = self.countdown and self.duration or 0
        self:_Update()
    end
    return self
end

function BarPrototype:SetCountdown(countdown)
    return self:_SetMode(countdown ~= false)
end

-- LibCandyBar naming: fill = progress mode.
function BarPrototype:SetFill(fill)
    return self:_SetMode(not fill)
end

function BarPrototype:IsCountdown()
    return self.countdown
end

function BarPrototype:IsFill()
    return not self.countdown
end

function BarPrototype:SetTimeVisible(visible)
    if visible == false then
        self.time:Hide()
    else
        self.time:Show()
    end
    return self
end

function BarPrototype:SetLabelVisible(visible)
    if visible == false then
        self.label:Hide()
    else
        self.label:Show()
    end
    return self
end

function BarPrototype:SetOnComplete(callback)
    self.onComplete = callback
    return self
end

function BarPrototype:SetOnCancel(callback)
    self.onCancel = callback
    return self
end

-- Start timing and show the bar. Returns false when no duration is set.
function BarPrototype:Start()
    if (self.duration or 0) <= 0 then
        return false
    end
    if self.updater then
        RGX:CancelTimer(self.updater)
        self.updater = nil
    end
    self.running = true
    self.start = now()
    self.exp = self.start + self.duration
    self.value = self.countdown and self.duration or 0
    self:_Update()
    self.updater = RGX:Every(UPDATE_RATE, function() self:_Tick() end, self._name)
    self:Show()
    return true
end

-- Stop a running bar: fires the cancel callback once and hides the bar.
-- Stopping a bar that is not running only hides it (pool cleanup).
function BarPrototype:Stop()
    if self.running then
        self:_Finish(false)
    else
        self:Hide()
    end
    return self
end

function BarPrototype:SetValue(value)
    value = tonumber(value) or 0
    if value < 0 then value = 0 end
    if self.duration and value > self.duration then value = self.duration end
    self.value = value
    self:_Update()
    return self
end

function BarPrototype:GetValue()
    return self.value
end

function BarPrototype:IsRunning()
    return self.running
end

function BarPrototype:_Update()
    local duration = self.duration or 0
    if duration > 0 then
        self.statusBar:SetValue(self.value / duration)
    else
        self.statusBar:SetValue(0)
    end
    local remaining
    if self.countdown then
        remaining = self.value
    else
        remaining = duration - self.value
    end
    self.time:SetText(formatTime(remaining))
end

function BarPrototype:_Tick()
    if not self.running then return end
    local remaining = (self.exp or now()) - now()
    if remaining <= 0 then
        self.value = self.countdown and 0 or self.duration
        self:_Update()
        self:_Finish(true)
        return
    end
    if self.countdown then
        self.value = remaining
    else
        self.value = self.duration - remaining
    end
    self:_Update()
end

function BarPrototype:_Finish(completed)
    if not self.running then return end
    self.running = false
    if self.updater then
        RGX:CancelTimer(self.updater)
        self.updater = nil
    end
    local callback = completed and self.onComplete or self.onCancel
    if callback then callback(self) end
    self:Hide()
end

RGX:RegisterModule("timers", Timers, { category = "library" })
