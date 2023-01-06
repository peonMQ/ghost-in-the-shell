--- @type Mq
local mq = require('mq')
local plugins = require('utils/plugins')
local logger = require('utils/logging')
local luapaths = require('utils/lua-paths')

mq.cmdf("/lua run hud")
mq.cmdf("/lua run actionbar")