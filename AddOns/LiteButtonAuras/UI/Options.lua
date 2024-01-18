--[[----------------------------------------------------------------------------

  LiteBag/Options.lua

  Copyright 2015 Mike Battersby

----------------------------------------------------------------------------]]--

local addonName, LBA = ...

local L = setmetatable({}, { __index = function (t,k) return k end })

local LSM = LibStub('LibSharedMedia-3.0')
local FONT = LSM.MediaType.FONT
local ALL_FONTS = LSM:HashTable(FONT)

local ANCHOR_SELECT_VALUES = {
    BOTTOMLEFT = L["Bottom Left"],
    BOTTOM = L["Bottom"],
    BOTTOMRIGHT = L["Bottom Right"],
    RIGHT = L["Right"],
    TOPRIGHT = L["Top Right"],
    TOP = L["Top"],
    TOPLEFT = L["Top Left"],
    LEFT = L["Left"],
    CENTER = L["Center"]
}

local function Getter(info)
    local k = info[#info]
    return LBA.db.profile[k]
end

local function Setter(info, val ,...)
    local k = info[#info]
    LBA.SetOption(k, val)
end

local function FontPathGetter(info)
    for name, path in pairs(ALL_FONTS) do
        if path == LBA.db.profile.fontPath then
            return name
        end
    end
end

local function FontPathSetter(info, name)
    if ALL_FONTS[name] then
        LBA.SetOption('fontPath', ALL_FONTS[name])
    end
end

local function ValidateSpellValue(_, v)
    if v == "" or GetSpellInfo(v) ~= nil then
        return true
    else
        return format(L["無效的法術: %s.\n\n不在你的法術書裡面的法術請使用法術 ID 數字。"], ORANGE_FONT_COLOR:WrapTextInColorCode(v))
    end
end

local order
do
    local n = 0
    order = function () n = n + 1 return n end
end

local addAuraMap = { }
local addDenyAbility

local options = {
    type = "group",
	name = "光環時間 (快捷列)",
    childGroups = "tab",
    args = {
        GeneralGroup = {
            type = "group",
            name = GENERAL,
            order = order(),
            get = Getter,
            set = Setter,
            args = {
                topGap = {
                    type = "description",
                    name = "\n",
                    width = "full",
                    order = order(),
                },
                showTimers = {
                    type = "toggle",
                    name = L["顯示光環持續時間"],
                    order = order(),
                    width = "full",
                },
                colorTimers = {
                    type = "toggle",
                    name = L["依據剩餘時間變化文字顏色"],
                    order = order(),
                    width = "full",
                },
                decimalTimers = {
                    type = "toggle",
                    name = L["時間顯示小數點"],
                    order = order(),
                    width = "full",
                },
                showStacks = {
                    type = "toggle",
                    name = L["顯示光環層數"],
                    order = order(),
                    width = "full",
                },
                showSuggestions = {
                    type = "toggle",
                    name = L["斷法和安撫按鈕發光"],
                    order = order(),
                    width = "full",
                },
                preFontHeaderGap = {
                    name = "\n",
                    type = "description",
                    width = 'full',
                    order = order(),
                },
                FontHeader = {
                    type = "header",
                    name = L["文字大小"],
                    order = order(),
                },
                postFontHeaderGap = {
                    name = "",
                    type = "description",
                    width = 'full',
                    order = order(),
                },
                fontPath = {
                    type = "select",
                    name = L["字體"],
                    order = order(),
                    dialogControl = 'LSM30_Font',
                    values = ALL_FONTS,
                    get = FontPathGetter,
                    set = FontPathSetter,
                },
                fontSizePreGap = {
                    type = "description",
                    name = "",
                    width = 0.1,
                    order = order(),
                },
                fontSize = {
                    type = "range",
                    name = L["文字大小"],
                    order = order(),
                    min = 6,
                    max = 24,
                    step = 1,
                },
                preAnchorHeaderGap = {
                    name = "\n",
                    type = "description",
                    width = 'full',
                    order = order(),
                },
                AnchorHeader = {
                    type = "header",
                    name = L["位置"],
                    order = order(),
                },
                postAnchorHeaderGap = {
                    name = "",
                    type = "description",
                    width = 'full',
                    order = order(),
                },
                preTimerAnchorGap = {
                    name = "",
                    type = "description",
                    width = 0.1,
                    order = order(),
                },
                timerAnchor = {
                    name = L["時間位置"],
                    type = "select",
                    control = 'LBAAnchorButtons',
                    values = ANCHOR_SELECT_VALUES,
                    order = order(),
                },
                preStacksAnchorGap = {
                    name = "",
                    type = "description",
                    width = 0.25,
                    order = order(),
                },
                stacksAnchor = {
                    name = L["層數位置"],
                    type = "select",
                    control = 'LBAAnchorButtons',
                    values = ANCHOR_SELECT_VALUES,
                    order = order(),
                },
                AnchorsGap = {
                    name = "",
                    type = "description",
                    width = 'full',
                    order = order(),
                },
                preTimerAdjustGap = {
                    name = "",
                    type = "description",
                    width = 0.1,
                    order = order(),
                },
                timerAdjust = {
                    name = L["時間位置偏移"],
                    type = "range",
                    order = order(),
                    min = -16,
                    max = 16,
                    step = 1,
                },
                preStacksAdjustGap = {
                    name = "",
                    type = "description",
                    width = 0.25,
                    order = order(),
                },
                stacksAdjust = {
                    name = L["層數位置偏移"],
                    type = "range",
                    order = order(),
                    min = -16,
                    max = 16,
                    step = 1,
                },
            },
        },
        MappingGroup = {
            name = L["額外顯示光環"],
            type = "group",
            inline = false,
            args = {
                showAura = {
                    name = L["顯示光環"],
                    type = "input",
                    width = 1.4,
                    order = order(),
                    get =
                        function ()
                            if not addAuraMap[1] then return end
                            local spellName, _, _, _, _, _, spellID = GetSpellInfo(addAuraMap[1])
                            return ("%s (%s)"):format(spellName, spellID) .. "\0" .. addAuraMap[1]
                        end,
                    set =
                        function (_, v)
                            addAuraMap[1] = select(7, GetSpellInfo(v))
                        end,
                    control = 'LBAInputFocus',
                    validate = ValidateSpellValue,
                },
                preOnAbilityGap = {
                    name = "",
                    type = "description",
                    width = 0.1,
                    order = order(),
                },
                onAbility = {
                    name = L["於技能"],
                    type = "input",
                    width = 1.4,
                    order = order(),
                    get =
                        function ()
                            if not addAuraMap[2] then return end
                            local spellName, _, _, _, _, _, spellID = GetSpellInfo(addAuraMap[2])
                            return ("%s (%s)"):format(spellName, spellID) .. "\0" .. addAuraMap[2]
                        end,
                    set =
                        function (_, v)
                            addAuraMap[2] = select(7, GetSpellInfo(v))
                        end,
                    control = 'LBAInputFocus',
                    validate = ValidateSpellValue,
                },
                preAddButtonGap = {
                    name = "",
                    type = "description",
                    width = 0.1,
                    order = order(),
                },
                AddButton = {
                    name = ADD,
                    type = "execute",
                    width = 0.5,
                    order = order(),
                    disabled =
                        function (info, v)
                            local auraName = GetSpellInfo(addAuraMap[1])
                            local abilityName = GetSpellInfo(addAuraMap[2])
                            if auraName and abilityName and auraName ~= abilityName then
                                return false
                            else
                                return true
                            end
                        end,
                    func =
                        function ()
                            local auraID = select(7, GetSpellInfo(addAuraMap[1]))
                            local abilityID = select(7, GetSpellInfo(addAuraMap[2]))
                            if auraID and abilityID then
                                LBA.AddAuraMap(auraID, abilityID)
                                addAuraMap[1] = nil
                                addAuraMap[2] = nil
                            end
                        end,
                },
                Mappings = {
                    name = L["額外顯示光環"],
                    type = "group",
                    order = order(),
                    inline = true,
                    args = {},
                    plugins = {},
                }
            }
        },
        IgnoreGroup = {
            name = L["忽略技能"],
            type = "group",
            inline = false,
            args = {
                denyAbility = {
                    name = L["忽略技能"],
                    type = "input",
                    width = 1,
                    order = order(),
                    get =
                        function ()
                            if not addDenyAbility then return end
                            local spellName, _, _, _, _, _, spellID = GetSpellInfo(addDenyAbility)
                            return ("%s (%s)"):format(spellName, spellID) .. "\0" .. addDenyAbility
                        end,
                    set =
                        function (_, v)
                            addDenyAbility = select(7, GetSpellInfo(v))
                        end,
                    control = 'LBAInputFocus',
                    validate = ValidateSpellValue,
                },
                AddButton = {
                    name = ADD,
                    type = "execute",
                    width = 1,
                    order = order(),
                    disabled = function () return not GetSpellInfo(addDenyAbility) end,
                    func =
                        function ()
                            local denyAbilityID = select(7, GetSpellInfo(addDenyAbility))
                            if denyAbilityID then
                                LBA.AddDenySpell(denyAbilityID)
                                addDenyAbility = nil
                            end
                        end,
                },
                Abilities = {
                    name = L["技能"],
                    type = "group",
                    order = order(),
                    inline = true,
                    args = {},
                    plugins = {},
                }
            }
        }
    },
}


local function UpdateDynamicOptions()
    local auraMapList = LBA.GetAuraMapList()
    local auraMaps = {}
    for i, entry in ipairs(auraMapList) do
        auraMaps["mapAura"..i] = {
            order = 10*i,
            name = format("%s (%d)", NORMAL_FONT_COLOR:WrapTextInColorCode(entry[2]), entry[1]),
            type = "description",
            image = select(3, GetSpellInfo(entry[1])),
            imageWidth = 22,
            imageHeight = 22,
            width = 1.4,
        }
        auraMaps["onText"..i] = {
            order = 10*i+2,
            name = GRAY_FONT_COLOR:WrapTextInColorCode(L["於"]),
            type = "description",
            width = 0.15,
        }
        auraMaps["mapAbility"..i] = {
            order = 10*i+3,
            name = format("%s (%d)", NORMAL_FONT_COLOR:WrapTextInColorCode(entry[4]), entry[3]),
            type = "description",
            image = select(3, GetSpellInfo(entry[3])),
            imageWidth = 22,
            imageHeight = 22,
            width = 1.4,
        }
        auraMaps["delete"..i] = {
            order = 10*i+5,
            name = DELETE,
            type = "execute",
            func = function () LBA.RemoveAuraMap(entry[1], entry[3]) end,
            width = 0.45,
        }
    end
    options.args.MappingGroup.args.Mappings.plugins.auraMaps = auraMaps

    local denySpellList = {}
    local cc = ContinuableContainer:Create()
    for spellID in pairs(LBA.db.profile.denySpells) do
        local spell = Spell:CreateFromSpellID(spellID)
        if not spell:IsSpellEmpty() then
            if WOW_PROJECT_ID ~= 1 then
                spell.IsDataEvictable = function () return true end
                spell.IsItemDataCached = spell.IsSpellDataCached
                spell.ContinueWithCancelOnItemLoad = spell.ContinueWithCancelOnSpellLoad
            end
            cc:AddContinuable(spell)
            table.insert(denySpellList, spell)
        end
    end

    local ignoreAbilities = {}
    cc:ContinueOnLoad(
        function ()
            table.sort(denySpellList, function (a, b) return a:GetSpellName() < b:GetSpellName() end)
            for i, spell in ipairs(denySpellList) do
                ignoreAbilities["ability"..i] = {
                    name = format("%s (%d)",
                                NORMAL_FONT_COLOR:WrapTextInColorCode(spell:GetSpellName()),
                                spell:GetSpellID()),
                    type = "description",
                    image = select(3, GetSpellInfo(spell:GetSpellID())),
                    imageWidth = 22,
                    imageHeight = 22,
                    width = 2.5,
                    order = 10*i,
                }
                ignoreAbilities["delete"..i] = {
                    order = 10*i+5,
                    name = DELETE,
                    type = "execute",
                    func = function () LBA.RemoveDenySpell(spell:GetSpellID()) end,
                    width = 0.5,
                }
            end
            options.args.IgnoreGroup.args.Abilities.plugins.ignoreAbilites = ignoreAbilities
        end)
end

-- The sheer amount of crap required here is ridiculous. I bloody well hate
-- frameworks, just give me components I can assemble. Dot-com weenies ruined
-- everything, even WoW.

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigCmd = LibStub("AceConfigCmd-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions =  LibStub("AceDBOptions-3.0")

-- AddOns are listed in the Blizzard panel in the order they are
-- added, not sorted by name. In order to mostly get them to
-- appear in the right order, add the main panel when loaded.

AceConfig:RegisterOptionsTable(addonName, options, { "litebuttonauras", "lba" })
local optionsPanel, category = AceConfigDialog:AddToBlizOptions(addonName, "光環時間")

function LBA.InitializeGUIOptions()
    local profileOptions = AceDBOptions:GetOptionsTable(LBA.db)
    AceConfig:RegisterOptionsTable(addonName.."Profiles", profileOptions)
    AceConfigDialog:AddToBlizOptions(addonName.."Profiles", profileOptions.name, "光環時間")
    LBA.db.RegisterCallback(LBA, "OnProfileChanged", UpdateDynamicOptions)
    LBA.db.RegisterCallback(LBA, "OnProfileCopied", UpdateDynamicOptions)
    LBA.db.RegisterCallback(LBA, "OnProfileReset", UpdateDynamicOptions)
    LBA.db.RegisterCallback(LBA, "OnModified", UpdateDynamicOptions)
    UpdateDynamicOptions()
end

function LBA.OpenOptions()
    Settings.OpenToCategory(category)
end
