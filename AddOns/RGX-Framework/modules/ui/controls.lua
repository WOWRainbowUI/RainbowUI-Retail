--[[
    RGX-Framework - UI Controls
    
    Shared UI components for RGX addons.
    
    Usage:
        local UI = RGX:GetModule("ui")
        
        -- Color picker
        UI:CreateColorPicker(parent, {
            key = "textColor",
            label = "Text Color",
            default = {r=1, g=1, b=1}
        })
        
        -- Slider
        UI:CreateSlider(parent, {
            key = "scale",
            label = "Scale",
            min = 0.5,
            max = 2,
            step = 0.1,
            default = 1
        })
        
        -- Toggle
        UI:CreateToggle(parent, {
            key = "enabled",
            label = "Enable",
            default = true
        })
--]]

local _, UI = ...
local RGX = _G.RGXFramework

if not RGX then
    error("RGX UI: RGX-Framework not loaded")
    return
end

UI.name = "ui"
UI.version = "1.0.0"

-- Control registry
UI.controls = {}
UI.backdrop = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false,
    edgeSize = 1,
    insets = {left = 0, right = 0, top = 0, bottom = 0}
}

-- Apply the framework default font to a label, preserving size/flags.
local function ApplyDefaultFont(fs)
    local Fonts = _G.RGXFonts
    if not (Fonts and type(Fonts.Apply) == "function" and type(Fonts.GetDefault) == "function") then return end
    if not (fs and fs.GetFont) then return end
    local _, size, flags = fs:GetFont()
    pcall(Fonts.Apply, Fonts, fs, Fonts:GetDefault(), size, flags)
end

function UI:CreateStatusBarDropdown(parent, options)
    options = options or {}

    local Textures = RGX:GetModule("textures")
    if not Textures or type(Textures.CreateBarSettingControl) ~= "function" then
        return self:CreateLabel(parent, {text = "RGX Textures not loaded", color = "red"})
    end

    return Textures:CreateBarSettingControl(parent, options)
end

UI.CreateTextureDropdown = UI.CreateStatusBarDropdown

--[[============================================================================
    COLOR PICKER CONTROL
============================================================================]]

-- Embeddable color-picker card: the full SV-box + hue-bar picker inline in an
-- options tab (not the popup swatch), bound to storage[key] = {r,g,b}. Returns
-- the widget frame (with :SetColor/:GetColor), or a label if the module is
-- missing. See ColorPicker:CreateEmbedded for opts.
function UI:CreateColorPickerCard(parent, options)
    local CP = RGX:GetColorPicker()
    if not CP or not CP.CreateEmbedded then
        local LocaleMod = RGX:GetModule("locale")
        local LL = (LocaleMod and LocaleMod.L) or {}
        return self:CreateLabel(parent, { text = LL["UI_COLORPICKER_NOT_LOADED"] or "RGX ColorPicker not loaded", color = "red" })
    end
    return CP:CreateEmbedded(parent, options or {})
end

