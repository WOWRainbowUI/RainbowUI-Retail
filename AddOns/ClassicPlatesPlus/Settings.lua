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
    local panelMain = func:CreatePanel(nil, myAddon);

    -- CATEGORY: General
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "一般");

        -- Spacer
        func:Create_Spacer(panel);

        -- CheckButton
        do
            local name = "根據距離縮放名條大小";
            local tooltip = "隨著距離越遠，名條縮小";
            local cfg = "ScaleWithDistance";
            local default = true;
            local flair = { classicEra = false, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "放大當前目標的名條";
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
            local name = "名字與公會文字外框";
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

        -- CheckButton
        do
            local name = "NPC 類別";
            local tooltip = "怪物分類: " .. white .. "精英, 稀有, 稀有精英, 世界首領";
            local cfg = "Classification";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "任務怪標示";
            local tooltip = "怪物分類: " .. white .. "精英, 稀有, 稀有精英, 世界首領";
            local cfg = "QuestMark";
            local default = true;
            local flair = { classicEra = false, cata = false, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "陣營徽章";
            local tooltip = "";
            local cfg = "ShowFaction";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "團隊徽章";
            local tooltip = "徽章顏色: " .. purple .. "好友, " .. green .. "公會成員, " .. blue .. "隊伍成員, " .. orange .. "團隊成員";
            local cfg = "FellowshipBadge";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Slider
        do
            local name = "名條縮放大小";
            local tooltip = "必須在非戰鬥狀態下才能生效";
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
            local name = "可以看見名條的最遠距離";
            local tooltip = "必須在非戰鬥狀態下才能生效";
            local cfg = "MaxNameplateDistance";
            local default = 60;
            local step = 1;
            local minValue = 10;
            local maxValue = 60;
            local decimals = 0;
            local flair = { classicEra = false, cata = false, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- Spacer
        func:Create_Spacer(panel);

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Health & Power
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "血量 & 能量");

        -- Spacer
        func:Create_Spacer(panel);

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
            local tooltip = "調換數值和百分比的位置";
            local cfg = "PercentageAsMainValue";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

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
            local tooltip = "顯示你的最大能量\n" .. white .. "例如: " .. yellow .. "法力、怒氣、能量...\n(只會顯示於個人資源條)";
            local cfg = "PersonalNameplateTotalPower";
            local default = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and true or false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "放大主要血量文字";
            local tooltip = "";
            local cfg = "LargeMainValue";
            local default = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and true or false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
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

    -- CATEGORY: Personal Nameplate
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "個人資源條");

        -- Spacer
        func:Create_Spacer(panel);

        -- CheckButton
        do
            local name = "個人資源條";
            local tooltip = not data.isRetail and "要移動個人資源條，按住 " .. green .. "CTRL" .. yellow .. " 不放，同時使用 " .. green .. "滑鼠左鍵拖曳" or "";
            local cfg = "PersonalNameplate";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = false };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "總是顯示個人資源條";
            local tooltip = "";
            local cfg = "PersonalNameplateAlwaysShow";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };
            local cvar = "NameplatePersonalShowAlways";

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default, cvar);
        end

        -- CheckButton
        do
            local name = "特殊能量";
            local tooltip = "自製的特殊能量條: " .. white .. "圖騰" .. yellow .. "\n之後會加入更多種";
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

        -- CheckButton
        do
            local name = "個人資源條動畫效果";
            local tooltip = "";
            local cfg = "PersonalPowerBarAnimation";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "淡出個人資源條";
            local tooltip = "非戰鬥中淡出個人資源條";
            local cfg = "PersonalNameplateFade";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = false };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
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
        func:Create_Spacer(panel);

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
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "友方血量條顯示職業顏色";
            local tooltip = "";
            local cfg = "HealthBarClassColorsFriendly";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "敵方血量條顯示職業顏色";
            local tooltip = "";
            local cfg = "HealthBarClassColorsEnemy";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "友方名字 & 公會顯示職業顏色";
            local tooltip = "";
            local cfg = "FriendlyClassColorNamesAndGuild";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "敵方名字 & 公會顯示職業顏色";
            local tooltip = "";
            local cfg = "EnemyClassColorNamesAndGuild";
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

        -- Spacer
        func:Create_Spacer(panel);

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
            local name = "敵方玩家";
            local tooltip = "";
            local cfg = "NamesOnlyEnemyPlayers";
            local default = false;
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
            local name = "敵方寵物";
            local tooltip = "";
            local cfg = "NamesOnlyEnemyPets";
            local default = false;
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
            local name = "敵方 NPC";
            local tooltip = "";
            local cfg = "NamesOnlyEnemyNPC";
            local default = false;
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

        -- CheckButton
        do
            local name = "敵方圖騰";
            local tooltip = "";
            local cfg = "NamesOnlyEnemyTotems";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "排除好友";
            local tooltip = "";
            local cfg = "NamesOnlyExcludeFriends";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "排除公會成員";
            local tooltip = "";
            local cfg = "NamesOnlyExcludeGuild";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "排除小隊成員";
            local tooltip = "";
            local cfg = "NamesOnlyExcludeParty";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "排除團隊成員";
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
            local name = "施法條位置 (垂直)";
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

    -- CATEGORY: Threat
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "仇恨值");

        -- Spacer
        func:Create_Spacer(panel);

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
            local name = "依據仇恨百分比變化顏色";
            local tooltip = "仇恨愈低顏色愈淺";
            local cfg = "ThreatColorBasedOnPercentage";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "顯著標示";
            local tooltip = "依據仇恨狀態顯著標示名條";
            local cfg = "ThreatHighlight";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "獲得仇恨顏色";
            local tooltip = "";
            local cfg = "ThreatAggroColor";
            local default = {r = 1, g = 0, b = 1, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- ColorPicker
        do
            local name = "其他坦克顏色";
            local tooltip = "仇恨在另一個坦克身上時的顏色";
            local cfg = "ThreatOtherTankColor";
            local default = {r = 0, g = 0.58, b = 1, a = 1};
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_ColorPicker(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "仇恨警告");

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
            local name = "臨界點";
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

    -- CATEGORY: Buffs & Debuffs
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "增益 & 減益");

        -- Spacer
        func:Create_Spacer(panel);

        -- DropDownMenu
        do
            local name = "過濾友方身上的光環";
            local tooltip = "";
            local cfg = "AurasFilterFriendly";
            local default = 1;
            local options = {
                [1] = "顯示所有光環",
                [2] = "顯示你施放的光環",
                [3] = "顯示你能施放和驅散的光環"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- DropDownMenu
        do
            local name = "過濾敵方身上的光環";
            local tooltip = "";
            local cfg = "AurasFilterEnemy";
            local default = 1;
            local options = {
                [1] = "顯示所有光環",
                [2] = "顯示你施放的光環"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- CheckButton
        do
            local name = "只顯示重要光環";
            local tooltip = "";
            local cfg = "AurasShowOnlyImportant";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- DropDownMenu
        do
            local name = "隱藏被動光環";
            local tooltip = "隱藏沒有時間限制的光環";
            local cfg = "AurasHidePassive";
            local default = 2;
            local options = {
                [1] = "無",
                [2] = "全部",
                [3] = "全部，除了你自己的"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- CheckButton
        do
            local name = "只有當前目標顯示光環";
            local tooltip = "";
            local cfg = "AurasOnTarget";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "標示你施放的光環";
            local tooltip = "";
            local cfg = "AurasMarkYours";
            local default = false;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "倒數計時";
            local tooltip = "";
            local cfg = "AurasCountdown";
            local default = false;
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
            local name = "反轉冷卻轉圈動畫";
            local tooltip = "";
            local cfg = "AurasReverseAnimation";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "標示可偷的增益";
            local tooltip = "將可偷取的增益標示為藍色，並且排列在其他增益的前面";
            local cfg = "MarkStealableAuras";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

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

        -- CheckButton
        do
            local name = "顯示友方增益";
            local tooltip = "";
            local cfg = "BuffsFriendly";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "顯示友方減益";
            local tooltip = "";
            local cfg = "DebuffsFriendly";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "顯示敵方增益";
            local tooltip = "";
            local cfg = "BuffsEnemy";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "顯示敵方減益";
            local tooltip = "";
            local cfg = "DebuffsEnemy";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Slider
        do
            local name = "友方最多顯示幾個增益";
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
            local name = "友方最多顯示幾個減益";
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

        -- Slider
        do
            local name = "敵方最多顯示幾個增益";
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
            local name = "敵方最多顯示幾個減益";
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

        -- Slider
        do
            local name = "光環縮放大小";
            local tooltip = "";
            local cfg = "AurasScale";
            local default = 1.00
            local step = 0.01;
            local minValue = 0.75;
            local maxValue = 1.25;
            local decimals = 2;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_Slider(panel, flair, name, tooltip, cfg, default, step, minValue, maxValue, decimals);
        end

        -- CheckButton
        do
            local name = "光環溢出計數器";
            local tooltip = "";
            local cfg = "AurasOverFlowCounter";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Sub-Category
        func:Create_SubCategory(panel, "個人光環");

        -- DropDownMenu
        do
            local name = "增益過濾方式";
            local tooltip = "";
            local cfg = "BuffsFilterPersonal";
            local default = 2;
            local options = {
                [1] = "顯示所有增益",
                [2] = "顯示你施放的增益",
                [3] = "顯示你能施放和你施放的增益"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- DropDownMenu
        do
            local name = "減益過濾方式";
            local tooltip = "";
            local cfg = "DebuffsFilterPersonal";
            local default = 1;
            local options = {
                [1] = "顯示所有減益",
                [2] = "顯示你能驅散的減益"
            }
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_DropDownMenu(panel, flair, name, tooltip, cfg, default, options);
        end

        -- CheckButton
        do
            local name = "顯示增益";
            local tooltip = "";
            local cfg = "BuffsPersonal";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- CheckButton
        do
            local name = "顯示減益";
            local tooltip = "";
            local cfg = "DebuffsPersonal";
            local default = true;
            local flair = { classicEra = true, cata = true, retail = true };

            func:Create_CheckButton(panel, flair, name, tooltip, cfg, default);
        end

        -- Slider
        do
            local name = "最多顯示幾個增益";
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
            local name = "最多顯示幾個減益";
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

        -- Spacer
        func:Create_Spacer(panel);

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    -- CATEGORY: Important Auras
    do
        -- Panel
        local panel = func:CreatePanel(panelMain.name, "重要光環");

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
        local panel = func:CreatePanel(panelMain.name, "黑名單光環");

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
            local default = "預設值";

            func:Create_Profiles(panel, name, cfg, default);
        end

        -- Anchoring settings
        func:AnchorFrames(panel);
    end

    ---------------------------------------
    -- Adding panels
    ---------------------------------------
    local mainCategory = Settings.RegisterCanvasLayoutCategory(panelMain, "血條")

    for k, v in ipairs(data.settings.panels) do
        if k and v.name ~= panelMain.name then
            Settings.RegisterCanvasLayoutSubcategory(mainCategory, v, v.name)
        end
    end

    mainCategory.ID = "ClassicPlatesPlus"
	Settings.RegisterAddOnCategory(mainCategory)
end