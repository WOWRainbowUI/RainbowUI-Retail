local _, lv = ...

local ROW_HEIGHT = 34
local ICON_SIZE = 22
local TRAIT_SYSTEM_ID = 48
local TRAIT_TREE_ID = 1186
local NODE_SIZE = 40
local NODE_GAP = 10
local FLYOUT_PADDING = 8
local COMMIT_TIMEOUT = 1.5

local folioView
local dashboardFolioFrame
local selectionFlyout
local ShowSelectionChoices
local folioEventFrame
local pendingCommitConfigID
local pendingCommitToken = 0

local function GetFolioLabel()
    return _G.RUNES_OF_POWER or "Omnium Folio"
end

local function GetCharacterDisplayName(charKey)
    return (charKey and charKey:match("^([^-]+)")) or charKey or UNKNOWN
end

local function FormatFolioStatusText()
    if pendingCommitConfigID then
        return "Committing Folio changes..."
    end
    if InCombatLockdown and InCombatLockdown() then
        return "Folio changes are unavailable in combat."
    end
    return "Left-click to purchase. Right-click to refund. Selection nodes open a choice flyout."
end

local function CreateActionButton(parent, width, label)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, 24)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    btn.Text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.Text:SetPoint("CENTER")
    btn.Text:SetText(label)
    return btn
end

local function SortNodesByPosition(a, b)
    local ay = tonumber(a.posY) or 0
    local by = tonumber(b.posY) or 0
    if ay ~= by then
        return ay < by
    end

    local ax = tonumber(a.posX) or 0
    local bx = tonumber(b.posX) or 0
    if ax ~= bx then
        return ax < bx
    end

    return (tonumber(a.nodeID) or 0) < (tonumber(b.nodeID) or 0)
end

local function OpenNativeFolio()
    if InCombatLockdown and InCombatLockdown() then
        return false
    end

    local function ShowLandingPage()
        local page = _G.ExpansionLandingPage
        if not page then
            return false
        end

        if _G.ShowUIPanel then
            pcall(_G.ShowUIPanel, page)
        elseif page.Show then
            pcall(page.Show, page)
        end

        if page.ShowTraitTab then
            local ok = pcall(page.ShowTraitTab, page)
            if ok then
                return true
            end
        end

        return page.IsShown and page:IsShown() or true
    end

    if ShowLandingPage() then
        return true
    end

    if _G.UIParentLoadAddOn then
        pcall(_G.UIParentLoadAddOn, "Blizzard_ExpansionLandingPage")
        if ShowLandingPage() then
            return true
        end
    end

    local landingButton = _G.ExpansionLandingPageMinimapButton
    if landingButton and landingButton.Click then
        pcall(landingButton.Click, landingButton)
        return ShowLandingPage()
    end

    return false
end

local function HasTreeOnConfig(configInfo, treeID)
    if type(configInfo) ~= "table" or type(configInfo.treeIDs) ~= "table" then
        return false
    end

    for _, configTreeID in ipairs(configInfo.treeIDs) do
        if configTreeID == treeID then
            return true
        end
    end

    return false
end

local function GetActiveConfigID()
    if not (C_Traits and C_Traits.GetConfigIDBySystemID) then
        return nil
    end
    local configID = C_Traits.GetConfigIDBySystemID(TRAIT_SYSTEM_ID)
    if configID and configID > 0 then
        return configID
    end
    return nil
end

local function GetActiveFolioConfig()
    if not (C_Traits and C_Traits.GetConfigInfo and C_Traits.GetTreeNodes and C_Traits.GetNodeInfo) then
        return nil, "Omnium Folio is unavailable on this client."
    end

    local configID = GetActiveConfigID()
    if not configID then
        return nil, "No active Omnium Folio config was found."
    end

    local configInfo = C_Traits.GetConfigInfo(configID)
    if not configInfo or not HasTreeOnConfig(configInfo, TRAIT_TREE_ID) then
        return nil, "The current character does not have an active Omnium Folio tree."
    end

    local nodeIDs = C_Traits.GetTreeNodes(TRAIT_TREE_ID)
    if type(nodeIDs) ~= "table" or #nodeIDs == 0 then
        return nil, "No Omnium Folio nodes were found."
    end

    return {
        configID = configID,
        configInfo = configInfo,
        nodeIDs = nodeIDs,
    }
end

local function GetTreeCurrencyQuantity(configID, treeID)
    if not (C_Traits and C_Traits.GetTreeCurrencyInfo) then
        return 0
    end

    local treeCurrencies = C_Traits.GetTreeCurrencyInfo(configID, treeID, false)
    local info = treeCurrencies and treeCurrencies[1]
    return tonumber(info and info.quantity) or 0
end

local function GetNodeRank(nodeInfo)
    local activeRank = nodeInfo and nodeInfo.activeEntry and tonumber(nodeInfo.activeEntry.rank) or nil
    if activeRank and activeRank > 0 then
        return activeRank
    end

    return tonumber(nodeInfo and (nodeInfo.currentRank or nodeInfo.ranksPurchased) or 0) or 0
end

local function GetCommittedEntryID(nodeInfo)
    if type(nodeInfo) == "table" and type(nodeInfo.entryIDsWithCommittedRanks) == "table" then
        local committedEntry = nodeInfo.entryIDsWithCommittedRanks[1]
        if type(committedEntry) == "table" then
            return committedEntry.entryID
        end
        return committedEntry
    end
    return nil
end

local function GetStagedEntryID(nodeInfo)
    if type(nodeInfo) ~= "table" or type(nodeInfo.entryIDToRanksIncreased) ~= "table" then
        return nil
    end

    for entryID, rankIncreased in pairs(nodeInfo.entryIDToRanksIncreased) do
        if tonumber(rankIncreased) and tonumber(rankIncreased) > 0 then
            return entryID
        end
    end

    return nil
end

local function ResolveNodeDisplayEntryID(nodeInfo)
    return GetCommittedEntryID(nodeInfo)
        or (nodeInfo and nodeInfo.activeEntry and nodeInfo.activeEntry.entryID)
        or GetStagedEntryID(nodeInfo)
        or (type(nodeInfo and nodeInfo.entryIDs) == "table" and nodeInfo.entryIDs[1])
end

local function ResolveSpellNameAndIcon(spellID)
    local spellName, spellIcon
    if spellID then
        if C_Spell and C_Spell.GetSpellName then
            spellName = C_Spell.GetSpellName(spellID)
        elseif GetSpellInfo then
            spellName = GetSpellInfo(spellID)
        end

        if C_Spell and C_Spell.GetSpellTexture then
            spellIcon = C_Spell.GetSpellTexture(spellID)
        elseif GetSpellTexture then
            spellIcon = GetSpellTexture(spellID)
        end
    end

    return spellName, spellIcon
end

