
local module = {}
local moduleName = "Animations"
MikSBT[moduleName] = module

local MSBTMedia = MikSBT.Media
local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations

local table_remove = table.remove
local string_find = string.find
local string_lower = string.lower

local IsModDisabled = MSBTProfiles.IsModDisabled
local EraseTable = MikSBT.EraseTable

local fonts = MSBTMedia.fonts
local sounds = MSBTMedia.sounds

local MAX_ANIMATIONS_PER_AREA = 15
local DEFAULT_SCROLL_TIME = 3
local DEFAULT_FADE_PERCENT = 0.8

local ANIMATION_DELAY = 0.015

local TEXT_ALIGN_MAP = {"BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}

local OUTLINE_MAP = {"", "OUTLINE", "THICKOUTLINE", "MONOCHROME", "MONOCHROME,OUTLINE", "MONOCHROME,THICKOUTLINE"}

local DEFAULT_FONT_SIZE = 18
local DEFAULT_FONT_PATH = L.FONT_FILES[L.DEFAULT_FONT_NAME]
local DEFAULT_TEXT_ALIGN = TEXT_ALIGN_MAP[2]
local DEFAULT_OUTLINE = OUTLINE_MAP[1]
local DEFAULT_SCROLL_AREA = "Notification"
local DEFAULT_SCROLL_HEIGHT = 260
local DEFAULT_SCROLL_WIDTH = 40
local DEFAULT_ANIMATION_STYLE = "Straight"
local DEFAULT_STICKY_ANIMATION_STYLE = "Pow"

local DEFAULT_SOUND_PATH = "Interface\\AddOns\\MikScrollingBattleText\\Sounds\\"

local TEMP_TEXTURE_PATH = "Interface\\Icons\\Temp"

local _

local animationFrame

local displayEventCache = {}
local textureCache = {}

local animationData = {normal = {}, sticky = {}}

local animationStyles = {}
local stickyAnimationStyles = {}
local scrollAreas = {}

local externalScrollAreas = {}

local fontLoaderFrame
local loadedFontStrings = {}

local function IsScrollAreaActive(scrollArea)
	local saSettings = scrollAreas[scrollArea] or scrollAreas[DEFAULT_SCROLL_AREA]

	if not saSettings or saSettings.disabled then
		return false
	end

	return true
end

local function IsScrollAreaIconShown(scrollArea)
	local saSettings = scrollAreas[scrollArea] or scrollAreas[DEFAULT_SCROLL_AREA]

	return saSettings and not saSettings.skillIconsDisabled or false
end

local function UpdateScrollAreas()

	EraseTable(scrollAreas)
	EraseTable(externalScrollAreas)

	if rawget(MSBTProfiles.currentProfile, "scrollAreas") then
		for saKey, saSettings in pairs(MSBTProfiles.currentProfile.scrollAreas) do
			scrollAreas[saKey] = saSettings
			externalScrollAreas[saKey] = saSettings.name
		end
	end

	for saKey, saSettings in pairs(MSBTProfiles.masterProfile.scrollAreas) do
		if not scrollAreas[saKey] then
			scrollAreas[saKey] = saSettings
			externalScrollAreas[saKey] = saSettings.name
		end
	end
end

local function RegisterAnimationStyle(styleID, initHandler, availableDirections, availableBehaviors, localizationTable)

	if not animationStyles[styleID] and initHandler then

		local animStyleSettings = {}
		animStyleSettings.initHandler = initHandler
		animStyleSettings.availableDirections = availableDirections
		animStyleSettings.availableBehaviors = availableBehaviors
		animStyleSettings.localizationTable = localizationTable

		animationStyles[styleID] = animStyleSettings
	end
end

local function RegisterStickyAnimationStyle(styleID, initHandler, availableDirections, availableBehaviors, localizationTable)

	if not stickyAnimationStyles[styleID] and initHandler then

		local animStyleSettings = {}
		animStyleSettings.initHandler = initHandler
		animStyleSettings.availableDirections = availableDirections
		animStyleSettings.availableBehaviors = availableBehaviors
		animStyleSettings.localizationTable = localizationTable

		stickyAnimationStyles[styleID] = animStyleSettings
	end
end

local function IterateScrollAreas()
	return pairs(externalScrollAreas)
end

local function LoadFont(fontName)
	local fontPath = MikSBT.Media.fonts[fontName]
	if fontPath == nil then
		return
	end

	local fontString = loadedFontStrings[fontName]
	if fontString ~= nil then
		return
	end

	fontLoaderFrame:Show()
	fontString = fontLoaderFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontString:SetPoint("BOTTOM")

	fontString:SetText("Font Loader")
	fontString:SetFont(fontPath, DEFAULT_FONT_SIZE, DEFAULT_FONT_OUTLINE)
	fontString:SetText("")
	fontString:SetAlpha(0)
	loadedFontStrings[fontName] = fontString
	fontLoaderFrame:Hide()
end

local function Display(message, saSettings, isSticky, colorR, colorG, colorB, fontSize, fontPath, outlineIndex, fontAlpha, texturePath)

	local animStyleSettings, direction, behavior, textAlignIndex
	if isSticky then
		animStyleSettings = stickyAnimationStyles[saSettings.stickyAnimationStyle] or stickyAnimationStyles[DEFAULT_STICKY_ANIMATION_STYLE]
		direction = saSettings.stickyDirection
		behavior = saSettings.stickyBehavior
		textAlignIndex = saSettings.stickyTextAlignIndex
	else
		animStyleSettings = animationStyles[saSettings.animationStyle] or animationStyles[DEFAULT_ANIMATION_STYLE]
		direction = saSettings.direction
		behavior = saSettings.behavior
		textAlignIndex = saSettings.textAlignIndex
	end

	if not animStyleSettings then
		return
	end

	if not animationData.normal[saSettings] then
		animationData.normal[saSettings] = {}
	end
	if isSticky and not animationData.sticky[saSettings] then
		animationData.sticky[saSettings] = {}
	end

	local animationArray = isSticky and animationData.sticky[saSettings] or animationData.normal[saSettings]

	local displayEvent
	if #animationArray >= MAX_ANIMATIONS_PER_AREA then
		displayEvent = table_remove(animationArray, 1)
		displayEvent.fontString:SetAlpha(0)
		if displayEvent.texture then
			displayEvent.texture:SetAlpha(0)
		end
	else
		displayEvent = table_remove(displayEventCache) or { fontString = animationFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal") }
	end

	local currentProfile = MSBTProfiles.currentProfile

	displayEvent.offsetX = saSettings.offsetX or 0
	displayEvent.offsetY = saSettings.offsetY or 0
	displayEvent.anchorPoint = TEXT_ALIGN_MAP[textAlignIndex] or DEFAULT_TEXT_ALIGN
	displayEvent.scrollHeight = saSettings.scrollHeight or DEFAULT_SCROLL_HEIGHT
	displayEvent.scrollWidth = saSettings.scrollWidth or DEFAULT_SCROLL_WIDTH
	displayEvent.animationSpeed = (saSettings.animationSpeed or currentProfile.animationSpeed) / 100
	displayEvent.masterAlpha = fontAlpha / 100

	displayEvent.alpha = 1
	displayEvent.positionX = 0
	displayEvent.positionY = 0
	displayEvent.fontSize = fontSize

	local fontString = displayEvent.fontString
	local fontOutline = OUTLINE_MAP[outlineIndex] or DEFAULT_OUTLINE
	if not fontPath then
		fontPath = DEFAULT_FONT_PATH
	end
	fontString:ClearAllPoints()
	if fontPath == DEFAULT_FONT_PATH then
		fontString:SetFont(DEFAULT_FONT_PATH, fontSize, fontOutline)
	end
	fontString:SetFont(fontPath, fontSize, fontOutline)
	fontString:SetTextColor(colorR, colorG, colorB)
	fontString:SetDrawLayer(isSticky and "OVERLAY" or "ARTWORK")
	if not currentProfile.textShadowingDisabled then
		fontString:SetShadowColor(0, 0, 0, 1)
		fontString:SetShadowOffset(1, -1)
	else
		fontString:SetShadowColor(0, 0, 0, 0)
		fontString:SetShadowOffset(0, 0)
	end
	fontString:SetAlpha(0)
	fontString:SetText(message)

	if texturePath and texturePath ~= TEMP_TEXTURE_PATH and not saSettings.skillIconsDisabled and not currentProfile.skillIconsDisabled then

		local texture = displayEvent.texture

		if not texture then
			texture = table_remove(textureCache) or animationFrame:CreateTexture(nil, "ARTWORK")
		end

		texture:ClearAllPoints()
		texture:SetTexture(texturePath)
		texture:SetWidth(fontSize)
		texture:SetHeight(fontSize)
		texture:SetTexCoord(0.125, 0.875, 0.125, 0.875)
		if saSettings.iconAlign == "Right" then
			texture:SetPoint("LEFT", fontString, "RIGHT", 4, 0)
		else
			texture:SetPoint("RIGHT", fontString, "LEFT", -4, 0)
		end
		texture:SetDrawLayer(isSticky and "OVERLAY" or "ARTWORK")
		texture:SetAlpha(0)
		displayEvent.texture = texture
	end

	displayEvent.elapsedTime = 0
	displayEvent.timeSinceLastUpdate = 0
	displayEvent.scrollTime = DEFAULT_SCROLL_TIME
	displayEvent.fadePercent = DEFAULT_FADE_PERCENT

	animStyleSettings.initHandler(displayEvent, animationArray, direction, behavior)
	fontString:SetPoint(displayEvent.anchorPoint, displayEvent.offsetX + displayEvent.positionX, displayEvent.offsetY + displayEvent.positionY)
	displayEvent.scrollTime = displayEvent.scrollTime / displayEvent.animationSpeed

	animationArray[#animationArray + 1] = displayEvent

	if not animationFrame:IsVisible() then
		animationFrame:Show()
	end
end

local function DisplayEvent(eventSettings, message, texturePath)

	local currentProfile = MSBTProfiles.currentProfile

	local saSettings = scrollAreas[eventSettings.scrollArea] or scrollAreas[DEFAULT_SCROLL_AREA]

	if not saSettings or saSettings.disabled then
		return
	end

	local fontSize, fontName, outlineIndex, fontAlpha, isSticky
	if eventSettings.isCrit then
		fontSize = eventSettings.fontSize or saSettings.critFontSize or currentProfile.critFontSize
		fontName = eventSettings.fontName or saSettings.critFontName or currentProfile.critFontName
		outlineIndex = eventSettings.outlineIndex or saSettings.critOutlineIndex or currentProfile.critOutlineIndex
		fontAlpha = eventSettings.fontAlpha or saSettings.critFontAlpha or currentProfile.critFontAlpha

		if not currentProfile.stickyCritsDisabled then
			isSticky = true
		end
	else
		fontSize = eventSettings.fontSize or saSettings.normalFontSize or currentProfile.normalFontSize
		fontName = eventSettings.fontName or saSettings.normalFontName or currentProfile.normalFontName
		outlineIndex = eventSettings.outlineIndex or saSettings.normalOutlineIndex or currentProfile.normalOutlineIndex
		fontAlpha = eventSettings.fontAlpha or saSettings.normalFontAlpha or currentProfile.normalFontAlpha
	end

	isSticky = isSticky or eventSettings.alwaysSticky

	local soundFile = eventSettings.soundFile
	if soundFile and not currentProfile.soundsDisabled then
		for soundName, soundPath in MikSBT.IterateSounds() do
			if soundName == soundFile then
				soundFile = soundPath
			end
		end

		if type(soundFile) == "string" then
			if soundFile ~= "" then
				local soundFileLower = string.lower(soundFile)

				if soundFile ~= "" and not string.find(soundFile, "\\", nil, 1) and not string.find(soundFile, "/", nil, 1) then
					soundFile = DEFAULT_SOUND_PATH .. soundFile

				elseif (string.find(soundFileLower, "interface", nil, 1) or 0) ~= 1 then
					return
				end
				PlaySoundFile(soundFile, "Master")
			end
		else
			PlaySoundFile(soundFile, "Master")
		end
	end

	Display(message, saSettings, isSticky, eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1, fontSize, fonts[fontName], outlineIndex, fontAlpha, texturePath)
end

local function DisplayMessage(message, scrollArea, isSticky, colorR, colorG, colorB, fontSize, fontName, outlineIndex, texturePath)

	if not message or IsModDisabled() then
		return
	end

	local saSettings = scrollAreas[scrollArea]
	if not saSettings then

		for _, settings in pairs(scrollAreas) do
			if scrollArea == settings.name then
				saSettings = settings
			end
		end
	end

	saSettings = saSettings or scrollAreas[DEFAULT_SCROLL_AREA]

	if not saSettings or saSettings.disabled then
		return
	end

	if colorR == nil or colorR < 0 or colorR > 255 then
		colorR = 255
	end
	if colorG == nil or colorG < 0 or colorG > 255 then
		colorG = 255
	end
	if colorB == nil or colorB < 0 or colorB > 255 then
		colorB = 255
	end

	local currentProfile = MSBTProfiles.currentProfile

	if fontSize == nil or fontSize < 4 or fontSize > 38 then
		fontSize = saSettings.normalFontSize or currentProfile.normalFontSize
	end

	local fontPath = fonts[fontName] or fonts[saSettings.normalFontName or currentProfile.normalFontName]

	if not OUTLINE_MAP[outlineIndex] then
		outlineIndex = saSettings.normalOutlineIndex or currentProfile.normalOutlineIndex
	end

	local fontAlpha = saSettings.normalFontAlpha or currentProfile.normalFontAlpha

	Display(message, saSettings, isSticky, colorR / 255, colorG / 255, colorB / 255, fontSize, fontPath, outlineIndex, fontAlpha, texturePath)
end

local function AnimateEvent(displayEvent)
	local fontString = displayEvent.fontString
	local texture = displayEvent.texture
	local percentDone = displayEvent.elapsedTime / displayEvent.scrollTime

	if percentDone <= 1 then

		displayEvent.animationHandler(displayEvent, percentDone)

		local fadePercent = displayEvent.fadePercent
		if percentDone >= fadePercent then
			displayEvent.alpha = (1 - percentDone) / (1 - fadePercent)
		end

		fontString:SetPoint(displayEvent.anchorPoint, displayEvent.offsetX + displayEvent.positionX, displayEvent.offsetY + displayEvent.positionY)
		fontString:SetAlpha(displayEvent.masterAlpha * displayEvent.alpha)
		if texture then
			texture:SetAlpha(displayEvent.masterAlpha * displayEvent.alpha)
		end
	else

		fontString:SetAlpha(0)
		if texture then
			texture:SetAlpha(0)
		end
		displayEvent.animationComplete = true
	end
end

local function OnUpdateAnimationFrame(this, elapsed)

	local allInactive = true

	local numEvents, displayEvent, texture

	for _, animationArray in pairs(animationData) do

		for _, displayEvents in pairs(animationArray) do
			numEvents = #displayEvents

			for i = 1, numEvents do
				displayEvent = displayEvents[i]
				displayEvent.timeSinceLastUpdate = displayEvent.timeSinceLastUpdate + elapsed

				if displayEvent.timeSinceLastUpdate >= ANIMATION_DELAY then
					displayEvent.elapsedTime = displayEvent.elapsedTime + displayEvent.timeSinceLastUpdate
					AnimateEvent(displayEvent)
					displayEvent.timeSinceLastUpdate = 0
				end

				allInactive = false
			end

			for i = numEvents, 1, -1 do
				displayEvent = displayEvents[i]
				if displayEvent.animationComplete then
					table_remove(displayEvents, i)

					texture = displayEvent.texture
					if texture then
						textureCache[#textureCache + 1] = texture
						texture:SetTexture(nil)
						displayEvent.texture = nil
					end

					displayEventCache[#displayEventCache + 1] = displayEvent
					displayEvent.animationComplete = false
				end
			end
		end
	end

	if allInactive then
		this:Hide()
	end
end

animationFrame = CreateFrame("Frame", "MSBTAnimationFrame", UIParent)
animationFrame:SetFrameStrata("HIGH")
animationFrame:SetPoint("BOTTOM", UIParent, "CENTER")
animationFrame:SetWidth(0.0001)
animationFrame:SetHeight(0.0001)
animationFrame:Hide()
animationFrame:SetScript("OnUpdate", OnUpdateAnimationFrame)

fontLoaderFrame = CreateFrame("Frame", nil, UIParent)
fontLoaderFrame:SetPoint("BOTTOM")
fontLoaderFrame:SetWidth(0.0001)
fontLoaderFrame:SetHeight(0.0001)
fontLoaderFrame:Hide()

module.scrollAreas					= scrollAreas
module.animationStyles				= animationStyles
module.stickyAnimationStyles		= stickyAnimationStyles

module.IsScrollAreaActive			= IsScrollAreaActive
module.IsScrollAreaIconShown		= IsScrollAreaIconShown
module.UpdateScrollAreas			= UpdateScrollAreas
module.RegisterAnimationStyle		= RegisterAnimationStyle
module.RegisterStickyAnimationStyle = RegisterStickyAnimationStyle
module.IterateScrollAreas			= IterateScrollAreas
module.LoadFont						= LoadFont
module.DisplayMessage				= DisplayMessage
module.DisplayEvent					= DisplayEvent

