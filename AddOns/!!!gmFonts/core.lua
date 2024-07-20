-- it was a small addon for adding my preferred fonts in LibSharedMedia
-- now is also an addon to change your UI default fonts.

-- the most important parts of the code (and probably the well written ones :) is taken by "tekticles" http://www.wowinterface.com/downloads/info8786-tekticles.html
-- also the defaults fonts typo and size are taken by "tekticles"
-- by Tekkub: http://www.tekkub.net/addons


local ADDON = ...

local size={}
local prgname = "|cffffd200"..ADDON.."|r"
local string_format = string.format

local BUTTON_HEIGHT = 40
local BUTTON_WIDTH = 150

local lsmfontsmenu
local gmfontsmenu

-- saved variables
GMFONTS = GMFONTS or {}

-- setup shared media
local LSM = LibStub and LibStub:GetLibrary("LibSharedMedia-3.0", true)
local PCD = LibStub("PhanxConfig-Dropdown")
-- local fontpath = "Interface\\Addons\\"..ADDON.."\\fonts\\"

-- function taken by PhanxFont, by Phanx
local function SetFont(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	
	if not obj then return end -- TODO: prune things that don't exist anymore
	
	size = size + GMFONTS["delta"]
	obj:SetFont(font, size, style)
	
	if sr and sg and sb then
		obj:SetShadowColor(sr, sg, sb)
	end
	
	if sox and soy then
		obj:SetShadowOffset(sox, soy)
	end
	
	if r and g and b then
		obj:SetTextColor(r, g, b)
	elseif r then
		obj:SetAlpha(r)
	end
end

local function UpdateFonts()

	-- to be used in future
	size = {sm = 9, me = 11, la = 15, hu = 17, gi = 25, zn = 100, zs = 20, zp = 30}
	
	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 14
	-- CHAT_FONT_HEIGHTS = {7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24}

	UNIT_NAME_FONT     = GMFONTS["N"]
	DAMAGE_TEXT_FONT   = GMFONTS["NR"]
	STANDARD_TEXT_FONT = GMFONTS["N"]
	NAMEPLATE_FONT     = GMFONTS["B"]

	-- Base fonts
	SetFont(_G.AchievementFont_Small,              	GMFONTS["B"], 13, "")
	SetFont(_G.FriendsFont_Large,                  	GMFONTS["N"], 15, "", nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(_G.FriendsFont_Normal,                 	GMFONTS["N"], 13, "", nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(_G.FriendsFont_Small,                  	GMFONTS["N"], 13, "", nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(_G.FriendsFont_UserText,               	GMFONTS["NR"], 13, "", nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(_G.GameTooltipHeader,                  	GMFONTS["B"], 15, "")
	SetFont(_G.GameFont_Gigantic,                  	GMFONTS["B"], 32, "", nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(_G.GameNormalNumberFont,               	GMFONTS["B"], 11, "")
	SetFont(_G.InvoiceFont_Med,                    	GMFONTS["I"], 15, "", 0.15, 0.09, 0.04)
	SetFont(_G.InvoiceFont_Small,                  	GMFONTS["I"], 13, "", 0.15, 0.09, 0.04)
	SetFont(_G.MailFont_Large,                     	GMFONTS["I"], 16, "", 0.15, 0.09, 0.04, 0.54, 0.4, 0.1, 1, -1)
	SetFont(_G.NumberFontNormal, 					GMFONTS["N"], 9, "THICKOUTLINE")
	SetFont(_G.NumberFont_OutlineThick_Mono_Small, 	GMFONTS["NR"], 11, "THICKOUTLINE")
	SetFont(_G.NumberFont_Outline_Huge,            	GMFONTS["NR"], 30, "THICKOUTLINE", 0.30)
	SetFont(_G.NumberFont_Outline_Large,           	GMFONTS["NR"], 17, "OUTLINE")
	SetFont(_G.NumberFont_Outline_Med,             	GMFONTS["NR"], 15, "OUTLINE")
	SetFont(_G.NumberFont_Shadow_Med,              	GMFONTS["N"], 14, "")
	SetFont(_G.NumberFont_Shadow_Small,            	GMFONTS["N"], 11, "")
	SetFont(_G.QuestFont_Shadow_Small,             	GMFONTS["N"], 16, "")
	SetFont(_G.QuestFont_Large,                    	GMFONTS["N"], 16, "")
	SetFont(_G.QuestFont_Shadow_Huge,              	GMFONTS["B"], 19, "", nil, nil, nil, 0.54, 0.4, 0.1)
	SetFont(_G.QuestFont_Super_Huge,               	GMFONTS["B"], 24, "")
	SetFont(_G.ReputationDetailFont,               	GMFONTS["B"], 13, "", nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(_G.SpellFont_Small,                    	GMFONTS["B"], 13, "")
	SetFont(_G.SystemFont_InverseShadow_Small,     	GMFONTS["B"], 13, "")
	SetFont(_G.SystemFont_Large,                   	GMFONTS["N"], 17, "")
	SetFont(_G.SystemFont_Med1,                    	GMFONTS["N"], 13, "")
	SetFont(_G.SystemFont_Med2,                    	GMFONTS["I"], 14, "", 0.15, 0.09, 0.04)
	SetFont(_G.SystemFont_Med3,                    	GMFONTS["N"], 15, "")
	SetFont(_G.SystemFont_OutlineThick_Huge2,      	GMFONTS["N"], 22, "THICKOUTLINE")
	SetFont(_G.SystemFont_OutlineThick_Huge4,      	GMFONTS["BI"], 27, "THICKOUTLINE")
	SetFont(_G.SystemFont_OutlineThick_WTF,    	   	GMFONTS["BI"], 31, "THICKOUTLINE", nil, nil, nil, 0, 0, 0, 1, -1)
	SetFont(_G.SystemFont_Outline_Small,           	GMFONTS["NR"], 13, "OUTLINE")
	SetFont(_G.SystemFont_Shadow_Huge1,            	GMFONTS["B"], 20, "")
	SetFont(_G.SystemFont_Shadow_Huge3,            	GMFONTS["B"], 25, "")
	SetFont(_G.SystemFont_Shadow_Large,            	GMFONTS["N"], 17, "")
	SetFont(_G.SystemFont_Shadow_Med1,             	GMFONTS["N"], 13, "")
	SetFont(_G.SystemFont_Shadow_Med2,             	GMFONTS["N"], 14, "")
	SetFont(_G.SystemFont_Shadow_Med3,             	GMFONTS["N"], 15, "")
	SetFont(_G.SystemFont_Shadow_Outline_Huge2,    	GMFONTS["N"], 22, "OUTLINE")
	SetFont(_G.SystemFont_Shadow_Small,            	GMFONTS["B"], 13, "")
	SetFont(_G.SystemFont_Small,                   	GMFONTS["N"], 13, "")
	SetFont(_G.SystemFont_Tiny,                    	GMFONTS["N"], 13, "")
	SetFont(_G.Tooltip_Med,                        	GMFONTS["N"], 13, "")
	SetFont(_G.Tooltip_Small,                      	GMFONTS["B"], 13, "")
	SetFont(_G.WhiteNormalNumberFont,              	GMFONTS["B"], 13, "")

	-- Derived fonts
	SetFont(_G.BossEmoteNormalHuge,     			GMFONTS["BI"], 27, "THICKOUTLINE")
	SetFont(_G.CombatTextFont,          			GMFONTS["N"], 26, "")
	SetFont(_G.ErrorFont,               			GMFONTS["I"], 16, "", 0.6)
	SetFont(_G.QuestFontNormalSmall,    			GMFONTS["B"], 13, "", nil, nil, nil, 0.54, 0.4, 0.1)
	SetFont(_G.WorldMapTextFont,        			GMFONTS["BI"], 31, "THICKOUTLINE",  0.4, nil, nil, 0, 0, 0, 1, -1)
	
	-- Other fonts definition taken from Phanx	
	SetFont(_G.ChatBubbleFont,                     GMFONTS["N"], 13, "")
	SetFont(_G.CoreAbilityFont,					   GMFONTS["B"], 32, "")
	SetFont(_G.DestinyFontHuge,                    GMFONTS["B"], 32, "")
	SetFont(_G.DestinyFontLarge,                   GMFONTS["B"], 18, "")
	SetFont(_G.Game18Font,                         GMFONTS["N"], 18, "")
	SetFont(_G.Game24Font,                         GMFONTS["N"], 24, "") -- there are two of these, good job Blizzard
	SetFont(_G.Game27Font,                         GMFONTS["N"], 27, "")
	SetFont(_G.Game30Font,                         GMFONTS["N"], 30, "")
	SetFont(_G.Game32Font,                         GMFONTS["N"], 32, "")
	SetFont(_G.NumberFont_GameNormal,              GMFONTS["N"], 10, "")
	SetFont(_G.NumberFont_Normal_Med,              GMFONTS["NR"], 14, "")
	
	SetFont(_G.NumberFont_GameNormal,              GMFONTS["N"], 11, "") -- orig 10 -- inherited by WhiteNormalNumberFont, tekticles = 11
	SetFont(_G.QuestFont_Enormous,                 GMFONTS["B"], 30, "")
	SetFont(_G.QuestFont_Huge,                     GMFONTS["B"], 19, "")

	SetFont(_G.QuestFont_Super_Huge_Outline,       GMFONTS["B"], 24, "OUTLINE")
	SetFont(_G.SplashHeaderFont,                   GMFONTS["B"], 24, "")
	
	SetFont(_G.SystemFont_Huge1,                   GMFONTS["N"], 20, "")
	SetFont(_G.SystemFont_Huge1_Outline,           GMFONTS["N"], 20, "OUTLINE")
	
	SetFont(_G.SystemFont_Outline,                 GMFONTS["NR"], 13, "OUTLINE")
	SetFont(_G.SystemFont_Shadow_Huge2,       		GMFONTS["B"], 24, "") -- SharedFonts.xml

	SetFont(_G.SystemFont_Shadow_Large2,           GMFONTS["N"], 19, "") -- SharedFonts.xml
	SetFont(_G.SystemFont_Shadow_Large_Outline,    GMFONTS["N"], 17, "OUTLINE") -- SharedFonts.xml
	
	SetFont(_G.SystemFont_Shadow_Med1_Outline,     GMFONTS["N"], 13, "OUTLINE") -- SharedFonts.xml
	SetFont(_G.SystemFont_Shadow_Small2,           GMFONTS["N"], 13, "") -- SharedFonts.xml
	SetFont(_G.SystemFont_Small2,                  GMFONTS["N"], 13, "") -- SharedFonts.xml
	
	
	for i=1,NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame"..i]
		if f then 
			local font, size, flags = f:GetFont()
			f:SetFont([[Interface\Addons\SharedMedia_BNS\font\ChironHeiHK-M.ttf]], size, flags)
		end
	end

	-- for _,butt in pairs(PaperDollTitlesPane.buttons) do butt.text:SetFontObject(GameFontHighlightSmallLeft) end

end

--- End tekkub code :-)
--[[
if LSM then	
	LSM:Register("font", "My custom font", fontpath .. "myfont.ttf")
	LSM:Register("font", "Ace Futurism", fontpath .. "Ace_Futurism.ttf")
	LSM:Register("font", "ExpressWay", fontpath .. "expressway.ttf")
	LSM:Register("font", "PT Sans", fontpath .. "PT_Sans-Web-Regular.ttf")
	LSM:Register("font", "PT Sans Bold", fontpath .. "PT_Sans-Web-Bold.ttf")
	LSM:Register("font", "PT Sans Bold Italic", fontpath .. "PT_Sans-Web-BoldItalic.ttf")
	LSM:Register("font", "PT Sans Italic", fontpath .. "PT_Sans-Web-Italic.ttf")
	LSM:Register("font", "Carlito", fontpath .. "Carlito-Regular.ttf")
	LSM:Register("font", "Carlito Bold", fontpath .. "Carlito-Bold.ttf")
	LSM:Register("font", "Carlito Italic", fontpath .. "Carlito-Italic.ttf")
	LSM:Register("font", "Carlito Bold Italic", fontpath .. "Carlito-BoldItalic.ttf")
	LSM:Register("font", "Ubuntu", fontpath .. "Ubuntu-R.ttf")
	LSM:Register("font", "Ubuntu Italic", fontpath .. "Ubuntu-RI.ttf")
	LSM:Register("font", "Ubuntu Condensed", fontpath .. "Ubuntu-C.ttf")
	LSM:Register("font", "Ubuntu Bold", fontpath .. "Ubuntu-B.ttf")
	LSM:Register("font", "Ubuntu Bold Italic", fontpath .. "Ubuntu-BI.ttf")
	LSM:Register("font", "Ubuntu Light", fontpath .. "Ubuntu-L.ttf")	
	LSM:Register("font", "Ubuntu Light Italic", fontpath .. "Ubuntu-LI.ttf")
	LSM:Register("font", "Ubuntu Medium", fontpath .. "Ubuntu-M.ttf")	
	LSM:Register("font", "Ubuntu Medium Italic", fontpath .. "Ubuntu-MI.ttf")
	LSM:Register("font", "Ubuntu Mono", fontpath .. "UbuntuMono-R.ttf")
	LSM:Register("font", "Ubuntu Mono Italic", fontpath .. "UbuntuMono-RI.ttf")
	LSM:Register("font", "Ubuntu Mono Bold", fontpath .. "UbuntuMono-B.ttf")
	LSM:Register("font", "Ubuntu Mono Bold Italic", fontpath .. "UbuntuMono-BI.ttf")
	LSM:Register("font", "ComicNeue", fontpath .. "ComicNeue-Regular.ttf")	
	LSM:Register("font", "ComicNeue Light", fontpath .. "ComicNeue-Light.ttf")	
	LSM:Register("font", "ComicNeue Bold", fontpath .. "ComicNeue-Bold.ttf")	
	LSM:Register("font", "Candara", fontpath .. "Candara.ttf")
	LSM:Register("font", "Candara Bold", fontpath .. "Candarab.ttf")
	LSM:Register("font", "Candara Italic", fontpath .. "Candarai.ttf")
	LSM:Register("font", "Candara Bold Italic", fontpath .. "Candaraz.ttf")
	LSM:Register("font", "Verdana", fontpath .. "Verdana.TTF")
	LSM:Register("font", "Verdana Bold", fontpath .. "Verdanab.TTF")
	LSM:Register("font", "Verdana Italic", fontpath .. "Verdanai.TTF")
	LSM:Register("font", "Verdana Bold Italic", fontpath .. "Verdanaz.TTF")
	LSM:Register("font", "Lauren", fontpath .. "lauren-normal.ttf")
	LSM:Register("font", "Lauren Bold", fontpath .. "lauren-bold.ttf")
	LSM:Register("font", "Lauren Italic", fontpath .. "lauren-italic.ttf")
	LSM:Register("font", "Lauren Bold Italic", fontpath .. "lauren-bold-italic.ttf")
	LSM:Register("font", "Lato", fontpath .. "Lato-Regular.ttf")
	LSM:Register("font", "Lato Bold", fontpath .. "Lato-Bold.ttf")
	LSM:Register("font", "Lato Italic", fontpath .. "Lato-Italic.ttf")
	LSM:Register("font", "Lato Bold Italic", fontpath .. "Lato-BoldItalic.ttf")
	LSM:Register("font", "Lato Thin", fontpath .. "Lato-Thin.ttf") 
	LSM:Register("font", "Happy Giraffe", fontpath .. "The Happy Giraffe Demo.ttf")
	LSM:Register("font", "Lady Bug", fontpath .. "Ladybug Love Demo.ttf")
	LSM:Register("font", "Droid Sans Mono", fontpath .. "DroidSansMono.ttf")
	LSM:Register("font", "Droid Sans", fontpath .. "DroidSans-Regular.ttf")
	LSM:Register("font", "Droid Sans Bold", fontpath .. "DroidSans-Bold.ttf")	
	LSM:Register("font", "AD Mono", fontpath .. "a_d_mono.ttf")
	LSM:Register("font", "Terminus", fontpath .. "Terminus.ttf")
	LSM:Register("font", "Terminus Bold", fontpath .. "TerminusBold.ttf")
	LSM:Register("font", "Ropa Sans", fontpath .. "RopaSans-Regular.ttf")
	LSM:Register("font", "Dosis", fontpath .. "Dosis-Regular.ttf")
	LSM:Register("font", "Dosis SemiBold", fontpath .. "Dosis-SemiBold.ttf")
	LSM:Register("font", "Dosis Bold", fontpath .. "Dosis-Bold.ttf")
	LSM:Register("font", "Dosis Medium", fontpath .. "Dosis-Medium.ttf")
	LSM:Register("font", "Noto Sans", fontpath .. "NotoSans-Regular.ttf")
	LSM:Register("font", "Noto Sans Bold", fontpath .. "NotoSans-Bold.ttf")
	LSM:Register("font", "Noto Sans Italic", fontpath .. "NotoSans-Italic.ttf")
	LSM:Register("font", "Noto Sans Bold Italic", fontpath .. "NotoSans-BoldItalic.ttf")
	LSM:Register("font", "Noto", fontpath .. "NotoSerif-Regular.ttf")
	LSM:Register("font", "Noto Bold", fontpath .. "NotoSerif-Bold.ttf")
	LSM:Register("font", "Noto Italic", fontpath .. "NotoSerif-Italic.ttf")
	LSM:Register("font", "Noto Bold Italic", fontpath .. "NotoSerif-BoldItalic.ttf")
	LSM:Register("font", "Noto Mono", fontpath .. "NotoMono-Regular.ttf")
	LSM:Register("font", "Roboto", fontpath .. "Roboto-Regular.ttf")
	LSM:Register("font", "Roboto Bold", fontpath .. "Roboto-Bold.ttf")
	LSM:Register("font", "Roboto Italic", fontpath .. "Roboto-Italic.ttf")
	LSM:Register("font", "Roboto Bold Italic", fontpath .. "Roboto-BoldItalic.ttf")
	LSM:Register("font", "OpenDyslexic", fontpath .. "OpenDyslexic-Regular.otf")
	LSM:Register("font", "OpenDyslexic Bold", fontpath .. "OpenDyslexic-Bold.otf")
	LSM:Register("font", "OpenDyslexic Italic", fontpath .. "OpenDyslexic-Italic.otf")
	LSM:Register("font", "OpenDyslexic Bold Italic", fontpath .. "OpenDyslexic-Bold-Italic.otf")
end
--]]
-- Configuration Panel -------------------------------------------------------------------------------------

local options = CreateFrame("Frame", ADDON.."Options", InterfaceOptionsFramePanelContainer)

UIParent:UnregisterEvent("GLOBAL_MOUSE_DOWN")

options.name = "字體" -- GetAddOnMetadata(ADDON, "Title") or ADDON
-- InterfaceOptions_AddCategory(options)
local category = Settings.RegisterCanvasLayoutCategory(options, options.name)
category.ID = options.name
Settings.RegisterAddOnCategory(category)

local title = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("遊戲介面字體")
options.title = title

local textmenu = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormal")
textmenu:SetPoint("TOPLEFT", 16, -48)
textmenu:SetText("只影響整體介面文字的預設字體和大小，每個插件仍可分別設定。")
options.textmenu = textmenu

local textlsmfonts = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormal")
textlsmfonts:SetPoint("TOPLEFT", 16, -80)
textlsmfonts:SetText("選擇共享媒體庫的字體:")
options.textlsmfonts = textlsmfonts

local lsmfonts = {} 
local lsmfonts = LSM:List("font")

local dropdown = PCD:New(options)
dropdown:SetPoint("TOPLEFT", 16, -80)
dropdown:SetList(lsmfonts)
dropdown.tooltipText = "請注意：英文字體無法顯示中文，請選擇中文字體。"
function dropdown:OnValueChanged(text,value)

	local LSM_DEFAULT_FONT = LSM:Fetch("font", value)
     
	GMFONTS["N"] 	= LSM_DEFAULT_FONT
	GMFONTS["B"] 	= LSM_DEFAULT_FONT
	GMFONTS["BI"] 	= LSM_DEFAULT_FONT
	GMFONTS["I"] 	= LSM_DEFAULT_FONT
	GMFONTS["NR"] 	= LSM_DEFAULT_FONT
   
	UpdateFonts()
	options.refresh()

end
--[[
local textgmfonts = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormal")
textgmfonts:SetPoint("TOPLEFT", 230, -80)
textgmfonts:SetText("gmFonts sets")
options.textgmfonts = textgmfonts
 
local gmlistfonts = {} 
local gmlistfonts = {"Ubuntu", "Ubuntu Mono", "Ubuntu Light","Carlito", "PT Sans", "ComicNeue", "Candara", "Verdana", "Laurel", "Lato", "Noto", "Noto Sans", "Roboto", "OpenDyslexic"}

local dropdown2 = PCD:New(options)
dropdown2:SetPoint("TOPLEFT", 230, -80)
dropdown2:SetList(gmlistfonts)
function dropdown2:OnValueChanged(text)
   
   	local gmfontset = {}
	gmfontset["Ubuntu"] = 		{"Ubuntu-R.ttf", "Ubuntu-B.ttf", "Ubuntu-BI.ttf", "Ubuntu-RI.ttf"}
	gmfontset["Ubuntu Mono"] = 	{"UbuntuMono-R.ttf", "UbuntuMono-B.ttf", "UbuntuMono-BI.ttf", "UbuntuMono-RI.ttf"}
	gmfontset["Ubuntu Light"] = {"Ubuntu-L.ttf", "Ubuntu-M.ttf", "Ubuntu-MI.ttf", "Ubuntu-L.ttf"}
	gmfontset["Carlito"] = 		{"Carlito-Regular.ttf", "Carlito-Bold.ttf", "Carlito-BoldItalic.ttf", "Carlito-Italic.ttf"}
	gmfontset["PT Sans"] = 		{"PT_Sans-Web-Regular.ttf", "PT_Sans-Web-Bold.ttf", "PT_Sans-Web-BoldItalic.ttf", "PT_Sans-Web-Italic.ttf"}
	gmfontset["ComicNeue"] = 	{"ComicNeue-Regular.ttf", "ComicNeue-Bold.ttf", "ComicNeue-Bold.ttf", "ComicNeue-Regular.ttf"}
	gmfontset["Candara"] = 		{"Candara.ttf", "Candarab.ttf", "Candaraz.ttf", "Candarai.ttf"}
	gmfontset["Verdana"] = 		{"Verdana.TTF", "Verdanab.TTF", "Verdanaz.TTF", "Verdanai.TTF"}
	gmfontset["Laurel"] = 		{"lauren-normal.ttf", "lauren-bold.ttf", "lauren-italic.ttf", "lauren-bold-italic.ttf"}
	gmfontset["Lato"] = 		{"Lato-Regular.ttf", "Lato-Bold.ttf", "Lato-Italic.ttf", "Lato-BoldItalic.ttf"}
	gmfontset["Noto"] = 		{"NotoSerif-Regular.ttf", "NotoSerif-Bold.ttf", "NotoSerif-Italic.ttf", "NotoSerif-BoldItalic.ttf"}
	gmfontset["Noto Sans"] = 	{"NotoSans-Regular.ttf", "NotoSans-Bold.ttf", "NotoSans-Italic.ttf", "NotoSans-BoldItalic.ttf"}
	gmfontset["Roboto"] = 		{"Roboto-Regular.ttf", "Roboto-Bold.ttf", "Roboto-Italic.ttf", "Roboto-BoldItalic.ttf"}
	gmfontset["OpenDyslexic"] = {"OpenDyslexic-Regular.otf", "OpenDyslexic-Bold.otf", "OpenDyslexic-Italic.otf", "OpenDyslexic-Bold-Italic.otf"}
	
	GMFONTS["N"] 	= fontpath .. gmfontset[text][1]
	GMFONTS["B"] 	= fontpath .. gmfontset[text][2]
	GMFONTS["BI"] 	= fontpath .. gmfontset[text][3]
	GMFONTS["I"] 	= fontpath .. gmfontset[text][4]
	GMFONTS["NR"] 	= fontpath .. gmfontset[text][1]
   
	UpdateFonts()
	options.refresh()
   
end
--]]
-- print the default values
local textdefaultn = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormal")
textdefaultn:SetPoint("TOPLEFT", 16, -160)
options.textdefaultn = textdefaultn

local textdefaultb = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormal")
textdefaultb:SetPoint("TOPLEFT", 16, -180)
options.textdefaultb = textdefaultb

local textdefaultbi = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormal")
textdefaultbi:SetPoint("TOPLEFT", 16, -200)
options.textdefaultbi = textdefaultbi

local textdefaulti = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormal")
textdefaulti:SetPoint("TOPLEFT", 16, -220)
options.textdefaulti = textdefaulti

local textdefaultnr = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormal")
textdefaultnr:SetPoint("TOPLEFT", 16, -240)
options.textdefaultnr = textdefaultnr

local slidertxt = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormal")
slidertxt:SetPoint("TOPLEFT", 16, -300)
slidertxt:SetText(string_format("|cffffffff%s|r : %s","文字大小比例","調整文字大小的縮放比例"))
options.slidertxt = slidertxt

local slider = CreateFrame("Slider","slider_name",options,"OptionsSliderTemplate") --frameType, frameName, frameParent, frameTemplate   
slider:SetPoint("TOPLEFT", 16, -330)
slider.textLow = _G["slider_name".."Low"]
slider.textHigh = _G["slider_name".."High"]
slider.text = _G["slider_name".."Text"]
slider:SetMinMaxValues(-4, 4)
slider.minValue, slider.maxValue = slider:GetMinMaxValues() 
slider.textLow:SetText(slider.minValue)
slider.textHigh:SetText(slider.maxValue)
slider.text:SetText("")
slider:SetValue(2)
slider:SetValueStep(1)
slider.value = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
slider.value:SetPoint("TOP", slider, "BOTTOM", 0, 0)
slider.value:SetText(GMFONTS["delta"])
slider:SetScript("OnValueChanged", function(self, value)
	GMFONTS["delta"] = floor(value + 0.5)
	self:SetValue(GMFONTS["delta"])
	self.value:SetText(GMFONTS["delta"])
end)


local textadvice = options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormal")
textadvice:SetPoint("TOPLEFT", 16, -400)
textadvice:SetText(string_format("|cffffffff%s|r : %s","提示","更改字體後需要重新載入介面..."))
options.textadvice = textadvice

-- WoW Default Fonts Button
local gmfonts_def_button = CreateFrame("button", gmfonts_def_button, options, "UIPanelButtonTemplate")
gmfonts_def_button:SetHeight(BUTTON_HEIGHT)
gmfonts_def_button:SetWidth(BUTTON_WIDTH)
gmfonts_def_button:SetPoint("TOPLEFT", 16, -430)
gmfonts_def_button:SetText("彩虹預設值")
gmfonts_def_button.tooltipText = "請注意：按下後會立刻將字體初始化為預設值並且重新載入介面。"
gmfonts_def_button:SetScript("OnClick",  
	function()
		GMFONTS = {}
		ReloadUI()
	end)  

-- WoW Default Fonts Button
local gmfonts_rld_button = CreateFrame("button", gmfonts_rld_button, options, "UIPanelButtonTemplate")
gmfonts_rld_button:SetHeight(BUTTON_HEIGHT)
gmfonts_rld_button:SetWidth(BUTTON_WIDTH)
gmfonts_rld_button:SetPoint("TOPLEFT", 180, -430)
gmfonts_rld_button:SetText(RELOADUI)
gmfonts_rld_button.tooltipText = "重新載入介面"
gmfonts_rld_button:SetScript("OnClick",  
	function()
		ReloadUI()
	end)  

--- credits 
local credits = options:CreateFontString("$parentTitle", "ARTWORK", "SystemFont_Small")
credits:SetPoint("BOTTOMRIGHT", -16, 16)
credits:SetText("Font engine: |cffffd200tekticles|r by tekkub      Widget engine: |cffffd200PhanxConfig-Dropdown|r by phanx")
options.credits = credits	
	
function options.refresh()
	slider:SetValue(GMFONTS["delta"])
	textdefaultn:SetText(string_format("|cffffffff%s|r : %s","一般",GMFONTS["N"] ))
	textdefaultb:SetText(string_format("|cffffffff%s|r : %s","粗體",GMFONTS["B"] ))
	textdefaultbi:SetText(string_format("|cffffffff%s|r : %s","粗斜體",GMFONTS["BI"] ))
	textdefaulti:SetText(string_format("|cffffffff%s|r : %s","斜體",GMFONTS["I"] ))
	textdefaultnr:SetText(string_format("|cffffffff%s|r : %s","數字",GMFONTS["NR"] ))
end

-- Configuration Panel End ---------------------------------------------------------------------------------

if LibStub and LibStub("LibAboutPanel", true) then
	options.about = LibStub("LibAboutPanel").new(options.name, ADDON)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function()

	local GMFONTS_DEFAULTS = { 
		["N"]="Interface\\Addons\\SharedMedia_Rainbow\\fonts\\bHEI00M\\bHEI00M.ttf", 
		["B"]="Interface\\Addons\\SharedMedia_Rainbow\\fonts\\bHEI00M\\bHEI00M.ttf",
		["BI"]="Interface\\Addons\\SharedMedia_Rainbow\\fonts\\bHEI00M\\bHEI00M.ttf",
		["I"]="Interface\\Addons\\SharedMedia_Rainbow\\fonts\\bHEI00M\\bHEI00M.ttf",
		["NR"]="Interface\\Addons\\SharedMedia_Rainbow\\fonts\\bHEI00M\\bHEI00M.ttf",
		["delta"]="2",
	}

	for k in pairs(GMFONTS_DEFAULTS) do
		if GMFONTS[k] == nil then GMFONTS[k] = GMFONTS_DEFAULTS[k] end
	end

	-- some check to prevent to call UpdateFonts() without a defined font.
	local k,v
	local checkfont = 0

	for k,v in pairs(GMFONTS) do	   
	   checkfont=1	   
	   if v == "遊戲預設值" then 
		  checkfont = 0
	   end
	end

	textdefaultn:SetText(string_format("|cffffffff%s|r : %s","一般",GMFONTS["N"] or "Default"))
	textdefaultb:SetText(string_format("|cffffffff%s|r : %s","粗體",GMFONTS["B"] ))
	textdefaultbi:SetText(string_format("|cffffffff%s|r : %s","粗斜體",GMFONTS["BI"] ))
	textdefaulti:SetText(string_format("|cffffffff%s|r : %s","斜體",GMFONTS["I"] ))
	textdefaultnr:SetText(string_format("|cffffffff%s|r : %s","數字",GMFONTS["NR"] ))	
	slider:SetValue(GMFONTS["delta"])
	slider.value:SetText(GMFONTS["delta"])

	if checkfont == 1 then UpdateFonts() end

end)