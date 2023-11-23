local class_buffs = {
    WAR = {
        { GroupName = 'clr_symbol' },
        { GroupName = 'clr_ac' },
        { GroupName = 'clr_aegolism' },

        { GroupName = 'shm_focus' },

        { GroupName = 'rng_hp' },

        { GroupName = 'rng_atk' },
        { GroupName = 'enc_haste' },
        { GroupName = 'shm_haste', NotClass = { 'ENC' } },

        { GroupName = 'dru_fire_resist' },
        { GroupName = 'enc_magic_resist' },
        { GroupName = 'shm_disease_resist' },
    }
}

class_buffs.SHD = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_ac' },
    { GroupName = 'clr_aegolism' },

    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },

    { GroupName = 'rng_atk' },
    { GroupName = 'enc_haste' },
    { GroupName = 'shm_haste', NotClass = { 'ENC' } },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'enc_magic_resist' },
    { GroupName = 'shm_disease_resist' },
}

class_buffs.PAL = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_ac' },
    { GroupName = 'clr_aegolism' },

    { GroupName = 'shm_focus' },

    { GroupName = 'rng_atk' },
    { GroupName = 'enc_haste' },
    { GroupName = 'shm_haste', NotClass = { 'ENC' } },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'enc_magic_resist' },
    { GroupName = 'shm_disease_resist' },
}

class_buffs.BRD = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_aegolism' },
    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },            -- 1st

    { GroupName = 'rng_atk' },
    { GroupName = 'shm_str' },
    { GroupName = 'enc_haste' },
    { GroupName = 'shm_haste', NotClass = { 'ENC' } },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'enc_magic_resist' },
    { GroupName = 'shm_disease_resist' },
}

class_buffs.CLR = {
    { GroupName = 'clr_aegolism' },
    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },

    { GroupName = 'enc_manaregen' },
    { GroupName = 'bst_manaregen' },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'enc_magic_resist' },
    { GroupName = 'shm_disease_resist' },
}

class_buffs.DRU = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },

    { GroupName = 'enc_manaregen' },
    { GroupName = 'bst_manaregen' },

    { GroupName = 'clr_spellhaste' },
    { GroupName = 'clr_vie' },

    { GroupName = 'enc_magic_resist' },
    { GroupName = 'shm_disease_resist' },
}

class_buffs.SHM = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_aegolism' },

    { GroupName = 'rng_hp' },

    { GroupName = 'enc_manaregen' },
    { GroupName = 'bst_manaregen' },

    { GroupName = 'clr_spellhaste' },
    { GroupName = 'clr_vie' },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'enc_magic_resist' },
}

class_buffs.ENC = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_aegolism' },
    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },

    { GroupName = 'clr_spellhaste' },
    { GroupName = 'bst_manaregen' },
    { GroupName = 'clr_vie' },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'shm_disease_resist' },
}

class_buffs.WIZ = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_aegolism' },
    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },

    { GroupName = 'clr_spellhaste' },
    { GroupName = 'enc_manaregen' },
    { GroupName = 'bst_manaregen' },
    { GroupName = 'clr_vie' },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'shm_disease_resist' },
    { GroupName = 'enc_magic_resist' },
}

class_buffs.MAG = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_aegolism' },
    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },

    { GroupName = 'clr_spellhaste' },
    { GroupName = 'enc_manaregen' },
    { GroupName = 'bst_manaregen' },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'shm_disease_resist' },
    { GroupName = 'enc_magic_resist' },
}

class_buffs.NEC = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_aegolism' },
    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },

    { GroupName = 'clr_spellhaste' },
    { GroupName = 'bst_manaregen' },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'shm_disease_resist' },
    { GroupName = 'enc_magic_resist' },
}

class_buffs.RNG = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_aegolism' },
    { GroupName = 'shm_focus' },

    { GroupName = 'shm_str' },
    { GroupName = 'enc_haste' },
    { GroupName = 'shm_haste', NotClass = { 'ENC' } },

    { GroupName = 'clr_spellhaste' },
    { GroupName = 'enc_manaregen' },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'enc_magic_resist' },
    { GroupName = 'shm_disease_resist' },
}

class_buffs.BST = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_aegolism' },
    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },                 -- 1st

    { GroupName = 'shm_str' },
    { GroupName = 'rng_atk' },
    { GroupName = 'enc_haste' },
    { GroupName = 'shm_haste', NotClass = { 'ENC' } },

    { GroupName = 'clr_spellhaste' },
    { GroupName = 'enc_manaregen' },
    { GroupName = 'bst_manaregen' },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'enc_magic_resist' },
    { GroupName = 'shm_disease_resist' },
}

class_buffs.ROG = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_aegolism' },
    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },                 -- 1st

    { GroupName = 'shm_str' },
    { GroupName = 'rng_atk' },
    { GroupName = 'enc_haste' },
    { GroupName = 'shm_haste', NotClass = { 'ENC' } },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'enc_magic_resist' },
    { GroupName = 'shm_disease_resist' },
}

class_buffs.MNK = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_aegolism' },
    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },                 -- 1st

    { GroupName = 'shm_str' },
    { GroupName = 'rng_atk' },
    { GroupName = 'enc_haste' },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'enc_magic_resist' },
    { GroupName = 'shm_disease_resist' },
}

class_buffs.BER = {
    { GroupName = 'clr_symbol' },
    { GroupName = 'clr_aegolism' },
    { GroupName = 'shm_focus' },

    { GroupName = 'rng_hp' },                 -- 1st

    { GroupName = 'shm_str' },
    { GroupName = 'rng_atk' },
    { GroupName = 'enc_haste' },
    { GroupName = 'shm_haste', NotClass = { 'ENC' } },

    { GroupName = 'dru_fire_resist' },
    { GroupName = 'enc_magic_resist' },
    { GroupName = 'shm_disease_resist' },
}


return class_buffs