function UI:CreateColorPicker(parent, options)
    options = options or {}
    local LocaleMod = RGX:GetModule("locale")
    local LL = (LocaleMod and LocaleMod.L) or {}
    local key = options.key or "color"
    local label = options.label or LL["UI_COLOR_DEFAULT_LABEL"] or "Color"
    local default = options.default or {r=1, g=1, b=1}
    local storage = options.storage or {}
    local onChange = options.onChange or function() end
    local previewOnClick = options.previewOnClick  -- Function to call when clicking swatch
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200, 24)
    
    -- Label
    container.label = self:CreateLabel(container, {
        text = label,
		size = "normal",
        color = "muted"
    })
    container.label:SetPoint("LEFT", 0, 0)
    
    -- Color swatch button
    local swatch = CreateFrame("Button", nil, container)
    swatch:SetSize(20, 20)
    swatch:SetPoint("LEFT", container.label, "RIGHT", 10, 0)
    
    swatch.bg = swatch:CreateTexture(nil, "BACKGROUND")
    swatch.bg:SetAllPoints()
    swatch.bg:SetColorTexture(0, 0, 0, 1)
    
    swatch.tex = swatch:CreateTexture(nil, "ARTWORK")
    swatch.tex:SetSize(16, 16)
    swatch.tex:SetPoint("CENTER")
    
    -- Set initial color
    local currentColor = storage[key] or default
    swatch.tex:SetColorTexture(currentColor.r or 1, currentColor.g or 1, currentColor.b or 1, 1)
    
    swatch:SetScript("OnClick", function()
        -- Call preview function if provided (shows preview of what we're editing)
        if previewOnClick then
            previewOnClick()
        end
        
        local ColorPicker = RGX:GetModule("colorpicker")
        if ColorPicker then
            ColorPicker:Show({
                r = currentColor.r or 1,
                g = currentColor.g or 1,
                b = currentColor.b or 1
            }, function(r, g, b)
                currentColor = {r=r, g=g, b=b}
                storage[key] = currentColor
                swatch.tex:SetColorTexture(r, g, b, 1)
                onChange(r, g, b)
            end)
        else
            -- Fallback to Blizzard color picker
            local r, g, b = currentColor.r or 1, currentColor.g or 1, currentColor.b or 1
            ColorPickerFrame:SetupColorPickerAndShow({
                r = r, g = g, b = b,
                swatchFunc = function()
                    local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                    currentColor = {r=nr, g=ng, b=nb}
                    storage[key] = currentColor
                    swatch.tex:SetColorTexture(nr, ng, nb, 1)
                    onChange(nr, ng, nb)
                end
            })
        end
    end)
    
    -- Reset button
    local reset = self:CreateResetButton(container, function()
        -- default is a keyed {r,g,b} table, not an array -- unpack(default)
        -- returns nothing on a keyed table, so this silently reset storage[key]
        -- to an empty table instead of the default color.
        currentColor = { r = default.r or 1, g = default.g or 1, b = default.b or 1 }
        storage[key] = currentColor
        swatch.tex:SetColorTexture(currentColor.r, currentColor.g, currentColor.b, 1)
        onChange(currentColor.r, currentColor.g, currentColor.b)
    end)
    reset:SetPoint("LEFT", swatch, "RIGHT", 8, 0)
    
    container.swatch = swatch
    return container
end

--[[============================================================================
SLIDER CONTROL

Custom track-style slider using RGX brand colors.
- Drag, click, or scroll to change value
- Value label appears on hover
- Reset button snaps to default

Usage:
	UI:CreateSlider(parent, {
		key = "scale",
		label = "Scale",
		min = 0.5,
		max = 2,
		step = 0.1,
		default = 1,
		storage = myDB,
		suffix = "%",
		onChange = function(value) end,
		width = 200,
		progress = true,   -- optional; false hides the fill behind the thumb
	})
============================================================================]]

function UI:CreateSlider(parent, options)
	options = options or {}
	local LocaleMod = RGX:GetModule("locale")
	local LL = (LocaleMod and LocaleMod.L) or {}
	local key = options.key or "value"
	local label = options.label or LL["UI_SLIDER_DEFAULT_LABEL"] or "Slider"
	local min = options.min or 0
	local max = options.max or 100
	local step = options.step or 1
	local default = options.default or min
	local storage = options.storage or {}
	local suffix = options.suffix or ""
	local onChange = options.onChange or function() end
	local sliderWidth = options.width or 200
	local valueDisplay = options.valueDisplay or "always"
	assert(valueDisplay == "always" or valueDisplay == "hover" or valueDisplay == "none",
		"RGX UI: slider valueDisplay must be always, hover, or none")
	-- progress: show the brand-colored fill behind the thumb. Defaults on so
	-- existing sliders are unchanged; pass progress = false for a bare track
	-- (some panels want the thumb without a running fill).
	local showProgress = options.progress
	if showProgress == nil then showProgress = true end

	local D = RGX:GetDesign()

	local container = CreateFrame("Frame", nil, parent)
	container:SetSize(sliderWidth + 32, 38)

	-- Static label above the track is the default. opts.noLabel drops it and
	-- the label moves into the track hover tooltip instead ("label: value").
	local hasLabel = options.noLabel ~= true
	if hasLabel then
		container.label = self:CreateLabel(container, {
			text = label,
			size = "normal",
			color = "muted"
		})
		container.label:SetPoint("TOPLEFT", 0, 0)
	end

	container.valueLabel = self:CreateLabel(container, {
		text = (storage[key] or default) .. suffix,
		size = "normal"
	})
	container.valueLabel:SetPoint("TOPRIGHT", -28, 0)
	if valueDisplay ~= "always" then container.valueLabel:Hide() end

	local trackFrame = CreateFrame("Frame", nil, container)
	trackFrame:SetPoint("TOPLEFT", container.label or container, hasLabel and "BOTTOMLEFT" or "TOPLEFT", 0, hasLabel and -4 or 0)
	trackFrame:SetPoint("TOPRIGHT", container.valueLabel, "BOTTOMRIGHT", 0, hasLabel and -4 or 0)
	trackFrame:SetHeight(18)

	local button = CreateFrame("Button", nil, trackFrame)
	button:SetAllPoints(trackFrame)
	button:SetHeight(18)

	local valueLabel = trackFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	valueLabel:SetTextColor(D:Unpack("subtext"))
	valueLabel:SetPoint("TOP", button, "BOTTOM", 0, 2)
	valueLabel:Hide()

	button:SetScript("OnEnter", function(self)
		if valueDisplay ~= "none" then valueLabel:Show() end
		if not hasLabel and GameTooltip then
			GameTooltip:SetOwner(self, "ANCHOR_TOP")
			GameTooltip:SetText(label .. ": " .. (storage[key] or default) .. suffix)
			GameTooltip:Show()
		end
	end)
	button:SetScript("OnLeave", function()
		valueLabel:Hide()
		if not hasLabel and GameTooltip then GameTooltip:Hide() end
	end)

	local track = trackFrame:CreateTexture(nil, "ARTWORK")
	track:SetHeight(4)
	track:SetPoint("LEFT", button, "LEFT", 0, 0)
	track:SetPoint("RIGHT", button, "RIGHT", 0, 0)
	track:SetPoint("CENTER", button, "CENTER", 0, 0)
	track:SetColorTexture(D:Unpack("track"))

	local fill = trackFrame:CreateTexture(nil, "ARTWORK")
	fill:SetHeight(4)
	fill:SetPoint("LEFT", track, "LEFT", 0, 0)
	fill:SetColorTexture(D:Unpack("primary"))
	if not showProgress then fill:Hide() end

	local thumb = trackFrame:CreateTexture(nil, "ARTWORK")
	thumb:SetSize(8, 8)
	thumb:SetTexture("Interface\\Buttons\\WHITE8x8")
	thumb:SetVertexColor(D:Unpack("primary"))

	local function valueToPercent(value)
		if max == min then return 0 end
		return (value - min) / (max - min)
	end

	local function percentToValue(pct)
		local raw = min + pct * (max - min)
		local snapped = math.floor(raw / step + 0.5) * step
		return math.max(min, math.min(max, snapped))
	end

	-- Position the fill/thumb from the current stored value. Returns false when
	-- the track has no width yet (frame not laid out, or built while hidden) so
	-- the caller can retry once geometry resolves.
	local function positionThumb()
		local current = storage[key] or default
		container.valueLabel:SetText(current .. suffix)
		valueLabel:SetText(current .. suffix)
		local trackWidth = track:GetWidth()
		if trackWidth < 1 then return false end
		local pct = math.max(0, math.min(1, valueToPercent(current)))
		local thumbX = trackWidth * pct
		local fillW = math.max(4, trackWidth * pct)
		if showProgress then fill:SetWidth(fillW) end
		thumb:ClearAllPoints()
		thumb:SetPoint("CENTER", track, "LEFT", thumbX, 0)
		return true
	end

	-- Retry positioning until the track has a real width. OnUpdate never fires
	-- while a frame is hidden, so a slider built on a not-yet-shown panel would
	-- otherwise stay at the wrong spot until its value changed -- the "default
	-- position wrong on login until set/reset/reload" bug. OnShow re-arms this.
	local function positionThumbDeferred()
		if positionThumb() then trackFrame:SetScript("OnUpdate", nil); return end
		trackFrame:SetScript("OnUpdate", function()
			if positionThumb() then trackFrame:SetScript("OnUpdate", nil) end
		end)
	end

	local function apply(value)
		value = math.floor(value / step + 0.5) * step
		value = math.max(min, math.min(max, value))
		storage[key] = value
		container.valueLabel:SetText(value .. suffix)
		valueLabel:SetText(value .. suffix)
		positionThumbDeferred()
		onChange(value)
	end

	local dragging = false

	button:SetScript("OnMouseDown", function(self, clickButton)
		if clickButton == "RightButton" then return end
		local cursorX = GetCursorPosition()
		local scale = self:GetEffectiveScale()
		local left = self:GetLeft() and (self:GetLeft() * scale) or 0
		local w = math.max(1, (self:GetWidth() or 1) * scale)
		local pct = math.max(0, math.min(1, (cursorX - left) / w))
		apply(percentToValue(pct))
		dragging = true
	end)

	button:SetScript("OnMouseUp", function()
		dragging = false
	end)

	button:SetScript("OnUpdate", function(self)
		if not dragging then return end
		if not IsMouseButtonDown("LeftButton") then
			dragging = false
			return
		end
		local cursorX = GetCursorPosition()
		local scale = self:GetEffectiveScale()
		local left = self:GetLeft() and (self:GetLeft() * scale) or 0
		local w = math.max(1, (self:GetWidth() or 1) * scale)
		local pct = math.max(0, math.min(1, (cursorX - left) / w))
		apply(percentToValue(pct))
	end)

	button:SetScript("OnMouseWheel", function(self, delta)
		local current = storage[key] or default
		local newVal = current + delta * step
		apply(newVal)
	end)
	button:EnableMouseWheel(true)

	local reset = self:CreateResetButton(container, function()
		apply(default)
	end)
    self:AnchorRowReset(parent, reset, trackFrame)

	-- Re-place the thumb every time the slider is shown: the first apply() below
	-- runs while the panel is usually still hidden (login/load), so this is what
	-- makes the initial position correct without needing a set/reset/reload.
	container:SetScript("OnShow", positionThumbDeferred)
	container:SetScript("OnSizeChanged", positionThumbDeferred)
	trackFrame:SetScript("OnSizeChanged", positionThumbDeferred)

	apply(storage[key] or default)

	container.SetValue = function(first, maybe)
		-- Support both control:SetValue(v) and control.SetValue(v)
		local value
		if maybe ~= nil and first == container then
			value = maybe
		elseif maybe == nil then
			value = first
		else
			value = maybe
		end
		apply(value)
	end
	container.GetValue = function() return storage[key] or default end
	container.hoverValueLabel = valueLabel
	container.button = button
	container.resetButton = reset

	return container
end

--[[============================================================================
VOLUME SLIDER CONTROL

3-position discrete slider (Low / Medium / High) using the RGX brand colors.
Click or scroll to cycle. Label appears below on hover.

Usage:
	UI:CreateVolumeSlider(parent, {
		key = "volume",
		storage = myDB,
		default = "medium",
		onChange = function(volume) end,
	})

Options:
	key      - string, storage key (default "volume")
	storage  - table, SavedVariables ref (default {})
	default  - "low"|"medium"|"high" (default "medium")
	onChange - callback(volumeString) (default noop)
	width    - number, track width (default 64)
============================================================================]]

function UI:CreateVolumeSlider(parent, options)
	options = options or {}
	local key = options.key or "volume"
	local storage = options.storage or {}
	local default = options.default or "medium"
	local onChange = options.onChange or function() end
	local width = options.width or 64

	local D = RGX:GetDesign()

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetHeight(18)

	local button = CreateFrame("Button", nil, frame)
	button:SetAllPoints(frame)
	button:SetHeight(18)

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	label:SetTextColor(D:Unpack("subtext"))
	label:SetPoint("TOP", button, "BOTTOM", 0, 2)
	label:Hide()

	button:SetScript("OnEnter", function() label:Show() end)
	button:SetScript("OnLeave", function() label:Hide() end)

	local track = frame:CreateTexture(nil, "ARTWORK")
	track:SetHeight(4)
	track:SetPoint("LEFT", button, "LEFT", 0, 0)
	track:SetPoint("RIGHT", button, "RIGHT", 0, 0)
	track:SetPoint("CENTER", button, "CENTER", 0, 0)
	track:SetColorTexture(D:Unpack("track"))

	local fill = frame:CreateTexture(nil, "ARTWORK")
	fill:SetHeight(4)
	fill:SetPoint("LEFT", track, "LEFT", 0, 0)
	fill:SetColorTexture(D:Unpack("primary"))

	local thumb = frame:CreateTexture(nil, "ARTWORK")
	thumb:SetSize(8, 8)
	thumb:SetTexture("Interface\\Buttons\\WHITE8x8")
	thumb:SetVertexColor(D:Unpack("primary"))

	local function getVolume()
		return storage[key] or default
	end

	local function setVolume(volume)
		storage[key] = volume
		onChange(volume)
	end

	local function updateVisuals()
			local volume = getVolume()
			local trackWidth = track:GetWidth()
			if trackWidth < 1 then return false end
			local pct = 0.50
			if volume == "low" then
				pct = 0.15
			elseif volume == "high" then
				pct = 0.85
			end
			local fillW = math.max(4, trackWidth * pct)
			fill:SetWidth(fillW)
			thumb:ClearAllPoints()
			thumb:SetPoint("CENTER", track, "LEFT", fillW, 0)
			label:SetText(volume:gsub("^%l", string.upper))
			return true
	end
	local function refreshVisuals()
		if not updateVisuals() then
			frame:SetScript("OnUpdate", function()
				if updateVisuals() then
					frame:SetScript("OnUpdate", nil)
				end
			end)
		else
			frame:SetScript("OnUpdate", nil)
		end
	end
	local function apply(volume)
		if volume ~= "low" and volume ~= "high" then volume = "medium" end
		setVolume(volume)
		refreshVisuals()
	end

	button:SetScript("OnMouseDown", function(self)
		local cursorX = GetCursorPosition()
		local scale = self:GetEffectiveScale()
		local left = self:GetLeft() and (self:GetLeft() * scale) or 0
		local w = math.max(1, (self:GetWidth() or 1) * scale)
		local percent = math.max(0, math.min(1, (cursorX - left) / w))
		if percent < 0.34 then
			apply("low")
		elseif percent > 0.66 then
			apply("high")
		else
			apply("medium")
		end
	end)

	button:SetScript("OnMouseWheel", function()
		local current = getVolume()
		if current == "low" then
			apply("medium")
		elseif current == "medium" then
			apply("high")
		else
			apply("low")
		end
	end)
	button:EnableMouseWheel(true)
	frame:SetScript("OnShow", refreshVisuals)
	frame:SetScript("OnSizeChanged", refreshVisuals)

	apply(getVolume())

	frame.Refresh = function()
		apply(getVolume())
	end

	return frame
end

--[[============================================================================
TOGGLE CONTROL
============================================================================]]

-- Normalize the widget API without teaching consumers removed method names.
-- Modern clients expose one combined setter; older clients used two setters.
-- Returns false when bounds cannot be applied (never reports a no-op success).
function UI:SetResizeBounds(frame, minWidth, minHeight, maxWidth, maxHeight)
    if not frame then return false end
    if type(frame.SetResizeBounds) == "function" then
        frame:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
        return true
    end
    if type(frame.SetMinResize) == "function" and type(frame.SetMaxResize) == "function"
        and maxWidth ~= nil and maxHeight ~= nil then
        frame:SetMinResize(minWidth, minHeight)
        frame:SetMaxResize(maxWidth, maxHeight)
        return true
    end
    return false
end

-- A label and 18px checkbox sharing a single layout frame. Consumers can
-- bind the check to their database or event handlers without recreating its
-- geometry, font, and artwork in each addon.
local function AttachCheckboxLabel(frame, checkbox, label)
    -- Limit the hit target to the text, not the entire row: neighboring
    -- controls remain independently clickable. Anchors track font changes.
    local target = CreateFrame("Button", nil, frame)
    target:SetPoint("TOPLEFT", label, "TOPLEFT", -4, 3)
    target:SetPoint("BOTTOMRIGHT", label, "BOTTOMRIGHT", 4, -3)
    target:SetScript("OnClick", function()
        if checkbox:IsEnabled() then checkbox:Click("LeftButton") end
    end)
    frame.labelButton = target
end

function UI:CreateCheckbox(parent, text)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(300, 20)
    local checkbox = CreateFrame("CheckButton", nil, frame)
    checkbox:SetSize(18, 18)
    checkbox:SetPoint("LEFT", 0, 0)
    checkbox:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
    checkbox:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
    checkbox:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
    checkbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
    local label = self:CreateLabel(frame, { text = text, size = "normal", color = "normal" })
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    frame.checkbox = checkbox
    frame.label = label
    AttachCheckboxLabel(frame, checkbox, label)
    return frame
end

function UI:CreateToggle(parent, options)
    options = options or {}
    local key = options.key or "enabled"
    local label = options.label or "Toggle"
    local default = options.default ~= false
    local storage = options.storage or {}
    local onChange = options.onChange or function() end
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200, 24)
    
    -- Checkbox
    local check = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
    check:SetSize(24, 24)
    check:SetPoint("LEFT", 0, 0)
    local currentValue = storage[key]
    if type(currentValue) == "nil" then currentValue = default end
    check:SetChecked(currentValue and true or false)
    
    -- Label
    container.label = self:CreateLabel(container, {
        text = label,
        size = "normal"
    })
    container.label:SetPoint("LEFT", check, "RIGHT", 4, 0)
    AttachCheckboxLabel(container, check, container.label)
    
    check:SetScript("OnClick", function(self)
        local enabled = self:GetChecked()
        storage[key] = enabled
        onChange(enabled)
    end)
    
    -- Reset
    local reset = self:CreateResetButton(container, function()
        check:SetChecked(default)
        storage[key] = default
        onChange(default)
    end)
    reset:SetPoint("LEFT", container.label, "RIGHT", 10, 0)
    
    container.check = check
    return container
