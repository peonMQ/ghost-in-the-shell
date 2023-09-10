--- @type Mq
local mq = require 'mq'
local plugins = require 'utils/plugins'
local logger = require 'utils/logging'
local luapaths = require 'utils/lua-paths'
local broadCastInterfaceFactory = require('broadcast/broadcastinterface')

---@type RunningDir
local runningDir = luapaths.RunningDir:new()
runningDir:AppendToPackagePath()

local bci = broadCastInterfaceFactory()
if not bci then
  logger.Fatal("No networking interface found, please start eqbc or dannet")
  return
end

bci.ExecuteAllCommand('/lua run hud/pids')

mq.cmd("/lua run hud")

local command = string.format('/lua run %s', runningDir:GetRelativeToMQLuaPath("/actionbar"))
mq.cmdf(command)