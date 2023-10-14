--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')

local casterResistsSelfBuff = {
  "Shielding",          -- L16
  "Major Shielding",    -- L24
  "Greater Shielding",  -- L34
  "Arch Shielding",     -- L44
  "Shield of the Magi"  -- L54
}

local magWizResistsSelfBuff = {
  "Elemental Armor"  -- L44
}
