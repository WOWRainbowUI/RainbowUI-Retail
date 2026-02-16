local _, ns = ...

local TrackerDB = {}
ns.TrackerDB = TrackerDB

TrackerDB.DEFAULT_COOLDOWN_SWIPE_COLOR = { 0, 0, 0, 0.7 }
TrackerDB.DEFAULT_AURA_SWIPE_COLOR = { 1, 0.95, 0.57, 0.7 }

local dbDefaults = {
    -- defaultAuraSwipeReversed = false,
    itemViewerLayouts = {},
    itemSettings = {},
    spellItemSettings = {},
    showUnusable = false,
}

TrackerDB.DefaultItems = {
    241304, -- Silvermoon Healing Potion
    241308, -- Light's Potential

    5512, -- Healthstone
    224464, -- Demonic Healthstone

    -- Invigorating Healing Potion
    244839,
    244838,
    244835,

    -- Tempered Potion
    212265, -- Tempered Potion (R3)
    212264, -- Tempered Potion (R2)
    212263, -- Tempered Potion (R1)

    -- Fleeting Tempered Potion
    212971,
    212970,
    212969,
}

TrackerDB.DefaultSpells = {
    7744, -- Will of the Forsaken
    20549, -- War Stomp
    20572, -- Blood Fury
    33697, -- Blood Fury
    33702, -- Blood Fury
    20589, -- Escape Artist
    20594, -- Stoneform
    26297, -- Berserking
    28880, -- Gift of the Naaru
    28880, -- Gift of the Naaru
    59542, -- Gift of the Naaru
    59543, -- Gift of the Naaru
    59544, -- Gift of the Naaru
    59545, -- Gift of the Naaru
    59547, -- Gift of the Naaru
    59548, -- Gift of the Naaru
    121093, -- Gift of the Naaru
    370626, -- Gift of the Naaru
    416250, -- Gift of the Naaru
    58984, -- Shadowmeld
    59752, -- Will to Survive
    68992, -- Darkflight
    69041, -- Rocket Barrage
    69070, -- Rocket Jump
    107079, -- Quaking Palm
    25046, -- Arcane Torrent
    28730, -- Arcane Torrent
    50613, -- Arcane Torrent
    69179, -- Arcane Torrent
    80483, -- Arcane Torrent
    202719, -- Arcane Torrent
    129597, -- Arcane Torrent
    155145, -- Arcane Torrent
    232633, -- Arcane Torrent
    255647, -- Light's Judgment
    255654, -- Bull Rush
    256948, -- Spatial Rift
    260364, -- Arcane Pulse
    265221, -- Fireblood
    274738, -- Ancestral Call
    287712, -- Haymaker
    291944, -- Regeneratin'
    312411, -- Bag of Tricks
    312924, -- Hyper Organic Light Originator
    357214, -- Wing Buffet
    368970, -- Tail Swipe
    436344, -- Azerite Surge
    1237885, -- Thorn Bloom
}

local function ApplyDefaultsToTable(tbl, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            if type(tbl[k]) ~= "table" then
                tbl[k] = {}
            end
            ApplyDefaultsToTable(tbl[k], v)
        elseif tbl[k] == nil then
            tbl[k] = v
        end
    end
end

function TrackerDB.GetDB()
    return ns.db.profile.tracker
end

function TrackerDB.InitializeDB()
    if not ns.db.profile.tracker_enabled then
        return
    end
    local db = TrackerDB.GetDB()
    ApplyDefaultsToTable(db, dbDefaults)
    if not ns.db.profile._tracker_filled_with_defaults then
        for i, spellID in pairs(TrackerDB.DefaultSpells) do
            if not db.spellItemSettings[spellID] then
                db.spellItemSettings[spellID] = {
                    state = "tracker1",
                    order = 1,
                }
            end
        end
        for i, itemID in pairs(TrackerDB.DefaultItems) do
            if not db.itemSettings[itemID] then
                db.itemSettings[itemID] = {
                    state = "tracker1",
                    order = 1,
                }
            end
        end
        ns.db.profile._tracker_filled_with_defaults = true
    end
end

function TrackerDB.GetItemSettings(itemID)
    local db = TrackerDB.GetDB()
    return db.itemSettings[itemID]
end

function TrackerDB.GetSpellItemSettings(spellID)
    local db = TrackerDB.GetDB()
    db.spellItemSettings = db.spellItemSettings or {}
    return db.spellItemSettings[spellID]
end

function TrackerDB.EnsureItemSettings(itemID)
    local db = TrackerDB.GetDB()
    if db.itemSettings[itemID] == nil then
        db.itemSettings[itemID] = {}
    end
    return db.itemSettings[itemID]
end

function TrackerDB.EnsureSpellItemSettings(spellID)
    local db = TrackerDB.GetDB()
    db.spellItemSettings = db.spellItemSettings or {}
    if db.spellItemSettings[spellID] == nil then
        db.spellItemSettings[spellID] = {}
    end
    return db.spellItemSettings[spellID]
end

function TrackerDB.GetItemState(itemID)
    local settings = TrackerDB.GetItemSettings(itemID)
    return settings and settings.state or nil
end

function TrackerDB.GetSpellItemState(spellID)
    local settings = TrackerDB.GetSpellItemSettings(spellID)
    return settings and settings.state or nil
end

function TrackerDB.SetItemState(itemID, state)
    local db = TrackerDB.GetDB()
    if state == nil then
        db.itemSettings[itemID] = nil
        return
    end

    local settings = TrackerDB.EnsureItemSettings(itemID)
    settings.state = state
end

function TrackerDB.SetSpellItemState(spellID, state)
    local db = TrackerDB.GetDB()
    db.spellItemSettings = db.spellItemSettings or {}
    if state == nil then
        db.spellItemSettings[spellID] = nil
        return
    end

    local settings = TrackerDB.EnsureSpellItemSettings(spellID)
    settings.state = state
end

function TrackerDB.GetShowingUnusable()
    local db = TrackerDB.GetDB()
    return db.showUnusable == true
end

function TrackerDB.ToggleShowUnusable()
    local db = TrackerDB.GetDB()
    db.showUnusable = not TrackerDB.GetShowingUnusable()
    if ns.MiscPanel and ns.MiscPanel.RefreshMiscPanel then
        ns.MiscPanel:RefreshMiscPanel()
    end
end
