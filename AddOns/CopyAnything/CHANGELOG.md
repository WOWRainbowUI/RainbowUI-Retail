# Copy Anything

## [v1.1.41](https://github.com/Oppzippy/CopyAnything/tree/v1.1.41) (2026-01-28)
[Full Changelog](https://github.com/Oppzippy/CopyAnything/compare/v1.1.40...v1.1.41) [Previous Releases](https://github.com/Oppzippy/CopyAnything/releases)

- fix type that can be nil  
- Fix secret value issues on retail  
    This makes use of `canaccessvalue` before touching anything returned  
    from Frame methods to ensure it's not secret.  
    Also refactor to use iterators instead of tables  
