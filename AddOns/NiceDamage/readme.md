# NiceDamage (Reloaded)

**NiceDamage (Reloaded)** is a lightweight combat text font addon for World of Warcraft that allows you to customize the appearance, size, and animation behavior of damage and healing numbers.

It modifies Blizzard's implementation of combat text fonts. Meaning it should not have any performance impact.

---

## ⚠️ Important: Application of Changes
Due to how the World of Warcraft engine handles 3D world text:
* **Changing the Font File:** Requires you to **Log Out** to the character selection screen and log back in. A `/reload` will NOT work for the initial font load.
* **Changing Size, Gravity, or Duration:** Takes effect **instantly** without needing to relog or reload.

---

## Features

* **Custom Font Selection:** Choose from a curated list of popular combat fonts including Pepsi, Bangers, Big Noodle Titling, and Expressway.
* **Font Scaling:** Real-time adjustment of damage number sizes.
* **Animation Control:** Fine-tune the "physics" of your combat text by adjusting **Gravity** (how fast numbers fall) and **Ramp Duration** (how long they stay on screen).
* **SharedMedia Support:** Automatically detects fonts from other addons installed in your game.

---

## Configuration

Access the settings panel using:
* `Escape` > `Options` > `Addons` > `NiceDamage (Reloaded)`.
* Type `/nicedamage` or `/nd` ingame.

---

## Included Fonts

**NiceDamage (Reloaded)** comes bundled with a curated selection of fonts:

* **Pepsi Modern:** The classic look (Default for Western clients).
* **Zero Cool:** A bold, high-energy font (Default for RU clients).
* **Pepsi Cursive:** A stylized cursive variant.
* **Technical/Pixel Fonts:** Pf Tempesta Seven, Prototype, Expressway.
* **Thematic Fonts:** Die Die Die, LifeCraft, Big Noodle Titling.

---

## Installing Your Own Fonts

### Option 1: The "Custom Font NDR" Toggle (Simple)
If you want to use a specific `.ttf` file without installing other addons:
**Note that updating the addon will remove your custom font file, so back it up!**

1. Navigate to `_retail_/Interface/AddOns/NiceDamage/fonts/`.
2. Place your desired font file in this folder and rename it to `customfontndr.ttf`.
3. In-game, open the settings and check **"Load Custom Font"**.
4. **Log out** to the character screen and log back in.
5. Select **"Custom Font NDR"** from the font dropdown menu.

### Option 2: Using the SharedMedia Addon (Recommended)
For managing multiple custom fonts, use the [SharedMedia](https://www.curseforge.com/wow/addons/sharedmedia) addon. Once you register a font there, NiceDamage will automatically list it in the selection menu.

---

## Troubleshooting

* **Font hasn't changed:** You need to log out to the character selection screen and log back in. The 3D world engine cannot swap the base font file while ingame.
* **Gravity/Scale isn't working:** Check if another addon (like ElvUI or MikScrollingCombatText) is controlling your combat text.
* **Question Marks (???) for numbers:** The font you selected does not support your language's character set (e.g., using a Latin-only font on a Russian or Asian client). Switch to **Roboto Bold** or **Expressway** for better character support.
* **ElvUI Conflicts:** To use NiceDamage with ElvUI:
    * **Option A:** Disable ElvUI's "CombatText" module. Found in ElvUI settings under General > Fonts > Combat Font.
    * **Option B:** Keep NiceDamage enabled to "register" the font in your library, then select that font name inside ElvUI's font settings. Found in ElvUI settings under General > Fonts > Combat Font.

---

## Credits
Maintained by **Azaiko**. 
Inspired by the legacy of the original NiceDamage and the Pepsi combat text style used by the community for over a decade.