local function ResolveEntryPresentation(configID, entryID, fallbackNodeID)
    local entryInfo = C_Traits.GetEntryInfo and entryID and C_Traits.GetEntryInfo(configID, entryID) or nil
    local definitionInfo = entryInfo and entryInfo.definitionID and C_Traits.GetDefinitionInfo and C_Traits.GetDefinitionInfo(entryInfo.definitionID) or nil
    local spellID = definitionInfo and definitionInfo.spellID or nil
    local spellName, spellIcon = ResolveSpellNameAndIcon(spellID)

    return {
        entryInfo = entryInfo,
        definitionInfo = definitionInfo,
        spellID = spellID,
        name = spellName or (definitionInfo and definitionInfo.overrideName) or string.format("Node %d", tonumber(fallbackNodeID) or 0),
        icon = (definitionInfo and (definitionInfo.overrideIcon or definitionInfo.icon)) or spellIcon or "Interface\\Icons\\INV_Misc_QuestionMark",
        maxRanks = tonumber(entryInfo and entryInfo.maxRanks) or 0,
    }
end

local function CanAffordNode(configID, treeID, nodeID)
    if not (configID and treeID and nodeID and C_Traits and C_Traits.GetTreeCurrencyInfo and C_Traits.GetNodeCost) then
        return true
    end

    local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configID, treeID, false)
    local costs = C_Traits.GetNodeCost(configID, nodeID)
    local idToCost = {}

    if costs and treeCurrencyInfo then
        for _, cost in ipairs(costs) do
            idToCost[cost.ID] = cost.amount
        end
    else
        return true
    end

    local idToAmount = {}
    for _, info in ipairs(treeCurrencyInfo) do
        idToAmount[info.traitCurrencyID] = info.quantity
    end

    for id, required in pairs(idToCost) do
        if (not idToAmount[id]) or (idToAmount[id] < required) then
            return false
        end
    end

    return true
end

local function CanPurchaseNode(configID, treeID, nodeID, nodeInfo)
    if not nodeInfo or not nodeInfo.canPurchaseRank then
        return false
    end

    if not CanAffordNode(configID, treeID, nodeID) then
        return false
    end

    if not (C_Traits and C_Traits.CanPurchaseRank) then
        return true
    end

    if type(nodeInfo.entryIDs) ~= "table" then
        return true
    end

    for _, entryID in ipairs(nodeInfo.entryIDs) do
        local ok, canPurchase = pcall(C_Traits.CanPurchaseRank, configID, nodeID, entryID)
        if ok and canPurchase then
            return true
        end
    end

    return false
end