end

--[[============================================================================
    LABEL
============================================================================]]

function UI:CreateLabel(parent, options)
    options = options or {}
    local text = options.text or ""
    local size = options.size or "normal"  -- small, normal, large
    local color = options.color or "normal"  -- normal, muted, accent, red, green
    local D = RGX:GetDesign()
    
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    
    -- Set font size
    if size == "small" then
        label:SetFontObject("GameFontNormalSmall")
    elseif size == "large" then
        label:SetFontObject("GameFontNormalLarge")
    else
        label:SetFontObject("GameFontNormal")
    end
    ApplyDefaultFont(label)
    
    local colorKeys = {
        normal = "text",
        muted  = "subtext",
        accent = "accent",
        red    = "error",
        green  = "success",
        yellow = "warning",
    }

    if D then
        label:SetTextColor(D:Unpack(colorKeys[color] or "text"))
    else
        label:SetTextColor(1, 1, 1)
    end
    
    label:SetText(text)

    -- Long text (descriptions, help text) needs an explicit width to wrap at
    -- -- a FontString with no width auto-sizes to fit everything on one line
    -- and silently overflows the parent frame's edge instead of breaking.
    -- Short labels ("Enable Addon", "R"/"G"/"B") should keep their natural
    -- single-line width, so wrapping is opt-in via options.width.
    if options.width then
        label:SetWidth(options.width)
        label:SetWordWrap(true)
        label:SetJustifyH(options.justify or "LEFT")
    end

    return label
