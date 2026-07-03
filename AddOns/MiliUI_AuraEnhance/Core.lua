------------------------------------------------------------
-- 光環強化 (AuraEnhance)
-- Buff/Debuff 時間文字樣式強化
-- 調整光環時間文字的位置、大小與描邊，不修改文字內容
--
-- 策略：hook 每個 Duration FontString 的 SetPoint / SetFontObject
-- 當 Blizzard 重設時，hook 立刻覆寫，零延遲零抖動。
--
-- 本插件由 MiliUI 套組中的「光環強化」抽出，獨立運作、不依賴 MiliUI。
------------------------------------------------------------
local _, ns = ...

-- 預設值
local DEFAULTS = {
    enabled = true,
    fontFace = "",          -- "" = 沿用暴雪原本字型
    fontSize = 12,
    outline = true,
    yOffset = 6,
    -- 堆疊層數
    countEnabled = true,
    countFontFace = "",     -- "" = 沿用暴雪原本字型
    countAnchor = "TOP",
    countXOffset = 0,
    countYOffset = 0,
}

-- Cache：初始化後這個指向 MiliUI_AuraEnhanceDB，hot hook 直接取
local db
local function GetDB()
    if db then return db end
    if not MiliUI_AuraEnhanceDB then MiliUI_AuraEnhanceDB = {} end
    -- 補齊舊版 DB 缺少的新欄位
    for k, v in pairs(DEFAULTS) do
        if MiliUI_AuraEnhanceDB[k] == nil then
            MiliUI_AuraEnhanceDB[k] = v
        end
    end
    db = MiliUI_AuraEnhanceDB
    return db
end

------------------------------------------------------------
-- 字型輔助
------------------------------------------------------------
-- 安全套用字型：路徑失效（例：LSM 字型被移除）時退回系統預設，避免文字消失
local function SetFontSafe(fs, path, size, flags)
    if not path or path == "" then return false end
    if fs:SetFont(path, size, flags) then return true end
    return fs:SetFont(STANDARD_TEXT_FONT, size, flags)
end

-- 時間文字字型路徑："" 代表沿用暴雪原本字型
local function ResolveDurationFont(dur)
    local face = db.fontFace
    if face and face ~= "" then return face end
    local of = dur.AuraEnhance_origFont
    if of and of[1] then return of[1] end
    return dur:GetFont() or STANDARD_TEXT_FONT
end

-- 套用堆疊層數自訂字型（保留原本大小與旗標，只換字體）
local function ApplyCountFont(cnt)
    local face = db.countFontFace
    if not face or face == "" then return end
    local _, sz, fl = cnt:GetFont()
    SetFontSafe(cnt, face, sz or 14, fl or "")
end

------------------------------------------------------------
-- 每個 Duration FontString 的 reactive hook
------------------------------------------------------------
-- Weak keys：Blizzard 回收按鈕時 FontString 被 GC，這裡的 entry 自動消失
local hookedDurations = setmetatable({}, { __mode = "k" })
local hookedCounts    = setmetatable({}, { __mode = "k" })

-- 遞歸防護（WoW 單執行緒，單一 flag 即可）
local overriding = false

local function EnsureOverlay(btn)
    local ov = btn.AuraEnhance_DurOverlay
    if ov then return ov end
    ov = CreateFrame("Frame", nil, btn)
    ov:SetAllPoints(btn)
    ov:SetFrameLevel(btn:GetFrameLevel() + 5)
    btn.AuraEnhance_DurOverlay = ov
    return ov
end

local function HookDuration(btn)
    if btn.isAuraAnchor then return end
    local dur = btn.Duration
    if not dur or hookedDurations[dur] then return end

    -- 記下暴雪原本字型，選「預設」時可立即還原字體
    dur.AuraEnhance_origFont = dur.AuraEnhance_origFont or { dur:GetFont() }

    -- Hook SetPoint：Blizzard 每次重設位置時，我們立刻覆寫
    hooksecurefunc(dur, "SetPoint", function(self)
        if overriding then return end
        if not db.enabled then return end

        overriding = true
        self:SetParent(EnsureOverlay(btn))
        self:ClearAllPoints()
        self:SetPoint("TOP", btn.Icon, "BOTTOM", 0, db.yOffset)
        overriding = false
    end)

    -- Hook SetFontObject：Blizzard 切換字型物件時，我們覆寫回自訂字型
    hooksecurefunc(dur, "SetFontObject", function(self)
        if overriding then return end
        if not db.enabled then return end

        overriding = true
        SetFontSafe(self, ResolveDurationFont(self), db.fontSize, db.outline and "OUTLINE" or "")
        if db.outline then
            self:SetShadowOffset(1, -1)
            self:SetShadowColor(0, 0, 0, 0.6)
        else
            self:SetShadowOffset(0, 0)
        end
        overriding = false
    end)

    hookedDurations[dur] = true
