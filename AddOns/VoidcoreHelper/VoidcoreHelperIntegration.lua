-- VoidcoreHelper 插件增强模块
-- 功能：在 KeystoneLoot 副本图标上显示虚空核心掉落信息

local Name, AddOnesTable = ...

-- 创建主框架用于事件监听
local integrationFrame = CreateFrame("Frame")
integrationFrame:RegisterEvent("ADDON_LOADED")

-- 标记插件是否已加载
local voidcoreHelperLoaded = false
local keystoneLootLoaded = false
local hookApplied = false

-- instanceId 到 displayItemID 的映射表
local instanceToDisplayItem = {
    [2526] = 268465, -- 学院
    [658] = 268468,  -- 萨隆矿坑
    [2805] = 268471, -- 风行者之塔
    [2811] = 268466, -- 魔导师平台
    [2915] = 268467, -- 节点
    [2874] = 268473, -- 迈萨拉洞窟
    [1209] = 268470, -- 通天峰
    [1753] = 268469, -- 执政团之座
}

-- teleportSpellId 到 instanceId 的映射表
local spellToInstance = {
    [393273] = 2526,  -- 学院
    [1254555] = 658,  -- 萨隆矿坑
    [1254400] = 2805, -- 风行者之塔
    [1254572] = 2811, -- 魔导师平台
    [1254563] = 2915, -- 节点
    [1254559] = 2874, -- 迈萨拉洞窟
    [159898] = 1209,  -- 通天峰
    [1254551] = 1753, -- 执政团之座
}

-- 检查功能是否启用
--[[local function IsFeatureEnabled()
    return AKJFS_DB and AKJFS_DB.voidcoreHelperIntegration ~= false
end]]

-- Hook 单个按钮的 OnEnter 事件
local function HookButtonOnEnter(button)
    --[[if not IsFeatureEnabled() then
        -- 功能未启用，显示原始 Tooltip
        if button:IsEnabled() and button.teleportSpellId then
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(button.teleportSpellId)
            
            if not IsSpellKnown(button.teleportSpellId) then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(UNAVAILABLE, RED_FONT_COLOR:GetRGB())
            elseif InCombatLockdown() then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(ERR_NOT_IN_COMBAT, RED_FONT_COLOR:GetRGB())
            end
            
            GameTooltip:Show()
            button.UpdateTooltip = button.OnEnter
        end
        return
    end]]
    
    if not button.dungeonDisplayItemID then
        -- 没有映射，显示原始 Tooltip
        if button:IsEnabled() and button.teleportSpellId then
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(button.teleportSpellId)
            
            if not IsSpellKnown(button.teleportSpellId) then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(UNAVAILABLE, RED_FONT_COLOR:GetRGB())
            elseif InCombatLockdown() then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(ERR_NOT_IN_COMBAT, RED_FONT_COLOR:GetRGB())
            end
            
            GameTooltip:Show()
            button.UpdateTooltip = button.OnEnter
        end
        return
    end
    
    -- 显示虚空核心掉落 Tooltip
    local VCH = _G["VoidcoreHelper"] and _G["VoidcoreHelper"].VCH
    if VCH then
        GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
        GameTooltip:SetItemByID(
            button.dungeonDisplayItemID,
            nil,
            16, -- itemContext (神话+)
            VCH.add10 and 10 or 2 -- treasureContextLevel
        )
        GameTooltip:Show()
        button.UpdateTooltip = function() HookButtonOnEnter(button) end
    end
end

-- Hook 已存在的按钮
local function HookExistingButtons()
    --[[if not IsFeatureEnabled() then
        return
    end]]
    
    local keystoneLootFrame = _G["KeystoneLootFrame"]
    if not keystoneLootFrame then
        return
    end
    
    local dungeonsFrame = keystoneLootFrame.DungeonsFrame
    if not dungeonsFrame or not dungeonsFrame.entryPool then
        return
    end
    
    -- 遍历所有激活的副本条目
    for frame in dungeonsFrame.entryPool:EnumerateActive() do
        local teleportButton = frame.TeleportButton
        if teleportButton and teleportButton.teleportSpellId then
            local instanceId = spellToInstance[teleportButton.teleportSpellId]
            if instanceId then
                teleportButton.dungeonInstanceId = instanceId
                teleportButton.dungeonDisplayItemID = instanceToDisplayItem[instanceId]
                
                if teleportButton.dungeonDisplayItemID then
                    -- 替换按钮的 OnEnter 脚本
                    teleportButton:SetScript("OnEnter", function(btn)
                        HookButtonOnEnter(btn)
                    end)
                    
                    teleportButton:SetScript("OnLeave", function(btn)
                        if btn:IsEnabled() then
                            GameTooltip:Hide()
                            btn.UpdateTooltip = nil
                        end
                    end)
                end
            end
        end
    end
