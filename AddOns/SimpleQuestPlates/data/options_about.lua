--=====================================================================================
-- RGX | Simple Quest Plates! - options_about.lua

-- Author: DonnieDice
-- Description: About tab — minimal info + slash commands
--=====================================================================================

local addonName, SQP = ...

function SQP:CreateAboutSection(content)
    local leftColumn = CreateFrame("Frame", nil, content)
    leftColumn:SetPoint("TOPLEFT")
    leftColumn:SetPoint("BOTTOMLEFT")
    leftColumn:SetWidth(280)

    local rightColumn = CreateFrame("Frame", nil, content)
    rightColumn:SetPoint("TOPRIGHT")
    rightColumn:SetPoint("BOTTOMRIGHT")
    rightColumn:SetPoint("LEFT", leftColumn, "RIGHT", 20, 0)

    -- ── LEFT COLUMN ───────────────────────────────────────────────────────────
    local yOffset = -15

    -- Title
    local aboutTitle = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    aboutTitle:SetPoint("TOPLEFT", 20, yOffset)
    aboutTitle:SetText("|cff8B1538RGX |cff58be81Simple Quest Plates!|r")
    yOffset = yOffset - 28

    -- Version + Author
    local versionText = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    versionText:SetPoint("TOPLEFT", 20, yOffset)
    versionText:SetText("v" .. (SQP.VERSION or "1.0.0") .. "  |cffaaaaaaRetail — Warcraft Midnight|r")
    yOffset = yOffset - 20

    local authorText = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    authorText:SetPoint("TOPLEFT", 20, yOffset)
    authorText:SetText("|cff888888By DonnieDice · donniedice@protonmail.com|r")
    yOffset = yOffset - 26

    -- Description
    local descText = leftColumn:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    descText:SetPoint("TOPLEFT", 20, yOffset)
    descText:SetPoint("TOPRIGHT", -10, yOffset)
    descText:SetJustifyH("LEFT")
    descText:SetText("Displays quest progress icons on enemy nameplates.\nPer-type colors, tinting, font, and animation.")
    yOffset = yOffset - 40

    -- RGX Community box
    local communityFrame = CreateFrame("Frame", nil, leftColumn, "BackdropTemplate")
    communityFrame:SetHeight(72)
    communityFrame:SetPoint("TOPLEFT", 20, yOffset)
    communityFrame:SetPoint("TOPRIGHT", -5, yOffset)
    communityFrame:SetBackdrop(self.BACKDROP_DARK)
    communityFrame:SetBackdropColor(0.08, 0.08, 0.12, 0.9)
    communityFrame:SetBackdropBorderColor(unpack(self.SECTION_COLOR))

    local discordIcon = communityFrame:CreateTexture(nil, "ARTWORK")
    discordIcon:SetSize(34, 34)
    discordIcon:SetPoint("LEFT", 10, 0)
    discordIcon:SetTexture("Interface\\AddOns\\SimpleQuestPlates\\media\\icon")

    local discordTitle = communityFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    discordTitle:SetPoint("TOPLEFT", discordIcon, "TOPRIGHT", 8, -4)
    discordTitle:SetText("|cff58be81RGX Mods Community|r")

    local discordDesc = communityFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    discordDesc:SetPoint("TOPLEFT", discordTitle, "BOTTOMLEFT", 0, -3)
    discordDesc:SetText("Join us for support, feedback, and more!")

    local discordLink = communityFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    discordLink:SetPoint("TOPLEFT", discordDesc, "BOTTOMLEFT", 0, -3)
    discordLink:SetText("|cffffffdadiscord.gg/rgxmods|r")

    -- ── RIGHT COLUMN ──────────────────────────────────────────────────────────
    local rightYOffset = -15

    -- Slash Commands box
    local cmdFrame = CreateFrame("Frame", nil, rightColumn, "BackdropTemplate")
    cmdFrame:SetHeight(152)
    cmdFrame:SetPoint("TOPLEFT", 0, rightYOffset)
    cmdFrame:SetPoint("TOPRIGHT", -10, rightYOffset)
    cmdFrame:SetBackdrop(self.BACKDROP_DARK)
    cmdFrame:SetBackdropColor(0.06, 0.06, 0.06, 0.8)
    cmdFrame:SetBackdropBorderColor(0.25, 0.25, 0.25)

    local cmdTitle = cmdFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    cmdTitle:SetPoint("TOPLEFT", cmdFrame, "TOPLEFT", 12, -10)
    cmdTitle:SetText("|cff58be81Slash Commands  |cffaaaaaa/sqp|r")

    local cmdList = cmdFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    cmdList:SetPoint("TOPLEFT", cmdTitle, "BOTTOMLEFT", 0, -6)
    cmdList:SetJustifyH("LEFT")
    cmdList:SetText(
        "|cff58be81/sqp|r               Open options panel\n" ..
        "|cff58be81/sqp on|r / |cff58be81off|r   Enable or disable\n" ..
        "|cff58be81/sqp test|r          Test quest detection\n" ..
        "|cff58be81/sqp reset|r         Reset all settings\n" ..
        "|cff58be81/sqp status|r        Show current settings\n" ..
        "|cff58be81/sqp icon on|r       Show minimap icon\n" ..
        "|cff58be81/sqp scale 1.2|r     Set icon scale\n" ..
        "|cff58be81/sqp offset 0 3|r    Set X / Y offset"
    )
end
