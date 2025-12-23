local mq = require('mq')
local logger = require('knightlinc/Write')
local plugins = require('utils/plugins')
local commandQueue  = require('application/command_queue')
local binder = require('application/binder')
local worldZones = require('data/zones')

local function tryFindDoorName()
  if mq.TLO.Zone.ShortName() == "overthere" then
    return "HOWLER"
  end

  if mq.TLO.Zone.ShortName() == "veeshan" then
    return "VETELE101"
  end

  return nil
end

---@param doorName string|nil
local function execute(doorName)
  if not doorName then
    mq.cmd("/doortarget")
  else
    mq.cmdf("/doortarget %s", doorName)
  end

  mq.delay(50)
  mq.cmdf("/click left door")
end

local function createCommand()
    commandQueue.Enqueue(function() execute(tryFindDoorName()) end)
end

binder.Bind("/clickdoor", createCommand, 'Tells the bot to click the nearest door if its within range of it.')

