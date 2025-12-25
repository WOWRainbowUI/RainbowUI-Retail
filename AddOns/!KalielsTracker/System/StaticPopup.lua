--- Kaliel's Tracker
--- Copyright (c) 2012-2025, Marouan Sabbagh <mar.sabbagh@gmail.com>
--- All Rights Reserved.
---
--- This file is part of addon Kaliel's Tracker.

---@type KT
local addonName, KT = ...

local SS = KT:NewSubsystem("StaticPopup")

local DIALOG_TITLE = "|T"..KT.MEDIA_PATH.."KT_logo:22:22:0:0|t"..NORMAL_FONT_COLOR_CODE..KT.TITLE.."|r"

function KT.StaticPopup_Show(token, text, subText, ...)
    local data = select("#", ...) > 0 and { ... } or nil
    return StaticPopup_Show(addonName.."_"..token, nil, nil, {
        text = text,
        subText = subText,
        data = data
    })
end

function KT.StaticPopup_ShowURL(token, param1, value1, param2, value2)
    return StaticPopup_Show(addonName.."_"..token, nil, nil, {
        param1 = param1,
        value1 = value1,
        param2 = param2,
        value2 = value2
    })
end

-- GameDialog.lua
local function OnMouseDown(self)
    local EditBoxOnMouseDown = StaticPopupDialogs[self:GetParent().which].EditBoxOnMouseDown
    if EditBoxOnMouseDown then
        EditBoxOnMouseDown(self, self:GetParent().data)
    end
end

local function OnMouseUp(self)
    local EditBoxOnMouseUp = StaticPopupDialogs[self:GetParent().which].EditBoxOnMouseUp
    if EditBoxOnMouseUp then
        EditBoxOnMouseUp(self, self:GetParent().data)
    end
end

for i = 1, 4 do
    local editbox = _G["StaticPopup"..i].EditBox
    editbox:HookScript("OnMouseDown", OnMouseDown)
    editbox:HookScript("OnMouseUp", OnMouseUp)
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

StaticPopupDialogs[addonName.."_WowheadURL"] = {
    text = DIALOG_TITLE.." - Wowhead URL",
    button2 = CLOSE,
    hasEditBox = 1,
    editBoxWidth = 300,
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
    OnShow = function(self)
        local type, id = self.data.param1, self.data.value1
        if not type or not id then return end

        local name = "..."
        local domain = "https://www.wowhead.com/"
        local path = type.."="..id

        if type == "quest" then
            name = QuestUtils_GetQuestName(id)
        elseif type == "achievement" then
            name = select(2, GetAchievementInfo(id))
        elseif type == "spell" then
            name = C_Spell.GetSpellName(id)
        elseif type == "activity" then
            local activityInfo = C_PerksActivities.GetPerksActivityInfo(id)
            if activityInfo then
                name = activityInfo.activityName
            end
            path = "trading-post-activity/"..id
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
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1
}

StaticPopupDialogs[addonName.."_YouTubeURL"] = {
    text = DIALOG_TITLE.." - YouTube Search URL",
    button2 = CLOSE,
    hasEditBox = 1,
    editBoxWidth = 400,
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
    OnShow = function(self)
        local type, id = self.data.param1, self.data.value1
        if not type or not id then return end

        local name = "..."
        local url = "https://www.youtube.com/results?search_query=wow"
        local params = "+"..type

        if type == "quest" then
            name = QuestUtils_GetQuestName(id)
        elseif type == "achievement" then
            name = select(2, GetAchievementInfo(id))
        elseif type == "spell" then
            name = C_Spell.GetSpellName(id)
        elseif type == "activity" then
            local activityInfo = C_PerksActivities.GetPerksActivityInfo(id)
            if activityInfo then
                name = activityInfo.activityName
            end
            params = "+trading+post"
        end
        params = params.."+\""..gsub(name, " ", "+").."\""

        self:SetText(self:GetText().."\n|cffff7f00"..name.."|r")
        local editBox = self:GetEditBox()
        editBox.text = url..params
        editBox:SetText(editBox.text)
        editBox:SetAltArrowKeyMode(true)
        editBox:SetCursorPosition(0)
        editBox:SetFocus()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1
}