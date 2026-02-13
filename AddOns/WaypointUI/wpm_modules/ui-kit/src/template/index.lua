local env = select(2, ...)
local Utils_Standard = env.WPM:Import("wpm_modules\\utils\\standard")
local UIKit_Template = env.WPM:New("wpm_modules\\ui-kit\\template")

local assert = assert
local type = type

local EMPTY_TABLE = {}

function UIKit_Template.New(constructor)
    assert(constructor, "Invalid variable `constructor`")
    assert(type(constructor) == "function", "Invalid variable `constructor`: Must be of type `function`")

    return function(name, children, ...)
        if type(name) == "table" then
            children = name
            name = nil
        end
        local id = Utils_Standard.GetUniqueID()
        name = name or "undefined"
        return constructor(id, name, children or EMPTY_TABLE, ...)
    end
end
