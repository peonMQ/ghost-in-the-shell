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
local killthis = {
  active = false,
  icon = icons.MD_GPS_FIXED,
  tooltip = "Kill Current Target",
  isDisabled = function () return not app_state.IsActive() or not mq.TLO.Target() or mq.TLO.Target.Type() == "PC" end,
  activate = function()
    bci.ExecuteZoneCommand('/killit '..mq.TLO.Target.ID())
  end,
}

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateButton(killthis, buttons.BlueButton, buttonSize)
  end,
}