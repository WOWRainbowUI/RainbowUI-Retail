local addonName, ns = ...
local CCS = ns.CCS
local L = ns.L  -- grab the localization table
local option = function(key) return CCS:GetOptionValue(key) end

-- Initialize SavedVariables
CCS:InitSavedVariables()

function CCS:tree()
    local CCS_Tree = _G["CCS_Tree"] or CreateFrame("Frame", "CCS_Tree", UIParent, "BackdropTemplate")
    CCS_Tree:SetSize(900, 700)
    CCS_Tree:SetScale(1.10)
    CCS_Tree:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    CCS_Tree:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    CCS_Tree:SetBackdropBorderColor(0.3, 0.1, 0.4, 1) -- purple border

    CCS_Tree:SetMovable(true)
    CCS_Tree:EnableMouse(true)
    CCS_Tree:RegisterForDrag("LeftButton")
    CCS_Tree:SetClampedToScreen(true)
    CCS_Tree:SetScript("OnDragStart", CCS_Tree.StartMoving)
    CCS_Tree:SetScript("OnDragStop", CCS_Tree.StopMovingOrSizing)


    CCS_Tree:EnableKeyboard(true)
    CCS_Tree:SetFrameLevel(0)
    CCS_Tree.name = addonName
    CCS_Tree:SetPropagateKeyboardInput(true)
    CCS_Tree:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            CCS_Tree:Hide()
            CCS_Tree:SetPropagateKeyboardInput(false)
        else
            self:SetPropagateKeyboardInput(true)
        end

    end)
    CCS_Tree:SetFrameStrata("HIGH")
    CCS_Tree:SetFrameLevel(0)

    local CCS_ic_tex1 = _G["CCS_Tree_tex1"] or CCS_Tree:CreateTexture("CCS_Tree_tex1", "BACKGROUND", nil)
    CCS_ic_tex1:SetPoint("TOPLEFT", CCS_Tree, "TOPLEFT")
    CCS_ic_tex1:SetPoint("BOTTOMLEFT", CCS_Tree, "BOTTOMLEFT")    
    CCS_ic_tex1:SetPoint("TOPRIGHT", CCS_Tree, "TOP", 0 , -1)
    CCS_ic_tex1:SetPoint("BOTTOMRIGHT", CCS_Tree, "BOTTOM", 0 , 1)    
    CCS_ic_tex1:SetTexture("Interface\\Masks\\SquareMask.BLP")
    CCS_ic_tex1:SetTexCoord(1,0,0,1)
    CCS_ic_tex1:SetGradient("Horizontal", CreateColor(0.094, 0.031, 0.137, 0.95), CreateColor(0, 0, 0, 1))
    --CCS_ic_tex1:Show()
    
    local CCS_ic_tex2 = _G["CCS_ic_tex2"] or CCS_Tree:CreateTexture("CCS_Tree_tex2", "BACKGROUND", nil)
    CCS_ic_tex2:SetPoint("TOPRIGHT", CCS_Tree, "TOPRIGHT")
    CCS_ic_tex2:SetPoint("BOTTOMRIGHT", CCS_Tree, "BOTTOMRIGHT")
    CCS_ic_tex2:SetPoint("TOPLEFT", CCS_Tree, "TOP", 0 , -1)
    CCS_ic_tex2:SetPoint("BOTTOMLEFT", CCS_Tree, "BOTTOM", 0 , 1)    
    CCS_ic_tex2:SetTexture("Interface\\Masks\\SquareMask.BLP")
    CCS_ic_tex2:SetGradient("Horizontal", CreateColor(0, 0, 0, 1), CreateColor(0.094, 0.031, 0.137, 0.95))
    --CCS_ic_tex2:Show()

    -- Close button
    local closeBtn = CreateFrame("Button", nil, CCS_Tree, "UIPanelCloseButton")
    closeBtn:SetNormalTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\close.png")
    closeBtn:SetHighlightTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\close-h.png")
    closeBtn:SetSize(32, 32)
    closeBtn:SetScale(.5)
    closeBtn:SetPoint("TOPRIGHT", CCS_Tree, "TOPRIGHT", -3, -3)
    closeBtn:Show()
    CCS_Tree:Show()

    -- Tooltip-safe button
    local gemButton = _G["CCS_GemButton"] or CreateFrame("Button", "CCS_GemButton", CCS_Tree, "UIPanelButtonTemplate")
    gemButton:SetSize(120, 24)
    gemButton:SetText("Hover for Gem")
    gemButton:SetPoint("TOPLEFT", CCS_Tree, "TOPLEFT", 20, -20)

    -- Create the tooltip frame once
    local CCStt = CCS:CreateTooltip("CCStt")
    local link = GetInventoryItemLink("player", INVSLOT_LEGS)   
    gemButton:SetScript("OnEnter", function(self)
        CCStt:SetOwner(self, "ANCHOR_RIGHT")
        CCS.RenderSafeTooltip(CCStt, link, "player")
    end)

    gemButton:SetScript("OnLeave", function()
        CCStt:Hide()
    end)

