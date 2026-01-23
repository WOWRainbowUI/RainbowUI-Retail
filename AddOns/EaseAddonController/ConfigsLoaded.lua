--- Called in ConfigsLoaded.lua and after all calls of U1RegisterAddon()
local _, U1 = ...
local L = U1.L

function U1ConfigsLoaded()
    local addonInfo = U1.addonInfo;
    --- process Curse AddOns
    for _, one in ipairs(U1.CurseAddOns) do
        if #one >= 3 then
            for _, folder in ipairs(one[3]) do
                local info = addonInfo[folder]
                if info and not info.tags then info.tags = { U1.CURSE_TAGS[one[2]][2] } end
            end
        else
            local info = addonInfo[one[1]]
            if info and not info.tags then info.tags = { U1.CURSE_TAGS[one[2]][2] } end
        end
    end
    wipe(U1.CURSE_TAGS) U1.CURSE_TAGS = nil
    wipe(U1.CurseAddOns) U1.CurseAddOns = nil

    if U1.CfgDefaults then -- 檢查有沒有預設設定檔
		for name, reg in pairs(U1.CfgDefaults) do
			if addonInfo[name:lower()] then
				U1RegisterAddon(name, reg)
			end
		end
		wipe(U1.CfgDefaults) U1.CfgDefaults = nil
	end

    --- register addons with X-Category if UI163_USE_X_CATEGORIES = true
    for k,v in pairs(addonInfo) do
        if not v.registered and v.xcategories then
            U1RegisterAddon(v.name, { registered = false, tags = {strsplit(",", v.xcategories:gsub(",[ ]+", ","))}})
        end
        v.xcategories = nil
    end

    --- process addon without parent installed.
    for _, info in pairs(addonInfo) do
        -- registered but parent is not installed
        if (info.parent and not info.tags and not addonInfo[info.parent] and U1.parentTags[info.parent]) then
            info.tags = U1.parentTags[info.parent]
            info.parent = nil
        end
    end
    wipe(U1.parentTags); U1.parentTags = nil

    for k,v in pairs(addonInfo) do

        if v.lod and not v.parent and not v.nolodbutton then
            tinsert(v, 1, {text=L["Load Now"], enableOnNotLoad=1, disableOnLoad=1, tip=L["hint.Load Now"], callback=function()
                if not C_AddOns.IsAddOnLoaded(k) then
                    local loaded, reason = C_AddOns.LoadAddOn(k)
                    U1OutputAddonLoaded(k, loaded, reason);
                    if loaded then UUI.Right.ADDON_SELECTED() UUI.Center.Refresh() end
                end
            end})
        end

        -- children of registered addon are also registered
        local pinfo = v.parent and addonInfo[v.parent]
        if not pinfo then v.parent = nil end
        if not v.registered and v.parent and pinfo and pinfo.registered then
            v.registered = true
        end

        -- we may hide some parent addons and load when their children is loaded.
        -- we register these addons by {hide=1,lod=1,protected=nil,} and Disable here to prevent Blizzard from loading them.
        if (v.lod and not v.realLOD) then
            EacDisableAddOn(k)
        end

        -- if parent addon is hidden, then set parent to nil and add parent in deps
        if (v.parent and addonInfo[v.parent] and addonInfo[v.parent].hide and not v.hide) then
            v.deps = v.deps or {};
            tinsertdata(v.deps, v.parent);
            v.parent = nil;
        end

        --- choose an icons base on time33 hash
        if not v.parent and not v.icon then
            local tag = v.tags and v.tags[1] or "NOTAGS"
            local icons = U1.ICONS[tag]
            if icons then
                v.icon = "Interface\\Icons\\"..icons[(time33(k) % #icons) + 1]
            end
        end
    end

    --- process tags, should be after all register and parent process.
    for _, info in pairs(addonInfo) do
        if not info.parent and not info.hide then
            info.tags = info.tags or (info.xcategories and {strsplit(",", info.xcategories:gsub(",[ ]+", ","))});
            for _, v in ipairs(info.tags or _empty_table) do
                if v == "CLASS" then info._classAddon = true end
                info.tags[v] = true;
                U1RegisterTag(v);
            end
        end
    end

    wipe(U1.ICONS) U1.ICONS = nil
    U1ConfigsLoaded = nil;
    U1RegisterAddon = nil;
    U1ChangeTags = nil;
end

U1ConfigsLoaded()
