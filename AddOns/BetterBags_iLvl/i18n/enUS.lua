local L, _, ns = {}, ...;

ns.L = setmetatable(L,{__index=function(t,k)
    local v = tostring(k);
    rawset(t,k,v);
    return v;
end});

L["CATEGORY_NAME"] = "Low iLvl";
L["OPTIONS_DESC"] = "Select the iLvl threshold for this category (all items with an iLvl strictly below this value will be placed in this category). Once the value is changed, a UI reload may be necessary.";
L["OPTIONS_INCLUDE_JUNK"] = "Include poor quality items in this category";
L["OPTIONS_REFRESH"] = "Reload UI";
L["OPTIONS_RESET_DEFAULT"] = "Reset to default";
L["OPTIONS_THRESHOLD"] = "iLvl Threshold (default: _default_)";
L["OPTIONS_THRESHOLD_ERROR"] = "Please enter a valid number for the iLvl threshold.";
