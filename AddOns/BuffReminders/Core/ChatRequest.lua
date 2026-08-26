local _, BR = ...
local L = BR.L

-- ============================================================================
-- CHAT REQUEST (definition + resolution)
-- ============================================================================
-- Single source of truth for "request this buff in chat". A buff is requestable
-- only when its definition in BR.BUFF_TABLES carries `chatRequestable = true`.
-- To add a requestable buff, set that flag in Data/Buffs.lua.

local ChatRequest = {}

-- The scan order fixes the order of the results. The virtual categories
-- (custom/loadout) are absent: no UI can flag them, so they never carry
-- `chatRequestable`.
local CATEGORY_ORDER = BR.STATIC_CATEGORIES

local buffList
local categoryList

-- BR.BUFF_TABLES is static after load (custom buffs are not scanned), so one
-- build is safe to cache for the session.
local function build()
    buffList = {}
    categoryList = {}
    local seenCat = {}
    for _, cat in ipairs(CATEGORY_ORDER) do
        local tbl = BR.BUFF_TABLES[cat]
        if tbl then
            for _, def in ipairs(tbl) do
                if def.chatRequestable then
                    buffList[#buffList + 1] = def
                    if not seenCat[cat] then
                        seenCat[cat] = true
                        categoryList[#categoryList + 1] = cat
                    end
                end
            end
        end
    end
end

--- Ordered list of buff defs flagged `chatRequestable`.
---@return table[] defs
function ChatRequest.Buffs()
    if not buffList then
        build()
    end
    return buffList
end

--- Ordered list of categories that host at least one requestable buff.
---@return string[] categories
function ChatRequest.Categories()
    if not categoryList then
        build()
    end
    return categoryList
end

--- Slash-command prefix for the current group context (instance > raid > party > say).
---@return string prefix trailing space included, ready to prepend to the message
function ChatRequest.GetPrefix()
    if IsInGroup(2) then -- instance group
        return "/instance "
    elseif IsInRaid() then
        return "/raid "
    elseif IsInGroup() then
        return "/party "
    end
    return "/say "
end

--- Resolve the message for a buff key: custom (profile) > localized default > fallback name.
---@param key string buff key (matches BR.profile.chatRequestMessages keys)
---@param fallbackName string? used only when no custom message and no locale entry exist
---@return string?
function ChatRequest.ResolveMessage(key, fallbackName)
    local custom = (BR.profile.chatRequestMessages or {})[key]
    if custom and custom ~= "" then
        return custom
    end
    return L["ChatRequest." .. key] or fallbackName
end

BR.ChatRequest = ChatRequest
