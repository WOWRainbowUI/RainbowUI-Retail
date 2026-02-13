local env = select(2, ...)
local GenericEnum = env.WPM:Import("wpm_modules\\generic-enum")
local Path = env.WPM:Import("wpm_modules\\path")
local Sound = env.WPM:Import("wpm_modules\\sound")
local UIFont = env.WPM:Import("wpm_modules\\ui-font")
local UIKit = env.WPM:Import("wpm_modules\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollView, LazyScrollView, ScrollBar, ScrollViewEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UIAnim = env.WPM:Import("wpm_modules\\ui-anim")
local UICSharedMixin = env.WPM:Import("wpm_modules\\uic-sharedmixin")
local Utils_Texture = env.WPM:Import("wpm_modules\\utils\\texture")
local UICCommonRange = env.WPM:New("wpm_modules\\uic-common\\range")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

Utils_Texture.Preload(Path.Root .. "\\wpm_modules\\uic-common\\resources\\range.png")
local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\wpm_modules\\uic-common\\resources\\range.png" }
local UIDef = {
    --Stepper
    UIStepperArrowLeft              = ATLAS{ inset = 0, scale = 1, left = 0 / 256, top = 64 / 256, right = 64 / 256, bottom = 128 / 256 },
    UIStepperArrowLeft_Highlighted  = ATLAS{ inset = 0, scale = 1, left = 64 / 256, top = 64 / 256, right = 128 / 256, bottom = 128 / 256 },
    UIStepperArrowLeft_Pushed       = ATLAS{ inset = 0, scale = 1, left = 128 / 256, top = 64 / 256, right = 192 / 256, bottom = 128 / 256 },
    UIStepperArrowLeft_Disabled     = ATLAS{ inset = 0, scale = 1, left = 192 / 256, top = 64 / 256, right = 256 / 256, bottom = 128 / 256 },
    UIStepperArrowRight             = ATLAS{ inset = 0, scale = 1, left = 0 / 256, top = 128 / 256, right = 64 / 256, bottom = 192 / 256 },
    UIStepperArrowRight_Highlighted = ATLAS{ inset = 0, scale = 1, left = 64 / 256, top = 128 / 256, right = 128 / 256, bottom = 192 / 256 },
    UIStepperArrowRight_Pushed      = ATLAS{ inset = 0, scale = 1, left = 128 / 256, top = 128 / 256, right = 192 / 256, bottom = 192 / 256 },
    UIStepperArrowRight_Disabled    = ATLAS{ inset = 0, scale = 1, left = 192 / 256, top = 128 / 256, right = 256 / 256, bottom = 192 / 256 },

    --Range
    UIRangeTrack                    = ATLAS{ inset = 32, scale = 0.125, left = 0 / 256, top = 192 / 256, right = 128 / 256, bottom = 256 / 256 },
    UIRangeThumb                    = ATLAS{ inset = 0, scale = 1, left = 0 / 256, top = 0 / 256, right = 64 / 256, bottom = 64 / 256 },
    UIRangeThumb_Highlighted        = ATLAS{ inset = 0, scale = 1, left = 64 / 256, top = 0 / 256, right = 128 / 256, bottom = 64 / 256 },
    UIRangeThumb_Pushed             = ATLAS{ inset = 0, scale = 1, left = 128 / 256, top = 0 / 256, right = 192 / 256, bottom = 64 / 256 },
    UIRangeThumb_Disabled           = ATLAS{ inset = 0, scale = 1, left = 192 / 256, top = 0 / 256, right = 256 / 256, bottom = 64 / 256 }
}

do -- Stepper
    local StepperButtonMixin = CreateFromMixins(UICSharedMixin.ButtonMixin)

    function StepperButtonMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        local enabled = self:IsEnabled()

        if not enabled then
            if self.isIncrease then
                self:background(UIDef.UIStepperArrowRight_Disabled)
            else
                self:background(UIDef.UIStepperArrowLeft_Disabled)
            end
        elseif buttonState == "PUSHED" then
            if self.isIncrease then
                self:background(UIDef.UIStepperArrowRight_Pushed)
            else
                self:background(UIDef.UIStepperArrowLeft_Pushed)
            end
        elseif buttonState == "HIGHLIGHTED" then
            if self.isIncrease then
                self:background(UIDef.UIStepperArrowRight_Highlighted)
            else
                self:background(UIDef.UIStepperArrowLeft_Highlighted)
            end
        else
            if self.isIncrease then
                self:background(UIDef.UIStepperArrowRight)
            else
                self:background(UIDef.UIStepperArrowLeft)
            end
        end
    end

    function StepperButtonMixin:HandleOnClick()
        local min, max = self.parent.Range:GetMinMaxValues()
        local step = self.parent.Range:GetValueStep()
        local value = self.parent.Range:GetValue()

        if self.isIncrease then
            self.parent.Range:SetValue(math.min(value + step, max))
        else
            self.parent.Range:SetValue(math.max(value - step, min))
        end
    end

    function StepperButtonMixin:OnLoad(isIncrease, parent)
        self:InitButton()
        self.isIncrease = isIncrease
        self.parent = parent

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookMouseUp(self.HandleOnClick)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function StepperButtonMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.SCROLLBAR_STEP)
    end

    UICCommonRange.StepperButton = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name)
            :background(UIKit.UI.TEXTURE_NIL)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        Mixin(frame, StepperButtonMixin)

        return frame
    end)
