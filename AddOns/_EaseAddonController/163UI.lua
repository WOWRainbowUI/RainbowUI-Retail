local floor,ceil,format,tostring=floor,ceil,format,tostring
local pairs,ipairs,next,wipe,assert,type,tinsert,select,tremove,GetTime = pairs,ipairs,next,wipe,assert,type,tinsert,select,tremove,GetTime
local n2s,safecall,copy,tinsertdata,tremovedata = n2s,safecall,copy,tinsertdata,tremovedata
local _, U1 = ...
local L = U1.L;
U1.PINYIN = U1.PINYIN or {}

local addonInfo = {}    --- all addon infos
local tagInfo = {}      --- all tag infos, { text = "", num = N }
local currAddons = {}   --- current addons in selected tag.
local currTags = {}     --- current tags listed in left
local additionalFilter  --- enabled or disabled filter
local reloadList = {}   --- addon list shown in reload button.
local initComplete      --- all addons include those load=='LATER' are loaded
local AceDBs = {}
local loadedNormalAddons = {}
--U1.variableLoaded     --- if VARIABLES_LOADED event is fired.
--U1.playerLogin        --- if PLAYER_LOGIN event is fired

CoreAddEvent("CURRENT_ADDONS_UPDATED")
CoreAddEvent("CURRENT_TAGS_UPDATED")
CoreAddEvent("ADDON_SELECTED")
CoreAddEvent("DB_LOADED")
CoreAddEvent("INIT_COMPLETED")

BINDING_NAME_EAC_RELOADUI = RELOADUI

local defaultDB = {
    selectedTag = UI163_USER_MODE and "ALL" or "NETEASE",
    showOrigin = nil,               -- show addon directory name
    addons = {},                    -- enable status for each addon
    configs = {},                   -- configs for each addon
}
local db;
--U1DB = nil local db = defaultDB;

local pcall = safecall;

_G["U1"] = U1
U1.addonInfo = addonInfo
U1.tagInfo = tagInfo
U1.currTags = currTags;
U1.currAddons = currAddons;
gai = function(...) return U1GetAddonInfo(...) end

