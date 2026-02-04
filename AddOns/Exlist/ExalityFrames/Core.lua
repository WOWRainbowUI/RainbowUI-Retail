local addonName, ns = ...

---@class ExalityFrames
ns.EXFrames = {}

local BASE_PATH = 'Interface\\Addons\\' .. addonName .. '\\ExalityFrames\\'

local initIndx = 0
ns.EXFrames.frames = {}

ns.EXFrames.config = {}

ns.EXFrames.GetFrame = function(self, id)
  if (not self.frames[id]) then
    initIndx = initIndx + 1
    self.frames[id] = {
      _index = initIndx
    }
  end

  return self.frames[id]
end

ns.EXFrames.InitFrames = function(self)
  for _, frame in self.utils.spairs(self.frames, function(t, a, b) return t[a]._index < t[b]._index end) do
    if (frame.Init) then
      frame:Init()
    end
  end
end

---@param self ExalityFrames
---@param config {logoPath?: string, defaultFontPath?: string}
ns.EXFrames.Configure = function(self, config)
  self.config = config
end

local randCharSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
ns.EXFrames.utils = {
  spairs = function(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do
      keys[#keys + 1] = k
    end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
      table.sort(
        keys,
        function(a, b)
          return order(t, a, b)
        end
      )
    else
      table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
      i = i + 1
      if keys[i] then
        return keys[i], t[keys[i]]
      end
    end
  end,
  generateRandomString = function(length)
    length = length or 10
    local output = ""
    for i = 1, length do
      local rand = math.random(#randCharSet)
      output = output .. string.sub(randCharSet, rand, rand)
    end
    return output
  end,
  animation = {
    getAnimationGroup = function(f)
      return f:CreateAnimationGroup();
    end,
    fade = function(f, duration, from, to, ag)
      ag = ag or f:CreateAnimationGroup()
      local fade = ag:CreateAnimation('Alpha')
      fade:SetFromAlpha(from or 0)
      fade:SetToAlpha(to or 1)
      fade:SetDuration(duration or 1)
      fade:SetSmoothing((from > to) and 'OUT' or 'IN')
      local finishScript = ag:GetScript('OnFinished')
      ag:SetScript(
        'OnFinished',
        function(...)
          if (finishScript) then finishScript(...) end
          f:SetAlpha(to)
        end
      )
      return ag
    end,
    diveIn = function(f, duration, xOff, yOff, smoothing, ag)
      ag = ag or f:CreateAnimationGroup()
      local translate = ag:CreateAnimation('Translation')
      translate:SetOffset(xOff, -yOff)
      translate:SetDuration(duration)
      translate:SetSmoothing(smoothing)
      ag:SetScript('OnPlay', function()
        if (smoothing == 'OUT') then
          return
        end

        for i = 1, f:GetNumPoints() do
          local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(i)
          f:SetPoint(point, relativeTo, relativePoint, xOfs + xOff, yOfs + yOff)
        end
      end)
      local finishScript = ag:GetScript('OnFinished')
      ag:SetScript('OnFinished', function(...)
        if (finishScript) then finishScript(...) end

        if (smoothing == 'OUT') then
          return
        end

        for i = 1, f:GetNumPoints() do
          local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(i)
          f:SetPoint(point, relativeTo, relativePoint, xOfs - xOff, yOfs - yOff)
        end
      end)

      return ag
    end,
    move = function(f, duration, xOff, yOff, ag)
      ag = ag or f:CreateAnimationGroup()
      local translate = ag:CreateAnimation('Translation')
      translate:SetOffset(xOff, yOff)
      translate:SetDuration(duration)
      local finishScript = ag:GetScript('OnFinished')
      ag:SetScript('OnFinished', function(...)
        if (finishScript) then finishScript(...) end

        for i = 1, f:GetNumPoints() do
          local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(i)
          f:SetPoint(point, relativeTo, relativePoint, xOfs + xOff, yOfs + yOff)
        end
      end)

      return ag
    end
  },
  addObserver = function(t, force)
    if (t.observable and not force) then
      return t
    end

    t.observable = {}
    t.Observe = function(_, key, onChangeFunc)
      if (type(key) == 'table') then
        for _, k in ipairs(key) do
          t.observable[k] = t.observable[k] or {}
          table.insert(t.observable[k], onChangeFunc)
        end
      else
        t.observable[key] = t.observable[key] or {}
        table.insert(t.observable[key], onChangeFunc)
      end
    end
    t.SetValue = function(self, key, value)
      local oldValue = t[key]
      t[key] = value
      if (t.observable[key]) then
        for _, func in ipairs(t.observable[key]) do
          func(value, oldValue, key, self)
        end
      end
      if (t.observable['']) then
        for _, func in ipairs(t.observable['']) do
          func(value, oldValue, key, self)
        end
      end
    end
    t.ObserveAll = function(_, onChangeFunc)
      t.observable[''] = t.observable[''] or {}
      table.insert(t.observable[''], onChangeFunc)
    end

    t.ClearObservable = function(self)
      self.observable = {}
    end

    return t
  end,
}

ns.EXFrames.assets = {
  textures = {
    window = {
      bg = BASE_PATH .. 'Assets\\Window\\bg',
      resizeBtn = BASE_PATH .. 'Assets\\Window\\resize-btn',
      resizeBtnHighlight = BASE_PATH .. 'Assets\\Window\\resize-btn-highlight',
    },
    input = {
      buttonBg = BASE_PATH .. 'Assets\\Inputs\\button-bg.png',
      buttonHover = BASE_PATH .. 'Assets\\Inputs\\button-hover.png',
      editBoxBg = BASE_PATH .. 'Assets\\Inputs\\editbox-bg',
      editBoxHover = BASE_PATH .. 'Assets\\Inputs\\editbox-hover',
      toggle = BASE_PATH .. 'Assets\\Inputs\\Toggle\\toggle',
      range = {
        dot = BASE_PATH .. 'Assets\\Inputs\\Range\\dot.png',
        dotActive = BASE_PATH .. 'Assets\\Inputs\\Range\\dot-active.png',
        editBox = BASE_PATH .. 'Assets\\Inputs\\Range\\editbox.png',
        leftArrow = BASE_PATH .. 'Assets\\Inputs\\Range\\left-arrow.png',
        leftArrowActive = BASE_PATH .. 'Assets\\Inputs\\Range\\left-arrow-active.png',
        rightArrow = BASE_PATH .. 'Assets\\Inputs\\Range\\right-arrow.png',
        rightArrowActive = BASE_PATH .. 'Assets\\Inputs\\Range\\right-arrow-active.png',
        track = BASE_PATH .. 'Assets\\Inputs\\Range\\track.png',
      },
      checkbox = {
        base = BASE_PATH .. 'Assets\\Inputs\\Checkbox\\base.png',
        hover = BASE_PATH .. 'Assets\\Inputs\\Checkbox\\hover.png',
        mark = BASE_PATH .. 'Assets\\Inputs\\Checkbox\\mark.png',
      }
    },
    icon = {
      close = BASE_PATH .. 'Assets\\Icon\\close.png',
      chevronDown = BASE_PATH .. 'Assets\\Icon\\chevronDown',
    },
    tabs = {
      active = BASE_PATH .. 'Assets\\Tabs\\active.png',
      inactive = BASE_PATH .. 'Assets\\Tabs\\inactive.png',
    },
    titleBg = BASE_PATH .. 'Assets\\title-bg.png',
    statusBar = BASE_PATH .. 'Assets\\StatusBar\\statusBar',
    solidBg = BASE_PATH .. 'Assets\\white.png',
  },
  backdrop = {
    DEFAULT = {
      bgFile = "Interface\\BUTTONS\\WHITE8X8.blp",
      edgeFile = "Interface\\BUTTONS\\WHITE8X8.blp",
      tile = false,
      tileSize = 0,
      edgeSize = 1,
      insets = { left = 0, right = 0, top = 0, bottom = 0 }
    },
    pixelPerfect = function()
      return {
        bgFile = "Interface\\BUTTONS\\WHITE8X8.blp",
        edgeFile = "Interface\\BUTTONS\\WHITE8X8.blp",
        edgeSize = EXUI:ScalePixel(1)
      }
    end
  },
  font = {
    default = function()
      return ns.EXFrames.config.defaultFontPath or BASE_PATH .. 'Assets\\Font\\DMSans.ttf'
    end,
  }
}

ns.EXFrames.handler = CreateFrame('Frame')
ns.EXFrames.handler:RegisterEvent('ADDON_LOADED')

ns.EXFrames.handler.eventHandlers = {
  --[[
    [event] = {
        [id] = function(event, ...)
    }
    ]]
}

ns.EXFrames.handler:SetScript('OnEvent', function(self, event, ...)
  if (event == 'ADDON_LOADED' and ... == addonName) then
    ns.EXFrames:InitFrames()
  end
end)

--- Callbacks
--[[
    {
        events = { 'event1', 'event2' },
        func = function(event, ...)
    }
]]
ns.EXFrames.callbacks = {}

ns.EXFrames.RegisterCallback = function(self, config)
  table.insert(ns.EXFrames.callbacks, config)
end

ns.EXFrames.Callback = function(self, event, ...)
  for _, callback in ipairs(self.callbacks) do
    if (FindInTable(callback.events, event)) then
      callback.func(event, ...)
    end
  end
end
