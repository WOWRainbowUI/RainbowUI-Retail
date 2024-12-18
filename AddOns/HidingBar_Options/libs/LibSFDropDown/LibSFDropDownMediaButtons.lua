local lsfdd = LibStub("LibSFDropDown-1.5")
local cur_ver, ver = lsfdd._mbv, 6
if cur_ver and cur_ver >= ver then return end
lsfdd._mbv = ver
local menu1 = lsfdd:GetMenu(1)
local libMethods = lsfdd._m.__index


if not menu1.mediaBackdropFrame then
	menu1.mediaBackdropFrame = CreateFrame("FRAME", nil, menu1, "BackdropTemplate")
	menu1.mediaBackdropFrame:Hide()
	menu1.mediaBackdropFrame:SetAllPoints()
	menu1.mediaBackdropFrame:SetScript("OnHide", function(self) self:Hide() end)


	function menu1.mediaBackdropFrame:setBackdrop(btn, backdrop)
		if btn.value == "None" then
			menu1.activeStyle:Show()
			self:Hide()
			return
		end
		menu1.activeStyle:Hide()
		self:SetBackdrop(backdrop)
		self:Show()
	end
end


local function media_setSelected(btn, ddBtn)
	ddBtn:ddSetSelectedValue(btn.value)
	if ddBtn.ddOnSelectedFunc then ddBtn.ddOnSelectedFunc(btn.value) end
end


local function media_setOnSelectedFunc(self, func)
	if type(func) == "function" then self.ddOnSelectedFunc = func end
end


local function selectedValueHook(self, value)
	self:ddSetSelectedText(value)
end


-- BACKGROUND
do
	local function onEnter(btn, ddBtn)
		menu1.mediaBackdropFrame:setBackdrop(btn, {bgFile = ddBtn.media:Fetch("background", btn.value)})
	end


	local function initFunc(self)
		local info = {list = {}}
		for i, name in ipairs(self.media:List("background")) do
			info.list[#info.list + 1] = {
				text = name,
				value = name,
				arg1 = self,
				func = media_setSelected,
				OnEnter = onEnter,
			}
		end
		self:ddAddButton(info)
	end


	local function mediaBackgroundInit(btn)
		btn.media = LibStub("LibSharedMedia-3.0")
		btn:ddSetInitFunc(initFunc)
		btn.ddSetOnSelectedFunc = media_setOnSelectedFunc
		hooksecurefunc(btn, "ddSetSelectedValue", selectedValueHook)
		return btn
	end


	function libMethods:CreateMediaBackgroundButtonOriginal(...)
		self.CreateMediaBackgroundButtonOriginal = nil

		local btn = self:CreateButtonOriginal(...)
		return mediaBackgroundInit(btn)
	end


	function libMethods:CreateMediaBackgroundButton(...)
		local btn = self:CreateButton(...)
		return mediaBackgroundInit(btn)
	end


	function libMethods:CreateMediaBackgroundModernButtonOriginal(...)
		self.CreateMediaBackgroundModernButtonOriginal = nil

		local btn = self:CreateModernButtonOriginal(...)
		return mediaBackgroundInit(btn)
	end


	function libMethods:CreateMediaBackgroundModernButton(...)
		local btn = self:CreateModernButton(...)
		return mediaBackgroundInit(btn)
	end
end


-- BORDER
do
	local function onEnter(btn, ddBtn)
		menu1.mediaBackdropFrame:setBackdrop(btn, {
			edgeFile = ddBtn.media:Fetch("border", btn.value),
			bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]],
			tile = true, tileSize = 16, edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
	end


	local function initFunc(self)
		local info = {list = {}}
		for i, name in ipairs(self.media:List("border")) do
			info.list[#info.list + 1] = {
				text = name,
				value = name,
				arg1 = self,
				func = media_setSelected,
				OnEnter = onEnter,
			}
		end
		self:ddAddButton(info)
	end


	local function mediaBorderInit(btn)
		btn.media = LibStub("LibSharedMedia-3.0")
		btn:ddSetInitFunc(initFunc)
		btn.ddSetOnSelectedFunc = media_setOnSelectedFunc
		hooksecurefunc(btn, "ddSetSelectedValue", selectedValueHook)
		return btn
	end


	function libMethods:CreateMediaBorderButtonOriginal(...)
		self.CreateMediaBorderButtonOriginal = nil

		local btn = self:CreateButtonOriginal(...)
		return mediaBorderInit(btn)
	end


	function libMethods:CreateMediaBorderButton(...)
		local btn = self:CreateButton(...)
		return mediaBorderInit(btn)
	end


	function libMethods:CreateMediaBorderModernButtonOriginal(...)
		self.CreateMediaBorderModernButtonOriginal = nil

		local btn = self:CreateModernButtonOriginal(...)
		return mediaBorderInit(btn)
	end


	function libMethods:CreateMediaBorderModernButton(...)
		local btn = self:CreateModernButton(...)
		return mediaBorderInit(btn)
	end
end


