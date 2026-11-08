# Myslot

## [v6.3.0](https://github.com/tg123/myslot/tree/v6.3.0) (2026-11-08)
[Full Changelog](https://github.com/tg123/myslot/commits/v6.3.0) 

- Add default import/export IGNORE options to the options panel (#149)  
    Defaults are saved per character and seed the main window's Import and Export ignore menus. The options panel mirrors the main window layout (Export left, Import right) and reuses the same dropdown menu. CreateSettingMenu no longer resets saved scalar flags, so CVars stay opt-in unless a default includes them.  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  