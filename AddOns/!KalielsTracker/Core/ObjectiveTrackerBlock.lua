---@type KT
local _, KT = ...

KT_ObjectiveTrackerBlockMixin = CreateFromMixins(KT_ObjectiveTrackerSlidingMixin);

-- Called on frame creation
function KT_ObjectiveTrackerBlockMixin:Init()
	self.usedLines = { };
	self.rightEdgeOffset = 0;
	
	-- Other Keys
	-- parentModule: owning module
	-- used: shown
	-- id: block key
	-- lastRegion: last region added
	-- isHighlighted: moused over	
	-- height

	-- offsetX: override for module.blockOffsetX
	-- fixedWidth: whether it has fixed width
	-- fixedHeight: whether it has fixed height
	-- rightEdgeFrame: the latest frame added to right edge
	-- addedRegions: list of regions added via AddTimer, AddRightEdgeFrame, etc
end

-- Called at the beginning of a layout
function KT_ObjectiveTrackerBlockMixin:Reset()
	self.used = false;
	self.nextBlock = nil;
	if self.rightEdgeOffset then
		if self.HeaderText then
			self.HeaderText:SetPoint("RIGHT", 0, 0);
		end
		self.rightEdgeOffset = 0;
		self.rightEdgeFrame = nil;
	end
	if not self.fixedHeight then
		self.height = 0;
	end
	self.lastRegion = nil;
	self.addedRegions = nil;
	for objectiveKey, line in pairs(self.usedLines) do
		line.used = nil;
	end
end

-- Called when the block is no longer used
function KT_ObjectiveTrackerBlockMixin:Free()
	-- free all the lines
	for _, line in pairs(self.usedLines) do
		self:FreeLine(line);
	end
	table.wipe(self.usedLines);
	
	if self.HeaderText then
		self.HeaderText:SetText("");
	end

	if self.slideInfo then
		self:EndSlide();
	end

	if self.addedRegions then
		for region, isManaged in pairs(self.addedRegions) do
			-- managed means unused ones get freed from module:EndLayout()
			if isManaged then
				region.used = nil;
			else
				region:Hide();
			end
		end
	end
end

function KT_ObjectiveTrackerBlockMixin:OnAddedRegion(region, isManaged)
	if not self.addedRegions then
		self.addedRegions = { };
	end
	self.addedRegions[region] = isManaged;
end

function KT_ObjectiveTrackerBlockMixin:GetLine(objectiveKey, optTemplate)
	local template = optTemplate or self.parentModule.lineTemplate;

	-- first look for existing line
	local line = self:GetExistingLine(objectiveKey);

	-- if existing line is not of the same type, discard it
	if line and line.template ~= template then
		self:FreeLine(line);
		line = nil;
	end
	
	-- acquire a new line if needed
	if not line then
		line = KT.ObjectiveTrackerManager:AcquireFrame(self, template);
		line:SetParent(self);
		line:Show();		
	end
	
	self.usedLines[objectiveKey] = line;
	line.objectiveKey = objectiveKey;
	line.parentBlock = self;
	line.used = true;
	return line;
end

function KT_ObjectiveTrackerBlockMixin:GetExistingLine(objectiveKey)
	return self.usedLines[objectiveKey];
end

function KT_ObjectiveTrackerBlockMixin:FreeUnusedLines()
	for objectiveKey, line in pairs(self.usedLines) do
		if not line.used then
			self:FreeLine(line);
		end
	end
end

function KT_ObjectiveTrackerBlockMixin:FreeLine(line)
	self.usedLines[line.objectiveKey] = nil;
	KT.ObjectiveTrackerManager:ReleaseFrame(line);
	line:Hide();
	if line.OnFree then
		line:OnFree(self);
	end
end

function KT_ObjectiveTrackerBlockMixin:ForEachUsedLine(func)
	for objectiveKey, line in pairs(self.usedLines) do
		if func(line, objectiveKey) then
			return;
		end
	end
end

function KT_ObjectiveTrackerBlockMixin:SetStringText(fontString, text, useFullHeight, colorStyle, useHighlight)
	if useFullHeight then
		fontString:SetMaxLines(0);
	else
		fontString:SetMaxLines(2);
	end
	fontString:SetHeight(0);	-- force a clear of internals or GetHeight() might return an incorrect value
	fontString:SetText(text);

	local stringHeight = fontString:GetHeight();
	colorStyle = colorStyle or KT_OBJECTIVE_TRACKER_COLOR["Normal"];
	if useHighlight and colorStyle.reverse then
		colorStyle = colorStyle.reverse;
	end
	if fontString.colorStyle ~= colorStyle then
		fontString:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
		fontString.colorStyle = colorStyle;
	end
	return stringHeight;
