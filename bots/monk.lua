--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
local wait4rez = require('wait4rez/wait4rez')
local doSell = require('modules/looter/sell')
local doMeleeDps = require('modules/melee/melee')

require('lib/common/cleanBuffs')

local function doPunchesAndKicks()
  local me = mq.TLO.Me

  if me.AbilityReady("Tiger Claw")() then
    mq.cmd('/doability "Tiger Claw"')
  end

  if me.AbilityReady("Flying Kick")() then
    mq.cmd('/doability "Flying Kick"')
  end
end

while true do
  doSell()
  doMeleeDps(doPunchesAndKicks)
  wait4rez()
  mq.doevents()
  mq.delay(100)
end