local mq = require('mq')
local imgui = require('ImGui')
local icons = require('mq/Icons')
local logger = require('knightlinc/Write')
local debugUtils = require('utils/debug')
local plugins = require('utils/plugins')
local filetutils = require('utils/file')
local bci = require('broadcast/broadcastinterface')('REMOTE')
local app_state = require('app_state')
local follow_state = require('application/follow_state')
local buttons = require('ui/buttons')

---@type ActionButton
local clickdoor = {
  active = false,
  icon = icons.FA_KEY,
  tooltip = "Click Nearest Door",
  isDisabled = function () return  not app_state.IsActive() end,
  activate = function()
    bci.ExecuteZoneCommand('/clickdoor')
  end,
}

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateButton(clickdoor, buttons.BlueButton, buttonSize)
  end,
}