end

--[[============================================================================
    RESET BUTTON
============================================================================]]

function UI:CreateResetButton(parent, onClick)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    local D = RGX:GetDesign()
    -- 24px wide: 2px transparent margin each side keeps the visual clear of adjacent controls
    btn:SetSize(24, 16)

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT",     btn, "TOPLEFT",     2,  0)
    bg:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 0)
    bg:SetColorTexture(D:Unpack("surface"))
    btn.bg = bg

    local border = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    border:SetPoint("TOPLEFT",     btn, "TOPLEFT",     2,  0)
    border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 0)
    border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    border:SetBackdropBorderColor(D:Unpack("border"))
    btn.border = border

    local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetAllPoints()
    lbl:SetJustifyH("CENTER")
    lbl:SetJustifyV("MIDDLE")
    lbl:SetText("R")
    lbl:SetTextColor(D:Unpack("subtext"))
    btn.lbl = lbl

    btn:SetScript("OnClick", onClick)
    btn:SetScript("OnEnter", function(self)
        local D = RGX:GetDesign()
        self.border:SetBackdropBorderColor(D:Unpack("primary"))
        self.bg:SetColorTexture(D:Unpack("hover"))
        self.lbl:SetTextColor(D:Unpack("primary"))
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Reset to default")
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        local D = RGX:GetDesign()
        self.border:SetBackdropBorderColor(D:Unpack("border"))
        self.bg:SetColorTexture(D:Unpack("surface"))
        self.lbl:SetTextColor(D:Unpack("subtext"))
        GameTooltip:Hide()
    end)
    return btn
end

-- Click behavior uses the options table or SetScript("OnClick"). Hover
-- behavior must compose with the skin via HookScript or table callbacks.
-- Pcall-isolated like every other shared dispatch so
-- one consumer's handler error cannot break unrelated panels.
local function AttachButtonAction(btn, onClick)
    if type(onClick) ~= "function" then return btn end
    btn:SetScript("OnClick", function(self, button)
        local ok, err = pcall(onClick, self, button)
        if not ok and RGX and type(RGX.Error) == "function" then
            RGX:Error("[RGXUI] button onClick failed: " .. tostring(err))
        end
    end)
    return btn
end

-- UI:CreateButton(parent, textOrOpts[, w][, h])
-- Legacy positional form still works; the table form is the declared
-- ergonomic surface: { text, width, height, tooltip, onClick }.
function UI:CreateButton(parent, textOrOpts, w, h)
    local opts = nil
    local text = textOrOpts
    if type(textOrOpts) == "table" then
        opts = textOrOpts
        text = opts.text
        w = opts.width or w
        h = opts.height or h
    elseif type(textOrOpts) == "function" then
        -- UI:CreateButton(parent, onClickFn) is never valid — surface it.
        text = nil
        opts = { onClick = textOrOpts }
    end
    h = h or (opts and opts.height) or 22

    local D = RGX:GetDesign()
    local btn
    if D and type(D.CreateButton) == "function" then
        btn = D:CreateButton(parent, text, w, h,
            opts and opts.tooltip, opts and opts.tooltipBody)
    else
        btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
        btn:SetSize(w or 120, h)
        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(D:Unpack("surface"))
        local border = CreateFrame("Frame", nil, btn, "BackdropTemplate")
        border:SetAllPoints()
        border:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        border:SetBackdropBorderColor(D:Unpack("border"))
        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetAllPoints()
        lbl:SetJustifyH("CENTER")
        lbl:SetJustifyV("MIDDLE")
        lbl:SetText(text or "")
        lbl:SetTextColor(D:Unpack("subtext"))
        btn:SetScript("OnEnter", function()
            local D2 = RGX:GetDesign()
            border:SetBackdropBorderColor(D2:Unpack("primary"))
            bg:SetColorTexture(D2:Unpack("hover"))
            lbl:SetTextColor(D2:Unpack("primary"))
        end)
        btn:SetScript("OnLeave", function()
            border:SetBackdropBorderColor(D:Unpack("border"))
            bg:SetColorTexture(D:Unpack("surface"))
            lbl:SetTextColor(D:Unpack("subtext"))
        end)
    end
    if opts and type(opts.onClick) == "function" then
        AttachButtonAction(btn, opts.onClick)
    end
    for _, entry in ipairs({ { "OnEnter", "onEnter" }, { "OnLeave", "onLeave" } }) do
        local callback = opts and opts[entry[2]]
        if type(callback) == "function" then
            local script = entry[1]
            btn:HookScript(script, function(self, ...)
                local ok, err = pcall(callback, self, ...)
                if not ok and RGX and type(RGX.Error) == "function" then
                    RGX:Error("[RGXUI] button " .. script .. " failed: " .. tostring(err))
                end
            end)
        end
    end
    return btn
