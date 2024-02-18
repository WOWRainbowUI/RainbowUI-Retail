local _,rematch = ...
local L = rematch.localization
local C = rematch.constants
local settings = rematch.settings
rematch.loadoutPanel = rematch.frame.LoadoutPanel
rematch.frame:Register("loadoutPanel")

function rematch.loadoutPanel:Update()
    for i=1,3 do
        local petID,ability1,ability2,ability3,locked = C_PetJournal.GetPetLoadOutInfo(i)

        self.Loadouts[i].petID = petID -- before possibly changing petID to a battle:1:x, save petIDs to loadout/pet button
        self.Loadouts[i].Pet.petID = petID
        if C_PetBattles.IsInBattle() then
            petID = "battle:1:"..i -- if in a pet battle, use the battle petID to get health updates during battle
        end

        self:FillSpecial(self.Loadouts[i],self.Loadouts[i]:GetID()) -- fills back and special badge/button at top of loadout
        self:FillLoadout(self.Loadouts[i],petID) -- fills pet, including name and pet badges
        self.Loadouts[i].AbilityBar:FillAbilityBar(petID,ability1,ability2,ability3) -- fills abilities
        self:FillStatusBars(self.Loadouts[i],petID) -- fills status bars
        self:FillModelScene(self.Loadouts[i],petID) -- fills pet model

        self.Loadouts[i].LockOverlay:SetShown(rematch.utils:IsJournalLocked())
    end
    self.AbilityFlyout:Hide()
    self:UpdateGlow()
end

function rematch.loadoutPanel:UpdateGlow()
    for i=1,3 do
        local showGlow = rematch.utils:IsPetOnCursor()
        if showGlow then
            self.Loadouts[i].Animation:Play()
        else
            self.Loadouts[i].Animation:Stop()
        end
        self.Loadouts[i].Glow:SetShown(showGlow)
    end
end

-- updates background for special types (leveling, random, ignored) and handles special slot badge
function rematch.loadoutPanel:FillSpecial(loadout,slot)
    if rematch.loadouts:IsSlotSpecial(slot) then
        local altID = rematch.loadouts:GetSlotInfo(slot)
        local altInfo = rematch.altInfo:Fetch(altID)
        local color
        if altInfo.idType=="leveling" then
            color = C.LOADOUT_COLOR_LEVELING
            loadout.SpecialButton.tooltipTitle = L["Leveling Pet"]
            loadout.SpecialButton.tooltipBody = L["When this team loads, a pet from the leveling queue will go in this spot."]
            loadout.SpecialButton.Icon:SetTexCoord(0.375,0.5,0.125,0.25)
        elseif altInfo.idType=="random" then
            color = C.LOADOUT_COLOR_RANDOM
            loadout.SpecialButton.tooltipTitle = L["Random Pet"]
            loadout.SpecialButton.tooltipBody = L["When this team loads, a random high level pet will go in this spot."]
            loadout.SpecialButton.Icon:SetTexCoord(rematch.utils:GetBadgeCoordsByPetType(altInfo.petType))
        elseif altInfo.idType=="ignored" then
            color = C.LOADOUT_COLOR_IGNORED
            loadout.SpecialButton.tooltipTitle = L["Ignored Slot"]
            loadout.SpecialButton.tooltipBody = L["When this team loads, this spot will be ignored."]
            loadout.SpecialButton.Icon:SetTexCoord(0.125,0.25,0.75,0.875)
        else
            -- normal loadout color; this shouldn't have run
            color = C.LOADOUT_COLOR_NORMAL
        end
        loadout.Back:SetDesaturated(true)
        loadout.Back:SetVertexColor(color[1],color[2],color[3])
        loadout.SpecialButton:Show()
    else
        loadout.Back:SetDesaturated(false)
        loadout.Back:SetVertexColor(1,1,1)
        loadout.SpecialButton:Hide()
    end
end

