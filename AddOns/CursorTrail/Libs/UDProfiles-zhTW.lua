if GetLocale() ~= "zhTW" then return end
local kAddonFolderName, private = ...
local L = private.L
--=============================================================================

-- TODO: Copy strings from UDProfiles-enUS.lua, and translate them.

--''''''''''''''
-- Menu Strings
--''''''''''''''
L.mNewProfile = "新設定檔"
L.mLoad = "載入..."
L.mDefaults = "預設值..."
L.mSave = "儲存"
L.mSaveAs = "另存新檔"
L.mRename = "重新命名"
L.mCopyTo = "複製到..."
L.mCopyFrom = "複製自..."
L.mDelete = "刪除..."
----L.mBackups = "備份..."
L.mBackup     = "備份"
L.mRestore     = "還原..."
L.mExport = "匯出..."
L.mImport = "匯入"
L.mOptions = "設定檔選項"

--''''''''''''''
-- Misc Strings
--''''''''''''''
L.HeadingPadChar = ":"  -- e.g. ":::::::::: SAVE PROFILE ::::::::::"
L.UnsavedMarker = " *"  -- Characters added to end of a profile name to indicate its not saved yet.
L.EmptyNameText = "設定檔名稱"
L.Menu = " 選單"  -- (Leading space helps center this word in the control better.)
L.NoUndo = "否" .." / 復原"
L.CreateProfile = "建立設定檔"
L.DeleteProfile = "刪除設定檔"
L.NewBackup  = "+ 新增備份 +"
L.BackupProfiles = "備份設定檔"
L.RestoreBackup = "還原備份"
L.DeleteBackup = "刪除備份"
L.BackupName_Prefix = "Backup_"
L.BackupName_Login = "@登入"  -- Must start with "@".
L.BackupName_Orig = "@原始"    -- Must start with "@".
L.Profiles = "設定檔"  -- Upper-case!
L.profiles = "設定檔"  -- Lower-case!
L.current_values = "目前值"  -- Lower-case!
L.loaded = "已載入"  -- A lower-case word meaning the profile is loaded.
L.modified = "已修改"  -- A lower-case word meaning the profile is modified.
L.NewProfileDesc = "使用預設值建立新的設定檔。"
L.BackupDesc = "建立目前設定檔的新備份。"
----L.BackupsDesc = "Create/restore backups of current profiles."
L.RestoreDesc = "使用備份的設定檔取代目前的設定檔。"

L.Disabled_NoProfiles = "沒有設定檔。"
L.Disabled_NoBackups = "沒有備份。"
L.Disabled_NameIsBlank = "因為設定檔名稱空白，所以停用。"
L.Disabled_Unsaved = "因為設定檔未儲存，所以停用。"
L.Disabled_NotImplemented = "尚未實裝。"

L.SaveProfileFirst = "請先儲存設定檔！"
L.MousewheelSwitchesProfiles = "提示：滑鼠滾輪可以切換設定檔。"
----L.RightclickToSaveProfile = "TIP: Right-click to save profile."
L.SaveProfileHelp = '右鍵點擊設定檔名稱，或\n從 '.. L.Menu ..' 選擇 "'.. L.mSaveAs ..'"。'
L.ProfileNotSaved = "*設定檔未儲存。"
L.TopOfList = "位於列表頂端。"
L.BottomOfList = "位於列表底部。"
L.NewProfileName = "新設定檔名稱："
L.SaveProfileAs = '將設定檔 "%s" 儲存為：'
L.RenameProfileTo = '將設定檔 "%s" 重新命名為：'
L.NewBackupName = "新備份名稱："
L.AreYouSure = "是否確定？"
L.SaveChangesFirst = '請先儲存對 "%s" 的變更？'
L.SaveBeforeLoading = '儲存 "%s" 後再載入 "%s"？'
L.ResetOptionsDesc = "重置設定檔選項"
L.ResetOptionsSucceeded = "設定檔選項已重置。"

L.ConfirmOverwriteProfile = '設定檔 "%s" 已經存在！\n\n它將被目前的設定檔覆蓋。'
L.ConfirmDefaults = '設定檔 "%s" 已經存在！\n\n它將被預設值覆蓋。'
L.ConfirmBackup = '備份 "%s" 已經存在！\n\n如果你繼續，它將被覆蓋。'
L.ConfirmRestore = '還原 "%s" ？\n\n如果你繼續，目前的設定檔將被覆蓋。'
L.ConfirmCopyTo = '設定檔 "%s" 將被 "%s" 的值覆蓋。'
L.ConfirmCopyFrom = '設定檔 "%s" 將被複製到 "%s"。'
L.ConfirmKeepChanges = "保留對設定檔的變更嗎？"
L.ConfirmDeleteProfile = L.AreYouSure ..'\n\n設定檔 "%s" 將被刪除。'
L.ConfirmDeleteBackup = L.AreYouSure ..'\n\n"%s"\n如果你繼續，將被永久刪除！'
L.ConfirmResetOptions = "將設定檔選項重置為原始值？"

