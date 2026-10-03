# Myslot

## [v6.2.0](https://github.com/tg123/myslot/tree/v6.2.0) (2026-09-29)
[Full Changelog](https://github.com/tg123/myslot/commits/v6.2.0) 

- Make /myslot clear options table local (#138)  
    The clear command assigned a global 'opt', which luacheck allowed via the globals whitelist. Declare it local and drop it from .luacheckrc so luacheck catches any future leak.  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  