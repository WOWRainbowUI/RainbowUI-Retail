---@class addonTablePlatynator
local addonTable = select(2, ...)

local cvars = {
  ["nameplateMaxAlpha"] = "1",
  ["nameplateMaxAlphaDistance"] = "40",
  ["nameplateMinAlpha"] = "0.6",
  ["nameplateMinAlphaDistance"] = "-100000",
  ["nameplateMaxDistance"] = "60",
  ["nameplatePlayerMaxDistance"] = "60",
  ["nameplateMaxScale"] = "1",
  ["nameplateMinScale"] = "1",
  ["nameplateMotionSpeed"] = "0.025",
  ["nameplateTargetBehindMaxDistance"] = "30",
  ["nameplateTargetRadialPosition"] = "1",
  ["nameplateNotSelectedAlpha"] = "-1",
  ["nameplateOverlapH"] = "1",
  ["nameplateOverlapV"] = "1",
}


function addonTable.Display.SetCVars()
  if not addonTable.Config.Get(addonTable.Config.Options.APPLY_CVARS) then
    return
  end
  for name, value in pairs(cvars) do
    if C_CVar.GetCVarInfo(name) then
      C_CVar.SetCVar(name, value)
    end
  end
end
