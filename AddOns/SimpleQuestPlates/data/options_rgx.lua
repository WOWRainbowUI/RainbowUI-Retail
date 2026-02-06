--=====================================================================================
-- RGX | Simple Quest Plates! - options_rgx.lua

-- Author: DonnieDice
-- Description: RGX Mods community tab content
--=====================================================================================

local addonName, SQP = ...

-- Create RGX Mods section
function SQP:CreateRGXSection(content)
    local yOffset = -15
    
    -- RGX Mods title
    local rgxTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    rgxTitle:SetPoint("TOPLEFT", 20, yOffset)
    rgxTitle:SetText("|cff58be81RGX Mods Community|r")
    yOffset = yOffset - 20
    
    -- Community description
    local communityFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    communityFrame:SetHeight(45)
    communityFrame:SetPoint("TOPLEFT", 20, yOffset)
    communityFrame:SetPoint("TOPRIGHT", -20, yOffset)
    communityFrame:SetBackdrop(self.BACKDROP_DARK)
    communityFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    communityFrame:SetBackdropBorderColor(unpack(self.SECTION_COLOR))
    
    local communityText = communityFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    communityText:SetPoint("TOPLEFT", communityFrame, "TOPLEFT", 10, -10)
    communityText:SetPoint("TOPRIGHT", communityFrame, "TOPRIGHT", -10, -10)
    communityText:SetJustifyH("LEFT")
    communityText:SetJustifyV("TOP")
    communityText:SetText("RGX Mods creates high-quality WoW addons. Join our Discord for support!")
    communityText:SetWordWrap(true)
    
    yOffset = yOffset - 55
    
    -- Discord section with icon
    local discordFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    discordFrame:SetHeight(60)
    discordFrame:SetPoint("TOPLEFT", 20, yOffset)
    discordFrame:SetPoint("TOPRIGHT", -20, yOffset)
    discordFrame:SetBackdrop(self.BACKDROP_DARK)
    discordFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    discordFrame:SetBackdropBorderColor(unpack(self.SECTION_COLOR))
    
    local discordIcon = discordFrame:CreateTexture(nil, "ARTWORK")
    discordIcon:SetSize(40, 40)
    discordIcon:SetPoint("LEFT", 10, 0)
    discordIcon:SetTexture("Interface\\AddOns\\SimpleQuestPlates\\images\\icon")
    
    local discordText = discordFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    discordText:SetPoint("LEFT", discordIcon, "RIGHT", 10, 8)
    discordText:SetText("|cff58be81Join Our Discord|r")
    
    local discordLink = discordFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    discordLink:SetPoint("TOPLEFT", discordText, "BOTTOMLEFT", 0, -3)
    discordLink:SetText("|cffffffffdiscord.gg/N7kdKAHVVF|r")
    
    -- Tab now fits without scrolling
end