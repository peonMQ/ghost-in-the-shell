local mq = require('mq')
local imgui = require('ImGui')
local icons = require('mq/Icons')
local logger = require('knightlinc/Write')
local debugUtils = require('utils/debug')
local plugins = require('utils/plugins')
local filetutils = require('utils/file')
local bci = require('broadcast/broadcastinterface')('ACTOR')
local app_state = require('app_state')
local follow_state = require('application/follow_state')
local buttons = require('ui/buttons')
local BotState = require('bot_states')

---@type ActionButton
local bots = {
  active = app_state.IsActive(),
  icon = icons.MD_PAUSE, -- MD_ANDRIOD
  activeIcon = icons.MD_PLAY_ARROW,
  tooltip = "Toogle Bots",
  isDisabled = function () return false end,
  activate = function() end,
  deactivate = function() end
}

bots.activate = function ()
  bci.ExecuteZoneWithSelfCommand(string.format("/gitstoggle %d", BotState.ACTIVE.value))
end

bots.deactivate = function ()
  bci.ExecuteZoneWithSelfCommand(string.format("/gitstoggle %d", BotState.PAUSED.value))
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    bots.active = app_state.IsActive()
    buttons.CreateStateButton(bots, buttonSize)
  end,
}