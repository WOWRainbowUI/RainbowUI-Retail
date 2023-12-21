local _,rematch = ...
local L = rematch.localization
local C = rematch.constants
local settings = rematch.settings
rematch.battle = {}

rematch.events:Register(rematch.battle,"PLAYER_LOGIN",function(self)
    if IsAddOnLoaded("Blizzard_PetBattleUI") then -- if already loaded on login, run setup right away
        self:Setup()
    else -- otherwise register for battle ui to load before doing setup
        rematch.events:Register(self,"ADDON_LOADED",self.ADDON_LOADED)
    end
end)

-- watches for battle ui being loaded and calls a setup if so
function rematch.battle:ADDON_LOADED(addon)
    if addon=="Blizzard_PetBattleUI" then
        self:Setup()
        rematch.events:Unregister(self,"ADDON_LOADED")
    end
end

-- one-time setup after battle ui is loaded
function rematch.battle:Setup()

    for _,parentKey in ipairs({"ActiveAlly","ActiveEnemy","Ally2","Ally3","Enemy2","Enemy3"}) do
        local frame = PetBattleFrame[parentKey]
        frame:HookScript("OnEnter",self.UnitOnEnter)
        frame:HookScript("OnLeave",self.UnitOnLeave)
        frame:HookScript("OnClick",self.UnitOnClick)
    end

    -- add anchor exceptions for pet card on ActiveAlly and ActiveEnemy
    rematch.cardManager:AddAnchorException(rematch.petCard,PetBattleFrame.ActiveAlly,"TOP",PetBattleFrame.ActiveAlly,"BOTTOM",0,16)
    rematch.cardManager:AddAnchorException(rematch.petCard,PetBattleFrame.ActiveEnemy,"TOP",PetBattleFrame.ActiveEnemy,"BOTTOM",0,16)

    rematch.events:Register(self,"PET_BATTLE_FINAL_ROUND",self.PET_BATTLE_FINAL_ROUND)
    rematch.events:Register(self,"PET_BATTLE_CLOSE",self.PET_BATTLE_CLOSE)
end

-- from the given owner,index, return a petID, either the owned petID (if petOwner is ally), or "battle:2:index"
function rematch.battle:GetUnitPetID(petOwner,petIndex)
    -- if all ally 3 ally pets loaded, then we can use loadouts to get actual petID
    -- (if a pet is dead, then index 2 pet could be loadout slot 3; so can't easily get petID)
    -- TODO: petInfo is going to loadouts anyway; this is a bug to fix for future (kinda messy)
    if petOwner==Enum.BattlePetOwner.Ally and petIndex and C_PetBattles.GetNumPets(Enum.BattlePetOwner.Ally)==3 then
        return (rematch.loadouts:GetLoadoutInfo(petIndex))
    elseif petIndex then
        return format("battle:%d:%d",petOwner,petIndex) -- this will return an enemy battle:owner:index link
    end
end

function rematch.battle:UnitOnEnter()
    if settings.PetCardInBattle then
        PetBattlePrimaryUnitTooltip:Hide()
        rematch.cardManager:OnEnter(rematch.petCard,self,rematch.battle:GetUnitPetID(self.petOwner,self.petIndex))
    end
end

function rematch.battle:UnitOnLeave()
    if settings.PetCardInBattle then
        rematch.cardManager:OnLeave(rematch.petCard,self,rematch.battle:GetUnitPetID(self.petOwner,self.petIndex))
    end
end

function rematch.battle:UnitOnClick(button)
    if button~="RightButton" and settings.PetCardInBattle then
        rematch.cardManager:OnClick(rematch.petCard,self,rematch.battle:GetUnitPetID(self.petOwner,self.petIndex))
    end
end

-- as battle is ending, record if it was a pvp battle
function rematch.battle:PET_BATTLE_FINAL_ROUND(winner)
    self.wasInPVP = not C_PetBattles.IsPlayerNPC(Enum.BattlePetOwner.Enemy)
end

-- this is called in pairs, so don't use toggle
function rematch.battle:PET_BATTLE_CLOSE()
    if settings.ShowAfterBattle and not (self.wasInPVP and settings.ShowAfterPVEOnly) and not rematch.frame:IsVisible() then
        rematch.frame:Toggle(true)
        -- pvp pets don't actually take damage, so update frame after leaving battle
        rematch.timer:Start(C.QUEUE_PROCESS_WAIT,rematch.frame.Update)
    end
    if rematch.notes:IsVisible() and not rematch.notes.Content.ScrollFrame.EditBox:HasFocus() and not settings.KeepNotesOnScreen then
        rematch.cardManager:HideCard(rematch.notes)
    end
end