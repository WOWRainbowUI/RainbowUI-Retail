local U1Name, U1 = ...
local L = U1.L

U1RegisterAddon(U1Name, {
    title = L["Ease Addon Controller"],
    tags = { "ENHANCEMENT" },
    desc = L["CFG.desc"],
    protected = 1,
    icon = "Interface\\AddOns\\"..U1Name.."\\Textures\\UI2-logo",

    nopic = 1,

    author = L["CFG.author"],

    {
        text = L["Ease Addon Controller Options"], type = "text",
        {
            var = "mmb", --no use but can't omit.
            text = L["Show Minimap Button"],
            default = 1,
            global = 1,
            getvalue = function() return not (U1DBG.minimap and U1DBG.minimap.hide) end,
            callback = function(cfg, v, loading)
                if not loading then
                    U1DBG.minimap.hide = not v
                    LibStub("LibDBIcon-1.0"):Refresh("U1MMB", U1DBG.minimap)
                end
            end
        },
        {
            var = "scale",
            text = L["Main Panel Scale"],
            default = 1,
            global = 1,
            type = "spin",
            range = { 0.5, 1.5, 0.1 },
            callback = function(cfg, v, loading)
                if UUI() then UUI():SetScale(v) end
            end,
        },
        {
            var = "alpha",
            text = L["Main Panel Opacity"],
            default = 1,
            global = 1,
            type = "spin",
            range = { 0.3, 1, 0.1 },
            callback = function(cfg, v, loading)
                if UUI() then UUI():SetAlpha(v) end
            end,
        },
        {
            var = "english",
            text = L["Show AddOns Folder Name"],
            default = false,
            global = 1,
            tip = L["Hint`Show addon folder name instead of the Title in the toc file."],
            getvalue = function() return U1GetShowOrigin() end,
            callback = function(cfg, v, loading)
                U1SetShowOrigin(v);
                if not loading then
                    U1SortAddons();
                    --UUI.Right.ADDON_SELECTED();
                end
            end,
        },
        {
            var = "sortmem",
            text = L["Sort AddOns by Memory Usage"],
            default = false,
            global = 1,
            tip = L["Hint`Sort the addons by their memory usages instead of name order."],
            -- 8.0 暫時修正
			-- getvalue = function() return not U1DB.sortByName end,
            getvalue = function() return false end,
            callback = function(cfg, v, loading)
                U1DB.sortByName = not v;
                if not loading then
                    UpdateAddOnMemoryUsage();
                    U1SortAddons()
                end
            end,
        },
    },
    {
        text = L["Panel Tile Settings"], type = "text",
        {
            text = L["Reset to Default"],
            confirm = L["Are you sure to reset these settings, and start an UI reload?"],
            callback = function()
                U1DBG.configs[U1Name:lower().."/tile_width"] = nil
                U1DBG.configs[U1Name:lower().."/tile_height"] = nil
                U1DBG.configs[U1Name:lower().."/tile_margin"] = nil
                ReloadUI()
            end
        },
        {
            var = "tile_width",
            text = L["AddOn Tile Width"],
            default = 240,
            global = 1,
            type = "spin",
            range = { 100, 240, 10},
            reload = 1,
        },
        {
            var = "tile_height",
            text = L["AddOn Tile Height"],
            default = 42,
            global = 1,
            type = "spin",
            range = { 14, 50, 2},
            reload = 1,
        },
        {
            var = "tile_margin",
            text = L["AddOn Tile Margin"],
            default = 8,
            global = 1,
            type = "spin",
            range = { 0, 12, 2},
            reload = 1,
        },
    },
});
