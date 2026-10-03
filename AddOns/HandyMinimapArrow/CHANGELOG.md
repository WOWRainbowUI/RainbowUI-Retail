# Handy Minimap Arrow

## [v11](https://github.com/kemayo/wow-handyminimaparrow/tree/v11) (2026-08-09)
[Full Changelog](https://github.com/kemayo/wow-handyminimaparrow/compare/v10...v11) [Previous Releases](https://github.com/kemayo/wow-handyminimaparrow/releases)

- TOC for 12.1.0, 2.5.6  
- Shallow checkout could give the package a wrong version  
    The build checked out at the default depth of one commit, so git describe  
    had no tags to work from and the packager could not find the previous tag  
    to build its changelog from. Alpha builds from a branch push were the worst  
    affected. Updates the checkout action from v2 to v7, which was still  
    running a node version GitHub is retiring; nothing in that range affects a  
    push-triggered workflow. Pins the packager to v2 rather than master, so an  
    upstream change can no longer land in a release without warning; v2 is the  
    maintained major tag, so fixes within the v2 line still arrive.  
