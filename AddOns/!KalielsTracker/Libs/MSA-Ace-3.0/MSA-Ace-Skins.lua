--- MSA-Ace-Skins - adds ElvUI skinning support for MSA-Ace-3.0 widgets
---
--- Marouan Sabbagh <mar.sabbagh@gmail.com>

local function ElvUI_Skin()
    if not C_AddOns.IsAddOnLoaded("ElvUI") then return end

    local E = unpack(ElvUI)
    local S = E:GetModule("Skins")
    local nextPrevColor = { r = 1, g = 0.8, b = 0, a = 1 }

    hooksecurefunc(S, "Ace3_RegisterAsContainer", function(self, widget)
        local TYPE = widget.type
        if TYPE == 'MSA-Frame' then
            local frame = widget.content:GetParent()
            frame:StripTextures()

            for _, child in next, { frame:GetChildren() } do
                if child:IsObjectType('Button') and child:GetText() then
                    S:HandleButton(child)
                else
                    child:StripTextures()
                end
            end

            frame:SetTemplate('Transparent')

            if widget.treeframe then
                widget.treeframe:SetTemplate('Transparent')
            end

            if widget.scrollbar then
                S:HandleScrollBar(widget.scrollbar)
            end
        end
    end)

    hooksecurefunc(S, "Ace3_RegisterAsWidget", function(self, widget)
        local TYPE = widget.type
        if TYPE == 'MSA-Slider' then
            local slider = widget.slider
            S:HandleSliderFrame(slider)

            local editbox = widget.editbox
            if editbox then
                editbox:SetTemplate()
                editbox:Height(15)
                editbox:Point('TOP', slider, 'BOTTOM', 0, -1)
            end

            local lowtext = widget.lowtext
            if lowtext then
                lowtext:Point('TOPLEFT', slider, 'BOTTOMLEFT', 2, -2)
            end

            local hightext = widget.hightext
            if hightext then
                hightext:Point('TOPRIGHT', slider, 'BOTTOMRIGHT', -2, -2)
            end
        elseif TYPE == 'MSA_LSM30_Sound' then
            local frame = widget.frame

            frame:StripTextures()
            frame:CreateBackdrop(nil, nil, nil, nil, nil, nil, nil, nil, true)
            frame.backdrop:Point('TOPLEFT', 0, -21)
            frame.backdrop:Point('BOTTOMRIGHT', -4, -1)

            local label = frame.label
            if label then
                label:ClearAllPoints()
                label:Point('BOTTOMLEFT', frame.backdrop, 'TOPLEFT', 2, 0)
            end

            local button = frame.dropButton
            if button then
                local text = frame.text
                if text then
                    text:ClearAllPoints()
                    text:Point('RIGHT', button, 'LEFT', -2, 0)
                    text:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
                    text:SetParent(frame.backdrop)
                end

                if TYPE == 'LSM30_Statusbar' then
                    S:HandleNextPrevButton(button, nil, nextPrevColor, true)

                    local bar = widget.bar
                    if bar then
                        bar:SetParent(frame.backdrop)
                        bar:ClearAllPoints()
                        bar:Point('TOPLEFT', frame.backdrop, 'TOPLEFT', 1, -1)
                        bar:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -1, 1)
                    end
                else
                    S:HandleNextPrevButton(button, nil, nextPrevColor)

                    local soundbutton = TYPE == 'LSM30_Sound' and widget.soundbutton
                    if soundbutton then
                        soundbutton:SetParent(frame.backdrop)
                        soundbutton:ClearAllPoints()
                        soundbutton:Point('LEFT', frame.backdrop, 'LEFT', 2, 0)
                    end
                end

                button:ClearAllPoints()
                button:Point('TOPLEFT', frame.backdrop, 'TOPRIGHT', -22, -2)
                button:Point('BOTTOMRIGHT', frame.backdrop, 'BOTTOMRIGHT', -2, 2)
                button:SetParent(frame.backdrop)
                button:HookScript('OnClick', S.Ace3_SkinDropdown)
            end
        end
    end)
end

local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event)
    ElvUI_Skin()
    self:UnregisterEvent(event)
end)
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")