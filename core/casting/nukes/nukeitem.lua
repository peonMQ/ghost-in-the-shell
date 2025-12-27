local mq = require('mq')
local logger = require('knightlinc/Write')
local item = require('core/casting/item')

---@class NukeItem : Item
---@field public Id integer
---@field public Name string
---@field public ItemName string
---@field public ResistType string
---@field public DPS float
local NukeItem = item:base()

---@param itemName string
---@return NukeItem
function NukeItem:new (itemName)
  self.__index = self
  local o = setmetatable(item:new(itemName), self)
  o.ResistType = mq.TLO.Spell(o.MQSpell.ID()).ResistType()
  return o --[[@as NukeItem]]
end

---@param spawn spawn
---@return boolean
function NukeItem:CanCastOnspawn(spawn)
  if spawn() and spawn.Distance() > self.MQSpell.Range() then
    return false
  end

  if spawn() and spawn.Type() == "Corpse" then
    return false
  end

  return true
end

return NukeItem