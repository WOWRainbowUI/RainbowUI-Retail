local addonName, IVSP = ...
local L = IVSP.L

local currentSpecID, isItemsShown
local items = {}
local addBtn, customFrame
-----------------------------------------------
-- font
-----------------------------------------------
CreateFont("IVSP_FONT")
IVSP_FONT:SetShadowColor(0, 0, 0)
IVSP_FONT:SetShadowOffset(1, -1)
IVSP_FONT:SetJustifyH("CENTER")
IVSP_FONT:SetJustifyV("MIDDLE")

CreateFont("IVSP_FONT_P")
IVSP_FONT_P:SetShadowColor(0, 0, 0)
IVSP_FONT_P:SetShadowOffset(1, -1)
IVSP_FONT_P:SetJustifyH("LEFT")
IVSP_FONT_P:SetJustifyV("MIDDLE")

-----------------------------------------------
-- widgets
-----------------------------------------------
local function CreateButton(parent, backdropColor, backdropBorderColor, width, height, text)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    b:SetPushedTextOffset(0, -1)
    b:SetBackdropColor(unpack(backdropColor))
    b:SetBackdropBorderColor(unpack(backdropBorderColor))
    b:SetNormalFontObject(IVSP_FONT)
    b:SetWidth(width)
    b:SetHeight(height)
    b:SetText(text)

    -- texture
    -- function b:SetTexture(tex, texSize, point)
    --     b.tex = b:CreateTexture(nil, "ARTWORK")
    --     b.tex:SetPoint(unpack(point))
    --     b.tex:SetSize(unpack(texSize))
    --     b.tex:SetTexture(tex)
    --     -- push effect
    --     b.onMouseDown = function()
    --         b.tex:ClearAllPoints()
    --         b.tex:SetPoint(point[1], point[2], point[3]-1)
    --     end
    --     b.onMouseUp = function()
    --         b.tex:ClearAllPoints()
    --         b.tex:SetPoint(unpack(point))
    --     end
    --     b:SetScript("OnMouseDown", b.onMouseDown)
    --     b:SetScript("OnMouseUp", b.onMouseUp)
    --     -- enable / disable
    --     b:HookScript("OnEnable", function()
    --         b.tex:SetVertexColor(1, 1, 1)
    --         b:SetScript("OnMouseDown", b.onMouseDown)
    --         b:SetScript("OnMouseUp", b.onMouseUp)
    --     end)
    --     b:HookScript("OnDisable", function()
    --         b.tex:SetVertexColor(.4, .4, .4)
    --         b:SetScript("OnMouseDown", nil)
    --         b:SetScript("OnMouseUp", nil)
    --     end)
    -- end
    return b
end

-----------------------------------------------
-- frame (button)
-----------------------------------------------
local frame = CreateFrame("Button", "IcyVeinsStatPriorityFrame", CharacterFrame, "BackdropTemplate")
frame:SetFrameLevel(CharacterFrame:GetFrameLevel()+100)
frame:SetPoint("BOTTOMRIGHT", CharacterFrame, "TOPRIGHT", 0, 1)
frame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
frame:SetPushedTextOffset(0, -1)
frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

-- function
local function SetFrame(bgColor, borderColor, fontColor, fontSize, show)
    IVSP_FONT:SetFont(GameFontNormal:GetFont(), fontSize, "")
    IVSP_FONT:SetTextColor(unpack(fontColor))

    IVSP_FONT_P:SetFont(GameFontNormal:GetFont(), fontSize, "")

    frame:SetNormalFontObject(IVSP_FONT)

    frame:SetBackdropColor(unpack(bgColor))
    frame:SetBackdropBorderColor(unpack(borderColor))
    frame:SetHeight(fontSize + 7)

    if show then
        frame:Show()
    else
        frame:Hide()
    end
end

local function SetText(text)
    if not text then return end
    frame:SetText(text)
    frame:SetWidth(frame:GetFontString():GetStringWidth() + 20)
end

-----------------------------------------------
-- version text
-----------------------------------------------
local versionText = frame:CreateFontString(nil, "OVERLAY", "IVSP_FONT")
versionText:SetPoint("BOTTOMLEFT", frame, "TOPRIGHT", 5, 2)
versionText:Hide()

