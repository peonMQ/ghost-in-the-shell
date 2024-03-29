local mq = require("mq")
local logger = require("knightlinc/Write")
local broadcast = require 'broadcast/broadcast'
local luautils = require 'utils/lua-table'
local enum = require 'utils/stringenum'
local commandQueue  = require("application/command_queue")
local config = require 'modules/nuker/config'

local validResistTypes = enum({
  -- "Chromatic",
  -- "Corruption",
  "Cold",
  "Disease",
  "Fire",
  "Magic",
  "Poison",
  -- "Unresistable",
  -- "Prismatic"
})

local function execute(resistType)
  logger.Info("Setting nuke lineup [%s]", resistType)
  if not validResistTypes[resistType] then
    logger.Warn("Lineup <%s> does not a valid resist type. Valid keys are: [%s]", resistType, luautils.GetKeysSorted(validResistTypes))
    return
  end

  if not next(config.Nukes) then
    logger.Warn("No nukes defined in config.")
    return
  end

  local newLineUp = {}
  for i=1, #config.Nukes do
    local nuke = config.Nukes[i]
    local spell = mq.TLO.Spell(nuke.Id)
    if validResistTypes[spell.ResistType()] and spell.ResistType() == resistType then
      table.insert(newLineUp, nuke)
      logger.Debug("Added [%s] to new linup.", spell.Name())
    end
  end

  if not next(newLineUp) then
    logger.Warn("Unable to find any nukes in config matching resist type <%s>.", resistType)
    return
  end

  config.CurrentLineup = newLineUp
end

local function createCommand(resistType)
    commandQueue.Enqueue(function() execute(resistType) end)
end

mq.bind("/setnukelineup", createCommand)

return execute
