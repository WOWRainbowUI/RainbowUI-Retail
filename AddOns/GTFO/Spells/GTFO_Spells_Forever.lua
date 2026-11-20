--------------------------------------------------------------------------
-- GTFO_Spells_Forever.lua 
--------------------------------------------------------------------------
--[[
GTFO Spell List - WoW: Forever
]]--

if (GTFO.ForeverMode) then


--- *******************
--- * Forever (World) *
--- *******************

GTFO.SpellID["18399"] = {
  --desc = "Flamestrike";
  instances = {
    289, -- Scholomance
    2999, -- Ruins of Lordaeron
  };
  sound = 1;
};


--- *****************
--- * Forever (PvP) *
--- *****************

GTFO.SpellID["26573"] = {
  --desc = "Consecration (PvP - Paladin)";
  map = 0; -- Global
  sound = 2;
};

GTFO.SpellID["2120"] = {
  --desc = "Flamestrike (PvP - Mage)";
  map = 0; -- Global
  sound = 2;
};

GTFO.SpellID["10"] = {
  --desc = "Blizzard (PvP - Mage)";
  map = 0; -- Global
  sound = 2;
};

GTFO.SpellID["5740"] = {
  --desc = "Rain of Fire (PvP - Warlock)";
  map = 0; -- Global
  sound = 2;
};

GTFO.SpellID["5857"] = {
  --desc = "Hellfire Effect (PvP - Warlock)";
  map = 0; -- Global
  sound = 2;
  ignoreSelfInflicted = true;
  test = true; -- Verify self-inflicted Hellfire damage does not cause alerts
};

GTFO.SpellID["16914"] = {
  --desc = "Hurricane (PvP - Druid)";
  map = 0; -- Global
  sound = 2;
};

GTFO.SpellID["8187"] = {
  --desc = "Magma Totem (PvP - Shaman)";
  map = 0; -- Global
  sound = 2;
};

GTFO.SpellID["8349"] = {
  --desc = "Fire Nova (PvP - Shaman)";
  map = 0; -- Global
  sound = 2;
};

GTFO.SpellID["13812"] = {
  --desc = "Explosive Trap (PvP - Hunter)";
  map = 0; -- Global
  sound = 2;
};

--- *************************
--- * Blackrock Spire (229) *
--- *************************

GTFO.SpellID["16805"] = {
  --desc = "Conflagration (General Drakkisath)";
  instance = 229;
  encounter = 3069;
  sound = 4;
};

--- *******************
--- * Gnomeregan (90) *
--- *******************

GTFO.SpellID["10341"] = {
  --desc = "Radiation Cloud (Irradiated Slime)";
  instance = 90;
  sound = 1;
};

--- ******************
--- * Maraudon (349) *
--- ******************

GTFO.SpellID["21070"] = {
  --desc = "Noxious Cloud (Noxious Slime)";
  instance = 349;
  sound = 1;
};

--- ***************************
--- * Scarlet Monastery (189) *
--- ***************************

GTFO.SpellID["8814"] = {
  --desc = "Flame Spike (Bloodmage Thalnos)";
  instance = 189;
  encounter = 2779;
  sound = 1;
};

--- *********************
--- * Scholomance (289) *
--- *********************

GTFO.SpellID["17742"] = {
  --desc = "Cloud of Disease (Diseased Ghoul)";
  instance = 289;
  sound = 1;
};

--- ********************
--- * Stratholme (329) *
--- ********************

GTFO.SpellID["8364"] = {
  --desc = "Blizzard (Skeletal Guardian)";
  instance = 329;
  sound = 1;
};

--- ***********************
--- * Sunken Temple (109) *
--- ***********************

GTFO.SpellID["12468"] = {
  --desc = "Flamestrike (Jammal'an the Prophet)";
  instance = 109;
  encounter = 3589;
  sound = 1;
};

end
