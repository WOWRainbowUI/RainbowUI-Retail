local _,rematch = ...
local L = rematch.localization
local C = rematch.constants
local settings = rematch.settings
rematch.optionsPanel = rematch.frame.OptionsPanel
rematch.frame:Register("optionsPanel")

-- ordered list of indexes into rematch.optionsList to display
local optionIndexes = {}
-- indexed by var, sub-tables of ordered list of option indexes that are dependent on this index (for search hits)
searchDependencies = {}

rematch.events:Register(rematch.optionsPanel,"PLAYER_LOGIN",function(self)
    self.Top.SearchBox.Instructions:SetText(L["Search Options"])
    -- expanded headers savedvar
    if type(settings.ExpandedOptionsHeaders)~="table" then
        settings.ExpandedOptionsHeaders = {}
    end

    -- when no breed addon loaded, then remove breed options (do any list removal before autoscrollbox setup)
    if not rematch.breedInfo:IsAnyBreedAddOnLoaded() then
        for index=#rematch.optionsList,1,-1 do
            local info = rematch.optionsList[index]
            if info.group==18 then -- remove all entries in Breed Options
                tremove(rematch.optionsList,index)
                if info.type=="header" then -- and nil its expanded header if it was open
                    settings.ExpandedOptionsHeaders[index] = nil
                end
            end
            -- remove "Always Hide Possible Breeds" from Pet Card Options or "Prioritize Breed On Import" on Team Options
            if info.var=="PetCardHidePossibleBreeds" or info.var=="PrioritizeBreedOnImport" then
                tremove(rematch.optionsList,index)
            end
        end
    end

    -- if soft target is not fully enabled (SoftTargetInteract is 3) then hide soft target dropdown
    if GetCVar("SoftTargetInteract")~="3" then
        for index=#rematch.optionsList,1,-1 do
            local info = rematch.optionsList[index]
            if info.parentKey=="InteractOnSoftInteractWidget" then
                tremove(rematch.optionsList,index)
            end
        end
        settings.InteractOnSoftInteract = C.INTERACT_NONE
    end

    -- for autoScrollBox, using the indexes into optionsList
    for index in ipairs(rematch.optionsList) do
        tinsert(optionIndexes,index)
    end
    -- for search hits, build dependency references
    for index,info in ipairs(rematch.optionsList) do
        if info.dependency then
            if not searchDependencies[info.dependency] then
                searchDependencies[info.dependency] = {}
            end
            tinsert(searchDependencies[info.dependency],index)
        end
    end
    -- setup autoScrollBox
    self.List:Setup({
        allData = optionIndexes,
        normalTemplate = "RematchOptionsNormalTemplate",
        normalFill = self.FillNormal,
        normalHeight = 26,
        headerTemplate = "RematchOptionsHeaderTemplate",
        headerFill = self.FillHeader,
        headerCriteria = self.HeaderCriteria,
        headerHeight = 26,
        expandedHeaders = settings.ExpandedOptionsHeaders,
        allButton = self.Top.AllButton,
        searchBox = self.Top.SearchBox,
        searchHit = self.SearchHit,
    })
    -- setup widgets
    for widget,setup in pairs(self.widgetSetup) do
        setup(self[widget])
    end
    -- go through all options and if any have runOnLogin set, then run their functions (named func is a member of rematch.optionPanel.funcs)
    for _,info in ipairs(rematch.optionsList) do
        if info.runOnLogin and rematch.optionsPanel.funcs[info.runOnLogin] then
            rematch.optionsPanel.funcs[info.runOnLogin](self,info)
        end
    end

    -- register CustomScaleDialog
    rematch.dialog:Register("CustomScaleDialog",{
        title = L["Use Custom Scale"],
        accept = SAVE,
        cancel = CANCEL,
        other = RESET,
        layout = {"Text","Slider"},
        refreshFunc = function(self,info,subject,firstRun)
            if firstRun then
                self.Text:SetText(L["The standalone window can be scaled from 50% to 200% of its normal size:"])
                self.Slider:Setup(settings.CustomScaleValue or 100,50,200,30,"%d%%",function(self,value)
                    settings.CustomScaleValue=value
                    rematch.frame:UpdateScale()
                    rematch.optionsPanel:Update()
                end)
                self.originalValue = settings.CustomScaleValue
            end
        end,
        otherFunc = function(self,info,subject)
            settings.CustomScaleValue = 100
            rematch.frame:UpdateScale()
            rematch.optionsPanel:Update()
        end,
        cancelFunc = function(self,info,subject)
            settings.CustomScaleValue = self.originalValue
            rematch.frame:UpdateScale()
            rematch.optionsPanel:Update()
        end
    })

    rematch.dialog:Register("ExportOptions",{
        title = L["Export Options"],
        accept = OKAY,
        layout = {"Text","MultiLineEditBox","Help"},
        refreshFunc = function(self,info,subject,firstRun)
            self.Text:SetText(L["Press Ctrl+C to copy to clipboard"])
            self.Help:SetText(L["This is intended to help troubleshoot issues.\n\nMany options interact with other options. When reporting a problem this can help recreate the issue."])
            self.MultiLineEditBox:SetText(subject or "",true)
            self.MultiLineEditBox:ScrollToTop()
        end,
        changeFunc = function(self,info,subject)
            self.MultiLineEditBox:SetText(subject or "",true)
            self.MultiLineEditBox:ScrollToTop()
        end
    })

    rematch.dialog:Register("ResetOptions",{
        title = L["Reset Options"],
        accept = YES,
        cancel = NO,
        prompt = L["Restore all options to default?"],
        layout = {"Icon","Text","Feedback"},
        refreshFunc = function(self,info,subject,firstRun)
            self.Icon:SetTexture("Interface\\ICONS\\Ability_Creature_Cursed_02")
            self.Icon:SetTexCoord(0.075,0.925,0.075,0.925)
            self.Text:SetText(L["This will restore all options in Rematch to default values and reload the UI.\n\nThis includes all settings in the Options panel but does not include teams, leveling queue or notes."])
            self.Feedback:Set("warning",L["Warning: This cannot be undone!"])
        end,
        acceptFunc = function(self,info,subject)
            for k,v in pairs(settings:GetDefaults()) do
                if type(v)~="table" then
                    settings[k] = v
                end
            end
            ReloadUI()
        end,
    })

end)

