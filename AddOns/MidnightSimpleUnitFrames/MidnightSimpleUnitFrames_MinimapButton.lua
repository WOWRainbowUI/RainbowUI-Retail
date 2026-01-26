-- Midnight Simple Unit Frames - 小地圖圖示 (BugSack 風格: LDB + LibDBIcon)
--
-- 行為：
--  - 左鍵拖曳：在小地圖周圍移動圖示 (由 LibDBIcon 處理)
--  - 右鍵點擊：開啟 MSUF 選單 (同 /msuf)
--  - Shift + 右鍵點擊：開啟 MSUF 編輯模式 (Edit Mode)
--
-- 註記：
--  - 首選：LibDataBroker-1.1 + LibDBIcon-1.0 (BugSack 風格)。
--  - 備案：若缺少上述函式庫，MSUF 會建立自己的輕量級小地圖按鈕，
--    確保僅載入 MSUF 時圖示依然存在。

local addonName = ...

-- -----------------------------------------------------------------------------
-- 後端狀態 (始終可用)
-- -----------------------------------------------------------------------------

local function EnsureGeneralDB()
    if type(_G.MSUF_DB) ~= "table" then
        _G.MSUF_DB = {}
    end
    if type(_G.MSUF_DB.general) ~= "table" then
        _G.MSUF_DB.general = {}
    end
    return _G.MSUF_DB.general
end

local function EnsureMinimapDB()
    local general = EnsureGeneralDB()

    local db = general.minimapIconDB
    if type(db) ~= "table" then
        db = { hide = false }
        general.minimapIconDB = db
    end

    -- 標準化，未來友好的切換選項 -> 雜項。
    if general.showMinimapIcon == false then
        db.hide = true
    elseif general.showMinimapIcon == true then
        db.hide = false
    elseif db.hide == nil then
        db.hide = false
    end

    -- LibDBIcon 預期的預設值 (即使缺少函式庫也保留，以便後續無需修改此文件即可實作切換)。
    if db.minimapPos == nil then db.minimapPos = 220 end
    if db.radius == nil then db.radius = 80 end

    return general, db
end

-- 本地 Hook，一旦 LibDBIcon 存在即生效。
local ApplyMinimapIconVisibility = function() end

-- 公用 API (稍後由 選項 -> 雜項 切換使用)。即使缺少函式庫也會定義，因此呼叫它們不會報錯。
function _G.MSUF_GetMinimapIconEnabled()
    local _, db = EnsureMinimapDB()
    return not db.hide
end

function _G.MSUF_SetMinimapIconEnabled(enabled)
    local general, db = EnsureMinimapDB()
    general.showMinimapIcon = (enabled and true) or false
    db.hide = (enabled and false) or true
    ApplyMinimapIconVisibility()
end

function _G.MSUF_ToggleMinimapIcon()
    _G.MSUF_SetMinimapIconEnabled(not _G.MSUF_GetMinimapIconEnabled())
end

-- 使用我們在 Media 中捆綁的圖示。
local ICON_PATH = "Interface\\AddOns\\" .. tostring(addonName) .. "\\Media\\MSUF_MinimapIcon.tga"

-- Libs 是可選的；當它們不存在時，我們支援備用的小地圖按鈕。
local libStub = _G.LibStub
local ldb = (libStub and libStub.GetLibrary and libStub:GetLibrary("LibDataBroker-1.1", true)) or nil

local function GetLibDBIcon()
    return (libStub and libStub("LibDBIcon-1.0", true)) or nil
end

local plugin -- 僅在 LDB 存在時建立

local function ChatMsg(msg)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    end
end

local function OpenMSUFMenu()
    -- 戰鬥中開啟選項 UI 可能會被阻擋/污染 (taint)。
    if InCombatLockdown and InCombatLockdown() then
        ChatMsg("|cffff5555MSUF: 戰鬥中無法開啟選單。|r")
        return
    end

    -- 首選：直接開啟 Flash/Slash 選單。
    if type(_G.MSUF_OpenPage) == "function" then
        _G.MSUF_OpenPage("home")
        return
    end

    -- 備案：某些版本會公開選項視窗切換功能。
    if type(_G.MSUF_ToggleOptionsWindow) == "function" then
        _G.MSUF_ToggleOptionsWindow("main")
        return
    end

    -- 最後手段：如果已註冊，則呼叫 slash 處理程序。
    if _G.SlashCmdList then
        local fn = _G.SlashCmdList.MSUFOPTIONS or _G.SlashCmdList.MIDNIGHTSIMPLEUNITFRAMES or _G.SlashCmdList.MIDNIGHTSUF or _G.SlashCmdList.MSUF
        if type(fn) == "function" then
            fn("")
        end
    end
end

local function OpenMSUFEditMode()
    if InCombatLockdown and InCombatLockdown() then
        ChatMsg("|cffff5555MSUF: 戰鬥中無法進入編輯模式。|r")
        return
    end

    -- 標準入口點 (首選；即使與暴雪編輯模式未連結也能運作)。
    if type(_G.MSUF_SetMSUFEditModeDirect) == "function" then
        _G.MSUF_SetMSUFEditModeDirect(true)
        return
    end

    -- 舊版備案 (舊版本 / 相容性)
    if type(_G.MSUF_ToggleEditMode) == "function" then
        _G.MSUF_ToggleEditMode()
    elseif type(_G.MSUF_EditMode_Toggle) == "function" then
        _G.MSUF_EditMode_Toggle()
    else
        ChatMsg("|cffff5555MSUF: 找不到編輯模式功能。|r")
    end
end

