local mq = require('mq')
local imgui = require('ImGui')
local icons = require('mq/Icons')
local logger = require('knightlinc/Write')
local bci = require('broadcast/broadcastinterface')('REMOTE')
local app_state = require('app_state')
local assist_state = require('application/assist_state')
local buttons = require('ui/buttons')

---@type ActionButton
local bots = {
  active = assist_state.pbaoe_active,
  icon = icons.FA_BOMB,
  tooltip = "Toogle PB AoE",
  isDisabled = function () return not app_state.IsActive() end,
  activate = function() end,
  deactivate = function() end
}

bots.activate = function ()
  bci.ExecuteZoneWithSelfCommand("/pbaoe on")
end

bots.deactivate = function ()
  bci.ExecuteZoneWithSelfCommand("/pbaoe off")
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    bots.active = assist_state.pbaoe_active
    buttons.CreateStateButton(bots, buttonSize)
  end,
}