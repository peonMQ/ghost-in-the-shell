local mq = require 'mq'
local plugins = require 'utils/plugins'
local logger = require("knightlinc/Write")

logger.prefix = string.format("\at%s\ax", "[GITS]")
logger.postfix = function () return string.format(" %s", os.date("%X")) end

local luapaths = require 'utils/lua-paths'

---@type RunningDir
local runningDir = luapaths.RunningDir:new()
runningDir:AppendToPackagePath()

local command = string.format('/lua run %s', runningDir:GetRelativeToMQLuaPath("/actionbar"))
mq.cmdf(command)