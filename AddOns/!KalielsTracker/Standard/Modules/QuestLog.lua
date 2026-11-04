--- Kaliel's Tracker

--- Copyright (c) 2012-2026, Marouan Sabbagh <mar.sabbagh@gmail.com>

--- All Rights Reserved.

---

--- This file is part of addon Kaliel's Tracker.



---@type KT

local addonName, KT = ...



---@class QuestLog

local M = KT:NewModule("QuestLog")

KT.QuestLog = M



local LSM = LibStub("LibSharedMedia-3.0")

local _DBG = function(...) if _DBG then _DBG("KT", ...) end end



local db, dbChar

local agwLists = AceGUIWidgetLSMlists

local textOffsets = { [-1] = "小", [0] = "中", [1] = "大", [2] = "特大" }

local baseFontSizes = {}



local dropDownFrame



-- Internal ------------------------------------------------------------------------------------------------------------



local function QuestDetails_SetText()

    if not db.questLog.detailsShow then return end



    local headingFont = LSM:Fetch("font", db.questLog.detailsHeadingFont)

    local bodyFont = LSM:Fetch("font", db.questLog.detailsBodyFont)

    local offset = db.questLog.detailsBodyTextOffset



    local function SetFontFile(fontObject, fontFile, sizeOffset)

        local _, size, flags = fontObject:GetFont()



        if not baseFontSizes[fontObject] then

            baseFontSizes[fontObject] = size

        end



        if sizeOffset then

            size = baseFontSizes[fontObject] + sizeOffset

        end



        fontObject:SetFont(fontFile, size, flags)

    end



    SetFontFile(KT_QuestInfoTitleHeader, headingFont)

    SetFontFile(KT_QuestInfoDescriptionHeader, headingFont)

    SetFontFile(KT_QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame.Label, headingFont)



    SetFontFile(KT_QuestInfoDescriptionText, bodyFont, offset)

    SetFontFile(KT_QuestInfoObjectivesText, bodyFont, offset)

    SetFontFile(KT_QuestInfoGroupSize, bodyFont, offset)

    SetFontFile(KT_QuestInfoTimerText, bodyFont, offset)

    SetFontFile(KT_QuestInfoSpellObjectiveLearnLabel, bodyFont, offset)

    SetFontFile(KT_QuestInfoRequiredMoneyText, bodyFont, offset)



    local objectives = KT_QuestInfoObjectivesFrame.Objectives

    for _, objective in ipairs(objectives) do

        if not baseFontSizes[objective] then

            baseFontSizes[objective] = baseFontSizes[objectives[1]]

        end

        SetFontFile(objective, bodyFont, offset)

    end

end



