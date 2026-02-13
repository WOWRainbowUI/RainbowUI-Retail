local env = select(2, ...)
local Path = env.WPM:Import("wpm_modules\\path")
local Sound = env.WPM:Import("wpm_modules\\sound")
local UIKit = env.WPM:Import("wpm_modules\\ui-kit")
local Frame, LayoutGrid, LayoutHorizontal, LayoutVertical, Text, ScrollView, LazyScrollView, ScrollBar, ScrollViewEdge, Input, LinearSlider, HitRect, List = unpack(UIKit.UI.Frames)
local UIAnim = env.WPM:Import("wpm_modules\\ui-anim")
local UICSharedMixin = env.WPM:Import("wpm_modules\\uic-sharedmixin")
local Utils_Texture = env.WPM:Import("wpm_modules\\utils\\texture")
local UICCommonScrollBar = env.WPM:New("wpm_modules\\uic-common\\scroll-bar")

local Mixin = Mixin
local CreateFromMixins = CreateFromMixins

Utils_Texture.Preload(Path.Root .. "\\wpm_modules\\uic-common\\resources\\scroll-bar.png")
local ATLAS = UIKit.Define.Texture_Atlas{ path = Path.Root .. "\\wpm_modules\\uic-common\\resources\\scroll-bar.png" }
local UIDef = {
    UIScrollBarTrack             = ATLAS{ inset = 32, scale = 0.25, left = 0 / 320, right = 64 / 320, top = 0 / 128, bottom = 128 / 128 },
    UIScrollBarThumb             = ATLAS{ inset = 32, scale = 0.25, left = 64 / 320, right = 128 / 320, top = 0 / 128, bottom = 64 / 128 },
    UIScrollBarThumb_Highlighted = ATLAS{ inset = 32, scale = 0.25, left = 128 / 320, right = 192 / 320, top = 0 / 128, bottom = 64 / 128 },
    UIScrollBarThumb_Pushed      = ATLAS{ inset = 32, scale = 0.25, left = 192 / 320, right = 256 / 320, top = 0 / 128, bottom = 64 / 128 },
    UIScrollBarThumb_Disabled    = ATLAS{ inset = 32, scale = 0.25, left = 256 / 320, right = 320 / 320, top = 0 / 128, bottom = 64 / 128 }
}

do --Scroll Bar
    local ScrollBarMixin = CreateFromMixins(UICSharedMixin.ScrollBarMixin)

    function ScrollBarMixin:OnLoad()
        self:InitScrollBar()

        self.HitRect:AddOnEnter(function() self:OnEnter() end)
        self.HitRect:AddOnLeave(function() self:OnLeave() end)
        self.HitRect:AddOnMouseDown(function() self:OnMouseDown() end)
        self.HitRect:AddOnMouseUp(function() self:OnMouseUp() end)

        self:HookButtonStateChange(self.UpdateAnimation)
        self:HookEnableChange(self.UpdateAnimation)
        self:HookMouseUp(self.PlayInteractSound)
        self:UpdateAnimation()
    end

    function ScrollBarMixin:UpdateAnimation()
        local buttonState = self:GetButtonState()
        local enabled = self:IsEnabled()

        if not enabled then
            self.Thumb:background(UIDef.UIScrollBarThumb_Disabled)
        elseif buttonState == "PUSHED" then
            self.Thumb:background(UIDef.UIScrollBarThumb_Pushed)
        elseif buttonState == "HIGHLIGHTED" then
            self.Thumb:background(UIDef.UIScrollBarThumb_Highlighted)
        else
            self.Thumb:background(UIDef.UIScrollBarThumb)
        end
    end

    function ScrollBarMixin:PlayInteractSound()
        Sound.PlaySound("UI", SOUNDKIT.U_CHAT_SCROLL_BUTTON)
    end

    UICCommonScrollBar.New = UIKit.Template(function(id, name, children, ...)
        local frame =
            ScrollBar(name, {
                HitRect(name .. ".HitRect")
                    :id("HitRect", id)
                    :frameLevel(3)
                    :size(UIKit.UI.FILL)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                Frame(name .. ".Thumb")
                    :id("Thumb", id)
                    :frameLevel(2)
                    :as("LINEAR_SLIDER_THUMB")
                    :size(UIKit.UI.FILL)
                    :background(UIDef.UIScrollBarThumb)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged),

                Frame(name .. ".Track")
                    :id("Track", id)
                    :frameLevel(1)
                    :as("LINEAR_SLIDER_TRACK")
                    :size(UIKit.UI.FILL)
                    :background(UIDef.UIScrollBarTrack)
                    :_updateMode(UIKit.Enum.UpdateMode.ExcludeVisibilityChanged)
            })

        frame.HitRect = UIKit.GetElementById("HitRect", id)
        frame.Thumb = UIKit.GetElementById("Thumb", id)
        frame.Track = UIKit.GetElementById("Track", id)

        Mixin(frame, ScrollBarMixin)
        frame:OnLoad()

        return frame
    end)
end