-----------------------------------------------
-- frame (help)
-----------------------------------------------
local helpFrame = CreateFrame("Frame", "IcyVeinsStatPriorityHelpFrame", frame, "BackdropTemplate")
helpFrame:Hide()
helpFrame:SetSize(250, 70)
helpFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 1, 0)
helpFrame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})

local gotItBtn = CreateButton(helpFrame, {0.41, 0.8, 0.94, 1}, {0, 0, 0, 1}, 100, 20, L["Got it!"])
gotItBtn:SetPoint("BOTTOMLEFT", 5, 5)
gotItBtn:SetPoint("BOTTOMRIGHT", -5, 5)
gotItBtn:SetScript("OnClick", function()
    helpFrame:Hide()
    IVSP_Config["helpViewed"] = true
end)

-- NOTE: used to update width
local helpFrameHiddenText = helpFrame:CreateFontString(nil, "OVERLAY", "IVSP_FONT_P")
helpFrameHiddenText:Hide()

local helpFrameText = helpFrame:CreateFontString(nil, "OVERLAY", "IVSP_FONT_P")
helpFrameText:SetPoint("TOPLEFT", 5, -5)
-- helpFrameText:SetPoint("BOTTOMRIGHT", -5, 5)
helpFrameText:SetJustifyH("LEFT")
helpFrameText:SetSpacing(5)

local function ShowHelpFrame(bgColor, borderColor)
    helpFrame:SetBackdropColor(unpack(bgColor))
    helpFrame:SetBackdropBorderColor(unpack(borderColor))
    helpFrameText:SetText(L["HELP"])
    -- resize
    helpFrameHiddenText:SetText(string.match(helpFrameText:GetText(), ".+\n(.+)\n.+"))
    helpFrame:Show()
    C_Timer.After(0, function()
        helpFrame:SetSize(helpFrameHiddenText:GetStringWidth() + 10, helpFrameHiddenText:GetStringHeight() * 3 + 45)
    end)
end

-----------------------------------------------
-- color picker -- https://wow.gamepedia.com/Using_the_ColorPickerFrame
-----------------------------------------------
local colorPicker
local function IVSPColorCallback(restore)
    local newR, newG, newB, newA
    if restore then -- canceled
        newR, newG, newB, newA = restore.r, restore.g, restore.b, restore.a
    else
        newA, newR, newG, newB = ColorPickerFrame:GetColorAlpha(), ColorPickerFrame:GetColorRGB()
    end

    colorPicker:SetBackdropColor(newR, newG, newB, newA)
    if colorPicker:GetName() == "IcyVeinsBGColorPicker" then
        IVSP_Config["bgColor"] = {newR, newG, newB, newA}
        frame:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
        addBtn:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
        for _, i in pairs(items) do
            i:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
        end
    elseif colorPicker:GetName() == "IcyVeinsBorderColorPicker" then
        IVSP_Config["borderColor"] = {newR, newG, newB, newA}
        frame:SetBackdropBorderColor(unpack(IVSP_Config["borderColor"]))
        addBtn:SetBackdropBorderColor(unpack(IVSP_Config["borderColor"]))
        for _, i in pairs(items) do
            i:SetBackdropBorderColor(unpack(IVSP_Config["borderColor"]))
        end
    elseif colorPicker:GetName() == "IcyVeinsFontColorPicker" then
        IVSP_Config["fontColor"] = {newR, newG, newB, newA}
        IVSP_FONT:SetTextColor(unpack(IVSP_Config["fontColor"]))
    end
end

local function ShowColorPicker(colorTable, changedCallback)
    ColorPickerFrame:Hide() -- reset

    local r, g, b, a = unpack(colorTable)

    ColorPickerFrame:SetupColorPickerAndShow({
        r = r,
        g = g,
        b = b,
        hasOpacity = a ~= nil,
        opacity = a,
        swatchFunc = changedCallback,
        opacityFunc = changedCallback,
        cancelFunc  = changedCallback,
        previousValues = colorTable,
    })

    -- ColorPickerFrame:ClearAllPoints()
    -- ColorPickerFrame:SetPoint("CENTER", UIParent)
