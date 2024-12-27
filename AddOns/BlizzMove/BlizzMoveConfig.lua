-- up-value the globals
local _G = getfenv(0);
local LibStub = _G.LibStub;
local pairs = _G.pairs;
local GetAddOnMetadata = _G.GetAddOnMetadata or _G.C_AddOns.GetAddOnMetadata;
local ReloadUI = _G.ReloadUI;
local string__match = _G.string.match;
local StaticPopupDialogs = _G.StaticPopupDialogs;
local StaticPopup_Show = _G.StaticPopup_Show;
local IsControlKeyDown = _G.IsControlKeyDown;

local name = ... or "BlizzMove";
---@class BlizzMove
local BlizzMove = LibStub("AceAddon-3.0"):GetAddon(name);
if not BlizzMove then return; end

---@type BlizzMoveAPI
local BlizzMoveAPI = _G.BlizzMoveAPI;

---@class BlizzMoveConfig
local Config = {};
BlizzMove.Config = Config;

Config.version = GetAddOnMetadata(name, "Version") or "unknown";

function Config:GetOptions()
    local count = 1;
    local function increment() count = count + 1; return count end;
    return {
        type = "group",
        childGroups = "tab",
		name = "移動暴雪視窗",
        args = {
            version = {
                order = increment(),
                type = "description",
                name = "版本: " .. self.version
            },
            mainTab = {
                order = increment(),
                name = "說明",
                type = "group",
                args = {
                    description = {
                        order = increment(),
                        type = "description",
                        name = [[
這個插件讓遊戲內建的視窗可以移動。

要暫時移動窗口，只需左鍵點擊視窗並將其拖動到你希望的位置，這個位置會在這次登入期間中保持。

按住 CTRL 並滾動滑鼠滾輪可以調整視窗的縮放比例。

按住 ALT 並左鍵拖曳可分離的子視窗會將其從父視窗中分離出來。 分離後的視窗可以獨立於父視窗移動和調整大小。

重置視窗：
  SHIFT + 右鍵重置位置。
  CTRL + 右鍵重置視窗縮放大小。
  ALT + 右鍵重新附加子視窗。

插件作者可以通過使用 BlizzMoveAPI 函數來支援他們自己的自訂視窗。
]],
                    },
                    plugins = {
                        order = increment(),
                        type = "execute",
                        name = "搜尋外掛套件",
                        func = function() Config:ShowURLPopup("https://www.curseforge.com/wow/addons/search?search=BlizzMove+plugin"); end,
                    },
                },
            },
            fullFramesTab = {
                order = increment(),
                name = "框架清單",
                type = "group",
                childGroups = "tree",
                get = function(info, frameName) return not BlizzMoveAPI:IsFrameDisabled(info[#info], frameName); end,
                set = function(info, frameName, enabled) return BlizzMoveAPI:SetFrameDisabled(info[#info], frameName, not enabled); end,
                args = self.ListOfFramesTable,
            },
            disabledFramesTab = {
                order = increment(),
                name = "預設停用的框架",
                type = "group",
                childGroups = "tree",
                get = function(info, frameName) return not BlizzMoveAPI:IsFrameDisabled(info[#info], frameName); end,
                set = function(info, frameName, enabled) return BlizzMoveAPI:SetFrameDisabled(info[#info], frameName, not enabled); end,
                args = self.DefaultDisabledFramesTable,
            },
            globalConfigTab = {
                order = increment(),
                name = "整體設定",
                type = "group",
                get = function(info) return Config:GetConfig(info[#info]); end,
                set = function(info, value) return Config:SetConfig(info[#info], value); end,
                args = {
                    requireMoveModifier = {
                        order = increment(),
                        name = "按輔助鍵才能移動",
                        desc = "啟用時，需要按住 Shift 鍵才能移動視窗。",
                        type = "toggle",
                    },
                    newline1 = {
                        order = increment(),
                        type = "description",
                        name = "",
                    },
                    savePosStrategy = {
                        order = increment(),
                        width = 1.5,
                        name = "是否要記憶視窗位置?",
                        desc = [[不要記憶 >> 關閉和重新打開視窗時都會重置位置

登入期間 >> 會保存視窗位置，直到重新載入介面後會重置

永久保存 >> 會一直保存視窗位置，直到你移動到其他位置、按下重置按鈕或停用此插件。]],
                        type = "select",
                        values = {
                            off = "不要記憶",
                            session = "登入期間，直到重新載入介面",
                            permanent = "永久保存",
                        },
                    },
                    saveScaleStrategy = {
                        order = increment(),
                        width = 1.5,
                        name = "是否要記憶視窗縮放大小?",
                        desc = [[登入期間 >> 會保存視窗縮放大小，直到重新載入介面後會重置

永久保存 >> 會一直保存視窗縮放大小，直到你調整縮放、按下重置按鈕或停用此插件。]],
                        type = "select",
                        values = {
                            session = "登入期間，直到重新載入介面",
                            permanent = "永久保存",
                        },
                    },
                    newline2 = {
                        order = increment(),
                        type = "description",
                        name = "",
                    },
                    resetPositions = {
                        order = increment(),
                        width = 1.5,
                        name = "重置位置",
                        desc = "重置永久保存的位置",
                        type = "execute",
                        func = function() BlizzMove:ResetPointStorage(); ReloadUI(); end,
                        confirm = function() return "是否確定要重置永久保存的位置? 將會重新載入介面。" end,
                    },
                    resetScales = {
                        order = increment(),
                        width = 1.5,
                        name = "重置縮放大小",
                        desc = "重置永久保存的縮放大小",
                        type = "execute",
                        func = function() BlizzMove:ResetScaleStorage(); ReloadUI(); end,
                        confirm = function() return "是否確定要重置永久保存的縮放大小? 將會重新載入介面。" end,
                    },
                },
            },
        },
    }
end

function Config:GetFramesTables()
    local listOfFrames = {};
    local defaultDisabledFrames = {};
    local addonOrder = function(info)
        if info[#info] == name then return 10; end
        if string__match(info[#info], "Blizzard_") then return 30; end
        return 20;
    end;

    local allFrames = {
        ["0"] = {
            name = "過濾方式",
            type = "input",
            desc = "搜尋框架名稱，或 '-' 是已停用的框架，或 '+' 是已啟用的框架。",
            order = 1,
            get = function() return self.search; end,
            set = function(_, value) self.search = value; end
        },
        ["1"] = {
            name = "清空",
            type = "execute",
            desc = "清空搜尋過濾方式。",
            order = 2,
            func = function() self.search = ""; end,
            width = 0.5,
        },
    }
    listOfFrames["0"] = {
        name = "所有框架",
        type = "group",
        order = 1,
        args = allFrames,
    };

    for addOnName, _ in pairs(BlizzMoveAPI:GetRegisteredAddOns()) do
        listOfFrames[addOnName] = {
            name = addOnName,
            type = "group",
            order = addonOrder,
            args = {
                [addOnName] = {
                    name = addOnName .. " 可移動的框架",
                    type = "multiselect",
                    values = function(info) return BlizzMoveAPI:GetRegisteredFrames(info[#info]); end,
                },
            },
        };
        allFrames[addOnName] = {
            name = addOnName .. " 可移動的框架",
            type = "multiselect",
            order = addonOrder,
            values = function(info) return self:GetFilteredFrames(info[#info], self.search); end,
            hidden = function(info) return not next(info.option.values(info)); end,
        }
        for frameName, _ in pairs(BlizzMoveAPI:GetRegisteredFrames(addOnName)) do
            if(BlizzMoveAPI:IsFrameDefaultDisabled(addOnName, frameName)) then
                defaultDisabledFrames[addOnName] = {
                    name = addOnName,
                    type = "group",
                    order = addonOrder,
                    args = {
                        [addOnName] = {
                            name = addOnName .. " 可移動的框架",
                            type = "multiselect",
                            values = function(info) return self:GetDefaultDisabledFrames(info[#info]); end,
                        },
                    },
                };
                break;
            end
        end
    end

    return listOfFrames, defaultDisabledFrames;
end

function Config:GetFilteredFrames(addOnName, filter)
    local frames = {};
    for frameName, _ in pairs(BlizzMoveAPI:GetRegisteredFrames(addOnName)) do
        if (
            not filter or filter == ''
            or (filter == '-' and BlizzMoveAPI:IsFrameDisabled(addOnName, frameName))
            or (filter == '+' and not BlizzMoveAPI:IsFrameDisabled(addOnName, frameName))
            or (string__match(string.lower(frameName), string.lower(filter)))
            or (string__match(string.lower(addOnName), string.lower(filter)))
        ) then
            frames[frameName] = frameName;
        end
    end
    return frames;
end

function Config:GetDefaultDisabledFrames(addOnName)
    local returnTable = {};

    for frameName, _ in pairs(BlizzMoveAPI:GetRegisteredFrames(addOnName)) do
        if(BlizzMoveAPI:IsFrameDefaultDisabled(addOnName, frameName)) then
            returnTable[frameName] = frameName;
        end
    end

    return returnTable;
end

function Config:Initialize()
    self.search = "";
    self:RegisterOptions();
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BlizzMove", "移動視窗");

    StaticPopupDialogs["BlizzMoveURLDialog"] = {
        text = "按 CTRL+C 複製",
        button1 = "關閉",
        OnShow = function(dialog, data)
            local function HidePopup()
                dialog:Hide();
            end
            dialog.editBox:SetScript("OnEscapePressed", HidePopup);
            dialog.editBox:SetScript("OnEnterPressed", HidePopup);
            dialog.editBox:SetScript("OnKeyUp", function(_, key)
                if IsControlKeyDown() and key == "C" then
                    HidePopup();
                end
            end);
            dialog.editBox:SetMaxLetters(0);
            dialog.editBox:SetText(data);
            dialog.editBox:HighlightText();
        end,
        hasEditBox = true,
        editBoxWidth = 240,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    };
end

function Config:RegisterOptions()
    self.ListOfFramesTable, self.DefaultDisabledFramesTable = self:GetFramesTables();
    LibStub("AceConfig-3.0"):RegisterOptionsTable("BlizzMove", self:GetOptions());
end

function Config:GetConfig(property)
    return BlizzMove.DB[property];
end

function Config:SetConfig(property, value)
    local oldValue = BlizzMove.DB[property] or nil;
    BlizzMove.DB[property] = value;
    if property == "savePosStrategy" then
        BlizzMove:SavePositionStrategyChanged(oldValue, value);
    end
end

function Config:ShowURLPopup(url)
    StaticPopup_Show("BlizzMoveURLDialog", _, _, url);
end