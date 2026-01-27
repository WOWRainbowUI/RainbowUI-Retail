--[[-------------------------------------------------------------------------
-- BlizzardFrames.lua
--
-- This file contains the definitions of the blizzard frame integration
-- options. These settings will not apply until the user interface is
-- reloaded.
--
-- Events registered:
--   * ADDON_LOADED - To watch for loading of the ArenaUI
-------------------------------------------------------------------------]]--

---@class CliqueAddon
local addon = select(2, ...)
local L = addon.L

local issecretvalue = issecretvalue or function(val) return false end

local parentKeysExact = {
    ["HealthBar"] = true,
    ["ManaBar"] = true,
    ["PowerBar"] = true,
    ["Debuff1"] = true,
    ["Debuff2"] = true,
    ["Debuff3"] = true,
    ["centerStatusIcon"] = true,
    ["CenterDefensiveBuff"] = true,
}

local globalNamePatterns = {
    "^.+Buff%d$",
    "^.+Debuff%d$",
    "^.+DispelDebuff1$",
    "^.+CenterStatusIcon$",
}

local function findSubFrames(obj)
    local checked = {}
    local found = {}

    local traverse
    traverse = function(current)
        if type(current) ~= "table" then return end
        if checked[current] then return end

        checked[current] = true

        for key, value in pairs(current) do
            -- Check the parent key names exactly
            if key and parentKeysExact[key] then
                table.insert(found, value)
            elseif key and type(key) == "string" and key:match("^[Pp]rivate[Aa]ura") then
                -- Don't do anything with this, these get weird
            elseif type(value) == "table" and value.IsForbidden and value:IsForbidden() then
                -- Skip this one, forbidden frames are weird
            elseif type(value) == "table" and value.GetName and pcall(value.GetName, value) and type(value:GetName()) == "string" then
                -- Check against global name patterns
                local name = value:GetName()
                for _, pattern in ipairs(globalNamePatterns) do
                    if name:match(pattern) then
                        table.insert(found, value)
                    end
                end
            elseif type(value) == "table" then
                traverse(value)
            end
        end
    end

    traverse(obj)
    return found
end

local function registerFrameOutOfcombat(frame)
        -- Stash the frame in case we later convert it
    local frameName = frame

    -- Convert a frame name to the global object
    if type(frame) == "string" then
        frameName = frame
        frame = _G[frameName]
        if not frame then
            addon:Printf(L["Error registering frame: %s"], tostring(frameName))
            return
        end
    end

    if not frame then
        addon:Printf(L["Unable to register empty frame: %s]"], tostring(frameName))
        return
    end

    -- Never allow forbidden frames, we can't do anything with those!
    local forbidden = frame.IsForbidden and frame:IsForbidden()
    if forbidden then
        return
    end

    local buttonish = frame and frame.RegisterForClicks
    local protected = frame.IsProtected and frame:IsProtected()
    local name = frame and frame.GetName and frame:GetName()
    local anchorRestricted = frame.IsAnchoringRestricted and frame:IsAnchoringRestricted()

	-- secrets secrets everywhere..
    if issecretvalue(protected) or issecretvalue(name) or issecretvalue(anchorRestricted) then
        return
    end

    local nameplateish = type(name) == "string" and name:match("^NamePlate")

    -- A frame must be a button, and must be protected, and must not be a nameplate, anchor restricted
    local valid = buttonish and protected and (not nameplateish) and (not anchorRestricted)

    if not valid then return end

    local subFrames = findSubFrames(frame)
    for _, value in ipairs(subFrames) do
        if value.SetPropagateMouseMotion then
            value:SetPropagateMouseMotion(true)
        end
    end

	if addon.settings.blizzframes.wipeMenuAction then
		frame:SetAttribute("*type2", nil)
	end

    ClickCastFrames[frame] = true
end

-- Register a Blizzard frame for click-casting, with some additional protection
function addon:RegisterBlizzardFrame(frame)
    if InCombatLockdown() then
        local deferred = function()
            registerFrameOutOfcombat(frame)
        end

        addon:Defer(deferred)
    else
        registerFrameOutOfcombat(frame)
    end
end
