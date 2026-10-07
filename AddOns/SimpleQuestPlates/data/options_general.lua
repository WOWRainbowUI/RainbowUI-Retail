--=====================================================================================
-- RGX | Simple Quest Plates! - options_general.lua

-- Author: DonnieDice
-- Description: Global card grid and preview-selected per-type settings.
--              Animation and Quest Toast live on the separate Animation tab.
--=====================================================================================

local addonName, SQP = ...
local SQPSettings = SQP.db.global

local function Card(host, title, opts)
    return SQP:CreateCard(host, title, opts)
end

-- Global display-mode controls share a single framework row.
local function BuildDisplayModes(parent, yOffset)
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, yOffset)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, yOffset)
    row:SetHeight(22)
    local left, right = SQP:CreateOptionColumns(row)

    local task = SQP:CreateStyledCheckbox(left, "Task Icons")
    task:SetPoint("TOPLEFT", left, "TOPLEFT", 0, 0)
    task:SetPoint("TOPRIGHT", left, "TOPRIGHT", 0, 0)
    task.checkbox:SetChecked(SQPSettings.showKillIcon ~= false
        or SQPSettings.showLootIcon ~= false or SQPSettings.showPercentIcon == true)
    SQP.optionControls.showQuestTypeIcons = task.checkbox
    task.checkbox:SetScript("OnClick", function(self)
        local enabled = self:GetChecked() and true or false
        for _, key in ipairs({ "showKillIcon", "showLootIcon", "showPercentIcon" }) do
            SQP:SetSetting(key, enabled)
            local control = SQP.optionControls[key]
            if control then control:SetChecked(enabled) end
        end
        SQP:RefreshAllNameplates()
        SQP:UpdatePreviewManually()
    end)

    local text = SQP:CreateStyledCheckbox(right, "Text Mode")
    text:SetPoint("TOPLEFT", right, "TOPLEFT", 0, 0)
    text:SetPoint("TOPRIGHT", right, "TOPRIGHT", 0, 0)
    text.checkbox:SetChecked(SQPSettings.showIconBackground == false)
    SQP.optionControls.showIconBackgroundTextOnly = text.checkbox
    text.checkbox:SetScript("OnClick", function(self)
        if self:GetChecked() then
            SQP:SetSetting("showIconBackground", false)
            SQP:SetSetting("showPercentIcon", true)
            local percent = SQP.optionControls.showPercentIcon
            if percent then percent:SetChecked(true) end
        else
            SQP:SetSetting("showIconBackground", nil)
        end
        for _, typeKey in ipairs({ "kill", "loot", "percent" }) do
            SQP:SetSetting(typeKey .. "ShowIconBackground", nil)
            local update = SQP.optionControls[typeKey .. "ShowIconBackgroundStyleUpdater"]
            if update then update() end
        end
        SQP:RebuildQuestPlates()
        SQP:UpdatePreviewManually()
    end)
    SQP:SetControlTooltip(text, "Use objective ratio text. Forever keeps its frame; Classic shows bare text.")
end

