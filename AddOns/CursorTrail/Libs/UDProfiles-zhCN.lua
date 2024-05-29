if GetLocale() ~= "zhCN" then return end
local kAddonFolderName, private = ...
local L = private.L
--=============================================================================

-- TODO: Copy strings from UDProfiles-enUS.lua, and translate them.

--''''''''''''''
-- 菜单字符串
--''''''''''''''
L.mNewProfile = "新建配置"
L.mLoad = "加载..."
L.mDefaults = "默认值..."
L.mSave = "保存"
L.mSaveAs = "另存为"
L.mRename = "重命名"
L.mCopyTo = "复制到..."
L.mCopyFrom = "复制自..."
L.mDelete = "删除..."
----L.mBackups = "Backups ..."
L.mBackup     = "备份"
L.mRestore     = "恢复..."
L.mExport = "导出..."
L.mImport = "导入"
L.mOptions = "配置选项"

--''''''''''''''
-- 杂项字符串
--''''''''''''''
L.HeadingPadChar = ":"  -- e.g. ":::::::::: SAVE PROFILE ::::::::::"
L.UnsavedMarker = " *"  -- Characters added to end of a profile name to indicate its not saved yet.
L.EmptyNameText = "配置名称"
L.Menu = " 菜单"  -- (Leading space helps center this word in the control better.)
L.NoUndo = "不" .." / 撤销"
L.CreateProfile = "创建配置"
L.DeleteProfile = "删除配置"
L.NewBackup  = "+ 新备份 +"
L.BackupProfiles = "备份配置"
L.RestoreBackup = "恢复备份"
L.DeleteBackup = "删除备份"
L.BackupName_Prefix = "Backup_"
L.BackupName_Login = "@登录"  -- Must start with "@".
L.BackupName_Orig = "@原始"    -- Must start with "@".
L.Profiles = "配置"  -- Upper-case!
L.profiles = "配置"  -- Lower-case!
L.current_values = "当前值"  -- Lower-case!
L.loaded = "已加载"  -- A lower-case word meaning the profile is loaded.
L.modified = "已修改"  -- A lower-case word meaning the profile is modified.
L.NewProfileDesc = "使用默认值创建一个新的配置。"
L.BackupDesc = "创建一个当前配置的新备份。"
----L.BackupsDesc = "Create/restore backups of current profiles."
L.RestoreDesc = "使用备份的配置替换当前的配置。"

L.Disabled_NoProfiles = "不存在配置。"
L.Disabled_NoBackups = "不存在备份。"
L.Disabled_NameIsBlank = "因为配置名称为空，所以禁用。"
L.Disabled_Unsaved = "因为配置未保存，所以禁用。"
L.Disabled_NotImplemented = "尚未实现。"

L.SaveProfileFirst = "请先保存配置！"
L.MousewheelSwitchesProfiles = "提示：鼠标滚轮可以切换配置。"
----L.RightclickToSaveProfile = "TIP: Right-click to save profile."
L.SaveProfileHelp = '右键点击配置名称，或\n从 '.. L.Menu ..' 选择 "'.. L.mSaveAs ..'"。'
L.ProfileNotSaved = "*配置未保存。"
L.TopOfList = "位于列表顶部。"
L.BottomOfList = "位于列表底部。"
L.NewProfileName = "新配置名称："
L.SaveProfileAs = '将配置 "%s" 保存为：'
L.RenameProfileTo = '将配置 "%s" 重命名为：'
L.NewBackupName = "新备份名称："
L.AreYouSure = "确定吗？"
L.SaveChangesFirst = '请先保存对 "%s" 的更改？'
L.SaveBeforeLoading = '保存 "%s" 后再加载 "%s"？'
L.ResetOptionsDesc = "重置配置选项"
L.ResetOptionsSucceeded = "配置选项已重置。"