end
KT.BackupMixin("KT_ObjectiveTrackerBlockMixin", "SetStringText")  -- MSA

function KT_ObjectiveTrackerBlockMixin:SetHeader(text)
	self.HeaderText:SetPoint("RIGHT", self.rightEdgeOffset, 0);
	local height = self:SetStringText(self.HeaderText, text, true, KT_OBJECTIVE_TRACKER_COLOR["Header"], self.isHighlighted);  -- fix Blizz bug
	self.height = height;
end
KT.BackupMixin("KT_ObjectiveTrackerBlockMixin", "SetHeader")  -- MSA

function KT_ObjectiveTrackerBlockMixin:AddObjective(objectiveKey, text, template, useFullHeight, dashStyle, colorStyle, adjustForNoText, overrideHeight)
	local line = self:GetLine(objectiveKey, template);

	line.progressBar = nil;

	-- dash
	if line.Dash then
		if not dashStyle then
			dashStyle = KT_OBJECTIVE_DASH_STYLE_SHOW;
		end
		if line.dashStyle ~= dashStyle then
			if dashStyle == KT_OBJECTIVE_DASH_STYLE_SHOW then
				line.Dash:Show();
				line.Dash:SetText(QUEST_DASH);
			elseif dashStyle == KT_OBJECTIVE_DASH_STYLE_HIDE then
				line.Dash:Hide();
				line.Dash:SetText(QUEST_DASH);
			elseif dashStyle == KT_OBJECTIVE_DASH_STYLE_HIDE_AND_COLLAPSE then
				line.Dash:Hide();
				line.Dash:SetText(nil);
			else
				assertsafe(false, "Invalid dash style: " .. tostring(dashStyle));
			end
			line.dashStyle = dashStyle;
		end
	end

	local lineSpacing = self.parentModule.lineSpacing;
	local offsetY = -lineSpacing;

	-- anchor the line
	local anchor = self.lastRegion or self.HeaderText;
	if anchor then
		line:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, offsetY);
	else
		line:SetPoint("TOPLEFT", 0, offsetY);
	end
	line:SetPoint("RIGHT", self.rightEdgeOffset, 0);

	-- set the text
	local textHeight = self:SetStringText(line.Text, text, useFullHeight, colorStyle, self.isHighlighted);
	local height = overrideHeight or textHeight;
	line:SetHeight(height);

	self.height = self.height + height + lineSpacing;

	self.lastRegion = line;
	return line;
end
KT.BackupMixin("KT_ObjectiveTrackerBlockMixin", "AddObjective")  -- MSA

function KT_ObjectiveTrackerBlockMixin:AddCustomRegion(region, optOffsetX, optOffsetY)
	local offsetX = optOffsetX or 0;
	local offsetY = optOffsetY or -self.parentModule.lineSpacing;
	-- anchor the line
	local anchor = self.lastRegion or self.HeaderText;
	if anchor then
		region:SetPoint("TOP", anchor, "BOTTOM", 0, offsetY);
		region:SetPoint("LEFT", offsetX, 0);
	else
		region:SetPoint("TOPLEFT", offsetX, offsetY);
	end
	
	self.height = self.height + region:GetHeight() - offsetY;
	self.lastRegion = region;
	region:Show();
	local isManaged = false;
	self:OnAddedRegion(region, isManaged);
end

function KT_ObjectiveTrackerBlockMixin:AddTimerBar(duration, startTime)
	local line = self.lastRegion;
	if not line then
		return nil;
	end

	local timerBar = self.parentModule:GetTimerBar(line);

	local lineSpacing = self.parentModule.lineSpacing;
	local anchor = self.lastRegion or self.HeaderText;
	if anchor then
		timerBar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -lineSpacing);
	else
		timerBar:SetPoint("TOPLEFT", 0, -lineSpacing);
	end

	timerBar.Bar:SetMinMaxValues(0, duration);
	timerBar.duration = duration;
	timerBar.startTime = startTime;
	timerBar.parentLine = line;

	self.height = self.height + timerBar.height + lineSpacing;
	self.lastRegion = timerBar;
	local isManaged = true;
	self:OnAddedRegion(timerBar, isManaged);
	return timerBar;
end
KT.BackupMixin("KT_ObjectiveTrackerBlockMixin", "AddTimerBar")  -- MSA

function KT_ObjectiveTrackerBlockMixin:AddProgressBar(id, lineSpacing)
	local line = self.lastRegion;
	if not line then
		return nil;
	end
	
	local progressBar = self.parentModule:GetProgressBar(line, id);

	lineSpacing = lineSpacing or self.parentModule.lineSpacing;
	local anchor = self.lastRegion or self.HeaderText;
	if anchor then
		progressBar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -lineSpacing);
	else
		progressBar:SetPoint("TOPLEFT", 0, -lineSpacing);
	end
	
	line.progressBar = progressBar;
	progressBar.parentLine = line;

	self.height = self.height + progressBar.height + lineSpacing;
	self.lastRegion = progressBar;
	local isManaged = true;
	self:OnAddedRegion(progressBar, isManaged);
	return progressBar;
