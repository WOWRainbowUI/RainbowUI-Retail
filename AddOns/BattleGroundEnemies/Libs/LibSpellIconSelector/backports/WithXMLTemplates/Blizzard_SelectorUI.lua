
BackportedSelectorMixin = {};

function BackportedSelectorMixin:OnSelection(selectionIndex)
	if self.selectedCallback ~= nil then
		self.selectedCallback(selectionIndex, self:GetSelection(selectionIndex));
	end

	self:SetSelectedIndex(selectionIndex);
end

function BackportedSelectorMixin:SetSelectedIndex(selectionIndex)
	self.selectedIndex = selectionIndex;
	self:UpdateAllSelectedTextures();
end

function BackportedSelectorMixin:GetSelectedIndex()
	return self.selectedIndex;
end

function BackportedSelectorMixin:UpdateAllSelectedTextures()
	if self.initialized then
		for button in self:EnumerateButtons() do
			button:UpdateSelectedTexture();
		end
	end
end

function BackportedSelectorMixin:IsSelected(selectionIndex)
	return selectionIndex == self.selectedIndex;
end

-- callback takes the selectionIndex and the selection.
function BackportedSelectorMixin:SetSelectedCallback(callback)
	self.selectedCallback = callback;
end

function BackportedSelectorMixin:SetSelectionsArray(selectionsArray)
	local function SelectorGetArraySelectionByIndex(selectionIndex)
		return selectionsArray[selectionIndex];
	end

	local function SelectorGetNumArraySelections()
		return #selectionsArray;
	end

	self:SetSelectionsDataProvider(SelectorGetArraySelectionByIndex, SelectorGetNumArraySelections);
end

function BackportedSelectorMixin:SetSelectionsDataProvider(getSelectionByIndex, getNumSelections)
	self.getSelectionByIndex = getSelectionByIndex;
	self.getNumSelections = getNumSelections;
	self:UpdateSelections();
end

function BackportedSelectorMixin:GetNumSelections()
	return (self.getNumSelections ~= nil) and self.getNumSelections() or 0;
end

function BackportedSelectorMixin:GetSelection(selectionIndex)
	return self.getSelectionByIndex(selectionIndex);
end

function BackportedSelectorMixin:SetCustomButtonTemplate(customTemplateType, customButtonTemplate)
	self.templateType = customTemplateType;
	self.buttonTemplate = customButtonTemplate;
end

function BackportedSelectorMixin:GetButtonTemplate()
	return self.templateType, self.buttonTemplate;
end

-- Takes the button to setup, the selectionIndex, and the selection.
function BackportedSelectorMixin:SetSetupCallback(setupCallback)
	self.setupCallback = setupCallback;
end

function BackportedSelectorMixin:GetSetupCallback()
	return self.setupCallback;
end

function BackportedSelectorMixin:RunSetup(button, selectionIndex)
	button:Init(self);

	button:SetSelectionIndex(selectionIndex);

	if self.setupCallback ~= nil then
		self.setupCallback(button, selectionIndex, self:GetSelection(selectionIndex));
	end
end

-- Override in your derived mixin.
function BackportedSelectorMixin:EnumerateButtons()
	return nil;
end

-- Override in your derived mixin.
function BackportedSelectorMixin:UpdateSelections()
end

BackportedSelectorButtonMixin = {};

function BackportedSelectorButtonMixin:Init(selectorFrame)
	self.selectorFrame = selectorFrame;
end

function BackportedSelectorButtonMixin:SetSelectionIndex(selectionIndex)
	self.selectionIndex = selectionIndex;
	self:UpdateSelectedTexture();
end

function BackportedSelectorButtonMixin:GetSelectionIndex()
	return self.selectionIndex;
end

function BackportedSelectorButtonMixin:SetIconTexture(iconTexture)
	self.Icon:SetTexture(iconTexture);
end

function BackportedSelectorButtonMixin:GetIconTexture()
	return self.Icon:GetTexture();
end

function BackportedSelectorButtonMixin:UpdateSelectedTexture()
	self.SelectedTexture:SetShown(self:GetSelectorFrame():IsSelected(self.selectionIndex));
end

function BackportedSelectorButtonMixin:OnClick()
	self:GetSelectorFrame():OnSelection(self.selectionIndex);
end

function BackportedSelectorButtonMixin:GetSelection()
	return self:GetSelectorFrame():GetSelection(self.selectionIndex);
end

function BackportedSelectorButtonMixin:GetSelectorFrame()
	return self.selectorFrame;
end


