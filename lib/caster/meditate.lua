--- @type Mq
local mq = require('mq')
local mqutil = require('utils/mq')
local configLoader = require('utils/configloader')
--- @type MQEvent
local mqEvents = require('lib/mqevent')
--- @type Timer
local timer = require('lib/timer')

---@class CommonConfig
local defaultConfig = {
  MeditateManaPct = 99,
  MeditateWithNpcInCamp = true
}

local config = configLoader("general.mana", defaultConfig)

local tempDisableMeditateTimer = timer:new()

local function youHaveBeenHitEvent()
  tempDisableMeditateTimer = timer:new(10)
end

local disableMeditateEvent = mqEvents:new("disableMeditate", "#*# YOU for #1# points of damage.", youHaveBeenHitEvent)

disableMeditateEvent:Register()

local function doMeditate()
  disableMeditateEvent:DoEvent()

  local me = mq.TLO.Me
  if me.Invis() or me.Casting() or mq.TLO.Window("SpellBookWnd").Open() or mq.TLO.Stick.Active() or mq.TLO.Navigation.Active() then
    return
  end

  if me.Sitting() and ((mqutil.NPCInRange(100) and not config.MeditateWithNpcInCamp) or tempDisableMeditateTimer:IsRunning()) then
    mq.cmd("/stand")
    return
  elseif not me.Sitting() and me.PctMana() < config.MeditateManaPct then
    mq.cmd("/sit")
    return
  end
end

return doMeditate