local function BuildLiveFolioState()
    local configState, reason = GetActiveFolioConfig()
    if not configState then
        return nil, reason
    end

    local configID = configState.configID
    local nodes = {}
    local selectedNodes = {}
    local spentPoints = 0

    for _, nodeID in ipairs(configState.nodeIDs) do
        local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID)
        if nodeInfo then
            local displayEntryID = ResolveNodeDisplayEntryID(nodeInfo)
            local presentation = ResolveEntryPresentation(configID, displayEntryID, nodeID)
            local currentRank = GetNodeRank(nodeInfo)
            local committedEntryID = GetCommittedEntryID(nodeInfo)
            local activeEntryID = nodeInfo.activeEntry and nodeInfo.activeEntry.entryID or nil
            local isSelection = nodeInfo.type == ((Enum and Enum.TraitNodeType and Enum.TraitNodeType.Selection) or 2)

            local nodeData = {
                configID = configID,
                treeID = TRAIT_TREE_ID,
                nodeID = nodeID,
                posX = nodeInfo.posX,
                posY = nodeInfo.posY,
                nodeInfo = nodeInfo,
                entryIDs = nodeInfo.entryIDs,
                displayEntryID = displayEntryID,
                committedEntryID = committedEntryID,
                activeEntryID = activeEntryID,
                currentRank = currentRank,
                ranksPurchased = tonumber(nodeInfo.ranksPurchased) or 0,
                name = presentation.name,
                icon = presentation.icon,
                spellID = presentation.spellID,
                maxRanks = presentation.maxRanks,
                isSelection = isSelection,
                canPurchase = CanPurchaseNode(configID, TRAIT_TREE_ID, nodeID, nodeInfo),
                canRefund = not not nodeInfo.canRefundRank,
            }

            nodeData.isSelected = (nodeData.currentRank > 0) or (nodeData.committedEntryID ~= nil) or ((nodeInfo.activeEntry and tonumber(nodeInfo.activeEntry.rank)) or 0) > 0

            nodes[#nodes + 1] = nodeData
            if nodeData.isSelected then
                selectedNodes[#selectedNodes + 1] = nodeData
                spentPoints = spentPoints + math.max(0, nodeData.currentRank)
            end
        end
    end

    table.sort(nodes, SortNodesByPosition)
    table.sort(selectedNodes, SortNodesByPosition)

    return {
        configID = configID,
        treeID = TRAIT_TREE_ID,
        availablePoints = GetTreeCurrencyQuantity(configID, TRAIT_TREE_ID),
        spentPoints = spentPoints,
        selectedNodeCount = #selectedNodes,
        totalNodeCount = #nodes,
        nodes = nodes,
        selectedNodes = selectedNodes,
    }
end

local function ApplyFolioViewTheme(frame, theme)
    if not frame or not theme then
        return
    end

    frame:SetBackdropColor(unpack(theme.backgroundTransparent or theme.background))
    frame:SetBackdropBorderColor(unpack(theme.borderPrimary))

    if frame.title then
        frame.title:SetTextColor(unpack(theme.textGold or theme.textPrimary))
    end
    if frame.charLabel then
        frame.charLabel:SetTextColor(unpack(theme.textPrimary))
    end
    if frame.pointsText then
        frame.pointsText:SetTextColor(unpack(theme.textPrimary))
    end
    if frame.progressText then
        frame.progressText:SetTextColor(unpack(theme.textPrimary))
    end
    if frame.updatedText then
        frame.updatedText:SetTextColor(unpack(theme.textMuted or theme.textSecondary))
    end
    if frame.noteText then
        frame.noteText:SetTextColor(unpack(theme.textMuted or theme.textSecondary))
    end
    if frame.emptyText then
        frame.emptyText:SetTextColor(unpack(theme.textSecondary))
    end
end

local function ApplyFolioButtonTheme(btn, theme)
    if not btn or not theme then
        return
    end

    local enabled = not btn.IsEnabled or btn:IsEnabled()
    btn:SetBackdropColor(unpack(theme.buttonBgAlt or theme.buttonBg))
    btn:SetBackdropBorderColor(unpack(theme.borderPrimary))
    if btn.Text then
        btn.Text:SetTextColor(unpack(enabled and theme.textPrimary or theme.textSecondary))
    end
    btn:SetAlpha(enabled and 1 or 0.55)
end

local function ApplyFolioRowTheme(row, theme)
    if not row or not theme then
        return
    end

    local bg = row.altRow and (theme.buttonBgAlt or theme.buttonBg) or (theme.backgroundSolid or theme.background)
    row:SetBackdropColor(bg[1], bg[2], bg[3], 0.5)
    row:SetBackdropBorderColor(unpack(theme.borderPrimary))
    row.nameText:SetTextColor(unpack(theme.textPrimary))
    row.rankText:SetTextColor(unpack(theme.textSecondary))
end

local function ApplyFolioScrollBarTheme(scrollBar, theme)
    if not scrollBar or not theme then
        return
    end

    local thumb = scrollBar.ThumbTexture or scrollBar.thumbTexture
    if not thumb and scrollBar.GetThumbTexture then
        thumb = scrollBar:GetThumbTexture()
    end
    if thumb and thumb.SetVertexColor then
        thumb:SetVertexColor(unpack(theme.borderPrimary))
    end

    local track = scrollBar.TrackBG or scrollBar.BG or scrollBar.Background
    if track and track.SetVertexColor then
        track:SetVertexColor(unpack(theme.backgroundAlt or theme.background))
    end

    local function ThemeScrollButton(button)
        if not button then
            return
        end

        local normalTexture = button.GetNormalTexture and button:GetNormalTexture() or nil
        local pushedTexture = button.GetPushedTexture and button:GetPushedTexture() or nil
        local disabledTexture = button.GetDisabledTexture and button:GetDisabledTexture() or nil
        local highlightTexture = button.GetHighlightTexture and button:GetHighlightTexture() or nil

        if normalTexture and normalTexture.SetVertexColor then
            normalTexture:SetVertexColor(unpack(theme.textSecondary))
        end
        if pushedTexture and pushedTexture.SetVertexColor then
            pushedTexture:SetVertexColor(unpack(theme.textPrimary))
        end
        if disabledTexture and disabledTexture.SetVertexColor then
            disabledTexture:SetVertexColor(unpack(theme.textMuted or theme.textSecondary))
        end
        if highlightTexture and highlightTexture.SetVertexColor then
            highlightTexture:SetVertexColor(unpack(theme.textPrimary))
        end
    end

    ThemeScrollButton(scrollBar.ScrollUpButton or scrollBar.UpButton)
    ThemeScrollButton(scrollBar.ScrollDownButton or scrollBar.DownButton)
end

local function EnsureFolioRows(view, count)
    view.rows = view.rows or {}
    for index = #view.rows + 1, count do
        local row = CreateFrame("Frame", nil, view.scrollChild, "BackdropTemplate")
        row:SetHeight(ROW_HEIGHT)
        row:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 10,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(ICON_SIZE, ICON_SIZE)
        row.icon:SetPoint("LEFT", 8, 0)
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        row.nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.nameText:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
        row.nameText:SetPoint("RIGHT", -82, 0)
        row.nameText:SetJustifyH("LEFT")

        row.rankText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        row.rankText:SetPoint("RIGHT", -10, 0)
        row.rankText:SetWidth(72)
        row.rankText:SetJustifyH("RIGHT")

        view.rows[index] = row
    end
end

local function RefreshRowLayout(view, count)
    for index, row in ipairs(view.rows or {}) do
        row:ClearAllPoints()
        row.altRow = (index % 2 == 0)
        if index <= count then
            row:SetPoint("TOPLEFT", 0, -((index - 1) * (ROW_HEIGHT + 4)))
            row:SetPoint("RIGHT", -4, 0)
            row:Show()
        else
            row:Hide()
        end
    end

    local totalHeight = math.max(1, count * (ROW_HEIGHT + 4))
    view.scrollChild:SetHeight(totalHeight)
    view.scrollFrame:SetVerticalScroll(0)
end

local function HideSelectionFlyout()
    if selectionFlyout then
        selectionFlyout.closeToken = (selectionFlyout.closeToken or 0) + 1
        selectionFlyout:Hide()
        selectionFlyout.owner = nil
    end
end

local function CancelPendingSelectionFlyoutClose()
    if selectionFlyout then
        selectionFlyout.closeToken = (selectionFlyout.closeToken or 0) + 1
    end
end

local function QueueSelectionFlyoutHideIfUnhovered()
    if not selectionFlyout then
        return
    end

    selectionFlyout.closeToken = (selectionFlyout.closeToken or 0) + 1
    local scheduledToken = selectionFlyout.closeToken

    local function CheckAndHide()
        if not selectionFlyout or scheduledToken ~= selectionFlyout.closeToken then
            return
        end
        if not selectionFlyout or not selectionFlyout:IsShown() then
            return
        end

        local flyoutHovered = selectionFlyout.IsMouseOver and selectionFlyout:IsMouseOver()
        local ownerHovered = selectionFlyout.owner and selectionFlyout.owner.IsMouseOver and selectionFlyout.owner:IsMouseOver()
        local childHovered = false
        for _, button in ipairs(selectionFlyout.buttons or {}) do
            if button:IsShown() and button.IsMouseOver and button:IsMouseOver() then
                childHovered = true
                break
            end
        end

        if not flyoutHovered and not ownerHovered and not childHovered then
            HideSelectionFlyout()
        end
    end

    if C_Timer and C_Timer.After then
        C_Timer.After(0.12, CheckAndHide)
    else
        CheckAndHide()
    end
end

local function IsCommitPending(configID)
    return pendingCommitConfigID and (not configID or pendingCommitConfigID == configID)
end

local function ReleaseCommitLock()
    pendingCommitConfigID = nil
end

local function ShowTraitTooltip(owner, nodeData, entryID, rank)
    if not owner or not nodeData or not GameTooltip then
        return
    end

    local function GetTooltipLineColor(lineColor, fallbackR, fallbackG, fallbackB)
        if type(lineColor) == "table" then
            if lineColor.GetRGBA then
                local r, g, b = lineColor:GetRGBA()
                if r and g and b then
                    return r, g, b
                end
            end

            local r = lineColor.r or lineColor.red
            local g = lineColor.g or lineColor.green
            local b = lineColor.b or lineColor.blue
            if r and g and b then
                return r, g, b
            end
        end

        return fallbackR, fallbackG, fallbackB
    end

    local function TrimTooltipText(text)
        if type(text) ~= "string" then
            return ""
        end
        return (text:gsub("^%s+", ""):gsub("%s+$", ""))
    end

    local function BuildTraitEntryTooltip(tooltip, titleText, tooltipEntryID, tooltipRank)
        if not (C_TooltipInfo and C_TooltipInfo.GetTraitEntry and tooltipEntryID) then
            return false
        end

        local ok, tooltipInfo = pcall(C_TooltipInfo.GetTraitEntry, tooltipEntryID, tooltipRank)
        if not ok or type(tooltipInfo) ~= "table" then
            return false
        end

        if TooltipUtil and type(TooltipUtil.SurfaceArgs) == "function" then
            pcall(TooltipUtil.SurfaceArgs, tooltipInfo)
        end

        local resolvedTitle = titleText
        if (not resolvedTitle or resolvedTitle == "" or resolvedTitle == UNKNOWN) and type(tooltipInfo.lines) == "table" then
            local firstLine = tooltipInfo.lines[1]
            if firstLine and firstLine.leftText then
                resolvedTitle = firstLine.leftText
            end
        end

        tooltip:SetOwner(owner, "ANCHOR_RIGHT")
        tooltip:SetText(resolvedTitle or UNKNOWN, 1, 1, 1)

        local normalizedTitle = TrimTooltipText(resolvedTitle)
        for _, line in ipairs(tooltipInfo.lines or {}) do
            local leftText = line.leftText
            local rightText = line.rightText
            local hasLeft = type(leftText) == "string" and TrimTooltipText(leftText) ~= ""
            local hasRight = type(rightText) == "string" and TrimTooltipText(rightText) ~= ""

            if hasLeft or hasRight then
                local skipDuplicateTitle = hasLeft and (not hasRight) and TrimTooltipText(leftText) == normalizedTitle
                if not skipDuplicateTitle then
                    local leftR, leftG, leftB = GetTooltipLineColor(line.leftColor or line.color, 1, 1, 1)
                    local rightR, rightG, rightB = GetTooltipLineColor(line.rightColor or line.color, 1, 1, 1)

                    if hasLeft and hasRight then
                        tooltip:AddDoubleLine(leftText, rightText, leftR, leftG, leftB, rightR, rightG, rightB)
                    elseif hasLeft then
                        tooltip:AddLine(leftText, leftR, leftG, leftB, true)
                    else
                        tooltip:AddLine(rightText, rightR, rightG, rightB, true)
                    end
                end
            end
        end

        return true
    end

    local tooltipRank = rank or math.max(1, nodeData.currentRank or 1)
    if not BuildTraitEntryTooltip(GameTooltip, nodeData.name or UNKNOWN, entryID, tooltipRank) then
        GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
        GameTooltip:SetText(nodeData.name or UNKNOWN, 1, 1, 1)
    end

    if InCombatLockdown and InCombatLockdown() then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Folio changes are unavailable in combat.", 1, 0.2, 0.2, true)
    elseif IsCommitPending(nodeData.configID) then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("A Folio change is already being committed.", 1, 0.82, 0, true)
    else
        local showInstructions = false
        if nodeData.canPurchase then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(TALENT_BUTTON_TOOLTIP_PURCHASE_INSTRUCTIONS or "Left-click to purchase.", 0.1, 1, 0.1, true)
            showInstructions = true
        end
        if nodeData.canRefund then
            if not showInstructions then
                GameTooltip:AddLine(" ")
            end
            GameTooltip:AddLine(TALENT_BUTTON_TOOLTIP_REFUND_INSTRUCTIONS or "Right-click to refund.", 0.75, 0.75, 0.75, true)
        end
    end

    GameTooltip:Show()
end

local function CreateSelectionPulse(region)
    if not region then
        return nil
    end

    local pulse = region:CreateAnimationGroup()
    pulse:SetLooping("REPEAT")
    local fadeIn = pulse:CreateAnimation("Alpha")
    fadeIn:SetOrder(1)
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.25)
    fadeIn:SetSmoothing("IN_OUT")
    local fadeOut = pulse:CreateAnimation("Alpha")
    fadeOut:SetOrder(2)
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.75)
    fadeOut:SetSmoothing("IN_OUT")
    pulse:SetScript("OnPlay", function()
        region:Show()
    end)
    pulse:SetScript("OnStop", function()
        region:SetAlpha(0)
        region:Hide()
    end)
    return pulse
