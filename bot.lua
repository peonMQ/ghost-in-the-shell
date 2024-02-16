local mq = require 'mq'
local logger = require("knightlinc/Write")

logger.prefix = string.format("\at%s\ax", "[GITS]")
logger.postfix = function () return string.format(" %s", os.date("%X")) end

local broadcast = require 'broadcast/broadcast'
local plugins = require 'utils/plugins'
local debugutils = require 'utils/debug'
local doMeditate = require 'lib/caster/meditate'
local doManaConversion = require 'lib/caster/manaconversion'
local doBuffs = require 'modules/buffer/buffer'
local doDeBuffs = require 'modules/debuffer/debuffer'
local doMezz = require 'modules/debuffer/mezz'
local doHealing = require 'modules/healer/healing'
local doCuring = require 'modules/curer/curer'
local combatActions = require 'modules/melee/combatactions'
local doMeleeDps = require 'modules/melee/melee'
local doMedley = require 'modules/medley/medley'
local doNuking = require 'modules/nuker/nuke'
local doPet = require 'modules/pet/pet'
local commandQueue  = require("application/command_queue")
require("application/commands")

---@alias eqclass 'bard'|'cleric'|'druid'|'enchanter'|'magician'|'monk'|'necromancer'|'paladin'|'ranger'|'rogue'|'shadowknight'|'shaman'|'warrior'|'wizard'

---@type table<eqclass, fun()[]>
local classActions = {
  bard = {doBuffs, doMeleeDps, doMedley},
  cleric = {doBuffs, doHealing, doNuking, doMeleeDps, doMeditate, doCuring, doManaConversion},
  druid = {doBuffs, doDeBuffs, doHealing, doNuking, doMeleeDps, doMeditate, doManaConversion},
  enchanter = {doMezz, doBuffs, doDeBuffs, doMeleeDps, doNuking, doMeditate, doManaConversion},
  magician = {doBuffs, doDeBuffs, doPet, doNuking, doMeleeDps, doMeditate, doManaConversion},
  monk = {doBuffs, function() doMeleeDps(combatActions.DoPunchesAndKicks) end},
  necromancer = {doBuffs, doDeBuffs, doPet, doNuking, doMeleeDps, doMeditate, doManaConversion},
  paladin = {doBuffs, doHealing, doNuking, doMeleeDps, doMeditate},
  ranger = {doBuffs, doHealing, doNuking, doMeleeDps, doMeditate},
  rogue = {doBuffs, function() doMeleeDps(combatActions.DoBackStab) end},
  shadowknight = {doBuffs, doPet, doNuking, doMeleeDps, doMeditate},
  shaman = {doBuffs, doDeBuffs, doHealing, doPet, doNuking, doMeleeDps, doManaConversion, doMeditate, doCuring},
  warrior = {doBuffs, doMeleeDps},
  wizard = {doBuffs, doNuking, doMeleeDps, doManaConversion, doMeditate}
}

local function isFollowing()
  if plugins.IsLoaded("mq2nav") and mq.TLO.Navigation.Active() then
    return true
  end

  if plugins.IsLoaded("mq2advpath") and mq.TLO.AdvPath.Following() then
    return true
  end

  if plugins.IsLoaded("mqactoradvpath") and mq.TLO.ActorAdvPath.IsFollowing() then
    return true
  end

  if plugins.IsLoaded("mq2moveutils") and mq.TLO.Stick.Active() then
    local stickSpawn = mq.getFilteredSpawns(function(spawn) return spawn.ID() == mq.TLO.Stick.StickTarget() and  spawn.Type() =="PC" end)
    if next(stickSpawn) then
      return true
    end
  end

  return false
end

if mq.TLO.Me.GM() then
  logger.Error("Cannot run GM character as BOT...")
  return
end

broadcast.SuccessAll("Bot starting up <%s>...", mq.TLO.Me.CleanName())
local botActions = classActions[mq.TLO.Me.Class():lower()] or {}
if mq.TLO.Me.Class.ShortName() == "BRD" then
  mq.cmd('/if (!${BardSwap}) /bardswap')
end

while true do
  mq.doevents()
  commandQueue.Process()

  if not isFollowing() then
    for _,action in ipairs(botActions) do
      action()
    end
  elseif mq.TLO.Me.Class.ShortName() == "BRD" then
    doMedley()
  end

  mq.delay(1)
end