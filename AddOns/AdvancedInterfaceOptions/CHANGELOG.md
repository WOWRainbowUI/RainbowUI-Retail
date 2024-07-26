# Advanced Interface Options

## [1.9.1](https://github.com/Stanzilla/AdvancedInterfaceOptions/tree/1.9.1) (2024-06-11)
[Full Changelog](https://github.com/Stanzilla/AdvancedInterfaceOptions/compare/1.9.0...1.9.1) [Previous Releases](https://github.com/Stanzilla/AdvancedInterfaceOptions/releases)

- Add TWW TOC  
- Switch to new Settings API  
- Fix CvarUtil pattern matching  
    Seems like all the different clients have slightly different SharedXML/CvarUtil now.  
    This should catch anything SharedXML/CvarUtil.lua or SharedXML/ClassicCvarUtil.lua (SoD)  
    or Blizzard\_SharedXML/CvarUtil.lua  (Cata Classic) now.  
    Fixes #80  
