local fontMain = "Interface\\Addons\\DFFriendlyNameplates\\Media\\Fonts\\FiraMono-Medium.ttf" 
local pathToMedia = "Interface\\Addons\\DFFriendlyNameplates\\Media\\"
local backdrop = { edgeFile = pathToMedia.."Textures\\WHITE8X8.BLP", edgeSize = 1 }
local backdrop2 = { bgFile = pathToMedia.."Textures\\UI-Tooltip-Background.blp", tile = true, tileSize = 16, edgeFile = pathToMedia.."Textures\\WHITE8X8.BLP", edgeSize = 2 }

local LSM = LibStub("LibSharedMedia-3.0")

local httpsxFriendlyNamePlates = CreateFrame("Frame")
httpsxFriendlyNamePlates.hideCastBar = CreateFrame("Frame")
httpsxFriendlyNamePlates.config = {}

local function frameAddBg(frame, bd, color, border)
    frame:SetBackdrop(bd)
    frame:SetBackdropColor(unpack(color or {0,0,0,1}))
    frame:SetBackdropBorderColor(unpack(border or {1,1,1,1}))
end
local function WidgetTab_OnEnter(self)
    if (self.active ~= true) then
        self:SetBackdropColor(1, 1, 1, 0.3)
        self["BottomEdge"]:Show()
        self:SetBackdropBorderColor(1.0,0.74,0,1)  
    end
end

local function WidgetTab_OnLeave(self)
    self:SetBackdropColor(1, 1, 1, 0)
    if (self.active ~= true) then
        self["BottomEdge"]:Hide()
    end
    self:SetBackdropBorderColor(0.59,0.98,0.59,1)  
end

local function frame_OnDragStart(self)
    self:StartMoving()
end

local function frame_OnDragStop(self)
    self:StopMovingOrSizing()
end

local function EditBoxEscapePressed(self)
    self:ClearFocus()
end

local function createEditBox(frame,xSize,ySize)
    local editBox = CreateFrame("EditBox", nil, frame, 'BackdropTemplate')
    editBox:SetSize(xSize, ySize)
    editBox:SetPoint("BOTTOM", frame, 0, -ySize - 3)
    frameAddBg(editBox, backdrop2, {0,0,0,0.3}, {1,1,1,0.3})
    editBox:SetTextInsets(4, 4, 0, 0)
    editBox:SetFont(fontMain, 12, "")
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEscapePressed",EditBoxEscapePressed)
    editBox:SetScript("OnEnter",function(self) self:SetBackdropBorderColor(1.0,0.74,0, 0.5)  end)
    editBox:SetScript("OnLeave",function(self) self:SetBackdropBorderColor(1,1,1,0.3)  end)
    editBox:SetNumeric(true)
    editBox:SetJustifyH("CENTER")
    return editBox
end

local function createCheckButton(frame, x, y, text, dop)
    local checkButton = CreateFrame("CheckButton", nil, frame, "ChatConfigCheckButtonTemplate");
    checkButton:SetPoint("TOPLEFT", frame, x, y)
    checkButton:SetSize(25,25)
    checkButton.text = checkButton:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    checkButton.text:SetPoint("LEFT",  checkButton, 25, 0)
    checkButton.text:SetText(text)
    checkButton.text:SetFont(fontMain, 12, "")
    if dop then 
        checkButton.dopText = checkButton:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        checkButton.dopText:SetPoint("LEFT",  checkButton, 155, -2)
        checkButton.dopText:SetText("(Required ReloadUI)") 
        checkButton.dopText:SetFont(fontMain, 8, "")
        checkButton.dopText:SetTextColor(1, 0.31, 0.31, 1.0)
    end
    return checkButton
end

