-- Auto-generated from CHANGELOG.md by tools/update-addon-changelog.ps1.
-- Edit CHANGELOG.md, then regenerate this file before packaging.
local _, ns = ...
ns = ns or {}

local data = {
    currentVersion = "5.56",
    previousVersion = "5.51",
    rangeLabel = "5.51 -> 5.56",
    entries = {
        {
            version = "5.56",
            date = "2026-05-30",
            sections = {
                {
                    title = "Critical Fixes",
                    bullets = {
                        "Fixed group-frame smooth health and power fill not animating because the group-frame runtime cache read an unset interpolation value instead of Blizzard's status-bar interpolation enum.",
                        "Fixed Blizzard-rendered group-frame private aura cleanup during roster or instance transitions so Blizzard can remove stale private aura anchors even after its settings handler has already been cleared.",
                    },
                },
            },
        },
        {
            version = "5.55",
            date = "2026-05-29",
            sections = {
                {
                    title = "Critical Fixes",
                    bullets = {
                        "Fixed Blizzard-rendered group-frame private auras reusing a stale Blizzard settings-change handler after instance or roster transitions.",
                        "Fixed group-frame absorb and heal-absorb overlays drawing over the normal frame outline on party and raid frames.",
                        "Fixed an edge case where active debuffs could drop off the display even while they were still running.",
                        "Fixed cold-start font application so unit-frame text relayouts after the configured font becomes available, preventing wrong text anchoring after login or reload.",
                    },
                },
            },
        },
        {
            version = "5.53",
            date = "2026-05-26",
            sections = {
                {
                    title = "Critical Fixes",
                    bullets = {
                        "Fixed target, focus, and boss frame alpha/background recovery after combat so frames no longer need a target swap or reload to restore missing backgrounds.",
                        "Fixed post-combat range fade handling so combat end restores cached alpha/background state instead of running an expensive range scan or full alpha refresh.",
                        "Fixed group-frame range fade incorrectly fading the player/self frame by treating the player token and matching player GUID as always in range.",
                        "Fixed stale absorb, shield, and heal-absorb overlays that could stay visible after the target no longer had an active absorb or heal absorb.",
                        "Fixed group-frame secure-button recovery after login, reload, and party/raid changes so blank party or raid frames are reconciled without requiring /reload.",
                        "Fixed CDM/custom-anchor login timing so unit frames keep their cached screen position until Blizzard EditMode or the configured anchor is available, instead of saving wrong UIParent offsets.",
                        "Added a legacy no-op anchor for old Blizzard EditMode layouts that still reference EssentialCooldownViewer_MSA_Container, preventing repeated CDM SetPoint warnings after removing the old MSA dependency.",
                    },
                },
                {
                    title = "Menu and Preview Fixes",
                    bullets = {
                        "Fixed Buff Reminders checkboxes so the full label row is clickable again.",
                        "Fixed Global Ignore List checkboxes and the per-unit override toggle so their click areas match the visible controls.",
                        "Fixed Unit Auras scope/override clipping in compact or scaled menu layouts.",
                        "Fixed Group Frame Aura Display Mode clipping by making the Blizzard aura routing and layering controls responsive in narrow menu layouts.",
                        "Added a castbar size label to the Unit Frame preview so castbar width and height are visible while editing.",
                    },
                },
                {
                    title = "Performance and Stability",
                    bullets = {
                        "Kept alpha/range fixes cached and event-driven, avoiding broad post-combat frame sweeps.",
                        "Kept absorb and heal-absorb cleanup on the existing prediction update paths with secret-safe positive-value checks.",
                        "Improved post-login group-frame recovery through delayed live-frame reconciliation without adding constant polling.",
                        "Kept late anchor recovery event-driven with a short, finite retry window only for profiles that actually use CDM, custom, or unit-frame anchors.",
                    },
                },
            },
        },
        {
            version = "5.52",
            date = "2026-05-23",
            sections = {
                {
                    title = "Critical Fixes",
                    bullets = {
                        "Fixed the Dashboard Edit frames button so it no longer calls private Menu2 core helpers that are not visible from the dashboard module.",
                        "Restored the dashboard Edit Mode toggle path while keeping the existing combat-lock handling and menu frame priority refresh.",
                    },
                },
            },
        },
        {
            version = "5.51",
            date = "2026-05-22",
            sections = {
                {
                    title = "Critical Fixes",
                    bullets = {
                        "Fixed a critical edge case where selected debuff dispel-type filters could hide unrelated debuffs globally instead of only narrowing the dispellable-debuff exception.",
                        "Fixed Aura Filters menu checkbox hitboxes and labels so the dispel and include toggles are easier to click and only active when they affect the current filter setup.",
                    },
                },
            },
        },
    },
}

ns.MSUF_Changelog = data
_G.MSUF_Changelog = data
