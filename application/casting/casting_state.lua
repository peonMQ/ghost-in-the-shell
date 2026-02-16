local mq = require('mq')
local logger = require('knightlinc/Write')
local broadcast = require('broadcast/broadcast')
local timer = require('core/timer')
local castReturnTypes = require('core/casting/castreturn')

---@class CastState
---@field castReturn CastReturn
---@field giveUpTimer Timer
---@field retryTimer Timer
---@field resistCounter integer
---@field recastTime number
---@field recoveryTime number
---@field spellNotHold boolean
local state =  {
  castReturn = castReturnTypes.Unknown,
  giveUpTimer = timer:new(),
  retryTimer = timer:new(),
  resistCounter = 0,
  recastTime = 0,
  recoveryTime = 0,
  spellNotHold = false
}

---@param giveUpTimer? integer
function state.Reset(giveUpTimer)
  state.castReturn = castReturnTypes.Unknown
  state.resistCounter = 0
  state.recastTime = 0
  state.recoveryTime = 0
  state.spellNotHold = false
  state.giveUpTimer = timer:new(giveUpTimer or 0)
  state.retryTimer = timer:new()
end

---@param spellId integer
---@return CastReturn
function state.interrupt(spellId)
  local spellname = mq.TLO.Me.Casting()
  broadcast.InfoAll("Cancelled casting <%s-%s>", spellId,  spellname)
  logger.Debug("Interrupt casting <%s-%s>.", spellId,  spellname)
  mq.cmd("/stopcast")
  state.castReturn = castReturnTypes.Cancelled
  state.giveUpTimer = timer:new(0)
  mq.delay("1s", function () return not mq.TLO.Me.Casting.ID() ~= nil end)
  return state.castReturn
end

---@param castReturn CastReturn
function state.setCastReturn(castReturn)
  logger.Debug("setCastReturn <%s>.", castReturn.Name)
  state.castReturn = castReturn
end

return state