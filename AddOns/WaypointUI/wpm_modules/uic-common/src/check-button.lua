local env = select(2, ...)
local Path = env.WPM:Import("wpm_modules\\path")
local Sound = env.WPM:Import("wpm_modules\\sound")
local UIKit = env.WPM:Import("wpm_modules\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollView, LazyScrollView, ScrollBar, ScrollViewEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UIAnim = env.WPM:Import("wpm_modules\\ui-anim")
local UICSharedMixin = env.WPM:Import("wpm_modules\\uic-sharedmixin")
local Utils_Texture = env.WPM:Import("wpm_modules\\utils\\texture")
local UICCommonCheckButton = env.WPM:New("wpm_modules\\uic-common\\check-button")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

Utils_Texture.Preload(Path.Root .. "\\wpm_modules\\uic-common\\resources\\\\check-button.png")
local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\wpm_modules\\uic-common\\resources\\check-button.png", inset = 75, scale = 1 }
local UIDef = {
    UICheckButton                    = ATLAS{ left = 0 / 192, top = 0 / 128, right = 64 / 192, bottom = 64 / 128 },
    UICheckButton_Highlighted        = ATLAS{ left = 64 / 192, top = 0 / 128, right = 128 / 192, bottom = 64 / 128 },
    UICheckButton_Disabled           = ATLAS{ left = 128 / 192, top = 0 / 128, right = 192 / 192, bottom = 64 / 128 },
    UICheckButtonChecked             = ATLAS{ left = 0 / 192, top = 64 / 128, right = 64 / 192, bottom = 128 / 128 },
    UICheckButtonChecked_Highlighted = ATLAS{ left = 64 / 192, top = 64 / 128, right = 128 / 192, bottom = 128 / 128 },
    UICheckButtonChecked_Disabled    = ATLAS{ left = 128 / 192, top = 64 / 128, right = 192 / 192, bottom = 128 / 128 }
}

do --Check Button
    local CheckButtonMixin = CreateFromMixins(UICSharedMixin.CheckButtonMixin)

    function CheckButtonMixin:OnLoad()
        self:InitCheckButton()

        self:RegisterMouseEvents()
        self:HookCheck(self.UpdateCheck)
        self:HookMouseUp(self.Toggle)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookMouseUp(self.PlayInteractSound)

        self:UpdateAnimation()
        self:UpdateCheck()
    end

    function CheckButtonMixin:UpdateAnimation()
        local chedked = self:GetChecked()
        local highlighted = self:IsHighlighted()
        local enabled = self:IsEnabled()

        if chedked then
            if not enabled then
                self:background(UIDef.UICheckButtonChecked_Disabled)
            elseif highlighted then
                self:background(UIDef.UICheckButtonChecked_Highlighted)
            else
                self:background(UIDef.UICheckButtonChecked)
            end
        else
            if not enabled then
                self:background(UIDef.UICheckButton_Disabled)
            elseif highlighted then
                self:background(UIDef.UICheckButton_Highlighted)
            else
                self:background(UIDef.UICheckButton)
            end
        end
    end

    function CheckButtonMixin:UpdateCheck()
        self:UpdateAnimation()
    end

    function CheckButtonMixin:PlayInteractSound()
        local checked = self:GetChecked()
        if checked then
            Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        else
            Sound.PlaySound("UI", SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        end
    end

    UICCommonCheckButton.New = UIKit.Template(function(id, name, children, ...)
        local frame =
            Frame(name)
            :background(UIDef.UICheckButton)
            :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)

        Mixin(frame, CheckButtonMixin)
        frame:OnLoad()

        return frame
    end)
end
