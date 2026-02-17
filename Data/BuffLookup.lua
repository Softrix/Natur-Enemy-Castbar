--[[

      Natur Buff Lookup Table for Classic Era, Classic Hardcore, SoD, TBC Anniversary, WotLK Classic, and MoP Classic.

  ]]

if not _G.NaturBuffDB then
  _G.NaturBuffDB = {}
end
local DB = _G.NaturBuffDB

-- =============================================================================
-- DRUID
-- =============================================================================
-- Buffs
DB[5232]   = { duration = 1800,  class = "DRUID" }    -- Mark of the Wild (Rank 1)
DB[5234]   = { duration = 1800,  class = "DRUID" }    -- Mark of the Wild (Rank 2)
DB[6756]   = { duration = 1800,  class = "DRUID" }    -- Mark of the Wild (Rank 3)
DB[5235]   = { duration = 1800, class = "DRUID" }    -- Mark of the Wild (Rank 4)
DB[6787]   = { duration = 1800, class = "DRUID" }    -- Mark of the Wild (Rank 5)
DB[6788]   = { duration = 1800, class = "DRUID" }    -- Mark of the Wild (Rank 6)
DB[8907]   = { duration = 1800, class = "DRUID" }    -- Mark of the Wild (Rank 7)
DB[9884]   = { duration = 1800, class = "DRUID" }    -- Mark of the Wild (Rank 8)
DB[9885]   = { duration = 1800, class = "DRUID" }    -- Mark of the Wild (Rank 9)
DB[26990]  = { duration = 1800, class = "DRUID" }    -- Mark of the Wild (Rank 10) TBC
DB[21849]  = { duration = 1800, class = "DRUID" }    -- Gift of the Wild (Rank 1)
DB[21850]  = { duration = 3600,  class = "DRUID" }    -- Gift of the Wild (Rank 2)
DB[26991]  = { duration = 3600,  class = "DRUID" }    -- Gift of the Wild (Rank 3) TBC
DB[467]    = { duration = 600,   class = "DRUID" }    -- Thorns (Rank 1)
DB[782]    = { duration = 600,   class = "DRUID" }    -- Thorns (Rank 2)
DB[1075]   = { duration = 600,   class = "DRUID" }   -- Thorns (Rank 3)
DB[8914]   = { duration = 600,   class = "DRUID" }   -- Thorns (Rank 4)
DB[9756]   = { duration = 600,   class = "DRUID" }   -- Thorns (Rank 5)
DB[9910]   = { duration = 600,   class = "DRUID" }   -- Thorns (Rank 6)
DB[26992]  = { duration = 600,   class = "DRUID" }    -- Thorns (Rank 7) TBC
DB[1126]   = { duration = 1800,  class = "DRUID" }    -- Mark of the Wild (old rank)
DB[7737]   = { duration = 600,   class = "DRUID" }   -- Grace of Air Totem effect (from Shaman)
DB[16870]  = { duration = 15,    cooldown = 0,    class = "DRUID" }    -- Clearcasting (Omen of Clarity, proc)
DB[24858]  = { duration = 15,    class = "DRUID" }    -- Moonkin Form (aura)
DB[9634]   = { duration = 120,   class = "DRUID" }    -- Dire Bear Form (aura)
DB[768]    = { duration = 0,     class = "DRUID" }    -- Cat Form (until cancelled)
DB[783]    = { duration = 0,     class = "DRUID" }    -- Travel Form (until cancelled)
DB[5487]   = { duration = 0,     class = "DRUID" }    -- Bear Form (until cancelled)
DB[1066]   = { duration = 0,     class = "DRUID" }    -- Aquatic Form (until cancelled)
DB[5215]   = { duration = 0,     class = "DRUID" }    -- Prowl (Rank 1, until cancelled)
DB[6783]   = { duration = 0,     class = "DRUID" }    -- Prowl (Rank 2)
DB[9913]   = { duration = 0,     class = "DRUID" }    -- Prowl (Rank 3)
DB[24450]  = { duration = 0,     class = "DRUID" }   -- Prowl (Rank 4) TBC
DB[24452]  = { duration = 0,     class = "DRUID" }   -- Prowl (Rank 5) TBC
DB[24453]  = { duration = 0,     class = "DRUID" }   -- Prowl (Rank 6) TBC
-- Defensives / major cooldowns
DB[17116]  = { duration = 15,    cooldown = 180,  class = "DRUID" }    -- Nature's Swiftness (3 min)
DB[29166]  = { duration = 3600,  cooldown = 180,  class = "DRUID" }    -- Innervate (TBC, 3 min CD)
DB[22812]  = { duration = 12,    cooldown = 60,   class = "DRUID" }    -- Barkskin (1 min)
DB[22842]  = { duration = 30,    cooldown = 180,  class = "DRUID" }    -- Frenzied Regeneration (3 min)
DB[5217]   = { duration = 6,     cooldown = 30,   class = "DRUID" }    -- Tiger's Fury (30s) combat
DB[50322]  = { duration = 6,     cooldown = 180,  class = "DRUID" }    -- Survival Instincts (SoD/Classic, 3 min)
DB[102342] = { duration = 12,    cooldown = 60,   class = "DRUID" }    -- Ironbark (MoP, 1 min)
DB[106922] = { duration = 20,    cooldown = 180,  class = "DRUID" }    -- Might of Ursoc (MoP, 3 min)
-- Healing
DB[5185]   = { duration = 0,     class = "DRUID",   healing = true }   -- Healing Touch (Rank 1)
DB[5186]   = { duration = 0,     class = "DRUID",   healing = true }   -- Healing Touch (Rank 2)
DB[5187]   = { duration = 0,     class = "DRUID",   healing = true }   -- Healing Touch (Rank 3)
DB[5188]   = { duration = 0,     class = "DRUID",   healing = true }   -- Healing Touch (Rank 4)
DB[5189]   = { duration = 0,     class = "DRUID",   healing = true }   -- Healing Touch (Rank 5)
DB[6778]   = { duration = 0,     class = "DRUID",   healing = true }   -- Healing Touch (Rank 6)
DB[8903]   = { duration = 0,     class = "DRUID",   healing = true }   -- Healing Touch (Rank 7)
DB[9758]   = { duration = 0,     class = "DRUID",   healing = true }   -- Healing Touch (Rank 8)
DB[25297]  = { duration = 0,     class = "DRUID",   healing = true }   -- Healing Touch (Rank 9) TBC
DB[8936]   = { duration = 0,     class = "DRUID",   healing = true }   -- Regrowth (Rank 1)
DB[8938]   = { duration = 0,     class = "DRUID",   healing = true }   -- Regrowth (Rank 2)
DB[8939]   = { duration = 0,     class = "DRUID",   healing = true }   -- Regrowth (Rank 3)
DB[8940]   = { duration = 0,     class = "DRUID",   healing = true }   -- Regrowth (Rank 4)
DB[8941]   = { duration = 0,     class = "DRUID",   healing = true }   -- Regrowth (Rank 5)
DB[9750]   = { duration = 0,     class = "DRUID",   healing = true }   -- Regrowth (Rank 6)
DB[9856]   = { duration = 0,     class = "DRUID",   healing = true }   -- Regrowth (Rank 7)
DB[9857]   = { duration = 0,     class = "DRUID",   healing = true }   -- Regrowth (Rank 8)
DB[9858]   = { duration = 0,     class = "DRUID",   healing = true }   -- Regrowth (Rank 9)
DB[25298]  = { duration = 0,     class = "DRUID",   healing = true }   -- Regrowth (Rank 10) TBC
DB[33763]  = { duration = 7,    class = "DRUID",   healing = true }   -- Lifebloom (TBC, HoT)
-- Interrupts / stuns (also CC)
DB[5211]   = { duration = 60,   cooldown = 60,   class = "DRUID",    crowdcontrol = true }    -- Bash (1 min stun/interrupt)
DB[9754]   = { duration = 60,   cooldown = 60,   class = "DRUID",    crowdcontrol = true }    -- Bash (Rank 2)
-- Crowd control (roots, hibernate, cyclone-style)
DB[2637]   = { duration = 20,   cooldown = 0,    class = "DRUID",    crowdcontrol = true, diminish = true }    -- Hibernate (20s, Beast/Dragon)
DB[339]    = { duration = 12,   cooldown = 0,    class = "DRUID",    crowdcontrol = true, diminish = true }     -- Entangling Roots (12s)
DB[1062]   = { duration = 27,   cooldown = 0,    class = "DRUID",    crowdcontrol = true, diminish = true }    -- Entangling Roots (Rank 2)
DB[5195]   = { duration = 24,   cooldown = 0,    class = "DRUID",    crowdcontrol = true, diminish = true }     -- Entangling Roots (Rank 3)
DB[5196]   = { duration = 24,   cooldown = 0,    class = "DRUID",    crowdcontrol = true, diminish = true }     -- Entangling Roots (Rank 4)
DB[9852]   = { duration = 27,   cooldown = 0,    class = "DRUID",    crowdcontrol = true, diminish = true }     -- Entangling Roots (Rank 5)
DB[9853]   = { duration = 27,   cooldown = 0,    class = "DRUID",    crowdcontrol = true, diminish = true }     -- Entangling Roots (Rank 6)
DB[26989]  = { duration = 27,   cooldown = 0,    class = "DRUID",    crowdcontrol = true, diminish = true }     -- Entangling Roots (TBC)
-- Dispel
DB[2782]   = { duration = 0,     class = "DRUID",   dispell = true }   -- Remove Curse
DB[8946]   = { duration = 0,     class = "DRUID",   dispell = true }   -- Cure Poison
DB[2893]   = { duration = 0,     class = "DRUID",   dispell = true }   -- Abolish Poison
DB[88423]  = { duration = 0,     class = "DRUID",   dispell = true }   -- Nature's Cure (MoP, magic/poison/curse/disease)

