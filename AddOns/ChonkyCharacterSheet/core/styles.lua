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

CCS.CurrentTheme = CCS.Themes["Darkmoon Faire"]

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

    if CCS.CurrentVersion == CCS.RETAIL then
        CCS.CreateChonkyCharacterBG(false)
        CCS.CreateChonkyCharacterBG(true)
        CCS.CreateChonkyNineSlice(CharacterStatsPane)
        CCS.CreateChonkyNineSlice(CharacterModelFramebg)
        CCS.CreateChonkyNineSlice(InspectModelFramebg)
        CCS.CreateChonkyNineSlice(ccsrf_sf)
        CCS.CreateChonkyNineSlice(ccsm_sf)
        CCS.CreateChonkyNineSlice(ccsmi_sf)
        CCS.CreateChonkyNineSlice(ccsgf_sf)
        CCS.UpdateThemeInfo()
        
    elseif CCS.CurrentVersion == CCS.FOREVER then
        CCS.CreateChonkyCharacterBG(false)
        CCS.CreateChonkyCharacterBG(true)
        CCS.CreateChonkyNineSlice(CharacterStatsPaneScrollBox)
        CCS.CreateChonkyNineSlice(CharacterModelFramebg)
        CCS.CreateChonkyNineSlice(InspectModelFramebg)
        CCS.UpdateThemeInfo()
    end
    
    if (CCS.CurrentVersion == CCS.RETAIL or CCS.CurrentVersion == CCS.FOREVER) and CCS.Themes ~= nil and CCS.Themes.enabled == true and option("theme") ~= "None" then
        newNormal = CCS.CurrentTheme.ncolor
        newBorder = CCS.CurrentTheme.bcolor
        newHighlight = CCS.CurrentTheme.hcolor

    elseif option("style_class_color") == true then
        newNormal = {cr, cg, cb, 1}
        newBorder = CCS.DarkenColor(newNormal, .25)
        newHighlight = CCS.LightenColor(newNormal, .25)

    end

    CCS.StyleColor.normal    = newNormal    or CCS.StyleColor.normal or {0.49, 0.196, 0.659, 1}
    CCS.StyleColor.highlight = newHighlight or CCS.StyleColor.highlight or {0.8, .2, 1, 1}
    CCS.StyleColor.border    = newBorder    or CCS.StyleColor.border or {0.3, 0.1, 0.4, 1}

    if ccsm_sf_bb ~= nil and ccsm_sf_tb ~= nil then
        ccsm_sf_bb:SetVertexColor(unpack(CCS.StyleColor.highlight))
        ccsm_sf_tb:SetVertexColor(unpack(CCS.StyleColor.highlight))
    end

    if ccsmi_sf_bb ~= nil and ccsmi_sf_tb ~= nil then
        ccsmi_sf_bb:SetVertexColor(unpack(CCS.StyleColor.highlight))
        ccsmi_sf_tb:SetVertexColor(unpack(CCS.StyleColor.highlight))
    end
    
    if ccsrf_rf_bb ~= nil and ccsrf_rf_tb ~= nil then
        ccsrf_rf_bb:SetVertexColor(unpack(CCS.StyleColor.highlight))
        ccsrf_rf_tb:SetVertexColor(unpack(CCS.StyleColor.highlight))
    end

    if ccsgf_sf_bb ~= nil and ccsgf_sf_tb ~= nil then
        ccsgf_sf_bb:SetVertexColor(unpack(CCS.StyleColor.highlight))
        ccsgf_sf_tb:SetVertexColor(unpack(CCS.StyleColor.highlight))
    end
    
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
-- Chonky NineSlice Frame.
---------------------------
function CCS.CreateChonkyNineSlice(parent)
    if parent == nil then return end

    local frame = parent.ChonkyNS
    if not frame then
        frame = CreateFrame("Frame", nil, parent)
        parent.ChonkyNS = frame
    end
    local parentname = parent:GetName()
    parent.ChonkyNS:ClearAllPoints()

    if parent == CharacterStatsPaneScrollBox then
        parent.ChonkyNS:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, 0)
        parent.ChonkyNS:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 2)        
    else
        parent.ChonkyNS:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -27)
        parent.ChonkyNS:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 2, 2)
    end

    local theme = CCS.CurrentTheme
    local themeatlas = theme.path .. theme.frame_tl.texture
    local atlas = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\statbg.png"
    local color = {0,0,0,1}
    local path = theme.path
    local slice_tl, slice_t, slice_tr, slice_r, slice_br, slice_b, slice_bl, slice_l
    
    if option("theme") ~= "None" and CCS.Themes.enabled then

        if parent == CharacterModelFramebg 
        or parent == InspectModelFramebg 
        or parent == ccsrf_sf 
        or parent == ccsm_sf 
        or parent == ccsmi_sf 
        or parent == ccsgf_sf 
        then
            themeatlas = theme.path .. theme.paper_tl.texture
            
            frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 3)
            frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 3, -3)            

            frame:SetFrameLevel(10)
           
            slice_tl = theme.paper_tl
            slice_t = theme.paper_t
            slice_tr = theme.paper_tr
            slice_r = theme.paper_r
            slice_br = theme.paper_br
            slice_b = theme.paper_b
            slice_bl = theme.paper_bl
            slice_l = theme.paper_l
            
        elseif parent == CharacterStatsPane or parent == CharacterStatsPaneScrollBox 
            or parent == ccms_world1
            or parent == ccms_world2
            or parent == ccms_world3
            or parent == ccms_r1
            or parent == ccms_r2
            or parent == ccms_r3
            or parent == ccms_raid1
            or parent == ccms_raid2
            or parent == ccms_raid3
        
        then -- Stats section
            color = theme.statbgcolor        
            themeatlas = theme.path .. theme.stats_tl.texture
            frame:SetFrameLevel(2)
            
            if parent == CharacterStatsPaneScrollBox then
                frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, 0)
                frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 2)        
            elseif parent == CharacterStatsPane then
                frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, -27)
                frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 2, 2)
            else
                frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
                frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
                frame:SetFrameLevel(9)
            end

            slice_tl = theme.stats_tl
            slice_t = theme.stats_t
            slice_tr = theme.stats_tr
            slice_r = theme.stats_r
            slice_br = theme.stats_br
            slice_b = theme.stats_b
            slice_bl = theme.stats_bl
            slice_l = theme.stats_l        
        else
            themeatlas = theme.path .. theme.stats_tl.texture
            color = theme.hcolor
            frame:SetPoint("TOPLEFT", parent, "TOPLEFT", -2, 0)
            frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 12, 0)
            frame:SetFrameLevel(2)
        end
    end

    ------------------------------------------------------------
    -- Background texture
    ------------------------------------------------------------
    if (parent == CharacterStatsPane or parent == CharacterStatsPaneScrollBox) and not parent.BG then
        parent.BG = parent:CreateTexture(nil, "BACKGROUND", nil, -1)
    end

    if parent.BG then
        parent.BG:SetTexture("Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\Frame\\vparch.png")
        parent.BG:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
        parent.BG:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)   
        parent.BG:SetVertexColor(color[1],color[2],color[3],color[4] )
        parent.BG:Show()
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

    if option("theme") ~= "None" and CCS.Themes.enabled then
        --------------------------------------------------------------------
        -- TexCoords for the atlas.
        --------------------------------------------------------------------
        local function ApplySlice(tex, slice, path)
            tex:SetTexture(path .. slice.texture)

            if slice.map then
                tex:SetTexCoord(slice.map[3], slice.map[4], slice.map[5], slice.map[6])
                tex:SetSize(slice.map[1], slice.map[2])
            end
        end
        
        ApplySlice(TL, slice_tl, path)
        ApplySlice(T,  slice_t,  path)
        ApplySlice(TR, slice_tr, path)

        ApplySlice(L,  slice_l,  path)
        ApplySlice(R,  slice_r,  path)

        ApplySlice(BL, slice_bl, path)
        ApplySlice(B,  slice_b,  path)
        ApplySlice(BR, slice_br, path)

        --------------------------------------------------------------------
        -- Corners
        --------------------------------------------------------------------
        local width = slice_tl.map[1]
        local height = slice_tl.map[1]    
        
        TL:SetPoint("TOPLEFT", frame, "TOPLEFT", slice_tl.cx,slice_tl.cy)
        TL:SetSize(width, height)

        TR:SetPoint("TOPRIGHT", frame, "TOPRIGHT", slice_tr.cx,slice_tr.cy)
        TR:SetSize(width, height)

        BL:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", slice_bl.cx,slice_bl.cy)
        BL:SetSize(width, height)

        BR:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", slice_br.cx,slice_br.cy)
        BR:SetSize(width, height)
        --------------------------------------------------------------------
        -- Top / Bottom edges
        --------------------------------------------------------------------
        T:SetPoint("TOPLEFT", TL, "TOPRIGHT")
        T:SetPoint("TOPRIGHT", TR, "TOPLEFT")
        T:SetHeight(height)

        B:SetPoint("BOTTOMLEFT", BL, "BOTTOMRIGHT")
        B:SetPoint("BOTTOMRIGHT", BR, "BOTTOMLEFT")
        B:SetHeight(height)

        --------------------------------------------------------------------
        -- Left / Right edges
        --------------------------------------------------------------------
        L:SetPoint("TOPLEFT", TL, "BOTTOMLEFT")
        L:SetPoint("BOTTOMLEFT", BL, "TOPLEFT")
        L:SetWidth(width)

        R:SetPoint("TOPRIGHT", TR, "BOTTOMRIGHT")
        R:SetPoint("BOTTOMRIGHT", BR, "TOPRIGHT")
        R:SetWidth(width)
    else
        local size = 24
        ------------------------------------------------------------
        -- Set TexCoords
        ------------------------------------------------------------
        TL:SetTexture(atlas)
        T:SetTexture(atlas)
        TR:SetTexture(atlas)
        R:SetTexture(atlas)
        BR:SetTexture(atlas)
        B:SetTexture(atlas)
        BL:SetTexture(atlas)
        L:SetTexture(atlas)
        TL:SetTexCoord(0/143, 24/143, 0/143, 24/143)
        T:SetTexCoord(24/143, 119/143, 0/143, 24/143)
        TR:SetTexCoord(119/143, 143/143, 0/143, 24/143)

        L:SetTexCoord(0/143, 24/143, 24/143, 119/143)
        R:SetTexCoord(119/143, 143/143, 24/143, 119/143)

        BL:SetTexCoord(0/143, 24/143, 119/143, 143/143)
        B:SetTexCoord(24/143, 119/143, 119/143, 143/143)
        BR:SetTexCoord(119/143, 143/143, 119/143, 143/143)

        ------------------------------------------------------------
        -- Anchor corners (fixed size)
        ------------------------------------------------------------
        TL:SetPoint("TOPLEFT")
        TL:SetSize(size, size)

        TR:SetPoint("TOPRIGHT")
        TR:SetSize(size, size)

        BL:SetPoint("BOTTOMLEFT")
        BL:SetSize(size, size)

        BR:SetPoint("BOTTOMRIGHT")
        BR:SetSize(size, size)

        ------------------------------------------------------------
        -- Top and bottom edges (fixed height, fixed width)
        ------------------------------------------------------------
        T:SetPoint("TOPLEFT", TL, "TOPRIGHT")
        T:SetPoint("TOPRIGHT", TR, "TOPLEFT")
        T:SetHeight(size)

        B:SetPoint("BOTTOMLEFT", BL, "BOTTOMRIGHT")
        B:SetPoint("BOTTOMRIGHT", BR, "BOTTOMLEFT")
        B:SetHeight(size)

        ------------------------------------------------------------
        -- Left and right edges (stretch vertically)
        ------------------------------------------------------------
        L:SetPoint("TOPLEFT", TL, "BOTTOMLEFT")
        L:SetPoint("BOTTOMLEFT", BL, "TOPLEFT")
        L:SetWidth(size)

        R:SetPoint("TOPRIGHT", TR, "BOTTOMRIGHT")
        R:SetPoint("BOTTOMRIGHT", BR, "TOPRIGHT")
        R:SetWidth(size)
        if parent.BG ~= nil then parent.BG:Hide() end
    end

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
        if CCS.CurrentVersion ~= CCS.FOREVER then
            tab:SetSize(72, 24)  
        else                
            tab:SetSize(48, 48)  
        end
        
    end
    
    if CCS.CurrentVersion == CCS.FOREVER then 
        CharacterFrameModeTabs:ClearAllPoints()
        CharacterFrameModeTabs:SetPoint("TOPLEFT", CharacterFrameBgbg,"TOPRIGHT", 2, -30)
        CharacterFrameModeTab2:ClearAllPoints()
        CharacterFrameModeTab3:ClearAllPoints()
        CharacterFrameModeTab4:ClearAllPoints()
        CharacterFrameModeTab5:ClearAllPoints()
        CharacterFrameModeTab6:ClearAllPoints()
        CharacterFrameModeTab2:SetPoint("TOPLEFT", CharacterFrameModeTab1, "BOTTOMLEFT", 0, -4)
        CharacterFrameModeTab3:SetPoint("TOPLEFT", CharacterFrameModeTab2, "BOTTOMLEFT", 0, -4)
        CharacterFrameModeTab4:SetPoint("TOPLEFT", CharacterFrameModeTab3, "BOTTOMLEFT", 0, -4)
        CharacterFrameModeTab5:SetPoint("TOPLEFT", CharacterFrameModeTab4, "BOTTOMLEFT", 0, -4)
        CharacterFrameModeTab6:SetPoint("TOPLEFT", CharacterFrameModeTab5, "BOTTOMLEFT", 0, -4)
        UnSkinTab(CharacterFrameModeTab1, 1)
        UnSkinTab(CharacterFrameModeTab2, 2)
        UnSkinTab(CharacterFrameModeTab3, 3)
        UnSkinTab(CharacterFrameModeTab4, 4)
        UnSkinTab(CharacterFrameModeTab5, 5)
        UnSkinTab(CharacterFrameModeTab6, 6)
    else
        UnSkinTab(CharacterFrameTab1, 1)
        UnSkinTab(CharacterFrameTab2, 2)
        UnSkinTab(CharacterFrameTab3, 3)
    end

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
                local c = CCS.StyleColor.highlight
                tab.CCS_BG:SetVertexColor(c[1], c[2], c[3], c[4]) -- white base
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
    -- Apply to all tabs
    ------------------------------------------------------------

    if CCS.CurrentVersion == CCS.FOREVER then 
        SkinTab(CharacterFrameModeTab1, 1)
        SkinTab(CharacterFrameModeTab2, 2)
        SkinTab(CharacterFrameModeTab3, 3)
        SkinTab(CharacterFrameModeTab4, 4)
        SkinTab(CharacterFrameModeTab5, 5)
        SkinTab(CharacterFrameModeTab6, 6)    

        CharacterFrameModeTabs:ClearAllPoints()
        CharacterFrameModeTabs:SetPoint("TOPLEFT", CharacterFrameBg,"BOTTOMLEFT", 50, 2)
        CharacterFrameModeTab2:ClearAllPoints()
        CharacterFrameModeTab3:ClearAllPoints()
        CharacterFrameModeTab4:ClearAllPoints()
        CharacterFrameModeTab5:ClearAllPoints()
        CharacterFrameModeTab6:ClearAllPoints()
        CharacterFrameModeTab2:SetPoint("LEFT", CharacterFrameModeTab1, "RIGHT", 1, 0)
        CharacterFrameModeTab3:SetPoint("LEFT", CharacterFrameModeTab2, "RIGHT", 1, 0)
        CharacterFrameModeTab4:SetPoint("LEFT", CharacterFrameModeTab3, "RIGHT", 1, 0)
        CharacterFrameModeTab5:SetPoint("LEFT", CharacterFrameModeTab4, "RIGHT", 1, 0)
        CharacterFrameModeTab6:SetPoint("LEFT", CharacterFrameModeTab5, "RIGHT", 1, 0)
    else
        SkinTab(CharacterFrameTab1, 1)
        SkinTab(CharacterFrameTab2, 2)
        SkinTab(CharacterFrameTab3, 3)
    end
    
