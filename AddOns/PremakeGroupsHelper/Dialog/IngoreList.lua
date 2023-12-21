local addonName, addon = ...
local utils = addon.utils
local dialog = addon.dialog
local lang = addon.language
local const = addon.const
local config = addon.config
local event = addon.event
dialog.ingorelist = dialog.ingorelist or utils.class("dialog.ingorelist").new()
local IngoreList = dialog.ingorelist

function IngoreList:PremakeGroupsHelperDialogIngoreListToggle_OnClick(frame)
    if self.frame:IsShown() then
        self.frame:Hide()
    else
        self.frame:Show()
        --提升至顶级
        self.frame:Raise()
    end
end

function IngoreList:PremakeGroupsHelperIgnoreDialog_OnMouseDown()
    self.frame:StartMoving()
end

function IngoreList:PremakeGroupsHelperIgnoreDialog_OnMouseUp()
    self.frame:StopMovingOrSizing()
end

function IngoreList:PremakeGroupsHelperIgnoreDialog_OnHide()
    StaticPopup_Hide('GROUP_FINDER_HELPER_IGNORE_CLEAR_ALL_CONFIRM')
end

function IngoreList:PremakeGroupsHelperDialog_OnHide()
    self.frame:Hide()
end

function IngoreList:filterPlayersWithKeyWord(data)
    local result = {}

    if not data then
        return {}
    end

    if not self.searchText then
        return data
    end

    for k, v in pairs(data) do
        if k and string.find(k, self.searchText) then
            result[k] = v
        end
    end

    return result
end

function IngoreList:PremakeGroupsHelperIgnoreDialogLists_OnUpdate(frame)
    local spamfilter = self:filterPlayersWithKeyWord(config:getValue({"spamfilter"}))
    local numSpams = spamfilter and utils.tnums(spamfilter) or 0
    HybridScrollFrame_Update(frame, numSpams * PLAYER_TITLE_HEIGHT + 20 , frame:GetHeight());
    self:updateScrollFrame(frame)
end

function IngoreList:PremakeGroupsHelperIgnoreDialogLists_OnShow(frame)
    self:PremakeGroupsHelperIgnoreDialogLists_OnUpdate(frame)
end

function IngoreList:PremakeGroupsHelperIgnoreDialogButtons_OnClick(frame)
    if not frame or not frame:GetParent() or not frame:GetParent().spamName then
        return
    end

    local spamfilter = config:getValue({"spamfilter"})
    spamfilter[frame:GetParent().spamName] = nil

    self:PremakeGroupsHelperIgnoreDialogLists_OnUpdate(self.frame.lists)
end

function IngoreList:PremakeGroupsHelperIgnoreDialogClearButton_OnClick(frame)
    StaticPopup_Show('GROUP_FINDER_HELPER_IGNORE_CLEAR_ALL_CONFIRM')
end


function IngoreList:clearAll()
    config:setValue({"spamfilter"}, {})
    self:PremakeGroupsHelperIgnoreDialogLists_OnUpdate(self.frame.lists)
end

function IngoreList:updateScrollFrame(frame)
	local buttons = frame.buttons;
	local numButtons = #buttons;
	local scrollOffset = HybridScrollFrame_GetOffset(frame);
    local STRIPE_COLOR = {r=0.9, g=0.9, b=1};
    local spamfilter = self:filterPlayersWithKeyWord(config:getValue({"spamfilter"}))
    local filter = spamfilter and utils.tkeys(spamfilter) or nil

    for i = 1, numButtons do
		data = filter and (filter[i + scrollOffset] or nil) or nil;
		if ( data  ) then
			buttons[i]:Show();
            buttons[i].spamName = data
			buttons[i].text:SetText(data);

			if ((i+scrollOffset) == 1) then
				buttons[i].BgTop:Show();
				buttons[i].BgMiddle:SetPoint("TOP", buttons[i].BgTop, "BOTTOM");
			else
				buttons[i].BgTop:Hide();
				buttons[i].BgMiddle:SetPoint("TOP");
			end

			if ((i+scrollOffset)%2 == 0) then
				buttons[i].Stripe:SetColorTexture(STRIPE_COLOR.r, STRIPE_COLOR.g, STRIPE_COLOR.b);
				buttons[i].Stripe:SetAlpha(0.1);
				buttons[i].Stripe:Show();
			else
				buttons[i].Stripe:Hide();
			end
		else
			buttons[i]:Hide();
		end
	end

    self.frame.Total:SetText(lang["dialog.ignore.total"] .. #filter or 0)
end

function IngoreList:PremakeGroupsHelperIgnoreDialogSearch_onTextChanged(frame, userInput)
    self.searchText = frame:GetText()

    if not userInput then
        return
    end
    
    self:PremakeGroupsHelperIgnoreDialogLists_OnUpdate(self.frame.lists)
end

function IngoreList:initialize(frame)
    self.frame = PremakeGroupsHelperIgnoreDialog
    if not self.frame then
        return
    end

    self.frame.lists.scrollBar.doNotHide = 1;
    self.frame.lists:SetFrameLevel(CharacterFrameInsetRight:GetFrameLevel() + 1);
    HybridScrollFrame_OnLoad(self.frame.lists);

    dialog:_registerScriptEvent(self.frame, "OnMouseDown", "PremakeGroupsHelperIgnoreDialog_OnMouseDown")
    dialog:_registerScriptEvent(self.frame, "OnMouseUp", "PremakeGroupsHelperIgnoreDialog_OnMouseUp")
    dialog:_registerScriptEvent(self.frame, "OnShow", "PremakeGroupsHelperIgnoreDialog_OnShow")
    dialog:_registerScriptEvent(self.frame, "OnHide", "PremakeGroupsHelperIgnoreDialog_OnHide")
    dialog:_registerScriptEvent(self.frame.lists, "OnShow", "PremakeGroupsHelperIgnoreDialogLists_OnShow")
    self.frame.lists.update = utils.handler(self, IngoreList.PremakeGroupsHelperIgnoreDialogLists_OnUpdate)
	HybridScrollFrame_CreateButtons(self.frame.lists, "PremakeGroupsHelperIgnoreButtonTemplate", 6, -4);

    for k, v in ipairs(self.frame.lists.buttons) do
        v.clean:SetScript("OnClick", utils.handler(self, IngoreList.PremakeGroupsHelperIgnoreDialogButtons_OnClick))
    end

    dialog:_registerScriptEvent(self.frame.search, "OnTextChanged", "PremakeGroupsHelperIgnoreDialogSearch_onTextChanged")

    self.frame.Title:SetText(lang["dialog.ignore.title"])
    self.frame.Total:SetText(lang["dialog.ignore.total"])
    self.frame.clearButton:SetText(lang["dialog.ignore.clearbutton"])
    dialog:_registerScriptEvent(self.frame.clearButton, "OnClick", "PremakeGroupsHelperIgnoreDialogClearButton_OnClick")

    StaticPopupDialogs['GROUP_FINDER_HELPER_IGNORE_CLEAR_ALL_CONFIRM'] = {
        text = lang["dialog.ignore.clearall"],
        button1 = OKAY,
        button2 = NO,
        hideOnEscape = true,
        timeout = 0,
        exclusive = true,
        showAlert = true,
        OnAccept = function(s) PlaySound(SOUNDKIT.IG_MAINMENU_OPEN) self:clearAll() end,
        OnCancel = function(s) PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE) StaticPopup_Hide('GROUP_FINDER_HELPER_IGNORE_CLEAR_ALL_CONFIRM') end,
    }
end


dialog:registerHandlers(IngoreList)
event:registerHandlers(IngoreList)