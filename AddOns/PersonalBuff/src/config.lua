local AceConfig = LibStub("AceConfig-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("PersonalBuff")
local media = LibStub("LibSharedMedia-3.0")

local mainOption,options

function UpdateCustomBuffs()
    local order = mainOption.args["Buffs"].args["customBuff"].order + 1

    for i, k in ipairs(customBuffDB) do
        mainOption.args["Buffs"].args["customBuff" .. i] = {
            order = order,
            type = "toggle",
            name = function() return format("|T%s:16|t %s", C_Spell.GetSpellTexture(k[1]), C_Spell.GetSpellInfo(k[1])["name"]) end,
            desc = string.format("%s \nid : %d",C_Spell.GetSpellDescription(k[1]),k[1]),
            get = function(info) return customBuffDB[i][2] end,
            set = function(info, value) customBuffDB[i][2] = value end,
        }
        order = order + 1

        mainOption.args["Buffs"].args["customBuffRange" .. i] = {
            order = order,
            type = "range",
            name = L["Priority"] ,
            desc = L["The higher the rank ordering more right"],
            max = 15,
            min = 0,
            step = 1,
            get = function(info)  return customBuffDB[i][3] end,
            set = function(info, value) customBuffDB[i][3] = value end,
        }
        order = order + 1
    end
    mainOption.args["Buffs"].args["addCustomBuff"].order = order + 1
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Personal Buff")
end

local function buffDBContainsValue(t, value)
    for _, subTable in ipairs(t) do
        if subTable[1] == value then
            return true
        end
    end
    return false
end

function UpdateDefaultBuffs()
    local order = mainOption.args["Buffs"].args["defaultBuff"].order + 1

    for i, k in ipairs(defaultBuffDB) do
        mainOption.args["Buffs"].args["defaultBuff" .. i] = {
            order = order,
            type = "toggle",
            name = function() return format("|T%s:16|t %s", C_Spell.GetSpellTexture(k[1]), C_Spell.GetSpellInfo(k[1])["name"]) end,
            desc = string.format("%s \nid : %d",C_Spell.GetSpellDescription(k[1]),k[1]),
            get = function(info) return defaultBuffDB[i][2] end,
            set = function(info, value) defaultBuffDB[i][2] = value end,
        }
        order = order + 1

        mainOption.args["Buffs"].args["defaultBuffRange" .. i] = {
            order = order,
            type = "range",
            name = L["Priority"] ,
            desc = L["The higher the rank ordering more right"],
            max = 15,
            min = 0,
            step = 1,
            get = function(info)  return defaultBuffDB[i][3] or defaultBuffDB[i][4] end,
            -- 如果有 RANK(defaultBuffDB[i][3])，使用 RANK，否则使用 INDEX(defaultBuffDB[i][4])
            set = function(info, value) defaultBuffDB[i][3] = value

            end,
        }
        order = order + 1
    end
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Personal Buff")
end



local function getClassOption()
    mainOption = {
        type = "group",
        name = L["option"],
        args = {
            Buffs = {
                order = 1,
                name = L["Buffs"],
                type = "group",
                args = {
                    defaultBuff = {
                        order = 1,
                        type = "header",
                        name = L["Default buff"],
                    },
                    customBuff = {
                        order = 50,
                        type = "header",
                        name = L["Custom buff"],
                    },
                    addCustomBuff = {
                        order = 51,
                        type = "input",
                        name = L["Add Custom Buff (Spell ID)"],
                        desc = L["Enter the Spell ID of the buff you want to add."],
                        get = function() return "" end,
                        set = function(info, value)
                            local spellID = tonumber(value)
                            if spellID then
                                local spellName = C_Spell.GetSpellName(spellID)
                                if spellName then
                                    StaticPopup_Show("CONFIRM_ADD_CUSTOM_BUFF", spellName, spellID, {spellID = spellID, spellName = spellName})
                                else
                                    print(L["Invalid Spell ID."])
                                end
                            else
                                print(L["Please enter a valid number."])
                            end
                        end,
                    },
                    partybuff = {
                        order = 100,
                        type = "header",
                        name = L["Party buff"],
                    },
                }
            },
            personalBar = {
                order = 2,
                name = L["personal bar"],
                type = "group",
                args = {
                    personalBar = {
                        order = 1,
                        type = "header",
                        name = L["personal bar"],
                    },
                    setDefault = {
                        order = 3,
                        type = "execute",
                        name = L["default"],

                        func = function()
                            SetCVar("nameplateSelfTopInset", 0.50)
                            SetCVar("nameplateSelfBottomInset", 0.20)
                        end,

                    },
                    personalBarAnchor = {
                        order = 2,
                        type = "range",
                        name = L["personalBarAnchor"],
                        min = 20,
                        max = 70,
                        step = 1,
                        get = function()
                            return tonumber(100 - GetCVar("nameplateSelfTopInset") * 100)
                        end,
                        set = function(info, val)
                            SetCVar("nameplateSelfBottomInset", val / 100)
                            SetCVar("nameplateSelfTopInset", abs(val - 100) / 100)
                        end,
                    },
                    customTexture = {
                        order = 4,
                        type = "toggle",
                        name = L["customTexture"],
                        confirm = function(info, v)
                            if v then
								return L["Changes will take effect the next time you reload"]
							else
                                return L["Disabling the texture will make them reset next time you reload, are you sure?"]
                            end
                        end,
                        get = function(info)
                            return aceDB.char.customTexture
                        end,
                        set = function(info, val)
                            aceDB.char.customTexture = val
                        end,
                    },
                    barTexture = {
                        order = 5,
                        type = "select",
                        style = "dropdown",
                        name = L["personalBarTexture"],
                        values = media:List("statusbar"),
                        itemControl = "DDI-Statusbar",
                        disabled = function()
                            return not (aceDB.char.customTexture)
                        end,
						confirm = function(info, v)
							return L["Changes will take effect the next time you reload"]
                        end,
                        get = function(info)
                            for i, v in next, media:List("statusbar") do
                                if v == aceDB.char.barTexture then
                                    return i
                                end
                            end
                        end,
                        set = function(info, key)
                            local list = media:List("statusbar")
                            local texture = list[key]
                            aceDB.char.barTexture = texture
                        end,
                    },

                    changeHealthBarColor = {
                        order = 6,
                        type = "toggle",
                        name = L["change health bar Color by class color"],
                        confirm = function(info, v)
                            if v then
								return L["Health bar color will change after the character moves"]
							else
                                return L["Reset the health bar color next time you reload"]
                            end
                        end,
                        get = function(info)
                            return aceDB.char.changeHealthBarColor
                        end,
                        set = function(info, val)
                            aceDB.char.changeHealthBarColor = val
                        end,
                    },
                    alwayshow = {
                        order = 7,
                        type = "toggle",
                        name = L["alway show"],

                        get = function(info)
                            if GetCVar("NameplatepersonalShowAlways") == "0" then
                                return false
                            else

                                return true
                            end
                        end,
                        set = function(info, val)
                            if val == false then
                                SetCVar("NameplatepersonalShowAlways", "0")
                            else
                                SetCVar("NameplatepersonalShowAlways", "1")
                            end

                        end,
                    },
                },

            },
            column = {
                order = 3,
                name = L["icons"],
                type = "group",
                args = {
                    iconHeader = {
                        order = 0,
                        type = "header",
                        name = L["icon"],
                    },
                    font = {
                        order = 1,
                        type = "select",
                        style = "dropdown",
                        name = L["font"],
                        values = media:List("font"),
                        itemControl = "DDI-Font",
                        get = function(info)
                            for i, v in next, media:List("font") do
                                if v == aceDB.char.font then
                                    return i
                                end
                            end
                        end,
                        set = function(info, key)
                            local list = media:List("font")
                            local font = list[key]
                            aceDB.char.font = font

                            adjustmentFont()
                        end,
                    },
                    iconSize = {
                        order = 2,
                        type = "range",
                        name = L["iconSize"],
                        min = 12,
                        max = 45,
                        step = 1,
                        get = function(info)
                            return aceDB.char.iconSize
                        end,
                        set = function(info, val)
                            aceDB.char.iconSize = val
                            adjustmentIconSize()
                        end,
                    },

                    fontSize = {
                        order = 3,
                        type = "range",
                        name = L["fontSize"],
                        min = 6,
                        max = 14,
                        step = 1,
                        get = function(info)
                            return aceDB.char.fontSize
                        end,
                        set = function(info, val)
                            aceDB.char.fontSize = val
                            adjustmentFont()
                        end,
                    },
                    iconSpacing = {
                        order = 4,
                        type = "range",
                        name = L["iconSpacing"],
                        min = -10,
                        max = 10,
                        step = 1,
                        get = function(info)
                            return aceDB.char.iconSpacing
                        end,
                        set = function(info, val)
                            aceDB.char.iconSpacing = val
                            adjustmentIconSpacing()
                        end,
                    },
                    XOffset = {
                        order = 5,
                        type = "range",
                        name = L["X offset"],
                        min = -50,
                        max = 50,
                        step = 1,
                        get = function(info)
                            return aceDB.char.XOffset
                        end,
                        set = function(info, val)
                            aceDB.char.XOffset = val
                            setXOffset()
                        end,
                    },
                    YOffset = {
                        order = 5,
                        type = "range",
                        name = L["Y offset"],
                        min = -50,
                        max = 50,
                        step = 1,
                        get = function(info)
                            return aceDB.char.YOffset
                        end,
                        set = function(info, val)
                            aceDB.char.YOffset = val
                            setYOffset()
                        end,
                    },
                    countFont = {
                        order = 6,
                        type = "select",
                        style = "dropdown",
                        name = L["count font"],
                        values = media:List("font"),
                        itemControl = "DDI-Font",
                        get = function(info)
                            for i, v in next, media:List("font") do
                                if v == aceDB.char.countFont then
                                    return i
                                end
                            end
                        end,
                        set = function(info, key)
                            local list = media:List("font")
                            local font = list[key]
                            aceDB.char.countFont = font
                            adjustmentCountFont()
                        end,
                    },
                    countFontSize = {
                        order = 7,
                        type = "range",
                        name = L["count font size"],
                        min = 4,
                        max = 18,
                        step = 1,
                        get = function(info)
                            return aceDB.char.countFontSize
                        end,
                        set = function(info, val)
                            aceDB.char.countFontSize = val
                            adjustmentCountFont()
                        end,
                    },
                },

            },
            resourceNumber = {
                order = 4,
                name = L["Resource Number"],
                type = "group",
                args = {
                    show = {
                        order = 1,
                        type = "toggle",
                        name = L["Show"],
						confirm = function(info, v)
							return L["Changes will take effect the next time you reload"]
                        end,

                        get = function(info)
                            return aceDB.char.resourceNumber
                        end,
                        set = function(info, val)
                            aceDB.char.resourceNumber = val
                            showNameplateNumber = aceDB.char.resourceNumber
                        end,
                    },
                    header = {
                        order = 2,
                        type = "header",
                        name = "",
                    },
                    font = {
                        order = 3,
                        type = "select",
                        style = "dropdown",
                        name = L["font"],
                        values = media:List("font"),
                        itemControl = "DDI-Font",
						confirm = function(info, v)
							return L["Changes will take effect the next time you reload"]
                        end,
                        get = function(info)
                            for i, v in next, media:List("font") do
                                if v == aceDB.char.resourceFont then
                                    return i
                                end
                            end
                        end,
                        set = function(info, key)
                            local list = media:List("font")
                            local font = list[key]
                            aceDB.char.resourceFont = font
                        end,
                        disabled = function()
                            return not aceDB.char.resourceNumber
                        end,
                    },
                    size = {
                        order = 4,
                        type = "range",
                        name = L["fontSize"],
                        min = 6,
                        max = 14,
                        step = 1,
						confirm = function(info, v)
							return L["Changes will take effect the next time you reload"]
                        end,
                        get = function(info)
                            return aceDB.char.resourceFontSize
                        end,
                        set = function(info, val)
                            aceDB.char.resourceFontSize = val
                        end,
                        disabled = function()
                            return not aceDB.char.resourceNumber
                        end,
                    },
                    alignment = {
                        order = 5,
                        type = "select",
                        style = "dropdown",
                        name = L["alignment"],
                        values = {
                            LEFT = L["left"],
                            CENTER = L["center"],
                            RIGHT = L["right"],
                        },
						confirm = function(info, v)
							return L["Changes will take effect the next time you reload"]
                        end,
                        get = function(info)
                            return aceDB.char.resourceAlignment
                        end,
                        set = function(info, val)
                            aceDB.char.resourceAlignment = val
                        end,
                        disabled = function()
                            return not aceDB.char.resourceNumber
                        end,
                    },
                    type = {
                        order = 6,
                        type = "select",
                        style = "dropdown",
                        name = L["Type"],
                        values = {
                            Numerical = L["Numerical"],
                            Percent = L["Percent"],
                            Both = L["Both"],
                        },
						confirm = function(info, v)
							return L["Changes will take effect the next time you reload"]
                        end,
                        get = function(info)
                            return aceDB.char.resourceNumberType
                        end,
                        set = function(info, val)
                            aceDB.char.resourceNumberType = val
                        end,
                        disabled = function()
                            return not aceDB.char.resourceNumber
                        end,
                    },
                }
            }
        }
    }

end
customBuffTable = {}
StaticPopupDialogs["CONFIRM_ADD_CUSTOM_BUFF"] = {
    text = L["Do you want to add the buff: %s (%d)?"],
    button1 = YES,
    button2 = NO,
    OnAccept = function(self, data)
        if not buffDBContainsValue(defaultBuffDB,data.spellID) and not buffDBContainsValue(partyBuffDB,data.spellID) and not buffDBContainsValue(customBuffDB,data.spellID) then
            table.insert(customBuffDB, {data.spellID, true, 10})
            UpdateCustomBuffs()
            print(data.spellName,L["added successfully."])
        else
            print(data.spellName,L["is exist."])
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function getOptions()
    if not options then
        options = {
            type = "group",
            name = L["Personal Buff"],
            args = {
                mainOption = mainOption
            }
        }
    end

    return options
end


local function SetupOptions()
    optionsFrames = {}
    getClassOption()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Personal Buff", getOptions)
    optionsFrames.PersonalBuff = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Personal Buff", L["personal bar"], nil,"mainOption")
end




function setDBoptions()
    mainOption.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(aceDB)
end



function setBuffConfig(buffTable)
    local order = mainOption.args["Buffs"].args["partybuff"].order + 1
	for i,k in ipairs(buffTable) do
        mainOption.args["Buffs"].args[tostring(((i + 2) * 2 ) - 1)] = {
            type = "toggle",
            order = order,
            name = function() return format("|T%s:16|t %s", C_Spell.GetSpellTexture(k[1]), C_Spell.GetSpellInfo(k[1])["name"]) end,
            desc = string.format("%s \nid : %d",C_Spell.GetSpellDescription(k[1]),k[1]),
            get = function(info)
                return aceDB.char.spellList.partySpellList[i][2]
            end,
            set = function(info, val)
                aceDB.char.spellList.partySpellList[i][2] = val
            end,
        }
        order = order + 1
        mainOption.args["Buffs"].args[tostring(((i + 2) * 2 ))] = {
            order = order,
            type = "range",
            name = L["Priority"] ,
            desc = L["The higher the rank ordering more right"],
            max = 15,
            min = 0,
            step = 1,
            get = function(info)
                  return aceDB.char.spellList.partySpellList[i][3]
            end,
            set = function(info, val)
                aceDB.char.spellList.partySpellList[i][3] = val
            end,
        }
        order = order + 1
    end
end

media:Register("font","BIG_BOLD",[[Interface\AddOns\PersonalBuff\font\BIG_BOLD.TTF]],255 )
media:Register("statusbar","Flat_N",[[Interface\AddOns\PersonalBuff\texture\nameplate.blp]],255 )

SetupOptions()

local previousOnShow = optionsFrames.PersonalBuff:GetScript("OnShow")

optionsFrames.PersonalBuff:SetScript("OnShow", function(self)
    table.sort(defaultBuffDB, function(a, b)
        local rankA = a[3] or a[4]
        local rankB = b[3] or b[4]

        return rankA < rankB
    end)
    if previousOnShow then
        previousOnShow(self)
    end
end)

