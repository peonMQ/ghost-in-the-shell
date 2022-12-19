--- @type Mq
local mq = require('mq')
local plugins = require('utils/plugins')

-- load EQBC if needed
plugins.EnsureIsLoaded("mq2eqbc")
mq.delay('1s', function() return plugins.IsLoaded("mq2eqbc") end)
if (plugins.IsLoaded("mq2eqbc") == false) then
  print("[SETUP] MQ2EQBC.dll has failed to load, ending script!")
  mq.exit()
end

-- enabling EQBC Autoconnect
print("[SETUP] enabling EQBC AutoConnect")
mq.cmd("/bccmd set autoconnect on")

-- connecting to EQBC server
if (mq.TLO.EQBC.Connected() == false) then
  print("[SETUP] Connecting to EQBC Server...")
  mq.cmd("/bccmd connect 127.0.0.1 2112")
end

mq.delay('5s', function() return mq.TLO.EQBC.Connected() or false end)
if (mq.TLO.EQBC.Connected() == false) then
  print("[SETUP] MQ2EQBC Was unable to connect, ending script!")
  mq.exit()
end

-- load Netbots if needed
plugins.EnsureIsLoaded("mq2netbots")
mq.delay('1s', function() return plugins.IsLoaded("mq2netbots") end)
if (plugins.IsLoaded("mq2netbots") == false) then
  print("[SETUP] MQ2Netbots.dll has failed to load, ending script!")
  mq.exit()
end

-- turn grab/send on
print("[SETUP] Enabling netbots reporting...")
mq.cmd("/netbots grab on")
mq.cmd("/netbots send on")
mq.cmd("/netbots extend on")

print("[SETUP] All done!")