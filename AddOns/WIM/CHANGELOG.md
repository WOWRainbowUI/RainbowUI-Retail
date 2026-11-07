# WIM

## [3.19.2](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.19.2) (2026-11-06)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.19.1...3.19.2) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Fix: WIM no longer steals focus from the chat frame if you are currently typing.  
- Fix Trade & Services chat from being merged into the same chat window.  
    - Instead of normalizing a channel name from the message event string, we do a look up by channel number. This ensures channel settings and message processing are in line with each other. #302  
