-- StaggerBarReskin.lua
-- Applies custom LSM statusbar texture to the Brewmaster Monk stagger bar (PRD)
-- Preserves Blizzard's native green / yellow / red stagger color stages
-- When Alternate Power Bar Gradient is enabled, that system handles texture instead

local LSM = LibStub("LibSharedMedia-3.0", true)
if not LSM then return end

local function GetProfile()
    return PersonalResourceReskin and PersonalResourceReskin.db and PersonalResourceReskin.db.profile
end

local function ApplyStaggerTexture(bar)
    local profile = GetProfile()
    if not profile then return end
    -- When gradient is enabled for MONK, the gradient system handles texture + colors
    local gVal = (profile.altPowerGradientEnabled or {})["MONK"]
    -- Default OFF for Monk; only skip when explicitly enabled
    if gVal == true then return end
    local tex = LSM:Fetch("statusbar", profile.altTexture or profile.texture)
    if tex and bar.SetStatusBarTexture then
        bar:SetStatusBarTexture(tex)
    end
end

-- Hook MonkAlternatePowerBarMixin:UpdateArt so custom texture persists
-- after Blizzard resets it on every stagger value/state change
local hooked = false
local function TryHook()
    if hooked or not MonkAlternatePowerBarMixin then return end
    hooked = true
    hooksecurefunc(MonkAlternatePowerBarMixin, "UpdateArt", function(self)
        ApplyStaggerTexture(self)
    end)
end

TryHook()
if not hooked then
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self)
        TryHook()
        self:UnregisterAllEvents()
    end)
end
