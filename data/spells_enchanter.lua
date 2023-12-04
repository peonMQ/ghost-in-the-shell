return {
  enc_manaregen = {
      "Seer's Cognizance",                        -- L78: 35 mana/tick, cost 610 mana
      "Seer's Intuition",                         -- L73: 24 mana/tick, cost 480 mana
      "Clairvoyance",                             -- L68: 20 mana/tick, cost 400 mana
      "Clarity II",                               -- L52: 9-11 mana/tick, cost 115 mana, Kunark
      "Clarity",                                  -- L26: 7-9 mana/tick, cost 75 mana, Original
      "Breeze",                                   -- L16: 2 mana/tick, cost 35 mana, Kunark
  },
  enc_group_manaregen = {
      "Voice of Cognizance",                      -- L80 Voice of Cognizance Rk. II (35 mana/tick, cost 1983 mana, group)
      "Voice of Intuition",                       -- L75 Voice of Intuition Rk. II (25 mana/tick, cost 1625 mana, group)
      "Voice of Clairvoyance",                    -- L70 Voice of Clairvoyance (20 mana/tick, cost 1300 mana, group), OOW
      "Voice of Quellious",                       -- L65 Voice of Quellious (18 mana/tick, group, cost 1200 mana), PoP
      --"Dusty Cap of the Will Breaker",          -- L65 Dusty Cap of the Will Breaker (LDoN raid). casts Voice of Quellious on L01 toons, TODO make use of
      "Tranquility",                              -- L63 Tranquility (16 mana/tick, group), PoP
      "Koadic's Endless Intellect",               -- L60 Koadic's Endless Intellect (14 mana/tick, group), Luclin
      "Gift of Pure Thought",                     -- L56 Gift of Pure Thought (10-11 mana/tick, group), Kunark
      "Boon of the Clear Mind",                   -- L42 Boon of the Clear Mind (6-9 mana/tick, group), Kunark
  },
  enc_mana_pool = {
      "Gift of Brilliance",                       -- L60: slot 1: 150 mana cap, slot 3: 2 mana/tick, Velious
      "Gift of Insight",                          -- L55: slot 1: 100 mana cap, slot 3: 1 mana/tick, Velious
  },
  enc_haste = {
      "Speed of Ellowind",                        -- L72 Speed of Ellowind   (68% haste, 64 atk, 72 agi, 60 dex, 42 min, 24% melee crit chance, %1 crit melee damage, cost 524 mana)
      "Speed of Salik",                           -- L67 Speed of Salik      (68% haste, 53 atk, 60 agi, 50 dex, 42 min 20% melee crit chance, cost 437 mana)
      "Speed of Vallon",                          -- L62 Speed of Vallon     (68% haste, 41 atk, 52 agi, 33 dex, 42 min)
      "Wonderous Rapidity",                       -- NOTE: original spelling, used on some classic servers like FVP
      "Wondrous Rapidity",                        -- L58 Wondrous Rapidity   (70% haste, 18.4 min)
      "Aanya's Quickening",                       -- L53 Aanya's Quickening  (64% haste, 24 min, DOES NOT land on lv15. DOES LAND on L42)
      "Swift Like the Wind",                      -- L47 Swift Like the Wind (60% haste, 16 min) - L01-45
      "Augmentation",                             -- L29: 22-28% haste, 27min
      "Alacrity",                                 -- L24 Alacrity (34-40% haste, 7 min)
      "Quickness",                                -- L16 Quickness (28-30% haste, 7 min)
  },
  enc_group_haste = {
      "Vallon's Quickening",                      -- L65 Vallon's Quickening (68% haste, 41 atk, 52 agi, 33 dex, 42 min, group)
      "Hastening of Salik",                       -- L67 Hastening of Salik  (68% haste, 53 atk, 60 agi, 50 dex, 42 min, 20% melee crit chance, cost 1260 mana, group)
      "Hastening of Ellowind",                    -- L75 Hastening of Ellowind Rk. II (68% haste, 66 atk, 75 agi, 63 dex, 42 min, 25% melee crit chance, 2% crit melee damage, cost 1575 mana, group)
  },
  enc_magic_resist = {
      "Guard of Druzzil",                         -- L62: 75 mr, group, PoP
      "Group Resist Magic",                       -- L49: 55 mr, group
      "Resist Magic",                             -- L39: 40 mr
      "Endure Magic",                             -- L20: 20 mr
  },
  enc_cha = {
      "Overwhelming Splendor",                    -- L56: 50 cha
      "Adorning Grace",                           -- L46: 40 cha
      "Radiant Visage",                           -- L31: 25-30 cha
      "Sympathetic Aura",                         -- L18: 15-18 cha
  },
  -- targeted rune - slot 1
  enc_rune = {
      "Rune of Erradien/Reagent|Peridot",         -- L76 Rune of Erradien (absorb rk1 5363 dmg, rk2 5631 dmg) SoF
      "Rune of Ellowind/Reagent|Peridot",         -- L71 Rune of Ellowind (absorb 2160 dmg) SerpentSpine
      "Rune of Salik/Reagent|Peridot",            -- L67 Rune of Salik (absorb 1105 dmg) OOW
      "Rune of Zebuxoruk/Reagent|Peridot",        -- L61 Rune of Zebuxoruk (absorb 850 dmg) PoP
      "Rune V/Reagent|Peridot",                   -- L52 Rune V (absorb 620-700 dmg) Kunark
      "Rune IV/Reagent|Peridot",                  -- L44 Rune IV (absorb 305-394 dmg, 90 min) Original
      "Rune III/Reagent|Jasper",                  -- L34 Rune III (absorb 168-230 dmg, 72 min) Original
      "Rune II/Reagent|Bloodstone",               -- L24 Rune II (absorb 71-118 dmg, 54 min) Original
      "Rune I/Reagent|Cat's Eye Agate",           -- L16 Rune I (absorb 27-55 dmg, 36 min) Original
  },
  enc_group_rune = {
      "Rune of the Deep",                         -- L79: slot 1: absorb 4118 dmg, slot 2: defensive proc Blurred Shadows Rk. II
      "Rune of Rikkukin",                         -- L69: slot 1: absorb 1500 dmg, group, DoN
  },

  -- self rune - slot 3. NOTE: don't stack with Eldritch Rune AA
  -- L65 Eldritch Rune AA Rank 1 (id:3258, absorb 500 dmg) PoP
  -- L65 Eldritch Rune AA Rank 2 (id:3259, absorb 1000 dmg) PoP
  -- L65 Eldritch Rune AA Rank 3 (id:3260, absorb 1500 dmg) PoP
  -- L66 Eldritch Rune AA Rank 4 (id:8109, absorb 1800 dmg)
  -- L67 Eldritch Rune AA Rank 5 (id:8110, absorb 2100 dmg)
  -- L68 Eldritch Rune AA Rank 6 (id:8111, absorb 2400 dmg)
  -- L69 Eldritch Rune AA Rank 7 (id:8112, absorb 2700 dmg)
  -- L70 Eldritch Rune AA Rank 8 (id:8113, absorb 3000 dmg, 10 min recast)
  enc_self_rune = {
      "Ethereal Rune",                            -- L66 Ethereal Rune (absorb 1950 dmg) OOW
      "Arcane Rune",                              -- L61 Arcane Rune (absorb 1500 dmg) PoP
  },

  -- NOTE: does not stack with clr_aegolism or shm_focus
  enc_self_shield = {
      "Mystic Shield",                            -- L66: 390 hp, 46 ac, 40 mr
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
  enc_tash = {
      "Howl of Tashan",                           -- L61 Howl of Tashan (-48-50 mr, 13.6 min, cost 40 mana) PoP
      "Tashanian",                                -- L57 Tashanian (-37-43 mr, 12.4 min, 40 mana) Kunark
      "Tashania",                                 -- L44 Tashania (-31-33 mr, 30 mana) Original
      "Tashani",                                  -- L20 Tashani (-20-23 mr, 20 mana) Original
      "Tashan",                                   -- L04 Tashan (-9-13 mr, 10 mana) Original
  },
  enc_mez = {
      "Euphoria",                                 -- L69: 0.9 min/L73, resist adj -10, 70% memblur, 375 mana, OOW
      "Felicity",                                 -- L67: 0.9 min/L70, resist adj -10, 70% memblur, 340 mana, OOW
      "Bliss",                                    -- L64: 0.9 min/L68, resist adj -10, 80% memblur, 300 mana, PoP
      "Sleep",                                    -- L63: 0.9 min/L65, resist adj -10, 75% memblur, 275 mana, PoP
      "Apathy",                                   -- L61: 0.9 min/L62, reisst adj -10, 70% memblur, 225 mana, PoP
      "Glamour of Kintaz",                        -- L54: 0.9 min/L57, resist adj -10, 70% memblur, 125 mana, 1.5s recast, Kunark
      "Dazzle",                                   -- L49: 1.6 min/L55, 1% memblur, 125 mana, 5s recast, Original
      "Entrance",                                 -- L34: 1.2 min/L55, 1% memblur, 85 mana, 3.75s recast, Original
      "Enthrall",                                 -- L16: 0.8 min/L55, 1% memblur, 50 mana, 2.5s recasat, Original
      "Mesmerize",                                -- L04: 0.4 min/L55, 1% memblur, 20 mana, 2.25s recast, Original
  },
  enc_unresistable_mez = {
      "Rapture",                                  -- L59: 0.7 min/L61, resist adj -1000, 80% memblur, 250 mana, 24s recast, Kunark
  },
  enc_ae_mez = {
      "Wake of Felicity",                         -- L69: 0.9 min/L70, 25 aerange, 6 sec recast
      "Bliss of the Nihil",                       -- L65: 0.6 min/L68, aerange 25, cost 850 mana, 6 sec recast, GoD
      "Word of Morell",                           -- L62: 0.3 min/L65, aerange 30, cost 300 mana, PoP
      "Fascination",                              -- L52: 36 sec/L55, 35 aerange resist adj -10, 1% memblur, cost 200 mana, Kunark
      "Mesmerization",                            -- L16: 0.4 min/L55, aerange 30, 1% memblur, cost 70 mana, Original
  },
  enc_slow = {
      "Desolate Deeds",                           -- L69: MAGIC 70% slow, resist adj -30, 1.5 min, cost 300 mana, OOW
      "Dreary Deeds",                             -- L65: MAGIC 70% slow, resist adj -10, 1.5 min, cost 270 mana, GoD
      "Forlorn Deeds",                            -- L57: MAGIC 67-70% slow, 2.9 min, 225 mana, Kunark
      "Shiftless Deeds",                          -- L44: MAGIC 49-65% slow, 2.7 min, 200 mana, Original
      "Tepid Deeds",                              -- L24: MAGIC 32-50% slow, 2.7 min, 100 mana, Original
      "Languid Pace",                             -- L12: MAGIC 18-30% slow, 2.7 min, 50 mana, Original
  },
  enc_disempower = {
      "Synapsis Spasm",                           -- L66 Synapsis Spasm (-100 dex, -100 agi, -100 str, -39 ac, cost 225 mana) OOW
      "Cripple",                                  -- L53 Cripple (-58-105 dex, -68-115 agi, -68-115 str, -30-45 ac, cost 225 mana) Kunark
      "Incapacitate",                             -- L40 Incapacitate (-45-55 agi, -45-55 str, -21-24 ac, cost 150 mana) Original
      "Listless Power",                           -- L25 Listless Power (-22-35 agi, -22-35 str, -10-18 ac, cost 90 mana) Original
      "Disempower",                               -- L16 Disempower (-9-12 sta, -13-15 str, -6-9 ac) Original
      "Enfeeblement",                             -- L04 Enfeeblement (-18-20 str, -3 ac, cost 20 mana) Original
  },
  enc_unresistable_charm = {
      "Ancient: Voice of Muram/MaxLevel|70",      -- L70 Ancient: Voice of Muram (-1000 magic, charm/L70, 0.8 min, 5m recast)
      "Dictate/MaxLevel|58",                      -- L60 Dictate (-1000 magic, charm/L58, 0.8 min, 5m recast)
      "Ordinance/MaxLevel|52",                    -- L48 Ordinance (-1000 magic, charm/L52, 0.8 min, 5m recast)
  },
  enc_charm = {
      "True Name/MaxLevel|69",                    -- L70 True Name (magic, charm/L69, 7.5 min). 5s cast time, 1.5s recast
      "Compel/MaxLevel|67",                       -- L68 Compel (magic, charm/L67, 7.5 min). 5s cast time, 1.5s recast
      "Command of Druzzil/MaxLevel|64",           -- L64 Command of Druzzil (magic, charm/L64, 7.5 min). 5s cast time, 1.5s recast
      "Beckon/MaxLevel|57",                       -- L62 Beckon (magic, charm/L57, 7.5 min)
      "Boltran's Agacerie/MaxLevel|53",           -- L53 Boltran's Agacerie (-10 magic, charm/L53, 7.5 min)
      "Allure/MaxLevel|51",                       -- L46 Allure (magic, charm/L51, 20.5 min)
      "Cajoling Whispers/MaxLevel|46",            -- L37 Cajoling Whispers (magic, charm/L46, 20.5 min)
      "Beguile/MaxLevel|37",                      -- L23 Beguile (magic, charm/L37, 20.5 min)
      "Charm/MaxLevel|25",                        -- L11 Charm (magic, charm/L25, 20.5 min)
  },
  enc_magic_nuke = {
      "Ancient: Neurosis",                        -- L70 Ancient: Neurosis (1634 hp, cost 398 mana)
      "Psychosis",                                -- L68 Psychosis (1513 hp, cost 375 mana)
      "Ancient: Chaos Madness",                   -- L65 Ancient: Chaos Madness (1320 hp, cost 360 mana)
      "Madness of Ikkibi",                        -- L65 Madness of Ikkibi (1210 hp, cost 330 mana)
      "Insanity",                                 -- L64 Insanity (1100 hp, cost 300 mana)
      "Dementing Visions",                        -- L58 Dementing Visions (836 hp, 239 mana)
      "Dementia",                                 -- L54 Dementia (571 hp, 1s stun, 169 mana)
      "Discordant Mind",                          -- L43 Discordant Mind (387 hp, 1s stun, 126 mana)
      "Anarchy",                                  -- L32 Anarchy (264-275 hp, 1s stun, 99 mana)
      "Chaos Flux",                               -- L21 Chaos Flux (152-175 hp, 1s stun, 67 mana)
      "Sanity Warp",                              -- L16 Sanity Warp (81-87 hp, 1s stun, 38 mana)
      "Chaotic Feedback",                         -- L07 Chaotic Feedback (28-32 hp, 1s stun, 16 mana)
  },
  enc_chromatic_nuke = {
      "Colored Chaos",                            -- L69 Colored Chaos (CHROMATIC, 1600 hp, cost 425 mana)
  },
  enc_ae_stun = {
      "Color Snap",                               -- L69: timer 3, 6s stun/L70, aerange 30, recast 12s
      "Color Cloud",                              -- L63: timer 3, 8s stun/L65, aerange 30, recast 12s   XXX best for pop stuns then!?
      "Color Slant",                              -- L52: 8s stun/L55?, -100 mana, aerange 35, recast 12s
      "Color Skew",                               -- L43: 8s stun/L55?, aerange 30, recast 12s
      "Color Shift",                              -- L20: 6s stun/L55?, aerange 25, recast 12s
      "Color Flux",                               -- L03: 4s stun/L55?, aerange 20, recast 12s
  },
  enc_root = {
      "Fetter",                                   -- L58: root for 3 min, Kunark
      "Paralyzing Earth",                         -- L49: root for 3 min
      "Immobilize",                               -- L39: root for 1 min
      "Enstill",                                  -- L29: root for 1.6 min
      "Root",                                     -- L08: root for 0.8 min
  },
  enc_epic2 = {
      "Staff of Eternal Eloquence",               -- epic 2.0: slot 5: Aegis of Abstraction,  absorb 1800 dmg
      "Oculus of Persuasion",                     -- epic 1.5: slot 5: Protection of the Eye, absorb 1500 dmg
  },
  enc_oow_bp = {
      "Mindreaver's Vest of Coercion",            -- oow t2 bp: Bedazzling Aura, 42 sec, -1% spell resist rate, 5 min reuse
      "Charmweaver's Robe",                       -- oow t1 bp: Bedazzling Eyes, 30 sec, -1% spell resist rate, 5 min reuse
  }
}