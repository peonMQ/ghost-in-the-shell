return {
  -- group heals with cure component
  clr_group_heal = {
      "Word of Vivification",                     -- CLR/69: 3417-3427 hp, -21 dr, -21 pr, -14 curse, cost 1357 mana
      "Word of Replenishment",                    -- CLR/64: 2500 hp, -14 dr, -14 pr, -7 curse, cost 1100 mana
      "Word of Redemption",                       -- CLR/60: 7500 hp, cost 1100 mana
      "Word of Restoration",                      -- CLR/57: 1788-1818 hp, cost 898 mana
      "Word of Health",                           -- CLR/30: 380-485 hp, cost 302 mana
  },
  clr_heal = {
      "Ancient: Hallowed Light",                  -- L70 Ancient: Hallowed Light (4150 hp, 3.8s cast, 775 mana)
      "Pious Light",                              -- L68 Pious Light (3750-3770 hp, 3.8s cast, 740 mana)
      "Holy Light",                               -- L65 Holy Light (3275 hp, 3.8s cast, 650 mana)
      "Supernal Light",                           -- L63 Supernal Light (2730-2750 hp, 3.8s cast, 600 mana)
      "Ethereal Light",                           -- L58 Ethereal Light (1980-2000 hp, 3.8s cast, 490 mana)
      "Divine Light",                             -- L53 Divine Light
      "Greater Healing",                          -- L20 Greater Healing (280-350 hp, 3.0s cast, 115 mana)
      "Healing",                                  -- L10 Healing (135-175 hp, 2.5s cast, 65 mana)
      "Light Healing",                            -- L04 Light Healing (47-65 hp, 2s cast, 28 mana)
      "Minor Healing",                            -- L01 Minor Healing (12-20 hp, 1.5s cast, 10 mana)
  },
  clr_remedy = {
      "Pious Remedy",                             -- L66 Pious Remedy (1990 hp, 1.8s cast, 495 mana)
      "Supernal Remedy",                          -- L61 Supernal Remedy (1450 hp, 1.8s cast, 400 mana)
      "Ethereal Remedy",                          -- L58 Ethereal Remedy (975 hp, 2.8s cast, 400 mana)
      "Remedy",                                   -- L51 Remedy (463-483 hp, 1.8s cast, 167 mana)
  },
  clr_hot = {
      "Pious Elixir",                             -- L67 Pious Elixir (slot 1: 1170 hp/tick, 0.4 min, 890 mana)
      "Holy Elixir",                              -- L65 Holy Elixir (900 hp/tick, 0.4 min, 720 mana)
      "Supernal Elixir",                          -- L62 Supernal Elixir (600 hp/tick, 0.4 min, 480 mana)
      "Ethereal Elixir",                          -- L60 Ethereal Elixir (300 hp/tick, 0.4 min, 975 mana, group)
      "Celestial Elixir",                         -- L59 Celestial Elixir (300 hp/tick, 0.4 min, 300 mana)
      "Celestial Healing",                        -- L44 Celestial Healing (180 hp/tick, 0.4 min, 225 mana)
  },
  -- group hot, don't stack with Celestial Regeneration AA
  clr_group_hot = {
      "Elixir of Divinity",                       -- L70 Elixir of Divinity (900 hp/tick, group, cost 1550 mana)
  },
  clr_rez = {
      "Reviviscence",                             -- L56: 96% exp, 7s cast, 600 mana, Kunark
      "Resurrection",                             -- L47: 90% exp, 6s cast, 20s recast, 700 mana, Original
      "Restoration",                              -- L42: 75% exp, 6s cast, 20s recast, Luclin?
      "Resuscitate",                              -- L37: 60% exp, 6s cast, 20s recast, Original
      "Renewal",                                  -- L32: 50% exp, 6s cast, 20s recast, Luclin?
      "Revive",                                   -- L27: 35% exp, 6s cast, 20s recast, Original
      "Reparation",                               -- L22: 20% exp, 6s cast, 20s recast, Luclin?
      "Reconstitution",                           -- L18: 10% exp, 6s cast, 20s recast, Luclin?
      "Reanimation",                              -- L12:  0% exp, 6s cast, 20s recast, Luclin?
  },
  -- NOTE: stacks with dru_skin and clr_ac
  clr_symbol = {
      "Symbol of Kaerra",                         -- L76 Symbol of Kaerra Rk. II (1847 hp, cost 1190 mana)
      "Symbol of Elushar",                        -- L71 Symbol of Elushar (1364 hp, cost 936 mana)
      "Symbol of Balikor",                        -- L66 Symbol of Balikor (1137 hp, cost 780 mana)
      "Symbol of Kazad",                          -- L61 Symbol of Kazad (910 hp, cost 600 mana) PoP
      "Symbol of Marzin/Reagent|Peridot",         -- L54 Symbol of Marzin (640-700 hp)
      "Symbol of Naltron/Reagent|Peridot",        -- L41 Symbol of Naltron (406-525 hp)
      "Symbol of Pinzarn/Reagent|Jasper",         -- L34 Symbol of Pinzarn
      "Symbol of Ryltan/Reagent|Bloodstone",      -- L24 Symbol of Ryltan
      "Symbol of Transal/Reagent|Cat's Eye Agate",-- L14 Symbol of Transal (34-72 hp)
  },
  clr_group_symbol = {
      "Kaerra's Mark",                            -- L80 Kaerra's Mark (1563 hp, cost 3130 mana)
      "Elushar's Mark",                           -- L75 Elushar's Mark Rk. II (1421 hp, cost 2925 mana)
      "Balikor's Mark",                           -- L70 Balikor's Mark (1137 hp, cost 2340 mana)
      "Kazad's Mark",                             -- L63 Kazad's Mark (910 hp, cost 1800 mana) PoP
      "Marzin's Mark",                            -- L60 Marzin's Mark (725 hp)
      "Naltron's Mark",                           -- L58 Naltron's Mark (525 hp)
  },
  clr_di = {
      "Divine Intervention",                      -- L60 Divine Intervention (single)
  },
  -- NOTE: stacks with clr_symbol + dru_skin + shm_focus
  clr_ac = {
      "Order of the Resolute",                    -- L80 Order of the Resolute Rk. II (slot 4: 109 ac, group)
      "Ward of the Resolute",                     -- L76 Ward of the Resolute Rk. II (solt 4: 109 ac)
      "Ward of the Dauntless",                    -- L71 Ward of the Dauntless (slot 4: 86 ac)
      "Ward of Valiance",                         -- L66 Ward of Valiance (slot 4: 72 ac)
      "Ward of Gallantry",                        -- L61 Ward of Gallantry (slot 4: 54 ac)
      "Shield of Words",                          -- L49 Shield of Words (slot 4: 31 ac)
      "Armor of Faith",                           -- L39 Armor of Faith (slot 4: 24-25 ac)
      "Guard",                                    -- L29 Guard (slot 4: 18-19 ac)
      "Spirit Armor",                             -- L19 Spirit Armor (slot 4: 11-13 ac)
      "Holy Armor",                               -- L05 Holy Armor (slot 4: 6 ac)
  },
  -- NOTE: slot 2 - does not stack with dru_skin
  clr_aegolism     = {
      "Temerity",                                 -- L77: 2457 hp, 126  ac, SoF
      "Tenacity",                                 -- L72: (2144 hp, 113 ac)
      "Conviction",                               -- L67: (1787 hp, 94 ac)
      "Virtue",                                   -- L62: (1405 hp, 72 ac, single) PoP
      "Aegolism",                                 -- L60: (1150 hp, 60 ac, single) Velious
      "Temperance",                               -- L40: (800 hp, 48 ac, single) LoY - LANDS ON L01
      "Fortitu    de",                            -- L55: (320-360 hp, 17-18 ac, 2h24m duration) Kunark
      "Heroic Bond",                              -- L52: (360-400 hp, 18-19 ac, group) Kunark
      "Heroism",                                  -- L52: (360-400 hp, 18-19 ac, 1h12m duration) Kunark
      "Resolution",                               -- L44: (232-250 hp, 15-16 ac)
      "Valor",                                    -- L34: (168-200 hp, 12-13 ac)
      "Bravery",                                  -- L24: (114-140 hp, 9-10 ac)
      "Daring",                                   -- L19: (84-135 hp, 7-9 ac)
      "Center",                                   -- L09: (44-105 hp, 5-6 ac)
      "Courage",                                  -- L01: (20 hp, 4 ac, single)
  },
  clr_group_aegoism = {
      "Hand of Temerity",                         -- L80 Hand of Temerity (2457 hp, 126 ac, group)
      "Hand of Tenacity",                         -- L75 Hand of Tenacity Rk. II (2234 hp, 118 ac, group)
      "Hand of Conviction",                       -- L70 Hand of Conviction (1787 hp, 94 ac, group) - LANDS ON L62
      "Hand of Virtue",                           -- L65 Hand of Virtue (1405 hp, 72 ac, group) PoP - LANDS ON L47
      "Blessing of Aegolism",                     -- L60 Blessing of Aegolism (1150 hp, 60 ac, group) Luclin
      "Blessing of Temperance",                   -- L45 Blessing of Temperance (800 hp, 48 ac, group) LDoN - LANDS ON L01
  },
  clr_vie = {
      "Shield of Vie",                            -- L78: absorb 10% of melee dmg to 3380, 36 min
      "Aegis of Vie",                             -- L73: absorb 10% of melee dmg to 2496, 36 min
      "Panoply of Vie",                           -- L67: absorb 10% melee dmg to 2080, 36 min
      "Bulwark of Vie",                           -- L62: absorb 10% melee dmg to 1600
      "Protection of Vie",                        -- L54: absorb 10% melee dmg to 1200
      "Guard of Vie",                             -- L40: absorb 10% melee dmg to 700
      "Ward of Vie",                              -- L20: absorb 10% melee dmg to 460
  },
  clr_group_vie = {
      "Rallied Shield of Vie",                    -- L80: slot 1: absorb 10% of melee dmg to 3380, 36 min, group
      "Rallied Aegis of Vie",                     -- L75: absorb 10% of melee dmg to 2600, 36 min, group
  },
  clr_spellhaste = {
      "Blessing of Resolve",                      -- L76 Blessing of Resolve Rk. II (10% spell haste to L80, 40 min, 390 mana)
      "Blessing of Purpose",                      -- L71 Blessing of Purpose (9% spell haste to L75, 40 min, 390 mana)
      "Blessing of Devotion",                     -- L67 Blessing of Devotion (10% spell haste to L70, 40 min, 390 mana) OOW
      "Blessing of Reverence",                    -- L62 Blessing of Reverence (10% spell haste to L65, 40 min) PoP
      "Blessing of Faith",                        -- L35 Blessing of Faith (10% spell haste to L61, 40 min) PoP
      "Blessing of Piety",                        -- L15 Blessing of Piety (10% spell haste to L39, 40 min) PoP
  },
  clr_group_spellhaste = {
      "Aura of Resolve",                          -- L77 Aura of Resolve Rk. II (10% spell haste to L80, 45 min, group, 1125 mana)
      "Aura of Purpose",                          -- L72 Aura of Purpose Rk. II (10% spell haste to L75, 45 min, group, 1125 mana)
      "Aura of Devotion",                         -- L69 Aura of Devotion (10% spell haste to L70, 45 min, group, 1125 mana) OOW
      "Aura of Reverence",                        -- L64 Aura of Reverence (10% spell haste to L65, 40 min, group) LDoN
  },
  -- NOTE: does not stack with dru_skin
  clr_self_shield = {
      "Armor of the Solemn",                      -- L80 Armor of the Solemn Rk. II (915 hp, 71 ac, 12 mana/tick)
      "Armor of the Sacred",                      -- L75 Armor of the Sacred Rk. II (704 hp, 58 ac, 10 mana/tick)
      "Armor of the Pious",                       -- L70 Armor of the Pious (563 hp, 46 ac, 9 mana/tick)
      "Armor of the Zealot",                      -- L65 Armor of the Zealot (450 hp, 36 ac, 8 mana/tick)
      "Blessed Armor of the Risen",               -- L58 Blessed Armor of the Risen (294-300 hp, 30 ac, 6 mana/tick)
      "Armor of the Faithful",                    -- L49 Armor of the Faithful (252-275 hp, 22 ac)
      "Armor of Protection",                      -- L34 Armor of Protection (202-225 hp, 15 ac)
  },
  clr_yaulp = {
      "Yaulp VII",                                -- L69 Yaulp VII (80 atk, 14 mana/tick, 100 dex, 30% haste)
      "Yaulp VI",                                 -- L65 Yaulp VI (60 atk, 12 mana/tick, 90 dex, 30% haste)
      "Yaulp V",                                  -- L56 Yaulp V (50 atk, 10 mana/tick, 75 dex, 25% haste)
      "Yaulp IV",                                 -- L53 Yaulp IV () Kunark
      "Yaulp III",                                -- L44 Yaulp III () Original
      "Yaulp II",                                 -- L19 Yaulp II () Original
      "Yaulp",                                    -- L01 Yaulp () Original
  },
  clr_stun = {
      "Enforced Reverence",                       -- L58 Enforced Reverence
      "Sound of Force",                           -- L49 Sound of Force
      "Force",                                    -- L34 Force
      "Holy Might",                               -- L19 Holy Might
      "Stun",                                     -- L05 Stun
  },
  clr_nuke = {
      "Ancient: Pious Conscience",                -- L70: 1646 dd, cost 457 mana
      "Chromastrike",                             -- L69: 1200 dd, cost 375 mana, chromatic resist
      "Reproach",                                 -- L67: 1424-1524 dd, cost 430 mana
      "Ancient: Chaos Censure",                   -- L65: 1329 dd, cost 413 mana
      "Order",                                    -- L65: 1219 dd, cost 379 mana
      "Condemnation",                             -- L62: 1175 dd, cost 365 mana
      "Judgment",                                 -- L56: 842 dd, cost 274 mana
      "Reckoning",                                -- L54: 675 dd, cost 250 mana, Kunark
      "Retribution",                              -- L44: 372-390 dd, cost 240 mana, Original
      "Wrath",                                    -- L29: 192-218 dd, cost 145 mana
      "Smite",                                    -- L14: -74-83 dd, cost 70 mana
      "Furor",                                    -- L05: -16-19 dd, cost 20 mana
      "Strike",                                   -- L01: -6-8 dd, cost 12 mana
  },
  clr_pbae_nuke = {
      "Calamity",                                 -- L69 Calamity (1105 hp, aerange 35, recast 24s, cost 812 mana - PUSHBACK 1.0)
      "Catastrophe",                              -- L64 Catastrophe (850 hp, aerange 35, recast 24s, cost 650 mana)
      "The Unspoken Word",                        -- L59 The Unspoken Word (605 hp, aerange 20, recast 120s, cost 427 mana)
      "Upheaval",                                 -- L52 Upheaval (618-725 hp, aerange 35, recast 24s, cost 625 mana)
      "Word Divine",                              -- L49 Word Divine (339 hp, aerange 20, recast 9s, cost 304 mana)
      "Earthquake",                               -- L44 Earthquake (214-246 hp, aerange 30, recast 24s, cost 375 mana)
      "Word of Souls",                            -- L39 Word of Souls (138-155 hp, aerange 20, recast 9s, cost 171 mana)
      "Tremor",                                   -- L34 Tremor (106-122 hp, aerange 30, recast 10s, cost 200 mana)
      "Word of Spirit",                           -- L26 Word of Spirit (91-104 hp, aerange 20, recast 9s, cost 133 mana)
      "Word of Shadow",                           -- L19 Word of Shadow (52-58 hp, aerange 20, recast 9s, cost 85 mana)
      "Word of Pain",                             -- L09 Word of Pain (24-29 hp, aerange 20, recast 9s, cost 47 mana)
  },
  clr_magic_resist = {
      "Resist Magic",                             -- L44: 40 mr
      "Endure Magic",                             -- L19: 20 mr
  },
  clr_oow_bp = {
      "Faithbringer's Breastplate of Conviction", -- oow T2 bp: increase healing spell potency by 1-50% for 0.7 min
      "Sanctified Chestguard",                    -- oow T1 bp: increase healing spell potency by 1-50% for 0.5 min
  },
}