local httpsxNamePlatesSettings = CreateFrame('Frame', nil, UIParent, 'BackdropTemplate')
httpsxNamePlatesSettings:ClearAllPoints()
httpsxNamePlatesSettings:SetSize(320, 370)
httpsxNamePlatesSettings:SetPoint("CENTER")
httpsxNamePlatesSettings:EnableMouse(true)
httpsxNamePlatesSettings:SetClampedToScreen(true)
httpsxNamePlatesSettings:SetDontSavePosition(true)
httpsxNamePlatesSettings:SetMovable(true)
httpsxNamePlatesSettings:RegisterForDrag("LeftButton")
httpsxNamePlatesSettings:SetScript("OnDragStart", frame_OnDragStart)
httpsxNamePlatesSettings:SetScript("OnDragStop", frame_OnDragStop)  
httpsxNamePlatesSettings:SetScale(1)
frameAddBg(httpsxNamePlatesSettings, backdrop2, {0,0,0,0.6}, {1,1,1,0.3})
httpsxNamePlatesSettings:Hide()
_G["httpsxNamePlatesSettings"] = httpsxNamePlatesSettings
tinsert(UISpecialFrames, "httpsxNamePlatesSettings")

httpsxNamePlatesSettings.closeButton = CreateFrame('Button', nil, httpsxNamePlatesSettings, 'BackdropTemplate')
httpsxNamePlatesSettings.closeButton:ClearAllPoints()
httpsxNamePlatesSettings.closeButton:SetPoint("TOPRIGHT", httpsxNamePlatesSettings, "TOPRIGHT", 3, 3)
httpsxNamePlatesSettings.closeButton:SetSize(25, 25)
httpsxNamePlatesSettings.closeButton.texture = httpsxNamePlatesSettings.closeButton:CreateTexture("Texture", 'ARTWORK')
httpsxNamePlatesSettings.closeButton.texture:SetPoint('CENTER')
httpsxNamePlatesSettings.closeButton.texture:SetTexture(pathToMedia.."Textures\\cancel-icon.tga")
httpsxNamePlatesSettings.closeButton.texture:SetSize(15, 15)
httpsxNamePlatesSettings.closeButton.texture:SetDesaturated(1)
httpsxNamePlatesSettings.closeButton:SetScript("OnEnter", function(self) self.texture:SetDesaturated(nil) end)
httpsxNamePlatesSettings.closeButton:SetScript("OnLeave", function(self) self.texture:SetDesaturated(1) end)
httpsxNamePlatesSettings.closeButton:SetScript("OnClick", function(self) self:GetParent():Hide();httpsxNamePlatesSettings:Hide(); end)

httpsxNamePlatesSettings.VersionText =  httpsxNamePlatesSettings:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
httpsxNamePlatesSettings.VersionText:SetPoint("BOTTOM",  httpsxNamePlatesSettings, "BOTTOM", 0, 10)
httpsxNamePlatesSettings.VersionText:SetText("DF Friendly Nameplates 1.1")
httpsxNamePlatesSettings.VersionText:SetFont(fontMain, 12, "OUTLINE")

httpsxNamePlatesSettings.header = CreateFrame('Frame', nil, httpsxNamePlatesSettings, 'BackdropTemplate')
httpsxNamePlatesSettings.header:ClearAllPoints()
httpsxNamePlatesSettings.header:SetPoint("TOPLEFT", httpsxNamePlatesSettings, "TOPLEFT", 0, 0)
httpsxNamePlatesSettings.header:SetSize(320, 32)
frameAddBg(httpsxNamePlatesSettings.header, backdrop, {0,0,0,0.6}, {1,1,1,0.3})
local nfx = {"BottomLeftCorner","BottomRightCorner","LeftEdge","RightEdge","TopEdge","TopLeftCorner","TopRightCorner"}
for x=1, #nfx do
    httpsxNamePlatesSettings.header[nfx[x]]:Hide()
end

httpsxNamePlatesSettings.header.tabs = {}

local tabs = {"General","World text"}

