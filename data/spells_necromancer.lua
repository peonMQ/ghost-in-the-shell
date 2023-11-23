return {
  nec_levitate = {
      "Dead Man Floating",                        -- L41: 61-70 pr, water breathing, see invis, levitate
  },
  nec_group_levitate = {
      "Dead Men Floating",                        -- L45: 65-70 pr, water breathing, see invis, levitate, group
  },
  -- NOTE: nec_lich dont stack with enc_manaregen
  nec_lich = {
      "Spectralside",                             -- L79 Spectralside (87 mana/tick, cost 76 hp/tick, mottled skeleton)
      "Otherside",                                -- L74 Otherside Rk. II (81 mana/tick, cost 81 hp/tick, mottled skeleton)
      "Grave Pact",                               -- L70 Grave Pact (72 mana/tick, cost 60 hp/tick, skeleton, por expansion)
      "Dark Possession",                          -- L70 Dark Possession (65 mana/tick, cost 57 hp/tick, skeleton, oow expansion)
      "Ancient: Seduction of Chaos",              -- L65 Ancient: Seduction of Chaos (60 mana/tick, cost 50 hp/tick, skeleton)
      "Seduction of Saryrn",                      -- L64 Seduction of Saryrn (50 mana/tick, cost 42 hp/tick, skeleton)
      "Arch Lich",                                -- L60 Arch Lich (35 mana/tick, cost 36 hp/tick, wraith)
      "Demi Lich",                                -- L56 Demi Lich (31 mana/tick, cost 32 hp/tick)
      "Lich",                                     -- L48 Lich (20 mana/tick, cost 22 hp/tick)
      "Call of Bones",                            -- L31 Call of Bones (8 mana/tick, cost 11 hp/tick)
      "Dark Pact",                                -- L06 Dark Pact (2 mana/tick, cost 3 hp/tick)
  },
  -- NOTE: does not stack with ENC rune
  nec_self_rune = {
      "Shadowskin",                               -- L78 Shadowskin Rk. II (slot 1: absorb 1585 dmg, 4 mana/tick)
      "Wraithskin",                               -- L73 Wraithskin Rk. II (slot 1: absorb 1219 dmg, 4 mana/tick)
      "Dull Pain",                                -- L69: absorb 975 dmg, 3 mana/tick
      "Force Shield",                             -- L63: absorb 750 dmg, 2 mana/tick
      "Manaskin/Reagent|Peridot",                 -- L52: absorb 521-600 dmg, 1 mana/tick
      "Steelskin/Reagent|Jasper",                 -- L32: absorb 168-230 dmg
      "Leatherskin/Reagent|Bloodstone",           -- L22: absorb 71-118 dmg
      "Shieldskin/Reagent|Cat's Eye Agate",       -- L14: absorb 27-55 dmg
  },
  nec_pet_haste = {
      "Sigil of the Aberrant",                    -- L77 Sigil of the Aberrant Rk. II (10% skills dmg mod, 122 str, 70% haste, 36 ac)
      "Sigil of the Unnatural",                   -- L72 Sigil of the Unnatural (6% skills dmg mod, 96 str, 70% haste, 28 ac)
      "Glyph of Darkness",                        -- L67 Glyph of Darkness (5% skills dmg mod, 84 str, 70% haste, 23 ac)
      "Rune of Death",                            -- L62 Rune of Death (65 str, 70% haste, 18 ac)
      "Augmentation of Death",                    -- L55 Augmentation of Death (52-55 str, 65% haste, 14-15 ac)
      "Augment Death",                            -- L35 Augment Death (37-45 str, 45-55% haste, 9-12 ac
      "Intensify Death",                          -- L23 Intensify Death (25-33 str, 21-30% haste, 6-8 ac)
  },
  nec_pet_heal = {
      "Chilling Renewal",                         -- L73 Chilling Renewal (2420-2440 hp, -34 dr, -34 pr, -34 curse, -8 corruption, cost 504 mana)
      "Dark Salve",                               -- L69 Dark Salve (1635-1645 hp, -28 dr, -28 pr, -28 curse, cost 358 mana)
      "Touch of Death",                           -- L64 Touch of Death (1190-1200 hp, -24 dr, -24 pr, -24 curse, cost 290 mana)
      "Renew Bones",                              -- L26 Renew Bones (121-175 hp)
      "Mend Bones",                               -- L07 Mend Bones (22-32 hp)
  },
  -- NOTE: does not stack with clr_aegolism or shm_focus
  nec_self_shield = {
      "Shadow Guard",                             -- L66: 390 hp, 46 ac, 40 mr
      "Shield of Maelin",                         -- L64: 350 hp, 38-39 ac, 40 mr
      "Shield of the Arcane",                     -- L61: 298-300 hp, 34-36 ac, 30 mr
      "Shield of the Magi",                       -- L54: 232-250 hp, 29-31 ac, 22-24 mr
      "Arch Shielding",                           -- L41: 140-150 hp, 24-27 ac, 20 mr
      "Greater Shielding",                        -- L32: 91-100 hp, 20-22 ac, 16 mr
      "Major Shielding",                          -- L24: 68-75 hp, 16-18 ac, 14 mr
      "Shielding",                                -- L16: 45-50 hp, 11-13 ac, 11-12 mr
      "Lesser Shielding",                         -- L05: 17-30 hp, 5-9 ac, 6-10 mr
      "Minor Shielding",                          -- L01: 6-10 hp, 3-4 ac
  },
  nec_snare_dot = {
      "Desecrating Darkness",                     -- L68 Desecrating Darkness (resist adj -20, 96 hp/tick, 75% snare, 2.0 min, cost 248 mana)
      "Embracing Darkness",                       -- L63 Embracing Darkness (resist adj -20, 68-70 hp/tick, 75% snare, 2.0 min, cost 200 mana)
      "Devouring Darkness",                       -- L59 Devouring Darkness (123 hp/tick, 69-75% snare, 1.3 min, cost 400 mana)
      "Cascading Darkness",                       -- L47 Cascading Darkness (72 hp/tick, 60% snare, 1.6 min, cost 300 mana)
      "Dooming Darkness",                         -- L27 Dooming Darkness (20 hp/tick, 48-59% snare, 1.5 min, cost 120 mana)
      "Engulfing Darkness",                       -- L11 Engulfing Darkness (11 hp/tick, 40% snare, 1.0 min, cost 60 mana)
      "Clinging Darkness",                        -- L04 Clinging Darkness (8 hp/tick, 24-30% snare, 0.8 min, cost 20 mana)
  },
  nec_poison_dot = {
      "Chaos Venom",                              -- L70 Chaos Venom (473 hp/tick, POISON, resist adj -50, cost 566 mana)
      "Corath Venom",                             -- L69 Corath Venom (611 hp/tick, POISON,  resist adj -50, cost 655 mana)
      "Blood of Thule",                           -- L65 Blood of Thule (350-360 hp/tick, resist adj -50, poison)
      "Chilling Embrace",                         -- L36 Chilling Embrace (100-114 hp/tick, poison)
      "Venom of the Snake",                       -- L34 Venom of the Snake (x)
      "Poison Bolt",                              -- L04 Poison Bolt (10 hp/tick, poison)
  },
  nec_disease_dot = {
      "Grip of Mori",                             -- L67 Grip of Mori (194-197 hp/tick, -63-65 str, -35-36 ac, cost 325 mana)
      "Chaos Plague",                             -- L66 Chaos Plague (247-250 hp/tick, resist adj -50, disease)
      "Dark Plague",                              -- L61 Dark Plague (182-190 hp/tick, resist adj -50, disease, cost 340 mana)
      "Asystole",                                 -- L40 Asystole (x)
      "Scrounge",                                 -- L35 Scrounge (x)
      "Heart Flutter",                            -- L13 Heart Flutter (18-22 hp/tick, -13-20 str, -7-9 ac)
      "Disease Cloud",                            -- L01 Disease Cloud (x)
  },
  nec_magic_dot = {
      "Ancient: Curse of Mori",                   -- L70 Ancient: Curse of Mori (639 hp/tick, resist adj -30, magic, cost 625 mana)
      "Dark Nightmare",                           -- L67 Dark Nightmare (591 hp/tick, resist adj -30, magic, cost 585 mana)
      "Horror",                                   -- L63 Horror (432-450 hp/tick, resist adj -30, magic, cost 450 mana)
      "Splurt",                                   -- L51 Splurt (x)
      "Dark Soul",                                -- L39 Dark Soul (x)
  },
  nec_fire_dot = {
      "Dread Pyre",                               -- L70 Dread Pyre (956 hp/tick, resist adj -100, cost 1093 mana)
      "Pyre of Mori",                             -- L69 Pyre of Mori (419 hp/tick, resist adj -100, cost 560 mana)
      "Night Fire",                               -- L65 Night Fire (335 hp/tick, resist adj -100)
      "Pyrocruor",                                -- L58 Pyrocruor (156-166 hp/tick)
      "Ignite Blood",                             -- L47 Ignite Blood (X)
      "Boil Blood",                               -- L28 Boil Blood (67 hp/tick)
      "Heat Blood",                               -- L10 Heat Blood (28-43 hp/tick)
  },
  -- duration tap (heal + DoT)
  nec_heal_dot = {
      "Fang of Death",                            -- L68 Fang of Death (370 hp/tick, MAGIC, resist adj -200, cost 750 mana)
      "Night's Beckon",                           -- L65 Night's Beckon (220 hp/tick, MAGIC resist adj -200, cost 605 mana)
      "Night Stalker",                            -- L65 Night Stalker (122 hp/tick, DISEASE, resist adj -200, cost 950 mana)
      "Saryrn's Kiss",                            -- L62 Saryrn's Kiss (191-200 hp/tick, MAGIC, resist adj -200, magic, cost 550 mana)
      "Auspice",                                  -- L45 Auspice (30 hp/tick, DISEASE, resist adj -200)
      "Vampiric Curse",                           -- L29 Vampiric Curse (21 hp/tick, MAGIC, resist adj -200)
      "Leech",                                    -- L09 Leech (8 hp/tick, MAGIC, resist adj -200)
  },
  nec_poison_nuke = {
      "Call for Blood",                           -- L68 Call for Blood (1770 dmg, cost 568 mana) DoDH - adjusts dot dmg randomly, better than Ancient: Touch of Orshilak
      "Ancient: Touch of Orshilak",               -- L70 Ancient: Touch of Orshilak (-200 resist check, 1300 dmg, cost 598) OOW
      "Acikin",                                   -- L66 Acikin (1823 hp, cost 556 mana) OOW
      "Neurotoxin",                               -- L61 Neurotoxin (1325 hp, cost 445 mana) PoP
      "Ancient: Lifebane",                        -- L60 Ancient: Lifebane (1050 dmg)
      "Torbas' Venom Blast",                      -- L54 Torbas' Venom Blast (688 dmg, cost 251 mana)
      "Torbas' Acid Blast",                       -- L32 Torbas' Acid Blast (314-332 dmg)
      "Shock of Poison",                          -- L21 Shock of Poison (171-210 dmg)
  },
  nec_pbae_nuke = {
      "Word of Souls",                            -- L36 Word of Souls (MAGIC, 138-155 hp, aerange 20, recast 9s, cost 171 mana)
      "Word of Spirit",                           -- L27 Word of Spirit (MAGIC, 91-104 hp, aerange 20, recast 9s, cost 133 mana)
      "Word of Shadow",                           -- L20 Word of Shadow (MAGIC, 52-58 hp, aerange 20, recast 9s, cost 85 mana)
  },
  nec_scent_debuff = {
      "Scent of Midnight",                        -- L68 Scent of Midnight (-55 dr, -55 pr, disease, resist adj -200)
      "Scent of Terris",                          -- L52 Scent of Terris (-33-36 fr, -33-36 pr, -33-36 dr, poison)
      "Scent of Darkness",                        -- L37 Scent of Darkness (-23-27 fr, -23-27 pr, -23-27 dr)
      "Scent of Dusk",                            -- L10 Scent of Dusk (-6-9 fr, -6-9 pr, -6-9 dr)
  },
  nec_lifetap = {
      "Ancient: Touch of Orshilak",               -- L70 Ancient: Touch of Orshilak (1300 hp, cost 598 mana)
      "Soulspike",                                -- L67 Soulspike (1204 hp, cost 563 mana)
      "Touch of Night",                           -- L59 Touch of Night (708 hp, cost 382 mana)
      "Deflux",                                   -- L54 Deflux (535 hp, cost 299 mana)
      "Drain Spirit",                             -- L39 Drain Spirit (314 hp, cost 213 mana)
      "Spirit Tap",                               -- L26 Spirit Tap (202-210 hp, cost 152 mana)
      "Siphon Life",                              -- L20 Siphon Life (140-150 hp, cost 115 mana)
      "Lifedraw",                                 -- L12 Lifedraw (102-105 hp, cost 86 mana)
      "Lifespike",                                -- L03 Lifespike (8-12 hp, cost 13 mana)
      "Lifetap",                                  -- L01 Lifetap (4-6 hp, cost 8 mana)
  },
  nec_manadump = {
      "Sedulous Subversion",                      -- L56 Sedulous Subversion (150 mana, cost 400 mana, 8s recast)
      "Covetous Subversion",                      -- L43 Covetous Subversion (100 mana, cost 300 mana, 8s recast)
      "Rapacious Subvention",                     -- L21 Rapacious Subvention (60 mana, cost 200 mana)
  },
  nec_epic2 = {
      "Deathwhisper",                             -- epic 2.0: Guardian of Blood, swarm pet
      "Soulwhisper",                              -- epic 1.5: Servant of Blood, swarm pet
  },
  new_oow_bp = {
      "Blightbringer's Tunic of the Grave",       -- oow tier 2 bp: increase dot crit by 40% for 0.6 min, 5 min recast
      "Deathcaller's Robe",                       -- oow tier 1 bp: increase dot crit by 40% for 0.3 min, 5 min recast
  },
}