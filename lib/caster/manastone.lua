--- @type Mq
local mq = require 'mq'
local configLoader = require 'utils/configloader'

---@class CommonConfig
local defaultConfig = {
  StartManaPct = 90,
  EndHPPct = 70
}

local config = configLoader("general.mana.manastone", defaultConfig)
local hasManaStone = mq.TLO.FindItem("=Manastone")()

local function doManastone()
  if not hasManaStone then
    return
  end

  local me = mq.TLO.Me
  if me.Invis() then
    return
  end

  if me.PctMana() > config.StartManaPct then
    return
  end

  if me.PctHPs() < config.EndHPPct then
    return
  end

  mq.cmd("/useitem Manastone")
end

return doManastone