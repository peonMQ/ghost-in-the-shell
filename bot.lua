--- @type Mq
local mq = require('mq')
local plugins = require('utils/plugins')
local doManaStone = require('lib/caster/manastone')
local doMeditate = require('lib/caster/meditate')
local doManaConversion = require('lib/caster/manaconversion')
local doBuffs = require('modules/buffer/buffer')
local doDeBuffs = require('modules/debuffer/debuffer')
local doMezz = require('modules/debuffer/mezz')
local doHealing = require('modules/healer/healing')
local combatActions = require('modules/melee/combatactions')
local doMeleeDps = require('modules/melee/melee')
local doNuking = require('modules/nuker/nuke')
local doPet = require('modules/pet/pet')
local doLoot = require('modules/looter/loot')
local doSell = require('modules/looter/sell')
local wait4rez = require('wait4rez/wait4rez')

require('lib/common/cleanBuffs')

---@alias eqclass 'bard'|'cleric'|'druid'|'enchanter'|'magician'|'monk'|'necromancer'|'paladin'|'ranger'|'rogue'|'shadowknight'|'shaman'|'warrior'|'wizard'

---@type table<eqclass, fun()[]>
local classActions = {
  bard = {doBuffs, doMeleeDps},
  cleric = {doBuffs, doHealing, doNuking, doMeleeDps, doManaStone, doMeditate},
  druid = {doBuffs, doHealing, doNuking, doMeleeDps, doManaStone, doMeditate},
  enchanter = {doMezz, doBuffs, doHealing, doMeleeDps, doNuking, doManaStone, doMeditate},
  magician = {doBuffs, doDeBuffs, doNuking, doMeleeDps, doManaStone, doMeditate},
  monk = {function() doMeleeDps(combatActions.DoPunchesAndKicks) end},
  necromancer = {doBuffs, doPet, doNuking, doMeleeDps, doManaStone, doMeditate},
  paladin = {doBuffs, doHealing, doNuking, doMeleeDps, doMeditate},
  ranger = {doBuffs, doHealing, doNuking, doMeleeDps, doMeditate},
  rogue = {function() doMeleeDps(combatActions.DoBackStab) end},
  shadowknight = {doBuffs, doPet, doNuking, doManaStone, doMeditate},
  shaman = {doBuffs, doHealing, doPet, doNuking, doMeleeDps, doManaStone, doMeditate},
  warrior = {doMeleeDps},
  wizard = {doBuffs, doNuking, doMeleeDps, doManaStone, doManaConversion}
}

local function isFollowing()
  if plugins.IsLoaded("mq2nav") and mq.TLO.Navigation.Active() then
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

local botActions = classActions[mq.TLO.Me.Class():lower()] or {}

while true do
  if not isFollowing() then
    for _,action in ipairs(botActions) do
      action()
    end

    doLoot()
    doSell()
  end

  wait4rez()
  mq.doevents()
  mq.delay(50)
end