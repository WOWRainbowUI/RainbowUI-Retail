local MCE = LibStub("AceAddon-3.0"):GetAddon("MinimalistCooldownEdge")
local AssistText = MCE:NewModule("AssistText", "AceHook-3.0")

local ipairs, pairs, pcall, type, wipe = ipairs, pairs, pcall, type, wipe
local setmetatable = setmetatable
local canaccessallvalues = canaccessallvalues

local MAX_OWNER_SCAN_DEPTH = 10

local assistTextOriginalShow = setmetatable({}, { __mode = "k" })
local assistTextOwnerButton = setmetatable({}, { __mode = "k" })

local function CanAccessAllValues(...)
    if not canaccessallvalues then return true end

    local ok, result = pcall(canaccessallvalues, ...)
    return ok and result or false
end

local function GetActionIDFromButton(button)
    if not button then return nil end

    local actionID = button.action
    if type(actionID) == "number" then
        return actionID
    end

    if button.GetAttribute then
        local ok, attr = pcall(button.GetAttribute, button, "action")
        if ok and type(attr) == "number" then
            return attr
        end
    end

    return nil
end

local function GetOwningActionButton(frame)
    local current = frame

    for _ = 1, MAX_OWNER_SCAN_DEPTH do
        if not current then break end
        if GetActionIDFromButton(current) then
            return current
        end
        current = current.GetParent and current:GetParent() or nil
    end

    return nil
end

function MCE:IsAssistedCombatButton(button)
    local actionID = GetActionIDFromButton(button)
    if not actionID
       or not (C_ActionBar and type(C_ActionBar.IsAssistedCombatAction) == "function")
       or not CanAccessAllValues(actionID) then
        return false
    end

    return C_ActionBar.IsAssistedCombatAction(actionID)
end

function MCE:GetAssistedCombatOwnerButton(frame)
    local button = GetOwningActionButton(frame)
    if button and self:IsAssistedCombatButton(button) then
        return button
    end

    return nil
end

local function AssistedTextShowProxy(region, ...)
    local button = assistTextOwnerButton[region]
    if button and MCE:IsAssistedCombatButton(button) then
        return
    end

    local originalShow = assistTextOriginalShow[region]
    if originalShow then
        return originalShow(region, ...)
    end
end

local function SuppressAssistTextRegion(button, region)
    if not region
       or MCE:IsForbidden(region)
       or not region.GetObjectType
       or region:GetObjectType() ~= "FontString" then
        return
    end

    if not assistTextOriginalShow[region] and region.Show then
        assistTextOriginalShow[region] = region.Show
    end

    assistTextOwnerButton[region] = button
    region:Hide()
    region.Show = AssistedTextShowProxy
end

local function SuppressAssistTextInFrame(button, frame)
    if not frame or MCE:IsForbidden(frame) then
        return
    end

    SuppressAssistTextRegion(button, frame.Name)

    if not frame.GetRegions then return end

    for _, region in ipairs({ frame:GetRegions() }) do
        SuppressAssistTextRegion(button, region)
    end
end

function MCE:HideAssistedCombatText(button)
    if not button or MCE:IsForbidden(button) then
        return
    end

    SuppressAssistTextInFrame(button, button)

    local rotationFrame = button.AssistedCombatRotationFrame
    if rotationFrame then
        SuppressAssistTextInFrame(button, rotationFrame)
        SuppressAssistTextInFrame(button, rotationFrame.cooldown or rotationFrame.Cooldown)
        SuppressAssistTextInFrame(button, rotationFrame.chargeCooldown or rotationFrame.ChargeCooldown)
    end

    SuppressAssistTextInFrame(button, button.cooldown or button.Cooldown)
    SuppressAssistTextInFrame(button, button.chargeCooldown or button.ChargeCooldown)
end

function AssistText:OnEnable()
    if ActionButton_UpdateCooldown then
        self:SecureHook("ActionButton_UpdateCooldown", function(button)
            if MCE:IsAssistedCombatButton(button) then
                MCE:HideAssistedCombatText(button)
            end
        end)
    end

    if ActionButton_Update then
        self:SecureHook("ActionButton_Update", function(button)
            if MCE:IsAssistedCombatButton(button) then
                MCE:HideAssistedCombatText(button)
            end
        end)
    end
end

function AssistText:OnDisable()
    for region, originalShow in pairs(assistTextOriginalShow) do
        if region and originalShow and not MCE:IsForbidden(region) then
            region.Show = originalShow
        end
    end

    wipe(assistTextOriginalShow)
    wipe(assistTextOwnerButton)
end
