local mq = require("mq")
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local commandQueue  = require("application/command_queue")
local settings = require 'settings/settings'
local assist_state = require 'application/assist_state'

local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function execute(set_name)
  if not set_name or not settings.medleys[set_name] then
    logger.Warning("Medley set '%s' does not exist in settings.", set_name)
    broadcast.FailAll("Medley set '%s' does not exist in settings.", set_name)
    return
  end

  ---@type table<number, Song>
  local songgem = {}
  for _, song in ipairs(settings.medleys[assist_state.medley] or {}) do
    local currentGem = mq.TLO.Me.Gem(song.Name)()
    if currentGem then
      songgem[currentGem] = song
    elseif not songgem[song.DefaultGem] and not mq.TLO.Me.Gem(song.DefaultGem)() then
      songgem[song.DefaultGem] = song
    elseif not songgem[settings.gems.default] and not mq.TLO.Me.Gem(settings.gems.default)() then
      songgem[settings.gems.default] = song
    end
  end

  if tablelength(songgem) ~= tablelength(settings.medleys[assist_state.medley] or {}) then
    logger.Error("Unable to map medley [%s] to gems", assist_state.medley)
    broadcast.FailAll("Unable to map medley [%s] to gems", assist_state.medley)
    return
  end

  for gem, song in pairs(songgem) do
    if mq.TLO.Me.Gem(gem)() ~= song.Name then
      local rankName = song.MQSpell.RankName.Name()
      logger.Info("Memorizing \ag%s\ax in gem %d", rankName, gem)
      mq.cmdf('/memspell  %d "%s"', gem, rankName)
      mq.delay("10s", function() return mq.TLO.Me.Gem(rankName)() ~= nil end)
      mq.delay(500)
    end
  end

  mq.cmd('/stopsong')
  mq.cmd("/makemevisible")
  logger.Info("Active medley set is now '%s'", set_name)
  broadcast.SuccessAll("Active medley set is now '%s'", set_name)
  assist_state.medley = set_name
end

local function createCommand(set_name)
  if mq.TLO.Me.Class.ShortName() == "BRD" then
    commandQueue.Enqueue(function() execute(set_name) end)
  end
end

mq.bind("/activemedley", createCommand)

return execute
