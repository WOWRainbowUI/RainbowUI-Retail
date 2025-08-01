local GlobalAddonName, MRT = ...

MRT.Options = {}

local ELib,L = MRT.lib,MRT.L

------------------------------------------------------------
--------------- New Options --------------------------------
------------------------------------------------------------

local OptionsFrameName = "MRTOptionsFrame"
local Options = ELib:Template("ExRTBWInterfaceFrame",UIParent)
_G[OptionsFrameName] = Options

MRT.Options.Frame = Options

Options.Width = 863
Options.Height = 650
Options.ListWidth = 165

Options:Hide()
Options:SetPoint("CENTER",0,0)
Options:SetSize(Options.Width,Options.Height)
Options.HeaderText:SetText("")
Options:SetMovable(true)
Options:RegisterForDrag("LeftButton")
Options:SetScript("OnDragStart", function(self) self:StartMoving() end)
Options:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
Options:SetDontSavePosition(true)
Options.border = MRT.lib.CreateShadow(Options,20)

ELib:ShadowInside(Options)

Options.bossButton:Hide()
Options.backToInterface:SetScript("OnClick",function ()
	MRT.Options.Frame:Hide()
	if SettingsPanel then
		SettingsPanel:Show()
	else
		InterfaceOptionsFrame:Show()
	end
end)


Options.modulesList = ELib:ScrollList(Options):LineHeight(24):Size(Options.ListWidth - 1,Options.Height):Point(0,0):FontSize(11):HideBorders()
Options.modulesList.SCROLL_WIDTH = 10
Options.modulesList.LINE_PADDING_LEFT = 7
Options.modulesList.LINE_TEXTURE = "Interface\\Addons\\"..GlobalAddonName.."\\media\\White"
Options.modulesList.LINE_TEXTURE_IGNOREBLEND = true
Options.modulesList.LINE_TEXTURE_HEIGHT = 24
Options.modulesList.LINE_TEXTURE_COLOR_HL = {1,1,1,.5}
Options.modulesList.LINE_TEXTURE_COLOR_P = {1,.82,0,.6}
Options.modulesList.EnableHoverAnimation = true

Options.modulesList.border_right = ELib:Texture(Options.modulesList,.24,.25,.30,1,"BORDER"):Point("TOPLEFT",Options.modulesList,"TOPRIGHT",0,0):Point("BOTTOMRIGHT",Options.modulesList,"BOTTOMRIGHT",1,0)

Options.modulesList.Frame.ScrollBar:Size(8,0):Point("TOPRIGHT",0,0):Point("BOTTOMRIGHT",0,0)
Options.modulesList.Frame.ScrollBar.thumb:SetHeight(100)
Options.modulesList.Frame.ScrollBar.buttonUP:Hide()
Options.modulesList.Frame.ScrollBar.buttonDown:Hide()

Options.modulesList.Frame.ScrollBar.border_right = ELib:Texture(Options.modulesList.Frame.ScrollBar,.24,.25,.30,1,"BORDER"):Point("TOPLEFT",Options.modulesList.Frame.ScrollBar,"TOPLEFT",-1,0):Point("BOTTOMRIGHT",Options.modulesList.Frame.ScrollBar,"BOTTOMLEFT",0,0)

Options.Frames = {}

Options:SetScript("OnShow",function(self)
	self.modulesList:Update()
	if Options.CurrentFrame and Options.CurrentFrame.AdditionalOnShow then
		Options.CurrentFrame:AdditionalOnShow()
	end

	if type(Options.CurrentFrame.OnShow) == 'function' then
		Options.CurrentFrame:OnShow()
	end
end)

function Options:SetPage(page,dontreload)
	local isSamePage = Options.CurrentFrame == page
	if Options.CurrentFrame and (not dontreload or not isSamePage) then
		Options.CurrentFrame:Hide()
	end
	Options.CurrentFrame = page

	if Options.CurrentFrame.AdditionalOnShow and (not dontreload or not isSamePage) then
		Options.CurrentFrame:AdditionalOnShow()
	end

	if (not dontreload or not isSamePage) then
		Options.CurrentFrame:Show()
	end

	if Options.CurrentFrame.isWide and Options.nowWide ~= Options.CurrentFrame.isWide then
		local frameWidth = type(Options.CurrentFrame.isWide)=='number' and Options.CurrentFrame.isWide or 850
		Options:SetWidth(frameWidth+Options.ListWidth)
		Options.nowWide = Options.CurrentFrame.isWide
	elseif not Options.CurrentFrame.isWide and Options.nowWide then
		Options:SetWidth(Options.Width)
		Options.nowWide = nil
	end

	if Options.CurrentFrame.isWide then
		Options.CurrentFrame:SetWidth(type(Options.CurrentFrame.isWide)=='number' and Options.CurrentFrame.isWide or 850)
		Options.CurrentFrame._wasWide = true
	elseif Options.CurrentFrame._wasWide then
		Options.CurrentFrame:SetWidth(Options.Width-Options.ListWidth)
		Options.CurrentFrame._wasWide = nil
	end

	if type(Options.CurrentFrame.OnShow) == 'function' then
		Options.CurrentFrame:OnShow()
	end
end


function Options.modulesList:SetListValue(index)
	Options:SetPage(Options.Frames[index])
end


function MRT.Options:Add(moduleName,frameName)
	local self = CreateFrame("Frame",OptionsFrameName..moduleName,Options)
	self:SetSize(Options.Width-Options.ListWidth,Options.Height-16)
	self:SetPoint("TOPLEFT",Options.ListWidth,-16)
	self.moduleName = moduleName
	
	local pos = #Options.Frames + 1
	Options.modulesList.L[pos] = frameName or moduleName
	Options.Frames[pos] = self
	
	if Options:IsShown() then
		Options.modulesList:Update()
	end
	
	self:Hide()
	
	return self
end

function MRT.Options:AddIcon(moduleName,icon)
	Options.modulesList.IconsRight = Options.modulesList.IconsRight or {}
	for i=1,#Options.Frames do
		if Options.Frames[i].moduleName == moduleName then
			Options.modulesList.IconsRight[i] = icon
			break
		end
	end
	if Options:IsShown() then
		Options.modulesList:Update()
	end
end
function MRT.Options:RemoveIcon(moduleName)
	if not Options.modulesList.IconsRight then
		return
	end
	for i=1,#Options.Frames do
		if Options.Frames[i].moduleName == moduleName then
			Options.modulesList.IconsRight[i] = nil
			break
		end
	end
	if Options:IsShown() then
		Options.modulesList:Update()
	end
end

local OptionsFrame = MRT.Options:Add("Method Raid Tools","|cffffa800"..L.addonname.."|r")
Options.modulesList:SetListValue(1)
Options.modulesList.selected = 1
Options.modulesList:Update()

------------------------------------------------------------
--[[ 不顯示選項
MRT.Options.InBlizzardInterface = CreateFrame( "Frame", nil )
MRT.Options.InBlizzardInterface.name = "Method Raid Tools"
if SettingsPanel then
	local category = Settings.RegisterCanvasLayoutCategory(MRT.Options.InBlizzardInterface, "Method Raid Tools")
	Settings.RegisterAddOnCategory(category)
else
	InterfaceOptions_AddCategory(MRT.Options.InBlizzardInterface)
end
MRT.Options.InBlizzardInterface:Hide()

MRT.Options.InBlizzardInterface:SetScript("OnShow",function (self)
	if SettingsPanel then
		if SettingsPanel:IsShown() then
			HideUIPanel(SettingsPanel)
		end
	else
		if InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrame:Hide()
		end
	end
	MRT.Options:Open()
	self:SetScript("OnShow",nil)
end)

MRT.Options.InBlizzardInterface.button = ELib:Button(MRT.Options.InBlizzardInterface,"Method Raid Tools",0):Size(400,25):Point("TOP",0,-100):OnClick(function ()
	if SettingsPanel then
		if SettingsPanel:IsShown() then
			HideUIPanel(SettingsPanel)
		end
	else
		if InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrame:Hide()
		end
	end
	MRT.Options:Open()
end)
--]]
------------------------------------------------------------