end

-- Standard window close ("X") button attachable to any framework-built
-- window, dialog, or panel, so consumers never hand-roll window chrome.
-- Uses the native UIPanelCloseButton art on every supported flavor.
-- opts: width/height (default 30), point/relativePoint (default TOPRIGHT),
-- relativeTo (default parent), x/y (default 0), onClick (default hides the
-- parent), tooltip (optional hover text), hidden (start hidden).
-- Returns the button; find it later via parent.closeButton or your own ref.
function UI:CreateCloseButton(parent, opts)
    assert(parent, "RGX UI: CreateCloseButton requires a parent frame")
    opts = opts or {}
    local button = CreateFrame("Button", nil, parent, "UIPanelCloseButton")
    button:SetSize(opts.width or 30, opts.height or 30)
    button:ClearAllPoints()
    local point = opts.point or "TOPRIGHT"
    local relativeTo = opts.relativeTo or parent
    local relativePoint = opts.relativePoint or point
    button:SetPoint(point, relativeTo, relativePoint, opts.x or 0, opts.y or 0)
    local onClick = opts.onClick
    if type(onClick) ~= "function" then
        onClick = function()
            if parent and parent.Hide then parent:Hide() end
        end
    end
    button:SetScript("OnClick", onClick)
    if opts.tooltip then
        button:SetScript("OnEnter", function(self)
            if GameTooltip then
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                GameTooltip:SetText(opts.tooltip, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end
        end)
        button:SetScript("OnLeave", function()
            if GameTooltip then GameTooltip:Hide() end
        end)
    end
    if opts.hidden then
        button:Hide()
    end
    parent.closeButton = button
    return button
end

-- Sub-menu configuration affordance: a small gear button attached to a
-- control (or any anchor frame) that opens a configuration dialog, so
-- consumers never hand-roll "advanced settings" chrome. opts: point /
-- relativeTo / relativePoint / x / y (default RIGHT of the anchor, 6, 0),
-- onClick (default: Show opts.dialog), dialog (frame to show), tooltip,
-- width/height (default 18), hidden. The button publishes itself as
-- opts.anchor.configButton when an anchor is given.
function UI:CreateConfigButton(anchor, opts)
    assert(anchor, "RGX UI: CreateConfigButton requires an anchor frame")
    opts = opts or {}
    local button = CreateFrame("Button", nil, anchor:GetParent() or anchor)
    button:SetSize(opts.width or 18, opts.height or 18)
    button:ClearAllPoints()
    local point = opts.point or "LEFT"
    local relativeTo = opts.relativeTo or anchor
    local relativePoint = opts.relativePoint or "RIGHT"
    button:SetPoint(point, relativeTo, relativePoint, opts.x or 6, opts.y or 0)
    local gear = button:CreateTexture(nil, "ARTWORK")
    gear:SetAllPoints()
    gear:SetTexture("Interface\\WorldMap\\Gear_64.png")
    gear:SetTexCoord(0, 0.5, 0, 0.5)
    gear:SetDesaturated(true)
    button.gear = gear
    button:SetScript("OnEnter", function(self)
        gear:SetDesaturated(false)
        if opts.tooltip and GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
            GameTooltip:SetText(opts.tooltip, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end
    end)
    button:SetScript("OnLeave", function()
        gear:SetDesaturated(true)
        if GameTooltip then GameTooltip:Hide() end
    end)
    local onClick = opts.onClick
    if type(onClick) ~= "function" then
        local dialog = opts.dialog
        onClick = function()
            if dialog and dialog.Show then dialog:Show() end
        end
    end
    button:SetScript("OnClick", onClick)
    if opts.hidden then
        button:Hide()
    end
    anchor.configButton = button
    return button
end

-- Titled configuration dialog for a control's advanced settings: design-skinned
-- frame with the framework close button and an optional Reset action.
-- opts: title (required), width/height (default 420x260), onReset (function),
-- onShow (function), strata (default "FULLSCREEN_DIALOG"), hidden (bool).
-- Consumers populate the returned frame; show it from a CreateConfigButton.
function UI:CreateConfigDialog(parent, opts)
    opts = opts or {}
    local D = RGX:GetDesign()
    local dialog
    if D and type(D.CreateFrame) == "function" then
        dialog = D:CreateFrame(parent or UIParent, {
            width = opts.width or 420, height = opts.height or 260,
            square = opts.square, bgAlpha = 0.95,
        })
    else
        dialog = CreateFrame("Frame", nil, parent or UIParent, "BackdropTemplate")
        dialog:SetSize(opts.width or 420, opts.height or 260)
    end
    dialog:SetFrameStrata(opts.strata or "FULLSCREEN_DIALOG")
    dialog:SetClampedToScreen(true)
    dialog:EnableMouse(true)
    dialog:SetMovable(true)
    dialog:RegisterForDrag("LeftButton")
    dialog:SetScript("OnDragStart", function(self) self:StartMoving() end)
    dialog:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    if not dialog.SetPanelColor then
        dialog:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1,
        })
        if D then
            dialog:SetBackdropColor(D:Unpack("surface"))
            dialog:SetBackdropBorderColor(D:Unpack("border"))
        else
            dialog:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
            dialog:SetBackdropBorderColor(0.137, 0.137, 0.173)
        end
    end

    if opts.resizable == true and type(dialog.SetResizable) == "function" then
        dialog.resizable = self:SetResizeBounds(dialog, opts.minWidth or 280,
            opts.minHeight or 180, opts.maxWidth or 1400, opts.maxHeight or 1000)
        dialog:SetResizable(dialog.resizable)
        if dialog.resizable then
            local grip = CreateFrame("Button", nil, dialog)
            grip:SetSize(16, 16)
            grip:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMRIGHT", -2, 2)
            grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
            grip:RegisterForDrag("LeftButton")
            grip:SetScript("OnDragStart", function() dialog:StartSizing("BOTTOMRIGHT") end)
            grip:SetScript("OnDragStop", function()
                dialog:StopMovingOrSizing()
                if type(opts.onResize) == "function" then
                    local ok, err = pcall(opts.onResize, dialog:GetWidth(), dialog:GetHeight(), dialog)
                    if not ok then RGX:Error("[RGXUI] resize callback failed: " .. tostring(err)) end
                end
            end)
            dialog.resizeGrip = grip
        end
    end

    local title = dialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -12)
    title:SetText(opts.title or "Configuration")
    if D then
        title:SetTextColor(D:Unpack("primary"))
    end
    dialog.titleText = title

    self:CreateCloseButton(dialog, { onClick = function() dialog:Hide() end })

    if type(opts.onReset) == "function" then
        local reset = self:CreateButton(dialog, {
            text = "Reset",
            width = 90,
            onClick = function() opts.onReset() end,
        })
        reset:SetPoint("BOTTOMLEFT", 16, 14)
        dialog.resetButton = reset
    end

    if type(opts.onShow) == "function" then
        dialog:HookScript("OnShow", opts.onShow)
    end
    if opts.hidden ~= false then
        dialog:Hide()
    end
    return dialog
