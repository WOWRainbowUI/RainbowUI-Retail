--- Kaliel's Tracker
--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

local SS = KT:NewSubsystem("StaticPopup")

local db
local DIALOG_TITLE = "|T"..KT.MEDIA_PATH.."KT_logo:22:22:0:0|t"..NORMAL_FONT_COLOR_CODE..KT.TITLE.."|r"

function KT.StaticPopup_Show(token, text, subText, ...)
    local data = select("#", ...) > 0 and { ... } or nil
    return StaticPopup_Show(addonName.."_"..token, nil, nil, {
        text = text,
        subText = subText,
        data = data
    })
end

function KT.StaticPopup_ShowURL(token, ...)
    return StaticPopup_Show(addonName.."_"..token, nil, nil, { ... })
end

function SS:Init()
    db = KT.db.profile
end

-- ---------------------------------------------------------------------------------------------------------------------

-- GameDialog.lua
local function SP_Setup(self)
    local dialogInfo = StaticPopupDialogs[self.which]

    if self.EditBoxHint then
        self.EditBoxHint:Hide()
    end

    if dialogInfo.subText then
        self.SubText:SetJustifyH(dialogInfo.justify or "CENTER")
    end

    if dialogInfo.hasEditBox then
        if dialogInfo.editBoxHint then
            if not self.EditBoxHint then
                local editBox = self:GetEditBox()
                self.EditBoxHint = self:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
                self.EditBoxHint:SetPoint("TOPRIGHT", editBox, "BOTTOMRIGHT")
            end
            self.EditBoxHint:SetText(dialogInfo.editBoxHint)
            self.EditBoxHint:Show()
        end
    end
end

local function EB_OnKeyDown(self, key)
    local func = StaticPopupDialogs[self:GetParent().which].EditBoxOnKeyDown
    if func then
        func(self, key, self:GetParent().data)
    end
end

local function EB_OnKeyUp(self, key)
    local func = StaticPopupDialogs[self:GetParent().which].EditBoxOnKeyUp
    if func then
        func(self, key, self:GetParent().data)
    end
end

local function EB_OnMouseDown(self, button)
    local func = StaticPopupDialogs[self:GetParent().which].EditBoxOnMouseDown
    if func then
        func(self, button, self:GetParent().data)
    end
end

local function EB_OnMouseUp(self, button)
    local func = StaticPopupDialogs[self:GetParent().which].EditBoxOnMouseUp
    if func then
        func(self, button, self:GetParent().data)
    end
end

for i = 1, 4 do
    local popup = _G["StaticPopup"..i]
    popup:HookScript("OnShow", SP_Setup)
    local editBox = popup.EditBox
    editBox:HookScript("OnKeyDown", EB_OnKeyDown)
    editBox:HookScript("OnKeyUp", EB_OnKeyUp)
    editBox:HookScript("OnMouseDown", EB_OnMouseDown)
    editBox:HookScript("OnMouseUp", EB_OnMouseUp)
end

-- ---------------------------------------------------------------------------------------------------------------------

local function StaticPopup_OnShow(self)
    local text = self.data.text
    local subText = self.data.subText
    if text then
        self:SetText(self:GetText().." - "..text)
    end
    if subText then
        local data = self.data.data
        if data then
            self.SubText:SetFormattedText(subText, unpack(data))
        else
            self.SubText:SetText(subText)
        end
    end
    self.SubText:SetTextColor(1, 1, 1)
end

StaticPopupDialogs[addonName.."_Info"] = {
    text = DIALOG_TITLE,
    subText = "...",
    button2 = CLOSE,
    OnShow = StaticPopup_OnShow,
    timeout = 0,
    whileDead = 1
}

StaticPopupDialogs[addonName.."_InfoWide"] = {
    text = DIALOG_TITLE,
    subText = "...",
    button2 = CLOSE,
    wide = true,
    wideText = true,
    justify = "LEFT",
    OnShow = StaticPopup_OnShow,
    timeout = 0,
    whileDead = 1
}

StaticPopupDialogs[addonName.."_ReloadUI"] = {
    text = DIALOG_TITLE,
    subText = "...",
    button1 = RELOADUI,
    OnShow = StaticPopup_OnShow,
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = 1
}

