# Capacity & QuickBar Tweaks

A simple UE4SS mod for Subnautica 2 to customize storage capacity and quickbar slots.

## Features
- **Custom Storage Capacity:** Adjust the number of Rows and Columns for floor, wall, and portable lockers.
- **QuickBar Expansion:** Increase your quickbar slots beyond the default count (1-10).
- **Live Updates:** Changes in the mod settings take effect immediately while in-game.
- **Multi Language Support:** The mod automatically detects your in-game language and translates the settings accordingly. If your language is not yet supported, it safely falls back to English.

## Requirements
- [UE4SS - Subnautica 2](https://www.nexusmods.com/subnautica2/mods/36) (Required for running Lua mods)
- [Mod Settings for Subnautica 2](https://www.nexusmods.com/subnautica2/mods/20) (Required for the in-game configuration menu)

## Optional Recommended Mods
- [InventoryScrollBar](https://www.nexusmods.com/subnautica2/mods/24) (Recommended to easily access expanded locker inventories)

## Installation
1. Ensure [UE4SS](https://www.nexusmods.com/subnautica2/mods/36) and [Mod Settings for Subnautica 2](https://www.nexusmods.com/subnautica2/mods/20) are installed.
2. Download the mod.
3. Extract the contents into your `Subnautica2/Binaries/Win64/ue4ss/Mods/` folder.

## Configuration
The mod uses the `Mod Settings` menu to allow easy in-game customization:
- **Enabled Toggles:** Toggle custom capacity for each locker type individually.
- **Locker Settings:** Adjust capacity by defining Rows and Columns (Total capacity = Rows * Columns).
- **QuickBar Slots:** Set the desired number of quickbar slots (1-10).

## Translators Welcome!
Want to enjoy this mod in your native language? You can easily create your own translation by copying `Scripts/Translations/en.lua` and renaming it to your language code (e.g., `de.lua`). Feel free to submit a pull request if you want to share your translation!

## Troubleshooting & Installation Tips
- **Folder Structure:** Please ensure the files are extracted correctly. Your folder path should look like this: 
  `Subnautica2/Binaries/Win64/ue4ss/Mods/CapacityQuickBarTweaks/Scripts/`
  If your zip extractor creates nested folders, please move the files so they match the structure above.
- **Mod Loading:** This mod uses `enabled.txt` to load automatically. If you have any issues, make sure the `enabled.txt` is located directly inside the `CapacityQuickBarTweaks` folder. If it still doesn't load, you can manually register it by adding `CapacityQuickBarTweaks : 1` to your `ue4ss/Mods/mods.txt` file.
- **Language Changes:** This mod automatically translates its settings based on your game language. However, changing your language in-game currently requires a **game restart** for the newly translated texts to actually show up in the Mod Menu.

## Credits & Inspiration
This mod was inspired by the work of:
- [More Quick Slots](https://www.nexusmods.com/subnautica2/mods/38)
- [Bigger Locker Storage (UE4SS)](https://www.nexusmods.com/subnautica2/mods/135)
- [Portable Locker Expanded](https://www.nexusmods.com/subnautica2/mods/173)

---
*Built with UE4SS.*