L.ProfilesVersion = "設定檔版本："
L.ControlsVersion = "控制版本："
L.InvalidProfileName = "無效的設定檔名稱。"
L.NameExceedsMaxLetters = "名稱超過 %d 個字元。"
L.CanceledProfileChanges = "取消設定檔變更。"

L.Title_Load = "載入"
L.Title_ProfilesChanged = "設定檔已變更"
L.Title_BackupProfiles = "備份設定檔"
L.Title_RestoreProfiles = "還原設定檔"
L.Title_Warning = "警告"

L.DefaultLoaded = '已載入預設值："%s"'  -- %s = name of a default
L.DefaultsLoaded = "已載入預設值。"
L.Created = '已建立 "%s"。'
L.FailedToCreate = '建立 "%s" 失敗。'
L.Saved = '已儲存 "%s"。'
L.FailedToSave = '儲存 "%s" 失敗。'
L.Loaded = '已載入 "%s"。'
L.FailedToLoad = '載入 "%s" 失敗。'
L.Deleted = '已刪除 "%s"。'
L.FailedToDelete = '刪除 "%s" 失敗。'
L.RenamedOldToNew = '已將 "%s" 重新命名為 "%s"。'  -- %s %s = old name, new name
L.FailedToRename = '重新命名 "%s" 失敗。'
L.CopiedSrcToDest = '已將 "%s" 複製到 "%s"。'  -- %s %s = source name, destination name
L.CreatedBackup = '已建立備份 "%s"。'
L.FailedToCreateBackup = "備份設定檔失敗！"
L.Restored = '已還原備份 "%s"。'
L.FailedToRestore = '還原 "%s" 失敗。'
L.DeletedBackup = '已刪除備份 "%s"。'
L.FailedToDeleteBackup = '刪除 "%s" 失敗。'
L.NotAllowToDelete = '不允許刪除 "%s"。'
L.UnsavedChangesBackupWarning = "備份成功，但目前的設定檔中未儲存的設定沒有被備份。"

L.OptionSaveOnOkay = "在點擊確定按鈕時儲存設定檔。"
L.OptionConfirmDelete = "刪除設定檔前詢問。"
L.OptionConfirmCopy = "複製設定檔前詢問。"

L.ProfilesHelp = [[
- 若要建立新的設定檔，請從選單中選擇「新增設定檔」。

- 活動設定檔名稱末尾的星號 (*) 表示顯示的值已修改，但這些變更尚未儲存到設定檔中。

- 可以通過從載入下拉選單中選擇相同的設定檔名稱來撤銷未儲存的設定檔變更。

- 若要儲存對活動設定檔的變更，請右鍵點擊設定檔名稱，或從選單中選擇「另存新檔」。

- 點擊確定按鈕會保留對顯示值的任何變更，但不會將這些變更儲存到活動設定檔中。這允許在嘗試不同的外掛設定時，仍然能夠在以後撤銷這些變更。
若要更改此行為，請從選單中選擇「設定檔選項」，然後開啟「在點擊確定按鈕時儲存設定檔」。

- 選擇預設設定檔時，除非先儲存，否則它的名稱不會顯示在載入下拉選單中。

- 將滑鼠指向設定檔名稱上時，可以使用滑鼠滾輪載入下一個/上一個設定檔。

- 當載入下拉選單打開時...
      在點擊名稱時按住 Shift 鍵，可以保持列表打開。
      在使用滑鼠滾輪時按住 Shift 鍵，可以載入下一個/上一個設定檔。

- [X] 按鈕旁邊的小箭頭會在載入和預設下拉選單中循環顯示設定檔。
]]

L.BackupsHelp = [[
- 你可以在選項視窗中通過從選單中選擇「備份」或「還原」來備份或還原所有設定檔。

- 總會有兩個備份可供還原：
      @原始 - 包含第一次使用設定檔介面時存在的設定檔。
      @登入 - 包含上次登入遊戲時存在的設定檔。

- 可以通過從選單中選擇「還原」，然後點擊要刪除的名稱右側的紅色「X」圖示來刪除舊的備份。
]]

--- End of File ---