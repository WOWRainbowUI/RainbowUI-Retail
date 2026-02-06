--=====================================================================================
-- RGX | Simple Quest Plates! - options_header.lua

-- Author: DonnieDice
-- Description: Options panel header
--=====================================================================================

local addonName, SQP = ...

-- Create panel header section
function SQP:CreatePanelHeader(container)
    local header = CreateFrame("Frame", nil, container, "BackdropTemplate")
    header:SetHeight(100)
    header:SetPoint("TOPLEFT", 10, -10)
    header:SetPoint("TOPRIGHT", -10, -10)
    header:SetBackdrop(self.BACKDROP_DARK)
    header:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    header:SetBackdropBorderColor(unpack(self.SECTION_COLOR))
    
    -- Logo
    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(80, 80)
    logo:SetPoint("LEFT", 15, 0)
    logo:SetTexture("Interface\\AddOns\\SimpleQuestPlates\\images\\icon")
    
    -- Title
    local title = header:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("LEFT", logo, "RIGHT", 15, 15)
    title:SetText("|cff58be81S|r|cffffffffimple |cff58be81Q|r|cffffffffuest |cff58be81P|r|cfffffffflates|r|cff58be81!|r")
    
    -- Set custom font size
    local fontFile, _, fontFlags = title:GetFont()
    title:SetFont(fontFile, 24, fontFlags)
    
    -- Subtitle
    local subtitle = header:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
    subtitle:SetText("Quest tracking overlay for enemy nameplates")
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    
    -- Version
    local version = header:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    version:SetPoint("TOPRIGHT", header, "TOPRIGHT", -15, -15)
    version:SetText("v" .. (SQP.VERSION or "1.0.0"))
    version:SetTextColor(0.5, 0.5, 0.5)
    
    return header
end