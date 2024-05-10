local actionBarHookSet = false

local function experimentalFixPaddingMinSetting()
  -- Set icon padding to 0
  -- EditModePresetLayoutManager:GetModernSystemMap()[Enum.EditModeSystem.ActionBar][
  -- 	 Enum.EditModeActionBarSystemIndices.MainBar]["settings"][4] = 0
  -- -- verify value
  -- for key, value in pairs(EditModePresetLayoutManager:GetModernSystemMap()[Enum.EditModeSystem.ActionBar][
  -- 	Enum.EditModeActionBarSystemIndices.MainBar]["settings"]) do
  -- 	print("Key: ", key, " Value: ", value)
  -- end
  -- EditModeSettingDisplayInfoManager.systemSettingDisplayInfo[Enum.EditModeSystem.ActionBar][5] = {
  -- 	minValue = 0,
  -- }

  -- local kiddos = { MainMenuBar:GetChildren() };
  -- for _, child in ipairs(kiddos) do
  -- 	if child.SetPadding ~= nil then
  -- 		 print(child:GetName(), " can set padding!")
  -- 	else
  -- 		print(child:GetName(), " can't set padding :(")
  -- 		local grand_kiddos = { child:GetChildren() };
  -- 		for _, grand_child in ipairs(grand_kiddos) do

  -- 			if grand_child.SetPadding ~= nil then
  -- 				 print(grand_child:GetName(), " can set padding!")
  -- 			else
  -- 				print(grand_child:GetName(), " can't set padding :(")
  -- 			end
  -- 		end
  -- 	end
  -- end

  local layout
  if true then
    layout = GridLayoutUtil.CreateStandardGridLayout(stride, buttonPadding, buttonPadding, xMultiplier, yMultiplier);
  else
    layout = GridLayoutUtil.CreateVerticalGridLayout(stride, buttonPadding, buttonPadding, xMultiplier, yMultiplier);
  end
end

local function setButtonPaddingOnActionBar(actionBar, padding)
  if padding < actionBar.minButtonPadding then
    actionBar.minButtonPadding = padding
  end
  actionBar.buttonPadding = padding

  if actionBar.UpdateGridLayout then
    actionBar:UpdateGridLayout()
  end
end

local function actionBar_OnUpdate(self, arg1, ...)
  if self.minButtonPadding ~= 0 then
    self.minButtonPadding = 0
    self.buttonPadding = 0
    -- Call show to make the changes take effect visually
    -- self:Show()
  end
end

local function disableBorderOnActionBar(actionBarName)
  for i = 0, 12 do
    local button = _G[actionBarName .. "Button" .. i]
    if button then
      button:DisableDrawLayer("OVERLAY")
    end
  end
end

local function enableBorderOnActionBar(actionBarName)
  for i = 0, 12 do
    local button = _G[actionBarName .. "Button" .. i]
    if button then
      button:EnableDrawLayer("OVERLAY")
    end
  end
end

function BUII_ActionBarsImprovedNoPaddingEnable()
  -- if not actionBarHookSet then
  -- 	StanceBar:HookScript("OnUpdate", actionBar_OnUpdate)
  -- 	MainMenuBar:HookScript("OnUpdate", actionBar_OnUpdate)
  -- 	MultiBarLeft:HookScript("OnUpdate", actionBar_OnUpdate)
  -- 	MultiBarRight:HookScript("OnUpdate", actionBar_OnUpdate)
  -- 	MultiBarBottomLeft:HookScript("OnUpdate", actionBar_OnUpdate)
  -- 	MultiBarBottomRight:HookScript("OnUpdate", actionBar_OnUpdate)
  -- 	actionBarHookSet = true
  -- end

  experimentalFixPaddingMinSetting()

  -- BUIIDatabase["no_action_bar_padding"] = true

  -- setButtonPaddingOnActionBar(StanceBar, 0)
  -- setButtonPaddingOnActionBar(MainMenuBar, 0)
  -- setButtonPaddingOnActionBar(MultiBarLeft, 0)
  -- setButtonPaddingOnActionBar(MultiBarRight, 0)
  -- setButtonPaddingOnActionBar(MultiBarBottomLeft, 0)
  -- setButtonPaddingOnActionBar(MultiBarBottomRight, 0)

  -- disableBorderOnActionBar("Stance")
  -- disableBorderOnActionBar("Action")
  -- disableBorderOnActionBar("MultiBarLeft")
  -- disableBorderOnActionBar("MultiBarRight")
  -- disableBorderOnActionBar("MultiBarBottomLeft")
  -- disableBorderOnActionBar("MultiBarBottomRight")
end

function BUII_ActionBarsImprovedNoPaddingDisable()
  BUIIDatabase["no_action_bar_padding"] = false
  -- enableBorderOnActionBar("Stance")
  -- enableBorderOnActionBar("Action")
  -- enableBorderOnActionBar("MultiBarLeft")
  -- enableBorderOnActionBar("MultiBarRight")
  -- enableBorderOnActionBar("MultiBarBottomLeft")
  -- enableBorderOnActionBar("MultiBarBottomRight")
end
