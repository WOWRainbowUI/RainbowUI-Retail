local addonName, addon = ...
local utils = addon.utils
local dialog = addon.dialog
local lang = addon.language
local const = addon.const
local config = addon.config
local event = addon.event
local UICheckBox = dialog.checkbox
dialog.dropdown = dialog.dropdown or utils.class("dialog.dropdown", UICheckBox).new()
local UIDropDownMenu = dialog.dropdown

local DIFFICULTY_TEXT = {
    [const.DIFFICULTY_NORMAL] = lang["difficulty.normal"],
    [const.DIFFICULTY_HEROIC] = lang["difficulty.heroic"],
    [const.DIFFICULTY_MYTHIC] = lang["difficulty.mythic"],
    [const.DIFFICULTY_MYTHICPLUS] = lang["difficulty.mythicplus"],
}

local showInfo = {
    ["showclassinfo"] = {const.CATEGORY_TYPE_DUNGEON},
    ["showclassbar"] = {const.CATEGORY_TYPE_DUNGEON},
    ["showservername"] = {},
    ["showleaderscore"] = {const.CATEGORY_TYPE_DUNGEON, const.CATEGORY_TYPE_ARENA, const.CATEGORY_TYPE_RBG},
    ["showleaderraidprocess"] = {const.CATEGORY_TYPE_RAID, const.CATEGORY_TYPE_CLASSRAID}
}

local shortcutoption = 
{
    --"quicksingnup",
    "autorolecheck",
    "autoacceptinvite",
    "autoinviteapplicate",
}

local ORDERTYPE_TEXT = {
    [const.ORDER_TYPE_DEFAULT] = lang["dialog.order.default"],
    [const.ORDER_TYPE_TIME] = lang["dialog.order.time"],
    [const.ORDER_TYPE_SCORE] = lang["dialog.order.score"],
    [const.ORDER_TYPE_LESS_PROCESS] = lang["dialog.order.lessprocess"],
    [const.ORDER_TYPE_MORE_PROCESS] = lang["dialog.order.moreprocess"],
}

local orderTypes = {
    [const.ORDER_TYPE_DEFAULT] = {},  --默认排序
    [const.ORDER_TYPE_TIME] = {},     --按时间排序
    [const.ORDER_TYPE_SCORE] = {const.CATEGORY_TYPE_DUNGEON, const.CATEGORY_TYPE_ARENA, const.CATEGORY_TYPE_RBG},    --按分数排序
    [const.ORDER_TYPE_LESS_PROCESS] = {const.CATEGORY_TYPE_RAID, const.CATEGORY_TYPE_CLASSRAID},  --按击杀数量排序
    [const.ORDER_TYPE_MORE_PROCESS] = {const.CATEGORY_TYPE_RAID, const.CATEGORY_TYPE_CLASSRAID},  --按击杀数量排序
}

local dropdownFields = {
    "Difficulty",
    "Dungeon",
    "Class",
    "ShowInfo",
    "ShortcutOption",
    "Order",
}

--order
function UIDropDownMenu:onOrderMenuChanged(frame)
    local arg1 = config:getValue({"order", "value"}, utils.getCategory()) or const.ORDER_TYPE_DEFAULT
    UIDropDownMenu_SetText(frame, ORDERTYPE_TEXT[arg1])
end

function UIDropDownMenu:onOrderMenuUpdated(frame, arg1, arg2, checked)
    config:setValue({"order", "value"}, arg1, utils.getCategory())
    self:setChecked(frame.owner:GetParent().Act, true)
    self:onOrderMenuChanged(frame.owner)
end

function UIDropDownMenu:initOrderMenu(frame, level, menuList)
    for k, v in ipairs(orderTypes) do
        local categoryId = utils.getCategory()
        if utils.tindexof(v, categoryId) or #v == 0 then
            local entry = UIDropDownMenu_CreateInfo()
            entry.text, entry.value, entry.arg1 = ORDERTYPE_TEXT[k], k, k
            entry.keepShownOnClick = false
            entry.notCheckable = 1
            entry.func = utils.handler(self, UIDropDownMenu.onOrderMenuUpdated)
            entry.owner = frame
            UIDropDownMenu_AddButton(entry)
        end
    end
