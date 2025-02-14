local mq = require('mq')
local logger = require('knightlinc/Write')
local mqEvents = require('core/mqevent')
local settings = require('settings/settings')
local assist_state = require('application/assist_state')
local commandQueue  = require('application/command_queue')
local MedleyStates = require('application/medley/medley_states')
local events = require('application/medley/events')
local state = require('application/medley/state')
local changeMedleyCommand = require('application/commands/medley/change_medley_command')

local next = next

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
    return false, string.format("Casting - %s", me.Casting() or 'nil')
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
  return state.currentSong and state.currentSong.MQSpell.HasSPA(SPA_INVISIBILITY)()
end

local function createPostCommand()
  return coroutine.create(function ()
    mq.doevents()

    while mq.TLO.Me.Casting() and (state.castCompleteDue:IsRunning() or currentSongHasInvisEffect()) and not state.wasInterrupted do
      coroutine.yield()
    end

    if state.currentSong and not state.wasInterrupted then
      mq.cmd('/stopsong')
      local expires = setSongExpires(state.currentSong) - mq.gettime()
      logger.Info("Completed <%s>, expires in <%dms>", state.currentSong.Name, expires)
    end

    if state.castCompleteDue:IsRunning() and state.wasInterrupted and state.currentSong then
      logger.Info("Interrupted <%s>...", state.currentSong.Name)
      state.wasInterrupted = false
    end

    mq.cmd('/stopsong')
    state.medleyState = MedleyStates.IDLE
  end)
end

---@param song Song|nil
local function queueSong(song)
  if song then
    commandQueue.Enqueue(function()
      state.medleyState = MedleyStates.CASTING
      local castTime = song:Cast()

      mq.delay(1)
      state.castCompleteDue:Reset(castTime + settings.medleyPadTimeMs)
      logger.Info("Cast <%s> with casttime <%dms>", song.Name, state.castCompleteDue:TimeRemaining())
      -- mq.delay(1500, function() return mq.TLO.Window("CastingWindow").Open() or not mq.TLO.Me.Casting() end)
      return createPostCommand()
    end)
  end
end

local function onTick()
  -- if assist.IsOrchestrator() then
  --   return
  -- end

  if state.medleyState == MedleyStates.UNINITALIZED then
    changeMedleyCommand(assist_state.medley)
    state.medleyState = MedleyStates.IDLE
  end

  if state.medleyState == MedleyStates.IDLE and mq.TLO.Me.Casting() then
    mq.cmd("/stopsong")
  end

  -- if medleyState == MedleyStates.CASTING and not mq.TLO.Window("CastingWindow").Open() then
  --   medleyState = MedleyStates.IDLE
  --   if mq.TLO.Me.Casting() then
  --     logger.Warn("Stoping to sing due to unopen cast window %s %s", mq.TLO.Window("CastingWindow").Open(), mq.TLO.Me.Casting())
  --     mq.cmd("/stopcast")
  --   end

  --   mq.delay(1)
  -- end

  local medley = settings.medleys[assist_state.medley]
  if not medley then
    logger.Debug("No medley found for [%s]", assist_state.medley)
    return
  end

  local canPlay, errorMessage = canPlayMelody()
  if not canPlay or state.medleyState ~= MedleyStates.IDLE then
    if state.medleyState == MedleyStates.IDLE then
      logger.Debug("Cannot play medley - State: <%s> Reason: <%s>", state.medleyState.Name, errorMessage)
    end

    return
  end

  state.currentSong = scheduleNextSong()
  queueSong(state.currentSong)
end

local function reset()
  mq.cmd('/stopsong')
  state:Reset()
  state.medleyState = MedleyStates.IDLE
end

return {
  OnTick = onTick,
  Reset = reset
}