end

local function CreateColorPicker(name, colorTable, tooltip)
    local picker = CreateFrame("Button", name, frame, "BackdropTemplate")
    picker:SetSize(15, 15)
    picker:Hide()
    picker:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
    picker:SetBackdropBorderColor(.8, .8, .8, 1)
    picker:SetScript("OnHide", function() picker:Hide() end)
    picker:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    picker:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            colorPicker = picker
            ShowColorPicker(IVSP_Config[colorTable], IVSPColorCallback)
        elseif button == "RightButton" then
            if colorTable == "bgColor" then
                IVSP_Config["bgColor"] = {0.1, 0.1, 0.1, 0.9}
                frame:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
                for _, i in pairs(items) do
                    i:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
                end
                picker:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
            elseif colorTable == "borderColor" then
                IVSP_Config["borderColor"] = {0, 0, 0, 1}
                frame:SetBackdropBorderColor(unpack(IVSP_Config["borderColor"]))
                for _, i in pairs(items) do
                    i:SetBackdropBorderColor(unpack(IVSP_Config["borderColor"]))
                end
                picker:SetBackdropColor(unpack(IVSP_Config["borderColor"]))
            elseif colorTable == "fontColor" then
                IVSP_Config["fontColor"] = {1, 1, 1, 1}
                IVSP_FONT:SetTextColor(unpack(IVSP_Config["fontColor"]))
                picker:SetBackdropColor(unpack(IVSP_Config["fontColor"]))
            end
        end
    end)

    picker:SetScript("OnEnter", function()
        GameTooltip:SetOwner(picker, "ANCHOR_TOP")
        GameTooltip:AddLine(tooltip)
        GameTooltip:AddLine("|cffffffff"..L["Right-Click to reset"])
        GameTooltip:Show()
    end)

    picker:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    return picker
end

local bgColorPicker = CreateColorPicker("IcyVeinsBGColorPicker", "bgColor", L["Background Color"])
bgColorPicker:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, 1)

local borderColorPicker = CreateColorPicker("IcyVeinsBorderColorPicker", "borderColor", L["Border Color"])
borderColorPicker:SetPoint("RIGHT", bgColorPicker, "LEFT", -1, 0)

local fontColorPicker = CreateColorPicker("IcyVeinsFontColorPicker", "fontColor", L["Font Color"])
fontColorPicker:SetPoint("RIGHT", borderColorPicker, "LEFT", -1, 0)

