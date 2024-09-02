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

local seekzradius = 20
local seekradius = 100
local query = string.format("npc corpse zradius %d radius %d", seekzradius, seekradius)

---@type ActionButton
local loot = {
  active = false,
  icon = icons.FA_DIAMOND,
  tooltip = "Do Loot",
  isDisabled = function () return not app_state.IsActive() or mq.TLO.SpawnCount(query)() == 0 end,
  activate = function () bci.ExecuteZoneCommand('/doloot '..seekradius) end
}

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateStateButton(loot, buttonSize)
  end
}