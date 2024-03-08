local _, T = ...
-- See https://www.townlong-yak.com/addons/opie/localization

local C, z, V, K = GetLocale(), nil
V =
    C == "zhCN" and { -- 145/180 (80%)
      z, "%s取消", "%s在当前结果内搜索", "(默认)", "（输入图标名称或路径）", "左键点击时激活", "添加环", "添加一个新功能", z, "所有%s角色",
      "%s的所有专精", "所有设置", "全部角色", "允许作为快捷动作", z, z, "动画", "外观", z, z,
      "按功能显示", "行为", "快捷键冲突", "快捷键：", z, "取消", "在鼠标位置打开环", z, "修改将不被保存", "为此环绑定快捷键，或在OPie设置中启用%s选项。",
      "颜色：", "战斗", "条件快捷键", "条件可见", "快捷键冲突：%s", z, "创建配置文件", "创建一份新的配置文件", "创建一个新的环", "创建新配置",
      "自定义环", z, "修改已有环或创建你自己的环来个性化OPie。", "在下面自定义OPie快捷键。|cffa0a0a0灰色|r和|cffFA2800红色|r分别代表按键绑定有冲突和当前未激活。", "自定义OPie的外观和行为。右键点击选项框可将该项恢复为默认值。", z, z, "自定义图标", "默认按键已禁用", "默认",
      "全局默认", "删除当前配置", "删除环", "删除功能", "召唤恶魔", z, "显示为嵌套环", "显示为：", z, "默认嵌入其它环",
      "嵌入这个环中的功能", "空环", "放大选中的功能", "套装方案", "例如：%s.", "更多传送门", "野性", "炉石", "隐藏环", "隐藏姿势条",
      "隐藏此环", "图标：", "如果这个宏条件的返回值为%s，或者没有适用条件，此功能将被隐藏。", z, "导入快照", "单击上面的%s以导入快照。", z, "未激活的环", z, z,
      z, "点击后依然显示", "环功能置顶", "可用此环的角色：", "小地图追踪", "下移环", "右移环", z, "嵌套环：%s", "嵌套环",
      "创建新环", "新配置名称：", "没有%s专精", z, "未绑定", "未自定义", z, "OPie环", "OPie环：%s", "OPie环",
      "仅%s", "打开嵌套环", "选项：", "旋转消失", "预设环功能按键", "宠物", "变形术", "传送门与传送", "预选快捷功能", "按%s键保存。",
      "按%s搜索", "配置", "在你切换专精后相应配置文件会自动激活。", "配置文件保存设置与环快捷键。", "任务物品", "环中央使用快捷功能", z, "使用后随机切换", "显示时随机", "记住最近的选择",
      "显示时重置", "重置为默认设置", "恢复默认设置", z, z, "环快捷键", "环名称：", "环尺寸", "环：%s", "旋转：",
      "旋转嵌套环（下）", "旋转嵌套环（上）", "滚轮敏感度", "搜索", "选择要修改的环", "双击一个动作以加入到这个环", "当前选择环（环保持打开）", "变形", "分享环", z,
      "显示冷却数字", "显示充能数字", z, "显示给：", "显示鼠标提示", "模拟右键点击", "功能#%d", z, "快照：", "专精和旅行",
      "获取该环的快照与他人分享。", "标记目标", "按键设置将根据该宏条件的返回值更新。", "用以下宏命令打开此环：", "这些设置", z, "此快捷键正被另一个插件使用。", "此快捷键当前无法使用，因为它和另一个绑定冲突。", "专业技能", "饰品",
      "明白了；继续编辑", "撤销变动", z, "使用默认环快捷键", "打开时使用第一个功能", "使用全局设定", "工具", z, "可见条件：", "术士战斗",
      "术士通用", "世界标记", "由于内存不足，魔兽世界不能加载已保存的OPie变量。请尝试禁用其他插件。现在你所做的任何改动都不会被保存。", z, "你可以使用扩展的宏条件；详情见%s。", "必须为此环启用%s选项以使用快捷动作。", "默认", "快捷键", "快捷列-环形",
    }
    or C == "zhTW" and { -- 177/180 (98%)
      "%d 分鐘前 (%s)", "%s取消", "%s在目前的結果內搜尋", "(預設)", "(在此輸入圖示名稱或路徑)", "左鍵點擊使用", "新增環", "加入一個新的功能", "使用後進階顯示", "所有 %s 角色",
      "所有 %s 專精", "所有設定", "所有角色", "設為快速動作", "Alt+左鍵 設定條件式綁定", "轉換動畫", "動畫", "外觀", "守護", "給所有專精使用",
      "依據自身的功能顯示圖示", "行為", "按鍵已被使用", "按鍵綁定:", "移動視角用的類比搖桿", "取消", "在滑鼠位置顯示環", "更改動作", "不會儲存變更", "選擇這個環的按鍵綁定，或是在 OPie 選項中啟用 %s。",
      "顏色:", "戰鬥", "條件式綁定", "條件式顯示", "按鍵已被使用: %s", "搖桿互動模式", "建立設定檔", "建立新的設定檔", "建立新的環", "建立新的設定檔",
      "自訂環", "自訂功能", "修改已有的環來自訂 OPie，或是建立新的環。", "自訂下列的 OPie 按鍵綁定。滑鼠指向綁定按鈕時會顯示額外的資訊和選項。", "自訂 OPie 的外觀和行為，右鍵點擊核取方塊可恢復為預設值。", "自訂按鍵綁定", "自訂選項", "自訂圖示", "預設的按鍵綁定已停用", "預設值",
      "所有環的預設值", "刪除目前的設定檔", "刪除環", "刪除功能", "惡魔", "顯示跳躍功能", "顯示為環中環", "顯示為:", "是否要重置 %s 的所有設定，恢復成預設值，還是只要重置 %s 類別中的設定?", "預設嵌入其他環裡面",
      "這個環中啟用的功能", "空的環", "放大選取的圖示", "裝備設定:", "範例: %s。", "額外傳送門", "野性", "爐石", "隱藏環", "隱藏姿勢形態列",
      "隱藏這個環", "圖示:", "如果巨集條件符合 %s，或是沒有適用的情況，便會隱藏這個功能。", "匯入 %s 個環中環", "匯入字串", "按下 %s 可匯入字串。", "環內按鍵綁定", "非作用中的環", "包含環中環", "輸入功能動作內容:",
      "請安裝此外觀的更新版本後再選擇它。", "使用後保持展開狀態", "顯示在最前方", "此環可用於:", "小地圖追蹤", "環向下偏移", "環向右偏移", "移動類比搖桿", "環中環: %s", "環中環",
      "建立新的環...", "新的設定檔名稱:", "沒有 %s 專精", "無", "未綁定", "未自訂", "不支援所選的外觀。", "OPie 環", "OPie 環: %s", "OPie 環",
      "只供 %s", "展開環中環", "選項:", "旋轉消失", "每個功能各自綁定快速鍵", "寵物", "變形術", "傳送門和傳送術", "預選一個功能做為快速動作", "按 %s 儲存。",
      "按 %s 搜尋", "設定檔", "切換專精時會自動啟用設定檔。", "設定檔儲存選項和環按鍵綁定。", "任務物品", "環中心的快速功能", "滑鼠停留時的快速動作", "使用後隨機顯示", "隨機顯示", "記憶上次旋轉",
      "重置顯示", "重置為預設值", "恢復為預設值", "還原...", "點右鍵取消綁定", "環按鍵綁定", "環的名稱:", "環縮放大小", "環: %s", "環旋轉:",
      "捲動環中環 (往下)", "捲動環中環 (往上)", "滾輪敏感度", "搜尋", "選擇要更改的環", "在技能上面點兩下便可加入環。", "選擇的功能 (保持環展開)", "變形", "分享環", "Shift+左鍵 檢視環的巨集指令",
      "顯示冷卻時間數字", "顯示充能數字", "顯示功能文字", "顯示給:", "顯示浮動提示資訊", "模擬右鍵點擊", "功能 #%d", "貼齊滑鼠游標", "字串:", "天賦專精和旅行",
      "將環的設定字串分享給其他人用。", "目標標記圖示", "將會依據巨集條件更新按鍵綁定。", "使用下列的巨集指令來展開這個環:", "這些設定", "這個外觀可能不支援 OPie 的全部功能。", "其他插件正在使用這個按鍵綁定。", "無法使用這個按鍵綁定，因為已用於其他地方。", "專業技能", "飾品",
      "瞭解; 仍要繼續編輯", "復原變更", "需要更新", "使用預設的環按鍵綁定", "展開時使用第一個功能", "使用整體設定", "工具", "虛擬滑鼠游標", "顯示條件:", "術士戰鬥",
      "術士一般", "世界標記圖示", "記憶體不足! 魔獸世界無法載入 OPie 已儲存的變數，請停用其它插件。\n\n現在做的任何變更都不會被儲存。", "稍後可以取消或還原成先前的設定。", "可以使用擴充的巨集條件式；詳細內容請看 %s。", "要使用快速功能，必須在 OPie 選項中替這個環啟用 %s。", "預設", "按鍵綁定", "快捷列-環形",
    } or nil

