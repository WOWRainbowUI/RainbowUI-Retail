local _, T = ...
-- See https://www.townlong-yak.com/addons/opie/localization

local C, z, V, K = GetLocale(), nil
V =
    C == "zhCN" and { -- 234/234 (100%)
      "%d 分钟前（%s）", "%s 取消", "%s 在当前分类中搜索", "（所有套装）", "(默认)", "（输入图标名称或路径）", "添加圆环", "添加新扇格", "使用后切换下一个", "所有%s角色",
      "所有%s专精", "全部设置", "所有角色", "允许作为快捷动作", "按 Alt 点击，设置条件快捷键", "加载 OPie 时出错。", "启用圆环过渡动画", "动画效果", "你现在所做的任何更改都不会被保存。", "指示外观",
      "分配至所有专精", "HUD 提示框处", "指针在圆环中心", "默认动作图标", "显示行为", "快捷键冲突", "快捷键：", "视角模拟摇杆", "取消", "更改动作",
      "标有%s的更新，由用户提交的反馈启发。", "更改将不会保存", "设置此圆环快捷键，或在OPie显示行为中启用[%s]选项。", "关闭圆环", "仅在快捷动作后关闭圆环", "扇格颜色：", "战斗相关", "条件快捷键", "冲突项：%s", "手柄方向输入：",
      "复制上方显示的网址并在浏览器中打开。", "创建配置文件", "新建配置文件", "新建圆环", "创建新配置", "自定义圆环", "自定义扇格", "修改现有圆环或创建新圆环来打造个性化 OPie。", "自定义 OPie 快捷键。鼠标悬停在快捷键按钮上查看更多信息和选项。", "自定义OPie圆环及环内扇格的快捷键。",
      "自定义 OPie 圆环的界面及操作。", "自定义 OPie 圆环的界面及操作。右键点击勾选框将该项设为默认圆环设置。", "自定义快捷键", "自定义扇格快捷键", "当前圆环设置", "自定义图标", "默认按键已禁用", "默认", "默认圆环设置", "删除当前配置",
      "删除圆环", "删除扇格", "召唤恶魔", "已禁用", "跳转扇格", "子圆环扇格", "嵌套显示方式：", "不显示", "什么也不做", "是否要将所有%s设置恢复为默认设值，还是仅重置%s页面中的设置？",
      "编辑现有圆环，或创建你的自定义OPie圆环。", "嵌套时默认平铺嵌入其他圆环", "平铺嵌入扇格", "空圆环", "放大选中的扇格", "套装方案：", "装备方案", "示例：%s", "OPie内置动作", "更多传送门",
      "野性（德鲁伊）", "其他选项请使用{显示条件}设置。", "炉石相关", "隐藏的圆环", "隐藏姿态条", "隐藏此圆环", "圆环存在时隐藏事件等弹出通知", "图标：", "如果OPie运行出现异常（或你希望它有所改变），请通过以下链接提交问题：", "若圆环处已存在：",
      "如果这个宏条件的返回值为%s，或者没有适用条件，此功能将被隐藏。", "导入%s个嵌套圆环", "导入快照", "点击上方的%s导入快照。", "扇格快捷键", "未激活的圆环", "包含嵌套圆环", "输入扇格动作规格：", "需安装此外观的更新版本方可选择。", "安装并启用 %s 以按文件名搜索。",
      "禁用环指针旋转动画", "触发模式", "使用后保持打开", "左键分配快捷键，右键解除", "圆环可用于：", "小地图追踪", "键盘模式", "向下移动圆环", "向右移动圆环", "移动模拟摇杆",
      "嵌套子圆环：%s", "悬停显示嵌套子圆环", "新建圆环...", "新配置名称：", "无%s专精", "无", "未设置", "不能对单个圆环进行配置。", "默认方式", "所选外观不支持此功能。",
      "OPie圆环", "OPie圆环：%s", "OPie圆环", "左键点击时：", "右键点击时：", "按下圆环快捷键时：", "松开圆环快捷键时：", "仅%s", "打开嵌套圆环", "在鼠标位置打开圆环",
      "在屏幕中心打开圆环", "常规设置", "其他选项：", "隐藏时向外螺旋消失", "覆盖图标", "自定义标签：", "秘境团本传送", "角色独立的嵌套子圆环转动角度", "显示扇格快捷键", "使用扇格快捷键时：",
      "宠物", "变形术（法师）", "传送门与传送", "自动选用快捷动作", "按%s保存", "按%s搜索", "阻止其他UI交互", "配置文件", "切换角色专精时，配置文件将自动激活。", "配置文件会保存选项和圆环快捷键设置。",
      "任务物品", "快速模式", "指针在圆环中心触发快捷动作", "指针保持静止时触发快捷动作", "快捷动作重复触发条件：", "使用后随机切换", "显示时随机选择", "宽松模式", "记住上次的选择", "重新打开圆环",
      "反馈问题", "显示时重置选择", "重启游戏。若此提示持续出现，请删除并重新安装OPie。", "恢复默认", "恢复默认设置", "恢复已删除的圆环", "恢复备份", "左键点击再右键点击，还原默认键位", "圆环快捷键", "圆环名称：",
      "圆环缩放比例", "圆环边", "圆环：%s", "顺时针转动：", "顺时针转动嵌套圆环", "逆时针转动嵌套圆环", "搜索", "开启%s后，此选项可用。", "选择要修改的圆环", "双击图标添加动作。",
      "以下是 OPie 近期更新的重点内容。完整更新日志请访问 %s", "选中的扇格（关闭圆环）", "选中的扇格（保持圆环打开）", "套装名称过滤器：", "变形（德鲁伊）", "分享圆环", "按 Shift 点击，查看圆环宏命令", "显示冷却时间", "显示充能时间", "显示自定义标签",
      "此扇格显示于：", "提示框位置：", "模拟右键点击", "扇格#%d", "扇格快捷键与%s冲突。", "快照：", "专精与旅行", "输入图标文件名、纹理路径、图集名称或已知技能名称来指定图标。", "为此圆环创建快照以与他人分享。", "目标标记",
      "若可用，则传送至对应的秘境或团本。", "快捷键将根据此宏表达式的值更新。", "以下宏命令可打开此圆环：", "当前页面设置", "此外观可能不支持OPie的全部功能。", "此快捷键已被其他插件占用。", "此快捷键当前未激活，因与其他快捷键冲突。", "专业技能", "翻译 OPie", "按下快捷键时触发",
      "松开快捷键时触发", "已知晓；仍要编辑", "撤销更改", "指针未移动", "指针未移动或在圆环中心", "需要更新", "使用默认环快捷键", "自动使用（且隐藏）第一个扇格", "使用全局设置", "使用扇格",
      "使用扇格并关闭圆环", "实用功能", "虚拟鼠标指针", "显示条件：", "更新日志", "圆环存在时：", "世界标记", "内存不足，无法加载OPie的已保存数据。请尝试禁用其他插件。", "稍后你可取消或恢复为之前的设置。", "你可以通过以下链接来帮助翻译 OPie：",
      "可使用扩展宏条件，详见 %s。", "在常规设置中开启%s后，此选项可用。", "你的角色当前无法使用此项。", "默认",
    }
    or C == "zhTW" and { -- 234/234 (100%)
      "%d 分鐘前 (%s)", "%s取消", "%s在目前的結果內搜尋", "(所有套裝)", "(預設)", "(在此輸入圖示名稱或路徑)", "新增環", "加入一個新的功能", "使用後進階顯示", "所有 %s 角色",
      "所有 %s 專精", "所有設定", "所有角色", "設為快速動作", "Alt+左鍵 設定條件式綁定", "載入 OPie 環形快捷列時發生錯誤。", "轉換動畫", "動畫", "現在做的任何變更都不會被儲存。", "外觀",
      "給所有專精使用", "在畫面上顯示浮動提示資訊的位置", "在環中心", "依據自身的功能顯示圖示", "行為", "按鍵已被使用", "按鍵綁定:", "移動視角用的類比搖桿", "取消", "更改動作",
      "標記為 %s 的變更是受到提交的回饋啟發而進行的。", "不會儲存變更", "選擇這個環的按鍵綁定，或是在 OPie 選項中啟用 %s。", "關閉環", "執行快速動作後關閉環", "顏色:", "戰鬥", "條件式綁定", "按鍵已被使用: %s", "搖桿互動模式",
      "複製上方顯示的網址，並使用網頁瀏覽器前往該網址。", "建立設定檔", "建立新的設定檔", "建立新的環", "建立新的設定檔", "自訂環", "自訂功能", "修改已有的環來自訂 OPie，或是建立新的環。", "自訂下列的 OPie 按鍵綁定。滑鼠指向綁定按鈕時會顯示額外的資訊和選項。", "自訂環形選單與環內按鍵綁定。",
      "自訂環形選單的外觀與行為。", "自訂 OPie 的外觀和行為，右鍵點擊核取方塊可恢復為預設值。", "自訂按鍵綁定", "自訂環內按鍵綁定", "自訂選項", "自訂圖示", "預設的按鍵綁定已停用", "預設值", "所有環的預設值", "刪除目前的設定檔",
      "刪除環", "刪除功能", "惡魔", "已停用", "顯示跳躍功能", "顯示為環中環", "顯示為:", "不要顯示", "不做任何事", "是否要重置 %s 的所有設定，恢復成預設值，還是只要重置 %s 類別中的設定?",
      "編輯現有的環形選單，或建立你自己的自訂環形選單。", "預設嵌入其他環裡面", "這個環中啟用的功能", "空的環", "放大選取的圖示", "裝備設定:", "裝備管理員套裝", "範例: %s。", "額外動作", "額外傳送門",
      "野性", "其他選項請使用{visibility conditional}。", "爐石", "隱藏環", "隱藏姿勢形態列", "隱藏這個環", "打開環形選單時隱藏提示訊息", "圖示:", "如果 OPie 中有任何功能未正常運作（或你希望它以不同方式運作），請造訪以下網址建立 issue：", "如果環已經展開:",
      "如果巨集條件符合 %s，或是沒有適用的情況，便會隱藏這個功能。", "匯入 %s 個環中環", "匯入字串", "按下 %s 可匯入字串。", "環內按鍵綁定", "非作用中的環", "包含環中環", "輸入功能動作內容:", "請安裝此外觀的更新版本後再選擇它。", "安裝並啟用 %s 以便使用檔案名稱來搜尋。",
      "即時指向旋轉", "互動", "使用後保持展開狀態", "點一下左鍵來設定按鍵綁定", "此環可用於:", "小地圖追蹤", "不用滑鼠", "環向下偏移", "環向右偏移", "移動類比搖桿",
      "環中環: %s", "環中環", "建立新的環...", "新的設定檔名稱:", "沒有 %s 專精", "無", "未綁定", "不可針對每個環進行配置。", "未自訂", "不支援所選的外觀。",
      "OPie 環", "OPie 環: %s", "OPie 環", "左鍵點擊:", "右鍵點擊:", "按下環按鍵綁定:", "放開環按鍵綁定:", "只供 %s", "展開環中環", "在滑鼠位置顯示環",
      "在畫面中央顯示環", "選項", "選項:", "旋轉消失", "取代圖示", "取代標籤:", "老練英雄之路", "每個角色的環旋轉", "每個功能各自綁定快速鍵", "每個功能各自的按鍵綁定:",
      "寵物", "變形術", "傳送門和傳送術", "預選一個功能做為快速動作", "按 %s 儲存。", "按 %s 搜尋", "顯示在最前方", "設定檔", "切換專精時會自動啟用設定檔。", "設定檔儲存選項和環按鍵綁定。",
      "任務物品", "快速", "環中心的快速功能", "滑鼠停留時的快速動作", "快速重複動作:", "使用後隨機顯示", "隨機顯示", "輕鬆", "記憶上次旋轉", "重新展開環",
      "回報問題", "重置顯示", "重新啟動魔獸世界。如果持續出現此訊息，請刪除並重新安裝 OPie。", "重置為預設值", "恢復為預設值", "恢復已刪除的環", "還原...", "點右鍵取消綁定", "環按鍵綁定", "環的名稱:",
      "環縮放大小", "環旁邊", "環: %s", "環旋轉:", "捲動環中環 (往下)", "捲動環中環 (往上)", "搜尋", "選擇 %s 互動方式以啟用此選項。", "選擇要更改的環", "在技能上面點兩下便可加入環。",
      "OPie 最近更新的重點摘要如下，如需完整的更新紀錄，請造訪 %s", "選擇的功能 (關閉環)", "選擇的功能 (保持環展開)", "套裝名稱過濾:", "變形", "分享環", "Shift+左鍵 檢視環的巨集指令", "顯示冷卻時間數字", "顯示充能數字", "顯示功能文字",
      "顯示給:", "顯示浮動提示資訊", "模擬右鍵點擊", "功能 #%d", "功能的按鍵綁定和 %s 衝突。", "字串:", "天賦專精和旅行", "輸入圖示檔案名稱、材質路徑、圖集名稱或已知的技能名稱來指定圖示。", "將環的設定字串分享給其他人用。", "目標標記圖示",
      "傳送到你需要的地方... 若你知曉那條道路。", "將會依據巨集條件更新按鍵綁定。", "使用下列的巨集指令來展開這個環:", "這些設定", "這個外觀可能不支援 OPie 的全部功能。", "其他插件正在使用這個按鍵綁定。", "無法使用這個按鍵綁定，因為已用於其他地方。", "專業技能", "翻譯 OPie", "按下按鍵綁定時觸發",
      "放開按鍵綁定時觸發", "瞭解; 仍要繼續編輯", "復原變更", "游標未移動", "游標未移動，或在環中心", "需要更新", "使用預設的環按鍵綁定", "展開時使用第一個功能", "使用整體設定", "使用功能",
      "使用功能後關閉環", "工具", "虛擬滑鼠游標", "顯示條件:", "更新資訊", "環展開時:", "世界標記圖示", "記憶體不足! 魔獸世界無法載入 OPie 環形快捷列已儲存的變數，請停用其它插件。", "稍後可以取消或還原成先前的設定。", "你可以前往以下頁面協助翻譯 OPie：",
      "可以使用擴充的巨集條件式；詳細內容請看 %s。", "要使用快速功能，必須在 OPie 選項中替這個環啟用 %s 互動。", "你的角色目前無法使用此功能。", "預設", "快捷列-環形",
    } or nil

