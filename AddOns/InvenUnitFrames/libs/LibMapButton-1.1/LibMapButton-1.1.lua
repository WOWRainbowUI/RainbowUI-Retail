local MAJOR_VERSION = "LibMapButton-1.1"
local MINOR_VERSION = 2

--[[
라이브러리: LibMapButton-1.1
설명: 미니맵 버튼 생성 라이브러리.
제작자: Inven - InTheBlue
사용법:
	local LMB = LibStub("LibMapButton-1.1")
	LMB:CreateButton(owner, name, icon, angle, db)
		미니맵 버튼 생성
		owner: 애드온
		name: 미니맵 버튼 이름
		icon: 아이콘
		angle: 기본 앵글값 (디폴트: 183)
		db: 꼭 테이블로 선언되어 있을것
	LMB:SetTooltip(method or function)
		미니맵 툴팁 생성 함수 설정
	LMB:SetClick(method or function, button)
		클릭 함수 설정
]]

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local _G = _G
local type = _G.type
local rad = _G.math.rad
local sin = _G.math.sin
local cos = _G.math.cos
local max = _G.math.max
local min = _G.math.min
local deg = _G.math.deg
local atan2 = _G.math.atan2
local IsLoggedIn = _G.IsLoggedIn
local GetCursorPosition = _G.GetCursorPosition

lib.framelevel = max(MinimapBackdrop:GetFrameLevel(), lib.framelevel or 0)
lib.buttons = lib.buttons or {}

local minimapShapes = {
	["ROUND"] = { true, true, true, true },
	["SQUARE"] = { false, false, false, false },
	["CORNER-TOPLEFT"] = { true, false, false, false },
	["CORNER-TOPRIGHT"] = { false, false, true, false },
	["CORNER-BOTTOMLEFT"] = { false, true, false, false },
	["CORNER-BOTTOMRIGHT"] = { false, false, false, true },
	["SIDE-LEFT"] = { true, true, false, false },
	["SIDE-RIGHT"] = { false, false, true, true },
	["SIDE-TOP"] = { true, false, true, false },
	["SIDE-BOTTOM"] = { false, true, false, true },
	["TRICORNER-TOPLEFT"] = { true, true, true, false },
	["TRICORNER-TOPRIGHT"] = { true, false, true, true },
	["TRICORNER-BOTTOMLEFT"] = { true, true, false, true },
	["TRICORNER-BOTTOMRIGHT"] = { false, true, true, true },
}

local function updatePosition(button)
	local angle = rad(button.db.angle)
	local x, y = cos(angle), sin(angle)
	if minimapShapes[GetMinimapShape and GetMinimapShape() or "ROUND"][1 + (x < 0 and 1 or 0) + (y > 0 and 2 or 0)] then
		button:SetPoint("CENTER", Minimap, "CENTER", x * 80, y * 80)
	else
		button:SetPoint("CENTER", Minimap, "CENTER", max(-80, min(x * 103.13708498985, 80)), max(-80, min(y * 103.13708498985, 80)))
	end
end

local function toggle(button)
	if button.db.show then
		button:Show()
	else
		button:Hide()
	end
end

local function onMouseDown(button)
	button:LockHighlight()
	button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
end

local function onMouseUp(button)
	button:UnlockHighlight()
	button.icon:SetTexCoord(0, 1, 0, 1)
end


local function onUpdate(button)
	local mx, my = Minimap:GetCenter()
	local px, py = GetCursorPosition()
	local scale = Minimap:GetEffectiveScale()
	button.db.angle = deg(atan2(py / scale - my, px / scale - mx)) % 360
	updatePosition(button)
end

local function onDragStart(button)
	if button.db.dragable then
		onMouseDown(button)
		button.isMoving = true
		button:SetScript("OnUpdate", onUpdate)
		HideDropDownMenu(1)
		if LibStub("LibDropMenu-1.1", true) then
			LibStub("LibDropMenu-1.1"):CloseMenu(i)
		end
	end
end

local function onDragStop(button)
	if button.isMoving then
		onMouseUp(button)
		button:SetScript("OnUpdate", nil)
		button.isMoving = nil
	end
end

