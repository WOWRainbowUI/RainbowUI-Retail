---@class addonTableCoolinator
local addonTable = select(2, ...)

addonTable.Designer.Options.pixelStep = 0.5
local pixelStep = addonTable.Designer.Options.pixelStep

local function RoundPixel(pixel)
  return Round(pixel / pixelStep) * pixelStep
end

function addonTable.Designer.Options.GetSelectorMarker(frame, isHover)
  local texture = frame:CreateTexture()
  texture:SetTexture("Interface/AddOns/Coolinator/Assets/selection-outline.png")
  texture:SetVertexColor(78/255, 165/255, 252/255, isHover and 0.45 or 0.8)
  texture:SetTextureSliceMargins(45, 45, 45, 45)
  texture:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
  texture:SetScale(0.25)
  texture:SetAllPoints()

  return frame
end

function addonTable.Designer.Options.UpdateWidgetPointsBasic(preview, w, snapping, offsetX, offsetY)
  snapping = snapping or 2
  offsetX = offsetX or 0
  offsetY = offsetY or 0
  local left, bottom, width, height = w:GetRect()
  local widgetRect = {left = left + offsetX, bottom = bottom + offsetY, width = width, height = height}
  left, bottom, width, height = preview:GetRect()
  local previewRect = {left = left, bottom = bottom, width = width, height = height}
  local widgetCenter = {x = widgetRect.left + widgetRect.width / 2, y = widgetRect.bottom + widgetRect.height / 2}
  local previewCenter = {x = previewRect.left + previewRect.width / 2, y = previewRect.bottom + previewRect.height / 2}

  local point, x, y = "", 0, 0

  if math.abs(widgetCenter.y - previewCenter.y) < snapping then
    point = point
  elseif widgetCenter.y < previewCenter.y then
    point = "TOP" .. point
    y = widgetRect.bottom + widgetRect.height - previewCenter.y
  else
    point = "BOTTOM" .. point
    y = widgetRect.bottom - previewCenter.y
  end

  if math.abs(widgetCenter.x - previewCenter.x) < snapping then
    point = point
  elseif widgetCenter.x < previewCenter.x then
    point = point .. "LEFT"
    x = widgetRect.left - previewCenter.x
  else
    point = point .. "RIGHT"
    x = widgetRect.left + widgetRect.width - previewCenter.x
  end

  if point == "" then
    w.details.anchor = {}
  elseif x == 0 and y == 0 then
    w.details.anchor = {point}
  else
    w.details.anchor = {point, RoundPixel(x), RoundPixel(y)}
  end
end

function addonTable.Designer.Options.UpdateWidgetPointsBar(preview, w, snapping, offsetX, offsetY)
  snapping = snapping or 2
  offsetX = offsetX or 0
  offsetY = offsetY or 0
  local left, bottom, width, height = w:GetRect()
  local widgetRect = {left = left + offsetX, bottom = bottom + offsetY, width = width, height = height}
  left, bottom, width, height = preview:GetRect()
  local previewRect = {left = left, bottom = bottom, width = width, height = height}
  local widgetCenter = {x = widgetRect.left + widgetRect.width / 2, y = widgetRect.bottom + widgetRect.height / 2}
  local previewCenter = {x = previewRect.left + previewRect.width / 2, y = previewRect.bottom + previewRect.height / 2}
  local previewCutoff1 = {x = previewRect.left + previewRect.width / 3, y = previewRect.bottom + previewRect.height / 3}
  local previewCutoff2 = {x = previewRect.left + previewRect.width * 2 / 3, y = previewRect.bottom + previewRect.height * 2 / 3}

  local point, x, y = "", 0, 0

  if math.abs(widgetCenter.y - previewCenter.y) < snapping then
    point = point
  elseif widgetCenter.y < previewCutoff1.y then -- Bottom aligned
    point = "BOTTOM" .. point
    y = widgetRect.bottom - previewRect.bottom
  elseif widgetCenter.y <= previewCutoff2.y then -- Centralised
    point = point
    y = widgetCenter.y - previewCenter.y
  else
    point = "TOP" .. point
    y = widgetRect.bottom + widgetRect.height - previewRect.bottom - previewRect.height
  end

  if math.abs(widgetCenter.x - previewCenter.x) < snapping then
    point = point
  elseif widgetCenter.x < previewCutoff1.x then -- Left aligned
    point = point .. "LEFT"
    x = widgetRect.left - previewRect.left
  elseif widgetCenter.x <= previewCutoff2.x then -- Centralised
    point = point
    x = widgetCenter.x - previewCenter.x
  else
    point = point .. "RIGHT"
    x = widgetRect.left + widgetRect.width - previewRect.left - previewRect.width
  end

  if point == "" then
    w.details.anchor = {"CENTER", 0, 0}
  elseif x == 0 and y == 0 then
    w.details.anchor = {point, 0, 0}
  else
    w.details.anchor = {point, RoundPixel(x), RoundPixel(y)}
  end
end