end

--difficulty
function UIDropDownMenu:onDifficultyMenuChanged(frame)
    local arg1 = config:getValue({"difficulty", "value"}, utils.getCategory()) or const.DIFFICULTY_MYTHIC
    UIDropDownMenu_SetText(frame, DIFFICULTY_TEXT[arg1])
end

function UIDropDownMenu:onDifficultyMenuUpdated(frame, arg1, arg2, checked)
    config:setValue({"difficulty", "value"}, arg1, utils.getCategory())
    self:setChecked(frame.owner:GetParent().Act, true)
    self:onDifficultyMenuChanged(frame.owner)
end

function UIDropDownMenu:initDifficultyMenu(frame, level, menuList)
    for k, v in ipairs(DIFFICULTY_TEXT) do
        local entry = UIDropDownMenu_CreateInfo()
        entry.text  = v
        entry.value = k
        entry.arg1 = k
        entry.keepShownOnClick = false
        entry.owner = frame
        entry.notCheckable = 1
        entry.func = utils.handler(self, UIDropDownMenu.onDifficultyMenuUpdated)
        UIDropDownMenu_AddButton(entry)
    end
end

function UIDropDownMenu:onDifficultyMenuChanged(frame)
    local arg1 = config:getValue({"difficulty", "value"}, utils.getCategory()) or const.DIFFICULTY_MYTHIC
    UIDropDownMenu_SetText(frame, DIFFICULTY_TEXT[arg1])
end

function UIDropDownMenu:onDifficultyMenuUpdated(frame, arg1, arg2, checked)
    config:setValue({"difficulty", "value"}, arg1, utils.getCategory())
    self:setChecked(frame.owner:GetParent().Act, true)
    self:onDifficultyMenuChanged(frame.owner)
end

function UIDropDownMenu:initDifficultyMenu(frame, level, menuList)
    for k, v in ipairs(DIFFICULTY_TEXT) do
        local entry = UIDropDownMenu_CreateInfo()
        entry.text  = v
        entry.value = k
        entry.arg1 = k
        entry.keepShownOnClick = false
        entry.owner = frame
        entry.notCheckable = 1
        entry.func = utils.handler(self, UIDropDownMenu.onDifficultyMenuUpdated)
        UIDropDownMenu_AddButton(entry)
    end
end

function UIDropDownMenu:onDungeonMenuChanged(frame, userInput)
    local function selectDungeonCount()
        local selectedCount = 0
        local selectedNames = {}

        local dungeon = config:getValue({"dungeon"}, utils.getCategory())

        if dungeon then
            if dungeon.group then
                utils.twalk(dungeon.group, function(v, k)
                    if v then
                        selectedCount = selectedCount + 1
                        local name = C_LFGList.GetActivityGroupInfo(k)
                        table.insert(selectedNames, name)
                    end
                end)
            end

            if dungeon.activity then
                utils.twalk(dungeon.activity, function(v, k)
                    if v then
                        selectedCount = selectedCount + 1
                        local activityInfo = C_LFGList.GetActivityInfoTable(k)
                        table.insert(selectedNames, activityInfo.fullName)
                    end
                end)
            end
        end

        return selectedCount, selectedNames
    end

    local selectedCount, selectedNames = selectDungeonCount()

    local showText = ""
    if selectedCount == 0 then
        showText = lang["dialog.unselect"]
    else
        showText = string.format("|cFF00FF00(%d)%s|r", selectedCount, table.concat(selectedNames, ","))
    end

    UIDropDownMenu_SetText(frame, showText)

    if userInput then
        self:setChecked(frame:GetParent().Act, (selectedCount ~= 0))
    end
end

function UIDropDownMenu:onDungeonMenuReset(frame, arg1, arg2, checked)
    config:setValue({"dungeon"}, {}, utils.getCategory())
    self:onDungeonMenuChanged(frame.owner, true)
end

