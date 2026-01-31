local LSM = LibStub("LibSharedMedia-3.0")
local zhCN, zhTW, western = LSM.LOCALE_BIT_zhCN, LSM.LOCALE_BIT_zhTW, LSM.LOCALE_BIT_western

local MediaType_BACKGROUND = LSM.MediaType.BACKGROUND
local MediaType_BORDER = LSM.MediaType.BORDER
local MediaType_FONT = LSM.MediaType.FONT
local MediaType_STATUSBAR = LSM.MediaType.STATUSBAR

-- -----
-- borders
-- -----

LSM:Register(MediaType_BORDER, "fer01", [[Interface\AddOns\SharedMedia_BNS\Borders\fer1.tga]])
LSM:Register(MediaType_BORDER, "fer02", [[Interface\AddOns\SharedMedia_BNS\Borders\fer2.tga]])
LSM:Register(MediaType_BORDER, "fer03", [[Interface\AddOns\SharedMedia_BNS\Borders\fer3.tga]])
LSM:Register(MediaType_BORDER, "fer04", [[Interface\AddOns\SharedMedia_BNS\Borders\fer4.tga]])
LSM:Register(MediaType_BORDER, "fer05", [[Interface\AddOns\SharedMedia_BNS\Borders\fer5.tga]])
LSM:Register(MediaType_BORDER, "fer06", [[Interface\AddOns\SharedMedia_BNS\Borders\fer6.tga]])
LSM:Register(MediaType_BORDER, "fer07", [[Interface\AddOns\SharedMedia_BNS\Borders\fer7.tga]])
LSM:Register(MediaType_BORDER, "fer08", [[Interface\AddOns\SharedMedia_BNS\Borders\fer8.tga]])
LSM:Register(MediaType_BORDER, "fer09", [[Interface\AddOns\SharedMedia_BNS\Borders\fer9.tga]])
LSM:Register(MediaType_BORDER, "fer10", [[Interface\AddOns\SharedMedia_BNS\Borders\fer10.tga]])
LSM:Register(MediaType_BORDER, "fer11", [[Interface\AddOns\SharedMedia_BNS\Borders\fer11.tga]])
LSM:Register(MediaType_BORDER, "fer12", [[Interface\AddOns\SharedMedia_BNS\Borders\fer12.tga]])
LSM:Register(MediaType_BORDER, "fer13", [[Interface\AddOns\SharedMedia_BNS\Borders\fer13.tga]])

