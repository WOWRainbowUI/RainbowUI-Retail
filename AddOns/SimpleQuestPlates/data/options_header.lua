--=====================================================================================
-- RGX | Simple Quest Plates! - options_header.lua

-- Author: DonnieDice
-- Description: Options panel header
--=====================================================================================

local addonName, SQP = ...

-- Create panel header section
function SQP:CreatePanelHeader(container)
    local header = CreateFrame("Frame", nil, container, "BackdropTemplate")
    header:SetHeight(42)
    header:SetPoint("TOPLEFT", 10, -10)
    header:SetPoint("TOPRIGHT", -10, -10)
    header:SetBackdrop(self.BACKDROP_DARK)
    header:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
    header:SetBackdropBorderColor(unpack(self.SECTION_COLOR))

    -- Logo
    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(28, 28)
    logo:SetPoint("LEFT", 12, 0)
    logo:SetTexture("Interface\\AddOns\\SimpleQuestPlates\\media\\icon")

    -- Title
    local title = header:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("LEFT", logo, "RIGHT", 8, 4)
    title:SetText(self.L["|cff58be81S|r|cffffffffimple |cff58be81Q|r|cffffffffuest |cff58be81P|r|cfffffffflates|r|cff58be81!|r"])

    -- Set custom font size
    local fontFile, _, fontFlags = title:GetFont()
    title:SetFont(fontFile, 14, fontFlags)

    -- Subtitle
    local subtitle = header:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -1)
    subtitle:SetText(self.L["Quest tracking overlay for enemy nameplates"])
    subtitle:SetTextColor(0.7, 0.7, 0.7)
    subtitle:SetFontObject(GameFontNormalSmall)
    subtitle:SetAlpha(0.85)

    -- Version
    local version = header:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    version:SetPoint("TOPRIGHT", header, "TOPRIGHT", -10, -8)
    version:SetText("v" .. (SQP.VERSION or "1.0.0"))
    version:SetTextColor(0.5, 0.5, 0.5)
    
    return header
end
