local mq = require("mq")
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local plugins = require 'utils/plugins'
local commandQueue  = require("application/command_queue")
local sellItems = require 'modules/looter/sell'

local function execute()
  local isBardSwapping = plugins.IsLoaded("MQ2BardSwap") and mq.TLO.BardSwap()
  if isBardSwapping then
    mq.cmd("/bardswap")
  end

  sellItems()

  if isBardSwapping then
    mq.cmd("/bardswap")
  end

  logger.Info("Sell items command completed.")
  broadcast.SuccessAll("Sell items command completed.")
end

local function createCommand()
  commandQueue.Enqueue(function() execute() end)
end

mq.bind("/sellitems", createCommand)
