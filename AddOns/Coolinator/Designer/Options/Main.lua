---@class addonTableCoolinator
local addonTable = select(2, ...)

function addonTable.Designer.Options.Announce()
  addonTable.CallbackRegistry:TriggerEvent("Designer.Options.SavePreset")
end

local function GenerateKindOptions(parent, options)
  local container = CreateFrame("Frame", nil, parent)

  local tabManager = CreateFrame("Frame", nil, container)
  tabManager:SetPoint("TOP", 0, -5)
  tabManager:SetPoint("LEFT")
  tabManager:SetPoint("RIGHT")
  tabManager:SetHeight(30)

  local tabs = {}
  local tabMap = {}
  local paths = {
    ["*"] = {
      ["*"] = {}
    }
  }
  local tabsPool = CreateObjectPool(function()
    return addonTable.CustomiseDialog.Components.GetTab(tabManager)
  end, Pool_HideAndClearAnchors)
  local wrappersPool = CreateFramePool("Frame", container)

  container:SetPoint("TOPLEFT", addonTable.Constants.ButtonFrameOffset, -25)
  container:SetPoint("BOTTOMRIGHT")
  for k1, l1 in pairs(options) do
    for k2, l2 in pairs(l1) do
      for _, tabDetails in ipairs(l2) do
        local c = CreateFrame("Frame", nil, container)
        c.label = tabDetails.label
        c:Hide()
        c:SetPoint("LEFT")
        c:SetPoint("RIGHT")
        c.allFrames = addonTable.Designer.Options.GenerateOptions(c, 0, 0, tabDetails.entries)
        function c:UpdateOptions(details)
          c.details = details

          for _, f in ipairs(c.allFrames) do
            if f.getInitData then
              f:Init(f.getInitData(c.details))
            end
            if f.SetValue then
              f:SetValue(f.Getter())
            end
          end
        end
        if not paths[k1] then
          paths[k1] = {}
        end
        if not paths[k1][k2] then
          paths[k1][k2] = {}
        end
        table.insert(paths[k1][k2], c)
      end
    end
  end

  function container:SetTab(label)
    PanelTemplates_SelectTab(tabMap[label].button)
    for _, t in ipairs(tabs ) do
      t:Hide()
      if t.children[1].label ~= label then
        PanelTemplates_DeselectTab(t.button)
      end
    end
    tabMap[label]:Show()
    for _, child in ipairs(tabMap[label].children) do
      child:UpdateOptions(container.details)
    end
  end

  local previousPath = ""

  local function SetupPath(details)
    local newPath = details.resource and (details.resource.kind .. "$" .. (details.resource.resource or "")) or "ALL"
    if newPath == previousPath then
      return
    end
    local rootListing = paths["*"]["*"]
    for _, t in ipairs(tabs) do
      for _, child in ipairs(t.children) do
        child:Hide()
      end
    end
    tabsPool:ReleaseAll()
    wrappersPool:ReleaseAll()
    tabs = {}
    tabMap = {}
    for _, entry in ipairs(rootListing) do
      local wrapper = wrappersPool:Acquire()
      wrapper.button = tabsPool:Acquire()
      wrapper.button:SetText(entry.label)
      wrapper.button:GetScript("OnShow")(wrapper.button) -- auto size
      wrapper.button:Show()
      wrapper:SetAllPoints()
      wrapper.children = {entry}
      entry:SetParent(wrapper)
      entry:SetPoint("TOP", wrapper, 0, -35)
      entry:Show()
      entry:SetHeight(entry.allFrames[1]:GetTop() - entry.allFrames[#entry.allFrames]:GetBottom())
      tabMap[entry.label] = wrapper
      table.insert(tabs, wrapper)
    end
    if details.resource and paths[details.resource.kind] then
      for _, entry in ipairs(paths[details.resource.kind]["*"] or {}) do
        if tabMap[entry.label] then
          local wrapper = tabMap[entry.label]
          entry:SetParent(wrapper)
          entry:SetPoint("TOP", wrapper.children[#wrapper.children], "BOTTOM", 0, -30)
          entry:Show()
          table.insert(wrapper.children, entry)
        else
          local wrapper = wrappersPool:Acquire()
          wrapper.button = tabsPool:Acquire()
          wrapper.button:SetText(entry.label)
          wrapper.button:GetScript("OnShow")(wrapper.button) -- auto size
          wrapper.button:Show()
          wrapper:SetAllPoints()
          wrapper.children = {entry}
          entry:SetParent(wrapper)
          entry:Show()
          entry:SetPoint("TOP", wrapper, 0, -35)
          tabMap[entry.label] = wrapper
          table.insert(tabs, wrapper)
        end
        entry:SetHeight(entry.allFrames[1]:GetTop() - entry.allFrames[#entry.allFrames]:GetBottom())
      end
      if paths[details.resource.kind][details.resource.resource] then
        for _, entry in ipairs(paths[details.resource.kind][details.resource.resource] or {}) do
          if tabMap[entry.label] then
            local wrapper = tabMap[entry.label]
            entry:SetParent(wrapper)
            entry:SetPoint("TOP", wrapper.children[#wrapper.children], "BOTTOM", 0, -30)
            entry:Show()
            table.insert(wrapper.children, entry)
          else
            local wrapper = wrappersPool:Acquire()
            wrapper.button = tabsPool:Acquire()
            wrapper.button:SetText(entry.label)
            wrapper.button:GetScript("OnShow")(wrapper.button) -- auto size
            wrapper.button:Show()
            wrapper:SetAllPoints()
            wrapper.children = {entry}
            entry:SetParent(wrapper)
            entry:Show()
            entry:SetPoint("TOP", wrapper, 0, -35)
            tabMap[entry.label] = wrapper
            table.insert(tabs, wrapper)
          end
          entry:SetHeight(entry.allFrames[1]:GetTop() - entry.allFrames[#entry.allFrames]:GetBottom())
        end
      end
    end
    for _, t in ipairs(tabs) do
      t.button:SetScript("OnClick", function()
        container:SetTab(t.children[1].label)
      end)
    end
    previousPath = newPath
  end

  function container:UpdateOptions(details)
    SetupPath(details)
    container.details = details
    local any = false
    local lastTab
    for _, t in ipairs(tabs) do
      if t:IsShown() then
        any = true
        PanelTemplates_SelectTab(t.button)
        for _, child in ipairs(t.children) do
          child:UpdateOptions(details)
        end
      end
      if not lastTab then
        t.button:SetPoint("TOPLEFT", 20, 0)
      else
        t.button:SetPoint("TOPLEFT", lastTab, "TOPRIGHT", 5, 0)
      end
      lastTab = t.button
    end
    if not any then
      tabs[1].button:Click()
    end
  end

  return container
end

local function GetMetaDetails(detailsList)
  if #detailsList <= 1 then
    return detailsList[1]
  end
  local mapping = {}
  local lastTbl = {}
  local detailsMeta = {
    __newindex = function(tbl, index, value)
      for _, d in ipairs(detailsList) do
        d[index] = value
      end
    end,
    __index = function(tbl, index)
      if index == "___origin" then
        return detailsList[1]
      end
      if type(detailsList[1][index]) == "table" and not index:match("[Cc]olor") then
        if mapping[index] and lastTbl[index] == detailsList[1][index] then
          return mapping[index]
        end
        local list = {}
        for _, details in ipairs(detailsList) do
          table.insert(list, details[index])
        end
        lastTbl[index] = detailsList[1][index]
        mapping[index] = GetMetaDetails(list)
        return mapping[index]
      else
        return detailsList[1][index]
      end
    end,
  }
  local details = {}
  setmetatable(details, detailsMeta)

  return details
end

local optionsFrames = {}
function addonTable.Designer.GenerateOptionsFromDetails(detailsList)
  if optionsFrames[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)] then
    local frame = optionsFrames[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)]
    local oldDetails = frame.details
    frame.details = GetMetaDetails(detailsList)
    if frame.details and (frame.details ~= oldDetails or not frame:IsShown()) then
      frame:Show()
      frame:Update()
    else
      frame:Hide()
    end
    return
  end

  local frame = addonTable.CustomiseDialog.Components.GetContentFrame(
    "CoolinatorDesignerOptionsDialog" .. addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN),
    600, 550
  )
  frame:ClearAllPoints()
  frame:SetPoint("TOPLEFT", 10, -10)
  optionsFrames[addonTable.Config.Get(addonTable.Config.Options.CURRENT_SKIN)] = frame

  local function SetTitle()
    frame:SetTitle(addonTable.Locales.CUSTOMISE_COOLINATOR_X:format(addonTable.Designer.GetLabel(frame.details)))
  end

  local containers = {}
  for kind, o in pairs(addonTable.Designer.WidgetConfiguration) do
    containers[kind] = GenerateKindOptions(frame, o)
    containers[kind]:Hide()
  end

  function frame:Update()
    if not frame.details then
      self:Hide()
      return
    end
    local any = false
    SetTitle()
    for kind, c in pairs(containers) do
      c.details = frame.details
      if frame.details.kind == kind then
        c:Show()
        c:UpdateOptions(frame.details)
      else
        c:Hide()
      end
      any = any or c:IsShown()
    end
    if not any then
      frame:Hide()
    end
  end

  addonTable.CallbackRegistry:RegisterCallback("Designer.Close", function()
    frame.details = nil
    frame:Hide()
  end)

  addonTable.CallbackRegistry:RegisterCallback("Designer.Layout", function()
    if frame:IsVisible() then
      frame:Update()
    end
  end)

  addonTable.CallbackRegistry:RegisterCallback("Designer.Options.SavePreset", function()
    if frame.details and frame.details.preset then
      addonTable.Core.SavePreset(frame.details.preset, frame.details.___origin or frame.details, true)
    end
    addonTable.CallbackRegistry:TriggerEvent("Designer.Layout")
  end)

  frame:SetScript("OnHide", function()
    for kind, c in pairs(containers) do
      c:Hide()
    end
  end)

  frame.details = GetMetaDetails(detailsList)

  frame:Show()
  frame:Update()
end
