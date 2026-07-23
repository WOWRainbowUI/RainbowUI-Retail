# Details! Damage Meter

## [Details.20260721.15251.172](https://github.com/Tercioo/Details-Damage-Meter/tree/Details.20260721.15251.172) (2026-07-22)
[Full Changelog](https://github.com/Tercioo/Details-Damage-Meter/compare/Details.20260707.15250.172...Details.20260721.15251.172) 

- Bump version number  
- Update DF  
- Framework dump  
- Merge pull request #1090 from WidgetA/codex/glow-template-fallback  
    Fix glow overlay template fallback  
- Fix glow overlay template fallback using DoesTemplateExist  
    CreateGlowOverlay() picked the spell-alert template from the client's  
    build number, so any client missing both the pre-11.1.7 and post-11.1.7  
    templates (e.g. WoW Classic Titan) hit a hard "Couldn't find inherited  
    node" error. Check DoesTemplateExist() for each template instead of  
    guessing from the build number, and fall back to a plain frame if  
    neither exists.  
    Rebased onto latest master and dropped the frames/window\_wa.lua change  
    from the original submission per review feedback (that file's WeakAuras  
    support is unmaintained/dead).  