for i=1, #tabs do 
    
    httpsxNamePlatesSettings.header.tabs[i] = CreateFrame('Button', nil, httpsxNamePlatesSettings.header, 'BackdropTemplate')
    httpsxNamePlatesSettings.header.tabs[i]:SetPoint("BOTTOMLEFT", httpsxNamePlatesSettings.header, ((i-1)*90) + ((i-1)*5) + 2, 8)
    httpsxNamePlatesSettings.header.tabs[i]:SetSize(90, 16)
    frameAddBg(httpsxNamePlatesSettings.header.tabs[i], backdrop2, {1,1,1,0}, {0.59,0.98,0.59,1})
    httpsxNamePlatesSettings.header.tabs[i]:SetScript("OnEnter", WidgetTab_OnEnter)
    httpsxNamePlatesSettings.header.tabs[i]:SetScript("OnLeave", WidgetTab_OnLeave)
    httpsxNamePlatesSettings.header.tabs[i].text = httpsxNamePlatesSettings.header.tabs[i]:CreateFontString(nil, nil, "GameFontNormal")
    httpsxNamePlatesSettings.header.tabs[i].text:SetPoint("CENTER")
    httpsxNamePlatesSettings.header.tabs[i].text:SetTextColor(1,1,1,1)
    httpsxNamePlatesSettings.header.tabs[i].text:SetText(tabs[i])
    httpsxNamePlatesSettings.header.tabs[i].text:SetJustifyH("CENTER")
    httpsxNamePlatesSettings.header.tabs[i].text:SetFont(fontMain, 10, "")
    httpsxNamePlatesSettings.header.tabs[i].active = false
    
    local nf = {"BottomLeftCorner","BottomRightCorner","LeftEdge","RightEdge","TopEdge","TopLeftCorner","TopRightCorner", "BottomEdge"}
    for x=1, #nf do
        httpsxNamePlatesSettings.header.tabs[i][nf[x]]:Hide()
    end
    
end
httpsxNamePlatesSettings.header.tabs[1].active = true 
httpsxNamePlatesSettings.header.tabs[1]["BottomEdge"]:Show()

httpsxNamePlatesSettings.contents = {}
for i=1, #tabs do
    httpsxNamePlatesSettings.contents[i] = CreateFrame('Frame', nil, httpsxNamePlatesSettings, 'BackdropTemplate') 
    httpsxNamePlatesSettings.contents[i]:ClearAllPoints()
    httpsxNamePlatesSettings.contents[i]:SetPoint("TOPLEFT", httpsxNamePlatesSettings, "TOPLEFT", 0, -32)
    httpsxNamePlatesSettings.contents[i]:SetSize(320, 338)
    frameAddBg(httpsxNamePlatesSettings.contents[i], backdrop, {1,1,1,0.6}, {1,1,1,0.3})
    httpsxNamePlatesSettings.contents[i].lines = {}
    httpsxNamePlatesSettings.contents[i].sp = 0
    httpsxNamePlatesSettings.contents[i]:Hide()
end

for i=1, #tabs do 
    httpsxNamePlatesSettings.header.tabs[i]:SetScript("OnClick",  function(self) 
            for x=1, #tabs do
                if (httpsxNamePlatesSettings.header.tabs[x].active == true) then
                    httpsxNamePlatesSettings.header.tabs[x].active = false
                    httpsxNamePlatesSettings.header.tabs[x]["BottomEdge"]:Hide()
                    httpsxNamePlatesSettings.header.tabs[x]:SetBackdropBorderColor(0.59,0.98,0.59,0)  
                    httpsxNamePlatesSettings.header.tabs[x]:SetBackdropColor(1, 1, 1, 0)
                    httpsxNamePlatesSettings.contents[x]:Hide()
                end
            end
            
            self:SetBackdropBorderColor(0.59,0.98,0.59,1)  
            self:SetBackdropColor(1, 1, 1, 0)
            httpsxNamePlatesSettings.contents[i]:Show()
            
            self.active = true 
            self["BottomEdge"]:Show()   
    end)
