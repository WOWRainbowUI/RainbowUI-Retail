local addonName, addon = ...
local utils = addon.utils
addon.dialog = addon.dialog or utils.class("addon.dialog", addon.schedule).new()
local dialog = addon.dialog
local lang = addon.language
local const = addon.const
local event = addon.event
local config = addon.config

function dialog:PremakeGroupsHelperDialog_OnShow(frame)
    frame.Defeated:Hide()
    frame.MythicScore:Hide()
    frame.PvpRating:Hide()

    local categoryId = utils.getCategory()
    if categoryId == const.CATEGORY_TYPE_DUNGEON then
        --MythicScore只生效在Dungeon选项卡下
        frame.MythicScore:Show()
    elseif categoryId == const.CATEGORY_TYPE_ARENA or 
        categoryId == const.CATEGORY_TYPE_SKIRMISH or 
        categoryId == const.CATEGORY_TYPE_BG or 
        categoryId == const.CATEGORY_TYPE_RBG 
        then
            frame.PvpRating:Show()
    else
        frame.Defeated:Show()
    end

    if PremakeGroupsHelperIgnoreDialog then
        frame.IngoreListToggle:Show()
    end

    dialog:exec("setup", frame)
end

function dialog:PremakeGroupsHelperDialog_OnMouseDown()
    local enable = config:getValue({"moveabletoggle", "enable"}) or false

    if enable then
        self.frame:StartMoving()
    end
end

function dialog:PremakeGroupsHelperDialog_OnMouseUp()
    self.frame:StopMovingOrSizing()
end

--[[
function dialog:PremakeGroupsHelperDialogClass_OnClick(frame)
    --如果没有父级节点
    local parent = frame:GetParent()
    if not parent then
        return
    end

    local key = parent:GetAttribute("parentKey")
    local r,g, b, a = parent.Title:GetTextColor()
    --如果是选择状态并且颜色为红色
    if r == 1 and g == 0 and b == 0 then
        frame:SetChecked(false)
        parent.Title:SetText(lang["dialog." .. key:lower()])
        parent.Title:SetTextColor(1, 1, 1, 1)
        config:setValue({"class", "negate"}, false, utils.getCategory())
    else

    --此处取反
    local checked = frame:GetChecked() and false or true
    
    utils.dump(checked, "checked")
    --处于没有被选中状态
    if not checked then
        utils.dump(checked, "checked")
        utils.dump(key, "key")
        frame:SetChecked(false)
        parent.Title:SetTextColor(1, 1, 1, 1)
        parent.Title:SetText(lang["dialog." .. key:lower()])
        config:setValue({"class", "negate"}, false, utils.getCategory())
        return
    end

    local r,g, b, a = parent.Title:GetTextColor()
    --如果是选择状态并且颜色为红色
    if r == 1 and g == 0 and b == 0 then
        frame:SetChecked(false)
        parent.Title:SetText(lang["dialog." .. key:lower()])
        parent.Title:SetTextColor(1, 1, 1, 1)
        config:setValue({"class", "negate"}, false, utils.getCategory())
    else
        frame:SetChecked(true)
        parent.Title:SetText(lang["dialog." .. key:lower() .. "_off"])
        parent.Title:SetTextColor(1, 0, 0, 1)
        config:setValue({"class", "negate"}, true, utils.getCategory())
    end
end]]

function dialog:PremakeGroupsHelperDialogResetButton_OnClick(frame)
    config:resetConfiguration(utils.getCategory())
    self:exec("clearFocus")
    --utils.dump("setup", "setup")
    self:exec("setup", self.frame, true)

    if LFGListFrame.SearchPanel:IsShown() then
        LFGListFrame.SearchPanel.RefreshButton:Click()
    end
    --config:setValue({"difficulty", "value"}, arg1, )
end

function dialog:PremakeGroupsHelperDialogSearchButton_OnClick(frame)
    if LFGListFrame.SearchPanel:IsShown() then
        LFGListFrame.SearchPanel.RefreshButton:Click()
    end
end

function dialog:toggle()
    if PVEFrame:IsShown() and 
        ((LFGListFrame.activePanel == LFGListFrame.SearchPanel and LFGListFrame.SearchPanel:IsShown()) or 
        (LFGListFrame.activePanel == LFGListFrame.ApplicationViewer and LFGListFrame.ApplicationViewer:IsShown())) then
            self.frame:Show()
    else
        self.frame:Hide()
    end
