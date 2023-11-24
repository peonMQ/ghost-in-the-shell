local mq = require("mq")
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local spell_finder = require 'lib/spells/spell_finder'
local spells_mezmerize = require 'data/spells_mezmerize'
local assist_state = require 'settings/assist_state'
local commandQueue  = require("application/command_queue")

local function execute(mezz_mode)
  if not mezz_mode then
    assist_state.mezz_mode = nil
  end

  local mezz_spell_group = spells_mezmerize[mq.TLO.Me.Class.ShortName()] and spells_mezmerize[mq.TLO.Me.Class.ShortName()][mezz_mode]
  if not mezz_spell_group then
    assist_state.mezz_mode = nil
  else
    local class_spell = spell_finder.FindGroupSpell(mezz_spell_group)
    if not class_spell then
      assist_state.mezz_mode = nil
    else
      assist_state.mezz_mode = mezz_mode
    end
  end

  if not assist_state.mezz_mode then
    broadcast.ErrorAll("%s is no longer doing crowd control", mq.TLO.Me.Name())
  else
    broadcast.SuccessAll("%s is now doing crowd control", mq.TLO.Me.Name())
  end
end

local function createCommand(mezzMode)
    commandQueue.Enqueue(function() execute(mezzMode) end)
end

mq.bind("/mezzmode", createCommand)

return execute
