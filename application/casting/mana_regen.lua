local mq = require('mq')
local mqutil = require('utils/mqhelpers')
local assist = require('core/assist')
local mqEvents = require('core/mqevent')
local timer = require('core/timer')
local settings = require('settings/settings')

local tempDisableMeditateTimer = timer:new(10)

local function youHaveBeenHitEvent()
  tempDisableMeditateTimer:Reset()
end

local disableMeditateEvent = mqEvents:new("disableMeditate", "#*# YOU for #1# points of damage.", youHaveBeenHitEvent)
disableMeditateEvent:Register()

local function doMeditate()
  if assist.IsOrchestrator() then
    return
  end

  disableMeditateEvent:DoEvent()

  local me = mq.TLO.Me
  if me.Invis() or me.Casting() or mq.TLO.Window("SpellBookWnd").Open() or mq.TLO.Stick.Active() or mq.TLO.Navigation.Active() then
    return
  end

  if me.Sitting() and ((mqutil.NPCInRange(100) and not settings.mana.meditate_with_mob_in_camp) or tempDisableMeditateTimer:IsRunning()) then
    mq.cmd("/stand")
  elseif not me.Sitting() and me.PctMana() < settings.mana.meditate and (not mqutil.NPCInRange(100) or settings.mana.meditate_with_mob_in_camp) and tempDisableMeditateTimer:IsComplete() then
    mq.cmd("/sit")
  end
end

local function doManaConversion()
  for _, conversion in pairs(settings.mana.conversions) do
    if conversion:CanCast() then
      conversion:Cast()
    end
  end
end

return {
  DoManaConversion = doManaConversion,
  DoMeditate = doMeditate
}