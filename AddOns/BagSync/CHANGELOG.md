# BagSync

## [v19.26](https://github.com/Xruptor/BagSync/tree/v19.26) (2024-02-16)
[Full Changelog](https://github.com/Xruptor/BagSync/compare/v19.25...v19.26) [Previous Releases](https://github.com/Xruptor/BagSync/releases)

- DB Check Fix  
    * Removed an old DB refresh check that was used to check for older database formats.  It was causing issues with those whom were using symlinks to combine multiple accounts together.  (Fixed #324)  
