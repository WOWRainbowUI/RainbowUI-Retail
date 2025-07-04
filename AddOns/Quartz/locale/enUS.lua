-- Quartz3 Locale
-- Please use the Localization App on WoWAce to Update this
-- http://www.wowace.com/projects/quartz/localization/ ;¶

local debug = false
--[==[@debug@
debug = true
--@end-debug@]==]

local L = LibStub("AceLocale-3.0"):NewLocale("Quartz3", "enUS", true, debug)

L["%dms"] = true
L["%s Color"] = true
L["%s on %s"] = true
L["<Time in seconds>"] = true
L["1 minute"] = true
L["15 seconds"] = true
L["30 seconds"] = true
L["Above"] = true
L["Adjust the Border Style for non-interruptible Cast Bars"] = true
L["Adjust the X position of the spell name text"] = true
L["Adjust the X position of the time text"] = true
L["Adjust the Y position of the name text"] = true
L["Adjust the Y position of the time text"] = true
L["Alpha"] = true
L["Anchor Frame"] = true
L["Anchor point"] = true
L["AOE Rez"] = true
L["BACKGROUND"] = true
L["Background"] = true
L["Background Alpha"] = true
L["Bar Color"] = true
L["Bar Height"] = true
L["Bar Position"] = true
L["Bar Width"] = true
L["Bars and Colors"] = true
L["Bars unlocked. Move them now and click Lock when you are done."] = true
L["Below"] = true
L["Border"] = true
L["Border Alpha"] = true
L["Border Color"] = true
L["Bottom"] = true
L["Bottom Left"] = true
L["Bottom Right"] = true
L["Breath"] = true
L["Buff"] = true
L["Buff Bar Height"] = true
L["Buff Bar Width"] = true
L["Buff Color"] = true
L["Buff Name Text"] = true
L["Buff Time Text"] = true
L["Cast Bar Color"] = true
L["Cast End Side"] = true
L["Cast Start Side"] = true
L["Cast Time Count Up"] = true
L["Cast Time Precision"] = true
L["Casting"] = true
L["Center"] = true
L["Center (Backdrop)"] = true
L["Center (CastBar)"] = true
L["Change Border Style"] = true
L["Change Color"] = true
L["Change the color of non-interruptible Cast Bars"] = true
L["Channeling"] = true
L["Color debuff bars according to their dispel type"] = true
L["Colors"] = true
L["Complete"] = true
L["Configure the color of the cast bar."] = true
L["Congratulations! You've just upgraded Quartz from the old Ace2-based version to the new Ace3 version!"] = true
L["Copy Settings From"] = true
L["Count up from zero instead of down from the cast duration"] = true
L["Curse Color"] = true
L["Debuff Color"] = true
L["Debuffs by Type"] = true
L["Deplete"] = true
L["DIALOG"] = true
L["Disable and hide the default UI's casting bar"] = true
L["Disable Blizzard Cast Bar"] = true
L["Disable the text that displays the spell name"] = true
L["Disable the text that displays the time remaining on your cast"] = true
L["Disable the text that displays the total cast time"] = true
L["Disease Color"] = true
L["Display target name of spellcasts after spell name"] = true
L["Display the latency time as a number on the latency bar"] = true
L["Display the name of the spell on the bars"] = true
L["Display the names of buffs/debuffs on their bars"] = true
L["Display the names of Mirror Bar Types on their bars"] = true
L["Display the time remaining on buffs/debuffs on their bars"] = true
L["Display the time remaining on the bars"] = true
L["Down"] = true
L["Duel Request"] = true
L["Duration Text"] = true
L["Embed"] = true
L["Embed mode will decrease it's lag estimates by this amount.  Ideally, set it to the difference between your highest and lowest ping amounts.  (ie, if your ping varies from 200ms to 400ms, set it to 0.2)"] = true
L["Embed Safety Margin"] = true
L["Enable"] = true
L["Enable %s"] = true
L["Enable Buffs"] = true
L["Enable Debuffs"] = true
L["Enemy CastBars"] = true
L["Exhaustion"] = true
L["Failed"] = true
L["Feign Death"] = true
L["Fifteen seconds until"] = true
L["Fix bars to a specified duration"] = true
L["Fixed Duration"] = true
L["Flight"] = true
L["Flight Map Color"] = true
L["Focus"] = true
L["Font"] = true
L["Font and Text"] = true
L["Font Size"] = true
L["Forfeit Duel"] = true
L["Free"] = true
L["Game Start"] = true
L["Gap"] = true
L["GCD"] = true
L["Global Cooldown"] = true
L["Grow Direction"] = true
L["Height"] = true
L["Hide Blizz Mirror Bars"] = true
L["Hide Blizzard's mirror bars"] = true
L["Hide Cast Time"] = true
L["Hide Icon"] = true
L["Hide Samwise Icon"] = true
L["Hide Spell Cast Icon"] = true
L["Hide Spell Name"] = true
L["Hide the icon for spells with no icon"] = true
L["Hide Time Text"] = true
L["HIGH"] = true
L["Horizontal"] = true
L["How to display target name of spellcasts after spell name"] = true
L["Icon"] = true
L["Icon Alpha"] = true
L["Icon Gap"] = true
L["Icon Position"] = true
L["Include Latency time in the displayed cast bar."] = true
L["Instance Boot"] = true
L["Interrupt"] = true
L["Interrupt Color"] = true
L["INTERRUPTED (%s)"] = true
L["Latency"] = true
L["Latency Bar"] = true
L["Left"] = true
L["Left (grow down)"] = true
L["Left (grow up)"] = true
L["Length of the new timer, in seconds"] = true
L["Lock"] = true
L["Logout"] = true
L["LOW"] = true
L["Magic Color"] = true
L["Make a new timer using the above settings.  NOTE: it may be easier for you to simply use the command line to make timers, /qt"] = true
L["Make Timer"] = true
L["MEDIUM"] = true
L["Mirror"] = true
L["Mirror Bar Height"] = true
L["Mirror Bar Width"] = true
L["Move the CastBar to center of the screen along the specified axis"] = true
L["Name Text"] = true
L["New Timer Length"] = true
L["New Timer Name"] = true
L["No interrupt cast bars"] = true
L["Number of decimals to show for the Cast Time"] = true
L["Offset"] = true
L["One minute until"] = true
L["Only in Instances"] = true
L["Only show the casts of enemys when inside an instance (dungeon or raid)"] = true
L["Out of Range Color"] = true
L["Outside"] = true
L["Party Invite"] = true
L["Pet"] = true
L["Player"] = true
L["Poison Color"] = true
L["Position"] = true
L["Position the bars"] = true
L["Position the bars for your %s"] = true
L["Quartz3"] = true
L["Quit"] = true
L["Range"] = true
L["Release"] = true
L["Remaining Text"] = true
L["Remaining Time"] = true
L["Resurrect"] = true
L["Resurrect Timer"] = true
L["Reverses the direction of the GCD spark, causing it to move right-to-left"] = true
L["Right"] = true
L["Right (grow down)"] = true
L["Right (grow up)"] = true
L["Sadly, this also means your configuration was lost. You'll have to reconfigure Quartz using the new options integrated into the Interface Options Panel, quickly accessible with /quartz"] = true
L["Scale"] = true
L["Select a bar from which to copy settings"] = true
L["Select a timer to stop"] = true
L["Select where to anchor the %s bars"] = true
L["Select where to anchor the bars"] = true
L["Set a name for the new timer"] = true
L["Set an exact X value for this bar's position."] = true
L["Set an exact Y value for this bar's position."] = true
L["Set the alignment of the spell name text"] = true
L["Set the alignment of the time text"] = true
L["Set the alpha of the bars"] = true
L["Set the alpha of the buff bars"] = true
L["Set the alpha of the casting bar background"] = true
L["Set the alpha of the casting bar border"] = true
L["Set the alpha of the GCD bar"] = true
L["Set the alpha of the latency bar"] = true
L["Set the alpha of the no interrupt casting bar border"] = true
L["Set the alpha of the swing timer bar"] = true
L["Set the bar in front of or behind other UI elements."] = true
L["Set the bar Texture"] = true
L["Set the border style"] = true
L["Set the border style for no interrupt casting bars"] = true
L["Set the buff bar Texture"] = true
L["Set the Cast Bar Texture"] = true
L["Set the color of the %s"] = true
L["Set the color of the bars"] = true
L["Set the color of the bars for %s"] = true
L["Set the color of the bars for buffs"] = true
L["Set the color of the bars for curses"] = true
L["Set the color of the bars for debuffs"] = true
L["Set the color of the bars for diseases"] = true
L["Set the color of the bars for magic"] = true
L["Set the color of the bars for poisons"] = true
L["Set the color of the bars for undispellable debuffs"] = true
L["Set the color of the cast bar when %s"] = true
L["Set the color of the casting bar background"] = true
L["Set the color of the casting bar border"] = true
L["Set the color of the casting bar spark"] = true
L["Set the color of the GCD bar spark"] = true
L["Set the color of the latency text"] = true
L["Set the color of the no interrupt casting bar border"] = true
L["Set the color of the swing timer bar"] = true
L["Set the color of the text for the bars"] = true
L["Set the color of the text for the buff bars"] = true
L["Set the color the cast bar is changed to when you have a spell interrupted"] = true
L["Set the color to turn the cast bar when taking a flight path"] = true
L["Set the color to turn the cast bar when the target is out of range"] = true
L["Set the font size for the bars"] = true
L["Set the font size for the buff bars"] = true
L["Set the font used for the latency text"] = true
L["Set the font used in the bars"] = true
L["Set the font used in the buff bars"] = true
L["Set the font used in the Name and Time texts"] = true
L["Set the grow direction of the %s bars"] = true
L["Set the grow direction of the bars"] = true
L["Set the height of the bars"] = true
L["Set the height of the buff bars"] = true
L["Set the height of the GCD bar"] = true
L["Set the height of the swing timer bar"] = true
L["Set the position of the GCD bar"] = true
L["Set the position of the latency text"] = true
L["Set the position of the swing timer bar"] = true
L["Set the side of the bar that the icon appears on"] = true
L["Set the side of the buff bar that the icon appears on"] = true
L["Set the size of the latency text"] = true
L["Set the size of the spell name text"] = true
L["Set the size of the time text"] = true
L["Set the Spell Cast icon alpha"] = true
L["Set the vertical position of the latency text"] = true
L["Set the width of the bars"] = true
L["Set the width of the buff bars"] = true
L["Set where the Spell Cast icon appears"] = true
L["Settings"] = true
L["Show bar for Ready Checks"] = true
L["Show bar for start of arena and battleground games"] = true
L["Show bars for static popup items such as rez and summon timers"] = true
L["Show buffs for your %s"] = true
L["Show buffs/debuffs for your %s"] = true
L["Show channeling ticks"] = true
L["Show damage / mana ticks while channeling spells like Drain Life or Blizzard"] = true
L["Show debuffs for your %s"] = true
L["Show for Enemies"] = true
L["Show for Friends"] = true
L["Show Icons"] = true
L["Show icons on buffs and debuffs for your %s"] = true
L["Show icons on the bars"] = true
L["Show if Target"] = true
L["Show Mirror"] = true
L["Show mirror bars such as breath and feign death"] = true
L["Show PvP"] = true
L["Show Ready Check"] = true
L["Show Shield Icon"] = true
L["Show Static"] = true
L["Show Target Name"] = true
L["Show Text"] = true
L["Show the Shield Icon on non-interruptible Cast Bars"] = true
L["Show this castbar for friendly units"] = true
L["Show this castbar for hostile units"] = true
L["Show this castbar if focus is also target"] = true
L["Snap to Center"] = true
L["Sorry for the inconvenience, and thanks for using Quartz!"] = true
L["Sort by Remaining Time"] = true
L["Sort the buffs and debuffs by time remaining.  If unchecked, they will be sorted alphabetically."] = true
L["Space between the cast bar and the icon."] = true
L["Spacing"] = true
L["Spark Color"] = true
L["Spell -> Target"] = true
L["Spell Name"] = true
L["Spell Name Font Size"] = true
L["Spell Name Position"] = true
L["Spell Name X Offset"] = true
L["Spell Name Y Offset"] = true
L["Spell on Target"] = true
L["Spell Text"] = true
L["Stop Timer"] = true
L["Strata"] = true
L["Summon"] = true
L["Swing"] = true
L["Target"] = true
L["Target Name Style"] = true
L["Text Alignment"] = true
L["Text Color"] = true
L["Text Position"] = true
L["Texture"] = true
L["Texture and Border"] = true
L["Thirty seconds until"] = true
L["Time Font Size"] = true
L["Time Text"] = true
L["Time Text Position"] = true
L["Time Text X Offset"] = true
L["Time Text Y Offset"] = true
L["Timer"] = true
L["Toggle %s bar lock"] = true
L["Toggle bar lock"] = true
L["Toggle Bar Lock"] = true
L["Toggle Cast Bar lock"] = true
L["Toggle display of text showing the time remaining until you can swing again"] = true
L["Toggle display of text showing your total swing time"] = true
L["Tools"] = true
L["Top"] = true
L["Top Left"] = true
L["Top Right"] = true
L["Tradeskill Merge"] = true
L["Tweak the distance of the GCD bar from the cast bar"] = true
L["Tweak the distance of the swing timer bar from the cast bar"] = true
L["Tweak the horizontal position of the bars"] = true
L["Tweak the horizontal position of the bars for your %s"] = true
L["Tweak the space between bars"] = true
L["Tweak the space between bars for your %s"] = true
L["Tweak the vertical position of the bars"] = true
L["Tweak the vertical position of the bars for your %s"] = true
L["Tweak the vertical position of thebars"] = true
L["Undispellable Color"] = true
L["Unlock the Bars to be able to move them around."] = true
L["Up"] = true
L["Usage: /quartztimer timername 60 or /quartztimer 60 timername"] = true
L["Usage: /quartztimer timername 60 or /quartztimer kill timername"] = true
L["Vertical"] = true
L["Width"] = true
L["X"] = true
L["Y"] = true

-- 自行加入
L["Profiles"] = true
