local U1Name, U1 = ...
local DataBroker = LibStub'LibDataBroker-1.1'
local L = U1.L

U1_FRAME_NAME = "U1Frame";

UUI = UUI or {}
UUI.Main, UUI.Right, UUI.Center, UUI.Left, UUI.Top = {}, {}, {}, {}, {}
setmetatable(UUI, {__call = function() return _G[U1_FRAME_NAME] end})

UUI.DropDownItems = U1_QuickMenus or {}

--[[------------------------------------------------------------
Constants
---------------------------------------------------------------]]
UUI.URL = "http://wowui.w.163.com/163ui";
UUI.DEFAULT_ICON = "Interface\\HelpFrame\\HelpIcon-CharacterStuck" --"Interface\\HelpFrame\\HelpIcon-KnowledgeBase"  --"Interface\\Icons\\INV_Misc_QuestionMark"

UUI.MAX_COL = 5
UUI.BUTTON_W = 192
UUI.BUTTON_H = 42
UUI.ICON_W = 32
UUI.CHECK_W = 24;
UUI.BUTTON_OFFSET = 8      -- Central addon button vertical margin
UUI.BUTTON_P = 8;          -- Central addon button horizonal margin
UUI.CENTER_COLS = 2;
UUI.CENTER_TEXT_LEFT = math.max(2,(UUI.BUTTON_H-UUI.ICON_W)/2-1)*2 + UUI.ICON_W

UUI.PANEL_BUTTON_HEIGHT = 22
UUI.BORDER_WIDTH = 12
UUI.LEFT_WIDTH = 120-UUI.BORDER_WIDTH
UUI.TOP_HEIGHT = 55-UUI.BORDER_WIDTH
UUI.RIGHT_WIDTH = 275-UUI.BORDER_WIDTH

UUI.DEFAULT_TAG = UI163_USER_MODE and "ALL" or "NETEASE"

UUI.FONT_PANEL_BUTTON = "U1FPanelButtonHei"
WW:Font3(UUI.FONT_PANEL_BUTTON, U1.CN and ChatFontNormal or GameFontNormal, U1.CN and 14.1 or 12.1, {{1,.82,0},{1,1,1},{.5,.5,.5}}, nil, 1, -1)
WW:Font3("U1FBannerHei", U1.CN and ChatFontNormal or GameFontNormal, 16, {{.91,.72,0},{1,1,1},{.5,.5,.5}}, nil, 1, -1)
WW:Font3("U1F_LeftTags", U1.CN and ChatFontNormal or GameFontNormal, U1.CN and 14.1 or 12.1, {{0.81, 0.65, 0.48},{1,1,1},{.5,.5,.5}}, nil, 1, -1)
WW:Font("U1FCenterTextMid", U1.CN and ChatFontNormal or GameFontNormal, U1.CN and 14.1 or 12.1):SetFontFlags():SetShadowOffset(2,-2):un();
WW:Font("U1FCenterTextTiny", U1.CN and ChatFontNormal or GameFontNormal, U1.CN and 11 or 9):SetShadowOffset(1,-2):un();

--[[------------------------------------------------------------
Public functions
---------------------------------------------------------------]]
function UUI.Tex(name)
    return "Interface\\AddOns\\"..U1Name.."\\Textures\\"..name
end

local dropDownFuncCheck = function(self, arg1, arg2, on) CtlRegularSaveValue(self, on and 1 or nil, arg1) end
local dropDownFuncAddon = function(self, arg1, arg2, on) U1ToggleAddon(arg1, on) end

--- Translate cfg object to dropdown info, used by QuickMenu
function UUI.TransCfgToDropDown(path, info)
    local path, flagAlways = strsplit(",", path)
    local pos = path:find("/");
    assert(pos, "parameter #1 should be addon/path!")
    local addon, path = path:sub(1, pos - 1), path:sub(pos + 1)
    if select(5, C_AddOns.GetAddOnInfo(addon)) == "MISSING" and not flagAlways then return end
    if path == "" then
        info = info or UIDropDownMenu_CreateInfo()
        table.wipe(info);
        info.isNotRadio = true;
        info.keepShownOnClick = true;
        info.notCheckable = nil;
        info.checked = U1IsAddonEnabled(addon)
        info.func = dropDownFuncAddon;
        info.text = L["AddOn: "] .. U1GetAddonTitle(addon)
        info.fontObject = "CtlFontNormalSmall";
        info.arg1 = addon;
        info.tooltipTitle = L["Quick Enable/Disable AddOn"];
        info.tooltipText = nil;
    else
        if (not U1IsAddonInstalled(addon) and not flagAlways) or (not UI163_USER_MODE and not U1IsAddonRegistered(addon)) then return end
        if not C_AddOns.IsAddOnLoaded(addon) and not flagAlways then return end
        if addon == U1Name:lower() and (path == "sortmem" or path == "english") and not UUI():IsVisible() then return end

        info = info or UIDropDownMenu_CreateInfo()
        --info.tooltipOnButton = 1;
        info.isNotRadio = nil;
        info.keepShownOnClick = true;
        info.notCheckable = nil;
        local value, cfg = U1GetCfgValue(addon, path, 1)
        if not cfg then return end
        if cfg.type == "checkbox" then
            info.isNotRadio = true;
            info.checked = value;
        elseif cfg.type == "button" then
            info.keepShownOnClick = nil;
        end
        info.func = dropDownFuncCheck;
        info.text = cfg.text;
        info.fontObject = "CtlFontNormalSmall";
        info.arg1 = cfg;
        CtlRegularTip(info, cfg);
        info.tooltipTitle = cfg.tipLines and cfg.tipLines[1] .. "|cff00d200 (" .. U1GetAddonTitle(addon) .. ")|r"
        info.tooltipText = cfg.tipLines and table.concat(cfg.tipLines, "\n", 2)
    end
    UIDropDownMenu_AddButton(info);
end

--- change UI size when resize panel width
UUI.changeWithCols = {}
function UUI.AddChangeWithCols(obj, func)
    UUI.changeWithCols[obj] = func;
end
function UUI.ToggleLongShortText(cols, obj)
    local long, short = obj.textLong, obj.textShort;
    local useShort = UUI.CalcWidth(cols) < 680
    WW(obj):SetText(format(useShort and short or long)):AutoWidth():un();
    obj:SetWidth(obj:GetWidth() + 4)
    if obj.flash then
        if useShort then
            WW(obj.flash):TL(-3,2):BR(1,-3):up():un();
        else
            WW(obj.flash):TL(-11,2):BR(8,-3):up():un();
        end
        UUI.ReloadFlashRefresh();
    end
end
function UUI.AddChangeWithColsButton(obj, ...)
    obj:SetText(...)
    obj:SetWidth(obj:GetFontString():GetStringWidth()+(obj.mid and 12 or 0));
    obj.textLong, obj.textShort = ...
    UUI.AddChangeWithCols(obj, UUI.ToggleLongShortText)
end
function UUI.ChangeWithCols()
    for k, v in pairs(UUI.changeWithCols) do v(UUI().center.cols, k) end
    --RunOnNextFrame(CoreCall, "U1_MMBUpdateUI")
end

--- ReloadUI Button flash
--@param from checkBox move starts
--@param enable checkBox checked or not
function UUI.ReloadFlash(from, enable)
    local f = UUI();
    if(next(U1GetReloadList()))then
        f.animCheck:SetChecked(enable)
        f.animCheck.anim:Stop();
        local left1, top1 = f.reload:GetCenter();
        local left2, top2 = from:GetCenter();
        f.animCheck.anim.move:SetOffset(left1-left2, top1-top2)
        f.animCheck.anim.size:SetScale(f.reload:GetWidth()/ from:GetWidth(), f.reload:GetHeight()/ from:GetHeight())
        f.animCheck:ClearAllPoints();
        f.animCheck:SetAllPoints(from);
        f.animCheck:Show();
        f.animCheck:SetFrameLevel(1000);
        f.animCheck.anim:Play();
    end
    UUI.ReloadFlashRefresh();
end

function UUI.ReloadFlashRefresh()
    local flash = UUI().reload.flash
    ActionButton_HideOverlayGlow(flash);
    if(next(U1GetReloadList()))then
        ActionButton_ShowOverlayGlow(flash);
    end
end

--- Show Main Panel on toplevel, or bottom level when raise == false
function UUI.Raise(raise)
    if(U1ProfileFrame and U1ProfileFrame:IsVisible()) then U1ProfileFrame:Hide() end
    local main = UUI();
    if(raise~=false)then
        main:SetFrameStrata("DIALOG");
        main:SetFrameLevel(0);
        main:Raise();
        if(main:GetFrameLevel()>100) then
            main:SetFrameLevel(30);
        end
    else
        if GameMenuFrame:IsVisible() then
            HideUIPanel(GameMenuFrame);
        else
            main:SetFrameStrata("MEDIUM");
            main:Lower();
        end
    end
end

function UUI.MainStartMoving() UUI():StartMoving() end
function UUI.MainStopMoving() UUI():StopMovingOrSizing() end
function UUI.MakeMove(frame)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton");
    frame:SetScript("OnDragStart", UUI.MainStartMoving)
    frame:SetScript("OnDragStop", UUI.MainStopMoving)
    frame:HookScript("OnMouseDown", UUI.Raise)
end

function UUI.ClickAddonCheckBox(self, name, enable, subgroup)
    if(not subgroup and U1GetSelectedAddon()~=name) then U1SelectAddon(name, true) end
    local deepToggleChildren = IsControlKeyDown()
    if enable and not C_AddOns.IsAddOnLoaded(name) then
        -- when an addon is loaded manually, load all children unless pressing CTRL+ALT
        deepToggleChildren = not (IsControlKeyDown() and IsAltKeyDown())
    end

    --todo: temporary conflict handler
    local info = U1GetAddonInfo(name)
    if info then
        local other_loaded = false
        for _, other in ipairs(info.conflicts or _empty_table) do
            if C_AddOns.IsAddOnLoaded(other) then
                EacDisableAddOn(other)
                other_loaded = true
            end
        end
        if other_loaded then EacEnableAddOn(name) return ReloadUI() end
    end

    local needReload = U1ToggleAddon(name, enable, nil, deepToggleChildren);
    UUI.ReloadFlash(self, enable);
    if(not subgroup) then
        UUI.Right.ADDON_SELECTED()
    end
    UUI.Center.Refresh();
end

function UUI.SizeFitCols()
    local main = UUI();
    main:SetWidth(UUI.CalcWidth(main.center.cols));
    local maxRows = math.floor((GetScreenHeight() - 50 - UUI.TOP_HEIGHT - 105) / (UUI.BUTTON_H + UUI.BUTTON_OFFSET))
    main:SetResizeBounds(UUI.CalcWidth(1), UUI.TOP_HEIGHT + (UUI.BUTTON_H + UUI.BUTTON_OFFSET)*3 + 110, UUI.CalcWidth(UUI.MAX_COL), UUI.TOP_HEIGHT + (UUI.BUTTON_H + UUI.BUTTON_OFFSET) * maxRows + 105)
end
function UUI.CalcWidth(cols)
    local need = UUI.LEFT_WIDTH + (UUI.BUTTON_W + UUI.BUTTON_P) * cols + UUI.RIGHT_WIDTH + 48;
    while need < 600 do
        cols = cols + 1
        need = need + (UUI.BUTTON_W + UUI.BUTTON_P)
    end
    return need, cols