end

local function newLine(frame, isSpace)
    local x = #frame.lines
    
    frame.lines[x+1] = CreateFrame('Frame', nil, frame, 'BackdropTemplate')
    frame.lines[x+1]:ClearAllPoints()
    frame.lines[x+1]:SetSize(300, 25)
    frame.lines[x+1]:SetPoint("TOPLEFT", 10, -5 - (26 * (x-frame.sp))-(13 * (frame.sp)))
    if (isSpace) then
        frame.sp = frame.sp + 1
        frame.lines[x+1]:SetSize(300, 12)
    end
    --frameAddBg(frame.lines[x+1], backdrop2, {0,0,0,0.3}, {1,1,1,0.3})
    return (x+1)
end

httpsxNamePlatesSettings.contents[1]:Show()

local checkButtonSettings = {}
local checkCNamePlates = {}
local checkButtonGeneralSettings = {}
local checkButtonFontOutline = {}

local btnName = {
    {name="Enable world text names", tab=2, dop=false, space=false},
    
}

local btcNameGeneral = {
    {name="Show only name", tab=1, dop=false, space=false},
}

for i=1, #btnName  do
    local lname, ltabID, ldop, lspace = btnName[i].name, btnName[i].tab, btnName[i].dop, btnName[i].space
    if (lspace) then 
        newLine(httpsxNamePlatesSettings.contents[ltabID], true)
    end
    local lid = newLine(httpsxNamePlatesSettings.contents[ltabID], false)
    checkButtonSettings[i] = createCheckButton(httpsxNamePlatesSettings.contents[ltabID].lines[lid], 0, 0, lname, ldop)
end

for i=1, #btcNameGeneral  do
    local lname, ltabID, ldop, lspace = btcNameGeneral[i].name, btcNameGeneral[i].tab, btcNameGeneral[i].dop, btcNameGeneral[i].space
    if (lspace) then 
        newLine(httpsxNamePlatesSettings.contents[ltabID], true)
    end
    local lid = newLine(httpsxNamePlatesSettings.contents[ltabID], false)
    checkButtonGeneralSettings[i] = createCheckButton(httpsxNamePlatesSettings.contents[ltabID].lines[lid], 0, 0, lname, ldop)
end

newLine(httpsxNamePlatesSettings.contents[1], true)

newLine(httpsxNamePlatesSettings.contents[1], true)

newLine(httpsxNamePlatesSettings.contents[2], true)
newLine(httpsxNamePlatesSettings.contents[2], true)

local lid = newLine(httpsxNamePlatesSettings.contents[2], false)

local worldTextSizeSlider = CreateFrame("Slider", "SliderCFRNaddon", httpsxNamePlatesSettings.contents[2].lines[lid], "OptionsSliderTemplate");
worldTextSizeSlider:SetPoint("BOTTOMLEFT", httpsxNamePlatesSettings.contents[2].lines[lid], 75, 0)
worldTextSizeSlider:SetMinMaxValues(0, 64);
worldTextSizeSlider:SetValue(12);
worldTextSizeSlider:SetValueStep(1);
worldTextSizeSlider.tooltipText = "Default = 0"
worldTextSizeSlider:SetObeyStepOnDrag(true)
worldTextSizeSlider.disable = nil;
worldTextSizeSlider.Low:SetText(0)
worldTextSizeSlider.High:SetText(64)
worldTextSizeSlider:SetSize(150,10)
--frameAddBg(sliderScale, backdrop2, {0,0,0,0.6}, {1,1,1,0.3})
worldTextSizeSlider.textBox = worldTextSizeSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
worldTextSizeSlider.textBox:SetPoint("TOP",  worldTextSizeSlider, 0, 14)
worldTextSizeSlider.textBox:SetText("World Text Size:")
worldTextSizeSlider.textBox:SetTextColor(1.0,0.74,0,1)
local sliderWorldTextSizeEditBox = createEditBox(worldTextSizeSlider, 55, 18)
sliderWorldTextSizeEditBox:SetText(worldTextSizeSlider:GetValue())
worldTextSizeSlider:SetScript("OnValueChanged", function(self, value)
        if self.disable then
            return
        end
        sliderWorldTextSizeEditBox:SetText(string.format("%.3g", value))
        if (DFFriendlyNamePlates.WorldTextSettings[1] == false) then
            return
        end 
        DFFriendlyNamePlates.WorldTextSettings[2] = value;
        SetCVar("WorldTextMinSize", value);
end)
sliderWorldTextSizeEditBox:SetScript("OnEnterPressed", function(self)
        worldTextSizeSlider:SetValue(self:GetNumber());
        self:ClearFocus();
end)

