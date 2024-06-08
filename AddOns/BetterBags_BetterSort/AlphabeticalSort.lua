---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
---@class Localization: AceModule
local L = BetterBags:GetModule('Localization')
---@class Sort: AceModule
local sort = BetterBags:GetModule('Sort')

-- Override the default sort function
---@param a Section
---@param b Section
---@return boolean
function sort.SortSectionsAlphabetically(kind, a, b)
    local shouldSort, sortResult = sort.SortSectionsByPriority(kind, a, b)
    if shouldSort then return sortResult end

    local titleA = a.title:GetText()
    local titleB = b.title:GetText()

    if titleA == L:G("Recent Items") then return true end
    if titleB == L:G("Recent Items") then return false end

    if a:GetFillWidth() then return false end
    if b:GetFillWidth() then return true end

    if titleA == L:G("Free Space") then return false end
    if titleB == L:G("Free Space") then return true end

    return stripColorCode(titleA) < stripColorCode(titleB)
end

---@param text string
---@return string
function stripColorCode(text)
    if string.sub(text, 1, 4) == "|cff" then
        return string.sub(text, 11)
    end
    return text
end