end

local function SetSelectionTriangleColor(region, r, g, b, a)
    if not region then
        return
    end

    region:SetVertexColor(r, g, b, a or 1)
end

local function CreateDashboardNodeButton(parent)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(NODE_SIZE, NODE_SIZE)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })

    button.icon = button:CreateTexture(nil, "ARTWORK")
    button.icon:SetPoint("TOPLEFT", 4, -4)
    button.icon:SetPoint("BOTTOMRIGHT", -4, 4)
    button.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    button.greenGlow = button:CreateTexture(nil, "BACKGROUND")
    button.greenGlow:SetPoint("TOPLEFT", -3, 3)
    button.greenGlow:SetPoint("BOTTOMRIGHT", 3, -3)
    button.greenGlow:SetTexture("Interface\\Buttons\\WHITE8X8")
    button.greenGlow:SetBlendMode("ADD")
    button.greenGlow:SetVertexColor(0.15, 0.95, 0.2, 0.85)
    button.greenGlow:SetAlpha(0)
    button.greenGlow:Hide()
    button.greenGlowPulse = CreateSelectionPulse(button.greenGlow)

    button.rankText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    button.rankText:SetPoint("BOTTOMRIGHT", -4, 3)
    button.rankText:SetJustifyH("RIGHT")

    button.leftTriangle = button:CreateTexture(nil, "OVERLAY")
    button.leftTriangle:SetSize(7, 11)
    button.leftTriangle:SetPoint("RIGHT", button, "LEFT", -2, 0)
    button.leftTriangle:SetTexture("Interface\\AddOns\\LiteVault\\Art\\FolioTriangle")
    button.leftTriangle:SetTexCoord(1, 0, 0, 1)
    button.leftTriangle:SetAlpha(1)
    button.leftTriangle:Hide()

    button.rightTriangle = button:CreateTexture(nil, "OVERLAY")
    button.rightTriangle:SetSize(7, 11)
    button.rightTriangle:SetPoint("LEFT", button, "RIGHT", 2, 0)
    button.rightTriangle:SetTexture("Interface\\AddOns\\LiteVault\\Art\\FolioTriangle")
    button.rightTriangle:SetTexCoord(0, 1, 0, 1)
    button.rightTriangle:SetAlpha(1)
    button.rightTriangle:Hide()

    button.leftTrianglePulse = CreateSelectionPulse(button.leftTriangle)
    button.rightTrianglePulse = CreateSelectionPulse(button.rightTriangle)

    button:SetScript("OnEnter", function(self)
        CancelPendingSelectionFlyoutClose()
        if self.nodeData then
            ShowTraitTooltip(self, self.nodeData, self.tooltipEntryID or self.nodeData.displayEntryID, self.tooltipRank or self.nodeData.currentRank)
        end
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
        QueueSelectionFlyoutHideIfUnhovered()
    end)

    return button
end

local function CreateSelectionFlyout(parent)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:Hide()
    frame.buttons = {}
    frame.closeToken = 0

    frame:SetScript("OnEnter", function()
        CancelPendingSelectionFlyoutClose()
    end)

    frame:SetScript("OnLeave", function()
        QueueSelectionFlyoutHideIfUnhovered()
    end)

    return frame
