------------------------------------------------------------
-- 光環強化 (AuraEnhance) — 設定面板
-- 註冊為獨立的介面設定分類「光環強化」
------------------------------------------------------------
local _, ns = ...

-- 字型清單：偵測到 LibSharedMedia-3.0 就用共享字型，否則退回 WoW 內建字型。
-- 每次呼叫都重新讀取，下拉選單打開時即時反映 LSM 動態註冊的字型。
local function GetFontList()
    local list = { { text = "沿用暴雪字型", value = "" } }
    local LSM = _G.LibStub and _G.LibStub("LibSharedMedia-3.0", true)
    if LSM then
        local hash = LSM:HashTable("font")
        local names = {}
        for name in pairs(hash) do names[#names + 1] = name end
        table.sort(names)
        for _, name in ipairs(names) do
            list[#list + 1] = { text = name, value = hash[name] }
        end
    else
        list[#list + 1] = { text = "Friz Quadrata", value = "Fonts\\FRIZQT__.TTF" }
        list[#list + 1] = { text = "Arial Narrow",  value = "Fonts\\ARIALN.TTF" }
        list[#list + 1] = { text = "Skurri",        value = "Fonts\\skurri.TTF" }
        list[#list + 1] = { text = "Morpheus",      value = "Fonts\\MORPHEUS.TTF" }
    end
    return list
end

local function BuildOptions()
    local Style = ns.BuffDurationStyle

    -- 依儲存的字型路徑找回顯示名稱（找不到時直接顯示路徑）
    local function FontTextOf(value)
        value = value or ""
        for _, opt in ipairs(GetFontList()) do
            if opt.value == value then return opt.text end
        end
        return value ~= "" and value or "沿用暴雪字型"
    end

    -- 建立一個字型下拉選單，選擇時呼叫 setter(path)
    -- 每次打開選單都重新取得字型清單，即時反映 LSM 動態註冊
    local function CreateFontDropdown(name, parent, setter)
        local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(dd, 140)
        UIDropDownMenu_Initialize(dd, function(self, level)
            for _, opt in ipairs(GetFontList()) do
                local value, text = opt.value, opt.text
                local info = UIDropDownMenu_CreateInfo()
                info.text = text
                info.value = value
                info.func = function()
                    UIDropDownMenu_SetSelectedValue(dd, value)
                    UIDropDownMenu_SetText(dd, text)
                    setter(value)
                end
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        return dd
    end

    -- ============================================================
    -- 光環強化 面板
    -- ============================================================
    local auraFrame = CreateFrame("Frame")
    auraFrame:SetSize(600, 700)

    local auraTitle = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    auraTitle:SetPoint("TOPLEFT", 16, -16)
    auraTitle:SetText("|cffffe00a光環時間美化|r")

    local auraDesc = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    auraDesc:SetPoint("TOPLEFT", auraTitle, "BOTTOMLEFT", 0, -8)
    auraDesc:SetText("調整增益 / 減益圖示下方時間文字的位置、大小與邊框。")
    auraDesc:SetTextColor(0.7, 0.7, 0.7)


    -- 時間文字區塊標題
    local durLabel = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    durLabel:SetPoint("TOPLEFT", auraDesc, "BOTTOMLEFT", 0, -20)
    durLabel:SetText("時間文字")

    -- 啟用 checkbox
    local auraCB = CreateFrame("CheckButton", "AuraEnhance_BuffDurEnabledCB", auraFrame, "UICheckButtonTemplate")
    auraCB:SetPoint("TOPLEFT", durLabel, "BOTTOMLEFT", 0, -8)
    auraCB.text:SetText("啟用時間文字美化")
    auraCB.text:SetFontObject("GameFontHighlight")

    local auraCBDesc = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    auraCBDesc:SetPoint("TOPLEFT", auraCB, "BOTTOMLEFT", 26, -2)
    auraCBDesc:SetWidth(520)
    auraCBDesc:SetJustifyH("LEFT")
    auraCBDesc:SetText("自訂增益 / 減益圖示下方的時間文字樣式與位置。\n不修改文字內容，純粹調整外觀。")
    auraCBDesc:SetTextColor(0.5, 0.5, 0.5)

    -- 邊框 checkbox
    local outlineCB = CreateFrame("CheckButton", "AuraEnhance_BuffDurOutlineCB", auraFrame, "UICheckButtonTemplate")
    outlineCB:SetPoint("TOPLEFT", auraCBDesc, "BOTTOMLEFT", -26, -12)
    outlineCB.text:SetText("文字邊框")
    outlineCB.text:SetFontObject("GameFontHighlight")

    local outlineDesc = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    outlineDesc:SetPoint("TOPLEFT", outlineCB, "BOTTOMLEFT", 26, -2)
    outlineDesc:SetText("為時間文字加上 1px 黑色邊框以提升可讀性")
    outlineDesc:SetTextColor(0.5, 0.5, 0.5)

    -- 文字大小 slider
    local fontSizeSlider = CreateFrame("Slider", "AuraEnhance_BuffDurFontSizeSlider", auraFrame, "OptionsSliderTemplate")
    fontSizeSlider:SetPoint("TOPLEFT", outlineDesc, "BOTTOMLEFT", -26, -18)
    fontSizeSlider:SetSize(200, 16)
    fontSizeSlider:SetMinMaxValues(7, 16)
    fontSizeSlider:SetValueStep(1)
    fontSizeSlider:SetObeyStepOnDrag(true)
    fontSizeSlider.Low:SetText("7")
    fontSizeSlider.High:SetText("16")
    fontSizeSlider.Text:SetText("文字大小")

    local fontSizeValue = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fontSizeValue:SetPoint("LEFT", fontSizeSlider, "RIGHT", 12, 0)

    -- Y 軸偏移 slider
    local yOffsetSlider = CreateFrame("Slider", "AuraEnhance_BuffDurYOffsetSlider", auraFrame, "OptionsSliderTemplate")
    yOffsetSlider:SetPoint("TOPLEFT", fontSizeSlider, "BOTTOMLEFT", 0, -26)
    yOffsetSlider:SetSize(200, 16)
    yOffsetSlider:SetMinMaxValues(-10, 20)
    yOffsetSlider:SetValueStep(1)
    yOffsetSlider:SetObeyStepOnDrag(true)
    yOffsetSlider.Low:SetText("-10")
    yOffsetSlider.High:SetText("20")
    yOffsetSlider.Text:SetText("垂直位移")

    local yOffsetValue = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    yOffsetValue:SetPoint("LEFT", yOffsetSlider, "RIGHT", 12, 0)

    -- 時間文字字型
    local durFontLabel = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    durFontLabel:SetPoint("TOPLEFT", yOffsetSlider, "BOTTOMLEFT", 0, -30)
    durFontLabel:SetText("字型：")

    local durFontDropdown = CreateFontDropdown("AuraEnhance_BuffDurFontDropdown", auraFrame, function(path)
        if Style then Style.SetFontFace(path) end
    end)
    durFontDropdown:SetPoint("LEFT", durFontLabel, "RIGHT", -8, -2)

    -- ============================================================
    -- 堆疊層數區塊
    -- ============================================================
    local countLabel = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    countLabel:SetPoint("TOPLEFT", durFontLabel, "BOTTOMLEFT", 0, -28)
    countLabel:SetText("堆疊層數")

    -- 啟用堆疊層數調整
    local countCB = CreateFrame("CheckButton", "AuraEnhance_CountEnabledCB", auraFrame, "UICheckButtonTemplate")
    countCB:SetPoint("TOPLEFT", countLabel, "BOTTOMLEFT", 0, -8)
    countCB.text:SetText("啟用層數位置調整")
    countCB.text:SetFontObject("GameFontHighlight")

    local countCBDesc = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    countCBDesc:SetPoint("TOPLEFT", countCB, "BOTTOMLEFT", 26, -2)
    countCBDesc:SetWidth(520)
    countCBDesc:SetJustifyH("LEFT")
    countCBDesc:SetText("自訂堆疊層數文字的位置與字型。")
    countCBDesc:SetTextColor(0.5, 0.5, 0.5)

    -- 錨點下拉選單
    local anchorOptions = {
        { text = "左上", value = "TOPLEFT" },
        { text = "上", value = "TOP" },
        { text = "右上", value = "TOPRIGHT" },
        { text = "左", value = "LEFT" },
        { text = "右", value = "RIGHT" },
        { text = "左下", value = "BOTTOMLEFT" },
        { text = "下", value = "BOTTOM" },
        { text = "右下", value = "BOTTOMRIGHT" },
    }

    local anchorLabel = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    anchorLabel:SetPoint("TOPLEFT", countCBDesc, "BOTTOMLEFT", -26, -14)
    anchorLabel:SetText("位置：")

    local anchorDropdown = CreateFrame("Frame", "AuraEnhance_CountAnchorDropdown", auraFrame, "UIDropDownMenuTemplate")
    anchorDropdown:SetPoint("LEFT", anchorLabel, "RIGHT", -8, -2)
    UIDropDownMenu_SetWidth(anchorDropdown, 100)

    local function AnchorDropdown_Initialize(self, level)
        for _, opt in ipairs(anchorOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = opt.text .. "  (" .. opt.value .. ")"
            info.value = opt.value
            info.func = function(item)
                UIDropDownMenu_SetSelectedValue(anchorDropdown, item.value)
                UIDropDownMenu_SetText(anchorDropdown, opt.text)
                if Style then
                    Style.SetCountAnchor(item.value)
                end
            end
            info.checked = nil
            UIDropDownMenu_AddButton(info, level)
        end
    end
    UIDropDownMenu_Initialize(anchorDropdown, AnchorDropdown_Initialize)

    -- X 軸偏移
    local countXSlider = CreateFrame("Slider", "AuraEnhance_CountXOffsetSlider", auraFrame, "OptionsSliderTemplate")
    countXSlider:SetPoint("TOPLEFT", anchorLabel, "BOTTOMLEFT", 0, -22)
    countXSlider:SetSize(200, 16)
    countXSlider:SetMinMaxValues(-20, 20)
    countXSlider:SetValueStep(1)
    countXSlider:SetObeyStepOnDrag(true)
    countXSlider.Low:SetText("-20")
    countXSlider.High:SetText("20")
    countXSlider.Text:SetText("水平位移")

    local countXValue = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    countXValue:SetPoint("LEFT", countXSlider, "RIGHT", 12, 0)

    -- Y 軸偏移
    local countYSlider = CreateFrame("Slider", "AuraEnhance_CountYOffsetSlider", auraFrame, "OptionsSliderTemplate")
    countYSlider:SetPoint("TOPLEFT", countXSlider, "BOTTOMLEFT", 0, -26)
    countYSlider:SetSize(200, 16)
    countYSlider:SetMinMaxValues(-20, 20)
    countYSlider:SetValueStep(1)
    countYSlider:SetObeyStepOnDrag(true)
    countYSlider.Low:SetText("-20")
    countYSlider.High:SetText("20")
    countYSlider.Text:SetText("垂直位移")

    local countYValue = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    countYValue:SetPoint("LEFT", countYSlider, "RIGHT", 12, 0)

    -- 堆疊層數字型
    local countFontLabel = auraFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    countFontLabel:SetPoint("TOPLEFT", countYSlider, "BOTTOMLEFT", 0, -24)
    countFontLabel:SetText("字型：")

    local countFontDropdown = CreateFontDropdown("AuraEnhance_CountFontDropdown", auraFrame, function(path)
        if Style then Style.SetCountFontFace(path) end
    end)
    countFontDropdown:SetPoint("LEFT", countFontLabel, "RIGHT", -8, -2)

    -- 控制子選項的啟用/反灰狀態
    local function UpdateCountSubControls(enabled)
        if enabled then
            anchorDropdown:SetAlpha(1)
            countXSlider:Enable()
            countYSlider:Enable()
            UIDropDownMenu_EnableDropDown(countFontDropdown)
        else
            anchorDropdown:SetAlpha(0.5)
            countXSlider:Disable()
            countYSlider:Disable()
            UIDropDownMenu_DisableDropDown(countFontDropdown)
        end
    end

    local function UpdateSubControlsState(enabled)
        if enabled then
            outlineCB:Enable()
            outlineCB.text:SetFontObject("GameFontHighlight")
            fontSizeSlider:Enable()
            yOffsetSlider:Enable()
            UIDropDownMenu_EnableDropDown(durFontDropdown)
            countCB:Enable()
            countCB.text:SetFontObject("GameFontHighlight")
        else
            outlineCB:Disable()
            outlineCB.text:SetFontObject("GameFontDisable")
            fontSizeSlider:Disable()
            yOffsetSlider:Disable()
            UIDropDownMenu_DisableDropDown(durFontDropdown)
            countCB:Disable()
            countCB.text:SetFontObject("GameFontDisable")
            UpdateCountSubControls(false)
        end
    end

    -- 同步光環設定
    local function SyncAuraSettings()
        if not Style then return end
        local db = Style.GetDB()
        auraCB:SetChecked(db.enabled)
        outlineCB:SetChecked(db.outline)
        fontSizeSlider:SetValue(db.fontSize)
        fontSizeValue:SetText(db.fontSize)
        yOffsetSlider:SetValue(db.yOffset)
        yOffsetValue:SetText(db.yOffset)
        UIDropDownMenu_SetSelectedValue(durFontDropdown, db.fontFace or "")
        UIDropDownMenu_SetText(durFontDropdown, FontTextOf(db.fontFace))
        -- 堆疊層數
        countCB:SetChecked(db.countEnabled)
        UIDropDownMenu_SetSelectedValue(countFontDropdown, db.countFontFace or "")
        UIDropDownMenu_SetText(countFontDropdown, FontTextOf(db.countFontFace))
        UIDropDownMenu_SetSelectedValue(anchorDropdown, db.countAnchor)
        for _, opt in ipairs(anchorOptions) do
            if opt.value == db.countAnchor then
                UIDropDownMenu_SetText(anchorDropdown, opt.text)
                break
            end
        end
        countXSlider:SetValue(db.countXOffset)
        countXValue:SetText(db.countXOffset)
        countYSlider:SetValue(db.countYOffset)
        countYValue:SetText(db.countYOffset)
        UpdateSubControlsState(db.enabled)
        if db.enabled then
            UpdateCountSubControls(db.countEnabled)
        end
    end
    SyncAuraSettings()
    auraFrame:SetScript("OnShow", SyncAuraSettings)

    auraCB:HookScript("OnClick", function(self)
        if not Style then return end
        local enabled = self:GetChecked() and true or false
        Style.SetEnabled(enabled)
        UpdateSubControlsState(enabled)
        if enabled then
            UpdateCountSubControls(countCB:GetChecked())
        end
        print("|cff00ff00[光環時間美化]|r 時間文字美化:", enabled and "開" or "關")
    end)

    outlineCB:HookScript("OnClick", function(self)
        if not Style then return end
        local enabled = self:GetChecked() and true or false
        Style.SetOutline(enabled)
        print("|cff00ff00[光環時間美化]|r 文字邊框:", enabled and "開" or "關")
    end)

    fontSizeSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        fontSizeValue:SetText(value)
        if Style then
            Style.SetFontSize(value)
        end
    end)

    yOffsetSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        yOffsetValue:SetText(value)
        if Style then
            Style.SetYOffset(value)
        end
    end)

    countCB:HookScript("OnClick", function(self)
        if not Style then return end
        local enabled = self:GetChecked() and true or false
        Style.SetCountEnabled(enabled)
        UpdateCountSubControls(enabled)
        print("|cff00ff00[光環時間美化]|r 層數位置調整:", enabled and "開" or "關")
    end)

    countXSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        countXValue:SetText(value)
        if Style then
            Style.SetCountXOffset(value)
        end
    end)

    countYSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        countYValue:SetText(value)
        if Style then
            Style.SetCountYOffset(value)
        end
    end)

    -- 註冊為獨立的頂層設定分類
    local category = Settings.RegisterCanvasLayoutCategory(auraFrame, "光環時間")

    Settings.RegisterAddOnCategory(category)
    MiliUI_AuraEnhanceDB.categoryID = category:GetID()
end

-- 等 SavedVariables 載入後再建立面板（確保同步顯示正確的值）
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    BuildOptions()
end)
