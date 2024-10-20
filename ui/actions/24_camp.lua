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
local bots = {
  active = app_state.CampLoc ~= nil,
  icon = icons.MD_HOME,
  tooltip = "Toogle Camp",
  isDisabled = function () return false end,
  activate = function() end,
  deactivate = function() end
}

bots.activate = function ()
  local me = mq.TLO.Me
  local command = string.format("/togglecamp %s %s %s", me.X(), me.Y(), me.Z())
  bci.ExecuteZoneWithSelfCommand(command)
end

bots.deactivate = function ()
  bci.ExecuteZoneWithSelfCommand("/togglecamp")
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    bots.active = app_state.CampLoc ~= nil
    buttons.CreateStateButton(bots, buttonSize)
  end,
}