function UIDropDownMenu:onDungeonMenuUpdated(frame, arg1, arg2, checked)
    --[[if arg1 == const.DUNGEON_MENU_TYPE_LIST then
        --utils.dump(frame.menuList, " onDungeonMenuUpdated frame.menuList")
        utils.dump(checked, "checked")
        for k,v in pairs(frame.menuList) do
            local type = (v.groupId and v.groupId) and "group" or "activity"
            local value = (v.groupId and v.groupId) and v.groupId or v.activityId

            config:setValue({"dungeon", type, value}, checked, utils.getCategory())
        end
    else
        config:setValue({"dungeon", (arg1 == const.DUNGEON_MENU_TYPE_GROUP and "group" or "activity"), frame.value}, checked, utils.getCategory())
    end]]

    config:setValue({"dungeon", (arg1 == const.DUNGEON_MENU_TYPE_GROUP and "group" or "activity"), frame.value}, checked, utils.getCategory())
    self:onDungeonMenuChanged(frame.owner, true)
end

function UIDropDownMenu:onDungeonMenuChecked(frame)
    --[[if frame.arg1 == const.DUNGEON_MENU_TYPE_LIST then
        if not frame.menuList then
            return false
        end

        for k,v in pairs(frame.menuList) do
            local checked = false
            local type = (v.groupId and v.groupId) and "group" or "activity"
            local value = (v.groupId and v.groupId) and v.groupId or v.activityId

            checked = config:getValue({"dungeon", type, value}, utils.getCategory()) or false

            if checked == true then
                return true
            end
        end

        return false
    end]]

    return config:getValue({"dungeon",(frame.arg1 == const.DUNGEON_MENU_TYPE_GROUP and "group" or "activity"), frame.value}, utils.getCategory()) or false
end

local function MakeActivityMenuTable(activityId, baseFilter)
    local activityInfo = C_LFGList.GetActivityInfoTable(activityId)
    local data = {}

    data.text = activityInfo.fullName
    data.categoryId = activityInfo.categoryID
    data.groupId = activityInfo.groupFinderActivityGroupID
    data.activityId = activityId
    data.filters = activityInfo.filters
    data.baseFilter = baseFilter
    return data
end

local function MakeGroupMenuTable(categoryId, groupId, baseFilter)
    local data = {}

    data.text = C_LFGList.GetActivityGroupInfo(groupId)
    data.categoryId = categoryId
    data.groupId = groupId
    data.baseFilter = baseFilter
    return data
end

local function MakeVersionMenuTable(categoryId, versionId, baseFilter, menuType)
    local data = {}
    data.text = _G['EXPANSION_NAME' .. versionId]
    data.versionId = versionId

    local menuTable = {}

    for _, groupId in ipairs(C_LFGList.GetAvailableActivityGroups(categoryId, baseFilter)) do
        if addon.CATEGORY[versionId].groups[groupId] then
            tinsert(menuTable, MakeGroupMenuTable(categoryId, groupId, baseFilter))
        end
    end

    for _, activityId in ipairs(C_LFGList.GetAvailableActivities(categoryId, nil, baseFilter)) do
        local activityInfo = C_LFGList.GetActivityInfoTable(activityId);
        if addon.CATEGORY[versionId].activities[activityId] and activityInfo.groupFinderActivityGroupID == 0 then
            tinsert(menuTable, MakeActivityMenuTable(activityId, baseFilter))
        end
    end

    if #menuTable > 0 then
        data.menuTable = menuTable
        data.hasArrow = true
    else
        return
    end
    return data
end