local function clearWidget(self)
    if self.widget and self.widget:GetParent()==self then
        self.widget:ClearAllPoints()
        self.widget:SetParent(rematch.optionsPanel)
        self.widget:Hide()
        self.widget = nil
    end
end

-- updates the options panel
function rematch.optionsPanel:Update()
    self.List:Update()
    for widget,update in pairs(self.widgetUpdate) do
        update(self[widget])
    end
end

-- returns true if the index is a header
function rematch.optionsPanel:HeaderCriteria(index)
    local info = rematch.optionsList[index]
    return info and info.type=="header" or false
end

-- fills a header button with details at index
function rematch.optionsPanel:FillHeader(index)
    self.index = index
    self.info = rematch.optionsList[index]
    if not self.info then return end
    self.Text:SetText(self.info.text)
    self:SetBack()
    self:SetExpanded(rematch.optionsPanel.List:IsHeaderExpanded(index),rematch.optionsPanel.List:IsSearching())
end

-- fills a normal (non-header) button with details at the index
function rematch.optionsPanel:FillNormal(index)
    self.index = index
    self.info = rematch.optionsList[index]
    if not self.info then return end
    if self.info.type=="check" then
        self.Check:Show()
        self.Text:Show()
        clearWidget(self)
        local xoff = settings[self.info.var] and 0.25 or 0
        self.Check:SetTexCoord(0+xoff,0.25+xoff,0.5,0.75)
        self.Check:SetDesaturated(self.info.dependency and not settings[self.info.dependency])
        self.Check:SetPoint("LEFT",self.info.dependency and 16 or 0,0)
        self.dependencyUnchecked = self.info.dependency and not settings[self.info.dependency]

        if settings[self.info.var]==nil then -- temporary, when a default doesn't exist for this setting, make it red
            self.Text:SetTextColor(1,0.5,0.5)
        elseif self.dependencyUnchecked then -- dependent option disabled, grey this one
            self.Text:SetTextColor(0.5,0.5,0.5)
        else -- for everything else, white text
            self.Text:SetTextColor(0.9,0.9,0.9)
        end
        self.Text:SetPoint("LEFT",self.Check,"RIGHT",2,0)
        self.Text:SetText(self.info.text)
    elseif self.info.type=="text" then
        self.Check:Hide()
        self.Text:Show()
        clearWidget(self)
        self.Text:SetTextColor(0.9,0.9,0.9)
        self.Text:SetPoint("LEFT",6,0)
        self.Text:SetText(self.info.text)
    elseif self.info.type=="widget" then
        self.Check:Hide()
        self.Text:Hide()
        clearWidget(self)
        local widget = rematch.optionsPanel[self.info.parentKey]
        widget:ClearAllPoints()
        widget:SetParent(self)
        widget:SetAllPoints(true)
        widget:Show()
        self.widget = widget
    end
end

function rematch.optionsPanel:SearchHit(mask,index)
    local info = rematch.optionsList[index]
    if info.text and rematch.utils:match(mask,info.text,info.tooltip) then
        return true -- this option was a search hit
    end
    -- while this option didn't match, see if it has dependants that do
    if info.var and searchDependencies[info.var] then
        for _,dependant in ipairs(searchDependencies[info.var]) do
            if rematch.optionsPanel.SearchHit(self,mask,dependant) then
                return true -- if at least one dependant was a hit, list this dependency
            end
        end
    end
    return false
