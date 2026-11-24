# Myslot

## [v6.3.2](https://github.com/tg123/myslot/tree/v6.3.2) (2026-11-23)
[Full Changelog](https://github.com/tg123/myslot/commits/v6.3.2) 

- Add CLEAR before Import to default settings (#156)  
    * Add CLEAR before Import to default settings  
    The options panel's Default Import menu now offers CLEAR before Import defaults (when CLEAR before Import is allowed), seeding the Import dropdown's clear options. Import only clears when CLEAR before Import is allowed. The GUI test harness moves to ci/gui\_harness.lua and GUI tests to tests/cases/gui.lua.  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  
    * Address review: back up cleared categories, apply only changed defaults, rebuild import menu  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  
    * Back up macros referenced by action bars and click bindings selected for CLEAR  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  
    * Test that import skips CLEAR when CLEAR before Import is disallowed  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  
    ---------  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  