end

--[[============================================================================
    SECTION/PANEL
============================================================================]]

-- A scrollable canvas for card layouts taller than an options tab. Keep the
-- scrollbar and clipping in the framework so consumers only position cards.
function UI:CreateScrollPage(parent, height)
    -- Intrinsic clipping viewport: framework pages never expose native bars.
    local scroll = CreateFrame("ScrollFrame", nil, parent)
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, -8)
    scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -8, 8)

    local canvas = CreateFrame("Frame", nil, scroll)
    canvas:SetHeight(height or 620)
    canvas:SetWidth(math.max(1, scroll:GetWidth()))
    scroll:SetScrollChild(canvas)
    local function clampScroll()
        local max = math.max(0, scroll:GetVerticalScrollRange())
        scroll:SetVerticalScroll(math.max(0, math.min(max, scroll:GetVerticalScroll())))
    end
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local max = math.max(0, self:GetVerticalScrollRange())
        self:SetVerticalScroll(math.max(0, math.min(max, self:GetVerticalScroll() - delta * 30)))
    end)
    scroll:HookScript("OnShow", clampScroll)
    scroll:HookScript("OnSizeChanged", function(self, width)
        canvas:SetWidth(math.max(1, width))
        clampScroll()
    end)
    canvas:HookScript("OnSizeChanged", clampScroll)
    return canvas, scroll
end

function UI:CreateSection(parent, options)
    options = options or {}
    local title = options.title or "Section"
    local width = options.width or 300
    local height = options.height or 200
    local D = RGX:GetDesign()
    assert(D and type(D.CreateSection) == "function", "RGX UI: section design unavailable")
    -- Share the consumer-proven section skin; RGXUI owns placement, RGXDesign textures.
    local section = D:CreateSection(parent, title ~= "" and title or nil, options.icon,
        { square = options.square ~= false })
    section:SetSize(width, height)
    section.headerBand = section.header
    -- Measure direct widgets after the consumer finishes building the card.
    -- Children can be Frames or FontStrings; do not depend on a fixed count,
    -- particular widget type, or the consumer's hand-maintained y offsets.
    function section:FitContent(padding)
        local top = self.content:GetTop()
        local deepest = 0
        local function measure(region)
            if not region or (region.IsShown and not region:IsShown()) then return end
            local bottom = region.GetBottom and region:GetBottom()
            if top and type(bottom) == "number" then
                deepest = math.max(deepest, top - bottom)
            elseif region.GetPoint and region.GetHeight then
                local _, relative, relativePoint, _, y = region:GetPoint(1)
                if relative == self.content and (relativePoint == "TOPLEFT" or relativePoint == "TOP")
                    and type(y) == "number" then
                    deepest = math.max(deepest, -y + (region:GetHeight() or 0))
                end
            end
        end
        for _, child in ipairs({self.content:GetChildren()}) do measure(child) end
        for _, region in ipairs({self.content:GetRegions()}) do measure(region) end
        if deepest > 0 then
            self:SetHeight(self.contentTopInset + deepest + self.contentBottomInset + (padding or 2))
        end
        return self:GetHeight()
    end
    return section
end

--[[============================================================================
    PREVIEW FRAME
============================================================================]]

function UI:CreatePreviewFrame(parent, options)
    options = options or {}
    local width = options.width or 250
    local height = options.height or 150
    local D = RGX:GetDesign()
    
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetBackdrop(self.backdrop)
    local sr, sg, sb = D:Unpack("surface")
    frame:SetBackdropColor(sr, sg, sb, 0.9)
    frame:SetBackdropBorderColor(D:Unpack("border"))
    
    -- Label
    frame.label = self:CreateLabel(frame, {
        text = options.title or "Preview",
        size = "normal",
        color = "muted"
    })
    frame.label:SetPoint("TOP", 0, -8)
    
    -- Preview content area
    frame.preview = CreateFrame("Frame", nil, frame)
    frame.preview:SetPoint("CENTER", 0, -10)
    frame.preview:SetSize(width - 20, height - 40)
    
    -- Background for preview
    frame.preview.bg = frame.preview:CreateTexture(nil, "BACKGROUND")
    frame.preview.bg:SetAllPoints()
    frame.preview.bg:SetColorTexture(D:Unpack("background"))
    
    return frame
end

--[[============================================================================
    SWITCH — sliding on/off control (consumer module-page style)

    UI:CreateSwitch(parent, options)
    options:
        key      storage key (when storage given)
        label    text shown left of the switch
        default  default state when storage has no value (default true)
        storage  settings table (optional; without it the switch is stateless
                 and reports via onChange)
        onChange function(enabled)
    Returns a container with .switchFrame / .toggle / .label / .Refresh and
    container.checkbox (a Button emulating GetChecked) for compatibility.
============================================================================]]

function UI:CreateSwitch(parent, options)
    options = options or {}
    local D = RGX:GetDesign()
    local pr, pg, pb = 0.02, 0.87, 0.38 -- green-ish; refined by theme below
    if D then pr, pg, pb = D:Unpack("success") end
    local br, bg_, bb = 0.30, 0.30, 0.30
    if D then br, bg_, bb = D:Unpack("border") end

    local container = CreateFrame("Button", nil, parent)
    container:SetSize(200, 22)
    container:RegisterForClicks("LeftButtonUp")

    -- Status text (right of label area, matches consumer module toggles)
    container.label = self:CreateLabel(container, {
        text = options.label or "",
        size = "small",
    })
    container.label:SetPoint("LEFT", 0, 0)

    local status = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("RIGHT", container, "RIGHT", -52, 0)
    ApplyDefaultFont(status)
    container.status = status

    -- Track
    local switchFrame = CreateFrame("Frame", nil, container)
    switchFrame:SetSize(44, 20)
    switchFrame:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    container.switchFrame = switchFrame

    local switchBg = switchFrame:CreateTexture(nil, "BACKGROUND")
    switchBg:SetAllPoints()
    switchBg:SetTexture("Interface\\Buttons\\WHITE8x8")

    -- Thumb
    local toggle = CreateFrame("Frame", nil, switchFrame)
    toggle:SetSize(18, 18)
    toggle:EnableMouse(false)
    container.toggle = toggle

    local toggleBg = toggle:CreateTexture(nil, "ARTWORK")
    toggleBg:SetAllPoints()
    toggleBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    toggleBg:SetVertexColor(0.92, 0.92, 0.92, 1)

    local storage   = options.storage
    local key       = options.key
    local default   = options.default
    if default == nil then default = true end
    local onChange  = options.onChange or function() end
    if not (storage and key) then
        container._enabled = (default == true)
    end

    local function IsEnabled()
        if storage and key then
            local v = storage[key]
            if v == nil then return default end
            return v and true or false
        end
        return container._enabled == true
    end

    function container:Refresh()
        local enabled = IsEnabled()
        toggle:ClearAllPoints()
        if enabled then
            toggle:SetPoint("RIGHT", switchFrame, "RIGHT", -1, 0)
            switchBg:SetVertexColor(pr, pg, pb, 1)
            status:SetText("|cff00ff00ON|r")
        else
            toggle:SetPoint("LEFT", switchFrame, "LEFT", 1, 0)
            switchBg:SetVertexColor(br, bg_, bb, 1)
            status:SetText("|cffff0000OFF|r")
        end
    end

    container:SetScript("OnClick", function()
        local nextState = not IsEnabled()
        if storage and key then
            storage[key] = nextState
        else
            container._enabled = nextState
        end
        container:Refresh()
        onChange(nextState)
    end)

    -- Compatibility shim so generic refresh code can SetChecked/GetChecked
    local fake = { checked = IsEnabled() }
    function fake:GetChecked()  return IsEnabled() end
    function fake:SetChecked(s) if storage and key then storage[key] = s and true or false else container._enabled = s and true or false end; container:Refresh() end
    function fake:SetScript() end
    container.checkbox = fake

    container:Refresh()
    return container
