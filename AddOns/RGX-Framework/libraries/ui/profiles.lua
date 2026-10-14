-- Shared profile editor; consumers supply their existing database owner.
-- Reference layout: title band, intro line, and a three-zone card —
-- active-profile highlight box, profile dropdown with count, and the stacked
-- Create/Rename/Reset/Copy actions — using only framework skin primitives.
-- Create/Rename enter the name through a small framework dialog; Copy
-- auto-generates its name. No consumer colors, icons, or presets here.
local _, UI = ...
local RGX = _G.RGXFramework

if not RGX then
    error("RGX UI Profiles: RGX-Framework not loaded")
    return
end

-- opts: db (required database owner), title, icon (texture path),
-- description (intro line), onChange(activeName, db),
-- presets (array of { name, description?, ... }), onPreset(preset, db).
function UI:CreateProfilesPanel(parent, opts)
    opts = opts or {}
    local db = assert(opts.db, "RGX UI: profile controls require a database")
    local D = assert(RGX:GetDesign(), "RGX UI: design unavailable")
    local dropdowns = assert(RGX:GetModule("dropdowns"), "RGX UI: dropdowns unavailable")

    -- Title band + intro line.
    local header = D:CreateSectionHeader(parent, opts.title or "Profiles", opts.icon)
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    local intro = self:CreateLabel(parent, {
        text = opts.description or "Create, switch, and manage your saved profiles.",
        color = "muted",
        width = 544,
    })
    -- Inset matches the card content so the first word clears the card border.
    intro:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 16, -8)
    intro:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -16, -8)

    -- Main card: highlight box (left), dropdown column (middle),
    -- stacked actions (right). Fixed zones like the reference layout;
    -- middle content is anchored, never measured.
    local card = self:CreateCard(parent, { title = opts.title or "Profiles", height = opts.height or 214 })
    card:ClearAllPoints()
    card:SetPoint("TOPLEFT", intro, "BOTTOMLEFT", 0, -8)
    card:SetPoint("TOPRIGHT", intro, "BOTTOMRIGHT", 0, -8)
    local content = card.content

    local status = self:CreateLabel(content, { text = "", color = "muted", width = 220 })

    local function changed()
        card:Refresh()
        if type(opts.onChange) == "function" then
            local ok, err = pcall(opts.onChange, db:GetActiveProfile(), db)
            if not ok then RGX:Error("[RGXUI] profile callback failed: " .. tostring(err)) end
        end
    end

    -- Plain Button widgets expose Enable/Disable, not SetEnabled.
    local function setButtonEnabled(button, enabled)
        if enabled then button:Enable() else button:Disable() end
    end

    -- Name dialog for Create/Rename: small framework dialog with an editbox
    -- and confirm. Errors and empty names report through the panel status.
    local nameDialog, nameInput, nameCommit
    local function openNameDialog(title, commit)
        if not nameDialog then
            nameDialog = self:CreateConfigDialog(parent, { title = title, width = 320, height = 130 })
            nameDialog:SetPoint("CENTER", parent, "CENTER", 0, 0)
            nameInput = CreateFrame("EditBox", nil, nameDialog, "InputBoxTemplate")
            nameInput:SetSize(220, 26)
            nameInput:SetPoint("TOPLEFT", nameDialog, "TOPLEFT", 16, -44)
            nameInput:SetAutoFocus(true)
            nameInput:SetMaxLetters(80)
            nameInput:SetScript("OnEscapePressed", function() nameDialog:Hide() end)
            local feedback = self:CreateLabel(nameDialog, { text = "", width = 288, color = "muted" })
            feedback:SetPoint("TOPLEFT", nameInput, "BOTTOMLEFT", 0, -4)
            nameDialog.feedback = feedback
            local okBtn = self:CreateButton(nameDialog, { text = "OK", width = 80, height = 22, onClick = function()
                local name = (nameInput:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
                if name == "" then
                    status:SetText("Enter a profile name.")
                    feedback:SetText("Enter a profile name.")
                    return
                end
                for _, existing in ipairs(db:ListProfiles()) do
                    if existing == name then
                        status:SetText("That profile already exists.")
                        feedback:SetText("That profile already exists.")
                        return
                    end
                end
                nameDialog:Hide()
                if nameCommit(name) then
                    status:SetText("Profile updated.")
                    changed()
                else
                    status:SetText("Profile could not be changed.")
                end
            end })
            okBtn:SetPoint("BOTTOMLEFT", nameDialog, "BOTTOMLEFT", 16, 14)
            local cancelBtn = self:CreateButton(nameDialog, { text = "Cancel", width = 80, height = 22, onClick = function() nameDialog:Hide() end })
            cancelBtn:SetPoint("LEFT", okBtn, "RIGHT", 8, 0)
            nameDialog.okButton, nameDialog.cancelButton = okBtn, cancelBtn
            nameDialog.input = nameInput
            nameInput:SetScript("OnEnterPressed", function() okBtn:Click() end)
        end
        nameDialog.titleText:SetText(title)
        nameInput:SetText("")
        nameDialog.feedback:SetText("")
        nameCommit = commit
        card._nameDialog = nameDialog
        nameDialog:Show()
    end
    card.openNameDialog = openNameDialog

    -- Copy auto-names: "Copy", then "Copy 2", "Copy 3"… (reference behavior).
    local nestedCopy = { current = 0 }
    local function suggestedCopyName()
        nestedCopy.current = nestedCopy.current or 0
        local base = "Copy"
        local function exists(name)
            for _, existing in ipairs(db:ListProfiles()) do
                if existing == name then return true end
            end
            return false
        end
        if not exists(base) then return base end
        local n = nestedCopy.current + 1
        while exists(base .. " " .. n) do n = n + 1 end
        nestedCopy.current = n
        return base .. " " .. n
    end

    -- RIGHT: stacked actions in the reference order/geometry (84x22, 6px gap).
    card.buttons = {}
    local function makeAction(label, commit)
        return function()
            local ok, result = pcall(commit)
            if not ok then
                status:SetText("Profile action failed: " .. tostring(result))
                RGX:Error("[RGXUI] profile action failed: " .. tostring(result))
                return
            end
            -- Opening a name dialog is not a completed database operation.
            if result == nil then return end
            status:SetText(result == false and "Profile could not be changed." or "Profile updated.")
            if result then changed() end
        end
    end
    local actionSpecs = {
        { "Create", makeAction("create", function() openNameDialog("Create Profile", function(name)
            if opts.createFromCurrent then return db:CopyProfile(db:GetActiveProfile(), name) end
            return db:CreateProfile(name)
        end) end) },
        { "Rename", makeAction("rename", function() openNameDialog("Rename Profile", function(name)
            return db:RenameProfile(db:GetActiveProfile(), name)
        end) end) },
        { "Reset",  makeAction("reset",  function() return db:ResetProfile(db:GetActiveProfile()) end) },
        { "Copy",   makeAction("copy",   function() return db:CopyProfile(db:GetActiveProfile(), suggestedCopyName()) end) },
    }
    local buttonY = -8
    for _, spec in ipairs(actionSpecs) do
        local button = self:CreateButton(content, {
                text = spec[1], width = 84, height = 22, onClick = spec[2],
            })
        button:SetPoint("TOPRIGHT", content, "TOPRIGHT", -8, buttonY)
        card.buttons[spec[1]:lower()] = button
        buttonY = buttonY - 28
    end

    -- LEFT: active-profile highlight box in the theme surface.
    local highlight = CreateFrame("Frame", nil, content, "BackdropTemplate")
    highlight:SetPoint("TOPLEFT", content, "TOPLEFT", 8, -8)
    highlight:SetPoint("BOTTOMLEFT", content, "BOTTOMLEFT", 8, 8)
    highlight:SetWidth(170)
    D:ApplyBackdrop(highlight, "dark", 0.60)
    local activeLabel = self:CreateLabel(highlight, { text = "Active", color = "muted" })
    activeLabel:SetPoint("TOPLEFT", highlight, "TOPLEFT", 12, -12)
    local activeValue = self:CreateLabel(highlight, {
        text = db:GetActiveProfile() or "Default", width = 146,
    })
    activeValue:SetPoint("TOPLEFT", activeLabel, "BOTTOMLEFT", 0, -2)
    activeValue:SetTextColor(D:Unpack("primary"))
    local characterValue = self:CreateLabel(highlight, {
        text = "Character: " .. tostring(db:GetCharKey()), color = "muted", width = 146,
    })
    characterValue:SetPoint("TOPLEFT", activeValue, "BOTTOMLEFT", 0, -10)

    -- MIDDLE: dropdown → count → status, each chained under the previous
    -- element so dropdown height never needs measuring.
    local profileLabel = self:CreateLabel(content, { text = "Profile", color = "accent" })
    profileLabel:SetPoint("TOPLEFT", highlight, "TOPRIGHT", 8, 0)
    local deleteDialog, pendingDelete
    local function requestDelete(name)
        if name == "Default" then return end
        if type(RGX.SafeCloseDropDownMenus) == "function" then RGX:SafeCloseDropDownMenus() end
        pendingDelete = name
        if not deleteDialog then
            deleteDialog = self:CreateConfigDialog(parent, { title = "Delete Profile", width = 320, height = 140 })
            deleteDialog:SetFrameStrata("FULLSCREEN_DIALOG")
            deleteDialog:SetPoint("CENTER", parent, "CENTER", 0, 0)
            deleteDialog.message = self:CreateLabel(deleteDialog, { text = "", width = 288 })
            deleteDialog.message:SetPoint("TOPLEFT", deleteDialog, "TOPLEFT", 16, -44)
            local confirm = self:CreateButton(deleteDialog, { text = "Delete", width = 84, height = 22,
                onClick = function()
                    local nameToDelete = pendingDelete
                    deleteDialog:Hide()
                    if nameToDelete and nameToDelete ~= "Default" and db:DeleteProfile(nameToDelete) then
                        status:SetText("Profile deleted.")
                        changed()
                    end
                end })
            confirm:SetPoint("BOTTOMLEFT", deleteDialog, "BOTTOMLEFT", 16, 14)
            local cancel = self:CreateButton(deleteDialog, { text = "Cancel", width = 84, height = 22,
                onClick = function() deleteDialog:Hide() end })
            cancel:SetPoint("LEFT", confirm, "RIGHT", 8, 0)
            deleteDialog.confirmButton, deleteDialog.cancelButton = confirm, cancel
            card._deleteDialog = deleteDialog
        end
        deleteDialog.message:SetText("Delete profile \"" .. name .. "\"?")
        deleteDialog:Show()
    end
    -- Reference-styled dropdown trigger from the shared dropdowns module.
    local picker = dropdowns:CreateNestedDropdown(content, {
        label = "", width = 220, buttonWidth = 220, triggerStyle = "retail",
        menuWidth = 220,
        autoWidth = { minWidth = 220, leftInset = 24,
            opts = { inlineKeys = { "rgxProfileDelete" }, compactRight = true } },
        items = function()
            local items = {}
            for _, name in ipairs(db:ListProfiles()) do items[#items + 1] = { text = name, value = name } end
            return items
        end,
        value = db:GetActiveProfile(),
        getValueText = function(value) return value or "Default" end,
        onChange = function(value) if db:LoadProfile(value) then changed() end end,
        onButtonCreated = function(row, item)
            if row.rgxProfileDelete then row.rgxProfileDelete:Hide() end
            if not item or item.value == "Default" or not item.value then return end
            local name = item.value
            local button = dropdowns:AddInlineButton(row, {
                key = "rgxProfileDelete", text = "Delete", width = 44, height = 16,
                onClick = function() requestDelete(name) end,
            })
            button:ClearAllPoints()
            button:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        end,
    })
    assert(picker, "RGX UI: no supported profile dropdown capability")
    picker:SetPoint("TOPLEFT", profileLabel, "BOTTOMLEFT", 0, -4)
    local count = self:CreateLabel(content, { text = "", color = "muted" })
    count:SetPoint("TOPLEFT", picker, "BOTTOMLEFT", 0, -4)
    status:SetPoint("TOPLEFT", count, "BOTTOMLEFT", 0, -8)

    local function profileCountText()
        local n = #db:ListProfiles()
        return n == 1 and "1 profile" or (n .. " profiles")
    end

    -- Presets: optional second card under the main one. The consumer owns
    -- preset data and application; the framework only renders the button
    -- grid and isolates applier failures. Absent when no presets given.
    if opts.presets and #opts.presets > 0 then
        assert(type(opts.onPreset) == "function", "RGX UI: presets require onPreset")
        local rows = math.ceil(#opts.presets / 3)
        local perPage = opts.presetsPerPage or 3
        assert(type(perPage) == "number" and perPage >= 3 and perPage % 3 == 0,
            "RGX UI: presetsPerPage must be a positive multiple of three")
        local pageCount = math.ceil(#opts.presets / perPage)
        local paged = opts.pagedPresets and pageCount > 1
        local visibleRows = opts.pagedPresets and math.ceil(math.min(#opts.presets, perPage) / 3) or rows
        -- Titled-card insets (42 top, 12 bottom) + 12px pad + one 30px row each.
        local presetsCard = self:CreateCard(parent, {
            title = "Presets", height = 66 + visibleRows * 30,
        })
        presetsCard:ClearAllPoints()
        presetsCard:SetPoint("TOPLEFT", card, "BOTTOMLEFT", 0, -8)
        presetsCard:SetPoint("TOPRIGHT", card, "BOTTOMRIGHT", 0, -8)
        local pager
        if paged then
            pager = self:CreatePager(presetsCard.content, { pages = pageCount })
            pager.nav:SetParent(presetsCard.headerBand)
            pager.nav:ClearAllPoints()
            pager.nav:SetPoint("RIGHT", presetsCard.headerBand, "RIGHT", -8, 0)
            -- Navigation lives in the header; page bodies no longer need
            -- the standalone pager's reserved navigation strip.
            for _, page in ipairs(pager.frames) do
                page:ClearAllPoints()
                page:SetPoint("TOPLEFT", presetsCard.content, "TOPLEFT", 0, 0)
                page:SetPoint("BOTTOMRIGHT", presetsCard.content, "BOTTOMRIGHT", 0, 0)
            end
            presetsCard.pager = pager
        end
        card.presetsCard = presetsCard
        card.presetButtons = {}
        for i, preset in ipairs(opts.presets) do
            local col = (i - 1) % 3
            local localIndex = pager and ((i - 1) % perPage) or (i - 1)
            local row = math.floor(localIndex / 3)
            local host = pager and pager.frames[math.floor((i - 1) / perPage) + 1] or presetsCard.content
            local button = self:CreateButton(host, {
                text = preset.name or ("Preset " .. i), width = 170, height = 22,
                onClick = function()
                    if preset.disabled then return end
                    local ok, err = pcall(opts.onPreset, preset, db)
                    if not ok then
                        status:SetText("Preset could not be applied.")
                        RGX:Error("[RGXUI] preset failed: " .. tostring(err))
                    else
                        changed()
                    end
                end,
            })
            button:SetPoint("TOPLEFT", host, "TOPLEFT", 12 + col * 182, -12 - row * 30)
            if preset.disabled then button:Disable() end
            card.presetButtons[#card.presetButtons + 1] = button
        end
    end

    function card:Refresh()
        local active = db:GetActiveProfile()
        picker:Refresh(active)
        activeValue:SetText(active or "Default")
        characterValue:SetText("Character: " .. tostring(db:GetCharKey()))
        count:SetText(profileCountText())
        local protected = active == "Default"
        if self.buttons.delete then setButtonEnabled(self.buttons.delete, not protected) end
        setButtonEnabled(self.buttons.rename, not protected)
    end
    card.dropdown, card.status = picker, status
    card.intro = intro
    card.activeInfo = { label = activeLabel, value = activeValue, character = characterValue }
    card:HookScript("OnShow", function(self) self:Refresh() end)
    card:Refresh()
    return card
end
