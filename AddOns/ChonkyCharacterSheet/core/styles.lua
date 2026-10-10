--[[ 
    This file contains style wrappers and skinning for icons, buttons, etc.
]]
local addonName, ns = ...
local CCS = ns.CCS
local option = function(key) return CCS:GetOptionValue(key) end

function CCS.DarkenColor(color, factor)
    return {
        color[1] * (1 - factor),
        color[2] * (1 - factor),
        color[3] * (1 - factor),
        color[4] or 1
    }
end

function CCS.LightenColor(color, factor)
    return {
        color[1] + (1 - color[1]) * factor,
        color[2] + (1 - color[2]) * factor,
        color[3] + (1 - color[3]) * factor,
        color[4] or 1
    }
end

CCS.StyleColor = {
    normal    = {0.49, 0.196, 0.659, 1},    --7D32A8
    highlight = {0.8, .2, 1, 1},            --CC33FF
    border    = {0.3, 0.1, 0.4, 1},         --4D1A66
}

local function GetLuminance(r, g, b)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b
end

-- Purpose is to normalize bright and dark colors to a target luminance.
-- This is mostly future code in case I need it.
function CCS.NormalizeColor(color)
    local r, g, b = color[1], color[2], color[3]
    local lum = GetLuminance(r, g, b)
    local TARGET_LUMINANCE = 0.75
    
    -- difference from target
    local diff = TARGET_LUMINANCE - lum

    -- scale factor: small adjustments only
    local adjust = diff * 0.5   -- 0.5 = strength of normalization

    if adjust > 0 then
        return CCS.LightenColor(color, adjust)
    else
        return CCS.DarkenColor(color, -adjust)
    end
end

