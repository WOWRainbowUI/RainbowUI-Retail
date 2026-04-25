--[[
    RGX-Framework - Textures Module

    Shared status bar textures and texture-selection helpers for RGX addons.
--]]

local _, Textures = ...
local RGX = _G.RGXFramework

if not RGX then
    error("RGX Textures: RGX-Framework not loaded")
    return
end

Textures.name = "textures"
Textures.version = "1.0.0"
Textures.defaultBar = "Blizzard"
Textures.bars = {}
Textures._lsmImported = false

local function NormalizePath(path)
    if type(path) ~= "string" or path == "" then
        return nil
    end

    return (path:gsub("/", "\\"))
end

local function CopyInfo(info)
    if type(info) ~= "table" then
        return nil
    end

    local copy = {}
    for key, value in pairs(info) do
        copy[key] = value
    end
    return copy
end

local function EnsureBarInfo(name, entry)
    if type(entry) == "table" then
        entry.name = entry.name or name
        entry.path = NormalizePath(entry.path)
        return entry
    end

    return {
        name = name,
        path = NormalizePath(entry),
        source = "RGX-Framework",
        group = "Built-in",
    }
end

function Textures:RegisterBar(name, path, opts)
    if type(name) ~= "string" or name == "" then
        return false
    end

    local normalizedPath = NormalizePath(path)
    if not normalizedPath then
        return false
    end

    opts = opts or {}
    self.bars[name] = {
        name = name,
        path = normalizedPath,
        source = opts.source or "RGX-Framework",
        group = opts.group or opts.source or "Custom",
        description = opts.description,
        previewLabel = opts.previewLabel,
        order = opts.order,
    }

    return true
end

function Textures:RegisterBars(sourceName, bars, opts)
    if type(bars) ~= "table" then
        return false
    end

    local registered = false
    for name, value in pairs(bars) do
        local info = EnsureBarInfo(name, value)
        if info and info.path then
            local merged = CopyInfo(info) or {}
            merged.source = merged.source or sourceName or (opts and opts.source) or "RGX-Framework"
            merged.group = merged.group or sourceName or (opts and opts.group) or "Custom"
            if self:RegisterBar(name, info.path, merged) then
                registered = true
            end
        end
    end

    return registered
end

function Textures:Exists(name)
    return type(name) == "string" and type(self.bars[name]) == "table"
end

function Textures:GetInfo(name)
    local info = self.bars[name]
    if type(info) == "table" then
        return info
    end
    return nil
end

function Textures:GetDefault()
    if self:Exists(self.defaultBar) then
        return self.defaultBar
    end

    for name in pairs(self.bars) do
        return name
    end

    return "Blizzard"
end

function Textures:SetDefault(name)
    if not self:Exists(name) then
        return false
    end

    self.defaultBar = name
    return true
end

function Textures:GetBar(name)
    local resolvedName = name
    if not self:Exists(resolvedName) then
        resolvedName = self:GetDefault()
    end

    local info = self:GetInfo(resolvedName)
    return info and info.path or nil
end

function Textures:GetDefaultPath()
    return self:GetBar(self:GetDefault())
end

