--[[-------------------------------------------------------------------
--  Clique - Copyright 2006-2026 - James N. Whitehead II
-------------------------------------------------------------------]]--

--- @class CliqueAddon
local addon = select(2, ...)

function addon:ShouldRemoveSelfCast()
    return false
end

local function ATTR(indent, prefix, attr, suffix, value)
    local fmt = [[%sbutton:SetAttribute("%s%s%s%s%s", %q)]]
    return fmt:format(indent, prefix, #prefix > 0 and "-" or "", attr, tonumber(suffix) and "" or "-", suffix, value)
end

local function REMATTR(prefix, attr, suffix, value)
    local fmt = [[button:SetAttribute("%s%s%s%s%s", nil)]]
    return fmt:format(prefix, #prefix > 0 and "-" or "", attr, tonumber(suffix) and "" or "-", suffix)
end

local B_SET = [[self:SetBindingClick(true, %q, clickableButton, %q);]]
local B_CLR = [[self:ClearBinding(%q);]]

-- A sort function that determines in what order bindings should be applied.
-- This function should be treated with care, it can drastically change behavior
local function ApplicationOrder(a, b)
    local acnt, bcnt = 0, 0
    for k,v in pairs(a.sets) do acnt = acnt + 1 end
    for k,v in pairs(b.sets) do bcnt = bcnt + 1 end

    -- Force out-of-combat clicks to take the HIGHEST priority
    if a.sets.ooc and not b.sets.ooc then
        return true
    elseif b.sets.ooc and not a.sets.ooc then
        return false
    elseif a.sets.ooc and b.sets.ooc then
        return acnt < bcnt
    end

    -- Try to give any 'default' clicks LOWEST priority
    if a.sets.default and not b.sets.default then
        return true
    elseif a.sets.default and b.sets.default then
        return acnt < bcnt
    end
end

local function shouldApply(global, entry)
    -- Filter out gamepad bindings when the gamepad option is disabled
    if addon:IsGamePadBinding(entry) and not addon:IsGamePadEnabled() then
        return false
    end

    -- If this is the global button and this is a 'global' binding
    if global and (entry.sets.hovercast or entry.sets.global) then
        return true
    elseif not global then
        -- Check to see if there's a non-global binding to be set
        for k, v in pairs(entry.sets) do
            if k ~= "global" and k ~= "hovercast" then
                return true
            end
        end
        return false
    end
end

-- This function takes a single argument indicating if the attributes being
-- computed are for the special 'global' button used by Clique.  It then
-- computes the set of attributes necessary for the player's bindings to be
-- active on all the appropriate frames. The logic here is quite delicate but
-- also rather well commented.
function addon:GetClickAttributes(global)
    -- In these scripts, 'self' should always be the header
    local bits = {
        "local inCombat = control:GetAttribute('inCombat')",
        "local setupbutton = self:GetFrameRef('cliquesetup_button')",
        "local button = setupbutton or self",
    }

    local rembits = {
        "local inCombat = control:GetAttribute('inCombat')",
        "local setupbutton = self:GetFrameRef('cliquesetup_button')",
        "local button = setupbutton or self",
    }

    -- Check to see if the frame being setup is blacklisted. Do not perform
    -- this check on the global frame.
    if not global then
        bits[#bits + 1] = "local name = button:GetName()"
        bits[#bits + 1] = "if blacklist[name] then return end"

        rembits[#rembits + 1] = "local name = button:GetName()"
        rembits[#rembits + 1] = "if blacklist[name] then return end"
    end

    if self:ShouldRemoveSelfCast() then
        table.insert(bits, "button:SetAttribute('checkselfcast', false)")
        table.insert(bits, "button:SetAttribute('checkfocuscast', false)")
    end

    -- When we're in AnyDown mode the 'menu' action won't work, since its
    -- hard-coded to only operate on the 'up' portion of the click. So we
    -- need to convert menu into togglemenu if and when we see that.
    if not global and self:IsDownClickEnabled() then
        table.insert(bits, [[local curType2 = button:GetAttribute("*type2")]])
        table.insert(bits, [[if curType2 == "menu" then]])
        table.insert(bits, [[  button:SetAttribute("*type2", "togglemenu")]])
        table.insert(bits, [[end]])
    end

    -- Backup and remove wildcard attributes on frames, as a nuclear option
    -- but only when enabled. We're not concerned that we'll back up the
    -- togglemenu option, as that's the one that works most well for addons.
    if not global and self.settings.removeWildcardActions then
        table.insert(bits, [[local oldType1 = button:GetAttribute("*type1")]])
        table.insert(bits, [[if oldType1 then]])
        table.insert(bits, [[  button:SetAttribute("clique-backup-*type1", oldType1)]])
        table.insert(bits, [[  button:SetAttribute("*type1", "")]])
        table.insert(bits, [[end]])
        table.insert(bits, [[local oldType2 = button:GetAttribute("*type2")]])
        table.insert(bits, [[if oldType2 then]])
        table.insert(bits, [[  button:SetAttribute("clique-backup-*type2", oldType2)]])
        table.insert(bits, [[  button:SetAttribute("*type2", "")]])
        table.insert(bits, [[end]])

        table.insert(rembits, [[local backup1 = button:GetAttribute("clique-backup-*type1")]])
        table.insert(rembits, [[if backup1 then]])
        table.insert(rembits, [[  button:SetAttribute("*type1", backup1)]])
        table.insert(rembits, [[  button:SetAttribute("clique-backup-*type1", nil)]])
        table.insert(rembits, [[end]])
        table.insert(rembits, [[local backup2 = button:GetAttribute("clique-backup-*type2")]])
        table.insert(rembits, [[if backup2 then]])
        table.insert(rembits, [[  button:SetAttribute("*type2", backup2)]])
        table.insert(rembits, [[  button:SetAttribute("clique-backup-*type2", nil)]])
        table.insert(rembits, [[end]])
    end

   -- Sort the bindings so they are applied in order. This sort ensures that
    -- any 'ooc' bindings are applied first.
    table.sort(self.bindings, ApplicationOrder)

    -- Build a small table of ooc keys that are 'taken' so we can check for
    -- masking conflicts with the friend/enemy sets.
    local oocKeys = {}
    for idx, entry in ipairs(self.bindings) do
        if shouldApply(global, entry) and entry.sets.ooc and entry.key then
            oocKeys[entry.key] = true
        end
    end

    for idx, entry in ipairs(self.bindings) do
        -- Global (i.e. 'hovercast' and 'global') bindings are only applied
        -- on the global frame, and not on any others. Additionally, any
        -- non-global bindings are only applied on non-global frames. handle
        -- this logic here.

        if shouldApply(global, entry) and self:IsBindingCorrectSpec(entry) and entry.key then
            -- Check to see if this is a 'friend' or an 'enemy' binding, and
            -- check if it would mask an 'ooc' binding with the same key. If
            -- so, we need to add code that prevents this from happening, by
            -- stopping the friend/enemy binding from being applied when the
            -- player is out of combat.

            local indent = ""
            local oocmask = oocKeys[entry.key]

            -- This code needs to set/clear a binding depending on combat
            -- state. We do both in this function to ensure that we don't have
            -- to run remove_clicks every single time the combat status
            -- changes.

            local startbits
            if oocmask and not entry.sets.ooc then
                -- This means that the binding will mask the 'ooc' binding
                -- with the same key, so we must ensure this is only set when
                -- we are in combat.
                bits[#bits + 1] = "if inCombat then      -- non-ooc that is masking"
                indent = indent .. "  "
            elseif entry.sets.ooc then
                -- This is a standard 'ooc' binding, so we want to ensure its
                -- only applied when out of combat, and cleared otherwise.
                bits[#bits + 1] = "if not inCombat then  -- ooc binding"
                indent = indent .. "  "
                startbits = #rembits + 1
            end

            local prefix, suffix = self:GetBindingPrefixSuffix(entry, global)

            -- Set up help/harm bindings. The button value will be either a number,
            -- in the case of mouse buttons, otherwise it will be a string of
            -- characters. Harmbuttons work alongside modifiers, so we need to include
            -- then in the remapping.
            if entry.sets.friend then
                if global then
                    -- A modified binding that uses friend/enemy must have the unmodified
                    -- 'unit' attribute set, in order to do the friend/enemy lookup. Add
                    -- that here.
                    --
                    -- NOTE: This will not work with useOwnerUnit and usesuffix frames
                    -- such as pet frames that use the owner's parent. This is a problem
                    -- with the way the 'mouseover' unit resolves in these cases.
                    bits[#bits + 1] = ATTR(indent, prefix, "unit", suffix, "mouseover")
                    rembits[#rembits + 1] = REMATTR(prefix, "unit", suffix)
                end
                local newbutton = "friend" .. suffix
                bits[#bits + 1] = ATTR(indent, prefix, "helpbutton", suffix, newbutton)
                rembits[#rembits + 1] = REMATTR(prefix, "helpbutton", suffix)
                suffix = newbutton
            elseif entry.sets.enemy then
                if global then
                    -- A modified binding that uses friend/enemy must have the unmodified
                    -- 'unit' attribute set, in order to do the friend/enemy lookup. Add
                    -- that here.
                    --
                    -- NOTE: This will not work with useOwnerUnit and usesuffix frames

                    -- such as pet frames that use the owner's parent. This is a problem
                    -- with the way the 'mouseover' unit resolves in these cases.
                    bits[#bits + 1] = ATTR(indent, prefix, "unit", suffix, "mouseover")
                    rembits[#rembits + 1] = REMATTR(prefix, "unit", suffix)
                end
                local newbutton = "enemy" .. suffix
                bits[#bits + 1] = ATTR(indent, prefix, "harmbutton", suffix, newbutton)
                rembits[#rembits + 1] = REMATTR(prefix, "harmbutton", suffix)
                suffix = newbutton
            end

            -- When we're setting up the 'global' button, and the binding is in the
            -- 'hovercast' binding set, we need to specify the unit on which to take
            -- the action. In this case, that's just mouseover.
            if global and entry.sets.hovercast then
                bits[#bits + 1] = ATTR(indent, prefix, "unit", suffix, "mouseover")
                rembits[#rembits + 1] = REMATTR(prefix, "unit", suffix)
            end

            -- Build any needed SetAttribute() calls
            if entry.type == "target" then
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, entry.type)
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
            elseif entry.type == "menu" then
                -- For some reason, the menu only triggers on 'up' clicks so we need to use
                -- togglemenu always now.
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, "togglemenu")
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
            elseif entry.type == "spell" and self.settings.stopcastingfix then
                -- Implement the 'stop casting' fix
                local macrotext
                local spellText = self:SpellTextWithSubName(entry)
                if entry.sets.global then
                    -- Do not include @mouseover
                    macrotext = string.format("/click %s\n/cast %s", self.stopbutton.name, spellText)
                else
                    macrotext = string.format("/click %s\n/cast [@mouseover] %s", self.stopbutton.name, spellText)
                end
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, "macro")
                bits[#bits + 1] = ATTR(indent, prefix, "macrotext", suffix, macrotext)
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
                rembits[#rembits + 1] = REMATTR(prefix, "macrotext", suffix)
            elseif entry.type == "spell" then
                local spellText = self:SpellTextWithSubName(entry)
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, entry.type)
                bits[#bits + 1] = ATTR(indent, prefix, "spell", suffix, spellText)
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
                rembits[#rembits + 1] = REMATTR(prefix, "spell", suffix)
            -- Macros aren't available on The War Within and above
            elseif entry.type == "macro" and self.settings.stopcastingfix and entry.macrotext then
                local macrotext = string.format("/click %s\n%s", self.stopbutton.name, entry.macrotext)
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, entry.type)
                bits[#bits + 1] = ATTR(indent, prefix, "macrotext", suffix, macrotext)
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
                rembits[#rembits + 1] = REMATTR(prefix, "macrotext", suffix)
            -- Macros aren't available on The War Within and above
            elseif entry.type == "macro" and entry.macrotext then
                -- Macros aren't available on 11.x: The War Within
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, entry.type)
                bits[#bits + 1] = ATTR(indent, prefix, "macrotext", suffix, entry.macrotext)
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
                rembits[#rembits + 1] = REMATTR(prefix, "macrotext", suffix)
            elseif entry.type == "macro" and entry.macro then
                bits[#bits + 1] = ATTR(indent, prefix, "type", suffix, entry.type)
                bits[#bits + 1] = ATTR(indent, prefix, "macro", suffix, entry.macro)
                rembits[#rembits + 1] = REMATTR(prefix, "type", suffix)
                rembits[#rembits + 1] = REMATTR(prefix, "macro", suffix)
            else
                error(string.format("Invalid action type: '%s'", tostring(entry.type)))
            end

            -- Finish the conditional statements started above
            if oocmask and not entry.sets.ooc then
                -- This means that the binding will mask the 'ooc' binding
                -- with the same key, so we must ensure this is only set when
                -- we are in combat.
                bits[#bits + 1] = "end"
                indent = indent:sub(1, -3)
            elseif entry.sets.ooc then
                -- This is a standard 'ooc' binding, so we want to ensure its
                -- only applied when out of combat, and cleared otherwise.
                local endbits = #rembits
                bits[#bits + 1] = "else                  -- clear ooc binding"
                for i = startbits, endbits, 1 do
                    bits[#bits + 1] = indent .. rembits[i]
                end
                bits[#bits + 1] = "end"
                indent = indent:sub(1, -3)
            end
        end
    end

    return table.concat(bits, "\n"), table.concat(rembits, "\n")
end

-- This function takes a single argument, indicating whether the attributes
-- should be built for the special global button or not, and returns an
-- attribute that can set the appropriate attributes, and one that can clear
function addon:GetBindingAttributes(global)
    local set, clr

    -- If this is not the global button, include some logic that solves issues
    -- when the frame disappears or the frame loses focus without the OnLeave
    -- event firing.
    --
    -- TODO: In the future, this should be done via OnHide or other ways as well

    if global then
        set = {
            "local clickableButton = self",
        }
        clr = {}
    else
        set = {
            "local button = self",
            "local name = button:GetName()",
            --"print('onenter: ' .. tostring(name and name or button))",
            "if blacklist[name] then return end",
            "if danglingButton then ",
            --"  local dangleName = danglingButton:GetName()",
            --"  print('clearing dangles for: ' .. tostring(dangleName and dangleName or danglingButton))",
            "  control:RunFor(danglingButton, control:GetAttribute('setup_onleave'))",
            "end",
            "local cliqueNamedButton = control:GetFrameRef('cliqueNamedButton')",
            "if not name then ",
            "  cliqueNamedButton:SetAttribute('unit', button:GetAttribute('unit'))",
            "end",
            "local clickableButton = name and self or cliqueNamedButton:GetName()",
            "danglingButton = button",
        }
        clr = {
            "local button = self",
            "local name = button:GetName()",
            --"print('onleave: ' .. tostring(name and name or button))",
            "if blacklist[name] then return end",
            "danglingButton = nil",
        }
    end

    -- This function is greatly simplified in that regardless of whether or
    -- not bindings mask one another, they still need to be set as binding
    -- clicks on the frame. Simply make a list of the keys that need to be
    -- bound, and bind them.

    local unique = {}

    for idx, entry in ipairs(self.bindings) do
        if entry.key then
            if shouldApply(global, entry) and self:IsBindingCorrectSpec(entry) then
                if global then
                    -- Allow for the re-binding of clicks and keys, except for
                    -- unmodified left/right-click
                    if entry.key ~= "BUTTON1" and entry.key ~= "BUTTON2" then
                        local prefix, suffix = self:GetBindingPrefixSuffix(entry, global)
                        local key = self:ConvertSpecialKeys(entry)

                        local attr = B_SET:format(key, suffix)
                        if not unique[attr] then
                            set[#set + 1] = attr
                            clr[#clr + 1] = B_CLR:format(key)
                            unique[attr] = true
                        end
                    end
                else
                    local buttonNum = entry.key:match("BUTTON(%d+)$")
                    if not buttonNum then
                        -- Only apply key-based binding clicks, let the raw
                        -- attributes handle the others
                        local prefix, suffix = self:GetBindingPrefixSuffix(entry, global)
                        local key = self:ConvertSpecialKeys(entry)

                        local attr = B_SET:format(key, suffix)
                        if not unique[attr] then
                            set[#set + 1] = attr
                            clr[#clr + 1] = B_CLR:format(key)
                            unique[attr] = true
                        end
                    end
                end
            end
        end
    end

    return table.concat(set, "\n"), table.concat(clr, "\n")
end

function addon:ClearAttributes()
    self.header:Execute([[
        for button, enabled in pairs(ccframes) do
            self:RunFor(button, self:GetAttribute("remove_clicks"))
        end
    ]])

    for button, enabled in pairs(self.ccframes) do
        -- Perform the setup of click bindings
        self.header:SetFrameRef("cliquesetup_button", button)
        self.header:Execute(self.header:GetAttribute("remove_clicks"), button)
    end

    -- Clear global attributes
    local globutton = self.globutton
    globutton:Execute(globutton.remove)
    globutton:Execute(globutton.clearbinds)
end

-- Recompute all attributes, so they can later be applied.
function addon:UpdateAttributes()
    local setup, remove = self:GetClickAttributes()
    self.header:SetAttribute("setup_clicks", setup)
    self.header:SetAttribute("remove_clicks", remove)

    local set, clr = self:GetBindingAttributes()
    self.header:SetAttribute("setup_onenter", set)
    self.header:SetAttribute("setup_onleave", clr)

    local globutton = self.globutton
    globutton.setup, globutton.remove = self:GetClickAttributes(true)
    globutton.setbinds, globutton.clearbinds = self:GetBindingAttributes(true)
end

function addon:ApplyAttributes()
    -- Handle all of the securely registered frames
    self.header:Execute([[
        for button, enabled in pairs(ccframes) do
            self:RunFor(button, self:GetAttribute("setup_clicks"))
        end
    ]])

    -- Now any compat frames that used the old method
    for button, enabled in pairs(self.ccframes) do
        -- Unwrap any existing enter/leave scripts
        self.header:UnwrapScript(button, "OnEnter")
        self.header:UnwrapScript(button, "OnLeave")
        self.header:WrapScript(button, "OnEnter", addon.header:GetAttribute("setup_onenter"))
        self.header:WrapScript(button, "OnLeave", addon.header:GetAttribute("setup_onleave"))

        -- Perform the setup of click bindings
        self.header:SetFrameRef("cliquesetup_button", button)
        self.header:Execute(self.header:GetAttribute("setup_clicks"), button)
    end

    -- Update the global button attributes
    self.globutton:Execute(self.globutton.setup)
    self.globutton:Execute(self.globutton.setbinds)
end