end

function UUI.formatTip(label, text)
    return format("|cffffff7f%s：|r%s", label, text);
end
function UUI.getAddonStatus(parent, loaded, enabled, reason, lod, protected)
    local status, reasonInfo
    if loaded then
        lod = lod and protected or nil -- lod is not interest when loaded.
        if(not enabled) then
            status = L["Loaded, reload to disable"]
        else
            status = L["|cff00D100Loaded|r"]
        end
    elseif reason == "MISSING" then
        status = L["|cff00D100Missing|r"]
    elseif not enabled then
        status = L["|cff00D100Disabled|r"]
    elseif(not reason or lod) then
        status = lod and L["Enabled"] or L["Enabled, reloadui to load"]
    else
        if parent and reason=="DEP_DISABLED" then
            status = L["|cffA0A0A0Deps Disabled|r"]
        else
            status = L["|cffff7f7fLoad Failed|r"];
            reasonInfo = _G["U1REASON_"..reason] or reason;
        end
    end
    return status, reasonInfo, lod
end
function UUI.SetAddonTooltipChild(addonName, tip)
    local info = U1GetAddonInfo(addonName);
    if C_AddOns.IsAddOnLoaded(addonName) then
        for subName, subInfo in U1IterateAllAddons() do
            if subInfo.parent == addonName then
                if (C_AddOns.IsAddOnLoaded(subName))then
                    local mem = GetAddOnMemoryUsage(subName);
                    mem = mem > 1000 and format("%.2f MB", mem/1000) or format("%.0f KB", mem)
                    tip:AddDoubleLine(UUI.formatTip(L["Module"],U1GetAddonTitle(subName)), mem, 1,1,1)
                    --TODO: multiple level children
                end
            end
        end
    end
end
function UUI.SetAddonTooltip(addonName, tip)
    tip = tip or GameTooltip;
    local info = U1GetAddonInfo(addonName);
    
    local name, title, notes, _, reason = C_AddOns.GetAddOnInfo(addonName);
	local title = U1GetAddonTitle(addonName, false);
    local enabled = C_AddOns.GetAddOnEnableState(addonName, U1PlayerName)>=2;
    local loaded = C_AddOns.IsAddOnLoaded(name);
	local intro;

    if(InCombatLockdown()) then
        tip:AddLine(L["Loading addons while in combat is not recommended.\n"], 1, .1, .1, 1);
    end

    if info.parent then
        tip:AddLine(L["Module"].."：" .. (title or info.name));
    else
        tip:AddLine(title or info.name);
    end

    --if(info.name ~= info.title)then tip:AddDoubleLine(" ", info.name, 1, 1, 1, 1, 1, 1); end

    if info.parent then
        if(info.author)then
            if info.modifier then
                tip:AddDoubleLine(UUI.formatTip(L["Author"], info.author), UUI.formatTip(L["Credits"], info.modifier), 1, 1, 1, true);
            else
                tip:AddLine(UUI.formatTip(L["Author"], info.author), 1, 1, 1, true);
            end
        end

        if(info.desc) then
            tip:AddLine(" ")
             if(type(info.desc)=="string") then
				intro = info.desc:match("|n.-$");
				if intro then 
					intro = intro:sub(3, intro:len());
					info.desc = intro;
				end
				info.desc = {strsplit("`", info.desc)};
            end
            if(type(info.desc)=="table") then
                for _, txt in ipairs(info.desc) do
                    tip:AddLine(txt, nil, nil, nil, true);
                end
            end
            tip:AddLine(" ")
        end
    else
        tip:AddLine(" ")
    end

    if(info.name ~= info.title)then tip:AddLine(UUI.formatTip(L["Folder"], info.name), 1, 1, 1); end
    if(info.version)then tip:AddLine(UUI.formatTip(L["Version"], info.version), 1, 1, 1, true); end

    local memTip, allmemTip
    if(loaded)then
        local _, subs, allmem = U1GetAddonModsAndMemory(name)
        local mem = GetAddOnMemoryUsage(name);
        mem = mem > 1000 and format("%.2f MB", mem/1000) or format("%.0f KB", mem)
        if subs > 0 then
            allmem = allmem > 1000 and format("%.2f MB", allmem/1000) or format("%.0f KB", allmem)
            allmemTip = UUI.formatTip(L["Total"], allmem)
        end
        memTip = UUI.formatTip(L["Memory"], mem)
    end
    local status, reasonInfo, lod = UUI.getAddonStatus(info.parent, loaded, enabled, reason, info.lod, info.protected);
    tip:AddDoubleLine(UUI.formatTip(L["Status"], status), lod and L["|cff00D100LoD|r"], 1, 1, 1)
    tip:AddDoubleLine(memTip, allmemTip, 1, 1, 1)
    UUI.SetAddonTooltipChild(addonName, tip)
    if(reasonInfo) then
        tip:AddLine(UUI.formatTip(L["Reason"], reasonInfo), 1, .5, .5)
        local depNum = select("#", C_AddOns.GetAddOnDependencies(name));
        if(depNum > 0) then
            for i=1, depNum do
                local depName = select(i, C_AddOns.GetAddOnDependencies(name));
                local _, _, _, _, depReason = C_AddOns.GetAddOnInfo(depName)
                local depEnabled = C_AddOns.GetAddOnEnableState(name, U1PlayerName)>=2
                local status, reasonInfo = UUI.getAddonStatus(nil, C_AddOns.IsAddOnLoaded(depName), depEnabled, depReason, C_AddOns.IsAddOnLoadOnDemand(depName));
                tip:AddLine(UUI.formatTip(L["Depends"], depName.." "..(reasonInfo or status)), 1, 1, 1)
            end
        end
    end

    if UI163_USER_MODE then return end

    tip:AddLine(" ")
    if(not info.vendor)then
        tip:AddLine(L["Individual AddOn"])
    else
        tip:AddLine(L["Package AddOn"], 0, 0.82, 0)
    end
end

