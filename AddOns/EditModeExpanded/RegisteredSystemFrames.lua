local addonName, addon = ...

local lib = LibStub:GetLibrary("EditModeExpanded-1.0")

function addon:initSystemFrames()
    local db = addon.db.global
        
    for _, frame in ipairs(EditModeManagerFrame.registeredSystemFrames) do
        local name = frame:GetName()
        
        -- Backward compatibility: frame name was changed from MicroMenu to MicroMenuContainer in 10.1
        if name == "MicroMenuContainer" then
            if db["MicroMenu"] and (not db[name]) then
                db[name] = db["MicroMenu"]
                db["MicroMenu"] = nil
            end
        end
        
        if not db[name] then db[name] = {} end
        lib:RegisterFrame(frame, "", db[name])
    end
    
    -- The earlier RegisterFrame will :SetShown(true) the TalkingHeadFrame if it was set to Hide then unset.
    -- Since its actually not normally shown on login, we will immediately re-hide it again.
    TalkingHeadFrame:Hide()
end

function addon:registerSecureFrameHideable(frame)
    local hidden, toggleInCombat, x, y
    
    local function hide()
        if not x then
            x, y = frame:GetLeft(), frame:GetBottom()
        end
        frame:ClearAllPoints()
        frame:SetClampedToScreen(false)
        frame:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", -1000, -1000)
    end
    
    local function show()
        if not x then return end
        frame:ClearAllPoints()
        frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
        x, y = nil, nil
    end
    
    EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_REGEN_ENABLED", function()
        if not toggleInCombat then return end
        if hidden then
            hide()
        else
            show()
        end
    end)
    EventRegistry:RegisterFrameEventAndCallbackWithHandle("PLAYER_REGEN_DISABLED", function()
        if not toggleInCombat then return end
        if hidden then
            show()
        else
            hide()
        end
    end)
    
    lib:RegisterCustomCheckbox(frame, "隱藏",
        function()
            hidden = true
            if not EditModeManagerFrame.editModeActive then
                hide()
            end
        end,
        function()
            hidden = false
            show()
        end,
        "HidePermanently")
    
    lib:RegisterCustomCheckbox(frame, "戰鬥中隱藏",
        function()
            toggleInCombat = true
        end,
        function()
            toggleInCombat = false
        end,
        "ToggleInCombat")
    
    hooksecurefunc(EditModeManagerFrame, "EnterEditMode", function()
        show()
    end)
    
    hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
        if hidden then
            hide()
        end
    end)
    
    hooksecurefunc(frame, "Show", function()
        if InCombatLockdown() then return end
        if hidden then hide() end
    end)
    
    hooksecurefunc(frame, "SetShown", function()
        if InCombatLockdown() then return end
        if hidden then hide() end
    end)
end
