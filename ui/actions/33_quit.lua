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

---@type ActionButton
local quit = {
  active = false,
  icon = icons.FA_POWER_OFF,
  tooltip = "Camp Desktop",
  isDisabled = function () return false end,
  activate = function()
    bci.ExecuteZoneWithSelfCommand('/qtd')
  end,
}

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateButton(quit, buttons.RedButton, buttonSize)
  end,
}