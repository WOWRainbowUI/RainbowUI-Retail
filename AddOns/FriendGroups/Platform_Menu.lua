-- Context menus: Compat.OpenContextMenu forwards to MenuUtil.CreateContextMenu, or renders
-- the same generator through a UIDropDownMenu polyfill where the Menu API is absent.

local addonName, addonTable = ...
local Compat = addonTable.Compat

-- [[ RETAIL PASS-THROUGH ]]
if Compat.HAS_MENU_API then
	function Compat.OpenContextMenu(owner, generator)
		return MenuUtil.CreateContextMenu(owner, generator)
	end
	return
end

-- [[ CLASSIC POLYFILL ]] Every node shares one metatable so submenus get the root's builders.

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

-- Takes a boolean or a function, like Blizzard's; the function is read at render time.
function NodeMixin:SetEnabled(enabled)
	self.enabled = enabled
	return self
end

local function NodeIsEnabled(node)
	local enabled = node.enabled
	if enabled == nil then return true end
	if type(enabled) == "function" then return enabled(node) and true or false end
	return enabled and true or false
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

			if not NodeIsEnabled(child) then
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
