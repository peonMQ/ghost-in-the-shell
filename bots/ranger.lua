--- @type Mq
local mq = require('mq')
local doBuffs = require('modules/buffer/buffer')
local doNuking = require('modules/nuker/nuke')
local doSell = require('modules/looter/sell')
local wait4rez = require('wait4rez/wait4rez')

require('lib/common/cleanBuffs')

while true do
  doSell()
  doBuffs()
  doNuking()
  wait4rez()
  mq.doevents()
  mq.delay(100)
end