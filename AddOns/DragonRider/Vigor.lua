local _, DR = ...

local L = DR.L
local defaultsTable = DR.defaultsTable


---@type LibAdvFlight
local LibAdvFlight = LibStub:GetLibrary("LibAdvFlight-1.1")

-- temp / default settings
local BAR_X = 0
local BAR_Y = -200
local BAR_WIDTH = 32
local BAR_HEIGHT = 32
local BAR_SPACING = 10
local MAX_CHARGES = 6
local SPELL_ID = 372608

-- 1 for vertical (stacks up), 2 for horizontal (stacks right)
local ORIENTATION = 2

-- 1 for top-to-bottom / left-to-right growth
-- 2 for bottom-to-top / right-to-left growth
local DIRECTION = 1

-- How many bubbles before wrapping to a new row/column
local VIGOR_WRAP = 6

-- 1 for vertical, 2 for horizontal
local BAR_FILL_ORIENTATION = 1

-- 1 for (bottom-to-top / left-to-right)
-- 2 for (top-to-Bottom / right-to-left)
local FILL_DIRECTION = 1

local SPARK_WIDTH = 32
local SPARK_HEIGHT = 12

local FLASH_FULL = true
local FLASH_PROGRESS = true

local VigorColors = {
	full = CreateColor(0.24, 0.84, 1.0, 1.0),
	empty = CreateColor(0.3, 0.3, 0.3, 1.0),
	empty = CreateColor(1.0, 1.0, 1.0, 1.0),
	progress = CreateColor(1.0, 1.0, 1.0, 1.0),
	spark = CreateColor(1.0, 1.0, 1.0, 0.9),
	cover = CreateColor(0.4, 0.4, 0.4, 1.0),
	flash = CreateColor(1.0, 1.0, 1.0, 0.9),
	decor = CreateColor(0.4, 0.4, 0.4, 1.0),
};

local DECOR_X = -15
local DECOR_Y = -10