end

RematchOptionsListButtonMixin = {}

function RematchOptionsListButtonMixin:OnEnter()
    if self.info and not self.dependencyUnchecked and (not rematch.optionsPanel.List:IsSearching() or self.info.type~="header") then
        if self.info.type=="header" then
            rematch.textureHighlight:Show(self.Back,self.ExpandIcon)
        elseif self.info.type=="check" then
            rematch.textureHighlight:Show(self.Check)
        end
    end
    if self.info and self.info.tooltip then
        if self.info.type=="check" then
            rematch.tooltip:ShowSimpleTooltip(self,self.info.text,self.info.tooltip)
        end
    end
end

function RematchOptionsListButtonMixin:OnLeave()
    rematch.textureHighlight:Hide()
    rematch.tooltip:Hide()
end

function RematchOptionsListButtonMixin:OnMouseDown()
    rematch.textureHighlight:Hide()
end

function RematchOptionsListButtonMixin:OnMouseUp()
    if GetMouseFocus()==self then
        self:OnEnter()
    end
end

-- onclick shared by header and non-header
function RematchOptionsListButtonMixin:OnClick()
    if not self.info or self.dependencyUnchecked then
        return -- don't click anything unknown or if dependency unchecked
    end
    if self.info.type=="header" then
        rematch.optionsPanel.List:ToggleHeader(self.index)
        PlaySound(C.SOUND_HEADER_CLICK)
    elseif self.info.type=="check" then
        if settings[self.info.var]==nil then
            return -- for settings in development; don't update settings that don't have a default (they'll be colored red)
        end
        settings[self.info.var] = not settings[self.info.var]
        if self.info.func then -- if there's a function to run, run that
            rematch.optionsPanel.funcs[self.info.func](self)
        end
        if self.info.update then -- if not and whole UI should be updated
            rematch.frame:Update()
        else -- otherwise just update options panel
            rematch.optionsPanel:Update()
        end
        PlaySound(C.SOUND_CHECKBUTTON)
    end
end

--[[ option funcs (to run when an option changes) ]]

rematch.optionsPanel.funcs = {}

-- when checking UseDefaultJournal while in the journal, turn off the journal (like bottombar's rematch checkbutton)
function rematch.optionsPanel.funcs:UseDefaultJournal()
    if settings.UseDefaultJournal and rematch.journal:IsActive() then
        rematch.frame:Hide()
        rematch.frame:SetParent(UIParent)
        PetJournal:Show()
        PetJournal_UpdatePetLoadOut() -- in case journal wasn't keeping up while rematch was doing stuff
    end
end


-- Standalone Window Options: Lower Window Behind UI; toggles the framestrata between LOW and MEDIUM
function rematch.optionsPanel.funcs:LowerStrata()
    if not rematch.journal:IsActive() then
        rematch.frame:SetFrameStrata(settings.LowerStrata and "LOW" or "MEDIUM")
    end
end

function rematch.optionsPanel.funcs:ConfigureToolbar()
    rematch.toolbar:Configure()
end

function rematch.optionsPanel.funcs:CompactPetList()
    rematch.petsPanel.List:SetCompactMode(settings.CompactPetList)
    rematch.petsPanel.List:Update()
end

function rematch.optionsPanel.funcs:CompactTeamList()
    rematch.teamsPanel.List:SetCompactMode(settings.CompactTeamList)
    rematch.teamsPanel.List:Update()
end

function rematch.optionsPanel.funcs:CompactTargetList()
    rematch.targetsPanel.List:SetCompactMode(settings.CompactTargetList)
    rematch.targetsPanel.List:Update()
end

function rematch.optionsPanel.funcs:CompactQueueList()
    rematch.queuePanel.List:SetCompactMode(settings.CompactQueueList)
    rematch.queuePanel.List:Update()
end

-- any option that can change the results of the filtered list (including sort) should run this if the option changes
function rematch.optionsPanel.funcs:UpdateFilters()
    rematch.filters:ForceUpdate() -- sets the dirty flag so the filtered list is rerun in the update
    rematch.petsPanel:Update()
end

-- Pet Filter Options: Allow Hidden Pets; turn off filter it was enabled
function rematch.optionsPanel.funcs:UpdateHiddenPetFilter()
    rematch.filters:Set("Other","Hidden",nil)
    rematch.menus:Hide() -- in case Other filter menu is up (hide the Hidden Pets filter)
    rematch.filters:ForceUpdate()
    rematch.petsPanel:Update()
end

-- any option that can change the pet card
function rematch.optionsPanel.funcs:UpdatePetCard()
    if rematch.petCard:IsVisible() then
        rematch.petCard:Update()
    end
end

-- Pet Card Options: Allow Pet Cards To Be Pinned; unpin it if option unchecked and snap card back to its relativeTo
function rematch.optionsPanel.funcs:UpdatePetCardPin()
    if rematch.petCard:IsVisible() and not rematch.cardManager:IsCardPinned(rematch.petCard) then
        rematch.cardManager:Unpin(rematch.petCard)
    end
end

-- Team Win Record Options: Display Total Wins Instead
function rematch.optionsPanel.funcs:AlternateWinRecord()
    for groupID,group in rematch.savedGroups:AllGroups() do
        if group.sortMode==C.GROUP_SORT_WINS then
            rematch.savedGroups:Sort(groupID)
        end
    end
end

-- Team Options: Always Show Team Tabs
function rematch.optionsPanel.funcs:AlwaysTeamTabs()
    settings.NeverTeamTabs = false
    rematch.teamTabs:Configure()
end

-- Team Options: Never Show Team Tabs
function rematch.optionsPanel.funcs:NeverTeamTabs()
    settings.AlwaysTeamTabs = false
    rematch.teamTabs:Configure()
end

function rematch.optionsPanel.funcs:ShowNewGroupTab()
    rematch.teamTabs:Update()
end

-- for any options that may change queue/behavior
function rematch.optionsPanel.funcs:ProcessQueue()
    rematch.queue:Process()
end

-- for changes to win record options to register/unregister monitoring battles
function rematch.optionsPanel.funcs:AutoWinRecord()
    rematch.winrecord:Update()
end

function rematch.optionsPanel.funcs:UseMinimapButton()
    rematch.minimap:Configure()
end

-- if ExportPetsDialog is open when changing ExportSimplePetList option, then switch to new list
function rematch.optionsPanel.funcs:ExportSimplePetList()
    if rematch.dialog:GetOpenDialog()=="ExportPetsDialog" then
        rematch.dialog.Canvas.CheckButton:SetChecked(settings.ExportSimplePetList)
        rematch.dialog.Canvas.MultiLineEditBox:SetText(rematch.petFilterMenu:GetPetExportData(),true)
    end
end

--[[ widget setups ]]

rematch.optionsPanel.widgetSetup = {}

-- sets up the AnchorWidget and its dropdown control
function rematch.optionsPanel.widgetSetup:AnchorWidget()
    self.tooltipTitle = L["Anchor To"]
    self.tooltipBody = L["When the standalone window is minimized or maximized, use the chosen corner/edge as the anchor."]
    self.Label:SetText(self.tooltipTitle..":")
    self.DropDown:BasicSetup({
            {text="Bottom Left", value="BOTTOMLEFT", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0,0.25,0.5,0.75}},
            {text="Bottom Center", value="BOTTOM", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0.25,0.5,0.5,0.75}},
            {text="Bottom Right", value="BOTTOMRIGHT", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0.5,0.75,0.5,0.75}},
            {text="Top Right", value="TOPRIGHT", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0.5,0.75,0,0.25}},
            {text="Top Center", value="TOP", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0.25,0.5,0,0.25}},
            {text="Top Left", value="TOPLEFT", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0,0.25,0,0.25}}},
            function(value)
                -- changing anchor while in journal mode (or while window is not on screen) messes up anchoring
                if rematch.journal:IsActive() then
                    rematch.frame:Toggle() -- hide journal
                    rematch.frame:Toggle() -- show standalone window
                end
                rematch.frame:ChangeAnchor(value)
            end
    )
    self.DropDown:SetSelection(settings.Anchor)
