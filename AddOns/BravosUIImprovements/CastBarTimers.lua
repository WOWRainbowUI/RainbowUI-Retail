local castBarTimersInitialized = false

local function createChildTimerFrame(parent, xOffset, yOffset)
  local timerFrame = CreateFrame("Frame", "BUIICastBarTimer" .. parent:GetName(), parent)
  timerFrame:SetWidth(1)
  timerFrame:SetHeight(1)
  timerFrame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xOffset, yOffset)
  timerFrame.text = timerFrame:CreateFontString(nil, "ARTWORK")
  timerFrame.text:SetFont(STANDARD_TEXT_FONT, 16, "") -- 法術時間文字大小
  timerFrame.text:SetPoint("CENTER", 0, 0)
end

local function realignSpellNameText()
  TargetFrameSpellBar.Text:SetJustifyH("LEFT")
  FocusFrameSpellBar.Text:SetJustifyH("LEFT")
  PlayerCastingBarFrame.Text:SetJustifyH("LEFT")

  PlayerCastingBarFrame.Text:SetPoint("TOPLEFT", PlayerCastingBarFrame, "TOPLEFT", 5, -10)
  PlayerCastingBarFrame.Text:SetPoint("TOPRIGHT", PlayerCastingBarFrame, "TOPRIGHT", -30, -10)
  TargetFrameSpellBar.Text:SetPoint("TOPLEFT", TargetFrameSpellBar, "TOPLEFT", 5, -8)
  TargetFrameSpellBar.Text:SetPoint("TOPRIGHT", TargetFrameSpellBar, "TOPRIGHT", -25, -8)
  FocusFrameSpellBar.Text:SetPoint("TOPLEFT", FocusFrameSpellBar, "TOPLEFT", 5, -8)
  FocusFrameSpellBar.Text:SetPoint("TOPRIGHT", FocusFrameSpellBar, "TOPRIGHT", -25, -8)
end

local function restoreSpellNameText()
  TargetFrameSpellBar.Text:SetJustifyH("CENTER")
  FocusFrameSpellBar.Text:SetJustifyH("CENTER")
  PlayerCastingBarFrame.Text:SetJustifyH("CENTER")

  PlayerCastingBarFrame.Text:ClearAllPoints()
  PlayerCastingBarFrame.Text:SetPoint("TOP", PlayerCastingBarFrame, "TOP", 0, -10)
  TargetFrameSpellBar.Text:ClearAllPoints()
  TargetFrameSpellBar.Text:SetPoint("TOPLEFT", TargetFrameSpellBar, "TOPLEFT", 0, -8)
  TargetFrameSpellBar.Text:SetPoint("TOPRIGHT", TargetFrameSpellBar, "TOPRIGHT", 0, -8)
  FocusFrameSpellBar.Text:ClearAllPoints()
  FocusFrameSpellBar.Text:SetPoint("TOPLEFT", FocusFrameSpellBar, "TOPLEFT", 0, -8)
  FocusFrameSpellBar.Text:SetPoint("TOPRIGHT", FocusFrameSpellBar, "TOPRIGHT", 0, -8)
end

local function setTimerText(castBarFrame, timerTextFrame)
  local timeLeft = nil;
  if (castBarFrame.casting) then
    timeLeft = castBarFrame.maxValue - castBarFrame:GetValue();
  elseif (castBarFrame.channeling) then
    timeLeft = castBarFrame:GetValue()
  end
  if (timeLeft) then
    timeLeft = (timeLeft < 0.1) and 0.01 or timeLeft;
    timerTextFrame.text:SetText(string.format("%.1f", timeLeft))
  end
end

local function handlePlayerCastBar_OnUpdate(self, ...)
  setTimerText(self, _G["BUIICastBarTimerPlayerCastingBarFrame"])
end

local function handleTargetSpellBar_OnUpdate(self, ...)
  setTimerText(self, _G["BUIICastBarTimerTargetFrameSpellBar"])
end

local function handleFocusSpellBar_OnUpdate(self, ...)
  setTimerText(self, _G["BUIICastBarTimerFocusFrameSpellBar"])
end

function BUII_CastBarTimersEnable()
  if not castBarTimersInitialized then
    createChildTimerFrame(PlayerCastingBarFrame, -14, -17)
    PlayerCastingBarFrame:HookScript("OnUpdate", handlePlayerCastBar_OnUpdate)
    createChildTimerFrame(TargetFrameSpellBar, -12, -16)
    TargetFrameSpellBar:HookScript("OnUpdate", handleTargetSpellBar_OnUpdate)
    createChildTimerFrame(FocusFrameSpellBar, -12, -16)
    FocusFrameSpellBar:HookScript("OnUpdate", handleFocusSpellBar_OnUpdate)
    castBarTimersInitialized = true
  end

  -- Prevent the text from flowing into the castbar timer
  realignSpellNameText()

  _G["BUIICastBarTimerPlayerCastingBarFrame"]:Show()
  _G["BUIICastBarTimerTargetFrameSpellBar"]:Show()
  _G["BUIICastBarTimerFocusFrameSpellBar"]:Show()
end

function BUII_CastBarTimersDisable()
  if castBarTimersInitialized then
    restoreSpellNameText()
    _G["BUIICastBarTimerPlayerCastingBarFrame"]:Hide()
    _G["BUIICastBarTimerTargetFrameSpellBar"]:Hide()
    _G["BUIICastBarTimerFocusFrameSpellBar"]:Hide()
  end
end