end

local function EnsureSelectionFlyoutButtons(frame, count)
    for index = #frame.buttons + 1, count do
        local button = CreateDashboardNodeButton(frame)
        button.isFlyoutChoice = true
        frame.buttons[index] = button
    end
end

local function CanChooseSelectionEntry(nodeData, entryID)
    if not nodeData or not entryID then
        return false
    end

    if nodeData.committedEntryID and nodeData.committedEntryID == entryID then
        return false
    end

    if nodeData.canPurchase then
        return true
    end

    return nodeData.committedEntryID ~= nil
end

local function StartCommit(configID)
    if not configID or IsCommitPending() or (InCombatLockdown and InCombatLockdown()) then
        return false
    end

    pendingCommitConfigID = configID
    pendingCommitToken = pendingCommitToken + 1
    local token = pendingCommitToken

    if C_Traits and C_Traits.CommitConfig then
        C_Traits.CommitConfig(configID)
    end

    C_Timer.After(COMMIT_TIMEOUT, function()
        if pendingCommitConfigID == configID and pendingCommitToken == token then
            ReleaseCommitLock()
            if lv.RefreshFolioDisplays then
                lv.RefreshFolioDisplays()
            end
        end
    end)

    return true
end

local function TryPurchaseNode(nodeData)
    if not nodeData or not nodeData.configID or not nodeData.nodeID or IsCommitPending() then
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        return
    end
    if not (C_Traits and C_Traits.PurchaseRank) then
        return
    end

    local success = C_Traits.PurchaseRank(nodeData.configID, nodeData.nodeID)
    if success then
        HideSelectionFlyout()
        StartCommit(nodeData.configID)
        if lv.RefreshFolioDisplays then
            lv.RefreshFolioDisplays()
        end
    end
end

local function TryRefundNode(nodeData)
    if not nodeData or not nodeData.configID or not nodeData.nodeID or IsCommitPending() then
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        return
    end
    if not (C_Traits and C_Traits.RefundRank) then
        return
    end

    local success = C_Traits.RefundRank(nodeData.configID, nodeData.nodeID)
    if success then
        HideSelectionFlyout()
        StartCommit(nodeData.configID)
        if lv.RefreshFolioDisplays then
            lv.RefreshFolioDisplays()
        end
    end
end

local function TrySelectEntry(nodeData, entryID)
    if not nodeData or not entryID or not nodeData.configID or not nodeData.nodeID or IsCommitPending() then
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        return
    end
    if not (C_Traits and C_Traits.SetSelection) then
        return
    end
    if not CanChooseSelectionEntry(nodeData, entryID) then
        return
    end

    local success = C_Traits.SetSelection(nodeData.configID, nodeData.nodeID, entryID)
    if success then
        HideSelectionFlyout()
        StartCommit(nodeData.configID)
        if lv.RefreshFolioDisplays then
            lv.RefreshFolioDisplays()
        end
    end
end

