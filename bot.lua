local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local plugins = require('utils/plugins')
local debugutils = require('utils/debug')
local movement = require('core/movement')
local manaregen = require('application/casting/mana_regen')
local doBuffs = require('application/buffer')
local doDeBuffs = require('application/debuffing/debuffer')
local doMezz = require('application/debuffing/mezz')
local doHealing = require('application/healing')
local doCuring = require('application/curer')
local melee = require('core/melee_abilities')
local doMeleeDps = require('application/meleeing/melee')
local doMedley = require('application/medley/medley')
local doNuking = require('application/nuke')
local doPet = require('application/pet')
local assistTick = require('application/assist')
local app_state = require('app_state')
local commandQueue  = require('application/command_queue')
local follow_state  = require('application/follow_state')
local camp  = require('application/camp')
require('application/commands')

---@alias eqclass 'bard'|'cleric'|'druid'|'enchanter'|'magician'|'monk'|'necromancer'|'paladin'|'ranger'|'rogue'|'shadow knight'|'shaman'|'warrior'|'wizard'
---@alias boolFunc fun(): boolean
---@type table<eqclass, boolFunc[]>
local classActions = {
  bard = {doBuffs, doMeleeDps, doMedley.OnTick},
  cleric = {doHealing, doCuring, doBuffs, doNuking, doMeleeDps, manaregen.DoMeditate, manaregen.DoManaConversion},
  druid = {doHealing, doBuffs, doDeBuffs, doNuking, doMeleeDps, manaregen.DoMeditate, manaregen.DoManaConversion},
  enchanter = {doMezz, doBuffs, doDeBuffs, doMeleeDps, doNuking, manaregen.DoMeditate, manaregen.DoManaConversion},
  magician = {doBuffs, doDeBuffs, doPet, doNuking, doMeleeDps, manaregen.DoMeditate, manaregen.DoManaConversion},
  monk = {doBuffs, function() return doMeleeDps(melee.DoPunchesAndKicks) end},
  necromancer = {doBuffs, doDeBuffs, doPet, doNuking, doMeleeDps, manaregen.DoMeditate, manaregen.DoManaConversion},
  paladin = {doBuffs, doHealing, doNuking, doMeleeDps, manaregen.DoMeditate},
  ranger = {doBuffs, doHealing, doNuking, doMeleeDps, manaregen.DoMeditate},
  rogue = {doBuffs, function() return doMeleeDps(melee.DoBackStab) end},
  ["shadow knight"] = {doBuffs, doPet, doNuking, doMeleeDps, manaregen.DoMeditate},
  shaman = {doHealing, doCuring, doBuffs, doDeBuffs, doPet, doNuking, doMeleeDps, manaregen.DoManaConversion, manaregen.DoMeditate},
  warrior = {doBuffs, doMeleeDps},
  wizard = {doBuffs, doNuking, doMeleeDps, manaregen.DoManaConversion, manaregen.DoMeditate}
}

broadcast.SuccessAll("Bot starting up %s", broadcast.ColorWrap(mq.TLO.Me.CleanName(), 'Maroon'))
local currentClass = mq.TLO.Me.Class
local botActions = classActions[currentClass():lower()] or {}
if currentClass.ShortName() == "BRD" then
  plugins.EnsureIsLoaded("mq2bardswap")
  mq.cmd('/if (!${BardSwap}) /bardswap')
  mq.cmd('/if (!${BardSwap.MeleeSwap}) /bardswap melee')
  mq.cmd('/stopsong')
end

local function process()
  mq.doevents()
  if not app_state.IsPaused() then
    return
  end

  commandQueue.Process()
  if app_state.PerformActions() and not movement.IsFollowing() then
    for _, action in ipairs(botActions) do
      assistTick()
      if action() then
        break
      end
    end

    camp.Process()
  elseif movement.IsFollowing() and currentClass.ShortName() == "BRD" then
    doMedley.OnTick()
  end
end

return {
  Process = process
}