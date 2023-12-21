local addonName, addon = ...
local utils = addon.utils
addon.config = addon.config or utils.class("addon.config").new()
local config = addon.config
local const = addon.const
local callbacks = {}
local ADDON_VERSION = 2

function config:getOrCreateTable(categoryId)
    if not PremakeGroupsHelperConfig then
        return nil
    end

    if categoryId then
        if not PremakeGroupsHelperConfig[categoryId] then
            PremakeGroupsHelperConfig[categoryId] = {}
        end

        return PremakeGroupsHelperConfig[categoryId]
    end

    return PremakeGroupsHelperConfig
end

function config:getValue(keys, categoryId)
    local node = config.getOrCreateTable(config, categoryId)
    if not node then
        return nil
    end

    if type(keys) == "table" then
        for _, v in ipairs(keys) do
            if not node[v] then
                return nil
            end
            node = node[v]
        end
        return node
    else
        return node[keys]
    end
end

function config:setValue(keys, newvalue, categoryId)
    local node = config.getOrCreateTable(config, categoryId)
    if not node then
        return nil
    end

    if type(keys) == "table" then
        if #keys == 1 then
            node[keys[1]] = newvalue
        else
            for i = 1, #keys - 1 do
                local v = keys[i]
                if not node[v] then
                    node[v] = {}
                end
                node = node[v]
            end
            node[keys[#keys]] = newvalue
        end
    else
        node[keys] = newvalue
    end

    local key = type(keys) == "table" and keys[1] or keys

    if callbacks[key] then
        utils.twalk(callbacks[key], function( v, k)
            v(keys, newvalue, categoryId)
        end)
    end
end

function config:resetConfiguration(categoryId)
    if not PremakeGroupsHelperConfig then
        return
    end

    local default = self:getDefaultConfiguration()
    if categoryId then
        PremakeGroupsHelperConfig[categoryId] = default[categoryId] or {}
    else
        PremakeGroupsHelperConfig = default
    end
end

function config:registerCallback(key, func)
	if type(key) == "table" then
		for _, key2 in ipairs(key) do
			if callbacks[key2] then
				table.insert(callbacks[key2], func)
			else
				callbacks[key2] = { func }
			end
		end
	else
		if callbacks[key] then
			table.insert(callbacks[key], func)
		else
			callbacks[key] = { func }
		end
	end
end

function config:unregisterCallback(key, func)
	if callbacks[key] then
        utils.tremovebyvalue(callbacks[key], func, true)

        if #table == 0 then
            callbacks[key] = nil
        end
	end
end

function config:initConfiguration()
    if PremakeGroupsHelperConfig == nil or not pcall(self.migrateConfiguration, self) then
        self:setDefaultConfiguration()
    end
end

function config:getDefaultConfiguration()
    return {
        version = ADDON_VERSION,
        --spamfilter = {}, --屏蔽垃圾广告用的黑名单
        [const.CATEGORY_TYPE_DUNGEON] =
        {
            showinfo = {
                enable = true,
                showclassbar = true,
                showclassinfo = false,
                showleaderscore = true,
            },
        },
        [const.CATEGORY_TYPE_CLASSRAID] = {
            showinfo = {
                enable = true,
                showleaderraidprocess = true,
            },
        },
        [const.CATEGORY_TYPE_RAID] = {
            showinfo = {
                enable = true,
                showleaderraidprocess = true,
            },
        },
        [const.CATEGORY_TYPE_ARENA] = {
            showinfo = {
                enable = true,
                showleaderscore = true,
            },
        },
        [const.CATEGORY_TYPE_RBG] = {
            showinfo = {
                enable = true,
                showleaderscore = true,
            },
        }
    }
end

function config:setDefaultConfiguration()
    PremakeGroupsHelperConfig = self:getDefaultConfiguration()
end

function config:migrateConfiguration()
    if PremakeGroupsHelperConfig.version ~= ADDON_VERSION then
        PremakeGroupsHelperConfig = self:getDefaultConfiguration()
    end
end