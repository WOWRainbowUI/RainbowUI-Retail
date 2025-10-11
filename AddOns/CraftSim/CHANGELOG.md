# CraftSim

## [20.3.0](https://github.com/derfloh205/CraftSim/tree/20.3.0) (2025-10-10)
[Full Changelog](https://github.com/derfloh205/CraftSim/compare/20.2.4...20.3.0) [Previous Releases](https://github.com/derfloh205/CraftSim/releases)

- added collab notes  
- Update version to 20.3.0  
- Recognize correct amount of gems saved by resourcefulness when crushing gems (#894)  
    * Fix issue where the number of logged crafts was lower than the actual number of crafts  
    This changeset adds more accurate counting of the number of crafts that  
    have been done. It was possible for one craft to be counted multiple times,  
    and for multiple crafts to be counted as one craft depending on the timing  
    of TRADE\_SKILL\_ITEM\_CRAFTED\_RESULT events and the player's framerate.  
    For me this was easiest to observe when crafting potions or flasks by  
    starting a run of 10 crafts, then observing the "Crafts" number on the  
    advanced craft log showing something lower than 10.  
    This fix in turn makes the statistics related to crafting costs and profit  
    more accurate.  
    * Recognize correct amount of gems saved by resourcefulness when crushing gems  
    This changeset is a workaround for the fact that the in game API's don't  
    include all resourcefulness savings when crushing gems into crushed gemstones.  
    This fixes the scenarios described below:  
    	 If the crafting result saves only bismuth, it saves the same # of gems, up to 3 (#gems required for recipe)  
    	-- ex: if only bismuth saved, and 1 saved - also saved 1 gem  
    	-- ex: if only bismuth saved, and 2 saved - also saved 2 gem  
    	-- ex: if only bismuth saved, and 3 saved - also saved 3 gem  
    	-- ex: if only bismuth saved, and 4 saved - also saved 3 gem  
    This makes later calculations much more accurate, namely the profit and  
    resourcefulness saved costs when crushing gems.  
    ---------  
    Co-authored-by: genjuwow <derfloh205@gmail.com>  
- news  
- Ensure professionStats data is correct after doing AverageProfit calculations (#893)  
    This changeset fixes an issue where the professionStats on recipeData  
    are modified in-place to calculate the impact of resourcefulness/multicraft  
    points in the AverageProfit module. The changes were reverted, but the  
    old values were still used in later calculations because recipeData:Update()  
    wasn't called.  
    This can be observed on salvage recipes when using the bountiful phials that  
    add resourcefulness points during winter months. The bountiful phial bonus  
    resourcefulness is not recognized without this change.  
- news  
- Fix issue where the number of logged crafts was lower than the actual number of crafts (#892)  
    This changeset adds more accurate counting of the number of crafts that  
    have been done. It was possible for one craft to be counted multiple times,  
    and for multiple crafts to be counted as one craft depending on the timing  
    of TRADE\_SKILL\_ITEM\_CRAFTED\_RESULT events and the player's framerate.  
    For me this was easiest to observe when crafting potions or flasks by  
    starting a run of 10 crafts, then observing the "Crafts" number on the  
    advanced craft log showing something lower than 10.  
    This fix in turn makes the statistics related to crafting costs and profit  
    more accurate.  