-----------------------------------------------
-- custom editbox
-----------------------------------------------
local function ShowCustomFrame(sp, desc, k, isSelected)
    if not customFrame then
        customFrame = CreateFrame("Frame", nil, addBtn)
        customFrame:Hide()
        customFrame:SetSize(280, 50)
        customFrame:SetPoint("TOPLEFT", addBtn, "BOTTOMLEFT", 0, -1)
        customFrame:SetScript("OnHide", function()
            customFrame:Hide()
            for _, item in pairs(items) do
                if item.del then
                    item.del:SetEnabled(true)
                    item.del:SetBackdropColor(0.6, 0.1, 0.1, 1)
                end
            end
        end)
        -- prevent k error
        customFrame:SetScript("OnShow", function()
            for _, item in pairs(items) do
                if item.del then
                    item.del:SetEnabled(false)
                    item.del:SetBackdropColor(0.4, 0.4, 0.4, 1)
                end
            end
        end)

        local height = select(2, IVSP_FONT:GetFont()) + 7

        customFrame.eb1 = CreateFrame("EditBox", nil, customFrame, "BackdropTemplate")
        customFrame.eb1:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
        customFrame.eb1:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        customFrame.eb1:SetBackdropBorderColor(0, 0, 0, 1)
        customFrame.eb1:SetFontObject(IVSP_FONT)
        customFrame.eb1:SetMultiLine(false)
        customFrame.eb1:SetMaxLetters(0)
        customFrame.eb1:SetJustifyH("LEFT")
        customFrame.eb1:SetJustifyV("MIDDLE")
        customFrame.eb1:SetWidth(300)
        customFrame.eb1:SetHeight(height)
        customFrame.eb1:SetTextInsets(5, 5, 0, 0)
        customFrame.eb1:SetAutoFocus(false)
        customFrame.eb1:SetScript("OnEscapePressed", function() customFrame.eb1:ClearFocus() end)
        customFrame.eb1:SetScript("OnEnterPressed", function() customFrame.eb1:ClearFocus() end)
        customFrame.eb1:SetScript("OnEditFocusGained", function() customFrame.eb1:HighlightText() end)
        customFrame.eb1:SetScript("OnEditFocusLost", function() customFrame.eb1:HighlightText(0, 0) end)

        customFrame.eb2 = CreateFrame("EditBox", nil, customFrame, "BackdropTemplate")
        customFrame.eb2:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
        customFrame.eb2:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        customFrame.eb2:SetBackdropBorderColor(0, 0, 0, 1)
        customFrame.eb2:SetFontObject(IVSP_FONT)
        customFrame.eb2:SetMultiLine(false)
        customFrame.eb2:SetMaxLetters(0)
        customFrame.eb2:SetJustifyH("LEFT")
        customFrame.eb2:SetJustifyV("MIDDLE")
        customFrame.eb2:SetTextInsets(5, 5, 0, 0)
        customFrame.eb2:SetAutoFocus(false)
        customFrame.eb2:SetScript("OnEscapePressed", function() customFrame.eb2:ClearFocus() end)
        customFrame.eb2:SetScript("OnEnterPressed", function() customFrame.eb2:ClearFocus() end)
        customFrame.eb2:SetScript("OnEditFocusGained", function() customFrame.eb2:HighlightText() end)
	    customFrame.eb2:SetScript("OnEditFocusLost", function() customFrame.eb2:HighlightText(0, 0) end)
        customFrame.eb2:SetPoint("TOPLEFT", customFrame.eb1, "BOTTOMLEFT", 0, -1)

        customFrame.cancelBtn = CreateButton(customFrame, {0.6, 0.1, 0.1, 1}, {0, 0, 0, 1}, height, height, "×")
        customFrame.cancelBtn:SetPoint("TOPRIGHT", customFrame.eb1, "BOTTOMRIGHT", 0, -1)
        customFrame.cancelBtn:SetScript("OnClick", function() customFrame:Hide() end)

        customFrame.confirmBtn = CreateButton(customFrame, {0.1, 0.6, 0.1, 1}, {0, 0, 0, 1}, height, height, "√")
        customFrame.confirmBtn:SetPoint("RIGHT", customFrame.cancelBtn, "LEFT", 1, 0)

        customFrame.eb1:SetPoint("TOPLEFT")
        customFrame.eb2:SetPoint("BOTTOMRIGHT", customFrame.confirmBtn, "BOTTOMLEFT", 1, 0)

        customFrame.eb1:SetScript("OnTextChanged", function(self, userInput)
            -- if not userInput then return end
            if string.trim(self:GetText()) == "" then
                customFrame.eb1.valid = false

            else
                customFrame.eb1.valid = true
            end

            if customFrame.eb1.valid and customFrame.eb2.valid then
                customFrame.confirmBtn:SetEnabled(true)
                customFrame.confirmBtn:SetBackdropColor(0.1, 0.6, 0.1, 1)
            else
                customFrame.confirmBtn:SetEnabled(false)
                customFrame.confirmBtn:SetBackdropColor(0.4, 0.4, 0.4, 1)
            end
        end)
        customFrame.eb2:SetScript("OnTextChanged", function(self, userInput)
            -- if not userInput then return end
            if string.trim(self:GetText()) == "" then
                customFrame.eb2.valid = false

            else
                customFrame.eb2.valid = true
            end

            if customFrame.eb1.valid and customFrame.eb2.valid then
                customFrame.confirmBtn:SetEnabled(true)
                customFrame.confirmBtn:SetBackdropColor(0.1, 0.6, 0.1, 1)
            else
                customFrame.confirmBtn:SetEnabled(false)
                customFrame.confirmBtn:SetBackdropColor(0.4, 0.4, 0.4, 1)
            end
        end)
    end

    -- update db
    customFrame.confirmBtn:SetScript("OnClick", function()
        if k then -- edit
            IVSP_Custom[currentSpecID][k] = {string.trim(customFrame.eb1:GetText()), string.trim(customFrame.eb2:GetText())}
            if isSelected then -- current shown
                SetText(IVSP_Custom[currentSpecID][k][1])
            end
        else
            if type(IVSP_Custom[currentSpecID]) ~= "table" then IVSP_Custom[currentSpecID] = {} end
            table.insert(IVSP_Custom[currentSpecID], {string.trim(customFrame.eb1:GetText()), string.trim(customFrame.eb2:GetText())})
        end
        customFrame:Hide()
        IVSP:LoadList()
        frame:Click()
    end)

    customFrame.eb1:SetText(sp or L["Stat Priority"])
    customFrame.eb1:ClearFocus()
    customFrame.eb2:SetText(desc or L["Description"])
    customFrame.eb2:ClearFocus()
    customFrame:Show()