DR.VigorOptions = {
	[1] = { 
		key = "Default",          -- Add Internal Key
		name = L["Default"],      -- Add Display Name
		Full = {
			Atlas = "dragonriding_vigor_fillfull",
			Desat = false,
		},
		Fill = {
			Atlas = "dragonriding_vigor_fill",
			Desat = false,
		},
		Progress = {
			Atlas = "dragonriding_vigor_fill_flipbook",
			Desat = false,
			Flipbook = {
				Duration = 1.0,
				Rows = 5,
				Columns = 4,
				Frames = 20,
			},
		},
		Background = { -- bar.bg
			Atlas = "dragonriding_vigor_background",
			Desat = false,
		},
		Spark = {
			Atlas = "dragonriding_vigor_spark",
			Desat = false,
		},
		Mask = {
			Atlas = "dragonriding_vigor_mask",
		},
		Cover = {
			Atlas = "dragonriding_vigor_frame",
			Desat = false,
		},
		Flash = {
			Atlas = "dragonriding_vigor_flash",
			Desat = false,
		},
		Overlay = {
			X = .4,
			Y = .4,
		},
	},
	[2] = { -- Algari Bronze, non-desaturated
		key = "AlgariBronze",
		name = L["ThemeAlgari_Bronze"],
		Full = {
			Atlas = "dragonriding_sgvigor_fillfull",
			Desat = false,
		},
		Fill = {
			Atlas = "dragonriding_sgvigor_fillfull",
			Desat = true, -- texture doesn't exist so just use a desat version
		},
		Progress = {
			Atlas = "dragonriding_sgvigor_fill_flipbook",
			Desat = false,
			Flipbook = {
				Duration = 1.0,
				Rows = 5,
				Columns = 4,
				Frames = 20,
			},
		},
		Background = { -- bar.bg
			Atlas = "dragonriding_sgvigor_background",
			Desat = false,
		},
		Spark = {
			Atlas = "dragonriding_sgvigor_spark",
			Desat = false,
		},
		Mask = {
			Atlas = "dragonriding_sgvigor_mask",
		},
		Cover = {
			Atlas = "dragonriding_sgvigor_frame_bronze",
			Desat = false,
		},
		Flash = {
			Atlas = "dragonriding_sgvigor_flash",
			Desat = false,
		},
		Overlay = {
			X = .2,
			Y = .2,
		},
	},
	[3] = { -- Algari Dark, non-desaturated
		key = "Algari_Dark",
		name = L["ThemeAlgari_Dark"],
		Full = {
			Atlas = "dragonriding_sgvigor_fillfull",
			Desat = false,
		},
		Fill = {
			Atlas = "dragonriding_sgvigor_fillfull",
			Desat = true, -- texture doesn't exist so just use a desat version
		},
		Progress = {
			Atlas = "dragonriding_sgvigor_fill_flipbook",
			Desat = false,
			Flipbook = {
				Duration = 1.0,
				Rows = 5,
				Columns = 4,
				Frames = 20,
			},
		},
		Background = { -- bar.bg
			Atlas = "dragonriding_sgvigor_background",
			Desat = false,
		},
		Spark = {
			Atlas = "dragonriding_sgvigor_spark",
			Desat = false,
		},
		Mask = {
			Atlas = "dragonriding_sgvigor_mask",
		},
		Cover = {
			Atlas = "dragonriding_sgvigor_frame_dark",
			Desat = false,
		},
		Flash = {
			Atlas = "dragonriding_sgvigor_flash",
			Desat = false,
		},
		Overlay = {
			X = .2,
			Y = .2,
		},
	},
	[4] = { -- Algari Gold, non-desaturated
		key = "Algari_Gold",
		name = L["ThemeAlgari_Gold"],
		Full = {
			Atlas = "dragonriding_sgvigor_fillfull",
			Desat = false,
		},
		Fill = {
			Atlas = "dragonriding_sgvigor_fillfull",
			Desat = true, -- texture doesn't exist so just use a desat version
		},
		Progress = {
			Atlas = "dragonriding_sgvigor_fill_flipbook",
			Desat = false,
			Flipbook = {
				Duration = 1.0,
				Rows = 5,
				Columns = 4,
				Frames = 20,
			},
		},
		Background = { -- bar.bg
			Atlas = "dragonriding_sgvigor_background",
			Desat = false,
		},
		Spark = {
			Atlas = "dragonriding_sgvigor_spark",
			Desat = false,
		},
		Mask = {
			Atlas = "dragonriding_sgvigor_mask",
		},
		Cover = {
			Atlas = "dragonriding_sgvigor_frame_gold",
			Desat = false,
		},
		Flash = {
			Atlas = "dragonriding_sgvigor_flash",
			Desat = false,
		},
		Overlay = {
			X = .2,
			Y = .2,
		},
	},
	[5] = { -- Algari Silver, non-desaturated
		key = "Algari_Silver",
		name = L["ThemeAlgari_Silver"],
		Full = {
			Atlas = "dragonriding_sgvigor_fillfull",
			Desat = false,
		},
		Fill = {
			Atlas = "dragonriding_sgvigor_fillfull",
			Desat = true, -- texture doesn't exist so just use a desat version
		},
		Progress = {
			Atlas = "dragonriding_sgvigor_fill_flipbook",
			Desat = false,
			Flipbook = {
				Duration = 1.0,
				Rows = 5,
				Columns = 4,
				Frames = 20,
			},
		},
		Background = { -- bar.bg
			Atlas = "dragonriding_sgvigor_background",
			Desat = false,
		},
		Spark = {
			Atlas = "dragonriding_sgvigor_spark",
			Desat = false,
		},
		Mask = {
			Atlas = "dragonriding_sgvigor_mask",
		},
		Cover = {
			Atlas = "dragonriding_sgvigor_frame_silver",
			Desat = false,
		},
		Flash = {
			Atlas = "dragonriding_sgvigor_flash",
			Desat = false,
		},
		Overlay = {
			X = .2,
			Y = .2,
		},
	},
	[6] = { -- default but desaturated
		key = "Default_Desaturated",
		name = L["ThemeDefault_Desaturated"],
		Full = {
			Atlas = "dragonriding_vigor_fillfull",
			Desat = true,
		},
		Fill = {
			Atlas = "dragonriding_vigor_fill",
			Desat = true,
		},
		Progress = {
			Atlas = "dragonriding_vigor_fill_flipbook",
			Desat = true,
			Flipbook = {
				Duration = 1.0,
				Rows = 5,
				Columns = 4,
				Frames = 20,
			},
		},
		Background = { -- bar.bg
			Atlas = "dragonriding_vigor_background",
			Desat = true,
		},
		Spark = {
			Atlas = "dragonriding_vigor_spark",
			Desat = true,
		},
		Mask = {
			Atlas = "dragonriding_vigor_mask",
		},
		Cover = {
			Atlas = "dragonriding_vigor_frame",
			Desat = true,
		},
		Flash = {
			Atlas = "dragonriding_vigor_flash",
			Desat = true,
		},
		Overlay = {
			X = .4,
			Y = .4,
		},
	},
	[7] = { -- Algari but desaturated
		key = "Algari_Desaturated",
		name = L["ThemeAlgari_Desaturated"],
		Full = {
			Atlas = "dragonriding_sgvigor_fillfull",
			Desat = true,
		},
		Fill = {
			Atlas = "dragonriding_sgvigor_fillfull",
			Desat = true, -- texture doesn't exist so just use a desat version
		},
		Progress = {
			Atlas = "dragonriding_sgvigor_fill_flipbook",
			Desat = true,
			Flipbook = {
				Duration = 1.0,
				Rows = 5,
				Columns = 4,
				Frames = 20,
			},
		},
		Background = { -- bar.bg
			Atlas = "dragonriding_sgvigor_background",
			Desat = true,
		},
		Spark = {
			Atlas = "dragonriding_sgvigor_spark",
			Desat = true,
		},
		Mask = {
			Atlas = "dragonriding_sgvigor_mask",
		},
		Cover = {
			Atlas = "dragonriding_sgvigor_frame_silver",
			Desat = true,
		},
		Flash = {
			Atlas = "dragonriding_sgvigor_flash",
			Desat = true,
		},
		Overlay = {
			X = .2,
			Y = .2,
		},
	},
	[8] = { -- Minimalist
		key = "Minimalist",
		name = L["Minimalist"],
		Full = {
			Texture = "Interface\\buttons\\white8x8",
			Desat = false,
		},
		Fill = {
			Texture = "Interface\\buttons\\white8x8",
			Desat = false,
		},
		Progress = {
			Texture = "Interface\\buttons\\white8x8",
			Desat = false,
			Flipbook = nil,
		},
		Background = {
			Texture = "Interface\\buttons\\white8x8",
			Desat = false,
		},
		Spark = {
			Texture = "Interface\\buttons\\white8x8",
			Desat = false,
		},
		Mask = {
			Texture = "Interface\\buttons\\white8x8",
		},
		Cover = {
			Atlas = nil,
			Texture = nil,
			Desat = false,
		},
		Flash = {
			Texture = "Interface\\buttons\\white8x8",
			Desat = false,
		},
		Overlay = {
			X = 0,
			Y = 0,
		},
	},
};

local DecorOptions = {
	[1] = {
		Atlas = "dragonriding_vigor_decor",
		Desat = false,
	},
	[2] = {
		Atlas = "dragonriding_sgvigor_decor_bronze",
		Desat = false,
	},
	[3] = {
		Atlas = "dragonriding_sgvigor_decor_dark",
		Desat = false,
	},
	[4] = {
		Atlas = "dragonriding_sgvigor_decor_gold",
		Desat = false,
	},
	[5] = {
		Atlas = "dragonriding_sgvigor_decor_silver",
		Desat = false,
	},
	[6] = {
		Atlas = "dragonriding_vigor_decor",
		Desat = true,
	},
	[7] = {
		Atlas = "dragonriding_sgvigor_decor_silver",
		Desat = true,
	},
	[8] = {
		Atlas = "UI-HUD-ActionBar-Gryphon-Right",
		Desat = true,
	},
	[9] = {
		Atlas = "UI-HUD-ActionBar-Wyvern-Right",
		Desat = true,
	},
	[10] = {
		Atlas = "nameplates-icon-elite-silver",
		Desat = true,
	},
};

function DR.RegisterVigorTheme(themeKey, themeName, themeData)
	if type(themeData) ~= "table" then return end
	
	for _, theme in ipairs(DR.VigorOptions) do
		if theme.key == themeKey then
			return
		end
	end

	themeData.key = themeKey
	themeData.name = themeName

	table.insert(DR.VigorOptions, themeData)