-- Global behavior toggles and the reset action.
local function BuildGeneralPage(leftColumn)
    local generalCard = Card(leftColumn, "General")
    do
        local c = generalCard.content
        local right = CreateFrame("Frame", nil, c)
        right:SetPoint("TOPLEFT", c, "TOP", 0, 0)
        right:SetPoint("TOPRIGHT", c, "TOPRIGHT", 0, 0)
        right:SetHeight(44)
        local yOffset = -8

        local chatFrame = SQP:CreateStyledCheckbox(c, "Chat Messages")
        chatFrame:SetPoint("TOPLEFT", 8, yOffset)
        chatFrame.checkbox:SetChecked(SQPSettings.showMessages ~= false)
        SQP.optionControls.showMessages = chatFrame.checkbox
        chatFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting('showMessages', self:GetChecked())
        end)
        yOffset = yOffset - 22

        local minimapFrame = SQP:CreateStyledCheckbox(c, "Minimap Icon")
        minimapFrame:SetPoint("TOPLEFT", 8, yOffset)
        minimapFrame.checkbox:SetChecked(SQPSettings.minimapIconEnabled ~= false)
        SQP.optionControls.minimapIconEnabled = minimapFrame.checkbox
        minimapFrame.checkbox:SetScript("OnClick", function(self)
            SQP:ToggleMinimapIcon(self:GetChecked())
        end)
        SQP:SetControlTooltip(minimapFrame, "Left-click opens options. Drag to move. Ctrl-right-click hides it.")
        yOffset = yOffset - 22

        local combatFrame = SQP:CreateStyledCheckbox(right, "Hide in Combat")
        combatFrame:SetPoint("TOPLEFT", 2, -8)
        combatFrame.checkbox:SetChecked(SQPSettings.hideInCombat)
        SQP.optionControls.hideInCombat = combatFrame.checkbox
        combatFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting('hideInCombat', self:GetChecked()); SQP:RefreshAllNameplates()
        end)

        local instanceFrame = SQP:CreateStyledCheckbox(right, "Hide in Instances")
        instanceFrame:SetPoint("TOPLEFT", 2, -30)
        instanceFrame.checkbox:SetChecked(SQPSettings.hideInInstance)
        SQP.optionControls.hideInInstance = instanceFrame.checkbox
        instanceFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting('hideInInstance', self:GetChecked()); SQP:RefreshAllNameplates()
        end)

        yOffset = yOffset - 8
        local resetButton = SQP:CreateStyledButton(c, SQP.L["OPTIONS_RESET"] or "Reset All Settings", 138, 20)
        resetButton:SetPoint("TOP", c, "TOP", 0, yOffset)
        resetButton:SetAlpha(0.8)
        resetButton:SetScript("OnClick", function() StaticPopup_Show("SQP_RESET_CONFIRM") end)
        generalCard:FitContent()
    end
    return generalCard
end

-- Apply one global display mode everywhere: writes the global background
-- keys, clears per-type overrides, refreshes all style controls, rebuilds
-- plates and the preview. Shared by the Global dropdown and display presets.
-- mode: "icon" | "chip" | "text".
function SQP:ApplyGlobalDisplayStyle(mode, backgroundOnly)
    assert(mode == "icon" or mode == "chip" or mode == "text", "SQP: unknown display mode")
    SQP:SetSetting('unifiedNameplates', mode == "chip")
    if not backgroundOnly then SQP:SetSetting('showIconBackground', mode ~= "text") end
    for _, typeKey in ipairs({ "kill", "loot", "percent" }) do
        SQP:SetSetting(typeKey .. "LevelChip", nil)
        if not backgroundOnly then SQP:SetSetting(typeKey .. "ShowIconBackground", nil) end
        local update = SQP.optionControls[typeKey .. "ShowIconBackgroundStyleUpdater"]
        if update then update() end
    end
    local dd = SQP.optionControls.unifiedDropdown
    if dd and type(dd.SetValue) == "function" then
        dd:SetValue(mode == "chip" and ("chip:" .. (SQPSettings.chipTexture or "coin")) or "icon")
    end
    local box = SQP.optionControls.showIconBackgroundTextOnly
    if box and type(box.SetChecked) == "function" then
        box:SetChecked(SQPSettings.showIconBackground == false)
    end
    SQP:RebuildQuestPlates()
    if SQP.previewFrame and type(SQP.previewFrame.UpdatePreview) == "function" then
        SQP.previewFrame:UpdatePreview()
    end
end

