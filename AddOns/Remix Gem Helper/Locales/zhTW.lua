---@class RemixGemHelperPrivate
local Private = select(2, ...)
Private.Locales = Private.Locales or {}

Private.Locales["zhTW"] = {
    --isEditing = true,

    -- CloakTooltip.lua
    ["Rank"] = "等級",

    -- Core.lua
    ["Socketed"] = "已鑲嵌",
    ["In Bag"] = "背包",
    ["In Bag Item!"] = "背包物品!",
    ["Uncollected"] = "未收集",
    ["Scrappable Items"] = "可拆物品",
    ["NOTHING TO SCRAP"] = "沒有東西可以拆解",
    ["Resocket Gems"] = "重新鑲嵌寶石",
    ["Toggle the %s UI"] = "顯示/隱藏混搭寶石助手", -- %s is the Addon name and needs to be included!
    ["Search Gems"] = "搜尋寶石",
    ["Unowned"] = "未知的",
    ["Show Unowned Gems in the List."] = "在列表中顯示未知的寶石。",
    ["Primordial"] = "原始的",
    ["Show Primordial Gems in the List."] = "在列表中顯示原始的寶石。",
    ["Open, Use and Combine"] = "打開、使用和合成",
    ["NOTHING TO USE"] = "沒有東西可以使用",
    ["HelpText"] =
        "|A:newplayertutorial-icon-mouse-leftbutton:16:16|a 點擊此列表中的寶石以進行鑲嵌或卸除。\n" ..
        "'背包物品' 或 '已鑲嵌' 表示可以卸除它。\n" ..
        "'背包' 表示寶石在背包中，可以進行鑲嵌。\n\n" ..
        "將滑鼠指向 '已鑲嵌' 的寶石上時，會在角色面板中看到顯著標示的物品。\n" ..
        "可以使用下拉選單或頂部的搜尋欄來篩選您的列表。\n" ..
        "此插件還會在披風浮動提示資訊中加入當前披風的等級和屬性。\n" ..
        "在角色框架的右上角看到一個圖標，可以用於隱藏或顯示此框架。\n" ..
        "在寶石列表下方，有一些可點擊的按鈕，可以快速打開寶箱或合成寶石\n\n" ..
        "要關閉此框架，只需按住 Shift 並點擊它。\n祝您遊戲愉快！",

    -- UIElements.lua
    ["You don't have a valid free Slot for this Gem"] = "你沒有能夠鑲嵌這顆寶石的空插槽",
	
	-- 自行加入
	["Remix Gem Helper"] = "混搭寶石助手",
}