end

local VigorOptions = DR.VigorOptions


local vigorBar = CreateFrame("Frame", "DragonRider_Vigor", UIParent)
vigorBar:SetPoint("CENTER", BAR_X, BAR_Y)
vigorBar.bars = {};
DR.vigorBar = vigorBar;
vigorBar:Hide();

local function CreateChargeBar(parent, index)
	local bar = CreateFrame("Frame", "DRVigorBubble_"..index, parent)
	bar:SetSize(BAR_WIDTH, BAR_HEIGHT)

	local borderPixel = "Interface\\buttons\\white8x8"
	local borderThickness = 1
	
	bar.borderTop = bar:CreateTexture(nil, "OVERLAY", nil, 5)
	bar.borderTop:SetTexture(borderPixel)
	PixelUtil.SetPoint(bar.borderTop, "TOPLEFT", bar, "TOPLEFT", 0, 0)
	PixelUtil.SetPoint(bar.borderTop, "TOPRIGHT", bar, "TOPRIGHT", 0, 0)
	bar.borderTop:SetHeight(borderThickness)
	bar.borderTop:SetVertexColor(VigorColors.cover:GetRGBA())
	bar.borderTop:SetTexelSnappingBias(0)
	bar.borderTop:SetSnapToPixelGrid(false)
	bar.borderTop:Hide()

	bar.borderBottom = bar:CreateTexture(nil, "OVERLAY", nil, 5)
	bar.borderBottom:SetTexture(borderPixel)
	PixelUtil.SetPoint(bar.borderBottom, "BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
	PixelUtil.SetPoint(bar.borderBottom, "BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
	bar.borderBottom:SetHeight(borderThickness)
	bar.borderBottom:SetVertexColor(VigorColors.cover:GetRGBA())
	bar.borderBottom:SetTexelSnappingBias(0)
	bar.borderBottom:SetSnapToPixelGrid(false)
	bar.borderBottom:Hide()

	bar.borderLeft = bar:CreateTexture(nil, "OVERLAY", nil, 5)
	bar.borderLeft:SetTexture(borderPixel)
	-- Anchor inside the top/bottom borders to avoid corner overlap
	PixelUtil.SetPoint(bar.borderLeft, "TOPLEFT", bar, "TOPLEFT", 0, -borderThickness) 
	PixelUtil.SetPoint(bar.borderLeft, "BOTTOMLEFT", bar, "BOTTOMLEFT", 0, borderThickness)
	bar.borderLeft:SetWidth(borderThickness)
	bar.borderLeft:SetVertexColor(VigorColors.cover:GetRGBA())
	bar.borderLeft:SetTexelSnappingBias(0)
	bar.borderLeft:SetSnapToPixelGrid(false)
	bar.borderLeft:Hide()

	bar.borderRight = bar:CreateTexture(nil, "OVERLAY", nil, 5)
	bar.borderRight:SetTexture(borderPixel)
	-- Anchor inside the top/bottom borders to avoid corner overlap
	PixelUtil.SetPoint(bar.borderRight, "TOPRIGHT", bar, "TOPRIGHT", 0, -borderThickness)
	PixelUtil.SetPoint(bar.borderRight, "BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, borderThickness)
	bar.borderRight:SetWidth(borderThickness)
	bar.borderRight:SetVertexColor(VigorColors.cover:GetRGBA())
	bar.borderRight:SetTexelSnappingBias(0)
	bar.borderRight:SetSnapToPixelGrid(false)
	bar.borderRight:Hide()

	local themeOptions = VigorOptions[1]

	-- background frame
	bar.bg = bar:CreateTexture(nil, "BACKGROUND", nil, 0)
	if themeOptions.Background.Atlas then
		bar.bg:SetAtlas(themeOptions.Background.Atlas)
	elseif themeOptions.Background.Texture then
		bar.bg:SetTexture(themeOptions.Background.Texture)
	end
	bar.bg:ClearAllPoints()
	bar.bg:SetAllPoints(bar)
	bar.bg:SetDrawLayer("BACKGROUND", 0)
	bar.bg:SetDesaturated(themeOptions.Background.Desat or false)

	-- empty fill texture
	bar.emptyFill = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	if themeOptions.Fill.Atlas then
		bar.emptyFill:SetAtlas(themeOptions.Fill.Atlas)
	elseif themeOptions.Fill.Texture then
		bar.emptyFill:SetTexture(themeOptions.Fill.Texture)
	end
	bar.emptyFill:SetAllPoints(bar)
	bar.emptyFill:SetDesaturated(themeOptions.Fill.Desat or true)
	bar.emptyFill:SetVertexColor(VigorColors.full:GetRGBA())

	-- full fill texture
	bar.fullFill = bar:CreateTexture(nil, "ARTWORK", nil, 1)
	if themeOptions.Full.Atlas then
		bar.fullFill:SetAtlas(themeOptions.Full.Atlas)
	elseif themeOptions.Full.Texture then
		bar.fullFill:SetTexture(themeOptions.Full.Texture)
	end
	bar.fullFill:SetAllPoints(bar)
	bar.fullFill:SetDesaturated(themeOptions.Full.Desat or false)
	bar.fullFill:SetVertexColor(VigorColors.full:GetRGBA())
	bar.fullFill:Hide() -- Hide by default

	-- mask for linear fill
	bar.clippingFrame = CreateFrame("Frame", nil, bar)
	bar.clippingFrame:SetClipsChildren(true)
	bar.clippingFrame:Hide()

	-- animated fill texture, placed inside the clipping mask frame
	bar.animFill = bar.clippingFrame:CreateTexture(nil, "ARTWORK", nil, 1)
	if themeOptions.Progress.Atlas then
		bar.animFill:SetAtlas(themeOptions.Progress.Atlas)
	elseif themeOptions.Progress.Texture then
		bar.animFill:SetTexture(themeOptions.Progress.Texture)
	end
	bar.animFill:SetSize(BAR_WIDTH, BAR_HEIGHT)
	bar.animFillKey = "animFill" -- key for the animation group

	bar.fillOrientation = (DragonRider_DB and DragonRider_DB.vigorBarFillDirection) or BAR_FILL_ORIENTATION
	bar.fillDirection = FILL_DIRECTION

	function bar:UpdateFillAnchors()
		bar.clippingFrame:ClearAllPoints()
		bar.animFill:ClearAllPoints()
		if bar.spark then
			bar.spark:SetRotation(0) -- Reset rotation
		end

		local currentWidth, currentHeight = bar:GetSize()

		if bar.fillOrientation == 1 then -- vertical
			bar.clippingFrame:SetWidth(currentWidth)
			bar.clippingFrame:SetHeight(0)
			if bar.fillDirection == 1 then -- bottom-to-top
				bar.clippingFrame:SetPoint("BOTTOMLEFT", bar)
				bar.clippingFrame:SetPoint("BOTTOMRIGHT", bar)
				bar.animFill:SetPoint("BOTTOM", bar.clippingFrame, "BOTTOM")
			else -- top-to-bottom
				bar.clippingFrame:SetPoint("TOPLEFT", bar)
				bar.clippingFrame:SetPoint("TOPRIGHT", bar)
				bar.animFill:SetPoint("TOP", bar.clippingFrame, "TOP")
			end
		elseif bar.fillOrientation == 2 then -- horizontal
			bar.clippingFrame:SetWidth(0)
			bar.clippingFrame:SetHeight(currentHeight)
			if bar.fillDirection == 1 then -- left-to-right
				bar.clippingFrame:SetPoint("TOPLEFT", bar)
				bar.clippingFrame:SetPoint("BOTTOMLEFT", bar)
				bar.animFill:SetPoint("LEFT", bar.clippingFrame, "LEFT")
			else -- right-to-left
				bar.clippingFrame:SetPoint("TOPRIGHT", bar)
				bar.clippingFrame:SetPoint("BOTTOMRIGHT", bar)
				bar.animFill:SetPoint("RIGHT", bar.clippingFrame, "RIGHT")
			end
		end
		
		bar.animFill:SetSize(currentWidth, currentHeight)
	end

	bar:UpdateFillAnchors()

	local animGroup = bar:CreateAnimationGroup()
	animGroup:SetLooping("REPEAT")
	bar.animGroup = animGroup

	-- animation for the fill texture
	if themeOptions.Progress.Flipbook then
		local flipAnim = animGroup:CreateAnimation("FlipBook")
		bar.flipAnim = flipAnim
		flipAnim:SetChildKey(bar.animFillKey)
		local flipbookOptions = themeOptions.Progress.Flipbook
		flipAnim:SetDuration(flipbookOptions.Duration)
		flipAnim:SetOrder(1)
		flipAnim:SetFlipBookRows(flipbookOptions.Rows)
		flipAnim:SetFlipBookColumns(flipbookOptions.Columns)
		flipAnim:SetFlipBookFrames(flipbookOptions.Frames)
	else
		-- For minimalist, just show static progress
		bar.flipAnim = nil
	end

	animGroup:SetScript("OnPlay", function()
		bar.clippingFrame:Show()
	end)
	animGroup:SetScript("OnStop", function()
		bar.clippingFrame:Hide()
	end)

	-- cover
	bar.overlayFrame = CreateFrame("Frame", nil, bar)
	local overlayOptions = themeOptions.Overlay
	bar.overlayFrame:SetPoint("TOPLEFT", bar, "TOPLEFT", -bar:GetWidth()*overlayOptions.X, bar:GetHeight()*overlayOptions.Y)
	bar.overlayFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", bar:GetWidth()*overlayOptions.X, -bar:GetHeight()*overlayOptions.Y)
	-- ensure cover is above the clipping frame
	bar.overlayFrame:SetFrameLevel(bar.clippingFrame:GetFrameLevel() + 10)
	bar.cover = bar.overlayFrame:CreateTexture(nil, "OVERLAY", nil, 3)
	bar.cover:SetAtlas(themeOptions.Cover.Atlas)
	bar.cover:SetAllPoints()
	bar.cover:SetDesaturated(themeOptions.Cover.Desat or true)
	bar.cover:SetVertexColor(VigorColors.cover:GetRGBA())

	-- spark clipping frame (masking)
	-- this frame will contain the spark and be masked by the bubble shape.
	bar.sparkClippingFrame = CreateFrame("Frame", nil, bar)
	bar.sparkClippingFrame:SetPoint("TOPLEFT", bar, "TOPLEFT", -bar:GetWidth()*overlayOptions.X, bar:GetHeight()*overlayOptions.Y)
	bar.sparkClippingFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", bar:GetWidth()*overlayOptions.X, -bar:GetHeight()*overlayOptions.Y)
	bar.sparkClippingFrame:SetFrameLevel(bar.clippingFrame:GetFrameLevel() + 5)
	bar.sparkMask = bar.sparkClippingFrame:CreateMaskTexture(nil, "ARTWORK")
	bar.sparkMask:SetAtlas(themeOptions.Mask.Atlas)
	bar.sparkMask:SetAllPoints(bar.sparkClippingFrame)
	bar.spark = bar.sparkClippingFrame:CreateTexture(nil, "OVERLAY", nil, 2)
	bar.spark:SetAtlas(themeOptions.Spark.Atlas)
	bar.spark:SetDesaturated(themeOptions.Spark.Desat or false)
	bar.spark:SetSize(SPARK_WIDTH, SPARK_HEIGHT)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetVertexColor(VigorColors.spark:GetRGBA())
	bar.spark:AddMaskTexture(bar.sparkMask)

	-- flash texture
	bar.flash = bar.overlayFrame:CreateTexture(nil, "OVERLAY", nil, 4)
	bar.flash:SetAtlas(themeOptions.Flash.Atlas)
	bar.flash:SetDesaturated(themeOptions.Flash.Desat or false)
	bar.flash:SetAllPoints()
	bar.flash:SetVertexColor(VigorColors.flash:GetRGBA())
	bar.flash:Hide()

	-- animation group for the "full" flash (one-shot fade out)
	bar.flashAnimFull = bar:CreateAnimationGroup()
	local flashFullAnim = bar.flashAnimFull:CreateAnimation("Alpha")
	flashFullAnim:SetChildKey("flash")
	flashFullAnim:SetFromAlpha(1.0)
	flashFullAnim:SetToAlpha(0)
	flashFullAnim:SetDuration(0.5)
	flashFullAnim:SetOrder(1)
	
	bar.flashAnimFull:SetScript("OnPlay", function()
		bar.flash:Show();
		if not DragonRider_DB.muteVigorSound then
			PlaySound(201528, "SFX") -- "bling" sound upon full vigor bar
		end
	end)
	bar.flashAnimFull:SetScript("OnFinished", function() bar.flash:Hide() end)
	
	-- animation group for the "progress" flash (looping pulse)
	bar.flashAnimProgress = bar:CreateAnimationGroup()
	bar.flashAnimProgress:SetLooping("REPEAT")
	
	local flashProgAnimIn = bar.flashAnimProgress:CreateAnimation("Alpha")
	flashProgAnimIn:SetChildKey("flash")
	flashProgAnimIn:SetFromAlpha(0.2)
	flashProgAnimIn:SetToAlpha(0.8)
	flashProgAnimIn:SetDuration(0.7)
	flashProgAnimIn:SetOrder(1)
	
	local flashProgAnimOut = bar.flashAnimProgress:CreateAnimation("Alpha")
	flashProgAnimOut:SetChildKey("flash")
	flashProgAnimOut:SetFromAlpha(0.8)
	flashProgAnimOut:SetToAlpha(0.2)
	flashProgAnimOut:SetDuration(0.7)
	flashProgAnimOut:SetOrder(2)
	
	bar.flashAnimProgress:SetScript("OnPlay", function() bar.flash:Show() end)
	bar.flashAnimProgress:SetScript("OnStop", function() bar.flash:Hide() end)

	-- progress control
	function bar:SetProgress(percent)
		percent = math.max(0, math.min(percent, 1))
		bar.progress = percent

		local currentWidth, currentHeight = bar:GetSize()

		if bar.fillOrientation == 1 then -- Vertical
			local fillHeight = currentHeight * percent
			bar.clippingFrame:SetHeight(fillHeight)
			-- position the spark at the top edge of the fill
			bar.spark:ClearAllPoints()
			local yOffset = (bar.fillDirection == 1 and 1 or -1) * fillHeight
			local anchorPoint = (bar.fillDirection == 1 and "BOTTOM" or "TOP")
			bar.spark:SetPoint("CENTER", bar, anchorPoint, 0, yOffset)

		elseif bar.fillOrientation == 2 then -- Horizontal
			local fillWidth = currentWidth * percent
			bar.clippingFrame:SetWidth(fillWidth)
			-- position the spark at the leading edge of the fill
			bar.spark:ClearAllPoints()
			local xOffset = (bar.fillDirection == 1 and 1 or -1) * fillWidth
			local anchorPoint = (bar.fillDirection == 1 and "LEFT" or "RIGHT")
			bar.spark:SetPoint("CENTER", bar, anchorPoint, xOffset, 0)
			bar.spark:SetRotation(math.rad(90))
		end

		-- show spark only when filling, not when full or empty
		if percent > 0.01 and percent < 0.99 then
			bar.spark:Show()
		else
			bar.spark:Hide()
		end

		--bar:SetAlpha(0.6 + 0.4 * percent)
	end

	-- initialize
	bar:SetProgress(0)
	bar.isFull = false
	return bar
end

-- calculates the layout based on settings
function DR.UpdateVigorLayout()
	local vigorWrap
	local orientation
	local bar_width
	local bar_height
	local bar_spacing
	local direction
	if DragonRider_DB then
		vigorWrap = (DragonRider_DB.vigorWrap and DragonRider_DB.vigorWrap > 0 and DragonRider_DB.vigorWrap) or VIGOR_WRAP
		orientation = (DragonRider_DB.vigorBarOrientation) or ORIENTATION
		bar_width = (DragonRider_DB.vigorBarWidth) or BAR_WIDTH
		bar_height = (DragonRider_DB.vigorBarHeight) or BAR_HEIGHT
		bar_spacing = (DragonRider_DB.vigorBarSpacing) or BAR_SPACING
		direction = (DragonRider_DB.vigorBarDirection) or DIRECTION
	else
		vigorWrap = VIGOR_WRAP
		orientation = ORIENTATION
		bar_width = BAR_WIDTH
		bar_height = BAR_HEIGHT
		bar_spacing = BAR_SPACING
		direction = DIRECTION
	end

	local wrap = math.min(vigorWrap, MAX_CHARGES)
	if wrap <= 0 then wrap = MAX_CHARGES end

	if orientation == 1 then -- Vertical layout
		local numCols = math.ceil(MAX_CHARGES / wrap)
		local numRowsOnLongestCol = wrap

		local totalWidth = (numCols * bar_width) + (math.max(0, numCols - 1) * bar_spacing)
		local totalHeight = (numRowsOnLongestCol * bar_height) + (math.max(0, numRowsOnLongestCol - 1) * bar_spacing)
		vigorBar:SetSize(totalWidth, totalHeight)

		for i, bar in ipairs(vigorBar.bars) do
			bar:SetSize(bar_width, bar_height)
			bar:UpdateFillAnchors()
			
			-- Removed overlay/spark frame positioning, will be handled by UpdateVigorTheme

			bar:ClearAllPoints()
			local col = math.floor((i - 1) / wrap)
			local row = (i - 1) % wrap

			-- calculate how many bars are in this column to center it vertically
			local numBarsInThisCol = (col < numCols - 1) and wrap or (MAX_CHARGES - (col * wrap))
			local colHeight = (numBarsInThisCol * bar_height) + (math.max(0, numBarsInThisCol - 1) * bar_spacing)
			local yOffset = (totalHeight - colHeight) / 2

			if direction == 1 then -- left-to-right columns, top-to-bottom bars
				local x = col * (bar_width + bar_spacing)
				local y = -(yOffset + row * (bar_height + bar_spacing))
				bar:SetPoint("TOPLEFT", vigorBar, "TOPLEFT", x, y)
			else -- right-to-left columns, bottom-to-top bars
				local x = -(col * (bar_width + bar_spacing))
				local y = yOffset + row * (bar_height + bar_spacing)
				bar:SetPoint("BOTTOMRIGHT", vigorBar, "BOTTOMRIGHT", x, y)
			end

			if bar.progress then bar:SetProgress(bar.progress) end
		end

	elseif orientation == 2 then -- Horizontal layout
		local numRows = math.ceil(MAX_CHARGES / wrap)
		local numColsOnLongestRow = wrap

		local totalWidth = (numColsOnLongestRow * bar_width) + (math.max(0, numColsOnLongestRow - 1) * bar_spacing)
		local totalHeight = (numRows * bar_height) + (math.max(0, numRows - 1) * bar_spacing)
		vigorBar:SetSize(totalWidth, totalHeight)

		for i, bar in ipairs(vigorBar.bars) do
			bar:SetSize(bar_width, bar_height)
			bar:UpdateFillAnchors()
			
			-- Removed overlay/spark frame positioning, will be handled by UpdateVigorTheme

			bar:ClearAllPoints()
			local row = math.floor((i - 1) / wrap)
			local col = (i - 1) % wrap

			-- calculate how many bars are in this row to center it horizontally
			local numBarsInThisRow = (row < numRows - 1) and wrap or (MAX_CHARGES - (row * wrap))
			local rowWidth = (numBarsInThisRow * bar_width) + (math.max(0, numBarsInThisRow - 1) * bar_spacing)
			local xOffset = (totalWidth - rowWidth) / 2

			if direction == 1 then -- top-to-bottom rows, left-to-right bars
				local x = xOffset + col * (bar_width + bar_spacing)
				local y = -(row * (bar_height + bar_spacing))
				bar:SetPoint("TOPLEFT", vigorBar, "TOPLEFT", x, y)
			else -- bottom-to-top rows, right-to-left bars
				local x = -(xOffset + col * (bar_width + bar_spacing))
				local y = row * (bar_height + bar_spacing)
				bar:SetPoint("BOTTOMRIGHT", vigorBar, "BOTTOMRIGHT", x, y)
			end

			if bar.progress then bar:SetProgress(bar.progress) end
		end
	end
end

local function SetTextureOrAtlas(texture, options)
	if options.Atlas then
		texture:SetTexture(nil)
		texture:SetAtlas(options.Atlas)
	elseif options.Texture then
		texture:SetAtlas(nil)
		texture:SetTexture(options.Texture)
	else
		texture:SetTexture(nil)
		texture:SetAtlas(nil)
	end
end

function DR.UpdateVigorFillDirection()
	local barFillOrientation = (DragonRider_DB and DragonRider_DB.vigorBarFillDirection) or BAR_FILL_ORIENTATION
	local fillDirection = FILL_DIRECTION

	for i, bar in ipairs(vigorBar.bars) do
		if bar then
			bar.fillOrientation = barFillOrientation
			bar.fillDirection = fillDirection
			
			bar:UpdateFillAnchors()
			
			if bar.progress then
				bar:SetProgress(bar.progress)
			end
		end
	end
end

function DR.UpdateVigorTheme()
	local themeIndex = (DragonRider_DB and DragonRider_DB.themeVigor) or 1
	local options = VigorOptions[themeIndex] or VigorOptions[1]
	local isMinimalist = (themeIndex == 8)
	local overlayOptions = options.Overlay or VigorOptions[1].Overlay

	for i, bar in ipairs(vigorBar.bars) do
		if bar then

			if isMinimalist then
				bar.borderTop:Show()
				bar.borderBottom:Show()
				bar.borderLeft:Show()
				bar.borderRight:Show()
			else
				bar.borderTop:Hide()
				bar.borderBottom:Hide()
				bar.borderLeft:Hide()
				bar.borderRight:Hide()
			end

			-- Apply Textures and Desaturation using helper function
			SetTextureOrAtlas(bar.bg, options.Background)
			bar.bg:SetDesaturated(options.Background.Desat or false)
			
			SetTextureOrAtlas(bar.emptyFill, options.Fill)
			bar.emptyFill:SetDesaturated(options.Fill.Desat or false)

			SetTextureOrAtlas(bar.fullFill, options.Full)
			bar.fullFill:SetDesaturated(options.Full.Desat or false)

			SetTextureOrAtlas(bar.animFill, options.Progress)
			bar.animFill:SetDesaturated(options.Progress.Desat or false)

			SetTextureOrAtlas(bar.cover, options.Cover)
			bar.cover:SetDesaturated(options.Cover.Desat or false)

			-- Handle mask (uses Texture or Atlas)
			if options.Mask.Atlas then
				bar.sparkMask:SetAtlas(options.Mask.Atlas)
			elseif options.Mask.Texture then
				bar.sparkMask:SetTexture(options.Mask.Texture)
			end

			SetTextureOrAtlas(bar.spark, options.Spark)
			bar.spark:SetDesaturated(options.Spark.Desat or false)

			SetTextureOrAtlas(bar.flash, options.Flash)
			bar.flash:SetDesaturated(options.Flash.Desat or false)

			-- Update Flipbook Animation (skip for minimalist)
			if options.Progress.Flipbook then
				local flipbookOptions = options.Progress.Flipbook
				if bar.flipAnim then
					bar.flipAnim:SetDuration(flipbookOptions.Duration)
					bar.flipAnim:SetFlipBookRows(flipbookOptions.Rows)
					bar.flipAnim:SetFlipBookColumns(flipbookOptions.Columns)
					bar.flipAnim:SetFlipBookFrames(flipbookOptions.Frames)
				end
			end
			
			-- Update Overlay/Spark Clipping Frame positions
			bar.overlayFrame:ClearAllPoints()
			bar.overlayFrame:SetPoint("TOPLEFT", bar, "TOPLEFT", -bar:GetWidth()*overlayOptions.X, bar:GetHeight()*overlayOptions.Y)
			bar.overlayFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", bar:GetWidth()*overlayOptions.X, -bar:GetHeight()*overlayOptions.Y)
			
			bar.sparkClippingFrame:ClearAllPoints()
			bar.sparkClippingFrame:SetPoint("TOPLEFT", bar, "TOPLEFT", -bar:GetWidth()*overlayOptions.X, bar:GetHeight()*overlayOptions.Y)
			bar.sparkClippingFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", bar:GetWidth()*overlayOptions.X, -bar:GetHeight()*overlayOptions.Y)
		end
	end
end


-- create all the bar objects first
for i = 1, MAX_CHARGES do
	vigorBar.bars[i] = CreateChargeBar(vigorBar, i)
end

DR.UpdateVigorLayout()
DR.UpdateVigorTheme() -- Call after layout to apply the theme
DR.UpdateVigorFillDirection() -- Call after layout and theme to apply fill direction


-- side wings art
vigorBar.decor = {};

local function CreateDecor(parent, index)
	local decor = CreateFrame("Frame", "DragonRider_Decor"..index, parent)
	decor:SetSize(64, 64) -- adjust size as desired
	decor.texture = decor:CreateTexture(nil, "ARTWORK", nil, 1)
	decor.texture:SetAtlas("dragonriding_vigor_decor")
	decor.texture:SetAllPoints(decor)
	decor.texture:SetDesaturated(true)
	decor.texture:SetVertexColor(VigorColors.decor:GetRGBA())

	if index == 1 then
		-- Left side (mirrored)
		decor:SetPoint("RIGHT", parent, "LEFT", -DECOR_X, DECOR_Y)
		decor.texture:SetTexCoord(1, 0, 0, 1) -- horizontal flip
	else
		-- Right side (normal)
		decor:SetPoint("LEFT", parent, "RIGHT", DECOR_X, DECOR_Y)
	end

	parent.decor[index] = decor
	return decor
end

for i = 1, 2 do
	vigorBar.decor[i] = CreateDecor(vigorBar, i);
end

function DR.ToggleDecor()
	local toggleModels = DragonRider_DB and DragonRider_DB.sideArt
	local PosX, PosY = (DragonRider_DB and DragonRider_DB.sideArtPosX) or DECOR_X, (DragonRider_DB and DragonRider_DB.sideArtPosY) or DECOR_Y
	local Size = (DragonRider_DB and DragonRider_DB.sideArtSize) or 1
	local Rot = (DragonRider_DB and DragonRider_DB.sideArtRot) or 0

	if toggleModels then
		for i = 1, 2 do
			vigorBar.decor[i]:Show()
		end
	else
		for i = 1, 2 do
			vigorBar.decor[i]:Hide()
		end
	end

	local themeIndex = (DragonRider_DB and DragonRider_DB.sideArtStyle) or 1
	local options = DecorOptions[themeIndex] or DecorOptions[1]

	for i = 1, 2 do
		local decor = vigorBar.decor[i]
		if decor then
			if options.Atlas then
				decor.texture:SetAtlas(options.Atlas)
			elseif options.Texture then
				decor.texture:SetTexture(options.Texture)
			end
			if options.Desat ~= nil then
				decor.texture:SetDesaturated(options.Desat)
			else
				decor.texture:SetDesaturated(false)
			end
		end

		if i == 1 then
			-- Left side (mirrored)
			decor:SetPoint("RIGHT", vigorBar, "LEFT", -PosX, PosY)
			decor.texture:SetRotation(math.rad(-Rot)) -- apply opposite rotation
		else
			-- Right side (normal)
			decor:SetPoint("LEFT", vigorBar, "RIGHT", PosX, PosY)
			decor.texture:SetRotation(math.rad(Rot))
		end
		decor:SetScale(Size)
	end
end

local function GetRGBA(colorTbl, fallbackTbl)
	local c = (DragonRider_DB and DragonRider_DB.vigorBarColor and colorTbl) or fallbackTbl
	if not c then return 1, 1, 1, 1 end
	return c.r, c.g, c.b, c.a or 1
end

local function UpdateChargeBars()

	local info = C_Spell.GetSpellCharges(SPELL_ID)
	if not info then return end

	local current = info.currentCharges or 0
	if issecretvalue and issecretvalue(current) then
		return
	end
	local max = info.maxCharges or MAX_CHARGES
	local start = info.cooldownStartTime or 0
	local duration = info.cooldownDuration or 0

	local rF, gF, bF, aF = GetRGBA(DragonRider_DB and DragonRider_DB.vigorBarColor and DragonRider_DB.vigorBarColor.full, VigorColors.full)
	local rP, gP, bP, aP = GetRGBA(DragonRider_DB and DragonRider_DB.vigorBarColor and DragonRider_DB.vigorBarColor.progress, VigorColors.progress)
	local rE, gE, bE, aE = GetRGBA(DragonRider_DB and DragonRider_DB.vigorBarColor and DragonRider_DB.vigorBarColor.empty, VigorColors.empty)
	local rBG, gBG, bBG, aBG = GetRGBA(DragonRider_DB and DragonRider_DB.vigorBarColor and DragonRider_DB.vigorBarColor.background, VigorColors.background)
	local rS, gS, bS, aS = GetRGBA(DragonRider_DB and DragonRider_DB.vigorBarColor and DragonRider_DB.vigorBarColor.spark, VigorColors.spark)
	local rC, gC, bC, aC = GetRGBA(DragonRider_DB and DragonRider_DB.vigorBarColor and DragonRider_DB.vigorBarColor.cover, VigorColors.cover)
	local rFl, gFl, bFl, aFl = GetRGBA(DragonRider_DB and DragonRider_DB.vigorBarColor and DragonRider_DB.vigorBarColor.flash, VigorColors.flash)
	local rD, gD, bD, aD = GetRGBA(DragonRider_DB and DragonRider_DB.vigorBarColor and DragonRider_DB.vigorBarColor.decor, VigorColors.decor)

	for i = 1, 2 do
		if vigorBar.decor[i] then vigorBar.decor[i].texture:SetVertexColor(rD, gD, bD, aD) end
	end

	for i = 1, MAX_CHARGES do
		local bar = vigorBar.bars[i]
		if not bar then break end

		bar.bg:SetVertexColor(rBG, gBG, bBG, aBG)
		bar.spark:SetVertexColor(rS, gS, bS, aS)
		bar.cover:SetVertexColor(rC, gC, bC, aC)
		bar.flash:SetVertexColor(rFl, gFl, bFl, aFl)

		if bar.borderTop then
			bar.borderTop:SetVertexColor(rC, gC, bC, aC)
			bar.borderBottom:SetVertexColor(rC, gC, bC, aC)
			bar.borderLeft:SetVertexColor(rC, gC, bC, aC)
			bar.borderRight:SetVertexColor(rC, gC, bC, aC)
		end

		if i <= current then -- fully charged
			bar.fullFill:Show()
			
			if bar.animGroup:IsPlaying() then bar.animGroup:Stop() end
			bar.clippingFrame:Hide()
			
			bar.emptyFill:Hide()
			--bar.fullFill:SetDesaturated(false)
			bar.fullFill:SetVertexColor(rF, gF, bF, aF)
			bar.fullFill:SetAlpha(1) 
			bar:SetProgress(1)

			-- stop progress flash if it was running
			if bar.flashAnimProgress:IsPlaying() then
				bar.flashAnimProgress:Stop()
			end

			-- check if it *just* became full
			if not bar.isFull and DragonRider_DB.toggleFlashFull then
				bar.flashAnimFull:Play()
			end
			bar.isFull = true -- set current state

		elseif i == current + 1 and duration > 0 then -- recharging
			bar.isFull = false -- mark as not full
			bar.fullFill:Hide()
			bar.emptyFill:Hide()
			bar.clippingFrame:Show()
			
			if not bar.animGroup:IsPlaying() then bar.animGroup:Play() end

			local elapsed = GetTime() - start
			local progress = math.max(0.001, math.min(elapsed / duration, 1))
			bar.animFill:SetVertexColor(rP, gP, bP, aP)
			bar:SetProgress(progress)

			-- play progress flash
			if DragonRider_DB.toggleFlashProgress and not bar.flashAnimProgress:IsPlaying() then
				bar.flashAnimProgress:Play()
			end
			
			-- stop full flash if it was somehow running
			if bar.flashAnimFull:IsPlaying() then
				bar.flashAnimFull:Stop()
				bar.flash:Hide()
			end

		else -- empty
			bar.isFull = false -- mark as not full
			bar.emptyFill:Show()
			bar.fullFill:Hide()
			bar.emptyFill:SetDesaturated(true)
			bar.emptyFill:SetVertexColor(rE, gE, bE, aE)
			if bar.animGroup:IsPlaying() then bar.animGroup:Stop() end
			bar.clippingFrame:Hide()
			bar:SetProgress(0)

			-- stop any flashes
			if bar.flashAnimProgress:IsPlaying() then
				bar.flashAnimProgress:Stop()
			end
			if bar.flashAnimFull:IsPlaying() then
				bar.flashAnimFull:Stop()
				bar.flash:Hide()
			end
		end
	end
end

local updateTimer = 0 -- throttle
vigorBar:SetScript("OnUpdate", function(self, elapsed)
	updateTimer = updateTimer + elapsed
	if updateTimer > 0.1 then
		UpdateChargeBars()
		updateTimer = 0
	end
end)



---------------------------------------------------------------------------------------------------------------
-- Models
---------------------------------------------------------------------------------------------------------------

DR.model = {};
DR.modelScene = {};

local ModelOptions = {
	[1] = { -- Wind
		modelFileID = 1100194,
		Pos = {
			X = 5, Y = 0, Z = -1.5,
		},
		Yaw = 0,
		Pitch = 0,
		Anim = 1,
	},
	[2] = { -- Lightning
		modelFileID = 3009394,
		Pos = {
			X = 5, Y = 0, Z = -.5,
		},
		Yaw = 0,
		Pitch = 0,
		Anim = 1,
	},
	[3] = { -- Fire Form
		modelFileID = 166112,
		Pos = {
			X = 2.2, Y = 0, Z = -.65,
		},
		Yaw = 0,
		Pitch = 0,
		Anim = 1,
	},
	[4] = { -- Arcane Form
		modelFileID = 165568,
		Pos = {
			X = 2.2, Y = 0, Z = -.65,
		},
		Yaw = 0,
		Pitch = 0,
		Anim = 1,
	},
	[5] = { -- Frost Form
		modelFileID = 166209,
		Pos = {
			X = 2.2, Y = 0, Z = -.65,
		},
		Yaw = 0,
		Pitch = 0,
		Anim = 1,
	},
	[6] = { -- Holy Form
		modelFileID = 166322,
		Pos = {
			X = 2.2, Y = 0, Z = -.65,
		},
		Yaw = 0,
		Pitch = 0,
		Anim = 1,
	},
	[7] = { -- Nature Form
		modelFileID = 166603,
		Pos = {
			X = 2.2, Y = 0, Z = -.65,
		},
		Yaw = 0,
		Pitch = 0,
		Anim = 1,
	},
	[8] = { -- Shadow Form
		modelFileID = 166792,
		Pos = {
			X = 2.2, Y = 0, Z = -.65,
		},
		Yaw = 0,
		Pitch = 0,
		Anim = 1,
	},


	--[[
	[number] = { -- Water (wasn't very visible, maybe revisit later)
		modelFileID = 791823,
		Pos = {
			X = 3, Y = 0, Z = -.3,
		},
		Yaw = 0,
		Pitch = 1,
		Anim = 1,
	},
	]]
};

function DR.modelSetup()
	local themeIndex = (DragonRider_DB and DragonRider_DB.modelTheme) or 1
	local options = ModelOptions[themeIndex] or ModelOptions[1]

	for i = 1, MAX_CHARGES do
		local model = DR.model[i]
		if model then
			model:SetModelByFileID(options.modelFileID)
			model:SetPosition(options.Pos.X, options.Pos.Y, options.Pos.Z)
			if options.Pitch then
				model:SetPitch(options.Pitch)
			end
			model:SetYaw(options.Yaw or 0) -- rotation?
			if options.Anim then
				model:SetAnimation(options.Anim)
			end
		end
	end
end


for i = 1, MAX_CHARGES do
	DR.modelScene[i] = CreateFrame("ModelScene", nil, vigorBar.bars[i])
	DR.modelScene[i]:SetAllPoints()
	DR.modelScene[i]:SetFrameLevel(vigorBar.bars[i]:GetFrameLevel() + 5)
	DR.modelScene[i]:SetSize(43,43)

	DR.model[i] = DR.modelScene[i]:CreateActor()
end

DR.modelSetup()


function DR.hideModels()
	for i = 1, MAX_CHARGES do
		DR.modelScene[i]:Hide()
	end
end

DR.hideModels()

function DR.vigorCounter()
	local vigorCurrent = LibAdvFlight:GetCurrentVigor()
	local toggleModels = DragonRider_DB and DragonRider_DB.toggleModels
	if not vigorCurrent then
		-- vigorCurrent will be nil during login I think
		return;
	end
	if toggleModels then
		for i = 1, MAX_CHARGES do
			if vigorCurrent >= i then
				DR.modelScene[i]:Show()
			else
				DR.modelScene[i]:Hide()
			end
		end
	else
		DR.hideModels();
	end
end