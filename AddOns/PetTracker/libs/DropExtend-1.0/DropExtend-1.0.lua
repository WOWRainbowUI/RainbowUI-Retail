--[[
Copyright 2023 João Cardoso
DropExtend is distributed under the terms of the GNU General Public License (or the Lesser GPL).
This file is part of DropExtend.

DropExtend is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

DropExtend is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with DropExtend. If not, see <http://www.gnu.org/licenses/>.
--]]

local Lib = LibStub:NewLibrary('DropExtend-1.0', 1)
if not Lib then
    return
elseif not Lib.timers then
    hooksecurefunc('UIDropDownMenu_Initialize', function(f) Lib:OnUIDropdownMenu(f) end)
    Lib.callbacks, Lib.timers = {}, {}
end

local function Always() return true end
local function SetGlobalMouse(parent)
	parent.HandlesGlobalMouseEvent = parent.HandlesGlobalMouseEvent or Always

	for _, child in pairs{parent:GetChildren()} do
		SetGlobalMouse(child)
	end
end


--[[ Methods ]]--

function Lib:Hook(owner, callback)
    if not self.callbacks[owner] then
		hooksecurefunc(owner, 'initialize', function(...) Lib:OnHookedDropdown(...) end)
        self.callbacks[owner] = {}
	end

	tinsert(self.callbacks[owner], callback)
end

function Lib:OnUIDropdownMenu(owner)
    if not self.callbacks[owner] then
        for level = 1, UIDROPDOWNMENU_MAXLEVELS do
            local timer = self.timers[level]
            if timer then
                timer.cancel = true
            end
        end
    end
end

function Lib:OnHookedDropdown(owner, level, ...)
    local list = _G['DropDownList' .. level]
    local extensions = {}

    for _, call in ipairs(self.callbacks[owner]) do
        local frame = call(level, ...)
        if frame then
            frame:Show()
            frame:SetParent(list)
            tinsert(extensions, frame)
        end
    end

    local timer = self.timers[level] or C_Timer.NewTicker(0.01, self:OnTick(level))
    timer.top = list:GetHeight() - 15
    timer.extensions = extensions
    timer.cancel = nil

    self.timers[level] = timer
end

function Lib:OnTick(level)
    return function()
        local timer = self.timers[level]
        if not timer.cancel and _G['DropDownList' .. level]:IsVisible() then
            local offset = timer.top
            for _, frame in ipairs(timer.extensions) do
                frame:SetPoint('TOPLEFT', 0, -offset)
                offset = offset + frame:GetHeight()
                SetGlobalMouse(frame)
            end

            _G['DropDownList' .. level .. 'MenuBackdrop']:SetPoint('BOTTOM', 0,timer.top-offset)
            _G['DropDownList' .. level .. 'Backdrop']:SetPoint('BOTTOM', 0,timer.top-offset)
        else
            timer:Cancel()
            for _, frame in ipairs(timer.extensions) do
                frame:Hide()
            end

            _G['DropDownList' .. level .. 'MenuBackdrop']:SetPoint('BOTTOM')
            _G['DropDownList' .. level .. 'Backdrop']:SetPoint('BOTTOM')
            self.timers[level] = nil
        end
    end
end