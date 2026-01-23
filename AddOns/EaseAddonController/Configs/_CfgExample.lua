U1RegisterAddon("AddOn Main Folder Name", {
    title =	"string",                       --- Addon's title shown in the control panel, instead reading from toc tag ##Title
    defaultEnable =	"true or false or 0/1",    --- Default state of the addon (User's EAC DB is nil)
    parent = "string",                      --- Force set the dependency addon.
    protected = true or false,              --- This addon cannot be disabled.
    hide = true or false,                   --- This addon is not shown in the control panel.
    optdeps = { "addon1", ... },            --- The optional dependencies, which decide the addon when load on demand
    optionsAfterVar = true or false,        --- Load the control panel option callbacks after VARIABLE_LOADED event.
    optionsAfterLogin = true or false,      --- Load the control panel option callbacks after PLAYER_LOGIN event.
    runBeforeLoad = function(info, name) end,   --- Run before the addon is loaded but not response to it's own ADDON_LOADED event, which is also the time when Ace3's OnInitialize method is called.
    runAfterLoad = function(info, name) end,    --- Run after the addon is loaded and responsed to it's own ADDON_LOADED, but before Ace3's OnEnable method.
    tags = { "tag1", ... },                 --- Categories of this addon.
    tags = { "" },                 --- Categories of this addon.
    icon = "Interface\\Icons\\XXX",         --- Icon in the control panel.
    desc = "string",                        --- Addon introduction instead of reading from toc's ##Notes tag
    author = "string",                      --- Addon author instead of reading from toc's ##Author tag
    modifier = "string",                    --- Some credits shown in the control panel introduction page.
    nolodbutton = true or false,            --- For Load-On-Demand addons, wether or not to create a "Force Load" button
    toggle = function(name, info, enable, justload) return need_to_reload end, --- Callback that runs when this addon is enabled or disabled, the justload parameter is true when the addon is actually loaded (not disabled and then re-enabled). The returning value of this function is used to decide if the ReloadUI button should be glowing or not.

    ------ Options Controls -------
    {
        type = "control_type",                      --- button,checkbox,drop,radio,checklist,spin,text
        var = "string",                             --- The saved variable name. This is the leaf path in the U1DB.configs, for example: U1DB.configs["recount/cfg1/cfg2"]
        text = "string",                            --- The shown title in buttons or after checkbox or as header.
        callback = function(cfg, v, loading)        --- The callback func when click button, toggle checkbox, select radio.
            LibStub("AceConfigDialog-3.0"):Open("GM2/Import")       --Ace3 Options
            InterfaceOptionsFrame_OpenToCategory("GatherMate 2")    --Blizzard Options
            SlashCmdList["GatherMate2"]("")                         --Run Slash Command
        end,
        lower = true or false,                      --- Lower the control panel frame or not.
        secure = true or false,                     --- Disabled while in combat.
        visible = true or false,                    --- Can be seen or hide. (for example, when player class is not supported)
        disabled = true or false,                   --- Temporarily disable this option
        tip = "string use ` as a linebreak.",       --- Options hints
        default	= "value or function",              --- The default value of this option.
        getvalue = function() return value end,     --- Get the value of this option from addon's own config variable.
        confirm = "string",                         --- If provided, there will be a confirm dialog box before changing this option.
        reload = true or false,                     --- Add a "Requires Reload" to the option's tooltip and the ReloadUI button will glow.
        options = {"Caption 1","Value 1", ... },    --- only used with control "radio"/"drop"/"checklist"
        cols = 3,                                   --- only used with control "radio"/"checklist", Column of the option list.
        indent = 1,                                 --- only used with control "radio", where options are indented.
        range = {min, max, step},                   --- only used with control "spin", all must be numbers.
        place = function(parent, cfg, last) end,    --- Custom Control
        enableOnNotLoad = true or false,            --- INTERNAL. Cannot interact when the addon is load.
        disableOnLoad = true or false,              --- INTERNAL. Can interact event the addon is not load.
        alwaysEnable = true or false,               --- INTERNAL. Can always interact.
    },
})