local function SetupOptions()

    if not KT:Addon_IsModule(KT.Options) then return end



    KT.Options.AddFeatureSection("questLog", {

        name = "任務日誌",

        type = "group",

        inline = true,

        get = function(info)

            return db.questLog[info[#info]]

        end,

        set = function(info, value)

            db.questLog[info[#info]] = value

            QuestDetails_SetText()

        end,

        args = {

            detailsShow = {

                name = "在世界地圖上顯示任務內容 "..KT.TEXT.OPTION_EXPERIMENTAL,

                type = "toggle",

                width = 2,

                order = 1.1,

            },


            detailsShowDesc = {

                name = "從追蹤清單開啟任務地圖時顯示任務詳情。此功能使用插件提供的任務詳情介面。\n\n",


                type = "description",

                width = 2,

                marginLeft = 30,

                order = 1.2,

            },

            detailsShowSpacer = {

                name = " ",

                type = "description",

                width = 1,

                order = 1.3,

            },

            detailsHeadingFont = {

                name = "標題字型",

                desc = "- 預設：".. KT.db.defaults.profile.questLog.detailsHeadingFont,

                type = "select",

                dialogControl = "LSM30_Font",

                values = agwLists.font,

                disabled = function()

                    return not db.questLog.detailsShow

                end,

                order = 2,

            },

            detailsBodyFont = {

                name = "內文字型",

                desc = "- 預設：".. KT.db.defaults.profile.questLog.detailsBodyFont,

                type = "select",

                dialogControl = "LSM30_Font",

                values = agwLists.font,

                disabled = function()

                    return not db.questLog.detailsShow

                end,

                order = 3,

            },

            detailsBodyTextOffset = {

                name = "內文字體大小",

                desc = "- 預設：".. textOffsets[KT.db.defaults.profile.questLog.detailsBodyTextOffset],

                type = "select",

                values = textOffsets,

                disabled = function()

                    return not db.questLog.detailsShow

                end,

                order = 4,

            },

        },

    })

end



local function QuestMap_ToggleDropDown(frame, handlerFunc, anchor, xOffset, yOffset, point, relativePoint)

    if dropDownFrame.activeFrame ~= frame then

        MSA_CloseDropDownMenus()

    end

    dropDownFrame.activeFrame = frame

    dropDownFrame.initialize = handlerFunc

    dropDownFrame.questID = frame.questID

    if point then

        MSA_DropDownMenu_SetAnchor(dropDownFrame, nil, nil, point, nil, relativePoint)

    end

    MSA_ToggleDropDownMenu(1, nil, dropDownFrame, anchor, xOffset, yOffset)

    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

end



local function QuestLog_OnOpenDropDown(self)

    local questID = self.questID

	local info = KT.Menu_CreateInfo()

	KT.Menu_AddTitle(C_QuestLog.GetTitleForQuestID(questID))



	local text, func

	if C_SuperTrack.GetSuperTrackedQuestID() ~= questID then

		text = SUPER_TRACK_QUEST

		func = function()

			C_SuperTrack.SetSuperTrackedQuestID(questID)

		end

	else

		text = STOP_SUPER_TRACK_QUEST

		func = function()

			C_SuperTrack.SetSuperTrackedQuestID(0)

		end

	end

	KT.Menu_AddButton(text, func)



	KT.Menu_AddButton(QuestUtils_IsQuestWatched(questID) and UNTRACK_QUEST or TRACK_QUEST, function()

		QuestMapQuestOptions_TrackQuest(questID)

	end, (dbChar.filterAuto[1] ~= nil))



	info.disabled = false



	KT.Menu_AddButton(SHARE_QUEST, function()

		QuestMapQuestOptions_ShareQuest(questID)

	end, (not C_QuestLog.IsPushableQuest(questID) or not IsInGroup()))



	info.disabled = false



	if C_QuestLog.CanAbandonQuest(questID) then

		KT.Menu_AddButton(ABANDON_QUEST, function()

			QuestMapQuestOptions_AbandonQuest(questID)

		end)

	end



	KT:SendSignal("CONTEXT_MENU_UPDATE", info, "quest", questID)

end



local function QuestDetails_OnOpenDropDown(self)

    local questID = self:GetParent().DetailsFrame.questID

    local info = KT.Menu_CreateInfo()

    info.KTmenuSource = "questDetails"

    KT.Menu_AddTitle(C_QuestLog.GetTitleForQuestID(questID))



    KT:SendSignal("CONTEXT_MENU_UPDATE", info, "quest", questID)

end



local function SetHooks()

    -- WorldMapFrame.lua

    WorldMapFrame:HookScript("OnHide", function()

        KT_QuestMapFrame_CloseQuestDetails()

    end)



    hooksecurefunc(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame, "Maximize", function(self, isAutomaticAction, skipCallback)

        KT_QuestMapFrame_CloseQuestDetails()

    end)



    WorldMapFrame.SidePanelToggle.CloseButton:HookScript("OnClick", function()

        KT_QuestMapFrame_CloseQuestDetails()

    end)



    -- for Mapster

    hooksecurefunc(WorldMapFrame, "SetScale", function(self, scale)

        KT_QuestMapFrame:SetScale(scale)

    end)



	-- QuestMapFrame.lua

    hooksecurefunc(QuestMapFrame, "Refresh", function(self)

        if KT_QuestMapFrame.DetailsFrame.questMapID and KT_QuestMapFrame.DetailsFrame.questMapID ~= self:GetParent():GetMapID() then

            KT_QuestMapFrame_CloseQuestDetails()

        end

    end)



	hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self, button)

		local isDisabledQuest = C_QuestLog.IsQuestDisabledForSession(self.questID)

		if not isDisabledQuest and button == "RightButton" then

			local manager = Menu.GetManager()

			local menu = manager:GetOpenMenu()

			if menu then

				manager:CloseMenu(menu)

			end

			QuestMap_ToggleDropDown(self, QuestLog_OnOpenDropDown, "cursor", 6, -6)

		elseif button == "LeftButton" then

			if IsModifiedClick(db.menuWowheadURLModifier) then

				KT:Alert_WowheadURL("quest", self.questID)

			elseif IsModifiedClick(db.menuYouTubeURLModifier) then

				KT:Alert_YouTubeURL("quest", self.questID)

			elseif db.questLog.detailsShow then

				KT.OpenService_Open("quest", self.questID, true)

			end

		end

	end)



	hooksecurefunc("QuestMapQuestOptions_TrackQuest", function(questID)

		if db.questsAutoFocusClosest and not C_SuperTrack.GetSuperTrackedQuestID() then

			KT.QuestSuperTracking_ChooseClosestQuest()

		end

	end)



    hooksecurefunc(QuestMapFrame, "SetDisplayMode", function(self, displayMode)

        if KT_QuestMapFrame.DetailsFrame.questID then

            KT_QuestMapFrame:SetShown(displayMode == QuestLogDisplayMode.Quests)

        end

    end)

end



local function SetFrames()

    -- Quest detail

    local questMapFrame = CreateFrame("Frame", "KT_QuestMapFrame", UIParent)

    questMapFrame:SetSize(331, 498)  -- 504

    questMapFrame:SetPoint("TOPRIGHT", QuestMapFrame, -1, 0)

    questMapFrame:SetFrameStrata(QuestMapFrame:GetFrameStrata())

    questMapFrame:EnableMouse(true)

    questMapFrame:Hide()



    questMapFrame:SetScript("OnEvent", function(_, event)

        if event == "QUEST_WATCH_LIST_CHANGED" then

            KT_QuestMapFrame_UpdateQuestDetailsButtons()

        elseif event == "QUEST_REMOVED" then

            KT_QuestMapFrame_CloseQuestDetails()

        elseif event == "SUPER_TRACKING_CHANGED" then

            KT_QuestMapFrame_UpdateSuperTrackedQuest()

        end

    end)

    questMapFrame:RegisterEvent("QUEST_WATCH_LIST_CHANGED")

    questMapFrame:RegisterEvent("QUEST_REMOVED")

    questMapFrame:RegisterEvent("SUPER_TRACKING_CHANGED")



    local bg = questMapFrame:CreateTexture(nil, "BACKGROUND")

    if not C_AddOns.IsAddOnLoaded("ElvUI") then

        bg:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock")

    else

        bg:SetColorTexture(0, 0, 0)

    end

    bg:SetAllPoints()



    local logo = CreateFrame("Frame", nil, questMapFrame)

    logo:SetSize(26, 26)

    logo:SetPoint("TOP", -9, -10)

    logo:SetFrameLevel(10)

    logo.tex = logo:CreateTexture(nil, "ARTWORK")

    logo.tex:SetTexture(KT.MEDIA_PATH.."KT_logo")

    logo.tex:SetAllPoints()

    logo:SetScript("OnMouseUp", function(self)

        QuestMap_ToggleDropDown(self, QuestDetails_OnOpenDropDown, self, 0, 0, "TOP", "BOTTOM")

    end)

    logo:SetScript("OnEnter", function(self)

        GameTooltip:SetOwner(self, "ANCHOR_TOP")

        GameTooltip:AddLine("任務詳情由以下插件提供：|cffffd200"..KT.TITLE, 1, 1, 1)

        GameTooltip:Show()

    end)

    logo:SetScript("OnLeave", function(self)

        GameTooltip:Hide()

    end)



    KT_QuestsFrame:SetParent(questMapFrame)

    KT_QuestsFrame:SetPoint("TOPLEFT")

    KT_QuestsFrame:SetPoint("BOTTOMRIGHT", -21, 0)

    questMapFrame.DetailsFrame = KT_QuestsFrame.DetailsFrame



	-- DropDown frame

	dropDownFrame = MSA_DropDownMenu_Create(addonName.."QuestLogDropDown", KT_QuestMapFrame)

	MSA_DropDownMenu_Initialize(dropDownFrame, nil, "MENU")

end



-- External ------------------------------------------------------------------------------------------------------------



function M:OnInitialize()

	_DBG("|cffffff00初始化|r - "..self:GetName(), true)

	db = KT.db.profile

	dbChar = KT.db.char

    self.isAvailable = true



    if self.isAvailable then

        local defaults = KT.MergeTables({

            profile = {

                questLog = {

                    detailsShow = true,

                    detailsHeadingFont = "Morpheus",

                    detailsBodyFont = LSM:GetDefault("font"),

                    detailsBodyTextOffset = 0,

                },

            },

        }, KT.db.defaults)

        KT.db:RegisterDefaults(defaults)



        -- migration

        if db.questLogShowDetails ~= nil then

            db.questLog.detailsShow = db.questLogShowDetails

            db.questLogShowDetails = nil

        end

    end

end



function M:OnEnable()

    _DBG("|cff00ff00啟用|r - "..self:GetName(), true)

    SetupOptions()

    SetFrames()

    SetHooks()



    QuestDetails_SetText()

end

