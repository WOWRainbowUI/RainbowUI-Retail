local _, T = ...
-- See https://www.townlong-yak.com/addons/opie/localization

local C, z, V, K = GetLocale(), nil
V =
    C == "zhCN" and { -- 206/214 (96%)
      "%d 分钟前 (%s)", "%s取消", "%s在当前结果内搜索", z, "(默认)", "（输入图标名称或路径）", "添加环", "添加一个新功能", "使用后进阶显示", "所有%s角色",
      "%s的所有专精", "所有设置", "全部角色", "允许作为快捷动作", "Alt单击设置条件绑定", "动画过渡", "动画", "外观", "分配到所有专精", z,
      "在环中心", "按功能显示", "行为", "快捷键冲突", "快捷键：", "视角模拟摇杆", "取消", "改变行为", "修改将不被保存", "为此环绑定快捷键，或在OPie设置中启用%s选项。",
      "关闭环", "执行快速动作后关闭环", "颜色：", "战斗", "条件快捷键", "条件可见", "快捷键冲突：%s", "手柄方向输入：", "创建配置文件", "创建一份新的配置文件",
      "创建一个新的环", "创建新配置", "自定义环", "自定义功能", "修改已有环或创建你自己的环来个性化OPie。", "在下面自定义OPie快捷键。|cffa0a0a0灰色|r和|cffFA2800红色|r分别代表按键绑定有冲突和当前未激活。", "自定义OPie的外观和行为。右键点击选项框可将该项恢复为默认值。", "自定义绑定", "自定义环内按键绑定", "自定义选项",
      "自定义图标", "默认按键已禁用", "默认", "全局默认", "删除当前配置", "删除环", "删除功能", "召唤恶魔", "已停用", "显示跳跃功能",
      "显示为嵌套环", "显示为：", z, "什么也不做", "您想要将所有 %s 设置重置为其默认值，还是仅重置 %s 类别中的设置？", "默认嵌入其它环", "嵌入这个环中的功能", "空环", "放大选中的功能", "套装方案",
      z, "例如：%s.", z, "更多传送门", "野性", "炉石", "隐藏环", "隐藏姿势条", "隐藏此环", "图标：",
      "如果环已打开：", "如果这个宏条件的返回值为%s，或者没有适用条件，此功能将被隐藏。", "导入%s个嵌套环", "导入快照", "单击上面的%s以导入快照。", "环内按键绑定", "未激活的环", "包含嵌套环", "输入功能动作说明：", "安装此外观的更新版本以选择它",
      "安装并启用 %s 以按文件名搜索。", "将指针捕捉到鼠标光标", "互动", "点击后依然显示", "左键点击应用绑定", "可用此环的角色：", "小地图追踪", "无鼠标", "下移环", "右移环",
      "移动模拟摇杆", "嵌套环：%s", "嵌套环", "创建新环", "新配置名称：", "没有%s专精", "空", "未绑定", z, "未自定义",
      "所选外观不支持此功能。", "OPie环", "OPie环：%s", "OPie环", "左键点击：", "右键点击：", "按下环按键绑定：", "放开按键绑定：", "仅%s", "打开嵌套环",
      "在鼠标位置打开环", "在屏幕中心打开环", "选项：", "旋转消失", "覆盖图标", "覆盖标签：", "独立角色的环旋转", "预设环功能按键", "宠物", "变形术",
      "传送门与传送", "预选快捷功能", "按%s键保存。", "按%s搜索", "环功能置顶", "配置", "在你切换专精后相应配置文件会自动激活。", "配置文件保存设置与环快捷键。", "任务物品", "快速",
      "环中央使用快捷功能", "鼠标悬停时的快速动作。", "快速重复动作：", "使用后随机切换", "显示时随机", "放松", "记住最近的选择", "重新打开环", "显示时重置", "重启魔兽世界。如果此信息持续存在，删除后重装OPie。",
      "重置为默认设置", "恢复默认设置", "回复已删除的环", "还原...", "右键点击解除绑定", "环快捷键", "环名称：", "环尺寸", z, "环：%s",
      "旋转：", "旋转嵌套环（下）", "旋转嵌套环（上）", "搜索", "选择 %s 互动方式以启用此选项。", "选择要修改的环", "双击一个动作以加入到这个环", "选择的功能（关闭环）", "当前选择环（环保持打开）", z,
      "变形", "分享环", "按住 Shift 键单击查看环宏命令", "显示冷却数字", "显示充能数字", "显示功能标签", "显示给：", "显示鼠标提示", "模拟右键点击", "功能#%d",
      "快照：", "专精和旅行", "通过输入图标文件名、纹理路径、纹理图集名称或已知的技能名称来指定图标。", "获取该环的快照与他人分享。", "标记目标", "按键设置将根据该宏条件的返回值更新。", "用以下宏命令打开此环：", "这些设置", "此外观可能不支持全部的OPie功能。", "此快捷键正被另一个插件使用。",
      "此快捷键当前无法使用，因为它和另一个绑定冲突。", "专业技能", "按下绑定按键触发", "松开绑定按键触发", "明白了；继续编辑", "撤销变动", "未移动的光标", "光标未移动，或者在环中心", "需要更新", "使用默认环快捷键",
      "打开时使用第一个功能", "使用全局设定", "使用功能", "使用功能并关闭环", "工具", "虚拟鼠标光标", "可见条件：", "环展开时：", "世界标记", "由于内存不足，魔兽世界不能加载已保存的OPie变量。请尝试禁用其他插件。现在你所做的任何改动都不会被保存。",
      "您可以稍后取消或恢复到之前的设置。", "你可以使用扩展的宏条件；详情见%s。", "必须为此环启用%s选项，以使用快捷动作。", "默认",
    }
    or C == "zhTW" and { -- 214/214 (100%)
      "%d 分鐘前 (%s)", "%s取消", "%s在目前的結果內搜尋", "(所有套裝)", "(預設)", "(在此輸入圖示名稱或路徑)", "新增環", "加入一個新的功能", "使用後進階顯示", "所有 %s 角色",
      "所有 %s 專精", "所有設定", "所有角色", "設為快速動作", "Alt+左鍵 設定條件式綁定", "轉換動畫", "動畫", "外觀", "給所有專精使用", "在畫面上顯示浮動提示資訊的位置",
      "在環中心", "依據自身的功能顯示圖示", "行為", "按鍵已被使用", "按鍵綁定:", "移動視角用的類比搖桿", "取消", "更改動作", "不會儲存變更", "選擇這個環的按鍵綁定，或是在 OPie 選項中啟用 %s。",
      "關閉環", "執行快速動作後關閉環", "顏色:", "戰鬥", "條件式綁定", "條件式顯示", "按鍵已被使用: %s", "搖桿互動模式", "建立設定檔", "建立新的設定檔",
      "建立新的環", "建立新的設定檔", "自訂環", "自訂功能", "修改已有的環來自訂 OPie，或是建立新的環。", "自訂下列的 OPie 按鍵綁定。滑鼠指向綁定按鈕時會顯示額外的資訊和選項。", "自訂 OPie 的外觀和行為，右鍵點擊核取方塊可恢復為預設值。", "自訂按鍵綁定", "自訂環內按鍵綁定", "自訂選項",
      "自訂圖示", "預設的按鍵綁定已停用", "預設值", "所有環的預設值", "刪除目前的設定檔", "刪除環", "刪除功能", "惡魔", "已停用", "顯示跳躍功能",
      "顯示為環中環", "顯示為:", "不要顯示", "不做任何事", "是否要重置 %s 的所有設定，恢復成預設值，還是只要重置 %s 類別中的設定?", "預設嵌入其他環裡面", "這個環中啟用的功能", "空的環", "放大選取的圖示", "裝備設定:",
      "裝備管理員套裝", "範例: %s。", "額外動作", "額外傳送門", "野性", "爐石", "隱藏環", "隱藏姿勢形態列", "隱藏這個環", "圖示:",
      "如果環已經展開:", "如果巨集條件符合 %s，或是沒有適用的情況，便會隱藏這個功能。", "匯入 %s 個環中環", "匯入字串", "按下 %s 可匯入字串。", "環內按鍵綁定", "非作用中的環", "包含環中環", "輸入功能動作內容:", "請安裝此外觀的更新版本後再選擇它。",
      "安裝並啟用 %s 以便使用檔案名稱來搜尋。", "即時指向旋轉", "互動", "使用後保持展開狀態", "點一下左鍵來設定按鍵綁定", "此環可用於:", "小地圖追蹤", "不用滑鼠", "環向下偏移", "環向右偏移",
      "移動類比搖桿", "環中環: %s", "環中環", "建立新的環...", "新的設定檔名稱:", "沒有 %s 專精", "無", "未綁定", "不可針對每個環進行配置。", "未自訂",
      "不支援所選的外觀。", "OPie 環", "OPie 環: %s", "OPie 環", "左鍵點擊:", "右鍵點擊:", "按下環按鍵綁定:", "放開環按鍵綁定:", "只供 %s", "展開環中環",
      "在滑鼠位置顯示環", "在畫面中央顯示環", "選項:", "旋轉消失", "取代圖示", "取代標籤:", "每個角色的環旋轉", "每個功能各自綁定快速鍵", "寵物", "變形術",
      "傳送門和傳送術", "預選一個功能做為快速動作", "按 %s 儲存。", "按 %s 搜尋", "顯示在最前方", "設定檔", "切換專精時會自動啟用設定檔。", "設定檔儲存選項和環按鍵綁定。", "任務物品", "快速",
      "環中心的快速功能", "滑鼠停留時的快速動作", "快速重複動作:", "使用後隨機顯示", "隨機顯示", "輕鬆", "記憶上次旋轉", "重新展開環", "重置顯示", "重新啟動魔獸世界。如果持續出現此訊息，請刪除並重新安裝 OPie。",
      "重置為預設值", "恢復為預設值", "恢復已刪除的環", "還原...", "點右鍵取消綁定", "環按鍵綁定", "環的名稱:", "環縮放大小", "環旁邊", "環: %s",
      "環旋轉:", "捲動環中環 (往下)", "捲動環中環 (往上)", "搜尋", "選擇 %s 互動方式以啟用此選項。", "選擇要更改的環", "在技能上面點兩下便可加入環。", "選擇的功能 (關閉環)", "選擇的功能 (保持環展開)", "套裝名稱過濾:",
      "變形", "分享環", "Shift+左鍵 檢視環的巨集指令", "顯示冷卻時間數字", "顯示充能數字", "顯示功能文字", "顯示給:", "顯示浮動提示資訊", "模擬右鍵點擊", "功能 #%d",
      "字串:", "天賦專精和旅行", "輸入圖示檔案名稱、材質路徑、圖集名稱或已知的技能名稱來指定圖示。", "將環的設定字串分享給其他人用。", "目標標記圖示", "將會依據巨集條件更新按鍵綁定。", "使用下列的巨集指令來展開這個環:", "這些設定", "這個外觀可能不支援 OPie 的全部功能。", "其他插件正在使用這個按鍵綁定。",
      "無法使用這個按鍵綁定，因為已用於其他地方。", "專業技能", "按下按鍵綁定時觸發", "放開按鍵綁定時觸發", "瞭解; 仍要繼續編輯", "復原變更", "游標未移動", "游標未移動，或在環中心", "需要更新", "使用預設的環按鍵綁定",
      "展開時使用第一個功能", "使用整體設定", "使用功能", "使用功能後關閉環", "工具", "虛擬滑鼠游標", "顯示條件:", "環展開時:", "世界標記圖示", "記憶體不足! 魔獸世界無法載入 OPie 已儲存的變數，請停用其它插件。\n\n現在做的任何變更都不會被儲存。",
      "稍後可以取消或還原成先前的設定。", "可以使用擴充的巨集條件式；詳細內容請看 %s。", "要使用快速功能，必須在 OPie 選項中替這個環啟用 %s 互動。", "預設", "快捷列-環形",
    } or nil

