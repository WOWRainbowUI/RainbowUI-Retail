# GatherMate2_InstanceFix

**GatherMate2_InstanceFix** is a simple, lightweight plugin designed to resolve a Lua error that occurrs when gathering inside instances and delves.

### What It Does
When looting certain items in instances, the game sometimes obscures the item or node name as a "secret value" and throws a Lua error. This plugin intercepts those hidden values before GatherMate2 tries to process them,  preventing the error.


### Requirements
* **[GatherMate2](https://www.curseforge.com/wow/addons/gathermate2)** must be installed and enabled.

### Installation
1. Download the latest version of **GatherMate2_InstanceFix**.
2. Extract the `GatherMate2_InstanceFix` folder into your World of Warcraft AddOns directory: `\_retail_\Interface\AddOns\`
3. Ensure both **GatherMate2** and **GatherMate2_InstanceFix** are enabled in your in-game Addon list. 

### Disclaimer
This is an unofficial, community-created fix. It is not affiliated with or supported by the original GatherMate2 authors. Once GatherMate2 releases an official update that handles `issecretvalue` checks natively, this addon can be disabled or uninstalled.