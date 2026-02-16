local icons = require('mq/Icons')
local bci = require('broadcast/broadcastinterface')('REMOTE')
local app_state = require('app_state')
local buttons = require('ui/buttons')

---@type ActionButton
local clickdoor = {
  active = false,
  icon = icons.MD_LOCK_OPEN,
  tooltip = "Lockpick Nearest Door",
  isDisabled = function () return  not app_state.IsActive() end,
  activate = function()
    bci.ExecuteZoneCommand('/lockpick')
  end,
}

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateButton(clickdoor, buttons.BlueButton, buttonSize)
  end,
}