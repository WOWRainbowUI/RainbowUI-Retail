# <DBM Mod> PvP

## [r159](https://github.com/DeadlyBossMods/DBM-PvP/tree/r159) (2023-12-15)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-PvP/compare/r158...r159) [Previous Releases](https://github.com/DeadlyBossMods/DBM-PvP/releases)

- Merge pull request #126 from emmericp/master  
    Ashenvale: Add cross-raid boss health syncing  
- Ashenvale: support health tracking of bosses across different raids  
    Observed boss health for Ashenvale is now synced to both RAID and YELL  
    chats. We also propagate syncs received from one to the other.  
    The idea is to use YELL chat to propagate from one raid to another.  
    Basically if a raid has a player at boss A and another player at boss B  
    then the player at B will know health of A and propagate to others at A.  
    These, in turn, will tell their raid who may have someone at boss C who  
    then tells others at boss C etc.  
    Syncs are limited to 10 messages per second total (across both chats),  
    and I'm attempting to do some basic prevention of duplicate sending, but  
    it's not super reliable because there are large latencies involved.  
    Also refactor the HealthTracker a bit, it's no longer some weird  
    singleton with some effectively global state. It's now an object which  
    you should only have a single instance of because of singleton-like  
    dependencies it has. Anyhow, this cleans up state management and  
    resolves some problems with multiple event registrations.  
- Add deploy script for VS Code  
    Basic idea is to set wow.base\_path in your global VS Code config to  
    whereever you have WoW installed and then bind this script to some  
    hotkey (I have it on Ctrl+D), it then copies the addon from whereever  
    you are developing it to all variants of the game.  
    Requires Linux, macOS, or WSL2 with rsync installed. It's a bit slow  
    on WSL, I guess someone who carse about windows should write a  
    PowerShell variant...  
- Merge pull request #125 from emmericp/master  
    Improve Ashenvale mod a bit  