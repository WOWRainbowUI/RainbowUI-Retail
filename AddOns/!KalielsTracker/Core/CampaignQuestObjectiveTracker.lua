local settings = {
	headerText = TRACKER_HEADER_CAMPAIGN_QUESTS,
	events = { "QUEST_LOG_UPDATE", "QUEST_WATCH_LIST_CHANGED" },
	lineTemplate = "KT_ObjectiveTrackerAnimLineTemplate",
};

KT_CampaignQuestObjectiveTrackerMixin = CreateFromMixins(KT_QuestObjectiveTrackerMixin, settings);

function KT_CampaignQuestObjectiveTrackerMixin:ShouldDisplayQuest(quest)
	return (quest:GetQuestClassification() == Enum.QuestClassification.Campaign) and not quest:IsDisabledForSession();
end