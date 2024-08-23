local mq = require 'mq'
local packageMan = require('mq/PackageMan')
local logger = require("knightlinc/Write")
local lfs = packageMan.Require('luafilesystem', 'lfs')
local runningDir = require('utils/lua-paths').RunningDir
local appPath = mq.luaDir..'/'..runningDir:Parent():RelativeToMQLuaPath()
local commandQueue  = require("application/command_queue")

require("application/commands/buff/commands")
require("application/commands/debuff/commands")
require("application/commands/loot/commands")
require("application/commands/medley/commands")
require("application/commands/movement/commands")
require("application/commands/nuke/commands")
require("application/commands/pet/commands")
require("application/commands/settings/commands")
require("application/commands/wait4rez/commands")

require("application/commands/memorize_command")
require("application/commands/quit_command")

local function loadPlugins(directory)
  logger.Debug("Loading from: %s", directory)
  for file in lfs.dir(appPath..'/'..directory) do
    if file ~= "." and file ~= ".." then
      local fileAttributes = lfs.attributes(appPath..'/'..directory.."/"..file,"mode")
      logger.Debug("Found %s with mode %s", file, fileAttributes)
      if fileAttributes == "file" then
        local filename, extension = file:match("^(.+)%.(.+)$")
        logger.Info("Loading plugin: %s", directory.."/"..file)
        local command = require(directory.."/"..filename)
        command(commandQueue)
      elseif fileAttributes == "directory" then
        loadPlugins(directory.."/"..file)
      end
    end
  end
end

logger.Info("Loading plugins from: %s", appPath.."/plugins")

loadPlugins("plugins")