end

--[[============================================================================
    COLUMNS — centered multi-column page layout

    UI:CreateColumns(parent, count, options)
    options:
        colWidth  width per column (default: share the parent width evenly)
        gap       horizontal gap between columns (default 14)
        margin    extra inset from the parent edges when auto-sizing (default 0)

    Columns are centered as a block inside the parent, so two-column pages
    sit properly centered instead of hugging the edges.
    Returns one frame per column (unpack into locals).
============================================================================]]

function UI:CreateColumns(parent, count, options)
    options = options or {}
    count = count or 2
    local gap = options.gap or 14
    local margin = options.margin or 0
    local fixedWidth = options.colWidth

    local columns = {}
    for i = 1, count do
        columns[i] = CreateFrame("Frame", nil, parent)
    end

    -- Column width is derived from the parent, which may be anchor-sized and
    -- therefore report 0 until layout resolves. Recompute on size changes so
    -- the page settles at the right width instead of staying collapsed.
    local function layout()
        local colWidth = fixedWidth
        if not colWidth then
            local w = (parent.GetWidth and parent:GetWidth()) or 0
            if w <= 0 then
                colWidth = 360
            else
                colWidth = math.floor((w - (count - 1) * gap - margin * 2) / count)
                if colWidth < 0 then colWidth = 0 end
            end
        end
        for i = 1, count do
            local col = columns[i]
            col:SetWidth(colWidth)
            local xCenter = (i - 0.5 - count / 2) * (colWidth + gap)
            col:ClearAllPoints()
            col:SetPoint("TOP", parent, "TOP", xCenter, 0)
            col:SetPoint("BOTTOM", parent, "BOTTOM", xCenter, 0)
        end
    end
    layout()

    if parent.HookScript then
        parent:HookScript("OnSizeChanged", layout)
    end

    return unpack(columns)
end

-- Versioned label definitions: data-only editor/import surface. Keep this
-- validator congruent with contract/schemas/rgx-definition.schema.json and JS fixtures.
local definitionKeys = { version = true, kind = true, id = true, text = true,
    enabled = true, x = true, y = true, scale = true }
local function DefinitionValueAccessible(value)
    return RGX.API and type(RGX.API.CanAccessValue) == "function"
        and RGX.API.CanAccessValue(value) == true
end
local function DefinitionTableAccessible(value)
    return RGX.API and type(RGX.API.CanAccessTable) == "function"
        and RGX.API.CanAccessTable(value) == true
end
local function ValidDefinitionText(text)
    if #text > 256 then return false end
    local i = 1
    while i <= #text do
        local first = text:byte(i)
        local count, low, high = 0, 128, 191
        if first < 128 then
            if first < 32 or first == 127 then return false end
        elseif first >= 194 and first <= 223 then count = 1
        elseif first == 224 then count, low = 2, 160
        elseif first >= 225 and first <= 236 then count = 2
        elseif first == 237 then count, high = 2, 159
        elseif first >= 238 and first <= 239 then count = 2
        elseif first == 240 then count, low = 3, 144
        elseif first >= 241 and first <= 243 then count = 3
        elseif first == 244 then count, high = 3, 143
        else return false end
        for offset = 1, count do
            local byte = text:byte(i + offset)
            if not byte or byte < (offset == 1 and low or 128)
                or byte > (offset == 1 and high or 191) then return false end
        end
        i = i + count + 1
    end
    return true
end

function UI:NormalizeDefinition(value)
    if not DefinitionTableAccessible(value) or getmetatable(value) ~= nil then
        return nil, "definition must be an accessible plain table"
    end
    for key in pairs(value) do
        if not DefinitionValueAccessible(key) or not definitionKeys[key] then
            return nil, "unknown definition field"
        end
    end
    for key in pairs(definitionKeys) do
        if not DefinitionValueAccessible(value[key]) then return nil, "missing/inaccessible definition field" end
    end
    if value.version ~= 1 or value.kind ~= "label" then return nil, "unsupported definition version/kind" end
    if type(value.id) ~= "string" or #value.id > 48
        or not value.id:match("^[A-Za-z][A-Za-z0-9_-]*$") then return nil, "invalid definition id" end
    if type(value.text) ~= "string" or not ValidDefinitionText(value.text) then return nil, "invalid definition text" end
    if type(value.enabled) ~= "boolean" then return nil, "invalid definition enabled state" end
    for _, key in ipairs({ "x", "y", "scale" }) do
        local number = value[key]
        local min, max = -500, 500
        if key == "scale" then min, max = 25, 300 end
        if type(number) ~= "number" or number ~= number or number < min or number > max
            or number % 1 ~= 0 then return nil, "invalid definition number" end
    end
    return { version = 1, kind = "label", id = value.id, text = value.text,
        enabled = value.enabled, x = value.x == 0 and 0 or value.x,
        y = value.y == 0 and 0 or value.y, scale = value.scale }
end

function UI:ExportDefinition(value)
    local d, err = self:NormalizeDefinition(value)
    if not d then return nil, err end
    local text = d.text:gsub(".", function(char) return string.format("%%%02X", char:byte()) end)
    return table.concat({ "RGXD1", d.kind, d.id, d.enabled and "1" or "0",
        tostring(d.scale), tostring(d.x), tostring(d.y), text }, "|")
end