local function onEnter(button)
	GameTooltip:SetOwner(button, "ANCHOR_BOTTOMLEFT")
	if type(button.tooltipFunction) == "function" then
		button.tooltipFunction(button, GameTooltip)
	elseif button.tooltipFunction and button.owner[button.tooltipFunction] then
		button.owner[button.tooltipFunction](button, GameTooltip)
	end
	GameTooltip:Show()
end

local function onClick(button, click)
	if type(button.clickFunction) == "function" then
		button.clickFunction(button, button)
	elseif button.clickFunction and button.owner[button.clickFunction] then
		button.owner[button.clickFunction](button, click)
	end
end

local function onEvent(button)
	button:UnregisterEvent("PLAYER_LOGIN")
	updatePosition(button)
end

function lib:CreateButton(owner, name, icon, angle, db)
	if lib.buttons[owner] then return end
	lib.framelevel = lib.framelevel + 1
	lib.buttons[owner] = CreateFrame("Button", name, Minimap)
	lib.buttons[owner].db = db or {}
	if lib.buttons[owner].db.angle == nil then
		lib.buttons[owner].db.show = true
		lib.buttons[owner].db.dragable = true
		lib.buttons[owner].db.angle = angle or 183
	end
	lib.buttons[owner].owner = owner
	lib.buttons[owner]:SetFrameStrata("LOW")
	lib.buttons[owner]:SetFrameLevel(lib.framelevel)
	lib.buttons[owner]:SetWidth(33)
	lib.buttons[owner]:SetHeight(33)
	lib.buttons[owner]:SetPoint("CENTER")
	lib.buttons[owner]:EnableMouse(true)
	lib.buttons[owner]:RegisterForClicks("AnyUp")
	lib.buttons[owner]:RegisterForDrag("LeftButton", "RightButton")
	lib.buttons[owner]:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	lib.buttons[owner]:SetNormalTexture(icon)
	lib.buttons[owner].icon = lib.buttons[owner]:GetNormalTexture()
	lib.buttons[owner].icon:SetWidth(18)
	lib.buttons[owner].icon:SetHeight(18)
	lib.buttons[owner].icon:ClearAllPoints()
	lib.buttons[owner].icon:SetPoint("CENTER", -1, 2)
	lib.buttons[owner].icon:SetTexCoord(0, 1, 0, 1)
	lib.buttons[owner].border = lib.buttons[owner]:CreateTexture(name.."Border", "OVERLAY")
	lib.buttons[owner].border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	lib.buttons[owner].border:SetWidth(52)
	lib.buttons[owner].border:SetHeight(52)
	lib.buttons[owner].border:SetPoint("TOPLEFT")
	lib.buttons[owner]:SetScript("OnDragStart", onDragStart)
	lib.buttons[owner]:SetScript("OnDragStop", onDragStop)
	lib.buttons[owner]:SetScript("OnMouseDown", onMouseDown)
	lib.buttons[owner]:SetScript("OnMouseUp", onMouseUp)
	lib.buttons[owner]:SetScript("OnEvent", onEvent)
	if type(owner.OnClick) == "function" then
		lib:SetClick(owner, "OnClick")
	end
	if type(owner.OnTooltip) == "function" then
		lib:SetTooltip(owner, "OnTooltip")
	end
	lib.buttons[owner].UpdatePosition = updatePosition
	lib.buttons[owner].Toggle = toggle
	updatePosition(lib.buttons[owner])
	toggle(lib.buttons[owner])
	if not IsLoggedIn() then
		lib.buttons[owner]:RegisterEvent("PLAYER_LOGIN")
	end
end

function lib:SetTooltip(owner, method)
	if lib.buttons[owner] then
		lib.buttons[owner].tooltipFunction = method
		lib.buttons[owner]:SetScript("OnEnter", onEnter)
		lib.buttons[owner]:SetScript("OnLeave", GameTooltip_Hide)
	end
end

function lib:SetClick(owner, method)
	if lib.buttons[owner] then
		lib.buttons[owner].clickFunction = method
		lib.buttons[owner]:SetScript("OnClick", onClick)
	end
end

function lib:GetButton(owner)
	return lib.buttons[owner]
end