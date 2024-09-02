local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local commandQueue  = require('application/command_queue')
local settings = require('settings/settings')
local assist_state = require('application/assist_state')
local binder = require('application/binder')

local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function execute(set_name)
  if not set_name or not settings.medleys[set_name] then
    logger.Warn("Medley set '%s' does not exist in settings.", set_name)
    broadcast.FailAll("Medley set %s does not exist in settings.", broadcast.ColorWrap(set_name, 'Yellow'))
    return
  end

  ---@type table<number, Song>
  local songgem = {}
  for _, song in ipairs(settings.medleys[set_name] or {}) do
    local currentGem = mq.TLO.Me.Gem(song.Name)()
    if currentGem then
      logger.Info("Mapped %s to gem %d", song.Name, currentGem)
      songgem[currentGem] = song
    elseif not songgem[song.DefaultGem] then
      songgem[song.DefaultGem] = song
    elseif not songgem[settings.gems.default] then
      songgem[settings.gems.default] = song
    else
      logger.Error("Failed to map song [%s] to gem %d", song.Name, song.DefaultGem)
    end
  end

  if tablelength(songgem) ~= tablelength(settings.medleys[set_name] or {}) then
    logger.Error("Unable to map medley [%s] to gems", set_name)
    broadcast.FailAll("Unable to map medley %s to gems", broadcast.ColorWrap(set_name, 'Orange'))
    return
  end

  for gem, song in pairs(songgem) do
    if mq.TLO.Me.Gem(gem)() ~= song.Name then
      local rankName = song.MQSpell.RankName.Name()
      logger.Info("Memorizing \ag%s\ax in gem %d", rankName, gem)
      mq.cmdf('/memspell %d "%s"', gem, rankName)
      mq.delay("10s", function() return mq.TLO.Me.Gem(rankName)() ~= nil end)
      mq.delay(500)
    end
  end

  mq.cmd("/makemevisible")
  logger.Info("Active medley set is now '%s'", set_name)
  broadcast.SuccessAll("Active medley set is now %s", broadcast.ColorWrap(set_name, 'Blue'))
  assist_state.medley = set_name
end

local function createCommand(set_name)
  if mq.TLO.Me.Class.ShortName() == "BRD" then
    commandQueue.Enqueue(function() execute(set_name) end)
  end
end

binder.Bind("/activemedley", createCommand, "Tells bard to set his active medley to 'name'", 'name')

return execute
