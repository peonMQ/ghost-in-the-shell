local mq = require('mq')
local broadcast = require('broadcast/broadcast')
local logger = require('knightlinc/Write')
local commandQueue  = require('application/command_queue')
local settings = require('settings/settings')
local assist_state = require('application/assist_state')
local binder = require('application/binder')

local function arg_to_bool(string_arg)
  if string_arg == nil then
      return false
  end

  if string.lower(string_arg) == 'true' then
    return true
  end

  if string.lower(string_arg) == 'false' then
    return true
  end

  local number_arg = tonumber(string_arg)
  if number_arg then
    return number_arg == 1
  end

  if string.lower(string_arg) == "on" then
    return true
  end

  return false
end


---@param enable boolean
local function execute(enable)
  broadcast.SuccessAll("Set pb aoe to %s", broadcast.ColorWrap(tostring(enable), 'Blue'))
  assist_state.pbaoe_active = enable
end

local function createCommand(enable)
    commandQueue.Enqueue(function() execute(arg_to_bool(enable)) end)
end

binder.Bind("/pbaoe", createCommand, "Toggles pb aoe combat with flags", 'on|off')

return execute