-- -----
--   FONT
-- -----
LSM:Register(MediaType_FONT, " 昭源黑體改",						[[Interface\Addons\SharedMedia_BNS\font\ChironHeiHKText-Bold.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, " 芫荽+霞鹜文楷",					[[Interface\Addons\SharedMedia_BNS\font\bLEI00D.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, " 更莎黑體等寬",					[[Interface\Addons\SharedMedia_BNS\font\SarasaMonoTC-Regular.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Alata",							[[Interface\Addons\SharedMedia_BNS\font\Alata.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "MaJi Bold",						[[Interface\Addons\SharedMedia_BNS\font\MaJi-Bold.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "US Damage text",					[[Interface\Addons\SharedMedia_BNS\font\US_damage_Font_Bold.TTF]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "CANAVAR Bold",					[[Interface\Addons\SharedMedia_BNS\font\CANAVAR-Bold.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "PEPSI",							[[Interface\Addons\SharedMedia_BNS\font\PEPSI_pl.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Coalition",						[[Interface\Addons\SharedMedia_BNS\font\Coalition.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "ReggaeOne",						[[Interface\Addons\SharedMedia_BNS\font\ReggaeOneLatin.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Neusharp Bold",					[[Interface\Addons\SharedMedia_BNS\font\Neusharp-Bold.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "sf-fourche Bold",					[[Interface\Addons\SharedMedia_BNS\font\sf-fourche bold.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Spartan Bold",					[[Interface\Addons\SharedMedia_BNS\font\Spartan Bold.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Hackman",							[[Interface\Addons\SharedMedia_BNS\font\Hackman.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Kdam Thmor Pro",					[[Interface\Addons\SharedMedia_BNS\font\Kdam Thmor Pro.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Balisong",						[[Interface\Addons\SharedMedia_BNS\font\Balisong.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Refunk",							[[Interface\Addons\SharedMedia_BNS\font\Refunk.ttf]], zhCN + zhTW + western)

-- -----
--   SOUND
-- -----
LSM:Register("sound", "#|cff00c0ff語音：快驅散|r", [[Interface\Addons\SharedMedia_BNS\sound\dispelnow.ogg]]) 
LSM:Register("sound", "#|cff00c0ff語音：快打斷|r", [[Interface\Addons\SharedMedia_BNS\sound\kickcast.ogg]]) 
LSM:Register("sound", "!|cff00c0ff音效：低血量|r", [[Interface\Addons\SharedMedia_BNS\sound\LowHealth.ogg]]) 
LSM:Register("sound", "!|cff00c0ff音效：低法力|r", [[Interface\Addons\SharedMedia_BNS\sound\LowMana.ogg]]) 
LSM:Register("sound", "!|cff00c0ff音效：mgsdrop|r", [[Interface\Addons\SharedMedia_BNS\sound\mgsdrop.ogg]]) 
LSM:Register("sound", "!|cff00c0ff音效：mgsmail|r", [[Interface\Addons\SharedMedia_BNS\sound\mgsmail.ogg]]) 
LSM:Register("sound", "!|cff00c0ff音效：mgsopen|r", [[Interface\Addons\SharedMedia_BNS\sound\mgsopen.ogg]]) 
LSM:Register("sound", "!|cff00c0ff音效：瑪利歐金幣|r", [[Interface\Addons\SharedMedia_BNS\sound\super_mario_bros_coin.ogg]])
LSM:Register("sound", "!|cff00c0ff音效：瑪利歐GG|r", [[Interface\Addons\SharedMedia_BNS\sound\super_mario_bros_game_over.ogg]])
LSM:Register("sound", "!|cff00c0ff音效：瑪利歐變大|r", [[Interface\Addons\SharedMedia_BNS\sound\super_mario_bros_powerup.ogg]])

-- -----
--   STATUSBAR
-- -----
LSM:Register(MediaType_STATUSBAR, "Cloud",				[[Interface\Addons\SharedMedia_BNS\statusbar\Cloud]])
LSM:Register(MediaType_STATUSBAR, "Comet",				[[Interface\Addons\SharedMedia_BNS\statusbar\Comet]])
LSM:Register(MediaType_STATUSBAR, "Dabs",				[[Interface\Addons\SharedMedia_BNS\statusbar\Dabs]])
LSM:Register(MediaType_STATUSBAR, "DarkBottom",			[[Interface\Addons\SharedMedia_BNS\statusbar\DarkBottom]])
LSM:Register(MediaType_STATUSBAR, "Glamour",			[[Interface\Addons\SharedMedia_BNS\statusbar\Glamour]])
LSM:Register(MediaType_STATUSBAR, "Glamour2",			[[Interface\Addons\SharedMedia_BNS\statusbar\Glamour2]])
LSM:Register(MediaType_STATUSBAR, "Glamour3",			[[Interface\Addons\SharedMedia_BNS\statusbar\Glamour3]])
LSM:Register(MediaType_STATUSBAR, "Glamour4",			[[Interface\Addons\SharedMedia_BNS\statusbar\Glamour4]])
LSM:Register(MediaType_STATUSBAR, "Glamour5",			[[Interface\Addons\SharedMedia_BNS\statusbar\Glamour5]])
LSM:Register(MediaType_STATUSBAR, "Glamour6",			[[Interface\Addons\SharedMedia_BNS\statusbar\Glamour6]])
LSM:Register(MediaType_STATUSBAR, "Glamour7",			[[Interface\Addons\SharedMedia_BNS\statusbar\Glamour7]])
LSM:Register(MediaType_STATUSBAR, "Perl v2",			[[Interface\Addons\SharedMedia_BNS\statusbar\Perl2]])
LSM:Register(MediaType_STATUSBAR, "Rainbow",			[[Interface\Addons\SharedMedia_BNS\statusbar\Rainbow]])
LSM:Register(MediaType_STATUSBAR, "Rocks",				[[Interface\Addons\SharedMedia_BNS\statusbar\Rocks]])
LSM:Register(MediaType_STATUSBAR, "Runes",				[[Interface\Addons\SharedMedia_BNS\statusbar\Runes]])
LSM:Register(MediaType_STATUSBAR, "Smooth v2",			[[Interface\Addons\SharedMedia_BNS\statusbar\Smoothv2]])
LSM:Register(MediaType_STATUSBAR, "Water",				[[Interface\Addons\SharedMedia_BNS\statusbar\Water]])
LSM:Register(MediaType_STATUSBAR, "Wisps",				[[Interface\Addons\SharedMedia_BNS\statusbar\Wisps]])
LSM:Register(MediaType_STATUSBAR, "fer2",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer2]])
LSM:Register(MediaType_STATUSBAR, "fer3",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer3]])
LSM:Register(MediaType_STATUSBAR, "fer5",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer5]])
LSM:Register(MediaType_STATUSBAR, "fer6",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer6]])
LSM:Register(MediaType_STATUSBAR, "fer8",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer8]])
LSM:Register(MediaType_STATUSBAR, "fer9",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer9]])
LSM:Register(MediaType_STATUSBAR, "fer14",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer14]])
LSM:Register(MediaType_STATUSBAR, "fer20",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer20]])
LSM:Register(MediaType_STATUSBAR, "fer21",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer21]])
LSM:Register(MediaType_STATUSBAR, "fer25",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer25]])
LSM:Register(MediaType_STATUSBAR, "fer27",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer27]])
LSM:Register(MediaType_STATUSBAR, "fer34",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer34]])
LSM:Register(MediaType_STATUSBAR, "fer35",				[[Interface\Addons\SharedMedia_BNS\statusbar\fer35]])
LSM:Register(MediaType_STATUSBAR, "FF_Antonia",			[[Interface\Addons\SharedMedia_BNS\statusbar\FF_Antonia]])
LSM:Register(MediaType_STATUSBAR, "FF_Bettina",			[[Interface\Addons\SharedMedia_BNS\statusbar\FF_Bettina]])
LSM:Register(MediaType_STATUSBAR, "ToxiUI-clean",		[[Interface\Addons\SharedMedia_BNS\statusbar\ToxiUI-clean]])
LSM:Register(MediaType_STATUSBAR, "ToxiUI-dark",		[[Interface\Addons\SharedMedia_BNS\statusbar\ToxiUI-dark]])
LSM:Register(MediaType_STATUSBAR, "ToxiUI-g1",			[[Interface\Addons\SharedMedia_BNS\statusbar\ToxiUI-g1]])
LSM:Register(MediaType_STATUSBAR, "ToxiUI-g2",			[[Interface\Addons\SharedMedia_BNS\statusbar\ToxiUI-g2]])
LSM:Register(MediaType_STATUSBAR, "ToxiUI-grad",		[[Interface\Addons\SharedMedia_BNS\statusbar\ToxiUI-grad]])