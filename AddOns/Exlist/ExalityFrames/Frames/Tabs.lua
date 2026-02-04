local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

--- @class ExalityFramesTabsFrame
local tabs = EXFrames:GetFrame('tabs-frame')

tabs.Init = function(self)
    tabs.pool = CreateFramePool('Frame', UIParent)
end

local function CreateTabButton(parent)
    local button = CreateFrame('Button', nil, parent)
    button.ID = ''
    button:SetSize(80, 20)

    local texture = button:CreateTexture(nil, 'BACKGROUND')
    texture:SetTexture(EXFrames.assets.textures.tabs.inactive)
    texture:SetTextureSliceMargins(10, 10, 10, 10)
    texture:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
    texture:SetAllPoints()

    local text = button:CreateFontString(nil, 'OVERLAY')
    text:SetFont(EXFrames.assets.font.default(), 11, 'OUTLINE')
    text:SetPoint('CENTER', 0, -2)
    text:SetWidth(0)
    button.text = text

    button.SetActive = function(self, active)
        texture:SetTexture(
            active and
            EXFrames.assets.textures.tabs.active or
            EXFrames.assets.textures.tabs.inactive
        )
    end

    button.SetText = function(self, text)
        self.text:SetText(text)
        self:SetWidth(self.text:GetStringWidth() + 20)
    end

    button:SetScript('OnClick', function(self)
        if (self.onClick) then
            self:onClick(self.ID)
        end
    end)

    return button
end

local configure = function(frame)
    frame.tabs = {}
    frame.activeTabID = nil

    local tabBar = CreateFrame('Frame', nil, frame)
    tabBar:SetPoint('TOPLEFT', 0, 0)
    tabBar:SetPoint('TOPRIGHT', 0, 0)
    tabBar:SetHeight(30)
    frame.tabBar = tabBar

    local container = EXFrames:GetFrame('panel-frame'):Create()
    container:SetBackgroundColor(0.12, 0.12, 0.12, 0.8)
    container:SetParent(frame)
    container:SetPoint('TOPLEFT', tabBar, 'BOTTOMLEFT')
    container:SetPoint('BOTTOMRIGHT')
    frame.container = container

    frame.onTabClick = function(self, id)
        frame.activeTabID = id
        for _, tab in ipairs(frame.tabs) do
            tab:SetActive(tab.ID == id)
        end
        if (frame.onTabChange) then
            frame.onTabChange(id)
        end
    end

    frame.AddTabs = function(self, tabs)
        for _, tab in ipairs_reverse(self.tabs) do
            tab:ClearAllPoints()
        end
        local prev = nil
        for i, tab in ipairs(tabs) do
            if (not self.tabs[i]) then
                self.tabs[i] = CreateTabButton(self.tabBar)
            end
            local button = self.tabs[i]
            button.ID = tab.ID
            button:SetText(tab.label)
            button.onClick = self.onTabClick
            if (not prev) then
                button:SetPoint('BOTTOMLEFT', self.tabBar, 'BOTTOMLEFT', 20, 0)
            else
                button:SetPoint('BOTTOMLEFT', prev, 'BOTTOMRIGHT', 3, 0)
            end

            if (self.activeTabID and self.activeTabID == tab.ID) then
                button:SetActive(true)
            elseif (not self.activeTabID and not prev) then
                button:SetActive(true)
                self.activeTabID = tab.ID
            end
            prev = button
        end
    end

    frame.SetOnTabChange = function(self, callback)
        self.onTabChange = callback
    end

    frame.SetActiveTab = function(self, id)
        self.activeTabID = id
        for _, tab in ipairs(self.tabs) do
            tab:SetActive(tab.ID == id)
        end
        if (self.onTabChange) then
            self.onTabChange(id)
        end
    end

    frame.Destroy = function(self)
        self:ClearAllPoints()
        tabs.pool:Release(self)
    end

    frame.configured = true
end

---@param self ExalityFramesTabsFrame
---@return Frame
tabs.Create = function(self)
    local f = self.pool:Acquire()
    if not f.configured then
        configure(f)
    end

    f:Show()

    return f
end
