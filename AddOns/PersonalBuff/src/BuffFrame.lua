local BuffFrame = {}
local Masque, MSQ_Version = LibStub("Masque", true)
IconGroup = nil

local function CreateIcon(IconSetting)
    local frame = CreateFrame("Button", nil ,IconSetting.parent)
    frame:SetSize(IconSetting.iconSize, IconSetting.iconSize)
    frame:SetPoint("Center")

    local icon = frame:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints()
    icon:SetTexture(C_Spell.GetSpellTexture(IconSetting.SpellID))
    frame.icon = icon

    local count = frame:CreateFontString(nil, "ARTWORK")
    count:SetFont(IconSetting.countFont, IconSetting.countFontSize, "OUTLINE")
    count:SetPoint("BOTTOMRIGHT", 0, 0)
    count:SetJustifyH("RIGHT")
    frame.count = count

    local text = frame:CreateFontString(nil, "OVERLAY")
    text:SetFont(IconSetting.font, IconSetting.fontSize, "OUTLINE")
    text:SetPoint("CENTER", 0, 0)
    frame.text = text

    frame:SetSize(IconSetting.iconSize, IconSetting.iconSize)
    frame:SetScale(1)

    local cooldown = CreateFrame("Cooldown", nil , frame, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    cooldown:SetSwipeColor(1, 1, 1, 0.8)
    cooldown:SetHideCountdownNumbers(true)
    cooldown:SetDrawEdge(false)
    cooldown:SetDrawSwipe(true)
    cooldown.noCooldownCount = true
    cooldown:SetHideCountdownNumbers(true)
    frame.cooldown = cooldown

    local cooldownCount = cooldown:CreateFontString(nil, "ARTWORK")
    cooldownCount:SetFont(IconSetting.countFont, IconSetting.countFontSize, "OUTLINE")
    cooldownCount:SetPoint("BOTTOMRIGHT", 0, 0)
    cooldownCount:SetJustifyH("RIGHT")
    frame.cooldownCount = cooldownCount

    local cooldownText = cooldown:CreateFontString(nil, "OVERLAY")
    cooldownText:SetFont(IconSetting.font, IconSetting.fontSize, "OUTLINE")
    cooldownText:SetPoint("CENTER", 0, 0)
    frame.cooldownText = cooldownText

    frame:SetSize(IconSetting.iconSize, IconSetting.iconSize)
    frame:SetScale(1)

    frame.iconSetting = nil
    frame.timer = nil

    if IconSetting.group then
        IconSetting.group:AddButton(frame)
    end

    return frame
end


local function clearIcon(icon)
    icon:Hide()
end

local function setAuraTime(iconSetting)
    if iconSetting.time and iconSetting.time~=0 and BuffFrame.icons[iconSetting.spellID] ~= nil then
        local AuraTime = iconSetting.time - GetTime()
        BuffFrame.icons[iconSetting.spellID].iconSetting = iconSetting
        if iconSetting.duration == 0 then
            if(AuraTime > 60) then
                BuffFrame.icons[iconSetting.spellID].text:SetText(math.floor(AuraTime / 60) .. "m")
            elseif (AuraTime > 3) then
                BuffFrame.icons[iconSetting.spellID].text:SetText(string.format("%.0f", AuraTime))
            elseif (AuraTime > 0) then
                BuffFrame.icons[iconSetting.spellID].text:SetText(string.format("%.1f", AuraTime))
            end
        else
            if(AuraTime > 60) then
                BuffFrame.icons[iconSetting.spellID].cooldownText:SetText(math.floor(AuraTime / 60) .. "m")
            elseif (AuraTime > 3) then
                BuffFrame.icons[iconSetting.spellID].cooldownText:SetText(string.format("%.0f", AuraTime))
            elseif (AuraTime > 0) then
                BuffFrame.icons[iconSetting.spellID].cooldownText:SetText(string.format("%.1f", AuraTime))
            end
        end

    else

    end
end

local function setAuraTimer(iconSetting)
    local AuraTime = iconSetting.time - GetTime()
    if BuffFrame.icons[iconSetting.spellID].timer ~= nil then
        BuffFrame.icons[iconSetting.spellID].timer:Cancel()
    end
	if AuraTime ~= nil and AuraTime >=0 and BuffFrame.icons[iconSetting.spellID]:IsShown() then
		BuffFrame.icons[iconSetting.spellID].timer = C_Timer.NewTicker(0.1, function() setAuraTime(iconSetting)end ,math.floor(AuraTime * 10))
	end
end

local function setStackCount(iconSetting)
    if iconSetting.count ~=0 then
        if iconSetting.duration == 0 and iconSetting.count ~=1 then
            BuffFrame.icons[iconSetting.spellID].count:SetText(iconSetting.count)
        else
            BuffFrame.icons[iconSetting.spellID].cooldownCount:SetText(iconSetting.count)
        end
    end
end

function BuffFrame:clear()
    for _,i in pairs(BuffFrame.icons) do
        clearIcon(i)

        if i.timer ~= nil then
            i.timer:Cancel()
        end
    end
end

function BuffFrame:SetFont()
    for _,i in pairs(BuffFrame.icons) do
        i.cooldownText:SetFont(BuffFrame.FrameSetting.IconSetting.font, BuffFrame.FrameSetting.IconSetting.fontSize, "OUTLINE")
        i.text:SetFont(BuffFrame.FrameSetting.IconSetting.font, BuffFrame.FrameSetting.IconSetting.fontSize, "OUTLINE")
    end
end

function BuffFrame:SetCountFont()
    for _,i in pairs(BuffFrame.icons) do
        i.cooldownCount:SetFont(BuffFrame.FrameSetting.IconSetting.countFont, BuffFrame.FrameSetting.IconSetting.countFontSize, "OUTLINE")
        i.count:SetFont(BuffFrame.FrameSetting.IconSetting.countFont, BuffFrame.FrameSetting.IconSetting.countFontSize, "OUTLINE")
    end
end

function BuffFrame:SetIconSize()
    BuffFrame.Frame:SetSize(BuffFrame.FrameSetting.IconSetting.iconSize * 10, BuffFrame.FrameSetting.IconSetting.iconSize)

    for _,i in pairs(BuffFrame.icons) do
        i:SetSize(BuffFrame.FrameSetting.IconSetting.iconSize,BuffFrame.FrameSetting.IconSetting.iconSize)
        --i.icon:SetSize(BuffFrame.FrameSetting.IconSetting.iconSize,BuffFrame.FrameSetting.IconSetting.iconSize)
        --i.cooldown:SetSize(BuffFrame.FrameSetting.IconSetting.iconSize,BuffFrame.FrameSetting.IconSetting.iconSize)
        i.icon:SetAllPoints()
        i.cooldown:SetAllPoints()
    end

    if BuffFrame.FrameSetting.IconSetting.group then
        BuffFrame.FrameSetting.IconSetting.group:ReSkin(true)
    end
end

local function displayIcon(iconSetting,last)
    if BuffFrame.icons[iconSetting.spellID] == nil or BuffFrame.icons[iconSetting.spellID] == last then
        return last
    end
    BuffFrame.icons[iconSetting.spellID]:Show()
    BuffFrame.icons[iconSetting.spellID]:SetAlpha(1)

    BuffFrame.icons[iconSetting.spellID]:ClearAllPoints()
    BuffFrame.icons[iconSetting.spellID]:SetScale(1)


    if last == nil then
        BuffFrame.icons[iconSetting.spellID]:SetPoint("BOTTOMLEFT", BuffFrame.FrameSetting.IconSetting.XOffset + BuffFrame.FrameSetting.IconSetting.iconSize , BuffFrame.FrameSetting.IconSetting.YOffset)
    else
        BuffFrame.icons[iconSetting.spellID]:SetPoint("RIGHT", last, "RIGHT", BuffFrame.FrameSetting.IconSetting.iconSize + BuffFrame.FrameSetting.IconSetting.iconSpacing + 1, 0)
    end

    BuffFrame.icons[iconSetting.spellID].cooldown:SetCooldown(iconSetting.time - iconSetting.duration , iconSetting.duration)
	
	--BuffFrame.icons[iconSetting.spellID]:SetScript("OnEnter", function(self)
    --    GameTooltip:SetOwner(self, "ANCHOR_PRESERVE")
    --    GameTooltip:SetUnitAura(iconSetting.source, iconSetting.auraIndex, "HELPFUL")
    --    GameTooltip:Show()
    --    end)
	--	BuffFrame.icons[iconSetting.spellID]:SetScript("OnLeave", function(self)
    --        GameTooltip:Hide()
    --    end)

    return BuffFrame.icons[iconSetting.spellID]
end


local function reloadTexture(SpellID)
    BuffFrame.icons[SpellID].icon:SetTexture(GetSpellTexture(SpellID))
end

function BuffFrame:display(enableAuraTable)
    local last
    for i,k in ipairs(enableAuraTable) do
        local iconSetting = {}
		iconSetting.name = k["name"]
        iconSetting.spellID = k["spellId"]
        iconSetting.time = k["expirationTime"]
        iconSetting.order = i
        iconSetting.duration = k["duration"]
        iconSetting.count = k["applications"]
        iconSetting.alpha = enableAuraTable.alpha
        iconSetting.nameplateShowPersonal = k["nameplateShowPersonal"]
		iconSetting.auraIndex = k[2]
		iconSetting.source = k[4]
        last = displayIcon(iconSetting,last)
        setAuraTime(iconSetting)
        setAuraTimer(iconSetting)
        setStackCount(iconSetting)
    end
    last = nil
end

function BuffFrame:SetFramePoint(parent)
    BuffFrame.Frame:SetPoint("LEFT", parent ,"LEFT",-( BuffFrame.FrameSetting.IconSetting.iconSize ),
            ((BuffFrame.FrameSetting.IconSetting.iconSize - 20) / 3) + 2)
    BuffFrame.Frame:SetParent(C_NamePlate.GetNamePlateForUnit("player", issecure()))
end

function CreateBuffFrame(FrameSetting)
    BuffFrame.Frame = CreateFrame("Frame",nil, nil)
    BuffFrame.Frame:SetSize(FrameSetting.Width,FrameSetting.Height)
    FrameSetting.IconSetting.parent = BuffFrame.Frame
    BuffFrame.icons = {}

    if Masque then
        local L = LibStub("AceLocale-3.0"):GetLocale("PersonalBuff")
		IconGroup = Masque:Group(L["Personal Buff"], L["IconGroup"])
    end

    for _,i in ipairs(FrameSetting.Spells) do
        FrameSetting.IconSetting.group = IconGroup
        FrameSetting.IconSetting.SpellID = i
        BuffFrame.icons[i] = CreateIcon(FrameSetting.IconSetting)
		clearIcon(BuffFrame.icons[i])
    end
    BuffFrame.FrameSetting = FrameSetting
    return BuffFrame
end

function addCustomIcon(spellID)
    if BuffFrame.icons[spellID] == nil then
        BuffFrame.FrameSetting.IconSetting.group = IconGroup
        BuffFrame.FrameSetting.IconSetting.SpellID = spellID
        BuffFrame.icons[spellID] = CreateIcon(BuffFrame.FrameSetting.IconSetting)
		clearIcon(BuffFrame.icons[spellID])
    end
end