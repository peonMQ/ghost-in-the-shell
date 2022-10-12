--- @type Mq
local mq = require('mq')
local plugin = require('utils/plugins')
local wait4rez = require('wait4rez/wait4rez')
local doBuffs = require('modules/buffer/buffer')

require('lib/common/cleanBuffs')

if plugin.IsLoaded("mq2bardswap") then
  mq.cmd("/bardswap")
end

while true do
  doBuffs()
  wait4rez()
  mq.doevents()
  mq.delay(100)
end