-- fills a loadout slot for the petID: type decal, notes, breed, badges, names
function rematch.loadoutPanel:FillLoadout(loadout,petID)
    local petInfo = rematch.petInfo:Fetch(petID)
    local slot = loadout:GetID()

    loadout.Pet:FillPet(petID)

    -- pet type decal in the topright
    if petInfo.suffix then
        loadout.TypeDecal:SetTexture("Interface\\PetBattles\\PetIcon-"..petInfo.suffix)
        loadout.TypeDecal:Show()
    else
        loadout.TypeDecal:Hide()
    end

    -- notes button in the topright
    local showNotes = not settings.HideNotesBadges and petInfo.hasNotes
    loadout.NotesButton:SetShown(showNotes)

    -- breed in topright beneath notes button
    local breedXoff = -14
    if petInfo.breedName and not settings.HideBreedsLoadouts then
        loadout.Breed:SetFontObject(settings.LargerBreedText and "GameFontNormal" or "GameFontNormalSmall")
        loadout.Breed:SetText(petInfo.breedName)
        loadout.Breed:Show()
        breedXoff = breedXoff - ceil(loadout.Breed:GetStringWidth())
    else
        loadout.Breed:Hide()
    end

    -- badges in topright to left of notes button
    local right = showNotes and -34 or -12
    local badgesWidth = rematch.badges:AddBadges(loadout.Badges,"pets",petID,"TOPRIGHT",loadout,"TOPRIGHT",right,-24,-1)

    -- names between pet button and notes/badges/breed
    local nameXoff = min(right,breedXoff)
    local nameYoff = -21
    loadout.PetName:SetPoint("TOPLEFT",70,nameYoff)
    loadout.PetName:SetPoint("TOPRIGHT",nameXoff,nameYoff)
    loadout.PetName:SetText(petInfo.name)
    local nameHeight = loadout.PetName:GetStringHeight()
    if petInfo.customName then
        loadout.SpeciesName:SetText(petInfo.speciesName)
        loadout.SpeciesName:Show()
        nameHeight = nameHeight + loadout.SpeciesName:GetStringHeight() + 2
    else
        loadout.SpeciesName:Hide()
    end
    -- if name+species name takes up less space than icon height, nudge it down
    if nameHeight < 46 then
        nameYoff = -21-floor((46-nameHeight)/2+0.5)+1
        loadout.PetName:SetPoint("TOPLEFT",70,nameYoff)
        loadout.PetName:SetPoint("TOPRIGHT",nameXoff,nameYoff)
    end
    -- color the name
    if settings.ColorPetNames and petInfo.color then
        loadout.PetName:SetTextColor(petInfo.color.r,petInfo.color.g,petInfo.color.b)
    else
        loadout.PetName:SetTextColor(1,0.82,0)
    end
end

-- unlike mini loadout, the regular loadout bars never move position; though the xp bar is still only visible for pets under 25
function rematch.loadoutPanel:FillStatusBars(loadout,petID)
    local petInfo = rematch.petInfo:Fetch(petID)
    local showXpBar = petInfo.level and petInfo.level<25
    loadout.XpBar:SetShown(showXpBar)
    loadout.XpBarBack:SetShown(showXpBar)
    loadout.XpBarBorder:SetShown(showXpBar)
    if petInfo.level and petInfo.level<25 then
        rematch.utils:UpdateStatusBar(loadout.XpBar,petInfo.xp,petInfo.maxXp,C.LOADOUT_XPBAR_WIDTH,C.XP_BAR_COLOR.r,C.XP_BAR_COLOR.g,C.XP_BAR_COLOR.b)
    end
    local showHpBar = petInfo.health and petInfo.maxHealth
    loadout.HpBar:SetShown(showHpBar)
    loadout.HpBarBack:SetShown(showHpBar)
    loadout.HpBarBorder:SetShown(showHpBar)
    loadout.HeartIcon:SetShown(showHpBar)
    loadout.HealthText:SetShown(showHpBar)
    if showHpBar then
        rematch.utils:UpdateStatusBar(loadout.HpBar,petInfo.health,petInfo.maxHealth,C.LOADOUT_HPBAR_WIDTH,C.HP_BAR_COLOR.r,C.HP_BAR_COLOR.g,C.HP_BAR_COLOR.bg)
        loadout.HealthText:SetText(petInfo.shortHealthStatus)
    end
end

-- updates loadout pet model
function rematch.loadoutPanel:FillModelScene(loadout,petID)
    local petInfo = rematch.petInfo:Fetch(petID)
    local displayID = petInfo.displayID
    if not displayID then
        loadout.ModelScene:Hide()
    else
        loadout.ModelScene:Show()
        if displayID ~= loadout.displayID then
            loadout.displayID = displayID
            local _,loadoutModelSceneID = C_PetJournal.GetPetModelSceneInfoBySpeciesID(petInfo.speciesID)
            loadout.ModelScene:TransitionToModelSceneID(loadoutModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange)
            local battlePetActor = loadout.ModelScene:GetActorByTag("pet")
            if battlePetActor then
                battlePetActor:SetModelByCreatureDisplayID(displayID)
                battlePetActor:SetAnimationBlendOperation(LE_MODEL_BLEND_OPERATION_NONE)
            end
        end
    end
end