end

-- sets up the AnchorWidget and its dropdown control
function rematch.optionsPanel.widgetSetup:PanelTabAnchorWidget()
    self.tooltipTitle = L["Panel Tabs"]
    self.tooltipBody = L["Choose which corner of the standalone Rematch window to anchor panel tabs such as Pets, Teams, Targets, etc.\n\nNote: Choosing a new anchor for the whole window will change the tabs anchor to match. You can change this tabs anchor again anytime."]
    self.Label:SetText(self.tooltipTitle..":")
    self.DropDown:BasicSetup({
            {text="Bottom Left", value="BOTTOMLEFT", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0,0.25,0.5,0.75}},
            {text="Bottom Center", value="BOTTOM", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0.25,0.5,0.5,0.75}},
            {text="Bottom Right", value="BOTTOMRIGHT", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0.5,0.75,0.5,0.75}},
            {text="Top Right", value="TOPRIGHT", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0.5,0.75,0,0.25}},
            {text="Top Center", value="TOP", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0.25,0.5,0,0.25}},
            {text="Top Left", value="TOPLEFT", icon="Interface\\AddOns\\Rematch\\textures\\arrows", iconCoords={0,0.25,0,0.25}}},
            function(value)
                rematch.frame:ChangePanelTabAnchor(value)
            end
    )
    self.DropDown:SetSelection(settings.PanelTabAnchor)
end