local function MakeCategoryMenuTable(categoryId, baseFilter)
	local category_data = C_LFGList.GetLfgCategoryInfo(categoryId)
    local name, autoChoose = category_data.name,category_data.autoChooseActivity
    local menuTable = {}
    if categoryId == const.CATEGORY_TYPE_DUNGEON or categoryId == const.CATEGORY_TYPE_RAID then
        for i = LE_EXPANSION_LEVEL_CURRENT, 0, -1 do
            local versionMenu = MakeVersionMenuTable(categoryId, i, baseFilter)
            if versionMenu then
                tinsert(menuTable, versionMenu)
            end
        end
    elseif autoChoose and categoryId ~= const.CATEGORY_TYPE_CUSTOM then
        return MakeActivityMenuTable(C_LFGList.GetAvailableActivities(categoryId)[1], nil, baseFilter)
    else
        local list = C_LFGList.GetAvailableActivityGroups(categoryId)
        local count = #list
        if count > 1 then
            local s, e, step = 1, count, 1
            if categoryId == 1 then
                s, e, step = e, s, -1
            end
            for i = s, e, step do
                tinsert(menuTable, MakeGroupMenuTable(categoryId, list[i], baseFilter))
            end
        end
        for _, activityId in ipairs(C_LFGList.GetAvailableActivities(categoryId, nil, baseFilter)) do
            local activityInfo = C_LFGList.GetActivityInfoTable(activityId);
            if activityInfo.groupFinderActivityGroupID == 0 or count == 1 then
                tinsert(menuTable, MakeActivityMenuTable(activityId, baseFilter))
            end
        end
    end

    return menuTable
end

function UIDropDownMenu:initDungeonMenu(frame, level, menuList)
    if not LFGListFrame or not LFGListFrame.CategorySelection then
        return
    end

    local function addEntry(value, level)
        local entry = UIDropDownMenu_CreateInfo()
        entry.text = value.text
        entry.value = (value.groupId ~= 0 and value.groupId) or value.activityId
        entry.arg1 = (value.groupId ~= 0 and const.DUNGEON_MENU_TYPE_GROUP) or const.DUNGEON_MENU_TYPE_ACTIVITY
        entry.arg2 = nil
        entry.keepShownOnClick = 1
        entry.checked = utils.handler(self, UIDropDownMenu.onDungeonMenuChecked)
        entry.func = utils.handler(self, UIDropDownMenu.onDungeonMenuUpdated)
        entry.owner = frame
        UIDropDownMenu_AddButton(entry, level)
    end
    
    local function addResetEntry(level)
        local entry = UIDropDownMenu_CreateInfo()
        entry.text = lang["dialog.resetmenu"]
        entry.value = "reset"
        entry.arg1 = nil
        entry.arg2 = nil
        entry.isNotRadio = true
        entry.notCheckable = 1
        entry.func = utils.handler(self, UIDropDownMenu.onDungeonMenuReset)
        entry.owner = frame
        UIDropDownMenu_AddButton(entry, level)
    end
        
    local function ResolveCategoryFilters(categoryID, filters)
        -- Dungeons ONLY display recommended groups.
        if categoryID == const.CATEGORY_TYPE_DUNGEON then
            return bit.band(bit.bnot(Enum.LFGListFilter.NotRecommended), bit.bor(filters, Enum.LFGListFilter.Recommended));
        end
    
        return filters
    end

    if (level or 1) == 1 then
        local categoryId = LFGListFrame.CategorySelection.selectedCategory or const.CATEGORY_TYPE_DUNGEON    --categoryId
        local baseFilters = LFGListFrame.baseFilters or 0
        local selectedFilters = LFGListFrame.CategorySelection.selectedFilters or 0
        local filters = ResolveCategoryFilters(categoryId, selectedFilters) or Enum.LFGListFilter.Recommended
        local list = MakeCategoryMenuTable(categoryId, filters)

        addResetEntry(level)

        if #list == 1 then
            for k, v in ipairs(list[1].menuTable) do
                addEntry(v, level)
            end
        else
            for k, v in ipairs(list) do
                if v.menuTable then
                    local entry = UIDropDownMenu_CreateInfo()
                    entry.text = v.text
                    entry.menuList = v.menuTable
                    entry.hasArrow = true
                    entry.notCheckable = true
                    --entry.arg1 = const.DUNGEON_MENU_TYPE_LIST
                    --entry.notCheckable = false
                    --entry.checked = utils.handler(self, UIDropDownMenu.onDungeonMenuChecked)
                    --entry.func = utils.handler(self, UIDropDownMenu.onDungeonMenuUpdated)
                    entry.owner = frame
                    UIDropDownMenu_AddButton(entry)
                else
                    addEntry(v, level)
                end
            end
        end
    else
        for k, v in ipairs(menuList) do
            addEntry(v, level)
        end
    end