end

-- Debug utility: list all registered events and handlers with version metadata
function CCS:DebugEvents()
    print("|cff00ff00[CCS]|r Registered Events Debug:")

    for event, handlers in pairs(self.RegisteredEvents) do
        if handlers and #handlers > 0 then
            print("Event:", event, " (#handlers:", #handlers, ")")
            for i, fn in ipairs(handlers) do
                -- Try to extract version info if handler was wrapped
                local info = debug.getinfo(fn, "S")
                local source = info and info.short_src or "unknown"

                local verList = fn._ccsVersions and table.concat(fn._ccsVersions, ", ") or "none"
                print("   Handler", i, ":", tostring(fn), "Source:", source, "Versions:", verList)
            end
        else
            print("Event:", event, " (no handlers)")
        end
    end
end


function CCS:ShowFontTester()
    local testerFrame = _G["CCS_FontTester"]

    -- Create frame if it doesn't exist
    if not testerFrame then
        testerFrame = CreateFrame("Frame", "CCS_FontTester", UIParent, "BackdropTemplate")
        testerFrame:SetSize(600, 500)
        testerFrame:SetPoint("CENTER")
        testerFrame:SetBackdrop({
            --bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            bgFile = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\bgtexture.png",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 128,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        --testerFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        testerFrame:SetBackdropBorderColor(1, 1, 1, 1)
        testerFrame:SetMovable(true)
        testerFrame:EnableMouse(true)
        testerFrame:RegisterForDrag("LeftButton")
        testerFrame:SetScript("OnDragStart", testerFrame.StartMoving)
        testerFrame:SetScript("OnDragStop", testerFrame.StopMovingOrSizing)

        -- Close button
        local closeBtn = CreateFrame("Button", nil, testerFrame, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", testerFrame, "TOPRIGHT")

        -- Scroll frame
        local scrollFrame = CreateFrame("ScrollFrame", nil, testerFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 10, -10)
        scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

        -- Scroll child
        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetSize(560, 1000)
        scrollFrame:SetScrollChild(scrollChild)

        testerFrame.scrollChild = scrollChild
        testerFrame.fontStrings = {}
    end

    -- Sort font names alphabetically
    local sortedNames = {}
    for fontName in pairs(CCS.fonts) do
        table.insert(sortedNames, fontName)
    end
    table.sort(sortedNames, function(a, b) return a:lower() < b:lower() end)

    -- Update or create font strings
    local yOffset = -10
    for i, fontName in ipairs(sortedNames) do
        local fontPath = CCS.fonts[fontName]
        local fs = testerFrame.fontStrings[i]

        if not fs then
            fs = testerFrame.scrollChild:CreateFontString(nil, "OVERLAY")
            testerFrame.fontStrings[i] = fs
            fs:SetPoint("TOPLEFT", 10, yOffset)
            yOffset = yOffset - 22
        end

        local success = fs:SetFont(fontPath, 16)
        fs:SetText(i .. ": " .. fontName .. " - " .. (success and "|cff00ff00GOOD|r" or "|cffff0000BAD|r"))
        fs:SetTextColor(1, 1, 1, 1)
    end

    testerFrame:Show()
end

---------------------------
-- Slash Command Handling
---------------------------
SLASH_CHONKYCHARACTERSHEET1 = "/ccs"

SlashCmdList["CHONKYCHARACTERSHEET"] = function(msg)
    local optionsFrame = _G["CCS_Options"] or CreateFrame("Frame", "CCS_Options", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    msg = msg and msg:lower()

    -- Export
    if msg == "export" then
        local exportStr = CCS.ExportProfile(CCS.CurrentProfile)
        if not exportStr or exportStr == "" then
            print("|cffff0000No export data available.|r")
            return
        end
        CCS:ShowExportFrame(exportStr)
        return
    end
    
    if msg == "events" then
        CCS:DebugEvents()
        return
    end
        
    if msg == "inspect" then
        CCS:inspect()
        return
    end

    if msg == "tree" then
        CCS:tree()
        return
    end
    
    -- Import
    if msg == "import" then
        CCS.ShowImportFrame()
        return
    end
    
    if msg:match("^itemstat") then
        local slot = tonumber(msg:match("^itemstat%s+(%d+)$"))

        -- If no slot provided, print usage + slot list
        if not slot then
            print("|c00ff0000Usage: /ccs itemstat <slotNumber>|r")
            print("Available slots:")

            for i = 1, 19 do
                local name = CCS.slotNames[i]
                if name then
                    print(string.format("  %2d = %s", i, name))
                end
            end

            return
        end

        -- If slot provided, run the test
        local stats = CCS:ParseItemStats("player", slot)

        print("---- CCS Item Stat Debug (slot " .. slot .. " = " .. (CCS.slotNames[slot] or "Unknown") .. ") ----")
        for stat, value in pairs(stats) do
            print(stat .. " = " .. tostring(value))
        end
        print("------------------------------------------------------------")
        return
    end
    

    if msg == "fstack" then
        if not C_AddOns.IsAddOnLoaded("Blizzard_DebugTools") then UIParentLoadAddOn("Blizzard_DebugTools") end
            TableAttributeDisplay:SetWidth(1400)
            TableAttributeDisplay.LinesScrollFrame:SetWidth(1330)
            TableAttributeDisplay.LinesScrollFrame.LinesContainer:SetWidth(1200)
        for _, child in ipairs({ TableAttributeDisplay.LinesScrollFrame.LinesContainer:GetChildren() }) do if child.ValueButton and child.ValueButton.Text then child.ValueButton.Text:SetWidth(800) end end
        return
    end

    if msg == "font-test" then
        CCS:ShowFontTester()
        return
    end
    
    if msg == "test" then
        
        -- TEST CODE --
        local unit = UnitExists("target") and "target" or "player"
        local stats = CCS:GetUnitEquipmentStats(unit)
        
        -- END TEST CODE --        
        return
    end

    -- Test
    if msg == "testio" then
        CCS.testExportImport()
        return
    end

    if msg == "eventstats reset" then
        wipe(CCS.EventStats)
        print("Event profiling stats reset.")
        return
    end

    if msg == "eventstats on" then
        CCS.EventStatsEnabled = true
        print("EventStats tracking ENABLED")
        return
    end

    if msg == "eventstats off" then
        CCS.EventStatsEnabled = false
        print("EventStats tracking DISABLED")
        return
    end
    
    if msg == "eventstats" then
        print("Event profiling results:")
        for event, stats in pairs(CCS.EventStats) do
            local avg = stats.avgInterval and string.format("%.1f ms", stats.avgInterval) or "n/a"
            local min = stats.minInterval and string.format("%.1f ms", stats.minInterval) or "n/a"
            local max = stats.maxInterval and string.format("%.1f ms", stats.maxInterval) or "n/a"

            local execAvg = stats.execAvg and string.format("%.3f ms", stats.execAvg) or "n/a"
            local execMin = stats.execMin and string.format("%.3f ms", stats.execMin) or "n/a"
            local execMax = stats.execMax and string.format("%.3f ms", stats.execMax) or "n/a"

            print(
                event,
                "count:", stats.count or 0,
                "avg:", avg,
                "min:", min,
                "max:", max,
                "| exec avg:", execAvg,
                "min:", execMin,
                "max:", execMax
            )
        end
        return
    end
        
    if msg == "eventstats summary" then
        CCS:PrintEventStats()
        return
    end

    if msg == "eventstats top" then
        print("=== Slowest Handlers (Top) ===")

        local sortable = {}

        for eventName, eventStats in pairs(CCS.EventStats) do
            if eventStats.handlers then
                for hkey, hstats in pairs(eventStats.handlers) do
                    table.insert(sortable, {
                        event = eventName,
                        handler = hkey,
                        avg = hstats.execAvg or 0,
                        max = hstats.execMax or 0,
                        count = hstats.execCount or 0,
                    })
                end
            end
        end

        table.sort(sortable, function(a, b)
            return a.avg > b.avg
        end)

        for i, data in ipairs(sortable) do
            print(string.format(
                "%d) %s -> %s | ExecAvg=%.3fms | ExecMax=%.3fms | Count=%d",
                i,
                data.event,
                data.handler,
                data.avg,
                data.max,
                data.count
            ))
        end

        print("=== End Slowest ===")
        return
    end

    
    if msg == "testevents" then
        print("|cff00ff00Running Events Test...|r")

        -- Fire all registered events
        for event, handlers in pairs(CCS.RegisteredEvents) do
            for _, handler in ipairs(handlers) do
                if type(handler) == "function" then
                    local success, err = pcall(handler, event, "arg1", "arg2", "arg3")
                    if not success then
                        print("|cffff0000Event Handler Error:|r", event, err)
                    else
                        print("|cff00ff00Event fired successfully:|r", event, handler)
                    end
                end
            end
        end

        -- Fire custom events explicitly
        print("|cff00ff00Firing custom events CCS_CSHOW and CCS_STATS...|r")
        CCS:FireEvent("CCS_CSHOW")
        CCS:FireEvent("CCS_STATS")

        print("|cff00ff00Events Test Complete.|r")
        return
    end    
    -- Toggle Options Frame
    if optionsFrame then
        if optionsFrame:IsShown() then
            optionsFrame:Hide()
        else
            optionsFrame:Show()
            optionsFrame:SetPropagateKeyboardInput(true)
        end
    end
end

---------------------------
-- Module System
---------------------------

-- Register a module
function CCS:RegisterModule(name, module)
    self.Modules[name] = module
    if module.OnInitialize then
        module:OnInitialize()
    end
end

-- Call a version-specific hook on all modules
function CCS:CallVersionHook(hookName, ...)
    for _, module in pairs(self.Modules) do
        if module.VersionHooks and module.VersionHooks[hookName] then
            local func = module.VersionHooks[hookName][_G.WOW_PROJECT_ID]
            if func then func(...) end
        end
    end
end

---------------------------
-- Version-Specific Module Loader (WoW-Compatible, Debug/Verbose)
---------------------------
do
    local currentVersion = CCS.GetCurrentVersion()
    -- print("|cff00ff00[CCS]|r Current WoW version:", currentVersion)

    local registeredCount = 0

    -- Iterate over all modules already in CCS.Modules
    for moduleName, module in pairs(CCS.Modules) do
        if module then
            -- Check compatibility with current WoW version
            local compatible = true
            if module.CompatibleVersions then
                compatible = false
                for _, v in ipairs(module.CompatibleVersions) do
                    if v == currentVersion or v == CCS.ALL then
                        compatible = true
                        break
                    end
                end
            end

            if compatible then
                -- Register module in CCS
                CCS:RegisterModule(module.Name, module)
                --print("|cff00ff00[CCS]|r Loaded module:", moduleName)
                registeredCount = registeredCount + 1
            else
                --print("|cffffff00[CCS]|r Skipped module (incompatible):", moduleName)
            end
        else
            --print("|cffff0000[CCS]|r Module is nil:", moduleName)
        end
    end

    --print("|cff00ff00[CCS]|r Total modules registered:", registeredCount)
end

