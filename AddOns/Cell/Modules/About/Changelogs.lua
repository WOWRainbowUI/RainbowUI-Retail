local _, Cell = ...
local L = Cell.L
local F = Cell.funcs
local P = Cell.pixelPerfectFuncs

local changelogsFrame

local function CreateChangelogsFrame()
    changelogsFrame = Cell.CreateMovableFrame("Cell "..L["Changelogs"], "CellChangelogsFrame", 400, 450, "DIALOG", 1, true)
    Cell.frames.changelogsFrame = changelogsFrame
    changelogsFrame:SetToplevel(true)

    changelogsFrame.header.closeBtn:HookScript("OnClick", function()
        CellDB["changelogsViewed"] = Cell.version
    end)

    Cell.CreateScrollFrame(changelogsFrame)
    changelogsFrame.scrollFrame:SetScrollStep(37)

    local content = CreateFrame("SimpleHTML", "CellChangelogsContent", changelogsFrame.scrollFrame.content)
    content:SetSpacing("h1", 9)
    content:SetSpacing("h2", 7)
    content:SetSpacing("p", 5)
    content:SetFontObject("h1", "CELL_FONT_CLASS_TITLE")
    content:SetFontObject("h2", "CELL_FONT_CLASS")
    if LOCALE_zhCN then
        content:SetFontObject("p", "CELL_FONT_WIDGET")
    else
        content:SetFontObject("p", "CELL_FONT_CHINESE")
    end
    content:SetPoint("TOP", 0, -10)
    content:SetWidth(changelogsFrame:GetWidth() - 30)
    content:SetHyperlinkFormat("|H%s|h|cFFFFD100%s|r|h")

    changelogsFrame:SetScript("OnShow", function()
        content:SetText("<html><body>" .. L["CHANGELOGS"] .. "</body></html>")
        C_Timer.After(0, function()
            local height = content:GetContentHeight()
            content:SetHeight(height)
            changelogsFrame.scrollFrame.content:SetHeight(height + 100)
            P.PixelPerfectPoint(changelogsFrame)
        end)
    end)

    content:SetScript("OnHyperlinkClick", function(self, linkData, link, button)
        if linkData == "older" then
            content:SetText("<html><body>" .. L["OLDER_CHANGELOGS"] .. "</body></html>")
        elseif linkData == "recent" then
            content:SetText("<html><body>" .. L["CHANGELOGS"] .. "</body></html>")
        end

        C_Timer.After(0, function()
            local height = content:GetContentHeight()
            content:SetHeight(height)
            changelogsFrame.scrollFrame.content:SetHeight(height + 30)
            changelogsFrame.scrollFrame:ResetScroll()
        end)
    end)
end

function F.CheckWhatsNew(show)
    if show or CellDB["changelogsViewed"] ~= Cell.version then
        if not init then
            init = true
            CreateChangelogsFrame()
        end

        if changelogsFrame:IsShown() then
            changelogsFrame:Hide()
        else
            changelogsFrame:ClearAllPoints()
            changelogsFrame:SetPoint("CENTER")
            changelogsFrame:Show()
        end
    end
end