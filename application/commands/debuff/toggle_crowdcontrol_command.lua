local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local spell_finder = require('application/casting/spell_finder')
local spells_mesmerize = require('data/spells_mesmerize')
local assist_state = require('application/assist_state')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')

---comment
---@param crowdControlMode CrowdControlMode|nil
local function execute(crowdControlMode)
  if not crowdControlMode then
    assist_state.crowd_control_mode = nil
  end

  if mq.TLO.Me.Class.ShortName() ~= "ENC" then
    return
  end

  local class_spell
  local mezz_spell_group = spells_mesmerize[mq.TLO.Me.Class.ShortName()] and spells_mesmerize[mq.TLO.Me.Class.ShortName()][crowdControlMode]
  if not mezz_spell_group then
    logger.Info("%s has no crowd controll spell.", mq.TLO.Me.Class.ShortName())
    assist_state.crowd_control_mode = nil
  else
    class_spell = spell_finder.FindGroupSpell(mezz_spell_group)
    if not class_spell then
      assist_state.crowd_control_mode = nil
    else
      assist_state.crowd_control_mode = crowdControlMode
    end
  end

  if not assist_state.crowd_control_mode then
    broadcast.WarnAll("%s is no longer doing crowd control", broadcast.ColorWrap(mq.TLO.Me.Name(), 'Maroon'))
  elseif class_spell then
    broadcast.SuccessAll("%s is now doing crowd control: %s - %s", mq.TLO.Me.Name(), crowdControlMode, class_spell.Name)
  end
end

local function createCommand(crowdControlMode)
    commandQueue.Enqueue(function() execute(crowdControlMode) end)
end

binder.Bind("/crowdcontrol", createCommand, "Sets automatic crowd control mode (mezz) for enchanters", 'single_mez|ae_mez|unresistable_mez|nil')

return execute