-- =============================================================================
-- HUNTER
-- =============================================================================
-- Buffs
DB[13165]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Hawk (until cancelled)
DB[14318]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Hawk (Rank 2)
DB[14319]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Hawk (Rank 3)
DB[14320]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Hawk (Rank 4)
DB[14321]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Hawk (Rank 5)
DB[14322]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Hawk (Rank 6)
DB[25296]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Hawk (Rank 7)
DB[27044]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Hawk (Rank 8) TBC
DB[13161]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Beast
DB[5118]   = { duration = 0,     class = "HUNTER" }   -- Aspect of the Cheetah
DB[13163]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Monkey
DB[13159]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Pack
DB[20043]  = { duration = 0,     class = "HUNTER" }   -- Aspect of the Wild (TBC)
DB[19506]  = { duration = 0,     class = "HUNTER" }   -- Trueshot Aura (aura)
DB[20906]  = { duration = 15,    class = "HUNTER" }   -- Trueshot Aura (buff when in group)
DB[6197]   = { duration = 60,    class = "HUNTER" }   -- Eagle Eye (buff)
-- Defensives / major cooldowns
DB[34477]  = { duration = 15,    cooldown = 30,   class = "HUNTER" }   -- Misdirection (TBC, 30s)
DB[19574]  = { duration = 18,    cooldown = 120,  class = "HUNTER" }   -- Bestial Wrath (2 min) combat
DB[19263]  = { duration = 5,     cooldown = 300,  class = "HUNTER" }   -- Deterrence (5 min)
DB[3045]   = { duration = 15,    cooldown = 300,  class = "HUNTER" }   -- Rapid Fire (5 min)
DB[23989]  = { duration = 15,    cooldown = 300,  class = "HUNTER" }   -- Readiness (5 min)
DB[35098]  = { duration = 15,    cooldown = 120,  class = "HUNTER" }   -- Rapid Killing (TBC, 2 min)
DB[26064]  = { duration = 15,    cooldown = 30,   class = "HUNTER" }   -- Shell Shield (TBC, 30s)
-- Crowd control (traps, scatter, scare beast)
DB[1499]   = { duration = 20,   cooldown = 30,   class = "HUNTER",   crowdcontrol = true }    -- Freezing Trap (Rank 1)
DB[14310]  = { duration = 20,   cooldown = 30,   class = "HUNTER",   crowdcontrol = true }    -- Freezing Trap (Rank 2)
DB[14311]  = { duration = 20,   cooldown = 30,   class = "HUNTER",   crowdcontrol = true }    -- Freezing Trap (Rank 3)
DB[3355]   = { duration = 20,   cooldown = 30,   class = "HUNTER",   crowdcontrol = true }    -- Freezing Trap effect (aura)
DB[13809]  = { duration = 4,    cooldown = 30,   class = "HUNTER",   crowdcontrol = true }    -- Frost Trap (snare)
DB[19503]  = { duration = 4,    cooldown = 30,   class = "HUNTER",   crowdcontrol = true }    -- Scatter Shot (4s, 30s CD)
DB[1513]   = { duration = 4,    cooldown = 30,   class = "HUNTER",   crowdcontrol = true }    -- Scare Beast (4s, 30s CD)

