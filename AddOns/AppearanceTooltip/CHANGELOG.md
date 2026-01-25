# AppearanceTooltip

## [v74](https://github.com/kemayo/wow-appearancetooltip/tree/v74) (2026-01-25)
[Full Changelog](https://github.com/kemayo/wow-appearancetooltip/compare/v73...v74) [Previous Releases](https://github.com/kemayo/wow-appearancetooltip/releases)

- Change the order of transmog-known checks  
    PlayerHasTransmogByItemInfo turned out to over-claim when given a link  
    that has variants. As such, only use it as a fallback if the appearance  
    can't be found.  
- Support multiple bonuses from generic tier tokens  
    This happens from the encounter journal, which has unbonused versions of  
    the tokens regardless of the selected raid variant  