end

function UIDropDownMenu:onClassMenuChanged(frame, userInput)
    local function selectClassCount()
        local selectedCount = 0
        local selectedNames = {}
        local class = config:getValue({"class"}, utils.getCategory())

        if class then
            utils.twalk(class, function(v, k)
                if k ~= "enable" and k ~= "negate" and v then
                    selectedCount = selectedCount + 1
                    table.insert(selectedNames, LOCALIZED_CLASS_NAMES_MALE[k])
                end
            end)
        end
        return selectedCount, selectedNames
    end

    local selectedCount, selectedNames = selectClassCount()

    local showText = ""
    if selectedCount == 0 then
        showText = lang["dialog.unselect"]
    else
        showText = string.format("|cFF00FF00(%d)%s|r", selectedCount, table.concat(selectedNames, ","))
    end

    UIDropDownMenu_SetText(frame, showText)

    local parent = frame:GetParent()
    local key = parent:GetAttribute("parentKey")

    local class = config:getValue({"class"}, utils.getCategory())
    --如果取反
    if class and class.negate then
        parent.Title:SetTextColor(1, 0, 0, 1)
        parent.Title:SetText(lang["dialog." .. key:lower() .. "_off"])
    else
        parent.Title:SetTextColor(1, 1, 1, 1)
        parent.Title:SetText(lang["dialog." .. key:lower()])
    end
    
    if userInput then
        self:setChecked(frame:GetParent().Act, (selectedCount ~= 0))
    end
end

function UIDropDownMenu:onClassMenuReset(frame, arg1, arg2, checked)
    config:setValue({"class"}, {}, utils.getCategory())
    self:onClassMenuChanged(frame.owner, true)
end

function UIDropDownMenu:onClassMenuUpdated(frame, arg1, arg2, checked)
    config:setValue({"class", arg1}, checked, utils.getCategory())
    self:onClassMenuChanged(frame.owner, true)
end

function UIDropDownMenu:onClassMenuChecked(frame)
    return config:getValue({"class", frame.value}, utils.getCategory()) or false
end

function UIDropDownMenu:initClassMenu(frame, level, menuList)
    local function addEntry(index, level)
        local className, classFile, classID = GetClassInfo(index)
        local classText = RAID_CLASS_COLORS[classFile]:WrapTextInColorCode(className)
        local entry = UIDropDownMenu_CreateInfo()
        entry.text, entry.value, entry.arg1 = classText, classFile, classFile
        entry.keepShownOnClick = 1
        entry.checked = utils.handler(self, UIDropDownMenu.onClassMenuChecked)
        entry.func = utils.handler(self, UIDropDownMenu.onClassMenuUpdated)
        entry.owner = frame
        UIDropDownMenu_AddButton(entry, level)
    end
    
    local function addResetEntry(level)
        local entry = UIDropDownMenu_CreateInfo()
        entry.text = lang["dialog.resetmenu"]
        entry.value = "reset"
        entry.arg1 = nil
        entry.arg2 = nil
        entry.isNotRadio = true
        entry.notCheckable = 1
        entry.func = utils.handler(self, UIDropDownMenu.onClassMenuReset)
        entry.owner = frame
        UIDropDownMenu_AddButton(entry, level)
    end
        
    local function addNegateEntry(level)
        local entry = UIDropDownMenu_CreateInfo()
        entry.text = lang["dialog.negate"]
        entry.value = "negate"
        entry.arg1 = "negate"
        entry.keepShownOnClick = 1
        entry.checked = utils.handler(self, UIDropDownMenu.onClassMenuChecked)
        entry.func = utils.handler(self, UIDropDownMenu.onClassMenuUpdated)
        entry.owner = frame
        UIDropDownMenu_AddButton(entry, level)
    end

    addResetEntry(level)
    addNegateEntry(level)
    local classNum = GetNumClasses()
    for i = 1, classNum do
        addEntry(i, level)
    end
