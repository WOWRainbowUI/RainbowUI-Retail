--[[
Written by: Simca@Malfurion-US

Thanks to Hugh@Burning-Blade, a co-author for the first few versions of the AddOn.

Special thanks to Ro for inspiration for the overall structure of this options panel (and the title/version/description code)
]]--

--GLOBALS: BPBID_Options

--[[
(BPBID_Options.format) CHANGING TEXT BLURB BELOW FORMAT DROPDOWN MENU

Show BreedIDs in the Name line...
BPBID_Options.Names.PrimaryBattle: In Battle (on primary pets for both owners)
BPBID_Options.Names.BattleTooltip: In PrimaryBattlePetUnitTooltip's header (in-battle tooltips)
BPBID_Options.Names.BPT: In BattlePetTooltip's header (items)
BPBID_Options.Names.FBPT: In FloatingBattlePetTooltip's header (chat links)
BPBID_Options.Names.HSFUpdate: In the Pet Journal scrolling frame
    BPBID_Options.Names.HSFUpdateRarity: Color Pet Journal scrolling frame by rarity
BPBID_Options.Names.PJT: In the Pet Journal tooltips
    BPBID_Options.Names.PJTRarity: Color Pet Journal tooltip headers by rarity

BPBID_Options.Tooltips.Enabled: Enable Battle Pet BreedID Tooltips
Show Battle Pet BreedID Tooltips...
BPBID_Options.Tooltips.BattleTooltip: In Battle (PrimaryBattlePetUnitTooltip)
BPBID_Options.Tooltips.BPT: On Items (BattlePetTooltip)
BPBID_Options.Tooltips.FBPT: On Chat Links (FloatingBattlePetTooltip)
BPBID_Options.Tooltips.PJT: In the Pet Journal (GameTooltip)

In Tooltips, show...
BPBID_Options.Breedtip.Current: Current pet's breed
BPBID_Options.Breedtip.Possible: Current pet's possible breeds
BPBID_Options.Breedtip.SpeciesBase: Pet species' base stats
BPBID_Options.Breedtip.CurrentStats: Current breed's base stats (level 1 Poor)
BPBID_Options.Breedtip.AllStats: All breed's base stats (level 1 Poor)
BPBID_Options.Breedtip.CurrentStats25: Current breed's stats at level 25
    BPBID_Options.Breedtip.CurrentStats25Rare: Always assume pet will be Rare at level 25
BPBID_Options.Breedtip.AllStats25: All breeds' stats at level 25
    BPBID_Options.Breedtip.AllStats25Rare: Always assume pet will be Rare at level 25
--]]

-- Get folder path and set addon namespace
local addonname, internal = ...

-- Create options panel
local Options = CreateFrame("Frame")
local properName = "戰寵-品級"

-- Variable for easy positioning
local lastcheckbox

-- Ro's CreateFont function for easy FontString creation
local function CreateFont(fontName, r, g, b, anchorPoint, relativeTo, relativePoint, cx, cy, xoff, yoff, text)
    local font = Options:CreateFontString(nil, "BACKGROUND", fontName)
    font:SetJustifyH("LEFT")
    font:SetJustifyV("TOP")
    if type(r) == "string" then -- R is text, no positioning
        text = r
    else
        if r then
            font:SetTextColor(r, g, b, 1)
        end
        font:SetSize(cx, cy)
        font:SetPoint(anchorPoint, relativeTo, relativePoint, xoff, yoff)
    end
    font:SetText(text)
    return font
end

-- My CreateCheckbox function for easy Checkbox creation (going to need lots and lots)
local function CreateCheckbox(text, height, width, anchorPoint, relativeTo, relativePoint, xoff, yoff, font)
    local checkbox = CreateFrame("CheckButton", nil, Options, "UICheckButtonTemplate")
    checkbox:SetPoint(anchorPoint, relativeTo, relativePoint, xoff, yoff)
    checkbox:SetSize(height, width)
    local realfont = font or "GameFontNormal"
    checkbox.text:SetFontObject(realfont)
    checkbox.text:SetText(" " .. text)
    lastcheckbox = checkbox
    return checkbox
end

-- Similar function for buttons
local function CreateButton(text, height, width, anchorPoint, relativeTo, relativePoint, xoff, yoff)
    local button = CreateFrame("Button", nil, Options, "UIPanelButtonTemplate")
    button:SetPoint(anchorPoint, relativeTo, relativePoint, xoff, yoff)
    button:SetSize(height, width)
    button:SetText(text)
    return button
end