-- =============================================================================
-- MAGE
-- =============================================================================
-- Buffs
DB[1459]   = { duration = 1800,  class = "MAGE" }     -- Arcane Intellect (Rank 1)
DB[1460]   = { duration = 1800,  class = "MAGE" }     -- Arcane Intellect (Rank 2)
DB[1461]   = { duration = 1800,  class = "MAGE" }     -- Arcane Intellect (Rank 3)
DB[10156]  = { duration = 1800,  class = "MAGE" }     -- Arcane Intellect (Rank 4)
DB[10157]  = { duration = 1800,  class = "MAGE" }     -- Arcane Intellect (Rank 5)
DB[27126]  = { duration = 1800, class = "MAGE" }     -- Arcane Intellect (Rank 6) TBC
DB[23028]  = { duration = 1800, class = "MAGE" }     -- Arcane Brilliance (party)
DB[10169]  = { duration = 600,   class = "MAGE" }     -- Amplify Magic (Rank 1)
DB[10170]  = { duration = 600,   class = "MAGE" }     -- Amplify Magic (Rank 2)
DB[27130]  = { duration = 600,   class = "MAGE" }     -- Amplify Magic (Rank 3) TBC
DB[604]    = { duration = 600,   class = "MAGE" }     -- Dampen Magic (Rank 1)
DB[8450]   = { duration = 600,   class = "MAGE" }     -- Dampen Magic (Rank 2)
DB[8451]   = { duration = 600,   class = "MAGE" }     -- Dampen Magic (Rank 3)
DB[10173]  = { duration = 600,   class = "MAGE" }     -- Dampen Magic (Rank 4)
DB[10174]  = { duration = 600,   class = "MAGE" }     -- Dampen Magic (Rank 5)
DB[27128]  = { duration = 600,   class = "MAGE" }     -- Dampen Magic (Rank 6) TBC
DB[543]    = { duration = 1800,  class = "MAGE" }     -- Fire Ward (Rank 1)
DB[8457]   = { duration = 1800, class = "MAGE" }     -- Fire Ward (Rank 2)
DB[8458]   = { duration = 1800, class = "MAGE" }     -- Fire Ward (Rank 3)
DB[10223]  = { duration = 1800, class = "MAGE" }     -- Fire Ward (Rank 4)
DB[10225]  = { duration = 1800, class = "MAGE" }     -- Fire Ward (Rank 5)
DB[27134]  = { duration = 1800, class = "MAGE" }     -- Fire Ward (Rank 6) TBC
DB[6143]   = { duration = 1800,  class = "MAGE" }     -- Frost Ward (Rank 1)
DB[8461]   = { duration = 1800, class = "MAGE" }     -- Frost Ward (Rank 2)
DB[8462]   = { duration = 1800, class = "MAGE" }     -- Frost Ward (Rank 3)
DB[10177]  = { duration = 1800, class = "MAGE" }     -- Frost Ward (Rank 4)
DB[28609]  = { duration = 1800, class = "MAGE" }     -- Frost Ward (Rank 5) TBC
DB[130]    = { duration = 300,   class = "MAGE" }     -- Slow Fall
DB[80353]  = { duration = 40,    cooldown = 300,  class = "MAGE" }     -- Time Warp (MoP, 5 min)
-- Defensives / major cooldowns
DB[11426]  = { duration = 30,    cooldown = 30,   class = "MAGE" }     -- Ice Barrier (Rank 1)
DB[13031]  = { duration = 30,    cooldown = 30,   class = "MAGE" }     -- Ice Barrier (Rank 2)
DB[13032]  = { duration = 30,    cooldown = 30,   class = "MAGE" }     -- Ice Barrier (Rank 3)
DB[13033]  = { duration = 30,    cooldown = 30,   class = "MAGE" }     -- Ice Barrier (Rank 4)
DB[33405]  = { duration = 30,    cooldown = 30,   class = "MAGE" }     -- Ice Barrier (TBC rank)
DB[12042]  = { duration = 15,    cooldown = 180,  class = "MAGE" }     -- Arcane Power (3 min)
DB[12043]  = { duration = 20,    cooldown = 180,  class = "MAGE" }     -- Presence of Mind (3 min)
DB[28682]  = { duration = 30,    cooldown = 120,  class = "MAGE" }     -- Combustion (2 min)
DB[1953]   = { duration = 0,     cooldown = 15,   class = "MAGE" }     -- Blink (15s CD, movement)
DB[11958]  = { duration = 10,    cooldown = 300,  class = "MAGE" }     -- Ice Block (Classic, 5 min)
DB[45438]  = { duration = 10,    cooldown = 300,  class = "MAGE" }     -- Ice Block (TBC, 5 min)
DB[12051]  = { duration = 8,     cooldown = 480,  class = "MAGE" }     -- Evocation (8 min)
DB[66]     = { duration = 20,    cooldown = 300,  class = "MAGE" }     -- Invisibility (5 min)
DB[425124] = { duration = 8,    cooldown = 120,  class = "MAGE" }    -- Arcane Surge (SoD, 8s buff, 2 min CD)
-- Interrupts
DB[2139]   = { duration = 10,   cooldown = 30,   class = "MAGE" }      -- Counterspell (30s, 10s lockout)
-- Crowd control (polymorph, deep freeze)
DB[118]    = { duration = 20,   cooldown = 0,    class = "MAGE",      crowdcontrol = true, diminish = true }      -- Polymorph (Rank 1)
DB[12824]  = { duration = 30,   cooldown = 0,    class = "MAGE",      crowdcontrol = true, diminish = true }      -- Polymorph (Rank 2)
DB[12825]  = { duration = 30,   cooldown = 0,    class = "MAGE",      crowdcontrol = true, diminish = true }      -- Polymorph (Rank 3)
DB[12826]  = { duration = 30,   cooldown = 0,    class = "MAGE",      crowdcontrol = true, diminish = true }      -- Polymorph (Rank 4)
DB[61305]  = { duration = 50,   cooldown = 0,    class = "MAGE",      crowdcontrol = true, diminish = true }      -- Polymorph: Black Cat (TBC)
DB[28272]  = { duration = 50,   cooldown = 0,    class = "MAGE",      crowdcontrol = true, diminish = true }      -- Polymorph: Pig (TBC)
DB[61721]  = { duration = 50,   cooldown = 0,    class = "MAGE",      crowdcontrol = true, diminish = true }      -- Polymorph: Rabbit (TBC)
DB[61780]  = { duration = 50,   cooldown = 0,    class = "MAGE",      crowdcontrol = true, diminish = true }      -- Polymorph: Turkey (TBC)
-- Dispel
DB[475]    = { duration = 0,     class = "MAGE",    dispell = true }   -- Remove Lesser Curse

-- =============================================================================
-- MONK (MoP Classic)
-- =============================================================================
-- Buffs
DB[115921] = { duration = 3600,  class = "MONK" }    -- Legacy of the Emperor (stats)
DB[116781] = { duration = 3600,  class = "MONK" }    -- Legacy of the White Tiger (crit)
DB[116841] = { duration = 6,     cooldown = 30,   class = "MONK" }     -- Tiger's Lust (freedom/sprint)
-- Defensives / major cooldowns
DB[115203] = { duration = 15,    cooldown = 120,  class = "MONK" }     -- Fortifying Brew (2 min)
DB[115176] = { duration = 8,     cooldown = 180,  class = "MONK" }     -- Zen Meditation (3 min, channel)
DB[122470] = { duration = 10,    cooldown = 90,   class = "MONK" }     -- Touch of Karma (90s)
DB[122783] = { duration = 6,     cooldown = 120,  class = "MONK" }     -- Diffuse Magic (2 min)
DB[122278] = { duration = 6,     cooldown = 90,   class = "MONK" }     -- Dampen Harm (90s)
-- Healing
DB[115175] = { duration = 0,     class = "MONK",   healing = true }    -- Soothing Mist (channel)
DB[116670] = { duration = 0,     class = "MONK",   healing = true }   -- Vivify
DB[124081] = { duration = 30,    class = "MONK",   healing = true }    -- Zen Sphere (HoT)
DB[115310] = { duration = 0,     cooldown = 180,  class = "MONK",   healing = true }  -- Revival (3 min)
DB[119611] = { duration = 0,     class = "MONK",   healing = true }   -- Renewing Mist (HoT)
-- Interrupts
DB[116705] = { duration = 4,     cooldown = 15,   class = "MONK" }     -- Spear Hand Strike (15s, 4s lockout)
-- Crowd control
DB[115078] = { duration = 4,     cooldown = 15,   class = "MONK",   crowdcontrol = true, diminish = true }   -- Paralysis (incapacitate)
DB[119381] = { duration = 5,     cooldown = 45,   class = "MONK",   crowdcontrol = true, diminish = true }   -- Leg Sweep (stun)
DB[116844] = { duration = 5,     cooldown = 45,   class = "MONK",   crowdcontrol = true, diminish = true }   -- Ring of Peace (disorient/knock)
DB[116095] = { duration = 6,     cooldown = 15,   class = "MONK",   crowdcontrol = true, diminish = true }    -- Disable (slow)
-- Dispel
DB[115450] = { duration = 0,     class = "MONK",   dispell = true }    -- Detox (poison/disease)

