local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames


local pixelPerfect = EXFrames:GetFrame('pixel-perfect')

pixelPerfect.UIScale = 1
pixelPerfect.Mult = 1

pixelPerfect.Initialize = function(self)
  local _, screenHeight = GetPhysicalScreenSize()
  local perfect = 768 / screenHeight
  self.UIScale = UIParent:GetScale()
  self.Mult = perfect / self.UIScale
end

function EXFrames.ScalePixel(self, value)
  return PixelUtil.GetNearestPixelSize(value, pixelPerfect.UIScale) - 0.07
end

function EXFrames:SetSize(frame, width, height)
  frame:SetSize(self:ScalePixel(width), self:ScalePixel(height))
end

function EXFrames:SetHeight(frame, height)
  frame:SetHeight(self:ScalePixel(height))
end

function EXFrames:SetWidth(frame, width)
  frame:SetWidth(self:ScalePixel(width))
end

function EXFrames:SetPoint(frame, point, arg2, arg3, arg4, arg5)
  if (type(arg2) == 'number') then
    -- SetPoint(point, x, y)
    frame:SetPoint(point, self:ScalePixel(arg2), self:ScalePixel(arg3))
  else
    -- SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
    frame:SetPoint(point, arg2, arg3, self:ScalePixel(arg4), self:ScalePixel(arg5))
  end
end

function EXFrames:AddPixelPerfectBorder(frame, thickness)
  local borderFrame = CreateFrame('Frame', nil, frame)
  borderFrame:SetAllPoints()
  thickness = thickness or 1

  -- Top
  local top = borderFrame:CreateTexture(nil, 'BACKGROUND')
  top:SetPoint('TOPLEFT')
  top:SetPoint('TOPRIGHT')
  top:SetTexture(EXUI.const.textures.frame.solidBg)
  top:SetHeight(EXUI:ScalePixel(thickness))

  borderFrame.Top = top

  -- Bottom
  local bottom = borderFrame:CreateTexture(nil, 'BACKGROUND')
  bottom:SetPoint('BOTTOMLEFT')
  bottom:SetPoint('BOTTOMRIGHT')
  bottom:SetHeight(EXUI:ScalePixel(thickness))
  bottom:SetTexture(EXUI.const.textures.frame.solidBg)

  borderFrame.Bottom = bottom

  -- Left
  local left = borderFrame:CreateTexture(nil, 'BACKGROUND')
  left:SetPoint('TOPLEFT')
  left:SetPoint('BOTTOMLEFT')
  left:SetWidth(EXUI:ScalePixel(thickness))
  left:SetTexture(EXUI.const.textures.frame.solidBg)

  borderFrame.Left = left

  -- Right
  local right = borderFrame:CreateTexture(nil, 'BACKGROUND')
  right:SetPoint('TOPRIGHT')
  right:SetPoint('BOTTOMRIGHT')
  right:SetWidth(EXUI:ScalePixel(thickness))
  right:SetTexture(EXUI.const.textures.frame.solidBg)

  borderFrame.Right = right

  borderFrame.SetBorderColor = function(self, r, g, b, a)
    self.Top:SetVertexColor(r, g, b, a)
    self.Bottom:SetVertexColor(r, g, b, a)
    self.Left:SetVertexColor(r, g, b, a)
    self.Right:SetVertexColor(r, g, b, a)
  end

  borderFrame.SetBorderThickness = function(self, thickness)
    self.Top:SetHeight(EXUI:ScalePixel(thickness))
    self.Bottom:SetHeight(EXUI:ScalePixel(thickness))
    self.Left:SetWidth(EXUI:ScalePixel(thickness))
    self.Right:SetWidth(EXUI:ScalePixel(thickness))
  end

  return borderFrame
end