local function CanInteractWithSelectionNode(nodeData)
    return not not (nodeData and nodeData.isSelection and type(nodeData.entryIDs) == "table" and #nodeData.entryIDs >= 2)
end

local function ResetDashboardNodeVisuals(button, theme)
    if not button or not theme then
        return
    end

    local bg = theme.buttonBgAlt or theme.buttonBg
    button:SetBackdropColor(bg[1], bg[2], bg[3], 0.9)
    button:SetBackdropBorderColor(unpack(theme.borderPrimary))

    if button.icon then
        button.icon:SetDesaturated(false)
        button.icon:SetVertexColor(1, 1, 1)
    end

    if button.greenGlow then
        button.greenGlow:SetVertexColor(0.15, 0.95, 0.2, 0.85)
        button.greenGlow:SetAlpha(0)
        button.greenGlow:Hide()
    end

    if button.rankText then
        button.rankText:SetText("")
        button.rankText:SetTextColor(unpack(theme.textPrimary))
    end

    if button.leftTriangle then button.leftTriangle:Hide() end
    if button.rightTriangle then button.rightTriangle:Hide() end
end

local function ApplyDashboardNodeTheme(button, theme)
    if not button or not theme then
        return
    end

    local nodeData = button.nodeData
    ResetDashboardNodeVisuals(button, theme)

    if not nodeData then
        return
    end

    local isActive = not not nodeData.dashboardIsActive
    local isPurchasable = not not nodeData.dashboardIsPurchasable
    local rankText = nodeData.dashboardRankText
    local hasChoiceMarkers = not not nodeData.dashboardShowChoiceMarkers
    local shouldPulse = not not nodeData.dashboardShouldPulse

    if isActive then
        button.rankText:SetText(rankText or "")
        button.rankText:SetTextColor(unpack(theme.textGold or { 1, 0.82, 0 }))
    end

    if isActive then
        button:SetBackdropBorderColor(unpack(theme.textGold or { 1, 0.82, 0 }))
    else
        button:SetBackdropBorderColor(0.62, 0.62, 0.62, 1)
        if not isPurchasable then
            button.icon:SetDesaturated(true)
            button.icon:SetVertexColor(0.7, 0.7, 0.7)
        end
    end

    if hasChoiceMarkers then
        local markerColor = ((isActive or shouldPulse) and (theme.textGold or { 1, 0.82, 0 }))
            or { 0.62, 0.62, 0.62 }
        if button.leftTriangle then
            SetSelectionTriangleColor(button.leftTriangle, unpack(markerColor))
            button.leftTriangle:Show()
        end
        if button.rightTriangle then
            SetSelectionTriangleColor(button.rightTriangle, unpack(markerColor))
            button.rightTriangle:Show()
        end
        if shouldPulse then
            if button.leftTriangle and button.leftTrianglePulse and not button.leftTrianglePulse:IsPlaying() then
                button.leftTrianglePulse:Play()
            end
            if button.rightTriangle and button.rightTrianglePulse and not button.rightTrianglePulse:IsPlaying() then
                button.rightTrianglePulse:Play()
            end
            if button.greenGlowPulse and button.greenGlowPulse:IsPlaying() then
                button.greenGlowPulse:Stop()
            end
            if button.greenGlow then
                button.greenGlow:SetAlpha(0)
                button.greenGlow:Hide()
            end
        elseif button.greenGlow then
            if button.greenGlowPulse and button.greenGlowPulse:IsPlaying() then
                button.greenGlowPulse:Stop()
            end
            button.greenGlow:SetAlpha(0)
            button.greenGlow:Hide()
            if button.leftTrianglePulse and button.leftTrianglePulse:IsPlaying() then
                button.leftTrianglePulse:Stop()
            end
            if button.rightTrianglePulse and button.rightTrianglePulse:IsPlaying() then
                button.rightTrianglePulse:Stop()
            end
            if button.leftTriangle then
                button.leftTriangle:SetAlpha(1)
                button.leftTriangle:Show()
            end
            if button.rightTriangle then
                button.rightTriangle:SetAlpha(1)
                button.rightTriangle:Show()
            end
        end
    elseif button.greenGlow then
        if button.greenGlowPulse and button.greenGlowPulse:IsPlaying() then
            button.greenGlowPulse:Stop()
        end
        button.greenGlow:SetAlpha(0)
        button.greenGlow:Hide()
        if button.leftTrianglePulse and button.leftTrianglePulse:IsPlaying() then
            button.leftTrianglePulse:Stop()
        end
        if button.rightTrianglePulse and button.rightTrianglePulse:IsPlaying() then
            button.rightTrianglePulse:Stop()
        end
    end
end

local function ApplyDashboardFolioTheme(frame, theme)
    if not frame or not theme then
        return
    end

    frame:SetBackdropColor(unpack(theme.backgroundTransparent or theme.background))
    frame:SetBackdropBorderColor(unpack(theme.borderPrimary))

    if frame.title then
        frame.title:SetTextColor(unpack(theme.textGold or theme.textPrimary))
    end
    if frame.pointsText then
        frame.pointsText:SetTextColor(unpack(theme.textPrimary))
    end
    if frame.progressText then
        frame.progressText:SetTextColor(unpack(theme.textPrimary))
    end
    if frame.noteText then
        frame.noteText:SetTextColor(unpack(theme.textMuted or theme.textSecondary))
    end
    if frame.emptyText then
        frame.emptyText:SetTextColor(unpack(theme.textSecondary))
    end

    for _, button in ipairs(frame.nodeButtons or {}) do
        ApplyDashboardNodeTheme(button, theme)
    end

    if selectionFlyout and selectionFlyout:IsShown() then
        selectionFlyout:SetBackdropColor(unpack(theme.backgroundSolid or theme.background))
        selectionFlyout:SetBackdropBorderColor(unpack(theme.borderPrimary))
        for _, button in ipairs(selectionFlyout.buttons or {}) do
            ApplyDashboardNodeTheme(button, theme)
        end
    end
end

local function ApplyCompleteFolioTheme(theme)
    if not theme and lv.GetTheme then
        theme = lv.GetTheme()
    end
    if not theme then
        return
    end

    if folioView then
        ApplyFolioViewTheme(folioView, theme)
        ApplyFolioButtonTheme(folioView.openBtn, theme)
        if folioView.scrollBar then
            ApplyFolioScrollBarTheme(folioView.scrollBar, theme)
        end
        for _, row in ipairs(folioView.rows or {}) do
            ApplyFolioRowTheme(row, theme)
        end
    end

    if dashboardFolioFrame then
        ApplyDashboardFolioTheme(dashboardFolioFrame, theme)
    end
end

local function PopulateFolioView(state, reason)
    if not folioView then
        return
    end

    folioView.title:SetText(GetFolioLabel())
    folioView.charLabel:SetText(GetCharacterDisplayName(lv.PLAYER_KEY))
    folioView.updatedText:SetText("Live current character")
    folioView.noteText:SetText(FormatFolioStatusText())

    if state then
        folioView.pointsText:SetText(string.format("Available Points: %d", tonumber(state.availablePoints) or 0))
        folioView.progressText:SetText(string.format("Selected Nodes: %d / %d    Spent Points: %d", tonumber(state.selectedNodeCount) or 0, tonumber(state.totalNodeCount) or 0, tonumber(state.spentPoints) or 0))
    else
        folioView.pointsText:SetText("Available Points: -")
        folioView.progressText:SetText("Selected Nodes: -")
    end

    local selectedNodes = state and state.selectedNodes or {}
    EnsureFolioRows(folioView, #selectedNodes)
    RefreshRowLayout(folioView, #selectedNodes)

    if state and #selectedNodes > 0 then
        folioView.emptyText:Hide()
        for index, row in ipairs(folioView.rows or {}) do
            if index <= #selectedNodes then
                local node = selectedNodes[index]
                row.icon:SetTexture(node.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
                row.nameText:SetText(node.name or string.format("Node %d", tonumber(node.nodeID) or 0))
                if tonumber(node.currentRank) and tonumber(node.currentRank) > 0 then
                    row.rankText:SetText(string.format("Rank %d", tonumber(node.currentRank) or 0))
                else
                    row.rankText:SetText("Selected")
                end
            end
        end
    else
        folioView.emptyText:SetText(reason or "No committed Omnium Folio nodes are active.")
        folioView.emptyText:Show()
    end

    folioView.openBtn:SetEnabled(not (pendingCommitConfigID and state and pendingCommitConfigID == state.configID))

    ApplyCompleteFolioTheme(lv.GetTheme and lv.GetTheme() or nil)
end

local function EnsureDashboardNodeButtons(frame, count)
    frame.nodeButtons = frame.nodeButtons or {}
    for index = #frame.nodeButtons + 1, count do
        local button = CreateDashboardNodeButton(frame.nodesContainer)
        frame.nodeButtons[index] = button
    end
end

function ShowSelectionChoices(ownerButton)
    local nodeData = ownerButton and ownerButton.nodeData or nil
    if selectionFlyout and selectionFlyout:IsShown() and selectionFlyout.owner == ownerButton then
        HideSelectionFlyout()
        return
    end
    if not nodeData or not nodeData.isSelection or type(nodeData.entryIDs) ~= "table" or #nodeData.entryIDs < 2 then
        return
    end
    if not CanInteractWithSelectionNode(nodeData) then
        return
    end
    if InCombatLockdown and InCombatLockdown() then
        return
    end
    if IsCommitPending(nodeData.configID) then
        return
    end
    if not dashboardFolioFrame then
        return
    end

    if not selectionFlyout then
        selectionFlyout = CreateSelectionFlyout(dashboardFolioFrame)
    end

    local entries = {}
    for _, entryID in ipairs(nodeData.entryIDs) do
        local presentation = ResolveEntryPresentation(nodeData.configID, entryID, nodeData.nodeID)
        entries[#entries + 1] = {
            entryID = entryID,
            name = presentation.name,
            icon = presentation.icon,
            rank = nodeData.currentRank,
            canChoose = CanChooseSelectionEntry(nodeData, entryID),
            isSelected = nodeData.committedEntryID == entryID or (not nodeData.committedEntryID and nodeData.activeEntryID == entryID and nodeData.currentRank > 0),
            nodeData = nodeData,
        }
    end

    EnsureSelectionFlyoutButtons(selectionFlyout, #entries)

    local width = (#entries * NODE_SIZE) + ((math.max(0, #entries - 1)) * NODE_GAP) + (FLYOUT_PADDING * 2)
    selectionFlyout:SetSize(width, NODE_SIZE + (FLYOUT_PADDING * 2))
    selectionFlyout:ClearAllPoints()
    selectionFlyout:SetPoint("BOTTOM", ownerButton, "TOP", 0, 10)
    selectionFlyout.owner = ownerButton

    for index, button in ipairs(selectionFlyout.buttons) do
        button:ClearAllPoints()
        if index <= #entries then
            local entryData = entries[index]
            button:SetPoint("LEFT", selectionFlyout, "LEFT", FLYOUT_PADDING + ((index - 1) * (NODE_SIZE + NODE_GAP)), 0)
            button.nodeData = {
                configID = nodeData.configID,
                nodeID = nodeData.nodeID,
                displayEntryID = entryData.entryID,
                currentRank = entryData.rank,
                name = entryData.name,
                icon = entryData.icon,
                dashboardIsActive = not not entryData.isSelected,
                dashboardIsPurchasable = not not entryData.canChoose,
                dashboardRankText = entryData.isSelected and "Active" or "",
                dashboardShowChoiceMarkers = false,
                dashboardShouldPulse = false,
            }
            button.tooltipEntryID = entryData.entryID
            button.tooltipRank = entryData.isSelected and math.max(1, entryData.rank or 1) or 1
            button.isSelectedChoice = entryData.isSelected
            button.isChoicePurchasable = entryData.canChoose
            button.icon:SetTexture(entryData.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            button:SetScript("OnClick", function()
                TrySelectEntry(nodeData, entryData.entryID)
            end)
            button:Show()
        else
            button:Hide()
        end
    end

    selectionFlyout:Show()
    ApplyCompleteFolioTheme(lv.GetTheme and lv.GetTheme() or nil)
end

local function RefreshDashboardNodeButton(button, nodeData)
    if not button then
        return
    end

    local isSelection = not not nodeData.isSelection
    local isActive
    local rankText = ""

    if isSelection then
        isActive = nodeData.committedEntryID ~= nil
        if isActive and tonumber(nodeData.currentRank) and tonumber(nodeData.currentRank) > 0 then
            rankText = tostring(tonumber(nodeData.currentRank) or 0)
        end
    else
        isActive = (tonumber(nodeData.currentRank) or 0) > 0 or (tonumber(nodeData.ranksPurchased) or 0) > 0
        if isActive and tonumber(nodeData.currentRank) and tonumber(nodeData.currentRank) > 0 then
            rankText = tostring(tonumber(nodeData.currentRank) or 0)
        end
    end

    local isPurchasable = (not isActive) and (not not nodeData.canPurchase)

    button.nodeData = {
        configID = nodeData.configID,
        nodeID = nodeData.nodeID,
        displayEntryID = nodeData.displayEntryID,
        currentRank = nodeData.currentRank,
        name = nodeData.name,
        icon = nodeData.icon,
        isSelected = nodeData.isSelected,
        canPurchase = nodeData.canPurchase,
        canRefund = nodeData.canRefund,
        isSelection = isSelection,
        entryIDs = nodeData.entryIDs,
        committedEntryID = nodeData.committedEntryID,
        activeEntryID = nodeData.activeEntryID,
        dashboardIsActive = isActive,
        dashboardIsPurchasable = isPurchasable,
        dashboardRankText = rankText,
        dashboardShowChoiceMarkers = true,
        dashboardShouldPulse = isSelection
            and type(nodeData.entryIDs) == "table"
            and #nodeData.entryIDs > 1
            and nodeData.committedEntryID == nil
            and isPurchasable,
    }
    button.tooltipEntryID = nodeData.displayEntryID
    button.tooltipRank = math.max(1, nodeData.currentRank or 1)
    button.isSelectedChoice = false
    button.isChoicePurchasable = false

    button.icon:SetTexture(nodeData.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    button:SetScript("OnClick", function(self, mouseButton)
        if not self.nodeData then
            return
        end
        if mouseButton == "RightButton" then
            TryRefundNode(self.nodeData)
            return
        end
        if CanInteractWithSelectionNode(self.nodeData) then
            ShowSelectionChoices(self)
        elseif self.nodeData.canPurchase then
            TryPurchaseNode(self.nodeData)
        end
    end)
end

local function PopulateDashboardFolio(state, reason)
    if not dashboardFolioFrame then
        return
    end

    dashboardFolioFrame.title:SetText(GetFolioLabel())

    if not state then
        dashboardFolioFrame.pointsText:SetText("Available Points: -")
        dashboardFolioFrame.emptyText:SetText(reason or "Omnium Folio is unavailable.")
        dashboardFolioFrame.emptyText:Show()
        dashboardFolioFrame.nodesContainer:Hide()
        HideSelectionFlyout()
        ApplyCompleteFolioTheme(lv.GetTheme and lv.GetTheme() or nil)
        return
    end

    dashboardFolioFrame.pointsText:SetText(string.format("Available Points: %d", tonumber(state.availablePoints) or 0))
    dashboardFolioFrame.emptyText:Hide()
    dashboardFolioFrame.nodesContainer:Show()

    EnsureDashboardNodeButtons(dashboardFolioFrame, #state.nodes)

    local dashboardNodeGap = 28
    local totalWidth = (#state.nodes * NODE_SIZE) + (math.max(0, #state.nodes - 1) * dashboardNodeGap)
    dashboardFolioFrame.nodesContainer:SetSize(math.max(totalWidth, NODE_SIZE), NODE_SIZE)

    for index, button in ipairs(dashboardFolioFrame.nodeButtons or {}) do
        button:ClearAllPoints()
        if index <= #state.nodes then
            local nodeData = state.nodes[index]
            button:SetPoint("LEFT", dashboardFolioFrame.nodesContainer, "LEFT", (index - 1) * (NODE_SIZE + dashboardNodeGap), 0)
            RefreshDashboardNodeButton(button, nodeData)
            if index == 3 and button.nodeData then
                button.nodeData.dashboardShowChoiceMarkers = false
                button.nodeData.dashboardShouldPulse = false
                if button.leftTrianglePulse and button.leftTrianglePulse:IsPlaying() then
                    button.leftTrianglePulse:Stop()
                end
                if button.rightTrianglePulse and button.rightTrianglePulse:IsPlaying() then
                    button.rightTrianglePulse:Stop()
                end
                if button.leftTriangle then
                    button.leftTriangle:Hide()
                end
                if button.rightTriangle then
                    button.rightTriangle:Hide()
                end
            end
            button:Show()
        else
            button:Hide()
        end
    end

    if selectionFlyout and selectionFlyout:IsShown() and selectionFlyout.owner and selectionFlyout.owner.nodeData then
        local ownerNodeID = selectionFlyout.owner.nodeData.nodeID
        local ownerButton
        for _, button in ipairs(dashboardFolioFrame.nodeButtons or {}) do
            if button:IsShown() and button.nodeData and button.nodeData.nodeID == ownerNodeID then
                ownerButton = button
                break
            end
        end

        if ownerButton then
            ShowSelectionChoices(ownerButton)
        else
            HideSelectionFlyout()
        end
    end

    ApplyCompleteFolioTheme(lv.GetTheme and lv.GetTheme() or nil)
end

local function RefreshAllFolioDisplays()
    local state, reason = BuildLiveFolioState()
    PopulateFolioView(state, reason)
    PopulateDashboardFolio(state, reason)
end

local function EnsureEventFrame()
    if folioEventFrame then
        return
    end

    folioEventFrame = CreateFrame("Frame")
    folioEventFrame:RegisterEvent("TRAIT_TREE_CURRENCY_INFO_UPDATED")
    folioEventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
    folioEventFrame:RegisterEvent("CONFIG_COMMIT_FAILED")
    folioEventFrame:SetScript("OnEvent", function(_, event, arg1)
        local activeConfigID = GetActiveConfigID()

        if event == "TRAIT_TREE_CURRENCY_INFO_UPDATED" then
            if arg1 == TRAIT_TREE_ID then
                RefreshAllFolioDisplays()
            end
        elseif event == "TRAIT_CONFIG_UPDATED" then
            if activeConfigID and arg1 == activeConfigID then
                if pendingCommitConfigID == arg1 then
                    ReleaseCommitLock()
                end
                RefreshAllFolioDisplays()
            end
        elseif event == "CONFIG_COMMIT_FAILED" then
            if pendingCommitConfigID and arg1 == pendingCommitConfigID then
                ReleaseCommitLock()
            end
            if activeConfigID and arg1 == activeConfigID then
                RefreshAllFolioDisplays()
            end
        end
    end)
end

function lv.RefreshFolioDisplays()
    RefreshAllFolioDisplays()
end

function lv.SetFolioContentVisible(visible)
    if not folioView then
        return
    end

    if visible then
        RefreshAllFolioDisplays()
        ApplyCompleteFolioTheme(lv.GetTheme and lv.GetTheme() or nil)
        folioView:Show()
    else
        folioView:Hide()
    end
end

function lv.RefreshFolioViewForCurrentChar(playerKey)
    if playerKey == lv.PLAYER_KEY then
        RefreshAllFolioDisplays()
    end
end

function lv.AttachFolioDashboardFrame()
    if dashboardFolioFrame or not lv.WeeklyBox or not lv.LVWindow then
        return
    end

    EnsureEventFrame()

    local frame = CreateFrame("Frame", nil, lv.LVWindow, "BackdropTemplate")
    frame:SetSize(360, 98)
    frame:SetPoint("TOP", lv.WeeklyBox, "BOTTOM", 0, -6)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:Hide()

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 16, -14)

    frame.pointsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.pointsText:SetPoint("TOPRIGHT", -16, -15)
    frame.pointsText:SetJustifyH("RIGHT")

    frame.progressText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.progressText:Hide()

    frame.noteText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frame.noteText:Hide()

    frame.emptyText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.emptyText:SetPoint("CENTER", frame, "CENTER", 0, -2)
    frame.emptyText:SetPoint("LEFT", 20, 0)
    frame.emptyText:SetPoint("RIGHT", -20, 0)
    frame.emptyText:SetJustifyH("CENTER")
    frame.emptyText:SetText("Omnium Folio is unavailable.")
    frame.emptyText:Hide()

    frame.nodesContainer = CreateFrame("Frame", nil, frame)
    frame.nodesContainer:SetPoint("BOTTOM", frame, "BOTTOM", 0, 18)
    frame.nodesContainer:SetSize(NODE_SIZE, NODE_SIZE)

    dashboardFolioFrame = frame
    lv.LVDashboardFolioFrame = frame

    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(frame, function(_, theme)
            ApplyCompleteFolioTheme(theme)
        end)
    end

    ApplyCompleteFolioTheme(lv.GetTheme and lv.GetTheme() or nil)
end

function lv.SetDashboardFolioVisible(visible)
    if not dashboardFolioFrame and visible then
        lv.AttachFolioDashboardFrame()
    end
    if not dashboardFolioFrame then
        return
    end

    if visible then
        RefreshAllFolioDisplays()
        ApplyCompleteFolioTheme(lv.GetTheme and lv.GetTheme() or nil)
        dashboardFolioFrame:Show()
    else
        HideSelectionFlyout()
        dashboardFolioFrame:Hide()
    end
end

function lv.InitFolioUI(env)
    if folioView then
        return
    end

    local parent = env and env.LVWindow or lv.LVWindow
    if not parent then
        return
    end

    local view = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    view:SetPoint("TOPLEFT", 35, -65)
    view:SetPoint("BOTTOMRIGHT", -15, 25)
    view:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    view:Hide()

    view.title = view:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    view.title:SetPoint("TOPLEFT", 16, -16)

    view.updatedText = view:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    view.updatedText:SetPoint("TOPRIGHT", -16, -18)
    view.updatedText:SetJustifyH("RIGHT")

    view.charLabel = view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    view.charLabel:SetPoint("TOPLEFT", 16, -48)
    view.charLabel:SetJustifyH("LEFT")

    view.openBtn = CreateActionButton(view, 140, "Open Blizzard Folio")
    view.openBtn:SetPoint("TOPRIGHT", -16, -46)

    view.pointsText = view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    view.pointsText:SetPoint("TOPLEFT", 16, -80)
    view.pointsText:SetJustifyH("LEFT")

    view.progressText = view:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    view.progressText:SetPoint("TOPLEFT", 16, -102)
    view.progressText:SetJustifyH("LEFT")

    view.noteText = view:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    view.noteText:SetPoint("TOPLEFT", 16, -124)
    view.noteText:SetPoint("RIGHT", -16, 0)
    view.noteText:SetJustifyH("LEFT")

    view.emptyText = view:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    view.emptyText:SetPoint("TOPLEFT", 20, -184)
    view.emptyText:SetPoint("RIGHT", -28, 0)
    view.emptyText:SetJustifyH("CENTER")
    view.emptyText:Hide()

    view.scrollFrame = CreateFrame("ScrollFrame", nil, view, "UIPanelScrollFrameTemplate")
    view.scrollFrame:SetPoint("TOPLEFT", 16, -154)
    view.scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)
    view.scrollBar = view.scrollFrame.ScrollBar or view.scrollFrame.scrollBar

    view.scrollChild = CreateFrame("Frame", nil, view.scrollFrame)
    view.scrollChild:SetSize(1, 1)
    view.scrollFrame:SetScrollChild(view.scrollChild)

    view.openBtn:SetScript("OnClick", function()
        OpenNativeFolio()
    end)

    folioView = view
    lv.LVFolioView = view

    EnsureEventFrame()

    if lv.RegisterThemedElement then
        lv.RegisterThemedElement(view, function(_, theme)
            ApplyCompleteFolioTheme(theme)
        end)
    end

    RefreshAllFolioDisplays()
    ApplyCompleteFolioTheme(lv.GetTheme and lv.GetTheme() or nil)
end
