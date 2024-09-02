--- @type Mq
local mq = require('mq')
local logger = require('knightlinc/Write')
local mqUtils = require('utils/mqhelpers')
local assist = require('core/assist')
local assist_state = require('application/assist_state')
local doMeleeDps = require('application/meleeing/melee')

local function canTargetOfftankAdd()
  local mainAssist = assist.GetMainAssist()
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
  if not assist.AmIOfftank() then
    return
  end

  if canTargetOfftankAdd() then
    doMeleeDps()
  end
end

return {
  OfftankNearest = offtankNearest
}