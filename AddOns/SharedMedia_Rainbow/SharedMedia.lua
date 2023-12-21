-- tab size is 4
-- registrations for media from the client itself belongs in LibSharedMedia-3.0

local LSM = LibStub("LibSharedMedia-3.0")
local koKR, ruRU, zhCN, zhTW, western = LSM.LOCALE_BIT_koKR, LSM.LOCALE_BIT_ruRU, LSM.LOCALE_BIT_zhCN, LSM.LOCALE_BIT_zhTW, LSM.LOCALE_BIT_western

local MediaType_BACKGROUND = LSM.MediaType.BACKGROUND
local MediaType_BORDER = LSM.MediaType.BORDER
local MediaType_FONT = LSM.MediaType.FONT
local MediaType_STATUSBAR = LSM.MediaType.STATUSBAR

-- -----
-- BACKGROUND
-- -----
LSM:Register(MediaType_BACKGROUND, "Moo", [[Interface\Addons\SharedMedia_Rainbow\background\moo.tga]])
LSM:Register(MediaType_BACKGROUND, "Bricks", [[Interface\Addons\SharedMedia_Rainbow\background\bricks.tga]])
LSM:Register(MediaType_BACKGROUND, "Brushed Metal", [[Interface\Addons\SharedMedia_Rainbow\background\brushedmetal.tga]])
LSM:Register(MediaType_BACKGROUND, "Copper", [[Interface\Addons\SharedMedia_Rainbow\background\copper.tga]])
LSM:Register(MediaType_BACKGROUND, "Smoke", [[Interface\Addons\SharedMedia_Rainbow\background\smoke.tga]])

-- -----
--  BORDER
-- ----
LSM:Register(MediaType_BORDER, "RothSquare", [[Interface\Addons\SharedMedia_Rainbow\border\roth.tga]])
LSM:Register(MediaType_BORDER, "SeerahScalloped", [[Interface\Addons\SharedMedia_Rainbow\border\SeerahScalloped.blp]])