--[[------------------------------------------------------------
local functions
---------------------------------------------------------------]]
--- multiple dependencies, remove known AddonPacks
local knownAddonPacks = { "elvui", "duowan", "bigfoot", "mogu", "ace2", "ace3", "fish!!!" }
local function getInitialAddonInfo()
    local x = strchar(33) x={x,x,x,163,"ui",x,x,x} x=table.concat(x); GetNumAddOns = strlower(_)==x  --插件名称保护
    for i = 1, C_AddOns.GetNumAddOns() do
        local name, title, notes, _, reason = C_AddOns.GetAddOnInfo(i)
        title = title:gsub("%|cff880303%[网易有爱%]%|r ", "")

        local realDeps = { C_AddOns.GetAddOnDependencies(i) }
        local realOptDeps = { C_AddOns.GetAddOnOptionalDependencies(i) }
        for k = 1, #realDeps do realDeps[k] = realDeps[k]:lower() end
        for k = 1, #realOptDeps do realOptDeps[k] = realOptDeps[k]:lower() end

        --- copy a deps is mainly to calc parent, and the table is used later as info.optdeps
        --- there is no deps in raw_infos
        local deps = copy(realDeps)
        for _, known in ipairs(knownAddonPacks) do
            tremovedata(deps, known:lower())
        end
        -- GarrisonMissionManager depends on Blizzard, will got an uninstalled parent
        for j=#deps, 1, -1 do
            if (deps[j]:find("^blizzard_") and select(6, C_AddOns.GetAddOnInfo(deps[j]))=="SECURE") then
                tremove(deps, j);
            end
        end

        addonInfo[name:lower()] = {
            name = name,
            title = title or name,
            author = C_AddOns.GetAddOnMetadata(i, "Author"),
            modifier = C_AddOns.GetAddOnMetadata(i, "X-Modifier"),
            parent = deps[1] and deps[1]:lower(),
            realDeps = realDeps,
            realOptDeps = realOptDeps,
            desc = notes,
			icon = C_AddOns.GetAddOnMetadata(i, "IconTexture"),

            installed = i,
            realLOD = C_AddOns.IsAddOnLoadOnDemand(i),
            lod = C_AddOns.IsAddOnLoadOnDemand(i), --- may be override
            vendor = C_AddOns.GetAddOnMetadata(i, "X-Vendor") == "NetEase",
            version = C_AddOns.GetAddOnMetadata(i, "Version"),
            xcategories = UI163_USE_X_CATEGORIES and C_AddOns.GetAddOnMetadata(i, "X-Category"),
            originEnabled = C_AddOns.GetAddOnEnableState(i, U1PlayerName)>=2,
        }

        --- transform multiple dependencies (which can't show in control panel) to optional dependencies
        if (#deps > 1) then
            if DEBUG_MODE then print("MultiDependencies: " .. name .. " depends on " .. table.concat(deps, ",")) end
            table.remove(deps, 1)
            addonInfo[name:lower()].optdeps = deps
        end
    end

    -- clean up realDeps and realOptDeps to save memory
    for k, v in pairs(addonInfo) do
        for i = #v.realDeps,    1, -1 do if not addonInfo[v.realDeps[i]]    then tremove(v.realDeps, i)    end end
        for i = #v.realOptDeps, 1, -1 do if not addonInfo[v.realOptDeps[i]] then tremove(v.realOptDeps, i) end end
        if #v.realDeps == 0    then v.realDeps = nil    end
        if #v.realOptDeps == 0 then v.realOptDeps = nil end
        if v.realOptDeps then
            v.optdeps = v.optdeps or {}
            for _, dep in ipairs(v.realOptDeps) do tinsert(v.optdeps, dep) end
        end
    end

    for _, v in ipairs(U1.removedAddOns or _empty_table) do
        local info = addonInfo[v:lower()]
        if info and info.vendor then
            --DisableAddOn(v);
            --info.originEnabled = nil;
        end
    end
end

function U1IsInitComplete()
    return initComplete and IsLoggedIn();
end

function U1EncodeNIL(value)
    return (value==nil) and "_NIL" or value
end
function U1DecodeNIL(value)
    if value == "_NIL" then return nil end
    return value;
end

function U1LoadDBDefault(cfg)
    if cfg.default then
        if type(cfg.default) == "function" then
            return true, cfg.default()
        else
            return true, cfg.default
        end
    else
        return false, nil
    end
end

function U1LoadDBValue(cfg)
    local db = cfg.global and U1DBG or U1DB
    local v = db.configs[cfg._path]
    if(v == nil) then
        local has, default = U1LoadDBDefault(cfg)
        if has then
            if type(default) == "table" then
                v = copy(default)
            else
                v = default
            end
        end
    end
    return U1DecodeNIL(v)
end

--- save configs to DB.
-- called by 1.deepSave(getvalue) when LOGOUT; 2.OnShow(getvalue) in Controls; 3.RegularSave
-- config value same as default won't be saved.
-- config's getvalue() will be called when 1.LOGOUT and 2.OnShow
function U1SaveDBValue(cfg, value)
    if U1.PROFILE_CHANGED then return end
    local old = U1EncodeNIL(U1LoadDBValue(cfg))
    local has_default, default = U1LoadDBDefault(cfg)
    local db = cfg.global and U1DBG or U1DB
    if type(value) == "table" then
        if has_default and type(default) == "table" and tcovers(value, default) and tcovers(default, value) then
            db.configs[cfg._path] = nil
        else
            db.configs[cfg._path] = value
        end
    elseif has_default and value == default then
        db.configs[cfg._path] = nil
    else
        db.configs[cfg._path] = U1EncodeNIL(value);
    end
    return old
end

--- call a cfg's callback. with forceValue[optional] or currentValue
function U1CfgCallBack(cfg, forceValue, loading)
    local value = forceValue;
    if value == nil then value = U1LoadDBValue(cfg); end
    if cfg.visible ~= false and cfg.callback then
        pcall(cfg.callback, cfg, value, loading);
    end
end

--- change a cfg to value and call sub
function U1ChangeCfg(path, value)
    local _, cfg = U1GetCfgValue(path)
    if(cfg)then
        U1SaveDBValue(cfg, value)
        U1CfgCallBack(cfg)
    end
end

--- call a config's child config, if parentEnabled == false, subs are all false.
function U1CfgCallSub(cfg, sub, parentEnabled)
    U1CfgCallBack(U1CfgFindChild(cfg, sub), not not parentEnabled and nil);
end

function U1CfgFindChild(cfg, var)
    local children = cfg;
    if type(cfg) == "string" then --AddonPage top config
        children = U1GetPage(cfg);
    end
    if children then
        for _, sub in ipairs(children) do
            if(sub.var==var or sub.id==var) then return sub end
        end
        for _, sub in ipairs(children) do
            if sub.type == "text" then
                local textsub = U1CfgFindChild(sub, var)
                if textsub then return textsub end
            end
        end
    end
end

local function U1GetCfgValueDeep(cfg, first, ...)
    cfg = U1CfgFindChild(cfg, first)
    if cfg then
        if select('#', ...) == 0 then
            return cfg
        else
            return U1GetCfgValueDeep(cfg, ...)
        end
    end
end

--- U1GetCfgValue("addon", "level1/config") or U1GetCfgValue("addon/level1/config")
function U1GetCfgValue(addon, path, safe)
    if not path then
        local pos = addon:find("/")
        path = addon:sub(pos + 1)
        addon = addon:sub(1, pos - 1)
    end
    local cfg = U1GetCfgValueDeep(addon:lower(), strsplit("/", path));
    if safe and not cfg then return end
    assert(cfg, format("Error, can't find config [%s] of addon [%s].", path, addon));
    return U1LoadDBValue(cfg), cfg;
end

--- show config values, only for debug purpose.
function U1ShowCfg(addon, pattern)
    print(strrep("=",30))
    addon = addon:lower()
    for k,v in pairs(db.configs) do
        if strsplit("/", k):find(addon) and (not pattern or k:lower():find(pattern:lower())) then print(format("[[%s]] = '|cff00ff00%s|r'", k, tostring(U1DecodeNIL(v)))) end
    end
end

function U1CfgResetAddOn(addon)
    for k,v in pairs(db.configs) do
        if strsplit("/", k) == addon:lower() then
            db.configs[k] = nil
        end
    end
    ReloadUI()
end

function U1RegisterTag(v)
    local tag = tagInfo[v];
    if not tag then
        local tagDef = U1.TAGS[v];
        tag = {
            num = 0,
            text = type(tagDef)=="table" and tagDef.text or _G["TAG_"..v] or v,
            order = type(tagDef)=="table" and tagDef.order or nil,
        }
        tagInfo[v] = tag;
    end
    tag.num = tag.num + 1;
end

function U1SearchPinyin(data, pattern)
    return data:find(pattern) or U1.PINYIN[data] and (U1.PINYIN[data][1]:find(pattern) or U1.PINYIN[data][2]:find(pattern))
end

------------------------------------------------------------
-- Tags related.
------------------------------------------------------------
--- Update tags, called when addon loaded
--@param onlyAffectLoaded   only update when current filter is loaded
--@param addonName          only update when current selected is <addonName>
function U1UpdateTags(onlyAffectLoaded, addonName)
    -- process tags with filters
    for k, v in pairs(U1.TAGS) do
        if (type(v)=="table" and v.filter) then
            if not tagInfo[k] then U1RegisterTag(k) end
            tagInfo[k].num = 0;
            tagInfo[k].caption = nil;
            for name, info in pairs(addonInfo) do
                if (info.parent == nil and not info.hide) then
                    info.tags = info.tags or {};
                    info.tags[k] = v.filter(name, info);
                    if(info.tags[k])then
                        U1RegisterTag(k);
                    end
                end
            end
        end
    end

    wipe(currTags);
    for k, v in pairs(tagInfo) do
        local tagDef = U1.TAGS[k]
        local hide = type(tagDef)=='table' and tagDef.hide
        if v.num > 0 and not hide then
            tinsert(currTags, k);
        end
    end

    if(not onlyAffectLoaded) then
        U1SelectTag(db.selectedTag, 1);
    else
        U1SortTag()
        CoreFireEvent("CURRENT_ADDONS_UPDATED") -- update number, buttons
    end

    -- re-select addon
    if(not addonName or addonName==db.selectedAddon) then
        if(db.selectedAddon)then U1SelectAddon(db.selectedAddon) end;
    end
end

function U1AddonHasTag(name, tag)
    name = name:lower();
    local info = addonInfo[name]
    return info.tags and info.tags[tag];
end

function U1GetNumTags()
    return #currTags;
end

local tagComparator = function(v1, v2)
    local o1 = tagInfo[v1].order or math.huge;
    local o2 = tagInfo[v2].order or math.huge;
    if o1 < 0 and o2 > 0 then
        return false
    elseif o1 > 0 and o2 < 0 then
        return true
    elseif (o1 == o2) then
        return v1 < v2
    else
        return o1 < o2;
    end
end

function U1SortTag()
    table.sort(currTags, tagComparator);
    CoreFireEvent("CURRENT_TAGS_UPDATED");
end

function U1SearchTag(text)
    local pattern = nocase(text);
    wipe(currTags);
    for k, v in pairs(tagInfo) do
        if (v.num > 0 and U1SearchPinyin(v.text, pattern)) then
            tinsert(currTags, k);
        end
    end
    U1SortTag();
end

function U1SelectTag(tag, keepSelectedAddon)
    db.selectedTag = tag;
    U1SelectAddon(keepSelectedAddon and db.selectedAddon or nil);
    U1UpdateTags("LOADED", keepSelectedAddon and db.selectedAddon or nil);
    U1UpdateCurrentAddOns();
    U1SortTag();
end

function U1GetSelectedTag()
    return db.selectedTag;
end

function U1GetTagInfoByName(name)
    local info = tagInfo[name];
    if not info then
        name = UI163_USER_MODE and "ALL" or "NETEASE"
        info = tagInfo[name]
    end
    info.caption = info.caption or info.text .. ((name=="LOADED" or name=="NLOADED") and "(" .. info.num .. ")" or "");
    local desc = _G["TAG_DESC_" .. name] or ""
    return name, info.num, info.caption, info.order and true, desc;
end

--- @return name, num, caption, special;
function U1GetTagInfo(index)
    local name = currTags[index];
    return U1GetTagInfoByName(name)
end

function U1SetAdditionalFilter(tag)
    additionalFilter = tag
    U1UpdateCurrentAddOns()
end

function U1GetAdditionalFilter()
    return additionalFilter
end

--[[------------------------------------------------------------
Addon Controller API
---------------------------------------------------------------]]
local order = 1;
U1.parentTags = {}; --tag names used by children addons
function U1RegisterAddon(name, infoReg)
    local infoRaw = addonInfo[name:lower()];
    if not infoRaw then U1.parentTags[name:lower()] = infoReg.tags return end

    infoReg.name = name; -- save name with case.
    infoReg.order = order;
    order = order + 1;
    if infoReg.registered ~= false then infoReg.registered = true end
    infoReg.ldbIcon = infoReg.ldbIcon == 1 and infoReg.icon or infoReg.ldbIcon;
    name = name:lower();

    addonInfo[name] = infoReg;

    -- copy raw addonInfo to registered table
    for k, v in pairs(infoRaw) do
        if k=="optdeps" then
            --合并两个optdeps
            if infoReg.optdeps then
                for _, opt in ipairs(infoReg.optdeps) do
                    if addonInfo[opt:lower()] then
                        tinsertdata(v, opt:lower())
                    end
                end
            end
            infoReg[k] = v
        else
            infoReg[k] = infoReg[k] or v
        end
    end

    wipe(infoRaw)

    if infoReg.deps then
        for i=1, #infoReg.deps do infoReg.deps[i] = infoReg.deps[i]:lower() end
    end

    -- prop:children
    if (infoReg.children) then
        for k, v in pairs(addonInfo) do
            if ( k~= name and (not v.registered or not v.parent)) then
                for _, pattern in ipairs(infoReg.children) do
                    if (strfind(strlower(k), strlower(pattern))) then
                        v.parent = name;
                        break;
                    end
                end
            end
        end
    end

    infoReg.parent = infoReg.parent and infoReg.parent~="" and infoReg.parent~=0 and infoReg.parent:lower() or nil
end

function U1ChangeTags(name, tags, add)
    local info = U1GetAddonInfo(name)
    if info and (UI163_USER_MODE or info.registered) then
        if not add then
            for _, v in ipairs(info.tags or _empty_table) do
                if v == "CLASS" then info._classAddon = nil end
                info.tags[v] = nil;
                tagInfo[v].num = tagInfo[v].num - 1;
            end
            info.tags = {};
        end
        for _, v in ipairs(tags) do
            if v == "CLASS" then info._classAddon = true end
            info.tags[v] = true;
            U1RegisterTag(v)
        end
    end
end

function U1GetPage(name)
    local info = U1GetAddonInfo(name);
    if info and #info > 0 then return info end
end

function U1GetAddonInfo(name)
    name = name:lower();
    return addonInfo[name]
end

function U1IterateAllAddons()
    return pairs(addonInfo);
end

function U1IsAddonInstalled(name)
    name = name:lower();
    local info = addonInfo[name]
    return info and info.installed and true
end

function U1IsAddonRegistered(name)
    name = name:lower();
    local info = addonInfo[name]
    return info and info.registered, info and info.vendor
end

function U1GetAddonModsAndMemory(addonName)
    local subNum, subLoaded, mem, subMem = 0, 0, 0, 0
    local info = U1GetAddonInfo(addonName);
    if C_AddOns.IsAddOnLoaded(addonName) then
        mem = GetAddOnMemoryUsage(addonName);
        for subName, subInfo in U1IterateAllAddons() do
            if subInfo.parent == addonName then --and not subInfo.hide then
                subNum = subNum + 1;
                --这里可以用C_AddOns.IsAddOnLoaded或者U1IsAddonEnabled，还能分别用不同的条件
                if (U1IsAddonEnabled(subName))then
                    subLoaded = subLoaded + 1;
                    subMem = subMem + GetAddOnMemoryUsage(subName);
                end
            end
        end
    end
    return subNum, subLoaded, mem+subMem
end

local comparatorAddonMemory = function(v1, v2)
    local _, _, mem1 = U1GetAddonModsAndMemory(v1);
    local _, _, mem2 = U1GetAddonModsAndMemory(v2);
    if(mem2==mem1)then
        return v1<v2;
    else
        return mem2<mem1;
    end
end

local comparatorAddonTitle = function(v1, v2)
    local t1 = U1GetAddonTitle(v1);
    t1 = U1.PINYIN[t1] and U1.PINYIN[t1][1] or t1;
    local t2 = U1GetAddonTitle(v2);
    t2 = U1.PINYIN[t2] and U1.PINYIN[t2][1] or t2;
    return t1 < t2;
end

function U1SortAddons()
    if U1DB.sortByName then
        table.sort(currAddons, comparatorAddonTitle);
    else
        table.sort(currAddons, comparatorAddonMemory)
    end
    CoreFireEvent("CURRENT_ADDONS_UPDATED")
end

function U1UpdateCurrentAddOns(searching)
    wipe(currAddons);
    local selectedTag = db.selectedTag
    local addFilter = additionalFilter and U1.TAGS[additionalFilter] and U1.TAGS[additionalFilter].filter

    for k, v in pairs(addonInfo) do
        if(not v.filtered and v.parent==nil and not v.hide)
                and (searching or (U1AddonHasTag(k, selectedTag) and (not addFilter or addFilter(k)))) then
            tinsert(currAddons, k);
        end
    end

    U1SortAddons()
end

function U1GetNumCurrentAddOns()
    return #currAddons;
end

--- @return name, info
function U1GetCurrentAddOnInfo(i)
    local name = currAddons[i]
    return name, addonInfo[name];
end

function U1SelectAddon(name, noevent)
    name = name and name:lower()
    if(name and not U1GetAddonInfo(name)) then name = nil end
    db.selectedAddon = name;
    if not noevent then CoreFireEvent("ADDON_SELECTED", name); end
end

function U1GetSelectedAddon()
    return db.selectedAddon;
end

local function deepSearch(cfg, pattern)
    if cfg.text then
        if(cfg.text and cfg.text:find(pattern)) then return 1 end
    end
    if #cfg > 0 then
        for _, v in ipairs(cfg) do
            if deepSearch(v, pattern) then return 1 end
        end
    end
end

local function searchAddonPage(addonName, pattern)
    local page = U1GetPage(addonName);
    local info = U1GetAddonInfo(addonName);
    if info.hide then
        return false
    end
    if(addonName:find(pattern) or (info.title and U1SearchPinyin(info.title , pattern))) then
        return true;
    end
    if page then
        for _, cfg in ipairs(page) do
            if deepSearch(cfg, pattern) then
                return true;
            end
        end
    end
end

local function searchAddonDesc(addonName, addonInfo, pattern)
    if addonInfo.desc then
        if type(addonInfo.desc)=="table" then
            for _, s in ipairs(addonInfo.desc) do
                if s:find(pattern) then return true end
            end
        else
            if addonInfo.desc:find(pattern) then return true end
        end
    end
    do return end --- no need search subs desc
    for subName, subInfo in U1IterateAllAddons() do
        if subInfo.parent == addonName then
            if searchAddonDesc(subName, subInfo, pattern) then
                return true
            end
        end
    end
end

function U1SearchAddon(text)
    if db then db.lastSearch = text~="" and text or nil end
    local pattern = nocase(text);
    for k, v in U1IterateAllAddons() do
        if k:find(pattern) or (v.title and U1SearchPinyin(v.title, pattern)) then
            v.filtered = nil;
        else
            v.filtered = 1;
            -- search text in configs
            if(searchAddonPage(k, pattern)) then
                v.filtered = nil;
            else
                for subName, subInfo in U1IterateAllAddons() do
                    if subInfo.parent == k then
                        if(searchAddonPage(subName, pattern)) then
                            v.filtered = nil;
                            break;
                        end
                    end
                end
            end
            if v.filtered then
                if searchAddonDesc(k, v, pattern) then
                    v.filtered = nil
                end
            end
        end
    end
    U1UpdateCurrentAddOns(text~="");
end

local outputOnce = {}
function U1OutputAddonState(text, addon, force)
    if force or (DEBUG_MODE or initComplete and not outputOnce[addon]) then
        if not U1GetAddonInfo(addon).hide and not U1GetAddonInfo(addon).parent then
            U1Message(format(text, format(L["AddOn |cffffd100%s|r"], U1GetAddonTitle(addon))));
        end
        outputOnce[addon] = 1;
    end
end
function U1OutputAddonLoaded(name, loaded, reason)
    if(loaded)then
        U1OutputAddonState(L["%s loaded"], name);
    else
        U1OutputAddonState(L["%s load failed, reason: "]..(reason and _G["U1REASON_"..reason] or reason or L["unknown"]), name);
    end
end

function U1GetReloadList()
    return reloadList;
end

--- add name to reload list
function U1ChangeReloadList(name, isCfg, oldValue, newValue)
    if not isCfg then
        reloadList[name .. "/__disable"] = oldValue
    else
        if (reloadList[name]) then
            -- value restored, removed from list.
            if (type(newValue) ~= "table" and reloadList[name] == newValue) then
                reloadList[name] = nil
            end
        else
            reloadList[name] = oldValue
        end
    end
end

function U1IsAddonEnabled(name)
    name = name:lower()
    local info = U1GetAddonInfo(name);
    if not info then return nil end
    local state = db and db.addons[name];
    if (not state) then return info.originEnabled end
    return state == 1 and (info.installed or info.protected)
end

--[[------------------------------------------------------------
API used by UI
---------------------------------------------------------------]]
function U1SetShowOrigin(enabled)
    db.showOrigin = enabled;
end

function U1GetShowOrigin()
    return db and db.showOrigin;
end

function U1GetAddonTitle(name)
    local info = U1GetAddonInfo(name);
    local originName = info.name
	-- 取得插件中文名稱，不包含分類
	local title = info.title:match("]|r.-$");
	if title then
		-- 去除 "-主程式"
		title = title:gsub("-主程式","");
		title = title:sub(5, title:len());
	else 
		title = info.title;
	end
	
    return U1GetShowOrigin() and originName or uncolor(title or originName)
end

--[[------------------------------------------------------------
U1LoadAddOn and Event Simulation
---------------------------------------------------------------]]
-- event need to capture in LoadAddOn
local eventCaptured = {
    VARIABLES_LOADED = {},
    PLAYER_LOGIN = {},
    PLAYER_ENTERING_WORLD = {},
    SPELLS_CHANGED = {},
    --PLAYER_REGEN_DISABLED = {}, -- reason: 1. Can't simulate InCombatLockdown() == nil 2. I assume no addon use this as start point.
    PLAYER_REGEN_ENABLED = {},
    GROUP_ROSTER_UPDATE = {},
    PLAYER_ALIVE = {},
    PLAYER_DEAD = {},
    WORLD_MAP_UPDATE = {},
    QUEST_LOG_UPDATE = {},
    UPDATE_FACTION = {},
    LOADING_SCREEN_DISABLED = {},
}

U1.captureEvents = eventCaptured

-- search RegisterEvent in file Secure*.*
local secureEvents = {
    GROUP_ROSTER_UPDATE = 1,
    UNIT_AURA = 1,
    UNIT_NAME_UPDATE = 1,
    UNIT_PET = 1,
}

local capturing;            --- just a flag
local bundleLoading;        --- mark state to prevent AceAddon from responsing to ADDON_LOADED
local bundleSimNames = {};  --- save addons loaded by U1LoadAddon, to call configs.
function U1IsBundleLoading() return bundleLoading end

local captureHook = function(frame, event, special)
    if not capturing then return end
    if frame:GetName() == "AceEvent30Frame" then return end --- AceEvent is special, see captureHookAceEvent

    -- SecureGroupHeaders, actually secureEvents is no longer needed now.
    if secureEvents[event] and select(2, frame:IsProtected()) then return end

    if(eventCaptured[event])then
        if not tContains(eventCaptured[event], frame) then
            tinsert(eventCaptured[event], frame);
        end
    end
end

--- deal with AceEvent
-- copied from CallbackHandler, no extra arg!
local captureHookAceEvent = function(self, eventname, method, ... --[[actually just a single arg]])
    if(capturing and type(eventname)=="string" and eventCaptured[eventname]) then
        local RegisterName = "RegisterEvent"

        method = method or eventname

        if type(method) ~= "string" and type(method) ~= "function" then
            error("Usage: "..RegisterName.."(\"eventname\", \"methodname\"): 'methodname' - string or function expected.", 2)
        end

        local regfunc

        if type(method) == "string" then
            -- self["method"] calling style
            if type(self) ~= "table" then
                error("Usage: "..RegisterName.."(\"eventname\", \"methodname\"): self was not a table?", 2)
            elseif self==target then
                error("Usage: "..RegisterName.."(\"eventname\", \"methodname\"): do not use Library:"..RegisterName.."(), use your own 'self'", 2)
            elseif type(self[method]) ~= "function" then
                error("Usage: "..RegisterName.."(\"eventname\", \"methodname\"): 'methodname' - method '"..tostring(method).."' not found on self.", 2)
            end

            if select("#",...)>=1 then  -- this is not the same as testing for arg==nil!
                local arg=select(1,...)
                regfunc = function(...) if self[method] then self[method](self,arg,...) elseif DEBUG_MODE then print("ERROR", capturing, method) end end
            else
                regfunc = function(...) if self[method] then self[method](self,...) elseif DEBUG_MODE then print("ERROR", capturing, method) end end
            end
        else
            -- function ref with self=object or self="addonId" or self=thread
            if type(self)~="table" and type(self)~="string" and type(self)~="thread" then
                error("Usage: "..RegisterName.."(self or \"addonId\", eventname, method): 'self or addonId': table or string or thread expected.", 2)
            end

            if select("#",...)>=1 then  -- this is not the same as testing for arg==nil!
                local arg=select(1,...)
                regfunc = function(...) method(arg,...) end
            else
                regfunc = method
            end
        end

        --print("captured", self, eventname, regfunc);
        -- modification
        for i, v in ipairs(eventCaptured[eventname]) do
            if v[1] and v[1]==self then v[2]=regfunc return end
        end
        tinsert(eventCaptured[eventname], {self, regfunc})
    end
end

--- supported frameTypes (with RegisterEvent)
local frameTypes = { "Frame", "GameTooltip", "ScrollFrame", "Cooldown", "StatusBar", "MessageFrame", "ScrollingMessageFrame", "Button", "Slider", "CheckButton", "EditBox", }
                   -- these also have RegisterEvent, but ignored by us. "SimpleHTML", "QuestPOIFrame", "ColorSelect", "ArchaeologyDigSiteFrame", "MovieFrame", "Model", "DressUpModel", "TabardModel", "PlayerModel",

-- only RegisterEvent is needed to hook, UnregisterEvent can be test by IsEventRegistered
local metaHooked = {}
for _, v in ipairs(frameTypes) do
    local f = CreateFrame(v) f:Hide()
    local meta = getmetatable(f).__index
    if (meta and meta.RegisterEvent and metaHooked[meta] == nil) then
        metaHooked[meta] = 1
        hooksecurefunc(meta, "RegisterEvent", captureHook);
    end
end
wipe(metaHooked) metaHooked = nil

local function startCapturing()
    bundleLoading = 1
    wipe(bundleSimNames)
    for k, v in pairs(eventCaptured) do wipe(v); end

    -- AceEvent related, the first loaded AceEvent-3.0 must be the newest, so we modify our bundled AceEvent-3.0's version number
    local aceevent = LibStub:GetLibrary("AceEvent-3.0", true)
    if aceevent and not aceevent.origin then
        aceevent.origin = aceevent.RegisterEvent;
        aceevent.RegisterEvent = function(self, event, method, ...)
            aceevent.origin(self, event, method, ...)
            captureHookAceEvent(self, event, method, ...)
        end
    end
end

local function stopCapturing()
    startCapturing()
    bundleLoading = nil
end

function U1SimulateEvent(event, ...)
    if not eventCaptured[event] then return end
    capturing = "SIM";
    if event == "PLAYER_LOGIN" and AceAddon30Frame then AceAddon30Frame:GetScript("OnEvent")(AceAddon30Frame, event) end

    for i=1,#eventCaptured[event] do
        local v=eventCaptured[event][i]
        -- v with 2 values is AceEvent
        if #v==2 then
            --print("SIM ACE ", v[1], event, ...)
            pcall(v[2], event, ...); --regfunc already en-closure self
        else
            if v and v.GetScript and v:GetScript("OnEvent") and v.IsEventRegistered and (event=="PLAYER_LOGIN" or v:IsEventRegistered(event)) then
                --print("SIM ", event, v:GetName() or v, ...)
                pcall(v:GetScript("OnEvent"), v, event, ...)
                -- prevent VARIABLES_LOADED fires after PLAYER_ENTERING_WORLD
                if event=="VARIABLES_LOADED" or event=="PLAYER_LOGIN" then v:UnregisterEvent(event) end
            end
        end
    end
    capturing = nil;
end

local function deepLoad(cfg)
    if(cfg.var)then
        U1CfgCallBack(cfg, nil, true)
        if( #cfg > 0 and (cfg.type~="checkbox" or U1LoadDBValue(cfg)) )then
            for i=1,#cfg do
                deepLoad(cfg[i]);
            end
        end
    elseif(cfg.type=="text")then
        for i=1,#cfg do
            deepLoad(cfg[i]);
        end
    end
end

local optionsAfterVarInfos, optionsAfterLoginInfos ={},{}
local function simEventsAndLoadCfgs()

    for i = 1, #bundleSimNames do
        local name = bundleSimNames[i]
        local page = U1GetPage(name);
        local info = U1GetAddonInfo(name);
        if page then
            if info.optionsAfterLogin then
                tinsert(optionsAfterLoginInfos, page)
            elseif info.optionsAfterVar then
                tinsert(optionsAfterVarInfos, page)
            else
                for j = 1, #page do deepLoad(page[j]) end
            end
        end
    end

    U1SimulateEvent("VARIABLES_LOADED");

    for i=1, #optionsAfterVarInfos do
        local page = optionsAfterVarInfos[i];
        for j=1,#page do deepLoad(page[j]) end
    end
    wipe(optionsAfterVarInfos)

    bundleLoading = nil; --- @see AceAddon-3.0 onEvent, allow EnableAddon
    U1SimulateEvent("PLAYER_LOGIN");

    for i=1, #optionsAfterLoginInfos do
        local page = optionsAfterLoginInfos[i];
        for j=1,#page do deepLoad(page[j]) end
    end
    wipe(optionsAfterLoginInfos)

    U1SimulateEvent("PLAYER_ENTERING_WORLD");
    U1SimulateEvent("LOADING_SCREEN_DISABLED");
    U1SimulateEvent("UPDATE_FACTION");
    U1SimulateEvent("SPELLS_CHANGED");
    U1SimulateEvent("WORLD_MAP_UPDATE");
    U1SimulateEvent("QUEST_LOG_UPDATE");
    if(UnitIsDeadOrGhost("player")) then U1SimulateEvent("PLAYER_DEAD") else U1SimulateEvent("PLAYER_ALIVE") end
    if(not InCombatLockdown())then U1SimulateEvent("PLAYER_REGEN_ENABLED") end
    if(GetNumGroupMembers()>0) then U1SimulateEvent("GROUP_ROSTER_UPDATE") end

    for i=1, #bundleSimNames do
        local name = bundleSimNames[i]
        local info = U1GetAddonInfo(name);
        if(info.toggle) then pcall(info.toggle, name, info, true, true) end
    end

    stopCapturing();
end

local loadPath = {} --- avoid cycle
function U1LoadAddOn(name, bundleSim)
    local before = time()
    wipe(loadPath)
    if not bundleSim then startCapturing(); end
    local result, reason = select(2, _G.pcall(U1LoadAddOnBackend, name))
    if not bundleSim then simEventsAndLoadCfgs(); end
    return result, reason
end

function U1LoadAddOnBackend(name)
    if C_AddOns.IsAddOnLoaded(name) then return 1 end
    local ii = U1GetAddonInfo(name);
    if not ii then return false, "MISSING" end

    if ii.conflicts then
        for _, other in ipairs(ii.conflicts) do
            if C_AddOns.IsAddOnLoaded(other) then
                EacDisableAddOn(name)
                return false, "Cannot be loaded together with -"..U1GetAddonTitle(other)
            end
        end
    end

    local iip = ii.parent and U1GetAddonInfo(ii.parent);
    if (ii.parent and not C_AddOns.IsAddOnLoaded(ii.parent) and not loadPath[ii.parent]) then
        local loaded = U1LoadAddOnBackend(ii.parent);
        if (not loaded) then
            U1OutputAddonState(format(L["%%s load failed, error loading dependency [%s]"], ii.parent), name, true);
            return false, "DEP_CORRUPT";
        end
    end
    if (ii.deps) then
        local deps = ii.deps;
        if type(deps) == "string" then deps = { deps }; end
        for _, dep in ipairs(deps) do
            if not C_AddOns.IsAddOnLoaded(dep) and not loadPath[dep] then
                if C_AddOns.GetAddOnEnableState(dep, U1PlayerName) < 2 then EacEnableAddOn(dep) end
                local loaded = U1LoadAddOnBackend(dep);
                if (not loaded) then
                    U1OutputAddonState(format(L["%%s load failed, error loading dependency [%s]"], dep), ii.name, true);
                    return false, "DEP_CORRUPT";
                end
            end
        end
    end

    loadPath[name] = 1
    if(ii.optdeps) then
        for _, dep in ipairs(ii.optdeps) do
            if not loadPath[dep] and not C_AddOns.IsAddOnLoaded(dep) and U1IsAddonEnabled(dep) then
                local loaded, reason = U1LoadAddOnBackend(dep);
                U1OutputAddonLoaded(dep, loaded, reason);
            end
        end
    end

    --- childrens are not loaded here, they are load in ToggleAddon
    if C_AddOns.GetAddOnEnableState(name, U1PlayerName) < 2 then EacEnableAddOn(name) end

    -- print("before", name, GetTime())
    capturing = name
    local status, loaded, reason = safecall(C_AddOns.LoadAddOn, name);
    capturing = nil
    -- print("after", name, GetTime(),loaded, reason)
    if loaded then
        local info = U1GetAddonInfo(name);
        if info.runAfterLoad then pcall(info.runAfterLoad, info, name) end
        tinsert(bundleSimNames, name);
    end

    return loaded, reason;
end

function U1ToggleChildren(name, enabled, noset, deepToggleChildren, bundleSim)
    local reloadChildren = false
    for subName, subInfo in U1IterateAllAddons() do
        if(subInfo.parent==name) then
            if deepToggleChildren and not subInfo.ignoreLoadAll then
                if (enabled) then
                    local r2 = U1ToggleAddon(subName, enabled, nil, true, bundleSim);
                    reloadChildren =  reloadChildren or r2;
                elseif (not enabled and C_AddOns.IsAddOnLoaded(subName) and U1IsAddonEnabled(subName)) then
                    local r2 = U1ToggleAddon(subName, enabled, nil, true, bundleSim);
                    reloadChildren =  reloadChildren or r2;
                end
            else
                if enabled and U1IsAddonEnabled(subName) then
                    local r2 = U1ToggleAddon(subName, true, "noset", true, bundleSim);
                    reloadChildren =  reloadChildren or r2;
                elseif not enabled and C_AddOns.IsAddOnLoaded(subName) and U1IsAddonEnabled(subName) then
                    local r2 = U1ToggleAddon(subName, false, "noset", true, bundleSim);
                    reloadChildren =  reloadChildren or r2;
                end
            end
        end
    end
    return reloadChildren
end

function U1ToggleAddon(name, enabled, noset, deepToggleChildren, bundleSim)
    local info = addonInfo[name];
    if not info then return end

    local reload = false;
    local status;

    if not bundleSim then startCapturing(name); end

    if not noset then
        db.addons[name] = enabled and 1 or 0;
        if(enabled)then EacEnableAddOn(name); else EacDisableAddOn(name) end
    end

    if(C_AddOns.IsAddOnLoaded(name)) then
        if(not enabled)then
            if(info.toggle) then
                status, reload = pcall(info.toggle, name, info, false);
            else
                reload = true;
            end

            if(reload)then
                if not noset then U1OutputAddonState(L["Reload to completely disable %s."], name); end
                U1ChangeReloadList(name, nil, 1)
            else
                if not noset then U1OutputAddonState(L["%s is current paused, the memory will not release until reload ui."], name); end
            end
        else
            if(info.toggle) then pcall(info.toggle, name, info, true, false) end

            if not noset then U1OutputAddonState(L["%s is no longer disabled."], name); end
            U1ChangeReloadList(name, nil, nil)
        end

    else
        if(enabled)then
            if(not info.lod or info.loadWith and C_AddOns.IsAddOnLoaded(info.loadWith))then
                local loaded, reason = U1LoadAddOn(name, true);
                if not noset then U1OutputAddonLoaded(name, loaded, reason); end
            else
                if not noset then U1OutputAddonState(L["%s is enabled, and will load on demand."], name); end
            end
        end
    end

    local reloadChildren = U1ToggleChildren(name, enabled, noset, deepToggleChildren, true)

    if not bundleSim then simEventsAndLoadCfgs(); end

    return reload or reloadChildren;
end

--- set cfg's internal properties like _parth, _path, _depth
local function deepInit(p, cfg, addonName)
    cfg._parent = p;
    if(cfg.var) then
        cfg.type = cfg.type or "checkbox";
        cfg._path = p and (p._path.."/"..cfg.var) or (addonName.."/"..cfg.var);
    else
        cfg._path = p and p._path or addonName;
        cfg.type = cfg.type or "button";
        --assert(#cfg==0, "error: no var, but with children: "..cfg.text);
    end
    cfg._depth = p and p._depth+1 or 0

    cfg.ldbIcon = cfg.ldbIcon == 1 and cfg.icon or cfg.ldbIcon;
    --cfg.tipLines = cfg.tipLines or (cfg.tip and {strsplit("`", cfg.tip)}); -- move to CtlRegularTip

    if #cfg > 0 then
        for i=1,#cfg do
            deepInit(cfg, cfg[i], nil);
        end
    end
end

function U1DeepInitConfigs(name, info)
    if name then name = name:lower() end
    for i=1,#info do
        deepInit(nil, info[i], name);
    end
end

local function initPageConfigs()
    for name, info in pairs(addonInfo) do
        U1DeepInitConfigs(name, info)
    end
end

--- load addon configs. asap = As soom as possible, or after VARIABLES_LOADED, or after PLAYER_LOGIN
local function loadNormalCfgs(asap, afterVar, afterLogin)
    for i=1,#loadedNormalAddons do
        local name = loadedNormalAddons[i]
        local info = U1GetAddonInfo(name)
        if ((asap and not info.optionsAfterVar and not info.optionsAfterLogin) or (afterVar and info.optionsAfterVar) or (afterLogin and info.optionsAfterLogin)) then
            if(info.runAfterLoad) then pcall(info.runAfterLoad, info, name) end
            if(info.toggle) then pcall(info.toggle, name, info, true, true) end
            local page = U1GetPage(name);
            if page then for j=1,#page do deepLoad(page[j]) end end
        end
    end
end

--- add "Options" button if addon called Settings.RegisterAddOnCategory
do
    local gotOptionCategory = {}
    local funcOpenCategory = function(cfg, v, loading)
        local func = CoreIOF_OTC or Settings.OpenToCategory
        func(gotOptionCategory[cfg._path].ID)
        if not SettingsPanel.CategoryList:IsVisible() then -- 10.0 fix
            func(gotOptionCategory[cfg._path].ID)
        end
    end
    local exclude = { ["!!!163ui!!!"] = 1, ["ace-3.0"] = 1 }
    hooksecurefunc(Settings, "RegisterAddOnCategory", function(frm)
        if frm.name and frm.parent==nil then
            local stack = debugstack()
            stack = stack:lower()
            for line in string.gmatch(stack, "([^\n]*)") do --for _, line in next, {strsplit("\n", stack)} do
                if not line:find("aceconfigdialog") then
                    local _,_,addon = line:find("interface[/\\]addons[/\\]([^/\\]+)[/\\]")
                    if addon and not exclude[addon] and not gotOptionCategory[addon] then
                        gotOptionCategory[addon] = frm
                        local info = U1GetAddonInfo(addon)
                        if info and not info.registered then
                            table.insert(info, { text = L["Options"], callback = funcOpenCategory, })
                            deepInit(nil, info, addon)
                        end
                        break
                    end
                end
            end
            --frm:Hide(); --to trigger onshow for grid2
        end
    end)
end

------------------------------------------------------------
-- Events
------------------------------------------------------------
local f = U1.eventframe
function U1Initialize()
    getInitialAddonInfo();
    CoreDispatchEvent(f, U1);
end

function U1:PLAYER_LOGIN()
    U1.playerLogin = true

    if not U1.variableLoaded then
        U1.loginBeforeVar = true
        loadNormalCfgs(1, nil, nil);
        U1:VARIABLES_LOADED(1)
    else
        loadNormalCfgs(nil, 1, nil);
    end

    f:UnregisterEvent("PLAYER_LOGIN") U1.PLAYER_LOGIN = nil
end

--- unregister acedb's PLAYER_LOGOUT, and call it in our logout.
local function processAceDBs()
    local acedb = LibStub("AceDB-3.0", true);
    if(acedb) then
        tinsertdata(AceDBs, acedb);
        acedb.frame:UnregisterEvent("PLAYER_LOGOUT");
    end
end

local function processDefaultEnable()
    for name,info in pairs(addonInfo) do
        -- force enable protected addons
        if info.protected then
            db.addons[name] = 1
            if not info.originEnabled and not info.parent then
                EacEnableAddOn(name)
                info.originEnabled = true
            end
        end

        -- Disable or Enable addon for the first time.
        if not db.addons[name] then
            local enabled = false
            if info.parent and info.defaultEnable == nil then --child addon without defaultEnable will set to true
                info.defaultEnable = 1
            end
            if info.defaultEnable == 0 then info.defaultEnable = false end
            if info.defaultEnable == 1 then info.defaultEnable = true end
            if (info.defaultEnable~=nil) then
                enabled = info.defaultEnable
                if not info.lod and info.registered then
                    if not enabled and info.originEnabled then
                        EacDisableAddOn(name)
                    elseif enabled and not info.originEnabled then
                        EacEnableAddOn(name)
                    end
                end
            else
                enabled = info.originEnabled
            end
            db.addons[name] = enabled and 1 or 0
        else
            -- if wow not exit properly use states in db, not current addon states
            if(db == defaultDB or db.enteredWorld) then
                db.addons[name] = (info.protected or info.originEnabled) and 1 or 0;
            end
        end
    end
end

local EnableOrLoadDependencies

function U1:ADDON_LOADED(event, name)
    if name == _ then
        if U2DB or U2DBG then U1DB, U1DBG = U2DB, U2DBG end  -- compatible with earlier versions.
        db = U1DB or defaultDB;
        U1DB = db;
        U1.db = db;
        U1DBG = U1DBG or {}
        U1DBG.configs = U1DBG.configs or {}
        db.selectedTag = db.selectedTag or defaultDB.selectedTag;

        -- some modifications to configs. All configs is loaded when ADDON_LOADED fired.
        initPageConfigs();
        if U1CreateUI then U1CreateUI() end

        -- remove addon for other classes, just remove from addonInfo
        for k, info in pairs(addonInfo) do
            if(info._classAddon and not U1AddonHasTag(k, U1PlayerClass))then
                for tag, tinfo in pairs(tagInfo) do
                    if(U1AddonHasTag(k, tag)) then tinfo.num = tinfo.num -1 end
                end
                addonInfo[k] = nil
            end
        end

        -- load EAC configs
        local pageself = U1GetPage(_)
        if pageself then
            for j = 1, #pageself do deepLoad(pageself[j]) end
        end

        -- Deal with info.defaultEnable property
        processDefaultEnable()

		-- Enable addon by db state
		for name,info in pairs(addonInfo) do
	        if(db.addons[name]==1) then
        	    if info.realLOD or info.protected then
            	    EacEnableAddOn(name)
	            end
    	    end
		end

        db.enteredWorld = nil;

        local saveState = function(name, value)
            name = C_AddOns.GetAddOnInfo(name);
            if not name then return end
            name = name:lower();
            if (db.addons[name]) then
                db.addons[name] = value;
            end
            U1UpdateTags("LOADED", name)
        end
        hooksecurefunc(C_AddOns, "EnableAddOn",  function(name) saveState(name, 1) end)
        hooksecurefunc(C_AddOns, "DisableAddOn", function(name) saveState(name, 0) end)
        CoreFireEvent("DB_LOADED");
        CoreCall("U1_CreateMinimapButton"); --must called after U1DB
		-- EnableOrLoadDependencies
        local loaded = {}
        for name, info in U1IterateAllAddons() do
            if info.deps then
                local tmp = info;
                while(tmp) do
                    if not U1IsAddonEnabled(tmp.name) then break; end
                    if not tmp.parent then tmp=true; break; end
                    tmp = U1GetAddonInfo(tmp.parent);
                end
                if tmp==true then
                    EnableOrLoadDependencies(name, info, loaded)
                end
            end
        end
    else

        local info = U1GetAddonInfo(name)
        if info then
            -- prop:runBeforeLoad
            if info.runBeforeLoad then info.runBeforeLoad(info, name) info.runBeforeLoad = nil end

            -- save loadedNormalAddons for loadNormalCfgs
            if not U1.variableLoaded and not U1.playerLogin then
                tinsert(loadedNormalAddons, name);
            end

            CoreFireEvent("CURRENT_ADDONS_UPDATED")
            CoreFireEvent("ADDON_SELECTED", U1GetSelectedAddon())
        end
    end

    processAceDBs(); --- unregister ace db's PLAYER_LOGOUT, there may be many AceDB's versions.
end

local function EnableOrLoad(name, info, realDeps, realOpts, loaded)
    --print("EnableOrLoad", name)
    if not name or not info then return end
    name = name:lower()
    if C_AddOns.IsAddOnLoaded(name) or loaded[name] then return end
    if loaded[name] then return end

    --- EnableAddOn in ADDON_LOADED, will be load by Blizzard, with dependencies honored
    if realDeps and tContains(realDeps, name) or realOpts and tContains(realOpts, name) then
        EnableOrLoadDependencies(name, info, loaded)
        --print("Real Enable", name)
        EacEnableAddOn(name)
    else
        --print("Real Load", name)
        U1LoadAddOn(name)
    end
    loaded[name] = true
end

function EnableOrLoadDependencies(name, info, loaded)
    --print("do deps", name)
    if info.parent then
        EnableOrLoad(info.parent, U1GetAddonInfo(info.parent), info.realDeps, info.realOptDeps, loaded)
    end

    for _, dep in ipairs(info.deps or _empty_table) do
        EnableOrLoad(dep, U1GetAddonInfo(dep), info.realDeps, info.realOptDeps, loaded)
    end

    for _, dep in ipairs(info.optdeps or _empty_table) do
        if U1IsAddonEnabled(dep) then
            EnableOrLoad(dep, U1GetAddonInfo(dep), info.realDeps, info.realOptDeps, loaded)
        end
    end
end

function U1:VARIABLES_LOADED(calledFromLogin)
    if calledFromLogin ~= 1 then
        if not U1.playerLogin then
            loadNormalCfgs(1, nil, nil);
        else
            RunOnNextFrame(loadNormalCfgs, nil, 1)
        end
    end
    U1.variableLoaded = true
end

function U1:PLAYER_ENTERING_WORLD(event)
    loadNormalCfgs(nil, nil, 1)
    initComplete = true;
    db.enteredWorld = true;
    f:UnregisterEvent("PLAYER_ENTERING_WORLD") U1.PLAYER_ENTERING_WORLD = nil;
end

local function deepSave(cfg)
    if(cfg.var and cfg.getvalue)then
        local success, value = pcall(cfg.getvalue);
        if success then
            U1SaveDBValue(cfg, value);
        end
    end
    if(#cfg > 0)then
        for _,v in ipairs(cfg) do
            deepSave(v);
        end
    end
end

--- refresh DB when logout, in case that configs are modified not by us.
function U1:PLAYER_LOGOUT(event)
    if(not self.PROFILE_CHANGED) then
        for addon, info in U1IterateAllAddons() do
            local page = U1GetPage(addon)
            if(page and C_AddOns.IsAddOnLoaded(addon)) then
                for _, cfg in ipairs(page) do
                    pcall(deepSave, cfg)
                end
            end
        end
    end
    for _, v in ipairs(AceDBs) do v.frame:GetScript("OnEvent")(v.frame, "PLAYER_LOGOUT"); end
end

U1Initialize();
