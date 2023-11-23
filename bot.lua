--- @type Mq
local mq = require 'mq'
local plugins = require 'utils/plugins'
local logger = require 'utils/logging'
local debugutils = require 'utils/debug'
local doManaStone = require 'lib/caster/manastone'
local doMeditate = require 'lib/caster/meditate'
local doManaConversion = require 'lib/caster/manaconversion'
local doBuffs = require 'modules/buffer/buffer'
local doDeBuffs = require 'modules/debuffer/debuffer'
local doMezz = require 'modules/debuffer/mezz'
local doHealing = require 'modules/healer/healing'
local doCuring = require 'modules/curer/curer'
local combatActions = require 'modules/melee/combatactions'
local doMeleeDps = require 'modules/melee/melee'
local doNuking = require 'modules/nuker/nuke'
local doPet = require 'modules/pet/pet'
local commandQueue  = require("application/command_queue")
require("application/commands")

---@alias eqclass 'bard'|'cleric'|'druid'|'enchanter'|'magician'|'monk'|'necromancer'|'paladin'|'ranger'|'rogue'|'shadowknight'|'shaman'|'warrior'|'wizard'

---@type table<eqclass, fun()[]>
local classActions = {
  bard = {doBuffs, doMeleeDps},
  cleric = {doBuffs, doHealing, doNuking, doMeleeDps, doManaStone, doMeditate, doCuring},
  druid = {doBuffs, doDeBuffs, doHealing, doNuking, doMeleeDps, doManaStone, doMeditate},
  enchanter = {doMezz, doBuffs, doDeBuffs, doMeleeDps, doNuking, doManaStone, doMeditate},
  magician = {doBuffs, doDeBuffs, doPet, doNuking, doMeleeDps, doManaStone, doMeditate},
  monk = {doBuffs, function() doMeleeDps(combatActions.DoPunchesAndKicks) end},
  necromancer = {doBuffs, doDeBuffs, doPet, doNuking, doMeleeDps, doManaStone, doMeditate},
  paladin = {doBuffs, doHealing, doNuking, doMeleeDps, doMeditate},
  ranger = {doBuffs, doHealing, doNuking, doMeleeDps, doMeditate},
  rogue = {doBuffs, function() doMeleeDps(combatActions.DoBackStab) end},
  shadowknight = {doBuffs, doPet, doNuking, doMeleeDps, doMeditate},
  shaman = {doBuffs, doDeBuffs, doHealing, doPet, doNuking, doMeleeDps, doManaStone, doManaConversion, doMeditate, doCuring},
  warrior = {doBuffs, doMeleeDps},
  wizard = {doBuffs, doNuking, doMeleeDps, doManaStone, doManaConversion, doMeditate}
}

local function isFollowing()
  if plugins.IsLoaded("mq2nav") and mq.TLO.Navigation.Active() then
    return true
  end

  if plugins.IsLoaded("mq2advpath") and mq.TLO.AdvPath.Following() then
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

local botActions = classActions[mq.TLO.Me.Class():lower()] or {}

while true do
  if not isFollowing() then
    for _,action in ipairs(botActions) do
      action()
    end
  end

  mq.doevents()
  commandQueue.Process()
  mq.delay(50)
end