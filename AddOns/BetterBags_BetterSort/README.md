# BetterBags - BetterSort

Plugin for the AddOn [BetterBags](https://www.curseforge.com/wow/addons/better-bags) that adds improvements and additions to the default sorting methods.

Currently implemented features:
- Option to sort by item level.
- Improvement to Alphabetical sorting by ignoring color codes.
- Option to ignore Blizzards New Item Tags. Making the "New Item Duration" setting fully in charge.

### Alphabetical Sorting
Currently the default Alphabetical sorting doesn't remove the color prefix from titles when sorting. So eg. `|cffff8000Armor - Leather` would come after `|cffa335eeArmor - Mail` due to `a` coming before `f` in the comparison. This is not intuitive behavior for an Alphabetical sorting.

Since `|` is a special character, the problem actually extends as far as to make the color coded titles always show up at the bottom of the bags with the default sorting method.

This plugin solves this by stripping color codes before sorting, to ensure proper Alphabetical order.

# Examples

A visual example of the default behaviour can be seen here - the letters highlighted in `Red` being the ones that decide the order:

${\Huge{\color{white}{\textsf{|cff\ \}} \color{red}f \space \color{white}{\textsf{f8000Armor - Leather\ \}}}}$

${\Huge{\color{white}{\textsf{|cff\ \}} \color{red}a \space \color{white}{\textsf{335eeArmor - Mail\ \}}}}$

And by removing the color codes when comparing, we get the expected behaviour:

${\Huge{\color{white}{\textsf{Armor - \ \}} \color{red}L \space \color{white}{\textsf{eather\ \}}}}$

${\Huge{\color{white}{\textsf{Armor - \ \}} \color{red}M \space \color{white}{\textsf{ail\ \}}}}$

Practical example, left side with plugin; right side without:

![imgonline-com-ua-twotoone-TDYvPPfCgZFDpz](https://github.com/Krealle/BetterBags_BetterSort/assets/3404958/8ee41bd0-60ea-40ea-b71f-dca8c2d93330)

# Downloads

- [Curseforge](https://www.curseforge.com/wow/addons/betterbags-bettersort)
- [Wago AddOns](https://addons.wago.io/addons/betterbags-bettersort)
- [Wowinterface](https://www.wowinterface.com/downloads/info26720-BetterBags-BetterSort.html)
