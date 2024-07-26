U1RegisterAddon("TinyInspect", {
    title = LOCALE_zhCN and "装备装等观察" or "裝備裝等觀察",
    defaultEnable = 1,
    load = 'LOGIN',
    tags = { TAG_ITEM },
    icon = [[Interface\Icons\Item_spellclothbolt]],
    desc = LOCALE_zhCN and "国人作者loudsoul的Tiny系列插件之TinyInspect，在你能想到的所有地方，显示物品装等信息，" or "國人作者loudsoul的Tiny系列插件之TinyInspect，在你能想到的所有地方，顯示物品裝等訊息，",
    nopic = 1,
    toggle = function(name, info, enable, justload) end,

    {
        text = LOCALE_zhCN and "配置选项" or "配置選項",
        callback = function(cfg, v, loading) SlashCmdList.TinyInspect("") end,
    },
    {
        text = LOCALE_zhCN and "团队面板" or "團隊面板",
        callback = function(cfg, v, loading) SlashCmdList.TinyInspect("raid") end,
    },
    {
        text = LOCALE_zhCN and "恢复默认设置" or "恢復預設設置",
        confirm = LOCALE_zhCN and "即将清除此插件的相关设置，会自动重载，请确定" or "即將清除此插件的相關設置，會自動重載，請確定",
        callback = function(cfg, v, loading) TinyInspectDB = nil ReloadUI() end,
    },

});