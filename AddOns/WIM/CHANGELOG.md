# WIM

## [3.10.24](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.10.24) (2024-05-24)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.10.23...3.10.24) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Add module to ignore censored messages. If you receive a message that has been censored, it will be delivered to the default chat frame instead of WIM. This is a work around for replicating the default behavior within WIM itself as its implementation is too complicated at this time.  
- Experimental: Run a second pass through ChatMessageEventFilters when displaying message in WIM windows. This allows for other addons such as Questie which depend on the chat frame in order to format their links. This will only work on newly received messages, support for messages saved in history is not possible. #50  
- Fix: Messages sent/received quickly within the same second could sometimes be displayed in history in the incorrect order. #66  
- Update History to used normalized name in whispers.  
- Fix cross-server message delivery and normalize whisper window indexing. #76  
- Fix color picker on retail. #67 #74  