-- =============================================================================
-- PALADIN
-- =============================================================================
-- Buffs (blessings, auras, seals)
DB[19740]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Might (Rank 1)
DB[19834]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Might (Rank 2)
DB[19835]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Might (Rank 3)
DB[19836]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Might (Rank 4)
DB[19837]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Might (Rank 5)
DB[19838]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Might (Rank 6)
DB[25291]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Might (Rank 7)
DB[27140]  = { duration = 600,   class = "PALADIN" }  -- Blessing of Might (Rank 8) TBC
DB[25782]  = { duration = 1800, class = "PALADIN" }  -- Greater Blessing of Might TBC
DB[19742]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Wisdom (Rank 1)
DB[19850]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Wisdom (Rank 2)
DB[19852]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Wisdom (Rank 3)
DB[19853]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Wisdom (Rank 4)
DB[19854]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Wisdom (Rank 5)
DB[25290]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Wisdom (Rank 6)
DB[27142]  = { duration = 600,   class = "PALADIN" }  -- Blessing of Wisdom (Rank 7) TBC
DB[25894]  = { duration = 1800, class = "PALADIN" }  -- Greater Blessing of Wisdom TBC
DB[20217]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Kings (5 min Classic)
DB[25898]  = { duration = 1800, class = "PALADIN" }  -- Greater Blessing of Kings TBC (30 min)
DB[19977]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Light (Rank 1)
DB[19978]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Light (Rank 2)
DB[19979]  = { duration = 300,   class = "PALADIN" }  -- Blessing of Light (Rank 3)
DB[25890]  = { duration = 1800, class = "PALADIN" }  -- Greater Blessing of Light TBC
DB[1038]   = { duration = 300,   class = "PALADIN" }  -- Blessing of Salvation
DB[25895]  = { duration = 1800, class = "PALADIN" }  -- Greater Blessing of Salvation TBC
DB[1040]   = { duration = 300,   class = "PALADIN" }  -- Blessing of Sanctuary
DB[25899]  = { duration = 1800, class = "PALADIN" }  -- Greater Blessing of Sanctuary TBC
DB[19746]  = { duration = 300,   class = "PALADIN" }  -- Concentration Aura (aura)
DB[465]    = { duration = 0,     class = "PALADIN" }  -- Devotion Aura (aura)
DB[19876]  = { duration = 0,     class = "PALADIN" }  -- Shadow Resistance Aura (aura)
DB[19888]  = { duration = 0,     class = "PALADIN" }  -- Frost Resistance Aura (aura)
DB[19891]  = { duration = 0,     class = "PALADIN" }  -- Fire Resistance Aura (aura)
DB[20050]  = { duration = 0,     class = "PALADIN" }  -- Retribution Aura (aura)
DB[20164]  = { duration = 0,     class = "PALADIN" }  -- Seal of Justice (aura)
DB[20165]  = { duration = 30,    class = "PALADIN" }  -- Seal of Light (aura)
DB[21084]  = { duration = 30,    class = "PALADIN" }  -- Seal of Righteousness (aura)
DB[31801]  = { duration = 30,    class = "PALADIN" }  -- Seal of Vengeance (TBC)
DB[31892]  = { duration = 30,    class = "PALADIN" }  -- Seal of Blood (TBC)
DB[28734]  = { duration = 30,    class = "PALADIN" }  -- Mana Tap (Blood Elf)
DB[20911]  = { duration = 120,   class = "PALADIN" }  -- Blessing of Sanctuary (old)
-- Defensives / major cooldowns
DB[1022]   = { duration = 6,     cooldown = 300,  class = "PALADIN" }  -- Blessing of Protection (5 min)
DB[5599]   = { duration = 10,    cooldown = 300,  class = "PALADIN" }  -- Blessing of Protection (Rank 2)
DB[10278]  = { duration = 10,    cooldown = 300,  class = "PALADIN" }  -- Blessing of Protection (Rank 3)
DB[6940]   = { duration = 12,    cooldown = 30,   class = "PALADIN" }  -- Blessing of Sacrifice (30s)
DB[31821]  = { duration = 20,    cooldown = 120,  class = "PALADIN" }  -- Aura Mastery (TBC, 2 min)
DB[642]    = { duration = 10,   cooldown = 300,  class = "PALADIN" }  -- Divine Shield (5 min) PvP
DB[498]    = { duration = 8,    cooldown = 300,  class = "PALADIN" }   -- Divine Protection (5 min)
DB[31884]  = { duration = 20,   cooldown = 180,  class = "PALADIN" }   -- Avenging Wrath (TBC, 3 min)
DB[20925]  = { duration = 10,   cooldown = 10,   class = "PALADIN" }   -- Holy Shield (10s duration, 10s CD)
-- Healing
DB[635]    = { duration = 0,     class = "PALADIN", healing = true }  -- Holy Light (Rank 1)
DB[639]    = { duration = 0,     class = "PALADIN", healing = true }  -- Holy Light (Rank 2)
DB[647]    = { duration = 0,     class = "PALADIN", healing = true }  -- Holy Light (Rank 3)
DB[1026]   = { duration = 0,     class = "PALADIN", healing = true }  -- Holy Light (Rank 4)
DB[1042]   = { duration = 0,     class = "PALADIN", healing = true }  -- Holy Light (Rank 5)
DB[3472]   = { duration = 0,     class = "PALADIN", healing = true }  -- Holy Light (Rank 6)
DB[10328]  = { duration = 0,     class = "PALADIN", healing = true }  -- Holy Light (Rank 7)
DB[10329]  = { duration = 0,     class = "PALADIN", healing = true }  -- Holy Light (Rank 8)
DB[25292]  = { duration = 0,     class = "PALADIN", healing = true }  -- Holy Light (Rank 9) TBC
DB[27135]  = { duration = 0,     class = "PALADIN", healing = true }  -- Holy Light (Rank 10) TBC
DB[19750]  = { duration = 0,     class = "PALADIN", healing = true }  -- Flash of Light (Rank 1)
DB[19939]  = { duration = 0,     class = "PALADIN", healing = true }  -- Flash of Light (Rank 2)
DB[19940]  = { duration = 0,     class = "PALADIN", healing = true }  -- Flash of Light (Rank 3)
DB[19941]  = { duration = 0,     class = "PALADIN", healing = true }  -- Flash of Light (Rank 4)
DB[19942]  = { duration = 0,     class = "PALADIN", healing = true }  -- Flash of Light (Rank 5)
DB[19943]  = { duration = 0,     class = "PALADIN", healing = true }  -- Flash of Light (Rank 6)
DB[27137]  = { duration = 0,     class = "PALADIN", healing = true }  -- Flash of Light (Rank 7) TBC
-- Crowd control (stuns)
DB[853]    = { duration = 3,    cooldown = 30,   class = "PALADIN",  crowdcontrol = true }   -- Hammer of Justice (Rank 1)
DB[5588]   = { duration = 4,    cooldown = 30,   class = "PALADIN",  crowdcontrol = true }   -- Hammer of Justice (Rank 2)
DB[5589]   = { duration = 5,    cooldown = 30,   class = "PALADIN",  crowdcontrol = true }   -- Hammer of Justice (Rank 3)
DB[10308]  = { duration = 6,    cooldown = 30,   class = "PALADIN",  crowdcontrol = true }   -- Hammer of Justice (Rank 4)
-- Dispel
DB[4987]   = { duration = 0,     class = "PALADIN", dispell = true }  -- Cleanse (poison/disease/magic)

