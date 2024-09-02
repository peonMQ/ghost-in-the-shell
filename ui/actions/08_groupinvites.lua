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


local groups = {
  Eredhrin = {"Hamfast", "Newt", "Bill", "Marillion", "Ithildin"},
  Renaissance = {"Inara", "Tedd", "Araushnee", "Freyja", "Milamber"},
  Soundgarden = {"Lolth", "Ronin", "Tyrion", "Sheperd", "Valsharess"},
  Genesis = {"Vierna", "Osiris", "Regis", "Tiamat", "Mordenkainen"},
  Zeppelin = {"Mizzfit", "Eilistraee", "Komodo", "Nozdormu", "Vorion"},
  Supertramp = {"Moradin", "Aredhel", "Izzy", "Lulz", "Gwydion"},
}

---@type ActionButton
local group = {
  active = false,
  icon = icons.MD_GROUP,
  tooltip = "Create Groups",
  isDisabled = function () return  not app_state.IsActive() end,
  activate = function () end
}

group.isDisabled = function () return group.active == true end
group.activate = function () group.active = true end
local function onClick ()
  if not group.active then
    return
  end

  for leader, members in pairs(groups) do
    for _, member in ipairs(members) do
      if mq.TLO.Me.Name() == leader then
        mq.cmdf("/invite %s", member)
      else
        bci.ExecuteCommand(string.format('/invite %s', member), {leader})
      end
    end
  end
  mq.delay(2000)

  for _leader, members in pairs(groups) do
    for _, member in ipairs(members) do
      bci.ExecuteCommand('/invite', {member})
    end
  end

  group.active = false
end

return {
  ---@param buttonSize ImVec2
  Render = function (buttonSize)
    buttons.CreateButton(group, buttons.BlueButton, buttonSize)
  end,
  OnClick = onClick
}