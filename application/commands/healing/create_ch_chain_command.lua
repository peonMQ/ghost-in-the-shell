local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local bci = require('broadcast/broadcastinterface')('ACTOR')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')

local chChainActive = false
local chChain = {}
local nextIndex = 1
local ch_delay = 12*1000
local lastCH = mq.gettime()


local function createPostCommand()
  return coroutine.create(function ()
    while chChainActive do
      local timeSinceLastCommand = mq.gettime() - lastCH
      if timeSinceLastCommand > ch_delay then
        lastCH = mq.gettime()
        logger.Debug("Telling %s to cast complete heal at %s", chChain[nextIndex], timeSinceLastCommand/1000)
        bci.ExecuteCommand("/ch", { chChain[nextIndex] })
        if nextIndex == #chChain then
          nextIndex = 1
        else
          nextIndex = nextIndex + 1
        end
      end

      coroutine.yield()
    end
  end)
end

local function createChChain()
  local bots = bci.ConnectedClients()
  for _, bot in ipairs(bots) do
    bot = bot:gsub("^%l", string.upper)
    local netbot = mq.TLO.NetBots(bot)
    if netbot.Class.Name() == "Cleric" and netbot.Zone() == mq.TLO.Zone.ID() then
      table.insert(chChain, bot)
    end
  end

  ch_delay = 12*1000 / #chChain
  logger.Warn("Starting CH chain with %s clerics and a delay of %s", #chChain, ch_delay)
  chChainActive = true
end

local function disableChChain()
  chChainActive = false
  chChain = {}
end

local function createCommand()
  if chChainActive then
    disableChChain()
  else
    commandQueue.Enqueue(function() createChChain(); return createPostCommand() end)
  end
end

binder.Bind("/chchain", createCommand, "Toggles this bot to run a CH chain")

return createChChain
