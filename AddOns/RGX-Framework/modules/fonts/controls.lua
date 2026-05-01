local _, addon = ...
local Fonts = addon._fontsModule
local RGX = _G.RGXFramework

function Fonts:CreateFontSettingControl(parent, opts)
	opts = opts or {}
	parent = parent or UIParent

	local holder = CreateFrame("Frame", nil, parent)
	holder:SetSize(opts.width or 250, opts.height or 56)

	local storage = opts.storage
	local key = opts.key
	local defaultName = self:ResolveName(opts.defaultName or opts.defaultPath, self:GetDefault()) or self:GetDefault()
	local defaultPath = self:ResolvePath(opts.defaultPath or defaultName, defaultName)

	local function resolveCurrentName()
		if storage and key and type(storage[key]) == "string" then
			return self:ResolveName(storage[key], opts.value or defaultName) or defaultName
		end

		return self:ResolveName(opts.value, defaultName) or defaultName
	end

	local dropdown = self:CreateFontDropdown(holder, {
		label = opts.label or "Font",
		width = opts.dropdownWidth or (opts.width or 250) - (opts.showReset == false and 0 or 28),
		height = opts.dropdownHeight or 56,
		buttonWidth = opts.buttonWidth or 180,
		value = resolveCurrentName(),
		onChange = function(fontName, fontPath)
			holder.value = fontName
			holder.path = fontPath

			if storage and key then
				storage[key] = fontPath
			end

			if type(opts.onChange) == "function" then
				opts.onChange(holder, fontName, fontPath)
			end
		end,
	})
	if not dropdown then
		local label = holder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		label:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, -2)
		label:SetWidth(opts.width or 250)
		label:SetJustifyH("LEFT")
		label:SetText("|cffff5555Font dropdown unavailable.|r")
		holder.label = label
		return holder
	end
	dropdown:SetPoint("TOPLEFT", holder, "TOPLEFT", 0, 0)
	holder.dropdown = dropdown

	local reset = nil
	if opts.showReset ~= false then
		reset = CreateFrame("Button", nil, holder)
		reset:SetSize(opts.resetWidth or 22, opts.resetHeight or 18)
		reset:SetPoint("TOPLEFT", dropdown, "TOPRIGHT", -2, -18)
		reset.bg = reset:CreateTexture(nil, "BACKGROUND")
		reset.bg:SetAllPoints()
		reset.bg:SetColorTexture(0.08, 0.08, 0.08, 0.90)
		reset.border = reset:CreateTexture(nil, "BORDER")
		reset.border:SetAllPoints()
		reset.border:SetColorTexture(0.30, 0.30, 0.30, 0.85)
		reset.text = reset:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		reset.text:SetPoint("CENTER", reset, "CENTER", 0, 0)
		reset.text:SetText(opts.resetText or "R")
		reset:SetScript("OnEnter", function()
			reset.bg:SetColorTexture(0.14, 0.14, 0.14, 0.95)
		end)
		reset:SetScript("OnLeave", function()
			reset.bg:SetColorTexture(0.08, 0.08, 0.08, 0.90)
		end)
		holder.reset = reset
	end

	function holder:GetValue()
		return self.value
	end

	function holder:GetPath()
		return self.path or self:GetDefaultPath()
	end

	function holder:GetDefaultName()
		return defaultName
	end

	function holder:GetDefaultPath()
		return defaultPath
	end

	function holder:SetValue(fontName)
		fontName = Fonts:ResolveName(fontName, defaultName) or defaultName
		self.value = fontName
		self.path = Fonts:GetPath(fontName)
		if storage and key then
			storage[key] = self.path
		end
		if self.dropdown and self.dropdown.Refresh then
			self.dropdown:Refresh(fontName)
		end
	end

	function holder:SetPath(fontPath)
		self:SetValue(Fonts:ResolveName(fontPath, defaultName) or defaultName)
	end

	function holder:Reset()
		self:SetValue(defaultName)
		if type(opts.onReset) == "function" then
			opts.onReset(self, self.value, self.path)
		end
		if type(opts.onChange) == "function" then
			opts.onChange(self, self.value, self.path)
		end
	end

	function holder:SetEnabled(enabled)
		local isEnabled = enabled ~= false
		if self.dropdown and type(self.dropdown.SetEnabled) == "function" then
			self.dropdown:SetEnabled(isEnabled)
		elseif self.dropdown and self.dropdown.label then
			self.dropdown.label:SetAlpha(isEnabled and 1 or 0.6)
		end
		if self.dropdown and self.dropdown.dropdown then
			Fonts:_SafeDropdownDisable(self.dropdown.dropdown)
			if isEnabled then
				Fonts:_SafeDropdownEnable(self.dropdown.dropdown)
			end
			self.dropdown.dropdown:SetAlpha(isEnabled and 1 or 0.45)
		end
		if self.reset then
			self.reset:SetEnabled(isEnabled)
			self.reset:SetAlpha(isEnabled and 1 or 0.45)
		end
	end

	holder:SetValue(resolveCurrentName())

	if reset then
		reset:SetScript("OnClick", function()
			holder:Reset()
		end)
	end

	return holder
end

function Fonts:_EnsureBindingTable(db, key, fallback)
	if type(db) ~= "table" or type(key) ~= "string" or key == "" then
		return nil
	end

	if db[key] == nil and fallback ~= nil then
		db[key] = RGX:CopyTable(fallback)
	end

	return db[key]
end

function Fonts:AttachFontSelector(parent, db, key, opts)
	opts = opts or {}
	if type(db) ~= "table" or type(key) ~= "string" or key == "" then
		RGX:Debug("Fonts: AttachFontSelector requires db table and key")
		return nil
	end

	local current = self:ResolveName(db[key], opts.value or self:GetDefault()) or self:GetDefault()
	db[key] = current

	local selector = self:CreateSimpleFontSelector(parent, {
		label = opts.label or "Font",
		value = current,
		width = opts.width,
		height = opts.height,
		buttonWidth = opts.buttonWidth,
		onChange = function(fontName, path)
			db[key] = fontName
			if type(opts.onChange) == "function" then
				opts.onChange(fontName, path, db)
			end
		end,
	})

	selector.DB = db
	selector.DBKey = key

	function selector:RefreshFromDB()
		local value = Fonts:ResolveName(self.DB[self.DBKey], Fonts:GetDefault()) or Fonts:GetDefault()
		self.DB[self.DBKey] = value
		self:Refresh(value)
	end

	selector:RefreshFromDB()
	return selector
end

function Fonts:GetOptionValues()
	local values = {}
	for _, info in ipairs(self:ListAvailable()) do
		values[info.name] = info.displayName or info.family or info.name
	end
	return values
end
