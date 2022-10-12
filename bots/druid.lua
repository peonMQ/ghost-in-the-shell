--- @type Mq
local mq = require('mq')
local doManaStone = require('lib/caster/manastone')
local doMeditate = require('lib/caster/meditate')
local doBuffs = require('modules/buffer/buffer')
local doHealing = require('modules/healer/healing')
local doNuking = require('modules/nuker/nuke')
local doSell = require('modules/looter/sell')
local wait4rez = require('wait4rez/wait4rez')

require('lib/common/cleanBuffs')

while true do
  doBuffs()
  doHealing()
  doNuking()
  doManaStone()
  doMeditate()
  doSell()
  wait4rez()
  mq.doevents()
  mq.delay(100)
end