-- =============================================================================
-- PRIEST
-- =============================================================================
-- Buffs
DB[1243]   = { duration = 1800,  class = "PRIEST" }   -- Power Word: Fortitude (Rank 1)
DB[1244]   = { duration = 1800,  class = "PRIEST" }   -- Power Word: Fortitude (Rank 2)
DB[1245]   = { duration = 1800,  class = "PRIEST" }   -- Power Word: Fortitude (Rank 3)
DB[2791]   = { duration = 1800,  class = "PRIEST" }   -- Power Word: Fortitude (Rank 4)
DB[10937]  = { duration = 1800,  class = "PRIEST" }   -- Power Word: Fortitude (Rank 5)
DB[10938]  = { duration = 1800,  class = "PRIEST" }   -- Power Word: Fortitude (Rank 6)
DB[21562]  = { duration = 3600,  class = "PRIEST" }   -- Prayer of Fortitude
DB[14752]  = { duration = 1800,  class = "PRIEST" }   -- Divine Spirit (Rank 1)
DB[14818]  = { duration = 1800,  class = "PRIEST" }   -- Divine Spirit (Rank 2)
DB[14819]  = { duration = 1800,  class = "PRIEST" }   -- Divine Spirit (Rank 3)
DB[27841]  = { duration = 1800,  class = "PRIEST" }   -- Divine Spirit (Rank 4)
DB[25312]  = { duration = 1800,  class = "PRIEST" }   -- Divine Spirit (Rank 5)
DB[27681]  = { duration = 3600,  class = "PRIEST" }   -- Prayer of Spirit
DB[976]    = { duration = 600,   class = "PRIEST" }   -- Shadow Protection (Rank 1)
DB[10957]  = { duration = 600,   class = "PRIEST" }   -- Shadow Protection (Rank 2)
DB[10958]  = { duration = 600,   class = "PRIEST" }   -- Shadow Protection (Rank 3)
DB[25433]  = { duration = 600,   class = "PRIEST" }   -- Shadow Protection (Rank 4)
DB[27683]  = { duration = 600,   class = "PRIEST" }   -- Prayer of Shadow Protection
DB[2096]   = { duration = 30,    class = "PRIEST" }   -- Mind Vision
DB[14767]  = { duration = 1800, class = "PRIEST" }   -- Inner Fire (various ranks)
DB[588]    = { duration = 1800, class = "PRIEST" }   -- Inner Fire (Rank 1)
DB[7128]   = { duration = 1800, class = "PRIEST" }   -- Inner Fire (Rank 2)
DB[602]    = { duration = 1800, class = "PRIEST" }   -- Inner Fire (Rank 3)
DB[1006]   = { duration = 600,   class = "PRIEST" }   -- Inner Fire (Rank 4)
DB[10951]  = { duration = 1800, class = "PRIEST" }   -- Inner Fire (Rank 5)
DB[10952]  = { duration = 1800, class = "PRIEST" }   -- Inner Fire (Rank 6)
DB[25431]  = { duration = 1800, class = "PRIEST" }   -- Inner Fire (Rank 7)
DB[15258]  = { duration = 1800, class = "PRIEST" }   -- Shadow Weaving (Rank 1)
DB[15318]  = { duration = 1800, class = "PRIEST" }   -- Shadow Weaving (Rank 2)
DB[15319]  = { duration = 1800, class = "PRIEST" }   -- Shadow Weaving (Rank 3)
DB[15320]  = { duration = 1800, class = "PRIEST" }   -- Shadow Weaving (Rank 4)
DB[27827]  = { duration = 1800, class = "PRIEST" }   -- Spirit of Redemption
DB[402799] = { duration = 120,   cooldown = 120,  class = "PRIEST" }  -- Homunculi (SoD, 2 min)
-- Defensives / major cooldowns
DB[10060]  = { duration = 15,    cooldown = 180,  class = "PRIEST" }   -- Power Infusion (3 min)
DB[33206]  = { duration = 8,     cooldown = 120,  class = "PRIEST" }   -- Pain Suppression (TBC, 2 min)
DB[6346]   = { duration = 600,   cooldown = 30,   class = "PRIEST" }   -- Fear Ward (10 min buff, 30s CD) PvP
DB[73325]  = { duration = 0,     cooldown = 90,   class = "PRIEST" }   -- Leap of Faith (MoP, 90s)
DB[108968] = { duration = 0,     cooldown = 300,  class = "PRIEST" }   -- Void Shift (MoP, 5 min)
-- Healing
DB[2054]   = { duration = 0,     class = "PRIEST",  healing = true }   -- Heal (Rank 1)
DB[2055]   = { duration = 0,     class = "PRIEST",  healing = true }   -- Heal (Rank 2)
DB[2056]   = { duration = 0,     class = "PRIEST",  healing = true }   -- Heal (Rank 3)
DB[2060]   = { duration = 0,     class = "PRIEST",  healing = true }   -- Greater Heal (Rank 1)
DB[10963]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Greater Heal (Rank 2)
DB[10964]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Greater Heal (Rank 3)
DB[10965]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Greater Heal (Rank 4)
DB[25314]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Greater Heal (Rank 5) TBC
DB[2061]   = { duration = 0,     class = "PRIEST",  healing = true }   -- Flash Heal (Rank 1)
DB[10917]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Flash Heal (Rank 2)
DB[10927]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Flash Heal (Rank 3)
DB[10928]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Flash Heal (Rank 4)
DB[10929]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Flash Heal (Rank 5)
DB[25315]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Flash Heal (Rank 6) TBC
DB[596]    = { duration = 0,     class = "PRIEST",  healing = true }   -- Prayer of Healing (Rank 1)
DB[996]    = { duration = 0,     class = "PRIEST",  healing = true }   -- Prayer of Healing (Rank 2)
DB[10960]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Prayer of Healing (Rank 3)
DB[10961]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Prayer of Healing (Rank 4)
DB[25316]  = { duration = 0,     class = "PRIEST",  healing = true }   -- Prayer of Healing (Rank 5) TBC
DB[139]    = { duration = 0,     class = "PRIEST",  healing = true }   -- Renew (Rank 1)
DB[6074]   = { duration = 0,     class = "PRIEST",  healing = true }   -- Renew (Rank 2)
DB[6075]   = { duration = 0,     class = "PRIEST",  healing = true }   -- Renew (Rank 3)
DB[6076]   = { duration = 0,     class = "PRIEST",  healing = true }   -- Renew (Rank 4)
DB[6077]   = { duration = 0,     class = "PRIEST",  healing = true }   -- Renew (Rank 5)
DB[6078]   = { duration = 0,     class = "PRIEST",  healing = true }   -- Renew (Rank 6)
DB[402174] = { duration = 0,     cooldown = 12,   class = "PRIEST",  healing = true }   -- Penance (SoD, channeled heal/damage, 12s CD)
-- Crowd control
DB[8122]   = { duration = 8,    cooldown = 30,   class = "PRIEST",   crowdcontrol = true }    -- Psychic Scream (Fear, 30s CD)
-- Dispel
DB[527]    = { duration = 0,     class = "PRIEST",  dispell = true }   -- Dispel Magic (Rank 1)
DB[988]    = { duration = 0,     class = "PRIEST",  dispell = true }   -- Dispel Magic (Rank 2)
DB[528]    = { duration = 0,     class = "PRIEST",  dispell = true }   -- Cure Disease
DB[1152]   = { duration = 0,     class = "PRIEST",  dispell = true }   -- Purify (disease/poison)