function rematch.loadoutPanel:OnShow()
    rematch.events:Register(self,"REMATCH_LOADOUTS_CHANGED",self.Update)
    rematch.events:Register(self,"REMATCH_ABILITIES_CHANGED",self.Update)
    rematch.events:Register(self,"REMATCH_PET_PICKED_UP_ON_CURSOR",self.Update)
    rematch.events:Register(self,"REMATCH_PET_DROPPED_FROM_CURSOR",self.Update)
    rematch.events:Register(self,"PET_BATTLE_HEALTH_CHANGED",self.Update) -- health changing during battle
    rematch.events:Register(self,"REMATCH_TEAM_LOADED",self.REMATCH_TEAM_LOADED) -- team loaded, flash pets
    self:UpdateGlow()
end

function rematch.loadoutPanel:OnHide()
    --self.AbilityFlyout:Hide()
    rematch.events:Unregister(self,"REMATCH_LOADOUTS_CHANGED")
    rematch.events:Unregister(self,"REMATCH_ABILITIES_CHANGED")
    rematch.events:Unregister(self,"REMATCH_PET_PICKED_UP_ON_CURSOR")
    rematch.events:Unregister(self,"REMATCH_PET_DROPPED_FROM_CURSOR")
    rematch.events:Unregister(self,"PET_BATTLE_HEALTH_CHANGED")
    rematch.events:Unregister(self,"REMATCH_TEAM_LOADED")
end

-- flashes the three loadout slots when a team finishes loading
function rematch.loadoutPanel:REMATCH_TEAM_LOADED()
    self:Update()
    self:BlingLoadouts()
end

function rematch.loadoutPanel:BlingLoadouts()
    for i=1,3 do
        self.Loadouts[i].Bling:Show()
    end
end

--[[ script handlers for Loadout slots ]]

function rematch.loadoutPanel:LoadoutOnEnter()
    self.Highlight:Show()
    rematch.cardManager:OnEnter(rematch.petCard,self,self.petID)
end

function rematch.loadoutPanel:LoadoutOnLeave()
    self.Highlight:Hide()
    if GetMouseFocus()~=self.Pet then -- don't dismiss card if moving onto pet button
        rematch.cardManager:OnLeave(rematch.petCard,self,self.petID)
    end
end

function rematch.loadoutPanel:LoadoutOnMouseDown()
    if rematch.utils:IsJournalUnlocked() then
        self.Highlight:Hide()
    end
end

function rematch.loadoutPanel:LoadoutOnMouseUp()
    if GetMouseFocus()==self and rematch.utils:IsJournalUnlocked() then
        self.Highlight:Show()
    end
end

function rematch.loadoutPanel:LoadoutOnClick(button)
    if rematch.utils:IsJournalLocked() then
        rematch.cardManager:OnClick(rematch.petCard,self,self.petID) -- if journal locked, only allow locking pet card
    elseif button=="RightButton" then
        if rematch.petInfo:Fetch(self.petID).idType=="pet" then
            rematch.menus:Show("LoadoutMenu",self,{slot=self:GetID(),petID=self.petID},"cursor")
        end
    else
        if rematch.utils:IsPetOnCursor() then -- if pet is on the cursor then drop pet into this loadout
            rematch.loadoutPanel.LoadoutOnReceiveDrag(self)
        else -- otherwise lock/unlock pet card
            rematch.cardManager:OnClick(rematch.petCard,self,self.petID)
        end
    end
end

function rematch.loadoutPanel:LoadoutOnDoubleClick()
    if not settings.NoSummonOnDblClick then
        C_PetJournal.SummonPetByGUID(self.petID)
        rematch.petCard:Hide()
    end
end

function rematch.loadoutPanel:LoadoutOnDragStart()
    if rematch.utils:IsJournalUnlocked() then
        local petInfo = rematch.petInfo:Fetch(self.petID)
        if petInfo.isOwned and petInfo.idType=="pet" then
            C_PetJournal.PickupPet(self.petID)
        end
    end
end

function rematch.loadoutPanel:LoadoutOnReceiveDrag()
    if rematch.utils:IsJournalUnlocked() then
        local petID = rematch.utils:GetPetCursorInfo()
        if petID then
            ClearCursor()
            rematch.loadouts:SlotPet(self:GetID(),petID)
            rematch.petCard:Hide()
            rematch.loadoutPanel.LoadoutOnEnter(self) -- go through motions of entering since new pet here
            PlaySound(C.SOUND_DRAG_STOP)
        end
    end
end

--[[ script handlers for pet buttons within loadout slots ]]

function rematch.loadoutPanel:PetOnEnter()
    self:GetParent().Highlight:Show()
    rematch.textureHighlight:Show(self.Icon)
    rematch.cardManager:OnEnter(rematch.petCard,self:GetParent(),self.petID)
end