end


-----------------------------------------------
-- list button functions
-----------------------------------------------
local textWidth = 0
local function AddItem(text, k)
    local item = CreateButton(frame, IVSP_Config["bgColor"], IVSP_Config["borderColor"], 200, select(2, IVSP_FONT:GetFont()) + 7, text)
    item:Hide()
    textWidth = math.max(item:GetFontString():GetStringWidth(), textWidth)

    -- highlight texture
    item.highlight = item:CreateTexture()
    item.highlight:SetColorTexture(0.41, 0.8, 0.94, 1)
    item.highlight:SetSize(5, item:GetHeight() - 2)
    item.highlight:SetPoint("LEFT", 1, 0)
    item.highlight:Hide()

    -- delete/edit button
    if k then
        item.edit = CreateButton(item, {0, 0.5, 0.8, 1}, IVSP_Config["borderColor"], item:GetHeight(), item:GetHeight(), "!")
        item.edit:SetPoint("LEFT", item, "RIGHT", -1, 0)
        item.edit:SetScript("OnClick", function()
            ShowCustomFrame(IVSP_Custom[currentSpecID][k][1], IVSP_Custom[currentSpecID][k][2], k, IVSP_Config["selected"][currentSpecID] == item.n)
        end)

        item.del = CreateButton(item, {0.6, 0.1, 0.1, 1}, IVSP_Config["borderColor"], item:GetHeight(), item:GetHeight(), "×")
        item.del:SetPoint("LEFT", item.edit, "RIGHT", -1, 0)
        item.del:SetScript("OnClick", function()
            if IsShiftKeyDown() then
                -- remove from custom table
                table.remove(IVSP_Custom[currentSpecID], k)
                -- check whether custom table is empty
                if #IVSP_Custom[currentSpecID] == 0 then
                    IVSP_Custom[currentSpecID] = nil
                end

                if IVSP_Config["selected"][currentSpecID] == item.n then -- current selected
                    IVSP_Config["selected"][currentSpecID] = 1
                end
                SetText(IVSP:GetSPText(currentSpecID))
                IVSP:LoadList()
                frame:Click()
            else
                print("|cff69CCF0IVSP:|r "..L["Shift + Left-Click to delete it."])
            end
        end)
    end

    table.insert(items, item)
    item.n = #items

    item:SetScript("OnHide", function() item:Hide() end)

    item:SetScript("OnClick", function()
        isItemsShown = false

        bgColorPicker:Hide()
        borderColorPicker:Hide()
        fontColorPicker:Hide()
        addBtn:Hide()
        versionText:Hide()

        for _, i in pairs(items) do
            i.highlight:Hide()
            i:Hide()
        end
        item.highlight:Show()
        IVSP_Config["selected"][currentSpecID] = item.n
        SetText(IVSP:GetSPText(currentSpecID))
    end)
end