-- =============================================================================
-- ROGUE
-- =============================================================================
-- Buffs / stealth
DB[1784]   = { duration = 0,     class = "ROGUE" }    -- Stealth (until cancelled)
DB[2836]   = { duration = 0,     class = "ROGUE" }    -- Detect Traps (until cancelled)
DB[5171]   = { duration = 0,     class = "ROGUE" }    -- Slice and Dice (until cancelled)
DB[31665]  = { duration = 10,    cooldown = 0,    class = "ROGUE" }    -- Master of Subtlety (TBC, no CD)
-- Defensives / major cooldowns
DB[2983]   = { duration = 15,    cooldown = 300,  class = "ROGUE" }    -- Sprint (5 min)
DB[1856]   = { duration = 5,     cooldown = 300,  class = "ROGUE" }    -- Vanish (5 min)
DB[31224]  = { duration = 5,     cooldown = 60,   class = "ROGUE" }    -- Cloak of Shadows (TBC, 1 min)
DB[13750]  = { duration = 15,    cooldown = 300,  class = "ROGUE" }    -- Adrenaline Rush (5 min)
DB[13877]  = { duration = 6,     cooldown = 120,  class = "ROGUE" }    -- Blade Flurry (2 min)
DB[14177]  = { duration = 20,    cooldown = 180,  class = "ROGUE" }    -- Cold Blood (3 min)
DB[14251]  = { duration = 6,     cooldown = 6,    class = "ROGUE" }    -- Riposte (6s)
DB[5277]   = { duration = 15,   cooldown = 300,  class = "ROGUE" }    -- Evasion (Classic, 5 min)
DB[26669]  = { duration = 15,   cooldown = 120,  class = "ROGUE" }    -- Evasion (TBC, 2 min)
-- Interrupts
DB[1766]   = { duration = 10,   cooldown = 10,   class = "ROGUE" }    -- Kick (10s)
-- Crowd control (blind, sap, gouge, kidney shot)
DB[2094]   = { duration = 10,   cooldown = 120,  class = "ROGUE",    crowdcontrol = true }     -- Blind (10s, 2 min CD)
DB[6770]   = { duration = 25,   cooldown = 10,   class = "ROGUE",    crowdcontrol = true, diminish = true }     -- Sap (25s out of combat, 10s CD)
DB[1776]   = { duration = 4,    cooldown = 10,   class = "ROGUE",    crowdcontrol = true, diminish = true }     -- Gouge (4s, 10s CD)
DB[408]    = { duration = 5,    cooldown = 20,   class = "ROGUE",    crowdcontrol = true }     -- Kidney Shot (1–5s by CP, 20s CD)