-- Create title, version, author, and description fields
local title = CreateFont("GameFontNormalLarge", "戰寵品級提示")
title:SetPoint("TOPLEFT", 16, -16)
local ver = CreateFont("GameFontNormalSmall", C_AddOns.GetAddOnMetadata(addonname, "Version"))
ver:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 4, 0)
local auth = CreateFont("GameFontNormalSmall", "作者: "..C_AddOns.GetAddOnMetadata(addonname, "Author"))
auth:SetPoint("BOTTOMLEFT", ver, "BOTTOMRIGHT", 3, 0)
local desc = CreateFont("GameFontHighlight", nil, nil, nil, "TOPLEFT", title, "BOTTOMLEFT", 580, 40, 0, -8, "在寵物日誌、對戰、聊天視窗連結和拍賣場的滑鼠提示中顯示戰寵的屬性品級資訊。")

-- Create dropdownmenu
if not BPBID_OptionsFormatMenu then
    CreateFrame("Button", "BPBID_OptionsFormatMenu", Options, "UIDropDownMenuTemplate")
end

-- Set dropdownmenu location
BPBID_OptionsFormatMenu:ClearAllPoints()
BPBID_OptionsFormatMenu:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 16, -8)
BPBID_OptionsFormatMenu:Show()

-- Create array for dropdownmenu
local formats = {
    "數字 (3)",
    "雙數字 (3/13)",
    "文字 (B/B)",
}

-- Create array for text blurb
local formatTexts = {
    "數字系統原本是由暴雪開發人員所建立，僅供內部使用 (透過 Web API 被發現)，也因此相當的武斷 (為何是從 3 開始?)，但這是起初所能獲得的全部資訊。然而，有些人已經透過數字學會了這個系統，還有少數較舊的資源和插件也會使用。",
    "和數字相同，主要提供給想要辨別寵物性別的玩家使用。公的寵物使用較前面的數字 (3 - 12)，母的寵物使用第二組數字 (13 - 22)。請記得，不是所有寵物都有兩種性別，例如所有 (?) 元素類型的寵物清一色都是公的。",
    "單字系統是為了能夠快速辨識寵物之間不同品級而發展出來的。每個單字都代表著這個品級的主要構成屬性，例如 速/速 (#5) 是純速度的品級，速/平 (#11) 是一半速度和一半其他3種屬性平衡的組合，血/攻 (#7) 是一半血量和一半攻擊強度。",
}

-- Create text blurb explaining format choices
local FormatTextBlurb = CreateFont("GameFontNormal", nil, nil, nil, "TOPLEFT", BPBID_OptionsFormatMenu, "TOPRIGHT" , 350, 100, 16, 24, formatTexts[tempformat])
FormatTextBlurb:SetTextColor(1, 1, 1, 1)



-- OnClick function for dropdownmenu
local function BPBID_OptionsFormatMenu_OnClick(self, arg1, arg2, checked)
    -- Update temp variable
    BPBID_Options.format = arg1
    
    -- Update dropdownmenu text
    UIDropDownMenu_SetText(BPBID_OptionsFormatMenu, formats[BPBID_Options.format])
    
    -- Update text blurb to the new choice
    FormatTextBlurb:SetText(formatTexts[BPBID_Options.format])
end

-- Initialization function for dropdownmenu
local function BPBID_OptionsFormatMenu_Initialize(self, level)
    local info = UIDropDownMenu_CreateInfo()
    info = UIDropDownMenu_CreateInfo()
    info.func = BPBID_OptionsFormatMenu_OnClick
    info.arg1, info.text = 1, formats[1]
    UIDropDownMenu_AddButton(info)
    info.arg1, info.text = 2, formats[2]
    UIDropDownMenu_AddButton(info)
    info.arg1, info.text = 3, formats[3]
    UIDropDownMenu_AddButton(info)
end

-- Final setup for dropdownmenu
UIDropDownMenu_Initialize(BPBID_OptionsFormatMenu, BPBID_OptionsFormatMenu_Initialize)
UIDropDownMenu_SetWidth(BPBID_OptionsFormatMenu, 148);
UIDropDownMenu_SetButtonWidth(BPBID_OptionsFormatMenu, 124)
UIDropDownMenu_SetText(BPBID_OptionsFormatMenu, formats[tempformat])
UIDropDownMenu_JustifyText(BPBID_OptionsFormatMenu, "LEFT")

-- Set on top of colored region
local nameTitle = CreateFont("GameFontNormal", "名字旁顯示品級於...")
nameTitle:SetPoint("TOPLEFT", BPBID_OptionsFormatMenu, "BOTTOMLEFT", -8, -16)
nameTitle:SetTextColor(1, 1, 1, 1)

