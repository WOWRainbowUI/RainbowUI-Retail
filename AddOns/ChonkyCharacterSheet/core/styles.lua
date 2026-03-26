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
local function NormalizeColor(color)
    local r, g, b = color[1], color[2], color[3]
    local lum = GetLuminance(r, g, b)
    local TARGET_LUMINANCE = 0.55
    
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