-- Page 2: Display — nameplate side, text mode, position & scale, background
-- style, plus the font card on the left.
local function BuildDisplayPage(leftColumn, rightColumn, generalCard)
    -- RIGHT: Display (quest display style + position & scale in one card)
    local displayCard = Card(rightColumn, "Display")
    do
        local c = displayCard.content
        local yOffset = -8
        BuildDisplayModes(c, yOffset)
        yOffset = yOffset - 28

        -- Side buttons are self-describing; no extra heading row.
        local sides = _G.RGXUI:CreateButtonGroup(c, { "Left Side", "Right Side" },
            { buttonWidth = 68, height = 20, gap = 4 })
        sides:ClearAllPoints()
        sides:SetPoint("TOP", c, "TOP", 0, yOffset)
        local leftBtn, rightBtn = sides.buttons[1], sides.buttons[2]
        SQP.optionControls.anchorButtons = {left = leftBtn, right = rightBtn}

        local function UpdateAnchorButtons()
            leftBtn:SetAlpha( SQPSettings.anchor == "RIGHT" and 1 or 0.6)
            rightBtn:SetAlpha(SQPSettings.anchor == "LEFT"  and 1 or 0.6)
        end
        SQP.optionControls.updateAnchorButtons = UpdateAnchorButtons
        UpdateAnchorButtons()

        leftBtn:SetScript("OnClick", function()
            local oldBaseline = SQP:GetSettingBaseline("offsetX")
            local oldX = SQP:GetSettingValue("offsetX")
            SQP:SetSetting('anchor', "RIGHT")
            SQP:SetSetting('relativeTo', "LEFT")
            if oldX == oldBaseline then
                SQP:SetSetting('offsetX', SQP:GetSettingBaseline("offsetX"))
                local slider = SQP.optionControls.offsetX
                if slider then slider.SetValue(SQP:GetSettingBaseline("offsetX")) end
            end
            UpdateAnchorButtons()
            SQP:RefreshAllNameplates()
        end)
        rightBtn:SetScript("OnClick", function()
            local oldBaseline = SQP:GetSettingBaseline("offsetX")
            local oldX = SQP:GetSettingValue("offsetX")
            SQP:SetSetting('anchor', "LEFT")
            SQP:SetSetting('relativeTo', "RIGHT")
            if oldX == oldBaseline or oldX == SQP.DEFAULTS.offsetX then
                SQP:SetSetting('offsetX', SQP:GetSettingBaseline("offsetX"))
                local slider = SQP.optionControls.offsetX
                if slider then slider.SetValue(SQP:GetSettingBaseline("offsetX")) end
            end
            UpdateAnchorButtons()
            SQP:RefreshAllNameplates()
        end)


        local Drops = _G.RGXDropdowns
        yOffset = yOffset - 28
        local hasDropdown = Drops and type(Drops.CreateNestedDropdown) == "function"

        -- Range 0.5–1.5 centers the slider on 1; 1.1 is the baseline default.
        local scaleSlider = SQP:CreateStyledSlider(c, {
            key = "scale", label = "Scale", min = 0.5, max = 1.5, step = 0.1,
            default = 1.1, storage = SQPSettings, suffix = "", width = 160,
            onChange = function(value) SQP:RefreshAllNameplates() end,
        })
        scaleSlider:SetPoint("TOPLEFT", 8, yOffset)
        scaleSlider:SetPoint("TOPRIGHT", c, "TOPRIGHT", -8, yOffset)
        SQP.optionControls.scale = scaleSlider
        SQP.optionControls.scaleLabel = scaleSlider.valueLabel
        yOffset = yOffset - 42

        local xSlider = SQP:CreateStyledSlider(c, {
            key = "offsetX", label = "Offset X", min = -100, max = 100, step = 1,
            default = 0, storage = SQPSettings, width = 160,
            onChange = function(value) SQP:RefreshAllNameplates() end,
        })
        xSlider:SetPoint("TOPLEFT", 8, yOffset)
        xSlider:SetPoint("TOPRIGHT", c, "TOPRIGHT", -8, yOffset)
        SQP.optionControls.offsetX = xSlider
        SQP.optionControls.offsetXLabel = xSlider.valueLabel
        if xSlider.resetButton then
            xSlider.resetButton:SetScript("OnClick", function()
                xSlider.SetValue(SQP:GetSettingBaseline("offsetX"))
            end)
        end
        yOffset = yOffset - 42

        local ySlider = SQP:CreateStyledSlider(c, {
            key = "offsetY", label = "Offset Y", min = -100, max = 100, step = 1,
            default = 0, storage = SQPSettings, width = 160,
            onChange = function(value) SQP:RefreshAllNameplates() end,
        })
        ySlider:SetPoint("TOPLEFT", 8, yOffset)
        ySlider:SetPoint("TOPRIGHT", c, "TOPRIGHT", -8, yOffset)
        SQP.optionControls.offsetY = ySlider
        SQP.optionControls.offsetYLabel = ySlider.valueLabel
        yOffset = yOffset - 46

        if hasDropdown then
            -- One dropdown owns background choices; its value carries the chip
            -- texture selection at the same time.
            local blizzardItems = {
                { text = "Classic (default)", value = "icon" },
                { text = "Chip: Coin (gold)", value = "chip:coin" },
                { text = "Chip: Coin (silver)", value = "chip:silver" },
                { text = "Chip: Coin (copper)", value = "chip:copper" },
                { text = "Chip: Medal (gold)", value = "chip:medalGold" },
                { text = "Chip: Medal (silver)", value = "chip:medalSilver" },
                { text = "Chip: Medal (bronze)", value = "chip:medalBronze" },
                { text = "Chip: Artifact gold medallion", value = "chip:artifactMedal" },
                { text = "Chip: Guild achievement badge", value = "chip:guildBadge" },
                { text = "Chip: Gold ring 2", value = "chip:goldRing2" },
                { text = "Chip: Gold ring 3", value = "chip:goldRing3" },
                { text = "Chip: Titan disc", value = "chip:titanDisc" },
            }
            -- Image-only labels; item text is the artwork markup. Names stay
            -- in artworkLabel for data only.
            for _, item in ipairs(blizzardItems) do
                item.artworkLabel = item.text
                local key = item.value:match("^chip:(.+)$")
                local artwork = key and SQP.CHIP_TEXTURES[key]
                if item.value == "icon" then
                    item.text = "|TInterface\\QuestFrame\\AutoQuest-Parts:24:24:0:0:512:64:155:215:1:61|t"
                elseif type(artwork) == "table" and artwork.atlas
                    and type(CreateAtlasMarkup) == "function"
                    and C_Texture and C_Texture.GetAtlasInfo
                    and C_Texture.GetAtlasInfo(artwork.atlas) then
                    item.text = CreateAtlasMarkup(artwork.atlas, 24, 24)
                else
                    item.text = string.format("|T%s:24:24:0:0|t", SQP.CHIP_TEXTURES.logo)
                end
            end
            local rgxItems = {}
            for _, logo in ipairs(SQP.LOGO_BACKGROUNDS) do
                rgxItems[#rgxItems + 1] = {
                    text = string.format("|T%s:24:24:0:0|t", SQP.CHIP_TEXTURES[logo.key]),
                    artworkLabel = logo.label,
                    value = "chip:" .. logo.key,
                }
            end
            local chipItems = {
                { text = "Blizzard", children = blizzardItems },
                { text = "RGX", children = rgxItems },
            }
            local function CurrentMode()
                if SQPSettings.unifiedNameplates == true then
                    local selected = "chip:" .. (SQPSettings.chipTexture or "coin")
                    for _, group in ipairs(chipItems) do
                        for _, item in ipairs(group.children) do
                            if item.value == selected then return selected end
                        end
                    end
                    SQPSettings.chipTexture = "coin"
                    return "chip:coin"
                end
                return "icon"
            end
            local dd = Drops:CreateNestedDropdown(c, {
                label = "Background style",
                width = 300,
                buttonWidth = 290,
                triggerStyle = "retail",
                value = CurrentMode(),
                items = chipItems,
                onChange = function(value)
                    if value == "icon" then
                        SQP:ApplyGlobalDisplayStyle("icon", true)
                    else
                        local chip = value:match("^chip:(.+)$") or "coin"
                        SQP:SetSetting("chipTexture", chip)
                        SQP:ApplyGlobalDisplayStyle("chip", true)
                    end
                end,
            })
            if dd and dd.retailTrigger then
                -- Center the selected label on the retail trigger. The
                -- framework keeps the menu alignment itself; this only
                -- changes the closed button face for this control.
                local regions = { dd.retailTrigger:GetRegions() }
                for _, region in ipairs(regions) do
                    if region.IsObjectType and region:IsObjectType("FontString") and region.GetText and region:GetText() ~= "v" then
                        region:ClearAllPoints()
                        region:SetPoint("CENTER", dd.retailTrigger, "CENTER", 0, 0)
                        region:SetJustifyH("CENTER")
                    end
                end
            end
            if dd then
                if dd.label then dd.label:SetTextColor(0.345, 0.745, 0.506) end
                dd:SetPoint("TOPLEFT", c, "TOPLEFT", 8, yOffset)
                dd:SetPoint("TOPRIGHT", c, "TOPRIGHT", -8, yOffset)
                SQP:SetControlTooltip(dd, "Blizzard contains Classic, coins, medals and badges. RGX contains bundled addon logos. Background selection preserves Text Mode. Unavailable atlases show the SQP logo.")
                SQP.optionControls.unifiedDropdown = dd
            end
        end
        displayCard:FitContent()
    end

    -- LEFT: Font
    local fontCard = Card(leftColumn, "Font", { above = generalCard })
    SQP:CreateFontSection(fontCard.content, nil, -8)
    fontCard:FitContent()
