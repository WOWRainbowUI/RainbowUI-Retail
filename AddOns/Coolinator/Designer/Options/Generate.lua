---@class addonTableCoolinator
local addonTable = select(2, ...)

function addonTable.Designer.Options.GenerateOptions(parent, yOffset, xOffset, entries)
  local allFrames = {}

  for _, e in ipairs(entries) do
    local frame
    local function Setter(value)
      if not parent.details then
        return
      end
      local oldValue = e.getter(parent.details)
      e.setter(parent.details, value)
      if type(oldValue) == "table" then
        if not tCompare(oldValue, e.getter(parent.details)) then
          addonTable.Designer.Options.Announce()
        end
      elseif oldValue ~= e.getter(parent.details) then
        addonTable.Designer.Options.Announce()
      end
    end
    local function Getter()
      if not parent.details then
        return
      end
      return e.getter(parent.details)
    end
    if e.hide then
      frame = nil
    elseif e.kind == "slider" then
      if e.valuePattern then
        frame = addonTable.CustomiseDialog.Components.GetSlider(parent, e.label, e.min, e.max, function(val) return e.valuePattern:format(val) end, Setter)
      else
        frame = addonTable.CustomiseDialog.Components.GetSlider(parent, e.label, e.min, e.max, e.formatter, Setter)
      end
    elseif e.kind == "dropdown" then
      frame = addonTable.CustomiseDialog.Components.GetBasicDropdown(parent, e.label, function(value)
        if not parent.details then
          return false
        end
        if type(value) == "table" then
          return tCompare(value, e.getter(parent.details))
        else
          return value == e.getter(parent.details)
        end
      end, Setter)
    elseif e.kind == "checkbox" then
      frame = addonTable.CustomiseDialog.Components.GetCheckbox(parent, e.label, 28 + xOffset, Setter)
    elseif e.kind == "colorPicker" then
      frame = addonTable.CustomiseDialog.Components.GetColorPicker(parent, e.label, 28 + xOffset, Setter)
    elseif e.kind == "colorPickerWithCheckbox" then
      frame = addonTable.CustomiseDialog.Components.GetColorPickerWithCheckbox(parent, e.label, 28 + xOffset, Setter)
    elseif e.kind == "iconTexts" then
      frame = addonTable.Designer.Options.GetIconTextPositioning(parent, 615339)
    elseif e.kind == "barTexts" then
      frame = addonTable.Designer.Options.GetBarTextPositioning(parent, e.texts)
    elseif e.kind == "presets" then
      frame = addonTable.Designer.Options.GetPresets(parent)
    elseif e.kind == "groupVisibility" then
      frame = addonTable.Designer.Options.GetGroupVisibility(parent)
    end

    if frame then
      frame.kind = e.kind
      frame.getInitData = e.getInitData
      frame.Getter = Getter
      if #allFrames == 0 then
        frame:SetPoint("TOP", 0, yOffset)
      else
        frame:SetPoint("TOP", allFrames[#allFrames], "BOTTOM", 0, yOffset)
      end
      table.insert(allFrames, frame)
      yOffset = 0
    elseif e.kind == "spacer" then
      yOffset = -30
    end
  end

  return allFrames
end
