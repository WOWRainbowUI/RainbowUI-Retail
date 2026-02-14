local _, ns = ...

local LAB = ns.LibActionButton
local ButtonPress = {}
ns.ButtonPress = ButtonPress

local function CreateSpellIDCollection(spellID)
    if not spellID then
        return nil
    end

    local collection = {}
    collection[spellID] = true

    local overrideSpell = C_Spell.GetOverrideSpell(spellID)
    local baseSpell = C_Spell.GetBaseSpell(spellID)

    if overrideSpell then
        collection[overrideSpell] = true
    end
    if baseSpell then
        collection[baseSpell] = true
    end
    return collection
end

local function GetSpellIDFromCooldownId(cooldownID)
    if not cooldownID then
        return nil
    end
    if type(cooldownID) ~= "number" then
        return nil
    end
    local cooldownIDInfo = C_CooldownViewer.GetCooldownViewerCooldownInfo(cooldownID)
    if cooldownIDInfo.spellID then
        return cooldownIDInfo.spellID, cooldownIDInfo.overrideSpellID
    end
end

local viewerTypes = { "EssentialCooldownViewer", "UtilityCooldownViewer" }
local function GetViewerIconBySpellId(spellID)
    if not spellID then
        return nil
    end

    for _, viewerName in ipairs(viewerTypes) do
        local viewerFrame = _G[viewerName]
        if viewerFrame then
            local spellIDCollection = CreateSpellIDCollection(spellID)

            local cooldownIcons = { viewerFrame:GetChildren() }
            for _, icon in ipairs(cooldownIcons) do
                if icon.Icon and icon.cooldownID then
                    local cooldownIDRelatedSpellID, cooldownIDRelatedOverrideSpellID =
                        GetSpellIDFromCooldownId(icon.cooldownID)

                    if
                        type(cooldownIDRelatedSpellID) == "number"
                        and (
                            spellIDCollection[cooldownIDRelatedSpellID]
                            or spellIDCollection[cooldownIDRelatedOverrideSpellID]
                        )
                    then
                        return icon
                    end
                    if icon.GetBaseSpellID then
                        local id = icon:GetBaseSpellID()

                        if id and not issecretvalue(id) and spellIDCollection[id] then
                            return icon
                        end
                    end

                    if icon.GetSpellID then
                        local id = icon:GetSpellID()

                        if id and not issecretvalue(id) and spellIDCollection[id] then
                            return icon
                        end
                    end
                end
            end
        end
    end
end

local function GetSpellIdFromMacroName(macroName)
    if not macroName then
        return nil
    end

    local macroSpellID = GetMacroSpell(macroName)

    if macroSpellID then
        return macroSpellID
    end
end

local function GetSpellIdFromButton(btn)
    if not btn or not btn.action then
        return nil
    end

    local actionType, id, subType = GetActionInfo(btn.action)

    if actionType == "macro" and subType == "spell" then
        return id, true
    elseif actionType == "spell" then
        return id
    elseif actionType == "macro" then
        local macroName = GetActionText(btn.action)
        return GetSpellIdFromMacroName(macroName), true
    end
    return nil
end

local function CreateOrGetTextureFrame(icon)
    if icon.HighlightTexture then
        return icon.HighlightTexture
    end

    local frame = CreateFrame("Frame", nil, icon, "BackdropTemplate")
    frame:SetFrameLevel(icon:GetFrameLevel() + 10)
    frame:SetAllPoints(icon)

    local tex = frame:CreateTexture(nil, "OVERLAY")
    tex:SetAllPoints(frame)
    if ns.db.profile.cooldownManager_buttonPress_texture == "Flat" then -- todo texture option
        tex:SetTexture("Interface\\AddOns\\CooldownManagerCentered\\Media\\Art\\Square")
        tex:SetBlendMode("ADD")
        tex:SetColorTexture(0.8, 0.8, 0.8, 0.3)
        if frame.SetInside then
            tex:SetInside()
        end
    else
        tex:SetAtlas("UI-HUD-ActionBar-IconFrame-Down", true)
    end
    frame.texture = tex
    frame:Hide()

    icon.HighlightTexture = frame
    return frame
end

local function EnableTexture(icon)
    local iconFrame = CreateOrGetTextureFrame(icon)
    iconFrame:Show()
end

local function DisableTexture(icon)
    local iconFrame = CreateOrGetTextureFrame(icon)
    iconFrame:Hide()
end

local toHide = {}
local function cleanupToHide()
    for _, icon in ipairs(toHide) do
        DisableTexture(icon)
    end
    toHide = {}
end

local function ToggleHighlight(icon, show)
    if not ns.db.profile.cooldownManager_buttonPress then
        return
    end
    if not icon then
        return
    end
    local textureFrame = CreateOrGetTextureFrame(icon)
    if show then
        textureFrame:Show()
    else
        textureFrame:Hide()
    end