Options.scale = ELib:Slider(Options):_Size(70,8):Point("TOPRIGHT",-45,-5):Range(50,200,true):OnShow(function(self)
	VMRT.Addon.Scale = tonumber(VMRT.Addon.Scale or "1") or 1
	VMRT.Addon.Scale = max( min( VMRT.Addon.Scale,2 ),0.5)

	self:SetTo((VMRT.Addon.Scale or 1)*100):Scale(1 / (VMRT.Addon.Scale or 1)):OnChange(function(self,event) 
		if self.disable then
			self:SetTo(100)
			self.tooltipText = L.bossmodsscale.."|n100%|n"..L.SetScaleReset
			return
		end
		event = MRT.F.Round(event)
		VMRT.Addon.Scale = event / 100
		MRT.F.SetScaleFixTR(Options,VMRT.Addon.Scale)
		self:SetScale(1 / VMRT.Addon.Scale)
		self.tooltipText = L.bossmodsscale.."|n"..event.."%|n"..L.SetScaleReset
		self:tooltipReload(self)
	end)
	self:SetScript("OnShow",nil)
	self.tooltipText = L.bossmodsscale.."|n"..((VMRT.Addon.Scale or 1) * 100).."%|n"..L.SetScaleReset
	self:Point("TOPRIGHT",-45 * (VMRT.Addon.Scale or 1),-5)
	Options:SetScale(VMRT.Addon.Scale or 1)
end,true)

Options.scale:SetScript("OnMouseDown",function(self,button)
	if button == "RightButton" then
		self:SetTo(100)
		self.disable = true
	end
end)
Options.scale:SetScript("OnMouseUp",function(self,button)
	if button == "RightButton" then
		self.disable = nil
	end
	self:Point("TOPRIGHT",-45 * (VMRT.Addon.Scale or 1),-5)
end)

----> Minimap Icon

