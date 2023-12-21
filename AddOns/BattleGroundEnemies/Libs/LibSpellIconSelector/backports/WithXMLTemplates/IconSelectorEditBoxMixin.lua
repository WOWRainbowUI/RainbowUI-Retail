BackportedIconSelectorEditBoxMixin = {};

function BackportedIconSelectorEditBoxMixin:OnTextChanged()
	local iconSelectorPopupFrame = self:GetIconSelectorPopupFrame();
	local text = self:GetText();
	text = string.gsub(text, "\"", "");
	if #text > 0 then
		iconSelectorPopupFrame.BorderBox.OkayButton:Enable();
	else
		iconSelectorPopupFrame.BorderBox.OkayButton:Disable();
	end
end

function BackportedIconSelectorEditBoxMixin:OnEnterPressed()
	local text = self:GetText();
	text = string.gsub(text, "\"", "");
	if #text > 0 then
		self:GetIconSelectorPopupFrame():OkayButton_OnClick();
	end
end

function BackportedIconSelectorEditBoxMixin:OnEscapePressed()
	self:GetIconSelectorPopupFrame():CancelButton_OnClick();
end

function BackportedIconSelectorEditBoxMixin:GetIconSelectorPopupFrame()
	return self.editBoxIconSelector;
end

function BackportedIconSelectorEditBoxMixin:SetIconSelector(iconSelector)
	self.editBoxIconSelector = iconSelector;
end