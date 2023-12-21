 
BackportedIconSelectorPopupFrameTemplateMixin = {};

IconSelectorPopupFrameModes = EnumUtil.MakeEnum(
	"New",
	"Edit"
);

local ValidIconSelectorCursorTypes = {
	"item",
	"spell",
	"mount",
	"battlepet",
	"macro"
};

local IconSelectorPopupFramesShown = 0;

function BackportedIconSelectorPopupFrameTemplateMixin:OnLoad()
	local function IconButtonInitializer(button, selectionIndex, icon)
		button:SetIconTexture(icon);
	end
	self.IconSelector:SetSetupCallback(IconButtonInitializer);
	self.IconSelector:AdjustScrollBarOffsets(0, 18, -1);

	self.BorderBox.OkayButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
		self:OkayButton_OnClick();
	end);

	self.BorderBox.CancelButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
		self:CancelButton_OnClick();
	end);

	self.BorderBox.EditBoxHeaderText:SetText(self.editBoxHeaderText);
end

-- Usually overridden by inheriting frame.
function BackportedIconSelectorPopupFrameTemplateMixin:OnShow()
	IconSelectorPopupFramesShown = IconSelectorPopupFramesShown + 1;

	self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconSelector(self);
	self.BorderBox.IconSelectorEditBox:SetIconSelector(self);
end

-- Usually overridden by inheriting frame.
function BackportedIconSelectorPopupFrameTemplateMixin:OnHide()
	IconSelectorPopupFramesShown = IconSelectorPopupFramesShown - 1;
end

-- Usually overridden by inheriting frame.
function BackportedIconSelectorPopupFrameTemplateMixin:Update()
end

function BackportedIconSelectorPopupFrameTemplateMixin:OnEvent(event, ...)
end

function BackportedIconSelectorPopupFrameTemplateMixin:SetIconFromMouse()
	local cursorType, ID = GetCursorInfo();
	for _, validType in ipairs(ValidIconSelectorCursorTypes) do
		if ( cursorType == validType ) then
			local icon;
			if ( cursorType == "item" ) then
				icon = select(10, GetItemInfo(ID));
			elseif ( cursorType == "spell" ) then
				-- 'ID' field for spells would actually be the slot number, not the actual spellID, so we get this separately.
				local spellID = select(4, GetCursorInfo());
				icon = select(3, GetSpellInfo(spellID));
			elseif ( cursorType == "mount" ) then
				icon = select(3, C_MountJournal.GetMountInfoByID(ID));
			elseif ( cursorType == "battlepet" ) then
				icon = select(9, C_PetJournal.GetPetInfoByPetID(ID));
			elseif ( cursorType == "macro" ) then
				icon = select(2, GetMacroInfo(ID));
			end

			self.IconSelector:SetSelectedIndex(self:GetIndexOfIcon(icon));
			self.IconSelector:ScrollToSelectedIndex();
			ClearCursor();

			if ( icon ) then
				self.BorderBox.SelectedIconArea.SelectedIconButton:SetIconTexture(icon);
				self.BorderBox.SelectedIconArea.SelectedIconButton:SetSelectedTexture();
			end

			self:SetSelectedIconText();
			break;
		end
	end
end

function BackportedIconSelectorPopupFrameTemplateMixin:SetSelectedIconText()
	if ( self:GetSelectedIndex() ) then
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconHeader:SetText(ICON_SELECTION_TITLE_CURRENT);
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_CLICK);
	else
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconHeader:SetText(ICON_SELECTION_TITLE_CUSTOM);
		self.BorderBox.SelectedIconArea.SelectedIconText.SelectedIconDescription:SetText(ICON_SELECTION_NOTINLIST);
	end

	self.BorderBox.SelectedIconArea.SelectedIconText:Layout();
end

-- Usually overridden by inheriting frame.
function BackportedIconSelectorPopupFrameTemplateMixin:OkayButton_OnClick()
	self:Hide();
end

-- Usually overridden by inheriting frame.
function BackportedIconSelectorPopupFrameTemplateMixin:CancelButton_OnClick()
	self:Hide();
end

function BackportedIconSelectorPopupFrameTemplateMixin:GetIconByIndex(index)
	return self.iconDataProvider:GetIconByIndex(index);
end

function BackportedIconSelectorPopupFrameTemplateMixin:GetIndexOfIcon(icon)
	return self.iconDataProvider:GetIndexOfIcon(icon);
end

function BackportedIconSelectorPopupFrameTemplateMixin:GetNumIcons()
	return self.iconDataProvider:GetNumIcons();
end

function BackportedIconSelectorPopupFrameTemplateMixin:GetSelectedIndex()
	return self.IconSelector:GetSelectedIndex();
end

function IsAnyIconSelectorPopupFrameShown()
	return IconSelectorPopupFramesShown and IconSelectorPopupFramesShown > 0;
end