function rematch.loadoutPanel:PetOnLeave()
    self:GetParent().Highlight:Hide()
    rematch.textureHighlight:Hide()
    if GetMouseFocus()~=self:GetParent() then
        rematch.cardManager:OnLeave(rematch.petCard,self:GetParent(),self.petID)
    end
end

function rematch.loadoutPanel:PetOnMouseDown()
    if rematch.utils:IsJournalUnlocked() then
        self:GetParent().Highlight:Hide()
        rematch.textureHighlight:Hide()
    end
end

function rematch.loadoutPanel:PetOnMouseUp()
    if GetMouseFocus()==self and rematch.utils:IsJournalUnlocked() then
        self:GetParent().Highlight:Show()
        rematch.textureHighlight:Show(self.Icon)
    end
end

function rematch.loadoutPanel:PetOnClick(button)
    if rematch.utils:IsJournalLocked() then
        rematch.cardManager:OnClick(rematch.petCard,self,self.petID) -- if journal locked, only allow locking pet card
    elseif rematch.utils:IsPetOnCursor() then
        rematch.loadoutPanel.PetOnReceiveDrag(self)
    else
        local petInfo = rematch.petInfo:Fetch(self.petID)
        if petInfo.isOwned and petInfo.idType=="pet" then
            if button=="RightButton" then
                rematch.menus:Show("LoadoutMenu",self,{slot=self:GetParent():GetID(),petID=self.petID},"cursor")
            elseif rematch.utils:HandleSpecialPetClicks(self.petID) then
                -- if stone targeting or shift-clicking handled, do nothing
            else
                C_PetJournal.PickupPet(self.petID)
            end
        end
    end
end

function rematch.loadoutPanel:PetOnDragStart()
    if rematch.utils:IsJournalUnlocked() then
        local petInfo = rematch.petInfo:Fetch(self.petID)
        if petInfo.isOwned and petInfo.idType=="pet" then
            C_PetJournal.PickupPet(self.petID)
        end
    end
end

function rematch.loadoutPanel:PetOnReceiveDrag()
    if rematch.utils:IsJournalUnlocked() then
        local petID = rematch.utils:GetPetCursorInfo()
        if petID then
            ClearCursor()
            rematch.loadouts:SlotPet(self:GetParent():GetID(),petID)
            rematch.petCard:Hide()
            rematch.loadoutPanel.PetOnEnter(self)
        end
    end
end

-- OnUpdate closes flyout after C.FLYOUT_OPEN_TIMER passes with mouse not on the flyout or ability that opened it
local flyoutTimer = 0
function rematch.loadoutPanel.AbilityFlyout:OnUpdate(elapsed)
    if self.anchoredTo and (MouseIsOver(self.anchoredTo) or MouseIsOver(self)) then
        flyoutTimer = 0
    else
        flyoutTimer = flyoutTimer + elapsed
        if flyoutTimer > C.FLYOUT_OPEN_TIMER then
            self:Hide()
        end
    end
end

--[[ script handlers for special buttons at the top of loadout slots (leveling, random, ignored) ]]

function rematch.loadoutPanel:SpecialOnEnter()
    rematch.textureHighlight:Show(self.Icon)
    rematch.tooltip:ShowSimpleTooltip(self) -- tooltip is updated in the loadout update
end

function rematch.loadoutPanel:SpecialOnLeave()
    rematch.textureHighlight:Hide()
    rematch.tooltip:Hide()
end

function rematch.loadoutPanel:SpecialOnMouseDown()
    if rematch.utils:IsJournalUnlocked() then
        rematch.textureHighlight:Hide()
    end
end

function rematch.loadoutPanel:SpecialOnMouseUp()
    if GetMouseFocus()==self and rematch.utils:IsJournalUnlocked() then
        rematch.textureHighlight:Show(self.Icon)
    end
end

function rematch.loadoutPanel:SpecialOnClick(button)
    if rematch.utils:IsJournalUnlocked() then
        rematch.menus:Show("SpecialMenu",self,{slot=self:GetParent():GetID()},"cursor")
    end
end

--[[ script handlers for lock in topleft corner when journal locked ]]

function rematch.loadoutPanel:LockOnEnter()
    rematch.textureHighlight:Show(self)
    if not C_PetJournal.IsJournalUnlocked() then
        rematch.tooltip:ShowSimpleTooltip(self,LOCKED,PET_JOURNAL_READONLY_TEXT)
    elseif C_PetBattles.GetPVPMatchmakingInfo() then
        rematch.tooltip:ShowSimpleTooltip(self,LOCKED,ERR_PETBATTLE_QUEUE_QUEUED)
    end
end

function rematch.loadoutPanel:LockOnLeave()
    rematch.textureHighlight:Hide()
    rematch.tooltip:Hide()
end