end

function CCS.CreateChonkyCharacterBG(isInspect)
    ------------------------------------------------------------
    -- Ensure CharacterFrameBgbg exists (this function loads before characterSheet.lua, so we just create it here.
    ------------------------------------------------------------
    if isInspect == true and ( false or InspectFrame == nil) then return end
    
    local parent
    local bg_name 
    local bg_setpoint
    local bgr, bgg, bgb, bgalpha

    if isInspect then
        bg_name = "InspectFrameBgbg"
        bg_setpoint = InspectFrameBg
        parent = InspectFrame
        bgr, bgg, bgb, bgalpha = unpack(option("bgcolor_inspect"))
    else
        bg_name = "CharacterFrameBgbg"
        bg_setpoint = CharacterFrameBg
        parent = CharacterFrame
        bgr, bgg, bgb, bgalpha = unpack(option("bgcolor"))
    end
    local bg = _G[bg_name]
    
    if not bg then
        bg = CreateFrame("Frame", bg_name, parent, BackdropTemplateMixin and "BackdropTemplate")
        bg:SetAllPoints(bg_setpoint)
        bg:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\AddOns\\ChonkyCharacterSheet\\Media\\Textures\\UI-Tooltip-SquareBorder.blp",
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        
    end

    local bgr, bgg, bgb, bgalpha = option("bgcolor")[1], option("bgcolor")[2], option("bgcolor")[3], option("bgcolor")[4];
    if option("theme") ~= "None" and CCS.Themes.enabled then
        bgr, bgg, bgb, bgalpha = unpack({0,0,0,1})
    end

    local borderColor = CCS.StyleColor.border
    
    if bg.SetBackdrop and bg.SetBackdropColor and bg.SetBackdropBorderColor then
        bg:SetBackdropBorderColor(unpack(borderColor))   -- purple border    
        bg:SetBackdropColor(bgr,bgg,bgb,bgalpha)   -- purple border    
    end
    ------------------------------------------------------------
    -- Get or create ChonkyNS 
    ------------------------------------------------------------
    local ns = parent.ChonkyNS
    if not ns then
        ns = CreateFrame("Frame", nil, parent)
        parent.ChonkyNS = ns
    end

    ns:ClearAllPoints()
    ns:SetAllPoints(bg)
    ns:SetFrameStrata("BACKGROUND")
    ns:SetFrameLevel(3)

    ------------------------------------------------------------
    -- Theme
    ------------------------------------------------------------
    local theme = CCS.CurrentTheme
    local path = theme.path

    ------------------------------------------------------------
    -- Always create slice textures
    ------------------------------------------------------------
    local function EnsureTex(name)
        if not ns[name] then
            ns[name] = ns:CreateTexture(nil, "BORDER")
        end
        return ns[name]
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
    -- Always create overlays inside PaperDollFrame
    ------------------------------------------------------------
    local TopOverlay
    local LeftOverlay
    local RightOverlay
    
    if isInspect == false then
        if not PaperDollFrame.TopOverlay then
            PaperDollFrame.TopOverlay = PaperDollFrame:CreateTexture(nil, "ARTWORK")
        end
        if not PaperDollFrame.LeftOverlay then
            PaperDollFrame.LeftOverlay = PaperDollFrame:CreateTexture(nil, "ARTWORK")
        end
        if not PaperDollFrame.RightOverlay then
            PaperDollFrame.RightOverlay = PaperDollFrame:CreateTexture(nil, "ARTWORK")
        end

        TopOverlay   = PaperDollFrame.TopOverlay
        LeftOverlay  = PaperDollFrame.LeftOverlay
        RightOverlay = PaperDollFrame.RightOverlay
    end
    ------------------------------------------------------------
    -- THEME MODE
    ------------------------------------------------------------
    if option("theme") ~= "None" and CCS.Themes.enabled then
        local function ApplySlice(tex, slice)
            tex:SetTexture(path .. slice.texture)
            tex:SetTexCoord(slice.map[3], slice.map[4], slice.map[5], slice.map[6])
            tex:SetSize(slice.map[1], slice.map[2])
            tex:Show()
        end

        ApplySlice(TL, theme.frame_tl)
        ApplySlice(T,  theme.frame_t)
        ApplySlice(TR, theme.frame_tr)
        ApplySlice(L,  theme.frame_l)
        ApplySlice(R,  theme.frame_r)
        ApplySlice(BL, theme.frame_bl)
        ApplySlice(B,  theme.frame_b)
        ApplySlice(BR, theme.frame_br)

        T:SetTextureSliceMode(1)
        B:SetTextureSliceMode(1)
        L:SetTextureSliceMode(1)
        R:SetTextureSliceMode(1)

        local w = theme.frame_tl.map[1]
        local h = theme.frame_tl.map[2]

        TL:SetPoint("TOPLEFT", ns, "TOPLEFT", theme.frame_tl.cx, theme.frame_tl.cy)
        TR:SetPoint("TOPRIGHT", ns, "TOPRIGHT", theme.frame_tr.cx, theme.frame_tr.cy)
        BL:SetPoint("BOTTOMLEFT", ns, "BOTTOMLEFT", theme.frame_bl.cx, theme.frame_bl.cy)
        BR:SetPoint("BOTTOMRIGHT", ns, "BOTTOMRIGHT", theme.frame_br.cx, theme.frame_br.cy)

        TL:SetSize(w, h)
        TR:SetSize(w, h)
        BL:SetSize(w, h)
        BR:SetSize(w, h)

        T:SetPoint("TOPLEFT", TL, "TOPRIGHT")
        T:SetPoint("TOPRIGHT", TR, "TOPLEFT")
        T:SetHeight(h)

        B:SetPoint("BOTTOMLEFT", BL, "BOTTOMRIGHT")
        B:SetPoint("BOTTOMRIGHT", BR, "BOTTOMLEFT")
        B:SetHeight(h)

        L:SetPoint("TOPLEFT", TL, "BOTTOMLEFT")
        L:SetPoint("BOTTOMLEFT", BL, "TOPLEFT")
        L:SetWidth(w)

        R:SetPoint("TOPRIGHT", TR, "BOTTOMRIGHT")
        R:SetPoint("BOTTOMRIGHT", BR, "TOPRIGHT")
        R:SetWidth(w)
        ---------------------------
        -- Only adjust for Character frame
        ---------------------------
        if isInspect == false then
            local top_scale = option("top_tex_scale") or 1
            local left_scale = option("left_tex_scale") or 1
            local right_scale = option("right_tex_scale") or 1
            local t_xoff = option("top_tex_xoff") or 0
            local t_yoff = option("top_tex_yoff") or 0
            local l_xoff = option("left_tex_xoff") or 0
            local l_yoff = option("left_tex_yoff") or 0
            local r_xoff = option("right_tex_xoff") or 0
            local r_yoff = option("right_tex_yoff") or 0
            
            TopOverlay:SetTexture(path .. theme.frame_top_img.texture)
            TopOverlay:SetSize(theme.frame_top_img.w, theme.frame_top_img.h)
            TopOverlay:SetScale(top_scale)

            TopOverlay:SetPoint("BOTTOM", CharacterFrameBg, "TOP", theme.frame_top_img.cx / top_scale + t_xoff, theme.frame_top_img.cy/top_scale + t_yoff)
            TopOverlay:SetPoint("CENTER", CharacterFrameTitleText, "CENTER", theme.frame_top_img.cx / top_scale + t_xoff,0)
            TopOverlay:Show()
            LeftOverlay:SetTexture(path .. theme.frame_left_img.texture)
            LeftOverlay:SetSize(theme.frame_left_img.w, theme.frame_left_img.h)
            LeftOverlay:SetScale(left_scale)            
            LeftOverlay:SetPoint("RIGHT", bg_setpoint, "LEFT", theme.frame_left_img.cx/left_scale + l_xoff, theme.frame_left_img.cy/left_scale + l_yoff)
            LeftOverlay:Show()

            RightOverlay:SetTexture(path .. theme.frame_right_img.texture)
            RightOverlay:SetSize(theme.frame_right_img.w, theme.frame_right_img.h)
            RightOverlay:SetScale(right_scale)                        
            RightOverlay:SetPoint("LEFT", bg_setpoint, "RIGHT", theme.frame_right_img.cx/right_scale + r_xoff, theme.frame_right_img.cy/right_scale + r_yoff)
            RightOverlay:Show()
        end
    ------------------------------------------------------------
    -- FALLBACK MODE
    ------------------------------------------------------------
    else
        if isInspect == false then
            TopOverlay:Hide()
            LeftOverlay:Hide()
            RightOverlay:Hide()
        end
            ns:Hide()
        
    end
    if InspectFrame ~= nil and InspectFrame.ChonkyNS ~= nil then InspectFrame.ChonkyNS:SetShown(option("show_inspect_frame"))  end
	if InspectModelFramebg.ChonkyNS ~= nil then InspectModelFramebg.ChonkyNS:SetShown(option("show_paperdolli_border"))  end        

end

function CCS.UpdateThemeInfo()

    if CCS.CurrentVersion == CCS.RETAIL then
        if CharacterModelFramebg == nil or CharacterFrameBgbg == nil or CharacterStatsPane == nil then return end
    elseif CCS.CurrentVersion == CCS.FOREVER then
        if CharacterModelFramebg == nil or CharacterFrameBgbg == nil or CharacterStatsPaneScrollBox == nil then return end
    end
    
    if CharacterFrameRightPaneHost ~= nil then 
        CharacterFrameRightPaneHost:SetFrameLevel(1) 
    end
    --------------------
    -- No Theme Selected
    --------------------
    if option("theme") == "None" and CharacterFrame.ChonkyNS ~= nil then
        if CharacterModelFramebg.ChonkyNS ~= nil then CharacterModelFramebg.ChonkyNS:Hide() end
        if InspectModelFramebg.ChonkyNS ~= nil then InspectModelFramebg.ChonkyNS:Hide() end        
        if CharacterStatsPane.ChonkyNS ~= nil then 
            CharacterStatsPane.ChonkyNS:SetShown(option("showstatborder"))
        end
        
        if CCS.CurrentVersion == CCS.FOREVER and CharacterStatsPaneScrollBox ~= nil then
            if CharacterStatsPaneScrollBox.Border ~= nil then CharacterStatsPaneScrollBox.Border:Show() end
            if CharacterStatsPaneScrollBox.ClassBackground ~= nil then CharacterStatsPaneScrollBox.ClassBackground:Show() end
            if CharacterFrameRightPaneHost ~= nil then select(1, CharacterFrameRightPaneHost:GetChildren()):Show() end
            CharacterStatsPaneScrollBox:SetPoint("TOPLEFT", CharacterFrameRightPaneHostStoneBg, "BOTTOMLEFT",0,0)
        end
        
        if CharacterFrame.ChonkyNS ~= nil then CharacterFrame.ChonkyNS:Hide() end
        if InspectFrame ~= nil and InspectFrame.ChonkyNS ~= nil then InspectFrame.ChonkyNS:Hide() end
        if PaperDollFrame.TopOverlay ~= nil then PaperDollFrame.TopOverlay:Hide() end
        if PaperDollFrame.LeftOverlay ~= nil then PaperDollFrame.LeftOverlay:Hide() end
        if PaperDollFrame.RightOverlay ~= nil then PaperDollFrame.RightOverlay:Hide() end

        if ccsm_sf ~= nil and ccsm_sf.ChonkyNS ~= nil then ccsm_sf.ChonkyNS:Hide() end
        if ccsmi_sf ~= nil and ccsmi_sf.ChonkyNS ~= nil then ccsmi_sf.ChonkyNS:Hide() end
        if ccsrf_sf ~= nil and ccsrf_sf.ChonkyNS ~= nil then ccsrf_sf.ChonkyNS:Hide() end
        if ccsgf_sf ~= nil and ccsgf_sf.ChonkyNS ~= nil then ccsgf_sf.ChonkyNS:Hide() end

    --------------------
    -- Theme Selected.
    --------------------
      
    elseif option("theme") ~= "None" then

        if CharacterFrame.ChonkyNS ~= nil then CharacterFrame.ChonkyNS:SetShown(option("show_char_frame")) end
        if PaperDollFrame.TopOverlay ~= nil then PaperDollFrame.TopOverlay:SetShown(option("show_top_texture")) end
        if PaperDollFrame.LeftOverlay ~= nil then PaperDollFrame.LeftOverlay:SetShown(option("show_left_texture")) end
        if PaperDollFrame.RightOverlay ~= nil then PaperDollFrame.RightOverlay:SetShown(option("show_right_texture")) end
        if CharacterModelFramebg.ChonkyNS ~= nil then CharacterModelFramebg.ChonkyNS:SetShown(option("show_paperdoll_border")) end
        if CharacterFrameInsetRight ~= nil and CharacterFrameInsetRight.Bg ~= nil then CharacterFrameInsetRight.Bg:SetShown(option("showsidebarbg")) end
        CCS.SkinItems()
        if InspectFrame ~= nil and InspectFrame.ChonkyNS ~= nil then InspectFrame.ChonkyNS:SetShown(option("show_inspect_frame"))  end
        if InspectModelFramebg ~= nil and InspectModelFramebg.ChonkyNS ~= nil then InspectModelFramebg.ChonkyNS:SetShown(option("show_paperdolli_border"))  end        
        if ccsmi_sf ~= nil and ccsmi_sf.ChonkyNS ~= nil then ccsmi_sf.ChonkyNS:SetShown(option("show_mplusi_frame_border"))  end

        if CharacterStatsPane.ChonkyNS ~= nil then CharacterStatsPane.ChonkyNS:SetShown(option("showstatborder")) end
        if CharacterStatsPane.BG ~= nil then CharacterStatsPane.BG:SetShown(option("show_stats_background")) end        

        if ccsm_sf ~= nil and ccsm_sf.ChonkyNS ~= nil then ccsm_sf.ChonkyNS:SetShown(option("show_mplus_frame_border")) end
        if ccsrf_sf ~= nil and ccsrf_sf.ChonkyNS ~= nil then ccsrf_sf.ChonkyNS:SetShown(option("show_raid_frame_border")) end
        if ccsgf_sf ~= nil and ccsgf_sf.ChonkyNS ~= nil then ccsgf_sf.ChonkyNS:SetShown(option("show_gear_frame_border")) end

        if CCS.CurrentVersion == CCS.FOREVER and CharacterStatsPaneScrollBox ~= nil then
            if CharacterStatsPaneScrollBox.Border ~= nil then CharacterStatsPaneScrollBox.Border:Hide() end
            if CharacterStatsPaneScrollBox.ClassBackground ~= nil then CharacterStatsPaneScrollBox.ClassBackground:Hide() end
            if CharacterFrameRightPaneHost ~= nil then select(1, CharacterFrameRightPaneHost:GetChildren()):Hide() end
            CharacterStatsPaneScrollBox:SetPoint("TOPLEFT", CharacterFrameRightPaneHostStoneBg, "BOTTOMLEFT",0,10)
        end
    end
    
end