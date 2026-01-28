--=====================================================================================
-- RGX | Simple Quest Plates! - options_about.lua
-- Version: 1.0.0
-- Author: DonnieDice
-- Description: About options tab content
--=====================================================================================

local addonName, SQP = ...

-- Create about section
function SQP:CreateAboutSection(content)
    local yOffset = -15
    
    -- About title
    local aboutTitle = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    aboutTitle:SetPoint("TOPLEFT", 20, yOffset)
    aboutTitle:SetText("|cff8B1538RGX |cff58be81Simple Quest Plates!|r")
    yOffset = yOffset - 20
    
    -- Description
    local descFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    descFrame:SetHeight(65)
    descFrame:SetPoint("TOPLEFT", 20, yOffset)
    descFrame:SetPoint("TOPRIGHT", -20, yOffset)
    descFrame:SetBackdrop(self.BACKDROP_DARK)
    descFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    descFrame:SetBackdropBorderColor(unpack(self.SECTION_COLOR))
    
    local descText = descFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    descText:SetPoint("TOPLEFT", descFrame, "TOPLEFT", 10, -10)
    descText:SetPoint("TOPRIGHT", descFrame, "TOPRIGHT", -10, -10)
    descText:SetJustifyH("LEFT")
    descText:SetJustifyV("TOP")
    descText:SetText("Simple Quest Plates displays quest progress icons on enemy nameplates. See at a glance which enemies to defeat, item drops needed, and overall progress.")
    descText:SetWordWrap(true)
    
    yOffset = yOffset - 75
    
    -- Version and Author info
    local infoFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    infoFrame:SetHeight(55)
    infoFrame:SetPoint("TOPLEFT", 20, yOffset)
    infoFrame:SetPoint("TOPRIGHT", -20, yOffset)
    infoFrame:SetBackdrop(self.BACKDROP_DARK)
    infoFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.8)
    infoFrame:SetBackdropBorderColor(0.2, 0.2, 0.2)
    
    local versionText = infoFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    versionText:SetPoint("TOPLEFT", infoFrame, "TOPLEFT", 10, -10)
    versionText:SetText("Version: |cff58be81" .. (SQP.VERSION or "1.0.0") .. "|r")
    
    local authorText = infoFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    authorText:SetPoint("TOPLEFT", versionText, "BOTTOMLEFT", 0, -3)
    authorText:SetText("Author: |cff58be81DonnieDice|r")
    
    local emailText = infoFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    emailText:SetPoint("TOPLEFT", authorText, "BOTTOMLEFT", 0, -3)
    emailText:SetText("Contact: |cff58be81donniedice@protonmail.com|r")
    emailText:SetTextColor(0.7, 0.7, 0.7)
    
    -- No scrolling needed - content fits
end