-----------------------------------------------
-- load list
-----------------------------------------------
function IVSP:LoadList()
    isItemsShown = false
    bgColorPicker:Hide()
    borderColorPicker:Hide()
    fontColorPicker:Hide()
    versionText:Hide()

    textWidth = 0
    for _, i in pairs(items) do
        i:ClearAllPoints()
        i:Hide()
        i:SetParent(nil)
    end
    wipe(items)

    -- "+" button
    if not addBtn then addBtn = CreateButton(frame, IVSP_Config["bgColor"], IVSP_Config["borderColor"], select(2, IVSP_FONT:GetFont()) + 7, select(2, IVSP_FONT:GetFont()) + 7, "+") end
    -- addBtn:SetTexture("Interface\\Addons\\IcyVeinsStatPriority\\Media\\create.blp", {16, 16}, {"CENTER", 0, 0})
    addBtn:Hide()
    addBtn:ClearAllPoints()
    addBtn:SetPoint("TOPLEFT", frame, "TOPRIGHT", 1, 0)
    addBtn:SetScript("OnHide", function() addBtn:Hide() end)
    addBtn:SetScript("OnClick", function()
        ShowCustomFrame()
    end)

    local desc = IVSP:GetSPDesc(currentSpecID)

    for k, t in pairs(desc) do
        AddItem(t[1], t[2])
        if k == 1 then
            items[1]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 1, 0)
        else
            items[k]:SetPoint("TOPLEFT", items[k-1], "BOTTOMLEFT", 0, -1)
        end
    end

    if #items == 0 then
        addBtn:Hide()
        return
    end

    -- re-set "+" buttona point
    addBtn:ClearAllPoints()
    addBtn:SetPoint("TOPLEFT", items[#items], "BOTTOMLEFT", 0, -1)

    -- update width
    for _, i in pairs(items) do
        i:SetWidth(textWidth + 20)
    end

    -- highlight selected
    if IVSP_Config["selected"][currentSpecID] then
        items[IVSP_Config["selected"][currentSpecID]].highlight:Show()
    else -- highlight first
        items[1].highlight:Show()
    end
end

-----------------------------------------------
-- class frame
-----------------------------------------------
local classFrame = CreateFrame("Frame", "IcyVeinsStatPriorityClassFrame", frame)
classFrame:SetPoint("TOPLEFT", frame, "TOPRIGHT", 1, 0)
classFrame:SetSize(100, 300)
classFrame:Hide()

local specFrame = CreateFrame("Frame", "IcyVeinsStatPrioritySpecFrame", classFrame, "BackdropTemplate")
specFrame:SetPoint("TOPLEFT", classFrame, "TOPRIGHT", 1, 0)
specFrame:SetSize(100, 100)
specFrame:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1})
specFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
specFrame:Hide()

local content = CreateFrame("SimpleHTML", nil, specFrame)
-- content:SetPoint("TOP", 0, -5)
-- content:SetWidth(specFrame:GetWidth() - 10)
content:SetPoint("TOPLEFT", 5, -5)
content:SetPoint("TOPRIGHT", -5, -5)
content:SetHeight(20)
content:SetSpacing("p", 5)
content:SetFontObject("p", "IVSP_FONT_P")

content:SetScript("OnHyperlinkClick", function(self, link, text, button)
    -- NOTE: text => |HPaladin-Protection|h***********|h
    text = string.match(text, ".*\124h(.+)\124h.*")
    local editBox = ChatEdit_ChooseBoxForSend()
    ChatEdit_ActivateChat(editBox)
    editBox:SetText("[" .. link .. "] " .. text)
end)

local classLoaded
classFrame:SetScript("OnHide", function()
    classFrame:Hide()
    specFrame:Hide()
    classLoaded = 0
end)

-- NOTE: used to update specFrame
local specFrameHiddenText = specFrame:CreateFontString(nil, "OVERLAY", "IVSP_FONT_P")
specFrameHiddenText:Hide()

