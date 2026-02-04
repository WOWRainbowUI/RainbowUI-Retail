local _, ns = ...
---@class ExalityFrames
local EXFrames = ns.EXFrames

---@class ExalityFramesInputGroupOptions = {name: string, children: table}

---@class ExalityFramesInputGroup
local inputGroup = EXFrames:GetFrame('input-group')

inputGroup.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
end

local function Configure(f)
    local bg = f:CreateTexture(nil, 'BACKGROUND')
    bg:SetTexture(EXFrames.assets.textures.input.buttonBg)
    bg:SetTextureSliceMargins(10, 10, 10, 10)
    bg:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
    bg:SetVertexColor(1, 1, 1, 0.2)
    bg:SetAllPoints()
    f.bg = bg

    local name = f:CreateFontString(nil, 'OVERLAY')
    name:SetFont(EXFrames.assets.font.default(), 12, 'OUTLINE')
    name:SetPoint('LEFT', f, 'TOPLEFT', 5, 0)
    name:SetWidth(0)
    f.name = name

    f.SetGroupName = function(self, name)
        self.name:SetText(name)
    end

    f.PopulateChildren = function(self)
        local prev = nil
        local width = 0
        local height = 10
        local frameLevel = self:GetFrameLevel()
        local frameStrata = self:GetFrameStrata()
        for _, child in pairs(self.children) do
            child:ClearAllPoints()
            if (prev) then
                child:SetPoint('TOPLEFT', prev, 'BOTTOMLEFT', 0, -10)
            else
                child:SetPoint('TOPLEFT', self, 'TOPLEFT', 10, -20)
            end
            child:SetFrameStrata(frameStrata)
            child:SetFrameLevel(frameLevel + 5)
            if (child:GetWidth() > width) then
                width = child:GetWidth()
                widestChild = child
            end
            height = height + child:GetHeight() + 10
            prev = child
        end
        f:SetSize(width + 20, height + 10)
    end

    f.configured = true
end

---Create Input Group
---@param self ExalityFramesInputGroup
---@param options ExalityFramesInputGroupOptions
---@param parent Frame
---@return Frame
inputGroup.Create = function(self, options, parent)
    local f = self.pool:Acquire()
    if (not f.configured) then
        Configure(f)
    end

    if (parent) then
        f:SetParent(parent)
    end

    f:SetGroupName(options.name)
    f.children = options.children
    f:PopulateChildren()
    f:Show();

    return f
end
