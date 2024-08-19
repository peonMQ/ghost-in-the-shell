local mq = require 'mq'
local logger = require("knightlinc/Write")
local common = require 'lib/common/common'
local mqEvents = require 'lib/mqevent'
local timer = require 'lib/timer'
local settings = require 'settings/settings'
local assist_state = require 'application/assist_state'
local commandQueue  = require("application/command_queue")

local next = next

---@enum MedleyStates
local MedleyStates = {
  IDLE = 0,
  CASTING = 1,
  PAUSED = 2
}

local wasInterrupted = false
local castCompleteDue = timer:new(0)
local medleyState = MedleyStates.IDLE
---@type Song|nil
local currentSong

local function interruptedEvent()
  wasInterrupted = true
  castCompleteDue:Reset()
  medleyState = MedleyStates.IDLE
end

local function missedNote()
  wasInterrupted = true
  castCompleteDue:Reset()
  medleyState = MedleyStates.IDLE
end

local function recoverEvent()
  wasInterrupted = true
  castCompleteDue:Reset()
  medleyState = MedleyStates.IDLE
end

local function stunnedEvent()
  wasInterrupted = true
  medleyState = MedleyStates.IDLE
  castCompleteDue:Reset(10)
end


local events = {
  mqEvents:new("brd_interruptCasting", "Your casting has been interrupted#*#", interruptedEvent),
  mqEvents:new("brd_interruptSpell", "Your spell is interrupted#*#", interruptedEvent),
  mqEvents:new("brd_missednote", "You miss a note, bringing your#*#to a close!", missedNote),
  mqEvents:new("brd_recoverYou", "You haven't recovered yet...#*#", recoverEvent),
  mqEvents:new("brd_stunned", "You are stunned#*#", stunnedEvent),
  mqEvents:new("brd_stunnedCast", "You can't cast spells while stunned!#*#", stunnedEvent),
}

for _, value in ipairs(events) do
  value:Register()
end

---@type table<number, table<string, number>>
local song_mob_expires = {}

---@type table<string, number>
local song_expires = {}

local function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

---@return boolean, string?
local function canPlayMelody()
  local me = mq.TLO.Me
  if me.Stunned() then
    return false, "Stunned"
  elseif me.Silenced() then
    return false, "Silenced"
  elseif me.Invulnerable() then
    return false, "Error"
  -- elseif mq.TLO.Window("CastingWindow").Open() then
  --   return false;
  elseif me.Casting() then
  -- elseif me.CastTimeLeft() > 0 and me.CastTimeLeft() < 100000 then -- Attempt to check if we are currently casting a spell (active spell cast bar)
    return false, "Casting"
  end

  local stand_state = me.StandState()
  if stand_state == "SIT" then
    return false, "Sitting"
  elseif stand_state == "FEIGN" then
    mq.cmd("/stand")
    return false, "Feigned"
  elseif stand_state == "DEAD" then
    mq.cmd("/stand")
    return false, "Dead"
  end

  return true
end


---@param song Song
---@return number When song expires from buff window
local function setSongExpires(song)
  local expires = mq.gettime() + song.Duration
  if song.Duration == 0 then
    expires = mq.gettime() + (tablelength(settings.medleys[assist_state.medley])-1)*6*1000
  end

  if song.IsDot then
    if mq.TLO.Target()() then
      song_mob_expires[mq.TLO.Target.ID()][song.Name] = expires
    end
  else
    song_expires[song.Name] = expires
  end

  return expires
end

---@param song Song
---@return number
local function getExpires(song)
  if song.IsDot then
    if mq.TLO.Target()() then
      if song_mob_expires[mq.TLO.Target.ID()] then
        return song_mob_expires[mq.TLO.Target.ID()][song.Name] or 0
      end
    end

    return 0
  end

  return song_expires[song.Name] or 0
end

---@return Song|nil
local function scheduleNextSong()
  local stalest_song = nil
  for _, song in ipairs(settings.medleys[assist_state.medley] or {}) do
    if song:IsGemReady() then
      if not stalest_song then
        stalest_song = song
      end

      if getExpires(song) < getExpires(stalest_song) then
        stalest_song = song;
      end
    end
  end

  if not stalest_song then
    logger.Info("No medley/songs found for [%s]", assist_state.medley)
    return
  end

  return stalest_song
end

local SPA_INVISIBILITY = 12
local function currentSongHasInvisEffect()
  return currentSong and currentSong.MQSpell.HasSPA(SPA_INVISIBILITY)()
end

local function createPostCommand()
  return coroutine.create(function ()
    for _, value in ipairs(events) do
      value:DoEvent()
    end

    while mq.TLO.Me.Casting() and (castCompleteDue:IsRunning() or currentSongHasInvisEffect()) and not wasInterrupted do
      coroutine.yield()
    end

    if currentSong and not wasInterrupted then
      mq.cmd('/stopsong')
      local expires = setSongExpires(currentSong) - mq.gettime()
      logger.Info("Completed <%s>, expires in <%dms>", currentSong.Name, expires)
    end

    if castCompleteDue:IsRunning() and wasInterrupted and currentSong then
      logger.Info("Interrupted <%s>...", currentSong.Name)
      wasInterrupted = false
    end

    medleyState = MedleyStates.IDLE
  end)
end

---@param song Song|nil
local function queueSong(song)
  if song then
    commandQueue.Enqueue(function()
      medleyState = MedleyStates.CASTING
      local castTime = song:Cast()
      for _, value in ipairs(events) do
        value:Flush()
      end

      castCompleteDue:Reset(castTime + settings.medleyPadTimeMs)
      logger.Info("Cast <%s> with casttime <%dms>", song.Name, castCompleteDue:TimeRemaining())
      return createPostCommand()
    end)
  end
end

local function onTick()
  if common.IsOrchestrator() then
    return
  end

  if medleyState == MedleyStates.CASTING and not mq.TLO.Window("CastingWindow").Open() then
    medleyState = MedleyStates.IDLE
    if mq.TLO.Me.Casting() then
      mq.cmd("/stopcast")
    end

    mq.delay(1)
  end

  local medley = settings.medleys[assist_state.medley]
  if not medley then
    logger.Info("No medley found for [%s]", assist_state.medley)
    return
  end

  local canPlay, errorMessage = canPlayMelody()
  if not canPlay or medleyState ~= MedleyStates.IDLE then
    if medleyState == MedleyStates.IDLE then
      logger.Warn("Cannot play medley - State: <%s> Reason: <%s>", medleyState, errorMessage)
      if mq.TLO.Me.Casting() then
        print(mq.TLO.Me.Casting())
      end
    end

    return
  end

  currentSong = scheduleNextSong()
  queueSong(currentSong)
end

return onTick