--[=[

local LDB = LibStub("LibDataBroker-1.1",true)
local LDBI = LibStub("LibDBIcon-1.0",true)

if LDB and LDBI then
	local dataBroker = LDB:NewDataObject("MRT",
		{type = "launcher", label = "Method Raid Tools", icon = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\MiniMap"}
	)
	
	function dataBroker.OnClick(self, button)
		if button == "RightButton" then
			for _,func in pairs(MRT.MiniMapMenu) do
				func:miniMapMenu()
			end
			MRT.Options:UpdateModulesList()
			ELib.ScrollDropDown.EasyMenu(self,MRT.F.menuTable,150)
		elseif button == "LeftButton" then
			MRT.Options:Open()
		end
	end
	
	function dataBroker.OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_LEFT") 
		GameTooltip:AddLine("Method Raid Tools") 
		GameTooltip:AddLine(L.minimaptooltiplmp,1,1,1) 
		GameTooltip:AddLine(L.minimaptooltiprmp,1,1,1) 
		GameTooltip:Show() 
		if not self.anim then
			self.iconMini = self:CreateTexture(nil, "ARTWORK")
			self.iconMini:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\MiniMap")
			self.iconMini:SetSize(18,18)
			self.iconMini:SetPoint("CENTER", self, "CENTER")
			self.iconMini:SetVertexColor(1,.5,.5,1)
			self.iconMini:Hide()

			self.anim = self:CreateAnimationGroup()
			self.anim:SetLooping("BOUNCE")
			self.timer = self.anim:CreateAnimation()
			self.timer:SetDuration(2)
			self.timer:SetScript("OnUpdate", function(s,elapsed) 
				self.iconMini:SetAlpha(s:GetProgress())
			end)
		end
		self.anim:Play()
		self.iconMini:Show()
	end

	function dataBroker.OnLeave(self)
		GameTooltip:Hide()
		if self.anim then
			self.anim:Stop()
			self.iconMini:Hide()
		end
	end

	VMRT.IconDB = VMRT.IconDB or {}
	LDBI:Register("MRT", dataBroker, VMRT.IconDB)
end

]=]

local MiniMapIcon = CreateFrame("Button", "LibDBIcon10_MethodRaidTools", Minimap)
MRT.MiniMapIcon = MiniMapIcon
MiniMapIcon:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight") 
MiniMapIcon:SetSize(32,32) 
MiniMapIcon:SetFrameStrata("MEDIUM")
MiniMapIcon:SetFrameLevel(8)
MiniMapIcon:SetPoint("CENTER", -12, -80)
MiniMapIcon:SetDontSavePosition(true)
MiniMapIcon:RegisterForDrag("LeftButton")
MiniMapIcon.icon = MiniMapIcon:CreateTexture(nil, "BACKGROUND")
MiniMapIcon.icon:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\MiniMap")
MiniMapIcon.icon:SetSize(18,18)
MiniMapIcon.icon:SetPoint("CENTER",0,1)
MiniMapIcon.iconMini = MiniMapIcon:CreateTexture(nil, "BACKGROUND")
MiniMapIcon.iconMini:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\MiniMap")
MiniMapIcon.iconMini:SetSize(18,18)
MiniMapIcon.iconMini:SetPoint("CENTER", 0, 1)
MiniMapIcon.iconMini:SetVertexColor(1,.5,.5,1)
MiniMapIcon.iconMini:Hide()
MiniMapIcon.border = MiniMapIcon:CreateTexture(nil, "ARTWORK")
MiniMapIcon.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
MiniMapIcon.border:SetTexCoord(0,0.6,0,0.6)
MiniMapIcon.border:SetAllPoints()
MiniMapIcon:RegisterForClicks("anyUp")
MiniMapIcon:SetScript("OnEnter",function(self) 
	GameTooltip:SetOwner(self, "ANCHOR_LEFT") 
	GameTooltip:AddLine(L.addonname) 
	GameTooltip:AddLine(L.minimaptooltiplmp,1,1,1) 
	GameTooltip:AddLine(L.minimaptooltiprmp,1,1,1) 
	GameTooltip:Show() 
	self.anim:Play()
	self.iconMini:Show()
end)
MiniMapIcon:SetScript("OnLeave", function(self)    
	GameTooltip:Hide()
	self.anim:Stop()
	self.iconMini:Hide()
end)
if not MRT.isClassic then
	MiniMapIcon.icon:SetSize(20,20)
	MiniMapIcon.iconMini:SetSize(20,20)
	MiniMapIcon.icon:SetPoint("CENTER",1,0)
	MiniMapIcon.iconMini:SetPoint("CENTER", 1, 0)
end



MiniMapIcon.anim = MiniMapIcon:CreateAnimationGroup()
MiniMapIcon.anim:SetLooping("BOUNCE")
MiniMapIcon.timer = MiniMapIcon.anim:CreateAnimation()
MiniMapIcon.timer:SetDuration(2)
MiniMapIcon.timer:SetScript("OnUpdate", function(self,elapsed) 
	MiniMapIcon.iconMini:SetAlpha(self:GetProgress())
end)

local minimapShapes = {
	["ROUND"] = {true, true, true, true},
	["SQUARE"] = {false, false, false, false},
	["CORNER-TOPLEFT"] = {false, false, false, true},
	["CORNER-TOPRIGHT"] = {false, false, true, false},
	["CORNER-BOTTOMLEFT"] = {false, true, false, false},
	["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
	["SIDE-LEFT"] = {false, true, false, true},
	["SIDE-RIGHT"] = {true, false, true, false},
	["SIDE-TOP"] = {false, false, true, true},
	["SIDE-BOTTOM"] = {true, true, false, false},
	["TRICORNER-TOPLEFT"] = {false, true, true, true},
	["TRICORNER-TOPRIGHT"] = {true, false, true, true},
	["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
	["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
}

local function IconMoveButton(self)
	if self.dragMode == "free" then
		local centerX, centerY = Minimap:GetCenter()
		local x, y = GetCursorPosition()
		x, y = x / self:GetEffectiveScale() - centerX, y / self:GetEffectiveScale() - centerY
		self:ClearAllPoints()
		self:SetPoint("CENTER", x, y)
		VMRT.Addon.IconMiniMapLeft = x
		VMRT.Addon.IconMiniMapTop = y
	else
		local mx, my = Minimap:GetCenter()
		local px, py = GetCursorPosition()
		local scale = Minimap:GetEffectiveScale()
		px, py = px / scale, py / scale
		
		local angle = math.atan2(py - my, px - mx)
		local x, y, q = math.cos(angle), math.sin(angle), 1
		if x < 0 then q = q + 1 end
		if y > 0 then q = q + 2 end
		local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
		local quadTable = minimapShapes[minimapShape]
		local w = (Minimap:GetWidth() / 2) + 5
		local h = (Minimap:GetHeight() / 2) + 5
		if quadTable[q] then
			x, y = x*w, y*h
		else
			local diagRadiusW = sqrt(2*(w)^2)-10
			local diagRadiusH = sqrt(2*(h)^2)-10
			x = max(-w, min(x*diagRadiusW, w))
			y = max(-h, min(y*diagRadiusH, h))
		end
		self:ClearAllPoints()
		self:SetPoint("CENTER", Minimap, "CENTER", x, y)
		VMRT.Addon.IconMiniMapLeft = x
		VMRT.Addon.IconMiniMapTop = y
	end
end

MiniMapIcon:SetScript("OnDragStart", function(self)
	self:LockHighlight()
	self:SetScript("OnUpdate", IconMoveButton)
	self.isMoving = true
	GameTooltip:Hide()
end)
MiniMapIcon:SetScript("OnDragStop", function(self)
	self:UnlockHighlight()
	self:SetScript("OnUpdate", nil)
	self.isMoving = false
end)

local function MiniMapIconOnClick(self, button)
	if button == "RightButton" then
		for _,func in pairs(MRT.MiniMapMenu) do
			func:miniMapMenu()
		end
		MRT.Options:UpdateModulesList()
		--EasyMenu(MRT.F.menuTable, MRT.Options.MiniMapDropdown, "cursor", 10 , -15, "MENU")
		ELib.ScrollDropDown.EasyMenu(self,MRT.F.menuTable,150)
	elseif button == "LeftButton" then
		MRT.Options:Open()
	end
end

MRT_MinimapClickFunction = function()
	MRT.Options:Open()
end

MiniMapIcon:SetScript("OnMouseUp", MiniMapIconOnClick)

MRT.Options.MiniMapDropdown = CreateFrame("Frame", "MRTMiniMapMenuFrame", nil, "UIDropDownMenuTemplate")

local MinimapMenu_UIDs = {}
local MinimapMenu_UIDnumeric = 0
local MinimapMenu_Level = {3,4,5,5}

function MRT.F.MinimapMenuAdd(text, func, level, uid, subMenu)
	level = level or 2
	if not uid then
		MinimapMenu_UIDnumeric = MinimapMenu_UIDnumeric + 1
		uid = MinimapMenu_UIDnumeric
	end
	if MinimapMenu_UIDs[uid] then
		return
	end
	local menuTable = { text = text, func = func, notCheckable = true, keepShownOnClick = true, }
	if subMenu then
		menuTable.hasArrow = true
		menuTable.menuList = subMenu
		menuTable.subMenu = subMenu
	end
	tinsert(MRT.F.menuTable,MinimapMenu_Level[level],menuTable)
	for i=level,#MinimapMenu_Level do
		MinimapMenu_Level[i] = MinimapMenu_Level[i] + 1
	end
	MinimapMenu_UIDs[uid] = menuTable
end

function MRT.F.MinimapMenuRemove(uid)
	for i=1,#MRT.F.menuTable do
		if MRT.F.menuTable[i] == MinimapMenu_UIDs[uid] then 
			for j=i,#MRT.F.menuTable do
				MRT.F.menuTable[j] = MRT.F.menuTable[j+1]
			end
			for j=1,#MinimapMenu_Level do
				if i <= MinimapMenu_Level[j] then
					MinimapMenu_Level[j] = MinimapMenu_Level[j] - 1
				end
			end
			MinimapMenu_UIDs[uid] = nil
			return
		end
	end
end

function MRT.Options:Open(PANEL)
	CloseDropDownMenus()
	ELib.ScrollDropDown.Close()
	Options:Show()
	
	Options:SetPage(PANEL or Options.Frames[Options.modulesList.selected or 1])
	
	if PANEL then
		for i=1,#Options.Frames do
			if Options.Frames[i] == PANEL then
				Options.modulesList.selected = i
				Options.modulesList:Update()
				break
			end
		end
	end
end

function MRT.Options:OpenByModuleName(moduleName)
	for i=1,#Options.Frames do
		if Options.Frames[i].moduleName == moduleName then
			Options:Show()

			Options:SetPage(Options.Frames[i])

			Options.modulesList.selected = i
			Options.modulesList:Update()
			return Options.Frames[i]
		end
	end
end

MRT.F.menuTable = {
{ text = L.minimapmenu, isTitle = true, notCheckable = true, notClickable = true },
{ text = L.minimapmenuset, func = MRT.Options.Open, notCheckable = true, keepShownOnClick = true, },
{ text = " ", isTitle = true, notCheckable = true, notClickable = true },
{ text = " ", isTitle = true, notCheckable = true, notClickable = true },
{ text = "Profiling", func = function() CloseDropDownMenus() ELib.ScrollDropDown.Close() MRT.F:ProfilingWindow() end, notCheckable = true },
{ text = " ", isTitle = true, notCheckable = true, notClickable = true },
{ text = L.minimapmenuclose, func = function() CloseDropDownMenus() ELib.ScrollDropDown.Close() end, notCheckable = true },
}

if MRT.Dev == true then
	tinsert(MRT.F.menuTable, { text = "Reload UI", func = function() ReloadUI() end, notCheckable = true })
end

local modulesActive = {}
function MRT.Options:UpdateModulesList()
	for i=1,#MRT.ModulesOptions do
		MRT.F.MinimapMenuAdd(MRT.ModulesOptions[i].name, function() 
			MRT.Options:Open(MRT.ModulesOptions[i]) 
		end, 2,MRT.ModulesOptions[i].name)
	end
end

----> Options
local OptionsFrame_title, OptionsFrame_image, OptionsFrame_imagehat

function OptionsFrame:AddSnowStorm(maxSnowflake)
	local sf = OptionsFrame.SnowStorm or CreateFrame("ScrollFrame", nil, Options)
	OptionsFrame.SnowStorm = sf
	sf:SetPoint("TOPLEFT")
	sf:SetPoint("BOTTOMRIGHT")

	local resumeSnowFunc = function(self)
		self:SetScript("OnUpdate",nil)
		for i=1,self.snowlast do
			self.snow[i].g:Play()
		end
	end
	
	sf.C = sf.C or CreateFrame("Frame", nil, sf) 
	sf:SetScrollChild(sf.C)
	sf.C:SetSize(Options:GetWidth(),Options:GetHeight())

	maxSnowflake = maxSnowflake or 200

	if not OptionsFrame.hatBut then
		local hat = CreateFrame("Button",nil,OptionsFrame)  
		OptionsFrame.hatBut = hat
		hat:SetSize(50,30) 
		hat:SetPoint("CENTER",OptionsFrame_image,-40,55)
		hat.maxSnowflake = maxSnowflake
		hat:RegisterForClicks("LeftButtonDown","RightButtonDown")
		hat:SetScript("OnClick",function(self,button) 
			if button == "RightButton" then
				self.maxSnowflake = 0
			else
				self.maxSnowflake = self.maxSnowflake + 100
			end
			OptionsFrame:AddSnowStorm(self.maxSnowflake)
		end)
		hat:SetScript("OnEnter",function()
			OptionsFrame_imagehat:SetVertexColor(1,.8,.8)
		end)
		hat:SetScript("OnLeave",function()
			OptionsFrame_imagehat:SetVertexColor(1,1,1)
		end)

		hat.g = hat:CreateAnimationGroup()
		hat.g:SetScript('OnFinished', function(self) 
			self.a:SetStartDelay(math.random(10,30))
			self:Play()
		end)
		hat.g.a = hat.g:CreateAnimation()
		hat.g.a:SetDuration(1)
		hat.g.a:SetScript("OnUpdate",function(self)
			local p = self:GetProgress()
			p = p % 0.333
			if p > 0.1665 then 
				p = p 
				if p > 0.24975 then 
					p = (0.333 - p)
				else
					p = p - 0.1665
				end
			else
				if p > 0.08325 then 
					p = -(0.1665 - p)
				else
					p = 0 - p
				end
			end
			OptionsFrame_imagehat:SetPoint("CENTER",OptionsFrame_image,"CENTER",p*12*3,0)
		end)
		hat.g.a:SetStartDelay(10)
		hat.g:Play()
	end

	sf.snow = sf.snow or {}
	sf.snowlast = sf.snowlast or 0
	if sf.snowlast > maxSnowflake then
		for i=maxSnowflake+1,#sf.snow do
			local f = sf.snow[i]
			f:Hide()
			f.g:Pause()
		end
		sf.snowlast = 0
		return
	end

	local function AnimOnFinished(self)
		local f = self.p
		f.img:Hide()
		f:Update()
	end
	local function AnimOnUpdate(self)
		if not sf:IsVisible() then
			sf:SetScript("OnUpdate",resumeSnowFunc)
			self:GetParent():Pause()
			return
		end
		local f = self.p
		local p = self:GetProgress()
		if p == 0 then
			return
		end
		if p > 0 and not f.img.on then
			f.img.on = true
			f.img:Show()
		end
		if p > self.wayu then
			self.wayu = p + 0.15
			local way = math.random(1,3)
			self.way = way - 2
			self.wayF, self.wayT = 0, 40
			if self.way == 0 then
				self.wayF, self.wayT = -20, 20
				self.way = 1
			end
		end
		f.x = f.x + math.random(self.wayF, self.wayT) / 100 * self.way
		local posy = -self.H*p+20+self.Hfix
		f.img:SetPoint("CENTER",sf.C,"TOPLEFT",f.x,posy)
		if self.Hfix ~= 0 and posy < (-self.H+20) then
			self:Stop()
			f:Update()
		end
	end
	local function Update(self,isFirstTime)
		local size = math.random(1,20)
		if size >= 10 then
			if math.random(0,100) < 80 then
				size = math.random(1,10)
			end
		end
		self.img:SetSize(size,size)
		self.img.on = nil
		self.g.a.wayu = 0
		self.x = math.random(0,Options:GetWidth())
		self.g.a:SetStartDelay(1+math.random(0,1000)/100)
		self.g.a:SetDuration(math.random(5,14)*(size < 10 and 0.75 or 1))
		self.g.a.H = Options:GetHeight()+40
		self.g.a.Hfix = 0
		if isFirstTime then
			self.g.a.Hfix = -math.random(0,self.g.a.H)
			self.g.a:SetStartDelay(0)
		end
		self.g:Play()
	end

	for i=1,maxSnowflake do
		if not sf.snow[i] then
			local f = CreateFrame("Frame",nil,sf.C)
			sf.snow[i] = f
		
			f.Update = Update

			f.img = f:CreateTexture(nil,"BACKGROUND")
			f.img:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\snowflake")
			f.img:SetAlpha(.5)
			f.img:Hide()
			
			f.g = f:CreateAnimationGroup()
			f.g.p = f
			f.g:SetScript('OnFinished', AnimOnFinished)
			f.g.a = f.g:CreateAnimation()
			f.g.a.p = f
			f.g.a:SetScript("OnUpdate",AnimOnUpdate)
		
			f:Update(true)
		end
		sf.snow[i].g:Play()
		sf.snow[i]:Show()
	end
	sf.snowlast = maxSnowflake
end

function OptionsFrame:AddDeathStar(maxDeathStars,deathStarType)
	local sf = OptionsFrame.DeathStar or CreateFrame("ScrollFrame", nil, Options)
	OptionsFrame.DeathStar = sf
	sf:SetPoint("TOPLEFT")
	sf:SetPoint("BOTTOMRIGHT")

	sf.C = sf.C or CreateFrame("Frame", nil, sf) 
	sf:SetScrollChild(sf.C)
	sf.C:SetSize(Options:GetWidth(),Options:GetHeight())

	local resumeSnowFunc = function(self)
		self:SetScript("OnUpdate",nil)
		for i=1,self.snowlast do
			self.snow[i].g:Play()
		end
	end

	maxDeathStars = maxDeathStars or 1

	if not OptionsFrame.hatBut then
		local hat = CreateFrame("Button",nil,OptionsFrame)  
		OptionsFrame.hatBut = hat
		hat:SetSize(76,20) 
		hat:SetPoint("TOP",OptionsFrame_image,22,-5)
		if deathStarType == 2 then
			hat:SetPoint("TOP",OptionsFrame_image,3,-35)
			hat:SetSize(50,50) 
		end
		hat.maxDeathStars = maxDeathStars
		hat:RegisterForClicks("LeftButtonDown","RightButtonDown")
		hat:SetScript("OnClick",function(self,button) 
			if button == "RightButton" then
				self.maxDeathStars = 0
			else
				self.maxDeathStars = self.maxDeathStars + 1
			end
			OptionsFrame:AddDeathStar(self.maxDeathStars,deathStarType)
		end)

		OptionsFrame.score = ELib:Text(OptionsFrame,"Score: 0",28):Point("RIGHT",OptionsFrame_title,"CENTER",85,-27):Color("FF9117"):Font("Interface\\AddOns\\"..GlobalAddonName.."\\media\\FiraSansMedium.ttf",20)
	end

	sf.snow = sf.snow or {}
	sf.snowlast = sf.snowlast or 0
	if sf.snowlast > maxDeathStars then
		for i=maxDeathStars+1,#sf.snow do
			local f = sf.snow[i]
			f:Hide()
			f.g:Pause()
		end
		sf.snowlast = 0
		return
	end

	local function AnimOnFinished(self)
		local f = self.p
		f.img:Hide()
		f:Update()
	end
	local function AnimOnUpdate(self)
		if not sf:IsVisible() then
			sf:SetScript("OnUpdate",resumeSnowFunc)
			self:GetParent():Pause()
			return
		end
		local f = self.p
		local p = self:GetProgress()
		if p == 0 then
			return
		end
		if p > 0 and not f.img.on then
			f.img.on = true
			f.img:Show()
		end
		if not f.pause then
			f.img:SetPoint("TOPLEFT",sf.C,"TOPLEFT",f.xf+(f.xt-f.xf)*p,-(f.yf+(f.yt-f.yf)*p))
		end
		if IsMouseButtonDown(1) and f.img2:IsMouseOver() and not f.pause then
			f.pause = true
			f.img:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\deathstard")
			
			local d = self:GetDuration()
			local ds = math.min(p + 0.5 / d, 0.999)
			local dp = math.min(p + 2 / d, 1)
			f.alphastart = ds
			f.alphaend = dp

			local t = OptionsFrame.score:GetText()
			local tt = tonumber(t:match("%d+"),10)
			OptionsFrame.score:SetText(t:gsub("%d+",tt+1))
		end
		if f.pause then
			local a = 1
			if p >= f.alphastart then
				a = 1 - (p - f.alphastart) / (f.alphaend - f.alphastart)
			end
			if a < 0 then a = 0 elseif a > 1 then a = 1 end
			f.img:SetAlpha(a)
			if p >= f.alphaend then
				self:Stop()
			end
		end
	end
	local function Update(self,isFirstTime)
		local size = 128
		if self.pause then
			self.pause = nil
			self.img:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\"..(deathStarType == 2 and "borgcube" or "deathstar"))
			self.img:SetAlpha(1)
		end
		self.img:SetSize(size,size)
		local img2s = deathStarType == 2 and 0.9 or 0.7
		self.img2:SetSize(size*img2s,size*img2s)
		self.img.on = nil
		self.g.a.wayu = 0
		local MIN,MAXX,MAXY = -size, Options:GetWidth(), Options:GetHeight()
		self.xf = math.random(MIN,MAXX)
		self.xt = math.random(MIN,MAXX)
		self.yf = math.random(MIN,MAXY)
		self.yt = math.random(MIN,MAXY)
		local p = math.random(1,4)
		if p == 1 then
			self.yf = MIN
		elseif p == 2 then
			self.xf = MAXX
		elseif p == 3 then
			self.yf = MAXY
		elseif p == 4 then
			self.xf = MIN
		end
		local p2 = math.random(1,4)
		while p == p2 do
			p2 = math.random(1,4)
		end
		if p2 == 1 then
			self.yt = MIN
		elseif p2 == 2 then
			self.xt = MAXX
		elseif p2 == 3 then
			self.yt = MAXY
		elseif p2 == 4 then
			self.xt = MIN
		end		
		self.g.a:SetStartDelay(1+math.random(0,1000)/100)
		self.g.a:SetDuration(math.random(5,14))
		if isFirstTime then
			self.g.a:SetStartDelay(0)
		end
		self.g:Play()
	end

	for i=1,maxDeathStars do
		if not sf.snow[i] then
			local f = CreateFrame("Frame",nil,sf.C)
			sf.snow[i] = f
		
			f.Update = Update

			f.img = f:CreateTexture(nil,"BACKGROUND")
			f.img:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\"..(deathStarType == 2 and "borgcube" or "deathstar"))
			f.img:SetAlpha(1)
			f.img:Hide()

			f.img2 = f:CreateTexture(nil,"BACKGROUND")
			f.img2:SetPoint("CENTER",f.img)
			f.img2:Hide()
			
			f.g = f:CreateAnimationGroup()
			f.g.p = f
			f.g:SetScript('OnFinished', AnimOnFinished)
			f.g.a = f.g:CreateAnimation()
			f.g.a.p = f
			f.g.a:SetScript("OnUpdate",AnimOnUpdate)
		
			f:Update(true)
		end
		sf.snow[i].g:Play()
		sf.snow[i]:Show()
	end
	sf.snowlast = maxDeathStars
end

function OptionsFrame:AddChest(chestType)
	local sf = OptionsFrame.ChestFrame or CreateFrame("ScrollFrame", nil, Options)
	OptionsFrame.ChestFrame = sf
	sf:SetPoint("TOPLEFT")
	sf:SetPoint("BOTTOMRIGHT")

	sf.C = sf.C or CreateFrame("Frame", nil, sf) 
	sf:SetScrollChild(sf.C)
	sf.C:SetSize(Options:GetWidth(),Options:GetHeight())

	local SCALE = 0.4

	local captured
	local function AddCaptured()
		if captured then
			return captured
		end
		local animated = CreateFrame("Button",nil,UIParent)
		captured = animated
		animated.texture = animated:CreateTexture()
		animated.texture:SetAllPoints()
		local list = {
			{img = [[Interface\AddOns\MRT\media\frieren.jpg]],w = 256*1.5,h = 256*1.5,s = 0.15,m = 14},
			{img = [[Interface\AddOns\MRT\media\frieren2.jpg]],w = 597 * 0.75,h = 408 * 0.75,s = 0.15},
			{img = [[Interface\AddOns\MRT\media\frieren3.jpg]],w = 1024 * 0.5,h = 576 * 0.5,s = 0.10,m=31,is=8,se={[16]={.6,.9,1,.4},[17]={.12,.52,1,.3},[18]=-1,[19]=-1,[20]={.12,.52,1,.1},[24]={.6,.9,1,.3},[25]={.12,.52,1,.3},[26]={.12,.52,1,.2},[27]={.12,.52,1,.1},[28]={.12,.52,1,.05},[29]=-1}},
		}
		local data = list[math.random(1,#list)]
		animated.texture:SetTexture(data.img)
		animated:SetFrameStrata("DIALOG")

		animated.specialeffect = animated:CreateTexture(nil,"BACKGROUND")
		animated.specialeffect:SetAllPoints(UIParent)
		animated.specialeffect:SetColorTexture(.12,.52,1,0)
		
		animated:SetPoint("CENTER")
		animated:SetSize(data.w,data.h)
		animated.texture:SetTexCoord(0,0.25,0,0.25)
		
		animated.frame = 0
		animated.frame_max = data.m or 15
		animated.tmr = 1
		animated:SetScript("OnUpdate",function(self,elapsed)
			self.tmr = self.tmr + elapsed
			if self.tmr > data.s then
				self.tmr = 0
				self.frame = self.frame + 1

				if not Options:IsShown() then
					self:Hide()
				end
		
				if self.frame > self.frame_max then
					self.frame = 0
				end
		
				local w = self.frame % (data.is or 4)
				local h = floor(self.frame / (data.is or 4))
				
				local ww = 1 / (data.is or 4)
				self.texture:SetTexCoord(w * ww,(w + 1) * ww,h * 0.25,(h + 1) * 0.25)

				if data.se then
					local c = data.se[self.frame]
					if c then
						if c == -1 then for i=self.frame-1,0,-1 do c = data.se[i] if c~=-1 then break end end end
						animated.specialeffect:SetColorTexture(unpack(c))
					else
						animated.specialeffect:SetColorTexture(0,0,0,0)
					end	
				end
			end
		end)
		animated:SetScript("OnClick",function(self)
			self:Hide()
		end)
	end

	local chest = CreateFrame("Button",nil,sf.C)  
	OptionsFrame.chestBut = chest
	chest:SetSize(175*SCALE,130*SCALE) 
	local x,y = math.random(130,Options:GetWidth()-175*SCALE),math.random(0,Options:GetHeight()-130*SCALE)
	chest:SetPoint("TOPLEFT",x,-y)
	chest:RegisterForClicks("LeftButtonDown","RightButtonDown")
	chest:SetScript("OnClick",function(self,button) 
		AddCaptured()
		captured:Show()
		self:Hide()
	end)
	chest.t = chest:CreateTexture()
	chest.t:SetAllPoints()
	chest.t:SetAtlas("ChallengeMode-Chest")

	chest:RotateTextures(math.pi*2/360*(math.random(0,360)))
end


function OptionsFrame:AddWeb()
	local sf = OptionsFrame.HWWebFrame or CreateFrame("ScrollFrame", nil, Options)
	OptionsFrame.HWWebFrame = sf

	if not sf.c then
		sf.c = CreateFrame("Frame", nil, sf) 
		sf:SetScrollChild(sf.c)
	
		sf:SetSize(200,200)
		sf:SetPoint("TOPRIGHT",0,-16)
		sf.c:SetSize(200,200)
	
		local X,Y = -0,-0
		local function l(x1,y1,x2,y2)
			local line = sf.c:CreateLine(nil,"ARTWORK",nil,2)
			line:SetColorTexture(1,1,1,.4)
			line:SetStartPoint("TOPRIGHT",x1+X,y1+Y)
			line:SetEndPoint("TOPRIGHT",x2+X,y2+Y)
			line:SetThickness(2)
		end
		local ANGLE = 5
		local RADIUS,SPACE,PIES = 160, 20, 18
		local pie_angle = (360/PIES)
		for i=0+ANGLE,359,pie_angle do
			if i >= 180-45 and i <= 270+45 then
				local x = math.cos(2*math.pi/360*i)*RADIUS
				local y = math.sin(2*math.pi/360*i)*RADIUS
				l(0,0,x,y)
			end
		end
		
		for i=0+ANGLE,359,pie_angle do
			if i >= 180-45 and i <= 270+45 then
				for j=RADIUS-10,SPACE,-SPACE do
					local x1 = math.cos(2*math.pi/360*i)*j
					local y1 = math.sin(2*math.pi/360*i)*j
					local x2 = math.cos(2*math.pi/360*(i+pie_angle))*j
					local y2 = math.sin(2*math.pi/360*(i+pie_angle))*j
					l(x1,y1,x2,y2)
				end
			end
		end
	end

	local sf = OptionsFrame.GhostFrame or CreateFrame("ScrollFrame", nil, Options)
	OptionsFrame.GhostFrame = sf
	sf:SetPoint("TOPLEFT")
	sf:SetPoint("BOTTOMRIGHT")

	if not sf.C then
		sf.C = sf.C or CreateFrame("Frame", nil, sf) 
		sf:SetScrollChild(sf.C)
		sf.C:SetSize(Options:GetWidth(),Options:GetHeight())

		sf.g = {}
		sf.c = 0
		local function CreateGhost(i,parent,size)
			if not i then 
				sf.c = sf.c + 1
				i = sf.c
			end
			if sf.g[i] then
				sf.g[i]:Show()
				return sf.g[i]
			end
			local f = CreateFrame("Frame",nil,parent)
			f:SetSize(1,1)
		
			f:SetAlpha(.3)

			sf.g[i] = f
		
			local function ct(i,x)
				local g1 = f:CreateTexture(nil, "BACKGROUND",nil,-6)
				g1:SetTexture(i and "Interface\\AddOns\\MRT\\media\\circle256inv" or "Interface\\AddOns\\MRT\\media\\circle256")
				g1:SetVertexColor(1,1,1,1)
				g1:SetTexCoord(0,1,0,x and 1 or .5)
				return g1
			end
		
			local s = size / 100
		
			local g1 = ct()
			g1:SetPoint("TOP",0,0)
			g1:SetSize(130*s,70*s)
			
			local g2 = f:CreateTexture(nil, "BACKGROUND",nil,-6)
			g2:SetColorTexture(1,1,1,1)
			g2:SetPoint("TOP",g1,"BOTTOM",0,0)
			g2:SetSize(130*s,200*s)
			
			local g3 = ct(true)
			g3:SetPoint("TOPLEFT",g2,"BOTTOMLEFT",0,0)
			g3:SetSize(40*s,20*s)
			
			local g4 = ct(true)
			g4:SetPoint("LEFT",g3,"RIGHT",0,0)
			g4:SetSize(50*s,20*s)
			
			local g5 = ct(true)
			g5:SetPoint("LEFT",g4,"RIGHT",0,0)
			g5:SetSize(40*s,20*s)
			
			local g6 = ct(nil,true)
			g6:SetVertexColor(0,0,0,1)
			g6:SetPoint("CENTER",g1,-25*s,-40*s)
			g6:SetSize(20*s,30*s)
			
			local g7 = ct(nil,true)
			g7:SetVertexColor(0,0,0,1)
			g7:SetPoint("CENTER",g1,25*s,-40*s)
			g7:SetSize(20*s,30*s)
		
			return f
		end
		sf.CreateGhost = CreateGhost
	end


	if not OptionsFrame.hatBut then
		local hat = CreateFrame("Button",nil,OptionsFrame)  
		OptionsFrame.hatBut = hat
		hat:SetAllPoints(OptionsFrame_image) 

		hat:RegisterForClicks("LeftButtonDown","RightButtonDown")
		hat:SetScript("OnClick",function(self,button) 
			if button == "RightButton" then
				sf.c = 0
				for i=1,#sf.g do sf.g[i]:Hide() end
				return
			end
			local g = sf.CreateGhost(nil,sf.C,30)
			g:SetPoint("TOPLEFT",math.random(0,Options:GetWidth()),-math.random(0,Options:GetHeight()))
		end)
	end
end

OptionsFrame_image = OptionsFrame:CreateTexture(nil,"ARTWORK")

local p = {[0] = OptionsFrame_image[0]}
setmetatable(p,getmetatable(OptionsFrame_image))
OptionsFrame_image[0] = nil
OptionsFrame_image = p

OptionsFrame_image:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\OptionLogo2")
OptionsFrame_image:SetPoint("TOPLEFT",15,5)
OptionsFrame_image:SetSize(140,140)
OptionsFrame_image.Point = OptionsFrame_image.SetPoint


OptionsFrame_title = ELib:Texture(OptionsFrame,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\logoname2"):Point("LEFT",OptionsFrame_image,"RIGHT",15,-5):Size(512*0.7,128*0.7)

local askFrame_show
local pmove_pos = 40
OptionsFrame.pmove = CreateFrame("Frame",nil,OptionsFrame)
OptionsFrame.pmove:SetPoint("CENTER",OptionsFrame_image,"CENTER",54*cos(pmove_pos),54*sin(pmove_pos))
OptionsFrame.pmove:SetSize(15,15)
local function pmove_OnUpdate(self,elapsed)
	if not self:IsMouseOver() or not IsMouseButtonDown() then
		self.isReverse = true
	end
	if self.isReverse and self:IsMouseOver() and IsMouseButtonDown() then
		self.isReverse = false
	end
	--pmove_pos = pmove_pos + (self.isReverse and -1 or 1) * (100 / GetFramerate() * 0.333)
	pmove_pos = pmove_pos + (self.isReverse and -1 or 1) * (100 / 60 * 0.333)
	if self.isReverse and pmove_pos < 40 then
		pmove_pos = 40
		self:SetScript("OnUpdate",nil)
	elseif not self.isReverse and pmove_pos >= 400 then
		pmove_pos = 40
		self:SetScript("OnUpdate",nil)
		askFrame_show()
	end
	self:SetPoint("CENTER",OptionsFrame_image,"CENTER",54*cos(pmove_pos),54*sin(pmove_pos))
	OptionsFrame_image:SetRotation((pmove_pos-40)*PI/180)
end
OptionsFrame.pmove:SetScript("OnMouseDown",function(self)
	self.isReverse = false
	self:SetScript("OnUpdate",pmove_OnUpdate)
end)

OptionsFrame.animLogo = CreateFrame("Frame",nil,OptionsFrame)
OptionsFrame.animLogo.g = OptionsFrame.animLogo:CreateAnimationGroup()
OptionsFrame.animLogo.g:SetLooping("BOUNCE")
OptionsFrame.animLogo.g:SetScript('OnFinished', function(self) 
	self.a:SetStartDelay(math.random(4,15))
	self:Play()
end)
OptionsFrame.animLogo.g.a = OptionsFrame.animLogo.g:CreateAnimation()
OptionsFrame.animLogo.g.a:SetDuration(.5)
OptionsFrame.animLogo.g.a:SetScript("OnUpdate",function(self)
	local p = 0.5-abs(0.5-self:GetProgress())
	if pmove_pos ~= 40 then return end
	OptionsFrame_image:SetRotation(p*10*PI/180)
end)
OptionsFrame.animLogo.g.a:SetStartDelay(4)
OptionsFrame.animLogo.g:Play()

OptionsFrame_imagehat = ELib:Texture(OptionsFrame,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\OptionLogoHat","OVERLAY"):Point("CENTER",OptionsFrame_image,"CENTER",0,0):Size(140,140):Shown(false)

OptionsFrame.dateChecks = CreateFrame("Frame",nil,OptionsFrame)
OptionsFrame.dateChecks:SetPoint("TOPLEFT")
OptionsFrame.dateChecks:SetSize(1,1)
OptionsFrame.dateChecks:SetScript("OnShow",function(self)
	self:SetScript("OnShow",nil)
	local today = date("*t",time())
	local isChristmas, isSnowDay
	local isFrierenFriday
	if MRT.locale == "ruRU" then
		if (today.month == 12 and today.day >= 23) or (today.month == 1 and today.day <= 4) then
			isChristmas = true
		end
		if (today.month == 12 and today.day >= 30) or (today.month == 1 and today.day <= 2) then
			isSnowDay = true
		end
		if (today.month == 12 and today.day >= 24 and today.day <= 25) then
			isSnowDay = true
		end
	elseif MRT.locale == "deDE" or MRT.locale == "enGB" or MRT.locale == "enUS" or MRT.locale == "esES" or MRT.locale == "esMX" or MRT.locale == "frFR" or MRT.locale == "itIT" or MRT.locale == "ptBR" or MRT.locale == "ptPT" then
		if (today.month == 12 and today.day >= 15) or (today.month == 1 and today.day <= 2) then
			isChristmas = true
		end
		if (today.month == 12 and today.day >= 24 and today.day <= 25) or ((today.month == 12 and today.day >= 31) or (today.month == 1 and today.day <= 1)) then
			isSnowDay = true
		end
	elseif MRT.locale == "koKR" then
		if (today.month == 12 and today.day >= 30) or (today.month == 1 and today.day <= 2) then
			isChristmas = true
		end
		if (today.month == 12 and today.day >= 31) or (today.month == 1 and today.day <= 1) then
			isSnowDay = true
		end
	end
	if (today.wday == 6 and today.day % 2 == 0 and today.day > 16) and not MRT.isClassic then
		isFrierenFriday = true
	end	
	
	if isFrierenFriday then
		OptionsFrame:AddChest()
	end

	if isChristmas then
		OptionsFrame_imagehat:Show()
		if isSnowDay then
			OptionsFrame:AddSnowStorm()
		else
			OptionsFrame:AddSnowStorm(0)
		end

		return
	end

	if (today.month == 5 and today.day == 4) then
		OptionsFrame_image:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\OptionLogom4")
		OptionsFrame_title:Color("FF9117")
		if math.random(1,5) == 4 then
			OptionsFrame_title:Color("ff0000")	--you are sith
		else	
			OptionsFrame_title:Color("00ff00")
		end

		OptionsFrame:AddDeathStar()

		return
	end

	if (today.month == 4 and today.day == 5) then
		OptionsFrame_image:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\OptionLogost")

		OptionsFrame:AddDeathStar(nil,2)

		return
	end

	if (today.month == 10 and today.day >= 30) or (today.month == 11 and today.day <= 1) then
		OptionsFrame_image:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\OptionLogohw")

		OptionsFrame:AddWeb()

		return
	end

	if (today.month == 4 and today.day == 28) then
		local s = 0.39
		OptionsFrame_title:Size(512*0.7,128*0.7*s):TexCoord(0,1,0,s):Point("LEFT",OptionsFrame_image,"RIGHT",15,-5+128*s*0.4*0.5):Color(0, 87/255, 183/255,1)
		local OptionsFrame_title2 = ELib:Texture(OptionsFrame,"Interface\\AddOns\\"..GlobalAddonName.."\\media\\logoname2"):Point("TOP",OptionsFrame_title,"BOTTOM"):Size(512*0.7,128*0.7*(1-s)):TexCoord(0,1,s,1):Color(255/255, 221/255, 0,1)

		return
	end

	if type(GetGuildInfo) == 'function' and ((MRT.isClassic and GetGuildInfo("player") == "Гачивайд") or (not MRT.isClassic and today.wday == 4 and GetGuildInfo("player") == "Дивайд")) then
		OptionsFrame_image:SetTexture("Interface\\AddOns\\"..GlobalAddonName.."\\media\\OptionLogogv")
		OptionsFrame_image:SetTexCoord(0,1,0.21875,1-0.21875)
		OptionsFrame_image:SetSize(140,79)
		OptionsFrame_image:Point("TOPLEFT",15,5-32)

		return
	end
end)

do
	local askFrame
	function askFrame_show()
		if not askFrame then
			local M_WIDTH,M_HEIGHT = 1024,650

			askFrame = CreateFrame("Button",nil,UIParent)
			askFrame:Hide()
			askFrame:SetSize(M_WIDTH,M_HEIGHT)
			askFrame:SetPoint("CENTER")
			askFrame:SetFrameStrata("DIALOG")
			local mainbg = ELib:Texture(askFrame,[[Interface\AddOns\MRT\media\askjt]],"BACKGROUND"):TexCoord(0,1,0,650/1024):Size(M_WIDTH,M_HEIGHT):Point("TOPLEFT")
			local hiddenask = ELib:Texture(askFrame,[[Interface\AddOns\MRT\media\askjt]],"BORDER"):TexCoord(0,146/1024,651/1024,874/1024):Size(147,223):Point("CENTER",mainbg,35,-112)
			hiddenask:SetAlpha(0)

			askFrame:SetMovable(true)
			askFrame:RegisterForDrag("LeftButton")
			askFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
			askFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

			askFrame.Close = ELib:Templates_GUIcons(1)
			askFrame.Close:SetParent(askFrame)
			askFrame.Close:SetPoint("TOPRIGHT",-1,0)
			askFrame.Close:SetSize(18,18)
			askFrame.Close:SetScript("OnClick",function() askFrame:Hide() end)

			askFrame.border = ELib.CreateShadow(askFrame,20)

			local soundWillPlay, soundHandle, soundTicker
			askFrame:SetScript("OnShow",function()
				soundWillPlay, soundHandle = PlaySoundFile("Interface/AddOns/MRT/media/askm.ogg","Master")
				if soundTicker then
					soundTicker:Cancel()
				end
				soundTicker = C_Timer.NewTicker(40,function()
					if soundHandle then
						StopSound(soundHandle)
					end
					soundWillPlay, soundHandle = PlaySoundFile("Interface/AddOns/MRT/media/askm.ogg","Master")	
				end)
			end)
			askFrame:SetScript("OnHide",function()
				if soundTicker then
					soundTicker:Cancel()
				end
				if soundHandle then
					StopSound(soundHandle)
				end
			end)
			
			local MIN_X,MAX_X = 354, 672
			local MIN_Y,MAX_Y = 379, 409
			
			local cars = {}
			for i=1,30 do
				local posX = MIN_X + (MAX_X - MIN_X) * math.random()
				local posY = MIN_Y + (MAX_Y - MIN_Y) * math.random()
				local width = math.random(3,7)
				local height = math.random(1,2)
				local car = ELib:Texture(askFrame,0,0,0,.3):Size(width,height):Point("TOPLEFT",mainbg,posX,-posY)
				cars[i] = car
				car.x = posX
				car.y = posY
				car.w = width
				car.h = height
				car.s = math.random(10,100) / 100
				car:SetAlpha(0)
			end

			local sf = CreateFrame("ScrollFrame", nil, askFrame)
			sf:SetPoint("TOPLEFT")
			sf:SetPoint("BOTTOMRIGHT")
		
			sf.C = CreateFrame("Frame", nil, sf) 
			sf:SetScrollChild(sf.C)
			sf.C:SetSize(M_WIDTH,M_HEIGHT)

			local function AnimOnUpdate(self)
				local p = self:GetProgress()
				self = self.p
				self:SetPoint("TOPLEFT",self.fx+(self.tx-self.fx)*p,self.fy+(self.ty-self.fy)*p)
			end
			local function AnimOnFinished(self)
				self.p:Update()
			end
			local function AnimUpdate(self,isFirstTime)
				local width = math.random(1,10)
				self.t:SetSize(width,width)
				local alpha = math.random(10,40)
				self.t:Color(1,1,1,alpha/100)

				local maxw,maxh = M_WIDTH,M_HEIGHT
				local dur = math.random(15,30)

				if isFirstTime then
					self.fx = math.random(0,maxw)
					self.fy = -math.random(0,maxh)
					if self.fx < maxw * 0.5 then
						dur = dur * 0.5
					end
				else
					self.fx = math.random(maxw*0.25,maxw*1.5)
					self.fy = -maxh-width
				end
				if math.random(1,2) == 1 then
					self.tx = math.random(-width,self.fx)
					self.ty = width
				else
					self.tx = -width
					self.ty = math.random(-maxh,width)
				end
				self.g.a:SetDuration(dur)
				self.g:Play()
			end

			local blink = {}
			for i=1,100 do
				local f = CreateFrame("Frame",nil,sf.C)
				f:SetSize(1,1)
				blink[i] = f
				f.t = ELib:Texture(f,[[Interface\AddOns\MRT\media\blip.tga]]):Point("CENTER")

				f.g = f:CreateAnimationGroup()
				f.g.p = f
				f.g:SetScript('OnFinished', AnimOnFinished)
				f.g.a = f.g:CreateAnimation()
				f.g.a.p = f
				f.g.a:SetScript("OnUpdate",AnimOnUpdate)

				f.Update = AnimUpdate
				f:Update(true)
			end
			
			local start = GetTime() + 5
			local carAlphaStart
			askFrame:SetScript("OnUpdate",function()
				local now = GetTime()
				if now - start <= 30 then
					local a = max(0,min((now - start) / 30,1))
					hiddenask:SetAlpha(a)
				elseif not hiddenask.isshown then
					hiddenask:SetAlpha(1)
					hiddenask.isshown = true
					carAlphaStart = now + 5
				end
			
				if carAlphaStart then
					if now < carAlphaStart then
						local a = 1-max(0,min((carAlphaStart - now) / 5,1))
						for i=1,#cars do
							cars[i]:SetAlpha(a)
						end
					elseif not hiddenask.carsFull then
						for i=1,#cars do
							cars[i]:SetAlpha(1)
						end
						hiddenask.carsFull = true
					end
					for i=1,#cars do
						local car = cars[i]
						if i % 2 == 0 then
							car.x = car.x + car.s
							local adjX = 0
							if car.x > MAX_X then
								car.x = MIN_X - car.w + 1
								car:SetWidth(min(car.w - (MIN_X - car.x),car.w))
								adjX = MIN_X - car.x
							elseif car.x + car.w > MAX_X and car.x < MAX_X then
								car:SetWidth(max(MAX_X - car.x,1))
							elseif car.x < MIN_X then
								car:SetWidth(min(car.w - (MIN_X - car.x),car.w))
								adjX = MIN_X - car.x
							else
								car:SetWidth(car.w)
							end
							car:Point("TOPLEFT",mainbg,car.x + adjX,-car.y)
						else
							car.x = car.x - car.s
							local adjX = 0
							if car.x < MIN_X - car.w then
								car.x = MAX_X
								car:SetWidth(1)
							elseif car.x < MIN_X then
								car:SetWidth(max(car.w - (MIN_X - car.x),1))
								adjX = MIN_X - car.x
							elseif car.x + car.w > MAX_X then
								car:SetWidth(min(car.w - (car.x + car.w - MAX_X),car.w))
							else
								car:SetWidth(car.w)
							end
							car:Point("TOPLEFT",mainbg,car.x + adjX,-car.y)
						end
					end
				end
			end)
		end
		askFrame:Show()
	end
end

OptionsFrame.chkIconMiniMap = ELib:Check(OptionsFrame,L.setminimap1):Point(25,-155):OnClick(function(self) 
	if self:GetChecked() then
		VMRT.Addon.IconMiniMapHide = true
		MRT.MiniMapIcon:Hide()
	else
		VMRT.Addon.IconMiniMapHide = nil
		MRT.MiniMapIcon:Show()
	end
end)
OptionsFrame.chkIconMiniMap:SetScript("OnShow", function(self,event) 
	self:SetChecked(VMRT.Addon.IconMiniMapHide) 
end)

OptionsFrame.chkHideOnEsc = ELib:Check(OptionsFrame,L.SetHideOnESC):Point(350,-155):OnClick(function(self) 
	if self:GetChecked() then
		VMRT.Addon.DisableHideESC = true
		for i=1,#UISpecialFrames do
			if UISpecialFrames[i] == "MRTOptionsFrame" then
				tremove(UISpecialFrames, i)
				break
			end
		end
	else
		VMRT.Addon.DisableHideESC = nil
		tinsert(UISpecialFrames, "MRTOptionsFrame")
	end
end)
OptionsFrame.chkHideOnEsc:SetScript("OnShow", function(self,event) 
	self:SetChecked(VMRT.Addon.DisableHideESC) 
end)

OptionsFrame.authorLeft = ELib:Text(OptionsFrame,L.setauthor,12):Size(150,25):Point(15,-195):Shadow():Top()
OptionsFrame.authorRight = ELib:Text(OptionsFrame,"Afiya (Афиа) @ EU-Howling Fjord",12):Size(520,25):Point(135,-195):Color():Shadow():Top()

OptionsFrame.versionLeft = ELib:Text(OptionsFrame,L.setver,12):Size(150,25):Point(15,-215):Shadow():Top()
OptionsFrame.versionRight = ELib:Text(OptionsFrame,MRT.V..(MRT.T == "R" and "" or " "..MRT.T),12):Size(520,25):Point(135,-215):Color():Shadow():Top()

OptionsFrame.contactLeft = ELib:Text(OptionsFrame,L.setcontact,12):Size(150,25):Point(15,-235):Shadow():Top()
OptionsFrame.contactRight = ELib:Text(OptionsFrame,"e-mail: ykiigor@gmail.com",12):Size(520,25):Point(135,-235):Color():Shadow():Top()

OptionsFrame.thanksLeft = ELib:Text(OptionsFrame,L.SetThanks,12):Size(150,25):Point(15,-255):Shadow():Top()
OptionsFrame.thanksRight = ELib:Text(OptionsFrame,"Phanx, funkydude, Shurshik, Kemayo, Guillotine, Rabbit, fookah, diesal2010, Felix, yuk6196, martinkerth, Gyffes, Cubetrace, tigerlolol, Morana, SafeteeWoW, Dejablue, Wollie, eXochron, Firehead94, Mitalie, m33shoq",12):Size(540,0):Point(135,-255):Color():Shadow():Top()

if L.TranslateBy ~= "" then
	OptionsFrame.translateLeft = ELib:Text(OptionsFrame,L.SetTranslate,12):Size(150,25):Point("LEFT",OptionsFrame,15,0):Point("TOP",OptionsFrame.thanksRight,"BOTTOM",0,-8):Shadow():Top()
	OptionsFrame.translateRight = ELib:Text(OptionsFrame,L.TranslateBy,12):Size(520,25):Point("LEFT",OptionsFrame.thanksRight,"LEFT",0,0):Point("TOP",OptionsFrame.translateLeft,0,0):Color():Shadow():Top()
end

OptionsFrame.Changelog = ELib:ScrollFrame(OptionsFrame):Size(680,180):Point("TOP",0,-335):OnShow(function(self)
	local text = MRT.Options.Changelog or ""
	text = text:gsub("(v%.%d+([^\n]*).-\n\n)",function(a,b)
		if (b == "-Classic" and MRT.isClassic and not MRT.isBC) or (b == "-BC" and MRT.isBC and not MRT.isLK) or (b == "-LK" and MRT.isLK and not MRT.isCata) or (b == "-Cata" and MRT.isCata) or (b == "-MoP" and MRT.isMoP) or (b == "-LK" and MRT.isCata and tonumber(a:match("%d+") or "4841")<=4840) or (b == "-Cata" and MRT.isMoP and tonumber(a:match("%d+") or "5181")<=5180) or ((b ~= "-Classic" and b ~= "-BC" and b ~= "-LK" and b ~= "-Cata" and b ~= "-MoP") and not MRT.isClassic) then
			return a
		else
			return ""
		end
	end)
	local isFind
	text = text:gsub("^[ \t\n]*","|cff99ff99"):gsub("v%.(%d+)",function(ver)
		if not isFind and ver ~= tostring(MRT.V) then
			isFind = true
			return "|rv."..ver
		end
	end)
	if #text > 8192 then
		local lennow = 0
		local texts = {""}
		local c = 1
		for w in string.gmatch(text,"[^\n]+\n*") do
			lennow = lennow + #w
			if lennow > 8192 then
				c = c + 1
				texts[c] = ""
				lennow = #w
			end
			texts[c] = texts[c] .. w
		end
		for i=2,c do
			self["Text"..i] = ELib:Text(self.C,texts[i],12):Point("LEFT",3,0):Point("RIGHT",-3,0):Point("TOP",self["Text"..(i-1)] or self.Text,"BOTTOM",0,0):Left():Color(1,1,1)
		end
		text = texts[1]
	end
	self.Text:SetText(text)
	self:Height(self.Text:GetStringHeight()+50)
	self:OnShow(function()
		local height = 6 + self.Text:GetStringHeight()
		local c = 2
		while self["Text"..c] do
			height = height + self["Text"..c]:GetStringHeight()
			c = c + 1
		end
		self:Height(height)
		self:OnShow()
	end,true)
end,true)
ELib:Border(OptionsFrame.Changelog,0)

ELib:DecorationLine(OptionsFrame):Point("BOTTOM",OptionsFrame.Changelog,"TOP",0,0):Point("LEFT",OptionsFrame):Point("RIGHT",OptionsFrame):Size(0,1)
ELib:DecorationLine(OptionsFrame):Point("TOP",OptionsFrame.Changelog,"BOTTOM",0,0):Point("LEFT",OptionsFrame):Point("RIGHT",OptionsFrame):Size(0,1)

OptionsFrame.Changelog.Text = ELib:Text(OptionsFrame.Changelog.C,"",12):Point("TOPLEFT",3,-3):Point("TOPRIGHT",-3,-3):Left():Color(1,1,1)
OptionsFrame.Changelog.Header = ELib:Text(OptionsFrame.Changelog,"Changelog",12):Point("BOTTOMLEFT",OptionsFrame.Changelog,"TOPLEFT",0,2):Left()

local VersionCheckReqSended = {}
local function UpdateVersionCheck()
	OptionsFrame.VersionUpdateButton:Enable()
	local list = OptionsFrame.VersionCheck.L
	wipe(list)
	
	for _, name, _, class in MRT.F.IterateRoster do
		list[#list + 1] = {
			"|c"..MRT.F.classColor(class or "?")..name,
			0,
			name,
		}
	end
	
	for i=1,#list do
		local name = list[i][3]
		
		local ver = MRT.RaidVersions[name]
		if not ver and not name:find("%-") then
			for long_name,v in pairs(MRT.RaidVersions) do
				if long_name:find("^"..name) then
					ver = v
					break
				end
			end
		end
		if not ver then
			if VersionCheckReqSended[name] then
				if not UnitIsConnected(name) then
					ver = "|cff888888offline"
				else
					ver = "|cffff8888no addon"
				end
			else
				ver = "???"
			end
		elseif not tonumber(ver) then
		
		elseif tonumber(ver) >= MRT.V then
			ver = "|cff88ff88"..ver
		else
			ver = "|cffffff88"..ver
		end
		
		list[i][2] = ver
	end
	
	sort(list,function(a,b) return a[3]<b[3] end)
	OptionsFrame.VersionCheck:Update()
end

OptionsFrame.VersionCheck = ELib:ScrollTableList(OptionsFrame,0,130):Point("TOPLEFT",OptionsFrame.Changelog,"BOTTOMLEFT",0,-3):Size(350,115):HideBorders():OnShow(UpdateVersionCheck,true)
OptionsFrame.VersionUpdateButton = ELib:Button(OptionsFrame,UPDATE):Point("BOTTOMLEFT",OptionsFrame.VersionCheck,"BOTTOMRIGHT",10,3):Size(100,20):Tooltip(L.OptionsUpdateVerTooltip):OnClick(function()
	MRT.F.SendExMsg("needversion","")
	C_Timer.After(2,UpdateVersionCheck)
	for _, name in MRT.F.IterateRoster do
		VersionCheckReqSended[name]=true
	end
	local list = OptionsFrame.VersionCheck.L
	for i=1,#list do
		list[i][2] = "..."
	end
	OptionsFrame.VersionCheck:Update()
	OptionsFrame.VersionUpdateButton:Disable()
end)

local function CreateDataBrokerPlugin()
	local dataObject = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(GlobalAddonName, {
		type = 'launcher',
		icon = "Interface\\AddOns\\"..GlobalAddonName.."\\media\\MiniMap",
		OnClick = MiniMapIconOnClick,
	})
end
CreateDataBrokerPlugin()