---------------------------------------
-- These are the character stat section header bars.
-- We define them and create a reverse lookup by name
---------------------------------------
CCS.headertexture = 
{  -- Width, Height, Left, Right, Top, Bottom
    [1] = { name = "Arch", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\headerbars.png", map = {441, 68, 0.039665971, 0.960334029, 0.577190542, 0.671766342} },
    [2] = { name = "Castle", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\headerbars.png", map = {446, 64, 0.035490605, 0.966597077, 0.222531293, 0.311543811} },
    [3] = { name = "Fleur", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\headerbars.png", map = {444, 56, 0.037578288, 0.964509395, 0.468706537, 0.546592490} },
    [4] = { name = "Star", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\headerbars.png", map = {459, 50, 0.020876827, 0.979123173, 0.114047288, 0.183588317} },
    [5] = { name = "Steel Beam", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\headerbars.png", map = {441, 55, 0.039665971, 0.960334029, 0.347705146, 0.424200278} },
    [6] = { name = "Stone", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\headerbars.png", map = {449, 60, 0.031315240, 0.968684760, 0.716272601, 0.799721836} },
}

CCS.headertextureByName = {}
for i, entry in ipairs(CCS.headertexture) do
    CCS.headertextureByName[entry.name] = i
end

function CCS:GetHeaderTextureByName(name)
    local idx = CCS.headertextureByName[name]
    if idx then
        return CCS.headertexture[idx]
    end
    return nil
end

---------------------------------------
-- These are the frame header bars. (e.g. Reputation and Token Frames)
-- We define them and create a reverse lookup by name
---------------------------------------
CCS.frameheadertexture = 
{  -- Width, Height, Left, Right, Top, Bottom
    [1] = { name = "Arch", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\frameheaderbars.png", map = {1271, 36, 0.003125, 0.99609375, 0.676923076923077, 0.815384615384615} },
    [2] = { name = "Castle", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\frameheaderbars.png", map = {1272, 33, 0.003125, 0.996875, 0.165384615384615, 0.292307692307692} },
    [3] = { name = "Fleur", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\frameheaderbars.png", map = {1274, 29, 0.00234375, 0.99765625, 0.515384615384615, 0.626923076923077} },
    [4] = { name = "Star", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\frameheaderbars.png", map = {1275, 28, 0.0015625, 0.99765625, 0.0115384615384615, 0.119230769230769} },
    [5] = { name = "Steel Beam", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\frameheaderbars.png", map = {1268, 31, 0.0046875, 0.9953125, 0.338461538461538, 0.457692307692308} },
    [6] = { name = "Stone", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\frameheaderbars.png", map = {1270, 31, 0.00390625, 0.99609375, 0.865384615384615, 0.984615384615385} },
}

CCS.frameheadertextureByName = {}
for i, entry in ipairs(CCS.frameheadertexture) do
    CCS.frameheadertextureByName[entry.name] = i
end

function CCS:GetframeHeaderTextureByName(name)
    local idx = CCS.frameheadertextureByName[name]
    if idx then
        return CCS.frameheadertexture[idx]
    end
    return nil
end


function CCS.RefreshStyleColors()
    local newNormal    = option("button_color")
    local newHighlight = option("highlight_color")
    local newBorder    = option("border_color")
    local cr, cg, cb = GetClassColor(select(2, UnitClass("player")))

    if option("style_class_color") == true then
        newNormal = {cr, cg, cb, 1}
        newBorder = CCS.DarkenColor(newNormal, .25)
        newHighlight = CCS.LightenColor(newNormal, .25)
    end

    CCS.StyleColor.normal    = newNormal    or CCS.StyleColor.normal or {0.49, 0.196, 0.659, 1}
    CCS.StyleColor.highlight = newHighlight or CCS.StyleColor.highlight or {0.8, .2, 1, 1}
    CCS.StyleColor.border    = newBorder    or CCS.StyleColor.border or {0.3, 0.1, 0.4, 1}
end

function CCS:ApplyIconStyle(parent, iconType, iconSize)
    local normalColor = CCS.StyleColor.normal
    local highlightColor = CCS.StyleColor.highlight

    -------------------------------------------------
    -- Background texture (no changes to this at the moment)
    -------------------------------------------------
    local bg = parent.bg or parent:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\bg_square.png")
    bg:SetAllPoints(parent)
    parent.bg = bg

    -------------------------------------------------
    -- Icon texture (white mask for tinting)
    -------------------------------------------------
    local icon = parent.icon or parent:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\white_" .. iconType .. ".png")
    icon:SetPoint("CENTER", parent, "CENTER")
    icon:SetSize(iconSize, iconSize)
    parent.icon = icon

    -------------------------------------------------
    -- Apply normal tint
    -------------------------------------------------
    icon:SetVertexColor(normalColor[1], normalColor[2], normalColor[3], normalColor[4])

    -------------------------------------------------
    -- Hover behavior
    -------------------------------------------------
    parent:SetScript("OnEnter", function(self)
        self.icon:SetVertexColor(highlightColor[1], highlightColor[2], highlightColor[3], highlightColor[4])

        -- Run CCS OnEnter logic if present. It allows us to combine our tinting and any currently present button logic.
        if self._ccs_OnEnter then
            self:_ccs_OnEnter()
        end

    end)

    parent:SetScript("OnLeave", function(self)
        self.icon:SetVertexColor(normalColor[1], normalColor[2], normalColor[3], normalColor[4])

        -- Run CCS OnLeave logic if present.
        if self._ccs_OnLeave then
            self:_ccs_OnLeave()
        end
        
    end)
end

function CCS:SkinBlizzardButton(button, iconType, iconSize)
    local normalColor = CCS.StyleColor.normal
    local highlightColor = CCS.StyleColor.highlight
    local pushedColor = CCS.DarkenColor(normalColor, 0.25)
    
    -------------------------------------------------
    -- Create Button Background
    -------------------------------------------------
    local bg = button.bg or button:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\bg_square.png")
    bg:SetAllPoints(button)
    button.bg = bg
    button.normalColor = normalColor
    button.highlightColor = highlightColor
    button.pushedColor = pushedColor
    -------------------------------------------------
    -- Replace Blizzard textures
    -------------------------------------------------
    local normal = button:GetNormalTexture()
    local highlight = button:GetHighlightTexture()
    local pushed = button:GetPushedTexture()
    
    local tex = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\white_" .. iconType .. ".png"

    normal:ClearAllPoints()
    normal:SetPoint("CENTER", button, "CENTER")
    normal:SetTexture(tex)
    normal:SetSize(iconSize, iconSize)

    if pushed then
        pushed:ClearAllPoints()
        pushed:SetPoint("CENTER", button, "CENTER")
        pushed:SetTexture(tex)
        pushed:SetSize(iconSize, iconSize)
    end

    -- Disable Blizzard's highlight overlay
    local hl = button:GetHighlightTexture()
    if hl then
        hl:SetTexture("")
        hl:SetAlpha(0)
    end

    -------------------------------------------------
    -- Apply normal tint
    -------------------------------------------------
    normal:SetVertexColor(unpack(normalColor))

    -------------------------------------------------
    -- Hook hover logic
    -------------------------------------------------
    if not button.ccsHooked then
        button:HookScript("OnMouseDown", function(self)
            local tex = self:GetPushedTexture()
            if tex then
                tex:SetVertexColor(unpack(self.pushedColor))
            end
        end)

        button:HookScript("OnMouseUp", function(self)
            local tex = self:GetNormalTexture()
            if tex then
                tex:SetVertexColor(unpack(self.normalColor))
            end
        end)
        
        button:HookScript("OnEnter", function(self)
            self:GetNormalTexture():SetVertexColor(unpack(self.highlightColor))
        end)

        button:HookScript("OnLeave", function(self)
            self:GetNormalTexture():SetVertexColor(unpack(self.normalColor))
        end)

        button.ccsHooked = true
    end
end

function CCS.SkinDropdown(dd, name)
    local normalColor = CCS.StyleColor.normal
    local highlightColor = CCS.StyleColor.highlight
    local borderColor = CCS.StyleColor.border
    local pushedColor = CCS.DarkenColor(normalColor, 0.25)

    -- Apply backdrop
    dd:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\UI-Tooltip-SquareBorder.blp",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })

    dd:SetBackdropColor(0.1, 0.1, 0.1, 1)
    dd:SetBackdropBorderColor(unpack(borderColor))

    -- Hide default textures
    local left   = _G[name .. "Left"]
    local middle = _G[name .. "Middle"]
    local right  = _G[name .. "Right"]

    if left then left:Hide() end
    if middle then middle:Hide() end
    if right then right:Hide() end

    -- Style arrow
    local arrow = _G[name .. "Button"]
    if arrow then
        arrow:ClearAllPoints()
        arrow:SetPoint("RIGHT", dd, "RIGHT", -3, 0)
        arrow:SetNormalTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\white_downarrow.png")
        local normal = arrow:GetNormalTexture()
        normal:SetVertexColor(unpack(normalColor))

        local hl = arrow:GetHighlightTexture()
        if hl then
            hl:SetTexture("")
            hl:SetAlpha(0)
        end
        arrow:SetPushedTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\white_downarrow.png")

        local pushed = arrow:GetPushedTexture()
        if pushed then
            pushed:SetPoint("CENTER", arrow, "CENTER", 1, -1)
        end

        arrow.normalColor = normalColor
        arrow.highlightColor = highlightColor
        arrow.pushedColor = pushedColor

        if not arrow.ccsHooked then
            arrow:HookScript("OnMouseDown", function(self)
                local tex = self:GetPushedTexture()
                if tex then
                    tex:SetVertexColor(unpack(self.pushedColor))
                end
            end)

            arrow:HookScript("OnMouseUp", function(self)
                local tex = self:GetNormalTexture()
                if tex then
                    tex:SetVertexColor(unpack(self.normalColor))
                end
            end)
            
            arrow:HookScript("OnEnter", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(self.highlightColor))
            end)

            arrow:HookScript("OnLeave", function(self)
                self:GetNormalTexture():SetVertexColor(unpack(self.normalColor))
            end)

            arrow.ccsHooked = true
        end
    end
end

function CCS.SkinCheckbox(check)
    local normalColor = CCS.StyleColor.normal
    local highlightColor = CCS.StyleColor.highlight
    local borderColor = CCS.StyleColor.border
    -- Apply backdrop
    check:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\UI-Tooltip-SquareBorder.blp",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    check:SetBackdropColor(0.1, 0.1, 0.1, 1)
    check:SetBackdropBorderColor(unpack(borderColor)) -- purple border

    check:SetNormalTexture("")
    check:SetCheckedTexture("")
    check:SetHighlightTexture("")

    -- Apply checkmark textures (optional, theme-ready)
    check:SetCheckedTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\UI-CheckBox-Check")
    check:SetHighlightTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\buttonhilight-square.png")
    check:GetHighlightTexture():SetVertexColor(unpack(highlightColor)) -- Neon purple with transparency
    
    -- Ensure checkmark is centered and sized
    local tex = check:GetCheckedTexture()
    if tex then
        tex:ClearAllPoints()
        tex:SetPoint("CENTER", check, "CENTER", 0, 0)
        tex:SetSize(24, 24)
    end
end

function CCS.SkinButton(button)
    local normalColor = CCS.StyleColor.normal
    local highlightColor = CCS.StyleColor.highlight
    local borderColor = CCS.StyleColor.border

    button.highlightColor = highlightColor
    button.borderColor = borderColor
    
    -- Apply custom backdrop
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\UI-Tooltip-SquareBorder.blp",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    button:SetBackdropColor(0.17, 0.17, 0.17, .9)
    button:SetBackdropBorderColor(unpack(borderColor)) -- default purple

    -- Hover feedback
    if not button.ccsHooked then
        button:HookScript("OnEnter", function(self)
            button:SetBackdropBorderColor(unpack(self.highlightColor)) -- neon purple
        end)
        button:HookScript("OnLeave", function(self)
            button:SetBackdropBorderColor(unpack(self.borderColor)) -- default purple
        end)
         button.ccsHooked = true
    end
    -- Font styling
    local text = button:GetFontString()
    if text then
        text:SetFont(CCS:GetDefaultFontForLocale(), 12, CCS.textoutline)
        text:SetTextColor(1, 1, 1, 1)
    end
end

---------------------------
-- Chonky NineSlice Frame. Creates corners + edges only (no center slice).
-- Uses statbg.png (108x107) as an atlas.
---------------------------
function CCS.CreateChonkyNineSlice(parent)
    -- Reuse existing frame if present
    if parent.ChonkyStatBG then
        parent.ChonkyStatBG:ClearAllPoints()
		parent.ChonkyStatBG:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -27)
		parent.ChonkyStatBG:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 2, 2)
		
        return parent.ChonkyStatBG
    end

    local atlas = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\statbg.png"

    local frame = CreateFrame("Frame", nil, parent)
    parent.ChonkyStatBG = frame

    if parent == PaperDollFrame.TitleManagerPane.ScrollBox then
        frame:SetPoint("TOPLEFT", parent, "TOPLEFT", -2, 0)
        frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 12, 0)
    else
    	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -27)
        frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 2, 2)
    end
    ------------------------------------------------------------
    -- Create slice textures only if they don't already exist
    ------------------------------------------------------------
    local function EnsureTex(name)
        if not frame[name] then
            frame[name] = frame:CreateTexture(nil, "BACKGROUND")
            frame[name]:SetTexture(atlas)
        end
        return frame[name]
    end

    local TL = EnsureTex("TL")
    local T  = EnsureTex("T")
    local TR = EnsureTex("TR")

    local L  = EnsureTex("L")
    local R  = EnsureTex("R")

    local BL = EnsureTex("BL")
    local B  = EnsureTex("B")
    local BR = EnsureTex("BR")

    ------------------------------------------------------------
    -- Set TexCoords
    ------------------------------------------------------------
    TL:SetTexCoord(0/108, 24/108, 0/107, 24/107)
    T:SetTexCoord(24/108, 84/108, 0/107, 24/107)
    TR:SetTexCoord(84/108, 108/108, 0/107, 24/107)

    L:SetTexCoord(0/108, 24/108, 24/107, 83/107)
    R:SetTexCoord(84/108, 108/108, 24/107, 83/107)

    BL:SetTexCoord(0/108, 24/108, 83/107, 107/107)
    B:SetTexCoord(24/108, 84/108, 83/107, 107/107)
    BR:SetTexCoord(84/108, 108/108, 83/107, 107/107)

    ------------------------------------------------------------
    -- Anchor corners (fixed size)
    ------------------------------------------------------------
    TL:SetPoint("TOPLEFT")
    TL:SetSize(24, 24)

    TR:SetPoint("TOPRIGHT")
    TR:SetSize(24, 24)

    BL:SetPoint("BOTTOMLEFT")
    BL:SetSize(24, 24)

    BR:SetPoint("BOTTOMRIGHT")
    BR:SetSize(24, 24)

    ------------------------------------------------------------
    -- Top and bottom edges (fixed height, fixed width)
    ------------------------------------------------------------
    T:SetPoint("TOPLEFT", TL, "TOPRIGHT")
    T:SetPoint("TOPRIGHT", TR, "TOPLEFT")
    T:SetHeight(24)

    B:SetPoint("BOTTOMLEFT", BL, "BOTTOMRIGHT")
    B:SetPoint("BOTTOMRIGHT", BR, "BOTTOMLEFT")
    B:SetHeight(24)

    ------------------------------------------------------------
    -- Left and right edges (stretch vertically)
    ------------------------------------------------------------
    L:SetPoint("TOPLEFT", TL, "BOTTOMLEFT")
    L:SetPoint("BOTTOMLEFT", BL, "TOPLEFT")
    L:SetWidth(24)

    R:SetPoint("TOPRIGHT", TR, "BOTTOMRIGHT")
    R:SetPoint("BOTTOMRIGHT", BR, "TOPRIGHT")
    R:SetWidth(24)

    return frame
end


---------------------------------------
-- These are the buttons at the botom of the character frame.
-- We define them and create a reverse lookup by name
---------------------------------------
CCS.charbutton =
{  -- Width, Height, Left, Right, Top, Bottom
    [1] = { name = "Fleur", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\charbuttons1.png", map = {119, 116, 0.0179948586118252, 0.323907455012853, 0.494208494208494, 0.942084942084942} },
    [2] = { name = "Hammered", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\charbuttons1.png", map = {119, 116, 0.347043701799486, 0.652956298200514, 0.0231660231660232, 0.471042471042471} },
    [3] = { name = "Iron", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\charbuttons1.png", map = {119, 116, 0.0179948586118252, 0.323907455012853, 0.0231660231660232, 0.471042471042471} },
    [4] = { name = "Onyx", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\charbuttons1.png", map = {119, 116, 0.676092544987147, 0.982005141388175, 0.494208494208494, 0.942084942084942} },
    [5] = { name = "Shiny", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\charbuttons1.png", map = {119, 116, 0.676092544987147, 0.982005141388175, 0.0231660231660232, 0.471042471042471} },
    [6] = { name = "Steel Beam", texture = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\charbuttons1.png", map = {119, 116, 0.347043701799486, 0.652956298200514, 0.494208494208494, 0.942084942084942} },
}

CCS.charbuttonByName = {}
for i, entry in ipairs(CCS.charbutton) do
    CCS.charbuttonByName[entry.name] = i
end

function CCS:GetCharButtonTextureByName(name)
    local idx = CCS.charbuttonByName[name]
    if idx then
        return CCS.charbutton[idx]
    end
    return nil
end

function CCS.CharacterButtonsRevert()

    local function UnSkinTab(tab, index)
        ------------------------------------------------------------
        -- Show Blizzard textures
        ------------------------------------------------------------
        if tab.Left then tab.Left:Show() end
        if tab.LeftActive then tab.LeftActive:Show() end
        if tab.LeftHighlight then tab.LeftHighlight:Show() end

        if tab.Middle then tab.Middle:Show() end
        if tab.MiddleActive then tab.MiddleActive:Show() end
        if tab.MiddleHighlight then tab.MiddleHighlight:Show() end

        if tab.Right then tab.Right:Show() end
        if tab.RightActive then tab.RightActive:Show() end
        if tab.RightHighlight then tab.RightHighlight:Show() end

        if tab.Text then tab.Text:Show() end
        
        if tab.Background then tab.Background:Show() end 
        if tab.HighlightTexture then tab.HighlightTexture:SetAlpha(1) end
        if tab.Icon then tab.Icon:Show() end
        if tab.Mask then tab.Mask:Show() end
        if tab.SelectedTexture then tab.SelectedTexture:SetAlpha(1) end
        if tab.TabGlow then tab.TabGlow:Show() end
        
        if tab.CCS_BG then tab.CCS_BG:Hide() end
        if tab.CCS_Icon then tab.CCS_Icon:Hide() end
        if tab.CCS_Highlight then tab.CCS_Highlight:SetAlpha(0) end
        if tab.CCS_Mask then tab.CCS_Mask:Hide() end
        
        tab:SetSize(72, 24)
        
    end
        UnSkinTab(CharacterFrameTab1, 1)
        UnSkinTab(CharacterFrameTab2, 2)
        UnSkinTab(CharacterFrameTab3, 3)

end

function CCS.SkinCharacterButtons()

    local RetailIcons = { 
        [1] = nil,
        [2] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\hands.png",
        [3] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\coins.png",
    }
    local ForeverIcons = { 
        [1] = nil,
        [2] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\hands.png",
        [3] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\Ability_Racial_JackofAllTrades.blp",
        [4] = nil,        
        [5] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\coins.png",        
        [6] = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\stats.png",        
    }
    
    local bgInfo = CCS:GetCharButtonTextureByName(option("tabtex")) -- CCS.charbutton[6]
    local bgTexture = bgInfo.texture
    local bgMap = bgInfo.map  -- {width, height, left, right, top, bottom}
    local maskTex = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\buttonmask1.blp"
    
    local function SkinTab(tab, index)
        if not tab then return end

        ------------------------------------------------------------
        -- Hide Blizzard textures
        ------------------------------------------------------------
        if tab.Left then tab.Left:Hide() end
        if tab.LeftActive then tab.LeftActive:Hide() end
        if tab.LeftHighlight then tab.LeftHighlight:Hide() end

        if tab.Middle then tab.Middle:Hide() end
        if tab.MiddleActive then tab.MiddleActive:Hide() end
        if tab.MiddleHighlight then tab.MiddleHighlight:Hide() end

        if tab.Right then tab.Right:Hide() end
        if tab.RightActive then tab.RightActive:Hide() end
        if tab.RightHighlight then tab.RightHighlight:Hide() end

        if tab.Text then tab.Text:Hide() end
        
        if tab.Background then tab.Background:Hide() end 
        if tab.HighlightTexture then tab.HighlightTexture:SetAlpha(0) end
        if tab.Icon then tab.Icon:Hide() end
        if tab.Mask then tab.Mask:Hide() end
        if tab.SelectedTexture then tab.SelectedTexture:SetAlpha(0) end
        if tab.TabGlow then tab.TabGlow:Hide() end

        ------------------------------------------------------------
        -- Resize tab
        ------------------------------------------------------------
        tab:SetSize(48, 48)
            ------------------------------------------------------------
            -- Create background texture
            ------------------------------------------------------------
            if not tab.CCS_BG then
                tab.CCS_BG = tab:CreateTexture(nil, "BACKGROUND", nil, -8)
            end
                tab.CCS_BG:SetTexture(bgTexture)
                tab.CCS_BG:SetTexCoord(bgMap[3], bgMap[4], bgMap[5], bgMap[6])
                tab.CCS_BG:SetAllPoints()
                tab.CCS_BG:Show()
                
            ------------------------------------------------------------
            -- Create icon texture and apply mask
            ------------------------------------------------------------
            if not tab.CCS_Icon then
                tab.CCS_Icon = tab:CreateTexture(nil, "ARTWORK")
                tab.CCS_Icon:SetPoint("CENTER", tab, "CENTER")
                -- Apply mask to the frame
                tab.CCS_mask = tab:CreateMaskTexture()
            end
                
            -- Tab 1 uses the player portrait
            if index == 1 then
                SetPortraitTexture(tab.CCS_Icon, "player")
                tab.CCS_Icon:SetTexCoord(0.03125, 0.96875, 0.03125, 0.96875)
                tab.CCS_Icon:SetSize(42,42)                
            elseif index == 4 and CCS.CurrentVersion == CCS.FOREVER then
                if UnitFactionGroup("player") == "Alliance" then
                    tab.CCS_Icon:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\INV_AllianceWarEffort.blp")
                else
                    tab.CCS_Icon:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\INV_HordeWarEffort.blp")
                end
                tab.CCS_Icon:SetSize(42,42)
            else
                if CCS.CurrentVersion == CCS.FOREVER then
                    tab.CCS_Icon:SetTexture(ForeverIcons[index])
                else
                    tab.CCS_Icon:SetTexture(RetailIcons[index])
                end
                tab.CCS_Icon:SetSize(42,42)
            end
            tab.CCS_mask:SetTexture(maskTex)
            tab.CCS_mask:SetAllPoints(tab)
            tab.CCS_Icon:AddMaskTexture(tab.CCS_mask)
            tab.CCS_Icon:Show()
            tab.CCS_mask:Show()
            ------------------------------------------------------------
            -- Create highlight texture (always bright yellow)
            ------------------------------------------------------------
            if not tab.CCS_Highlight then
                tab.CCS_Highlight = tab:CreateTexture(nil, "OVERLAY", nil, 7)
            end
            tab.CCS_Highlight:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\buttonhighlight1.png")
            tab.CCS_Highlight:SetPoint("CENTER")
            tab.CCS_Highlight:SetSize(38,38)            
            tab.CCS_Highlight:SetVertexColor(1, 1, 0, 1) -- bright yellow
            tab.CCS_Highlight:SetAlpha(1)
            ------------------------------------------------------------
            -- Tinting logic
            ------------------------------------------------------------
            local function SetNormal()
                local c = CCS.StyleColor.border
                tab.CCS_BG:SetVertexColor(c[1], c[2], c[3], c[4])
                tab.CCS_Highlight:Hide()
            end

            local function SetHover()
                local c = CCS.StyleColor.normal
                tab.CCS_BG:SetVertexColor(c[1], c[2], c[3], c[4])
                tab.CCS_Highlight:Hide()
            end

            local function SetActive()
                tab.CCS_BG:SetVertexColor(1, 1, 1, 1) -- white base
                tab.CCS_Highlight:Show()             -- bright yellow overlay
            end

            ------------------------------------------------------------
            -- Hook scripts
            ------------------------------------------------------------
            if not tab.CCS_Hooked then

                -- Do NOT hover-highlight the selected tab
                tab:HookScript("OnEnter", function()
                    if tab:GetID() == PanelTemplates_GetSelectedTab(CharacterFrame) then
                        SetActive()   -- stay bright yellow
                    else
                        SetHover()    -- normal hover behavior
                    end
                end)

                tab:HookScript("OnLeave", function()
                    if tab:GetID() == PanelTemplates_GetSelectedTab(CharacterFrame) then
                        SetActive()
                    else
                        SetNormal()
                    end
                end)

                tab:HookScript("OnShow", function()
                    if tab:GetID() == PanelTemplates_GetSelectedTab(CharacterFrame) then
                        SetActive()
                    else
                        SetNormal()
                    end
                end)
                if CCS.CurrentVersion ~= CCS.FOREVER then
                    tab:HookScript("OnClick", function()
                        PanelTemplates_SetTab(CharacterFrame, tab:GetID())
                        local tabcount
                        
                        if CCS.CurrentVersion ~= CCS.FOREVER then 
                            tabcount = 3 
                        else
                            tabcount = 6
                        end
                        -- Update all tabs after click
                        for i = 1, tabcount do
                            local t = _G["CharacterFrameTab"..i]
                            if t then
                                if t:GetID() == tab:GetID() then
                                    t.CCS_BG:SetVertexColor(1, 1, 1, 1)
                                    t.CCS_Highlight:Show()
                                else
                                    local bc = CCS.StyleColor.border
                                    t.CCS_BG:SetVertexColor(bc[1], bc[2], bc[3], bc[4])
                                    t.CCS_Highlight:Hide()
                                end
                            end
                        end
                    end)
                else
                    tab:SetScript("OnMouseDown", function()
                       -- PanelTemplates_SetTab(CharacterFrame, tab:GetID())
                        local tabcount = 6

                        for i = 1, tabcount do
                            local t = _G["CharacterFrameModeTab"..i]
                            if t then
                                if t:GetID() == tab:GetID() then
                                    t.CCS_BG:SetVertexColor(1, 1, 1, 1)
                                    t.CCS_Highlight:Show()
                                else
                                    local bc = CCS.StyleColor.border
                                    t.CCS_BG:SetVertexColor(bc[1], bc[2], bc[3], bc[4])
                                    t.CCS_Highlight:Hide()
                                end
                            end
                        end
                    end)                
                end
                tab.CCS_Hooked = true
            end
        
        ------------------------------------------------------------
        -- Initial state
        ------------------------------------------------------------
        if tab:GetID() == PanelTemplates_GetSelectedTab(CharacterFrame) then
            SetActive()
        else
            SetNormal()
        end

    end
   
    ------------------------------------------------------------
    -- Apply to all three tabs
    ------------------------------------------------------------

    if CCS.CurrentVersion == CCS.FOREVER then 
        SkinTab(CharacterFrameModeTab1, 1)
        SkinTab(CharacterFrameModeTab2, 2)
        SkinTab(CharacterFrameModeTab3, 3)
        SkinTab(CharacterFrameModeTab4, 4)
        SkinTab(CharacterFrameModeTab5, 5)
        SkinTab(CharacterFrameModeTab6, 6)    
    
    else
        SkinTab(CharacterFrameTab1, 1)
        SkinTab(CharacterFrameTab2, 2)
        SkinTab(CharacterFrameTab3, 3)
    end
    
end