-----------------------------------------------
-- load classes
-----------------------------------------------
local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local classBtns = {}
function IVSP:LoadClasses()
    if not classLoaded then
        classLoaded = 0
        local textWidth = 0

        for classID = 1, 13 do
            local className, classFile = GetClassInfo(classID)
            local r, g, b = RAID_CLASS_COLORS[classFile].r, RAID_CLASS_COLORS[classFile].g, RAID_CLASS_COLORS[classFile].b
            local colorStr = "|c" .. RAID_CLASS_COLORS[classFile].colorStr

            classBtns[classID] = CreateButton(classFrame, {0.1, 0.1, 0.1, 0.9}, {r, g, b, 1},
                select(2, IVSP_FONT:GetFont()) + 7, select(2, IVSP_FONT:GetFont()) + 7, colorStr .. className)
            textWidth = math.max(textWidth, classBtns[classID]:GetFontString():GetStringWidth())

            if classID == 1 then
                classBtns[classID]:SetPoint("TOPLEFT")
            else
                classBtns[classID]:SetPoint("TOP", classBtns[classID - 1], "BOTTOM", 0, -1)
            end

            -- specs
            for specIndex = 1, 4 do
                local specID = GetSpecializationInfoForClassID(classID, specIndex)
                if specID then
                    if not classBtns[classID]["specs"] then classBtns[classID]["specs"] = {} end
                    tinsert(classBtns[classID]["specs"], specID)
                end
            end

            -- highlight
            classBtns[classID].highlight = classBtns[classID]:CreateTexture(nil, "ARTWORK")
            classBtns[classID].highlight:SetPoint("TOPRIGHT")
            classBtns[classID].highlight:SetPoint("BOTTOMLEFT", classBtns[classID], "BOTTOM")
            classBtns[classID].highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
            classBtns[classID].highlight:SetGradient("HORIZONTAL", CreateColor(r, g, b, 0), CreateColor(r, g, b, 0.77))
            classBtns[classID].highlight:Hide()

            classBtns[classID]:SetScript("OnHide", function(self)
                self.highlight:Hide()
            end)

            -- onclick
            classBtns[classID]:SetScript("OnClick", function(self)
                if classLoaded == classID then return end
                classLoaded = classID

                for i = 1, 13 do
                    classBtns[i].highlight:Hide()
                end
                self.highlight:Show()

                -- load
                local maxWidth = 0
                local details = ""
                for _, specID in pairs(classBtns[classID]["specs"]) do
                    local _, specName = GetSpecializationInfoByID(specID)
                    details = details .. "<p>[" .. specName .. "]</p>"

                    for _, sp in pairs(IVSP:GetSP(specID)) do
                        details = details .. "<p>" .. colorStr .. "<a href=\"" .. className .. " - " .. specName .. "\">" .. sp .. "</a>|r</p>"
                        specFrameHiddenText:SetText(sp)
                        maxWidth = math.max(specFrameHiddenText:GetStringWidth(), maxWidth)
                    end
                    details = details .. "<br/>"
                end
                details = details .. "<p>|cFFB2B2B2" .. L["Click on stat priority text to send."] .. "|r</p>"
                content:SetText("<html><body>" .. details .. "</body></html>")

                specFrameHiddenText:SetText(L["Click on stat priority text to send."])
                maxWidth = math.max(specFrameHiddenText:GetStringWidth(), maxWidth)

                content:SetHeight(content:GetContentHeight())
                specFrame:SetHeight(content:GetContentHeight() + 10)
                specFrame:SetWidth(maxWidth + 10)

                specFrame:SetBackdropBorderColor(r, g, b)
                specFrame:Show()
            end)
        end

        classFrame:SetWidth(textWidth + 20)
        for _, b in pairs(classBtns) do
            b:SetWidth(textWidth + 20)
        end
    end
end

-----------------------------------------------
-- frame scripts
-----------------------------------------------
frame:SetScript("OnHide", function()
    isItemsShown = false
    versionText:Hide()
end)

frame:SetScript("OnClick", function(self, button, down)
    if button == "LeftButton" then
        classFrame:Hide()
        if isItemsShown then
            isItemsShown = false
            for _, i in pairs(items) do
                i:Hide()
            end
            bgColorPicker:Hide()
            borderColorPicker:Hide()
            fontColorPicker:Hide()
            addBtn:Hide()
            versionText:Hide()
        else
            isItemsShown = true
            for _, i in pairs(items) do
                i:Show()
            end
            bgColorPicker:Show()
            borderColorPicker:Show()
            fontColorPicker:Show()
            if #items ~= 0 then addBtn:Show() end
            versionText:Show()
        end
    elseif button == "RightButton" then
        if classFrame:IsShown() then
            classFrame:Hide()
            versionText:Hide()
        else
            isItemsShown = false
            for _, i in pairs(items) do
                i:Hide()
            end
            bgColorPicker:Hide()
            borderColorPicker:Hide()
            fontColorPicker:Hide()
            addBtn:Hide()

            IVSP:LoadClasses()
            classFrame:Show()
            versionText:Show()
        end
    end

    -- hide help on click
    if helpFrame:IsShown() then
        helpFrame:Hide()
    end
end)

