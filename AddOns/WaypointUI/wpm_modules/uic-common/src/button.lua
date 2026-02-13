local env = select(2, ...)
local Path = env.WPM:Import("wpm_modules\\path")
local Sound = env.WPM:Import("wpm_modules\\sound")
local UIFont = env.WPM:Import("wpm_modules\\ui-font")
local UIKit = env.WPM:Import("wpm_modules\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollView, LazyScrollView, ScrollBar, ScrollViewEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UIAnim = env.WPM:Import("wpm_modules\\ui-anim")
local UICSharedMixin = env.WPM:Import("wpm_modules\\uic-sharedmixin")
local GenericEnum = env.WPM:Import("wpm_modules\\generic-enum")
local Utils_Texture = env.WPM:Import("wpm_modules\\utils\\texture")
local UICCommonButton = env.WPM:New("wpm_modules\\uic-common\\button")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

Utils_Texture.Preload(Path.Root .. "\\wpm_modules\\uic-common\\resources\\button.png")
local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\wpm_modules\\uic-common\\resources\\button.png", inset = 37, scale = 0.5 }
local UIDef = {
    Close                           = ATLAS{ left = 64 / 512, top = 256 / 320, right = 128 / 512, bottom = 320 / 320 },
    SelectionMenu                   = ATLAS{ left = 0 / 512, top = 256 / 320, right = 64 / 512, bottom = 320 / 320 },

    --Red
    UIButtonRed                     = ATLAS{ left = 0 / 512, top = 0 / 320, right = 128 / 512, bottom = 64 / 320 },
    UIButtonRed_Highlighted         = ATLAS{ left = 128 / 512, top = 0 / 320, right = 256 / 512, bottom = 64 / 320 },
    UIButtonRed_Pushed              = ATLAS{ left = 256 / 512, top = 0 / 320, right = 384 / 512, bottom = 64 / 320 },
    UIButtonRed_Disabled            = ATLAS{ left = 384 / 512, top = 0 / 320, right = 512 / 512, bottom = 64 / 320 },

    UIButtonRedCompact              = ATLAS{ left = 0 / 512, top = 128 / 320, right = 64 / 512, bottom = 192 / 320 },
    UIButtonRedCompact_Highlighted  = ATLAS{ left = 64 / 512, top = 128 / 320, right = 128 / 512, bottom = 192 / 320 },
    UIButtonRedCompact_Pushed       = ATLAS{ left = 128 / 512, top = 128 / 320, right = 192 / 512, bottom = 192 / 320 },
    UIButtonRedCompact_Disabled     = ATLAS{ left = 192 / 512, top = 128 / 320, right = 256 / 512, bottom = 192 / 320 },

    --Gray
    UIButtonGray                    = ATLAS{ left = 0 / 512, top = 64 / 320, right = 128 / 512, bottom = 128 / 320 },
    UIButtonGray_Highlighted        = ATLAS{ left = 128 / 512, top = 64 / 320, right = 256 / 512, bottom = 128 / 320 },
    UIButtonGray_Pushed             = ATLAS{ left = 256 / 512, top = 64 / 320, right = 384 / 512, bottom = 128 / 320 },
    UIButtonGray_Disabled           = ATLAS{ left = 384 / 512, top = 64 / 320, right = 512 / 512, bottom = 128 / 320 },

    UIButtonGrayCompact             = ATLAS{ left = 0 / 512, top = 192 / 320, right = 64 / 512, bottom = 256 / 320 },
    UIButtonGrayCompact_Highlighted = ATLAS{ left = 64 / 512, top = 192 / 320, right = 128 / 512, bottom = 256 / 320 },
    UIButtonGrayCompact_Pushed      = ATLAS{ left = 128 / 512, top = 192 / 320, right = 192 / 512, bottom = 256 / 320 },
    UIButtonGrayCompact_Disabled    = ATLAS{ left = 192 / 512, top = 192 / 320, right = 256 / 512, bottom = 256 / 320 }
}

do --Button
    local CONTENT_SIZE = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 19 }
    local CONTENT_SIZE_SQUARE = UIKit.Define.Percentage{ value = 100 }
    local CONTENT_Y = 0
    local CONTENT_Y_HIGHLIGHTED = 0
    local CONTENT_Y_PRESSED = -1
    local CONTENT_ALPHA_ENABLED = 1
    local CONTENT_ALPHA_DISABLED = 0.5

    local ButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function ButtonMixin:OnLoad(isRed, isCompact)
        self:InitButton()
        self.isRed = isRed
        self.isCompact = isCompact

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function ButtonMixin:UpdateAnimation()
        local enabled = self:IsEnabled()
        local buttonState = self:GetButtonState()

        if not enabled then
            local texture =
                self.isCompact and (self.isRed and UIDef.UIButtonRedCompact_Disabled or UIDef.UIButtonGrayCompact_Disabled) or
                (self.isRed and UIDef.UIButtonRed_Disabled or UIDef.UIButtonGray_Disabled)

            self.Texture:background(texture)
            self.Content:ClearAllPoints()
            self.Content:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y)
        elseif buttonState == "NORMAL" then
            local texture =
                self.isCompact and (self.isRed and UIDef.UIButtonRedCompact or UIDef.UIButtonGrayCompact) or
                (self.isRed and UIDef.UIButtonRed or UIDef.UIButtonGray)

            self.Texture:background(texture)
            self.Content:ClearAllPoints()
            self.Content:SetPoint("CENTER", self, "CENTER", 0, CONTENT_Y)
        elseif buttonState == "HIGHLIGHTED" then
            local texture =
                self.isCompact and (self.isRed and UIDef.UIButtonRedCompact_Highlighted or UIDef.UIButtonGrayCompact_Highlighted) or
                (self.isRed and UIDef.UIButtonRed_Highlighted or UIDef.UIButtonGray_Highlighted)

            self.Texture:background(texture)
            self.Content:ClearAllPoints()
            self.Content:SetPoint("CENTER", self, "CENTER", -CONTENT_Y_HIGHLIGHTED, CONTENT_Y_HIGHLIGHTED)
        elseif buttonState == "PUSHED" then
            local texture =
                self.isCompact and (self.isRed and UIDef.UIButtonRedCompact_Pushed or UIDef.UIButtonGrayCompact_Pushed) or
                (self.isRed and UIDef.UIButtonRed_Pushed or UIDef.UIButtonGray_Pushed)

            self.Texture:background(texture)
            self.Content:ClearAllPoints()
            self.Content:SetPoint("CENTER", self, "CENTER", -CONTENT_Y_PRESSED, CONTENT_Y_PRESSED)
        end

        self.Content:SetAlpha(enabled and CONTENT_ALPHA_ENABLED or CONTENT_ALPHA_DISABLED)
    end

    function ButtonMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end

    UICCommonButton.RedBase = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. ".Content", {
                    unpack(children)
                })
                    :id("Content", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(CONTENT_SIZE, CONTENT_SIZE)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
            :background(UIKit.UI.TEXTURE_NIL)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Texture = frame:GetTextureFrame()
        frame.Content = UIKit.GetElementById("Content", id)

        Mixin(frame, ButtonMixin)
        frame:OnLoad(true)

        return frame
    end)

    UICCommonButton.GrayBase = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. ".Content", {
                    unpack(children)
                })
                    :id("Content", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(CONTENT_SIZE, CONTENT_SIZE)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
            :background(UIKit.UI.TEXTURE_NIL)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Texture = frame:GetTextureFrame()
        frame.Content = UIKit.GetElementById("Content", id)

        Mixin(frame, ButtonMixin)
        frame:OnLoad(false)

        return frame
    end)

    UICCommonButton.RedBaseSquare = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. ".Content", {
                    unpack(children)
                })
                    :id("Content", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(CONTENT_SIZE_SQUARE, CONTENT_SIZE_SQUARE)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
            :background(UIKit.UI.TEXTURE_NIL)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Texture = frame:GetTextureFrame()
        frame.Content = UIKit.GetElementById("Content", id)

        Mixin(frame, ButtonMixin)
        frame:OnLoad(true, true)

        return frame
    end)

    UICCommonButton.GrayBaseSquare = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. ".Content", {
                    unpack(children)
                })
                    :id("Content", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(CONTENT_SIZE_SQUARE, CONTENT_SIZE_SQUARE)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
            :background(UIKit.UI.TEXTURE_NIL)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Texture = frame:GetTextureFrame()
        frame.Content = UIKit.GetElementById("Content", id)

        Mixin(frame, ButtonMixin)
        frame:OnLoad(false, true)

        return frame
    end)
