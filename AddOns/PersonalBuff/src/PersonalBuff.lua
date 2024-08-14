local BuffIcons,eventFrame
local enabledSpell
local updateTicker,updateTracker
local playerInfo = { }
local iconSize,iconSpacing
local media = LibStub("LibSharedMedia-3.0")
local XOffset = 0
local YOffset = 0
local enableAuraTable = {}
local buffFrame
defaultBuffDB={}
customBuffDB={}
partyBuffDB={}
showNameplateNumber = false

local function iconEnable(spellID)
    for _,i in ipairs(enabledSpell) do
        if i == spellID then
            return true
        end
    end
    return false
end

local function isNotExist (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return false
        end
    end
    return true
end
function RankCompare(a,b)
    if a.Rank == b.Rank and a.Index ~= nil and b.Index ~= nil then
        return a.Index < b.Index
    elseif a.Rank ~= nil and b.Rank ~= nil then
        return a.Rank < b.Rank
    end

end

local function getEnableAuraTable(aura)
    addCustomIcon(aura["spellId"])
    table.insert(enableAuraTable,aura)
end


local function InitializeDB()
    local defaultSettings = {
        char = {
            font = "BIG_BOLD",
            iconSize = 20,
            fontSize = 8,
            countFont = "BIG_BOLD",
            countFontSize = 6,
            iconSpacing = 0,
            XOffset = 0,
            YOffset = 0,
            customTexture = true,
            barTexture = "Flat_N",
            resourceNumber = false,
            resourceNumberType = "Numerical",
            resourceFont = "BIG_BOLD",
            resourceFontSize = 8,
            resourceAlignment = "CENTER",
            changeHealthBarColor = true,
			showDefault = true,
            spellList = {
                defaultSpellList = {},
                customSpellList = {},
                partySpellList = {
                    {10060,true,0},
                    {395152,true,0},
                    {32182,true,0},
                    {2825,true,0},
                    {80353,true,0},
                    {264667,true,0},
                    {390386,true,0},
                }
            },
        }
    }
    aceDB = LibStub("AceDB-3.0"):New("PersonalBuffAceDB", defaultSettings)
    setDBoptions()
end

local function hideBlizzardAuras()
    if C_NamePlate.GetNamePlateForUnit("player", issecure()) ~= nil then
        C_NamePlate.GetNamePlateForUnit("player", issecure()).UnitFrame.BuffFrame:Hide()
    end
end

local function setBuffFramePoint()
    if C_NamePlate.GetNamePlateForUnit("player", issecure()) ~= nil then
        buffFrame:SetFramePoint(C_NamePlate.GetNamePlateForUnit("player", issecure()).UnitFrame.BuffFrame)
    end
end

function checkEnableSpell(spellID, val)
    if val == true then
        table.insert(enabledSpell,spellID)
    else
        for i,k in ipairs(enabledSpell) do
            if k == spellID then
                table.remove(enabledSpell,i)
            end
        end
    end
end

local original
local function setNameplateBarTexture()
    if aceDB.char.customTexture then
        local barTexture = aceDB.char.barTexture
        local nameplate = C_NamePlate.GetNamePlateForUnit("player", issecure())
        if nameplate then
            if original == nil then
                original = nameplate.UnitFrame.HealthBarsContainer.healthBar.barTexture:GetTexture()
            end
            if nameplate.driverFrame and nameplate.driverFrame.classNamePlatePowerBar then
                nameplate.driverFrame.classNamePlatePowerBar.Texture:SetTexture(media.MediaTable.statusbar[barTexture])
            end
            nameplate.UnitFrame.HealthBarsContainer.healthBar.barTexture:SetTexture(media.MediaTable.statusbar[barTexture])
        end
    end
end

local function setHealthBarClassColor()
    local nameplate = C_NamePlate.GetNamePlateForUnit("player", issecure())
    if nameplate then
        local _,classFilename = UnitClass("player")
        local r,g,b = GetClassColor(classFilename) -- 暫時修正
        nameplate.UnitFrame.HealthBarsContainer.healthBar:SetStatusBarColor(r,g,b,1)
    end
end

local function healthBarReset(nameplateToken)
    local playerNameplate = C_NamePlate.GetNamePlateForUnit("player", issecure())
    if playerNameplate ~=nil and playerNameplate.namePlateUnitToken == nameplateToken then
    elseif original ~= nil then
        local nameplate = C_NamePlate.GetNamePlateForUnit(nameplateToken, issecure())
        nameplate.UnitFrame.HealthBarsContainer.healthBar.barTexture:SetTexture(original)
    end
end

local function setNameplateHealthText(unitToken)
    local nameplate = C_NamePlate.GetNamePlateForUnit("player", issecure())
    if UnitIsUnit("player",unitToken) and nameplate ~= nil and showNameplateNumber then
        local alpha = nameplate:GetAlpha()
        if healthFrame == nil then
            InitializeHealthNumber(nameplate.UnitFrame.HealthBarsContainer.healthBar:GetSize())
        end
        healthFrame:SetAllPoints(nameplate.UnitFrame.HealthBarsContainer.healthBar)
        healthFrame:SetAlpha(alpha)
        healthFrame.update()

    end
end

local function setNameplatePowerText(unitToken)
    local nameplate = C_NamePlate.GetNamePlateForUnit("player", issecure())
    if UnitIsUnit("player",unitToken) and nameplate ~= nil and showNameplateNumber then
        local alpha = nameplate:GetAlpha()
        if nameplate.driverFrame and nameplate.driverFrame.classNamePlatePowerBar then

            if powerFrame == nil then
                InitializePowerNumber(nameplate.driverFrame.classNamePlatePowerBar:GetSize())
            end

            powerFrame:SetAllPoints(nameplate.driverFrame.classNamePlatePowerBar)
            powerFrame:SetAlpha(alpha)
            powerFrame.update()
        end
    end
end
local function setNameplateNumber(unitToken)
    setNameplateHealthText(unitToken)
    setNameplatePowerText(unitToken)
end


local function initialBuffFrame()
    local IconSetting = {}
    IconSetting.iconSize = aceDB.char.iconSize
    IconSetting.iconSpacing =aceDB.char.iconSpacing
    IconSetting.countFont = media.MediaTable.font[aceDB.char.countFont]
    IconSetting.countFontSize = aceDB.char.countFontSize
    IconSetting.font = media.MediaTable.font[aceDB.char.font]
    IconSetting.fontSize = aceDB.char.fontSize
    IconSetting.XOffset = aceDB.char.XOffset
    IconSetting.YOffset = aceDB.char.YOffset
    local FrameSetting = {}
    FrameSetting.Width = aceDB.char.iconSize * 10
    FrameSetting.Height = aceDB.char.iconSize
    FrameSetting.Spells = {}
    FrameSetting.IconSetting = IconSetting

    return CreateBuffFrame(FrameSetting)
end

function adjustmentFont()
    buffFrame.FrameSetting.IconSetting.font = media.MediaTable.font[aceDB.char.font]
    buffFrame.FrameSetting.IconSetting.fontSize = aceDB.char.fontSize
    buffFrame:SetFont()
end

function adjustmentCountFont()
    buffFrame.FrameSetting.IconSetting.countFont = media.MediaTable.font[aceDB.char.countFont]
    buffFrame.FrameSetting.IconSetting.countFontSize = aceDB.char.countFontSize
    buffFrame:SetCountFont()
end

function adjustmentIconSize()
    buffFrame.FrameSetting.IconSetting.iconSize = aceDB.char.iconSize
    buffFrame:SetIconSize()
end

function adjustmentIconSpacing()
    buffFrame.FrameSetting.IconSetting.iconSpacing = aceDB.char.iconSpacing
end

function setXOffset()
    buffFrame.FrameSetting.IconSetting.XOffset = aceDB.char.XOffset
end

function setYOffset()
    buffFrame.FrameSetting.IconSetting.YOffset = aceDB.char.YOffset
end

local function clearResourceNumberFrame()
    if healthFrame ~= nil then
        healthFrame:Hide()
        healthFrame = nil
    end
    if powerFrame ~= nil then
        powerFrame:Hide()
        powerFrame = nil
    end
end

local function GetBuffInfoFromAuraInstanceID(unit, auraInstanceID)
    local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
    if aura then
        return aura.name
    end
    return nil
end

local function buffDBContainsValue(t, value)
    for _, subTable in ipairs(t) do
        if subTable[1] == value then
            return true
        end
    end
    return false
end

local function ContainsValue(t, value)
    for _, v in ipairs(t) do
        if v == value then
            return true
        end
    end
    return false
end


local function InsertUniqueValue(t, value)
    if not ContainsValue(t, value) then
        table.insert(t, value)
    end
end
defaultBuffTable = {}
local defaultBuffIDTable = {}
local spellLayoutList = {}
local minIndexList = {}
local function getDefaultBuffIDTable()
    defaultBuffIDTable = {}
    spellLayoutList = {}
    if C_NamePlate.GetNamePlateForUnit("player", issecure()) ~= nil then
        local BuffFrame = C_NamePlate.GetNamePlateForUnit("player", issecure()).UnitFrame.BuffFrame
        local Buffs = {BuffFrame:GetChildren()}

        for i,k in ipairs(Buffs) do
            if k:IsShown() then
                if k["spellID"] ~= nil then
                    table.insert(defaultBuffIDTable, k["spellID"])
                    spellLayoutList [k["spellID"]] = k["layoutIndex"]

                    if minIndexList[k["spellID"]] == nil or minIndexList[k["spellID"]] < k["layoutIndex"]  then
                        minIndexList[k["spellID"]] = k["layoutIndex"]
                    end

                    InsertUniqueValue(defaultBuffTable, k["spellID"])
                end
            end
        end
    end
end
local function updateAura()
    enableAuraTable = {}
    enableAuraTable.alpha = 1

    if C_NamePlate.GetNamePlateForUnit("player", issecure()) ~= nil then
        enableAuraTable.alpha = C_NamePlate.GetNamePlateForUnit("player", issecure()):GetAlpha()
    else
        return
    end

    buffFrame:clear()
    for i, spell in ipairs(partyBuffDB) do
        local buff = C_UnitAuras.GetPlayerAuraBySpellID(spell[1])
        if buff ~= nil and spell[2] then
            buff.Rank = spell[3]
            getEnableAuraTable(buff)
        end
    end

    for i, k in ipairs(defaultBuffIDTable) do
        local findStatus = false
        if k ~= nil then
            local buff = C_UnitAuras.GetPlayerAuraBySpellID(k)
            if buff ~= nil then
                for _, subTable in ipairs(defaultBuffDB) do
                    if subTable[1] == k then
                        if subTable[2] then
                            buff.Rank = subTable[3] or subTable[4]
                            buff.Index = spellLayoutList[k]
                            getEnableAuraTable(buff)
                        end
                        findStatus = true
                    end
                end
                if not findStatus then
                    buff.Rank = spellLayoutList[k]
                    getEnableAuraTable(buff)
                end
            end
        end
    end

    for i, spell in ipairs(customBuffDB) do
        local buff = C_UnitAuras.GetPlayerAuraBySpellID(spell[1])
        if buff ~= nil and spell[2] then
            buff.Rank = spell[3]
            getEnableAuraTable(buff)
        end
    end

    table.sort(enableAuraTable,RankCompare)

    buffFrame:display(enableAuraTable)
end

local function checkDefaultSpellListDB()
    for _,i in ipairs(defaultBuffTable) do
        if buffDBContainsValue(defaultBuffDB, i) then
            for _, subTable in ipairs(defaultBuffDB) do
                if subTable[1] == i then
                    subTable[4] = minIndexList[i]
                end
            end
        else
            table.insert(defaultBuffDB, { i, true, nil , minIndexList[i]} )
        end
    end
end

local function hideBlizzardBuffFrame(unitToken)
    if UnitIsUnit("player",unitToken) then
        C_NamePlate.GetNamePlateForUnit(unitToken, issecure()).UnitFrame.BuffFrame:SetAlpha(0)
    else
        C_NamePlate.GetNamePlateForUnit(unitToken, issecure()).UnitFrame.BuffFrame:SetAlpha(1)
    end
end

local function updatePlayerHealth(unit)
    if UnitIsUnit("player",unit) then
        health = UnitHealth("player")
    end
end


local function loadBuffDB()
    defaultBuffDB = aceDB.char.spellList.defaultSpellList
    customBuffDB = aceDB.char.spellList.customSpellList
    partyBuffDB = aceDB.char.spellList.partySpellList
end

local function EventHandler(self, event,...)
    if event == "PLAYER_ENTERING_WORLD" then
        InitializeDB()
        loadBuffDB()
        buffFrame = initialBuffFrame()
        UpdateDefaultBuffs()
        UpdateCustomBuffs()
        showNameplateNumber = aceDB.char.resourceNumber
        setBuffConfig(partyBuffDB)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
        if  UnitIsUnit("player",select(1, ...)) then
            buffFrame:clear()
            clearResourceNumberFrame()
            defaultBuffIDTable = {}
        end
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        healthBarReset(...)
		hideBlizzardBuffFrame(...)
        if aceDB.char.resourceNumber then -- 暫時修正
			setNameplateNumber(...)
		end
		if aceDB.char.changeHealthBarColor then
			setHealthBarClassColor() -- 暫時修正
		end
		setNameplateBarTexture() -- 暫時修正
        setBuffFramePoint()
		-- if nameplate show before UNIT_AURA ,maybe buff frame will not show so need trigger it
		if  UnitIsUnit("player",select(1, ...)) then
            getDefaultBuffIDTable()
            updateAura()
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        checkDefaultSpellListDB()
        UpdateDefaultBuffs()
	elseif event == "UNIT_AURA" then
        if  UnitIsUnit("player",select(1, ...)) then
            getDefaultBuffIDTable()
            updateAura()
        end
    elseif event == "UNIT_HEALTH" then
        setNameplateHealthText(...)
    elseif event == "UNIT_POWER_FREQUENT" then
        setNameplatePowerText(...)
    end
end

local function registerAuraEvent()
    eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    eventFrame:RegisterEvent("UNIT_AURA")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    eventFrame:RegisterEvent("UNIT_HEALTH")
    eventFrame:RegisterEvent("UNIT_POWER_FREQUENT")
	
    eventFrame:SetScript("OnEvent", EventHandler)
end

function resetBuffFrame()
    buffFrame:clear()
    buffFrame = nil
    getPlayerInfo()
    buffFrame = initialBuffFrame()
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


function addClassSpells(SpellTable)
    if SpellTable ~= nil then
        for _,i in pairs(SpellTable) do
            local isExist = false
            for _,e in ipairs(playerInfo.classSpells) do
                if i == e then
                    isExist = true
                    break
                end
            end
            if isExist == false then
                table.insert(playerInfo.classSpells,i)
            end

        end
    end
end

registerAuraEvent()
updateTracker = false