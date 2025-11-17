# WIM

## [3.13.3](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.13.3) (2025-11-14)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.13.2...3.13.3) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Add check for WhisperMode being set to 'in-line'. If it isn't, then whispers can not be suppressed correctly. Added a popup on first game load prompting to change it as well as a shortcut in WIM's options under Whispers -> Window Behavior.  
- fix: Whisper module was being loaded before saved variables were loaded, causing errors sometime accessing addon settings on load.  
