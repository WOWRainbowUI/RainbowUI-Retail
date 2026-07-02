local addonName, lv = ...

local DEFAULT_CARD_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local DEFAULT_BUTTON_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8X8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
}

local function ApplyBackdrop(frame, backdrop)
    if frame and backdrop then
        frame:SetBackdrop(backdrop)
    end
end

local function ApplyPoint(frame, point)
    if not frame or type(point) ~= "table" or not point[1] then
        return
    end
    frame:SetPoint(unpack(point))
end

local pendingMousePropagation = pendingMousePropagation or {}
local propagationDriver = propagationDriver

local function FlushPendingMousePropagation()
    if InCombatLockdown and InCombatLockdown() then
        return
    end

    for frame, propagate in pairs(pendingMousePropagation) do
        if frame and frame.SetPropagateMouseClicks then
            frame:SetPropagateMouseClicks(propagate)
        end
        pendingMousePropagation[frame] = nil
    end

    if propagationDriver then
        propagationDriver:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end

local function SafeSetPropagateMouseClicks(frame, propagate)
    if not frame or not frame.SetPropagateMouseClicks then
        return
    end

    if InCombatLockdown and InCombatLockdown() then
        pendingMousePropagation[frame] = propagate
        if not propagationDriver then
            propagationDriver = CreateFrame("Frame")
            propagationDriver:SetScript("OnEvent", FlushPendingMousePropagation)
        end
        propagationDriver:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    frame:SetPropagateMouseClicks(propagate)
end

function lv.CreateSectionHeader(parent, text, opts)
    opts = opts or {}

    local header = CreateFrame("Frame", nil, parent)
    header:SetSize(opts.width or 1, opts.height or 18)
    ApplyPoint(header, opts.point)

    header.Text = header:CreateFontString(nil, "OVERLAY", opts.fontObject or "GameFontNormal")
    header.Text:SetPoint(unpack(opts.textPoint or { "LEFT", 0, 0 }))
    header.Text:SetText(text or "")

    if opts.textColor then
        header.Text:SetTextColor(unpack(opts.textColor))
    end
    if opts.localeFontSize and lv.ApplyLocaleFont then
        lv.ApplyLocaleFont(header.Text, opts.localeFontSize)
    end

    if opts.line ~= false then
        header.line = header:CreateTexture(nil, "BACKGROUND")
        header.line:SetColorTexture(1, 1, 1, 0.12)
        header.line:SetHeight(opts.lineHeight or 1)
        header.line:SetPoint("LEFT", header.Text, "BOTTOMLEFT", 0, -2)
        header.line:SetPoint("RIGHT", header, "RIGHT", 0, 0)
    end

    return header
end

function lv.CreateCardContainer(parent, opts)
    opts = opts or {}

    local frame = CreateFrame(opts.kind or "Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(opts.width or 1, opts.height or 1)
    ApplyPoint(frame, opts.point)
    ApplyBackdrop(frame, opts.backdrop or DEFAULT_CARD_BACKDROP)

    if opts.backdropColor then
        frame:SetBackdropColor(unpack(opts.backdropColor))
    end
    if opts.backdropBorderColor then
        frame:SetBackdropBorderColor(unpack(opts.backdropBorderColor))
    end
    if opts.mouse then
        frame:EnableMouse(true)
    end
    if opts.strata then
        frame:SetFrameStrata(opts.strata)
    end
    if opts.toplevel ~= nil then
        frame:SetToplevel(opts.toplevel)
    end
    if opts.propagateMouseClicks ~= nil and frame.SetPropagateMouseClicks then
        SafeSetPropagateMouseClicks(frame, opts.propagateMouseClicks)
    end
    if opts.registerForClicks and frame.RegisterForClicks then
        frame:RegisterForClicks(unpack(opts.registerForClicks))
    end

    return frame
end

function lv.CreateSmallActionButton(parent, opts)
    opts = opts or {}

    local btn = lv.CreateCardContainer(parent, {
        kind = "Button",
        width = opts.width or 76,
        height = opts.height or 24,
        point = opts.point,
        backdrop = opts.backdrop or DEFAULT_BUTTON_BACKDROP,
        backdropColor = opts.backdropColor,
        backdropBorderColor = opts.backdropBorderColor,
        mouse = opts.mouse ~= false,
        strata = opts.strata,
        toplevel = opts.toplevel,
        propagateMouseClicks = opts.propagateMouseClicks,
        registerForClicks = opts.registerForClicks,
    })

    btn.isActionControl = opts.isActionControl == true

    if opts.text then
        btn.text = btn:CreateFontString(nil, "OVERLAY", opts.fontObject or "GameFontHighlightSmall")
        btn.text:SetPoint(unpack(opts.textPoint or { "CENTER", 0, 0 }))
        btn.text:SetText(opts.text)
        if opts.textColor then
            btn.text:SetTextColor(unpack(opts.textColor))
        end
    end

    if opts.iconTexture then
        btn.icon = btn:CreateTexture(nil, "ARTWORK")
        btn.icon:SetSize(opts.iconSize or 16, opts.iconSize or 16)
        btn.icon:SetPoint(unpack(opts.iconPoint or { "LEFT", 4, 0 }))
        btn.icon:SetTexture(opts.iconTexture)
    end

    return btn
end