local function Plugin_OnClick(_, button)
    -- 保留左鍵 (LeftButton) 供 LibDBIcon 的拖曳行為使用。
    if button == "RightButton" then
        if IsShiftKeyDown and IsShiftKeyDown() then
            OpenMSUFEditMode()
        else
            OpenMSUFMenu()
        end
    end
end

local function Plugin_OnTooltipShow(tt)
    if not tt then return end
    tt:AddLine("至暗之夜頭像")
    tt:AddLine("右鍵：開啟 /msuf", 0.2, 1, 0.2)
    tt:AddLine("Shift + 右鍵：MSUF 編輯模式", 0.2, 1, 0.2)
    tt:AddLine("左鍵拖曳：移動圖示", 0.2, 1, 0.2)
end

-- 如果我們有 LDB，建立 broker 資料物件，以便 LibDBIcon (如果存在) 可以渲染它。
if ldb then
    plugin = ldb:NewDataObject(addonName, {
        type = "data source",
        text = "MSUF",
        icon = ICON_PATH,
    })
    plugin.OnClick = Plugin_OnClick
    plugin.OnTooltipShow = Plugin_OnTooltipShow
end

-- ----------------------------------------------------------------------------
-- 備用小地圖按鈕 (無外部 Libs)
-- ----------------------------------------------------------------------------

local fallbackButton
local fallbackDragTicker

local function Fallback_UpdatePosition()
    if not fallbackButton or not Minimap then return end
    local _, db = EnsureMinimapDB()

    local angle = tonumber(db.minimapPos) or 220
    local radius = tonumber(db.radius) or 80
    local rad = math.rad(angle)
    local x = math.cos(rad) * radius
    local y = math.sin(rad) * radius

    fallbackButton:ClearAllPoints()
    fallbackButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function Fallback_StopDrag()
    if fallbackDragTicker then
        fallbackDragTicker:Cancel()
        fallbackDragTicker = nil
    end
    if fallbackButton then
        fallbackButton:SetScript("OnUpdate", nil)
    end
end

local function Fallback_StartDrag()
    if not fallbackButton or not Minimap then return end

    -- 拖曳時以適度的速率更新；沒有永久的 OnUpdate。
    Fallback_StopDrag()
    fallbackDragTicker = (C_Timer and C_Timer.NewTicker) and C_Timer.NewTicker(0.02, function()
        if not fallbackButton or not fallbackButton._msufDragging then
            Fallback_StopDrag()
            return
        end

        local mx, my = Minimap:GetCenter()
        if not mx or not my then return end

        local cx, cy = GetCursorPosition()
        local scale = (Minimap.GetEffectiveScale and Minimap:GetEffectiveScale()) or 1
        cx, cy = cx / scale, cy / scale

        local dx, dy = (cx - mx), (cy - my)
        local angle = math.deg(math.atan2(dy, dx))
        -- 轉換為 0..360 並旋轉，使 0 為 "東"，就像 LibDBIcon 一樣。
        angle = (angle + 360) % 360

        local _, db = EnsureMinimapDB()
        db.minimapPos = angle
        Fallback_UpdatePosition()
    end) or nil
end

local function EnsureFallbackButton()
    if fallbackButton or not Minimap or type(CreateFrame) ~= "function" then
        return fallbackButton
    end

    local b = CreateFrame("Button", "MSUF_MinimapButton", Minimap)
    fallbackButton = b
    b:SetFrameStrata("MEDIUM")
    b:SetSize(32, 32)
    b:RegisterForClicks("RightButtonUp", "LeftButtonUp")
    b:RegisterForDrag("LeftButton")
    b:SetClampedToScreen(true)

    local tex = b:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture(ICON_PATH)
    b._msufTex = tex

    -- Tooltip (提示訊息)
    b:SetScript("OnEnter", function(self)
        if GameTooltip then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            Plugin_OnTooltipShow(GameTooltip)
            GameTooltip:Show()
        end
    end)
    b:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)

    b:SetScript("OnClick", function(_, button)
        -- 保持行為與 broker plugin 相同。
        if button == "RightButton" then
            Plugin_OnClick(nil, "RightButton")
        end
    end)

    b:SetScript("OnDragStart", function(self)
        if not _G.MSUF_GetMinimapIconEnabled() then return end
        self._msufDragging = true
        Fallback_StartDrag()
    end)
    b:SetScript("OnDragStop", function(self)
        self._msufDragging = false
        Fallback_StopDrag()
    end)

    Fallback_UpdatePosition()
    return b
end

-- 現在 LibDBIcon 存在，連結公用 API 使用的可見性應用程式。
ApplyMinimapIconVisibility = function()
    local _, db = EnsureMinimapDB()

    -- 如果可用並已註冊，優先使用 LibDBIcon，否則使用備用按鈕。
    local icon = GetLibDBIcon()
    if icon and plugin then
        if db.hide then
            icon:Hide(addonName)
        else
            icon:Show(addonName)
        end
        -- 如果我們使用 LibDBIcon，確保備用按鈕被隱藏。
        if fallbackButton then fallbackButton:Hide() end
        return
    end

    -- 無 LibDBIcon：使用備用按鈕。
    local b = EnsureFallbackButton()
    if not b then return end
    if db.hide then
        b:Hide()
    else
        b:Show()
        Fallback_UpdatePosition()
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    local _, db = EnsureMinimapDB()

    local icon = GetLibDBIcon()
    if icon and plugin then
        icon:Register(addonName, plugin, db)
    else
        EnsureFallbackButton()
    end

    -- 確保在註冊/建立後應用當前的 DB 可見性狀態。
    ApplyMinimapIconVisibility()
end)