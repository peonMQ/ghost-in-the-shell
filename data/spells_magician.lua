return {
  mag_ds = {
      "Fireskin",                                 -- L66: 62 ds - slot 1, 45 fr, 15 min
      "Flameshield of Ro",                        -- L61: 48 ds, 45 fr, 15 min
      "Cadeau of Flame",                          -- L56: 35 ds, 33 fr, 15 min
      "Shield of Lava",                           -- L45: 25 ds, 25 fr, 15 min - L1-45
      "Barrier of Combustion",                    -- L38: 18-20 ds, 22 fr, 15 min
      "Inferno Shield",                           -- L28: 13-15 ds, 20 fr, 15 min
      "Shield of Flame",                          -- L19: 7-9 ds, 15 fr, 15 min
      "Shield of Fire",                           -- L07: 4-6 ds, 10 fr, 1.5 min
  },
  mag_group_ds = {
      "Circle of Fireskin",                       -- L70: 62 ds, 45 fr, 15 min, group, OOW
      "Maelstrom of Ro",                          -- L63: 48 ds, 45 fr, 15 min, group, PoP
      "Boon of Immolation",                       -- L53: 25 ds, 25 fr, 15 min, group, Kunark
  },
  mag_big_ds = {
      "Ancient: Veil of Pyrilonus",               -- L70: 500 ds - slot 12, 24 sec
      "Pyrilen Skin",                             -- L68: 420 ds - slot 12, 12 sec
  },
  -- NOTE: does not stack with clr_aegolism or shm_focus
  mag_self_shield = {
      "Elemental Aura",                           -- L66: 390 hp, 46 ac, 40 mr
      "Shield of Maelin",                         -- L64: 350 hp, 38-39 ac, 40 mr
      "Shield of the Arcane",                     -- L61: 298-300 hp, 34-36 ac, 30 mr
      "Shield of the Magi",                       -- L54: 232-250 hp, 29-31 ac, 22-24 mr
      "Arch Shielding",                           -- L43: 140-150 hp, 24-27 ac, 20 mr
      "Greater Shielding",                        -- L32: 91-100 hp, 20-22 ac, 16 mr
      "Major Shielding",                          -- L24: 68-75 hp, 16-18 ac, 14 mr
      "Shielding",                                -- L16: 45-50 hp, 11-13 ac, 11-12 mr
      "Lesser Shielding",                         -- L05: 17-30 hp, 5-9 ac, 6-10 mr
      "Minor Shielding",                          -- L01: 6-10 hp, 3-4 ac
  },
  -- NOTE: does not stack with druid resists
  mag_self_resist = {
      "Elemental Barrier",                        -- L61 Elemental Barrier (60 cr, 60 fr)
      "Elemental Cloak",                          -- L54 Elemental Cloak (45 cr, 45 fr)
      "Elemental Armor",                          -- L41 Elemental Armor (30 cr, 30 fr)
      "Elemental Shield",                         -- L19 Elemental Shield (14-15 cr, 14-15 fr)
  },
  mag_pet_haste = {
      "Elemental Fury",                           -- L69 Elemental Fury (85% haste, 29 ac, 52 atk, 5% skill dmg mod)
      "Burnout V",                                -- L62 Burnout V (80 str, 85% haste, 22 ac, 40 atk)
      "Ancient: Burnout Blaze",                   -- L60 Ancient: Burnout Blaze (80 str, 80% haste, 22 ac, 50 atk)
      "Burnout IV",                               -- L55 Burnout IV (60 str, 21-85% haste, 16 ac)
      "Elemental Empathy",                        -- L52 Elemental Empathy (60 str, 21-80% haste, 18 ac)
      "Burnout III",                              -- L47 Burnout III (50 str, 16-75% haste, 13 ac)
      "Burnout II",                               -- L29 Burnout II (39-45 str, 15-50% haste, 9 ac)
      "Burnout",                                  -- L11 Burnout (15 str, 12-15% haste, 7 ac)
  },
  mag_pet_runspeed = {
      "Velocity",                                 -- L58 Velocity (59-80% movement, 36 min)
      "Expedience",                               -- L27 Expedience (20% movement, 12 min)
  },
  mag_earth_pet = {
      "Child of Earth",                           -- L70, OOW
      "Rathe's Son",                              -- L65, PoP
      "Greater Vocaration: Earth",                -- L57, Kunark
      "Vocarate: Earth",                          -- L51, Kunark
      "Greater Conjuration: Earth",               -- L49
      "Conjuration: Earth",                       -- L44
      "Lesser Conjuration: Earth",                -- L39
      "Minor Conjuration: Earth",                 -- L34
      "Greater Summoning: Earth",                 -- L29
      "Summoning: Earth",                         -- L24
      "Lesser Summoning: Earth",                  -- L20
      "Minor Summoning: Earth",                   -- L16
      "Elemental: Earth",                         -- L12
      "Elementaling: Earth",                      -- L08
      "Elementalkin: Earth",                      -- L04
  },
  mag_fire_pet = {
      "Child of Fire",                            -- L68, OOW
      "Child of Ro",                              -- L63, PoP
      "Greater Vocaration: Fire",                 -- L58, Kunark
      "Vocarate: Fire",                           -- L52, Kunark
      "Greater Conjuration: Fire",                -- L49
      "Conjuration: Fire",                        -- L44
      "Lesser Conjuration: Fire",                 -- L39
      "Minor Conjuration: Fire",                  -- L34
      "Greater Summoning: Fire",                  -- L29
      "Summoning: Fire",                          -- L24
      "Lesser Summoning: Fire",                   -- L20
      "Minor Summoning: Fire",                    -- L16
      "Elemental: Fire",                          -- L12
      "Elementaling: Fire",                       -- L08
      "Elementalkin: Fire",                       -- L04
  },
  mag_air_pet = {
      "Child of Wind",                            -- L66, OOW
      "Ward of Xegony",                           -- L61, PoP
      "Greater Vocaration: Air",                  -- L59, Kunark
      "Vocarate: Air",                            -- L53, Kunark
      "Greater Conjuration: Air",                 -- L49
      "Conjuration: Air",                         -- L44
      "Lesser Conjuration: Air",                  -- L39
      "Minor Conjuration: Air",                   -- L34
      "Greater Summoning: Air",                   -- L29
      "Summoning: Air",                           -- L24
      "Lesser Summoning: Air",                    -- L20
      "Minor Summoning: Air",                     -- L16
      "Elemental: Air",                           -- L12
      "Elementaling: Air",                        -- L08
      "Elementalkin: Air",                        -- L04
  },
  mag_water_pet = {
      "Child of Water",                           -- L67 (pet ROG/65) - Malachite, OOW
      "Servant of Marr",                          -- L62 (pet ROG/60) - no reagent, PoP
      "Greater Vocaration: Water",                -- L60, Kunark
      "Vocarate: Water",                          -- L54, Kunark
      "Greater Conjuration: Water",               -- L49
      "Conjuration: Water",                       -- L44
      "Lesser Conjuration: Water",                -- L39
      "Minor Conjuration: Water",                 -- L34
      "Greater Summoning: Water",                 -- L29
      "Summoning: Water",                         -- L24
      "Lesser Summoning: Water",                  -- L20
      "Minor Summoning: Water",                   -- L16
      "Elemental: Water",                         -- L12
      "Elementaling: Water",                      -- L08
      "Elementalkin: Water",                      -- L04
  },
  mag_fire_nuke = {
      "Ancient: Nova Strike",                     -- L70 Ancient: Nova Strike (2377 hp, 6.3s cast, cost 525 mana)
      "Star Strike",                              -- L70 Star Strike (2201 hp, 6.4s cast, cost 494 mana)
      "Spear of Ro",                              -- L70 Spear of Ro (3119 hp, 7s cast, cost 684 mana)
      "Fickle Fire",                              -- L69 Fickle Fire (2475 hp, 6.4s cast, cost 519 mana) + chance to increase dmg
      "Burning Earth",                            -- L69 Burning Earth (1348 hp, 3s cast, cost 337 mana)
      "Bolt of Jerikor",                          -- L66 Bolt of Jerikor (2889 hp, cost 644 mana)
      "Ancient: Chaos Vortex",                    -- L65 Ancient: Chaos Vortex (1920 hp, cost 474 mana)
      "Sun Vortex",                               -- L65 Sun Vortex (1600 hp, cost 395 mana)
      "Burning Sand",                             -- L62 Burning Sand (980 hp, cost 270 mana)
      "Firebolt of Tallon",                       -- L61 Firebolt of Tallon (2100 hp, cost 515 mana)
      "Shock of Fiery Blades",                    -- L60 Shock of Fiery Blades (1294 hp, cost 335 mana)
      "Seeking Flame of Seukor",                  -- L59 Seeking Flame of Seukor
      "Scars of Sigil",                           -- L54 Scars of Sigil
      "Char",                                     -- L52 Char
      "Lava Bolt",                                -- L49 Lava Bolt
      "Cinder Bolt",                              -- L34 Cinder Bolt
      "Blaze",                                    -- L34 Blaze
      "Bolt of Flame",                            -- L20 Bolt of Flame (105 mana, 146-156 dd)
      "Shock of Flame",                           -- L16 Shock of Flame (70 mana, 91-96 dd)
      "Flame Bolt",                               -- L08 Flame Bolt
      "Burn",                                     -- L04 Burn
      "Burst of Flame",                           -- L01 Burst of Flame
  },
  mag_magic_nuke = {
    "Shock of Steel",                             -- L57 Shock of Steel (275 mana, 795-825  dd)
    "Shock of Swords",                            -- L44 Shock of Swords
    "Shock of Spikes",                            -- L24 Shock of Spikes
    "Shock of Blades",                            -- L08 Shock of Blades
  },
  mag_malo = {
      "Malosinia",                                -- L63: -70 cr, -70 mr, -70 pr, -70 fr, cost 300 mana
      "Mala",                                     -- L60: -35 cr, -35 mr, -35 pr, -35 fr, unresistable, cost 350 mana
      "Malosi",                                   -- L51: -58-60 cr, -58-60 mr, -58-60 pr, -58-60 fr, cost 175 mana
      "Malaisement",                              -- L44: -36-40 cr, -36-40 mr, -36-40 pr, -36-40 fr, cost 100 mana
      "Malaise",                                  -- L22: -15-20 cr, -15-20 mr, -15-20 pr, -15-20 fr, cost 60 mana
  },
  mag_pet_heal = {
      "Renewal of Jerikor",                       -- L69 Renewal of Jerikor (1635-1645 hp, -28 dr pr curse, cost 358 mana)
      "Planar Renewal",                           -- L64 Planar Renewal (1190-1200 hp, -24 dr pr curse, cost 290 mana)
      "Transon's Elemental Renewal",              -- L60 Transon's Elemental Renewal (849-873 hp, -20 dr pr curse, cost 237 mana)
      "Primal Remedy",                            -- L44: HoT, 120hp/tick
      "Renew Summoning",                          -- L20 Renew Summoning (140-200 hp)
      "Renew Elements",                           -- L08 Renew Elements (33-50 hp)
  },
  mag_pet_aa_heal = {
      "Mend Companion",                           -- L59 Mend Companion Rank 1 AA (36 min reuse without Hastened Mending AA) Luclin
                                                  -- L63 Mend Companion Rank 2 AA, PoP
      "Replenish Companion",                      -- L67 Replenish Companion Rank 1 AA (36 min reuse), OOW
                                                  -- L68 Replenish Companion Rank 2 AA, OOW
                                                  -- L69 Replenish Companion Rank 3 AA, OOW
  },
  mag_pbae_nuke = {
      "Wind of the Desert",                       -- L60 Wind of the Desert (1050 hp, aerange 25, recast 12s, cost 780 mana)
      "Scintillation",                            -- L51 Scintillation (597-608 hp, aerange 25, recast 6.5s, cost 361 mana)
      "Flame Arc",                                -- L39 Flame Arc (171-181 hp, aerange 20, recast 7s , cost 199 mana)
      "Flame Flux",                               -- L22 Flame Flux (89-96 hp, aerange 20, recast 6s, cost 123 mana)
      "Fire Flux",                                -- L01 Fire Flux (8-12 hp, aerange 20, recast 6s , cost 23 mana)
  },
  -- pet delay is fixed, so list is ordered by damage
  mag_pet_weapon = {
      --"Dagger of Symbols/Summon|Summoned: Dagger of Symbols", -- L39: 5/20 1hp
      "Sword of Runes/Summon|Summoned: Sword of Runes",       -- L29: 7/27 1hs, proc Ward Summoned
      "Spear of Warding/Summon|Summoned: Spear of Warding",   -- L20: 6/27 1hp, 5 fr, 5 cr
      "Summon Fang/Summon|Summoned: Snake Fang",              -- L12: 5/26 1hp
      "Summon Dagger/Summon|Summoned: Dagger",                -- L01: 3/21 1hp
  },
  mag_pet_gear = {
      "Muzzle of Mardu/Summon|Summoned: Muzzle of Mardu",     -- L56: 11% haste
  },
  mag_summoned_clickies = {
      "Modulating Rod/Summon|Summoned: Modulating Rod",       -- L44: 150 mana, -225 hp, 5 min recast (1 charge)
      "Summon Ring of Flight/Summon|Summoned: Ring of Flight",-- L39: levitate (2 charges)
      "Staff of Symbols/Summon|Summoned: Staff of Symbols",   -- L34: 10/34 2hb, click See Invisible (4 charges)
      "Staff of Runes/Summon|Summoned: Staff of Runes",       -- L24: 9/36 2hb, click Cancel Magic (1 charge)
      "Staff of Warding/Summon|Summoned: Staff of Warding",   -- L16: 8/38 2hb, click Gaze (5 charges)
      "Staff of Tracing/Summon|Summoned: Staff of Tracing",   -- L08: 7/40 2hb, click Flare (2 charges)
  },
  mag_epic2 = {
      "Focus of Primal Elements",                 -- epic 2.0: hp 1000, mana 12/tick, hp 24/tick, proc Primal Fusion Strike, defensive proc Primal Fusion Parry, 20 min (34 min with ext duration)
      "Staff of Elemental Essence",               -- epic 1.5: hp  800, mana 10/tick, hp 20/tick, proc Elemental Conjunction Strike, defensive proc Elemental Conjunction Parry
  },
  mag_oow_bp = {
      "Glyphwielder's Tunic of the Summoner",     -- oow t2 bp: pet buff, +50% skill dmg mod, -15% skill dmg taken for 0.5 min
      "Runemaster's Robe",                        -- oow t1 bp: pet buff, +50% skill dmg mod, -15% skill dmg taken for 0.3 min
  },
}