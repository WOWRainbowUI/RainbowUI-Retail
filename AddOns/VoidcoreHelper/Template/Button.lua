function VCHButton_OnLoad(frame)
    frame.text = frame.Text
    local w = math.min(frame:GetWidth(), frame:GetHeight()) * 0.4

    frame.line = frame:CreateLine(nil, "OVERLAY")
    frame.line:SetStartPoint("TOPLEFT", -1, 0)
    frame.line:SetEndPoint("TOPLEFT", w, 0)
    frame.line:SetColorTexture(1, 1, 1, 1)
    frame.line:SetThickness(2)
    frame.vline = frame:CreateLine(nil, "OVERLAY")
    frame.vline:SetStartPoint("TOPLEFT", 0, -1)
    frame.vline:SetEndPoint("TOPLEFT", 0, -w)
    frame.vline:SetColorTexture(1, 1, 1, 0.8)
    frame.vline:SetThickness(2)
    frame.line:Hide()
    frame.vline:Hide()

    frame.line2 = frame:CreateLine(nil, "OVERLAY")
    frame.line2:SetStartPoint("BOTTOMRIGHT", 1, 0)
    frame.line2:SetEndPoint("BOTTOMRIGHT", -w, 0)
    frame.line2:SetColorTexture(1, 1, 1, 1)
    frame.line2:SetThickness(2)
    frame.vline2 = frame:CreateLine(nil, "OVERLAY")
    frame.vline2:SetStartPoint("BOTTOMRIGHT", 0, 1)
    frame.vline2:SetEndPoint("BOTTOMRIGHT", 0, w)
    frame.vline2:SetColorTexture(1, 1, 1, 0.8)
    frame.vline2:SetThickness(2)
    frame.line2:Hide()
    frame.vline2:Hide()


    -- 创建一个边框
    frame.border = frame.border or frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    frame.border:SetSize(frame:GetWidth() + 2, frame:GetHeight() + 2)
    frame.border:SetColorTexture(19 / 255, 18 / 255, 54 / 255, 0.3)

    -- 创建一个背景纹理并设置为黑色
    frame.background = frame.background or frame:CreateTexture(nil, "BACKGROUND", nil, 2)
    frame.background:SetAllPoints(frame)
    frame.background:SetColorTexture(0, 0, 0, 0.4)

    frame.border:Hide()
    frame.background:Hide()
end

function VCHButton_OnMouseEnter(frame)
    if not frame.disable then
        local w = math.min(frame:GetWidth(), frame:GetHeight()) * 0.4
        frame.line:SetEndPoint("TOPLEFT", w, 0)
        frame.vline:SetEndPoint("TOPLEFT", 0, -w)
        frame.line:Show()
        frame.vline:Show()

        frame.line2:SetEndPoint("BOTTOMRIGHT", -w, 0)
        frame.vline2:SetEndPoint("BOTTOMRIGHT", 0, w)
        frame.line2:Show()
        frame.vline2:Show()

        frame.border:SetSize(frame:GetWidth() + 2, frame:GetHeight() + 2)
        frame.border:Show()
        frame.background:Show()
    end
end

function VCHButton_OnMouseLeave(frame)
    frame.line:Hide()
    frame.vline:Hide()
    frame.line2:Hide()
    frame.vline2:Hide()

    frame.border:Hide()
    frame.background:Hide()
end

function VCHButton_OnDisable(frame)
    frame.disable = true
    frame:SetAlpha(0.2)
end

function VCHButton_OnEnable(frame)
    frame.disable = false
    frame:SetAlpha(1)
end