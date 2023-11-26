return {
  -- NOTE: does not stack with clr_aegolism or shm_focus
  wiz_self_shield = {
      "Ether Shield",                             -- L66 Ether Shield (390 hp, 46 ac, 40 mr)
      "Shield of Maelin",                         -- L64 Shield of Maelin (350 hp, 38-39 ac, 40 mr)
      "Shield of the Arcane",                     -- L61 Shield of the Arcane (298-300 hp, 34-36 ac, 30 mr)
      "Shield of the Magi",                       -- L54 Shield of the Magi (232-250 hp, 29-31 ac, 22-24 mr)
      "Arch Shielding",                           -- L44 Arch Shielding (140-150 hp, 24-27 ac, 20 mr)
      "Greater Shielding",                        -- L33 Greater Shielding (91-100 hp, 20-22 ac, 16 mr)
      "Major Shielding",                          -- L23 Major Shielding (68-75 hp, 16-18 ac, 14 mr)
      "Shielding",                                -- L15 Shielding (45-50 hp, 11-13 ac, 11-12 mr)
      "Lesser Shielding",                         -- L06 Lesser Shielding (17-30 hp, 5-9 ac, 6-10 mr)
      "Minor Shielding",                          -- L01 Minor Shielding (6-10 hp, 3-4 ac)
  },
  wiz_self_rune = {
      "Shield of Dreams",                         -- L70: slot 1: absorb 451 dmg, slot 8: +10 resists, slot 9: 3 mana/tick
      "Ether Skin",                               -- L68: slot 1: absorb 975 dmg, 3 mana/tick
      "Force Shield",                             -- L63: slot 1: absorb 750 dmg, 2 mana/tick
  },
  -- NOTE: does not stack with druid resists
  wiz_self_resist = {
      "Elemental Barrier",                        -- L61 Elemental Barrier (60 cr, 60 fr)
      "Elemental Cloak",                          -- L54 Elemental Cloak (45 cr, 45 fr)
      "Elemental Armor",                          -- L41 Elemental Armor (30 cr, 30 fr)
      "Elemental Shield",                         -- L19 Elemental Shield (14-15 cr, 14-15 fr)
  },
  wiz_fire_nuke = {
      "Ancient: Core Fire",                       -- L70 Ancient: Core Fire (4070 hp, resist adj -10, cost 850 mana, 8s cast)
      "Corona Flare",                             -- L70 Corona Flare (3770 hp, resist adj -10, cost 800 mana, 8s cast)
      "Ether Flame",                              -- L70 Ether Flame (5848 hp, resist adj -50, cost 1550 mana, 8s cast)
      "Chaos Flame",                              -- L70 Chaos Flame (random 1000 to 2000, resist adj -50, cost 275 mana, 3.0s cast)
      "Firebane",                                 -- L68 Firebane (1500 hp, resist adj -300, cost 456 mana, 4.5s cast)
      "Spark of Fire",                            -- L66 Spark of Fire (1348 hp, resist adj -50, cost 319 mana, 3s cast)
      "Ancient: Strike of Chaos",                 -- L65 Ancient: Strike of Chaos (3288 hp, resist adj -10, cost 768 mana)
      "White Fire",                               -- L65 White Fire (3015 hp, resist adj -10, cost 704 mana)
      "Strike of Solusek",                        -- L65 Strike of Solusek (2740 hp, resist adj -10, cost 640 mana)
      "Lure of Ro",                               -- L62 Lure of Ro (1090 hp, resist adj -300, cost 387 mana)
      "Draught of Ro",                            -- L62 Draught of Ro (980 hp, resist adj -50, cost 255 mana)
      "Sunstrike",                                -- L60 Sunstrike (1615 hp, resist adj -10, cost 450 mana)
      "Draught of Fire",                          -- L51 Draught of Fire (643-688 hp, cost 215 mana)
      "Supernova",                                -- L49 Supernova (854 hp, cost 875 mana)
      "Conflagration",                            -- L44 Conflagration (606-625 hp, cost 250 mana)
      "Inferno Shock",                            -- L29 Inferno Shock (237-250 hp, cost 135 mana)
      "Flame Shock",                              -- L16 Flame Shock (102-110 hp, cost 75 mana)
      "Fire Bolt",                                -- L08 Fire Bolt (45-51 hp, cost 40 mana)
      "Shock of Fire",                            -- L04 Shock of Fire (13-16 hp, cost 15 mana)
  },
  wiz_cold_nuke = {
    "Ancient: Spear of Gelaqua",                  -- L70 Ancient: Spear of Gelaqua (1976 hp, resist adj -10, cost 345 mana, 3.5s cast)
    "Claw of Vox",                                -- L69 Claw of Vox (1375 hp, resist adj -50, cost 208 mana, 5s cast)
    "Spark of Ice",                               -- L69 Spark of Ice (1348 hp, resist adj -50, cost 319 mana, 3s cast)
    "Gelidin Comet",                              -- L69 Gelidin Comet (3385 hp, resist adj -10, cost 650 mana)
    "Clinging Frost",                             -- L68 Clinging Frost (1830 hp, resist adj -10, cost 350 mana + Clinging Frost Trigger DD)
    "Icebane",                                    -- L66 Icebane (1500 hp, resist adj -300, cost 456 mana)
    "Black Ice",                                  -- L65 Black Ice (1078 hp, resist adj -10, cost 280 mana)
    "Draught of E'ci",                            -- L64 Draught of E'ci (980 hp, resist adj -50, cost 255 mana)
    "Ice Meteor",                                 -- L64 Ice Meteor (2460 hp, resist adj -10, cost 520 mana)
    "Claw of Frost",                              -- L61 Claw of Frost (1000 hp, resist adj -50, cost 167 mana)
    "Ice Spear of Solist",                        -- L60 Ice Spear of Solist (1076 hp, resist adj -10, cost 221 mana)
    "Draught of Ice",                             -- L57 Draught of Ice (793 hp, resist adj -10, cost 216 mana)
    "Ice Comet",                                  -- L49 Ice Comet (808 hp, resist adj -10, cost 203 mana)
    "Shock of Ice",                               -- L08 Shock of Ice (46-58 hp, cost 23 mana)
    "Blast of Cold",                              -- L01 Blast of Cold (11-18 hp, cost 8 mana), called "Shock of Frost" on fvp
    "Frost Bolt",                                 -- L01 Frost Bolt (9-14 hp, cost 6 mana)
  },
  wiz_magic_nuke = {
    "Thundaka",                                   -- L68 Thundaka (3233 hp, cost 656 mana)
    "Spark of Thunder",                           -- L68 Spark of Thunder (1348 hp, resist adj -50, cost 319 mana + 1s stun L70)
    "Spark of Lightning",                         -- L68 Spark of Lightning (1348 hp, resist adj -50, cost 319 mana)
    "Lightningbane",                              -- L67 Lightningbane (1500 hp, resist adj -300, cost 456 mana)
    "Shock of Magic",                             -- L65 Shock of Magic (random dmg up to 2400 hp, resist adj -20, cost 550 mana)
    "Agnarr's Thunder",                           -- L63 Agnarr's Thunder (2350 hp, cost 525 mana)
    "Draught of Lightning",                       -- L63 Draught of Lightning (980 hp, resist adj -50, cost 255 mana)
    "Draught of Thunder",                         -- L63 Draught of Thunder (980 hp, stun 1s/65, resist adj -50, cost 255 mana)
    "Lure of Thunder",                            -- L61 Lure of Thunder (1090 hp, resist adj -300, cost 365 mana)
    "Elnerick's Electrical Rending",              -- L60 Elnerick's Electrical Rending (1796 hp, cost 421 mana)
    "Shock of Lightning",                         -- L10 Shock of Lightning (74-83 hp, cost 50 mana)
  },
  wiz_target_ae = {
    "Meteor Storm",                               -- L69 Meteor Storm (886 hp, FIRE, adj -300, aerange 25, recast 12s, cost 523 mana)
    "Tears of the Sun",                           -- L66 Tears of the Sun (1168 hp, FIRE, adj -10, aerange 25, recast 10s, cost 529 mana)
    "Tears of Arlyxir",                           -- L64 Tears of Arlyxir (645 hp, FIRE, adj -300, aerange 25, recast 12s, cost 420 mana)
    "Tears of Ro",                                -- L61 Tears of Ro (1106 hp, FIRE, adj -10, aerange 25, recast 10s, cost 492 mana)
    "Lava Storm",                                 -- L32 Lava Storm (401 hp, FIRE, adj -10, aerange 25, recast 12s, cost 234 mana)
    "Circle of Force",                            -- L31 Circle of Force (193-216 hp, FIRE, adj -10, aerange 15, recast 6s, cost 175 mana)
    "Shock Spiral of Al'Kabor",                   -- L28 Shock Spiral of Al'Kabor (111-118 hp, MAGIC, aerange 35, recast 9s, cost 200 mana)
    "Energy Storm",                               -- L26 Energy Storm (238 hp, MAGIC, adj -10, aerange 25, recast 12s, cost 148 mana)
    "Column of Lightning",                        -- L24 Column of Lightning (128-136 hp, FIRE, aerange 15, recast 6s, cost 130 mana)
    "Firestorm",                                  -- L12 Firestorm (41 hp, FIRE, adj -10, aerange 25, recast 12s, cost 34 mana)
  },
  wiz_pbae_nuke = {
    "Circle of Thunder",                          -- L70 Circle of Thunder (1450 hp, MAGIC; adj -10, aerange 35, recast 12s, cost 990 mana)
    "Circle of Fire",                             -- L67 Circle of Fire (845 hp, FIRE, adj -10, aerange 35, recast 6s, cost 430 mana)
    "Winds of Gelid",                             -- L60 Winds of Gelid (1260 hp, ICE, adj -10, aerange 35, recast 12s, cost 875 mana)
    "Jyll's Wave of Heat",                        -- L59 Jyll's Wave of Heat (638-648 hp, FIRE, adj -10, aerange 25, recast 6s, cost 342 mana)
    "Jyll's Zephyr of Ice",                       -- L56 Jyll's Zephyr of Ice (594 hp, ICE, adj -10, aerange 25, recast 6s, cost 313 mana)
    "Jyll's Static Pulse",                        -- L53 Jyll's Static Pulse (495-510 hp, MAGIC, aerange 25, recast 6s, cost 285 mana)
    "Supernova",                                  -- L45 Supernova (854 hp, FIRE, aerange 35, recast 12s, cost 875 mana)
    "Thunderclap",                                -- L30 Thunderclap (210-232 hp, MAGIC, aerange 20, recast 12s, cost 175 mana)
    "Project Lightning",                          -- L14 Project Lightning (55-62 hp, MAGIC, aerange 25, recast 6s, cost 85 mana)
    "Fingers of Fire",                            -- L05 Fingers of Fire (19-28 hp, FIRE, aerange 25, recast 6s, cost 47 mana)
    "Numbing Cold",                               -- L01 Numbing Cold (14 hp, ICE, aerange 25, recast 12s, cost 6 mana)
  },
  wiz_mana_conversion = {
      "Harvest",
  },
  wiz_epic2 = {
      "Staff of Phenomenal Power",                -- epic 2.0: -50% spell resist rate for group, -6% spell hate
      "Staff of Prismatic Power",                 -- epic 1.5: -30% spell resist rate for group, -4% spell hate
  },
  wiz_oow_bp = {
      "Academic's Robe of the Arcanists",         -- oow t2 bp: Academic's Intellect, -25% cast time for 0.7 min, 5 min reuse
      "Spelldeviser's Cloth Robe",                -- oow t1 bp: Academic's Foresight, -25% cast time for 0.5 min, 5 min reuse
  },
}