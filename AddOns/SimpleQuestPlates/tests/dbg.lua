-- Debug runner: same environment as tests/run.lua but executes a debug
-- script given as argument instead of the suite.
local scriptPath = arg and arg[0] or "tests/dbg.lua"
local root = scriptPath:match("^(.*)tests[/\\]") or "./"
local dbgPath = arg and arg[1]
assert(dbgPath, "usage: lua5.1 tests/dbg.lua <debug-script>")

local function readFile(path)
    local f = io.open(path, "r")
    if not f then error("cannot open " .. path, 0) end
    local c = f:read("*all"); f:close(); return c
end
local function loadSource(source, path, ...)
    local chunk, err = loadstring(source, "@" .. path)
    if not chunk then error(err, 0) end
    return chunk(...)
end

function UnitName() return "TestChar" end
function GetRealmName() return "TestRealm" end
SlashCmdList = SlashCmdList or {}
local RGX = { _databases = {} }
function RGX:Print(...) end
function RGX:Error(...) end
function RGX:Debug(...) end
_G.RGXFramework = RGX

local fw = os.getenv("RGXFW_PATH") or root .. "../RGX-Framework"
loadSource(readFile(fw .. "/core/systems/database.lua"), "fw/database.lua", "RGX-Framework", RGX)

-- defaults extraction (same as run.lua)
local coreSource = readFile(root .. "data/core.lua")
local cut = coreSource:find("function SQP:GetSettingBaseline")
assert(cut, "marker missing")
local defaultsChunkSource = coreSource:sub(1, cut - 1)
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
local addonNamespace = {}
loadSource(defaultsChunkSource, "core-head", "SimpleQuestPlates", addonNamespace)
package.loaded = package.loaded or {}
package.loaded["sqp_defaults"] = assert(addonNamespace.DEFAULTS)

loadSource(readFile(dbgPath), dbgPath, "SimpleQuestPlates", RGX)