-- STATUSBAR
do
	local lang, fontObject = GetLocale()
	if lang == "zhTW" or lang == "zhCN" then
		fontObject = GameFontHighlightOutline
	else
		fontObject = Game10Font_o1
	end


	local function initFunc(self)
		local info = {list = {}}
		local iconInfo = {
			tSizeX = 0,
			tSizeY = lsfdd._v.dropDownMenuButtonHeight - 2,
		}
		local statusbars = self.media:HashTable("statusbar")
		for i, name in ipairs(self.media:List("statusbar")) do
			info.list[#info.list + 1] = {
				text = name,
				value = name,
				fontObject = fontObject,
				icon = statusbars[name],
				iconOnly = true,
				iconInfo = iconInfo,
				arg1 = self,
				func = media_setSelected,
			}
		end
		self:ddAddButton(info)
	end


	local function selectedvalueStatusbarHook(self, value)
		local icon = self.media:Fetch("statusbar", value)
		local iconInfo = {
			tSizeX = 0,
			tSizeY = self.ddTSizeY or 14,
		}
		self:ddSetSelectedText(value, icon, iconInfo, true, fontObject)
	end


	local function mediaStatusbarInit(btn)
		btn.media = LibStub("LibSharedMedia-3.0")
		btn:ddSetMinMenuWidth(280)
		btn:ddSetInitFunc(initFunc)
		btn.ddSetOnSelectedFunc = media_setOnSelectedFunc
		hooksecurefunc(btn, "ddSetSelectedValue", selectedvalueStatusbarHook)
		return btn
	end


	function libMethods:CreateMediaStatusbarButtonOriginal(...)
		self.CreateMediaStatusbarButtonOriginal = nil

		local btn = self:CreateButtonOriginal(...)
		return mediaStatusbarInit(btn)
	end


	function libMethods:CreateMediaStatusbarButton(...)
		local btn = self:CreateButton(...)
		return mediaStatusbarInit(btn)
	end


	function libMethods:CreateMediaStatusbarModernButtonOriginal(...)
		self.CreateMediaStatusbarModernButtonOriginal = nil

		local btn = self:CreateModernButtonOriginal(...)
		btn.ddTSizeY = 19
		return mediaStatusbarInit(btn)
	end


	function libMethods:CreateMediaStatusbarModernButton(...)
		local btn = self:CreateModernButton(...)
		btn.ddTSizeY = 19
		return mediaStatusbarInit(btn)
	end
end


-- FONT
do
	local function initFunc(self)
		local info = {list = {}}
		local fonts = self.media:HashTable("font")
		for i, name in ipairs(self.media:List("font")) do
			info.list[#info.list + 1] = {
				text = name,
				value = name,
				fontObject = GameFontHighlightLeft,
				font = fonts[name],
				arg1 = self,
				func = media_setSelected,
			}
		end
		self:ddAddButton(info)
	end


	local function selectedValueFontHook(self, value)
		self:ddSetSelectedText(value, nil, nil, nil, nil, self.media:Fetch("font", value))
	end


	local function mediaFontInit(btn)
		btn.media = LibStub("LibSharedMedia-3.0")
		btn:ddSetInitFunc(initFunc)
		btn.ddSetOnSelectedFunc = media_setOnSelectedFunc
		hooksecurefunc(btn, "ddSetSelectedValue", selectedValueFontHook)
		return btn
	end


	function libMethods:CreateMediaFontButtonOriginal(...)
		self.CreateMediaFontButtonOriginal = nil

		local btn = self:CreateButtonOriginal(...)
		return mediaFontInit(btn)
	end


	function libMethods:CreateMediaFontButton(...)
		local btn = self:CreateButton(...)
		return mediaFontInit(btn)
	end


	function libMethods:CreateMediaFontModernButtonOriginal(...)
		self.CreateMediaFontModernButtonOriginal = nil

		local btn = self:CreateModernButtonOriginal(...)
		return mediaFontInit(btn)
	end


	function libMethods:CreateMediaFontModernButton(...)
		local btn = self:CreateModernButton(...)
		return mediaFontInit(btn)
	end
end


-- SOUND
do
	local function sound_OnClick(btn, ddBtn)
		PlaySoundFile(ddBtn.media:Fetch("sound", btn.value), "Master")
	end


	local function initFunc(self)
		local info = {list = {}}
		local widgets = {
			{
				icon = "Interface/Common/VoiceChat-Speaker",
				OnClick = sound_OnClick,
			}
		}
		for i, name in ipairs(self.media:List("sound")) do
			info.list[#info.list + 1] = {
				text = name,
				value = name,
				arg1 = self,
				func = media_setSelected,
				widgets = widgets
			}
		end
		self:ddAddButton(info)
	end


	local function mediaSoundInit(btn)
		btn.media = LibStub("LibSharedMedia-3.0")
		btn:ddSetInitFunc(initFunc)
		btn.ddSetOnSelectedFunc = media_setOnSelectedFunc
		hooksecurefunc(btn, "ddSetSelectedValue", selectedValueHook)
		return btn
	end


	function libMethods:CreateMediaSoundButtonOriginal(...)
		self.CreateMediaSoundButtonOriginal = nil

		local btn = self:CreateButtonOriginal(...)
		return mediaSoundInit(btn)
	end


	function libMethods:CreateMediaSoundButton(...)
		local btn = self:CreateButton(...)
		return mediaSoundInit(btn)
	end


	function libMethods:CreateMediaSoundModernButtonOriginal(...)
		self.CreateMediaSoundModernButtonOriginal = nil

		local btn = self:CreateModernButtonOriginal(...)
		return mediaSoundInit(btn)
	end


	function libMethods:CreateMediaSoundModernButton(...)
		local btn = self:CreateModernButton(...)
		return mediaSoundInit(btn)
	end
end