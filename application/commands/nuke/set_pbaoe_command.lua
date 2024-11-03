local mq = require('mq')
local broadcast = require('broadcast/broadcast')
local logger = require('knightlinc/Write')
local commandQueue  = require('application/command_queue')
local settings = require('settings/settings')
local assist_state = require('application/assist_state')
local binder = require('application/binder')
local strings = require('core/strings')

---@param enable boolean
local function execute(enable)
  broadcast.SuccessAll("Set pb aoe to %s", broadcast.ColorWrap(tostring(enable), 'Blue'))
  assist_state.pbaoe_active = enable
end

local function createCommand(enable)
    commandQueue.Enqueue(function() execute(strings.ConvertToBoolean(enable)) end)
end

binder.Bind("/pbaoe", createCommand, "Toggles pb aoe combat with flags", 'on|off')

return execute
