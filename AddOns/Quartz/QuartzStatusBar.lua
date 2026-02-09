--[[
	Copyright (C) 2006-2007 Nymbia
	Copyright (C) 2010-2017 Hendrik "Nevcairiel" Leppkes < h.leppkes@gmail.com >

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
]]
local Quartz3 = LibStub("AceAddon-3.0"):GetAddon("Quartz3")

-- Use native StatusBar prototype to allow method lookup via __index
-- We use a real StatusBar so that if we add custom methods to it, they are found
local QuartzStatusBar = CreateFrame("StatusBar")
local MetaTable = {__index = QuartzStatusBar}

QuartzStatusBar.__rotatesTexture = 1

function Quartz3:CreateStatusBar(name, parent)
	local bar = setmetatable(CreateFrame("StatusBar", name, parent, "BackdropTemplate"), MetaTable)
	
	-- Use native texture setting
	-- Note: Native SetStatusBarTexture expects a path/ID usually
	bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	
	bar:SetMinMaxValues(0, 100)
	bar:SetValue(0)
	
	-- Hook SetOrientation to handle texture rotation if enabled (Quartz feature)
	hooksecurefunc(bar, "SetOrientation", function(self, orientation)
		if self.__rotatesTexture then
			local tex = self:GetStatusBarTexture()
			if tex then tex:SetRotated(orientation == "VERTICAL") end
		end
	end)
	
	return bar
end

-- Custom methods found via __index
function QuartzStatusBar:GetRotatesTexture()
	return self.__rotatesTexture
end

function QuartzStatusBar:SetRotatesTexture(rotate)
	self.__rotatesTexture = rotate and 1 or nil
	local tex = self:GetStatusBarTexture()
	if tex then
		tex:SetRotated(rotate and self:GetOrientation() == "VERTICAL")
	end
end

-- Native methods (SetMinMaxValues, SetValue, SetStatusBarColor, SetTimerDuration) 
-- are called directly on the instance (bar) and do not go through __index
