local mq = require('mq')
local logger = require('knightlinc/Write')
local commandQueue  = require('application/command_queue')
local spells_pet = require('data/spells_pet')
local settings = require('settings/settings')
local binder = require('application/binder')

local function GetSentenceCase(str)
  local firstLetter = str:sub(1, 1):upper()
  local remainingLetters = str:sub(2):lower()
  return firstLetter..remainingLetters
end

local function execute(petType)
  local spell, _ = spells_pet(petType)
  if not spell then
    logger.Error("No pet spell found for type <%s>.", petType)
    mq.cmd("/beep")
  else
    settings.pet.type = petType
  end
end

local function createCommand(petType)
    commandQueue.Enqueue(function() execute(GetSentenceCase(petType)) end)
end

binder.Bind("/setpettype", createCommand, "Tells bot to set her/his active summon pet spell to 'type'", 'type')

return execute
