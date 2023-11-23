--- @type Mq
local mq = require 'mq'
local broadcast = require 'broadcast/broadcast'
local logger = require 'utils/logging'
local configLoader = require 'utils/configloader'
local state = require 'lib/spells/state'
local spell = require 'lib/spells/types/spell'

---@class CommonConfig
local defaultConfig = {
  Evacspell = "",
}

local config = configLoader("general.evac", defaultConfig)
if not config.Evacspell then
  return
end

local evacSpell = spell:new(config.Evacspell, 8, 0, 30)

local function evacuate()
  if not mq.TLO.Me.SpellReady(evacSpell.Name)() then
    mq.delay("10s", function() return mq.TLO.Me.SpellReady(evacSpell.Name)() end )
  end

  if mq.TLO.Me.Casting() then
    state.interrupt()
  end

  evacSpell:Cast()
  logger.Info("<<< EVACUATING [%s] >>>", evacSpell.Name)
  broadcast.WarnAll("<<< EVACUATING [%s] >>>", evacSpell.Name)
end

mq.unbind('/evac')
mq.bind("/evac", evacuate)