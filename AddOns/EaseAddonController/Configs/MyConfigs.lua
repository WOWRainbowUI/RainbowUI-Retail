--- Custom Register AddOns' Config
-- Create a folder "!!!EaseAddOnConfigs" in Interface\AddOns, and copy this file there.
-- You can also create multiple config-files and include them from !!!EaseAddOnConfigs/MyConfigs.xml (need to be created manually)
-- The optional properties in U1RegisterAddon is listed in _CfgExample.lua
U1RegisterAddon("Recount", {
    title = "Damage Meters",
    tags = {"My Favorites"},
    icon = "Interface\\ICONS\\ACHIEVEMENT_GUILDPERK_FASTTRACK_RANK2",
    desc = "Write your own descriptions here, or leave nil for default addon notes.",

    {
        type = "checkbox",
        var = "show",
        lower = true,
        text = "Toggle Main Window",
        default = true,
        callback = function(cfg, v, loading)             
            if(v) then
                Recount.MainWindow:Show();
                Recount:RefreshMainWindow();
            else
                Recount.MainWindow:Hide();
            end
        end,
        {
            type = "button",
            text = "Test Button",
            callback = function() print("Hello World") end
        },
    },
    {
        type = "text",
        text = "Text Title Example",
        {
            var = "var1",
            type = "drop",
            var = "var1",
            text = "DropDown Example",
            default = 2,
            options = {"Caption1", "value1", "Caption2", 2, },
            callback = function(cfg, v, loading) print(cfg.text, v) end,
        },
        {
            var = "var2",
            type = "radio",
            text = "Radio Box Example",
            cols = 2,
            default = function() return U1PlayerClass == "WARRIOR" and 100 or "value2" end,
            options = {"Caption1", 100, "Caption2", "value2", },
            callback = function(cfg, v, loading) print(cfg.text, v) end,
        },
        {
            var = "var3",
            type = "checklist",
            text = "CheckBox List Example",
            default = { ["value1"] = true, ["value2"] = true, },
            options = {"Caption1", "value1", "Caption2", "value2", },
            callback = function(cfg, v, loading) print(cfg.text) dump(v) end,
        },
        {
            var = "var4",
            type = "spin",
            text = "SpinBox Example",
            range = {1, 100, 5},
            default = 50,
            callback = function(cfg, v, loading) print(cfg.text, v) end,
        },
    },
})
