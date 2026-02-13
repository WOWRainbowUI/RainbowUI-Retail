local env = select(2, ...)
local Path = env.WPM:Import("wpm_modules\\path")
local Sound = env.WPM:Import("wpm_modules\\sound")
local UIKit = env.WPM:Import("wpm_modules\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollView, LazyScrollView, ScrollBar, ScrollViewEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UIAnim = env.WPM:Import("wpm_modules\\ui-anim")
local UICSharedMixin = env.WPM:Import("wpm_modules\\uic-sharedmixin")
local Utils_Texture = env.WPM:Import("wpm_modules\\utils\\texture")
local UICCommonColorInput = env.WPM:New("wpm_modules\\uic-common\\color-input")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

Utils_Texture.Preload(Path.Root .. "\\wpm_modules\\uic-common\\resources\\color-input.png")
local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\wpm_modules\\uic-common\\resources\\color-input.png", inset = 37, scale = 0.5 }
local UIDef = {
    UIColorInput              = ATLAS{ left = 0 / 384, right = 128 / 384, top = 0 / 128, bottom = 64 / 128 },
    UIColorInput_Disabled     = ATLAS{ left = 256 / 384, right = 384 / 384, top = 0 / 128, bottom = 64 / 128 },
    UIColorInputFill          = ATLAS{ left = 0 / 384, right = 128 / 384, top = 64 / 128, bottom = 128 / 128 },
    UIColorInputFill_Pushed   = ATLAS{ left = 128 / 384, right = 256 / 384, top = 64 / 128, bottom = 128 / 128 },
    UIColorInputFill_Disabled = ATLAS{ left = 256 / 384, right = 384 / 384, top = 64 / 128, bottom = 128 / 128 }
}

do --Color Input
    local ColorInputMixin = CreateFromMixins(UICSharedMixin.ColorInputMixin)

    function ColorInputMixin:OnLoad()
        self:InitColorInput()

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookColorChange(self.OnColorChange)
        self:HookMouseUp(self.OnClick)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function ColorInputMixin:OnColorChange(color)
        self.FillTexture:SetColor(color)
    end

    function ColorInputMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        local enabled = self:IsEnabled()

        self:background(enabled and UIDef.UIColorInput or UIDef.UIColorInput_Disabled)
        if not enabled then
            self.Fill:background(UIDef.UIColorInputFill_Disabled)
            return
        end

        if buttonState == "NORMAL" or buttonState == "HIGHLIGHTED" then
            self.Fill:background(UIDef.UIColorInputFill)
        elseif buttonState == "PUSHED" then
            self.Fill:background(UIDef.UIColorInputFill_Pushed)
        end
    end

    function ColorInputMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end

    UICCommonColorInput.New = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Frame(name .. ".Fill", {
                    unpack(children)
                })
                    :id("Fill", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(UIKit.UI.P_FILL, UIKit.UI.P_FILL)
                    :background(UIKit.UI.TEXTURE_NIL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
            :background(UIDef.UIColorInput)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Texture = frame:GetTextureFrame()
        frame.Fill = UIKit.GetElementById("Fill", id)
        frame.FillTexture = frame.Fill:GetTextureFrame()

        Mixin(frame, ColorInputMixin)
        frame:OnLoad(true)

        return frame
    end)
end