-- Make Names checkboxes
local OptNamesPrimaryBattle = CreateCheckbox("對戰中 (在主要的寵物)", 32, 32, "TOPLEFT", nameTitle, "BOTTOMLEFT", 0, 0)
local OptNamesBattleTooltip = CreateCheckbox("對戰中的滑鼠提示", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptNamesBPT = CreateCheckbox("物品滑鼠提示", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptNamesFBPT = CreateCheckbox("聊天視窗連結的滑鼠提示", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptNamesHSFUpdate = CreateCheckbox("寵物日誌可捲動的視窗", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptNamesHSFUpdateRarity = CreateCheckbox("顯示稀有程度顏色", 16, 16, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 32, 0, "GameFontNormalSmall")
local OptNamesPJT = CreateCheckbox("寵物日誌說明滑鼠提示", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", -32, 0)
local OptNamesPJTRarity = CreateCheckbox("顯示稀有程度顏色", 16, 16, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 32, 0, "GameFontNormalSmall")

-- Above the Tooltips region's title (this checkbox disables the rest of them)
local OptTooltipsEnabled = CreateCheckbox("啟用戰寵品級滑鼠提示", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", -32, -16)

-- Text above the Tooltips region
local tooltipsTitle = CreateFont("GameFontNormal", "顯示戰寵品級滑鼠提示於...")
tooltipsTitle:SetPoint("TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, -2)
tooltipsTitle:SetTextColor(1, 1, 1, 1)

-- Make Tooltips checkboxes
local OptTooltipsBattleTooltip = CreateCheckbox("對戰中", 32, 32, "TOPLEFT", tooltipsTitle, "BOTTOMLEFT", 0, 0)
local OptTooltipsBPT = CreateCheckbox("物品", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptTooltipsFBPT = CreateCheckbox("聊天視窗連結", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptTooltipsPJT = CreateCheckbox("寵物日誌", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)

-- Text above the Tooltips region
local breedtipTitle = CreateFont("GameFontNormal", "滑鼠提示中要顯示...")
breedtipTitle:SetPoint("TOP", FormatTextBlurb, "BOTTOM", -48, -8)
breedtipTitle:SetTextColor(1, 1, 1, 1)

-- Make Breedtip checkboxes
local OptBreedtipCurrent = CreateCheckbox("當前寵物的品級", 32, 32, "TOPLEFT", breedtipTitle, "BOTTOMLEFT", 0, 0)
local OptBreedtipPossible = CreateCheckbox("當前寵物潛力品級", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptBreedtipCollected = CreateCheckbox("當前寵物已有品級", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptBreedtipSpeciesBase = CreateCheckbox("寵物種類的基本屬性", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptBreedtipCurrentStats = CreateCheckbox("目前品級的基本屬性", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptBreedtipAllStats = CreateCheckbox("所有品級的基本屬性", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptBreedtipCurrentStats25 = CreateCheckbox("目前品級在25級時的屬性", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, 0)
local OptBreedtipCurrentStats25Rare = CreateCheckbox("總是假設寵物在25級時是稀有", 16, 16, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 32, 0, "GameFontNormalSmall")
local OptBreedtipAllStats25 = CreateCheckbox("所有品級在25級時的屬性", 32, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", -32, 0)
local OptBreedtipAllStats25Rare = CreateCheckbox("總是假設寵物在25級時是稀有", 16, 16, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 32, 0, "GameFontNormalSmall")

-- Text above the BlizzBug region
local blizzbugTitle = CreateFont("GameFontNormal", "修正Bug:") -- Used to say "Fix Blizzard Bugs:"
blizzbugTitle:SetPoint("TOPLEFT", OptBreedtipAllStats25Rare, "BOTTOMLEFT", -32, -16)
blizzbugTitle:SetTextColor(1, 1, 1, 1)

local OptDefaultButton = CreateButton("恢復預設", 80, 32, "TOPLEFT", lastcheckbox, "BOTTOMLEFT", 0, -32)

-- Refresh all settings from storage
local function BPBID_Options_Refresh()
    -- Reset the dropdownmenu to the old value
    UIDropDownMenu_SetText(BPBID_OptionsFormatMenu, formats[BPBID_Options.format])
    
    -- Reset the text blurb to the old value
    FormatTextBlurb:SetText(formatTexts[BPBID_Options.format])
    
    -- Reset all the checkboxes to the old value
    OptNamesPrimaryBattle:SetChecked(BPBID_Options.Names.PrimaryBattle)
    OptNamesBattleTooltip:SetChecked(BPBID_Options.Names.BattleTooltip)
    OptNamesBPT:SetChecked(BPBID_Options.Names.BPT)
    OptNamesFBPT:SetChecked(BPBID_Options.Names.FBPT)
    OptNamesHSFUpdate:SetChecked(BPBID_Options.Names.HSFUpdate)
    OptNamesHSFUpdateRarity:SetChecked(BPBID_Options.Names.HSFUpdateRarity)
    OptNamesPJT:SetChecked(BPBID_Options.Names.PJT)
    OptNamesPJTRarity:SetChecked(BPBID_Options.Names.PJTRarity)
    OptTooltipsEnabled:SetChecked(BPBID_Options.Tooltips.Enabled)
    OptTooltipsBattleTooltip:SetChecked(BPBID_Options.Tooltips.BattleTooltip)
    OptTooltipsBPT:SetChecked(BPBID_Options.Tooltips.BPT)
    OptTooltipsFBPT:SetChecked(BPBID_Options.Tooltips.FBPT)
    OptTooltipsPJT:SetChecked(BPBID_Options.Tooltips.PJT)
    OptBreedtipCurrent:SetChecked(BPBID_Options.Breedtip.Current)
    OptBreedtipPossible:SetChecked(BPBID_Options.Breedtip.Possible)
    OptBreedtipSpeciesBase:SetChecked(BPBID_Options.Breedtip.SpeciesBase)
    OptBreedtipCurrentStats:SetChecked(BPBID_Options.Breedtip.CurrentStats)
    OptBreedtipAllStats:SetChecked(BPBID_Options.Breedtip.AllStats)
    OptBreedtipCurrentStats25:SetChecked(BPBID_Options.Breedtip.CurrentStats25)
    OptBreedtipCurrentStats25Rare:SetChecked(BPBID_Options.Breedtip.CurrentStats25Rare)
    OptBreedtipAllStats25:SetChecked(BPBID_Options.Breedtip.AllStats25)
    OptBreedtipAllStats25Rare:SetChecked(BPBID_Options.Breedtip.AllStats25Rare)
    OptBreedtipCollected:SetChecked(BPBID_Options.Breedtip.Collected)

    -- Enable/disable dependent checkboxes
    if (OptNamesHSFUpdate:GetChecked()) then
        OptNamesHSFUpdateRarity:Enable()
    elseif (not OptNamesHSFUpdate:GetChecked()) then
        OptNamesHSFUpdateRarity:Disable()
    end
    if (OptNamesPJT:GetChecked()) then
        OptNamesPJTRarity:Enable()
    elseif (not OptNamesPJT:GetChecked()) then
        OptNamesPJTRarity:Disable()
    end
    if (OptTooltipsEnabled:GetChecked()) then
        OptTooltipsBattleTooltip:Enable()
        OptTooltipsBPT:Enable()
        OptTooltipsFBPT:Enable()
        OptTooltipsPJT:Enable()
        OptBreedtipCurrent:Enable()
        OptBreedtipPossible:Enable()
        OptBreedtipSpeciesBase:Enable()
        OptBreedtipCurrentStats:Enable()
        OptBreedtipAllStats:Enable()
        OptBreedtipCurrentStats25:Enable()
        OptBreedtipCurrentStats25Rare:Enable()
        OptBreedtipAllStats25:Enable()
        OptBreedtipAllStats25Rare:Enable()
        OptBreedtipCollected:Enable()
    elseif (not OptTooltipsEnabled:GetChecked()) then
        OptTooltipsBattleTooltip:Disable()
        OptTooltipsBPT:Disable()
        OptTooltipsFBPT:Disable()
        OptTooltipsPJT:Disable()
        OptBreedtipCurrent:Disable()
        OptBreedtipPossible:Disable()
        OptBreedtipSpeciesBase:Disable()
        OptBreedtipCurrentStats:Disable()
        OptBreedtipAllStats:Disable()
        OptBreedtipCurrentStats25:Disable()
        OptBreedtipCurrentStats25Rare:Disable()
        OptBreedtipAllStats25:Disable()
        OptBreedtipAllStats25Rare:Disable()
        OptBreedtipCollected:Disable()
    end

    if (OptBreedtipCurrentStats25:GetChecked()) then
        OptBreedtipCurrentStats25Rare:Enable()
    elseif (not OptBreedtipCurrentStats25:GetChecked()) then
        OptBreedtipCurrentStats25Rare:Disable()
    end

    if (OptBreedtipAllStats25:GetChecked()) then
        OptBreedtipAllStats25Rare:Enable()
    elseif (not OptBreedtipAllStats25:GetChecked()) then
        OptBreedtipAllStats25Rare:Disable()
    end
end

-- Enable/disable dependent checkboxes
local function BPBID_OptNamesHSFUpdate_OnClick(self, button, down)
    
    -- Change value of dependent checkbox accordingly (default sub-checkbox to true)
    if (OptNamesHSFUpdate:GetChecked()) then
        BPBID_Options.Names.HSFUpdate = true
        BPBID_Options.Names.HSFUpdateRarity = true
    elseif (not OptNamesHSFUpdate:GetChecked()) then
        BPBID_Options.Names.HSFUpdate = false
        BPBID_Options.Names.HSFUpdateRarity = false
    end
    
    -- A manual change has occurred (added in v1.0.8 to help update values added in new versions)
    BPBID_Options.ManualChange = C_AddOns.GetAddOnMetadata(addonname, "Version")
    
    -- Refresh the options page to display the new values
    BPBID_Options_Refresh()
end
local function BPBID_OptNamesPJT_OnClick(self, button, down)
    
    -- Change value of dependent checkbox accordingly (default sub-checkbox to false)
    if (OptNamesPJT:GetChecked()) then
        BPBID_Options.Names.PJT = true
        BPBID_Options.Names.PJTRarity = false
    elseif (not OptNamesPJT:GetChecked()) then
        BPBID_Options.Names.PJT = false
        BPBID_Options.Names.PJTRarity = false
    end
    
    -- A manual change has occurred (added in v1.0.8 to help update values added in new versions)
    BPBID_Options.ManualChange = C_AddOns.GetAddOnMetadata(addonname, "Version")
    
    -- Refresh the options page to display the new values
    BPBID_Options_Refresh()
end
local function BPBID_OptBreedtipCurrentStats25_OnClick(self, button, down)
    
    -- Change value of dependent checkbox accordingly (default sub-checkbox to true)
    if (OptBreedtipCurrentStats25:GetChecked()) then
        BPBID_Options.Breedtip.CurrentStats25 = true
        BPBID_Options.Breedtip.CurrentStats25Rare = true
    elseif (not OptBreedtipCurrentStats25:GetChecked()) then
        BPBID_Options.Breedtip.CurrentStats25 = false
        BPBID_Options.Breedtip.CurrentStats25Rare = false
    end
    
    -- A manual change has occurred (added in v1.0.8 to help update values added in new versions)
    BPBID_Options.ManualChange = C_AddOns.GetAddOnMetadata(addonname, "Version")
    
    -- Refresh the options page to display the new values
    BPBID_Options_Refresh()
end
local function BPBID_OptBreedtipAllStats25_OnClick(self, button, down)
    
    -- Change value of dependent checkbox accordingly (default sub-checkbox to true)
    if (OptBreedtipAllStats25:GetChecked()) then
        BPBID_Options.Breedtip.AllStats25 = true
        BPBID_Options.Breedtip.AllStats25Rare = true
    elseif (not OptBreedtipAllStats25:GetChecked()) then
        BPBID_Options.Breedtip.AllStats25 = false
        BPBID_Options.Breedtip.AllStats25Rare = false
    end
    
    -- A manual change has occurred (added in v1.0.8 to help update values added in new versions)
    BPBID_Options.ManualChange = C_AddOns.GetAddOnMetadata(addonname, "Version")
    
    -- Refresh the options page to display the new values
    BPBID_Options_Refresh()
end

-- Disable dependent checkboxes if unchecked
local function BPBID_OptTooltipsEnabled_OnClick(self, button, down)
    
    -- If the checkbox is checked
    if (OptTooltipsEnabled:GetChecked()) then
        
        -- Enable all tooltip-related checkboxes
        OptTooltipsBattleTooltip:Enable()
        OptTooltipsBPT:Enable()
        OptTooltipsFBPT:Enable()
        OptTooltipsPJT:Enable()
        OptBreedtipCurrent:Enable()
        OptBreedtipPossible:Enable()
        OptBreedtipSpeciesBase:Enable()
        OptBreedtipCurrentStats:Enable()
        OptBreedtipAllStats:Enable()
        OptBreedtipCurrentStats25:Enable()
        OptBreedtipCurrentStats25Rare:Enable()
        OptBreedtipAllStats25:Enable()
        OptBreedtipAllStats25Rare:Enable()
        OptBreedtipCollected:Enable()
        
        -- Restore defaults for previously disabled checkboxes
        BPBID_Options.Tooltips.Enabled = true -- Enable Battle Pet BreedID Tooltips
        BPBID_Options.Tooltips.BattleTooltip = true -- In Battle (PrimaryBattlePetUnitTooltip)
        BPBID_Options.Tooltips.BPT = true -- On Items (BattlePetTooltip)
        BPBID_Options.Tooltips.FBPT = true -- On Chat Links (FloatingBattlePetTooltip)
        BPBID_Options.Tooltips.PJT = true -- In the Pet Journal (GameTooltip)
        BPBID_Options.Breedtip.Current = true -- Current pet's breed
        BPBID_Options.Breedtip.Possible = true -- Current pet's possible breeds
        BPBID_Options.Breedtip.SpeciesBase = false -- Pet species' base stats
        BPBID_Options.Breedtip.CurrentStats = false -- Current breed's base stats (level 1 Poor)
        BPBID_Options.Breedtip.AllStats = false -- All breed's base stats (level 1 Poor)
        BPBID_Options.Breedtip.CurrentStats25 = true -- Current breed's stats at level 25
        BPBID_Options.Breedtip.CurrentStats25Rare = true -- Always assume pet will be Rare at level 25
        BPBID_Options.Breedtip.AllStats25 = true -- All breeds' stats at level 25
        BPBID_Options.Breedtip.AllStats25Rare = true -- Always assume pet will be Rare at level 25
        
    elseif (not OptTooltipsEnabled:GetChecked()) then
        
        -- Disable any tooltip-related checkboxes
        OptTooltipsBattleTooltip:Disable()
        OptTooltipsBPT:Disable()
        OptTooltipsFBPT:Disable()
        OptTooltipsPJT:Disable()
        OptBreedtipCurrent:Disable()
        OptBreedtipPossible:Disable()
        OptBreedtipSpeciesBase:Disable()
        OptBreedtipCurrentStats:Disable()
        OptBreedtipAllStats:Disable()
        OptBreedtipCurrentStats25:Disable()
        OptBreedtipCurrentStats25Rare:Disable()
        OptBreedtipAllStats25:Disable()
        OptBreedtipAllStats25Rare:Disable()
        OptBreedtipCollected:Disable()
        
        -- Uncheck all tooltip-related checkboxes
        BPBID_Options.Tooltips.Enabled = false -- Enable Battle Pet BreedID Tooltips
        BPBID_Options.Tooltips.BattleTooltip = false -- In Battle (PrimaryBattlePetUnitTooltip)
        BPBID_Options.Tooltips.BPT = false -- On Items (BattlePetTooltip)
        BPBID_Options.Tooltips.FBPT = false -- On Chat Links (FloatingBattlePetTooltip)
        BPBID_Options.Tooltips.PJT = false -- In the Pet Journal (GameTooltip)
        BPBID_Options.Breedtip.Current = false -- Current pet's breed
        BPBID_Options.Breedtip.Possible = false -- Current pet's possible breeds
        BPBID_Options.Breedtip.SpeciesBase = false -- Pet species' base stats
        BPBID_Options.Breedtip.CurrentStats = false -- Current breed's base stats (level 1 Poor)
        BPBID_Options.Breedtip.AllStats = false -- All breed's base stats (level 1 Poor)
        BPBID_Options.Breedtip.CurrentStats25 = false -- Current breed's stats at level 25
        BPBID_Options.Breedtip.CurrentStats25Rare = false -- Always assume pet will be Rare at level 25
        BPBID_Options.Breedtip.AllStats25 = false -- All breeds' stats at level 25
        BPBID_Options.Breedtip.AllStats25Rare = false -- Always assume pet will be Rare at level 25
    end
    
    -- A manual change has occurred (added in v1.0.8 to help update values added in new versions)
    BPBID_Options.ManualChange = C_AddOns.GetAddOnMetadata(addonname, "Version")
    
    -- Refresh the options page to display the new values
    BPBID_Options_Refresh()
end

local function BPBID_Options_EnableAll()
    OptNamesHSFUpdateRarity:Enable()
    OptNamesPJTRarity:Enable()
    OptTooltipsBattleTooltip:Enable()
    OptTooltipsBPT:Enable()
    OptTooltipsFBPT:Enable()
    OptTooltipsPJT:Enable()
    OptBreedtipCurrent:Enable()
    OptBreedtipPossible:Enable()
    OptBreedtipSpeciesBase:Enable()
    OptBreedtipCurrentStats:Enable()
    OptBreedtipAllStats:Enable()
    OptBreedtipCurrentStats25:Enable()
    OptBreedtipCurrentStats25Rare:Enable()
    OptBreedtipAllStats25:Enable()
    OptBreedtipAllStats25Rare:Enable()
    OptBreedtipCollected:Enable()
end

local function BPBID_Options_Default()
    
    BPBID_Options = {}

    BPBID_Options.format = 3

    BPBID_Options.Names = {}
    BPBID_Options.Names.PrimaryBattle = true -- In Battle (on primary pets for both owners)
    BPBID_Options.Names.BattleTooltip = true -- In PrimaryBattlePetUnitTooltip's header (in-battle tooltips)
    BPBID_Options.Names.BPT = true -- In BattlePetTooltip's header (items)
    BPBID_Options.Names.FBPT = true -- In FloatingBattlePetTooltip's header (chat links)
    BPBID_Options.Names.HSFUpdate = true -- In the Pet Journal scrolling frame
    BPBID_Options.Names.HSFUpdateRarity = true -- Color Pet Journal scrolling frame entries by rarity
    BPBID_Options.Names.PJT = true -- In the Pet Journal tooltip header
    BPBID_Options.Names.PJTRarity = false -- Color Pet Journal tooltip headers by rarity

    BPBID_Options.Tooltips = {}
    BPBID_Options.Tooltips.Enabled = true -- Enable Battle Pet BreedID Tooltips
    BPBID_Options.Tooltips.BattleTooltip = true -- In Battle (PrimaryBattlePetUnitTooltip)
    BPBID_Options.Tooltips.BPT = true -- On Items (BattlePetTooltip)
    BPBID_Options.Tooltips.FBPT = true -- On Chat Links (FloatingBattlePetTooltip)
    BPBID_Options.Tooltips.PJT = true -- In the Pet Journal (GameTooltip)

    BPBID_Options.Breedtip = {}
    BPBID_Options.Breedtip.Current = true -- Current pet's breed
    BPBID_Options.Breedtip.Possible = true -- Current pet's possible breeds
    BPBID_Options.Breedtip.SpeciesBase = false -- Pet species' base stats
    BPBID_Options.Breedtip.CurrentStats = false -- Current breed's base stats (level 1 Poor)
    BPBID_Options.Breedtip.AllStats = false -- All breed's base stats (level 1 Poor)
    BPBID_Options.Breedtip.CurrentStats25 = true -- Current breed's stats at level 25
    BPBID_Options.Breedtip.CurrentStats25Rare = true -- Always assume pet will be Rare at level 25
    BPBID_Options.Breedtip.AllStats25 = true -- All breeds' stats at level 25
    BPBID_Options.Breedtip.AllStats25Rare = true -- Always assume pet will be Rare at level 25

    -- Enable all checkboxes that can be enabled (defaults would enable them)
    BPBID_Options_EnableAll()
    
    -- Refresh the options page to display the new defaults
    BPBID_Options_Refresh()
end

local function BPBID_GeneralCheckbox_OnClick(self, button, down)
    -- IF THE LAST TOOLTIP CALLED BEFORE THE OPTIONS ARE CHANGED HAS CHANGED FONT,
    -- BAD STUFF WILL HAPPEN SO CALL ORIGINAL FONT CHANGING FUNCTIONS HERE
    
    -- Retrieve the rest of the settings from the checkboxes
    BPBID_Options.Names.PrimaryBattle = OptNamesPrimaryBattle:GetChecked()
    BPBID_Options.Names.BattleTooltip = OptNamesBattleTooltip:GetChecked()
    BPBID_Options.Names.BPT = OptNamesBPT:GetChecked()
    BPBID_Options.Names.FBPT = OptNamesFBPT:GetChecked()
    BPBID_Options.Names.HSFUpdate = OptNamesHSFUpdate:GetChecked()
    BPBID_Options.Names.HSFUpdateRarity = OptNamesHSFUpdateRarity:GetChecked()
    BPBID_Options.Names.PJT = OptNamesPJT:GetChecked()
    BPBID_Options.Names.PJTRarity = OptNamesPJTRarity:GetChecked()
    BPBID_Options.Tooltips.Enabled = OptTooltipsEnabled:GetChecked()
    BPBID_Options.Tooltips.BattleTooltip = OptTooltipsBattleTooltip:GetChecked()
    BPBID_Options.Tooltips.BPT = OptTooltipsBPT:GetChecked()
    BPBID_Options.Tooltips.FBPT = OptTooltipsFBPT:GetChecked()
    BPBID_Options.Tooltips.PJT = OptTooltipsPJT:GetChecked()
    BPBID_Options.Breedtip.Current = OptBreedtipCurrent:GetChecked()
    BPBID_Options.Breedtip.Possible = OptBreedtipPossible:GetChecked()
    BPBID_Options.Breedtip.SpeciesBase = OptBreedtipSpeciesBase:GetChecked()
    BPBID_Options.Breedtip.CurrentStats = OptBreedtipCurrentStats:GetChecked()
    BPBID_Options.Breedtip.AllStats = OptBreedtipAllStats:GetChecked()
    BPBID_Options.Breedtip.CurrentStats25 = OptBreedtipCurrentStats25:GetChecked()
    BPBID_Options.Breedtip.CurrentStats25Rare = OptBreedtipCurrentStats25Rare:GetChecked()
    BPBID_Options.Breedtip.AllStats25 = OptBreedtipAllStats25:GetChecked()
    BPBID_Options.Breedtip.AllStats25Rare = OptBreedtipAllStats25Rare:GetChecked()
    BPBID_Options.Breedtip.Collected = OptBreedtipCollected:GetChecked()
    
    -- Fix fontsize for PrimaryBattlePetUnitTooltip (TODO: PetFrame)
    if (not BPBID_Options.Names.BattleTooltip) and (internal.BattleFontSize) then
        PetBattlePrimaryUnitTooltip.Name:SetFont(internal.BattleFontSize[1], internal.BattleFontSize[2], internal.BattleFontSize[3])
    end
    
    -- Reset fontsize for BattlePetTooltip if original font size known
    if (not BPBID_Options.Names.BPT) and (internal.BPTFontSize) then
        BattlePetTooltip.Name:SetFont(internal.BPTFontSize[1], internal.BPTFontSize[2], internal.BPTFontSize[3])
    end
    
    -- Fix width for FloatingBattlePetTooltip
    if (not BPBID_Options.Names.FBPT) then
        FloatingBattlePetTooltip:SetWidth(260)
        FloatingBattlePetTooltip.Name:SetWidth(238)
        FloatingBattlePetTooltip.BattlePet:SetWidth(238)
        FloatingBattlePetTooltip.PetType:SetPoint("TOP", FloatingBattlePetTooltip.Name, "BOTTOM", 0, -5)
        FloatingBattlePetTooltip.Level:SetWidth(238)
        FloatingBattlePetTooltip.Delimiter:SetWidth(251)
        FloatingBattlePetTooltip.JournalClick:SetWidth(238)
    end
    
    -- A manual change has occurred (added in v1.0.8 to help update values added in new versions)
    BPBID_Options.ManualChange = C_AddOns.GetAddOnMetadata(addonname, "Version")
    
    -- Refresh the options page to display the new defaults
    BPBID_Options_Refresh()
end

-- Refresh on show
Options:SetScript("OnShow", BPBID_Options_Refresh)

-- Enable/disable dependent checkboxes
OptNamesHSFUpdate:SetScript("OnClick", BPBID_OptNamesHSFUpdate_OnClick)
OptNamesPJT:SetScript("OnClick", BPBID_OptNamesPJT_OnClick)
OptTooltipsEnabled:SetScript("OnClick", BPBID_OptTooltipsEnabled_OnClick)
OptBreedtipCurrentStats25:SetScript("OnClick", BPBID_OptBreedtipCurrentStats25_OnClick)
OptBreedtipAllStats25:SetScript("OnClick", BPBID_OptBreedtipAllStats25_OnClick)

-- Toggle settings
OptNamesPrimaryBattle:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptNamesBattleTooltip:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptNamesBPT:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptNamesFBPT:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptNamesHSFUpdateRarity:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptNamesPJTRarity:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptTooltipsBattleTooltip:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptTooltipsBPT:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptTooltipsFBPT:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptTooltipsPJT:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptBreedtipCurrent:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptBreedtipPossible:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptBreedtipSpeciesBase:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptBreedtipCurrentStats:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptBreedtipAllStats:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptBreedtipCurrentStats25Rare:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptBreedtipAllStats25Rare:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)
OptBreedtipCollected:SetScript("OnClick", BPBID_GeneralCheckbox_OnClick)

-- Reset to Defaults button
OptDefaultButton:SetScript("OnClick", BPBID_Options_Default)

-- Set up required functions on frame
Options.OnCommit = BPBID_GeneralCheckbox_OnClick
Options.OnDefault = BPBID_Options_Default
Options.OnRefresh = BPBID_Options_Refresh

-- Add the options panel to the Blizzard list
local category = Settings.RegisterCanvasLayoutCategory(Options, properName, properName)
category.ID = addonname
Settings.RegisterAddOnCategory(category)
