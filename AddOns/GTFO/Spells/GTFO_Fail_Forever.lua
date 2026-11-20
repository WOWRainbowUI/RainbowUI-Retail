--------------------------------------------------------------------------
-- GTFO_Fail_Forever.lua 
--------------------------------------------------------------------------
--[[
GTFO Fail List - WoW: Forever
]]--

if (GTFO.ForeverMode) then


--- *******************
--- * Forever (World) *
--- *******************

GTFO.SpellID["40505"] = {
  --desc = "Cleave";
  instances = {
    389, -- Ragefire Chasm
    2999, -- Ruins of Lordaeron
  };
  sound = 3;
  tankSound = 0;
};

--- *****************
--- * Forever (PvP) *
--- *****************

GTFO.SpellID["3355"] = {
  --desc = "Freezing Trap Effect (PvP - Hunter)";
  map = 0; -- Global
  sound = 3;
  applicationOnly = true;
};


GTFO.SpellID["13797"] = {
  --desc = "Immolation Trap (PvP - Hunter)";
  map = 0; -- Global
  sound = 3;
  applicationOnly = true;
};

--- *****************************
--- * The Hall of Thanes (3065) *
--- *****************************

GTFO.SpellID["1294260"] = {
  --desc = "Throw Dynamite (Dark Iron Engineer)";
  instance = 3065;
  sound = 3;
};


end
