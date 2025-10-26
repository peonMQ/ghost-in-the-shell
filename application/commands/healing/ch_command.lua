local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local plugin = require('utils/plugins')
local mqUtils = require('utils/mqhelpers')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')
local state = require('application/casting/casting_state')
local spell_finder = require('application/casting/spell_finder')
local assist = require('core/assist')
local healSpell = require('core/casting/heals/healspell')
local castReturnTypes = require('core/casting/castreturn')
local numberUtils = require('core/numbers')
local timer = require('core/timer')
local settings = require('settings/settings')

---@param spellId number
local function checkInterrupt(spellId)
  local target = mq.TLO.Target
  if not target() then
    state.interrupt(spellId)
    return
  end

  if target.Type() == "Corpse" then
    state.interrupt(spellId)
    return
  end

  local spell = mq.TLO.Spell(spellId)
  if numberUtils.IsLargerThan(target.Distance(), spell.Range()) then
    state.interrupt(spellId)
    return
  end

  -- if mq.TLO.Me.CastTimeLeft() < 500 and target() and target.PctHPs() > 98 then
  --   state.interrupt(spellId)
  -- end
end

local completeHeal
if mq.TLO.Me.Class.Name() == "Cleric" then
  local spell = spell_finder.FindGroupSpell("clr_complete_heal")
  if spell then
    completeHeal = healSpell:new(spell.Name(), settings:GetDefaultGem("clr_complete_heal"), 0, 100, 100, spell.Range())
  end
end

---@param commandRecievedTime number
local function execute(commandRecievedTime)
  logger.Warn("Starting CH %s", mq.gettime() - commandRecievedTime)
  local mainTank = assist.GetMainTank()
  if not mainTank then
    return
  end

  if mqUtils.EnsureTarget(mq.TLO.NetBots(mainTank).ID())  then
    local timeSinceRecieved = mq.gettime() - commandRecievedTime
    logger.Debug("Complete healing maintank <%s>[%d] - %s", mq.TLO.Target.Name(), mq.TLO.Target.PctHPs() or -100, timeSinceRecieved/1000)
    local totalCastTime = mq.gettime()
    completeHeal:Cast(checkInterrupt)
    if state.castReturn == castReturnTypes.Success then
      broadcast.SuccessAll("Complete healing complete - %s", (mq.gettime() - totalCastTime)/1000)
    else
      broadcast.WarnAll("Complete healing incomplete - %s <%s>", (mq.gettime() - totalCastTime)/1000, state.castReturn)
    end
  end
end

local function createCommand()
  if mq.TLO.Me.Class.Name() == "Cleric" then
    commandQueue.Enqueue(function() execute(mq.gettime()) end)
  else
    broadcast.Error("I recieved a command to cast complete heal on MT but I am not a cleric.")
  end
end

binder.Bind("/ch", createCommand, "Toggles this bot to run cast a complete heal on MT")

return execute