end

-- Hook KeystoneLoot 的副本图标按钮
local function HookDungeonTeleportButtons()
    -- 延迟执行，确保 KeystoneLootFrame 已经完全加载
    C_Timer.After(1, function()
        local keystoneLootFrame = _G["KeystoneLootFrame"]
        if not keystoneLootFrame then
            return
        end
        
        local dungeonsFrame = keystoneLootFrame.DungeonsFrame
        if dungeonsFrame then
            -- Hook Refresh 方法
            if dungeonsFrame.Refresh then
                hooksecurefunc(dungeonsFrame, "Refresh", function(self)
                    C_Timer.After(0.3, function()
                        HookExistingButtons()
                    end)
                end)
            end
            
            -- Hook Init 方法
            if dungeonsFrame.Init then
                hooksecurefunc(dungeonsFrame, "Init", function(self)
                    C_Timer.After(0.3, function()
                        HookExistingButtons()
                    end)
                end)
            end
        end
        
        -- Hook KeystoneLootFrame 的显示事件
        keystoneLootFrame:HookScript("OnShow", function()
            C_Timer.After(0.5, function()
                HookExistingButtons()
            end)
        end)
        
        -- 如果界面已经显示，立即尝试 Hook
        if keystoneLootFrame:IsShown() then
            C_Timer.After(0.5, function()
                HookExistingButtons()
            end)
        end
    end)
    
    -- Hook Init 方法（用于新创建的按钮）
    if KeystoneLootTeleportButtonMixin and KeystoneLootTeleportButtonMixin.Init then
        hooksecurefunc(KeystoneLootTeleportButtonMixin, "Init", function(self, dungeon, texture)
            if not IsFeatureEnabled() then
                return
            end
            
            if not self.teleportSpellId then
                return
            end
            
            local instanceId = spellToInstance[self.teleportSpellId]
            if instanceId then
                self.dungeonInstanceId = instanceId
                self.dungeonDisplayItemID = instanceToDisplayItem[instanceId]
                
                if self.dungeonDisplayItemID then
                    -- 直接替换这个按钮的 OnEnter 脚本
                    self:SetScript("OnEnter", function(btn)
                        HookButtonOnEnter(btn)
                    end)
                    
                    self:SetScript("OnLeave", function(btn)
                        if btn:IsEnabled() then
                            GameTooltip:Hide()
                            btn.UpdateTooltip = nil
                        end
                    end)
                end
            end
        end)
    end
end

-- 主 Hook 函数
local function ApplyHooks()
    if hookApplied then
        return
    end
    
    HookDungeonTeleportButtons()
    hookApplied = true
end

-- 事件处理函数
integrationFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" then
        if addonName == "VoidcoreHelper" then
            voidcoreHelperLoaded = true
        end
        
        if addonName == "KeystoneLoot" then
            keystoneLootLoaded = true
        end
        
        -- 如果两个插件都已加载，应用 Hook
        if voidcoreHelperLoaded and keystoneLootLoaded and not hookApplied then
            C_Timer.After(2, ApplyHooks)
        end
    end
end)

-- 如果插件已经加载（热重载情况），立即检查
if C_AddOns and C_AddOns.IsAddOnLoaded then
    if C_AddOns.IsAddOnLoaded("VoidcoreHelper") then
        voidcoreHelperLoaded = true
    end
    
    if C_AddOns.IsAddOnLoaded("KeystoneLoot") then
        keystoneLootLoaded = true
    end
elseif IsAddOnLoaded then
    -- 兼容旧版本 API
    if IsAddOnLoaded("VoidcoreHelper") then
        voidcoreHelperLoaded = true
    end
    
    if IsAddOnLoaded("KeystoneLoot") then
        keystoneLootLoaded = true
    end
end

if voidcoreHelperLoaded and keystoneLootLoaded and not hookApplied then
    C_Timer.After(2, ApplyHooks)
end

-- 导出函数供 Options.lua 使用
if not _G["AKJFS"] then
    _G["AKJFS"] = {}
end

AKJFS.RefreshVoidcoreHelperIntegration = function()
    if hookApplied then
        HookExistingButtons()
    end
end