function UI:ImportDefinition(wire)
    if not DefinitionValueAccessible(wire) or type(wire) ~= "string" or #wire > 1024 then
        return nil, "invalid definition transfer"
    end
    local p = {}
    for part in (wire .. "|"):gmatch("(.-)|") do p[#p + 1] = part end
    if #p ~= 8 or p[1] ~= "RGXD1" or (p[4] ~= "0" and p[4] ~= "1")
        or p[8]:gsub("%%[%x][%x]", "") ~= "" then return nil, "invalid definition transfer" end
    for index = 5, 7 do
        if not p[index]:match("^-?%d+$") or p[index]:match("^-?0%d") then
            return nil, "invalid definition number"
        end
    end
    local text = p[8]:gsub("%%([%x][%x])", function(hex) return string.char(tonumber(hex, 16)) end)
    return self:NormalizeDefinition({ version = 1, kind = p[2], id = p[3], text = text,
        enabled = p[4] == "1", scale = tonumber(p[5]), x = tonumber(p[6]), y = tonumber(p[7]) })
end

function UI:CreateDefinitionSession(value, onSave)
    local owner = self
    local saved, err = owner:NormalizeDefinition(value)
    if not saved then return nil, err end
    local draft = owner:NormalizeDefinition(saved)
    local session = {}
    function session:GetDefinition() return owner:NormalizeDefinition(saved) end
    function session:GetDraft() return owner:NormalizeDefinition(draft) end
    function session:Patch(changes)
        if not DefinitionTableAccessible(changes) or getmetatable(changes) ~= nil then
            return nil, "changes must be an accessible plain table"
        end
        local nextDraft = owner:NormalizeDefinition(draft)
        if not nextDraft then return nil, "inaccessible draft" end
        for key, value in pairs(changes) do
            if not DefinitionValueAccessible(key) or not DefinitionValueAccessible(value)
                or not definitionKeys[key] then return nil, "invalid definition change" end
            nextDraft[key] = value
        end
        local normalized, errorText = owner:NormalizeDefinition(nextDraft)
        if not normalized then return nil, errorText end
        draft = normalized
        return self:GetDraft()
    end
    function session:Import(wire)
        local nextDraft, errorText = owner:ImportDefinition(wire)
        if not nextDraft then return nil, errorText end
        draft = nextDraft
        return self:GetDraft()
    end
    function session:Export() return owner:ExportDefinition(draft) end
    function session:Cancel()
        local nextDraft, errorText = owner:NormalizeDefinition(saved)
        if not nextDraft then return nil, errorText end
        draft = nextDraft
        return self:GetDraft()
    end
    function session:Save()
        local nextSaved, errorText = owner:NormalizeDefinition(draft)
        if not nextSaved then return nil, errorText end
        if type(onSave) == "function" then
            local ok, accepted = pcall(onSave, owner:NormalizeDefinition(nextSaved))
            if not ok or (type(accepted) ~= "nil" and
                (not DefinitionValueAccessible(accepted) or accepted ~= true)) then
                return nil, "definition save rejected"
            end
        end
        saved = nextSaved
        return self:GetDefinition()
    end
    return session
end

function UI:CreateDefinitionEditor(parent, options)
    options = options or {}
    local session, err = self:CreateDefinitionSession(options.definition, options.onSave)
    if not session then return nil, err end
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(480, 390)
    frame.session = session
    local scene = self:CreateSection(frame, { title = "Label preview", width = 460, height = 100 })
    scene:SetPoint("TOPLEFT", 10, 0)
    local previewCanvas = self:CreateScrollPage(scene.content, 48)
    local preview = CreateFrame("Frame", nil, previewCanvas)
    preview:SetSize(1, 1)
    local label = self:CreateLabel(preview, { text = "" })
    label:SetPoint("CENTER")
    local status = self:CreateLabel(frame, { text = "", width = 460, color = "muted" })
    status:SetPoint("TOPLEFT", 10, -350)
    local fields, syncing, invalidFields = {}, false, {}
    local function updatePreview()
        local d = session:GetDraft()
        if not d then return end
        label:SetText(d.text:gsub("|", "||")) -- plain text, matching browser textContent
        preview:ClearAllPoints()
        preview:SetPoint("CENTER", previewCanvas, "CENTER", d.x, d.y)
        preview:SetScale(d.scale / 100)
        if d.enabled then preview:Show() else preview:Hide() end
    end
    local function input(title, y, onChange)
        local caption = self:CreateLabel(frame, { text = title })
        caption:SetPoint("TOPLEFT", 10, y)
        local box = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
        box:SetSize(320, 24)
        box:SetPoint("TOPLEFT", 140, y + 4)
        if type(box.SetAutoFocus) == "function" then box:SetAutoFocus(false) end
        ApplyDefaultFont(box)
        box:SetScript("OnEscapePressed", function(widget) widget:ClearFocus() end)
        box:SetScript("OnEnterPressed", function(widget) widget:ClearFocus() end)
        box:SetScript("OnTextChanged", function(widget, userInput)
            if syncing or not userInput or not onChange then return end
            local ok, errorText = onChange(widget:GetText())
            invalidFields[title] = not ok or nil
            status:SetText(ok and "Draft changed; Save to persist." or (errorText or "Invalid value"))
            updatePreview()
        end)
        return box
    end
    fields.text = input("Text", -120, function(text) return session:Patch({ text = text }) end)
    for index, key in ipairs({ "x", "y", "scale" }) do
        local fieldKey = key
        fields[key] = input(key == "scale" and "Scale (%)" or key:upper(), -120 - index * 30,
            function(text)
                local number = tonumber(text)
                if not number then return nil, "Enter an integer" end
                return session:Patch({ [fieldKey] = number })
            end)
    end
    local toggle = self:CreateToggle(frame, { label = "Enabled", storage = { enabled = session:GetDraft().enabled },
        default = true, onChange = function(value) session:Patch({ enabled = value }); updatePreview() end })
    toggle:SetPoint("TOPLEFT", 10, -242)
    fields.transfer = input("Import / export", -274)
    local function refresh(message)
        syncing = true
        invalidFields = {}
        local d = session:GetDraft()
        if d then
            fields.text:SetText(d.text)
            for _, key in ipairs({ "x", "y", "scale" }) do fields[key]:SetText(tostring(d[key])) end
            toggle.check:SetChecked(d.enabled)
            fields.transfer:SetText(session:Export() or "")
        end
        syncing = false
        status:SetText(message or "Draft ready; changes are saved only on Save.")
        updatePreview()
    end
    for index, action in ipairs({ "Import", "Export", "Save", "Cancel" }) do
        local name = action
        local button = self:CreateButton(frame, { text = name, width = 100, onClick = function()
            if name == "Export" then fields.transfer:SetText(session:Export() or ""); return end
            local result, errorText
            if name == "Import" then result, errorText = session:Import(fields.transfer:GetText())
            elseif name == "Save" then
                if next(invalidFields) then status:SetText("Fix invalid fields before saving."); return end
                result, errorText = session:Save()
            else result, errorText = session:Cancel() end
            if result then refresh(name .. " complete") else status:SetText(errorText or "Operation failed") end
        end })
        button:SetPoint("TOPLEFT", 10 + (index - 1) * 115, -312)
    end
    function frame:Refresh() refresh() end
    frame:SetScript("OnHide", function() session:Cancel(); refresh() end)
    refresh()
    return frame
end

--[[============================================================================
    INITIALIZATION
============================================================================]]

function UI:Init()
    RGX:RegisterModule("ui", self, { category = "library", depends = { "fonts", "colors", "textures", "dropdowns" } })
    _G.RGXUI = self
end

UI:Init()