K = V and {
      "%d |4minute:minutes; ago (%s)", "%s to cancel", "%s to search within current results", "(All sets)", "(default)", "(enter an icon name or path here)", "Add Ring", "Add a new slice", "Advance rotation after use", "All %s characters",
      "All %s specializations", "All Settings", "All characters", "Allow as quick action", "Alt click to set conditional binding", "Animate transitions", "Animation", "Appearance", "Assign to all specializations", "At HUD Tooltip position",
      "At ring center", "Based on slice action", "Behavior", "Binding conflict", "Binding:", "Camera analog stick", "Cancel", "Change action", "Changes will not be saved", "Choose a binding for this ring, or enable the %s option in OPie options.",
      "Close ring", "Close ring after quick action", "Color:", "Combat", "Conditional Bindings", "Conditional Visibility", "Conflicts with: %s", "Controller directional input:", "Create Profile", "Create a New Profile",
      "Create a New Ring", "Create a new profile", "Custom Rings", "Custom slice", "Customize OPie by modifying existing rings, or creating your own.", "Customize OPie key bindings below. Hover over a binding button for additional information and options.", "Customize OPie's appearance and behavior. Right clicking a checkbox restores it to its default state.", "Customize bindings", "Customize in-ring bindings", "Customize options",
      "Customized icon", "Default binding disabled", "Defaults", "Defaults for all rings", "Delete current profile", "Delete ring", "Delete slice", "Demons", "Disabled", "Display a jump slice",
      "Display as a nested ring", "Display as:", "Do not show", "Do nothing", "Do you want to reset all %s settings to their defaults, or only the settings in the %s category?", "Embed into other rings by default", "Embed slices in this ring", "Empty ring", "Enlarge selected slice", "Equip set:",
      "Equipment Sets", "Example: %s.", "Extra Actions", "Extra Portals", "Feral", "Hearthstones", "Hidden rings", "Hide stance bar", "Hide this ring", "Icon:",
      "If the ring is already open:", "If this macro conditional evaluates to %s, or if none of its clauses apply, this slice will be hidden.", "Import %s |4nested ring:nested rings;", "Import snapshot", "Import snapshots by clicking %s above.", "In-Ring Bindings", "Inactive rings", "Include nested rings", "Input a slice action specification:", "Install an updated version of this appearance to select it.",
      "Install and enable %s to search by file name.", "Instant pointer rotation", "Interaction", "Leave open after use", "Left click to assign binding", "Make this ring available to:", "Minimap Tracking", "Mouse-less", "Move rings down", "Move rings right",
      "Movement analog stick", "Nested ring: %s", "Nested rings", "New Ring...", "New profile name:", "No %s specializations", "None", "Not bound", "Not configurable per-ring.", "Not customized",
      "Not supported by selected appearance.", "OPie Ring", "OPie ring: %s", "OPie rings", "On left click:", "On right click:", "On ring binding press:", "On ring binding release:", "Only %s", "Open nested ring",
      "Open ring at mouse", "Open ring at screen center", "Options:", "Outward spiral on hide", "Override Icon", "Override label:", "Per-character ring rotations", "Per-slice bindings", "Pets", "Polymorphs",
      "Portals and Teleports", "Pre-select a quick action slice", "Press %s to save.", "Press %s to search", "Prevent other UI interactions", "Profile", "Profiles activate automatically when you switch character specializations.", "Profiles save options and ring bindings.", "Quest Items", "Quick",
      "Quick action at ring center", "Quick action if mouse remains still", "Quick action repeat trigger:", "Randomize rotation after use", "Randomize rotation on display", "Relaxed", "Remember last rotation", "Reopen ring", "Reset rotation on display", "Restart World of Warcraft. If this message continues to appear, delete and re-install OPie.",
      "Restore default", "Restore default settings", "Restore deleted ring", "Revert...", "Right click to unbind", "Ring Bindings", "Ring name:", "Ring scale", "Ring-side", "Ring: %s",
      "Rotation:", "Scroll nested ring (down)", "Scroll nested ring (up)", "Search", "Select a %s interaction to enable this option.", "Select a ring to modify", "Select an action by double clicking.", "Selected slice (close ring)", "Selected slice (keep ring open)", "Set name filter:",
      "Shapeshifts", "Share ring", "Shift click to view ring macro command", "Show cooldown numbers", "Show recharge numbers", "Show slice labels", "Show this slice for:", "Show tooltips:", "Simulate a right-click", "Slice #%d",
      "Snapshot:", "Specializations and Travel", "Specify an icon by entering an icon file name, texture path, atlas name, or a known ability name.", "Take a snapshot of this ring to share it with others.", "Target Markers", "The binding will update to reflect the value of this macro conditional.", "The following macro command opens this ring:", "These Settings", "This appearance may not support all OPie features.", "This binding is currently used by another addon.",
      "This binding is not currently active because it conflicts with another.", "Trade Skills", "Trigger on binding press", "Trigger on binding release", "Understood; edit anyway", "Undo changes", "Unmoved cursor", "Unmoved cursor, or at ring center", "Update required", "Use default ring bindings",
      "Use first slice when opened", "Use global setting", "Use slice", "Use slice and close ring", "Utility", "Virtual mouse cursor", "Visibility conditional:", "While a ring is open:", "World Markers", "World of Warcraft could not load OPie's saved variables due to a lack of memory. Try disabling other addons.\n\nAny changes you make now will not be saved.",
      "You can cancel or revert to previous settings later.", "You may use extended macro conditionals; see %s for details.", "You must enable a %s interaction for this ring in OPie options to use quick actions.", "default", "OPie",
}

local L = K and {}
for i=1,K and #K or 0 do
	L[K[i]] = V[i]
end

T.L = L or nil