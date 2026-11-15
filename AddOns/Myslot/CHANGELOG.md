# Myslot

## [v6.3.1](https://github.com/tg123/myslot/tree/v6.3.1) (2026-11-14)
[Full Changelog](https://github.com/tg123/myslot/commits/v6.3.1) 

- Support ALT-CTRL-SHIFT-META key bindings (#154)  
    * Support ALT-CTRL-SHIFT-META key bindings (#152)  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  
    * Test export round-trip for every modifier combination  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  
    * Encode key modifiers as a bitmask alongside the legacy code  
    Key gains optional modmask (ALT=1, CTRL=2, SHIFT=4, META=8). Export writes  
    both the legacy mod code (CUSTOM when none exists) and modmask; import  
    prefers modmask, falls back to mod, and skips unknown modifiers instead of  
    erroring. Modifier strings are parsed in any order.  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  
    * Test gamepad chords with emulated modifiers  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  
    * Clarify legacy mod code compatibility for code 122  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  
    * Drop legacy mod code 122; write ALT-CTRL-SHIFT-META as CUSTOM + modmask  
    A new legacy code makes older readers error on import, while CUSTOM is  
    known to them and only produces an unusable binding.  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  
    ---------  
    Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>  