local _,rematch = ...
local L = rematch.localization
local C = rematch.constants
rematch.badges = {}

local badges = {
    marker1 = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0,0.125,0.25,0.375}, -- star
    marker2 = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.125,0.25,0.25,0.375}, -- circle
    marker3 = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.25,0.375,0.25,0.375}, -- diamond
    marker4 = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.375,0.5,0.25,0.375}, -- triangle
    marker5 = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.5,0.625,0.25,0.375}, -- moon
    marker6 = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.625,0.75,0.25,0.375}, -- square
    marker7 = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.75,0.875,0.25,0.375}, -- cross
    marker8 = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.875,1,0.25,0.375}, -- skull
    leveling = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.375,0.5,0.125,0.25}, -- leveling blue arrow
    team = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.5,0.625,0.125,0.25}, -- team green paw
    preferences ={"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.75,0.875,0.125,0.25}, -- preferences blue gear
    targets = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.375,0.5,0.375,0.5}, -- target
    new = {"Interface\\AddOns\\Rematch\\textures\\badges-borderless",0.625,0.75,0.75,0.875}, -- new (wrapped/stickied pet)
}

local extendedBadges = {} -- for adding badges used by outside addons
local badgeArrays = {} -- indexed by the parentArray, the number of badges used

-- clears the badges from the given array of textures
function rematch.badges:ClearBadges(array)
    badgeArrays[array] = 0
    for _,badge in ipairs(array) do
        badge:Hide()
    end
end

-- adds a named badge ("leveling", "marker3", etc.) to the given array of textures (parentArray of badges)
-- xdir should be -1 for badges that go right to left, 1 otherwise
function rematch.badges:AddBadge(array,badge,anchorPoint,relativeTo,relativePoint,xoff,yoff,xdir)
    assert(badges[badge],"Badge "..(badge or "nil").." doesn't exist")
    if not badgeArrays[array] then
        badgeArrays[array] = 1 -- not seen this one before, start at 1
    else
        badgeArrays[array] = badgeArrays[array] + 1 -- otherwise increment to next one
    end
    local index = badgeArrays[array]
    if not array[index] then
        array[index] = array[1]:GetParent():CreateTexture(nil,"ARTWORK")
        array[index]:SetSize(C.BADGE_SIZE,C.BADGE_SIZE)
    end
    array[index]:ClearAllPoints()
    array[index]:SetPoint(anchorPoint,relativeTo,relativePoint,(C.BADGE_SIZE+1)*(index-1)*xdir+xoff,yoff)
    array[index]:SetTexture(badges[badge][1])
    array[index]:SetTexCoord(badges[badge][2],badges[badge][3],badges[badge][4],badges[badge][5])
    array[index]:Show()
    return array[index]
end


-- RegisterBadge is for outside addons to add their own badges to lists without modifying built-in badges
-- list can be "pets", "teams", "targets" for the list to put the badge on
-- badge should be a name to reference the badge (must not already be used by another badge)
-- icon is a patch/fileid of the icon
-- iconCoords is either nil for 0,1,0,1 texcoords or a {left,right,top,bottom} ordered list
-- callback is a function that takes a petID, teamID or targetID and should return true if the badge should show
function rematch.badges:RegisterBadge(list,badge,icon,iconCoords,callback)
    assert(list=="pets" or list=="teams" or list=="targets","Only pets, teams or targets supported for extended badges")
    assert(type(badge)=="string","Invalid badge name \""..(badge or "nil").."\"")
    assert(type(callback)=="function","ExtendBadges requires a callback")

    -- a badge icon can be reused for multiple lists but can't be modified once it's defined
    if badge and not badges[badge] then
        icon = icon or C.UNKNOWN_ICON
        if iconCoords and #iconCoords==4 then
            badges[badge] = {icon,unpack(iconCoords)}
        else
            badges[badge] = {icon,0,1,0,1}
        end
    end

    if not extendedBadges[list] then
        extendedBadges[list] = {}
    end
    -- in case the same badge is being re-defined, remove any of the given badges from the list if found
    rematch.badges:UnregisterBadge(list,badge)
    tinsert(extendedBadges[list],{badge,callback}) -- ordered so badges appear in order they were registered
end

-- removes a registered badge
function rematch.badges:UnregisterBadge(list,badge)
    if extendedBadges[list] then
        for i=#extendedBadges[list],1,-1 do
            if extendedBadges[list][i][1]==badge then
                tremove(extendedBadges[list],i)
            end
        end
        if rematch.frame:IsVisible() then
            rematch.frame:Update()
        end
    end
end

-- called by the pet, team and target listbutton fills to add any extended badges; returns the number of badges placed
function rematch.badges:AddExtendedBadges(id,list,array,anchorPoint,relativeTo,relativePoint,xoff,yoff,xdir)
    local count = 0
    if extendedBadges[list] then
        for _,info in ipairs(extendedBadges[list]) do
            if info[2](id) then
                rematch.badges:AddBadge(array,info[1],anchorPoint,relativeTo,relativePoint,xoff,yoff,xdir)
                count = count + 1
            end
        end
    end
    return count
end