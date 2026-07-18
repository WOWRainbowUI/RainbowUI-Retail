--[[
	FriendGroups - Platform_Menu.lua
	============================================================================
	Context-menu adapter. Loaded after Compat.lua, before FriendGroups.lua.

	Menu API present (every shipping flavor, probed 2026-07: retail 12.0.7,
	    MoP 5.5.4, BC Anniversary 2.5.6) : Compat.OpenContextMenu is a
	    pass-through to MenuUtil.CreateContextMenu, byte-identical to retail.
	Menu API absent (no current client -- safety net only) : a lightweight
	    polyfill implements exactly the subset of the rootDescription API that
	    FriendGroups uses (CreateTitle / CreateButton / CreateDivider /
	    CreateCheckbox / SetEnabled / SetTooltip, incl. nested submenus) on top
	    of the legacy UIDropDownMenu.

	The point of the polyfill is single-source menu content: the SAME generator
	closures that build the modern menus would build the fallback menus, so the
	two paths can never drift.

	API compliance:
	  - Retail  : MenuUtil.CreateContextMenu (WoW 12.0.7).
	  - Classic : UIDropDownMenu_CreateInfo / _AddButton / _Initialize,
	              ToggleDropDownMenu (MoP Classic 5.5.4).
	Only documented globals are referenced, each guarded before use.
]] --

local addonName, addonTable = ...
local Compat = addonTable.Compat

-- ============================================================================
-- [[ RETAIL PASS-THROUGH ]]
-- On retail the native Menu system exists; OpenContextMenu is a thin forward so
-- the call sites read uniformly on both flavors while retail behavior is exactly
-- MenuUtil.CreateContextMenu(owner, generator).
-- ============================================================================
if Compat.HAS_MENU_API then
	function Compat.OpenContextMenu(owner, generator)
		return MenuUtil.CreateContextMenu(owner, generator)
	end
	return
end

-- ============================================================================
-- [[ CLASSIC POLYFILL ]]
-- A description node accumulates children; the generator builds a tree, then the
-- tree is rendered into a UIDropDownMenu. Every node shares one metatable so
-- submenus support the same builder methods as the root.
-- ============================================================================

local NodeMixin = {}
local NodeMeta = { __index = NodeMixin }

local function NewNode()
	return setmetatable({ children = {} }, NodeMeta)
end

function NodeMixin:CreateTitle(text)
	local node = NewNode()
	node.kind = "title"
	node.text = text
	table.insert(self.children, node)
	return node
end

function NodeMixin:CreateDivider()
	local node = NewNode()
	node.kind = "divider"
	table.insert(self.children, node)
	return node
end

-- CreateButton(text) with no func is a submenu container; children are added to
-- the returned node. CreateButton(text, func) is a leaf action.
function NodeMixin:CreateButton(text, func)
	local node = NewNode()
	node.kind = "button"
	node.text = text
	node.func = func
	table.insert(self.children, node)
	return node
end

function NodeMixin:CreateCheckbox(text, isChecked, onClick)
	local node = NewNode()
	node.kind = "checkbox"
	node.text = text
	node.isChecked = isChecked
	node.onClick = onClick
	table.insert(self.children, node)
	return node
end

function NodeMixin:SetEnabled(enabled)
	self.disabled = not enabled
	return self
end

function NodeMixin:SetTooltip(fn)
	self.tooltipFn = fn
	return self
end

-- Add a visual separator, using the native helper when the client provides it
-- and a disabled spacer otherwise (no assumption about its availability).
local function AddSeparator(level)
	if type(UIDropDownMenu_AddSeparator) == "function" then
		UIDropDownMenu_AddSeparator(level)
	else
		local info = UIDropDownMenu_CreateInfo()
		info.text = ""
		info.notClickable = true
		info.notCheckable = true
		info.disabled = true
		UIDropDownMenu_AddButton(info, level)
	end
end

local function RenderNode(node, level)
	for _, child in ipairs(node.children) do
		if child.kind == "divider" then
			AddSeparator(level)
		else
			local info = UIDropDownMenu_CreateInfo()
			info.text = child.text

			if child.kind == "title" then
				info.isTitle = 1
				info.notCheckable = 1
			elseif child.kind == "checkbox" then
				info.notCheckable = false
				info.isNotRadio = true
				info.keepShownOnClick = true
				-- Function form so keepShownOnClick refreshes re-read the state.
				info.checked = child.isChecked
				info.func = function()
					if child.onClick then child.onClick() end
				end
			else
				-- button: submenu container when it has children, else a leaf action
				info.notCheckable = 1
				if #child.children > 0 then
					info.hasArrow = true
					info.value = child
				else
					info.func = function()
						if child.func then child.func() end
					end
				end
			end

			if child.disabled then
				info.disabled = true
			end

			if child.tooltipFn then
				info.funcOnEnter = function(button)
					GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
					child.tooltipFn(GameTooltip)
					GameTooltip:Show()
				end
				info.funcOnLeave = function()
					GameTooltip:Hide()
				end
			end

			UIDropDownMenu_AddButton(info, level)
		end
	end
end

local menuFrame

function Compat.OpenContextMenu(owner, generator)
	local root = NewNode()
	generator(owner, root)

	if not menuFrame then
		menuFrame = CreateFrame("Frame", "FriendGroupsCompatContextMenu", UIParent, "UIDropDownMenuTemplate")
	end

	UIDropDownMenu_Initialize(menuFrame, function(self, level)
		if not level then return end
		if level == 1 then
			RenderNode(root, level)
		else
			local parent = UIDROPDOWNMENU_MENU_VALUE
			if type(parent) == "table" and parent.children then
				RenderNode(parent, level)
			end
		end
	end, "MENU")

	ToggleDropDownMenu(1, nil, menuFrame, "cursor", 0, 0)
end
