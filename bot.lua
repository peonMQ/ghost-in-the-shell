--- @type Mq
local mq = require('mq')
local plugins = require('utils/plugins')
local logger = require('utils/logging')
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
local doWeaponize = require('modules/pet/weaponize')
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
  enchanter = {doMezz, doBuffs, doDeBuffs, doMeleeDps, doNuking, doManaStone, doMeditate},
  magician = {doBuffs, doDeBuffs, doPet, doWeaponize, doNuking, doMeleeDps, doManaStone, doMeditate},
  monk = {function() doMeleeDps(combatActions.DoPunchesAndKicks) end},
  necromancer = {doBuffs, doPet, doWeaponize, doNuking, doMeleeDps, doManaStone, doMeditate},
  paladin = {doBuffs, doHealing, doNuking, doMeleeDps, doMeditate},
  ranger = {},
  rogue = {function() doMeleeDps(combatActions.DoBackStab) end},
  shadowknight = {doBuffs, doPet, doNuking, doManaStone, doMeditate},
  shaman = {doBuffs, doDeBuffs, doHealing, doPet, doWeaponize, doNuking, doMeleeDps, doManaStone, doMeditate},
  warrior = {doMeleeDps},
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

local function toggleFollow(targetId)
  if not plugins.IsLoaded("mq2advpath") then
    return
  end

  if mq.TLO.AdvPath.Following() then
    mq.cmd("/afollow off")
    return
  end

  if plugins.IsLoaded("mq2nav") and mq.TLO.Navigation.Active() then
    mq.cmd("/nav stop")
  end

  if not targetId then
    logger.Warn("Missing <targetId> to follow.")
    return
  end

  local stickSpawn = mq.getFilteredSpawns(function(spawn)  return spawn.ID() == tonumber(targetId) and spawn.Type() == "PC" end)
  if stickSpawn[1] then
    mq.cmdf("/afollow spawn %d", stickSpawn[1].ID())
  end
end

local function toggleNavTo(targetId)
  if not plugins.IsLoaded("mq2nav") then
    return
  end

  if mq.TLO.Navigation.Active() then
    mq.cmd("/nav stop")
    return
  end

  if plugins.IsLoaded("mq2advpath") and mq.TLO.AdvPath.Following() then
    mq.cmd("/afollow off")
  end

  if not targetId then
    logger.Warn("Missing <targetId> to navigate to.")
    return
  end

  local stickSpawn = mq.getFilteredSpawns(function(spawn) return spawn.ID() == tonumber(targetId) and spawn.Type() == "PC" end)
  if stickSpawn[1] and not mq.TLO.Navigation.PathExists("id "..stickSpawn[1].ID()) then
    mq.cmdf("/nav id %d", stickSpawn[1].ID())
  end
end

local function createAliases()
  mq.unbind('/stalk')
  mq.unbind('/navto')
  mq.bind("/stalk", toggleFollow)
  mq.bind("/navto", toggleNavTo)
end

createAliases()

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