local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class ExalityFramesButton
local button = EXFrames:GetFrame('button')

---@class ExalityFramesEditBoxInput
local editBox = EXFrames:GetFrame('edit-box-input')

---@class ExalityFramesInputDialogFrame
local inputDialog = EXFrames:GetFrame('input-dialog-frame')

inputDialog.Init = function(self)
  self.pool = CreateFramePool('Frame', UIParent)
end

local function ConfigureFrame(f)
  f:SetSize(300, 90)
  f:SetPoint('TOP', 0, -200)
  f:SetFrameStrata('DIALOG')
  f:SetFrameLevel(10)
  f:SetClampedToScreen(true)
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag('LeftButton')
  f:SetScript('OnDragStart', function(self)
    self:StartMoving()
  end)
  f:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
  end)

  f.fadeIn = EXFrames.utils.animation.fade(f, 0.2, 0, 1)
  f.fadeOut = EXFrames.utils.animation.fade(f, 0.2, 1, 0)
  f.fadeOut:SetScript('OnFinished', function() f:Hide() end)
  EXFrames.utils.animation.diveIn(f, 0.2, 0, 20, 'IN', f.fadeIn)
  EXFrames.utils.animation.diveIn(f, 0.2, 0, -20, 'OUT', f.fadeOut)

  local background = f:CreateTexture(nil, 'BACKGROUND')
  background:SetTexture(EXFrames.assets.textures.window.bg)
  background:SetVertexColor(0, 0, 0, 0.8)
  background:SetTexCoord(7 / 512, 505 / 512, 7 / 512, 505 / 512)
  background:SetTextureSliceMargins(15, 15, 15, 15)
  background:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
  background:SetAllPoints()

  local editBox = editBox:Create({}, f)
  f.editBox = editBox
  editBox:SetHeight(40)
  editBox:SetPoint('TOPLEFT', 5, -5)
  editBox:SetPoint('TOPRIGHT', -5, -5)

  local cancelButton = button:Create({
    color = { 128 / 255, 17 / 255, 0, 1 }
  }, f)
  cancelButton:SetText('Cancel')
  cancelButton:SetOnClick(function()
    f:HideDialog()
  end)
  cancelButton:SetPoint('BOTTOMLEFT', f, 'BOTTOM', 5, 5)
  cancelButton:SetPoint('BOTTOMRIGHT', -5, 5)

  f.cancelButton = cancelButton

  local successButton = button:Create({
    color = { 44 / 255, 145 / 255, 0, 1 }
  }, f)
  successButton:SetText('OK')
  successButton:SetOnClick(function()
    local value = f.editBox:GetEditorValue()
    if (f.onSuccess) then
      f.onSuccess(value)
    end
    f:HideDialog()
  end)
  successButton:SetPoint('BOTTOMLEFT', 5, 5)
  successButton:SetPoint('BOTTOMRIGHT', f, 'BOTTOM', -5, 5)

  f.successButton = successButton

  f.ShowDialog = function(self)
    self:Show()
    self.fadeIn:Play()
  end

  f.HideDialog = function(self)
    self.fadeOut:Play()
  end

  f.SetLabel = function(self, label)
    self.editBox:SetLabel(label)
  end

  f.SetSuccessButtonText = function(self, text)
    self.successButton:SetText(text)
  end

  f.SetCancelButtonText = function(self, text)
    self.cancelButton:SetText(text)
  end

  f.SetOnSuccess = function(self, onSuccess)
    self.onSuccess = onSuccess
  end
end

---Create Dialog Frame
---@param self ExalityFramesInputDialogFrame
---@return Frame
inputDialog.Create = function(self)
  local f = self.pool:Acquire()
  if not f.configured then
    ConfigureFrame(f)
  end

  f:Hide()

  return f
end
