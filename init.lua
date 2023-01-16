--- @type Mq
local mq = require('mq')
local plugins = require('utils/plugins')
local logger = require('utils/logging')
local luapaths = require('utils/lua-paths')


---@type RunningDir
local runningDir = luapaths.RunningDir:new()
runningDir:AppendToPackagePath()

mq.cmd("/lua run hud")

local command = string.format('/lua run %s', runningDir:GetRelativeToMQLuaPath("actionbar"))
mq.cmdf(command)