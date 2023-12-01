local mq = require 'mq'
local plugins = require 'utils/plugins'
local logger = require("knightlinc/Write")

logger.prefix = string.format("\at%s\ax", "[GITS]")
logger.postfix = function () return string.format(" %s", os.date("%X")) end

local luapaths = require 'utils/lua-paths'
local filetutils = require 'utils/file'
local broadCastInterfaceFactory = require('broadcast/broadcastinterface')

---@type RunningDir
local runningDir = luapaths.RunningDir:new()
runningDir:AppendToPackagePath()


local hudPidsExists = filetutils.Exists(mq.luaDir.."\\hud\\pids.lua")
if hudPidsExists then
  local bci = broadCastInterfaceFactory()
  bci.ExecuteAllWithSelfCommand('/lua run hud/pids')

  mq.cmd("/lua run hud")
else
  logger.Error("HUD not installed.")
end

local command = string.format('/lua run %s', runningDir:GetRelativeToMQLuaPath("/actionbar"))
mq.cmdf(command)