end

-- Page 3: Animation — animation switches, global intensity, and the quest toast
local function BuildAnimationPage(page)
    if not page then return end
    local leftColumn, rightColumn = SQP:CreateOptionColumns(page)

    -- LEFT: Animation (applies across all quest types)
    local animationCard = Card(leftColumn, "Animation")
    do
        local c = animationCard.content
        local yOffset = -8

        local taskFrame = SQP:CreateStyledCheckbox(c, "Animate task icons")
        taskFrame:SetPoint("TOPLEFT", 8, yOffset)
        taskFrame.checkbox:SetChecked(SQPSettings.animateQuestIcons == true)
        SQP.optionControls.animateQuestIcons = taskFrame.checkbox
        taskFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting('animateQuestIcons', self:GetChecked())
            SQP:RefreshAllNameplates()
        end)
        SQP:SetControlTooltip(taskFrame, "Pulse the small kill, loot and percent task icons on plates.")
        yOffset = yOffset - 22

        local mainFrame = SQP:CreateStyledCheckbox(c, "Animate Main Icons")
        mainFrame:SetPoint("TOPLEFT", 8, yOffset)
        mainFrame.checkbox:SetChecked(SQPSettings.animateMainIcons == true)
        SQP.optionControls.animateMainIcons = mainFrame.checkbox
        mainFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting('animateMainIcons', self:GetChecked())
            SQP:RefreshAllNameplates()
        end)
        SQP:SetControlTooltip(mainFrame, "Animate every main quest icon. When off, Kill, Loot and Percent use their individual switches.")
        yOffset = yOffset - 22

        local syncFrame = SQP:CreateStyledCheckbox(c, "Sync icon animations")
        syncFrame:SetPoint("TOPLEFT", 8, yOffset)
        syncFrame.checkbox:SetChecked(SQPSettings.syncAnimations == true)
        SQP.optionControls.syncAnimations = syncFrame.checkbox
        syncFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting('syncAnimations', self:GetChecked())
            SQP:RefreshAllNameplates()
        end)
        SQP:SetControlTooltip(syncFrame, "Play the main, kill, loot and percent pulses in phase.")
        yOffset = yOffset - 22

        local globalFrame = SQP:CreateStyledCheckbox(c, "Use global intensity for all icons")
        globalFrame:SetPoint("TOPLEFT", 8, yOffset)
        globalFrame.checkbox:SetChecked(SQPSettings.useGlobalAnimationSettings == true)
        SQP.optionControls.useGlobalAnimationSettings = globalFrame.checkbox
        globalFrame.checkbox:SetScript("OnClick", function(self)
            SQP:SetSetting('useGlobalAnimationSettings', self:GetChecked())
            SQP:RefreshAllNameplates()
        end)
        SQP:SetControlTooltip(globalFrame, "When checked, the global intensity below drives every icon. When off, Kill, Loot and Percent use their individual intensity sliders.")
        yOffset = yOffset - 24

        local intensityReady = false
        local globalIntensitySlider = SQP:CreateStyledSlider(c, {
            key = "globalAnimationIntensity",
            label = "Global intensity",
            min = 25,
            max = 200,
            step = 5,
            default = 100,
            storage = SQPSettings,
            width = 160,
            suffix = "%",
            onChange = function(val)
                -- The framework invokes onChange once during construction;
                -- do not overwrite saved per-type intensities at panel open.
                if not intensityReady then return end
                -- Cascade: mark the loop so child slider updates do not fire
                -- their per-type preview activations (which would flip the
                -- visible preview to the last-updated type), then re-render
                -- the current preview once at the end.
                SQP._cascadingGlobalIntensity = true
                for _, key in ipairs({ "killAnimationIntensity", "lootAnimationIntensity", "percentAnimationIntensity" }) do
                    SQP:SetSetting(key, val)
                    local slider = SQP.optionControls[key]
                    if slider and slider.SetValue then slider.SetValue(val) end
                end
                SQP._cascadingGlobalIntensity = false
                SQP:RefreshAllNameplates()
                if SQP.UpdatePreviewManually then SQP:UpdatePreviewManually() end
            end,
        })
        intensityReady = true
        globalIntensitySlider:SetPoint("TOPLEFT", 8, yOffset)
        globalIntensitySlider:SetPoint("TOPRIGHT", c, "TOPRIGHT", -8, yOffset)
        SQP.optionControls.globalAnimationIntensity = globalIntensitySlider
        SQP.optionControls.globalAnimationIntensityLabel = globalIntensitySlider.valueLabel
        yOffset = yOffset - 48

        -- Bottom of the card: restores every SQP animation setting, not just
        -- the toast trio. Baselines match SQP.DEFAULTS exactly.
        local animationKeys = {
            "animationsEnabled", "killAnimationsEnabled", "lootAnimationsEnabled", "percentAnimationsEnabled",
            "animateQuestIcon", "animateQuestIcons", "animateMainIcons",
            "killAnimateMain", "lootAnimateMain", "percentAnimateMain",
            "syncAnimations", "useGlobalAnimationSettings", "globalAnimationEnabled",
            "animationCombatMode", "globalAnimationIntensity", "killAnimationIntensity",
            "lootAnimationIntensity", "percentAnimationIntensity", "showQuestMarker",
            "questMarkerSize", "toastDuration", "toastHeight",
        }
        local resetAll = SQP:CreateStyledButton(c, "Reset All Animation Settings", 190, 20)
        resetAll:SetPoint("TOP", c, "TOP", 0, yOffset)
        resetAll:SetScript("OnClick", function()
            local animationDefaults = {}
            for _, key in ipairs(animationKeys) do
                local value = SQP.DEFAULTS[key]
                animationDefaults[key] = value
                SQP:SetSetting(key, value)
            end
            for key, control in pairs(SQP.optionControls or {}) do
                if animationDefaults[key] ~= nil then
                    if control.SetChecked then
                        control:SetChecked(animationDefaults[key] == true)
                    elseif control.SetValue then
                        control.SetValue(animationDefaults[key])
                    end
                end
            end
            for _, key in ipairs({ "animateQuestIconsLoot", "animateQuestIconsPercent" }) do
                local control = SQP.optionControls[key]
                if control then control:SetChecked(SQP.DEFAULTS.animateQuestIcons) end
            end
            SQP:RefreshAllNameplates()
            if SQP.previewFrame and SQP.previewFrame.UpdatePreview then
                SQP.previewFrame:UpdatePreview()
            end
        end)
        SQP.optionControls.resetAllAnimations = resetAll
        animationCard:FitContent()
    end

    -- RIGHT: Quest Toast (the on-target question-mark pop)
    local toastCard = Card(rightColumn, "Quest Toast")
    do
        local c = toastCard.content
        local flow = toastCard.flow

        flow:AddSpacer(8)
        local toastSwitch = SQP:CreateHeaderSwitch(toastCard, "showQuestMarker")
        local toastPreview = SQP:CreateStyledButton(c, "Preview Toast", 104, 20)
        SQP:SetControlTooltip(toastSwitch, "Enable quest toast: the question-mark pop that plays when you target a mob with a quest icon.")

        local toastDurationSlider = SQP:CreateStyledSlider(c, {
            key = "toastDuration", label = "Toast Duration", min = 0.3, max = 2.5, step = 0.1,
            default = 1.3, storage = SQPSettings, suffix = "s", width = 160,
        })
        flow:Add(toastDurationSlider, { fill = true })
        SQP.optionControls.toastDuration = toastDurationSlider
        SQP.optionControls.toastDurationLabel = toastDurationSlider.valueLabel

        -- Selecting the toast card's preview is the only way the toast replays;
        -- typing random animation options must not fire it. Toast stays
        -- selected only while this tab is open and the feature is enabled.
        -- The enable switch lives in the card header; Preview stays in the body.
        SQP.optionControls.toastPreviewButton = toastPreview
        toastPreview:SetScript("OnClick", function()
            if SQP.previewFrame and SQP.previewFrame.questFrame then
                SQP:SetQuestToastSelected(SQP.previewFrame.questFrame, true)
            end
        end)

        local toastHeightSlider = SQP:CreateStyledSlider(c, {
            key = "toastHeight", label = "Toast Height", min = 0, max = 60, step = 2,
            default = 30, storage = SQPSettings, suffix = "", width = 160,
        })
        flow:Add(toastHeightSlider, { fill = true })
        SQP.optionControls.toastHeight = toastHeightSlider
        SQP.optionControls.toastHeightLabel = toastHeightSlider.valueLabel

        local toastSizeSlider = SQP:CreateStyledSlider(c, {
            key = "questMarkerSize", label = "Toast Size", min = 12, max = 48, step = 2,
            default = 40, storage = SQPSettings, suffix = "", width = 160,
            onChange = function(value) SQP:RefreshAllNameplates() end,
        })
        flow:Add(toastSizeSlider, { fill = true })
        SQP.optionControls.questMarkerSize = toastSizeSlider
        SQP.optionControls.questMarkerSizeLabel = toastSizeSlider.valueLabel
        flow:AddRow({ { child = toastPreview, align = "center" } })
        toastCard:AutoHeight()
    end