-- -----
--   FONT
-- -----
LSM:Register(MediaType_FONT, "Adventure",					[[Interface\Addons\SharedMedia_Rainbow\fonts\adventure\Adventure.ttf]],				zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "All Hooked Up",				[[Interface\Addons\SharedMedia_Rainbow\fonts\all_hooked_up\HookedUp.ttf]],			zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Bazooka",						[[Interface\Addons\SharedMedia_Rainbow\fonts\bazooka\Bazooka.ttf]],					zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Black Chancery",				[[Interface\Addons\SharedMedia_Rainbow\fonts\black_chancery\BlackChancery.ttf]],	zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Celestia Medium Redux",		[[Interface\Addons\SharedMedia_Rainbow\fonts\celestia_medium_redux\CelestiaMediumRedux1.55.ttf]], zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "DejaVu Sans",					[[Interface\Addons\SharedMedia_Rainbow\fonts\deja_vu\DejaVuLGCSans.ttf]],			zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "DejaVu Serif",				[[Interface\Addons\SharedMedia_Rainbow\fonts\deja_vu\DejaVuLGCSerif.ttf]],			zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "DorisPP",						[[Interface\Addons\SharedMedia_Rainbow\fonts\doris_pp\DorisPP.ttf]],				zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Enigmatic",					[[Interface\Addons\SharedMedia_Rainbow\fonts\enigmatic\EnigmaU_2.ttf]],				zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Fitzgerald",					[[Interface\Addons\SharedMedia_Rainbow\fonts\fitzgerald\Fitzgerald.ttf]],			zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Gentium Plus",				[[Interface\Addons\SharedMedia_Rainbow\fonts\gentium_plus\GentiumPlus-R.ttf]],		zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Hack",						[[Interface\Addons\SharedMedia_Rainbow\fonts\hack\Hack-Regular.ttf]],				zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Liberation Sans",				[[Interface\Addons\SharedMedia_Rainbow\fonts\liberation\LiberationSans-Regular.ttf]],	 zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Liberation Serif",			[[Interface\Addons\SharedMedia_Rainbow\fonts\liberation\LiberationSerif-Regular.ttf]],	 zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "SF Atarian System",			[[Interface\Addons\SharedMedia_Rainbow\fonts\sf_atarian_system\SFAtarianSystem.ttf]],	 zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "SF Covington",				[[Interface\Addons\SharedMedia_Rainbow\fonts\sf_covington\SFCovington.ttf]],		zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "SF Movie Poster",				[[Interface\Addons\SharedMedia_Rainbow\fonts\sf_movie_poster\SFMoviePoster-Bold.ttf]],	 zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "SF Wonder Comic",				[[Interface\Addons\SharedMedia_Rainbow\fonts\sf_wonder_comic\SFWonderComic.ttf]],	zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "swf!t",						[[Interface\Addons\SharedMedia_Rainbow\fonts\swf!t\SWF!T___.ttf]],					zhCN + zhTW + western)
LSM:Register(MediaType_FONT, " 源流明體123",					[[Interface\Addons\SharedMedia_Rainbow\fonts\GenRyuMin\GenRyuMin-B-Hoefler.ttf]],			zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Hoefler Text Regular",		[[Interface\Addons\SharedMedia_Rainbow\fonts\hoefler\Hoefler_Text_Regular.ttf]],	zhCN + zhTW + western)
LSM:Register(MediaType_FONT, "Miedinger Bold",				[[Interface\Addons\SharedMedia_Rainbow\fonts\miedinger\Miedinger-Bold.ttf]],		zhCN + zhTW + western)
LSM:Register(MediaType_FONT, " 微軟雅黑123",				[[Interface\Addons\SharedMedia_Rainbow\fonts\YaHei\YaHei.ttf]],		zhCN + zhTW + western)
LSM:Register(MediaType_FONT, " 簡轉繁-文泉驛微米黑",			[[Interface\Addons\SharedMedia_Rainbow\fonts\hiya1561gl\hiya1561gl.ttf]],		zhCN + zhTW + western)
LSM:Register(MediaType_FONT, " 王漢宗綜藝體",				[[Interface\Addons\SharedMedia_Rainbow\fonts\Rawhide_Raw\Rawhide_Raw.ttf]], zhTW + western)
LSM:Register(MediaType_FONT, " 方正准圓123",				[[Interface\Addons\SharedMedia_Rainbow\fonts\bHEI00M\bHEI00M.ttf]], zhCN + zhTW + western)

-- -----
--   SOUND
-- -----

-- -----
--   STATUSBAR
-- -----
LSM:Register(MediaType_STATUSBAR, "Aluminium",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Aluminium]])
LSM:Register(MediaType_STATUSBAR, "Armory",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Armory]])
LSM:Register(MediaType_STATUSBAR, "BantoBar",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\BantoBar]])
LSM:Register(MediaType_STATUSBAR, "Bars",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Bars]])
LSM:Register(MediaType_STATUSBAR, "Bumps",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Bumps]])
LSM:Register(MediaType_STATUSBAR, "Button",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Button]])
LSM:Register(MediaType_STATUSBAR, "Charcoal",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Charcoal]])
LSM:Register(MediaType_STATUSBAR, "Cilo",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Cilo]])
LSM:Register(MediaType_STATUSBAR, "Cloud",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Cloud]])
LSM:Register(MediaType_STATUSBAR, "Comet",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Comet]])
LSM:Register(MediaType_STATUSBAR, "Dabs",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Dabs]])
LSM:Register(MediaType_STATUSBAR, "DarkBottom",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\DarkBottom]])
LSM:Register(MediaType_STATUSBAR, "Diagonal",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Diagonal]])
LSM:Register(MediaType_STATUSBAR, "Empty",			    [[Interface\Addons\SharedMedia_Rainbow\statusbar\Empty]])
LSM:Register(MediaType_STATUSBAR, "Falumn",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Falumn]])
LSM:Register(MediaType_STATUSBAR, "Fifths",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Fifths]])
LSM:Register(MediaType_STATUSBAR, "Flat",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Flat]])
LSM:Register(MediaType_STATUSBAR, "Fourths",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Fourths]])
LSM:Register(MediaType_STATUSBAR, "Frost",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Frost]])
LSM:Register(MediaType_STATUSBAR, "Glamour",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Glamour]])
LSM:Register(MediaType_STATUSBAR, "Glamour2",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Glamour2]])
LSM:Register(MediaType_STATUSBAR, "Glamour3",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Glamour3]])
LSM:Register(MediaType_STATUSBAR, "Glamour4",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Glamour4]])
LSM:Register(MediaType_STATUSBAR, "Glamour5",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Glamour5]])
LSM:Register(MediaType_STATUSBAR, "Glamour6",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Glamour6]])
LSM:Register(MediaType_STATUSBAR, "Glamour7",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Glamour7]])
LSM:Register(MediaType_STATUSBAR, "Glass",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Glass]])
LSM:Register(MediaType_STATUSBAR, "Glaze",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Glaze]])
LSM:Register(MediaType_STATUSBAR, "Glaze v2",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Glaze2]])
LSM:Register(MediaType_STATUSBAR, "Gloss",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Gloss]])
LSM:Register(MediaType_STATUSBAR, "Graphite",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Graphite]])
LSM:Register(MediaType_STATUSBAR, "Grid",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Grid]])
LSM:Register(MediaType_STATUSBAR, "Hatched",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Hatched]])
LSM:Register(MediaType_STATUSBAR, "Healbot",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Healbot]])
LSM:Register(MediaType_STATUSBAR, "Lyfe",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Lyfe]])
LSM:Register(MediaType_STATUSBAR, "LiteStep",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\LiteStep]])
LSM:Register(MediaType_STATUSBAR, "LiteStepLite",		[[Interface\Addons\SharedMedia_Rainbow\statusbar\LiteStepLite]])
LSM:Register(MediaType_STATUSBAR, "Melli",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Melli]])
LSM:Register(MediaType_STATUSBAR, "Melli Dark",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\MelliDark]])
LSM:Register(MediaType_STATUSBAR, "Melli Dark Rough",	[[Interface\Addons\SharedMedia_Rainbow\statusbar\MelliDarkRough]])
LSM:Register(MediaType_STATUSBAR, "Minimalist",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Minimalist]])
LSM:Register(MediaType_STATUSBAR, "Otravi",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Otravi]])
LSM:Register(MediaType_STATUSBAR, "Outline",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Outline]])
LSM:Register(MediaType_STATUSBAR, "Perl",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Perl]])
LSM:Register(MediaType_STATUSBAR, "Perl v2",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Perl2]])
LSM:Register(MediaType_STATUSBAR, "Pill",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Pill]])
LSM:Register(MediaType_STATUSBAR, "Rain",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Rain]])
LSM:Register(MediaType_STATUSBAR, "Rocks",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Rocks]])
LSM:Register(MediaType_STATUSBAR, "Round",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Round]])
LSM:Register(MediaType_STATUSBAR, "Ruben",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Ruben]])
LSM:Register(MediaType_STATUSBAR, "Runes",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Runes]])
LSM:Register(MediaType_STATUSBAR, "Skewed",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Skewed]])
LSM:Register(MediaType_STATUSBAR, "Smooth",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Smooth]])
LSM:Register(MediaType_STATUSBAR, "Smooth v2",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Smoothv2]])
LSM:Register(MediaType_STATUSBAR, "Smudge",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Smudge]])
LSM:Register(MediaType_STATUSBAR, "Steel",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Steel]])
LSM:Register(MediaType_STATUSBAR, "Striped",			[[Interface\Addons\SharedMedia_Rainbow\statusbar\Striped]])
LSM:Register(MediaType_STATUSBAR, "Tube",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Tube]])
LSM:Register(MediaType_STATUSBAR, "Water",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Water]])
LSM:Register(MediaType_STATUSBAR, "Wglass",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Wglass]])
LSM:Register(MediaType_STATUSBAR, "Wisps",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Wisps]])
LSM:Register(MediaType_STATUSBAR, "Xeon",				[[Interface\Addons\SharedMedia_Rainbow\statusbar\Xeon]])
