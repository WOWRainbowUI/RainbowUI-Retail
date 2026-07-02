local _, MKPT_env = ...

MKPT_env.L = setmetatable({}, {
    __index = function(t, k)
        return k
    end
})