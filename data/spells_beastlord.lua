return {
  bst_manaregen = {
      "Spiritual Ascendance",                     -- L69 Spiritual Ascendance (10 hp + 10 mana/tick, group, cost 900 mana)
      "Spiritual Dominion",                       -- L64 Spiritual Dominion (9 hp + 9 mana/tick, group)
      "Spiritual Purity",                         -- L59 Spiritual Purity (7 hp + 7 mana/tick, group)
      "Spiritual Radiance",                       -- L52 Spiritual Radiance (5 hp + 5 mana/tick, group)
      "Spiritual Light",                          -- L41 Spiritual Light (3 hp + 3 mana/tick, group)
  },
  -- hp type 2 - Slot 4: Increase max HP
  -- NOTE: RNG buff has more atk
  bst_hp = {
      "Spiritual Vitality",                       -- L67 Spiritual Vitality (52 atk, 280 hp, group)
      "Spiritual Vigor",                          -- L62 Spiritual Vigor (40 atk, 225 hp, group)
      "Spiritual Strength",                       -- L60 Spiritual Strength (25 atk, 150 hp)
      "Spiritual Brawn",                          -- L42 Spiritual Brawn (10 atk, 75 hp)
  },
  bst_haste = {
      "Celerity",                                 -- L63 Celerity (47-50% haste, 16 min)
      "Alacrity",                                 -- L60 Alacrity (32-40% haste, 11 min)
  },
  -- NOTE: shm_focus is stronger
  bst_focus = {
      "Focus of Alladnu",                         -- L67 Focus of Alladnu (513 hp)
      "Talisman of Kragg",                        -- L62 Talisman of Kragg (365-500 hp)
      "Talisman of Altuna",                       -- L58 Talisman of Altuna (230-250 hp)
      "Talisman of Tnarg",                        -- L53 Talisman of Tnarg (132-150 hp)
  },
  bst_sta = {
      "Stamina",                                  -- L57 Stamina (36-40 sta)
      "Health",                                   -- L52 Health (27-31 sta)
      "Spirit of Ox",                             -- L37 Spirit of Ox (19-23 sta)
      "Spirit of Bear",                           -- L17 Spirit of Bear (11-15 sta)
  },
  bst_str = {
      "Furious Strength",                         -- L54 Furious Strength (31-34 str)
      "Raging Strength",                          -- L41 Raging Strength (23-26 str)
      "Spirit Strength",                          -- L28 Spirit Strength (16-18 str)
      "Strengthen",                               -- L14 Strengthen (5-10 str)
  },
  -- do not stack with shm_focus
  bst_dex = {
      "Dexterity",                                -- L57 Dexterity (49-50 dex)
      "Deftness",                                 -- L53 Deftness (40 dex)
      "Spirit of Monkey",                         -- L38 Spirit of Monkey (19-20 dex)
  },
  bst_ferocity = {
      "Ferocity of Irionu",                       -- L70 Ferocity of Irionu (52 sta, 187 atk, 65 all resists, 6.5 min, 2 min recast)
      "Ferocity",                                 -- L65 Ferocity (40 sta, 150 atk, 65 all resists, 6.5 min)
      "Growl of the Leopard",                     -- L61 Growl of the Leopard (15% skill damage mod, 80 hp/tick, max hp 850, 1 min, cost 500 mana)
      "Frenzy",                                   -- L47 Frenzy (6-10 ac, 18-25 agi, 19-28 str, 25 dex, 10 min)
  },
  bst_pet_haste = {
     "Growl of the Beast",                        -- L68 Growl of the Beast (85% haste, 90 atk, 78 ac, 5% skill dmg mod, duration 1h)
     "Arag's Celerity",                           -- L64 Arag's Celerity (115 str, 85% haste, 75 atk, 71 ac)
     "Sha's Ferocity",                            -- L59 Sha's Ferocity (99-100 str, 84-85% haste, 60 atk, 60 ac)
     "Omakin's Alacrity",                         -- L55 Omakin's Alacrity (60 str, 65-70% haste, 40 atk, 30 ac)
     "Bond of the Wild",                          -- L52 Bond of the Wild (51-55 str, 60% haste, 25 atk, 13-15 ac)
     "Yekan's Quickening",                        -- L37 Yekan's Quickening (43-45 str, 60% haste, 20 atk, 11-12 ac)
  },
  bst_pet_proc = {
      "Spirit of Oroshar",                        -- L70 Spirit of Oroshar (FIRE: Spirit of Oroshar Strike, rate mod 150, 75 dex)
      "Spirit of Irionu",                         -- L68 Spirit of Irionu (COLD: Spirit of Irionu Strike, rate mod 150, 75 dex)
      "Spirit of Rellic",                         -- L63 Spirit of Rellic (COLD: Spirit of Rellic Strike, rate mod 150)
      "Spirit of Flame",                          -- L56 Spirit of Flame (FIRE: Spirit of Flame Strike, rate mod 150)
      "Spirit of Snow",                           -- L54 Spirit of Snow (Spirit of Snow Strike, rate mod 150)
      "Spirit of the Storm",                      -- L53 Spirit of the Storm (Spirit of Storm Strike, rate mod 150)
      "Spirit of Wind",                           -- L51 Spirit of Wind (Spirit of Wind Strike proc, rate mod 150)
      "Spirit of Vermin",                         -- L46 Spirit of Vermin (Spirit of Vermin Strike proc)
      "Spirit of the Scorpion",                   -- L38 Spirit of the Scorpion (Spirit of Scorpion Strike proc)
      "Spirit of Inferno",                        -- L28 Spirit of Inferno (Spirit of Inferno Strike proc)
      "Spirit of Lightning",                      -- L13 Spirit of Lightning (Spirit of Lightning Strike proc)
  },
  bst_pet_heal = {
      "Healing of Mikkily",                       -- L66 Healing of Mikkily (2810 hp, decrease dr 28, pr 28, cr 28, cost 610 mana)
      "Healing of Sorsha",                        -- L61 Healing of Sorsha (2018-2050 hp, decrease dr 24, pr 24, cr 24, cost 495 mana)
      "Sha's Restoration",                        -- L55 Sha's Restoration (1426-1461 hp, decrease dr 20, pr 20, cr 20, cost 404 mana)
      "Aid of Khurenz",                           -- L52 Aid of Khurenz (1044 hp, decrease dr 16, pr 16, cr 16, cost 293 mana)
      "Vigor of Zehkes",                          -- L49 Vigor of Zehkes (671 hp, decrease dr 10, pr 10, cr 10, cost 206 mana)
      "Yekan's Recovery",                         -- L36 Yekan's Recovery
      "Herikol's Soothing",                       -- L27 Herikol's Soothing (274-298 hp, decrease dr 10, pr 10, cr 10)
      "Keshuval's Rejuvenation",                  -- L15 Keshuval's Rejuvenation
      "Sharik's Replenishing",                    -- L09 Sharik's Replenishing
  },
  bst_ice_nuke = {
      "Ancient: Savage Ice",                      -- L70 Ancient: Savage Ice (1034 hp, cost 329 mana, 30s recast)
      "Glacier Spear",                            -- L69 Glacier Spear (958 hp, cost 310 mana)
      "Ancient: Frozen Chaos",                    -- L65 Ancient: Frozen Chaos (836 hp, cost 298 mana)
      "Trushar's Frost",                          -- L65 Trushar's Frost (742 hp, cost 274 mana)
      "Frost Spear",                              -- L63 Frost Spear (600 hp, cost 235 mana)
      "Blizzard Blast",                           -- L59 Blizzard Blast (332-346 hp, cost 147 mana)
      "Ice Shard",                                -- L54 Ice Shard (404 hp, cost 156 mana)
      "Frost Shard",                              -- L47 Frost Shard (281 hp, cost 119 mana)
      "Ice Spear",                                -- L33 Ice Spear (207 hp, cost 97 mana)
      "Spirit Strike",                            -- L26 Spirit Strike (72-78 hp, cost 44 mana)
      "Blast of Frost",                           -- L12 Blast of Frost (71 hp, cost 40 mana)
  },
  bst_slow = {
      "Sha's Legacy",                             -- L70 Sha's Legacy (MAGIC -30 adj, 65% slow, 1m30s duration)
      "Sha's Revenge",                            -- L65 Sha's Revenge (MAGIC, 65% slow, 3m30s duration)
  },
  bst_heal = {
      "Muada's Mending",                          -- L67 Muada's Mending (1176-1206 hp, cost 376 mana, 3s cast time)
      "Trushar's Mending",                        -- L65 Trushar's Mending (1048 hp, cost 330 mana)
      "Chloroblast",                              -- L62 Chloroblast (994-1044 hp, cost 331 mana)
      "Greater Healing",                          -- L57 Greater Healing (280-350 hp, cost 115 mana)
      "Healing",                                  -- L36 Healing (135-175 hp, cost 65 mana)
      "Light Healing",                            -- L20 Light Healing (47-65 hp, cost 28 mana)
      "Minor Healing",                            -- L06 Minor Healing (12-20 hp, cost 10 mana)
      "Salve",                                    -- L01 Salve (5-9 hp, cost 8 mana), GoD
  },
  bst_posion_dot = {
      "Turepta Blood",                            -- L65 Turepta Blood (168/tick, poison, cost 377 mana)
      "Scorpion Venom",                           -- L61 Scorpion Venom (162-170/tick, poison, cost 350 mana)
      "Venom of the Snake",                       -- L52 Venom of the Snake (104-114 hp/tick, poison, cost 172 mana)
      "Envenomed Breath",                         -- L35 Envenomed Breath (59-71/tick, poison, cost 181 mana)
      "Tainted Breath",                           -- L19 Tainted Breath (14-19/tick, poison)
  },
  bst_disease_dot = {
      "Plague",                                   -- L65 Plague (74-79 hp/tick, disease, cost 172 mana)
      "Sicken",                                   -- L14 Sicken (3-5/tick, disease)
  },
  bst_epic2 = {
      "Spiritcaller Totem of the Feral",          -- epic 2.0: pet buff, double attack 8%, evasion 12%, hp 1000, proc Wild Spirit Strike
      "Savage Lord's Totem",                      -- epic 1.5: pet buff, double attack 5%, evasion 10%, hp 800, proc Savage Blessing Strike
  },
  bst_oow_bp = {
      "Savagesoul Jerkin of the Wilds",           -- oow T2 bp: Savage Spirit Infusion, +50% skill dmg mod, -15% dmg taken for 30s
      "Beast Tamer's Jerkin",                     -- oow T1 bp: Wild Spirit Infusion, +50% skill dmg mod, -15% dmg taken for 18s
  }
}