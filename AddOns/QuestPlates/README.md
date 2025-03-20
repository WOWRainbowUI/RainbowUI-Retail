[![](https://img.shields.io/static/v1?label=Donate&message=CashApp&color=brightgreen)](https://bit.ly/3fyxxSU)

# QuestPlates (Fork)

## Note
**Original Creator:** The original version of this addon was created by Semlar.  
**Permissions:** I do not have permissions to publish this onto CurseForge, and the original creator is currently AWOL. Despite reaching out, I have been unable to contact them. This is a fork of their work, with updates and improvements made where necessary.

---

## Overview
**QuestPlates** is an addon for World of Warcraft that enhances nameplates by displaying quest objectives directly on enemy health bars. This fork builds upon Semlar’s original addon with performance improvements and updated compatibility for the **The War Within** expansion.

---

## Features
- **Quest Objectives on Nameplates:** Displays the remaining mobs to kill or items to collect directly on the nameplate.
- **Customizable Settings:** Modify the position, size, and appearance of quest icons using simple commands.
- **Compatibility with Other Nameplate Addons:** Works seamlessly with TidyPlates, KuiNameplates, and Blizzard default nameplates.

---

## Usage

To customize icon position and size, use the following commands:

- Move the quest icon from the left to the right side of the nameplate:
  ```bash
  /run QuestPlateSettings.AnchorPoint = 'LEFT'; QuestPlateSettings.RelativeTo = 'RIGHT'; ReloadUI()
  ```

- Adjust the X (horizontal) and Y (vertical) offsets:
  ```bash
  /run QuestPlateSettings.OffsetX = -10; QuestPlateSettings.OffsetY = 5; ReloadUI()
  ```

- Reset settings to default:
  ```bash
  /run QuestPlateSettings = nil; ReloadUI()
  ```

---

## Compatibility
- **Retail (The War Within)**

---

## Installation
1. Download the addon from [CurseForge](https://legacy.curseforge.com/wow/addons/questplates-tww).
2. Extract the downloaded file into the appropriate World of Warcraft AddOns directory:
   - For **The War Within**: `World of Warcraft/_retail_/Interface/AddOns`
3. Restart World of Warcraft and enable the addon in the AddOns menu.

---

## Support the Project

### ☕️ Buy Me a Coffee
If you enjoy this addon and would like to support its development, consider buying me a coffee. Your contributions help me maintain and improve this project!

[![Buy Me a Coffee](https://img.shields.io/badge/☕️-Buy%20Me%20a%20Coffee-orange?style=flat-square&logo=buy-me-a-coffee)](https://www.buymeacoffee.com/donniedice)

---

## Stay Connected

### 💸 Support:
[![Donate via CashApp](https://img.shields.io/static/v1?label=Donate&message=CashApp&color=brightgreen)](https://bit.ly/3fyxxSU)

### 💬 Follow:
- Follow me on [GitHub](https://github.com/donniedice)

### ⭐️ Show Your Support:
- Star this project on [GitHub](https://github.com/donniedice/QuestPlates) ⭐️
- Share it with your friends and guildmates 📢