K = V and {
      "%d |4minute:minutes; ago (%s)", "%s to cancel", "%s to search within current results", "(default)", "(enter an icon name or path here)", "Activate on left click", "Add Ring", "Add a new slice", "Advance rotation after use", "All %s characters",
      "All %s specializations", "All Settings", "All characters", "Allow as quick action", "Alt click to set conditional binding", "Animate transitions", "Animation", "Appearance", "Aspects", "Assign to all specializations",
      "Based on slice action", "Behavior", "Binding conflict", "Binding:", "Camera analog stick", "Cancel", "Center rings at mouse", "Change action", "Changes will not be saved", "Choose a binding for this ring, or enable the %s option in OPie options.",
      "Color:", "Combat", "Conditional Bindings", "Conditional Visibility", "Conflicts with: %s", "Controller interaction mode", "Create Profile", "Create a New Profile", "Create a New Ring", "Create a new profile",
      "Custom Rings", "Custom slice", "Customize OPie by modifying existing rings, or creating your own.", "Customize OPie key bindings below. Hover over a binding button for additional information and options.", "Customize OPie's appearance and behavior. Right clicking a checkbox restores it to its default state.", "Customize bindings", "Customize options", "Customized icon", "Default binding disabled", "Defaults",
      "Defaults for all rings", "Delete current profile", "Delete ring", "Delete slice", "Demons", "Display a jump slice", "Display as a nested ring", "Display as:", "Do you want to reset all %s settings to their defaults, or only the settings in the %s category?", "Embed into other rings by default",
      "Embed slices in this ring", "Empty ring", "Enlarge selected slice", "Equip set:", "Example: %s.", "Extra Portals", "Feral", "Hearthstones", "Hidden rings", "Hide stance bar",
      "Hide this ring", "Icon:", "If this macro conditional evaluates to %s, or if none of its clauses apply, this slice will be hidden.", "Import %s |4nested ring:nested rings;", "Import snapshot", "Import snapshots by clicking %s above.", "In-Ring Bindings", "Inactive rings", "Include nested rings", "Input a slice action specification:",
      "Install an updated version of this appearance to select it.", "Leave open after use", "Make rings top-most", "Make this ring available to:", "Minimap Tracking", "Move rings down", "Move rings right", "Movement analog stick", "Nested ring: %s", "Nested rings",
      "New Ring...", "New profile name:", "No %s specializations", "None", "Not bound", "Not customized", "Not supported by selected appearance.", "OPie Ring", "OPie ring: %s", "OPie rings",
      "Only %s", "Open nested ring", "Options:", "Outward spiral on hide", "Per-slice bindings", "Pets", "Polymorphs", "Portals and Teleports", "Pre-select a quick action slice", "Press %s to save.",
      "Press %s to search", "Profile", "Profiles activate automatically when you switch character specializations.", "Profiles save options and ring bindings.", "Quest Items", "Quick action at ring center", "Quick action if mouse remains still", "Randomize rotation after use", "Randomize rotation on display", "Remember last rotation",
      "Reset rotation on display", "Restore default", "Restore default settings", "Revert...", "Right click to unbind", "Ring Bindings", "Ring name:", "Ring scale", "Ring: %s", "Rotation:",
      "Scroll nested ring (down)", "Scroll nested ring (up)", "Scroll wheel sensitivity", "Search", "Select a ring to modify", "Select an action by double clicking.", "Selected slice (keep ring open)", "Shapeshifts", "Share ring", "Shift click to view ring macro command",
      "Show cooldown numbers", "Show recharge numbers", "Show slice labels", "Show this slice for:", "Show tooltips", "Simulate a right-click", "Slice #%d", "Snap pointer to mouse cursor", "Snapshot:", "Specializations and Travel",
      "Take a snapshot of this ring to share it with others.", "Target Markers", "The binding will update to reflect the value of this macro conditional.", "The following macro command opens this ring:", "These Settings", "This appearance may not support all OPie features.", "This binding is currently used by another addon.", "This binding is not currently active because it conflicts with another.", "Trade Skills", "Trinkets",
      "Understood; edit anyway", "Undo changes", "Update required", "Use default ring bindings", "Use first slice when opened", "Use global setting", "Utility", "Virtual mouse cursor", "Visibility conditional:", "Warlock Combat",
      "Warlock General", "World Markers", "World of Warcraft could not load OPie's saved variables due to a lack of memory. Try disabling other addons.\n\nAny changes you make now will not be saved.", "You can cancel or revert to previous settings later.", "You may use extended macro conditionals; see %s for details.", "You must enable the %s option for this ring in OPie options to use quick actions.", "default", "Bindings", "OPie",
}

local L = K and {}
for i=1,K and #K or 0 do
	L[K[i]] = V[i]
end

T.L = L or nil