newLine(httpsxNamePlatesSettings.contents[2], true)
newLine(httpsxNamePlatesSettings.contents[2], true)

lid = newLine(httpsxNamePlatesSettings.contents[2], false)

local worldTextMinAlphaSlider = CreateFrame("Slider", "SliderCFRNaddon2", httpsxNamePlatesSettings.contents[2].lines[lid], "OptionsSliderTemplate");
worldTextMinAlphaSlider:SetPoint("BOTTOMLEFT", httpsxNamePlatesSettings.contents[2].lines[lid], 75, 0)
worldTextMinAlphaSlider:SetMinMaxValues(0, 1);
worldTextMinAlphaSlider:SetValue(0.5);
worldTextMinAlphaSlider:SetValueStep(0.01);
worldTextMinAlphaSlider.tooltipText = "Default = 0.5"
worldTextMinAlphaSlider:SetObeyStepOnDrag(true)
worldTextMinAlphaSlider.disable = nil;
worldTextMinAlphaSlider.Low:SetText(0)
worldTextMinAlphaSlider.High:SetText(1)
worldTextMinAlphaSlider:SetSize(150,10)
--frameAddBg(sliderScale, backdrop2, {0,0,0,0.6}, {1,1,1,0.3})
worldTextMinAlphaSlider.textBox = worldTextMinAlphaSlider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
worldTextMinAlphaSlider.textBox:SetPoint("TOP",  worldTextMinAlphaSlider, 0, 14)
worldTextMinAlphaSlider.textBox:SetText("World Text Alpha:")
worldTextMinAlphaSlider.textBox:SetTextColor(1.0,0.74,0,1)
local sliderWorldTextAlphaEditBox = createEditBox(worldTextMinAlphaSlider, 55, 18)
sliderWorldTextAlphaEditBox:SetNumeric(false) 

sliderWorldTextAlphaEditBox:SetText(worldTextMinAlphaSlider:GetValue())
worldTextMinAlphaSlider:SetScript("OnValueChanged", function(self, value)
        if self.disable then
            return
        end
        sliderWorldTextAlphaEditBox:SetText(string.format("%.2f", value))
        if (DFFriendlyNamePlates.WorldTextSettings[1] == false) then
            return
        end 
        DFFriendlyNamePlates.WorldTextSettings[3] = value;
        SetCVar("WorldTextMinAlpha", value);
end)
sliderWorldTextSizeEditBox:SetScript("OnEnterPressed", function(self)
        worldTextMinAlphaSlider:SetValue(self:GetNumber());
        self:ClearFocus();
end)