do
    local addons = {}
    local order = {}
    local last_tag = nil

    local function mem_sort(a, b)
        return addons[a] > addons[b]
    end

    local function fmt_mem(b)
        if(b > 1e3) then
            return string.format('%.1f m', b/1024)
        else
            return string.format('%d k', b)
        end
    end

    UUI.Left.TagButton_OnEnter = function(self)
        local tag = self.tag
        wipe(addons)
        if(tag ~= last_tag) then
            last_tag = tag
            wipe(order)

            -- addon list of current tag
            for addon, info in U1IterateAllAddons() do
                if(C_AddOns.IsAddOnLoaded(addon) and U1AddonHasTag(addon, tag)) then
                    tinsert(order, addon)
                end
            end
        end

        -- get mem usage
        for _, name in ipairs(order) do
            local mem = GetAddOnMemoryUsage(name)
            addons[name] = mem
        end

        -- sort
        table.sort(order, mem_sort)

        -- display
        GameTooltip:SetOwner(self, 'ANCHOR_LEFT', 5, 0)
        local tag_name = select(3, U1GetTagInfoByName(tag))
        GameTooltip:AddLine(tag_name)
        GameTooltip:AddLine('    ')

        if(#order == 0) then
            GameTooltip:AddLine("|cffFFA3A3" .. L["No Loaded Addons"] .."|r")
        else
            for i = 1, math.min(#order , 10) do
                local addon = order[i]
                GameTooltip:AddDoubleLine('|cffB2E2FF'..U1GetAddonTitle(addon), '|cffB2FFC2'..fmt_mem(addons[addon]))
            end
        end

        GameTooltip:Show()
    end
end

UUI.Left.TagButton_OnLeave = function(self)
    GameTooltip:Hide()
end

--[[------------------------------------------------------------
Left Panel (Tags)
---------------------------------------------------------------]]
function UUI.Left.Create(main)
    local left = main:Frame(nil, nil, "left"):TL(0, -UUI.TOP_HEIGHT-1):BR(main, "BL", UUI.LEFT_WIDTH, 0);

    left:Button():Key("btn163"):Size(128,32):TL(-14,-6):Set3Fonts("U1FBannerHei"):SetText(L["  All AddOns  "])
    :Texture(nil, nil, UUI.Tex'UI2-banner', 0,1,0,0.5):ToTexture("Normal"):ALL():up():un()

    left.btn163.tag = UUI.DEFAULT_TAG
    left.btn163:SetScript('OnClick', UUI.Left.ButtonOnClick)
    left.btn163:SetScript('OnEnter', UUI.Left.TagButton_OnEnter)
    left.btn163:SetScript('OnLeave', UUI.Left.TagButton_OnLeave)

    local scroll = CoreUICreateHybridStep1(nil, left(), nil, nil, nil, "LINE")
    UUI.MakeMove(scroll);
    left.scroll = scroll;
    WW(scroll):TL(3, -65):BR(0, 20):SetSize(110, 100):un()

    scroll.creator = UUI.Left.ScrollHybridCreator
    scroll.updateFunc = UUI.Left.ScrollHybridUpdater
    scroll.getNumFunc = function() return U1GetNumTags() end

    -- custom scroll bar
    scroll.noScrollBar = true;
    scroll.scrollBar.IsVisible = function() return 1 end --cheat HybridScrollFrameScrollButton_OnClick
    scroll.scrollUp = UUI.Left.CreateScrollButton(scroll, 1):BOTTOM(scroll, 'TOP', 0, 1)
    scroll.scrollDown = UUI.Left.CreateScrollButton(scroll, -1):TOP(scroll, 'BOTTOM', 0, -0)

    CoreUICreateHybridStep2(scroll, 0, 0, "TOPLEFT", "TOPLEFT", 2)

    -- shadow on edge
    WW:Frame(nil, scroll):ALL()
    :Texture(nil, "OVERLAY", UUI.Tex'UI2-shade-dark-deeper'):SetTexRotate(180):TL(0,1):BR(scroll, "TR", 0, -4):up()
    :Texture(nil, "OVERLAY", UUI.Tex'UI2-shade-dark-deeper'):BL(0,-2):TR(scroll, "BR", 0, 8):up()
    :un();

    left:SetScript("OnSizeChanged", CoreUICreateHybridButtonsOnSizeChanged)

    return left
end

function UUI.Left.CreateScrollButton(scroll, direction)
    local l, r, t, b = 2/128, 106/128+2/128, 0, 20/64
    if direction < 0 then t=0.5 b=b+0.5 end
    local btn = WW(scroll):Button():Size(106, 20)
    :Texture(nil, nil, UUI.Tex'UI2-left-scroll', l, r, t, b):ToTexture("Normal"):ALL():up()
    :Texture(nil, nil, UUI.Tex'UI2-left-scroll', l, r, t, b):ToTexture("Disabled"):ALL():up()
    :Texture(nil, nil, "Interface\\Buttons\\UI-Silver-Button-Highlight", 0, 1, 0.03, 0.7175):ToTexture("Highlight"):SetAlpha(0.7):TL(-4, 6):BR(1, -6):up()
    :Texture(nil, nil, UUI.Tex'UI2-left-scroll', l-1/128, r-1/128, t-1/64, b-1/64):ToTexture("Pushed"):ALL():up()

    btn:GetDisabledTexture():SetDesaturated(1)
    btn:GetDisabledTexture():SetVertexColor(.75, .75, .75);
    btn.direction = direction
    btn.parent = scroll; --use HybridScrollFrameScrollButton_OnClick, parent must be scroll, and MouseDown
    btn:RegisterForClicks("LeftButtonUp", "LeftButtonDown");
    btn:SetScript('OnClick', HybridScrollFrameScrollButton_OnClick)

    return btn
end

function UUI.Left.ScrollHybridCreator(self, index, name)
    local btn = WW:Button(nil, self.scrollChild):Size(104, 32):Set3Fonts("U1F_LeftTags"):SetText("ABC")
    :Texture(nil, nil, UUI.Tex'UI2-left-btn', 0,104/128,0,0.25):ToTexture("Normal"):ALL():up()
    :Texture(nil, nil, UUI.Tex'UI2-left-btn', 0,104/128,0.25,0.5):ToTexture("Highlight"):SetAlpha(0.3):ALL():up()
    :Texture(nil, nil, UUI.Tex'UI2-left-btn', 0,104/128,0.5,0.75):ToTexture("Pushed"):ALL():up()

    btn:GetFontString():SetSize(btn:GetSize())
    btn:GetFontString():SetMaxLines((U1.CN or UUI.BUTTON_H < 26) and 1 or 2)

    btn:SetScript('OnClick', UUI.Left.ButtonOnClick);

    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", UUI.Left.ScrollOnDragStart);
    btn:SetScript("OnDragStop", UUI.Left.ScrollOnDragStop);
    btn:SetScript('OnEnter', UUI.Left.TagButton_OnEnter)
    btn:SetScript('OnLeave', UUI.Left.TagButton_OnLeave)

    return btn()
end

function UUI.Left.ScrollHybridUpdater(self, button, index)
    local name, num, caption, special = U1GetTagInfo(index);
    button:SetText(caption)
    --button:SetNormalFontObject(special and U1ButtonNormalFontSpecial or U1ButtonNormalFontNormal);
    button.tag = name;

    if (button.tag == U1GetSelectedTag()) then
        button:GetNormalTexture():SetTexCoord(0,0.8125,0.5,0.75);
        button:GetFontString():SetTextColor(1, .96, .63)
    else
        button:GetFontString():SetTextColor(0.81, 0.65, 0.48)
        button:GetNormalTexture():SetTexCoord(0,0.8125,0,0.25);
    end
end

--- Drag tags to scroll
function UUI.Left.ScrollOnUpdateDrag(self)
    local y = select(2, GetCursorPosition());
    self.scrollBar:SetValue(self.scrollBar:GetValue() + y - self.dragging);
    self.dragging = y;
end

function UUI.Left.ScrollOnDragStart(self)
    local scroll = self:GetParent():GetParent();
    scroll.dragging = select(2, GetCursorPosition());
    scroll:SetScript("OnUpdate", UUI.Left.ScrollOnUpdateDrag);
end

function UUI.Left.ScrollOnDragStop(self)
    local scroll = self:GetParent():GetParent();
    scroll.dragging = nil;
    scroll:SetScript("OnUpdate", nil);
end

function UUI.Left.ButtonOnClick(self)
    local search = UUI().search;
    search:SetText("");
    search:SetFocus();
    search:ClearFocus();
    U1SelectTag(self.tag);
end

--[[------------------------------------------------------------
Top Operation Buttons
---------------------------------------------------------------]]
function UUI.Top.Create(main)
    -- TopLeft logo and title
    main:CreateTexture():Key("logo"):SetTexture(UUI.Tex"UI2-logo"):TL(-18, 38):Size(87):un()
-- 移除左上角的標題圖案
--[[
    if U1.CN then
        main:Texture(nil, nil, UUI.Tex'UI2-text', 0,1,0,0.5):TL(74, -7):Size(256,32):un()
        local url = main:Button():Size(180, 32):TL(180, -11):Texture(nil, nil, UUI.Tex'UI2-text', 0,180/256,0.5,1):ALL():ToTexture("Normal"):up():un()
        url:SetScript("OnClick", function() CoreUISetEditText(UUI.URL) end)
        UUI.MakeMove(url)
    else
        main:CreateFontString():SetJustifyH("LEFT"):SetFont(UUI.Tex"FORCED SQUARE.ttf", 30, "OUTLINE"):SetShadowOffset(3,-3):SetShadowColor(0.41, 0.35, 0.28):SetTextColor(0.81, 0.65, 0.48):SetText("Ease AddOn Controller"):TL(74+5, -7+2):Size(256+128,32):un()
    end
--]]	 
	main:CreateFontString():SetJustifyH("LEFT"):SetFont(UUI.Tex"FORCED SQUARE.ttf", 30, "OUTLINE"):SetShadowOffset(3,-3):SetShadowColor(0.41, 0.35, 0.28):SetTextColor(0.81, 0.65, 0.48):SetText("Ease AddOn Controller"):TL(74+5, -7+2):Size(256+128,32):un()

    -- TopRight close button
    main.btnClose = main:Button(nil, "UIPanelCloseButton"):Size(30):TR(5, 5)
    :SetScript("OnClick", function(self) HideUIPanel(self:GetParent()) end)
    :un()
    -- Border of close button
    main:Texture(nil, nil, "Interface\\Buttons\\UI-CheckBox-Up"):TL(main.btnClose,1,0):BR(main.btnClose,-1,-1):un()

    -- Top Operation Buttons
    main.setting = TplPanelButton(main,nil, UUI.PANEL_BUTTON_HEIGHT):Set3Fonts(UUI.FONT_PANEL_BUTTON)
    :SetScript("OnClick", function()
        CloseDropDownMenus(1);
        if(UUI().right.addonName==U1Name) then
            UUI.Right.ADDON_SELECTED()
        else
            UUI.Right.ADDON_SELECTED(U1Name) UUI.Right.TabChange(1)
        end
    end)
    :Frame("$parentSettingDropdown", "UIDropDownMenuTemplate", "drop"):TL("$parent", "BL", 0, 0):up()
    :Button():Key("dropbutton"):Size(20,UUI.PANEL_BUTTON_HEIGHT+6):LEFT("$parent", "RIGHT", -6, -1)
	:SetNormalTexture("Interface/ChatFrame/UI-ChatIcon-ScrollDown-Up")
	:SetPushedTexture("Interface/ChatFrame/UI-ChatIcon-ScrollDown-Down")
	:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
    :SetScript("OnClick", UUI.Top.ToggleQuickSettingDropDown):up()
    :un()
    CoreUIEnableTooltip(main.setting, L["EAC Options"], L["Show Ease Addon Controller's option page. Click again to return to the previous selected addon."])
    CoreUIEnableTooltip(main.setting.dropbutton, L["Quick Menu"], L["Show frequently used toggle options, in a dropdown menu."])
    UUI.AddChangeWithColsButton(main.setting, L["EAC Options"], L["OP"])

    do
        --- Scale Slider
        main.setting.sliderPanel = WW:Frame(nil, UIParent, "BackdropTemplate"):Size(60,175):TL(DropDownList1, "TR", -3, 0):SetFrameStrata("FULLSCREEN_DIALOG"):Hide()
        :Backdrop("Interface\\Tooltips\\UI-Tooltip-Background", "Interface\\Tooltips\\UI-Tooltip-Border", 16, {5,5,5,4}, 16)
        :SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
        :SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
        :EnableMouse(true)
        :SetScript("OnShow", function(self) WW(self):TL(DropDownList1, "TR", -3, 0):un() end)
        :SetScript("OnEnter", UIDropDownMenu_StopCounting):SetScript("OnLeave", UIDropDownMenu_StartCounting)
        :un()
        main.setting.sliderPanel.parent = DropDownList1; --stopCounting

        local scaleSlider = TplSlider(main.setting.sliderPanel, nil, L["Scale"], 1, "%d%%", 50, 150, 10):Size(12,128):TOP(-10, -35)
        :SetScript("OnEnter", UIDropDownMenu_StopCounting):SetScript("OnLeave", UIDropDownMenu_StartCounting)
        :SetScript("OnShow", function(self) self:SetValue(150 + 50 - U1GetCfgValue(U1Name.."/scale")*100) end):un()
        scaleSlider.func = function(self, v) self:GetParent():ClearAllPoints() U1ChangeCfg(U1Name.."/scale", floor(v/10)/10) end
        scaleSlider.parent = DropDownList1; --StopCounting
        DropDownList1:HookScript("OnHide", function() main.setting.sliderPanel:Hide() end)
    end

    main.reload = TplPanelButton(main,nil, UUI.PANEL_BUTTON_HEIGHT):Set3Fonts(UUI.FONT_PANEL_BUTTON)
    :SetScript("OnClick", function(self) self.hint:SetFrameLevel(self:GetFrameLevel()+1) CoreScheduleTimer(false, 0.4, self.hint.Show, self.hint) end)
    :SetScript("OnEnter", UUI.Top.ReloadOnEnter)
    :SetScript("OnDoubleClick", function(self) ReloadUI();end)
    :Frame():Key("flash"):SetAlpha(0.5):TL(-11,2):BR(8,-3):up()
    :un()
    UUI.AddChangeWithColsButton(main.reload, L["ReloadUI"], L["RL"])
    local hint = TplGlowHint(main.reload, "$parentReloadHint", 240):Key("hint"):BOTTOM("$parent", "TOP", 0, 20):Hide():un()
    hint.text:SetText(L["Please DOUBLE click to confirm"]);

    main.collect = TplPanelButton(main,nil, UUI.PANEL_BUTTON_HEIGHT):Set3Fonts(UUI.FONT_PANEL_BUTTON)
    :SetScript("OnClick", function(self) collectgarbage(); UpdateAddOnMemoryUsage(); U1SortAddons() end)
    :un()
    CoreUIEnableTooltip(main.collect, L["Memory Garbage Collect"], L["desc.GC"])
    UUI.AddChangeWithColsButton(main.collect, L["MemoryGC"], L["GC"])

    main.profile = TplPanelButton(main,nil, UUI.PANEL_BUTTON_HEIGHT):Set3Fonts(UUI.FONT_PANEL_BUTTON)
    :SetScript("OnMouseDown", function(self)
        if not U1ProfileFrame then U1Profiles:CreateFrame() return end
        CoreUIShowOrHide(U1ProfileFrame, not U1ProfileFrame:IsVisible())
        U1ProfileFrame:SetFrameLevel(UUI():GetFrameLevel()+10)
    end)
    CoreUIEnableTooltip(main.profile, L["Profiles"], L["Save addons status and control panel settings, and share the profile among characters."])
    UUI.AddChangeWithColsButton(main.profile, L["Profiles"], L["PF"])

    CoreUIAnchor(main,"TOPRIGHT","TOPRIGHT",-28-20,-12,"RIGHT", "LEFT",-8,0, main.setting, main.collect, main.profile, main.reload);
end

function UUI.Top.ToggleQuickSettingDropDown(self)
    GameTooltip:Hide()
    if not self._inited then
        self._inited = true
        UIDropDownMenu_Initialize(UUI().setting.drop, UUI.Top.QuickSettingDropDownMenuInitialize, "MENU"); -- taint here
    end
    ToggleDropDownMenu(1, nil, UUI().setting.drop, self, 0, 0)
    if DropDownList1:IsVisible() then UUI().setting.sliderPanel:Show() end
end

function UUI.Top.QuickSettingDropDownMenuInitialize(frame, level, menuList)
    frame.point = "TOPRIGHT"; frame.relativePoint = "BOTTOMRIGHT";
    local info = UIDropDownMenu_CreateInfo();
    info.isNotRadio = 1; info.notCheckable = 1; info.isTitle = 1; info.justifyH = "CENTER"; info.text = L["Quick Menu"];
    UIDropDownMenu_AddButton(info);
    --info.text = "";
    --UIDropDownMenu_AddButton(info);
    table.wipe(info);
    local items = U1DBG.qSet or UUI.DropDownItems
    for _, v in ipairs(items) do
        UUI.TransCfgToDropDown(v, info)
    end
end

function UUI.Top.ReloadOnEnter(self)
    local tmp = _temp_table
    local reloadList = U1GetReloadList();
    if(next(reloadList))then
        GameTooltip:SetOwner(self);
        GameTooltip:AddLine(L["Operations require reloading: "],1,1,1);
        local i=0
        table.wipe(tmp)

        -- remember disabled addons, Disable is prior
        for k,v in pairs(reloadList) do
            local name, type = strsplit("/", k)
            tmp[name] = type
        end
        for k,v in pairs(reloadList) do
            local name, type = strsplit("/", k);
            local info = U1GetAddonInfo(name);
            while info.parent do
                info = U1GetAddonInfo(info.parent)
                type = "config" --disabling sub shows 'Config - <parent>'
            end
            name = info.name:lower()
            if tmp[name] ~= 1 then
                local title = U1GetAddonTitle(name);
                if tmp[name] == "__disable" or type == "__disable" then
                    GameTooltip:AddLine( L["|cffff0000Disable|r - "] .. title)
                else
                    GameTooltip:AddLine( L["Modified - "] .. title)
                end
                tmp[name] = 1
                i=i+1
                if(i>10)then GameTooltip:AddLine("..."); break end
            end
        end
        GameTooltip:Show();
    end
end

--[[------------------------------------------------------------
Central Panel
---------------------------------------------------------------]]
function UUI.Center.Create(main)
    local center = main:Frame(nil, "BackdropTemplate"):Key("center"):TL(UUI.LEFT_WIDTH+11, -(UUI.TOP_HEIGHT+10+24+10)):BR(-UUI.RIGHT_WIDTH-9, 12):Backdrop("Interface\\GLUES\\COMMON\\Glue-Tooltip-Background")
    local tl = CoreUIDrawBorder(center, 1, "U1T_InnerBorder", 16, UUI.Tex'UI2-border-inner-corner', 16, true)

    local scroll = CoreUICreateHybridStep1(nil, center(), 9, nil, true, "LINE")
    UUI.MakeMove(scroll);
    center.scroll = scroll;
    WW(scroll):TL(UUI.BUTTON_P+2,-UUI.BUTTON_P-2):BR(-23, 41):un();
    scroll:SetSize(409,325)
    scroll.scrollBar.doNotHide = 1

    center:Texture(nil, "BORDER", UUI.Tex'UI2-scroll-end'):Size(32):TR():up()
    :Texture(nil, "BORDER", UUI.Tex'UI2-scroll-end'):Size(32):BR():SetTexRotate("V"):up()
    :CreateTexture(nil, "BORDER", 'U1T_ScrollMid'):Size(32):TL("$parent", "TR", -32, -32):BR(0, 32):up()

    WW(scroll.scrollBar):TL(scroll, "TR", 1, -9):BL(scroll, "BR", 1, -21)
    :AddFrameLevel(1)
    :un()

    WW(scroll.scrollUp):TOP(0,17):Size(18,17):un();
    WW(scroll.scrollDown):BOTTOM(0,-17):Size(18,17):un();

    --WW(scroll):CreateTexture():SetTexture(1,1,1):ALL()
    scroll.creator = UUI.Center.ScrollHybridCreator;
    scroll.updateFunc = UUI.Center.ScrollHybridUpdater;
    function scroll:getNumFunc()
        return math.ceil(U1GetNumCurrentAddOns()/self:GetParent().cols);
    end
    center.cols = UUI.CENTER_COLS
    CoreUICreateHybridStep2(scroll, 0, 0, "TOPLEFT", "TOPLEFT", UUI.BUTTON_OFFSET)

    -- bottom background
    local l = center:Texture(nil, "BORDER", UUI.Tex'UI2-bg-bottom-end'):BL(2,-24):SetSize(16, 64)
    local r = center:Texture(nil, "BORDER", UUI.Tex'UI2-bg-bottom-end'):BR(-21,-24):SetSize(16, 64):SetTexRotate("H")
    center:CreateTexture(nil, "BORDER", 'U1T_BottomMid'):Size(16,64):TL(l, "TR"):BR(r, "BL"):up()
    center:Frame():CreateTexture(nil, "OVERLAY"):SetTexture(UUI.Tex'UI2-shade-dark-deeper'):ALL():up():SetHeight(32):BL(l,"TL"):BR(r,"TR"):AddFrameLevel(2, center)

    local btn = TplPanelButton(center,nil, UUI.PANEL_BUTTON_HEIGHT):Set3Fonts(UUI.FONT_PANEL_BUTTON)
    :SetScript("OnClick", UUI.Center.BtnLoadAllOnClick):un();
    UUI.AddChangeWithColsButton(btn, L["Load All"], L["short.LoadAll"])
    CoreUIEnableTooltip(btn, L["Load all addons in the above list"], function(self, tip)
        if InCombatLockdown() then
            tip:AddLine(L["Loading addons while in combat is not recommended.\n"], 1, .1, .1, 1)
        end
        tip:AddLine(L["The game may freeze for a little while."], nil, nil, nil, 1)
    end)
    main.btnLoadAll = btn;

    local btn = TplPanelButton(center,nil, UUI.PANEL_BUTTON_HEIGHT):Set3Fonts(UUI.FONT_PANEL_BUTTON)
    :SetScript("OnClick", UUI.Center.BtnDisAllOnClick):un();
    UUI.AddChangeWithColsButton(btn, L["Disable All"], L["short.DisableAll"])
    CoreUIEnableTooltip(btn, L["Disable all addons in the above list"], function(self, tip)
        if InCombatLockdown() then
            tip:AddLine(L["Loading addons while in combat is not recommended.\n"], 1, .1, .1, 1)
        end
        tip:AddLine(L["UI reloading is required to really disable addons."], nil, nil, nil, 1)
    end);
    main.btnDisAll = btn;

    CoreUIAnchor(center(), "BOTTOMRIGHT", "BOTTOMRIGHT", -30, 10, "RIGHT", "LEFT", -5, 0, main.btnDisAll, main.btnLoadAll)

    local chkLoaded = TplCheckButton(center):Key("chkLoaded"):Size(24):Set3Fonts(UUI.FONT_PANEL_BUTTON):SetText(L["Enabled"]):SetScript('OnClick', UUI.Center.FilterButtonOnClick):un()
    chkLoaded.tag = 'LOADED'
    CoreUIEnableTooltip(chkLoaded, L["Hint"], L["Show or hide the loaded addons in the above list"])
    local chkDisabled = TplCheckButton(center):Key("chkDisabled"):Size(24):Set3Fonts(UUI.FONT_PANEL_BUTTON):SetText(L["Disabled"]):SetScript('OnClick', UUI.Center.FilterButtonOnClick):un()
    chkDisabled.tag = 'NLOADED'
    CoreUIEnableTooltip(chkDisabled, L["Hint"], L["Show or hide the disabled addons in the above list"])
    chkLoaded.other = chkDisabled
    chkDisabled.other = chkLoaded

    chkLoaded:SetPoint("BOTTOMLEFT", 10, 8);
    chkDisabled:SetPoint("LEFT", chkLoaded.text, "RIGHT", 5, -1);

    UUI.AddChangeWithCols("Center.FilterButtonAdjust", UUI.Center.FilterButtonAdjust)
end

function UUI.Center.ScrollToAddon(name)
    local center = UUI().center
    name = name or U1GetSelectedAddon()
    if(name) then
        for i=1, U1GetNumCurrentAddOns() do
            if U1GetCurrentAddOnInfo(i) == name then
                CoreUIScrollTo(center.scroll, math.ceil(i / center.cols) - 1);
                return;
            end
        end
    end
end

function UUI.Center.Resize(self)
    CoreUICreateHybridButtonsOnSizeChanged(self);
    UUI.SizeFitCols();
end

function UUI.Center.Refresh()
    UUI().center.scroll.update();
end

function UUI.Center.ButtonOnClick(self)
    local f = UUI()
    if(self.addonName == U1GetSelectedAddon() and (f.right:IsVisible() and f.right.addonName==self.addonName))then
        U1SelectAddon(nil, true);
        UUI.Center.Refresh();  -- for selected border
    else
        U1SelectAddon(self.addonName);
    end
end

function UUI.Center.ButtonUpdateTooltip(self)
    if not self.addonName then return end
    GameTooltip_SetDefaultAnchor(GameTooltip, self)
    UUI.SetAddonTooltip(self.addonName, GameTooltip);
    GameTooltip:Show();
end
function UUI.Center.ButtonOnEnter(self)
    UUI.Center.ButtonUpdateTooltip(self)
    local info = U1GetAddonInfo(self.addonName)
    if info and info.installed then
        self.text1:SetTextColor(1, .96, .63)
    end
end
function UUI.Center.ButtonOnLeave(self)
    local f = UUI();
    local txt = self.text1
    txt:SetTextColor(txt.r, txt.g, txt.b, txt.a)
    GameTooltip:Hide();
end

function UUI.Center.CheckOnClick(self)
    UUI.ClickAddonCheckBox(self, self:GetParent().addonName, self:GetChecked());
end
function UUI.Center.CheckOnEnter(self)
    local btn = self:GetParent();
    WW(btn):On("Enter"):LockHighlight():un()
end
function UUI.Center.CheckOnLeave(self)
    local btn = self:GetParent();
    WW(btn):On("Leave"):UnlockHighlight():un()
end

-- create one of the buttons in a row.
function UUI.Center.ScrollCreateOnButton(lineButton)
    local b = lineButton:Button():Size(UUI.BUTTON_W, UUI.BUTTON_H);
    b:SetMotionScriptsWhileDisabled(true);
    --b.tooltipAnchorPoint = "ANCHOR_TOPLEFT"; -- fix tip to default position
    CoreUIEnableTooltip(b);
    b:SetScript("OnEnter", UUI.Center.ButtonOnEnter);
    b:SetScript("OnClick", UUI.Center.ButtonOnClick);
    b:SetScript("OnLeave", UUI.Center.ButtonOnLeave);
    b.UpdateTooltip = UUI.Center.ButtonUpdateTooltip; --can't start new line

    -- if create texture directly, highlight effect is different.
    local anchor = (UUI.BUTTON_H - UUI.ICON_W)/2
    -- 經典版移除圖示
	if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
		local icon = b:Frame():Key("icon"):Size(UUI.ICON_W):TL(math.max(2, anchor-2), -anchor+1)
		:Texture():Key("tex"):ALL():SetTexture("Interface\\Buttons\\Button-Backpack-Up"):up()
		:un();
	end

    local check = b:CheckButton(nil, "UICheckButtonTemplate"):Key("check"):RIGHT(-UUI.CHECK_W/4, 0):Size(UUI.CHECK_W):AddFrameLevel(1)
    :SetMotionScriptsWhileDisabled(true)
    :SetScript("OnClick", UUI.Center.CheckOnClick)
    :SetScript("OnEnter", UUI.Center.CheckOnEnter)
    :SetScript("OnLeave", UUI.Center.CheckOnLeave)
    :un()

    b:CreateFontString():Key("text1"):LEFT(UUI.CENTER_TEXT_LEFT, 1):RIGHT(check, "LEFT", 2, 0):SetJustifyH("LEFT"):SetNonSpaceWrap(false):un()

    b:CreateFontString():Key("text2"):LEFT(UUI.CENTER_TEXT_LEFT, -9):RIGHT(check, "LEFT", 2, 0):SetJustifyH("LEFT"):SetFontObject(U1FCenterTextTiny):SetMaxLines(1):un()

    b:Texture(nil, "BACKGROUND", UUI.Tex"UI2-center-btn", 0,.75,0,.1875):ToTexture("Normal"):ALL():un() --0,192/256,0/256,48/256
    --b:Texture(nil, "BACKGROUND", UUI.Tex"UI2-center-btn", 0,.75,.375,.5625):ToTexture("Pushed"):ALL():un() --0,192/256,96/256,144/256
    b:Texture(nil, "HIGHLIGHT", UUI.Tex"UI2-center-btn", 0,.75,.1875,.375):ToTexture("Highlight", "ADD"):ALL():SetAlpha(.4):un() --0,192/256,48/256,96/256

    return b:un();
end

function UUI.Center.ScrollHybridCreator(self, index, name)
    local btn = WW(self.scrollChild):Frame(name):Size(1, UUI.BUTTON_H);
    local height = btn:GetHeight();
    btn.btns = {};
    for i = 1, UUI.MAX_COL do
        btn.btns[i] = UUI.Center.ScrollCreateOnButton(btn);
        if (i == 1) then
            btn.btns[i]:SetPoint("LEFT", 0, 0);
        else
            btn.btns[i]:SetPoint("LEFT", btn.btns[i - 1], "RIGHT", UUI.BUTTON_P, 0);
        end
    end
    return btn:un();
end

function UUI.Center.ScrollUpdateOneButton(b, idx)
    local addonName, info = U1GetCurrentAddOnInfo(idx);
    b.addonName = addonName;

    b.text1:SetFontObject( U1.CN and (not UI163_USER_MODE and not info.registered or U1GetShowOrigin()) and U1FCenterTextTiny or U1FCenterTextMid)

    if(not info.icon) then
        if(not info.noAddonLoaderLDBIcon) then
            info.noAddonLoaderLDBIcon = true
            local meta = C_AddOns.GetAddOnMetadata(addonName, 'X-LoadOn-LDB-Launcher')
            if(meta) then
                local texture, brokername = string.split(' ', meta)
                if(texture) then
                    info.icon = texture
                end
            end
        end

        if(not info.icon) then
            local dataobj = DataBroker:GetDataObjectByName(addonName)
            or DataBroker:GetDataObjectByName(addonName..'Launcher')
            or DataBroker:GetDataObjectByName('Broker_'..addonName)
            if(dataobj and dataobj.icon) then
                info.icon = dataobj.icon
            end
        end
    end

    -- 經典版移除圖示
	if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
		b.icon.tex:SetTexture(info.icon or UUI.DEFAULT_ICON)
	end

    local addonId = info.installed;
    if addonId then
        b:Enable();
        b:GetHighlightTexture():Show()
        -- 經典版移除圖示
		if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
			b.icon.tex:SetVertexColor(1,1,1)
		end
        b.check:Show()

        CoreUIEnableOrDisable(b.check, not info.protected and not InCombatLockdown());
        b.check:SetChecked(U1IsAddonEnabled(addonName));

        b.text1:SetShadowOffset(2, -2)

        -- distinguish form Disabled and Loaded
        local enabled = U1IsAddonEnabled(addonName)
        local loaded = C_AddOns.IsAddOnLoaded(addonName)
        if loaded or (false and info.lod and enabled) then
            b.text1:SetShadowOffset(2,-2)
            b:GetNormalTexture():SetVertexColor(1,1,1)
            -- 經典版移除圖示
			if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
				CoreUIUndesaturateTexture(b.icon.tex);
			end
            CoreUIUndesaturateTexture(b:GetNormalTexture());
            if(enabled) then
                b.text1:SetTextColor(0.81, 0.65, 0.48);
            else
                b.text1:SetTextColor(0.71, 0.5, 0.30);
            end
        else
            b.text1:SetShadowOffset(1,-1)
            b:GetNormalTexture():SetVertexColor(.75,.75,.75)
            -- 經典版移除圖示
			if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
				if not (info.lod and enabled) then CoreUIDesaturateTexture(b.icon.tex); end
			end
            CoreUIDesaturateTexture(b:GetNormalTexture());
            if(enabled) then
                if info.lod then
                    b.text1:SetTextColor(0.81, 0.65, 0.48);
                else
                    b.text1:SetTextColor(1, .2, .2);
                end
            else
                b.text1:SetTextColor(.5, .5, .5);
            end
        end

        -- selected addon
        if(addonName==U1GetSelectedAddon())then
            b.text1:SetTextColor(1, .96, .63)
            b:GetNormalTexture():SetTexCoord(0,.75,.375,.5625)
            CoreUIUndesaturateTexture(b:GetNormalTexture());
        else
            b:GetNormalTexture():SetTexCoord(0,.75,0,.185) --.1875 cut a bit to awoid white line
        end
    else
        b:Disable();
        b:GetHighlightTexture():Hide()
        -- 經典版移除圖示
		if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
			b.icon.tex:SetVertexColor(.3,.3,.3)
		end
        b.check:Hide()

        b.text1:SetTextColor(.5, .5, .5, .5);
        b:GetNormalTexture():SetTexCoord(0,.75,0,.185)
        b:GetNormalTexture():SetVertexColor(.3,.3,.3)
        CoreUIDesaturateTexture(b:GetNormalTexture())
        -- 經典版移除圖示
		if WOW_PROJECT_ID ~= WOW_PROJECT_CLASSIC then
			CoreUIDesaturateTexture(b.icon.tex);
		end
    end

    -- highlight when searching
    local text = UUI().search:GetSearchText()
    local title = U1GetAddonTitle(addonName)
    local showText2 = false
    if(text=="")then
        b.text1:SetText(title);
    else
        local pattern = nocase(text);
        if(title:find(pattern)) then
            b.text1:SetText(title:gsub(pattern, "|cff00ff00%0|r"));
        elseif(addonName:find(pattern)) then
            b.text1:SetText(title);
            b.text2:SetText(info.name:gsub(pattern, "|cff00ff00%0|r"))
            showText2 = true
        else
            b.text1:SetText(title);
        end
    end
    CoreUIShowOrHide(b.text2, showText2)
    b.text1:SetMaxLines(showText2 and 1 or ((U1.CN or UUI.BUTTON_H < 26) and 1 or 2))
    b.text1:SetPoint("LEFT", UUI.CENTER_TEXT_LEFT, showText2 and (U1.CN and 8 or 6) or 1)

    local txt = b.text1
    txt.r, txt.g, txt.b, txt.a = txt:GetTextColor() -- restore searching highlight after mouse over
    if addonId and b:IsMouseOver() then b.text1:SetTextColor(1, .96, .63) end
end

function UUI.Center.ScrollHybridUpdater(self, button, index)
    local cols = self:GetParent().cols;
    for i = 1, #button.btns do
        local b = button.btns[i]
        if i>cols then
            b:Hide()
        else
            local idx=(index-1)*cols+i;
            if idx >U1GetNumCurrentAddOns()then
                b:Hide()
            else
                UUI.Center.ScrollUpdateOneButton(b, idx)
                b:Show();
            end
        end
    end
end

function UUI.Center.FilterButtonOnClick(self)
    local other = self.other
    if(self:GetChecked() == other:GetChecked()) then
        U1SetAdditionalFilter(nil)
    else
        local tag = self:GetChecked() and self.tag
        if(other:GetChecked()) then
            tag = other.tag
        end
        U1SetAdditionalFilter(tag)
    end
end

function UUI.Center.FilterButtonAdjust(cols)
    local main = UUI()
    local width = UUI.CalcWidth(cols)
    main.center.chkLoaded:SetText(width<800 and format("|cff00ff00 %d|r", select(2, U1GetTagInfoByName("LOADED"))) or format(L["|cff00ff00 %d|r Enabled"], select(2, U1GetTagInfoByName("LOADED"))));
    main.center.chkDisabled:SetText(width<800 and format("|cffAAAAAA %d|r", select(2, U1GetTagInfoByName("NLOADED"))) or format(L["|cffAAAAAA %d|r Disabled"], select(2, U1GetTagInfoByName("NLOADED"))));
end

UUI.addonToLoad, UUI.loadTimer = {}, nil
function UUI.LoadAddons(deepToggleChildren)
    --if InCombatLockdown() then return end
    local used = 0;
    while (used < 0.2) do
        local name = table.remove(UUI.addonToLoad, 1);
        if(not name) then
            U1Message(L["All of selected addons are loaded."])
            CoreCancelTimer(UUI.loadTimer);
            UUI.loadTimer = nil
            UUI.Center.Refresh();
            UUI.Right.ADDON_SELECTED();
            return
        end
        if(not C_AddOns.IsAddOnLoaded(name)) then
            U1ToggleAddon(name, true, nil, deepToggleChildren)
            used = used + 0.1;
        end
    end
end

function UUI.Center.BtnLoadAllOnClick(self)
    if UUI.loadTimer then return end
    local deepToggleChildren = true --IsControlKeyDown()
    table.wipe(UUI.addonToLoad)
    local names = {}
    for i=1, U1GetNumCurrentAddOns() do names[i] = U1GetCurrentAddOnInfo(i) end
    for _, name in ipairs(names) do
        local info = U1GetAddonInfo(name);
        if (not U1IsAddonEnabled(name) and (info.installed or info.dummy)) then
            if not info.ignoreLoadAll then
                if not C_AddOns.IsAddOnLoaded(name) then
                    table.insert(UUI.addonToLoad, name)
                else
                    U1ToggleAddon(name, true, nil, deepToggleChildren)
                end
            end
        else
            if deepToggleChildren then
                U1ToggleChildren(name, true, nil, true)
            end
        end
    end
    UUI.loadTimer = CoreScheduleTimer(true, 0.05, UUI.LoadAddons, deepToggleChildren);
end

function UUI.Center.BtnDisAllOnClick(self)
    local names = {}
    local deepToggleChildren = IsControlKeyDown()
    for i=1, U1GetNumCurrentAddOns() do names[i] = U1GetCurrentAddOnInfo(i) end
    for _, name in ipairs(names) do
        local info = U1GetAddonInfo(name);
        if U1IsAddonEnabled(name) and not info.protected and name~=strlower(U1Name) then
            U1ToggleAddon(name, false, nil, deepToggleChildren)
        else
            if deepToggleChildren then
                U1ToggleChildren(name, false, nil, true)
            end
        end
    end
    UUI.ReloadFlash(self, false);
    UUI.Center.Refresh();
    UUI.Right.ADDON_SELECTED();
end

--[[------------------------------------------------------------
Right Panel
---------------------------------------------------------------]]
function UUI.Right.Create(main)
    local right = main:Frame(nil, "BackdropTemplate"):Key("right"):TL(main,"TR", -UUI.RIGHT_WIDTH, -(UUI.TOP_HEIGHT+10+24+10)):BR(-12, 12):Backdrop("Interface\\GLUES\\COMMON\\Glue-Tooltip-Background")
    local l = right:Texture(nil, "BORDER", UUI.Tex'UI2-chain-end'):Size(16,16):TL(-10,0)
    local r = right:Texture(nil, "BORDER", UUI.Tex'UI2-chain-end'):Size(16,16):BL(-10,0):SetTexRotate("V")
    right:CreateTexture(nil, "BORDER", 'U1T_ChainMid'):Size(16,1):TL(l, "BL"):BR(r, "TR"):up()

    local check = CoreUICreateCheckButtonWithIcon(right, nil, 22, 16):Key("check"):Set3Fonts(UUI.FONT_PANEL_BUTTON):BL(right, "TL", -5,7):un();
    check.text:SetMaxLines(1)

    check:SetScript("OnClick", UUI.Center.CheckOnClick);
    CoreUIEnableTooltip(check, nil, function(self, tip)
        local name = self:GetParent().addonName
        if name then UUI.SetAddonTooltip(name, tip) end
    end, true)

    --- right tabs
    local _,_,_,_,_,_,t = CoreUIDrawBorder(right, 1, "U1T_InnerBorder", 16, UUI.Tex'UI2-border-inner-corner', 16, true)  t:Hide()
    local topw = UUI.RIGHT_WIDTH-44
    right.tabBottom = right:Texture(nil, "BORDER", UUI.Tex'UI2-border-right-top'):Size(topw,16):TR(-18,1)
    right.tabBg = right:Texture(nil, "OVERLAY", UUI.Tex'UI2-tab-1'):Size(128,64):BR(right.tabBottom, "TR", 10, -3):un()

    local function clickTabButton(self)
        UUI.Right.TabChange(self:GetID(), nil, true)
    end
    local function createTabButton(title, info)
        local btn = right:Button():Size(48, 32):SetMotionScriptsWhileDisabled(true)
        :Texture(nil, nil, "Interface\\PaperDollInfoFrame\\UI-Character-Tab-RealHighlight"):TL(-9,11):BR(7,-14):ToTexture("Highlight"):up()
        :SetScript("OnClick", clickTabButton);
        CoreUIEnableTooltip(btn(), title, info)
        return btn;
    end
    right.tabs = {}
    right.tabs[1] = createTabButton(L["AddOn Options"]):SetID(1):BR(right.tabBg, -73, 2):un()
    right.tabs[2] = createTabButton(L["AddOn Notes"]):SetID(2):BR(right.tabBg, -17, 2):un()

    right:Texture(nil, "BORDER", UUI.Tex'UI2-scroll-end'):Size(32):TR():up()
    :Texture(nil, "BORDER", UUI.Tex'UI2-scroll-end'):Size(32):BR():SetTexRotate("V"):up()
    :CreateTexture(nil, "BORDER", 'U1T_ScrollMid'):Size(32):TL("$parent", "TR", -32, -32):BR(0, 32):up()

    local scroll = WW:ScrollFrame(tostring(right).."Scroll", right, "MinimalScrollFrameTemplate"):Key("scroll"):Size(UUI.RIGHT_WIDTH-33,100):TL(2,-5):BR(-22,5)
	-- 拿掉浮水印
    -- :CreateTexture(nil,"BACKGROUND"):Key("wm"):SetTexture(U1.CN and UUI.Tex'UI2-watermark' or nil):SetAlpha(0.125):Size(256, 64):BL(5, 0):up()
    :un();
    --WW(scroll):CreateTexture():SetTexture(1,1,1):ALL()
    scroll.scrollBarHideable = nil
    _G[scroll.ScrollBar:GetName().."Track"]:SetAlpha(0.3)
    scroll.scrollBar = scroll.ScrollBar --for CoreUIScrollSavePos
    WW(scroll.scrollBar):TL(scroll, "TR", 0, -16):BL(scroll, "BR", 0, 15)

    local scrollUp = _G[scroll.ScrollBar:GetName().."ScrollUpButton"]
    local scrollDown = _G[scroll.ScrollBar:GetName().."ScrollDownButton"]
    WW(scrollUp):TOP(0,17):Size(18,17):un()
    WW(scrollDown):BOTTOM(0,-17):Size(18,17):un()
    WW(scroll):On("Load"):un();

    UUI.Right.CreatePageDesc(right)

    right = right:un();
end

function UUI.Right.CreatePageDesc(right)
    local scroll = right.scroll
    right.pageCfg = WW:Frame(nil, scroll):AddToScroll(scroll):Size(scroll:GetWidth(), 10):un();
    local pageDesc = WW:Frame(nil, scroll):Size(scroll:GetWidth(), 10):un(); right.pageDesc = pageDesc
    local font = (U1.CN and ChatFontNormal or GameFontNormal):GetFont()
	-- 空出插件說明上方的位置，放置圖片
    WW:SimpleHTML(nil, pageDesc):Key("html"):TL(5, -120):Size(scroll:GetWidth()-10, 10)
	:CreateTexture():Key("descImg"):Size(230, 118):TL(-7, 120):up()
    :SetFont("P" ,font,U1.CN and 13 or 12, "OUTLINE"):SetTextColor("P",0.81, 0.65, 0.48):SetSpacing("P",5) --cfa67f
    :SetFont("H1",font,U1.CN and 14 or 13, "OUTLINE"):SetTextColor("H1",.9,.9,.7):SetSpacing("H1",5)
    :SetFont("H2",font,U1.CN and 13 or 12, "OUTLINE"):SetTextColor("H2",.9,.9,.7):SetSpacing("H2",4)
    :SetFont("H3",font,U1.CN and 12 or 11, "OUTLINE"):SetTextColor("H3",.9,.9,.7):SetSpacing("H3",3):SetIndentedWordWrap("H3",true)
    :un();
end

function UUI.Right.SetHtmlUpdateLog(tmp, log)
    for _, s in ipairs(log) do
        table.insert(tmp, format("<H3>-%s</H3>", CoreEncodeHTML(s:gsub("<a .->.-</a>", ""))))
    end
    table.insert(tmp, "<IMG height='5'/>");
end

function UUI.Right.GetTitleFormat(notice)
	if notice then
		return "<img height='10'/><H1>|cffff0000%s|r</H1><H3>|TInterface\\DialogFrame\\UI-DialogBox-Gold-Background:2:185:0:1|t</H3>";
	else
		return "<img height='10'/><H1>|cffffb233%s|r</H1><H3>|TInterface\\DialogFrame\\UI-DialogBox-Gold-Background:2:185:0:1|t</H3>";
	end
end
function UUI.Right.SetHTML(right, name)
    if not name and right.tagName==UUI.DEFAULT_TAG then name=U1Name end

    -- if no name then use right.tagName to show tags intro
    if not name then
        local _,num,caption,order,desc = U1GetTagInfoByName(right.tagName)
        if right.tagName=="CLASS" then caption = L["TAG_CLASS"] end
        desc = (desc and desc ~= "") and format("<P>  %s<br/><br/></P>", CoreEncodeHTML(desc)) or ""
        local text = "<HTML><BODY>"..format(UUI.Right.GetTitleFormat(), L["Category: "].. CoreEncodeHTML(caption)) .. desc .. "<P>  %s</P></BODY></HTML>";
        right.pageDesc.html:SetText(format(text, L["AddOns Installed: "]..num));
		-- 插件分類說明，不顯示圖片
		right.pageDesc.html.descImg:SetTexture(nil)
		right.pageDesc.html:SetPoint("TOPLEFT", 5, -5)

    else
        local info = U1GetAddonInfo(name);
        local title = U1GetAddonTitle(name, false)
        local name, _, notes, _, reason = C_AddOns.GetAddOnInfo(name)
        local loaded = C_AddOns.IsAddOnLoaded(name);
		local originName, intro, notice, usage, trim;

        local desc = info.desc or ""
        if(type(desc)=="table") then
            desc = table.concat(desc, "`");
        end

        local text = UUI().search:GetSearchText()
        if(text~="")then
            local pattern = nocase(text);
            if(desc:find(pattern)) then
                desc = desc:gsub(pattern, "|cff00ff00%0|r");
            end
        end
        desc = CoreEncodeHTML(desc, true):gsub("`", "<BR/>  ");
		
		-- 取得特別注意
		notice = desc:match("特別注意：|r.-$");
		if notice then
			notice = notice:sub(18, notice:len()):gsub("|n", "<br/><br/>");
			notice = "</P>"..format(UUI.Right.GetTitleFormat(true), L["Notice"]).."<P>".. notice;
		else 
			notice = "";
		end
		
		-- 取得使用方法
		if notice:len() > 0 then
			usage = desc:match("使用方法：|r.-|n|c");
			trim = 4;
		else
			usage = desc:match("使用方法：|r.-$");
			trim = 0;
		end
		if usage then
			usage = usage:sub(18, usage:len() - trim):gsub("|n", "<br/><br/>");
			usage = "</P>"..format(UUI.Right.GetTitleFormat(), L["How To Use"]).."<P>".. usage;
		else 
			usage = "";
		end
		
		-- 取得插件說明
		if usage:len() > 0 or notice:len() > 0 then
			intro = desc:match("|n.-|n|c");
			trim = 4
		else
			intro = desc:match("|n.-$");
			trim = 0;
		end
		if intro then
			intro = intro:sub(3, intro:len() - trim):gsub("|n", "<br/><br/>");
		else 
			intro = desc;
		end
		
		
		desc = intro .. usage .. notice;

        local page = right.pageDesc;

        local text = "<HTML><BODY>%s%s%s%s"..format(UUI.Right.GetTitleFormat(), L["AddOn Introduction"]) .. "<P>  %s<br/></P>%s</BODY></HTML>";
        local author, modifier, changes, tags = "", "", "", ""
        if info.tags and #info.tags > 0 then
            for _, tag in ipairs(info.tags) do
                tag = select(3, U1GetTagInfoByName(tag))
                if tag then tags = tags .. ", " .. tag end
            end
            tags = format("<P>|cffe6e6b3"..L["Category: "].."%s|r</P>", CoreEncodeHTML(tags:sub(3)));
        end
        if info.author then
            author = format("<P>|cffe6e6b3"..L["Author"].."：%s|r</P>", CoreEncodeHTML(info.author))
        end
        if info.modifier then
            modifier = format("<P>|cffe6e6b3"..L["Credits"].."：%s|r</P>", CoreEncodeHTML(info.modifier))
        end
		-- 加上插件原文名稱
		originName = format("<P>|cffe6e6b3"..L["Name: "].."%s|r</P>", CoreEncodeHTML(info.name))

        --right.html:SetHeight(1)
        --print(format(text, author, modifier, desc, changes:gsub("<H3>%- </H3>","")))
        page.html:SetText(format(text, originName, author, modifier, tags, desc, changes:gsub("<H3>%- </H3>","")));
		
		-- 加入圖片
		if info.img then
			page.html:SetPoint("TOPLEFT", 5, -120)
			page.html.descImg:SetTexture("Interface\\AddOns\\!!!EaseAddonController\\Images\\"..info.name)
		else
			page.html.descImg:SetTexture(nil)
			page.html:SetPoint("TOPLEFT", 5, -5)
		end
    end
end

--- if addon has children or config options
function UUI.Right.IsAddonHasCfg(name, info)
    if #info > 0 or info._hasCfg then return true end
    -- check if there are child addons
    for k, v in U1IterateAllAddons() do
        if(v.parent == name and not v.hide) then
            info._hasCfg = true
            return true
        end
    end
    info._hasCfg = false
    return false
end

--@param name addon's name, if name=nil then use current selected
function UUI.Right.ADDON_SELECTED(name)
    if not UUI():IsVisible() then return end
    local right = UUI().right
    name = name or U1GetSelectedAddon()

    -- show tag intro
    if(not name)then
        right.hasCfg = nil;
        right.addonName = nil;
        right.tagName = U1GetSelectedTag();
        UUI.Right.TabChange(2)
        right.check:Hide();
        return
    else
        right.addonName = name;
        right.check:Show();
        local info = U1GetAddonInfo(name);
        if(info.ldbIcon)then
            right.check.icon:Show();
            right.check:SetIcon(info.ldbIcon==1 and info.icon or info.ldbIcon);
        else
            right.check.icon:Hide();
        end
        right.check:SetText(U1GetAddonTitle(name));
        right.check:EnableOrDisable(info.installed);
        if(info.protected or InCombatLockdown()) then
            right.check:Disable(); -- only disable check button, options are not changed
        end
        right.check:SetChecked(U1IsAddonEnabled(name));

        right.hasCfg = UUI.Right.IsAddonHasCfg(name, info)
        right.check.text:SetWidth(UUI.RIGHT_WIDTH - (right.hasCfg and 163 or 113));

        UUI.Right.TabChange(right.selectedTab or 1)
    end
end

function UUI.Right.ShowPageBucket(name)
    local self = UUI().right
    CoreCall("CtlShowPage", name, self.pageCfg);
    CoreCall("CtlSearchPage", self.pageCfg, self:GetParent().search:GetSearchText());
    self.pageCfg:Show();
    self.scroll:SetScrollChild(self.pageCfg);
end

--- if tag is selected, name will be nil, but right.tagName has value.
function UUI.Right.TabChange(state, name, saveLast)
    local right = UUI().right
    name = name or right.addonName
    if not right.hasCfg then
        right.tabs[1]:Hide()
        right.tabBg:SetTexture(UUI.Tex'UI2-tab-3')
        state = 2
    else
        right.tabs[1]:Show()
        right.tabBg:SetTexture(state==1 and UUI.Tex'UI2-tab-1' or UUI.Tex'UI2-tab-2')
    end
    local texL = state==1 and .23 or .12
    right.tabBottom:SetTexCoord(texL,texL+(UUI.RIGHT_WIDTH-44)/512,0,1)
    if saveLast then right.selectedTab = state end

    for _, v in ipairs(right.tabs) do CoreUIEnableOrDisable(v, v:GetID()~=state) end

    if(state==1) then
        right.pageDesc:Hide();
        right.pageCfg:Hide() -- hide first to avoid blink
        CoreScheduleBucket("ShowPage", 0.1, UUI.Right.ShowPageBucket, name)
    else
        right.pageCfg:Hide();
        right.pageDesc:Show();
        UUI.Right.SetHTML(right, name)
        --RunOnNextFrame(function() right.pageDesc.html:SetHeight(select(4, right.pageDesc.html:GetBoundsRect()) + 10) end)
        right.scroll:SetScrollChild(right.pageDesc);
        right.scroll.scrollBar:SetValue(0);
    end
end

--[[------------------------------------------------------------
Event Scripts
---------------------------------------------------------------]]
--- update memory usage and process dragging operation.
function UUI.OnUpdate(self, elapsed)
    if (self.sizing) then
        local delta = GetCursorPosition() - self.initx
        local factor = 2.5
        if (math.abs(delta) > UUI.BUTTON_W / factor) then
            local center = self.center;
            local coldelta = math.floor(delta / UUI.BUTTON_W * factor)
            if (coldelta < 0) then coldelta = coldelta + 1 end
            local colsOld = center.cols;
            center.cols = center.cols + coldelta;
            local _, min = UUI.CalcWidth(1)
            if (center.cols < min) then center.cols = min end
            if (center.cols > UUI.MAX_COL) then center.cols = UUI.MAX_COL end
            U1DB.cols = center.cols
            self.initx = GetCursorPosition();
            UUI.Center.Refresh();
            UUI.SizeFitCols();
            if (center.cols ~= colsOld) then UUI.ChangeWithCols(); end
            UUI.ReloadFlashRefresh();
            self.timer = 0;
            return;
        end
    end

    self.timer = self.timer + elapsed;
    if (self.timer > 3) then
        self.timer = 0;
        UpdateAddOnMemoryUsage()
        UUI.Center.Refresh();
    end
end

function UUI.OnSizeChanged(self)
    if(self.sizing) then UUI.Center.Resize(self.center) end;
end

function UUI.OnShow(self)
    --self:SetSize(840, 465)
    UpdateAddOnMemoryUsage();
    self.left:SetWidth(UUI.LEFT_WIDTH);

    U1UpdateTags();
    UUI.Center.Resize(self.center);
    UUI.ChangeWithCols();
    self:SetFrameStrata("MEDIUM");
    self:Raise();
    self.search.onTextChanged(self.search)
    CoreUIShowOrHide(self.search.hint, U1DBG and U1DBG.hintSearch == nil)

    if self:GetLeft() > GetScreenWidth() - UUI.BORDER_WIDTH
            or self:GetBottom() > GetScreenHeight() - UUI.BORDER_WIDTH
            or self:GetRight() < UUI.BORDER_WIDTH
            or self:GetTop() < UUI.BORDER_WIDTH then
        self:ClearAllPoints()
        self:SetPoint("CENTER")
    end
end

function UUI:CURRENT_TAGS_UPDATED(...)
    local main = UUI()
    main.left.scroll.update();
    UUI.Center.FilterButtonAdjust(UUI().center.cols);
    local _, num = U1GetTagInfoByName("SINGLE");
    CoreUIEnableOrDisable(main.left.btnSingle, num>0)
end

function UUI:CURRENT_ADDONS_UPDATED(...)
    UUI.Center.Refresh();
    UUI.Center.ScrollToAddon();
end

function UUI:ADDON_SELECTED(name)
    local main = UUI();
    UUI.Center.Refresh();
    if(name) then
        UUI.Center.ScrollToAddon(name);
    else
        main.center.scroll.scrollBar:SetValue(0);
    end
    UUI.Right.ADDON_SELECTED(name);
end

function UUI:DB_LOADED()
    local main = UUI();
    if U1DB.lastSearch then
        main.search:SetSearchText(U1DB.lastSearch)
    end
    main.center.cols = U1DB.cols or UUI.CENTER_COLS;
    UUI.Center.Resize(main.center)
    --UIDropDownMenu_Initialize(UUI().setting.drop, UUI.Top.QuickSettingDropDownMenuInitialize, "MENU"); --taint here
    main.setting.drop:Hide()
    UUI.DB_LOADED = nil
end

function UUI.CreateUI()
    table.insert(UISpecialFrames, U1_FRAME_NAME)
    local main = WW:Frame(U1_FRAME_NAME, UIParent, "BackdropTemplate"):TR(-250, -160):Size(800,500) --TR(-350, -260)
    :Hide():SetToplevel(1)
    CoreUIMakeMovable(main)
    CoreHookScript(main, "OnMouseDown", UUI.Raise)

    local tl = CoreUIDrawBorder(main, UUI.BORDER_WIDTH, "U1T_OuterBorder", 32, UUI.Tex'UI2-border-outter-corner', 32, nil)
    tl:SetAlpha(0)

    main:Backdrop("Interface\\DialogFrame\\UI-DialogBox-Background")

    local left = UUI.Left.Create(main)

    main:Texture(nil, "BORDER", UUI.Tex'UI2-corner'):SetTexRotate(90):TR(11,11):Size(64):SetVertexColor(.4,.4,.4)--:SetAlpha(0.4)
    main:Texture(nil, "BORDER", UUI.Tex'UI2-corner'):SetTexRotate(180):BR(11,-11):Size(64):SetVertexColor(.4,.4,.4)--:SetAlpha(0.4)
    main:Texture(nil, "BORDER", UUI.Tex'UI2-corner'):SetTexRotate(-90):BL(-11,-11):Size(64):SetVertexColor(.4,.4,.4)--:SetAlpha(0.4)
    main:Texture(nil, "BACKGROUND", UUI.Tex'UI2-curve'):SetTexRotate(0):TL(-3,9):Size(256,64):SetAlpha(1):SetVertexColor(.7,.7,.7)
    main:Texture(nil, "BORDER", UUI.Tex'UI2-curve'):SetTexRotate("H"):TR(0,-8):Size(256,64):SetAlpha(1):SetVertexColor(.7,.7,.7)

    -- Highlight between left and center
    left:CreateTexture(nil, "BACKGROUND"):SetTexture(UUI.Tex'UI2-shade-dark-deep'):SetWidth(32):SetTexRotate(90):TR(0,0):BR()
    left:CreateTexture(nil, "BACKGROUND"):SetTexture(UUI.Tex'UI2-shade-light'):SetWidth(32):SetTexRotate(-90):TL("$parent","TR",1,0):BR(32,0)
    left:CreateTexture(nil, "BACKGROUND"):SetTexture(UUI.Tex'UI2-line-carve'):SetWidth(8):SetTexRotate(-90):TL("$parent","TR",0,0):BR(8,0)

    -- bottom shadow
    main:CreateTexture(nil, "BORDER"):SetTexture(UUI.Tex'UI2-shade-dark'):SetHeight(32):SetTexRotate(180):BL():BR()

    -- Highlight between left and top
    main:CreateTexture(nil, "BORDER"):SetTexture(UUI.Tex'UI2-shade-dark'):SetHeight(32):SetTexRotate(180):BL("$parent","TL",0,-UUI.TOP_HEIGHT):BR("$parent","TR",0,-UUI.TOP_HEIGHT)
    main:CreateTexture(nil, "BORDER"):SetTexture(UUI.Tex'UI2-shade-light'):SetHeight(32):TL(0, -UUI.TOP_HEIGHT-1):TR(0, -UUI.TOP_HEIGHT)
    main:CreateTexture(nil, "BORDER"):SetTexture(UUI.Tex'UI2-line-carve'):SetHeight(8):TL(0, -UUI.TOP_HEIGHT):TR(0, -UUI.TOP_HEIGHT)

    -- resize button
    main:SetResizable(true);
    main:Texture(nil, nil, "Interface\\BUTTONS\\UI-AutoCastableOverlay", 0.619, 0.760, 0.612, 0.762):Size(14):BR(UUI.BORDER_WIDTH-2, -UUI.BORDER_WIDTH+2)
    local resizeButton = CoreUICreateResizeButton(main(),"BOTTOMRIGHT","BOTTOM", UUI.BORDER_WIDTH-1, -UUI.BORDER_WIDTH+1, 14)
    resizeButton:GetNormalTexture():SetAlpha(0)
    resizeButton:GetPushedTexture():SetAlpha(0)
    resizeButton:HookScript("OnMouseDown", function(self)
        local f = self:GetParent();
        f.sizing = true;
        f.initx = GetCursorPosition();
    end)
    resizeButton:HookScript("OnMouseUp", function(self)
        local f = self:GetParent();
        f.sizing = false;
        UUI.SizeFitCols();
        UUI.Center.ScrollToAddon();
    end)

    -- Background can not be resize
    main.BG = CoreUIDrawBG(main, "U1T_OuterBG", 0, true)

    -- Search box
    local search = CoreUICreateSearchBox(U1_FRAME_NAME.."AddonSearchBox", main, 300, 24)
    :Key("search"):TL(UUI.LEFT_WIDTH+15, -(UUI.TOP_HEIGHT+10)):TR(-UUI.RIGHT_WIDTH-10,10):SetAlpha(1):un()
    search.tooltipAnchorPoint = "ANCHOR_TOP"
    CoreUIEnableTooltip(search, L["Search AddOns"], function(self, tip)
        tip:AddLine(L["desc.SEARCH1"], nil,nil,nil,true);
        tip:AddLine(" ");
        tip:AddLine(L["desc.SEARCH2"], nil,nil,nil,true);
        if L["desc.SEARCH3"] then
            tip:AddLine(" ");
            tip:AddLine(L["desc.SEARCH3"], 0,0.82,0,true);
        end
    end)

    search.onTextChanged = function(self)
        local text = self:GetSearchText();
        CoreUIShowOrHide(self:GetParent().center.chkLoaded, text=="")
        CoreUIShowOrHide(self:GetParent().center.chkDisabled, text=="")
        U1SearchAddon(text);
        if(U1GetSelectedAddon()) then
            CoreCall("CtlSearchPage", self:GetParent().right.scroll:GetScrollChild(), self:GetSearchText())
            if self:GetParent().right.pageDesc:IsVisible() then
                -- update addon desc highlight
                UUI.Right.SetHTML(self:GetParent().right, U1GetSelectedAddon())
            end
        end
    end

    search.onEnterPressed = function(self)
        if U1GetNumCurrentAddOns()==1 then
            U1SelectAddon(U1GetCurrentAddOnInfo(1), nil)
        end
    end

    -- Search Hint
    local f = TplGlowHint(search, "$parentHint", 320):Key("hint"):BOTTOM("$parent", "TOP", -30, 12)
    f.text:SetText(L["help.SEARCH"]);
    f.close:HookScript("OnClick", function() if U1DBG then U1DBG.hintSearch = 1 end end)

    -- Right Panel
    UUI.Right.Create(main)

    -- Center Panel
    UUI.Center.Create(main)

    UUI.Top.Create(main)

    -- Scripts
    main:SetClampedToScreen(false)

    main.animCheck = main:CheckButton(nil, "UICheckButtonTemplate"):SetFrameStrata("TOOLTIP"):Size(24):BR():Hide():EnableMouse(false):un()
    main.animCheck.anim = WW(main.animCheck):CreateAnimationGroup()
    :CreateAnimation("Translation"):Key("move"):SetOffset(50,30):SetDuration(0.4):up()
    :CreateAnimation("Scale"):Key("size"):SetScale(2,2):SetDuration(0.4):up()
    :CreateAnimation("Alpha"):SetFromAlpha(1):SetToAlpha(0)
    :SetDuration(0.4):up()
    :SetScript("OnFinished", function(self) self:GetParent():Hide() end)

    main.timer = 0;
    main:SetScript("OnUpdate", UUI.OnUpdate)
    main:SetScript("OnSizeChanged", UUI.OnSizeChanged)
    main:SetScript("OnShow", UUI.OnShow)
    CoreRegisterEvent("CURRENT_TAGS_UPDATED", UUI);
    CoreRegisterEvent("CURRENT_ADDONS_UPDATED", UUI);
    CoreRegisterEvent("ADDON_SELECTED", UUI);
    CoreRegisterEvent("DB_LOADED", UUI);

    CoreDispatchEvent(main());
    main:RegisterEvent("DISPLAY_SIZE_CHANGED")
    main:RegisterEvent("PLAYER_REGEN_ENABLED")
    main:RegisterEvent("PLAYER_REGEN_DISABLED")
    function main:DISPLAY_SIZE_CHANGED(...)
        if UUI():IsVisible() then
            UUI.Center.Resize(self.center);
            self.left:GetScript("OnSizeChanged")(self.left);
        end
    end
    function main:PLAYER_REGEN_ENABLED(event)
        if UUI():IsVisible() then
            UUI.Center.Refresh()
            UUI.Right.ADDON_SELECTED()
        end
        --CoreUIEnableOrDisable(self.btnLoadAll, not InCombatLockdown())
        --CoreUIEnableOrDisable(self.btnDisAll, not InCombatLockdown())
    end
    function main:PLAYER_REGEN_DISABLED(event)
        -- InCombatLockdown() return false when event fired, so delay 0.1 second
        CoreScheduleTimer(false, 0.1, self.PLAYER_REGEN_ENABLED, self)
    end
	
	-- 遊戲選單的彩虹ui按鈕
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		WW:Button(nil, GameMenuFrame.Header):Key("logo"):CENTER(GameMenuFrame.Header, "LEFT", 0, 0):Size(40):EnableMouse(false)
		:CreateTexture():SetTexture(UUI.Tex"UI2-logo"):ALL():up()
		:CreateTexture():Key("highlight"):TL(-3,3):BR(3,-3):SetTexture("Interface\\UnitPowerBarAlt\\Atramedes_Circular_Flash")
		:SetBlendMode("ADD"):SetDrawLayer("OVERLAY"):Hide():up()
		:un()
		
		GameMenuFrame.Header.Text:SetText(L["Ease AddOn"])
		GameMenuFrame.Header:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" or button == "RightButton" then
				UUI.ToggleUI() 
			else
				ReloadUI()
			end
		end)
		GameMenuFrame.Header:SetScript("OnShow", function(self) UICoreFrameFlash(self.logo.highlight, 2 , 2, -1, nil, 0, 0) end)
		GameMenuFrame.Header:SetScript("OnHide", function(self) UICoreFrameFlashStop(self.logo.highlight) end)
		GameMenuFrame.Header:SetScript("OnEnter", function(self) UICoreFrameFlashStop(self.logo.highlight); UICoreFrameFlash(self.logo.highlight, 0.5 , 0.5, -1, nil, 0, 0) end)
		GameMenuFrame.Header:SetScript("OnLeave", function(self) UICoreFrameFlashStop(self.logo.highlight); UICoreFrameFlash(self.logo.highlight, 2 , 2, -1, nil, 0, 0) end)
		CoreUIEnableTooltip(GameMenuFrame.Header, L["Left or Right click: Open Ease Addon Controller's main panel\nOther mouse buttons: Reload UI"])
	else
	-- Buttons on GameMenuFrame
		CoreHookScript(GameMenuFrame, "OnShow", function()
			GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + 26)
			if GameMenuFrame.btn163 then return end

			WW:Button(nil, GameMenuFrame, "GameMenuButtonTemplate"):Key("btn163")
			:SetText(L["Ease AddOn"])
			:TOP(select(2, GameMenuButtonAddons:GetPoint()), "BOTTOM", 0, -1)
			:SetScript("OnClick", UUI.ToggleUI)
			:SetScript("OnEnter", function(self) UICoreFrameFlash(self.logo.highlight, 0.5 , 0.5, -1, nil, 0, 0) end)
			:SetScript("OnLeave", function(self) UICoreFrameFlashStop(self.logo.highlight) end)
			:Button():Key("logo"):CENTER("$parent", "LEFT", 0, 0):Size(32):EnableMouse(false)
			--:CreateTexture():SetColorTexture(0, 1, 0, 0.4):ALL():up()
			:CreateTexture():SetTexture(UUI.Tex"UI2-logo"):ALL():up()
			:CreateTexture():Key("highlight"):TL(-3,3):BR(3,-3):SetTexture("Interface\\UnitPowerBarAlt\\Atramedes_Circular_Flash")
			:SetBlendMode("ADD"):SetDrawLayer("OVERLAY"):Hide():up()
			:un()
			GameMenuButtonAddons:SetPoint("TOP", GameMenuFrame.btn163, "BOTTOM", 0, -1)
			CoreUIEnableTooltip(GameMenuFrame.btn163, L["Ease Addon Controller"], L["Open Ease Addon Controller's main panel"])
		end, true)
	end