local function CreatePopup_URL(text, editBoxWidth, onShow)
    return {
        text = text,
        button2 = CLOSE,
        hasEditBox = 1,
        editBoxWidth = editBoxWidth,
        editBoxHint = "Ctrl+C to copy",
        maxLetters = 0,
        maxBytes = 0,
        countInvisibleLetters = false,
        EditBoxOnTextChanged = function(self)
            local text = self.text
            if text and self:GetText() ~= text then
                self:SetText(text)
            end
            self:HighlightText()
        end,
        EditBoxOnMouseDown = function(self)
            if self:HasFocus() then
                C_Timer.After(0, function()
                    self:HighlightText()
                end)
            end
        end,
        EditBoxOnMouseUp = function(self)
            if self:HasFocus() then
                self:SetCursorPosition(0)
                self:HighlightText()
            end
        end,
        EditBoxOnEnterPressed = function(self)
            self:GetParent():Hide()
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
        -- Close popup after copy - Inspired by SimulationCraft
        EditBoxOnKeyDown = function(self, key)
            if key == "LCTRL" or key == "RCTRL" or key == "LMETA" or key == "RMETA" then
                self.ctrlDown = true
            end
        end,
        EditBoxOnKeyUp = function(self, key)
            if key == "LCTRL" or key == "RCTRL" or key == "LMETA" or key == "RMETA" then
                C_Timer.After(0.2, function()
                    self.ctrlDown = nil
                end)
            end
            if self.ctrlDown then
                if key == "C" then
                    if db.popupCloseOnCopy then
                        C_Timer.After(0.1, function()
                            self:GetParent():Hide()
                        end)
                    end
                end
            end
        end,
        OnShow = onShow,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1
    }
end

StaticPopupDialogs[addonName.."_WowheadURL"] = CreatePopup_URL(
        DIALOG_TITLE.." - Wowhead URL",
        300,
        function(self)
            local type, id, subtype = unpack(self.data)
            if not type or not id then return end

            local name = "..."
            local domain = "https://www.wowhead.com/"
            local path = type.."="..id
            local info

            if type == "quest" then
                name = QuestUtils_GetQuestName(id)
            elseif type == "achievement" then
                name = select(2, GetAchievementInfo(id))
            elseif type == "spell" then
                name = C_Spell.GetSpellName(id)
            elseif type == "item" then
                info = KT.GetCollectibleItemInfo(subtype, id)
                if info then
                    name = info.name
                    path = type.."="..info.itemID
                end
            elseif type == "activity" then
                info = C_PerksActivities.GetPerksActivityInfo(id)
                if info then
                    name = info.activityName
                end
                path = "trading-post-activity/"..id
            elseif type == "endeavor" then
                info = C_NeighborhoodInitiative.GetInitiativeTaskInfo(id)
                if info then
                    name = info.taskName
                end
                path = "endeavor-task/"..id
            end

            local lang = KT.LOCALE:sub(1, 2)
            if lang ~= "en" then
                if lang == "zh" then lang = "cn" end
                domain = domain..lang.."/"
            end

            self:SetText(self:GetText().."\n|cffff7f00"..name.."|r")
            local editBox = self:GetEditBox()
            editBox.text = domain..path
            editBox:SetText(editBox.text)
            editBox:SetAltArrowKeyMode(true)
            editBox:SetCursorPosition(0)
            editBox:SetFocus()
        end
)

StaticPopupDialogs[addonName.."_YouTubeURL"] = CreatePopup_URL(
        DIALOG_TITLE.." - YouTube Search URL",
        400,
        function(self)
            local type, id, subtype = unpack(self.data)
            if not type or not id then return end

            local name = "..."
            local url = "https://www.youtube.com/results?search_query=wow"
            local params = "+"..type
            local info

            if type == "quest" then
                name = QuestUtils_GetQuestName(id)
            elseif type == "achievement" then
                name = select(2, GetAchievementInfo(id))
            elseif type == "spell" then
                name = C_Spell.GetSpellName(id)
            elseif type == "item" then
                info = KT.GetCollectibleItemInfo(subtype, id)
                if info then
                    name = info.name
                end
            elseif type == "activity" then
                info = C_PerksActivities.GetPerksActivityInfo(id)
                if info then
                    name = info.activityName
                end
                params = "+trading+post"
            elseif type == "endeavor" then
                info = C_NeighborhoodInitiative.GetInitiativeTaskInfo(id)
                if info then
                    name = info.taskName
                end
                params = "+endeavor+task"
            end
            params = params.."+\""..gsub(name, " ", "+").."\""

            self:SetText(self:GetText().."\n|cffff7f00"..name.."|r")
            local editBox = self:GetEditBox()
            editBox.text = url..params
            editBox:SetText(editBox.text)
            editBox:SetAltArrowKeyMode(true)
            editBox:SetCursorPosition(0)
            editBox:SetFocus()
        end
)