# CraftSim

## [17.0.3](https://github.com/derfloh205/CraftSim/tree/17.0.3) (2024-07-31)
[Full Changelog](https://github.com/derfloh205/CraftSim/compare/17.0.2...17.0.3) [Previous Releases](https://github.com/derfloh205/CraftSim/releases)

- Feature/#321 craft queue (#344)  
    * concentrationCosts update refactor to consider optional reagents  
    * ConcentrationToggle wip  
    * more concentration fixes  
    * also update simulation mode as workaround  
    * Simulation Mode Concentration Toggles  
- #340  
- #342  
- news update  
- use empty concentrationData if no real data has been written yet (#343)  
- Feature/#278 blacksmithing (#341)  
    * means of production  
    * make inventory type useable in node rule mapping  
    * mens of production complete  
    * wip  
    * weapon smithing finished  
    * printrecipeids debug adaption  
    * blacksmithing finished  
    * refactor to string ids instead of numeric to prevent overlap with subitemids  
    * idLocMapping Mapping Option and some renamings  
- ggui update  
- activationBuffID rule property  
- news update  
- TWW/#279 Alchemy Specialization (#324)  
    * Tww/#288 (#294)  
    * version increase  
    * news  
    * toc version  
    * acedb tww update  
    * replace depricated settings api call  
    * updated getCraftingOperationInfo for concentration param  
    * GetSpellInfo deprication fix  
    * gutil  update  
    * AllocateBestQualityCheckbox renaming consideration  
    * comment for followup issue  
    * fill in auto generated weight list (#295)  
    * Concentration Refactor (#296)  
    * resultData refactor  
    * priceData refactor  
    * Profit Calculation Refactor  
    * resultData Fix  
    * statistics module rework  
    * profit explanation update  
    * inspiration removal wip  
    * customer service module removal  
    * AverageProfit Window Size  
    * CraftingOrders  
    * TWW Expansion Const  
    * Tww/#297 recipe scan (#298)  
    * added new skilllineids  
    * migration for itemOptimizedCostsDB  
    * Fixed gear recognition in recipe data constructor  
    * consider reagent increase factor of 0  
    * depricated function fix  
    * migration fix  
    * Tww/#302 craft results (#303)  
    * craft results considering concentration  
    * Craft Statistics Tracker First Draft  
    * Multicraft Tracker  
    * Resourcefulness Tracker  
    * yield statistics tracker and bug fixes (#306)  
    * Tww/#304 specialization info (#307)  
    * basic expansionid check  
    * module renaming  
    * file renaming  
    * specdata files per expansion  
    * preparation for war within specs  
    * alchemy data renaming  
    * module renamings  
    * typings for data providers  
    * base rule node change test  
    * node fetching based on profession and expansionid  
    * more fixes  
    * nodeName from api  
    * cleanup  
    * node ids unused list cleanup  
    * node data structure streamlining  
    * wip  
    * streamline finish  
    * wip  
    * const table instead of function  
    * function to table conversions  
    * moved table declaration to init for preload , move node data to const table  
    * ingenuity stat  
    * wip  
    * updating constants (#309)  
    Co-authored-by: Florian Schneider <derfloh205@gmail.com>  
    * stat percent table per expac  
    * skillequality boolean -> number to represent multiple  
    * TWW Enchant data (#314)  
    * Cooldown charge implementation was causing lua errors when viewing/performing cooldowns (#313)  
    * Tww/#310 spec node prep (#312)  
    * implemented nodes raw  
    * JW base  
    * File Bases  
    * toggled all implementations on for beta  
    * wip  
    * alchemy prep finished  
    * TWW Enchant data (#314)  
    * Cooldown charge implementation was causing lua errors when viewing/performing cooldowns (#313)  
    * merge, fixes, and news update  
    * Enchanting Node Structure  
    * EngineeringAndInscription  
    * leatherworkingAndTailoring  
    * Jewelcrafting  
    * redundancy cleanup  
    * affectedReagentIDs noderule mapping property  
    * ingenuity extra factor node rule property  
    * ingenuity  
    * concentrationCost  
    * concentrationLessUsageFactor noderule property  
    ---------  
    Co-authored-by: Williwams <biscuit1987@gmail.com>  
    * concentration stat weight (#316)  
    * TWW Beta: Specialization Mappings Alchemy  
    Fixes #279  
    * Tww/#288 (#294)  
    * version increase  
    * news  
    * toc version  
    * acedb tww update  
    * replace depricated settings api call  
    * updated getCraftingOperationInfo for concentration param  
    * GetSpellInfo deprication fix  
    * gutil  update  
    * AllocateBestQualityCheckbox renaming consideration  
    * comment for followup issue  
    * fill in auto generated weight list (#295)  
    * Concentration Refactor (#296)  
    * resultData refactor  
    * priceData refactor  
    * Profit Calculation Refactor  
    * resultData Fix  
    * statistics module rework  
    * profit explanation update  
    * inspiration removal wip  
    * customer service module removal  
    * AverageProfit Window Size  
    * CraftingOrders  
    * TWW Expansion Const  
    * Tww/#297 recipe scan (#298)  
    * added new skilllineids  
    * migration for itemOptimizedCostsDB  
    * Fixed gear recognition in recipe data constructor  
    * consider reagent increase factor of 0  
    * depricated function fix  
    * migration fix  
    * Tww/#302 craft results (#303)  
    * craft results considering concentration  
    * Craft Statistics Tracker First Draft  
    * Multicraft Tracker  
    * Resourcefulness Tracker  
    * yield statistics tracker and bug fixes (#306)  
    * Tww/#304 specialization info (#307)  
    * basic expansionid check  
    * module renaming  
    * file renaming  
    * specdata files per expansion  
    * preparation for war within specs  
    * alchemy data renaming  
    * module renamings  
    * typings for data providers  
    * base rule node change test  
    * node fetching based on profession and expansionid  
    * more fixes  
    * nodeName from api  
    * cleanup  
    * node ids unused list cleanup  
    * node data structure streamlining  
    * wip  
    * streamline finish  
    * wip  
    * const table instead of function  
    * function to table conversions  
    * moved table declaration to init for preload , move node data to const table  
    * ingenuity stat  
    * wip  
    * updating constants (#309)  
    Co-authored-by: Florian Schneider <derfloh205@gmail.com>  
    * stat percent table per expac  
    * skillequality boolean -> number to represent multiple  
    * Cooldown charge implementation was causing lua errors when viewing/performing cooldowns (#313)  
    * Tww/#310 spec node prep (#312)  
    * implemented nodes raw  
    * JW base  
    * File Bases  
    * toggled all implementations on for beta  
    * wip  
    * alchemy prep finished  
    * TWW Enchant data (#314)  
    * Cooldown charge implementation was causing lua errors when viewing/performing cooldowns (#313)  
    * merge, fixes, and news update  
    * Enchanting Node Structure  
    * EngineeringAndInscription  
    * leatherworkingAndTailoring  
    * Jewelcrafting  
    * redundancy cleanup  
    * affectedReagentIDs noderule mapping property  
    * ingenuity extra factor node rule property  
    * ingenuity  
    * concentrationCost  
    * concentrationLessUsageFactor noderule property  
    ---------  
    Co-authored-by: Williwams <biscuit1987@gmail.com>  
    * concentration stat weight (#316)  
    * TWW Beta: Specialization Mappings Alchemy  
    Fixes #279  
    * TWW Beta: Specialization Mappings Alchemy  
    Fixes #279 checked on Beta  
    ---------  
    Co-authored-by: Florian Schneider <derfloh205@gmail.com>  
    Co-authored-by: Williwams <biscuit1987@gmail.com>  