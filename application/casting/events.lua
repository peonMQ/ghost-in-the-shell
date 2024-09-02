local mq = require('mq')
local logger = require('knightlinc/Write')
local castReturnTypes = require('core/casting/castreturn')
local state = require('application/casting/casting_state')
local mqEvents = require('core/mqevent')
local timer = require('core/timer')

local function beginCastEvent()
  state.setCastReturn(castReturnTypes.Success)
end

local function collapseEvent()
  state.giveUpTimer = timer:new(200)
  state.setCastReturn(castReturnTypes.Collapse)
end

local function feignDeathFailedEvent(line, name)
  if(mq.TLO.Me.Name() == name) then
    if(mq.TLO.Me.Standing()) then
      logger.Debug("feignDeathFailedEvent")
      mq.cmd("/stand")
    end

    state.setCastReturn(castReturnTypes.Restart)
  end
end

local function fizzleEvent()
  local fizzleTime = math.ceil(state.recoveryTime/1000)
  state.retryTimer = timer:new(fizzleTime)
  state.setCastReturn(castReturnTypes.Fizzle)
end

local function immuneEvent()
  local recastTime = math.ceil(state.recastTime/1000)
  state.retryTimer = timer:new(recastTime)
  state.setCastReturn(castReturnTypes.Immune)
end

local function interruptedEvent()
  state.setCastReturn(castReturnTypes.Interrupted)
end

local function noHoldEvent()
  state.spellNotHold = true
end

local function cannotSeeEvent()
  state.setCastReturn(castReturnTypes.CannotSee)
end

local function noTargetEvent()
  state.setCastReturn(castReturnTypes.NoTarget)
end

local function notReadyEvent()
  state.setCastReturn(castReturnTypes.NotReady)
end

local function outOfManaEvent()
  state.setCastReturn(castReturnTypes.OutOfMana)
end

local function outOfRangeEvent()
  state.setCastReturn(castReturnTypes.OutOfRange)
end

local function recoverEvent()
  local recastTime = math.ceil(state.recastTime/1000)
  state.retryTimer = timer:new(recastTime)
  state.setCastReturn(castReturnTypes.Recover)
end

local function resistEvent(line, spellname)
  local recastTime = math.ceil(state.recastTime/1000)
  state.retryTimer = timer:new(recastTime)
  state.resistCounter = state.resistCounter + 1
  state.setCastReturn(castReturnTypes.Resisted)
end

local function standEvent()
  mq.cmd("/stand")
  state.setCastReturn(castReturnTypes.Restart)
  logger.Debug("standEvent")
end

local function stunnedEvent()
  state.setCastReturn(castReturnTypes.Stunned)
end

local function notTakeHoldEvent()
  state.setCastReturn(castReturnTypes.NotTakeHold)
end

local events = {
  mqEvents:new("begincast", "You begin casting#*#", beginCastEvent),
  mqEvents:new("collapse", "Your gate is too unstable, and collapses.#*#", collapseEvent),
  mqEvents:new("feignDeathFailed", "#1# has fallen to the ground.#*#", feignDeathFailedEvent),
  mqEvents:new("fizzle", "Your spell fizzles#*#", fizzleEvent),
  mqEvents:new("immuneAttackSpeed", "Your target is immune to changes in its attack speed#*#", immuneEvent),
  mqEvents:new("immuneRunSpeed", "Your target is immune to changes in its run speed#*#", immuneEvent),
  mqEvents:new("immuneMezmerize", "Your target cannot be mesmerized#*#", immuneEvent),
  mqEvents:new("interruptCasting", "Your casting has been interrupted#*#", interruptedEvent),
  mqEvents:new("interruptSpell", "Your spell is interrupted#*#", interruptedEvent),
  mqEvents:new("noHoldSpellDid", "Your spell did not take hold#*#", noHoldEvent),
  mqEvents:new("noHoldSpellWould", "Your spell would not have taken hold#*#", noHoldEvent),
  mqEvents:new("noHoldNoGroupTarget", "You must first target a group member#*#", noHoldEvent),
  mqEvents:new("noHoldToPowerfull", "Your spell is too powerful for your intended target#*#", noHoldEvent),
  mqEvents:new("noLineOfSight", "You cannot see your target.#*#", cannotSeeEvent),
  mqEvents:new("noTarget", "You must first select a target for this spell!#*#", noTargetEvent),
  mqEvents:new("notReady", "Spell recast time not yet met.#*#", notReadyEvent),
  mqEvents:new("outOfMana", "Insufficient Mana to cast this spell!#*#", outOfManaEvent),
  mqEvents:new("outOfRange", "Your target is out of range, get closer!#*#", outOfRangeEvent),
  mqEvents:new("recoverYou", "You haven't recovered yet...#*#", recoverEvent),
  mqEvents:new("recoverSpell", "Spell recovery time not yet met#*#", recoverEvent),
  mqEvents:new("resistTarget", "Your target resisted the #1# spell#*#", resistEvent),
  mqEvents:new("standing", "You must be standing to cast a spell#*#", standEvent),
  mqEvents:new("stunned", "You are stunned#*#", stunnedEvent),
  mqEvents:new("stunnedCast", "You can't cast spells while stunned!#*#", stunnedEvent),
  mqEvents:new("stunnedSilenced", "You *CANNOT* cast spells, you have been silenced!#*#", stunnedEvent),
  mqEvents:new("notTakeHold", "#*# spell did not take hold.#*#", notTakeHoldEvent),
  mqEvents:new("wouldNotTakeHold", "Your spell would not have taken hold.", notTakeHoldEvent),
  mqEvents:new("toPowerful", "Your spell is to powerful for your intended target.", notTakeHoldEvent),
}

for key, value in pairs(events) do
  value:Register()
end

return events