function rematch.optionsPanel.widgetSetup:TooltipBehaviorWidget()
    self.tooltipTitle = L["Tooltip Speed"]
    self.tooltipBody = L["Choose how quickly you prefer the tooltips (including pet ability tooltips) to be shown."]
    self.Label:SetText(L["Tooltip Speed:"])
    self.DropDown:BasicSetup({
        {text=L["Slow"], value="Slow", tooltipTitle=L["Slow Mouseover"], tooltipBody=L["Wait three quarters of a second for the tooltip to appear when you mouseover a button with a tooltip."]},
        {text=L["Normal"], value="Normal", tooltipTitle=L["Normal Mouseover"], tooltipBody=L["Wait a quarter of a second for the tooltip to appear when you mouseover a button with a tooltip."]},
        {text=L["Fast"], value="Fast", tooltipTitle=L["Fast Mouseover"], tooltipBody=L["Immediately show the tooltip when you mouseover a button with a tooltip."]}},
        function(value) settings.TooltipBehavior=value end)
    self.DropDown:SetSelection(settings.TooltipBehavior)
end

function rematch.optionsPanel.widgetSetup:CardBehaviorWidget()
    self.tooltipTitle = L["Card Speed"]
    self.tooltipBody = L["Choose how quickly you prefer the pet card and notes to be shown when you mouseover a pet or notes button."]
    self.Label:SetText(L["Card Speed:"])
    self.DropDown:BasicSetup({
        {text=L["Slow"], value="Slow", tooltipTitle=L["Slow Mouseover"], tooltipBody=L["Wait three quarters of a second for the pet card or notes to appear when you mouseover a pet or notes button."]},
        {text=L["Normal"], value="Normal", tooltipTitle=L["Normal Mouseover"], tooltipBody=L["Wait a quarter of a second for the pet card or notes to appear when you mouseover a pet or notes button."]},
        {text=L["Fast"], value="Fast", tooltipTitle=L["Fast Mouseover"], tooltipBody=L["Immediately show the pet card or notes when you mouseover a pet or notes button."]},
        {text=L["On Click"], value="Click", tooltipTitle=L["On Click"], tooltipBody=L["Only show the pet card or notes when you click a pet or notes button."]}},
        function(value) settings.CardBehavior=value end)
    self.DropDown:SetSelection(settings.CardBehavior)
end

-- sets up the FlipKeyWidget and its dropdown control
function rematch.optionsPanel.widgetSetup:FlipKeyWidget()
    self.tooltipTitle = L["Flip Modifier Key"]
    self.tooltipBody = L["The modifier key that will flip the pet card over. Regardless of this setting, you can flip the pet card over by mouseover of the pet's icon at the top of the card."]
    self.Label:SetText(self.tooltipTitle..":")
    self.DropDown:BasicSetup({{text="Alt Key", value="Alt"},{text="Shift Key", value="Shift"},{text="Ctrl Key", value="Ctrl"},{text="None", value="None"}},
                            function(value) settings.PetCardFlipKey=value rematch.petCard:Update() end)
    self.DropDown:SetSelection(settings.PetCardFlipKey)
end

function rematch.optionsPanel.widgetSetup:CardBackWidget()
    self.tooltipTitle = L["Card Background"]
    self.tooltipBody = L["The artwork displayed in the background on the front of pet cards."]
    self.Label:SetText(self.tooltipTitle..":")
    self.DropDown:BasicSetup({{text=L["Expansion Art"], value="Expansion"},{text=L["Portrait Art"], value="Portrait"},{text=L["Icon Art"], value="Icon"},{text=L["Type Art"], value="Type"},{text=L["None"], value="None"}},
                            function(value) settings.PetCardBackground=value rematch.petCard:Update() end)
    self.DropDown:SetSelection(settings.PetCardBackground)
end

function rematch.optionsPanel.widgetSetup:AbilityBackWidget()
    self.tooltipTitle = L["Ability Background"]
    self.tooltipBody = L["The artwork displayed in the background of ability tooltips."]
    self.Label:SetText(self.tooltipTitle..":")
    self.DropDown:BasicSetup({{text=L["Icon Art"], value="Icon"},{text=L["Type Art"], value="Type"},{text=L["None"], value="None"}},
        function(value) settings.AbilityBackground=value end)
    self.DropDown:SetSelection(settings.AbilityBackground)
end

function rematch.optionsPanel.widgetSetup:RandomPetRulesWidget()
    self.tooltipTitle = L["Random Pet Rules"]
    self.tooltipBody = L["Rules to apply when loading a random pet. The more strict rules will limit the pool of random pets to choose from.\n\nNote: When a team loads with random pets in all three slots, 'Lenient' rules are used regardless of this setting."]
    self.Label:SetText(self.tooltipTitle..":")
    self.DropDown:BasicSetup({
        {text=L["Strict"], value=C.RANDOM_RULES_STRICT, tooltipTitle=L["Scrict Rules"], tooltipBody=L["When a random pet is chosen, never pick pets saved in a team and never pick injured pets."]},
        {text=L["Normal"], value=C.RANDOM_RULES_NORMAL, tooltipTitle=L["Normal Rules"], tooltipBody=L["When a random pet is chosen, prefer pets not saved in a team and prefer uninjured pets."]},
        {text=L["Lenient"], value=C.RANDOM_RULES_LENIENT, tooltipTitle=L["Lenient Rules"], tooltipBody=L["When a random pet is chosen, allow pets saved in a team and prefer uninjured pets."]}
        },
        function(value) settings.RandomPetRules=value end)
    self.DropDown:SetSelection(settings.RandomPetRules)
