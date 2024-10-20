local mq = require('mq')
local logger = require('knightlinc/Write')
local cast = require('core/casting/cast')

---@class Song : Cast
---@field public DefaultGem integer
---@field public CastTime number
---@field public Duration number
---@field public IsDot boolean
---@field public MQSpell spell
local Song = cast:base()


---@param name string
---@param defaultGem number|nil
---@return Song
function Song:new (name, defaultGem)
  self.__index = self
  if not mq.TLO.Spell(name)() then
    logger.Error("<%s> is not a valid song.", name)
  end

  local spellBookPosition = mq.TLO.Me.Book(name)()
  if not spellBookPosition then
    logger.Error("<%s> is not availbable in spellbook.", name)
  end

  local mqspell = mq.TLO.Spell(name)--[[@as spell]]
  local o = setmetatable(cast:new(mqspell.ID(), name), self)
  o.DefaultGem = defaultGem or 0
  o.CastTime = mqspell.MyCastTime()
  o.Duration = mqspell.Duration.TotalSeconds()*1000
  o.IsDot = false
  o.MQSpell = mqspell
  return o --[[@as Song]]
end

function Song:IsGemReady()
  if not mq.TLO.Me.Gem(self.Name)() then
    return false
  end

  return mq.TLO.Me.GemTimer(self.Name)() == 0
end

---@return number CastTime
function Song:Cast()
  if mq.TLO.Window("SpellBookWnd").Open() then
    mq.cmd("/keypress spellbook")
  end

  if mq.TLO.Me.Ducking() then
    mq.cmd("/keypress duck")
  end

  if mq.TLO.Me.Sitting() then
    mq.cmd("/stand")
  end

  if mq.TLO.Me.Animation() == 16 or mq.TLO.Me.Feigning() then -- Death - https://docs.eqemu.io/server/npc/animations/
    mq.cmd("/stand")
  end

  mq.cmdf('/cast "%s"', self.Name)
  return self.CastTime
end

return Song