end

do -- Range
    local THUMB_SIZE = 16
    local STEPPER_SIZE = 16
    local WIDTH = UIKit.Define.Percentage{ value = 100, operator = "-", delta = 28 }
    local HEIGHT = UIKit.Define.Percentage{ value = 100 }
    local TRACK_SIZE = UIKit.Define.Fill{ delta = 6 }

    local RangeSliderMixin = CreateFromMixins(UICSharedMixin.RangeMixin)

    local function OnEnableChange(self, enabled)
        self.parent.ForwardButton:SetEnabled(enabled)
        self.parent.BackwardButton:SetEnabled(enabled)

        self:UpdateAnimation()
    end

    function RangeSliderMixin:OnLoad(parent)
        self:InitRange()
        self.parent = parent

        self:RegisterMouseEvents()
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(OnEnableChange)
        self:HookMouseDown(self.PlayInteractSound)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function RangeSliderMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        local enabled = self:IsEnabled()

        if not enabled then
            self.parent.RangeThumb:background(UIDef.UIRangeThumb_Disabled)
        elseif buttonState == "PUSHED" then
            self.parent.RangeThumb:background(UIDef.UIRangeThumb_Pushed)
        elseif buttonState == "HIGHLIGHTED" then
            self.parent.RangeThumb:background(UIDef.UIRangeThumb_Highlighted)
        else
            self.parent.RangeThumb:background(UIDef.UIRangeThumb)
        end
    end

    function RangeSliderMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    end

    local RangeMixin = {}

    function RangeMixin:GetRange()
        return self.Range
    end

    UICCommonRange.New = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                LinearSlider(name .. ".Range", {
                    Frame(name .. ".RangeThumb")
                        :id("RangeThumb", id)
                        :frameLevel(2)
                        :as("LINEAR_SLIDER_THUMB")
                        :size(UIKit.UI.FILL)
                        :background(UIDef.UIRangeThumb)
                        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                    Frame(name .. ".RangeTrack")
                        :id("RangeTrack", id)
                        :frameLevel(1)
                        :as("LINEAR_SLIDER_TRACK")
                        :size(TRACK_SIZE)
                        :background(UIDef.UIRangeTrack)
                        :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
                })
                    :id("Range", id)
                    :point(UIKit.Enum.Point.Center)
                    :size(WIDTH, HEIGHT)
                    :linearSliderThumbPropagateMouse(true)
                    :linearSliderThumbSize(THUMB_SIZE, THUMB_SIZE)
                    :linearSliderOrientation(UIKit.Enum.Orientation.Horizontal)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                UICCommonRange.StepperButton(name .. ".ForwardButton")
                    :id("ForwardButton", id)
                    :point(UIKit.Enum.Point.Right)
                    :size(STEPPER_SIZE, STEPPER_SIZE)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                UICCommonRange.StepperButton(name .. ".BackwardButton")
                    :id("BackwardButton", id)
                    :point(UIKit.Enum.Point.Left)
                    :size(STEPPER_SIZE, STEPPER_SIZE)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })

        frame.Range = UIKit.GetElementById("Range", id)
        frame.RangeThumb = UIKit.GetElementById("RangeThumb", id)
        frame.RangeTrack = UIKit.GetElementById("RangeTrack", id)
        frame.ForwardButton = UIKit.GetElementById("ForwardButton", id)
        frame.BackwardButton = UIKit.GetElementById("BackwardButton", id)

        Mixin(frame.Range, RangeSliderMixin)
        Mixin(frame, RangeMixin)
        frame.Range:OnLoad(frame)
        frame.ForwardButton:OnLoad(true, frame)
        frame.BackwardButton:OnLoad(false, frame)

        return frame
    end)
end

do -- Range with Text
    local TEXT_COLOR = GenericEnum.UIColorRGB.NormalText
    local TEXT_WIDTH = UIKit.Define.Percentage{ value = 34, operator = "-", delta = 5 }
    local RANGE_WIDTH = UIKit.Define.Percentage{ value = 66 }

    local RangeWithTextMixin = {}

    function RangeWithTextMixin:GetRange()
        return self.Range:GetRange()
    end

    function RangeWithTextMixin:SetText(text)
        self.Text:SetText(text)
    end

    function RangeWithTextMixin:GetText()
        return self.Text:GetText()
    end

    UICCommonRange.NewWithText = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name, {
                Text(name .. ".Text")
                    :id("Text", id)
                    :point(UIKit.Enum.Point.Left)
                    :size(TEXT_WIDTH, UIKit.UI.P_FILL)
                    :fontObject(UIFont.UIFontObjectNormal11)
                    :textAlignment("RIGHT", "MIDDLE")
                    :textColor(TEXT_COLOR)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                UICCommonRange.New(name .. ".Range")
                    :id("Range", id)
                    :point(UIKit.Enum.Point.Right)
                    :size(RANGE_WIDTH, UIKit.UI.P_FILL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        frame.Text = UIKit.GetElementById("Text", id)
        frame.Range = UIKit.GetElementById("Range", id)

        Mixin(frame, RangeWithTextMixin)

        return frame
    end)
end