end

function rematch.optionsPanel.widgetSetup:BreedSourceWidget()
    self.tooltipTitle = L["Breed Source"]
    self.tooltipBody = L["Which enabled addon you want to use to supply breed data."]
    self.Label:SetText(self.tooltipTitle..":")
    local sources = {{text=L["None"], value="None", tooltipTitle=L["None"], tooltipBody=L["No breed information will be shown if this is selected. Rematch does not maintain its own breed data."]}}

    if IsAddOnLoaded("BattlePetBreedID") then
        tinsert(sources,{text="Battle Pet Breed ID", value="BattlePetBreedID"})
    end
    if IsAddOnLoaded("PetTracker") then
        tinsert(sources,{text="PetTracker", value="PetTracker"})
    end
    self.DropDown:BasicSetup(sources,function(value)
        if value=="BattlePetBreedID" and settings.BreedFormat==C.BREED_FORMAT_ICONS then
            settings.BreedFormat = C.BREED_FORMAT_LETTERS -- if changing to BattlePetBreedID and format is icons, change format to letters
        end
        settings.BreedSource=value
        rematch.breedInfo:ResetBreedSource()
        rematch.frame:Update()
    end)
    self.DropDown:SetSelection(rematch.breedInfo:GetBreedSource() or "None")
end

function rematch.optionsPanel.widgetSetup:BreedFormatWidget()
    self.tooltipTitle = L["Breed Format"]
    self.tooltipBody = L["How breeds should display."]
    self.Label:SetText(self.tooltipTitle..":")
    local formats = {{text=L["Letters"], value=C.BREED_FORMAT_LETTERS},
                     {text=L["Numbers"], value=C.BREED_FORMAT_NUMBERS}}
    if IsAddOnLoaded("PetTracker") then
        tinsert(formats,{text=L["Icons"], value=C.BREED_FORMAT_ICONS})
    elseif settings.BreedFormat==C.BREED_FORMAT_ICONS then -- if PetTracker not enabled and breed format is icons, change to letters
        settings.BreedFormat = C.BREED_FORMAT_LETTERS
    end
    self.DropDown:BasicSetup(formats,function(value)
        if value==C.BREED_FORMAT_ICONS and settings.BreedSource=="BattlePetBreedID" then
            settings.BreedSource = "PetTracker" -- if changing to Icons and source isn't PetTracker, change source to PetTracker
            rematch.breedInfo:ResetBreedSource()
        end
        settings.BreedFormat=value
        rematch.frame:Update()
    end)
    self.DropDown:SetSelection(settings.BreedFormat)
end

function rematch.optionsPanel.widgetSetup:InteractOnTargetWidget()
    self.tooltipTitle = L["Interact On Target"]
    self.tooltipBody = L["Choose the action to take when you target an NPC with a saved team that's not already loaded."]
    self.Label:SetText(L["On Target:"])
    self.DropDown:BasicSetup({
            {text=L["Do Nothing"], value=C.INTERACT_NONE, tooltipTitle=L["Do Nothing"], tooltipBody=L["When targeting an NPC with a saved team not already loaded, do nothing."]},
            {text=L["Prompt To Load"], value=C.INTERACT_PROMPT, tooltipTitle=L["Prompt To Load"], tooltipBody=L["When targeting an NPC with a saved team not already loaded, show a prompt to load the save team."]},
            {text=L["Show Window"], value=C.INTERACT_WINDOW, tooltipTitle=L["Show Window"], tooltipBody=L["When targeting an NPC with a saved team not already loaded, show the standalone Rematch window."]},
            {text=L["Auto Load"], value=C.INTERACT_AUTOLOAD, tooltipTitle=L["Auto Load"], tooltipBody=format(L["When targeting an NPC with a saved team not already loaded, automatically load the saved team.\n\n%sWarning\124r: If you target with right click and immediately enter battle, it may be too late to load a team. %sAuto Load is not recommended for On Target.\124r Use On Mouseover for Auto Load instead."],C.HEX_RED,C.HEX_WHITE)}
        },
        function(value)
        settings.InteractOnTarget = value
        if value~=C.INTERACT_NONE then
            settings.InteractOnSoftInteract = C.INTERACT_NONE
            settings.InteractOnMouseover = C.INTERACT_NONE
            rematch.optionsPanel:Update()
            rematch.interact:Update()
        end
    end)
    self.DropDown:SetSelection(settings.InteractOnTarget)
