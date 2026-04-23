---------------------------------------------------------------------------------------------------
-- Module: Font
---------------------------------------------------------------------------------------------------
local ADDON_NAME, Addon = ...

---------------------------------------------------------------------------------------------------
-- Imported functions and constants
---------------------------------------------------------------------------------------------------

-- Lua APIs

-- WoW APIs
local SystemFont_NamePlate, SystemFont_NamePlateFixed = SystemFont_NamePlate, SystemFont_NamePlateFixed
local SystemFont_LargeNamePlate, SystemFont_LargeNamePlateFixed = SystemFont_LargeNamePlate, SystemFont_LargeNamePlateFixed
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

-- ThreatPlates APIs
local ANCHOR_POINT_TEXT = Addon.ANCHOR_POINT_TEXT

-- Cached database settings

---------------------------------------------------------------------------------------------------
-- Module Setup
---------------------------------------------------------------------------------------------------
local FontModule = Addon.Font

---------------------------------------------------------------------------------------------------
-- Backup system fonts for recovery if necessary
---------------------------------------------------------------------------------------------------

local function BackupSystemFont(font_instance)
  local font_name, font_height, font_flags = font_instance:GetFont()

  return {
    Typeface = font_name,
    Size = font_height,
    flags = font_flags
  }
end

local DefaultSystemFonts = {
  NamePlate = BackupSystemFont(SystemFont_NamePlate),
  NamePlateFixed = BackupSystemFont(SystemFont_NamePlateFixed),
  LargeNamePlate = BackupSystemFont(SystemFont_LargeNamePlate),
  LargeNamePlateFixed = BackupSystemFont(SystemFont_LargeNamePlateFixed),
}

---------------------------------------------------------------------------------------------------
-- Font fetch helpers (WoW 12.0 safety: ensure non-nil font path and valid flags)
---------------------------------------------------------------------------------------------------

-- 安全地從 LibSharedMedia 取得字型路徑；找不到時回退到內建字型，避免 SetFont 噴錯
local function SafeFetchFont(typeface)
  local font_path
  if typeface then
    font_path = Addon.LibSharedMedia:Fetch('font', typeface)
  end
  if not font_path or font_path == "" then
    font_path = STANDARD_TEXT_FONT or "Fonts\\bHEI01B.ttf"
  end
  return font_path
end

-- WoW 10.0+ flags 已不可選；"NONE" 不是合法值，需轉為空字串
local function NormalizeFontFlags(flags)
  if not flags or flags == "NONE" then
    return ""
  end
  return flags
end

---------------------------------------------------------------------------------------------------
-- UI utility functions
---------------------------------------------------------------------------------------------------

function Addon.AnchorFrameTo(db, frame, parent_frame)
  frame:ClearAllPoints()

  local anchor = db.Anchor or "CENTER"
  if db.InsideAnchor == false then
    local anchor_point_text = ANCHOR_POINT_TEXT[anchor]
    frame:SetPoint(anchor_point_text[2], parent_frame, anchor_point_text[1], db.HorizontalOffset or 0, db.VerticalOffset or 0)
  else -- db.InsideAnchor not defined in settings or true
    frame:SetPoint(anchor, parent_frame, anchor, db.HorizontalOffset or 0, db.VerticalOffset or 0)
  end
end

local AnchorFrameTo = Addon.AnchorFrameTo

---------------------------------------------------------------------------------------------------
-- Element code
---------------------------------------------------------------------------------------------------

function FontModule.SetJustify(font_string, horz, vert)
  local align_horz, align_vert = font_string:GetJustifyH(), font_string:GetJustifyV()
  if align_horz ~= horz or align_vert ~= vert then
    font_string:SetJustifyH(horz)
    font_string:SetJustifyV(vert)

    -- Set text to nil to enforce text string update, otherwise updates to justification will not take effect
    local text = font_string:GetText()
    font_string:SetText(nil)
    font_string:SetText(text)
  end
end

local function UpdateTextFont(font, db)
  local font_path = SafeFetchFont(db.Typeface)
  local flags = NormalizeFontFlags(db.flags)

  font:SetFont(font_path, db.Size, flags)

  if db.Shadow then
    font:SetShadowOffset(1, -1)
    font:SetShadowColor(0, 0, 0, 1)
  else
    font:SetShadowColor(0, 0, 0, 0)
  end

  if db.Color then
    font:SetTextColor(db.Color.r, db.Color.g, db.Color.b, db.Transparency or 1)
  end

  FontModule.SetJustify(font, db.HorizontalAlignment or "CENTER", db.VerticalAlignment or "MIDDLE")

  -- Set text to nil to enforce text string update, otherwise updates to justification will not take effect
  local text = font:GetText()
  font:SetText(nil)
  font:SetText(text)
end

function FontModule.UpdateText(parent, font, db)
  UpdateTextFont(font, db.Font)
  AnchorFrameTo(db, font, parent)
end

function FontModule.UpdateTextSize(parent, font, db)
  local width, height = parent:GetSize()
  if db.AutoSizing == nil or db.AutoSizing then
    font:SetSize(width, height)
    font:SetWordWrap(false)
  else
    font:SetSize(db.Width, font:GetLineHeight() * font:GetMaxLines())
    font:SetWordWrap(db.WordWrap)
    font:SetNonSpaceWrap(true)
  end
end

---------------------------------------------------------------------------------------------------
-- Configure system fonts
---------------------------------------------------------------------------------------------------

local function UpdateSystemFont(obj, db)
  local font_path = SafeFetchFont(db.Typeface)
  local flags = NormalizeFontFlags(db.flags)

  obj:SetFont(font_path, db.Size, flags)

  if db.Shadow then
    local color = db.ShadowColor
    obj:SetShadowColor(color.r, color.g, color.b, color.a)
    obj:SetShadowOffset(db.ShadowHorizontalOffset, db.ShadowVerticalOffset)
  else
    obj:SetShadowColor(0, 0, 0, 0)
  end
end

function FontModule.SetNamesFonts()
  local db = Addon.db.profile.BlizzardSettings.Names
  if db.Enabled then
    db = db.Font
    UpdateSystemFont(SystemFont_NamePlate, db)
    UpdateSystemFont(SystemFont_NamePlateFixed, db)
    UpdateSystemFont(SystemFont_LargeNamePlate, db)
    UpdateSystemFont(SystemFont_LargeNamePlateFixed, db)
  end
end

function FontModule.ResetNamesFonts()
  UpdateSystemFont(SystemFont_NamePlate, DefaultSystemFonts.NamePlate)
  UpdateSystemFont(SystemFont_NamePlateFixed, DefaultSystemFonts.NamePlateFixed)
  UpdateSystemFont(SystemFont_LargeNamePlate, DefaultSystemFonts.LargeNamePlate)
  UpdateSystemFont(SystemFont_LargeNamePlateFixed, DefaultSystemFonts.LargeNamePlateFixed)
end

---------------------------------------------------------------------------------------------------
-- Update of settings
---------------------------------------------------------------------------------------------------

-- function FontModule:UpdateSettings()
-- end
