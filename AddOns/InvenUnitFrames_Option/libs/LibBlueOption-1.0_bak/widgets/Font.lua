local widget, version = "Font", 2
local LBO = LibStub("LibBlueOption-1.0")
if not LBO:NewWidget(widget, version) then return end

local SM = LibStub("LibSharedMedia-3.0", true)

local _G = _G
local type = _G.type
local CreateFrame = _G.CreateFrame
local menu = LibBlueOption10FontMenu or nil
local file, size, attribute, shadow, fixSize

local function getfuncvalue(func, ...)
	if type(func) == "function" then
		return func(...)
	else
		return func
	end
end

local function hide(self)
	if menu then
		if not self or menu.parent == self or menu.parent == self:GetParent() then
			menu:SetMenu(nil)
			return true
		end
	end
	return nil
end

local function getFontFile(file)
	if file and SM.MediaTable.font[file] then
		return file
	else
		return SM.DefaultMedia.font
	end
end

local function update(self)
	if self and self.GetValue then
		file, size, attribute, shadow, fixSize = self:GetValue()
		file = getFontFile(file)
		self.text:SetFont(SM:Fetch("font", file), 12, attribute or "")
		if shadow then
			self.text:SetShadowColor(0, 0, 0)
			self.text:SetShadowOffset(1, -1)
		else
			self.text:SetShadowOffset(0, 0)
		end
		if getfuncvalue(fixSize) then
			self.text:SetFormattedText(file)
		else
			self.text:SetFormattedText("%s, %d", file, size or 12)
		end
	end
end

local function createFontFrame()
	if not menu then
		menu = LBO:CreateDropDownMenu(widget, "DIALOG")
		menu:SetWidth(150)
		menu:SetHeight(230)
		menu.attributeList = { "없음", "외곽선", "굵은 외곽선", "예리하게", "예리한 외곽선", "예리한 굵은 외곽선" }
		menu.attributeSet = {
			["외곽선"] = "OUTLINE",
			["OUTLINE"] = "외곽선",
			["굵은 외곽선"] = "THICKOUTLINE",
			["THICKOUTLINE"] = "굵은 외곽선",
			["예리하게"] = "MONOCHROME",
			["MONOCHROME"] = "예리하게",
			["예리한 외곽선"] = "OUTLINE,MONOCHROME",
			["OUTLINE,MONOCHROME"] = "예리한 외곽선",
			["예리한 굵은 외곽선"] = "THICKOUTLINE,MONOCHROME",
			["THICKOUTLINE,MONOCHROME"] = "예리한 굵은 외곽선",
		}
		menu.info = {}
		local function hidden(key)
			if menu:IsVisible() and menu.parent and type(menu.parent.set) == "function" then
				if key == "size" then
					if getfuncvalue(menu.info.fixSize) then
						menu.fontAttribute:ClearAllPoints()
						menu.fontAttribute:SetPoint("TOP", menu.fontFile, "BOTTOM", 0, -5)
						menu:SetHeight(181)
						return true
					else
						menu.fontAttribute:ClearAllPoints()
						menu.fontAttribute:SetPoint("TOP", menu.fontSize, "BOTTOM", 0, -5)
						menu:SetHeight(230)
						return nil
					end
				else
					return nil
				end
			end
			return true
		end
		local function set(v, key)
			if key == "file" or key == "size" or key == "shadow" then
				menu.info[key] = v
			elseif key == "attribute" then
				menu.info[key] = menu.attributeSet[v] or nil
			else
				return
			end
			menu.parent.set(
				menu.info.file,
				menu.info.size,
				menu.info.attribute,
				menu.info.shadow,
				menu.parent.arg1,
				menu.parent.arg2,
				menu.parent.arg3
			)
			update(menu.parent)
		end
		menu.fontFile = LBO:CreateWidget("Media", menu, "글꼴", "글꼴 모양을 설정합니다.", hidden, nil, nil, function() return menu.info.file, "font" end, set, "file")
		menu.fontFile:SetWidth(120)
		menu.fontFile:SetPoint("TOP", 0, -15)
		menu.fontSize = LBO:CreateWidget("Slider", menu, "크기", "글꼴 크기를 설정합니다.", hidden, nil, nil, function() return menu.info.size, 7, 34, 1, "포인트" end, set, "size")
		menu.fontSize:SetWidth(120)
		menu.fontSize:SetPoint("TOP", menu.fontFile, "BOTTOM", 0, -5)
		menu.fontAttribute = LBO:CreateWidget("DropDown", menu, "속성", "글꼴 속성을 설정합니다.", hidden, nil, nil, function() return menu.attributeSet[menu.info.attribute or ""] or "없음", menu.attributeList end, set, "attribute")
		menu.fontAttribute:SetWidth(120)
		menu.fontAttribute:SetPoint("TOP", menu.fontSize, "BOTTOM", 0, -5)
		menu.fontShadow = LBO:CreateWidget("CheckBox", menu, "그림자", "글꼴의 그림자를 설정합니다.", hidden, nil, nil, function() return menu.info.shadow end, set, "shadow")
		menu.fontShadow:SetWidth(120)
		menu.fontShadow:SetPoint("TOP", menu.fontAttribute, "BOTTOM", 0, 0)
		menu.fontOkay = LBO:CreateWidget("Button", menu, OKAY, nil, hidden, nil, nil,
			function()
				menu:SetMenu(nil)
				LBO:Refresh()
			end
		)
		menu.fontOkay:SetPoint("BOTTOMLEFT", 10, 0)
		menu.fontOkay:SetPoint("BOTTOMRIGHT", menu, "BOTTOM", 0.5, 0)
		menu.fontCancel = LBO:CreateWidget("Button", menu, CANCEL, nil, hidden, nil, nil, function()
			if menu.info.file ~= menu.info.prev_file or menu.info.size ~= menu.info.prev_size or menu.info.attribute ~= menu.info.prev_attribute or menu.info.prev_shadow ~= menu.info.shadow then
				menu.parent.set(
					menu.info.prev_file,
					menu.info.prev_size,
					menu.info.prev_attribute,
					menu.info.prev_shadow,
					menu.parent.arg1,
					menu.parent.arg2,
					menu.parent.arg3
				)
				LBO:Refresh()
			end
			menu:SetMenu(nil)
		end)
		menu.fontCancel:SetPoint("BOTTOMLEFT", menu, "BOTTOM", -0.5, 0)
		menu.fontCancel:SetPoint("BOTTOMRIGHT", -10, 0)
	end
end

local function click(self)
	if hide(self) then
		return nil
	else
		createFontFrame()
		file, size, menu.info.attribute, shadow, menu.info.fixSize = self:GetValue()
		menu:SetMenu(self)
		menu.info.file = getFontFile(file)
		menu.info.size = size or 12
		menu.info.shadow = shadow and true or nil
		menu.info.prev_file = menu.info.file
		menu.info.prev_size = menu.info.size
		menu.info.prev_attribute = menu.info.attribute
		menu.info.prev_shadow = menu.info.shadow
		menu:Show()
		return true
	end
end

LBO:RegisterWidget(widget, version, function(self, name)
	LBO:CreateDropDown(self, true, click)
	self.Setup = update
end)