end
KT.BackupMixin("KT_ObjectiveTrackerBlockMixin", "AddProgressBar")  -- MSA

function KT_ObjectiveTrackerBlockMixin:OnHeaderClick(mouseButton)
	self.parentModule:OnBlockHeaderClick(self, mouseButton);
end

function KT_ObjectiveTrackerBlockMixin:OnHeaderEnter()
	self.isHighlighted = true;
	self:UpdateHighlight();
	self.parentModule:OnBlockHeaderEnter(self);
end

function KT_ObjectiveTrackerBlockMixin:OnHeaderLeave()
	self.isHighlighted = false;
	self:UpdateHighlight();	
	self.parentModule:OnBlockHeaderLeave(self);
end

function KT_ObjectiveTrackerBlockMixin:UpdateHighlight()
	local headerColor, dashColor;
	if self.isHighlighted then
		headerColor = KT_OBJECTIVE_TRACKER_COLOR["HeaderHighlight"];
		dashColor = KT_OBJECTIVE_TRACKER_COLOR["NormalHighlight"];
	else
		headerColor = KT_OBJECTIVE_TRACKER_COLOR["Header"];
		dashColor = KT_OBJECTIVE_TRACKER_COLOR["Normal"];
	end

	if self.HeaderText then
		self.HeaderText:SetTextColor(headerColor.r, headerColor.g, headerColor.b);
		self.HeaderText.colorStyle = headerColor;
	end
	
	for objectiveKey, line in pairs(self.usedLines) do
		local colorStyle = line.Text.colorStyle.reverse;
		if colorStyle then
			line.Text:SetTextColor(colorStyle.r, colorStyle.g, colorStyle.b);
			line.Text.colorStyle = colorStyle;
			if line.Dash then
				line.Dash:SetTextColor(dashColor.r, dashColor.g, dashColor.b);
			end
		end
	end
end
KT.BackupMixin("KT_ObjectiveTrackerBlockMixin", "UpdateHighlight")  -- MSA

function KT_ObjectiveTrackerBlockMixin:AdjustSlideAnchor(offsetY)
	self.HeaderText:SetPoint("TOPLEFT", 0, offsetY);
end

function KT_ObjectiveTrackerBlockMixin:AdjustRightEdgeOffset(offset)
	-- this must be done before setting any lines
	assert(not self.lastRegion);
	self.rightEdgeOffset = self.rightEdgeOffset + offset;
end

local function MakeRightEdgeFrameKey(frameKey, instanceKey)
	return frameKey .. instanceKey;
end

function KT_ObjectiveTrackerBlockMixin:AddRightEdgeFrame(settings, identifier, ...)
	local frame = self.parentModule:GetRightEdgeFrame(settings, identifier);

	if self.rightEdgeFrame == frame then
		-- TODO: Fix for real, some event causes the findGroup button to get added twice (could happen for any button)
		-- so it doesn't need to be reanchored another time
		return;
	end

	frame:ClearAllPoints();

	local spacing = self.parentModule.rightEdgeFrameSpacing;
	if self.rightEdgeFrame then
		frame:SetPoint("RIGHT", self.rightEdgeFrame, "LEFT", -spacing, 0);
	else
		frame:SetPoint("TOPRIGHT", self, settings.offsetX, settings.offsetY);
		self:AdjustRightEdgeOffset(settings.offsetX);
	end

	frame:SetUp(identifier, ...);

	self.rightEdgeFrame = frame;
	self:AdjustRightEdgeOffset(-frame:GetWidth() - spacing);
	local isManaged = true;
	self:OnAddedRegion(frame, isManaged);
	return frame;
end
KT.BackupMixin("KT_ObjectiveTrackerBlockMixin", "AddRightEdgeFrame")  -- MSA

KT_ObjectiveTrackerBlockHeaderMixin = { };

function KT_ObjectiveTrackerBlockHeaderMixin:OnLoad()
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function KT_ObjectiveTrackerBlockHeaderMixin:OnClick(mouseButton)
	local block = self:GetParent();
	block:OnHeaderClick(mouseButton);
end

function KT_ObjectiveTrackerBlockHeaderMixin:OnEnter()
	local block = self:GetParent();
	block:OnHeaderEnter();
end

function KT_ObjectiveTrackerBlockHeaderMixin:OnLeave()
	local block = self:GetParent();
	block:OnHeaderLeave();
end