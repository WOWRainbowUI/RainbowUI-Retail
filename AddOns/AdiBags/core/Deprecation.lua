local addonName = ...
---@class AdiBags: ABEvent-1.0
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

-- This is a deprecation message for AdiBags. To remove this for whatever reason,
-- remove this call from Core.lua in OnInitialize.
function addon:Deprecation()
  if addon.db.profile.deprecationPhase < 2 then
    print("AdiBags 已經被捨棄，不會再有新的功能更新。")
    print("請考慮轉換到 AdiBags 的續作 BetterBags (掰特包)。")
    print("您可以在 Curse、Wago 和 github.com/Cidan/BetterBags 上找到 BetterBags。")
    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    frame:SetBackdrop({
      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      tile = true,
      tileSize = 16,
      edgeSize = 16,
      insets = { left = 4, right = 0, top = 4, bottom = 4 }
    })
    frame:SetBackdropColor(0, 0, 0, 0.9)
    frame:SetPoint("LEFT", 30, 0)
    frame:SetSize(440, 300)
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    text:SetTextColor(1, 1, 1, 1)
    text:SetPoint("LEFT", 20, 0)
    text:SetJustifyH("LEFT")
    text:SetText([[
AdiBags 已經被捨棄，不會再有新的功能更新，並且可能不會修復日後所產生的錯誤。
請考慮轉換到 AdiBags 的續作 BetterBags (掰特包)。
BetterBags 是由與 AdiBags 相同的維護團隊所開發。
您可以在 Curse、Wago 和 github.com/Cidan/BetterBags 上找到 BetterBags。
雖然這則訊息不會再次顯示，但只要還能運作，您仍然可以繼續使用 AdiBags。
謝謝! :)
      ]])
    text:SetWordWrap(true)
    text:SetWidth(400)
    --frame:SetSize(text:GetStringWidth()+ 40, 200)

    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button:SetSize(180, 25)
    button:SetPoint("BOTTOM", 0, 10)
    button:SetText("不要再次顯示")
    button:SetScript("OnClick", function()
      addon.db.profile.deprecationPhase = 2
      frame:Hide()
    end)
    frame:Show()
  end
end
