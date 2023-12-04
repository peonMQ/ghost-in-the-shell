local mq = require("mq")
local logger = require("knightlinc/Write")
local plugins = require 'utils/plugins'
local mqUtils = require 'utils/mqhelpers'
local moveUtils = require 'lib/moveutils'
local commandQueue  = require("application/command_queue")

local function execute(targetId)
  if mqUtils.EnsureTarget(targetId) then
    mq.cmd('/cast  "Wake of Tranquility"')
  end
end

local function createCommand(targetId)
    commandQueue.Enqueue(function() execute(targetId) end)
end

mq.bind("/pacify", createCommand)
