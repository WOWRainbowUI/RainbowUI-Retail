KT_POIButtonUtil = {};

KT_POIButtonUtil.Type = {
	Custom = 1,
	Quest = 2,
	Content = 3,
	AreaPOI = 4,
	Vignette = 5,
};

KT_POIButtonUtil.Style = {
	Waypoint = 1,
	QuestInProgress = 2,
	QuestComplete = 3,
	QuestDisabled = 4,
	QuestThreat = 5,
	ContentTracking = 6,
	WorldQuest = 7,
	BonusObjective = 9,
	AreaPOI = 10,
	Vignette = 11,
};

local styleXType = {
	[KT_POIButtonUtil.Style.Waypoint] = KT_POIButtonUtil.Type.None,
	[KT_POIButtonUtil.Style.QuestInProgress] = KT_POIButtonUtil.Type.Quest,
	[KT_POIButtonUtil.Style.QuestComplete] = KT_POIButtonUtil.Type.Quest,
	[KT_POIButtonUtil.Style.QuestDisabled] = KT_POIButtonUtil.Type.Quest,
	[KT_POIButtonUtil.Style.QuestThreat] = KT_POIButtonUtil.Type.Quest,
	[KT_POIButtonUtil.Style.ContentTracking] = KT_POIButtonUtil.Type.Content,
	[KT_POIButtonUtil.Style.WorldQuest] = KT_POIButtonUtil.Type.Quest,
	[KT_POIButtonUtil.Style.BonusObjective] = KT_POIButtonUtil.Type.Quest,
	[KT_POIButtonUtil.Style.AreaPOI] = KT_POIButtonUtil.Type.AreaPOI,
	[KT_POIButtonUtil.Style.Vignette] = KT_POIButtonUtil.Type.Vignette,
}

function KT_POIButtonUtil.GetStyle(questID)
	local quest = KT_QuestCache:Get(questID);

	if quest:IsComplete() then
		return KT_POIButtonUtil.Style.QuestComplete;
	elseif quest:IsDisabledForSession() then
		return KT_POIButtonUtil.Style.QuestDisabled;
	else
		return KT_POIButtonUtil.Style.QuestInProgress;
	end
end

function KT_POIButtonUtil.GetTypeFromStyle(style)
	return styleXType[style];
end

function KT_POIButtonUtil.ShowLegendGlow(pin)
    if not pin.LegendGlow then
        local glow = pin:CreateTexture(nil, "BACKGROUND");
        if pin.Glow then
            glow:SetPoint("TOPLEFT", pin.Glow, "TOPLEFT");
            glow:SetPoint("BOTTOMRIGHT", pin.Glow, "BOTTOMRIGHT");
        else
            glow:SetPoint("TOPLEFT", pin, "TOPLEFT", -18, 18);
            glow:SetPoint("BOTTOMRIGHT", pin, "BOTTOMRIGHT", 18, -18);
        end
        glow:SetAtlas("UI-QuestPoi-OuterGlow");
        pin.LegendGlow = glow;
    end
    pin.LegendGlow:Show();
end

function KT_POIButtonUtil.HideLegendGlow(pin)
    pin.LegendGlow:Hide();
end