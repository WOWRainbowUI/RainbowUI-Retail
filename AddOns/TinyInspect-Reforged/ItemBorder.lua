
local LibEvent = LibStub:GetLibrary("LibEvent.7000")

local function SetItemAngularBorder(self, quality, itemIDOrLink)
    if (not self) then return end
    if (not self.angularFrame) then
        local anchor, w, h = self.IconBorder or self, self:GetSize()
        local ww, hh = anchor:GetSize()
        if (ww == 0 or hh == 0) then
            anchor = self.Icon or self.icon or self
            w, h = anchor:GetSize()
        else
            w, h = min(w, ww), min(h, hh)
        end
        if (w > h * 1.28) then
            w = h
        end
        self.angularFrame = CreateFrame("Frame", nil, self)
        self.angularFrame:SetFrameLevel(5)
        self.angularFrame:SetSize(w, h)
        self.angularFrame:SetPoint("CENTER", anchor, "CENTER", 0, 0)
        self.angularFrame:Hide()
        self.angularFrame.mask = CreateFrame("Frame", nil, self.angularFrame, BackdropTemplateMixin and "BackdropTemplate" or nil)
        self.angularFrame.mask:SetSize(w-2, h-2)
        self.angularFrame.mask:SetPoint("CENTER")
        self.angularFrame.mask:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeSize = 2})
        self.angularFrame.mask:SetBackdropBorderColor(0, 0, 0)
        self.angularFrame.border = CreateFrame("Frame", nil, self.angularFrame, BackdropTemplateMixin and "BackdropTemplate" or nil)
        self.angularFrame.border:SetSize(w, h)
        self.angularFrame.border:SetPoint("CENTER")
        self.angularFrame.border:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
    end
    if (TinyInspectReforgedDB and TinyInspectReforgedDB.ShowItemBorder) then
        LibEvent:trigger("SET_ITEM_ANGULARBORDER", self.angularFrame, quality, itemIDOrLink)
    else
        self.angularFrame:Hide()
    end
end

hooksecurefunc("SetItemButtonQuality", function(self, quality, itemIDOrLink, suppressOverlays)
    SetItemAngularBorder(self, quality, itemIDOrLink)
end)

LibEvent:attachEvent("ADDON_LOADED", function(self, addonName)
    if (addonName == "Blizzard_InspectUI") then
        hooksecurefunc("InspectPaperDollItemSlotButton_Update", function(self)
            local textureName = GetInventoryItemTexture(InspectFrame.unit, self:GetID())
            if (not textureName) then SetItemAngularBorder(self, false) end
        end)
    end
end)

LibEvent:attachTrigger("SET_ITEM_ANGULARBORDER", function(self, frame, quality, itemIDOrLink)
    if (quality) then
        local r, g, b = GetItemQualityColor(quality)
        if (quality <= 1) then
            r = r - 0.3
            g = g - 0.3
            b = b - 0.3
        end
        frame.border:SetBackdropBorderColor(r, g, b)
        frame:Show()
    else
        frame:Hide()
    end
end)

local RankFrame = CharacterNeckSlot and CharacterNeckSlot.RankFrame
if (RankFrame) then
    RankFrame:SetFrameLevel(8)
    RankFrame.Texture:Hide()
    RankFrame:SetPoint("CENTER", CharacterNeckSlot, "BOTTOM", 0, 8)
    local fontFile, fontSize, fontFlags = TextStatusBarText:GetFont()
    RankFrame.Label:SetFont(fontFile, fontSize, "THINOUTLINE")
    RankFrame.Label:SetTextColor(0, 0.9, 0.9)
end
