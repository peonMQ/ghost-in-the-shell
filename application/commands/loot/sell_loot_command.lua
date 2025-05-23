local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local plugins = require('utils/plugins')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')
local sellItems = require('application/looting/sell')

local function execute()
  local isBardSwapping = plugins.IsLoaded("MQ2BardSwap") and mq.TLO.BardSwap.Swapping()
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

binder.Bind("/sellitems", createCommand, "Sends toon to nearest merchant within a given radius to sell items marked as 'sellable'")