end

-- The preview selectors own the per-type pages; the tab row stays global.
-- One shared geometry rule for pages with headers: cards live in an inset
-- below the header, so they can never draw over it.
function SQP:CreatePageArea(content, title)
    local header = SQP:CreatePageHeader(content, title)
    local inset = CreateFrame("Frame", nil, content)
    -- Header is 32px; the 8px gap matches every other page transition.
    inset:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -40)
    inset:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", 0, 0)
    return inset, header
end

function SQP:CreateGlobalOptions(content)
    if not self.optionControls then self.optionControls = {} end
    local contentArea, header = SQP:CreatePageArea(content, "Global")
    local typeSwitches = {}
    for _, typeKey in ipairs({ "kill", "loot", "percent" }) do
        local switch = SQP:CreateHeaderSwitch(header, typeKey .. "Enabled")
        switch:Hide()
        typeSwitches[#typeSwitches + 1] = switch
    end
    local pages = {}
    for i = 1, 4 do
        local page = CreateFrame("Frame", nil, contentArea)
        page:SetAllPoints()
        page:SetShown(i == 1)
        pages[i] = page
    end
    local pager = { frames = pages, page = 1 }
    function pager:SetPage(n)
        self.page = n
        local titles = { "Global", "Kill", "Loot", "Percent" }
        if header.label then header.label:SetText(titles[n]) end
        for i, switch in ipairs(typeSwitches) do switch:SetShown(n == i + 1) end
        for i, page in ipairs(self.frames) do page:SetShown(i == n) end
    end
    self.optionControls.generalPager = pager
    local leftColumn, rightColumn = SQP:CreateOptionColumns(pages[1])
    local generalCard = BuildGeneralPage(leftColumn)
    BuildDisplayPage(leftColumn, rightColumn, generalCard)
    -- Build each type page when shown: framework cards measure their children
    -- against visible geometry, which is unavailable on a hidden page.
    local builders = { SQP.CreateKillOptions, SQP.CreateLootOptions, SQP.CreatePercentOptions }
    for i = 2, 4 do
        local page = pages[i]
        local builder = builders[i - 1]
        page:SetScript("OnShow", function(self)
            if not self._built then
                self._built = true
                local design = _G.RGXDesign
                if design and design.WithTheme and SQP.optionsTheme then
                    design:WithTheme(SQP.optionsTheme, function() builder(SQP, self) end)
                else
                    builder(SQP, self)
                end
            end
        end)
    end
end

function SQP:CreateAnimationOptions(content)
    if not self.optionControls then self.optionControls = {} end
    local contentArea, header = SQP:CreatePageArea(content, "Animation")
    SQP:CreateHeaderSwitch(header, "animationsEnabled")
    BuildAnimationPage(contentArea)
end
