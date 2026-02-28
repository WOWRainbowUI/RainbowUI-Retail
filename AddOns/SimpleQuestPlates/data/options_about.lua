--=====================================================================================
-- RGX | Simple Quest Plates! - options_about.lua

-- Author: DonnieDice
-- Description: About tab with description, features, commands, and community links
--=====================================================================================

local addonName, SQP = ...

function SQP:CreateAboutSection(content)
    local yOffset = -15

    -- Title
    local aboutTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    aboutTitle:SetPoint("TOPLEFT", 20, yOffset)
    aboutTitle:SetText("|cff8B1538RGX |cff58be81Simple Quest Plates!|r")
    yOffset = yOffset - 26

    -- Version / Author / Contact box
    local infoFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    infoFrame:SetHeight(60)
    infoFrame:SetPoint("TOPLEFT", 20, yOffset)
    infoFrame:SetPoint("TOPRIGHT", -20, yOffset)
    infoFrame:SetBackdrop(self.BACKDROP_DARK)
    infoFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    infoFrame:SetBackdropBorderColor(0.3, 0.3, 0.3)

    local versionText = infoFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    versionText:SetPoint("TOPLEFT", infoFrame, "TOPLEFT", 12, -10)
    versionText:SetText("Version: |cff58be81" .. (SQP.VERSION or "1.0.0") .. "|r   |cffaaaaaaRetail — The War Within|r")

    local authorText = infoFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    authorText:SetPoint("TOPLEFT", versionText, "BOTTOMLEFT", 0, -4)
    authorText:SetText("Author: |cff58be81DonnieDice|r   |cff888888donniedice@protonmail.com|r")
    yOffset = yOffset - 70

    -- Description box
    local descFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    descFrame:SetHeight(62)
    descFrame:SetPoint("TOPLEFT", 20, yOffset)
    descFrame:SetPoint("TOPRIGHT", -20, yOffset)
    descFrame:SetBackdrop(self.BACKDROP_DARK)
    descFrame:SetBackdropColor(0.06, 0.06, 0.06, 0.8)
    descFrame:SetBackdropBorderColor(0.25, 0.25, 0.25)

    local descText = descFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    descText:SetPoint("TOPLEFT", descFrame, "TOPLEFT", 12, -10)
    descText:SetPoint("TOPRIGHT", descFrame, "TOPRIGHT", -12, -10)
    descText:SetJustifyH("LEFT")
    descText:SetText("Displays quest progress icons on enemy nameplates. Supports kill, item, and percentage quest types with per-type colors, mini icons, icon tinting, font control, and live preview.")
    yOffset = yOffset - 72

    -- Key Features box
    local featFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    featFrame:SetHeight(100)
    featFrame:SetPoint("TOPLEFT", 20, yOffset)
    featFrame:SetPoint("TOPRIGHT", -20, yOffset)
    featFrame:SetBackdrop(self.BACKDROP_DARK)
    featFrame:SetBackdropColor(0.06, 0.06, 0.06, 0.8)
    featFrame:SetBackdropBorderColor(0.25, 0.25, 0.25)

    local featTitle = featFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    featTitle:SetPoint("TOPLEFT", featFrame, "TOPLEFT", 12, -8)
    featTitle:SetText("|cff58be81Key Features|r")

    local featList = featFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    featList:SetPoint("TOPLEFT", featTitle, "BOTTOMLEFT", 0, -4)
    featList:SetPoint("TOPRIGHT", featFrame, "TOPRIGHT", -12, 0)
    featList:SetJustifyH("LEFT")
    featList:SetText(
        "• Kill / item / percent quest tracking with per-type text colors\n" ..
        "• Mini kill & loot icons with individual size, offset, and tint controls\n" ..
        "• Font family, size, outline width, opacity, and outline color\n" ..
        "• Icon mode (jellybean) or Text mode (floating fraction/percent)\n" ..
        "• Animate main icon — pulsing alpha animation on tracked enemy"
    )
    yOffset = yOffset - 110

    -- Commands box
    local cmdFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    cmdFrame:SetHeight(100)
    cmdFrame:SetPoint("TOPLEFT", 20, yOffset)
    cmdFrame:SetPoint("TOPRIGHT", -20, yOffset)
    cmdFrame:SetBackdrop(self.BACKDROP_DARK)
    cmdFrame:SetBackdropColor(0.06, 0.06, 0.06, 0.8)
    cmdFrame:SetBackdropBorderColor(0.25, 0.25, 0.25)

    local cmdTitle = cmdFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    cmdTitle:SetPoint("TOPLEFT", cmdFrame, "TOPLEFT", 12, -8)
    cmdTitle:SetText("|cff58be81Slash Commands  |cffaaaaaa/sqp|r")

    local cmdList = cmdFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    cmdList:SetPoint("TOPLEFT", cmdTitle, "BOTTOMLEFT", 0, -4)
    cmdList:SetJustifyH("LEFT")
    cmdList:SetText(
        "|cff58be81/sqp|r               Open options panel\n" ..
        "|cff58be81/sqp on|r / |cff58be81off|r   Enable or disable\n" ..
        "|cff58be81/sqp test|r          Test quest detection\n" ..
        "|cff58be81/sqp reset|r         Reset all settings to defaults\n" ..
        "|cff58be81/sqp status|r        Show current settings in chat"
    )
    yOffset = yOffset - 110

    -- RGX Community box
    local discordFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    discordFrame:SetHeight(55)
    discordFrame:SetPoint("TOPLEFT", 20, yOffset)
    discordFrame:SetPoint("TOPRIGHT", -20, yOffset)
    discordFrame:SetBackdrop(self.BACKDROP_DARK)
    discordFrame:SetBackdropColor(0.08, 0.08, 0.12, 0.9)
    discordFrame:SetBackdropBorderColor(unpack(self.SECTION_COLOR))

    local discordIcon = discordFrame:CreateTexture(nil, "ARTWORK")
    discordIcon:SetSize(34, 34)
    discordIcon:SetPoint("LEFT", 12, 0)
    discordIcon:SetTexture("Interface\\AddOns\\SimpleQuestPlates\\images\\icon")

    local discordTitle = discordFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    discordTitle:SetPoint("TOPLEFT", discordIcon, "TOPRIGHT", 10, -4)
    discordTitle:SetText("|cff58be81RGX Mods Community|r")

    local discordLink = discordFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    discordLink:SetPoint("TOPLEFT", discordTitle, "BOTTOMLEFT", 0, -3)
    discordLink:SetText("|cffffffffdiscord.gg/N7kdKAHVVF|r   — bug reports, feedback, and more addons")
end
