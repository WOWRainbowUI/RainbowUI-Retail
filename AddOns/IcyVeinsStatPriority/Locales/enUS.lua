-- self == L
-- rawset(t, key, value)
-- Sets the value associated with a key in a table without invoking any metamethods
-- t - A table (table)
-- key - A key in the table (cannot be nil) (value)
-- value - New value to set for the key (value)
select(2, ...).L = setmetatable({
    ["HELP"] = "|cff69CCF0Left-Click|r on IVSP to config it\n|cff69CCF0Right-Click|r to view all stat priorities\nSlash command: |cff69CCF0/ivsp|r",
}, {
    __index = function(self, Key)
        if (Key ~= nil) then
            rawset(self, Key, Key)
            return Key
        end
    end
})