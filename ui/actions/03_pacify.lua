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
local pacify = {
  active = false,
  icon = icons.MD_REMOVE_RED_EYE,
  tooltip = "Pacify Target",
  isDisabled = function () return not app_state.IsActive() end,
  activate = function()
    bci.ExecuteCommand('/pacify '..mq.TLO.Target.ID(), {"Ithildin"})
  end,
}

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateButton(pacify, buttons.YellowButton, buttonSize)
  end,
}