local function safeForbiddenAccess(table, attributeTable, setChange)
    table[attributeTable.attribute] = setChange;
    local tableInspectorPool = CreateFramePool("FRAME", UIParent, "TableAttributeDisplayTemplate");
    local attributeDisplay = tableInspectorPool:Acquire();
    attributeDisplay:OnLoad();
    --attributeDisplay:SetTableFocusedCallback(tableFocusedCallback);
    --attributeDisplay:InspectTable(focusedTable, customTitle);
    attributeDisplay:SetPoint("LEFT", 64 + math.random(0, 64), math.random(0, 64));
    attributeDisplay:Hide();
    attributeDisplay:InspectTable(table)
    attributeDisplay.dataProviders[2].lines[3]:GetTableInspector():SetDynamicUpdates(true)
    attributeDisplay.dataProviders[2].lines[3]:GetTableInspector():SetDynamicUpdates(false)
    for i=1, #attributeDisplay.dataProviders[2].lines do
        if (attributeDisplay.dataProviders[2].lines[i].Value ~= nil) then
            if (attributeDisplay.dataProviders[2].lines[i]:GetAttributeData().type == "boolean") then
                TableAttributeDisplayEditBox_OnEnterPressed(attributeDisplay.dataProviders[2].lines[i].Value)
            end
        end
    end
    SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits",GetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits"));
end

local forbiddenNPAccess = {
    {attribute="displayName", r=1},
}

checkButtonGeneralSettings[1]:SetScript("OnClick",  function(self) 
        local setChange = self:GetChecked();
        SetCVar("nameplateshowfriendlyPlayers", "1");
        SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", setChange)
        DFFriendlyNamePlates.NamePlatesGeneralSettings[1] = setChange
        checkButtonSettings[1]:SetChecked(false);
        DFFriendlyNamePlates.WorldTextSettings[1] = false
        --safeForbiddenAccess(DefaultCompactNamePlateFrameSetUpOptions, {attribute="hideHealthbar", r=0}, setChange)
        --ReloadUI();
end)

checkButtonSettings[1]:SetScript("OnClick",  function(self) 
        local setChange = self:GetChecked();
        DFFriendlyNamePlates.WorldTextSettings[1] = setChange
        if (setChange) then
            checkButtonGeneralSettings[1]:SetChecked(false);
            DFFriendlyNamePlates.NamePlatesGeneralSettings[1] = false
            SetCVar("WorldTextMinSize", DFFriendlyNamePlates.WorldTextSettings[2]);
            SetCVar("WorldTextMinAlpha", DFFriendlyNamePlates.WorldTextSettings[3]);
            SetCVar("nameplateshowfriendlyPlayers", "0");
        else
            SetCVar("WorldTextMinSize", 0);
            SetCVar("WorldTextMinAlpha", 0.5);
            SetCVar("nameplateshowfriendlyPlayers", "1");
        end
end)