end

local function ShowHighlight(icon)
    ToggleHighlight(icon, true)
end

local function ButtonPressed(button, mouseButton)
    if not ns.db.profile.cooldownManager_buttonPress then
        return
    end
    if not button then
        return
    end
    local spellID = GetSpellIdFromButton(button)
    if not spellID then
        return
    end

    local icon = GetViewerIconBySpellId(spellID)
    if not icon then
        return
    end
    table.insert(toHide, icon)

    ShowHighlight(icon)
end

local function HookButtonPressToPreClick(button)
    button:HookScript("PreClick", function(self, mouseButton, down)
        cleanupToHide()
        if not down then
            return
        end
        ButtonPressed(self, mouseButton)
    end)
    button.IsCMCButtonPressHooked = true
end

local function HookDominosButton(button)
    if not button then
        return
    end
    local function handler(_, mouseButton, down)
        ButtonPressed(button, mouseButton, down, nil)
    end
    if button.bind and not button.IsCMCButtonPress_BindHooked then
        button.bind:HookScript("PreClick", handler)
        button.IsCMCButtonPress_BindHooked = true
    end
    if not button.IsCMCButtonPressHooked then
        HookButtonPressToPreClick(button)
    end
end

local function HookAllLABButtons()
    if not LAB or not LAB.activeButtons then
        return
    end

    for button in pairs(LAB.activeButtons) do
        if not button.IsCMCButtonPressHooked then
            HookButtonPressToPreClick(button, nil)
        end
    end
end

local function RegisterLABCallbacks()
    if not LAB then
        return
    end
    if LAB.__CMCButtonPress_OnButtonUpdateRegistered then
        return
    end
    LAB.__CMCButtonPress_OnButtonUpdateRegistered = true

    LAB:RegisterCallback("OnButtonUpdate", function(_, button)
        HookButtonPressToPreClick(button, nil)
    end)
end

function ButtonPress:RegisterElvUICallbacks()
    local ElvUI = _G.ElvUI and _G.ElvUI[1]
    if not ElvUI then
        return
    end
    local ElvUILAB = ElvUI.Libs and ElvUI.Libs.LAB
    if not ElvUILAB then
        return
    end
    ElvUILAB:RegisterCallback("OnButtonUpdate", function(_, button)
        HookButtonPressToPreClick(button, "ElvUI")
    end)
end

function ButtonPress:HookAllDominosButtons()
    local Dominos = _G.Dominos
    if not Dominos or not Dominos.ActionButtons or not Dominos.ActionButtons.GetAll then
        return
    end
    Dominos.RegisterCallback(Dominos, "LAYOUT_LOADED", function()
        for button in Dominos.ActionButtons:GetAll() do
            HookDominosButton(button)
        end
    end)
end

function ButtonPress:Initialize()
    if not ns.db.profile.cooldownManager_buttonPress then
        return
    end
    hooksecurefunc("ActionButtonDown", function(id)
        if not ns.db.profile.cooldownManager_buttonPress then
            return
        end
        local btn = _G["ActionButton" .. id]
        local spellID, isFromMacro = GetSpellIdFromButton(btn)
        local icon = GetViewerIconBySpellId(spellID)
        if icon then
            EnableTexture(icon)
            if isFromMacro then
                table.insert(toHide, icon)
            end
        end
    end)

    hooksecurefunc("ActionButtonUp", function(id)
        if not ns.db.profile.cooldownManager_buttonPress then
            return
        end
        local btn = _G["ActionButton" .. id]
        local spellID = GetSpellIdFromButton(btn)
        local icon = GetViewerIconBySpellId(spellID)
        if icon then
            DisableTexture(icon)
        end
        cleanupToHide()
    end)

    hooksecurefunc("MultiActionButtonDown", function(bar, id)
        if not ns.db.profile.cooldownManager_buttonPress then
            return
        end
        local btn = _G[bar .. "Button" .. id]
        local spellID, isFromMacro = GetSpellIdFromButton(btn)
        local icon = GetViewerIconBySpellId(spellID)
        if icon then
            EnableTexture(icon)
        end
        if isFromMacro then
            table.insert(toHide, icon)
        end
    end)

    hooksecurefunc("MultiActionButtonUp", function(bar, id)
        if not ns.db.profile.cooldownManager_buttonPress then
            return
        end
        local btn = _G[bar .. "Button" .. id]
        local spellID = GetSpellIdFromButton(btn)
        local icon = GetViewerIconBySpellId(spellID)
        if icon then
            DisableTexture(icon)
        end
        cleanupToHide()
    end)
    RegisterLABCallbacks()
    HookAllLABButtons()
end