-- =============================================================================
-- SHAMAN
-- =============================================================================
-- Buffs (totem effects, shields)
DB[10627]  = { duration = 120,   class = "SHAMAN" }   -- Grace of Air Totem (Rank 2)
DB[25359]  = { duration = 120,   class = "SHAMAN" }   -- Grace of Air Totem (Rank 3)
DB[8835]   = { duration = 120,   class = "SHAMAN" }   -- Grace of Air Totem (Rank 1)
DB[25908]  = { duration = 120,   class = "SHAMAN" }   -- Tranquil Air Totem (TBC)
DB[10408]  = { duration = 120,   class = "SHAMAN" }   -- Stoneskin Totem (Rank 5)
DB[25508]  = { duration = 120,   class = "SHAMAN" }   -- Strength of Earth Totem (Rank 5)
DB[25361]  = { duration = 120,   class = "SHAMAN" }   -- Strength of Earth Totem (Rank 6) TBC
DB[10428]  = { duration = 120,   class = "SHAMAN" }   -- Windfury Totem (Rank 2)
DB[25587]  = { duration = 120,   class = "SHAMAN" }   -- Windfury Totem (Rank 3) TBC
DB[16293]  = { duration = 120,   class = "SHAMAN" }   -- Mana Spring Totem (Rank 3)
DB[25570]  = { duration = 120,   class = "SHAMAN" }   -- Mana Spring Totem (Rank 5) TBC
DB[5675]   = { duration = 120,   class = "SHAMAN" }   -- Mana Spring Totem (Rank 1)
DB[10495]  = { duration = 120,   class = "SHAMAN" }   -- Mana Tide Totem
DB[29206]  = { duration = 120,   class = "SHAMAN" }   -- Mana Tide Totem (TBC)
DB[8071]   = { duration = 120,   class = "SHAMAN" }   -- Stoneskin Totem (Rank 1)
DB[8160]   = { duration = 120,   class = "SHAMAN" }   -- Strength of Earth Totem (Rank 1)
DB[324]    = { duration = 120,   class = "SHAMAN" }   -- Lightning Shield (Rank 1)
DB[325]    = { duration = 120,   class = "SHAMAN" }   -- Lightning Shield (Rank 2)
DB[905]    = { duration = 120,   class = "SHAMAN" }   -- Lightning Shield (Rank 3)
DB[945]    = { duration = 120,   class = "SHAMAN" }   -- Lightning Shield (Rank 4)
DB[8134]   = { duration = 120,   class = "SHAMAN" }   -- Lightning Shield (Rank 5)
DB[10431]  = { duration = 120,   class = "SHAMAN" }   -- Lightning Shield (Rank 6)
DB[10432]  = { duration = 120,   class = "SHAMAN" }   -- Lightning Shield (Rank 7)
DB[25469]  = { duration = 120,   class = "SHAMAN" }   -- Lightning Shield (Rank 8) TBC
DB[16177]  = { duration = 15,    class = "SHAMAN" }   -- Ancestral Fortitude (TBC)
DB[408510] = { duration = 600,  class = "SHAMAN" }   -- Water Shield (SoD rune, 10 min)
-- Defensives / major cooldowns
DB[16188]  = { duration = 15,    cooldown = 180,  class = "SHAMAN" }   -- Nature's Swiftness (3 min)
DB[30823]  = { duration = 15,    cooldown = 60,   class = "SHAMAN" }   -- Shamanistic Rage (TBC, 1 min)
DB[2825]   = { duration = 40,    cooldown = 600,  class = "SHAMAN" }   -- Bloodlust (TBC, 10 min)
DB[32182]  = { duration = 40,    cooldown = 600,  class = "SHAMAN" }   -- Heroism (TBC, 10 min)
-- Healing
DB[974]    = { duration = 10,    cooldown = 0,    class = "SHAMAN",  healing = true }   -- Earth Shield (TBC, no CD)
DB[49284]  = { duration = 10,    cooldown = 0,    class = "SHAMAN",  healing = true }   -- Earth Shield (TBC rank)
DB[331]    = { duration = 0,     class = "SHAMAN",  healing = true }   -- Healing Wave (Rank 1)
DB[332]    = { duration = 0,     class = "SHAMAN",  healing = true }   -- Healing Wave (Rank 2)
DB[547]    = { duration = 0,     class = "SHAMAN",  healing = true }   -- Healing Wave (Rank 3)
DB[913]    = { duration = 0,     class = "SHAMAN",  healing = true }   -- Healing Wave (Rank 4)
DB[939]    = { duration = 0,     class = "SHAMAN",  healing = true }   -- Healing Wave (Rank 5)
DB[959]    = { duration = 0,     class = "SHAMAN",  healing = true }   -- Healing Wave (Rank 6)
DB[8005]   = { duration = 0,     class = "SHAMAN",  healing = true }   -- Healing Wave (Rank 7)
DB[10395]  = { duration = 0,     class = "SHAMAN",  healing = true }   -- Healing Wave (Rank 8)
DB[10396]  = { duration = 0,     class = "SHAMAN",  healing = true }   -- Healing Wave (Rank 9)
DB[25357]  = { duration = 0,     class = "SHAMAN",  healing = true }   -- Healing Wave (Rank 10) TBC
DB[8004]   = { duration = 0,     class = "SHAMAN",  healing = true }   -- Lesser Healing Wave (Rank 1)
DB[8008]   = { duration = 0,     class = "SHAMAN",  healing = true }   -- Lesser Healing Wave (Rank 2)
DB[8010]   = { duration = 0,     class = "SHAMAN",  healing = true }   -- Lesser Healing Wave (Rank 3)
DB[10466]  = { duration = 0,     class = "SHAMAN",  healing = true }   -- Lesser Healing Wave (Rank 4)
DB[10467]  = { duration = 0,     class = "SHAMAN",  healing = true }   -- Lesser Healing Wave (Rank 5)
DB[10468]  = { duration = 0,     class = "SHAMAN",  healing = true }   -- Lesser Healing Wave (Rank 6)
DB[25420]  = { duration = 0,     class = "SHAMAN",  healing = true }   -- Lesser Healing Wave (Rank 7) TBC
DB[1064]   = { duration = 0,     class = "SHAMAN",  healing = true }   -- Chain Heal (Rank 1)
DB[10622]  = { duration = 0,     class = "SHAMAN",  healing = true }   -- Chain Heal (Rank 2)
DB[10623]  = { duration = 0,     class = "SHAMAN",  healing = true }   -- Chain Heal (Rank 3)
DB[25422]  = { duration = 0,     class = "SHAMAN",  healing = true }   -- Chain Heal (Rank 4) TBC
DB[25423]  = { duration = 0,     class = "SHAMAN",  healing = true }   -- Chain Heal (Rank 5) TBC
-- Interrupts (Earth Shock)
DB[8042]   = { duration = 6,    cooldown = 6,    class = "SHAMAN" }   -- Earth Shock (Rank 1, interrupt)
DB[8044]   = { duration = 6,    cooldown = 6,    class = "SHAMAN" }   -- Earth Shock (Rank 2)
DB[8045]   = { duration = 6,    cooldown = 6,    class = "SHAMAN" }   -- Earth Shock (Rank 3)
DB[8046]   = { duration = 6,    cooldown = 6,    class = "SHAMAN" }   -- Earth Shock (Rank 4)
DB[10412]  = { duration = 6,    cooldown = 6,    class = "SHAMAN" }   -- Earth Shock (Rank 5)
DB[10413]  = { duration = 6,    cooldown = 6,    class = "SHAMAN" }   -- Earth Shock (Rank 6)
DB[10414]  = { duration = 6,    cooldown = 6,    class = "SHAMAN" }   -- Earth Shock (Rank 7)
DB[25454]  = { duration = 6,    cooldown = 6,    class = "SHAMAN" }   -- Earth Shock (TBC rank)
-- Dispel
DB[370]    = { duration = 0,     class = "SHAMAN",  dispell = true }   -- Purge (enemy magic)
DB[526]    = { duration = 0,     class = "SHAMAN",  dispell = true }   -- Cure Poison
DB[2870]   = { duration = 0,     class = "SHAMAN",  dispell = true }   -- Cure Disease
DB[51886]  = { duration = 0,     class = "SHAMAN",  dispell = true }   -- Cleanse Spirit (TBC, curse)

