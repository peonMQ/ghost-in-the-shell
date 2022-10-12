--- @type Mq
local mq = require('mq')
local plugins = require('utils/plugins')
local logger = require('utils/logging')

plugins.EnsureIsLoaded("mq2eqbc")
plugins.EnsureIsLoaded("mq2netbots")

if (mq.TLO.EQBC.Connected() == false) then
  logger.Fatal("Not connected to EQBC.")
end

local function startBots()
  logger.Info("Start up bots.")
  local me = mq.TLO.Me
  for i=1,mq.TLO.NetBots.Counts() do
    local name = mq.TLO.NetBots.Client(i)()
    if name ~= me.Name() then
      local netbot = mq.TLO.NetBots(name)
      logger.Info("Starting up %s >> %s", name, netbot.Class.Name())
      mq.cmdf('/bct %s //lua run "bots/%s"', name, netbot.Class.Name())
    end
  end
  logger.Info("Bots ready.")
end

startBots()

mq.cmd("/lua run hud")