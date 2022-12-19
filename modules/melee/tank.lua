--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local mqUtils = require('utils/mqhelpers')
local common = require('lib/common/common')
local doMeleeDps = require('modules/melee/melee')

local function canTargetOfftankAdd() 
  local mainAssist = common.GetMainAssist()
  if not mainAssist then
    return false
  end

  local netbot = mq.TLO.NetBots(mainAssist)
  if not netbot.TargetID() then
    return false
  end

  local maTargetId = mq.TLO.NetBots(mainAssist).TargetID()
  local spawnQuery = string.format("npc los targetable radius %d notid %s", 100, maTargetId)
  local otTargetCount = mq.TLO.SpawnCount(spawnQuery)()

  if not otTargetCount then
    return false
  end

  local otTargetId = mq.TLO.NearestSpawn(1, spawnQuery).ID()
  if mq.TLO.Target.ID() == otTargetId then
    return false
  end

  return mqUtils.EnsureTarget(otTargetId)
end

local function offtankNearest() 
  if not common.AmIOfftank() then
    return
  end

  if canTargetOfftankAdd() then
    doMeleeDps()
  end
end