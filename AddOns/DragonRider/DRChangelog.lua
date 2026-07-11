local _, DR = ...;
local L = DR.L;

local CHANGELOG_TEXT = [[
#    
 
# Dragon Rider has hit 1 million downloads!

## When I first made this addon, it was pretty rough and I only knew some real basics. I've always been an artist first before a coder. I started out wanting to make a speedometer to pair with the Vigor bar in Dragonflight. I never really knew I'd get this far. Blizzard's widget was also kind of a pain to work with - the vigor frame didn't really want to fade or have its colors changed, and it seemingly would shift in some certain direction if I tied the speedometer to it. I probably could have made it better of course, but it was pretty difficult to work with as is.

## I expanded wanting the project to also be able track race scores. The older journal I made was... pretty rough. I've actually just gotten around to giving it what I hope is a bit of a fancy overhaul - partly from my experience working on Artificer and particularly Weather's almanac feature.

## Updates were a bit more quiet around March 2025, around the time of the Undermine 11.1 patch, I had fully intended to add more features for the DRIVE system but a lot of real life happened including the passing of my dog Bubba. Some of the remnants of what I worked on still remain in the DriveUI file, but I just never got around to finishing it. Maybe some day, if we ever revisit the place or DRIVE is relevant again, but I think I missed that window of opportunity.

## Near the launch of Midnight / 11.2.7 housing update, when Blizzard effectively removed the Vigor widget, I made it my goal to try to bring far more customization to the addon and restore the old widget visually. It was a pretty difficult task, I probably spent somewhere close to a month of all of my free time working on it, trying to make it look and behave as close to the original as possible.

## In more recent updates, I've looked into adding global API functions for addons to hook into and allow them to use their own custom textures and themes for the vigor bar and speedometer. Since I've added so many customizable options, it kind of came to my realization that an import/export was necessary at this point. A functional profile system was a pretty big undertaking, all of it is pretty new to me, so hopefully it doesn't break horribly.

## Looking toward the future, I hope to add some easier ways for users to add in custom assets for their own loadouts because there's a lot of ways I think I could help facilitate making creative layouts for users. Nothing solid yet, but it's something I want to eventually do - Zelda style carrots theme comes to mind for example. I don't want to bloat file size by adding a ton of my own custom frames that people may use like 1% of the time, and I'd rather those be sub-module addons to this one.

## I'd like to particularly thank Peterodox, Raenore, Solanya, Meorawr, and Ghost for helping with some of the various coding hurdles I've encountered over the years.

## I'd also like to thank you (yes, you!) the user for trying out my addon, giving feedback on certain features and pointing out bugs, and overall just for being you. I wouldn't have been able to make it without your support.

## Thank you.

#    

#    

]]


local function FormatInline(text)
	text = text:gsub("%*%*(.-)%*%*", "|cffffffff%1|r");
	text = text:gsub("%[(.-)%]%((.-)%)", "|cff66bbff%1|r");
	return text;
end

local function ParseMarkdown(text)
	local blocks = {};
	for line in text:gmatch("[^\r\n]+") do
		local cleanLine = line:gsub("^%s+", "");
		if cleanLine ~= "" then
			if cleanLine:match("^# ") then
				table.insert(blocks, { type = "h1", content = FormatInline(cleanLine:gsub("^# ", "")) });
			elseif cleanLine:match("^## ") then
				table.insert(blocks, { type = "h2", content = FormatInline(cleanLine:gsub("^## ", "")) });
			elseif cleanLine:match("^### ") then
				table.insert(blocks, { type = "h3", content = FormatInline(cleanLine:gsub("^### ", "")) });
			elseif cleanLine:match("^%- ") then
				table.insert(blocks, { type = "list", content = FormatInline(cleanLine:gsub("^%- ", "")) });
			else
				table.insert(blocks, { type = "text", content = FormatInline(cleanLine) });
			end
		end
	end
	return blocks;
end

local function UpdateChangelogLayout(contentFrame)
	local newWidth = contentFrame:GetParent():GetWidth() - 10;
	contentFrame:SetWidth(newWidth);
	local currentY = -10;

	for _, item in ipairs(contentFrame.items) do
		item.fs:SetWidth(newWidth);
		item.fs:SetPoint("TOPLEFT", 10, currentY);
		currentY = currentY - item.fs:GetStringHeight() - item.spacing;
	end
	contentFrame:SetHeight(math.abs(currentY) + 20);
end