end

--- Create minimap buttons, must be called after DB_LOADED
function U1_CreateMinimapButton()

    local ldb = LibStub("LibDataBroker-1.1"):NewDataObject(U1Name, {
        type = "launcher",
        label = L["EAC"],
        icon = UUI.Tex'UI2-icon',
        iconCoords = {0.04+0.05, 26/32-0.06+0.05, 0.06, 26/32-0.10},
        OnEnter = CoreUIShowTooltip,
        OnClick = function(self, button)
            GameTooltip:Hide();
            if button=="RightButton" then
                UUI.Top.ToggleQuickSettingDropDown(self)
            else
                CloseDropDownMenus(1);
                UUI.ToggleUI(self, button)
            end
        end,
        OnTooltipShow = function(tip)
            tip:AddLine(L["Ease Addon Controller"])
            tip:AddLine(L["An advanced in-game addon control center, which combines Categoring, Searching, Loading and Setting of wow addons all together."], nil, nil, nil, 1)
            tip:AddLine(" ")
            tip:AddLine(L["Right click to open quick menu."], 0, 0.82, 0)
        end,
    })
    U1DBG.minimap = U1DBG.minimap or {}
    local mdb = U1DBG.minimap
    mdb.minimapPos = mdb.minimapPos or 217
    LibStub("LibDBIcon-1.0"):Register("U1MMB", ldb, mdb);
    U1_CreateMinimapButton = nil