K = V and {
      "%d |4minute:minutes; ago (%s)", "%s to cancel", "%s to search within current results", "(All sets)", "(default)", "(enter an icon name or path here)", "Add Ring", "Add a new slice", "Advance rotation after use", "All %s characters",
      "All %s specializations", "All Settings", "All characters", "Allow as quick action", "Alt click to set conditional binding", "An error occurred while loading OPie.", "Animate transitions", "Animation", "Any changes you make now will not be saved.", "Appearance",
      "Assign to all specializations", "At HUD Tooltip position", "At ring center", "Based on slice action", "Behavior", "Binding conflict", "Binding:", "Camera analog stick", "Cancel", "Change action",
      "Changes marked with %s were inspired by submitted feedback.", "Changes will not be saved", "Choose a binding for this ring, or enable the %s option in OPie options.", "Close ring", "Close ring after quick action", "Color:", "Combat", "Conditional Bindings", "Conflicts with: %s", "Controller directional input:",
      "Copy the URL shown above and visit it using a web browser.", "Create Profile", "Create a New Profile", "Create a New Ring", "Create a new profile", "Custom Rings", "Custom slice", "Customize OPie by modifying existing rings, or creating your own.", "Customize OPie key bindings below. Hover over a binding button for additional information and options.", "Customize OPie ring and in-ring key bindings.",
      "Customize OPie's appearance and behavior.", "Customize OPie's appearance and behavior. Right clicking a checkbox restores it to its default state.", "Customize bindings", "Customize in-ring bindings", "Customize options", "Customized icon", "Default binding disabled", "Defaults", "Defaults for all rings", "Delete current profile",
      "Delete ring", "Delete slice", "Demons", "Disabled", "Display a jump slice", "Display as a nested ring", "Display as:", "Do not show", "Do nothing", "Do you want to reset all %s settings to their defaults, or only the settings in the %s category?",
      "Edit existing rings, or create your own custom OPie rings.", "Embed into other rings by default", "Embed slices in this ring", "Empty ring", "Enlarge selected slice", "Equip set:", "Equipment Sets", "Example: %s.", "Extra Actions", "Extra Portals",
      "Feral", "For other options, use a {visibility conditional}.", "Hearthstones", "Hidden rings", "Hide stance bar", "Hide this ring", "Hide toasts on ring open", "Icon:", "If something in OPie does not behave correctly (or if you'd like it to behave differently), create an issue by visiting:", "If the ring is already open:",
      "If this macro options expression evaluates to %s, or if none of its clauses apply, this slice will be hidden.", "Import %s |4nested ring:nested rings;", "Import snapshot", "Import snapshots by clicking %s above.", "In-Ring Bindings", "Inactive rings", "Include nested rings", "Input a slice action specification:", "Install an updated version of this appearance to select it.", "Install and enable %s to search by file name.",
      "Instant pointer rotation", "Interaction", "Leave open after use", "Left click to assign binding", "Make this ring available to:", "Minimap Tracking", "Mouse-less", "Move rings down", "Move rings right", "Movement analog stick",
      "Nested ring: %s", "Nested rings", "New Ring...", "New profile name:", "No %s specializations", "None", "Not bound", "Not configurable per-ring.", "Not customized", "Not supported by selected appearance.",
      "OPie Ring", "OPie ring: %s", "OPie rings", "On left click:", "On right click:", "On ring binding press:", "On ring binding release:", "Only %s", "Open nested ring", "Open ring at mouse",
      "Open ring at screen center", "Options", "Options:", "Outward spiral on hide", "Override Icon", "Override label:", "Path of the Seasoned Hero", "Per-character ring rotations", "Per-slice bindings", "Per-slice bindings:",
      "Pets", "Polymorphs", "Portals and Teleports", "Pre-select a quick action slice", "Press %s to save.", "Press %s to search", "Prevent other UI interactions", "Profile", "Profiles activate automatically when you switch character specializations.", "Profiles save options and ring bindings.",
      "Quest Items", "Quick", "Quick action at ring center", "Quick action if mouse remains still", "Quick action repeat trigger:", "Randomize rotation after use", "Randomize rotation on display", "Relaxed", "Remember last rotation", "Reopen ring",
      "Report an Issue", "Reset rotation on display", "Restart World of Warcraft. If this message continues to appear, delete and re-install OPie.", "Restore default", "Restore default settings", "Restore deleted ring", "Revert...", "Right click to unbind", "Ring Bindings", "Ring name:",
      "Ring scale", "Ring-side", "Ring: %s", "Rotation:", "Scroll nested ring (down)", "Scroll nested ring (up)", "Search", "Select a %s interaction to enable this option.", "Select a ring to modify", "Select an action by double clicking.",
      "Selected highlights from recent updates to OPie are summarized below. For full release notes, please visit %s", "Selected slice (close ring)", "Selected slice (keep ring open)", "Set name filter:", "Shapeshifts", "Share ring", "Shift click to view ring macro command", "Show cooldown numbers", "Show recharge numbers", "Show slice labels",
      "Show this slice for:", "Show tooltips:", "Simulate a right-click", "Slice #%d", "Slice binding conflicts with %s.", "Snapshot:", "Specializations and Travel", "Specify an icon by entering an icon file name, texture path, atlas name, or a known ability name.", "Take a snapshot of this ring to share it with others.", "Target Markers",
      "Teleport to where you are needed... if you know that Path.", "The binding will update to reflect the value of this macro options expression.", "The following macro command opens this ring:", "These Settings", "This appearance may not support all OPie features.", "This binding is currently used by another addon.", "This binding is not currently active because it conflicts with another.", "Trade Skills", "Translate OPie", "Trigger on binding press",
      "Trigger on binding release", "Understood; edit anyway", "Undo changes", "Unmoved cursor", "Unmoved cursor, or at ring center", "Update required", "Use default ring bindings", "Use first slice when opened", "Use global setting", "Use slice",
      "Use slice and close ring", "Utility", "Virtual mouse cursor", "Visibility conditional:", "What's New", "While a ring is open:", "World Markers", "World of Warcraft could not load OPie's saved variables due to a lack of memory. Try disabling other addons.", "You can cancel or revert to previous settings later.", "You can help translate OPie by visiting:",
      "You may use extended conditionals; see %s for details.", "You must enable a %s interaction for this ring in OPie options to use quick actions.", "Your character currently cannot use this.", "default", "OPie",
}

local L = K and {}
for i=1,K and #K or 0 do
	L[K[i]] = V[i]
end

T.L = L or nil