local function CreateChangelogFrame()
	local frame = CreateFrame("Frame", nil, DR.mainFrame);
	
	frame:SetPoint("TOPLEFT", DR.mainFrame, "TOPLEFT", 2, -25);
	frame:SetPoint("BOTTOMRIGHT", DR.mainFrame, "BOTTOMRIGHT", -2, 4);
	frame:SetFrameLevel(50);
	frame:EnableMouse(true);

	local bg = frame:CreateTexture(nil, "BACKGROUND");
	bg:SetAllPoints();
	bg:SetColorTexture(0.05, 0.05, 0.05, 0.95);

	local heartPool = {};
	local function SpawnHeart(parent)
		local heart = nil;
		
		for _, h in ipairs(heartPool) do
			if not h:IsShown() then
				heart = h;
				break;
			end
		end

		if not heart then
			heart = parent:CreateTexture(nil, "ARTWORK");
			heart:SetAtlas("delves-scenario-heart-icon");
			
			local animGroup = heart:CreateAnimationGroup();
			local fade = animGroup:CreateAnimation("Alpha");
			fade:SetFromAlpha(0.5);
			fade:SetToAlpha(0);
			fade:SetDuration(2.5);
			fade:SetSmoothing("OUT");
			
			animGroup:SetScript("OnFinished", function()
				heart:Hide();
			end);
			heart.anim = animGroup;
			
			table.insert(heartPool, heart);
		end

		local size = math.random(32, 64);
		heart:SetSize(size, size);
		
		local maxX = math.max(1, math.floor(parent:GetWidth() - size));
		local maxY = math.max(1, math.floor(parent:GetHeight() - size));
		local x = math.random(0, maxX);
		local y = -math.random(0, maxY);
		
		heart:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y);
		heart:Show();
		heart.anim:Play();
	end

	local timeSinceLastSpawn = 0;
	local currentSpawnRate = 2.0;

	frame:SetScript("OnUpdate", function(self, elapsed)
		timeSinceLastSpawn = timeSinceLastSpawn + elapsed;
		if timeSinceLastSpawn >= currentSpawnRate then
			timeSinceLastSpawn = 0;
			currentSpawnRate = math.random(15, 25) / 10;
			SpawnHeart(self);
		end
	end);

	frame:SetScript("OnShow", function()
		timeSinceLastSpawn = currentSpawnRate;
	end);

	local scrollFrame = CreateFrame("ScrollFrame", nil, frame);
	scrollFrame:SetPoint("TOPLEFT", 10, 0);
	scrollFrame:SetPoint("BOTTOMRIGHT", -35, 0);
	
	Mixin(scrollFrame, CallbackRegistryMixin);
	scrollFrame:OnLoad();
	
	local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar");
	scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 20, 0);
	scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 20, 0);
	
	ScrollUtil.InitScrollFrameWithScrollBar(scrollFrame, scrollBar);

	local content = CreateFrame("Frame", nil, scrollFrame);
	scrollFrame:SetScrollChild(content);
	content.items = {};

	local blocks = ParseMarkdown(CHANGELOG_TEXT);
	for _, block in ipairs(blocks) do
		local fs = content:CreateFontString(nil, "OVERLAY");
		fs:SetJustifyH("LEFT");
		fs:SetJustifyV("TOP");
		local spacing = 8;

		if block.type == "h1" then
			fs:SetFontObject("GameFontNormalHuge");
			fs:SetText(block.content);
			fs:SetTextColor(1, 0.82, 0, .85);
			spacing = 15
		elseif block.type == "h2" then
			fs:SetFontObject("GameFontNormalLarge");
			fs:SetText(block.content);
			fs:SetTextColor(1, 1, 1, .8);
			spacing = 10
		elseif block.type == "h3" then
			fs:SetFontObject("GameFontNormal");
			fs:SetText(block.content);
			fs:SetTextColor(0.8, 0.8, 0.8, .8);
			spacing = 5
		elseif block.type == "list" then
			fs:SetFontObject("GameFontHighlight");
			fs:SetText("• " .. block.content);
			spacing = 5;
		else
			fs:SetFontObject("GameFontHighlight");
			fs:SetText(block.content);
			fs:SetTextColor(.8, .8, .8, .8);
			spacing = 8;
		end

		table.insert(content.items, { fs = fs, spacing = spacing });
	end

	frame:SetScript("OnSizeChanged", function()
		UpdateChangelogLayout(content);
	end)
	UpdateChangelogLayout(content);

	frame:Hide(); 

	return frame;
end

function DR.ToggleChangelog()
	if not DR.mainFrame then return; end

	if DragonRider_DB and not DragonRider_DB.hasSeenChangelog then
		DragonRider_DB.hasSeenChangelog = true;
		if DR.mainFrame.portraitButton and DR.mainFrame.portraitButton.Glow then
			DR.mainFrame.portraitButton.Glow:Hide();
			DR.mainFrame.portraitButton.PulseAnim:Stop();
		end
	end

	if not DR.mainFrame.ChangelogFrame then
		DR.mainFrame.ChangelogFrame = CreateChangelogFrame();
	end

	if DR.mainFrame.ChangelogFrame:IsShown() then
		DR.mainFrame.ChangelogFrame:Hide();
	else
		DR.mainFrame.ChangelogFrame:Show();
	end
end

function DR.HideChangelog()
	if DR.mainFrame and DR.mainFrame.ChangelogFrame then
		DR.mainFrame.ChangelogFrame:Hide();
	end
end