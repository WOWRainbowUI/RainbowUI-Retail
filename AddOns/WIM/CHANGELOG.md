# WIM

## [3.13.5](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/tree/3.13.5) (2025-11-21)
[Full Changelog](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/compare/3.13.4...3.13.5) [Previous Releases](https://github.com/Legacy-of-Sylvanaar/wow-instant-messenger/releases)

- Add TOC for 12.00.00  
- Added some secret value checking. When a secret, certain features will be skipped such as History, Filters, string modifiers, etc. I have not been able to test this yet with real secrets. Not sure how message formatting is going to work yet, let me know if you receive errors while in restricted communications.  
    In addition, the game checks if comms are disabled due to restricted area/state. If it is restricted, your message will not be sent, but the message will also not be cleared from the message box so you can resend it afterwards. I'm thinking of adding a queue, and sending the messages once comms are active again.  
- TOC: Add 12.00.00, but still not working with secrets yet.  
- Bypass redundant checks when sending messages and allow SubmitSplitMessage to do all the work for both whispers and chat. Thank you @lootwant #145  