-----------------------------------------------
-- event
-----------------------------------------------
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
frame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

function frame:ADDON_LOADED(arg1)
    if arg1 == addonName then
        if type(IVSP_Custom) ~= "table" then IVSP_Custom = {} end
        if type(IVSP_Config) ~= "table" then IVSP_Config = {} end
        if type(IVSP_Config["show"]) ~= "boolean" then IVSP_Config["show"] = true end
        if type(IVSP_Config["bgColor"]) ~= "table" then IVSP_Config["bgColor"] = {0.1, 0.1, 0.1, 0.9} end
        if type(IVSP_Config["borderColor"]) ~= "table" then IVSP_Config["borderColor"] = {0, 0, 0, 1} end
        if type(IVSP_Config["fontColor"]) ~= "table" then IVSP_Config["fontColor"] = {1, 1, 1} end
        if type(IVSP_Config["fontSize"]) ~= "number" then IVSP_Config["fontSize"] = 13 end
        if type(IVSP_Config["selected"]) ~= "table" then IVSP_Config["selected"] = {} end
        if type(IVSP_Config["helpViewed"]) ~= "boolean" then IVSP_Config["helpViewed"] = false end

        SetFrame(IVSP_Config["bgColor"], IVSP_Config["borderColor"], IVSP_Config["fontColor"], IVSP_Config["fontSize"], IVSP_Config["show"])

        if not IVSP_Config["helpViewed"] then
            ShowHelpFrame(IVSP_Config["bgColor"], IVSP_Config["borderColor"])
        end

        bgColorPicker:SetBackdropColor(unpack(IVSP_Config["bgColor"]))
        borderColorPicker:SetBackdropColor(unpack(IVSP_Config["borderColor"]))
        fontColorPicker:SetBackdropColor(unpack(IVSP_Config["fontColor"]))

        versionText:SetText("Version: |cff69CCF0" .. C_AddOns.GetAddOnMetadata(addonName, "version"))
    end
end

function frame:PLAYER_ENTERING_WORLD()
    frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    currentSpecID = GetSpecializationInfoForClassID(select(3, UnitClass("player")), GetSpecialization())
    SetText(IVSP:GetSPText(currentSpecID))
    IVSP:LoadList()
end

function frame:ACTIVE_TALENT_GROUP_CHANGED()
    -- specID, name, description, iconID, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(classID, specNum)
    local specID = GetSpecializationInfoForClassID(select(3, UnitClass("player")), GetSpecialization())
    if specID ~= currentSpecID then
        currentSpecID = specID
        SetText(IVSP:GetSPText(currentSpecID))
        IVSP:LoadList()
    end
end

SLASH_ICYVEINSSTATPRIORITY1 = "/ivsp"
function SlashCmdList.ICYVEINSSTATPRIORITY(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    if command == "show" then
        frame:Show()
        IVSP_Config["show"] = true
    elseif command == "hide" then
        frame:Hide()
        IVSP_Config["show"] = false
    elseif command == "font" then
        IVSP_Config["fontSize"] = tonumber(rest) or 13
        IVSP_FONT:SetFont(GameFontNormal:GetFont(), IVSP_Config["fontSize"], "")
        frame:SetHeight(IVSP_Config["fontSize"] + 7)
    elseif command == "reset" then
        IVSP_Config = nil
        ReloadUI()
    else -- help
        print("|cff69CCF0Icy Veins Stat Priority|r "..L["help"]..":")
        print("|cff69CCF0/ivsp show/hide|r: "..L["show/hide IVSP."])
        print("|cff69CCF0/ivsp font [fontSize]|r: "..L["set font size (default 13)."])
        print("|cff69CCF0/ivsp reset|r: "..L["reset IVSP and reload UI."])
    end
end