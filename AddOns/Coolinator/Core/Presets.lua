---@class addonTableCoolinator
local addonTable = select(2, ...)

-- Needed to prevent multi-selected widgets breaking
local function Apply(tbl, to)
  for key, val in pairs(tbl) do
    if type(val) == "table" then
      to[key] = CopyTable(val)
    else
      to[key] = val
    end
  end
end

function addonTable.Core.ApplyPresetToDetails(details)
  local hasAnchor = details.anchor
  local new = CopyTable(addonTable.Core.GetPreset(details))
  new.resource = nil
  new.index = nil
  new.entries = nil
  if not hasAnchor and details.kind == "group" then
    new.anchor = nil
  end
  Apply(new, details)
end

function addonTable.Core.ApplyPresets(design)
  for _, entry in ipairs(design.entries) do
    if entry.preset then
      addonTable.Core.ApplyPresetToDetails(entry)
    end
    if entry.kind == "group" or entry.kind == "stack" then
      addonTable.Core.ApplyPresets(entry)
    end
  end
end

function addonTable.Core.SavePreset(label, details, overwrite)
  local presets = addonTable.Config.Get(addonTable.Config.Options.PRESETS)
  local new = CopyTable(details)
  if details.kind == "group" then
    presets[details.kind] = presets[details.kind] or {}
    new.entries = {}
    if overwrite or not presets["group"][label] then
      presets["group"][label] = new
    end
  elseif details.kind == "icon" then
    presets[details.kind] = presets[details.kind] or {}
    presets[details.kind][details.resource.kind] = presets[details.kind][details.resource.kind] or {}
    if overwrite or not presets["icon"][details.resource.kind][label] then
      presets["icon"][details.resource.kind][label] = new
    end
  elseif details.kind == "bar" then
    presets[details.kind] = presets[details.kind] or {}
    presets[details.kind][details.resource.kind] = presets[details.kind][details.resource.kind] or {}
    if details.resource.kind == "class" then
      presets[details.kind][details.resource.kind][details.resource.resource] = presets[details.kind][details.resource.kind][details.resource.resource] or {}
      if overwrite or not presets[details.kind][details.resource.kind][details.resource.resource][label] then
        presets[details.kind][details.resource.kind][details.resource.resource][label] = new
      end
    else
      if overwrite or not presets[details.kind][details.resource.kind][label] then
        presets[details.kind][details.resource.kind][label] = new
      end
    end
  end
end

function addonTable.Core.GetPreset(details)
  if not details.preset then
    return
  end
  local presets = addonTable.Config.Get(addonTable.Config.Options.PRESETS)
  if details.kind == "group" then
    return presets[details.kind][details.preset]
  elseif details.kind == "icon" then
    return presets[details.kind][details.resource.kind][details.preset]
  elseif details.kind == "bar" then
    if details.resource.kind == "class" then
      return presets[details.kind][details.resource.kind][details.resource.resource][details.preset]
    else
      return presets[details.kind][details.resource.kind][details.preset]
    end
  end
end

function addonTable.Core.GetApplicablePresets(details)
  local presets = addonTable.Config.Get(addonTable.Config.Options.PRESETS)
  if details.kind == "group" then
    return presets[details.kind] or {}
  elseif details.kind == "icon" then
    return presets[details.kind] and presets[details.kind][details.resource.kind] or {}
  elseif details.kind == "bar" then
    if details.resource.kind == "class" then
      return presets[details.kind] and presets[details.kind][details.resource.kind] and presets[details.kind][details.resource.kind][details.resource.resource] or {}
    else
      return presets[details.kind] and presets[details.kind][details.resource.kind] or {}
    end
  end
  return {}
end

function addonTable.Core.GeneratePresetsFromDesign(design, overwrite)
  for _, entry in ipairs(design.entries) do
    if entry.preset then
      addonTable.Core.SavePreset(entry.preset, entry, overwrite)
    end
    if entry.kind == "group" then
      addonTable.Core.GeneratePresetsFromDesign(entry, overwrite)
    end
  end
end

local function RemovePresetFromDesign(label, details, design)
  for _, entry in ipairs(design.entries) do
    if entry.preset and entry.preset == label then
      if entry.kind == details.kind then
        if entry.kind == "group" then
          entry.preset = nil
        elseif entry.kind == "bar" and entry.resource.kind == details.resource.kind then
          if details.resource.kind == "class" and details.resource.resource == entry.resource.resource then
            entry.preset = nil
          else
            entry.preset = nil
          end
        elseif entry.kind == "icon" and entry.resource.kind == details.resource.kind then
          entry.preset = nil
        end
      end
    end
    if entry.kind == "group" then
      RemovePresetFromDesign(label, details, entry)
    end
  end
end

function addonTable.Core.DeletePreset(label, details)
  for specID, designs in pairs(addonTable.Config.Get(addonTable.Config.Options.DESIGNS)) do
    for _, d in pairs(designs) do
      RemovePresetFromDesign(label, details, d)
    end
  end

  local presets = addonTable.Config.Get(addonTable.Config.Options.PRESETS)
  if details.kind == "group" then
    presets[details.kind][label] = nil
  elseif details.kind == "bar" then
    if details.resource.kind == "class" then
      presets[details.kind][details.resource.kind][details.resource.resource][label] = nil
    else
      presets[details.kind][details.resource.kind][label] = nil
    end
  elseif details.kind == "icon" then
    presets[details.kind][details.resource.kind][label] = nil
  end
end

function addonTable.Core.GetPresetsGrouped(presets)
  local group = CopyTable(addonTable.Designer.Defaults.Group)
  group.version = presets.version or 13
  group.layout = "standalone"

  for _, details in pairs(presets["group"] or {}) do
    table.insert(group.entries, details)
  end

  for _, p in pairs(presets["icon"] or {}) do
    for k, details in pairs(p) do
      table.insert(group.entries, details)
    end
  end

  for key, p in pairs(presets["bar"] or {}) do
    if key == "class" then
      for _, p2 in pairs(p) do
        for _, details in pairs(p2) do
          table.insert(group.entries, details)
        end
      end
    else
      for _, details in pairs(p) do
        table.insert(group.entries, details)
      end
    end
  end

  return group
end
