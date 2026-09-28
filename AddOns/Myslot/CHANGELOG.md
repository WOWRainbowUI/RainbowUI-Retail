# Myslot

## [v6.1.1](https://github.com/tg123/myslot/tree/v6.1.1) (2026-09-26)
[Full Changelog](https://github.com/tg123/myslot/commits/v6.1.1) 

- Fix export crash on WoW Forever and add 16001 to the TOC (#132)  
    * Fix export crash on WoW Forever without the legacy talent grid  
    WoW Forever (1.60.x, toc 16001) runs the 12.1 engine with vanilla  
    content. It has C\_SpellBook.GetNumSpellBookSkillLines, so  
    CreateSpellOverrideMap takes the retail branch, but MAX\_TALENT\_TIERS is  
    nil there and Export failed with "Myslot.lua:210: 'for' limit must be a  
    number".  
    Only scan the tier/column talents when GetNumSpecGroups, GetTalentInfo,  
    MAX\_TALENT\_TIERS and NUM\_TALENT\_COLUMNS all exist, and guard the PvP  
    talent scan on C\_SpecializationInfo.GetPvpTalentSlotInfo and  
    GetPvpTalentInfoByID the same way.  
    Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>  
    * Add WoW Forever (16001) to the TOC interface list  
    None of the packager's Interface-* directives cover WoW Forever, so  
    without 16001 on the main Interface line Myslot loaded there only as  
    out of date. BugSack, RXPGuides and EllesmereUI list it the same way.  
    Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>  
    ---------  
    Co-authored-by: Claude Opus 5.5 <noreply@anthropic.com>  