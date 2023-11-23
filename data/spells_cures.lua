
---@alias CounterTypes 'any'|'curse'|'disease'|'poison'|'radiant'

---@type table<CounterTypes, string[]>
local cures = {}

-- List of "disease" cures, order: most powerful first
cures.disease = {
    "Desperate Renewal",                                -- CLR/70: -18 disease, -18 poison, -18 curse
    "Radiant Cure/Group",
    "Blood of Nadox/Group",                             -- SHM/52: -9 poison x2, -9 disease x2 (group)
    --"Difinecting Aura",                                 -- SHM/52: -10 poison x2, -10 disease x2
    "Abolish Disease",                                  -- SHM/48, BST/63: -36 disease
    "Crusader's Purity",                                -- PAL/67: -32 disease, -32 poison, -16 curse
    "Crusader's Touch",                                 -- PAL/62: -20 disease, -20 poison, -5 curse
    "Counteract Disease",                               -- SHM/22, DRU/28, CLR/28, BST/45, PAL/56, RNG/61, NEC/36: -8 disease
    "Cure Disease",                                     -- SHM/01, DRU/04, CLR/04, BST/04, PAL/11, RNG/22, NEC/13: -1 to -4 disease
}

-- List of "poison" cures, order: most powerful first
cures.poison = {
    "Desperate Renewal",                                -- CLR/70: -18 poison, -18 disease, -18 curse
    "Radiant Cure/Group",
    --"Puratus",                                          -- CLR/70: cure all poisons from target + block next posion spell from affecting them, 15s recast
    "Purge Posion/Self",                                -- ROG/59: -99 poison x12 (AA)
    "Antidote",                                         -- CLR/58: -16 poison x4
    "Blood of Nadox/Group",                             -- SHM/52: -9 poison x2, -9 disease x2 (group)
    --"Difinecting Aura",                                 -- SHM/52: -10 poison x2, -10 disease x2
    "Pure Blood",                                       -- CLR/51, DRU/52: -9 poison x4
    "Abolish Poison",                                   -- CLR/48: -36 posion
    "Crusader's Purity",                                -- PAL/67: -32 disease, -32 poison, -16 curse
    "Crusader's Touch",                                 -- PAL/62: -20 disease, -20 poison, -5 curse
    "Counteract Poison",                                -- CLR/22, SHM/26, DRU/28, PAL/34, BST/61, RNG/61: -8 posion
    "Cure Poison",                                      -- CLR/01, SHM/02, DRU/05, PAL/05, BST/13, RNG/13: -1 to -4 poison
}

-- List of "curse" cures, order: most powerful first
cures.curse = {
    "Desperate Renewal",                                -- CLR/70: -18 curse, -18 poison, -18 disease
    "Radiant Cure/Group",
    "Remove Greater Curse",                             -- CLR/54, DRU/54, SHM/54, PAL/60: -9 curse x5
    "Remove Curse",                                     -- CLR/38, DRU/38, SHM/38, PAL/45: -4 curse x2
    "Remove Lesser Curse",                              -- CLR/23, DRU/23, SHM/24, PAL/34: -4 curse
    "Remove Minor Curse",                               -- CLR/08, DRU/08, SHM/09, PAL/19: -2 curse
}

cures.radiant = {
    "Radiant Cure/Group",
}

-- List of the "any" cures, order: most powerful first
cures.any = {
    "Radiant Cure/Group",

    "Pure Spirit",                                      -- SHM/69: 95% chance to remove detrimental effect from target, 12s recast

    --"Desperate Renewal",                                -- CLR/70: heal 4935 hp, -18 pr, -18 dr, -18 curse, cost 1375 mana

    "Purify Body/Self",                                 -- MNK/59: remove all negative effects, 30 min reuse (21 min reuse with Hastened Purification of the Body Rank 3)

    "Purify Soul/Self",                                 -- CLR/59: remove all negative effects, 30 min reuse (15 min reuse with Hastened Purification of the Soul Rank 5)

    "Blessing of Purification",                         -- PAL/80: remove all negative effects, xxx reuse
    "Purification/Self",                                -- PAL/65: remove all negative effects, 1h12 min reuse (14m24s reuse with Hastened Purification Rank 8)
}

return cures