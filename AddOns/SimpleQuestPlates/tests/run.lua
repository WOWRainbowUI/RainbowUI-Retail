--=====================================================================================
-- RGX | Simple Quest Plates! - tests/run.lua
--
-- Description: Lua 5.1 test runner for the SavedVariables evidence suite.
-- Stubs the WoW globals touched by RGX-Framework's core/systems/database.lua
-- (same approach as the framework's own tools/ci/database-runtime-test.lua),
-- loads the real framework database code, extracts the real SQP.DEFAULTS
-- table from data/core.lua, and executes tests/savedvariables_test.lua.
--
-- Usage: lua5.1 tests/run.lua
--   RGXFW_PATH: path to an RGX-Framework checkout containing
--               core/systems/database.lua (default ../RGX-Framework).
--=====================================================================================

local LuaUnit = {} -- placeholder; this runner is deliberately minimal

-- Locate the SQP repo root (this script lives in <root>/tests).
local scriptPath = arg and arg[0] or "tests/run.lua"
local root = scriptPath:match("^(.*)tests[/\\]run%.lua$") or "./"
if root == "" then root = "." end
root = root:gsub("\\", "/")
if not root:find("/$") then root = root .. "/" end

-- Optional env override for the framework checkout (defaults to a sibling).
local function env(name, default)
    return os.getenv(name) or default
end

local frameworkPath = env("RGXFW_PATH", root .. "../RGX-Framework")
frameworkPath = frameworkPath:gsub("\\", "/")
if not frameworkPath:find("/$") then frameworkPath = frameworkPath .. "/" end

local function readFile(path)
    local f = io.open(path, "r")
    if not f then return nil, "cannot open " .. path end
    local content = f:read("*all")
    f:close()
    return content
end

local function loadSource(source, path, ...)
    local chunk, err = loadstring(source, "@" .. path)
    if not chunk then error(err, 0) end
    return chunk(...)
end

-- ---------------------------------------------------------------------------
-- WoW environment stubs: only what database.lua touches (mirrors the
-- framework's own CI harness, tools/ci/database-runtime-check.mjs).
-- ---------------------------------------------------------------------------
function UnitName() return "TestChar" end
function GetRealmName() return "TestRealm" end
SlashCmdList = SlashCmdList or {}

-- RGX runtime host: the database system registers itself onto this table
-- and only optionally calls RGX:Error / RGX:Print, both stubbed no-op like
-- in the framework harness.
local RGX = { _databases = {} }
function RGX:Print(...) end
function RGX:Error(...) end
function RGX:Debug(...) end

_G.RGXFramework = RGX

-- ---------------------------------------------------------------------------
-- Load the real framework database code.
-- ---------------------------------------------------------------------------
local dbSourcePath = frameworkPath .. "core/systems/database.lua"
local dbSource, err = readFile(dbSourcePath)
if not dbSource then
    error("RGX-Framework checkout not found. Set RGXFW_PATH. " .. tostring(err), 0)
end
loadSource(dbSource, "RGX-Framework/core/systems/database.lua", "RGX-Framework", RGX)

-- ---------------------------------------------------------------------------
-- Extract the real SQP.DEFAULTS from data/core.lua.
--
-- core.lua at chunk scope touches WoW APIs before SQP.DEFAULTS (line 106):
-- GetAddOnMetadata/C_AddOns, GetLocale, RGX.interfaceVersion. It also
-- asserts _G.RGXFramework. SQP.DEFAULTS is fully defined before the first
-- WoW-frame usage (CHIP_TEXTURES/logo loop are pure tables). We therefore
-- execute the real chunk in a restricted environment where WoW metadata
-- accessors return deterministic values, and stop right after the defaults
-- block by terminating the chunk at the first statement that needs a real
-- WoW global we have not stubbed: RGX.interfaceVersion is defined via the
-- host above; GetAddOnMetadata/GetLocale/C_AddOns are stubbed below. The
-- chunk runs to completion only as far as SQP.DEFAULTS + the pure-table
-- blocks; for extraction purposes we truncate at "SQP.defaultMinimapAngle"
-- to guarantee no dependency on downstream WoW behavior.
-- ---------------------------------------------------------------------------
local coreSource, cerr = readFile(root .. "data/core.lua")
if not coreSource then
    error("data/core.lua not found under " .. root .. ": " .. tostring(cerr), 0)
end

-- Truncate the real chunk just after SQP.DEFAULTS closes and the pure
-- following constants, at the first function that reads live settings.
local cut = coreSource:find("function SQP:GetSettingBaseline")
assert(cut, "cannot find SQP:GetSettingBaseline marker in data/core.lua")
local defaultsChunkSource = coreSource:sub(1, cut - 1)

-- WoW metadata stubs used by the truncated head of core.lua.
GetAddOnMetadata = function(name, field)
    if field == "Title" then return "SimpleQuestPlates" end
    if field == "Author" then return "DonnieDice" end
    if field == "IconTexture" then return "Interface\\AddOns\\SimpleQuestPlates\\media\\icon" end
    if field == "Interface" then return "120100" end
    return nil
end
C_AddOns = { GetAddOnMetadata = function(_, f) return GetAddOnMetadata("SimpleQuestPlates", f) end }
function GetLocale() return "enUS" end
function GetAddOnInfo() return nil, "SimpleQuestPlates", "notes" end
RGX.interfaceVersion = "120100"

-- Run the truncated real core.lua chunk: SQP.DEFAULTS is now real.
local addonNamespace = {}
loadSource(defaultsChunkSource, "data/core.lua (defaults head)", "SimpleQuestPlates", addonNamespace)
local DEFAULTS = assert(addonNamespace.DEFAULTS,
    "SQP.DEFAULTS missing after executing the data/core.lua defaults head")

-- ---------------------------------------------------------------------------
-- Expose the extracted defaults to the suite through package.loaded so the
-- test's require("sqp_defaults") returns the real table.
-- ---------------------------------------------------------------------------
package.loaded = package.loaded or {}
package.loaded["sqp_defaults"] = DEFAULTS

-- ---------------------------------------------------------------------------
-- Run the suite.
-- ---------------------------------------------------------------------------
-- Run the suite (or the debug script when SQP_TEST_DEBUG is set).
local testSource, terr = readFile(root .. "tests/savedvariables_test.lua")
if not testSource then
    error("tests/savedvariables_test.lua not found: " .. tostring(terr), 0)
end
loadSource(testSource, "tests/savedvariables_test.lua", "SimpleQuestPlates", RGX)