end

--ShowInfoMenu
function UIDropDownMenu:onShowInfoMenuChanged(frame, userInput)
    local function selectShowInfoCount()
        local selectedCount = 0
        local selectedNames = {}

        local showinfo = config:getValue({"showinfo"}, utils.getCategory())
            if showinfo then
            utils.twalk(showinfo, function(v, k)
                if k ~= "enable" and v then
                    selectedCount = selectedCount + 1
                    table.insert(selectedNames, lang["dialog." .. k:lower()])
                end
            end)
        end

        return selectedCount, selectedNames
    end

    local selectedCount, selectedNames = selectShowInfoCount()

    local showText = ""
    if selectedCount == 0 then
        showText = lang["dialog.unselect"]
    else
        showText = string.format("|cFF00FF00(%d)%s|r", selectedCount, table.concat(selectedNames, ","))
    end

    UIDropDownMenu_SetText(frame, showText)

    if userInput then
        self:setChecked(frame:GetParent().Act, (selectedCount ~= 0))
    end
end

function UIDropDownMenu:onShowInfoMenuReset(frame, arg1, arg2, checked)
    config:setValue({"showinfo"}, {}, utils.getCategory())
    self:onShowInfoMenuChanged(frame.owner, true)
end

function UIDropDownMenu:onShowInfoMenuUpdated(frame, arg1, arg2, checked)
    config:setValue({"showinfo", arg1}, checked, utils.getCategory())
    if(arg1 == "showclassinfo" and checked == true) then
        config:setValue({"showinfo", "showclassbar"}, false, utils.getCategory())
    elseif(arg1 == "showclassbar" and checked == true) then
        config:setValue({"showinfo", "showclassinfo"}, false, utils.getCategory())
    end
    self:onShowInfoMenuChanged(frame.owner, true)
end

function UIDropDownMenu:onShowInfoMenuChecked(frame)
    return config:getValue({"showinfo", frame.value}, utils.getCategory())
end

function UIDropDownMenu:initShowInfoMenu(frame, level, menuList)      
    local function addResetEntry(level)
        local entry = UIDropDownMenu_CreateInfo()
        entry.text = lang["dialog.resetmenu"]
        entry.value = "reset"
        entry.arg1 = nil
        entry.arg2 = nil
        entry.isNotRadio = true
        entry.notCheckable = 1
        entry.func = utils.handler(self, UIDropDownMenu.onShowInfoMenuReset)
        entry.owner = frame
        UIDropDownMenu_AddButton(entry, level)
    end
        
    addResetEntry(level)

    for k, v in pairs(showInfo) do
        local categoryId = utils.getCategory()
        if utils.tindexof(v, categoryId) or #v == 0 then
            local entry = UIDropDownMenu_CreateInfo()
            entry.text, entry.value, entry.arg1 = lang["dialog." .. k], k, k
            entry.keepShownOnClick = 1
            entry.checked = utils.handler(self, UIDropDownMenu.onShowInfoMenuChecked)
            entry.func = utils.handler(self, UIDropDownMenu.onShowInfoMenuUpdated)
            entry.owner = frame
            UIDropDownMenu_AddButton(entry)
        end
    end
end

--ShortcutOptionMenu
function UIDropDownMenu:onShortcutOptionMenuChanged(frame, userInput)
    local function selectShortcutOptionCount()
        local selectedCount = 0
        local selectedNames = {}

        local shortcutoption = config:getValue({"shortcutoption"}, utils.getCategory())
        if shortcutoption then
            utils.twalk(shortcutoption, function(v, k)
                if k ~= "enable" and v then
                    selectedCount = selectedCount + 1
                    table.insert(selectedNames, lang["dialog." .. k:lower()])
                end
            end)
        end

        return selectedCount, selectedNames
    end

    local selectedCount, selectedNames = selectShortcutOptionCount()

    local showText = ""
    if selectedCount == 0 then
        showText = lang["dialog.unselect"]
    else
        showText = string.format("|cFF00FF00(%d)%s|r", selectedCount, table.concat(selectedNames, ","))
    end

    UIDropDownMenu_SetText(frame, showText)

    if userInput then
        self:setChecked(frame:GetParent().Act, (selectedCount ~= 0))
    end