end

function rematch.optionsPanel.widgetSetup:InteractOnSoftInteractWidget()
    self.tooltipTitle = L["Interact On Soft Interact"]
    self.tooltipBody = format(L["Choose the action to take when you soft interact with an NPC with a saved team that's not already loaded.\n\n%sNote\124r: This option is only available if SoftTargetInteract cvar is fully enabled (3). It will be hidden otherwise."],C.HEX_WHITE)
    self.Label:SetText(L["On Soft Interact:"])
    self.DropDown:BasicSetup({
            {text=L["Do Nothing"], value=C.INTERACT_NONE, tooltipTitle=L["Do Nothing"], tooltipBody=L["When soft interactiong with an NPC with a saved team not already loaded, do nothing."]},
            {text=L["Prompt To Load"], value=C.INTERACT_PROMPT, tooltipTitle=L["Prompt To Load"], tooltipBody=L["When soft interacting with an NPC with a saved team not already loaded, show a prompt to load the save team."]},
            {text=L["Show Window"], value=C.INTERACT_WINDOW, tooltipTitle=L["Show Window"], tooltipBody=L["When soft interacting with an NPC with a saved team not already loaded, show the standalone Rematch window."]},
            {text=L["Auto Load"], value=C.INTERACT_AUTOLOAD, tooltipTitle=L["Auto Load"], tooltipBody=format(L["When soft interacting with an NPC with a saved team not already loaded, automatically load the saved team."],C.HEX_RED,C.HEX_WHITE)}
        },
        function(value)
        settings.InteractOnSoftInteract = value
        if value~=C.INTERACT_NONE then
            settings.InteractOnTarget = C.INTERACT_NONE
            settings.InteractOnMouseover = C.INTERACT_NONE
            rematch.optionsPanel:Update()
            rematch.interact:Update()
        end
    end)
    self.DropDown:SetSelection(settings.InteractOnSoftInteract)
end

function rematch.optionsPanel.widgetSetup:InteractOnMouseoverWidget()
    self.tooltipTitle = L["Interact On Mouseover"]
    self.tooltipBody = L["Choose the action to take when the mouse moves over an NPC with a saved team that's not already loaded."]
    self.Label:SetText(L["On Mouseover:"])
    self.DropDown:BasicSetup({
            {text=L["Do Nothing"], value=C.INTERACT_NONE, tooltipTitle=L["Do Nothing"], tooltipBody=L["When the mouse moves over an NPC with a saved team not already loaded, do nothing."]},
            {text=L["Prompt To Load"], value=C.INTERACT_PROMPT, tooltipTitle=L["Prompt To Load"], tooltipBody=L["When the mouse moves over an NPC with a saved team not already loaded, show a prompt to load the save team."]},
            {text=L["Show Window"], value=C.INTERACT_WINDOW, tooltipTitle=L["Show Window"], tooltipBody=L["When the mouse moves over an NPC with a saved team not already loaded, show the standalone Rematch window."]},
            {text=L["Auto Load"], value=C.INTERACT_AUTOLOAD, tooltipTitle=L["Auto Load"], tooltipBody=L["When the mouse moves over an NPC with a saved team not already loaded, automatically load the saved team."]}
        },
        function(value)
        settings.InteractOnMouseover = value
        if value~=C.INTERACT_NONE then
            settings.InteractOnTarget = C.INTERACT_NONE
            settings.InteractOnSoftInteract = C.INTERACT_NONE
            rematch.optionsPanel:Update()
            rematch.interact:Update()
        end
    end)
    self.DropDown:SetSelection(settings.InteractOnMouseover)
end

function rematch.optionsPanel.widgetSetup:NotesFontWidget()
    self.tooltipTitle = L["Notes Size"]
    self.tooltipBody = L["Choose the size of the text in the pet and team notes."]
    self.Label:SetText(self.tooltipTitle..":")
    self.DropDown:BasicSetup({
            {text=L["Small"], value="GameFontHighlightSmall"},
            {text=L["Medium"], value="GameFontHighlight"},
            {text=L["Large"], value="GameFontHighlightLarge"},
        },
        function(value)
            settings.NotesFont = value
            rematch.notes:UpdateFont()
        end
    )
    self.DropDown:SetSelection(settings.NotesFont)
end

function rematch.optionsPanel.widgetSetup:UseCustomScaleWidget()
    self.tooltipTitle = L["Use Custom Scale"]
    self.tooltipBody = L["Adjust the relative size of the standalone Rematch window by changing its scale."]
    self.Text:SetText(L["Use Custom Scale"])
    self.ScaleButton.Text:SetFontObject(GameFontHighlight)
end

function rematch.optionsPanel.UseCustomScaleWidget:OnEnter()
    rematch.textureHighlight:Show(self.Check)
    rematch.tooltip:ShowSimpleTooltip(self,self.tooltipTitle,self.tooltipBody)