end

function UUI.ToggleUI(self, button)
    if GameMenuFrame:IsVisible() then HideUIPanel(GameMenuFrame) end
    if UUI():IsVisible() then UUI():Hide() else UUI():Show() end
end

function UUI.OpenToAddon(addon, forceSelect)
    if not UUI():IsShown() then
        UUI():Show();
    end
    if forceSelect then
        local tags = U1GetAddonInfo(addon).tags
        UUI().search:SetText("")
        UUI().search:ClearFocus();
        U1SelectTag(tags and tags[1] or UUI.DEFAULT_TAG)
        U1SelectAddon(addon)
    else
        UUI.Right.ADDON_SELECTED(addon)
    end
end

CoreUIRegisterSlash('EAC_TOGGLE', '/eac', '/163ui', UUI.ToggleUI)

function UUI.Clean()
    UUI.Right.Create = nil
    UUI.Left.Create = nil
    UUI.Center.Create = nil
    UUI.Left.CreateScrollButton = nil
    UUI.Top.Create = nil
    UUI.Right.CreatePageDesc = nil
    UUI.CreateUI = nil
    UUI.Clean = nil
end

function U1CreateUI()
    UUI.BUTTON_W = U1GetCfgValue(U1Name, "tile_width")
    UUI.BUTTON_H = U1GetCfgValue(U1Name, "tile_height")
    UUI.ICON_W = UUI.BUTTON_H - 3 - UUI.BUTTON_H / 6
    UUI.CHECK_W = math.min(UUI.BUTTON_H-2, 24)

    UUI.BUTTON_OFFSET = U1GetCfgValue(U1Name, "tile_margin")
    UUI.BUTTON_P = UUI.BUTTON_OFFSET
    UUI.CENTER_TEXT_LEFT = math.max(2,(UUI.BUTTON_H-UUI.ICON_W)/2-1)*2 + UUI.ICON_W
    UUI.MAX_COL = math.floor((GetScreenWidth()-440) / UUI.BUTTON_W)

    local _, min = UUI.CalcWidth(1)
    if (U1DB.cols and U1DB.cols < min) then U1DB.cols = min end
    UUI.CreateUI();
    UUI.Clean();
end
