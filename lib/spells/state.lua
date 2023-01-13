--- @type Mq
local mq = require('mq')
local logger = require('utils/logging')
--- @type Timer
local timer = require('lib/timer')
local castReturnTypes = require('lib/spells/types/castreturn')

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

---@return CastReturn
function state.interrupt() 
  logger.Debug("Interrupt casting <%s>.", mq.TLO.Me.Casting())
  mq.cmd("/stopcast")
  state.castReturn = castReturnTypes.Cancelled
  mq.delay("1s", function () return not mq.TLO.Me.Casting.ID() end)
  return state.castReturn
end

---@param castReturn CastReturn
function state.setCastReturn(castReturn) 
  logger.Debug("setCastReturn <%s>.", castReturn.Name)
  state.castReturn = castReturn
end

return state