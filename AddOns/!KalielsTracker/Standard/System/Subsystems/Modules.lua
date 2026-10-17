--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local _, KT = ...

local SS = KT:NewSubsystem("Modules")

local db, dbChar

local OTF = KT_ObjectiveTrackerFrame

local function ModuleHeader_OnClick(self)
    local module = self:GetParent()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    KT:Module_SetCollapsed(module)
end

local function Module_SetHeader(module)
    if not module.Header then return end

    module.Header.Text.ClearAllPoints = function() end
    module.Header.Text:SetPoint("LEFT", 10, 1)
    module.Header.Text.SetPoint = function() end
    module.Header.PlayAddAnimation = function() end
    module.Header.MinimizeButton:SetShown(false)
    module.Header.MinimizeButton.SetShown = function() end
    module.Header:SetScript("OnMouseUp", ModuleHeader_OnClick)

    local icon = module.Header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetTexture(KT.MEDIA_PATH.."UI-KT-HeaderButtons")
    icon:SetTexCoord(0.5, 1, 0.75, 1)
    icon:SetPoint("LEFT", -6, 2)
    module.Header.Icon = icon
end

function KT:Module_Setup(moduleName, index)
    local module = _G[moduleName]
    module.uiOrder = index
    self.ObjectiveTrackerManager:SetModuleContainer(module, OTF)
    Module_SetHeader(module)
    self:Module_SetCollapsed(module, dbChar.collapsedModules[moduleName])
end

---Register Tracker Module.
---@param name string Module (frame) name
---@param isDisabled boolean|nil Module state in the tracker (true = disabled, false/nil = enabled)
function KT:Tracker_RegisterModule(name, isDisabled)
    local module = _G[name]
    module.disabled = isDisabled

    tinsert(self.MODULES, name)
    self.db.defaults.char.collapsedModules[name] = false
    self.db:RegisterDefaults(self.db.defaults)
end

---Set module collapsed or expanded.
---@param module table Module object
---@param collapsed boolean|nil Collapsed state (true = collapse, false = expand, nil = toggle)
---@param silent boolean|nil If true, does not save collapsed state
function KT:Module_SetCollapsed(module, collapsed, silent)
    if collapsed == nil then
        module:ToggleCollapsed()
    else
        module:SetCollapsed(collapsed)
    end
    if not silent then
        dbChar.collapsedModules[module.name] = module.isCollapsed
    end
end

---Get module collapsed state.
---@param module table Module object
---@return boolean True is collapsed, false is expanded
function KT:Module_IsCollapsed(module)
    return module:IsCollapsed()
end

---Expand module only if it is currently collapsed.
---@param module table Module object
function KT:Module_Expand(module)
    if self:Module_IsCollapsed(module) then
        self:Module_SetCollapsed(module, false)
    end
end

function KT.Module_Move(idx, direction)
    local tmpIdx = (direction == "up") and idx - 1 or idx + 1

    local moduleName = tremove(db.modulesOrder, idx)
    tinsert(db.modulesOrder, tmpIdx, moduleName)

    OTF.modules[tmpIdx].uiOrder = idx
    OTF.modules[idx].uiOrder = tmpIdx
    OTF.needsSorting = true

    KT:SendSignal("MODULES_ORDER_CHANGED")
    OTF:MarkDirty()
end

function KT.Modules_ReconcileOrder()
    db.modulesOrder = KT.ReconcileOrder(KT.MODULES, db.modulesOrder)
end

function SS:Init()
    db = KT.db.profile
    dbChar = KT.db.char
end