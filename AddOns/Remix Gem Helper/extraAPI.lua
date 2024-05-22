---@class Anchor

---@param point FramePoint
---@param relativeTo? any
---@param relativePoint? FramePoint
---@param offsetX? uiUnit
---@param offsetY? uiUnit
---@return Anchor
---@overload fun(point: AnchorPoint, relativeTo?: any, ofsx?: number, ofsy?: number):Anchor
---@overload fun(point: AnchorPoint, ofsx?: number, ofsy?: number):Anchor
function CreateAnchor(point, relativeTo, relativePoint, offsetX, offsetY) return {} end