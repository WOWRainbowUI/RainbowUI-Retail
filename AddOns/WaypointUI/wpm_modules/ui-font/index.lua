local env = select(2, ...)
local React = env.WPM:Import("wpm_modules\\react")
local UIFont_CustomFont = env.WPM:Import("wpm_modules\\ui-font\\custom-font")
local UIFont_FontUtil = env.WPM:Import("wpm_modules\\ui-font\\font-util")
local UIFont = env.WPM:New("wpm_modules\\ui-font")

UIFont.CustomFont = UIFont_CustomFont

do -- Fonts
    local UI_FONT_SCHEMATIC = {
        8, 10, 11, 12, 13, 14, 16, 18
    }

    local function CreateUIFontObjectNormal(fontHeight)
        local fontObject = UIFont_FontUtil:CreateFontObject()
        fontObject:SetFont(GameFontNormal:GetFont(), fontHeight, "")
        fontObject:SetShadowOffset(1, -1)
        fontObject:SetShadowColor(0, 0, 0, 1)

        return fontObject
    end

    function UIFont.SetNormalFont(fontPath)
        for _, fontHeight in ipairs(UI_FONT_SCHEMATIC) do
            UIFont["UIFontObjectNormal" .. fontHeight]:SetFontFile(fontPath)
        end
    end

    local UIFontNormal = React.New(GameFontNormal:GetFont())
    UIFont.UIFontNormal = UIFontNormal

    for _, fontHeight in ipairs(UI_FONT_SCHEMATIC) do
        UIFont["UIFontObjectNormal" .. fontHeight] = CreateUIFontObjectNormal(fontHeight)
    end
end