httpsxFriendlyNamePlates:RegisterEvent("PLAYER_ENTERING_WORLD")
httpsxFriendlyNamePlates:SetScript("OnEvent", function()
        
        --UIParentLoadAddOn("Blizzard_DebugTools")
        
        httpsxFriendlyNamePlates.config.default = {
            ["NamePlatesSettings"] = {
                true,
                true,
                true
            },
            ["WorldTextSettings"] = {
                false, -- [1]
                10,
                1,
            },
            ["NamePlatesGeneralSettings"] = {
                true,
            },
        }
        
        if not DFFriendlyNamePlates 
        or not DFFriendlyNamePlates.NamePlatesGeneralSettings
        or not DFFriendlyNamePlates.WorldTextSettings
        then
            local updateConfig = false
            local oldConfig = false
            local oldCname = false
            if (DFFriendlyNamePlates and DFFriendlyNamePlates.NamePlatesSettings) then oldConfig = DFFriendlyNamePlates.NamePlatesSettings end

            if (oldConfig and #oldConfig == 1) then
                updateConfig = true
            end
            DFFriendlyNamePlates = httpsxFriendlyNamePlates.config.default
            
            if (updateConfig) then
                --print("Update config 1.0 -> 1.1")
                --DFFriendlyNamePlates.NamePlatesFriendlySettings[1] = oldConfig[2]
            end
            
        end
        
        for i=1, #checkButtonGeneralSettings do
            local setChange = DFFriendlyNamePlates.NamePlatesGeneralSettings[i]; 
            checkButtonGeneralSettings[i]:SetChecked(setChange);
            if (i==1 and setChange) then
                SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnits", setChange)
                SetCVar("nameplateshowfriendlyPlayers", "1");
            end
        end

        for i=1, #checkButtonSettings do
            local setChange = DFFriendlyNamePlates.WorldTextSettings[i]; 
            checkButtonSettings[i]:SetChecked(setChange);
            if (i==1) then
                if (setChange) then
                    SetCVar("WorldTextMinSize", DFFriendlyNamePlates.WorldTextSettings[2]);
                    SetCVar("WorldTextMinAlpha", DFFriendlyNamePlates.WorldTextSettings[3]);
                    SetCVar("nameplateshowfriendlyPlayers", "0");
                else
                    SetCVar("WorldTextMinSize", 0);
                    SetCVar("WorldTextMinAlpha", 0.5);
                    SetCVar("nameplateshowfriendlyPlayers", "1");
                end
            end
        end

        worldTextMinAlphaSlider:SetValue(DFFriendlyNamePlates.WorldTextSettings[3]);
        worldTextSizeSlider:SetValue(DFFriendlyNamePlates.WorldTextSettings[2]);

        --TableAttributeDisplay safe copy
        --local tableInspectorPool = CreateFramePool("FRAME", UIParent, "TableAttributeDisplayTemplate");
        --local attributeDisplay = tableInspectorPool:Acquire();
        --attributeDisplay:OnLoad();
        --attributeDisplay:SetTableFocusedCallback(tableFocusedCallback);
        --attributeDisplay:InspectTable(focusedTable, customTitle);
        --attributeDisplay:SetPoint("LEFT", 64 + math.random(0, 64), math.random(0, 64));
        --attributeDisplay:Hide();      
        --attributeDisplay:InspectTable(DefaultCompactNamePlateFriendlyFrameOptions)
        --attributeDisplay.dataProviders[2].lines[3]:GetTableInspector():SetDynamicUpdates(true)
       -- attributeDisplay.dataProviders[2].lines[3]:GetTableInspector():SetDynamicUpdates(false)
        --for i=1, #attributeDisplay.dataProviders[2].lines do
        --    if (attributeDisplay.dataProviders[2].lines[i].Value ~= nil) then
        --       TableAttributeDisplayEditBox_OnEnterPressed(attributeDisplay.dataProviders[2].lines[i].Value)
        --    end
        --end
                
        --local needHideCastBar = DFFriendlyNamePlates.NamePlatesGeneralSettings[2];
        local needHideCastBar = false;
        if needHideCastBar then
            --httpsxFriendlyNamePlates.hideCastBar:RegisterEvent("NAME_PLATE_UNIT_ADDED")
            --httpsxFriendlyNamePlates.hideCastBar:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED")
            --httpsxFriendlyNamePlates.hideCastBar:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
            --httpsxFriendlyNamePlates.hideCastBar:RegisterEvent("FORBIDDEN_NAME_PLATE_UNIT_REMOVED")
        end
        
        httpsxFriendlyNamePlates:UnregisterEvent("PLAYER_ENTERING_WORLD"); 
end)

httpsxFriendlyNamePlates.hideCastBar:SetScript("OnEvent", function()
        for _, frame in pairs(C_NamePlate.GetNamePlates(true)) do
            if frame.template=="ForbiddenNamePlateUnitFrameTemplate" then
                frame.UnitFrame.CastBar.showCastbar = false
            else
                frame.UnitFrame.CastBar.showCastbar = true
            end
        end
end)

for i, v in pairs({"httpsxnp", "cfrn", "friendlynameplates", "dffn"}) do
    _G["SLASH_CFRN"..i] = "/"..v
end

function SlashCmdList.CFRN()
    local isShown = httpsxNamePlatesSettings:IsShown()
    httpsxNamePlatesSettings:SetShown(not isShown)
end