local addonName, ns = ...

-- ========================================================================
-- 本地化
-- ========================================================================
ns.L = setmetatable({}, {
    __index = function(t, key) return key end
})

-- ========================================================================
-- 存档初始化
-- ========================================================================
local function MergeDefaults(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" then
            if target[k] == nil then target[k] = {} end
            MergeDefaults(target[k], v)
        elseif target[k] == nil then
            target[k] = v
        end
    end
end

EventUtil.ContinueOnAddOnLoaded(addonName, function()
    RoyChatBarDB = RoyChatBarDB or {}
    if ns.defaults then
        MergeDefaults(RoyChatBarDB, ns.defaults)
    end

    -- 斜杠命令
    SLASH_RoyChatBar1 = "/rcb"
    SlashCmdList["RoyChatBar"] = function()
        local id = ns.chatCategoryID or ns.categoryID
        if id then
            Settings.OpenToCategory(id)
        end
    end
end)
