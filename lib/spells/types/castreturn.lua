local logger = require("knightlinc/Write")

---@class CastReturn
---@field public Name string
---@field public AbilityRetry boolean
---@field public SpellRetry boolean
local CastReturn = {Name = "", AbilityRetry = false, SpellRetry = false}

---@param name string
---@param abilityRetry? boolean
---@param spellRetry? boolean
---@return CastReturn
function CastReturn:new (name, spellRetry, abilityRetry)
  self.__index = self
  local o = setmetatable({}, self)
  o.Name = name or logger.Fatal("Name is required for <CastReturn>")
  o.AbilityRetry = abilityRetry or false
  o.SpellRetry = spellRetry or false
  return o
end

function CastReturn:__eq(castReturn)
  return self.Name == castReturn.Name
end

function CastReturn:__tostring()
  return self.Name
end

---@enum castReturns
local castReturns = {
  Cancelled = CastReturn:new("CAST_CANCELLED"),
  CannotSee = CastReturn:new("CAST_CANNOTSEE"),
  Collapse = CastReturn:new("CAST_COLLAPSE", true),
  Fizzle = CastReturn:new("CAST_FIZZLE", true),
  Immune = CastReturn:new("CAST_IMMUNE"),
  Interrupted = CastReturn:new("CAST_INTERRUPTED", true, true),
  OutOfMana = CastReturn:new("CAST_OUTOFMANA"),
  OutOfRange = CastReturn:new("CAST_OUTOFRANGE"),
  NoTarget = CastReturn:new("CAST_NOTARGET"),
  NotMemmed = CastReturn:new("CAST_NOTMEMMED"),
  NotReady = CastReturn:new("CAST_NOTREADY"),
  Recover = CastReturn:new("CAST_RECOVER"),
  Resisted = CastReturn:new("CAST_RESISTED"),
  Restart = CastReturn:new("CAST_RESTART", true, true),
  Stunned = CastReturn:new("CAST_STUNNED", true, true),
  Success = CastReturn:new("CAST_SUCCESS"),
  NotTakeHold = CastReturn:new("CAST_NOT_TAKE_HOLD"),
  Unknown = CastReturn:new("CAST_UNKNOWNSPELL")

}

return castReturns