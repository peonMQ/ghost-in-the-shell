local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local port_spells = require "data/spells_ports"
local settings = require('settings/settings')
local state = require('application/casting/casting_state')
local spell = require('core/casting/spell')
local binder = require('application/binder')

local function getPortSpell(zoneShortName, classShortName)
  local class_port_spells = port_spells[classShortName]
  if not class_port_spells then
    logger.Warn("<%s> does not have portal spells configurated", mq.TLO.Me.Class.Name())
    return nil
  end

  local port_spell = class_port_spells[zoneShortName]
  if not port_spells then
    logger.Warn("<%s> does not have portal spells configurated for class <%s>", zoneShortName, classShortName)
    return nil
  end

  return port_spell
end

local function execute(zoneShortName)
  local classShortName = mq.TLO.Me.Class.ShortName()
  local port_spell = getPortSpell(zoneShortName, classShortName)
  if not port_spell then
    return
  end

  if classShortName == "DRU" then
    -- Abort if druid and grouped with a wizard within 5 levels of the druid's level
    for i = 1,mq.TLO.Group.Members() do
        local member = mq.TLO.Group.Member(i)
        local class = member.Class.ShortName()
        if class == "WIZ" and getPortSpell(zoneShortName, class) then
            logger.Warn("Aborting /port: I am grouped with capable wizard %s, they will port!", member.Name())
            return
        end
    end
  end

  local portToSpell = spell:new(port_spell, settings:GetDefaultGem(port_spell), 0, 30)

  -- if not mq.TLO.Me.SpellReady(portToSpell.Name)() then
  --   portToSpell:MemSpell()
  --   mq.delay("60s", function() return mq.TLO.Me.SpellReady(portToSpell.Name)() end )
  -- end

  if mq.TLO.Me.Casting() then
    state.interrupt(mq.TLO.Me.Casting.ID())
  end

  portToSpell:MemSpell(nil, 60)
  logger.Info("Teleporting to <%s>", portToSpell.Name)
  broadcast.WarnAll("Teleporting to <%s>", portToSpell.Name)
  portToSpell:Cast()
end

local function createCommand(zoneShortName)
  commandQueue.Enqueue(function() execute(zoneShortName) end)
end

binder.Bind("/port", createCommand, "Tells the bot to teleport using the spell that matches the supplied 'zone_short_name'", 'zone_short_name')
