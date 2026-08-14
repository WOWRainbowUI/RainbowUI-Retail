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
        return self:CreateLabel(parent, { text = "RGX ColorPicker not loaded", color = "red" })
    end
    return CP:CreateEmbedded(parent, options or {})
end

function UI:CreateColorPicker(parent, options)
    options = options or {}
    local key = options.key or "color"
    local label = options.label or "Color"
    local default = options.default or {r=1, g=1, b=1}
    local storage = options.storage or {}
    local onChange = options.onChange or function() end
    local previewOnClick = options.previewOnClick  -- Function to call when clicking swatch
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200, 24)
    
    -- Label
    container.label = self:CreateLabel(container, {
        text = label,
        size = "small",
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
	local key = options.key or "value"
	local label = options.label or "Slider"
	local min = options.min or 0
	local max = options.max or 100
	local step = options.step or 1
	local default = options.default or min
	local storage = options.storage or {}
	local suffix = options.suffix or ""
	local onChange = options.onChange or function() end
	local sliderWidth = options.width or 200
	-- progress: show the brand-colored fill behind the thumb. Defaults on so
	-- existing sliders are unchanged; pass progress = false for a bare track
	-- (some panels want the thumb without a running fill).
	local showProgress = options.progress
	if showProgress == nil then showProgress = true end

	local D = RGX:GetDesign()

	local container = CreateFrame("Frame", nil, parent)
	container:SetSize(sliderWidth + 32, 38)

	container.label = self:CreateLabel(container, {
		text = label,
		size = "small",
		color = "muted"
	})
	container.label:SetPoint("TOPLEFT", 0, 0)

	container.valueLabel = self:CreateLabel(container, {
		text = (storage[key] or default) .. suffix,
		size = "small"
	})
	container.valueLabel:SetPoint("TOPRIGHT", -28, 0)

	local trackFrame = CreateFrame("Frame", nil, container)
	trackFrame:SetPoint("TOPLEFT", container.label, "BOTTOMLEFT", 0, -4)
	trackFrame:SetPoint("TOPRIGHT", container.valueLabel, "BOTTOMRIGHT", 0, -4)
	trackFrame:SetHeight(18)

	local button = CreateFrame("Button", nil, trackFrame)
	button:SetAllPoints(trackFrame)
	button:SetHeight(18)

	local valueLabel = trackFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	valueLabel:SetTextColor(D:Unpack("subtext"))
	valueLabel:SetPoint("TOP", button, "BOTTOM", 0, 2)
	valueLabel:Hide()

	button:SetScript("OnEnter", function() valueLabel:Show() end)
	button:SetScript("OnLeave", function() valueLabel:Hide() end)

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
		local trackWidth = track:GetWidth()
		if trackWidth < 1 then return false end
		local pct = valueToPercent(storage[key] or default)
		local fillW = math.max(4, trackWidth * pct)
		if showProgress then fill:SetWidth(fillW) end
		thumb:ClearAllPoints()
		thumb:SetPoint("CENTER", track, "LEFT", fillW, 0)
		return true
	end

	-- Retry positioning until the track has a real width. OnUpdate never fires
	-- while a frame is hidden, so a slider built on a not-yet-shown panel would
	-- otherwise stay at the wrong spot until its value changed -- the "default
	-- position wrong on login until set/reset/reload" bug. OnShow re-arms this.
	local function positionThumbDeferred()
		if positionThumb() then return end
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
	reset:SetPoint("RIGHT", container, "RIGHT", 0, -10)

	-- Re-place the thumb every time the slider is shown: the first apply() below
	-- runs while the panel is usually still hidden (login/load), so this is what
	-- makes the initial position correct without needing a set/reset/reload.
	container:SetScript("OnShow", positionThumbDeferred)

	apply(storage[key] or default)

	container.SetValue = apply
	container.GetValue = function() return storage[key] or default end

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

	local function apply(volume)
		if volume ~= "low" and volume ~= "high" then
			volume = "medium"
		end
		setVolume(volume)

		local function updateVisuals()
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

		if not updateVisuals() then
			frame:SetScript("OnUpdate", function()
				if updateVisuals() then
					frame:SetScript("OnUpdate", nil)
				end
			end)
		end
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

	apply(getVolume())

	frame.Refresh = function()
		apply(getVolume())
	end

	return frame
end

--[[============================================================================
TOGGLE CONTROL
============================================================================]]

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
    check:SetChecked(storage[key] ~= false and default)
    
    -- Label
    container.label = self:CreateLabel(container, {
        text = label,
        size = "small"
    })
    container.label:SetPoint("LEFT", check, "RIGHT", 4, 0)
    
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
    
    local colorKeys = {
        normal = "text",
        muted  = "subtext",
        accent = "primary",
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

function UI:CreateButton(parent, text, w, h)
    h = h or 22
    local D = RGX:GetDesign()
    if D and type(D.CreateButton) == "function" then
        return D:CreateButton(parent, text, w, h)
    end
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(w or 120, h or 22)
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
    return btn
end

--[[============================================================================
    SECTION/PANEL
============================================================================]]

function UI:CreateSection(parent, options)
    options = options or {}
    local title = options.title or "Section"
    local width = options.width or 300
    local height = options.height or 200
    
    local section = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    section:SetSize(width, height)
    section:SetBackdrop(self.backdrop)
    local D = RGX:GetDesign()
    local sr, sg, sb = D:Unpack("surface")
    section:SetBackdropColor(sr, sg, sb, 0.85)
    section:SetBackdropBorderColor(D:Unpack("border"))
    
    -- Header
    section.header = self:CreateLabel(section, {
        text = title,
        size = "small",
        color = "accent"
    })
    section.header:SetPoint("TOPLEFT", 12, -10)
    
    -- Content area
    section.content = CreateFrame("Frame", nil, section)
    section.content:SetPoint("TOPLEFT", 12, -30)
    section.content:SetPoint("BOTTOMRIGHT", -12, 12)
    
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
        size = "small",
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
    INITIALIZATION
============================================================================]]

function UI:Init()
    RGX:RegisterModule("ui", self)
    _G.RGXUI = self
end

UI:Init()
