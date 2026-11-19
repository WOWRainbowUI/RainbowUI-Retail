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

local QuartzStatusBar = CreateFrame("StatusBar")
local MetaTable = {__index = QuartzStatusBar}

QuartzStatusBar.__rotatesTexture = 1

function Quartz3:CreateStatusBar(name, parent)
	local bar = setmetatable(CreateFrame("StatusBar", name, parent, "BackdropTemplate"), MetaTable)
	
	bar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	
	bar:SetMinMaxValues(0, 100)
	bar:SetValue(0)
	
	hooksecurefunc(bar, "SetOrientation", function(self, orientation)
		if self.__rotatesTexture then
			local tex = self:GetStatusBarTexture()
			if tex then tex:SetRotated(orientation == "VERTICAL") end
		end
	end)
	
	return bar
end

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

function Quartz3:CreateImportantOverlay(host)
	local overlay = CreateFrame("StatusBar", nil, host)
	overlay:SetAllPoints(host)
	overlay:SetFrameLevel(host:GetFrameLevel() + 1)
	overlay:SetMinMaxValues(0, 1)
	overlay:Hide()
	hooksecurefunc(host, "SetMinMaxValues", function(_, ...) overlay:SetMinMaxValues(...) end)
	hooksecurefunc(host, "SetValue", function(_, ...) overlay:SetValue(...) end)
	if host.SetTimerDuration then
		hooksecurefunc(host, "SetTimerDuration", function(_, ...) overlay:SetTimerDuration(...) end)
	end
	-- Re-setting the texture is how the host reclaims value control after a native timer; the overlay needs the same with its own texture.
	hooksecurefunc(host, "SetStatusBarTexture", function()
		if overlay.textureFile then
			overlay:SetStatusBarTexture(overlay.textureFile)
		end
	end)
	host.ImportantOverlay = overlay
	return overlay
end

function Quartz3:SetImportantOverlay(host, isImportant, textureFile, notInterruptible, importantColor, importantNoInterruptColor)
	local overlay = host.ImportantOverlay
	if not overlay then return end
	if issecretvalue(isImportant) or isImportant then
		if overlay.textureFile ~= textureFile then
			overlay.textureFile = textureFile
			overlay:SetStatusBarTexture(textureFile)
		end
		overlay:SetStatusBarColor(1, 1, 1, 1)
		overlay:GetStatusBarTexture():SetVertexColorFromBoolean(notInterruptible, importantNoInterruptColor, importantColor)
		overlay:Show()
		overlay:SetAlphaFromBoolean(isImportant, 1, 0)
	else
		overlay:Hide()
	end
end