end

--ShortcutOption
function UIDropDownMenu:onShortcutOptionMenuReset(frame, arg1, arg2, checked)
    config:setValue({"shortcutoption"}, {}, utils.getCategory())
    self:onShortcutOptionMenuChanged(frame.owner, true)
end

function UIDropDownMenu:onShortcutOptionMenuUpdated(frame, arg1, arg2, checked)
    config:setValue({"shortcutoption", arg1}, checked, utils.getCategory())
    self:onShortcutOptionMenuChanged(frame.owner, true)
end

function UIDropDownMenu:onShortcutOptionMenuChecked(frame)
    return config:getValue({"shortcutoption", frame.value}, utils.getCategory())
end

function UIDropDownMenu:initShortcutOptionMenu(frame, level, menuList)      
    local function addResetEntry(level)
        local entry = UIDropDownMenu_CreateInfo()
        entry.text = lang["dialog.resetmenu"]
        entry.value = "reset"
        entry.arg1 = nil
        entry.arg2 = nil
        entry.isNotRadio = true
        entry.notCheckable = 1
        entry.func = utils.handler(self, UIDropDownMenu.onShortcutOptionMenuReset)
        entry.owner = frame
        UIDropDownMenu_AddButton(entry, level)
    end
        
    addResetEntry(level)

    for k, v in pairs(shortcutoption) do
        local entry = UIDropDownMenu_CreateInfo()
        entry.text, entry.value, entry.arg1 = lang["dialog." .. v], v, v
        entry.keepShownOnClick = 1
        entry.checked = utils.handler(self, UIDropDownMenu.onShortcutOptionMenuChecked)
        entry.func = utils.handler(self, UIDropDownMenu.onShortcutOptionMenuUpdated)
        entry.owner = frame
        UIDropDownMenu_AddButton(entry)
    end
end

function UIDropDownMenu:genericField(parent, name)
    UIDropDownMenu.super:genericField(parent, name)

    if not parent then
        return
    end

    if parent.DropDown then
        UIDropDownMenu_Initialize(parent.DropDown, utils.handler(self, self["init" .. name .. "Menu"] or nil))
        UIDropDownMenu_SetWidth(parent.DropDown, 105)
        UIDropDownMenu_JustifyText(parent.DropDown, "LEFT")
        parent.DropDown:SetPoint("LEFT", parent, "TOPRIGHT", -134, 0)
        event:exec("SETUP_SKIN", parent.DropDown, "UIDropDownMenu")
    end
end

function UIDropDownMenu:setup(dialog)
    if not dialog then
        return
    end

    for k, v in pairs(dropdownFields) do
        local parent = dialog[v]
        if parent then
            local cfg = config:getValue({v:lower()}, utils.getCategory()) or nil
            local enable = cfg and cfg.enable or false
            
            if parent.DropDown then
                local func = self["on".. v .."MenuChanged"]
                if func then
                    func(self, parent.DropDown, false)
                end
            end

            parent.Act:SetChecked(enable)
        end
    end
end

function UIDropDownMenu:_setSkin(frame)
    local skins = utils.getElvUISkins()
    if not skins then
        return
    end

    skin:HandleDropDownBox(frame)
end

function UIDropDownMenu:setSkin(dialog)
    if not dialog then
        return
    end

    utils.twalk(dropdownFields, function(v, k)
        local parent = dialog[v]
        if parent then
            self:_setSkin(parent.DropDown)
        end
    end)
end

function UIDropDownMenu:initialize(dialog)
    if not dialog then
        return
    end
    
    for k, v in pairs(dropdownFields) do
        local parent = dialog[v]
        if parent then
            self:genericField(parent, v)
        end
    end
end

dialog:registerHandlers(UIDropDownMenu)