local addonName, addon, categoryId, frame = ...
local LSM = LibStub("LibSharedMedia-3.0")
local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)

-- Create the Ace3 Addon object
LibStub("AceAddon-3.0"):NewAddon(addon, addonName, "AceEvent-3.0", "AceConsole-3.0")

function addon:OnInitialize()
    -- Determine if the client is Russian to set default font accordingly
    local isRussian = (GetLocale() == "ruRU")
    local defaultFont = "Pepsi Modern"
    if isRussian then
        defaultFont = "Zero Cool"
    end

    -- Initialize the Database
    -- Note: SavedVariables name must match the .toc file
    self.db = LibStub("AceDB-3.0"):New(addonName .. "DBv1", {
        global = { 
            minimap = { hide = true } 
        },
        profile = {
            enabled = true,
            loadCustomFont = false,
            -- Combat font
            updateWorldText = true, -- Combat Damage Number Font
            fontName = defaultFont,
            fontSize = 1,
            fontGravity = 0.5,
            fontRampDuration = 1.0,
            -- Floating text font
            updateUiText = false,   -- Scrolling Combat Text Font
            uiFont = defaultFont,
            uiOutline = "OUTLINE",
            uiMonochrome = false,
            uiShadowOffset = 1,
        }
    }, true)

    -- Register custom fonts with LibSharedMedia
    self:RegisterFonts()

    -- Create DataBroker object for Minimap/Addon Managers
    self.ldb = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
        type = "launcher",
        icon = "Interface\\Icons\\INV_Scroll_03",
        label = "NiceDamage (Reloaded)",
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("NiceDamage (Reloaded)")
            tooltip:AddLine("|cff888888Click to open settings|r")
        end,
        OnClick = function() self:OpenConfig() end,
    })

    -- Initialize Minimap Icon via LibDBIcon
    self.icon = LibStub("LibDBIcon-1.0")
    self.icon:Register(addonName, self.ldb, self.db.global.minimap)

    -- Register the Options Table with AceConfig
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, self:GetOptions())
    
    -- Add the options to the Blizzard Settings menu
    -- We use the full name here for the display label in the menu
    frame, categoryId = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(addonName, "戰鬥-文字", nil)
	NiceDamageDBv1.categoryID = categoryId -- 自行修改

    -- Register chat commands for easy access
    self:RegisterChatCommand("nd", "OpenConfig")
    self:RegisterChatCommand("nicedamage", "OpenConfig")
    
    -- Apply fonts immediately on load
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "ApplySystemFonts")
    LSM.RegisterCallback(self, "LibSharedMedia_Registered", "ApplySystemFonts") 
    self:ApplySystemFonts()
end

-- Opens the Blizzard Settings category for this addon
function addon:OpenConfig()
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(categoryId)
    end
end

-- Core logic for updating the game engine fonts
function addon:ApplySystemFonts()
    if not self.db.profile.enabled then return end
    
    local fontPath = LSM:Fetch("font", self.db.profile.fontName)
    local sizeScale = tostring(self.db.profile.fontSize or 1)

    local suffix = isRetail and "_v2" or ""
    
    if fontPath then
        -- 1. WORLD TEXT (Damage/Healing numbers floating in the 3D world)
        if self.db.profile.updateWorldText then
            DAMAGE_TEXT_FONT = fontPath
            -- Dynamically set CVars based on the game version
            SetCVar("WorldTextScale" .. suffix, sizeScale)
            SetCVar("WorldTextGravity" .. suffix, tostring(self.db.profile.fontGravity or 0.5))
            SetCVar("WorldTextRampDuration" .. suffix, tostring(self.db.profile.fontRampDuration or 1.0))
        end
                
        -- 2. UI TEXT (Damage received, scrolling combat text on player frame)
        if self.db.profile.updateUiText then

            -- Combine flags
            local flags = self.db.profile.uiOutline or ""
            if self.db.profile.uiMonochrome then
                if flags == "" then
                    flags = "MONOCHROME"
                else
                    flags = flags .. ", MONOCHROME"
                end
            else -- If MONOCHROME is not enabled add SLUG
                if flags == "" then
                    flags = "SLUG"
                else
                    flags = flags .. ", SLUG"
                end
            end


            -- Fetch the specific UI font path
            local uiFontPath = LSM:Fetch("font", self.db.profile.uiFont)
            if uiFontPath then
                local fonts = { CombatTextFont, DamageNumberFont, WorldFont }
                for _, fontObj in ipairs(fonts) do
                    if fontObj then
                        fontObj:SetFont(uiFontPath, 16 ,flags)
                        local off = self.db.profile.uiShadowOffset or 1
                        fontObj:SetShadowOffset(off, -off)
                        fontObj:SetShadowColor(0, 0, 0, 1) -- Black shadow
                    end
                end
            end
        end
    end
end

-- Toggles visibility of the Minimap button
function addon:UpdateMinimapIcon()
    if self.db.global.minimap.hide then
        self.icon:Hide(addonName)
    else
        self.icon:Show(addonName)
    end
end