end

local function HookCount(btn)
    if btn.isAuraAnchor then return end
    local cnt = btn.Count
    if not cnt or hookedCounts[cnt] then return end

    -- 記下暴雪原本字型，停用自訂字型時可還原
    cnt.AuraEnhance_origFont = cnt.AuraEnhance_origFont or { cnt:GetFont() }

    -- SetPoint 與 SetText 做同一件事（確保位置不跑掉）——共用 closure
    local function reapply(self)
        if overriding then return end
        if not db.countEnabled then return end

        overriding = true
        self:SetParent(EnsureOverlay(btn))
        self:SetWidth(0)
        self:ClearAllPoints()
        self:SetPoint(db.countAnchor, btn.Icon, db.countAnchor, db.countXOffset, db.countYOffset)
        if db.countFontFace and db.countFontFace ~= "" then
            ApplyCountFont(self)
            self.AuraEnhance_fontApplied = true
        end
        overriding = false
    end

    hooksecurefunc(cnt, "SetPoint", reapply)
    hooksecurefunc(cnt, "SetText",  reapply)

    -- Blizzard 切換字型物件時，覆寫回自訂字型
    hooksecurefunc(cnt, "SetFontObject", function(self)
        if overriding then return end
        if not db.countEnabled then return end
        if not (db.countFontFace and db.countFontFace ~= "") then return end

        overriding = true
        ApplyCountFont(self)
        self.AuraEnhance_fontApplied = true
        overriding = false
    end)

    hookedCounts[cnt] = true
end

------------------------------------------------------------
-- 主動套用 / 恢復（給初始化和設定變更用）
------------------------------------------------------------
local function ApplyDurationStyle(btn)
    local dur = btn.Duration
    if not dur or not dur:IsShown() then return end

    overriding = true

    dur:SetParent(EnsureOverlay(btn))

    SetFontSafe(dur, ResolveDurationFont(dur), db.fontSize, db.outline and "OUTLINE" or "")

    if db.outline then
        dur:SetShadowOffset(1, -1)
        dur:SetShadowColor(0, 0, 0, 0.6)
    else
        dur:SetShadowOffset(0, 0)
    end

    dur:ClearAllPoints()
    dur:SetPoint("TOP", btn.Icon, "BOTTOM", 0, db.yOffset)

    overriding = false
end

local function RestoreDurationStyle(btn)
    local dur = btn.Duration
    if not dur then return end

    overriding = true

    -- 不 re-parent：overlay 與 btn 同區域，直接還原位置和字型即可
    -- re-parent 會導致 WoW 渲染異常
    local fontPath, fontSize = dur:GetFont()
    if fontPath and fontSize then
        dur:SetFont(fontPath, fontSize, "")
    end
    if DEFAULT_AURA_DURATION_FONT then
        dur:SetFontObject(DEFAULT_AURA_DURATION_FONT)
    end

    dur:SetShadowOffset(0, 0)
    dur:SetShadowColor(0, 0, 0, 1)
    dur:ClearAllPoints()
    dur:SetPoint("TOP", btn, "BOTTOM", 0, -2)

    overriding = false
end

local function ApplyCountStyle(btn)
    local cnt = btn.Count
    if not cnt or not cnt:IsShown() then return end

    overriding = true
    cnt:SetParent(EnsureOverlay(btn))
    cnt:SetWidth(0)
    cnt:ClearAllPoints()
    cnt:SetPoint(db.countAnchor, btn.Icon, db.countAnchor, db.countXOffset, db.countYOffset)
    -- 字型：有自訂就套用，選回「預設」則還原暴雪原本字型
    if db.countFontFace and db.countFontFace ~= "" then
        ApplyCountFont(cnt)
        cnt.AuraEnhance_fontApplied = true
    elseif cnt.AuraEnhance_fontApplied then
        local of = cnt.AuraEnhance_origFont
        if of and of[1] then cnt:SetFont(of[1], of[2] or 14, of[3] or "") end
        cnt.AuraEnhance_fontApplied = false
    end
    overriding = false
end