-- =============================================================================
-- WARLOCK
-- =============================================================================
-- Buffs
DB[25228]  = { duration = 0,     class = "WARLOCK" }   -- Soul Link (until cancelled)
DB[28176]  = { duration = 30,    class = "WARLOCK" }  -- Fel Armor (Rank 1) TBC
DB[28189]  = { duration = 30,    class = "WARLOCK" }  -- Fel Armor (Rank 2) TBC
DB[47892]  = { duration = 30,    class = "WARLOCK" }  -- Fel Armor (Rank 3) TBC
DB[687]    = { duration = 600,   class = "WARLOCK" }   -- Demon Skin (Rank 1)
DB[696]    = { duration = 600,   class = "WARLOCK" }   -- Demon Skin (Rank 2)
DB[706]    = { duration = 1800, class = "WARLOCK" }   -- Demon Armor (Rank 1)
DB[1086]   = { duration = 1800, class = "WARLOCK" }   -- Demon Armor (Rank 2)
DB[11733]  = { duration = 1800, class = "WARLOCK" }   -- Demon Armor (Rank 3)
DB[11734]  = { duration = 1800, class = "WARLOCK" }   -- Demon Armor (Rank 4)
DB[11735]  = { duration = 1800, class = "WARLOCK" }   -- Demon Armor (Rank 5)
DB[5697]   = { duration = 300,   class = "WARLOCK" }   -- Unending Breath
DB[17800]  = { duration = 30,    class = "WARLOCK" }   -- Shadow and Flame (TBC)
DB[19028]  = { duration = 15,    class = "WARLOCK" }   -- Soul Link (pet)
DB[25222]  = { duration = 30,    class = "WARLOCK" }   -- Unholy Power (TBC)
DB[18790]  = { duration = 30,    class = "WARLOCK" }   -- Fel Stamina
DB[18791]  = { duration = 30,    class = "WARLOCK" }   -- Fel Energy
DB[18792]  = { duration = 30,    class = "WARLOCK" }   -- Fel Intelligence
-- Defensives
DB[6229]   = { duration = 30,   cooldown = 30,   class = "WARLOCK" }   -- Shadow Ward (30s) PvP/combat
-- Interrupts (pet)
DB[19244]  = { duration = 30,   cooldown = 30,   class = "WARLOCK" }   -- Spell Lock (Felhunter, 30s)
DB[19647]  = { duration = 24,   cooldown = 24,   class = "WARLOCK" }   -- Spell Lock (Felhunter alt)
-- Crowd control (fear, seduction, death coil)
DB[5782]   = { duration = 20,   cooldown = 0,    class = "WARLOCK",  crowdcontrol = true, diminish = true }   -- Fear (20s)
DB[6358]   = { duration = 30,   cooldown = 0,    class = "WARLOCK",  crowdcontrol = true, diminish = true }   -- Seduction (Succubus, 30s)
DB[6789]   = { duration = 3,    cooldown = 120,  class = "WARLOCK",  crowdcontrol = true }   -- Death Coil (3s fear, 2 min CD)
DB[17928]  = { duration = 3,    cooldown = 120,  class = "WARLOCK",  crowdcontrol = true }   -- Death Coil (Rank 2)
DB[11297]  = { duration = 3,    cooldown = 120,  class = "WARLOCK",  crowdcontrol = true }   -- Death Coil (Rank 3)
-- Dispel (pet)
DB[19505]  = { duration = 0,     class = "WARLOCK", dispell = true }  -- Devour Magic (Felhunter)

-- =============================================================================
-- WARRIOR
-- =============================================================================
-- Buffs
DB[6673]   = { duration = 120,   class = "WARRIOR" }  -- Battle Shout (Rank 1)
DB[5242]   = { duration = 120,   class = "WARRIOR" }  -- Battle Shout (Rank 2)
DB[6192]   = { duration = 120,   class = "WARRIOR" }  -- Battle Shout (Rank 3)
DB[11549]  = { duration = 120,   class = "WARRIOR" }  -- Battle Shout (Rank 4)
DB[11550]  = { duration = 120,   class = "WARRIOR" }  -- Battle Shout (Rank 5)
DB[11551]  = { duration = 120,   class = "WARRIOR" }  -- Battle Shout (Rank 6)
DB[25289]  = { duration = 120,   class = "WARRIOR" }  -- Battle Shout (Rank 7)
DB[2048]   = { duration = 120,   class = "WARRIOR" }  -- Battle Shout (Rank 8) TBC
DB[469]    = { duration = 30,    class = "WARRIOR" }  -- Commanding Shout (TBC)
-- Defensives / major cooldowns
DB[2565]   = { duration = 6,     cooldown = 5,    class = "WARRIOR" }  -- Shield Block (5s)
DB[871]    = { duration = 12,    cooldown = 1800, class = "WARRIOR" }  -- Shield Wall (30 min)
DB[1719]   = { duration = 15,    cooldown = 1800, class = "WARRIOR" }  -- Recklessness (30 min)
DB[12975]  = { duration = 15,    cooldown = 180,  class = "WARRIOR" }  -- Last Stand (3 min)
DB[12328]  = { duration = 30,    cooldown = 30,   class = "WARRIOR" }  -- Sweeping Strikes (30s)
DB[23885]  = { duration = 30,    cooldown = 6,    class = "WARRIOR" }  -- Bloodthirst (buff, 6s CD)
DB[29834]  = { duration = 15,    cooldown = 120,  class = "WARRIOR" }  -- Second Wind (TBC, 2 min)
DB[25264]  = { duration = 10,    cooldown = 6,    class = "WARRIOR" }  -- Shield Slam (buff, 6s CD)
DB[20230]  = { duration = 15,   cooldown = 1800, class = "WARRIOR" }  -- Retaliation (30 min) PvP/combat
-- Interrupts
DB[6552]   = { duration = 10,   cooldown = 10,   class = "WARRIOR" }  -- Pummel (10s)
DB[72]     = { duration = 12,   cooldown = 12,   class = "WARRIOR" }  -- Shield Bash (12s)

-- =============================================================================
-- WORLD (consumables, world buffs, other)
-- =============================================================================
DB[22817]  = { duration = 7200,  class = "WORLD" }    -- Fengus' Ferocity (DM North)
DB[22818]  = { duration = 7200,  class = "WORLD" }    -- Mol'dar's Moxie (DM North)
DB[22820]  = { duration = 7200,  class = "WORLD" }    -- Slip'kik's Savvy (DM North)
DB[23768]  = { duration = 7200,  class = "WORLD" }    -- Sayge's Dark Fortune (Darkmoon)
DB[24425]  = { duration = 7200,  class = "WORLD" }    -- Spirit of Zandalar
DB[15366]  = { duration = 3600,  class = "WORLD" }    -- Songflower Serenade (1 hr)
DB[16609]  = { duration = 3600,  class = "WORLD" }    -- Warchief's Blessing (Horde)
DB[15123]  = { duration = 3600,  class = "WORLD" }    -- Resist Fire (Songflower area)
DB[29534]  = { duration = 1800, class = "WORLD" }    -- Traces of Silithyst
DB[31906]  = { duration = 1800, class = "WORLD" }    -- Lordaeron's Blessing
DB[22812]  = { duration = 12,    class = "WORLD" }    -- Barkskin (Druid - duplicate for lookup)
DB[10442]  = { duration = 3600, class = "WORLD" }    -- Rumsey Rum (example consumable)
DB[17538]  = { duration = 3600, class = "WORLD" }    -- Elixir of the Mongoose
DB[17539]  = { duration = 3600, class = "WORLD" }    -- Greater Arcane Elixir
DB[26276]  = { duration = 3600, class = "WORLD" }    -- Elixir of Greater Firepower
DB[11334]  = { duration = 3600, class = "WORLD" }    -- Gift of Arthas
DB[28518]  = { duration = 3600, class = "WORLD" }    -- Flask of Relentless Assault (TBC)
DB[28540]  = { duration = 3600, class = "WORLD" }    -- Flask of Blinding Light (TBC)
DB[41621]  = { duration = 3600, class = "WORLD" }    -- Flask of Relentless Assault (TBC)
