# WIM

## [3.15.3](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.15.3) (2026-02-13)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.15.2...3.15.3) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Refactor to avoid compilation warnings.  
- Fix handling of secrets. WIM will ignore all chat events that contain a secret falling back to WoW's default behavior of handling messages. WIM will NOT be able to display this messages, nor will they be able to filter or save to history messages which contain secrets.  