end

do --Button (Text)
    local RED_TEXT_COLOR = GenericEnum.UIColorRGB.NormalText
    local RED_TEXT_COLOR_HIGHLIGHTED = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }
    local GRAY_TEXT_COLOR = UIKit.Define.Color_RGBA{ r = 216, g = 216, b = 216, a = 1 }
    local GRAY_TEXT_COLOR_HIGHLIGHTED = UIKit.Define.Color_RGBA{ r = 255, g = 255, b = 255, a = 1 }

    local ButtonTextMixin = {}

    function ButtonTextMixin:ButtonText_OnLoad()
        self:HookButtonStateChange(self.ButtonText_UpdateAnimation)
    end

    function ButtonTextMixin:ButtonText_UpdateAnimation()
        local isRed = self.isRed
        local enabled = self:IsEnabled()
        local buttonState = self:GetButtonState()

        if not enabled then
            self.Text:textColor(isRed and RED_TEXT_COLOR or GRAY_TEXT_COLOR)
        elseif buttonState == "NORMAL" then
            self.Text:textColor(isRed and RED_TEXT_COLOR or GRAY_TEXT_COLOR)
        elseif buttonState == "HIGHLIGHTED" then
            self.Text:textColor(isRed and RED_TEXT_COLOR_HIGHLIGHTED or GRAY_TEXT_COLOR_HIGHLIGHTED)
        elseif buttonState == "PUSHED" then
            self.Text:textColor(isRed and RED_TEXT_COLOR_HIGHLIGHTED or GRAY_TEXT_COLOR_HIGHLIGHTED)
        end
    end

    function ButtonTextMixin:SetText(text)
        self.Text:SetText(text)
    end

    function ButtonTextMixin:GetText()
        return self.Text:GetText()
    end

    UICCommonButton.RedWithText = UIKit.Template(function(id, name, children, ...)
        local frame =
            UICCommonButton.RedBase(name, {
                Text(name .. ".Text")
                    :id("Text", id)
                    :fontObject(UIFont.UIFontObjectNormal12)
                    :textColor(RED_TEXT_COLOR)
                    :size(UIKit.UI.FILL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                unpack(children)
            })
            :id("Button", id)

        frame.Text = UIKit.GetElementById("Text", id)

        Mixin(frame, ButtonTextMixin)
        frame:ButtonText_OnLoad()

        return frame
    end)

    UICCommonButton.GrayWithText = UIKit.Template(function(id, name, children, ...)
        local frame =
            UICCommonButton.GrayBase(name, {
                Text(name .. ".Text")
                    :id("Text", id)
                    :fontObject(UIFont.UIFontObjectNormal12)
                    :size(UIKit.UI.FILL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                unpack(children)
            })

        frame.Text = UIKit.GetElementById("Text", id)

        Mixin(frame, ButtonTextMixin)
        frame:ButtonText_OnLoad()

        return frame
    end)
end

do --Button (Close)
    local SIZE = UIKit.Define.Percentage{ value = 62 }

    UICCommonButton.RedClose = UIKit.Template(function(id, name, children, ...)
        local frame =
            UICCommonButton.RedBaseSquare(name, {
                Frame(name .. ".Close")
                    :id("Close", id)
                    :point(UIKit.Enum.Point.Center)
                    :background(UIDef.Close)
                    :size(SIZE, SIZE)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                unpack(children)
            })

        frame.Close = UIKit.GetElementById("Close", id)
        frame.CloseTexture = frame.Close:GetTextureFrame()

        return frame
    end)
end

do --Button (Selection Menu)
    local SIZE = 12

    local ButtonSelectionMenuMixin = CreateFromMixins(UICSharedMixin.SelectionMenuRemoteMixin)

    function ButtonSelectionMenuMixin:OnLoad()
        self:InitSelectionMenuRemoteMixin()
    end

    UICCommonButton.SelectionMenu = UIKit.Template(function(id, name, children, ...)
        local frame =
            UICCommonButton.GrayWithText(name, {
                Frame(name .. ".Arrow")
                    :id("Arrow", id)
                    :point(UIKit.Enum.Point.Right)
                    :background(UIDef.SelectionMenu)
                    :size(SIZE, SIZE)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                unpack(children)
            })

        frame.Text:textAlignment("LEFT", "MIDDLE")
        frame.Arrow = UIKit.GetElementById("Arrow", id)

        Mixin(frame, ButtonSelectionMenuMixin)
        frame:OnLoad()

        return frame
    end)
end
