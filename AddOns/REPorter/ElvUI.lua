if ElvUI then
  local E = unpack(ElvUI)
  local S = E:GetModule("Skins")

  local function Skin_REPorter()
    REPorterFrameBorder:StripTextures()
    S:HandleFrame(REPorterFrameBG, true)
    REPorterFrameBG:SetOutside(nil, 2, 2)
    REPorterFrameBorderResize:Point("BOTTOMRIGHT", REPorterFrameBorder, "BOTTOMRIGHT", 2, -2)
  end

  S:AddCallbackForAddon("REPorter", "REPorter", Skin_REPorter)
end
