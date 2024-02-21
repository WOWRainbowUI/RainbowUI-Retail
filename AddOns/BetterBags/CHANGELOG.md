# BetterBags

## [v0.1.7](https://github.com/Cidan/BetterBags/tree/v0.1.7) (2024-02-20)
[Full Changelog](https://github.com/Cidan/BetterBags/compare/v0.1.6...v0.1.7) [Previous Releases](https://github.com/Cidan/BetterBags/releases)

- Bag Refresh and Rendering (#181)  
    * Picking up items while in combat will now delay drawing picked up items in your bag until combat is over. This fixes the weird graphical issues that happen sometimes when looting items while in combat (icons appearing large, etc). This is a temporary workaround to the fact that rendering bags takes a long time. More work and research will be conducted on how to make this better in time.  
    * Added a hackfix for Masque addons that are out of date and don't apply icon border blend like they are supposed to.  
    * Reworked some internals and fixed some obscure bugs that would cause some slowdowns in some cases.  