end

function dialog:LFGListFrame_SetActivePanel(frame, panel)
    self:toggle()
end

function dialog:GroupFinderFrame_ShowGroupFrame(...)
    self:toggle()
end

--[[
function dialog:PVEFrame_ShowFrame(...)
    self:toggle()
end
]]

function dialog:PVEFrame_OnShow(...)
    self:toggle()
end

function dialog:PVEFrame_OnHide(...)
    self:toggle()
end

function dialog:resetPosition()
    self.frame:ClearAllPoints()
    self.frame:SetPoint("TOPLEFT", GroupFinderFrame, "TOPRIGHT")
    self.frame:SetWidth(300)
end

function dialog:setup(frame)
    local enable = config:getValue({"moveabletoggle", "enable"}) or false

    if not enable then
        self:resetPosition()
    end
end

function dialog:initialize(frame)
    self:_registerScriptEvent(frame, "OnShow", "PremakeGroupsHelperDialog_OnShow")
    self:_registerScriptEvent(frame, "OnHide", "PremakeGroupsHelperDialog_OnHide")
    self:_registerScriptEvent(frame, "OnMouseDown", "PremakeGroupsHelperDialog_OnMouseDown")
    self:_registerScriptEvent(frame, "OnMouseUp", "PremakeGroupsHelperDialog_OnMouseUp")
    self:resetPosition()
    event:exec("SETUP_SKIN", frame, "frame")
end

function dialog:_registerScriptEvent(frame, event, func)
    if not frame then
        return
    end

    if frame:GetScript(event) ~= nil then
        frame:HookScript(event, self:handler(func))
    else
        frame:SetScript(event, self:handler(func))
    end
end

function dialog:registerScriptEvents()
    local scriptEvents = {
        {
            frame = PVEFrame,
            event = "OnShow",
            func = "PVEFrame_OnShow",
        },
        {
            frame = PVEFrame,
            event = "OnHide",
            func = "PVEFrame_OnHide",
        },
        {
            frame = LFGListApplicationDialog,
            event = "OnShow",
            func = "LFGListApplicationDialog_OnShow",
        },
        {
            frame = LFDRoleCheckPopup,
            event = "OnShow",
            func = "LFDRoleCheckPopup_OnShow",
        },
        {
            frame = LFGListInviteDialog,
            event = "OnShow",
            func = "LFGListInviteDialog_OnShow",
        },
        {
            frame = LFGListInviteDialog,
            event = "OnEnter",
            func = "LFGListInviteDialog_OnEnter",
        },
        {
            frame = LFGListInviteDialog,
            event = "OnLeave",
            func = "LFGListInviteDialog_OnLeave",
        },
		
        -- Allow double-click on category buttons to open next frame --
        {
            frame = LFGListFrame.CategorySelection.CategoryButtons,
            event = "OnDoubleClick",
            func = "LFGListFrameCategorySelectionCategoryButtons_OnDoubleClick",
            range = #LFGListFrame.CategorySelection.CategoryButtons,
        },
    }

    for _, v in pairs(scriptEvents) do
        if v.range then
            for i = 1, v.range do
                self:_registerScriptEvent(v.frame[i], v.event, v.func)
            end
        else
            self:_registerScriptEvent(v.frame, v.event, v.func)
        end
    end

    --添加双击加入队伍支持
    hooksecurefunc("LFGListSearchPanel_InitButton",function(button) 
        button:SetScript("OnDoubleClick",self:handler("LFGListSearchPanelScrollFrameButtons_OnDoubleClick"))
    end)
end

function addon:DIALOG_LOADED( frame)
    if frame then
        --触发一次按钮创建事件
        LFGListCategorySelection_SelectCategory(LFGListFrame.CategorySelection, nil, nil)
        --
        event:registerHandlers(dialog)
        dialog.frame = frame
        dialog:registerHandlers(dialog)
        dialog:registerScriptEvents()
        dialog:exec("initialize", frame)
        
        --event:exec("SETUP_SKIN", PremakeGroupsHelperReportButton, "UIButton")
        --部分界面加载的很晚，在这里做自定义或特殊框架的注册吧
    end
end