L.ConfirmOverwriteProfile = '配置 "%s" 已存在！\n\n它将被当前值替换。'
L.ConfirmDefaults = '配置 "%s" 已存在！\n\n它将被默认值替换。'
L.ConfirmBackup = '备份 "%s" 已存在！\n\n如果你继续，它将被替换。'
L.ConfirmRestore = '恢复 "%s" ？\n\n如果你继续，当前的配置将被替换。'
L.ConfirmCopyTo = '配置 "%s" 将被 "%s" 的值覆盖。'
L.ConfirmCopyFrom = '配置 "%s" 将被复制到 "%s"。'
L.ConfirmKeepChanges = "保留对配置的更改吗？"
L.ConfirmDeleteProfile = L.AreYouSure ..'\n\n配置 "%s" 将被删除。'
L.ConfirmDeleteBackup = L.AreYouSure ..'\n\n"%s"\n如果你继续，将被永久删除！'
L.ConfirmResetOptions = "将配置选项重置为原始值？"

L.ProfilesVersion = "配置版本："
L.ControlsVersion = "控制版本："
L.InvalidProfileName = "无效的配置名称。"
L.NameExceedsMaxLetters = "名称超过 %d 个字符。"
L.CanceledProfileChanges = "取消配置更改。"

L.Title_Load = "加载"
L.Title_ProfilesChanged = "配置已更改"
L.Title_BackupProfiles = "备份配置"
L.Title_RestoreProfiles = "恢复配置"
L.Title_Warning = "警告"

L.DefaultLoaded = '已加载默认值："%s"'  -- %s = name of a default
L.DefaultsLoaded = "已加载默认值。"
L.Created = '已创建 "%s"。'
L.FailedToCreate = '创建 "%s" 失败。'
L.Saved = '已保存 "%s"。'
L.FailedToSave = '保存 "%s" 失败。'
L.Loaded = '已加载 "%s"。'
L.FailedToLoad = '加载 "%s" 失败。'
L.Deleted = '已删除 "%s"。'
L.FailedToDelete = '删除 "%s" 失败。'
L.RenamedOldToNew = '已将 "%s" 重命名为 "%s"。'  -- %s %s = old name, new name
L.FailedToRename = '重命名 "%s" 失败。'
L.CopiedSrcToDest = '已将 "%s" 复制到 "%s"。'  -- %s %s = source name, destination name
L.CreatedBackup = '已创建备份 "%s"。'
L.FailedToCreateBackup = "备份配置失败！"
L.Restored = '已恢复备份 "%s"。'
L.FailedToRestore = '恢复 "%s" 失败。'
L.DeletedBackup = '已删除备份 "%s"。'
L.FailedToDeleteBackup = '删除 "%s" 失败。'
L.NotAllowToDelete = '不允许删除 "%s"。'
L.UnsavedChangesBackupWarning = "备份成功，但当前配置中未保存的设置没有被备份。"

L.OptionSaveOnOkay = "在点击确定按钮时保存配置。"
L.OptionConfirmDelete = "删除配置前询问。"
L.OptionConfirmCopy = "复制配置前询问。"

L.ProfilesHelp = [[
- 若要创建新的配置，请从菜单中选择“新建配置”。

- 活动配置名称末尾的星号 (*) 表示显示的值已修改，但这些修改尚未保存到配置中。

- 可以通过从加载下拉列表中选择相同的配置名称来撤销未保存的配置更改。

- 若要保存对活动配置的更改，请右键点击配置名称，或从菜单中选择“另存为”。

- 点击确定按钮会保留对显示值的任何更改，但不会将这些更改保存到活动配置中。这允许在尝试不同的插件设置时，仍然能够在以后撤销这些更改。
若要更改此行为，请从菜单中选择“配置选项”，然后开启“在点击确定按钮时保存配置”。

- 选择默认配置时，除非先保存，否则它的名称不会显示在加载下拉列表中。

- 将鼠标悬停在配置名称上时，可以使用鼠标滚轮加载下一个/上一个配置。

- 当加载下拉列表打开时...
      在点击名称时按住 Shift 键，可以保持列表打开。
      在使用鼠标滚轮时按住 Shift 键，可以加载下一个/上一个配置。

- [X] 按钮旁边的小箭头会循环显示加载和默认下拉列表中的配置。
]]

L.BackupsHelp = [[
- 你可以在选项窗口中通过从菜单中选择“备份”或“恢复”来备份或恢复所有配置。

- 总会有两个备份可供恢复：
      @原始 - 包含第一次使用配置 UI 时存在的配置。
      @登录 - 包含上次登录游戏时存在的配置。

- 可以通过从菜单中选择“恢复”，然后点击要删除的名称右侧的红色“X”图标来删除旧的备份。
]]

--- End of File ---