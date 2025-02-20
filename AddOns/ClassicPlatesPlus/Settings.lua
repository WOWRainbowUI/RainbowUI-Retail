----------------------------------------
-- CORE
----------------------------------------
local myAddon, core = ...;
local func = core.func;
local data = core.data;

-- Colors
local yellow = "|cff" .. "ffd100";
local white  = "|cff" .. "ffffff";
local green  = "|cff" .. "7CFC00";
local orange = "|cff" .. "FF5600";
local blue   = "|cff" .. "0072CA";
local purple = "|cff" .. "FF00FF";
local gray   = "|cff" .. "808080";

-- Panels table
data.settings = {
    panels = {}, -- Table that will store panels for initialization
    configs = {
        all = {}, -- Table that will contain complete list of configs
        panels = {} -- Table for panels settings
    }
};

----------------------------------------
-- Loading Settings
----------------------------------------
function func:Load_Settings()

    -- Creating config tables
    CFG_ClassicPlatesPlus = CFG_ClassicPlatesPlus or {};
    CFG_Account_ClassicPlatesPlus = CFG_Account_ClassicPlatesPlus or { Profiles = {} };

    -- Creating profiles
    local profileID = func:GenerateID();
    local playerName = UnitName("player");
    local playerRealm = GetRealmName("player");
    local profileName = playerName .. " - " .. playerRealm;

    CFG_ClassicPlatesPlus.Profile = CFG_ClassicPlatesPlus.Profile or profileID;
    CFG_Account_ClassicPlatesPlus.Profiles[CFG_ClassicPlatesPlus.Profile] = CFG_Account_ClassicPlatesPlus.Profiles[CFG_ClassicPlatesPlus.Profile] or { displayName = profileName };

    -- MAIN PANEL
    -- Fist panel has to be accessable to other panels, putting it outside of the code block.
    local panelMain = func:CreatePanel(nil, "血條");

    -- CATEGORY: About
    do
        -- Sub-Category
        do
            local title = "聯絡我";
            local description = "隨時提供反饋、尋求幫助或提出您的想法。";

            func:Create_SubCategory(panelMain, title, description);
        end

        -- Social Link
        do
            local name = "Discord";
            local image = "Interface\\addons\\ClassicPlatesPlus\\media\\logo\\discord";
            local link = "discord.gg/Hj49J2APGZ";
            local text = "";
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_SocialLink(panelMain, flair, name, image, text, link)
        end

        -- Spacer
        func:Create_Spacer(panelMain);

        -- Social Link
        do
            local name = "GitHub";
            local image = "Interface\\addons\\ClassicPlatesPlus\\media\\logo\\github";
            local link = "github.com/ReubinAuthor/ClassicPlatesPlus";
            local text = "";
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_SocialLink(panelMain, flair, name, image, text, link)
        end

        -- Spacer
        func:Create_Spacer(panelMain);

        -- Sub-Category
        do
            local title = "考慮贊助這個專案";
            local description = "這個專案的開發佔用了我 99% 的魔獸世界時間。\n如果您喜歡它，請考慮贊助。";

            func:Create_SubCategory(panelMain, title, description);
        end

        -- Social Link
        do
            local name = "Boosty";
            local image = "Interface\\addons\\ClassicPlatesPlus\\media\\logo\\boosty";
            local link = "boosty.to/reubin";
            local text = "";
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_SocialLink(panelMain, flair, name, image, text, link)
        end

        -- Anchoring settings
        func:AnchorFrames(panelMain);
    end

    -- CATEGORY: General
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "一般");

        -- Sub-Category
        func:Create_SubCategory(panel, "一般");

        -- CheckButton
        do
            local name = "依距離縮放名條大小";
            local tooltip = "隨著距離越遠，名條縮小";
            local cfg = "ScaleWithDistance";
            local default = true;
            local flair = { classicEra = false, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "放大當前目標的血條";
            local tooltip = "";
            local cfg = "EnlargeSelected";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "淡化非當前目標";
            local tooltip = "";
            local cfg = "FadeUnselected";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Slider
        do
            local name = "淡化強度";
            local tooltip = "";
            local cfg = "FadeIntensity";
            local default = 0.5;
            local step = 0.01;
            local minValue = 0.0;
            local maxValue = 1.0;
            local decimals = 2;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Slider
        do
            local name = "名條縮放大小";
            local tooltip = "必須脫離戰鬥才能生效";
            local cfg = "NameplatesScale";
            local default = 1.00;
            local step = 0.01;
            local minValue = 0.75;
            local maxValue = 1.25;
            local decimals = 2;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Slider
        do
            local name = "最遠可以看見名條的距離";
            local tooltip = "必須脫離戰鬥才能生效";
            local cfg = "MaxNameplateDistance";
            local default = 60;
            local step = 1;
            local minValue = 10;
            local maxValue = 60;
            local decimals = 0;
            local flair = { classicEra = false, cata = false, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Slider
        do
            local name = "連擊點數縮放大小";
            local tooltip = "";
            local cfg = "ComboPointsScaleClassless" --"ClassPowerScale";
            local default = 1;
            local step = 0.01;
            local minValue = 0.50;
            local maxValue = 1.50;
            local decimals = 2;
            local flair = { classicEra = true, cata = true, retail = false };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "部件");

        -- CheckButton
        do
            local name = "能量條";
            local tooltip = "";
            local cfg = "Powerbar";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "頭像";
            local tooltip = "";
            local cfg = "Portrait";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "等級";
            local tooltip = "";
            local cfg = "ShowLevel";
            local default = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and true or false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "公會名稱";
            local tooltip = "";
            local cfg = "ShowGuildName";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "NPC 類別";
            local tooltip = "生物類別：" .. white .. "精英、稀有、稀有精英、世界首領";
            local cfg = "Classification";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "陣營徽章";
            local tooltip = "";
            local cfg = "ShowFaction";
            local default = false; -- 更改預設值
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "成員徽章";
            local tooltip = "徽章顏色：" .. purple .. "好友、" .. green .. "公會成員、" .. blue .. "隊伍成員、" .. orange .. "團隊成員";
            local cfg = "FellowshipBadge";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "任務標記";
            local tooltip = "生物類別：" .. white .. "精英、稀有、稀有精英、世界首領";
            local cfg = "QuestMark";
            local default = true;
            local flair = { classicEra = false, cata = false, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "數值", nil, "small");

        -- CheckButton
        do
            local name = "數值";
            local tooltip = "顯示血量和能量數值";
            local cfg = "NumericValue";
            local default = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and true or false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "百分比";
            local tooltip = "顯示血量和能量百分比";
            local cfg = "Percentage";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "對調數值位置";
            local tooltip = "交換數值和百分比的位置";
            local cfg = "PercentageAsMainValue";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Spacer
        func:Create_Spacer(panel, "small");

        -- CheckButton
        do
            local name = "最大血量";
            local tooltip = "顯示你的最大血量\n(只會顯示於個人資源條)";
            local cfg = "PersonalNameplateTotalHealth";
            local default = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and true or false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "最大能量";
            local tooltip = "顯示你的最大能量\n" .. white .. "例如：" .. yellow .. "法力、怒氣、能量...等\n（只會顯示於個人資源條）";
            local cfg = "PersonalNameplateTotalPower";
            local default = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and true or false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Spacer
        func:Create_Spacer(panel);

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Personal Nameplate
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "個人資源條");

        -- Sub-Category
        func:Create_SubCategory(panel, "一般");

        -- CheckButton
        do
            local name = "啟用個人資源條";
            local tooltip = "";
            local cfg = "PersonalNameplate";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = false };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "非戰鬥中也要顯示";
            local tooltip = "即時不在戰鬥中，也要顯示個人資源條。";
            local cfg = "PersonalNameplateAlwaysShow";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };
            local cvar = "NameplatePersonalShowAlways";

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default, cvar);
        end

        -- CheckButton
        do
            local name = "淡出";
            local tooltip = "脫離戰鬥時淡出個人資源條";
            local cfg = "PersonalNameplateFade";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = false };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Slider
        do
            local name = "淡出程度";
            local tooltip = "";
            local cfg = "PersonalNameplateFadeIntensity";
            local default = 0.5;
            local step = 0.01;
            local minValue = 0.0;
            local maxValue = 1.0;
            local decimals = 2;
            local flair = { classicEra = true, cata = true, retail = false };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Slider
        do
            local name = "個人資源條位置";
            local tooltip = "也可以按住 " .. green .. "CTRL" .. yellow .. " 不放，用" .. green .. "滑鼠左鍵拖曳移動。";
            local cfg = "PersonalNameplatePointY";
            local default = 380;
            local step = 1;
            local minValue = 1;
            local maxValue = 1500;
            local decimals = 0;
            local flair = { classicEra = true, cata = true, retail = false };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Slider
        do
            local name = "個人資源條縮放大小";
            local tooltip = "";
            local cfg = "PersonalNameplatesScale";
            local default = 1.00;
            local step = 0.01;
            local minValue = 0.75;
            local maxValue = 1.25;
            local decimals = 2;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "特殊能量");

        -- CheckButton
        do
            local name = "特殊能量";
            local tooltip = "自訂特殊能量條：" .. white .. "圖騰" .. gray .. "\n日後會新增更多";
            local cfg = "SpecialPower";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Slider
        do
            local name = "特殊能量縮放大小";
            local tooltip = "";
            local cfg = "SpecialPowerScale";
            local default = 1.00;
            local step = 0.01;
            local minValue = 0.75;
            local maxValue = 1.25;
            local decimals = 2;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "血量條動畫");

        -- CheckButton
        do
            local name = "血量條動畫";
            local tooltip = "顯示血量條減少和恢復的動畫";
            local cfg = "PersonalHealthBarAnimation";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Slider
        do
            local name = "血量條動畫閾值";
            local tooltip = "動畫閾值（百分比）";
            local cfg = "PersonalHealthBarAnimationThreshold";
            local default = 1.00;
            local step = 1;
            local minValue = 1;
            local maxValue = 99;
            local decimals = 0;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "能量條動畫");

        -- CheckButton
        do
            local name = "能量條動畫";
            local tooltip = "顯示能量條減少和恢復的動畫";
            local cfg = "PersonalPowerBarAnimation";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Slider
        do
            local name = "能量條動畫閾值";
            local tooltip = "動畫閾值（百分比）";
            local cfg = "PersonalPowerBarAnimationThreshold";
            local default = 10.00;
            local step = 1;
            local minValue = 1;
            local maxValue = 99;
            local decimals = 0;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Spacer
        func:Create_Spacer(panel);

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Class Related
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "職業相關");

        -- Spacer
        --func:Create_Spacer(panel);

        -- Sub-Category
        func:Create_SubCategory(panel, "名字 & 公會", nil, "large");

        -- CheckButton
        do
            local name = "友方玩家職業顏色";
            local tooltip = "友方名字 & 公會職業顏色";
            local cfg = "FriendlyClassColorNamesAndGuild";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "敵方玩家職業顏色";
            local tooltip = "敵方名字 & 公會職業顏色";
            local cfg = "EnemyClassColorNamesAndGuild";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "圖示", nil, "large");

        -- CheckButton
        do
            local name = "友方玩家職業圖示";
            local tooltip = "";
            local cfg = "ClassIconsFriendly";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "敵方玩家職業圖示";
            local tooltip = "";
            local cfg = "ClassIconsEnemy";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "血量條", nil, "large");

        -- CheckButton
        do
            local name = "友方玩家血量條職業顏色";
            local tooltip = "";
            local cfg = "HealthBarClassColorsFriendly";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "敵方玩家血量條職業顏色";
            local tooltip = "";
            local cfg = "HealthBarClassColorsEnemy";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Spacer
        func:Create_Spacer(panel);

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Names Only
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "只顯示名字");

        -- Sub-Category
        func:Create_SubCategory(panel, "一般");

        -- CheckButton
        do
            local name = "總是顯示當前目標的血條";
            local tooltip = "";
            local cfg = "NamesOnlyAlwaysShowTargetsNameplate";
            local default = false; -- 更改預設值
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "友方");

        -- CheckButton
        do
            local name = "友方玩家";
            local tooltip = "";
            local cfg = "NamesOnlyFriendlyPlayers";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "友方寵物";
            local tooltip = "";
            local cfg = "NamesOnlyFriendlyPets";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "友方 NPC";
            local tooltip = "";
            local cfg = "NamesOnlyFriendlyNPC";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "友方圖騰";
            local tooltip = "";
            local cfg = "NamesOnlyFriendlyTotems";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "敵方");

        -- CheckButton
        do
            local name = "敵方玩家";
            local tooltip = "";
            local cfg = "NamesOnlyEnemyPlayers";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "敵方寵物";
            local tooltip = "";
            local cfg = "NamesOnlyEnemyPets";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "敵方 NPC";
            local tooltip = "";
            local cfg = "NamesOnlyEnemyNPC";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "敵方圖騰";
            local tooltip = "";
            local cfg = "NamesOnlyEnemyTotems";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "排除");

        -- CheckButton
        do
            local name = "好友除外";
            local tooltip = "";
            local cfg = "NamesOnlyExcludeFriends";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "公會成員除外";
            local tooltip = "";
            local cfg = "NamesOnlyExcludeGuild";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "隊伍成員除外";
            local tooltip = "";
            local cfg = "NamesOnlyExcludeParty";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "團隊成員除外";
            local tooltip = "";
            local cfg = "NamesOnlyExcludeRaid";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Spacer
        func:Create_Spacer(panel);

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Auras
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "光環");

        -- Sub-Category
        func:Create_SubCategory(panel, "一般");

        -- CheckButton
        do
            local name = "倒數計時";
            local tooltip = "";
            local cfg = "AurasCountdown";
            local default = false; -- 更改預設值
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- DropDownMenu
        do
            local name = "倒數計時位置";
            local tooltip = "";
            local cfg = "AurasCountdownPosition";
            local default = 1;
            local options = {
                [1] = "右上",
                [2] = "中間"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- CheckButton
        do
            local name = "反向冷卻動畫";
            local tooltip = "";
            local cfg = "AurasReverseAnimation";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "標示你的光環";
            local tooltip = "";
            local cfg = "AurasMarkYours";
            local default = false; -- 更改預設值
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "標示顏色";
            local tooltip = "";
            local cfg = "AurasMarkColor";
            local default = {r = 1, g = 1, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- DropDownMenu
        do
            local name = "標示位置";
            local tooltip = "隱藏沒有到期時間的光環";
            local cfg = "AurasMarkLocation";
            local default = 1;
            local options = {
                [1] = "左上",
                [2] = "左下",
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- CheckButton
        do
            local name = "顯著標示重要光環";
            local tooltip = "";
            local cfg = "AurasImportantHighlight";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "過濾方式");

        -- CheckButton
        do
            local name = "只顯示重要光環";
            local tooltip = "";
            local cfg = "AurasShowOnlyImportant";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "只在當前目標上顯示光環";
            local tooltip = "";
            local cfg = "AurasOnTarget";
            local default = false; -- 更改預設值
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Spacer
        func:Create_Spacer(panel, "small");

        -- CheckButton
        do
            local name = "在友方身上顯示增益";
            local tooltip = "";
            local cfg = "BuffsFriendly";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "在友方身上顯示減益";
            local tooltip = "";
            local cfg = "DebuffsFriendly";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "在敵方身上顯示增益";
            local tooltip = "";
            local cfg = "BuffsEnemy";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "在敵方身上顯示減益";
            local tooltip = "";
            local cfg = "DebuffsEnemy";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Spacer
        func:Create_Spacer(panel, "small");

        -- CheckButton
        do
            local name = "在個人資源條上顯示增益";
            local tooltip = "";
            local cfg = "BuffsPersonal";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "在個人資源條上顯示減益";
            local tooltip = "";
            local cfg = "DebuffsPersonal";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Spacer
        func:Create_Spacer(panel, "small");

        -- DropDownMenu
        do
            local name = "被動光環";
            local tooltip = "隱藏沒有到期時間的光環";
            local cfg = "AurasHidePassive";
            local default = 2; -- 更改預設值
            local options = {
                [1] = "顯示全部",
                [2] = "隱藏全部",
                [3] = "只顯示你自己的"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- DropDownMenu
        do
            local name = "友方身上的光環";
            local tooltip = "";
            local cfg = "AurasFilterFriendly";
            local default = 3; -- 更改預設值
            local options = {
                [1] = "顯示所有光環",
                [2] = "顯示你施放的光環",
                [3] = "顯示你可以施放和驅散的光環"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- DropDownMenu
        do
            local name = "敵方身上的光環";
            local tooltip = "";
            local cfg = "AurasFilterEnemy";
            local default = 2; -- 更改預設值
            local options = {
                [1] = "顯示所有光環",
                [2] = "顯示你施放的光環"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- DropDownMenu
        do
            local name = "個人資源條增益";
            local tooltip = "";
            local cfg = "BuffsFilterPersonal";
            local default = 1;
            local options = {
                [1] = "顯示所有增益",
                [2] = "顯示你施放的增益",
                [3] = "顯示你可以施放和已經施放的增益"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- DropDownMenu
        do
            local name = "個人資源條減益";
            local tooltip = "";
            local cfg = "DebuffsFilterPersonal";
            local default = 1;
            local options = {
                [1] = "顯示所有減益",
                [2] = "顯示你可以驅散的減益"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- Spacer
        func:Create_Spacer(panel, "small");

        -- DropDownMenu
        do
            local name = "隊伍過濾方式";
            local tooltip = "";
            local cfg = "AurasGroupFilter";
            local default = 1;
            local options = {
                [1] = "顯示所有人的增益",
                [2] = "顯示隊伍成員的增益",
                [3] = "顯示團隊成員的增益",
                [4] = "顯示隊伍 & 團隊成員的增益"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- CheckButton
        do
            local name = "排除目標";
            local tooltip = "從隊伍過濾中排除目標";
            local cfg = "AurasGroupFilterExcludeTarget";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "浮動提示資訊");

        -- DropDownMenu
        do
            local name = "浮動提示資訊";
            local tooltip = "";
            local cfg = "Tooltip";
            local default = 1;
            local options = {
                [1] = "按住 SHIFT",
                [2] = "按住 CTRL",
                [3] = "按住 ALT",
                [4] = "停用"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- CheckButton
        do
            local name = "在浮動提示中顯示法術 ID";
            local tooltip = "";
            local cfg = "TooltipSpellID";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "光環數量");

        -- CheckButton
        do
            local name = "光環超出數量";
            local tooltip = "";
            local cfg = "AurasOverFlowCounter";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "友方", nil, "small");

        -- Slider
        do
            local name = "最大增益數量";
            local tooltip = "";
            local cfg = "AurasMaxBuffsFriendly";
            local default = 4;
            local step = 1;
            local minValue = 1;
            local maxValue = 16;
            local decimals = 0;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Slider
        do
            local name = "最大減益數量";
            local tooltip = "";
            local cfg = "AurasMaxDebuffsFriendly";
            local default = 2;
            local step = 1;
            local minValue = 1;
            local maxValue = 16;
            local decimals = 0;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "敵方", nil, "small");

        -- Slider
        do
            local name = "最大增益數量";
            local tooltip = "";
            local cfg = "AurasMaxBuffsEnemy";
            local default = 2;
            local step = 1;
            local minValue = 1;
            local maxValue = 16;
            local decimals = 0;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Slider
        do
            local name = "最大減益數量";
            local tooltip = "";
            local cfg = "AurasMaxDebuffsEnemy";
            local default = 4;
            local step = 1;
            local minValue = 1;
            local maxValue = 16;
            local decimals = 0;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "個人資源條光環", nil, "small");

        -- Slider
        do
            local name = "最大增益數量";
            local tooltip = "";
            local cfg = "AurasPersonalMaxBuffs";
            local default = 6;
            local step = 1;
            local minValue = 1;
            local maxValue = 16;
            local decimals = 0;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Slider
        do
            local name = "最大減益數量";
            local tooltip = "";
            local cfg = "AurasPersonalMaxDebuffs";
            local default = 6;
            local step = 1;
            local minValue = 1;
            local maxValue = 16;
            local decimals = 0;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "縮放大小");

        -- Slider
        do
            local name = "一般光環縮放大小";
            local tooltip = "";
            local cfg = "AurasScale";
            local default = 1.00;
            local step = 0.01;
            local minValue = 0.75;
            local maxValue = 1.25;
            local decimals = 2;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Slider
        do
            local name = "重要光環縮放大小";
            local tooltip = "";
            local cfg = "AurasImportantScale";
            local default = 1.25;
            local step = 0.01;
            local minValue = 0.75;
            local maxValue = 1.5;
            local decimals = 2;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Spacer
        func:Create_Spacer(panel);

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Important Auras
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "重要光環清單");

        -- Spacer
        func:Create_Spacer(panel);

        -- Auras List
        do
            local name = "重要光環";
            local cfg = "AurasImportantList";

            func:Create_AurasList(panel, name, cfg);
        end

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Blacklisted Auras
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "黑名單光環清單");

        -- Spacer
        func:Create_Spacer(panel);

        -- Auras List
        do
            local name = "黑名單光環";
            local cfg = "AurasBlacklist";

            func:Create_AurasList(panel, name, cfg);
        end

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Threat
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "仇恨值");

        -- Sub-Category
        func:Create_SubCategory(panel, "一般");

        -- CheckButton
        do
            local name = "仇恨百分比";
            local tooltip = "顯示產生的仇恨值";
            local cfg = "ThreatPercentage";
            local default = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and true or false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "根據仇恨值變換顏色";
            local tooltip = "仇恨值越低，顏色越淺";
            local cfg = "ThreatColorBasedOnPercentage";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "顯著標示";
            local tooltip = "根據仇恨值情況顯著標示血條";
            local cfg = "ThreatHighlight";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "獲得仇恨顏色";
            local tooltip = "怪的目標是你時的顏色";
            local cfg = "ThreatAggroColor";
            local default = {r = 1, g = 0, b = 1, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "其他坦克顏色";
            local tooltip = "其他坦克正在坦怪時的顏色";
            local cfg = "ThreatOtherTankColor";
            local default = {r = 0, g = 0.58, b = 1, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "仇恨值警告");

        -- CheckButton
        do
            local name = "啟用";
            local tooltip = "";
            local cfg = "ThreatWarning";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Slider
        do
            local name = "閾值";
            local tooltip = "";
            local cfg = "ThreatWarningThreshold";
            local default = 75;
            local step = 1;
            local minValue = 1;
            local maxValue = 100;
            local decimals = 0;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- ColorPicker
        do
            local name = "警告顏色";
            local tooltip = "";
            local cfg = "ThreatWarningColor";
            local default = {r = 1, g = 0.6, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- Spacer
        func:Create_Spacer(panel);

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Cast Bar
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "施法條");

        -- Spacer
        func:Create_Spacer(panel);

        -- CheckButton
        do
            local name = "顯示施法條";
            local tooltip = "";
            local cfg = "CastbarShow";
            local default = true;
            local flair = { classicEra = true, cata = false, retail = false };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "顯示施法條圖示";
            local tooltip = "";
            local cfg = "CastbarIconShow";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Slider
        do
            local name = "施法條縮放大小";
            local tooltip = "";
            local cfg = "CastbarScale";
            local default = 1;
            local step = 0.01;
            local minValue = 0.75;
            local maxValue = 1.25;
            local decimals = 2;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Slider
        do
            local name = "施法條位置（垂直）";
            local tooltip = "";
            local cfg = "CastbarPositionY";
            local default = 2;
            local step = 1;
            local minValue = 0;
            local maxValue = 50;
            local decimals = 0;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Spacer
        func:Create_Spacer(panel);

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Fonts
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "文字");

        -- Sub-Category
        func:Create_SubCategory(panel, "一般");

        -- CheckButton
        do
            local name = "名字和公會外框";
            local tooltip = "";
            local cfg = "NameAndGuildOutline";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "放大名字文字";
            local tooltip = "";
            local cfg = "LargeName";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "放大公會名稱文字";
            local tooltip = "";
            local cfg = "LargeGuildName";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "血量和能量");

        -- CheckButton
        do
            local name = "放大主要血量文字";
            local tooltip = "";
            local cfg = "LargeMainValue";
            local default = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and true or false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "文字顏色";
            local tooltip = "";
            local cfg = "HealthFontColor";
            local default = {r = 1, g = 0.82, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- Spacer
        func:Create_Spacer(panel);

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Border
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "邊框");

        -- Sub-Category
        func:Create_SubCategory(panel, "名條邊框顏色");

        -- ColorPicker
        do
            local name = "顏色";
            local tooltip = "";
            local cfg = "BorderColor";
            local default = {r = 0.75, g = 0.60, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "光環邊框顏色");

        -- Sub-Category
        func:Create_SubCategory(panel, "增益", nil, "small");

        -- ColorPicker
        do
            local name = "一般";
            local tooltip = "";
            local cfg = "AurasHelpfulBorderColor";
            local default = {r = 0.85, g = 0.7, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "可偷取的光環";
            local tooltip = "";
            local cfg = "AurasStealableBorderColor";
            local default = {r = 0.6, g = 0.79, b = 1, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "減益", nil, "small");

        -- ColorPicker
        do
            local name = "一般";
            local tooltip = "";
            local cfg = "Auras_HarmfulBorderColor_Regular";
            local default = {r = 0.8, g = 0, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "魔法";
            local tooltip = "";
            local cfg = "Auras_HarmfulBorderColor_Magic";
            local default = {r = 0.8, g = 0, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "詛咒";
            local tooltip = "";
            local cfg = "Auras_HarmfulBorderColor_Curse";
            local default = {r = 0.8, g = 0, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "疾病";
            local tooltip = "";
            local cfg = "Auras_HarmfulBorderColor_Disease";
            local default = {r = 0.8, g = 0, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "毒藥";
            local tooltip = "";
            local cfg = "Auras_HarmfulBorderColor_Poison";
            local default = {r = 0.8, g = 0, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "個人資源條減益", nil, "small");

        -- ColorPicker
        do
            local name = "一般";
            local tooltip = "";
            local cfg = "Auras_Personal_HarmfulBorderColor_Regular";
            local default = {r = 0.8, g = 0, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "魔法";
            local tooltip = "";
            local cfg = "Auras_Personal_HarmfulBorderColor_Magic";
            local default = {r = 0.2, g = 0.6, b = 1, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "詛咒";
            local tooltip = "";
            local cfg = "Auras_Personal_HarmfulBorderColor_Curse";
            local default = {r = 0.6, g = 0, b = 1, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "疾病";
            local tooltip = "";
            local cfg = "Auras_Personal_HarmfulBorderColor_Disease";
            local default = {r = 0.6, g = 0.4, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "毒藥";
            local tooltip = "";
            local cfg = "Auras_Personal_HarmfulBorderColor_Poison";
            local default = {r = 0, g = 0.6, b = 0, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- Spacer
        func:Create_Spacer(panel);

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Profiles
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "設定檔");

        -- Spacer
        func:Create_Spacer(panel);

        -- Auras List
        do
            local name = "設定檔";
            local cfg = "Profiles";
            local default = "預設";

            func:Create_Profiles(panel, name, cfg, default);
        end

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    ---------------------------------------
    -- Adding panels
    ---------------------------------------
    local mainCategory = Settings.RegisterCanvasLayoutCategory(panelMain, panelMain.name)
	mainCategory.ID = "ClassicPlatesPlus"

    for k, v in ipairs(data.settings.panels) do
        if k and v.name ~= panelMain.name then
            Settings.RegisterCanvasLayoutSubcategory(mainCategory, v, v.name)
        end
    end

    Settings.RegisterAddOnCategory(mainCategory)
end