function Textures:ListBars()
    local list = {}
    for name in pairs(self.bars) do
        list[#list + 1] = name
    end
    table.sort(list)
    return list
end

function Textures:ListAvailable()
    return self:ListBars()
end

function Textures:GetGroups()
    local groups = {}
    local seen = {}

    for _, info in pairs(self.bars) do
        local group = info.group or info.source or "Other"
        if not seen[group] then
            seen[group] = true
            groups[#groups + 1] = group
        end
    end

    table.sort(groups)
    return groups
end

function Textures:ListByGroup(group)
    local list = {}
    for name, info in pairs(self.bars) do
        local entryGroup = info.group or info.source or "Other"
        if entryGroup == group then
            list[#list + 1] = name
        end
    end
    table.sort(list)
    return list
end

function Textures:GetDropdownItems()
    local items = {}

    for _, group in ipairs(self:GetGroups()) do
        local children = {}
        for _, name in ipairs(self:ListByGroup(group)) do
            local info = self:GetInfo(name) or {}
            children[#children + 1] = {
                value = name,
                text = info.previewLabel or name,
                tooltipTitle = name,
                tooltipText = info.description or info.path,
            }
        end

        items[#items + 1] = {
            text = group,
            notCheckable = true,
            children = children,
        }
    end

    return items
end

function Textures:ImportLibSharedMedia(force)
    if self._lsmImported and not force then
        return true
    end

    local libStubObject = rawget(_G, "LibStub")
    if type(libStubObject) ~= "table" or type(libStubObject.GetLibrary) ~= "function" then
        return false
    end

    local ok, externalLSM = pcall(libStubObject.GetLibrary, libStubObject, "LibSharedMedia-3.0", true)
    if not ok or not externalLSM then
        return false
    end

    local mediaList = externalLSM:List("statusbar") or {}
    for _, mediaName in ipairs(mediaList) do
        local mediaPath = externalLSM:Fetch("statusbar", mediaName, true) or externalLSM:Fetch("statusbar", mediaName)
        if type(mediaPath) == "string" and mediaPath ~= "" then
            self:RegisterBar(mediaName, mediaPath, {
                source = "LibSharedMedia",
                group = "LibSharedMedia",
            })
        end
    end

    self._lsmImported = true
    return true
end

function Textures:ApplyToStatusBar(statusBar, name)
    if not statusBar or type(statusBar.SetStatusBarTexture) ~= "function" then
        return false
    end

    local path = self:GetBar(name)
    if not path then
        return false
    end

    statusBar:SetStatusBarTexture(path)
    return true
end

function Textures:ApplyToTexture(region, name)
    if not region or type(region.SetTexture) ~= "function" then
        return false
    end

    local path = self:GetBar(name)
    if not path then
        return false
    end

    region:SetTexture(path)
    return true
end

function Textures:CreateBarDropdown(parent, opts)
    opts = opts or {}
    parent = parent or UIParent

    local dropdowns = _G.RGXDropdowns or RGX:GetModule("dropdowns")
    if not dropdowns or type(dropdowns.CreateNestedDropdown) ~= "function" then
        return nil
    end

    return dropdowns:CreateNestedDropdown(parent, {
        label = opts.label or "Status Bar Texture",
        width = opts.width or 250,
        height = opts.height or 56,
        buttonWidth = opts.buttonWidth or 190,
        value = opts.value or self:GetDefault(),
        items = function()
            return self:GetDropdownItems()
        end,
        getValueText = function(value)
            return value or self:GetDefault()
        end,
        onChange = function(value, item, holder)
            if type(opts.onChange) == "function" then
                opts.onChange(value, self:GetBar(value), item, holder)
            end
        end,
    })
end

function Textures:CreateBarSettingControl(parent, opts)
    opts = opts or {}
    parent = parent or UIParent

    local holder = CreateFrame("Frame", nil, parent)
    holder:SetSize(opts.width or 250, opts.height or 56)

    local storage = opts.storage
    local key = opts.key
    local defaultName = opts.defaultName or self:GetDefault()

    local function resolveCurrentName()
        if storage and key and type(storage[key]) == "string" and self:Exists(storage[key]) then
            return storage[key]
        end

        if type(opts.value) == "string" and self:Exists(opts.value) then
            return opts.value
        end

        return defaultName
    end

    local dropdown = self:CreateBarDropdown(holder, {
        label = opts.label or "Status Bar Texture",
        width = opts.dropdownWidth or (opts.width or 250) - (opts.showReset == false and 0 or 28),
        buttonWidth = opts.buttonWidth or 180,
        value = resolveCurrentName(),
        onChange = function(barName, barPath, item, dropdownHolder)
            holder.value = barName
            holder.path = barPath

            if storage and key then
                storage[key] = barName
            end

            if type(opts.onChange) == "function" then
                opts.onChange(holder, barName, barPath, item, dropdownHolder)
            end
        end,
    })

    if not dropdown then
        return nil
    end

    dropdown:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
    holder.dropdown = dropdown
    holder.value = resolveCurrentName()
    holder.path = self:GetBar(holder.value)

    if opts.showReset ~= false then
        local reset = CreateFrame("Button", nil, holder, "UIPanelButtonTemplate")
        reset:SetSize(opts.resetWidth or 22, opts.resetHeight or 18)
        reset:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", -2, -18)
        reset:SetText(opts.resetText or "R")
        holder.reset = reset

        reset:SetScript("OnClick", function()
            holder:Reset()
        end)
    end

    function holder:GetValue()
        return self.value
    end

    function holder:GetPath()
        return self.path or Textures:GetBar(self:GetDefaultName())
    end

    function holder:GetDefaultName()
        return defaultName
    end

    function holder:SetValue(barName)
        if type(barName) ~= "string" or not Textures:Exists(barName) then
            barName = defaultName
        end

        self.value = barName
        self.path = Textures:GetBar(barName)

        if storage and key then
            storage[key] = barName
        end

        if self.dropdown and self.dropdown.Refresh then
            self.dropdown:Refresh(barName)
        end
    end

    function holder:Reset()
        self:SetValue(defaultName)
        if type(opts.onReset) == "function" then
            opts.onReset(self, self.value, self.path)
        end
        if type(opts.onChange) == "function" then
            opts.onChange(self, self.value, self.path)
        end
    end

    function holder:SetEnabled(enabled)
        if self.dropdown and self.dropdown.SetEnabled then
            self.dropdown:SetEnabled(enabled)
        end
        if self.reset then
            self.reset:SetEnabled(enabled ~= false)
            self.reset:SetAlpha(enabled ~= false and 1 or 0.5)
        end
    end

    return holder
end

function Textures:AttachBarSelector(parent, db, key, opts)
    opts = opts or {}
    opts.storage = db
    opts.key = key
    return self:CreateBarSettingControl(parent, opts)
end

function Textures:Init()
    self:RegisterBars("RGX-Framework", {
        Blizzard = {
            path = "Interface\\TargetingFrame\\UI-StatusBar",
            description = "Default Blizzard status bar texture.",
        },
        Smooth = {
            path = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
            description = "Rounded smooth raid-frame bar fill.",
        },
        Flat = {
            path = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-Bar",
            description = "Clean flat Blizzard skills bar texture.",
        },
    })

    self:ImportLibSharedMedia()

    RGX:RegisterModule("textures", self)
    _G.RGXTextures = self
    RGX:Debug("Textures: Initialized")
end

Textures:Init()