end

function rematch.optionsPanel.UseCustomScaleWidget:OnLeave()
    rematch.textureHighlight:Hide()
    rematch.tooltip:Hide()
end

function rematch.optionsPanel.UseCustomScaleWidget:OnMouseDown()
    rematch.textureHighlight:Hide()
end

function rematch.optionsPanel.UseCustomScaleWidget:OnMouseUp()
    if GetMouseFocus()==self then
        rematch.textureHighlight:Show(self.Check)
    end
end

function rematch.optionsPanel.UseCustomScaleWidget:OnClick()
    settings.CustomScale = not settings.CustomScale
    rematch.frame:UpdateScale()
    rematch.optionsPanel:Update()
    PlaySound(C.SOUND_CHECKBUTTON)
end

function rematch.optionsPanel.UseCustomScaleWidget.ScaleButton:OnClick()
    rematch.dialog:ShowDialog("CustomScaleDialog")
end

-- sets up the AnchorWidget and its dropdown control
function rematch.optionsPanel.widgetSetup:OptionsManagementWidget()
    self.Label:SetText(L["All Options:"])
    self.ResetButton:SetText(L["Reset"])
    self.ExportButton:SetText(L["Export"])
end

-- exports all non-default options in this format: var=value:var=value:etc=value:
-- settings that are tables are just the count of elements within the table
function rematch.optionsPanel.OptionsManagementWidget.ExportButton:OnClick()
    -- building a table so it can be sorted
    local results = {}
    for k,v in pairs(settings:GetDefaults()) do
        if type(v)=="table" then -- table contents aren't saved, just a count of its contents
            tinsert(results,k.."="..rematch.utils:GetSize(settings[k]))
        elseif v~=settings[k] then
            tinsert(results,k.."="..tostring(settings[k]))
        end
    end
    tinsert(results,"AllTeams="..rematch.utils:GetSize(rematch.savedTeams.AllTeams))
    table.sort(results)

    rematch.dialog:ShowDialog("ExportOptions",table.concat(results,"\n"))
end

function rematch.optionsPanel.OptionsManagementWidget.ResetButton:OnClick()
    rematch.dialog:ShowDialog("ResetOptions")
end

--[[ widget updates ]]

rematch.optionsPanel.widgetUpdate = {}

function rematch.optionsPanel.widgetUpdate:AnchorWidget()
    self.DropDown:SetSelection(settings.Anchor)
end

function rematch.optionsPanel.widgetUpdate:PanelTabAnchorWidget()
    self.DropDown:SetSelection(settings.PanelTabAnchor)
end

function rematch.optionsPanel.widgetUpdate:TooltipBehaviorWidget()
    self.DropDown:SetSelection(settings.TooltipBehavior)
end

function rematch.optionsPanel.widgetUpdate:CardBehaviorWidget()
    self.DropDown:SetSelection(settings.CardBehavior)
end

function rematch.optionsPanel.widgetUpdate:FlipKeyWidget()
    self.DropDown:SetSelection(settings.PetCardFlipKey)
end

function rematch.optionsPanel.widgetUpdate:CardBackWidget()
    self.DropDown:SetSelection(settings.PetCardBackground)
end

function rematch.optionsPanel.widgetUpdate:AbilityBackWidget()
    self.DropDown:SetSelection(settings.AbilityBackground)
end

function rematch.optionsPanel.widgetUpdate:RandomPetRulesWidget()
    self.DropDown:SetSelection(settings.RandomPetRules)
end

function rematch.optionsPanel.widgetUpdate:BreedSourceWidget()
    self.DropDown:SetSelection(rematch.breedInfo:GetBreedSource() or "None")
end

function rematch.optionsPanel.widgetUpdate:BreedFormatWidget()
    self.DropDown:SetSelection(settings.BreedFormat)
end

function rematch.optionsPanel.widgetUpdate:InteractOnTargetWidget()
    self.DropDown:SetSelection(settings.InteractOnTarget)
end

function rematch.optionsPanel.widgetUpdate:InteractOnSoftInteractWidget()
    self.DropDown:SetSelection(settings.InteractOnSoftInteract)
end

function rematch.optionsPanel.widgetUpdate:InteractOnMouseoverWidget()
    self.DropDown:SetSelection(settings.InteractOnMouseover)
end

function rematch.optionsPanel.widgetUpdate:NotesFontWidget()
    self.DropDown:SetSelection(settings.NotesFont)
end

function rematch.optionsPanel.widgetUpdate:UseCustomScaleWidget()
    local xoff = settings.CustomScale and 0.25 or 0
    self.Check:SetTexCoord(0+xoff,0.25+xoff,0.5,0.75)
    self.ScaleButton:SetShown(settings.CustomScale)
    self.ScaleButton:SetText(format("%d%%",settings.CustomScaleValue or 0))
end
