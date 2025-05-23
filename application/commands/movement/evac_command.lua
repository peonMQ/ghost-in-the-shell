local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local port_spells = require "data/spells_ports"
local settings = require('settings/settings')
local state = require('application/casting/casting_state')
local assist_state = require('application/assist_state')
local spell = require('core/casting/spell')
local binder = require('application/binder')

local function execute(port_spell)
  local evacSpell = spell:new(port_spell, settings:GetDefaultGem(port_spell), 0, 30)

  if not mq.TLO.Me.SpellReady(evacSpell.Name)() then
    mq.delay("10s", function() return mq.TLO.Me.SpellReady(evacSpell.Name)() end )
  end

  if mq.TLO.Me.Casting() then
    state.interrupt(mq.TLO.Me.Casting.ID())
  end

  evacSpell:Cast()
  logger.Info("<<< EVACUATING [%s] >>>", evacSpell.Name)
  broadcast.WarnAll("<<< EVACUATING [%s] >>>", evacSpell.Name)
end

local function createCommand(zoneShortName)
  local class_port_spells = port_spells[mq.TLO.Me.Class.ShortName()]
  if not class_port_spells then
    broadcast.InfoAll("<%s> does not have portal spells configurated", mq.TLO.Me.Class.Name())
    return;
  end

  local port_spell = class_port_spells[zoneShortName]
  if not port_spells then
    broadcast.InfoAll("<%s> does not have portal spells configurated for class <%s>", zoneShortName, mq.TLO.Me.Class.ShortName())
    return;
  end

  assist_state:Reset('current_target_id')
  assist_state:Reset('current_pet_target_id')
  commandQueue.Clear()
  commandQueue.Enqueue(function() execute(port_spell) end)
end

binder.Bind("/evac", createCommand, "Tells the bot to evacuate using the spell that matches the supplied 'zone_short_name'", 'zone_short_name')