local function RestoreCountStyle(btn)
    local cnt = btn.Count
    if not cnt then return end

    overriding = true
    -- 不 re-parent：避免 WoW FontString 渲染異常
    cnt:SetWidth(0)
    cnt:ClearAllPoints()
    cnt:SetPoint("BOTTOMRIGHT", btn.Icon, "BOTTOMRIGHT", -2, 2)
    -- 還原自訂字型
    if cnt.AuraEnhance_fontApplied then
        local of = cnt.AuraEnhance_origFont
        if of and of[1] then cnt:SetFont(of[1], of[2] or 14, of[3] or "") end
        cnt.AuraEnhance_fontApplied = false
    end
    overriding = false
end

local function ForEachAuraButton(func)
    for _, container in ipairs({ BuffFrame, DebuffFrame }) do
        if container and container.AuraContainer then
            for _, btn in ipairs({ container.AuraContainer:GetChildren() }) do
                if btn.Icon and not btn.isAuraAnchor then
                    func(btn)
                end
            end
        end
    end
end

------------------------------------------------------------
-- 安裝所有 hooks
------------------------------------------------------------
local function InstallHooks()
    -- 先掛 UpdateGridLayout 攔截未來新建的按鈕
    for _, container in ipairs({ BuffFrame, DebuffFrame }) do
        if container and container.AuraContainer then
            hooksecurefunc(container.AuraContainer, "UpdateGridLayout", function(self, auras)
                if not auras then return end
                for _, aura in ipairs(auras) do
                    if aura and aura.Icon and not aura.isAuraAnchor then
                        if aura.Duration then HookDuration(aura) end
                        if aura.Count    then HookCount(aura) end
                    end
                end
            end)
        end
    end

    -- 現有按鈕：掛 hook + 立刻套用（單次迭代）
    ForEachAuraButton(function(btn)
        if btn.Duration then
            HookDuration(btn)
            if db.enabled then ApplyDurationStyle(btn) end
        end
        if btn.Count then
            HookCount(btn)
            if db.countEnabled then ApplyCountStyle(btn) end
        end
    end)
end

------------------------------------------------------------
-- PUBLIC API（透過 ns 共享給 Options.lua）
------------------------------------------------------------
local API = {}
ns.BuffDurationStyle = API

function API.SetEnabled(enabled)
    GetDB().enabled = enabled
    if enabled then
        ForEachAuraButton(ApplyDurationStyle)
    else
        ForEachAuraButton(RestoreDurationStyle)
    end
end

function API.SetFontFace(path)
    GetDB().fontFace = path or ""
    if GetDB().enabled then ForEachAuraButton(ApplyDurationStyle) end
end

function API.SetFontSize(size)
    GetDB().fontSize = math.max(7, math.min(16, size))
    if GetDB().enabled then ForEachAuraButton(ApplyDurationStyle) end
end

function API.SetOutline(enabled)
    GetDB().outline = enabled
    if GetDB().enabled then ForEachAuraButton(ApplyDurationStyle) end
end

function API.SetYOffset(offset)
    GetDB().yOffset = math.max(-10, math.min(20, offset))
    if GetDB().enabled then ForEachAuraButton(ApplyDurationStyle) end
end

function API.SetCountEnabled(enabled)
    GetDB().countEnabled = enabled
    if enabled then
        ForEachAuraButton(ApplyCountStyle)
    else
        ForEachAuraButton(RestoreCountStyle)
    end
end

function API.SetCountFontFace(path)
    GetDB().countFontFace = path or ""
    if GetDB().countEnabled then ForEachAuraButton(ApplyCountStyle) end
end

function API.SetCountAnchor(anchor)
    GetDB().countAnchor = anchor
    if GetDB().countEnabled then ForEachAuraButton(ApplyCountStyle) end
end

function API.SetCountXOffset(offset)
    GetDB().countXOffset = math.max(-20, math.min(20, offset))
    if GetDB().countEnabled then ForEachAuraButton(ApplyCountStyle) end
end

function API.SetCountYOffset(offset)
    GetDB().countYOffset = math.max(-20, math.min(20, offset))
    if GetDB().countEnabled then ForEachAuraButton(ApplyCountStyle) end
end

function API.GetDB()
    return GetDB()
end

------------------------------------------------------------
-- INITIALIZATION
-- PLAYER_LOGIN：初始化 DB
-- PLAYER_ENTERING_WORLD：Blizzard 的 BuffFrame 已完成首輪布局後才掛 hook
------------------------------------------------------------
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        GetDB()
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_LOGIN")
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        InstallHooks()
    end
end)
